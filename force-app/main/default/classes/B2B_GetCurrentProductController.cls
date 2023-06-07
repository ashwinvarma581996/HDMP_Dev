/**
* @File Name          : B2B_GetCurrentProductController
* @Description        : 
* @Created By         : Faraz Ansari
* @Date               : 26/10/2022
* @Last Modified By   : 26/10/2022
*==============================================================
* Ver         Date			Author           Modification
*==============================================================
* 1.0       26/10/2022    Faraz Ansari      Initial Version
**/
public without sharing class B2B_GetCurrentProductController {
    @AuraEnabled
    public static String getAddedProductsInfo(){
        try{
            String cartId = B2B_HandleCartAndUser.getCurrentCart();
            if(String.isNotEmpty(cartId)){
                Map<String, List<Object>> accessoriesData = new Map<String, List<Object>>();
                List<CartItem> cartItems = [SELECT Id, Name, op_code__c, Product_Division__c, Cart.DealerId__c, Product2Id, 
                                            Product_Model__r.Product_Model_ID__c, unitAdjustedPrice, Sku, Product_Type__c,
                                            Illustration_Id__c, Illustration_Group_Image_Id__c, Section_Id__c, Accessorie_Image_URL__c/*, Category__c, Subcategory__c*/ 
                                            FROM CartItem WHERE CartId =: cartId AND Product2.IsActive = true];
                Set<Id> product2IdSet = new Set<Id>();
                for(CartItem cartItem : cartItems){
                    product2IdSet.add(cartItem.Product2Id);
                }
                Map<Id, String> product2IdAndImageMap = new Map<Id, String>();
                for(Product2 prod : [SELECT ImageURL__c FROM Product2 where id IN :product2IdSet]){
                    if(prod.ImageURL__c != null){
                        product2IdAndImageMap.put(prod.Id, prod.ImageURL__c);
                    }
                }
                if(cartItems.size() > 0 && !cartItems.isEmpty()){
                    //For Accessories
                    for(CartItem itemObj : cartItems){
                        if(product2IdAndImageMap.containsKey(itemObj.Product2Id)){
                            itemObj.Accessorie_Image_URL__c = product2IdAndImageMap.get(itemObj.Product2Id);
                        }
                        if(itemObj.Product_Type__c == 'Accessory' && itemObj.Product_Model__c != null){
                            String data = B2B_EconfigIntegration.getCompleteDetail(itemObj.Product_Model__r.Product_Model_ID__c, itemObj.Product_Division__c);
                            Map<String, Object> mapDbResult = (Map<String, Object>)JSON.deserializeUntyped(data);
                            Map<String, Object> mapDbResult1 = (Map<String, Object>)JSON.deserializeUntyped(mapDbResult.get('accessoryResult')+'');
                            List<Object> mapDbResult2 = (List<Object>)mapDbResult1.get('Accessories');
                            accessoriesData.put(itemObj.op_code__c, mapDbResult2);
                        }
                    }
                    accessoriesData.put('items', cartItems);
                    //For Parts
                    Set<String> modelIds = new Set<String>();
                    Map<String, Vehicle__c> VehicleMap = new Map<String, Vehicle__c>();
                    for(CartItem itemObj : cartItems){
                        if(itemObj.Product_Type__c == 'Part' && itemObj.Product_Model__r.Product_Model_ID__c != null){
                            modelIds.add(itemObj.Product_Model__r.Product_Model_ID__c);
                        }
                    }
                    List<Vehicle__c> vehicles = [SELECT Id, iNDivisionID__c, iNYearID__c, iNModelID__c, iNDoorID__c, iNGradeID__c, 
                                                 iNCatalogID__c, iNTransmissionID__c, Model_Id__c FROM Vehicle__c WHERE 
                                                 Model_Id__c IN: modelIds];
                    for(Vehicle__c itemObj : vehicles){
                        VehicleMap.put(itemObj.Model_Id__c, itemObj);
                    }
                    for(CartItem itemObj : cartItems){
                        if(itemObj.Product_Type__c == 'Part' && itemObj.Product_Model__r.Product_Model_ID__c != null && itemObj.Section_Id__c != null &&
                           itemObj.Illustration_Id__c != null && itemObj.Illustration_Group_Image_Id__c != null)
                        {
                            Vehicle__c vehicleObj = VehicleMap.get(itemObj.Product_Model__r.Product_Model_ID__c);
                            String data = B2B_INSystemIntegration.PartialSearchbyProduct(Integer.valueOf(vehicleObj.iNDivisionID__c), Integer.valueOf(vehicleObj.iNYearID__c),
                                                                                         Integer.valueOf(vehicleObj.iNModelID__c), Integer.valueOf(vehicleObj.iNDoorID__c), 
                                                                                         Integer.valueOf(vehicleObj.iNGradeID__c), Integer.valueOf(vehicleObj.iNCatalogID__c),
                                                                                         Integer.valueOf(vehicleObj.iNTransmissionID__c), Integer.valueOf(itemObj.Section_Id__c),
                                                                                         Integer.valueOf(itemObj.Illustration_Id__c), Integer.valueOf(itemObj.Illustration_Group_Image_Id__c),
                                                                                         0, 0, itemObj.Sku);
                            
                            Map<String, Object> mapDbResult = (Map<String, Object>)JSON.deserializeUntyped(data);
                            List<Object> partsData = (List<Object>)mapDbResult.get('Parts');
                            accessoriesData.put(itemObj.Sku, partsData);
                        }else if(itemObj.Product_Type__c == 'Part' && (itemObj.Section_Id__c == null || itemObj.Illustration_Id__c == null || itemObj.Illustration_Group_Image_Id__c == null)){
                            Product2 productobj = [SELECT Id, (SELECT Id, Product2.Name, Product2.StockKeepingUnit, UnitPrice FROM PricebookEntries) FROM Product2 WHERE Id =: itemObj.Product2Id];
                            accessoriesData.put(itemObj.Sku, productobj.PricebookEntries);
                        }
                    }
                    return JSON.serialize(accessoriesData);
                }
            }
            return '';
        }catch(Exception ex){
            String errorMsg = ex.getMessage() + ' At '+ex.getLineNumber();
            System.debug('Error : '+errorMsg);
            throw new AuraHandledException(errorMsg);
        }
    } 
    @AuraEnabled
    public static void updateCartItems(List<Object> cartItemList){
        String s = JSON.serialize(cartItemList);
        List<CartItem> cartItems = (List<CartItem>) JSON.deserialize(s, List<CartItem>.class);
        try {
            update cartItems;
             // Saravanan LTIM Added for HDMP-18860,18862
             String cartId = B2B_HandleCartAndUser.getCurrentCart();
             CartItemsCtrl.updateCartItemstoSyncDynamically(cartId);
             // Saravanan LTIM Ended for HDMP-18860,18862
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String getAddedProductsInfoByProductId(String productId){
        try{
            String cartId = B2B_HandleCartAndUser.getCurrentCart();
            if(String.isNotEmpty(cartId)){
                Map<String, List<Object>> accessoriesData = new Map<String, List<Object>>();
                List<CartItem> cartItems = [SELECT Id, Name, op_code__c, Product_Division__c, Cart.DealerId__c,  
                                            Product_Model__r.Product_Model_ID__c, unitAdjustedPrice, Sku, Product_Type__c,
                                            Illustration_Id__c, Illustration_Group_Image_Id__c, Section_Id__c FROM CartItem 
                                            WHERE CartId =: cartId And Product2Id =: productId];
                if(cartItems.size() > 0 && !cartItems.isEmpty()){
                    //For Accessories
                    for(CartItem itemObj : cartItems){
                        if(itemObj.Product_Type__c == 'Accessory' && itemObj.Product_Model__c != null){
                            String data = B2B_EconfigIntegration.getCompleteDetail(itemObj.Product_Model__r.Product_Model_ID__c, itemObj.Product_Division__c);
                            Map<String, Object> mapDbResult = (Map<String, Object>)JSON.deserializeUntyped(data);
                            Map<String, Object> mapDbResult1 = (Map<String, Object>)JSON.deserializeUntyped(mapDbResult.get('accessoryResult')+'');
                            List<Object> mapDbResult2 = (List<Object>)mapDbResult1.get('Accessories');
                            accessoriesData.put(itemObj.op_code__c, mapDbResult2);
                        }
                    }
                    accessoriesData.put('items', cartItems);
                    //For Parts
                    Set<String> modelIds = new Set<String>();
                    Map<String, Vehicle__c> VehicleMap = new Map<String, Vehicle__c>();
                    for(CartItem itemObj : cartItems){
                        if(itemObj.Product_Type__c == 'Part' && itemObj.Product_Model__r.Product_Model_ID__c != null){
                            modelIds.add(itemObj.Product_Model__r.Product_Model_ID__c);
                        }
                    }
                    List<Vehicle__c> vehicles = [SELECT Id, iNDivisionID__c, iNYearID__c, iNModelID__c, iNDoorID__c, iNGradeID__c, 
                                                 iNCatalogID__c, iNTransmissionID__c, Model_Id__c FROM Vehicle__c WHERE 
                                                 Model_Id__c IN: modelIds];
                    for(Vehicle__c itemObj : vehicles){
                        VehicleMap.put(itemObj.Model_Id__c, itemObj);
                    }
                    for(CartItem itemObj : cartItems){
                        if(itemObj.Product_Type__c == 'Part' && itemObj.Product_Model__r.Product_Model_ID__c != null && itemObj.Section_Id__c != null &&
                           itemObj.Illustration_Id__c != null && itemObj.Illustration_Group_Image_Id__c != null)
                        {
                            Vehicle__c vehicleObj = VehicleMap.get(itemObj.Product_Model__r.Product_Model_ID__c);
                            String data = B2B_INSystemIntegration.PartialSearchbyProduct(Integer.valueOf(vehicleObj.iNDivisionID__c), Integer.valueOf(vehicleObj.iNYearID__c),
                                                                                         Integer.valueOf(vehicleObj.iNModelID__c), Integer.valueOf(vehicleObj.iNDoorID__c), 
                                                                                         Integer.valueOf(vehicleObj.iNGradeID__c), Integer.valueOf(vehicleObj.iNCatalogID__c),
                                                                                         Integer.valueOf(vehicleObj.iNTransmissionID__c), Integer.valueOf(itemObj.Section_Id__c),
                                                                                         Integer.valueOf(itemObj.Illustration_Id__c), Integer.valueOf(itemObj.Illustration_Group_Image_Id__c),
                                                                                         0, 0, itemObj.Sku);
                            
                            Map<String, Object> mapDbResult = (Map<String, Object>)JSON.deserializeUntyped(data);
                            List<Object> partsData = (List<Object>)mapDbResult.get('Parts');
                            accessoriesData.put(itemObj.Sku, partsData);
                        }
                    }
                    return JSON.serialize(accessoriesData);
                }
            }
            return '';
        }catch(Exception ex){
            String errorMsg = ex.getMessage() + ' At '+ex.getLineNumber();
            System.debug('Error : '+errorMsg);
            throw new AuraHandledException(errorMsg);
        }
    }
    @AuraEnabled
    public static Vehicle__c getVehicleDetailsByModelID(String modelId){
        Vehicle__c vehicle;
        vehicle = [SELECT eConfigSourceCode__c, Year__c, Trim__c, Model__c, iNDivisionID__c, iNGradeID__c,iNYearID__c,iNDoorID__c,iNCatalogID__c,iNTransmissionID__c,iNModelID__c,Model_Id__c 
                   FROM Vehicle__c 
                   WHERE Model_Id__c =: modelId LIMIT 1];
        return vehicle;
    }
    @AuraEnabled
    public static String getCategoryId(String categoryName){
     ProductCategory cat = [select id,name from ProductCategory where name=:categoryName AND Catalog.Name LIKE '%DreamShop%' limit 1];
        return cat.id;
    }
        
    
    
}
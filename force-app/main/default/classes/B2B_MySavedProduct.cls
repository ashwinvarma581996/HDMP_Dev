/**
* @File Name          : B2B_MySavedProduct
* @Description        : Apex class is created to handles all the saved my product.
* @Created By         : Deepak Mali
* @Date               : 08/Feb/2022
* @Last Modified By   : 20/August/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       08/Feb/2022               Deepak Mali           Initial Version
* 2.0       20/August/2022             Farazuddin            -
**/
public without sharing class B2B_MySavedProduct {
    
    private static String getPersonAccountId(){
        String conactId = [SELECT Id, ContactId FROM User WHERE Id =: userinfo.getUserId() Limit 1]?.ContactId;
        String accountId = [Select Id from Account where PersonContactId =: conactId]?.Id;
        return accountId;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Ownership__c > getMyProductList(){
        String objAccountId = getPersonAccountId();
        List<Ownership__c > lstOfMyProducts  = [SELECT Id, Name, Product_Owner__c, Honda_Product__c, Nickname__c, Ownership_Origination__c, Honda_Product__r.Name,
                                                Honda_Product__r.Product_Identifier__c, Honda_Product__r.Alternate_Product_Identifier__c, 
                                                Honda_Product__r.Product_Models__c, Honda_Product__r.Product_Models__r.Name, 
                                                Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Model_Year__c, 
                                                Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Model_ID__c, 
                                                Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Trim__c,
                                                Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c, Honda_Product__r.Product_Models__r.Default_Large_Image_Url__c 
                                                FROM Ownership__c WHERE Product_Owner__c =: objAccountId AND (Ownership_Origination__c = '23' OR Managed__c = true) 
                                                Order by Honda_Product__r.Product_Models__r.Model_Year__c DESC, Honda_Product__r.Product_Models__r.Model_Name__c ASC];
        return lstOfMyProducts;
    }
    
    /*@AuraEnabled(cacheable=true)
    public static Map<Id, Product_Model_Color__c> getProductModelColors(List<String> productModelIdsSet){
        List<Product_Model_Color__c> productModelColors = [SELECT Id, Name, Thumbnail_Image_URL__c, Product_Model__c FROM Product_Model_Color__c Where Product_Model__c IN: productModelIdsSet Order By Id];
        Map<Id, Product_Model_Color__c> productModelIdsAndModelColorMap = new Map<Id, Product_Model_Color__c>(); 
        for(Product_Model_Color__c productModelColor : productModelColors){
            if(productModelIdsAndModelColorMap.containsKey(productModelColor.Product_Model__c) == False)
                productModelIdsAndModelColorMap.put(productModelColor.Product_Model__c, productModelColor);
        }
        return productModelIdsAndModelColorMap;
    }*/ 
    
    @AuraEnabled(cacheable=true)
    public static List<Ownership__c> getMyVINProductList(){
        String objAccountId = getPersonAccountId();
        List<Ownership__c > lstOfMyProducts  = [SELECT Id, Name, Product_Owner__c, Honda_Product__c, Nickname__c, Ownership_Origination__c, Honda_Product__r.Name,
                                                Honda_Product__r.Product_Identifier__c, Honda_Product__r.Alternate_Product_Identifier__c, 
                                                Honda_Product__r.Product_Models__c, Honda_Product__r.Product_Models__r.Name, 
                                                Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Model_Year__c, 
                                                Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Model_ID__c, 
                                                Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Trim__c
                                                FROM Ownership__c WHERE Product_Owner__c =: objAccountId AND Honda_Product__r.Product_Identifier__c != NULL 
                                                AND (Ownership_Origination__c = '23' OR Managed__c = true)];
        return lstOfMyProducts;
    }    
    
    @AuraEnabled
    public static String saveToMyProduct(String vin, String trimModelId, String nickname, String mnfgColorCode){
        try{
            String objAccountId = getPersonAccountId();
            String query = 'SELECT Id, Ownership_Origination__c, Managed__c, Honda_Product__c FROM Ownership__c WHERE Product_Owner__c =: objAccountId AND (';
            if(trimModelId != NULL && trimModelId.length() > 0){
                query += 'Honda_Product__r.Product_Models__r.Product_Model_ID__c =: trimModelId';
            }
            if((trimModelId != NULL && trimModelId.length() > 0) && (vin != NULL && vin.length() > 0)){
                query += ' AND ';
            }
            if(vin != NULL && vin.length() > 0){
                query += 'Honda_Product__r.Product_Identifier__c =: vin';
            }else if(vin == NULL || vin.length() == 0){
                query += ' AND Honda_Product__r.Product_Identifier__c = '+NULL;
            }
            query += ') LIMIT 1';
            List<Ownership__c> ownershipRecords = Database.query(query);
            if(ownershipRecords.size () == 0){
                String qery = 'SELECT Id, Product_Identifier__c, Product_Model_Color__c FROM Honda_Product__c WHERE ';
                if((trimModelId != NULL && trimModelId.length() > 0) && (vin == NULL || vin.length() == 0)){
                    qery += 'Product_Models__r.Product_Model_ID__c =: trimModelId AND Product_Identifier__c = '+NULL;
                }else if((trimModelId != NULL && trimModelId.length() > 0) && (vin != NULL && vin.length() > 0)){
                    qery += 'Product_Models__r.Product_Model_ID__c =: trimModelId AND Product_Identifier__c =: vin';
                }else if(vin != NULL && vin.length() > 0){
                    qery += 'Product_Identifier__c =: vin';
                }
                qery += ' LIMIT 1';
                List<Honda_Product__c> productsList = Database.query(qery);
                if(productsList.size() > 0){
                    if(productsList[0].Product_Model_Color__c == null){
                        updateHondaProductColor(productsList[0].Id, trimModelId, mnfgColorCode);
                    }
                    addOwnershipRecord(objAccountId, productsList[0].Id, nickname, '');
                }else{
                    String productModelId;
                    if(trimModelId != NULL && trimModelId.length() > 0){
                        Product_Model__c product = [SELECT Id FROM Product_Model__c WHERE Product_Model_ID__c =: trimModelId];
                        productModelId = product.Id;
                    }/* else if(vin != NULL && vin.length() > 0){
                        Honda_Product__c product = [SELECT Id, Product_Models__c FROM Honda_Product__c WHERE Product_Identifier__c =: vin];
                        productModelId = product.Product_Models__c;
                    } */
                    if(String.isNotEmpty(productModelId)){
                        String hondaProductId = addHondaProductRecord(productModelId, vin, mnfgColorCode);
                        addOwnershipRecord(objAccountId, hondaProductId, nickname, '');
                    }else{
                        return '';
                    }
                }
                return 'Success';
            } else{
                if(ownershipRecords[0].Ownership_Origination__c != '23' && ownershipRecords[0].Managed__c == false){
                    addOwnershipRecord(objAccountId, ownershipRecords[0].Honda_Product__c, nickname, ownershipRecords[0].Id);
                    return 'Success';
                }else{
                    return 'Already Exists';
                }
            }
        }catch(Exception ex){
            String errorMsg = ex.getMessage() + ' At '+ex.getLineNumber();
            return errorMsg;
        }
    } 
    
    private static String addHondaProductRecord(String productId, String vin, String mfgColorCode){
        //List<Product_Model_Color__c> productModelColors = [SELECT Id FROM Product_Model_Color__c WHERE Product_Model__c =: productId Order By Id];
        String query = 'SELECT Id FROM Product_Model_Color__c WHERE Product_Model__c =: productId';
        if(mfgColorCode != NULL && mfgColorCode.length() > 0){
            query += ' AND Manufacturer_Color_Code__c =: mfgColorCode';
        }    
        List<Product_Model_Color__c> productModelColors = Database.query(query);
        Honda_Product__c hondaProductObj = new Honda_Product__c(Product_Models__c = productId);
        if(String.isNotEmpty(vin)){
            hondaProductObj.Product_Identifier__c = vin;
        }
        if(productModelColors.size() > 0 && productModelColors.isEmpty() == false){
            hondaProductObj.Product_Model_Color__c = productModelColors[0].Id;
        }
        insert hondaProductObj;
        return hondaProductObj.Id;
    }

    private static String updateHondaProductColor(String hondaProductId, String trimId, String mfgColorCode){
        if(trimId != NULL && trimId.length() > 0){
            Product_Model__c product = [SELECT Id FROM Product_Model__c WHERE Product_Model_ID__c =: trimId LIMIT 1];
            String productId = product.Id;
            String query = 'SELECT Id FROM Product_Model_Color__c WHERE Product_Model__c =: productId';
            if(mfgColorCode != NULL && mfgColorCode.length() > 0){
                query += ' AND Manufacturer_Color_Code__c =: mfgColorCode';
            }    
            List<Product_Model_Color__c> productModelColors = Database.query(query);
            if(productModelColors.size() > 0 && productModelColors.isEmpty() == false){
                Honda_Product__c hondaProductObj = new Honda_Product__c(Id = hondaProductId, Product_Model_Color__c = productModelColors[0].Id);
                update hondaProductObj;
                return hondaProductObj.Id;
            }
        }
        return '';
    }
    
    private static String addOwnershipRecord(String objAccountId, String hondaProductId, String nickname, String Id){
        Ownership__c ownershipObj = new Ownership__c();
        ownershipObj.Product_Owner__c = objAccountId;
        ownershipObj.Honda_Product__c = hondaProductId;
        ownershipObj.Ownership_Origination__c = '23';
        ownershipObj.Nickname__c = nickname;
        ownershipObj.Ownership_Unique_ID__c = objAccountId + '~' + hondaProductId;
        if(String.isNotEmpty(Id)){
            ownershipObj.Id = Id;
        }
        upsert ownershipObj;
        return 'ownership created.';
    }
    
    @AuraEnabled
    public static String deleteMyProduct(String recordId){
        try{
            List<Ownership__c> lstOfMyProducts  = [SELECT Id FROM Ownership__c WHERE Id =: recordId];
            delete lstOfMyProducts;
            return 'Success';
        }catch(Exception ex){
            String errorMsg = ex.getMessage() + ' At '+ex.getLineNumber();
            return errorMsg;
        }
    }   
    
    @AuraEnabled
    public static String updateMyProduct(String recordId, String nickname, String vin, String trimModelId, String mnfgColorCode){
        try{
            if(vin != NULL && vin.length() > 0){
                String objAccountId = getPersonAccountId();
                String qury = 'SELECT Id, Ownership_Origination__c, Managed__c, Honda_Product__c FROM Ownership__c WHERE Product_Owner__c =: objAccountId AND (';
                if(trimModelId != NULL && trimModelId.length() > 0){
                    qury += 'Honda_Product__r.Product_Models__r.Product_Model_ID__c =: trimModelId AND ';
                }
                qury += 'Honda_Product__r.Product_Identifier__c =: vin) LIMIT 1';
                List<Ownership__c> ownershipRecords = Database.query(qury);
                if(ownershipRecords.size () == 0){
                    String query = 'SELECT Id, Product_Identifier__c, Product_Model_Color__c FROM Honda_Product__c WHERE Product_Identifier__c =: vin LIMIT 1';
                    List<Honda_Product__c> productsList = Database.query(query);
                    system.debug('productsList' +productsList);
                    if(productsList.size() > 0){
                        if(productsList[0].Product_Model_Color__c == null){
                            updateHondaProductColor(productsList[0].Id, trimModelId, mnfgColorCode);
                        }
                        addOwnershipRecord(objAccountId, productsList[0].Id, nickname, recordId);
                    }else{
                        if(trimModelId != NULL && trimModelId.length() > 0){
                            Product_Model__c product = [SELECT Id FROM Product_Model__c WHERE Product_Model_ID__c =: trimModelId];
                            String productModelId = product.Id;
                            if(String.isNotEmpty(productModelId)){
                                String hondaProductId = addHondaProductRecord(productModelId, vin, mnfgColorCode);
                                addOwnershipRecord(objAccountId, hondaProductId, nickname, recordId);
                            }else{
                                return '';
                            }
                        }else{
                            return '';
                        }
                    }
                }else{
                    if(ownershipRecords[0].Ownership_Origination__c != '23' && ownershipRecords[0].Managed__c == false){
                        addOwnershipRecord(objAccountId, ownershipRecords[0].Honda_Product__c, nickname, ownershipRecords[0].Id);
                        return 'Success';
                    }else{
                        return 'Already Exists';
                    }
                }
            }else{
                Ownership__c ownershipObj  = new Ownership__c(Id = recordId, Nickname__c = nickname);
                update ownershipObj;
            }
            return 'Success';
        }catch(Exception ex){
            String errorMsg = ex.getMessage() + ' At '+ex.getLineNumber();
            return errorMsg;
        }
    }
}
/*********************************************************************************************************************
Name: 			B2B_ShoppingSelectionController
Created Date: 	09/09/2022
Description: 	Apex class is created to handle last shopping selection for logged in user in Dreamshop.
Test Class: 	B2B_ShoppingSelectionControllerTest
Dev Name: 		Faraz Ansari
***********************************************************************************************************************
MODIFICATIONS – Date 		|	Dev Name		|	Method		|	User Story
***********************************************************************************************************************
							|					|				|
***********************************************************************************************************************/

public without sharing class B2B_ShoppingSelectionController {
    static String currentUserFName = UserInfo.getFirstName();
    private static String getPersonAccountId(){
        String conactId = [SELECT Id, ContactId FROM User WHERE Id =: userinfo.getUserId() Limit 1]?.ContactId;
        String accountId = [Select Id from Account where PersonContactId =: conactId]?.Id;
        return accountId;
    }
    
    @AuraEnabled
    public static string saveLastShoppingSelection(String dataAsObj){
        if(!currentUserFName.containsIgnoreCase('Guest')){
            try {
                String objAccountId = getPersonAccountId();
                Shopping_Selection__c shoppingSelectionObj = (Shopping_Selection__c) JSON.deserialize(dataAsObj, Shopping_Selection__c.class);
                shoppingSelectionObj.Account__c = objAccountId;
                List<Shopping_Selection__c> shoppingSelections = [SELECT Id, Last_Product_ModelId__c, Product_Subdivision__c, Product_Identifier__c 
                                                                  FROM Shopping_Selection__c WHERE Account__c =: objAccountId
                                                                  AND Product_Subdivision__c =: shoppingSelectionObj.Product_Subdivision__c];
                if(shoppingSelections.size() > 0){
                    shoppingSelectionObj.Id = shoppingSelections[0].Id;
                }
                upsert shoppingSelectionObj;
                return 'success';
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return '';
    }
    
    @AuraEnabled
    public static string getMyShoppingSelectionRecords(){
        try {
            String objAccountId = getPersonAccountId();
            if(String.isNotEmpty(objAccountId)){
                List<Shopping_Selection__c> shoppingSelections = [SELECT Id, Name, Last_Product_ModelId__c, Account__c, Product_Subdivision__c,
                                                                  Product_Identifier__c, AK_Shopping_Selection__c FROM Shopping_Selection__c WHERE
                                                                  Account__c = : objAccountId];
                if(shoppingSelections.size() > 0 && shoppingSelections.isEmpty() == false && !currentUserFName.containsIgnoreCase('Guest')){
                    Map<String, String> mapVehicleDetails = new Map<String, String>();
                    Set<String> modelIds = new Set<String>();
                    for(Shopping_Selection__c shoppingObj : shoppingSelections){
                        modelIds.add(shoppingObj.Last_Product_ModelId__c);
                        mapVehicleDetails.put(shoppingObj.Product_Subdivision__c +'VIN',shoppingObj.Product_Identifier__c);
                    }
                    List<Vehicle__c> vehicles = [SELECT Id, iNDivisionID__c, iNYearID__c, Year__c, iNModelID__c, Model_Id__c, Model__c, Trim__c FROM Vehicle__c WHERE Model_Id__c IN: modelIds]; 
                    for(Vehicle__c vehicleObj : vehicles){
                        String vehicleModels = B2B_EconfigIntegration.getVehicleModel(String.valueOf(vehicleObj.iNDivisionID__c), Integer.valueOf(vehicleObj.iNYearID__c));
                        String vehicleTrims = B2B_EconfigIntegration.getVehicleTrim(String.valueOf(vehicleObj.iNDivisionID__c), Integer.valueOf(vehicleObj.iNYearID__c), vehicleObj.Model__c);
                        String brandType = vehicleObj.iNDivisionID__c > 0? vehicleObj.iNDivisionID__c == 1 ? 'Honda' : vehicleObj.iNDivisionID__c == 2 ? 'Acura' : '' : '';
                        mapVehicleDetails.put(brandType +'VehicleModels',vehicleModels);
                        mapVehicleDetails.put(brandType +'VehicleTrims',vehicleTrims);
                        mapVehicleDetails.put(brandType +'Vehicle',JSON.serialize(vehicleObj));
                    }
                    if(mapVehicleDetails.size() > 0){
                        return JSON.serialize(mapVehicleDetails);
                    }
                }
            }
            return 'No records found';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static User getUserDetails(String userId){
        User user = [SELECT Id, Name, Email FROM User Where Id =: userId];
        user.Email = getCartBrand();
        return user;
    }
    @AuraEnabled
    public static string saveLastDealer(Shopping_Selection__c shoppingSelection){
        if(!currentUserFName.containsIgnoreCase('Guest')){
            try {
                String objAccountId = getPersonAccountId();
                shoppingSelection.Account__c = objAccountId;
                List<Shopping_Selection__c> shoppingSelections = [SELECT Id, Last_Product_ModelId__c, Product_Subdivision__c, Product_Identifier__c 
                                                                  FROM Shopping_Selection__c WHERE Account__c =: objAccountId
                                                                  AND Product_Subdivision__c =: shoppingSelection.Product_Subdivision__c];
                if(shoppingSelections.size() > 0){
                    shoppingSelection.Id = shoppingSelections[0].Id;
                }
                upsert shoppingSelection;
                return 'success';
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return '';
    }
    @AuraEnabled
    public static Account getDealerByPOIID(String poiId){
        List<Account> accs = [SELECT Id, Name, PoIId__c FROM Account Where PoIId__c =: poiId];
        return accs.size() > 0 ? accs[0] : null;
    }
    @AuraEnabled
    public static List<Account> getLastDealers(){
        List<Account> lastDealers = null;
        String accId = getPersonAccountId();
        if(String.isNotEmpty(accId)){
            List<Shopping_Selection__c> shoppingSelections = [SELECT Last_Dealer__c FROM Shopping_Selection__c WHERE Account__c = : accId Order By LastModifiedDate DESC];
            Set<Id> lastDealerIdsSet = new Set<Id>();
            if(shoppingSelections.size() > 0 && !currentUserFName.containsIgnoreCase('Guest')){
                for(Shopping_Selection__c shoppingSelection : shoppingSelections){
                    if(shoppingSelection.Last_Dealer__c != Null){
                        lastDealerIdsSet.add(shoppingSelection.Last_Dealer__c);
                    }
                }
            }
            if(lastDealerIdsSet.size() > 0){
                try{
                    lastDealers = [SELECT Id, DivisionCd__c, Name, IsActive__c, PoIId__c FROM Account Where Id IN :lastDealerIdsSet And IsActive__c = True];
                }catch(Exception e){
                   lastDealers = null;
                }
            }
        }
        return lastDealers;
    }
    @AuraEnabled
    public static Account saveAwardsToDealers(Account acc){
        update acc;
        return acc;
    }
    @AuraEnabled(cacheable=true)
    public static String getCartBrand(){
        String brand = null;
        List<WebCart> webCart = [SELECT Id, OwnerId, Status FROM WebCart Where Status = 'Active' And OwnerId =: Userinfo.getUserId()];
        if(webCart.size() > 0){
            List<CartItem> cartItems = [SELECT Id, Name, Product_Subdivision__c FROM CartItem Where CartId =: webCart[0].Id];
            if(cartItems.size() > 0 && cartItems[0].Product_Subdivision__c != null){
                brand = cartItems[0].Product_Subdivision__c;
            }
        }
        return brand;
    }
}
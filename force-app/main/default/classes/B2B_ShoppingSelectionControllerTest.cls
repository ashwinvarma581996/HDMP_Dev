/*********************************************************************************************************************
Name: 			B2B_ShoppingSelectionControllerTest
Created Date: 	09/09/2022
Description: 	Apex class is created to for test coverage of B2B_ShoppingSelectionController.
Dev Name: 		Faraz Ansari
***********************************************************************************************************************
MODIFICATIONS – Date 		|	Dev Name		|	Method		|	User Story
***********************************************************************************************************************
							|					|				|
***********************************************************************************************************************/
@isTest
private class B2B_ShoppingSelectionControllerTest {
	@isTest static void testgetMyShoppingSelectionRecords(){
        B2B_ShoppingSelectionController.getMyShoppingSelectionRecords();
        User testUser = B2B_TestDataFactory.personAccountUser(True);
        System.runAs(testUser){
            Vehicle__c vehicleObj = new Vehicle__c(iNDivisionID__c = 1, iNYearID__c = 5, Model_Id__c = 'abcde', Model__c = 'AB-C',
                                                   Year__c = 2020, Trim__c = 'Test Trim');
            insert vehicleObj;
            String conactId = [SELECT Id, ContactId FROM User WHERE Id =: userinfo.getUserId() Limit 1]?.ContactId;
            String accountId = [Select Id from Account where PersonContactId =: conactId]?.Id;
            Shopping_Selection__c shoppingSelectionObj = new Shopping_Selection__c(Last_Product_ModelId__c = 'abcde',
                                Product_Subdivision__c = 'Honda', Account__c = accountId, Product_Identifier__c = '12345678901234567');
            insert shoppingSelectionObj;
            B2B_ShoppingSelectionController.getMyShoppingSelectionRecords();
            B2B_ShoppingSelectionController.saveLastDealer(shoppingSelectionObj);
        }
    }
    @isTest static void testsaveLastShoppingSelection(){
        Shopping_Selection__c obj = new Shopping_Selection__c(Last_Product_ModelId__c = 'abcde', Product_Subdivision__c = 'Honda');
        B2B_ShoppingSelectionController.saveLastShoppingSelection(JSON.serialize(obj));
        try{B2B_ShoppingSelectionController.saveLastShoppingSelection('');}catch(Exception e){}
    }
    @isTest static void getUserDetailsTest(){
        Test.startTest();
        User u=[select id from user limit 1];
        B2B_ShoppingSelectionController.getUserDetails(u.Id);
        Test.stopTest();
    }
    @isTest static void getDealerByPOIIDTest(){
        Test.startTest();
        User u=[select id from user limit 1];
        B2B_ShoppingSelectionController.getDealerByPOIID('');
        Test.stopTest();
    }
    @isTest static void saveAwardsToDealersTest(){
        Test.startTest();
        User u=[select id from user limit 1];
        Account acc = new Account(Name = 'Award');
        insert acc;
        B2B_ShoppingSelectionController.saveAwardsToDealers(acc);
        Test.stopTest();
    }
    @isTest static void getLastDealersTest(){
        Test.startTest();
        User u=[select id from user limit 1];
        B2B_ShoppingSelectionController.getLastDealers();
        Test.stopTest();
    }
    /*@isTest static void saveLastDealerTest(){
        Test.startTest();
        B2B_ShoppingSelectionController.saveLastDealer(new Shopping_Selection__c());
        Test.stopTest();
    }*/
}
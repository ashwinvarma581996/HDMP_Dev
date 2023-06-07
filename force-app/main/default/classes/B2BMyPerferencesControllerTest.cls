/*******************************************************************************
Name: B2BMyPerferencesControllerTest
Business Unit: HDM
Date: 25/05/2021
Developer: Apoorv Garg
Description: Test class for B2BMyPerferencesController.
*******************************************************************************
MODIFICATIONS – Date | Dev Name 	| Method | User Story
21/07/22    saikiran      Added checkCurrentUserIsGuestTest1
15/08/2022  	Mathioli 	insertMyPreferredShipping (HDMP-5356 JIRA Number)
*******************************************************************************/
@isTest
public class B2BMyPerferencesControllerTest {
    @testSetup 
    public static void setup(){
        User objUser = [Select Id, ContactId from User where ISACTIVE = TRUE  LIMIT 1];
        
        Account acc = new Account();
        acc= B2B_TestDataFactory.createAccount(true);
        
        Contact con = new Contact();
        con = B2B_TestDataFactory.createContact(true);
        Honda_Shipping_Speed__c hp=B2B_TestDataFactory.createshippingSpeed('Standard (7-10 Days)');
        Account myPreferredShipping = new Account();
        myPreferredShipping.Name='Test user';
        // myPreferredShipping.Person_Account__c = acc.Id;
        //myPreferredShipping.B2B_Department_Preference__c = 'Parts';
        myPreferredShipping.Preferred_Delivery_Type__c = 'Ship to Me';
        myPreferredShipping.Preferred_Honda_Shipping_Speed__c= hp.Id;
        insert myPreferredShipping;
        
    }
    
    @isTest 
    public static void getPickListValuesTest() {
        Map<string, List<String>> pickListValues = B2BMyPerferencesController.getPickListValues();
        System.assertEquals(false, pickListValues.isEmpty());
    }
    
    @isTest 
    public static void checkCurrentUserIsGuestTest() {
        Boolean checkGuestUser = B2BMyPerferencesController.checkCurrentUserIsGuest();
        System.assertEquals(false, checkGuestUser);
    }
    //Added by saikiran to cover test coverage for B2BMyPerferencesController
    @isTest 
    public static void checkCurrentUserIsGuestTest1() {
        user us = [SELECT Id,ContactId,Name FROM User where ContactId != null AND Name Like 'Guest%' limit 1];
        System.runAs(us){
            Boolean checkGuestUser = B2BMyPerferencesController.checkCurrentUserIsGuest();}
    }
    
    @isTest 
    public static void checkExistingShippingPerferencesTest() {
        user us = [SELECT Id,ContactId,Name FROM User where ContactId != null AND Name Like 'Guest%' limit 1];
        System.runAs(us){
            List<Account> checkExistingShipping = B2BMyPerferencesController.checkExistingShippingPerferences();
            
            System.assertEquals(0, checkExistingShipping.size());}
    }  
    @isTest 
    public static void insertMyPreferredShippingTest() {
        User uid=B2B_TestDataFactory.personAccountUser(True);
        system.runAs(uid ){ 
            String insertShiping = B2BMyPerferencesController.insertMyPreferredShipping('ship to me','Standard (7-10 Days)');
            List<Account> mypeferredShippingList1 = new  List<Account>();
            Honda_Shipping_Speed__c hp=B2B_TestDataFactory.createshippingSpeed('Standard (7-10 Days)');
            
            
            System.assertEquals('Success', insertShiping);
        }
        
    }
    @isTest 
    public static void insertMyPreferredShippingTestnegative() {
        User uid=B2B_TestDataFactory.personAccountUser(True);
        system.runAs(uid ){ 
            List<Account> mypeferredShippingList2 = new  List<Account>();
            mypeferredShippingList2.add(new account());
            String insertShiping = B2BMyPerferencesController.insertMyPreferredShipping(null,NULL);
            
            System.assertEquals('Fail', insertShiping);
        }
        
    }  
}
/**********************************************************************
Name			: 	B2B_LoggedInUserAddressCheckTest
Purpose			: 	Test Class for B2B_LoggedInUserAddressCheck.
Date 			: 	03/03/2022		
Created By 		: 	Sayalee
*******************************************************************************
MODIFICATIONS – Date 		|	Dev Name		|	Method		|	User Story
*******************************************************************************
	V1			19/07/2022	|	Ravi Prasad		|				|	
********************************************************************************/
@isTest
public with sharing class B2B_LoggedInUserAddressCheckTest {
    
    @isTest
    public static void loggedInUser()
    {
        User u = B2B_TestDataFactory.personAccountUser(true);
        System.runAs(u){
            List<My_Address_Book__c> newList = new List<My_Address_Book__c>();
            Test.startTest();
            My_Address_Book__c address = B2B_TestDataFactory.createAddressBook(true);
            newList = B2B_LoggedInUserAddressCheck.loggedInuser();
            Test.stopTest(); 
        }
    }
    
    @isTest
    public static void loggedInUserAddressList()
    {
        User u = B2B_TestDataFactory.personAccountUser(true);
        System.runAs(u){
            List<My_Address_Book__c> newList = new List<My_Address_Book__c>();
            Test.startTest();
            My_Address_Book__c address = B2B_TestDataFactory.createAddressBook(true);
            newList = B2B_LoggedInUserAddressCheck.loggedInuserAddressList(); 
            Test.stopTest(); 
        }
    }
    
    @isTest
    public static void deleteAddressBook()
    {
        try{
            My_Address_Book__c myAdd = B2B_TestDataFactory.createAddressBook(true);
            My_Address_Book__c address = new My_Address_Book__c();
            address.Name = 'New Address';
            address.Address__c = '4951 Lake Forrest Way Suite 201ac';
            address.isPreferred__c = true;
            insert address;
            BT_Payment_Method__c BTPaymentObj = new BT_Payment_Method__c();
            BTPaymentObj.Default_Payment_Method__c = true;
            Test.startTest();
            B2B_LoggedInUserAddressCheck.deleteAddressBook(address.Id);  
            Test.stopTest();
        }
        catch(Exception e){
            system.debug('error msg123->'+e.getMessage());
        }  
    }
    
    @isTest
    public static void getStateCodes(){
        Test.startTest();
        B2B_LoggedInUserAddressCheck.getStateAddressBook(); 
        Test.stopTest(); 
    }
    
    @isTest
    public static void createAddress()
    {
        User u = B2B_TestDataFactory.personAccountUser(true);
        System.runAs(u){  
            My_Address_Book__c myAdd = B2B_TestDataFactory.createAddressBook(true);
            Test.startTest();
            myAdd.Phone__c = '1234982654';
            B2B_LoggedInUserAddressCheck.createAddressRecord(JSON.serialize(myAdd));
            My_Address_Book__c myAdd2 = B2B_TestDataFactory.createAddressBook(true);
            myAdd2.Name = 'New Address1';
            myAdd2.City__c = 'CA';
            myAdd2.Phone__c = '1234987654';
            B2B_LoggedInUserAddressCheck.updateAddressBook(JSON.serialize(myAdd2));
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testCreateAddressForNegative()
    {
        User u = B2B_TestDataFactory.personAccountUser(true);
        System.runAs(u){
            Test.startTest();
            try{
                B2B_LoggedInUserAddressCheck.createAddressRecord('Test');
            } catch(Exception ex){
                
            }
            Test.stopTest();
        }
    }
    
    @isTest
    public static void createAddress2()
    {
        User u = B2B_TestDataFactory.personAccountUser(true);
        String accId = [SELECT Id FROM Account WHERE PersonContactId =: u.ContactId].Id;
        System.runAs(u){  
            My_Address_Book__c myAdd2 = B2B_TestDataFactory.createAddressBook(true);
            myAdd2.Name = 'New Address';
            myAdd2.City__c = 'GA';
            myAdd2.Phone__c = '1234567891';
            myAdd2.Person_Address_Account__c = accId;
            insert myAdd2;
            Test.startTest();
            B2B_LoggedInUserAddressCheck.updateAddressBook(JSON.serialize(myAdd2));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void markAsPrefferedDirectly()
    {
        My_Address_Book__c myAdd = B2B_TestDataFactory.createAddressBook1(true);
        System.debug('$myAdd: '+myAdd);
        // String id = [Select Id from My_Address_Book__c where Id =: myAdd.Id].Id;
        // System.debug('$id: '+id);   
        Test.startTest();
        try{
            // B2B_LoggedInUserAddressCheck.markAsPrefferedDirectly(id);
            myAdd.isPreferred__c = False;
            update myAdd;
            // B2B_LoggedInUserAddressCheck.markAsPrefferedDirectly(id);
        }
        catch(Exception e){   
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testMarkAsPrefferedDirectlyNegative()
    {
        My_Address_Book__c myAdd = B2B_TestDataFactory.createAddressBook1(true);
        // String id = [Select Id from My_Address_Book__c where Id =: myAdd.Id].Id;
        Test.startTest();
        try{
            B2B_LoggedInUserAddressCheck.markAsPrefferedDirectly('Test');
            myAdd.isPreferred__c = False;
            update myAdd;
        }
        catch(Exception e){   
        }
        Test.stopTest();
    } 
    @isTest
    public static void testloggedInuserAllAddressList()
    {
        My_Address_Book__c myAdd = B2B_TestDataFactory.createAddressBook1(true);
        // String id = [Select Id from My_Address_Book__c where Id =: myAdd.Id].Id;
        Test.startTest();
        try{
            B2B_LoggedInUserAddressCheck.loggedInuserAllAddressList();
        }catch(Exception e){   
        }
        Test.stopTest();
    } 
    @isTest
    public static void testgetEditAddressInfo()
    {
        My_Address_Book__c myAdd = B2B_TestDataFactory.createAddressBook1(true);
        Test.startTest();
        try{
            B2B_LoggedInUserAddressCheck.getEditAddressInfo('');
        }catch(Exception e){   
        }
        Test.stopTest();
    } 
}
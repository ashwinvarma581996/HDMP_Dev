/**********************************************************************
Name: 		B2B_PayPalCheckoutControllerTest
Purpose: 	Test class for B2B_PayPalCheckoutController
Date: 		01/09/2022
Created by: Rajrishi Kaushik
*******************************************************************************
MODIFICATIONS – Date 		|	Dev Name		|	Method		|	User Story
********************************************************************************/
@isTest
public class B2B_PayPalCheckoutControllerTest {
    
    @testSetup static void setup() {    
        account acc = B2B_TestDataFactory.createAccount(true, 'testMerchant');
        account acc1 = B2B_TestDataFactory.createAccount(true, '');
        webStore store = B2B_TestDataFactory.createStore(true);
        WebCart cart = new WebCart();
        cart.Name = 'Test cart';
        cart.PoNumber = '123';
        cart.AccountId = acc.Id;
        cart.WebStoreId = store.Id;
        cart.Status = 'Active';
        cart.Type = 'Cart'; 
        cart.DealerId__c  = acc.id;
        cart.CustomerStreet__c = '1234 Main Street'; 
        cart.CustomerCity__c = 'DALLAS'; 
        cart.Customer_State__c = 'TX'; 
        cart.CustomerCountry__c = 'USA';
        cart.CustomerPostalCode__c = '75201';
        cart.Delivery_Type__c = 'Install At Dealer';
        cart.ShippingAmount__c = 0;
        insert cart;
        
        WebCart cart1 = new WebCart();
        cart1.Name = 'Test cart1';
        cart1.PoNumber = '1234';
        cart1.AccountId = acc1.Id;
        cart1.WebStoreId = store.Id;
        cart1.Status = 'Active';
        cart1.Type = 'Cart'; 
        cart1.DealerId__c  = acc1.id;
        cart1.CustomerStreet__c = '1234 Main Street'; 
        cart1.CustomerCity__c = 'DALLAS'; 
        cart1.Customer_State__c = 'TX'; 
        cart1.CustomerCountry__c = 'USA';
        cart1.CustomerPostalCode__c = '75201';
        cart1.Delivery_Type__c = 'Install At Dealer';
        cart1.ShippingAmount__c = 0;
        insert cart1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objuser = new User(Alias = 'standt', Email='rajuser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                                UserName='rajuser@testorg.com');
        insert objuser;
        
        B2B_Custom_Settings__c obj = B2B_TestDataFactory.createCustomSetting(true, acc.Id, objuser.Id);
        Order ord = B2B_TestDataFactory.createOrder(true, acc.Id, cart.Id);
        BT_Customer_Details__c objCustomer = new BT_Customer_Details__c();
        objCustomer.BT_CustomerId__c = '23456534567';
        objCustomer.Name = 'Raj';
        insert objCustomer;
        
        BT_Payment_Method__c objPayment = new BT_Payment_Method__c();
        objPayment.Payment_Method_Token__c = '34567tfdsdf';
        objPayment.BT_Customer_Details__c = objCustomer.Id;
        objPayment.Credit_Card_Number__c = '1111';
        insert objPayment;
        
        BT_Token_Details__c bToken = B2B_TestDataFactory.createBTTokenDetails(true, acc.Id );
    }
    
	@isTest
    public static void unitTest1(){
        webCart cart = [select id , DealerId__c from webCart limit 1];
        test.startTest();
        B2B_PayPalCheckoutController.getClientToken(cart.Id);
        test.stopTest();
    }
    
    @isTest
    public static void unitTest2(){
        webCart cart = [select Id , DealerId__c from webCart limit 1];
        String shippingAddress = '{ "recipientName" : "test user", "line1":"test address 1", "city":"New York", "State" : "NY", "countryCode": "USA", "postalCode" : "456001"}';
        test.startTest();
        B2B_PayPalCheckoutController.updateCart(shippingAddress, 'test1@gmail.com', '9982345754', cart.Id, 'Ship To Me');
        B2B_PayPalCheckoutController.updateCart(shippingAddress, 'test1@gmail.com', '9982345754', cart.Id, 'Pickup At Dealer');
        test.stopTest();
    }  
    
    @isTest
    public static void unitTest3(){
        webCart cart = [select id , DealerId__c from webCart limit 1];
        test.startTest();
        B2B_PayPalCheckoutController.calculateShippingCharges(cart.Id);
        test.stopTest();
    }
    
    @isTest
    public static void unitTest4(){
        webCart cart = [select id , DealerId__c from webCart limit 1];
        test.startTest();
        B2B_PayPalCheckoutController.calculateTaxes(cart.Id);
        test.stopTest();
    }
    
    @isTest
    public static void unitTest5(){
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId' , (object)'23456534567');
        custMap.put('address1' , (object)'test');
        custMap.put('address2' , (object)'test');
        custMap.put('city' , (object)'test');
        custMap.put('state' , (object)'CA');
        custMap.put('zipCode' , (object)'1234567');
        custMap.put('isSaveNewPaymentMethod',true);
        order ord = [Select id from order limit 1];
        webCart cart = [select id , DealerId__c from webCart limit 1];
        test.startTest();
        B2B_PayPalCheckoutController.accessToken = 'vhgkjvghhbvv-3vdscbdvacdbd';
        Test.setMock(HttpCalloutMock.class, new B2B_PayPalCheckoutMock());
        B2B_PayPalCheckoutController.processPayment(ord.Id, cart.Id, custMap, 'Nonce');
        test.stopTest();
    }
    
    @isTest
    public static void unitTest6(){
        order ord = [Select id from order limit 1];
        webCart cart = [select id , DealerId__c from webCart limit 1];
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId' , (object)'23456534567');
        custMap.put('address1' , (object)'test');
        custMap.put('address2' , (object)'test');
        custMap.put('city' , (object)'test');
        custMap.put('state' , (object)'CA');
        custMap.put('zipCode' , (object)'1234567');
        B2B_PayPalCheckoutHelper.linkCartToOrder(cart.Id, ord.Id, custMap);         
    }
    
    @isTest
    public static void unitTest7(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_PayPalCheckoutMock());
        B2B_PayPalCheckoutHelper.makePayment('dsfgdradf', 'testMerchantId', '4354645fdqdfberre', '200.00','Nonce');
        test.stopTest();
    }
    
    @isTest
    public static void unitTest8(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_PayPalCheckoutMock());
        B2B_PayPalCheckoutHelper.isDealerInstall = true;
        B2B_PayPalCheckoutHelper.makePayment('dsfgdradf', 'testPostAuthFailure', '4354645fdqdfberre', '200.00','Nonce');
        test.stopTest();
    }
    
    @isTest 
    public static void unitTest9() {
        WebCart c  = [Select Id FROM WebCart LIMIT 1];
        B2B_PayPalCheckoutController.getCartItemList2(c.Id);
    }
}
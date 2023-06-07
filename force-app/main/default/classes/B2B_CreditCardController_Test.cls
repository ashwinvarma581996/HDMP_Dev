/**********************************************************************
Name: 			B2B_CreditCardController_Test
Purpose: 		Test Class for B2B_CreditCardController.
Date : 			10/22/2021
Created By : 	
*******************************************************************************
MODIFICATIONS – Date 		|	Dev Name		|	Method		|	User Story
*******************************************************************************
	V1			08/06/2022	|	Ravi Prasad		|				|	
********************************************************************************/

@isTest
public class B2B_CreditCardController_Test {
    
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
        
        //Added by Palak to cover negetive scenario
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
    
    //Updated by Palak
    @isTest 
    public static void testHostedFormSetup(){
        webCart cr = [select id , DealerId__c from webCart limit 1];
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardControllerMock.createClientTokenResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;
        B2B_CreditCardController.hostedFormSetup(cr.Id);
        test.StopTest();
    }
    
    //Added by Palak
    @isTest 
    public static void testHostedFormSetupNegetive(){
        webCart cr = [select id , DealerId__c from webCart where Name = 'Test cart1' limit 1];
        test.startTest();
        B2B_CreditCardControllerMock.createClientTokenResponse = true;
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardController.hostedFormSetup(cr.Id);
        test.StopTest();
    }
    
    //Added by Palak
    @isTest 
    public static void testHostedFormSetupNegetive_Sr1(){
        webCart cr = [select id , DealerId__c from webCart limit 1];
        test.startTest();
        B2B_CreditCardControllerMock.createClientTokenResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = true;
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardController.hostedFormSetup(cr.Id);
        test.StopTest();
    }
    
    //Updated by Palak
    @istest
    public Static void testProcessPayment(){
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId' , (object)'23456534567');
        order ord = [Select id from order limit 1];
        webCart cr = [select id , DealerId__c from webCart limit 1];
        test.StartTest();
        B2B_CreditCardController.DATA_UPDATES = new Map<String, Object>();
        B2B_CreditCardControllerMock.createErrorResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());  
        B2B_CreditCardController.createCustomer(custMap);
        B2B_CreditCardController.processPayment('nounce' ,custMap , cr.Id , ord.Id, 'Credit Card');
        B2B_CreditCardController.processPayment('nounce' ,custMap , cr.Id , ord.Id, 'PayPal');
        test.stopTest();
    }
    
    //Added by Palak    
    @istest
    public Static void testProcessPaymentNoMerchantId(){ 
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId' , (object)'esrghxffxg');    
        order ord = [Select id from order limit 1];
        webCart cr = [select id , DealerId__c from webCart where Name = 'Test cart1' limit 1];   		
        test.StartTest();
        B2B_CreditCardController.DATA_UPDATES = new Map<String, Object>();
        B2B_CreditCardControllerMock.createErrorResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());  
        B2B_CreditCardController.createCustomer(custMap);
        B2B_CreditCardController.processPayment('nounce' ,custMap , cr.Id , ord.Id, 'Credit Card');
        B2B_CreditCardController.processPayment('nounce' ,custMap , cr.Id , ord.Id, 'PayPal');
        test.stopTest();
    }
    
    //Added by Palak
    @istest
    public Static void testProcessPaymentNegetive(){       
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        order ord = [Select id from order limit 1];
        webCart cr = [select id , DealerId__c from webCart limit 1];   		
        test.StartTest();
        B2B_CreditCardController.DATA_UPDATES = new Map<String, Object>();
        B2B_CreditCardControllerMock.createErrorResponse = true;
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock()); 
        B2B_CreditCardControllerMock.blankStatusCode = true;
        B2B_CreditCardController.createCustomer(custMap);
        B2B_CreditCardController.processPayment('nounce' ,custMap , cr.Id , ord.Id, 'Credit Card');
        B2B_CreditCardController.processPayment('nounce' ,custMap , cr.Id , ord.Id, 'PayPal');
        test.stopTest();
    }
    
    //Added by Palak
    @isTest
    public Static void testParseVaultPaymentResponse(){
        string jsonresponse = '{ "data" :  {"vaultPaymentMethod" :  {"paymentMethod": {"id":"test" , "verification" :  { "status" :"success" }, "details" : {"last4" : "1111", "brandCode" : "VISA", "cardholderName" : "Raj", "expirationMonth" : "12", "expirationYear" : "22", "uniqueNumberIdentifier" : "123456543"}  } }}}';
        B2B_CreditCardController.parseVaultPaymentResponse(jsonresponse);  
    }
    
    @isTest
    public static void testProcessPaymentForLoggedInUser(){
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');  
        order ord = [Select id from order limit 1];
        webCart cr = [select id , DealerId__c from webCart limit 1];
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardControllerMock.createCustomerResponse = true;
        B2B_CreditCardController.processPaymentForLoggedInUser(objPayment.Id , cr.Id , ord.Id, custMap); 
        string jsonresponse = '{ "data" :  {"vaultPaymentMethod" :  { "verification" :  { "status" :"Failed", "gatewayRejectionReason" : "AVS" } }}}';
        B2B_CreditCardController.parseVaultPaymentResponse(jsonresponse);
        string jsonresponse1 = '{"data" : {"vaultPaymentMethod" : {}}, "errors" : [{"message" : "Credit card type is not accepted"}]}';
        B2B_CreditCardController.parseVaultPaymentResponse(jsonresponse1);
        test.stopTest();
    }
    
    //Added by Palak
    @isTest
    public static void testProcessPaymentForLoggedInUser_NoPM(){
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        order ord = [Select id from order limit 1];
        webCart cr = [select id , DealerId__c from webCart limit 1];
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        objPayment.Id = 'a0201000002yXafAAE';
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardControllerMock.createCustomerResponse = true;
        B2B_CreditCardController.processPaymentForLoggedInUser(objPayment.Id , cr.Id , ord.Id, custMap); 
        string jsonresponse = '{ "data" :  {"vaultPaymentMethod" :  { "verification" :  { "status" :"Failed", "gatewayRejectionReason" : "AVS" } }}}';
        B2B_CreditCardController.parseVaultPaymentResponse(jsonresponse);
        string jsonresponse1 = '{"data" : {"vaultPaymentMethod" : {}}, "errors" : [{"message" : "Credit card type is not accepted"}]}';
        B2B_CreditCardController.parseVaultPaymentResponse(jsonresponse1);
        test.stopTest();
    }
    
    //Added by Palak
    @isTest
    public static void testProcessPaymentForLoggedInUserNegative(){
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        order ord = [Select id from order limit 1];
        webCart cr = [select id , DealerId__c from webCart limit 1];
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardControllerMock.createCustomerResponse = true;        
        B2B_CreditCardController.processPaymentForLoggedInUser(objPayment.Id , '' , ord.Id, custMap);   
        string jsonresponse = '{ "data" :  {"vaultPaymentMethod" :  { "verification" :  { "status" :"Failed", "gatewayRejectionReason" : "AVS" } }}}';
        B2B_CreditCardController.parseVaultPaymentResponse(jsonresponse);
        string jsonresponse1 = '{"data" : {"vaultPaymentMethod" : {}}, "errors" : [{"message" : "Credit card type is not accepted"}]}';
        B2B_CreditCardController.parseVaultPaymentResponse(jsonresponse1);
        test.stopTest();
    }    
    
    @istest
    public Static void testcreatePaymentId(){
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        BT_Customer_Details__c objCustomer = [SELECT Id, BT_CustomerId__c FROM BT_Customer_Details__c];
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId', (object)'23456534567');
        custMap.put('address1' , (object)'test');
        custMap.put('address2' , (object)'test');
        custMap.put('city' , (object)'test');
        custMap.put('state' , (object)'CA');
        custMap.put('zipCode' , (object)'1234567');
        custMap.put('isSaveNewPaymentMethod' , (object)true);
        custMap.put('isMakePreferred' , (object)true);
        
        Map<String,object > dataUpdate  = new Map<String,object > ();
        dataUpdate.put('customerData', (object)custMap);
        dataUpdate.put('brandCode', (object)'MASTERCARD');
        dataUpdate.put('expirationMonth', (object)'12');
        dataUpdate.put('expirationYear', (object)'22');
        dataUpdate.put('paymentType', (object)'CreditCard');
        
        User objUser = B2B_TestDataFactory.createUser(true);
        
        System.runAs(objUser) {
            B2B_CreditCardController.createPaymentDetailsRecord(dataUpdate);
            B2B_CreditCardController.createTransactionDetailsRecord(dataUpdate); 
        }
    }
    
    @istest
    public Static void testcreatePaymentIdPmType(){
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        BT_Customer_Details__c objCustomer = [SELECT Id, BT_CustomerId__c FROM BT_Customer_Details__c];
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId', (object)'23456534567');
        custMap.put('address1' , (object)'test');
        custMap.put('address2' , (object)'test');
        custMap.put('city' , (object)'test');
        custMap.put('state' , (object)'CA');
        custMap.put('zipCode' , (object)'1234567');
        custMap.put('isSaveNewPaymentMethod' , (object)true);
        custMap.put('isMakePreferred' , (object)true);
        
        Map<String,object > dataUpdate  = new Map<String,object > ();
        dataUpdate.put('customerData', (object)custMap);
        dataUpdate.put('brandCode', (object)'MASTERCARD');
        dataUpdate.put('expirationMonth', (object)'12');
        dataUpdate.put('expirationYear', (object)'22');
        dataUpdate.put('paymentType', (object)'PayPal');
        User objUser = B2B_TestDataFactory.createUser(true);
        
        System.runAs(objUser) {
            B2B_CreditCardController.createPaymentDetailsRecord(dataUpdate);
            B2B_CreditCardController.createTransactionDetailsRecord(dataUpdate); 
        }
    }
    
    @istest
    public Static void testcreatePaymentId2(){
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        BT_Customer_Details__c objCustomer = [SELECT Id, BT_CustomerId__c FROM BT_Customer_Details__c];
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId', (object)'23456534567');
        custMap.put('address1' , (object)'test');
        custMap.put('address2' , (object)'test');
        custMap.put('city' , (object)'test');
        custMap.put('state' , (object)'CA');
        custMap.put('zipCode' , (object)'1234567');
        custMap.put('isSaveNewPaymentMethod' , (object)true);
        custMap.put('isMakePreferred' , (object)true);
        
        Map<String,object > dataUpdate  = new Map<String,object > ();
        dataUpdate.put('customerData', (object)custMap);
        dataUpdate.put('brandCode', (object)'VISA');
        dataUpdate.put('expirationMonth', (object)'12');
        dataUpdate.put('expirationYear', (object)'22');
        dataUpdate.put('paymentType', (object)'CreditCard');
        
        User objUser = B2B_TestDataFactory.createUser(true);
        
        System.runAs(objUser) {
            B2B_CreditCardController.createPaymentDetailsRecord(dataUpdate);
            B2B_CreditCardController.createTransactionDetailsRecord(dataUpdate); 
        }
    }
    
    @istest
    public Static void testcreatePaymentId3(){
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        BT_Customer_Details__c objCustomer = [SELECT Id, BT_CustomerId__c FROM BT_Customer_Details__c];
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId', (object)'23456534567');
        custMap.put('address1' , (object)'test');
        custMap.put('address2' , (object)'test');
        custMap.put('city' , (object)'test');
        custMap.put('state' , (object)'CA');
        custMap.put('zipCode' , (object)'1234567');
        custMap.put('isSaveNewPaymentMethod' , (object)true);
        custMap.put('isMakePreferred' , (object)true);
        
        Map<String,object > dataUpdate  = new Map<String,object > ();
        dataUpdate.put('customerData', (object)custMap);
        dataUpdate.put('brandCode', (object)'DISCOVER');
        dataUpdate.put('expirationMonth', (object)'12');
        dataUpdate.put('expirationYear', (object)'22');
        dataUpdate.put('paymentType', (object)'CreditCard');
        
        User objUser = B2B_TestDataFactory.createUser(true);
        
        System.runAs(objUser) {
            B2B_CreditCardController.createPaymentDetailsRecord(dataUpdate);
            B2B_CreditCardController.createTransactionDetailsRecord(dataUpdate); 
        }
    }
    
    @istest
    public Static void testcreatePaymentId4(){
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        BT_Customer_Details__c objCustomer = [SELECT Id, BT_CustomerId__c FROM BT_Customer_Details__c];
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId', (object)'23456534567');
        custMap.put('address1' , (object)'test');
        custMap.put('address2' , (object)'test');
        custMap.put('city' , (object)'test');
        custMap.put('state' , (object)'CA');
        custMap.put('zipCode' , (object)'1234567');
        custMap.put('isSaveNewPaymentMethod' , (object)true);
        custMap.put('isMakePreferred' , (object)true);
        
        Map<String,object > dataUpdate  = new Map<String,object > ();
        dataUpdate.put('customerData', (object)custMap);
        dataUpdate.put('brandCode', (object)'AMERICAN_EXPRESS');
        dataUpdate.put('expirationMonth', (object)'12');
        dataUpdate.put('expirationYear', (object)'22');
        dataUpdate.put('paymentType', (object)'CreditCard');
        
        User objUser = B2B_TestDataFactory.createUser(true);
        
        System.runAs(objUser) {
            B2B_CreditCardController.createPaymentDetailsRecord(dataUpdate);
            B2B_CreditCardController.createTransactionDetailsRecord(dataUpdate); 
        }
    }
    
    @istest
    public Static void testSubmitAuthorizationRequest(){
        map<string, object > testMap = new Map<String, object>();
        webCart cr = [select id , DealerId__c from webCart limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        B2B_CreditCardController.setMerchantAndDealerID(cr.Id);
        B2B_CreditCardController.DATA_UPDATES = new Map<String , object>();
        B2B_CreditCardController.submitAuthorizationRequest('test' , 'test', 'test',testMap);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testUpdateTransactionStatusOnOrder(){
        Map<String,object > m  = new Map<String,object > ();
        map<string, string> innerMap = new Map<String, String>();
        innerMap.put('email' , 'test@test.com');
        innerMap.put('address1' , 'testaddress');
        innerMap.put('address2' , 'testaddress2');
        innerMap.put('name' , 'test');
        innerMap.put('city' , 'Test');
        innerMap.put('state' , 'NA');
        innerMap.put('zipCode' , '123456');
        innerMap.put('country' , 'India');
        m.put('brandCode' , 'VISA');
        m.put('type' , 'Credit Card - Visa');
        m.put('customerData' , (object) innerMap);
        
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardController.ORDER_ID =  [Select id from order limit 1].Id;
        B2B_CreditCardController.updateTransactionStatusOnOrder('Authorized', m);
        B2B_CreditCardController.handleBraintreeError('error' , m);
        test.stopTest();
        
    }
    
    //Added by Palak
    @isTest
    public static void testUpdateTransactionStatusOnOrder_Sr1(){
        Map<String,object > m  = new Map<String,object > ();
        map<string, string> innerMap = new Map<String, String>();
        innerMap.put('email' , 'test@test.com');
        innerMap.put('address1' , 'testAddress');
        innerMap.put('city' , 'Test');
        innerMap.put('state' , 'NA');
        innerMap.put('zipCode' , '123456');
        innerMap.put('country' , 'India');
        m.put('brandCode' , 'DISCOVER');
        m.put('type' , 'Credit Card - DISCOVER');
        m.put('shippingAddress' , (object) innerMap);
        
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardController.ORDER_ID =  [Select id from order limit 1].Id;
        B2B_CreditCardController.updateTransactionStatusOnOrder('Authorized', m);
        B2B_CreditCardController.handleBraintreeError('error' , m);
        test.stopTest();  
    }
    
    @isTest
    public static void testUpdateTransactionStatusOnOrder_Sr2(){
        Map<String,object > m  = new Map<String,object > ();
        map<string, string> innerMap = new Map<String, String>();
        innerMap.put('email' , 'test@test.com');
        innerMap.put('address1' , 'testAddress');
        innerMap.put('city' , 'Test');
        innerMap.put('state' , 'NA');
        innerMap.put('zipCode' , '123456');
        innerMap.put('country' , 'India');
        m.put('brandCode' , 'AMERICAN_EXPRESS');
        m.put('type' , 'Credit Card - Amex');
        m.put('shippingAddress' , (object) innerMap);
        
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardController.ORDER_ID =  [Select id from order limit 1].Id;
        B2B_CreditCardController.updateTransactionStatusOnOrder('Authorized', m);
        B2B_CreditCardController.handleBraintreeError('error' , m);
        test.stopTest();    
    }
    
    
    @isTest
    public static void testUpdateTransactionStatusOnOrder_Sr3(){
        Map<String,object > m  = new Map<String,object > ();
        map<string, string> innerMap = new Map<String, String>();
        innerMap.put('email' , 'test@test.com');
        innerMap.put('address1' , 'testAddress');
        innerMap.put('city' , 'Test');
        innerMap.put('state' , 'NA');
        innerMap.put('zipCode' , '123456');
        innerMap.put('country' , 'India');
        m.put('brandCode' , 'MASTERCARD');
        m.put('type' , 'Credit Card - Mastercard');
        m.put('shippingAddress' , (object) innerMap);
        
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardController.ORDER_ID =  [Select id from order limit 1].Id;
        B2B_CreditCardController.updateTransactionStatusOnOrder('Authorized', m);
        B2B_CreditCardController.handleBraintreeError('error' , m);
        test.stopTest();  
    }
    
    
    @isTest
    public static void testUpdateTokenInformation(){
        Map<String,object > m  = new Map<String,object > ();
        BT_Token_Details__c bt = [select id from BT_Token_Details__c limit 1];
        m.put('id' , (object)bt.Id);
        m.put('accessToken' , (object)'test');
        m.put('refreshToken' , (object)'test');
        m.put('accessExpiration' ,(object) 'today');
        m.put('refreshExpiration' , (object)'today');
        B2B_CreditCardController.UpdateTokenInformation( m);
        
    }
    
    //Added by Palak 
    @isTest
    public static void testCreateAddressRecord(){
        Map<String,object > m  = new Map<String,object > ();
        My_Address_Book__c address=B2B_TestDataFactory.createAddressBook1(true);
        m.put('id' , address.Id);
        m.put('email' , 'test@test.com');
        m.put('address1' , 'test');
        m.put('address2' , 'test');
        m.put('address' , 'test');
        m.put('state' , 'test');
        m.put('zipCode' , '2345671');
        m.put('phone' , '1234567890');
        m.put('name' , 'test');
        m.put('city' , 'test');
        B2B_CreditCardController.createAddressRecord(m);
    }
    
    @isTest
    public static void testVaultPaymentMethod(){
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardController.vaultPaymentMethod('nounce','werthjk56712w');
        B2B_CreditCardControllerMock.createClientTokenResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;
        test.stopTest();
    }
    
    @isTest
    public static void testVaultPaymentMethodNegative(){
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardController.vaultPaymentMethod('nounce','werthjk56712w');
        B2B_CreditCardControllerMock.createClientTokenResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = true;
        test.stopTest();
    }
    
    @isTest
    public static void testCreateOrderTransactionRecord(){
        Account acc = B2B_TestDataFactory.createAccount(true);
        WebStore store = B2B_TestDataFactory.createStore(true);
        WebCart cart = B2B_TestDataFactory.createCart(true, acc.Id, store.Id);
        Order ord = B2B_TestDataFactory.createOrder(true, acc.Id, cart.Id);
        Order ordr = [Select id from order where id =: ord.Id];
        ordr.Updated_Order_Total__c = 200;ordr.Updated_Total_Tax__c = 20;
        Product2 testProduct = B2B_TestDataFactory.createProduct(true);
        OrderItem testOrdItem = B2B_TestDataFactory.createOrderItem(true,ordr.Id,testProduct.Id);
        BT_Transaction_Details__c testBTTranDtl = B2B_TestDataFactory.createBTTransactionDetails(true, ordr.Id);
        B2B_CreditCardController.ORDER_ID = ordr.Id;        
    }
    
    @isTest
    public static void testCreateInvoiceRecordsException(){
        test.startTest();
        Account acc = B2B_TestDataFactory.createAccount(true);
        WebStore store = B2B_TestDataFactory.createStore(true);
        WebCart cart = B2B_TestDataFactory.createCart(true, acc.Id, store.Id);
        Order ord = B2B_TestDataFactory.createOrder(true, acc.Id, cart.Id);
        Order ordr = [Select id from order where id =: ord.Id];
        B2B_CreditCardController.ORDER_ID = ordr.Id+'gfgreg';
        Invoice__c inv=B2B_TestDataFactory.createInvoice(true);
        B2B_CreditCardController.createInvoiceRecords();
        test.StopTest();
    }
    
    @isTest
    public static void testCreateInvoiceRecords(){
        test.startTest();
        Account acc = B2B_TestDataFactory.createAccount(true);
        WebStore store = B2B_TestDataFactory.createStore(true);
        WebCart cart = B2B_TestDataFactory.createCart(true, acc.Id, store.Id);
        Order ord = B2B_TestDataFactory.createOrder(true, acc.Id, cart.Id);
        Order ordr = [Select id from order where id =: ord.Id];
        ordr.Updated_Order_Total__c = 200;ordr.Updated_Total_Tax__c = 20;
        Product2 testProduct = B2B_TestDataFactory.createProduct(true);
        OrderItem testOrdItem = B2B_TestDataFactory.createOrderItem(true,ordr.Id,testProduct.Id);
        BT_Transaction_Details__c testBTTranDtl = B2B_TestDataFactory.createBTTransactionDetails(true, ordr.Id);
        B2B_CreditCardController.ORDER_ID = ordr.Id;
        Invoice__c inv=B2B_TestDataFactory.createInvoice(true);
        update ordr;
        B2B_CreditCardController.createInvoiceRecords();
        delete testBTTranDtl;
        test.StopTest();
    }
    
    @isTest
    public static void testCreateCustomerDetailsRecord(){
        Map<String, Object> dataUpdate = new Map<String, Object>();
        dataUpdate.put('legacyId', (Object)'456787543');
        dataUpdate.put('customerId', (Object)'efgh54w56rtsdadsf');
        B2B_CreditCardController.createCustomerDetailsRecord(dataUpdate);  
    }   
    
}
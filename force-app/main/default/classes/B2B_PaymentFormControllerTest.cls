/******************************************************************************
Name: 		B2B_PaymentFormControllerTest
Purpose: 	Test Class for PaymentFormController.
Date : 		24/05/2022
Created By:	Raktim Bhowmick
*******************************************************************************
MODIFICATIONS – Date 		|	Dev Name		|	Method		|	User Story
*******************************************************************************
	V1			08/06/2022	|	Raktim Bhowmick	|				|	
*******************************************************************************/

@isTest
public class B2B_PaymentFormControllerTest {
    @testSetup
    public static void dataSetup(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        objAccount.Merchant_Id__c='x6q6b83wjsn28t2m';
        objAccount.PoIId__c = '251084';
        update objAccount;
        
        BT_Customer_Details__c objCustomer = new BT_Customer_Details__c();
        objCustomer.BT_CustomerId__c = '23456534567';
        objCustomer.Name = 'Raj';
        insert objCustomer;
        
        BT_Payment_Method__c objPayment = new BT_Payment_Method__c();
        objPayment.Payment_Method_Token__c = '34567tfdsdf';
        objPayment.BT_Customer_Details__c = objCustomer.Id;
        objPayment.Credit_Card_Number__c = '1111';
        insert objPayment;
    }
    
	@isTest
    public static void testHostedFormSetup(){
        Account objAccount = [SELECT Id,Merchant_Id__c FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        Test.startTest();
        Map<String, Object> mapReturnData = B2B_PaymentFormController.hostedFormSetup(objOrder.Id);     
        Test.stopTest();
    }
    
    @isTest
    public static void testHostedFormSetupfalse(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        BT_Customer_Details__c objBTCustomerDetails = B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id); 
        objBTCustomerDetails.Name = 'Guest'; 
        update objBTCustomerDetails; 
        
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = false;
        update objOrder;
        WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, objAccount.Id, testStore.Id);
        Test.startTest();
        B2B_CreditCardControllerMock.createClientTokenResponse = true;
        Map<String, Object> mapReturnData = B2B_PaymentFormController.hostedFormSetup(objOrder.Id);
        Map<String, Object> mapReturnData1 = B2B_PaymentFormController.hostedFormSetup('abcd');
        map<String, object> custMap = createCustomerDataMap();
        B2B_CreditCardControllerMock.createCustomerResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        
        B2B_PaymentFormController.processPayment('Test1', custMap,testcart.id,objOrder.id, 'CreditCard');
        Test.stopTest();
    }
    
    @isTest
    public static void hostedFormSetupForGuestUserTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'stguest', Email='standarduserguest@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Guest', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserguest@testorg.com');
        insert u;
        
        System.runAs(u) {
            Account objAccount = [SELECT Id FROM Account LIMIT 1];
            Order objOrder = createTestData(objAccount);               
            B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
            BT_Customer_Details__c objBTCustomerDetails = B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
            
            objOrder.Status = 'Payment Issue';
            objOrder.IsPaymentReproccessing__c = false;
            update objOrder;
            WebStore testStore = B2B_TestDataFactory.createStore(true);
            WebCart testcart = B2B_TestDataFactory.createCart(true, objAccount.Id, testStore.Id);
            Test.startTest();
            B2B_CreditCardControllerMock.createClientTokenResponse = true;
            Map<String, Object> mapReturnData = B2B_PaymentFormController.hostedFormSetup(objOrder.Id); 
            Test.stopTest();
        }  
    }
            
    @isTest
    public static void testprocessPayment(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        update updatetestcart;
	
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        map<String, object> custMap = createCustomerDataMap();        
        Test.startTest();
        
        B2B_CreditCardControllerMock.createCustomerResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'CreditCard');       
        Test.stopTest();
    }
    
    @isTest
    public static void testprocessPaymentNegative(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);       
        
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        update updatetestcart;
	
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        map<String, object> custMap = createCustomerDataMap();        
        Test.startTest();
        
        B2B_CreditCardControllerMock.createErrorResponse = true;
		B2B_CreditCardControllerMock.createCustomerResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;        
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'Credit Card');       
        Test.stopTest();
    }
    
    @isTest
    public static void testprocessPaymentNegative1(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);       
        
        BT_Customer_Details__c objCustomer = new BT_Customer_Details__c();
        objCustomer.BT_CustomerId__c = '23456534567';
        objCustomer.Name = 'Raj';
        insert objCustomer;
        
        BT_Payment_Method__c objPayment = new BT_Payment_Method__c();
        objPayment.Payment_Method_Token__c = '34567tfdsdf';
        objPayment.BT_Customer_Details__c = objCustomer.Id;
        objPayment.Credit_Card_Number__c = '1111';
        objPayment.Unique_Number_Identifier__c = 'dfgasdgf2345fd';
        insert objPayment;
        
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        update updatetestcart;
	
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        map<String, object> custMap = createCustomerDataMap();        
        Test.startTest();
        
        B2B_CreditCardControllerMock.createErrorResponse = true;
		B2B_CreditCardControllerMock.createCustomerResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;        
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'Credit Card');       
        Test.stopTest();
    }
    
    public static map<String, object> createCustomerDataMap(){
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
        return custMap;
    }
    
    @isTest
    public static void submitAuthorizationRequestTest(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String,Object>();
		map<String, object> custMap = createCustomerDataMap();  
        Test.startTest();
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
  		B2B_PaymentFormController.submitAuthorizationRequest('23456534567','123','25697',objRec);   
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'CreditCard'); 
        B2B_PaymentFormController.deletePaymentMethod('23456534567', '25469');
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('type','Credit Card - Mastercard');
        B2B_PaymentFormController.DATA_UPDATES.put('brandCode','MASTERCARD');
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.updateOrder('Settling','123456');
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec);
        Test.stopTest();
    }

    @isTest
    public static void testSubmitAuthorizationRequest(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Order objOrder = createTestData(objAccount);  
        BT_Token_Details__c bttoken = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        bttoken.AccessTokenExpiresAt__c = System.now().addMinutes(30);
        insert bttoken;
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        Map<String, Object> objRec = new Map<String, Object>();
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_PaymentFormController.submitAuthorizationRequest('bbncbncnb','123','34567',objRec);
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec);
        Test.stopTest();
    }
    
    @isTest
    public static void setDealerAuthorizationHeaderNegativeTest(){
        Test.startTest();
        B2B_PaymentFormController.setDealerAuthorizationHeader();
        Test.stopTest();
    }    
    
    @isTest
    public static void requestPostAuthTest(){
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DATA_UPDATES.put('isNewPayment', true);
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String, Object>();

        Test.startTest();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        B2B_PaymentFormController.MERCHANT_ID = 'x6q6b83wjsn28t2m';
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec); 
        Test.stopTest();
    }
    
    public static Order createTestData(Account objAccount){     
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock()); 
        
        User objUser=[select id from user Limit 1];
        WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, objAccount.Id, testStore.Id);
        
        CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, testcart.Id);
        Product2 prod = B2B_TestDataFactory.createProduct(true);
        Product2 objProduct = [Select Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c From Product2 Where Id =: prod.Id];
        CartItem objCartItem = B2B_TestDataFactory.createCartItem(true, testcart.Id, testdelivery.Id, objProduct.Id);   
        B2B_Custom_Settings__c objCustomSetting = B2B_TestDataFactory.createCustomSetting(true,objAccount.Id, objUser.Id);
        Order objOrder = B2B_TestDataFactory.createOrder(true, objAccount.Id, testcart.Id); 
        B2B_TestDataFactory.createOrderItem(true, objOrder.Id, objProduct.Id); 
        return objOrder;
    }
    
    @isTest
    public static void testProcessPaymentByMyPayment(){   
        
        B2B_Custom_Settings__c customSettingObj = new B2B_Custom_Settings__c();
        customSettingObj.name = 'Honda';
        customSettingObj.Default_Guest_Account__c = '0010100000NN7HSAA1';
        insert customSettingObj;
        
        BT_Customer_Details__c objCustomer = new BT_Customer_Details__c();
        
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        objOrder.Updated_Order_Total__c = 120.00;
        update objOrder;
        webcart testcart=[select id,Pickup_Dealer__c from webcart Limit 1];
        
        WebCart updatetestcart=[select id,Pickup_Dealer__c from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = false;
        update updatetestcart;
        
        map<String, object> custMap = createCustomerDataMap();        
        
        Test.startTest();
        B2B_CreditCardControllerMock.createCustomerResponse = true;      
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.retryFailedPayment(objOrder.id, testcart.id);
        B2B_PaymentFormController.processPaymentByMyPayment('', updatetestcart.id, objOrder.id, custMap);        
        Test.stopTest();    
    }
    
    @isTest
    public static void testRetryNegative(){
        BT_Customer_Details__c objCustomer = new BT_Customer_Details__c();
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        Account objAccount = [SELECT Id,Merchant_Id__c FROM Account LIMIT 1];
        objAccount.Merchant_Id__c = null;
        update objAccount;
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        objOrder.Updated_Order_Total__c = 120.00;
        update objOrder;
         
        webcart testcart=[select id,Pickup_Dealer__c from webcart Limit 1];
     
        Test.startTest();
        B2B_CreditCardControllerMock.createCustomerResponse = true;
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.retryFailedPayment(objOrder.id, testcart.id);
        
        try{
            B2B_PaymentFormController.retryFailedPayment(objOrder.id, '');
            B2B_PaymentFormController.retryFailedPayment('234567875432345', testcart.id);           
        }catch(exception ex){
            
        }
        Test.stopTest();
    }
    
    @isTest
    public static void requestPostAuthTest1(){
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DATA_UPDATES.put('isNewPayment', true);
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String, Object>();

        Test.startTest();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock1());
        B2B_PaymentFormController.MERCHANT_ID = 'x6q6b83wjsn28t2m';
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','yyyyy#',objRec); 
       Test.stopTest();
    }
    
    @isTest
    public static void testdeletePayment(){   
        BT_Customer_Details__c objCustomer = new BT_Customer_Details__c();
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        objOrder.Updated_Order_Total__c = 120.00;
        update objOrder;
        webcart testcart=[select id,Pickup_Dealer__c from webcart Limit 1];
        
        WebCart updatetestcart=[select id,Pickup_Dealer__c from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = false;
        update updatetestcart;
        
        map<String, object> custMap = createCustomerDataMap();        
        Test.startTest();
        
        B2B_CreditCardControllerMock.createCustomerResponse = true;      
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.deletePaymentMethod('23456534567', '25469');
        Test.stopTest(); 
    }
    
    @isTest 
    public static void  testretryFailedPayment() {
        Account objAccount = [SELECT Id,Merchant_Id__c FROM Account LIMIT 1];
        
        Order objOrder = createTestData(objAccount); 
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        BT_Customer_Details__c objCustomer =[SELECT id From BT_Customer_Details__c LIMIT 1];
        
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c LIMIT 1];       
       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        objOrder.BT_Customer_Detail__c = objCustomer.Id;
        objOrder.Payment_Method_Token__c = objPayment.Id;
        objOrder.Updated_Order_Total__c = 120.00;
        update objOrder;   
        
        webcart testcart=[select id,Pickup_Dealer__c from webcart Limit 1];
             
        Test.startTest();
        B2B_CreditCardControllerMock.createCustomerResponse = true;
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.retryFailedPayment(objOrder.id, testcart.id);  
        Test.stopTest();
    }      
    
    @isTest
    public static void testsetDealerAuthorizationHeaderN(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        BT_Token_Details__c bttoken = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        bttoken.AccessTokenExpiresAt__c = System.now().addMinutes(30);
        insert bttoken;
        B2B_PaymentFormController.AUTHORIZATION_HEADER= ' ';
        Map<String, Object> objRec = new Map<String, Object>();
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        
        Test.startTest();
        B2B_PaymentFormController.setDealerAuthorizationHeader();
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateOrderVisa(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String,Object>();
		map<String, object> custMap = createCustomerDataMap();  
        Test.startTest();
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'CreditCard'); 
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('type','Credit Card - Visa');
        B2B_PaymentFormController.DATA_UPDATES.put('brandCode','VISA');
        
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.updateOrder('Settling','123456');
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateOrderDiscover(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String,Object>();
        map<String, object> custMap = createCustomerDataMap();  
        Test.startTest();
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'CreditCard'); 
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('type','Credit Card - Discover');
        B2B_PaymentFormController.DATA_UPDATES.put('brandCode','DISCOVER');
        
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.updateOrder('Settling','123456');
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateOrderAmex(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String,Object>();
        map<String, object> custMap = createCustomerDataMap();  
        Test.startTest();
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
                    
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'CreditCard'); 
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('type','Credit Card - Amex');
        B2B_PaymentFormController.DATA_UPDATES.put('brandCode','AMERICAN_EXPRESS');
        
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.updateOrder('Settling','123456');
        Test.stopTest();
    }

    @isTest
    public static void testUpdateOrderPaypal(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String,Object>();
        map<String, object> custMap = createCustomerDataMap();  
        Test.startTest();
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'CreditCard'); 
        B2B_PaymentFormController.DATA_UPDATES.put('paymentType', 'PayPal');
        
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.updateOrder('Settling','123456');
        Test.stopTest();
    }
    
    @isTest
    public static void requestPostAuthTestVisa(){
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DATA_UPDATES.put('isNewPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', True);
        B2B_PaymentFormController.DATA_UPDATES.put('type','Visa');
        B2B_PaymentFormController.DATA_UPDATES.put('brandCode','VISA');
        Account objAccount = [SELECT Id,name FROM Account LIMIT 1];
        objAccount.name='Honda';
        update objAccount;
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String, Object>();

        Test.startTest();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        B2B_PaymentFormController.MERCHANT_ID = 'x6q6b83wjsn28t2m';
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec); 
        Test.stopTest();
    }
    
    @isTest
    public static void requestPostAuthTestDiscover(){
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DATA_UPDATES.put('isNewPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', True);
        B2B_PaymentFormController.DATA_UPDATES.put('type','Discover');
        B2B_PaymentFormController.DATA_UPDATES.put('brandCode','DISCOVER');
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String, Object>();

        Test.startTest();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        B2B_PaymentFormController.MERCHANT_ID = 'x6q6b83wjsn28t2m';
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec); 
        Test.stopTest();
    }
 
    @isTest
    public static void requestPostAuthTestAmex(){
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DATA_UPDATES.put('isNewPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', True);
        B2B_PaymentFormController.DATA_UPDATES.put('type','Amex');
        B2B_PaymentFormController.DATA_UPDATES.put('brandCode','AMERICAN_EXPRESS');
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String, Object>();

        Test.startTest();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        B2B_PaymentFormController.MERCHANT_ID = 'x6q6b83wjsn28t2m';
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec); 
        Test.stopTest();
    }
    
    @isTest
    public static void requestPostAuthTestMastercard(){
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DATA_UPDATES.put('isNewPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', True);
        B2B_PaymentFormController.DATA_UPDATES.put('type','Mastercard');
        B2B_PaymentFormController.DATA_UPDATES.put('brandCode','MASTERCARD');
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String, Object>();
        
        Test.startTest();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        B2B_PaymentFormController.MERCHANT_ID = 'x6q6b83wjsn28t2m';
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec); 
        Test.stopTest();
    }
    
    @isTest
    public static void requestPostAuthTestCardHolderName(){
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DATA_UPDATES.put('isNewPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', True);
        B2B_PaymentFormController.DATA_UPDATES.put('cardholderName','cardholderName');
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String, Object>();

        Test.startTest();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        B2B_PaymentFormController.MERCHANT_ID = 'x6q6b83wjsn28t2m';
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec); 
        Test.stopTest();
    }
    
    @isTest
    public static void requestPostAuthTestcustomerData(){
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
       
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String, Object>();
        B2B_PaymentFormController.DATA_UPDATES.put('isNewPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', True);
        map<String, object> customerData = new map<String, object>();
        customerData.put('address1' , objOrder.BillingStreet);
        customerData.put('city' , objOrder.BillingCity);
        customerData.put('state' , objOrder.BillingState);
        customerData.put('zipCode' , objOrder.BillingPostalCode);
        
        B2B_PaymentFormController.DATA_UPDATES.put('customerData','customerData');

        Test.startTest();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        B2B_PaymentFormController.MERCHANT_ID = 'x6q6b83wjsn28t2m';
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec); 
        Test.stopTest();
    }
 
    @isTest
    public static void testSubmitAuthorizationRequestcatch(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        Map<String, Object> objRec = new Map<String, Object>();
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_PaymentFormController.submitAuthorizationRequest('bbncbncnb','123','34567',objRec);
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec);
        Test.stopTest();
    }
    
    @isTest
    public static void testHostedFormSetup1(){
        Account objAccount = [SELECT Id,Merchant_Id__c FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        BT_Customer_Details__c objBTCustomerDetails = B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        objOrder.BT_Customer_Detail__c = objBTCustomerDetails.Id;
        update objOrder;
        Test.startTest();
        Map<String, Object> mapReturnData = B2B_PaymentFormController.hostedFormSetup(objOrder.Id);       
        Test.stopTest();
    }
    
    @isTest
    public static void testHostedFormSetup2(){
        Account objAccount = [SELECT Id,Merchant_Id__c FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        BT_Customer_Details__c objBTCustomerDetails = B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = false;
        objOrder.BT_Customer_Detail__c = objBTCustomerDetails.Id;
        update objOrder;
        Test.startTest();
        Map<String, Object> mapReturnData = B2B_PaymentFormController.hostedFormSetup('12345');       
        Test.stopTest();
    }
    
    @isTest
    public static void testHostedFormCartidBlank(){
        Account objAccount = [SELECT Id,Merchant_Id__c FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        BT_Customer_Details__c objBTCustomerDetails = B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        objOrder.BT_Customer_Detail__c = objBTCustomerDetails.Id;
        update objOrder;
        Test.startTest();
        Map<String, Object> mapReturnData = B2B_PaymentFormController.hostedFormSetup('');       
        Test.stopTest();
    }
    
    @isTest
    public static void testprocessPaymentCartidBlank(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        update updatetestcart;
	
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        map<String, object> custMap = createCustomerDataMap();        
        Test.startTest();
        
        B2B_CreditCardControllerMock.createCustomerResponse = true;
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,' ',objOrder.id, 'CreditCard');       
        Test.stopTest();
    }
    
    @isTest
    public static void testprocessPaymentMerchantidBlank(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        update updatetestcart;
	
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        map<String, object> custMap = createCustomerDataMap();
        B2B_PaymentFormController.MERCHANT_ID = '';
        Test.startTest();
        
        B2B_CreditCardControllerMock.createErrorResponse = true;        
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        try{
             B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,'12345',objOrder.id, 'Credit Card');
        } catch( exception e){}
        Test.stopTest();
    } 
    
    @isTest
    public static void submitAuthorizationRequestTest1(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String,Object>();
		map<String, object> custMap = createCustomerDataMap();  
        Test.startTest();
       
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
  		B2B_PaymentFormController.submitAuthorizationRequest('abol1234','123','25697',objRec);
        Test.stopTest();
    }

    @isTest
    public static void requestPostAuthTest5(){
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DATA_UPDATES.put('isRetryPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('paymentToken', 'paymentTokenId');
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String, Object>();
        
        Test.startTest();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        B2B_PaymentFormController.MERCHANT_ID = 'x6q6b83wjsn28t2m';
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec); 
        Test.stopTest();
    }
    
    @isTest
    public static void requestPostAuthTestcustomerData1(){
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        Map<String, Object> customerData = new Map<String,Object>();
       
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = true;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String, Object>();
        B2B_PaymentFormController.DATA_UPDATES.put('isNewPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', True);
        B2B_PaymentFormController.DATA_UPDATES.put('customerData', 'customerData');
        B2B_PaymentFormController.DATA_UPDATES.put('address1', 'address1');

        Test.startTest();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        B2B_PaymentFormController.MERCHANT_ID = 'x6q6b83wjsn28t2m';
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec); 
        Test.stopTest();
    } 
    
    @isTest
    public static void submitAuthorizationRequestTestdealerfalse(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = false;
        update updatetestcart;
        Map<String, Object> objRec = new Map<String,Object>();
		map<String, object> custMap = createCustomerDataMap();  
        Test.startTest();
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        B2B_PaymentFormController.DEALER_ID  = String.valueOf(objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
  		B2B_PaymentFormController.submitAuthorizationRequest('23456534567','123','25697',objRec);   //String customerId, String paymentToken,String paypalNonce, Map<String, Object> returnData              
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'CreditCard'); 
        B2B_PaymentFormController.deletePaymentMethod('23456534567', '25469');
        B2B_PaymentFormController.DATA_UPDATES.put('isMyPayment', true);
        B2B_PaymentFormController.DATA_UPDATES.put('type','Credit Card - Mastercard');
        B2B_PaymentFormController.DATA_UPDATES.put('brandCode','MASTERCARD');
        
        B2B_PaymentFormController.CART_ID = String.valueOf(updatetestcart.Id);
        B2B_PaymentFormController.ORDER_ID = String.valueOf(objOrder.Id);
        B2B_PaymentFormController.updateOrder('Settling','123456');
        B2B_PaymentFormController.requestPostAuth('ky5hkfng','John Smith',objRec);
        Test.stopTest();
    }
    
    @isTest
    public static void testProcessPaymentByMyPaymentnegative(){   
        B2B_Custom_Settings__c customSettingObj = new B2B_Custom_Settings__c();
        customSettingObj.name = 'Honda';
        customSettingObj.Default_Guest_Account__c = '0010100000NN7HSAA1';
        insert customSettingObj;
        
        BT_Customer_Details__c objCustomer = new BT_Customer_Details__c();
        
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        objOrder.Updated_Order_Total__c = 120.00;
        update objOrder;
        webcart testcart=[select id,Pickup_Dealer__c from webcart Limit 1];
        
        WebCart updatetestcart=[select id,Pickup_Dealer__c from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = false;
        update updatetestcart;
        
        map<String, object> custMap = createCustomerDataMap();        
        Test.startTest();
        
        B2B_CreditCardControllerMock.createCustomerResponse = true;      
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.retryFailedPayment(objOrder.id, testcart.id);
        B2B_PaymentFormController.processPaymentByMyPayment(objPayment.Id, updatetestcart.id, objOrder.id, custMap);        
        Test.stopTest();    
    }
    
    @isTest
    public static void testProcessPaymentByMyPaymentnegative1(){   
        B2B_Custom_Settings__c customSettingObj = new B2B_Custom_Settings__c();
        customSettingObj.name = 'Honda';
        customSettingObj.Default_Guest_Account__c = '0010100000NN7HSAA1';
        insert customSettingObj;
        
        BT_Customer_Details__c objCustomer = new BT_Customer_Details__c();
        
        BT_Payment_Method__c objPayment = [SELECT id From BT_Payment_Method__c];
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        objOrder.Updated_Order_Total__c = 120.00;
        update objOrder;
        webcart testcart=[select id,Pickup_Dealer__c from webcart Limit 1];
        
        WebCart updatetestcart=[select id,Pickup_Dealer__c from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        updatetestcart.Pickup_Dealer__c = false;
        update updatetestcart;
        
        map<String, object> custMap = createCustomerDataMap();        
        Test.startTest();
        
        B2B_CreditCardControllerMock.createCustomerResponse = true;      
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.retryFailedPayment(objOrder.id, testcart.id);
        B2B_PaymentFormController.processPaymentByMyPayment('objPayment.Id', 'updatetestcart.id', 'objOrder.id', custMap);        
        Test.stopTest();    
    }
    
    @isTest
    public static void testHostedFormSetupOrdernull(){
        Test.startTest();
        Map<String, Object> mapReturnData = B2B_PaymentFormController.hostedFormSetup('');       
        Test.stopTest();
    
    }
    
     @isTest
    public static void testprocessPaymentNegative2(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);       
        
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        update updatetestcart;
	
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        map<String, object> custMap = createCustomerDataMap();        
        Test.startTest();
        
		B2B_CreditCardControllerMock.createCustomerResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = true;        
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'Credit Card');       
        Test.stopTest();
    }
    
  @isTest
    public static void testprocessPaymentNegative3(){
        Account objAccount = [SELECT Id FROM Account LIMIT 1];
        Order objOrder = createTestData(objAccount);       
        
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);       
        objOrder.Status = 'Payment Issue';
        objOrder.IsPaymentReproccessing__c = true;
        update objOrder;
        webcart testcart=[select id from webcart Limit 1];
        WebCart updatetestcart=[select id from WebCart Limit 1];
        updatetestcart.DealerId__c=objAccount.id;
        update updatetestcart;
	
        B2B_PaymentFormController.DATA_UPDATES = new Map<String,Object>();
        map<String, object> custMap = createCustomerDataMap();        
        Test.startTest();
        
        B2B_CreditCardControllerMock.createErrorResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = true;        
        Test.setMock(HTTPCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_PaymentFormController.processPayment('tokencc_bh_t4s5zb_s2y8ms_7bkrz6_8wp4fy_zx7', custMap,testcart.id,objOrder.id, 'createCustomer');       
        Test.stopTest();
    }
}
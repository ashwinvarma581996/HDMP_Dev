/**************************************************************************************
@File Name      : B2B_OrderTriggerTest  
@Description    : This is a test class for OrderTrigger.
@Created By		: Rajrishi Kaushik
@Business Unit  : HDM
@Created Date   : 16/07/2021
@API Version    : 54.0
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                    | User Story  
19-07-2022                | Ravi Prasad      | Order Status updated		 | 
*****************************************************************************************/
@isTest
public class B2B_OrderTriggerTest {
    
	@isTest
    public static void unitTestPositive(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        objOrder.BT_Transaction_Id__c = 'fe67q2zd';
        update objOrder;
        Test.startTest();
        objOrder.Status = 'CUSTOMER CANCELED';
        update objOrder;
        Test.stopTest();                
    }
    
    @isTest
    public static void captureBTCustomerOrderPositiveTest(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);   
        system.debug('objOrder123'+objOrder);
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);         
        objOrder.Status = 'Activated';
        objOrder.BT_Transaction_Id__c = 'fe67q2zd';
        update objOrder;
        objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        update objOrder;
        Test.startTest();
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';       
        update objOrder;
        Test.stopTest();                
    }
    
    @isTest
    public static void captureBTCustomerOrderPositiveWithAccessToken(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        objOrder.BT_Transaction_Id__c = 'fe67q2zd';
        update objOrder;
       	objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        update objOrder;
        Test.startTest();
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';       
        update objOrder;
        Test.stopTest();     
    }
    
    
    @isTest
    public static void unitTestPositiveWithAccessToken(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        update objOrder;
        Test.startTest();
        objOrder.Status = 'CUSTOMER CANCELED';
        update objOrder;
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestNegativeWithoutBTDetails(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);                      
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        
        Test.startTest();
        objOrder.Status = 'CUSTOMER CANCELED';
        update objOrder;
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestNegativeWithoutCustomer(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);                      
       	B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        Test.startTest();
        objOrder.Status = 'CUSTOMER CANCELED';
        update objOrder;
        Test.stopTest();
    }
        
    
    @isTest
    public static void testRefundPositiveWithAccessToken(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        objOrder.BT_Transaction_Id__c = 'fe67q2zd';
        update objOrder;
       	objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        update objOrder;
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';  
        objOrder.BT_Transaction_Status__c = 'Settled';
        update objOrder;
        Test.startTest();
       	objOrder.Status = 'PARTIAL RETURN';       
        update objOrder;
        Test.stopTest();     
    }
    
    
    @isTest
    public static void testRefundPositiveForInstallOrder(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        objOrder.BT_Transaction_Id__c = 'fe67q2zd';
        update objOrder;
        Test.startTest();
       	objOrder.Status = 'ORDER COMPLETE - INSTALLED';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        objOrder.BT_Transaction_Status__c = 'Settled';
        update objOrder; 
        
        
       	objOrder.Status = 'PARTIAL RETURN';       
        update objOrder;
        Test.stopTest();     
    }
    
    
    public static Order createTestData(Account objAccount){
       	Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());         	 
        WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, objAccount.Id, testStore.Id);
        testcart.Delivery_Type__c = 'Install At Dealer';
        update testcart;
        CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, testcart.Id);
        Product2 prod = B2B_TestDataFactory.createProduct(true);
        Product2 objProduct = [Select Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c From Product2 Where Id =: prod.Id];
        CartItem objCartItem = B2B_TestDataFactory.createCartItem(true, testcart.Id, testdelivery.Id, objProduct.Id);    
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objuser = new User(Alias = 'standt', Email='rajuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
             UserName='rajuser@testorg.com');
        insert objuser;
        B2B_Custom_Settings__c obj = B2B_TestDataFactory.createCustomSetting(true, objAccount.Id, objuser.Id);
        Order objOrder = B2B_TestDataFactory.createOrder(true, objAccount.Id, testcart.Id);
        OrderItem objOrderItem123 = B2B_TestDataFactory.createOrderItem(false, objOrder.Id, objProduct.Id); 
        objOrderItem123.Updated_Quantity__c = objOrderItem123.Quantity;
        insert objOrderItem123;
        system.debug('OrderItem123'+objOrderItem123);
        return objOrder;
    }
    
    @isTest
    public static void testGenerateOrderRefNumOnAfterUpdate(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        objAccount.Dealer_Type__c = 'Honda Auto';
        objAccount.DivisionCd__c = 'A';
        update objAccount;
        Order objOrder = createTestData(objAccount); 
        objorder.Status = 'Activated';
        objorder.Delivery_Types__c = 'Ship to Me';
        B2B_OrderTriggerHelper.firstcall = false;
        update objorder;  
    }
    
    @isTest
    public static void testStatusUpdate(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        objAccount.Dealer_Type__c = 'Honda Auto';
        update objAccount;
        Order objOrder = createTestData(objAccount); 
        
        objorder.Delivery_Types__c = 'Ship to Me';
        B2B_OrderTriggerHelper.firstcall = false;
        objorder.Status = 'READY FOR PICKUP';
        update objorder;
        objorder.Status = 'ORDER COMPLETE - PICKED UP';
        update objorder;
    }
}
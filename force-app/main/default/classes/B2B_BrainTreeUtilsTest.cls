/******************************************************************************* 
Name: B2B_BrainTreeUtilsTest
Business Unit:HDM
Date : 16/07/2021
Developer: Rajrishi Kaushik
Description : This is a test class for B2B_BrainTreeUtils class, B2B_BrainTreeUtilsTestMock is mock class
MODIFICATIONS:26-5-2022 |Mathioli| Worked on coverage
MODIFICATIONS – 09/06/2022 | Mathioli | (Added header and removal of commented code)
***********************************************************************************/

@isTest
public class B2B_BrainTreeUtilsTest {
    @isTest
    public static void testOAuthFlowPositive() {
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeUtilsTestMock()); 
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'x6q6b83wjsn28t2m');
        Account testAccount = B2B_BrainTreeUtils.updateAccountByMerchant('x6q6b83wjsn28t2m', '351d8cad85f7599f48106a579a17e3ec', 'US');        
        System.assertEquals(testAccount.Code__c, '351d8cad85f7599f48106a579a17e3ec');
        Test.stopTest();
        B2B_BrainTreeUtils.updateBTDetailsByAccount(testAccount, '351d8cad85f7599f48106a579a17e3ec');
    }
    
    @isTest
    public static void testOAuthFlow() {
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeUtilsTestMock());         
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'x6q6b83wjsn28t2m');
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        Account testAccount = B2B_BrainTreeUtils.updateAccountByMerchant('x6q6b83wjsn28t2m', '351d8cad85f7599f48106a579a17e3ec', 'US');        
        System.assertEquals(testAccount.Code__c, '351d8cad85f7599f48106a579a17e3ec');
        Test.stopTest();
        B2B_BrainTreeUtils.updateBTDetailsByAccount(testAccount, '351d8cad85f7599f48106a579a17e3ec');
        B2B_BrainTreeUtils.updateBTDetailsByAccount(objAccount, '351d8cad85f7599f48106a579a17e3ec');        
    }        
    public static void testrefreshtoken(){
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeUtilsTestMock()); 
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        BT_Token_Details__c detail = B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
    }
    @isTest
    public static void testErrorRec(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);
        String orderid = objOrder.Id;
        B2B_BrainTreeUtils.createErrorRecord('Test',orderid, 'Test Error Class');
    }
    @isTest
    public static void testDealerLocator(){
        
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeUtilsTestMock()); 
        Account objAccount = B2B_TestDataFactory.createAccount(true);
        Account AC = [SELECT Id,PoIId__c 
                     FROM Account 
                     WHERE PoIId__c ='34507' 
                     LIMIT 1];
        Test.startTest();
        B2B_BrainTreeUtils.dealerLocatorService('251084','34507');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testDealerLocator1(){
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeUtilsTestMock());
        Account objAccount = B2B_TestDataFactory.createAccount(true);
        Account AC = [SELECT Id,PoIId__c 
                     FROM Account 
                     WHERE PoIId__c ='34507' 
                     LIMIT 1];
        B2B_BrainTreeUtils.dealerLocatorService('251084','34507');
        
        Test.stopTest();
    }
    @isTest
    public static void testVertexReturnTax(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);
        B2B_BrainTreeUtils.callVertaxReturnTax(objAccount,objOrder);
        B2B_BrainTreeUtils.callVertaxLineItemReturnTax(objAccount,objOrder, null,null);
    }
    
    @isTest
    public static void testDeleteBTVaultPaymentMethod(){
        B2B_BrainTreeUtils.deleteBTVaultPaymentMethod('test');
    }
    
    public static void testfut(){
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeUtilsTestMock());         
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'x6q6b83wjsn28t2m');
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
    }
    
    @isTest
    public static void testCheckBTTokenDetails(){
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeUtilsTestMock()); 
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        BT_Token_Details__c detail = new BT_Token_Details__c();
        String response = '{"status": 200,"merchantId": "x6q6b83wjsn28t2m","credentials": {"accessToken": "access_token$sandbox$x6q6b83wjsn28t2m$d648f8a9d4523e920c631bfa31065647","refreshToken": "refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130160a82ddf4ef9eec","tokenType": "bearer","expiresAt": "2021-07-06T09:13:40Z","scope": "read_write,shared_vault_transactions"}}';
        B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();
        objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(response, B2B_AccessTokenResponseWrapper.class);
        B2B_BrainTreeUtils.checkBTTokenDetails(detail,objAccessTokenResponseWrapper); 
    }
    
    @isTest
    public static void testNegUpdateDealerOnBoarding(){
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeUtilsTestMock()); 
        B2B_BraintreeUtils.UpdateDealerOnBoardingEnrollment('123456');
        Test.stopTest();
    }
    
    
    public static Order createTestData(Account objAccount){
        Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeUtilsTestMock());         	 
        WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, objAccount.Id, testStore.Id);
        CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, testcart.Id);
        Product2 prod = B2B_TestDataFactory.createProduct(true);
        Product2 objProduct = [Select Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c From Product2 Where Id =: prod.Id];
        CartItem objCartItem = B2B_TestDataFactory.createCartItem(true, testcart.Id, testdelivery.Id, objProduct.Id);    
        
        Profile p = [SELECT Id 
                     FROM Profile 
                     WHERE Name='Standard User']; 
        User objuser = new User(Alias = 'standt', Email='rajuser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                                UserName='rajuser@testorg.com');
        insert objuser;
        B2B_Custom_Settings__c obj = B2B_TestDataFactory.createCustomSetting(true, objAccount.Id, objuser.Id);
        Order objOrder = B2B_TestDataFactory.createOrder(true, objAccount.Id, testcart.Id);
        B2B_TestDataFactory.createOrderItem(true, objOrder.Id, objProduct.Id); 
        return objOrder;
    }

    
}
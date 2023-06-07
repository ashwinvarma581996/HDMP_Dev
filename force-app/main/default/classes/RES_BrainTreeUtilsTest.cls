/*
Description : This is a test class for RES_BrainTreeUtils class.
*/
@isTest
public class RES_BrainTreeUtilsTest {

	@isTest
    public static void testOAuthFlowPositive() {
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'x6q6b83wjsn28t2m');
        Account testAccount = RES_BrainTreeUtils.updateAccountByMerchant('x6q6b83wjsn28t2m', '351d8cad85f7599f48106a579a17e3ec', 'US');
        System.assertEquals(testAccount.Code__c, '351d8cad85f7599f48106a579a17e3ec');
        Test.stopTest();

        RES_BrainTreeUtils.updateBTDetailsByAccount(testAccount, '351d8cad85f7599f48106a579a17e3ec');
	}

    @isTest
    public static void testOAuthFlow() {
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'x6q6b83wjsn28t2m');
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        Account testAccount = RES_BrainTreeUtils.updateAccountByMerchant('x6q6b83wjsn28t2m', '351d8cad85f7599f48106a579a17e3ec', 'US');
        System.assertEquals(testAccount.Code__c, '351d8cad85f7599f48106a579a17e3ec');
        Test.stopTest();

        RES_BrainTreeUtils.updateBTDetailsByAccount(testAccount, '351d8cad85f7599f48106a579a17e3ec');
        RES_BrainTreeUtils.updateBTDetailsByAccount(objAccount, '351d8cad85f7599f48106a579a17e3ec');
	}

    @isTest
    public static void testrefreshtoken(){
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        BT_Token_Details__c detail = B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        RES_BrainTreeUtils.refreshAccessToken(detail);
    }

    @isTest
    public static void testErrorRec(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);
        String orderid = objOrder.Id;
        RES_BrainTreeUtils.createErrorRecord('Test',orderid, 'Test Error Class');
    }

    @isTest
    public static void testDealerLocator(){
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        //Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        //Order objOrder = createTestData(objAccount);
        //String orderid = objOrder.Id;
        RES_BrainTreeUtils.dealerLocatorService('251084','A');
        Test.stopTest();
    }

    @isTest
    public static void testVertexReturnTax(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);
        //String orderid = objOrder.Id;
        RES_BrainTreeUtils.callVertaxReturnTax(objAccount,objOrder);
        RES_BrainTreeUtils.callVertaxLineItemReturnTax(objAccount,objOrder);
    }

    @isTest
    public static void testfut(){
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'x6q6b83wjsn28t2m');
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        RES_BrainTreeUtils.futureNewAccessToken('x6q6b83wjsn28t2m');
    }

    /*@isTest
    public static void testCheckBTTokenDetails(){
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        BT_Token_Details__c detail = B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        String response = B2B_BrainTreeIntegration.getAccessToken(objAccount.Merchant_Id__c, '351d8cad85f7599f48106a579a17e3ec');
        Account testAccount = RES_BrainTreeUtils.updateAccountByMerchant('x6q6b83wjsn28t2m', '351d8cad85f7599f48106a579a17e3ec', 'US');
        B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();
        objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(response, B2B_AccessTokenResponseWrapper.class);
        RES_BrainTreeUtils.checkBTTokenDetails(detail,objAccessTokenResponseWrapper);
    }*/

    public static Order createTestData(Account objAccount){
       	Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, objAccount.Id, testStore.Id);
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
        B2B_TestDataFactory.createOrderItem(true, objOrder.Id, objProduct.Id);
        return objOrder;
    }
}
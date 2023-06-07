/**********************************************************************
Name: RES_BrainTreeIntegrationTest
Purpose: Test Class for BrainTreeIntegration.
Date : 05/07/2021
Created By : Apoorv Garg
*************************************************************/
@isTest
public class RES_BrainTreeIntegrationTest {

    @isTest
    public static void testNegAccessToken(){
        Test.startTest();
        String merchantId = 'dadagdadh';
        String code = '54dc9f56f2a9820';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String negAccessResponse = RES_BrainTreeIntegration.getAccessToken(merchantID, code);
        System.assertEquals(true,negAccessResponse.contains('502'));
        Test.stopTest();
    }

    @isTest
    public static void testAccessToken(){
        Test.startTest();
        String merchantId = 'x6q6b83wjsn28t2m';
        String code = '54dc9f56f2a98200e31aa9ce87c435d6';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String accessResponse = RES_BrainTreeIntegration.getAccessToken(merchantID, code);
  		System.assertEquals(true,accessResponse.contains('200'));
        Test.stopTest();
    }

    @isTest
    public static void testNegRefreshToken(){
        Test.startTest();
        String merchantId = 'agdadh';
        String refreshToken = 'refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String negRefreshResponse = RES_BrainTreeIntegration.getRefreshToken(merchantID, refreshToken);
   		System.assertEquals(true,negRefreshResponse.contains('502'));
        Test.stopTest();
    }

    @isTest
    public static void testRefreshToken(){
        Test.startTest();
        String merchantId = 'x6q6b83wjsn28t2m';
        String refreshToken = 'refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130160a82ddf4ef9eec';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String refreshResponse = RES_BrainTreeIntegration.getRefreshToken(merchantID, refreshToken);
       	System.assertEquals(true,refreshResponse.contains('200'));
        Test.stopTest();
    }

    @isTest
    public static void testnegativePreAuth() {
        Test.startTest();
          // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String negpreAuthResponse = RES_BrainTreeIntegration.braintreeTransactionPreAuth('123','bbncbncnb','refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130160a82ddddf9eed','10','009');
        System.assertEquals(true,negpreAuthResponse.contains('400'));
        Test.stopTest();
    }

    @isTest
    public static void testPreAuth(){
        Test.startTest();
        String merchantId = 'x6q6b83wjsn28t2m';
        String customerID ='John Smith';
        String saleAmount = '210';
        String accessToken = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        String paymentToken = '009';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String preAuthResponse = RES_BrainTreeIntegration.braintreeTransactionPreAuth(customerID, merchantID, accessToken, saleAmount, paymentToken);
        //System.assertEquals(true,preAuthResponse.contains('200'));
        Test.stopTest();
    }

    @isTest
    public static void testPostAuth(){
        Test.startTest();
        String merchantId = 'x6q6b83wjsn28t2m';
        String customerID ='John Smith';
        String transactionID = '2e0aavf2';
        String accessToken = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String postAuthResponse = RES_BrainTreeIntegration.braintreeTransactionPostAuth(customerID, merchantID, transactionID,'5000', accessToken);
       // System.assertEquals(true,postAuthResponse.contains('200'));
        Test.stopTest();
    }

    @isTest
    public static void testNegPostAuth(){
        Test.startTest();
        String merchantId = 'ffsfsf';
        String customerID ='John';
        String transactionID = '2e0aa';
        String accessToken = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String negpostAuthResponse = RES_BrainTreeIntegration.braintreeTransactionPostAuth(customerID, merchantID, transactionID,'5000', accessToken);
        //System.assertEquals(true,negpostAuthResponse.contains('400'));
        Test.stopTest();
    }

    @isTest
    public static void testNegRefund(){
       Test.startTest();
        String merchantId = 'sfsjgf';
        String customerID ='Smith';
        String transactionID = '2e0a';
        String accessToken = 'access_token$sandbox$x6q6b83wjsn28t2m$d648f8a9d4523e920c631bfa31065647';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String negRefundResponse = RES_BrainTreeIntegration.braintreeTransactionRefund(customerID, merchantID, accessToken, transactionID, '3000');
       //System.assertEquals(true,negRefundResponse.contains('400'));
        Test.stopTest();
    }

    @isTest
    public static void testRefund(){
        Test.startTest();
        String merchantId = 'x6q6b83wjsn28t2m';
        String customerID ='John Smith';
        String transactionID = '2e0aavf2';
        String accessToken = 'access_token$sandbox$x6q6b83wjsn28t2m$d648f8a9d4523e920c631bfa31065647';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String posRefundResponse = RES_BrainTreeIntegration.braintreeTransactionRefund(customerID, merchantID, accessToken, transactionID,'3000');
       // System.assertEquals(true,posRefundResponse.contains('200'));
        Test.stopTest();
    }

   	@isTest
    public static void testNegVoid(){
        Test.startTest();
        String merchantId = 'sdfsfjsf';
        String customerID = 'JohnSmith';
        String transactionID = '2e0aavf2ddd';
        String accessToken = 'access_token$sandbox$x6q6b83wjsn28t2m$d648f8a9d4523e920c631bfa31065647';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String negVoidResponse = RES_BrainTreeIntegration.braintreeTransactionVoid(customerID, merchantID, transactionID, accessToken);
       // System.assertEquals(true,negVoidResponse.contains('400'));
        Test.stopTest();
    }

    @isTest
    public static void testVoid(){
        Test.startTest();
        String merchantId = 'x6q6b83wjsn28t2m';
        String customerID = 'John Smith';
        String transactionID = '2e0aavf2';
        String accessToken = 'access_token$sandbox$x6q6b83wjsn28t2m$d648f8a9d4523e920c631bfa31065647';
        Test.setMock(HTTPCalloutMock.class, new RES_BrainTreeIntegrationMock());
        String posVoidResponse = RES_BrainTreeIntegration.braintreeTransactionVoid(customerID, merchantID, transactionID, accessToken);
    	//System.assertEquals(true,posVoidResponse.contains('200'));
        Test.stopTest();
    }

}
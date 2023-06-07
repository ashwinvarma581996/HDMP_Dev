/**********************************************************************
Name: B2B_BrainTreeIntegrationTest
Purpose: Test Class for BrainTreeIntegration.
Date : 05/07/2021
Created By : Apoorv Garg
*************************************************************/
@isTest
public class B2B_BrainTreeIntegrationTest {
	
    @isTest
    public static void testNegAccessToken(){
        Test.startTest();
        String merchantId = 'dadagdadh';
        String code = '54dc9f56f2a9820';   
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String negAccessResponse = B2B_BrainTreeIntegration.getAccessToken(merchantID, code);   
        // for catch coverage 
        B2B_BrainTreeIntegration.getAccessToken('testCatch', code);
        System.assertEquals(true,negAccessResponse.contains('502'));
        Test.stopTest();
    }
    
    @isTest
    public static void testAccessToken(){
        Test.startTest();
        String merchantId = 'x6q6b83wjsn28t2m';
        String code = '54dc9f56f2a98200e31aa9ce87c435d6';   
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String accessResponse = B2B_BrainTreeIntegration.getAccessToken(merchantID, code);
  		System.assertEquals(true,accessResponse.contains('200'));
        Test.stopTest();
    }

    @isTest
    public static void testNegRefreshToken(){
        Test.startTest();
        String merchantId = 'dadagdadh';
        String refreshToken = 'refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130';
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String negRefreshResponse = B2B_BrainTreeIntegration.getRefreshToken(merchantID, refreshToken);
        // for catch coverage 
        B2B_BrainTreeIntegration.getRefreshToken('testCatch', refreshToken);
   		System.assertEquals(true,negRefreshResponse.contains('502'));
        Test.stopTest();
    }
    
    @isTest
    public static void testRefreshToken(){
        Test.startTest();
        String merchantId = 'x6q6b83wjsn28t2m';
        String refreshToken = 'refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130160a82ddf4ef9eec';
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String refreshResponse = B2B_BrainTreeIntegration.getRefreshToken(merchantID, refreshToken);
       	System.assertEquals(true,refreshResponse.contains('200'));
        Test.stopTest();
    }
    
    @isTest
    public static void testnegativePreAuth() {
        Test.startTest();
          // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());             
        String negpreAuthResponse = B2B_BrainTreeIntegration.braintreeTransactionPreAuth('123','bbncbncnb','refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130160a82ddddf9eed','10','009', '');
       // for catch coverage 
        B2B_BrainTreeIntegration.braintreeTransactionPreAuth('testCatch','testCatch','refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130160a82ddddf9eed','10','009', '');
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
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String preAuthResponse = B2B_BrainTreeIntegration.braintreeTransactionPreAuth(customerID, merchantID, accessToken, saleAmount, paymentToken, '');
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
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String postAuthResponse = B2B_BrainTreeIntegration.braintreeTransactionPostAuth(customerID, merchantID, transactionID,'5000', accessToken);
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
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String negpostAuthResponse = B2B_BrainTreeIntegration.braintreeTransactionPostAuth(customerID, merchantID, transactionID,'5000', accessToken);
        B2B_BrainTreeIntegration.braintreeTransactionPostAuth('testCatch', merchantID, transactionID,'5000', accessToken);
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
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String negRefundResponse = B2B_BrainTreeIntegration.braintreeTransactionRefund(customerID, merchantID, accessToken, transactionID, '3000');
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
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String posRefundResponse = B2B_BrainTreeIntegration.braintreeTransactionRefund(customerID, merchantID, accessToken, transactionID,'3000');
        B2B_BrainTreeIntegration.braintreeTransactionRefund('testCatch', merchantID, accessToken, transactionID,'3000');
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
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String negVoidResponse = B2B_BrainTreeIntegration.braintreeTransactionVoid(customerID, merchantID, transactionID, accessToken);
        B2B_BrainTreeIntegration.braintreeTransactionVoid('testCatch', merchantID, transactionID, accessToken);
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
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        String posVoidResponse = B2B_BrainTreeIntegration.braintreeTransactionVoid(customerID, merchantID, transactionID, accessToken);         	
        //System.assertEquals(true,posVoidResponse.contains('200'));
        Test.stopTest();
    }
    
     //Raktim 
    @isTest
    public static void testPaymentMethodDelete(){
        Test.startTest();        
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_BrainTreeTransactionResponse updateResponse = B2B_BrainTreeIntegration.braintreePaymentMethodDelete('braintreePaymentMethodDelete');
        Test.stopTest();
    }
    
    //Raktim
    @isTest
    public static void testPaymentMethodDeleteNeg(){
        Test.startTest();        
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock1()); 
        B2B_BrainTreeTransactionResponse updateResponse = B2B_BrainTreeIntegration.braintreePaymentMethodDelete('2refdsss');        
        Test.stopTest();
    }
    
    //Raktim
    @isTest
    public static void testbraintreePaymentMethodFind(){
        Test.startTest();        
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_BrainTreeTransactionResponse updateResponse = B2B_BrainTreeIntegration.braintreePaymentMethodFind('braintreePaymentMethodFind');
        Test.stopTest();
    }
    
    //Raktim
    @isTest
    public static void testbraintreePaymentMethodFindNegative(){
        Test.startTest();        
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock1()); 
        B2B_BrainTreeTransactionResponse updateResponse = B2B_BrainTreeIntegration.braintreePaymentMethodFind('12324342');
        B2B_BrainTreeIntegration.braintreePaymentMethodFind('');
        Test.stopTest();
    }
    
    //Raktim
    @isTest
    public static void testbraintreeAddressDelete(){
        Test.startTest();        
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_BrainTreeTransactionResponse updateResponse = B2B_BrainTreeIntegration.braintreeAddressDelete('braintreeAddressDelete',' ');
        Test.stopTest();
    }
    
    //Raktim
    @isTest
    public static void testbraintreeAddressDeleteNeg(){
        Test.startTest();        
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_BrainTreeTransactionResponse updateResponse = B2B_BrainTreeIntegration.braintreeAddressDelete('1234','x ');
        B2B_BrainTreeIntegration.braintreeAddressDelete('','');
        Test.stopTest();
    }
    
    //Raktim    
    @isTest
    public static void testbraintreeTransactionSearch(){
        Test.startTest();        
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_BrainTreeIntegration.braintreeTransactionSearch('fe67q2zd','54dc9f56f2a9820');
        B2B_BrainTreeIntegration.braintreeTransactionSearch('braintreeTransactionSearch','54dc9f56f2a9820');
        
        B2B_BrainTreeIntegration.braintreeTransactionSearch('coverCatch','54dc9f56f2a9820');
        Test.stopTest();
    }
    
	@isTest
    public static void testCreditCardUpdate(){
        Test.startTest();        
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_BrainTreeTransactionResponse updateResponse = B2B_BrainTreeIntegration.braintreePaymentMethodUpdate('cGF5bWVudG1ldGhvZF9jY183M2RrZmM2', 'tokencc_bj_4sz547_syz2ys_bs54n6_ks82dn_gy3');
        Test.stopTest();
    }
    @isTest
    public static void testCreditCardUpdateNeg(){
        Test.startTest();        
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        B2B_BrainTreeTransactionResponse updateResponse = B2B_BrainTreeIntegration.braintreePaymentMethodUpdate('testNonce', 'tokencc_bj_4sz547_syz2ys_bs54n6_ks82dn_gy3');
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestPositive(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        update objOrder;
        Test.startTest();
        objOrder.Status = 'CUSTOMER CANCELED';
        update objOrder;
        List<OrderItem> lstOrderItems = [SELECT Id, Total_Return_Installation_Charge__c, Delta_Quantity__c, Updated_Installation_Price__c,Delta_Installation_Price__c, Updated_Quantity__c,Return_Quantity__c, Quantity, UnitPrice, Total_Tax__c 
                                         FROM OrderItem];
        B2B_BrainTreeIntegration.revertOrderItemChanges(lstOrderItems); 
        Test.stopTest();                
    }
    
    //cancel failure testing starts 
    @isTest
    public static void unitTestCancelFailure(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'sdfsfjsf');
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
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
    public static void unitTestCancelRefreshTokenFailure(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'dadagdadh');
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
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
    public static void unitTestCancelFailureWithAccessToken(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'sdfsfjsf');
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
    //cancel failure testing ends 
    
    //fulfillment failure testing starts 
   	@isTest
    public static void unitTestFulfillFailure(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'ffsfsf');
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
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
    public static void fulfiilRefreshTokenFailure(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'dadagdadh');
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
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
    public static void fulfillFailureWithAccessToken(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'ffsfsf');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
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
      //fulfillment failure testing ends 
    
    @isTest
    public static void unitTest(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'sdfsfjsf');
        Order objOrder = createTestData(objAccount);               
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
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
    public static void captureBTCustomerOrderPositiveTest(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);   
        system.debug('objOrder123'+objOrder);
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);         
        objOrder.Status = 'Activated';
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
        Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock());
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
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
        objOrder.Status = 'Activated';
        update objOrder;
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
        objOrder.Status = 'Activated';
        update objOrder;
        Test.startTest();
        objOrder.Status = 'CUSTOMER CANCELED';
        objOrder.BT_Customer_Detail__c = null;
        update objOrder;        
        Test.stopTest();
    }
    
    
     @isTest
    public static void unitTestNegWithoutBTDetails(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);                      
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'IN PROGRESS';
        update objOrder;
        Test.startTest();
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';
        update objOrder;       
        Test.stopTest();
    }
    
    @isTest
    public static void unitTestNegWithoutCustomer(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);                      
       	B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        objOrder.Status = 'IN PROGRESS';
        update objOrder;
        Test.startTest();       
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';
        objOrder.BT_Customer_Detail__c = null;
        update objOrder;
        Test.stopTest();
    }
        
    
   // @isTest
    public static void testRefundPositiveWithAccessToken(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        update objOrder;
       	objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        update objOrder;
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';  
        objOrder.BT_Transaction_Status__c = 'Settled';
        update objOrder;
        Test.startTest();
       	objOrder.Status = 'ORDER RETURN';        
        update objOrder;
        Test.stopTest();     
    }
    
    @isTest
    public static void testPartialRefundPositiveWithAccessToken(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        update objOrder;
       	objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        update objOrder;
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';  
        objOrder.BT_Transaction_Status__c = 'Settled';
        update objOrder;
        Test.startTest();
       	objOrder.Status = 'PARTIAL RETURN COMPLETE';        
        update objOrder;
        Test.stopTest();     
    }
    
    
    @isTest
    public static void testRefundPositiveWithoutAccessToken(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        //objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        update objOrder;
       	objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        update objOrder;
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';  
        objOrder.BT_Transaction_Status__c = 'Settled';
        update objOrder;
        Test.startTest();
       	objOrder.Status = 'ORDER RETURN';        
        update objOrder;
        Test.stopTest();     
    }
    
    @isTest
    public static void testPartialRefundPositiveWithoutAccessToken(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        //objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        update objOrder;
       	objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        update objOrder;
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';  
        objOrder.BT_Transaction_Status__c = 'Settled';
        update objOrder;
        Test.startTest();
       	objOrder.Status = 'PARTIAL RETURN COMPLETE';        
        update objOrder;
        Test.stopTest();     
    }
    
        @isTest
    public static void captureBTCustomerOrderFailure(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'bbncbncnb');
        Order objOrder = createTestData(objAccount);   
        system.debug('objOrder123'+objOrder);
        B2B_TestDataFactory.createBTTokenDetails(true, objAccount.Id);
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        BT_Transaction_Details__c objTran = B2B_TestDataFactory.createBTTransactionDetails(false, objOrder.Id); 
		objTran.BT_TransactionId__c = 'braintreeTransactionSearch';  
        insert objTran;
        objOrder.Status = 'Activated';
        update objOrder;
        objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        objOrder.BT_Transaction_Id__c = 'braintreeTransactionSearch';
        update objOrder;
        Test.startTest();
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';       
        update objOrder;
        Test.stopTest();                
    }
    
    @isTest
    public static void captureOrderFailureWithAccessToken(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'bbncbncnb');
        Order objOrder = createTestData(objAccount);   
        system.debug('objOrder123'+objOrder);
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        BT_Transaction_Details__c objTran = B2B_TestDataFactory.createBTTransactionDetails(false, objOrder.Id); 
		objTran.BT_TransactionId__c = 'braintreeTransactionSearch';  
        insert objTran;
        objOrder.Status = 'Activated';
        update objOrder;
        objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        objOrder.BT_Transaction_Id__c = 'braintreeTransactionSearch';
        update objOrder;
        Test.startTest();
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';       
        update objOrder;
        Test.stopTest();                
    }
    
     @isTest
    public static void testBraintreeOrderCancellationCatch(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'sdfsfjsf');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        update objOrder;
        
        objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = 20000;
        objOrder.Updated_Total_Tax__c = 300;
        update objOrder;
        
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';  
        objOrder.BT_Transaction_Status__c = 'Settled';
        update objOrder;
        Test.startTest();
        objOrder.Current_Shipping_Tax__c = null;
       	objOrder.Status = 'PARTIAL RETURN COMPLETE';        
        update objOrder;
        Test.stopTest();                 
    }
    
   @isTest
    public static void fulfillFailureCatch(){
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'ffsfsf');
        Order objOrder = createTestData(objAccount);               
        BT_Token_Details__c objBTTokenDetails = B2B_TestDataFactory.createBTTokenDetails(false, objAccount.Id);
        objBTTokenDetails.AccessTokenExpiresAt__c = System.now().addDays(1);
        insert objBTTokenDetails;
        B2B_TestDataFactory.createBTCustomerDetails(true, objOrder.Id);
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);  
        objOrder.Status = 'Activated';
        update objOrder;
        objOrder.Status = 'IN PROGRESS';
        objOrder.Updated_Order_Total__c = null;
        objOrder.Updated_Total_Tax__c = 300;
        update objOrder;
        Test.startTest();
        objOrder.Status = 'ORDER COMPLETE - SHIPPED';       
        update objOrder;
        Test.stopTest();               
    }
    
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
        Order objOrder = B2B_TestDataFactory.createOrder(false, objAccount.Id, testcart.Id);
        objOrder.Updated_Order_Amount__c = 15000;
        objOrder.Updated_Order_Total__c = 15010;
        objOrder.Updated_Total_Tax__c = 10;
        objOrder.BT_Transaction_Id__c = 'fe67q2zd';
        objOrder.BT_Customer_Detail__c = 'dfrsedfg';
        objOrder.Payment_Method_Token__c = 'sdfgdaasfgdfsafgdeaw';
        objOrder.Current_Shipping_Tax__c = 0;
        objOrder.Return_Shipping_Tax__c = 0;
        insert objOrder;
        
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);
        
        OrderItem objOrderItem123 = B2B_TestDataFactory.createOrderItem(false, objOrder.Id, objProduct.Id); 
        objOrderItem123.Updated_Quantity__c = 2;  
        objOrderItem123.Updated_Installation_Price__c = 25;
        objOrderItem123.Total_Tax__c = 10;
        objOrderItem123.Delta_Quantity__c = 2;
        objOrderItem123.Delta_Installation_Price__c = 12;
        insert objOrderItem123;
        system.debug('OrderItem123'+objOrderItem123);
        return objOrder;
    }
    
}
/**
* @File Name          : B2B_MyPaymentsControllerTest
* @Description        : Apex class is created for code coverage only.
* @Created By         : Farazuddin
* @Date               : 04/March/2022
* @Last Modified By   : 22/September/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       04/March/2022             Farazuddin            Initial Version
* 2.0        22/September/2022           Mathioli            

**/
@isTest
private class B2B_MyPaymentsControllerTest {
    @testSetup static void setup() {
        User userObj = B2B_TestDataFactory.createUser(true);
        System.runAs(userObj) {
            createBTCustomerDetails();
            createBillingAddress();
            createBTPaymentMethod();           
            B2B_MyPaymentsController myPaymentsObj = new B2B_MyPaymentsController();
        }
    }
    
    private static void createBTCustomerDetails(){
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        BT_Customer_Details__c objBTCustomerDetails = new BT_Customer_Details__c();
        objBTCustomerDetails.BT_CustomerId__c = '582110612';
        objBTCustomerDetails.Name = 'John1';
        objBTCustomerDetails.Customer__c = userList[0].Id;
        insert objBTCustomerDetails;
    }
    
    private static void createBillingAddress(){
        List<User> userList = [SELECT Id FROM User LIMIT 1];
        My_Address_Book__c addressObj = new My_Address_Book__c();
        addressObj.Name = 'Test Address';
        //addressObj.Address_Type__c = 'Billing Address';
        insert addressObj;
    }
    
    private static void createBTPaymentMethod(){
        BT_Customer_Details__c objBTCustomerDetails = [SELECT Id FROM BT_Customer_Details__c];
        My_Address_Book__c addressObj = [SELECT Id FROM My_Address_Book__c LIMIT 1];
        BT_Payment_Method__c BTPaymentObj = new BT_Payment_Method__c();
        //BTPaymentObj.Name = 'Test Payment';
        BTPaymentObj.Payment_Method_Token__c = 'cGF5bWVudG1ldGhvZF9wcF9wZGdicHM2';
        BTPaymentObj.BT_Customer_Details__c = objBTCustomerDetails.Id;
        //BTPaymentObj.My_Address_Book__c = addressObj.Id;
        BTPaymentObj.Default_Payment_Method__c = true;
        BTPaymentObj.Is_In_My_Payment__c=true;
        BTPaymentObj.Is_Vaulted__c=true;
        BTPaymentObj.CC_Expiration_Month__c=09;
        BTPaymentObj.CC_Expiration_Year__c=2019;
        insert BTPaymentObj;
    }
    
    @isTest static void testGetAllMyPayments() {
        //B2B_MyPaymentsController.callClientTokenAPI=true;
        User userHonda = [SELECT Id FROM User LIMIT 1];
        BT_Customer_Details__c objBTCustomerDetails = [SELECT Id FROM BT_Customer_Details__c ];
        My_Address_Book__c addressObj = [SELECT Id, Person_Address_Account__r.PersonContactId FROM My_Address_Book__c LIMIT 1];
        BT_Payment_Method__c BTPaymentObj = [SELECT Id, Name,BT_Customer_Details__c, Default_Payment_Method__c FROM BT_Payment_Method__c LIMIT 1];
        system.debug('BTPaymentObj' +BTPaymentObj);
        Test.startTest(); 
        
        System.runAs(userHonda) {
            B2B_MyPaymentsController.getAllMyPayments();
            B2B_MyPaymentsController.markPreferredSingleRecord(BTPaymentObj.id);
            B2B_MyPaymentsController.getAllMyAddresses(addressObj.id);            
        }
        System.runAs(userHonda) {
            delete addressObj;
            B2B_MyPaymentsController.getAllMyPayments();
            B2B_MyPaymentsController.getAllMyPaymentsNew();
            
        }
        System.runAs(userHonda) {
            delete objBTCustomerDetails;
            B2B_MyPaymentsController.getAllMyPayments();
            B2B_MyPaymentsController.getSavedAddresses();
            B2B_MyPaymentsController.getAllMyPaymentsNew();
            
        }
        System.runAs(userHonda) {
            delete BTPaymentObj;
            B2B_MyPaymentsController.markPreferredSingleRecord(BTPaymentObj.id);
            Test.stopTest(); 
        }
    }
     @isTest static void getSavedAddresses() {
            B2B_MyPaymentsController.getSavedAddresses();
         B2B_MyPaymentsController.getAddMyPayments();
 		 B2B_MyPaymentsController.getAllMyPayments();
         B2B_MyPaymentsController.getAllMyPaymentsNew();
         }
    
      @isTest static void testDeletePaymentRecord() {
        User userObj = [SELECT Id From User limit 1];
        System.runAs(userObj) {
            List<BT_Payment_Method__c> BTPaymentObj = [SELECT Id,Payment_Method_Token__c FROM BT_Payment_Method__c];
            Test.startTest();
            //B2B_BrainTreeIntegrationMock.createDeleteResponse = true;
            Test.setMock(HttpCalloutMock.class, new B2B_BrainTreeIntegrationMock());
            B2B_MyPaymentsController.deletePaymentRecord(BTPaymentObj[0].id);
            Test.stopTest();
        }
    }
    
        //added by mathi for covering negative
    @isTest static void testDeletePaymentRecord1() {
        Map<String,Object> customerData=new Map<String,object>();
            Test.startTest();
        
        	 B2B_MyPaymentsController.createCustomer(customerData);
            B2B_MyPaymentsController.deletePaymentRecord('');
        	B2B_MyPaymentsController.deletePaymentRecord('a');
        	B2B_MyPaymentsController.getAllMyAddresses(null);
            Test.stopTest();
    }
    
       
    @isTest static void testmarkPreferredSingleRecord2() {
        User userHonda = [SELECT Id FROM User LIMIT 1];
       BT_Customer_Details__c objBTCustomerDetails = [SELECT Id FROM BT_Customer_Details__c];
        System.runAs(userHonda) {
            delete objBTCustomerDetails;
            B2B_MyPaymentsController.getAllMyAddresses('q');//added by mathi
            try{
                    B2B_MyPaymentsController.markPreferredSingleRecord('a');
            } catch(exception ex){}
             
             B2B_MyPaymentsController.getAllMyAddresses(null);
        }
    }
    //added by mathi to cover getmypayment
       @isTest static void testGetAllMyPayments1() {
        User userHonda = [SELECT Id FROM User LIMIT 1];
      	System.runAs(userHonda) {
        String currentUserId = UserInfo.getUserId();
        BT_Customer_Details__c objBTCustomerDetails = [SELECT Id FROM BT_Customer_Details__c WHERE Customer__c =: currentUserId Limit 1 ];
        My_Address_Book__c addressObj = [SELECT Id FROM My_Address_Book__c LIMIT 1];
        BT_Payment_Method__c BTPaymentObj = [SELECT Id, Name, Default_Payment_Method__c FROM BT_Payment_Method__c LIMIT 1];
        Test.startTest(); 
    
            B2B_MyPaymentsController.getAllMyPayments();
        }
        Test.stopTest(); 
    }
    
    //added by mathi to cover getsavedaddress
        
    @isTest static void testgetSavedAddresses1() {
       //User userHonda = [SELECT Id FROM User LIMIT 1];
       // BT_Customer_Details__c objBTCustomerDetails = [SELECT Id FROM BT_Customer_Details__c];

        //BT_Payment_Method__c BTPaymentObj = [SELECT Id, Name, Default_Payment_Method__c FROM BT_Payment_Method__c LIMIT 1];
      	//System.runAs(userHonda) {
                   My_Address_Book__c addressObj1 = new My_Address_Book__c();
            insert addressObj1;
            B2B_MyPaymentsController.getSavedAddresses();
        //}
    }
    
    @isTest static void testUpdateCreditCard(){
        User userHonda = [SELECT Id FROM User LIMIT 1];
        //BT_Customer_Details__c objBTCustomerDetails = [SELECT Id FROM BT_Customer_Details__c];
        BT_Payment_Method__c BTPaymentObj = [SELECT Id, Name, Default_Payment_Method__c FROM BT_Payment_Method__c LIMIT 1];
        BT_Payment_Method__c BTPaymentObj2 = [SELECT Id, Name FROM BT_Payment_Method__c LIMIT 1];
      //  B2B_MyPaymentsController.callClientTokenAPI=true;
        Test.startTest();
        System.runAs(userHonda) {
            Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
            String payload = '{"nonce": "tokencc_bj_4sz547_syz2ys_bs54n6_ks82dn_gy3","details": {"cardholderName": "Raj QA New","expirationMonth": "12","expirationYear": "2023"}}';
           
            B2B_MyPaymentsController.updatePaymentAndAddress(payload, JSON.serialize(BTPaymentObj),'');
            B2B_MyPaymentsController.updatePaymentAndAddress(payload, JSON.serialize(BTPaymentObj2),'');
        Test.stopTest();
    }
    }
    //added by mathi
   
       @isTest static void testUpdateCreditCardnegative(){
        User userHonda = [SELECT Id FROM User LIMIT 1];
        //BT_Customer_Details__c objBTCustomerDetails = [SELECT Id FROM BT_Customer_Details__c];
       // BT_Payment_Method__c BTPaymentObj = [SELECT Id, Name, Default_Payment_Method__c FROM BT_Payment_Method__c LIMIT 1];
        //BT_Payment_Method__c BTPaymentObj2 = [SELECT Id, Name FROM BT_Payment_Method__c LIMIT 1];
      //  B2B_MyPaymentsController.callClientTokenAPI=true;
        Test.startTest();
        //System.runAs(userHonda) {
           // Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
            //String payload = '{"nonce": "tokencc_bj_4sz547_syz2ys_bs54n6_ks82dn_gy3","details": {"cardholderName": "Raj QA New","expirationMonth": "12","expirationYear": "2023"}}';
           //B2B_MyPaymentsController.callClientTokenAPI=true;
           // B2B_MyPaymentsController.updatePaymentAndAddress(payload, JSON.serialize(BTPaymentObj));
            //B2B_MyPaymentsController.updatePaymentAndAddress(payload, JSON.serialize(BTPaymentObj2));
            try{
            B2B_MyPaymentsController.updatePaymentAndAddress(null, null, null);// added by mathi for covering catch
            }
            catch (exception ex){}
        //}
        Test.stopTest();
    }
    
 
  
    
    //added by mathi to cover updateexpiredcardlist
    @isTest static void testupdateExpiredCardList() {
        User userObj = [SELECT Id From User limit 1];
        System.runAs(userObj) {
            List<BT_Payment_Method__c> BTPaymentObj = [SELECT Id,Payment_Method_Token__c FROM BT_Payment_Method__c];
            Test.startTest();
            //B2B_CreditCardControllerMock.createDeleteResponse = true;
            Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
            B2B_MyPaymentsController.updateExpiredCardList();
            Test.stopTest();
        }
    }
    
    @isTest static void testupdateExpiredCardList1() {
        BT_Customer_Details__c objBTCustomerDetails = [SELECT Id FROM BT_Customer_Details__c];
        My_Address_Book__c addressObj = [SELECT Id FROM My_Address_Book__c LIMIT 1];
        BT_Payment_Method__c BTPaymentObj1 = new BT_Payment_Method__c();
        //BTPaymentObj.Name = 'Test Payment';
        BTPaymentObj1.Payment_Method_Token__c = 'dfggfsfdgfhsrfd';
        BTPaymentObj1.BT_Customer_Details__c = objBTCustomerDetails.Id;
        //BTPaymentObj.My_Address_Book__c = addressObj.Id;
        BTPaymentObj1.Default_Payment_Method__c = true;
        BTPaymentObj1.Is_In_My_Payment__c=true;
        BTPaymentObj1.Is_Vaulted__c=true;
        BTPaymentObj1.CC_Expiration_Month__c=08;
        BTPaymentObj1.CC_Expiration_Year__c=2022;
        insert BTPaymentObj1;
        User userObj = [SELECT Id From User limit 1];
        System.runAs(userObj) {
            //List<BT_Payment_Method__c> BTPaymentObj = [SELECT Id,Payment_Method_Token__c FROM BT_Payment_Method__c];
            Test.startTest();
            //B2B_CreditCardControllerMock.createDeleteResponse = true;
              try{
                 B2B_MyPaymentsController.getAddMyPayments();
                  B2B_MyPaymentsController.updateExpiredCardList();}
              catch (exception ex){}
            Test.stopTest();
        }
    }

    
    @isTest static void testDeletePaymentRecord2() {
        B2B_MyPaymentsController.deletePaymentRecord('a');
        User userObj = [SELECT Id From User limit 1];
        System.runAs(userObj) {
        B2B_MyPaymentsController.callClientTokenAPI=true;
             BT_Payment_Method__c BTPaymentObj1 = new BT_Payment_Method__c();
            B2B_MyPaymentsController.getAllMyPaymentsNew();
    }
    }
    
    //added by mathi
   
    @isTest 
    public static void testHostedFormSetup(){
        //webCart cr = [select id , DealerId__c from webCart limit 1];
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
        B2B_CreditCardControllerMock.createClientTokenResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;
       // B2B_CreditCardController.AUTHORIZATION_HEADER = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        B2B_MyPaymentsController.hostedFormSetup();
        B2B_MyPaymentsController.getStateAddressBook();
        test.StopTest();
    }
     @isTest
    public static void testCreateCustomerDetailsRecord(){
        Map<String, Object> dataUpdate = new Map<String, Object>();
        dataUpdate.put('legacyId', (Object)'456787543');
        //dataUpdate.put('customerId', (Object)'efgh54w56rtsdadsf');
        B2B_MyPaymentsController.createCustomerDetailsRecord(dataUpdate);  
    }   
    @isTest
    public static void testCreateCustomerDetailsRecord1(){
        Map<String, Object> dataUpdate = new Map<String, Object>();
        dataUpdate.put('legacyId', (Object)'456787543');
        dataUpdate.put('customerId', (Object)'efgh54w56rtsdadsf');
        B2B_MyPaymentsController.createCustomerDetailsRecord(null);  
    }
        @istest
    public Static void testProcessPayment(){
        map<String, object> custMap = new map<String, object>();
        //custMap.put('name' , (object)'test test');
        //custMap.put('email' , (object)'test@test.com');
        //custMap.put('phone' , (object)'1234567');
        //custMap.put('customerId' , (object)'23456534567');
        //custMap.put('isSaveNewPaymentMethod',true);
        
        custMap.put('', '');
        test.StartTest();
        B2B_CreditCardControllerMock.createErrorResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());  
        B2B_MyPaymentsController.createCustomer(null);
        test.stopTest();
    }
    //added by mathi to get negative coverage
        @istest
    public Static void testProcessPaymentnegative(){
        map<String, object> custMap = new map<String, object>();
        //custMap.put('name' , (object)'test test');
        //custMap.put('email' , (object)'test@test.com');
        //custMap.put('phone' , (object)'1234567');
        //custMap.put('customerId' , (object)'23456534567');
        //custMap.put('isSaveNewPaymentMethod',true);
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());  
        B2B_MyPaymentsController.createCustomer(custMap);
        test.stopTest();
    }
        @isTest
    public static void testCreateAddressRecord(){
        Map<String,object > m  = new Map<String,object > ();
        My_Address_Book__c address=B2B_TestDataFactory.createAddressBook1(true);
        m.put('id' , address.Id);
        m.put('email' , 'test@test.com');
        m.put('address1' , 'test');
        m.put('address2' , 'test');
        m.put('address' , 'test');
        m.put('state' , 'AL');
        m.put('zipCode' , '2345671');
        m.put('phone' , '1234567890');
        m.put('name' , 'test');
        m.put('city' , 'test');
        B2B_MyPaymentsController.createAddressRecord(m);
    }
      @istest
    public Static void testProcessPayment2(){
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId' , (object)'23456534567');
        custMap.put('isSaveNewPaymentMethod',true);
        custMap.put('city','Newyork');
        custMap.put('address1','4340 w dublin granville rd');
        custMap.put('state','oh');
        custMap.put('zipCode','43017');
        custMap.put('countryName','United States');
         custMap.put('address2','Pailayout');
        //order ord = [Select id from order limit 1];
        //webCart cr = [select id , DealerId__c from webCart limit 1];
        test.StartTest();
        B2B_CreditCardController.DATA_UPDATES = new Map<String, Object>();
        //B2B_CreditCardControllerMock.createErrorResponse = false;
        B2B_CreditCardControllerMock.createCustomerResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());  
       // B2B_MyPaymentsController.createCustomer(custMap);
        B2B_MyPaymentsController.processAddPayment('nounce' ,custMap ,  'Credit Card',True, True);
        //B2B_MyPaymentsController.processAddPayment('nounce' ,custMap ,  'PayPal', True, True);
        test.stopTest();
    }
    
    @istest
    public Static void testProcessPayment1(){
        try{
        User userObj = [SELECT Id From User limit 1];
        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , (object)'test test');
        custMap.put('email' , (object)'test@test.com');
        custMap.put('phone' , (object)'1234567');
        custMap.put('customerId' , (object)'23456534567');
        custMap.put('isSaveNewPaymentMethod',true);
        custMap.put('city','Newyork');
        custMap.put('address1','4340 w dublin granville rd');
        custMap.put('state','oh');
        custMap.put('zipCode','43017');
        custMap.put('countryName','United States');
         custMap.put('address2','Pailayout');
        //order ord = [Select id from order limit 1];
        //webCart cr = [select id , DealerId__c from webCart limit 1];
          System.runAs(userObj) {
        test.StartTest();
        B2B_CreditCardController.DATA_UPDATES = new Map<String, Object>();
        //B2B_CreditCardControllerMock.createErrorResponse = false;
        B2B_CreditCardControllerMock.createCustomerResponse = true;
        B2B_CreditCardControllerMock.blankStatusCode = false;
        Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());  
       // B2B_MyPaymentsController.createCustomer(custMap);
        B2B_MyPaymentsController.processAddPayment('nounce' ,custMap ,  'Credit Card',True, True);
        //B2B_MyPaymentsController.processAddPayment('nounce' ,custMap ,  'PayPal', True, True);
                B2B_MyPaymentsController.processAddPayment('nounce' ,null ,  'Credit Card',True, True);
        test.stopTest();
   
          }
            
    }
                   catch (exception ex){}
    }
   //added by mathi for coveringdeletepaymentelse
    @isTest static void testDeletePaymentRecordnegativetest() {
        User userObj = [SELECT Id From User limit 1];
        B2B_Custom_Settings__c cs = new B2B_Custom_Settings__c(Batch_Current_Brand__c = 'Honda');
        insert cs;
        
        List<BT_Payment_Method__c> BTPaymentObj = [SELECT Id,Payment_Method_Token__c FROM BT_Payment_Method__c];
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
           Order objOrder = new Order();
        objOrder.Name = 'Test Order';
        objOrder.cart__c = cart.Id;  
        objOrder.OrderedDate = System.now() ;//Added by saikiran to cover B2B_GetOrderInfo Test class
        objOrder.AccountId = acc1.Id;
        objOrder.Status = 'Draft';
        objOrder.IsPaymentReproccessing__c = false;
        objOrder.EffectiveDate = System.today().addDays(20);
        objOrder.BT_Transaction_Status__c = 'Authorized';
        objOrder.Updated_Order_Total__c = 90.0;
        objOrder.Billing_Email_Address_User_Email__c='test.org@honda.com';
        // below two line added by Soumya to cover B2B_GetOrderInfo Test class
        objOrder.BillingPostalCode='xyz';
        //objOrder.Type='Order Product';
        objorder.BillingEmailAddress='abc@honda.com';
        objOrder.Payment_Method_Token__c=BTPaymentObj[0].Payment_Method_Token__c;
        insert objOrder;
        System.runAs(userObj) {
            
            Test.startTest();
            B2B_BrainTreeTransactionResponse wr = new B2B_BrainTreeTransactionResponse();
            wr.status = 200;
            B2B_CreditCardControllerMock.createDeleteResponse = true;
            Test.setMock(HttpCalloutMock.class, new B2B_CreditCardControllerMock());
            B2B_MyPaymentsController.deletePaymentRecord(BTPaymentObj[0].id);
            Test.stopTest();
        }
    }
    
    
    
}
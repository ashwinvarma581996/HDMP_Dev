/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
public class RES_CreditCardController_Test {


    @testSetup static void setup() {


		User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != null AND isActive = true LIMIT 1];
		System.runAs(admin) {
            Res_TestDataFactory.setUpReservationTest() ;
        }

        List<Account> accounts = [SELECT id FROM Account LIMIT 1] ;
        List<WebStore> stores = [SELECT id FROM WebStore LIMIT 1] ;

        WebCart cart = [SELECT id FROM WebCart LIMIT 1] ;
        B2B_Custom_Settings__c b2b = new B2B_Custom_Settings__c( name = 'test', Default_Guest_Account__c = accounts[0].id ) ;
        insert b2b ;

        Order ord = Res_TestDataFactory.createOrder(accounts[0].Id, cart.Id);
        BT_Token_Details__c bToken = Res_TestDataFactory.createBTTokenDetails(accounts[0].Id );

        Res_TestDataFactory.createSession() ;

    }

    @isTest
    public static void testHostedFormSetup(){

        webCart cr = [select id , DealerId__c from webCart limit 1];

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RES_CreditCardControllerMock());
        RES_CreditCardControllerMock.createClientTokenResponse = true;
        RES_CreditCardController.hostedFormSetup(cr.Id);
        test.StopTest();
    }

    @istest
    public static void testRequestClientToken(){
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new RES_CreditCardControllerMock());
        RES_CreditCardControllerMock.createClientTokenResponse = true;
        RES_CreditCardController.requestClientToken('merchantId');
        test.StopTest();
    }

    @istest
    public Static void testProcessPayment(){

        Reservation_Contact2__c c = [SELECT id, First_Name__c, Last_Name__c, Email_Address__c, Phone_Number__c FROM Reservation_Contact2__c LIMIT 1] ;
        Reservation__c r = [SELECT id FROM Reservation__C LIMIT 1] ;
        webCart cr = [select id , DealerId__c from webCart limit 1];
        User u = [SELECT id FROM User WHERE Alias = 'gst' LIMIT 1] ;
        Account a = [SELECT id FROM Account LIMIT 1] ;
        Reservation_Session__c s = Res_TestDataFactory.createSession(u.id,c.id,a.id,r.id,cr.id) ;

        map<String, object> custMap = new map<String, object>();
        custMap.put('name' , c.First_Name__c + ' ' + c.Last_Name__c);
        custMap.put('email' , c.Email_Address__c);
        custMap.put('phone' , c.Phone_Number__c);


        order ord = [Select id from order limit 1];

        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new RES_CreditCardControllerMock());
        RES_CreditCardControllerMock.createCustomerResponse = true;
        Object rd = RES_CreditCardController.processPayment('nounce' ,custMap , cr.Id , ord.Id );
        test.stopTest();
        Map<String,Object> returnData = (Map<String,Object>) rd ;
        System.assert(returnData.get('success') == true, 'Expected success') ;
    }

    @istest
    public Static void testParseValutPaymentResponse(){
        test.StartTest();
        string jsonresponse = '{ "data" :  {"vaultPaymentMethod" :  {"paymentMethod": {"id":"test" , "verification" :  { "status" :"success" }  } }}}';
        Map<String,Object> rd = RES_CreditCardController.parseVaultPaymentResponse(jsonresponse);
        test.stopTest();
        Map<String,Object> returnData = (Map<String,Object>) rd ;
        System.assert( ((String) returnData.get('status')) == 'success', 'Expected success') ;
        System.assert( ((String) returnData.get('id')) == 'test', 'Expected test') ;
    }


    @istest
    public Static void testcreatePaymentId(){
        RES_CreditCardController.createPaymentDetailsRecord('test','test','test','test');
    }

    @istest
    public Static void testSubmitAuthorizationRequest(){
        map<string, object > testMap = new Map<String, object>();
        webCart cr = [select id , DealerId__c from webCart limit 1];
        Map<String,Object> params = new Map<String,Object>() ;
        params.put('cartId',cr.id) ;
        params.put('dataUpdates', new Map<String,Object>()) ;
        RES_CreditCardController.setMerchantAndDealerID(params);
        RES_CreditCardController.submitAuthorizationRequest('test' , 'test',testMap, params);
    }

    @isTest
    public static void testUpdateTransactionStatusOnOrder(){

        Map<String,object > m  = new Map<String,object > ();
        map<string, string> innerMap = new Map<String, String>();
        innerMap.put('email' , 'test@test.com');
        innerMap.put('address1' , 'test@test.com');
        innerMap.put('address2' , 'test@test.com');
        innerMap.put('city' , 'Test');
        innerMap.put('state' , 'NA');
        innerMap.put('zipCode' , '123456');
        innerMap.put('country' , 'India');
        innerMap.put('name' , 'testing');
        innerMap.put('phone' , '123456');

        m.put('customerData' , (object) innerMap);


        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new RES_CreditCardControllerMock());
        String ORDER_ID =  [Select id from order limit 1].Id;
        RES_CreditCardController.updateTransactionStatusOnOrder('Authorized', m,ORDER_ID);
        RES_CreditCardController.handleBraintreeError(m);
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
        Test.startTest();
        RES_CreditCardController.UpdateTokenInformation( m);
        Test.stopTest();
    }

    @istest
    public static void testFlagReservationAsComplete(){
        List<Reservation_Contact2__c> cs = [SELECT id, First_Name__c, Last_Name__c, Email_Address__c, Phone_Number__c FROM Reservation_Contact2__c LIMIT 1] ;
        Reservation_Contact2__c c = cs[0] ;
        Reservation__c r = [SELECT id FROM Reservation__C LIMIT 1] ;
        webCart cr = [select id , DealerId__c from webCart limit 1];
        User u = [SELECT id FROM User WHERE Alias = 'gst' LIMIT 1] ;
        Account a = [SELECT id FROM Account LIMIT 1] ;
        Reservation_Session__c s = Res_TestDataFactory.createSession(u.id,c.id,a.id,r.id,cr.id) ;

        test.startTest();
        RES_CreditCardController.flagReservationAsComplete(cr.id) ;
        test.stopTest();

        System.assert([SELECT Completed__c FROM Reservation__c WHERE id = :r.id][0].Completed__c == true, 'Expected completed reservation');

    }

    @isTest
    public static void testGetTaggingFields(){

        WebCart cart = [SELECT id FROM WebCart LIMIT 1] ;

        test.startTest();
        Reservation_Contact2__c c = [SELECT id, First_Name__c, Last_Name__c, Email_Address__c, Phone_Number__c FROM Reservation_Contact2__c LIMIT 1] ;
        Reservation__c r = [SELECT id FROM Reservation__C LIMIT 1] ;
        webCart cr = [select id , DealerId__c from webCart limit 1];
        User u = [SELECT id FROM User WHERE Alias = 'gst' LIMIT 1] ;
        Account a = [SELECT id FROM Account LIMIT 1] ;
        Reservation_Session__c s = Res_TestDataFactory.createSession(u.id,c.id,a.id,r.id,cr.id) ;
        Map<String,String> parameters = RES_CreditCardController.getTaggingFields(cart.id) ;
        test.stopTest() ;

        System.assert(parameters.size() == 5, 'Expected 5 fields. Received: ' + String.valueOf(parameters.size()) );

    }

    @isTest
    public static void testProcessBTReturn(){
        string input = '{ "transactionBT": { "type": "sale", "status": "authorized", "id": "4kppn0jw", "amount": "500.00" }, "status": 200, "merchantId": "n3gdfyqzgs28j8g3", "facilitatorDetails": { "sourcePaymentMethodToken": "94xjp2z", "oauthApplicationName": "Braintree Payment Service", "oauthApplicationClientId": "client_id$production$32m8grwfxg9c76mf" }, "facilitatedDetails": { "merchantName": "POST OAK ACURA", "merchantId": "n3gdfyqzgs28j8g3" }, "errorMessage": null }' ;

        Map<String,Object> dataUpdates = new Map<String,Object>() ;
        Map<String,Object> returnData = new Map<String,Object>() ;

        Test.startTest() ;

        RES_CreditCardController.processBTReturn(input,dataUpdates,returnData) ;

        Test.stopTest() ;

        System.assert( dataUpdates.get('authorizationId') == '4kppn0jw', 'Unexpected authorization Id') ;
        System.assert( returnData.get('authorizationId') == '4kppn0jw', 'Unexpected authorization Id') ;
        System.assert( dataUpdates.get('transactionStatus') == 'authorized', 'Unexpected authorization status') ;
        System.assert( returnData.get('success') == true, 'Unexpected transaction error' ) ;
        System.assert( dataUpdates.get('success') == true, 'Unexpected transaction error (dataUpdates)' ) ;

    }

    @isTest
    public static void testProcessBTReturnWithInsufficientFunds(){
        string input = '{"transactionBT":null,"status":400,"merchantId":null,"facilitatorDetails":null,"facilitatedDetails":null,"errorMessage":"\\"Insufficient Funds\\""}' ;

        Map<String,Object> dataUpdates = new Map<String,Object>() ;
        Map<String,Object> returnData = new Map<String,Object>() ;

        Test.startTest() ;

        RES_CreditCardController.processBTReturn(input,dataUpdates,returnData) ;

        Test.stopTest() ;

        System.assert( dataUpdates.get('error') == '"Insufficient Funds"', 'Unexpected error message: ' + dataUpdates.get('error') ) ;
        System.assert( returnData.get('success') == false, 'Unexpected transaction error' ) ;
        System.assert( dataUpdates.get('success') == false, 'Unexpected transaction error (dataUpdates)' ) ;
    }

    @isTest
    public static void testProcessBTReturnWithAuthError(){
        string input = '{"transactionBT":null,"status":400,"merchantId":null,"facilitatorDetails":null,"facilitatedDetails":null,"errorMessage":"\\"authenticationError\\""}' ;

        Map<String,Object> dataUpdates = new Map<String,Object>() ;
        Map<String,Object> returnData = new Map<String,Object>() ;

        Test.startTest() ;

        RES_CreditCardController.processBTReturn(input,dataUpdates,returnData) ;

        Test.stopTest() ;

        System.assert( dataUpdates.get('error') == '"authenticationError"', 'Unexpected error message: ' + dataUpdates.get('error') ) ;
        System.assert( returnData.get('success') == false, 'Unexpected transaction error' ) ;
        System.assert( dataUpdates.get('success') == false, 'Unexpected transaction error (dataUpdates)' ) ;
    }

    @isTest
    public static void testCompleteReservation(){

        Map<String,Object> state = new Map<String,Object>() ;

        state.put('cartId',[SELECT id FROM WebCart LIMIT 1][0].id) ;
        state.put('sessionId',[SELECT id FROM Reservation_Session__c LIMIT 1][0].id ) ;
        state.put('reservationId', [SELECT id FROM Reservation__c LIMIT 1][0].id ) ;
        state.put('reservationContactId',[SELECT id FROM Reservation_Contact2__c LIMIT 1][0].id) ;
        state.put('orderId',[SELECT id FROM Order LIMIT 1][0].id) ;
        state.put('dataUpdates', new Map<String,Object>()) ;
        ((Map<String,Object>)state.get('dataUpdates')).put('success',true) ;
        ((Map<String,Object>)state.get('dataUpdates')).put('authorizationId','123456') ;

        test.startTest() ;
        RES_CreditCardController.completeReservation(JSON.serialize(state)) ;
        test.stopTest() ;

        Reservation__c r = [SELECT id, completed__c, status__c, Approval_code__c FROM Reservation__c WHERE id = :String.valueof(state.get('reservationId'))] ;
        System.assert(r.Approval_Code__c == '123456', 'Unexpected approval code: ' + r.Approval_Code__c ) ;
        System.assert(r.Status__c == 'Deposit Made', 'Expected successful deposit') ;
        System.assert(r.Completed__c, 'Expected complete') ;
    }

    @IsTest
    public static void testCompleteReservationFailure(){
        Map<String,Object> state = new Map<String,Object>() ;

        state.put('cartId',[SELECT id FROM WebCart LIMIT 1][0].id) ;
        state.put('sessionId',[SELECT id FROM Reservation_Session__c LIMIT 1][0].id ) ;
        state.put('reservationId', [SELECT id FROM Reservation__c LIMIT 1][0].id ) ;
        state.put('reservationContactId',[SELECT id FROM Reservation_Contact2__c LIMIT 1][0].id) ;
        state.put('orderId',[SELECT id FROM Order LIMIT 1][0].id) ;
        state.put('dataUpdates', new Map<String,Object>()) ;
        ((Map<String,Object>)state.get('dataUpdates')).put('success',false) ;

        test.startTest() ;
        RES_CreditCardController.completeReservation(JSON.serialize(state)) ;
        test.stopTest() ;

        Reservation__c r = [SELECT id, completed__c, status__c, Approval_code__c FROM Reservation__c WHERE id = :String.valueof(state.get('reservationId'))] ;
        System.assert(r.Status__c == 'Deposit Failed', 'Unexpected approval' ) ;
        System.assert(!r.Completed__c, 'Expected incomplete') ;
    }
}
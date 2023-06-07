/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
global class RES_CreditCardControllerMock implements HttpCalloutMock {

    public static boolean createClientTokenResponse;
    public static boolean createCustomerResponse;
    global HTTPResponse respond(HTTPRequest request) {
        String reqBody = request.getBody();
        // Create a fake response
        HttpResponse response = new HttpResponse();
        System.debug('CCMock request: ' + request  ) ;
        System.debug('CCMock endpoint: ' + request.getEndpoint() ) ;
        response.setHeader('Content-Type', 'application/json');
        if ( reqBody.contains('vaultPaymentMethod'))
        {
            response.setBody('{ "data" :  {"vaultPaymentMethod" :  {"paymentMethod": {"id" : "123" } , "verification": {"status" : "123" } } } }');
            return response ;
        }
        if (request.getEndpoint().endsWith('transaction/pre-auth')) {
            String body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"authorized","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            response.setBody(body);
            response.setStatusCode(200);  
            System.debug('CCMock response: ' + response  ) ;
            return response ;
        }
        if (request.getEndpoint().endsWith('transaction/post-auth')) {
            String body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"submitted_for_settlement","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            response.setBody(body);
            response.setStatusCode(200);  
            return response ;
        }

        if (request.getEndpoint().contains('refreshed-tokens')) {
            String body ='{"status": 200,"merchantID": "x6q6b83wjsn28t2m","credentials": {"accessToken": "access_token$sandbox$x6q6b83wjsn28t2m$d648f8a9d4523e920c631bfa31065647","refreshToken": "refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130160a82ddf4ef9eec","tokenType": "bearer","expiresAt": "2021-07-06T09:13:40Z","scope": "read_write,shared_vault_transactions"}}'; 
            response.setBody(body);
            response.setStatusCode(200) ;
            return response ;
        }


        if(createClientTokenResponse == true || reqBody.contains('createClientToken')) {
   
            response.setBody('{ "data" :  {"createClientToken" :  {"createClientToken": {"createClientToken" : [ {"createClientToken":"test" , "clientToken" : "testing"}] } , "clientToken" : "testing"} }}');//  [ {"createClientToken":"test" , "clientToken" : "testing"}] }');
            return response;
        }
        if(createCustomerResponse || reqBody.contains('createClientToken')){
            response.setBody('{ "data" :  {"createCustomer" :  {"customer": {"id" : "123" } } }              }');
       
            return response;
        }
        return response;
    }
    
}
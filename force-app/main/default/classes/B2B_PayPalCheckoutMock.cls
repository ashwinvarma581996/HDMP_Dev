/**********************************************************************
Name: 		B2B_PayPalCheckoutMock
Purpose: 	Mock class for B2B_PayPalCheckoutController
Date: 		01/09/2022
Created by: Rajrishi Kaushik
*******************************************************************************
MODIFICATIONS – Date 		|	Dev Name		|	Method		|	User Story
********************************************************************************/
global class B2B_PayPalCheckoutMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest request) {
        String reqBody = request.getBody();
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        if(request.getEndpoint().endsWith('transaction/pre-auth')) {
            String body;
            if(reqBody.contains('testMerchantId')){
                body = '{"status":400,"errorMessage":"authenticationError"}';
            }else {
                body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"authorized","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            }            
            response.setBody(body);
        }else if(request.getEndpoint().endsWith('transaction/post-auth')) {
            String body;
            if(reqBody.contains('testPostAuthFailure')){
                body = '{"status":400,"errorMessage":"authenticationError"}';
            }else {
                body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"submitted_for_settlement","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            }
            response.setBody(body); 
        }else if(reqBody.contains('createCustomer')){
            response.setBody('{ "data" :  {"createCustomer" :  {"customer": {"id" : "123" }}}}');//  [ {"createClientToken":"test" , "clientToken" : "testing"}] }');            
        }else if(reqBody.contains('vaultPaymentMethod')){
            response.setBody('{ "data" :  {"vaultPaymentMethod" :  {"paymentMethod": {"id" : "123","legacyId" : "45654", "details" : {"last4" : "1111", "cardholderName": "raj", "expirationMonth": "12", "expirationYear": "22", "brandCode": "MASTERCARD", "uniqueNumberIdentifier": "dfgasdgf2345fd"} } , "verification": {"status" : "123" } } } }');           
        }
        
        response.setStatusCode(200);
        return response;
    }
}
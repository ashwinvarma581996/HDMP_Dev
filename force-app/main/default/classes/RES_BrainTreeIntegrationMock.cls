/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 10-27-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
//Date : 05/07/2021
//Created by : Apoorv Garg
//Description: Mock class for B2B_BrainTreeIntegration.cls

@isTest
global class RES_BrainTreeIntegrationMock implements HTTPCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        
        String reqBody = request.getBody();
        System.debug('body' + reqBody);
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        //Negative for AccessToken
        if(request.getEndpoint().contains('dadagdadh')) {
            String body ='{"status": 502,"errorMessage": "Gatway error"}';
            response.setBody(body);
            response.setStatusCode(502);
            response.setStatus('Gatway error');
        }
        
        //Positive for AccessToken
        else if (request.getEndpoint().contains('x6q6b83wjsn28t2m')) {
            String body ='{"status": 200,"merchantId": "x6q6b83wjsn28t2m","credentials": {"accessToken": "access_token$sandbox$x6q6b83wjsn28t2m$d648f8a9d4523e920c631bfa31065647","refreshToken": "refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130160a82ddf4ef9eec","tokenType": "bearer","expiresAt": "2021-07-06T09:13:40Z","scope": "read_write,shared_vault_transactions"}}';
            response.setBody(body); 
            response.setStatusCode(200); 
        }
        
        //Negative for RefreshToken
        if(request.getEndpoint().contains('agdadh')) {
            String body ='{"status": 502,"errorMessage": "Gatway error"}';
            response.setBody(body);
            response.setStatusCode(502); 
            response.setStatus('Gatway error');
        }
        
        //Positive for RefreshToken
        else if (request.getEndpoint().contains('x6q6b83wjsn28t2m')) {
            String body ='{"status": 200,"merchantID": "x6q6b83wjsn28t2m","credentials": {"accessToken": "access_token$sandbox$x6q6b83wjsn28t2m$d648f8a9d4523e920c631bfa31065647","refreshToken": "refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130160a82ddf4ef9eec","tokenType": "bearer","expiresAt": "2021-07-06T09:13:40Z","scope": "read_write,shared_vault_transactions"}}'; 
            response.setBody(body);
        }
        
        //Negative for PreAuth
        if(reqBody.contains('bbncbncnb')) {
            String body ='{"status":400,"errorMessage":"authenticationError"}';
            response.setBody(body); 
            response.setStatusCode(400); 
        }
        
        //Positive for PreAuth
        else if (request.getEndpoint().endsWith('transaction/pre-auth')) {
            String body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"authorized","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            response.setBody(body);
            response.setStatusCode(200);  
        }
        
        //Negative for PostAuth
        else if(reqBody.contains('ffsfsf'))
        {
            String body ='{"status":400,"errorMessage":"authenticationError"}';
            response.setBody(body); 
            response.setStatusCode(400); 
        }
        
        //Positive for PostAuth
        else if (request.getEndpoint().endsWith('transaction/post-auth')) {
            String body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"submitted_for_settlement","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            response.setBody(body);
            response.setStatusCode(200);  
        }
        
        //Negative for Refund
        else if(reqBody.contains('sfsjgf'))
        {
            String body = '{"status":400,"errorMessage":"authenticationError"}';
            response.setBody(body);
            response.setStatusCode(400); 
        }
        
        //Positive for Refund
        else if (request.getEndpoint().endsWith('transaction/refund')) {
            String body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"refunded","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            response.setBody(body);
            response.setStatusCode(200);  
        }
        
        //Negative for Void
        else if (reqBody.contains('sdfsfjsf')) {
            String body = '{"status":400,"errorMessage":"authenticationError"}';
            response.setBody(body);
            response.setStatusCode(400); 
        }
        
        //Positive for Void
        else if (request.getEndpoint().endsWith('transaction/void')) {
            String body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"Voided","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            response.setBody(body);
            response.setStatusCode(200); 
            response.setHeader('Content-Type', 'application/json');
        }
        
        return response;
    }
}
/*****************************************************************************
Name: 		B2B_BrainTreeIntegrationMock
Purpose: 	Mock class for BrainTreeIntegration
Date: 		10/22/2021
Created by: 
*******************************************************************************
MODIFICATIONS – Date 		|	Dev Name		|	Method		|	User Story
*******************************************************************************
	V1			08/06/2022	|	Ravi Prasad		|				|	
********************************************************************************/

global class B2B_CreditCardControllerMock implements HttpCalloutMock {
    
    public static boolean createClientTokenResponse;
    public static boolean createCustomerResponse;
    public static boolean createErrorResponse;
    public static boolean createDeleteResponse;
    public static boolean blankStatusCode;
    
    global HTTPResponse respond(HTTPRequest request) {
        String reqBody = request.getBody();
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        if(createClientTokenResponse == true && !blankStatusCode) {
            response.setStatusCode(200);
            response.setBody('{ "data" :  {"createClientToken" :  {"createClientToken": {"createClientToken" : [ {"createClientToken":"test" , "clientToken" : "testing"}] } , "clientToken" : "testing"} }}');//  [ {"createClientToken":"test" , "clientToken" : "testing"}] }');
            return response;
        }else if(createCustomerResponse == true && !blankStatusCode){
            response.setStatusCode(200);
            if(reqBody.contains('createCustomer')){
                response.setBody('{ "data" :  {"createCustomer" :  {"customer": {"id" : "123" }}}}');//  [ {"createClientToken":"test" , "clientToken" : "testing"}] }');            
            }else if(reqBody.contains('vaultPaymentMethod')){
                response.setBody('{ "data" :  {"vaultPaymentMethod" :  {"paymentMethod": {"id" : "123","legacyId" : "45654", "details" : {"last4" : "1111", "cardholderName": "raj", "expirationMonth": "12", "expirationYear": "22", "brandCode": "MASTERCARD", "uniqueNumberIdentifier": "dfgasdgf2345fd"} } , "verification": {"status" : "123" } } } }');           
            }
            return response;
        }else if(createCustomerResponse == true && blankStatusCode){
            if(reqBody.contains('createCustomer')){
                response.setBody('{ "data" :  {"createCustomer" :  {"customer": {"id" : "123" }}}}');//  [ {"createClientToken":"test" , "clientToken" : "testing"}] }');            
            }else if(reqBody.contains('vaultPaymentMethod')){
                response.setBody('{ "data" :  {"vaultPaymentMethod" :  {"paymentMethod": {"id" : "123","legacyId" : "45654", "details" : {"last4" : "1111", "cardholderName": "raj", "expirationMonth": "12", "expirationYear": "22", "brandCode": "MASTERCARD", "uniqueNumberIdentifier": "dfgasdgf2345fd"} } , "verification": {"status" : "123" } } } }');           
            }
            return response;
        }else if(createErrorResponse == true && !blankStatusCode){
            response.setStatusCode(200);
            if(reqBody.contains('createCustomer')){
                response.setBody('{ "data" :  {"createCustomer" :  {"customer": {"id" : "123" }}}}');//  [ {"createClientToken":"test" , "clientToken" : "testing"}] }');            
            }else if(reqBody.contains('vaultPaymentMethod')){
                response.setBody('{"errors": [{"message": "Credit card type is not accepted by this merchant account."}],"data": {"vaultPaymentMethod": {"verification": {"status" : "123","gatewayRejectionReason" : "AVS" } }}}');           
            }
            return response;
        }else if(createErrorResponse == true && blankStatusCode){
            if(reqBody.contains('createCustomer')){
                response.setBody('{ "data" :  {"createCustomer" :  {"customer": {"id" : "123" }}}}');//  [ {"createClientToken":"test" , "clientToken" : "testing"}] }');            
            }else if(reqBody.contains('vaultPaymentMethod')){
                response.setBody('{"errors": [{"message": "Credit card type is not accepted by this merchant account."}],"data": {"vaultPaymentMethod": {"verification": {"status" : "123","gatewayRejectionReason" : "AVS" } }}}');           
            }
            return response;
        }else if(createDeleteResponse == true){           
            response.setStatusCode(200);
            response.setBody('{ "data" :  {"deletePaymentMethodFromVault" :  "data"}}');
            return response;
        }else if(createClientTokenResponse == true && blankStatusCode){
            response.setBody('{ "data" :  {"createClientToken" :  {"createClientToken": {"createClientToken" : [ {"createClientToken":"test" , "clientToken" : "testing"}] } , "clientToken" : "testing"} }}');//  [ {"createClientToken":"test" , "clientToken" : "testing"}] }');
            return response;
        }
        return response;
    }
    
}
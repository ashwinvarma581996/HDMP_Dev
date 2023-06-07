@isTest
global class OwnSendAnEmailFormControllerTestMock implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest request){
		HTTPResponse res = new HTTPResponse();
        res.setBody('{"success" : "true"}');
        res.setStatusCode(200);
		if(request.getEndpoint().contains('oauth2/token')){
            String jsonString = '{\n'+
                '\t"access_token": "00D760000004cMU!ARQAQOxwocHcJjR618eMsNLvOlW8FMSu0Xf4rweV5nrnybEFwxODqTqjSKPK3UbMHoPMSBHTWIdjdjWw9xwhUJXym5uucQoR",\n'+
                '\t"instance_url": "https://crmshonda--sfull.sandbox.my.salesforce.com",\n'+
                '\t"id": "https://test.salesforce.com/id/00D760000004cMUEAY/00576000001GoJPAA0",\n'+
                '\t"token_type": "Bearer",\n'+
                '\t"issued_at": "1680765521041",\n'+
                '\t"signature": "nbnt9vP6hU4hyuEHyhSmJ1wSR8e99140OxqR738xb6w="\n'+
            '}';
			res.setBody(jsonString);
			res.setStatusCode(200);
		}
		return res;
	}
}
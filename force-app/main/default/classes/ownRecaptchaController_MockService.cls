@isTest
global class ownRecaptchaController_MockService implements HttpCalloutMock {
	
    global HTTPResponse respond(HTTPRequest req){
        
        String reqString = req.getBody();
        System.debug('ReqString ' + reqString);
        HttpResponse res = new HttpResponse(); 
        
        
        if(reqString.contains('StringTestPositive')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true}');
            res.setStatusCode(200);
        }
        else if(reqString.contains('StringTestFail')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"fail": false}');
            res.setStatusCode(200);
        }
        else{
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"fail": false}');
            res.setStatusCode(400);
        }
		
        return res;
        
    }


}
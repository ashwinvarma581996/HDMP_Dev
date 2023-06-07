@isTest
global class OwnProductServiceNotes_MockService implements HttpCalloutMock {
	
    global HTTPResponse respond(HTTPRequest req){
        
		String body = '55';
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
		res.setStatusCode(200);
        
        
        return res;
        
    }


}
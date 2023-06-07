@isTest
global class MockHttpResponseGeneratorexcp implements HttpCalloutMock {
    // Implement this interface method
   
    global HTTPResponse respond(HTTPRequest req) {
         Product2 prod1 = [SELECT Id, Name, STOCKKEEPINGUNIT FROM PRODUCT2 LIMIT 1];
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://inventorymanagerdemo.herokuapp.com/api/inventory/'+prod1.Id, req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(400);
        return res;
    }
    
}
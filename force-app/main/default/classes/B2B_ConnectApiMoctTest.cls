@isTest
global class B2B_ConnectApiMoctTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/xml');
        String reqBody = request.getBody();
        string body ='ConnectApi.CartSummary[buildVersion=51.0, accountId=0010100000NN7HSAA1, cartId=0a6010000000DfJAAU, currencyIsoCode=USD, grandTotalAmount=0.00, messagesSummary=ConnectApi.CartMessagesSummary[buildVersion=51.0, errorCount=0, hasErrors=false, limitedMessages=(), relatedEntityId=0a6010000000DfNAAU, totalLineItemsWithErrors=0], name=Cart, ownerId=00501000001s2WCAAY, purchaseOrderNumber=null, status=Active, totalChargeAmount=0.00, totalListPrice=0.00, totalProductAmount=0.00, totalProductCount=2, totalTaxAmount=0.00, type=Cart, uniqueProductCount=0, webstoreId=0ZE010000004ESbGAM]';
            response.setStatusCode(200);
                response.setBody(body); 
        return response; 
    }


}
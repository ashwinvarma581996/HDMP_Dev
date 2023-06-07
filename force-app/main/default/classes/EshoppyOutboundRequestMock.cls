/* Apex Class Name       :    EshoppyOutboundRequestMock
* @description        	 :    Mock Callout Class for EshoppyOutboundRequest
* Modification Log   	 :* ---------------------------------------------------------------------------
* Developer                   Date                   Description
* ---------------------------------------------------------------------------
* Spoorthi               14 Mar 2022              Created
*********************************************************************************/
/**
* @description EshoppyOutboundRequestMock
**/

public class EshoppyOutboundRequestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        String jsonResposne = '{';
        jsonResposne+='"Body": "",';
        jsonResposne+='"Header": {';
        jsonResposne+='"Code": "200",';
        jsonResposne+='"Status": "Success",';
        jsonResposne+='"Errors": null';
        jsonResposne+='}';
        jsonResposne+='}';
        response.setBody(jsonResposne);
        response.setStatusCode(200);
        return response; 
    }
}
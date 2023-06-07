/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 10-28-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
//Date : 05/07/2021
//Created by : Apoorv Garg
//Description: Mock class for B2B_BrainTreeIntegration.cls

@isTest
global class Res_LeadService_Mock implements HTTPCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"Status":"Submitted","ApplicantNumber":"15359877","SessionId":"90de0a98-8ccc-4549-abdf-3e053e5dd033"}')   ;
        response.setStatusCode(201) ;
        response.setStatus('Created') ;
        return response;
    }
}
//****************************************************************************** 
// File Name:       OwnHttpCalloutServiceTest.cls
// Summary:         Apex Class for Garage
// Created On:      27-12-2021
// Created By:      Arunprasad N (Wipro)
// Data I/O:        
// Honda Jira Story: Apex class for API of Honda MyGarage Experience
//===============================================================================
// Modification Log: 
// December 27, 2021 Arunprasad N (Wipro) initial coding 
// December 27, 2021 Sai Kotu (Wipro) added test methods
//*******************************************************************************

@isTest
public class OwnHttpCalloutServiceTest {
    @testsetup
    static void testSetup(){
        Profile adm = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole role1 = [SELECT Id FROM UserRole WHERE Name = 'Honda Owner' LIMIT 1];
        User testUserAdmin = new User (
            FirstName='admin',
            LastName='user',
            Alias = 'admin',
            Email = 'admin1@test.com',
            Username =  System.now().millisecond() + 'admin1@test.com',
            ProfileId = adm.Id,
            UserRoleId = role1.Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert testUserAdmin;
    }
    
    @isTest
    static void OwnHttpCalloutServiceTest(){
        List<String> endpointParameters = new List<String>{'2022', 'Odyssey'};
            OwnHttpCalloutService service = new OwnHttpCalloutService();
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'A';
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            service = new OwnHttpCalloutService('FeatureListByModel', attribute, endpointParameters);
        }
        System.assertEquals(true, service.getEndpointURL().contains('FeatureList'));
        System.assertEquals('GET', service.getRequestMethod());
    }
    @isTest
    static void InitializeTest(){
        List<String> endpointParameters = new List<String>{'2022', 'Odyssey'};
            OwnHttpCalloutService service = new OwnHttpCalloutService();
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'A';
        attribute.modelId='Test';
        attribute.carrierId='Test';
        attribute.manufacturerId='Test';
        attribute.phoneId='Test';
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            service = new OwnHttpCalloutService('FeaturesByPhone', attribute, endpointParameters);
        }
        System.assertEquals(true, service.getEndpointURL().contains('GetFeatures'));
        System.assertEquals('POST', service.getRequestMethod());
    }
    @isTest
    static void OwnHttpCalloutServiceAcuraTest(){
        List<String> endpointParameters = new List<String>{'2022', 'MDX'};
            OwnHttpCalloutService service = new OwnHttpCalloutService();
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'B';
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            service = new OwnHttpCalloutService('FeatureListByModel', attribute, endpointParameters);
        }        
        System.assertEquals(true, service.getEndpointURL().contains('FeatureList'));
        System.assertEquals('GET', service.getRequestMethod());
        
    }
    
    @isTest
    static void setEndpointURLTest(){
        OwnHttpCalloutService service = new OwnHttpCalloutService();
        service.setEndpointURL('https://test.com');        
        System.assertEquals(true, service.getEndpointURL().contains('test'));
    }
    
    @isTest
    static void setRequestMethodTest(){
        OwnHttpCalloutService service = new OwnHttpCalloutService();
        service.setRequestMethod('GET');        
        System.assertEquals('GET', service.getRequestMethod());
    }
    
    @isTest
    static void setURLParameterTest(){
        OwnHttpCalloutService service = new OwnHttpCalloutService();
        Map<String, String> paraMap=new  Map<String, String>();
        service.setURLParameter('id','123'); 
        service.setURLParameter('name',''); 
        System.assertEquals('123', service.getURLParameter('id'));
        paraMap=service.getURLParameters();
        System.assertEquals(false, string.isNotEmpty(paraMap.get('name')));
        service.removeURLParameter('name');
        paraMap=service.getURLParameters();
        if(paraMap.containsKey('name')){
            System.assert(false,'name is not removed from header map');
        }else{
            System.assert(true,'name is removed from header map');
        }
    }
    
    @isTest
    static void setHeaderParameterTest(){
        OwnHttpCalloutService service = new OwnHttpCalloutService();
        Map<String, String> headerMap=new  Map<String, String>();
        service.setHeaderParameter('id','123'); 
        service.setHeaderParameter('name','Sai1123'); 
        System.assertEquals('123', service.getHeaderParameter('id'));
        headerMap=service.getHeaderParameters();
        System.assertEquals('Sai1123', headerMap.get('name'));
        service.removeHeaderParameter('id');
        headerMap=service.getHeaderParameters();
        if(headerMap.containsKey('id')){
            System.assert(false,'id is not removed from header map');
        }else{
            System.assert(true,'id is removed from header map');
        }
    }
    @isTest
    static void setRequestBodyTest(){
        OwnHttpCalloutService service = new OwnHttpCalloutService();
        String requestBody='{"id": "123","name" : "sai12234"}';
        service.setRequestBody(requestBody);
        String body=service.getRequestBody();
        System.assertEquals(true, body.contains('sai12234'));
    }
    
    @isTest
    static void setCalloutMetadataTest(){
        OwnHttpCalloutService service = new OwnHttpCalloutService();
        OwnAPIConfiguration__mdt calloutMetadata;
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            calloutMetadata = [
                SELECT Id, MasterLabel, DeveloperName, Method__c, URLParameters__c, HeaderParameters__c, Endpoint__c,
                Body__c
                FROM OwnAPIConfiguration__mdt
                WHERE DeveloperName ='PhoneDataByModelId'
            ];
        }
        service.setCalloutMetadata(calloutMetadata);
        calloutMetadata= service.getCalloutMetadata();
        System.assertEquals('POST',calloutMetadata.Method__c);
    }
    
    
    @isTest
    static void getGUIDTest(){
        System.assertEquals(true, OwnHttpCalloutService.getGUID() != null);
    }
    
    @isTest
    static void HeaderTest(){
        OwnHttpCalloutService.Header h=new OwnHttpCalloutService.Header('key','value','type');
            System.assertEquals('key',h.key);
    }    
    @isTest
    static void sendRequestTest(){
        List<String> endpointParameters = new List<String>();
        OwnHttpCalloutService service=new OwnHttpCalloutService();
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'B';
        attribute.modelId = 'YD9H4NKNW';
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        HTTPResponse res=new HTTPResponse(); 
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            service = new OwnHttpCalloutService('PhoneDataByModelId', attribute, endpointParameters);
            Test.startTest();
            res=service.sendRequest();
            Test.stopTest();
        }
        System.assertEquals(true, res.getBody().contains('ATT'));
        System.assertEquals(200, res.getStatusCode());
    }
    
    @isTest
    static void sendRequestTest2(){
        List<String> endpointParameters = new List<String>();
        OwnHttpCalloutService service=new OwnHttpCalloutService();
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'B';
        attribute.modelId = 'YD9H4NKNW';
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        HTTPResponse res=new HTTPResponse(); 
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            service = new OwnHttpCalloutService('PhoneDataByModelId', attribute, endpointParameters);
            HTTPRequest req=service.getRequest();
            Test.startTest();
            res=service.sendRequest(req);
            Test.stopTest();
        }
        System.assertEquals(true, res.getBody().contains('ATT'));
        System.assertEquals(200, res.getStatusCode());
    }
}
//****************************************************************************** 
// File Name:       OwnSpecificationsController.cls
// Summary:         Apex Class for Garage 
// Created On:      10-18-2021
// Created By:      Arunprasad N (Wipro)
// Test Classes:    OwnSpecificationsControllerTest.cls
// Data I/O:        
// Honda Jira Story: Apex class for API of Honda MyGarage Experience
//===============================================================================
// Modification Log: 
// July 07, 2022 Arunprasad N (Wipro) initial coding
//*******************************************************************************
public without sharing class OwnSpecificationsController {


//Powersport Motorcycle Get Specifications
@AuraEnabled
public static String getSpecificationsByModelID(String modID, String divisionId){
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    Http http = new Http();
    String returnXML;

    Xmlstreamwriter xmlW = new Xmlstreamwriter();

    //create XML 
    xmlW.writeStartDocument('utf-8','1.0');
        //mit
        xmlW.writeStartElement(null,'mit',null);
            xmlW.writeAttribute(null,null,'mit_version_number','1');
            xmlW.writeAttribute(null,null,'mit_version_date','2018-04-12');	

            xmlW.writeStartElement(null,'client_info', null);
            if(divisionId == 'A' || divisionId == 'B'){
                //xmlW.writeAttribute(null,null,'application_id','ownerportal.honda.com');
                xmlW.writeAttribute(null,null,'application_id','mygarage.honda.com');
            }else if(divisionId=='M'){
                //xmlW.writeAttribute(null,null,'application_id','powersports.honda.com');
                xmlW.writeAttribute(null,null,'application_id','mygarage.honda.com');
            }
                xmlW.writeAttribute(null,null,'echo_input','true');
                xmlW.writeAttribute(null,null,'server_ip','test');
                xmlW.writeAttribute(null,null,'session_id','test');
                if(divisionId == 'A' || divisionId == 'B'){
                    //xmlW.writeAttribute(null,null,'domain','dev.ownerportal.honda.com');
                    xmlW.writeAttribute(null,null,'domain','mygarage.honda.com');
                }else if(divisionId=='M'){
                    //xmlW.writeAttribute(null,null,'domain','prestage2.powersports.honda.com');
                    xmlW.writeAttribute(null,null,'domain','mygarage.honda.com');
                }
                //xmlW.writeAttribute(null,null,'environment','prestage');
                xmlW.writeAttribute(null,null,'environment','production');
                xmlW.writeEndElement();

            xmlW.writeStartElement(null,'input_parameters',null);
                    xmlW.writeStartElement(null,'required',null);
                        xmlW.writeStartElement(null,'source_cd',null);
                            if(divisionId == 'A' || divisionId == 'B'){
                                xmlW.writeCharacters('HONDA');
                            }else if(divisionId=='M'){
                                xmlW.writeCharacters('MOTORCYCLE');
                            }
                        xmlW.writeEndElement(); //Close source_cd
                        xmlW.writeStartElement(null,'site_cd',null);
                            if(divisionId == 'A' || divisionId == 'B'){
                                xmlW.writeCharacters('HONDA');
                            }else if(divisionId=='M'){
                                xmlW.writeCharacters('MOTORCYCLE');
                            }
                        xmlW.writeEndElement(); //Close site_cd
                        xmlW.writeStartElement(null,'category_cd',null);
                            xmlW.writeCharacters('CONFIG');
                        xmlW.writeEndElement(); //Close category_cd
                        xmlW.writeStartElement(null,'division',null);
                            xmlW.writeAttribute(null,null,'version_num','0');
                            if(divisionId == 'A' || divisionId == 'B'){
                                xmlW.writeCharacters(divisionId);
                            }else if(divisionId=='M'){
                                xmlW.writeCharacters(divisionId);
                            }
                        xmlW.writeEndElement(); //Close division
                        xmlW.writeStartElement(null,'models',null);
                            xmlW.writeStartElement(null,'model', null);
                                xmlW.writeAttribute(null, null,'id',modID);
                            xmlW.writeEndElement(); //close model
                        xmlW.writeEndElement(); //close models 
                    xmlW.writeEndElement(); //Close required
            xmlW.writeEndElement(); //Close input_parameters
            
            xmlW.writeStartElement(null,'private',null);
                xmlW.writeStartElement(null,'template_info',null);
                    xmlW.writeAttribute(null, null,'filename','FeaturesSpecifications-GetSpecificationsByModel-MIT.xml');
                    xmlW.writeAttribute(null, null,'xsd','FeaturesSpecifications-GetSpecificationsByModel-MIT.xsd');
                    xmlW.writeAttribute(null, null,'class','FeaturesSpecifications');
                    xmlW.writeAttribute(null, null,'method','GetSpecificationsByModel');
                xmlW.writeEndElement(); //Close template_info

                xmlW.writeStartElement(null,'stored_procedure',null);
                    xmlW.writeAttribute(null, null,'name','ecnetsp_FeaturesSpecifications-GetSpecificationsByModel');
                xmlW.writeEndElement(); //Close stored_procedure
            xmlW.writeEndElement(); //Close private

        xmlW.writeEndElement(); //Close mit
    xmlW.writeEndDocument(); //Close XML document

    String xmlStringxmlRes = xmlW.getXmlString();
    System.debug('The XML :'+xmlW.getXmlString());     
    string test = xmlW.getXmlString();
    System.debug('test :' + test);    
    xmlW.close();

    OwnAPIController.setJWTAccessToken();
    List<String> endpointParameters = new List<String>();
    OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
    attribute.divisionId = divisionId;
    attribute.requestBody = test;
    OwnHttpCalloutService service = new OwnHttpCalloutService('GetSpecificationsByModel', attribute, endpointParameters);
    String response = service.sendRequest().getBody();
    if(String.isBlank(response)){
        //OwnAPIController.setJWTAccessTokenToNULL();
    }
    System.debug('response'+response);
    return response;

    /*req.setEndpoint('https://ws-qa4.hondaweb.com/REST/B2C/GetSpecificationsByModel/1.0?appid=ownerportal.honda.com');
    req.setMethod('POST');
    req.setBody(test);
    req.setHeader('Authorization', 'Bearer ' + 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJDbGllbnRBcHBsaWNhdGlvbklEIjoib3duZXJwb3J0YWwuaG9uZGEuY29tIiwiQ2xpZW50RG9tYWluIjoidGVzdC5vd25lcnBvcnRhbC5ob25kYS5jb20iLCJUb2tlbklEIjoiMTYxNzMwMTg0MjI5MSIsImlzcyI6ImVjb25maWcuc2VydmljZXMuaG9uZGEuY29tIiwiYXVkIjoidGVzdF90ZXN0LmVjb25maWcyLnNlcnZpY2VzLmhvbmRhLmNvbSJ9.0DnYZZ7iCnR7jW7KVSCzYdedFxvydKQWocgfH327On8');
    req.setHeader('Content-Type', 'application/xml');
    req.setHeader('Accept', 'application/xml');
    req.setHeader('ClientDomain', 'test.ownerportal.honda.com');  
    req.setHeader('X-Honda-wl-authorization', 'Basic c2VydmljZV9vd25lcnNfYjJjX3FhOkZlZXQkNzcx');  
    req.setHeader('hondaHeaderType.messageId', '82eee037-784e-47aa-9b1a-00be9cc5e5f4');  
    req.setHeader('hondaHeaderType.siteId', '00e0e97f0fb543208a918fc946dea334');
    //req.setHeader('hondaHeaderType.collectedTimestamp', '2012-01-01T14:02:41.548-05:00');  
    req.setCompressed(false); // otherwise we hit a limit of 32000

    try {
        res = http.send(req);
    } catch(System.CalloutException e) {
        System.debug('Callout error: '+ e);
        System.debug(res.getBody());
    }

    if(res != null){
        //System.debug('Res Body' + res.getBody());
        returnXML = res.getBody();
    }
    return returnXML;*/
}

@AuraEnabled
public static String getAutoSpecificationsByModelId(String modelId, String divisionId){
    try{
        String responseSpec;
        List<String> endpointParameters = new List<String>{};
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = divisionId;
        attribute.modelId = modelId;
        SpecificationCompleteDetails specCompleteDetails;
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            specCompleteDetails = (SpecificationCompleteDetails)sessionPart.get('SpecCompDetail' + modelId + divisionId + userId);
        }
        if(specCompleteDetails == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('GetModelCompleteDetails', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            OwnAPIController.Error error = (OwnAPIController.Error)JSON.deserialize(response, OwnAPIController.Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                OwnAPIController.setJWTAccessTokenToNULL();
            }
            System.debug('@@response'+response);
            System.debug('@@response'+service.sendRequest().getStatusCode());
            response=response.replace('@id','id');
            response=response.replace('@name','name');
            response=response.replace('@type_cd','type_cd');
            response=response.replace('@description','description');
            response=response.replace('@path','path');
            
            specCompleteDetails = (SpecificationCompleteDetails)JSON.deserialize(response, SpecificationCompleteDetails.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('SpecCompDetail' + modelId + divisionId + userId, specCompleteDetails);
            }
        }
            List<AssetSpec> assets = new List<AssetSpec>();
            String endpoint = '';
            if(specCompleteDetails.mot != null && specCompleteDetails.mot.db_results != null){
                assets = specCompleteDetails.mot.db_results.assets.asset;
                for (AssetSpec asset : assets) {
                    endpoint = asset.path;
                    break;
                }
            }
            //endpoint = 'https://owners.honda.com/assets/OWNERLINK/Model/Content/hondaModelSpecs/2017/Accord%20Hybrid_EX-L_Specifications.xml';
            if(endpoint != ''){
                endpoint = 'https://owners.honda.com/assets/' + endpoint;
                endpoint = endpoint.replace(' ','%20');
                // Get the XML document from the external server
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('GET');
                HttpResponse res = http.send(req);
                // Log the XML content
                System.debug(res.getBody());
                if(res.getStatusCode() == 200){
                    responseSpec = res.getBody();
                }
            }
        
        return responseSpec;
    }catch(Exception e){
        System.debug('Exception--->'+ e.getMessage());
        System.debug('Exception--->'+ e.getStackTraceString());
        return e.getMessage();
    }  
}

public class SpecificationCompleteDetails{
    public MOTSpec mot {get;set;}
}
public class MOTSpec {
    public DBResult db_results {get;set;}
}
public class DBResult {
    public AssetsSpec assets {get;set;}
}
public class AssetsSpec {
    public List<AssetSpec> asset {get;set;}
}
public class AssetSpec {
    @AuraEnabled public String id {get;set;}	//1363302
    @AuraEnabled public String type_cd {get;set;}	//OWNERMAN
    @AuraEnabled public String name {get;set;}	//2021 Recon (TRX250TM) Owner's Manual
    @AuraEnabled public String description {get;set;}	//2021 Recon (TRX250TM) Owner's Manual
    @AuraEnabled public String path {get;set;}	///documentum/MWOM/ml.remawmom.2021_31hs0650_trx250tm_recon.pdf
}


//Honda Get Specifications
@AuraEnabled
public static String getSpecificationsByModelID_Honda(String modID){
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    Http http = new Http();
    String returnXML;

    Xmlstreamwriter xmlW = new Xmlstreamwriter();

    //create XML 
    xmlW.writeStartDocument('utf-8','1.0');
        //mit
        xmlW.writeStartElement(null,'mit',null);
            xmlW.writeAttribute(null,null,'mit_version_number','1');
            xmlW.writeAttribute(null,null,'mit_version_date','2018-04-12');	

            xmlW.writeStartElement(null,'client_info', null);
                xmlW.writeAttribute(null,null,'application_id','ownerportal.honda.com');
                xmlW.writeAttribute(null,null,'echo_input','true');
                xmlW.writeAttribute(null,null,'server_ip','test');
                xmlW.writeAttribute(null,null,'session_id','test');
                xmlW.writeAttribute(null,null,'domain','dev.ownerportal.honda.com');
                xmlW.writeAttribute(null,null,'environment','prestage');
                xmlW.writeEndElement();
                
            xmlW.writeStartElement(null,'input_parameters',null);
                    xmlW.writeStartElement(null,'required',null);
                        xmlW.writeStartElement(null,'source_cd',null);
                            xmlW.writeCharacters('HONDA');
                        xmlW.writeEndElement(); //Close source_cd
                        xmlW.writeStartElement(null,'site_cd',null);
                            xmlW.writeCharacters('HONDA');
                        xmlW.writeEndElement(); //Close site_cd
                        xmlW.writeStartElement(null,'category_cd',null);
                            xmlW.writeCharacters('CONFIG');
                        xmlW.writeEndElement(); //Close category_cd
                        xmlW.writeStartElement(null,'division',null);
                            xmlW.writeAttribute(null,null,'version_num','0');
                            xmlW.writeCharacters('A');
                        xmlW.writeEndElement(); //Close division
                        xmlW.writeStartElement(null,'models',null);
                            xmlW.writeStartElement(null,'model', null);
                                xmlW.writeAttribute(null, null,'id','SXS10M3J');
                            xmlW.writeEndElement(); //close model
                        xmlW.writeEndElement(); //close models 
                    xmlW.writeEndElement(); //Close required
            xmlW.writeEndElement(); //Close input_parameters
            
            xmlW.writeStartElement(null,'private',null);
                xmlW.writeStartElement(null,'template_info',null);
                    xmlW.writeAttribute(null, null,'filename','FeaturesSpecifications-GetSpecificationsByModel-MIT.xml');
                    xmlW.writeAttribute(null, null,'xsd','FeaturesSpecifications-GetSpecificationsByModel-MIT.xsd');
                    xmlW.writeAttribute(null, null,'class','FeaturesSpecifications');
                    xmlW.writeAttribute(null, null,'method','GetSpecificationsByModel');
                xmlW.writeEndElement(); //Close template_info

                xmlW.writeStartElement(null,'stored_procedure',null);
                    xmlW.writeAttribute(null, null,'name','ecnetsp_FeaturesSpecifications-GetSpecificationsByModel');
                xmlW.writeEndElement(); //Close stored_procedure
            xmlW.writeEndElement(); //Close private

        xmlW.writeEndElement(); //Close mit
    xmlW.writeEndDocument(); //Close XML document

    String xmlStringxmlRes = xmlW.getXmlString();
    System.debug('The XML :'+xmlW.getXmlString());     
    string test = xmlW.getXmlString();
    System.debug('test :' + test);    
    xmlW.close();

    req.setEndpoint('https://ws-qa4.hondaweb.com/REST/B2C/GetSpecificationsByModel/1.0?appid=ownerportal.honda.com');
    req.setMethod('POST');
    req.setBody(test);
    req.setHeader('Authorization', 'Bearer ' + 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJDbGllbnRBcHBsaWNhdGlvbklEIjoib3duZXJwb3J0YWwuaG9uZGEuY29tIiwiQ2xpZW50RG9tYWluIjoidGVzdC5vd25lcnBvcnRhbC5ob25kYS5jb20iLCJUb2tlbklEIjoiMTYxNzMwMTg0MjI5MSIsImlzcyI6ImVjb25maWcuc2VydmljZXMuaG9uZGEuY29tIiwiYXVkIjoidGVzdF90ZXN0LmVjb25maWcyLnNlcnZpY2VzLmhvbmRhLmNvbSJ9.0DnYZZ7iCnR7jW7KVSCzYdedFxvydKQWocgfH327On8');
    req.setHeader('Content-Type', 'application/xml');
    req.setHeader('Accept', 'application/xml');
    req.setHeader('ClientDomain', 'test.ownerportal.honda.com');  
    req.setHeader('X-Honda-wl-authorization', 'Basic c2VydmljZV9vd25lcnNfYjJjX3FhOkZlZXQkNzcx');  
    req.setHeader('hondaHeaderType.messageId', '82eee037-784e-47aa-9b1a-00be9cc5e5f4');  
    req.setHeader('hondaHeaderType.siteId', '00e0e97f0fb543208a918fc946dea334');
    //req.setHeader('hondaHeaderType.collectedTimestamp', '2012-01-01T14:02:41.548-05:00');  
    req.setCompressed(false); // otherwise we hit a limit of 32000

    try {
        res = http.send(req);
    } catch(System.CalloutException e) {
        System.debug('Callout error: '+ e);
        System.debug(res.getBody());
    }

    if(res != null){
        //System.debug('Res Body' + res.getBody());
        returnXML = res.getBody();
    }
    return returnXML;
}

@AuraEnabled
public static String getSpecificationsByModelID_Acura(String modID){
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();
    Http http = new Http();
    String returnXML;

    Xmlstreamwriter xmlW = new Xmlstreamwriter();

    //create XML 
    xmlW.writeStartDocument('utf-8','1.0');
        //mit
        xmlW.writeStartElement(null,'mit',null);
            xmlW.writeAttribute(null,null,'mit_version_number','1');
            xmlW.writeAttribute(null,null,'mit_version_date','2018-04-12');	

            xmlW.writeStartElement(null,'client_info', null);
                xmlW.writeAttribute(null,null,'application_id','ownerportal.honda.com');
                xmlW.writeAttribute(null,null,'echo_input','true');
                xmlW.writeAttribute(null,null,'server_ip','test');
                xmlW.writeAttribute(null,null,'session_id','test');
                xmlW.writeAttribute(null,null,'domain','dev.ownerportal.honda.com');
                xmlW.writeAttribute(null,null,'environment','prestage');
                xmlW.writeEndElement();
                
            xmlW.writeStartElement(null,'input_parameters',null);
                    xmlW.writeStartElement(null,'required',null);
                        xmlW.writeStartElement(null,'source_cd',null);
                            xmlW.writeCharacters('ACURA');
                        xmlW.writeEndElement(); //Close source_cd
                        xmlW.writeStartElement(null,'site_cd',null);
                            xmlW.writeCharacters('ACURA');
                        xmlW.writeEndElement(); //Close site_cd
                        xmlW.writeStartElement(null,'category_cd',null);
                            xmlW.writeCharacters('CONFIG');
                        xmlW.writeEndElement(); //Close category_cd
                        xmlW.writeStartElement(null,'division',null);
                            xmlW.writeAttribute(null,null,'version_num','0');
                            xmlW.writeCharacters('B');
                        xmlW.writeEndElement(); //Close division
                        xmlW.writeStartElement(null,'models',null);
                            xmlW.writeStartElement(null,'model', null);
                                xmlW.writeAttribute(null, null,'id',modID);
                            xmlW.writeEndElement(); //close model
                        xmlW.writeEndElement(); //close models 
                    xmlW.writeEndElement(); //Close required
            xmlW.writeEndElement(); //Close input_parameters
            
            xmlW.writeStartElement(null,'private',null);
                xmlW.writeStartElement(null,'template_info',null);
                    xmlW.writeAttribute(null, null,'filename','FeaturesSpecifications-GetSpecificationsByModel-MIT.xml');
                    xmlW.writeAttribute(null, null,'xsd','FeaturesSpecifications-GetSpecificationsByModel-MIT.xsd');
                    xmlW.writeAttribute(null, null,'class','FeaturesSpecifications');
                    xmlW.writeAttribute(null, null,'method','GetSpecificationsByModel');
                xmlW.writeEndElement(); //Close template_info

                xmlW.writeStartElement(null,'stored_procedure',null);
                    xmlW.writeAttribute(null, null,'name','ecnetsp_FeaturesSpecifications-GetSpecificationsByModel');
                xmlW.writeEndElement(); //Close stored_procedure
            xmlW.writeEndElement(); //Close private

        xmlW.writeEndElement(); //Close mit
    xmlW.writeEndDocument(); //Close XML document

    String xmlStringxmlRes = xmlW.getXmlString();
    System.debug('The XML :'+xmlW.getXmlString());     
    string test = xmlW.getXmlString();
    System.debug('test :' + test);    
    xmlW.close();

    req.setEndpoint('https://ws-qa4.hondaweb.com/REST/B2C/GetSpecificationsByModel/1.0?appid=ownerportal.honda.com');
    req.setMethod('POST');
    req.setBody(test);
    req.setHeader('Authorization', 'Bearer ' + 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJDbGllbnRBcHBsaWNhdGlvbklEIjoib3duZXJwb3J0YWwuaG9uZGEuY29tIiwiQ2xpZW50RG9tYWluIjoidGVzdC5vd25lcnBvcnRhbC5ob25kYS5jb20iLCJUb2tlbklEIjoiMTYxNzMwMTg0MjI5MSIsImlzcyI6ImVjb25maWcuc2VydmljZXMuaG9uZGEuY29tIiwiYXVkIjoidGVzdF90ZXN0LmVjb25maWcyLnNlcnZpY2VzLmhvbmRhLmNvbSJ9.0DnYZZ7iCnR7jW7KVSCzYdedFxvydKQWocgfH327On8');
    req.setHeader('Content-Type', 'application/xml');
    req.setHeader('Accept', 'application/xml');
    req.setHeader('ClientDomain', 'test.ownerportal.honda.com');  
    req.setHeader('X-Honda-wl-authorization', 'Basic c2VydmljZV9vd25lcnNfYjJjX3FhOkZlZXQkNzcx');  
    req.setHeader('hondaHeaderType.messageId', '82eee037-784e-47aa-9b1a-00be9cc5e5f4');  
    req.setHeader('hondaHeaderType.siteId', '00e0e97f0fb543208a918fc946dea334');
    //req.setHeader('hondaHeaderType.collectedTimestamp', '2012-01-01T14:02:41.548-05:00');  
    req.setCompressed(false); // otherwise we hit a limit of 32000

    try {
        res = http.send(req);
        System.debug('@@RES--'+res);
    } catch(System.CalloutException e) {
        System.debug('Callout error: '+ e);
        System.debug(res.getBody());
    }

    if(res != null){
        //System.debug('Res Body' + res.getBody());
        returnXML = res.getBody();
    }
    return returnXML;
}

}
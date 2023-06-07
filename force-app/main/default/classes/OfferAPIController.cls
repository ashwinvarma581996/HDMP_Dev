//****************************************************************************** 
// File Name:       OfferAPIController.cls
// Summary:         Apex Class for Offers 
// Created On:      03-13-2023
// Created By:      Manoharan Nirmalraj 
// Test Classes:    OfferAPIControllerTest.cls
// Data I/O:        
// Honda Jira Story: Apex class for API of Honda Offers Experience
//===============================================================================
// Modification Log: 
//
//*******************************************************************************
public without sharing class OfferAPIController {
    public static void setJWTAccessToken(){
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.CurrentOffersConnectedFeature');
        String cachedToken = (String)orgPart.get('JWTAccessToken');
        if(cachedToken == null){
            orgPart.put('JWTAccessToken', 'Bearer ' + JWTToken.getAccessToken());
        }
    }
    
    public static void setJWTAccessTokenToNULL(){
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.CurrentOffersConnectedFeature');
        orgPart.put('JWTAccessToken', null);
    }
    private static User getCurrentUser(){
        if(UserInfo.getUserType() != 'Guest'){
            return [Select Id, Username, CIAMToken__c From User Where Id =: UserInfo.getUserId()];
        }
        return null;
    }
    public static String getBrandLineProductByDivisionForOffers(String brand, String divisionId,String categoryCode,String currEnv){
        
        List<String> endpointParameters = new List<String>();
        Attribute attribute = new Attribute();
        attribute.divisionId = divisionId;
        if (brand == 'Powersports'){
            attribute.divisionId = 'A';
        }
        setJWTAccessToken();
        
        String metadataName = ( (brand == 'Powersports') ? 'Get_BL_ProductByDivision_PWS_'+ categoryCode + '_' + currEnv : 'Get_BL_ProductByDivision_' + brand+'_' + categoryCode+'_'+currEnv);
        //Get_BL_ProductByDivision_PWS_New_dev
        System.debug('metadataName_BrandLine--->' +metadataName);
        OfferHttpCalloutService service = new OfferHttpCalloutService(metadataName, attribute, endpointParameters);
        
        Map<String, String> headerParam = service.getHeaderParameters();
        //service.setHeaderParameter('ClientDomain', 'test.ownerportal.honda.com');
        HttpResponse response = service.sendRequest();
        if(response.getStatusCode() != 200)//Successful response will have Status=OK , code=200 
        {
            createErrorRecord(true,null,null,null,null,null,'OfferAPIController',null,null,null,
           'getBrandLineProductByDivisionForOffers',true,null,null,null,0,null,service.getRequestBody(),response.getBody());
            return null;
        }
        else
        {
            String responseBody = response.getBody();
            System.debug('Response Body : ' + responseBody);
            Error error = (Error)JSON.deserialize(responseBody, Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                setJWTAccessTokenToNULL();
            }        
            return responseBody;
        }
    }
   
    public static HttpResponse getProductChooserDataForOffers(String year, String brand,String categoryCode,String currEnv){
        HttpResponse response;
        setJWTAccessToken();
        // for (Integer i = 0; i < 2000; i++) {
        // }
        //Delaying the execution to prevent timeout
        Long startTimerTime = DateTime.now().getTime();
        Long finishTimerTime = DateTime.now().getTime();

        while ((finishTimerTime - startTimerTime ) < 5000) 
        {
            //delay for 5 seconds
            finishTimerTime = DateTime.now().getTime();
        } 
        if (brand == 'Acura'){
            /* List<InputParamsWrapper> headerParams = (List<InputParamsWrapper>) JSON.deserialize(calloutMetadata.HeaderParameters__c, InputParamsWrapper.class); */
            //String endPoint = this.calloutMetadata.Endpoint__c;
            OfferAPIController.Attribute attribute = new OfferAPIController.Attribute();
            attribute.year = year;
            attribute.divisionId = 'A';

            OfferHttpCalloutService productChooserCalloutService = new OfferHttpCalloutService('ProductChooser_Acura_' + categoryCode +'_'+ currEnv, attribute, new List<String>());
            response = productChooserCalloutService.sendRequest();

            if(response.getStatusCode() != 200)//Successful response will have Status=OK , code=200 
            {
                createErrorRecord(true,null,null,null,null,null,'OfferAPIController',null,null,null,
               'getProductChooserDataForOffers',true,null,null,null,0,null,productChooserCalloutService.getRequestBody(),response.getBody());
            }
            
        }
        else if (brand == 'Honda'){
            /* List<InputParamsWrapper> headerParams = (List<InputParamsWrapper>) JSON.deserialize(calloutMetadata.HeaderParameters__c, InputParamsWrapper.class); */
            
            OfferAPIController.Attribute attribute = new OfferAPIController.Attribute();
            attribute.year = year;
            attribute.divisionId = 'A';
            OfferHttpCalloutService productChooserCalloutService = new OfferHttpCalloutService('ProductChooser_Honda_' + categoryCode +'_'+ currEnv, attribute, new List<String>());
            
            response = productChooserCalloutService.sendRequest();


            system.debug('response.getStatusCode()  '  + response.getStatusCode());
            if(response.getStatusCode() != 200)//Successful response will have Status=OK , code=200 
            { 
                createErrorRecord(true,null,null,null,null,null,'OfferAPIController',null,null,null,
               'getProductChooserDataForOffers',true,null,null,null,0,null,productChooserCalloutService.getRequestBody(),response.getBody());

            }

        }
        else if (brand == 'Powersports'){
            OfferAPIController.Attribute attribute = new OfferAPIController.Attribute();
            attribute.year = year;
            attribute.divisionId = 'A';
            OfferHttpCalloutService productChooserCalloutService = new OfferHttpCalloutService('ProductChooser_Powersports_' + categoryCode +'_'+ currEnv, attribute, new List<String>());
            
            response = productChooserCalloutService.sendRequest();
            if(response.getStatusCode() != 200)//Successful response will have Status=OK , code=200 
            {
                createErrorRecord(true,null,null,null,null,null,'OfferAPIController',null,null,null,
               'getProductChooserDataForOffers',true,null,null,null,0,null,productChooserCalloutService.getRequestBody(),response.getBody());
            }
        }   




        System.debug(response.getBody());
        Error error = (Error)JSON.deserialize(response.getBody(), Error.class);
        if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
            setJWTAccessTokenToNULL();
        }

        return response;
    }  

    /* This method is used to create error log record for eConfig webservice failures*/
public static Error__c createErrorRecord(Boolean toInsert,String errorName,String orderreturnId,String accountId,String personAccountId, String cartId,String className, String errorMessage, String errorType, String lineNumber,String methodName,Boolean notifySupport,String OrderId,String recordid,String stackTrace,Long duration,String severity,String requestPayload,String responsePayload){
    try{
        Error__c errorRecord  =  new Error__c();
        List<Error__c> errorRecToInsertList  =  new List<Error__c>();
        errorRecord.Name  =  errorName;
        if(String.isNotBlank(orderreturnId))
            errorRecord.Order_Transaction__c  =  orderreturnId;
        if(String.isNotBlank(accountId))
            errorRecord.Account__c  =  accountId;
        if(String.isNotBlank(personAccountId))
            errorRecord.Person_Account__c = personAccountId;
        if(String.isNotBlank(cartId))
            errorRecord.Cart__c	 = cartId;
        if(String.isNotBlank(OrderId))
            errorRecord.Order__c=OrderId;
        errorRecord.ClassName__c  = className;
        errorRecord.Duration__c  = duration;
        errorRecord.Error_Message__c = errorMessage;
        errorRecord.Error_Type__c = errorType;
        if(String.isNotBlank(lineNumber))
            errorRecord.Line_Number__c = Integer.valueOf(lineNumber);
        errorRecord.MethodName__c = methodName;
        errorRecord.Notify_Support__c = notifySupport;
        errorRecord.Support_Notification_Date__c = system.now();
        if(String.isNotBlank(orderId))
            errorRecord.Order__c = orderId;
        errorRecord.RecordId__c = recordid;
        errorRecord.Severity__c = Severity;
        errorRecord.StackTrace__c = stackTrace;
        if(requestPayload.length() <= 32760)
        {
          errorRecord.Request_Payload__c = requestPayload;
        }
        errorRecord.Response_Payload__c = responsePayload;
        errorRecToInsertList.add(errorRecord);
        if(!errorRecToInsertList.isEmpty() && toInsert)
        {
            insert errorRecToInsertList;
            if(requestPayload.length() > 32760)
            {
              createRequestJSONFile(requestPayload,errorRecord.Id);
            }
            return null;
        } else {
            return errorRecord;
        }
    }catch(Exception e) {
        System.debug(e.getMessage());
    }
    return null;
  }
  /*This method is used to create request JSON File based on char limit */
  private static void createRequestJSONFile(string requestJSON,string errorRecId)
  {
    String base64Content = EncodingUtil.Base64Encode( 
      Blob.valueOf( requestJSON) 
  );
  System.debug( 'Base64 Content is ' + base64Content );
  Blob blobContent = EncodingUtil.base64Decode( base64Content );
  System.debug( 'Decoded Base64 value is ' + blobContent.toString() );
  ContentVersion objCV = new ContentVersion(
      Title = 'Request PayLoad',
      PathOnClient = 'Request_PayLoad.JSON',
      VersionData = blobContent 
  );
  insert objCV;
  objCV = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id =: objCV.Id
  ];
  ContentDocumentLink objCDL = new ContentDocumentLink(
      ContentDocumentId = objCV.ContentDocumentId,
      LinkedEntityId = errorRecId,
      Visibility = 'AllUsers'
  );
  insert objCDL;
  }
    public class Error {
        @AuraEnabled
        public Header header {get;set;}
        @AuraEnabled
        public String status {get;set;}
    }
    public class Header {
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public String errorType {get;set;}
        @AuraEnabled
        public String node {get;set;}
        @AuraEnabled
        public String errorDescription {get;set;}
        @AuraEnabled
        public String errorCode {get;set;}
    }
    
    public class Attribute {
        @AuraEnabled
        public string id {get;set;}
        @AuraEnabled
        public string divisionId {get;set;}
        @AuraEnabled
        public string subDivisionCd {get;set;}
        @AuraEnabled
        public string division {get;set;}
        @AuraEnabled
        public String modelId {get;set;}
        @AuraEnabled
        public String carrierId {get;set;}
        @AuraEnabled
        public String manufacturerId {get;set;}
        @AuraEnabled
        public String phoneId {get;set;}
        @AuraEnabled
        public String productIdentifier {get;set;}
        @AuraEnabled
        public String event {get;set;}
        @AuraEnabled
        public String vehicleAlias {get;set;}
        @AuraEnabled
        public String licensePlate {get;set;}
        @AuraEnabled
        public String vin {get;set;}
        @AuraEnabled
        public String year {get;set;}
        @AuraEnabled
        public String applicationId {get;set;}
        @AuraEnabled
        public Boolean echoInput {get;set;}
        @AuraEnabled
        public String serverIp {get;set;}
        @AuraEnabled
        public String sessionId {get;set;}
        @AuraEnabled
        public String domain {get;set;}
        @AuraEnabled
        public String environment {get;set;}
        @AuraEnabled
        public String checkSum {get;set;}
        @AuraEnabled
        public String programName {get;set;}
        @AuraEnabled 
        public String accessToken {get;set;}
        @AuraEnabled
        public String city {get;set;}
        @AuraEnabled
        public String state {get;set;}
        @AuraEnabled
        public String zipcode {get;set;}
        @AuraEnabled
        public String poiType {get;set;}
        @AuraEnabled
        public String searchRadius {get;set;}
        @AuraEnabled
        public String pOIId {get;set;}
        @AuraEnabled
        public String filters {get;set;}
        @AuraEnabled
        public String key {get;set;}
        @AuraEnabled
        public String latitude {get;set;}
        @AuraEnabled
        public String longitude {get;set;}
        @AuraEnabled
        public String requestBody {get;set;}
        @AuraEnabled
        public String email {get;set;}
        @AuraEnabled
        public String poiName {get;set;}
        @AuraEnabled
        public String productDivisionCD {get;set;}
        @AuraEnabled
        public String referenceCoordinates {get;set;}
        @AuraEnabled 
        public String federationIdentifier {get;set;}
    }


}
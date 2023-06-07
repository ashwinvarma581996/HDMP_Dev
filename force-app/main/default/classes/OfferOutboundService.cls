//****************************************************************************** 
// File Name:       OfferOutboundService.cls
// Summary:         This is service class for Offer Outbound Integration
// Created On:      03-31-2023
// Created By:      Rama Iyer
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
public  class OfferOutboundService {
    public static Map<String,OM_Integration_Setting__mdt> mapIntSettings = OfferOutboundHelper.getAllIntegrationSettings();  

    /*This method is used to peform outbound call out and also it logs the request, response JSON to error object */
    public static HttpResponse makeCallout(string jsonString,string offerRecId,string offerStatus,string requestClass,string requestType)
    {
        
        string strResponse=''; 
        HttpResponse response;

        if(mapIntSettings !=null) {
          system.debug('Request type:'+requestType);
           OM_Integration_Setting__mdt objSetting=mapIntSettings.get(requestType);
           map<String,String> mapHeaderKeyToValue = OfferOutboundHelper.getHeaderValue(objSetting.HeaderValue__c);
            Http http = new Http();
           HttpRequest request = new HttpRequest();
           //request.setEndpoint('callout:OM_OutboundIntegration_Production'); 
           request.setEndpoint('callout:OM_OutboundIntegration_Stagging');            
            for(String key : mapHeaderKeyToValue.keySet()){
              system.debug('Header Key and Value: '+key + mapHeaderKeyToValue.get(key));
              request.setHeader(key,mapHeaderKeyToValue.get(key)); 
            } 
            request.setMethod('POST');   
            if(offerStatus == 'Expired')
            {
              request.setMethod('DELETE');   
            }
            request.setBody(jsonString);
            request.setTimeout(20000);
            system.debug('request  for callout: '+request);
            response = http.send(request);
      
        system.debug('response from callout: '+response);
       
       createErrorRecord(true,null,null,null,null,null,requestClass,null,null,null,'makeCallout',false,null,offerRecId,null,0,null,jsonString,response.getBody());
    }
     return response;  
   }
   /*This method is used to update the offer record based on the response from outbound */
 public static void updateOffer(string offerId,string offerStatus,HttpResponse response)
 {
  boolean responseStatus;
  string message;
  Map<String, Object> mapResponse;
  Offers__c offerRec;
  if(offerId !=null && response!=null)
  {
    system.debug('### Response status:' + response.getStatus() +' AND code :'+response.getStatusCode());
     if(response.getStatusCode() == 200)//Successful response will have Status=OK , code=200 
     {
      mapResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
      if(mapResponse !=null && mapResponse.containsKey('IsSuccess')) 
      {
        responseStatus = (boolean)mapResponse.get('IsSuccess');
        message = (string)mapResponse.get('ErrorMessage');
        if(responseStatus !=null){
          offerRec = [select Id,Status__c,start_date__c, Integration_Status__c,Integration_Message__c,Advertised_Start_Date__c,End_Date__c,Advertised_End_Date__c
                      FROM Offers__c 
                      WHERE id=:offerId];
          offerRec.Integration_Status__c =responseStatus == true?'Success':'Fail';
          offerRec.Integration_Message__c = message;  
        }
      }
     }
     else
     {
      offerRec = new Offers__c(Id=offerId,
                              Integration_Status__c='Fail',
                              Integration_Message__c='Status='+response.getStatus() +': Status Code='+response.getStatusCode());
     }
   
    if(offerRec !=null) {
        try{
          if(Approval.isLocked(offerId))// In submitted status the record will be locked for apporval
          {
            Approval.UnlockResult unlockResult = Approval.unlock(offerId);
          }
          system.debug('###!:'+offerRec.Status__c + OfferRec.Start_Date__c + OfferRec.Integration_Status__c);
          if(offerRec.Status__c =='Approved' && OfferRec.Integration_Status__c =='Success' && (OfferRec.Start_Date__c <= system.today() || OfferRec.Advertised_Start_Date__c<=system.today()))
          {
            offerRec.Status__c = 'Active';  
          } 
          if(OfferRec.End_Date__c <= system.today() || OfferRec.Advertised_End_Date__c<=system.today())
          {
            offerRec.Status__c = 'Expired';  
          }
          update offerRec; 
          system.debug('Offer Status in Service'+offerStatus);
          if(offerStatus=='Submitted')
          {
            Approval.LockResult lockResult = Approval.lock(offerId);
            system.debug('Offer Lock Status in Service'+lockResult); 
          }
         
        }
        catch(Exception ex)
        {
          system.debug('Error occured in updating offer from outbound response :'+ex.getMessage());
        }
      } 
    
  }
}
/* This method is used to create error log record on outbound integration*/
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

   
}
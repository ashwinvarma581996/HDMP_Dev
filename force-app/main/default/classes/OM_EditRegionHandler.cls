/* 
* Apex Class Name   :   OM_EditRegionHandler
* @description      :	
* Modification Log  :
* ---------------------------------------------------------------------------
* Developer                        Date                   Description
* ---------------------------------------------------------------------------
* Spoorthi                      02nd SEP 2022               Created
*********************************************************************************/
/**
* @description AHFC_BatchRetryEsignLECall 
*/
public with sharing class OM_EditRegionHandler {
    public static Map<String,OM_Integration_Setting__mdt> mapIntSettings = getAllIntegrationSettings();
    public static final String SPECIALREGION = 'GETSPECIALREGION';
    

    @AuraEnabled 
    public static string handleEditRegion(string offerGroupType, string offerBrand){
        string strResponsebody = '';
        HttpResponse objResponse = new HttpResponse();
        system.debug('### in Handle Edit Region');
        OM_Integration_Setting__mdt objSetting=mapIntSettings.get(SPECIALREGION);
        Map<String,String> mapHeaderKeyToValue= getHeaderValue(objSetting.HeaderValue__c);
       
        if((!mapHeaderKeyToValue.isEmpty() || objSetting!=null) && String.isNotBlank(offerGroupType) && String.isNotBlank(offerBrand)){
            strResponsebody=makeCallout(objSetting,mapHeaderKeyToValue,offerGroupType,offerBrand);
        }
        return strResponsebody;
    }


public static Map<String,String> getHeaderValue(String headerJson){
        Map<String,String> mapHeaderKeyToHeaderValue = new Map<String,String>();
        List<Object> headerValueResult = (List<Object>)JSON.deserializeUntyped(headerJson); 
        
        for(Object obj : headerValueResult) { 
            Map<String,Object> mapHeaderKeyToHeaderValueTemp = (Map<String,Object>)obj;      
            mapHeaderKeyToHeaderValue.put((String)mapHeaderKeyToHeaderValueTemp.get('key'),(String)mapHeaderKeyToHeaderValueTemp.get('value'));
        }
         //Manohar:Added below to pass unique header message Id on 26th April 23
        string messageId = OfferOutboundHelper.getHeaderMessageId(); 
        if(messageId !=null)
        {
            mapHeaderKeyToHeaderValue.put('hondaHeaderType.messageId',messageId);
        }
        return mapHeaderKeyToHeaderValue;
    }

    public static string  makeCallout(OM_Integration_Setting__mdt objSetting, Map<String,String> mapHeaderKeyToValue, string groupType, string productDivisionCD){
        string strResponse= '';
        string responseCallout='';
        HttpRequest request = new HttpRequest(); 
        HttpResponse objResponse = new HttpResponse();
        Http objHttp = new Http();
        system.debug('###mapHeaderKeyToValue:'+mapHeaderKeyToValue);
       string endPointURL=objSetting.Endpoint_URL__c;

       endPointURL=endPointURL.replace('state', groupType);
       endPointURL=endPointURL.replace('=A', '='+productDivisionCD);

        Blob headerValue = Blob.valueOf(objSetting.UserName__c + ':' + objSetting.Password__c);
        String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
        mapHeaderKeyToValue.put('Authorization',authorizationHeader);

        request.setEndpoint(endPointURL);
        for(String key : mapHeaderKeyToValue.keySet()){
            system.debug('Header Key and Value: '+key + mapHeaderKeyToValue.get(key));
            request.setHeader(key,mapHeaderKeyToValue.get(key)); 
        } 
        request.setMethod(objSetting.Method__c); 
        system.debug('Debug Logs');
        system.debug(EncodingUtil.base64Encode(headerValue));
        system.debug(request);

       //List<String> lstSuccessStatuses =objSetting.Success_Status_Codes__c?.split(';');
       try {
           objResponse = objHttp.send(request);
           if(objResponse.getStatusCode() != 200 && objResponse.getStatus().toLowerCase() != 'ok'){
            strResponse='ERROR';
           }
           strResponse='SUCCESS';
           responseCallout = objResponse.getBody();
           Map<String,Object> jsonResponse = (Map<String,Object>)JSON.deserializeUntyped(responseCallout);
           Map<String, Object> jsonResponseMOTs=(Map<String, Object>) jsonResponse.get('MOTs');
           Map<String, Object> jsonResponseMOT=(Map<String, Object>) jsonResponseMOTs.get('MOT');
           Map<String, Object> jsonResponseOutput=(Map<String, Object>) jsonResponseMOT.get('Output');
           Map<String, Object> jsonResponseOutputResult=(Map<String, Object>) jsonResponseOutput.get('Results');
           system.debug('jsonResponseOutputResult: '+jsonResponseOutputResult);
           if(jsonResponseOutputResult!=null){
            List<Object> jsonResponseOutputResultGroupType=(List< Object>) jsonResponseOutputResult.get('GroupType');
            Map<String,Object>  groupDetails=(Map<String, Object>) jsonResponseOutputResultGroupType[0];
      
             List<object> values =(List<object>) groupDetails.get('Group');
             strResponse=JSON.serialize(values);
           }else{
            strResponse='NO DATA';
           }

       } catch (Exception e) {
             String exdetails = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString();
             strResponse='FAILED';
       }

    
        return strResponse;
     
    }

    public static Map<String,OM_Integration_Setting__mdt> getAllIntegrationSettings(){
        
        Map<String,OM_Integration_Setting__mdt> mapSettings = new Map<String,OM_Integration_Setting__mdt>();
        for(OM_Integration_Setting__mdt objSetting :[SELECT ID, MasterLabel,Parameters__c,Endpoint_URL__c,Method__c,HeaderValue__c,Environment__c,  Success_Status_Codes__c,UserName__c,Password__c FROM OM_Integration_Setting__mdt]){
            mapSettings.put(objSetting.Method__c+objSetting.MasterLabel, objSetting);
        }
        return mapSettings;
    }

    @AuraEnabled 
    public static string saveCalloutDetails(string stateName, string groupCode,string recordId,string offGroupType, string offBrand){
        string returnStr='';
        Offers__c offRecord= new  Offers__c();
        Offers__c off= new Offers__c();
        system.debug('recordId: '+recordId);
        if(recordId!=null && recordId!=''){
          offRecord=  [SELECT Id,AHM_Regions__c,Group_Code__c,Group_Type__c,Brand__c FROM Offers__c WHERE Id=:recordId];
          offRecord.Id=recordId;
          offRecord.AHM_Regions__c=stateName;
          offRecord.Group_Code__c=groupCode;
          offRecord.Group_Type__c=offGroupType;
          offRecord.Brand__c=offBrand;
        }
        try{
            update offRecord;
            returnStr='SUCCESS';
        }catch(Exception e){
            System.debug('Exception in OM_EditRegionHandler: ' +e);
            returnStr='ERROR';
        }    
       return returnStr;        
    }
}
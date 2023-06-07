global class OwnUploadCRRSFileEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.debug('$email' + email.plainTextBody);
            
        ParamData paramData = (ParamData)JSON.deserialize(email.plainTextBody, ParamData.class);
        System.debug('$paramData' + paramData);
        
        String externalId = Test.isRunningTest() ? 'extid' : [Select ExternalId From Case__x Where Id =: paramData.caseId].ExternalId;
        Blob blobData = Test.isRunningTest() ? Blob.valueOf('') : [SELECT VersionData FROM ContentVersion Where Id =: paramData.contentVersionId].VersionData;
        
        OwnAPIConfiguration__mdt ownAPIConfiguration = [SELECT Endpoint__c, HeaderParameters__c, Method__c FROM OwnAPIConfiguration__mdt Where DeveloperName = 'CRRS_Upload_Case_File' LIMIT 1];
        List<OwnSendAnEmailFormController.CaseServiceMtd> caseServiceMtd = (List<OwnSendAnEmailFormController.CaseServiceMtd>)JSON.deserialize(ownAPIConfiguration.HeaderParameters__c, List<OwnSendAnEmailFormController.CaseServiceMtd>.class);
        HttpRequest request = new HttpRequest();
        paramData.fileName = paramData.fileName.replaceAll(' ', '_');
        String ext = paramData.fileName.substring(paramData.fileName.lastIndexOf('.'));
        paramData.fileName = paramData.fileName.removeEnd(ext);
        request.setEndpoint(ownAPIConfiguration.Endpoint__c + '/' + externalId + '/' + paramData.fileName.replaceAll('[^a-zA-Z0-9_\\-\\s]', '_') + ext);
        request.setMethod(ownAPIConfiguration.Method__c);
        for(OwnSendAnEmailFormController.CaseServiceMtd caseService : caseServiceMtd){
            if(caseService.key == 'hondaHeaderType.messageId')
                request.setHeader(caseService.key, caseService.value + Datetime.now().formatGMT('yyyyMMddHHmmss'));
            else
                request.setHeader(caseService.key, caseService.value);
        }
        request.setBodyAsBlob(blobData);
        Http http = new Http();
        HTTPResponse response = http.send(request);
        System.debug('$$FileResponse: ' + response.getBody());
        return result;
    }
    public class ParamData{
        public String fileName;
        public String contentVersionId;
        public String caseId;
        public String fileData_json;
    }
}
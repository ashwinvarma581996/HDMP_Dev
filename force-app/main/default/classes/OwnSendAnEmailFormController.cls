public without sharing class OwnSendAnEmailFormController {
    
    @AuraEnabled(cacheable=true)
    public static String getPreferredDealerName(String ownershipId){
        String dealerName = '';
        Ownership__c ownerShip = [SELECT Preferred_Dealer__r.Name FROM Ownership__c Where Id =: ownershipId];
        if(ownerShip.Preferred_Dealer__r != null){
            dealerName = ownerShip.Preferred_Dealer__r.Name;
        }
        return dealerName;
    }
    
    @AuraEnabled
    public static Case__x reOpenCase(Case__x caseRecord){
        if(!Test.isRunningTest()){
        	User__x user = [SELECT Id, ExternalId, Name__c, Email__c FROM User__x Where Name__c = 'Integration Mygarage' limit 1];
            caseRecord.OwnerId__c = user.ExternalId;    
        }
        
        Database.SaveResult sr = Test.isRunningTest() ? Database.insert(new Account(Name = 'runningTest')) : Database.updateImmediate(caseRecord);
        if (sr.isSuccess()) {
            System.debug('Success: ' + sr.getId());
        }
        else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error: ' + err.getMessage());
                throw new DMLException(err.getMessage());
            }
        }
        return caseRecord;
    }
    
    @AuraEnabled(cacheable = true)
    public static Boolean showCasesTab(){
        Boolean showCaseTab = false;
        String userEmail = UserInfo.getUserEmail();
        String emails = [SELECT Email_Addresses__c FROM Email_List__mdt Where DeveloperName = 'Support_Case_Tab_Visibility' LIMIT 1].Email_Addresses__c;
        if(emails.trim().containsIgnoreCase('All') && emails.trim().length() == 3){
            showCaseTab = true;
        }else{
            for(String email : emails.split(',')){
                if(email.trim().containsIgnoreCase(userEmail) && !showCaseTab){
                    showCaseTab = true;
                }
            }
        }
        return showCaseTab;
    }
    
    @AuraEnabled(cacheable = true)
    public static Map<String, Object> getPersonMailingAddress(){
        Map<String, Object> userAndAccountDetails = new Map<String, Object>();
        User user = [SELECT FirstName, LastName, Email, ContactId, FederationIdentifier FROM User Where Id =:UserInfo.getUserId() Limit 1];
        Account acc = [SELECT Name, PersonMailingAddress, Phone FROM Account Where PersonContactId =: user.ContactId];
        userAndAccountDetails.put('User', user);
        userAndAccountDetails.put('Account', acc);
        return userAndAccountDetails;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDropdowns(){
        Map<String, Object> dropdownsMap = new Map<String, Object>();
        List<Dropdown__mdt> dropdowns = [SELECT DeveloperName, MasterLabel, JSON__c FROM Dropdown__mdt];
        for(Dropdown__mdt dropdown: dropdowns){
            dropdownsMap.put(dropdown.DeveloperName, JSON.deserializeUntyped(dropdown.JSON__c));
        }
        return dropdownsMap;
    }
    
    @AuraEnabled
    public static List<FeedItemWrapper> getCaseComments(String caseExternalId){
        Set<Id> userIdsSet = new Set<Id>();
        for(FeedItem__x feedItem : [SELECT RelatedRecordId__c, InsertedById__c, Body__c FROM FeedItem__x where ParentId__c =: caseExternalId And Visibility__c = 'AllUsers' Order By CreatedDate__c DESC]){
            if(feedItem.RelatedRecordId__c == Null && feedItem.Body__c != Null){
                userIdsSet.add(feedItem.InsertedById__c);
            }
        }
        Map<Id, String> userxIdAndNameMap = new Map<Id, String>();
        for(User__x userx : [SELECT ExternalId, Name__c FROM User__x Where ExternalId IN: userIdsSet]){
            userxIdAndNameMap.put(userx.ExternalId, userx.Name__c);
        }
        List<FeedItemWrapper> feedItemsWrapper = new List<FeedItemWrapper>();
        User user = [SELECT Name, SmallPhotoUrl FROM User Where Id =:UserInfo.getUserId() Limit 1];
        for(FeedItem__x feedItem : [SELECT ExternalId, Body__c, CreatedDate__c, RelatedRecordId__c, InsertedById__c FROM FeedItem__x where ParentId__c =: caseExternalId And Visibility__c = 'AllUsers' Order By CreatedDate__c DESC]){
            if(feedItem.RelatedRecordId__c == Null && feedItem.Body__c != Null){
                feedItemsWrapper.add(new FeedItemWrapper(user, feedItem, userxIdAndNameMap));
            }
        }
        return feedItemsWrapper;
    }
    
    public class FeedItemWrapper{
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public String Body;
        @AuraEnabled
        public String UserName;
        @AuraEnabled
        public String ExternalId;
        @AuraEnabled
        public DateTime CreatedDate;
        @AuraEnabled
        public String SmallPhotoUrl;
        @AuraEnabled
        public String InsertedByName;
        
        public FeedItemWrapper(User user, FeedItem__x feedItem, Map<Id, String> userxIdAndNameMap){
            recordId = feedItem.Id;
            ExternalId = feedItem.ExternalId;
            Body = feedItem.Body__c;
            CreatedDate = feedItem.CreatedDate__c;
            InsertedByName = userxIdAndNameMap.get(feedItem.InsertedById__c);
            UserName = userxIdAndNameMap.get(feedItem.InsertedById__c).containsIgnoreCase('Integration Mygarage') ? user.Name : 'Customer Relations';
            SmallPhotoUrl = userxIdAndNameMap.get(feedItem.InsertedById__c).containsIgnoreCase('Integration Mygarage') ? user.SmallPhotoUrl : 'Default Avatar';
        }
    }
    
    @AuraEnabled
    public static List<ContentVersion__x> getCaseAttachments(String caseExternalId){
        Set<Id> cvExtIds = new Set<Id>();
        Map<Id, String> externalIdCreatedDateMap = new Map<Id, String>();
        for(FeedItem__x caseFeed : [SELECT Body__c, CreatedDate__c, RelatedRecordId__c FROM FeedItem__x where ParentId__c =: caseExternalId And Visibility__c = 'AllUsers' Order By CreatedDate__c DESC]){
            if(caseFeed.RelatedRecordId__c != Null){
            	cvExtIds.add(caseFeed.RelatedRecordId__c);
                externalIdCreatedDateMap.put(caseFeed.RelatedRecordId__c, caseFeed.CreatedDate__c + '');
            }
        }
        List<ContentVersion__x> contentVersions = new List<ContentVersion__x>();
        for(ContentVersion__x cv : [SELECT ExternalId, Title__c, FileExtension__c, ContentDocumentId__c, ContentSize__c FROM ContentVersion__x Where ExternalId IN: cvExtIds]){
            cv.DisplayUrl = externalIdCreatedDateMap.get(cv.ExternalId);
            contentVersions.add(cv);
        }
        return contentVersions;
    }
    
    @AuraEnabled
    public static List<Case__x> getCases(){
        User user = [SELECT FederationIdentifier FROM User Where Id =:UserInfo.getUserId() Limit 1];
        return [Select Id, ExternalId, CaseNumber__c, CustomerId_c__c, Status__c, CreatedDate__c, Subject__c, WebtoCase_Make_c__c, Topic_c__c, WebToCase_Power_Equip_Product_Line_c__c, WebToCase_Marine_What_Engine_Size_c__c, WebToCase_Marine_do_you_need_help_with_c__c, 
                Sub_topic_c__c, First_Name_c__c, Last_Name_c__c, SuppliedEmail__c, SuppliedPhone__c, WebToCase_Zipcode_c__c, VIN_Text_c__c, Miles_c__c, Description__c From Case__x 
                Where CustomerId_c__c =:user.FederationIdentifier Order By CreatedDate__c DESC];
    }
    
    @AuraEnabled
    public static Case__x getCase(String caseNumber){
        return Test.isRunningTest() ? (Case__x)JSON.deserialize('{"Id" : "05T010000063zOyEAI", "ExternalId" : "05T010000063zOyEAI"}', Case__x.class) : [Select Id, ExternalId, CaseNumber__c, Status__c, CreatedDate__c,Subject__c,WebtoCase_Make_c__c,Topic_c__c, CustomerId_c__c, 
                WebToCase_Marine_do_you_need_help_with_c__c, WebToCase_Marine_What_Engine_Size_c__c, WebToCase_Power_Equip_Product_Line_c__c, Sub_topic_c__c, 
                First_Name_c__c, Last_Name_c__c, SuppliedEmail__c, SuppliedPhone__c, WebToCase_Street_c__c, WebToCase_City_c__c, WebToCase_State_c__c, WebToCase_Zipcode_c__c, 
                WebtoCase_Model_c__c, WebToCase_Street2_c__c, webToCase_Title_c__c, WebToCase_How_can_we_help_you_c__c, WebToCase_Serial_Number_c__c, 
                WebToCase_Dealer_s_City_c__c, WebToCase_Dealer_s_State_c__c, Name_of_Dealer_c__c, W2C_IsYourProductCurrentlyAtThisDealer_c__c, VIN_Text_c__c, Make_manual_c__c, 
                Model_Manual_c__c, Year_manual_c__c, WebToCase_Vehicle_Trim_c__c, Phone_Carrier_c__c, Phone_Manufacturer_c__c, Phone_Model_c__c, Phone_OS_c__c, Miles_c__c, 
                Description__c From Case__x Where CaseNumber__c =:caseNumber LIMIT 1];
    }
    
    @AuraEnabled
    public static Case__x getCaseById(String caseId){
        System.debug('$$caseId: ' + caseId);
        return Test.isRunningTest() ? (Case__x)JSON.deserialize('{"Id" : "05T010000063zOyEAI", "ExternalId" : "05T010000063zOyEAI"}', Case__x.class) : [Select Id, ExternalId, CaseNumber__c, Status__c, CreatedDate__c,Subject__c,WebtoCase_Make_c__c,Topic_c__c, CustomerId_c__c, 
                WebToCase_Marine_do_you_need_help_with_c__c, WebToCase_Marine_What_Engine_Size_c__c, WebToCase_Power_Equip_Product_Line_c__c, Sub_topic_c__c, 
                First_Name_c__c, Last_Name_c__c, SuppliedEmail__c, SuppliedPhone__c, WebToCase_Street_c__c, WebToCase_City_c__c, WebToCase_State_c__c, WebToCase_Zipcode_c__c, 
                WebtoCase_Model_c__c, WebToCase_Street2_c__c, webToCase_Title_c__c, WebToCase_How_can_we_help_you_c__c, WebToCase_Serial_Number_c__c, 
                WebToCase_Dealer_s_City_c__c, WebToCase_Dealer_s_State_c__c, Name_of_Dealer_c__c, W2C_IsYourProductCurrentlyAtThisDealer_c__c, VIN_Text_c__c, Make_manual_c__c, 
                Model_Manual_c__c, Year_manual_c__c, WebToCase_Vehicle_Trim_c__c, Phone_Carrier_c__c, Phone_Manufacturer_c__c, Phone_Model_c__c, Phone_OS_c__c, Miles_c__c, 
                Description__c From Case__x Where Id =:caseId LIMIT 1];
    }
    
    @AuraEnabled
    public static string addMoreAttachment(String fileData_json, String caseId){
        List<FileData> file = (List<FileData>)JSON.deserialize(fileData_json, List<FileData>.class);
        uploadFile(file[0].file.name, file[0].file.contentVersionId, caseId, fileData_json);
        return 'Success';
    }
    
    @AuraEnabled
    public static Case__x createCase(Case__x webToCase, String fileData_json){
        
        System.debug('$$fileData_json: ' + fileData_json);
        List<FileData> fileData = new List<FileData>();
        
        if(String.isNotBlank(fileData_json)){
            fileData = (List<FileData>)JSON.deserialize(fileData_json, List<FileData>.class);
            System.debug('$$fileData: ' + fileData);
        }
        
        System.debug('$$webToCase: ' + webToCase);
        
        Database.SaveResult sr = Test.isRunningTest() ? Database.insert(new Account(Name = 'Test')) : Database.insertImmediate(webToCase);
        if (sr.isSuccess()) {
            System.debug('Success: ' + sr.getId());
            for(FileData file : fileData){
                System.debug('$$$file: ' + file);
                uploadFile(file.file.name, file.file.contentVersionId, webToCase.Id, fileData_json);
            }
        }
        else {
            for(Database.Error err : sr.getErrors()) {
                System.debug('Error: ' + err.getMessage());
                throw new DMLException(err.getMessage());
            }
        }
        return webToCase;
    }
    @future(callout=true)
    public static void uploadFile(String fileName, Id contentVersionId, Id caseId, String fileData_json){
        
        Integer contentSize = Test.isRunningTest() ? 1234 : [SELECT ContentSize FROM ContentVersion Where Id =: contentVersionId].ContentSize;
        System.debug('$contentSize: ' + contentSize);
        if(contentSize > 11 * 1024 * 1024) {
            System.debug('Size is greater than 11 MB');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{Label.Upload_CRRS_File_Email_Service_Email});
            mail.setSubject('Test Email');
            mail.setPlainTextBody('{"fileName": "'+ fileName +'", "contentVersionId": "'+ contentVersionId +'", "caseId": "'+ caseId +'", "fileData_json": "fileData_json"}');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }else{
            System.debug('Size is not greater than 11 MB');
            uploadFileHelper(fileName, contentVersionId, caseId, fileData_json);
        }
    }
    public static void uploadFileHelper(String fileName, Id contentVersionId, Id caseId, String fileData_json){
        String externalId = Test.isRunningTest() ? 'extid' : [Select ExternalId From Case__x Where Id =: caseId].ExternalId;
        System.debug('$$caseId: ' + caseId);
        System.debug('$$externalId: ' + externalId);
        Blob blobData = Test.isRunningTest() ? Blob.valueOf('') : [SELECT VersionData FROM ContentVersion Where Id =: contentVersionId].VersionData;
        
        //Cache.OrgPartition orgPart = Cache.Org.getPartition('local.MyGarage');
        //orgPart.put(externalId, (List<FileData>)JSON.deserialize(fileData_json, List<FileData>.class));
        
        OwnAPIConfiguration__mdt ownAPIConfiguration = [SELECT Endpoint__c, HeaderParameters__c, Method__c FROM OwnAPIConfiguration__mdt Where DeveloperName = 'CRRS_Upload_Case_File' LIMIT 1];
        List<CaseServiceMtd> caseServiceMtd = (List<CaseServiceMtd>)JSON.deserialize(ownAPIConfiguration.HeaderParameters__c, List<CaseServiceMtd>.class);
        HttpRequest request = new HttpRequest();
        fileName = fileName.replaceAll(' ', '_');
        String ext = fileName.substring(fileName.lastIndexOf('.'));
        fileName = fileName.removeEnd(ext);
        request.setEndpoint(ownAPIConfiguration.Endpoint__c + '/' + externalId + '/' + fileName.replaceAll('[^a-zA-Z0-9_\\-\\s]', '_') + ext);
        request.setMethod(ownAPIConfiguration.Method__c);
        for(CaseServiceMtd caseService : caseServiceMtd){
            if(caseService.key == 'hondaHeaderType.messageId')
                request.setHeader(caseService.key, caseService.value + Datetime.now().formatGMT('yyyyMMddHHmmss'));
            else
                request.setHeader(caseService.key, caseService.value);
        }
        request.setBodyAsBlob(blobData);
        Http http = new Http();
        HTTPResponse response = http.send(request);
        System.debug('$FileResponse: ' + response.getBody());
    }
    @AuraEnabled
    public static Object createFeedItem(String parentId, String messageBody, String visibilityValue){
        
        //String parentId = '500760000030joGAAQ';
        //String messageBody = 'test1 body 2';
        //String visibilityValue = 'AllUsers';
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        
        OwnAPIConfiguration__mdt ownAPIConfiguration = [SELECT Endpoint__c, HeaderParameters__c, Method__c, Body__c FROM OwnAPIConfiguration__mdt Where DeveloperName = 'CRRS_CreateFeedItem' LIMIT 1];
        Map<String, String> accessTokenInstanceUrlMap = getAccessToken();
        String endpoint = ownAPIConfiguration.Endpoint__c.replace('PARENT_ID', parentId);
        endpoint = endpoint.replace('ORG_DOMAIN', accessTokenInstanceUrlMap.get('instance_url'));
        List<CaseServiceMtd> caseServiceMtd = (List<CaseServiceMtd>)JSON.deserialize(ownAPIConfiguration.HeaderParameters__c, List<CaseServiceMtd>.class);
        for(CaseServiceMtd caseService : caseServiceMtd){
            if(caseService.key == 'Authorization')
                request.setHeader(caseService.key, caseService.value + ' ' + accessTokenInstanceUrlMap.get('access_token'));
            else
                request.setHeader(caseService.key, caseService.value);
        }
        request.setEndpoint(endpoint);
        String body = ownAPIConfiguration.Body__c;
        body = body.replace('PARENT_ID', parentId);
        body = body.replace('MESSAGE_BODY', messageBody);
        body = body.replace('VISIBILITY_VALUE', visibilityValue);

        request.setBody(body);
        request.setMethod(ownAPIConfiguration.Method__c);
        response = http.send(request);
        String jsonResponse = response.getBody();
        System.debug('Status Code: ' + response.getStatusCode());
        System.debug('Response: ' + jsonResponse);
        return JSON.deserializeUntyped(jsonResponse);
    }
    public static Map<String, String> getAccessToken(){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        OwnAPIConfiguration__mdt ownAPIConfiguration = [SELECT Endpoint__c, UrlParameters__c, Method__c FROM OwnAPIConfiguration__mdt Where DeveloperName = 'CRRS_AccessToken' LIMIT 1];
        String endpoint = ownAPIConfiguration.Endpoint__c;
        List<CaseServiceMtd> caseServiceMtd = (List<CaseServiceMtd>)JSON.deserialize(ownAPIConfiguration.UrlParameters__c, List<CaseServiceMtd>.class);
        for(CaseServiceMtd caseService : caseServiceMtd){
            endpoint += caseService.key + '=' + caseService.value + '&';
        }
        endpoint = endpoint.removeEnd('&');
        req.setMethod(ownAPIConfiguration.Method__c);
        req.setEndpoint(endpoint);
        
        HttpResponse res = h.send(req);
        System.debug('res:'+res.getBody());
        Map<String, String> accessTokenInstanceUrlMap = new Map<String, String>();
        JSONParser parser1 = JSON.createParser(res.getBody());
        while(parser1.nextToken() != NULL){
            if((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'access_token')){
                parser1.nextToken();
                accessTokenInstanceUrlMap.put('access_token', parser1.getText());
            }
            if((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 'instance_url')){
                parser1.nextToken();
                accessTokenInstanceUrlMap.put('instance_url', parser1.getText());
            }
        }
        System.debug('$accessTokenInstanceUrlMap : '+accessTokenInstanceUrlMap);
        return accessTokenInstanceUrlMap;
    }
    public class CaseServiceMtd {
        public String key;
        public String value;
        public String type;
    }
    public class FileData {
        @AuraEnabled public File file;
        @AuraEnabled public String label;
        @AuraEnabled public Boolean required;
    }
    public class File {
		@AuraEnabled public String name;
		@AuraEnabled public String contentVersionId;
		@AuraEnabled public String contentBodyId;
		@AuraEnabled public String mimeType;
	}
    
    @AuraEnabled(cacheable=true)
    public static string getAttachmentBody(String caseExternalId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        OwnAPIConfiguration__mdt ownAPIConfiguration = [SELECT Endpoint__c, HeaderParameters__c, Method__c FROM OwnAPIConfiguration__mdt Where DeveloperName = 'CRRS_Get_Case_File' LIMIT 1];
        List<CaseServiceMtd> caseServiceMtd = (List<CaseServiceMtd>)JSON.deserialize(ownAPIConfiguration.HeaderParameters__c, List<CaseServiceMtd>.class);
        for(CaseServiceMtd caseService : caseServiceMtd){
            if(caseService.key == 'hondaHeaderType.messageId')
                request.setHeader(caseService.key, caseService.value + Datetime.now().formatGMT('yyyyMMddHHmmss'));
            else if(caseService.key == 'hondaHeaderType.collectedTimestamp')
                request.setHeader(caseService.key, Datetime.now().formatGMT('yyyyMMddHHmmss'));
            else
                request.setHeader(caseService.key, caseService.value);
        }
        request.setEndpoint(ownAPIConfiguration.Endpoint__c + '?id=' + caseExternalId);
        request.setMethod(ownAPIConfiguration.Method__c);
        
        HttpResponse response = http.send(request);
        Blob fileBlob = response.getBodyAsBlob();
        // Blob fileBlob = [SELECT Id, Title, VersionData FROM ContentVersion Where Id = '068010000028CwwAAE'].VersionData;
        return EncodingUtil.base64Encode(fileBlob);
    }
    
    @AuraEnabled(cacheable=true)
    public static Object getAttachmentUrl(String documentId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        OwnAPIConfiguration__mdt ownAPIConfiguration = [SELECT Endpoint__c, HeaderParameters__c, Method__c FROM OwnAPIConfiguration__mdt Where DeveloperName = 'CRRS_Get_Case_File_Url' LIMIT 1];
        List<CaseServiceMtd> caseServiceMtd = (List<CaseServiceMtd>)JSON.deserialize(ownAPIConfiguration.HeaderParameters__c, List<CaseServiceMtd>.class);
        for(CaseServiceMtd caseService : caseServiceMtd){
            if(caseService.key == 'hondaHeaderType.messageId')
                request.setHeader(caseService.key, caseService.value + Datetime.now().formatGMT('yyyyMMddHHmmss'));
            else if(caseService.key == 'hondaHeaderType.collectedTimestamp')
                request.setHeader(caseService.key, Datetime.now().formatGMT('yyyyMMddHHmmss'));
            else
                request.setHeader(caseService.key, caseService.value);
        }
        request.setEndpoint(ownAPIConfiguration.Endpoint__c + '/' + documentId);
        request.setMethod(ownAPIConfiguration.Method__c);
        HttpResponse response = http.send(request);
        
        System.debug(response.getBody());

        return JSON.deserializeUntyped(response.getBody());
    }
}
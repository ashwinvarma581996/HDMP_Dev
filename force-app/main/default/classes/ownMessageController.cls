public without sharing class ownMessageController {
    @AuraEnabled(cacheable=true)
    public static MessageInbox getAllMessages(){
        try {
            MessageInbox inbox = new MessageInbox();
            Schema.DescribeSObjectResult messageDescribe = Message__c.SObjectType.getDescribe();
            List<Schema.RecordTypeInfo> recordTypeInfoList = messageDescribe.getRecordTypeInfos();
            for (Schema.RecordTypeInfo rti : recordTypeInfoList){
                inbox.recordTypeMap.put(rti.getRecordTypeId(), rti.getName());
            }
            
            String recordTypeVar=system.Label.OTARecordType;    
            Id otaRecordID = Schema.SObjectType.Message__c.getRecordTypeInfosByName().get(recordTypeVar).getRecordTypeId();
            
            Own_Message_Record_Type_Config__mdt generalRecordTypeNameMDT = [SELECT Record_Type_Developer_API_Names__c, MasterLabel FROM Own_Message_Record_Type_Config__mdt WHERE MasterLabel = 'General Message Record Types'];
            List<Id> generalRecordTypeIdList = new List<Id>();
            for (String recordTypeName : generalRecordTypeNameMDT.Record_Type_Developer_API_Names__c.deleteWhitespace().split(',')){
                for (Schema.RecordTypeInfo rti : recordTypeInfoList){
                    if (rti.getDeveloperName() == recordTypeName){
                        generalRecordTypeIdList.add(rti.getRecordTypeId());
                    }
                }
            }
            Datetime dt=System.now();
            inbox.generalMessages = [SELECT Id, Body__c, RecordTypeId, Subject__c, CreatedDate FROM Message__c WHERE RecordTypeId IN :generalRecordTypeIdList];
            Id acctId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;
            inbox.ownerMessages = [SELECT Alternate_Identifier__c,Is_Read__c,Message__r.Body__c,Message__r.RecordTypeId,Message__r.Subject__c,Message__r.CreatedDate 
                                    FROM Owner_Message__c WHERE Owner__c=:acctId AND Ownership__r.Managed__c=true AND Message__r.RecordTypeId NOT IN :generalRecordTypeIdList AND (Message__r.RecordTypeId !=:otaRecordID OR (Message__r.RecordTypeId =:otaRecordID AND  Message__r.Start_Date__c < :dt AND  Message__r.End_Date__c >= :dt))];

            return inbox;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class MessageInbox{
        @AuraEnabled public List<Message__c> generalMessages;
        @AuraEnabled public List<Owner_Message__c> ownerMessages;
        @AuraEnabled public Map<Id, String> recordTypeMap;
        public MessageInbox(){
            //this.generalMessages = new List<Message__c>();
            this.recordTypeMap = new Map<Id,String>();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Message__c> getAlerts(){
        return [SELECT Id FROM Message__c WHERE RecordType.DeveloperName IN ('Product_Alert', 'Safety_Alert')];
    }

    @AuraEnabled(cacheable=false)
    public static String markItRead(String id){
        Datetime ReadDateTime = Datetime.now();  
        Owner_Message__c messageToUpdate;
            messageToUpdate = 
                    [SELECT Is_Read__c,Read_Date__c FROM Owner_Message__c 
                    WHERE Id=:id
                    LIMIT 1];
                // Update the isRead.
                messageToUpdate.Is_Read__c = true;
                messageToUpdate.Read_Date__c = ReadDateTime;
            update messageToUpdate;
           return 'success';
    }
    @AuraEnabled(cacheable=true)
    public static List<Owner_Message__c> getAllRecalls(){
        Id acctId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;
        List<Owner_Message__c> allRecallsList=new List<Owner_Message__c>();
         try {
            Id recallRecordTypeId = Schema.SObjectType.Message__c.getRecordTypeInfosByDeveloperName().get('Recall').getRecordTypeId();
            system.debug('@@test'+recallRecordTypeId);
            //Imtiyaz - RECALLS Start
            List<Owner_Message__c> allRecalls = [SELECT Alternate_Identifier__c,Is_Read__c, Message__r.Brand__c, Message__r.Body__c,Message__r.RecordTypeId,Message__r.Subject__c,Message__r.CreatedDate 
            FROM Owner_Message__c   WHERE Owner__c=:acctId AND Ownership__r.Managed__c=true];
            //Imtiyaz - RECALLS End
            for(Owner_Message__c m:allRecalls){
                system.debug('@@test'+m.Message__r.Subject__c);
                if(m.Message__r.RecordTypeId == recallRecordTypeId){
                    system.debug('@@test added'+acctId);
                    allRecallsList.add(m);
                }
            }                                     
            return allRecallsList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Message__c getRecallByAlt_Idnf(String alternateIdentifier){
        try {
            Message__c recall = [SELECT Alternate_Identifier__c,Body__c,Subject__c,CreatedDate 
                                FROM Message__c WHERE Alternate_Identifier__c=:alternateIdentifier ];
            return recall;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static User getUserDetail(){
        User user = [SELECT FirstName, LastName, Email, ContactId, FederationIdentifier FROM User Where Id =:UserInfo.getUserId() Limit 1];
        return user;
    }
}
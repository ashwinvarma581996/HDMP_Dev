public without sharing class OwnRecallsController {
    
    @AuraEnabled(cacheable=true)
    public static Integer getUnreadMessageCount(){
        String recordTypeVar=system.Label.OTARecordType;    
        Id otaRecordID = Schema.SObjectType.Message__c.getRecordTypeInfosByName().get(recordTypeVar).getRecordTypeId();
        Datetime dt=System.now();
        Id acctId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;

        System.debug([SELECT Id FROM Owner_Message__c WHERE Owner__c=:acctId AND Is_Read__c=false].size());

        return [SELECT Id FROM Owner_Message__c WHERE Owner__c=:acctId AND Is_Read__c=false AND Ownership__r.Managed__c=true AND (Message__r.RecordTypeId !=:otaRecordID OR (Message__r.RecordTypeId =:otaRecordID AND  Message__r.Start_Date__c < :dt AND  Message__r.End_Date__c >= :dt))].size();
    }
    @AuraEnabled(cacheable=true)
    public static Integer getRecallsCount(){
        
        Id acctId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;

        System.debug([SELECT Id FROM Owner_Message__c WHERE Owner__c=:acctId AND Is_Read__c=false AND Message__r.RecordType.Name = 'Recall'].size());

        return [SELECT Id FROM Owner_Message__c WHERE Owner__c=:acctId AND Ownership__r.Managed__c=true AND Message__r.RecordType.Name = 'Recall'].size();
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean getRecallByOwnershipId(String ownershipId){
      Integer resultSize = [SELECT Id, OwnerId, Name, Message__c, Ownership__c FROM Owner_Message__c  WHERE Message__r.RecordType.Name ='Recall' AND Ownership__c =: ownershipId].size();   
      return resultSize > 0 ? true : false;
    }

    public class RecallParam{
        String vin;
        String modelId;
        String divisionId;
    }

    // Alexander Dzhitenov (Wipro) : Save recalls data during the user login sequence
    @AuraEnabled(cacheable=false)
    public static Map<String, RecallObject> getRecallData(/* List<OwnGarageController.VinDetails> vins */ List<OwnGarageController.Product> productList, Id userAcctId){
        // Create Message__c records based on API response for each VIN provided, return data back
        // to User Login Sequence for DML operations later

        Id recallRecordTypeId = Schema.SObjectType.Message__c.getRecordTypeInfosByDeveloperName().get('Recall').getRecordTypeId();

        Map<String, RecallObject> newRecalls = new Map<String, RecallObject>();

        for (OwnGarageController.Product p : productList){
            OwnAPIController.RecallData recallData = new OwnAPIController.RecallData();
            try{
                recallData = (p.vin == null || p.vin == '-') ? OwnAPIController.getRecallsByModelId(p.modelId, p.divisionId) : OwnAPIController.getRecallsByProductIdentifier(p.vin, p.divisionId);
            }
            catch(Exception e){
                recallData.isError = true;
                System.debug('%%RECALLS ERROR: ' + p.modelId + ' ' + e.getMessage());
                continue;
            }
            if (recallData.response.recalls_response.response.error == 'false' && recallData.isError != true){
                List<OwnAPIController.Campaign> campaigns = recallData.response.recalls_response.response.recall.campaignType.campaign;

                if (campaigns != null && campaigns.size() > 0){
                    List<Message__c> newMessages = new List<Message__c>();
                    for (OwnAPIController.Campaign campaign : campaigns){
                        Message__c message = getMessageFromCampaign(campaign, p.vin, p.divisionId, p.modelId);
                        message.RecordTypeId = recallRecordTypeId;
                        newMessages.add(message);
                    }
                    newRecalls.put(getVinModelIdKey(p.vin, p.modelId), new RecallObject(p, newMessages, true));
                }
                else{
                    newRecalls.put(getVinModelIdKey(p.vin, p.modelId), new RecallObject(p, false));
                } // Products both with and without recalls are returned, differentiated by the hasRecall property
            }
        }

        return newRecalls;
    }

    public static void saveAndDeleteRecallsData(Map<String, RecallObject> newRecallDataMap, Id userAcctId){
        // Process recall data returned by getRecallData - create Owner_Message__c objects, insert Message__c and Owner_Message__c records,
        // and handle record deletion for recalls that were not returned from the API this time
        
        //Set<String> vinSet = new Set<String>();
        //Set<String> modelIdSet = new Set<String>();
        Set<String> newMessageIdentifiers = new Set<String>();
        Set<String> newOwnerMessageIdentifiers = new Set<String>();
        Set<String> currentMessageIdentifiers = new Set<String>();

        Map<String, Message__c> newRecallMessageAltIdMap = new Map<String, Message__c>();

        for (RecallObject recallObj : newRecallDataMap.values()){
            //modelIdSet.add(recallObj.product.modelId);
            newMessageIdentifiers.addAll(recallObj.getMessageIdentifiers());
        }

        System.debug(newOwnerMessageIdentifiers);

        // Obtain user Ownerships
        Map<Id, Ownership__c> userOwnershipMap = new Map<Id, Ownership__c>([SELECT Id, Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c FROM Ownership__c WHERE Product_Owner__c=:userAcctId AND Managed__c=true]);
        
        // Obtain current Messages in database matching message identifiers
        List<Message__c> currentMessages = [SELECT Id, Alternate_Identifier__c FROM Message__c WHERE Alternate_Identifier__c IN :newMessageIdentifiers];
        Map<String, Message__c> currentMessageAltIdMap = new Map<String, Message__c>();

        for (Message__c m : currentMessages){
            currentMessageAltIdMap.put(m.Alternate_Identifier__c, m);
        }

        // Obtain Owner Messages in current database
        Id recallRecordTypeId = Schema.SObjectType.Message__c.getRecordTypeInfosByDeveloperName().get('Recall').getRecordTypeId();
        List<Owner_Message__c> currentOwnerMessages = [SELECT Id, Alternate_Identifier__c, Ownership__r.Honda_Product__r.Product_Identifier__c, Ownership__r.Honda_Product__r.Product_Models__r.Product_Model_Id__c, Message__c, Message__r.Alternate_Identifier__c FROM Owner_Message__c WHERE Ownership__c IN :userOwnershipMap.keySet() AND Message__r.RecordTypeId = :recallRecordTypeId];
        Map<String, Owner_Message__c> currentOwnerMessageAltIdMap = new Map<String, Owner_Message__c>();

        for (Owner_Message__c om : currentOwnerMessages){
            currentOwnerMessageAltIdMap.put(om.Alternate_Identifier__c, om);
        }

        List<Message__c> messageInsertList = new List<Message__c>();
        for (RecallObject recallObj : newRecallDataMap.values()){
            for (RecallDataObject recallData : recallObj.recallData){
                if (currentMessageAltIdMap.containsKey(recallData.message.Alternate_Identifier__c)){
                    // Get SF ID of all messages that already have existing records in the database
                    recallData.message.Id = currentMessageAltIdMap.get(recallData.message.Alternate_Identifier__c).Id;
                }
                messageInsertList.add(recallData.message);
            }
        }

        Database.UpsertResult[] mDbr = Database.upsert(messageInsertList, false);
        for (Database.UpsertResult saveResult : mdbr){
            if (saveResult.isSuccess()){
                System.debug(saveResult.getId() + ': success');
            }
            else{
                for (Database.Error err : saveResult.getErrors()){
                    System.debug('Error: ' + err.getStatusCode() + ', ' + err.getMessage());
                }
            }
        }

        List<Owner_Message__c> ownerMessageInsertList = new List<Owner_Message__c>();

        for (Ownership__c o : userOwnershipMap.values()){
            String vinModelIdKey = getVinModelIdKey(o.Honda_Product__r.Product_Identifier__c, o.Honda_Product__r.Product_Models__r.Product_Model_Id__c);
            if (newRecallDataMap.containsKey(vinModelIdKey)){
                for (RecallDataObject rdo : newRecallDataMap.get(vinModelIdKey).recallData){
                    rdo.fillOwnerMessage(userAcctId, o.Id);
                    if (!currentOwnerMessageAltIdMap.containsKey(rdo.ownerMessage.Alternate_Identifier__c)){
                        ownerMessageInsertList.add(rdo.ownerMessage);
                    }
                    newOwnerMessageIdentifiers.add(rdo.ownerMessage.Alternate_Identifier__c);
                }
            }
        }

        Database.UpsertResult[] omDbr = Database.upsert(ownerMessageInsertList, false);
        for (Database.UpsertResult saveResult : omDBR){
            if (saveResult.isSuccess()){
                System.debug(saveResult.getId() + ': success');
            }
            else{
                for (Database.Error err : saveResult.getErrors()){
                    System.debug('Error: ' + err.getStatusCode() + ', ' + err.getMessage());
                }
            }
        }


        Set<Owner_Message__c> ownerMessageDeleteSet = new Set<Owner_Message__c>();
        Set<Message__c> messageDeleteSet = new Set<Message__c>();

        for (Owner_Message__c om : currentOwnerMessageAltIdMap.values()){
            String vinModelIdKey = getVinModelIdKey(om.Ownership__r.Honda_Product__r.Product_Identifier__c, om.Ownership__r.Honda_Product__r.Product_Models__r.Product_Model_Id__c);
            if (newRecallDataMap.containsKey(vinModelIdKey) && newRecallDataMap.get(vinModelIdKey).hasRecall == false){
                ownerMessageDeleteSet.add(new Owner_Message__c(Id=om.Id));
                messageDeleteSet.add(new Message__c(Id=om.Message__c));
            }
            else if (newRecallDataMap.containsKey(vinModelIdKey) && newRecallDataMap.get(vinModelIdKey).hasRecall == true && !newOwnerMessageIdentifiers.contains(om.Alternate_Identifier__c)){ //Recalls were retrieved for this model, but this specific recall was not
                ownerMessageDeleteSet.add(new Owner_Message__c(Id=om.Id));
                messageDeleteSet.add(new Message__c(Id=om.Message__c));
            }
        }

        List<Owner_Message__c> ownerMessageDeleteList = new List<Owner_Message__c>();
        ownerMessageDeleteList.addAll(ownerMessageDeleteSet);
        List<Message__c> messageDeleteList = new List<Message__c>();
        messageDeleteList.addAll(messageDeleteSet);

        delete ownerMessageDeleteList;
        delete messageDeleteList;
    }

    public static void recallsTestMethod(List<OwnGarageController.Product> products, Id userAcctId){
        Map<String, RecallObject> recalls = getRecallData(products, userAcctId);
        saveAndDeleteRecallsData(recalls, userAcctId);
    }

    private static String getVinModelIdKey(String vin, String modelId){
        // Used to match recalls and ownerships by both vin and modelId
        return (((vin != null && vin != '-') ? vin : '') + '_' + modelId);
    }

    private static Message__c getMessageFromCampaign(OwnAPIController.Campaign campaign, String vin, String divisionId, String modelId){
        Message__c message = new Message__c();
        message.Subject__c = campaign.campaignDescription;
        message.Brand__c = divisionId;
        message.Product_Identifier__c = vin;
        message.Source_Id__c = campaign.campaignID;
        message.Alternate_Identifier__c = (!String.isEmpty(vin) ? vin : modelId) + '~' + message.Source_Id__c; // Alternate Identifier is Product Identifier concatenated with Source ID

        String dateStr = campaign.CampaignStartDate;

        if (divisionId == 'P'){
            String dateYear =   dateStr.substring(0, 4);
            String dateMonth =  dateStr.substring(4, 6);
            String dateDay =    dateStr.substring(6, 8);
            dateStr = dateYear + '-' + dateMonth + '-' + dateDay;
        }

        System.debug('%%%% DATESTR ' + dateStr);

        message.Start_Date__c = Date.valueOf(dateStr);

        String b =      '<b>';
        String bEnd =   '</b>';
        String s =      '<span>';
        String sEnd =   '</span>';
        String br = '<br>';

        /*String messageBody = b + 'NHTSA Recall Number: ' + bEnd +   (!String.isEmpty(campaign.recallNumber) ? campaign.recallNumber : '-') + br + br;
        messageBody += b + 'MFR Campaign ID: ' + bEnd +             (!String.isEmpty(campaign.campaignId) ? campaign.campaignId : '-') + br + br;
        messageBody += b + 'Campaign Description: ' + bEnd +        (!String.isEmpty(campaign.campaignDescription) ? campaign.campaignDescription : '-') + br + br;
        messageBody += b + 'Recall Date: ' + bEnd +                 (!String.isEmpty(campaign.recallDate) ? campaign.recallDate : '-') + br + br;
        messageBody += b + 'Recall Status: ' + bEnd +               (campaign.mfrRecallStatus != null && !String.isEmpty(campaign.mfrRecallStatus.value) ? campaign.mfrRecallStatus.value : '-') + br + br;
        messageBody += b + 'Summary: ' + br + bEnd +                (!String.isEmpty(campaign.recallDescription) ? campaign.recallDescription : '-') + br + br;
        messageBody += b + 'Safety Risk: ' + br + bEnd +            (!String.isEmpty(campaign.safetyRiskDescription) ? campaign.safetyRiskDescription : '-') + br + br;
        messageBody += b + 'Remedy: ' + br + bEnd +                 (!String.isEmpty(campaign.remedyDescription) ? campaign.remedyDescription : '-') + br + br;*/
        
        String messageBody = '';
        if(String.isNotEmpty(campaign.recallNumber))
        	messageBody = b + 'NHTSA Recall Number: ' + bEnd + campaign.recallNumber + br + br;    
        if(String.isNotEmpty(campaign.campaignId))
            messageBody += b + 'MFR Campaign ID: ' + bEnd + campaign.campaignId + br + br;
        if(String.isNotEmpty(campaign.campaignDescription))
            messageBody += b + 'Campaign Description: ' + bEnd + campaign.campaignDescription + br + br;
        if (divisionId == 'P'){
            if(String.isNotEmpty(campaign.CampaignStartDate)){
                messageBody += b + 'Campaign Start Date: ' + bEnd + dateStr + br + br;
            }
        }
        if(String.isNotEmpty(campaign.recallDate))
            messageBody += b + 'Recall Date: ' + bEnd + campaign.recallDate + br + br;
        if(campaign.mfrRecallStatus != null && String.isNotEmpty(campaign.mfrRecallStatus.value))
            messageBody += b + 'Recall Status: ' + bEnd + campaign.mfrRecallStatus.value + br + br;
        if(String.isNotEmpty(campaign.recallDescription))
            messageBody += b + 'Summary: ' + br + bEnd + campaign.recallDescription + br + br;
        if(String.isNotEmpty(campaign.safetyRiskDescription))
            messageBody += b + 'Safety Risk: ' + br + bEnd + campaign.safetyRiskDescription + br + br;
        if(String.isNotEmpty(campaign.remedyDescription))
            messageBody += b + 'Remedy: ' + br + bEnd + campaign.remedyDescription + br + br;
        message.Body__c = messageBody;

        return message;
    }


    //get recalls based on ownershipId
    @AuraEnabled
    public static List<Owner_Message__c> getRecallByOwnership(String ownership){
        try {
            Id recallRecordTypeId = Schema.SObjectType.Message__c.getRecordTypeInfosByDeveloperName().get('Recall').getRecordTypeId();
            List<Owner_Message__c> recalls =[SELECT Id,Alternate_Identifier__c,Message__r.Subject__c,Message__r.Start_Date__c,Message__r.Source_Id__c, Message__r.Body__c 
                                                    FROM Owner_Message__c WHERE Message__r.RecordTypeId=:recallRecordTypeId AND Ownership__c=:ownership ];
            return recalls;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class RecallObject{
        OwnGarageController.Product product;
        List<RecallDataObject> recallData;

        Boolean messageInsertFailed = false;
        Boolean hasRecall;

        public Set<String> getMessageIdentifiers(){
            Set<String> identifiers = new Set<String>();
            for (RecallDataObject recallDatum : recallData){
                identifiers.add(recallDatum.message.Alternate_Identifier__c);
            }
            return identifiers;
        }
        public Set<String> getOwnerMessageIdentifiers(){
            Set<String> identifiers = new Set<String>();
            for (RecallDataObject recallDatum : recallData){
                identifiers.add(recallDatum.ownerMessage.Alternate_Identifier__c);
            }
            return identifiers;
        }

        public RecallObject(OwnGarageController.Product p, List<Message__c> mList, Boolean hasRecall){
            this.product = p;
            this.recallData = new List<RecallDataObject>();
            for (Message__c m : mList){
                this.recallData.add(new RecallDataObject(m));
            }
            this.hasRecall = hasRecall;
        }
        public RecallObject(OwnGarageController.Product p, Boolean hasRecall){
            this.product = p;
            this.recallData = new List<RecallDataObject>();
            this.hasRecall = hasRecall;
        }
        public RecallObject(){
        }
    }
    public class RecallDataObject{
        Message__c message;
        Owner_Message__c ownerMessage;

        public void fillOwnerMessage(Id userAcctId, Id ownershipId){
            if (this.message.Id != null){
                this.ownerMessage.Message__c = this.message.Id;
            }
            else{
                System.debug('ERROR: MESSAGE MISSING ID ' + this.message);
            }
            this.ownerMessage.Owner__c = userAcctId;
            this.ownerMessage.Ownership__c = ownershipId;
            this.ownerMessage.Alternate_Identifier__c = this.ownerMessage.Message__c + '~' + this.ownerMessage.Owner__c; //
        }

        public RecallDataObject(Message__c message, Owner_Message__c ownerMessage){
            this.message = message;
            this.ownerMessage = ownerMessage;
        }
        public RecallDataObject(Message__c message){
            this.message = message;
            this.ownerMessage = new Owner_Message__c();
        }
    }
    @AuraEnabled
    public static void update_UserIsRecallsEnabled(Boolean hasRecalls) {
        update new User(Id = UserInfo.getUserId(), HasRecalls__c = hasRecalls);
    }


    @AuraEnabled
    public static  List<Owner_Message__c> getOTAByOwnership(String ownership){
        try {
            Id recallRecordTypeId = Schema.SObjectType.Message__c.getRecordTypeInfosByDeveloperName().get('Recall').getRecordTypeId();
                List<Owner_Message__c> recalls =[SELECT Id,Alternate_Identifier__c,Message__r.Subject__c,Message__r.Start_Date__c,Message__r.Source_Id__c, 
                                                Message__r.Body__c FROM Owner_Message__c WHERE Message__r.RecordTypeId=:recallRecordTypeId AND Ownership__c=:ownership ];
            return recalls;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

//get recalls based on ownershipId
   
    public class Recall{
        List<Message__c> messages;
        Set<String> newMessageIdentifiers;
    }

    @AuraEnabled
    public static String getDealerFromObj(String ownershipId){
        System.debug('ownershipId '+ownershipId);
        List<Ownership__c> ownerships = [Select Id, Preferred_Dealer__c, Preferred_Dealer__r.POIID__c, Servicing_Dealer__c, Servicing_Dealer__r.POIID__c From Ownership__c where Id =: ownershipId Limit 1];
        System.debug('ownerships '+ ownerships);
        System.debug('ownershipId '+ ownershipId);
        if(ownerships.size() > 0){
            if(String.isNotEmpty(ownerships[0].Preferred_Dealer__r.POIID__c)){
                System.debug('Preferred_Dealer__r '+ ownerships[0].Preferred_Dealer__r.POIID__c);
                return ownerships[0].Preferred_Dealer__r.POIID__c;
            }
            if(String.isNotEmpty(ownerships[0].Servicing_Dealer__r.POIID__c)){
                System.debug('Servicing_Dealer__r '+ ownerships[0].Servicing_Dealer__r.POIID__c);
                return ownerships[0].Servicing_Dealer__r.POIID__c;
            }
        }
        return '';
    }
}
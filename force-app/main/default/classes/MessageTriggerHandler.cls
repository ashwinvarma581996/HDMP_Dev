public class MessageTriggerHandler {
    
    public void insertOwnersMessages(List<Message__c> messageList){
        try{
            system.debug('@@Test Sarted');
        Map<String,List<Message__c>> vinsMap=new Map<String,List<Message__c>>();
        List<Owner_Message__c> ownerMessages=new List<Owner_Message__c>(); 
        String recordTypeVar=system.Label.OTARecordType;    
        Id otaRecordID = Schema.SObjectType.Message__c.getRecordTypeInfosByName().get(recordTypeVar).getRecordTypeId();
        for(Message__c m:messageList){
            if(m.RecordTypeId == otaRecordID){
                if(m.Product_Identifier__c != null || String.isBlank(m.Product_Identifier__c)){
                    if(!vinsMap.containsKey(m.Product_Identifier__c)){
                        List<Message__c> messageIdList=new List<Message__c>();
                        messageIdList.add(m);
                        system.debug('@@Test MessageId'+m.Id);
                        vinsMap.put(m.Product_Identifier__c,messageIdList);
                    }else{
                        List<Message__c> messageIdList = vinsMap.get(m.Product_Identifier__c);
                        messageIdList.add(m);
                        vinsMap.put(m.Product_Identifier__c,messageIdList);
                    }
                }
            }
        }
        if(vinsMap.keySet().Size() > 0){
            List<Ownership__c> ownerShipRec=[SELECT Id,Name,Honda_Product__r.Product_Identifier__c,Product_Owner__r.Id FROM Ownership__c where Honda_Product__r.Product_Identifier__c IN:vinsMap.keySet()];
         
            if(ownerShipRec.Size() > 0){
                for(Ownership__c o:ownerShipRec){
                    for(Message__c m:vinsMap.get(o.Honda_Product__r.Product_Identifier__c)){
                        Owner_Message__c ownerMessage=new Owner_Message__c();
                        ownerMessage.Message__c=m.Id;
                        ownerMessage.Ownership__c=o.Id;
                        ownerMessage.Owner__c=o.Product_Owner__r.Id; 
                        ownerMessage.Name=m.Subject__c;
                        ownerMessage.Alternate_Identifier__c=m.Id+'~'+o.Product_Owner__r.Id;
                        ownerMessage.Received_Date__c= System.Now();
                        ownerMessages.add(ownerMessage);
                    }
                }
            }
        }
        
        if(ownerMessages.size() > 0){
            system.debug('@@Test MessageEnd');
            Database.SaveResult[] srList = Database.insert(ownerMessages, false); 
        }
        }catch(exception e){
                system.debug('Excpetion'+e.getStackTraceString());
               system.debug('Excpetion'+e.getLineNumber());
            }   
    }
    
}
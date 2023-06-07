public class OwnershipTriggerHandler {
    
    public void insertOwnersMessages(List<Ownership__c> ownershipList){
        try{
            set<String> vinSet=new set<String>();
            set<String> productSet=new set<String>();
            map<String,String> productMap=new map<String,String>();
            List<Owner_Message__c> ownerMessages=new List<Owner_Message__c>(); 
            map<String,List<Message__c>> messageMap=new map<String,List<Message__c>>();
            String recordTypeVar=system.Label.OTARecordType; 
            Id otaRecordID = Schema.SObjectType.Message__c.getRecordTypeInfosByName().get(recordTypeVar).getRecordTypeId();
            system.debug('@@InsideAfter'+otaRecordID);
            for(Ownership__c o:ownershipList){
                if(!String.isBlank(o.Honda_Product__c) && o.Honda_Product__c != null){
                    productSet.add(o.Honda_Product__c);
                }
            }
            if(productSet.size()> 0){
                List<Honda_Product__c> products=[select id,Product_Identifier__c from Honda_Product__c where id IN:productSet];
                for(Honda_Product__c h:products){
                    if(!String.isBlank(h.Product_Identifier__c) && h.Product_Identifier__c != null){
                        vinSet.add(h.Product_Identifier__c);
                        productMap.put(h.id,h.Product_Identifier__c);
                    }
                }
            }
            system.debug('@@InsideAfter'+vinSet.Size());
            system.debug('@@InsideAfter'+vinSet);
           Datetime dt=System.now();
            if(vinSet.Size() > 0){
                List<Message__c> messages = new List<Message__c>();
                if(Test.isRunningTest()){
                    messages=[select id,Product_Identifier__c,Subject__c from Message__c where RecordTypeId=:otaRecordID AND Product_Identifier__c IN :vinSet];
                }else{
                    messages=[select id,Product_Identifier__c,Subject__c from Message__c where RecordTypeId=:otaRecordID AND Product_Identifier__c IN :vinSet AND Start_Date__c < :dt AND End_Date__c >= :dt];
                }
                system.debug('@@InsideAftermsg'+messages.Size());
                for(Message__c m:messages){
                    if(!messageMap.containsKey(m.Product_Identifier__c)){
                        List<Message__c> messageList=new List<Message__c>();
                        messageList.add(m);
                        system.debug('@@InsideAfter'+m.Product_Identifier__c);
                        messageMap.put(m.Product_Identifier__c,messageList);
                    }else{
                        List<Message__c> messageList=messageMap.get(m.Product_Identifier__c);
                        messageList.add(m);
                        messageMap.put(m.Product_Identifier__c,messageList);
                    }
                }
                
            }
            
            for(Ownership__c o:ownershipList){
                if(productMap.containsKey(o.Honda_Product__c)){
                    if(messageMap.containsKey(productMap.get(o.Honda_Product__c))){
                        for(Message__c m:messageMap.get(productMap.get(o.Honda_Product__c))){
                            Owner_Message__c ownerMessage=new Owner_Message__c();
                            ownerMessage.Message__c=m.Id;
                            ownerMessage.Ownership__c=o.Id;
                            ownerMessage.Owner__c=o.Product_Owner__c; 
                            ownerMessage.Name=m.Subject__c;
                            ownerMessage.Alternate_Identifier__c=m.Id+'~'+o.Product_Owner__c;
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
            system.debug('@@Excpetion'+e.getStackTraceString());
            system.debug('@@Excpetion'+e.getLineNumber());
        } 
    }
    
    public void UpdateOwnersMessages(List<Ownership__c> ownershipList,Map<Id,Ownership__c> oldOwnershipMap){
        try{
            Set<String> ownershipIds=new Set<String>();
            List<Owner_Message__c> ownerMessageToUpdate= new List<Owner_Message__c>();
              for(Ownership__c o:ownershipList){
                if(o.Managed__c == false && oldOwnershipMap.get(o.Id).Managed__c == true){
                    ownershipIds.add(o.Id);
                }
            }
            
            if(ownershipIds.Size() > 0){
                String recordTypeVar=system.Label.OTARecordType; 
            Id otaRecordID = Schema.SObjectType.Message__c.getRecordTypeInfosByName().get(recordTypeVar).getRecordTypeId();
            Id recallRecordID = Schema.SObjectType.Message__c.getRecordTypeInfosByName().get('Recall').getRecordTypeId();

             List<Owner_Message__c>   ownerMessage=[select id,Is_Read__c,Read_Date__c from Owner_Message__c where Ownership__c in :ownershipIds AND (Message__r.RecordTypeId=:otaRecordID OR Message__r.RecordTypeId=:recallRecordID)];
              
                for(Owner_Message__c om:ownerMessage){
                    om.Is_Read__c=false;
                    om.Read_Date__c=null;
                    ownerMessageToUpdate.add(om);
                }   
            
            }
            
            if(ownerMessageToUpdate.Size() > 0){
                Database.update(ownerMessageToUpdate,false);
            }
            
        }catch(exception e){
            system.debug('@@Excpetion'+e.getStackTraceString());
            system.debug('@@Excpetion'+e.getLineNumber());
        } 
    }
    //Added By Imtiyaz to update Product_Service_Note__c after insert ownership
    @future
    public static void addOwnershipToProductServiceNotes(Set<Id> ownershipsSet){
        User user = [SELECT FederationIdentifier FROM User Where Id =: UserInfo.getUserId()];
        List<Product_Service_Note__c> productServiceNotes = new List<Product_Service_Note__c>();
        Map<String, Id> alternateOwnershipStringOwnershipIdMap = new Map<String, Id>();
        for(Ownership__c ownership : [SELECT Honda_Product__c, Honda_Product__r.Product_Identifier__c, Honda_Product__r.Alternate_Product_Identifier__c FROM Ownership__c 
                                      Where Id IN : ownershipsSet]){
            if(ownership.Honda_Product__r.Product_Identifier__c != Null){
                alternateOwnershipStringOwnershipIdMap.put(user.FederationIdentifier + '_' + ownership.Honda_Product__r.Product_Identifier__c, ownership.Id);
            }else{
                alternateOwnershipStringOwnershipIdMap.put(user.FederationIdentifier + '_' + ownership.Honda_Product__r.Alternate_Product_Identifier__c, ownership.Id);
            }
        }
        if(alternateOwnershipStringOwnershipIdMap.size() > 0){
			for(Product_Service_Note__c productServiceNote : [SELECT Id, Name, Ownership__c, Alternate_Ownership__c FROM Product_Service_Note__c 
                                               Where Alternate_Ownership__c IN: alternateOwnershipStringOwnershipIdMap.keySet() And Alternate_Ownership__c != Null]){
               if(alternateOwnershipStringOwnershipIdMap.containsKey(productServiceNote.Alternate_Ownership__c)){
                   productServiceNote.Ownership__c = alternateOwnershipStringOwnershipIdMap.get(productServiceNote.Alternate_Ownership__c);
                   productServiceNote.Alternate_Ownership__c = '';
                   productServiceNotes.add(productServiceNote);
               }
            }
        }
        if(productServiceNotes.size() > 0){
            update productServiceNotes;
        }
    }
}
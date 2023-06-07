trigger MessageTrigger on Message__c (After insert, After update) {
    if(Trigger.isInsert || Trigger.isUpdate){
        MessageTriggerHandler m=new MessageTriggerHandler();
        m.insertOwnersMessages(Trigger.new);
    }
}
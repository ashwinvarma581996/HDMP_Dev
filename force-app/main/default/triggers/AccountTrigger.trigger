trigger AccountTrigger on Account (before insert,before update, after update) {
    if(Trigger.isBefore && Trigger.isUpdate){  
       B2B_AccountTriggerHelper.beforeUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap); 
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        B2B_AccountTriggerHelper.afterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap); 
    }
    if(Trigger.isBefore && Trigger.isInsert){
        B2B_AccountTriggerHelper.beforeInsert(Trigger.new);
    }
}
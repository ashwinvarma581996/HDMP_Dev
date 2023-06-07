trigger MegacategoryMappingTrigger on MegaCategoryMapping__c (before insert, before update) {
    
    if(Trigger.isInsert && Trigger.isBefore){
        B2BMegacategoryMappingTriggerHandler.beforeInsert(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        B2BMegacategoryMappingTriggerHandler.beforeUpdate(Trigger.New);
    }
}
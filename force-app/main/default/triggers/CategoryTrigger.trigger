trigger CategoryTrigger on ProductCategory (before insert, before update) {

    if(Trigger.isInsert && Trigger.isBefore){
        B2BCategoryTriggerHandler.beforeInsert(Trigger.New);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        B2BCategoryTriggerHandler.beforeUpdate(Trigger.New);
    }
}
trigger OrderTrigger on Order (before insert,after insert,before update, after update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        // HDMP-10756 starts here
        //B2B_OrderTriggerHelper.populateDataFromCart(Trigger.new);
        // HDMP-10756 ends here
        //AA: added to handle dealer field update
        B2B_OrderTriggerHelper.updateOrderDealer(Trigger.new);
    }
    else if(Trigger.isAfter && Trigger.isUpdate){
        B2B_OrderTriggerHelper.afterUpdate(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    }
    
}
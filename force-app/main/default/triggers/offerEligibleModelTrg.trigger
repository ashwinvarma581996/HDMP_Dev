trigger offerEligibleModelTrg on Offer_Eligible_Models__c (before insert,before update,after insert,after update,before delete,after undelete){
     TriggerHandler handler = new offerEligibleModelHandler(Trigger.isExecuting,Trigger.size);
     if(TriggerAdministrationHandler.validateExecutionStatus('offerEligibleModelTrg')){
    switch on Trigger.operationType {
            when BEFORE_INSERT {
				handler.beforeInsert(Trigger.new, Trigger.oldMap); 
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                handler.beforeDelete(Trigger.old, Trigger.oldMap); 
                
            }
            when AFTER_INSERT {
            	handler.afterInsert(Trigger.new,Trigger.newMap);
            }
            when AFTER_UPDATE {
                
            }
            when AFTER_DELETE {
                // handler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                // handler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
    }
    
}
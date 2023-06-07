trigger OfferHeaderTrigger on Offer_Header__c (before insert,after insert,before delete,after undelete) {
    
    TriggerHandler handler = new OfferHeaderHandler(Trigger.isExecuting, Trigger.size);
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            handler.beforeInsert(Trigger.new,Trigger.newMap);
        }
        when BEFORE_UPDATE {
            handler.beforeInsert(Trigger.new,Trigger.newMap); 
        }
        when BEFORE_DELETE {
            // handler.beforeDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_INSERT {
            handler.afterInsert(Trigger.new, Trigger.newMap);
        }
        when AFTER_UPDATE {
            // handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
        when AFTER_DELETE {
            // handler.afterDelete(Trigger.old, Trigger.oldMap);
        }
        when AFTER_UNDELETE {
            // handler.afterUndelete(Trigger.new, Trigger.newMap);
        }
    }
}
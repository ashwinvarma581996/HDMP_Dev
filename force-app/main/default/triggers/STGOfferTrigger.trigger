//****************************************************************************** 
// File Name:       STGOfferTrigger.trg
// Summary:        Trigger on Stage Object for inbound processing
// Created On:      03/15/2023
// Created By:      Rama Iyer
// JIRA Story :     OMP-156,OMP-76,OMP-104,OMP-103
//===============================================================================

trigger STGOfferTrigger on STG_Offers__c (before insert,before update,after insert,after update,before delete,after undelete) {
  TriggerHandler handler = new STGOfferTriggerHandler(Trigger.isExecuting, Trigger.size);

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
                 handler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                 handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                // handler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                // handler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
    }
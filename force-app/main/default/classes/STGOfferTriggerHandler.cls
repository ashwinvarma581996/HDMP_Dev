//****************************************************************************** 
// File Name:       STGOfferTriggerHandler.cls
// Summary:         STGOfferTrigger Handler process incoming records on STG Offer Records
// Created On:      02-22-2023
// Created By:      Rama Iyer
// Test Class : OfferManagmentInboundProcessing_Test
// Test Classes:    STGOfferTriggerHelper_Test.cls
// JIRA Story :     OMP-156,OMP-76,OMP-104,OMP-103
//===============================================================================
public without sharing class STGOfferTriggerHandler  implements TriggerHandler {
    
        private boolean triggerIsExecuting; 
    private integer triggerSize; 
    public STGOfferTriggerHelper helper;
    public STGOfferTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new STGOfferTriggerHelper();
    }
    
    public void beforeInsert(List<STG_Offers__c> newOffers,Map<id,SObject> newOfferMap) {
        //helper.placeholder();
        //new STGOfferTriggerHelper().seperateNewandMatchingRecords(newOffers);
       }
    public void beforeUpdate(List<STG_Offers__c> oldOffers, List<STG_Offers__c> newOffers, Map<ID, SObject> oldOfferMap, Map<ID, SObject> newOfferMap) {
        new STGOfferTriggerHelper().seperateNewandMatchingRecords(newOffers);
    }
    public void beforeDelete(List<STG_Offers__c> oldOffers, Map<ID, SObject> oldOfferMap) {
        // helper.doTask5();
        // helper.doTask1();
    }
    public void afterInsert(List<STG_Offers__c> newOffers, Map<ID, SObject> newOfferMap) {
       // new STGOfferTriggerHelper().seperateNewandMatchingRecords(newOffers);
       
    }
    public void afterUpdate(List<STG_Offers__c> oldOffers, List<STG_Offers__c> newOffers, Map<ID, SObject> oldOfferMap, Map<ID, SObject> newOfferMap) {
                // helper.doTask5();
     //   new STGOfferTriggerHelper().seperateNewandMatchingRecords(newOffers);
    }
    public void afterDelete(List<STG_Offers__c> oldOffers, Map<ID, SObject> oldOfferMap) {
        // helper.doTask3();
        // helper.doTask1();
    }
    public void afterUndelete(List<STG_Offers__c> newOffers, Map<ID, SObject> newOfferMap) {
        // helper.doTask4();
        // helper.doTask2();
    }    

}
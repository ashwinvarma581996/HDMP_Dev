public without sharing class offerEligibleModelHandler implements TriggerHandler {
	private boolean triggerIsExecuting; 
    private integer triggerSize; 
    public offerEligibleModelHelper helper;
    
    public offerEligibleModelHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new offerEligibleModelHelper();
    }
    public void beforeUpdate(List<Offer_Eligible_Models__c> oldOffers, List<Offer_Eligible_Models__c> newOffers, Map<ID, SObject> oldOfferMap, Map<ID, SObject> newOfferMap) {
        offerEligibleModelHelper.editCheck(newOffers);
       // offerEligibleModelHelper.editCheckForPrism(newOfferMap,oldOfferMap);
    }
    public void beforeDelete(List<Offer_Eligible_Models__c> oldOffers, Map<ID, SObject> oldOfferMap) {
        offerEligibleModelHelper.deleteCheck(oldOffers);
    }
    
    public void afterUpdate(List<Offer_Eligible_Models__c> oldOffers, List<Offer_Eligible_Models__c> newOffers, Map<ID, SObject> oldOfferMap, Map<ID, SObject> newOfferMap) {
        //helper.outboundIntegrationCallout(newOffers);// Commented by Rama as outbound is throwing Null Pointer Exceptions
        // helper.doTask5();
    }
    public void afterDelete(List<Offer_Eligible_Models__c> oldOffers, Map<ID, SObject> oldOfferMap) {
        // helper.doTask3();
        // helper.doTask1();
    }
    public void afterUndelete(List<Offer_Eligible_Models__c> newOffers, Map<ID, SObject> newOfferMap) {
        // helper.doTask4();
        // helper.doTask2();
    }
    public void afterInsert(List<Offer_Eligible_Models__c> newOEMs, Map<ID, SObject> newOfferMap) {
        offerEligibleModelHelper.updateSort(newOEMs);
    }
    public void beforeInsert(List<Offer_Eligible_Models__c> newOEMs,Map<id,SObject> newOfferMap) {
        offerEligibleModelHelper.updateOEMs(this.triggerIsExecuting,newOEMs);
        offerEligibleModelHelper.processOEMs(newOEMs);
        offerEligibleModelHelper.updateDefaultImage(newOEMs);
        //offerEligibleModelHelper.defaultFieldValues(newOEMs);
        offerEligibleModelHelper.defaultOEMFieldValues(newOEMs);
       }
    
    
}
public class OfferHeaderHandler implements TriggerHandler {
  private boolean triggerIsExecuting;
    private integer triggerSize;
    public OfferTriggerHelper helper;
    public OfferHeaderHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new OfferTriggerHelper();
    }
    public void beforeInsert(List<Offer_Header__c> newOfferHeaders,Map<id,SObject> newOfferHeaderMap) {
         new OfferHeaderTriggerHelper().preventDuplicateRecords(newOfferHeaders);
         
       }
    public void beforeUpdate(List<Offer_Header__c> oldOfferHeaders, List<Offer_Header__c> newOfferHeaders, Map<ID, SObject> oldOfferHeaderMap, Map<ID, SObject> newOfferHeaderMap) {
        // helper.doTask3();
        // helper.doTask4();
    }
    public void beforeDelete(List<Offer_Header__c> oldOfferHeaders, Map<ID, SObject> oldOfferHeaderMap) {
        // helper.doTask5();
        // helper.doTask1();
    }
    public void afterInsert(List<Offer_Header__c> newOfferHeaders, Map<ID, SObject> newOfferHeaderMap) {
      
    }
    public void afterUpdate(List<Offer_Header__c> oldOfferHeaders, List<Account> newOfferHeaders, Map<ID, SObject> oldOfferHeaderMap, Map<ID, SObject> newOfferHeaderMap) {
        // helper.doTask4();
        // helper.doTask5();
    }
    public void afterDelete(List<Offer_Header__c> oldOfferHeaders, Map<ID, SObject> oldOfferHeaderMap) {
        // helper.doTask3();
        // helper.doTask1();
    }
    public void afterUndelete(List<Offer_Header__c> newOfferHeaders, Map<ID, SObject> newOfferHeaderMap) {
        // helper.doTask4();
        // helper.doTask2();
    }
}
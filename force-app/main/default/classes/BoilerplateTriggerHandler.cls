public without sharing class BoilerplateTriggerHandler implements TriggerHandler {
    
    private boolean triggerIsExecuting; 
    private integer triggerSize; 
    public BoilerplateTriggerHelper helper;
    
      public BoilerplateTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.helper = new BoilerplateTriggerHelper();
    }
    
        public void beforeInsert(List<Boilerplate__c> newBoilerplates,Map<id,SObject> newBoilerplateMap) {      
            new BoilerplateTriggerHelper().preventDuplicateRecords(newBoilerplates);
            new BoilerplateTriggerHelper().defaultStatusWIPWhenClone(newBoilerplates);
        system.debug('calling from before insert');
       }
    
    public void beforeUpdate(List<Boilerplate__c> oldBoilerplates, List<Boilerplate__c> newBoilerplates, Map<ID, SObject> oldBoilerplateMap, Map<ID, SObject> newBoilerplateMap) {
        new BoilerplateTriggerHelper().validateStatusOfBoilerPlate(newBoilerplates);
    }
    
    public void beforeDelete(List<Boilerplate__c> oldBoilerplates, Map<ID, SObject> oldBoilerplateMap) {
         new BoilerplateTriggerHelper().validateStatusOfBoilerPlateDelete(oldBoilerplates);
    }
    
        public void afterInsert(List<Boilerplate__c> newBoilerplate, Map<ID, SObject> newBoilerplateMap) {
       // helper.doTask1();
        // helper.doTask2();

    }
    public void afterUpdate(List<Boilerplate__c> oldBoilerplates, List<Boilerplate__c> newBoilerplates, Map<ID, SObject> oldBoilerplateMap, Map<ID, SObject> newBoilerplateMap) {
        // helper.doTask3();
    }
    public void afterDelete(List<Boilerplate__c> oldBoilerplates, Map<ID, SObject> oldBoilerplateMap) {
        // helper.doTask4();
        // helper.doTask5();
    }
    public void afterUndelete(List<Boilerplate__c> newBoilerplates, Map<ID, SObject> newBoilerplateMap) {
        // helper.doTask5();
        // helper.doTask9();
    }

}
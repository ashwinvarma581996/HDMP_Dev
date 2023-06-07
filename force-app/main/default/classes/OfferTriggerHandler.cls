public without sharing class OfferTriggerHandler implements TriggerHandler {
        private boolean triggerIsExecuting; 
        private integer triggerSize; 
        public OfferTriggerHelper helper;
        public OfferTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
            this.triggerIsExecuting = triggerIsExecuting;
            this.triggerSize = triggerSize;
            this.helper = new OfferTriggerHelper(); 
        }
        public void beforeInsert(List<Offers__c> newOffers,Map<id,SObject> newOfferMap) {
            new OfferTriggerHelper().updateOfferRecord(newOffers,newOfferMap);  
           // new OfferTriggerHelper().hasMoreActiveOffers(newOffers); //Addedc to check if on offer header is having more then one active offer , if yes then through Error.
            new OfferTriggerHelper().updateLatestVersion(newOffers);
            new OfferTriggerHelper().updateDefaultBoilerPlate(newOffers);
            new OfferTriggerHelper().updateinboundOffer(newOffers,triggerIsExecuting);
            new OfferTriggerHelper().populateVehicleTypeCode(newOffers,null);
            new OfferTriggerHelper().populateSalesProgramCode(newOffers);
        }
        public void beforeUpdate(List<Offers__c> oldOffers, List<Offers__c> newOffers, Map<ID, SObject> oldOfferMap, Map<ID, SObject> newOfferMap) {
            new OfferTriggerHelper().hasMoreActiveOffers(newOffers); //Addedc to check if on offer header is having more then one active offer , if yes then through Error.
        	//new OfferTriggerHelper().populateVehicleTypeCode(newOffers,oldOfferMap);
        	new OfferTriggerHelper().uncheckPreview(newOfferMap,oldOfferMap);
        }
        
        public void beforeDelete(List<Offers__c> oldOffers, Map<ID, SObject> oldOfferMap) {
           
        }
        public void afterInsert(List<Offers__c> newOffers, Map<ID, SObject> newOfferMap) {
            new OfferTriggerHelper().updateSequenceNumber(newOffers);
            new OfferTriggerHelper().CreateChildrecordsBasedOnOldOffer(newOffers);
            
            
            
        } 
        public void afterUpdate(List<Offers__c> oldOffers, List<Offers__c> newOffers, Map<ID, SObject> oldOfferMap, Map<ID, SObject> newOfferMap) {
            helper.outboundIntegrationCallout(newOffers,oldOfferMap);
            new OfferTriggerHelper().markOfferAsExpired(newOffers,(map<Id,Offers__c>)newOfferMap,(map<Id,Offers__c>)oldOfferMap); 
          
        }
        public void afterDelete(List<Offers__c> oldOffers, Map<ID, SObject> oldOfferMap) {
            
        }
        public void afterUndelete(List<Offers__c> newOffers, Map<ID, SObject> newOfferMap) {
            
        }
    }
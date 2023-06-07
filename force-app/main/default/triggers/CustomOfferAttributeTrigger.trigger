trigger CustomOfferAttributeTrigger on Custom_Offer_Attribute__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        CustomOfferAttributeTriggerHandler.populateAlternateCustomOfferAttributeId(Trigger.new);
    }
}
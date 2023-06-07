public class CustomOfferAttributeTriggerHandler {
    public static void populateAlternateCustomOfferAttributeId(List<Custom_Offer_Attribute__c> newRecords) {
        for (Custom_Offer_Attribute__c record : newRecords) {
            record.Alternate_Custom_Offer_attribute_ID__c = record.Offer_Attribute_Code__c + ' ~ ' + record.Offer_Status_Code_for_Publishing__c + ' ~ ' + record.Brand__c;
            record.Name = record.Offer_Attribute_Name__c;
        }
    }
}
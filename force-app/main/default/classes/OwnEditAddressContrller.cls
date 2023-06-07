public without sharing class OwnEditAddressContrller {
    @AuraEnabled
    public static InitalDataWrapper getInitalData(String accountId) {
        InitalDataWrapper result = new InitalDataWrapper();
        
        result.accountRecord = [SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode FROM Account WHERE Id = :accountId];
        result.states = getPickListOptions('Ownership__c', 'License_Plate_State_Name__c');

        return result;
    }

    @AuraEnabled
    public static void updateAddress(Account accountRecord) {
        try {
            Update accountRecord;
        } catch (Exception e) {
            throw e;
        }
    }

    public static List<PickListOption> getPickListOptions(String objectApi, String fieldApi) {
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectApi);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(fieldApi).getDescribe().getPickListValues();
        List<PickListOption> result = new List<PickListOption> ();

        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            result.add(new PickListOption(objPickList.getLabel(), objPickList.getValue()));
        }

        return result;
    }

    public class InitalDataWrapper {
        @AuraEnabled
        public Account accountRecord;
        @AuraEnabled
        public List<PickListOption> states;
    }

    public class PickListOption {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public PickListOption(String label, String value) {
            this.label = label;
            this.value = label;
        }
    }

    @AuraEnabled
    public static List<PickListOption> getStateData() {
        List<PickListOption> result = new List<PickListOption>();
        
        result = getPickListOptions('Ownership__c', 'License_Plate_State_Name__c');

        return result;
    }
}
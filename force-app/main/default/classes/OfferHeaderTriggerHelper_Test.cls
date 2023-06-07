@isTest 
public class OfferHeaderTriggerHelper_Test {
    
    static testMethod void testPreventDuplicateRecords() {
        List<Offer_Header__c>  lstheader = new list<Offer_Header__c>();
        lstheader.add(new Offer_Header__c(Name='Testing offer Header',Brand__c='A'));
        lstheader.add(new Offer_Header__c(Name='Testing offer Header',Brand__c='A'));
        INSERT lstheader;
        new OfferHeaderTriggerHelper().preventDuplicateRecords(lstheader);
    }
}
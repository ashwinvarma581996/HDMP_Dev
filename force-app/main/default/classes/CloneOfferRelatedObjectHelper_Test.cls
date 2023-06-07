@isTest
public class CloneOfferRelatedObjectHelper_Test {
    static testMethod void getOfferRecord_test() {
        List<Offers__c>  lstoffer = new list<Offers__c>();
        lstoffer.add(new Offers__c(Name  = 'test',Brand__c = 'A',Product_Type__c  = 'Used'));
        insert lstoffer;
        CloneOfferRelatedObjectHelper.getOfferRecord(lstoffer[0].id);
    } 
    static testMethod void offerclone_test(){
        id offerRecordTypeId = Schema.SObjectType.Offers__c.getRecordTypeInfosByName().get('New Special Finance').getRecordTypeId();
        id offerHeaderRecordTypeId = Schema.SObjectType.Offer_Header__c.getRecordTypeInfosByName().get('New Special Finance').getRecordTypeId();
        id offerEligibleModelRecordTypeId = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('New Special Finance').getRecordTypeId();
        
        List<Offer_Header__c>  lstheader = new list<Offer_Header__c>();
        lstheader.add(new Offer_Header__c(Name='Testing offer Header',Brand__c='A',recordTypeId=offerHeaderRecordTypeId,status__c='WIP'));
        INSERT lstheader;
        
        List<Offers__c>  lstoffer = new list<Offers__c>();
        lstoffer.add(new Offers__c(Name  = 'test',Brand__c = 'A',Product_Type__c  = 'Used',Offer_Header__c=lstheader[0].id,recordTypeId=offerRecordTypeId,status__c='WIP'));
        insert lstoffer;
        
        List<Offer_Eligible_Models__c>  lstEligiblemodel = new list<Offer_Eligible_Models__c>();
        lstEligiblemodel.add(new Offer_Eligible_Models__c(Name  = 'test',Brand__c = 'A',Offer__c = lstoffer[0].id,recordTypeiD=offerEligibleModelRecordTypeId));
        insert lstEligiblemodel;
        
        CloneOfferRelatedObjectHelper.offerclone(lstoffer[0].id,'testrecord create','test description');
        CloneOfferRelatedObjectHelper.offerclonewithoutheader(lstoffer[0].id);
    }
}
@isTest  
public class OfferTriggerHelper_Test {
    static testMethod void updateSequenceNumber_test() {
        List<Offers__c>  lstoffer = new list<Offers__c>();
        lstoffer.add(new Offers__c(Name  = 'test',Brand__c = 'A',Product_Type__c  = 'Used'));
        insert lstoffer;
        new OfferTriggerHelper().updateSequenceNumber(lstoffer); 
    }
    static testMethod void CreateOfferHeader_test() {
        List<Offers__c>  lstoffer = new list<Offers__c>();
        id offerRecordTypeId = Schema.SObjectType.Offers__c.getRecordTypeInfosByName().get('New Special Finance').getRecordTypeId();
         id offerHeaderRecordTypeId = Schema.SObjectType.Offer_Header__c.getRecordTypeInfosByName().get('New Special Finance').getRecordTypeId();
        lstoffer.add(new Offers__c(Name  = 'test',Brand__c = 'A',Product_Type__c  = 'Used',Custom_clone__c= false,recordtypeid=offerRecordTypeId));
        insert lstoffer;
        new OfferTriggerHelper().CreateOfferHeader(lstoffer,offerHeaderRecordTypeId);
    }  
    static testMethod void updateDefaultBoilerPlate_test() {
        List<Offer_Header__c>  lstheader = new list<Offer_Header__c>();
        lstheader.add(new Offer_Header__c(Name='Testing offer Header',Brand__c='A'));
        INSERT lstheader;
        
        List<Boilerplate__c>  lstboilerplate = new list<Boilerplate__c>();
        lstboilerplate.add(new Boilerplate__c(Name  = 'National Honda spd 2 Tier w/grad – Certain Vehicles',Brand__c = 'A',Offer_Title__c='Offer title',
                                             Short_Description__c ='Short Desc',Detailed_Description__c ='Detailed desc',Terms_Conditions__c ='terms & Cond',
                                             Legal_Disclaimer__c ='Legal desc'));
        insert lstboilerplate;
        List<Offers__c>  lstoffer = new list<Offers__c>();
        
        id offerrecordtypeid = Schema.SObjectType.Offers__c.getRecordTypeInfosByName().get('New Special Finance').getRecordTypeId();
        //lstoffer.add(new Offers__c(Name  = 'test default Boiler',Brand__c = 'A', RecordTypeId =offerrecordtypeid,Offer_Header__c=lstheader[0].id));
        lstoffer.add(new Offers__c(Name  = 'test regional',Brand__c = 'A', RecordTypeId =offerrecordtypeid,Offer_Availability__c ='Regional',
                                   Sales_Program_CD__c =123,AHFC_Sales_Program_ID__c='AHFCI',AHM_Sales_Program_ID__c='AHM',Offer_Header__c=lstheader[0].id,
                                   Boilerplate__c=lstboilerplate[0].id,Dealer_Contribution__c='12',Loyalty_Cash__c =23,Additional_Cash__c =34,Captive_Cash__c =45,
                                  Conquest_Cash__c =56,Other_Captive_Cash__c =67));
        insert lstoffer;
        
        Offers__c  lstoffercopy  = lstoffer[0].clone(false, false, false, false);
        insert lstoffercopy;
        new OfferTriggerHelper().updateDefaultBoilerPlate(lstoffer);
        new OfferTriggerHelper().updateOfferHeader(new list<Offers__c> {lstoffercopy});
        new OfferTriggerHelper().displayErrorMessage(lstoffer,'Show Error');
        
    }
    static testMethod void updateOfferRecord_test(){
        //Offers__c offob =new Offers__c(Name  = 'test',Brand__c = 'A', RecordTypeId =offerrecordtypeid);
        //insert offob;
    }
    static testMethod void updateinboundOffer_test(){
        List<Offers__c> offers = new List<Offers__c>();
        
        List<Offer_Header__c>  lstheader = new list<Offer_Header__c>();
        lstheader.add(new Offer_Header__c(Name='Testing offer Header1',Brand__c='A'));
        INSERT lstheader;
        
        for(Integer i=0; i<5; i++) {
            Offers__c offObj = new Offers__c();
            offObj.Name = 'Test Offer ' + i;
            offObj.Version_Number__c =123;
            offObj.Offer_Header__c=lstheader[0].id;    
            offers.add(offObj);
        }
        Test.startTest();
        OfferTriggerHelper helper = new OfferTriggerHelper();
        helper.updateinboundOffer(offers,false);
        Test.stopTest();
        
    }
    static testMethod void testSetVehicleTypeCode(){
         List<Offers__c>  lstoffer = new list<Offers__c>();
        id offerRecordTypeId = Schema.SObjectType.Offers__c.getRecordTypeInfosByName().get('CPO Special Finance').getRecordTypeId();
         id offerHeaderRecordTypeId = Schema.SObjectType.Offer_Header__c.getRecordTypeInfosByName().get('CPO Special Finance').getRecordTypeId();
        lstoffer.add(new Offers__c(Name  = 'test Vehicle',Brand__c = 'A',Custom_clone__c= false,recordtypeid=offerRecordTypeId));
        insert lstoffer;
        new OfferTriggerHelper().setVehicleTypeCode(lstoffer[0]);
    }
}
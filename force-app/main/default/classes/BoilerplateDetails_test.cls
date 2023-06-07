@isTest
public class BoilerplateDetails_test {

    static testMethod void getBoilerPlateDetails_Test() {
     List<Boilerplate__c>  lstboilerplate = new list<Boilerplate__c>();
        lstboilerplate.add(new Boilerplate__c(Name  = 'National Honda spd 2 Tier w/grad – Certain Vehicles',Brand__c = 'A'));
        insert lstboilerplate;
         List<Offers__c>  lstoffer = new list<Offers__c>();
        lstoffer.add(new Offers__c(Name  = 'test',Brand__c = 'A',Special_category__c = 'Loyalty',Product_Type__c  = 'Used'));
        insert lstoffer;
        BoilerplateDetails.getBoilerPlateDetails(lstboilerplate[0].id,lstoffer[0].id);
    }
    static testMethod void getofferdetails_Test() {
    Boilerplate__c boilerobj = new Boilerplate__c(Name  = 'National Honda spd 2 Tier w/grad – Certain Vehicles',Brand__c = 'A');
        insert boilerobj;
        Offers__c offerobj = new Offers__c(Name  = 'test',Brand__c = 'A',Product_Type__c  = 'Used',Custom_clone__c= false,Boilerplate__c =boilerobj.id);
        insert offerobj;
        BoilerplateDetails.getofferdetails(offerobj.id);
        BoilerplateDetailsDAO.getBoilerPlate(boilerobj.id);
        BoilerplateDetailsDAO.getoffer(offerobj.id);
        BoilerplateDetailsDAO.getofferboilerplate((string)offerobj.id);
        BoilerplateDetailsDAO.getBoilerPlatebasedOfferType('National Honda spd 2 Tier w/grad – Certain Vehicles');
        
    }
    static testMethod void getOffBolderdetails_Test() {
         Boilerplate__c boilerobj = new Boilerplate__c(Name  = 'National Honda spd 2 Tier w/grad – Certain Vehicles',Brand__c = 'A');
        insert boilerobj;
        Offers__c offerobj = new Offers__c(Name  = 'test',Brand__c = 'A',Product_Type__c  = 'Used',Custom_clone__c= false,Boilerplate__c =boilerobj.id);
        insert offerobj;
        BoilerplateDetails.getOffBolderdetails(offerobj.id);
        BoilerplateDetails.saveOffer((string)offerobj.id,(string) boilerobj.id,'test','test','test','test','test');
        
    }
}
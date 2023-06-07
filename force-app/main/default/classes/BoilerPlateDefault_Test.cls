@isTest  
public class BoilerPlateDefault_Test {
    static testMethod void defBlrPlate_Test() {
        List<Boilerplate__c>  lstboilerplate = new list<Boilerplate__c>();
        lstboilerplate.add(new Boilerplate__c(Name  = 'National Honda spd 2 Tier w/grad – Certain Vehicles',Brand__c = 'A',Status__c ='Active'));
        insert lstboilerplate;
        BoilerPlateDefault.defBlrPlate('National Honda spd 2 Tier w/grad – Certain Vehicles');
    }
    static testMethod void defBlrPlateBasedonOfferListforUI_Test (){
                List<Offers__c>  lstoffer = new list<Offers__c>();
        
       Boilerplate__c boilerobj = new Boilerplate__c(Name  = 'National Honda spd 2 Tier w/grad – Certain Vehicles',Brand__c = 'A');
        insert boilerobj;
          id offerrecordtypeid = Schema.SObjectType.Offers__c.getRecordTypeInfosByName().get('New Special Finance').getRecordTypeId();
         lstoffer.add(new Offers__c(Name  = 'test',Brand__c = 'A', RecordTypeId =offerrecordtypeid));
         insert lstoffer;
        BoilerPlateDefault.defBlrPlateBasedonOfferListforUI(lstoffer);
    }
}
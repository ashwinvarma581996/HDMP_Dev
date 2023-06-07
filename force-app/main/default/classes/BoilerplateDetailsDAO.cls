public without sharing class BoilerplateDetailsDAO {
    public static  Boilerplate__c getBoilerPlate(string boilerid){
        if(boilerid == null){
            return null;
        } 
        Boilerplate__c boiler =[SELECT ID,Name,
                                Offer_Title__c,
                                Short_Description__c, 
                                Detailed_Description__c,
                                Terms_Conditions__c,
                                
                                Legal_Disclaimer__c  FROM Boilerplate__c  WHERE ID =:boilerid limit 1];
        system.debug('wrapper responds'+boiler);
        return boiler;
    }
    
    public static Boilerplate__c getBoilerPlatebasedOfferType(string name){
        Boilerplate__c boiler ;
        if(name == null){
            return null;
        }
        try{
            boiler =[SELECT ID,Name,
                     Offer_Title__c,
                     Short_Description__c, 
                     Detailed_Description__c,
                     Terms_Conditions__c,
                     Legal_Disclaimer__c  FROM Boilerplate__c  WHERE Name =:name limit 1];
            system.debug('wrapper responds'+boiler);
        }
        catch(exception ex){
            
        }
        return boiler;
    }
    Public static Offers__c getoffer(string offerid){
        Offers__c off =[SELECT ID,Boilerplate__c,recordtype.name,status__c FROM Offers__c Where ID =:offerid];
        return off;
    }
    
    @AuraEnabled
    public static Offers__c getofferboilerplate(string offerid){
        Offers__c offobj = new Offers__c();
        try{
            offobj = [SELECT ID,Offer_Title__c,
                      Boilerplate__c,
                      Short_Description__c,
                      Detailed_Description__c,
                      Terms_and_Conditions__c,
                      Legal_Desclaimer__c,
                      recordtype.name FROM Offers__c WHERE ID =:offerid];
        }
        Catch(exception ex){
            
        }
        return offobj;
    } 
    
}
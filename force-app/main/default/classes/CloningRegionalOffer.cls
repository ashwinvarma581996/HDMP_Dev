public without sharing class CloningRegionalOffer {
    @AuraEnabled
    public static Wrapperoffer getOfferRecord(string offerid){
        Offers__c off;
        Wrapperoffer wrapoff = new Wrapperoffer();
        
        if(offerid != null){
           off =[SELECT ID,Name,Descriptive_Name__c,AHM_Regions__c from  Offers__c where id =:offerid];
            wrapoff.offerdescriptive = off.Descriptive_Name__c;
            wrapoff.Ahmregion = off.AHM_Regions__c;
              wrapoff.Programname= off.Name;
        }
        return wrapoff;
        
    }
    @AuraEnabled
    public static string offerclone(string offerid,string filename, string ahmregion){ 
        string headerid =createOfferHeader(filename);
        Map<String, String> labelMap = new Map<String, String>();
        Schema.DescribeSObjectResult objectDescribe  = Offers__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        List<String> fieldNames = new List<String>( fieldMap.keySet() );
        String offerrecord =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Offers__c  WHERE id=\''+offerid+'\'';
        Offers__c lstelgs = Database.query(offerrecord);
        Offers__c lstelg  = lstelgs.clone(false, false, false, false);
        lstelg.National_Offer__c = lstelgs.Id;
        lstelg.Offer_Availability__c='Regional';
        lstelg.Offer_Header__c  =headerid;
        lstelg.PRISM_Offer_Status__c = null;
        //lstelg.Descriptive_Name__c    = descriptivename;
        lstelg.AHM_Regions__c= filename;
        
        // lstelg.Boilerplate__c = lstelgs.Boilerplate__c;
        system.debug('====== Prdshi Debug'+lstelg.PRISM_Offer_Status__c);
        insert lstelg;
        system.debug('======+++++++'+lstelg.id);
        if(lstelg.id != null){
            eligiblemodelClone(lstelg.id,offerid); 
           // eligibleRegionClone(lstelg.id,offerid);
        } 
        
        return lstelg.id; 
    }
    /**
* Description: this method used to Clone eligible model
*/
    @AuraEnabled
    public static void eligiblemodelClone(string newRecID,string oldoffer){
        Map<String, String> labelMap = new Map<String, String>();
        Schema.DescribeSObjectResult objectDescribe  = Offer_Eligible_Models__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        List<String> fieldNames = new List<String>( fieldMap.keySet() );
        String boilderplate =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Offer_Eligible_Models__c  WHERE Offer__c=\''+oldoffer+'\'';
        List<Offer_Eligible_Models__c> lstelg = Database.query(boilderplate);
        List<Offer_Eligible_Models__c> lsteligible = new List<Offer_Eligible_Models__c>();
        for(Offer_Eligible_Models__c elg:lstelg){
            Offer_Eligible_Models__c  elgcopy = elg.clone(false,true);
            elgcopy.Offer__c =newRecID;
            lsteligible.add(elgcopy);
        }
        insert lsteligible;
    }
    /*
    @AuraEnabled
    public static void eligibleRegionClone(string newRecID,string oldoffer){
        Map<String, String> labelMap = new Map<String, String>();
        Schema.DescribeSObjectResult objectDescribe  = Offer_Eligible_Regions__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        List<String> fieldNames = new List<String>( fieldMap.keySet() );
        String regional =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Offer_Eligible_Regions__c  WHERE Offer__c=\''+oldoffer+'\'';
        List<Offer_Eligible_Regions__c> lstelg = Database.query(regional);
        List<Offer_Eligible_Regions__c> lstNewelig = new list<Offer_Eligible_Regions__c>();
        for(Offer_Eligible_Regions__c elg:lstelg){
            Offer_Eligible_Regions__c  elgcopy = elg.clone(false,true);
            elgcopy.Offer__c =newRecID;
            lstNewelig.add(elgcopy);
        }
        insert lstNewelig;
    }*/
    @AuraEnabled
    public static string createOfferHeader(string program){
        Offer_Header__c offheader = new Offer_Header__c();
        offheader.Name = program;
        //offheader.Descriptive__c = descriptivename;
        
        try{
          insert offheader;  
        }
        catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return offheader.id; 
    }
 
    public class Wrapperoffer{
        @AuraEnabled
        Public string offerdescriptive;
        @AuraEnabled
        Public string Programname;
        @AuraEnabled
        Public string Ahmregion;       
    }
    
}
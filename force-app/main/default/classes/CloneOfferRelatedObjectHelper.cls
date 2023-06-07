/*******************************************************************
* Name: siva
* Descrition : this class is used in Lwc component (regional offer and create new version)
* **************************************************************************/
public without sharing class CloneOfferRelatedObjectHelper {
    /*********************************************************************
* Description: this method used to display data 
* *******************************************************************/
    @AuraEnabled
    public static Wrapperoffer getOfferRecord(string offerid){
        Offers__c off;
        Wrapperoffer wrapoff = new Wrapperoffer();
        
        if(offerid != null){
            off =[SELECT ID,Descriptive_Name__c,File_Name__c,Name from  Offers__c where id =:offerid];
            wrapoff.offerdescriptive = off.Descriptive_Name__c;
            wrapoff.Programname = off.Name;
        }
        return wrapoff;
        
    }
    /***************************************************************************************************
* Description: this method will create offer record based existing record 
* 
* ***********************************************************************************************/
    @AuraEnabled
    public static string offerclone(string offerid,string program, string descriptivename){ 
        Map<String, String> labelMap = new Map<String, String>();
        Schema.DescribeSObjectResult objectDescribe  = Offers__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        List<String> fieldNames = new List<String>( fieldMap.keySet() );
        System.debug('printing field names'+fieldNames);
        fieldNames.add('recordtype.name');
        String offerrecord =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Offers__c  WHERE id=\''+offerid+'\'';
        Offers__c lstelgs = Database.query(offerrecord);
        Offers__c lstelg  = lstelgs.clone(false, false, false, false);
        Id headerRecId = Schema.SObjectType.Offer_Header__c.getRecordTypeInfosByName().get(lstelgs.recordtype.name).getRecordTypeId();
        string headerid =createOfferHeader(program,descriptivename,lstelg.Offer_Type__c,lstelg.Brand__c,headerRecId,lstelg.AHFC_Sales_Program_ID__c,lstelg.AHM_Sales_Program_ID__c);
        Offer_Header__c header =[SELECT Id, Descriptive__c,RecordTypeId,recordtype.name, Name FROM Offer_Header__c where id IN(SELECT Offer_Header__c FROM Offers__c WHERE ID =:offerid) LimiT 1]; 
        system.debug('========='+header);
        system.debug('Printing Brand'+lstelgs.Brand__c);
        system.debug('clinicRecordTypeId'+headerRecId);
        lstelg.National_Offer__c = lstelgs.Id;
        lstelg.Name = program;  
        lstelg.File_Name__c = program;
        lstelg.Descriptive_Name__c = descriptivename;
        lstelg.Custom_clone__c = true;
        lstelg.Offer_Header__c  =headerid;
        lstelg.Offer_Availability__c='Regional';
        header.Name = lstelg.Name;
        header.RecordTypeId = headerRecId;
        header.Brand__c = lstelg.Brand__c;
        header.AHFC_Sales_Program_ID__c = lstelg.AHFC_Sales_Program_ID__c;
        header.AHM_Sales_Program_ID__c = lstelg.AHM_Sales_Program_ID__c;
        lstelg.Status__c ='WIP';
        lstelg.Synched_with_PRISM__c =false;
        lstelg.PRISM_Offer_Status__c = null;
        //lstelg.Brand__c = lstelg.Brand__c;
        lstelg.Alternate_Offer_Identifier__c ='';
        lstelg.Preview__c = false;
            insert lstelg;    
        return lstelg.id; 
    }
    /**
* Description: this method used to Clone eligible model
*/
    @AuraEnabled
    public static list<Offer_Eligible_Models__c> eligiblemodelClone(string newRecID,string oldoffer){
        system.debug('new offer id '+newRecID+'   '+oldoffer);
        Map<String, String> labelMap = new Map<String, String>();
        Schema.DescribeSObjectResult objectDescribe  = Offer_Eligible_Models__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        List<String> fieldNames = new List<String>( fieldMap.keySet() );
        String eligiblemodel =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Offer_Eligible_Models__c  WHERE Offer__c=\''+oldoffer+'\'';
        List<Offer_Eligible_Models__c> lstelg = Database.query(eligiblemodel);
        list<Offer_Eligible_Models__c> lsteligible = new list<Offer_Eligible_Models__c>();
        for(Offer_Eligible_Models__c elg:lstelg){
            Offer_Eligible_Models__c  elgcopy = elg.clone(false,true);
            elgcopy.Offer__c =newRecID;
            elgcopy.OwnerId = UserInfo.getUserId();
            elgcopy.Alternate_Offer_Eligible_Model_Id__c=newRecID+'~'+elg.Model_ID__c;
            lsteligible.add(elgcopy);
        }
        insert lsteligible;
        
        return lsteligible;
    }
    
    
    
    
    
    @AuraEnabled
    public static string createOfferHeader(string program,string descriptivename,string offertype,string Brand,Id recordid,String AHFCSalesId,String AHMSalesId){
        Offer_Header__c offheader = new Offer_Header__c();
        if(program != null){
            offheader.Name = program;  
        }
        if(descriptivename != null){
            offheader.Descriptive__c = descriptivename; 
        } 
        if(offertype != null){
            offheader.Offer_Type__c = offertype;
        }
        if(Brand !=null){
            offheader.Brand__c = brand; 
        }
        if(recordid !=null){
            offheader.RecordTypeId = recordid;
        }
        if(AHFCSalesId !=null){
            offheader.AHFC_Sales_Program_ID__c = AHFCSalesId;
        }
        if(AHMSalesId !=null){
            offheader.AHM_Sales_Program_ID__c = AHMSalesId;
        }
        
        insert offheader;  
        
        return offheader.id; 
    }
    @AuraEnabled
    public static string offerclonewithoutheader(string offerid){         
        Offer_Header__c header =[SELECT Id, Descriptive__c, Name FROM Offer_Header__c where id IN(SELECT Offer_Header__c FROM Offers__c WHERE ID =:offerid)]; 
        Map<String, String> labelMap = new Map<String, String>();
        Schema.DescribeSObjectResult objectDescribe  = Offers__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        List<String> fieldNames = new List<String>( fieldMap.keySet() );
        String offerrecord =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Offers__c  WHERE id=\''+offerid+'\'';
        Offers__c lstelgs = Database.query(offerrecord);
        Offers__c lstelg  = lstelgs.clone(false, false, false, false);
        
        lstelg.Offer_Header__c  =header.id;
        header.Name = lstelg.Name;
        lstelg.Custom_clone__c = true;
        lstelg.Status__c ='WIP';
        // lstelg.Offer_Availability__c='Regional';
        lstelg.Synched_with_PRISM__c =false;
        lstelg.PRISM_Offer_Status__c = null;
        lstelg.Alternate_Offer_Identifier__c ='';
        lstelg.Preview__c = false;
        lstelg.Integration_Status__c = null;
            insert lstelg;    
        
        
        
        return lstelg.id; 
    }
    
    public class Wrapperoffer{
        @AuraEnabled
        Public string offerdescriptive;
        @AuraEnabled
        Public string Programname;
        
    }  
}
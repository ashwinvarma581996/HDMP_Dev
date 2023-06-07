public without sharing class BoilerplateDetails {
  @AuraEnabled
    public static BoilerplateWrapper getBoilerPlateDetails(string boilerplateid, string offerId){
        
          List<Offers__c> listOfOffer = new List<Offers__c>();
         BoilerplateWrapper wrpObj = new BoilerplateWrapper();
        
        system.debug('@@@ boilerplateid'+boilerplateid);
        system.debug('@@@ offerId'+offerId);
        if(offerId != null && boilerplateid !=null)
        {
        	listOfOffer = [select id,Boilerplate__c,Terms_and_Conditions__c,Offer_Title__c,Short_Description__c,Detailed_Description__c,Legal_Desclaimer__c 
                           from Offers__c 
                           where id=:offerId and Boilerplate__c=: boilerplateid];
            if(listOfOffer !=null && listOfOffer.size() > 0)
            {
                Offers__c offerRec = listOfOffer[0];// always will be one record here.
                wrpObj.boilerplateid = boilerplateid;           
                wrpObj.offerTitle = offerRec.Offer_Title__c;
                wrpObj.shortDescription  = offerRec.Short_Description__c;
                wrpObj.detailedDescription = offerRec.Detailed_Description__c; 
                wrpObj.termsAndConditions  = offerRec.Terms_and_Conditions__c;
                wrpObj.legalDesclaimer  = offerRec.Legal_Desclaimer__c;
            }
            else
            {
                Boilerplate__c boilerPlateRec = [select id,Terms_Conditions__c,Offer_Title__c,Legal_Disclaimer__c,Detailed_Description__c,Short_Description__c
                                               from boilerplate__c
                                               where Id=:boilerplateid];
                wrpObj = new BoilerplateWrapper();
                if( boilerPlateRec!=null)
                {
                    wrpObj.boilerplateid = boilerplateid;           
                    wrpObj.offerTitle = boilerPlateRec.Offer_Title__c;
                    wrpObj.shortDescription  = boilerPlateRec.Short_Description__c;
                    wrpObj.detailedDescription = boilerPlateRec.Detailed_Description__c; 
                    wrpObj.termsAndConditions  = boilerPlateRec.Terms_Conditions__c;
                    wrpObj.legalDesclaimer  = boilerPlateRec.Legal_Disclaimer__c;
                }
            }
        
        }
        return wrpObj;
    }
    @AuraEnabled
    Public static BoilerplateWrapper getofferdetails(string offerid){
        Offers__c offobj= BoilerplateDetailsDAO.getoffer(offerid);
        BoilerplateWrapper wrp = new BoilerplateWrapper();
        if(offobj!= null){
            wrp.boilerplateid = offobj.Boilerplate__c;
            wrp.offerRecordTypeName = offobj.recordtype.name;
            wrp.offerStatus = offobj.status__c;
        }
        return wrp;
    }
    @AuraEnabled
    Public static BoilerplateWrapper getOffBolderdetails(string offerid){
        Offers__c offobj= BoilerplateDetailsDAO.getofferboilerplate(offerid);
        BoilerplateWrapper wrp = new BoilerplateWrapper();
        if(offerid!= null){
            wrp.boilerplateid = offobj.Boilerplate__c;
            wrp.offerTitle  = offobj.Offer_Title__c;
            wrp.shortDescription=offobj.Short_Description__c;
            wrp.detailedDescription=offobj.Detailed_Description__c;
            wrp.termsAndConditions=offobj.Terms_and_Conditions__c; 
            wrp.legalDesclaimer=offobj.Legal_Desclaimer__c;
            wrp.offerRecordTypeName =string.valueof(Recordtype.Name);
            wrp.recordtypeName=offobj.Recordtype.Name;// to store recordtype of offer
            System.debug('wrp.recordtypeName'+wrp.recordtypeName);
        }
        return wrp;
    }
    
    @AuraEnabled
    public static List<Boilerplate__c> searchBoilerPlate(string offerId, string searchName){
        
        Offers__c objOffer = new Offers__c();
        list<Boilerplate__c> listofBoilerplate = new list<Boilerplate__c>();
        
        if(offerId != null){
            objOffer = [select id,recordtype.name,status__c, Brand__c from Offers__c where id=:offerId];
        }
        if(searchName == null || searchName ==''){
            listofBoilerplate = [select Id,name from Boilerplate__c where status__c='Active' and Offer_Type__c =:objOffer.recordtype.name and Brand__c=:objOffer.Brand__c order by createddate DESC];                
        } else {
            listofBoilerplate = [select Id,name from Boilerplate__c where status__c='Active' and name  LIKE :'%'+searchName+'%' and  Offer_Type__c =:objOffer.recordtype.name and Brand__c=:objOffer.Brand__c order by createddate DESC];                
        }
        
        return listofBoilerplate;
        
    }
    
    @AuraEnabled
    public static String saveOffer(string offerid, string boidlerid,string offertitle,string shortdescription,string detaildec,string term,string legal){
        /*Offers__c offobj = [SELECT ID,Offer_Title__c,
                            Boilerplate__c,
                            Short_Description__c,
                            Detailed_Description__c,
                            Terms_and_Conditions__c,
                            Legal_Desclaimer__c FROM Offers__c WHERE ID =:offerid];*/
        String returnValue = '';
        Offers__c offobj = new Offers__c();
        offobj.id = offerid;
        system.debug(' ========='+offerid);
        offobj.Boilerplate__c = boidlerid;
        system.debug('=++++++++++'+boidlerid);
        /*if(term.length()>255){
            term = term.substring(0,255);
        }*/
        system.debug('in class:'+detaildec);
        system.debug('in class:'+term);
        offobj.Offer_Title__c= offertitle;
        offobj.Short_Description__c=shortdescription;
        
        offobj.Detailed_Description__c=detaildec;
        
        offobj.Terms_and_Conditions__c=term; 
        offobj.Legal_Desclaimer__c=legal;

        try{
            update offobj;
            system.debug('+++++++++++'+offobj);
          }
        catch(exception ex){
            system.debug('======='+ex.getMessage());
            returnValue = ex.getMessage();
        }
        return returnValue;
        
    }
    /**********************************************************************************
*  Name : Siva
*  Description: This method will return default boilerplate 
* *************************************************************************************/
   
    public class BoilerplateWrapper{
        @AuraEnabled
        public string boilerplateid;
        @AuraEnabled
        public string offerTitle;
        @AuraEnabled
        public string shortDescription;
        @AuraEnabled
        public string detailedDescription;
        @AuraEnabled
        public string termsAndConditions;
        @AuraEnabled
        public string legalDesclaimer;
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string offerRecordTypeName;
        @AuraEnabled
        public string offerStatus;
        @AuraEnabled
        public string recordtypeName;
    } 
}
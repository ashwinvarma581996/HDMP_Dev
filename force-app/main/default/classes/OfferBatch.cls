/*************************************************************************
Purpose : This is batch class used to activate or expire offer records based on its start or end date
/*************************************************************************/
global class OfferBatch  implements Database.Batchable<sObject>{
    set<string> setStatusClause =new set<string>{'Approved','Active'};
    set<string> setIntegrationStatus = new set<string>{'Success'};
    public Database.QueryLocator start(Database.BatchableContext BC){        
     
         return Database.getQueryLocator('Select id,Status__c,Start_Date__c,End_Date__c,Advertised_Start_Date__c,Advertised_End_Date__c,Integration_Status__c  from offers__c'+
                                         ' where status__c  IN:setStatusClause'+
                                         ' AND Integration_Status__c IN:setIntegrationStatus'+
                                         ' AND ((Start_Date__c<=today OR Advertised_Start_Date__c<=today) or '+
                                         '(end_date__c<=today OR Advertised_End_Date__c<=today))');
    }
    /*If offer's start date is matching with today's date set the status to Activate . If End date is matching with today's date , set status to Expired*/
    public void execute(Database.BatchableContext BC, List<Offers__c> scope){
        for(offers__c offerRec : scope)
        {
            if(offerRec.status__c=='Approved' && OfferRec.Integration_Status__c =='Success' &&(offerRec.Start_Date__c<=system.today() || offerRec.Advertised_Start_Date__c <= system.today())) 
            { 
             offerRec.status__c='Active';   
            }
            if(setStatusClause.contains(offerRec.status__c) && (offerRec.End_Date__c<system.today()|| offerRec.Advertised_End_Date__c < system.today()))
            {
             offerRec.status__c='Expired';    
            }
        }        
        Database.SaveResult[] srList = Database.update(scope, false);
    }
    
    
    
    public void finish(Database.BatchableContext BC){
    }
   
    
}
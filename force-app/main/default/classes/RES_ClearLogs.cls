/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
public without sharing class RES_ClearLogs  implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    public RES_ClearLogs() { }

    
    public void execute(SchedulableContext sc){
        if ( ! Test.isRunningTest()){
            Database.executeBatch(new RES_ClearLogs()) ;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        Datetime cutoffDate = Datetime.now().addDays(-30) ;
        return Database.getQueryLocator([SELECT id FROM RES_Log__c WHERE CreatedDate > :cutoffDate ]) ;
    }

    public void execute(Database.BatchableContext bc, List<SObject> recordList){
        
        RES_Log__c[] logRecords = new List<RES_Log__c>() ;

        for ( SObject record : recordList){
            logRecords.add(new RES_Log__c(id = record.id)) ;
        }

        delete logRecords ; 
    }

    public void finish(Database.BatchableContext bc){
    }
}
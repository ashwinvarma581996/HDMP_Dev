/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class RES_ClearSessions  implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    public RES_ClearSessions() {

    }

    
    public void execute(SchedulableContext sc){
        if ( ! Test.isRunningTest()){
            Database.executeBatch(new RES_ClearSessions()) ;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        Datetime cutoffDate = Datetime.now().addDays(-5) ;
        return Database.getQueryLocator([SELECT id FROM Reservation_Session__c WHERE CreatedDate > :cutoffDate ]) ;
    }

    public void execute(Database.BatchableContext bc, List<SObject> recordList){
        
        Reservation_Session__c[] sessions = new List<Reservation_Session__c>() ;

        for ( SObject record : recordList){
            sessions.add(new Reservation_Session__c(id = record.id)) ;
        }

        delete sessions ; 
    }

    public void finish(Database.BatchableContext bc){
    }
}
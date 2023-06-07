/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
public with sharing class RES_Retry_Lead_Submissions implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    public RES_Retry_Lead_Submissions() {

    }

    public void execute(SchedulableContext sc){
        if ( ! Test.isRunningTest()){
            Database.executeBatch(new RES_Retry_Lead_Submissions()) ;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id, payload__c, Reservation__c FROM RES_Lead_Retry_Queue__c WHERE retried__c = false]) ;
    }

    public void execute(Database.BatchableContext bc, List<SObject> recordList){
        for ( SObject o : recordList ){
            RES_Lead_Retry_Queue__c q = (RES_Lead_Retry_Queue__c) o ;
            Map<String,Object> leadRecord = (Map<String,Object>)  JSON.deserializeUntyped(q.Payload__c) ;
            Reservation__c lead = new Reservation__c(id = q.Reservation__c) ;
            RES_LeadCreation.sendLeadsData(leadRecord, lead,true) ;
            q.retried__c = true ;
        }
        update recordList ;
    }

    public void finish(Database.BatchableContext bc){
        if ( ! Test.isRunningTest()){
            String cronID = System.scheduleBatch(new RES_Retry_Lead_Submissions(), 'lead_retry', 60);
        }
    }

}
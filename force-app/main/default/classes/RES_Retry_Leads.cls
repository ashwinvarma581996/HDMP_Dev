public with sharing class RES_Retry_Leads implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    public RES_Retry_Leads() {

    }

    public void execute(SchedulableContext sc) {
        if (!Test.isRunningTest()) {
            Database.executeBatch(new RES_Retry_Leads());
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([   SELECT id, retry_count__c, Status__c
                                            FROM Reservation__c
                                            WHERE CreatedDate > 2022-09-01T00:00:00Z
                                            AND Status__c
                                            IN ('Reservation Made','Deposit Made','Wait-listed')
                                            AND LeadPosted__c = false
                                            AND (retry_count__c = -1)
                                        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> recordList){

        List<Reservation__c> objectsToUpdate = new List<Reservation__c>() ;

        for(SObject sobj : recordList) {
            Integer rc =  Integer.valueOf(sobj.get('retry_count__c')) ;
            rc = rc == -1 ? 0 : rc ;
            if (rc < 3){
                RES_LeadCreation.postLeadsFromReservation(sobj.id) ;
            }
            else {
                sobj.put('status__c','leadPostFailure') ;
            }
            objectsToUpdate.add( new Reservation__c(id = sobj.id, Retry_Count__c = rc + 1 , Status__c = String.valueof(sobj.get('Status__c')))) ;
        }
        update objectsToUpdate ;
    }

    public void finish(Database.BatchableContext bc){
    }

}
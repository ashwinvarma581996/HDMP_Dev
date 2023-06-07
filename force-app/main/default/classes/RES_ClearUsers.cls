/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 09-02-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class RES_ClearUsers  implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    public RES_ClearUsers() {

    }

    
    public void execute(SchedulableContext sc){
        if ( ! Test.isRunningTest()){
            Database.executeBatch(new RES_ClearSessions()) ;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        Profile profile = [SELECT id FROM Profile WHERE Name = 'Reservation Community User'][0] ;
        Datetime cutoffDate = Datetime.now().addDays(-5) ;

        return Database.getQueryLocator([   SELECT id 
                                            FROM User 
                                            WHERE 
                                                ProfileId = :profile.id AND
                                                IsActive = true AND 
                                                Id NOT IN (SELECT User__c FROM Reservation_Session__c WHERE createdDate > :cutoffDate) ]) ;
    }

    public void execute(Database.BatchableContext bc, List<SObject> recordList){
        
        User[] users = new List<User>() ;

        for ( SObject record : recordList){
            users.add(new User(id = record.id, isActive = false )) ;
        }

        update users ; 
    }

    public void finish(Database.BatchableContext bc){
    }
}
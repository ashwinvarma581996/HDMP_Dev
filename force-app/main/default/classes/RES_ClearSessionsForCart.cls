/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 10-26-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
public with sharing class RES_ClearSessionsForCart {

    @InvocableMethod(label='Clean Up Sessions' description='description')
    public static void cleanUpSessions(List<Id> ids) {
        
        List<Reservation_Session__c> sessions = [SELECT id FROM Reservation_Session__c WHERE Cart__c IN :ids] ;

        try{
            List<Database.DeleteResult> dr = Database.delete(sessions);
        }
        catch(Exception e)
        {
            
        }

    }

}
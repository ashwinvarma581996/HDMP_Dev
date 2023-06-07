/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 09-23-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
trigger Reservation_Session_BI on Reservation_Session__c (before insert, before update) {

  for ( Reservation_Session__c session : trigger.new)
  {
    session.Duplicate_User_Check__c = session.Reservation_User__c ;
  }
}
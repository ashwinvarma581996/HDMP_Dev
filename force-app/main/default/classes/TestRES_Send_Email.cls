/**
* @description       : 
* @author            : mbunch@gorillagroup.com
* @group             : 
* @last modified on  : 03-17-2022
* @last modified by  : mbunch@gorillagroup.com
**/
@isTest
private class TestRES_Send_Email{
    
    
    @testSetup static void setup(){
        Res_TestDataFactory.setUpReservationTest();		 
    }
    
    
    @IsTest
    private static void testMethod1(){

  
        WebCart cart = [SELECT id FROM WebCart LIMIT 1] ;
		Res_TestDataFactory.createSession() ;
		Reservation_Settings__mdt settings = RES_Settings.getSettings() ;
		settings.Reservation_Account__c = [SELECT id FROM Account LIMIT 1][0].id ;
		settings.Storeid__c = [SELECT id FROM WebStore LIMIT 1][0].id ;
		Test.startTest();
		RES_Send_Email.psettings = settings ;
		RES_Send_Email.sendConfirmation(cart.id);
		Test.stopTest();
		
		String reservation = [SELECT Reservation__c FROM Reservation_Session__c WHERE Cart__c = :cart.id][0].Reservation__c ;
		List<Reservation__c> reservations = [SELECT id FROM Reservation__c WHERE id = :reservation AND EmailSent__c = true] ;
		System.assert(reservations.Size() == 1, 'Excpected email to be sent');
	}
  
}
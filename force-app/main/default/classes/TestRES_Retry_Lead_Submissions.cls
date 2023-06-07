/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-08-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
private class TestRES_Retry_Lead_Submissions{

	@testSetup static void setup(){
		Reservation_Contact2__c rc = Res_TestDataFactory.createReservationContact() ;
		Reservation__c r = Res_TestDataFactory.createReservation(rc) ;
		Map<String,Object> p = Res_TestDataFactory.buildReservationMap(r.id, rc.id) ;
		RES_Lead_Retry_Queue__c q = new RES_Lead_Retry_Queue__c(Payload__c = JSON.serialize(p), retried__c = false, Reservation__c = r.id ) ;
		insert q ;
	}

	@isTest static void teststart() {
		
		Test.startTest();
		RES_Retry_Lead_Submissions c = new RES_Retry_Lead_Submissions() ;
		Database.QueryLocator ql = c.start(null) ;
		Database.QueryLocatorIterator i = ql.iterator() ;
		System.assert(i.hasNext(),'No value read') ;
		Test.stopTest();

	}

	@isTest static void testexecute() {

		Test.startTest() ;
		List<RES_Lead_Retry_Queue__c> q = new List<RES_Lead_Retry_Queue__c>() ;
		RES_Retry_Lead_Submissions c = new RES_Retry_Lead_Submissions() ;
		Database.QueryLocatorIterator cli = c.start(null).iterator() ;
		while(cli.hasNext()){
			q.add((RES_Lead_Retry_Queue__c)cli.next()) ;
		}
		c.execute(null, q) ;
		Test.stopTest() ;
	}

	@istest static void finish(){
		Test.startTest();
		RES_Retry_Lead_Submissions c = new RES_Retry_Lead_Submissions() ;
		try {
			c.finish(null) ;
		}
		catch(Exception e){
			// do nothing.  job is already scheduled
		}
		Test.stopTest();
	}

	@istest static void executeSched(){
		Test.startTest();
		RES_Retry_Lead_Submissions c = new RES_Retry_Lead_Submissions() ;
		try {
			c.execute(null) ;
		}
		catch(Exception e){
			// do nothing.  job is already scheduled
		}
		Test.stopTest();
	}
}
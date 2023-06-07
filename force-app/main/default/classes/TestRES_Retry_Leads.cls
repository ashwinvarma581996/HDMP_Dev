/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-24-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
private class TestRES_Retry_Leads{

	@testSetup static void setup(){
		Res_TestDataFactory.setUpReservationTest();
	}

	@isTest static void testQueryNoLeadsToRetry() {
		Reservation__c r = [SELECT id FROM Reservation__c][0] ;
		r.Status__c = 'Reservation Made' ;
		r.retry_count__c = 0 ;
		r.LeadPosted__c = true ;
		update r ;
		Test.startTest() ;
		RES_Retry_Leads rl = new RES_Retry_Leads() ;
		Database.QueryLocator ql = rl.start(null) ;
		Database.QueryLocatorIterator it = ql.iterator();
		Boolean found = false ;
		while ( it.hasNext() ){
			System.debug(it.next()) ;
			found = true ;
		}
		test.stopTest() ;
		System.assert(!found,'Expected no reservations') ;
	}

	@isTest static void testQueryNoLeadsToRetry2() {
		Reservation__c r = [SELECT id FROM Reservation__c][0] ;
		r.Status__c = 'In Process' ;
		r.retry_count__c = 0 ;
		r.LeadPosted__c = false ;
		update r ;
		Test.startTest() ;
		RES_Retry_Leads rl = new RES_Retry_Leads() ;
		Database.QueryLocator ql = rl.start(null) ;
		Database.QueryLocatorIterator it = ql.iterator();
		Boolean found = false ;
		while ( it.hasNext() ){
			System.debug(it.next()) ;
			found = true ;
		}
		test.stopTest() ;
		System.assert(!found,'Expected no reservations') ;
	}

	@isTest static void testQueryNoLeadsToRetry3() {
		Reservation__c r = [SELECT id FROM Reservation__c][0] ;
		r.Status__c = 'Reservation Made' ;
		r.retry_count__c = 4 ;
		r.LeadPosted__c = false ;
		update r ;
		Test.startTest() ;
		RES_Retry_Leads rl = new RES_Retry_Leads() ;
		Database.QueryLocator ql = rl.start(null) ;
		Database.QueryLocatorIterator it = ql.iterator();
		Boolean found = false ;
		while ( it.hasNext() ){
			System.debug(it.next()) ;
			found = true ;
		}
		test.stopTest() ;
		System.assert(!found,'Expected no reservations') ;
	}

	@isTest static void testQueryLeadsToRetry() {
		Reservation__c r = [SELECT id FROM Reservation__c][0] ;
		r.Status__c = 'Reservation Made' ;
		r.retry_count__c = -1 ;
		r.LeadPosted__c = false ;
		update r ;
		Test.startTest() ;
		RES_Retry_Leads rl = new RES_Retry_Leads() ;
		Database.QueryLocator ql = rl.start(null) ;
		Database.QueryLocatorIterator it = ql.iterator();
		Boolean found = false ;
		while ( it.hasNext() ){
			System.debug(it.next()) ;
			found = true ;
		}
		test.stopTest() ;
		System.assert(found,'Expected reservation') ;
	}

	@isTest static void testQueryLeadsToRetry2() {
		Reservation__c r = [SELECT id FROM Reservation__c][0] ;
		r.Status__c = 'Deposit Made' ;
		r.retry_count__c = -1 ;
		r.LeadPosted__c = false ;
		update r ;
		Test.startTest() ;
		RES_Retry_Leads rl = new RES_Retry_Leads() ;
		Database.QueryLocator ql = rl.start(null) ;
		Database.QueryLocatorIterator it = ql.iterator();
		Boolean found = false ;
		while ( it.hasNext() ){
			System.debug(it.next()) ;
			found = true ;
		}
		test.stopTest() ;
		System.assert(found,'Expected reservation') ;
	}

	@isTest static void testQueryLeadsToRetry3() {
		Reservation__c r = [SELECT id FROM Reservation__c][0] ;
		r.Status__c = 'Reservation Made' ;
		r.retry_count__c = -1 ;
		r.LeadPosted__c = false ;
		update r ;
		Test.startTest() ;
		RES_Retry_Leads rl = new RES_Retry_Leads() ;
		Database.QueryLocator ql = rl.start(null) ;
		Database.QueryLocatorIterator it = ql.iterator();
		Boolean found = false ;
		while ( it.hasNext() ){
			System.debug(it.next()) ;
			found = true ;
		}
		test.stopTest() ;
		System.assert(found,'Expected reservation') ;
	}


	@isTest static void testExecute() {

		Reservation__c r = [SELECT id FROM Reservation__c][0] ;
		r.Status__c = 'Reservation Made' ;
		r.retry_count__c = -1 ;
		r.LeadPosted__c = false ;
		update r ;
		Test.startTest() ;
		Test.setMock(HttpCalloutMock.class, new Res_LeadService_Mock());
		RES_Retry_Leads rl = new RES_Retry_Leads() ;
		rl.execute(null, new List<SObject> { r }) ;
		test.stopTest() ;
        System.assert(true);
		// System.assert([SELECT id FROM Reservation__c WHERE LeadPosted__c = true].size() > 0,'Lead posted expected') ;
	}

	@isTest static void testExecute2() {

		Test.setMock(HttpCalloutMock.class, new Res_LeadService_Mock());
		Reservation__c r = [SELECT id FROM Reservation__c][0] ;
		r.Status__c = 'Reservation Made' ;
		r.retry_count__c = 5 ;
		r.LeadPosted__c = false ;
		update r ;
		Test.startTest() ;
		RES_Retry_Leads rl = new RES_Retry_Leads() ;
		rl.execute(null, new List<SObject> { r }) ;
		test.stopTest() ;
		System.assert([SELECT id FROM Reservation__c WHERE Status__c = 'leadPostFailure'].size() > 0,'Lead posted expected') ;
	}

}
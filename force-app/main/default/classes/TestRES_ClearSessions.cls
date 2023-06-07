/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
public with sharing class TestRES_ClearSessions {

	@testSetup static void setup(){
        Reservation_Session__c session = new Reservation_Session__c() ;
        insert session ;
        Test.setCreatedDate(session.id, Datetime.now().addDays(-60)) ;
        update session ;
        session = new Reservation_Session__c() ;
        insert session ;

	}

	@isTest 
    static void teststart() {
		
		Test.startTest();
		RES_ClearSessions c = new RES_ClearSessions() ;
		Database.QueryLocator ql = c.start(null) ;
		Database.QueryLocatorIterator i = ql.iterator() ;
		System.assert(i.hasNext(),'No value read') ;
		Test.stopTest();
	}

	@isTest static void testexecute() {

		Test.startTest() ;
        List<SObject> q = new List<SObject>() ;
		RES_ClearSessions c = new RES_ClearSessions() ;
		Database.QueryLocatorIterator cli = c.start(null).iterator() ;
		while(cli.hasNext()){
			q.add((Reservation_Session__c)cli.next()) ;
		}
		c.execute(null, q) ;
		Test.stopTest() ;
        System.assert([SELECT id FROM Reservation_Session__c].size() == 1, 'Expected 1') ;
	}

	@istest static void finish(){
		Test.startTest();
		RES_ClearSessions c = new RES_ClearSessions() ;
		try {
			c.finish(null) ;
		}
		catch(Exception e){
		}
		Test.stopTest();
	}

	@istest static void executeSched(){
		Test.startTest();
		RES_ClearSessions c = new RES_ClearSessions() ;
		try {
			c.execute(null) ;
		}
		catch(Exception e){
			// do nothing.  job is already scheduled
		}
		Test.stopTest();
	}
}
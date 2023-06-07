/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
private class TestRES_ClearLogs{

	@testSetup static void setup(){
        RES_Log__c log = new Res_Log__c(Log_Data__c = '123') ;
        insert log ;
        Test.setCreatedDate(log.id, Datetime.now().addDays(-60)) ;
        update log ;
        log = new Res_Log__c(Log_Data__c = '456') ;
        insert log ;

	}

	@isTest 
    static void teststart() {
		
		Test.startTest();
		RES_ClearLogs c = new RES_ClearLogs() ;
		Database.QueryLocator ql = c.start(null) ;
		Database.QueryLocatorIterator i = ql.iterator() ;
		System.assert(i.hasNext(),'No value read') ;
		Test.stopTest();
	}

	@isTest static void testexecute() {

		Test.startTest() ;
        List<SObject> q = new List<SObject>() ;
		RES_ClearLogs c = new RES_ClearLogs() ;
		Database.QueryLocatorIterator cli = c.start(null).iterator() ;
		while(cli.hasNext()){
			q.add((RES_Log__c)cli.next()) ;
		}
		c.execute(null, q) ;
		Test.stopTest() ;
        System.assert([SELECT id FROM Res_Log__c].size() == 1, 'Expected 1') ;
	}

	@istest static void finish(){
		Test.startTest();
		RES_ClearLogs c = new RES_ClearLogs() ;
		try {
			c.finish(null) ;
		}
		catch(Exception e){
		}
		Test.stopTest();
	}

	@istest static void executeSched(){
		Test.startTest();
		RES_ClearLogs c = new RES_ClearLogs() ;
		try {
			c.execute(null) ;
		}
		catch(Exception e){
			// do nothing.  job is already scheduled
		}
		Test.stopTest();
	}
}
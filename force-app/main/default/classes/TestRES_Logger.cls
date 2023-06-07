/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
private class TestRES_Logger{

	@isTest 
	static void testLogException() {
		RES_Exception e = new RES_Exception('test') ;
		Test.startTest() ;
		RES_Settings.getSettings().Enable_Logging__c = true ;
		RES_Settings.getSettings().Logging_Level__c = 'ERROR' ;
		RES_Logger.logException(e) ;
		Test.stopTest() ;
		System.assert([SELECT id FROM Res_Log__c].size() > 0, 'Expected Exception') ;
	}

	@isTest 
	static void testLogExceptionNoLog() {
		RES_Exception e = new RES_Exception('test') ;
		Test.startTest() ;
		RES_Settings.getSettings().Enable_Logging__c = true ;
		RES_Settings.getSettings().Logging_Level__c = 'NONE' ;
		RES_Logger.logException(e) ;
		Test.stopTest() ;
		System.assert([SELECT id FROM Res_Log__c].size() == 0, 'Not Expected Exception') ;
	}


	@istest 
	static void testBadLoggingLevel(){
		Reservation_Settings__mdt settings = RES_Settings.getSettings() ;
		settings.Logging_Level__c = ' not a level ' ;
		Test.startTest();
		RES_Logger.log('ohno') ;
		Test.stopTest() ;
	}

	@istest 
	static void testNoLogging(){
		Reservation_Settings__mdt settings = RES_Settings.getSettings() ;
		settings.Enable_Logging__c = false ;
		Test.startTest() ;
		RES_Logger.log('noooo') ;
		Test.stopTest() ;
	}

	@istest 
	static void testStoreAndFlush(){
		Test.startTest() ;
		RES_Logger.Log(LoggingLevel.DEBUG, 'test', true) ;
		System.assert([SELECT id FROM RES_Log__c].size() == 0) ;
		RES_Logger.flush() ;
		//System.assert([SELECT id FROM RES_Log__c].size() > 0) ;
		Test.stopTest() ;
	}
}
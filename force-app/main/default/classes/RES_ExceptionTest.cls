/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 10-28-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
private class RES_ExceptionTest{

	@isTest static void testMethod1() {
		Boolean thrown = false ;
		Test.startTest();
		try{
			throw new RES_Exception('ohno') ;
		}
		catch(Exception e)
		{
			thrown = true ;
		}
		Test.stopTest();
		System.assert(thrown, 'Excpected an exception') ;
	}

}
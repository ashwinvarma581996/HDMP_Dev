/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 02-12-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
private class TestRES_CapManagement{

	@testSetup static void setup(){

		
        List<Product2> products = Res_TestDataFactory.createProducts(1) ;
		Reservation_Cap_Group__c g = Res_TestDataFactory.createCapGroup() ;
		Res_TestDataFactory.assignProductToCapGroup(products[0].id, g.id) ;
		RES_Settings.getSettings().Reservation_Product_Id__c = products[0].id ;
		RES_Settings.getSettings().NoCap__c = false ;
		 
	}

	@isTest static void getProductWithoutKeys() {
        
			Test.startTest();
			Product2 p = RES_CapManagement.getProduct(null,null) ;
			System.Assert( p != null) ;
			Test.stopTest();
	}

	@isTest static void getProductWithKeys() {

		Test.startTest();
		Product2 product = [SELECT id FROM Product2 LIMIT 1][0] ;
		product.Res_ProductId__c = 'a b c';
		update product ;
		Map<String,Object> data = new Map<String,Object>{ 'a' => 'a' , 'b' => 'b' , 'c' => 'c' } ;
		RES_Settings.getSettings().Reservation_Product_Id__c = null ;
		Product2 p = RES_CapManagement.getProduct('a,b,c',data) ;
	
		Test.stopTest();
}


	@isTest static void testMethod2() {
  
		Test.startTest() ;
		String b = RES_CapManagement.calcWaitlist([SELECT id FROM Reservation_Cap_Group__c LIMIT 1][0].id, 0, false) ;
		System.assertEquals('true',b) ;
		Test.stopTest();
	}

	@isTest static void testMethod3() {
  
		Test.startTest() ;
		String b = RES_CapManagement.calcWaitlist([SELECT id FROM Reservation_Cap_Group__c LIMIT 1][0].id, 1, false) ;
		//System.AssertEquals('false',b) ;
		Test.stopTest();
	}

	@isTest static void testMethod4() {
        //setup();
		String gId = [SELECT id FROM Reservation_Cap_Group__c LIMIT 1][0].id ;
		List<Reservation__c> reservations = new List<Reservation__c>() ;
		reservations.add(new Reservation__c(Completed__c = true, Reservation_Cap_Group__c = gId, status__c = 'Deposit Made' )) ;
		reservations.add(new Reservation__c(Completed__c = true, Reservation_Cap_Group__c = gId, status__c = 'Deposit Made' )) ;
		insert reservations ;
		Test.startTest() ;
		Boolean b = Boolean.valueOf( RES_CapManagement.calcWaitlist(gId, 1, false)) ;
		System.Assert(b) ;
		Test.stopTest();
	}

	@isTest static void testMethod5() {
   
		String gId = [SELECT id FROM Reservation_Cap_Group__c LIMIT 1][0].id ;
		List<Reservation__c> reservations = new List<Reservation__c>() ;
		reservations.add(new Reservation__c(Completed__c = true, Reservation_Cap_Group__c = gId, status__c = 'Deposit Made' )) ;
		reservations.add(new Reservation__c(Completed__c = true, Reservation_Cap_Group__c = gId, status__c = 'Deposit Made' )) ;
		insert reservations ;
		Test.startTest() ;
		Boolean b = Boolean.valueOf( RES_CapManagement.calcWaitlist(gId, 3, false)) ;
		System.Assert(!b) ;
		Test.stopTest();
	}

	@isTest static void testMethod6() {
        //setup();
		String gId = [SELECT id FROM Reservation_Cap_Group__c LIMIT 1][0].id ;
		List<Reservation__c> reservations = new List<Reservation__c>() ;
		reservations.add(new Reservation__c(Completed__c = true,  status__c = 'Deposit Made' )) ;
		reservations.add(new Reservation__c(Completed__c = true,  status__c = 'Deposit Made' )) ;
		insert reservations ;
		Test.startTest() ;
		Boolean b = Boolean.valueOf( RES_CapManagement.calcWaitlist(null, 1, false) );
		System.Assert(b) ;
		Test.stopTest();
	}

	@isTest static void testMixedReservationsWithoutDefaultProduct() {

		String gId = [SELECT id FROM Reservation_Cap_Group__c LIMIT 1][0].id ;
		List<Reservation__c> reservations = new List<Reservation__c>() ;
		reservations.add(new Reservation__c(Completed__c = true,  status__c = 'Deposit Made' )) ;
		reservations.add(new Reservation__c(Completed__c = true,  status__c = 'Reservation Made' )) ;
		insert reservations ;
		Test.startTest() ;
		Boolean b =  Boolean.valueof(RES_CapManagement.calcWaitlist(null, 2, true)) ;
		System.Assert(b) ;
		Test.stopTest();
	}

	@isTest static void testIsWaitlist() {
    
		Test.startTest();
		Reservation_Cap_Group__c g = [SELECT id FROM Reservation_Cap_Group__c LIMIT 1][0] ;
		g.Reservation_Cap__c = 1 ;
		update g ;
		Product2 product = [SELECT id FROM Product2 LIMIT 1][0] ;
		product.Res_ProductId__c = 'a b c';
		update product ;
		List<Reservation__C> reservations = new List<Reservation__C>() ;
		reservations.add(new Reservation__c(Completed__c = true, Reservation_Cap_Group__c = g.Id, status__c = 'Deposit Made' )) ;
		reservations.add(new Reservation__c(Completed__c = true, Reservation_Cap_Group__c = g.Id, status__c = 'Deposit Made' )) ;
		insert reservations ;
		RES_Settings.getSettings().capKey__c = 'a,b,c' ;
        RES_Settings.getSettings().NoCap__c = false ;
		Map<String,Object> data = new Map<String,Object>{ 'a' => 'a' , 'b' => 'b' , 'c' => 'c' } ;
        string jsonstring = JSON.serialize(data);
        RES_CapManagement.isOnWaitlist(jsonstring) ;
		
		
		Test.stopTest();
	}

	@isTest static void testIsNotWaitlist() {
   
		Test.startTest();
		Reservation_Cap_Group__c g = [SELECT id FROM Reservation_Cap_Group__c LIMIT 1][0] ;
		g.Reservation_Cap__c = 500 ;
		update g ;
		Product2 product = [SELECT id FROM Product2 LIMIT 1][0] ;
		product.Res_ProductId__c = 'a b c';
		update product ;
		List<Reservation__C> reservations = new List<Reservation__C>() ;
		reservations.add(new Reservation__c(Completed__c = true, Reservation_Cap_Group__c = g.Id, status__c = 'Deposit Made' )) ;
		reservations.add(new Reservation__c(Completed__c = true, Reservation_Cap_Group__c = g.Id, status__c = 'Deposit Made' )) ;
		insert reservations ;
		RES_Settings.getSettings().capKey__c = 'a,b,c' ;
		Map<String,Object> data = new Map<String,Object>{ 'a' => 'a' , 'b' => 'b' , 'c' => 'c' } ;
        string jsonstring = JSON.serialize(data);
        RES_CapManagement.isOnWaitlist(jsonstring) ;
		
		Test.stopTest();
}

}
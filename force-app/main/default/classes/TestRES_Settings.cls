/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-01-2022
 * @last modified by  : mbunch@gorillagroup.com
**/ 
@isTest
private class TestRES_Settings{

	@testSetup static void setup(){

		Webstore webstoreObj = new Webstore (
			Name = 'test value', 
			OptionsGuestBrowsingEnabled = TRUE, 
			OptionsSkipAdditionalEntitlementCheckForSearch = TRUE, 
			OptionsAutoFacetingEnabled = TRUE
		);
		insert webstoreObj;
		 
	}
 
	@isTest static void testGetSettings() {
		RES_Settings.webStoreId = [SELECT id FROM WebStore LIMIT 1][0].id ;
		Test.startTest();
		Reservation_Settings__mdt settings = RES_Settings.getSettings() ;
		Test.stopTest();
		System.Assert(settings != null , 'Excpected settings') ;
	}

	@isTest static void testGetWebStore() {
		Test.startTest() ;
		String id = RES_Settings.getWebStore() ;
		Test.stopTest() ;
		System.assert(id != null, 'Excpected web store id') ;
	}
    
    @isTest static void testNoSettings() {
		String storeId = [SELECT id FROM WebStore LIMIT 1][0].id ;
        RES_Settings.settings = null;
		Test.startTest();
		RES_Settings.getSettings(storeId);
		Test.stopTest();
		
	}

	@isTest static void testGetSettingsFromOrg(){

		Test.startTest();
		Reservation_Settings__mdt settings = RES_Settings.getSettingsFromOrg() ;
		Test.stopTest();
		System.Assert(settings != null , 'Excpected settings') ;		
	}

	@isTest static void testGetSettingsFromOrgDomain(){

		Test.startTest();
		RES_Settings.useOrgDomain = true ;
		Reservation_Settings__mdt settings = RES_Settings.getSettingsFromOrg() ;
		Test.stopTest();
		System.Assert(settings != null , 'Excpected settings') ;		
	}
}
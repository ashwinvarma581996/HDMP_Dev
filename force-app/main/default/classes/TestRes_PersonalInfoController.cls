/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-29-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
private without sharing class TestRes_PersonalInfoController{

	@testSetup static void setup(){

		UserRole userRole ;
		User admin ;
		List<UserRole> userRoles = [SELECT Id FROM UserRole WHERE DeveloperName = 'Honda_Owner' LIMIT 1];
		if ( userRoles.isEmpty())
		{
			admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != null AND isActive = true LIMIT 1];
		}
		else {
			admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRoles[0].Id AND isActive = true LIMIT 1];
		}
		System.runAs(admin) {
			Res_TestDataFactory.setUpReservationTest();
		}
	}

	static void injectSettings()
	{

		String accountId = [SELECT id FROM Account][0].id ;
		String productId = [SELECT id FROM Product2 WHERE Name LIKE 'reservation%'][0].id ;
		String webId = [SELECT id FROM WebStore][0].id ;
		RES_Settings.getSettings().Reservation_Account__c = accountId ;
		RES_Settings.getSettings().Reservation_Product_Id__c = productId ;
		RES_Settings.getSettings().storeid__c = webId ;
		//Res_PersonalInfoController.injectSettings(new Map<String,String>{ 'account' => accountId , 'product' => productId , 'store' => webId   })  ;
	}

	@isTest static void getWebStore() {

		String storeId = [SELECT id FROM WebStore LIMIT 1][0].id ;
		User user = [SELECT id FROM User LIMIT 1][0] ;
		String rv ;
		Test.startTest();
		System.runAs(user){
			rv = Res_PersonalInfoController.getWebStore() ;

		}
		Test.stopTest();

		System.assert(storeId == rv) ;
	}

	@isTest static void getSettings() {

		String storeId = [SELECT id FROM WebStore LIMIT 1][0].id ;
		User user = [SELECT id FROM User LIMIT 1][0] ;
		Reservation_Settings__mdt rv ;
		Test.startTest();
		injectSettings();
		rv = Res_PersonalInfoController.getSettings(storeId) ;

		Test.stopTest();
		System.assert(rv.StoreId__c == storeId, 'Expected ' + storeId + ' Received ' + rv.StoreId__c) ;
	}
// ewogICAiZXh0ZXJpb3JDb2xvciI6IlBlcmZvcm1hbmNlIFJlZCBQZWFybCIsCiAgICJleHRlcmlvckNvbG9yQ29kZSI6IkItNjIxIiwKICAgImludGVyaW9yQ29sb3IiOiJSZWQiLAogICAidmVoaWNsZU1vZGVsU2VyaWVzIjoiTURYIiwKICAgImludGVyaW9yQ29sb3JDb2RlIjoiUkUiLAogICAibW9kZWxJZCI6IlRDMUg2TUtOVyIsIAogICAibW9kZWxZZWFyIjoyMDIyLAogICAiZGVwb3NpdEFtb3VudCI6IiQ1MDAiLAogICAiaXNPbmJvYXJkZWREZWFsZXIiOnRydWUsCiAgICJkZWFsZXJOdW1iZXIiOiIyNTE2MzMiLAogICAiZGVhbGVyTmFtZSI6IkFjdXJhIG9mIFNoZXJtYW4gT2FrcyIsCiAgICJkZWFsZXJBZGRyZXNzIjoiNTIzMCBWYW4gTnV5cyBCbHZkIFNoZXJtYW4gT2FrcywgQ0EgOTE0MDEiLAogICAiZGVhbGVyUGhvbmVOdW1iZXIiOiI4MTgtNTI4LTEzMDAiLAogICAiY2FsbGJhY2tVcmwiOiIvdG9vbHMvcmVzZXJ2ZS1vbmxpbmUvY29uZmlybWF0aW9uIgp9

@istest
static void testSaveReservation() {

	Test.startTest() ;

	String s = Res_PersonalInfoController.getBackLink('eyJtb2RlbElkIjoiWUQ4SDlOS05XIiwidmVoaWNsZU1vZGVsU2VyaWVzIjoiTURYIFR5cGUgUyIsIm1vZGVsWWVhciI6IjIwMjIiLCJleHRlcmlvckNvbG9yIjoiTGlxdWlkIENhcmJvbiBNZXRhbGxpYyIsImV4dGVyaW9yQ29sb3JDb2RlIjoiTkgtODg1TSIsImV4dGVyaW9yQ29sb3JQcmljZSI6IiIsImludGVyaW9yQ29sb3IiOiJSZWQiLCJpbnRlcmlvckNvbG9yQ29kZSI6IlJFIiwiZGVwb3NpdEFtb3VudCI6IjUwMCIsIk1TUlAiOiIiLCJkZWFsZXJOdW1iZXIiOiIyNTEwNTkiLCJkZWFsZXJOYW1lIjoiQ2Vycml0b3MgQWN1cmEiLCJkZWFsZXJBZGRyZXNzIjoiMTg4MjcgU3R1ZGViYWtlciBSZCAiLCJkZWFsZXJQaG9uZU51bWJlciI6Iig4ODgpIDMyMS02Nzk3IiwiaXNQYXJ0aWNpcGFudERlYWxlciI6dHJ1ZSwiemlwQ29kZSI6IjkwNzAzIiwiY2FsbGJhY2tVcmwiOiJodHRwczovL2NhMS1uZXctYWN1cmEucG9zc2libGUuY29tL3Rvb2xzL3Jlc2VydmUtb25saW5lL2NvbmZpcm1hdGlvbiIsInN1YnNjaXB0aW9uSW5mbyI6eyJidXNpbmVzc0VudGl0eSI6IiIsImNhbXBhaWduTmFtZSI6Ik1EWCBMQVVOQ0ggQUhNIiwicHJvdmlkZXJQYXJ0aWNpcGFudERlYWxlciI6Ik1EWCBUeXBlIFMgRGVwb3NpdCBBSE0iLCJwcm92aWRlck5vblBhcnRpY2lwYW50RGVhbGVyIjoiTURYIExBVU5DSCBBSE0iLCJwcm92aWRlclJlc2VydmVXYWl0bGlzdCI6IiIsInZlaGljbGVNb2RlbE1hcmtldGluZ05hbWUiOiJNRFggVFlQRSBTIiwidmVoaWNsZU1vZGVsQm9keVN0eWxlIjoiIiwic2hvcHBpbmdUb29sIjoiUmVzZXJ2ZSBPbmxpbmUiLCJ0cmFuc2FjdGlvblR5cGUiOiJWTCIsImRlbGl2ZXJ5U2VuZERhdGUiOm51bGx9fQ') ;
	String mockJSON = '{'+
		'"id": "B268CC144C2C406F92E0462D8D8B923E",'+
		'"modelId": "FK1H3MKNW",'+
		'"uniqueModelId": "FK1H3MKNW",'+
		'"modelName": "Integra",'+
		'"packageName": "Integra",'+
		'"vehicleModelSeries": "A-Spec® (CVT)",'+
		'"modelYear": "2023",'+
		'"exteriorColor": "Liquid Carbon Metallic",'+
		'"exteriorColorCode": "NH-885M",'+
		'"exteriorColorPrice": "",'+
		'"interiorColor": "Red",'+
		'"interiorColorCode": "RE",'+
		'"depositAmount": "",'+
		'"MSRP": "",'+
		'"dealerNumber": "251183",'+
		'"dealerName": "Esserman International Acura",'+
		'"dealerAddress": "10455 NW 12th St",'+
		'"dealerPhoneNumber": "3054776666 ",'+
		'"dealerCity": "Doral",'+
		'"dealerState": "FL",'+
		'"isParticipantDealer": false,'+
		'"zipCode": "331722736",'+
		'"callbackUrl": "https://ca1-new-acura.possible.com/tools/reserve-online/confirmation",'+
		'"subsciptionInfo": {'+
			'"businessEntity": "Acura",'+
			'"campaignName": "",'+
			'"providerParticipantDealer": "Integra Reserve AHM",'+
			'"providerNonParticipantDealer": "Integra Launch AHM",'+
			'"providerReserveWaitlist": "Integra Waitlist AHM",'+
			'"vehicleModelBodyStyle": "",'+
			'"shoppingTool": "Reserve Online",'+
			'"transactionType": "VL",'+
			'"deliverySendDate": "",'+
			'"vehicleModelMarketingName": "2023 Integra A-Spec"'+
		'}'+
	'}';
	Product2 p = [SELECT id, Reservation_Cap_Group__c FROM Product2 LIMIT 1][0] ;
	Reservation_Contact2__c rc = [SELECT id FROM Reservation_Contact2__c LIMIT 1][0] ;
	String whatisIt = Res_PersonalInfoController.saveReservation(mockJSON, false, rc.id,p.id,p.Reservation_Cap_Group__c);

	Test.stopTest();

}


	@isTest static void getSession() {

		String resContact = [SELECT id FROM Reservation_Contact2__c LIMIT 1][0].id ;
		String reservation = [SELECT id FROM Reservation__c LIMIT 1][0].id ;
		Reservation_Settings__mdt settings = [SELECT id, Reservation_Account__c, StoreId__c, Reservation_Product_Id__c, Checkout_URL__c, User_Profile__c, Reservation_Cap__c, Base_Return_URL__c ,
                                					Include_No_Deposit_in_Cap_Calculation__c, Enable_Logging__c, Guest_Nickname_Prefix__c
                            							FROM Reservation_Settings__mdt WHERE DeveloperName = 'Default' ];
		Test.setMock(HttpCalloutMock.class, new Res_AddToCartMock());
		Reservation_Session__c rv ;
		Account a = [SELECT id FROM Account LIMIT 1][0] ;
		Contact c = Res_TestDataFactory.createContact(a);
		Test.startTest();
		RES_Settings.getSettings().Reservation_Account__c = a.id ;
		//Res_PersonalInfoController.injectSettings( new Map<STring,String> { 'acount' => a.id  } );
		settings = Res_PersonalInfoController.getSettings() ;
		String ex ;
		try {
			User u = Res_PersonalInfoController.createNewUser( a.id, settings.User_Profile__c, settings, c, 200, 1  ) ;
			rv = Res_PersonalInfoController.getSession(resContact,reservation, u.id,settings) ;
		}
		catch (Exception e) {
			ex = e.getMessage() ;
		}
		Test.stopTest();
		System.assert(ex == null, 'Excepted no exception.  Recieved: ' + ex ) ;
		System.assert(rv != null, 'Expected result') ;
	}

	@isTest
	static void testWaitlist()
	{
		Test.startTest();
		Boolean rv ;
		rv = Res_PersonalInfoController.waitlist() ;
		Test.stopTest() ;
		System.assert(!rv, 'Excpect false received true');
	}

	@isTest
	static void testWaitlis2()
	{
		Test.startTest();
		Boolean rv ;
		rv = Res_PersonalInfoController.waitlist(10,1) ;
		Test.stopTest() ;
		System.assert(!rv, 'Excpect false received true');
	}

	@isTest
	static void testGetLoginUser()
	{
		Reservation_Settings__mdt settings = Res_PersonalInfoController.getSettings(Res_PersonalInfoController.getWebStore()) ;
		RES_Settings.getSettings().Reservation_Account__c = [SELECT id FROM Account].id ;
		User u ;
		Test.startTest() ;

		User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != null AND isActive = true LIMIT 1];
		System.runAs(admin){
			u = Res_PersonalInfoController.getLoginUser(settings,0) ; }
		Test.stopTest() ;
		System.assert(u.Alias.startsWith('t') , 'Expected alieas with a leading t received'  + u.Alias ) ;
	}

	@IsTest
	static void testDoLogin()
	{
		String s ;
		Test.startTest();

		User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != null AND isActive = true LIMIT 1];
		System.runAs(admin) {
			s = Res_PersonalInfoController.doLogin('\test\test', false, 0) ;
		}
		Test.stopTest() ;
		System.assert(s == 'test', 'Expected test received: ' + s ) ;
	}

	@isTest
	static void testSaveFormDataException()
	{
		Map<String,Object> formData = new Map<String,Object>() ;
		formData.put('Accepted_Terms__c',true) ;
		formData.put('Email_Address__c', 'test@example.com');
		formData.put('First_Name__c', 'test');
		formData.put('Last_Name__c','test');
		formData.put('Phone_Number__c','11234567890');
		formData.put('Zip_Code__c', '46037') ;
		test.startTest();
		String id = Res_PersonalInfoController.saveFormData(formData, 'ip', 'language', 'browser') ;
		test.stopTest() ;
		System.assert(id != null, 'Excpected non null id') ;
	}

	@isTest
	static void testStartSession(){

		String uId = [SELECT id FROM User WHERE Alias = 'gst' AND IsActive = true LIMIT 1][0].id ;

		Reservation_Contact2__c rc = new REservation_Contact2__c( Accepted_Terms__c = true , Email_Address__c = 'test@example.com' , First_Name__c = 'test', Last_Name__c = 'test',
			Phone_Number__c = '11234567890', Zip_Code__c = '46037') ;

		insert rc ;

		Reservation__c r = new Reservation__c( Model_ID__c = '1234' , Model_Name__c = 'MDX' , Package_Name__c = 'package' , Vehicle_Model_Series__c = 'series', Model_Year__c = '2022' ,
			Exterior_Color__c = 'blue' , Exterior_Color_Code__c = 'bl' , 	Exterior_Color_Price__c =  null , Interior_Color__c = 'red' , Interior_Color_Code__c = 'rd' ,
			Deposit_Amount__c = 500.00, Dealer_Number__c = '12345' , 	Dealer_Name__c = 'Dealer' , Dealer_Address__c = 'Delaers place' , Dealer_Phone__c = '12345678901',
			Is_Participating__c =  true, 	Dealer_Postal_Code__c = '12345', Redirect_URL__c = '\\' , IsWaitlist__c = false, Campaign_Name__c  = 'campaign',
			Provider_Participating_Dealer__c = 'test' , Provider_Non_Participating_Dealer__c = 'test' , Provider_Reserve_Waitlist__c = 'test' ,
			Vehicle_Model_Marketing_Name__c = 'test' , Vehicle_Model_Body_Style__c = 'test' , Shopping_Tool__c = 'test' , Transaction_Type__c = 'TX' ,
			Delivery_Send_Date__c = null , Reservation_Contact2__c = rc.id)  ;

		insert r ;

		Test.startTest();
		String s = Res_PersonalInfoController.startSession(uId, rc.Id, r.id) ;
		Test.stopTest() ;

		System.assert(s != null, 'Expected return value') ;
	}

	@isTest
	static void testGetBackLink(){

		Test.startTest() ;
		String mockJSON = '{'+
		'"id": "B268CC144C2C406F92E0462D8D8B923E",'+
		'"modelId": "FK1H3MKNW",'+
		'"uniqueModelId": "FK1H3MKNW",'+
		'"modelName": "Integra",'+
		'"packageName": "Integra",'+
		'"vehicleModelSeries": "A-Spec® (CVT)",'+
		'"modelYear": "2023",'+
		'"exteriorColor": "Liquid Carbon Metallic",'+
		'"exteriorColorCode": "NH-885M",'+
		'"exteriorColorPrice": "",'+
		'"interiorColor": "Red",'+
		'"interiorColorCode": "RE",'+
		'"depositAmount": "",'+
		'"MSRP": "",'+
		'"dealerNumber": "251183",'+
		'"dealerName": "Esserman International Acura",'+
		'"dealerAddress": "10455 NW 12th St",'+
		'"dealerPhoneNumber": "3054776666 ",'+
		'"dealerCity": "Doral",'+
		'"dealerState": "FL",'+
		'"isParticipantDealer": false,'+
		'"zipCode": "331722736",'+
		'"callbackUrl": "https://ca1-new-acura.possible.com/tools/reserve-online/confirmation",'+
		'"subsciptionInfo": {'+
			'"businessEntity": "Acura",'+
			'"campaignName": "",'+
			'"providerParticipantDealer": "Integra Reserve AHM",'+
			'"providerNonParticipantDealer": "Integra Launch AHM",'+
			'"providerReserveWaitlist": "Integra Waitlist AHM",'+
			'"vehicleModelBodyStyle": "",'+
			'"shoppingTool": "Reserve Online",'+
			'"transactionType": "VL",'+
			'"deliverySendDate": "",'+
			'"vehicleModelMarketingName": "2023 Integra A-Spec"'+
		'}'+
	'}';
		String s = Res_PersonalInfoController.getBackLink(mockJSON) ;
		Test.stopTest();
        System.assert(true) ;
		// System.assert(! String.isBlank(s)) ;
	}
    @isTest
	static void testflushMethod(){
        List<Res_Log__c> logRecords = new List<Res_Log__c>() ;
        RES_Log__c logRec = new Res_Log__c(Log_data__c = 'test') ;
        logRecords.add(logRec) ;
        insert logRecords ;
        RES_Log__c logRec2 = new Res_Log__c(Log_data__c = 'test2') ;

        RES_Logger.logRecords.add(logRec2);
        Test.startTest() ;
        RES_Logger.flush();
        RES_Logger.Log(LoggingLevel.NONE, 'message');
        RES_Logger.Log('message');
        RES_Logger.Log(LoggingLevel.NONE, 'message',true);
        Test.stopTest() ;
    }
     @isTest
	static void testgetWebStore(){
        String storeId = [SELECT id FROM WebStore LIMIT 1][0].id ;

        //insert settings;

       RES_Settings.settings = null;
        Test.startTest() ;
        RES_Settings.getWebStore();
        RES_Settings.getSettings(storeId);

        Test.stopTest() ;
    }


    @isTest
    static void testBuildAccessoriesIdsString() {
        List<Object> accessories = new List<Map<String, String>> { new Map<String, String> {'opCode' => '1'}, new Map<String, String> {'opCode' => '2'}};
        Test.startTest() ;
        String accIds = Res_PersonalInfoController.buildAccessoriesIdsString(accessories);
        Test.stopTest() ;
        System.assert(accIds == '1,2');
    }

    @isTest
    static void testBuildAccessoriesNamesString() {
        List<Object> accessories = new List<Map<String, String>> { new Map<String, String> {'name' => '1'}, new Map<String, String> {'name' => '2'}};
        Test.startTest() ;
        String accNames = Res_PersonalInfoController.buildAccessoriesNamesString(accessories);
        Test.stopTest() ;
        System.assert(accNames == '1' + '\n'+ '2');
    }
}
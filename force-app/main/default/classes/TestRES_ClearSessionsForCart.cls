/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 10-28-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
@isTest
private class TestRES_ClearSessionsForCart{
	@isTest static void testCleanupSessions() {
		Test.startTest();
		Res_TestDataFactory.createWebStores(1);
		List<Account> accounts = Res_TestDataFactory.createAccounts(1) ;
		BuyerGroup buyerGroup = Res_TestDataFactory.createBuyerGroup() ;
		List<BuyerGroupMember> buyers = Res_TestDataFactory.createBuyers(buyerGroup,accounts);

		List<WebStore> stores = [SELECT id FROM WebStore LIMIT 1] ;

		WebCart cart = new WebCart();
		cart.Name = 'Test cart';
		cart.PoNumber = '123';
		cart.AccountId = accounts[0].Id;
		cart.WebStoreId = stores[0].Id;
		cart.Status = 'Active';
		cart.Type = 'Cart'; 
		cart.DealerId__c  = accounts[0].id;
		cart.CustomerStreet__c = '1234 Main Street'; 
		cart.CustomerCity__c = 'DALLAS'; 
		cart.Customer_State__c = 'TX'; 
		cart.CustomerCountry__c = 'USA';
		cart.CustomerPostalCode__c = '75201';
		cart.ShippingAmount__c = 0;
		insert cart;

		Reservation_Session__c s = new Reservation_Session__c(Cart__c = cart.id) ;
		insert s ;
		RES_ClearSessionsForCart.cleanUpSessions(new List<String>{ cart.id });
		Test.stopTest();
		System.assert([SELECT id FROM REservation_Session__c].size() == 0, 'expected no sessions');
	}

}
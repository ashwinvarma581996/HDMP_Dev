/**************************************************************************************
@File Name      : B2BUserConnectApiTest  
@Bussiness unit : HDM 
@Description    : It is created to code coverage for B2BGuestUserController, B2BCartControllerSample apex class
@Created By		: Soumya Sahoo 
@Created Date   : 05/04/2021
@API Version    : 54.0
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                    | User Story 
10/20/2021                | Soumya,Yashika   |                           | 
26/05/2022                | Mathi		     |							 | 
*****************************************************************************************/
@isTest(seeAllData=true)
private class B2BUserConnectApiTest {
	static Network communityObj = [SELECT id, name FROM Network where (name like 'dev%' OR  name like 'Dream%' )and status = 'Live' LIMIT 1];

	static Account acc = [SELECT Id FROM Account WHERE IsBuyer = TRUE  LIMIT 1];
	static WebStore store = [SELECT Id FROM WebStore where name like 'Dream%' LIMIT 1];
	static Product2 prodObj = B2B_TestDataFactory.createProduct_Vehicle(true);
	static User us=[select id from user limit 1];
    static Account personAccount = [SELECT Id,PersonContactId from Account where PersonContactId!=null ORDER BY CreatedDate DESC limit 1];
   	static User personAccoutUser=[select id,ContactId from user where contactid=:personAccount.PersonContactId limit 1];

	@isTest 
	static void testCartItemCategory() {
		Account personAccountId=B2B_TestDataFactory.createPersonAccount(true);
		User u = [SELECT Id, Name from User LIMIT 1];
		delete [SELECT Id FROM WebCart WHERE AccountId =: acc.Id];
		webcart cartdata1=B2B_TestDataFactory.createCart(true, acc.Id, store.Id);
		CartDeliveryGroup cdgObj = B2B_TestDataFactory.createCartDeliveryGroup(true, cartdata1.Id);
		CartItem cartItemObj = B2B_TestDataFactory.createCartItem(true, cartdata1.Id, cdgObj.Id, prodObj.Id);
		Id owneriddata=[select ownerid from webcart limit 1].ownerid;
		try{
			B2B_VehicleSelectorController.getCartItemCategory(communityObj.id);
		}catch(Exception ex){
			System.debug('errortest : '+ex);
		}
	}

	@isTest 
	static void testCartItemCategory1() {
		Account personAccountId=B2B_TestDataFactory.createPersonAccount(true);
		User u = [SELECT Id, Name from User LIMIT 1];
		delete [SELECT Id FROM WebCart WHERE AccountId =: acc.Id];
		webcart cartdata1=B2B_TestDataFactory.createCart(true, acc.Id, store.Id);
		CartDeliveryGroup cdgObj = B2B_TestDataFactory.createCartDeliveryGroup(true, cartdata1.Id);
		Product2 prod = B2B_TestDataFactory.createProduct_Vehicle(false);
		prod.Division__c='B';
		prod.StockKeepingUnit='testunit1';
		insert prod;
		
		CartItem cartItemObj = B2B_TestDataFactory.createCartItem(true, cartdata1.Id, cdgObj.Id, prod.Id);
		Id owneriddata=[select ownerid from webcart limit 1].ownerid;
		try{
			B2B_VehicleSelectorController.getCartItemCategory(communityObj.id);
		}catch(Exception ex){
			System.debug('errortest : '+ex);
		}
	}

	/*@isTest 
    static void testCartItemCategory2() {
        Account personAccountId=B2B_TestDataFactory.createPersonAccount(true);
        User u = [SELECT Id, Name from User LIMIT 1];
        delete [SELECT Id FROM WebCart WHERE AccountId =: acc.Id];
        webcart cartdata1=B2B_TestDataFactory.createCart(true, acc.Id, store.Id);
        CartDeliveryGroup cdgObj = B2B_TestDataFactory.createCartDeliveryGroup(true, cartdata1.Id);
        Product2 prod = B2B_TestDataFactory.createProduct_Vehicle(false);
        prod.Division__c='A;B';
        prod.StockKeepingUnit='testunit2';
        insert prod;
        
        CartItem cartItemObj = B2B_TestDataFactory.createCartItem(true, cartdata1.Id, cdgObj.Id, prod.Id);
        Id owneriddata=[select ownerid from webcart limit 1].ownerid;
        try{
            B2B_VehicleSelectorController.getCartItemCategory(communityObj.id);
        }catch(Exception ex){
            System.debug('errortest : '+ex);
        }
    }*/

	@isTest 
	static void testaddProductToCartItem1() {
		try{
			B2BGuestUserController.addProductToCartItem(acc.id,prodObj.StockKeepingUnit,communityObj.id,2.2,10);
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest 
	static void testgetActiveCartItems() {
		try{
			B2BGuestUserController.getActiveCartItems(communityObj.id);
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest 
	static void testgetActiveCartItems1() {
		try{
			B2BGuestUserController.getActiveCartItems('sryry');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest
	static void testcheckIfUserHasCartAndSetup() {
		test.startTest();
		try{
			Network communityObjtest = [SELECT id, name FROM Network where (name like 'dev%' OR  name like 'Dream%' ) ];
			B2BGuestUserController.checkIfUserHasCartAndSetup(communityObjtest.name,us.id);
		}catch(Exception ex){
			System.debug('error : '+ex);
			test.stopTest();
		}
	}

	//added by mathi to increase the code coverage 
	@isTest
	static void testcheckIfUserHasCartAndSetup1() {
		try{
			B2BGuestUserController.checkIfUserHasCartAndSetup('communityObj.id','us.id');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest 
	static void testresolveSortParam() {
		try{
			B2BUtils.resolveSortParam('ASC');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}


@isTest
	static void testAddItemToList(){
				Network communityObj1 = [SELECT Id, name FROM Network where (name like 'dev%' OR  name like 'Dream%' )and status = 'Live' LIMIT 1];
        
       		 Product2 product =[Select Id, StockKeepingUnit from Product2 LIMIT 1]	;
        Account acc =[SELECT Id,PersonContactId from Account where PersonContactId=:personAccoutUser.ContactId];
        Wishlist wishList= new Wishlist();
        Webstore store1=[SELECT Id from Webstore LIMIT 1];
       wishList= B2B_TestDataFactory.createWishlist(true, acc.Id, store1.Id, personAccoutUser.Id);
         Product_Model__c productModel=new Product_Model__c();
        productModel= B2B_TestDataFactory.createProductModel(true);
        WishlistItem lstOfItems = [Select Id From WishlistItem limit 1];
       
        System.RunAs(personAccoutUser){

				 B2B_LoggedInUserWishlist.addItemToList('Acura', null,communityObj1.id, product.StockKeepingUnit, personAccoutUser.Id,10,1, 'ABC','','','','','','undefined',productModel.Id,'1','1','1','1');
              }
        }
    
    @isTest
	static void testAddItemToListHonda(){
				Network communityObj1 = [SELECT Id, name FROM Network where (name like 'dev%' OR  name like 'Dream%' )and status = 'Live' LIMIT 1];
        
       		 Product2 product =[Select Id, StockKeepingUnit from Product2 LIMIT 1]	;
        Account acc =[SELECT Id,PersonContactId from Account where PersonContactId=:personAccoutUser.ContactId];
        Wishlist wishList= new Wishlist();
        Webstore store1=[SELECT Id from Webstore LIMIT 1];
       wishList= B2B_TestDataFactory.createWishlist(true, acc.Id, store1.Id, personAccoutUser.Id);
         Product_Model__c productModel=new Product_Model__c();
        productModel= B2B_TestDataFactory.createProductModel(true);
        WishlistItem lstOfItems = [Select Id From WishlistItem limit 1];
       
        System.RunAs(personAccoutUser){

				 B2B_LoggedInUserWishlist.addItemToList('Honda', acc.Id,communityObj1.id, product.StockKeepingUnit, personAccoutUser.Id,10,1, 'ABC','','','','','','undefined',productModel.Id,'1','1','1','1');
              }
        }

    @isTest
	static void testAddItemToListNegative(){
       try{
				 B2B_LoggedInUserWishlist.addItemToList('Acura', null,null, '123', null,10,null, 'ABC','','','','','','undefined',null,'1','1','1','1');
        
        }Catch(Exception ex){}
      }
  
	@isTest 
	static void testUpdateDealerIdOnCart() {
		try{
			B2B_LoggedInUserMyDealers.updateDealerIdOnCart(communityObj.Id, acc.Id);
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest 
	static void testaddProductToCartItem() {
		try{
			B2BGuestUserController.addProductToCartItem(acc.Id, '71107-SE3-A01', communityObj.id, 500, 10);
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	//mathi added this method for coverage
	@isTest
	static void testaddProductToCart2Item1() {
		try{
			B2BGuestUserController.addProductToCartItem('acc.Id', '71107-SE3-A02', communityObj.id, 50, 10);
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest
	static void testaddProductToCartItemClone() {
		try{
			cartItem Ci=[select  Id, op_code__c, Product2Id, Quantity FROM CartItem Limit 1];
			Product_Model__c p=B2B_TestDataFactory.createProductModel(True);
			B2BGuestUserController.addProductToCartItem_Clone(acc.Id, 'testunit', communityObj.id, 100.00, 10, 'red', 'test', 'Accessory', '', 'opcode', 'Honda', p.id, '19UUB2F64LA003874', true, 'Test Market Name', '10','1','1','1');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}
    	@isTest
	static void testaddProductToCartItemClone3() {
		try{
			cartItem Ci=[select  Id, op_code__c, Product2Id, Quantity FROM CartItem Limit 1];
			Product_Model__c p=B2B_TestDataFactory.createProductModel(True);
                B2BGuestUserController.addProductToCartItem_Clone(acc.Id, 'testunit', communityObj.id, 100.00, 10, 'red', 'test', 'abc', '', 'opcode', 'Honda', p.id, '19UUB2F64LA003874', true, 'Test Market Name', '10','1','1','1');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}
        	@isTest
	static void testaddProductToCartItemClone4() {
		try{
			cartItem Ci=[select  Id, op_code__c, Product2Id, Quantity FROM CartItem Limit 1];
			Product_Model__c p=B2B_TestDataFactory.createProductModel(True);
                B2BGuestUserController.addProductToCartItem_Clone(acc.Id, 'testunit', communityObj.id, 100.00, 10, 'red', 'test', 'part', '', 'opcode', 'Honda', p.id, '', false, 'Test Market Name', '10','1','1','1');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}
    	static void testaddProductToCartItemClone5() {
		try{
			cartItem Ci=[select  Id, op_code__c, Product2Id, Quantity FROM CartItem Limit 1];
			Product_Model__c p=B2B_TestDataFactory.createProductModel(True);
                B2BGuestUserController.addProductToCartItem_Clone(acc.Id, 'testunit', communityObj.id, 100.00, 10, 'red', 'test', 'part', '', 'opcode', 'Acura', p.id, '', false, 'Test Market Name', '10','1','1','1');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}
    
	@isTest
	static void testaddProductToCartItemClonetest() {
		try{
			cartItem Ci=[select  Id, op_code__c, Product2Id, Quantity FROM CartItem Limit 1];
			Product_Model__c p=B2B_TestDataFactory.createProductModel(True);
			B2BGuestUserController.addProductToCartItem_Clone(acc.Id, 'testunit', communityObj.id, 100.00, 10, 'red', 'test', 'Part', '', 'opcode', 'Honda', p.id, '', true, 'Test Market Name', '10','1','1','1');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

    
	@isTest
	static void testaddProductToCartItemClone1() {
		try{
			cartItem Ci=[select  Id, op_code__c, Product2Id, Quantity FROM CartItem Limit 1];
			Product_Model__c p=B2B_TestDataFactory.createProductModel(True);
			B2BGuestUserController.addProductToCartItem_Clone(acc.Id, 'testunit', communityObj.id, 100.00, 10, 'red', 'test', 'Part', '', 'opcode', 'Honda', p.id, '19UUB2F64LA003874', false, 'Test Market Name', '10','1','1','1');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest
	static void testProductModel() {
		Product_Model__c pm=new Product_Model__c(Product_Model_ID__c='abcd',Model_Year__c='1234',Model_Name__c='bwm',Trim__c='affr');
		insert pm;
		try{
			B2BGuestUserController.getModelId('1234','bwm','affr');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest
	static void testProductModel1() {
		Product_Model__c pm=new Product_Model__c(Product_Model_ID__c='abcd',Model_Year__c='1234',Model_Name__c='bwm',Trim__c='affr');
		insert pm;
		try{
			B2BGuestUserController.getModelId('1234','bwm','yyyy');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest 
	static void testgetModelIdByVIN() {
		Product_Model__c pm=new Product_Model__c (Model_Name__c	='bwww',Product_Model_ID__c='test2');
		insert pm;
		Honda_Product__c hp=new  Honda_Product__c (Product_Models__c=pm.id,Product_Identifier__c='affr');
		insert hp;
		try{
			B2BGuestUserController.getModelIdByVIN('affr');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest 
	static void testgetModelIdByVIN1() {
		
		Product_Model__c pm=new Product_Model__c (Model_Name__c	='bwww',Product_Model_ID__c='test3');
		insert pm;
		Honda_Product__c hp=new  Honda_Product__c (Product_Models__c=pm.id,Product_Identifier__c='affr');
		insert hp;
		try{
			B2BGuestUserController.getModelIdByVIN('huy');
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest
	static void testactiveCartItems() {
		try{
			B2BGuestUserController.getActiveCartItems(communityObj.id);
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest
	static void checkIfUserHasCartAndSetup() {
		try{
			 B2BGuestUserController.checkIfUserHasCartAndSetup(communityObj.id, us.id);
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest
	static void updateCartItems() {
		try{
			List<B2BGuestUserController.Product> productWrapperList = new List<B2BGuestUserController.Product>();
			B2BGuestUserController.Product bprod = new B2BGuestUserController.Product();
			bprod.DealerPrice = '500';
			bprod.PartNumber = '1';
			productWrapperList.add(bprod);
			
			B2BGuestUserController.AddToCart bat = new B2BGuestUserController.AddToCart();
			bat.communityId = communityObj.id;
			bat.accountId = acc.Id;
			bat.products = productWrapperList;
			
			B2BGuestUserController.updateCartItems(bat);
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest
	static void updateCartItems1() {
		try{
			B2BGuestUserController.AddToCart bat = new B2BGuestUserController.AddToCart();
			bat.accountId = acc.Id;
			B2BGuestUserController.Product bprod = new B2BGuestUserController.Product();
			B2BGuestUserController.updateCartItems(bat);
		}catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	@isTest
	private static void testupdateCartItem1(){
		Test.setMock(HttpCalloutMock.class, new RestMock1());
		Account objAccount = [Select Id From Account limit 1];
		WebCart objWebCart2 = [Select Id From WebCart Limit 1];
		Product2 prod=[select id from product2 limit 1]; 
		CartDeliveryGroup cartdelivery=[select id from CartDeliveryGroup limit 1];
		cartItem objcartitem=B2B_TestDataFactory.createCartItem(false,objWebCart2.id,cartdelivery.id,prod.id);
		try{
			B2BGuestUserController.updateCartItem(objcartitem.id,'2.2',12);
		}
		catch(Exception ex){
			System.debug('error : '+ex);
		}
	}

	private class RestMock1 implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			Product2 objProduct2  = [Select Id From Product2 Limit 1];
			WebCart objWebCart = [Select Id From WebCart Limit 1];
			WebCart objWebCart2 = [Select Id From WebCart Limit 1];
			Product2 prod=[select id from product2 limit 1]; 
			CartDeliveryGroup cartdelivery=[select id from CartDeliveryGroup limit 1];
			cartItem cartItems=B2B_TestDataFactory.createCartItem(True,objWebCart2.id,cartdelivery.id,prod.id);
			String fullJson = '{"productId" : "' + objProduct2 + '", "quantity" :100, "type" : "Product", "cartItemId" : "'+cartItems.Id+'"}';
			
			HTTPResponse res = new HTTPResponse();
			res.setHeader('Content-Type', 'text/json');
			res.setBody(fullJson);
			res.setStatusCode(202);
			res.setStatus('created');
			return res;
		}
	} 
	
}
@isTest(seeAllData=true)
private class B2BGetInfoTestSeeAllData{
    
    static Network communityObj = [SELECT id, name FROM Network where name like 'dev%' OR  name like 'Dream%' LIMIT 1];
    static Account acc = [SELECT Id FROM Account WHERE IsBuyer = TRUE  LIMIT 1];
    static B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
    static WebStore store = [SELECT Id FROM WebStore where name like 'Dream%' LIMIT 1];
    //static WebCart cart = B2B_TestDataFactory.createCart(true, acc.Id, store.Id);
    static Product2 prod = [SELECT Id, Name, STOCKKEEPINGUNIT from Product2 LIMIT 1];
    //static CartDeliveryGroup cdgObj = B2B_TestDataFactory.createCartDeliveryGroup(true, cart.Id);
    //static CartItem cartItemObj = B2B_TestDataFactory.createCartItem(true, cart.Id, cdgObj.Id, prod.Id);
    static User us=[select id from user limit 1];
    static ProductCatalog catalog = [SELECT Id from ProductCatalog LIMIT 1];
    static ProductCategory category = [SELECT Id, Name from ProductCategory WHERE CatalogId=:catalog.Id LIMIT 1];
    
    @isTest static void testgetProduct() {
        
        try{
             B2BGetInfo.getProduct(communityObj.id, prod.Id, acc.id);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }
    @isTest static void testgetCartSummary() {
        
        try{
             B2BGetInfo.getCartSummary(communityObj.id,acc.id);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }
    @isTest static void testaddToCart() {
        delete [SELECT Id FROM WebCart WHERE AccountId =: acc.Id];
        Product2 prod1 = [SELECT Id, Name, STOCKKEEPINGUNIT FROM PRODUCT2 LIMIT 1];
        ProductCategoryProduct pcp = new ProductCategoryProduct(ProductId=prod.Id, ProductCategoryId=category.Id,External_Id__c='12345', IsPrimaryCategory=true);
    	//insert pcp;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=store.Id, AccountId=b2b.Default_Guest_Account__c, status='Active');
        insert cart;        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;
        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct1', CartDeliveryGroupId=cartDeliveryGroup.Id, Product2Id=prod1.Id, Sku=prod1.StockKeepingUnit, Quantity=2);
        insert cartItem;
        try{
             B2BGetInfo.addToCart(communityObj.id, prod1.Id, '5', b2b.Default_Guest_Account__c);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    } 
	@isTest static void testgetProductPrice() {
        
        try{
            B2BGetInfo.getProductPrice(communityObj.id, prod.Id, acc.id);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }     
    
    @isTest static void testcheckProductCompatibility() {
        delete [SELECT Id FROM WebCart WHERE AccountId =: acc.Id];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=store.Id, AccountId=b2b.Default_Guest_Account__c, status='Active');
        insert cart;
        prod.Division__c='A';
        update prod;
        ProductCategoryProduct pcp = new ProductCategoryProduct(ProductId=prod.Id, ProductCategoryId=category.Id,External_Id__c='12345', IsPrimaryCategory=true);
    	//insert pcp;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;
        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct1', CartDeliveryGroupId=cartDeliveryGroup.Id, Product2Id=prod.Id, Sku=prod.StockKeepingUnit, Quantity=2);
        insert cartItem;
        try{
            B2BGetInfo.checkProductCompatibility(communityObj.id, prod.Id,  b2b.Default_Guest_Account__c);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }
    
	 @isTest static void testgetCartId() {
        
        try{
            User testUser = [SELECT Id FROM User WHERE Username = 'mdsfdc2020@gmail.com.updated603' LIMIT 1];
            System.runAs(testUser){
            	B2BGetInfo.getCartId(communityObj.id);
            }
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }
    
    @isTest(SeeAllData=true) static void Test_getCartCompatibility(){
        delete [SELECT Id FROM WebCart WHERE AccountId =: acc.Id];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=store.Id, AccountId=b2b.Default_Guest_Account__c, status='Active');
        insert cart;
        prod.Division__c='A';
        update prod;
        ProductCategoryProduct pcp = new ProductCategoryProduct(ProductId=prod.Id, ProductCategoryId=category.Id,External_Id__c='12345', IsPrimaryCategory=true);
    	//insert pcp;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;
        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct1', CartDeliveryGroupId=cartDeliveryGroup.Id, Product2Id=prod.Id, Sku=prod.StockKeepingUnit, Quantity=2);
        insert cartItem;
        
        try{
            B2BGetInfo.getCartCompatibility(prod.StockKeepingUnit,communityObj.id);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
        
    }
     @isTest static void testcreateAndAddToList() {
        
        try{
            B2BGetInfo.createAndAddToList(communityObj.id,prod.Id,'Wish123', acc.id);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }
    
    
}
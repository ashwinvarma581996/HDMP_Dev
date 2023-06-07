/**************************************************************************************
@File Name      : B2B_GetInfoTestClass  
@Business Unit  : HDM
@Description    : This is cover test coverage for B2BGetInfo
@Created By		: Sayeed Shaik
@Created Date   : 19/04/2022
@API Version    : 54.0
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                               | User Story 
09/06/2022                |<Raktim Bhowmick> | testpostivecheckProductCompatibility |
                                               Test_NegativegetCartCompatibility     
*****************************************************************************************/
@isTest(seeAllData=true)
Private class B2B_GetInfoTestClass{
    
    static Network communityObj = [SELECT id, name FROM Network where (name like 'dev%' OR  name like 'Dream%' )and status = 'Live' LIMIT 1];
    static Account acc = [SELECT Id FROM Account WHERE IsBuyer = TRUE  LIMIT 1];
    static B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
    static WebStore store = [SELECT Id FROM WebStore where name like 'Dream%' LIMIT 1];
    
    static Product2 prod = [SELECT Id, Name, STOCKKEEPINGUNIT from Product2 LIMIT 1];
    
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
    
    @isTest static void testnegativecheckProductCompatibility() {
        delete [SELECT Id FROM WebCart WHERE AccountId =: acc.Id];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=store.Id, AccountId=b2b.Default_Guest_Account__c, status='Active');
        insert cart;
        prod.Division__c='A';
        update prod;
        ProductCategoryProduct pcp = new ProductCategoryProduct(ProductId=prod.Id, ProductCategoryId=category.Id,External_Id__c='12345', IsPrimaryCategory=true);
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;
       
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
      
        ProductCategoryProduct pcp = new ProductCategoryProduct(ProductId=prod.Id, ProductCategoryId=category.Id,External_Id__c='12345', IsPrimaryCategory=true);
       
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
    @isTest
    static void Test_NegativegetCartCompatibility(){
    try{   
         delete [SELECT Id FROM WebCart WHERE AccountId =: acc.Id];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=store.Id, AccountId=b2b.Default_Guest_Account__c, status='Active');
        insert cart;
        prod.Division__c='D';
        update prod;
        ProductCategoryProduct pcp = new ProductCategoryProduct(ProductId=prod.Id, ProductCategoryId=category.Id,External_Id__c='12345', IsPrimaryCategory=true);
       
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;
       
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
    
    
      @isTest static void testpostivecheckProductCompatibility() {
        delete [SELECT Id FROM WebCart WHERE AccountId =: acc.Id];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=store.Id, AccountId=b2b.Default_Guest_Account__c, status='Active');
        insert cart;
        prod.Division__c='A';
        update prod;
        ProductCategoryProduct pcp = new ProductCategoryProduct(ProductId=prod.Id, ProductCategoryId=category.Id,External_Id__c='12345', IsPrimaryCategory=true);
        
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
    
}
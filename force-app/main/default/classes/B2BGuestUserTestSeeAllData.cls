@isTest(seeAllData=true)
private class B2BGuestUserTestSeeAllData {
  /*  static Network communityObj = [SELECT id, name FROM Network where name like 'dev%' LIMIT 1];
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
    
    @isTest static void testaddProductToCartItem() {
        
        try{
             B2BGuestUserController.addProductToCartItem(acc.Id, '71107-SE3-A01', communityObj.id, 500, 10);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }
    
    @isTest static void testaddProductToCartItemClone() {
        
        try{
             B2BGuestUserController.addProductToCartItem_Clone(acc.Id, '71107-SE3-A01', communityObj.id, 500, 10, 'red', 'test', 'test', 'test', 'test', '1');
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }
    
    @isTest static void testactiveCartItems() {
        
        try{
             B2BGuestUserController.getActiveCartItems(communityObj.id);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }

    @isTest static void checkIfUserHasCartAndSetup() {
        
        try{
             B2BGuestUserController.checkIfUserHasCartAndSetup(communityObj.id, us.id);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }
    
    @isTest static void updateCartItems() {
        
        try{
            B2BGuestUserController.AddToCart bat = new B2BGuestUserController.AddToCart();
            bat.communityId = communityObj.id;
            bat.accountId = acc.Id;
        	B2BGuestUserController.Product bprod = new B2BGuestUserController.Product();
            bprod.DealerPrice = '500';
            bprod.PartNumber = '1';
            B2BGuestUserController.updateCartItems(bat);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }*/
}
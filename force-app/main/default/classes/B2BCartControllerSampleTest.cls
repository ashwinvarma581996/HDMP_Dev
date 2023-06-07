/**
* @File Name          : B2BCartControllerSampleTest
* @Description        : It is created to code coverage for B2BCartControllerSample apex class.
* @Modified By        : Farazuddin
* @Date               : 08/09/2021
* @Last Modified By   : 
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       05/04/2021               Farazuddin            Initial Version
**/

@isTest(seeAllData=true)
private class B2BCartControllerSampleTest {
    static Network communityObj = [SELECT id, name FROM Network where Status = 'Live' AND name like 'Dream%' LIMIT 1];
    static Account acc = [SELECT Id FROM Account WHERE IsBuyer = TRUE  LIMIT 1];
    static WebStore store = [SELECT Id FROM WebStore where name like 'Dream%' LIMIT 1];//B2B_TestDataFactory.createStore(true);
    static WebCart cart = B2B_TestDataFactory.createCart(true, acc.Id, store.Id);
    static Product2 prodObj = B2B_TestDataFactory.createProduct(true);
    static CartDeliveryGroup cdgObj = B2B_TestDataFactory.createCartDeliveryGroup(true, cart.Id);
    static CartItem cartItemObj = B2B_TestDataFactory.createCartItem(true, cart.Id, cdgObj.Id, prodObj.Id);
    
    @isTest static void testGetCartItems() {
        B2BCartControllerSample.getCartItems(communityObj.Id, acc.Id, cart.Id, null, null);
    }
    
    @isTest static void testUpdateCartItem() {
        ConnectApi.CartItemInput cartItem = new ConnectApi.CartItemInput();
        cartItem.quantity = '1.00';
        try{
            B2BCartControllerSample.updateCartItem(communityObj.Id, acc.Id, cart.Id, cartItemObj.Id, cartItem);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }
    }
    
    @isTest static void testDeleteCartItem() {
        try{
            B2BCartControllerSample.deleteCartItem(communityObj.Id, acc.Id, cart.Id, cartItemObj.Id);
        }catch(Exception ex){
            System.debug('error : '+ex);
        }     
    }
    
    @isTest static void testGetCartSummary() {
        B2BCartControllerSample.getCartSummary(communityObj.Id, acc.Id, cart.Id);
    }
    
    @isTest static void testUnlockCart() {
        cart.Status = 'Checkout';
        update cart;
        Order ordObj = B2B_TestDataFactory.createOrder(true, acc.Id, cart.Id);
        B2BCartControllerSample.unlockCart(cart.Id);
    }
    
    @isTest static void testCreateCart() {
        delete [SELECT Id FROM WebCart WHERE AccountId =: acc.Id];
        B2BCartControllerSample.createCart(communityObj.Id, acc.Id);
    }
    
    @isTest static void testDeleteCart() {
        B2BCartControllerSample.deleteCart(communityObj.Id, acc.Id, cart.Id);
    }
    
    @isTest static void testGetCartItemsSku() {
        B2BCartControllerSample.getCartItemsSku(new List<String>{cartItemObj.Id});
    }
    
    @isTest static void testAddDealerInstallationPrice() {
        try {
            B2BCartControllerSample.addDealerInstallationPrice(new List<CartItem>{});
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        cartItemObj.Quantity = 2.00;
        cartItemObj.Dealer_Installation_Price__c = 8;
        B2BCartControllerSample.addDealerInstallationPrice(new List<CartItem>{cartItemObj});
    }
    
    @isTest static void testCartToActive() {
        cart.Status = 'Checkout';
        cart.OwnerId = UserInfo.getUserId();
        update cart;
        Order ordObj = B2B_TestDataFactory.createOrder(true, acc.Id, cart.Id);
        B2BCartControllerSample.cartToActive(UserInfo.getUserId());
    }
}
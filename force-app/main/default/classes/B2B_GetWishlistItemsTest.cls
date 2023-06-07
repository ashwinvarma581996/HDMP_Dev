@isTest
public class B2B_GetWishlistItemsTest {
    @testSetup 
    public static void setup(){
        User objUser = [Select Id from User LIMIT 1 ];
       
        WebStore store1 = new WebStore();
       store1=B2B_TestDataFactory.createStore(true);
      
       Account acc=new Account();
       acc= B2B_TestDataFactory.createAccount(true);
      
       B2B_Custom_Settings__c objB2BCustomSetting = new B2B_Custom_Settings__c();
       objB2BCustomSetting=B2B_TestDataFactory.createCustomSetting(true, acc.Id, objUser.Id);
          
       Product2 product = new Product2();
       product= B2B_TestDataFactory.createProduct(true);

       Wishlist wishList= new Wishlist();
       wishList= B2B_TestDataFactory.createWishlist(true, acc.Id, store1.Id, objUser.Id);
        
       WishlistItem wish = new WishlistItem();
       wish= B2B_TestDataFactory.createWishlistItem( true,  acc.Id, store1.Id, product.Id, wishList.Id);

         
    }

    @isTest
    private static void testGetWishlistItem(){
        WishlistItem lstOfItems = [Select Id From WishlistItem limit 1];
        List<WishlistItem> wish= new List<WishlistItem>();
        try{
            wish= B2B_GetWishlistItems.getWishlistItem(lstOfItems.Id);
        }catch(Exception ex){}
    }
}
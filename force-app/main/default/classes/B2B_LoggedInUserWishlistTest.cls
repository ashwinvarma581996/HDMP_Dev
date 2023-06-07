/**************************************************************************************
@File Name      : B2B_LoggedInUserWishlistTest  
@Description    : This class used to create test class for B2B_LoggedInUserWishlist
@Created By		: Yashika
@Created Date   : 05/03/2022
@API Version    : 54.0
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                    | User Story 
19/07/2022                |Yashika        |                           |            
*****************************************************************************************/
@isTest
public class B2B_LoggedInUserWishlistTest {
  static Network communityObj = [SELECT id, name FROM Network where (name like 'dev%' OR  name like 'Dream%' )and status = 'Live' LIMIT 1];

    @testSetup 
    public static void setup(){
        User objUser = [Select Id from User LIMIT 1 ];
       
        WebStore store1 = new WebStore();
       store1=B2B_TestDataFactory.createStore(true);
      
       Account acc=new Account();
       Product2 product = new Product2();
       product= B2B_TestDataFactory.createProduct(true);

       acc= B2B_TestDataFactory.createAccount(true);
       WebCart objWebCart =  B2B_TestDataFactory.createCart(true,acc.Id, store1.Id);
        CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, objWebCart.Id);
        CartItem objCartItem = B2B_TestDataFactory.createCartItem(true, objWebCart.Id, testdelivery.Id, product.Id);
       B2B_Custom_Settings__c objB2BCustomSetting = new B2B_Custom_Settings__c();
       objB2BCustomSetting=B2B_TestDataFactory.createCustomSetting(true, acc.Id, objUser.Id);
          
    Wishlist wishList= new Wishlist();
       wishList= B2B_TestDataFactory.createWishlist(true, acc.Id, store1.Id, objUser.Id);
        
       WishlistItem wish = new WishlistItem();
       wish= B2B_TestDataFactory.createWishlistItem( true,  acc.Id, store1.Id, product.Id, wishList.Id);
        Product_Model__c p=new Product_Model__c();
        p= B2B_TestDataFactory.createProductModel(true);
         
    }

 @isTest
    private static void testGetWishlistItem(){
             User uid=B2B_TestDataFactory.createUser(True);
        system.runAs(uid ){ 
          
        List<WishlistItem> wish= new List<WishlistItem>();
        wish= B2B_LoggedInUserWishlist.getWishlistItem('');
      }
}
    
    @isTest
    private static void testGetCustomSettings(){
        B2B_Custom_Settings__c cust =new B2B_Custom_Settings__c();
         cust= B2B_LoggedInUserWishlist.getCustomSettings();
    }

    @isTest
    private static void testRemoveItemFromList(){
        User objUser = [Select Id from User LIMIT 1 ];
        WishlistItem lstOfItems = [Select Id From WishlistItem limit 1];
        List<WishlistItem> wish= new List<WishlistItem>();
        wish= B2B_LoggedInUserWishlist.removeItemFromList(lstOfItems.Id, objUser.Id);
    }
  
    @isTest
    private static void testUpdateWishlistItem(){
        User objUser = [Select Id from User LIMIT 1 ];
        WishlistItem lstOfItems = [Select Id From WishlistItem limit 1];
        List<WishlistItem> wish= new List<WishlistItem>();
        wish= B2B_LoggedInUserWishlist.updateWishlistItem(lstOfItems.Id, 2, objUser.Id);
    }
        @isTest
    private static void testUpdateWishlistItemnegative(){
        try{
         B2B_LoggedInUserWishlist.updateWishlistItem(null, null, null);   
        }
        catch (exception ex){}
       
    }
    
    @isTest
    private static void testGetItemImage(){
        list<CartItem> ci =new list<CartItem>();
        CartItem c =[Select Id from CartItem ];
       ci= B2B_LoggedInUserWishlist.getItemImage( c.Id);
    }
     @isTest
    private static void testgetWishlistItemFromSKU(){
        User objUser = [Select Id from User LIMIT 1 ];
        WishlistItem lstOfItems = [Select Id From WishlistItem limit 1];
        List<WishlistItem> wish= new List<WishlistItem>();
        wish= B2B_LoggedInUserWishlist.getWishlistItemFromSKU(objUser.Id, '123');
    }
    @isTest
    private static void testgetCartItems(){
         WebCart c =[Select Id from WebCart ];
        List<CartItem> cartList = new List<CartItem>();
        cartList= B2B_LoggedInUserWishlist.getCartItems(c.Id, '123');
    }
    
    
@isTest
	static void testAddItemToList3(){
				
        		Network communityObj1 = [SELECT Id, name FROM Network where (name like 'dev%' OR  name like 'Dream%' )and status = 'Live' LIMIT 1];
        		User u = B2B_TestDataFactory.personAccountUser(true);
       		 Product2 product =[Select Id, StockKeepingUnit from Product2 LIMIT 1]	;
        Account acc =[SELECT Id,PersonContactId from Account where PersonContactId=:u.ContactId];
        Wishlist wishList= new Wishlist();
        Webstore store1=[SELECT Id from Webstore LIMIT 1];
       wishList= B2B_TestDataFactory.createHondaWishlist(true, acc.Id, store1.Id, u.Id);
         Product_Model__c productModel=new Product_Model__c();
        productModel= B2B_TestDataFactory.createProductModel(true);
        WishlistItem lstOfItems = [Select Id From WishlistItem limit 1];
       
        System.RunAs(u){

            B2B_LoggedInUserWishlist.addItemToList('Honda', acc.Id,communityObj1.id, product.StockKeepingUnit, u.Id,10,1, 'ABC','','','','','','',productModel.Id,'1','1', '1','1');
              }
        
    }
    @isTest
    static void testGetModelDetails(){
        Product_Model__c pm = [Select Id from Product_Model__c];
        B2B_LoggedInUserWishlist.getModelDetails(pm.Id);
    }
}
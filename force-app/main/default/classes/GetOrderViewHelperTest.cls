/*******************************************************************************
	Name: GetOrderViewHelperTest
    Business Unit: HDM
	Date: 07/01/2022
	Developer: Yashika
	Description: Covering GetOrderViewHelper class.
	*******************************************************************************
	MODIFICATIONS – V1 | 09/06/2022 | Sayalee | Added Header
	*******************************************************************************/

@isTest
public class GetOrderViewHelperTest {
    
    
    @testSetup 
    public static void setup(){
        User objUser = [SELECT Id FROM User LIMIT 1 ];
        
       WebStore store1 = new WebStore();
       store1=B2B_TestDataFactory.createStore(true);
        
       Account acc=new Account();
       acc= B2B_TestDataFactory.createAccount(true);
        
       B2B_Custom_Settings__c objB2BCustomSetting = new B2B_Custom_Settings__c();
       objB2BCustomSetting=B2B_TestDataFactory.createCustomSetting(true, acc.Id, objUser.Id);
        
       WebCart cart = new WebCart();
       cart= B2B_TestDataFactory.createCart(true, acc.Id, store1.Id );
        
       CartDeliveryGroup cartgroup = new CartDeliveryGroup();
       cartgroup =B2B_TestDataFactory.createCartDeliveryGroup(true, cart.Id);
        
       Product2 product = new Product2();
       product= B2B_TestDataFactory.createProduct(true);
        
       cartItem cartitm = new cartItem();
       cartitm=B2B_TestDataFactory.createCartItem(true, cart.Id, cartgroup.Id, product.Id );
       Order ord = B2B_TestDataFactory.createOrder(true, acc.Id, cart.Id);
       OrderItem orditem = B2B_TestDataFactory.createOrderItem(true,ord.Id,product.Id);
        
    }
    @isTest
    private static void testOrderDetails(){
        Order lstOfOrders = [SELECT Id,OrderNumber FROM Order LIMIT 1];
         List<Order> ord= new List<Order>();
        ord= GetOrderViewHelper.OrderDetails(lstOfOrders.OrderNumber);
    }
  
}
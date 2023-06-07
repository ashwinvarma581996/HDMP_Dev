/**************************************************************************************
@File Name      : OrderHelperTest
@Description    : This class used to create test class for OrderHelper
@Created By		: Yashika
@Created Date   : 05/07/2021
@API Version    : 54.0
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                    | User Story 
19/07/2022                |Yashika	 |		GetOrderItemsRelatedToOrderTest			 |	
*****************************************************************************************/

@isTest
public class OrderHelperTest {
   
    @testSetup static void setup(){
        User objUser = [Select Id from User LIMIT 1 ];
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
    public static void GetOrderItemsRelatedToOrderTest() {
       
        List<OrderItem> ODList =new List<OrderItem>();
       Order ord  = [Select Id, OrderNumber From Order Limit 1];
       OrderItem oItem =[select Id,Order.cart__c,Order.OrderNumber from OrderItem where OrderId = :ord.id];
        oItem.Type='Order Product';
        update oItem;
        system.debug([select Id,Type,Order.cart__c,Order.OrderNumber from OrderItem where OrderId = :ord.id]);
       test.startTest();
       OrderHelper.getOrderItemsRelatedToOrder(ord.OrderNumber);    	
       test.stopTest();
    }

}
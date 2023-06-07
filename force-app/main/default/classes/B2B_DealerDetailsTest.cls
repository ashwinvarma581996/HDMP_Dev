@isTest
private class B2B_DealerDetailsTest {
    @isTest 
    public static void testGetCartItemList(){
        WebStore store1 = new WebStore();
        store1=B2B_TestDataFactory.createStore(true);
        
        Account acc=new Account();
        User objUser=[Select Id from User LIMIT 1];
        B2B_Custom_Settings__c objB2BCustomSetting = new B2B_Custom_Settings__c();
        
        objB2BCustomSetting=B2B_TestDataFactory.createCustomSetting(true, acc.Id,objUser.Id);
       
        acc= B2B_TestDataFactory.createAccount(true);
        
        WebCart cart = new WebCart();
        cart= B2B_TestDataFactory.createCart(true, acc.Id, store1.Id );
        Product2 product = new Product2();
        product= B2B_TestDataFactory.createProduct(true);
        
        CartDeliveryGroup objCartDeliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(true,cart.Id);
        cartItem objcartItem = B2B_TestDataFactory.createCartItem(true,cart.Id,objCartDeliveryGroup.Id,product.Id);
        OrderDeliveryMethod objOrderDeliveryMethod = B2B_TestDataFactory.createOrderDeliveryMethod(true,'test',product.Id);
        Order ord = B2B_TestDataFactory.createOrder(true, acc.Id, cart.Id);
        OrderItem orditem = B2B_TestDataFactory.createOrderItem(true,ord.Id,product.Id);
        ord.Status = 'PARTIAL RETURN';
        update ord;
        Order_Return__c orRet= B2B_TestDataFactory.createOrderReturn(true, ord.Id);
       
        B2B_DealerDetails dealerDetails = new B2B_DealerDetails();
        dealerDetails.dealerRecId = acc.Id;
        dealerDetails.customer_Name = 'test';
        dealerDetails.order_Number= 'test';
        dealerDetails.order_Date= date.today();
        dealerDetails.order_deliveryType = 'test Type';
        dealerDetails.compPos = 1;
        
        dealerDetails.getdealerRec();
    }
}
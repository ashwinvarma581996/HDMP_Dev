@isTest
private class DisplayCartItemsCtrlTest {
    @isTest 
    public static void testGetCartItemList(){
        WebStore store1 = new WebStore();
        store1=B2B_TestDataFactory.createStore(true);
        
        Account acc=new Account();
         //User objUser = B2B_TestDataFactory.createUser(true);
        //system.runAs(objUser.Id){}
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
        //Order_Return__c orRet= B2B_TestDataFactory.createOrderReturn(true, ord.Id);
		DisplayCartItemsCtrl objDisplayCartItemsCtrl = new DisplayCartItemsCtrl();
        objDisplayCartItemsCtrl.cartId = cart.Id;
        objDisplayCartItemsCtrl.orderId = ord.Id;
        
        Invoice__c objInvoice = new Invoice__c();
        objInvoice.Order__c = ord.Id;
        objInvoice.Total_Restocking_Fee__c = 3;
        objInvoice.Total_Shipping_Amount__c = 3;
        objInvoice.Total_Invoice_Price__c = 30;
        objInvoice.Total_Invoice_Tax__c = 10;
        objInvoice.Invoice_Type__c = 'Order Return';
        insert objInvoice;
        objDisplayCartItemsCtrl.getOrderItemReturnList();
        Invoice_Item__c objInvoiceItem = new Invoice_Item__c();
        objInvoiceItem.Invoice__c = objInvoice.Id;
        objInvoiceItem.Product_SKU__c = 'sdfgdrewa';
        objInvoiceItem.Product_Name__c = 'New product';
        objInvoiceItem.Accessory_Op_Code__c = 'sdfbs';
        objInvoiceItem.Unit_Price__c = 10;
        objInvoiceItem.Item_Quantity__c = 1;
        objInvoiceItem.Extended_Price__c = 10;            
       	insert objInvoiceItem;
        
        objDisplayCartItemsCtrl.getCartItemList();
        objDisplayCartItemsCtrl.getOrderItemList();
        objDisplayCartItemsCtrl.getOrderItemReturnList();
        objDisplayCartItemsCtrl.getOrderReturnList();
        DisplayCartItemsCtrl.getMotocompactoMarkupMdt();
        
        cartItem objcartItem2 = B2B_TestDataFactory.createCartItem(true,cart.Id,objCartDeliveryGroup.Id,product.Id);
        objcartItem2.Product_Type__c = 'Motocompacto';
        update objcartItem2;
        objDisplayCartItemsCtrl.getIsMotocompacto();
        
        objDisplayCartItemsCtrl.handleDesktopView();
        objDisplayCartItemsCtrl.handleMobileView();
    }
}
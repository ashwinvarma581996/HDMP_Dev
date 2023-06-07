/******************************************************************************* 
Name:  B2B_GetOrderInfoTest
Business Unit: HDM
Create By: Sayeed Shaik 
Description: It is created to code coverage for B2B_GetOrderInfo apex class.

******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
		  25/08/2022 | <Vipul>  | HDMP-5357,HDMP-5358
*******************************************************************************/

@isTest
public class B2B_GetOrderInfoTest {
    
    @testSetup
    private static void createSetupData(){
       User objUser = B2B_TestDataFactory.createUser(true);
        User usi=[select id from user limit 1];
        system.runAs(usi)
	        {
               Account objAccount = B2B_TestDataFactory.createAccount(true);
               B2B_Custom_Settings__c objCustomSetting = B2B_TestDataFactory.createCustomSetting(true,objAccount.Id,objUser.Id); 
               WebStore objWebStore = B2B_TestDataFactory.createStore(true);
               WebCart objWebCart =  B2B_TestDataFactory.createCart(true,objAccount.Id, objWebStore.Id);
               Product2 product= B2B_TestDataFactory.createProduct(true);
               Order ord = B2B_TestDataFactory.createOrder(true, objAccount.Id, objWebCart.Id);
               OrderItem orditem = B2B_TestDataFactory.createOrderItem(true,ord.Id,product.Id);
    		}
    	}
    @istest
    private static void testgetMyOrderDetail()
    {	
        OrderItem oitem=[select id,order.ActivatedDate,type from OrderItem limit 1];
        //order  od=[select id from order limit 1];
        /*oitem.order.ActivatedDate=system.today();
        oitem.Type='Order Product';
        update oitem;*/
        B2B_GetOrderInfo.OrderRelatedWrapper wrapper = B2B_GetOrderInfo.getMyOrderDetail(oitem.Id);
	}
   	
    @istest 
    private static void testGetMyProductDetail(){
        Product2 product=[select id from product2 limit 1];
        product.StockKeepingUnit = 'test11';
        update product;
        
        B2B_GetOrderInfo.ProductRelatedWrapper wrapper = B2B_GetOrderInfo.getMyProductDetail('test11');
    }
    @isTest
    private static void testGetOrderList(){
     	//OrderItem oitem=[select id,order.type,order.BillingPostalCode,order.OrderNumber from OrderItem limit 1];
            //oitem.order.BillingPostalCode = 'xyz';
            //oitem.order.Type = 'Order Product';
        	//oitem.order.OrderNumber='12345';
            //update oitem;
           
        // updated by saikiran.
        order ord = [SELECT Id, Status FROM ORDER limit 1];
        ord.Status = 'Activated';
        update ord ;
        OrderItem oitem=[select id,OrderId,order.type,order.BillingPostalCode,order.OrderNumber, Order.OrderReferenceNumber,Order.OrderedDate from OrderItem limit 1];
        list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper = B2B_GetOrderInfo.getOrderList(oitem.order.OrderReferenceNumber,'','xyz');
        list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper2 = B2B_GetOrderInfo.getOrderList('','abc@honda.com','xyz');
        list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper3 = B2B_GetOrderInfo.getOrderList(oitem.order.OrderReferenceNumber,'abc@honda.com','');
        list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper4 = B2B_GetOrderInfo.getOrderList(oitem.order.OrderReferenceNumber,'abc@honda.com','xyz');
        
        ord.Status = 'ORDER COMPLETE - SHIPPED';
        ord.Shipping_Vendors__c = 'Other';
        update ord ;
          list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper5 = B2B_GetOrderInfo.getOrderList(oitem.order.OrderReferenceNumber,'','xyz');
        list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper6 = B2B_GetOrderInfo.getOrderList('','abc@honda.com','xyz');
        list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper7 = B2B_GetOrderInfo.getOrderList(oitem.order.OrderReferenceNumber,'abc@honda.com','');
        list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper8 = B2B_GetOrderInfo.getOrderList(oitem.order.OrderReferenceNumber,'abc@honda.com','xyz');
        
        
        
        //list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper = B2B_GetOrderInfo.getOrderList(oitem.order.OrderNumber,'','xyz');
       // list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper2 = B2B_GetOrderInfo.getOrderList('','abc@honda.com','xyz');
        //list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper3 = B2B_GetOrderInfo.getOrderList(oitem.order.OrderNumber,'abc@honda.com','');
        //list<B2B_GetOrderInfo.OrderRelatedWrapper> lstOfOrderRelatedWrapper4 = B2B_GetOrderInfo.getOrderList(oitem.order.OrderNumber,'abc@honda.com','xyz');

}
}
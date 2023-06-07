/*******************************************************************************
Name: OrderHelper
Business Unit: 
Created Date:  10/22/2021, 11:21 PM
Developer: 
Description: Apex class is created to get order & order related data.
*******************************************************************************

MODIFICATIONS – Date | Dev Name     | Method | User Story
26 Dec 2021          | shalini soni | OrderItemWrapper | HDMP-5428
*******************************************************************************/

public without sharing class OrderHelper {  
    
    @AuraEnabled(cacheable=true)
    public static OrderItemWrapper getOrderItemsRelatedToOrder(String orid) {
        
        System.debug('order id'+orid);
        String orderid=orid.replaceFirst('x', '8');
        String cartId = ''; 
        Set<String> setOfSKU = new Set<String>();
        List<OrderItem> ODList =new List<OrderItem>();
        List<CartItem> lstOfCartItems = new List<CartItem>();
        
        if(!String.isEmpty(orderid)){
            // Addded Product_Type__c as Part of SP2-16549
            ODList = [SELECT Id,Order.cart__c,Return_Quantity__c,Product2Id,Extended_Price__c,Cart_Item_Product_Name__c,
                      Product_Name__c,Updated_Quantity__c, Product_SKU__c,Type ,Product_Type__c,
                      Order.Status,Order.CustomerOrderStatus__c, Product2.Part__c,
                      Quantity,unitPrice,Order_Item_Status__c, ListPrice,Product_Model_Marketing_Name__c
                      from OrderItem where Order.OrderNumber = :orderid 
                      AND Type!='Delivery Charge' ORDER BY Product_SKU__c
                     ];
            
            //Added by shalini soni 6 Dec 2021 HDMP-5428 R2 Story
            if(ODList.size() >0){
                cartId = ODList[0].Order.cart__c;
                for(OrderItem orderItem : ODList) {
                    setOfSKU.add(orderItem.Product_SKU__c);
                }
            }
            
            if(setOfSKU.size() >0 && String.isNotBlank(cartId)){
                lstOfCartItems = [SELECT Id,Name, Sku,Quantity,Dealer_Installation_Price__c,cart.Delivery_Type__c,Product_Type__c  FROM CartItem WHERE
                                  CartId =: cartId AND Sku IN :setOfSKU 
                                 ];
            }
        }
        
        OrderItemWrapper objWrapper = new OrderItemWrapper(ODList,lstOfCartItems);
        
        system.debug('Orderitem: '+ODList);    
        //Ended
        return  objWrapper;
    }
    
    //Added by shalini soni 26 Dec 2021 HDMP-5428 R2 Story
	public Class OrderItemWrapper{
      @AuraEnabled  public List<OrderItem> orderItem;
      @AuraEnabled  public List<CartItem> cartItems;
        public OrderItemWrapper(List<OrderItem> orderItem, List<CartItem> cartItems){
            this.orderItem = orderItem;
            this.cartItems = cartItems;
        }
    } 
    //Ended
}
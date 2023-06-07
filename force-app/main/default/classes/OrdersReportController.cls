public without sharing class OrdersReportController {
    public Map<String,Map<Order, List<OrderItem>>> orderAndOrderItems  {get;set;}
    public OrdersReportController(){
        List<OrderItem> orderItems = [SELECT Id, OrderID,Order.GrandTotalAmount__c,Order.CreatedDate, Order.OrderNumber, Order.OrderReferenceNumber, Order.Account.Name, Product_Name__c, Product_SKU__c, Quantity, UnitPrice FROM OrderItem Where 
                                      Order.Account.Name != 'Reservation Guest' And CreatedDate = LAST_N_DAYS:7];
        List<Order> orders = new List<Order>();
        orderAndOrderItems = new  Map<String,Map<Order, List<OrderItem>>>();
        for(OrderItem oi : orderItems){
            if(!orderAndOrderItems.containsKey(oi.Order.Account.Name)){
                orderAndOrderItems.put(oi.Order.Account.Name, new Map<Order, List<OrderItem>>());
                orderAndOrderItems.get(oi.Order.Account.Name).put(oi.Order,new List<OrderItem>{oi});
            }
            else if(orderAndOrderItems.get(oi.Order.Account.Name).containsKey(oi.Order)){
                List<OrderItem> oItems = orderAndOrderItems.get(oi.Order.Account.Name).get(oi.Order);
                oItems.add(oi);
            	orderAndOrderItems.get(oi.Order.Account.Name).put(oi.Order, oItems);
            }
            else{
                orderAndOrderItems.get(oi.Order.Account.Name).put(oi.Order, new List<OrderItem>{oi});
            }
        }
    }
}
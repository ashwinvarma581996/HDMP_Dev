public  class EmailTemplateController {
   public list<OrderItem> orderItemList{get;set;}
   public Id recordId{get;set;}

   public list<OrderItem> getItems()
   {
      System.debug('I am here::'+recordId);
    orderItemList=[SELECT Id,AvailableQuantity,UnitPrice,Type, OrderId,Order.ActivatedDate,Order.Account.Name, Product2.Name,Product2.StockKeepingUnit, Order.OrderNumber, Order.Status, Order.ShippingAddress, Order.GrandTotalAmount  FROM OrderItem WHERE OrderId =:recordId];
    System.debug('orderItemList::'+orderItemList);
       return orderItemList;
   }
}
public with sharing class B2BGetOI {
	@AuraEnabled(cacheable=true)
    
    public static List<orderitem> getOrderItem(String oid) {
    return [
            SELECT Id, Product2.Name
            FROM OrderItem
            WHERE OrderId=:oid
        ];
  }

}
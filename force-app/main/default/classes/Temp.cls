public class Temp {
    public Temp(){
        Map<String, Id> marketingNameAndModelIdMap = new Map<String, Id>();
        for(Product_Model__c prodModal : [SELECT Id, Name, Model_Year__c, Model_Name__c, Product_Division__c, Product_Model_ID__c, Product_Subdivision__c, Trim__c FROM Product_Model__c 
                                          Where Model_Year__c != null And Model_Name__c != null And Product_Subdivision__c != null 
                                          And Trim__c != null And (Product_Subdivision__c = 'Acura' Or Product_Subdivision__c = 'Honda')]){
                                              if(String.isNotBlank(prodModal.Product_Subdivision__c) && String.isNotBlank(prodModal.Model_Year__c) && String.isNotBlank(prodModal.Model_Name__c) && String.isNotBlank(prodModal.Trim__c)){
                                              	  marketingNameAndModelIdMap.put(prodModal.Product_Subdivision__c + ' ' + prodModal.Model_Year__c + ' ' + prodModal.Model_Name__c + ' ' + prodModal.Trim__c, prodModal.Id);
                                              }
                
        }
        System.debug('$$marketingNameAndModelIdMap Size: '+marketingNameAndModelIdMap.size());
        List<OrderItem> orderItems = new List<OrderItem>();
        List<OrderItem> orderItemsAll = [SELECT Product_Model_Marketing_Name__c,Product_Model__c FROM OrderItem
                                         Where Order.Account_Name__c != 'Reservation Guest' and  Order.StatusCode = 'Activated' /*and Product_Model__c = null*/ 
                                         And Product_Model_Marketing_Name__c != null order by createddate DESC];
        System.debug('$$orderItemsAll Size: '+orderItemsAll.size());
        for(OrderItem orderItem : orderItemsAll){
              if(marketingNameAndModelIdMap.containsKey(orderItem.Product_Model_Marketing_Name__c)){
                  //System.debug('$$Marketing Name: '+orderItem.Product_Model_Marketing_Name__c);
                  //System.debug('$$ModelId: '+marketingNameAndModelIdMap.get(orderItem.Product_Model_Marketing_Name__c));
                  orderItem.Product_Model__c = marketingNameAndModelIdMap.get(orderItem.Product_Model_Marketing_Name__c);
                  orderItems.add(orderItem);
              }
        }
        //update orderItems;
        System.debug('$$orderItems Size: '+orderItems.size());
    }
    public static List<Product_Model__c> getModelId(String subdivision,String  year,String  model,String  trim){
        List<Product_Model__c> productModels = [SELECT Product_Subdivision__c , Model_Year__c, Model_Name__c, Trim__c FROM Product_Model__c 
                                                Where Product_Subdivision__c = :subdivision And Model_Year__c =: year And Model_Name__c =: model And Trim__c =:trim];
        return productModels;
    }
    public static List<OrderItem> getOrderItems(String marketingname){
        List<OrderItem> orderItems = [SELECT Product_Model_Marketing_Name__c,Product_Model__c FROM OrderItem Where Product_Model_Marketing_Name__c = :marketingname And 
                                      Order.Account_Name__c != 'Reservation Guest' and  Order.StatusCode = 'Activated' and Product_Model__c = null 
                                         And Product_Model_Marketing_Name__c != null order by createddate DESC];
        return orderItems;
    }
    @AuraEnabled
    public static void createLogs(String log){
        insert new Contact(LastName = log);
    }
}
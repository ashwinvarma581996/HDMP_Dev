global without sharing class B2B_VehicleSelectorController {    

    @AuraEnabled
    global static String getVehicleYear(String make){
         List<Vehicle__c> vehicleList  = [SELECT Year__c FROM Vehicle__c  Where Make__c = :make order by Year__c desc  LIMIT 5000];
         return JSON.serialize(vehicleList);
    }
    @AuraEnabled
    global static List<Vehicle__c> getVehicleMake(String make, Integer year){
         List<Vehicle__c> vehicleList  = [SELECT Model__c FROM Vehicle__c  Where Year__c = :year and Make__c = :make order by Year__c desc  LIMIT 5000];
         return vehicleList;
    }
    @AuraEnabled
    global static List<Vehicle__c> getVehicleTrim(String make, Integer year, String model){
         List<Vehicle__c> vehicleList  = [SELECT Trim__c FROM Vehicle__c  Where Year__c = :year and Make__c = :make and Model__c = :model order by Year__c desc  LIMIT 5000];
         return vehicleList;
    }
    
    @AuraEnabled
    public static Product2  getProduct(String productId) 
    {
     return [SELECT Id, Name, StockKeepingUnit, division__c from Product2 Where Id = :productId LIMIT 1];
    }
    @AuraEnabled
     public static String  getBrand(String cartId){
          String brandName  = [SELECT Id,Product_Subdivision__c FROM CartItem WHERE cartId = :cartId LIMIT 1]?.Product_Subdivision__c;
          return brandName;
     }
    
    @AuraEnabled
    public static String getCategoryId(String categoryName) 
    {
     ProductCategory cat = [select id,name from ProductCategory where name=:categoryName AND Catalog.Name LIKE '%DreamShop%' limit 1];
        
        return cat.id;
    }

    public class ItemWrapper
    {
      @AuraEnabled
     public string catName{get;set;}
     @AuraEnabled
     public Integer catCount{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static ItemWrapper getCartItemCategory(String communityId){
     B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
     String  effectiveAccountId = b2b.Default_Guest_Account__c;
     ConnectApi.CartSummary CurrentCart = B2BGetInfo.getCartSummary(communityId, effectiveAccountId) ;
     ItemWrapper ItemWrapperList=new ItemWrapper();
     String CartItemDivision='';
     Integer count=0;
     Boolean check=false;

    
     List<CartItem> cartItems = [SELECT Id,Product2.StockKeepingUnit,Product2.Id, Product2.Name, Product2.division__c FROM CartItem 
     WHERE cartId =: CurrentCart.cartId];
      
           if(cartItems.size() >= 1)
           {

           for(Integer i=0;i<cartItems.size();i++)
           {
               system.debug('sku_12345'+cartItems[i].Id);
               if(cartItems[i].Product2.division__c == 'A;B')
               {    
                    count++;
                    check=true;
               }
               else
               {
                    CartItemDivision= cartItems[0].Product2.division__c;
                    if(CartItemDivision == 'A')
                    {
                         ItemWrapperList.catName='honda';
                         ItemWrapperList.catCount=1;
                         check=false;
          
                    }
                    else if(CartItemDivision == 'B')
                    {
                         ItemWrapperList.catName='acura';
                         ItemWrapperList.catCount=1;
                         check=false;
          
                    }
                   
                }
      
           }
          }
      

     
      if(count>0  && check==true)
      {
          ItemWrapperList.catName='dual';
          ItemWrapperList.catCount=2;
      }
        System.debug('ItemWrapperList'+ItemWrapperList);
        return ItemWrapperList;
    }
}
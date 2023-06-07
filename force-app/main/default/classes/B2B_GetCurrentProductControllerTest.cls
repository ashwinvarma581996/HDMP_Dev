/**
* @File Name          : B2B_GetCurrentProductControllerTest
* @Description        : 
* @Created By         : Faraz Ansari
* @Date               : 30/10/2022
* @Last Modified By   : 30/10/2022
*==============================================================
* Ver         Date			Author           Modification
*==============================================================
* 1.0       30/10/2022    Faraz Ansari      Initial Version
**/
@isTest
private class B2B_GetCurrentProductControllerTest {
    @testSetup 
    public static void setup(){
        User objUser = [Select Id from User LIMIT 1 ];
       
        WebStore store1 = new WebStore();
       store1=B2B_TestDataFactory.createStore(true);
      
       Account acc=new Account();
       Product2 product = new Product2();
       product= B2B_TestDataFactory.createProduct(true);

       acc= B2B_TestDataFactory.createAccount(true);
       WebCart objWebCart =  B2B_TestDataFactory.createCart(true,acc.Id, store1.Id);
        CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, objWebCart.Id);
        CartItem objCartItem = B2B_TestDataFactory.createCartItem(true, objWebCart.Id, testdelivery.Id, product.Id);
       B2B_Custom_Settings__c objB2BCustomSetting = new B2B_Custom_Settings__c();
       objB2BCustomSetting=B2B_TestDataFactory.createCustomSetting(true, acc.Id, objUser.Id);
         Product_Model__c objPM = B2B_TestDataFactory.createProductModel(true);
    }
	
    @isTest static void testGetAddedProductsInfo(){
        
      List<Webcart>  wc=[Select Id from WebCart];
        CartItem  ci=[Select Id from CartItem];
         Product_Model__c pm= [Select Id from Product_Model__c];
         ci.Product_Type__c ='Accessory';
         ci.Product_Model__c =pm.Id;
        ci.op_code__c ='abc';
         update ci;
         Product2  pr=[Select Id from Product2];
        pr.ImageURL__c='abc';
        update pr;
        try{
            B2B_GetCurrentProductController.getAddedProductsInfo();
        }catch(Exception ex){
            
        }
    }
     @isTest static void testGetAddedProductsInfo3(){
        
      List<Webcart>  wc=[Select Id from WebCart];
        CartItem  ci=[Select Id from CartItem];
         Product_Model__c pm= [Select Id from Product_Model__c];
         pm.Product_Model_ID__c='abc';
         update pm;
         ci.Product_Type__c ='Part';
         ci.Product_Model__c =pm.Id;
          ci.Section_Id__c ='1';
         ci.Illustration_Id__c ='abc';
         ci.Illustration_Group_Image_Id__c='abc';
         ci.op_code__c ='abc';
         update ci;
         Product2  pr=[Select Id from Product2];
        pr.ImageURL__c='abc';
        update pr;
        try{
            B2B_GetCurrentProductController.getAddedProductsInfo();
        }catch(Exception ex){
            
        }
    }
     @isTest static void testGetAddedProductsInfo2(){
        
      List<Webcart>  wc=[Select Id from WebCart];
       
          try{
            B2B_GetCurrentProductController.getAddedProductsInfo();
        }catch(Exception ex){
            
        }
    }
     @isTest static void testGetAddedProductsInfoById(){
        
      List<Webcart>  wc=[Select Id from WebCart];
        CartItem  ci=[Select Id from CartItem];
         Product2  pr=[Select Id from Product2];
         Product_Model__c pm= [Select Id from Product_Model__c];
          pm.Product_Model_ID__c='abc';
         update pm;
         ci.Product_Type__c ='Part';
         ci.Section_Id__c ='1';
         ci.Illustration_Id__c ='abc';
         ci.Illustration_Group_Image_Id__c='abc';
         ci.Product_Model__c =pm.Id;
         ci.op_code__c ='abc';
         update ci;
         try { 
             B2B_GetCurrentProductController.getAddedProductsInfoByProductId(pr.Id);
         }catch(Exception ex){}
    }
    @isTest static void testGetAddedProductsInfoById2(){
        
      List<Webcart>  wc=[Select Id from WebCart];
        CartItem  ci=[Select Id from CartItem];
         Product2  pr=[Select Id from Product2];
         Product_Model__c pm= [Select Id from Product_Model__c];
          pm.Product_Model_ID__c='abc';
         update pm;
         ci.Product_Type__c ='Accessory';
         ci.Product_Model__c =pm.Id;
        ci.Section_Id__c ='1';
         ci.Illustration_Id__c ='abc';
         ci.Illustration_Group_Image_Id__c='abc';
         ci.op_code__c ='abc';
         update ci;
         try { 
             B2B_GetCurrentProductController.getAddedProductsInfoByProductId(pr.Id);
         }catch(Exception ex){}
    }
    
    @isTest static void testUpdateCartItems(){
        CartItem cartItemObj = new CartItem();
        cartItemObj.Quantity = 2.00;
        try{
            B2B_GetCurrentProductController.updateCartItems(new List<CartItem>{cartItemObj});
        }catch(Exception ex){}
        
    }
    @isTest static void testgetCategoryId(){
        try{
        string res= B2B_GetCurrentProductController.getCategoryId('abc');
        }catch(Exception ex){}
    }
     @isTest static void testgetVehicleDetailsByModelID(){
         Vehicle__c v= new Vehicle__c();
         try{
             v= B2B_GetCurrentProductController.getVehicleDetailsByModelID('abc');
         }catch(Exception ex){}
    }
}
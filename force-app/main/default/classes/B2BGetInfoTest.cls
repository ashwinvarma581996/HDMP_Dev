/**************************************************************************************
@File Name      : B2B_GetInfoTest  
@Description    : This is cover test coverage for B2BGetInfo
@Created By		: Deployment User
@Business Unit  : HDM
@Created Date   : 22/10/2021
@API Version    : 54.0
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                    | User Story 
26/05/2022                |<Raktim Bhowmick> | Test_getProuctQuantity2   |
*****************************************************************************************/ 
@isTest
private class B2BGetInfoTest {
    
    @testSetup static void setup() {
        Account testAccount = new Account(Name='TestAccount',PoIId__c='test');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        Account account = [SELECT Id FROM Account WHERE Name='TestAccount' LIMIT 1];
        WebStore webStore = [SELECT Id FROM WebStore WHERE Name='TestWebStore' LIMIT 1];
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
        insert cart;
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup;
        
        Product2 prod1 = new Product2(Name='TestProduct1', StockKeepingUnit='Prod1', Price__c=120, Description='Test1');
        insert prod1;
        Product2 prod2 = new Product2(Name='TestProduct2', StockKeepingUnit='Prod2', Price__c=150, Description='Test2');
        insert prod2;
        Product2 prod3 = new Product2(Name='TestProduct1', StockKeepingUnit='Prod3', Price__c=130,  Description='Test3');
        insert prod3;
        
        ProductCategoryProduct ProductCategoryProduct1 = B2B_TestDataFactory.createProductCategory(true ,prod1.Id );
        ProductCategoryProduct ProductCategoryProduct2 = B2B_TestDataFactory.createProductCategory(true , prod2.Id );

        CartItem cartItem1 = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct1', CartDeliveryGroupId=cartDeliveryGroup.Id, Product2Id=prod1.Id, Sku=prod1.StockKeepingUnit, Quantity=2);
        insert cartItem1;
        CartItem cartItem2 = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct2', CartDeliveryGroupId=cartDeliveryGroup.Id, Product2Id=prod2.Id, Sku=prod2.StockKeepingUnit, Quantity=3);
        insert cartItem2;
        CartItem cartItem3 = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct3', CartDeliveryGroupId=cartDeliveryGroup.Id, Product2Id=prod1.Id, Sku=prod3.StockKeepingUnit, Quantity=1);
        insert cartItem3;
        
        B2BGetInfo.getCartItemsCount(cart.Id);
        B2BGetInfo.Compatibility b2bcl = new B2BGetInfo.Compatibility();
        
      

    }
   
	@isTest static void Test_getProuctQuantity(){
        WebCart cart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1]; 
		Product2 prod = [SELECT Id, StockKeepingUnit from Product2 WHERE NAME = 'TestProduct1' AND StockKeepingUnit='Prod1'];
        CartItem cartItem = [SELECT Id, CartId, Sku, Quantity FROM CartItem WHERE CartId=:cart.Id and Sku=:prod.StockKeepingUnit LIMIT 1];        
        Decimal exp1 = B2BGetInfo.getProuctQuantity(cartItem.Sku,cartItem.CartId);  
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            Boolean res = B2BGetInfo.checkProductIsInStock(prod.Id);
        Test.stopTest();
        System.assertEquals(exp1, 2);
        
    }

    
    @isTest static void validategetCartItemsCount(){
        WebCart cart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1]; 
        Test.startTest();
        	B2BGetInfo.getCartItemsCount(cart.Id);
        Test.stopTest();
        
    }
    
    @isTest static void Test_getAllProuctQuantity(){
        WebCart cart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1];     
        Map<String,Decimal> exp2 = B2BGetInfo.getAllProuctQuantity(cart.Id);  
        Map<String,Decimal> act2 = new Map<String, Decimal>();
        act2.put('Prod1', 2);
        act2.put('Prod2', 3);
        act2.put('Prod3', 1);
        System.assertEquals(exp2, act2);
    }


	@isTest static void Test_ProductSKU(){        
               
		Product2 prod = [SELECT Id, StockKeepingUnit from Product2 LIMIT 1];             
        List<Product2> exp3 = B2BGetInfo.ProductSKU(prod.Id);  
        List<Product2> act3 = [SELECT Id, StockKeepingUnit from Product2 WHERE Id=:prod.Id];
        System.assertEquals(exp3, act3);
    }
    
    @isTest static void Test_getProdDetails(){        
                
		Product2 prod = [SELECT Id, StockKeepingUnit from Product2 LIMIT 1];   
        String exp3 = B2BGetInfo.getProdDetails(prod.Id);  
        
    }
    @isTest static void Test_NegativegetProdDetails(){        
               
		Product2 prod = [SELECT Id, StockKeepingUnit from Product2 LIMIT 1]; 
        String exp3 = B2BGetInfo.getProdDetails('');  
        
    }
      @isTest static void Test_NegativeListgetProdDetails(){        
               
		Product2 prod = [SELECT Id, StockKeepingUnit from Product2 LIMIT 1]; 
          
        
    }
    
    @isTest static void Test_getCategoryId(){        
		Product2 prod = [SELECT Id, StockKeepingUnit from Product2 LIMIT 1];
        ProductCategoryProduct prcategory=new ProductCategoryProduct();
        prcategory= B2B_TestDataFactory.createProductCategory(true, prod.Id);
        prcategory.IsPrimaryCategory=true;
        update prcategory;
        String exp4 = B2BGetInfo.getCategoryId(prod.Id);  
        
        
    }        
    
    @isTest static void Test_getResult(){
        Product2 prod = new Product2(Name='Snowboard Attachment1', StockKeepingUnit = '08L03-E09-100BABC123', Division__c = 'A');
        insert prod;
        B2BGetInfo.getResult(prod.StockKeepingUnit, prod.Division__c);
    }
	@isTest static void Test_NegativegetResult(){
        Product2 prod = new Product2(Name='Snowboard Attachment2', StockKeepingUnit = '08L03-E09-100BABC124', Division__c = 'A;B');
        insert prod;
        B2BGetInfo.getResult(prod.StockKeepingUnit, prod.Division__c);
    }    
    @isTest static void No_MatchingTest(){
        Product2 prod = new Product2(Name='Snowboard Attachment3', StockKeepingUnit = '08L03-E09-100BABC125', Division__c = 'A');
        insert prod;
        B2BGetInfo.getResult(prod.StockKeepingUnit, 'B');
    }    
    
    @istest static void Test_PostivegetDealerInfo(){
        Account testAccount = new Account(Name='TestAccount',PoIId__c='test');
        insert testAccount;
        B2BGetInfo.getDealerInfo(testAccount.name, testAccount.PoIId__c); //trying
    } 
   @istest 
    static void Test_getCartId(){
        Account acc = [SELECT Id FROM Account WHERE Name ='TestAccount' LIMIT 1];
        B2B_Custom_Settings__c b2b = new B2B_Custom_Settings__c(Name='test',Default_Guest_Account__c=acc.Id,Current_Sub_Category__c=1,Batch_Current_Brand__c='Honda');
        insert b2b;
        
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=acc.Id);
        insert cart;
        
        WebStore ws = [SELECT Id FROM WebStore LIMIT 1];
        WebCart wc = [SELECT Id FROM WebCart LIMIT 1];
        B2BGetInfo.getCartId(wc.Id);
    }
     
    
    @isTest
     static void Test_getProuctQuantity2(){
        WebCart cart = [SELECT Id FROM WebCart WHERE Name='Cart' LIMIT 1]; 
		Product2 prod = [SELECT Id, StockKeepingUnit from Product2 WHERE NAME = 'TestProduct1' AND StockKeepingUnit='Prod1'];
        CartItem cartItem = [SELECT Id, CartId, Sku, Quantity FROM CartItem WHERE CartId=:cart.Id and Sku=:prod.StockKeepingUnit LIMIT 1];        
        Decimal exp1 = B2BGetInfo.getProuctQuantity(cartItem.Sku,cartItem.CartId);  
        
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorexcp());
         Boolean res = B2BGetInfo.checkProductIsInStock(prod.Id);
        Test.stopTest();
        System.assertEquals(exp1, 2);
        
    }
    
    
    
}
/**************************************************************************************
@File Name      : B2BGuestUserControllerTest  
@Description    : This test class covers B2BGuestUserController
@Created By		: Mathi
@Business Unit  : HDM
@Created Date   : 26-5-2022
@API Version    : 54.0
*****************************************************************************************
MODIFICATIONS – Date      	| Dev Name         	| Method                    | User Story 
		V1		07-06-2022  | Sai kiran         | Updated header		    | 
		V2		20-07-2022	| Ravi Prasad		| Added test methods		|
*****************************************************************************************/ 

@isTest
public class B2BGuestUserControllerTest{
    static Network communityObj = [SELECT id, name FROM Network where (name like 'dev%' OR  name like 'Dream%' )and status = 'Live' LIMIT 1] ;
    
    @testSetup
    Private static void createSetupData(){
        User objUser = B2B_TestDataFactory.createUser(true);
        User u=[select id from user where email like '%@myorg.com' limit 1];
        system.runAs(u){
            Account objAccount = B2B_TestDataFactory.createAccountdealer(true); 
            Contact con=B2B_TestDataFactory.createContact(true);
            WebStore objWebStore = B2B_TestDataFactory.createStore(true);
            WebCart objWebCart =  B2B_TestDataFactory.createCart(true,objAccount.Id, objWebStore.Id);
            CartDeliveryGroup objCartDeliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(true,objWebCart.Id);
            Product2 objProduct2 = B2B_TestDataFactory.createProduct(true);
            OrderDeliveryMethod objOrderDeliveryMethod = B2B_TestDataFactory.createOrderDeliveryMethod(true,'test',objProduct2.Id);
            
            B2B_Custom_Settings__c objCustomSetting = B2B_TestDataFactory.createCustomSetting(true,objAccount.Id, objUser.Id);
            
           
            
            try{
                B2BGuestUserController.addItem(u.Id, objProduct2.Id, 50, 'https://lab-marketplace.cs67.force.com/s', objWebCart.Id, '500');
                
            }
            catch(exception e){}
            
        }
    }
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Product2 objProduct2  = [Select Id From Product2 Limit 1];
            Account personAccountId=B2B_TestDataFactory.createPersonAccount(true);//added by mathi now 
            
            WebCart objWebCart = [Select Id From WebCart Limit 1];
            WebCart objWebCart2 = [Select Id From WebCart Limit 1];
            Product2 prod=[select id from product2 limit 1]; 
            CartDeliveryGroup cartdelivery=[select id from CartDeliveryGroup limit 1];
            cartItem cartItems=B2B_TestDataFactory.createCartItem(True,objWebCart2.id,cartdelivery.id,prod.id);
            String fullJson = '{"productId" : "' + objProduct2 + '", "quantity" :100, "type" : "Product", "cartItemId" : "'+cartItems.Id+'"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(201);
            res.setStatus('created');
            return res;
        }
    }
   
    private class RestMock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Product2 objProduct2  = [Select Id From Product2 Limit 1];
            WebCart objWebCart = [Select Id From WebCart Limit 1];
            WebCart objWebCart2 = [Select Id From WebCart Limit 1];
            Product2 prod=[select id from product2 limit 1]; 
            CartDeliveryGroup cartdelivery=[select id from CartDeliveryGroup limit 1];
            cartItem cartItems=B2B_TestDataFactory.createCartItem(True,objWebCart2.id,cartdelivery.id,prod.id);
            String fullJson = '{"productId" : "' + objProduct2 + '", "quantity" :100, "type" : "Product", "cartItemId" : "'+cartItems.Id+'"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(202);
            res.setStatus('created');
            return res;
        }
    }    
    @isTest
    private static void testCreateSetupDataAndUser(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        Account objAccount = [Select Id From Account limit 1];
        B2B_Custom_Settings__c obCustomSetting = [Select Id From B2B_Custom_Settings__c limit 1];
        Webstore objWebstore = [Select Id From Webstore limit 1];
        Product2 objProduct23  = [Select Id From Product2 Limit 1];
        String redirecturl='https://dev-hondamarketplace.cs17.force.com/s/product/' + objProduct23.id;
        B2BGuestUserController.createSetupDataAndUser('',1,redirecturl,String.valueOf(objAccount.Id));
        try{
            //B2BGuestUserController.shareAccounts();
        }
        catch(exception e){}
        Test.stopTest();
   
    }
    @isTest
    private static void testCreateCartSetup(){
        Account objAccount = [Select Id From Account limit 1];
        User objUser = [Select Id From User Limit 1];
        B2BGuestUserController.createCartSetup(objUser.Id,objAccount.Id);
    }
    @isTest
    private static void testAddItem(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        WebCart objWebCart = [Select Id From WebCart Limit 1];
        contact objcontact = [Select Id From contact limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Plus User']; 
        UserRole r=[select id from UserRole limit 1];
        List<User> uu = new List<User>();
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com',ContactId=objcontact.id);      
        
        
        insert u; 
        
        Product2 objProduct2  = [Select Id From Product2 Limit 1];
        Test.startTest();
        try{
            B2BGuestUserController.addItem(u.Id,objProduct2.Id, 100, 'https://lab-marketplace.cs67.force.com/s',objWebCart.Id,'100');
        }
        catch(Exception e){}
        Test.stopTest();
    }
    //added by mathi for the coverage
    @isTest
    private static void testAddItem1(){
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        WebCart objWebCart = [Select Id From WebCart Limit 1];
        contact objcontact = [Select Id From contact limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Plus User']; 
        UserRole r=[select id from UserRole limit 1];
        List<User> uu = new List<User>();
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com',ContactId=objcontact.id);      
        
        
        insert u; 
        
        Product2 objProduct2  = [Select Id From Product2 Limit 1];
        Test.startTest();
        try{
            B2BGuestUserController.addItem(u.Id,objProduct2.Id, 100, 'https://lab-marketplace.cs67.force.com/s',objWebCart.Id,'100');
        }
        catch(Exception e){}
        Test.stopTest();
    }
    @isTest
    private static void testAddItem5(){
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        WebCart objWebCart = [Select Id From WebCart Limit 1];
        contact objcontact = [Select Id From contact limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Plus User']; 
        UserRole r=[select id from UserRole limit 1];
        List<User> uu = new List<User>();
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com',ContactId=objcontact.id);      
        
        
        insert u; 
        Product2 prod2 = new Product2(Name='TestProduct1', StockKeepingUnit='Prod1', Price__c=120, Description='Test1');
        Test.startTest();
        try{
            B2BGuestUserController.addItem(u.Id,prod2.Id, 100, 'https://lab-marketplace.cs67.force.com/s',objWebCart.Id,'100');
        }
        catch(Exception e){}
        Test.stopTest();
    }
    @isTest
    private static void addItem_Clone(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        contact objcontact = [Select Id From contact limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Plus User']; 
        UserRole r=[select id from UserRole limit 1];
        List<User> uu = new List<User>();
                WebCart objWebCart = [Select Id From WebCart Limit 1];

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com',ContactId=objcontact.id);      
        
        
        insert u; 
        Product2 prod1 = new Product2(Name='TestProduct1', StockKeepingUnit='Prod1', Price__c=120, Description='Test1');
        Product_Model__c pm = B2B_TestDataFactory.createProductModel(True);
        Test.startTest();
        try{
             B2BGuestUserController.addItem_Clone(u.Id, prod1.Id, 100, 'https://lab-marketplace.cs67.force.com/s', objWebCart.Id, '100', 'red', 'test', 'abc', 
             '', 'opcode', 'Honda', pm.Id, '19UUB2F64LA003874', true, 'Test Market Name', '10', '1', '1', '1');            
        }
        catch(exception e){}
        Test.stopTest();
    }
    
     @isTest
    private static void addItem_Clonetest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        contact objcontact = [Select Id From contact limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Plus User']; 
        UserRole r=[select id from UserRole limit 1];
        List<User> uu = new List<User>();
        WebCart objWebCart = [Select Id From WebCart Limit 1];
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com',ContactId=objcontact.id);      
        
        
        insert u; 
        
        Product2 objProduct2  = [Select Id From Product2 Limit 1];
        Product_Model__c pm = B2B_TestDataFactory.createProductModel(True);
        Test.startTest();
        try{
            B2BGuestUserController.addItem_Clone(u.Id, objProduct2.Id, 100, 'https://lab-marketplace.cs67.force.com/s', objWebCart.Id, '100', 'red', 'test', 'abc', '', 'opcode', 'Honda', pm.Id, '19UUB2F64LA003874', true, 'Test', '10', '1', '1', '1');
        }
        catch(exception e){}
        Test.stopTest();
    }
    @isTest
    private static void addItem_Clone1(){
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        contact objcontact = [Select Id From contact limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Plus User']; 
        UserRole r=[select id from UserRole limit 1];
        List<User> uu = new List<User>();
        WebCart objWebCart = [Select Id From WebCart Limit 1];
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com',ContactId=objcontact.id);      
        
        
        insert u; 
        
        Product2 objProduct2  = [Select Id From Product2 Limit 1];
        Product_Model__c pm = B2B_TestDataFactory.createProductModel(True);
        Test.startTest();
        try{
            B2BGuestUserController.addItem_Clone(u.Id, objProduct2.Id, 100, 'https://lab-marketplace.cs67.force.com/s', objWebCart.Id, '100', 'red', 'test', 'abc', '', 'opcode', 'Honda', pm.Id, '19UUB2F64LA003874', true, 'Test', '10', '1', '1', '1');
        }
        catch(exception e){}
        Test.stopTest();
    }
    @isTest
    private static void testCreateUser(){
        B2BGuestUserController.createUser();
    }
    @isTest
    private static void testCreateUserAndCartSetup(){
        Account objAccount = [Select Id From Account limit 1];
        B2BGuestUserController.createUserAndCartSetup(objAccount.Id);
    }
    //added by mathi
    @isTest
    Public static void updateCartItemVin(){
        try{
            test.startTest();
             Product2 product = new Product2();
        	product.Name = 'Test Product';
        //product.DealerPrice__c = 7500;
       	 product.Length_in__c = 12;
        	product.Width_in__c = 12;
        
       	 product.Height_in__c = 12;
        product.Weight_lbs__c = 20; 
        //product.Price__c = 7000;
        product.StockKeepingUnit='testunit';
            insert product;
            //CartItem ci=B2B_TestDataFactory.cartItem(True);
                Product_Model__c pm=new Product_Model__c(Product_Model_ID__c='abcd',Model_Year__c='1234',Model_Name__c='bwm',Trim__c='affr');
        insert pm;
             Honda_Product__c hp=new  Honda_Product__c (Product_Models__c=pm.id,Product_Identifier__c='19UUB2F64LA003874');
        insert hp;
            B2BGuestUserController.updateCartItemVin('testunit','19UUB2F64LA003874','ci.CartId');}
        
        catch(exception e){}
        test.stopTest();
    }
    @isTest
    private static void testAddToCart1(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        Account objAccount = [Select Id From Account limit 1];
        Product2 objProduct2  = [Select Id From Product2 Limit 1];
        WebCart objWebCart = [Select Id From WebCart Limit 1];
        B2BGuestUserController.addToCart1(objWebCart.Id,objAccount.Id,objProduct2.Id,50,'200');
        Test.StopTest();
    }
    @isTest
    private static void testcreatePermissionSetsSynchronous(){
        user u=[select id, name from user limit 1];
        B2BGuestUserController.createPermissionSetsSynchronous(u.name);
        try{
            B2BGuestUserController.checkIfUserIsLoggedIn();
        }
        catch(exception e){}
    }
        @isTest
    private static void testcreatePermissionSetsSynchronous1(){
      
        user u=[select id from user limit 1];
         try{
              // PermissionSetAssignment ps=new PermissionSetAssignment();
        //insert ps;
        B2BGuestUserController.createPermissionSetsSynchronous('abcd');
        }
        catch(exception e){}
    }
    
    @isTest
    private static void testupdateDealerOnCart(){
        Webstore objWebstore = [Select Id From Webstore limit 1];
        try{
            B2BGuestUserController.updateDealerOnCart('honda',objWebstore.id);
        }
        catch(exception e){}
    }
        private static void testupdateDealerOnCart1(){
        //Webstore objWebstore = [Select Id From Webstore limit 1];
        try{
            B2BGuestUserController.updateDealerOnCart('honda',null);
        }
        catch(exception e){}
    }
    @isTest
    private static void testgetAccountByDealerNo(){
        try{
            B2BGuestUserController.getAccountByDealerNo('test');
        } 
        catch(Exception ex){
            System.debug('error : '+ex);
        }  
    }
    @isTest
    private static void testgetAccountByDealerNo1(){
        try{
            B2BGuestUserController.getAccountByDealerNo('');
        } 
        catch(Exception ex){
            System.debug('error : '+ex);
        }
    }
    @isTest
    private static void testgetCurrentProduct(){
        product2 prod=[select id, name from product2 limit 1];
        B2BGuestUserController.getCurrentProduct(prod.id);
        B2BGuestUserController.getProduct('testunit');
    }
    
       @isTest
    private static void testgetCurrentProduct1(){
        Test.startTest();
        try{
            B2BGuestUserController.getProduct('abcd');
        }
        catch(Exception ex){
            System.debug('error : '+ex);
        }
        test.stopTest();
    }
           @isTest
    private static void testgetCurrentProduct3(){
        Test.startTest();
        try{
            B2BGuestUserController.getCurrentProduct('prod.id');
        }
        catch(Exception ex){
            System.debug('error : '+ex);
        }
        test.stopTest();
    }
    
    ///added below method by mathi
     @isTest
    private static void testupdateCartItemtest(){
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        Account objAccount = [Select Id From Account limit 1];
        WebCart objWebCart2 = [Select Id From WebCart Limit 1];
        Product2 prod=[select id from product2 limit 1]; 
        CartDeliveryGroup cartdelivery=[select id from CartDeliveryGroup limit 1];
        cartItem objcartitem=B2B_TestDataFactory.createCartItem(True,objWebCart2.id,cartdelivery.id,prod.id);
       B2BGuestUserController.updateCartItem(objcartitem.id,'2.2',12);  
                //B2BGuestUserController.updateCartItem(null,null,null);  

        
        B2BGuestUserController.getStateCodes();
        B2BGuestUserController.getcartTotalQuantity(objWebCart2.id);
        B2BGuestUserController.getVisualforceOrigin();
            
        Update_CartItem__e uc = new Update_CartItem__e();
        uc.Adjustment_Amount__c = 10;
        uc.Adjustment_Tax_Amount__c = 500;
        uc.Color__c = 'blue';
        uc.Cart_Item_Id__c = objWebCart2.id;
        
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(uc);
        Test.stopTest();
        
        try{
             B2BGuestUserController.addToCart1(objWebCart2.Id,objAccount.Id,prod.Id,50,'200');
        }
        catch(exception e){}
    }
    @isTest
    private static void testupdateCartItemtestcatch(){
        try{  Test.setMock(HttpCalloutMock.class, new RestMock1());
        Account objAccount = [Select Id From Account limit 1];
        WebCart objWebCart2 = [Select Id From WebCart Limit 1];
        Product2 prod=[select id from product2 limit 1]; 
        CartDeliveryGroup cartdelivery=[select id from CartDeliveryGroup limit 1];
        cartItem objcartitem=B2B_TestDataFactory.createCartItem(True,objWebCart2.id,cartdelivery.id,prod.id);
      // B2BGuestUserController.updateCartItem(objcartitem.id,'2.2',12);  
                B2BGuestUserController.updateCartItem(null,null,null);  

        
        B2BGuestUserController.getStateCodes();
        B2BGuestUserController.getcartTotalQuantity(objWebCart2.id);
        B2BGuestUserController.getVisualforceOrigin();
            
        Update_CartItem__e uc = new Update_CartItem__e();
        uc.Adjustment_Amount__c = 10;
        uc.Adjustment_Tax_Amount__c = 500;
        uc.Color__c = 'blue';
        uc.Cart_Item_Id__c = objWebCart2.id;
        
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(uc);
        Test.stopTest();
        
      
             B2BGuestUserController.addToCart1(objWebCart2.Id,objAccount.Id,prod.Id,50,'200');
        }
        catch(exception e){}
    }
    @isTest
    private static void testgetcartTotalQuantity(){
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        Account objAccount = [Select Id From Account limit 1];
        WebCart objWebCart2 = [Select Id From WebCart Limit 1];
        Product2 prod=[select id from product2 limit 1]; 
        CartDeliveryGroup cartdelivery=[select id from CartDeliveryGroup limit 1];
        cartItem objcartitem=B2B_TestDataFactory.createCartItem(True,objWebCart2.id,cartdelivery.id,prod.id);
        B2BGuestUserController.updateCartItem(objcartitem.id,'2.2',12); 
        try
        { 
            B2BGuestUserController.getcartTotalQuantity(objAccount.id);
        }
        
   
         catch(exception e){}
    }
	    
    @isTest
    private static void testUpdateCartItems(){
        User objUser = B2B_TestDataFactory.createUser(true);
        User u = [select id from user where email like '%@myorg.com' limit 1];
        WebCart objWebCart = [Select Id From WebCart Limit 1];
        
        System.runAs(u){
            Account objAccount = [Select Id From Account limit 1];
            Webstore objWebstore = [Select Id From Webstore limit 1];
            
            
            B2B_Custom_Settings__c objCustomSetting = B2B_TestDataFactory.createCustomSetting(true,objAccount.Id, objUser.Id);
            
            List<B2BGuestUserController.Product> productWrapperList = new List<B2BGuestUserController.Product>();
            B2BGuestUserController.Product productWrapper = new B2BGuestUserController.Product();
            productWrapper.PartNumber = '12345';
            productWrapper.DealerPrice = '100';
            productWrapperList.add(productWrapper);
            
            B2BGuestUserController.AddToCart addToCartWrapper = new B2BGuestUserController.AddToCart();
            addToCartWrapper.accountId = objAccount.Id;
            addToCartWrapper.communityId = communityObj.Id;
            addToCartWrapper.products = productWrapperList;
        
            //B2BGuestUserController.updateCartItems(addToCartWrapper);
        }        
    }
    
    @isTest
    private static void testCheckIfUserHasCartAndSetup(){
        User objUser = B2B_TestDataFactory.createUser(true);
        User u = [select id from user where email like '%@myorg.com' limit 1];
        Account objAccount = [Select Id From Account limit 1];
        
        System.runAs(u){
            //B2BGuestUserController.createPermissionSets(u.Id);
            //B2BGuestUserController.checkIfUserHasCartAndSetup(communityObj.id, objUser.Id);
        }
    }
    
    @isTest
    private static void testGetModelId(){
        Product_Model__c pm = new Product_Model__c(Product_Model_ID__c = 'abcd', Model_Year__c = '1234', Model_Name__c = 'bwm', Trim__c = 'affr');
        insert pm;
        
        Honda_Product__c hp = new  Honda_Product__c (Product_Models__c = pm.id, Product_Identifier__c = '19UUB2F64LA003874');
        insert hp;
        B2BGuestUserController.getModelId('1234', 'bwm', 'affr');
    }
    
    @isTest
    private static void testGetModelIdNegative(){
        try{
            B2BGuestUserController.getModelId('1234', 'bwm', 'affr');
        } catch(Exception ex){}
    }
    
    @isTest
    private static void testGetModelIdByVIN(){
        Product_Model__c pm = new Product_Model__c(Product_Model_ID__c = 'abcd', Model_Year__c = '1234', Model_Name__c = 'bwm', Trim__c = 'affr');
        insert pm;
        
        Honda_Product__c hp = new  Honda_Product__c (Product_Models__c = pm.id, Product_Identifier__c = '19UUB2F64LA003874');
        insert hp;
        B2BGuestUserController.getModelIdByVIN('19UUB2F64LA003874');
    }
    
    @isTest
    private static void testGetModelIdByVinNegative(){
        try{
			B2BGuestUserController.getModelIdByVIN('19UUB2F64LA003874');            
        } catch(Exception ex){}
    }
    
    @isTest
    private static void testUpdateCartItemVin(){
        //User objUser = B2B_TestDataFactory.createUser(true);
        //User u = [select id from user where email like '%@myorg.com' limit 1];
        WebCart objWebCart = [Select Id From WebCart Limit 1];
        
        //System.runAs(u){
            Product2 prod = [select id, StockKeepingUnit from product2 limit 1];
            CartDeliveryGroup cartdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true,objWebCart.Id);
            cartItem cartItem = B2B_TestDataFactory.createCartItem(True,objWebCart.id,cartdelivery.id,prod.id);
            
            Product_Model__c pm = new Product_Model__c(Product_Model_ID__c = 'abcd', Model_Year__c = '1234', Model_Name__c = 'bwm', Trim__c = 'affr');
            insert pm;
            
            Honda_Product__c hp = new  Honda_Product__c (Product_Models__c = pm.id, Product_Identifier__c = '19UUB2F64LA003874');
            insert hp;
            
            B2BGuestUserController.updateCartItemVin(prod.StockKeepingUnit, '19UUB2F64LA003874', objWebCart.Id);
            //B2BGuestUserController.updateCartItemVin(null, null, null);

            B2BGuestUserController.getVisualforceOrigin();
        //}
    }
@isTest
    private static void testgetProductSKUById(){
        
        Product2 prod = [select id, StockKeepingUnit from product2 limit 1];
       prod= B2BGuestUserController.getProductSKUById(prod.id);
    }
@isTest
    private static void testUpdateCartItemVintest(){
        try{ //User objUser = B2B_TestDataFactory.createUser(true);
        //User u = [select id from user where email like '%@myorg.com' limit 1];
        WebCart objWebCart = [Select Id From WebCart Limit 1];
        
        //System.runAs(u){
            Product2 prod = [select id, StockKeepingUnit from product2 limit 1];
            CartDeliveryGroup cartdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true,objWebCart.Id);
            cartItem cartItem = B2B_TestDataFactory.createCartItem(True,objWebCart.id,cartdelivery.id,prod.id);
            
            Product_Model__c pm = new Product_Model__c(Product_Model_ID__c = 'abcd', Model_Year__c = '1234', Model_Name__c = 'bwm', Trim__c = 'affr');
            insert pm;
            
            Honda_Product__c hp = new  Honda_Product__c (Product_Model__c = pm.id, Product_Identifier__c = '19UUB2F64LA003874');
            insert hp;
            
            //B2BGuestUserController.updateCartItemVin(prod.StockKeepingUnit, '19UUB2F64LA003874', objWebCart.Id);
            B2BGuestUserController.updateCartItemVin(null, null, null);

            B2BGuestUserController.getVisualforceOrigin();
        //}
    }
          catch (exception ex){
        
    }
    }
    
}
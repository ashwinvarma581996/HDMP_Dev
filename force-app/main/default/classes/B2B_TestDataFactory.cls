/**************************************************************************************
@File Name      : B2B_TestDataFactory  
@Description    : This class used to create test data for test classes
@Created By		: Raj Rishi Kaushik 
@Created Date   : 05/07/2021
@API Version    : 54.0
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                    | User Story 
06/07/2021                |Apoorv Garg       |                           |            
08/07/2021                |Apoorv Garg		 |							 |	
*****************************************************************************************/
@isTest
public class B2B_TestDataFactory {
    
    public static OrderItem createOrderItem(Boolean isInsert, String orderId, String productId){
        OrderItem objOrderItem = new OrderItem();
        objOrderItem.OrderId = orderId;
        objOrderItem.Product2Id = productId;       
        objOrderItem.Quantity = 2;
        objOrderItem.UnitPrice = 7500;  
        objOrderItem.ListPrice = 15000;
        //below line added to cover test class of B2BGetOrderInfoTest class
        objOrderItem.Type='Order Product';
        
        if(isInsert == true){
            insert objOrderItem;  
        }
        return objOrderItem;
    }
    public static Order createOrder(Boolean isInsert, String accountId, String cartId){
        Order objOrder = new Order();
        objOrder.Name = 'Test Order';
        objOrder.cart__c = cartId;  
        objOrder.OrderedDate = System.now() ;//Added by saikiran to cover B2B_GetOrderInfo Test class
        objOrder.AccountId = accountId;
        objOrder.Status = 'Draft';
        objOrder.IsPaymentReproccessing__c = false;
        objOrder.EffectiveDate = System.today().addDays(20);
        objOrder.BT_Transaction_Status__c = 'Authorized';
        objOrder.Updated_Order_Total__c = 90.0;
        objOrder.Billing_Email_Address_User_Email__c='test.org@honda.com';
        // below two line added by Soumya to cover B2B_GetOrderInfo Test class
        objOrder.BillingPostalCode='xyz';
        //objOrder.Type='Order Product';
        objorder.BillingEmailAddress='abc@honda.com';
        if(isInsert == true){
            insert objOrder;             
        }
        return objOrder;        
    }
    
    public static BT_Customer_Details__c createBTCustomerDetails(Boolean isInsert, String orderId){
        BT_Customer_Details__c objBTCustomerDetails = new BT_Customer_Details__c();
        objBTCustomerDetails.BT_CustomerId__c = '582110612';
        objBTCustomerDetails.Name = 'John1';
        objBTCustomerDetails.Order__c = orderId;       
        if(isInsert == true){
            insert objBTCustomerDetails;  
        }
        return objBTCustomerDetails;
        
    }
    
    public static BT_Transaction_Details__c createBTTransactionDetails(Boolean isInsert, String orderId){
        BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();
        objBTTransactionDetails.BT_TransactionId__c = 'fe67q2zd';
        objBTTransactionDetails.Name = 'John1 Transaction';
        objBTTransactionDetails.Order__c = orderId;     
        if(isInsert == true){
            insert objBTTransactionDetails;  
        }
        return objBTTransactionDetails;
        
    }
    
    public static Vehicle__c createVehicle(Boolean isInsert){
        Vehicle__c vObj = new Vehicle__c() ;       
        vObj.Model_Id__c =  'YK3F6KKNW';
        vObj.Year__c = 2019;
        vObj.Model__c = 'Ridgeline';
        vObj.Make__c = 'Honda';
        vObj.Trim__c = 'AWD RTL-T 6 Speed Automatic';        
        vObj.iNDivisionID__c = 1;       
        vObj.iNDivisionName__c = 'Honda';
        vObj.iNYearID__c = 50;
        vObj.iNYear__c = 2019;
        vObj.iNModelID__c = 17;
        vObj.iNModel__c = 'RIDGELINE';
        vObj.iNDoorID__c = 4;
        vObj.iNDoor__c = 4;
        vObj.iNGradeID__c = 4965;
        vObj.iNGrade__c = 'RTL (-T AWD/NAV/SUN)';
        vObj.iNCatalogID__c = 149;
        vObj.iNTransmissionID__c = 9;
        vObj.iNTransmission__c = '6AT';
        vObj.eConfigSourceCode__c = 'Honda';       
        vObj.eConfigModelID__c = 'YK3F6KKNW';
        vObj.eConfigDivisionID__c = 'A';
        if(isInsert == true){
            insert vObj;  
        }
        return vObj;
    }
    
    public static Account createAccount(Boolean isInsert){
        Account objAccount = new Account();
        objAccount.Name = 'test Account';
        objAccount.BillingStreet = '4300 S Georgia St';
        objAccount.BillingCity = 'AMARILLO';
        objAccount.BillingState = 'TX';
        objAccount.BillingPostalCode = '79110-1722';
        objAccount.Dealer_Type__c = 'Honda Auto';// Added by sai kiran
        objAccount.Operation_Hour__c = 'Mon-Fri 7:00AM-6:00PM;  Sat 7:00AM-5:00PM;  Sun Closed';
        objAccount.Email__c = 'test@gmail.com';
        objAccount.IsActive__c = true;
        objAccount.PoIId__c='34507';
        objAccount.Participation_Code__c='DRM';
        objAccount.Return_Policy__c = 'Return / Refund Policy <br><br>Last updated <br><br><br><br>Thank you for your purchase. We hope you are happy with your purchase. However, if you are not completely satisfied with your purchase for any reason, you may return it to us for. Please see below for more information on our return policy. <br><br><br><br>RETURNS<br><br><br><br>All returns must be postmarked within [#] days of the purchase date. All returned items must be in new and unused condition, with all original tags and labels attached.<br><br><br><br>RETURN PROCESS<br><br><br><br>ch';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = false;
        
        //insert objAccount;
        
        if(isInsert == true){
            Database.SaveResult sr = Database.insert(objAccount, dml);
        }
        return objAccount;
    }
    public static Account createPersonAccount(Boolean isInsert){
        String recordTypeId=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account' Limit 1].Id;
        Account objAccount = new Account();
        objAccount.RecordTypeId = recordTypeId;
        objAccount.Name = 'test Account';
        objAccount.BillingStreet = '4300 S Georgia St';
        objAccount.BillingCity = 'AMARILLO';
        objAccount.BillingState = 'TX';
        objAccount.BillingPostalCode = '79110-1722';
        objAccount.Operation_Hour__c = 'Mon-Fri 7:00AM-6:00PM;  Sat 7:00AM-5:00PM;  Sun Closed';
        objAccount.Email__c = 'test@gmail.com';
        objAccount.IsActive__c = true;
        objAccount.PoIId__c='test';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = false;
        
        //insert objAccount;
        
        if(isInsert == true){
            Database.SaveResult sr = Database.insert(objAccount, dml);
        }
        return objAccount;
    }
    public static Account createAccountdealer(Boolean isInsert){
        Account objAccountdealer = new Account();
        objAccountdealer.Name = 'test Account Dealer';
        //objAccountdealer.BillingStreet = '4300 S Georgia Dl';
        //objAccountdealer.BillingCity = 'AMARILL';
        //objAccountdealer.BillingState = 'TX';
        //objAccountdealer.BillingPostalCode = '79110-1700';
        objAccountdealer.Operation_Hour__c = 'Mon-Fri 7:00AM-6:00PM;  Sat 7:00AM-5:00AM;  Sun Closed';
        objAccountdealer.Email__c = 'testdealer@gmail.com';
        objAccountdealer.IsActive__c = true;
        objAccountdealer.PoIId__c='232244';
        objAccountdealer.Return_Policy__c = 'Return / Refund Policy <br><br>Last updated <br><br><br><br>Thank you for your purchase. We hope you are happy with your purchase. However, if you are not completely satisfied with your purchase for any reason, you may return it to us for. Please see below for more information on our return policy. <br><br><br><br>RETURNS<br><br><br><br>All returns must be postmarked within [#] days of the purchase date. All returned items must be in new and unused condition, with all original tags and labels attached.<br><br><br><br>RETURN PROCESS<br><br><br><br>To return an item, [please email customer service at [Email Address] to obtain a Return Merchandise Authorization (RMA) number. After receiving a RMA number,] place the item securely in its original packaging and [include your proof of purchase / the return form provided / other], and mail your return to the following address:<br><br><br><br>[Company Name]<br><br><br><br>Attn: Returns<br><br>[RMA #]<br><br>[Street Address]<br><br>[City, State ZIP Code]<br><br><br><br>Return shipping charges will be paid or reimbursed by us. / Please note, you will be responsible for all return shipping charges. We strongly recommend that you use a trackable method to mail your return. <br><br><br><br>REFUNDS<br><br><br><ah';
        //objAccountdealer.B2B_Preferred_Carrier__c='USPS';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        //dml.DuplicateRuleHeader.allowSave = true;
        //dml.DuplicateRuleHeader.runAsCurrentUser = false;
        
        insert objAccountdealer;
        
        if(isInsert == false){
            Database.SaveResult sr = Database.insert(objAccountdealer, dml);
        }
        return objAccountdealer;
    }
    
    public static Account createAccount(Boolean isInsert,String merchantId){
        Account objAccount2 = new Account();
        objAccount2.Name = 'test Account';
        objAccount2.Merchant_Id__c = merchantId;
        objAccount2.PoIId__c= '123test';        
        if(isInsert == true){
            insert objAccount2;  
        }
        return objAccount2;
    }
    
    public static WebStore createStore(Boolean isInsert){
        WebStore store1 = new WebStore();
        store1.Name = 'Dream';
        store1.Description = 'Test Description';
        store1.DefaultLanguage='en_US';
        store1.PaginationSize = 1;
        if(isInsert == true){
            insert store1;  
        }
        return store1;
    }
    
    public static WebCart createCart(Boolean isInsert, String accId, String storeId){
        WebCart cart = new WebCart();
        cart.Name = 'Test cart';
        cart.PoNumber = '123';    
        cart.AccountId = accId;
        cart.WebStoreId = storeId;
        cart.Status = 'Active';
        cart.Type = 'Cart';       
        cart.CustomerStreet__c = '1234 Main Street'; 
        cart.CustomerCity__c = 'DALLAS'; 
        cart.Customer_State__c = 'TX'; 
        cart.CustomerCountry__c = 'USA';
        cart.CustomerPostalCode__c = '75201';
        cart.ShippingAmount__c = 0;
        cart.Delivery_Type__c = 'Ship to Me';
        cart.OwnerId = UserInfo.getUserId();
        cart.Customer_Email__c= 'abc@gmail.com';
        cart.Customer_Name__c='test user';
        cart.Customer_Phone__c='1234567891';
        cart.Pickup_Dealer__c=false;
        cart.DealerId__c=accId;
        cart.OwnerId = UserInfo.getUserId();
        if(isInsert == true){
            insert cart;  
        }
        return cart;
    }
    
    public static CartDeliveryGroup createCartDeliveryGroup(Boolean isInsert , String cartId){
        CartDeliveryGroup cartgroup = new CartDeliveryGroup();
        cartgroup.Name = 'Test Delivery Group';
        cartgroup.CartId = cartId;
        if(isInsert == true){
            insert cartgroup;  
        }
        return cartgroup;
    }
    
    public static cartItem createCartItem(Boolean isInsert ,String cartId,String cartDeliveryGroupId,String product2Id){
        cartItem cart = new cartItem();
        cart.Name = 'Test Cart Item';
        cart.CartId = cartId;
        cart.Product2Id = product2Id;
        cart.CartDeliveryGroupId = cartDeliveryGroupId;
        cart.Quantity = 10;
        cart.Dealer_Installation_Price__c=267;
        cart.Product_Type__c='Part';
        if(isInsert == true){
            insert cart;  
        }
        return cart;
    }
    
    public static Product2 createProduct(Boolean isInsert){
        Product2 product = new Product2();
        product.Name = 'Test Product';
        //product.DealerPrice__c = 7500;
        product.Length_in__c = 12;
        product.Width_in__c = 12;
        
        product.Height_in__c = 12;
        product.Weight_lbs__c = 20; 
        //product.Price__c = 7000;
        product.StockKeepingUnit='testunit';
        if(isInsert == true){
            insert product;  
        }
        return product;        
    } 
    public static Product2 createProduct_Vehicle(Boolean isInsert){
        Product2 product = new Product2();
        product.Name = 'Test Product';
        //product.DealerPrice__c = 7500;
        product.Length_in__c = 12;
        product.Width_in__c = 12;
        product.Division__c='A';
        product.Height_in__c = 12;
        product.Weight_lbs__c = 20; 
        //product.Price__c = 7000;
        product.StockKeepingUnit='testunit';
        if(isInsert == true){
            insert product;  
        }
        return product;        
    } 
    
    public static ProductCategoryProduct createProductCategory(Boolean isInsert,String productId){
        
        ProductCatalog objProdCatalog = new ProductCatalog();
        objProdCatalog.Name = 'DreamShop';
        insert objProdCatalog;
        ProductCategory objProdCategory = new ProductCategory();
        objProdCategory.Name = 'Test Product Category';
        objProdCategory.CatalogId = objProdCatalog.Id;
        insert objProdCategory;
        ProductCategoryProduct testproduct = new ProductCategoryProduct();
        testproduct.ProductId = productId;
        testproduct.ProductCategoryId = objProdCategory.Id;
        testproduct.External_Id__c='test';
        if(isInsert == true){
            insert testproduct;  
        }
        return testproduct;        
    } 
    
    public static BT_Token_Details__c createBTTokenDetails(Boolean isInsert,String accId){        
        BT_Token_Details__c bttoken = new BT_Token_Details__c();
        bttoken.Account__c= accId;
        bttoken.AccessToken__c = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        bttoken.RefreshToken__c = 'refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130';
        DateTime currentTime = System.now();
        bttoken.AccessTokenExpiresAt__c=  System.now();
        bttoken.RefreshTokenExpiresAT__c=  currentTime.addMinutes(30); 
        
        if(isInsert == true){
            insert bttoken; 
        }
        return bttoken;        
    } 
    public static OrderDeliveryMethod createOrderDeliveryMethod(Boolean isInsert,String name, String productId){
        OrderDeliveryMethod objOrderDeliveryMethod = new OrderDeliveryMethod();
        objOrderDeliveryMethod.Name = name;
        objOrderDeliveryMethod.ProductId = productId;
        
        if(isInsert == true){
            insert objOrderDeliveryMethod; 
        }
        return objOrderDeliveryMethod;   
    }
    public static User createUser(Boolean isInsert){
        UserRole r = new UserRole(Name='test');
        insert r;
        system.debug('data'+r.id);
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> uu = new List<User>();
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com',UserRoleId = r.Id);      
        
        if(isInsert == true){
            insert u; 
        }
        return u; 
    }
    public static User createUserWithContact(Boolean isInsert){
        UserRole r = new UserRole(Name='test');
        insert r;
        //system.debug('data'+r.id);
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        
        User u = new User(Alias = uid, Email= uid + '@myorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com',UserRoleId = r.Id);      
        
        try
        {
            if(isInsert == true){
                insert u; 
                System.debug('User is'+u);
            }
            
            B2B_TestDataFactory.createPersonAccount(true);
            Account acc=[select PersonContactId from Account Limit 1];
            u.ContactId = acc.PersonContactId;
            update u;
            
        }
        catch(Exception e)
        {
            System.debug('Contact error line no'+e.getLineNumber());
            System.debug('Contact error msg'+e.getMessage());
        }
        return u; 
    }
    public static Contact createContact(Boolean isInsert){
        contact con=new contact();
        B2B_TestDataFactory.createAccount(true);
        account acc=[select id from Account Limit 1];
        con.FirstName = 'Guest';
        con.LastName = 'Contactname';
        con.Email = 'guest@test.com';
        con.AccountId = acc.id;
        insert con;
        return con;
        
    }
    
    public static Order_Return__c createOrderReturn(Boolean isInsert, String OrderId){
        Order_Return__c ord =new Order_Return__c();
        ord.Order__c=OrderId;
        ord.Status__c='PARTIAL RETURN';
        if(isInsert == true){
            insert ord; 
        }
        return ord;   
        
        
    }
    //Palak
    public static Order_Transaction__c createOrderTransaction(Boolean isInsert, String OrderId){
        Order_Transaction__c ord =new Order_Transaction__c();
        try
        {
            ord.Order__c=OrderId; 
        }
        catch(Exception e)
        {
            System.debug('Exception'+e);
            
        }
        return ord;
    }
    
    public static Invoice__c createInvoice(Boolean isInsert){
        Invoice__c inv =new Invoice__c();
        return inv;         
    }
    
    public static CartCheckoutSession createCartCheckoutSession(Boolean isInsert, string cartId){
        CartCheckoutSession c=new CartCheckoutSession();
        c.state='Order Confirmation';
        c.NextState='Payment And Billing Address';
        if(isInsert == true){
            insert c; 
        }
        return c;   
        
        
    }
    
    
    
    
    
    public static B2B_Custom_Settings__c createCustomSetting(Boolean isInsert,String accountId,String setupOwnerId){
        B2B_Custom_Settings__c objB2BCustomSetting = new B2B_Custom_Settings__c();
        objB2BCustomSetting.Default_Guest_Account__c = accountId;
        objB2BCustomSetting.name = 'test';
        objB2BCustomSetting.Batch_Current_Brand__c='honda';
        objB2BCustomSetting.SetupOwnerId = setupOwnerId;
        
        if(isInsert == true){
            insert objB2BCustomSetting; 
        }
        return objB2BCustomSetting; 
    }
    public static String createB2BUtil(){
        String kHexChars = '0123456789abcdef';
        String returnValue = '';
        Integer nextByte = 0;
        
        for (Integer i=0; i<16; i++) {
            
            if (i==4 || i==6 || i==8 || i==10) 
                returnValue += '-';
            
            nextByte = (Math.round(Math.random() * 255)-128) & 255;
            
            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            
            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }
            
            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }
        
        return returnValue;
    }
    
    // This method is internally called from createGui()
    public static String getCharAtIndex(String str, Integer index) {
        if (str == null) return null;
        if (str.length() <= 0) return str; 
        if (index == str.length()) return null;  
        return str.substring(index, index+1);
    }
    
    public static Boolean isSalesforceID(String value){
        try{
            Id salesforceId = Id.valueOf(value);
            return true;
        }catch(Exception ex){
            return false;
        }
    }
    
    public static void createVehicleData(String modelId){
        B2B_Vehicle_FunctionCode__c functionCode=new B2B_Vehicle_FunctionCode__c();
        functionCode.B2B_Code__c='42751';
        functionCode.B2B_External_Id_Function__c=modelId;
        insert functionCode;
        
    }
    //added by Yashika for Wishlist
    public static Wishlist createWishlist(Boolean isInsert, String accId, String storeId, String userId){
        Wishlist wish = new Wishlist();
        try{
            wish.Name = 'My Wishlist';
            wish.OwnerId=userId;
            wish.AccountId = accId;
            wish.WebStoreId = storeId;
            if(isInsert == true){
                insert wish;  
            }
            
        }catch(Exception e)
        {
            System.debug('Error msg wish'+e.getLineNumber());
            System.debug('Error msg wish'+e.getMessage());
            
        }
        return wish;
    }

    public static Wishlist createHondaWishlist(Boolean isInsert, String accId, String storeId, String userId){
        Wishlist wish = new Wishlist();
        try{
            wish.Name = 'My Honda Wishlist';
            wish.OwnerId=userId;
            wish.AccountId = accId;
            wish.WebStoreId = storeId;
            if(isInsert == true){
                insert wish;  
            }
            
        }catch(Exception e)
        {
            System.debug('Error msg wish'+e.getLineNumber());
            System.debug('Error msg wish'+e.getMessage());
            
        }
        return wish;
    }
    public static Wishlist createAcuraWishlist(Boolean isInsert, String accId, String storeId, String userId){
        Wishlist wish = new Wishlist();
        try{
            wish.Name = 'My Acura Wishlist';
            wish.OwnerId=userId;
            wish.AccountId = accId;
            wish.WebStoreId = storeId;
            if(isInsert == true){
                insert wish;  
            }
            
        }catch(Exception e)
        {
            System.debug('Error msg wish'+e.getLineNumber());
            System.debug('Error msg wish'+e.getMessage());
            
        }
        return wish;
    }
    
    public static WishlistItem createWishlistItem(Boolean isInsert, String accId, String storeId, String productId, String wishlistId){
        WishlistItem wish = new WishlistItem();
        try{
            wish.Name = 'Test wishlist Item';
            wish.Quantity__c=1;
            wish.Product2Id =productId;
            wish.WishlistId =wishlistId;
            
            if(isInsert == true){
                insert wish;  
            }
            
        }
        catch(Exception e)
        {
            System.debug('Error msg wish'+e.getLineNumber());
            System.debug('Error msg wish'+e.getMessage());
            
        }
        return wish;
    }
    public static Pricebook2 createPriceBook(Boolean isInsert){
        Pricebook2 p = new Pricebook2();
        p.IsActive=true;
        p.Name='Pricebook1';
        //p.IsStandard=true;
        if(isInsert == true){
            insert p;  
        }
        return p;
    }
    public static PricebookEntry createStdPricebookEntry(Boolean isInsert, String productId,String StpId, String extId){
        PricebookEntry pr = new PricebookEntry();
        //Pricebook2 p=[Select Id, Name from Pricebook2 where IsStandard=True];
        try{
            pr.UnitPrice=10;
            pr.Pricebook2Id= StpId;
            pr.Product2Id=productId;
            pr.External_Id__c=extId;
            pr.IsActive=true;
            if(isInsert == true){
                insert pr;  
            }
        }catch(Exception e)
        {
            System.debug('Error msg std'+e.getLineNumber());
            System.debug('Error msg std'+e.getMessage());
            
        }
        
        return pr;
    }
    public static PricebookEntry createPricebookEntry(Boolean isInsert, String productId, String PriceBookId, String extId ){
        PricebookEntry pr = new PricebookEntry();
        try{ 
            pr.UnitPrice=10;
            pr.Pricebook2Id=PriceBookId;
            pr.Product2Id=productId;
            pr.External_Id__c=extId;
            pr.IsActive=true;
            if(isInsert == true){
                insert pr;  
            }
        }
        catch(Exception e)
        {
            System.debug('Error msg'+e.getLineNumber());
            System.debug('Error msg'+e.getMessage());
            
        }
        return pr;
    }
    //ends
    public static My_Address_Book__c createAddressBook(Boolean isInsert)
    {
        My_Address_Book__c address = new My_Address_Book__c();
        try
        {
            //B2B_TestDataFactory.createContact(true);
            //Contact con=[select id from Contact Limit 1];
           // User u = personAccountUser(true);
            address.Person_Address_Account__c = [select contactId from User Limit 1].contactId;
            address.Name = 'New Address';
            address.Address__c = '4951 Lake Forrest Way Suite 201ac';
            address.City__c = 'Atlant';
            address.Zip__c = '30342';
            address.State__c = 'CA';
            address.isPreferred__c = true;
            address.NickName__c = 'newOne';
            //address.Address_Type__c = 'Shipping Address';
            
            if(isInsert == true)
            {
                insert address;
            }
            System.debug('Address is'+address);
            
        }
        catch(Exception e)
        {
            System.debug('Error msg'+e.getLineNumber());
            System.debug('Error msg'+e.getMessage());
        }
        return address;
    }
    
    public static My_Address_Book__c createAddressBook1(Boolean isInsert)
    {
        My_Address_Book__c address = new My_Address_Book__c();
        try
        {
            //B2B_TestDataFactory.createContact(true);
            //Contact con=[select id from Contact Limit 1];
           // User u = personAccountUser(true);
            address.Person_Address_Account__c = [select Contact.AccountId from user limit 1].Contact.AccountId;
            address.Name = 'New Address 2';
            address.Address__c = '4951 Lake Forrest Way Suite 201ac';
            address.City__c = 'Atlant';
            address.Zip__c = '30342';
            address.State__c = 'AS';
            address.NickName__c = 'newOne';
            //address.Address_Type__c = 'Shipping Address';
            
            if(isInsert == true)
            {
                insert address;
            }
            System.debug('Address is'+address);
            
        }
        catch(Exception e)
        {
            System.debug('Error msg'+e.getLineNumber());
            System.debug('Error msg'+e.getMessage());
        }
        return address;
    }
    public static user personAccountUser(Boolean isInsert){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'Honda_Owner' Limit 1];
        thisUser.UserRoleId = userRole.Id;
        update thisUser;
        
        System.runAs(thisUser){
        	StandardUserHandler handler = new StandardUserHandler();
            Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                         'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'testbook',
                                                         null, new Map<String, String>{'language' => 'en_US'});
            String pid =[Select Id from Profile Where name ='Honda Sites User'].Id ;
            BuyerGroup bg=new BuyerGroup();
            bg.Name='Test';
            insert bg;
            
            B2B_Logged_In_Buyer_group__c logged_buyer=new B2B_Logged_In_Buyer_group__c();
            logged_buyer.B2B_Is_Active__c=true;
            logged_buyer.B2B_Logged_in_Buyer_GroupId__c=bg.id;
            insert logged_buyer;
            Map<string,String> tempUser=  new Map<String, String>
            {'language' => 'en_US' ,
                'username'=>'testaskdhjkasdj@sdjkfhsjd.com' ,
                'First Name'=>'test',
                'Last Name'=>'asdjhgasjhd',
                'Email'=>'test11@gmail.com',
                'Alias'=>'asdhagsd',
                'CommunityNickname'=>'asdjasgdjhahsdhasd',
                'TimeZoneSidKey'=>'America/Los_Angeles',
                'LocaleSidKey'=>'en_US',
                'EmailEncodingKey'=>'UTF-8',
                'ProfileId'=>pid,
                'LanguageLocaleKey'=>'en_US' }; 
                    
            User u = handler.createUser(null,null,null,'501543237',tempUser,null);
            insert(u);
            return u;
        }
        return null;
    }
    //added by Yashika for 8708
    public static Product_Model__c createProductModel( Boolean isInsert){
        Product_Model__c p=new Product_Model__c();
        try{
            p.Model_Year__c='2021';
        p.Model_Name__c='CRV';
        p.Trim__c ='Continuously Variable Transmission 2WD EX';
        p.Product_Model_ID__c='RW1H5MJW';
        if(isInsert==true){
            insert p;
        }
       }
        catch(Exception e)
        {
            System.debug('Error msg'+e.getLineNumber());
            System.debug('Error msg'+e.getMessage());
        }
        return p;
    }
    
    public static Document createDocument(Boolean isInsert){
        Document document;
        
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'dreamshop';
        document.IsPublic = true;
        document.Name = 'My Document';
        document.FolderId = [select id from folder where name = 'Public'].id;
        insert document;
        if(isInsert == true){
            insert document;  
        }
        return document;
    }
    public static Carrier__c createCarrier(string carrier){
        Carrier__c carrierData=new Carrier__c();
        carrierData.name=carrier;
        carrierData.Is_Active__c=true;
        insert carrierData;
        return carrierData;
        
    }
    public static Honda_Shipping_Speed__c createshippingSpeed(String hondaSpeed){
        Honda_Shipping_Speed__c hondaSpeedData=new Honda_Shipping_Speed__c();
        hondaSpeedData.Honda_Speed_Name__c=hondaSpeed;
        hondaSpeedData.Is_Active__c=true;
        insert hondaSpeedData;
        return hondaSpeedData;
    }
    public static Carrier_Speed__c createCarrierSpeed(string carrier,string carrierId){
        Carrier_Speed__c carrierSpeedData=new Carrier_Speed__c();
        carrierSpeedData.Carrier__c=carrierId;
        if(carrier=='FEDEX'){
            carrierSpeedData.Carrier_Speed_Name__c='FEDEX_GROUND';
            carrierSpeedData.Sort_Order__c=1;
            Honda_Shipping_Speed__c hondaShippingSpeed1 = createshippingSpeed('Standard (7-10 Days)');
            carrierSpeedData.Honda_Shipping_Speed__c = hondaShippingSpeed1.id;
            insert carrierSpeedData;
            
        }else if(carrier == 'USPS'){
            carrierSpeedData.Carrier_Speed_Name__c='Priority Mail Express 1-Day';
            carrierSpeedData.Sort_Order__c=1;
            Honda_Shipping_Speed__c hondaShippingSpeed1 = createshippingSpeed('Standard (7-10 Days)');
            carrierSpeedData.Honda_Shipping_Speed__c = hondaShippingSpeed1.id;
            insert carrierSpeedData;
        }else if(carrier == 'UPS'){
            carrierSpeedData.Carrier_Speed_Name__c='12';
            carrierSpeedData.Sort_Order__c=1;
            Honda_Shipping_Speed__c hondaShippingSpeed1 = createshippingSpeed('Standard (7-10 Days)');
            carrierSpeedData.Honda_Shipping_Speed__c = hondaShippingSpeed1.id;
            insert carrierSpeedData;
        }
        
        return carrierSpeedData;
    }
    
    
}
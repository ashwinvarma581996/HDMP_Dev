/**************************************************************************************
@File Name      : B2BGuestUserController  
@Description    : TThis class is to call B2B commerce API
@Created By		: Radhey Shyam Gupta
@Business Unit  : HDM
@Created Date   : 28/04/2021
@API Version    : 54.0
@TEST Code      : B2BGuestUserControllerTest,B2BUserConnectApiTest(To commerce API)
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                    | User Story 
22/05/2022                |Soumya Sahoo      | 						     | Error handling changes- JIRA- 8617
20/03/2023                |Aditya Saini      |addProductToCartItem_Clone | Bug Fix HDMP-17802
*****************************************************************************************/ 
public without sharing class B2BGuestUserController {
    public static String currTime;
    
    @AuraEnabled(cacheable=false)
    public static String createSetupDataAndUser(String productId, integer quantity, String redirectUrl, String accountId) {
        
        //Capture the current time to be used in names/etc. for Accounts/Contacts/etc.
        currTime = String.valueOf(DateTime.now());
        currTime = currTime.replaceAll( '\\s+', '');
        currTime = currTime.replaceAll( ':', '');
        
        //Create an Account, Contact, and User 
        B2B_Custom_Settings__c b2b = [SELECT Id,Name, Default_Guest_Account__c 
                                      FROM B2B_Custom_Settings__c 
                                      LIMIT 1];
        
        Contact c = setupGuestContact(b2b.Default_Guest_Account__c);
        User u = setupGuestUser(c);
        //Create a Cart and necessary related objects for the User
        //TODO : Use a more dynamic approach vs. hardcoding the ID   
        webstore store = [select Id 
                          from webstore 
                          where name like 'Dream%' 
                          LIMIT 1];
        WebCart wc = createWebCart(b2b.Default_Guest_Account__c, store.id, u.Id, accountId);
        createCartDeliveryGroup(wc.Id);
        //Adds the Product to the User's Cart
        //Note: This is a Future method as you cannot perform a callout and DML operation in the same transaction)
        addToCart(wc.Id, b2b.Default_Guest_Account__c, productId,quantity);
        return logUserIn(u, redirectUrl);
    }
    
    @AuraEnabled(cacheable = false)
    public static String createCartSetup(String userId, String accountId) {
        webstore store = [SELECT Id 
                          FROM webstore 
                          WHERE name LIKE 'Dream%' 
                          LIMIT 1];
        B2B_Custom_Settings__c b2b = [SELECT Id,Name, Default_Guest_Account__c FROM B2B_Custom_Settings__c LIMIT 1];
        WebCart wc = createWebCart(b2b.Default_Guest_Account__c, store.id, userId, accountId);
        createCartDeliveryGroup(wc.Id);
        return wc.id;
    }
    
    @AuraEnabled(cacheable=false)
    public static String addItem(String userId, String productId, integer quantity, String redirectUrl, String wc, String price) {
        
        if(B2B_Util.isSalesforceID(productId) == false){
            Product2 product = [SELECT Id FROM Product2 WHERE StockKeepingUnit = :productId LIMIT 1];
            productId = product.Id;
        }
        B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
        addToCart1(wc, b2b.Default_Guest_Account__c, productId,quantity, price);
        user u = [select id,Username from user where id=:userId limit 1];
        return logUserIn(u, redirectUrl);
    }
    
    // Saravanan LTIM Added new Parameter Decimal coreCharge 19527 , 19528
    @AuraEnabled(cacheable=false)
    public static String addItem_Clone(String userId, String productId, integer quantity, String redirectUrl, String wc, String price, String color, String accessoryName, String productType, String accImageURL, String opCode,String brand, String modelId, String vin, Boolean vincompatibility, String productModelMarketingName, String itemPackageQuantity, String sectionId, String IllustrationId, String IllustrationImageId , Decimal coreCharge , string communityId) {
        if(B2B_Util.isSalesforceID(productId) == false){
            Product2 product = [SELECT Id FROM Product2 WHERE StockKeepingUnit = :productId LIMIT 1];
            productId = product.Id;
        }
        B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
        // Saravanan LTIM Added new Parameter Decimal coreCharge 19527 , 19528
        system.debug('Core Charge Values---'+coreCharge);
        addToCart1_Clone(wc, b2b.Default_Guest_Account__c, productId,quantity, price, color, accessoryName, productType,accImageURL, opCode, brand, modelId, vin,vincompatibility, productModelMarketingName,itemPackageQuantity, sectionId, IllustrationId, IllustrationImageId , coreCharge , communityId);
        user u = [select id,Username from user where id=:userId limit 1];
        return logUserIn(u, redirectUrl);
    }
    
    @AuraEnabled(cacheable=false)
    public static User createUser() {
        
        //Capture the current time to be used in names/etc. for Accounts/Contacts/etc.
        currTime = String.valueOf(DateTime.now());
        currTime = currTime.replaceAll( '\\s+', '');
        currTime = currTime.replaceAll( ':', '');
        //Create an Account, Contact, and User 
        B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
        Contact c = setupGuestContact(b2b.Default_Guest_Account__c);
        User u = setupGuestUser(c);
        return u;
    }
    
    @AuraEnabled(cacheable=false)
    public static cartSetup createUserAndCartSetup(String accountId) {
        //Capture the current time to be used in names/etc. for Accounts/Contacts/etc.
        currTime = String.valueOf(DateTime.now());
        currTime = currTime.replaceAll( '\\s+', '');
        currTime = currTime.replaceAll( ':', '');
        
        //Create an Account, Contact, and User 
        B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
        Contact c = setupGuestContact(b2b.Default_Guest_Account__c);
        User u = setupGuestUser(c);
        
        //Assigns the created User the B2B Permission Set
        //Note: This is a Future method as PermissionSetAssignment and User creation in the same transaction will cause a Mixed DML error)
        //createPermissionSets(u.Id);
        
        webstore store = [select id from webstore where name like 'Dream%' LIMIT 1]   ;
        WebCart wc = createWebCart(b2b.Default_Guest_Account__c, store.id, u.id, accountId);
        createCartDeliveryGroup(wc.Id);
        cartSetup ct = new cartSetup(wc.Id,u.Id);
        return ct;
    }
    
    private static Contact setupGuestContact(String accId) {
        Contact c = new Contact();
        c.FirstName = 'Guest';
        c.LastName = 'Contact' + currTime;
        c.Email = 'guest' + currTime + '@test.com';
        c.AccountId = accId;
        insert c;
        return c;
    }
    
    private static User setupGuestUser(Contact c) {
        User u = new User();
        u.ContactId = c.Id;
        u.FirstName = c.FirstName;
        u.LastName = c.LastName;
        u.Email = c.Email;
        Profile pfile = [SELECT  Name,id 
                         FROM Profile
                         WHERE name ='Honda Sites User'];
        
        //TODO : Use a more dynamic approach vs. hardcoding the ID
        u.ProfileId = pfile.id;//'00e6g000000e3WD';
        u.UserName = c.Email +'.guest';
        u.Alias = 'gst';
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.CommunityNickname = c.FirstName + ' ' + c.LastName;
        insert u;
        return u;
    }
    
    private static String logUserIn(User u, String redirectUrl) {
        String passwordString = 'test123!';
        
        System.setPassword(u.Id, passwordString);
        //TODO : Update the 3rd parameter to be the redirectUrl (this should be the URL of the PDP, which will be passed in from the LWC)
        System.PageReference loggedInPage = System.Site.login(u.Username, passwordString,redirectUrl);//'https://lab-marketplace.cs67.force.com/s');
        if(loggedInPage!=Null)
            return loggedInPage.getUrl(); 
        else 
            return null;
    }
    
    private static WebCart createWebCart(String accId, String storeId, String userId, String accountId) {
        WebCart wc = new WebCart();
        wc.AccountId = accId;  
        wc.Name = 'GuestCart' + currTime;
        wc.WebStoreId = storeId;
        wc.Status = 'Active'; 
        wc.Type = 'Cart';
        wc.OwnerId = userId;
        if(!String.isEmpty(accountId)){
            wc.DealerId__c = accountId;
        }
        insert wc;
        return wc;
    }
    
    private static void createCartDeliveryGroup(String cartId) {
        CartDeliveryGroup cdg = new CartDeliveryGroup();
        cdg.Name = 'Default Delivery';
        cdg.CartId = cartId;
        OrderDeliveryMethod orderDeliveryMethod = [select id, createddate, name, ProductId from OrderDeliveryMethod limit 1]; 
        cdg.DeliveryMethodId = orderDeliveryMethod.id; 
        insert cdg;
    }
    
    public static void addToCart1(String cartId, String accId, String productId, integer quantity, String price) {
        HttpRequest req = new HttpRequest();
        webstore store = [select id from webstore where name like 'Dream%' LIMIT 1]   ;
        //TODO : Update this callout URL (version & Store ID) to be more dynamic (the Reference Code for the PDP should already do this)
        req.setEndpoint('callout:ReferenceComponents/services/data/v52.0/commerce/webstores/'+store.Id+'/carts/' + cartId + '/cart-items?effectiveAccountId=' + accId);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;  charset=utf-8');
        
        //TODO : Add quantity as a parameter that will be passed in from the LWC
        String reqBody = '{"productId" : "' + productId + '", "quantity" :"'+quantity+'", "type" : "Product"}';
        req.setBody(reqBody);
        
        Http http = new Http();
        Long beforeAPI = B2B_Util.fetchCurrentTime();
        HttpResponse res = http.send(req);
        
        if(String.valueOf(res.getStatus()) == 'Created' && String.valueOf(res.getStatusCode()) == '201' && !String.isEmpty(price)){
            Map<String, Object> cartItemMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if(cartItemMap != null){
                if(cartItemMap.get('cartItemId') != null){
                    Decimal dealerPrice = Decimal.valueOf(price);
                    Integer cartItemQuantity = Integer.valueOf(cartItemMap.get('quantity'));
                    CartItem ci = new CartItem();
                    ci.Id = String.valueOf(cartItemMap.get('cartItemId'));
                    ci.ListPrice = dealerPrice;
                    ci.SalesPrice = dealerPrice;
                    ci.UnitAdjustmentAmount  = 0;
                    ci.UnitAdjustedPrice = dealerPrice;
                    ci.TotalListPrice = dealerPrice;
                    ci.TotalLineAmount = dealerPrice;
                    ci.AdjustmentAmount = 0;
                    ci.TotalPrice = dealerPrice;
                    ci.AdjustmentTaxAmount = 0;
                    ci.TotalListPrice = cartItemQuantity * dealerPrice;
                    ci.TotalLineAmount = cartItemQuantity * dealerPrice;
                    ci.TotalPrice = cartItemQuantity * dealerPrice;
                    ci.TotalPriceAfterAllAdjustments = ci.Quantity!= NULL ? ci.Quantity * dealerPrice:0;
                    ci.TotalPromoAdjustmentAmount = 0;
                    ci.TotalAdjustmentAmount = 0;
                    update ci;
                }
            }
        } else {
            //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
            Long afterAPI = B2B_Util.fetchCurrentTime();
            Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
            String severity;
            String errorType;
            Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
            if(errorRecords.containskey(String.valueOf(res.getStatusCode()))){
                severity= errorRecords.get(String.valueOf(res.getStatusCode())).severity__c;
                errorType=errorRecords.get(String.valueOf(res.getStatusCode())).error_Type__c;
            }
            else{
                severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
            }
           Webcart cart = B2B_IntegrationUtility.getcartdetails(cartId);
            String personAccountId;
            if(cart != null){
                personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(cart.ownerId);
            }
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', '', personAccountId, cartId, 'B2BGuestUserController', String.valueOf(res.getStatusCode()), errorType, '', 'addToCart1', true, '', cartId, '', durationTime, severity, 'Request:'+req.getBody(), 'Response:'+res.getBody());
            //HDMP-8617- End of changes
        }
    }
    
        // Saravanan LTIM Added new Parameter Decimal coreCharge 19527 , 19528

    public static void addToCart1_Clone(String cartId, String accId, String productId, integer quantity, String price, String color, String accessoryName, String productType, String accImageURL, String opCode, String brand, String modelId, String vin, Boolean vincompatibility, String productModelMarketingName, String itemPackageQuantity, String sectionId, String IllustrationId, String IllustrationImageId , Decimal coreCharge , string communityId) {
        HttpRequest req = new HttpRequest();
        Long beforeAPI = B2B_Util.fetchCurrentTime();
        webstore store = [select id from webstore where name like 'Dream%' LIMIT 1]   ;
        // Saravanan LTIM Added StockKeepingUnit for 19527,19528
        Product2 product = [SELECT Id,Name,PickupatDealer__c,StockKeepingUnit FROM Product2 WHERE Id = :productId LIMIT 1];
        if(coreCharge == null){
            //TODO : Update this callout URL (version & Store ID) to be more dynamic (the Reference Code for the PDP should already do this)
            req.setEndpoint('callout:ReferenceComponents/services/data/v52.0/commerce/webstores/'+store.Id+'/carts/' + cartId + '/cart-items?effectiveAccountId=' + accId);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;  charset=utf-8');
            
            //TODO : Add quantity as a parameter that will be passed in from the LWC
            String reqBody = '{"productId" : "' + productId + '", "quantity" :"'+quantity+'", "type" : "Product"}';
            req.setBody(reqBody);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            if(coreCharge == null){
                if(String.valueOf(res.getStatus()) == 'Created' && String.valueOf(res.getStatusCode()) == '201' && !String.isEmpty(price)){
                    Map<String, Object> cartItemMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    if(cartItemMap != null){
                        if(coreCharge  == null  ){
                            if(cartItemMap.get('cartItemId') != null){
                            Decimal dealerPrice = Decimal.valueOf(price);
                            Integer cartItemQuantity = Integer.valueOf(cartItemMap.get('quantity'));
                            
                            CartItem ci = new CartItem();
                            ci.Id = String.valueOf(cartItemMap.get('cartItemId'));
                            ci.ListPrice = dealerPrice;
                            ci.SalesPrice = dealerPrice;
                            ci.UnitAdjustmentAmount  = 0;
                            ci.UnitAdjustedPrice = dealerPrice;
                            ci.TotalListPrice = dealerPrice;
                            ci.TotalLineAmount = dealerPrice;
                            ci.AdjustmentAmount = 0;
                            ci.TotalPrice = dealerPrice;
                            ci.Color__c = color;
                            ci.Name = accessoryName;
                            ci.AdjustmentTaxAmount = 0;
                            ci.TotalListPrice = cartItemQuantity * dealerPrice;
                            ci.TotalLineAmount = cartItemQuantity * dealerPrice;
                            ci.TotalPrice = cartItemQuantity * dealerPrice;
                            ci.TotalPriceAfterAllAdjustments = ci.Quantity!= NULL ? ci.Quantity * dealerPrice:0;
                            ci.TotalPromoAdjustmentAmount = 0;
                            ci.TotalAdjustmentAmount = 0;
                            ci.Product_Type__c = productType; //Added by shalini soni HDMP-5428 R2 Story
                            ci.Accessorie_Image_URL__c =accImageURL; //added by Yashika for 7380
                            ci.op_code__c =opCode; //added by Yashika for 7911
                            ci.Product_Type__c = productType; // Added by Bhawesh for bug 7434
                            ci.Product_Subdivision__c =brand; //added by shalini 10-3-2022
                            ci.Product_Model__c = modelId;// added by Yashika for 8708
                            ci.Product_Identifier__c = vin;// added by Yashika for 
                            ci.Section_Id__c = sectionId;//Added by Faraz for 10203
                            ci.Illustration_Id__c = IllustrationId;//Added by Faraz for 10203
                            ci.Illustration_Group_Image_Id__c = IllustrationImageId;//Added by Faraz for 10203
                            if(vin=='undefined' || vin==null){ //for 12421
                                ci.Product_Identifier__c='';
                            }
                        
                            if(productType == 'Accessory'){
                                ci.Item_Package_Quantity__c = Decimal.valueOf(itemPackageQuantity);
                            }
                            //added by Yashika for 9674
                            if(productType!='Part'){
                                ci.Is_VIN_Fitment__c='Yes';
                            }
                            else if(vincompatibility==true){
                                ci.Is_VIN_Fitment__c='Yes';
                            }
                            else if(vin!='' && vin!='undefined' && vin != null){
                                ci.Is_VIN_Fitment__c='Yes';
                            }
                            else{
                                ci.Is_VIN_Fitment__c='Unknown';
                            }
                            if(product.PickupatDealer__c==true){
                                ci.Shipping_Option__c ='Pickup at Dealer only';
                            }
                            else{
                                ci.Shipping_Option__c ='Pickup at Dealer, Shippable';
                            } 
                            ci.Product_Subdivision__c=brand;
                            if(brand=='Honda'){
                                ci.Product_Division__c='A';
                            }
                            else{
                                ci.Product_Division__c='B';
                            }//ends: 9674
                            ci.Product_Model_Marketing_Name__c =productModelMarketingName; //for 10179
                            ci.AK_Cart_Item__c = cartId + '' + String.valueOf(cartItemMap.get('productId'));
                            update ci; 
                            WebCart wc = new WebCart();
                            wc.Id = cartId;
                            wc.Product_Subdivision__c=brand;
                            if(brand=='Honda'){
                                wc.Product_Division__c='A';
                            }
                            else{
                                wc.Product_Division__c='B';
                            }
                            update wc;
                        }else{
                            system.debug('Clone values---1');
                            addProductToCartItem_Clone(accId,product.StockKeepingUnit,communityId,Decimal.valueof(price),quantity,color,accessoryName,productType,accImageURL,'opCode',brand,modelId,vin,vincompatibility,productModelMarketingName,'itemPackageQuantity',sectionId, IllustrationId, IllustrationImageId, coreCharge,cartId);
                            //addProductToCartItem_Clone(String accountId, String sku, String communityId, Decimal price, Integer quantity, String color, String accessoryName, String productType, String accImageURL, String opCode,String brand, String modelId, String vin, Boolean vincompatibility, String productModelMarketingName, String itemPackageQuantity, String sectionId, String IllustrationId, String IllustrationImageId, Decimal coreCharge)
                        }
                    }
                    }else{
                        system.debug('Clone values---2');
                        addProductToCartItem_Clone(accId,product.StockKeepingUnit,communityId,Decimal.valueof(price),quantity,color,accessoryName,productType,accImageURL,'opCode',brand,modelId,vin,vincompatibility,productModelMarketingName,'itemPackageQuantity',sectionId, IllustrationId, IllustrationImageId, coreCharge,cartId);

                    }
                } else {
                    //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                    Long afterAPI = B2B_Util.fetchCurrentTime();
                    Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                    String severity;
                    String errorType;
                    Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                    if(errorRecords.containskey(String.valueOf(res.getStatusCode()))){
                        severity= errorRecords.get(String.valueOf(res.getStatusCode())).severity__c;
                        errorType=errorRecords.get(String.valueOf(res.getStatusCode())).error_Type__c;
                    }
                    else{
                        severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                        errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                    }   
                    Webcart cart = B2B_IntegrationUtility.getcartdetails(cartId);
                    String personAccountId;
                    if(cart != null){
                        personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(cart.ownerId);
                    }
                    Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', '', personAccountId, cartId, 'B2BGuestUserController', String.valueOf(res.getStatusCode()), errorType, '', 'addToCart1_Clone', true, '', cartId, '', durationTime, severity, 'Request:'+req.getBody(), 'Response:'+res.getBody());
                    //HDMP-8617- End of changes
                }
            }else{
                
            }
        }else{
            addProductToCartItem_Clone(accId,product.StockKeepingUnit,communityId,Decimal.valueof(price),quantity,color,accessoryName,productType,accImageURL,'opCode',brand,modelId,vin,vincompatibility,productModelMarketingName,'itemPackageQuantity',sectionId, IllustrationId, IllustrationImageId, coreCharge , cartId);

        }
    }
    
    //Note: This method uses the Connect REST API vs. Apex as it will run under the User Authenticated with the Named Credential
    @future(callout=true)
    private static void addToCart(String cartId, String accId, String productId, integer quantity) {
        HttpRequest req = new HttpRequest();
        webstore store = [select id from webstore where name like 'Dream%' LIMIT 1]   ;
        
        //TODO : Update this callout URL (version & Store ID) to be more dynamic (the Reference Code for the PDP should already do this)
        req.setEndpoint('callout:ReferenceComponents/services/data/v52.0/commerce/webstores/'+store.Id+'/carts/' + cartId + '/cart-items?effectiveAccountId=' + accId);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;  charset=utf-8');
        
        //TODO : Add quantity as a parameter that will be passed in from the LWC
        String reqBody = '{"productId" : "' + productId + '", "quantity" :"'+quantity+'", "type" : "Product"}';
        req.setBody(reqBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
    }
    
    /*@future
    private static void createPermissionSets(String userId) {
        try {
            List<PermissionSetAssignment> permissionsToCreate = new List<PermissionSetAssignment>();
            
            //Placed in a for loop in the event that there are multiple Permission Sets that need to be assigned  
            for(PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name ='Dreamshop_Sites_User']) {
                permissionsToCreate.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id));
            }
            insert permissionsToCreate;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }*/
    
    @AuraEnabled(cacheable=false)
    public static boolean createPermissionSetsSynchronous(String userId) {
        try {
            // updated by Pradeep for Login/Registration CIAM user access.
            List<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name='Dreamshop_Sites_User'];
            List<PermissionSetAssignment> permissionsToCreate = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN: psList AND AssigneeId=:userId];
            if(permissionsToCreate == null||permissionsToCreate.isEmpty() )
            {
                new List<PermissionSetAssignment>();
                //Placed in a for loop in the event that there are multiple Permission Sets that need to be assigned  
                for(PermissionSet ps : psList){
                    permissionsToCreate.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id));
                }
                insert permissionsToCreate;
            }
            return true;
        } catch(Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static String checkIfUserIsLoggedIn(){
        Profile pfile = [Select Name from Profile where Id =: userinfo.getProfileid()];
        String pname = pfile.name;
        User u = [SELECT LastLoginDate FROM User WHERE Id =:UserInfo.getUserId()];
        DateTime lastlogin = u.LastLoginDate;
        
        //by Yashika: have removed (&& lastlogin !=null) this condition from if to add product to logged in user cart only and not create a separate guest user while doing add to cart from logged in exp for first time
        if(pname=='Honda Sites User Guest' || pname == 'System Administrator' || pname=='Honda Sites User')  { 
            return u.Id;
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static Boolean updateDealerOnCart(String selectedDealerId,String communityId)
    {
        B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
        String  effectiveAccountId = b2b.Default_Guest_Account__c;
        //Below lines of code for Person Account changes
        string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
        if(String.isNotBlank(personAccountId))
            effectiveAccountId =personAccountId;
        //End Soumya changes
        ConnectApi.CartSummary CurrentCart = B2BGetInfo.getCartSummary(communityId, effectiveAccountId) ;
        if(CurrentCart.cartId!=null){
            Webcart wc=[Select Id,DealerId__c from WebCart where Id=:CurrentCart.cartId];
            wc.DealerId__c=selectedDealerId;
            update wc;
            return true;
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static CartItem addProductToCartItem(String accountId, String sku, String communityId, Decimal price, Integer quantity){
        try {
            Product2 product = [SELECT Id,Name FROM Product2 WHERE StockKeepingUnit = :sku LIMIT 1];
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);system.debug('webstoreId:::'+webstoreId);
            B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];system.debug('Default_Guest_Account__c:::'+b2b.Default_Guest_Account__c);
            //Below lines of code for Person Account changes
            string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
            if(String.isNotBlank(personAccountId))
                b2b.Default_Guest_Account__c=personAccountId;
            //End Soumya changes
            ConnectApi.CartSummary currentCart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, b2b.Default_Guest_Account__c, 'active');
            CartDeliveryGroup cartDelGroup = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :currentCart.cartId LIMIT 1];
            //LTIM Saravanan has updated for 7813 and 7815
            List<CartItem> cartItems = [SELECT Id, Product2Id, Quantity FROM CartItem WHERE Product2Id =: product.Id AND cartId = :currentCart.cartId and Product_Type__c != 'Core Charge'];
            
            CartItem ci = new CartItem();
            ci.Name = product.Name;
            ci.Type = 'Product';
            ci.CartDeliveryGroupId = cartDelGroup.Id;
            ci.Sku = sku;
            ci.cartId = currentCart.cartId;
            ci.Product2Id = product.Id;
            ci.Quantity = quantity;
            ci.ListPrice = price;
            ci.SalesPrice = price;
            ci.UnitAdjustmentAmount  = 0;
            ci.UnitAdjustedPrice = price;
            ci.TotalListPrice = quantity * price;
            ci.TotalLineAmount = quantity * price;
            ci.AdjustmentAmount = 0;
            ci.TotalPrice = quantity * price;
            ci.AdjustmentTaxAmount = 0;
            ci.TotalPriceAfterAllAdjustments = price;
            ci.TotalPromoAdjustmentAmount = 0;
            ci.TotalAdjustmentAmount = 0;
            system.debug('price'+price);
            for(CartItem cItem : cartItems){ 
                if(cItem.Product2Id == product.Id){
                    ci.Quantity = cItem.Quantity + quantity;
                    ci.TotalListPrice = ci.Quantity * price;
                    ci.TotalLineAmount = ci.Quantity * price;
                    ci.TotalPrice = ci.Quantity * price;
                    ci.TotalPriceAfterAllAdjustments = ci.Quantity * price;
                }
            }
            WebCart wc = new WebCart();
            wc.Id = currentCart.cartId;
            wc.DealerId__c = accountId;
            update wc;
            insert ci;
            delete cartItems;
            return ci;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static CartItem addProductToCartItem_Clone(String accountId, String sku, String communityId, Decimal price, Integer quantity, String color, String accessoryName, String productType, String accImageURL, String opCode,String brand, String modelId, String vin, Boolean vincompatibility, String productModelMarketingName, String itemPackageQuantity, String sectionId, String IllustrationId, String IllustrationImageId, Decimal coreCharge , string cartId){
        try {
            List<CartItem> cartItemsToupsert= new List<CartItem>();//Aditya Bug Fix HDMP-17802
            Product2 product = [SELECT Id,Name,PickupatDealer__c FROM Product2 WHERE StockKeepingUnit = :sku LIMIT 1];
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);system.debug('webstoreId:::'+webstoreId);
            B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];system.debug('Default_Guest_Account__c:::'+b2b.Default_Guest_Account__c);
            //Below lines of code for Person Account changes
            string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
            if(String.isNotBlank(personAccountId)){
                b2b.Default_Guest_Account__c=personAccountId;
            }   
            //End Soumya changes
            ConnectApi.CartSummary currentCart ;
            string cartIdVar = ''; // Saravanan LTIM 19527 , 19528
            system.debug('cartId---'+cartId);
            if(cartId == null){
                 currentCart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, b2b.Default_Guest_Account__c, 'active');
                 cartIdVar = currentCart.cartId; // Saravanan LTIM 19527 , 19528
            }else{
                cartIdVar = cartId; // Saravanan LTIM 19527 , 19528

            }

            CartDeliveryGroup cartDelGroup = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartIdVar LIMIT 1]; // Saravanan LTIM 19527 , 19528

            system.debug('currentCart---'+currentCart);
            
            List<CartItem> cartItems = [SELECT Id,op_code__c, Product2Id, Quantity FROM CartItem WHERE Product2Id =: product.Id AND cartId = :cartIdVar]; // Saravanan LTIM 19527 , 19528
            CartItem ci = new CartItem();
            //Added by Bhawesh on 22-01-2022 for 6240
            
            /* Start Aditya Bug Fix HDMP-18563 */
            if(coreCharge!=null){
                ci.Name = accessoryName.unescapeHtml4()+' '+ System.Label.B2B_Reman_Part_Identification_Label;
                addOrUpdateRemanCorecharge(sku, communityId, price, quantity, accessoryName, productType, brand, modelId, vin, productModelMarketingName, itemPackageQuantity, coreCharge , cartIdVar); // Saravanan LTIM 19527 , 19528
            }else{
                ci.Name = accessoryName.unescapeHtml4();
            }
            /* End Aditya Bug Fix HDMP-18563 */
            ci.Color__c = color;
            ci.Type = 'Product';
            ci.CartDeliveryGroupId = cartDelGroup.Id;
            ci.Sku = sku;
            ci.cartId = cartIdVar; //currentCart.cartId;
            ci.Product2Id = product.Id;
            ci.Quantity = quantity;
            ci.ListPrice = price;
            ci.SalesPrice = price;
            ci.UnitAdjustmentAmount  = 0;
            ci.UnitAdjustedPrice = price;
            ci.TotalListPrice = quantity * price;
            ci.TotalLineAmount = quantity * price;
            ci.AdjustmentAmount = 0;
            ci.TotalPrice = quantity * price;
            ci.AdjustmentTaxAmount = 0;
            ci.TotalPromoAdjustmentAmount = 0;
            ci.Product_Type__c = productType; //Added by shalini soni HDMP-5428 R2 Story
            ci.Accessorie_Image_URL__c =accImageURL;//added by Yashika for 7380
            ci.op_code__c =opCode; //added by Yashika for 7911
            ci.Product_Subdivision__c =brand; //added by shalini 10-3-2022
            ci.Product_Model__c =modelId;//added by Yashika for 8708
            ci.Product_Identifier__c =vin; //added by Yashika for 8708
            ci.Section_Id__c = sectionId;//Added by Faraz for 10203
            ci.Illustration_Id__c = IllustrationId;//Added by Faraz for 10203
            ci.Illustration_Group_Image_Id__c = IllustrationImageId;//Added by Faraz for 10203
            system.debug('---vin----' + vin);
            if(vin=='undefined' || vin == null){ //for 12421
                ci.Product_Identifier__c='';
            }
           
            if(productType == 'Accessory'){
                ci.Item_Package_Quantity__c = Decimal.valueOf(itemPackageQuantity);
            }
            //added by Yashika for 9674
            if(productType!='Part'){
                ci.Is_VIN_Fitment__c='Yes';
            }
            else if(vincompatibility==true){
                ci.Is_VIN_Fitment__c='Yes';
            }
            else if( vin!='' && vin!='undefined' && vin != null){
                ci.Is_VIN_Fitment__c='Yes';
            }
            else{
                ci.Is_VIN_Fitment__c='Unknown';
            }
            if(product.PickupatDealer__c==true){
                ci.Shipping_Option__c ='Pickup at Dealer only';
            }
            else{
                ci.Shipping_Option__c ='Pickup at Dealer, Shippable';
            } 
            ci.Product_Subdivision__c=brand;
            if(brand=='Honda'){
                ci.Product_Division__c='A';
            }
            else{
                ci.Product_Division__c='B';
            }//ends: 9674
            ci.Product_Model_Marketing_Name__c =productModelMarketingName; //for 10179
            ci.TotalPriceAfterAllAdjustments = price;
            ci.AK_Cart_Item__c = cartIdVar  + '' + product.Id; // currentCart.cartId + '' + product.Id; // Saravanan LTIM 19527 , 19528
            for(CartItem cItem : cartItems){
                if((productType =='Accessory' && cItem.op_code__c == opCode && cItem.Product2Id == product.Id) || 
                   (productType !='Accessory' && cItem.Product2Id == product.Id)){
                       ci.Id = cItem.Id;
                       ci.Quantity = cItem.Quantity + quantity;
                       ci.TotalListPrice = ci.Quantity * price;
                       ci.TotalLineAmount = ci.Quantity * price;
                       ci.TotalPrice = ci.Quantity * price;
                       ci.TotalPriceAfterAllAdjustments = ci.Quantity * price;
                   }
            }  
            
            cartItemsToupsert.add(ci); // Aditya Bug Fix HDMP-17802   
            WebCart wc = new WebCart();
            wc.Id = cartIdVar;//currentCart.cartId; // Saravanan LTIM 19527 , 19528
            wc.DealerId__c = accountId;
            wc.Product_Subdivision__c=brand;
            if(brand=='Honda'){
                wc.Product_Division__c='A';
            }
            else{
                wc.Product_Division__c='B';
            }
            update wc;
            /* Start Aditya Bug Fix HDMP-17802 */
            if(!cartItemsToupsert.isEmpty()){
                upsert cartItemsToupsert;
            }
            /* End Aditya Bug Fix HDMP-17802 */
            return cartItemsToupsert[0]; //Aditya Bug Fix HDMP-17802
        } catch (Exception ex) {
            system.debug('error message' +ex.getLineNumber() + ':' + ex.getMessage());
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
            
        }
    }
  /* Start Aditya Bug Fix HDMP-18563 */
  // Saravanan LTIM 19527 , 19528
public static void addOrUpdateRemanCorecharge(String sku, String communityId, Decimal price, Integer quantity, String accessoryName, String productType,String brand, String modelId, String vin, String productModelMarketingName, String itemPackageQuantity, Decimal coreCharge , string cartIdVar) {
	try{
        Product2 product = [SELECT Id,Name,PickupatDealer__c FROM Product2 WHERE StockKeepingUnit = :sku LIMIT 1];
        /* Start Added by Aditya for HDMP-19463 */
        if(product.PickupatDealer__c!=true){
            product.PickupatDealer__c = true;
            update product;
        }
        /* End Added by Aditya for HDMP-19463 */
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);system.debug('webstoreId:::'+webstoreId);
        B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];system.debug('Default_Guest_Account__c:::'+b2b.Default_Guest_Account__c);
        
        string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                if(String.isNotBlank(personAccountId))
                    b2b.Default_Guest_Account__c=personAccountId;
        
        // Saravanan LTIM 19527 , 19528
        if(cartIdVar == null){             
            ConnectApi.CartSummary currentCart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, b2b.Default_Guest_Account__c, 'active');
            cartIdVar = currentCart.cartId; // Saravanan LTIM 19527 , 19528
        }
        CartDeliveryGroup cartDelGroup = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartIdVar LIMIT 1];// Saravanan LTIM 19527 , 19528
        
        List<CartItem> cartItems = [SELECT Id, Product2Id,Product_Type__c, Quantity FROM CartItem WHERE Product2Id =: product.Id AND cartId = :cartIdVar and Product_Type__c = 'Core Charge']; // Saravanan LTIM 19527 , 19528

        if (!cartItems.isEmpty()) {
            for(CartItem cItem : cartItems){
                cItem.ListPrice = coreCharge;
                cItem.SalesPrice = coreCharge;
                cItem.Quantity += quantity;
                cItem.TotalLineAmount = cItem.Quantity * coreCharge;
                cItem.TotalPrice = cItem.Quantity * coreCharge;
                cItem.TotalListPrice = cItem.Quantity * coreCharge;
                cItem.Name = accessoryName.unescapeHtml4()+' '+ System.Label.B2B_Reman_Part_Core_Charge_Identification_Label;
                cItem.AK_Cart_Item__c = cartIdVar + '~' + product.Id+ '~' + cItem.Product_Type__c ;//currentCart.cartId + '~' + product.Id+ '~' + cItem.Product_Type__c; // Saravanan LTIM 19527 , 19528
                cItem.Shipping_Option__c ='Pickup at Dealer only';
            }
            update cartItems;

        } else {
            List<CartItem> remanCartItemsToinsert= new List<CartItem>();
            /* -------------------------------------- inserting Reman Core Charge -------------------------------------- */
            CartItem core_ci = new CartItem();
            core_ci.Name = accessoryName.unescapeHtml4()+' '+ System.Label.B2B_Reman_Part_Core_Charge_Identification_Label;
            core_ci.Type = 'Product';
            core_ci.CartDeliveryGroupId = cartDelGroup.Id;
            core_ci.Sku = sku;
            core_ci.cartId = cartIdVar ;//currentCart.cartId; // Saravanan LTIM 19527 , 19528
            core_ci.Product2Id = product.Id;
            core_ci.Quantity = quantity;
            core_ci.ListPrice = coreCharge;
            core_ci.SalesPrice = coreCharge;
            core_ci.UnitAdjustedPrice = coreCharge;
            core_ci.TotalLineAmount = quantity * coreCharge;
            core_ci.TotalPrice = quantity * coreCharge;
            core_ci.Product_Type__c = 'Core Charge';
            core_ci.Product_Subdivision__c =brand;
            core_ci.Product_Model__c =modelId;
            core_ci.Product_Identifier__c =vin;
            core_ci.Shipping_Option__c ='Pickup at Dealer only';
            core_ci.Product_Model_Marketing_Name__c =productModelMarketingName;
            core_ci.AK_Cart_Item__c = cartIdVar + '~' + product.Id+ '~Core Charge';// currentCart.cartId + '~' + product.Id+ '~Core Charge'; // Saravanan LTIM 19527 , 19528
            core_ci.Is_VIN_Fitment__c='Unknown';
            core_ci.Item_Package_Quantity__c =1;
            remanCartItemsToinsert.add(core_ci);
            if(!remanCartItemsToinsert.isEmpty()){
                insert remanCartItemsToinsert;
            }	
        
        }
    }catch (Exception ex) {
        system.debug('error message' +ex.getLineNumber() + ':' + ex.getMessage());
        throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
            
    }
}
    /* End Aditya Bug Fix HDMP-18563 */

    @AuraEnabled
    public static List<CartItem> getActiveCartItems(String communityId){
        try {
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
            //Below lines of code for Person Account changes
            string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
            if(String.isNotBlank(personAccountId))
                b2b.Default_Guest_Account__c=personAccountId;
            // End - Soumya Changes
            ConnectApi.CartSummary currentCart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, b2b.Default_Guest_Account__c, 'active');
            List<CartItem> cartItems = [SELECT Id, op_code__c, Product2Id, Product2.StockKeepingUnit, Quantity FROM CartItem WHERE cartId = :currentCart.cartId];
            return cartItems;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<CartItem> updateCartItems(AddToCart adToCart){
        try {
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(adToCart.communityId);
            B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
            //Below lines of code for Person Account changes
            string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
            if(String.isNotBlank(personAccountId))
                b2b.Default_Guest_Account__c=personAccountId;
            //End Soumya changes
            ConnectApi.CartSummary currentCart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, b2b.Default_Guest_Account__c, 'active');
            // Saravanan LTIM Added a condition to update the core charge for 7813,7817
            List<CartItem> cartItems = [SELECT Id, Product2Id, Product2.StockKeepingUnit, Quantity FROM CartItem WHERE cartId = :currentCart.cartId and Product_Type__c != 'Core Charge'];
            List<CartItem> cartItemsToUpdate = new List<CartItem>();
            for(CartItem cItem : cartItems){
                for(Product product : adToCart.products){
                    if(cItem.Product2.StockKeepingUnit == product.PartNumber){
                        Decimal price = Decimal.valueOf(product.DealerPrice);
                        
                        
                        CartItem ci = new CartItem();
                        ci.Id = cItem.Id;
                        ci.ListPrice = price;
                        ci.SalesPrice = price;
                        ci.UnitAdjustmentAmount  = 0;
                        ci.UnitAdjustedPrice = price;
                        ci.TotalListPrice = price;
                        ci.TotalLineAmount = price;
                        ci.AdjustmentAmount = 0;
                        ci.TotalPrice = price;
                        ci.AdjustmentTaxAmount = 0;
                        ci.TotalAdjustmentAmount = 0;
                        ci.TotalPriceAfterAllAdjustments = price;
                        ci.TotalListPrice = cItem.Quantity * price;
                        ci.TotalLineAmount = cItem.Quantity * price;
                        ci.TotalPrice = cItem.Quantity * price;
                        cartItemsToUpdate.add(ci);
                    }
                }
            }
            WebCart wc = new WebCart();
            wc.Id = currentCart.cartId;
            wc.DealerId__c = adToCart.accountId;
            update wc;
            if(!cartItemsToUpdate.isEmpty()){
                update cartItemsToUpdate;
            }
            return cartItemsToUpdate;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static CartItem updateCartItem(String cartItemId, String price, Integer quantity){
        try {
            /* Start Aditya Bug Fix HDMP-17802 */
            List<CartItem> cartItemsToUpdateqty= new List<CartItem>();
            CartItem ciRupdate =  [Select id,Product2Id,cartId,Product_Type__c from CartItem where id=:cartItemId ];
            CartItem[] ciCupdate = [Select id,Quantity,ListPrice,Product2Id,cartId,Product_Type__c from CartItem where cartId=:ciRupdate.cartId and Product2Id=:ciRupdate.Product2Id and Product_Type__c ='Core Charge' ];
            /* End Aditya Bug Fix HDMP-17802 */
            Decimal cartItemPrice = Decimal.valueOf(price);
            CartItem ci = new CartItem();
            ci.Id = cartItemId;
            ci.Quantity = quantity;
            ci.ListPrice = cartItemPrice;
            ci.SalesPrice = cartItemPrice;
            ci.UnitAdjustmentAmount  = 0;
            ci.UnitAdjustedPrice = cartItemPrice;
            ci.TotalListPrice = cartItemPrice;
            ci.TotalLineAmount = cartItemPrice;
            ci.AdjustmentAmount = 0;
            ci.TotalPrice = cartItemPrice;
            ci.AdjustmentTaxAmount = 0;
            ci.TotalAdjustmentAmount = 0;
            ci.TotalListPrice = ci.Quantity * cartItemPrice;
            ci.TotalLineAmount = ci.Quantity * cartItemPrice;
            ci.TotalPrice = ci.Quantity * cartItemPrice;
            cartItemsToUpdateqty.add(ci);
            /* Start Aditya Bug Fix HDMP-17802 */
            if (ciCupdate.size() > 0){
                ciCupdate[0].Quantity = quantity;
                ciCupdate[0].TotalListPrice = quantity * ciCupdate[0].ListPrice;
                ciCupdate[0].TotalLineAmount = quantity * ciCupdate[0].ListPrice;
                ciCupdate[0].TotalPrice = quantity * ciCupdate[0].ListPrice;
                cartItemsToUpdateqty.add(ciCupdate[0]);
            }   
            if(!cartItemsToUpdateqty.isEmpty()){
                update cartItemsToUpdateqty;
            }
            /* End Aditya Bug Fix HDMP-17802 */
            return cartItemsToUpdateqty[0]; // Aditya Bug Fix HDMP-17802
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static cartSetup checkIfUserHasCartAndSetup(String communityId, String userId) {
        try {
            cartSetup ct;
            String cartId = null;
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
            try{
                //Below lines of code for Person Account changes
                string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(userId);
                if(String.isNotBlank(personAccountId))
                    b2b.Default_Guest_Account__c=personAccountId;
                // End - Soumya Changes
                ConnectApi.CartSummary currentCart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, b2b.Default_Guest_Account__c, 'active');  
                cartId = currentCart.cartId;
            }Catch(Exception ex){
                if(ex.getMessage() == 'Invalid webstoreId or no active cart exists'){
                    cartId = null;
                }
            }
            if(cartId != null){
                updateCartDeliveryGroup(cartId); 
                ct = new cartSetup(cartId, userId);
            }
            return ct;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }
    
    private static void updateCartDeliveryGroup(String cartId) {
        CartDeliveryGroup cdg = [SELECT Id, DeliveryMethodId FROM CartDeliveryGroup WHERE CartId = :cartId LIMIT 1];
        OrderDeliveryMethod orderDeliveryMethod = [select id, createddate, name, ProductId from OrderDeliveryMethod limit 1]; 
        cdg.DeliveryMethodId = orderDeliveryMethod.id; 
        update cdg;
    }
    
    @AuraEnabled
    public static Product2 getProduct(String productId){
        try {
            Product2 product1 = [SELECT Id,Name FROM Product2 WHERE StockKeepingUnit  = :productId LIMIT 1];
            productId = product1.Id;
            Product2 product = [SELECT Id,Name FROM Product2 WHERE Id = :productId LIMIT 1];
            return product;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Product2 getCurrentProduct(String productId){
        try {
            if(B2B_Util.isSalesforceID(productId) == false){
                Product2 product = [SELECT Id,Name FROM Product2 WHERE StockKeepingUnit  = :productId LIMIT 1];
                productId = product.Id;
            }
            Product2 product = [SELECT Id,Name FROM Product2 WHERE Id = :productId LIMIT 1];
            return product;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }
    //Added by Deepak Mali 28 Oct 2021 
    //Returns a list of all US State Codes
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getStateCodes() {
        List<Map<String, String>> stateCodes = new List<Map<String, String>>();
        List<State_List__c> stateList = State_List__c.getall().values();
        for(State_List__c objState : stateList){
            stateCodes.add(new Map<String, String>{'label' => objState.Name, 'value' => objState.Name});
        }
        return stateCodes;
    }
    
    @AuraEnabled
    public static Account getAccountByDealerNo(String dealerNo, Boolean isguest, String brand){
        try {
            Account acc = [SELECT Id, Name FROM Account WHERE PoIId__c  = :dealerNo LIMIT 1];
            if(!isguest)
                B2B_ShoppingSelectionController.saveLastDealer(new Shopping_Selection__c(Product_Subdivision__c = brand, Last_Dealer__c = acc.Id));
            return acc;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    } 
    @AuraEnabled
    public static Webcart getcartTotalQuantity(Id cartId){
        try {
            Webcart wc = [Select Id,TotalProductCount,(Select Id,Quantity FROM CartItems) from WebCart where Id=: cartId];
            return wc;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    } 
    //added by Yashika for 8708: starts
    @AuraEnabled(cacheable=true)
    public static Product_Model__c getModelId(String year, String model, String trim){
        try {
            Product_Model__c pm = [Select Id,Product_Model_ID__c from Product_Model__c where Model_Year__c=:year and Model_Name__c=: model and Trim__c=: trim];
            return pm;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    } 
    @AuraEnabled(cacheable=true)
    public static Honda_Product__c getModelIdByVIN(String vin){
        try {
            Honda_Product__c hp = [Select Id,Product_Models__c,Product_Models__r.Product_Model_ID__c  from Honda_Product__c where Product_Identifier__c=:vin];//for adobe bug-11:added (Product_Models__r.Product_Model_ID__c ) field
            return hp;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    } 
    @AuraEnabled
    public static  List<CartItem> updateCartItemVin(String sku, String vin, String cart){
        try {
            // LTIM Saravanan updated for 7813
            CartItem ci = [Select Id,Product_Identifier__c from CartItem where CartId=:cart and Product2.StockKeepingUnit=:sku and Product_Type__c != 'Core Charge'];
            List<Honda_Product__c> hp = new List<Honda_Product__c>();
            hp=[Select Id,Product_Models__c from Honda_Product__c where Product_Identifier__c=:vin];
            ci.Product_Identifier__c = vin;
            if(hp.size()!=0){
            ci.Product_Model__c = hp[0].Product_Models__c;
            }
            ci.Is_VIN_Fitment__c='Yes';
            update ci;
            List<CartItem> lstCartItem = new List<CartItem>();
            lstCartItem = CartItemsCtrl.getCartItemList2(cart);
            return lstCartItem;
        } catch (Exception ex) {
            System.debug('Error '+ex.getMessage()+ ' At '+ex.getLineNumber());

            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    } 
    //ends: 8708
    @AuraEnabled
    public static string getVisualforceOrigin() {
        string visualOrigin = '';
        string baseUrl = URL.getOrgDomainUrl().toExternalForm(); 
        // Expected Format = https://domain.my.salesforce.com
        // Expected Format for DE, Sandbox & Production ORgs = domain--c.visualforce.com
        visualOrigin = baseUrl.split('.my.')[0] + '--c.' + 'visualforce.com';
        return visualOrigin;
    }
    
    public class cartSetup {
        @AuraEnabled public String cartId {get; set;}
        @AuraEnabled public String userId {get; set;}
        
        public cartSetup(String cart, String user) {
            cartId = cart;
            userId = user;
        }
    }
    
    public class AddToCart {
        @AuraEnabled public String accountId {get; set;}
        @AuraEnabled public String communityId {get; set;}
        @AuraEnabled public List<Product> products {get; set;}
    }
    
    public class Product {
        @AuraEnabled public String PartNumber {get; set;}
        @AuraEnabled public String DealerPrice {get; set;}
    }
    @AuraEnabled(cacheable=true)
    public static Product2 getProductSKUById(String prodId){
        Product2 prod = [SELECT Id, StockKeepingUnit, Name FROM Product2 where id = :prodId];
		return prod;
    } 
}
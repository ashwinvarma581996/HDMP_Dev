/**************************************************************************************
@File Name      : B2B_GetInfoTest  
@Description    : This class is to to call OOTB API of B2B Commerce
@Created By		: Radhey Shyam Gupta
@Business Unit  : HDM
@Created Date   : 28/04/2021
@API Version    : 54.0
@TEST Code      : B2BGetInfoTest ,B2B_GetInfoTestClass apex classes covers test codefor this class
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                    | User Story 
24/05/2022                |Soumya Sahoo      | 						     | Error handling changes- JIRA- 8617
*****************************************************************************************/ 
public without sharing class B2BGetInfo {
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductDetail getProduct(
        String communityId,
        String productId,
        String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        String effaccid = effectiveAccountId;
        
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
        return ConnectApi.CommerceCatalog.getProduct(
            webstoreId,
            productId,
            effectiveAccountID,
            null,
            false,
            null,
            false,
            true,
            false
        );
    }
    
    
    
    
    @AuraEnabled(cacheable=true)
    public static Boolean checkProductIsInStock(String productId) {
        /*
         * The following is an example of calling an external API.
         * The example API provided is extremely simple: It takes in a product id
         * and returns a true or false value for inStock based on whether the 15th char is odd or even.
         * To access this endpoint on your org, go to Remote Site Settings in Setup as an admin user
         * click "New Remote Site" and provide "https://inventorymanagerdemo.herokuapp.com" for the "Remote Site URL" field 
		 */
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String endpoint =
            'https://inventorymanagerdemo.herokuapp.com/api/inventory/' + productId;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        Long beforeAPI =B2B_Util.fetchCurrentTime();
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
                response.getBody()
            );
            //return (boolean) results.get('inStock');
            return true;
        } else {
            //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
            Long afterAPI = B2B_Util.fetchCurrentTime();
            Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);
            String severity;
            String errorType;
            Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
            if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                severity= errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                errorType=errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
            }
            else{
                severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
            }
            String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
            Error__c errorRecord=B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2BGetInfo',String.valueOf(response.getStatusCode()),errorType,'','checkProductIsInStock',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
            //HDMP-8617- End of changes
            return true;
        }
    }
    
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(
        String communityId,
        String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        
        //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
        //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
        String activeCartOrId = 'active';
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        //Below line of code Added By -Soumya for Person Account changes
        string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
        if(String.isNotBlank(personAccountId))
            effectiveAccountId=personAccountId;
        
        // End - Soumya changes
        return ConnectApi.CommerceCart.getCartSummary(
            webstoreId,
            effectiveAccountId,
            activeCartOrId
        );
    }
    
    @AuraEnabled
    public static ConnectApi.CartItem addToCart(
        String communityId,
        String productId,
        String quantity,
        String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
        cartInput.productId = productId;
        cartInput.quantity = quantity;
        cartInput.type = ConnectApi.CartItemType.PRODUCT;
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        return ConnectApi.CommerceCart.addItemToCart(
            webstoreId,
            effectiveAccountId,
            'active',
            cartInput
        );
    }
    
    @AuraEnabled
    public static ConnectApi.Wishlist createAndAddToList(
        String communityId,
        String productId,
        String wishlistName,
        String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        
        // Store the product in a WishlistItemInput to pass to the Wishlist
        ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
        wishlistItemInput.productId = productId;
        
        //Create a wishlistInput to be created
        ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
        wishlistInput.name = wishlistName;
        wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
            wishlistItemInput
                };
                    
                    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
                    return ConnectApi.CommerceWishlist.createWishlist(
                        webstoreId,
                        effectiveAccountId,
                        wishlistInput
                    );
    }
    
    @AuraEnabled(cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice(
        String communityId,
        String productId,
        String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
        return ConnectApi.CommerceStorePricing.getProductPrice(
            webstoreId,
            productId,
            effectiveAccountId
        );
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> checkProductCompatibility(
        String communityId,
        String productId,
        String effectiveAccountId
    ) {
        String JSONInner = '';
        Compatibility compa = new Compatibility();
        B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
        effectiveAccountId = b2b.Default_Guest_Account__c;
        if(effectiveAccountId != null &&  effectiveAccountId !='000000000000000'){
            
            //Lookup the product id with part number
            if(B2B_Util.isSalesforceID(productId) == false){
                Product2 product = [SELECT Id FROM Product2 WHERE StockKeepingUnit = :productId LIMIT 1];
                productId = product.Id;
            }
            
            
            // Lookup the webstore ID associated with the community
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            ConnectApi.CartSummary CurrentCart = getCartSummary(communityId, effectiveAccountId) ;
            String rootCurrentProductCategory ='';
            String rootCurrentCartCategory ='';
            List<cartItem> cartItems = new List<cartItem>([select id,product2Id from cartItem where cartId =: currentCart.cartId and name !='Delivery Method 2']);
            if(cartItems.size()>0){
                ProductCategoryProduct CurrentItemCategory = [select id,productId, ProductCategoryId  from ProductCategoryProduct  where productId =:productId limit 1];
                ProductCategoryProduct CurrentCartCategory = [select id, ProductCategoryId  from ProductCategoryProduct  where productId =:cartItems[0].product2Id limit 1];
                ConnectApi.ProductCategoryPath categories = ConnectApi.CommerceCatalog.getProductCategoryPath (webstoreId, (String)CurrentItemCategory.ProductCategoryId);
                List<ConnectApi.ProductCategoryData> paths = categories.path;        
                for(ConnectApi.ProductCategoryData cat: paths){
                    if(cat.name=='Honda'||cat.name=='Acura'){
                        rootCurrentProductCategory = cat.name;
                        break;  
                    }
                    
                }
                ConnectApi.ProductCategoryPath CartCategory = ConnectApi.CommerceCatalog.getProductCategoryPath (webstoreId, (String)CurrentCartCategory.ProductCategoryId);
                List<ConnectApi.ProductCategoryData> CartPaths = CartCategory.path;        
                for(ConnectApi.ProductCategoryData cat: CartPaths){
                    if(cat.name=='Honda'||cat.name=='Acura'){
                        rootCurrentCartCategory = cat.name;
                        break;
                        
                    }
                    
                }
                
                if(rootCurrentCartCategory!=''&& rootCurrentProductCategory!=''&& rootCurrentCartCategory!=rootCurrentProductCategory){
                    compa.isCompatible = false;
                    compa.currentProduct = rootCurrentProductCategory;
                    compa.currentCart = rootCurrentCartCategory;
                    compa.message = 'Product incompatible with the cart';
                }
            }
            
        }
        JSONInner = JSON.serialize(compa);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONInner);
        
        
        
        return m;
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static String getCategoryId(String productId)
    {
        String productCategoryName; 
        for(ProductCategoryProduct pc :[Select Id,ProductCategory.Name from ProductCategoryProduct where ProductId=:productId AND IsPrimaryCategory=true]){
            productCategoryName = pc.ProductCategory.Name;
        }
        return productCategoryName;
        
    }
    @AuraEnabled(cacheable=true)
    public static String getProdDetails(String productId){
        if(String.isBlank(productId)){
            return 'productId Blank';
        }
        List<Product2> productDetails =[SELECT Id,Price__c , Name, ProductCode, PickupatDealer__c,Description,StockKeepingUnit FROM Product2 where Id =: productId];
        if(productDetails.size()>0){
            return JSON.serialize(productDetails);
        }
        else
            return 'Product Detail Not Found'; 
    }
    
    
    
    Public class Compatibility
    {
        boolean isCompatible = true;
        String currentCart = '';
        String currentProduct= '';
        String Message= '';
    }
    
    
    Public class comp
    {
        
        public boolean dualcatcomp=false;
        public boolean cartcomp=false;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean getCartCompatibility(String PartNumber,String communityId) 
    {
        Boolean Compatible=false;
        B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
        String  effectiveAccountId = b2b.Default_Guest_Account__c;
        
        ConnectApi.CartSummary CurrentCart = getCartSummary(communityId, effectiveAccountId) ;
        String division ='';
        
        List<cartItem> cartItems = new List<cartItem>([select id,product2Id,Product2.StockKeepingUnit,Product2.division__c from cartItem where 
                                                       cartId =:CurrentCart.cartId and product2.division__c != null and (Not(product2.division__c includes ('A') and product2.division__c includes ('B')))]);
        
        if(cartItems.size()==0){
            return true;
        }
        
        if(cartItems.size()>0){
            division = cartItems[0].product2.division__c;
        }
        
        if(cartItems.size()>=1){
            List<Product2> CurrentItemList=new List<Product2>([select Id,StockKeepingUnit,division__c  from Product2 where StockKeepingUnit=:PartNumber limit 1]);
            if(CurrentItemList.size()>=0){
                Product2 curentItem = CurrentItemList[0];
                if (curentItem.Division__c.contains('A') && curentItem.Division__c.contains('B')){
                    return true;
                }
                else{
                    if(curentItem.Division__c == division)
                        return true;
                    else 
                        return false;
                }
                
            }
            
            
            return true;
        }
        
        return Compatible;
        
    }
    public static comp getResult(String sku,String CurrentItemDivision)
    {
        
        
        comp compat=new comp();
        
        if(sku!=null)
        {
            String ProductDivision  = [select Id,division__c from product2  where   StockKeepingUnit=:sku].division__c;
            
            
            if(ProductDivision =='A;B')
            {
                compat.dualcatcomp=true;
                compat.cartcomp=true;
            }
            
            else if(ProductDivision == 'A' || ProductDivision== 'B')
                
            {
                String CartItemDivision=[select Id,StockKeepingUnit,division__c from Product2 where StockKeepingUnit=:sku].division__c;
                
                if(CartItemDivision == CurrentItemDivision)
                    
                {
                    
                    compat.dualcatcomp=false;
                    compat.cartcomp=true;
                    
                }
                if(CartItemDivision != CurrentItemDivision)
                {
                    
                    compat.dualcatcomp=false;
                    compat.cartcomp=false;
                    
                    
                }
                
            }
            
            
        }
        return compat;
    }
    
    
    // Used to Provide Product SKU number in VinFitCheck
    // By: Sakshi Jadon
    // 22-06-21
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> ProductSKU(String productId) {
        
        List<Product2> productinfo;
        
        if(!String.isEmpty(productId)){
            productinfo=[SELECT Id,StockKeepingUnit FROM Product2 WHERE Id = :productId LIMIT 1];
            
        }
        
        return productinfo;
        
    }
    
    @AuraEnabled
    public static string getCartId(String communityId) 
    { 
        String cartId,effectiveAccountId;
        B2B_Custom_Settings__c b2b = [SELECT Default_Guest_Account__c FROM B2B_Custom_Settings__c LIMIT 1];
        if(b2b != NULL)
            effectiveAccountId = b2b.Default_Guest_Account__c;
        
        if(effectiveAccountId != NULL){
            try{// Added Deepak Mali 11 April 2022 try catch block for 8332 
                ConnectApi.CartSummary CurrentCart = getCartSummary(communityId, effectiveAccountId) ;
                cartId = CurrentCart.cartId;    
            }catch(exception ex){
                System.debug(ex);
            }
        }
        return cartId;
    }
    
    @AuraEnabled(cacheable=false)
    public static Decimal getProuctQuantity(String sku,String cartId) 
    {
        Decimal quantity;
        if(String.isNotEmpty(sku) && String.isNotEmpty(cartId)){
            List<CartItem> cartList= new List<CartItem>([SELECT CartId, Sku, Quantity FROM CartItem WHERE Sku =: sku AND CartId=:cartId LIMIT 1]);
            if(cartList.size() > 0){
                quantity = cartList[0].Quantity;
            }
        }
        return quantity;
    }
    @AuraEnabled(cacheable=false)
    public static Map<String,Decimal> getAllProuctQuantity(String cartId) 
    {
        Map<String,Decimal> prodQuantity = new Map<String,Decimal>();
        if(String.isNotEmpty(cartId)){
            for(CartItem cartList :[SELECT CartId, Sku, Quantity FROM CartItem WHERE CartId=:cartId ])
            {
                prodQuantity.put(cartList.Sku,cartList.Quantity);
            }
        }
        return prodQuantity;
    }
    
    @AuraEnabled
    public static String getDealerInfo(String dealerName, String poiId) {
        try{
            List<Account> accountList =[SELECT Id, Email__c, Phone FROM Account WHERE PoIId__c =: poiId AND Name LIKE : dealerName];
            if(accountList.size() > 0){
                return JSON.serialize(accountList);
            }else {
                return 'Dealer info not recived.';
            }
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Decimal getCartItemsCount(String cartId) 
    {
        Decimal quantity = 0; 
        if(String.isNotEmpty(cartId)){
            List<CartItem> cartList = new List<CartItem>([SELECT CartId, Sku, Quantity FROM CartItem WHERE CartId=:cartId AND Cart.OwnerId =: UserInfo.getUserId()]);
            
            for(CartItem objCartItem : cartList){
                if(objCartItem.Quantity > 0){
                    quantity += objCartItem.Quantity;
                }
            }
            
        }
        return quantity;
    }
    
    //Added by Faraz for HDMP-16716
    @AuraEnabled
    public static string getCartItemBrand(String webcartId){
        try {
            return JSON.serialize([SELECT Id,Cart.Product_Subdivision__c,Product_Type__c, Product_Subdivision__c FROM CartItem WHERE CartId =: webcartId]); 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //End HDMP-16716
}
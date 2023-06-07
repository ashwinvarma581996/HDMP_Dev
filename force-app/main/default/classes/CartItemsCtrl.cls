/*******************************************************************************
Name: CartItemsCtrl
Business Unit: HDM
Date: 10/22/2021
Developer: Bhawesh/Faraz/Shalini/Yashika/Ravi Prasad
Description: Contains all the methods related to Cart info 
*******************************************************************************
MODIFICATIONS – 09/06/2022 | Sayalee Brahmankar | For Header Modification
Updated by - 10/07/2022    | Saikiran           | updated reCalculateTaxOnChangeShippingSpeed , fetchShippingSpeeds
Updated by - 21/04/2023    | Aditya Saini       | added moveUnavailableCartItemsToWishList method for moving cart item to wishlist if Reman Part is not available.
*******************************************************************************/

public without sharing class CartItemsCtrl {
    //should be Named to B2B_***checkout
    @AuraEnabled(cacheable=true)
    public static List<CartItem> getCartItemList(String cartId){
        List<CartItem> cartItems = [SELECT Id,TotalAmount,Cart.Total_Tax__c,Cart.GrandTotalAmount,Cart.DealerId__r.Phone,Product_Type__c, Cart.Pickup_Dealer__c,Cart.DealerId__r.PoIId__c,
                                    Cart.Account.Name,Cart.DealerId__c,Cart.DealerId__r.ShippingAddress,Cart.DealerId__r.Email__c,Cart.DealerId__r.Return_Policy__c,
                                    Cart.DealerId__r.Name, Cart.Delivery_Type__c, Cart.Total_Installation_Charge__c, Cart.ShippingAmount__c, Name,Product2.PickupatDealer__c,Product2.Name,
                                    Product2.StockKeepingUnit,Product2.Color__c,CartId,ListPrice,Quantity,Color__c ,Product_Model_Marketing_Name__c,Product_Identifier__c,op_code__c,Product_Subdivision__c
                                    FROM CartItem 
                                    WHERE cartId =: cartId ORDER BY Sku];
        return cartItems;
    }
    //added by yashika to get total quantity in cart
    @AuraEnabled
    public static string gettotalquantity(String cartId){
        String quantity;
        if(String.isNotBlank(cartId)){
            Decimal cartquantity=[SELECT TotalProductCount,GrandTotalAmount 
                                  FROM WebCart 
                                  WHERE Id=: cartId LIMIT 1].TotalProductCount;
            quantity= String.ValueOf(cartquantity);
        }
        return quantity;
    }
    @AuraEnabled
    public static string gettotalamount(String cartId){
        String amount;
        if(String.isNotBlank(cartId)){
            Decimal cartamount=[SELECT GrandTotalAmount FROM 
                                WebCart 
                                WHERE Id=: cartId LIMIT 1].GrandTotalAmount;
            system.debug('##@@cartamount' + cartamount);
            amount= String.ValueOf(cartamount);
        }
        return amount; 
    }
    
    
    /*@AuraEnabled
public static List<WebCart> getShipToMeDissableMode(String cartId){

return [SELECT Id, DisableShipToMe__c FROM WebCart WHERE id =: cartId];
}*/
    //added by Yashika for 8708
    @AuraEnabled(cacheable=true)
    public static List<CartItem> getCartItemList3(String cartId){
        List<CartItem> cartItems = [SELECT Id,op_code__c ,Cart.Delivery_Type__c,Cart.Total_Installation_Charge__c,TotalAmount,Color__c,Cart.Total_Tax__c,Cart.GrandTotalAmount ,Product_Type__c, 
                                    Cart.DealerId__r.Phone,Cart.Account.Name,Cart.DealerId__c,Cart.DealerId__r.Last_Name__c, Cart.DealerId__r.First_Name__c, Cart.DealerId__r.Operation_Hour__c,
                                    Cart.DealerId__r.Preferred_Shipping_Carrier__r.Name, Cart.DealerId__r.ShippingAddress,Cart.DealerId__r.Name,Cart.DealerId__r.Email__c,Cart.B2B_Shipping_Speed_Options__c,
                                    Name,Product2.PickupatDealer__c,Product2.Name,Product2.Part__c, Product2.Color__c,CartId,ListPrice,Quantity,Cart.CustomerStreet__c, Cart.CustomerCity__c, 
                                    Cart.Customer_State__c, Cart.CustomerCountry__c, Cart.CustomerPostalCode__c, Cart.DealerId__r.ShippingStreet, Cart.DealerId__r.Service_Scheduling_URL__c, Cart.TotalProductCount, 
                                    Cart.DealerId__r.ShippingCity, Cart.DealerId__r.ShippingState, Cart.DealerId__r.ShippingPostalCode, Cart.DealerId__r.ShippingCountry, Cart.customerAddress__c,
                                    Cart.ShippingAmount__c,Cart.Pickup_Dealer__c,Product2.StockKeepingUnit, Product_Model__r.Model_Year__c, Product_Model__r.Model_Name__c, 
                                    Product_Model__r.Trim__c,Product_Model__r.Product_Subdivision__c,Product_Identifier__c,Product_Model_Marketing_Name__c
                                    FROM CartItem WHERE cartId =: cartId ORDER BY Sku];
        return cartItems;
    }
    @AuraEnabled//(cacheable=true)
    public static List<CartItem> getCartItemList2(String cartId){
        try {
            //added schedule_installation__c field  by Yashika for R2 story: appointment scheduling
            // Saravanan LTIM Added Product2.Core_Charge_Unit_Price__c to identify Reman Part
            List<CartItem> cartItems = [SELECT Id,Is_VIN_Fitment__c,op_code__c ,Cart.Delivery_Type__c,Cart.Total_Installation_Charge__c,TotalAmount,Color__c,Cart.Total_Tax__c,Cart.GrandTotalAmount ,Product_Type__c, 
                                        Cart.DealerId__r.Phone,Cart.Account.Name,Cart.DealerId__c,Cart.DealerId__r.Last_Name__c, Cart.DealerId__r.First_Name__c, Cart.DealerId__r.Operation_Hour__c,
                                        Cart.DealerId__r.Preferred_Shipping_Carrier__r.Name,Cart.DealerId__r.B2B_Preferred_Carrier__c,Cart.DealerId__r.Return_Policy__c,Cart.DealerId__r.ShippingAddress,Cart.DealerId__r.Name,
                                        Cart.DealerId__r.Email__c,Cart.B2B_Shipping_Speed_Options__c, Name,Product2.Product_availability__c,Product2.PickupatDealer__c,Product2.Name,Product2.Part__c,Product2.Color__c,CartId,ListPrice,Quantity,Cart.CustomerStreet__c,
                                        Cart.CustomerCity__c, Cart.Customer_State__c, Cart.CustomerCountry__c, Cart.CustomerPostalCode__c,Cart.DealerId__r.ShippingStreet, Cart.DealerId__r.Service_Scheduling_URL__c, Cart.TotalProductCount,
                                        Cart.DealerId__r.ShippingCity, Cart.DealerId__r.ShippingState, Cart.DealerId__r.ShippingPostalCode, Cart.DealerId__r.ShippingCountry,Cart.customerAddress__c,Cart.Customer_Name__c, 
                                        Cart.Customer_Phone__c, Cart.ShippingAmount__c,Cart.Pickup_Dealer__c,Product2.StockKeepingUnit, Product_Model__r.Model_Year__c, Product_Model__r.Model_Name__c,Product_Model__r.Product_Model_ID__c,//for adobe:added fields
                                        Product_Model__r.Trim__c,Product_Model__r.Product_Subdivision__c,Product_Identifier__c,Product_Model_Marketing_Name__c,Cart.Status,Product2.Core_Charge_Unit_Price__c FROM CartItem WHERE cartId =: cartId ORDER BY Sku];
            //Added by saikiran velugundula as part removing HTML tags from return policy 
            /* Start Aditya Bug Fix HDMP-19463 */
            WebCart wc2 = new WebCart();
            wc2.Id = cartId;
            WebCart wcobj2 = [SELECT id,Status,Pickup_Dealer__c,Delivery_Type__c from WebCart where id=:wc2.Id ];
            if(wcobj2.Delivery_Type__c =='Pick Up At Dealer'  && wcobj2.Status != 'Closed'){
                wc2.Pickup_Dealer__c = true;
                update wc2;
            }
            String username;
            for(CartItem item : cartItems ){
                if(item.Product_Type__c == 'Core Charge'){
                    username = UserInfo.getName();
                }
            }
            
            if(username!=null && !username.contains('Guest')){
                Account acc = new Account();
                acc.Id = [SELECT id,AccountId from WebCart where id=:cartId].accountId;
                Account accobj = [SELECT id, Preferred_Delivery_Type__c from account where id=:acc.Id ];
                if(accobj.Preferred_Delivery_Type__c !='Pick Up At Dealer'){
                    acc.Preferred_Delivery_Type__c = 'Pick Up At Dealer';
                    update acc;
                }
                WebCart wc = new WebCart();
                wc.Id = cartId;
                WebCart wcobj = [SELECT id,Status,Pickup_Dealer__c,Delivery_Type__c from WebCart where id=:wc.Id ];
                if((wcobj.Delivery_Type__c !='Pick Up At Dealer' || wcobj.Pickup_Dealer__c !=true) && wcobj.Status != 'Closed'){
                    wc.Delivery_Type__c = 'Pick Up At Dealer';
                    wc.Pickup_Dealer__c = true;
                    update wc;
                }
            }
            /* End Aditya Bug Fix HDMP-19463 */
            return cartItems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

// Start Added by Aditya to fix bug HDMP-18862
/* 
This method moved Reman cart item to wishlist if Reman product is not available that is Product_availability__c field in Product is marked and Not Available.
*/
@AuraEnabled	 
public static Boolean moveUnavailableCartItemsToWishList(String cartId){
    try {
        List<CartItem> updatedCartItems = new List<CartItem>();
        Map<Id,PriceBookEntry> ProductIdsToPriceEntry = new Map<Id,PriceBookEntry>(); // Added by ashwin for 19451
        List<Error__c> createError = new List<Error__c>(); //Added by ashwin for 19451
        // Commented by ashwin for 19451
        /*List<CartItem> cartItems = [SELECT Id, Product2Id, Product2.Name, Product2.Product_availability__c, CartId, Name, Product_Subdivision__c, Cart.Accountid, Cart.WebStoreId,
        Product2.StockKeepingUnit, Quantity, Product_Type__c, Accessorie_Image_URL__c, color__c, Op_Code__c, Product_Identifier__c, Product_Model__c, Product_Model_Marketing_Name__c 
        FROM CartItem WHERE CartId =: cartId AND Product2.Product_availability__c ='Not Available' AND Cart.status = 'Active' AND Product_Type__c !='Core Charge'];*/
        
        List<CartItem> cartItems = [SELECT Id, Product2Id, Product2.Name, Product2.Product_availability__c, CartId, Name, Product_Subdivision__c, Cart.Accountid, Cart.WebStoreId,
        Product2.StockKeepingUnit, Quantity, Product_Type__c, Accessorie_Image_URL__c, color__c, Op_Code__c, Product_Identifier__c, Product_Model__c, Product_Model_Marketing_Name__c 
        FROM CartItem WHERE CartId =: cartId AND  Cart.status = 'Active' AND Product_Type__c !='Core Charge'];
        
        
        //Started by ashwin for 19451
        for(CartItem ci : cartItems){
            ProductIdsToPriceEntry.put(ci.Product2Id, new PriceBookEntry());
        }
        
        
        for(PriceBookEntry pbe : [Select Id, UnitPrice,Product2.isActive, Product2Id,Product2.Product_availability__c, Pricebook2.Name from PricebookEntry where Pricebook2.Name =: label.Dreamshop_Pricebook_Name And  Product2Id IN :ProductIdsToPriceEntry.keySet()]){
            ProductIdsToPriceEntry.put(pbe.Product2Id, pbe);
        }
        // ended by ashwin for 19451
        
        
        
        for(CartItem item : cartItems ){
            // if Condition Added by ashwin for 19451
            if(item.Product2.Product_availability__c == 'Not Available' 
               || (ProductIdsToPriceEntry.containsKey(item.Product2Id) && ProductIdsToPriceEntry.get(item.Product2Id).UnitPrice <= 0))
            {
                updatedCartItems.add(item);
                
                
                
                // creating Error Record Added by ashwin for 19451
                
                
                String errorType = item.Product2.Product_availability__c == 'Not Available'  ? 'Not Available' : 'MSRP Price is 0';
                

                
                String errorMessage = 'Item saved previously in shopping cart have been moved to wishlist, Since the Part ' + errorType;
                
                /*Error__c errorRecord = B2B_Util.createErrorRecord(false, '', '', '', item.Cart.AccountId, item.CartId,
                                                                          '', 'The items previously saved in your shopping cart have been moved to My Wish List.', 
                                                                          errorType, '', '', true, '', item.Product2Id, '', 0, Label.B2B_Severity_API, 
                                                                          '', '');*/
                
                String errorName = 'Part ' + errorType + ' Error' ;
                
                Error__c errorRecord = B2B_DataErrorLogger.createErrorRecord(false,errorName,item.Cart.AccountId,'B2B_DataErrorLogger','logDataError',
                                                                              errorMessage,errorType,true);
                
                errorRecord.Cart__c = item.CartId;
                errorRecord.RecordId__c = item.Product2Id;
                errorRecord.Severity__c = Label.B2B_Severity_API;
                
                createError.add(errorRecord);
                
                
            }
        }
        
        cartItems = updatedCartItems;
        if(cartItems.size() > 0 && !cartItems.isEmpty()){
            List<WishList> wishlistData = [SELECT Id,Name FROM WishList WHERE OwnerId =: UserInfo.getUserId()];
            String wishId = '';
            for(WishList wish : wishlistData){
                if(wish.Name.containsIgnoreCase(cartItems[0].Product_Subdivision__c)){
                    wishId = wish.Id;
                    break;
                }
            }
            if(String.isEmpty(wishId)){
                WishList wishListRec = new WishList(OwnerId=UserInfo.getUserId(),
                Name='My '+ cartItems[0].Product_Subdivision__c +' Wishlist',
                AccountId=cartItems[0].Cart.AccountId,
                WebStoreId=cartItems[0].Cart.WebStoreId);
                insert wishListRec;
                wishId = wishListRec.Id;
            }
            Map<Id,WishListItem> oldProd = new Map<Id,WishListItem>();
            Map<Id,WishListItem> newProd = new Map<Id,WishListItem>();
            boolean isContainsprod = false;
            for(WishListItem wi : [SELECT Id, Product2Id, Quantity__c FROM WishListItem WHERE WishlistId =: wishId]){
                oldProd.put(wi.Product2Id, wi);
            }
            for(CartItem ci : cartItems){
                if(oldProd.containsKey(ci.Product2Id)){
                    oldProd.get(ci.Product2Id).Quantity__c +=ci.Quantity;
                    isContainsprod = true;
                }else {
                    Decimal partPrice = Test.isRunningTest() ? 1 : [SELECT UnitPrice FROM PricebookEntry where Product2.StockKeepingUnit=: ci.Product2.StockKeepingUnit LIMIT 1].UnitPrice;
                    WishListItem wli = new WishListItem();
                    wli.WishlistId = wishId;
                    wli.Product2Id = ci.Product2Id;
                    wli.Quantity__c = ci.Quantity;
                    wli.Product_Subdivision__c = ci.Product_Subdivision__c;
                    wli.Product_Division__c = ci.Product_Subdivision__c == 'Honda' ? 'A' : 'B';
                    wli.Product_Type__c = ci.Product_Type__c;
                    wli.Name = ci.Name;
                    wli.Price__c = partPrice;
                    wli.productImage__c = ci.Accessorie_Image_URL__c;
                    wli.color__c = ci.color__c;
                    wli.Op_Code__c = ci.Op_Code__c;
                    wli.Product_Identifier__c = ci.Product_Identifier__c;
                    wli.Product_Model__c = ci.Product_Model__c;
                    wli.Product_Model_Marketing_Name__c = ci.Product_Model_Marketing_Name__c;
                    wli.AK_Wishlist_Item__c = String.ValueOf(ci.Product2Id)+'~'+String.ValueOf(wishId)+'~'+ci.Product_Type__c ; //HDMP-19439
                    newProd.put(wli.Product2Id, wli);
                }
            }
            if(isContainsprod){
                update oldProd.values();
            }
            if(newProd.size() > 0){
                insert newProd.values(); 
            }
            delete cartItems;
            
            // if condition Added by ashwin for 19451
            if(!createError.isEmpty()){
                insert createError;
            }
            
                return true;
            }
        return false;
    } catch (Exception ex) {
        throw new AuraHandledException(ex.getMessage() + ' At '+ex.getLineNumber());
    }
}
// End Added by Aditya to fix bug HDMP-18862
   
    
    @AuraEnabled
    public static Boolean checkPackageHWL(String cartId){
        Boolean isShipable = true;
        for(CartItem objCartItem : [Select Id, Product2.PickupatDealer__c 
                                    FROM CartItem 
                                    WHERE cartId =:cartId ]){
                                        if(objCartItem.Product2.PickupatDealer__c == true){
                                            isShipable = false;
                                        }
                                    }
        return isShipable;
    }
    
    @AuraEnabled
    public static string redirectToBackScreen(String pState, String nState, String cartId, String orderId){
        CartCheckoutSession cSession = [SELECT Id,state,NextState from CartCheckoutSession 
                                        WHERE WebCartId=:cartId AND IsArchived =false]; // AA: removed 'AND state=:nState'
        cSession.State = pState;
        
        try{
            UPDATE cSession;
            if(String.isNotBlank(orderId)){
                DELETE new order(id=orderId);
            }
        }
        catch(Exception e){
            return cSession.Id + '------' + e.getMessage();
        }
        return 'OK';
    }
    
    @AuraEnabled
    public static String changeStatusWithDeliveryMethod(String cartId, String selectedBrand){
        if(String.isNotBlank(cartId)){
            try{
                // addded for paypal checkout by Rajrishi Kaushik 
                WebCart objCart = [SELECT Is_PayPal_Checkout__c FROM WebCart  WHERE Id =: cartId];
                if(objCart != null && objCart.Is_PayPal_Checkout__c == true){
                    objCart.Is_PayPal_Checkout__c = false;
                    UPDATE objCart;
                    
                    CartCheckoutSession cSession = [SELECT Id,state,NextState 
                                                    FROM CartCheckoutSession 
                                                    WHERE WebCartId=:cartId AND WebCart.OwnerId =: UserInfo.getUserId()];
                    if(cSession != null){
                        cSession.State = 'Delivery Method';
                        UPDATE cSession;                     
                    }
                }
                //Modified by: Bhawesh Asudani for DPS- Issue start 
                if(fetchDelearPrice(cartId,selectedBrand)){ // modified by Bhawesh on 15-03-2022 for 8429
                    List<Order> orderList = new List<Order>([SELECT Id, cart__c 
                                                             FROM Order 
                                                             WHERE cart__c =: cartId AND cart__r.OwnerId =: UserInfo.getUserId()]);
                    if(!orderList.isEmpty()){
                        DELETE orderList;
                    }
                    CartCheckoutSession cSession = [SELECT Id,state,NextState 
                                                    FROM CartCheckoutSession 
                                                    WHERE WebCartId=:cartId AND WebCart.OwnerId =: UserInfo.getUserId()];
                    if(cSession != null){
                        cSession.State = 'Delivery Method';
                        UPDATE cSession;
                        return 'success';
                    }else{
                        return 'initial';
                    }
                }
                //End
            }
            catch(Exception e){
                System.debug('error'+ e.getMessage());
                return 'error: '+ e.getMessage();
            }
            
        }
        return null;  
    }
    
    @AuraEnabled
    public static string updateCart(String cartId, String shippingStreet, String shippingCity, 
                                    String shippingState, String shippingCountry, 
                                    String shippingPostalCode,Boolean isPickupDealer, String customerName,
                                    String customerPhone, String shippingEmail, String shippingNote){
                                        try {
                                            WebCart cart = [Select Id, Shipping_Note__c, Pickup_Dealer__c,CustomerStreet__c,Customer_State__c,CustomerCity__c,CustomerCountry__c,CustomerPostalCode__c, Customer_Name__c, Customer_Phone__c,Customer_Email__c	
                                                            FROM WebCart 
                                                            WHERE Id=: cartId];
                                            if(cart.CustomerStreet__c != shippingStreet || cart.CustomerCity__c != shippingCity ||
                                               cart.Customer_State__c != shippingState || cart.CustomerCountry__c != shippingCountry ||
                                               cart.CustomerPostalCode__c != shippingPostalCode || cart.Pickup_Dealer__c != isPickupDealer || 
                                               cart.Customer_Name__c != customerName || cart.Customer_Phone__c != customerPhone ||
                                               cart.Customer_Email__c != shippingEmail){
                                                   cart.Shipping_Note__c = shippingNote;
                                                   cart.Customer_Name__c = customerName;
                                                   cart.Customer_Phone__c = customerPhone;
                                                   cart.CustomerStreet__c = shippingStreet ;
                                                   cart.CustomerCity__c = shippingCity ;
                                                   cart.Customer_State__c = shippingState ; 
                                                   cart.CustomerCountry__c = shippingCountry ;
                                                   cart.CustomerPostalCode__c = shippingPostalCode;
                                                   cart.Pickup_Dealer__c = isPickupDealer;
                                                   cart.Customer_Email__c = shippingEmail;
                                                   
                                                   UPDATE cart;
                                                   return cart.Id;
                                               } 
                                            else{
                                                return cart.Id;
                                            }             
                                        }catch (Exception e) {
                                            throw new AuraHandledException(e.getMessage());   
                                        }
                                    }
    
    @AuraEnabled
    public static WebCart getCartInfo(String cartId){
        return [Select Id,Pickup_Dealer__c, DisableShipToMe__c, CustomerStreet__c,Customer_State__c,CustomerCity__c,CustomerCountry__c,CustomerPostalCode__c, Customer_Name__c, Customer_Phone__c	
                FROM WebCart 
                WHERE Id=: cartId];
    }
    
    // Getting the Document Id and creating a Document Url.
    public String getStrLogoUrl(){
        List<Document> lstDocument = [SELECT Id 
                                      FROM Document 
                                      WHERE DeveloperName = 'dreamshop'];
        if(!lstDocument.isEmpty()){
            String strOrgId = UserInfo.getOrganizationId();
            String strLogoUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id='+lstDocument[0].Id + '&oid=' + strOrgId;
            return strLogoUrl;
        }
        return '';
        
    }
    
    @AuraEnabled
    public static CheckoutCompatibility proceedCheckout(String CartId){
        try {
            CheckoutCompatibility comp=new CheckoutCompatibility();
            Webcart wc=[SELECT Id,Pickup_Dealer__c,ShippingAmount__c, Total_Tax__c 
                        FROM Webcart 
                        WHERE Id=:CartId];
            if(wc.Pickup_Dealer__c){
                if(wc.Total_Tax__c == null){
                    comp.compat = true;
                    comp.checkoutcomp = false;
                }else{
                    comp.compat = true;
                    comp.checkoutcomp = true;
                }
            }
            else{
                // commented and updated by saikiran as part of HDMP-8924 
                if((wc.ShippingAmount__c == 0) || (wc.Total_Tax__c == null)){
                    comp.compat = true;
                    comp.checkoutcomp = false;
                }else{
                    comp.compat = true;
                    comp.checkoutcomp = true;
                }
            }
            return comp;
        }
        
        
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Order getOrderInfo(String orderId){
        System.debug('id'+orderId);
        return [SELECT Id, OrderNumber,Payment_Type__c,Customer_Preferred_Speeds__c, OrderReferenceNumber, Customer_Name__c, Address__c, BillingCity, BillingStreet,CC_Last4__c, BillingState, BillingPostalCode, BillingCountry 
                FROM Order WHERE Id =: orderId];
    }
    
    //Added by shalini soni 6 Dec 2021 HDMP-5428 R2 Story
    @AuraEnabled
    public static String setDealerInstallationType(String cartId, String deliveryType){
        List<CartItem> cartItemstoUpdates = new List<CartItem>(); 
        String returnString = '';
        
        if(String.isNotBlank(cartId)) {
            WebCart objCart = [SELECT Id, Delivery_Type__c, Pickup_Dealer__c,Honda_Shipping_Speed__c,Shipping_Note__c, Total_Tax__c,Total_Shipping_Tax__c,Total_Installation_Tax__c,Total_Product_TaxAmount__c ,(SELECT Id, Dealer_Installation_Price__c,B2B_Item_Total_Tax__c FROM CartItems WHERE Product_Type__c =: B2BConstants.ACCESSORY) 
                               FROM WebCart 
                               WHERE id =:cartId LIMIT 1]; //Added by Aditya to fix pickup at dealer checkbox for cart
            List<CartItem> cartItems = objCart.CartItems;
            if(objCart != null){
                objCart.Delivery_Type__c = deliveryType;
                try {
                    UPDATE objCart; 
                    returnString = B2BConstants.SUCCESS; 
                } catch(Exception ex){
                    return  returnString = B2BConstants.ERROR;
                }
            }
            //Added by Faraz
            if(deliveryType != B2BConstants.INSTALL_AT_DEALER){
                for(CartItem cartItemObj : cartItems){
                    cartItemObj.Dealer_Installation_Price__c = 0;
                }
                if(cartItems.size() > 0){
                    try{
                        UPDATE cartItems;
                    }catch(Exception ex){
                        throw new AuraHandledException(ex.getMessage());
                    }
                }
            }
            //added by Yashika for 12353: starts
            if((objCart != null)&&(deliveryType == 'Ship To Me')){
            
                objCart.Total_Tax__c=0;
                objCart.Total_Shipping_Tax__c=0;
                objCart.Total_Installation_Tax__c=0;
                objCart.ShippingAmount__c =0;
                objCart.Pickup_Dealer__c = false; //Added by Aditya to fix pickup at dealer checkbox for cart
                try{
                    UPDATE objCart;
                }catch(Exception ex){
                    throw new AuraHandledException(ex.getMessage());
                }
                for(CartItem cartItemObj : cartItems){
                    cartItemObj.B2B_Item_Total_Tax__c = 0;
                }
                if(cartItems.size() > 0){
                    try{
                        UPDATE cartItems;
                    }catch(Exception ex){
                        throw new AuraHandledException(ex.getMessage());
                    }
                }
            }
            else if((objCart != null)){
                if(deliveryType == 'Pick Up At Dealer'){
                    objCart.Total_Installation_Tax__c=0;
                }
                objCart.ShippingAmount__c =0;
                objCart.Total_Shipping_Tax__c=0;
                objCart.Pickup_Dealer__c = true;//Added by Aditya to fix pickup at dealer checkbox for cart
                try{
                    UPDATE objCart;
                }catch(Exception ex){
                    throw new AuraHandledException(ex.getMessage());
                }
                
            }
            // ends: 12353
            //End on 16/12/2021
        }
        return returnString;
    }
    //Ended
    //Added by shalini soni 6 Dec 2021 HDMP-5428 R2 Story
    @AuraEnabled
    public static String setDefaultDealerInstallation(String cartId){
        WebCart objCart = [SELECT Id, Delivery_Type__c 
                           FROM WebCart 
                           WHERE id =:cartId LIMIT 1];
        try{
            objCart.Delivery_Type__c = B2BConstants.PICK_AT_DEALER;
            UPDATE objCart;
        }catch(Exception ex){
            return 'Error '+ex.getMessage();
        }
        return JSON.serialize(objCart);
        
    }
    //Ended
    //Added by shalini soni 6 Dec 2021 HDMP-5428 R2 Story
    @AuraEnabled
    public static String getCartDeliveryType(String cartId){
        List<User> loggedInUserList = [SELECT Id,ContactId FROM User WHERE Id =: userinfo.getUserId() AND ContactId != null LIMIT 1];
        if(!loggedInUserList.isEmpty()){
            List<Account> existingShippingPerferencesList = new List<Account>([SELECT Id, PersonContactId, Preferred_Honda_Shipping_Speed__c, Preferred_Honda_Shipping_Speed__r.Name, Preferred_Delivery_Type__c FROM Account WHERE PersonContactId =: loggedInUserList[0].ContactId LIMIT 1]);
            if(!existingShippingPerferencesList.isEmpty())
            {
                if(String.isNotEmpty(existingShippingPerferencesList[0].Preferred_Delivery_Type__c)){
                    WebCart cart = new WebCart(Id = cartId, Delivery_Type__c = existingShippingPerferencesList[0].Preferred_Delivery_Type__c, Pickup_Dealer__c = false);
                    update cart;
                }
            }  
        }
        return [SELECT Id, Delivery_Type__c 
                FROM WebCart 
                WHERE id =:cartId LIMIT 1]?.Delivery_Type__c;
    }
    //Ended
    //Created by Bhawesh Asudani R2 Story : 4726 Start
    @AuraEnabled
    public static Decimal getCartCountTotal(String cartId){
        Decimal productCount;
        List<WebCart> totalitems=[SELECT Id, TotalProductCount 
                                  FROM WebCart 
                                  WHERE id =:cartId LIMIT 1];
        if(totalitems.size()>0)
            productCount=totalitems[0].TotalProductCount;
        return productCount;
    }
    @AuraEnabled
    public static String reCalculateTaxOnChangeShippingSpeed(String cartId,String shippingCharges,String shippingSpeed){
        //added by saikiran  as part of HDMP 8923
        List<Carrier_Speed__c> hondaShippingSpeeds =  [SELECT id, Carrier_Speed_Name__c, Carrier__r.Name, Honda_Shipping_Speed__c,Honda_Shipping_Speed__r.Honda_Speed_Name__c 
                                                       FROM Carrier_Speed__c 
                                                       WHERE Carrier__r.Is_Active__c=true and Carrier_Speed_Name__c = :shippingSpeed];
        String recalulatedTax = '';
        B2B_VertexTaxCalculationIntegration.ResponseDataWrapper responseData = B2B_TaxHelperV2.getTaxRatesAndAmountsFromVertex(cartId,shippingCharges,'','');
        if(responseData.isSuccess){
            recalulatedTax = responseData.totalTaxAmount;
            try{
                WebCart wCart = [SELECT Id,Is_PayPal_Checkout__c,Honda_Shipping_Speed__c,Name,total_tax__c,ShippingAmount__C,
                                 (SELECT Id FROM Orders__r)
                                 FROM WebCart 
                                 WHERE Id =: cartId];
                if(wCart != null){
                    wCart.total_tax__c = Decimal.valueOf(recalulatedTax);
                    wCart.ShippingAmount__C = Decimal.valueOf(shippingCharges);
                    //wCart.Shipping_Speed__c = shippingSpeed;
                    String speedName = '';
                    // added by saikiran as part of HDMP 8923
                    for( Carrier_Speed__c speed : hondaShippingSpeeds){
                        if(speed.Carrier_Speed_Name__c == shippingSpeed){
                            wCart.Honda_Shipping_Speed__c = speed.Honda_Shipping_Speed__c ;
                            speedName = speed.Honda_Shipping_Speed__r.Honda_Speed_Name__c;
                        }
                    }
                    UPDATE wCart;
                    if(wCart.Is_PayPal_Checkout__c == true && !wCart.Orders__r.isEmpty()){
                        Order objOrder = new Order();
                        objOrder.Id = wCart.Orders__r[0].Id;
                        objOrder.Customer_Preferred_Speeds__c = speedName;
                        objOrder.Updated_Shipping__c = Decimal.valueOf(shippingCharges);
                        objOrder.Original_Shipping_Amount__c = Decimal.valueOf(shippingCharges);
                        objOrder.Updated_Total_Tax__c = Decimal.valueOf(recalulatedTax);
                        objOrder.TotalTaxAmount__c = Decimal.valueOf(recalulatedTax);
                        objOrder.Total_Shipping_Tax__c = responseData.shippingTaxAmount;
                        objOrder.Current_Shipping_Tax__c = responseData.shippingTaxAmount;
                        UPDATE objOrder;
                    }
                }
            }catch(Exception e){
                B2B_CheckoutUtility.createErrorRecord('Tax calculation error', null, e.getMessage(), 'CartItemsCtrl', 'reCalculateTaxOnChangeShippingSpeed',cartId,true,true);
                return JSON.serialize(responseData);
            }
        }else{
            WebCart wCart = [SELECT Id,Honda_Shipping_Speed__c,Name,total_tax__c,ShippingAmount__C
                                 FROM WebCart 
                                 WHERE Id =: cartId];
            if(wCart != null){
                wCart.total_tax__c=0.00;
                UPDATE wCart;
            }
        }
        return JSON.serialize(responseData);
    }
    // End
    
    /**
** @Method Name : getDealerInformation 
** @Parameters  : Dealer Id
** Created Date : 4th Jan 2021
** @Description : To get dealer information based on Dealer Id
** @JIRA Ticekt : R2 story : HDMP-5409
** Created by: Sai Lakshman Kanukollu Starts
*/
    @AuraEnabled
    public static Account getDealerInformation(Id dealerId){
        return [SELECT Id,ShippingStreet,ShippingCity,ShippingPostalCode 
                FROM Account 
                WHERE Id =:dealerId];
    }
    //Ends
    
    //Created by: Bhawesh Asudani R2 story : HDMP-4726 Start
    @AuraEnabled(cacheable = true)
    public static List<Carrier_Speed__c> fetchShippingSpeeds(){
        // Commented and updated by saikiran as part of HDMP - 8926
        //     return [SELECT Id, Shipping_Carrier__c, DeveloperName, MasterLabel, Language, Label, Speed_Category__c,B2B_Speed_Sequence__c 
        //    FROM Shipping_Speed__mdt 
        //    ORDER By B2B_Speed_Sequence__c];
        return [SELECT id,Carrier_Speed_Name__c,Carrier__r.Name,Honda_Shipping_Speed__r.Honda_Speed_Name__c,Sort_Order__c 
                FROM Carrier_Speed__c where Carrier__r.Is_Active__c=true
                ORDER By Sort_Order__c];
    }
    //End
    //Added By Pradeep for HDMP-8188
    @AuraEnabled
    public static Boolean updateDealerPrice(String cartId, String selectedBrand){
        return fetchDelearPrice(cartId,selectedBrand);
    }
    
    //ends here
    /*Created by: Bhawesh Asudani for DPS- Issue start 
Description : This method is used to update dealer price which dealer is accociated with the cart */
    static Boolean fetchDelearPrice(String cartId, String selectedBrand){ // modified by Bhawesh on 15-03-2022 for 8429
        try{
            List<String> partNumberList = New List<String>();
            List<String> opCodeList = New List<String>();
            List<CartItem> updateCartItemList = new List<CartItem>();
            String dealerNo;
            
            List<webCart> cartList = new List<webCart>([Select Id, Name, DealerId__r.PoIId__c, (SELECT Id, op_code__c, cartId,sku, Product_Type__c, 
                                                                                                TotalPrice, Quantity, ListPrice, unitAdjustedPrice, 
                                                                                                TotalListPrice, SalesPrice, TotalLineAmount
                                                                                                FROM CartItems WHERE Sku != null OR op_code__c != null) 
                                                        FROM webCart 
                                                        WHERE Id =: cartId AND OwnerId =: UserInfo.getUserId()]);            
            if(!cartList.isEmpty()){
                dealerNo = cartList[0].DealerId__r.PoIId__c;
                
                for(CartItem cartItem : cartList[0].CartItems){
                    if(cartItem.Product_Type__c == 'Part')
                        partNumberList.add(cartItem.Sku);
                    else if(cartItem.Product_Type__c == 'Accessory')
                        opCodeList.add(cartItem.op_code__c);
                }
                
                System.debug('partNumberList'+partNumberList);
                System.debug('opCodeList'+opCodeList);
                System.debug('dealerNo'+dealerNo);
                
                // modified by Bhawesh on 15-03-2022 for 8429
                DelearPriceResponseWrapper delearPriceResponse = (DelearPriceResponseWrapper) System.JSON.deserialize(B2B_INSystemIntegration.GetDealerPrice(dealerNo, Integer.valueOf(selectedBrand),JSON.serialize(partNumberList), JSON.serialize(opCodeList)), DelearPriceResponseWrapper.class);
                System.debug('delearPriceResponse: '+delearPriceResponse);
                
                for(CartItem cartItem : cartList[0].CartItems){
                    if(cartItem.Product_Type__c == 'Part'){
                        for(DelearPriceAccessoryResponseWrpper partObj : delearPriceResponse.Parts){
                            if(cartItem.Sku == partObj.partNumber){
                                cartItem.ListPrice  = Decimal.valueOf(partObj.DIYPrice);
                                cartItem.unitAdjustedPrice = Decimal.valueOf(partObj.DIYPrice);
                                cartItem.SalesPrice  = Decimal.valueOf(partObj.DIYPrice);
                                cartItem.TotalLineAmount  = cartItem.Quantity * Decimal.valueOf(partObj.DIYPrice);
                                cartItem.TotalListPrice  = cartItem.Quantity * Decimal.valueOf(partObj.DIYPrice);
                                cartItem.TotalPrice  = cartItem.Quantity * Decimal.valueOf(partObj.DIYPrice);
                                //cartItem.TotalPriceAfterAllAdjustments  = cartItem.Quantity != NULL ?  cartItem.Quantity * Decimal.valueOf(partObj.DIYPrice) : 0;
                                updateCartItemList.add(cartItem);
                                break;
                            }
                        } 
                    }
                    else if(cartItem.Product_Type__c == 'Accessory'){
                        for(DelearPriceAccessoryResponseWrpper accessoriesObj : delearPriceResponse.Accessories){
                            if(cartItem.op_code__c ==  accessoriesObj.OpCode){
                                cartItem.ListPrice  = Decimal.valueOf(accessoriesObj.DIYPrice);
                                cartItem.SalesPrice  = Decimal.valueOf(accessoriesObj.DIYPrice);
                                cartItem.unitAdjustedPrice = Decimal.valueOf(accessoriesObj.DIYPrice);
                                cartItem.TotalLineAmount  = cartItem.Quantity * Decimal.valueOf(accessoriesObj.DIYPrice);
                                cartItem.TotalListPrice  = cartItem.Quantity * Decimal.valueOf(accessoriesObj.DIYPrice);
                                cartItem.TotalPrice  = cartItem.Quantity * Decimal.valueOf(accessoriesObj.DIYPrice);
                                updateCartItemList.add(cartItem);
                                break;
                            }
                        }
                    }
                }
                
                if(!updateCartItemList.isEmpty()){
                    UPDATE updateCartItemList;
                    return true;
                } 
                
            }
            
            return false; 
            
        }catch(Exception ex){
            System.debug('Error while testing'+ex.getMessage()+ex.getLineNumber());
            return false;
        }
        
    }
    //End
    
    /* Created by:Shalini Soni
* Created Date:16 March 2022
Description : This method is used to get custom labels */
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getCustomLabels() {
        Map<String,String> nameOfLabels = new Map<String,String>();
        
        nameOfLabels.put('PickUpDealer', System.Label.PickUpDealer);
        nameOfLabels.put('InstallAtDealer', System.Label.InstallAtDealer);
        nameOfLabels.put('ShiptoMe', System.Label.ShiptoMe);
        nameOfLabels.put('ShippableErrorMessage', System.Label.ShippableErrorMessage);
        
        return nameOfLabels;
    }
    //Ends
    
    /* Created by:Shalini Soni
* Created Date:21 March 2022 for bug-8380
Description : This method is used to get custom labels for cartshippingSummary */
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getCustomLabelforCartShippingSummary() {
        Map<String,String> nameOfLabels = new Map<String,String>();
        
        nameOfLabels.put('ZipCodeLabel', System.Label.ZipCode_Label);
        nameOfLabels.put('Verifying_Zipcode', System.Label.Verifying_Zipcode);
        nameOfLabels.put('Estimated_Shipping', System.Label.Estimated_Shipping);
        nameOfLabels.put('Estimated_Tax', System.Label.Estimated_Tax);
        nameOfLabels.put('Estimated_Cart_Subtotal', System.Label.Estimated_Cart_Subtotal);
        
        return nameOfLabels;
    }
    //Ends
    
    public class CheckoutCompatibility
    {
        @AuraEnabled
        public boolean compat{get;set;}
        @AuraEnabled
        public boolean checkoutcomp{get;set;}
    }
    
    //Created by: Bhawesh Asudani for DPS- Issue start  
    public class DelearPriceResponseWrapper{
        public List<DelearPriceAccessoryResponseWrpper> Accessories;
        public String DealerNo;
        public Integer DivisionID;
        public List<DelearPriceAccessoryResponseWrpper> Parts;
    }
    
    public class DelearPriceAccessoryResponseWrpper{
        public string DIYPrice;
        public string InstallationCharges;
        public string OpCode;
        public string PriceWithInstallation;
        public string partNumber;
    }
    //End
    //for adobe analytics: returnCheckoutState method
    @AuraEnabled
    public static String returnCheckoutState(String cartId){
        CartCheckoutSession cSession = [SELECT Id,State,NextState from CartCheckoutSession 
                                        WHERE WebCartId=:cartId AND IsArchived =false]; // AA: removed 'AND state=:nState'
        
        return cSession.State;
    }

       /**
     * Method Name : updateCartItemstoSyncDynamically
     * Modified by: LTIM
     * Description : To update the Core charge cart item name on loading of page
     * Bug : HDMP-18566
     */

     @AuraEnabled
     public static Boolean updateCartItemstoSyncDynamically(string cartId){
         Boolean showMessage = false;

         try {

             List<CartItem> lstCartItem = new List<CartItem>();
             List<CartItem> lstCartItemtoUpdate = new List<CartItem>();
             List<CartItem> lstCartItemParts = new List<CartItem>();
             set<id> setCoreChargeProdIds = new set<id>();
             List<CartItem> lstCartItemDelete = new List<CartItem>(); // Saravanan LTIM Addded for 18860,18862
             Set<string> setProductSKU = new Set<string>();// Saravanan LTIM Addded for 18860,18862
             Map<string,Decimal> mapPriceBookEntry = new Map<string,Decimal> ();// Saravanan LTIM Addded for 18860,18862
             List<CartItem> lstmCoreChargetoDelete = new List<CartItem>(); 
 
             lstCartItem = [SELECT Id,Product_Type__c,Product2.Core_Charge_Unit_Price__c,Name,Product2.Name,Product2Id,UnitAdjustedPrice,Product_Subdivision__c, Cart.Accountid, Cart.WebStoreId,
             Product2.StockKeepingUnit, Quantity, Accessorie_Image_URL__c, color__c, Op_Code__c, Product_Identifier__c, Product_Model__c, Product_Model_Marketing_Name__c FROM CartItem WHERE cartId =:cartId ];
            

             for(CartItem objCartItem : lstCartItem){
 
                setProductSKU.add(objCartItem.Product2.StockKeepingUnit);
                if(objCartItem.Product_Type__c == Label.B2B_Product_Code_Core_Charges){
                     objCartItem.Name = objCartItem.Product2.Name + ' ' + Label.B2B_Reman_Part_Core_Charge_Identification_Label;
                     objCartItem.unitAdjustedPrice = objCartItem.Product2.Core_Charge_Unit_Price__c; // LaksShmi LTIM 18860
                     lstCartItemtoUpdate.add(objCartItem);
                     setCoreChargeProdIds.add(objCartItem.Product2Id);
                      
                     
                    if(!(objCartItem.UnitAdjustedPrice > 0)){

                       //lstmCoreChargetoDelete.add(objCartItem);
                    }
 
                 }else if(objCartItem.Product_Type__c == 'Part'){
                    
                    lstCartItemParts.add(objCartItem);

                    //objCartItem.UnitAdjustedPrice = 0;

                    if(!(objCartItem.UnitAdjustedPrice > 0)){

                        lstCartItemDelete.add(objCartItem);
                    }
                 }
                 
             }

             system.debug('changing vale---'+setCoreChargeProdIds.size());

             // To Identify the Reman Parts
             for(CartItem objCartItem : lstCartItemParts){

                // If the core charge with same prouct , then we are idenfying as Reman Products
                if(setCoreChargeProdIds.contains(objCartItem.Product2Id) ){
                    system.debug('check here---'+objCartItem.Product2Id);
                    objCartItem.Name = objCartItem.Product2.Name + ' ' + Label.B2B_Reman_Part_Identification_Label ;
                    lstCartItemtoUpdate.add(objCartItem);

                    // Saravanan LTIM Added for 18860
                    if(objCartItem.Product_Type__c == 'Part' && objCartItem.Product2.Core_Charge_Unit_Price__c <= 0){
                        lstCartItemDelete.add(objCartItem);

                    }
                }

             }
 
             Database.update(lstCartItemtoUpdate);

             List<User> loggedInUserList = [SELECT Id,ContactId FROM User WHERE Id =: userinfo.getUserId() AND ContactId != null LIMIT 1];

            
             
             if(!lstCartItemDelete.isEmpty()){

                List<WishList> wishlistDetails = [SELECT Id,Name FROM WishList WHERE OwnerId =: UserInfo.getUserId()];

                Map<Id,WishListItem> existingProducts = new Map<Id,WishListItem>();
                Map<Id,WishListItem> newProducts = new Map<Id,WishListItem>();
                List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();

                String wishListId = '';
                for(WishList wishListObj : wishlistDetails){
                    if(wishListObj.Name.containsIgnoreCase(lstCartItemDelete[0].Product_Subdivision__c)){
                        wishListId = wishListObj.Id;
                        break;
                    }
                }
                if(String.isEmpty(wishListId)){
                    WishList wishListRecord = new WishList(OwnerId=UserInfo.getUserId(),
                    Name='My '+ lstCartItemDelete[0].Product_Subdivision__c +' Wishlist',
                    AccountId=lstCartItemDelete[0].Cart.AccountId,
                    WebStoreId=lstCartItemDelete[0].Cart.WebStoreId);
                    insert wishListRecord;
                    wishListId = wishListRecord.Id;
                }
              
                boolean isProductExisting = false;
              

                 lstPriceBookEntry = [SELECT Product2.StockKeepingUnit , UnitPrice FROM PricebookEntry where Product2.StockKeepingUnit in : setProductSKU];

                

                for(PricebookEntry objPriceEntry : lstPriceBookEntry){

                    mapPriceBookEntry.put(objPriceEntry.Product2.StockKeepingUnit,objPriceEntry.UnitPrice);

                }

                for(WishListItem wi : [SELECT Id, Product2Id, Quantity__c FROM WishListItem WHERE WishlistId =: wishListId]){
                    existingProducts.put(wi.Product2Id, wi);
                }


                for(CartItem cartItemInstance : lstCartItemDelete){

                    showMessage = true;

                    if(existingProducts.containsKey(cartItemInstance.Product2Id)){
                        existingProducts.get(cartItemInstance.Product2Id).Quantity__c +=cartItemInstance.Quantity;
                        isProductExisting = true;
                    }else {
                        Decimal ProductPrice = Test.isRunningTest() ? 1 : mapPriceBookEntry.get(cartItemInstance.Product2.StockKeepingUnit);
                        WishListItem wli = new WishListItem();
                        wli.WishlistId = wishListId;
                        wli.Product2Id = cartItemInstance.Product2Id;
                        wli.Quantity__c = cartItemInstance.Quantity;
                        wli.Product_Subdivision__c = cartItemInstance.Product_Subdivision__c;
                        wli.Product_Division__c = cartItemInstance.Product_Subdivision__c == 'Honda' ? 'A' : 'B';
                        wli.Product_Type__c = cartItemInstance.Product_Type__c;
                        wli.Name = cartItemInstance.Name;
                        wli.Price__c = ProductPrice;
                        wli.productImage__c = cartItemInstance.Accessorie_Image_URL__c;
                        wli.color__c = cartItemInstance.color__c;
                        wli.Op_Code__c = cartItemInstance.Op_Code__c;
                        wli.Product_Identifier__c = cartItemInstance.Product_Identifier__c;
                        wli.Product_Model__c = cartItemInstance.Product_Model__c;
                        wli.Product_Model_Marketing_Name__c = cartItemInstance.Product_Model_Marketing_Name__c;
                        wli.AK_Wishlist_Item__c = String.ValueOf(wli.Product2Id)+'~'+String.ValueOf(wishListId)+'~'+cartItemInstance.Product_Type__c ; //HDMP-19439
                        newProducts.put(wli.Product2Id, wli);
                    }

                }


                if(isProductExisting){
                    update existingProducts.values();
                }
                if(newProducts.size() > 0){
                    insert newProducts.values(); 
                }

                Database.delete(lstCartItemDelete,false);

             }

             Database.delete(lstmCoreChargetoDelete,false);

             return showMessage ;
 
         } catch (Exception e) {
             return showMessage;
         }
     }
	 
	 // Added by ashwin
     @AuraEnabled(cacheable=true)
    public static Order getDraftOrderInfo(String orderId){
        return [SELECT Id, BillingPostalCode, Account.PoiId__c from Order where Id = : orderId];
    }

    
     
 
}
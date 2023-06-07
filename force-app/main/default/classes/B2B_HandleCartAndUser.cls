/**********************************************************************
Name: B2B_HandleCartAndUser
Business Unit:HDM
Developer : Deepak Mali
Description:
MODIFICATIONS- Soumya Sahoo (HDMP-6467)
MODIFICATIONS – Palak | (Added header and removal of commented code)
*************************************************************/

public without sharing class B2B_HandleCartAndUser {
    @AuraEnabled
    public static string getCurrentCart() 
    {  
        user u = [select id,AccountId, user.account.recordtype.developerName from user where id=:UserInfo.getUserId() ];
        List<Webcart> cartidlist=[select id from webcart where ownerid=:UserInfo.getUserId() and status='Active' Limit 1];
        if(cartidlist.size()>0)
            return cartidlist[0].id;
        else
            return '';
    }
    @AuraEnabled
    public static String handleCart(String userId, String cartId,string brand) 
    { 
        boolean ismoved = false;//Added by saikiran as part HDMP -15507
        if(cartId != '' && cartId !=null && cartId!='undefined' ){
            List<webCart> activeCartList = new List<webCart>([select id from webCart where ownerId=:userId and status = 'Active' and id !=:cartId]);
            try{
                String loggedInCartId,AccountIdCart,WebStoreIdCart;
                Boolean flag=false;
                List<WishList> wl = new List<Wishlist>();
                if(brand!='' && brand!=Null && brand=='Honda'){
                   wl = [SELECT Id FROM WishList WHERE OwnerId =: userId and Name=:'My Honda Wishlist'];
                }else if(brand!='' && brand!=Null && brand=='Acura'){
                   wl = [SELECT Id FROM WishList WHERE OwnerId =: userId and Name=:'My Acura Wishlist'];  
                }
                List<webcart> loggedInCartIdlist=[select id, AccountId,WebStoreId from webcart where ownerid=:userId and status = 'Active'  ];
                if(loggedInCartIdlist.size()>0){
                    loggedInCartId=loggedInCartIdlist[0].id;
                    AccountIdCart=loggedInCartIdlist[0].AccountId;
                    WebStoreIdCart=loggedInCartIdlist[0].WebStoreId;
                    flag=true;
                }
                if(!wl.isEmpty()){
                    ismoved = moveItemsToWishList(loggedInCartId,wl[0].Id);//updated by saikiran as part HDMP -15507
                } else if(flag==true) {
                    Wishlist wishListRecord = new Wishlist();
                    if(brand=='Honda'){
                    wishListRecord = new WishList(OwnerId=userId,Name='My Honda Wishlist',AccountId=AccountIdCart,WebStoreId=WebStoreIdCart);
                    }else{
                     wishListRecord = new WishList(OwnerId=userId,Name='My Acura Wishlist',AccountId=AccountIdCart,WebStoreId=WebStoreIdCart);
                        
                    }
                    insert wishListRecord;
                    ismoved = moveItemsToWishList(loggedInCartId,wishListRecord.Id);//updated by saikiran as part HDMP -15507
                }
                if(activeCartList.size()>0){ 
                    for(webCart wc: activeCartList){
                        wc.status = 'closed'; 
                    }
                }
                user u = [select id, accountId, account.recordtype.developerName from user where id=:UserInfo.getUserId() ];
                List<WebCart> wcGuestList = New List<webCart>([SELECT Id, OwnerId, AccountId FROM Webcart WHERE Id=: cartId AND Status ='Active' LIMIT 1]);
                update activeCartList;
                if(wcGuestList.size()>0)
                {
                    wcGuestList[0].OwnerId = userId;
                    wcGuestList[0].AccountId = u.accountId;
                    update wcGuestList[0];
                }
            }catch(DmlException e){
                return e.getMessage();
            }
            //updated by saikiran as part HDMP -15507
            if(ismoved) { return 'success';}
            else{return '';}
        }else if(brand!=Null && brand!=''){
            try{
                String loggedInCartId,AccountIdCart,WebStoreIdCart;
                Boolean flag=false;
                List<WishList> wishlistDetails = getExistingWishlist(userId, brand);
                List<CartItem> cartitemlist =getCartItemList(userId);
                if(cartitemlist.size()>0){
                    if(!brand.equalsIgnoreCase(cartitemlist[0].Product_Subdivision__c)){
                        loggedInCartId=String.valueof(cartitemlist[0].cartId);
                        AccountIdCart=cartitemlist[0].cart.AccountId;
                        WebStoreIdCart=cartitemlist[0].cart.WebStoreId;
                        if(!wishlistDetails.isEmpty()){
                            ismoved = moveItemsToWishList(loggedInCartId,wishlistDetails[0].Id);//updated by saikiran as part HDMP -15507
                        } else {
                            WishList wishListRecord = new WishList(OwnerId=userId,Name='My'+brand+'Wishlist',AccountId=AccountIdCart,WebStoreId=WebStoreIdCart);
                            insert wishListRecord;
                            ismoved =  moveItemsToWishList(loggedInCartId,wishListRecord.Id);//updated by saikiran as part HDMP -15507
                        }
                        Webcart cart=[select id from webcart where id=:loggedInCartId];
                        cart.status='Closed';
                        if(cart !=Null)
                            update cart;
                    }
                }
            }catch(DmlException e){
                return e.getMessage();
            }
           //updated b by saikiran as part HDMP -15507
            if(ismoved) { return 'success';}
            else{return '';}
        } else
            return '';
    }
    public static List<WishList> getExistingWishlist(String userId, String brand){
        if(brand=='Honda'){
            return [SELECT Id, Name FROM WishList WHERE OwnerId =: userId and Name=:'My Honda Wishlist'];
        }else if(brand=='Acura'){
            return [SELECT Id, Name FROM WishList WHERE OwnerId =: userId and Name=:'My Acura Wishlist'];
        }
        else{
            return new List<WishList>();
        }
    }
    public static List<CartItem> getCartItemList(String userId){
        return [select id,cartId,Product_Subdivision__c,cart.ownerid,cart.Accountid,cart.WebStoreId,cart.status from CartItem where cart.status = 'Active' and cart.ownerid =: userId];
    }
    //updated return type by saikiran as part HDMP -15507
    public static boolean moveItemsToWishList(String cartId, String wishListId){
        List<CartItem> cartItemsToDelete = new List<CartItem>();
        Map<Id,WishListItem> existingProducts = new Map<Id,WishListItem>();
        Map<Id,WishListItem> NewProducts = new Map<Id,WishListItem>();
        boolean isProductExisting = false;
        for(WishListItem wi : [SELECT ID,WishlistId,Product2Id,Quantity__c,Brand__c,Name,Price__c,productImage__c FROM WishListItem WHERE WishlistId =: wishListId]){
            existingProducts.put(wi.Product2Id,wi);
        }
        for(CartItem cartItemInstance : [SELECT Id,Product_Subdivision__c, Name,Product2.StockKeepingUnit, Product2Id, Quantity, Accessorie_Image_URL__c, ListPrice,Product_Type__c,color__c,Op_Code__c,Product_Model_Marketing_Name__c,Product_Model__c,Product_Identifier__c FROM CartItem WHERE CartId =: cartId AND Product_Type__c!='Motocompacto']){
            if(existingProducts.containsKey(cartItemInstance.Product2Id)){
                existingProducts.get(cartItemInstance.Product2Id).Quantity__c +=cartItemInstance.Quantity;
                isProductExisting = true;
            }else {
                Decimal ProductPrice = Test.isRunningTest() ? 1 : [SELECT Id, UnitPrice,Product2.StockKeepingUnit FROM PricebookEntry where Product2.StockKeepingUnit=: cartItemInstance.Product2.StockKeepingUnit LIMIT 1 ].UnitPrice ; //added by Yashika for 17058
                WishListItem wli    = new WishListItem();
                wli.WishlistId      = wishListId;
                wli.Product2Id      = cartItemInstance.Product2Id;
                wli.Quantity__c     = cartItemInstance.Quantity;
                wli.Product_Subdivision__c = cartItemInstance.Product_Subdivision__c;
                if(cartItemInstance.Product_Subdivision__c=='Honda'){
                    wli.Product_Division__c='A';
                }
                else{
                    wli.Product_Division__c='B';
                }
                wli.Product_Type__c = cartItemInstance.product_type__c;
                wli.Name            = cartItemInstance.Name;
                wli.Price__c        = ProductPrice;
                wli.productImage__c = cartItemInstance.Accessorie_Image_URL__c;
                wli.color__c        = cartItemInstance.color__c;
                wli.Op_Code__c      = cartItemInstance.Op_Code__c;
                wli.Product_Identifier__c = cartItemInstance.Product_Identifier__c;
                wli.Product_Model__c  = cartItemInstance.Product_Model__c;
                wli.Product_Model_Marketing_Name__c = cartItemInstance.Product_Model_Marketing_Name__c;
                newProducts.put(wli.Product2Id, wli);
            }
        }
        if(existingProducts.size()>0){
            update existingProducts.values();
            if(isProductExisting){
            return true;}//Added by saikiran as part HDMP -15507
        }
        if(newProducts.size()>0){
            insert newProducts.values();  
            return true;//Added by saikiran as part HDMP -15507
        }
        return false;//Added by saikiran as part HDMP -15507
    }

    @AuraEnabled
    public static Boolean moveInactiveItemsToWishList(){
        try {
            String cartId = getCurrentCart();
            if(String.isNotEmpty(cartId)){
                List<CartItem> cartItems = [SELECT Id, Product2Id, Product2.Name, Product2.IsActive, CartId, Name, Product_Subdivision__c, Cart.Accountid, Cart.WebStoreId,
                Product2.StockKeepingUnit, Quantity, Product_Type__c, Accessorie_Image_URL__c, color__c, Op_Code__c, Product_Identifier__c, Product_Model__c, Product_Model_Marketing_Name__c 
                FROM CartItem WHERE CartId =: cartId AND Product2.IsActive = false AND Cart.status = 'Active'];
                if(cartItems.size() > 0 && !cartItems.isEmpty()){
                    List<WishList> wishlistDetails = getExistingWishlist(UserInfo.getUserId(),cartItems[0].Product_Subdivision__c);
                    String wishListId = '';
                    for(WishList wishListObj : wishlistDetails){
                        if(wishListObj.Name.containsIgnoreCase(cartItems[0].Product_Subdivision__c)){
                            wishListId = wishListObj.Id;
                            break;
                        }
                    }
                    if(String.isEmpty(wishListId)){
                        WishList wishListRecord = new WishList(OwnerId=UserInfo.getUserId(),
                        Name='My '+ cartItems[0].Product_Subdivision__c +' Wishlist',
                        AccountId=cartItems[0].Cart.AccountId,
                        WebStoreId=cartItems[0].Cart.WebStoreId);
                        insert wishListRecord;
                        wishListId = wishListRecord.Id;
                    }
                    Map<Id,WishListItem> existingProducts = new Map<Id,WishListItem>();
                    Map<Id,WishListItem> newProducts = new Map<Id,WishListItem>();
                    boolean isProductExisting = false;
                    for(WishListItem wi : [SELECT Id, Product2Id, Quantity__c FROM WishListItem WHERE WishlistId =: wishListId]){
                        existingProducts.put(wi.Product2Id, wi);
                    }
                    for(CartItem cartItemInstance : cartItems){
                        if(existingProducts.containsKey(cartItemInstance.Product2Id)){
                            existingProducts.get(cartItemInstance.Product2Id).Quantity__c +=cartItemInstance.Quantity;
                            isProductExisting = true;
                        }else {
                            Decimal ProductPrice = Test.isRunningTest() ? 1 : [SELECT UnitPrice FROM PricebookEntry where Product2.StockKeepingUnit=: cartItemInstance.Product2.StockKeepingUnit LIMIT 1].UnitPrice;
                            WishListItem wli    = new WishListItem();
                            wli.WishlistId      = wishListId;
                            wli.Product2Id      = cartItemInstance.Product2Id;
                            wli.Quantity__c     = cartItemInstance.Quantity;
                            wli.Product_Subdivision__c = cartItemInstance.Product_Subdivision__c;
                            wli.Product_Division__c = cartItemInstance.Product_Subdivision__c == 'Honda' ? 'A' : 'B';
                            wli.Product_Type__c = cartItemInstance.Product_Type__c;
                            wli.Name            = cartItemInstance.Name;
                            wli.Price__c        = ProductPrice;
                            wli.productImage__c = cartItemInstance.Accessorie_Image_URL__c;
                            wli.color__c        = cartItemInstance.color__c;
                            wli.Op_Code__c      = cartItemInstance.Op_Code__c;
                            wli.Product_Identifier__c = cartItemInstance.Product_Identifier__c;
                            wli.Product_Model__c  = cartItemInstance.Product_Model__c;
                            wli.Product_Model_Marketing_Name__c = cartItemInstance.Product_Model_Marketing_Name__c;
                            newProducts.put(wli.Product2Id, wli);
                        }
                    }
                    if(isProductExisting){
                        update existingProducts.values();
                    }
                    if(newProducts.size() > 0){
                        insert newProducts.values();  
                    }
                    delete cartItems;
                    return true;
                }
            }
            return false;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage() + ' At '+ex.getLineNumber());
        }
    }
}
/****************************************************************************************************************
Name: B2BCartControllerSample
Purpose: Contains all the methods related to webcart & cartItems during shopping also some dealerInstallation.
Created Date : 10/22/2021
Created By   : 
******************************************************************************************************************
MODIFICATIONS – Date 		|	Dev Name	   |	Method		|	User Story
******************************************************************************************************************
                        | Faraz Ansari |addDealerInstallationPrice| HDMP-5428
******************************************************************************************************************/
 
/**
 * @description Demonstrates how to make Apex calls to ConnectApi.CommerceCart class
 * to perform Cart Operations for B2B Commerce on Lightning.
 *
 * @see B2BUtils
 */
public without sharing class B2BCartControllerSample {
  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.getCartItems
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   * @param pageParam Specifies the page token to be used to view a page of information.
   * @param sortParam Sort order for items in a cart.
   * @return CartItemCollection A collection of cart items
   */
  @AuraEnabled
  public static ConnectApi.CartItemCollection getCartItems(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId,
    String pageParam,
    String sortParam
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // Get the ConnectApi.CartItemSortOrder enum value from string.
    // For the list of possible values, see:
    // see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_enums.htm#cartItemSortOrderEnum
    ConnectApi.CartItemSortOrder resolvedSortParam = B2BUtils.resolveSortParam(
      sortParam
    );
      //Below line of code Added By -Soumya for Person Account changes
		string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
        if(String.isNotBlank(personAccountId))
            effectiveAccountId=personAccountId;
      // End- Soumya
      
    // For more details, see:
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
    return ConnectApi.CommerceCart.getCartItems(
      webstoreId,
      effectiveAccountId,
      activeCartOrId,
      pageParam,
      resolvedSortParam
    );
  }

  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.updateCartItem
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   * @param cartItemId ID of the cart item to be updated.
   * @return CartItem The updated cart item
   */
  @AuraEnabled
  public static ConnectApi.CartItem updateCartItem(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId,
    String cartItemId,
    ConnectApi.CartItemInput cartItem
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // For more details, see:
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
    //Below line of code Added By -Soumya for Person Account changes
		string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
        if(String.isNotBlank(personAccountId))
            effectiveAccountId=personAccountId;
      // End- Soumya
    return ConnectApi.CommerceCart.updateCartItem(
      webstoreId,
      effectiveAccountId,
      activeCartOrId,
      cartItemId,
      cartItem
    );
  }

  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.deleteCartItem
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   * @param cartItemId ID of the cart item to be deleted.
   */
  @AuraEnabled
  public static void deleteCartItem(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId,
    String cartItemId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
	 //Below line of code Added By -Soumya for Person Account changes
		string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
        if(String.isNotBlank(personAccountId))
            effectiveAccountId=personAccountId;
      // End- Soumya
     
    // For more details, see:
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
    ConnectApi.CommerceCart.deleteCartItem(
      webstoreId,
      effectiveAccountId,
      activeCartOrId,
      cartItemId
    );
  }

  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.getCartSummary
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   */
  @AuraEnabled
  public static ConnectApi.CartSummary getCartSummary(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
	      //Below line of code Added By -Soumya for Person Account changes
		string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
        if(String.isNotBlank(personAccountId))
            effectiveAccountId=personAccountId;
      // End- Soumya
    // For more details, see:
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
    return ConnectApi.CommerceCart.getCartSummary(
      webstoreId,
      effectiveAccountId,
      activeCartOrId
    );
  }

  // Created by K.SURYA SAKETH on 29/6/21
  //This method is to unlock cart if checkout is cancelled
    @AuraEnabled
    public static boolean unlockCart(String CartId)
    {
        WebCart c=[select Id,Status from WebCart where Id=:cartId];
        Boolean status=false;
        try{
            if(c!=null&& c.Status=='Checkout')
            {
                c.Status='Active';
                Update c;
                status=true;
            }
            
            Order ord=[Select Id,cart__c,status from Order where cart__c=:CartId];
            Order ordsum=[Select Id from Order where Id=:ord.id ]; //changed by Yashika for 8938
            if(ord !=null)
            {
                
                if(ord.status=='Activated')
                    ord.status='Draft';
                Update ord;
                
            }
            if(ord.status=='Draft'&&ordsum!=null)
            {
                Delete ordsum;
                Delete ord;
                
            }
            
        }
        Catch(Exception e)
        {
            System.debug('Exception '+e.getMessage());
        }
        return status;
        
    }
    
       //Added by deepak mali 9 March 2022
    //This method is to unlock cart if checkout
    @AuraEnabled
    public static Boolean cartToActive(String userId){
        Boolean status=false;
        List<WebCart> listCarts = new List<WebCart>([SELECT Id, Name,Status FROM webcart
                    WHERE owner.Id =:userId AND Status ='Checkout' LIMIT 1
                                                    ]);
        
        if(listCarts.size()>0){
           WebCart objCart = listCarts[0];
        try{
                if(objCart.Status=='Checkout'){
                    objCart.Status='Active';
                    Update objCart;
                status=true;
            }
            
                Order ord=[Select Id,cart__c,status from Order where cart__c =:objCart.Id];
            Order ordsum=[Select Id from Order where Id=:ord.id ]; //changed by Yashika for 8938
            if(ord !=null){
                if(ord.status=='Activated')
                    ord.status='Draft';
                Update ord;
            }
            if(ord.status=='Draft'&&ordsum!=null){
                Delete ordsum;
                Delete ord;
            }
            
        } catch(Exception e) {
            System.debug('Exception '+e.getMessage());
            }
        }
        return status;
    }
    //Ends
  

  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.createCart
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   */
  @AuraEnabled
  public static ConnectApi.CartSummary createCart(
    String communityId,
    String effectiveAccountId
  ) {
            //Below line of code Added By -Soumya for Person Account changes
		string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
       if(String.isNotBlank(personAccountId))
            effectiveAccountId=personAccountId;
      // End- Soumya
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
    ConnectApi.CartInput cartInput = new ConnectApi.CartInput();
    cartInput.effectiveAccountId = effectiveAccountId;
    // For more details, see:
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
    return ConnectApi.CommerceCart.createCart(webstoreId, cartInput);
  }

  /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.deleteCart
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   */
  @AuraEnabled
  public static void deleteCart(
    String communityId,
    String effectiveAccountId,
    String activeCartOrId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
	      //Below line of code Added By -Soumya for Person Account changes
		string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
        if(String.isNotBlank(personAccountId))
            effectiveAccountId=personAccountId;
      // End- Soumya
    // For more details, see:
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
    ConnectApi.CommerceCart.deleteCart(
      webstoreId,
      effectiveAccountId,
      activeCartOrId
    );
  }

    //Created by Faraz Ansari for R2 Story : 5428 Start
    @AuraEnabled
    public static string getCartItemsSku(String[] cartItemIds){
        try {
            return JSON.serialize( [SELECT Id, Name, Sku, Product_Type__c, Quantity, op_code__c, Product2.Division__c, Product_Subdivision__c FROM CartItem WHERE Id IN :cartItemIds AND Cart.OwnerId =: UserInfo.getUserId()] );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string addDealerInstallationPrice(List<Object> cartItems){
        String s = JSON.serialize(cartItems);
        List<CartItem> cartItemsList = (List<CartItem>) JSON.deserialize(s, List<CartItem>.class);
        List<Error__c> errorList = new List<Error__c>();
        System.debug('cartItemsList : '+cartItemsList);
        try {
            if(cartItemsList.size() > 0){
                for(CartItem itemObj : cartItemsList){
                    if(itemObj.Dealer_Installation_Price__c != null){
                        itemObj.Dealer_Installation_Price__c = itemObj.Dealer_Installation_Price__c * itemObj.Quantity;
                    }
                    if(itemObj.Dealer_Installation_Price__c == 0){
                        Error__c errorObj = new Error__c();
                        errorObj.Cart__c = itemObj.CartId;
                        errorObj.Error_Message__c = itemObj.Brand_Name__c +' '+itemObj.Product_Type__c +' '+ itemObj.Name +  ' do not have installation price for the mentioned '+itemObj.Brand_Name__c+ ' dealer.';
                        errorObj.Error_Type__c = 'Dealer installation zero(0) price issue.';
                        errorObj.RecordId__c = itemObj.Id;
                        errorList.add(errorObj);
                    }
                }
                update cartItemsList;
            }
            if(errorList.size() > 0){
                insert errorList;
            }
            return JSON.serialize([SELECT cart.Total_Installation_Charge__c FROM cartItem WHERE Id =: cartItemsList[0].Id]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //End 5428 R2 Story

    @AuraEnabled
    public static List<CartItem> getProductPrice(Map<String,String> cartItemIdToProdIdMap){
        
        if(cartItemIdToProdIdMap.isEmpty()){ return null;}
        
        
        
        List<CartItem> deleteCartItems = new List<CartItem>();
        Map<String,String> prodIdToCartItemId = new Map<String,String>();
        Map<String,Pricebookentry> prodIdToPbe = new  Map<String,Pricebookentry>();
        
        List<Pricebookentry> pbeLis = [Select Id, UnitPrice, Product2Id,Product2.Product_availability__c, Pricebook2.Name from PricebookEntry where Pricebook2.Name =: label.Dreamshop_Pricebook_Name And  Product2Id IN :cartItemIdToProdIdMap.values()];
        
        
        if(!pbeLis.isEmpty()){
            for(Pricebookentry pbe : pbeLis) {
                prodIdToPbe.put(pbe.Product2Id,pbe);
            }
        }
        
        for(String s : cartItemIdToProdIdMap.keySet()){
            
            prodIdToCartItemId.put(cartItemIdToProdIdMap.get(s), s);
        }
        
        
        for(String k : prodIdToCartItemId.KeySet()){
            if((prodIdToPbe.containsKey(k) && prodIdToPbe.get(k).UnitPrice == 0) || prodIdToPbe.get(k).Product2.Product_availability__c == 'Not Available'){
                
                CartItem ci = new CartItem(Id = prodIdToCartItemId.get(k) , Product2Id = k);
                deleteCartItems.add(ci);
                
                
            }
        }
        
        delete deleteCartItems;
        
        
        return !deleteCartItems.isEmpty() ? deleteCartItems : null;
        
    }
    
    @AuraEnabled
    public static Boolean isUserLoggedIn(){
        User usr = [SELECT Id,Name,Contact.Name FROM User WHERE Id =: userinfo.getUserId()];
        
        if(!usr.Name.containsIgnoreCase('Guest Contact')){
            return true;
        }
        
        return false;
        
    }
}
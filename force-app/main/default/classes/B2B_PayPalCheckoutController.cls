/*******************************************************************************
Name: B2B_PayPalCheckoutController
Business Unit: HDM
Date: 10/08/2022
Developer: Rajrishi Kaushik
Description: This class is used to handle the paypal checkout processes.
Test ClassName- 
*******************************************************************************/

public without sharing class B2B_PayPalCheckoutController {

    public static String merchantId;
    public static String accessToken; 
    public static String AUTHORIZATION_HEADER;
    public static boolean isProcessPayment = false;
    public static BT_Token_Details__c updateBTDetails;
    
    /*
    Created By : Rajrishi Kaushik
    Date : 10/08/2022
    Description : This method is used get the client token to render the paypal button on cart page.
    */ 
    @AuraEnabled
    public static Map<String, Object> getClientToken(String cartId){
        WebCart wc = [SELECT Id, TOTAL__c , DealerId__c,DealerId__r.Return_Policy__c, DealerId__r.Name, Delivery_Type__c FROM WebCart WHERE Id = :cartId];
        merchantId = [SELECT Id, Merchant_Id__c FROM Account WHERE Id = :wc.DealerId__c].Merchant_Id__c;
        setAccessToken(wc.DealerId__c);
      
        Map<String, Object> returnData = new Map<String, Object>();
        
        B2B_CreditCardController.AUTHORIZATION_HEADER = accessToken;
        B2B_CreditCardController.BASE_URL = 'callout:DealerBraintreeGraphQL';           
        String clientTokenPayPal = B2B_CreditCardController.requestClientToken();
        System.debug('clientTokenPayPal'+ clientTokenPayPal);
        returnData.put('success', true);
        returnData.put('tokenPayPal', clientTokenPayPal);  
        returnData.put('cart', wc);
        if(String.isNotEmpty(wc.DealerId__c) && wc.DealerId__r.Return_Policy__c != null){
            String returnPolicy = wc.DealerId__r.Return_Policy__c.stripHtmlTags();
            returnData.put('returnPolicy', returnPolicy);
        }
       	
        if(updateBTDetails != null){
            UPDATE updateBTDetails;
        }
        return returnData;
    } 
    
    /*
    Created By : Rajrishi Kaushik
    Date : 10/08/2022
    Description : This method is used to update the shipping information on cart from PayPal.
    */ 
    @AuraEnabled
    public static String updateCart(String shippingAddress, String shippingEmail, String customerPhone, String cartId, String orderType){
        try {
            if(String.isNotEmpty(cartId)){
                List<CartCheckoutSession> cSessionList = [SELECT Id,state,NextState 
                                                    FROM CartCheckoutSession 
                                                    WHERE WebCartId=:cartId AND WebCart.OwnerId =: UserInfo.getUserId() LIMIT 1];
                if(!cSessionList.isEmpty() && cSessionList[0].State != 'Start'){
                    cSessionList[0].State = 'Start';
                    UPDATE cSessionList;                     
                }
                
                if(orderType == 'Ship To Me'){
                    Map<String, Object> mapShippingAddress = (Map<String, Object>)JSON.deserializeUntyped(shippingAddress);
                    
                    WebCart cart = new WebCart();
                    cart.Id = cartId;
                    cart.Is_PayPal_Checkout__c = true;
                    cart.Customer_Name__c = mapShippingAddress.containsKey('recipientName') ? (String)mapShippingAddress.get('recipientName') : '';
                    cart.Customer_Phone__c = customerPhone;
                    cart.CustomerStreet__c = mapShippingAddress.containsKey('line1') ? (String)mapShippingAddress.get('line1') : '';
                    cart.CustomerCity__c = mapShippingAddress.containsKey('city') ? (String)mapShippingAddress.get('city') : '';
                    cart.Customer_State__c = mapShippingAddress.containsKey('state') ? (String)mapShippingAddress.get('state') : ''; 
                    cart.CustomerCountry__c = mapShippingAddress.containsKey('countryCode') ? (String)mapShippingAddress.get('countryCode') : '';
                    cart.CustomerPostalCode__c = mapShippingAddress.containsKey('postalCode') ? (String)mapShippingAddress.get('postalCode') : '';
                    cart.Pickup_Dealer__c = false;
                    cart.Customer_Email__c = shippingEmail;
                    
                    UPDATE cart; 
                }else {
                    WebCart objCart = [SELECT Id, DealerId__c FROM WebCart WHERE Id =: cartId];
                    if(objCart != null && String.isNotEmpty(objCart.DealerId__c)){
                        Account objAcc = [SELECT Id, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry FROM Account WHERE Id =: objCart.DealerId__c];
                        WebCart cart = new WebCart();
                        cart.Id = cartId;
                        cart.Is_PayPal_Checkout__c = true;
                        cart.CustomerStreet__c = objAcc.ShippingStreet;
                        cart.CustomerCity__c = objAcc.ShippingCity;
                        cart.Customer_State__c = objAcc.ShippingState; 
                        cart.CustomerCountry__c = objAcc.ShippingCountry;
                        cart.CustomerPostalCode__c = objAcc.ShippingPostalCode;
                        cart.Pickup_Dealer__c = true;
                        UPDATE cart;
                    }                   
                }
                
                return 'success';
            }  
        }catch(Exception ex){
            System.debug('exception : '+ ex.getMessage() + ex.getLineNumber());
            return ex.getMessage() + ex.getLineNumber();
        }
       return null;
    }
    
    /*
    Created By : Rajrishi Kaushik
    Date : 10/08/2022
    Description : This method is used to shipping charges from shipping API for PayPal checkout.
    */
    @AuraEnabled
    public static boolean calculateShippingCharges(String cartId){
        try{
            if(String.isNotEmpty(cartId)){
                String response = B2B_ShippingHelper.startCartProcessMegaSync(cartId, '', '');
                B2B_IntegrationWrapper shipResponse = (B2B_IntegrationWrapper)JSON.deserialize(response, B2B_IntegrationWrapper.class);
                System.debug('shipping response :- '+ response);
                if(shipResponse != null && shipResponse.isSuccess == true){
                    return true;
                }
            }       
        }catch(Exception ex){
            System.debug('exception :-'+ex.getMessage());
            System.debug('exception :-'+ex.getStackTraceString());
        }        
        return false;
    }
       
    /*
    Created By : Rajrishi Kaushik
    Date : 10/08/2022
    Description : This method is used to get the taxes from vertex API for PayPal checkout.
    */
    @AuraEnabled
    public static Map<String, Object> calculateTaxes(String cartId){   
        
        Map<String, Object> returnData = new Map<String, Object>();
        returnData.put('isSuccess', false);
        try {
            List<WebCart> lstCarts = [SELECT Id, Delivery_Type__c FROM WebCart WHERE Id =: cartId];                       
            if(!lstCarts.isEmpty()){
                //get Taxes from vertex             
                String vertexRes = B2B_TaxHelperV2.startCartProcessMegaSync(cartId, '', '', '');
                System.debug('vertexRes :- '+vertexRes);
                if(String.isNotEmpty(vertexRes)){
                    returnData.put('isSuccess', true);
                }                    
                
            }
        }catch(Exception ex){
            System.debug('exception :-'+ex.getMessage());
            System.debug('exception :-'+ex.getStackTraceString());
            returnData.put('errorMessage', ex.getMessage());
        }        
        
        return returnData;
    }
    
    /*
    Created By : Rajrishi Kaushik
    Date : 10/08/2022
    Description : This method is used to process the payment after calculating taxes for PayPal checkout.
    */
    @AuraEnabled
    public static Map<String, Object> processPayment(String orderId, String cartId, Map<String, object> customerData, String paypalNonce){
        isProcessPayment = true;
		String username = userInfo.getName();
        WebCart cart = [SELECT Id, Total_Shipping_Tax__c, DealerId__c, Delivery_Type__c, TOTAL__c, DealerId__r.Merchant_Id__c,
                        CustomerStreet__c,CustomerCity__c, Customer_State__c, CustomerCountry__c, CustomerPostalCode__c
                        FROM WebCart WHERE Id =: cartId];
        String merchantId = cart.DealerId__r != null ? cart.DealerId__r.Merchant_Id__c : '';
        if(cart != null && String.isNotEmpty(merchantId)){
            Boolean isNewCustomer = false;
            //set the braintree customer Id
            String customerId;
            String legacyId;
            if(username.contains('Guest')){
                B2B_CreditCardController.DATA_UPDATES = new Map<String, Object>();
                customerId = B2B_CreditCardController.createCustomer(customerData);
                legacyId = B2B_CreditCardController.DATA_UPDATES.containsKey('legacyId') ? String.valueOf(B2B_CreditCardController.DATA_UPDATES.get('legacyId')) : '';
                isNewCustomer = true;
                
            }else {
                List<BT_Customer_Details__c> customerDetailList = [SELECT Id, BT_CustomerId__c, BT_Customer_Legecy_Id__c 
                                                                   FROM BT_Customer_Details__c WHERE Customer__c =: UserInfo.getUserId() LIMIT 1];
                if(!customerDetailList.isEmpty()){
                    customerId = customerDetailList[0].BT_CustomerId__c;
                    legacyId =  customerDetailList[0].BT_Customer_Legecy_Id__c;
                }else {
                    B2B_CreditCardController.DATA_UPDATES = new Map<String, Object>();
                    customerId = B2B_CreditCardController.createCustomer(customerData);
                    legacyId = B2B_CreditCardController.DATA_UPDATES.containsKey('legacyId') ? String.valueOf(B2B_CreditCardController.DATA_UPDATES.get('legacyId')) : '';
                    isNewCustomer = true;
                }
            }
            
            //check for customer id should not be null
            if(String.isNotEmpty(customerId)){
                
                //set the access token in class variable
                setAccessToken(cart.DealerId__c);
                
                if(String.isNotEmpty(accessToken)){                    
                    B2B_PayPalCheckoutHelper.isDealerInstall = (cart.Delivery_Type__c == 'Install At Dealer') ? true : false;
                    B2B_PayPalCheckoutHelper.DEALER_ID = cart.DealerId__c;
                    B2B_PayPalCheckoutHelper.CART_ID = cartId;
                    B2B_PayPalCheckoutHelper.ORDER_ID = orderId;
                    
                    Map<String, Object> returnData = B2B_PayPalCheckoutHelper.makePayment(customerId, merchantId, accessToken, String.valueOf(cart.TOTAL__c), paypalNonce);
                    
                    //Update the Access/Refresh Token information 
                    //(NOTE: if Transaction failed but tokens were refreshed, these need to be saved)
                    if(updateBTDetails != null){
                        UPDATE updateBTDetails;
                    }
                    
                    if(returnData.containsKey('success') && Boolean.valueOf(returnData.get('success'))){                        
                        returnData.put('isNewCustomer', isNewCustomer); 
                        returnData.put('customerId', customerId); 
                        returnData.put('legacyId', legacyId); 
                        returnData.put('shippingTax', cart.Total_Shipping_Tax__c);    
                        returnData.put('cart', cart);
                        returnData.put('orderId', orderId);  
                        returnData.putAll(customerData);
                        B2B_PayPalCheckoutHelper.doPostUpdateTransactions(returnData);
                        return returnData;
                    }                                        
                }                
            } 
        }
        return null;
    }
       
    /*
    Created By : Rajrishi Kaushik
    Date : 10/08/2022
    Description : This method is helper method to set the access token in class variable from BT_Token_Detais__c object.
    */
    public static void setAccessToken(String dealerId){
        try { 
            BT_Token_Details__c btDetails = [SELECT Id, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c FROM BT_Token_Details__c WHERE Account__c = :dealerId];
            
            //If true, Access Token is expired & a new one needs to be requested
            if(Datetime.now() > btDetails.AccessTokenExpiresAt__c) {
                //Ensure refresh token is still valid
                if(Datetime.now() < btDetails.RefreshTokenExpiresAT__c) {
                    requestNewAccessToken(btDetails);
                } else {
                    //TODO - determine route if refresh token is expired
                }
            } else {
                accessToken = btDetails.AccessToken__c;
            }
        } catch(Exception e) {
            System.debug(e.getMessage());       
        } 
    }
    
    /*
    Created By : Rajrishi Kaushik
    Date : 10/08/2022
    Description : This method is used when the access token is expired.
    */
    public static void requestNewAccessToken(BT_Token_Details__c btDetails){
        String refreshTokenResponse = B2B_BrainTreeIntegration.getRefreshToken(merchantId, btDetails.RefreshToken__c);
        B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();           
        objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(refreshTokenResponse, B2B_AccessTokenResponseWrapper.class);                       
		if(objAccessTokenResponseWrapper.status == 200){ 
            btDetails = B2B_BrainTreeUtils.checkBTTokenDetails(btDetails, objAccessTokenResponseWrapper);
            accessToken = objAccessTokenResponseWrapper.credentials.accessToken;
            updateBTDetails = btDetails;                       
        }
    }
    
//for adobe:getCartItemList2
    @AuraEnabled//(cacheable=true)
    public static List<CartItem> getCartItemList2(String cartId){
        try {
            List<CartItem> cartItems = [SELECT Id,Name,Product2.StockKeepingUnit,Product_Model__r.Model_Year__c, Product_Model__r.Model_Name__c, Product_Model__r.Trim__c,
                                        Product_Model__r.Product_Subdivision__c,Product_Model__r.Product_Model_ID__c
                                        FROM CartItem 
                                        WHERE cartId =: cartId ORDER BY Product2.StockKeepingUnit];
            return cartItems;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
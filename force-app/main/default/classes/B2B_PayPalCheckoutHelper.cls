/*******************************************************************************
Name: B2B_PayPalCheckoutHelper
Business Unit: HDM
Date: 10/08/2022
Developer: Rajrishi Kaushik
Description: This class is a helper class of B2B_PayPalCheckoutController 
			 which is used to handle the paypal checkout processes.
Test ClassName- 
*******************************************************************************/
public without sharing class B2B_PayPalCheckoutHelper {

    public static boolean isDealerInstall;
    public static String DEALER_ID;
    public static String CART_ID;
    public static String ORDER_ID;
    
    /*
    Created By : Rajrishi Kaushik
    Date : 10/08/2022
    Description : This method is used to link the cart with the order for PayPal Checkout.
    */
    @AuraEnabled
    public static string linkCartToOrder(string cartId, string orderId, Map<String, Object> dataToUpdate){
        try {
            if(String.isNotEmpty(cartId) && String.isNotEmpty(orderId)){
                               
                Order objOrder = new Order();
                objOrder.Id = orderId;
                objOrder.cart__c = cartId;
                
                //set billing details
                if(dataToUpdate.containsKey('email')) {
                    objOrder.BillingEmailAddress = String.valueOf(dataToUpdate.get('email'));
                    //objOrder.Email__c = String.valueOf(dataToUpdate.get('email'));
                }
                
                //Set the necessary Address 1 and 2 fields
                if(dataToUpdate.containsKey('address1')) {
                    String fullAddress = String.valueOf(dataToUpdate.get('address1'));
                    
                    if(dataToUpdate.containsKey('address2') && String.isNotEmpty(String.valueOf(dataToUpdate.get('address2')))) {
                        fullAddress += ', ' + String.valueOf(dataToUpdate.get('address2'));
                    }
                    objOrder.BillingStreet = fullAddress;
                }
                
                //Set the necessary City field
                if(dataToUpdate.containsKey('city')) {
                    objOrder.BillingCity = String.valueOf(dataToUpdate.get('city'));
                }
                
                //Set the necessary State field
                if(dataToUpdate.containsKey('state')) {
                    objOrder.BillingState = String.valueOf(dataToUpdate.get('state'));
                }
                
                //Set the necessary Zip Code field
                if(dataToUpdate.containsKey('zipCode')) {
                    objOrder.BillingPostalCode = String.valueOf(dataToUpdate.get('zipCode'));
                }
                
                //Set the necessary Country field
                if(dataToUpdate.containsKey('country')) {
                    objOrder.BillingCountry = String.valueOf(dataToUpdate.get('country'));
                }
                
                //Set the necessary Customer Name field
                if(dataToUpdate.containsKey('name')) {
                    if(!String.isBlank(String.valueOf(dataToUpdate.get('name')))) {
                        if(!userInfo.getName().containsIgnoreCase('Guest Contact')){
                            objOrder.Email_Username__c = userInfo.getName();
                            objOrder.Customer_Name__c = String.valueOf(dataToUpdate.get('name'));
                        }else{
                            objOrder.Customer_Name__c = String.valueOf(dataToUpdate.get('name'));
                            objOrder.Email_Username__c = String.valueOf(dataToUpdate.get('name'));
                        }  
                    }
                }
                
                //Set the necessary Phone fields
                if(dataToUpdate.containsKey('phone')) {
                    if(!String.isBlank(String.valueOf(dataToUpdate.get('phone')))) {
                        objOrder.BillingPhoneNumber = String.valueOf(dataToUpdate.get('phone'));
                    }
                }
                
                
                UPDATE objOrder;
                
                B2B_DraftOrderUpdateController.FlowInputs objFlowInputs = new B2B_DraftOrderUpdateController.FlowInputs();
                objFlowInputs.cartId = cartId;
                objFlowInputs.orderId = orderId;
                List<B2B_DraftOrderUpdateController.FlowInputs> lstFlowInputs = new List<B2B_DraftOrderUpdateController.FlowInputs>();
                lstFlowInputs.add(objFlowInputs);
                B2B_DraftOrderUpdateController.updateOrderAndOrderItem(lstFlowInputs);
                return 'success';
            }
           
        } catch(Exception ex){
            system.debug('exception :-'+ ex.getMessage());
            return ex.getMessage();
        }
        return null;
    }
    
    /*
    Created By : Rajrishi Kaushik
    Date : 10/08/2022
    Description : This method is used call braintree PRE/POST API to charge the customer.
    */
    public static Map<String, Object> makePayment(String customerId, String merchantId, String accessToken, String totalAmount, String nonce){
        Map<String, Object> returnData = new  Map<String, Object>();
        returnData.put('success', false);
        String res = B2B_BrainTreeIntegration.braintreeTransactionPreAuth(customerId, merchantId, accessToken, totalAmount, '', nonce);

        if(res != null) {
            try {
                Map<String, Object> authResponse = (Map<String, Object>)JSON.deserializeUntyped(res);
                Long beforeAPI = DateTime.now().getTime();
                if(authResponse != null) {
                    if(authResponse.containsKey('status')) {
                        Integer status = Integer.valueOf(authResponse.get('status'));
                        
                        if(status == 200 && authResponse.containsKey('transactionBT')) {
                            Map<String, Object> transactionResponse = (Map<String, Object>)authResponse.get('transactionBT');
                            returnData.put('authorizationId', String.valueOf(transactionResponse.get('id')));
                            
                            if(isDealerInstall == true){
                                String postAuthResponse = B2B_BrainTreeIntegration.braintreeTransactionPostAuth(customerId, merchantId, String.valueOf(transactionResponse.get('id')), totalAmount, accessToken);
                                B2B_BrainTreeTransactionResponse postAuthBTResponse = B2B_BrainTreeTransactionResponse.parse(postAuthResponse);
                                if(postAuthBTResponse.status == 200){
                                    returnData.put('transactionStatus', postAuthBTResponse.transactionBT.status);
                                    returnData.put('success', true);
                                }else {

                                    returnData.put('error', 'An error occurred while authorizing the Payment');
                                    
                                    Long afterAPI = DateTime.now().getTime();
                                    Long durationTime = afterAPI - beforeAPI;
                                    String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                    //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                                    
                                    String severity;
                                    String errorType;
                                    Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                                    if(errorRecords.containskey(String.valueOf(postAuthBTResponse.status))){
                                        severity= errorRecords.get(String.valueOf(postAuthBTResponse.status)).severity__c;
                                        errorType=errorRecords.get(String.valueOf(postAuthBTResponse.status)).error_Type__c;
                                    }
                                    else{
                                        severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                                        errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                                    }
                                    Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID, 'B2B_CreditCardController', String.valueOf(postAuthBTResponse.status), errorType, '', 'submitAuthorizationRequest', true, ORDER_ID, '', '', durationTime, severity, 'Request:'+postAuthBTResponse.requestBody, 'Response:'+postAuthBTResponse.responseBody);
                                    //HDMP-8617:ends
                                }
                                
                            }else {                                  
                                returnData.put('transactionStatus', String.valueOf(transactionResponse.get('status')));
                                returnData.put('success', true);                              
                            }                       
                        } 
                        else {                            
                            //If we have a response from Braintree, leverage this info and return
                            //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                            Long afterAPI = DateTime.now().getTime();
                            Long durationTime = afterAPI - beforeAPI;
                            String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                            
                            String severity;
                            String errorType;
                            Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                            if(errorRecords.containskey(String.valueOf(status))){
                                severity= errorRecords.get(String.valueOf(status)).severity__c;
                                errorType=errorRecords.get(String.valueOf(status)).error_Type__c;
                            }
                            else{
                                severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                                errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                            }
                            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID, 'B2B_CreditCardController', String.valueOf(status), errorType, '', 'submitAuthorizationRequest', true, ORDER_ID, '', '', durationTime, severity, 'Request:'+authResponse.get('requestBody'), 'Response:'+authResponse.get('responseBody'));
                            //HDMP-8617:ends
                            returnData.put('error', String.valueOf(authResponse.get('errorMessage')));
                        }
                    }
                }
            } catch(Exception e) {
                //Pass exception message to Error__c record if an exception occurred
                returnData.put('error', e.getMessage() + ' LineNumber :-' + e.getLineNumber());
            }
           
        }
        return returnData;
    }
    
    /*
    Created By : Rajrishi Kaushik
    Date : 10/08/2022
    Description : This method is used Insert/Update the salesforce object after the API calls.
    */
    public static void doPostUpdateTransactions(Map<String, Object> updateData){
        if(updateData.containsKey('orderId')){
            if(updateData.containsKey('customerId') && Boolean.valueOf(updateData.get('isNewCustomer'))){
                createCustomerDetailsRecord(updateData);
            }
            
            if(updateData.containsKey('authorizationId')){
                //create transaction
                createTransactionDetailsRecord(updateData);
            }
            
            updateOrderDetails(updateData); 
        }               
    }
    
    //create customer record in salesforce
    public static void createCustomerDetailsRecord(Map<String, Object> dataToUpdate) {
        try {
            BT_Customer_Details__c customerDetails = new BT_Customer_Details__c();
            customerDetails.Customer__c = UserInfo.getUserId();
            
            customerDetails.BT_CustomerId__c = String.valueOf(dataToUpdate.get('customerId'));
            //changes for HDMP-8720
            customerDetails.Payment_Gateway__c = 'Braintree';
            //changes for HDMP-8730 
            if(dataToUpdate.containsKey('legacyId')){
                customerDetails.BT_Customer_Legecy_Id__c = String.valueOf(dataToUpdate.get('legacyId'));
            }
            insert customerDetails;
            
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    //create transaction record in salesforce
    public static void createTransactionDetailsRecord(Map<String, Object> dataToUpdate) {
        try {
            BT_Transaction_Details__c transactionDetails = new BT_Transaction_Details__c();
            transactionDetails.Customer__c = UserInfo.getUserId();
            transactionDetails.Order__c = ORDER_ID;
            transactionDetails.BT_TransactionId__c = String.valueOf(dataToUpdate.get('authorizationId'));
            transactionDetails.Transaction_Status__c = String.valueOf(dataToUpdate.get('transactionStatus'));
            transactionDetails.Type__c = 'Sale';
            transactionDetails.Payment_Gateway__c = 'Braintree';    
            transactionDetails.Payment_Method_Type__c = 'PayPal';
            if(dataToUpdate.containsKey('address1')) {
                String fullAddress = String.valueOf(dataToUpdate.get('address1'));
                
                if(dataToUpdate.containsKey('address2')) {
                    fullAddress += ', ' + String.valueOf(dataToUpdate.get('address2'));
                }
                transactionDetails.Billing_Street__c = fullAddress;
            }
            
            //Set the necessary City field
            if(dataToUpdate.containsKey('city')) {
                transactionDetails.Billing_City__c = String.valueOf(dataToUpdate.get('city'));
            }
            
            //Set the necessary State field
            if(dataToUpdate.containsKey('state')) {
                transactionDetails.Billing_State__c = String.valueOf(dataToUpdate.get('state'));
            }
            
            //Set the necessary Zip Code field
            if(dataToUpdate.containsKey('zipCode')) {
                transactionDetails.Billing_PostalCode__c = String.valueOf(dataToUpdate.get('zipCode'));               
            } 
            
            insert transactionDetails;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
   	//update Order record in salesforce
    public static void updateOrderDetails(Map<String, Object> dataToUpdate) {
        try {
            
            WebCart cart = (WebCart)dataToUpdate.get('cart');
            
            Order objOrder = new Order();
            objOrder.Id = String.valueOf(dataToUpdate.get('orderId'));
            objOrder.BT_Transaction_Status__c = String.valueOf(dataToUpdate.get('transactionStatus'));
            objOrder.BT_Transaction_Id__c = String.valueOf(dataToUpdate.get('authorizationId'));
            objOrder.BT_Customer_Detail__c = String.valueOf(dataToUpdate.get('customerId'));
            objOrder.Payment_Gateway__c = 'Braintree';
            objOrder.Payment_Type__c = 'PayPal';
            objOrder.BT_Customer_Legecy_Id__c = String.valueOf(dataToUpdate.get('legacyId'));
            objOrder.Total_Shipping_Tax__c = dataToUpdate.get('shippingTax') != null ? Decimal.valueOf(String.valueOf(dataToUpdate.get('shippingTax'))) : 0;         
            objOrder.Current_Shipping_Tax__c = objOrder.Total_Shipping_Tax__c; 
           
            //set shipping details
            objOrder.ShippingStreet = cart.CustomerStreet__c;
            objOrder.ShippingState = cart.Customer_State__c;
            objOrder.ShippingCity = cart.CustomerCity__c;
            objOrder.ShippingCountry = cart.CustomerCountry__c;
            objOrder.ShippingPostalCode = cart.CustomerPostalCode__c;  
            
            //set billing details
            if(dataToUpdate.containsKey('email')) {
                objOrder.BillingEmailAddress = String.valueOf(dataToUpdate.get('email'));
                //objOrder.Email__c = String.valueOf(dataToUpdate.get('email'));
            }
            
            //Set the necessary Address 1 and 2 fields
            if(dataToUpdate.containsKey('address1')) {
                String fullAddress = String.valueOf(dataToUpdate.get('address1'));
                
                if(dataToUpdate.containsKey('address2') && String.isNotEmpty(String.valueOf(dataToUpdate.get('address2')))) {
                    fullAddress += ', ' + String.valueOf(dataToUpdate.get('address2'));
                }
                objOrder.BillingStreet = fullAddress;
            }
            
            //Set the necessary City field
            if(dataToUpdate.containsKey('city')) {
                objOrder.BillingCity = String.valueOf(dataToUpdate.get('city'));
            }
            
            //Set the necessary State field
            if(dataToUpdate.containsKey('state')) {
                objOrder.BillingState = String.valueOf(dataToUpdate.get('state'));
            }
            
            //Set the necessary Zip Code field
            if(dataToUpdate.containsKey('zipCode')) {
                objOrder.BillingPostalCode = String.valueOf(dataToUpdate.get('zipCode'));
            }
            
            //Set the necessary Country field
            if(dataToUpdate.containsKey('country')) {
                objOrder.BillingCountry = String.valueOf(dataToUpdate.get('country'));
            }
            
            //Set the necessary Customer Name field
            if(dataToUpdate.containsKey('name')) {
                if(!String.isBlank(String.valueOf(dataToUpdate.get('name')))) {
                    if(!userInfo.getName().containsIgnoreCase('Guest Contact')){
                        objOrder.Email_Username__c = userInfo.getName();
                        objOrder.Customer_Name__c = String.valueOf(dataToUpdate.get('name'));
                    }else{
                        objOrder.Customer_Name__c = String.valueOf(dataToUpdate.get('name'));
                        objOrder.Email_Username__c = String.valueOf(dataToUpdate.get('name'));
                    }  
                }
            }
            
            //Set the necessary Phone fields
            if(dataToUpdate.containsKey('phone')) {
                if(!String.isBlank(String.valueOf(dataToUpdate.get('phone')))) {
                    objOrder.BillingPhoneNumber = String.valueOf(dataToUpdate.get('phone'));
                }
            }
            
            update objOrder;
             System.debug('objOrder :- '+ objOrder);
            
        } catch(Exception e) {
            System.debug('exception :-'+ e.getMessage());
            System.debug('Line Number :- '+e.getLineNumber());          
        }
    }
    
}
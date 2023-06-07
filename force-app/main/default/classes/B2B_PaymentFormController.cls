/*************************************************************************************************************************************
Name:               B2B_PaymentFormController
Purpose:            This class is used to handle payment reprocessing of a customer
Date :              22/07/2021
Created By :        Rajrishi Kaushik
Test Class Name:    B2B_PaymentFormControllerTest, B2B_CreditCardControllerMock (Mock Class), B2B_BrainTreeIntegrationMock (Mock Class)
**************************************************************************************************************************************
MODIFICATIONS – Date        |   Dev Name        |   Method      |   User Story
**************************************************************************************************************************************
                24/05/2022  |   Palak Gupta     |               |   Error handling changes- JIRA- 8617
**************************************************************************************************************************************/

public Without Sharing class B2B_PaymentFormController {
    public static String AUTHORIZATION_HEADER;
    
    public static String MERCHANT_ID;
    //Stores the Customer ID created in GraphQL
    public static String CUSTOMER_ID;
    
    //Stores the Payment Method ID crated in GraphQL
    public static String PAYMENT_ID;
    
    //ID of the Order for the current transaction
    public static String ORDER_ID;
    
    //(Account) ID of the Dealer for the transaction
    public static String DEALER_ID;
    
    //Stores the Amount for the transaction
    public static Double TOTAL_AMOUNT;
    
    public static String CART_ID;
    
    public static String lastFourDigitCC;
    
    public static BT_Token_Details__c objBTTokenDetails;
    
    public static Map<String, Object> DATA_UPDATES;
    
    public static string customerLegecyId;
    
    //for retry login when the access token is expired
    public static boolean isRetry = true;  
    
    public static string username = UserInfo.getName(); 
    
    public static List<BT_Customer_Details__c> customerDetailList = [SELECT Id, BT_CustomerId__c, Customer__c, Customer__r.ContactId 
                                                                     FROM BT_Customer_Details__c WHERE Customer__c =: UserInfo.getUserId() LIMIT 1];

    //Retrieves a Client Token from BrainTree for the Hosted Form    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> hostedFormSetup(String orderId) {
        Map<String, Object> mapReturnData = new Map<String, Object>();       
            try{
                if(!String.isBlank(orderId)){
                    Order objOrder;
                    if(!username.containsIgnoreCase('Guest')){
                        objOrder = [SELECT Id, BT_Customer_Detail__c, cart__c, cart__r.DealerId__r.Name, IsPaymentReproccessing__c, status, Updated_Order_Total__c, OrderNumber
                                      FROM Order WHERE Id =: orderId and createdBy.Name =: username LIMIT 1];   
                    }else {
                        objOrder = [SELECT Id, BT_Customer_Detail__c, cart__c, cart__r.DealerId__r.Name, IsPaymentReproccessing__c, status, Updated_Order_Total__c, OrderNumber
                                    FROM Order WHERE Id =: orderId LIMIT 1];
                    }                   

                    if(objOrder != null){          
                        if(objOrder.IsPaymentReproccessing__c == true){
                            String cartId = objOrder.cart__c;
                            mapReturnData = B2B_CreditCardController.hostedFormSetup(cartId);          
                            mapReturnData.put('cartId', (Object)cartId);   
                            mapReturnData.put('order',objOrder);
                            mapReturnData.put('totalAmount',objOrder.Updated_Order_Total__c);
                            if(!mapReturnData.containsKey('customerId')){
                                // data model changes :- BT_Customer_Detail__c is having the customer id of braintree
                                if(String.isNotEmpty(objOrder.BT_Customer_Detail__c)){
                                    String customerId = objOrder.BT_Customer_Detail__c;
                                    mapReturnData.put('customerId',(Object)customerId);
                                }                              
                            }
                            
                        }else {
                            mapReturnData.put('error', 'This order number is not available for Payment Reprocessing');
                        }
                    }else {
                        mapReturnData.put('error', 'This order number is not available for Payment Reprocessing');
                    }
                }else {
                    mapReturnData.put('error', 'Invalid Order number.');
                }
            }catch(Exception ex){
                mapReturnData.put('error', 'This order number is not available for Payment Reprocessing');
            }

        return mapReturnData; 
    }

    // vaults the Payment, and completes a Sale/Authorization Transaction
    @AuraEnabled(cacheable=false)
    public static Object processPayment(String nonce, Map<String, Object> customerData, String cartId, String orderId, String paymentType) {      
        Map<String, Object> returnData = new Map<String, Object>{'success' => false, 'error' => null};
        List<Error__c> lstErrors = new List<Error__c>();
        
        if(!String.isBlank(cartId)) { 
            DATA_UPDATES = new Map<String, Object>();
            DATA_UPDATES.put('customerData', customerData);
            DATA_UPDATES.put('isNewPayment', true);
            DATA_UPDATES.put('paymentType',paymentType);
            ORDER_ID = orderId; 
            CART_ID = cartId;
            setTotalAmount(orderId);
            setMerchantAndDealerID(cartId);
            
            if(customerData.containsKey('isSaveNewPaymentMethod') && (Boolean)customerData.get('isSaveNewPaymentMethod') == true){
                DATA_UPDATES.put('isSaveNewPaymentMethod', true);
            }
            //If Merchant ID or Access Token is null, we cannot proceed with request
            if(String.isBlank(MERCHANT_ID)) {
                //Error while accessing the Token and/or Merchant ID
                returnData.put('error', Label.BT_Merchant_Id_Error_Message);
                //Log into error object.
                Error__c objError = createErrorRecord(Label.BT_Merchant_Id_Error_Name, ORDER_ID , Label.BT_Merchant_Id_Error_Message, 'processPayment',
                                                  CART_ID, DEALER_ID, '', '', null);            
                lstErrors.add(objError);                
            }else {                                              
                String customerId = '';
                if(customerData != null && customerData.containsKey('customerId')){
                    customerId = String.valueOf(customerData.get('customerId'));
                }
                 
                if(!String.isBlank(customerId) && paymentType == 'Credit Card') {
                    
                    //Vault the Payment Method for the nonce and the newly created Customer
                    Map<String, Object> result = B2B_CreditCardController.vaultPaymentMethod(nonce, customerId);                    
                    //Capture cardholderName
                    if(result != null && result.containsKey('cardholderName')){
                        DATA_UPDATES.put('cardholderName', String.valueOf(result.get('cardholderName')));
                    }
                    
                    //Capture brandCode
                    if(result != null && result.containsKey('brandCode')){
                        DATA_UPDATES.put('brandCode', String.valueOf(result.get('brandCode')));
                    }
                    
                    //Capture expirationMonth
                    if(result != null && result.containsKey('expirationMonth')){
                        DATA_UPDATES.put('expirationMonth', String.valueOf(result.get('expirationMonth')));
                    }
                    
                    //Capture expirationYear
                    if(result != null && result.containsKey('expirationYear')){
                        DATA_UPDATES.put('expirationYear', String.valueOf(result.get('expirationYear')));
                    }
                    
                    //Capture CC Last4
                    if(result != null && result.containsKey('last4')){
                        DATA_UPDATES.put('last4', String.valueOf(result.get('last4')));
                        lastFourDigitCC = String.valueOf(result.get('last4'));
                    }
                    
                    String paymentToken;
                    //Capture CC uniqueNumberIdentifier
                    if(result != null && result.containsKey('uniqueNumberIdentifier') && !username.contains('Guest')){
                        if(customerData.containsKey('customerId') && DATA_UPDATES.containsKey('isSaveNewPaymentMethod')){
                            String uniqueNumber = String.valueOf(result.get('uniqueNumberIdentifier'));
                            List<BT_Payment_Method__c> lstPayments = [SELECT Id, Payment_Method_Token__c, BT_Customer_Details__c, Unique_Number_Identifier__c 
                                                                      FROM BT_Payment_Method__c 
                                                                      WHERE Is_In_My_Payment__c = true AND Unique_Number_Identifier__c =: uniqueNumber AND BT_Customer_Details__r.BT_CustomerId__c =: customerId]; 
                            if(!lstPayments.IsEmpty()){
                                DATA_UPDATES.put('PaymentSFId', lstPayments[0].Id);
                                paymentToken = lstPayments[0].Payment_Method_Token__c;
                            }
                        }
                        DATA_UPDATES.put('uniqueNumberIdentifier', String.valueOf(result.get('uniqueNumberIdentifier')));
                    }
                    //if payment method is duplicate then submit the pre-authorization request with the old matching credit card
                    if(String.isNotEmpty(paymentToken)){
                        returnData.put('errorReason', 'Duplicate Card');
                        if(result != null && result.containsKey('id')){
                            B2B_BrainTreeUtils.deleteBTVaultPaymentMethod(String.valueOf(result.get('id')));
                        }  
                        //submitAuthorizationRequest(customerId, paymentToken, returnData);
                    }
                    //If the request was successful, submit the pre-authorization request with the new Customer and Payment Method
                    else if(result != null && result.containsKey('id')) {  
                        //Store the Payment ID for a post-transaction update                      
                        returnData = submitAuthorizationRequest(customerId, String.valueOf(result.get('id')), '', returnData);
                    } else if(result != null){
                        
                        //Error occurred while vaulting the Payment
                        //Log into error object. 
                        //added by Rajrishi on 10 Nov 2021
                        if(result.containsKey('gatewayRejectionReason')){
                            returnData.put('errorReason', result.get('gatewayRejectionReason'));
                        }
                        //added by Rajrishi on 10 Nov 2021
                        if(result.containsKey('CCTypeError')){
                            returnData.put('error', result.get('CCTypeError'));
                        }else {
                            returnData.put('error', 'An error occurred while processing the Payment (auth).');
                        }
                        
                        Error__c objError = createErrorRecord(Label.BT_Vault_Error_Name, ORDER_ID , Label.BT_Vault_Error_Message, 'processPayment',CART_ID, DEALER_ID, '', '', null);            
                        lstErrors.add(objError);                    
                    }
                } else if(!String.isBlank(customerId) && paymentType == 'PayPal'){
                    submitAuthorizationRequest(customerId, '', nonce, returnData);
                }else {
                    //Error while creating the Customer
                    //Log into error object.
                    returnData.put('error', 'An error occurred. Please review and validate the entered information.');                
                    Error__c objError = createErrorRecord(Label.BT_Customer_Id_Error_Name, ORDER_ID , Label.BT_Customer_Id_Error_Message, 'processPayment', 
                                                  CART_ID, DEALER_ID, '', '', null);            
                    lstErrors.add(objError);
                } 
            }
        }else{            
            //Log into error object.
            returnData.put('error', 'An error occurred while processing the Order, please try again later or contact your Honda dealer.');              
            Error__c objError = createErrorRecord(Label.BT_Cart_Id_Error_Name, ORDER_ID , Label.BT_Cart_Id_Error_Message, 'processPayment', 
                                                  CART_ID, DEALER_ID, '', '', null);            
            lstErrors.add(objError);
        }     
        
        //insert error record if any error occured
        if(!lstErrors.isEmpty())
            insert lstErrors;
        
        //update the BT Token Details if new data is available. 
        if(objBTTokenDetails != null)
            update objBTTokenDetails;
        
        return returnData;
    }

    //Update By: Palak Gupta: 24/05/2022(Error handling changes- JIRA- 8617) 
    //Calls out to the Middleware to perform the pre-authorization
    @TestVisible
    private static Map<String, Object> submitAuthorizationRequest(String customerId, String paymentToken,String paypalNonce, Map<String, Object> returnData) {
        //Need to set the Authorization Header to be the Dealer's Access Token for this request
        if(isRetry == true){
            setDealerAuthorizationHeader(); 
        }
        
        if(AUTHORIZATION_HEADER != null){
            try {
                if(String.isNotEmpty(paymentToken)){
                    DATA_UPDATES.put('paymentId', paymentToken);
                }                   
                Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
                //changes for HDMP-8731 :- calling the updated sale:transaction API for PayPal and CC.
                //making callout to preAuth for authorizing the transaction
                String preAuthResponse = B2B_BrainTreeIntegration.braintreeTransactionPreAuth(customerID, MERCHANT_ID, AUTHORIZATION_HEADER, String.valueOf(TOTAL_AMOUNT), paymentToken, paypalNonce);                 
                B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parse(preAuthResponse);
                if(objBrainTreeTransactionResponse.status == 200) { 
                    String transactionId = objBrainTreeTransactionResponse.transactionBT.id;
                    returnData = requestPostAuth(transactionId, customerID, returnData);                                    
                }else {
                    String authError = objBrainTreeTransactionResponse.errorMessage;
                    if(authError.contains('authenticationError') && isRetry == true){
                        isRetry = false;
                        BT_Token_Details__c btDetails = [SELECT Id, RefreshToken__c, RefreshTokenExpiresAT__c 
                                                         FROM BT_Token_Details__c 
                                                         WHERE Account__c = :DEALER_ID];
                        if(Datetime.now() < btDetails.RefreshTokenExpiresAT__c) {                                   
                            requestNewAccessToken(btDetails);
                            submitAuthorizationRequest(customerId, paymentToken, paypalNonce, returnData);
                        }                              
                    }else{
                        createOrderTransactionRecord(false);
                        returnData.put('error', 'An error occurred in pre authorizing of the Payment.'); 
                        if(String.isNotBlank(paymentToken) && DATA_UPDATES.containsKey('isNewPayment')){
                            //changes for HDMP-8730 :- in deletePaymentMethod method we are calling the new set of API's 
                            //to delete the payment method and address from BT
                            deletePaymentMethod(customerId, paymentToken);
                        }
                        //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                        Long afterAPI = B2B_Util.fetchCurrentTime();
                        Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);// to calculate duration time between before API and after API
                        String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                        String severity;
                        String errorType;
                        //Below custom metadata provide the information related to Severity and error type based on the feature
                        Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                        if(errorRecords.containskey(String.valueOf(objBrainTreeTransactionResponse.status))){
                            severity= errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).severity__c;
                            errorType=errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).error_Type__c;
                        }
                        else{
                            severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                            errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                        }
                        Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID,
                                                                          'B2B_PaymentFormController', String.valueOf(objBrainTreeTransactionResponse.status), 
                                                                          errorType, '', 'braintreeTransactionPreAuth', true, ORDER_ID, '', '', durationTime,severity , 
                                                                          'Request:'+objBrainTreeTransactionResponse.requestBody, 'Response:'+objBrainTreeTransactionResponse.responseBody);
                    //HDMP-8617- End of changes
                    }
                    
                }          
            } catch(Exception ex) {              
                returnData.put('error', 'An exception occured in pre authorizing the Payment.'); 
                //Create a error record
                Error__c objError = createErrorRecord('Exception Occured', ORDER_ID , ex.getMessage(), 'submitAuthorizationRequest', CART_ID, 
                                                      DEALER_ID, ex.getStackTraceString(), ex.getTypeName(), Double.valueOf(ex.getLineNumber()));
                insert objError;
            } 
        } else {
            returnData.put('error', 'An Error occured while Authorizing the Dealer, please Contact to Honda Dealer'); 
        }       
        return returnData;
    }
    
    //Update By: Palak Gupta: 24/05/2022(Error handling changes- JIRA- 8617) 
    public static Map<String, Object> requestPostAuth(String transactionId, String customerID, Map<String, Object> returnData){     
       
        try{
            Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
            String postAuthResponse = B2B_BrainTreeIntegration.braintreeTransactionPostAuth(customerID, MERCHANT_ID, transactionId, String.valueOf(TOTAL_AMOUNT), AUTHORIZATION_HEADER);
            B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parse(postAuthResponse);
            List<Dealer_Email__c> lstDealerEmails = new List<Dealer_Email__c>();
            Order objOrder = [SELECT Id, Updated_Shipping__c, Account.Name, Account.PoIId__c FROM Order WHERE Id =: ORDER_ID];
            if(objBrainTreeTransactionResponse.status == 200){
                
                if(DATA_UPDATES.containsKey('isNewPayment') && (Boolean)DATA_UPDATES.get('isNewPayment') == true){   
                    //create a payment method record
                    if(!username.containsIgnoreCase('Guest') && DATA_UPDATES.containsKey('isSaveNewPaymentMethod') && !customerDetailList.isEmpty()){
                        B2B_CreditCardController.ORDER_ID = ORDER_ID;
                        B2B_CreditCardController.CUSTOMER_SF_ID = customerDetailList[0].Id;
                        B2B_CreditCardController.createPaymentDetailsRecord(DATA_UPDATES);
                    }
                    //delete if it's a one time credit card
                    else {
                        String paymentTokenId = (String)DATA_UPDATES.get('paymentId');
                        deletePaymentMethod(customerID, paymentTokenId);                      
                    }
                    
                }
                System.debug('DATA_UPDATES : '+DATA_UPDATES);
                //when retry payment, delete one time credit card after post auth from SF and BT
                if(DATA_UPDATES.containsKey('isRetryPayment') && (Boolean)DATA_UPDATES.get('isRetryPayment') == true && !DATA_UPDATES.containsKey('paymentSfId')){  
                    String paymentTokenId = DATA_UPDATES.containsKey('paymentId') ? (String)DATA_UPDATES.get('paymentId') : '';
                    deletePaymentMethod(customerID, paymentTokenId);
                }

                String dealerLocatorResponse = '';
                //send emails to dealer
                if(objOrder.Account.Name.contains('Honda')){
                    dealerLocatorResponse = B2B_BrainTreeUtils.dealerLocatorService('A',objOrder.Account.PoIId__c);
                }else {
                    dealerLocatorResponse = B2B_BrainTreeUtils.dealerLocatorService('B',objOrder.Account.PoIId__c);
                    system.debug('Ravis response dealerLocatorResponse'+dealerLocatorResponse);
                }                               
                if(String.isNotEmpty(dealerLocatorResponse)){
                    B2B_BrainTreeUtils.DealerServiceResponse objResponse = (B2B_BrainTreeUtils.DealerServiceResponse) JSON.deserialize(dealerLocatorResponse, B2B_BrainTreeUtils.DealerServiceResponse.class);
                    system.debug('Ravis response'+objResponse);
                    if(objResponse.isError == false && String.isNotEmpty(objResponse.dealerEmails)){
                        List<String> lstEmails = objResponse.dealerEmails.split(';');             
                        for(String email : lstEmails){  
                            Dealer_Email__c objDealerEmail = new Dealer_Email__c();
                            objDealerEmail.Email__c = email;
                            objDealerEmail.Order__c = ORDER_ID;
                            objDealerEmail.isPaymentReprocess__c = true;
                            objDealerEmail.IsShipToHome__c = (objOrder.Updated_Shipping__c != null && objOrder.Updated_Shipping__c > 0) ? true : false;
                            lstDealerEmails.add(objDealerEmail);
                        }
                    }
                }
                               
                //create transaction record
                BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();
                objBTTransactionDetails.BT_TransactionId__c = objBrainTreeTransactionResponse.transactionBT.id;
                objBTTransactionDetails.Type__c = objBrainTreeTransactionResponse.transactionBT.type;
                objBTTransactionDetails.Name = 'Reprocessed Transaction';
                objBTTransactionDetails.Order__c = ORDER_ID; 
                
                // changes for HDMP-8720 starts
                if(DATA_UPDATES.containsKey('brandCode')){
                    String brandCode = String.valueOf(DATA_UPDATES.get('brandCode'));
                    if(brandCode.containsIgnoreCase('VISA')){
                        objBTTransactionDetails.Payment_Method_Type__c  = 'Visa';
                    }else if(brandCode.containsIgnoreCase('DISCOVER')){
                        objBTTransactionDetails.Payment_Method_Type__c =  'Discover';
                    }else if(brandCode.containsIgnoreCase('AMERICAN_EXPRESS')){
                        objBTTransactionDetails.Payment_Method_Type__c  = 'Amex';
                    }else if(brandCode.containsIgnoreCase('MASTERCARD')){
                        objBTTransactionDetails.Payment_Method_Type__c  = 'Mastercard';
                    }
                }                
                
                //for logged in user and Retry
                if(DATA_UPDATES.containsKey('type')){
                    //objBTTransactionDetails.Payment_Method_Type__c = String.valueOf(DATA_UPDATES.get('type'));
                }
                
                // when customer is trying to pay with saved payment method
                if(DATA_UPDATES.containsKey('isMyPayment') && (Boolean)DATA_UPDATES.get('isMyPayment') == true){  
                    // set the brand code on order for saved credit card
                    if(DATA_UPDATES.containsKey('type')){
                        String brandCode = String.valueOf(DATA_UPDATES.get('type'));
                        if(brandCode == 'Credit Card - Visa'){
                            objBTTransactionDetails.Payment_Method_Type__c = 'Visa';
                        }else if(brandCode == 'Credit Card - Discover'){
                            objBTTransactionDetails.Payment_Method_Type__c = 'Discover';
                        }else if(brandCode == 'Credit Card - Amex'){
                            objBTTransactionDetails.Payment_Method_Type__c = 'Amex';
                        }else if(brandCode == 'Credit Card - Mastercard'){
                            objBTTransactionDetails.Payment_Method_Type__c = 'Mastercard';
                        }
                    }            
                }
                
                if(DATA_UPDATES.containsKey('paymentType') && String.valueOf(DATA_UPDATES.get('paymentType')) == 'PayPal'){
                    objBTTransactionDetails.Payment_Method_Type__c = 'PayPal';
                }
                if(DATA_UPDATES.containsKey('cardholderName')){
                    objBTTransactionDetails.Cardholder_Name__c = String.valueOf(DATA_UPDATES.get('cardholderName'));
                }
                if(String.isNotEmpty(lastFourDigitCC)){
                    objBTTransactionDetails.Credit_Card_Number__c = lastFourDigitCC;
                }                
                
                if(DATA_UPDATES.containsKey('customerData')) { 
                    Map<String, Object> customerData = (Map<String, Object>)DATA_UPDATES.get('customerData');
                    //Set the necessary Address 1 and 2 fields
                    if(customerData.containsKey('address1')) {
                        String fullAddress = String.valueOf(customerData.get('address1'));
                        
                        if(customerData.containsKey('address2')) {
                            fullAddress += ', ' + String.valueOf(customerData.get('address2'));
                        }
                        
                        objBTTransactionDetails.Billing_Street__c = fullAddress;
                    }
                    
                    //Set the necessary City field
                    if(customerData.containsKey('city')) {
                        objBTTransactionDetails.Billing_City__c = String.valueOf(customerData.get('city'));
                    }
                    
                    //Set the necessary State field
                    if(customerData.containsKey('state')) {
                        objBTTransactionDetails.Billing_State__c = String.valueOf(customerData.get('state'));
                    }
                    
                    //Set the necessary Zip Code field
                    if(customerData.containsKey('zipCode')) {
                        objBTTransactionDetails.Billing_PostalCode__c = String.valueOf(customerData.get('zipCode'));               
                    } 
                }
                objBTTransactionDetails.Payment_Method_Token__c = DATA_UPDATES.containsKey('paymentId') ? String.valueOf(DATA_UPDATES.get('paymentId')) : '';
                objBTTransactionDetails.Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                objBTTransactionDetails.Payment_Gateway__c = 'Braintree';
                objBTTransactionDetails.Customer__c = UserInfo.getUserId();
                // changes for HDMP-8720 ends
                insert objBTTransactionDetails;
                
                //update order 
                updateOrder(objBrainTreeTransactionResponse.transactionBT.status, objBrainTreeTransactionResponse.transactionBT.id);
                
                if(!lstDealerEmails.isEmpty()){
                    insert lstDealerEmails;
                }
                returnData.put('success', true);
                returnData.put('successMessage', Label.BT_Payment_Reprocessing_Sucess_Message);
            }else {
                if(DATA_UPDATES.containsKey('paymentId') && DATA_UPDATES.containsKey('isNewPayment')){
                    //changes for HDMP-8730 :- in deletePaymentMethod method we are calling the new set of API's 
                    //to delete the payment method and address from BT
                    deletePaymentMethod(customerID, String.valueOf(DATA_UPDATES.get('paymentId')));
                }
                createOrderTransactionRecord(false);
                
                //add error object
                returnData.put('error', 'An error occurred while post authorizing the Payment.'); 
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);// to calculate duration time between before API and after API
                String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                String severity;
                String errorType;
                //Below custom metadata provide the information related to Severity and error type based on the feature
                Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(objBrainTreeTransactionResponse.status))){
                    severity= errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).severity__c;
                    errorType=errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).error_Type__c;
                }
                else{
                    severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID, 'B2B_PaymentFormController', String.valueOf(objBrainTreeTransactionResponse.status), errorType, '', 'requestPostAuth', true, ORDER_ID, '', '', durationTime , severity, 'Request:'+objBrainTreeTransactionResponse.requestBody, 'Response:'+objBrainTreeTransactionResponse.responseBody);
                //HDMP-8617- End of changes
            }           
        }catch(Exception ex){
            //add exception
            //Create a error record
            Error__c objError = createErrorRecord('Exception Occured', ORDER_ID , ex.getMessage(), 'requestPostAuth', CART_ID, 
                                                  DEALER_ID, ex.getStackTraceString(), ex.getTypeName(), Double.valueOf(ex.getLineNumber()));
            insert objError;
            returnData.put('error', 'An exception occurred while post authorizing the Payment.'); 
            returnData.put('error', ex.getMessage() + 'Line Number : ' + ex.getLineNumber() + ' stack trace : '+ ex.getStackTraceString()); 
        } 
        return returnData;
    }
    
    //@future
    public static void updateOrder(String status, String transId){
        WebCart objWebCart = [SELECT Id, Pickup_Dealer__c FROM WebCart WHERE Id =: CART_ID LIMIT 1];
        //update order
        Order objOrder = new Order();
        objOrder.Id = ORDER_ID;        
        if(objWebCart.Pickup_Dealer__c == true){
            objOrder.Status = 'READY FOR PICKUP';
        }else {  
            objOrder.Shipped_Date__c = System.now();
            objOrder.Status = 'ORDER COMPLETE - SHIPPED';
        }
        objOrder.BT_Transaction_Status__c = status;
        objOrder.BT_Transaction_Id__c = transId;
        objOrder.IsPaymentReproccessing__c = false;
        objOrder.Send_Email_To_Customer__c = true;
        objOrder.CC_Last4__c = lastFourDigitCC;
        
        // when customer is trying to pay with saved payment method
        if(DATA_UPDATES.containsKey('isMyPayment') && (Boolean)DATA_UPDATES.get('isMyPayment') == true){  
            // set the brand code on order for saved credit card
            if(DATA_UPDATES.containsKey('type')){
                String brandCode = String.valueOf(DATA_UPDATES.get('type'));
                if(brandCode == 'Credit Card - Visa'){
                    objOrder.Payment_Type__c  = 'Visa';
                }else if(brandCode == 'Credit Card - Discover'){
                    objOrder.Payment_Type__c =  'Discover';
                }else if(brandCode == 'Credit Card - Amex'){
                    objOrder.Payment_Type__c  = 'Amex';
                }else if(brandCode == 'Credit Card - Mastercard'){
                    objOrder.Payment_Type__c  = 'Mastercard';
                }
            }            
        }
        
        if(DATA_UPDATES.containsKey('brandCode')){
            String brandCode = String.valueOf(DATA_UPDATES.get('brandCode'));
            if(brandCode.containsIgnoreCase('VISA')){
                objOrder.Payment_Type__c  = 'Visa';
            }else if(brandCode.containsIgnoreCase('DISCOVER')){
                objOrder.Payment_Type__c =  'Discover';
            }else if(brandCode.containsIgnoreCase('AMERICAN_EXPRESS')){
                objOrder.Payment_Type__c  = 'Amex';
            }else if(brandCode.containsIgnoreCase('MASTERCARD')){
                objOrder.Payment_Type__c  = 'Mastercard';
            }
        }
        
        if(DATA_UPDATES.containsKey('paymentType') && String.valueOf(DATA_UPDATES.get('paymentType')) == 'PayPal'){
            objOrder.CC_Last4__c = null;
            objOrder.Payment_Type__c = 'PayPal';
            objOrder.Payment_Method_Token__c = null;           
        }else {
            objOrder.Payment_Method_Token__c = String.valueOf(DATA_UPDATES.get('paymentId'));            
        }
        
        if(!DATA_UPDATES.containsKey('isRetryPayment')){
            setBillingAddressInformation(objOrder, DATA_UPDATES);
        }
      
        update objOrder;
        
        String orderTranId = createOrderTransactionRecord(true);
        createInvoiceRecords(orderTranId);
    }    
     
    
    // method to create the order_Transaction record
     @TestVisible
    private static String createOrderTransactionRecord(Boolean isSuccess){
        // REMAN-169 Saravanan LTIM Added Total_Core_Charge_Current_Quantity__c,Total_Core_Charge_Current_Amount__c , Total_Core_Charge_Current_Tax__c,Total_Core_Charge_Return_Amount__c, Total_Core_Charge_Return_Quantity__c,Total_Core_Charge_Return_Tax__c,Delivery_Type__c,Quantity__c
        //  REMAN-169 Saravanan LTIM Added Product_type__c,Description in Sub Query 
        Order objOrder = [SELECT Id, BT_Transaction_Id__c, Current_Shipping_Tax__c, Total_Restocking_Fees__c, Total_Restocking_Fee_Tax__c, Updated_Shipping__c,Updated_Order_Total__c,Updated_Total_Tax__c,                       
                          (SELECT Id, Updated_Quantity__c, ListPrice, Total_Current_Product_Tax__c,Product_type__c,Description FROM OrderItems WHERE Type != 'Delivery Charge')
                          Total_Core_Charge_Current_Quantity__c,Total_Core_Charge_Current_Amount__c , Total_Core_Charge_Current_Tax__c,
                                 Total_Core_Charge_Return_Amount__c, Total_Core_Charge_Return_Quantity__c,Total_Core_Charge_Return_Tax__c,
                                 Delivery_Type__c,Quantity__c
                          FROM Order 
                          WHERE Id =: ORDER_ID];
        if(objOrder != null){
            Order_Transaction__c objOrderTransaction = new Order_Transaction__c();
            objOrderTransaction.Order__c = ORDER_ID;
            objOrderTransaction.Order_Transaction_Status__c = isSuccess == true ? 'Success' : 'Failure';
            objOrderTransaction.Order_Transaction_Type__c = 'Resolved Payment';
            objOrderTransaction.Is_Adjustment__c = false;
            objOrderTransaction.Total_Restocking_Fee__c = objOrder.Total_Restocking_Fees__c;
            objOrderTransaction.Total_Restocking_Fee_Tax__c = objOrder.Total_Restocking_Fee_Tax__c;      
            objOrderTransaction.Total_Post_Adjustment_Shiping_Charge__c = objOrder.Updated_Shipping__c;      
            objOrderTransaction.Total_Post_adjustment_Shipping_Tax__c = objOrder.Current_Shipping_Tax__c;
            objOrderTransaction.Post_Adjustment_Total_Amount__c = objOrder.Updated_Order_Total__c;
            objOrderTransaction.Post_Adjustment_Total_Tax__c = objOrder.Updated_Total_Tax__c;
            objOrderTransaction.Adjustment_Date_Time__c = System.now();

            //Saravanan LTIM Added for REMAN-169 Payment Issue Resolved (Successful) - Retry Credit Card

            objOrderTransaction.Total_Post_Adjustment_Core_Charge_Qty__c = objOrder.Total_Core_Charge_Current_Quantity__c ;
            objOrderTransaction.Total_Post_Adjustment_Core_Charge_Amount__c = objOrder.Total_Core_Charge_Current_Amount__c ;
            objOrderTransaction.Total_Post_Adjustment_Core_Charge_Tax__c = objOrder.Total_Core_Charge_Current_Tax__c ;

            //Saravanan LTIM Added for REMAN-169 Payment Issue Resolved (Successful) - Retry Credit Card

            
            insert objOrderTransaction;
            
            List<Order_Transaction_Item__c> lstOrderTransactionItems = new List<Order_Transaction_Item__c>();
            for(OrderItem objOrderItem : objOrder.OrderItems){
                Order_Transaction_Item__c objOrderTranItem = new Order_Transaction_Item__c();
                objOrderTranItem.Order_Item__c = objOrderItem.Id;
                objOrderTranItem.Order_Transaction__c = objOrderTransaction.Id;                
                objOrderTranItem.Post_Adjustment_Quantity__c = objOrderItem.Updated_Quantity__c;                
                objOrderTranItem.Post_Adjustment_Extended_Price__c = objOrderItem.Updated_Quantity__c * objOrderItem.ListPrice;
                objOrderTranItem.Total_Post_Adjustment_Product_Tax__c = objOrderItem.Total_Current_Product_Tax__c;
                objOrderTranItem.Adjustment_Date_Time__c = System.now();
                objOrderTranItem.AK_Order_Transaction_Item__c = objOrderItem.Id + '' + objOrderTransaction.Id; //Added by Ravi Prasad to populate AK Order Transaction Item as part of HDMP-12002

                //Saravanan LTIM Added for REMAN-169 Payment Issue Resolved (Successful) - Retry Credit Card

                if(objOrderItem.Product_type__c == Label.B2B_Product_Code_Core_Charges || objOrderItem.Description.contains(Label.B2B_Reman_Part_Identification_Label)){

                    objOrderTranItem.AK_Order_Transaction_Item__c = '';

                    objOrderTranItem.Product_type__c = objOrderItem.Description.contains(Label.B2B_Reman_Part_Identification_Label) ? 'Part' : Label.B2B_Product_Code_Core_Charges;

                    objOrderTranItem.AK_Order_Transaction_Item__c  =  objOrderItem.Description.contains(Label.B2B_Reman_Part_Identification_Label) ? objOrderTransaction.Id +'~' + objOrderItem.Id +'~'+'Part' : objOrderTransaction.Id +'~' + objOrderItem.Id +'~'+objOrderItem.Product_Type__c ;

                }

                //Saravanan LTIM Added for REMAN-169 Payment Issue Resolved (Successful) - Retry Credit Card


                lstOrderTransactionItems.add(objOrderTranItem);
            }
            insert lstOrderTransactionItems;
            
            List<BT_Transaction_Details__c> lstBTTrans = [SELECT Id, Order_Transaction__c 
                                                          FROM BT_Transaction_Details__c 
                                                          WHERE BT_TransactionId__c =: objOrder.BT_Transaction_Id__c LIMIT 1];
            if(!lstBTTrans.isEmpty()){
                lstBTTrans[0].Order_Transaction__c = objOrderTransaction.Id;
                update lstBTTrans;
            }
            return objOrderTransaction.Id;
        }  
        return null;
    }
      
    private static void createInvoiceRecords(String orderTranId) {
        String singleOrderId;
        
        List<Invoice__c> lstInvoice = new List<Invoice__c>();
        List<Invoice_Item__c> lstInvoiceItem = new List<Invoice_Item__c>();
        //Cart_Shipping_Customer_Name__c,Delivery_Type__c
          // REMAN-173 Saravanan LTIM Added Total_Core_Charge_Current_Quantity__c,Total_Core_Charge_Current_Amount__c , Total_Core_Charge_Current_Tax__c,Total_Core_Charge_Return_Amount__c, Total_Core_Charge_Return_Quantity__c,Total_Core_Charge_Return_Tax__c,Delivery_Type__c,Quantity__c
        //  REMAN-173 Saravanan LTIM Added Product_type__c,Description in Sub Query 
        Order objOrder = [SELECT Id, Delivery_Types__c, Shipping_Customer_Name__c, OrderNumber, BT_Transaction_Id__c, OrderedDate, BT_Customer_Detail__c, Payment_Method_Token__c, Updated_Order_Total__c,   
                          AccountId, Status, Updated_Shipping__c, Updated_Total_Tax__c, ShipToContactId,BillingEmailAddress, Customer_Name__c,OrderReferenceNumber,
                          BT_Transaction_Status__c, IsError__c, cart__c, Send_Email_To_Customer__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, 
                          BillingCountry, BillingAddress, BillingPhoneNumber, CC_Last4__c, Payment_Type__c,Total_Shipping_Tax__c,Current_Shipping_Tax__c,
                          ShippingAddress, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                          (SELECT Id, TotalPrice, Dealer_Installation_Price__c, Delta_Installation_Price__c, Delta_Quantity__c,Updated_Quantity__c,
                           Return_Quantity__c, Quantity, ListPrice, Total_Tax__c, Product_SKU__c, Cart_Item_Product_Name__c, Op_Code__c,Product_type__c,Description FROM OrderItems WHERE Type != 'Delivery Charge') ,
                           Total_Core_Charge_Current_Quantity__c,Total_Core_Charge_Current_Amount__c , Total_Core_Charge_Current_Tax__c,Total_Core_Charge_Return_Amount__c, Total_Core_Charge_Return_Quantity__c,Total_Core_Charge_Return_Tax__c,Delivery_Type__c,Quantity__c
                          FROM Order 
                          WHERE Id =: ORDER_ID];
        if(objOrder.Id != null){
            singleOrderId = objOrder.Id;
            Account objAccount = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, Email__c, Phone FROM Account WHERE Id =: objOrder.AccountId];
            
            List<BT_Transaction_Details__c> lstBTTrans = [SELECT Id, Order_Transaction__c 
                                                          FROM BT_Transaction_Details__c 
                                                          WHERE BT_TransactionId__c =: objOrder.BT_Transaction_Id__c LIMIT 1];
            String BTTransactionId = (!lstBTTrans.isEmpty()) ? lstBTTrans[0].Id : null;
            Invoice__c invoiceObj = new Invoice__c();
            invoiceObj.Total_Shipping_Amount__c = objOrder.Updated_Shipping__c;
            invoiceObj.Total_Shipping_Tax__c = objOrder.Current_Shipping_Tax__c;
            invoiceObj.Total_Invoice_Price__c = (objOrder.Updated_Order_Total__c != null ? objOrder.Updated_Order_Total__c : 0); 
            invoiceObj.Total_Invoice_Tax__c = (objOrder.Updated_Total_Tax__c != null ? objOrder.Updated_Total_Tax__c : 0);
            invoiceObj.Total_Pre_Tax_Invoice_Amount__c = (objOrder.Updated_Order_Total__c != null ? objOrder.Updated_Order_Total__c : 0) - (objOrder.Updated_Total_Tax__c != null ? objOrder.Updated_Total_Tax__c : 0);
            invoiceObj.Account__c = objOrder.AccountId;
            invoiceObj.CC_Last4__c = objOrder.CC_Last4__c;
            invoiceObj.BillingStreet__c = objOrder.BillingStreet;
            invoiceObj.BillingCity__c = objOrder.BillingCity;
            invoiceObj.BillingCountry__c = objOrder.BillingCountry;
            invoiceObj.BillingState__c = objOrder.BillingState;
            invoiceObj.Billing_Customer_Name__c = objOrder.Customer_Name__c;
            invoiceObj.Order_EmailAddress__c = objOrder.BillingEmailAddress;
            invoiceObj.BillingPhoneNumber__c = objOrder.BillingPhoneNumber;
            invoiceObj.BillingPostalCode__c = objOrder.BillingPostalCode;
            invoiceObj.ShippingStreet__c = objOrder.ShippingStreet ;
            invoiceObj.ShippingCity__c = objOrder.ShippingCity;
            invoiceObj.ShippingCountry__c = objOrder.ShippingCountry;
            invoiceObj.ShippingPostalCode__c = objOrder.ShippingPostalCode;
            invoiceObj.ShippingState__c = objOrder.ShippingState;
            invoiceObj.Shipping_Customer_Name__c = objOrder.Shipping_Customer_Name__c;
            invoiceObj.Dealer_Name__c = objAccount.Name;
            invoiceObj.Dealer_Street__c = objAccount.BillingStreet;
            invoiceObj.Dealer_City__c = objAccount.BillingCity;
            invoiceObj.Dealer_State__c = objAccount.BillingState;
            invoiceObj.Dealer_Postal_Code__c = objAccount.BillingPostalCode;
            invoiceObj.Dealer_Phone_Number__c = objAccount.Phone;
            invoiceObj.Dealer_Email_Address__c = objAccount.Email__c;
            invoiceObj.Invoice_Date__c = System.now();
            invoiceObj.Ordered_Date__c = objOrder.OrderedDate;
            invoiceObj.BT_Transaction_Details__c = BTTransactionId;
            invoiceObj.Order__c = objOrder.Id;
            invoiceObj.Invoice_Type__c = B2B_IntegrationConstants.ORDER_INVOICE;
            invoiceObj.Order_Reference_Number__c = String.isNotEmpty(objOrder.OrderReferenceNumber) ? objOrder.OrderReferenceNumber : objOrder.OrderNumber;
            invoiceObj.Payment_Method_Type__c = objOrder.Payment_Type__c;
            invoiceObj.Delivery_Type__c = objOrder.Delivery_Types__c;
            invoiceObj.Order_Transaction__c = orderTranId;

            //Saravanan LTIM Added for REMAN-173 Payment Issue Resolved (Successful) - Retry Credit Card

            invoiceObj.Total_Core_Charge_Amount__c  = objOrder.Total_Core_Charge_Current_Amount__c;
            invoiceObj.Total_Core_Charge_Quantity__c  = objOrder.Total_Core_Charge_Current_Quantity__c;
            invoiceObj.Total_Core_Charge_Tax__c  = objOrder.Total_Core_Charge_Current_Tax__c;

            //Saravanan LTIM Added for REMAN-173 Payment Issue Resolved (Successful) - Retry Credit Card

            lstInvoice.add(invoiceObj);
            for(OrderItem objOrderItem : objOrder.OrderItems){
                Invoice_Item__c invItemObj = new Invoice_Item__c();
                invItemObj.Unit_Price__c = objOrderItem.ListPrice;
                invItemObj.Total_Product_Tax__c = objOrderItem.Total_Tax__c;
                invItemObj.Item_Installation_Price__c = objOrderItem.Dealer_Installation_Price__c ;
                invItemObj.Total_Installation_Charge__c = objOrderItem.Dealer_Installation_Price__c ;
                invItemObj.Extended_Price__c = objOrderItem.ListPrice * objOrderItem.Updated_Quantity__c;
                invItemObj.Accessory_Op_Code__c = objOrderItem.Op_Code__c;
                invItemObj.Product_SKU__c = objOrderItem.Product_SKU__c;
                invItemObj.Item_Quantity__c = objOrderItem.Updated_Quantity__c;
                invItemObj.Product_Name__c = objOrderItem.Cart_Item_Product_Name__c ;

                // Saravanan LTIM Added for Sprint 2 - Data Rules Invoice Items Payment Issues REMAN-174
                if(objOrderItem.Product_type__c == Label.B2B_Product_Code_Core_Charges || objOrderItem.Description.contains(Label.B2B_Reman_Part_Identification_Label)){
                    invItemObj.Product_Type__c = objOrderItem.Product_Type__c;
                    invItemObj.AK_Invoice_Item__c = '@INVOICEID'+'~'+objOrderItem.Id+'~'+objOrderItem.Product_Type__c;
                
                }
                // Saravanan LTIM Ended for Sprint 2 - Data Rules Invoice Items Payment Issues REMAN-174

                lstInvoiceItem.add(invItemObj);
            }
            //insert invoice & invoice item records for order  
            if(!lstInvoice.isEmpty()){
                insert lstInvoice;
                Invoice__c invoiceObj1 = [SELECT Id, Name FROM Invoice__c WHERE Id =: lstInvoice[0].Id];
                lstInvoice[0].Invoice_Number__c = invoiceObj1.Name;
                update lstInvoice;
                
                if(!lstInvoiceItem.isEmpty()){
                    for(Invoice_Item__c itemObj : lstInvoiceItem){
                        itemObj.Invoice__c = lstInvoice[0].Id;
                        // Saravanan LTIM Added for Sprint 2 - Data Rules Invoice Items Payment Issues REMAN-174
                        itemObj.AK_Invoice_Item__c =  itemObj.AK_Invoice_Item__c!= null ? itemObj.AK_Invoice_Item__c.replace('@INVOICEID',lstInvoice[0].Id) : itemObj.AK_Invoice_Item__c;
                        // Saravanan LTIM Emded for Sprint 2 - Data Rules Invoice Items Payment Issues REMAN-174
                    }
                    insert lstInvoiceItem;
                }
            }
        }
    }
    
    //Update By: Palak Gupta: 24/05/2022(Error handling changes- JIRA- 8617) 
    // changes for HDMP-8730 :- delete the payment method and address from Braintree
    @TestVisible
    private static void deletePaymentMethod(String customerID, String paymentToken){
        Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
        // get the address id from payment method find API
        B2B_BrainTreeTransactionResponse objPaymentFindResponse = B2B_BrainTreeIntegration.braintreePaymentMethodFind(paymentToken);
        if(objPaymentFindResponse.status == 200){     
            //delete the one time payment method from BT
            B2B_BrainTreeIntegration.braintreePaymentMethodDelete(paymentToken);
            
            //delete the related address to the payment method
            B2B_BrainTreeIntegration.braintreeAddressDelete(customerLegecyId, objPaymentFindResponse.billingAddressId);                                           
        } else{
            //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
            Long afterAPI = B2B_Util.fetchCurrentTime();
            Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);// to calculate duration time between before API and after API
            String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
            String severity;
            String errorType;
            //Below custom metadata provide the information related to Severity and error type based on the feature
            Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
            if(errorRecords.containskey(String.valueOf(objPaymentFindResponse.status))){
                severity= errorRecords.get(String.valueOf(objPaymentFindResponse.status)).severity__c;
                errorType=errorRecords.get(String.valueOf(objPaymentFindResponse.status)).error_Type__c;
            }
            else{
                severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
            }
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID, 'B2B_PaymentFormController', String.valueOf(objPaymentFindResponse.status), errorType, '', 'deletePaymentMethod', true, ORDER_ID   , '', '', durationTime,severity, 'Request:'+objPaymentFindResponse.requestBody, 'Response:'+objPaymentFindResponse.responseBody);
            //HDMP-8617- End of changes
        }
    }
    
    //Sets the Access Token for the Class - leverages the existing Access Token if still valid, otherwise, attempts to request a new one via the Refresh Token
     @TestVisible
    private static void setDealerAuthorizationHeader() {
        try { 
            List<BT_Token_Details__c> lstbtDetails = [SELECT Id, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c FROM BT_Token_Details__c WHERE Account__c = :DEALER_ID];
            if(!lstbtDetails.isEmpty()){
                BT_Token_Details__c btDetails = lstbtDetails[0];
                //If true, Access Token is expired & a new one needs to be requested
                if(Datetime.now() > btDetails.AccessTokenExpiresAt__c) {
                    //Ensure refresh token is still valid
                    if(Datetime.now() < btDetails.RefreshTokenExpiresAT__c) {
                        requestNewAccessToken(btDetails);
                    } else {
                        //TODO - determine route if refresh token is expired                   
                        //Create a error record
                        AUTHORIZATION_HEADER = null;
                        Error__c objError = createErrorRecord(Label.BT_Refresh_Token_Error_Name, ORDER_ID , Label.BT_Refresh_Token_Error_Message, 
                                                              'setDealerAuthorizationHeader', CART_ID, DEALER_ID, '', '', null);
                        insert objError;
                    }
                } else {
                    AUTHORIZATION_HEADER = btDetails.AccessToken__c;
                }  
            }else {
                AUTHORIZATION_HEADER = null;
                Error__c objError = createErrorRecord(Label.BT_Token_Details_Error_Name, ORDER_ID , Label.BT_Token_Details_Error_Message, 
                                                      'setDealerAuthorizationHeader', CART_ID, DEALER_ID, '', '', null);
                insert objError;
            }           
        } catch(Exception ex) {
            System.debug(ex.getMessage()); 
            AUTHORIZATION_HEADER = null;
            Error__c objError = createErrorRecord('Exception Occured', ORDER_ID , ex.getMessage(), 'setDealerAuthorizationHeader', CART_ID, 
                                                  DEALER_ID, ex.getStackTraceString(), ex.getTypeName(), Double.valueOf(ex.getLineNumber()));
            insert objError;
        }        
    }

    //Update By: Palak Gupta: 24/05/2022(Error handling changes- JIRA- 8617) 
    //Refreshes the current Access and Refresh Tokens for the current Merchant
    @TestVisible
    private static void requestNewAccessToken(BT_Token_Details__c btDetails) {
        Long beforeAPI = DateTime.now().getTime();// HDMP-8617- This will provide initial response time
        //Request a new Access Token given the current Refresh Token
        String refreshTokenResponse = B2B_BrainTreeIntegration.getRefreshToken(MERCHANT_ID, btDetails.RefreshToken__c);
        B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();           
        objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(refreshTokenResponse, B2B_AccessTokenResponseWrapper.class);                       

        //If request was successful, store results of callout and set the Access Token 
        if(objAccessTokenResponseWrapper.status == 200){  
            objBTTokenDetails = B2B_BrainTreeUtils.checkBTTokenDetails(btDetails, objAccessTokenResponseWrapper);                                  
            AUTHORIZATION_HEADER = objAccessTokenResponseWrapper.credentials.accessToken;
        } else {
            //TODO - should non-200 responses be considered?
            //ToDo - Log in error object 
            AUTHORIZATION_HEADER = null;
            //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
            Long afterAPI = B2B_Util.fetchCurrentTime();
            Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);// to calculate duration time between before API and after API
            String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
            String severity;
            String errorType;
            //Below custom metadata provide the information related to Severity and error type based on the feature
            Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
            if(errorRecords.containskey(String.valueOf(objAccessTokenResponseWrapper.status))){
                severity= errorRecords.get(String.valueOf(objAccessTokenResponseWrapper.status)).severity__c;
                errorType=errorRecords.get(String.valueOf(objAccessTokenResponseWrapper.status)).error_Type__c;
            }
            else{
                severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
            }
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID, 'B2B_PaymentFormController', String.valueOf(objAccessTokenResponseWrapper.status), errorType, '', 'requestNewAccessToken', true, ORDER_ID   , '', '', durationTime, severity, 'Request:'+objAccessTokenResponseWrapper.requestBody, 'Response:'+objAccessTokenResponseWrapper.responseBody);
            //HDMP-8617- End of changes
        }
    }

     //Sets the Class variable for the Total Amount given a Cart ID
    private static void setTotalAmount(String orderId) {
        try {
            Order objOrder = [SELECT Id, Updated_Order_Total__c, BT_Customer_Legecy_Id__c FROM Order WHERE Id = :orderId LIMIT 1];
            customerLegecyId = objOrder.BT_Customer_Legecy_Id__c;
            //TODO - Braintree fails if more than 2 decimals but need to validate how Honda wants it
            TOTAL_AMOUNT = objOrder.Updated_Order_Total__c.setScale(2);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    //Sets the Class variable for the Merchant and Dealer IDs
    private static void setMerchantAndDealerID(String cartId) {
        if(!String.isBlank(MERCHANT_ID)) {
            return;
        } else {
            try {
                WebCart wc = [SELECT Id, DealerId__c FROM WebCart WHERE Id = :cartId];
                DEALER_ID = wc.DealerId__c;
                
                MERCHANT_ID = [SELECT Id, Merchant_Id__c FROM Account WHERE Id = :DEALER_ID].Merchant_Id__c;
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
   
    //method to create Error record
    public static Error__c createErrorRecord(String name, String orderId , String errorMessage, String methodName,String cartId, String accountId, 
                                             String stackTrace, String errorType, Double lineNumber){
        Error__c objError = new Error__c();
        objError.Name = name; 
        objError.Order__c = orderId;
        objError.ClassName__c = 'B2B_PaymentFormController';
        objError.Error_Message__c = errorMessage;
        objError.MethodName__c = methodName;
        objError.RecordId__c = orderId;
        objError.Cart__c = cartId;
        objError.Account__c = accountId;
        objError.StackTrace__c = stackTrace;
        objError.Error_Type__c = errorType;
        objError.Line_Number__c = lineNumber;        
        return objError;
    }
    
    //set the new billing address on order 
    private static void setBillingAddressInformation(Order o, Map<String, Object> dataToUpdate) {
        if(dataToUpdate.containsKey('customerData')) {
            Map<String, Object> customerData = (Map<String, Object>)dataToUpdate.get('customerData');
            
            //Set the necessary Email fields
            if(customerData.containsKey('email')) {
                o.BillingEmailAddress = String.valueOf(customerData.get('email'));
                //o.Email__c = String.valueOf(customerData.get('email'));
            }
            
            //Set the necessary Address 1 and 2 fields
            if(customerData.containsKey('address1')) {
                String fullAddress = String.valueOf(customerData.get('address1'));
                
                if(customerData.containsKey('address2')) {
                    fullAddress += ', ' + String.valueOf(customerData.get('address2'));
                }
                
                o.BillingStreet = fullAddress;
            }
            
            //Set the necessary City field
            if(customerData.containsKey('city')) {
                o.BillingCity = String.valueOf(customerData.get('city'));
            }
            
            //Set the necessary State field
            if(customerData.containsKey('state')) {
                o.BillingState = String.valueOf(customerData.get('state'));
            }
                        
            //Set the necessary Zip Code field
            if(customerData.containsKey('zipCode')) {
                o.BillingPostalCode = String.valueOf(customerData.get('zipCode'));
            }
            
            //Set the necessary Country field
            if(customerData.containsKey('country')) {
                o.BillingCountry = String.valueOf(customerData.get('country'));
            }

            //Set the necessary Customer Name field
            if(customerData.containsKey('name')) {
                if(!String.isBlank(String.valueOf(customerData.get('name')))) {
                    o.Customer_Name__c = String.valueOf(customerData.get('name'));
                }
            }

            //Set the necessary Phone fields
            if(customerData.containsKey('phone')) {
                if(!String.isBlank(String.valueOf(customerData.get('phone')))) {
                    o.BillingPhoneNumber = String.valueOf(customerData.get('phone'));
                }
            }

        }
    }
    
    //Added by Faraz for 5359
    @AuraEnabled
    public static Object retryFailedPayment(String orderId, String cartId){
        try {
            List<Error__c> lstErrors = new List<Error__c>();
            Map<String, Object> returnData = new Map<String, Object>{'success' => false, 'error' => null};
            if(!String.isBlank(cartId)) {
                ORDER_ID = orderId; 
                CART_ID = cartId;
                setTotalAmount(orderId);
                setMerchantAndDealerID(cartId);
                //If Merchant ID or Access Token is null, we cannot proceed with request
                if(String.isBlank(MERCHANT_ID)) {
                    //Error while accessing the Token and/or Merchant ID
                    returnData.put('error', Label.BT_Merchant_Id_Error_Message);
                    //Log into error object.
                    Error__c objError = createErrorRecord(Label.BT_Merchant_Id_Error_Name, ORDER_ID , Label.BT_Merchant_Id_Error_Message, 'processPayment', CART_ID, DEALER_ID, '', '', null);            
                    lstErrors.add(objError);                
                }else {
                    DATA_UPDATES = new Map<String, Object>();
                    DATA_UPDATES.put('isRetryPayment', true); 
                    Order orderObj = [SELECT Id, BT_Customer_Detail__c, Payment_Method_Token__c, CC_Last4__c, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                      (SELECT Id, Cardholder_Name__c, Payment_Method_Type__c FROM BT_Transaction_Details__r)
                                      FROM Order WHERE Id =: orderId LIMIT 1];
                    if(orderObj != null && String.isNotEmpty(orderObj.BT_Customer_Detail__c) && String.isNotEmpty(orderObj.Payment_Method_Token__c)){
                        String customerId = orderObj.BT_Customer_Detail__c;
                        //changes for HDMP-8720(Data model) :- getting the payment id of BT from order 
                        String paymentTokenId = orderObj.Payment_Method_Token__c;
                        List<BT_Payment_Method__c> deletePaymentMethods = new List<BT_Payment_Method__c>();
                        List<BT_Payment_Method__c> lstPaymentMethods = [SELECT Id, Is_In_My_Payment__c FROM BT_Payment_Method__c WHERE Payment_Method_Token__c =: paymentTokenId];
                        if(!lstPaymentMethods.isEmpty()){
                            if(lstPaymentMethods[0].Is_In_My_Payment__c == false){
                                Integer orderCount = [SELECT count() FROM Order WHERE Payment_Method_Token__c =: orderObj.Payment_Method_Token__c AND BT_Transaction_Status__c = 'Authorized'];
                                if(orderCount == 1){
                                    deletePaymentMethods = lstPaymentMethods;
                                }else{
                                    DATA_UPDATES.put('paymentSfId', lstPaymentMethods[0].Id);
                                }
                            }else{
                                DATA_UPDATES.put('paymentSfId', lstPaymentMethods[0].Id);
                            }
                        }

                        lastFourDigitCC = orderObj.CC_Last4__c;                         
                        DATA_UPDATES.put('paymentTokenId', paymentTokenId);
                        
                        map<String, object> customerData = new map<String, object>();
                        customerData.put('address1' , orderObj.BillingStreet);
                        customerData.put('city' , orderObj.BillingCity);
                        customerData.put('state' , orderObj.BillingState);
                        customerData.put('zipCode' , orderObj.BillingPostalCode);
                        DATA_UPDATES.put('customerData', customerData);
                        if(!orderObj.BT_Transaction_Details__r.isEmpty()){
                            BT_Transaction_Details__c objTrans = orderObj.BT_Transaction_Details__r[0];
                            DATA_UPDATES.put('cardholderName', objTrans.Cardholder_Name__c);
                            DATA_UPDATES.put('type', objTrans.Payment_Method_Type__c);                            
                        }
                        
                        returnData = submitAuthorizationRequest(customerId, paymentTokenId, '', returnData);
                        if(!deletePaymentMethods.isEmpty()){
                            DELETE deletePaymentMethods;
                        }
                    }else{
                        returnData.put('error', 'An error occurred. Please review and validate the entered information.');                
                        Error__c objError = createErrorRecord(Label.BT_Customer_Id_Error_Name, ORDER_ID , Label.BT_Customer_Id_Error_Message, 'processPayment', CART_ID, DEALER_ID, '', '', null);            
                        lstErrors.add(objError);
                    }
                }
            }else{
                //Log into error object.
                returnData.put('error', 'An error occurred while processing the Order, please try again later or contact your Honda dealer.');              
                Error__c objError = createErrorRecord(Label.BT_Cart_Id_Error_Name, ORDER_ID , Label.BT_Cart_Id_Error_Message, 'processPayment', CART_ID, DEALER_ID, '', '', null);            
                lstErrors.add(objError);
            }
            //update the BT Token Details if new data is available. 
            if(objBTTokenDetails != null){
                update objBTTokenDetails;
            }
            //insert error record if any error occured
            if(!lstErrors.isEmpty()){
                insert lstErrors;
            }
            return returnData;
        } catch (Exception ex) {
            //Create a error record
            Error__c objError = createErrorRecord('Exception Occured', ORDER_ID , ex.getMessage(), 'submitAuthorizationRequest', CART_ID, DEALER_ID, 
                                                  ex.getStackTraceString(), ex.getTypeName(), Double.valueOf(ex.getLineNumber()));
            insert objError;
            return new Map<String, Object>{'error' => 'An exception occured in pre authorizing the Payment.'}; 
            //throw new AuraHandledException(ex.getMessage());
        }
    }
    //End 5359
    
    @AuraEnabled
    public static Object processPaymentByMyPayment(String paymentId, String cartId, String orderId, Map<String, Object> customerData){
        Map<String, Object> returnData = new Map<String, Object>{'success' => false, 'error' => null};        
        // if the cart id and payment id is not blank process the payment  
        if(!String.isBlank(cartId) && !String.isBlank(paymentId)) { 
            DATA_UPDATES = new Map<String, Object>();
            ORDER_ID = orderId;
            CART_ID = cartId;         
            setTotalAmount(orderId);
            setMerchantAndDealerID(cartId);
            
            //get the braintree payment token by salesforce BT_Payment_Method__c record id. 
            List<BT_Payment_Method__c> lstPaymentMethods = [SELECT Id, Cardholder_Name__c, Payment_Method_Token__c, Type__c, BT_Customer_Details__c, BT_Customer_Details__r.BT_CustomerId__c, Credit_Card_Number__c   
                                                            FROM BT_Payment_Method__c WHERE Id =: paymentId];
            if(!lstPaymentMethods.isEmpty()){
                lastFourDigitCC = lstPaymentMethods[0].Credit_Card_Number__c;
                DATA_UPDATES.put('isMyPayment', true);     
                DATA_UPDATES.put('cardholderName', lstPaymentMethods[0].Cardholder_Name__c);
                DATA_UPDATES.put('type', lstPaymentMethods[0].Type__c);
                DATA_UPDATES.put('customerSFId', lstPaymentMethods[0].BT_Customer_Details__c);
                DATA_UPDATES.put('customerData', customerData); 
                submitAuthorizationRequest(lstPaymentMethods[0].BT_Customer_Details__r.BT_CustomerId__c, lstPaymentMethods[0].Payment_Method_Token__c, '', returnData);
            }else {
                returnData.put('error', 'An error occurred while processing the Payment.');
                return returnData;
            }           
        }else {
            returnData.put('error', 'An error occurred while processing the Payment.');
            return returnData;
        }
        
        //for insert/update the salesforce object after the transaction is completed      
        return returnData;
    }
}
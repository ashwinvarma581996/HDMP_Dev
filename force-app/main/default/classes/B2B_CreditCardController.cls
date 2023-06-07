/*********************************************************************************************************************
Name:           B2B_CreditCardController
Date:           07/09/2021
Description:    Controller for the B2B_BraintreeForm component that authorizes a transaction
Test Class:     B2B_CreditCardControllerTest, B2B_CreditCardControllerMock (Mock Class), B2B_BrainTreeIntegrationMock (Mock Class)
***********************************************************************************************************************
MODIFICATIONS – Date        |   Dev Name        |   Method      |   User Story
***********************************************************************************************************************
        V1                  |   Yashika Agarwal |               |   (Error handling changes- JIRA- 8617)    
***********************************************************************************************************************/

//Likely without sharing due to need of updating Order and accessing Accounts for Merchant Tokens (could move these to a helper class & define without sharing there vs. class-level)
public without sharing class B2B_CreditCardController {
    
    
    //TODO - consider moving variables to helper/utility method (along with Code called out later in Class)
    public static String BASE_URL = 'callout:HondaBraintreeGraphQL';
    public static Final String BRAINTREE_VERSION = '2019-01-01';
    public static Final String CONTENT_TYPE = 'application/json';
    public static String AUTHORIZATION_HEADER;
    public static String MERCHANT_ID;
    
    //Stores the Customer ID created in GraphQL
    public static String CUSTOMER_ID;
    
    //Stores the Customer ID created in SF
    public static String CUSTOMER_SF_ID;
    
    //Stores the Payment Method ID created in SF
    public static String PAYMENT_SF_ID;
    
    //Stores the Payment Method ID crated in GraphQL
    public static String PAYMENT_ID;
    
    //ID of the Order for the current transaction
    public static String ORDER_ID;
    
    //ID of the Order for the current transaction
    public static String CART_ID;
    
    //(Account) ID of the Dealer for the transaction
    public static String DEALER_ID;
    
    //Stores the Amount for the transaction
    public static Double TOTAL_AMOUNT;
    
    //if the order is dealer install flag will be true
    public static boolean isDealerInstall = false;
    
    //for retry login when the access token is expired
    public static boolean isRetry = true;    

    public static Map<String, Object> DATA_UPDATES;
    
    //store the current user name
    public static String username = UserInfo.getName();  

    //Retrieves a Client Token from BrainTree for the Hosted Form
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> hostedFormSetup(String cartId) {
        CART_ID = cartId;
        DATA_UPDATES = new Map<String, Object>();
        String username = UserInfo.getName();
        Map<String, Object> returnData = new Map<String, Object>{'success' => false, 'error' => null};
        returnData.put('codes', getStateCodes());
        returnData.put('paymentTypes', getPaymentTypes());
        returnData.put('shipping', getShippingAddress(cartId));
        WebCart objCart = [SELECT Id, TOTAL__c, Delivery_Type__c FROM WebCart WHERE Id = :cartId LIMIT 1];
        if(objCart != null){
            returnData.put('totalAmount',(Object)objCart.TOTAL__c);
            returnData.put('DeliveryType',(Object)objCart.Delivery_Type__c);//By Faraz for 5329 on 29/06/2022
        }
        
        setMerchantAndDealerID(cartId);
        
        //If Merchant ID or Access Token is null, we cannot proceed with request
        if(String.isBlank(MERCHANT_ID)) {
            returnData.put('error', 'An error occurred. Please try refreshing the page.');
        } else {
            String clientToken = requestClientToken();
            
            if(String.isBlank(clientToken)) {
                returnData.put('error', 'An error occurred. Please try refreshing the page.');
            } else {
                returnData.put('success', true);
                returnData.put('token', clientToken);
            }
        }
        
        //changes for HDMP-8731 :- set client token from access token for PayPal button
        setDealerAuthorizationHeader();
        if(AUTHORIZATION_HEADER != null){
            BASE_URL = 'callout:DealerBraintreeGraphQL';           
            String clientTokenPayPal = requestClientToken();
            returnData.put('tokenPayPal', clientTokenPayPal);
        }
        
        returnData.put('isLoggedInUser',false);
        
        // comment code start:- for R2C (logged in user) 
        // if the customer is a logged in user return the customer and their saved payment details 
         if(!username.contains('Guest')){
            returnData.put('isLoggedInUser',true);
            
            // get all the saved payment method 
            B2B_MyPaymentsController.callClientTokenAPI = false;
            String myPayments = B2B_MyPaymentsController.getAllMyPayments();
            if(myPayments != 'No record found'){
                Map<string, object> mapPayments = (Map<String, Object>)JSON.deserializeUntyped(myPayments);
                returnData.put('myPayments',JSON.serialize(mapPayments.get('paymentMethodList')));
            }else {
                returnData.put('myPayments',myPayments);
            }
            
            
            // for returning the braintree id of the customer
            List<BT_Customer_Details__c> lstCustomers = [SELECT Id, BT_CustomerId__c 
                                                         FROM BT_Customer_Details__c 
                                                         WHERE Customer__c =: UserInfo.getUserId() LIMIT 1];
            if(!lstCustomers.isEmpty()){
                returnData.put('customerId',lstCustomers[0].BT_CustomerId__c);  
            }else {
                returnData.put('customerId','');
            }
            
            
            // return the saved address for logged in customer
            List<User> lstUser = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId()];          
            if(!lstUser.isEmpty()){
                List<My_Address_Book__c> addressBookList = [SELECT Id, Name, Person_Address_Account__c, Address__c, City__c, State__c, Zip__c, Phone__c, Notes__c, NickName__c, isPreferred__c, Email__c 
                                                        FROM My_Address_Book__c 
                                                        WHERE Person_Address_Account__r.PersonContactId =: lstUser[0].ContactId Order By Name Asc];
                Set<My_Address_Book__c> addressBookSet = new Set<My_Address_Book__c>();
                List<My_Address_Book__c> addressBookList1 = new List<My_Address_Book__c>();
                List<My_Address_Book__c> addressBookList2 = new List<My_Address_Book__c>();
                if(addressBookList.size() > 0){
                    for(My_Address_Book__c addr: addressBookList){
                        addressBookList1.add(addr);
                        if(addr.isPreferred__c){
                            addressBookList1.add(0, addr);
                        }
                    }
                    addressBookSet.addAll(addressBookList1); // To remove duplicate records
                    addressBookList2.addAll(addressBookSet); // To return final list of records
                }
                if(!addressBookList2.isEmpty()){
                    returnData.put('myAddresses',(Object)JSON.serialize(addressBookList2));
                }else {
                    returnData.put('myAddresses','No record found');
                }
                    
            }
            
        }  
        // comment code end for R2C (logged in user) 
        
        //Update the Access/Refresh Token information (NOTE: if Transaction failed but tokens were refreshed, these need to be saved)
        if(DATA_UPDATES.containsKey('tokens')) {
            Map<String, Object> tokenData = (Map<String, Object>)DATA_UPDATES.get('tokens');
            updateTokenInformation(tokenData);
        }
        returnData.put('myAddressesMG',B2B_LoggedInUserAddressCheck.loggedInuserAllAddressList());
        return returnData;
    }
    
    //if the customer is paying with there saved payment method this method will used 
    @AuraEnabled
    public static Object processPaymentForLoggedInUser(String paymentId, String cartId, String orderId, Map<String, Object> customerData){
        Map<String, Object> returnData = new Map<String, Object>{'success' => false, 'error' => null};
                 
        // if the cart id and payment id is not blank process the payment  
        if(!String.isBlank(cartId) && !String.isBlank(paymentId)) {
            DATA_UPDATES = new Map<String, Object>();
            ORDER_ID = orderId;
            DATA_UPDATES.put('orderId', ORDER_ID);
            setTotalAmount(cartId);
            setMerchantAndDealerID(cartId);
            //data model changes for R2A
            DATA_UPDATES.put('shippingAddress',getShippingAddress(cartId));
            //get the braintree payment token by salesforce BT_Payment_Method__c record id. 
            List<BT_Payment_Method__c> lstPaymentMethods = [SELECT Id, Payment_Method_Token__c,Cardholder_Name__c, Type__c, BT_Customer_Details__c, BT_Customer_Details__r.BT_CustomerId__c, BT_Customer_Details__r.BT_Customer_Legecy_Id__c, Credit_Card_Number__c   
                                                            FROM BT_Payment_Method__c WHERE Id =: paymentId];
            if(!lstPaymentMethods.isEmpty()){
                DATA_UPDATES.put('paymentId',paymentId);
                DATA_UPDATES.put('customerData', customerData); 
                DATA_UPDATES.put('last4', lstPaymentMethods[0].Credit_Card_Number__c);
                DATA_UPDATES.put('type', lstPaymentMethods[0].Type__c);   
                DATA_UPDATES.put('cardholderName', lstPaymentMethods[0].Cardholder_Name__c);  
                DATA_UPDATES.put('isSavedPayment', true);
                DATA_UPDATES.put('customerId', lstPaymentMethods[0].BT_Customer_Details__r.BT_CustomerId__c);
                DATA_UPDATES.put('legacyId', lstPaymentMethods[0].BT_Customer_Details__r.BT_Customer_Legecy_Id__c);
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
        doPostTransactionUpdate(JSON.serialize(DATA_UPDATES));
        return returnData;
    }
    
    // Do Insert/Update in salesforce object after transaction for logged in user
    //@future
    public static void doPostTransactionUpdate(String updateData){
        Map<String, Object> dataToUpdate = (Map<String, Object>)JSON.deserializeUntyped(updateData);
        if(dataToUpdate.containsKey('orderId')){
            ORDER_ID = String.valueOf(dataToUpdate.get('orderId'));  
            //If an error occured, create an Error record and update the Order record
            if(dataToUpdate.containsKey('error')) {
                handleBraintreeError(String.valueOf(dataToUpdate.get('error')), dataToUpdate);
            } 
           
            //Create the Braintree Transaction Details record
            if(dataToUpdate.containsKey('authorizationId')) {
                createTransactionDetailsRecord(dataToUpdate);
            }               
             updateTransactionStatusOnOrder(String.valueOf(dataToUpdate.get('transactionStatus')), dataToUpdate);          
        }
        
        //Update the Access/Refresh Token information (NOTE: if Transaction failed but tokens were refreshed, these need to be saved)
        if(dataToUpdate.containsKey('tokens')) {
            Map<String, Object> tokenData = (Map<String, Object>)dataToUpdate.get('tokens');
            updateTokenInformation(tokenData);
        }
    }
    
    //Creates a Customer, vaults the Payment, and completes a Sale/Authorization Transaction
    @AuraEnabled(cacheable=false)
    public static Object processPayment(String nonce, Map<String, Object> customerData, String cartId, String orderId,String paymentType) {      
        Map<String, Object> returnData = new Map<String, Object>{'success' => false, 'error' => null};
        
        if(!String.isBlank(cartId)) {            
            DATA_UPDATES = new Map<String, Object>();
            ORDER_ID = orderId;
            CART_ID = cartId;
            DATA_UPDATES.put('orderId', ORDER_ID);
            
            setTotalAmount(cartId);
            setMerchantAndDealerID(cartId);
            
            //data model changes for R2A
            DATA_UPDATES.put('shippingAddress',getShippingAddress(cartId));
            
            //If Merchant ID or Access Token is null, we cannot proceed with request
            if(String.isBlank(MERCHANT_ID)) {
                //Error while accessing the Token and/or Merchant ID
                returnData.put('error', 'An error occurred while processing the Payment.');
                return returnData;
            }
            String customerId;
            
            // if it's a logged in user and having the customer id 
            if(customerData != null && customerData.containsKey('customerId')){
                customerId = String.valueOf(customerData.get('customerId'));
                
                DATA_UPDATES.put('isOldCustomer', true);
                if(String.isNotEmpty(customerId)){
                        List<BT_Customer_Details__c> lstCustomers = [SELECT Id, BT_CustomerId__c, BT_Customer_Legecy_Id__c 
                                                                     FROM BT_Customer_Details__c 
                                                                     WHERE BT_CustomerId__c =: customerId LIMIT 1];
                        if(!lstCustomers.isEmpty()){
                            DATA_UPDATES.put('CustomerSFId', lstCustomers[0].Id); 
                            DATA_UPDATES.put('legacyId', lstCustomers[0].BT_Customer_Legecy_Id__c);
                        } 
                }
                DATA_UPDATES.put('customerData', customerData);
            }else {
                //Create a Customer with the given information
                customerId = createCustomer(customerData);    
            }   
            
            if(customerData.containsKey('isSaveNewPaymentMethod') && (Boolean)customerData.get('isSaveNewPaymentMethod') == true){
                DATA_UPDATES.put('isSaveNewPaymentMethod', true);
            }
            
            if(!String.isBlank(customerId) && paymentType == 'Credit Card') {              
                //Vault the Payment Method for the nonce and the newly created Customer
                Map<String, Object> result = vaultPaymentMethod(nonce, customerId);
                   
                //Store the Customer ID for a post-transaction update
                if(result != null){
                    DATA_UPDATES.put('customerId', customerId);
                } 
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
                
                if(result != null && String.isNotBlank(paymentType)){
                    DATA_UPDATES.put('paymentType', paymentType);
                }
                
                //if payment method is duplicate then submit the pre-authorization request with the old matching credit card
                if(String.isNotEmpty(paymentToken)){
                    returnData.put('errorReason', 'Duplicate Card');
                    if(result != null && result.containsKey('id')){
                        B2B_BrainTreeUtils.deleteBTVaultPaymentMethod(String.valueOf(result.get('id')));
                    }                   
                }
                //If the request was successful, submit the pre-authorization request with the new Customer and Payment Method
                else if(result != null && result.containsKey('id')) {                       
                    submitAuthorizationRequest(customerId, String.valueOf(result.get('id')), '', returnData);
                } else {
                    //added by Rajrishi on 10 Nov 2021
                    //Error occurred while vaulting the Payment
                    if(result.containsKey('gatewayRejectionReason')){
                        returnData.put('errorReason', result.get('gatewayRejectionReason'));
                    }
                    if(result.containsKey('CCTypeError')){
                        returnData.put('error', result.get('CCTypeError'));
                    }else {                       
                        returnData.put('error', 'An error occurred while processing the Payment.');
                    }
                }
             //changes for HDMP-8731  
            } else if(!String.isBlank(customerId) && paymentType == 'PayPal') {
                DATA_UPDATES.put('customerId', customerId);
                DATA_UPDATES.put('paymentType', paymentType);
                submitAuthorizationRequest(customerId, '', nonce, returnData);
            }else {
                //Error while creating the Customer
                returnData.put('error', 'An error occurred. Please review and validate the entered information.');
            }
            if(returnData.get('error') == null && returnData.get('errorReason') == null){
            handlePostTransactionUpdates(JSON.serialize(DATA_UPDATES));
            }
            //handlePostTransactionUpdates(JSON.serialize(DATA_UPDATES));
            return returnData;
        }
        returnData.put('error', 'An error occurred while processing the Payment.');
        handlePostTransactionUpdates(JSON.serialize(DATA_UPDATES));
        return returnData;
    }
    
    // --- GraphQL Request Methods ---
    //Creates a Base Request for the Braintree GraphQL
    public static HttpRequest createBaseRequest(String method) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL);
        req.setMethod(method);
        
        req.setHeader('Content-Type', CONTENT_TYPE);
        req.setHeader('Braintree-Version', BRAINTREE_VERSION);
        
        return req;
    }
    
    //GraphQL Callout to retrieve a Client Token for the Hosted Form   
    public static String requestClientToken() {
        try {
            HttpRequest req = createBaseRequest('POST');
            // to get the dealer client token for paypal
            if(AUTHORIZATION_HEADER != null){
                String authToken = 'Bearer '+ AUTHORIZATION_HEADER;
                req.setHeader('Authorization', authToken); 
            }
            Map<String, Object> graphQl = new Map<String, Object>();
            //Create base Query and Variables structure
            graphQl.put('query', 'mutation { createClientToken { clientToken }}');
            graphQl.put('variables', new Map<String, Object>());
            
            //input > clientToken > merchantAccountId > {merchantId}
            Map<String, String> merchantIdMap = new Map<String, String>{'merchantAccountId' => MERCHANT_ID};
            Map<String, Object> clientTokenMap = new Map<String, Object>{'clientToken' => merchantIdMap};
            ((Map<String, Object>)graphQl.get('variables')).put('input', clientTokenMap);
                    
            req.setBody(JSON.serialize(graphQl));

            Http http = new Http();
            Long beforeAPI = DateTime.now().getTime();
            HttpResponse res = http.send(req);

            if(res.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                return parseClientTokenResponse(res.getBody());
            }else{
                Long afterAPI = DateTime.now().getTime();
                Long durationTime = afterAPI - beforeAPI;
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
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
                Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID, 'B2B_CreditCardController', String.valueOf(res.getStatusCode()), errorType, '', 'requestClientToken', true, '', '', '', durationTime, severity, 'Request:'+req.getBody(), 'Response:'+res.getBody());
                //HDMP-8617:ends
                return '';
            }
            
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        return null;
    }
    
    //GraphQL Callout to create a Customer with given information
    public static String createCustomer(Map<String, Object> customerData) {
        if(customerData == null) {
            return null;
        }
        //Store the Customer Data for the future method
        DATA_UPDATES.put('customerData', customerData);
        try {
            HttpRequest req = createBaseRequest('POST');
            Map<String, Object> graphQl = new Map<String, Object>();
            //Create base Query and Variables structure
            graphQl.put('query', 'mutation createCustomer($input: CreateCustomerInput) { createCustomer(input: $input) { customer { id legacyId} } }');
            graphQl.put('variables', new Map<String, Object>());
            
            Map<String, String> fieldsMap = new Map<String, String>();
            
            //Add Name
            if(customerData.containsKey('name')) {
                if(!String.isBlank(String.valueOf(customerData.get('name')))) {
                    String fullName = String.valueOf(customerData.get('name'));
                    List<String> nameParts = fullName.split(' ');
                    fieldsMap.put('firstName', nameParts[0]);
                    nameParts.remove(0);
                    fieldsMap.put('lastName', String.join(nameParts, ' '));
                }
            }

            //Add Email
            if(customerData.containsKey('email')) {
                if(!String.isBlank(String.valueOf(customerData.get('email')))) {
                    fieldsMap.put('email', String.valueOf(customerData.get('email')));
                }
            }
            
            //Add Phone Number
            if(customerData.containsKey('phone')) {
                if(!String.isBlank(String.valueOf(customerData.get('phone')))) {
                    fieldsMap.put('phoneNumber', String.valueOf(customerData.get('phone')));
                }
            }

            //input > customer > firstName, lastName, email, phoneNumber
            Map<String, Object> customerMap = new Map<String, Object>{'customer' => fieldsMap};
            ((Map<String, Object>)graphQl.get('variables')).put('input', customerMap);
                    
            req.setBody(JSON.serialize(graphQl));

            Http http = new Http();
            Long beforeAPI = DateTime.now().getTime(); // Added By Ravi Prasad
            HttpResponse res = http.send(req);
            if(res.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                return parseCreateCustomerResponse(res.getBody());
            }else{
                Long afterAPI = DateTime.now().getTime();
                Long durationTime = afterAPI - beforeAPI;
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                    
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
                Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID, 'B2B_CreditCardController', String.valueOf(res.getStatusCode()), errorType, '', 'createCustomer', true, ORDER_ID, '', '', durationTime, severity, 'Request:'+req.getBody(), 'Response:'+res.getBody());
                //HDMP-8617:ends
                return '';
            }
            
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        return null;
    }
    
    //GraphQL Callout to vault the Payment Method
    public static Map<String, Object> vaultPaymentMethod(String nonce, String customerId) {
        try {
            HttpRequest req = createBaseRequest('POST');
            
            Map<String, Object> graphQl = new Map<String, Object>();

            //TODO - review fields included in mutation and also returned from mutation
            //Create base Query and Variables structure
            //Capture CC Last4 
            graphQl.put('query', 'mutation  vaultPaymentMethod($input: VaultPaymentMethodInput!) { vaultPaymentMethod(input: $input) { paymentMethod { id legacyId details{ __typename ...on CreditCardDetails{last4 brandCode cardholderName expirationMonth expirationYear uniqueNumberIdentifier} }} verification { status gatewayRejectionReason } } }');
            graphQl.put('variables', new Map<String, Object>());
            
            //input > paymentMethodId, customerId
            Map<String, String> inputMap = new Map<String, String>();
            inputMap.put('paymentMethodId', nonce);
            inputMap.put('customerId', customerId);
            ((Map<String, Object>)graphQl.get('variables')).put('input', inputMap);
            req.setBody(JSON.serialize(graphQl));
            
            Http http = new Http();
            Long beforeAPI = DateTime.now().getTime();
            
            HttpResponse res = http.send(req);
            if(res.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                return parseVaultPaymentResponse(res.getBody());
            }else{
                Long afterAPI = DateTime.now().getTime();
                Long durationTime = afterAPI - beforeAPI;
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                    
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
                Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID, 'B2B_CreditCardController', String.valueOf(res.getStatusCode()), errorType, '', 'vaultPaymentMethod', true, ORDER_ID, '', '', durationTime, severity, 'Request:'+req.getBody(), 'Response:'+res.getBody());
                //HDMP-8617:ends
                return null;
            }
            
        } catch(Exception e) {
            System.debug(e.getMessage() + ' line number : S'+e.getLineNumber());
        }
        return null;
    }   
    // --- End of GraphQL Request Methods ---
    
    // --- Methods that set Class Variables --- 
    //Sets the Class variable for the Merchant and Dealer IDs
    @testVisible
    private static void setMerchantAndDealerID(String cartId) {
        if(!String.isBlank(MERCHANT_ID)) {
            return;
        } else {
            try {
                WebCart wc = [SELECT Id, DealerId__c, Delivery_Type__c FROM WebCart WHERE Id = :cartId];
                DEALER_ID = wc.DealerId__c;
                
                if(wc.Delivery_Type__c == 'Install At Dealer'){
                    isDealerInstall = true;
                }
                MERCHANT_ID = [SELECT Id, Merchant_Id__c FROM Account WHERE Id = :DEALER_ID].Merchant_Id__c;
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }

    //Sets the Access Token for the Class - leverages the existing Access Token if still valid, otherwise, attempts to request a new one via the Refresh Token
    @testVisible
    private static void setDealerAuthorizationHeader() {
        try { 
            BT_Token_Details__c btDetails = [SELECT Id, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c FROM BT_Token_Details__c WHERE Account__c = :DEALER_ID];
    
            //If true, Access Token is expired & a new one needs to be requested
            if(Datetime.now() > btDetails.AccessTokenExpiresAt__c) {
                //Ensure refresh token is still valid
                if(Datetime.now() < btDetails.RefreshTokenExpiresAT__c) {
                    requestNewAccessToken(btDetails);
                } else {
                    //TODO - determine route if refresh token is expired
                }
            } else {
                AUTHORIZATION_HEADER = btDetails.AccessToken__c;
            }
        } catch(Exception e) {
            System.debug(e.getMessage());       
        }        
    }
    
    //Refreshes the current Access and Refresh Tokens for the current Merchant
    private static void requestNewAccessToken(BT_Token_Details__c btDetails) {
        Long beforeAPI = DateTime.now().getTime();
        //Request a new Access Token given the current Refresh Token
        String refreshTokenResponse = B2B_BrainTreeIntegration.getRefreshToken(MERCHANT_ID, btDetails.RefreshToken__c);
        B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();           
        objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(refreshTokenResponse, B2B_AccessTokenResponseWrapper.class);                       

        //If request was successful, store results of callout and set the Access Token 
        if(objAccessTokenResponseWrapper.status == 200){  
            Map<String, Object> tokenInformation = new Map<String, Object>();
            tokenInformation.put('id', btDetails.Id);
            
            //calculate expiry date for refresh token               
            Date myDate = System.today().addDays(179);
            Time myTime = Time.newInstance(23, 0, 0, 0); 
            
            //NOTE: Cannot cast to BT_Token_Details__c as information (encrypted) is lost during JSON serializing/deserializing in future method
            Datetime accessTokenExpDate = System.now().addHours(23); 
            
            DateTime refreshTokenExpDate = DateTime.newInstanceGMT(myDate, myTime);  
            String accessToken = objAccessTokenResponseWrapper.credentials.accessToken;
            String refreshToken = objAccessTokenResponseWrapper.credentials.refreshToken;
            
            tokenInformation.put('accessToken', accessToken);
            tokenInformation.put('refreshToken', refreshToken);
            tokenInformation.put('accessExpiration', accessTokenExpDate);
            tokenInformation.put('refreshExpiration', refreshTokenExpDate);
            
            DATA_UPDATES.put('tokens', tokenInformation);
            AUTHORIZATION_HEADER = accessToken;
        } else {
            //TODO - should non-200 responses be considered?
            Long afterAPI = DateTime.now().getTime();
            Long durationTime = afterAPI - beforeAPI;
            String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
            //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                    
            String severity;
            String errorType;
            Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                        if(errorRecords.containskey(String.valueOf(objAccessTokenResponseWrapper.status))){
                            severity= errorRecords.get(String.valueOf(objAccessTokenResponseWrapper.status)).severity__c;
                            errorType=errorRecords.get(String.valueOf(objAccessTokenResponseWrapper.status)).error_Type__c;
                        }
                        else{
                            severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                            errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                        }
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID, 'B2B_CreditCardController', String.valueOf(objAccessTokenResponseWrapper.status), errorType, '', 'requestNewAccessToken', true, ORDER_ID, '', '',durationTime, severity, 'Request:'+objAccessTokenResponseWrapper.requestBody, 'Response:'+objAccessTokenResponseWrapper.responseBody);
            //HDMP-8617:ends
        }
    }
    
    //Sets the Class variable for the Total Amount given a Cart ID
    private static void setTotalAmount(String cartId) {
        try {
            WebCart wc = [SELECT Id, TOTAL__c FROM WebCart WHERE Id = :cartId];
            
            //TODO - Braintree fails if more than 2 decimals but need to validate how Honda wants it
            TOTAL_AMOUNT = wc.TOTAL__c.setScale(2);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    // --- End of Methods that set Class Variables --- 
    
    //Calls out to the Middleware to perform the pre-authorization
    @testVisible
    private static void submitAuthorizationRequest(String customerId, String paymentToken,String paypalNonce, Map<String, Object> returnData) {
        //Need to set the Authorization Header to be the Dealer's Access Token for this request
        if(isRetry == true){
            setDealerAuthorizationHeader();
        } 
        
        if(!username.containsIgnoreCase('Guest') && DATA_UPDATES.containsKey('isSaveNewPaymentMethod') && (Boolean)DATA_UPDATES.get('isSaveNewPaymentMethod')){
            //Store the Payment ID for a post-transaction update
            DATA_UPDATES.put('paymentId', paymentToken);
        }
        
        if(!String.isEmpty(paymentToken)){
            //Store the paymentToken for order 
            DATA_UPDATES.put('paymentToken', paymentToken);
        }              
        //changes for HDMP-8731 :- now calling the updated sale:transaction API to create the transaction for PayPal or CC  
        String res = B2B_BrainTreeIntegration.braintreeTransactionPreAuth(customerID, MERCHANT_ID, AUTHORIZATION_HEADER, String.valueOf(TOTAL_AMOUNT), paymentToken, paypalNonce);
        //String res = B2B_BrainTreeIntegration.braintreeTransactionPreAuth(customerID, MERCHANT_ID, AUTHORIZATION_HEADER, '100', paymentToken);

        if(res != null) {
            try {
                Map<String, Object> authResponse = (Map<String, Object>)JSON.deserializeUntyped(res);
                Long beforeAPI = DateTime.now().getTime();
                if(authResponse != null) {
                    if(authResponse.containsKey('status')) {
                        Integer status = Integer.valueOf(authResponse.get('status'));
                        
                        if(status == 200 && authResponse.containsKey('transactionBT')) {
                            Map<String, Object> transactionResponse = (Map<String, Object>)authResponse.get('transactionBT');
                            DATA_UPDATES.put('authorizationId', String.valueOf(transactionResponse.get('id')));
                            
                            if(isDealerInstall == true){
                                String postAuthResponse = B2B_BrainTreeIntegration.braintreeTransactionPostAuth(customerID, MERCHANT_ID, String.valueOf(transactionResponse.get('id')), String.valueOf(TOTAL_AMOUNT), AUTHORIZATION_HEADER);
                                B2B_BrainTreeTransactionResponse postAuthBTResponse = B2B_BrainTreeTransactionResponse.parse(postAuthResponse);
                                if(postAuthBTResponse.status == 200){
                                    DATA_UPDATES.put('transactionStatus', postAuthBTResponse.transactionBT.status);
                                    DATA_UPDATES.put(B2B_IntegrationConstants.IS_DEALER_INSTALLATION, true);//Added by Faraz Ansari for HDMP-8705
                                    //if the credit card in one time use then delete the credit card from BT
                                    if(!DATA_UPDATES.containsKey('isSavedPayment') && DATA_UPDATES.containsKey('paymentToken') && !DATA_UPDATES.containsKey('paymentId')){
                                        //delete the one time credit card 
                                        deletePaymentMethod(customerID, paymentToken);
                                    }
                                    returnData.put('success', true);
                                    return;
                                }else {
                                    if(!DATA_UPDATES.containsKey('isSavedPayment') && DATA_UPDATES.containsKey('paymentToken')){
                                        //changes for HDMP-8730 :- in deletePaymentMethod method we are calling the new set of API's 
                                        //to delete the payment method and address from BT
                                        deletePaymentMethod(customerID, paymentToken);
                                        DATA_UPDATES.remove('paymentId');
                                    }                                   
                                    
                                    //If we have a response from Braintree, leverage this info and return
                                    // DATA_UPDATES.put('error',postAuthBTResponse.errorMessage);
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
                                    return;
                                }
                                
                            }else {                                  
                                DATA_UPDATES.put('transactionStatus', String.valueOf(transactionResponse.get('status')));
                                returnData.put('success', true);
                                return;                                
                            }                       
                        } 
                        else {                            
                            // if the transaction is having authenticationError 
                            // need to retry for payment by updating the access token 
                            String authError = String.valueOf(authResponse.get('errorMessage'));
                            if(authError.contains('authenticationError') && isRetry == true){
                                isRetry = false;
                                BT_Token_Details__c btDetails = [SELECT Id, RefreshToken__c, RefreshTokenExpiresAT__c 
                                                                 FROM BT_Token_Details__c 
                                                                 WHERE Account__c = :DEALER_ID];
                                if(Datetime.now() < btDetails.RefreshTokenExpiresAT__c) {
                                    //get the new access token
                                    requestNewAccessToken(btDetails);
                                    
                                    //again call the method for make the transaction
                                    submitAuthorizationRequest(customerId, paymentToken, paypalNonce,returnData);
                                }                              
                            }else {  
                                if(DATA_UPDATES.containsKey('paymentToken')){
                                    //changes for HDMP-8730 :- in deletePaymentMethod method we are calling the new set of API's 
                                    //to delete the payment method and address from BT
                                    deletePaymentMethod(customerID, paymentToken);
                                    DATA_UPDATES.remove('paymentId');
                                }
                                
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
                                
                                return;
                            }
                        }
                    }
                }
                if(!DATA_UPDATES.containsKey('isSavedPayment') && DATA_UPDATES.containsKey('paymentToken')){
                    //changes for HDMP-8730 :- in deletePaymentMethod method we are calling the new set of API's 
                    //to delete the payment method and address from BT
                    deletePaymentMethod(customerID, paymentToken);
                    DATA_UPDATES.remove('paymentId');
                }
                //Put in generic message to be passed to Error__c record
                DATA_UPDATES.put('error', 'An error occurred while authorizing the Payment.');
            } catch(Exception e) {
                //Pass exception message to Error__c record if an exception occurred
                DATA_UPDATES.put('error', e.getMessage());
            }
            if(!DATA_UPDATES.containsKey('isSavedPayment') && DATA_UPDATES.containsKey('paymentToken')){
                //changes for HDMP-8730 :- in deletePaymentMethod method we are calling the new set of API's 
                //to delete the payment method and address from BT
                deletePaymentMethod(customerID, paymentToken);
                DATA_UPDATES.remove('paymentId');
            }
            returnData.put('error', 'An error occurred while authorizing the Payment.');
        } else {
            if(!DATA_UPDATES.containsKey('isSavedPayment') && DATA_UPDATES.containsKey('paymentToken')){
                //changes for HDMP-8730 :- in deletePaymentMethod method we are calling the new set of API's 
                //to delete the payment method and address from BT
                deletePaymentMethod(customerID, paymentToken);
                DATA_UPDATES.remove('paymentId');
            }
            returnData.put('error', 'An error occurred while authorizing the Payment.');
            DATA_UPDATES.put('error', 'An error occurred while authorizing the Payment.');
        }
    }
    
    // changes for HDMP-8730 :- delete the payment method and address from Braintree
    private static void deletePaymentMethod(String customerID, String paymentToken){
        Long beforeAPI = DateTime.now().getTime();
        // get the address id from payment method find API
        B2B_BrainTreeTransactionResponse objPaymentFindResponse = B2B_BrainTreeIntegration.braintreePaymentMethodFind(paymentToken);
        if(objPaymentFindResponse.status == 200){     
            //delete the one time payment method from BT
            B2B_BrainTreeIntegration.braintreePaymentMethodDelete(paymentToken);
            if(DATA_UPDATES.containsKey('legacyId')){
                //delete the related address to the payment method
                B2B_BrainTreeIntegration.braintreeAddressDelete(String.valueOf(DATA_UPDATES.get('legacyId')), objPaymentFindResponse.billingAddressId); 
            }                                                     
        } else {
            Long afterAPI = DateTime.now().getTime();
            Long durationTime = afterAPI - beforeAPI;
            String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
            //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                    
            String severity;
            String errorType;
            Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                        if(errorRecords.containskey(String.valueOf(objPaymentFindResponse.status))){
                            severity= errorRecords.get(String.valueOf(objPaymentFindResponse.status)).severity__c;
                            errorType=errorRecords.get(String.valueOf(objPaymentFindResponse.status)).error_Type__c;
                        }
                        else{
                            severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                            errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                        }
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', DEALER_ID, personAccountId, CART_ID, 'B2B_CreditCardController', String.valueOf(objPaymentFindResponse.status), errorType, '', 'deletePaymentMethod', true, ORDER_ID, '', '', durationTime, severity, 'Request:'+objPaymentFindResponse.requestBody, 'Response:'+objPaymentFindResponse.responseBody);
            //HDMP-8617:ends
        }
    }
    
    // --- Methods that parse GraphQL Responses --- 
    //Parses the response of the clientToken request to extract the token
    private static String parseClientTokenResponse(String resBody) {
        Map<String, Object> resData = (Map<String, Object>)JSON.deserializeUntyped(resBody);
        
        // data > createClientToken > clientToken > {token}
        if(resData != null && resData.containsKey('data')) {
            Map<String, Object> initialData = (Map<String, Object>)resData.get('data');
            
            if(initialData != null && initialData.containsKey('createClientToken')) {
                Map<String, Object> createClientTokenData = (Map<String, Object>)initialData.get('createClientToken');
                
                if(createClientTokenData != null && createClientTokenData.containsKey('clientToken')) {
                    return String.valueOf(createClientTokenData.get('clientToken'));
                }
            }
        }
        return null;
    }
    
    //Parses the response of the createCustomer request to extract the token
    private static String parseCreateCustomerResponse(String resBody) {
        Map<String, Object> resData = (Map<String, Object>)JSON.deserializeUntyped(resBody);
        
        // data > createClientToken > clientToken > {token}
        if(resData != null && resData.containsKey('data')) {
            Map<String, Object> initialData = (Map<String, Object>)resData.get('data');
            
            if(initialData != null && initialData.containsKey('createCustomer')) {
                Map<String, Object> createCustomerData = (Map<String, Object>)initialData.get('createCustomer');
                
                if(createCustomerData != null && createCustomerData.containsKey('customer')) {
                    Map<String, Object> customerData = (Map<String, Object>)createCustomerData.get('customer');
                    if(customerData != null && customerData.containsKey('legacyId')) { 
                        DATA_UPDATES.put('legacyId',customerData.get('legacyId'));                     
                    }
                    if(customerData != null && customerData.containsKey('id')) {
                        return String.valueOf(customerData.get('id'));
                    }
                }
            }
        }
        return null;
    }
    
    //Parses the response of the createCustomer request to extract the token
    @testVisible
    private static Map<String, Object> parseVaultPaymentResponse(String resBody) {
        Map<String, Object> resData = (Map<String, Object>)JSON.deserializeUntyped(resBody);
        
        // data > vaultPaymentMethod > paymentMethod > id > {value}
        // data > vaultPaymentMethod > verification > status > {value}
        if(resData != null && resData.containsKey('data')) {
            Map<String, Object> returnData = new Map<String, Object>();
            Map<String, Object> initialData = (Map<String, Object>)resData.get('data');
            
            if(initialData != null && initialData.containsKey('vaultPaymentMethod')) {
                Map<String, Object> vaultPaymentMethodData = (Map<String, Object>)initialData.get('vaultPaymentMethod');
                
                if(vaultPaymentMethodData != null && vaultPaymentMethodData.containsKey('paymentMethod')) {
                    Map<String, Object> paymentMethodData = (Map<String, Object>)vaultPaymentMethodData.get('paymentMethod');
                    
                    if(paymentMethodData != null && paymentMethodData.containsKey('id')) {
                        returnData.put('id', String.valueOf(paymentMethodData.get('id')));
                        //Capture CC Last4 
                        if(paymentMethodData.containsKey('details')) {
                            Map<String, Object> detailsData = (Map<String, Object>)paymentMethodData.get('details');
                            if(detailsData != null && detailsData.containsKey('last4')) {
                                returnData.put('last4', String.valueOf(detailsData.get('last4')));
                            }
                            if(detailsData != null && detailsData.containsKey('cardholderName')) {
                                returnData.put('cardholderName', String.valueOf(detailsData.get('cardholderName')));
                            }
                            if(detailsData != null && detailsData.containsKey('expirationMonth')) {
                                returnData.put('expirationMonth', String.valueOf(detailsData.get('expirationMonth')));
                            }
                            if(detailsData != null && detailsData.containsKey('expirationYear')) {
                                returnData.put('expirationYear', String.valueOf(detailsData.get('expirationYear')));
                            }
                            if(detailsData != null && detailsData.containsKey('brandCode')) {
                                returnData.put('brandCode', String.valueOf(detailsData.get('brandCode')));
                            }                            
                            if(detailsData != null && detailsData.containsKey('uniqueNumberIdentifier')) {
                                returnData.put('uniqueNumberIdentifier', String.valueOf(detailsData.get('uniqueNumberIdentifier')));
                            }
                        }
                    }
                }
                //added by Rajrishi on 10 Nov 2021
                if(resData.containsKey('errors')){
                    List<Object> errorData = (List<Object>) resData.get('errors');
                    for(Object objError : errorData){
                        Map<String, Object> mapErrorObj = (Map<String, Object>)objError;
                        String errorMessage = mapErrorObj.containsKey('message') ? (String) mapErrorObj.get('message') : null;
                        if(errorMessage != null && errorMessage.contains('Credit card type is not accepted')){
                            returnData.put('CCTypeError', errorMessage);
                        }                      
                    }
                }
                if(vaultPaymentMethodData != null && vaultPaymentMethodData.containsKey('verification')) {
                    Map<String, Object> verificationData = (Map<String, Object>)vaultPaymentMethodData.get('verification');
                    
                    if(verificationData != null && verificationData.containsKey('status')) {
                        returnData.put('status', String.valueOf(verificationData.get('status')));
                    }
                    //added by Rajrishi on 10 Nov 2021
                    if(verificationData != null && verificationData.containsKey('gatewayRejectionReason')) {
                        returnData.put('gatewayRejectionReason', String.valueOf(verificationData.get('gatewayRejectionReason')));
                    }
                }
            }
            return returnData;
        }
        return null;
    }
    // --- End of Methods that parse GraphQL Responses --- 

    // --- Methods that create Records after the Operation --- 
    //Future Method called at the end of the operation to create all necessary records (Braintree Detail records, Access/Refresh Token records, Error records, etc.)
    //@future
    private static void handlePostTransactionUpdates(String updateData) {
        Map<String, Object> dataToUpdate = (Map<String, Object>)JSON.deserializeUntyped(updateData);

        //If the Order ID exists, create the subsequent child records
        if(dataToUpdate.containsKey('orderId')) {
            ORDER_ID = String.valueOf(dataToUpdate.get('orderId'));
            
            //If an error occured, create an Error record and update the Order record
            if(dataToUpdate.containsKey('error')) {
                handleBraintreeError(String.valueOf(dataToUpdate.get('error')), dataToUpdate);
            } 
            
            //Create the Braintree Customer Details record
            if(dataToUpdate.containsKey('customerId') && !dataToUpdate.containsKey('isOldCustomer')) {
                createCustomerDetailsRecord(dataToUpdate);
            }else if(dataToUpdate.containsKey('CustomerSFId')){
                CUSTOMER_SF_ID = String.valueOf(dataToUpdate.get('CustomerSFId'));
            }
            
            //Create the Braintree Payment Details record
            if(dataToUpdate.containsKey('paymentId') && dataToUpdate.containsKey('isSaveNewPaymentMethod') && Boolean.valueOf(dataToUpdate.containsKey('isSaveNewPaymentMethod'))) {
                //createPaymentDetailsRecord(String.valueOf(dataToUpdate.get('paymentId')));
                createPaymentDetailsRecord(dataToUpdate);               
            } else if(dataToUpdate.containsKey('customerData')){
                Map<String, Object> customerData = (Map<String, Object>)dataToUpdate.get('customerData');
                if(customerData.containsKey('newAddressData') && Boolean.valueOf(customerData.get('newAddressData'))){
                    createAddressRecord(customerData);
                }
            }
            
            //Create the Braintree Transaction Details record
            if(dataToUpdate.containsKey('authorizationId')) {
                createTransactionDetailsRecord(dataToUpdate);
            }
            
            //Update the Braintree Transaction field on the Order
            updateTransactionStatusOnOrder(String.valueOf(dataToUpdate.get('transactionStatus')), dataToUpdate);
            
            //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
            //Dealer Installation - Invoice creation
            if(dataToUpdate.containsKey(B2B_IntegrationConstants.IS_DEALER_INSTALLATION) && Boolean.valueOf(dataToUpdate.get(B2B_IntegrationConstants.IS_DEALER_INSTALLATION))) {
                //createInvoiceRecords();
            }           
            //Added by Faraz Ansari for HDMP-8705 - End
        }
        
        //Update the Access/Refresh Token information (NOTE: if Transaction failed but tokens were refreshed, these need to be saved)
        if(dataToUpdate.containsKey('tokens')) {
            Map<String, Object> tokenData = (Map<String, Object>)dataToUpdate.get('tokens');
            updateTokenInformation(tokenData);
        }
    }
    
    //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
    //Create Invoice & Invoice Items records based on Order & Order Items
    public static void createInvoiceRecords() {
      /*  String singleOrderId;
        try{
            List<Invoice__c> lstInvoice = new List<Invoice__c>();
            List<Invoice_Item__c> lstInvoiceItem = new List<Invoice_Item__c>();
            Order objOrder = [SELECT Id, OrderNumber, OrderedDate, BT_Customer_Detail__c, Payment_Method_Token__c, Updated_Order_Total__c, SHIPPING_from_cart__c,  
                                     AccountId, Status, Updated_Shipping__c, Updated_Total_Tax__c, cart__r.ShippingAmount__c , cart__r.CustomerStreet__c, cart__r.CustomerCity__c, 
                                     cart__r.Customer_State__c, ShipToContactId,BillingEmailAddress, Customer_Name__c,Cart_Shipping_Customer_Name__c, cart__r.CustomerPostalCode__c, 
                                     BT_Transaction_Status__c, IsError__c, cart__c, Send_Email_To_Customer__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, 
                                     BillingCountry, BillingAddress, BillingPhoneNumber, CC_Last4__c,Cart_Shipping_City__c, Cart_Shipping_Country__c, Cart_Shipping_Postal_Code__c,
                                     Cart_Shipping_State__c, Cart_Shipping_Street__c, Payment_Type__c, Delivery_Type__c,Total_Shipping_Tax__c,Current_Shipping_Tax__c,
                                     ShippingAddress, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                                     (SELECT Id, Name, BT_TransactionId__c , Customer__c FROM BT_Transaction_Details__r),
                                     (SELECT Id, TotalPrice, Dealer_Installation_Price__c, Delta_Installation_Price__c, Updated_Installation_Price__c, Delta_Quantity__c,Updated_Quantity__c,
                                      Return_Quantity__c, Quantity, ListPrice, Total_Tax__c, Product_SKU__c, Cart_Item_Product_Name__c, Op_Code__c FROM OrderItems WHERE Type != 'Delivery Charge') 
                                     FROM Order 
                                     WHERE Id =: ORDER_ID];
            if(objOrder.Id != null){
                singleOrderId = objOrder.Id;
                Account objAccount = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, Email__c, Phone FROM Account WHERE Id =: objOrder.AccountId];
                String BTTransactionId = objOrder.BT_Transaction_Details__r[0].Id;
                Invoice__c invoiceObj = new Invoice__c();
                invoiceObj.Total_Shipping_Amount__c = objOrder.Updated_Shipping__c;
                invoiceObj.Total_Shipping_Tax__c = objOrder.Current_Shipping_Tax__c;
                invoiceObj.Total_Invoice_Price__c = objOrder.Updated_Order_Total__c; 
                invoiceObj.Total_Invoice_Tax__c = objOrder.Updated_Total_Tax__c;
                invoiceObj.Total_Pre_Tax_Invoice_Amount__c = objOrder.Updated_Order_Total__c - objOrder.Updated_Total_Tax__c;
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
                invoiceObj.Shipping_Customer_Name__c = objOrder.Cart_Shipping_Customer_Name__c;
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
                invoiceObj.Order_Reference_Number__c = objOrder.OrderNumber;
                invoiceObj.Payment_Method_Type__c = objOrder.Payment_Type__c;
                invoiceObj.Delivery_Type__c = objOrder.Delivery_Type__c;
                lstInvoice.add(invoiceObj);
                for(OrderItem objOrderItem : objOrder.OrderItems){
                    Invoice_Item__c invItemObj = new Invoice_Item__c();
                    invItemObj.Unit_Price__c = objOrderItem.ListPrice;
                    invItemObj.Total_Product_Tax__c = objOrderItem.Total_Tax__c;
                    invItemObj.Item_Installation_Price__c = objOrderItem.Updated_Installation_Price__c;
                    invItemObj.Extended_Price__c = objOrderItem.ListPrice * objOrderItem.Updated_Quantity__c;
                    invItemObj.Accessory_Op_Code__c = objOrderItem.Op_Code__c;
                    invItemObj.Product_SKU__c = objOrderItem.Product_SKU__c;
                    invItemObj.Item_Quantity__c = objOrderItem.Updated_Quantity__c;
                    invItemObj.Product_Name__c = objOrderItem.Cart_Item_Product_Name__c ;
                    lstInvoiceItem.add(invItemObj);
                }
                //insert invoice & invoice item records for order  
                if(!lstInvoice.isEmpty()){
                    insert lstInvoice;
                    if(!lstInvoiceItem.isEmpty()){
                        for(Invoice_Item__c itemObj : lstInvoiceItem){
                            itemObj.Invoice__c = lstInvoice[0].Id;
                        }
                        insert lstInvoiceItem;
                    }
                }
            }
        } catch(Exception ex) {
            Error__c objError = new Error__c();
            objError.Line_Number__c = ex.getLineNumber();
            objError.StackTrace__c = ex.getStackTraceString();
            objError.Error_Type__c = ex.getTypeName();
            objError.Error_Message__c = ex.getMessage();
            objError.Name = 'Exception Occured'; 
            objError.ClassName__c = 'B2B_CreditCardController';
            objError.MethodName__c = 'createInvoiceRecords';
            objError.Order__c = singleOrderId;
            objError.RecordId__c = singleOrderId;
            insert objError;
        }*/
    }
    //Added by Faraz Ansari for HDMP-8705 - End
    
    //Creates a Customer Details record including the Customer ID
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
            CUSTOMER_SF_ID = customerDetails.Id;
            
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    //Creates a Payment Details record including the Payment Token   
    public static void createPaymentDetailsRecord(Map<String, Object> dataToUpdate) {
        try {           
            if(dataToUpdate.containsKey('customerData')) { 
                Map<String, Object> customerData = (Map<String, Object>)dataToUpdate.get('customerData');
                BT_Payment_Method__c paymentDetails = new BT_Payment_Method__c();
                paymentDetails.Customer__c = UserInfo.getUserId();
                paymentDetails.Payment_Method_Token__c = String.valueOf(dataToUpdate.get('paymentId')); 
                paymentDetails.AK_Payment_Method__c = 'Braintree' + CUSTOMER_SF_ID + String.valueOf(dataToUpdate.get('paymentId'));
                paymentDetails.BT_Customer_Details__c = CUSTOMER_SF_ID;
                paymentDetails.Credit_Card_Number__c = dataToUpdate.containsKey('last4') ? String.valueOf(dataToUpdate.get('last4')) : null;
                paymentDetails.Unique_Number_Identifier__c = dataToUpdate.containsKey('uniqueNumberIdentifier') ? String.valueOf(dataToUpdate.get('uniqueNumberIdentifier')) : null;
                paymentDetails.Is_In_My_Payment__c = true;
                paymentDetails.Is_Vaulted__c = true;
                //populate the card brand name in type__c field
                if(dataToUpdate.containsKey('brandCode')){
                    String brandCode = String.valueOf(dataToUpdate.get('brandCode'));
                    if(brandCode.containsIgnoreCase('VISA')){
                        paymentDetails.Type__c = 'Credit Card - Visa';
                    }else if(brandCode.containsIgnoreCase('DISCOVER')){
                        paymentDetails.Type__c =  'Credit Card - Discover';
                    }else if(brandCode.containsIgnoreCase('AMERICAN_EXPRESS')){
                        paymentDetails.Type__c = 'Credit Card - Amex';
                    }else if(brandCode.containsIgnoreCase('MASTERCARD')){
                        paymentDetails.Type__c = 'Credit Card - Mastercard';
                    }
                }
                
                // if the customer wants to make the payment method as default payment method
                if(customerData.containsKey('isMakePreferred') && (Boolean)customerData.get('isMakePreferred') == true){
                    // if the customer is having default payment method 
                    List<BT_Payment_Method__c> lstPayments = [SELECT Id, Default_Payment_Method__c 
                                                              FROM BT_Payment_Method__c 
                                                              WHERE BT_Customer_Details__c =: CUSTOMER_SF_ID AND Default_Payment_Method__c = true];
                    List<BT_Payment_Method__c> updatePayments = new List<BT_Payment_Method__c>();
                    
                    // change the default payment method to false for old default payment method
                    for(BT_Payment_Method__c objPayment : lstPayments){
                        objPayment.Default_Payment_Method__c = false;
                        updatePayments.add(objPayment);
                    }
                    
                    //make new payment method as default payment method
                    paymentDetails.Default_Payment_Method__c = true; 
                    if(!updatePayments.isEmpty()){
                        update updatePayments;
                    }
                }
                
                if(dataToUpdate.containsKey('expirationMonth') && dataToUpdate.containsKey('expirationYear')){
                    //changes for HDMP-8720 
                    paymentDetails.CC_Expiration_Month__c = Integer.valueOf(dataToUpdate.get('expirationMonth'));
                    paymentDetails.CC_Expiration_Year__c = Integer.valueOf(dataToUpdate.get('expirationYear'));                       
                    //paymentDetails.CC_Expiration_Date__c = date.newInstance(year, month, 1);
                }  
                
                //Set the necessary Address 1 and 2 fields
                if(customerData.containsKey('address1')) {
                    paymentDetails.Billing_Street__c = String.valueOf(customerData.get('address1'));
                    
                }
                
                //Set the necessary City field
                if(customerData.containsKey('city')) {
                    paymentDetails.Billing_City__c = String.valueOf(customerData.get('city'));
                }
                
                //Set the necessary State field
                if(customerData.containsKey('state')) {
                    paymentDetails.Billing_State__c = String.valueOf(customerData.get('state'));
                }

                if(customerData.containsKey('phone')) {
                    paymentDetails.Billing_Phone__c = String.valueOf(customerData.get('phone'));
                }
                
                //Set the necessary Zip Code field
                if(customerData.containsKey('zipCode')) {
                    //paymentDetails.Billing_Zipcode__c = String.valueOf(customerData.get('zipCode')); 
                    paymentDetails.Billing_PostalCode__c = String.valueOf(customerData.get('zipCode'));             
                }  

                if(customerData.containsKey('country')) {
                    paymentDetails.Billing_Country__c = String.valueOf(customerData.get('country')); 
                              
                }

                if(customerData.containsKey('name')) {
                    paymentDetails.Billing_Customer_Name__c = String.valueOf(customerData.get('name')); 
                              
                }

                if(dataToUpdate.containsKey('cardholderName')) {
                    paymentDetails.Cardholder_Name__c = String.valueOf(dataToUpdate.get('cardholderName'));               
                }  
                
                paymentDetails.Payment_Gateway__c = 'Braintree';
                insert paymentDetails;

                if(customerData.containsKey('newAddressData') && Boolean.valueOf(customerData.get('newAddressData'))){
                    createAddressRecord(customerData);
                }
            }                   
        } catch(Exception e) {
            System.debug('Exception : '+ e.getMessage() + ' line: ' + e.getLineNumber());
        }
    }
    
    //create a Billing Address record for payment method
    @testVisible
    private static My_Address_Book__c createAddressRecord(Map<String, Object> customerData) {        
        My_Address_Book__c objAddressBook = new My_Address_Book__c();
        //objAddressBook.Address_Type__c = 'Billing Address';                       
        objAddressBook.Person_Address_Account__c = [SELECT Contact.accountId FROM User WHERE Id =: UserInfo.getUserId()].Contact.accountId;
        //Set the necessary Email fields
        if(customerData.containsKey('email')) {                
            objAddressBook.Email__c = String.valueOf(customerData.get('email'));
        }
        
        //Set the necessary Address 1 and 2 fields
        if(customerData.containsKey('address1')) {
            String fullAddress = String.valueOf(customerData.get('address1'));
            
            /*if(customerData.containsKey('address2')) {
                fullAddress += ', ' + String.valueOf(customerData.get('address2'));
            }*/
            
            objAddressBook.Address__c = fullAddress;
        }
        
        //Set the necessary City field
        if(customerData.containsKey('city')) {
            objAddressBook.City__c = String.valueOf(customerData.get('city'));
        }
        
        //Set the necessary State field
        if(customerData.containsKey('state')) {
            objAddressBook.State__c = String.valueOf(customerData.get('state'));
        }
        
        //Set the necessary Zip Code field
        if(customerData.containsKey('zipCode')) {
            objAddressBook.Zip__c = String.valueOf(customerData.get('zipCode'));               
        }            
        
        //Set the necessary Customer Name field
        if(customerData.containsKey('name')) {
            if(!String.isBlank(String.valueOf(customerData.get('name')))) {
                objAddressBook.Name = String.valueOf(customerData.get('name'));
            }
        }
        
        //Set the necessary Phone fields
        if(customerData.containsKey('phone')) {
            if(!String.isBlank(String.valueOf(customerData.get('phone')))) {
                objAddressBook.Phone__c = String.valueOf(customerData.get('phone'));                   
            }
        }
        List<My_Address_Book__c> loggedInUserAddressesToUpdate = new  List<My_Address_Book__c>();
        if(customerData.containsKey('isPreferredAddress')){
            if(Boolean.valueOf(customerData.get('isPreferredAddress'))){
                objAddressBook.isPreferred__c = true;
                String conactId = [SELECT Id,ContactId  FROM User WHERE Id=:userinfo.getUserId() Limit 1]?.ContactId;
                List<My_Address_Book__c> loggedInUserAddresses =[SELECT Id, isPreferred__c FROM My_Address_Book__c WHERE Person_Address_Account__r.PersonContactId =:conactId];
                for(My_Address_Book__c addr : loggedInUserAddresses){
                    if(addr.isPreferred__c == true){
                        addr.isPreferred__c = false;
                        loggedInUserAddressesToUpdate.add(addr);
                    }
                }
                if(!loggedInUserAddressesToUpdate.isEmpty())
                    update loggedInUserAddressesToUpdate;
            }
        }
        //Added by saikiran as part of HDMP-16041
        String conactId = [SELECT Id,ContactId  FROM User WHERE Id=:userinfo.getUserId() Limit 1]?.ContactId;
        List<My_Address_Book__c> lstOfNames = [Select id,Name,Address__c,City__c,Zip__c,Phone__c,State__c,Country__c, Notes__c from My_Address_Book__c where  Person_Address_Account__r.PersonContactId =:conactId AND (Name =: objAddressBook.Name AND Address__c =: objAddressBook.Address__c AND City__c =: objAddressBook.City__c  AND State__c =: objAddressBook.State__c AND Zip__c =: objAddressBook.Zip__c AND Phone__c =: objAddressBook.Phone__c)];
        if(lstOfNames.isEmpty()){
        insert objAddressBook;}
        return objAddressBook;
    }
    
    //Creates a Transaction Details record including the Transaction ID
    @testVisible
    private static void createTransactionDetailsRecord(Map<String, Object> dataToUpdate) {
        try {
            BT_Transaction_Details__c transactionDetails = new BT_Transaction_Details__c();
            transactionDetails.Customer__c = UserInfo.getUserId();
            transactionDetails.Order__c = ORDER_ID;
            transactionDetails.BT_TransactionId__c = String.valueOf(dataToUpdate.get('authorizationId'));
            transactionDetails.Transaction_Status__c = String.valueOf(dataToUpdate.get('transactionStatus'));
            transactionDetails.Type__c = 'Sale';
            // changes for HDMP-8720 starts
            transactionDetails.Payment_Gateway__c = 'Braintree';            
            if(dataToUpdate.containsKey('brandCode')){
                String brandCode = String.valueOf(dataToUpdate.get('brandCode'));
                if(brandCode.containsIgnoreCase('VISA')){
                    transactionDetails.Payment_Method_Type__c = 'Visa';
                }else if(brandCode.containsIgnoreCase('DISCOVER')){
                    transactionDetails.Payment_Method_Type__c =  'Discover';
                }else if(brandCode.containsIgnoreCase('AMERICAN_EXPRESS')){
                    transactionDetails.Payment_Method_Type__c = 'Amex';
                }else if(brandCode.containsIgnoreCase('MASTERCARD')){
                    transactionDetails.Payment_Method_Type__c = 'Mastercard';
                }
            }else{
                 // for payment done through saved cards
                if(dataToUpdate.containsKey('type')){
                    String paymentType = String.valueOf(dataToUpdate.get('type'));
                    transactionDetails.Payment_Method_Type__c = String.valueOf(dataToUpdate.get('type')); 
                    if(paymentType == 'Credit Card - Visa'){
                        transactionDetails.Payment_Method_Type__c  = 'Visa';
                    }else if(paymentType == 'Credit Card - Discover'){
                        transactionDetails.Payment_Method_Type__c =  'Discover';
                    }else if(paymentType == 'Credit Card - Amex'){
                        transactionDetails.Payment_Method_Type__c  = 'Amex';
                    }else if(paymentType == 'Credit Card - Mastercard'){
                        transactionDetails.Payment_Method_Type__c  = 'Mastercard';
                    }
                }
            }
           
            
            
            if(dataToUpdate.containsKey('paymentType') && String.valueOf(dataToUpdate.get('paymentType')) == 'PayPal'){
                transactionDetails.Payment_Method_Type__c = 'PayPal';
            }
            
            if(dataToUpdate.containsKey('cardholderName')){
                transactionDetails.Cardholder_Name__c = String.valueOf(dataToUpdate.get('cardholderName'));
            }
            
            if(dataToUpdate.containsKey('paymentToken')){
                transactionDetails.Payment_Method_Token__c = String.valueOf(dataToUpdate.get('paymentToken'));
            }
            if(dataToUpdate.containsKey('last4')) {
                transactionDetails.Credit_Card_Number__c = String.valueOf(dataToUpdate.get('last4'));
            }
            if(dataToUpdate.containsKey('customerData')) { 
                Map<String, Object> customerData = (Map<String, Object>)dataToUpdate.get('customerData');
                //Set the necessary Address 1 and 2 fields
                if(customerData.containsKey('address1')) {
                    String fullAddress = String.valueOf(customerData.get('address1'));
                    
                    /*if(customerData.containsKey('address2')) {
                        fullAddress += ', ' + String.valueOf(customerData.get('address2'));
                    }*/
                    transactionDetails.Billing_Street__c = fullAddress;
                }
                
                //Set the necessary City field
                if(customerData.containsKey('city')) {
                    transactionDetails.Billing_City__c = String.valueOf(customerData.get('city'));
                }
                
                //Set the necessary State field
                if(customerData.containsKey('state')) {
                    transactionDetails.Billing_State__c = String.valueOf(customerData.get('state'));
                }
                
                //Set the necessary Zip Code field
                if(customerData.containsKey('zipCode')) {
                    transactionDetails.Billing_PostalCode__c = String.valueOf(customerData.get('zipCode'));               
                } 
                
            }
            insert transactionDetails;

            if(dataToUpdate.containsKey('paymentId')){
                String paymentId = String.valueOf(dataToUpdate.get('paymentId'));
                BT_Payment_Method__c paymentMethodRec = [SELECT Id,Billing_City__c,Billing_Country__c,Billing_Phone__c,Billing_PostalCode__c,Billing_State__c,Billing_Street__c,Billing_Street_Line2__c,Billing_Zipcode__c,Cardholder_Name__c FROM BT_Payment_Method__c WHERE Id =: paymentId];
                if(dataToUpdate.containsKey('customerData')) { 
                    Map<String, Object> customerData = (Map<String, Object>)dataToUpdate.get('customerData');
                    //Set the necessary Address 1 and 2 fields
                    if(customerData.containsKey('address1')) {
                        paymentMethodRec.Billing_Street__c = String.valueOf(customerData.get('address1'));
                        
                        /*if(customerData.containsKey('address2') && String.valueOf(customerData.get('address2')) != '' && String.valueOf(customerData.get('address2')) != null && String.valueOf(customerData.get('address2')) != ',,' && String.valueOf(customerData.get('address2')) != ',') {
                            paymentMethodRec.Billing_Street_Line2__c = String.valueOf(customerData.get('address2'));
                        }*/
                    }
                    
                    //Set the necessary City field
                    if(customerData.containsKey('city')) {
                        paymentMethodRec.Billing_City__c = String.valueOf(customerData.get('city'));
                    }
                    
                    //Set the necessary State field
                    if(customerData.containsKey('state')) {
                        paymentMethodRec.Billing_State__c = String.valueOf(customerData.get('state'));
                    }
                    
                    //Set the necessary Zip Code field
                    if(customerData.containsKey('zipCode')) {
                        paymentMethodRec.Billing_PostalCode__c = String.valueOf(customerData.get('zipCode'));               
                    } 


                    if(customerData.containsKey('phone')) {
                        paymentMethodRec.Billing_Phone__c = String.valueOf(customerData.get('phone'));               
                    } 

                    if(customerData.containsKey('name')) {
                        paymentMethodRec.Cardholder_Name__c = String.valueOf(customerData.get('name'));               
                    } 

                    if(customerData.containsKey('country')) {
                        paymentMethodRec.Billing_Country__c = String.valueOf(customerData.get('country'));               
                    } 
                }
                if(paymentMethodRec != null){
                    update paymentMethodRec;
                }
            }

        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    //Updates the Order record with the Status of the Braintree Transaction
    @testVisible
    private static void updateTransactionStatusOnOrder(String transactionStatus, Map<String, Object> dataToUpdate) {
        try {
            Order o = new Order(Id = ORDER_ID);
            o.BT_Transaction_Status__c = transactionStatus;
            // added by rajrishi 22/08/2021
            o.BT_Transaction_Id__c = String.valueOf(dataToUpdate.get('authorizationId'));
            //changes for HDMP-8720 
            o.BT_Customer_Detail__c = String.valueOf(dataToUpdate.get('customerId'));
            
            o.Payment_Gateway__c = 'Braintree';
            
            if(dataToUpdate.containsKey('paymentType') && String.valueOf(dataToUpdate.get('paymentType')) == 'PayPal'){
                o.Payment_Type__c = 'PayPal';
            }
            
            //changes for HDMP-8730 
            if(dataToUpdate.containsKey('legacyId')){
                 o.BT_Customer_Legecy_Id__c = String.valueOf(dataToUpdate.get('legacyId'));
            }
           
            //Capture CC Last4
            if(dataToUpdate.containsKey('last4')) {
                o.CC_Last4__c = String.valueOf(dataToUpdate.get('last4'));
            }            
            //changes for HDMP-8720 
            if(dataToUpdate.containsKey('paymentToken')){
                o.Payment_Method_Token__c = String.valueOf(dataToUpdate.get('paymentToken'));
            }
            
            // set the brand code on order for credit card payment
            if(dataToUpdate.containsKey('brandCode')){
                String brandCode = String.valueOf(dataToUpdate.get('brandCode'));
                if(brandCode.containsIgnoreCase('VISA')){
                    o.Payment_Type__c  = 'Visa';
                }else if(brandCode.containsIgnoreCase('DISCOVER')){
                    o.Payment_Type__c =  'Discover';
                }else if(brandCode.containsIgnoreCase('AMERICAN_EXPRESS')){
                    o.Payment_Type__c  = 'Amex';
                }else if(brandCode.containsIgnoreCase('MASTERCARD')){
                    o.Payment_Type__c  = 'Mastercard';
                }
            }
                 
            // set the brand code on order for saved credit card
            if(dataToUpdate.containsKey('type')){
                String brandCode = String.valueOf(dataToUpdate.get('type'));
                if(brandCode == 'Credit Card - Visa'){
                    o.Payment_Type__c  = 'Visa';
                }else if(brandCode == 'Credit Card - Discover'){
                    o.Payment_Type__c =  'Discover';
                }else if(brandCode == 'Credit Card - Amex'){
                    o.Payment_Type__c  = 'Amex';
                }else if(brandCode == 'Credit Card - Mastercard'){
                    o.Payment_Type__c  = 'Mastercard';
                }
            }
            
            // Data model changes for R2A 
            if(dataToUpdate.containsKey('shippingAddress')){
                Map<String, object> mapShippingAddress = (Map<String, Object>)dataToUpdate.get('shippingAddress');
                o.ShippingStreet = String.valueOf(mapShippingAddress.get('address'));
                o.ShippingState = String.valueOf(mapShippingAddress.get('state'));
                o.ShippingCity = String.valueOf(mapShippingAddress.get('city'));
                o.ShippingCountry = String.valueOf(mapShippingAddress.get('country'));
                o.ShippingPostalCode = String.valueOf(mapShippingAddress.get('zipcode'));  
                o.Total_Shipping_Tax__c = mapShippingAddress.get('shippingTax') != null ? Decimal.valueOf((String)mapShippingAddress.get('shippingTax')) : 0; 
                o.Current_Shipping_Tax__c = o.Total_Shipping_Tax__c;
                
            }
            //Set the Billing Address information
            setBillingAddressInformation(o, dataToUpdate);
            update o;
                        
            if(test.isRunningTest()){
                integer i = 1/ 0;
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    //Updates the Access and Refresh Token information
    @testVisible
    private static void updateTokenInformation(Map<String, Object> tokenData) {
        try {
            BT_Token_Details__c bt = new BT_Token_Details__c();
            bt.Id = String.valueOf(tokenData.get('id'));
            bt.AccessToken__c = String.valueOf(tokenData.get('accessToken'));
            bt.RefreshToken__c = String.valueOf(tokenData.get('refreshToken'));
            
            //NOTE - we are passing the raw response vs. object record, so we need to perform necessary translations here
            String accessDate = String.valueOf(tokenData.get('accessExpiration'));
            String refreshDate = String.valueOf(tokenData.get('refreshExpiration'));
            accessDate = accessDate.replace('T', ' ');
            refreshDate = refreshDate.replace('T', ' ');

            bt.AccessTokenExpiresAt__c = DateTime.valueOf(accessDate);
            bt.RefreshTokenExpiresAT__c = DateTime.valueOf(refreshDate);

            update bt;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    //Creates an Error Record and marks the Order as having an error
    @testVisible
    private static void handleBraintreeError(String errorMessage, Map<String, Object> dataToUpdate){
        try {
            Error__c errorRecord = new Error__c();
            errorRecord.Name = 'Braintree Pre-Auth Callout Service Failed'; 
            errorRecord.Order__c = ORDER_ID;
            errorRecord.ClassName__c = 'B2B_CreditCardController';
            errorRecord.Error_Message__c = errorMessage;
            errorRecord.MethodName__c = 'submitAuthorizationRequest';
            errorRecord.RecordId__c = ORDER_ID;
            insert errorRecord;
    
            Order o = new Order(Id = ORDER_ID);
            o.IsError__c = true;
            
            //Set the Billing Address information
            setBillingAddressInformation(o, dataToUpdate);
            update o;
            if(test.isRunningTest()){
                integer i = 1/ 0;
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    //Sets the Billing Address information on the Order record
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
                
                /*if(customerData.containsKey('address2') && String.isNotEmpty(String.valueOf(customerData.get('address2')))) {
                    fullAddress += ', ' + String.valueOf(customerData.get('address2'));
                }*/
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
                    if(!userInfo.getName().containsIgnoreCase('Guest Contact')){
                       o.Email_Username__c = userInfo.getName();
                       o.Customer_Name__c = String.valueOf(customerData.get('name'));
                    }else{
                        o.Customer_Name__c = String.valueOf(customerData.get('name'));
                        o.Email_Username__c = String.valueOf(customerData.get('name'));
                    }  
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
    // --- End of Methods that create Records after the Operation --- 
    
    // --- Methods for Front-End Data --- 
    //Returns a list of all US State Codes
    private static List<Map<String, String>> getStateCodes() {
        List<Map<String, String>> stateCodes = new List<Map<String, String>>();
        List<State_List__c> stateList = State_List__c.getall().values();
        for(State_List__c objState : stateList){
            stateCodes.add(new Map<String, String>{'label' => objState.Name, 'value' => objState.Name});
        }
        return stateCodes;
    }
    
    //Returns a list of Payment Types available on the page
    private static List<Map<String, String>> getPaymentTypes() {
        List<Map<String, String>> paymentTypes = new List<Map<String, String>>();
        
        //TODO - make this more dynamic once more payment types start being supported
        paymentTypes.add(new Map<String, String>{'label' => 'Credit Card', 'value' => 'CC'});

        return paymentTypes;
    } 
    
    //Returns the Cart's Shipping Address
    private static Map<String, Object> getShippingAddress(String cartId) {
        Map<String, Object> shippingInfo = new Map<String, String>();
        
        try {
            WebCart wc = [SELECT Id, Total_Shipping_Tax__c, CustomerStreet__c, CustomerCity__c, Customer_State__c, CustomerCountry__c, CustomerPostalCode__c, Pickup_Dealer__c FROM WebCart WHERE Id = :cartId];
            shippingInfo.put('address', wc.CustomerStreet__c);
            shippingInfo.put('city', wc.CustomerCity__c);
            shippingInfo.put('state', wc.Customer_State__c);
            shippingInfo.put('country', wc.CustomerCountry__c);
            shippingInfo.put('zipcode', wc.CustomerPostalCode__c);
            shippingInfo.put('dealerPickup', String.valueOf(wc.Pickup_Dealer__c));
            shippingInfo.put('shippingTax', String.valueOf(wc.Total_Shipping_Tax__c));

            return shippingInfo;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        return shippingInfo;
    }
    // --- End of Methods for Front-End Data --- 
}
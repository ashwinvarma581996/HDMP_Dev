/*
Name: B2B_CreditCardController
Date: 07/09/2021
Description: Controller for the B2B_BraintreeForm component that authorizes a transaction
*/

//Likely without sharing due to need of updating Order and accessing Accounts for Merchant Tokens (could move these to a helper class & define without sharing there vs. class-level)
@SuppressWarnings('PMD.ApexCRUDViolation,PMD.ExcessiveParameterList')
public without sharing class RES_CreditCardController {

    //TODO - consider moving variables to helper/utility method (along with Code called out later in Class)
    //public static Final String BASE_URL = 'callout:HondaBraintreeGraphQL_reservedev';
    public static Final String BASE_URL = RES_Util.getNamedCreds('HondaBraintreeGraphQL');
    public static Final String BRAINTREE_VERSION = '2019-01-01';
    public static Final String CONTENT_TYPE = 'application/json';
    private static Reservation_Session__c sessionState;



    //Retrieves a Client Token from BrainTree for the Hosted Form
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> hostedFormSetup(String cartId) {
        Map<String, Object> returnData = new Map<String, Object>{'success' => false, 'error' => null};
        returnData.put('codes', getStateCodes());
        returnData.put('paymentTypes', getPaymentTypes());


        Map<String,Object> params = new Map<String,Object>() ;
        params.put('cartId',cartId) ;

        setMerchantAndDealerID(params);

        //If Merchant ID or Access Token is null, we cannot proceed with request
        if(String.isBlank((String)params.get('merchantId'))) {
            RES_Logger.log(LoggingLevel.ERROR, 'Merchant ID not found', 'RES_CreditCardController', null, 'Error', null, false);
            returnData.put('error', 'An error occurred. Please try refreshing the page');
        } else {
            String clientToken = requestClientToken((String)params.get('merchantId'));

            if(String.isBlank(clientToken)) {
                RES_Logger.log(LoggingLevel.ERROR, 'Client token is null', 'RES_CreditCardController', null, 'Error', null, false);
            	returnData.put('error', 'An error occurred. Please try refreshing the page.');
            } else {
                returnData.put('success', true);
                returnData.put('token', clientToken);
            }
        }

        return returnData;
    }

    //Creates a Customer, vaults the Payment, and completes a Sale/Authorization Transaction
    @AuraEnabled(cacheable=false)
    public static Object processPayment(String nonce, Map<String, Object> customerData, String cartId, String orderId) {
        Map<String,Object> state = new Map<String,Object>() ;

        Map<String, Object> returnData = new Map<String, Object>{'success' => false, 'error' => null};




        if(!String.isBlank(cartId)) {
            state.put('dataUpdates',new Map<String, Object>());
            state.put('orderId',orderId);
            ((Map<String,Object>)state.get('dataUpdates')).put('orderId', orderId);
            state.put('cartId',cartId) ;
            String customerId = addCustomer(state, returnData, customerData) ;

            if(!String.isBlank(customerId)) {
                //Store the Customer ID for a post-transaction update
                ((Map<String,Object>) state.get('dataUpdates')).put('customerId', customerId);
                //Vault the Payment Method for the nonce and the newly created Customer
                Map<String, Object> result = vaultPaymentMethod(nonce, customerId,state);

                //If the request was successful, submit the pre-authorization request with the new Customer and Payment Method
                if(result != null && result.containsKey('id'))
                {

                    submitAuthorizationRequest(customerId,String.valueof(result.get('id')), returnData,state) ;
                    if ( returnData.get('success') != null && returnData.get('success') == true)
                    {

                        flagReservationAsComplete(cartId) ;
                    }
                    else
                    {

                        returnData.put('error', 'An error occurred while processing the Payment.');
                    }
                }
                else
                {
                    String errMsg = 'An error occurred while valuting the data. Please review and validate the entered information.' ;
                    if ( returnData.containsKey('error')  )
                    {
                        return returnData ;
                    }
                    returnData.put('error', errMsg );
                }
            } else {
               //Error while creating the Customer

                returnData.put('error', 'An error occurred. Please review and validate the entered information.');
            }

            state.put('sessionId',getSession(cartId).id) ;
            state.put('reservationId',getSession(cartId).reservation__c) ;
            state.put('reservationContactId', getSession(cartId).reservation_contact2__c) ;
            handlePostTransactionUpdates(JSON.serialize(state));
            completeReservation(JSON.serialize(state)) ;

            return returnData;
        }

        returnData.put('error', 'An error occurred while processing the Payment.');
        handlePostTransactionUpdates(JSON.serialize(state));
        RES_LeadCreation.postLeadsAsync(getSession(cartId).id) ;
        return returnData;
    }

    //Creates a Customer, vaults the Payment, and completes a Sale/Authorization Transaction
    @AuraEnabled(cacheable=false)
    public static Boolean hasReachedCap(String cartId) {
        Boolean hasReachedCap = false;
        if(!String.isBlank(cartId)) {
            Id reservationCapGroupId = getSession(cartId).Reservation__r.Reservation_Cap_Group__c;
            Boolean isCapActive = getSession(cartId).Reservation__r.Reservation_Cap_Group__r.is_active__c;
            RES_Logger.log(LoggingLevel.DEBUG, 'RESERVATIONS CAP ID: ' + reservationCapGroupId, 'RES_CreditCardController', null, 'Debug', null, false);
            if (!String.isBlank(reservationCapGroupId) && isCapActive) {
                List<Reservation__c> reservations = [SELECT Id, Reservation_Cap_Group__r.Reservation_Cap__c from Reservation__c
                                                        WHERE Reservation_Cap_Group__c = :reservationCapGroupId
                                                        AND Completed__c = true AND Status__c = 'Deposit Made'
                                                    ];
                Integer reservationsListSize = reservations.size();
                RES_Logger.log(LoggingLevel.DEBUG, 'RESERVATIONS SIZE: ' + reservationsListSize, 'RES_CreditCardController', null, 'Debug', null, false);
                if (reservationsListSize > 0) {
                    Decimal capCount = reservations[0].Reservation_Cap_Group__r.Reservation_Cap__c;
                    if (reservationsListSize >= capCount) {
                        hasReachedCap = true;
                    }
                }
            }
        }
        return hasReachedCap;
    }

    private static String addCustomer(Map<String,Object> state, Map<String,Object> returnData, Map<String,Object> customerData){
        state.put('totalAmount',setTotalAmount((String)state.get('cartId')));
        setMerchantAndDealerID(state);

        //If Merchant ID or Access Token is null, we cannot proceed with request
        if(String.isBlank((String)state.get('merchantId'))) {
            try{
                String reservationId = getSession((String)state.get('cartId')).Reservation__c;
                RES_Logger.log(LoggingLevel.ERROR, 'Merchant ID not found', 'RES_CreditCardController', reservationId, 'Error', null, false) ;
                returnData.put('error', 'An error occurred while processing the Payment.');
            }
            catch(Exception e) {} //NOPMD
            return null;
        }

        ((Map<String,Object>) state.get('dataUpdates')).put('customerData', customerData);
        //Create a Customer with the given information
        return createCustomer(customerData,(Map<String,Object>)state.get('dataUpdates'));
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

            if ( resData.containsKey('errors') )
            {
                List<Object> errors = (List<Object>) resData.get('errors') ;
                if ( errors != null && !errors.isEmpty())
                {
                    Map<String,Object> error = (Map<String,Object>) errors[0] ;
                    returnData.put('error', 'Error: ' + String.valueOf(error?.get('message'))  ) ;
                    returnData.put('errName','Vault Payment Failed') ;
                    returnData.put('errMethod', 'vaultPaymentMethod' ) ;
                    return returnData ;
                }
            }
            Map<String, Object> paymentMethodData = null ;
            if(initialData != null && initialData.containsKey('vaultPaymentMethod')) {
                Map<String, Object> vaultPaymentMethodData = (Map<String, Object>)initialData.get('vaultPaymentMethod');

                if(vaultPaymentMethodData != null && vaultPaymentMethodData.containsKey('paymentMethod')) {
                    paymentMethodData = (Map<String, Object>)vaultPaymentMethodData.get('paymentMethod');

                    if(paymentMethodData != null && paymentMethodData.containsKey('id')) {

                        returnData.put('id', String.valueOf(paymentMethodData.get('id')));


                        //Capture CC Last4
                        if(paymentMethodData.containsKey('details')) {
                            Map<String, Object> detailsData = (Map<String, Object>)paymentMethodData.get('details');
                            if(detailsData != null && detailsData.containsKey('last4')) {
                                returnData.put('last4', String.valueOf(detailsData.get('last4')));
                            }
                        }
                    }
                }

                if(paymentMethodData != null && paymentMethodData.containsKey('verification')) {
                    Map<String, Object> verificationData = (Map<String, Object>)paymentMethodData.get('verification');

                    if(verificationData != null && verificationData.containsKey('status')) {
                        returnData.put('status', String.valueOf(verificationData.get('status')));
                    }
                }
            }

            return returnData;
        }

        return null;
    }

    // --- GraphQL Request Methods ---
    //
    //Creates a Base Request for the Braintree GraphQL

    private static HttpRequest createBaseRequest(String method) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL);
        req.setMethod(method);

        req.setHeader('Content-Type', CONTENT_TYPE);
        req.setHeader('Braintree-Version', BRAINTREE_VERSION);

        return req;
    }

    //GraphQL Callout to retrieve a Client Token for the Hosted Form
    @testVisible
    public static String requestClientToken(String MERCHANT_ID) {
        try {
            HttpRequest req = createBaseRequest('POST');

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
            HttpResponse res = http.send(req);
            return parseClientTokenResponse(res.getBody());
        } catch(Exception e) {
            RES_Logger.log(LoggingLevel.ERROR, e.getMessage(), 'RES_CreditCardController', null, 'Error', e, false) ;
            System.debug(e.getMessage());
        }

        return null;
    }

    // --- Methods that set Class Variables ---
    //
    //Sets the Class variable for the Merchant and Dealer IDs
    @testVisible
    public static void setMerchantAndDealerID(Map<String,Object> params) {
        String cartId = (String) params.get('cartId') ;
        try {
            Reservation_Session__c session = getSession(cartId);
            Reservation__c r = [SELECT id, Dealer_Number__c FROM Reservation__c WHERE id = :session.Reservation__c][0] ;
            params.put('dealerId',r.Dealer_Number__c);

            List<Account> merchantAccounts = [SELECT Id, Merchant_Id__c, Code__c FROM Account WHERE PoIId__c  = :r.Dealer_Number__c] ;
            if ( merchantAccounts.isEmpty())
            {
                RES_Logger.log(LoggingLevel.ERROR, 'No merchant found :' + r.dealer_number__c, 'RES_CreditCardController', r.id, 'Error', null, false);
                throw new RES_Exception('Merchant not found.');
            }
            Account merchantAccount = merchantAccounts[0] ;
            params.put('merchantAccountId', merchantAccount.id) ;
            params.put('merchantId', merchantAccount.Merchant_Id__c);
            params.put('merchantCode', merchantAccount.Code__c) ;

        }
        catch(Exception e) {
            try {
                String id = getSession(cartId).Reservation__c ;
                RES_Logger.log(LoggingLevel.ERROR, 'Error setting merchant and dealer id', 'RES_CreditCardController', id, 'Error', e, false);
            }
            catch(Exception ex){} //NOPMD
        }
    }

    //Sets the Access Token for the Class - leverages the existing Access Token if still valid, otherwise, attempts to request a new one via the Refresh Token
    private static void setDealerAuthorizationHeader(Map<String,Object> state) {
        String dealerId = (String)state.get('merchantAccountId');
        try {
            List<BT_Token_Details__c> btTokens = [  SELECT Id, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c
                                                        FROM BT_Token_Details__c
                                                        WHERE Account__c = :dealerId];

            BT_Token_Details__c btDetails = null ;
            if (!btTokens.isEmpty()){
                btDetails = btTokens[0] ;
            }

            //If true, Access Token is expired & a new one needs to be requested
            if( btDetails == null ||  Datetime.now() > btDetails.AccessTokenExpiresAt__c) {
                //Ensure refresh token is still valid
                if(btDetails != null && Datetime.now() < btDetails.RefreshTokenExpiresAT__c) {
                    requestNewAccessToken(btDetails,state);
                }
                else {
                    throw new RES_Exception('Refresh token has expired');
                }
            }
            else {
                state.put('authorizationHeader',btDetails.AccessToken__c);
            }
        }
        catch(Exception e) {
            RES_Logger.log(LoggingLevel.ERROR, e.getMessage(), 'RES_CreditCardController', null, 'Error', e, false) ;
            throw new RES_Exception('Exception thrown while getting authorization header') ;
        }
    }

    //Refreshes the current Access and Refresh Tokens for the current Merchant
    private static void requestNewAccessToken(BT_Token_Details__c btDetails, Map<String,Object> state) {
        String MERCHANT_ID = (String) state.get('merchantId') ;
        Map<String,Object> dataUpdates = (Map<String,Object>) state.get('dataUpdates') ;
        //Request a new Access Token given the current Refresh Token

        String refreshTokenResponse = RES_BrainTreeIntegration.getRefreshToken(MERCHANT_ID, btdetails.RefreshToken__c);
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
            Datetime accessTokenExpDate = datetime.valueOf(objAccessTokenResponseWrapper.credentials.expiresAt.replace('T', ' '));
            accessTokenExpDate.addMinutes(-5);

            DateTime refreshTokenExpDate = DateTime.newInstanceGMT(myDate, myTime);
            String accessToken = objAccessTokenResponseWrapper.credentials.accessToken;
            String refreshToken = objAccessTokenResponseWrapper.credentials.refreshToken;

            tokenInformation.put('accessToken', accessToken);
            tokenInformation.put('refreshToken', refreshToken);
            tokenInformation.put('accessExpiration', accessTokenExpDate);
            tokenInformation.put('refreshExpiration', refreshTokenExpDate);


            dataUpdates.put('tokens', tokenInformation);
            state.put('authorizationHeader',accessToken);
        } else {
            //TODO - should non-200 responses be considered?

        }
    }

      //Refreshes the current Access and Refresh Tokens for the current Merchant
      private static void requestNewAccessTokenNoRefresh(BT_Token_Details__c btDetails, Map<String,Object> state) {
        String MERCHANT_ID = (String) state.get('merchantId') ;
        Map<String,Object> dataUpdates = (Map<String,Object>) state.get('dataUpdates') ;
        //Request a new Access Token given the current Refresh Token
        String refreshTokenResponse = RES_BrainTreeIntegration.getAccessToken(MERCHANT_ID,(String) state.get('merchantCode'));
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
            Datetime accessTokenExpDate = datetime.valueOf(objAccessTokenResponseWrapper.credentials.expiresAt.replace('T', ' '));
            accessTokenExpDate.addMinutes(-5);

            DateTime refreshTokenExpDate = DateTime.newInstanceGMT(myDate, myTime);
            String accessToken = objAccessTokenResponseWrapper.credentials.accessToken;
            String refreshToken = objAccessTokenResponseWrapper.credentials.refreshToken;

            tokenInformation.put('accessToken', accessToken);
            tokenInformation.put('refreshToken', refreshToken);
            tokenInformation.put('accessExpiration', accessTokenExpDate);
            tokenInformation.put('refreshExpiration', refreshTokenExpDate);

            dataUpdates.put('tokens', tokenInformation);
            state.put('authorizationToken',accessToken);
        } else {
            //TODO - should non-200 responses be considered?

        }
    }

    //Sets the Class variable for the Total Amount given a Cart ID
    private static Decimal setTotalAmount(String cartId) {
        try {
            WebCart wc = [SELECT Id, TOTAL__c FROM WebCart WHERE Id = :cartId];

            //TODO - Braintree fails if more than 2 decimals but need to validate how Honda wants it
            return wc.TOTAL__c.setScale(2);
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
        return 500.00 ;
    }
    //
    // --- End of Methods that set Class Variables ---

    //Calls out to the Middleware to perform the pre-authorization
    @testVisible
    private static void submitAuthorizationRequest(String customerId, String paymentToken, Map<String, Object> returnData, Map<String,Object> state) {
        //Need to set the Authorization Header to be the Dealer's Access Token for this request
        try{
            setDealerAuthorizationHeader(state);
        }
        catch(Exception e){
            returnData.put('error', e.getMessage());
            ((Map<String,Object>) state.get('dataUpdates')).put('error', e.getMessage());
            returnData.put('success',false) ;
            return ;
        }
        Map<String,Object> dataUpdates = (Map<String,Object>) state.get('dataUpdates') ;
        String AUTHORIZATION_HEADER = (String) state.get('authorizationHeader') ;
        Decimal TOTAL_AMOUNT = (Decimal) state.get('totalAmount');
        String MERCHANT_ID = (String) state.get('merchantId') ;

        //Store the Payment ID for a post-transaction update
        dataUpdates.put('paymentId', paymentToken);


        String res = RES_BrainTreeIntegration.braintreeTransactionPreAuth(customerID, MERCHANT_ID, AUTHORIZATION_HEADER, String.valueOf(TOTAL_AMOUNT), paymentToken);


        if(res != null) {

            processBTReturn(res,dataUpdates,returnData) ;
            if ( (Boolean)returnData.get('success') != true )
            {
                return ;
            }
        } else {
            returnData.put('error', 'An error occurred while authorizing the Payment.');
            dataUpdates.put('error', 'An error occurred while authorizing the Payment.');
        }

        res = RES_BrainTreeIntegration.braintreeTransactionPostAuth(customerId,MERCHANT_ID,(String) dataUpdates.get('authorizationId') ,String.valueof(TOTAL_AMOUNT), AUTHORIZATION_HEADER) ;

        if(res != null) {
            processBTReturn(res,dataUpdates,returnData) ;
        } else {
            returnData.put('error', 'An error occurred while authorizing the Payment.');
            dataUpdates.put('error', 'An error occurred while authorizing the Payment.');
        }
    }

    public static void completeReservation(String stateData )
    {
        Map<String,Object> state = (Map<String,Object>) JSON.deserializeUntyped(stateData) ;

        String reservationId = (String) state.get('reservationId') ;
        String orderId = (String) state.get('orderId') ;
        try {
            List<OrderSummary> ordSummary = [SELECT OriginalOrder.Id FROM OrderSummary WHERE id = :orderId] ;
            if ( !ordSummary.isEmpty( )){
                orderId = ordSummary[0].OriginalOrder.Id ;
            }
        }
        catch(Exception e){ //NOPMD
            // do nothing
        }

        try {
            Map<String,Object> dataUpdates = (Map<String,Object>) state.get('dataUpdates') ;
            Reservation__c reservation = new Reservation__c( id = reservationid) ;
            reservation.Completed__c = dataUpdates.get('success') == true ? true : false ;
            reservation.Status__c = dataUpdates.get('success') == true ? 'Deposit Made' : 'Deposit Failed' ;
            reservation.Order__c = orderId ;
            String authCode = (String) dataUpdates.get('authorizationId') ;
            reservation.Approval_Code__c =  authCode  ;
            RES_Logger.log(LoggingLevel.DEBUG, 'Completing Reservation: ' + reservation, 'RES_CreditCardController', null, 'Lead', null, false);
            RES_Logger.log(LoggingLevel.DEBUG, 'Completing Reservation BT Code: ' + authCode, 'RES_CreditCardController', null, 'Lead', null, false);
            update reservation ;
        }
        catch(Exception e)
        {
            RES_Logger.log(LoggingLevel.DEBUG, 'Unable to update reservation.  ' + e.getMessage(), 'RES_CreditCardController', reservationId, 'Error', e, false) ;
        }
    }

    /**
    * @description This method parses the return of the BT auth and settle calls.  The authorization id and status are written to data updates.  In the event of an
    *               the provider error detail will be set in error.
    * @author mbunch@gorillagroup.com | 03-28-2022
    * @param String res
    * @param Map<String Object> dataUpdates
    * @param Map<String Object> returnData
    **/
    @TestVisible
    private static void processBTReturn(String res, Map<String,Object> dataUpdates, Map<String,Object> returnData)
    {
        try {
            System.debug(res) ;
            Map<String, Object> authResponse = (Map<String, Object>)JSON.deserializeUntyped(res);

            if(authResponse != null) {
                if(authResponse.containsKey('status')) {
                    Integer status = Integer.valueOf(authResponse.get('status'));

                    if(status == 200 && authResponse.containsKey('transactionBT')) {
                        Map<String, Object> transactionResponse = (Map<String, Object>)authResponse.get('transactionBT');
                        dataUpdates.put('authorizationId', String.valueOf(transactionResponse.get('id')));
                        returnData.put('authorizationId',dataUpdates.get('authorizationId'));
                        dataUpdates.put('transactionStatus', String.valueOf(transactionResponse.get('status')));
                        returnData.put('success', true);
                        dataUpdates.put('success',true);
                        return;
                    }
                    else {
                        //If we have a response from Braintree, leverage this info and return
                        returnData.put('success', false) ;
                        dataUpdates.put('success',false) ;
                        dataUpdates.put('error', String.valueOf(authResponse.get('errorMessage')));
                        returnData.put('error', 'An error occurred while authorizing the Payment.');
                        return;
                    }
                }
            }

            //Put in generic message to be passed to Error__c record
            dataUpdates.put('error', 'An error occurred while authorizing the Payment.');
        } catch(Exception e) {
            //Pass exception message to Error__c record if an exception occurred
            dataUpdates.put('error', e.getMessage());
        }

        returnData.put('error', 'An error occurred while authorizing the Payment.');
    }


    // --- Methods that parse GraphQL Responses ---
    //
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

    //
    // --- End of Methods that parse GraphQL Responses ---



    // --- Methods that create Records after the Operation ---
    //
    //Future Method called at the end of the operation to create all necessary records (Braintree Detail records, Access/Refresh Token records, Error records, etc.)
    @future(callout=true)
    private static void handlePostTransactionUpdates(String stateData) {
        Map<String,Object> state = (Map<String,Object>) JSON.deserializeUntyped(stateData) ;
        Map<String, Object> dataToUpdate = (Map<String, Object>) state.get('dataUpdates') ;
        Reservation_Session__c sessionState = getSession((String) state.get('cartId')) ;

        //If the Order ID exists, create the subsequent child records
        try {
            if(dataToUpdate.containsKey('orderId')) {
                String ORDER_ID = String.valueOf(dataToUpdate.get('orderId'));

                try {

                    //If an error occured, create an Error record and update the Order record
                    if(dataToUpdate.containsKey('error')) {
                        handleBraintreeError(dataToUpdate);
                    }

                    //Create the Braintree Payment Details record
                    if(dataToUpdate.containsKey('paymentId')) {
                        createPaymentDetailsRecord(String.valueOf(dataToUpdate.get('paymentId')),String.valueOf(dataToUpdate.get('authorizationId')),(String)state.get('orderId'),sessionState.Reservation_Contact2__c);
                    }

                    updateTransactionStatusOnOrder(String.valueOf(dataToUpdate.get('transactionStatus')), dataToUpdate,(String)state.get('orderId'));
                }
                catch(Exception e){
                    RES_Logger.log(LoggingLevel.ERROR, 'Exception in post processing of order: ' + e.getMessage(), 'RES_CreditCardController', null, 'Error', e, true);
                }

            }

            //Update the Access/Refresh Token information (NOTE: if Transaction failed but tokens were refreshed, these need to be saved)
            if(dataToUpdate.containsKey('tokens')) {
                Map<String, Object> tokenData = (Map<String, Object>)dataToUpdate.get('tokens');
                updateTokenInformation(tokenData);
            }
        }
        catch(Exception e)
        {
            RES_Logger.log(LoggingLevel.ERROR, 'exception in handlePostTransactionUpdates ' + e.getMessage(), 'RES_CreditCardController', null, 'Error', e, true) ;
        }

        RES_Logger.flush();
    }

    //Creates a Customer Details record including the Customer I
        //GraphQL Callout to create a Customer with given information
        public static String createCustomer(Map<String, Object> customerData, Map<String,Object> dataUpdates) {
            if(customerData == null) {
                return null;
            }
            //Store the Customer Data for the future method
            dataUpdates.put('customerData', customerData);

            try {
                HttpRequest req = createBaseRequest('POST');

                Map<String, Object> graphQl = new Map<String, Object>();

                //Create base Query and Variables structure
                graphQl.put('query', 'mutation createCustomer($input: CreateCustomerInput) { createCustomer(input: $input) { customer { id } } }');
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
                HttpResponse res = http.send(req);


                return parseCreateCustomerResponse(res.getBody());

            } catch(Exception e) {
                System.debug(e.getMessage());
            }

            return null;
        }

    //GraphQL Callout to vault the Payment Method
    public static Map<String, Object> vaultPaymentMethod(String nonce, String customerId, Map<String,Object> state) {
        try {
            HttpRequest req = createBaseRequest('POST');

            Map<String, Object> graphQl = new Map<String, Object>();

            //TODO - review fields included in mutation and also returned from mutation
            //Create base Query and Variables structure


            //Capture CC Last4
            graphQl.put('query', 'mutation  vaultPaymentMethod($input: VaultPaymentMethodInput!) { vaultPaymentMethod(input: $input) { paymentMethod { id legacyId details{ __typename ...on CreditCardDetails{last4} }} verification { status } } }');

            graphQl.put('variables', new Map<String, Object>());

            //input > paymentMethodId, customerId
            Map<String, String> inputMap = new Map<String, String>();
            inputMap.put('paymentMethodId', nonce);
            inputMap.put('customerId', customerId);
            ((Map<String, Object>)graphQl.get('variables')).put('input', inputMap);


            req.setBody(JSON.serialize(graphQl));
            Http http = new Http();
            HttpResponse res = http.send(req);



            return parseVaultPaymentResponse(res.getBody());
        } catch(Exception e) {
            RES_Logger.log(LoggingLevel.ERROR, 'vault exception ' + e.getMessage(), 'RES_CreditCardController',null,'Error',e,false) ;
        }

        return null;
    }

    //Creates a Payment Details record including the Payment Token
    @testVisible
    private static void createPaymentDetailsRecord(String paymentId, String authorizationId, String ORDER_ID, string contactId) {
        try {
            Reservation_Payment__c paymentDetails = new Reservation_Payment__c();
            paymentDetails.Customer__c = contactId ;
            paymentDetails.Order__c = ORDER_ID;
            paymentDetails.Payment_Method_Token__c = paymentId;
            paymentDetails.BT_TransactionId__c = authorizationId;
            insert paymentDetails;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }


    //Updates the Order record with the Status of the Braintree Transaction
    @testVisible
    private static void updateTransactionStatusOnOrder(String transactionStatus, Map<String, Object> dataToUpdate, String ORDER_ID) {
        try {
            Order o = new Order(Id = ORDER_ID);
            o.BT_Transaction_Status__c = transactionStatus;
            // added by rajrishi 22/08/2021
            o.BT_Transaction_Id__c = String.valueOf(dataToUpdate.get('authorizationId'));
            //Capture CC Last4
            if(dataToUpdate.containsKey('last4')) {
                o.CC_Last4__c = String.valueOf(dataToUpdate.get('last4'));
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
            insert new Res_Log__c(Log_Data__c = 'exception processing new token ' + e.getmessage()) ;
            System.debug(e.getMessage());
        }
    }

    //Creates an Error Record and marks the Order as having an error
    @testVisible
    private static void handleBraintreeError(Map<String, Object> dataToUpdate){
        try {
            String errMessage = (String) dataToUpdate.get('error') ;
            String orderId = (String)dataToUpdate.get('orderId') ;
            String name = (String) dataToUpdate.get('errName') ;
            String method = (String) dataToUpdate.get('errMethod') ;
            Reservation_Error__c errorRecord = new Reservation_Error__c();
            errorRecord.Name =  name == null ? 'Braintree Service Failed' : name ;
            errorRecord.Order__c = orderId;
            errorRecord.ClassName__c = 'RES_CreditCardController';
            errorRecord.Error_Message__c =errMessage;
            errorRecord.MethodName__c = method == null ? 'unknown' : method;
            errorRecord.RecordId__c = orderId ;
            Database.SaveResult sr =  Database.insert( errorRecord );
            if ( ! sr.isSuccess())
            {

            }

            Order o = new Order(Id = orderId);
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
                o.Email__c = String.valueOf(customerData.get('email'));
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
                o.BillingZip__c = String.valueOf(customerData.get('zipCode'));
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
                    o.Phone_No__c = String.valueOf(customerData.get('phone'));
                    o.BillingPhoneNumber = String.valueOf(customerData.get('phone'));
                }
            }

        }
    }
    //
    // --- End of Methods that create Records after the Operation ---



    // --- Methods for Front-End Data ---
    //
    //Returns a list of all US State Codes
    private static List<Map<String, String>> getStateCodes() {
        List<Map<String, String>> stateCodes = new List<Map<String, String>>();

        //Source: https://www.ssa.gov/international/coc-docs/states.html (all codes except District of Columbia)
        for(String s : new List<String>{'AK','AL','AR','AS','AZ','CA','CO','CT','DC','DE','FL','GA','GU','HI','IA','ID','IL','IN','KS','KY','LA','MA','MD','ME','MI','MN','MO','MP','MS','MT','NC','ND','NE','NH','NJ','NM','NV','NY','OH','OK','OR','PA','PR','RI','SC','SD','TN','TX','UT','VA','VI','VT','WA','WI','WV','WY'}) {
            stateCodes.add(new Map<String, String>{'label' => s, 'value' => s});
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

    //
    // --- End of Methods for Front-End Data ---

    public static Reservation_Session__c getSession(String cartId) {
        List<Reservation_Session__c> sessions =  [SELECT Cart__c, Reservation__c, Reservation__r.Reservation_Cap_Group__c, Reservation__r.Reservation_Cap_Group__r.is_active__c, Reservation_Contact2__c FROM Reservation_Session__c WHERE Cart__c = :cartId ORDER BY CreatedDate DESC];
        if ( sessions.size() > 0 )
        {
            return sessions[0];
        }
        throw new RES_Exception('no session found');
    }

    @TestVisible
    private static void flagReservationAsComplete(String cartId)
    {
        Reservation_Session__c session = getSession(cartId) ;
        Reservation__c reservation = new Reservation__c(id = session.Reservation__c, Completed__c = true) ;
        update reservation ;
    }

    @AuraEnabled
    //this returns a map of a reservation object to the
    //RES_BraintreeFormHelper Aura Component called from the
    //getTaggingFields function on line ~92 and returned to
    //the Aura funciton getTaggingFields_callback Line ~101
    public static Map<String, String> getTaggingFields(String cartId) {
        try {
            Reservation__c r = [SELECT id, Model_Name__c, Model_Year__c, Package_Name__c, Vehicle_Model_Body_Style__c, Deposit_Amount__c, Vehicle_Model_Series__c FROM Reservation__c WHERE id = :getSession(cartId).Reservation__c];
            Map<String,String> rv = new Map<String,String>();
            rv.put('modelName',r.Model_Name__c);
            rv.put('modelYear', r.Model_Year__c);
            rv.put('bodyStyle', r.Vehicle_Model_Body_Style__c);
            rv.put('depositAmount', String.valueOf(r.Deposit_Amount__c));
            rv.put('vehicleModelSeries',r.Vehicle_Model_Series__c);
            return rv ;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
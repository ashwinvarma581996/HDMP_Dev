/**********************************************************************
Name: RES_BrainTreeIntegration
Purpose: Contains all the methods for BrainTree
Date : June 07 2022
*************************************************************/

public class RES_BrainTreeIntegration {

    /*
    Description : This method is used to get the access token and refresh token by passing a merchantId and code.
    */
    public static string getAccessToken(String merchantID, String code){
        B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();
        try{
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('GET','','');
            //String endpoint = 'https://ws-dev.hondaweb.com/REST/B2C/BTPaymentServices/1.0/access-token/merchantID/'+merchantID+'/code/'+code;
            String endpoint = 'callout:Braintree_Named_Credential' + '/access-token/merchantID/'+merchantID+'/code/'+code;
            request.setEndpoint(endpoint);
            String guId = B2B_Util.createGui();
            request.setHeader('hondaHeaderType.messageId', guId);
       		request.setHeader('accept', 'application/json');
            //request.setHeader('Authorization', 'Basic c2VydmljZV9CMkNCcmFpbnRyZWVfU0ZfRGV2OkNhYmxlQDE3NTI');

            Http http = new Http();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
              	System.debug('AccessToken '+response.getBody());
                objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) System.JSON.deserialize(response.getBody(), B2B_AccessTokenResponseWrapper.class);
                System.debug('testDebug'+objAccessTokenResponseWrapper);
                return JSON.serialize(objAccessTokenResponseWrapper);
            }else {
                objAccessTokenResponseWrapper.status = response.getStatusCode();
                objAccessTokenResponseWrapper.errorMessage = response.getStatus();
                return JSON.serialize(objAccessTokenResponseWrapper);
            }
        }catch(Exception ex){
            RES_Logger.log(LoggingLevel.DEBUG, 'BT integration', ex.getMessage(), null, null, null, true);
            System.debug('exception' + ex.getMessage());
            objAccessTokenResponseWrapper.errorMessage = ex.getMessage();
            objAccessTokenResponseWrapper.status = 400;
            return JSON.serialize(objAccessTokenResponseWrapper);
        }

    }

    /*
    Description : This method is used to get the access token and refresh token by passing a merchantId and refreshToken.
    */
    public static string getRefreshToken(String merchantID,String refreshToken){
        B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();
        try{
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('GET','','');
            String endpoint = 'callout:Braintree_Named_Credential' + '/refreshed-tokens/merchantID/'+merchantID+'/refresh-token/'+refreshToken;
            request.setEndpoint(endpoint);
            String guId = B2B_Util.createGui();
            request.setHeader('hondaHeaderType.messageId', guId);
       		request.setHeader('accept', 'application/json');
            Http http = new Http();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                System.debug('RefreshToken '+response.getBody());
                objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) System.JSON.deserialize(response.getBody(), B2B_AccessTokenResponseWrapper.class);
                System.debug('testDebug'+objAccessTokenResponseWrapper.status);
                return JSON.serialize(objAccessTokenResponseWrapper);
            }else {
                objAccessTokenResponseWrapper.status = response.getStatusCode();
                objAccessTokenResponseWrapper.errorMessage = response.getStatus();
                return JSON.serialize(objAccessTokenResponseWrapper);
            }
        }catch(Exception ex){
            System.debug('exception' + ex.getMessage());
            objAccessTokenResponseWrapper.errorMessage = ex.getMessage();
            objAccessTokenResponseWrapper.status = 400;
            return JSON.serialize(objAccessTokenResponseWrapper);
        }
    }

    /*
    Description : This method is used for creating a transaction having authorized status at braintree server.
	*/
    public static String braintreeTransactionPreAuth(String customerID, String merchantID, String accessToken, String saleAmount, String paymentToken){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{
            //String reqBody ='{"customerID": "'+customerID+'","merchantID": "'+merchantID+'", "paymentToken": "009","saleAmount": "'+saleAmount+'","accessToken": "'+accessToken+'"}';
            String reqBody ='{"customerID": "'+customerID+'","merchantID": "'+merchantID+'","saleAmount": "'+saleAmount+'","paymentToken": "'+paymentToken+'","accessToken": "'+accessToken+'"}';

            HttpRequest request = new HttpRequest();
            request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'pre-auth');
            System.debug('request' + request.getBody());
            Http http = new Http();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                System.debug('response' + JSON.serialize(request.getEndpoint() + request.getMethod()));
                System.debug('body:' + response.getBody());
                String responseBody = response.getBody();

                System.debug('PreAuthResponse '+response.getBody());
                Map<String,Object> mapVoidResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Integer status = Integer.valueOf(mapVoidResponse.get('status'));
                if(status == 200){
                    Map<String,Object> mapTransaction = (Map<String,Object>) mapVoidResponse.get('transaction');
                    objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parseTransactionData(objBrainTreeTransactionResponse, responseBody, mapTransaction);
                }else{
                    objBrainTreeTransactionResponse.errorMessage = JSON.serialize(mapVoidResponse.get('errorMessage'));
                    objBrainTreeTransactionResponse.status = status;
                }
            }else {
                objBrainTreeTransactionResponse.status = response.getStatusCode();
                objBrainTreeTransactionResponse.errorMessage = response.getStatus();
            }
        }catch(Exception ex){
            RES_Logger.log(LoggingLevel.DEBUG, 'BT integration', ex.getMessage(), null, null, null, true);
            objBrainTreeTransactionResponse.errorMessage = ex.getMessage();
            objBrainTreeTransactionResponse.status = 400;
        }
        System.debug('objBrainTreeTransactionResponse : ' + objBrainTreeTransactionResponse);
        return JSON.serialize(objBrainTreeTransactionResponse);

    }

    /*
    Created By :Rajrishi Kaushik
    Description : This method is used for changing the status of transaction from authorized to submitted_for_settlement.
    */
    public static String braintreeTransactionPostAuth(String customerID, String merchantID,String transactionID, String amount, String accessToken){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{
            //String reqBody = '{"customerID": "'+customerID+'", "merchantID": "'+merchantID+'", "transactionID": "'+transactionID+'", "accessToken": "'+accessToken+'"}';
            String reqBody = '{"customerID": "'+customerID+'", "merchantID": "'+merchantID+'", "transactionID": "'+transactionID+'", "amount": '+amount+', "accessToken": "'+accessToken+'"}';
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'post-auth');
            Http http = new Http();
            System.debug('*reqBody: '+reqBody);
            System.debug('*request: '+request);
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                System.debug('body:' + response.getBody());
                String responseBody = response.getBody();
                System.debug('PostAuthResponse '+response.getBody());
                Map<String,Object> mapVoidResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Integer status = Integer.valueOf(mapVoidResponse.get('status'));
                if(status == 200){
                    Map<String,Object> mapTransaction = (Map<String,Object>) mapVoidResponse.get('transaction');
                    objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parseTransactionData(objBrainTreeTransactionResponse, responseBody, mapTransaction);
                }else{
                    objBrainTreeTransactionResponse.errorMessage = JSON.serialize(mapVoidResponse.get('errorMessage'));
                    objBrainTreeTransactionResponse.status = status;
                }
            }else {
                objBrainTreeTransactionResponse.status = response.getStatusCode();
                objBrainTreeTransactionResponse.errorMessage = response.getStatus();
            }
        }catch(Exception ex){
            RES_Logger.log(LoggingLevel.DEBUG, 'BT integration', ex.getMessage(), null, null, null, true);
            objBrainTreeTransactionResponse.errorMessage = ex.getMessage();
            objBrainTreeTransactionResponse.status = 400;
        }
        System.debug('objBrainTreeTransactionResponse : ' + objBrainTreeTransactionResponse);
        return JSON.serialize(objBrainTreeTransactionResponse);
    }

    /*
    Description : This method is used for making a callout at braintree server for refunding of the transaction.
    */
    public static String braintreeTransactionRefund(String customerID, String merchantID, String transactionID, String accessToken,String refundAmount){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{
            String reqBody = '';
            if(String.isNotEmpty(refundAmount)){
                reqBody = '{"customerID": "'+customerID+'", "merchantID": "'+merchantID+'", "transactionID": "'+transactionID+'", "refundAmount": '+refundAmount+', "accessToken": "'+accessToken+'"}';
            }else {
                reqBody = '{"customerID": "'+customerID+'", "merchantID": "'+merchantID+'", "transactionID": "'+transactionID+'", "accessToken": "'+accessToken+'"}';
            }
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'refund');
            Http http = new Http();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                System.debug('body:' + response.getBody());
                String responseBody = response.getBody();
                System.debug('RefundResponse '+response.getBody());
                Map<String,Object> mapVoidResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Integer status = Integer.valueOf(mapVoidResponse.get('status'));
                if(status == 200){
                    Map<String,Object> mapTransaction = (Map<String,Object>) mapVoidResponse.get('transaction');
                    objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parseTransactionData(objBrainTreeTransactionResponse, responseBody, mapTransaction);
                }else{
                    objBrainTreeTransactionResponse.errorMessage = JSON.serialize(mapVoidResponse.get('errorMessage'));
                    objBrainTreeTransactionResponse.status = status;
                }
            }else {
                objBrainTreeTransactionResponse.status = response.getStatusCode();
                objBrainTreeTransactionResponse.errorMessage = response.getStatus();
            }
        }catch(Exception ex){
            objBrainTreeTransactionResponse.errorMessage = ex.getMessage();
            objBrainTreeTransactionResponse.status = 400;
        }
        System.debug('objBrainTreeTransactionResponse : ' + objBrainTreeTransactionResponse);
        return JSON.serialize(objBrainTreeTransactionResponse);
    }

    /*
    Description : This method is used for making a callout at braintree server for cancelling the order.
    */
    public static String braintreeTransactionVoid(String customerID, String merchantID, String transactionID, String accessToken){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{
            String reqBody = '{"customerID": "'+customerID+'", "merchantID": "'+merchantID+'", "transactionID": "'+transactionID+'", "accessToken": "'+accessToken+'"}';
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'void');
            Http http = new Http();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                System.debug('body:' + response.getBody());
                String responseBody = response.getBody();
                System.debug('VoidResponse '+response.getBody());
                Map<String,Object> mapVoidResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Integer status = Integer.valueOf(mapVoidResponse.get('status'));
                if(status == 200){
                    Map<String,Object> mapTransaction = (Map<String,Object>) mapVoidResponse.get('transaction');
                    objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parseTransactionData(objBrainTreeTransactionResponse, responseBody, mapTransaction);
                }else{
                    objBrainTreeTransactionResponse.errorMessage = JSON.serialize(mapVoidResponse.get('errorMessage'));
                    objBrainTreeTransactionResponse.status = status;
                }
            }else {
                objBrainTreeTransactionResponse.status = response.getStatusCode();
                objBrainTreeTransactionResponse.errorMessage = response.getStatus();
            }
        }catch(Exception ex){
            objBrainTreeTransactionResponse.errorMessage = ex.getMessage();
            objBrainTreeTransactionResponse.status = 400;
        }
        System.debug('objBrainTreeTransactionResponse : ' + objBrainTreeTransactionResponse);
        return JSON.serialize(objBrainTreeTransactionResponse);
    }

    public static List<OrderItem> revertOrderItemChanges(List<OrderItem> lstOrderItems){
        List<OrderItem> revertOrderItems = new List<OrderItem>();
        for(OrderItem objOrderItem : lstOrderItems){
           objOrderItem.Updated_Quantity__c += objOrderItem.Delta_Quantity__c;
           objOrderItem.Return_Quantity__c -= objOrderItem.Delta_Quantity__c;
           objOrderItem.Delta_Quantity__c = 0;
           revertOrderItems.add(objOrderItem);
        }
        return revertOrderItems;
    }

   	/* ---------- Future Method Starts -----------*/
    /*
    Date : 11/07/2021
    Description : this method is used for cancelling the customer order.
    */
    @future(callout=true)
    public static void braintreeOrderCancellation(Set<Id> setOrderIds, Set<Id> setAccountIds, Map<Id, String> mapOldOrderStatus, String methodName){
        List<BT_Token_Details__c> lstBTTokenDetailsUpdate = new List<BT_Token_Details__c>();
        List<Order> lstOrderUpdate = new List<Order>();
        List<OrderItem> lstOrderItemUpdate = new List<OrderItem>();
        List<OrderItem> lstOrderItemReturnUpdate = new List<OrderItem>();
        List<Error__c> lstErrors = new List<Error__c>();
        List<Order_Return__c> lstOrderReturns = new List<Order_Return__c>();
        List<Order_Item_Return__c> lstOrderItemReturns = new List<Order_Item_Return__c>();
        List<BT_Transaction_Details__c> lstBTTransactionDetails = new List<BT_Transaction_Details__c>();

        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();

        List<Account> lstAccounts = [SELECT Id, Merchant_Id__c, PoIId__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, (SELECT Id, Name, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c, Account__c FROM BT_Token_Details__r)
                                     FROM Account WHERE Id IN: setAccountIds];

        List<Order> lstOrders = [SELECT Id, AccountId, Current_Return_Amount__c, BT_Transaction_Id__c, Current_Return_Tax__c, Status, cart__r.Pickup_Dealer__c , cart__r.ShippingAmount__c , cart__r.CustomerStreet__c, cart__r.CustomerCity__c, cart__r.Customer_State__c, cart__r.CustomerPostalCode__c, Send_Email_To_Customer__c, Updated_Order_Total__c, Updated_Total_Tax__c, Updated_Order_Amount__c,
                                 BT_Transaction_Status__c, IsError__c, cart__c, (SELECT Id, Name, BT_TransactionId__c,Customer__c FROM BT_Transaction_Details__r),
                                 (SELECT Id, BT_CustomerId__c FROM BT_Customer_Details__r), (SELECT Id, Delta_Quantity__c,Updated_Quantity__c,Return_Quantity__c, Quantity, UnitPrice, Total_Tax__c FROM OrderItems WHERE Type != 'Delivery Charge')
                                 FROM Order
                                 WHERE Id IN: setOrderIds];

        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        for(Account objAccount : lstAccounts){
            mapAccounts.put(objAccount.Id, objAccount);
        }


        for(Order objOrder : lstOrders){
            try{
                String brainTreeResponse = '';
                Account objAccount = mapAccounts.get(objOrder.AccountId);
                //check for the BT_Token_Details__c object is not equals to null
                if(!objAccount.BT_Token_Details__r.isEmpty()){
                    BT_Token_Details__c objBTTokenDetails = objAccount.BT_Token_Details__r[0];

                    //check for the related Transaction and Customer object is not equals to null
                    if(objOrder.BT_Customer_Details__r.isEmpty() == false && objOrder.BT_Transaction_Details__r.isEmpty() == false){
                        String customerId = objOrder.BT_Customer_Details__r[0].BT_CustomerId__c;
                        String transactionID = objOrder.BT_Transaction_Id__c;
                        if(objBTTokenDetails.AccessTokenExpiresAt__c > System.now()){
                            Decimal refundAmount = 0;
                            Decimal refundTax = 0;
                            Decimal totalRefundAmount = 0;
                            Decimal fullRefundAmount = 0;
                            if(methodName == 'void'){
                                // make callout to braintree void api
                                brainTreeResponse = braintreeTransactionVoid(customerID, objAccount.Merchant_Id__c, transactionID, objBTTokenDetails.AccessToken__c);
                            }else if(methodName == 'refund'){
                                if(objOrder.cart__r.Pickup_Dealer__c == false){
                                    for(OrderItem objOrderItem : objOrder.OrderItems){
                                        Decimal taxPerItem = (objOrderItem.Total_Tax__c / objOrderItem.Quantity).setScale(2);
                                        refundTax += objOrderItem.Updated_Quantity__c * taxPerItem;
                                    }
                                    fullRefundAmount = objOrder.Updated_Order_Amount__c + refundTax;
                                }else {
                                    refundTax = objOrder.Updated_Total_Tax__c;
                                    fullRefundAmount = objOrder.Updated_Order_Total__c;
                                }
                                fullRefundAmount = fullRefundAmount.setScale(2);
                                // make callout to braintree refund api
                                brainTreeResponse = braintreeTransactionRefund(customerID, objAccount.Merchant_Id__c, transactionID, objBTTokenDetails.AccessToken__c, String.valueOf(fullRefundAmount));
                            }else if(methodName == 'partial return'){
                                // make callout to braintree refund api with the return amount
                                // to do
                                // calculate the amount from order items for passing to refund call

                                for(OrderItem objOrderItem : objOrder.OrderItems){
                                    if(objOrderItem.Delta_Quantity__c != 0){
                                        refundAmount += objOrderItem.Delta_Quantity__c * objOrderItem.UnitPrice;
                                        Decimal taxPerItem = objOrderItem.Total_Tax__c / objOrderItem.Quantity;
                                        refundTax += objOrderItem.Delta_Quantity__c * taxPerItem;
                                    }
                                }

								totalRefundAmount = refundAmount + refundTax;
                                totalRefundAmount = totalRefundAmount.setScale(2);
                                System.debug('totalRefundAmount' + String.valueOf(totalRefundAmount));
                                System.debug('refundAmount' + String.valueOf(refundAmount));
                                System.debug('refundTax' + String.valueOf(refundTax));
                                brainTreeResponse = braintreeTransactionRefund(customerID, objAccount.Merchant_Id__c, transactionID, objBTTokenDetails.AccessToken__c, String.valueOf(totalRefundAmount));
                            }
                            objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parse(brainTreeResponse);
                            System.debug('objBrainTreeTransactionResponse 1 :' + objBrainTreeTransactionResponse);

                            //check if the response status is 200
                            if(objBrainTreeTransactionResponse.status == 200){
                                System.debug('Order is successfully cancelled');
                                if(methodName != 'partial return'){
                                   objOrder.BT_Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                }
                                objOrder.IsError__c = false;
                                objOrder.Send_Email_To_Customer__c = true;
                                if(methodName == 'partial return'){
                                    objOrder.Status = 'PARTIAL RETURN';
                                    objOrder.Updated_Order_Amount__c = objOrder.Updated_Order_Amount__c - refundAmount;
                                    objOrder.Updated_Total_Tax__c = objOrder.Updated_Total_Tax__c - refundTax;
                                    objOrder.Updated_Order_Total__c = objOrder.Updated_Order_Total__c - totalRefundAmount;
                                    // current return values
                                    objOrder.Current_Return_Amount__c = refundAmount;
                                    objOrder.Current_Return_Tax__c = refundTax;

                                    Order_Return__c objOrderReturn = new Order_Return__c();
                                    objOrderReturn.Order__c = objOrder.Id;
                                    objOrderReturn.Total_Amount__c = totalRefundAmount;
                                    objOrderReturn.Total_Tax__c = refundTax;
                                    objOrderReturn.Subtotal__c = refundAmount;
                                    objOrderReturn.Status__c = 'PARTIAL RETURN';
                                    lstOrderReturns.add(objOrderReturn);

                                    for(OrderItem objOrderItem : objOrder.OrderItems){
                                        //add order item return object
                                        if(objOrderItem.Delta_Quantity__c != 0){
                                            Order_Item_Return__c objOrderItemReturn = new Order_Item_Return__c();
                                            objOrderItemReturn.Order_Product__c = objOrderItem.Id;
                                            objOrderItemReturn.Return_Quantity__c = objOrderItem.Delta_Quantity__c;
                                            lstOrderItemReturns.add(objOrderItemReturn);
                                        }
                                    }
                                }

                                if(methodName == 'refund'){
                                    Order_Return__c objOrderReturn = new Order_Return__c();
                                    objOrderReturn.Order__c = objOrder.Id;
                                    objOrderReturn.Total_Amount__c = fullRefundAmount;
                                    objOrderReturn.Total_Tax__c = refundTax;
                                    objOrderReturn.Subtotal__c = objOrder.Updated_Order_Amount__c;
                                    objOrderReturn.Status__c = 'ORDER RETURN';
                                    lstOrderReturns.add(objOrderReturn);


                                    for(OrderItem objOrderItem : objOrder.OrderItems){
                                        //add order item return object
                                        Order_Item_Return__c objOrderItemReturn = new Order_Item_Return__c();
                                        objOrderItemReturn.Order_Product__c = objOrderItem.Id;
                                        objOrderItemReturn.Return_Quantity__c = objOrderItem.Updated_Quantity__c;
                                        lstOrderItemReturns.add(objOrderItemReturn);

                                       	//set Updated_Quantity__c to 0
                                        objOrderItem.Updated_Quantity__c = 0;
                                        lstOrderItemReturnUpdate.add(objOrderItem);
                                    }
                                    objOrder.Updated_Order_Amount__c = 0;
                                    if(objOrder.cart__r.Pickup_Dealer__c == true){
                                        objOrder.Updated_Total_Tax__c = 0;
                                        objOrder.Updated_Order_Total__c = 0;
                                    }else {
                                        objOrder.Updated_Total_Tax__c = objOrder.Updated_Total_Tax__c - refundTax;
                                        objOrder.Updated_Order_Total__c = objOrder.Updated_Order_Total__c - fullRefundAmount;
                                    }

                                }

                                if(methodName == 'refund' || methodName == 'partial return') {
                                    //creating a new credit transaction
                                    BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();
                                    objBTTransactionDetails.BT_TransactionId__c = objBrainTreeTransactionResponse.transactionBT.id;
                                    objBTTransactionDetails.Type__c = objBrainTreeTransactionResponse.transactionBT.type;
                                    objBTTransactionDetails.Name = 'Return Transaction';
                                    objBTTransactionDetails.Order__c = objOrder.Id;
                                    objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                    lstBTTransactionDetails.add(objBTTransactionDetails);
                                }
                                RES_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper;
                                if(methodName != 'partial return') {
                                    //call vertax return tax for full return
                                	objResponseDataWrapper = RES_BrainTreeUtils.callVertaxReturnTax(objAccount, objOrder);
                                }else {
                                    //call vertax line item return tax
                                	objResponseDataWrapper = RES_BrainTreeUtils.callVertaxLineItemReturnTax(objAccount, objOrder);
                                }

                                if(objResponseDataWrapper.isSuccess == true){
                                    // do something
                                }else {
                                    objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                    objOrder.IsError__c = true;

                                    Error__c objError = RES_BrainTreeUtils.createErrorRecord('Vertax Return Callout Service Failed ', objOrder.Id, objResponseDataWrapper.errorMessage);
                                    lstErrors.add(objError);
                                }
                            }else {
                                System.debug('handle error in error object');
                                //ToDo Add Error object record
                                objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                objOrder.IsError__c = true;

                                if(methodName == 'partial return'){
                                    lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                                }
                                Error__c objError = RES_BrainTreeUtils.createErrorRecord('BT Cancellation Service Issue : Order Cancellation Failed ', objOrder.Id, objBrainTreeTransactionResponse.errorMessage);
                                lstErrors.add(objError);
                            }
                        }else if(objBTTokenDetails.RefreshTokenExpiresAT__c > System.now()){

                            //make callout to refresh token api for updating the BT_Token_Details object with the latest Access/Refresh Token.
                            String refreshTokenResponse = getRefreshToken(objAccount.Merchant_Id__c, objBTTokenDetails.RefreshToken__c);
                            B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();
                            objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(refreshTokenResponse, B2B_AccessTokenResponseWrapper.class);

                            if(objAccessTokenResponseWrapper.status == 200){
                                //updating BT_Token_Details object
                                objBTTokenDetails = RES_BrainTreeUtils.checkBTTokenDetails(objBTTokenDetails, objAccessTokenResponseWrapper);
                                lstBTTokenDetailsUpdate.add(objBTTokenDetails);

                                Decimal refundAmount = 0;
                                Decimal refundTax = 0;
                                Decimal totalRefundAmount = 0;
                                Decimal fullRefundAmount = 0;
                                if(methodName == 'void'){
                                    // make callout to braintree void api
                                    brainTreeResponse = braintreeTransactionVoid(customerID, objAccount.Merchant_Id__c, transactionID, objBTTokenDetails.AccessToken__c);
                                }else if(methodName == 'refund'){
                                    if(objOrder.cart__r.Pickup_Dealer__c == false){
                                        for(OrderItem objOrderItem : objOrder.OrderItems){
                                            Decimal taxPerItem = (objOrderItem.Total_Tax__c / objOrderItem.Quantity).setScale(2);
                                            refundTax += objOrderItem.Updated_Quantity__c * taxPerItem;
                                        }
                                        fullRefundAmount = objOrder.Updated_Order_Amount__c + refundTax;
                                    }else {
                                        refundTax = objOrder.Updated_Total_Tax__c;
                                        fullRefundAmount = objOrder.Updated_Order_Total__c;
                                    }
                                    fullRefundAmount = fullRefundAmount.setScale(2);
                                    // make callout to braintree refund api
                                    brainTreeResponse = braintreeTransactionRefund(customerID, objAccount.Merchant_Id__c, transactionID, objBTTokenDetails.AccessToken__c, String.valueOf(fullRefundAmount));
                                }else if(methodName == 'partial return'){
                                    // make callout to braintree refund api with the return amount
                                    // to do
                                    // calculate the amount from order items for passing to refund call

                                    for(OrderItem objOrderItem : objOrder.OrderItems){
                                        if(objOrderItem.Delta_Quantity__c != 0){
                                            refundAmount += objOrderItem.Delta_Quantity__c * objOrderItem.UnitPrice;
                                            Decimal taxPerItem = objOrderItem.Total_Tax__c / objOrderItem.Quantity;
                                            refundTax += objOrderItem.Delta_Quantity__c * taxPerItem;
                                        }
                                    }

                                    totalRefundAmount = refundAmount + refundTax;
                                    totalRefundAmount = totalRefundAmount.setScale(2);
                                    System.debug('totalRefundAmount' + String.valueOf(totalRefundAmount));
                                    brainTreeResponse = braintreeTransactionRefund(customerID, objAccount.Merchant_Id__c, transactionID, objBTTokenDetails.AccessToken__c, String.valueOf(totalRefundAmount));
                                }
                                objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parse(brainTreeResponse);
                                System.debug('objBrainTreeTransactionResponse 2 :' + objBrainTreeTransactionResponse);

                                //check if the response status is 200
                                if(objBrainTreeTransactionResponse.status == 200){
                                    System.debug('Order is successfully cancelled');
                                    if(methodName != 'partial return'){
                                        objOrder.BT_Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                    }
                                    objOrder.IsError__c = false;
                                    objOrder.Send_Email_To_Customer__c = true;
                                    if(methodName == 'partial return'){
                                        objOrder.Status = 'PARTIAL RETURN';
                                        objOrder.Updated_Order_Amount__c = objOrder.Updated_Order_Amount__c - refundAmount;
                                        objOrder.Updated_Total_Tax__c = objOrder.Updated_Total_Tax__c - refundTax;
                                        objOrder.Updated_Order_Total__c = objOrder.Updated_Order_Total__c - totalRefundAmount;

                                        // current return values
                                        objOrder.Current_Return_Amount__c = refundAmount;
                                        objOrder.Current_Return_Tax__c = refundTax;

                                        Order_Return__c objOrderReturn = new Order_Return__c();
                                        objOrderReturn.Order__c = objOrder.Id;
                                        objOrderReturn.Total_Amount__c = totalRefundAmount;
                                        objOrderReturn.Total_Tax__c = refundTax;
                                        objOrderReturn.Subtotal__c = refundAmount;
                                        objOrderReturn.Status__c = 'PARTIAL RETURN';
                                        lstOrderReturns.add(objOrderReturn);

                                        for(OrderItem objOrderItem : objOrder.OrderItems){
                                            //add order item return object
                                            if(objOrderItem.Delta_Quantity__c != 0){
                                                Order_Item_Return__c objOrderItemReturn = new Order_Item_Return__c();
                                                objOrderItemReturn.Order_Product__c = objOrderItem.Id;
                                                objOrderItemReturn.Return_Quantity__c = objOrderItem.Delta_Quantity__c;
                                                lstOrderItemReturns.add(objOrderItemReturn);
                                            }
                                        }

                                    }

                                    if(methodName == 'refund'){
                                        Order_Return__c objOrderReturn = new Order_Return__c();
                                        objOrderReturn.Order__c = objOrder.Id;
                                        objOrderReturn.Total_Amount__c = fullRefundAmount;
                                        objOrderReturn.Total_Tax__c = refundTax;
                                        objOrderReturn.Subtotal__c = objOrder.Updated_Order_Amount__c;
                                        objOrderReturn.Status__c = 'ORDER RETURN';
                                        lstOrderReturns.add(objOrderReturn);

                                        for(OrderItem objOrderItem : objOrder.OrderItems){
                                            //add order item return object
                                            Order_Item_Return__c objOrderItemReturn = new Order_Item_Return__c();
                                            objOrderItemReturn.Order_Product__c = objOrderItem.Id;
                                            objOrderItemReturn.Return_Quantity__c = objOrderItem.Updated_Quantity__c;
                                            lstOrderItemReturns.add(objOrderItemReturn);

                                            //set Updated_Quantity__c to 0
                                            objOrderItem.Updated_Quantity__c = 0;
                                            lstOrderItemReturnUpdate.add(objOrderItem);
                                        }

                                        objOrder.Updated_Order_Amount__c = 0;
                                        if(objOrder.cart__r.Pickup_Dealer__c == true){
                                            objOrder.Updated_Total_Tax__c = 0;
                                            objOrder.Updated_Order_Total__c = 0;
                                        }else {
                                            objOrder.Updated_Total_Tax__c = objOrder.Updated_Total_Tax__c - refundTax;
                                            objOrder.Updated_Order_Total__c = objOrder.Updated_Order_Total__c - fullRefundAmount;
                                        }
                                    }

                                    if(methodName == 'refund' || methodName == 'partial return') {
                                        // creating a new credit transaction
                                        BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();
                                        objBTTransactionDetails.BT_TransactionId__c = objBrainTreeTransactionResponse.transactionBT.id;
                                        objBTTransactionDetails.Type__c = objBrainTreeTransactionResponse.transactionBT.type;
                                        objBTTransactionDetails.Name = 'Return Transaction';
                                        objBTTransactionDetails.Order__c = objOrder.Id;
                                        objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                        lstBTTransactionDetails.add(objBTTransactionDetails);
                                    }
                                    RES_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper;
                                    if(methodName != 'partial return') {
                                        //call vertax return tax for full return
                                        objResponseDataWrapper = RES_BrainTreeUtils.callVertaxReturnTax(objAccount, objOrder);
                                    }else {
                                        //call vertax line item return tax
                                        objResponseDataWrapper = RES_BrainTreeUtils.callVertaxLineItemReturnTax(objAccount, objOrder);
                                    }

                                    if(objResponseDataWrapper.isSuccess == true){
                                        // do something
                                    }else {
                                        objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                        objOrder.IsError__c = true;

                                        Error__c objError = RES_BrainTreeUtils.createErrorRecord('Vertax Return Callout Service Failed ', objOrder.Id, objBrainTreeTransactionResponse.errorMessage);
                                        lstErrors.add(objError);
                                    }
                                }else {
                                    System.debug('handle error in error object');
                                    objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                    objOrder.IsError__c = true;

                                    if(methodName == 'partial return'){
                                    	lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                                	}
                                    Error__c objError = RES_BrainTreeUtils.createErrorRecord('BT Cancellation Service Issue : Order Cancellation Failed ', objOrder.Id, objBrainTreeTransactionResponse.errorMessage);
                                    lstErrors.add(objError);
                                }
                            }else {
                                system.debug('error in Refresh Token callout');
                                objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                objOrder.IsError__c = true;

                                if(methodName == 'partial return'){
                                    lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                                }
                                Error__c objError = RES_BrainTreeUtils.createErrorRecord('BT Refresh Token Service Failed ',objOrder.Id, objAccessTokenResponseWrapper.errorMessage);
                                lstErrors.add(objError);
                                //objOrder.addError('oAuth error : couldn\'t cancel order');
                            }
                        }
                    }else {
                        System.debug('show a error that order is not having a customer or transaction record');
                        //ToDo Throw a message on page to show the Order is missing Customer ID or BT Transaction record
                        //objOrder.addError(the Order is missing Customer ID or BT Transaction');
                        objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                        objOrder.IsError__c = true;

                        if(methodName == 'partial return'){
                            lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                        }
                        Error__c objError = RES_BrainTreeUtils.createErrorRecord('Missing Data On Record ', objOrder.Id, 'the Order is missing Customer ID or BT Transaction Id');
                        lstErrors.add(objError);
                    }
                }else {
                    objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                    objOrder.IsError__c = true;

                    if(methodName == 'partial return'){
                       lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                    }
                    Error__c objError = RES_BrainTreeUtils.createErrorRecord('BT Token Detail Missing ', objOrder.Id, 'the related account is missing BT_Token_Details__c record');
                    lstErrors.add(objError);
                }
            }catch(Exception ex){
                System.debug('exeption :-' + ex.getMessage() + ' line number : '+ ex.getLineNumber());
                objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                objOrder.IsError__c = true;

                if(methodName == 'partial return'){
                   lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                }
                Error__c objError = RES_BrainTreeUtils.createErrorRecord('Exception Occured ', objOrder.Id, ex.getMessage());
                objError.Line_Number__c = ex.getLineNumber();
                objError.StackTrace__c = ex.getStackTraceString();
                objError.Error_Type__c = ex.getTypeName();
                lstErrors.add(objError);
            }
            lstOrderUpdate.add(objOrder);
        }

        if(!lstOrderReturns.isEmpty()){
            System.debug('lstOrderReturns : '+lstOrderReturns);
            insert lstOrderReturns;
            if(!lstOrderItemReturns.isEmpty()){
                List<Order_Item_Return__c> lstOrderItemReturnsUpdate = new List<Order_Item_Return__c>();
                for(Order_Item_Return__c objOrderItemReturn : lstOrderItemReturns){
                    objOrderItemReturn.Order_Return__c = lstOrderReturns[0].Id;
                    lstOrderItemReturnsUpdate.add(objOrderItemReturn);
                }
                 System.debug('lstOrderItemReturnsUpdate : '+lstOrderItemReturnsUpdate);
                if(!lstOrderItemReturnsUpdate.isEmpty())
                    insert lstOrderItemReturnsUpdate;
            }
        }

        //update BT_Token_Details__c data
        if(!lstBTTokenDetailsUpdate.isEmpty())
            update lstBTTokenDetailsUpdate;

        // update Error object
        if(!lstErrors.isEmpty())
            insert lstErrors;

        // BT_transaction_Details__c
        if(!lstBTTransactionDetails.isEmpty())
        	insert lstBTTransactionDetails;

        //update OrderItem
        if(!lstOrderItemUpdate.isEmpty())
            update lstOrderItemUpdate;

        //update OrderItem for full return
        if(!lstOrderItemReturnUpdate.isEmpty())
            update lstOrderItemReturnUpdate;

        // update Order
        if(!lstOrderUpdate.isEmpty())
            update lstOrderUpdate;

    }


   /* ---------- Future Method ends -----------*/



   	/* ---------- Future Method Starts -----------*/
    /*
    Created By : Vikrant Upneja
    Date : 08/05/2021
    Description : this method is used for capturing the Post Auth
    */
    @future(callout=true)
    public static void braintreeOrderCapture(Set<Id> setOrderIds, Set<Id> setAccountIds, Map<Id, String> mapOldOrderStatus, String methodName){
        List<BT_Token_Details__c> lstBTTokenDetailsUpdate = new List<BT_Token_Details__c>();
        List<Order> lstOrderUpdate = new List<Order>();
        List<Error__c> lstErrors = new List<Error__c>();
        List<Dealer_Email__c> lstDealerEmails = new List<Dealer_Email__c>();
        String dealerLocatorResponse = '';
        List<BT_Transaction_Details__c> lstBTTransactionDetails = new List<BT_Transaction_Details__c>();

        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();

        List<Account> lstAccounts = [SELECT Id, Merchant_Id__c, Name, PoIId__c, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                     (SELECT Id, Name, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c, Account__c
                                      FROM BT_Token_Details__r)
                                     FROM Account
                                     WHERE Id IN: setAccountIds];

        List<Order> lstOrders = [SELECT Id, Updated_Order_Total__c, SHIPPING_from_cart__c,  AccountId, Status, cart__r.ShippingAmount__c , cart__r.CustomerStreet__c, cart__r.CustomerCity__c, cart__r.Customer_State__c,
                                 cart__r.CustomerPostalCode__c, BT_Transaction_Status__c, IsError__c, cart__c, Send_Email_To_Customer__c,
                                 (SELECT Id, Name, BT_TransactionId__c , Customer__c
                                  FROM BT_Transaction_Details__r),
                                 (SELECT Id, BT_CustomerId__c
                                  FROM BT_Customer_Details__r)
                                 FROM Order
                                 WHERE Id IN: setOrderIds];

        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        for(Account objAccount : lstAccounts){
            mapAccounts.put(objAccount.Id, objAccount);
        }

        for(Order objOrder : lstOrders){
            try{
                String brainTreeResponse = '';
                Account objAccount = mapAccounts.get(objOrder.AccountId);
                //check for the BT_Token_Details__c object is not equals to null
                if(!objAccount.BT_Token_Details__r.isEmpty()){
                    BT_Token_Details__c objBTTokenDetails = objAccount.BT_Token_Details__r[0];

                    //check for the related Transaction and Customer object is not equals to null
                    if(objOrder.BT_Customer_Details__r.isEmpty() == false && objOrder.BT_Transaction_Details__r.isEmpty() == false){
                        String BTTransactionId = objOrder.BT_Transaction_Details__r[0].Id;
                        String customerId = objOrder.BT_Customer_Details__r[0].BT_CustomerId__c;
                        String transactionID = objOrder.BT_Transaction_Details__r[0].BT_TransactionId__c;
                        if(objBTTokenDetails.AccessTokenExpiresAt__c > System.now()){
                            Decimal totalAmount = objOrder.Updated_Order_Total__c.setScale(2);
                            // make callout to braintree post auth api
                            brainTreeResponse = braintreeTransactionPostAuth(customerID, objAccount.Merchant_Id__c, transactionID, String.valueOf(totalAmount), objBTTokenDetails.AccessToken__c);

                            objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parse(brainTreeResponse);
                            System.debug('objBrainTreeTransactionResponse 1 :' + objBrainTreeTransactionResponse);

                            //check if the response status is 200
                            if(objBrainTreeTransactionResponse.status == 200){
                                System.debug('Order is successfully captured - PostAuth Successful');
                                objOrder.BT_Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                objOrder.IsError__c = false;
                                objOrder.Send_Email_To_Customer__c = true;
                                //updating the authorized transaction
                                BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();
                                objBTTransactionDetails.Id = BTTransactionId;
                                objBTTransactionDetails.BT_TransactionId__c = objBrainTreeTransactionResponse.transactionBT.id;
                                objBTTransactionDetails.Type__c = objBrainTreeTransactionResponse.transactionBT.type;
                                lstBTTransactionDetails.add(objBTTransactionDetails);

                                //send emails to dealer
                                if(objAccount.Name.contains('Honda')){
                                    dealerLocatorResponse = RES_BrainTreeUtils.dealerLocatorService('A',objAccount.PoIId__c);
                                }else {
                                    dealerLocatorResponse = RES_BrainTreeUtils.dealerLocatorService('B',objAccount.PoIId__c);
                                }
                                if(String.isNotEmpty(dealerLocatorResponse)){
                                    RES_BrainTreeUtils.DealerServiceResponse objResponse = (RES_BrainTreeUtils.DealerServiceResponse) JSON.deserialize(dealerLocatorResponse, RES_BrainTreeUtils.DealerServiceResponse.class);
                                    if(objResponse.isError == false && String.isNotEmpty(objResponse.dealerEmails)){
                                        List<String> lstEmails = objResponse.dealerEmails.split(';');
                                        for(String email : lstEmails){
                                            Dealer_Email__c objDealerEmail = new Dealer_Email__c();
                                            objDealerEmail.Email__c = email;
                                            objDealerEmail.Order__c = objOrder.Id;
                                            objDealerEmail.IsShipToHome__c = (objOrder.SHIPPING_from_cart__c != null && objOrder.SHIPPING_from_cart__c > 0) ? true : false;
                                            lstDealerEmails.add(objDealerEmail);
                                        }
                                    }
                                }
                            }else {
                                System.debug('handle error in error object');
                                //ToDo Add Error object record
                                //objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                objOrder.Status = 'PAYMENT ISSUE';
                                objOrder.IsError__c = true;

                                Error__c objError = RES_BrainTreeUtils.createErrorRecord('BT PostAuth Service Issue : Order has Payment Issue ', objOrder.Id, objBrainTreeTransactionResponse.errorMessage);
                                lstErrors.add(objError);
                            }
                        }else if(objBTTokenDetails.RefreshTokenExpiresAT__c > System.now()){

                            //make callout to refresh token api for updating the BT_Token_Details object with the latest Access/Refresh Token.
                            String refreshTokenResponse = getRefreshToken(objAccount.Merchant_Id__c, objBTTokenDetails.RefreshToken__c);
                            B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();
                            objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(refreshTokenResponse, B2B_AccessTokenResponseWrapper.class);

                            if(objAccessTokenResponseWrapper.status == 200){
                                //updating BT_Token_Details object
                                objBTTokenDetails = RES_BrainTreeUtils.checkBTTokenDetails(objBTTokenDetails, objAccessTokenResponseWrapper);
                                lstBTTokenDetailsUpdate.add(objBTTokenDetails);
                                Decimal totalAmount = objOrder.Updated_Order_Total__c.setScale(2);
                                // make callout to braintree post auth api
                                brainTreeResponse = braintreeTransactionPostAuth(customerID, objAccount.Merchant_Id__c, transactionID, String.valueOf(totalAmount), objBTTokenDetails.AccessToken__c);

                                objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parse(brainTreeResponse);
                                System.debug('objBrainTreeTransactionResponse 2 :' + objBrainTreeTransactionResponse);

                                //check if the response status is 200
                                if(objBrainTreeTransactionResponse.status == 200){
                                    System.debug('Order is successfully : Post Auth is successful.');
                                    objOrder.BT_Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                    objOrder.IsError__c = false;
                                    objOrder.Send_Email_To_Customer__c = true;
                                    //updating the authorized transaction
                                    BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();
                                    objBTTransactionDetails.Id = BTTransactionId;
                                    objBTTransactionDetails.BT_TransactionId__c = objBrainTreeTransactionResponse.transactionBT.id;
                                    objBTTransactionDetails.Type__c = objBrainTreeTransactionResponse.transactionBT.type;
                                    lstBTTransactionDetails.add(objBTTransactionDetails);

                                    //send emails to dealer
                                    if(objAccount.Name.contains('Honda')){
                                        dealerLocatorResponse = RES_BrainTreeUtils.dealerLocatorService('A',objAccount.PoIId__c);
                                    }else {
                                        dealerLocatorResponse = RES_BrainTreeUtils.dealerLocatorService('B',objAccount.PoIId__c);
                                    }
                                    if(String.isNotEmpty(dealerLocatorResponse)){
                                        RES_BrainTreeUtils.DealerServiceResponse objResponse = (RES_BrainTreeUtils.DealerServiceResponse) JSON.deserialize(dealerLocatorResponse, RES_BrainTreeUtils.DealerServiceResponse.class);
                                        if(objResponse.isError == false && String.isNotEmpty(objResponse.dealerEmails)){
                                            List<String> lstEmails = objResponse.dealerEmails.split(';');
                                            for(String email : lstEmails){
                                                Dealer_Email__c objDealerEmail = new Dealer_Email__c();
                                                objDealerEmail.Email__c = email;
                                                objDealerEmail.Order__c = objOrder.Id;
                                                objDealerEmail.IsShipToHome__c = (objOrder.SHIPPING_from_cart__c != null && objOrder.SHIPPING_from_cart__c > 0) ? true : false;
                                                lstDealerEmails.add(objDealerEmail);
                                            }
                                        }
                                    }


                                }else {
                                    System.debug('handle error in error object');
                                    //objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                    objOrder.Status = 'PAYMENT ISSUE';
                                    objOrder.IsError__c = true;

                                    Error__c objError = RES_BrainTreeUtils.createErrorRecord('BT PostAuth Service Issue : Order has Payment Issue ', objOrder.Id, objBrainTreeTransactionResponse.errorMessage);
                                    lstErrors.add(objError);
                                }
                            }else {
                                system.debug('error in Refresh Token callout');
                                objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                //objOrder.Status = 'PAYMENT ISSUE';
                                objOrder.IsError__c = true;

                                Error__c objError = RES_BrainTreeUtils.createErrorRecord('BT Refresh Token Service Failed ',objOrder.Id, objAccessTokenResponseWrapper.errorMessage);
                                lstErrors.add(objError);
                                //objOrder.addError('oAuth error : couldn\'t cancel order');
                            }
                        }
                    }else {
                        System.debug('show a error that order is not having a customer or transaction record');
                        //ToDo Throw a message on page to show the Order is missing Customer ID or BT Transaction record
                        //objOrder.addError(the Order is missing Customer ID or BT Transaction');
                        objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                        objOrder.IsError__c = true;

                        Error__c objError = RES_BrainTreeUtils.createErrorRecord('Missing Data On Record ', objOrder.Id, 'the Order is missing Customer ID or BT Transaction Id');
                        lstErrors.add(objError);
                    }
                }else {
                    objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                    objOrder.IsError__c = true;

                    Error__c objError = RES_BrainTreeUtils.createErrorRecord('BT Token Detail Missing ', objOrder.Id, 'the related account is missing BT_Token_Details__c record');
                    lstErrors.add(objError);
                }
            }catch(Exception ex){
                System.debug('exeption :-' + ex.getMessage() + ' line number : '+ ex.getLineNumber());
                objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                objOrder.IsError__c = true;

                Error__c objError = RES_BrainTreeUtils.createErrorRecord('Exception Occured ', objOrder.Id, ex.getMessage());
                objError.Line_Number__c = ex.getLineNumber();
                objError.StackTrace__c = ex.getStackTraceString();
                objError.Error_Type__c = ex.getTypeName();
                lstErrors.add(objError);
            }
            lstOrderUpdate.add(objOrder);
        }




        //update BT_Token_Details__c data
        if(!lstBTTokenDetailsUpdate.isEmpty())
            update lstBTTokenDetailsUpdate;

        // update Error object
        if(!lstErrors.isEmpty())
            insert lstErrors;

        // update Order
        if(!lstOrderUpdate.isEmpty())
            update lstOrderUpdate;

        // BT_transaction_Details__c
        if(!lstBTTransactionDetails.isEmpty())
            update lstBTTransactionDetails;

        // insert dealer Emails
        if(!lstDealerEmails.isEmpty())
            insert lstDealerEmails;


    }


   /* ---------- Future Method ends -----------*/

}
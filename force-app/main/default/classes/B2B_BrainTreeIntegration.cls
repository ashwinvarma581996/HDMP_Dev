/****************************************************************************************************************
Name: B2B_BrainTreeIntegration
Purpose: Contains all the methods for BrainTree
Date : 27/06/2021
Created By : Rajrishi Kaushik
Test class name: B2B_BrainTreeIntegrationTest, B2B_BrainTreeIntegrationMock, B2B_BrainTreeIntegrationMock1 
******************************************************************************************************************
MODIFICATIONS – Date        |   Dev Name        |   Method      |   User Story
******************************************************************************************************************
                22/05/2022  |   Yashika Agarwal |               |   Error handling changes- JIRA- 8617
                15/07/2022  |   Rajrishi Kaushik|               |   HDMP-8729
******************************************************************************************************************/
 
public class B2B_BrainTreeIntegration implements Queueable, Database.AllowsCallouts{

    // Saravanan LTIM starts for Sprint 2 - Data Rules Dealer
    Public static Map<Id,OrderItem> mapOrderIdtoOrderItem = new Map<Id,OrderItem>();
    // Saravnan LTIM Ends for Sprint 2 - Data Rules Dealer

        //Lakshmi HDMP-19490 for BT issue
        public Set<Id> setOrderIdsVal; 
        public Set<Id> setAccountIdsVal;
        public Map<Id, String> mapOldOrderStatusVal;
        public String methodNameVal;


        public B2B_BrainTreeIntegration(Set<Id> setOrderIds, Set<Id> setAccountIds, Map<Id, String> mapOldOrderStatus, String methodName){
            this.setOrderIdsVal=setOrderIds;
            this.setAccountIdsVal=setAccountIds;
            this.mapOldOrderStatusVal=mapOldOrderStatus;
            this.methodNameVal=methodName;
        }   


        public void execute(QueueableContext context) {
            if(methodNameVal.equalsIgnoreCase('refund')){
                braintreeOrderCapture(setOrderIdsVal,setAccountIdsVal,mapOldOrderStatusVal,methodNameVal);
            } else if (methodNameVal.equalsIgnoreCase('void')){
                braintreeOrderCancellation(setOrderIdsVal,setAccountIdsVal,mapOldOrderStatusVal,methodNameVal);
            } else if (methodNameVal.equalsIgnoreCase('partial return')){
                braintreeOrderCancellation(setOrderIdsVal,setAccountIdsVal,mapOldOrderStatusVal,methodNameVal);
            }
        }
     
    /*
    Created By : Rajrishi Kaushik
    Date : 27/06/2021
    Description : This method is used to get the access token and refresh token by passing a merchantId and code.
    */ 
    public static string getAccessToken(String merchantID, String code){
        B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();
        try{
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('GET','','');
            String endpoint = 'callout:Braintree_Named_Credential' + '/access-token/merchantID/'+merchantID+'/code/'+code;
            request.setEndpoint(endpoint);
            String guId = B2B_Util.createGui();
            request.setHeader('hondaHeaderType.messageId', guId);
            request.setHeader('accept', 'application/json');
             
            Http http = new Http();
            HTTPResponse response = http.send(request); 
            system.debug('Response---'+response);
            system.debug('Response Body---'+response.getBody());
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) System.JSON.deserialize(response.getBody(), B2B_AccessTokenResponseWrapper.class);                   
                if(response.getStatusCode() != 200 ){
                    objAccessTokenResponseWrapper.status = response.getStatusCode();
                    objAccessTokenResponseWrapper.errorMessage = response.getStatus();
                    objAccessTokenResponseWrapper.requestBody = request.getBody();
                    objAccessTokenResponseWrapper.responseBody = response.getBody();
                }
                return JSON.serialize(objAccessTokenResponseWrapper); 
            }else {
                objAccessTokenResponseWrapper.status = response.getStatusCode();
                objAccessTokenResponseWrapper.errorMessage = response.getStatus();
                objAccessTokenResponseWrapper.requestBody = request.getBody();
                objAccessTokenResponseWrapper.responseBody = response.getBody();
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
    Created By : Rajrishi Kaushik
    Date : 27/06/2021
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
                objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) System.JSON.deserialize(response.getBody(), B2B_AccessTokenResponseWrapper.class);  
                if(response.getStatusCode() != 200){
                    objAccessTokenResponseWrapper.requestBody = request.getbody();
                    objAccessTokenResponseWrapper.responseBody = response.getbody(); 
                }
                return JSON.serialize(objAccessTokenResponseWrapper);                
            }else {
                objAccessTokenResponseWrapper.status = response.getStatusCode();
                objAccessTokenResponseWrapper.errorMessage = response.getStatus();
                objAccessTokenResponseWrapper.requestBody = request.getbody();
                objAccessTokenResponseWrapper.responseBody = response.getbody();
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
    Created By : Rajrishi Kaushik
    Date : 27/06/2021
    Description : This method is used for creating a transaction having authorized status at braintree server.
    */ 
    public static String braintreeTransactionPreAuth(String customerID, String merchantID, String accessToken, String saleAmount, String paymentToken, String paypalNonce){  
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{
            String reqBody;
            if(String.isNotEmpty(paymentToken)){
                reqBody ='{"customerID": "'+customerID+'","merchantID": "'+merchantID+'","saleAmount": "'+saleAmount+'","paymentToken": "'+paymentToken+'","accessToken": "'+accessToken+'"}';
            }else {
                reqBody ='{"customerID": "'+customerID+'","merchantID": "'+merchantID+'","saleAmount": "'+saleAmount+'","paymentMethodNonce": "'+paypalNonce+'","accessToken": "'+accessToken+'"}';
            }
            HttpRequest request = new HttpRequest();
            request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'pre-auth');
            Http http = new Http();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){            
                String responseBody = response.getBody();
                Map<String,Object> mapVoidResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Integer status = Integer.valueOf(mapVoidResponse.get('status'));
                if(status == 200){
                    Map<String,Object> mapTransaction = (Map<String,Object>) mapVoidResponse.get('transaction');
                    objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parseTransactionData(objBrainTreeTransactionResponse, responseBody, mapTransaction);   
                }else{
                    objBrainTreeTransactionResponse.errorMessage = JSON.serialize(mapVoidResponse.get('errorMessage'));
                    objBrainTreeTransactionResponse.status = status;
                    objBrainTreeTransactionResponse.requestBody = request.getBody();
                    objBrainTreeTransactionResponse.responseBody = response.getBody();
                }   
            }else {
                objBrainTreeTransactionResponse.status = response.getStatusCode();
                objBrainTreeTransactionResponse.errorMessage = response.getStatus(); 
                objBrainTreeTransactionResponse.requestBody = request.getBody();
                objBrainTreeTransactionResponse.responseBody = response.getBody();
            } 
        }catch(Exception ex){
            objBrainTreeTransactionResponse.errorMessage = ex.getMessage();
            objBrainTreeTransactionResponse.status = 400;           
        }
        return JSON.serialize(objBrainTreeTransactionResponse);   
    }
    
    /*
    Created By :Rajrishi Kaushik
    Date : 27/06/2021
    Description : This method is used for changing the status of transaction from authorized to submitted_for_settlement.
    */
    public static String braintreeTransactionPostAuth(String customerID, String merchantID,String transactionID, String amount, String accessToken){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        system.debug('customerID---' + customerID);
        system.debug('merchantID---' + merchantID);
        system.debug('transactionID---' + transactionID);
        system.debug('accessToken---' + accessToken);
         system.debug('amount---' + amount);
        
        try{
            String reqBody = '{"customerID": "'+customerID+'", "merchantID": "'+merchantID+'", "transactionID": "'+transactionID+'", "amount": '+amount+', "accessToken": "'+accessToken+'"}';
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'post-auth');
            Http http = new Http();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){    
                String responseBody = response.getBody();
                system.debug(' response::' + responseBody);
                Map<String,Object> mapVoidResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Integer status = Integer.valueOf(mapVoidResponse.get('status'));
                if(status == 200){
                    Map<String,Object> mapTransaction = (Map<String,Object>) mapVoidResponse.get('transaction');
                    objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parseTransactionData(objBrainTreeTransactionResponse, responseBody, mapTransaction);                                                  
                }else{
                    objBrainTreeTransactionResponse.errorMessage = JSON.serialize(mapVoidResponse.get('errorMessage'));
                    objBrainTreeTransactionResponse.status = status;
                    objBrainTreeTransactionResponse.requestBody = request.getBody();
                    objBrainTreeTransactionResponse.responseBody = response.getBody();
                } 
            }else {
                objBrainTreeTransactionResponse.status = response.getStatusCode();
                objBrainTreeTransactionResponse.errorMessage = response.getStatus();    
                objBrainTreeTransactionResponse.requestBody = request.getBody();
                objBrainTreeTransactionResponse.responseBody = response.getBody();
            } 
        }catch(Exception ex){
            objBrainTreeTransactionResponse.errorMessage = ex.getMessage();
            objBrainTreeTransactionResponse.status = 400;           
        }
        return JSON.serialize(objBrainTreeTransactionResponse);     
    }       
    
    /*
    Created By : RajRishi Kaushik
    Date : 27/06/2021
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
            objBrainTreeTransactionResponse.requestBody = request.getBody();
            objBrainTreeTransactionResponse.responseBody = response.getBody();
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){ 
                String responseBody = response.getBody();
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
        return JSON.serialize(objBrainTreeTransactionResponse);   
    }   
    
    /*
    Created By : Rajrishi Kaushik
    Date : 27/06/2021
    Description : This method is used for making a callout at braintree server for cancelling the order.
    */   
    public static String braintreeTransactionVoid(String customerID, String merchantID, String transactionID, String accessToken){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{            
            String reqBody = '{"customerID": "'+customerID+'", "merchantID": "'+merchantID+'", "transactionID": "'+transactionID+'", "accessToken": "'+accessToken+'"}';
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'void');
            Http http = new Http();
            HTTPResponse response = http.send(request);
            objBrainTreeTransactionResponse.requestBody = request.getBody();
            objBrainTreeTransactionResponse.responseBody = response.getBody();
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                String responseBody = response.getBody();
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
        return JSON.serialize(objBrainTreeTransactionResponse);
    }   
    
    /*
    Created By :Rajrishi Kaushik
    Date : 08/10/2021
    Description : This method is used for getting the transaction current status from braintree.
    */
    public static String braintreeTransactionSearch(String transactionID, String accessToken){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{
            String reqBody = '{"transactionID": "'+transactionID+'", "accessToken": "'+accessToken+'"}';
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'search');
            Http http = new Http();
            HTTPResponse response = http.send(request);
            objBrainTreeTransactionResponse.requestBody = request.getBody();
            objBrainTreeTransactionResponse.responseBody = response.getBody();
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){    
                String responseBody = response.getBody();
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
        return JSON.serialize(objBrainTreeTransactionResponse);     
    }        
    
    /*
    Created By : Rajrishi Kaushik
    Date : 27/06/2021
    Description : This method is used to update the saved payment method in BT.
    */   
    public static B2B_BrainTreeTransactionResponse braintreePaymentMethodUpdate(String paymentID, String paymentNonce){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{            
            String reqBody = '{"token": "'+paymentID+'", "paymentMethodNonce": "'+paymentNonce+'"}';
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'update');
            Http http = new Http(); 
            HTTPResponse response = http.send(request);
            objBrainTreeTransactionResponse.requestBody = request.getBody();
            objBrainTreeTransactionResponse.responseBody = response.getBody();
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                String responseBody = response.getBody();
                Map<String,Object> mapUpdateResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Integer status = Integer.valueOf(mapUpdateResponse.get('status'));
                if(status == 200){                    
                     objBrainTreeTransactionResponse.status = status;                                           
                }else{
                    objBrainTreeTransactionResponse.errorMessage = JSON.serialize(mapUpdateResponse.get('errorMessage'));
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
        return objBrainTreeTransactionResponse;
    }   
    
    /*
    Created By : Rajrishi Kaushik
    Date : 16/05/2022
    Description : This method is used to delete the saved payment method in BT.
    */   
    public static B2B_BrainTreeTransactionResponse braintreePaymentMethodDelete(String paymentID){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{            
            String reqBody = '{"token": "'+paymentID+'"}';
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'Payment Delete');
            Http http = new Http(); 
            HTTPResponse response = http.send(request);
            objBrainTreeTransactionResponse.requestBody = request.getBody();
            objBrainTreeTransactionResponse.responseBody = response.getBody();
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                String responseBody = response.getBody();
                Map<String,Object> mapUpdateResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Integer status = Integer.valueOf(mapUpdateResponse.get('status'));
                if(status == 200){                    
                     objBrainTreeTransactionResponse.status = status;                                           
                }else{
                    objBrainTreeTransactionResponse.errorMessage = JSON.serialize(mapUpdateResponse.get('errorMessage'));
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
        return objBrainTreeTransactionResponse;
    }  
    
    /*
    Created By : Rajrishi Kaushik
    Date : 16/05/2022
    Description : This method is used to get the details of the vaulted payment method in BT.
    */   
    public static B2B_BrainTreeTransactionResponse braintreePaymentMethodFind(String paymentID){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{            
            String reqBody = '{"token": "'+paymentID+'"}';
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'Find');
            Http http = new Http(); 
            HTTPResponse response = http.send(request);
            objBrainTreeTransactionResponse.requestBody = request.getBody();
            objBrainTreeTransactionResponse.responseBody = response.getBody();
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                String responseBody = response.getBody();
                Map<String,Object> mapUpdateResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Integer status = Integer.valueOf(mapUpdateResponse.get('status'));
                if(status == 200){                    
                    objBrainTreeTransactionResponse.status = status;
                    objBrainTreeTransactionResponse.billingAddressId = String.valueOf(mapUpdateResponse.get('billingAddressId'));
                }else{
                    objBrainTreeTransactionResponse.errorMessage = JSON.serialize(mapUpdateResponse.get('errorMessage'));
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
        return objBrainTreeTransactionResponse;
    } 
    
    /*
    Created By : Rajrishi Kaushik
    Date : 16/05/2022
    Description : This method is used to delete the address related to payment method in BT.
    */   
    public static B2B_BrainTreeTransactionResponse braintreeAddressDelete(String customerID, String addressID){
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();
        try{            
            String reqBody = '{"customerID": "'+customerID+'", "addressID": "'+addressID+'"}';
            HttpRequest request = B2B_IntegrationCallout.createBraintreeRequest('POST',reqBody,'Address Delete');
            Http http = new Http(); 
            HTTPResponse response = http.send(request);
            objBrainTreeTransactionResponse.requestBody = request.getBody();
            objBrainTreeTransactionResponse.responseBody = response.getBody();
            if(response.getStatusCode() == 200 || response.getStatusCode() == 400){
                String responseBody = response.getBody();
                Map<String,Object> mapUpdateResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Integer status = Integer.valueOf(mapUpdateResponse.get('status'));
                if(status == 200){                    
                     objBrainTreeTransactionResponse.status = status;                                           
                }else{
                    objBrainTreeTransactionResponse.errorMessage = JSON.serialize(mapUpdateResponse.get('errorMessage'));
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
        return objBrainTreeTransactionResponse;
    }
    
    public static List<OrderItem> revertOrderItemChanges(List<OrderItem> lstOrderItems){
        List<OrderItem> revertOrderItems = new List<OrderItem>();
        for(OrderItem objOrderItem : lstOrderItems){                       
            objOrderItem.Return_Quantity__c -= objOrderItem.Delta_Quantity__c;
            objOrderItem.Delta_Quantity__c = 0;
            
            if(objOrderItem.Delta_Installation_Price__c > 0){                           
                // changes for HDMP-8729
                objOrderItem.Total_Return_Installation_Charge__c -= objOrderItem.Delta_Installation_Price__c;
                objOrderItem.Delta_Installation_Price__c = 0;
            }                    
            revertOrderItems.add(objOrderItem);
        }
        return revertOrderItems;
    }
    
    /* ---------- Future Method Starts -----------*/
    /*
    Created By : Rajrishi Kaushik
    Date : 11/07/2021
    Description : this method is used for cancelling, Returning and Partial Returning the customer order. 
    */
    //@future(callout=true)   
    public static void braintreeOrderCancellation(Set<Id> setOrderIds, Set<Id> setAccountIds, Map<Id, String> mapOldOrderStatus, String methodName){                   
        List<BT_Token_Details__c> lstBTTokenDetailsUpdate = new List<BT_Token_Details__c>();
        List<BT_Payment_Method__c> lstBTPaymentMethods = new List<BT_Payment_Method__c>();
        List<Order> lstOrderUpdate = new List<Order>();
        List<OrderItem> lstOrderItemUpdate = new List<OrderItem>();
        List<OrderItem> lstOrderItemReturnUpdate = new List<OrderItem>();
        List<Error__c> lstErrors = new List<Error__c>();
        List<Order_Return__c> lstOrderReturns = new List<Order_Return__c>();
        List<Order_Item_Return__c> lstOrderItemReturns = new List<Order_Item_Return__c>();
        List<BT_Transaction_Details__c> lstBTTransactionDetails = new List<BT_Transaction_Details__c>();
        //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
        List<Invoice__c> lstInvoice = new List<Invoice__c>();
        List<Invoice_Item__c> lstInvoiceItem = new List<Invoice_Item__c>();
        //Added by Faraz Ansari for HDMP-8705 - End

        //for HDMP-8716 : audit Trail 
        List<Order_Transaction__c> lstOrderTrans = new List<Order_Transaction__c>();
        List<Order_Transaction_Item__c> lstOrderTranItems = new List<Order_Transaction_Item__c>();
        String auditType;
        if(methodName == 'void'){   
            auditType = 'Cancelled';
        }else if(methodName == 'partial return'){
            auditType = 'Returned';
        }
        
        Boolean isVertaxFails = false;
        Map<String, Decimal> pricesMap = new Map<String, Decimal>();

        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();      
        
        //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
        List<Account> lstAccounts = [SELECT Id, Name, Merchant_Id__c, PoIId__c, BillingStreet, BillingCity, BillingState, BillingPostalCode,  Email__c, Phone,
                                     (SELECT Id, Name, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c, Account__c FROM BT_Token_Details__r)                                   
                                     FROM Account WHERE Id IN: setAccountIds];
        
        // changes for HDMP-8729 : added Total_Return_Installation_Charge__c in sub-query
        // Saravanan LTIM added for SPrint 2 SOQL Total_Core_Charge_Current_Quantity__c,Total_Core_Charge_Current_Amount__c , Total_Core_Charge_Current_Tax__c
        // Saravanan LTIM added for SPrint 2 Sub query Product_Type__c,Product2.Core_Charge_Unit_Price__c
        // Saravanan LTIM added for Sprint 2 Return API Total_Core_Charge_Return_Amount__c, Total_Core_Charge_Return_Quantity__c,Total_Core_Charge_Return_Tax__c 
        // Delivery_Type__c is Exceptional field
        // [REMAN-140] Saravanan LTIM added for ,Total_Current_Product_Amount__c,Total_Current_Product_Tax__c,Total_Core_Charge_Original_Quantity__c
        List<Order> lstOrders = [SELECT Id, Total_Return_Product_Tax__c, Return_Quantity__c, Total_Return_Pre_Tax_Amount__c, Current_Quantity__c,Total_Current_Pre_Tax_Order_Amount__c,Total_Current_Product_Tax__c, Total_Return_Installation_Tax__c, Customer_Notes__c, BT_Customer_Legecy_Id__c, OrderNumber, OrderedDate, BT_Customer_Detail__c, Tax_Refund__c, Payment_Method_Token__c, Delivery_Types__c, Install_Refund__c, TotalTaxAmount__c, Is_Shipping_Returned__c, Total_Installation_Return__c, Total_Restocking_Fees__c,Total_Item_Return__c,Total_Ship_Return__c,Total_Tax_Return__c,Total_Return__c, AccountId, Restocking_Fees__c, Shipping_Refund__c, 
                                 Current_Return_Amount__c, BT_Transaction_Id__c, Current_Return_Tax__c, Status, cart__r.Pickup_Dealer__c , cart__r.ShippingAmount__c , cart__r.CustomerStreet__c, cart__r.CustomerCity__c, cart__r.Customer_State__c, cart__r.CustomerPostalCode__c, Shipping_Customer_Name__c,  CC_Last4__c,
                                 Send_Email_To_Customer__c, Updated_Order_Total__c, Updated_Total_Tax__c, Updated_Order_Amount__c,Updated_Shipping__c, Total_Installation_Charges__c, ShipToContactId, BillingEmailAddress, Customer_Name__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingAddress, BillingPhoneNumber,Payment_Type__c, Total_Shipping_Tax__c,
                                 ShippingAddress, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, Current_Shipping_Tax__c,Total_Restocking_Fee_Tax__c,Return_Shipping_Tax__c,OrderReferenceNumber,
                                 BT_Transaction_Status__c, IsError__c, cart__c, (SELECT Id, Name, BT_TransactionId__c,Customer__c,Credit_Card_Number__c, Billing_Street__c, Billing_City__c, Billing_State__c, Billing_PostalCode__c, Payment_Gateway__c,Payment_Method_Type__c, Payment_Method_Token__c, Cardholder_Name__c FROM BT_Transaction_Details__r),                                  
                                 (SELECT Id, Total_Return_Installation_Charge__c, Total_Current_Product_Tax__c, Total_Return_Product_Tax__c, TotalPrice, Dealer_Installation_Price__c, Delta_Installation_Price__c, Delta_Quantity__c,Updated_Quantity__c,Return_Quantity__c, Quantity, UnitPrice, ListPrice, Total_Tax__c, Product_SKU__c, Cart_Item_Product_Name__c, Op_Code__c ,Product_Type__c,Product2.Core_Charge_Unit_Price__c FROM OrderItems WHERE Type != 'Delivery Charge')
                                 ,Total_Core_Charge_Current_Quantity__c,Total_Core_Charge_Current_Amount__c , Total_Core_Charge_Current_Tax__c,Total_Core_Charge_Original_Quantity__c,
                                 Total_Core_Charge_Return_Amount__c, Total_Core_Charge_Return_Quantity__c,Total_Core_Charge_Return_Tax__c,
                                 Delivery_Type__c,Quantity__c ,Total_Current_Product_Amount__c
                                 FROM Order 
                                 WHERE Id IN: setOrderIds];
        //Added by Faraz Ansari for HDMP-8705 - End
        
        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        for(Account objAccount : lstAccounts){
            mapAccounts.put(objAccount.Id, objAccount);           
        }
                        
        Boolean isSavedPaymentMethod = false;
        if(!lstOrders.isEmpty()){
            List<BT_Payment_Method__c> lstSavedPaymentMethods = [SELECT Id FROM BT_Payment_Method__c 
                                                                 WHERE Payment_Method_Token__c =: lstOrders[0].Payment_Method_Token__c 
                                                                 AND BT_Customer_Details__r.BT_CustomerId__c =: lstOrders[0].BT_Customer_Detail__c];
            if(!lstSavedPaymentMethods.isEmpty()){
                isSavedPaymentMethod = true;
            }
        }
        
        for(Order objOrder : lstOrders){
            try{
                String brainTreeResponse = '';
                Account objAccount = mapAccounts.get(objOrder.AccountId);               
                //check for the BT_Token_Details__c object is not equals to null
                if(!objAccount.BT_Token_Details__r.isEmpty()){                
                    BT_Token_Details__c objBTTokenDetails = objAccount.BT_Token_Details__r[0];  
                    
                    //check for the related Transaction and Customer object is not equals to null
                    if(String.isNotEmpty(objOrder.BT_Customer_Detail__c) && objOrder.BT_Transaction_Details__r.isEmpty() == false){
                        String customerId = objOrder.BT_Customer_Detail__c;
                        String transactionID = objOrder.BT_Transaction_Id__c;  
                        String BTTransactionId = objOrder.BT_Transaction_Details__r[0].Id;//Added by Faraz Ansari for HDMP-8705 on 16/05/2022
                        
                        if(objBTTokenDetails.AccessTokenExpiresAt__c > System.now()){ 
                            Decimal refundAmount = 0;
                            Decimal refundTax = objOrder.Tax_Refund__c;
                            Decimal totalRefundAmount = 0;
                            Decimal fullRefundAmount = 0; 
                            // Saravanan LTIM Added AND Conditions for HDMP-19407
                            Decimal returnCoreChargeQuantities = 0; 
                            

                            if(methodName == 'void'){
                                //call the transaction search api to check the current status of transaction before charging the customer
                                B2B_BrainTreeTransactionResponse objBrainTreeSearchResponse = new B2B_BrainTreeTransactionResponse();
                                String searchResponse = braintreeTransactionSearch(transactionID, objBTTokenDetails.AccessToken__c);
                                objBrainTreeSearchResponse = B2B_BrainTreeTransactionResponse.parse(searchResponse);
                                // if the transaction is expired again create a new transaction by the preAuth API using payment token stored on order
                                if(objBrainTreeSearchResponse.status == 200 && objBrainTreeSearchResponse.transactionBT.status == 'authorized'){
                                brainTreeResponse = braintreeTransactionVoid(customerID, objAccount.Merchant_Id__c, transactionID, objBTTokenDetails.AccessToken__c);                            
                                }else{
                                    brainTreeResponse = searchResponse;
                                }
                                // make callout to braintree void api                                                           
                            }else if(methodName == 'partial return'){
                                // make callout to braintree refund api with the return amount
                                // calculate the amount from order items for passing to refund call   
                                Decimal returnCoreAmount = 0.0; //Saravanan LTIM HDMP-19433
                                for(OrderItem objOrderItem : objOrder.OrderItems){ 
                                    // Saravanan LTIM Added AND Conditions for objOrderItem.Product_type__c != 'Core Charge' HDMP-19407
                                    if(objOrderItem.Delta_Quantity__c != 0 && objOrderItem.Product_type__c != 'Core Charge'){
                                        refundAmount += objOrderItem.Delta_Quantity__c * objOrderItem.ListPrice;                                        
                                    }

                                    // Saravanan LTIM Added IF Conditions for  HDMP-19407

                                    if(objOrderItem.Product_type__c == 'Core Charge'){
                                        returnCoreChargeQuantities += objOrderItem.Return_Quantity__c;
                                        returnCoreAmount+=objOrderItem.Delta_Quantity__c * objOrderItem.ListPrice; //Saravanan LTIM HDMP-19433

                                    }      

                                }
                                
                                if(objOrder.cart__r.Pickup_Dealer__c == false){   
                                    //Saravanan LTIM HDMP-19433                                
                                    totalRefundAmount = (refundAmount + refundTax + objOrder.Shipping_Refund__c+returnCoreAmount) - objOrder.Restocking_Fees__c;
                                }else {            
                                    //Saravanan LTIM HDMP-19433                      
                                    totalRefundAmount = (refundAmount + refundTax + objOrder.Install_Refund__c+returnCoreAmount) - objOrder.Restocking_Fees__c;   
                                }                               
                                totalRefundAmount = totalRefundAmount.setScale(2);
                                brainTreeResponse = braintreeTransactionRefund(customerID, objAccount.Merchant_Id__c, transactionID, objBTTokenDetails.AccessToken__c, String.valueOf(totalRefundAmount));
                            }
                            objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parse(brainTreeResponse);
                            Long beforeAPI = B2B_Util.fetchCurrentTime();
                            //check if the response status is 200
                            if(objBrainTreeTransactionResponse.status == 200){
                                if(methodName == 'void'){                                   
                                    if(objBrainTreeTransactionResponse.transactionBT.status == 'authorization_expired'){
                                        objOrder.BT_Transaction_Status__c = 'Voided';
                                    }else {
                                    objOrder.BT_Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                    } 
                                    //changes for HDMP-8730 :- delete the payment method from honda braintree for one time credit card
                                    if(isSavedPaymentMethod == false && String.isNotEmpty(objOrder.Payment_Method_Token__c)){
                                        // get the address id from payment method find API
                                        B2B_BrainTreeTransactionResponse objPaymentFindResponse = braintreePaymentMethodFind(objOrder.Payment_Method_Token__c);
                                        if(objPaymentFindResponse.status == 200){     
                                            //delete the one time payment method from BT
                                            braintreePaymentMethodDelete(objOrder.Payment_Method_Token__c);
                                            if(String.isNotEmpty(objOrder.BT_Customer_Legecy_Id__c)){
                                                //delete the related address to the payment method
                                                braintreeAddressDelete(objOrder.BT_Customer_Legecy_Id__c, objPaymentFindResponse.billingAddressId);
                                            }
                                        } else{
                                            Long afterAPI = B2B_Util.fetchCurrentTime();
                                            Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
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
                                            
                                            String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                            Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                              'B2B_BrainTreeIntegration',String.valueOf(objPaymentFindResponse.status),errorType,'',
                                                                                              'braintreeOrderCancellation',true, objOrder.Id,'','', durationTime,severity,
                                                                                              'Request:'+objPaymentFindResponse.requestBody,'Response:'+objPaymentFindResponse.responseBody);
                                            //HDMP-8617: ends
                                            lstErrors.add(errorRecord);
                                        }                                           
                                    }
                                }
                                
                                objOrder.IsError__c = false;  
                                objOrder.Send_Email_To_Customer__c = true;
                                if(methodName == 'partial return'){                                                                        
                                    if(mapOldOrderStatus.get(objOrder.Id) == 'Activated' && objOrder.Delivery_Types__c == 'Install At Dealer'){
                                        objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                    }else {
                                        objOrder.Status = 'PARTIAL RETURN';
                                    }
                                     
                                    // current return values
                                    objOrder.Current_Return_Amount__c = refundAmount;
                                    objOrder.Current_Return_Tax__c = refundTax;
                                    
                                    //total return values
                                    objOrder.Total_Item_Return__c += refundAmount;
                                    objOrder.Total_Ship_Return__c += objOrder.Shipping_Refund__c;
                                    objOrder.Total_Tax_Return__c += refundTax;
                                    objOrder.Total_Return__c += totalRefundAmount;
                                    objOrder.Total_Restocking_Fees__c += objOrder.Restocking_Fees__c;
                                    objOrder.Total_Installation_Return__c += objOrder.Install_Refund__c;   
                                    objOrder.Total_Return_Pre_Tax_Amount__c = (objOrder.Total_Return__c + objOrder.Restocking_Fees__c) - objOrder.Total_Tax_Return__c;

                                   
                                    
                                    
                                    // changes for HDMP-10051 
                                    // Saravanan LTIM Added && returnCoreChargeQuantities == objOrder.Total_Core_Charge_Original_Quantity__c for HDMP-19407
                                    if(objOrder.Updated_Order_Amount__c == objOrder.Total_Item_Return__c && objOrder.Updated_Shipping__c == objOrder.Total_Ship_Return__c && objOrder.Total_Installation_Charges__c == objOrder.Total_Installation_Return__c && returnCoreChargeQuantities == objOrder.Total_Core_Charge_Original_Quantity__c){
                                        objOrder.Status = 'ORDER RETURN';
                                    }
                                   
                                    pricesMap.put('returnTotal',totalRefundAmount);
                                    pricesMap.put('returnTax',refundTax);
                                }
                                
                                if(methodName == 'partial return' || methodName == 'void') {
                                    //creating a new credit transaction      
                                    BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();
                                    objBTTransactionDetails.BT_TransactionId__c = objBrainTreeTransactionResponse.transactionBT.id;
                                    objBTTransactionDetails.Type__c = objBrainTreeTransactionResponse.transactionBT.type;
                                    objBTTransactionDetails.Name = methodName == 'partial return' ? 'Return Transaction' : 'Void Transaction';
                                    objBTTransactionDetails.Order__c = objOrder.Id;
                                    if(objBrainTreeTransactionResponse.transactionBT.status == 'authorization_expired'){
                                        objBTTransactionDetails.Transaction_Status__c = 'Voided';
                                    }else {
                                    objBTTransactionDetails.Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                    }
                                    objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                    objBTTransactionDetails.Billing_Street__c = objOrder.BT_Transaction_Details__r[0].Billing_Street__c;
                                    objBTTransactionDetails.Billing_City__c = objOrder.BT_Transaction_Details__r[0].Billing_City__c;
                                    objBTTransactionDetails.Billing_State__c = objOrder.BT_Transaction_Details__r[0].Billing_State__c;
                                    objBTTransactionDetails.Billing_PostalCode__c = objOrder.BT_Transaction_Details__r[0].Billing_PostalCode__c;
                                    objBTTransactionDetails.Credit_Card_Number__c = objOrder.BT_Transaction_Details__r[0].Credit_Card_Number__c;
                                    objBTTransactionDetails.Payment_Gateway__c = objOrder.BT_Transaction_Details__r[0].Payment_Gateway__c;
                                    objBTTransactionDetails.Payment_Method_Type__c = objOrder.BT_Transaction_Details__r[0].Payment_Method_Type__c;
                                    objBTTransactionDetails.Payment_Method_Token__c = objOrder.BT_Transaction_Details__r[0].Payment_Method_Token__c;
                                    objBTTransactionDetails.Cardholder_Name__c = objOrder.BT_Transaction_Details__r[0].Cardholder_Name__c; 
                                    lstBTTransactionDetails.add(objBTTransactionDetails);
                                }    
                                
                                String shippingCharge = objOrder.Shipping_Refund__c != 0 ? String.valueOf(objOrder.Shipping_Refund__c) : null;
                                String installCharge = objOrder.Install_Refund__c != 0 ? String.valueOf(objOrder.Install_Refund__c) : null;
                                B2B_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper;
                                if(methodName == 'void') {
                                    //call vertax return tax for full return
                                    objResponseDataWrapper = B2B_BrainTreeUtils.callVertaxReturnTax(objAccount, objOrder);           
                                }else if(methodName == 'partial return'){
                                    //call vertax line item return tax 
                                    objResponseDataWrapper = B2B_BrainTreeUtils.callVertaxLineItemReturnTax(objAccount, objOrder, shippingCharge, installCharge);                                 
                                }
                                
                                if(objResponseDataWrapper != null && objResponseDataWrapper.isSuccess == false){
                                    isVertaxFails = true;
                                }
                                
                                if(methodName != 'void'){
                                    if(objResponseDataWrapper.isSuccess == true){
                                        // changes for HDMP-8716 starts
                                        Map<String, Vertex_Details__c> mapOrderItemVertexTax = new Map<String, Vertex_Details__c>();
                                        if(!objResponseDataWrapper.lstVertexDetails.isEmpty()){
                                            Decimal installReturnTax = 0;
                                            Decimal shippingReturnTax = 0;
                                            Decimal restockingTax = 0;
                                            // map order item and vertex details records to update order item tax
                                            for(Vertex_Details__c objVertexDetails : objResponseDataWrapper.lstVertexDetails){ 
                                                if(String.isNotEmpty(objVertexDetails.OrderItem__c)){
                                                    mapOrderItemVertexTax.put(objVertexDetails.OrderItem__c, objVertexDetails);
                                                }else if(objVertexDetails.B2B_Cart_Item_Id__c == Label.B2B_Installation_Code){
                                                    installReturnTax = objVertexDetails.B2B_Total_Tax__c;
                                                }else if(objVertexDetails.B2B_Cart_Item_Id__c == Label.B2B_Shipping_Code){
                                                    shippingReturnTax = objVertexDetails.B2B_Total_Tax__c;
                                                }else if(objVertexDetails.B2B_Cart_Item_Id__c == Label.B2B_Restocking_Code){
                                                    restockingTax = objVertexDetails.B2B_Total_Tax__c;
                                                }
                                            } 
                                            pricesMap.put('restockingTax',-1 * restockingTax);
                                            pricesMap.put('shippingTax',-1 * shippingReturnTax);
                                            pricesMap.put('installTax',-1 * installReturnTax);
                                            
                                            // changes for HDMP-8729
                                            objOrder.Total_Return_Installation_Tax__c = objOrder.Total_Return_Installation_Tax__c + (-1 * installReturnTax);
                                            objOrder.Return_Shipping_Tax__c = objOrder.Return_Shipping_Tax__c + (-1 * shippingReturnTax);
                                            objOrder.Total_Restocking_Fee_Tax__c += restockingTax;
                                            Decimal returnQuantity = 0;
                                            Decimal returnProductTax = 0;

                                            // Saravanan LTIM Starts - Sprint 2 Data Rules Partial Return Complete REMAN-208

                                            Decimal returnCoreChargeQuantity = 0;
                                            Decimal returnCoreChargeTax = 0;
                                            Decimal returnCoreAmount = 0;

                                            // Saravanan LTIM Ends - Sprint 2 Data Rules Partial Return Complete REMAN-208

                                            // update the product tax on the order items
                                            for(OrderItem objOrderItem : objOrder.OrderItems){ 
                                                if(mapOrderItemVertexTax.containsKey(objOrderItem.Id)){
                                                    Vertex_Details__c objVertexDetail = mapOrderItemVertexTax.get(objOrderItem.Id);                               
                                                    objOrderItem.Total_Return_Product_Tax__c = objOrderItem.Total_Return_Product_Tax__c + (-1 * objVertexDetail.B2B_Total_Tax__c);
                                                    pricesMap.put(objOrderItem.Id, (-1 * objVertexDetail.B2B_Total_Tax__c));
                                                    returnProductTax = returnProductTax + (-1 * objVertexDetail.B2B_Total_Tax__c);
                                                  // Saravanan LTIM Starts - Sprint 2 Data Rules Partial Return Complete REMAN-208
                                                  if(objOrderItem.Product_Type__c == Label.B2B_Product_Code_Core_Charges){
                                                        returnCoreChargeTax = returnCoreChargeTax + (-1 * objVertexDetail.B2B_Total_Tax__c);
                                                    }

                                                    // Saravanan LTIM Ends - Sprint 2 Data Rules Partial Return Complete REMAN-208


                                                    lstOrderItemUpdate.add(objOrderItem);
                                                } 
                                                returnQuantity += objOrderItem.Return_Quantity__c;

                                                // Saravanan LTIM Starts - Sprint 2 Data Rules Partial Return Complete REMAN-208

                                                if(objOrderItem.Product_Type__c == Label.B2B_Product_Code_Core_Charges){
                                                    returnCoreChargeQuantity += objOrderItem.Return_Quantity__c;
                                                    //returnCoreAmount += (returnCoreChargeQuantity * objOrderItem.UnitPrice) ;
                                                    returnCoreAmount+=objOrderItem.Delta_Quantity__c * objOrderItem.ListPrice; //Saravanan LTIM HDMP-19484

                                                }

                                                // Saravanan LTIM Starts - Sprint 2 Data Rules Partial Return Complete REMAN-208

                                            }
                                            objOrder.Return_Quantity__c = returnQuantity;
                                            objOrder.Total_Return_Product_Tax__c += returnProductTax;
                                            // changes for HDMP-8716 ends 
                                            
                                            // Saravanan LTIM Starts - Sprint 2 Data Rules Partial Return Complete REMAN-208
                                            objOrder.Total_Core_Charge_Return_Amount__c = returnCoreAmount;
                                            objOrder.Total_Core_Charge_Return_Quantity__c = returnCoreChargeQuantity;
                                            objOrder.Total_Core_Charge_Return_Tax__c = objOrder.Total_Core_Charge_Return_Tax__c != null ? objOrder.Total_Core_Charge_Return_Tax__c + returnCoreChargeTax : returnCoreChargeTax;
                                           // Saravanan LTIM ENDS - Sprint 2 Data Rules Partial Return Complete REMAN-208
                                        }
                                    }else {
                                        Error__c objError = B2B_BrainTreeUtils.createErrorRecord('Vertax Return Callout Service Failed ', objOrder.Id, objResponseDataWrapper.errorMessage);                                    
                                        lstErrors.add(objError);
                                    }  
                                }      
                                //For HDMP-8716 : create order transaction for the order starts
                                Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, auditType, BTTransactionId, pricesMap);
                                lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                                lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                                //for HDMP-8716 : Audit Trail ends
                                
                                if(methodName == 'void'){ 
                                    objOrder.Updated_Order_Amount__c = 0;
                                    objOrder.Updated_Total_Tax__c = 0;
                                    objOrder.Updated_Order_Total__c = 0;  
                                    objOrder.Updated_Shipping__c = 0;
                                    objOrder.Current_Quantity__c = 0;
                                    objOrder.Current_Shipping_Tax__c = 0;
                                    objOrder.Total_Current_Pre_Tax_Order_Amount__c = 0;
                                    objOrder.Total_Current_Product_Tax__c = 0;

                                    
                                    // Saravanan LTIM Added Sprint 2 Data Rules for Sprint 2 - Cancel Reman Part Order

                                    objOrder.Total_Core_Charge_Current_Amount__c = 0;
                                    objOrder.Total_Core_Charge_Current_Tax__c = 0;
                                    objOrder.Total_Core_Charge_Current_Quantity__c = 0;
                                    // Saravanan LTIM Added Sprint 2 Data Rules for Sprint 2 - Cancel Reman Part Order

                                    
                                    //update orderItems
                                    for(OrderItem objOrderItem : objOrder.OrderItems){
                                        objOrderItem.Updated_Quantity__c = 0;
                                        objOrderItem.Total_Current_Product_Tax__c = 0;
                                        lstOrderItemUpdate.add(objOrderItem);
                                    }
                                }
                                
                                if(methodName == 'partial return'){ 
                                    //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
                                    //Creating the invoice & Invoice Item for the order
                                    Decimal returnTotalAmount = pricesMap.containsKey('returnTotal') ? pricesMap.get('returnTotal') : 0;
                                    Map<String , Object> mapInvoiceRecords = createInvoiceRecords(B2B_IntegrationConstants.ORDER_RETURN, objAccount, objOrder, BTTransactionId, totalRefundAmount, refundTax, pricesMap);
                                    lstInvoice.add((Invoice__c) mapInvoiceRecords.get(B2B_IntegrationConstants.INVOICE_OBJ));
                                    lstInvoiceItem = (List<Invoice_Item__c>) mapInvoiceRecords.get(B2B_IntegrationConstants.INVOICE_ITEMS);
                                    //Added by Faraz Ansari for HDMP-8705 - End
                                }
                            }else {
                                //ToDo Add Error object record
                               // objOrder.Status = mapOldOrderStatus.get(objOrder.Id); Saravanan LTIM Commennted for HDMP-18917
                                objOrder.IsError__c = true;
                                if(methodName == 'partial return'){
                                    objOrder.Status = mapOldOrderStatus.get(objOrder.Id); //Saravanan LTIM Commennted for HDMP-18917
                                    lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                                }else if(methodName == 'void'){
                                    system.debug('Void Return value---'+objOrder.status);
                                }

                           
                                BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();   
                                objBTTransactionDetails.Name = 'Failure Transaction';
                                objBTTransactionDetails.Transaction_Status__c = 'BT error code';
                                objBTTransactionDetails.Order__c = objOrder.Id;
                                objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                lstBTTransactionDetails.add(objBTTransactionDetails);
                                
                                //For HDMP-8716 : create order transaction for the order starts                                   
                                Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, auditType, BTTransactionId, pricesMap);
                                lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                                lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                                //for HDMP-8716 : Audit Trail ends
                                
                                Long afterAPI = B2B_Util.fetchCurrentTime();
                                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                                //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                                String severity;
                                String errorType;
                                Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                                if(errorRecords.containskey(String.valueOf(objBrainTreeTransactionResponse.status))){
                                    severity= errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).severity__c;
                                    errorType=errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).error_Type__c;
                                }
                                else{
                                    severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                                    errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                                }
                                
                                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                  'B2B_BrainTreeIntegration',String.valueOf(objBrainTreeTransactionResponse.status),errorType,'',
                                                                                  'braintreeOrderCancellation',true,objOrder.Id,'','', durationTime,severity,
                                                                                  'Request:'+objBrainTreeTransactionResponse.requestBody,'Response:'+objBrainTreeTransactionResponse.responseBody);
                                //HDMP-8617: ends
                                lstErrors.add(errorRecord);
                            }                            
                        }else if(objBTTokenDetails.RefreshTokenExpiresAT__c > System.now()){   
                            
                            //make callout to refresh token api for updating the BT_Token_Details object with the latest Access/Refresh Token. 
                            String refreshTokenResponse = getRefreshToken(objAccount.Merchant_Id__c, objBTTokenDetails.RefreshToken__c);
                            B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();           
                            objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(refreshTokenResponse, B2B_AccessTokenResponseWrapper.class);                       
                            
                            Long beforeAPI = B2B_Util.fetchCurrentTime();
                            if(objAccessTokenResponseWrapper.status == 200){                                 
                                //updating BT_Token_Details object
                                objBTTokenDetails = B2B_BrainTreeUtils.checkBTTokenDetails(objBTTokenDetails, objAccessTokenResponseWrapper);                                   
                                lstBTTokenDetailsUpdate.add(objBTTokenDetails); 
                                
                                Decimal refundAmount = 0;
                                Decimal refundTax = objOrder.Tax_Refund__c;
                                Decimal totalRefundAmount = 0;
                                Decimal fullRefundAmount = 0;

                                // Saravanan LTIM below Variable for 19407

                                Decimal returnCoreChargeQuantities = 0;
                                
                                if(methodName == 'void'){
                                    //call the transaction search api to check the current status of transaction before charging the customer
                                    B2B_BrainTreeTransactionResponse objBrainTreeSearchResponse = new B2B_BrainTreeTransactionResponse();
                                    String searchResponse = braintreeTransactionSearch(transactionID, objBTTokenDetails.AccessToken__c);
                                    objBrainTreeSearchResponse = B2B_BrainTreeTransactionResponse.parse(searchResponse);
                                    // if the transaction is expired again create a new transaction by the preAuth API using payment token stored on order
                                    if(objBrainTreeSearchResponse.status == 200 && objBrainTreeSearchResponse.transactionBT.status == 'authorized'){
                                    brainTreeResponse = braintreeTransactionVoid(customerID, objAccount.Merchant_Id__c, transactionID, objBTTokenDetails.AccessToken__c);                            
                                    }else{
                                        brainTreeResponse = searchResponse;
                                    }                           
                                }else if(methodName == 'partial return'){
                                    // make callout to braintree refund api with the return amount
                                    // calculate the amount from order items for passing to refund call
                                    Decimal returnCoreAmount = 0.0; // Saravanan LTIM 19433
                                    for(OrderItem objOrderItem : objOrder.OrderItems){ 
                                        if(objOrderItem.Delta_Quantity__c != 0){
                                            refundAmount += objOrderItem.Delta_Quantity__c * objOrderItem.ListPrice;    

                                        }

                                        // Saravanan Added LTIM Sprint 2 - Data Rules Logic Order Return 19407

                                        if(objOrderItem.Product_Type__c == 'Core Charge'){

                                            returnCoreChargeQuantities += objOrderItem.Return_Quantity__c;
                                            returnCoreAmount += objOrderItem.Delta_Quantity__c * objOrderItem.ListPrice; // Saravanan LTIM HDMP-19433
                                        }

                                        // Saravanan Ended LTIM Sprint 2 - Data Rules Logic Order Return 
                                        
                                    }
                                    
                                    if(objOrder.cart__r.Pickup_Dealer__c == false){       
                                        // Saravanan LTIM HDMP-19433 returnCoreAmount
                            
                                        totalRefundAmount = (refundAmount + refundTax + objOrder.Shipping_Refund__c + returnCoreAmount) - objOrder.Restocking_Fees__c;
                                    }else {                                  
                                        totalRefundAmount = (refundAmount + refundTax + objOrder.Install_Refund__c + returnCoreAmount) - objOrder.Restocking_Fees__c;   
                                    }
                                    totalRefundAmount = totalRefundAmount.setScale(2);
                                    brainTreeResponse = braintreeTransactionRefund(customerID, objAccount.Merchant_Id__c, transactionID, objBTTokenDetails.AccessToken__c, String.valueOf(totalRefundAmount));
                                }
                                objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parse(brainTreeResponse);
                                //check if the response status is 200
                                if(objBrainTreeTransactionResponse.status == 200){                                   
                                    if(methodName == 'void'){                                                                                                                 
                                        if(objBrainTreeTransactionResponse.transactionBT.status == 'authorization_expired'){
                                            objOrder.BT_Transaction_Status__c = 'Voided';
                                        }else {
                                        objOrder.BT_Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                        }                                       
                                        //changes for HDMP-8730 :- delete the payment method from honda braintree for one time credit card
                                        if(isSavedPaymentMethod == false && String.isNotEmpty(objOrder.Payment_Method_Token__c)){
                                            
                                            // get the address id from payment method find API
                                            B2B_BrainTreeTransactionResponse objPaymentFindResponse = braintreePaymentMethodFind(objOrder.Payment_Method_Token__c);
                                            if(objPaymentFindResponse.status == 200){     
                                                //delete the one time payment method from BT
                                                braintreePaymentMethodDelete(objOrder.Payment_Method_Token__c);
                                                if(String.isNotEmpty(objOrder.BT_Customer_Legecy_Id__c)){
                                                    //delete the related address to the payment method
                                                    braintreeAddressDelete(objOrder.BT_Customer_Legecy_Id__c, objPaymentFindResponse.billingAddressId);
                                                }                                       
                                            }else{
                                                Long afterAPI = B2B_Util.fetchCurrentTime();
                                                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
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
                                                
                                                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                                Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                                  'B2B_BrainTreeIntegration',String.valueOf(objPaymentFindResponse.status),errorType,'',
                                                                                                  'braintreeOrderCancellation',true, objOrder.Id,'','', durationTime,severity,
                                                                                                  'Request:'+objPaymentFindResponse.requestBody,'Response:'+objPaymentFindResponse.responseBody);
                                                //HDMP-8617: ends
                                                lstErrors.add(errorRecord);
                                            }                                           
                                        }
                                    }
                                    
                                    objOrder.IsError__c = false; 
                                    objOrder.Send_Email_To_Customer__c = true;
                                    if(methodName == 'partial return'){
                                        if(mapOldOrderStatus.get(objOrder.Id) == 'Activated' && objOrder.Delivery_Types__c == 'Install At Dealer'){
                                            objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                        }else {
                                            objOrder.Status = 'PARTIAL RETURN';
                                        }
                                        
                                        // current return values
                                        objOrder.Current_Return_Amount__c = refundAmount;
                                        objOrder.Current_Return_Tax__c = refundTax;
                                        
                                        //total return values
                                        objOrder.Total_Item_Return__c += refundAmount;
                                        objOrder.Total_Ship_Return__c += objOrder.Shipping_Refund__c;
                                        objOrder.Total_Tax_Return__c += refundTax;
                                        objOrder.Total_Return__c += totalRefundAmount;
                                        objOrder.Total_Restocking_Fees__c += objOrder.Restocking_Fees__c;
                                        objOrder.Total_Installation_Return__c += objOrder.Install_Refund__c;
                                        objOrder.Total_Return_Pre_Tax_Amount__c = (objOrder.Total_Return__c + objOrder.Restocking_Fees__c) - objOrder.Total_Tax_Return__c;
                                        
                                        // changes for HDMP-10051 
                                        // Saravanan LTIM Added && objOrder.Total_Core_Charge_Return_Quantity__c == objOrder.Total_Core_Charge_Original_Quantity__c for HDMP-19407
                                        if(objOrder.Updated_Order_Amount__c == objOrder.Total_Item_Return__c && objOrder.Updated_Shipping__c == objOrder.Total_Ship_Return__c && objOrder.Total_Installation_Charges__c == objOrder.Total_Installation_Return__c && returnCoreChargeQuantities == objOrder.Total_Core_Charge_Original_Quantity__c ){
                                            objOrder.Status = 'ORDER RETURN';
                                        }

                                        pricesMap.put('returnTotal',totalRefundAmount);
                                        pricesMap.put('returnTax',refundTax);
                                    }
                                    
                                    if(methodName == 'partial return' || methodName == 'void') {
                                        //creating a new credit transaction      
                                        BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();
                                        objBTTransactionDetails.BT_TransactionId__c = objBrainTreeTransactionResponse.transactionBT.id;
                                        objBTTransactionDetails.Type__c = objBrainTreeTransactionResponse.transactionBT.type;
                                        objBTTransactionDetails.Name = methodName == 'partial return' ? 'Return Transaction' : 'Void Transaction';
                                        objBTTransactionDetails.Order__c = objOrder.Id;
                                        if(objBrainTreeTransactionResponse.transactionBT.status == 'authorization_expired'){
                                            objBTTransactionDetails.Transaction_Status__c = 'Voided';
                                        }else {
                                        objBTTransactionDetails.Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                        }                                 
                                        objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                        objBTTransactionDetails.Billing_Street__c = objOrder.BT_Transaction_Details__r[0].Billing_Street__c;
                                        objBTTransactionDetails.Billing_City__c = objOrder.BT_Transaction_Details__r[0].Billing_City__c;
                                        objBTTransactionDetails.Billing_State__c = objOrder.BT_Transaction_Details__r[0].Billing_State__c;
                                        objBTTransactionDetails.Billing_PostalCode__c = objOrder.BT_Transaction_Details__r[0].Billing_PostalCode__c;
                                        objBTTransactionDetails.Credit_Card_Number__c = objOrder.BT_Transaction_Details__r[0].Credit_Card_Number__c;
                                        objBTTransactionDetails.Payment_Gateway__c = objOrder.BT_Transaction_Details__r[0].Payment_Gateway__c;
                                        objBTTransactionDetails.Payment_Method_Type__c = objOrder.BT_Transaction_Details__r[0].Payment_Method_Type__c;
                                        objBTTransactionDetails.Payment_Method_Token__c = objOrder.BT_Transaction_Details__r[0].Payment_Method_Token__c;
                                        objBTTransactionDetails.Cardholder_Name__c = objOrder.BT_Transaction_Details__r[0].Cardholder_Name__c; 
                                        lstBTTransactionDetails.add(objBTTransactionDetails);
                                    }   
                                    String shippingCharge = objOrder.Shipping_Refund__c != 0 ? String.valueOf(objOrder.Shipping_Refund__c) : null;
                                    String installCharge = objOrder.Install_Refund__c != 0 ? String.valueOf(objOrder.Install_Refund__c) : null;
                                    B2B_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper;
                                    if(methodName == 'void') {
                                        //call vertax return tax for full return
                                        objResponseDataWrapper = B2B_BrainTreeUtils.callVertaxReturnTax(objAccount, objOrder);           
                                    }else if(methodName == 'partial return'){
                                        //call vertax line item return tax 
                                        objResponseDataWrapper = B2B_BrainTreeUtils.callVertaxLineItemReturnTax(objAccount, objOrder, shippingCharge, installCharge);                                 
                                    }
                                    
                                    if(objResponseDataWrapper != null && objResponseDataWrapper.isSuccess == false){
                                        isVertaxFails = true;
                                    }
                                    
                                    if(methodName != 'void'){
                                        if(objResponseDataWrapper.isSuccess == true){
                                            // changes for HDMP-8716 starts
                                            Map<String, Vertex_Details__c> mapOrderItemVertexTax = new Map<String, Vertex_Details__c>();
                                            if(!objResponseDataWrapper.lstVertexDetails.isEmpty()){
                                                Decimal installReturnTax = 0;
                                                Decimal shippingReturnTax = 0;
                                                Decimal restockingTax = 0;
                                                // map order item and vertex details records to update order item tax
                                                for(Vertex_Details__c objVertexDetails : objResponseDataWrapper.lstVertexDetails){ 
                                                    if(String.isNotEmpty(objVertexDetails.OrderItem__c)){
                                                        mapOrderItemVertexTax.put(objVertexDetails.OrderItem__c, objVertexDetails);
                                                    }else if(objVertexDetails.B2B_Cart_Item_Id__c == Label.B2B_Installation_Code){
                                                        installReturnTax = objVertexDetails.B2B_Total_Tax__c;
                                                    }else if(objVertexDetails.B2B_Cart_Item_Id__c == Label.B2B_Shipping_Code){
                                                        shippingReturnTax = objVertexDetails.B2B_Total_Tax__c;
                                                    }else if(objVertexDetails.B2B_Cart_Item_Id__c == Label.B2B_Restocking_Code){
                                                        restockingTax = objVertexDetails.B2B_Total_Tax__c;
                                                    }
                                                    
                                                } 

                                                pricesMap.put('restockingTax',-1 * restockingTax);
                                                pricesMap.put('shippingTax',-1 * shippingReturnTax);
                                                pricesMap.put('installTax',-1 * installReturnTax);

                                                // changes for HDMP-8729
                                                objOrder.Total_Return_Installation_Tax__c = objOrder.Total_Return_Installation_Tax__c + (-1 * installReturnTax);
                                                objOrder.Return_Shipping_Tax__c = objOrder.Return_Shipping_Tax__c + (-1 * shippingReturnTax);
                                                objOrder.Total_Restocking_Fee_Tax__c += restockingTax;
                                                Decimal returnQuantity = 0;
                                                Decimal returnProductTax = 0;
                                                // update the product tax on the order items
                                                for(OrderItem objOrderItem : objOrder.OrderItems){ 
                                                    if(mapOrderItemVertexTax.containsKey(objOrderItem.Id)){
                                                        Vertex_Details__c objVertexDetail = mapOrderItemVertexTax.get(objOrderItem.Id);
                                                        objOrderItem.Total_Return_Product_Tax__c = objOrderItem.Total_Return_Product_Tax__c + (-1 * objVertexDetail.B2B_Total_Tax__c);
                                                        pricesMap.put(objOrderItem.Id, (-1 * objVertexDetail.B2B_Total_Tax__c));
                                                        returnProductTax = returnProductTax + (-1 * objVertexDetail.B2B_Total_Tax__c);
                                                        lstOrderItemUpdate.add(objOrderItem);
                                                    } 
                                                    returnQuantity += objOrderItem.Return_Quantity__c;
                                                }
                                                objOrder.Return_Quantity__c = returnQuantity;
                                                objOrder.Total_Return_Product_Tax__c += returnProductTax;
                                                // changes for HDMP-8716 ends                                           
                                            }
                                        }else {
                                            Error__c objError = B2B_BrainTreeUtils.createErrorRecord('Vertax Return Callout Service Failed ', objOrder.Id, objResponseDataWrapper.errorMessage);                                    
                                            lstErrors.add(objError);
                                        }  
                                    }      
                                    //For HDMP-8716 : create order transaction for the order starts                                   
                                    Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, auditType, BTTransactionId, pricesMap);
                                    lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                                    lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                                    //for HDMP-8716 : Audit Trail ends
                                    
                                    if(methodName == 'void'){ 
                                        objOrder.Updated_Order_Amount__c = 0;
                                        objOrder.Updated_Total_Tax__c = 0;
                                        objOrder.Updated_Order_Total__c = 0;  
                                        objOrder.Updated_Shipping__c = 0;
                                        objOrder.Current_Quantity__c = 0;
                                        objOrder.Current_Shipping_Tax__c = 0;
                                        objOrder.Total_Current_Pre_Tax_Order_Amount__c = 0;
                                        objOrder.Total_Current_Product_Tax__c = 0;


                                        // Saravanan LTIM Added Sprint 2 Data Rules for Sprint 2 - Order Checkout, Cancellation, Modification, & Fulfillment

                                        objOrder.Total_Core_Charge_Current_Amount__c = 0;
                                        objOrder.Total_Core_Charge_Current_Tax__c = 0;
                                        objOrder.Total_Core_Charge_Current_Quantity__c = 0;
                                        // Saravanan LTIM Added Sprint 2 Data Rules for Sprint 2 - Order Checkout, Cancellation, Modification, & Fulfillment
                                        
                                        //update orderItems
                                        for(OrderItem objOrderItem : objOrder.OrderItems){
                                            objOrderItem.Updated_Quantity__c = 0;
                                            objOrderItem.Total_Current_Product_Tax__c = 0;
                                            lstOrderItemUpdate.add(objOrderItem);
                                        }
                                    }
                                    
                                    if(methodName == 'partial return'){ 
                                        //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
                                        //Creating the invoice & Invoice Item for the order
                                        Decimal returnTotalAmount = pricesMap.containsKey('returnTotal') ? pricesMap.get('returnTotal') : 0;
                                        Map<String , Object> mapInvoiceRecords = createInvoiceRecords(B2B_IntegrationConstants.ORDER_RETURN, objAccount, objOrder, BTTransactionId, totalRefundAmount, refundTax, pricesMap);
                                        lstInvoice.add((Invoice__c) mapInvoiceRecords.get(B2B_IntegrationConstants.INVOICE_OBJ));
                                        lstInvoiceItem = (List<Invoice_Item__c>) mapInvoiceRecords.get(B2B_IntegrationConstants.INVOICE_ITEMS);
                                        //Added by Faraz Ansari for HDMP-8705 - End
                                    }
                                }else {
                                    objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                    objOrder.IsError__c = true;
                                    
                                    if(methodName == 'partial return'){
                                        lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                                    }
                                    
                                    BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();   
                                    objBTTransactionDetails.Name = 'Failure Transaction';
                                    objBTTransactionDetails.Transaction_Status__c = 'BT error code';
                                    objBTTransactionDetails.Order__c = objOrder.Id;
                                    objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                    lstBTTransactionDetails.add(objBTTransactionDetails);
                                    
                                    //For HDMP-8716 : create order transaction for the order starts                                   
                                    Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, auditType, BTTransactionId, pricesMap);
                                    lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                                    lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                                    //for HDMP-8716 : Audit Trail ends
                                          
                                    Long afterAPI = B2B_Util.fetchCurrentTime();
                                    Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                                    //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                                    String severity;
                                    String errorType;
                                    Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                                    if(errorRecords.containskey(String.valueOf(objBrainTreeTransactionResponse.status))){
                                        severity= errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).severity__c;
                                        errorType=errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).error_Type__c;
                                    }
                                    else{
                                        severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                                        errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                                    }
                                    
                                    String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                    Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                      'B2B_BrainTreeIntegration',String.valueOf(objBrainTreeTransactionResponse.status),errorType,'',
                                                                                      'braintreeOrderCancellation',true,objOrder.Id,'','', durationTime,severity,
                                                                                      'Request:'+objBrainTreeTransactionResponse.requestBody,'Response:'+objBrainTreeTransactionResponse.responseBody);
                                    //HDMP-8617: ends
                                    lstErrors.add(errorRecord);
                                }                                     
                            }else {                                                             
                                system.debug('error in Refresh Token callout');
                                //objOrder.Status = mapOldOrderStatus.get(objOrder.Id); Saravanan LTIM Commented for HDMP-18917
                                objOrder.IsError__c = true;
                                
                                if(methodName == 'partial return'){
                                    objOrder.Status = mapOldOrderStatus.get(objOrder.Id); // Saravanan LTIM Added for HDMP-18917
                                    lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                                }
                                
                                BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();   
                                objBTTransactionDetails.Name = 'Failure Transaction';
                                objBTTransactionDetails.Transaction_Status__c = 'BT error code';
                                objBTTransactionDetails.Order__c = objOrder.Id;
                                objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                lstBTTransactionDetails.add(objBTTransactionDetails);
                                
                                //For HDMP-8716 : create order transaction for the order starts                                   
                                Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, auditType, BTTransactionId, pricesMap);
                                lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                                lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                                //for HDMP-8716 : Audit Trail ends
                                
                                Long afterAPI = B2B_Util.fetchCurrentTime();
                                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
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
                                
                                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                  'B2B_BrainTreeIntegration',String.valueOf(objAccessTokenResponseWrapper.status),errorType,'',
                                                                                  'braintreeOrderCancellation',true,objOrder.Id,'','', durationTime,severity,
                                                                                  'Request:'+objAccessTokenResponseWrapper.requestBody,'Response:'+objAccessTokenResponseWrapper.responseBody);
                                //HDMP-8617: ends
                                lstErrors.add(errorRecord);
                            }             
                        }                   
                    }else {                     
                        //ToDo Throw a message on page to show the Order is missing Customer ID or BT Transaction record
                        objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                        objOrder.IsError__c = true;
                        
                        if(methodName == 'partial return'){
                            lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                        }
                        
                        //For HDMP-8716 : create order transaction for the order starts                                   
                        Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, auditType, '', pricesMap);
                        lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                        lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                        //for HDMP-8716 : Audit Trail ends
                        
                        Error__c objError = B2B_BrainTreeUtils.createErrorRecord('Missing Data On Record ', objOrder.Id, 'the Order is missing Customer ID or BT Transaction Id');
                        lstErrors.add(objError);
                    }                 
                }else {
                    objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                    objOrder.IsError__c = true;
                    
                    if(methodName == 'partial return'){
                       lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                    }
                    
                    //For HDMP-8716 : create order transaction for the order starts                                   
                    Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, auditType, '', pricesMap);
                    lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                    lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                    //for HDMP-8716 : Audit Trail ends
                    Error__c objError = B2B_BrainTreeUtils.createErrorRecord('BT Token Detail Missing ', objOrder.Id, 'the related account is missing BT_Token_Details__c record');
                    lstErrors.add(objError);
                } 
            }catch(Exception ex){
                System.debug('exeption :-' + ex.getMessage() + ' line number : '+ ex.getLineNumber());
                objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                objOrder.IsError__c = true;               
                
                if(methodName == 'partial return'){
                   lstOrderItemUpdate = revertOrderItemChanges(objOrder.OrderItems);
                }        
                
                //For HDMP-8716 : create order transaction for the order starts                                   
                Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, auditType, '', pricesMap);
                lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                //for HDMP-8716 : Audit Trail ends
                Error__c objError = B2B_BrainTreeUtils.createErrorRecord('Exception Occured ', objOrder.Id, ex.getMessage());
                objError.Line_Number__c = ex.getLineNumber();
                objError.StackTrace__c = ex.getStackTraceString();
                objError.Error_Type__c = ex.getTypeName();
                lstErrors.add(objError);                
            }
             //Saravanan , Ashwin LTIM Added for bug 18896 ,  [REMAN-140]

             
              if(objOrder.status == 'CUSTOMER CANCELED' || objOrder.status == 'DEALER CANCELED'){
                objOrder.Current_Quantity__c = 0;
                objOrder.Total_Current_Product_Amount__c = 0;
                objOrder.Total_Current_Product_Tax__c = 0;
                objOrder.Updated_Total_Tax__c= 0;
                objOrder.Updated_Order_Total__c = 0;
                objOrder.Total_Core_Charge_Current_Amount__c = 0;
                objOrder.Total_Core_Charge_Current_Tax__c = 0;
                objOrder.Total_Core_Charge_Current_Quantity__c = 0;
             }
            // Saravanan , Ashwin LTIM Added for bug 18896
            lstOrderUpdate.add(objOrder);            
        }
        //for HDMP-8716 : Audit Trail starts
        if(!lstOrderTrans.isEmpty()){
            insert lstOrderTrans;

            // Saravanan LTIM Added for 19481
            if(methodName == 'partial return' && !lstInvoice.isEmpty()){

                for(Invoice__c objInvoice : lstInvoice){
                    objInvoice.Total_Core_Charge_Quantity__c  = lstOrderTrans[0].Total_Post_Adjustment_Core_Charge_Qty__c;
                    objInvoice.Total_Core_Charge_Amount__c  = lstOrderTrans[0].Total_Post_Adjustment_Core_Charge_Amount__c;
                    objInvoice.Total_Core_Charge_Tax__c  = lstOrderTrans[0].Total_Post_Adjustment_Core_Charge_Tax__c;
                }
            }

            if(!lstOrderTranItems.isEmpty()){
                for(Order_Transaction_Item__c itemObj : lstOrderTranItems){
                    itemObj.Order_Transaction__c = lstOrderTrans[0].Id;
                    itemObj.AK_Order_Transaction_Item__c = lstOrderTrans[0].Id + '' + itemObj.Order_Item__c; //Added by Ravi Prasad to populate AK Order Transaction Item as part of HDMP-12002

                        // Saravanan LTIM Added for Sprint 2 Data Rules Logic Dealer Order Fulfillment
                        itemObj.AK_Order_Transaction_Item__c =  lstOrderTrans[0].Id +'~' + itemObj.Order_Item__c +'~'+itemObj.Product_Type__c; // 19440;
                        // Saravanan LTIM Added for Sprint 2 Data Rules Logic Dealer Order Fulfillment

                }
                insert lstOrderTranItems;
            }
            //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
            //Filling invoice transaction field after order return creation
            for(Invoice__c invoiceObj : lstInvoice){
                invoiceObj.Order_Transaction__c = lstOrderTrans[0].Id;
            }
            //Added by Faraz Ansari for HDMP-8705 - End
            
            //Start
            // added for R2C1 : Tax Transaction to have a lookup to Order Transaction
            List<Vertex_Details__c> lstTaxTransactions = new List<Vertex_Details__c>();
            for(Vertex_Details__c objDetails : [SELECT Id, Order_Transaction__c FROM Vertex_Details__c WHERE Order__c =: lstOrders[0].Id AND Order_Transaction__c = null]){
                objDetails.Order_Transaction__c = lstOrderTrans[0].Id;
                lstTaxTransactions.add(objDetails);
            }
            
            if(!lstTaxTransactions.isEmpty()){
                update lstTaxTransactions;
            }
            //End
        }           
        //for HDMP-8716 : Audit Trail ends
        
        //update BT_Token_Details__c data
        if(!lstBTTokenDetailsUpdate.isEmpty())
            update lstBTTokenDetailsUpdate;
        
        if(isVertaxFails == true){
            List<Error__c> lstVertaxErrors = new List<Error__c>();
            for(Error__c err: [Select Id, Order_Transaction__c From Error__c Where Order__c =: lstOrders[0].Id Order By CreatedDate Desc Limit 1]){
                err.Order_Transaction__c = (!lstOrderTrans.isEmpty() ? lstOrderTrans[0].Id : null);
                lstVertaxErrors.add(err);
            }
            if(!lstVertaxErrors.isEmpty())
                update lstVertaxErrors;
        }
        
        // update Error object        
        if(!lstErrors.isEmpty()){
            for(Error__c err: lstErrors){
                err.Order_Transaction__c = (!lstOrderTrans.isEmpty() ? lstOrderTrans[0].Id : null);
            }
            insert lstErrors;
        }
            
        // BT_transaction_Details__c 
        if(!lstBTTransactionDetails.isEmpty()){
            if(!lstOrderTrans.isEmpty()){
                lstBTTransactionDetails[0].Order_Transaction__c = lstOrderTrans[0].Id;
            }
            insert lstBTTransactionDetails;
            
        }
            
        
        //update OrderItem
        if(!lstOrderItemUpdate.isEmpty())
            update lstOrderItemUpdate;
        
        //update OrderItem for full return
        if(!lstOrderItemReturnUpdate.isEmpty())
            update lstOrderItemReturnUpdate;       
      
        if(lstBTPaymentMethods.isEmpty())
            delete lstBTPaymentMethods;
        
        //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
        //Insert invoice & invoice item records for order  
        if(!lstInvoice.isEmpty()){
            insert lstInvoice;
            
            Invoice__c invoiceObj = [SELECT Id, Name FROM Invoice__c WHERE Id =: lstInvoice[0].Id];
            lstInvoice[0].Invoice_Number__c = invoiceObj.Name;
            lstInvoice[0].BT_Transaction_Details__c = !lstBTTransactionDetails.isEmpty() ? lstBTTransactionDetails[0].Id : null; 
            update lstInvoice;
            
            if(!lstInvoiceItem.isEmpty()){
                for(Invoice_Item__c itemObj : lstInvoiceItem){
                    itemObj.Invoice__c = lstInvoice[0].Id;
                     // Saravananan LTIMs Added the field assignment for Reman Data Rules and HDMP-19486
                     itemObj.AK_Invoice_Item__c = itemObj.AK_Invoice_Item__c != null ? itemObj.AK_Invoice_Item__c.replace('@INVOICEID',lstInvoice[0].id) : itemObj.AK_Invoice_Item__c;
                }
                System.debug('lstInvoiceItem : '+lstInvoiceItem);
                insert lstInvoiceItem;
            }
        }
        //Added by Faraz Ansari for HDMP-8705 - End        
        
        
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
    //@future(callout=true)  
    public static void braintreeOrderCapture(Set<Id> setOrderIds, Set<Id> setAccountIds, Map<Id, String> mapOldOrderStatus, String methodName){         
        List<BT_Token_Details__c> lstBTTokenDetailsUpdate = new List<BT_Token_Details__c>();
        List<Order> lstOrderUpdate = new List<Order>();
        List<BT_Payment_Method__c> lstBTPaymentMethods = new List<BT_Payment_Method__c>();
        List<Error__c> lstErrors = new List<Error__c>();
        List<Dealer_Email__c> lstDealerEmails = new List<Dealer_Email__c>();        
        String dealerLocatorResponse = '';
        List<BT_Transaction_Details__c> lstBTTransactionDetails = new List<BT_Transaction_Details__c>();
        //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
        List<Invoice__c> lstInvoice = new List<Invoice__c>();
        List<Invoice_Item__c> lstInvoiceItem = new List<Invoice_Item__c>();
        //Added by Faraz Ansari for HDMP-8705 - End
        
        //for HDMP-8716 : audit Trail 
        List<Order_Transaction__c> lstOrderTrans = new List<Order_Transaction__c>();
        List<Order_Transaction_Item__c> lstOrderTranItems = new List<Order_Transaction_Item__c>();
        
        List<BT_Payment_Method__c> deletePaymentMethods = new List<BT_Payment_Method__c>();
        B2B_BrainTreeTransactionResponse objBrainTreeTransactionResponse = new B2B_BrainTreeTransactionResponse();      
        
        //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
        List<Account> lstAccounts = [SELECT Id, Merchant_Id__c, Name, PoIId__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, Email__c, Phone,
                                     (SELECT Id, Name, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c, Account__c 
                                      FROM BT_Token_Details__r)                                   
                                     FROM Account 
                                     WHERE Id IN: setAccountIds];
        
         // Saravanan LTIM added for SPrint 2 SOQL Total_Core_Charge_Current_Quantity__c,Total_Core_Charge_Current_Amount__c , Total_Core_Charge_Current_Tax__c , 
        // Saravanan LTIM added for SPrint 2 SOQL Sub-Query Product_Type__c,Product2.Core_Charge_Unit_Price__c
        // Saravanan LTIM added for Sprint 2 Return API Total_Core_Charge_Return_Amount__c, Total_Core_Charge_Return_Quantity__c,Total_Core_Charge_Return_Tax__c ,Total_Core_Charge_Original_Quantity__c
        // Delivery_Type__c Exceptional Field
        List<Order> lstOrders = [SELECT Id, Shipped_Date__c, Updated_Order_Amount__c, Total_Restocking_Fee_Tax__c, Customer_Notes__c,Total_Restocking_Fees__c, BT_Customer_Legecy_Id__c, OrderNumber, OrderedDate, BT_Customer_Detail__c, Payment_Method_Token__c, Updated_Order_Total__c,  AccountId, Status, Updated_Shipping__c, Updated_Total_Tax__c, cart__r.ShippingAmount__c , cart__r.CustomerStreet__c, cart__r.CustomerCity__c, cart__r.Customer_State__c, ShipToContactId,BillingEmailAddress,
                                 Customer_Name__c,Shipping_Customer_Name__c, Payment_Type__c, Delivery_Types__c,Total_Shipping_Tax__c,Current_Shipping_Tax__c,ShippingAddress, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,OrderReferenceNumber,
                                 cart__r.CustomerPostalCode__c, BT_Transaction_Status__c, IsError__c, cart__c, Send_Email_To_Customer__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingAddress, BillingPhoneNumber, CC_Last4__c,
                                 (SELECT Id, Name, BT_TransactionId__c,Customer__c,Credit_Card_Number__c, Billing_Street__c, Billing_City__c, Billing_State__c, Billing_PostalCode__c, Payment_Gateway__c,Payment_Method_Type__c, Payment_Method_Token__c, Cardholder_Name__c FROM BT_Transaction_Details__r),
                                 (SELECT Id, Total_Current_Product_Tax__c, TotalPrice, Dealer_Installation_Price__c, Delta_Installation_Price__c, Delta_Quantity__c,Updated_Quantity__c,Return_Quantity__c, Quantity, UnitPrice, ListPrice, Total_Tax__c, Product_SKU__c, Cart_Item_Product_Name__c, Op_Code__c,Product_Type__c,Product2.Core_Charge_Unit_Price__c FROM OrderItems WHERE Type != 'Delivery Charge')
                                 , Total_Core_Charge_Current_Quantity__c,Total_Core_Charge_Current_Amount__c , Total_Core_Charge_Current_Tax__c ,
                                 Total_Core_Charge_Return_Amount__c, Total_Core_Charge_Return_Quantity__c,Total_Core_Charge_Return_Tax__c ,Total_Core_Charge_Original_Quantity__c,
                                 Delivery_Type__c,Quantity__c , Current_Quantity__c,Total_Current_Product_Amount__c,Total_Current_Product_Tax__c
                                 FROM Order 
                                 WHERE Id IN: setOrderIds];
        //Added by Faraz Ansari for HDMP-8705 - End

        Map<Id, Account> mapAccounts = new Map<Id, Account>();
        for(Account objAccount : lstAccounts){
            mapAccounts.put(objAccount.Id, objAccount);           
        }
        
        Boolean isSavedPaymentMethod = false;
        if(!lstOrders.isEmpty()){
            List<BT_Payment_Method__c> lstSavedPaymentMethods = [SELECT Id, Is_In_My_Payment__c FROM BT_Payment_Method__c 
                                                                 WHERE Payment_Method_Token__c =: lstOrders[0].Payment_Method_Token__c 
                                                                 AND BT_Customer_Details__r.BT_CustomerId__c =: lstOrders[0].BT_Customer_Detail__c];
            if(!lstSavedPaymentMethods.isEmpty()){
                if(lstSavedPaymentMethods[0].Is_In_My_Payment__c == false){
                    Integer orderCount = [SELECT count() FROM Order WHERE Payment_Method_Token__c =: lstOrders[0].Payment_Method_Token__c AND BT_Transaction_Status__c = 'Authorized'];
                    if(orderCount > 1){
                       isSavedPaymentMethod = true; 
                    }else {
                        deletePaymentMethods = lstSavedPaymentMethods;
                    }
                }else {
                    isSavedPaymentMethod = true; 
                }
                
            }
        }
        
        for(Order objOrder : lstOrders){
            try{
                String brainTreeResponse = '';
                Account objAccount = mapAccounts.get(objOrder.AccountId);               
                //check for the BT_Token_Details__c object is not equals to null
                if(!objAccount.BT_Token_Details__r.isEmpty()){     
                    BT_Token_Details__c objBTTokenDetails = objAccount.BT_Token_Details__r[0];  
                    //check if the response status is 200
                    Long beforeAPI = B2B_Util.fetchCurrentTime();
                    //check for the related Transaction and Customer object is not equals to null
                    if(String.isNotEmpty(objOrder.BT_Customer_Detail__c) && objOrder.BT_Transaction_Details__r.isEmpty() == false){
                        String BTTransactionId = objOrder.BT_Transaction_Details__r[0].Id; 
                        String customerId = objOrder.BT_Customer_Detail__c;                       
                        String transactionID = objOrder.BT_Transaction_Details__r[0].BT_TransactionId__c;                       
                        if(objBTTokenDetails.AccessTokenExpiresAt__c > System.now()){ 
                            Decimal totalAmount = objOrder.Updated_Order_Total__c.setScale(2);
                            
                            //changes for HDMP-8834 starts
                            if(String.isNotEmpty(objOrder.Payment_Method_Token__c)){
                                //call the transaction search api to check the current status of transaction before charging the customer
                                B2B_BrainTreeTransactionResponse objBrainTreeSearchResponse = new B2B_BrainTreeTransactionResponse();
                                String searchResponse = braintreeTransactionSearch(transactionID, objBTTokenDetails.AccessToken__c);
                                objBrainTreeSearchResponse = B2B_BrainTreeTransactionResponse.parse(searchResponse);
                                // if the transaction is expired again create a new transaction by the preAuth API using payment token stored on order
                                if(objBrainTreeSearchResponse.status == 200 && objBrainTreeSearchResponse.transactionBT.status == 'authorization_expired'){
                                    String preAuthResponse = braintreeTransactionPreAuth(customerID, objAccount.Merchant_Id__c, objBTTokenDetails.AccessToken__c, String.valueOf(totalAmount), objOrder.Payment_Method_Token__c, '');
                                    B2B_BrainTreeTransactionResponse objPreAuthResponse = B2B_BrainTreeTransactionResponse.parse(preAuthResponse);
                                    if(objPreAuthResponse.status == 200) { 
                                        transactionID = objPreAuthResponse.transactionBT.id;
                                    }else {
                                        Long afterAPI = B2B_Util.fetchCurrentTime();
                                        Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                                        //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                                        String severity;
                                        String errorType;
                                        Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                                        if(errorRecords.containskey(String.valueOf(objPreAuthResponse.status))){
                                            severity= errorRecords.get(String.valueOf(objPreAuthResponse.status)).severity__c;
                                            errorType=errorRecords.get(String.valueOf(objPreAuthResponse.status)).error_Type__c;
                                        }
                                        else{
                                            severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                                            errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                                        }
                                        
                                        String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                        Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                          'B2B_BrainTreeIntegration',String.valueOf(objPreAuthResponse.status),errorType,'',
                                                                                          'braintreeOrderCapture',true, objOrder.Id,'','', durationTime,severity,
                                                                                          'Request:'+objPreAuthResponse.requestBody,'Response:'+objPreAuthResponse.responseBody);
                                        //HDMP-8617: ends
                                        lstErrors.add(errorRecord);
                                    }
                                }else if(objBrainTreeSearchResponse.status != 200){
                                    Long afterAPI = B2B_Util.fetchCurrentTime();
                                    Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                                    //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                                    String severity;
                                    String errorType;
                                    Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                                    if(errorRecords.containskey(String.valueOf(objBrainTreeSearchResponse.status))){
                                        severity= errorRecords.get(String.valueOf(objBrainTreeSearchResponse.status)).severity__c;
                                        errorType=errorRecords.get(String.valueOf(objBrainTreeSearchResponse.status)).error_Type__c;
                                    }
                                    else{
                                        severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                                        errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                                    }
                                    
                                    String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                    Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                      'B2B_BrainTreeIntegration',String.valueOf(objBrainTreeSearchResponse.status),errorType,'',
                                                                                      'braintreeOrderCapture',true, objOrder.Id,'','', durationTime,severity,
                                                                                      'Request:'+objBrainTreeSearchResponse.requestBody,'Response:'+objBrainTreeSearchResponse.responseBody);
                                    //HDMP-8617: ends
                                    lstErrors.add(errorRecord);
                                }
                            }
                            //changes for HDMP-8834 end

                            // make callout to braintree post auth api
                            brainTreeResponse = braintreeTransactionPostAuth(customerID, objAccount.Merchant_Id__c, transactionID, String.valueOf(totalAmount), objBTTokenDetails.AccessToken__c);
                            
                            objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parse(brainTreeResponse);                            
                            
                            if(objBrainTreeTransactionResponse.status == 200){
                                system.debug('objBrainTreeTransactionResponse.transactionBT.status -----------1------------------------------------->'+objBrainTreeTransactionResponse.transactionBT.status);
                                objOrder.BT_Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                objOrder.BT_Transaction_Id__c = objBrainTreeTransactionResponse.transactionBT.id;
                                objOrder.IsError__c = false;   
                                objOrder.Send_Email_To_Customer__c = true;
                                
                                //creating the new transaction for fulfillment     
                                BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();   
                                objBTTransactionDetails.Name = 'Fulfilled Transaction';
                                objBTTransactionDetails.BT_TransactionId__c = objBrainTreeTransactionResponse.transactionBT.id;                               
                                objBTTransactionDetails.Type__c = objBrainTreeTransactionResponse.transactionBT.type;  
                                objBTTransactionDetails.Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                objBTTransactionDetails.Order__c = objOrder.Id;
                                objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                objBTTransactionDetails.Billing_Street__c = objOrder.BT_Transaction_Details__r[0].Billing_Street__c;
                                objBTTransactionDetails.Billing_City__c = objOrder.BT_Transaction_Details__r[0].Billing_City__c;
                                objBTTransactionDetails.Billing_State__c = objOrder.BT_Transaction_Details__r[0].Billing_State__c;
                                objBTTransactionDetails.Billing_PostalCode__c = objOrder.BT_Transaction_Details__r[0].Billing_PostalCode__c;
                                objBTTransactionDetails.Credit_Card_Number__c = objOrder.BT_Transaction_Details__r[0].Credit_Card_Number__c;
                                objBTTransactionDetails.Payment_Gateway__c = objOrder.BT_Transaction_Details__r[0].Payment_Gateway__c;
                                objBTTransactionDetails.Payment_Method_Type__c = objOrder.BT_Transaction_Details__r[0].Payment_Method_Type__c;
                                objBTTransactionDetails.Payment_Method_Token__c = objOrder.BT_Transaction_Details__r[0].Payment_Method_Token__c;
                                objBTTransactionDetails.Cardholder_Name__c = objOrder.BT_Transaction_Details__r[0].Cardholder_Name__c;                                 
                                lstBTTransactionDetails.add(objBTTransactionDetails);                                 
                                
                                 //changes for HDMP-8730 :- delete the payment method from honda braintree for one time credit card
                                if(isSavedPaymentMethod == false && String.isNotEmpty(objOrder.Payment_Method_Token__c)){
                                    
                                    // get the address id from payment method find API
                                    B2B_BrainTreeTransactionResponse objPaymentFindResponse = braintreePaymentMethodFind(objOrder.Payment_Method_Token__c);
                                    if(objPaymentFindResponse.status == 200){     
                                        //delete the one time payment method from BT
                                        braintreePaymentMethodDelete(objOrder.Payment_Method_Token__c);
                                        if(String.isNotEmpty(objOrder.BT_Customer_Legecy_Id__c)){
                                            //delete the related address to the payment method
                                            braintreeAddressDelete(objOrder.BT_Customer_Legecy_Id__c, objPaymentFindResponse.billingAddressId);  
                                        }
                                    }else{
                                        Long afterAPI = B2B_Util.fetchCurrentTime();
                                        Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
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
                                        
                                        String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                        Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                          'B2B_BrainTreeIntegration',String.valueOf(objPaymentFindResponse.status),errorType,'',
                                                                                          'braintreeOrderCapture',true, objOrder.Id,'','', durationTime,severity,
                                                                                          'Request:'+objPaymentFindResponse.requestBody,'Response:'+objPaymentFindResponse.responseBody);
                                        //HDMP-8617: ends
                                        lstErrors.add(errorRecord);
                                    }                                           
                                }                                                               
                                
                                //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
                                //Create the Invoice & Invoice Item for the order
                                Map<String , Object> mapInvoiceRecords = createInvoiceRecords(B2B_IntegrationConstants.ORDER_PLACE, objAccount, objOrder, BTTransactionId, 0, 0, new Map<String, Decimal>());
                                lstInvoice.add((Invoice__c) mapInvoiceRecords.get(B2B_IntegrationConstants.INVOICE_OBJ));
                                lstInvoiceItem = (List<Invoice_Item__c>) mapInvoiceRecords.get(B2B_IntegrationConstants.INVOICE_ITEMS);
                                //Added by Faraz Ansari for HDMP-8705 - End
                                    
                                //For HDMP-8716 : create order transaction for the order starts
                                Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, 'Fulfilled', BTTransactionId, null);
                                lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                                lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                                //for HDMP-8716 : Audit Trail ends
                                
                                //send emails to dealer
                                if(objAccount.Name.contains('Honda')){
                                    dealerLocatorResponse = B2B_BrainTreeUtils.dealerLocatorService('A',objAccount.PoIId__c);
                                }else {
                                    dealerLocatorResponse = B2B_BrainTreeUtils.dealerLocatorService('B',objAccount.PoIId__c);
                                }                               
                                if(String.isNotEmpty(dealerLocatorResponse)){
                                    B2B_BrainTreeUtils.DealerServiceResponse objResponse = (B2B_BrainTreeUtils.DealerServiceResponse) JSON.deserialize(dealerLocatorResponse, B2B_BrainTreeUtils.DealerServiceResponse.class);
                                    if(objResponse.isError == false && String.isNotEmpty(objResponse.dealerEmails)){
                                        List<String> lstEmails = objResponse.dealerEmails.split(';');             
                                        for(String email : lstEmails){  
                                            Dealer_Email__c objDealerEmail = new Dealer_Email__c();
                                            objDealerEmail.Email__c = email;
                                            objDealerEmail.Order__c = objOrder.Id;
                                            objDealerEmail.IsShipToHome__c = (objOrder.Updated_Shipping__c != null && objOrder.Updated_Shipping__c > 0) ? true : false;
                                            lstDealerEmails.add(objDealerEmail);
                                        }
                                    }
                                }                               
                            }else {
                                //ToDo Add Error object record
                                objOrder.Status = 'PAYMENT ISSUE';
                                objOrder.IsError__c = true;
                                objOrder.Shipped_Date__c = null;
                                objOrder.IsPaymentReproccessing__c = true;
                                
                                BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();   
                                objBTTransactionDetails.Name = 'Fulfill Failure Transaction';
                                objBTTransactionDetails.Transaction_Status__c = 'BT error code';
                                objBTTransactionDetails.Order__c = objOrder.Id;
                                objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                lstBTTransactionDetails.add(objBTTransactionDetails);
                                
                                //For HDMP-8716 : create order transaction for the order starts
                                Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, 'Fulfilled', BTTransactionId, null);
                                lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                                lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                                //for HDMP-8716 : Audit Trail ends
                                
                                Long afterAPI = B2B_Util.fetchCurrentTime();
                                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                                //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                                String severity;
                                String errorType;
                                Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                                if(errorRecords.containskey(String.valueOf(objBrainTreeTransactionResponse.status))){
                                    severity= errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).severity__c;
                                    errorType=errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).error_Type__c;
                                }
                                else{
                                    severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                                    errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                                }
                                
                                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                  'B2B_BrainTreeIntegration',String.valueOf(objBrainTreeTransactionResponse.status),errorType,'',
                                                                                  'braintreeOrderCapture',true, objOrder.Id,'','', durationTime,severity,
                                                                                  'Request:'+objBrainTreeTransactionResponse.requestBody,'Response:'+objBrainTreeTransactionResponse.responseBody);
                                //HDMP-8617: ends
                                lstErrors.add(errorRecord);
                                
                            }                            
                        }else if(objBTTokenDetails.RefreshTokenExpiresAT__c > System.now()){   
                            
                            //make callout to refresh token api for updating the BT_Token_Details object with the latest Access/Refresh Token. 
                            String refreshTokenResponse = getRefreshToken(objAccount.Merchant_Id__c, objBTTokenDetails.RefreshToken__c);
                            B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();           
                            objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(refreshTokenResponse, B2B_AccessTokenResponseWrapper.class);                       
                           
                            if(objAccessTokenResponseWrapper.status == 200){                                 
                                //updating BT_Token_Details object
                                objBTTokenDetails = B2B_BrainTreeUtils.checkBTTokenDetails(objBTTokenDetails, objAccessTokenResponseWrapper);                                   
                                lstBTTokenDetailsUpdate.add(objBTTokenDetails); 
                                Decimal totalAmount = objOrder.Updated_Order_Total__c.setScale(2);
                                //changes for HDMP-8834 starts
                                if(String.isNotEmpty(objOrder.Payment_Method_Token__c)){
                                    //call the transaction search api to check the current status of transaction before charging the customer
                                    B2B_BrainTreeTransactionResponse objBrainTreeSearchResponse = new B2B_BrainTreeTransactionResponse();
                                    String searchResponse = braintreeTransactionSearch(transactionID, objBTTokenDetails.AccessToken__c);
                                    objBrainTreeSearchResponse = B2B_BrainTreeTransactionResponse.parse(searchResponse);
                                    
                                    // if the transaction is expired again create a new transaction by the preAuth API using payment token stored on order
                                    if(objBrainTreeSearchResponse.status == 200 && objBrainTreeSearchResponse.transactionBT.status == 'authorization_expired'){
                                        String preAuthResponse = braintreeTransactionPreAuth(customerID, objAccount.Merchant_Id__c, objBTTokenDetails.AccessToken__c, String.valueOf(totalAmount), objOrder.Payment_Method_Token__c, '');
                                        B2B_BrainTreeTransactionResponse objPreAuthResponse = B2B_BrainTreeTransactionResponse.parse(preAuthResponse);
                                        if(objPreAuthResponse.status == 200) { 
                                            transactionID = objPreAuthResponse.transactionBT.id;
                                        }else {
                                            Long afterAPI = B2B_Util.fetchCurrentTime();
                                            Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                                            //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                                            String severity;
                                            String errorType;
                                            Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                                            if(errorRecords.containskey(String.valueOf(objPreAuthResponse.status))){
                                                severity= errorRecords.get(String.valueOf(objPreAuthResponse.status)).severity__c;
                                                errorType=errorRecords.get(String.valueOf(objPreAuthResponse.status)).error_Type__c;
                                            }
                                            else{
                                                severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                                                errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                                            }
                                            String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                            Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                              'B2B_BrainTreeIntegration',String.valueOf(objPreAuthResponse.status),errorType,'',
                                                                                              'braintreeOrderCapture',true, objOrder.Id,'','', durationTime,severity,
                                                                                              'Request:'+objPreAuthResponse.requestBody,'Response:'+objPreAuthResponse.responseBody);
                                            //HDMP-8617: ends
                                            lstErrors.add(errorRecord);
                                        }
                                    }else if(objBrainTreeSearchResponse.status != 200){
                                        Long afterAPI = B2B_Util.fetchCurrentTime();
                                        Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                                        //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                                        String severity;
                                        String errorType;
                                        Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                                        if(errorRecords.containskey(String.valueOf(objBrainTreeSearchResponse.status))){
                                            severity= errorRecords.get(String.valueOf(objBrainTreeSearchResponse.status)).severity__c;
                                            errorType=errorRecords.get(String.valueOf(objBrainTreeSearchResponse.status)).error_Type__c;
                                        }
                                        else{
                                            severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                                            errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                                        }
                                        
                                        String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                        Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                          'B2B_BrainTreeIntegration',String.valueOf(objBrainTreeSearchResponse.status),errorType,'',
                                                                                          'braintreeOrderCapture',true, objOrder.Id,'','', durationTime,severity,
                                                                                          'Request:'+objBrainTreeSearchResponse.requestBody,'Response:'+objBrainTreeSearchResponse.responseBody);
                                        //HDMP-8617: ends
                                        lstErrors.add(errorRecord);
                                    }
                                }
                                //changes for HDMP-8834 end

                                // make callout to braintree post auth api
                                brainTreeResponse = braintreeTransactionPostAuth(customerID, objAccount.Merchant_Id__c, transactionID, String.valueOf(totalAmount), objBTTokenDetails.AccessToken__c);
                                
                                objBrainTreeTransactionResponse = B2B_BrainTreeTransactionResponse.parse(brainTreeResponse);
                                
                                //check if the response status is 200
                                if(objBrainTreeTransactionResponse.status == 200){   
                                    system.debug('objBrainTreeTransactionResponse.transactionBT.status -----------2------------------------------------->'+objBrainTreeTransactionResponse.transactionBT.status);                                
                                    objOrder.BT_Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                    objOrder.BT_Transaction_Id__c = objBrainTreeTransactionResponse.transactionBT.id;
                                    objOrder.IsError__c = false;   
                                    objOrder.Send_Email_To_Customer__c = true;
                                    
                                    //creating the new transaction for fulfillment     
                                    BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();     
                                    objBTTransactionDetails.Name = 'Fulfilled Transaction';
                                    objBTTransactionDetails.BT_TransactionId__c = objBrainTreeTransactionResponse.transactionBT.id;                               
                                    objBTTransactionDetails.Type__c = objBrainTreeTransactionResponse.transactionBT.type;  
                                    objBTTransactionDetails.Transaction_Status__c = objBrainTreeTransactionResponse.transactionBT.status;
                                    objBTTransactionDetails.Order__c = objOrder.Id;
                                    objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                    objBTTransactionDetails.Billing_Street__c = objOrder.BT_Transaction_Details__r[0].Billing_Street__c;
                                    objBTTransactionDetails.Billing_City__c = objOrder.BT_Transaction_Details__r[0].Billing_City__c;
                                    objBTTransactionDetails.Billing_State__c = objOrder.BT_Transaction_Details__r[0].Billing_State__c;
                                    objBTTransactionDetails.Billing_PostalCode__c = objOrder.BT_Transaction_Details__r[0].Billing_PostalCode__c;
                                    objBTTransactionDetails.Credit_Card_Number__c = objOrder.BT_Transaction_Details__r[0].Credit_Card_Number__c;
                                    objBTTransactionDetails.Payment_Gateway__c = objOrder.BT_Transaction_Details__r[0].Payment_Gateway__c;
                                    objBTTransactionDetails.Payment_Method_Type__c = objOrder.BT_Transaction_Details__r[0].Payment_Method_Type__c;
                                    objBTTransactionDetails.Payment_Method_Token__c = objOrder.BT_Transaction_Details__r[0].Payment_Method_Token__c;
                                    objBTTransactionDetails.Cardholder_Name__c = objOrder.BT_Transaction_Details__r[0].Cardholder_Name__c;                                 
                                    lstBTTransactionDetails.add(objBTTransactionDetails); 
                                    
                                     //changes for HDMP-8730 :- delete the payment method from honda braintree for one time credit card
                                    if(isSavedPaymentMethod == false && String.isNotEmpty(objOrder.Payment_Method_Token__c)){
                                        
                                        // get the address id from payment method find API
                                        B2B_BrainTreeTransactionResponse objPaymentFindResponse = braintreePaymentMethodFind(objOrder.Payment_Method_Token__c);
                                        if(objPaymentFindResponse.status == 200){     
                                            //delete the one time payment method from BT
                                            braintreePaymentMethodDelete(objOrder.Payment_Method_Token__c);
                                            
                                            if(String.isNotEmpty(objOrder.BT_Customer_Legecy_Id__c)){
                                                //delete the related address to the payment method
                                                braintreeAddressDelete(objOrder.BT_Customer_Legecy_Id__c, objPaymentFindResponse.billingAddressId);  
                                            }                                          
                                        }else{
                                            Long afterAPI = B2B_Util.fetchCurrentTime();
                                            Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
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
                                            
                                            String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                            Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                              'B2B_BrainTreeIntegration',String.valueOf(objPaymentFindResponse.status),errorType,'',
                                                                                              'braintreeOrderCapture',true, objOrder.Id,'','', durationTime,severity,
                                                                                              'Request:'+objPaymentFindResponse.requestBody,'Response:'+objPaymentFindResponse.responseBody);
                                            //HDMP-8617: ends
                                            lstErrors.add(errorRecord);
                                        }                                           
                                    }
                                    
                                    //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
                                    //Create the Invoice & Invoice Item for the order
                                    Map<String , Object> mapInvoiceRecords = createInvoiceRecords(B2B_IntegrationConstants.ORDER_PLACE, objAccount, objOrder, BTTransactionId, 0, 0, new Map<String, Decimal>());
                                    lstInvoice.add((Invoice__c) mapInvoiceRecords.get(B2B_IntegrationConstants.INVOICE_OBJ));
                                    lstInvoiceItem = (List<Invoice_Item__c>) mapInvoiceRecords.get(B2B_IntegrationConstants.INVOICE_ITEMS);
                                    //Added by Faraz Ansari for HDMP-8705 - End
                                    
                                    //For HDMP-8716 : create order transaction for the order starts
                                    Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, 'Fulfilled', BTTransactionId, null);
                                    lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                                    lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                                    //for HDMP-8716 : Audit Trail ends
                                    
                                    //send emails to dealer
                                    if(objAccount.Name.contains('Honda')){
                                        dealerLocatorResponse = B2B_BrainTreeUtils.dealerLocatorService('A',objAccount.PoIId__c);
                                    }else {
                                        dealerLocatorResponse = B2B_BrainTreeUtils.dealerLocatorService('B',objAccount.PoIId__c);
                                    } 
                                    if(String.isNotEmpty(dealerLocatorResponse)){
                                        B2B_BrainTreeUtils.DealerServiceResponse objResponse = (B2B_BrainTreeUtils.DealerServiceResponse) JSON.deserialize(dealerLocatorResponse, B2B_BrainTreeUtils.DealerServiceResponse.class);
                                        if(objResponse.isError == false && String.isNotEmpty(objResponse.dealerEmails)){
                                            List<String> lstEmails = objResponse.dealerEmails.split(';');             
                                            for(String email : lstEmails){  
                                                Dealer_Email__c objDealerEmail = new Dealer_Email__c();
                                                objDealerEmail.Email__c = email;
                                                objDealerEmail.Order__c = objOrder.Id;
                                                objDealerEmail.IsShipToHome__c = (objOrder.Updated_Shipping__c != null && objOrder.Updated_Shipping__c > 0) ? true : false;
                                                lstDealerEmails.add(objDealerEmail);
                                            }
                                        }
                                    }
                                }else {
                                    objOrder.Status = 'PAYMENT ISSUE';
                                    objOrder.IsError__c = true;
                                    objOrder.Shipped_Date__c = null;
                                    objOrder.IsPaymentReproccessing__c = true;
                                    
                                    BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();   
                                    objBTTransactionDetails.Name = 'Fulfill Failure Transaction';
                                    objBTTransactionDetails.Transaction_Status__c = 'BT error code';
                                    objBTTransactionDetails.Order__c = objOrder.Id;
                                    objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                    lstBTTransactionDetails.add(objBTTransactionDetails);
                                    
                                    //For HDMP-8716 : create order transaction for the order starts
                                    Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, 'Fulfilled', BTTransactionId, null);
                                    lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                                    lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                                    //for HDMP-8716 : Audit Trail ends
                                    
                                    Long afterAPI = B2B_Util.fetchCurrentTime();
                                    Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                                    //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                                    String severity;
                                    String errorType;
                                    Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                                    if(errorRecords.containskey(String.valueOf(objBrainTreeTransactionResponse.status))){
                                        severity= errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).severity__c;
                                        errorType=errorRecords.get(String.valueOf(objBrainTreeTransactionResponse.status)).error_Type__c;
                                    }
                                    else{
                                        severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                                        errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                                    }
                                    
                                    String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                    Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                                                                      'B2B_BrainTreeIntegration',String.valueOf(objBrainTreeTransactionResponse.status),errorType,'',
                                                                                      'braintreeOrderCapture',true,objOrder.Id,'','', durationTime,severity,
                                                                                      'Request:'+objBrainTreeTransactionResponse.requestBody,'Response:'+objBrainTreeTransactionResponse.responseBody);
                                    //HDMP-8617: ends
                                    lstErrors.add(errorRecord);
                                }                                     
                            }else {                                                             
                                system.debug('error in Refresh Token callout');
                                objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                                objOrder.IsError__c = true;
                                
                                BT_Transaction_Details__c objBTTransactionDetails = new BT_Transaction_Details__c();   
                                objBTTransactionDetails.Name = 'Fulfill Failure Transaction';
                                objBTTransactionDetails.Transaction_Status__c = 'BT error code';
                                objBTTransactionDetails.Order__c = objOrder.Id;
                                objBTTransactionDetails.Customer__c = objOrder.BT_Transaction_Details__r[0].Customer__c;
                                lstBTTransactionDetails.add(objBTTransactionDetails);
                                
                                //For HDMP-8716 : create order transaction for the order starts
                                Map<String , Object> mapOrderTranRecords = createOrderTransactionRecord(objOrder, 'Fulfilled', BTTransactionId, null);
                                lstOrderTrans.add((Order_Transaction__c) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_OBJ));
                                lstOrderTranItems = (List<Order_Transaction_Item__c>) mapOrderTranRecords.get(B2B_IntegrationConstants.ORDER_TRAN_ITEMS);
                                //for HDMP-8716 : Audit Trail ends

                                Long afterAPI = B2B_Util.fetchCurrentTime();
                                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
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

                                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                                Error__c errorRecord = B2B_Util.createErrorRecord(false,'','', objAccount.Id, personAccountId,objOrder.cart__c,
                                'B2B_BrainTreeIntegration',String.valueOf(objAccessTokenResponseWrapper.status),errorType,'',
                                'braintreeOrderCapture',true,objOrder.Id,'','', durationTime,severity,
                                'Request:'+objAccessTokenResponseWrapper.requestBody,'Response:'+objAccessTokenResponseWrapper.responseBody);
                                //HDMP-8617: ends
                                lstErrors.add(errorRecord);
                            }             
                        }                   
                    }else {                     
                        //ToDo Throw a message on page to show the Order is missing Customer ID or BT Transaction record
                        objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                        objOrder.IsError__c = true;
                        
                        Error__c objError = B2B_BrainTreeUtils.createErrorRecord('Missing Data On Record ', objOrder.Id, 'the Order is missing Customer ID or BT Transaction Id');
                        lstErrors.add(objError);
                    }                 
                }else {
                    objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                    objOrder.IsError__c = true;
                    
                    Error__c objError = B2B_BrainTreeUtils.createErrorRecord('BT Token Detail Missing ', objOrder.Id, 'the related account is missing BT_Token_Details__c record');
                    lstErrors.add(objError);
                } 
            }catch(Exception ex){
                objOrder.Status = mapOldOrderStatus.get(objOrder.Id);
                objOrder.IsError__c = true;               
                
                Error__c objError = B2B_BrainTreeUtils.createErrorRecord('Exception Occured ', objOrder.Id, ex.getMessage());
                objError.Line_Number__c = ex.getLineNumber();
                objError.StackTrace__c = ex.getStackTraceString();
                objError.Error_Type__c = ex.getTypeName();
                lstErrors.add(objError);                
            }

             //Saravanan , Ashwin LTIM Added for bug 18896 , [REMAN-140]
            
              if(objOrder.status == 'CUSTOMER CANCELED' || objOrder.status == 'DEALER CANCELED' ){
                objOrder.Current_Quantity__c = 0;
                objOrder.Total_Current_Product_Amount__c = 0;
                objOrder.Total_Current_Product_Tax__c = 0;
                objOrder.Updated_Total_Tax__c= 0;
                objOrder.Updated_Order_Total__c = 0;
                objOrder.Total_Core_Charge_Current_Amount__c = 0;
                objOrder.Total_Core_Charge_Current_Tax__c = 0;
                objOrder.Total_Core_Charge_Current_Quantity__c = 0;
             }
            // Saravanan , Ashwin LTIM Added for bug 18896 , [REMAN-140]

            lstOrderUpdate.add(objOrder);            
        }
        
        //update BT_Token_Details__c data
        if(!lstBTTokenDetailsUpdate.isEmpty())
            update lstBTTokenDetailsUpdate;
        
        // update Order    
        if(!lstOrderUpdate.isEmpty())
            update lstOrderUpdate;       
        
        // insert dealer Emails 
        if(!lstDealerEmails.isEmpty())
            insert lstDealerEmails;
            
        if(lstBTPaymentMethods.isEmpty())
            delete lstBTPaymentMethods;
        
        //for HDMP-8716 : Audit Trail starts
        if(!lstOrderTrans.isEmpty()){
            insert lstOrderTrans;

            // Saravanan LTIM Added for 19481
            if(methodName == 'partial return' && !lstInvoice.isEmpty()){

                for(Invoice__c objInvoice : lstInvoice){
                    objInvoice.Total_Core_Charge_Quantity__c  = lstOrderTrans[0].Total_Post_Adjustment_Core_Charge_Qty__c;
                    objInvoice.Total_Core_Charge_Amount__c  = lstOrderTrans[0].Total_Post_Adjustment_Core_Charge_Amount__c;
                    objInvoice.Total_Core_Charge_Tax__c  = lstOrderTrans[0].Total_Post_Adjustment_Core_Charge_Tax__c;
                }
            }

            if(!lstOrderTranItems.isEmpty()){
                for(Order_Transaction_Item__c itemObj : lstOrderTranItems){
                    itemObj.Order_Transaction__c = lstOrderTrans[0].Id;
                    // Saravanan LTIM Added for Sprint 2 Data Rules Logic Dealer
                    itemObj.AK_Order_Transaction_Item__c =  lstOrderTrans[0].Id +'~' + itemObj.Order_Item__c +'~'+itemObj.Product_Type__c ; //HDMP-19440
                    // Saravanan LTIM Added for Sprint 2 Data Rules Logic Dealer
                }
                insert lstOrderTranItems;
            }
            
            //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
            //Filling invoice transaction field after order return creation
            for(Invoice__c invoiceObj : lstInvoice){
                invoiceObj.Order_Transaction__c = lstOrderTrans[0].Id;
            }
            //Added by Faraz Ansari for HDMP-8705 - End
        }
        
        // BT_transaction_Details__c 
        if(!lstBTTransactionDetails.isEmpty()){
            if(!lstOrderTrans.isEmpty()){
                lstBTTransactionDetails[0].Order_Transaction__c = lstOrderTrans[0].Id;
            }             
            insert lstBTTransactionDetails;
        }
            
        
        // update Error object        
        if(!lstErrors.isEmpty()){            
            for(Error__c err: lstErrors){
                err.Order_Transaction__c = (!lstOrderTrans.isEmpty() ? lstOrderTrans[0].Id : null);
            }
            insert lstErrors;
        }
        
        if(!deletePaymentMethods.isEmpty()){
            DELETE deletePaymentMethods;
        }
        //for HDMP-8716 : Audit Trail ends
        
        //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
        //insert invoice & invoice item records for order  
        if(!lstInvoice.isEmpty()){
            insert lstInvoice;
            Invoice__c invoiceObj = [SELECT Id, Name FROM Invoice__c WHERE Id =: lstInvoice[0].Id];
            lstInvoice[0].Invoice_Number__c = invoiceObj.Name;
            lstInvoice[0].BT_Transaction_Details__c = !lstBTTransactionDetails.isEmpty() ? lstBTTransactionDetails[0].Id : null;
            update lstInvoice;
            if(!lstInvoiceItem.isEmpty()){
                for(Invoice_Item__c itemObj : lstInvoiceItem){
                    itemObj.Invoice__c = lstInvoice[0].Id;
                }
                insert lstInvoiceItem;
            }
        }
        //Added by Faraz Ansari for HDMP-8705 - End
    }  
   /* ---------- Future Method ends -----------*/
    
    public static Map<String, Object> createOrderTransactionRecord(Order objOrder,String auditType, String transactionSfId, Map<String, Decimal> pricesMap){
        Map<String , Object> mapOrderTranRecords = new Map<String, Object>();
        Order_Transaction__c objOrderTransaction = new Order_Transaction__c();
        objOrderTransaction.Order__c = objOrder.Id;
        objOrderTransaction.Order_Transaction_Type__c = auditType;
        objOrderTransaction.Order_Transaction_Status__c = objOrder.IsError__c == false ? 'Success' : 'Failure';
        objOrderTransaction.Dealer_To_Customer_Note__c = objOrder.Customer_Notes__c;
        objOrderTransaction.Is_Adjustment__c = false;


        // Saravanan starts LTIM SPRINT -2 Data Rules Logic Dealer Order Fulfillment-Payment Issue

        objOrder.Total_Core_Charge_Current_Quantity__c = objOrder.Total_Core_Charge_Current_Quantity__c!= null ? objOrder.Total_Core_Charge_Current_Quantity__c : 0;
        objOrder.Total_Core_Charge_Current_Amount__c  = objOrder.Total_Core_Charge_Current_Amount__c!= null ? objOrder.Total_Core_Charge_Current_Amount__c : 0;
        objOrder.Total_Core_Charge_Current_Tax__c = objOrder.Total_Core_Charge_Current_Tax__c!= null ? objOrder.Total_Core_Charge_Current_Tax__c : 0;
        objOrder.Total_Core_Charge_Return_Quantity__c = objOrder.Total_Core_Charge_Return_Quantity__c!= null ? objOrder.Total_Core_Charge_Return_Quantity__c : 0;
        objOrder.Total_Core_Charge_Return_Amount__c = objOrder.Total_Core_Charge_Return_Amount__c!= null ? objOrder.Total_Core_Charge_Return_Amount__c : 0;
        objOrder.Total_Core_Charge_Return_Tax__c = objOrder.Total_Core_Charge_Return_Tax__c!= null ? objOrder.Total_Core_Charge_Return_Tax__c : 0;

        objOrderTransaction.Total_Post_Adjustment_Core_Charge_Qty__c = objOrder.Total_Core_Charge_Current_Quantity__c;
        objOrderTransaction.Total_Post_Adjustment_Core_Charge_Amount__c = objOrder.Total_Core_Charge_Current_Amount__c;
        objOrderTransaction.Total_Post_Adjustment_Core_Charge_Tax__c = objOrder.Total_Core_Charge_Current_Tax__c;

        //// Saravanan Ends LTIM SPRINT -2 Data Rules Logic Dealer Order Fulfillment-Payment Issue

                        
        if(auditType == 'Returned'){
            objOrderTransaction.Total_Restocking_Fee__c = objOrder.Restocking_Fees__c;
            objOrderTransaction.Total_Restocking_Fee_Tax__c = pricesMap.containsKey('restockingTax') ? pricesMap.get('restockingTax') : 0;
            objOrderTransaction.Total_Post_Adjustment_Shiping_Charge__c = objOrder.Shipping_Refund__c;
            objOrderTransaction.Total_Post_adjustment_Installation_Tax__c = pricesMap.containsKey('installTax') ? pricesMap.get('installTax') : 0;
            objOrderTransaction.Total_Post_adjustment_Shipping_Tax__c = pricesMap.containsKey('shippingTax') ? pricesMap.get('shippingTax') : 0;
            objOrderTransaction.Post_Adjustment_Total_Amount__c = pricesMap.containsKey('returnTotal') ? pricesMap.get('returnTotal') : 0;
            objOrderTransaction.Post_Adjustment_Total_Tax__c = pricesMap.containsKey('returnTax') ? pricesMap.get('returnTax') : 0;

            // Saravanan LTIM Added for Springt 3 Data Rules REMAN-254
            objOrderTransaction.Total_Post_Adjustment_Core_Charge_Qty__c = objOrder.Total_Core_Charge_Return_Quantity__c ; // Saravanan Variance objOrder.Total_Core_Charge_Current_Quantity__c ; // HELMS handling objOrder.Total_Core_Charge_Return_Quantity__c;
            objOrderTransaction.Total_Post_Adjustment_Core_Charge_Amount__c = objOrder.Total_Core_Charge_Return_Amount__c ; // Saravanan Variance objOrder.Total_Core_Charge_Current_Amount__c ; // objOrder.Total_Core_Charge_Return_Amount__c
            objOrderTransaction.Total_Post_Adjustment_Core_Charge_Tax__c = objOrder.Total_Core_Charge_Return_Tax__c; // Saravanan Variance objOrder.Total_Core_Charge_Current_Tax__c - objOrder.Total_Core_Charge_Return_Tax__c;
            // Saravanan LTIM EDED for Springt 3 Data Rules REMAN-254
            
        }else if(auditType == 'Fulfilled'){
            objOrderTransaction.Total_Post_Adjustment_Shiping_Charge__c = objOrder.Updated_Shipping__c;            
            objOrderTransaction.Total_Post_adjustment_Shipping_Tax__c = objOrder.Current_Shipping_Tax__c;
            objOrderTransaction.Post_Adjustment_Total_Amount__c = objOrder.Updated_Order_Total__c; //REMAN-116
            objOrderTransaction.Post_Adjustment_Total_Tax__c = objOrder.Updated_Total_Tax__c; //REMAN-116



            // Saravanan starts LTIM SPRINT -2 Data Rules Logic Dealer Order Fulfillment-Payment Issue REMAN-111 , REMAN-116
            objOrderTransaction.Total_Post_Adjustment_Core_Charge_Qty__c = objOrder.Total_Core_Charge_Current_Quantity__c;
            objOrderTransaction.Total_Post_Adjustment_Core_Charge_Amount__c = objOrder.Total_Core_Charge_Current_Amount__c;
            objOrderTransaction.Total_Post_Adjustment_Core_Charge_Tax__c = objOrder.Total_Core_Charge_Current_Tax__c;

            //// Saravanan Ends LTIM SPRINT -2 Data Rules Logic Dealer Order Fulfillment-Payment Issue REMAN-111 , REMAN-116

        }
       
        if(auditType == 'Cancelled'){
            objOrderTransaction.Is_Adjustment__c = true;
            objOrderTransaction.Total_Pre_Adjustment_Shiping_Charge__c = objOrder.Updated_Shipping__c;            
            objOrderTransaction.Total_Pre_Adjustment_Shipping_Tax__c = objOrder.Current_Shipping_Tax__c;
            objOrderTransaction.Pre_Adjustment_Total_Amount__c = objOrder.Updated_Order_Total__c;


             // Saravanan starts LTIM SPRINT -2 Data Rules Logic Dealer Order Modification - Cancelled
             objOrderTransaction.Total_Post_Adjustment_Core_Charge_Qty__c = 0;
             objOrderTransaction.Total_Post_Adjustment_Core_Charge_Amount__c = 0;
             objOrderTransaction.Total_Post_Adjustment_Core_Charge_Tax__c = 0;

             objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Qty__c = objOrder.Total_Core_Charge_Current_Quantity__c;
             objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Amount__c = objOrder.Total_Core_Charge_Current_Amount__c;
             objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Tax__c = objOrder.Total_Core_Charge_Current_Tax__c;

             //// Saravanan Ends LTIM SPRINT -2 Data Rules Logic Dealer Order Modification - Cancelled


        }
        objOrderTransaction.Adjustment_Date_Time__c = System.now();
        mapOrderTranRecords.put(B2B_IntegrationConstants.ORDER_TRAN_OBJ,(Object)objOrderTransaction);
        
        List<Order_Transaction_Item__c> lstOrderTranItems = new List<Order_Transaction_Item__c>();
        for(OrderItem objOrderItem : objOrder.OrderItems){
            Order_Transaction_Item__c objOrderTranItem = new Order_Transaction_Item__c();
            objOrderTranItem.Order_Item__c = objOrderItem.Id;

            // Saravanan LTIM Starts for Sprint 2 Data Rules Logic Dealer
             mapOrderIdtoOrderItem.put(objOrderItem.Id,objOrderItem);
             objOrderTranItem.Product_Type__c = objOrderItem.Product_Type__c;

            // Saravanan LTIM Ends for Sprint 2 Data Rules Logic Dealer

            if(auditType == 'Returned' && (objOrderItem.Delta_Quantity__c > 0 || objOrderItem.Delta_Installation_Price__c > 0)){
                objOrderTranItem.Post_Adjustment_Quantity__c = objOrderItem.Delta_Quantity__c;
                objOrderTranItem.Post_Adjustment_Extended_Price__c = objOrderItem.Delta_Quantity__c * objOrderItem.ListPrice;
                objOrderTranItem.Total_Post_Adjustment_Product_Tax__c = pricesMap.containsKey(objOrderItem.Id) ? pricesMap.get(objOrderItem.Id) : 0;
                objOrderTranItem.TotalPost_Adjustment_Installation_Charge__c = objOrderItem.Delta_Installation_Price__c;
            }else if(auditType == 'Fulfilled'){
                objOrderTranItem.Post_Adjustment_Quantity__c = objOrderItem.Updated_Quantity__c;
                objOrderTranItem.Post_Adjustment_Extended_Price__c = objOrderItem.Updated_Quantity__c * objOrderItem.ListPrice;
                objOrderTranItem.Total_Post_Adjustment_Product_Tax__c = objOrderItem.Total_Current_Product_Tax__c;                
            }           
            if(auditType == 'Cancelled'){
                objOrderTranItem.Pre_Adjustment_Quantity__c = objOrderItem.Updated_Quantity__c; 
                objOrderTranItem.Pre_Adjustment_Extended_Price__c = objOrderTranItem.Pre_Adjustment_Quantity__c * objOrderItem.ListPrice;
                objOrderTranItem.Total_Pre_Adjustment_Product_Tax__c = objOrderItem.Total_Current_Product_Tax__c;                               
            }
            objOrderTranItem.Adjustment_Date_Time__c = System.now();
            if(auditType == 'Returned' && (objOrderItem.Delta_Quantity__c > 0 || objOrderItem.Delta_Installation_Price__c > 0)){
                lstOrderTranItems.add(objOrderTranItem);
            }else if(auditType != 'Returned'){
                lstOrderTranItems.add(objOrderTranItem);
            }

            // Saravanan LTIM Added for HDMP-19493 Variance
            if(auditType == 'Returned' && objOrderTransaction.Order_Transaction_Status__c == 'Failure' && !(objOrderItem.Delta_Quantity__c > 0 || objOrderItem.Delta_Installation_Price__c > 0)){
                lstOrderTranItems.add(objOrderTranItem);
            }

            // Saravanan LTIM Ended for HDMP-19493 Variance
            
        }
        mapOrderTranRecords.put(B2B_IntegrationConstants.ORDER_TRAN_ITEMS,(Object)lstOrderTranItems);
        return mapOrderTranRecords;
    }
    
    //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
    //Create the Invoice & Invoice Item for the order
    public static Map<String , Object> createInvoiceRecords(String invoiceType, Account objAccount, Order objOrder, String BTTransactionId, Decimal totalRefundAmount, Decimal refundTax, Map<String, Decimal> pricesMap){
        Map<String , Object> mapInvoiceRecords = new Map<String, Object>();
        
        Invoice__c invoiceObj = new Invoice__c();
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
        invoiceObj.ShippingStreet__c = objOrder.ShippingStreet;
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
        //invoiceObj.BT_Transaction_Details__c = BTTransactionId;
        invoiceObj.Order__c = objOrder.Id;
        invoiceObj.Order_Reference_Number__c = String.isNotEmpty(objOrder.OrderReferenceNumber) ? objOrder.OrderReferenceNumber : objOrder.OrderNumber;
        invoiceObj.Payment_Method_Type__c = objOrder.Payment_Type__c != null ? objOrder.Payment_Type__c : 'PayPal';
        invoiceObj.Delivery_Type__c = objOrder.Delivery_Types__c;
        if(invoiceType == B2B_IntegrationConstants.ORDER_PLACE){
            invoiceObj.Total_Pre_Tax_Invoice_Amount__c = objOrder.Updated_Order_Total__c - objOrder.Updated_Total_Tax__c;
            invoiceObj.Total_Shipping_Amount__c = objOrder.Updated_Shipping__c;
            invoiceObj.Total_Shipping_Tax__c = objOrder.Current_Shipping_Tax__c;
            invoiceObj.Total_Invoice_Price__c = objOrder.Updated_Order_Total__c; 
            invoiceObj.Total_Invoice_Tax__c = objOrder.Updated_Total_Tax__c;
            invoiceObj.Invoice_Type__c = B2B_IntegrationConstants.ORDER_INVOICE;
        }else if(invoiceType == B2B_IntegrationConstants.ORDER_RETURN){
            invoiceObj.Total_Pre_Tax_Invoice_Amount__c = pricesMap.containsKey('returnTotal') && pricesMap.containsKey('returnTax') ? ((pricesMap.get('returnTotal') + objOrder.Restocking_Fees__c) - pricesMap.get('returnTax')) : 0;
            invoiceObj.Total_Restocking_Fee__c = objOrder.Restocking_Fees__c;
            invoiceObj.Total_Restocking_Fee_Tax__c = pricesMap.containsKey('restockingTax') ? pricesMap.get('restockingTax') : 0;
            invoiceObj.Invoice_Type__c = B2B_IntegrationConstants.ORDER_RETURN;
            invoiceObj.Total_Shipping_Amount__c = objOrder.Shipping_Refund__c;
            invoiceObj.Total_Shipping_Tax__c = pricesMap.containsKey('shippingTax') ? pricesMap.get('shippingTax') : 0;
            invoiceObj.Total_Invoice_Price__c = totalRefundAmount; 
            invoiceObj.Total_Invoice_Tax__c = refundTax;
            invoiceObj.Total_Installation_Tax__c = pricesMap.containsKey('installTax') ? pricesMap.get('installTax') : 0;
        }

         // Saravanan LTIM Added for Sprint 2 - Data Rules Invoice Payment Issue REMAN-181

         invoiceObj.Total_Core_Charge_Amount__c  = objOrder.Total_Core_Charge_Current_Amount__c;
         invoiceObj.Total_Core_Charge_Quantity__c  = objOrder.Total_Core_Charge_Current_Quantity__c;
         invoiceObj.Total_Core_Charge_Tax__c  = objOrder.Total_Core_Charge_Current_Tax__c;
 
         // Saravanan LTIM Added for Sprint 2 - Data Rules Invoice Payment Issue REMAN-181


        mapInvoiceRecords.put(B2B_IntegrationConstants.INVOICE_OBJ, invoiceObj);
        List<Invoice_Item__c> lstInvoiceItem = new List<Invoice_Item__c>();
        for(OrderItem objOrderItem : objOrder.OrderItems){
            Invoice_Item__c invItemObj = new Invoice_Item__c();
            invItemObj.Unit_Price__c = objOrderItem.ListPrice;
            invItemObj.Accessory_Op_Code__c = objOrderItem.Op_Code__c;
            invItemObj.Product_SKU__c = objOrderItem.Product_SKU__c;
            invItemObj.Product_Name__c = objOrderItem.Cart_Item_Product_Name__c ;
            if(invoiceType == B2B_IntegrationConstants.ORDER_PLACE){          
                invItemObj.Extended_Price__c = objOrderItem.ListPrice * objOrderItem.Updated_Quantity__c;//objOrderItem.TotalPrice;
                invItemObj.Item_Quantity__c = objOrderItem.Updated_Quantity__c;
                invItemObj.Total_Product_Tax__c = objOrderItem.Total_Current_Product_Tax__c;
            }else if(invoiceType == B2B_IntegrationConstants.ORDER_RETURN){
                invItemObj.Item_Installation_Price__c = objOrderItem.Delta_Installation_Price__c;
                invItemObj.Total_Installation_Charge__c = objOrderItem.Delta_Installation_Price__c;
                invItemObj.Extended_Price__c = objOrderItem.ListPrice * objOrderItem.Delta_Quantity__c;
                invItemObj.Item_Quantity__c = objOrderItem.Delta_Quantity__c;
                invItemObj.Total_Product_Tax__c = pricesMap.containsKey(objOrderItem.Id) ? pricesMap.get(objOrderItem.Id) : 0;
            }

             // Saravanan LTIM Added for Sprint 2 - Data Rules Invoice Items Payment Issues
             if(objOrderItem.Product2.Core_Charge_Unit_Price__c > 0 || objOrderItem.Product_Type__c == 'Core Chare'){
                //invItemObj.Product_Type__c = objOrderItem.Product_Type__c;
                invItemObj.AK_Invoice_Item__c = '@INVOICEID'+'~'+objOrderItem.Id+'~'+objOrderItem.Product_Type__c;
                
             }
             invItemObj.Product_Type__c = objOrderItem.Product_Type__c; // Bug HDMP-19394
             // Saravanan LTIM Ended for Sprint 2 - Data Rules Invoice Items Payment Issues

            if(invoiceType == B2B_IntegrationConstants.ORDER_RETURN && (objOrderItem.Delta_Quantity__c > 0 || objOrderItem.Delta_Installation_Price__c > 0)){
                lstInvoiceItem.add(invItemObj);
            }else if(invoiceType == B2B_IntegrationConstants.ORDER_PLACE){
                lstInvoiceItem.add(invItemObj);
            }
        }
        mapInvoiceRecords.put(B2B_IntegrationConstants.INVOICE_ITEMS, (Object)lstInvoiceItem);
        return mapInvoiceRecords;
    }
    //Added by Faraz Ansari for HDMP-8705 - End
}
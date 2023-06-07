/**********************************************************************
Name: B2B_BrainTreeUtils
Business Unit:HDM
Date : 16/06/2021
Developer: Rajrishi Kaushik
Description : This is a Utility class for BrainTree Integration,(Test ClassName- B2B_BrainTreeUtilsTest,B2B_BrainTreeUtilsTestMock(Mock Class),B2B_TestDataFactory)
MODIFICATIONS – 24/05/2022 | Palak Gupta| (Error handling changes- JIRA- 8617)
MODIFICATIONS – 09/06/2022 | Mathioli | (Added header and removal of commented code)
*************************************************************/

public Without Sharing class B2B_BrainTreeUtils {
  
    public static Integer retryCount = Integer.valueOf(Label.BT_RetryCount);
    public static Integer retryDealerOnboarding = Integer.valueOf(Label.BT_RetryCount);
    
    //method to create Error record
    public static Error__c createErrorRecord(String name, String orderId , String errorMessage){
        Error__c objError = new Error__c();
        objError.Name = name; 
        objError.Order__c = orderId;
        objError.ClassName__c = 'B2B_BrainTreeIntegration';
        objError.Error_Message__c = errorMessage;
        objError.MethodName__c = 'braintreeOrderCancellation';
        objError.RecordId__c = orderId;
        return objError;
    } 
    //this method will delete the vault payment method from honda's braintree account
    public static Boolean deleteBTVaultPaymentMethod(String paymentId){
        Try{        
            //create a base request
            HttpRequest req = B2B_CreditCardController.createBaseRequest('POST');
            Map<String, Object> graphQl = new Map<String, Object>();
            //Create base Query and Variables structure
            String mutation = 'mutation DeletePaymentMethodFromVaultPayload($input: DeletePaymentMethodFromVaultInput!){';
            mutation += 'deletePaymentMethodFromVault(input: $input) { clientMutationId  }}';
            String input = '{"input": { "paymentMethodId": "'+ paymentId + '" }}';
            graphQl.put('query', (object) mutation);
            graphQl.put('variables',new Map<String, Object>());
            Map<String, String> paymentMethodMap = new Map<String, String>{'paymentMethodId' => paymentId};
            ((Map<String, Object>)graphQl.get('variables')).put('input', paymentMethodMap);
            req.setBody(JSON.serialize(graphQl));
            Http http = new Http();
            HttpResponse res = http.send(req);
            Map<String, Object> resData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());               
            if(resData != null && resData.containsKey('data')) {
                Map<String, Object> initialData = (Map<String, Object>)resData.get('data');           
                if(initialData != null && initialData.containsKey('deletePaymentMethodFromVault')) {
                    return true;
                }
            }       
            return false;
        }Catch(Exception ex){
            return false;
        }
    }

    //method to call vertax return tax 
    public static B2B_BTVertexTaxCalculationIntegration.ResponseDataWrapper callVertaxReturnTax(Account objAccount, Order objOrder){
        Map<String,String> dealerAddressMap = new Map<String,String>();
        dealerAddressMap.put('streetAddress', objAccount.BillingStreet);
        dealerAddressMap.put('city', objAccount.BillingCity);
        dealerAddressMap.put('mainDivision', objAccount.BillingState);
        dealerAddressMap.put('postalCode', objAccount.BillingPostalCode);
        Map<String,String> customerAddressMap = new Map<String,String>();
        customerAddressMap.put('streetAddress', objOrder.cart__r.CustomerStreet__c);
        customerAddressMap.put('city',objOrder.cart__r.CustomerCity__c);
        customerAddressMap.put('mainDivision', objOrder.cart__r.Customer_State__c);
        customerAddressMap.put('postalCode', objOrder.cart__r.CustomerPostalCode__c);                                
        //make callout to return vertax 
        B2B_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper = B2B_BTVertexTaxCalculationIntegration.calculateTax(objOrder.cart__c, dealerAddressMap, customerAddressMap, objAccount.PoIId__c, String.valueOf(objOrder.Shipping_Refund__c),String.valueOf(objOrder.Install_Refund__c), 'return');
        return objResponseDataWrapper;
        
    }
    
    //method to call vertax return tax 
    public static B2B_BTVertexTaxCalculationIntegration.ResponseDataWrapper callVertaxLineItemReturnTax(Account objAccount, Order objOrder, String shippingCharge, String installCharge){
        Map<String,String> dealerAddressMap = new Map<String,String>();
        dealerAddressMap.put('streetAddress', objAccount.BillingStreet);
        dealerAddressMap.put('city', objAccount.BillingCity);
        dealerAddressMap.put('mainDivision', objAccount.BillingState);
        dealerAddressMap.put('postalCode', objAccount.BillingPostalCode);
        
        Map<String,String> customerAddressMap = new Map<String,String>();
        customerAddressMap.put('streetAddress', objOrder.cart__r.CustomerStreet__c);
        customerAddressMap.put('city',objOrder.cart__r.CustomerCity__c);
        customerAddressMap.put('mainDivision', objOrder.cart__r.Customer_State__c);
        customerAddressMap.put('postalCode', objOrder.cart__r.CustomerPostalCode__c); 
        
        //get restocking fees
        String restockingCharge = objOrder.Restocking_Fees__c != 0 ? String.valueOf(objOrder.Restocking_Fees__c) : null;
        //make callout to return vertax 
        B2B_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper = B2B_BTVertexTaxCalculationIntegration.calculateLineItemReturnTax(objOrder.cart__c, dealerAddressMap, customerAddressMap, objAccount.PoIId__c, shippingCharge, installCharge, restockingCharge);
        return objResponseDataWrapper;
        
    }
    
    
    //method to create BT_Token_Details__c record by Refresh/Access token api response
    public static BT_Token_Details__c checkBTTokenDetails(BT_Token_Details__c objBTTokenDetail, B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper){       
        Datetime accessTokenExpDate = datetime.valueOf(objAccessTokenResponseWrapper.credentials.expiresAt.replace('T', ' '));
        //calculate expiry date for refresh token               
        Date myDate = System.today().addDays(179);
        Time myTime = Time.newInstance(23, 0, 0, 0);                
        DateTime refreshTokenExpDate = DateTime.newInstanceGMT(myDate, myTime);                         
        objBTTokenDetail.AccessToken__c = objAccessTokenResponseWrapper.credentials.accessToken;
        objBTTokenDetail.RefreshToken__c = objAccessTokenResponseWrapper.credentials.refreshToken;
        objBTTokenDetail.AccessTokenExpiresAt__c = System.now().addHours(23); 
        objBTTokenDetail.RefreshTokenExpiresAT__c = refreshTokenExpDate;
        return objBTTokenDetail;
    }    
    
     /*
    Created By : Rajrishi Kaushik
    Date : 02/07/2021
    Description : This method is used to update the BT_Details object by calling the getAccessToken Api by the help of account object.
    */ 
    @auraEnabled
    public static String updateBTDetailsByAccount(Account objAccount, String code){ 
        String status = '';
        Try{   
            Long beforeAPI = B2B_Util.fetchCurrentTime(); // HDMP-8617- This will provide initial response time           
            //callout to braintree SDK
            String response = B2B_BrainTreeIntegration.getAccessToken(objAccount.Merchant_Id__c, code); 
            List<BT_Token_Details__c> lstBTTokenDetailsUpsert = new List<BT_Token_Details__c>();
            B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();           
            objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(response, B2B_AccessTokenResponseWrapper.class);          
            if(objAccessTokenResponseWrapper.status == B2B_IntegrationConstants.STATUSCODE){
                List<BT_Token_Details__c> lstBTTokenDetails = [SELECT Id, Name, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c, Account__c 
                                                               FROM BT_Token_Details__c
                                                               WHERE Account__c =: objAccount.Id 
                                                               LIMIT 1];
                
                
                Datetime accessTokenExpDate = datetime.valueOf(objAccessTokenResponseWrapper.credentials.expiresAt.replace('T', ' '));
                //calculate expiry date for refresh token               
                Date myDate = System.today().addDays(179);
                Time myTime = Time.newInstance(23, 0, 0, 0);                
                DateTime refreshTokenExpDate = DateTime.newInstanceGMT(myDate, myTime);                  
                //check if BT_Details record is exist 
                if(!lstBTTokenDetails.isEmpty()){
                    BT_Token_Details__c objBTTokenDetail = lstBTTokenDetails[0];
                    objBTTokenDetail.AccessToken__c = objAccessTokenResponseWrapper.credentials.accessToken;
                    objBTTokenDetail.RefreshToken__c = objAccessTokenResponseWrapper.credentials.refreshToken;
                    objBTTokenDetail.AccessTokenExpiresAt__c = System.now().addHours(23);
                    objBTTokenDetail.RefreshTokenExpiresAT__c = refreshTokenExpDate;
                    objBTTokenDetail.AK_Payment_Gateway_Token_Ext__c = objAccount.Id + 'Braintree';
                    lstBTTokenDetailsUpsert.add(objBTTokenDetail);
                }else {
                    BT_Token_Details__c objNewBTTokenDetail = new BT_Token_Details__c();
                    objNewBTTokenDetail.AccessToken__c = objAccessTokenResponseWrapper.credentials.accessToken;
                    objNewBTTokenDetail.RefreshToken__c = objAccessTokenResponseWrapper.credentials.refreshToken;
                    objNewBTTokenDetail.AccessTokenExpiresAt__c = System.now().addHours(23); 
                    objNewBTTokenDetail.RefreshTokenExpiresAT__c = refreshTokenExpDate;
                    objNewBTTokenDetail.Account__c = objAccount.Id;
                    objNewBTTokenDetail.AK_Payment_Gateway_Token_Ext__c = objAccount.Id + 'Braintree';
                    lstBTTokenDetailsUpsert.add(objNewBTTokenDetail);
                }
                //Calling dealer onboarding API
                DealerServiceResponse objDealerResponse = UpdateDealerOnBoardingEnrollment(objAccount.PoIId__c);
                if(!objDealerResponse.isError){
                    //update BT_Details
                    if(!lstBTTokenDetailsUpsert.isEmpty()){
                        upsert lstBTTokenDetailsUpsert;
                        objAccount.isActive__c = true; 
                        objAccount.OnBoarding_Error__c = null;
                        status = 'Updated';                                                         
                    }
                }else{
                    status = 'Failed';
                    objAccount.IsActive__c = false;
                    objAccount.OnBoarding_Error__c =  objDealerResponse.message;
                
					
                }
            }else {
                status = 'Failed';
                if(retryCount < 2){
                    retryCount++;
                    updateBTDetailsByAccount(objAccount, code);                   
                }else {           
                    objAccount.IsActive__c = false;
                    objAccount.OnBoarding_Error__c =  objAccessTokenResponseWrapper.errorMessage;
                    //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team 
                    Long afterAPI = B2B_Util.fetchCurrentTime();
                    Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);// to calculate duration time between before API and after API
                    String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
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
                    Error__c errorRecord = B2B_Util.createErrorRecord(true,'','', objAccount.Id, personAccountId,'',
                                                                      'B2B_BrainTreeUtils', String.valueOf(objAccessTokenResponseWrapper.status), errorType,'',
                                                                      'updateBTDetailsByAccount',true,'','','', durationTime, 
                                                                      severity, objAccessTokenResponseWrapper.requestBody, objAccessTokenResponseWrapper.responseBody);
                    //HDMP-8617- End of changes
                }
            } 
        }catch(Exception ex){
            status = 'Failed';
            if(retryCount < 2){
                retryCount++;
                updateBTDetailsByAccount(objAccount, code);                
            }else {
                objAccount.IsActive__c = false;
                objAccount.OnBoarding_Error__c =  ex.getMessage();                                
            }
        }
        
        //update account object
        update objAccount;
        return status;     
    }     
    
    /*
    Created By : Rajrishi Kaushik
    Date : 02/07/2021
    Description : This method is used to update the account record by Merchant Id.
	Update By: Palak Gupta: 24/05/2022(Error handling changes- JIRA- 8617) 
    */ 
    @auraEnabled
    public static Account updateAccountByMerchant(String merchantId, String code, String state){               
        String tempMerchantId = String.valueOf(merchantId);
        List<Account> lstAccounts = [SELECT Id, Merchant_Id__c, Code__c, State__c, isActive__c ,OnBoarding_Error__c, PoIId__c,
                                     Is_Dreamshop__c  /*Dreamshop_Setup__c, Vehicle_Reserve_Setup__c*/
                                     FROM Account 
                                     WHERE Merchant_Id__c =: tempMerchantId 
                                     LIMIT 1];   
        if(!lstAccounts.isEmpty()){               
            lstAccounts[0].code__c = code;
            lstAccounts[0].state__c = state; 
            update lstAccounts[0];            
            return lstAccounts[0];
        }        
        return null;
    }
    //this method is used to call dealer locator api after the customer is charged from dealer console. 
    public static string dealerLocatorService(String poiType, String poiId){     
        DealerServiceResponse objDealerResponse = New DealerServiceResponse();
        try{ 
            Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String guId = B2B_Util.createGui();
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('hondaHeaderType.messageId',guId);           
            request.setHeader('accept','application/json');
            request.setMethod('GET');
            String endPointUrl = 'callout:B2B_Dealer_Credential';
            endPointUrl += Label.B2B_Dealer_Locator_URL;
            endPointUrl += '&POIId='+poiId+'&Country=US&POIType='+poiType+'&SearchRadius=20&NumberOfPOIs=1&ShowAllAttributes=False&ShowAllProperties=False&ShowAllDepartments=False&DepartmentCdCSV=PA&ShowPOIMetadata=False&Output=Json';            
            request.setEndPoint(endPointUrl);
            // Getting response from Econfig Server.
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            Account lstAccount = [SELECT Id,PoIId__c 
                                  FROM Account 
                                  WHERE PoIId__c =: poiId 
                                  LIMIT 1];//HDMP-8617- fetching AccountId for passing in Error.DealerAccountId
            // Parsing the response body.

                List<Map<String, Object>> myMaps = new List<Map<String, Object>>();
                Map<String, Object> poiResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                Map<String, Object> mapResponse_level1 = (Map<String, Object>) poiResponse.get('POIResponse');
                if(!mapResponse_level1.containsKey('ResultCount') || (mapResponse_level1.containsKey('ResultCount') && (String)mapResponse_level1.get('ResultCount') == '0' )){
                    Map<String, Object> mapResponse_level2 = (Map<String, Object>) mapResponse_level1.get('Error');
                    String errorResponse = (String)mapResponse_level2.get('Description');
                    objDealerResponse.isError = true;                
                }else if(mapResponse_level1.containsKey('ResultCount') && (String)mapResponse_level1.get('ResultCount') != '0'){
                    Map<String, Object> mapPois = (Map<String, Object>)mapResponse_level1.get('POIs');
                    List<Object> poiList = (List<Object>)mapPois.get('POI');
                    if(!poiList.isEmpty()) {
                        Map<String, Object> poiData = (Map<String, Object>)poiList[0];                      
                        Map<String, Object> departments = (Map<String, Object>)poiData.get('Departments');
                        List<Object> departmentList = (List<Object>)departments.get('Department');               
                        Map<String, Object> departmentData = (Map<String, Object>)departmentList[0];                   
                        List<Object> contactList = (List<Object>)departmentData.get('Contact');                    
                        String emails = '';
                        for(Object conDetail : contactList){
                            Map<String, object> mapContactDetails = (Map<String, Object>)conDetail;
                            emails += String.valueOf(mapContactDetails.get('Email')) + ';';                                              
                        }         
                        objDealerResponse.isError = false;
                        objDealerResponse.dealerEmails = emails;
                    }else {
                        objDealerResponse.isError = true;
                    }                          
                }               
            //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
            if(response.getStatusCode() != B2B_IntegrationConstants.STATUSCODE){
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);// to calculate duration time between before API and after API
                String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                String severity;
                String errorType;
                //Below custom metadata provide the information related to Severity and error type based on the feature
                Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity= errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType=errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                Error__c errorRecord = B2B_Util.createErrorRecord(true,'','',lstAccount.Id, personAccountId,'',
                                                                  'B2B_BrainTreeUtils', String.valueOf(response.getStatusCode()), errorType,'',
                                                                  'dealerLocatorService',true,'','','', durationTime, 
                                                                  severity, 'Request:'+request.getBody(), 'Response:'+response.getBody());
            }//HDMP-8617- End of changes
        }catch(Exception ex){
            objDealerResponse.isError = true;
            objDealerResponse.message = ex.getMessage();
        }
        return JSON.serialize(objDealerResponse);
    }
    
    //Created by Faraz Ansari on 02 March 2022 for Dealer On Boarding Rest API.
    //Update By: Palak Gupta: 24/05/2022(Error handling changes- JIRA- 8617)
    
    public static DealerServiceResponse UpdateDealerOnBoardingEnrollment(String dealerNumber){
        Boolean isSuccess = false;
        DealerServiceResponse objDealerResponse = New DealerServiceResponse();
        try {
            Long beforeAPI = B2B_Util.fetchCurrentTime(); // HDMP-8617- This will provide initial response time
            Http http = new Http();
            //creating request body
            String reqBody = '{"mit": {"mit_Version_Number": "1","mit_Version_Date": "2022-02-02",';
            reqBody += '"client_Info":'+ '{"application_Id":"dreamshop.honda.com","echo_Input": "true","server_Ip":"127.0.0.1","session_Id":"123456","domain":"'+ Label.Dealer_On_Boarding_Client_Domain +'",';            
            reqBody += '"environment":"'+ Label.Environment +'"} },"input_Parameters": {"required": {"dealer_No": "'+ dealerNumber +'","dealer_Setup_Completion_Timestamp": "'+ JSON.serialize(datetime.now()).replace('"','') +'"}}}';
            
            //setting headers
            HttpRequest request = B2B_IntegrationCallout.dealerOnBoardingRequest('dealerOnBoarding', reqBody);
            
            //Send request & get response
            HTTPResponse response = http.send(request);
            String responseBody = response.getBody();
            Account lstAccount = [SELECT Id,PoIId__c 
                                  FROM Account 
                                  WHERE PoIId__c =: dealerNumber 
                                  LIMIT 1]; //HDMP-8617-fetching AccountId for passing in Error.DealerAccountId
            //Check status code 200
            if(response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                Map<String,Object> mapVoidResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                Map<String,Object> mapTransaction  = (Map<String,Object>) mapVoidResponse.get('Output');
                if((String)mapTransaction.get('Result') == 'success'){
                    objDealerResponse.isError = false;
                    objDealerResponse.message = (String)mapTransaction.get('Result');
                }
            }else{
                //ToDo - Retry logic
                if(retryDealerOnboarding < 2){
                    retryDealerOnboarding++;
                    UpdateDealerOnBoardingEnrollment(dealerNumber);
                }else {
                    Map<String,Object> mapVoidResponse = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
                    Map<String,Object> mapTransaction  = (Map<String,Object>) mapVoidResponse.get('response');
                    objDealerResponse.isError = true;
                    objDealerResponse.message = (String)mapTransaction.get('errorMessage');  
                    //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                    Long afterAPI = B2B_Util.fetchCurrentTime();// to calculate duration time between before API and after API
                    Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                    String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                    String severity;
                    String errorType;
                    //Below custom metadata provide the information related to Severity and error type based on the feature
                    Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                    if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                        severity= errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                        errorType=errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                    }
                    else{
                        severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                        errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                    }
                    Error__c errorRecord = B2B_Util.createErrorRecord(true,'','',lstAccount.Id, personAccountId,'',
					'B2B_BrainTreeUtils', String.valueOf(response.getStatusCode()), errorType,'',
					'UpdateDealerOnBoardingEnrollment',true,'','','', durationTime, 
                    severity, 'Request:'+request.getBody(), 'Response:'+response.getBody());
                	//HDMP-8617- End of changes
                }
            }
        } catch (Exception e) {
            if(retryDealerOnboarding < 2){
                retryDealerOnboarding++;
                UpdateDealerOnBoardingEnrollment(dealerNumber);
            }else {
                objDealerResponse.isError = true;
                objDealerResponse.message = e.getMessage();
            }
        }
        return objDealerResponse;
    }
    //End Here
    
    public class DealerServiceResponse {
        public Boolean isError;      
        public string message;
        public String dealerEmails;                
    }
}
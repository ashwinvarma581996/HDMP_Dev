/*
Name RES_BrainTreeUtils
Description : This is a Utility class for BrainTree Integration.
*/

public Without Sharing class RES_BrainTreeUtils {

public static Integer retryCount = Integer.valueOf(Label.BT_RetryCount);
public static Integer retryDealerOnboarding = Integer.valueOf(Label.BT_RetryCount);

//method to create Error record
public static Error__c createErrorRecord(String name, String orderId , String errorMessage){
    Error__c objError = new Error__c();
    objError.Name = name;
    objError.Order__c = orderId;
    objError.ClassName__c = 'RES_BrainTreeIntegration';
    objError.Error_Message__c = errorMessage;
    objError.MethodName__c = 'braintreeOrderCancellation';
    objError.RecordId__c = orderId;
    return objError;
}

//method to call vertax return tax
public static RES_BTVertexTaxCalculationIntegration.ResponseDataWrapper callVertaxReturnTax(Account objAccount, Order objOrder){
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
    RES_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper = RES_BTVertexTaxCalculationIntegration.calculateTax(objOrder.cart__c, dealerAddressMap, customerAddressMap, objAccount.PoIId__c, String.valueOf(objOrder.cart__r.ShippingAmount__c), 'return');
    System.debug('objResponseDataWrapper : '+ objResponseDataWrapper);
    return objResponseDataWrapper;

}

//method to call vertax return tax
public static RES_BTVertexTaxCalculationIntegration.ResponseDataWrapper callVertaxLineItemReturnTax(Account objAccount, Order objOrder){
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
    RES_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper = RES_BTVertexTaxCalculationIntegration.calculateLineItemReturnTax(objOrder.cart__c, dealerAddressMap, customerAddressMap, objAccount.PoIId__c);
    System.debug('objResponseDataWrapper : '+ objResponseDataWrapper);
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
    objBTTokenDetail.AccessTokenExpiresAt__c = accessTokenExpDate.addMinutes(-5);
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
        //callout to braintree SDK
        String response = RES_BrainTreeIntegration.getAccessToken(objAccount.Merchant_Id__c, code);
        System.debug('__response__ : ' +response );
        List<BT_Token_Details__c> lstBTTokenDetailsUpsert = new List<BT_Token_Details__c>();
        B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();
        objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(response, B2B_AccessTokenResponseWrapper.class);
        system.debug('objAccessTokenResponseWrapper : '+ objAccessTokenResponseWrapper);
        if(objAccessTokenResponseWrapper.status == 200){
            List<BT_Token_Details__c> lstBTTokenDetails = [SELECT Id, Name, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c, Account__c
                                                           FROM BT_Token_Details__c
                                                           WHERE Account__c =: objAccount.Id LIMIT 1];


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
                objBTTokenDetail.AccessTokenExpiresAt__c = accessTokenExpDate.addMinutes(-5);
                objBTTokenDetail.RefreshTokenExpiresAT__c = refreshTokenExpDate;
                lstBTTokenDetailsUpsert.add(objBTTokenDetail);
            }else {
                BT_Token_Details__c objNewBTTokenDetail = new BT_Token_Details__c();
                objNewBTTokenDetail.AccessToken__c = objAccessTokenResponseWrapper.credentials.accessToken;
                objNewBTTokenDetail.RefreshToken__c = objAccessTokenResponseWrapper.credentials.refreshToken;
                objNewBTTokenDetail.AccessTokenExpiresAt__c = accessTokenExpDate.addMinutes(-5);
                objNewBTTokenDetail.RefreshTokenExpiresAT__c = refreshTokenExpDate;
                objNewBTTokenDetail.Account__c = objAccount.Id;
                lstBTTokenDetailsUpsert.add(objNewBTTokenDetail);
            }

            //Calling dealer onboarding API
            DealerServiceResponse objDealerResponse = UpdateDealerOnBoardingEnrollment(objAccount.PoIId__c);
            if(!objDealerResponse.isError){
                //update BT_Details
                if(!lstBTTokenDetailsUpsert.isEmpty()){
                    upsert lstBTTokenDetailsUpsert;
                    objAccount.isActive__c = true;
                    /*if(objAccount.Is_Dreamshop__c == true){
                        objAccount.Dreamshop_Setup__c = true;
                    }
                    if(objAccount.Is_Vehicle_Reserve__c == true){
                        objAccount.Vehicle_Reserve_Setup__c = true;
                    } */
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
            }
        }

    }catch(Exception ex){
        status = 'Failed';
        System.debug('exception : '+ ex.getMessage());
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
*/
@auraEnabled
public static Account updateAccountByMerchant(String merchantId, String code, String state){
    System.debug('merchant id : '+ merchantId);
    String tempMerchantId = String.valueOf(merchantId);
    List<Account> lstAccounts = [SELECT Id, Merchant_Id__c, Code__c, State__c, isActive__c ,OnBoarding_Error__c,PoIId__c,
                                 Is_Dreamshop__c, Is_Vehicle_Reserve__c, Dreamshop_Setup__c, Vehicle_Reserve_Setup__c
                                 FROM Account
                                 WHERE Merchant_Id__c =: tempMerchantId LIMIT 1];
    System.debug('lstAccounts : '+ lstAccounts);
    if(!lstAccounts.isEmpty()){
        lstAccounts[0].code__c = code;
        lstAccounts[0].state__c = state;
        update lstAccounts[0];
        return lstAccounts[0];
    }
    return null;
}


/*
Created By : MON*TB
Date : 20/07/2021
Description : Refreshes the current Access and Refresh Tokens for the current Merchant
*/
  public static void refreshAccessToken(BT_Token_Details__c btDetails) {
      //Request a new Access Token given the current Refresh Token
      String refreshTokenResponse = RES_BrainTreeIntegration.getRefreshToken(btDetails.Account__r.Merchant_Id__c, btDetails.RefreshToken__c);
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

          btDetails.AccessToken__c = accessToken;
          btDetails.AccessTokenExpiresAt__c = accessTokenExpDate;
          btDetails.RefreshToken__c = refreshToken;
          btDetails.RefreshTokenExpiresAT__c = refreshTokenExpDate;

          update btDetails;

          System.debug('requestNewAccessToken: '+btDetails);

      } else {
          //TODO - should non-200 responses be considered?
      }
  }

  /*
Created By : MON*TB
Date : 20/07/2021
Description : Refreshes the current Access and Refresh Tokens for the current Merchant
*/
  @future(callout=true)
  public static void futureNewAccessToken(String MerchantId) {
      //Get Access Token List
      List<BT_Token_Details__c> tokens = [SELECT AccessToken__c,	AccessTokenExpiresAt__c, Account__r.Merchant_Id__c,	RefreshTokenExpiresAT__c, RefreshToken__c FROM BT_Token_Details__c WHERE Account__r.Merchant_Id__c =: MerchantId LIMIT 1];
      System.debug('futureNewAccessToken: '+tokens[0]);
      if(tokens.size() > 0 &&tokens[0].RefreshToken__c != null){
          refreshAccessToken(tokens[0]);
          System.debug('futureNewAccessToken: '+tokens[0]);
      }

  }

  //method for sending bulk emails
 /* public static void SendEmail(String templateName, String orderId, String dealerLocatorResponse) {
      DealerServiceResponse objRes = (DealerServiceResponse) JSON.deserialize(dealerLocatorResponse, DealerServiceResponse.class);
      List<String> lstDealerEmails = objRes.dealerEmails.split(';');
      EmailTemplate emailTemplate = [SELECT Id,Subject, Description, HtmlValue, DeveloperName, Body
                                     FROM EmailTemplate
                                     WHERE name =: templateName];
      List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
      // Define the email
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setToAddresses(lstDealerEmails);

      // Sets the paramaters of the email
      email.setUseSignature(false);
      email.setBccSender(false);
      email.setSaveAsActivity(false);
      email.setTemplateId(emailTemplate.Id);
      email.setWhatId(orderId);
      email.setTargetObjectId('005g0000008SuLiAAK');
      lstEmails.add(email);
      // Sends mass emails
      Messaging.sendEmail(lstEmails);
  } */

//this method is used to call dealer locator api after the customer is charged from dealer console.
public static string dealerLocatorService(String poiType, String poiId){
    DealerServiceResponse objDealerResponse = New DealerServiceResponse();
    try{
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String guId = B2B_Util.createGui();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('hondaHeaderType.messageId',guId);
        request.setHeader('accept','application/json');
        request.setMethod('GET');
        String endPointUrl = 'callout:B2B_Dealer_Credential';
        endPointUrl += Label.B2B_Dealer_Locator_URL;
        //http://staging.location.services.honda.com/poi/private/v1?AppId=bodyshops.honda.com
        endPointUrl += '&POIId='+poiId+'&Country=US&POIType='+poiType+'&SearchRadius=20&NumberOfPOIs=1&ShowAllAttributes=False&ShowAllProperties=False&ShowAllDepartments=False&DepartmentCdCSV=PA&ShowPOIMetadata=False&Output=Json';
        request.setEndPoint(endPointUrl);
        System.debug('--requestUrl---'+request.getEndpoint());

        // Getting response from Econfig Server.
        HTTPResponse response = http.send(request);
        String responseBody = response.getBody();
        System.debug('responseBodyData'+response.getBody());

        // Parsing the response body.
        List<Map<String, Object>> myMaps = new List<Map<String, Object>>();
        Map<String, Object> poiResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        //System.debug('poiResponse'+poiResponse);
        Map<String, Object> mapResponse_level1 = (Map<String, Object>) poiResponse.get('POIResponse');

        if(!mapResponse_level1.containsKey('ResultCount') || (mapResponse_level1.containsKey('ResultCount') && (String)mapResponse_level1.get('ResultCount') == '0' )){
            Map<String, Object> mapResponse_level2 = (Map<String, Object>) mapResponse_level1.get('Error');
            String errorResponse = (String)mapResponse_level2.get('Description');
            System.debug('ErrorMessageDetail'+errorResponse);
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
                    System.debug('mapContactDetails'+ JSON.serialize(mapContactDetails));
                    emails += String.valueOf(mapContactDetails.get('Email')) + ';';
                }
                System.debug('emails :'+emails);
                objDealerResponse.isError = false;
                objDealerResponse.dealerEmails = emails;
            }else {
                objDealerResponse.isError = true;
            }
        }
    }catch(Exception ex){
        objDealerResponse.isError = true;
        objDealerResponse.message = ex.getMessage();
        System.debug('objDealerResponse'  + objDealerResponse);
    }
    return JSON.serialize(objDealerResponse);
}
//Created by Faraz Ansari on 02 March 2022 for Dealer On Boarding Rest API.
public static DealerServiceResponse UpdateDealerOnBoardingEnrollment(String dealerNumber){
    Boolean isSuccess = false;
    DealerServiceResponse objDealerResponse = New DealerServiceResponse();
    try {
        Http http = new Http();
        //creating request body
        String reqBody = '{"mit": {"mit_Version_Number": "1","mit_Version_Date": "2022-02-02",';
        reqBody += '"client_Info":'+ '{"application_Id":"dreamshop.honda.com","echo_Input": "true","server_Ip":"127.0.0.1","session_Id":"123456","domain":"'+ Label.Dealer_On_Boarding_Client_Domain +'",';
        reqBody += '"environment":"'+ Label.Environment +'"} },"input_Parameters": {"required": {"dealer_No": "'+ dealerNumber +'","dealer_Setup_Completion_Timestamp": "'+ JSON.serialize(datetime.now()).replace('"','') +'"}}}';
        System.debug('RequestBody : '+reqBody);

        //setting headers
        HttpRequest request = B2B_IntegrationCallout.dealerOnBoardingRequest('dealerOnBoarding', reqBody);

        //Send request & get response
        HTTPResponse response = http.send(request);
        System.debug('ResponseBody==='+ response.getBody());

        String responseBody = response.getBody();
        //Check status code 200
        if(response.getStatusCode() == 200){
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
            }
        }
    } catch (Exception e) {
        System.debug('error : '+e.getMessage()+' line : '+e.getLineNumber());
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
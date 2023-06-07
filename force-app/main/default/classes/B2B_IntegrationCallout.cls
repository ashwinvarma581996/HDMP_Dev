/*
Created By : Radhey Shyam Gupta/Rajrishi Kaushik
Date : 22/04/2021
Description : this class used to create HttpRequest for IN, eConfig and BrainTree System.
*/
public class B2B_IntegrationCallout {
    
    //method to create request for eConfig System
    public static HttpRequest eConfigRequest(String methodName,String reqBody){
        HttpRequest request = new HttpRequest();
        String guId = B2B_Util.createGui();
        request.setHeader('accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', Label.B2B_Econfig_VinDecoderBearer);
        request.setHeader('ClientDomain', Label.B2B_Econfig_VinDecoder_ClientDomain);
        request.setHeader('X-Honda-wl-authorization', Label.B2B_Econfig_VinDecoder_Honda_Auth);
        request.setHeader('hondaHeaderType.messageId', guId);
        request.setMethod('POST');
        request.setBody(reqBody);
        String finalurl ='callout:Econfig_Vindecoder';
        if(methodName == 'GetModelByVIN'){
            finalurl += '/'+Label.B2B_VinDecoder;
        }else if(methodName == 'GetCompleteDetails'){
            finalurl += Label.B2B_Get_Complete_Details_URL;
        }
        request.setEndpoint(finalurl);
        return request;
    }
    
    //By Faraz :- Method to create request for dealer onboarding
    public static HttpRequest dealerOnBoardingRequest(String methodName, String reqBody){
        HttpRequest request = new HttpRequest();
        String guId = B2B_Util.createGui();
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', Label.Dealer_On_Boarding_Bearer);
        request.setHeader('ClientDomain', Label.Dealer_On_Boarding_Client_Domain);
        request.setHeader('hondaHeaderType.messageId', guId);
        request.setMethod('POST');
        request.setBody(reqBody);
        //Setting Endpoint
        String finalUrl = 'callout:UpdateDealerEnrollment' + Label.Update_Dealer_Enrollment;
        request.setEndpoint(finalUrl);
        
        //send request to main class
        return request;
    }
    //End on 07 March 2022
    
    //method to create request for IN System
    public static HttpRequest inSystemRequest(String methodName,String reqBody){
        String usernamePassword = Label.B2B_IN_UserName+':'+Label.B2B_IN_Password ;
        String authorizationString = EncodingUtil.base64Encode(Blob.valueof(usernamePassword));
        System.debug('authorizationString :' +authorizationString);
        HttpRequest request = new HttpRequest();
        String guId = B2B_Util.createGui();
        request.setHeader('accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic '+authorizationString);
        request.setHeader('hondaHeaderType.siteId', Label.B2B_IN_SiteId);
        request.setHeader('hondaHeaderType.businessId', Label.B2B_IN_BusinessId); 
        request.setHeader('hondaHeaderType.ApplicationId', Label.B2B_IN_ApplicationId);    
        request.setHeader('hondaHeaderType.messageId', guId);
        request.setHeader('hondaHeaderType.collectedTimestamp', datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'America/Los_Angeles')); 
        request.setMethod('POST');
        request.setBody(reqBody);
        String finalurl = 'callout:B2B_IN_Credential/';
        if(methodName == 'GetModelByVinDecoder'){
            finalurl += Label.B2B_IN_VinDecoder_Url_Path;
        }else if(methodName == 'GetIllustrationBySectionID') {
            finalurl += Label.B2B_IN_GetIllustration_Url_Path;
        }else if(methodName == 'GetPartsByIllustrationID'){
            finalurl += Label.B2B_IN_GetParts_Url_Path;
        }else if(methodName == 'ValidatePartsVIN'){
            finalurl += Label.B2B_IN_ValidatePartsVIN; //Added by Apoorv Garg(21/06/2021)
        }else if(methodName == 'SearchbyProduct'){   // Added by Apoorv Garg (21/05/2021)
            finalurl += Label.B2B_IN_SearchbyProduct_Url_Path;
        }
        //String finalurl = 'callout:B2B_IN_Credential/'+Label.B2B_IN_VinDecoder_Url_Path;
        request.setEndpoint(finalurl);
        request.setTimeout(120000);
        return request;
    }
    // changes related to Partial part Search-- by Soumya
    public static HttpRequest inSystemRequestPartial(String methodName,String reqBody){
        String usernamePassword = Label.B2B_iN_UserName_Parts+':'+Label.B2B_IN_Password ;
        String authorizationString = EncodingUtil.base64Encode(Blob.valueof(usernamePassword));
        System.debug('authorizationString :' +authorizationString);
        HttpRequest request = new HttpRequest();
        String guId = B2B_Util.createGui();
        request.setHeader('accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic '+authorizationString);
        request.setHeader('hondaHeaderType.siteId', Label.B2B_IN_SiteId);
        request.setHeader('hondaHeaderType.businessId', Label.B2B_IN_BusinessId); 
        request.setHeader('hondaHeaderType.ApplicationId', Label.B2B_IN_ApplicationId);    
        request.setHeader('hondaHeaderType.messageId', guId);
        request.setHeader('hondaHeaderType.collectedTimestamp', datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'America/Los_Angeles')); 
        request.setMethod('POST');
        request.setBody(reqBody);
        //string finalurl;
        String finalurl= 'callout:B2B_Partial_IN_Credential/';
        if(methodName == 'MaintainenceProduct'){
            finalurl += Label.B2B_iN_Maintenance_Url_Path;
        }else if(methodName == 'PartialSearchbyProduct'){   // Added by Apoorv Garg (21/05/2021)
            finalurl += Label.B2B_iN_PartialSearchProduct_Url_Path;
        }
        request.setEndpoint(finalurl);
        request.setTimeout(120000);
        return request;
    }// end by -- Soumya
    
    //method to create request for BrainTree System
    public static HttpRequest createBraintreeRequest(String methodType,String reqBody,String methodName){
        String guId = B2B_Util.createGui();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('hondaHeaderType.messageId', guId);
        request.setHeader('accept', 'application/json');
        request.setTimeout(120000);
        if(methodType == 'GET'){
            request.setMethod('GET');
        }else if(methodType == 'POST'){
            request.setMethod('POST');        
            request.setBody(reqBody);
            String finalUrl = 'callout:Braintree_Named_Credential';
            if(methodName == 'pre-auth'){
                finalUrl += Label.B2B_BT_Pre_Auth;                   
            }else if(methodName == 'post-auth'){
                finalUrl += Label.B2B_BT_Post_Auth;                  
            }else if(methodName == 'refund'){
                finalUrl += Label.B2B_BT_Refund;                
            }else if(methodName == 'void'){
                finalUrl += Label.B2B_BT_Void;                  
            }else if(methodName == 'update'){
                finalUrl += Label.B2B_BT_Update;                  
            }else if(methodName == 'Payment Delete'){
                finalUrl += Label.B2B_BT_Payment_Delete;                  
            }else if(methodName == 'Address Delete'){
                finalUrl += Label.B2B_BT_Address_Delete;                  
            }else if(methodName == 'Find'){
                finalUrl += Label.B2B_BT_Find;                  
            }else if(methodName == 'search'){
                finalUrl += Label.B2B_BT_Search;                  
            }

            //finalUrl += 'errorScenario';
           
            request.setEndpoint(finalUrl);
            
        }
        return request;
    }
    public static HttpRequest uspsRequest(String reqBody){
        HttpRequest request = new HttpRequest();
        String guId = B2B_Util.createGui();
        request.setHeader('Authorization',Label.B2B_USPS_Authorization);
        request.setHeader('hondaHeaderType.messageId', guId);
        request.setMethod('POST');
        request.setbody(reqBody);
        String finalUrl='callout:USPSShippingNamedCredential';
        finalurl += Label.B2B_USPS_Resource;
        request.setEndpoint(finalurl);
        request.setTimeout(120000);
        return request;
    }
    public static HttpRequest upsRequest(String reqBody){
        HttpRequest request = new HttpRequest();
        String guId = B2B_Util.createGui();
        request.setHeader('accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization',Label.B2B_UPS_Authorization);
        request.setHeader('hondaHeaderType.messageId', guId);
        request.setHeader('Username',Label.B2B_UPS_Username);
        request.setHeader('transId',Label.B2B_UPS_transId);
        request.setHeader('AccessLicenseNumber',Label.B2B_UPS_AccessLicenseNumber);
        request.setHeader('transactionSrc',Label.B2B_UPS_transactionSrc);
        request.setHeader('Password',Label.B2B_UPS_Password);
        request.setMethod('POST');
        request.setbody(reqBody);
        String finalUrl='callout:UPSDataPowerNamedCredential';
        finalurl += Label.B2B_UPS_Resource;
        request.setEndpoint(finalurl);
        request.setTimeout(120000);
        return request;
    }
    
}
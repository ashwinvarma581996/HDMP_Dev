/*
Created By : Rajrishi Kaushik
Date : 06/07/2021
Description : This is a Wrapper class for BrainTree Integration response.
*/
public class B2B_AccessTokenResponseWrapper {
    public Integer status;  
    public String merchantId; 
    public String errorMessage;
    public cls_credentials credentials;
    public String requestBody;
    public String responseBody;
    
    public class cls_credentials {
        public String accessToken;  
        public String refreshToken;
        public String tokenType; 
        public String expiresAt; 
        public String scope;  
    }
}
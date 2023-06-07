//****************************************************************************** 
// File Name:       ownRecaptchaController.cls
// Summary:         Apex Class for ownGoogleCaptcha
// Created On:      14-2-2022
// Created By:      Ravindra Ravindra (Wipro)
// Data I/O:        
// Honda Jira Story: Apex class for Garage for Honda Owner Experience
//===============================================================================
// Modification Log: 
// Feb 2, 2022 Ravindra Ravindra (Wipro) initial coding 


public class ownRecaptchaController {
	
    @AuraEnabled
    public static Boolean verifyCaptcha ( String recaptchaResponse ) {
        String recaptchaSecretKey = System.Label.recaptchaSecretKey; 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(System.Label.Captcha_Site);
        request.setMethod( 'POST');
        request.setBody( 'secret=' + recaptchaSecretKey + ' &response=' + recaptchaResponse );
        HttpResponse response = http.send( request );

        if ( response.getStatusCode() == 200 ) {
            
            System.debug( 'Response Body is ' + response.getBody() );
            Map < String, Object > result = ( Map< String, Object > ) JSON.deserializeUntyped( response.getBody() );

            if ( result.containsKey( 'success' ) && result.get( 'success' ) == true) { 
            
            	return true;
            } else {

                return false;

            }
            
        }
        
        return false;

    }

}
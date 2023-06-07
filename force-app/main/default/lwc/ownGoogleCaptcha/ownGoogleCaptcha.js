//============================================================================
// Title:    Google Captcha 
//
// Summary:  This is the JS for Google Captcha reuseable component
//
// Details:  Extent the ownGoogleCaptcha as child component into your lwc 
//           forms to implement google captcha.
//           for example :  <c-own-google-captcha oncaptcha={handleUpdate}></c-own-google-captcha><br/>
//           NOTE: import verifyCaptcha from '@salesforce/apex/RecaptchaController.verifyCaptcha';

// History:
// Feb 14, 2022 Ravindra Ravindra (Wipro) Original Author
//=========================================================================== -->
import { LightningElement } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnGoogleCaptcha extends OwnBaseElement {
    
    connectedCallback() {

        //console.log( 'Inside Google Captcha Connected Callback' );
        document.addEventListener( "grecaptchaVerified", ( e ) => {

            //console.log( 'Captcha Response from Verification is ' + e.detail.response );
            let detailPayload = { value : false, response : e.detail.response };
            this.dispatchEvent( new CustomEvent( 'captcha', { detail : detailPayload } ) );

        });

        document.addEventListener( "grecaptchaExpired", () => {

            //console.log( 'Listener Expired' );
            this.dispatchEvent( new CustomEvent( 'captcha', { detail : { value : true } } ) );

        } );
        
    }

    renderedCallback() {

        //console.log( 'Inside Google Captcha Rendered Callback' );
        let divElement = this.template.querySelector( 'div.recaptchaCheckbox' );
        //console.log( 'Div Element is ' + JSON.stringify( divElement ) );
        let payload = { element: divElement };
        document.dispatchEvent(new CustomEvent( "grecaptchaRender",  { "detail": payload } ) );
        
    }
}
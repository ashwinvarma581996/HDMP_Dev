//============================================================================
// Title:    Honda Owners Experience - Sign Up and Log In
//
// Summary:  sign up and log in logic at the top of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the sign up and log in component for all help center pages.
//
//
// History:
// June 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import {
    LightningElement, track
} from 'lwc';
import {
    OwnBaseElement
} from 'c/ownBaseElement';
import { ISGUEST } from 'c/ownDataUtils'; //Ravindra Ravindra(Wipro)  DOE-4370
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import userId from '@salesforce/user/Id';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnSignUpLogin extends OwnBaseElement {
    domainName;
    appId;
    @track loginUrl;
    @track signUpUrl;
    @track isguest = ISGUEST;
    connectedCallback() {
        this.getCIAMdetails();
        /* console.log('isUserLogin', sessionStorage.getItem('isUserLogin'));
        console.log('ownSignUpLogin Connected callback');
        if (sessionStorage.getItem('isUserLogin') && userId){
            console.log('Getting garage from API (ownSignUpLogin');
            getUserVehiclesFromAPI({'userId' : userId})
                .then(result=>{})
                .catch(error=>{console.log(JSON.stringify(error))});
        } */
    }

    getCIAMdetails = async () => {
        getCIAMConfig().then(result => {
            this.domainName = result.Domain_Name__c;
            this.appId = result.Application_Id__c;
            this.loginUrl = result.Ciam_Login_Url__c;
            this.signUpUrl = result.Ciam_SignUp_Url__c;
            //console.log('Custom Settings :', this.domainName + '--' + this.appId);
        })

    }

    handleClick(event) {
        // //Ravindra Ravindra(Wipro)  DOE-4370
        if (this.isguest) {
            var currentLocation = window.location;
            sessionStorage.setItem("RelayState", currentLocation.href);
        }
        //end


        let button = event.target.getAttribute('data-id');
        let url = '';

        if (this.domainName != undefined && this.appId != undefined) {
            // if (button === 'Sign_Up') {
            //     url = this.domainName + '/hondaowners/s/login/SelfRegister?app=' + this.appId + `&RelayState=${window.location.href}`;
            // } else if (button === 'Log_In') {
            //     url = this.domainName + '/hondaowners/s/login/?app=' + this.appId + `&RelayState=${window.location.href}`;
            // }
            let eventMetadata = {
                action_type: 'button',
                action_category: 'global-header-navigation'
            };
            if (button === 'Sign_Up') {
                eventMetadata.action_label = 'sign up';
                url = this.signUpUrl + `&RelayState=${window.location.href}`;
            } else if (button === 'Log_In') {
                eventMetadata.action_label = 'log in';
                url = this.loginUrl + `&RelayState=${window.location.href}`;
            }
            sessionStorage.setItem('referrer', document.location.href);
            let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
            this.publishToChannel(message);
            //console.log('URL == ', url);
            sessionStorage.setItem("isUserLogin", true);
            window.open(url, '_self');

            /* const config = {
                type: 'standard__webPage',
                attributes: {
                    url: url
                }
            };
            this[NavigationMixin.GenerateUrl](config)
                .then(url => {
                    window.open(url, '_self')
                }); */
        }

    }

}
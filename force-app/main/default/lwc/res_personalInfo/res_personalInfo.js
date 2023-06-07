/**
 * @description       : Form for capturing contact data
 * and sending to payments.
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-07-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
/* #region imports */
import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveReservation from '@salesforce/apex/Res_PersonalInfoController.saveReservation';
import startSession from '@salesforce/apex/Res_PersonalInfoController.startSession';
import doLogin from '@salesforce/apex/Res_PersonalInfoController.doLogin';
import saveFormData from '@salesforce/apex/Res_PersonalInfoController.saveFormData';
import isOnWaitlist from '@salesforce/apex/RES_CapManagement.isOnWaitlist';
import getBackLink from '@salesforce/apex/Res_PersonalInfoController.getBackLink';
import postLeadsFromReservation from '@salesforce/apex/RES_LeadCreation.postLeadsFromReservation';
import getReturnUrl from '@salesforce/apex/RES_GenerateConfirmationPayload.getReturnUrlFromReservation';
import sendConfirmation from '@salesforce/apex/RES_Send_Email.sendConfirmationByRes';
import FIRST_NAME from '@salesforce/schema/Reservation_Contact2__c.First_Name__c';
import LAST_NAME from '@salesforce/schema/Reservation_Contact2__c.Last_Name__c';
import EMAIL from '@salesforce/schema/Reservation_Contact2__c.Email_Address__c';
import PHONE from '@salesforce/schema/Reservation_Contact2__c.Phone_Number__c';
import ZIP from '@salesforce/schema/Reservation_Contact2__c.Zip_Code__c';
import ACCEPTED from '@salesforce/schema/Reservation_Contact2__c.Accepted_Terms__c';
import CONFIRM_EMAIL from '@salesforce/schema/Reservation_Contact2__c.Confirm_Email_Address__c';
import USERID from '@salesforce/user/Id';
import ISGUEST from '@salesforce/user/isGuest';
import { MessageContext, publish } from 'lightning/messageService';
import TAG_PARAMETER_UPDATE from '@salesforce/messageChannel/Tag_Parameter_Update__c';
import resCopyList from '@salesforce/apex/RES_CopyController.getSingleCopySets';
import { compressJSONString, deCompressJSONString } from 'c/resUtils';

export default class res_personalInfo extends NavigationMixin(LightningElement) {
    //local variables
    firstName = FIRST_NAME;
    lastName = LAST_NAME;
    email = EMAIL;
    phone = PHONE;
    zip = ZIP;
    accepted = ACCEPTED;
    confirmEmail = CONFIRM_EMAIL;
    reservationId;
    redirectUrl;
    isGuestUser = ISGUEST;
    isConnected = false;
    currentPageReference = null;
    dataloaded = false;
    generateUrl = false;
    userId = USERID;
    buttonLabel = 'Submit';
    subHead;
    forceLogin = false;
    _dataObject = null;
    isParticipantDealer = false;
    isNotaParticipantDealer = false;
    headingText;
    loginRetries = 0;
    modelName;
    modelYear;
    bodyStyle;
    byClicking;
    mdxTerms = false;
    integraTerms = false;
    clickDisabled = false;
    firstNameField;
    lastNameField;
    emailField;
    zipField;
    phoneField;
    acceptField;
    confirmEmailField;

    //used to open terms and conditions.
    @track openModal = false;
    @wire(MessageContext) messageContext;
    @api termsLink = '../s/terms-and-conditions';
    @api privacyPolicyLink = 'https://akamai-staging.honda.com/privacy/privacy-policy.pdf';
    @api recordId;
    @api objectApiName;

    @api
    get waitlisted() {
        let lsval = sessionStorage.getItem('waitlisted');
        return lsval === 'true';
    }

    set waitlisted(value) {
        if (value === true)
            sessionStorage.setItem('waitlisted', 'true');
        else
            sessionStorage.removeItem('waitlisted');
    }

    //component begins
    connectedCallback() {
        window.document.title = 'Personal Information';
        this.newSession();
        this.isConnected = true; //https://dreamshop-stage.cs202.force.com/tools/reserve-online/s/personal-information?data=ew0KICAgIm1vZGVsSWQiOiJUQzFINk1LTlciLA0KICAgInZlaGljbGVNb2RlbFNlcmllcyI6Ik1EWCBUeXBlIFMiLA0KICAgIm1vZGVsWWVhciI6MjAyMiwNCiAgICJleHRlcmlvckNvbG9yIjoiUGVyZm9ybWFuY2UgV2hpdGUgUGVhcmwiLA0KICAgImV4dGVyaW9yQ29sb3JDb2RlIjoiQi02MjEiLA0KICAgImV4dGVyaW9yQ29sb3JQcmljZSI6IjUwMCIsDQogICAiaW50ZXJpb3JDb2xvciI6IlJlZCIsDQogICAiaW50ZXJpb3JDb2xvckNvZGUiOiJSRSIsDQogICAiZGVwb3NpdEFtb3VudCI6IjUwMCIsDQogICAiTVNSUCI6IjUwNTAwIiwNCiAgICJkZWFsZXJOdW1iZXIiOiIyNTEwNTkiLCAgICANCiAgICJkZWFsZXJOYW1lIjoiQWN1cmEgb2YgU2hlcm1hbiBPYWtzIiwNCiAgICJkZWFsZXJBZGRyZXNzIjoiNTIzMCBWYW4gTnV5cyBCbHZkIFNoZXJtYW4gT2FrcyIsDQogICAiZGVhbGVyUGhvbmVOdW1iZXIiOiI4MTgtNTI4LTEzMDAiLA0KICAgImlzUGFydGljaXBhbnREZWFsZXIiOnRydWUsDQogICAiemlwQ29kZSI6IjkwMjEwIiwNCiAgICJjYWxsYmFja1VybCI6Imh0dHBzOi8vY2ExLW5ldy1hY3VyYS5wb3NzaWJsZS5jb20vdG9vbHMvcmVzZXJ2ZS1vbmxpbmUvY29uZmlybWF0aW9uIiwNCiAgICJidXNpbmVzc0VudGl0eSI6IiIsDQogICAicHJvdmlkZXJQYXJ0aWNpcGFudERlYWxlciI6Ik1EWCBUeXBlIFMgRGVwb3NpdCBBSE0iLA0KICAgInByb3ZpZGVyTm9uUGFydGljaXBhbnREZWFsZXIiOiJNRFggTEFVTkNIIEFITSIsDQogICAic2hvcHBpbmdUb29sIjoiUmVzZXJ2ZSBPbmxpbmUiLA0KICAgInRyYW5zYWN0aW9uVHlwZSI6IlZMIiwNCiAgICJkZWxpdmVyeVNlbmREYXRlIjoiIiwNCiAgICJjYW1wYWlnbk5hbWUiOiIiDQp9
    }

    initPage() {
        console.debug('init page start');
        if (!sessionStorage.getItem('referrer') && window.document.referrer) {
            sessionStorage.setItem('referrer', window.document.referrer);
        }
        //if we are a guest user or
        if (this.isGuestUser || this.forceLogin) {
            console.debug('page init');
            this.guestLogin();
        } else {
            try {
                if (this.waitlisted) {
                    console.debug('waitlisted');
                    this.setUpForm();
                } else {
                    let input = deCompressJSONString(sessionStorage.getItem('data'));
                    isOnWaitlist({ dataStr: input })
                        .then(res => {
                            console.debug('wl--->', res);
                            this.waitlisted = res.IsWaitlist === 'true' ? true : false;
                            sessionStorage.setItem('productId', res.Product);
                            if (res.ReservationCapGroup && res.ReservationCapGroup !== 'null' && res.ReservationCapGroup !== 'undefined') {
                                sessionStorage.setItem('capGroupId', res.ReservationCapGroup);
                            }
                            this.setUpForm();
                        })
                        .catch((e) => {
                            console.error('exception checking watilist ' + JSON.stringify(e));
                            this.setUpForm()
                        });
                }
            } catch (e) {
                console.error(e);
            }
        }
    }

    //check if session exist (back button hit)
    newSession() {
        if (this.currentPageReference == null) {
            return;
        }
        if (sessionStorage.getItem('back') === 'true') {
            sessionStorage.removeItem('back');
        }
        else {
            // const loggedIn = sessionStorage.getItem('loggedIn');
            // if (this.currentPageReference.state.data && loggedIn !== 'true') {
            if (this.currentPageReference.state.data) {
                this.waitlisted = false;
                this.isParticipantDealer = false;
                this.isNotaParticipantDealer = false;
                sessionStorage.removeItem('data');
                sessionStorage.removeItem('back');
                sessionStorage.removeItem('loggedIn');
                sessionStorage.removeItem('productId');
                sessionStorage.removeItem('capGroupId');
                this.loginRetries = 0;
                this.forceLogin = true;
                this.extractData();
            }
            else {
                if (sessionStorage.getItem('data') === null) {
                    // window.history.back();
                }
                else {
                    if (this.currentPageReference.state.waitlist === 'y' || this.currentPageReference.state.waitlist === 'true') {
                        this.waitlisted = true;
                    }
                }
            }
        }
        this.dataloaded = true;
        //setup the page for the user
        this.initPage();
    }

    //use data to drive form values now
    setUpForm() {
        this.clickDisabled = false;
        let data = sessionStorage.getItem('data');
        //decoded
        var decodedData = deCompressJSONString(data);
        //used to remove null values
        var dataNullsRemoved = JSON.parse(decodedData.replace(/\:null/gi, "\:\"\""));
        console.debug('form', dataNullsRemoved);
        try {
            //set values from decoded string
            this.isParticipantDealer = this.waitlisted ? false : dataNullsRemoved.isParticipantDealer;
            this.isNotaParticipantDealer = this.isParticipantDealer ? false : (this.waitlisted ? false : true);
            this.modelName = dataNullsRemoved.modelName ? dataNullsRemoved.modelName : 'MDX';
            this.modelYear = dataNullsRemoved.modelYear;
            //this.bodyStyle = dataNullsRemoved.packageName ? dataNullsRemoved.packageName : 'Type S' ;
            this.bodyStyle = dataNullsRemoved.subsciptionInfo.vehicleModelBodyStyle ? dataNullsRemoved.subsciptionInfo.vehicleModelBodyStyle : 'Sedan';
            const vehicleModelSeries = dataNullsRemoved.vehicleModelSeries;
            //determine make and model
            resCopyList({ modelName: this.modelName, waitlisted: this.waitlisted, isParticipantDealer: this.isParticipantDealer })
                .then((result) => {
                    this.copy = result;
                    this.error = undefined;
                    var parser = new DOMParser();
                    var doc;
                    var container;
                    //parse html
                    doc = parser.parseFromString(this.copy.windowDocumentTitle__c, 'text/html');
                    window.document.title = doc.body.firstChild.textContent;
                    //parse html
                    container = this.template.querySelector('.heading__title');
                    doc = parser.parseFromString(this.copy.headingText__c, 'text/html');
                    container.innerHTML = doc.body.firstChild.textContent;
                    //parse html
                    container = this.template.querySelector('.heading__sub-title');
                    let subHeader = this.copy.subHeaderText__c;
                    if (vehicleModelSeries === 'TLX Type S PMC Edition' && this.copy.subHeaderText__c) {
                        subHeader = this.copy.subHeaderText__c.replace('TLX', 'TLX Type S PMC Edition');
                    }
                    doc = parser.parseFromString(subHeader, 'text/html');
                    container.innerHTML = doc.body.firstChild.textContent
                    //parse html
                    doc = parser.parseFromString(this.copy.buttonText__c, 'text/html');
                    this.buttonLabel = doc.body.firstChild.textContent
                    //parse html
                    container = this.template.querySelector('.byClickingcontainer');
                    doc = parser.parseFromString(this.copy.By_Clicking_Copy__c, 'text/html');
                    container.innerHTML = doc.body.firstChild.textContent;
                    //publish info to Salesforce message service
                    publish(this.messageContext, TAG_PARAMETER_UPDATE, { modelName: this.modelName, modelYear: this.modelYear, bodyStyle: this.bodyStyle });
                    this.pageLoad({ modelName: this.modelName, modelYear: this.modelYear, bodyStyle: this.bodyStyle });
                    this.bigReveal();
                })
                .catch((error) => {
                    this.error = error;
                    this.copy = undefined;
                });//end resCopyList
        } catch (error) {
            this.bigReveal();
            this.showToastMessages('login', 'error', error);
        }
    }//end setupForm
    //big reveal

    bigReveal() {
        try {
            var formWrapper = this.template.querySelector('[data-id="formWrapper"]');
            if (formWrapper) {
                formWrapper.className = 'slds-visible';
            }
        } catch (e) {
            console.error(e);
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        if (this.isConnected && !this.dataloaded) {
            this.newSession();
        }
    }

    extractData() {
        if (this.currentPageReference) {
            let str = this.currentPageReference.state.data;
            if (!str) {
                history.back();
            }
            (str.length % 4 !== 0 && (str += "=".repeat(4 - str.length % 4)))
            str.replace(/-/g, '+').replace(/_/g, '/');
            sessionStorage.setItem('data', str);
            if (this.currentPageReference.state.waitlist === 'y' || this.currentPageReference.state.waitlist === 'true') {
                this.waitlisted = true;
            }
        }
    }

    //login as the guest.
    guestLogin() {
        try {
            if (this.loginRetries >= 5) {
                this.showToastMessages('Error', 'error', 'Internal Error');
                return;
            }
            //login as the guest user, creates user if needed
            const data = sessionStorage.getItem('data');
            doLogin({
                url: `/s/personal-information?data=${data}`,
                isWaitlisted: this.waitlisted,
                retries: this.loginRetries
            })
            // doLogin({
            //     url: '/s/personal-information/',
            //     isWaitlisted: this.waitlisted,
            //     retries: this.loginRetries
            // })
                .then(redirectUrl => {
                    sessionStorage.setItem('loggedIn', 'true');
                    window.location.replace(redirectUrl);
                }).catch(error => {
                    this.loginRetries++;
                    this.guestLogin();
                });//end do login
        } catch (e) {
            this.loginRetries++;
            console.error(e);
            this.guestLogin();
        }
    }//end guest login
    //handle submit button press

    handleSubmit(event) {

        event.preventDefault();
        try {
            this.clickDisabled = true;
            if (!event.detail.fields.Accepted_Terms__c) {
                this.showToastMessages('Error', 'Error', 'You must accept the terms before moving on.');
                this.clickDisabled = false;
                return;
            }
            let val = event.detail.fields.Zip_Code__c;
            const fiveDigitZipRegEx = /^\d{5}$/;
            if (val.length !== 5 || !fiveDigitZipRegEx.test(val)) {
                //   if ( val.length != 5 || ! /^\d+$/.test(val)) {
                this.showToastMessages('Error', 'Error', 'Invalid Zip Code');
                this.clickDisabled = false;
                return;
            }
            val = event.detail.fields.Phone_Number__c;
            if (val) {
                const tenDigitPhoneNoRegEx = /^\d{10}$/;

                if (val.length !== 10 || !tenDigitPhoneNoRegEx.test(val)) {
                    //     if ( val.length < 10 || ! /^\d+$/.test(val)) {
                    this.showToastMessages('Error', 'Error', 'Enter a valid Phone Number');
                    this.clickDisabled = false;
                    return;
                }
            } else {
                this.showToastMessages('Error', 'Error', 'Please fill in phone number.');
                return;
            }
            val = event.detail.fields.Email_Address__c;
            const confirmEmailInput = event.detail.fields.Confirm_Email_Address__c;
            if (val && confirmEmailInput) {
                if (val !== confirmEmailInput) {
                    this.showToastMessages('Error', 'Error', 'Email addresses must match.');
                    this.clickDisabled = false;
                    return;
                }
                if (val.length < 5) {
                    this.showToastMessages('Error', 'Error', 'Invalid Email Length');
                    this.clickDisabled = false;
                    return;
                }

                // const re = /[A-Za-z0-9!#$%&amp;'*+\/=?.\^_`\{\}~\-]{1,63}@[A-Za-z0-9]-?([A-Za-z0-9\.]-|[A-Za-z0-9\.]){0,62}\.[A-Za-z0-9][A-Za-z0-9-]{1,9}/;
                const re = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
                if (!re.test(val)) {
                    this.showToastMessages('Error', 'Error', 'Invalid Email Address');
                    this.clickDisabled = false;
                    return;
                }

                // if (!val.includes('@')) {
                //     this.showToastMessages('Error', 'Error', 'Invalid Email no @');
                //     this.clickDisabled = false;
                //     return;
                // }
                // if (!val.includes('.')) {

                //     this.showToastMessages('Error', 'Error', 'Invalid Email, Domain Missing');
                //     this.clickDisabled = false;
                //     return;
                // }
                /*if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(val)) {
                  return (true)
                }
                  this.showToastMessages('Error', 'Error', 'Invalid Email');
                  this.clickDisabled = false ;
                  return ;
                }*/


            }
        }
        catch (e) {
            console.error(e);
            this.clickDisabled = false;
        }

        try {
            this.clickEvent();
        } catch (e) { }

        //save form data and redirect
        saveFormData({ formData: event.detail.fields })
            .then(recId => {
                sessionStorage.setItem('contactId', recId);
                let data = sessionStorage.getItem('data');
                //decoded
                let decodedData = deCompressJSONString(data);
                const jsonObj = decodedData ? JSON.parse(decodedData) : '';
                const callbackUrl = jsonObj.callbackUrl;
                //save the reservation
                saveReservation({
                    JSONString: decodedData, isWaitlisted: this.waitlisted, contactId: recId, productId: sessionStorage.getItem('productId'),
                    capGroupId: sessionStorage.getItem('capGroupId') === 'undefined' ? null : sessionStorage.getItem('capGroupId')
                })
                    .then(resId => {
                        this.reservationId = resId;
                        //alert('here');
                        startSession({ userId: this.userId, reservationContactId: recId, reservationId: this.reservationId })
                            .then(redirectUrl => {
                                if (!this.isParticipantDealer || this.waitlisted) {
                                    //this.cartId = redirectUrl.slice(redirectUrl.length - 18 ,redirectUrl.length);
                                    postLeadsFromReservation({ reservationId: this.reservationId })
                                        .then(res => {
                                            //semd conformation
                                            sendConfirmation({ reservationId: this.reservationId })
                                                .then(res => {
                                                    //Returns URL based on reservation information
                                                    getReturnUrl({ reservationId: resId })
                                                        .then(jsonDataUrl => {
                                                            const jsonData = jsonDataUrl ? jsonDataUrl.split('?data=')[1] : '';
                                                            const compressedDataUrl = compressJSONString(jsonData);
                                                            const url = `${callbackUrl}?data=${compressedDataUrl}`;
                                                            //window.location.replace("<community-domain>/secur/logout.jsp?retUrl=<redirect-URL>");
                                                            sessionStorage.setItem('loggedIn', 'false');
                                                            this.clickDisabled = false;
                                                            window.location.href = url;
                                                            //this[NavigationMixin.Navigate]({ type: 'standard__webPage',  attributes: { url: url }}) ;
                                                            return;
                                                        })
                                                        .catch(err => { this.clickDisabled = false; })
                                                })
                                                .catch(err => { this.clickDisabled = false; })
                                        })
                                        .catch(err => {
                                            this.clickDisabled = false;
                                            console.error('Post Leads Error ' + err.body.message);
                                            this.showToastMessages('Error', 'error', 'Internal Error Processing Request.  Please try again later')
                                        });
                                } else {
                                    this[NavigationMixin.Navigate]({ type: 'standard__webPage', attributes: { url: redirectUrl } });
                                }
                            }).catch(error => {
                                this.clickDisabled = false;
                                this.showToastMessages('Get Session', 'error', error);
                                console.error(err);
                            });
                    }).catch(error => {
                        this.clickDisabled = false;
                        this.showToastMessages('Save Reservation', 'error', error);
                        console.error(err);
                    });
            }).catch(err => {
                this.clickDisabled = false;
                if (err.body.message === 'session timed out') {
                    this.showToastMessages('Error', 'error', 'Session timed out.  Please try again.');
                    this.newSession();
                    console.error(err);
                    return;
                }
                this.showToastMessages('Save Form Data', 'error', err);
            });
    }//end handle submit

    handleError(event) {
        if (error.detail.message === 'The requested resource does not exist') {
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error creating record',
                message: event,
                variant: 'error',
            }),
        );
    }//end handlError
    //
    showToastMessages(title, variant, error) {
        let message = error;
        if (typeof message !== 'string') {
            message = error.message;
        }
        if (!message) {
            if (error.detail && error.detail.message) {
                message = error.detail.message;
            }
            if (!message && error.body) {
                if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                    message = error.body.pageErrors[0].message;
                } else {
                    if (error.body.message) {
                        message = error.body.message;
                    }
                }
            }
        }
        this.dispatchEvent(new ShowToastEvent({ title: title, variant: variant, message: message, mode: 'dismissable' }));
    }//end show toast message
    //

    goBack() {
        //    if ( sessionStorage.getItem('referrer') && sessionStorage.getItem('referrer') !== 'undefined' && sessionStorage.getItem('referrer').indexOf('?') > 0 && sessionStorage.getItem('referrer').indexOf('modelId') > 0 ){
        //     window.location.href = sessionStorage.getItem('referrer') ;
        //   }
        // else {
        let dataStr = sessionStorage.getItem('data');
        //decoded
        let decodedData = deCompressJSONString(dataStr);
        if (decodedData != null) {
            getBackLink({ data: decodedData })
                .then(res => {
                    window.location.href = res;
                })
                .catch(() => { })
        }
        //}

    }//end goback

    //
    pageLoad(pageLoadData) {
        let Acr
        if (window.Acr) {
            Acr = window.Acr
        } else {
            window.Acr = {}
            Acr = window.Acr
        };
        //
        const { modelName, modelYear, bodyStyle } = pageLoadData;
        //
        const dataLayer = {
            Model: {
                model_brand: 'acura',
                model_name: modelName,
                model_year: modelYear,
                body_style: bodyStyle,
            },
            Page: {
                brand_name: 'Acura',
                full_url: window.location.href,
                page_name: 'Personal Information',
                page_friendly_url: document.querySelector("link[rel='canonical']")?.getAttribute('href') || '',
                referrer_type: document.referrer || 'typed/bookmark',
                internal_referrer: document.referrer.includes('acura') ? document.referrer : '',
                referrer_url: document.referrer.includes('acura') ? '' : document.referrer,
                site_display_format: window.innerWidth < 550 ? 'mobile' : window.innerWidth < 1024 ? 'tablet' : 'desktop',
                site_language_code: document.getElementsByTagName('html')[0].getAttribute('lang').slice(0, 2) || 'en',
                sub_section: 'reserve',
                sub_section2: 'personal information'
            }
        };
        Acr.dataLayer = { ...dataLayer }
        window._satellite.track('page-load');
    }
    //
    clickEvent() {
        let Acr
        if (window.Acr) {
            Acr = window.Acr
        } else {
            window.Acr = {}
            Acr = window.Acr
        };
        //
        const dataLayer = {
            ...Acr.dataLayer,
            EventMetadata: {
                action_label: `personal information:${this.buttonLabel}`,
                action_category: 'personal information',
                action_type: 'cta'
            }
        };
        Acr.dataLayer = { ...dataLayer };
        window._satellite.track('click-event');
    }

    //show terms and coditions
    showTermsAndConditions() {
        const config = {
            type: 'comm__namedPage',
            attributes: {
                name: 'Terms_and_Conditions__c'
            },
            state: { model: this.modelName }
        };
        this[NavigationMixin.GenerateUrl](config)
            .then(url => {
                window.open(url, '_blank');
            });
    }
}
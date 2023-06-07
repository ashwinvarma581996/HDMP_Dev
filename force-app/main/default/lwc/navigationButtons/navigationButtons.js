import { LightningElement, api, wire, track } from 'lwc';
import { FlowNavigationBackEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import goToPreviousScreen from '@salesforce/apex/CartItemsCtrl.redirectToBackScreen';
import communityId from '@salesforce/community/Id';
import { NavigationMixin } from 'lightning/navigation';
import proceedCheckout from '@salesforce/apex/CartItemsCtrl.proceedCheckout';
//for adobe: starts
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';
//for adobe: ends

import getStatusofVertex from '@salesforce/apex/B2B_BTVertexTaxCalculationIntegration.getStatusofVertex'; // Saravanan LTIM for 18902,18901
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  // Saravanan LTIM for 18902,18901

export default class NavigationButtons extends NavigationMixin(LightningElement) {
    @api nextButtonLabel;
    @api nextButtonTitle;
    @api backButtonLabel;
    @api backButtonTitle;
    @api previousState;
    @api nextState;
    @api cartStateId;
    @api orderId;

    @track hideBackButton = false;
    @track hideButton = false;
    @api hideNextButton;
    @api hidePrevButton;
    @track makeDisabled = false;
    @track cart_Id;

    @api triggerDataLayer;//for adobe bug-51
    //for adobe
    @wire(MessageContext)
    messageContext;


    connectedCallback() {
        if (this.nextButtonLabel == 'Proceed to Payment') {

            // Saravanan LTIM Added for 18901 , 18902

            this.getStatusofVertexJs();

            // Saravanan LTIM Ended for 18901 , 18902

        }
        //for adobe: starts
        if (this.triggerDataLayer === undefined || this.triggerDataLayer === true) {//for adobe bug-51
            const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        }
        //for adobe: ends
        var currURL = window.location.href;
        var baseurl = currURL.split('/');
        this.cart_Id = baseurl.pop()
        //console.log('this.cart_Id'+this.cart_Id)      
        if (this.hideNextButton == 'true') {
            this.hideButton = true;
        }
        if (this.hidePrevButton == 'true') {
            this.hideBackButton = true;
        }
        proceedCheckout({ CartId: this.cart_Id }).then(result => {
            //console.log('result'+result)
            if (result.checkoutcomp && result.compat) {
                //console.log('enable block')
                this.makeDisabled = false;
            }
            else {
                this.makeDisabled = true;
                //console.log('disable block')
            }
        }).catch(error => {
            //console.log('error----' , JSON.stringify(error));
        });


    }

    handleNext(event) {
        //console.log('handleNext : ',this.previousState);
        if (this.previousState != 'Checkout Summary') {
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        } else {
            this.dispatchEvent(new CustomEvent('submitorder'));
        }
    }

    handleBack(event) {
        //console.log('back screen----');
        //console.log('this.previousState : ',this.previousState);
        //console.log('this.nextState : ',this.nextState);

        //console.log('this.cartStateId : ',this.cartStateId);
        //console.log('this.orderId : ',this.orderId);




        if (this.previousState && this.nextState) {
            goToPreviousScreen({ pState: this.previousState, nState: this.nextState, cartId: this.cartStateId, orderId: this.orderId })
                .then(result => {
                    if (result == 'OK') {
                        const navigateBackEvent = new FlowNavigationBackEvent();
                        this.dispatchEvent(navigateBackEvent);
                        window.location.reload();
                    }
                })
                .catch(error => {
                    //console.log('error----' + JSON.stringify(error));
                    this.redirectOnCartPage();
                });
        }
        else {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
            // window.location.reload();
        }

    }

    redirectOnCartPage() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": '/s/cart/' + this.cart_Id
            }
        });
    }

    // Saravana LTIM Added to have Vertex status Bug 18902 , 18901
    getStatusofVertexJs() {
        var status = false;
        getStatusofVertex()
            .then(result => {
                if (!result) {
                    this.showToastMessage('Error', 'We’re experiencing technical difficulties, please try again later', 'error');
                    this.makeDisabled = true;
                }
                return result;
            })
            .catch(error => {
                return false;
            });
        return false;
    }

    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // Saravana LTIM Added to have Vertex status Bug 18902 , 18901
}
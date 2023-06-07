import { LightningElement, wire } from 'lwc';
import { DATALAYER_EVENT_TYPE, getDataLayer } from 'c/hdmAdobedtmUtils';
import { subscribe, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
export default class HdmAdobedtmUtilsHelper extends LightningElement {
    @wire(MessageContext)
    messageContext;
    connectedCallback() {
        subscribe(
            this.messageContext,
            HDMP_MESSAGE_CHANNEL,
            (message) => {
                console.log('@data message before if', message, message && message.message && message.message.eventType)
                if (message && message.message && message.message.eventType) {
                    console.log('@data -- message', message)
                    // let messages = message.message;
                    let eventMetadata = {};
                    if (message.message.eventMetadata) {
                        eventMetadata = message.message.eventMetadata;
                    }
                    let delay = false;
                    if (message.message.delay) {
                        delay = message.message.delay;
                    }
                    let page = {};
                    if (message.message.page) {
                        page = message.message.page;
                    }
                    let dealer = {};
                    if (message.message.dealer) {
                        dealer = message.message.dealer;
                    }
                    let findProductDetails = {};
                    if (message.message.findProductDetails) {
                        findProductDetails = message.message.findProductDetails;
                    }
                    let addToCartProductDetails = {};
                    if (message.message.addToCartProductDetails) {
                        addToCartProductDetails = message.message.addToCartProductDetails;
                    }
                    let events = '';
                    if (message.message.events) {
                        events = message.message.events;
                    }
                    let confirmationOrderId = '';
                    if (message.message.confirmationOrderId) {
                        confirmationOrderId = message.message.confirmationOrderId;
                    }
                    let adobedtmObj = { delay: delay, eventType: message.message.eventType, data: { page: page, eventMetadata: eventMetadata, dealer: dealer, findProductDetails: findProductDetails, addToCartProductDetails: addToCartProductDetails, events: events, confirmationOrderId: confirmationOrderId } };
                    this.initializeAdobedtm(adobedtmObj);
                }
            });
        if (!document.location.pathname.includes('/category') && !document.location.pathname.includes('/checkout')) {
            let adobedtmObj = { delay: false, eventType: DATALAYER_EVENT_TYPE.LOAD, data: { eventMetadata: {} } };
            this.initializeAdobedtm(adobedtmObj);
        }

    }
    initializeAdobedtm = async (adobedtmObj) => {
        if (adobedtmObj.delay) {
            await this.sleep(6000);
        }
        let dataLayer = await getDataLayer(adobedtmObj.data);
        const adobedtmEvent = new CustomEvent('adobedtm', {
            detail: {
                eventType: adobedtmObj.eventType,
                data: JSON.parse(JSON.stringify(dataLayer))
            },
            bubbles: true,
            composed: true
        });
        console.log('@ data dataLayer helper', JSON.stringify(dataLayer))
        this.dispatchEvent(adobedtmEvent);
    };

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
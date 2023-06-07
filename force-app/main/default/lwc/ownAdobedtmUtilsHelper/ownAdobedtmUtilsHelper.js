import { LightningElement, track } from 'lwc';
import { DATALAYER_EVENT_TYPE, getDataLayer } from 'c/ownAdobedtmUtils';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnAdobtmUtilsHelper extends OwnBaseElement {
    @track ss = false;
    connectedCallback() {
        //console.log('OwnAdobtmUtilsHelper', document.location.pathname);
        // window.addEventListener('popstate', async function (event) {
        //     console.log('@data GH CB')
        //     if (sessionStorage.getItem('currentFullURL')) {
        //         sessionStorage.setItem('referrer', sessionStorage.getItem('currentFullURL'));
        //     }
        // }, false);
        this.subscribeToChannel((message) => {
            if (message && message.eventType) {
              //  console.log('@message', message)
                let eventMetadata = {};
                if (message.eventMetadata) {
                    eventMetadata = message.eventMetadata;
                }
                let delay = false;
                if (message.delay) {
                    delay = message.delay;
                }
                let page = {};
                if (message.page) {
                    page = message.page;
                }
                let dealer = {};
                if (message.dealer) {
                    dealer = message.dealer;
                }
                let findProductDetails = {};
                if (message.findProductDetails) {
                    findProductDetails = message.findProductDetails;
                }
                let adobedtmObj = { delay: delay, eventType: message.eventType, data: { page: page, eventMetadata: eventMetadata, dealer: dealer, findProductDetails: findProductDetails } };
                this.initializeAdobedtm(adobedtmObj);
            }
        });
        let adobedtmObj = { delay: false, eventType: DATALAYER_EVENT_TYPE.LOAD, data: { eventMetadata: {} } };
        this.initializeAdobedtm(adobedtmObj);
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
       // console.log('@dataLayer', JSON.stringify(dataLayer))

        this.dispatchEvent(adobedtmEvent);
    };
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
//============================================================================
// Title:    Honda Owners Experience - Common Base Element
// Summary:  Common logic to support Honda's Salesforce Community for Owners Experience
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein
//
// Sample Usage:
// 1) add this line into the js of your lwc 
// 2) when you need access to Messaging Channel, add these lines into your .js code:
// * import getContext from '@salesforce/apex/ownContext.getContext';
//      1) const util = this.template.querySelector('[data-id="ownUtilities"]');
//      2) let userId = util.userId;
// 2b) or add this line into your .js code:
//      1) let userId = ownUtilities.userId;
//			
//--------------------------------------------------------------------------------------
//
// History:
// April 9, 2021 Jim Kohs (Wipro) DOE-zzz Initial coding
// May 19, 2021 Jim Kohs (Wipro) Added ref in init() to Static Var css 
//===========================================================================
import { LightningElement, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { generateNavigationTarget } from "c/ownNavigationUtility";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import OWNERS_MESSAGE_CHANNEL from "@salesforce/messageChannel/OwnersMessageChannel__c";

//unused (yet)
//import { loadScript } from 'lightning/platformResourceLoader';
import { loadStyle } from "lightning/platformResourceLoader";
//import { getObjectInfo } from "lightning/uiObjectInfoApi";

// Static Resources
//import sampleJSMin from '@salesforce/resourceUrl/sampleJSMin';
import commonResources from "@salesforce/resourceUrl/Owners";
import commonStyle from "@salesforce/resourceUrl/MyGarageCSS";
import myGarageResources from "@salesforce/resourceUrl/MyGarage";
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';


//constants
export const MESSAGETYPE_REFRESH = 'Refresh Context';

import {
    subscribe,
    publish,
    MessageContext,
    unsubscribe,
    APPLICATION_SCOPE,
} from "lightning/messageService";

import basePath from '@salesforce/community/basePath';

export class OwnBaseElement extends NavigationMixin(LightningElement) {
    get_MESSAGETYPE_REFRESH() { return MESSAGETYPE_REFRESH; }

    @wire(MessageContext)
    messageContext;

    // If a derived component has its own constructor, call this directly in connectedCallback
    initialize = async () => {
        await loadStyle(this, `${commonStyle}/variable.css`);
        await loadStyle(this, `${commonStyle}/main.css`);
        // console.log('*** in OwnBaseElement.initialize()');
    };

    constructor() {
        super();
        //this.initialize();
    }

    //connectedCallback() { 
    //Promise.all([
    //    loadScript(this, sampleJSMin),
    //]).then(() => { /* callback */ });
    //}

    @api getUserId() {
        //alert('in ownUtilities utils getUserId() - userId:' + userId ); 
        return Id;
    }

    subscription;
    subscribeToChannel(callback) {
        this.subscription = subscribe(
            this.messageContext,
            OWNERS_MESSAGE_CHANNEL,
            (message) => {
                if (callback) {
                    callback(message);
                }
            },
            { scope: APPLICATION_SCOPE }
        );
    }

    publishToChannel(message) {
        publish(this.messageContext, OWNERS_MESSAGE_CHANNEL, message);
    }

    disconnectedCallback() {
        if (this.subscription && unsubscribe) {
            unsubscribe(this.subscription);
        }
    }

    async navigate(targetString, context = {}) {
        const navigationTarget = generateNavigationTarget(targetString, context);
        if (navigationTarget.isModal) {
            this.publishToChannel({
                actionType: "showModal",
                recipient: "auraActionHandler",
                target: navigationTarget,
            });
        } else {
            this[NavigationMixin.Navigate](navigationTarget);
        }

        if (navigationTarget && navigationTarget.attributes && navigationTarget.attributes.url && !(navigationTarget.attributes.url.includes('https') || navigationTarget.attributes.url.includes('http'))) {
            sessionStorage.setItem('referrer', document.location.href);
            // if (targetString.includes('/article')) {
            //     let message = { delay: true, eventType: DATALAYER_EVENT_TYPE.LOAD };
            //     this.publishToChannel(message);
            // }
        }
    }

    showToast_error(message) {
        //Doc: mode: dismissable (default), remains visible until you click the close button or 3 seconds has elapsed, whichever comes first; pester, remains visible for 3 seconds and disappears automatically. No close button is provided; sticky, remains visible until you click the close button.
        //info (default), success, warning, and error.

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error!',
                message: message,
                variant: 'error',
                mode: 'dismissable '
            }),
        );
    }
    showToast_success(message) {
        //Doc: mode: dismissable (default), remains visible until you click the close button or 3 seconds has elapsed, whichever comes first; pester, remains visible for 3 seconds and disappears automatically. No close button is provided; sticky, remains visible until you click the close button.
        //info (default), success, warning, and error.
        console.log('*** showing success toast');
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success!',
                message: message,
                variant: 'success',
                mode: 'dismissable '
            }),
        );
    }

    ownerResource() {
        return commonResources;
    }
    commonStyle() {
        return commonStyle;
    }
    myGarageResource() {
        return myGarageResources;
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }
    getUrlParameters() {
        let href = window.location.href;
        let urlParameters = {};
        if (href.includes('?')) {
            href = href.substring(href.indexOf('?') + 1).includes('&') ? href.substring(href.indexOf('?') + 1).split('&') : href.substring(href.indexOf('?') + 1).split('=').join('=');
            href = Array.isArray(href) ? href : [href];
            href.forEach(param => {
                param = param.split('=');
                urlParameters[param[0]] = param[1];
            });
        }
        return urlParameters;
    }
    buildAdobeMessage(url, eventMetadata) {
        let message = { eventMetadata: eventMetadata };
        if (url.includes('.pdf') || url.includes('.PDF')) {
            message.eventMetadata.download_title = eventMetadata.action_label;
            message.eventType = DATALAYER_EVENT_TYPE.DOWNLOAD_EVENT;
        } else if ((url.includes('https') || url.includes('http')) && (!url.includes('.pdf') || !url.includes('.PDF'))) {
            message.page = { destination_url: url }
            message.eventType = DATALAYER_EVENT_TYPE.EXIT_EVENT;
        } else {
            message.eventType = DATALAYER_EVENT_TYPE.CLICK;
        }
        return message;
    }
}
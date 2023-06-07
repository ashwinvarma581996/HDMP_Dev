import { LightningElement, api, wire, track } from 'lwc';
import {subscribe, unsubscribe, APPLICATION_SCOPE,MessageContext} from 'lightning/messageService';
import categorySelected from '@salesforce/messageChannel/Category_Selected__c';


export default class B2bEBCategoryBanner extends LightningElement {
    @api recordId;

    @api titleSize;

    @api titleColor;

    @api descriptionSize;

    @api descriptionColor;

    @api ctaAlignment;

    @api ctaButtonColor;

    @api ctaButtonTextColor;

    @api ctaButtonTextSize;

    @api ctaButtonLabel;

    subscription = null;
    @track noCategorykey = true;

    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                categorySelected,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Handler for message received by component
    handleMessage(message) {
        this.noCategorykey = message.categoryKey;
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
}
import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { ISGUEST, getProductContext, getContext, getOrigin } from 'c/ownDataUtils';
import getEmissionWarrantyBooklet from '@salesforce/apex/OwnAPIController.getEmissionWarrantyBooklet';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnWarrantyBookletCardAutos extends OwnBaseElement {
    isGuest = ISGUEST;
    @track body = 'The warranty booklet has detailed information about the coverage and terms of your warranties.';
    @track title;
    @api headerLink;
    titlecolor = 'Honda Red';
    @api actionIcon = '';
    @api icon = '';
    url = '';
    get titleClass() {
        return 'slds-text-heading_small title red';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback() {
        this.initialize();
    }


    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        this.title = this.context.product.year + ' ' + this.context.product.model + ' ' + 'WARRANTY BOOKLET';
        let icon;
        let actionIcon;
        if (this.isGuest) {
            icon = 'adobe-pdf.svg';
            actionIcon = 'download.svg'
        } else {
            icon = 'document.svg';
            actionIcon = 'download.svg';
        }
        this.icon = this.myGarageResource() + '/ahmicons/' + icon;
        if (actionIcon !== '') {
            this.actionIcon = this.myGarageResource() + '/ahmicons/' + actionIcon;
        }
        //this.headerLink = sessionStorage.getItem('warrantyBookletURL');

    }
    async handleHeader() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = this.buildAdobeMessage(this.headerLink, eventMetadata);
        this.publishToChannel(message);
        await this.sleep(2000);
        this.navigate(this.headerLink, '_blank', {});
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
//============================================================================
// Title:    Honda Owners Experience - Warranty Booklet Card
//
// Summary:  This Card links to the Warranty Booklet
//
// History:
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { ISGUEST, getProductContext, getContext, getOrigin } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
import basePath from '@salesforce/community/basePath';

export default class ownWarrantyBookletCard extends OwnBaseElement {
    @api contentid;
    @api brand;
    @api bookletUrl;
    @api icon = "black-booklet.svg";
    @api title;
    @api titlecolor = 'Honda Red';
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    @track productTitle = '';
    @track alertlabel = '';
    @api BrandName;

    get titleClass() {
        return 'slds-text-heading_small title red';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
        this.productTitle = this.alertlabel + " WARRANTY BOOKLET";
    }


    initialize = async () => {
        //console.log('Content Id', this.contentid);
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext();
        }
        this.alertlabel = this.context.product.year + " " + this.context.product.model;
        this.contentKeys.push(this.contentid);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value);
            //console.log('status', this.body.includes('PRODUCTMODELVALUE'))
            if (this.body.includes('PRODUCTMODELVALUE')) {
                this.body = this.body.replace('PRODUCTMODELVALUE', this.alertlabel);
            }
        });
        // this.context = await getContext('');

        //console.log('context=', JSON.stringify(this.context));

        this.productTitle = this.alertlabel + " WARRANTY BOOKLET";

    }


    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
    handleHeader() {
        this.navigate('/warranty-info', '_blank', {});
    }

    handleHeaderClick() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.productTitle
        };
        let message = this.buildAdobeMessage(this.bookletUrl, eventMetadata);
        this.publishToChannel(message);
        //console.log('$EW-BookletUrl', this.bookletUrl);
        window.open(this.bookletUrl, "_blank");
    }
}
import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { ISGUEST, getProductContext, getContext } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
import warranties from '@salesforce/resourceUrl/warranties';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnWarrantyCardMarine extends OwnBaseElement {

    @api contentid;
    @api brand;
    @api icon;
    @api title;
    @api titlecolor = 'Honda Red';
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    @track title;
    @api headerLink;
    @api actionIcon;
    @api link;
    isGuest = ISGUEST;

    get titleClass() {
        return 'slds-text-heading_small title red';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if (this.actionIcon !== '') {
            this.actionIcon = this.myGarageResource() + '/ahmicons/' + this.actionIcon;
        }
        this.initialize();
    }


    initialize = async () => {
        //console.log('Content Id', this.contentid);
        this.contentKeys.push(this.contentid);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value);
            if (r.downloadLink) {
                // this.headerLink = window.location.origin + '/sfsites/c/resource/warranties' + this.htmlDecode(r.downloadLink.value);
                this.headerLink = window.location.origin + warranties + r.downloadLink.value;
            }
        });
        // this.headerLink = window.location.origin + '/sfsites/c/resource/warranties' + this.link;
        //console.log("link", this.headerLink);
        this.context = await getContext('');
        //console.log('context=', JSON.stringify(this.context));
    }


    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
    handleHeader() {
        // this.navigate(this.headerLink, '_blank', {});
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = this.buildAdobeMessage(this.headerLink, eventMetadata);
        this.publishToChannel(message);
        let isMobile = window.matchMedia("(max-width: 600px)").matches;
        if (isMobile) {
            window.open(this.headerLink, "_blank");
        } else {
            let pdfLink = this.headerLink;
            sessionStorage.setItem('pdflink', pdfLink);
            window.open(window.location.origin + window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/')) + '/pdf-document' + '?PDF=' + pdfLink.substring(pdfLink.lastIndexOf('/') + 1), "_blank");
        }
    }
    handleAction() {
        this.navigate(this.headerLink, '_blank', {});
    }



}
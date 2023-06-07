import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { ISGUEST, getProductContext, getContext } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
export default class ownWarrantyCard extends OwnBaseElement {

    @api contentid;
    @api brand;
    @api icon;
    @api title;
    @track headerClickable = true;
    @api titlecolor = 'Honda Red';
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track downloadLabel;
    @track managedContentType = '';
    @track results;
    @track body;
    @track title;
    @api headerLink;
    @api actionIcon;
    @api showWarrantyLink;
    isGuest = ISGUEST;
    @api showActionIconLoggedIn;
    @api showActionIconLoggedOut;
    get titleClass() {
        return 'slds-text-heading_small title red';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback() {
        if (this.showWarrantyLink) {
            this.titlecolor = 'Honda Black';
            this.headerClickable = false;
        }
        //console.log('$EW - icon1', this.icon)
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        //console.log('$EW - icon', this.icon)
        if (this.actionIcon !== '') {
            this.actionIcon = this.myGarageResource() + '/ahmicons/' + this.actionIcon;
        }
        this.initialize();
    }


    initialize = async () => {
        //console.log('Content Id', this.contentid);
        this.contentKeys.push(this.contentid);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('@RESS: ', JSON.parse(JSON.stringify(this.results)));
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value);
            this.downloadLabel = this.htmlDecode(r.downloadLabel.value);
        });
        this.context = await getContext('');
        //console.log('context=', JSON.stringify(this.context));
    }


    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
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
        if (this.headerLink && this.headerLink.startsWith('/tips-marine') || this.headerLink.startsWith('/tips-power-equipment')) {
            sessionStorage.setItem('frompage', document.location.pathname.toLowerCase());
            if (document.location.pathname.toLowerCase().includes('garage-marine')) {
                sessionStorage.setItem('tipsDefaultCategory', 'MarineFuelRecommendations');
            }
            else {
                sessionStorage.setItem('tipsDefaultCategory', '');
            }
            this.navigate(this.headerLink, '_blank', {});
        } else {
            //console.log('$EW headerlink', this.headerLink)
            sessionStorage.setItem('scroll', 'tire-warranty-section');
            this.navigate(this.headerLink, '_blank', {});
        }

    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    handleAction() {
        sessionStorage.setItem('scroll', 'tire-warranty-section');
        this.navigate(this.headerLink, '_blank', {});
    }

    handleLinkClick() {
        if (this.brand == 'Marine') {
            let backLink = {
                label: 'Help Center: Marine',
                url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
            };
            sessionStorage.setItem('backlink', JSON.stringify(backLink));
            this.navigate('/warranty-info?help=marine', {});
        } else if (this.brand == 'Powerequipment') {
            let backLink = {
                label: 'Help Center: Power Equipment',
                url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
            };
            sessionStorage.setItem('backlink', JSON.stringify(backLink));
            this.navigate('/warranty-search?brand=powerequipment', {});
        }
    }

}
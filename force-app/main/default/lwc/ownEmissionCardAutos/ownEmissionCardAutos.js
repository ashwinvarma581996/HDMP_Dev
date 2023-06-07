import { LightningElement, api, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { ISGUEST } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class ownEmissionCardAutos extends OwnBaseElement {
    @api contentId;
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
    @track headerLink;
    @api actionIcon;
    @api divisionName;
    @track userState;
    @api downloadLink;
    isGuest = ISGUEST;
    context;

    connectedCallback() {
        this.initialize();
    }

    initialize = async () => {
        let icon;
        let actionIcon = '';
        if (this.isGuest) {
            icon = 'adobe-pdf.svg';
            actionIcon = 'download.svg'
        } else {
            icon = 'download.svg';
        }
        this.icon = this.myGarageResource() + '/ahmicons/' + icon;
        if (actionIcon !== '') {
            //console.log('$EWactionIcon', actionIcon)
            this.actionIcon = this.myGarageResource() + '/ahmicons/' + actionIcon;
        }
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value);
        });
        // this.downloadLink = sessionStorage.getItem('emissionWarrantyURL');
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
        let message = this.buildAdobeMessage(this.downloadLink, eventMetadata);
        this.publishToChannel(message);
        sessionStorage.setItem('scroll', 'emission-warranty-section');
        await this.sleep(2000);
        if (this.downloadLink.includes("/warranty-info")) {
            this.navigate(this.downloadLink, {});
        } else {
            window.open(this.downloadLink, "_blank");

        }
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
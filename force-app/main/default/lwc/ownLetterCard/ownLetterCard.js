//============================================================================
// Title:    Honda MyGarage Experience - Send A Letter Card
//
// Summary:  Send A Letter Card for Help-'brand' pages
//
// Details:  This is the Send A Letter Card seen at the page of the Help-'brand' pages
//
// History:
// October 11, 2021 Ravindra Ravindra (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import {
    getManagedContentByTopicsAndContentKeys,
} from 'c/ownDataUtils';

export default class OwnLetterCard extends OwnBaseElement {
    @api contentId;
    @api brand;
    @api icon;
    @api title;
    @api titlecolor;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }

    handleAddressClick() {
        let bingAddressLink = 'https://www.bing.com/maps/?v=2&where1= ';
        bingAddressLink += this.convertToAddress(this.body);
        this.navigate(bingAddressLink, {});
    }

    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value);
        });
    }

    convertToAddress(rtf) {
        rtf = rtf.replaceAll('&nbsp;', " ");
        rtf = rtf.replaceAll('<p>', "")
        return rtf.replaceAll('</p>', " ").trim();
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
}
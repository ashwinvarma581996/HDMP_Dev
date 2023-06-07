//============================================================================
// Title:    Honda MyGarage Experience - CMS Card
//
// Summary:  This is the CMS Card html seen at the page of the Honda MyGarage Community
//
// Details:  CMS Card for pages
//
// History:
// October 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';

export default class OwnCMSCard extends OwnBaseElement {
    @api contentId;
    @api brand;
    @api icon;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api showforwardicon;
    @api showfooter;
    @api addressContentId;
    @track address;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    @track phoneFields = [];
    @track showPhoneLabel = false;
    @track showPhoneNumber = false;
    @track showPhone2Label = false;
    @track showPhone2Number = false;
    @track phoneLabel;
    @track phoneNumber;
    @track phone2Label;
    @track phone2Number;
    @track phoneNumberReadOnly = false;
    @track phone2NumberReadOnly = false;

    get bodyClass() {
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
    }

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }
    connectedCallback() {
        //console.log(window.getSearchEngine());
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }

    handleAddressClick() {
        let bingAddressLink = 'https://www.bing.com/maps/?v=2&where1= ';
        bingAddressLink += this.convertToAddress(this.address);
        this.navigate(bingAddressLink, {});
    }

    convertToAddress(rtf) {
        rtf = rtf.replaceAll('&nbsp;', " ");
        rtf = rtf.replaceAll('<p>', "")
        return rtf.replaceAll('</p>', " ").trim();
    }

    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.contentKeys.push(this.addressContentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            if (r.title.value.toLowerCase().includes('address')) {
                //console.log('Inside if', r.body.value);
                this.address = this.htmlDecode(r.body.value);
            } else {
               
                this.title = this.title ? this.title : this.htmlDecode(r.title.value);
                this.body = this.htmlDecode(r.body.value);
                if (r.phoneLabel) {
                    this.phoneLabel = this.htmlDecode(r.phoneLabel.value);
                    this.showPhoneLabel = true;
                }
                if (r.phoneNumber) {
                    this.phoneNumber = r.phoneNumber.value;
                    this.showPhoneNumber = true;
                }

                if (this.showPhoneLabel || this.showPhoneNumber) {
                    this.phoneFields.push({
                        label: this.phoneLabel,
                        value: this.phoneNumber,
                        readonly: this.phoneLabel ? this.phoneLabel.toLowerCase().includes('fax') ? true : false : false,
                        showLabel: this.showPhoneLabel,
                        showValue: this.showPhoneNumber
                    });
                }

                if (r.phone2Label) {
                    this.phone2Label = this.htmlDecode(r.phone2Label.value);
                    this.showPhone2Label = true;
                }
                if (r.phone2Number) {
                    this.phone2Number = r.phone2Number.value;
                    this.showPhone2Number = true;
                }

                if (this.showPhone2Label || this.showPhone2Number) {
                    this.phoneFields.push({
                        label: this.phone2Label,
                        value: this.phone2Number,
                        readonly: this.phone2Label ? this.phone2Label.toLowerCase().includes('fax') ? true : false : false,
                        showLabel: this.showPhone2Label,
                        showValue: this.showPhone2Number
                    });
                }

            }
        });
    };

    handleClickHeader() {
        this.navigate(this.headerlink, {});
    }

    handleClickAction() {

    }

    handleClickFooter() {

    }
    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
}
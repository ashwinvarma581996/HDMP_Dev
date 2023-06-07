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
import { ISGUEST, getProductContext, getOrigin, getContext, getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

const HONDA_HELP_LABEL = 'Honda Autos Help Center';
const ACURA_HELP_LABEL = 'Acura Autos Help Center';
const POWERSPORTS_HELP_LABEL = 'Honda Powersports Help Center';
const POWEREQUIPMENT_HELP_LABEL = 'Honda Power Equipment Help Center';
const MARINE_HELP_LABEL = 'Honda Marine Help Center';

const HONDA_HELP_VALUE = 'Help Honda';
const ACURA_HELP_VALUE = 'Help Acura';
const POWERSPORTS_HELP_VALUE = 'Help Powersports';
const POWEREQUIPMENT_HELP_VALUE = 'Help Power Equipment';
const MARINE_HELP_VALUE = 'Help Marine';

const HONDA_HELP_URL = '/help-honda';
const ACURA_HELP_URL = '/help-acura';
const POWERSPORTS_HELP_URL = '/help-powersports';
const POWEREQUIPMENT_HELP_URL = '/help-powerequipment';
const MARINE_HELP_URL = '/help-marine';

export default class ownHelpRoadsideAssistanceCard extends OwnBaseElement {
    @api contentId;
    @api brand;
    @api division;
    @api icon;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api showforwardicon;
    @api showfooter;
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
    @track showPhone3Label = false;
    @track showPhone3Number = false;
    @track showPhone4Label = false;
    @track showPhone4Number = false;
    @track phoneLabel;
    @track phoneNumber;
    @track phone2Label;
    @track phone2Number;
    @track phone3Label;
    @track phone3Number;
    @track phone4Label;
    @track phone4Number;
    @track phoneNumberReadOnly = false;
    @track phone2NumberReadOnly = false;
    @track phone3NumberReadOnly = false;
    @track phone4NumberReadOnly = false;
    @track breadcrumb;
    @track showColon = false;
    @track context;
    @track hideCard;

    get bodyClass() {
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
    }

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : this.titlecolor === 'Black' ? 'slds-text-heading_small title black' : 'slds-text-heading_small title';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }
    connectedCallback() {
        let label;
        let url;
        let value;
        switch (this.division) {
            case 'Honda':
                label = HONDA_HELP_LABEL;
                url = HONDA_HELP_URL;
                value = HONDA_HELP_VALUE;
                break;
            case 'Acura':
                label = ACURA_HELP_LABEL;
                url = ACURA_HELP_URL;
                value = ACURA_HELP_VALUE;
                break;
            case 'Powersports':
                label = POWERSPORTS_HELP_LABEL;
                url = POWERSPORTS_HELP_URL;
                value = POWERSPORTS_HELP_VALUE;
                break;
            case 'Power Equipment':
                label = POWEREQUIPMENT_HELP_LABEL;
                url = POWEREQUIPMENT_HELP_URL;
                value = POWEREQUIPMENT_HELP_VALUE;
                break;
            case 'Marine':
                label = MARINE_HELP_LABEL;
                url = MARINE_HELP_URL;
                value = MARINE_HELP_VALUE;
                break;
        }
        let breadcrumb = { label: label, value: value, url: url, type: '' };
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        localStorage.setItem('breadcrumb', JSON.stringify(breadcrumb));
        this.initialize();
    }

    initialize = async () => {
        if (window.location.href.includes("service-maintenance")) {
            //console.log("$HRA: -YES");
            let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
            if (fromProductChooser) {
                this.context = await getProductContext('', true);
            } else {
                this.context = await getContext('');
            }
            //console.log("$HRA: Context-", JSON.parse(JSON.stringify(this.context)));
            if (this.context && this.context.product && this.context.product.year) {
                let year = parseInt(this.context.product.year);
                //console.log("$HRA: Year-", year);
                if (year < 2015) {
                    //console.log("$HRA: Older-", year);
                    this.hideCard = true;
                }
            }
        }
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
            this.showColon = this.body.includes('Acura') ? true : false;
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
                    showValue: this.showPhoneNumber,
                    showColon: this.showColon
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

            if (r.phone3Label) {
                this.phone3Label = this.htmlDecode(r.phone3Label.value);
                this.showPhone3Label = true;
            }
            if (r.phone3Number) {
                this.phone3Number = r.phone3Number.value;
                this.showPhone3Number = true;
            }

            if (this.showPhone3Label || this.showPhone3Number) {
                this.phoneFields.push({
                    label: this.phone3Label,
                    value: this.phone3Number,
                    readonly: this.phone3Label ? this.phone3Label.toLowerCase().includes('fax') ? true : false : false,
                    showLabel: this.showPhone3Label,
                    showValue: this.showPhone3Number
                });
            }

            if (r.phone4Label) {
                this.phone4Label = this.htmlDecode(r.phone4Label.value);
                this.showPhone4Label = true;
            }
            if (r.phone4Number) {
                this.phone4Number = r.phone4Number.value;
                this.showPhone4Number = true;
            }

            if (this.showPhone4Label || this.showPhone4Number) {
                this.phoneFields.push({
                    label: this.phone4Label,
                    value: this.phone4Number,
                    readonly: this.phone4Label ? this.phone4Label.toLowerCase().includes('fax') ? true : false : false,
                    showLabel: this.showPhone4Label,
                    showValue: this.showPhone4Number
                });
            }
        });
    };

    async handleClickHeader() {
        let label;
        if (window.location.href.includes('help-honda')) {
            label = 'Help Center: Honda';
        } else if (window.location.href.includes('help-acura')) {
            label = 'Help Center: Acura';
        } else if (window.location.href.includes('service')) {
            label = 'Service & Maintenance';
        } else {
            label = 'Overview';
        }
        let backLink = {
            label: label,
            url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
        };
        sessionStorage.setItem('backlink', JSON.stringify(backLink));
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = this.buildAdobeMessage(this.headerlink, eventMetadata)
        this.publishToChannel(message);
        await this.sleep(2000);
        this.navigate(this.headerlink, {});
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
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
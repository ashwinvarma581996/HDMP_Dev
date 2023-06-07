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
import getKavBasedOnUrlName from '@salesforce/apex/OwnHelpCenterController.getKavBasedOnUrlName';
import { ISGUEST, getProductContext, setProductContextUser, getOrigin, getRecalls } from 'c/ownDataUtils';

import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
import dreamShopIDPLoginURL	from '@salesforce/label/c.DreamShopIDPLoginURL';

export default class OwnCMSCard extends OwnBaseElement {
    @track context;
    @api contentId;
    @api brand;
    @api icon;
    @api iconright;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api showforwardicon;
    @api headerRightIcon = 'utility:forward';
    @api forwardiconright;
    @api showfooter;
    @api actionButton;
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
    @track mainCardClass = 'card card-size card-styles-wrapper diff-cms-card';
    @track customBodyHeight = '';
    @track isCustomTitle;
    @track showCard = true;

    get bodyClass() {
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body' + this.customBodyHeight;
    }

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get customTitleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small customtitle red' : 'slds-text-heading_small customtitle';
    }

    get iconClass() {
        let colorClass = this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
        if (this.forwardiconright) {
            colorClass += ' forward-icon-right';
        }
        return colorClass;
    }
    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if (document.title == 'HondaLink Features' || document.title == 'Acuralink Connected Features') {
            this.mainCardClass = 'card card-size card-styles-wrapper diff-cms-card connected-features-tab-div';
        }
        this.initialize();
    }


    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        if (getOrigin() == 'ProductChooser' || ISGUEST) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            if (this.title == 'AcuraLink Legal Terms' || this.title == 'HondaLink Legal Terms') {
                this.customBodyHeight = ' custom-body-height ';
            }
            if(this.title === 'myQ CONNECTED GARAGE'){
                this.isCustomTitle = true;
                this.title = this.title.replace('GARAGE', 'GARAGE<sup class="supTop">beta</sup>');
            }
            if(this.title && this.title.toLowerCase().includes('google built-in')){
                let modelId = this.context.product.modelId;
                if(modelId === 'CY2F8PKNW'){
                    this.showCard = true;
                }else{
                    this.showCard = false;
                }
            }
            this.body = this.htmlDecode(r.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
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
            if (r.downloadLink) {
                this.downloadLink = r.downloadLink.value;
                if (document.title.includes('Collision Repair')) {
                    this.headerlink = this.downloadLink;
                }

            }
        });
    };

    async handleClickHeader() {
        //console.log('ownCMSCard this.headerlink', this.headerlink);

        if (this.headerlink && this.headerlink.startsWith('KA:#')) {
            var headerArray = this.headerlink.split(":#");
            if (!document.location.pathname.includes('powersports-product-connected-features')) {
                if (headerArray.length > 2) {
                    this.headerlink = '/article/' + headerArray[1] + '?' + 'brand=' + headerArray[2];
                } else {
                    this.headerlink = '/article/' + headerArray[1];
                }
            } else {
                if (getOrigin() == 'ProductChooser' || ISGUEST) {
                    this.context = await getProductContext('', true);
                } else {
                    this.context = await getProductContext('', false);
                }
                var cmpTitle = this.title.replaceAll(' ', '-').toLowerCase();
                var cmpmodel = this.context.product.model.toLowerCase().replaceAll(' ', '-');
                var modelSelected = '';
                if (cmpmodel.includes('gold-wing')) {
                    modelSelected = 'gold-wing';
                } else if (cmpmodel.includes('africa-twin')) {
                    modelSelected = 'africa-twin';
                }
                //console.log('@@' + cmpTitle + '@@' + cmpmodel + '@@' + modelSelected);
                for (var i = 0; i < headerArray.length; i++) {
                    if (headerArray[i].toLowerCase().includes(cmpTitle) && headerArray[i].toLowerCase().includes(modelSelected)) {
                        this.headerlink = '/article/' + headerArray[i];
                       // console.log('@@' + this.headerlink);
                    }
                }

            }

        }
        else if (this.headerlink && this.headerlink.startsWith('/power-equipment-serial-number-locator')) {
            sessionStorage.setItem('backlink', JSON.stringify({ label: 'Resources & Downloads', url: '/honda-power-equipment-resources-downloads' }));
        }
        else if (this.headerlink && this.headerlink.startsWith('/marine-serial-number-help')) {
            sessionStorage.setItem('frompage', 'Resources & Downloads');
        } else if (this.headerlink && this.headerlink.startsWith('/how-to-guides')) {
            let label;
            let url;
            if (document.location.pathname.includes('acura-service-maintenance')) {
                label = 'Service & Maintenance';
                url = '/acura-service-maintenance';
            } else if (document.location.pathname.includes('honda-service-maintenance')) {
                label = 'Service & Maintenance';
                url = '/honda-service-maintenance';
            } else if (document.location.pathname.includes('acura-resources-downloads')) {
                label = 'Resources & Downloads';
                url = '/acura-resources-downloads';
            } else if (document.location.pathname.includes('honda-resources-downloads')) {
                label = 'Resources & Downloads';
                url = '/honda-resources-downloads';
            } else if (document.location.pathname.includes('garage-acura')) {
                label = 'Overview';
                url = '/garage-acura';
            } else if (document.location.pathname.includes('garage-honda')) {
                label = 'Overview';
                url = '/garage-honda';
            }
            let fromPage = [{ label: label, url: url }];
            sessionStorage.setItem('fromhowtoguides', JSON.stringify(fromPage));

        } else if (this.headerlink && this.headerlink.startsWith('/acura-accelerated-service')) {
            sessionStorage.setItem('frompage', document.title.toLowerCase());
        } else if (this.headerlink && this.headerlink.startsWith('/tips-marine') || this.headerlink.startsWith('/tips-power-equipment')) {
            sessionStorage.setItem('frompage', document.location.pathname.toLowerCase());
            if (document.location.pathname.toLowerCase().includes('garage-marine')) {
                sessionStorage.setItem('tipsDefaultCategory', 'MarineFuelRecommendations');
            }
            else {
                sessionStorage.setItem('tipsDefaultCategory', '');
            }
        }
        if(this.headerlink && (this.headerlink.startsWith('https://staging.dreamshop.honda.com/s/') || this.headerlink.startsWith('https://dreamshop.honda.com/s/')) && !ISGUEST){
            this.headerlink = dreamShopIDPLoginURL + '&RelayState=' + this.headerlink;
        }
        if (this.titlecolor === 'Honda Red') {
            let eventMetadata = {
                action_type: 'link',
                action_category: 'body',
                action_label: this.title
            };
            let message = this.buildAdobeMessage(this.headerlink, eventMetadata);
            this.publishToChannel(message);
            //console.log('ownCMSCard adobe');
        }
        await this.sleep(2000);
        this.navigate(this.headerlink, {});
    }

    async handleClickAction() {

        if(this.headerlink && (this.headerlink.startsWith('https://staging.dreamshop.honda.com/s/') || this.headerlink.startsWith('https://dreamshop.honda.com/s/')) && !ISGUEST){
            this.headerlink = dreamShopIDPLoginURL + '&RelayState=' + this.headerlink;
        }
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: this.title + (this.actionButton ? ':' + this.actionButton : '')
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        await this.sleep(2000);
        this.navigate(this.headerlink, {});
    }

    handleClickFooter() {

    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
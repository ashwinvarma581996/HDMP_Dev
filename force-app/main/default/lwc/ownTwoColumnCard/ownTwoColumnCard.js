import { track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
import { getGarageURL, ISGUEST, getProductContext, setOrigin } from 'c/ownDataUtils';
import DreamshopHomeURL from '@salesforce/label/c.Dreamshop_Home';
import getCustomMetadataTypes from '@salesforce/apex/OwnGarageController.getCustomMetadataTypes';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnTwoColumnCard extends OwnBaseElement {

    @api headerlink = DreamshopHomeURL;
    @api contentId;
    @api icon;
    @api brand;
    @api type;
    @api buttonTitle;
    @api containsImage = false;
    @track title;
    @track body;
    @track body2;
    @track desktopImage;
    @track mobileImage;
    @track leftColumnExternalLink;
    @track rightcolumnExternalLink;
    @track leftColumnExternalLinkTitle;
    @track rightcolumnExternalLinkTitle;
    @track link1Label;//cms field - descriptionLabel
    @track link1;//cms field - description2Label
    @track link2Label;//cms field - phone label
    @track link2;//cms field - phone number
    @track link3Label;//cms field - phone2 label
    @track link3;//cms field - phone2 number
    @track link4Label;//cms field - section label
    @track link4;//cms field - section content 
    @track cardDivClass = '';
    @track marketplace_urls;

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if (document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage') {
            this.cardDivClass = 'overview-tab-class';
            //console.log('Document title ::: ', document.title);
        }
        this.initialize();
    }

    initialize = async () => {
        //console.log('Initialize method called');
        this.marketplace_urls = await getCustomMetadataTypes();
        //console.log('These are marketplace URLS : ', this.marketplace_urls);

        //console.log('this.contentId  :-  ', this.contentId)
        let contentKeys = [this.contentId];
        let results = await getManagedContentByTopicsAndContentKeys(contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('results  :-  ', results);
        results.forEach(r => {
            if (r.title) {
                this.title = this.htmlDecode(r.title.value);
            }
            if (r.body) {
                this.body = this.htmlDecode(r.body.value);
            }
            if (r.descriptionContent) {
                this.body2 = this.htmlDecode(r.descriptionContent.value);
            }
            // this.mobileImage = this.htmlDecode(r.description2Content.value)
            // this.desktopImage = this.htmlDecode(r.descriptionContent.value)
            if (this.containsImage) {
                console.log('contains image')
                if (r.descriptionContent) { this.desktopImage = this.htmlDecode(r.descriptionContent.value) }
                if (r.description2Content) { this.mobileImage = this.htmlDecode(r.description2Content.value) }
                if (r.descriptionLabel) { this.link1Label = this.htmlDecode(r.descriptionLabel.value) }
                if (r.description2Label) { this.link1 = this.htmlDecode(r.description2Label.value) }
                if (r.phoneLabel) { this.link2Label = this.htmlDecode(r.phoneLabel.value) }
                if (r.phoneNumber) { this.link2 = this.htmlDecode(r.phoneNumber.value) }
                if (r.phone2Label) { this.link3Label = this.htmlDecode(r.phone2Label.value) }
                if (r.phone2Number) { this.link3 = this.htmlDecode(r.phone2Number.value) }
                if (r.sectionLabel) { this.link4Label = this.htmlDecode(r.sectionLabel.value) }
                if (r.sectionContent) { this.link4 = this.htmlDecode(r.sectionContent.value) }
                //console.log('contains image', this.link1Label, this.link1, this.link2Label, this.link2, this.link3Label, this.link3, this.link4Label, this.link4)
            }
            else {
                if (r.phoneLabel) { this.leftColumnExternalLinkTitle = this.htmlDecode(r.phoneLabel.value) }
                if (r.phone2Label) { this.rightcolumnExternalLinkTitle = this.htmlDecode(r.phone2Label.value); }
                if (r.phoneNumber) { this.leftColumnExternalLink = this.htmlDecode(r.phoneNumber.value); }
                if (r.phone2Number) { this.rightcolumnExternalLink = this.htmlDecode(r.phone2Number.value); }
            }
        });
    }

    handleClickHeader() {
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: this.title + (this.buttonTitle ? ':' + this.buttonTitle : '')
        };

        let currentBrand = this.brand == 'Powerequipment' ? 'Power_Equipment' : this.brand;
        let navigationDetails = this.marketplace_urls.find(element => element.DeveloperName == currentBrand);
        //console.log('ALL navigationDetails :: ', navigationDetails);

        if ((this.type == 'Parts' || this.type == 'Parts_And_Accessories') && ISGUEST) {
            let message = this.buildAdobeMessage(navigationDetails.Parts_Logged_Out_URL__c, eventMetadata);
            this.publishToChannel(message);
            this.navigate(navigationDetails.Parts_Logged_Out_URL__c, {});
        } else if ((this.type == 'Parts' || this.type == 'Parts_And_Accessories') && !ISGUEST) {
            let message = this.buildAdobeMessage(navigationDetails.Parts_Logged_In_URL__c, eventMetadata);
            this.publishToChannel(message);
            this.navigate(navigationDetails.Parts_Logged_In_URL__c, {});
        } else if (this.type == 'Accessories' && ISGUEST) {
            let message = this.buildAdobeMessage(navigationDetails.Accessories_Logged_Out_URL__c, eventMetadata);
            this.publishToChannel(message);
            this.navigate(navigationDetails.Accessories_Logged_Out_URL__c, {});
        } else if (this.type == 'Accessories' && !ISGUEST) {
            let message = this.buildAdobeMessage(navigationDetails.Accessories_Logged_In_URL__c, eventMetadata);
            this.publishToChannel(message);
            this.navigate(navigationDetails.Accessories_Logged_In_URL__c, {});
        }

    }


    // get iconClass(){
    //     let colorClass = this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    //     if(this.forwardiconright) {
    //         colorClass += ' forward-icon-right';
    //     }
    //     return colorClass;
    // }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }

    // htmlDecode(input) {
    //     if (!input) return '';
    //     let doc = new DOMParser().parseFromString(input, "text/html");
    //     return doc.documentElement.textContent;
    // }

    handleExternalLink(event) {
        let label = event.currentTarget.dataset.label;
        //console.log("label : ", label);
        let currentBrand = this.brand == 'Powerequipment' ? 'Power_Equipment' : this.brand;
        let navigationDetails = this.marketplace_urls.find(element => element.DeveloperName == currentBrand);
        //console.log('ALL navigationDetails :: ', navigationDetails);
        if (label == 'Parts' && ISGUEST) {
            this.navigate(navigationDetails.Parts_Logged_Out_URL__c, {});
        } else if (label == 'Parts' && !ISGUEST) {
            this.navigate(navigationDetails.Parts_Logged_In_URL__c, {});
        } else if (label == 'Accessories' && ISGUEST) {
            this.navigate(navigationDetails.Accessories_Logged_Out_URL__c, {});
        } else if (label == 'Accessories' && !ISGUEST) {
            this.navigate(navigationDetails.Accessories_Logged_In_URL__c, {});
        }
    }
    handleLink1() {
        this.navigate(DreamshopHomeURL, {})
    }
    handleLink2() {
        this.navigate(DreamshopHomeURL, {})
    }
    handleLink3() {
        this.navigate(DreamshopHomeURL, {})
    }
    handleLink4() {
        this.navigate(DreamshopHomeURL, {})
    }
}
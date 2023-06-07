//============================================================================
// Title:    Honda MyGarage Experience - Virtual Assistant Card
//
// Summary:  Virtual Assistant Card for pages
//
// Details:  This is the Virtual Assistant Card seen at the page of the Help-Honda page
//
// History:
// October 11, 2021 Ravindra Ravindra (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import {
    getManagedContentByTopicsAndContentKeys,
    getContext,
    ISGUEST,
    getOrigin,
} from 'c/ownDataUtils';
import Id from '@salesforce/user/Id';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import Last_NAME_FIELD from '@salesforce/schema/User.LastName';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

const fields = [FIRST_NAME_FIELD, Last_NAME_FIELD];

export default class OwnVirtualAssistantCard extends OwnBaseElement {
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
    @track chatBotLinkLabel;
    isguest = ISGUEST;
    division;
    modelName;
    year;
    chatBotLink;
    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));
    userId = Id;

    @wire(getRecord, { recordId: '$userId', fields })
    user;

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

    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = r.title.value;
            this.body = this.htmlDecode(r.body.value);
            this.chatBotLink = r.downloadLink.value;
            this.chatBotLinkLabel = r.downloadLabel.value;
        });

        let context = await getContext('');
        let fromProductChooser = getOrigin() === 'ProductChooser' && !this.isguest ? true : false;
        let garageProducts = JSON.parse(localStorage.getItem('garage'))
        let productDetails = fromProductChooser && !this.isguest ? garageProducts.products[0] : undefined;
        if (productDetails != undefined || context.product != undefined) {
            this.division = fromProductChooser ? productDetails.division : context.product.division;
            this.modelName = productDetails != undefined ? productDetails.model : context.product.model;
            this.year = productDetails != undefined ? productDetails.year : context.product.year;
        }
    };

    handleChatBotClick(event) {
        event.preventDefault();
        let tempLink = this.linkForChatBot();
        var popupWidth = 600;
        var popupHeight = 600;
        var leftPos = screen.width - popupWidth;
        var topPos = screen.height - popupHeight;

        
        if(this.brand === 'Acura'){
            //console.log('Opening Acura brand +', this.brand);
            window.open(tempLink, 'Chat with Acura', "width=" + popupWidth + ", height=" + popupHeight + ", top=" + topPos +", left=" + leftPos);
        }
        else if(this.brand === 'Honda'){
            //console.log('Opening Honda brand +', this.brand);
        window.open(tempLink, 'Chat with Dave', "width=" + popupWidth + ", height=" + popupHeight + ", top=" + topPos +", left=" + leftPos);
        }
    }

    linkForChatBot() {
        let tempChatBotLink = this.chatBotLink + '?site=' + this.baseURL;
        //console.log('1 +', this.brand);
        tempChatBotLink += this.division === 'Honda' ? '&model=' + this.modelName.toUpperCase() + '&year=' + this.year : '';
        //console.log('2+', this.brand);
        //DOE-4998
        if(this.brand === 'Acura'){
        tempChatBotLink = this.brand === 'Acura' ? this.chatBotLink + '?site=Acura' : tempChatBotLink;
            //console.log('acura link +', this.brand, ' + ', tempChatBotLink);
        tempChatBotLink = this.division === 'Acura' ? this.chatBotLink + '?site=' + this.division + '&model=' + this.modelName.toUpperCase() + '&year=' + this.year : tempChatBotLink;
        }
        if (!this.isguest) {
            let user = getFieldValue(this.user.data, FIRST_NAME_FIELD);
            user += ' '+ getFieldValue(this.user.data, Last_NAME_FIELD);
            tempChatBotLink += '&username=' + user;
        };
        //console.log('Return botlink + ' , tempChatBotLink);
        return tempChatBotLink;
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
}
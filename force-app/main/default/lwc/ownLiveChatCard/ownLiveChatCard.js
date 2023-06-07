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
    ISGUEST,
} from 'c/ownDataUtils';
import Id from '@salesforce/user/Id';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import Last_NAME_FIELD from '@salesforce/schema/User.LastName';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import isChatAvailable from '@salesforce/apex/OwnHelpCenter.isChatAvailable';
import AcuraLiveChatLink from '@salesforce/label/c.Acura_Live_Chat_Link';
import HondaLiveChatLink from '@salesforce/label/c.Honda_Live_Chat_Link';

const fields = [FIRST_NAME_FIELD, Last_NAME_FIELD];

export default class OwnLiveChatCard extends OwnBaseElement {
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
    @track liveChatLabel;
    @track isLiveChatAvailable = true;
    isguest = ISGUEST;
    division;
    modelName;
    year;
    liveChatLink;
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
            this.body = r.body ? this.htmlDecode(r.body.value).trim() : '';
            this.liveChatLink = r.downloadLink ? r.downloadLink.value : '';
            this.liveChatLabel = r.downloadLabel ? r.downloadLabel.value : '';
        });

        isChatAvailable({brandName : this.brand}).then((res) =>{
            this.isLiveChatAvailable = res;
            //For testing purpose only//
            //this.isLiveChatAvailable = true; 
        });
    };

    handleLiveChatClick(event) {
        event.preventDefault();
        let tempLink = this.linkForLiveChat();
        var popupWidth = 660;
        var popupHeight = 600;
        var leftPos = screen.width - popupWidth;
        var topPos = screen.height - popupHeight;
        window.open(tempLink, 'Live Chat', "width=" + popupWidth + ", height=" + popupHeight + ", top=" + topPos +", left=" + leftPos);
    }

    linkForLiveChat() {
        return this.brand === 'HondaAutos' ? HondaLiveChatLink  : AcuraLiveChatLink;
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
}
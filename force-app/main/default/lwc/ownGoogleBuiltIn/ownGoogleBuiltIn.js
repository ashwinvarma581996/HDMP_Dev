import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import basePath from '@salesforce/community/basePath';
import { getManagedContentByTopicsAndContentKeys, ISGUEST } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnGoogleBuiltIn extends OwnBaseElement {

    @api contentId;
    @api contentId2;
    @api contentId3;
    @api contentId4;

    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track googleRecords = [];
    @track pageContent;
    @track isGuest = ISGUEST;

    connectedCallback() {
        this.initialize();
    }

    initialize = async () => {
        this.contentKeys = [this.contentId, this.contentId2, this.contentId3];
        //console.log('contentKeys', this.contentKeys);
        let result = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('result', result);
        let googleRecords = []
        result.forEach((element, index) => {
            let googleObj = {};
            googleObj.serialNumber = element.phone4Number ? element.phone4Number.value : '';
            googleObj.title = element.title.value;
            if (googleObj.title && googleObj.title.toLowerCase() === 'google maps') {
                googleObj.customImage = true;
            } else {
                googleObj.customImage = false;
            }
            googleObj.body = element.body ? this.htmlDecode(element.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '';
            googleObj.image = element.image ? `${basePath}/sfsites/c${element.image.url}` : '';
            googleObj.vedioLink = element.videoLink ? element.videoLink.value : '';
            googleRecords.push(googleObj);
        });
        this.googleRecords = googleRecords;
        //console.log('googleRecords', JSON.parse(JSON.stringify(this.googleRecords)));
        this.googleRecords.sort((a, b) => {
            return a.serialNumber - b.serialNumber;
        });
        //console.log('googleRecords', JSON.parse(JSON.stringify(this.googleRecords)));

    }

    renderedCallback() {
        let overlaps = this.template.querySelectorAll(".overlap");
        overlaps.forEach(element => {
            element.addEventListener("click", (e) => {
                e.target.firstChild.style.zIndex = 2;
                e.target.firstChild.src += "?autoplay=1";
                let eventMetadata = {
                    action_type: 'button',
                    action_category: 'body',
                    action_label: e.target.dataset.label
                };
                //console.log("@data eventMetadata", eventMetadata);
                let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
                this.publishToChannel(message);
            }, false);
        });
    }

}
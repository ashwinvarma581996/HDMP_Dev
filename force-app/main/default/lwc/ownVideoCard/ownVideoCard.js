import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnVideoCard extends OwnBaseElement {

    @api contentId;
    @api icon;
    @api iscollisionrepair;
    //@api topic;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @api title;
    @track videoLink;
    @api brand;
    @track headerIcon;
    @api link;
    @api fromPage;

    get titleClass() {
        return !this.link && this.fromPage == 'Service & Maintenance' ? 'title slds-p-left_small slds-text-title_caps' : 'title slds-p-left_small slds-text-title_caps link';
    }
    connectedCallback() {
        this.initialize();
        // console.log('this.topic',this.topic);
        this.headerIcon = this.myGarageResource() + '/ahmicons/' + this.icon;
    }

    initialize = async () => {
        if (this.contentId) {
            this.contentKeys.push(this.contentId);
        }
        //this.topics = this.topic ? this.topic : null;
        //console.log('this.contentKeys', this.contentKeys);
        //console.log('this.topics', this.topics);

        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('this.results', this.results);
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.videoLink = r.videoLink ? r.videoLink.value.replaceAll('&amp;', '&') : '';
            if (!this.brand) {
                this.brand = r.downloadLabel ? r.downloadLabel.value : '';
            }
        });
    }

    async handleClickHeader(event) {
        //console.log('Video Card handleClickHeader', this.iscollisionrepair);
        // if (this.link) {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };

        // }

        if ((!this.iscollisionrepair)) {
            //console.log('is repair false', this.link);
            if (this.link) {
                //console.log('handleClickHeader ifff');
                let navigateLink = this.link + '?key=' + this.contentId;
                sessionStorage.setItem('frompage', this.fromPage ? this.fromPage : this.brand + 'Link');
                await this.sleep(2000);
                let message = this.buildAdobeMessage(navigateLink, eventMetadata);
                this.publishToChannel(message);
                this.navigate(navigateLink, {});
            } else if (!this.link && this.fromPage != 'Service & Maintenance') {
                //console.log('handleClickHeader', this.brand);
                let navigateLink = '/' + this.brand.toLowerCase() + 'link-video-detail?key=' + this.contentId;
                sessionStorage.setItem('frompage', this.fromPage ? this.fromPage : this.brand + 'Link');
                let message = this.buildAdobeMessage(navigateLink, eventMetadata);
                this.publishToChannel(message);
                await this.sleep(2000);
                this.navigate(navigateLink, {});
            }

        }
        else if (this.iscollisionrepair) {
            let title = event.currentTarget.title;
            let message = this.buildAdobeMessage('/video-detail-page', eventMetadata);
            this.publishToChannel(message);
            this.dispatchEvent(new CustomEvent('videoclick', { contentId: this.contentId, title: title }));
            //this.navigate(link, {});
        }
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys, ISGUEST } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnFinancialServiceCard extends OwnBaseElement {

    @api contentId;
    @api icon;
    @api headerlink;
    @api headerinkloogedout;
    @track title;
    @track body;
    @track desktopImage;
    @track mobileImage;
    @api actionicon = 'utility:forward';
    isGuest = ISGUEST;
    // @track headerlink;

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }

    initialize = async () => {
        //console.log('this.contentId  :-  ', this.contentId);
        //console.log('headerlink :-  ', this.headerlink);
        //console.log('headerinkloogedout :-  ', this.headerinkloogedout);
        //console.log('isGuest :-  ', this.isGuest);
        let contentKeys = [this.contentId];
        let results = await getManagedContentByTopicsAndContentKeys(contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('results  :-  ', results);
        results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
            if (this.title == 'SHEFFIELD FINANCIAL') {
                //console.log('SHEFFIELD FINANCIAL==>>', JSON.stringify(this.htmlDecode(this.body)));
            }
            this.desktopImage = this.htmlDecode(r.descriptionContent.value);
            this.mobileImage = this.htmlDecode(r.description2Content.value);
        });
    }

    handleClickHeader() {
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: this.title + ':learn more'
        };
        let message = this.buildAdobeMessage(this.headerlink, eventMetadata);
        this.publishToChannel(message);
        try {
            if (this.isGuest) {
                //  this.navigate(this.headerinkloogedout,'_blank', {});
                window.open(this.headerinkloogedout, "_blank");
            } else {
                //   this.navigate(this.headerlink,'_blank', {});
                window.open(this.headerlink, "_blank");
            }
        } catch (e) {
            //console.log('@@exception' + e);
        }
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }
}
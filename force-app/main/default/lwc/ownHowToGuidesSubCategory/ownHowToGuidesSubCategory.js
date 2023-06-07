import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST, getProductContext, getContext, getOrigin } from 'c/ownDataUtils';
import youtubeEmbed from '@salesforce/label/c.Youtube';
import hondaPDF from '@salesforce/label/c.Honda_Owners_PDF';
import acuraPDF from '@salesforce/label/c.Acura_Owners_PDF';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
export default class OwnHowToGuidesSubCategory extends OwnBaseElement {
    @track mainCardClass = 'card card-size card-styles-wrapper diff-cms-card';
    @track customBodyHeight = '';
    @track icon = 'chat.svg';
    @track title;
    @track type;
    @track content;
    @api featureData;
    @track keyData;
    @api showforwardicon;
    @api headerRightIcon = 'utility:forward';
    @track titlecolor;
    @track isPdf = false;
    @track isText = false;
    @track isYoutube = false;
    @track isVideo = false;
    @track divisionId;
    @track year;
    @track model;
    @track videoLink;
    get bodyClass() {
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body' + this.customBodyHeight;
    }

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass() {
        let colorClass = this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
        if (this.forwardiconright) {
            colorClass += ' forward-icon-right';
        }
        return colorClass;
    }

    connectedCallback() {
        if (this.featureData) {
            this.type = this.featureData.type ? this.featureData.type : '';
            this.keyData = this.featureData.data ? this.featureData.data : '';
            this.title = this.featureData.title ? this.featureData.title : '';
            this.content = this.featureData.content ? this.featureData.content : '';

        }
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.titlecolor = 'Honda Red';
        this.isPdf = this.type == 'Pdf' ? true : false;
        this.isYoutube = this.type == 'YouTube' ? true : false;
        this.isText = this.type == 'Text' ? true : false;
        this.isVideo = this.type == 'Video' ? true : false;
        if (this.isPdf) {
            this.icon = this.myGarageResource() + '/ahmicons/document.svg';
            this.showforwardicon = true;
            this.headerRightIcon = 'utility:download';
            this.title = this.keyData;
        } else if (this.isYoutube) {
            this.icon = this.myGarageResource() + '/ahmicons/play.svg';
            this.videoLink = youtubeEmbed + this.keyData;
            this.titlecolor = 'black';
        } else if (this.isText || this.isVideo) {
            this.icon = this.myGarageResource() + '/ahmicons/download-how-to-guide.svg';
        }
        this.initialize();
    }

    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        let context;
        if (fromProductChooser) {
            context = await getProductContext('', true);
        } else {
            context = await getProductContext('', false);
        }
        if (context && context.product) {
            this.divisionId = context.product.divisionId;
            this.model = context.product.model;
            this.year = context.product.year;
        }
    }

    async handleClickHeader() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.convertToPlain(this.title)
        };


        if (this.isPdf) {
            let url;
            if (this.divisionId == 'A') {
                url = hondaPDF;
            } else if (this.divisionId == 'B') {
                url = acuraPDF;
            }
            url += +this.year + '/' + this.model + '/' + this.keyData;
            let message = this.buildAdobeMessage(url, eventMetadata)
            this.publishToChannel(message);
            await this.sleep(2000);
            this.navigate(url, {});
        } else if (this.isYoutube) {
            //console.log('this.categoryData--', this.featureData);
            let categoryData = this.featureData;
            sessionStorage.setItem('howtocategory', JSON.stringify(categoryData));
            sessionStorage.setItem('frompage', 'howtocategory');
            let breadcrumbData = {
                label: categoryData.category ? categoryData.category + ' How-to Guides' : 'How-to Guides',
                url: '/' + document.location.pathname.substring(document.location.pathname.lastIndexOf('/') + 1),
                subTitle: categoryData.title ? categoryData.title : ''
            }
            let breadcrumbArr = [];
            if (sessionStorage.getItem('fromhowtoguides')) {
                breadcrumbArr = JSON.parse(sessionStorage.getItem('fromhowtoguides'));
            }
            breadcrumbArr.push(breadcrumbData);
            sessionStorage.setItem('howtoguidesTitle', JSON.stringify(this.title));
            sessionStorage.setItem('fromhowtoguides', JSON.stringify(breadcrumbArr));
            let message = this.buildAdobeMessage('/guide-video-detail', eventMetadata)
            this.publishToChannel(message);
            await this.sleep(2000);
            this.navigate('/guide-video-detail', {});
        }
        //url = url.replace(' ', '%20');
    }

    handleClickAction() {
        this.navigate(this.headerlink, {});
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    convertToPlain(html) {
        let tempDivElement = document.createElement("div");
        tempDivElement.innerHTML = html;
        return tempDivElement.textContent || tempDivElement.innerText || "";
    }
}
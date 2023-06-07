import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST, getManagedContentByTopicsAndContentKeys, getProductContext } from 'c/ownDataUtils';
import getFinanceLink from '@salesforce/apex/OwnRetriveCustomMetaData.getFinanceLink';

export default class OwnFinanceBanner extends OwnBaseElement {
    @api title;
    @api contentId;
    @api imageposition;
    @api showbreadcrumb;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    @track desktopImage;
    @track mobileImage;
    @track mainCardClass = 'c-container';
    @track headerlink;
    context;
    contentSection = 'content-section';
    titleClass = 'title banner-inner-div';

    handleEnrollNow() {
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: this.title + ':enroll now'
        };
        let message = this.buildAdobeMessage(this.headerlink, eventMetadata);
        this.publishToChannel(message);
        this.navigate(this.headerlink, '_blank', {});
    }
    connectedCallback() {
        this.mainCardClass = 'c-container connected-features-tab-div';
        if (this.imageposition == 'Left') {
            this.contentSection = 'content-section image-left';
        }
        this.initialize();
    }
    initialize = async () => {
        //localStorage.setItem('origin','FeatureCard');
        let origin = localStorage.getItem('origin');
        if (ISGUEST || origin == 'ProductChooser') {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);

        this.results.forEach(r => {
            this.title = r.title.value;
            this.titleIcon = '';
            this.footerMessage = '';
            this.body = this.htmlDecode(r.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
            this.desktopImage = this.htmlDecode(r.descriptionContent.value);
            this.mobileImage = this.htmlDecode(r.description2Content.value);
            if (r.subTitle) {
                this.buttonLabel = r.subTitle.value
            }
        });
        await getFinanceLink({ brand: this.context.product.division }).then((data) => {
            if (ISGUEST) {
                this.headerlink = data.Guest_Link__c;
            } else {
                this.headerlink = data.Login_Link__c;
            }
        }).catch((error) => {
            //console.log('@@Error getting Data', error);
        });
    };
}
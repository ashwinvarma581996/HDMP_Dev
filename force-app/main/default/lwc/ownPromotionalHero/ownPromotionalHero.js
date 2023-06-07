//============================================================================
// Title:    Honda MyGarage Experience - Promotional Hero
//
// Summary:  This is the Promotional Hero html seen at the page of the Honda MyGarage Community
//
// Details:  Promotional Hero for pages
//
// History:
// October 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys, getProductContext, ISGUEST, getOrigin } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';

export default class OwnPromotionalHero extends OwnBaseElement {
    @api title;
    @api contentId; // added by Tahir
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
    @track buttonLabel;
    @track backLinkContent;
    @track titleIcon;
    @track footerMessage;
    @track mainCardClass = 'c-container';
    @track isCustomButton;
    isDriverFeedback = false;
    context;
    contentSection = 'content-section';
    videoLink;
    titleClass = 'title banner-inner-div';
    connectedCallback() {
        if (document.title == 'HondaLink Features' || document.title == 'Acuralink Connected Features') {
            this.mainCardClass = 'c-container connected-features-tab-div';
        }
        if (document.title == 'Garage' || document.title == 'Garage') {
            this.mainCardClass = 'c-container overview-tab-class';
            //console.log('Document title ::: ', document.title);
        }
        if (this.imageposition == 'Left') {
            this.contentSection = 'content-section image-left';
        }
        if (document.title == 'HondaLink Driver Feedback' || document.title == 'AcuraLink Driver Feedback') {
            this.isDriverFeedback = true;
            this.titleClass = 'banner-inner-div driver-feedback-title';
        }
        if (document.title == 'HondaLink Amazon Alexa' || document.title == 'AcuraLink Amazon Alexa') {
            this.isDriverFeedback = true;
            this.titleClass = 'banner-inner-div amazon-alexa-title';
        }
        this.initialize();
    }

    initialize = async () => {
        //localStorage.setItem('origin','FeatureCard');
        //console.log('Origin', getOrigin());
        let fromFeatureCard = localStorage.getItem('frompage') === 'FeatureCard' ? true : false; //DOE-4842
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }

        //console.log('This is Context : ', this.context);
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);

        this.results.forEach(r => {
            this.title = r.title.value;
            if (this.title === 'myQ Connected Garage') {
                this.isCustomButton = true;
                this.title = this.title.replace('Garage', 'Garage<sup class="supTop">beta</sup>');
            }
            this.titleIcon = '';
            this.footerMessage = '';
            if (r.sectionContent) {
                if (r.sectionContent.value.includes('::@@::')) {
                    this.titleIcon = this.htmlDecode(r.sectionContent.value.split('::@@::')[0]);
                    this.footerMessage = this.htmlDecode(r.sectionContent.value.split('::@@::')[1]);
                } else {
                    this.titleIcon = this.htmlDecode(r.sectionContent.value);
                    this.footerMessage = '';
                }
            }
            // if(document.location.pathname.includes('garage-')){
            //     this.footerMessage = '' ;
            // }
            //this.titleIcon = r.sectionContent ? this.htmlDecode(r.sectionContent.value) : '';
            this.body = this.htmlDecode(r.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
            this.desktopImage = this.htmlDecode(r.descriptionContent.value);
            this.mobileImage = this.htmlDecode(r.description2Content.value);
            this.backLinkContent = (fromFeatureCard) ? '< My Products' : '< ' + document.title.split(' ')[0]; //DOE-4842

            this.videoLink = r.sectionLabel ? r.sectionLabel.value : '';
            if (r.subTitle) {
                this.buttonLabel = r.subTitle.value
            }
        });
    };

    async handleButtonClick(event) {
        if (event.target.dataset.key === 'LEARN MORE') {
            let eventMetadata = {};
            if (this.context) {
                //let navigationPath = this.context.product.divisionId == 'A' ? '/honda-product-compatibility-result' : '/acura-product-compatibility-result';
                // let navigationPath = this.context.product.divisionId == 'A' ? '/hondalink-marketing' : '/acuralink-marketing';
                let documentTitle = document.title;
                if (documentTitle == 'Garage' || documentTitle == 'Garage' ||
                    documentTitle == 'HondaLink Features' || documentTitle == 'Acuralink Connected Features') {
                    //console.log('::::: INSIDE LEARN MORE :::::');
                    sessionStorage.setItem('frompageformarketingpage', 'pdp');
                }
                if (document.location.pathname.includes('-connected-features') || documentTitle == 'Garage') {
                    eventMetadata = {
                        action_type: 'button',
                        action_category: document.location.pathname.includes('-connected-features') ? 'my products - connected features' : 'my products - overview',
                        action_label: this.title + ':learn more'
                    };

                }
                if (this.context.product && this.context.product.division === 'Marine') {
                    let message = this.buildAdobeMessage(this.videoLink, eventMetadata);
                    this.publishToChannel(message);
                    await this.sleep(2000);
                    this.navigate(this.videoLink, {});
                } else {
                    let navigationPath = document.location.pathname.includes('honda') ? '/honda-product-compatibility-result?fb=' + ISGUEST : '/acura-product-compatibility-result?fb=' + ISGUEST;
                    let message = this.buildAdobeMessage(navigationPath, eventMetadata);
                    this.publishToChannel(message);
                    await this.sleep(2000);
                    this.navigate(navigationPath, {});
                }
            }
        } else if (event.target.dataset.key === 'CHECK VEHICLE COMPATIBILITY') {
            //let navigationPath = '/product-compatibility-check';
            let lastPage = sessionStorage.getItem('frompageformarketingpage');
            //console.log('FROM PAGE ::: ', lastPage);
            //console.log('title!!!', document.title);

            sessionStorage.setItem('frompage', document.title == 'HondaLink' ? 'HondaLink' : 'AcuraLink');
            //console.log('FROM PAGE ::: ', lastPage);
            if (this.context && this.context.product) {
                let documentTitle = this.context.product.divisionId == 'A' ? 'HondaLink' : 'AcuraLink';
                let navigationPath = '';
                if (document.title == documentTitle && lastPage == 'pdp') {
                    navigationPath = document.title == 'HondaLink' ? '/honda-product-compatibility-result?fb=true' : '/acura-product-compatibility-result?fb=true';
                } else {
                    navigationPath = document.title == 'HondaLink' ? '/hondalink-product-compatibility' : '/acuralink-product-compatibility';
                }
                this.navigate(navigationPath, {});
            } else {
                let navigationPath = document.title == 'HondaLink' ? '/hondalink-product-compatibility' : '/acuralink-product-compatibility';
                this.navigate(navigationPath, {});
            }

        } else if (event.target.dataset.key === 'WATCH VIDEO') {
            let navigationPath = this.videoLink;
            if (document.location.pathname.includes('/hondalink-google-built-in')) {
                let eventMetadata = {
                    action_type: 'button',
                    action_category: 'body',
                    action_label: this.buttonLabel
                };
                let message = this.buildAdobeMessage(navigationPath, eventMetadata)
                this.publishToChannel(message);
            }
            this.navigate(navigationPath, {});
        }
    }

    handleBreadcrumb() {
        window.history.back();
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

}
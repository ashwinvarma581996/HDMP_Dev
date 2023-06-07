//============================================================================
// Title:    Honda MyGarage Experience - Page Header
//
// Summary:  This is the Page Header html seen at the page of the Honda MyGarage Community
//
// Details:  Page Header for pages
//
// History:
// October 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { LightningElement, api, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { CurrentPageReference } from 'lightning/navigation';
import { ISGUEST, getProductContext, getContext, getOrigin, getMyProducts } from 'c/ownDataUtils';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import HondaLogo from '@salesforce/label/c.HondaLogo';
import AcuraLogo from '@salesforce/label/c.AcuraLogo';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

const SPAN_IMAGE_CLASS = 'slds-icon_container simple-image-span';
export default class ownPageHeader extends OwnBaseElement {
    @api image;
    @api title;
    @api subtitle;
    previousValues;
    @track pageUrl;
    @track hasSessionbacklink;
    @track showData;
    @api showProductBadge;
    @api hideProductBadge;
    @api isRadioNavPage;
    @api isproductbadge;
    @api showBreadcrumb;
    @track showBreadcrumbFlag;
    @api breadcrumbLabel;
    @api breadcrumbUrl = '/';
    @track breadcrumbs;
    @track vinNumber;
    @track isPEorMarine;
    @track isPSP;
    @track hasVin;
    @track hideEnterVin;
    @track isGuest = ISGUEST;
    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));
    @track fb;
    @track key;
    @track topics = null;
    @track pageSize = null;
    @track rectImageClass = '';
    @track managedContentType = '';
    @track imageCss = SPAN_IMAGE_CLASS;
    context;
    @track fromHowToGudides = [];
    //context2;
    @api brand;
    @track year;
    @track model;
    @track divisionId; 

    currentPageReference = null;
    urlStateParameters = null;
    handleBreadcrumbClick() {
        this.navigate(this.breadcrumbUrl, {})
    }

    @api isRecallPage;
    @api isVideoDetailPage;
    @api isSpecificationsPage;
    @track fromPage;

    connectedCallback() {
        try {
            this.showData = false;
            this.hideProductBadge = this.showProductBadge;//DO NOT REMOVE OR CHANGE THIS.
            this.fromPage = sessionStorage.getItem('frompage');
            //console.log('  this.fromPage ====>', this.fromPage);
            this.rectImageClass = this.image == 'AcuraLink.png' ? 'acura-link-image' : '';
            this.showBreadcrumbFlag = this.showBreadcrumb;
            //console.log('this.isVideoDetailPage', this.isVideoDetailPage);

            this.image = this.myGarageResource() + '/images/' + this.image;
            this.initialize();
            if (!document.location.pathname.includes('honda-handsfreelink-compatibility-check') && !document.location.pathname.includes('acura-handsfreelink-compatibility-check') && !document.location.pathname.includes('bluetooth-compatibility-check') && !document.location.pathname.includes('bluetooth-compatibility-result') && !document.location.pathname.includes('phone-compatibility-result') && !document.location.pathname.includes('how-to-category') && !document.location.pathname.includes('guide-video-detail')) {
                this.pageUrl = sessionStorage.getItem('frompage');
                if(document.location.pathname.includes('hondalink-product-compatibility') || document.location.pathname.includes('honda-product-compatibility-result')){
                    this.pageUrl =this.pageUrl.replaceAll('AcuraLink', 'HondaLink');
                    this.pageUrl =this.pageUrl.replaceAll('Acuralink', 'HondaLink');
                }else if(document.location.pathname.includes('acuralink-product-compatibility') || document.location.pathname.includes('acura-product-compatibility-result')){
                    this.pageUrl =this.pageUrl.replaceAll('Hondalink', 'AcuraLink');
                    this.pageUrl =this.pageUrl.replaceAll('HondaLink', 'AcuraLink');
                }
            }
            
            //console.log('this.pageUrl  :-  @', this.pageUrl);
            this.subtitle = this.subtitle ? this.subtitle.replaceAll('&lt;', '<').replaceAll('&gt;', '>') : this.subtitle;
        } catch (e) {
            this.showData = true;
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        //console.log('currentPageReference', currentPageReference);
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            //console.log('this.urlStateParameters', this.urlStateParameters);
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.fb = this.urlStateParameters.fb || null;
        this.divisionId = this.urlStateParameters.divisionid || null;
        this.year = this.urlStateParameters.year || null;
        this.model = this.urlStateParameters.model || null;
    }

    initialize = async () => {
        //console.log('ownPageHeader:: ConnectedCallback');
        try {
            let origin = localStorage.getItem('origin');
            const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
            //console.log('page context', context)

            if (document.location.pathname.includes('handsfreelink-compatibility-check')) {
                this.imageCss = this.imageCss + ' simple-image-padding';
            }
            if (context && context.product && context.product.productId === 'check-compatibility') {
                this.context = await getProductContext(context.product.productId);
            } else if (this.fb == 'true' || origin == 'ProductChooser') {
                /* this.context = await getProductContext('', true); DOE-4825 */
                if (origin == 'ProductChooser' || document.location.pathname.includes('radio-nav-code') || document.location.pathname.includes('phone-compatibility-result') || document.location.pathname.includes('bluetooth-compatibility-result') || document.title.includes('Collision Repair') || document.title.includes('Video Detail') || document.location.pathname.includes('specifications') || document.location.pathname.includes('phone-compatibility-phone') || document.location.pathname.includes('bluetooth-compatibility-phone')) {
                    //console.log('@@Guest Context');
                    this.context = await getProductContext('', true);
                } else {
                    //console.log('@@User Context');
                    this.context = await getContext('');
                }
                //console.log('context from browser - ', JSON.parse(JSON.stringify(this.context)));
            } else {
                /* this.context = await getProductContext('', false); */
                this.context = await getContext('');
                //console.log('context from server - ', JSON.parse(JSON.stringify(this.context)));
            }
            // this.isPEorMarine = context.product.division == 'Powerequipment' || context.product.division == 'Marine' ? true : false;
            if (this.context && this.context.product && this.isproductbadge && (!this.brand || this.brand == this.context.product.division) && this.fromPage != 'help-center') {
                this.title = this.context.product.year + ' ' + this.context.product.model;
                // this.vinNumber = this.context.product.vin;
                this.image = this.context.product.image;
                this.brand = this.context.product.division; //DOE-4825
                if (document.location.pathname.includes('radio-nav-code') && !this.isGuest && origin != 'ProductChooser'){
                    this.context= await getProductContext('', false);
                }
                if ((!(this.fb == 'true' || origin == 'ProductChooser' || this.isGuest)) || (!this.isGuest && document.location.pathname.includes('radio-nav-'))) {
                    this.image = this.context.product.customerUploadedImage ? this.context.product.customerUploadedImage : (this.context.product.productDefaultImage ? this.context.product.productDefaultImage : (this.context.product.image[0] === '/' ? this.baseURL + this.context.product.image : this.context.product.image));
                }
            }
            if(this.divisionId){
                if(this.year && this.model){
                    this.title = this.year + ' ' + this.model;
                }else{
                    this.title = '';
                }
                if (this.divisionId == 'B') {
                    this.image = this.myGarageResource() + '/images/' + AcuraLogo;
                } else {
                    this.image = this.myGarageResource() + '/images/' + HondaLogo;
                }
            }
            if (document.location.pathname.includes('compatibility-check') || document.location.pathname.includes('compatibility-phone')) {
                if (this.context) {
                    if (this.context.product.divisionId === 'A') {
                        this.subtitle = this.subtitle.replace('AcuraLink', 'HondaLink');
                        this.image = this.image.replace('AcuraLink', 'HondaLink');
                        //       this.image = this.context.product.productDefaultImage ? this.context.product.productDefaultImage : this.image;
                    }
                    if (this.context.product.divisionId === 'B') {
                        this.subtitle = this.subtitle.replace('HondaLink', 'AcuraLink');
                        this.image = this.image.replace('HondaLink', 'AcuraLink');
                        //       this.image = this.context.product.productDefaultImage ? this.context.product.productDefaultImage : this.image;
                    }
                }
            } else if (document.location.pathname.includes('phone-compatibility-result')) {
                this.subtitle = `${this.context.product.manufacturerName} ${this.context.product.phoneModelName}`
                this.pageUrl = 'Select Your Phone';
            } else if (document.location.pathname.includes('bluetooth-compatibility-result')) {
                this.subtitle = `${this.context.product.manufacturerName} ${this.context.product.phoneModelName} Bluetooth Compatibility`
                this.pageUrl = 'Select Your Phone';
            } else if (document.location.pathname.includes('acuralink-video-detail')) {
                this.getDetailsFromCMS();
            } else if (document.location.pathname.includes('hondalink-video-detail')) {
                this.getDetailsFromCMS();
            } else if (document.location.pathname.includes('collision-repair-video-page')) {
                this.getDetailsFromCMS();
            }
            else if (document.location.pathname.includes('video-detail-page') || document.location.pathname.includes('guide-video-detail')) {
                this.getDetailsFromCMS();
            } else if (document.location.pathname.includes('radio-nav-result')) {
                this.pageUrl = 'Retrieve Radio / Navigation Codes';
            }

            if (this.image && this.image.startsWith('/resource/MyGarage')) {
                this.image = this.image.replace('/resource/MyGarage', this.myGarageResource());
            }

            if (this.isSpecificationsPage) {
                this.pageUrl = sessionStorage.getItem('frompage');
                //this.pageUrl = 'Resources & Downloads';//this.breadcrumbLabel = 'Resources & Downloads';

                let division = this.context.product.division;
                if (division === 'Acura') {
                    this.breadcrumbUrl = '/garage-acura';
                }
                if (division === 'Honda') {
                    this.breadcrumbUrl = '/garage-honda';
                }
                if (division === 'Motorcycle/Powersports') {
                    this.breadcrumbUrl = '/garage-powersports';
                }
                if (division === 'Powerequipment') {
                    this.breadcrumbUrl = '/garage-powerequipment';
                }
                if (this.division === 'Marine') {
                    this.breadcrumbUrl = '/garage-marine';
                }
            }
            if (this.fromPage == 'collisionRepair') {
                this.breadcrumbUrl = '/' + this.brand.toLowerCase() + '-collision-repair';
                this.pageUrl = 'Collision Repair';//this.breadcrumbLabel = 'Collision Repair';
            }

            if (document.location.pathname.includes('tips-marine') || document.location.pathname.includes('tips-power-equipment')) {
                // Store initial subtitle text;
                // Alexander Dzhitenov (Wipro) - added for DOE-6575
                this.subscribeToChannel((message) => {
                    if (message.page === 'Tips' && message.setBreadcrumb) {
                        //console.log('$Tips: ownPageHeader:: setting breadcrumb - ', message.setBreadcrumb);
                        if (message.setBreadcrumb.pageTitle) {
                            this.pageUrl = message.setBreadcrumb.pageTitle;
                        }
                        if (message.setBreadcrumb.pageUrl || message.setBreadcrumb.pageUrl === '') {
                            this.breadcrumbUrl = message.setBreadcrumb.pageUrl;
                            //console.log('$Tips: ownPageHeader:: breadcrumbUrl - ', this.breadcrumbUrl);
                        }
                    }
                    if (message.page === 'Tips' && message.setSubtitle) {
                        //console.log('$Tips: ownPageHeader:: setTitle - ', message.setSubtitle);
                        this.subtitle = message.setSubtitle;
                    }
                    if (message.page === 'Tips' && message.revertHeader) {
                        //console.log('$Tips: ownPageHeader:: previous values - ', this.previousValues);
                        this.subtitle = this.previousValues.subtitle;
                        this.title = this.previousValues.title;
                        this.pageUrl = this.previousValues.pageUrl;
                        this.breadcrumbUrl = this.previousValues.breadcrumbUrl;
                    }
                })
            }
            this.addBreadCrumb();
        } catch (e) {
            this.showData = true;
        }
    };


    async getDetailsFromCMS() {
        //console.log('this.urlStateParameters', this.urlStateParameters);
        let contentKey = this.urlStateParameters ? this.urlStateParameters.key : null;
        if (!contentKey) {
            contentKey = this.getUrlParamValue(window.location.href, 'key');
        }
        this.key = contentKey;
        //console.log('this.this.key-->', this.key);
        let cmsRecords = await getManagedContentByTopicsAndContentKeys([this.key], this.topics, this.pageSize, this.managedContentType);
        //console.log('cmsRecords', cmsRecords);
        cmsRecords.forEach(r => {
            if (r.videoLink) {
                this.subtitle = this.htmlDecode(r.title.value);
            }
        });
    }

    handleBackLinkClick() {

        if((this.pageUrl == 'AcuraLink' || this.pageUrl == 'HondaLink') && window.location.pathname.endsWith('vehicle-data-privacy-settings')){
            sessionStorage.setItem('frompage','My Products');
        }

        if (sessionStorage.getItem('defaulttab') == 'Vehicle Data Privacy') {
            sessionStorage.setItem('defaulttab', 'Default Vehicle Data Privacy Settings');
        } else if (sessionStorage.getItem('fromhowtoguides') && (document.location.pathname.includes('how-to-guides') || document.location.pathname.includes('how-to-category') || document.location.pathname.includes('guide-video-detail'))) {
            let breadcrumbData = JSON.parse(sessionStorage.getItem('fromhowtoguides'));
            breadcrumbData.splice(-1);
            sessionStorage.setItem('fromhowtoguides', JSON.stringify(breadcrumbData));
        }
        let pageTitles = ['Warranty-info', 'HondaCare Protection Plan', 'Vehicle Report'];
        if (pageTitles.includes(document.title) || this.isVideoDetailPage) {
            this.navigate(this.breadcrumbUrl, {});
        }
        if (sessionStorage.getItem('collisionMobile')) {
            sessionStorage.removeItem('collisionMobile');
            this.navigate('/' + this.brand.toLowerCase() + '-collision-repair', {});
        } else if (document.title.includes('Collision Repair') && !sessionStorage.getItem('collisionMobile')) {
            sessionStorage.removeItem('collisionMobile');
            this.navigate(this.breadcrumbUrl, {});
        } else if (window.location.href.includes('recalls-detail') && this.hasSessionbacklink) {
            this.navigate(this.breadcrumbUrl, {});
        } else if (window.location.href.includes('-vehicle-report') && this.hasSessionbacklink) {
            this.navigate(this.breadcrumbUrl, {});
        } else if ((window.location.href.includes('-maintenance-minder') || window.location.href.includes('roadside-assistance') || window.location.href.includes("warranty-info") || window.location.href.includes("marine-serial-number-help")) && this.hasSessionbacklink) {
            this.navigate(this.breadcrumbUrl, {});
        } else if (this.pageUrl == 'MyGarage' && document.location.pathname.includes('radio-nav-code')) {
            this.navigate('/', {});
        } else if (document.location.pathname.includes('tips-marine') || document.location.pathname.includes('tips-power-equipment')) {
            //this.dispatchEvent(new CustomEvent('breadcrumbClick', {pageName : this.pageUrl}));
            //console.log('ownPageHeader:: breadcrumb navigation: ' + this.breadcrumbUrl);
            if (this.breadcrumbUrl != '') {
                this.navigate(this.breadcrumbUrl, {});
            } else if (document.title.includes('Product Registration')) {
                this.navigate(this.breadcrumbUrl, {});
            }
            else {
                this.publishToChannel({ page: 'Tips', headerBreadcrumbClick: true });
            }
        } else if (sessionStorage.getItem('from-page') == 'my-account' && window.location.href.includes(sessionStorage.getItem('to-page'))) {
            sessionStorage.setItem('from-page', '');
            sessionStorage.setItem('to-page', '');
            this.navigate('/my-account?tab=dataprivacy', {});
        } else {
            sessionStorage.setItem('referrer', document.location.href);
            let message = { delay: true, eventType: DATALAYER_EVENT_TYPE.LOAD };
            this.publishToChannel(message);
            history.back();
        }
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    async addBreadCrumb() {
        //console.log('ownPageHeader:: addBreadcrumb');
        try {
            let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
            let context;
            let brand;
            if (fromProductChooser || this.fb == 'true') {
                if (!(document.location.pathname.includes('radio-nav-code') && !this.isGuest && !fromProductChooser) ) { //PAT-35
                    context = await getProductContext('', true);
                } else {
                    context = await getProductContext('', false);
                }
            } else {
                context = await getProductContext('', false);
            }
            //console.log('@@@@context', context);

            if (context && context.product && this.fromPage != 'help-center'){
                this.title = context.product.year + ' ' + context.product.model;
            }
            if(this.divisionId){
                if(this.year && this.model){
                    this.title = this.year + ' ' + this.model;
                }else{
                    this.title = '';
                }
                if (this.divisionId == 'B') {
                    this.image = this.myGarageResource() + '/images/' + AcuraLogo;
                } else {
                    this.image = this.myGarageResource() + '/images/' + HondaLogo;
                }
            }
            if (context && context.product) {
                if (context.product.productIdentifier || (context.product.vin && context.product.vin != '-')) {
                    this.vinNumber = context.product.productIdentifier ? context.product.productIdentifier : context.product.vin;
                    this.hasVin = true;
                }
                if (this.hasVin && context.product.ownershipId) {
                    this.hideEnterVin = true;
                }
                //console.log('CONTEXT-PAGEHEADER: ', context);
                brand = context.product.division;
                this.isPEorMarine = context.product.division == 'Powerequipment' || context.product.division == 'Marine' ? true : false;
                this.isPSP = context.product.division === 'Motorcycle/Powersports' || context.product.division === 'Powersports' ? true : false;
                if (!this.isGuest && window.location.href.includes('recalls-detail') && this.hasVin) {
                    let myProducts = await getMyProducts('');
                    let products = JSON.parse(JSON.stringify(myProducts.products));
                    products.forEach(prod => {
                        if (prod.modelId && prod.modelId == context.product.modelId && !this.hideEnterVin) {
                            this.hideEnterVin = true;
                        }
                    });
                }
            }

            this.fromHowToGudides = sessionStorage.getItem('fromhowtoguides') ? JSON.parse(sessionStorage.getItem('fromhowtoguides')) : [];
            //console.log('this.fromHowToGudides-->', this.fromHowToGudides);
            let currentPage = this.fromHowToGudides ? this.fromHowToGudides[this.fromHowToGudides.length - 1] : '';
            if (currentPage) {
                this.pageUrl = currentPage.label;
                this.breadcrumbUrl = currentPage.url;
                if (currentPage.subTitle) {
                    this.subtitle = currentPage.subTitle;
                }
                if (currentPage.image) {
                    this.image = this.myGarageResource() + '/images/' + currentPage.image;
                }
                if (currentPage.from && currentPage.from == 'help-center')
                    this.title = '';
            } else if (document.location.pathname.includes('how-to-guides')) {
                this.pageUrl = 'Resource & Downloads';
            }

            if (document.title == 'HondaCare Protection Plan') {
                this.showBreadcrumbFlag = true;
                this.pageUrl = 'Powersports: Service & Maintenance';//this.breadcrumbLabel ='Powersports: Service & Maintenance'
                this.breadcrumbUrl = '/honda-powersports-service-maintenance';
            }
            /* if (window.location.href.includes("warranty-info")) {
                this.showBreadcrumbFlag = true;
                if (brand == 'Acura') {
                    this.pageUrl = 'Acura Autos: Service & Maintenance';
                    this.breadcrumbUrl = '/acura-service-maintenance';
                } else if (brand == 'Honda') {
                    this.pageUrl = 'Honda Autos: Service & Maintenance';
                    this.breadcrumbUrl = '/honda-service-maintenance';
                } else if (brand == 'Motorcycle/Powersports' || brand == 'Powersports') {
                    this.pageUrl = 'Powersports: Service & Maintenance';
                    this.breadcrumbUrl = '/honda-powersports-service-maintenance';
                    this.title = context.product.year + ' ' + context.product.model;
                } else if (brand == 'Marine') {
                    this.pageUrl = 'Marine: Service & Maintenance';
                    this.breadcrumbUrl = '/honda-marine-service-maintenance';
                } else if (brand == 'Powerequipment') {
                    this.pageUrl = 'Power Equipment: Service & Maintenance';
                    this.breadcrumbUrl = '/honda-power-equipmnt-service-maintenance';
                }
                this.hasSessionbacklink = true;
            } */
            let backlinkurl = sessionStorage.getItem('backlink');
            if (window.location.href.includes('warranty-info') && backlinkurl) {
                backlinkurl = JSON.parse(backlinkurl);
                this.pageUrl = backlinkurl.label;
                this.breadcrumbUrl = backlinkurl.url;
                this.hasSessionbacklink = true;
                //console.log('@@BACK-LINK-', backlinkurl);
            }
            if (window.location.href.includes('recalls-detail') && backlinkurl) {
                backlinkurl = JSON.parse(backlinkurl);
                this.pageUrl = backlinkurl.label;
                this.breadcrumbUrl = backlinkurl.url;
                this.hasSessionbacklink = true;
                //console.log('@@BACK-LINK-', backlinkurl);
            } else if (window.location.href.includes('recalls-detail') && !backlinkurl && context && context.product) {
                //console.log('@@BACK-LINK-not found1');
                if (context.product.division === 'Motorcycle/Powersports' || context.product.division === 'Powersports') {
                    this.breadcrumbUrl = '/garage-powersports';
                    this.pageUrl = 'Powersports: Overview';
                } else if (context.product.division == 'Acura') {
                    this.breadcrumbUrl = '/garage-acura';
                    this.pageUrl = 'Acura: Overview';
                } else if (context.product.division == 'Honda') {
                    this.breadcrumbUrl = '/garage-honda';
                    this.pageUrl = 'Honda: Overview';
                } else if (context.product.division == 'Marine') {
                    this.breadcrumbUrl = '/garage-marine';
                    this.pageUrl = 'Marine: Overview';
                } else if (context.product.division == 'Powerequipment') {
                    this.breadcrumbUrl = '/garage-powerequipment';
                    this.pageUrl = 'Powerequipment: Overview';
                }
                this.hasSessionbacklink = true;
            }
            else if ((window.location.href.includes('-maintenance-minder') || window.location.href.includes('acura-accelerated-service')) || window.location.href.includes('-vehicle-report') && backlinkurl) {
                backlinkurl = JSON.parse(backlinkurl);
                this.pageUrl = backlinkurl.label;
                this.breadcrumbUrl = backlinkurl.url;
                this.hasSessionbacklink = true;
                //console.log('@@BACK-LINK-', backlinkurl);
            } else if (window.location.href.includes('roadside-assistance')) {
                backlinkurl = JSON.parse(backlinkurl);
                this.pageUrl = backlinkurl.label;
                this.breadcrumbUrl = backlinkurl.url;
                this.hasSessionbacklink = true;
            } else if (document.title.includes('Vehicle Report')) {
                this.showBreadcrumbFlag = true;
                if (brand == 'Acura') {
                    this.pageUrl = 'Service & Maintenance';//this.breadcrumbLabel ='Acura Autos: Service & Maintenance'
                    this.breadcrumbUrl = '/acura-service-maintenance';
                } else if (brand == 'Honda') {
                    this.pageUrl = 'Service & Maintenance';//this.breadcrumbLabel ='Honda Autos: Service & Maintenance'
                    this.breadcrumbUrl = '/honda-service-maintenance';
                }
            }
            else if (document.title.includes('Collision Repair') || this.fromPage == 'Service & Maintenance') {
                this.breadcrumbUrl = '/' + this.brand.toLowerCase() + '-service-maintenance';
                this.pageUrl = 'Service & Maintenance';
            }
            else if (document.title.includes('Marine Serial Number')) {
                this.breadcrumbUrl = '/find-marine';
                let frmPg = sessionStorage.getItem('frompage');
                //console.log('FRMPGE', frmPg);
                switch (frmPg) {
                    case 'Recall Search':
                        this.pageUrl = 'Recall Search';
                        break;
                    case 'Resources & Downloads':
                        this.pageUrl = 'Resources & Downloads';
                        break;
                    default:
                        this.pageUrl = 'Honda Marine: Get Started';
                        break;
                }
                //console.log(this.pageUrl);
                //this.pageUrl = frmPg && frmPg == 'Recall Search' ? 'Recall Search' : 'Honda Marine: Get Started';
                if (frmPg)
                    sessionStorage.removeItem('frompage');
                backlinkurl = JSON.parse(backlinkurl);
                //console.log('&&backlinkurl1', backlinkurl, backlinkurl.label == 'Product Registration')
                if (backlinkurl && backlinkurl.label === 'Product Registration') {
                    //console.log('&&backlinkurl', backlinkurl)
                    this.pageUrl = backlinkurl.label;
                    this.breadcrumbUrl = backlinkurl.url;
                }
                this.image = this.myGarageResource() + '/images/' + 'thumbnail_marine.png';
                this.title = '';
            }
            else if (document.location.pathname.includes('acuralink-product-compatibility') || document.location.pathname.includes('hondalink-product-compatibility') || document.location.pathname.includes('handsfreelink-compatibility-check') || document.location.pathname.includes('bluetooth-compatibility-check')) {
                this.title = '';
            }
            if (document.location.pathname.includes('how-to-category') && sessionStorage.getItem('howtoguides') && this.fb == 'mp') {
                let categoryData = JSON.parse(sessionStorage.getItem('howtoguides'));
                //console.log('categoryData  ', categoryData);
                this.subtitle = categoryData.title ? categoryData.title + ' How-to Guides' : 'How-to Guides';
                this.breadcrumbUrl = '/how-to-guides';
                this.pageUrl = 'My Products';
            }
            else if (document.location.pathname.includes('guide-video-detail') && this.fromPage && this.fromPage != 'resource & downloads') {
                if (this.fromPage == 'connectedfeatures' && sessionStorage.getItem('howtocategory')) {
                    let categoryData = JSON.parse(sessionStorage.getItem('howtocategory'));
                    this.subtitle = categoryData.title ? categoryData.title : '';
                    this.pageUrl = 'Connected Features';
                }
            }

            if (this.isRadioNavPage) {
                //console.log('@@@showBadgeInRadioNav', this.hideProductBadge);
                if (this.fb == 'true') {
                    this.hideProductBadge = false;
                    if (document.location.pathname.includes('radio-nav-result')) {
                        this.title = sessionStorage.getItem('rnv-year') + ' ' + sessionStorage.getItem('rnv-model');;
                        this.image = sessionStorage.getItem('rnv-image');
                    }
                } else {
                    this.hideProductBadge = true;
                    this.title = '';
                    if (!document.location.pathname.includes('radio-nav-result')) {
                        this.pageUrl = 'MyGarage';
                    }
                }
            }
            if (document.location.pathname.includes('manual-request')) {
                this.pageUrl = "Owner's Manuals";
            }
            if (document.location.pathname.includes('roadside-assistance') && this.breadcrumbUrl.includes('help-')) {
                //console.log('ownPageHeader::isRoadsideAssistanceFromHelpCenter');
                this.title = '';
                this.image = '';
            }
            //console.log(' this.fromPage ====>', this.fromPage);
            if (this.fromPage && this.context) {
                //console.log('  this.fromPage ====>', this.fromPage);
                if (this.fromPage == 'garage' && document.location.pathname.includes('acura-accelerated-service')) {
                    this.pageUrl = 'Overview';
                }
                else if (this.fromPage == 'acura service & maintenance' || this.fromPage == 'acura service and maintenance' || this.fromPage == 'honda service & maintenance' || this.fromPage == 'honda service and maintenance') {
                    this.breadcrumbUrl = this.context.product.divisionId == 'A' ? '/honda-service-maintenance' : '/acura-service-maintenance';
                    this.pageUrl = 'Service & Maintenance';
                    sessionStorage.removeItem('frompage');
                }
                //console.log(' this.breadcrumbUrl ====>', this.breadcrumbUrl);
                //console.log(' this.pageUrl ====>', this.pageUrl);
            }
            if (document.location.pathname.includes('collision-repair') && this.fb == 'ff') {
                this.pageUrl = '';
                // this.hideProductBadge = true;
                this.isproductbadge = false;
                this.title = '';
                if (document.location.pathname.includes('acura')) {
                    this.image = this.myGarageResource() + '/images/' + AcuraLogo;
                } else {
                    this.image = this.myGarageResource() + '/images/' + HondaLogo;
                }
            }
            if (/*document.location.pathname.includes('product-registration')*/document.title.includes('Product Registration')) {
                //console.log('Inside Product Registration')
                let division = this.context.product.division;
                this.pageUrl = 'My Products';
                if (division == 'Powerequipment') {
                    //console.log('Inside PE')
                    this.breadcrumbUrl = '/garage-powerequipment';
                } else if (division == 'Marine') {
                    //console.log('Inside Marine')
                    this.breadcrumbUrl = '/garage-marine';
                }
                //console.log('this.breadcrumbUrl, ', this.breadcrumbUrl);
            }
            if (document.location.pathname.includes('tips-marine') || document.location.pathname.includes('tips-power-equipment')) {

                let division;

                this.pageUrl = 'Resources & Downloads';
                let fromPg = sessionStorage.getItem('frompage');

                if (this.context && this.context.product) {
                    division = this.context.product.division;
                }
                if (fromPg && fromPg.toLowerCase().includes('help-marine')) {
                    this.pageUrl = 'Marine: Help Center';
                    this.breadcrumbUrl = '/help-marine';
                    division = 'Marine';
                    this.image = '';
                    this.title = '';
                }
                else if (fromPg && fromPg.toLowerCase().includes('garage-marine')) {
                    this.pageUrl = 'Marine: Overview';
                    this.breadcrumbUrl = '/garage-marine';
                    division = 'Marine';
                }
                else if (fromPg && fromPg.toLowerCase().includes('honda-marine-resources-downloads')) {
                    this.pageUrl = 'Resources & Downloads';
                    this.breadcrumbUrl = '/honda-marine-resources-downloads';
                    division = 'Marine';
                }
                else if (fromPg && fromPg.toLowerCase().includes('honda-power-equipmnt-resources-downloads')) {
                    this.pageUrl = 'Resources & Downloads';
                    this.breadcrumbUrl = '/honda-power-equipment-resources-downloads';
                    division = 'Powerequipment';
                }
                else if (fromPg && fromPg.toLowerCase().includes('honda-power-equipmnt-service-maintenance')) {
                    this.pageUrl = 'Service & Maintenance';
                    this.breadcrumbUrl = '/honda-power-equipment-service-maintenance';
                    division = 'Powerequipment';
                }
                else if (fromPg && fromPg.toLowerCase().includes('garage-powerequipment')) {
                    this.pageUrl = 'Power Equipment: Overview';
                    this.breadcrumbUrl = '/garage-powerequipment';
                    division = 'Powerequipment';
                }
                else {
                    if (division == 'Powerequipment') {
                        this.breadcrumbUrl = '/honda-power-equipment-resources-downloads';
                    } else if (division == 'Marine') {
                        this.breadcrumbUrl = '/honda-marine-resources-downloads';
                    }
                }
                this.brand = division;
                this.previousValues = { title: this.title, subtitle: this.subtitle, pageUrl: this.pageUrl, breadcrumbUrl: this.breadcrumbUrl };
            }
            this.showData = true;
        } catch (e) {
            this.showData = true;
        }
        if (window.location.href.includes('warranty-info?help=marine')) {
            this.title = 'Marine Product';
            this.image = this.myGarageResource() + '/images/thumbnail_marine.png';
        }
        let backlinkurl1 = sessionStorage.getItem('backlink');
        if (window.location.href.includes('marine-serial-number-help') && backlinkurl1) {
            backlinkurl1 = JSON.parse(backlinkurl1);
            this.pageUrl = backlinkurl1.LABEL;
            this.breadcrumbUrl = backlinkurl1.URL;
            this.hasSessionbacklink = true;
            //console.log('@@BACK-LINK-11', backlinkurl1);
        }
    }
    handleEnterVinCLick() {
        sessionStorage.setItem('fromRecallCard', true);
        this.navigate('/enter-vin', {});
    }
    handleAddtoMygarageclick() {
        // this.navigate('/enter-vin',{});
    }
    handleTitleClick() {
        if (document.location.pathname.includes('specifications')) {
            sessionStorage.setItem('referrer', document.location.href);
            let message = { delay: true, eventType: DATALAYER_EVENT_TYPE.LOAD };
            this.publishToChannel(message);
            history.back();
        }
    }
    /* @api setBreadcrumb(breadcrumb){
        if (breadcrumb && breadcrumb.url){
            this.breadcrumbUrl = breadcrumb.url;
        }
        if (breadcrumb && breadcrumb.title){
            this.pageUrl = breadcrumb.title;
        }
    }
    @api
    setTitle(){
        console.log('ownPageHeader:: setTitle');
    }
    @api
    setSubtitle(subtitle){
        this.subtitle = subtitle;
    } */
}
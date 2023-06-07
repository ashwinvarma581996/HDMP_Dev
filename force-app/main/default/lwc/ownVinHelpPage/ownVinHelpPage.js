import { LightningElement, api, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { CurrentPageReference } from 'lightning/navigation';

import { ISGUEST, getContext, getKnowledgeArticle, getRelatedArticles, brandDataCategoryMap, addKnowledgeArticleVote, getGUID, setOrigin, getOrigin } from 'c/ownDataUtils';
import getProductIdentifierArticle from '@salesforce/apex/OwnVINHelpController.getProductIdentifierArticle';
import getProductIdentifierArticleByNumber from '@salesforce/apex/OwnVINHelpController.getProductIdentifierArticleByNumber';

const PAGE_NAMES = {
    FIND_HONDA: 'FindProductHonda',
    FIND_ACURA: 'FindProductAcura',
    FIND_POWERSPORTS: 'FindProductPowersports',
    FIND_POWEREQUIPMENT: 'FindProductPowerequipment',
    FIND_MARINE: 'FindProductMarine',
    ENTER_VIN: 'EnterVIN',
    PRODUCT_SETTINGS: 'ProductSettings',
    ACURA_RESOURCES_DOWNLOADS: 'AcuraResourcesDownloads',
    HONDA_RESOURCES_DOWNLOADS: 'HondaResourcesDownloads',
    POWERSPORTS_RESOURCES_DOWNLOADS: 'PowersportsResourcesDownloads',
    RECALL_DETAIL: 'RecallsDetail',
}

const BREADCRUMB_MAP = new Map([
    [PAGE_NAMES.FIND_HONDA, { NAME: 'Honda Autos: Get Started', LABEL: 'Honda Autos: Get Started', URL: '/find-honda' }],
    [PAGE_NAMES.FIND_ACURA, { NAME: 'Acura Autos: Get Started', LABEL: 'Acura Autos: Get Started', URL: '/find-acura' }],
    [PAGE_NAMES.FIND_POWERSPORTS, { NAME: 'Powersports: Get Started', LABEL: 'Powersports: Get Started', URL: '/find-powersports' }],
    [PAGE_NAMES.FIND_POWEREQUIPMENT, { NAME: 'Power Equipment: Get Started', LABEL: 'Power Equipment: Get Started', URL: '/find-powerequipment' }],
    [PAGE_NAMES.FIND_MARINE, { NAME: 'Honda Marine: Get Started', LABEL: 'Honda Marine: Get Started', URL: '/find-marine' }],
    [PAGE_NAMES.ENTER_VIN, { NAME: 'Enter VIN', LABEL: 'Enter VIN', URL: '/enter-vin' }],
    [PAGE_NAMES.PRODUCT_SETTINGS, { NAME: 'Edit Settings', LABEL: 'Edit Settings', URL: '/product-settings' }],
    [PAGE_NAMES.ACURA_RESOURCES_DOWNLOADS, { NAME: 'Resources & Downloads', LABEL: 'Resources & Downloads', URL: '/acura-resources-downloads' }],
    [PAGE_NAMES.HONDA_RESOURCES_DOWNLOADS, { NAME: 'Resources & Downloads', LABEL: 'Resources & Downloads', URL: '/honda-resources-downloads' }],
    [PAGE_NAMES.RECALL_DETAIL, { NAME: 'Recalls Detail', LABEL: 'Recalls Detail', URL: '/recalls-detail' }],
    [PAGE_NAMES.POWERSPORTS_RESOURCES_DOWNLOADS, { NAME: 'Resources & Downloads', LABEL: 'Resources & Downloads', URL: '/honda-powersports-resources-downloads' }]
]);

export default class ownVinHelpPage extends OwnBaseElement {
    @track vehicleNickname;
    @track year;
    @track modelName;
    @track trim;
    @track title = "Vehicle Identification Number (VIN)";
    @track image;
    @track customImage;

    @api vinArticleId;
    @track metadataArticleId;

    @track results;
    @track brand = {};
    @track brandName = "Honda";
    @track brandLabel;
    @track categoryLabel;
    @track relatedResults;
    @track maxResults = 3;
    @track hasResults = false;
    @track isGuest = ISGUEST;
    @track isVoted = false;
    @track guestId;
    @track context;
    @track hasContext;
    @track fromProductChooser;
    @track showBreadcrumb;
    @track fp='';

    hondaLogoSrc = '/resource/Owners/images/garage_hondadefault.svg';
    acuraLogoSrc = '/resource/Owners/Logos/honda_acura.svg';
    powersportsLogoSrc = '/resource/Owners/Logos/honda_powersports.svg';
    powerequipmentLogoSrc = '/resource/Owners/Logos/honda_equipment.svg';
    marineLogoSrc = '/resource/Owners/Logos/honda_marine.svg';

    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));

    @track breadcrumb;

    currentPageReference = null;
    urlStateParameters = null;

    /* Params from Url */
    urlId = null;
    urlLanguage = null;
    urlType = null;

    @track contextPage;

       @wire(CurrentPageReference)
        getStateParameters(currentPageReference) {
           if (currentPageReference) {
              this.urlStateParameters = currentPageReference.state;
              this.setParametersBasedOnUrl();
           }
        }
     
         setParametersBasedOnUrl() {
          //  this.modelName = this.urlStateParameters.model || null;
          this.fp=this.urlStateParameters.fp || null;
        } 

    get displayArticleTitle(){
        return this.brandName === 'Powersports' || this.brandName === 'Motorcycle/Powersports';
    }

    connectedCallback(){
        //console.log('******FROMPAGE: ' + sessionStorage.getItem('frompage'));
        if (ISGUEST){
            if (!localStorage.getItem('guestId')){
                this.initializeGetGUID();
            } else{
                this.guestId = localStorage.getItem('guestId');
            }
        }
        this.initialize();
    }

    initialize = async () => {

        this.context = await getContext();

        //console.log('context: ' + JSON.stringify(this.context));

        let model = ((new URL(window.location.href)).searchParams.get("model"));
        //console.log(model);

        this.fromProductChooser = getOrigin() === 'ProductChooser' && !this.isGuest ? true : false;

        // If the model parameter is passed in:
        // If from Product Chooser (navigating from EnterVin, but the product was added through Product Chooser), the product is not added to
        // the garage - and must be retrieved from garageProducts[0]
        // If not from Product Chooser, the product is added to the garage - and must be retrieved from context.
        let backlink = sessionStorage.getItem('backlink');
        //console.log(JSON.stringify(backlink));
        //console.log(localStorage.getItem('VINHelpBreadcrumb'));
        if ((new URL(window.location.href)).searchParams.get("frompage")) {
            //console.log('Setting breadcrumb from URL param')
            this.breadcrumb = BREADCRUMB_MAP.get((new URL(window.location.href)).searchParams.get("frompage"));
            //console.log('breadcrumb RD', JSON.stringify(this.breadcrumb));
            this.showBreadcrumb = true;
        }
        else if (localStorage.getItem('VINHelpBreadcrumb')){
            //console.log('Setting bradcrumb from VINHelpBreadcrumb');
            this.breadcrumb = BREADCRUMB_MAP.get(localStorage.getItem('VINHelpBreadcrumb'));
            this.showBreadcrumb = true;
        }
        else if (backlink){
            //console.log('$VinHelp - Setting breadcrumb from backlink');
            this.breadcrumb = JSON.parse(backlink);
            //console.log('$VinHelp - this.breadcrumb : ', JSON.parse(JSON.stringify(this.breadcrumb)));
            // sessionStorage.removeItem('backlink');
            this.showBreadcrumb = true;
        }
        else{
            //console.log('$VinHelp Breadcrumb not set.');
            this.showBreadcrumb = false;
        }
        // this.breadcrumb = BREADCRUMB_MAP.get(localStorage.getItem('VINHelpBreadcrumb'));

        let contextPageSet = new Set(['/enter-vin', '/product-settings', '/acura-resources-downloads', '/honda-resources-downloads', '/honda-powersports-resources-downloads']);

        /* switch (this.breadcrumb.URL){
            case '/enter-vin':
            case '/product-settings':
            case '/acura-resources-downloads':
            case '/honda-resources-downloads':
            case '/honda-powersports-resources-downloads':
                this.contextPage = true;
            default:
                this.contextPage = false;
        } */

        this.contextPage = contextPageSet.has(this.breadcrumb.URL);

        if (this.contextPage/*  && this.breadcrumb.url === '/enter-vin' */){
            //console.log('ownVinHelpPage: on context page');
            //console.log(this.isGuest);
            //console.log(getOrigin() === 'ProductChooser');
            this.fromProductChooser = getOrigin() === 'ProductChooser' && !this.isGuest;
            //console.log('Enter VIN fromProductChooser: ' + this.fromProductChooser);

            // Alexander Dzhitenov (Wipro) DOE-6045: Read context from local storage if user is a guest user (in this case, server storage cannot be retrieved), or
            // if user is viewing a product that has not been added to their garage
            let readLocalContext = getOrigin() === 'ProductChooser' || this.isGuest;
            //console.log('ownVinHelpPage:: readLocalContext: ' + readLocalContext);

            let garageProducts = JSON.parse(localStorage.getItem('garage'));
            //console.log('ownVinHelpPage:: garage: ' + JSON.stringify(garageProducts.products));
            //console.log('ownVinHelpPage:: ' + garageProducts.products[0].model);
            this.year =     readLocalContext ? garageProducts.products[0].year : this.context.product.year;
            this.modelName =    readLocalContext ? garageProducts.products[0].model : this.context.product.model;
            this.trim =     readLocalContext ? garageProducts.products[0].trim : this.context.product.trim;
            this.image =    readLocalContext ? garageProducts.products[0].image : this.context.product.productDefaultImage;
            //console.log('ownVinHelpPage:: ' + this.model);
        }
        /* else if (this.contextPage && this.breadcrumb.url != '/enter-vin') {
            this.year = this.context.product.year;
            this.modelName = this.context.product.model;
            this.trim = this.context.product.trim;
            this.image = this.context.product.productDefaultImage;
        } */
        else{
            this.year = '';
            this.modelName = '';
            this.trim = '';
            this.image = '';
        }

        /* if (this.breadcrumb.url === '/enter-vin'){
            this.context = localSsessionStorage.getItem('enterVinProductContext')
        } */

        //console.log('BREADCRUMB set to: ');
        //console.log(JSON.stringify(this.breadcrumb));

        /* if (model){
            console.log('ownVinHelpPage:: model block running' );
            let garageProducts = JSON.parse(localStorage.getItem('garage'));
            console.log(JSON.stringify(garageProducts));
            console.log(this.fromProductChooser);
            this.year = this.fromProductChooser ? garageProducts.products[0].year : this.context.product.year;
            this.modelName = this.fromProductChooser ? garageProducts.products[0].model : this.context.product.model;
            this.trim = this.fromProductChooser ? garageProducts.products[0].trim : this.context.product.trim;
            this.brandName = this.fromProductChooser ? garageProducts.products[0].division : this.context.product.division;
            let customVehicleImage = this.fromProductChooser ? '' : this.context.product.customerUploadedImage;
            let defaultVehicleImage = this.fromProductChooser ? garageProducts.products[0].image : this.context.product.productDefaultImage;
            let logoImage = this.fromProductChooser ? garageProducts.products[0].image : this.context.product.image;

            if (customVehicleImage){
                this.image = customVehicleImage;
            }
            else if (defaultVehicleImage){
                this.image = defaultVehicleImage;
            }
            else {
                this.image = this.baseURL + logoImage;
            }

            this.hasContext = this.modelName === model ? true : false;
        } */
        //else {
            this.brandName = ((new URL(window.location.href)).searchParams.get("division"));
        //}
        //console.log(this.guestId);
        //console.log('Before results: ');
        this.results = await this.getArticle(this.brandName, this.guestId);
        //console.log('Results: ');
        //console.log(JSON.stringify(this.results));

        //console.log('Result: ' + JSON.stringify(this.results));
        if (this.results){
            this.metadataArticleId = this.results.id;
        }
        if (this.results.hasOwnProperty('vote')){
            this.isVoted = true;
        }
        this.brand = {label: this.results.title, value: this.results.id, type: 'article', articleBrand: this.brandName === 'Honda' ? null : this.brandName, url: ''};
        //console.log(JSON.stringify(this.brand));
        this.initializeRelatedArticles();
        /*         this.brandLabel = this.brandName === 'Honda' ? 'Honda' : brandDataCategoryMap.get(this.brandName).label;
                if(this.brandName === 'Honda'){
                    this.categoryLabel = 'Popular Articles & FAQs';
                }else{
                    this.categoryLabel = this.results.categories[0].label;
                } */

        if(this.fp === 'rn'){
           this.breadcrumb={ NAME: 'Retrieve Radio / Navigation Codes', LABEL: 'Retrieve Radio / Navigation Codes', URL: '' };
        }        
    };

    getArticle = async(brandName, guestId) => {
        let article;
        let brandSearchName = (brandName === 'Powersports' ? 'Motorcycle/Powersports' : brandName);
        await getProductIdentifierArticleByNumber({ divisionName: brandSearchName, guestId: guestId })
            .then(result => { article = result; })
            .catch(error => { console.log(JSON.stringify(error)); }
            );
        return article;
    }

    initializeRelatedArticles = async() => {
        let category;
        switch (this.brandName){
            case 'Honda':
                category = 'HondaAutos';
                break;
            case 'Acura':
                category = 'AcuraAutos';
                break;
            case 'Powersports':
            case 'Motorcycle/Powersports':
                category = 'HondaPowersports';
                break;
        }
        this.relatedResults = await getRelatedArticles(this.results.title, category /* this.brandName === 'Honda' ? null : this.brandName */, this.maxResults);
        if (this.relatedResults.length > 0) {
            this.hasResults = true;
        } else {
            this.hasResults = false;
        }
    };

    initializeGetGUID = async() => {
        this.guestId = await getGUID();
        localStorage.setItem('guestId', this.guestId);
    };

    handleClick(event){
        let id = event.currentTarget.dataset.id;
        let urlName = event.currentTarget.dataset.urlname;
        this.navigate('/article/' + urlName + '?' + 'brand=' + this.brandName, {});
    }

    handleBreadcrumbClick(event){
        //console.log(event.currentTarget.dataset.label);
        //console.log(event.currentTarget.dataset.url);
       
        if(this.fp === 'rn'){
            history.back();
        }else{
            this.navigate(event.currentTarget.dataset.url, {});
        }
    }

    /*     initializeBreadcrumb(){
            let originPage = localStorage.getItem('VINHelpBreadcrumb');
    
            this.breadcrumb = 
        } */
}
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { viewProduct, setOrigin, getOrigin } from 'c/ownDataUtils';
import getProductChooserControl from '@salesforce/apex/FindProductController.getProductChooserControl';
import getProductChooserData from '@salesforce/apex/FindProductController.getProductChooserData';
import getProductByProductChooser from '@salesforce/apex/OwnGarageController.getProductByProductChooser';
import getRecallsByModelId from '@salesforce/apex/OwnAPIController.getRecallsByModelId';
import getUserGarageForModelId from '@salesforce/apex/OwnGarageController.getUserGarageForModelId';
import { ISGUEST } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

const FIND_BRAND_BUTTON_ACTIVE = 'find-brand-button-active';
const FIND_BRAND_BUTTON_DISABLED = 'find-brand-button-disabled';
const FIND_BRAND_SECTION_BUTTON_ACTIVE = 'find-brand-section-button-active';
const FIND_BRAND_SECTION_BUTTON_DISABLED = 'find-brand-section-button-disabled';

export default class OwnFindProductsDropdowns extends OwnBaseElement {
    @api division = "Honda";
    @track divisionName = 'Honda';
    @track divisionId = 'A';
    /*     @track controlArray = [];
    @track chooserData; */
    @track dropdownArray = [];
    @track dropdownData = [];
    @track dropdownOptions = [];
    @track highestFilledTier = 0;
    //@track extraSpaces = [];

    @track selectedValues;

    tiers = [{ name: 'Tier1__c', number: 1 }, { name: 'Tier2__c', number: 2 }, { name: 'Tier3__c', number: 3 },
    { name: 'Tier4__c', number: 4 }, { name: 'Tier5__c', number: 5 }, { name: 'Tier6__c', number: 6 }];

    tierNameMap = new Map([[1, 'Tier1__c'], [2, 'Tier2__c'], [3, 'Tier3__c'], [4, 'Tier4__c'], [5, 'Tier5__c'], [6, 'Tier6__c']]);
    maxTier;
    @track selectedElement;

    @track modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track vinFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track modelSectionButtonClass = FIND_BRAND_SECTION_BUTTON_ACTIVE;
    @track vinSectionButtonClass = FIND_BRAND_SECTION_BUTTON_DISABLED;

    @track showModelSection = true;
    @track isDropdownLoaded = false;
    @track showChooserError = false;
    @api buttonLabel = 'FIND';
    warningicon;
    get dropdownListMultipleRows() {
        return this.dropdownArray.length > 3;
    }

    get findByYMTButtonClass() {
        return (this.highestFilledTier === this.maxTier ? FIND_BRAND_BUTTON_ACTIVE : FIND_BRAND_BUTTON_DISABLED);
    }

    tierIterator(tier) {
        return tier - 1;
    }

    connectedCallback() {
        this.divisionName = this.division;
        this.warningicon = this.myGarageResource() + '/ahmicons/warning.png';
        let brandNameMap = new Map([
            ['Honda', 'Honda'], ['Acura', 'Acura'], ['Powersports', 'Motorcycle/Powersports']
        ]);
        if (this.divisionName === 'Marine' || this.divisionName === 'Power Equipment') {
            this.showModelSection = false;
            this.isDropdownLoaded = true;
        }
        else {
            getProductChooserControl({ division: brandNameMap.get(this.divisionName) })
                .then(result => {
                    //console.log('@@getProductChooserControl: ', result);
                    if (result) {
                        let chooserControl = result;
                        chooserControl.sort(function (a, b) { return (a.Tier_Number__c - b.Tier_Number__c) });
                        chooserControl.forEach(element => {
                            if (element.Product_Subdivision__c === brandNameMap.get(this.divisionName)) {
                                this.dropdownArray.push({ 'controlData': element });
                            }
                        });
                        this.maxTier = this.dropdownArray[this.dropdownArray.length - 1].controlData.Tier_Number__c;
                        this.selectedValues = new Array(this.maxTier);
                        //console.log(JSON.stringify(this.dropdownArray));                
                        getProductChooserData({ division: brandNameMap.get(this.divisionName) })
                            .then(result => {
                                if (result) {
                                    //console.log(JSON.stringify(result));                            
                                    result.forEach(element => {
                                        if (element.Product_Subdivision__c === brandNameMap.get(this.divisionName)) {
                                            this.dropdownData.push(element);
                                        }
                                    });
                                    this.showChooserError = false;
                                    this.isDropdownLoaded = true;
                                    //console.log(JSON.stringify(this.dropdownData));                            
                                    //this.getYears();
                                }
                                else {
                                    this.showModelSection = false;
                                    this.showChooserError = true;
                                    this.isDropdownLoaded = true;
                                    //console.log('Second product chooser setting error: ', this.showChooserError);
                                }
                            })
                            .catch(error => {
                                this.showModelSection = false;
                                this.showChooserError = true;
                                this.isDropdownLoaded = true;
                                //console.log(JSON.stringify(error));
                                //console.log('Second product chooser setting error: ', this.showChooserError);
                            });
                    }
                    else {
                        this.showModelSection = false;
                        this.showChooserError = true;
                        this.isDropdownLoaded = true;
                        //console.log('Second product chooser setting error: ', this.showChooserError);
                    }
                })
                .catch(error => {
                    this.showModelSection = false;
                    this.showChooserError = true;
                    this.isDropdownLoaded = true;
                    //console.log(JSON.stringify(error));
                    //console.log('Second product chooser setting error: ', this.showChooserError);
                });
        }

        if (this.divisionName === "Honda")
            this.divisionId = "A";
        else if (this.divisionName === "Acura")
            this.divisionId = "B";
        else if (this.divisionName === "Powersports")
            this.divisionId = "M";
        else if (this.divisionName === "Power Equipment")
            this.divisionId = "PE";
        else if (this.divisionName === "Marine")
            this.divisionId = "PE";
        else
            this.divisionId = "A";

        //console.log('Show model section: ' + this.showModelSection);
        //console.log('Show chooser error: ' + this.showChooserError);

        let path = window.location.href;
        let endpoint = path.substring(path.lastIndexOf('/') + 1);
        //console.log('endpoint at ownFindProducts ----> ', endpoint);

    }


    handleOptionSelect(event) {
        //console.log('OPTION SELECT');
        let tier = event.detail.tier;
        //console.log('tier info');
        //console.log(tier);
        //console.log(typeof (tier));
        let value = event.detail.value;
        //this.selectedValues.set(tier, value);
        this.selectedValues[this.tierIterator(tier)] = value;
        this.highestFilledTier = tier;

        // clear all values for tiers above the most recently selected one
        for (let i = tier + 1; i <= this.maxTier; ++i) {
            //console.log(i);
            //this.selectedValues.set(i, '');
            this.selectedValues[this.tierIterator(i)] = '';
        }

        if (this.highestFilledTier === this.maxTier) {
            // Test code; check if product with found details exists in initial data
            //console.log('***All values selected, running check: ***');
            let elementExists = false;
            let matchingElements = [];
            this.dropdownData.forEach(element => {
                let allTierValuesFound = true;
                for (let i = 1; i <= this.maxTier; ++i) {
                    if (!(element['Tier' + i + '__c'] === this.selectedValues[i - 1])) {
                        allTierValuesFound = false;
                    }
                }
                /* this.selectedValues.forEach(function(value, key){
                    if (!(element['Tier' + key + '__c'] === value)){
                        allTierValuesFound = false;
                    }
                }); */
                if (allTierValuesFound) {
                    elementExists = true;
                    matchingElements.push(element);
                }
            });
            //console.log('*Result: ' + elementExists + ';');
            //console.log('*Element: ');
            //console.log(JSON.stringify(matchingElements));
            //console.log('*******************************************');
            this.selectedElement = matchingElements;
        }

        // Debug code
        /* this.selectedValues.forEach(function(value, key){
            console.log('Parent '  + ' key: ' + key + ', value: ' + value);
        }) */
        //

        //this.template.querySelector("c-own-find-products-combobox").logValues();
    }


    handleFindByProductChooser() {
        if (window.location.href.includes('recall-search')) {
            let backLink = {
                label: document.title,
                url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
            };
            backLink.label = 'Recall Search: ' + this.capitalizeFirstLetter(backLink.url.substring(backLink.url.indexOf('=') + 1));
            sessionStorage.setItem('backlink', JSON.stringify(backLink));
        }
        if (window.location.href.includes('warranty-search')) {
            let backLink = {
                label: document.title,
                url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
            };
            backLink.label = 'Warranty Search: ' + this.capitalizeFirstLetter(backLink.url.substring(backLink.url.indexOf('=') + 1));
            sessionStorage.setItem('backlink', JSON.stringify(backLink));
        }
        /* let tierValues = [];
        this.dropdownArray.forEach(element => {
            tierValues.push({tierNumber : element.Tier_Number__c, tierName : element})
        }) */
        //console.log('Calling Apex');
        //console.log(JSON.stringify(this.selectedElement));
        getProductByProductChooser({ productChooserStr: JSON.stringify(this.selectedElement) })
            .then(result => {
                //console.log(JSON.stringify(result));
                //console.log(this.divisionName);
                let divisionLogo;
                if (this.divisionName === 'Honda') {
                    divisionLogo = '/resource/MyGarage/img/thumbnail_honda.png'; //'/cms/delivery/media/MCYYDI357BSZDS5FXGPSPN5AH4AQ';
                }
                else if (this.divisionName === 'Acura') {
                    divisionLogo = '/resource/MyGarage/img/thumbnail_acura.png'; //'/cms/delivery/media/MCZYP2ZIWGIJCNTB5TO4LRLE4TFY';
                }
                else if (this.divisionName === 'Powersports') {
                    divisionLogo = '/resource/MyGarage/img/thumbnail_powersports.png'; //'/cms/delivery/media/MCQJUU7MKCERCYBL77NG7CTXBDQU';
                }
                else if (this.divisionName === 'Powerequipment') {
                    divisionLogo = '/resource/MyGarage/img/thumbnail_powerequipment.png'; //'/cms/delivery/media/MCMFYJERXT4ZD6XDGL6HZ7GGNZ4U';
                }
                else if (this.divisionName === 'Marine') {
                    divisionLogo = '/resource/MyGarage/img/thumbnail_marine.png'; //'/cms/delivery/media/MCRIYJTYRG7FB23N4324ABJESWL4';
                }
                //console.log(divisionLogo);
                //console.log(1);
                let product = {
                    'divisionId': this.divisionId, 'division': this.divisionName,
                    'year': result.Model_Year__c.toString(), 'model': result.Model_Name__c, 'trim': result.Trim__c,
                    'modelId': result.Product_Model_ID__c,
                    'vin': '-',
                    'image': result.Product_Model_Colors__r ? result.Product_Model_Colors__r[0].Thumbnail_Image_URL__c ? result.Product_Model_Colors__r[0].Thumbnail_Image_URL__c : divisionLogo : divisionLogo,
                    'exteriorColor': result.Product_Model_Colors__r ? result.Product_Model_Colors__r[0].Exterior_Color_Name__c : '-'
                };
                product.color = {};
                product.color.name = result.Product_Model_Colors__r ? result.Product_Model_Colors__r[0].Exterior_Color_Name__c : '-';
                product.color.mfg_color_cd = result.Product_Model_Colors__r ? result.Product_Model_Colors__r[0].Manufacturer_Color_Code__c : '';
                //console.log('Child Component Product: ', product);
                // product.modelId = 'TC1H6KKNW';
                let eventMetadata = {
                    action_type: 'button',
                    action_category: 'body',
                    action_label: 'find'
                };
                let findProductDetails = {}
                findProductDetails.brandName = this.divisionName;
                if (this.selectedElement[0].Tier1__c) { findProductDetails.Tier1__c = this.selectedElement[0].Tier1__c };
                if (this.selectedElement[0].Tier2__c) { findProductDetails.Tier2__c = this.selectedElement[0].Tier2__c };
                if (this.selectedElement[0].Tier3__c) { findProductDetails.Tier3__c = this.selectedElement[0].Tier3__c };
                if (this.selectedElement[0].Tier4__c) { findProductDetails.Tier4__c = this.selectedElement[0].Tier4__c };
                if (this.selectedElement[0].Tier5__c) { findProductDetails.Tier5__c = this.selectedElement[0].Tier5__c };
                if (product.modelId) { findProductDetails.model_id = product.modelId }
                let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata, findProductDetails: findProductDetails };
                if (this.buttonLabel == 'FIND' && (document.location.pathname.includes('find-') || document.location.pathname.includes('garage-') ||
                    document.location.pathname.includes('-service-maintenance') || document.location.pathname.includes('-connected-features') ||
                    document.location.pathname.includes('-marketplace') || document.location.pathname.includes('-financial-services') ||
                    document.location.pathname.includes('-resources-downloads'))) {
                    this.publishToChannel(message);
                }

                if (!ISGUEST) {
                    getUserGarageForModelId({
                        'modelId': product.modelId
                    })
                        .then(result => {
                            product['ownershipId'] = result;
                        })
                        .catch(error => {
                            //console.log(JSON.stringify(error));
                        })
                }
                getRecallsByModelId({ modelId: product.modelId, divisionId: product.divisionId }).then((res => {
                    //console.log('MyModel-RESULT: ', res);
                    if (res.response.recalls_response.response.recall.campaignType.campaign) {
                        let result = JSON.parse(JSON.stringify(res.response.recalls_response.response.recall.campaignType.campaign));
                        product['recalls'] = result;
                        this.dispatchEvent(new CustomEvent('productfound', { detail: product }));
                    } else {
                        this.dispatchEvent(new CustomEvent('productfound', { detail: product }));
                    }
                })).catch(err => {
                    //console.error('RECALLS: err2', err);
                    this.dispatchEvent(new CustomEvent('productfound', { detail: product }));
                });
                // this.dispatchEvent(new CustomEvent('productfound', {detail : product}));
            })
            .catch(error => { //console.log(JSON.stringify(error));
             });
    }
    capitalizeFirstLetter(str) {
        return str.charAt(0).toUpperCase() + str.toLowerCase().slice(1);
    }
}
/* ============================================================================
// Title:    Honda Owners Product Chooser
//
// Summary:  This is the component seen on the find products pages
//
// Details:  Allows the user to search for a vehicle using a data-driven set of dropdown menus,
//           or a unique product identifier.
//
//
// History:
// Fri Dec 31, 2021 Alexander D. (initial coding, based on existing ownFindProductsAuto and ownGarageFindPowersports components)
//===========================================================================  */


import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
//Imtiyaz - RECALLS Start
import { viewProduct, setOrigin, getOrigin, getDate} from 'c/ownDataUtils';
//Imtiyaz - RECALLS End
//import getDivisionHonda from '@salesforce/apex/FindProductsController'
/* import getYears from '@salesforce/apex/FindProductController.getYears';
import getModels from '@salesforce/apex/FindProductController.getModels';
import getTrims from '@salesforce/apex/FindProductController.getTrims'; */
import getProductChooserControl from '@salesforce/apex/FindProductController.getProductChooserControl';
import getProductChooserData from '@salesforce/apex/FindProductController.getProductChooserData';
import getUserGarageForVIN from '@salesforce/apex/OwnGarageController.getUserGarageForVIN';
//import getValidVINHonda from '@salesforce/apex/FindProductsController.getValidVINHonda';
import getRecallsByProductIdentifier from '@salesforce/apex/OwnAPIController.getRecallsByProductIdentifier';

// Commented out - methods currently do not exist
//import getProductByYearModel from '@salesforce/apex/OwnGarageController.getProductByYearModel';
import getProductByProductChooser from '@salesforce/apex/OwnGarageController.getProductByProductChooser';
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';

import commonResources from "@salesforce/resourceUrl/Owners";

import { ISGUEST } from 'c/ownDataUtils';

import { CurrentPageReference } from 'lightning/navigation';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';


const LEFT_SECTION_TITLE_TEXT = {
    'Honda': 'Find Your Honda',
    'Acura': 'Find Your Acura',
    'Powersports': 'Find Your Honda Powersports Vehicle',
    'Power Equipment': 'Find Your Honda Power Equipment',
    'Marine': 'Find Your Honda Marine Outboard'
};

const PC_TEXT = {
    'Honda': 'Enter your year, model, and trim for information about your Honda.',
    'Acura': 'Get information about your Acura based on its year, model, and trim.',
    'Powersports': 'Find your Powersports vehicle based on its year and category.',
    'Power Equipment': 'Enter your serial number for details personalized to your product.',
    'Marine': 'Enter your serial number for details personalized to your product.'
};

const VIN_TEXT = 'Enter your VIN number for details personalized to your vehicle.';

const SN_TEXT = 'Enter your serial number for details personalized to your product.';

const MODEL = 'model';
const VIN = 'vin';
const FIND_BRAND_BUTTON_ACTIVE = 'find-brand-button-active';
const FIND_BRAND_BUTTON_DISABLED = 'find-brand-button-disabled';
const FIND_BRAND_SECTION_BUTTON_ACTIVE = 'find-brand-section-button-active';
const FIND_BRAND_SECTION_BUTTON_DISABLED = 'find-brand-section-button-disabled';

const VIN_ERROR_TEXT = "Incorrect VIN entered.";

const PREFERRED_VIN_IMAGE_TYPE = "IMGMIDSIZE";

const VIN_DATABASE_ERROR = 'Your VIN is currently not supported by MyGarage.';


export default class ownFindProducts extends OwnBaseElement {

    @api division = "Honda";
    @track divisionName = 'Honda';
    @track divisionId = 'A';

    @track isGuest = ISGUEST;

    /*     @track controlArray = [];
        @track chooserData; */
    @track dropdownArray = [];
    @track dropdownData = [];
    @track dropdownOptions = [];
    @track highestFilledTier = 0;
    //@track extraSpaces = [];

    @track selectedValues = new Map();

    tiers = [{ name: 'Tier1__c', number: 1 }, { name: 'Tier2__c', number: 2 }, { name: 'Tier3__c', number: 3 },
    { name: 'Tier4__c', number: 4 }, { name: 'Tier5__c', number: 5 }, { name: 'Tier6__c', number: 6 }];

    tierNameMap = new Map([[1, 'Tier1__c'], [2, 'Tier2__c'], [3, 'Tier3__c'], [4, 'Tier4__c'], [5, 'Tier5__c'], [6, 'Tier6__c']]);
    maxTier;
    @track selectedElement;

    @track allowedOptions;

    @track showModelSection = true;
    @track showVinSection = true;
    @track showChooserError = false;
    @track modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track vinFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track modelSectionButtonClass = FIND_BRAND_SECTION_BUTTON_ACTIVE;
    @track vinSectionButtonClass = FIND_BRAND_SECTION_BUTTON_DISABLED;
    @track years;
    @track year;
    @track models;
    @track model;
    @track modelLabel;
    @track trims;
    @track trim;
    @track modelId;
    @track vin;
    @track incorrectVINLength = false;
    @track correctVINLength = false;
    @track modelSelectionDisabled = true;
    @track trimSelectionDisabled = true;
    @track displayVINError = false;
    @track vinInputVal = "";

    @track isCompatibilityPage = false;
    @track isFindPage = false;
    @track isPhoneCompatibilityPage = false;
    paddingClass = '';

    @track isVinDatabaseError = false;

    //Imtiyaz - RECALLS Start
    get getDate(){
        return window.location.pathname.includes('find-powersports') || window.location.pathname.includes('find-honda') || window.location.pathname.includes('find-acura') ? getDate(7) : false;
    }
    //Imtiyaz - RECALLS End


    get leftSectionTitleText() {
        return LEFT_SECTION_TITLE_TEXT[this.divisionName];
    }

    get pcText() {
        return PC_TEXT[this.divisionName];
    }

    get snvinText() {
        return (this.divisionName === 'Power Equipment' || this.divisionName === 'Marine') ? SN_TEXT : VIN_TEXT;
    }


    get vehicleText() {
        switch (this.divisionName) {
            case "Honda":
                return {/* bannerText : 'Honda Auto',  */headerText: 'Honda', descriptionText: 'Get information about your Honda based on its year and model' };
            case "Acura":
                return {/* bannerText : 'Acura Auto',  */headerText: 'Acura', descriptionText: 'Get information about your Acura based on its year and model' };
            case "Powersports":
                return {/* bannerText : 'Powersports Vehicle',  */headerText: 'Honda Powersports Vehicle', descriptionText: 'Find your Powersports vehicle by selecting its type, model, and trim.' };
            case "Power Equipment":
                return {/* bannerText : 'Power Equipment',  */headerText: 'Honda Power Equipment', descriptionText: 'Find your Power Equipment by selecting a product, type, and model' };
            case "Marine":
                return {/* bannerText : 'Honda Marine Product',  */headerText: 'Honda Marine Product', descriptionText: 'Find your Honda Marine product by selecting an outboard and model' };
        }
    }

    get productIdentifierUppercase() {
        switch (this.divisionName) {
            case "Honda":
                return "VIN Number";
            case "Acura":
                return "VIN Number";
            case "Powersports":
                return "VIN Number";
            case "Power Equipment":
                return "Serial Number";
            case "Marine":
                return "Serial Number";
        }
    }

    get productIdentifierLowercase() {
        switch (this.divisionName) {
            case "Honda":
                return "VIN number";
            case "Acura":
                return "VIN number";
            case "Powersports":
                return "VIN number";
            case "Power Equipment":
                return "serial number";
            case "Marine":
                return "serial number";
        }
    }

    get productIdentifierEntryPlaceholder() {
        let str = 'Enter ';
        switch (this.divisionName) {
            case "Honda":
                return str + "VIN";
            case "Acura":
                return str + "VIN";
            case "Powersports":
                return str + "VIN";
            case "Power Equipment":
                return str + "Serial Number";
            case "Marine":
                return str + "Serial Number";
        }
    }

    get prodIdMinLength() {
        return this.divisionId != 'PE' ? 17 : 4;
    }

    get prodIdMaxLength() {
        return this.divisionId != 'PE' ? 17 : 20;
    }

    get dropdownListMultipleRows() {
        return this.dropdownArray.length > 3;
    }

    get findByYMTButtonClass() {
        return (this.highestFilledTier === this.maxTier ? FIND_BRAND_BUTTON_ACTIVE : FIND_BRAND_BUTTON_DISABLED);
    }

    get displayProductChooser() {
        return (this.divisionName === "Power Equipment" || this.divisionName === "Marine") ? false : true;
    }

    get vinErrorText() {
        if (this.isVinDatabaseError) {
            return VIN_DATABASE_ERROR;
        }
        else {
            return "Incorrect " + this.productIdentifierLowercase + " entered.";
        }
    }

    vinHelpIcon = commonResources + '/Icons/garage_questionmark.png';

    @wire(CurrentPageReference) pageref;

    connectedCallback() {
        //console.log('BREADCRUMB TEST ' + sessionStorage.getItem('vinHelpBreadcrumb'));
        if (sessionStorage.getItem('vinHelpBreadcrumb')) {
            sessionStorage.removeItem('vinHelpBreadcrumb');
        }
        this.divisionName = this.division;

        let brandNameMap = new Map([
            ['Honda', 'Honda'], ['Acura', 'Acura'], ['Powersports', 'Motorcycle/Powersports']
        ]);

        if (this.divisionName === 'Marine' || this.divisionName === 'Power Equipment') {
            this.showModelSection = false;
        }
        else {
            getProductChooserControl({ division: brandNameMap.get(this.divisionName) })
                .then(result => {
                    if (result) {
                        let chooserControl = result;
                        chooserControl.sort(function (a, b) { return (a.Tier_Number__c - b.Tier_Number__c) });

                        chooserControl.forEach(element => {
                            if (element.Product_Subdivision__c === brandNameMap.get(this.divisionName)) {
                                this.dropdownArray.push({ 'controlData': element });
                            }
                        });
                        this.maxTier = this.dropdownArray[this.dropdownArray.length - 1].controlData.Tier_Number__c;
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
                                    //console.log(JSON.stringify(this.dropdownData));
                                    //this.getYears();
                                }
                                else {
                                    this.showModelSection = false;
                                    this.showChooserError = true;
                                }
                            })
                            .catch(error => {
                                this.showModelSection = false;
                                this.showChooserError = true;
                                //console.log(JSON.stringify(error));
                            });
                    }
                    else {
                        this.showModelSection = false;
                        this.showChooserError = true;
                    }
                })
                .catch(error => {
                    this.showModelSection = false;
                    this.showChooserError = true;
                    //console.log(JSON.stringify(error));
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

        let path = window.location.href;
        let endpoint = path.substring(path.lastIndexOf('/') + 1);
        //console.log('endpoint at ownFindProducts ----> ', endpoint);

        this.paddingClass = 'slds-p-around_small';
        if (endpoint == 'hondalink-product-compatibility' || endpoint == 'acuralink-product-compatibility') {
            //console.log('------------In Honda at ownFindProducts -------------');
            this.isCompatibilityPage = true;
            this.paddingClass = 'slds-p-around_none';
        } else if (endpoint == 'find-acura' || endpoint == 'find-honda') { // Added For Resolving DOE-5065
            this.isFindPage = true;
        }

    }

    handleOptionSelect(event) {
        //console.log('OPTION SELECT');
        let tier = event.detail.tier;
        let value = event.detail.value;
        this.selectedValues.set(tier, value);
        this.highestFilledTier = tier;

        // clear all values for tiers above the most recently selected one
        for (let i = tier + 1; i <= this.maxTier; ++i) {
            //console.log(i);
            this.selectedValues.set(i, '');
        }

        if (this.highestFilledTier === this.maxTier) {
            // Test code; check if product with found details exists in initial data
            //console.log('***All values selected, running check: ***');
            let elementExists = false;
            let matchingElements = [];
            this.dropdownData.forEach(element => {
                let allTierValuesFound = true;
                this.selectedValues.forEach(function (value, key) {
                    if (!(element['Tier' + key + '__c'] === value)) {
                        allTierValuesFound = false;
                    }
                });
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
    }

    handleFoundProduct(event) {
        /* let tierValues = [];
        this.dropdownArray.forEach(element => {
            tierValues.push({tierNumber : element.Tier_Number__c, tierName : element})
        }) */
        const product = event.detail;
        //console.log('Product:');
        //console.log(JSON.stringify(product));
        let origin = 'ProductChooser';
        localStorage.setItem('origin', origin);
        setOrigin('ProductChooser');

        if (!this.isGuest) {
            this.resetGarage();
        }

        viewProduct(product);
    }

    handleVINChange(event) {
        // Handles onchange event for VIN input field

        // VIN Validation:
        // character length validation: Once 17 characters entered, display green check
        // < 17 characters & find pressed: display error message + cross
        // 17 characters, but is not valid VIN: server-side validation against database
        this.isVinDatabaseError = false;
        this.vin = event.target.value;
        this.vinInputVal = this.vin; // Note: the input field will display 'undefined' instead of placeholder text if its value is set to 'undefined'
        this.year = undefined;
        this.model = undefined;
        this.trim = undefined;
        this.modelId = undefined;
        if (this.vin && this.vin.length >= this.prodIdMinLength && this.vin.length <= this.prodIdMaxLength) {
            this.correctVINLength = true;
            this.incorrectVINLength = false;
            this.displayVINError = false;
            this.handleFindAndSection(this.year, this.model, this.trim, this.vin, VIN);
        } else {
            this.correctVINLength = false;
            this.handleFindAndSection(this.year, this.model, this.trim, undefined, VIN);
        }
    }

    handleVINHelp() {
        // Runs when VIN help button is pressed
        /*         console.log('NAVIGATE');
                let origin = 'ProductChooser';
                setOrigin('ProductChooser'); */
        localStorage.setItem('VINHelpBreadcrumb', 'FindProduct' + this.divisionName);
        //console.log(this.divisionName);
        sessionStorage.removeItem('backlink');
        if (this.divisionName == 'Honda' || this.divisionName == 'Acura' || this.divisionName == 'Powersports' || this.divisionName == 'Motorcycle/Powersports') {
            this.navigate('/vin-help/?division=' + this.divisionName, {});
        }
        else if (this.divisionName == 'Power Equipment') {
            sessionStorage.setItem('vinHelpBreadcrumb', 'findProduct');
            let backLink = {
                label: 'Power Equipment: Get Started',
                url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
            };
            sessionStorage.setItem('backlink', JSON.stringify(backLink));
            //this.navigate('/power-equipment-serial-number-locator', {});
            window.open('https://powerequipment.honda.com/support/serial-number-locator', '_blank');
        }
        else if (this.divisionName == 'Marine') {
            sessionStorage.setItem('vinHelpBreadcrumb', 'findProduct');
            this.navigate('/marine-serial-number-help', {});
        }
        //articleId: 'ka00200000018WqAAI', brand: 'Honda', year: this.year, modelName: this.model, trim: this.trim
    }

    clearVINIcons() {
        this.correctVINLength = false;
        this.incorrectVINLength = false;
        this.displayVINError = false;
    }

    handleSectionClick(event) {
        // Controls Year/Model/Trim and VIN sections in the mobile version of the page
        const section = event.currentTarget.dataset.section;
        this.year = undefined;
        this.model = undefined;
        this.vin = undefined;
        this.trim = undefined;
        this.modelId = undefined;
        this.modelSelectionDisabled = true;
        this.trimSelectionDisabled = true;
        this.clearVINIcons();

        if (section === MODEL) {
            this.showModelSection = true;
            this.showVinSection = false;
        } else if (section === VIN) {
            this.showModelSection = false;
            this.showVinSection = true;
        }

        this.handleFindAndSection(this.year, this.model, this.trim, this.vin, VIN);
    }

    handleFindAndSection(year, model, trim, vin, section) {
        // 
        // Updates 'Find' button classes according to whether or not all required fields have been filled out
        if (year && model) {
            this.modelSelectionDisabled = false;
            this.trimSelectionDisabled = false;
        }
        else if (year) {
            this.modelSelectionDisabled = false;
            this.trimSelectionDisabled = true;
        }
        else {
            this.modelSelectionDisabled = true;
            this.trimSelectionDisabled = true;
        }

        if (year && model && trim) {
            this.modelFindButtonClass = FIND_BRAND_BUTTON_ACTIVE;
        }
        else {
            this.modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
        }
        if (vin) {
            this.vinFindButtonClass = FIND_BRAND_BUTTON_ACTIVE;
        }
        else {
            this.vinFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
        }
        if (this.showModelSection) {
            this.modelSectionButtonClass = FIND_BRAND_SECTION_BUTTON_ACTIVE;
        }
        else {
            this.modelSectionButtonClass = FIND_BRAND_SECTION_BUTTON_DISABLED;
        }
        if (this.showVinSection) {
            this.vinSectionButtonClass = FIND_BRAND_SECTION_BUTTON_ACTIVE;
        }
        else {
            this.vinSectionButtonClass = FIND_BRAND_SECTION_BUTTON_DISABLED;
        }
    }

    resetGarage() {
        localStorage.removeItem('garage');
    }

    handleFindByVIN(event) {
        //console.log('Clicked');
        //console.log('event: ', event);

        if (this.vin.length < this.prodIdMinLength || this.vin.length > this.prodIdMaxLength) {
            //console.log('IF:');
            this.correctVINLength = false;
            this.incorrectVINLength = true;
            this.displayVINError = true;
        }
        else {
            //console.log('Else:');
            // this.vin = 'JHMBA4132JC011294';
            this.vin = this.vin.trim();
            getProductByVIN({ divisionId: this.divisionId === 'PE' ? 'P' : this.divisionId, vin: this.vin, divisionName: this.division })
                .then(result => {
                    //console.log('Apex callback');
                    //console.log('result: ', result);
                    // redirect using URL obtained
                    let prod = JSON.parse(result);
                    //console.log(prod.modelDetailList);

                    if (!prod.isError && prod.modelDetail) {
                        this.correctVINLength = true;
                        this.incorrectVINLength = false;
                        this.displayVINError = false;
                        //console.log('result ModelDetail: ', result['modelDetail']);
                        //console.log(prod.modelDetail);
                        //console.log(JSON.stringify(prod.modelDetail));

                        /* const prodct = {'divisionId': this.divisionId, 'division': this.divisionName,
                                        'year': prod.modelDetail.year ? prod.modelDetail.year : '',
                                        'model': prod.modelDetail.modelGroupName ? prod.modelDetail.modelGroupName : 
                                                (prod.modelDetail.modelName ? prod.modelDetail.modelName : '-'),
                                        'trim': prod.modelDetail.trim ? prod.modelDetail.trim : '',
                                        'modelId' : prod.modelDetail.modelId ? prod.modelDetail.modelId : '',
                                        'make' : prod.modelDetail.make ? prod.modelDetail.make : '-',
                                        'vin' : this.vin,
                                        'color' : prod.modelDetail.color ? prod.modelDetail.color : '-',
                                        'exteriorColor' : prod.modelDetail.color.name ? prod.modelDetail.color.name : '-',
                                        'image' : this.selectImageFromVINAPI(prod.modelDetail.assets)
                                        }; */
                        const prodct = this.processVinResponse(prod.modelDetail);
                        //console.log('prod1  :-  ', prodct);

                        if (!this.isGuest) {
                            this.resetGarage();
                        }
                        let origin = 'ProductChooser';
                        localStorage.setItem('origin', origin);
                        setOrigin('ProductChooser');
                        let eventMetadata = {
                            action_type: 'button',
                            action_category: 'body',
                            action_label: 'find'
                        };
                        let findProductDetails = {}
                        findProductDetails.brandName = this.division;
                        if (this.vin) { findProductDetails.vin = this.vin };
                        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata, findProductDetails: findProductDetails };
                        if (document.location.pathname.includes('find-') || document.location.pathname.includes('garage-') ||
                            document.location.pathname.includes('-service-maintenance') || document.location.pathname.includes('-connected-features') ||
                            document.location.pathname.includes('-marketplace') || document.location.pathname.includes('-financial-services') ||
                            document.location.pathname.includes('-resources-downloads')) {
                            this.publishToChannel(message);
                        }

                        if (!ISGUEST) {
                            getUserGarageForVIN({
                                'vin': prodct.vin
                            }).then(result => {
                                    prodct['ownershipId'] = result;
                                })
                                .catch(error => {
                                    //console.log(JSON.stringify(error));
                                })
                        }
                        
                        getRecallsByProductIdentifier({ productIdentifier: prodct.vin, divisionId: prodct.divisionId }).then((res) => {
                            //console.log('RECALLS: res', res);
                            if (res.response.recalls_response.response.recall.campaignType.campaign) {
                                let result = JSON.parse(JSON.stringify(res.response.recalls_response.response.recall.campaignType.campaign));
                                //console.log('RECALLS: res', result);
                                prodct['recalls'] = result;
                                viewProduct(prodct);
                            } else {
                                viewProduct(prodct);
                            }
                        }).catch(err => {
                            //console.error('RECALLS: err', err);
                            viewProduct(prodct);
                        });

                        // viewProduct(prodct);
                    }
                    else if (!prod.isError && prod.modelDetailList.length > 1) {

                        this.correctVINLength = true;
                        this.incorrectVINLength = false;
                        this.displayVINError = false;

                        let prodArr = [];
                        prod.modelDetailList.forEach(modelDetail => {
                            if (!modelDetail.isError) {
                                prodArr.push(this.processVinResponse(modelDetail));
                            }
                        })
                        localStorage.setItem('findProductPrelim', JSON.stringify(prodArr));
                        this.navigate('/find-product-intermediate', {});
                    }
                    else {
                        //console.log('In error block: ');
                        //console.log(prod.message);
                        if (prod.message === 'Your VIN is currently not supported by MyGarage.') {
                            this.isVinDatabaseError = true;
                        }
                        //console.log(this.isVinDatabaseError);
                        this.correctVINLength = false;
                        this.incorrectVINLength = true;
                        this.displayVINError = true;
                    }
                })
                .catch(error => {
                    //console.log('getProductByVIN: error');
                    //console.log('error: ', error);
                });
        }
    }

    processVinResponse(modelDetail) {
        let modelName;
        let trimName = ''; //Added by Yunus Khan on 01/31/23 to set trim as BLANK for PE and Marine
        if (this.divisionId == 'A' || this.divisionId == 'B' || this.divisionId == 'M') {
            modelName = modelDetail.modelGroupName ? modelDetail.modelGroupName :
                (modelDetail.modelName ? modelDetail.modelName : '-');
            trimName = modelDetail.trim ? modelDetail.trim : ''; //Added by Yunus Khan on 01/31/23 to set trim for Autos and PS
        }
        else if (this.divisionId == 'PE' || this.divisionId === 'P') {
            modelName = modelDetail.trim; //Updated by Yunus Khan on 01/31/23 to set trim on Model Name for PE and Marine
        }
        return {
            'divisionId': this.divisionId === 'PE' ? 'P' : this.divisionId,
            'division': this.divisionName === 'Power Equipment' ? 'Powerequipment' : this.divisionName,
            'year': modelDetail.year ? modelDetail.year : '',
            'model': modelName ? modelName : '-',
            'trim': trimName, //Updated by Yunus Khan on 01/31/23
            'modelId': modelDetail.modelId ? modelDetail.modelId : '',
            'make': modelDetail.make ? modelDetail.make : '-',
            'vin': this.vin,
            'color': modelDetail.color ? modelDetail.color : '-',
            'exteriorColor': modelDetail.color.name ? modelDetail.color.name : '-',
            'image': this.selectImageFromVINAPI(modelDetail.assets),
            'categoryCd': modelDetail.categoryCd
        };
    }

    selectImageFromVINAPI(vinImageSet) {
        // Pass 'assets' from VIN API result to select the correct image
        // Find an 'IMGMIDSIZE' image if possible; if not, use the first available image
        let selectedImage = '';

        if (vinImageSet) {
            vinImageSet.find(element => {
                if (element.assetType === PREFERRED_VIN_IMAGE_TYPE) {
                    selectedImage = element.imagePath;
                }
            });
            if (!selectedImage) {
                vinImageSet.find(element => {
                    if (element.imagePath) {
                        selectedImage = element.imagePath;
                    }
                })
            }
        }

        //console.log('%%%%%%%%%% IMAGE %%%%%%%%%%% ' + selectedImage);

        return selectedImage;
    }
}
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { viewProduct, getOrigin, setOrigin, addProduct, getGarageURL, getContext, setProductContextUser, getGarage, getProductContext } from 'c/ownDataUtils';
import getProductChooserControl from '@salesforce/apex/FindProductController.getProductChooserControl';
import getProductChooserData from '@salesforce/apex/FindProductController.getProductChooserData';
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';
import commonResources from "@salesforce/resourceUrl/Owners";
import { ISGUEST } from 'c/ownDataUtils';
import { CurrentPageReference } from 'lightning/navigation';

const LEFT_SECTION_TITLE_TEXT = {
    'Honda': "Owner's Manuals for Honda",
    'Acura': "Owner's Manuals for Acura",
    'Powersports': "Owner's Manuals for Honda Powersports",
    'Power Equipment': "Owner's Manuals for Power Equipment",
    'Marine': "Owner's Manuals for Honda Marine products"
};

const PC_TEXT = {
    'Honda': 'Enter your year, model, and trim for information about your Honda',
    'Acura': 'Enter your year, model, and trim for information about your Acura',
    'Powersports': 'Access manuals for your Powersports based on its year and category',
    'Power Equipment': 'Enter your serial number to access manuals for your product',
    'Marine': 'Enter your serial number to access manuals for your product'
};
const VIN_TEXT = {
    'Honda': 'Enter your VIN to access manuals for your vehicle',
    'Acura': 'Enter your VIN to access manuals for your vehicle',
    'Powersports': 'Enter your VIN to access manuals for your vehicle',
    'Power Equipment': 'Enter your serial number to access manuals for your product',
    'Marine': 'Enter your serial number to access manuals for your product'
};

const MODEL = 'model';
const VIN = 'vin';
const FIND_BRAND_BUTTON_ACTIVE = 'find-brand-button-active';
const FIND_BRAND_BUTTON_DISABLED = 'find-brand-button-disabled';
const FIND_BRAND_SECTION_BUTTON_ACTIVE = 'find-brand-section-button-active';
const FIND_BRAND_SECTION_BUTTON_DISABLED = 'find-brand-section-button-disabled';
const PREFERRED_VIN_IMAGE_TYPE = "IMGMIDSIZE";

import getRecallsByProductIdentifier from '@salesforce/apex/OwnAPIController.getRecallsByProductIdentifier';


export default class OwnManualsSearch extends OwnBaseElement {

    @track division = "Honda";
    @track divisionName;// = 'Acura';
    @track divisionId;// = 'B';

    @track isGuest = ISGUEST;

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
    @track context;

    @track isFindPage = false;
    @track isPhoneCompatibilityPage = false;
    paddingClass = '';



    get leftSectionTitleText() {
        return LEFT_SECTION_TITLE_TEXT[this.divisionName];
    }

    get pcText() {
        return PC_TEXT[this.divisionName];
    }

    get vinText() {
        return VIN_TEXT[this.divisionName];
    }
    get productIdentifierUppercase() {
        switch (this.divisionName) {
            case "Honda":
                return "VIN";
            case "Acura":
                return "VIN";
            case "Powersports":
                return "VIN";
            case "Motorcycle/Powersports":
                return "VIN";
            case "Power Equipment":
                return "Serial Number";
            case "Marine":
                return "Serial Number";
        }
    }

    get productIdentifierUppercaseLabel() {
        switch (this.divisionName) {
            case "Honda":
                return "VIN NUMBER";
            case "Acura":
                return "VIN NUMBER";
            case "Powersports":
                return "VIN NUMBER";
            case "Motorcycle/Powersports":
                return "VIN NUMBER";
            case "Power Equipment":
                return "Serial Number";
            case "Marine":
                return "Serial Number";
        }
    }

    get productIdentifierLowercase() {
        return (this.divisionName === "Power Equipment" || this.divisionName === "Marine") ? this.productIdentifierUppercase.toLowerCase() : this.productIdentifierUppercase;
    }

    get productIdentifierEntryPlaceholder() {
        return "Enter " + this.productIdentifierUppercase;
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
        return "Incorrect " + this.productIdentifierLowercase + " entered.";
    }

    vinHelpIcon = commonResources + '/Icons/garage_questionmark.png';

    // @wire(CurrentPageReference) pageref;
    currentPageReference = null;
    urlStateParameters = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            if (this.urlStateParameters.brand) {
                //console.log('BRAND', this.urlStateParameters.brand)
                if (this.urlStateParameters.brand == 'acura') {
                    this.division = 'Acura';
                    this.divisionId = "B";
                }
                if (this.urlStateParameters.brand == 'honda') {
                    this.division = 'Honda';
                    this.divisionId = "A";
                }
                if (this.urlStateParameters.brand == 'powersports') {
                    this.division = 'Powersports';
                    // this.divisionId = "M";
                }
                if (this.urlStateParameters.brand == 'powerequipment') {
                    this.division = 'Power Equipment';
                    this.divisionId = "PE";
                }
                if (this.urlStateParameters.brand == 'marine') {
                    this.division = 'Marine';
                    // this.divisionId = "PE";
                }
            }
        }
    }

    async connectedCallback() {
        // this.initialize();
        /*let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        console.log('RECALLS: From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext('');
        }
        console.log('CONTEXT-ownRecallSearch: ', JSON.parse(JSON.stringify(this.context)));
        if(this.context && this.context.product){
            this.division = this.context.product.division;
        }*/
        //console.log('BREADCRUMB TEST ' + sessionStorage.getItem('vinHelpBreadcrumb'));
        if (sessionStorage.getItem('vinHelpBreadcrumb')) {
            sessionStorage.removeItem('vinHelpBreadcrumb');
        }
        this.divisionName = this.division;
        //console.log('this.divisionName: ', this.divisionName);

        let brandNameMap = new Map([
            ['Honda', 'Honda'], ['Acura', 'Acura'], ['Powersports', 'Motorcycle/Powersports'], ['Motorcycle/Powersports', 'Motorcycle/Powersports']
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
        else if (this.divisionName === "Powersports" || this.divisionName === 'Motorcycle/Powersports')
            this.divisionId = "M";
        else if (this.divisionName === "Power Equipment")
            this.divisionId = "PE";
        else if (this.divisionName === "Marine")
            this.divisionId = "PE";
        else
            this.divisionId = "A";

        this.paddingClass = 'slds-p-around_small';

    }
    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext('');
        }
        if (this.context && this.context.product) {
            this.division = this.context.product.division;
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
        //localStorage.setItem('VINHelpBreadcrumb', 'FindProduct' + this.divisionName);
        let backLink = {
            NAME: document.title,
            LABEL: document.title,
            URL: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
        };
        sessionStorage.setItem('backlink', JSON.stringify(backLink));
        localStorage.removeItem('VINHelpBreadcrumb');
        //console.log(this.divisionName);
        if (this.divisionName == 'Honda' || this.divisionName == 'Acura' || this.divisionName == 'Powersports' || this.divisionName == 'Motorcycle/Powersports') {
            this.navigate('/vin-help/?division=' + this.divisionName, {});
        }
        else if (this.divisionName == 'Power Equipment') {
            sessionStorage.setItem('vinHelpBreadcrumb', 'findProduct');
            let backLink = {
                label: document.title,
                url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
            };
            sessionStorage.setItem('backlink', JSON.stringify(backLink));
            // this.navigate('/power-equipment-serial-number-locator', {});
            window.open('https://powerequipment.honda.com/support/serial-number-locator', '_blank');
        }
        else if (this.divisionName == 'Marine') {
            sessionStorage.setItem('frompage', 'Recall Search');
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
        //console.log('event: ', event);
        if (window.location.href.includes('manuals-search')) {
            let divisionBrandName = this.division == 'Powerequipment' ? 'Power Equipment' : this.division;
            let backLink = {
                label: 'Manuals Search: ' + divisionBrandName,
                url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
            };
            sessionStorage.setItem('backlink', JSON.stringify(backLink));
        }
        if (this.vin.length < this.prodIdMinLength || this.vin.length > this.prodIdMaxLength) {
            //console.log('IF:');
            this.correctVINLength = false;
            this.incorrectVINLength = true;
            this.displayVINError = true;
        }
        else {
            //console.log('Else:');
            getProductByVIN({ divisionId: this.divisionId === 'PE' ? 'P' : this.divisionId, vin: this.vin, divisionName: this.division })
                .then(result => {
                    //console.log('Apex callback');
                    //console.log('result: ', result);
                    // redirect using URL obtained
                    let prod = JSON.parse(result);
                    // console.log(prod.modelDetailList);
                    if (!prod.isError && prod.modelDetail) {
                        this.correctVINLength = true;
                        this.incorrectVINLength = false;
                        this.displayVINError = false;
                        //console.log('result ModelDetail: ', result['modelDetail']);
                        //console.log(prod.modelDetail);
                        //console.log(JSON.stringify(prod.modelDetail));
                        const prodct = this.processVinResponse(prod.modelDetail);
                        //console.log('prod1  :-  ', prodct);

                        if (!this.isGuest) {
                            this.resetGarage();
                        }
                        let origin = 'ProductChooser';
                        localStorage.setItem('origin', origin);
                        setOrigin('ProductChooser');

                        getRecallsByProductIdentifier({ productIdentifier: prodct.vin, divisionId: prodct.divisionId }).then((res) => {
                            //console.log('RECALLS: res', res);
                            if (res.response.recalls_response.response.recall.campaignType.campaign) {
                                let result = JSON.parse(JSON.stringify(res.response.recalls_response.response.recall.campaignType.campaign));
                                prodct['recalls'] = result;
                                viewProduct(prodct);
                            } else {
                                viewProduct(prodct);
                            }
                        }).catch(err => {
                            //console.error('RECALLS: err', err);
                            viewProduct(prodct);
                        });
                    } else if (!prod.isError && prod.modelDetailList.length > 1) {

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
                        this.navigate('/find-product-intermediate?page=recalls', {});
                    } else {
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
        if (this.divisionId == 'A' || this.divisionId == 'B' || this.divisionId == 'M') {
            modelName = modelDetail.modelGroupName ? modelDetail.modelGroupName :
                (modelDetail.modelName ? modelDetail.modelName : '-');
        }
        else if (this.divisionId == 'PE' || this.divisionId === 'P') {
            modelName = modelDetail.modelName;
        }
        //console.log('%%%%% modelName' + modelName);
        return {
            'divisionId': this.divisionId === 'PE' ? 'P' : this.divisionId,
            'division': this.divisionName === 'Power Equipment' ? 'Powerequipment' : this.divisionName,
            'year': modelDetail.year ? modelDetail.year : '',
            'model': modelName ? modelName : '-',
            'trim': modelDetail.trim ? modelDetail.trim : '',
            'modelId': modelDetail.modelId ? modelDetail.modelId : '',
            'make': modelDetail.make ? modelDetail.make : '-',
            'vin': this.vin,
            'color': modelDetail.color ? modelDetail.color : '-',
            'exteriorColor': modelDetail.color.name ? modelDetail.color.name : '-',
            'image': this.selectImageFromVINAPI(modelDetail.assets)
        };
    }

    selectImageFromVINAPI(vinImageSet) {
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

        return selectedImage;
    }
    capitalizeFirstLetter(str) {
        return str.charAt(0).toUpperCase() + str.toLowerCase().slice(1);
    }
}
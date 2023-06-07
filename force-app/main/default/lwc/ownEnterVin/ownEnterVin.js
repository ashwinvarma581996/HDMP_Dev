//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Owners Enter VIN page
//
// Details:  
//
// History:
// Oct 28, 2021 Ankur A (Wipro) Original Author
//===========================================================================

import { api, track, wire, LightningElement } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";
import { getContext, getGarageURL, getOrigin, removeProduct, viewProduct } from 'c/ownDataUtils';
//import saveChangesVINBasic from '@salesforce/apex/ownProductSettingsController.saveChangesVINBasic';
import validateVIN from '@salesforce/apex/ownProductSettingsController.validateVIN';
import checkUserGarageForVIN from '@salesforce/apex/OwnGarageController.checkUserGarageForVIN';
import saveChangesVIN from '@salesforce/apex/ownProductSettingsController.saveChangesVIN';
import { ISGUEST } from 'c/ownDataUtils';
import getRecallsByProductIdentifier from '@salesforce/apex/OwnAPIController.getRecallsByProductIdentifier';

import { CurrentPageReference } from 'lightning/navigation';


const SAVE_BUTTON_DISABLED = "product-button-1-disabled";
const SAVE_BUTTON_ACTIVE = "product-button-1";
const VIN_ERROR_TEXT = "Incorrect VIN entered.";
const USER_HAS_PRODUCT_ERROR = 'Attention: a product with this VIN already exists in your garage.';
const PREFERRED_VIN_IMAGE_TYPE = "IMGMIDSIZE";
const VIN_DATABASE_ERROR = 'Your VIN is currently not supported by MyGarage.';



export default class OwnEnterVin extends OwnBaseElement {

    hasVIN = false; // Whether or not a VIN was passed in
    userEnteredVIN = false; // Whether or not the user has entered their own VIN
    context;
    vin;
    vinInputVal = "";
    year;
    model;
    @track vehicleImage;
    defaultVehicleImage; //Large_Image_Url__c from Product_Model_Color__c. Need an Apex method to retrieve this.
    logoImage;
    hondaLogoImage = '/resource/Owners/images/garage_hondadefault.svg';

    //Null Image Bug Fix 
    hondaLogoSrc = '/resource/MyGarage/img/thumbnail_honda.png';
    acuraLogoSrc = '/resource/MyGarage/img/thumbnail_acura.png';
    powersportsLogoSrc = '/resource/MyGarage/img/thumbnail_powersports.png';
    powerequipmentLogoSrc = '/resource/MyGarage/img/thumbnail_powerequipment.png';
    marineLogoSrc = '/resource/MyGarage/img/thumbnail_marine.png';


    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));
    divisionId;
    @track divisionName;
    isGuest = ISGUEST;
    saveButtonClass = SAVE_BUTTON_DISABLED;
    saveButtonDisabled = true;
    @track displayVINError = false;
    correctVINLength;
    incorrectVINLength;
    //vinErrorText = VIN_ERROR_TEXT;
    fromRecallDetail;
    fromRecallCard;
    @track userHasVin = false;
    @track incorrectVIN = false;
    @track vinDatabaseError = false;


    @wire(CurrentPageReference) pageref;

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

    @api
    get vinErrorText() {
        if (this.userHasVin) {
            return USER_HAS_PRODUCT_ERROR;
        }
        else if (this.vinDatabaseError) {
            return VIN_DATABASE_ERROR;
        }
        else if (this.incorrectVIN) {
            return VIN_ERROR_TEXT;
        }
    }

    clearVinErrorFlags() {
        this.userHasVin = false;
        this.incorrectVin = false;
        this.vinDatabaseError = false;
    }


    initialize = async () => {
        this.context = await getContext('');
        //console.log('Enter VIN Context: ' + JSON.stringify(this.context));
        this.fromProductChooser = getOrigin() === 'ProductChooser' && !this.isGuest ? true : false;
        //console.log('Enter VIN fromProductChooser: ' + this.fromProductChooser);
        let garageProducts = JSON.parse(localStorage.getItem('garage'));
        this.year = this.fromProductChooser ? garageProducts.products[0].year : this.context.product.year;
        this.model = this.fromProductChooser ? garageProducts.products[0].model : this.context.product.model;
        this.divisionId = this.fromProductChooser ? garageProducts.products[0].divisionId : this.context.product.divisionId;
        this.divisionName = this.fromProductChooser ? garageProducts.products[0].division : this.context.product.division;
        this.defaultVehicleImage = this.fromProductChooser ? garageProducts.products[0].image : this.context.product.productDefaultImage;
        this.logoImage = this.fromProductChooser ? garageProducts.products[0].image : this.context.product.image;

        if (sessionStorage.getItem('fromRecallDetail')) {
            //console.log('Setting fromRecallDetail');
            this.fromRecallDetail = true;
            this.fromRecallCard = false;
        }
        else if (sessionStorage.getItem('fromRecallCard')) {
           // console.log('Setting fromRecallCard');
            this.fromRecallDetail = true;
            this.fromRecallCard = true;
        }
        this.setVehicleImage(this.defaultVehicleImage);
        if (this.vin && this.vin != '') {
            this.hasVIN = true;
        } else {
            this.hasVIN = false;
        }
    };

    setCorrectVINIcon() {
        this.correctVINLength = true;
        this.incorrectVINLength = false;
    }

    setIncorrectVINIcon() {
        this.correctVINLength = false;
        this.incorrectVINLength = true;
    }


    connectedCallback() {
        // Retrieve information from database (HondaProducts) based on the ProductId provided
        this.initialize();
    }

    setSaveButtonClass() {
        // Currently, save button must be set to 'active' after the user changes any field value
        this.saveButtonClass = SAVE_BUTTON_ACTIVE;
    }

    getResourceVehicleImage() {
        this.vehicleImage = this.divisionName === "Honda" ? this.hondaLogoSrc : this.hondaLogoSrc;
        this.vehicleImage = this.divisionName === "Acura" ? this.acuraLogoSrc : this.hondaLogoSrc;
        this.vehicleImage = this.divisionName === "Powersports" ? this.powersportsLogoSrc : this.hondaLogoSrc;
        this.vehicleImage = this.divisionName === "Marine" ? this.marineLogoSrc : this.hondaLogoSrc;
        this.vehicleImage = this.divisionName === "Powerequipment" ? this.powerequipmentLogoSrc : this.hondaLogoSrc;
    }

    setVehicleImage(defaultVehicleImage) {
        if (defaultVehicleImage) {
            //console.log("Setting default image;", defaultVehicleImage);
            this.vehicleImage = /* this.baseURL + DOE-4880 */ String(defaultVehicleImage);

            if (this.vehicleImage.endsWith('/assets/null')) {
                //Null Image Bug Fix
                //console.log(this.divisionName);
                this.getResourceVehicleImage();
            }
        } else {
            //console.log("Setting generic image;");
            if (this.logoImage.startsWith('http')) {
                //console.log('Is Link');
                this.vehicleImage = /*this.baseURL +*/ this.logoImage;

                if (this.vehicleImage.endsWith('/assets/null')) {
                    //Null Image Bug Fix
                    //console.log(this.divisionName);
                    this.getResourceVehicleImage();
                }

                //console.log('Vehicle Image ', this.vehicleImage);
            }
            else {
                //console.log('Is Resource');
                this.vehicleImage = this.baseURL + this.logoImage;
            }
        }
        //console.log("image: " + this.vehicleImage);
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

        return selectedImage;
    }

    handleVINHelp() {
        //console.log(this.pageref);
        //localStorage.setItem('VINHelpBreadcrumb', 'FindProduct' + this.divisionName);
        // Alexander Dzhitenov (Wipro) DOE-6045 - Setting breadcrumb to Enter-VIN page instead of find product page
        localStorage.setItem('VINHelpBreadcrumb', 'EnterVIN');
        //console.log(this.divisionName);
        if (this.divisionName == 'Honda' || this.divisionName == 'Acura' || this.divisionName == 'Powersports' || this.divisionName == 'Motorcycle/Powersports') {
            //sessionStorage.setItem('enterVinProductContext', {year: , modelName: , trim: , image: })
            this.navigate('/vin-help/?division=' + this.divisionName, {});
        }
        else if (this.divisionName == 'Power Equipment') {
            sessionStorage.setItem('vinHelpBreadcrumb', 'findProduct');
            this.navigate('/sample-emission-label-powerequipment', {});
        }
        else if (this.divisionName == 'Marine') {
            sessionStorage.setItem('vinHelpBreadcrumb', 'findProduct');
            this.navigate('/marine-emissions-location-label', {});
        }
    }

    handleVINChange(event) {
        this.vin = event.target.value;
        this.vinInputVal = event.target.value;
        //this.saveButtonClass = SAVE_BUTTON_ACTIVE;
        //this.saveButtonDisabled = false;
        this.clearVinErrorFlags();
        if (this.vin && this.vin.length === 17) {
            this.saveButtonClass = SAVE_BUTTON_ACTIVE;
            this.saveButtonDisabled = false;
            this.incorrectVINLength = false;
            this.correctVINLength = true;
            this.displayVINError = false;
            this.userEnteredVIN = true;
        } else {
            this.saveButtonClass = SAVE_BUTTON_DISABLED;
            this.saveButtonDisabled = true;
            this.correctVINLength = false;
            this.userEnteredVIN = false;
        }
    }

    onVinError() {
        this.correctVINLength = false;
        this.incorrectVINLength = true;
        this.incorrectVIN = true;
        this.displayVINError = true;
    }

    handleVinForUser(serverResult) {
        let garage = JSON.parse(localStorage.getItem('garage'));
        //console.log(garage);
        let productFromAPI = {
            'divisionId': this.divisionId,
            'division': this.divisionName,
            'year': serverResult.modelDetail.year ? serverResult.modelDetail.year : '-',
            'model': serverResult.modelDetail.modelGroupName ? serverResult.modelDetail.modelGroupName : '-',
            'trim': serverResult.modelDetail.trim ? serverResult.modelDetail.trim : '-',
            'modelId': serverResult.modelDetail.modelId ? serverResult.modelDetail.modelId : '-',
            'make': serverResult.modelDetail.make ? serverResult.modelDetail.make : '-',
            'vin': this.vin,
            'color': serverResult.modelDetail.color ? serverResult.modelDetail.color : '-',
            'exteriorColor': serverResult.modelDetail.color.name ? serverResult.modelDetail.color.name : '-',
            'image': this.selectImageFromVINAPI(serverResult.modelDetail.assets)
        };
        /* garage.products[0].vin = serverResult.modelDetail.vinNumber;
        garage.products[0].year = serverResult.modelDetail.year;
        garage.products[0].model = serverResult.modelDetail.modelGroupName;
        garage.products[0].trim = serverResult.modelDetail.trim;
        garage.products[0].modelId = serverResult.modelDetail.modelId;
        garage.products[0].exteriorColor = serverResult.modelDetail.color.name;
        garage.products[0].color = serverResult.modelDetail.color;
        garage.products[0].image = this.selectImageFromVINAPI(serverResult.modelDetail.assets); */
        //garage.products[0] = productFromAPI;
        garage.products.shift();
        localStorage.setItem('garage', JSON.stringify(garage));
        //console.log(productFromAPI);
        //console.log('ENTER VIN DIVISION: ' + this.divisionName);
        //this.navigate(getGarageURL(this.divisionName), {});
        getRecallsByProductIdentifier({ productIdentifier: productFromAPI.vin, divisionId: productFromAPI.divisionId }).then((res) => {
            //console.log('RECALLS: res', res);
            if (res.response.recalls_response.response.recall.campaignType.campaign) {
                let result = JSON.parse(JSON.stringify(res.response.recalls_response.response.recall.campaignType.campaign));
                productFromAPI['recalls'] = result;
                //console.log('@@@ added recalls', productFromAPI)
                viewProduct(productFromAPI);
            } else {
                viewProduct(productFromAPI);
            }
        }).catch(err => {
            //console.error('RECALLS: err', err);
            viewProduct(productFromAPI);
        });
        // viewProduct(productFromAPI);
    }

    handleVinForGuest(serverResult) {
        let garage = JSON.parse(localStorage.getItem('garage'));
        garage.products.shift();
        localStorage.setItem('garage', JSON.stringify(garage));
        let productFromAPI = {
            'divisionId': this.divisionId,
            'division': this.divisionName,
            'year': serverResult.modelDetail.year ? serverResult.modelDetail.year : '-',
            'model': serverResult.modelDetail.modelGroupName ? serverResult.modelDetail.modelGroupName : '-',
            'trim': serverResult.modelDetail.trim ? serverResult.modelDetail.trim : '-',
            'modelId': serverResult.modelDetail.modelId ? serverResult.modelDetail.modelId : '-',
            'make': serverResult.modelDetail.make ? serverResult.modelDetail.make : '-',
            'vin': this.vin,
            'color': serverResult.modelDetail.color ? serverResult.modelDetail.color : '-',
            'exteriorColor': serverResult.modelDetail.color.name ? serverResult.modelDetail.color.name : '-',
            'image': this.selectImageFromVINAPI(serverResult.modelDetail.assets)
        };
        getRecallsByProductIdentifier({ productIdentifier: productFromAPI.vin, divisionId: productFromAPI.divisionId }).then((res) => {
            //console.log('RECALLS: res', res);
            if (res.response.recalls_response.response.recall.campaignType.campaign) {
                let result = JSON.parse(JSON.stringify(res.response.recalls_response.response.recall.campaignType.campaign));
                productFromAPI['recalls'] = result;
                //console.log('@@@ added recalls', productFromAPI)
                viewProduct(productFromAPI);
            } else {
                viewProduct(productFromAPI);
            }
        }).catch(err => {
            //console.error('RECALLS: err', err);
            viewProduct(productFromAPI);
        });
        //viewProduct(productFromAPI);
    }

    handleSave() {
        if (this.vin ? (this.vin.length < 17) : false) {
            this.incorrectVINLength = true;
        } else {
            //console.log('SAVE CHANGES');
            this.incorrectVINLength = false;
        }

        //console.log(this.userEnteredVIN);
        //console.log(this.fromProductChooser);
        //console.log(this.fromRecallDetail);

        if (this.userEnteredVIN && (this.fromProductChooser || this.isGuest)) {
            this.vin = this.vin.trim();
            validateVIN({
                vin: this.vin,
                divisionId: this.divisionId
            })
                .then(result => {
                    const serverResult = JSON.parse(result);
                    //console.log(result);
                    if (serverResult.isError === false) {
                        //console.log('Valid VIN');
                        this.incorrectVINLength = false;
                        this.correctVINLength = true;
                        this.displayVINError = false;
                        if (this.isGuest) {
                            //console.log('RUNNING logged-out block');
                            this.handleVinForGuest(serverResult);
                        } else if (this.fromProductChooser && !this.isGuest) {
                            //console.log('RUNNING logged-in, from ProductChooser block');
                            this.handleVinForUser(serverResult);
                        }
                    } else if (serverResult.isError === true) {
                        //Note: error validating VIN results in catch statement
                        //console.log('Invalid VIN: ' + serverResult.message);
                        //console.log('In error block');
                        if (serverResult.message === 'Your VIN is currently not supported by MyGarage.') {
                            this.vinDatabaseError = true;
                        }
                        //console.log(this.vinDatabaseError);
                        this.onVinError();
                        //this.showToast_error('Incorrect VIN entered.');
                    }
                })
                .catch(error => {
                    //console.log('error: ' + JSON.stringify(error));
                    this.onVinError();
                    let msg = error.body.pageErrors[0].statusCode === 'DUPLICATE_VALUE' ?
                        'VIN is already registered with another product' : 'Invalid VIN.';
                    //this.showToast_error(msg);
                });

        }
        else if (this.userEnteredVIN && (!this.fromProductChooser && (this.fromRecallDetail || this.fromRecallCard))) {
            this.vin = this.vin.trim();
            //console.log('Running recall detail block');
            //sessionStorage.removeItem('fromRecallDetail');
            sessionStorage.removeItem('fromRecallCard');
            this.handleSaveVIN();
        }
    }

    handleSaveVIN() {
        checkUserGarageForVIN({ 'vin': this.vin })
            .then(result => {
                this.userHasVin = result;
                //console.log('### userHasVin = ' + this.userHasVin);
                if (!this.userHasVin) {
                    // VIN is not present in user's garage—save the VIN to the user's Ownership record
                    saveChangesVIN({
                        productId: this.context.product.productId, ownershipId: this.context.product.ownershipId, divisionId: this.context.product.divisionId,
                        nickname: this.context.product.nickname, vin: this.vin,
                        modelId: this.context.product.modelId, validVINLength: !this.incorrectVINLength,
                        licensePlate: this.context.product.licenseNumber, licensePlateState: this.context.product.licenseState
                    })
                        .then(result => {
                            let vinResultObj = JSON.parse(result);
                            if (!vinResultObj.isError) {
                                //console.log('handleSaveVIN: success');
                                window.open('./recalls-detail', '_self');
                            }
                            else {
                                //console.log('In error block: ');
                                if (result.message === 'Your VIN is currently not supported by MyGarage.') {
                                    this.vinDatabaseError = true;
                                }
                                else {
                                    this.incorrectVIN = true;
                                }
                                this.displayVINError = true;
                            }
                        })
                        .catch(error => {
                            //console.log(JSON.stringify(error));
                        })
                }
                else {
                    // VIN is present in the user's garage-do not save, disable the add button, and display error text
                    this.displayVINError = true;
                }
            })
            .catch(error => {
                //console.log(JSON.stringify(error));
            });
    }

    handleCloseEdit() {
        /* console.log('ownEnterVin:: fromRecallDetail ' + this.fromRecallDetail);
        console.log('ownEnterVin:: fromRecallCard ' + this.fromRecallCard);
        if (this.fromRecallDetail && !this.fromRecallCard){
            console.log('Navigating to recall detail page');
            this.navigate('/recalls-detail', {});
        }
        else if (this.fromRecallDetail){
            let redirectUrl;
            switch (this.divisionName){
                case 'Honda':
                    redirectUrl = '/honda-service-maintenance';
                    break;
                case 'Acura':
                    redirectUrl = '/acura-service-maintenance';
                    break;
                case 'Powersports':
                case 'Motorcycle/Powersports':
                    redirectUrl = '/honda-powersports-service-maintenance';
                    break;
                case 'Power Equipment':
                case 'Powerequipment':
                    redirectUrl = '/honda-power-equipmnt-service-maintenance';
                    break;
                case 'Marine':
                    redirectUrl = '/honda-marine-service-maintenance';
                    break;
            }
            this.navigate(redirectUrl, {});
        }
        else{
            console.log('Navigating to other page');
            let redirectUrl = this.getRedirectUrl(this.context.product.division, this.context.productTab);
            console.log('***REDIRECT URL: ' + redirectUrl);
            this.navigate(redirectUrl, {});
        } */
        //history.back();
        this.handleCancel();
    }

    getRedirectUrl(division, tabName){
        //console.log('***DIVISION ' + division);
        //console.log('***TABNAME ' + tabName);
        division = division.toLowerCase();
        
        if (division === 'power equipment'){
            division = 'powerequipment';
        }
        if (division === 'motorcycle/powersports'){
            division = 'powersports';
        }
        switch (tabName){
            case 'Overview':
                return getGarageURL(division);
            case 'Service & Maintenance':
                return (division != 'acura' && division != 'honda' ? 'honda-' : '')
                        + (division === 'powerequipment' ? 'power-equipmnt' : division) + '-'
                        + 'service-maintenance';
            case 'Connected Features':
                return (division) + '-product-connected-features';
            case 'Marketplace':
                return (division != 'acura' && division != 'honda' ? 'honda-' : '') + (division === 'powerequipment' ? 'power-equipment' : division) + '-' + 'marketplace';
            case 'Financial Services':
                return (division === 'powerequipment' ? 'power-equipment' : (division === 'powersports' ? 'power-sports' : division)) + '-' + 'financial-services';
            case 'Resources & Downloads':
                return (division != 'acura' && division != 'honda' ? 'honda-' : '') + (division === 'powerequipment' ? 'power-equipmnt' : division) + '-' + 'resources-downloads';
        }
    }

    handleCancel() {
        //console.log('ownEnterVin:: fromRecallDetail ' + this.fromRecallDetail);
        //console.log('ownEnterVin:: fromRecallCard ' + this.fromRecallCard);
        let context = JSON.parse(localStorage.getItem('context'));
        //console.log('**** LOCAL STORAGE CONTEXT, OWNENTERVIN: ' + context.productTab);
        if (this.fromRecallDetail && !this.fromRecallCard){
            this.navigate('/recalls-detail', {});
        }
        else if (this.fromRecallDetail){
            let redirectUrl;
            switch (this.divisionName){
                case 'Honda':
                    redirectUrl = '/honda-service-maintenance';
                    break;
                case 'Acura':
                    redirectUrl = '/acura-service-maintenance';
                    break;
                case 'Powersports':
                case 'Motorcycle/Powersports':
                    redirectUrl = '/honda-powersports-service-maintenance';
                    break;
                case 'Power Equipment':
                case 'Powerequipment':
                    redirectUrl = '/honda-power-equipment-service-maintenance';
                    break;
                case 'Marine':
                    redirectUrl = '/honda-marine-service-maintenance';
                    break;
            }
            this.navigate(redirectUrl, {});
        }
        else{
            //console.log('Navigating to other page');
            let redirectUrl = this.getRedirectUrl(this.context.product.division, /* this.context.productTab */ 'Overview');
            //console.log('***REDIRECT URL: ' + redirectUrl);
            this.navigate(redirectUrl, {});
        }
        //history.back();
    }

    /* handleExitNoSave() {
        this.navigate(getGarageURL(this.context.product.division), {});
    } */

}
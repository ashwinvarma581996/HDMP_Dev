//============================================================================
// Title:    Honda Owners Experience - Product Settings
//
// Summary:  Owners Product Settings - logic for the Product Settings and Edit
//           Product page
//
// Details:  Retrieves database information based on the ProductId that was
//           provided, and handles database save functionality.
//
//
// History:
// Oct 8, 2021 Alexander D (Wipro) Original Author
//===========================================================================

import { LightningElement, api, wire, track } from 'lwc';
import {OwnBaseElement} from 'c/ownBaseElement';

import { getContext, getGarageURL, removeProduct, setOrigin, getOrigin, nonConnectedPlatformMap, productIdentifierLookUp } from 'c/ownDataUtils';


import getStates from '@salesforce/apex/ownProductSettingsController.getStates';
// Colors to be fixed later
//import getModelColorsByModelId from '@salesforce/apex/ownProductSettingsController.getModelColorsByModelId';
//import getModelColors from '@salesforce/apex/ownProductSettingsController.getModelColors';
//import getModelImageURL from '@salesforce/apex/ownProductSettingsController.getModelImageURL';
import getTrims from '@salesforce/apex/FindProductController.getTrims';

import getProductDetails from '@salesforce/apex/ownProductSettingsController.getProductDetails';


import saveChanges from '@salesforce/apex/ownProductSettingsController.saveChanges';
import saveChangesVIN from '@salesforce/apex/ownProductSettingsController.saveChangesVIN';
import save from '@salesforce/apex/ownProductSettingsController.save';
import saveImage from "@salesforce/apex/ownProductSettingsController.saveImage";

import checkUserGarageForVIN from '@salesforce/apex/OwnGarageController.checkUserGarageForVIN'; // DOE-4780 Brett Spokes
import fromServer_updateConnectedFlag from '@salesforce/apex/OwnContextController.update_UserConnectedFlag';

import {CurrentPageReference} from 'lightning/navigation';
import getManageSubscriptions from '@salesforce/apex/OwnAPIController.getManageSubscriptions';
import getValidateCustomerIdentity from '@salesforce/apex/OwnAPIController.getValidateCustomerIdentity'; 
import { updateRecord } from 'lightning/uiRecordApi';
import UserId from '@salesforce/user/Id';
import ID from '@salesforce/schema/User.Id';
import CUSTOMERID from '@salesforce/schema/User.CustomerID__c';
import VIN from '@salesforce/schema/User.VIN__c';
import BRAND from '@salesforce/schema/User.Brand__c';
import getSSPSSOAcuralink from '@salesforce/apex/OwnAPIController.getSSPSSOAcuralink';
import getSSPSSOHondalink from '@salesforce/apex/OwnAPIController.getSSPSSOHondalink';
const PRODUCT_SETTINGS_TITLE = "Product Settings";
const SAVE_BUTTON_DISABLED = "product-button-1-disabled";
const SAVE_BUTTON_ACTIVE = "product-button-1";

const VIN_ERROR_TEXT = "Incorrect VIN entered.";

const USER_HAS_PRODUCT_ERROR = 'Attention: a product with this VIN already exists in your garage.';
const VIN_DATABASE_ERROR = 'Your VIN is currently not supported by MyGarage.';
import getSSO from '@salesforce/apex/OwnAPIController.getSSO';
import getTrialEligibility from '@salesforce/apex/OwnAPIController.getTrialEligibility';

export default class OwnProductSettings extends OwnBaseElement {

    // VARIABLES //

    hasVIN = true;                 // Whether or not a VIN was passed in
    userEnteredVIN = false; // Whether or not the user has entered their own VIN

    @api context;
    @track productId;
    productModelId;
    @track ownershipId;
    redirectUrl;
    division;
    divisionId;
    isFreeTrailEligible =false;

    @track nickname;

    @track showImageError = false;
    @track savingData = false;

    @track showPopup = false;
    @api playStoreURL;
    @api appStoreURL;
    @api acuraPlayStoreURL;
    @api acuraAppStoreURL;
    popupAppStoreIcon = this.myGarageResource() + '/images/appstoreicon.png';
    popupPlayStoreIcon = this.myGarageResource() + '/images/playstoreicon.png';

    get displayNickname(){
        if (this.nickname){
            return this.nickname;
        }
        else{
            return (this.year ? this.year : '') + ' '
                        + (this.model ? this.model : '') + ' '
                        + (this.trim ? this.trim : '');
        }
    }

    vin;
    vinInputVal = "";
    year;
    model;
    @track trim;
    @track modelId;
    exteriorColor;
    licensePlate;
    @track state;
    radioCode;
    navCode;
    @track showConfirmationPopup = false;
    product;
    saveSuccessful = false;

    hideRadioCode = true;

    @track vehicleImage;
    logoImage;
    defaultVehicleImage; //Large_Image_Url__c from Product_Model_Color__c. Need an Apex method to retrieve this.
    customVehicleImage;
    hondaLogoSrc =  '/resource/Owners/images/garage_hondadefault.svg';
    acuraLogoSrc = '/resource/Owners/Logos/honda_acura.svg';
    powersportsLogoSrc = '/resource/Owners/Logos/honda_powersports.svg';
    powerequipmentLogoSrc = '/resource/Owners/Logos/honda_equipment.svg';
    marineLogoSrc = '/resource/Owners/Logos/honda_marine.svg';

    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));

    productSettingsTitle = PRODUCT_SETTINGS_TITLE;
    saveButtonClass = SAVE_BUTTON_DISABLED;
    saveButtonDisabled = true;

    correctVINLength;
    incorrectVINLength;
    @track displayVINError=false;
    incorrectVinErrorText = VIN_ERROR_TEXT;
    @track incorrectVIN = false;

    userHasProductError = USER_HAS_PRODUCT_ERROR;

    states;
    trims;
    exteriorColors;

    customImage;
    customImageURL;
    showEditPin = false;
    telematicsPlatform;
    telematicsUnit;
    @api ssoInitiatingURL;

    @api hasSecuritySubscription;
    @api hasRemoteSubscription;
    @api hasConciergeSubscription;
    
    @api androidAppLink;
    @api iosAppLink;

    @track subscriptions;
    @track subscriptionError;
    @track isConnectedPrimaryDriver;
    @track notNonConnectedPlatform = false;
    @track vinLookUp;
    @track vinDatabaseError;
    isErrorResponse = false;
    @api
    get showSubscriptionSection(){
        return (this.hasVIN && this.notNonConnectedPlatform) ? true : false;
    }

    get allowImageUpload(){
        if (this.hasVIN){
            return false;
        }
        else{
            return true;
        }
    }


    get vinErrorText(){
        if (this.userHasVin){
            return this.userHasProductError;
        }
        else if (this.incorrectVIN){
            return this.incorrectVinErrorText;
        }
        else if (this.vinDatabaseError){
            return VIN_DATABASE_ERROR;
        }
        else{
            return '';
        }
    }

    clearVinErrorFlags(){
        this.userHasVin = false;
        this.incorrectVin = false;
        this.vinDatabaseError = false;
    }

    get productIdentifierUppercase(){
        switch(this.division){
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
            case "Powerequipment":
                return "Serial Number";
            case "Marine":
                return "Serial Number";
        }
    }

    get productIdentifierLowercase(){
        return (this.division === "Powerequipment" || this.division === "Marine") ? this.productIdentifierUppercase.toLowerCase() : this.productIdentifierUppercase;
    }

    get productIdentifierEntryPlaceholder(){
        return "Enter " + this.productIdentifierUppercase;
    }

    get displayExteriorColor(){
        return (this.division != 'Powerequipment' && this.division != 'Marine');
    }

    get displayLicensePlate(){
        return (this.division != 'Powerequipment' && this.division != 'Marine');
    }

    get displayLicenseState(){
        return (this.division != 'Powerequipment' && this.division != 'Marine');
    }


    @track userHasVin = false; // DOE-4780 Brett Spokes

    // END VARIABLES //

    // INITIALIZATION //

    // Colors to be fixed later

/*     @wire(getModelColorsByModelId, {modelId : '$modelId'})
    wiredGetExteriorColors({ error, data }){
        if (data){
            console.log('colors data', JSON.stringify(data));
            this.exteriorColors = data;
        }
        else if (error){
            this.showToast_error('colors error',error);
            this.exteriorColors = undefined;
            //this.exteriorColor = undefined;
        }
    } */

    @wire(CurrentPageReference) pageref;

    initialize = async () => {
        //console.log('Product Settings Base URL: ' + this.baseURL);
/*         console.log(window.location.href.substring(window.location.href.indexOf("/s"), window.location.href.length-1));
        console.log(this.pageref); */
        //console.log(JSON.stringify(this.pageref));
        //console.log(sessionStorage.getItem('getContextProductId') ? sessionStorage.getItem('getContextProductId') : productId);
        this.context = await getContext('');
        this.productId = this.context.product.productId;
        this.ownershipId = this.context.product.ownershipId;
        this.divisionId = this.context.product.divisionId;
        this.division = this.context.product.division;
        this.productModelId = this.context.product.productModelId; //This corresponds to Vehicle__c, not Product_Model__c
        this.nickname = this.context.product.nickname;
        this.year = this.context.product.year;
        this.model = this.context.product.model;
        this.modelId = this.context.product.modelId;
        this.vin = this.context.product.vin;
        //Ravindra Ravindar (Wipro) DOE-4197
        this.hasVIN = this.vin && this.vin != '-' ? true : false;
        this.licensePlate = this.context.product.licenseNumber;
        this.exteriorColor = this.context.product.exteriorColor === '-' ? ' ' : this.context.product.exteriorColor;
        this.defaultVehicleImage = this.context.product.productDefaultImage;
        //console.log(this.context.product.productDefaultImage);
        //console.log(this.defaultVehicleImage);
        this.customVehicleImage = this.context.product.customerUploadedImage;
        this.logoImage = this.baseURL + this.context.product.image;
        //console.log('Product Settings Logo Image', this.logoImage);
        //Ravindra Ravindra (Wipro) DOE-2441
        this.redirectUrl = getOrigin() === 'MyAccount'? '/my-account' :getGarageURL(this.context.product.division);
        //console.log('redirectUrl', this.redirectUrl);
/*         switch (this.divisionId){
            case 'A':
                this.logoImage = this.baseURL + this.hondaLogoSrc;
                break;
            case 'B':
                this.logoImage = this.baseURL + this.acuraLogoSrc;
                break;
            case 'M':
                this.logoImage = this.baseURL + this.powersportsLogoSrc;
                break;
            case 'P':
                this.logoImage = this.baseURL + this.powerequipmentLogoSrc;
        } */


        //console.log(this.productId);

        //console.log("PRODUCTMODELID: " + this.productModelId);
        //console.log("PRODUCTMODELNAME: " + this.context.product.model)



        //console.log("OWNERSHIP ID: " + this.ownershipId);

        //console.log(this.productId);
        //console.log(this.vin);
        //console.log(this.licensePlate);

        if (this.productId){
            getProductDetails({productId : this.productId, ownershipId : this.ownershipId})
                .then(result => {
                    //console.log(result);
                    if (result.vin && !this.vin){
                        this.vin = result.vin;
                    }
                    //this.model = result.model;
                    if (result.modelId && !this.modelId){
                        this.modelId = result.modelId;
                    }
                    //console.log('MODEL ID: ' + this.modelId);
                    this.trim = result.trim;
                    if (result.exteriorColor && !this.exteriorColor){
                        this.exteriorColor = result.exteriorColor;
                    }
                    if (result.radioCode && !this.radioCode){
                        this.radioCode = result.radioCode;
                    }
                    if (result.customVehicleImage && !this.customVehicleImage){
                        this.customVehicleImage = result.customVehicleImage;
                    }
                    if (result.defaultVehicleImage && !this.defaultVehicleImage){
                        this.defaultVehicleImage = result.defaultVehicleImage;
                    }
                    //console.log('default vehicle image set to ' + this.defaultVehicleImage);
                    if (result.state){
                        //console.log('SETTING STATE: ' + result.state);
                        this.state = result.state;
                    }
                    this.setVehicleImage(this.defaultVehicleImage, this.customVehicleImage);
                    //this.defaultVehicleImage = result.defaultVehicleImage;
                    getTrims({ divisionId : this.context.product.divisionId, year : this.context.product.year, modelName : this.context.product.model})
                        .then(result => {
                                            //console.log('SETTING TRIMS');
                                            this.trims = result;
                                            //console.log(JSON.stringify(this.trims));
                                            //console.log(this.trim);
                                            this.modelId = this.trims.find(option => option.label === this.trim).value;
                                        })
                        .catch(error => {'getTrims error: ' + error;});

                })
                .catch(error => {'getProductDetails error: ' + console.log(error)});

            let manageSubs = await getManageSubscriptions({productIdentifier : this.vin, divisionId : this.divisionId})
            //console.log('ManageSubscriptions', manageSubs);
            // if(manageSubs && manageSubs.manageSubscriptions && manageSubs.manageSubscriptions.vehicleInfo){
            //     console.log(JSON.stringify(manageSubs));
            //     this.telematicsPlatform = manageSubs.manageSubscriptions.vehicleInfo[0].telematicsPlatform;
            //     this.telematicsUnit = manageSubs.manageSubscriptions.vehicleInfo[0].telematicsUnit;
            //     if(this.telematicsPlatform == '2ZS' || this.telematicsPlatform == 'MY17' || this.telematicsPlatform == 'MY23'){
            //         this.showEditPin = true;
            //     }
            // } 
            if(manageSubs && manageSubs.vehicleFeature && manageSubs.vehicleFeature.vehicle){
                this.telematicsPlatform = manageSubs.vehicleFeature.vehicle.telematicsPlatform;
                this.telematicsUnit = manageSubs.vehicleFeature.vehicle.telematicsUnit;
                if(this.telematicsPlatform == '2ZS' || this.telematicsPlatform == 'MY17' || this.telematicsPlatform == 'MY23'){
                    this.showEditPin = true;
                }
            }
            
        }

        //console.log(this.productId);

        if (this.hasVIN){
            this.vinLookUp = await productIdentifierLookUp(this.context.product.productIdentifier, this.context.product.divisionId)
            this.getSubscriptions();
        }
        //console.log('INITIALIZE END: DIVISION - ' + this.division);
    };

    connectedCallback(){
        if (sessionStorage.getItem('vinHelpBreadcrumb')){
            sessionStorage.removeItem('vinHelpBreadcrumb');
        }
        // Retrieve information from database (HondaProducts) based on the ProductId provided
        //console.log('USER ID ' + this.getUserId());
        this.initialize();

        // Retrieve list of states
        getStates().then(result => {this.states = result;}).catch(error => {console.log(error);});

        //console.log('context' + this.context);
    }

    setVehicleImage(defaultVehicleImage, customVehicleImage){
        //this.vehicleImage = this.customImageTestURL;
        //console.log('SetVehicleImage');
        //console.log('DEFAULT: ' + this.defaultVehicleImage);
        //console.log('CUSTOM: ' + this.customVehicleImage);
        //console.log(this.hasVin);
        let selectedImage;
        if (this.hasVin && defaultVehicleImage){
            //console.log("Setting VIN image;");
            selectedImage = defaultVehicleImage;
        }
        else if (customVehicleImage){
            //console.log("Setting custom image;");
            selectedImage = customVehicleImage;
        }
        else if (defaultVehicleImage){
            //console.log("Setting default image;");
            selectedImage = defaultVehicleImage;
        }
        else{
            // Should be generic image per brand
            //console.log("Setting generic image;");
            selectedImage = this.logoImage;
        }

        this.vehicleImage = selectedImage;
        //this.vehicleImage = imageExists(selectedImage) ? selectedImage : this.hondaLogoImage;

        //console.log("image: " + this.vehicleImage);
    }


    selectImageFromVINAPI(vinImageSet){
        // Pass 'assets' from VIN API result to select the correct image
        // Find an 'IMGMIDSIZE' image if possible; if not, use the first available image
        let selectedImage='';

        if (vinImageSet){
            vinImageSet.find(element => {
                if (element.assetType === PREFERRED_VIN_IMAGE_TYPE){
                    selectedImage = element.imagePath;
                }
            });
            if (!selectedImage){
                vinImageSet.find(element => {
                    if (element.imagePath){
                        selectedImage = element.imagePath;
                    }
                })
            }
        }

        return selectedImage;
    }


    setSaveButtonClass(){
        // Currently, save button must be set to 'active' after the user changes any field value
        this.saveButtonClass = SAVE_BUTTON_ACTIVE;
        this.saveButtonDisabled = false;
    }

    disableSaveButton(){
        this.saveButtonClass = SAVE_BUTTON_DISABLED;
        this.saveButtonDisabled = true;
    }
    // END INITIALIZATION //

    // FORM HANDLERS //

    handleNicknameChange(event){
        this.nickname = event.detail.value;
        //console.log(this.nickname);
        this.setSaveButtonClass();
    }

    handleVINChange(event){
        this.userHasVin = false;
        this.vin = event.target.value;
        this.vinInputVal = event.target.value;
        if (this.vin){
            this.userEnteredVIN = true;
        }
        else{
            this.userEnteredVIN = false;
        }
        if (this.vin && this.vin.length === 17){
            this.incorrectVINLength = false;
            this.correctVINLength = true;
        }
        else{
            this.correctVINLength = false;
        }
        this.setSaveButtonClass();
    }

    // 'Save' button is enabled when the user makes any changes, regardless of whether or not they undo those changes

    handleTrimChange(event){
        this.modelId = event.detail.value;
        this.trims.forEach(element => { 
            if(element.value === this.modelId){ 
                this.trim = element.label;
            }
        });
        this.setSaveButtonClass();
    }

    handleColorChange(event){
        this.exteriorColor = event.detail.value;
        this.setSaveButtonClass();
    }

    handleRadioCodeChange(event){
        this.radioCode = event.detail.value;
        this.setSaveButtonClass();
    }

    handleNavCodeChange(event){
        this.navCode = event.detail.value;
        this.setSaveButtonClass();
    }

    handleLicensePlateChange(event){
        this.licensePlate = event.detail.value;
        this.setSaveButtonClass();
    }

    handleLicensePlateStateChange(event){
        this.state = event.detail.value;
        this.setSaveButtonClass();
    }

    handleVINHelp(){
        // Runs when VIN help text is pressed
        if (this.division == 'Honda' || this.division == 'Acura' || this.division == 'Powersports' || this.division == 'Motorcycle/Powersports'){
            localStorage.setItem('VINHelpBreadcrumb', 'ProductSettings');
            this.navigate('/vin-help/?model=' + this.model, {});
        }
        else if (this.division == 'Power Equipment' || this.division == 'Powerequipment'){
            sessionStorage.setItem('vinHelpBreadcrumb', 'productSettings');
            this.navigate('/sample-emission-label-powerequipment', {});
        }
        else if (this.division == 'Marine'){
            sessionStorage.setItem('vinHelpBreadcrumb', 'productSettings');
            this.navigate('/marine-emissions-location-label', {});
        }
    }


    handleVINHelp(){
        // Runs when VIN help text is pressed
        localStorage.setItem('VINHelpBreadcrumb', 'ProductSettings');
        this.navigate('/vin-help/?model=' + this.model, {});
    }

    handleRadioCodeHelp(){
        // Runs when Radio code help text is pressed
    }

    // END FORM HANDLERS //

    // SUBSCRIPTIONS //


    getSubscriptions(){
        getManageSubscriptions({productIdentifier: this.context.product.productIdentifier ?? this.context.product.vin,divisionId: this.context.product.divisionId})
            .then(result => {
                //console.log('getMySubscriptions: ',result);
                this.subscriptions = JSON.parse(JSON.stringify(result.packages));
                if(result.packages && result.packages.length == 1 && result.packages[0].packageName == 'Error'){
                    this.isErrorResponse = true;
                }
                let telematicsplatform = this.vinLookUp.vehicle.telematicsPlatform;
                if(!nonConnectedPlatformMap.includes(telematicsplatform)){
                    this.notNonConnectedPlatform = true;
                }
                // This Loop is used to change the order of packages as per figma 
                for(let i=0; i < this.subscriptions.length; i++){
                    if(this.subscriptions[i].packageName == 'Error'){
                        this.subscriptionError = this.subscriptions[i].status;
                        this.isConnectedPrimaryDriver = false;
                        return;
                    }
                    // if(this.subscriptions[i].packageAPIName.toUpperCase() == 'SAFETY AND SECURITY'){
                    //   this.subscriptions = this.moveElement(this.subscriptions, i, 1);
                    // }
                    // else if(this.subscriptions[i].packageAPIName.toUpperCase() == 'REMOTE PACKAGE'){
                    //   this.subscriptions = this.moveElement(this.subscriptions, i, 2);
                    // }
                    // else if(this.subscriptions[i].packageAPIName.toUpperCase() == 'CONCIERGE'){
                    //   this.subscriptions = this.moveElement(this.subscriptions, i, 3);
                    // }
                }

                //AMSMG-5-2
                if(this.subscriptions.length == 4 || this.subscriptions.length == 5){
                    for (let step = 0;  step <= this.subscriptions.length-2; step++) {
                        if(this.subscriptions[step].packageDisplayName == this.subscriptions[this.subscriptions.length-1].packageDisplayName){
                        //console.log('Duplicate At End');
                        this.subscriptions.pop();
                        break;
                        }
                    }
                }
                //AMSMG-5-2

            })
            .catch(error=>{
            console.log(error);
        })
    }

    async handleSubscriptionClick(event){
        let dataPack = event.currentTarget.dataset.pack;
        //console.log('dataPack : ',dataPack);
        //console.log('event : ',event.target.dataset.value);
        //console.log('divisionId, ', this.divisionId);
        let url;
        if(event.target.dataset.value == 'Learn More' && this.context){
            url = this.context.product.divisionId == 'A' ? '/honda-product-compatibility-result' : '/acura-product-compatibility-result';
            //console.log('611 url');
            this.navigate(url, {});
        }else if((event.target.dataset.value == 'Sign Up' || event.target.dataset.value == 'Manage') && this.context){
            // if(this.telematicsPlatform == 'MY17'){
            //     this.singleSingOnToSXM();
            // }
            // if(this.telematicsPlatform == 'MY13'){
            //     this.navigate('/sxm-phone-info',{});
            // }
            //console.log('620');
            //Added New If For DOE-5069 By ABHISHEK SALECHA
            //console.log('Info: [', dataPack,'], [', this.divisionId ,'], [',this.telematicsUnit,'], [', this.telematicsPlatform,']');
            await getTrialEligibility({ productIdentifier: this.vin, divisionId: this.divisionId})
            .then((data) => {
                //console.log('isFreeTrailEligibleData : ', JSON.stringify(data.responseBody));
                let vehicleEligibility = data.responseBody;
                if (vehicleEligibility) {
                    let currentVehicleEligibility = JSON.parse(JSON.stringify(vehicleEligibility));
                    //console.log('This is this.vehicleEligibility', JSON.stringify(vehicleEligibility));
                    if (currentVehicleEligibility && currentVehicleEligibility.eligibilityFlag && currentVehicleEligibility.eligibleProducts) {
                        for (const eligibilityProduct of currentVehicleEligibility.eligibleProducts) {
                            if (eligibilityProduct.productName.toLowerCase().includes(dataPack.toLowerCase())) {
                                this.isFreeTrailEligible=true;
                                //console.log('@@isFreeTrailEligible'+this.isFreeTrailEligible);
                                break;
                            }
                        }
                    }
                }
    
            }).catch((error) => {
                console.log('Error : ', error);
            });
            // if(dataPack == 'Remote' && this.divisionId == 'B' && this.telematicsUnit == 'Y' && this.telematicsPlatform =='MY21'){
            //     this.showPopup = true;
            //     //console.log('624 remote b y my21');
            // }
            // else 
            if(dataPack == 'Security' || dataPack == 'Remote' || dataPack == 'Concierge'){
                if(this.divisionId == 'B' || this.divisionId == 'A'){
                    if((this.telematicsPlatform == 'MY17' || this.telematicsPlatform == 'MY21' || this.telematicsPlatform == 'MY23') && this.telematicsUnit == 'Y'){
                        //console.log(' 629 single sign on');
                        if(this.vinLookUp.vehicle.enrollment === 'N' && this.vinLookUp.vehicle.ownership === 'N'){
                            this.showPopup = true;
                        }else if(this.telematicsPlatform == 'MY17' && this.telematicsUnit  == 'Y' && this.isFreeTrailEligible == true){
                            this.showPopup = true;
                        }else{
                            this.singleSingOnToSXM();
                        }
                    }
                }   
            }
            else if((dataPack == 'Standard' || dataPack == 'Connect' || dataPack == 'Premium') && this.divisionId == 'B'){
                if(this.telematicsPlatform == 'MY13'){
                    //console.log(' 636 phone info');
                    this.navigate('/sxm-phone-info',{}); //'sirius-xm-phone-info'
                }
            }
            else if(dataPack == 'Link'){
                //console.log(' 641 Link');
                let deviceDetails = navigator.userAgent.toLowerCase();
                let navigationURL = deviceDetails.indexOf("android") > -1 ? this.androidAppLink : this.iosAppLink; 
                //console.log('This is navigation URL : ',navigationURL);
                if(this.divisionId == 'A' && (this.telematicsPlatform == 'MY16' || this.telematicsPlatform =='MY17' || this.telematicsPlatform =='MY21' || this.telematicsPlatform =='MY23' || this.telematicsPlatform =='2ZS')){
                        this.navigate(navigationURL,{});
                }  
                if(this.divisionId == 'B' && (this.telematicsPlatform =='MY17' || this.telematicsPlatform =='MY23')){
                        this.navigate(navigationURL,{});   
                }
            } //Added New If For DOE-5069 By ABHISHEK SALECHA
            else if(dataPack == 'Telematics' && this.divisionId == 'A' && this.telematicsPlatform =='MY23'){
              //console.log(' 653 popup');
              this.showPopup = true;
            }
            //console.log(' 656 end');
        }
    }


    handleEdit(event){
        let subscription = event.target.dataset.subscription;

        switch(subscription){
            case "security":
                // handle edit security subscription
                break;
            case "remote":
                // handle edit remote subscription
                break;
            case "concierge":
                //handle edit concierge subscription
                break;
        }
    }

    handleSignup(event){
        let subscription = event.target.dataset.subscription;

        switch(subscription){
            case "security":
                // handle security subscription signup
                break;
            case "remote":
                // handle remote subscription signup
                break;
            case "concierge":
                //handle concierge subscription signup
                break;
        }
    }

    // END SUBSCRIPTIONS //

    // ACTIONS //

    handleRadioNavCodeAction(){

    }

    handleViewSpecifications(){

    }

    handleRemoveFromGarage(){
        this.showConfirmationPopup = true;
        this.scrollToTop();
    }

    handleYes() {
        removeProduct(this.productId);
        //console.log('Redirecting to ' + this.redirectUrl);
        sessionStorage.setItem('removeProductRedirect', this.redirectUrl);
        sessionStorage.setItem('redirectMsg', 'remove');
        this.navigate( '/in-progress', {});
    }

    handleNo() {
        this.showConfirmationPopup = false;
    }

    scrollToTop() {
        window.scrollTo({
            left: 0,
            top: 0,
            behavior: 'smooth'
        });
    }

    handleReportStolen(){

    }

    // END ACTIONS //

    // IMAGE UPLOAD HANDLERS //

    saveCustomImage(){
        if (this.customImage){
            this.showImageError = false;
            //console.log('In saveCustomImage', this.customImage);
            saveImage({ownershipId : this.ownershipId, imageName : this.customImage.name, imageURL : this.customImage.dataURL, imageType : this.customImage.type})
                .then(result => {
                    //console.log('Image Upload Success');
                    this.customImageURL=result;
                    this.savingData = false;
                    this.setVehicleImage(this.defaultVehicleImage, this.customVehicleImage);
                    window.open( '.'+ this.redirectUrl, "_self" );
                })
                .catch(error => {
                    this.showImageError = true;
                    this.savingData = false;
                    //console.log(JSON.stringify(error));
                });
            
            
        }else{
            this.savingData = false;
            window.open( '.'+ this.redirectUrl, "_self" );
        }
    }


    handleCustomImageUpload(event){
        //console.log('PARENT FILE UPLOAD HANDLER');
        //console.log(JSON.stringify(event.detail));
        //console.log('NAME ' + event.detail.name);
        this.customImage = event.detail;
        this.customImageURL = event.detail.dataURL;
        
        const imgName = event.detail.name;

        this.customVehicleImage = this.customImageURL;

        this.setSaveButtonClass();
    }

    // END IMAGE UPLOAD HANDLERS //

    // BUTTONS //

    handleSave(){
    // Runs when the 'save' button is pressed; calls one of two methods depending on whether or not the current vehicle has a VIN
    if(this.isInputValid()) {
        //console.log('@@test valid');
        if (this.vin && this.vin != '-'){
            this.vin = this.vin.trim();
        }
        if (this.hasVIN){
            this.handleSaveVIN();
        }
        else{
            this.handleSaveNoVIN();
            //console.log('User has vin, ',result);
        }
    }
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');

        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        //console.log('@@test'+isValid);
        return isValid;
    }


    handleSaveVIN(){
        this.savingData = true;
        save({  ownershipId : this.ownershipId, nickname : this.nickname, licensePlate : this.licensePlate, licensePlateState : this.state,
                radioCode : this.radioCode, navCode : this.navCode})
            .then(result => {   // Alexander Dzhitenov (Wipro), DOE-4843: Removed all 'success' toast messages.
                                //this.showToast_success();
                                setOrigin('ProductSettings');
                                //this.navigate( this.redirectUrl, {});
                                this.saveCustomImage();                               
                            })
            .catch(error => {   
                this.savingData = false;
                //console.log('error handleSaveVIN : ' + error);
                this.showToast_error();
            });

        
    }


    handleSaveNoVIN(){
        
        if (!this.userEnteredVIN){

            const product = this.context.product;
            product.nickname = this.nickname;
            product.vin = this.vin === '-' ? null : this.vin;
            product.modelId = this.modelId;
            product.trim = this.trim;
            product.licenseNumber = this.licensePlate;
            product.licenseState = this.licensePlateState;
            product.exteriorColor = this.exteriorColor;
            this.savingData = true;
            saveChanges({   productId : this.productId, ownershipId : this.ownershipId, divisionId : this.divisionId,
                            product: product, nickname : this.nickname, vin : this.vin === '-' ? null : this.vin,
                            modelId : this.modelId,
                            trim : this.trim, exteriorColor : this.exteriorColor + '',
                            radioCode : this.radioCode, navCode : this.navCode,
                            licensePlate : this.licensePlate, licensePlateState : this.state,
                            validVINLength : this.correctVINLength})
                .then(result => {   // Alexander Dzhitenov (Wipro), DOE-4843: Removed all 'success' toast messages.
                                    //this.showToast_success();
                                    setOrigin('ProductSettings');
                                    sessionStorage.setItem('getContextProductId', result);
                                    this.saveCustomImage();
                                    //console.log(this.redirectUrl);
                                    //console.log('.'+ this.redirectUrl);
                                })
                .catch(error => {   
                                    this.savingData = false;
                                    //console.log('error: ' + JSON.stringify(error));
                                    this.showToast_error();
                                });
            
            //console.log('RUNNING SAVE CHANGES');
        }
        else if (this.userEnteredVIN){
            //console.log('RUNNING SAVE CHANGES VIN');
            //console.log(this.licensePlate);
            //console.log(this.state);

            if (this.vin.length < 17){
                this.incorrectVINLength = true;
                this.displayVINError = true;
                this.incorrectVIN = true;
            }
            else{
                //console.log('SAVE CHANGES');
                this.incorrectVINLength = false;
                this.displayVINError = false;
                this.incorrectVIN = false;
                //DOE-4780 Added logic to check if user has vin in garage and prevent saving if that is the case. Brett Spokes
                //console.log('Checking if VIN ', this.vin, ' exists, currently userHasVin is, ', this.userHasVin);
                checkUserGarageForVIN({
                    'vin': this.vin
                })
                .then(result => {
                    this.userHasVin = result;
                    if (!this.userHasVin){
                        saveChangesVIN({productId : this.productId, ownershipId : this.ownershipId, divisionId : this.divisionId,
                                            nickname : this.nickname, vin : this.vin,
                                            modelId : this.modelId, validVINLength : this.correctVINLength,
                                            licensePlate : this.licensePlate, licensePlateState : this.state})
                        .then(result => {   let vinResultObj = JSON.parse(result);
                                            //console.log(result);
                                            //console.log('SUCCESS');
                                            this.saveSuccessful = true;
                                            if(!vinResultObj.isError){
                                                // Alexander Dzhitenov (Wipro), DOE-4843: Removed all 'success' toast messages.
                                                //this.showToast_success();
                                                setOrigin('ProductSettings');
                                                fromServer_updateConnectedFlag({productIdentifier : this.vin, divisionId : this.divisionId}).then((res) => {
                                                    //console.log('res :: ', res) ;
                                                    window.open( '.'+ this.redirectUrl, "_self" );
                                                }).catch((error) => {
                                                    //console.log('error', JSON.stringify(error));
                                                    this.saveSuccessful = false;
                                                });
                                                sleep(3000);
                                            }
                                            else{
                                                if (vinResultObj.message === 'Your VIN is currently not supported by MyGarage.'){
                                                    this.vinDatabaseError = true;
                                                }
                                                this.correctVINLength = false;
                                                this.incorrectVINLength = true;
                                                this.displayVINError = true;
                                                 //console.log('THEN');
                                                /*console.log(JSON.stringify(vinResultObj));
                                                this.showToast_error(vinResultObj.message); */
                                                //this.showToast_error('Incorrect VIN entered.');
                                            }
                                        })
                        .catch(error => {   // Note: This can return a number of things, for instance duplicate values or invalid VIN.S
                                            //console.log('CATCH');
                                            if(!this.saveSuccessful){
                                            this.correctVINLength = false;
                                            this.incorrectVINLength = true;
                                            this.displayVINError = true;
                                            this.incorrectVIN = true;
                                            //let msg =  error.body.pageErrors[0].statusCode === 'DUPLICATE_VALUE' ? 
                                            //'VIN is already registered with another product' : 'VIN is invalid';
                                            //console.log('error: ' + JSON.stringify(error));
                                            //this.showToast_error(msg);
                                            }
                                        });
                    }
                    else{
                        //console.log('User has vin, ',result);
                        this.saveButtonClass = SAVE_BUTTON_DISABLED;;
                        this.saveButtonDisabled = true;
                        this.displayVINError = true;
                        //this.showToast_error('Product already exists with this VIN in your garage');
                    }
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                });
            }
        }
    }

    handleCancel(){
        setOrigin('ProductSettings');
        this.navigate( this.redirectUrl, {});
    }


    handleEditPin = async (event) => {
        await this.updateUser();
        if(this.telematicsPlatform == '2ZS'){
            let deviceDetails = navigator.userAgent.toLowerCase();
            let navigationURL = deviceDetails.indexOf("android") > -1 ? this.androidAppLink : this.iosAppLink; 
            this.navigate(navigationURL,{}); //'mobile-app'
        }
        else if(this.telematicsPlatform == 'MY17'){
            //this.singleSingOnToSXM();
            this.showPopup = true;
            //this.navigate(this.ssoInitiatingURL,{});
        }
        else if(this.telematicsPlatform == 'MY13'){
            this.navigate('/sxm-phone-info',{});
        }//Added New If For DOE-5069 By ABHISHEK SALECHA
        else if(this.divisionId == 'B' && this.telematicsPlatform =='MY21' && this.telematicsUnit == 'Y'){
            this.showPopup = true;
        }
    }

    singleSingOnToSXM(){
        getSSO({ productIdentifier : this.vin })
            .then((data) => {
                //console.log('Data : ',typeof(data));
                if(data.statusCode === 200){
                    if(this.isJSON(data.response)){
                        let jsonResponse = JSON.parse(data.response);
                        if(jsonResponse && jsonResponse.body && jsonResponse.body.status === 'success'){
                          this.navigate(jsonResponse.body.url, {});
                        }else{
                          this.showPopup = true;
                        }
                      }else{
                        let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
                        ssoDiv.innerHTML = data.response;
                        //console.log('this querySelector : ',this.template.querySelector('form'));
                        this.template.querySelector('form').submit();
                      }
                }else{
                    this.showPopup = true;
                }
            })
            .catch((error) => {
                console.log('Error : ',error);
                this.showPopup = true;
            });
        // if(this.divisionId == 'B'){
        //     getSSPSSOAcuralink({ productIdentifier : this.vin , divisionId : this.divisionId })
        //     .then((data) => {
        //         console.log('Data : ',typeof(data));
        //         if(data.statusCode === 200){
        //             let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
        //             ssoDiv.innerHTML = data.response;
        //             console.log('this querySelector : ',this.template.querySelector('form'));
        //             this.template.querySelector('form').submit();
        //         }else{
        //             this.showPopup = true;
        //         }
        //     })
        //     .catch((error) => {
        //         console.log('Error : ',error);
        //         this.showPopup = true;
        //     });
        // }
        // if(this.divisionId == 'A'){
        //     getSSPSSOHondalink({ productIdentifier : this.vin , divisionId : this.divisionId })
        //     .then((data) => {
        //         if(data.statusCode === 200){
        //             let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
        //             ssoDiv.innerHTML = data.response;
        //             console.log('this querySelector : ',this.template.querySelector('form'));
        //             this.template.querySelector('form').submit();
        //         }else{
        //             this.showPopup = true;
        //         }
        //     })
        //     .catch((error) => {
        //         console.log('Error : ',error);
        //         this.showPopup = true;
        //     });
        // }
    }

    get popupText(){
        if(this.divisionId === 'A'){
            return 'DOWNLOAD THE HONDALINK APP AND PAIR WITH YOUR HONDA TO START USING THESE FEATURES TODAY';
        }else{
            return 'DOWNLOAD THE ACURALINK APP AND PAIR WITH YOUR ACURA TO START USING THESE FEATURES TODAY';
        }
    }

    isJSON(str) {
        try {
            return (JSON.parse(str) && !!str);
        } catch (e) {
            return false;
        }
    }

    closePopup(){
        this.showPopup = false;
    }

    handleNavigations(event){
        this.showPopup = false;
        let navigationUrl;
        if(this.divisionId == 'A'){
            navigationUrl =  event.currentTarget.dataset.hondaurl;
        }else if(this.divisionId == 'B'){
            navigationUrl =  event.currentTarget.dataset.acuraurl;
        }
        this.navigate(navigationUrl, {});
    }

    updateUser = async () => { 
       let customerId = await getValidateCustomerIdentity({productIdentifier : this.vin, divisionId : this.divisionId});
       //console.log('customerId',customerId); 
       const fields = {};
            fields[ID.fieldApiName] = UserId;
            fields[VIN.fieldApiName] = this.vin;
            fields[BRAND.fieldApiName] = this.divisionId == 'A' ? 'Honda' : 'Acura';
            if(customerId){
                fields[CUSTOMERID.fieldApiName] = customerId;
            }
        const recordInput = { fields };
        await updateRecord(recordInput)
                .then((result) => {
                    //console.log('result',result);
                })
                .catch(error => {
                    //console.log('error',error);
                });
    }
    // END BUTTONS //
}
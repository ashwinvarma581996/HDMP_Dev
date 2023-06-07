import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';

import { viewProduct, setOrigin, getOrigin } from 'c/ownDataUtils';
import commonResources from "@salesforce/resourceUrl/Owners";
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';
import getUserGarageForVIN from '@salesforce/apex/OwnGarageController.getUserGarageForVIN';
import getRecallsByProductIdentifier from '@salesforce/apex/OwnAPIController.getRecallsByProductIdentifier';
import { ISGUEST } from 'c/ownDataUtils';

const FIND_BUTTON_DISABLE_CLASS = 'slds-button slds-button_neutral custom-button custom-button-find disable ';
const FIND_BUTTON_ACTIVE_CLASS = 'slds-button slds-button_neutral custom-button custom-button-find active';



const FIND_BRAND_BUTTON_ACTIVE = 'find-brand-button-active';
const FIND_BRAND_BUTTON_DISABLED = 'find-brand-button-disabled';
const FIND_BRAND_SECTION_BUTTON_ACTIVE = 'find-brand-section-button-active';
const FIND_BRAND_SECTION_BUTTON_DISABLED = 'find-brand-section-button-disabled';
const VIN_DATABASE_ERROR = 'Your VIN is currently not supported by MyGarage.';
const PREFERRED_VIN_IMAGE_TYPE = "IMGMIDSIZE";

export default class OwnAutoLinkmyQConnectedDetail extends OwnBaseElement {
    playStoreUrl;
    appStoreUrl;

    productImage = this.myGarageResource() + '/images/blue_link_button.png';
    appStoreIcon = this.myGarageResource() + '/images/app_store_black_icon.png';
    playStoreIcon = this.myGarageResource() + '/images/play_store_black_icon.png';

    @api contentId;
    @api contentId2;
    @api contentId3;
    @api contentId4;
    @api contentId5;
    @api getAppSectionTitle;
    @api featuresTitle;
    @api includesTitle;

    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';

    @track section1Content = {};
    @track section2Content = {};
    @track features = [];


    @track vin;
    @track isVinDatabaseError = false;
    @track divisionName = "Honda";
    @api division = "Honda";
    @track divisionId = 'A';
    vinHelpIcon = commonResources + '/Icons/garage_questionmark.png';
    @track incorrectVINLength = false;
    @track correctVINLength = false;
    @track vinInputVal = "";
    @track displayVINError = false;
    @track year;
    @track model;
    @track trim;
    @track modelId;
    @track modelSelectionDisabled = true;
    @track trimSelectionDisabled = true;
    @track modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track vinFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track modelSectionButtonClass = FIND_BRAND_SECTION_BUTTON_ACTIVE;
    @track vinSectionButtonClass = FIND_BRAND_SECTION_BUTTON_DISABLED;
    @track showModelSection = true;
    @track showVinSection = true;
    @track isGuest = ISGUEST;
    get vinErrorText() {
        if (this.isVinDatabaseError) {
            return VIN_DATABASE_ERROR;
        }
        else {
            return "Incorrect " + this.productIdentifierLowercase + " entered.";
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

    get prodIdMinLength() {
        return this.divisionId != 'PE' ? 17 : 4;
    }

    get prodIdMaxLength() {
        return this.divisionId != 'PE' ? 17 : 20;
    }

    get displayProductChooser(){
        return (this.divisionName === "Power Equipment" || this.divisionName === "Marine") ? false : true;
    }


    get buttonClass() {
        if (this.state) {
            return FIND_BUTTON_ACTIVE_CLASS;
        } else {
            return FIND_BUTTON_DISABLE_CLASS;
        }
    }
    connectedCallback() {
        this.initialize();
        this.initializeFeaturesCard();
    }

    initialize = async () => {
        this.getAppSectionTitle = this.getAppSectionTitle.replace('GARAGE', 'GARAGE<sup class="supTop">beta</sup>&nbsp;');
        //this.contentKeys = [this.contentId];
        //console.log('contentKeys', this.contentKeys);
        let result = await getManagedContentByTopicsAndContentKeys([this.contentId, this.contentId2], this.topics, this.pageSize, this.managedContentType);
        //console.log('result', result);
        result.forEach(element => {
            if (element.title.value != 'Vehicle Compatibility') {
                this.section1Content = {
                    title: element.title.value,
                    description1: element.descriptionLabel ? this.htmlDecode(element.descriptionLabel.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
                    description1Image: element.descriptionContent ? this.htmlDecode(element.descriptionContent.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : ''
                };
                this.playStoreUrl = element.phoneLabel ? element.phoneLabel.value : '';
                this.appStoreUrl = element.phone2Label ? element.phone2Label.value : '';
            } else {
                this.section2Content = {
                    subTitle1: element.title.value,
                    subDescription1: element.body ? this.htmlDecode(element.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : '',
                    subTitle2: element.descriptionLabel.value,
                    subDescription2: element.descriptionContent ? this.htmlDecode(element.descriptionContent.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>') : ''
                };
            }
        });
    }

    initializeFeaturesCard = async () => {
        this.contentKeys = [this.contentId3,this.contentId4,this.contentId5];
        //console.log('contentKeys', this.contentKeys);
        let result = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('result', result);
        result.forEach(element => {
            this.features.push({
                title: element.title.value,
                body: element.body ? this.htmlDecode(element.body.value) : '',
                desktopImage:element.descriptionContent? this.htmlDecode(element.descriptionContent.value): '',
                mobileImage: element.description2Content? this.htmlDecode(element.description2Content.value): ''
            });
        });

        this.features.sort((a, b) => {
            if (a.title < b.title) {
                return -1;
            }
            if (a.title > b.title) {
                return 1;
            }
            return 0;
        });
        //console.log('features', this.features);
    }

    handleNavigations(event) {
        let navigationUrl = event.currentTarget.dataset.url;
        //console.log(' navigation URL : ', navigationUrl)
        this.navigate(navigationUrl, {});
    }

    resetGarage() {
        localStorage.removeItem('garage');
    }

    handleFoundProduct(event) {
        /* let tierValues = [];
        this.dropdownArray.forEach(element => {
            tierValues.push({tierNumber : element.Tier_Number__c, tierName : element})
        }) */
        const product = event.detail;
        console.log('Product:');
        //console.log(JSON.stringify(product));
        let origin = 'ProductChooser';
        localStorage.setItem('origin', origin);
        setOrigin('ProductChooser');

        if (!this.isGuest) {
            this.resetGarage();
        }

        viewProduct(product);
    }


    handleVINHelp() {
        localStorage.setItem('VINHelpBreadcrumb', 'FindProduct' + this.divisionName);
        //console.log(this.divisionName);
        sessionStorage.removeItem('backlink');
        this.navigate('/vin-help/?division=' + this.divisionName, {});
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
                        // let eventMetadata = {
                        //     action_type: 'button',
                        //     action_category: 'body',
                        //     action_label: 'find'
                        // };
                        // let findProductDetails = {}
                        // findProductDetails.brandName = this.division;
                        // if (this.vin) { findProductDetails.vin = this.vin };
                        // let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata, findProductDetails: findProductDetails };
                        // if (document.location.pathname.includes('find-') || document.location.pathname.includes('garage-') ||
                        //     document.location.pathname.includes('-service-maintenance') || document.location.pathname.includes('-connected-features') ||
                        //     document.location.pathname.includes('-marketplace') || document.location.pathname.includes('-financial-services') ||
                        //     document.location.pathname.includes('-resources-downloads')) {
                        //     this.publishToChannel(message);
                        // }

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
                    console.log('getProductByVIN: error');
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
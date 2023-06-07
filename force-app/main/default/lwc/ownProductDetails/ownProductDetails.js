//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Owners Garage Find - Honda Auto Body logic of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the own garage find honda body component for all community pages.
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import {
    api,
    track,
    wire,
    LightningElement
} from 'lwc';
import {
    OwnBaseElement
} from 'c/ownBaseElement';
import {
    viewProduct,
    getOrigin,
    setOrigin,
    /* addProduct,*/
    getContext,
    getGarageURL,
    setProductContextUser,
    getProductContext
} from 'c/ownDataUtils';
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import getYears from '@salesforce/apex/FindProductController.getYears';
import getTrims from '@salesforce/apex/FindProductController.getTrims';
//import getStates from '@salesforce/apex/ownProductSettingsController.getStates';
/* import addProductByVin from '@salesforce/apex/OwnGarageController.addProductByVin';
import addProductByYMT from '@salesforce/apex/OwnGarageController.addProductByYMT'; */
import addProduct from '@salesforce/apex/OwnGarageController.addProduct';
import checkUserGarageForVIN from '@salesforce/apex/OwnGarageController.checkUserGarageForVIN';
import checkUserGarageForModelId from '@salesforce/apex/OwnGarageController.checkUserGarageForModelId';
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';
import getRecallsByProductIdentifier from '@salesforce/apex/OwnAPIController.getRecallsByProductIdentifier';
import getRecallsByModelId from '@salesforce/apex/OwnAPIController.getRecallsByModelId';
import getRadioNaviCodes from '@salesforce/apex/OwnGarageController.getRadioNaviCode';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';


const CHANGE_BRAND_BUTTON_ACTIVE = 'change-brand-button-active';
const CHANGE_BRAND_BUTTON_DISABLED = 'change-brand-button-disabled';
const ADD_BUTTON_ACTIVE = 'add-brand-button';
const ADD_BUTTON_DISABLED = 'add-brand-button-disabled';

const VIN_ERROR_TEXT = "Incorrect VIN entered.";
const VIN_DATABASE_ERROR = 'Your VIN is currently not supported by MyGarage.';
const PREFERRED_VIN_IMAGE_TYPE = "IMGMIDSIZE";

const USER_HAS_PRODUCT_ERROR = 'Attention: this product already exists in your Garage';

export default class ownProductDetails extends OwnBaseElement {

    @track fromProductChooser = false;
    @track productDetails;
    @api context;
    @api isguest;
    @track loginUrl;
    @track displaySavedDetails = false;
    @track displaySearchedDetails = false;
    @track subItems;
    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));
    @track division;
    //@track changeButtonClass = CHANGE_BRAND_BUTTON_DISABLED;
    //@track changeButtonDisabled = true;
    @track divisionId;
    @track nickname;
    @track modelName;
    @track years;
    @track trims;
    @track year;
    @track trim;
    @track modelId;
    @track serialNumberInput;
    @track originAddedProduct = false;
    @track userHasProduct = false;
    @track licensePlateString = '-';
    @track displayRecallIcon;
    @track isNotGuest = false;
    @track navigationCode;
    @track radioCode;

    userHasProductError = USER_HAS_PRODUCT_ERROR;

    /* @api
    get detailsLoaded(){
        return this.hasDetails;
    } */

    @api
    get displayTrimInput() {
        return (this.division != 'Motorcycle/Powersports' && !this.displayRegisterProduct)
    }

    @api
    get productImage() {
        if (this.fromProductChooser) {
            return this.productDetails.image ? (this.productDetails.image[0] === '/' ? this.baseURL + this.productDetails.image : this.productDetails.image) : null;
        } else {
            if (this.context.product.customerUploadedImage) {
                return this.context.product.customerUploadedImage;
            }
            else if (this.context.product.productDefaultImage) {
                return this.context.product.productDefaultImage;
            }
            else if (this.context.product.image) {
                return (this.context.product.image[0] === '/' ? this.baseURL + this.context.product.image : this.context.product.image);
            }
            else {
                return null;
            }
            /* return (this.context.product.customerUploadedImage ?
                this.context.product.customerUploadedImage : (this.context.product.productDefaultImage ?
                    this.context.product.productDefaultImage :
                    (this.context.product.image[0] === '/' ? this.baseURL + this.context.product.image : this.context.product.image))); */
        }
    }

    get displayNickname() {
        if (this.nickname) {
            //console.log('DISPLAYNICKNAME IS SETTING CUSTOM NICKNAME: ' + this.nickname);
            return this.nickname;
        } else {
            //console.log('DISPLAYNICKNAME IS SETTING DEFAULT NICKNAME: ' + (this.year ? this.year : '') + ' ' + (this.modelName && this.modelName != 'NULL' ? this.modelName : '') + ' ' + (this.trim && this.trim != 'NULL' ? this.trim : ''));
            //console.log(this);
            return (this.year ? this.year + ' ' : '') +
                (this.modelName && this.modelName != 'NULL' ? this.modelName + ' ' : '') +
                (this.trim && this.trim != 'NULL' ? this.trim : '');
        }
    }

    /*     get addButtonDisabled(){
            if (this.fromProductChooser){
                let viewedVin = this.productDetails.vin;
                let garageProducts = JSON.parse(localStorage.getItem('garage'));
                let vinFoundInGarage = false;
                //console.log('GARAGE PRODUCTS ******: ');
                //console.log(JSON.stringify(garageProducts));
                garageProducts.products.forEach(product => {
                    if (product.vin === viewedVin){
                        vinFoundInGarage = true;
                    }
                });
                return vinFoundInGarage;
            }
            else{
                return true;
            }
        } */
    get addButtonClass() {
        return this.userHasProduct ? ADD_BUTTON_DISABLED : ADD_BUTTON_ACTIVE;
    }

    @api
    get displayVin() {
        return (this.division === 'Honda' || this.division === 'Acura' || this.division === 'Motorcycle/Powersports');
    }

    /* @api
    get displayRecallIcon() {
        let recallCount = this.productDetails != 'undefined' ? this.productDetails.recallCount : this.context.product.recallCount;
        return recallCount > 0;
        //return false;
    } */

    @api
    get displayEnterVin() {
        let vin = this.productDetails != 'undefined' ? this.productDetails.vin : this.context.product.vin;
        return (this.division === 'Motorcycle/Powersports' && this.isguest && (vin != '-' && vin));
    }

    @api
    get displayRegisterProduct() {
        return (this.division === 'Powerequipment' || this.division === 'Marine');
    }

    @api
    get displayMarine() {
        return (this.division === 'Marine');
    }

    @api
    get displayExteriorColor() {
        return (this.division != 'Marine' && this.division != 'Powerequipment' && !this.isguest);
    }

    @api
    get displayRadioLink() {
        return (this.division === 'Honda' || this.division === 'Acura');
    }

    get licenseState() {
        return (this.context.product.licenseState ? this.context.product.licenseState : '-');
    }

    @api
    get vinError() {
        if (this.userHasProduct) {
            return this.userHasProductError;
        }
        else {
            return '';
        }
    }

    handleEnterVIN() {
        sessionStorage.removeItem('fromRecallCard');
        sessionStorage.removeItem('fromRecallDetail');
        this.navigate('/enter-vin', {});
    }

    handleExploreLink() {
        //console.log('Explore Link Clicked');
        if (this.divisionId == 'A') {
            this.navigate('/hondalink-marketing', {});
        } else if (this.divisionId == 'B') {
            this.navigate('/acuralink-marketing', {});
        }
    }
    //Track3-US-2075/76 Start
    handleRadioNavCode() {
        sessionStorage.setItem('showContextInRadioNav', true);
        this.navigate('/radio-nav-code?fb=true', {});
    }
    //Track3-US-2075/76  End

    handleAdd() {
        //console.log('handleAdd called');
        /* let garageProducts = JSON.parse(localStorage.getItem('garage'));
        //console.log('HANDLEADD: garageProducts: ' + JSON.stringify(garageProducts));
        const product = garageProducts.products[0]; */
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: 'add to my garage'
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        const context = JSON.parse(localStorage.getItem('context'));
        //console.log('/////PDP LOCAL CONTEXT: ' + JSON.stringify(context));
        let product = context.product;
        //console.log(product.vin);
        //console.log('PDP PRODUCT - HANDLEADD %%%% ' + JSON.stringify(product));
        if (this.isguest) {
            sessionStorage.setItem('originAddProduct', product.division);
            sessionStorage.setItem('redirectMsg', 'originAdd');
            let redirectUrl = this.baseURL + '/s/in-progress'
            let url = this.loginUrl + `&RelayState=${redirectUrl}`;
            window.open(url, "_self");

        } else /* if (product.vin && product.vin != '-') */ {
            setOrigin(' ');
            product.image = product.vin && product.vin != '-' ? product.image : '';
            //console.log(JSON.stringify(product));
            addProduct({
                product: product
            })
                .then(result => {
                    if (result.isSuccess) {
                        //console.log('Success');
                        sessionStorage.setItem('firstItemIndex', 0);
                        if (product.divisionId != 'P') {
                            window.location.reload();
                        }
                        else {
                            sessionStorage.setItem('addingPEMProduct', true);
                            this.navigate('/product-registration', {});
                        }
                    } else if (!result.isSuccess && result.message) {
                        //console.log('error in result ', result);
                        this.showToast_error(result.message);
                    } else {
                        this.showToast_error('An error has occurred.');
                    }
                    //this.navigate(getGarageURL(product.division), {});
                })
                .catch(error => {
                    //console.log('error: ' + JSON.stringify(error));
                    if (error.body.isUserDefinedException) {
                        this.showToast_error(error.body.message);
                    } else {
                        this.showToast_error('An error has occurred.');
                    }
                });
        }
    }

    handleEditSettingsClick() {
        this.navigate('/product-settings', {});

    }


    /* @wire(getYears, {
        divisionId: '$divisionId',
        modelName: '$modelName'
    })
    wiredGetYearsHonda({
        error,
        data
    }) {
        if (data) {
            this.years = data;
            let yearTemp = this.year;
            this.year = this.year;
        } else if (error) {
            this.showToast_error(JSON.stringify(error));
            this.years = undefined;
            this.year = undefined;
        }
    } */


    /* @wire(getTrims, {
        divisionId: '$divisionId',
        modelName: '$modelName',
        year: '$year'
    })
    wiredGetTrimsHonda({
        error,
        data
    }) {
        if (data) {
            this.trims = data;
        } else if (error) {
            //console.log('TRIMS Error');
            //console.log(JSON.stringify(error));
            this.showToast_error(JSON.stringify(error));
            this.trims = undefined;
            this.trim = undefined;
            this.modelId = undefined;
        }
    } */

    @api
    get accordinLabel() {
        if (this.displayRadioLink) {
            return 'Change ' + this.modelName + ' Model'
        } else if (this.displayRegisterProduct) {
            return 'Change Serial Number'
        } else {
            return 'Change Year'
        }
    }

    handleProductChange(event) {
        const product = event.detail;
        /* this.modelName = product.model;
        this.year = product.year;
        this.trim = product.trim;
        this.modelId = product.modelId;
        this.productDetails = product; */
        let garageProducts = JSON.parse(localStorage.getItem('garage'));
        garageProducts.products[0] = product;
        localStorage.setItem('garage', JSON.stringify(garageProducts));
        const contextInput = {
            // 'Level1': getGarageURL(product.division),
            // 'Level2': product.productId,
            'productTab': 'Overview',
            'productId': product.productId,
            'product': product
        };
        localStorage.setItem('context', JSON.stringify(contextInput));
        /* if (this.isguest) {
            //console.log('In Product Change');
            this.context = contextInput;
        } */
        //console.log('product-------: ', JSON.parse(JSON.stringify(product)));

        window.open('.' + getGarageURL(product.division), '_Self');

        //this.checkUserGarageForProduct();
        //viewProduct(product);
    }

    /* handleYearChange(event) {
        this.year = event.detail.value;
        //console.log(typeof (this.year));
        this.trim = null;
        this.modelId = null;
        this.setChangeButton();
    }

    handleTrimChange(event) {
        this.modelId = event.detail.value;
        this.trim = this.getTrimLabel(this.modelId);
        //console.log(this.getTrimLabel(this.modelId));
        //console.log('trim set to ' + this.trim);
        //console.log('modelId set to ' + this.modelId);
        this.setChangeButton();
    } */

    handleSerialNumberChange(event) {
        //console.log('SERIAL NUMBER CHANGE');
        this.serialNumberInput = event.detail.value;
        //console.log(this.serialNumberInput);
    }

    @api
    get changeButtonDisabled() {
        /* if (this.year && this.modelId) {
            this.changeButtonClass = CHANGE_BRAND_BUTTON_ACTIVE;
            this.changeButtonDisabled = false;
        } else {
            this.changeButtonClass = CHANGE_BRAND_BUTTON_DISABLED;
            this.changeButtonDisabled = true;
        } */
        if (this.serialNumberInput) {
            return false;
        }
        else {
            return true;
        }
    }
    @api
    get changeButtonClass() {
        if (this.changeButtonDisabled) {
            return CHANGE_BRAND_BUTTON_DISABLED;
        }
        else {
            return CHANGE_BRAND_BUTTON_ACTIVE;
        }
    }

    @api
    get displaySearched() {
        //let vin = this.productDetails != 'undefined' ? this.productDetails.vin : this.context.product.vin;
        return (!this.displaySavedDetails)
    }

    @api
    get hasVin() {
        let vin = this.productDetails != 'undefined' ? this.productDetails.vin : this.context.product.vin;
        return (vin && vin != '-');
    }

    handleChangerClick() {
        //console.log('Changer Click');
        /* let garage = JSON.parse(localStorage.getItem('garage'));
        if (this.division === 'Honda' || this.division === 'Acura') {
            garage.products[0].year = this.year;
            garage.products[0].trim = this.trim;
            garage.products[0].modelId = this.modelId;
            //garage.products[0].nickname = this.year + ' ' + this.modelName + ' ' + this.trim;
        } else if (this.division === 'Motorcycle/Powersports') {
            garage.products[0].year = this.year;
            //garage.products[0].nickname = this.year + ' ' + this.modelName + ' ' + this.trim;
        } else {
            garage.products[0].serialNumberInput = this.serialNumberInput;
        }
        if (!this.isguest) {
            //console.log('Removing garage from PDP');
            localStorage.removeItem('garage');
        }
        viewProduct(garage.products[0]); */
        this.serialNumberInput = this.serialNumberInput.trim();
        getProductByVIN({ divisionId: this.divisionId === 'PE' ? 'P' : this.divisionId, vin: this.serialNumberInput, divisionName: this.division === 'Powerequipment' ? 'Power Equipment' : this.division })
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

                    /* const product = {'divisionId': this.divisionId, 'division': this.divisionName,
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
                    const product = this.processVinResponse(prod.modelDetail);
                    //console.log('prod1  :-  ', JSON.stringify(product));

                    if (!this.isGuest) {
                        this.resetGarage();
                    }
                    let origin = 'ProductChooser';
                    localStorage.setItem('origin', origin);
                    setOrigin('ProductChooser');

                    getRecallsByProductIdentifier({ productIdentifier: product.vin, divisionId: product.divisionId }).then((res) => {
                        //console.log('RECALLS: res', res);
                        if (res.response.recalls_response.response.recall.campaignType.campaign) {
                            let result = JSON.parse(JSON.stringify(res.response.recalls_response.response.recall.campaignType.campaign));
                            //console.log('RECALLS: res', result);
                            product['recalls'] = result;
                            viewProduct(product);
                        } else {
                            viewProduct(product);
                        }
                    }).catch(err => {
                        console.error('RECALLS: err', err);
                        viewProduct(product);
                    });

                    // viewProduct(product);
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
            'division': this.division === 'Power Equipment' ? 'Powerequipment' : this.division,
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

    resetGarage() {
        localStorage.removeItem('garage');
    }

    /* getTrimLabel(modelId) {
        let trimLabel;
        this.trims.forEach(element => {
            if (element.value === modelId) {
                trimLabel = element.label;
            }
        });
        return trimLabel;
    }

    getModelId(trim) {
        let modelId;
        this.trims.forEach(element => {
            if (element.label === trim) {
                modelId = element.value;
            }
        });
        return modelId;
    } */

    connectedCallback() {
        this.alertIcon = this.myGarageResource() + '/ahmicons/alert1.svg';
        if (this.isguest) {
            this.getCIAMdetails();
        } else {
            this.isNotGuest = true;
        }

        if (getOrigin() === 'ProductSettings') {
            sessionStorage.setItem('firstItemIndex', 0);
            setOrigin('');
            this.launchContextReloadEvt();
            //window.location.reload();
        } else if (sessionStorage.getItem('userLoginSequence')) {
            sessionStorage.removeItem('userLoginSequence');
            this.launchContextReloadEvt();
            this.launchGarageReloadEvt();
        } else if (sessionStorage.getItem('refreshPDP')) {
            sessionStorage.removeItem('refreshPDP');
            this.launchContextReloadEvt();
            this.launchGarageReloadEvt();
        }
        else {
            /*             //console.log('Product Details Connected Callback ELSE 1');
                        this.initialize();   */
        }
        this.initialize();
    }

    getCIAMdetails = async () => {
        getCIAMConfig().then(result => {
            this.loginUrl = result.Ciam_Login_Url__c;
        })

    }

    initialize = async () => {
        ////console.log('ownProductDetails: context: ' + JSON.stringify(this.context));
        /* //console.log('Product Details Base URL: ' + this.baseURL);
        //console.log('Product Details Image: ' + this.productImage); */
        this.fromProductChooser = getOrigin() === 'ProductChooser' && !this.isguest ? true : false;
        this.displaySavedDetails = !this.fromProductChooser && !this.isguest ? true : false;
        // always filling with searched products for later use.
        let garageProducts = JSON.parse(localStorage.getItem('garage'));
        //console.log('PDP: ' + garageProducts);

        // Alexander Dzhitenov (Wipro): Update recall count in local storage, if context is available
        /* if (this.context){
            garageProducts.products.forEach( product => {
                if (product.vin == this.context.product.vin){
                    //console.log('VIN MATCH FOUND');
                    product.recallCount = this.context.product.recallCount;
                }
            });
        }
        localStorage.setItem(JSON.stringify(garageProducts)); */
        //NOTE: Use productDetails when we want to check and display searched products 

        this.productDetails = this.fromProductChooser && garageProducts.products && garageProducts.products.length > 0 ? garageProducts.products[0] : 'undefined';

        this.checkUserGarageForProduct();

        //console.log(JSON.stringify(this.context));
        this.division = this.fromProductChooser ? this.productDetails.division : this.context.product.division;
        if (this.context.product) {
            this.subItems = this.context.product.activeSubscription;
        }
        this.divisionId = this.productDetails != 'undefined' ? this.productDetails.divisionId : this.context.product.divisionId;
        this.nickname = this.productDetails != 'undefined' ? this.productDetails.nickname : this.context.product.nickname;
        this.modelName = this.productDetails != 'undefined' ? this.productDetails.model : this.context.product.model;
        this.year = this.productDetails != 'undefined' ? this.productDetails.year : this.context.product.year;
        this.trim = this.productDetails != 'undefined' ? this.productDetails.trim : this.context.product.trim;
        this.modelId = this.productDetails != 'undefined' ? this.productDetails.modelId : this.context.product.modelId;

        if (!this.isguest) {
            let ownershipId = this.productDetails != 'undefined' ? this.productDetails.ownershipId : this.context.product.ownershipId;
            this.getRadioNaviCode(ownershipId);
        }
        //Brett Spokes DOE-4791
        ////console.log('License number ', this.context.product.licenseNumber);
        //this.licensePlateString = this.context.product.licenseNumber != '-' ? this.licensePlateString = this.context.product.licenseState + ' ' + this.context.product.licenseNumber : "-";
        ////console.log('License plate string ', this.licensePlateString);

        this.licensePlateString = (this.context.product.licenseState ? this.context.product.licenseState + ' ' : '') + (this.context.product.licenseNumber ? this.context.product.licenseNumber : '-');

        if (this.displaySavedDetails && this.context.product.productId != this.context.lastVisitedProductID) {
            const contextInput = {
                'productId': this.context.productId,
                'productTab': 'Overview'
            };
            setProductContextUser(contextInput);
            await this.sleep(2000);
            sessionStorage.removeItem('getContextProductId');
            //window.location.reload();
            this.launchContextReloadEvt();
        }
        //this.showRecallIcon();

        //console.log('###PDP DEBUG: ');
        //console.log('displayRegisterProduct: ' + this.displayRegisterProduct);
        //console.log('displayRadioLink: ' + this.displayRadioLink);
        //console.log('displaySearched: ' + this.displaySearched);
        //console.log('displaySavedDetails: ' + this.displaySavedDetails);
        //console.log('hasVin: ' + this.hasVin);
        this.showRecallIcon();
    }

    getRadioNaviCode(ownershipId) {
        getRadioNaviCodes({ ownershipId: ownershipId })
            .then(result => {
                if (result && result.length > 0) {
                    this.navigationCode = result[0].Navi_Code__c ? result[0].Navi_Code__c : '-';
                    this.radioCode = result[0].Radio_Code__c ? result[0].Radio_Code__c : '-';
                } else {
                    this.navigationCode = '-';
                    this.radioCode = '-';
                }
            }).catch(error => {
                this.navigationCode = '-';
                this.radioCode = '-';
            });
    }

    checkUserGarageForProduct() {
        //console.log('%%% CHECK USER GARAGE FOR PRODUCT');
        //console.log(JSON.stringify(this.productDetails));
        if (this.fromProductChooser && (this.productDetails.vin && this.productDetails.vin != '-')) {
            //console.log('Running VIN check');
            checkUserGarageForVIN({
                'vin': this.productDetails.vin
            })
                .then(result => {
                    this.userHasProduct = result;
                })
                .catch(error => {
                    //console.log(JSON.stringify(error));
                })
        }
        else if (this.fromProductChooser && (!this.productDetails.vin || this.productDetails.vin === '-')) {
            //console.log('%%%% Running with product ' + JSON.stringify(this.productDetails));
            checkUserGarageForModelId({
                'modelId': this.productDetails.modelId
            })
                .then(result => {
                    this.userHasProduct = result;
                    //console.log('This is check user garage for product : ', this.userHasProduct)
                })
                .catch(error => {
                    //console.log(JSON.stringify(error));
                })
        }
    }

    async showRecallIcon() {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('RECALLS: From Product Chooser ----', fromProductChooser);
        let context;
        if (fromProductChooser) {
            context = await getProductContext('', true);
        } else {
            context = await getContext('');
        }
        //console.log('OwnRecallsNotification: CONTEXT - OwnProductDetail', JSON.parse(JSON.stringify(context)));
        if (context && context.product && context.product.hasOwnProperty('recalls')) {
            this.displayRecallIcon = context.product.recalls.length > 0 ? true : false;
        } else {
            this.displayRecallIcon = context.product.recallCount > 0 ? true : false;
        }
        /*if (context.product.productIdentifier || (context.product.vin && context.product.vin != '-')) {
            getRecallsByProductIdentifier({ productIdentifier: context.product.productIdentifier ?? context.product.vin, divisionId: context.product.divisionId }).then((res) => {
                //console.log('RECALLS: res ..', res);
                if (res.response.recalls_response.response.recall.campaignType.campaign) {
                    this.displayRecallIcon = true;
                }
            }).catch(err => {
                //console.log('RECALLS: err ..', err);
            });
        } else {
            getRecallsByModelId({ modelId: context.product.modelId, divisionId: context.product.divisionId }).then((res => {
                //console.log('MyModel-RESULT..: ', res);
                if (res.response.recalls_response.response.recall.campaignType.campaign) {
                    this.displayRecallIcon = true;
                }
            })).catch(err => {
                //console.log('RECALLS: err2..', err);
            });
        }*/
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    launchContextReloadEvt() {
        ////console.log('context reload evt');
        this.dispatchEvent(new CustomEvent('contextreload'));
    }
    launchGarageReloadEvt() {
        this.dispatchEvent(new CustomEvent('garagereload'));
    }

    handleRegisterProduct() {
        this.navigate('/product-registration', {});
    }
}
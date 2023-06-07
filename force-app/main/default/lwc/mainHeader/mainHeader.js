import { LightningElement, track, wire } from 'lwc';
import imageResourcePath from '@salesforce/resourceUrl/Menu_logo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GetModelByVinDecoder from '@salesforce/apex/B2B_INSystemIntegration.GetModelByVinDecoder';
import getCategoryId from '@salesforce/apex/B2B_VehicleSelectorController.getCategoryId';
import getVehicleYear from '@salesforce/apex/B2B_EconfigIntegration.getVehicleYear';
import getVehicleDetails from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetails';
import getVehicleModel from '@salesforce/apex/B2B_EconfigIntegration.getVehicleModel';
import getVehicleTrim from '@salesforce/apex/B2B_EconfigIntegration.getVehicleTrim';
import callVinDecoderService from '@salesforce/apex/B2B_EconfigIntegration.callVinDecoderService';
import getVehicleDetailsForAccessories from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetailsForAccessories';
import pubsub from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import getAccountByDealerNo from '@salesforce/apex/B2BGuestUserController.getAccountByDealerNo';
import getVehicleDetailsForParts from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetailsForParts';
import unlockCheckoutCart from '@salesforce/apex/B2BCartControllerSample.unlockCart';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import getLoginUrl from '@salesforce/label/c.Identity_Provider_Login_URL';
import getRegisterUrl from '@salesforce/label/c.Identity_Provider_Register_URL';
import getMyProductList from '@salesforce/apex/B2B_MySavedProduct.getMyProductList';
import communityId from '@salesforce/community/Id';
import getVehicleDetailsWithModalAndTrims from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetailsWithModalAndTrims';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import isguest from '@salesforce/user/isGuest'
import saveToMyProduct from '@salesforce/apex/B2B_MySavedProduct.saveToMyProduct';
import getCurrentCart from '@salesforce/apex/B2B_HandleCartAndUser.getCurrentCart';
import saveLastShoppingSelection from '@salesforce/apex/B2B_ShoppingSelectionController.saveLastShoppingSelection';
import getMyShoppingSelectionRecords from '@salesforce/apex/B2B_ShoppingSelectionController.getMyShoppingSelectionRecords';
//for adobe: starts
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';
//for adobe: ends

//for motocompacto
import { getCompleteDetails } from 'c/utils';

export default class ModalPopupLWC extends NavigationMixin(LightningElement) {
    honda = imageResourcePath + '/Hondalogo.png';
    acura = imageResourcePath + '/Acuralogo.png';
    @track checkValue = "";
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track buttonLabel = "Select Vehicle";
    @track makeDisabled = false;
    @track yearDisabled = false;
    @track modelDisabled = true;
    @track trimDisabled = true;
    @track storedMake = "";
    @track storedYear = "";
    @track storedModel = "";
    @track storedTrim = "";
    @track boolVisible = true;
    @track divisionValue;
    @track makeOptions = [{
        label: 'Honda',
        value: 'Honda'
    },
    {
        label: 'Acura',
        value: 'Acura'
    },
    ];

    @track yearId;
    @track modelId;
    @track TrimId;
    selectedOption = 'Parts';
    @track showParts = true;
    @track showAccessories = false;
    @track defaultSelect = true;
    @track makeValue;
    @track yearValue = 0;
    @track modelValue = 0;
    @track trimValue = 0;
    @track categoryId = "";
    @track poihondavalue;
    @track poiacuravalue;
    @track productType = 'Parts';
    value = '';
    @track isClickOnBrand = false;
    currentPageReference = null;
    urlStateParameters = null;
    @track brandHonda = true;
    @track brandAcura = true;
    @track brandHondaURL = '/s/honda';
    @track brandAcuraURL = '/s/acura';
    @track yearOptionsAcura = [];
    @track yearOptionsHonda = [];
    @track modelOptionHonda = [];
    @track modelOptionAcura = [];
    @track trimOptionHonda = [];
    @track trimOptionAcura = [];
    @track myProductOptions = []; // added by deepak mali
    @track defaultSelectHonda = true;
    @track defaultSelectAcura = true;
    @track showHondaParts = true;
    @track showHondaAccessories = false;
    @track showAcuraParts = true;
    @track showAcuraAccessories = false;
    @track hondaSubmitValue = 'Parts1';
    @track acuraSubmitValue = 'Parts3';
    @track cartId = '';
    @track isLoaded = false;
    @track storedYearId;
    @track storedModalId;
    @track storedTrimId;
    vinErrorMessage;
    @track vehicleData;
    @track hondaVehicleData;
    @track acuraVehicleData;
    yearOptionsVINHonda = [];
    @track enterKeyPressed = false; //Added by Deepak Mali 20 Aug 2021
    @track currentIndexForVin = ''; //Added by Deepak Mali 20 Aug 2021
    @track myProductList = [];
    @track isLoadedComponent = false
    @track showMyProductEditModalBox = false;
    @track isGuest = isguest;
    hondaIndicator = false;
    acuraIndicator = false;
    @track selecteMyProductId = '';
    @track allProductListHonda = [];
    @track allProductListAcura = [];
    @track showProductListHonda = false;
    @track showProductListAcura = false;
    @track mfgColorCode = '';
    mouseHover = false;

    //motocompacto starts
    @track isMotoCompacto = false;
    @track yearModelMapHonda = new Map();
    @track yearModelMapAcura = new Map();

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    wireuserdata({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            let userFirstName = data.fields.Name.value;
            if (USER_ID == undefined || USER_ID == null || userFirstName.includes('Guest')) {
                this.isGuest = true
            } else {
                this.isGuest = false;
            }
        }
    }
    //for adobe    
    @wire(MessageContext)
    messageContext;

    //async await
    getMyProductListFromApex() {
        getMyProductList()
            .then(result => {
                if (result) {
                    this.myProductList = result;
                    this.myProductList.forEach(element => {
                        if (element.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Honda') {
                            this.showProductListHonda = true;
                            this.allProductListHonda.push({
                                label: element.Nickname__c ? element.Nickname__c : element.Honda_Product__r.Product_Models__r.Model_Year__c + ' ' + element.Honda_Product__r.Product_Models__r.Model_Name__c,
                                value: element.Id
                            });
                        } else if (element.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Acura') {
                            this.showProductListAcura = true;
                            this.allProductListAcura.push({
                                label: element.Nickname__c ? element.Nickname__c : element.Honda_Product__r.Product_Models__r.Model_Year__c + ' ' + element.Honda_Product__r.Product_Models__r.Model_Name__c,
                                value: element.Id
                            });
                        }
                    });
                    this.setMyProduct();
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    handleChange(event) {
        this.productType = event.target.value;      
        if(sessionStorage.getItem('brandAndProductTypeMap')){
            let brandProductMap = JSON.parse(sessionStorage.getItem('brandAndProductTypeMap'));
            if(this.divisionValue == 1){
                brandProductMap.Honda = this.productType;
            }else if(this.divisionValue == 2){
                brandProductMap.Acura = this.productType;
            }
            sessionStorage.setItem('brandAndProductTypeMap', JSON.stringify(brandProductMap));
        }else {
            let brandForproductType = this.divisionValue == 1 ? 'Honda' : 'Acura';
            let obj = { [brandForproductType]: this.productType };
            sessionStorage.setItem('brandAndProductTypeMap', JSON.stringify(obj));
        }
        
        if (this.productType === 'Parts') {      
            if (this.divisionValue == 1) {
                this.showHondaParts = true;
                this.showHondaAccessories = false;
                setTimeout(function () {
                    this.fillTemplateData(1);
                    this.fillTemplateData(5);
                }.bind(this), 50);
                this.defaultSelectHonda = true;
                this.hondaSubmitValue = this.productType + '1';
            } else if (this.divisionValue == 2) {
                this.showAcuraParts = true;
                this.showAcuraAccessories = false;
                setTimeout(function () {
                    this.fillTemplateData(3);
                    this.fillTemplateData(7);
                }.bind(this), 50);
                this.defaultSelectAcura = true;
                this.acuraSubmitValue = this.productType + '3';
            }

        } else if (this.productType === 'Accessories') {
            if (this.divisionValue == 1) {
                this.showHondaParts = false;
                this.showHondaAccessories = true;
                this.defaultSelectHonda = false;

                setTimeout(function () {
                    this.fillTemplateData(2);
                    this.fillTemplateData(6);
                }.bind(this), 50);
                this.hondaSubmitValue = this.productType + '2';
            } else if (this.divisionValue == 2) {
                this.showAcuraParts = false;
                this.showAcuraAccessories = true;
                setTimeout(function () {
                    this.fillTemplateData(4);
                    this.fillTemplateData(8);
                }.bind(this), 50);
                this.defaultSelectAcura = false;
                this.acuraSubmitValue = this.productType + '4';
            }
        }
    }

    fillTemplateData(index) {
        let newYearId, newYearValue, newModelId, newModelValue, newTrimId, newTrimValue, vinValue;
        if (this.divisionValue == 1) {
            vinValue = sessionStorage.getItem('HondaVin');
            newYearId = sessionStorage.getItem('HondaYearId');
            newYearValue = sessionStorage.getItem('HondaYearValue');
            newModelId = sessionStorage.getItem('HondaModelId');
            newModelValue = sessionStorage.getItem('HondaModelValue');
            newTrimId = sessionStorage.getItem('HondaTrimId');
            newTrimValue = sessionStorage.getItem('HondaTrimValue');
        } else if (this.divisionValue == 2) {
            vinValue = sessionStorage.getItem('AcuraVin');
            newYearId = sessionStorage.getItem('AcuraYearId');
            newYearValue = sessionStorage.getItem('AcuraYearValue');
            newModelId = sessionStorage.getItem('AcuraModelId');
            newModelValue = sessionStorage.getItem('AcuraModelValue');
            newTrimId = sessionStorage.getItem('AcuraTrimId');
            newTrimValue = sessionStorage.getItem('AcuraTrimValue');
        }

        if (vinValue) {
            let vinName = '.Vin' + index;
            let vinCmp = this.template.querySelector(vinName);
            vinCmp.value = vinValue;
        }
        if (newYearId && newYearValue) {
            let yearCmpName = '.Year' + index;
            let yearCmp = this.template.querySelector(yearCmpName);
            //yearCmp.options = [{label : newYearValue , value : newYearId}];                                                                   	
            if (this.divisionValue == 1) {
                yearCmp.disabled = false;
                yearCmp.options = this.yearOptionsHonda;
            } else if (this.divisionValue == 2) {
                yearCmp.disabled = false;
                yearCmp.options = this.yearOptionsAcura;
            }
            yearCmp.value = newYearId;
            let modelCmpName = '.Model' + index;
            let modelCmp = this.template.querySelector(modelCmpName);
            modelCmp.disabled = false;
            if (this.divisionValue == 1) {
                modelCmp.options = this.modelOptionHonda;
                modelCmp.disabled = false;
            } else if (this.divisionValue == 2) {
                modelCmp.disabled = false;
                modelCmp.options = this.modelOptionAcura;
            }

            if (newModelId && newModelValue) {
                modelCmp.value = newModelId;
                let trimCmpName = '.Trim' + index;
                let trimCmp = this.template.querySelector(trimCmpName);
                trimCmp.disabled = false;
                if (this.divisionValue == 1) {
                    trimCmp.disabled = false;
                    trimCmp.options = this.trimOptionHonda;
                } else if (this.divisionValue == 2) {
                    trimCmp.disabled = false;
                    trimCmp.options = this.trimOptionAcura;
                }
                if (newTrimId && newTrimValue) {
                    trimCmp.value = newTrimId;
                }
            }
        }

        //Added by Deepak Mali 25 Feb 2022
        let productClass = '.Products' + index;
        let productCmp = this.template.querySelector(productClass);
        if (productCmp) {
            if (this.divisionValue == 1) {
                productCmp.value = sessionStorage.getItem('hondaMyProductId');
            } else if (this.divisionValue == 2) {
                productCmp.value = sessionStorage.getItem('acuraMyProductId');
            }
        }
        //END
    }

    constructor() {
        super();
        let isSubmitted = sessionStorage.getItem('isSubmited');
        if (!isSubmitted) {
            let dealer = sessionStorage.getItem('dealer') ? sessionStorage.getItem('dealer') : null;
            // sessionStorage.clear();       
            if (dealer) {
                sessionStorage.setItem('dealer', dealer);
            }
            //sessionStorage.setItem('isSubmited', false);
        }
    }

    connectedCallback() {
        this.retrieveCategory();
        if (window.location.href.indexOf("/s/category/") > -1 || window.location.href.indexOf("/s/product/") > -1) {
            var currentUrl = window.location.href;
            sessionStorage.setItem('lastShoppingUrl', currentUrl);
        }
        if (this.makeValue == 'Honda' && this.getCookie('Make') != 'undefined' && this.getCookie('Make') != 'null' && this.getCookie('Make') != null && this.getCookie('Make') != '') {
            this.buttonLabel = 'MyVehicle: ' + this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim');
            this.boolVisible = true;
        } else {
            this.buttonLabel = 'Select Vehicle----';
            this.boolVisible = false;
        }
        if (sessionStorage.getItem('dealer')) {
            let dealer = JSON.parse(sessionStorage.getItem('dealer'));
            if (dealer && dealer.brand) {
                let brands = dealer.brand.split(',');
                if (brands.includes('Honda')) {
                    this.brandHonda = true;
                    this.brandAcura = false;
                }
                if (brands.includes('Acura')) {
                    this.brandHonda = brands.includes('Honda') ? true : false;;
                    this.brandAcura = true;
                }
            }
        }

        this.cartId = localStorage.getItem('checkCartId');
        if (this.cartId)
            this.updateCartStatus();

        // for prepopulating mega menu values on category and other pages      
        let isSubmitted = sessionStorage.getItem('isSubmited');
        if (isSubmitted && isSubmitted == 'true') {
            let brandAndType = JSON.parse(sessionStorage.getItem('brandAndProductTypeMap')); //added for Motocompacto
            this.yearId = this.getCookie('YearId');
            this.hondaVehicleData = sessionStorage.getItem('hondaVehicleData') != '' ? sessionStorage.getItem('hondaVehicleData') : null;
            this.acuraVehicleData = sessionStorage.getItem('acuraVehicleData') != '' ? sessionStorage.getItem('acuraVehicleData') : null;
            let division = sessionStorage.getItem('division');
            if (division && division == '1') {
                this.productType = brandAndType.Honda; //added for Motocompacto
                this.divisionValue = 1;
                //if(this.hondaVehicleData == null){                    
                let modelData = sessionStorage.getItem('ModelOptionHonda');
                let modelOptions = JSON.parse(modelData);
                this.modelOptionHonda = modelOptions;
                let trimData = sessionStorage.getItem('TrimOptionHonda');
                let trimOptions = JSON.parse(trimData);
                this.trimOptionHonda = trimOptions;
                // }                                      
                setTimeout(function () {
                    this.fillTemplateData(1);
                    this.fillTemplateData(5);
                    setTimeout(function () {
                        this.divisionValue = 2;
                        // if(this.acuraVehicleData == null){
                        let modelData = sessionStorage.getItem('ModelOptionAcura');
                        let modelOptions = JSON.parse(modelData);
                        this.modelOptionAcura = modelOptions;
                        let trimData = sessionStorage.getItem('TrimOptionAcura');
                        let trimOptions = JSON.parse(trimData);
                        this.trimOptionAcura = trimOptions;
                        // }
                        this.fillTemplateData(3);
                        this.fillTemplateData(7);
                    }.bind(this), 50);
                }.bind(this), 50);
            } else if (division && division == '2') {
                this.productType = brandAndType.Acura; //added for Motocompacto
                this.divisionValue = 2;
                // if(this.acuraVehicleData == null){
                let modelData = sessionStorage.getItem('ModelOptionAcura');
                let modelOptions = JSON.parse(modelData);
                this.modelOptionAcura = modelOptions;
                let trimData = sessionStorage.getItem('TrimOptionAcura');
                let trimOptions = JSON.parse(trimData);
                this.trimOptionAcura = trimOptions;
                //}                                    
                setTimeout(function () {
                    this.fillTemplateData(3);
                    this.fillTemplateData(7);

                    setTimeout(function () {
                        this.divisionValue = 1;
                        //if(this.hondaVehicleData == null){                    
                        let modelData = sessionStorage.getItem('ModelOptionHonda');
                        let modelOptions = JSON.parse(modelData);
                        this.modelOptionHonda = modelOptions;
                        let trimData = sessionStorage.getItem('TrimOptionHonda');
                        let trimOptions = JSON.parse(trimData);
                        this.trimOptionHonda = trimOptions;
                        //} 
                        this.fillTemplateData(1);
                        this.fillTemplateData(5);
                    }.bind(this), 50);
                }.bind(this), 50);
            }
        }
        setTimeout((self) => {
            //Added By Bhawesh 04-03-2022 start
            if (window.location.href.indexOf("/s/cart") > -1) {
                //Modified By Bhawesh 28-03-2022 start
                if(localStorage.getItem('cartBrand') == 'Honda'){
                    self.acuraIndicator = false;
                    self.hondaIndicator = true;
                }else if(localStorage.getItem('cartBrand') == 'Acura'){
                    self.hondaIndicator = false;
                    self.acuraIndicator = true;
                }else{
                    self.hondaIndicator = self.getCookie('Make') == 'Honda' ? true : false;
                    self.acuraIndicator = self.getCookie('Make') == 'Acura' ? true : false;
                }
            }else if(!window.location.href.endsWith('/s/')){
                if (self.makeValue == 'Honda' || self.getCookie('Make') == 'Honda') {
                    self.acuraIndicator = false;
                    self.hondaIndicator = true;
                } else if (self.makeValue == 'Acura' || self.getCookie('Make') == 'Acura') {
                    self.hondaIndicator = false;
                    self.acuraIndicator = true;
                }
            }
            //End
        }, 500, this);

        if (!this.isGuest) {
            this.handleLastShoppingSelection();
            this.getMyProductListFromApex();
        }
        window.addEventListener('resize', this.handleOnScreenReSize);
    }

    handleLastShoppingSelection() {
        getMyShoppingSelectionRecords()
            .then(result => {
                if (result && result != 'No records found') {
                    let data = JSON.parse(result);
                    let newYearId, newYearValue, newModelId, newModelValue, newTrimId, newTrimValue;
                    try {
                        sessionStorage.setItem('isSubmited', true);
                        sessionStorage.setItem('mainHeaderSearched', true);
                        if (data.hasOwnProperty("HondaVehicle")) {
                            let modelOptionAll = [];
                            let parseDataModel = JSON.parse(data.HondaVehicleModels);
                            let parseDataTrim = JSON.parse(data.HondaVehicleTrims);
                            let vehicleData = JSON.parse(data.HondaVehicle);
                            for (const [key, value] of Object.entries(parseDataModel)) {
                                modelOptionAll.push({
                                    label: key,
                                    value: value
                                })
                            }
                            let modelOptions = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);
                            let allTrimOptions = [];
                            for (const [key, value] of Object.entries(parseDataTrim)) {
                                allTrimOptions.push({
                                    label: key,
                                    value: value
                                })
                            }
                            let trimOptions = allTrimOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                            newYearId = vehicleData.iNYearID__c;
                            newYearValue = vehicleData.Year__c;
                            let modalCmp = modelOptions.find(item => item.label == vehicleData.Model__c);
                            newModelId = modalCmp.value;
                            newModelValue = modalCmp.label;
                            let TrimCmp = trimOptions.find(item => item.label == vehicleData.Trim__c);
                            newTrimValue = TrimCmp.label;
                            newTrimId = TrimCmp.value;
                            let vinValue = data.HondaVIN ? data.HondaVIN : '';
                            sessionStorage.setItem('HondaYearId', newYearId);
                            sessionStorage.setItem('HondaYearValue', newYearValue);
                            sessionStorage.setItem('HondaModelId', newModelId);
                            sessionStorage.setItem('HondaModelValue', newModelValue);
                            sessionStorage.setItem('HondaTrimId', newTrimId);
                            sessionStorage.setItem('HondaTrimValue', newTrimValue);
                            sessionStorage.setItem('HondaVin', vinValue);
                            sessionStorage.setItem('ModelOptionHonda', JSON.stringify(modelOptions));
                            sessionStorage.setItem('TrimOptionHonda', JSON.stringify(trimOptions));
                            this.modelOptionHonda = modelOptions;
                            this.trimOptionHonda = trimOptions;
                            setTimeout(() => {
                                this.divisionValue = 1;
                                this.fillTemplateData(1);
                                this.fillTemplateData(2);
                                this.fillTemplateData(5);
                                this.fillTemplateData(6);
                            }, 100);
                        }
                        if (data.hasOwnProperty("AcuraVehicle")) {
                            let modelOptionAll = [];
                            let parseDataModel = JSON.parse(data.AcuraVehicleModels);
                            let parseDataTrim = JSON.parse(data.AcuraVehicleTrims);
                            let vehicleData = JSON.parse(data.AcuraVehicle);
                            for (const [key, value] of Object.entries(parseDataModel)) {
                                modelOptionAll.push({
                                    label: key,
                                    value: value
                                })
                            }
                            let modelOptions = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);
                            let allTrimOptions = [];
                            for (const [key, value] of Object.entries(parseDataTrim)) {
                                allTrimOptions.push({
                                    label: key,
                                    value: value
                                })
                            }
                            let trimOptions = allTrimOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                            newYearId = vehicleData.iNYearID__c;
                            newYearValue = vehicleData.Year__c;
                            let modalCmp = modelOptions.find(item => item.label == vehicleData.Model__c);
                            newModelId = modalCmp.value;
                            newModelValue = modalCmp.label;
                            let TrimCmp = trimOptions.find(item => item.label == vehicleData.Trim__c);
                            newTrimValue = TrimCmp.label;
                            newTrimId = TrimCmp.value;
                            let vinValue = data.AcuraVIN ? data.AcuraVIN : '';
                            sessionStorage.setItem('AcuraYearId', newYearId);
                            sessionStorage.setItem('AcuraYearValue', newYearValue);
                            sessionStorage.setItem('AcuraModelId', newModelId);
                            sessionStorage.setItem('AcuraModelValue', newModelValue);
                            sessionStorage.setItem('AcuraTrimId', newTrimId);
                            sessionStorage.setItem('AcuraTrimValue', newTrimValue);
                            sessionStorage.setItem('AcuraVin', vinValue);
                            sessionStorage.setItem('ModelOptionAcura', JSON.stringify(modelOptions));
                            sessionStorage.setItem('TrimOptionAcura', JSON.stringify(trimOptions));
                            this.modelOptionAcura = modelOptions;
                            this.trimOptionAcura = trimOptions;
                            setTimeout(() => {
                                this.divisionValue = 2;
                                this.fillTemplateData(3);
                                this.fillTemplateData(4);
                                this.fillTemplateData(7);
                                this.fillTemplateData(8);
                            }, 100);
                        }
                    } catch (error) {
                        console.log('OUTPUTEr : ', error);
                    }
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    renderedCallback() {
        //START by Deepak Mali for My Product Stories at 12 Feb 2021
        if (this.isLoadedComponent == false) {
            // setTimeout(() => {
            this.setMyProduct();
            // }, 2000)
        }
        //END
    }

    setMyProduct() {
        try {
            if (sessionStorage.getItem('selecteMyProductId')) {
                let selecteMyProductId = sessionStorage.getItem('selecteMyProductId');
                let record = this.myProductList.find(item => item.Id == selecteMyProductId);
                const hondaIndex = [1, 2, 5, 6];
                const acuraIndex = [3, 4];
                let divisionIndex = sessionStorage.getItem('division');
                if (divisionIndex && divisionIndex == '1') {
                    hondaIndex.forEach(index => {
                        let productClass = '.Products' + index;
                        let productCmp = this.template.querySelector(productClass);
                        let vinCmp = this.template.querySelector('.Vin' + index);
                        if (productCmp)
                            productCmp.value = selecteMyProductId;
                        if (vinCmp && record)
                            vinCmp.value = record.Honda_Product__r.Product_Identifier__c;
                    })
                } else if (divisionIndex && divisionIndex == '2') {
                    acuraIndex.forEach(index => {
                        let productClass = '.Products' + index;
                        let productCmp = this.template.querySelector(productClass);
                        let vinCmp = this.template.querySelector('.Vin' + index);
                        if (productCmp)
                            productCmp.value = selecteMyProductId;
                        if (vinCmp && record)
                            vinCmp.value = record.Honda_Product__r.Product_Identifier__c;
                    })
                }
            }
            this.isLoadedComponent = true;
        } catch (error) {
            this.isLoadedComponent = true;
            console.error(error.message);
        }
    }

    handleToCreateAddress(event) { }

    updateCartStatus() {
        unlockCheckoutCart({ CartId: this.cartId })
            .then((result) => { })
            .catch((error) => { });
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        if (this.urlStateParameters.divisionid && this.urlStateParameters.divisionid === '0') {
            sessionStorage.removeItem("dealer");
        } else {
            if (this.urlStateParameters.divisionid && this.urlStateParameters.dealerno) {
                this.brandHonda = false;
                this.brandAcura = false;
                sessionStorage.removeItem("dealer");
                let brands = [];
                let divisionids = this.urlStateParameters.divisionid.split(',');
                if (divisionids.includes('1')) {
                    sessionStorage.setItem('brand', 'Honda');
                    sessionStorage.setItem('vehicleBrand', 'Honda');
                    sessionStorage.setItem('dealerSiteBrand', 'Honda');
                    localStorage.setItem('cartBrand', 'Honda');
                    brands.push('Honda');
                    this.brandHonda = true;
                    this.brandAcura = false;
                }
                if (divisionids.includes('2')) {
                    sessionStorage.setItem('brand', 'Acura');
                    sessionStorage.setItem('vehicleBrand', 'Acura');
                    sessionStorage.setItem('dealerSiteBrand', 'Acura');
                    localStorage.setItem('cartBrand', 'Honda');
                    brands.push('Acura');
                    this.brandHonda = brands.includes('Honda') ? true : false;;
                    this.brandAcura = true;
                }
                if (brands.length > 0) {
                    getAccountByDealerNo({ dealerNo: this.urlStateParameters.dealerno, isguest: isguest, brand: this.brandAcura ? 'Acura' : 'Honda' })
                        .then((result) => {
                            if (result) {
                                let dealer = {
                                    'brand': brands.join(),
                                    'id': result.Id,
                                    'label': result.Name,
                                    'dealerNo': this.urlStateParameters.dealerno
                                }
                                sessionStorage.setItem('dealer', JSON.stringify(dealer));
                                this.buildEffectiveDealer();
                                if (this.urlStateParameters.divisionid) {
                                    let pageName = '/';
                                    if (this.urlStateParameters.divisionid === '1') {
                                        pageName = 'honda';
                                    }
                                    if (this.urlStateParameters.divisionid === '2') {
                                        pageName = 'acura';
                                    }
                                    this.navigateToBrand(pageName);
                                }
                            }
                        })
                        .catch((error) => {
                            //console.log('error : ', error);
                        });
                }
            }
            if (this.urlStateParameters.divisionid && !this.urlStateParameters.dealerno) {
                let pageName = '/';
                if (this.urlStateParameters.divisionid === '1') {
                    pageName = 'honda';
                }
                if (this.urlStateParameters.divisionid === '2') {
                    pageName = 'acura';
                }
                this.navigateToBrand(pageName);
            }
        }
    }

    navigateToBrand(pageName) {
        // Use the built-in 'Navigate' method
        this[NavigationMixin.Navigate]({
            // Pass in pageReference
            type: 'standard__namedPage',
            attributes: {
                pageName: pageName
            }
        });
    }

    openModal() {
        // to open modal set isModalOpen track value as true

        var currURL = window.location.href;
        var parts = currURL.split('/');
        var lastSegment = parts.pop() || parts.pop(); // handle potential trailing slash

        if (lastSegment == 'honda') {
            this.makeValue = 'Honda';
            this.makeDisabled = true;
            this.yearDisabled = false;
        }
        if (lastSegment == 'acura') {
            this.makeValue = 'Acura';
            this.makeDisabled = true;
            this.yearDisabled = false;
        }
        this.isModalOpen = true;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    clearCookie() {
        this.createCookie('Make', '', 1); // Clear cookie first
        this.createCookie('Year', '', 1); // Clear cookie first
        this.createCookie('Model', '', 1); // Clear cookie first
        this.createCookie('Trim', '', 1); // Clear cookie first
        this.buttonLabel = 'Select Vehicle';
        this.boolVisible = false;
        var currURL = window.location.href;
        var parts = currURL.split('/');
        var lastSegment = parts.pop() || parts.pop(); // handle potential trailing slash
        if (lastSegment != 'honda' && lastSegment != 'acura') {
            location.reload();
        }
    }

    yearValueOnSubmit(yearCmp) {
        this.yearId = yearCmp.value;
        let yearObj = yearCmp.options.find(item => item.value == this.yearId);
        this.yearValue = yearObj.label;
    }

    modelValueOnSubmit(modelCmp) {
        this.modelId = modelCmp.value;
        let modelObj = modelCmp.options.find(item => item.value == this.modelId);
        this.modelValue = modelObj.label;
    }

    trimValueOnSubmit(trimCmp) {
        this.TrimId = trimCmp.value;
        let trimObj = trimCmp.options.find(item => item.value == this.TrimId);
        this.trimValue = trimObj.label;
    }

    submitDetailHelper(index) {
        let yearName = '.Year' + index;
        let yearCmp = this.template.querySelector(yearName);
        if (yearCmp.value) {
            this.yearValueOnSubmit(yearCmp);
        } else {
            this.yearId = null;
            this.yearValue = null;
        }

        let modelName = '.Model' + index;
        let modelCmp = this.template.querySelector(modelName);
        if (modelCmp.value) {
            this.modelValueOnSubmit(modelCmp);
        } else {
            this.modelId = undefined;
            this.modelValue = undefined;
        }

        let trimName = '.Trim' + index;
        let trimCmp = this.template.querySelector(trimName);
        if (trimCmp.value) {
            this.trimValueOnSubmit(trimCmp);
        } else {
            this.TrimId = undefined;
            this.trimValue = undefined;
        }
    }

    submitDetails(event) {
        // Added by Bhawesh on 24-03-2022 for HDMP-8359 start
        let existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));

        if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {

        }
        else {
            localStorage.setItem('allProductDetailsList', JSON.stringify([]));
        }
        localStorage.setItem('partSerachValue', '');
        localStorage.removeItem('searchedTerm');
        sessionStorage.removeItem('category');
        sessionStorage.removeItem('searchedTerm');
        // added for multi tab issue . starts here
        sessionStorage.removeItem('relayStatePage');
        // multi tab issue . ends here
        if (this.divisionValue == 1) {
            this.vinValue = sessionStorage.getItem('HondaVin');
            let obj = { 'Honda': this.productType };
            sessionStorage.setItem('brandAndProductTypeMap', JSON.stringify(obj));
        } else {
            this.vinValue = sessionStorage.getItem('AcuraVin');
            let obj = { 'Acura': this.productType };
            sessionStorage.setItem('brandAndProductTypeMap', JSON.stringify(obj));
        }
        // End
        //localStorage.removeItem('checkCartId');
        let isMobile = event.currentTarget.dataset.mobile;
        let submitValue = event.currentTarget.dataset.value;
        sessionStorage.setItem('fromWhichPageUserHasRefresh', 'CATEGORY'); //Added by Bhawesh on 11-02-2022 for HDMP-6887 
        if (isMobile === 'true') {
            let index;
            if (submitValue == 'Parts1') {
                index = '5';
            } else if (submitValue == 'Accessories2') {
                index = '6';
            } else if (submitValue == 'Parts3') {
                index = '7';
            } else if (submitValue == 'Accessories4') {
                index = '8';
            }
            this.submitDetailHelper(index);
        } else {
            let index = submitValue.charAt(submitValue.length - 1);
            this.submitDetailHelper(index);
        }

        let vehicle = {};
        if (this.divisionValue && this.yearValue && this.modelValue && this.trimValue) {

            //this.createCookie('ProductType', this.productType, 1);
            sessionStorage.setItem('ProductType', this.productType);
            // to close modal set isModalOpen track value as false
            localStorage.removeItem("category");
            let brand = this.makeValue;
            sessionStorage.setItem('brand', brand);
            sessionStorage.setItem('vehicleBrand', brand);
            sessionStorage.setItem('vehicleBrand2', brand); // used for backend breadcrumbs logic
            localStorage.setItem('cartBrand', brand);
            if (sessionStorage.getItem('dealer')) {
                this.buildEffectiveDealer();
            }
            if (this.checkVINValidation() && this.makeValue && this.yearValue && this.modelValue && this.trimValue) {
                this.createCookie('Make', '', 1); // Clear cookie first
                this.createCookie('Year', '', 1); // Clear cookie first
                this.createCookie('Model', '', 1); // Clear cookie first
                this.createCookie('Trim', '', 1); // Clear cookie first
                this.createCookie('YearId', '', 1); // Clear cookie first
                this.createCookie('ModelId', '', 1); // Clear cookie first
                this.createCookie('TrimId', '', 1); // Clear cookie first

                this.createCookie('Make', this.makeValue, 1);
                this.createCookie('Year', this.yearValue, 1);
                this.createCookie('Model', this.modelValue, 1);
                this.createCookie('Trim', this.trimValue, 1);
                this.createCookie('Vin', this.vinValue, 1);
                this.createCookie('Division', this.divisionValue, 1);
                this.createCookie('YearId', this.yearId, 1);
                this.createCookie('ModelId', this.modelId, 1);
                this.createCookie('TrimId', this.TrimId, 1);
                sessionStorage.setItem('selecteMyProductId', this.selecteMyProductId);
                // added on 11/12 start
                sessionStorage.setItem('VehicleName', this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim')); // used for backend breadcrumbs logic
                sessionStorage.setItem('VehicleModelId', this.getCookie('ModelId'));
                sessionStorage.setItem('VehicleVIN', this.vinValue);
                sessionStorage.setItem('VehicleYear', this.yearValue);
                sessionStorage.setItem('VehicleModel', this.modelValue);
                sessionStorage.setItem('VehicleTrim', this.trimValue);
                // added on 11/12 end
                try {
                    this.storedMake = this.getCookie('Make');
                    this.storedYear = this.getCookie('Year');
                    this.storedModel = this.getCookie('Model');
                    this.storedTrim = this.getCookie('Trim');
                    this.storedYearId = this.getCookie('YearId');
                    this.storedModalId = this.getCookie('ModelId');
                    this.storedTrimId = this.getCookie('TrimId');
                    this.buttonLabel = 'MyVehicle: ' + this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim');
                    this.isModalOpen = false;
                    var currURL = window.location.href;
                    var parts = currURL.split('/');
                    var getUrl = window.location;
                    var baseUrl = getUrl.protocol + "//" + getUrl.host + "/s/category/";
                    this.boolVisible = true;
                    this.saveToMyProductList(); // Added by Deepak Mali
                    this.handleSaveLastShoppingSelection();//Added by Faraz on 09/09/2022
                    //for adobe: starts
                    let eventMetadata = {
                        action_type: 'button',
                        action_label: 'search',
                        action_category: 'search by ' + this.productType
                    };
                    let findProductDetails = {
                        year: this.storedYear,
                        model: this.storedModel,
                        trim: this.storedTrim,
                        Model_Id__c: this.modelId,
                        brand: this.storedMake//for adobe bug-18
                    };
                    let events = 'product search by ' + this.productType;
                    const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'findProductDetails': findProductDetails, 'events': events } };
                    publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                    //for adobe: ends
                    this.goToCategoyPage(this.storedMake, baseUrl);           
                } catch (ex) {
                    //console.log(ex.message);
                }
            }
        } else {
            //Added by Deepak Mali 20 Aug 2021
            this.isLoaded = false;
            //The VIN field should not be editable while the search is executing
            let VinCmpName = '.Vin' + this.currentIndexForVin;
            let vinCmp = this.template.querySelector(VinCmpName);
            vinCmp.disabled = false;
            if (!this.enterKeyPressed || this.vinValue > 1) {
                if (this.vinValue && this.vinValue.length == 10 && this.vinErrorMessage) {
                    this.showNotification('Error', this.vinErrorMessage, 'error');
                } else {
                    this.showNotification('Error', 'Please select either year, model and trim or enter valid vin ', 'error');
                }
            }
        }
        //Sakshi -4815

        this.createCookie('VINFitValue', this.vinValue, 1);
        if (this.getCookie('Make') == 'Honda') {
            this.acuraIndicator = false;
            this.hondaIndicator = true;
        } else if (this.getCookie('Make') == 'Acura') {
            this.hondaIndicator = false;
            this.acuraIndicator = true;
        }
    }

    //Motocompacto starts
    async goToMotocompactoPDP(vehicle){
        console.log('vehicle raj : ',vehicle);
        sessionStorage.setItem('isMotoCompacto', 'true');
        //set breadcrum
        let brand = this.makeValue;
        let breadcrumbsList = [];
        let obj = {'label' : this.makeValue, 'isCurrentPage' : false, 'href' : window.location.origin+'/s/'+this.makeValue.toLowerCase()};
        breadcrumbsList.push(obj);    
        
        let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
        breadcrumbsMap.set(brand, JSON.parse(JSON.stringify(breadcrumbsList)));
        
        sessionStorage.setItem('breadcrumbsMap', JSON.stringify([...breadcrumbsMap]));
        sessionStorage.setItem(this.makeValue + 'ModelId' , this.modelId);
        sessionStorage.setItem(this.makeValue + 'ModelValue' , this.modelValue);

        let poiType = brand == 'Honda' ? 'A' : 'B';
        // calling getCompleteDetails from utils
        let productId = await getCompleteDetails(vehicle.Model_Id__c, poiType);
        console.log('product utils : ',productId);
        if(productId){
            window.location.href = '/s/product/' + productId;
        }else {
            this.showNotification('Error', 'We\'re experiencing technical difficulties, please try again later.', 'error');
        }                
    }
    //Motocompacto ends

    get makeOptions() {
        return [{
            label: 'Honda',
            value: 'Honda'
        },
        {
            label: 'Acura',
            value: 'Acura'
        },
        ];
    }

    @wire(getVehicleYear, {
        division: '$divisionValue'
    })

    wiredGetVehicleYear(result) {
        if (result.data) {
            let parseData = JSON.parse(result.data)
            let allYearOptions = [];
            for (const [key, value] of Object.entries(parseData)) {
                allYearOptions.push({
                    label: value,
                    value: key
                })
            }

            let yearOption = allYearOptions.sort(function (a, b) {
                return b.label - a.label;
            });
            if (this.divisionValue == 1 && this.yearOptionsHonda.length == 0) {
                this.yearOptionsHonda = yearOption;
                //this.createCookie('YearOptionHonda', JSON.stringify(this.yearOptionsHonda) , 1);
                sessionStorage.setItem('YearOptionHonda', JSON.stringify(yearOption));
            } else if (this.divisionValue == 2 && this.yearOptionsAcura.length == 0) {
                this.yearOptionsAcura = yearOption;
                //this.createCookie('YearOptionAcura', JSON.stringify(this.yearOptionsAcura) , 1);  
                sessionStorage.setItem('YearOptionAcura', JSON.stringify(yearOption));
            }
            this.error = undefined;
        } else if (result.error) {
            this.error = error;
            this.yearOptionsHonda = [];
            this.yearOptionsAcura = [];
        }
    }

    handleToEditMyProduct(event) {
        let index = event.currentTarget.dataset.index;
        let productClass = '.Products' + index;
        let productCmp = this.template.querySelector(productClass);
        let editProductId = productCmp.value;
        this.setSelectedMyProduct(editProductId, index);
        this.showMyProductEditModalBox = true;
        //END
        try {
            //  this.template.querySelector('c-my-product-modal-box').loadDataForEdit(JSON.stringify(sessionStorage.getItem('selectedMyProduct')));

            // let productName = this.template.querySelector('.Products' + index).value;
            // let yearValue = this.template.querySelector('.Year' + index).value;
            // let modalValue = this.template.querySelector('.Modal' + index).value;
            // let trimValue = this.template.querySelector('.Trim' + index).value;
            // let vinValue = this.template.querySelector('.Vin' + index).value;
        } catch (error) {
            console.error(error.message);
        }
    }

    setSelectedMyProduct(myProductId, index) {
        // Here we are sending data to Modal Box so user can edit this informations 
        let brandName = this.divisionValue == 1 ? 'Honda' : 'Acura';
        this.showModaxBox = true;
        let record = this.myProductList.find(item => item.Id == myProductId);
        let vinValue = this.template.querySelector('.Vin' + index).value;
        let vehicleRecord = {
            'Name': record.Nickname__c,
            'productType': brandName,
            'yearValue': record.Honda_Product__r.Product_Models__r.Model_Year__c,
            'modalValue': record.Honda_Product__r.Product_Models__r.Model_Name__c,
            'trimValue': record.Honda_Product__r.Product_Models__r.Trim__c,
            'vinValue': vinValue,
            'recordId': record.Id,
            'productModelId': record.Honda_Product__r.Product_Models__r.Product_Model_ID__c
        }
        this.vehicleData = JSON.stringify(vehicleRecord);
        //sessionStorage.setItem('selectedMyProduct', JSON.stringify(vehicleRecord));
        //END
    }

    closeModalBoxPopup(event) {
        this.showMyProductEditModalBox = false;
        if (event.detail) {
            window.location.reload();
        }
    }

    async handleProductChange(event) {
        let recordId = event.detail.value;
        this.selecteMyProductId = recordId;
        let index = event.currentTarget.dataset.index;
        //let name = '.' + event.currentTarget.name;
        let myProductRecord = this.myProductList.find(item => item.Id == recordId);
        let year, modal, trim;
        year = myProductRecord.Honda_Product__r.Product_Models__r.Model_Year__c;
        modal = myProductRecord.Honda_Product__r.Product_Models__r.Model_Name__c;
        trim = myProductRecord.Honda_Product__r.Product_Models__r.Trim__c;
        let productModelId = myProductRecord.Honda_Product__r.Product_Models__r.Product_Model_ID__c;

        //Added by Deepak Mali 3 March 2022
        let VinCmpName = '.Vin' + index;
        let vinCmp = this.template.querySelector(VinCmpName);
        vinCmp.value = myProductRecord.Honda_Product__r.Product_Identifier__c;
        vinCmp.setCustomValidity('');
        vinCmp.reportValidity();
        this.vinValue = myProductRecord.Honda_Product__r.Product_Identifier__c;

        let className = '';
        if (myProductRecord.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Honda' && myProductRecord.Honda_Product__r.Product_Identifier__c) {
            sessionStorage.setItem('HondaVin', myProductRecord.Honda_Product__r.Product_Identifier__c);
            className = 'hondaVINCheckBox'; // enable vin checkBox
        } else if (myProductRecord.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Acura' && myProductRecord.Honda_Product__r.Product_Identifier__c) {
            sessionStorage.setItem('AcuraVin', myProductRecord.Honda_Product__r.Product_Identifier__c);
            className = 'acuraVINCheckBox'; // enable vin checkBox
        } else {
            sessionStorage.setItem('HondaVin', '');
            sessionStorage.setItem('AcuraVin', '');
        }
        if (className) {
            this.template.querySelectorAll(className).forEach((element) => element.disabled = false);
        }
        //END
        if (this.divisionValue == 1) {
            sessionStorage.setItem('hondaMyProductId', recordId);
        } else if (this.divisionValue == 2) {
            sessionStorage.setItem('acuraMyProductId', recordId);
        }
        //const params = { yearValue: year, modelValue: modal, trimValue: trim };
        //START
        //await  getVehicleDetailsWithModalAndTrims(params).then(vecResult => {
        await getVehicleDetailsForAccessories({ modelId: productModelId }).then(vecResult => {
            if (vecResult) {
                let vehicleMapResult = JSON.parse(vecResult);
                let vehicleResult = JSON.parse(vehicleMapResult.vehicle);
                //for years  
                let yearCmpName = '.Year' + index;
                let yearCmp = this.template.querySelector(yearCmpName);
                if (this.divisionValue == 1) {
                    yearCmp.options = this.yearOptionsHonda;  //yearOptions;
                } else {
                    yearCmp.options = this.yearOptionsAcura;
                }
                yearCmp.value = vehicleResult.iNYearID__c.toString();
                yearCmp.disabled = false;
                this.yearValue = vehicleResult.Year__c;
                this.yearId = vehicleResult.iNYearID__c;
                this.setYearCookies();

                // for models
                let modelCmpName = '.Model' + index;
                let modelCmp = this.template.querySelector(modelCmpName);
                let modelOptionAll = [];
                let parseDataModel = JSON.parse(vehicleMapResult.vehicleModels);
                for (const [key, value] of Object.entries(parseDataModel)) {
                    modelOptionAll.push({
                        label: key,
                        value: value
                    })
                }
                let modelOptions = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);
                modelCmp.options = modelOptions;
                let vehicleModelId = modelOptions.find(item => item.label == vehicleResult.Model__c).value;
                modelCmp.value = vehicleModelId.toString();
                modelCmp.disabled = false;
                this.modelValue = vehicleResult.Model__c;
                this.modelId = vehicleModelId.toString();
                if (this.divisionValue == 1) {
                    this.modelOptionHonda = modelOptions;
                    sessionStorage.setItem('ModelOptionHonda', JSON.stringify(modelOptions));
                } else if (this.divisionValue == 2) {
                    this.modelOptionAcura = modelOptions;
                    sessionStorage.setItem('ModelOptionAcura', JSON.stringify(modelOptions));
                }
                this.setModelCookies();

                //for trims
                let trimCmpName = '.Trim' + index;
                let trimCmp = this.template.querySelector(trimCmpName);
                let parseDataTrim = JSON.parse(vehicleMapResult.vehicleTrims);
                let allTrimOptions = [];
                for (const [key, value] of Object.entries(parseDataTrim)) {
                    allTrimOptions.push({
                        label: key,
                        value: value
                    })
                }
                let trimOptions = allTrimOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                trimCmp.options = trimOptions;
                //Added by Shalini soani 29 Sept 
                trimCmp.value = vehicleResult.Model_Id__c.toString();
                //trimCmp.value = vehicleResult.iNGradeID__c.toString();
                trimCmp.disabled = false;
                this.trimValue = vehicleResult.Trim__c;
                //Added by Shalini soni 29 Sept 
                this.TrimId = vehicleResult.Model_Id__c;
                // this.TrimId = vehicleResult.iNGradeID__c;    
                if (this.divisionValue == 1) {
                    this.trimOptionHonda = trimOptions;
                    sessionStorage.setItem('TrimOptionHonda', JSON.stringify(trimOptions));
                } else if (this.divisionValue == 2) {
                    this.trimOptionAcura = trimOptions;
                    sessionStorage.setItem('TrimOptionAcura', JSON.stringify(trimOptions));
                }
                this.setTrimCookies();
            }
        }).catch(error => {
            console.error('Error : ', error);
        }).finally(() => {

        });

        // Here we are sending data to Modal Box so user can edit this informations 
        let brandName = this.divisionValue == 1 ? 'Honda' : 'Acura';
        let vehicleRecord = {
            'Name': myProductRecord.Nickname__c,
            'productType': brandName,
            'yearValue': this.yearValue,
            'modalValue': this.modelValue,
            'trimValue': this.trimValue,
            'vinValue': myProductRecord.Honda_Product__r.Product_Identifier__c,
            'recordId': myProductRecord.Id,
        }
        this.vehicleData = JSON.stringify(vehicleRecord);
        //END
    }

    handleMakeChange(event) {
        this.makeValue = event.detail.value;
        this.yearDisabled = false;
    }
    handleYearChange(event) {
        sessionStorage.setItem('mainHeaderSearched', false);
        //Remove hdie class which is added in handleVinChange HDMP-3638
        if (this.template.querySelector('.hondaDes')) {
            this.template.querySelector('.hondaDes').classList.remove('slds-hide');
        }
        if (this.template.querySelector('.auraDes')) {
            this.template.querySelector('.auraDes').classList.remove('slds-hide');
        }
        if (this.template.querySelector('.hondaMob')) {
            this.template.querySelector('.hondaMob').classList.remove('slds-hide');
        }
        if (this.template.querySelector('.auraMob')) {
            this.template.querySelector('.auraMob').classList.remove('slds-hide');
        }


        let index = event.currentTarget.dataset.index;
        let name = '.' + event.currentTarget.name;
        let yearCmp = this.template.querySelector(name);
        this.yearId = yearCmp.value;
        let yearObj = yearCmp.options.find(item => item.value == this.yearId);
        yearCmp.setCustomValidity('');
        yearCmp.reportValidity();
        this.yearValue = yearObj.label;
        this.createCookie('YearId', this.yearId, 1);
        this.createCookie('Year', this.yearValue, 1);

        //Added by Deepak Mali 19 Aug 2021
        let VinCmpName = '.Vin' + index;
        let vinCmp = this.template.querySelector(VinCmpName);
        vinCmp.value = '';
        vinCmp.setCustomValidity('');
        vinCmp.reportValidity();
        this.vinValue = '';

        //Added by Deepak Mali 25 2022
        let productCmpName = '.Products' + index;
        this.template.querySelector(productCmpName) ? this.template.querySelector(productCmpName).value = '' : null;

        if (this.divisionValue == 1) {
            sessionStorage.setItem('hondaMyProductId', '');
        } else if (this.divisionValue == 2) {
            sessionStorage.setItem('acuraMyProductId', '');
        }
        //End

        this.setYearCookies();
        if (this.divisionValue == 1) {
            this.hondaVehicleData = '';
            sessionStorage.setItem('HondaVin', '');
            sessionStorage.setItem('HondaModelId', '');
            sessionStorage.setItem('HondaModelValue', '');
        } else if (this.divisionValue == 2) {
            this.acuraVehicleData = '';
            sessionStorage.setItem('AcuraVin', '');
            sessionStorage.setItem('AcuraModelId', '');
            sessionStorage.setItem('AcuraModelValue', '');
        }

        if (this.divisionValue == 1) {
            sessionStorage.setItem('HondaTrimId', '');
            sessionStorage.setItem('HondaTrimValue', '');
        } else if (this.divisionValue == 2) {
            sessionStorage.setItem('AcuraTrimId', '');
            sessionStorage.setItem('AcuraTrimValue', '');
        }


        let modelName = '.Model' + index;
        let modelCmp = this.template.querySelector(modelName);
        modelCmp.value = '';
        modelCmp.disabled = true;
        modelCmp.options = [];
        modelCmp.setCustomValidity("");
        modelCmp.reportValidity();
        modelCmp.disabled = false;

        let trimName = '.Trim' + index;
        let trimCmp = this.template.querySelector(trimName);
        trimCmp.value = '';
        trimCmp.disabled = true;
        trimCmp.options = [];
        trimCmp.setCustomValidity("");
        trimCmp.reportValidity();

        getVehicleModel({ division: this.divisionValue, year: this.yearId }).then(result => {
            if (result) {
                let parseDataModel = JSON.parse(result)
                let modelOptionAll = [];
                for (const [key, value] of Object.entries(parseDataModel)) {
                    modelOptionAll.push({
                        label: key,
                        value: value
                    })
                }
                let modelOption = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);

                if (this.divisionValue == 1) {
                    this.modelOptionHonda = modelOption;
                    //this.createCookie('ModelOptionHonda', JSON.stringify(this.modelOptionHonda) , 1);
                    sessionStorage.setItem('ModelOptionHonda', JSON.stringify(modelOption));

                } else if (this.divisionValue == 2) {
                    this.modelOptionAcura = modelOption;
                    sessionStorage.setItem('ModelOptionAcura', JSON.stringify(modelOption));
                }
                this.error = undefined;
            }
        }).catch(error => {
            //console.log('#error', error);
        })
    }
    handleModelChange(event) {
        sessionStorage.setItem('mainHeaderSearched', false);
        let index = event.currentTarget.dataset.index;
        let name = '.' + event.currentTarget.name;
        let modelCmp = this.template.querySelector(name);
        this.modelId = modelCmp.value;
        let modelObj = modelCmp.options.find(item => item.value == this.modelId);
        this.modelValue = modelObj.label;
        modelCmp.setCustomValidity('');
        modelCmp.reportValidity();
        let trimName = '.Trim' + index;
        let trimCmp = this.template.querySelector(trimName);
        trimCmp.value = '';
        trimCmp.options = [];
        trimCmp.disabled = true;
        trimCmp.setCustomValidity("");
        trimCmp.reportValidity();
        trimCmp.disabled = false;

        //clear Vin
        let VinCmpName = '.Vin' + index;
        let vinCmp = this.template.querySelector(VinCmpName);
        vinCmp.value = '';
        vinCmp.setCustomValidity('');
        vinCmp.reportValidity();
        this.vinValue = '';

        //Added by Deepak Mali 25 2022
        let productCmpName = '.Products' + index;
        this.template.querySelector(productCmpName) ? this.template.querySelector(productCmpName).value = '' : null;

        if (this.divisionValue == 1) {
            sessionStorage.setItem('hondaMyProductId', '');
        } else if (this.divisionValue == 2) {
            sessionStorage.setItem('acuraMyProductId', '');
        }
        //End


        this.createCookie('ModelId', this.modelId, 1);
        this.createCookie('Model', this.modelValue, 1);

        this.setModelCookies();

        if (this.divisionValue == 1) {
            this.yearId = sessionStorage.getItem('HondaYearId');
            this.hondaVehicleData = '';
            sessionStorage.setItem('HondaVin', '');
            sessionStorage.setItem('HondaTrimId', '');
            sessionStorage.setItem('HondaTrimValue', '');
        } else if (this.divisionValue == 2) {
            this.yearId = sessionStorage.getItem('AcuraYearId');
            this.acuraVehicleData = '';
            sessionStorage.setItem('AcuraVin', '');
            sessionStorage.setItem('AcuraTrimId', '');
            sessionStorage.setItem('AcuraTrimValue', '');
        }

        //motocompacto starts
        let hondaCheckBoxes = this.template.querySelectorAll('.hondaCheckBox') ? this.template.querySelectorAll('.hondaCheckBox') : [];
        let acuraCheckBoxes = this.template.querySelectorAll('.acuraCheckBox') ? this.template.querySelectorAll('.acuraCheckBox') : [];
   
        if (this.modelValue == 'Motocompacto') {
            this.isMotoCompacto = true;
            sessionStorage.setItem('isMotoCompacto', 'true');
            hondaCheckBoxes.forEach(element => { element.disabled = true; });
            acuraCheckBoxes.forEach(element => { element.disabled = true; });
        }else {
            this.isMotoCompacto = false;
            sessionStorage.removeItem('isMotoCompacto');
            hondaCheckBoxes.forEach(element => { element.disabled = false; });
            acuraCheckBoxes.forEach(element => { element.disabled = false; });
        }
        //motocompacto ends

        getVehicleTrim({ division: this.divisionValue, year: this.yearId, modelValue: this.modelValue.toString() }).then(result => {
            if (result) {
                let parseDataTrim = JSON.parse(result)

                let allTrimOptions = [];
                for (const [key, value] of Object.entries(parseDataTrim)) {
                    allTrimOptions.push({
                        label: key,
                        value: value
                    })
                }
                let trimOption = allTrimOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                if (this.divisionValue == 1) {
                    this.trimOptionHonda = trimOption;
                    //this.createCookie('TrimOptionHonda', JSON.stringify(this.trimOptionHonda) ,1);
                    sessionStorage.setItem('TrimOptionHonda', JSON.stringify(trimOption));
                } else if (this.divisionValue == 2) {
                    this.trimOptionAcura = trimOption;
                    sessionStorage.setItem('TrimOptionAcura', JSON.stringify(trimOption));
                    // this.createCookie('TrimOptionAcura', JSON.stringify(this.trimOptionAcura) ,1);
                }

                this.error = undefined;
            }
        }).catch(error => {
            //console.log('#error', error);
        })

    }
    handleTrimChange(event) {
        sessionStorage.setItem('mainHeaderSearched', false);
        let index = event.currentTarget.dataset.index;
        let name = '.' + event.currentTarget.name;
        let trimCmp = this.template.querySelector(name);
        this.TrimId = trimCmp.value;
        let trimObj = trimCmp.options.find(item => item.value == this.TrimId);
        trimCmp.setCustomValidity('');
        trimCmp.reportValidity();

        //clear Vin
        let VinCmpName = '.Vin' + index;
        let vinCmp = this.template.querySelector(VinCmpName);
        vinCmp.value = '';
        vinCmp.setCustomValidity('');
        vinCmp.reportValidity();
        this.vinValue = '';

        //Added by Deepak Mali 25 2022
        let productCmpName = '.Products' + index;
        this.template.querySelector(productCmpName) ? this.template.querySelector(productCmpName).value = '' : null;

        if (this.divisionValue == 1) {
            sessionStorage.setItem('hondaMyProductId', '');
        } else if (this.divisionValue == 2) {
            sessionStorage.setItem('acuraMyProductId', '');
        }
        //End

        if (this.divisionValue == 1) {
            this.hondaVehicleData = '';
            sessionStorage.setItem('HondaVin', '');
        } else if (this.divisionValue == 2) {
            this.acuraVehicleData = '';
            sessionStorage.setItem('AcuraVin', '');
        }

        this.trimValue = trimObj.label;
        this.createCookie('TrimId', this.TrimId, 1);
        this.createCookie('Trim', this.trimValue, 1);

        this.setTrimCookies();
    }

    clearVinData(index) {
        this.makeDisabled = false;
        this.yearDisabled = false;
        this.modelDisabled = false;
        this.trimDisabled = false;
        let yearCmpName = '.Year' + index,
            modeCmpName = '.Model' + index,
            trimCmpName = '.Trim' + index;
        this.template.querySelector(yearCmpName).value = '';
        this.template.querySelector(modeCmpName).value = '';
        this.template.querySelector(trimCmpName).value = '';
        this.template.querySelector(yearCmpName).disabled = false;
        this.template.querySelector(modeCmpName).disabled = true;
        this.template.querySelector(trimCmpName).disabled = true;


        if (this.divisionValue == 1) {
            this.template.querySelector(yearCmpName).options = this.yearOptionsHonda;
            sessionStorage.setItem('HondaYearId', '');
            sessionStorage.setItem('HondaYearValue', '');
            sessionStorage.setItem('HondaVin', '');
            this.hondaVehicleData = null;
        } else if (this.divisionValue == 2) {
            this.template.querySelector(yearCmpName).options = this.yearOptionsAcura;
            sessionStorage.setItem('AcuraYearId', '');
            sessionStorage.setItem('AcuraYearValue', '');
            sessionStorage.setItem('AcuraVin', '');
            this.acuraVehicleData = null;
        }
        this.yearValue = 0;
        this.modelValue = 0;
        this.trimValue = 0;
    }

    handleVinChange(event) {
        sessionStorage.setItem('mainHeaderSearched', false);
        this.isLoaded = true;
        let vinCmpName = '.' + event.currentTarget.name;
        let index = event.currentTarget.dataset.index;
        this.currentIndexForVin = index;
        let searchButton = '.' + event.currentTarget.dataset.button;
        this.vinValue = event.detail.value;
        let vinCmp = this.template.querySelector(vinCmpName);
        //Add hdie class which is added in handleVinChange HDMP-3638
        // this.template.querySelector(searchButton).classList.add('slds-hide');
        //Added by Deepak Mali 3 March 2022
        let productCmpName = '.Products' + index;
        this.template.querySelector(productCmpName) ? this.template.querySelector(productCmpName).value = '' : null;
        //END
        if (this.vinValue.length == 0 || this.vinValue == '') {

            this.clearVinData(index);
            vinCmp.setCustomValidity("");
            //Remove hdie class which is added in handleVinChange HDMP-3638
            // this.template.querySelector(searchButton).classList.remove('slds-hide');
            this.isLoaded = false;
            // Added by deepak 
            let className = this.makeValue == 'Honda' ? '.hondaVINCheckBox' : '.acuraVINCheckBox';
            this.template.querySelectorAll(className).forEach((element) => {
                element.disabled = true;
                element.checked = false;
            });
            //End
        }
        if (this.vinValue.length > 0 && this.vinValue.length < 17) {
            this.isLoaded = false;
        }
        let format = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;
        if (this.vinValue.length > 0 && format.test(this.vinValue) == true) {
            vinCmp.setCustomValidity("Please enter valid VIN");
            let className = this.makeValue == 'Honda' ? '.hondaVINCheckBox' : '.acuraVINCheckBox';
            this.template.querySelectorAll(className).forEach((element) => {
                element.disabled = true;
                element.checked = false;
            });

        } else {
            vinCmp.setCustomValidity("");
        }

        if (this.vinValue.length == 17 || this.vinValue.length == 10) {
            if (this.divisionValue == 1) {
                let HondaVin = sessionStorage.getItem('HondaVin');
                if (HondaVin != this.vinValue) {
                    this.clearVinData(index);
                }
            } else if (this.divisionValue == 2) {
                let AcuraVin = sessionStorage.getItem('AcuraVin');
                if (AcuraVin != this.vinValue) {
                    this.clearVinData(index);
                }
            }
            this.isLoaded = true;
            if (this.divisionValue && this.divisionValue == 2 && this.template.querySelector('.acurabutton'))
                this.template.querySelector('.acurabutton').disabled = true;
            else if (this.divisionValue && this.divisionValue == 1 && this.template.querySelector('.hondabutton'))
                this.template.querySelector('.hondabutton').disabled = true;

            // if(this.divisionValue == 1){
            //     if (this.productType == 'Parts' && !this.hondaVehicleData){
            //         this.getModelByINVIN(vinCmp, index, searchButton);
            //     }else if(this.productType == 'Accessories' && !this.hondaVehicleData) {
            //         this.getModelByEconfigVIN(vinCmp, index, searchButton);
            //     }
            // }else {
            //     if (this.productType == 'Parts' && !this.acuraVehicleData){
            //         this.getModelByINVIN(vinCmp, index, searchButton);
            //     }else if(this.productType == 'Accessories' && !this.acuraVehicleData) {
            //         this.getModelByEconfigVIN(vinCmp, index, searchButton);
            //     }
            // }                    
            // Added by deepak 
            let className = this.makeValue == 'Honda' ? '.hondaVINCheckBox' : '.acuraVINCheckBox';
            this.template.querySelectorAll(className).forEach((element) => element.disabled = false);
            //End
            this.getModelByEconfigVIN(vinCmp, index, searchButton);
        }

        if (this.vinValue.length > 17) {
            vinCmp.setCustomValidity("Please enter valid VIN ");
            // Added by deepak 
            let className = this.makeValue == 'Honda' ? '.hondaVINCheckBox' : '.acuraVINCheckBox';
            this.template.querySelectorAll(className).forEach((element) => element.disabled = true);
            //End
        }

        vinCmp.reportValidity();
    }
    getModelByEconfigVIN(vinCmp, index, searchButton) {
        callVinDecoderService({ vinNumber: this.vinValue, poiType: this.poihondavalue }).then(result => {
            let displayData = JSON.parse(result);
            if (displayData.isError || !displayData.selectorDetail.partsCatalog) {
                this.vinValue = '';
                if (displayData.message) {
                    this.vinErrorMessage = displayData.message;
                } else {
                    this.vinErrorMessage = '';
                }

                let errorMsg = '';
                if (displayData.message && displayData.message.toLowerCase().includes("unable to decode vin at this time")) {
                    errorMsg = 'We’re sorry, we are not able to determine your vehicle’s model information. Please use our model selector to search for products';
                    // if(this.vinValue.length == 17){
                    //     errorMsg = 'VIN can\'t be decoded at this time, please select the additional model info to refine their vehicle search.';
                    // }else if(this.vinValue.length == 10){
                    //     errorMsg = 'We’re sorry, we are not able to determine your vehicle’s model information. Please use our model selector to search for products';
                    // } 
                }
                else if (displayData.message && (displayData.message.toLowerCase().includes("invalid acura vin") || displayData.message.toLowerCase().includes("invalid honda vin") || displayData.message.toLowerCase().includes("model does not exist"))) {
                    errorMsg = this.divisionValue && this.divisionValue == 1 ? 'You\'ve entered an Acura VIN, please select the Acura menu to search for those items' : 'You\'ve entered a Honda VIN, please select the Honda menu to search for those items';
                }
                else if (displayData.message && (displayData.message.includes("Please fix VIN. If VIN valid, please contact support"))) {
                    errorMsg = 'We\'re sorry, we are not able to determine your vehicle\'s model. Please use the model selector to search for products';
                }
                else
                    errorMsg = 'Please enter valid VIN';

                //Added by deepak mali 
                if (errorMsg) {
                    let className = this.makeValue == 'Honda' ? '.hondaVINCheckBox' : '.acuraVINCheckBox';
                    this.template.querySelectorAll(className).forEach((element) => {
                        element.disabled = true;
                        element.checked = false;
                    });
                }
                //END
                vinCmp.setCustomValidity(errorMsg);
                vinCmp.reportValidity();

                this.enableSearchButton(); // enabling the search button

            } else {
                let modelId = displayData.selectorDetail.modelId;
                if (displayData.selectorDetail && displayData.selectorDetail.colors) {
                    let colorDate = JSON.parse(displayData.selectorDetail.colors);
                    this.mfgColorCode = colorDate && colorDate.color && colorDate.color[1]['@mfg_color_cd'] ? colorDate.color[1]['@mfg_color_cd'] : '';
                }
                getVehicleDetailsForAccessories({ modelId: modelId.toString() }).then(vecResult => {
                    if (vecResult) {
                        let vehicleMapResult = JSON.parse(vecResult);

                        let vehicleResult = JSON.parse(vehicleMapResult.vehicle);
                        vinCmp.setCustomValidity("");
                        if (this.divisionValue == 1)
                            this.hondaVehicleData = vehicleResult;
                        else
                            this.acuraVehicleData = vehicleResult;

                        //for years  
                        let yearCmpName = '.Year' + index;
                        let yearCmp = this.template.querySelector(yearCmpName);
                        if (this.divisionValue == 1) {
                            yearCmp.options = this.yearOptionsHonda;  //yearOptions;
                        } else {
                            yearCmp.options = this.yearOptionsAcura;
                        }

                        yearCmp.value = vehicleResult.iNYearID__c.toString();
                        yearCmp.disabled = false;

                        this.yearValue = vehicleResult.Year__c;
                        this.yearId = vehicleResult.iNYearID__c;
                        this.setYearCookies();

                        // for models
                        let modelCmpName = '.Model' + index;
                        let modelCmp = this.template.querySelector(modelCmpName);
                        let modelOptionAll = [];
                        let parseDataModel = JSON.parse(vehicleMapResult.vehicleModels);
                        for (const [key, value] of Object.entries(parseDataModel)) {
                            modelOptionAll.push({
                                label: key,
                                value: value
                            })
                        }
                        let modelOptions = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);
                        modelCmp.options = modelOptions;
                        let vehicleModelId = modelOptions.find(item => item.label == vehicleResult.Model__c).value;
                        modelCmp.value = vehicleModelId.toString();
                        modelCmp.disabled = false;
                        this.modelValue = vehicleResult.Model__c;
                        this.modelId = vehicleModelId.toString();
                        if (this.divisionValue == 1) {
                            this.modelOptionHonda = modelOptions;
                            sessionStorage.setItem('ModelOptionHonda', JSON.stringify(modelOptions));
                        } else if (this.divisionValue == 2) {
                            this.modelOptionAcura = modelOptions;
                            sessionStorage.setItem('ModelOptionAcura', JSON.stringify(modelOptions));
                        }
                        this.setModelCookies();

                        //for trims
                        let trimCmpName = '.Trim' + index;
                        let trimCmp = this.template.querySelector(trimCmpName);
                        let parseDataTrim = JSON.parse(vehicleMapResult.vehicleTrims);
                        let allTrimOptions = [];
                        for (const [key, value] of Object.entries(parseDataTrim)) {
                            allTrimOptions.push({
                                label: key,
                                value: value
                            })
                        }
                        let trimOptions = allTrimOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                        trimCmp.options = trimOptions;

                        //Added by Shalini soni 29 Sept 
                        trimCmp.value = vehicleResult.Model_Id__c.toString();
                        //trimCmp.value = vehicleResult.iNGradeID__c.toString();

                        trimCmp.disabled = false;
                        this.trimValue = vehicleResult.Trim__c;

                        //Added by Shalini soni 29 Sept 
                        this.TrimId = vehicleResult.Model_Id__c;
                        // this.TrimId = vehicleResult.iNGradeID__c;    
                        if (this.divisionValue == 1) {
                            this.trimOptionHonda = trimOptions;
                            sessionStorage.setItem('TrimOptionHonda', JSON.stringify(trimOptions));
                        } else if (this.divisionValue == 2) {
                            this.trimOptionAcura = trimOptions;
                            sessionStorage.setItem('TrimOptionAcura', JSON.stringify(trimOptions));
                        }
                        this.setTrimCookies();

                        this.enableSearchButton(); // enabling the search button

                        sessionStorage.setItem('partsCatalog', displayData.selectorDetail.partsCatalog);
                        //Remove hdie class which is added in handleVinChange HDMP-3638             
                        // this.template.querySelector(searchButton).classList.remove('slds-hide');

                    }
                    if (this.divisionValue == 1) {
                        sessionStorage.setItem('HondaVin', this.vinValue);
                    } else if (this.divisionValue == 2) {
                        sessionStorage.setItem('AcuraVin', this.vinValue);
                    }



                }).catch(error => {
                    //console.log('Error : ', error);
                    this.error = error;
                    this.isLoaded = false;
                    if (this.error.body.message.includes('List has no rows for assignment to SObject')) {
                        vinCmp.setCustomValidity("Please enter valid VIN ");
                        vinCmp.reportValidity();
                        this.enableSearchButton();
                    }
                })
            }
            this.isLoaded = false;
        }).catch(error => {
            //console.log('Error : ', error);
            this.error = error;
            this.isLoaded = false;
        })
    }

    setYearCookies() {
        if (this.divisionValue == 1) {
            sessionStorage.setItem('HondaYearId', this.yearId);
            sessionStorage.setItem('HondaYearValue', this.yearValue);
        } else if (this.divisionValue == 2) {
            sessionStorage.setItem('AcuraYearId', this.yearId);
            sessionStorage.setItem('AcuraYearValue', this.yearValue);
        }
    }

    setModelCookies() {
        if (this.divisionValue == 1) {
            sessionStorage.setItem('HondaModelId', this.modelId);
            sessionStorage.setItem('HondaModelValue', this.modelValue);
        } else if (this.divisionValue == 2) {
            sessionStorage.setItem('AcuraModelId', this.modelId);
            sessionStorage.setItem('AcuraModelValue', this.modelValue);
        }
    }

    setTrimCookies() {
        if (this.divisionValue == 1) {
            sessionStorage.setItem('HondaTrimId', this.TrimId);
            sessionStorage.setItem('HondaTrimValue', this.trimValue);
        } else if (this.divisionValue == 2) {
            sessionStorage.setItem('AcuraTrimId', this.TrimId);
            sessionStorage.setItem('AcuraTrimValue', this.trimValue);
        }
    }

    goToCategoyPage(category, baseUrl) {
        getCategoryId({
            categoryName: this.checkValue
        })
            .then((resu) => {
                this.categoryId = resu;
                var catId = this.categoryId;
                baseUrl = baseUrl + catId;
                getVehicleDetails({ yearValue: this.yearValue, modelValue: this.modelValue, trimValue: this.trimValue, division : this.divisionValue }).then(result => {
                    let vehicle = Object.assign({}, result);
                    this.createCookie('vehicle', JSON.stringify(vehicle), 1);
                    sessionStorage.setItem('vehicle', JSON.stringify(vehicle));
                    sessionStorage.setItem('isSubmited', true);
                    sessionStorage.setItem('mainHeaderSearched', true);
                    sessionStorage.setItem('division', this.divisionValue);
                    if (this.divisionValue == 1) {
                        let hondaVehicle = this.hondaVehicleData ? this.hondaVehicleData : '';
                        sessionStorage.setItem('hondaVehicleData', hondaVehicle);
                    } else if (this.divisionValue == 2) {
                        let acuraVehicle = this.acuraVehicleData ? this.acuraVehicleData : '';
                        sessionStorage.setItem('acuraVehicleData', acuraVehicle);
                    }
                    this.buildEffectiveVehicle(catId);
                    setTimeout(function () {
                        this.isLoaded = false; //Added by deepak mali 20 Aug 2021
                        //The VIN field should not be editable while the search is executing
                        let VinCmpName = '.Vin' + this.currentIndexForVin;
                        let vinCmp = this.template.querySelector(VinCmpName);
                        vinCmp.disabled = false;
                    }.bind(this), 3000);
                    
                    //Motocompacto starts
                    //if it's a motocompacto Unit redirect to pdp
                    if(this.productType == 'Accessories' && this.modelValue == 'Motocompacto'){ 
                        this.goToMotocompactoPDP(vehicle);                      
                    }else {
                        window.open(baseUrl, "_self");
                    } 
                    //Motocompacto ends       
                }).catch(error => {
                    //console.log('error : ', error);
                    this.isLoaded = false;  //Added by deepak mali 20 Aug 2021
                })
            })
            .catch((error) => {
                this.error = error;
                //console.log('error::::' + error);
            });
    }


    retrieveCategory() {
        var baseurl = window.location.href;
        var finalurl = baseurl.split('/');
        var checkvalue = finalurl[4];
        if (checkvalue == 'honda') {
            this.poihondavalue = 'A';
        } else {
            this.poihondavalue = 'B';
        }
    }


    createCookie(name, value, days) {
        var expires;
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 100));
            expires = ";expires=" + date.toGMTString();
        } else {
            expires = "";
        }
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
    }


    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }

    handleOnMouseOver(event) {
        try {
            let currentUrl = window.location.href;
            // Added by Bhawesh on 24-03-2022 for HDMP- 8359 start
            let brandAndType = JSON.parse(sessionStorage.getItem('brandAndProductTypeMap'));
            if (event.currentTarget.dataset.value == 'Honda' && brandAndType) {
                //this.defaultSelectHonda = brandAndType.Honda == 'Accessories' ? false : true;
                let emlnt = brandAndType.Honda ? '.' + brandAndType.Honda + '1' : '';
                let elmntMobile = brandAndType.Honda ? '.' + brandAndType.Honda.toLowerCase() + '3' : '';
                if (elmntMobile && elmntMobile.length) {
                    setTimeout(() => {
                        let parCmp = this.template.querySelector(elmntMobile);
                        parCmp.checked = true;
                        if (parCmp.value) {
                            this.productType = parCmp.value;
                        }
                    }, 100);
                }
                if (emlnt) {
                    let parCmpValue = this.template.querySelector(emlnt.toLocaleLowerCase());
                    if (parCmpValue) {
                        parCmpValue.checked = true;
                        if (parCmpValue.value) {
                            this.productType = parCmpValue.value;
                        }
                    }
                }
            } else if (event.currentTarget.dataset.value == 'Acura' && brandAndType) {
                this.defaultSelectAcura = brandAndType.Acura == 'Accessories' ? false : true;
                let emlnt = brandAndType.Acura ? '.' + brandAndType.Acura + '2' : '';
                let elmntMobile = brandAndType.Acura ? '.' + brandAndType.Acura.toLowerCase() + '4' : '';
                if (elmntMobile && elmntMobile.length) {
                    setTimeout(() => {
                        let parCmp = this.template.querySelector(elmntMobile);
                        parCmp.checked = true;
                        if (parCmp.value) {
                            this.productType = parCmp.value;
                        }
                    }, 100);
                }
                if (emlnt) {
                    let parCmpValue = this.template.querySelector(emlnt.toLocaleLowerCase());
                    if (parCmpValue) {
                        parCmpValue.checked = true;
                        if (parCmpValue.value) {
                            this.productType = parCmpValue.value;
                        }
                    }
                }
            }
            // End

            let brand = event.currentTarget.dataset.value;
            this.checkValue = brand;
            this.makeValue = brand;
            //Added by Deepak Mali for HDMP-8455 if we are on same brand menu we will not filter acura and honda vehicle
            if (this.mouseHover && ((brand == 'Honda' && this.divisionValue == 1) || (brand == 'Acura' && this.divisionValue == 2))) {
                return;
            }
            //Ends

            if (brand === 'Honda') {
                this.divisionValue = 1;
                //this.fillTemplateData(5);
                this.poihondavalue = 'A';
                this.myProductOptions = this.allProductListHonda.length ? this.allProductListHonda : null;
            } else {
                this.divisionValue = 2;
                //this.fillTemplateData(7);
                this.poihondavalue = 'B';
                this.myProductOptions = this.allProductListAcura.length ? this.allProductListAcura : null;
            }
            this.setMyProduct();
            this.mouseHover = true;
        } catch (error) {
            console.log('OUTPUT : ', error);
        }
        // End

        let brand = event.currentTarget.dataset.value;
        this.checkValue = brand;
        this.makeValue = brand;
        //Added by Deepak Mali for HDMP-8455 if we are on same brand menu we will not filter acura and honda vehicle
        if ((brand == 'Honda' && this.divisionValue == 1) || (brand == 'Acura' && this.divisionValue == 2)) {
            return;
        }
        //Ends

        if (brand === 'Honda') {
            this.divisionValue = 1;
            this.poihondavalue = 'A';
            this.myProductOptions = this.allProductListHonda.length ? this.allProductListHonda : null;
        } else {
            this.divisionValue = 2;
            this.poihondavalue = 'B';
            this.myProductOptions = this.allProductListAcura.length ? this.allProductListAcura : null;
        }
        this.setMyProduct();

        /* let allProductList = [];
        this.myProductList.forEach(element => {
            let brandName = this.divisionValue == 1 ? 'Honda' : 'Acura';
            if (brandName == element.Honda_Product__r.Product_Models__r.Product_Subdivision__c) {
                allProductList.push({
                    label: element.Nickname__c,
                    value: element.Id
                })
            }

        });
        this.myProductOptions = allProductList.length > 0 ? allProductList : null; */
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    checkVINValidation() {
        let status = true;
        let vinNumber = this.vinValue;
        if (vinNumber) {
            if (vinNumber.length == 10 || vinNumber.length == 17) {
                status = true;
            } else {
                this.showNotification('Error', 'Incorrect VIN. Please enter valid VIN ', 'error');
                status = false;
            }
        }
        return status;
    }

    onClickTab(event) {
        let brand = event.currentTarget.dataset.value;
        this.isClickOnBrand = true;
        this.createCookie('ClickBrand', this.isClickOnBrand, 1);
        this.createCookie('BrandName', brand, 1);
        //Added By Bhawesh 28-03-2022 start
        this.createCookie('Make', brand, 1);
        //End
        sessionStorage.setItem('brand', brand);
        sessionStorage.setItem('vehicleBrand', brand);
        sessionStorage.setItem('vehicleBrand2', brand); // used for backend breadcrumbs logic
        localStorage.setItem('cartBrand', brand);
        if (sessionStorage.getItem('dealer')) {
            this.buildEffectiveDealer();
        }
        pubsub.publish('tabOnClick', true);
        var delayInMilliseconds = 10;
        if (window.location.href.includes('cart')) {
            setTimeout(function () {
                window.location.reload();
            }, delayInMilliseconds);
            //this.populateValuesOfYearModelTrim(1);
        } else {
            setTimeout(function () {
                window.location.reload();
            }, delayInMilliseconds);
            this.buildCurrentVehicle();
        }
    }


    buildEffectiveDealer() {
        let brand = sessionStorage.getItem('brand');
        let dealer = JSON.parse(sessionStorage.getItem('dealer'));
        let brands = [];
        if (localStorage.getItem('effectiveDealer')) {
            brands = JSON.parse(localStorage.getItem('effectiveDealer'))['brands'];
            let hasExist = false;
            if (brands) {
                brands.forEach(element => {
                    if (brand === element.brand) {
                        element.id = dealer.id;
                        element.label = dealer.label;
                        element.dealerNo = dealer.dealerNo;
                        hasExist = true;
                    }
                });
                if (!hasExist) {
                    brands.push({ 'brand': brand, 'id': dealer.id, 'label': dealer.label, 'dealerNo': dealer.dealerNo });
                }
            } else {
                brands = [];
                brands.push({ 'brand': brand, 'id': dealer.id, 'label': dealer.label, 'dealerNo': dealer.dealerNo });
            }
        } else {
            brands = [];
            brands.push({ 'brand': brand, 'id': dealer.id, 'label': dealer.label, 'dealerNo': dealer.dealerNo });
        }
        localStorage.setItem('effectiveDealer', JSON.stringify({ 'brands': brands }));
    }

    buildEffectiveVehicle(categoryId) {
        let make = this.getCookie('Make');
        let year = this.getCookie('Year');
        let model = this.getCookie('Model');
        let trim = this.getCookie('Trim');
        let vin = this.getCookie('Vin');
        if(model == 'Motocompacto'){
            make = '';
        }
        //let productType = this.getCookie('ProductType');
        let productType = sessionStorage.getItem('ProductType');
        let brand = sessionStorage.getItem('brand');
        let brands = [];
        let vehicle = JSON.parse(this.getCookie('vehicle'));
        if (vehicle) {
            if (localStorage.getItem("effectiveVehicle")) {
                brands = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
                let hasExist = false;
                if (brands) {
                    brands.forEach(element => {
                        if (brand === element.brand) {
                            element.make = make;
                            element.year = year;
                            element.model = model;
                            element.trim = trim;
                            element.vin = vin;
                            element.productType = productType;
                            if (categoryId) {
                                element.categoryId = categoryId;
                            }
                            element.Id = vehicle.Id;
                            element.Model_Id__c = vehicle.Model_Id__c;
                            element.iNCatalogID__c = vehicle.iNCatalogID__c;
                            element.iNDivisionID__c = vehicle.iNDivisionID__c;
                            element.iNDoorID__c = vehicle.iNDoorID__c;
                            element.iNGradeID__c = vehicle.iNGradeID__c;
                            element.iNModelID__c = vehicle.iNModelID__c;
                            element.iNYearID__c = vehicle.iNYearID__c;
                            element.iNTransmissionID__c = vehicle.iNTransmissionID__c;
                            hasExist = true;
                        }
                    });
                }
                if (!hasExist) {
                    brands.push({ 'brand': brand, 'make': make, 'year': year, 'model': model, 'trim': trim, 'productType': productType, 'vin': vin, 'categoryId': categoryId, 'Id': vehicle.Id, 'Model_Id__c': vehicle.Model_Id__c, 'iNCatalogID__c': vehicle.iNCatalogID__c, 'iNDivisionID__c': vehicle.iNDivisionID__c, 'iNDoorID__c': vehicle.iNDoorID__c, 'iNGradeID__c': vehicle.iNGradeID__c, 'iNModelID__c': vehicle.iNModelID__c, 'iNYearID__c': vehicle.iNYearID__c, 'iNTransmissionID__c': vehicle.iNTransmissionID__c });
                }
            } else {
                brands.push({ 'brand': brand, 'make': make, 'year': year, 'model': model, 'trim': trim, 'productType': productType, 'vin': vin, 'categoryId': categoryId, 'Id': vehicle.Id, 'Model_Id__c': vehicle.Model_Id__c, 'iNCatalogID__c': vehicle.iNCatalogID__c, 'iNDivisionID__c': vehicle.iNDivisionID__c, 'iNDoorID__c': vehicle.iNDoorID__c, 'iNGradeID__c': vehicle.iNGradeID__c, 'iNModelID__c': vehicle.iNModelID__c, 'iNYearID__c': vehicle.iNYearID__c, 'iNTransmissionID__c': vehicle.iNTransmissionID__c });
            }
        }
        localStorage.setItem("effectiveVehicle", JSON.stringify({ 'brands': brands }));
    }

    buildBrandURL() {

        let brands = [];
        if (localStorage.getItem("effectiveVehicle")) {
            brands = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
            if (brands) {
                brands.forEach(element => {
                    if (element.brand === 'Honda') {
                        this.brandHondaURL = '/s/category/' + element.categoryId;

                    }
                    if (element.brand === 'Acura') {
                        this.brandAcuraURL = '/s/category/' + element.categoryId;
                    }
                });
            }
        }

    }

    buildCurrentVehicle() {
        let brand = sessionStorage.getItem('brand');
        let brands = [];
        if (localStorage.getItem("effectiveVehicle")) {
            brands = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
            if (brands) {
                brands.forEach(element => {
                    if (brand === element.brand) {
                        this.createCookie('vehicle', JSON.stringify({
                            'Id': element.Id,
                            'Model_Id__c': element.Model_Id__c,
                            'iNCatalogID__c': element.iNCatalogID__c,
                            'iNDivisionID__c': element.iNDivisionID__c,
                            'iNDoorID__c': element.iNDoorID__c,
                            'iNGradeID__c': element.iNGradeID__c,
                            'iNModelID__c': element.iNModelID__c,
                            'iNYearID__c': element.iNYearID__c
                        }));
                    }
                });
            }
        }
    }

    enableSearchButton() {
        if (this.divisionValue && this.divisionValue == 2 && this.template.querySelector('.acurabutton'))
            this.template.querySelector('.acurabutton').disabled = false;
        else if (this.divisionValue && this.divisionValue == 1 && this.template.querySelector('.hondabutton'))
            this.template.querySelector('.hondabutton').disabled = false;
    }
    //Added by Deepak Mali Task:HDMP-3690 "Enter" key should have the same functionality as clicking the main CTA
    handleKeyPress(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        let isMobile = event.currentTarget.dataset.mobile;
        let submitValue = event.currentTarget.dataset.value;

        if (charCode == 13 && ((this.trimValue && this.trimValue.length > 0) || this.vinValue > 1)) {

            //alert('Wait...');
            this.isLoaded = true;
            let eventValue = { currentTarget: { dataset: { mobile: {}, value: {} } } };
            eventValue.currentTarget.dataset.mobile = isMobile;
            eventValue.currentTarget.dataset.value = submitValue;
            this.enterKeyPressed = true; //Added by Deepak Mali 20 Aug 2021

            //The VIN field should not be editable while the search is executing
            let VinCmpName = '.Vin' + this.currentIndexForVin;
            let vinCmp = this.template.querySelector(VinCmpName);
            vinCmp.disabled = true;

            this.submitDetails(eventValue);

        }
    }
    handleKeyPressCombobox(event) { }

    //Added by Soumya for Cart Management- Login
    redirectToLoginPage() {
        getCurrentCart()
            .then((result) => {
                let pathURL;
                let finalURL;
                if (result !== null && result !== '') {
                    pathURL = '/s/splash?cartId=' + result + '&returnUrl=' + window.location.pathname;
                }
                else {
                    pathURL = '/s/splash?returnUrl=' + window.location.pathname;
                }
                let relayState = localStorage.getItem('relayStateUrl');
                if (relayState && window.location.href.includes('/s/category/')) {
                    localStorage.setItem('fromlogin', 'true');
                    relayState = relayState.substring(relayState.indexOf('/s/'));
                    localStorage.removeItem('relayStateUrl');
                    pathURL = '/s/splash?returnUrl=' + relayState;
                    finalURL = getLoginUrl + '&RelayState=' + pathURL;
                } else {
                    finalURL = getLoginUrl + '&RelayState=' + encodeURIComponent(pathURL);
                }
                //for adobe analytic: starts
                sessionStorage.setItem('eventsForAdobe', 'login success');
                let events = 'login initiation';
                let eventMetadata = {
                    action_type: 'link',
                    action_label: 'login',
                    action_category: 'login'//for adobe bug-17
                };
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events } };
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                //adobe: ends
                window.open(finalURL, '_self');
            })
            .catch((error) => {
                console.error('Error:', error);
            });

    } // Ends Here
    // Added by Soumya for Cart Management- Register
    redirectToRegisterPage() {


        getCurrentCart()
            .then((result) => {
                let pathURL;
                if (result !== null && result !== '') {
                    pathURL = '/s/splash?cartId=' + result + '&returnUrl=' + window.location.pathname;
                }
                else {
                    pathURL = '/s/splash?returnUrl=' + window.location.pathname;
                }
                const finalURL = getRegisterUrl + '&RelayState=' + encodeURIComponent(pathURL);
                //for adobe analytic: starts
                sessionStorage.setItem('eventsForAdobe', 'registration success');
                let events = 'register initiation';
                let eventMetadata = {
                    action_type: 'link',
                    action_label: 'register',
                    action_category: 'register'//for adobe bug-17
                };
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events } };
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                //adobe: ends
                window.open(finalURL, '_self');
            })
            .catch((error) => {
                console.error('Error:', error);
            });

    }// Ends here

    /*Below Lines of code commented by Soumya for Cart Management changes 
    redirectToLoginPage() {
        const finalURL = getLoginUrl + '&RelayState=' + window.location.pathname;
        window.open(finalURL, '_self');
    
        
    }
    redirectToRegisterPage() {
        
        const finalURL = getRegisterUrl + '&RelayState=' + window.location.pathname;
        window.open(finalURL, '_self');
        
        
    }
*/
    handleClearAll(event) {
        let brandName = event.currentTarget.dataset.value;
        try {
            let hondaIndex = [1, 2, 5, 6];
            let acuraIndex = [3, 4, 7, 8];
            let clearIndex = [];

            if (brandName == 'Honda') {
                clearIndex = hondaIndex;
                this.template.querySelectorAll('.hondaCheckBox').forEach(element => element.checked = false);
                this.template.querySelectorAll('.hondaVINCheckBox').forEach(element => element.checked = false);
            } else if (brandName == 'Acura') {
                clearIndex = acuraIndex;
                this.template.querySelectorAll('.acuraCheckBox').forEach(element => element.checked = false);

                this.template.querySelectorAll('.acuraVINCheckBox').forEach(element => element.checked = false);
            }

            clearIndex.forEach(index => {

                this.createCookie('Make', '', 1); // Clear cookie first
                this.createCookie('Year', '', 1); // Clear cookie first
                this.createCookie('Model', '', 1); // Clear cookie first
                this.createCookie('Trim', '', 1); // Clear cookie first


                this.makeDisabled = false;
                this.yearDisabled = false;
                this.modelDisabled = false;
                this.trimDisabled = false;
                let productCmpName = '.Products' + index,
                    yearCmpName = '.Year' + index,
                    modeCmpName = '.Model' + index,
                    trimCmpName = '.Trim' + index,
                    vinCmpName = '.Vin' + index;


                this.template.querySelector(productCmpName) ? this.template.querySelector(productCmpName).value = '' : null;
                this.template.querySelector(yearCmpName) ? this.template.querySelector(yearCmpName).value = '' : null;
                this.template.querySelector(modeCmpName) ? this.template.querySelector(modeCmpName).value = '' : null;
                this.template.querySelector(trimCmpName) ? this.template.querySelector(trimCmpName).value = '' : null;
                this.template.querySelector(vinCmpName) ? this.template.querySelector(vinCmpName).value = '' : null;

                this.template.querySelector(yearCmpName) ? this.template.querySelector(yearCmpName).disabled = false : null;
                this.template.querySelector(modeCmpName) ? this.template.querySelector(modeCmpName).disabled = true : null;
                this.template.querySelector(trimCmpName) ? this.template.querySelector(trimCmpName).disabled = true : null;


                if (this.divisionValue == 1) {
                    sessionStorage.setItem('HondaYearId', '');
                    sessionStorage.setItem('HondaYearValue', '');
                    sessionStorage.setItem('HondaVin', '');
                    this.hondaVehicleData = null;
                } else if (this.divisionValue == 2) {
                    sessionStorage.setItem('AcuraYearId', '');
                    sessionStorage.setItem('AcuraYearValue', '');
                    sessionStorage.setItem('AcuraVin', '');
                    this.acuraVehicleData = null;
                }
                this.yearValue = 0;
                this.modelValue = 0;
                this.trimValue = 0;
                sessionStorage.setItem('hondaMyProductId', '');
                sessionStorage.setItem('acuraMyProductId', '');
            })
            sessionStorage.setItem('selecteMyProductId', '');
        } catch (error) {
            console.error(error.message);
        }
    }

    // Added by deepak 
    saveToMyProductList() {
        try {
            let hondaCheckBoxes = ['.hondaCheckBox', '.hondaVINCheckBox'];
            let acuraCheckBoxes = ['.acuraCheckBox', '.acuraVINCheckBox'];
            let classNames = this.makeValue == 'Honda' ? hondaCheckBoxes : acuraCheckBoxes;

            let checked = false;
            classNames.forEach(className => {
                this.template.querySelectorAll(className).forEach((element) => {
                    if (element.checked && checked == false) {
                        checked = true;
                    }
                });
            });

            if (checked && checked == true) {
                /* let inputParams = {
                    //Product_Type__c: this.makeValue,
                    //Year__c: this.yearValue,
                    //Modal__c: this.modelValue,
                    //Trim__c: this.trimValue,
                    Vin: this.vinValue,
                };*/
                let name = this.yearValue + ' ' + this.modelValue;
                let subVinValue = '';
                if (this.vinValue && this.vinValue.length) {
                    subVinValue = this.vinValue.substring(this.vinValue.length - 6);
                    name += ' ' + this.trimValue + ' ' + subVinValue;
                } else {
                    name += ' ' + this.trimValue;
                }
                //let name = this.yearValue +' '+ this.modelValue +' '+ this.trimValue + ' ' +  subVinValue;
                saveToMyProduct({ vin: this.vinValue, trimModelId: this.TrimId, nickname: name, mnfgColorCode: this.mfgColorCode })
                    .then((result) => {
                        if (result == 'Success') {
                            this.showNotification(result, 'Saved to My Product Successfully', 'success');
                        } else if (result == 'Already Exists') {
                            let msg = this.vinValue.length ? 'A product with this VIN already exists in My Products.' : 'A product with this model already exists in My Products.';
                            this.showNotification(result, msg, 'info');
                        } else {
                            this.showNotification('Record not Saved!', 'We\'re experiencing technical difficulties, please try again later.', 'error');
                            console.error(result);
                        }
                    })
                    .catch((error) => {
                        console.error(error.message);
                    });
            }
        } catch (error) {
            console.error('Error : ', error.message);
        }
    }

    //Added by Deepak
    handleMenuItem(event) {
        const boxes = this.template.querySelectorAll('.subMenu');
        boxes.forEach(box => {
            if (box.checked) {
                box.checked = event.target.name === box.name
            }
        });
    }
    //End

    //Added by Faraz for Shopping Selection functionality
    handleSaveLastShoppingSelection() {
        if (!this.isGuest) {
            //Account__c: USER_ID,
            let inputParams = {
                Last_Product_ModelId__c: this.TrimId,
                Product_Subdivision__c: this.makeValue,
                Product_Identifier__c: this.vinValue,
            };

            saveLastShoppingSelection({ dataAsObj: JSON.stringify(inputParams) })
                .then(result => {
                    if (result && result == 'success') {
                        console.log('Result', result);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                });
        }
    }
    renderedCallback() {
        if (window.location.href.includes('category/honda')) {
            this.hondaIndicator = true;
            this.acuraIndicator = false;
        } else if (window.location.href.includes('category/acura')) {
            this.hondaIndicator = false;
            this.acuraIndicator = true;
        }
        console.log('$MH-I: hondaIndicator: ', this.hondaIndicator);
        console.log('$MH-I: acuraIndicator: ', this.acuraIndicator);

        let hondaImg = this.template.querySelector('.honda-logo-img');
        let acuraImg = this.template.querySelector('.acura-logo-img');
        if (this.hondaIndicator || window.location.href.includes('/honda')) {
            if (hondaImg)
                hondaImg.classList.add('hondaSelected');
            if (acuraImg)
                acuraImg.classList.remove('acuraSelected');
        } else if (this.acuraIndicator || window.location.href.includes('/acura')) {
            if (acuraImg)
                acuraImg.classList.add('acuraSelected');
            if (hondaImg)
                hondaImg.classList.remove('hondaSelected');
        }
    }
    //End

    //Added by Deepak
    // if we clicked on menu bar that time we are not hiding back scroll bar here
    // handleMenuBtn(event) {
    //     if (event.target.checked) {
    //         document.body.style.overflow = 'hidden';
    //     } else {
    //         document.body.style.overflow = '';
    //     }
    // }
    // if screen size is less than 770 we are not showing scroll bar here
    // handleOnScreenReSize() {
    //     if (window.innerWidth >= 770) {
    //         document.body.style.overflow = '';
    //     } else {
    //         document.body.style.overflow = 'hidden';
    //     }
    // }
    //End
}
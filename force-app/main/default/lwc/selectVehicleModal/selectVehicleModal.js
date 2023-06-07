import { LightningElement, track, wire, api} from 'lwc';
import getVehicleYear from '@salesforce/apex/B2B_EconfigIntegration.getVehicleYear';
import getVehicleModel from '@salesforce/apex/B2B_EconfigIntegration.getVehicleModel';
import getVehicleTrim from '@salesforce/apex/B2B_EconfigIntegration.getVehicleTrim';
import getCategoryId from '@salesforce/apex/B2B_VehicleSelectorController.getCategoryId';
import getVehicleDetails from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetails';
import GetModelByVinDecoder from '@salesforce/apex/B2B_INSystemIntegration.GetModelByVinDecoder';
import getVehicleDetailsForParts from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetailsForParts';
import callVinDecoderService from '@salesforce/apex/B2B_EconfigIntegration.callVinDecoderService';
import getVehicleDetailsForAccessories from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetailsForAccessories';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isguest from '@salesforce/user/isGuest'
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import getMyProductList from '@salesforce/apex/B2B_MySavedProduct.getMyProductList';
import getVehicleDetailsWithModalAndTrims from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetailsWithModalAndTrims';
import saveToMyProduct from '@salesforce/apex/B2B_MySavedProduct.saveToMyProduct';
import getCurrentCart from '@salesforce/apex/B2B_HandleCartAndUser.getCurrentCart';
import communityId from '@salesforce/community/Id';
import getLoginUrl from '@salesforce/label/c.Identity_Provider_Login_URL';
import getRegisterUrl from '@salesforce/label/c.Identity_Provider_Register_URL';
import saveLastShoppingSelection from '@salesforce/apex/B2B_ShoppingSelectionController.saveLastShoppingSelection';
//for adobe: starts
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';
//for adobe: ends

//for motocompacto
import { getCompleteDetails } from 'c/utils';
export default class SelectVehicleModal extends NavigationMixin(LightningElement) {
    @api isSEOMaintenence = false;
    @track divisionValue;
    @track yearId;
    @track modelId;
    @track TrimId;
    @track yearValue = 0;
    @track modelValue = 0;
    @track trimValue = 0;
    @track vinValue;
    @track makeValue;
    @track yearOptions = [];
    @track modelOptions = [];
    @track trimOption = [];
    @track productType = 'Parts';
    @track isLoaded = false;
    @track defaultSelectParts = true;
    @track showOrHideSearchButton = false;
    @track hondaVehicleData;
    @track acuraVehicleData;
    @track enterKeyPressed = false;
    @track isGuest = isguest;
    @track myProductOptions = [];
    @track showMyProductEditModalBox = false;
    @track vehicleData;
    @track selecteMyProductId = '';
    @track mfgColorCode = '';
    @track hasRender = true; // Added by Bhawesh on 25-03-2022 for HDMP- 8359 start

    //for adobe    
    @wire(MessageContext)
    messageContext;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuserdata({error, data }) {
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

    hasErrorFromAPI = false;
    hasErrorFromApex = false;

    connectedCallback() {
        let isSEOCategory = sessionStorage.getItem('isSEOCategory');
        let currentURL = window.location.href;
        let pathname = window.location.pathname;
        let selectedBrand = sessionStorage.getItem('brand') && sessionStorage.getItem('brand') != 'null' ? sessionStorage.getItem('brand') : '';
        if(isSEOCategory && (pathname.includes('acura') || pathname.includes('honda'))){
            this.divisionValue = currentURL.includes('acura') ? 2 : 1;
            this.makeValue = currentURL.includes('acura') ? 'Acura' : 'Honda';
        }else{
            if (selectedBrand) {
                this.divisionValue = selectedBrand.toLowerCase().includes('acura') ? 2 : 1;
                this.makeValue = selectedBrand.toLowerCase().includes('acura') ? 'Acura' : 'Honda';
            } else {
                this.divisionValue = currentURL.includes('acura') ? 2 : 1;
                this.makeValue = currentURL.includes('acura') ? 'Acura' : 'Honda';
            }
        }
        //let productType = this.getCookie('ProductType');
        let productType = sessionStorage.getItem('ProductType');
        if (productType && productType != 'null' && productType.toLowerCase() == 'parts' && this.template.querySelector('.partradio')) {
            this.template.querySelector('.partradio').checked = true;
        }
        else if (productType && productType != 'null' && productType.toLowerCase() == 'accessories' && this.template.querySelector('.accessoriesradio')) {
            this.template.querySelector('.accessoriesradio').checked = true;
        }
        this.prePopulateModelFields();
        this.getMyProductListFromApex();
    }

    // Added by Bhawesh on 25-03-2022 for HDMP- 8359 start
    renderedCallback(){
        if(this.hasRender){
            let self = this;
            let brandAndType =  JSON.parse(sessionStorage.getItem('brandAndProductTypeMap'));
            if (brandAndType && brandAndType != 'null' && brandAndType.Honda) {
                this.productType = brandAndType.Honda;
                let emlnt = brandAndType.Honda == 'Accessories' ? '.accessoriesradio' : '.partradio';
                this.defaultSelectParts = brandAndType.Honda == 'Accessories' ? false : true;
                let parCmpValue = self.template.querySelector(emlnt);
                if(parCmpValue){
                    parCmpValue.checked = true;
                }
            }
            else if(brandAndType && brandAndType != 'null' && brandAndType.Acura){
                let emlnt = brandAndType && brandAndType.Acura && brandAndType.Acura == 'Accessories' ? '.accessoriesradio' : '.partradio';
                this.productType = brandAndType.Acura;
                this.defaultSelectParts = brandAndType.Acura == 'Accessories' ? false : true;
                let parCmpValue = this.template.querySelector(emlnt);
                if(parCmpValue)
                    parCmpValue.checked = true;
            }
            this.hasRender = false;
        }
    }
    //End

    //Added by Faraz on 20/09/2021
    prePopulateModelFields(){
        let isSubmitted = sessionStorage.getItem('isSubmited');
        let mainHeaderSearched = sessionStorage.getItem('mainHeaderSearched');
        if((isSubmitted && isSubmitted == 'true') && (mainHeaderSearched && mainHeaderSearched == 'true')){
            let newYearId ,newYearValue, newModelId, newModelValue, newTrimId, newTrimValue, vinValue, modelData, trimData;	
            if(this.divisionValue == 1){
                vinValue = sessionStorage.getItem('HondaVin');
                this.vinValue = sessionStorage.getItem('HondaVin');
                newYearId = sessionStorage.getItem('HondaYearId');
                newYearValue = sessionStorage.getItem('HondaYearValue');
                newModelId = sessionStorage.getItem('HondaModelId');	
                newModelValue = sessionStorage.getItem('HondaModelValue');              	
                newTrimId = sessionStorage.getItem('HondaTrimId');	
                newTrimValue = sessionStorage.getItem('HondaTrimValue');
                modelData = sessionStorage.getItem('ModelOptionHonda');
                trimData = sessionStorage.getItem('TrimOptionHonda');
            }else if(this.divisionValue == 2){	
                vinValue = sessionStorage.getItem('AcuraVin');
                this.vinValue = sessionStorage.getItem('AcuraVin');
                newYearId = sessionStorage.getItem('AcuraYearId');	
                newYearValue = sessionStorage.getItem('AcuraYearValue');              	
                newModelId = sessionStorage.getItem('AcuraModelId');	
                newModelValue = sessionStorage.getItem('AcuraModelValue');                	
                newTrimId = sessionStorage.getItem('AcuraTrimId');	
                newTrimValue = sessionStorage.getItem('AcuraTrimValue');
                modelData = sessionStorage.getItem('ModelOptionAcura');
                trimData = sessionStorage.getItem('TrimOptionAcura');          	
            }
            setTimeout(function() {
                //For VIN 
                if(vinValue){
                    let vinCmp = this.template.querySelector('.Vin');
                    vinCmp.value = vinValue;
                }
                //For Year
                if(newYearId && newYearValue){
                    let yearCmp = this.template.querySelector('.Year');
                    yearCmp.disabled = false;
                    yearCmp.options = this.yearOptions;
                    yearCmp.value = newYearId;
                    this.yearValue = newYearValue;
                    this.yearId = newYearId;
                    //For Model
                    if(newModelId && newModelValue){
                        let options = JSON.parse(modelData);
                        this.modelOptions = options;
                        let modelCmp = this.template.querySelector('.Model');
                        modelCmp.disabled = false;
                        modelCmp.options = this.modelOptions;
                        modelCmp.value = newModelId;
                        this.modelValue = newModelValue;
                        this.modelId = newModelId;
                        //For Trim
                        if(newTrimId && newTrimValue){
                            let trimOptions = JSON.parse(trimData);
                            this.trimOption = trimOptions;
                            let trimCmp = this.template.querySelector('.Trim');
                            trimCmp.disabled = false;
                            trimCmp.options = this.trimOption;	                                            	
                            trimCmp.value = newTrimId;
                            this.trimValue = newTrimValue;
                            this.TrimId = newTrimId;
                        }
                    }
                }
            }.bind(this), 50);
        }
    }
    //-----End----//
    
    @wire(getVehicleYear, {
        division: '$divisionValue'
    })
    wiredGetVehicleYear(result) {
        if (result.data) {
            let parseData = JSON.parse(result.data)
            let yearOptionList = [];
            for (const [key, value] of Object.entries(parseData)) {
                yearOptionList.push({ label: value, value: key });
            }
            this.yearOptions = yearOptionList.sort(function (a, b) {
                return b.label - a.label;
            });
        } else if (result.error) {
            //console.log('ERROR::', JSON.stringify(result.error));
            this.yearOptions = [];
        }
    }

    handleSelectOnPartsOrAccessories(event) {
        this.productType = event.target.value;
        if (this.productType == 'Parts') {
            this.defaultSelectParts = true;
        } else if (this.productType == 'Accessories') {
            this.defaultSelectParts = false;
        }

        if (this.hasErrorFromAPI) {
            this.clearYMT();
            this.clearVINNumber();
            let vinCmp = this.template.querySelector('.Vin');
            vinCmp.focus();
            setTimeout(() => {
                vinCmp.blur();
            }, 50);
        }

        if (this.hasErrorFromApex) {
            this.clearVINNumber();
            let vinCmp = this.template.querySelector('.Vin');
            vinCmp.focus();
            setTimeout(() => {
                vinCmp.blur();
            }, 50);
        }
    }

    clearYMT() {
        let yearCmp = this.template.querySelector('.Year');
        yearCmp.value = '';
        this.yearId = '';
        this.yearValue = '';

        let modelCmp = this.template.querySelector('.Model');
        modelCmp.value = '';
        this.modelId = '';
        this.modelValue = '';

        let trimCmp = this.template.querySelector('.Trim');
        trimCmp.value = '';
        this.TrimId = '';
        this.trimValue = '';
    }

    clearVINNumber() {
        let vinCmp = this.template.querySelector('.Vin');
        vinCmp.setCustomValidity("");
        vinCmp.value = ''
        this.vinValue = '';
    }

    // this method will call when user select the year
    handleYearChange(event) {
        this.clearVINNumber();
        //   let index = event.currentTarget.dataset.index;
        let name = '.' + event.currentTarget.name;
        let yearCmp = this.template.querySelector(name);
        this.yearId = yearCmp.value;
        let yearObj = yearCmp.options.find(item => item.value == this.yearId);
        this.yearValue = yearObj.label;
        let modelName = '.Model';
        let modelCmp = this.template.querySelector(modelName);
        modelCmp.value = '';
        this.modelValue = '';
        modelCmp.options = [];
        modelCmp.disabled = true;
        modelCmp.setCustomValidity("");
        modelCmp.reportValidity();
        modelCmp.disabled = false;
        let trimName = '.Trim';
        let trimCmp = this.template.querySelector(trimName);
        trimCmp.value = '';
        this.trimValue = '';
        trimCmp.options = [];
        trimCmp.disabled = true;
        trimCmp.setCustomValidity("");
        trimCmp.reportValidity();
        //Added by Deepak Mali 25 2022
        let productCmpName = '.Products';
        this.template.querySelector(productCmpName) ? this.template.querySelector(productCmpName).value = '' : null;
        //Ends
        this.getModelOptions(this.divisionValue, this.yearId);
        // Added by Bhawesh on 25-03-2022 for HDMP- 8359 start
        this.hasRender = false;
        //End
    }

    // this method will call when user select the model
    handleModelChange(event) {
        this.clearVINNumber();
        //let index = event.currentTarget.dataset.index;
        let name = '.' + event.currentTarget.name;
        let modelCmp = this.template.querySelector(name);
        this.modelId = modelCmp.value;
        let modelObj = modelCmp.options.find(item => item.value == this.modelId);
        this.modelValue = modelObj.label;
        let trimName = '.Trim';
        let trimCmp = this.template.querySelector(trimName);
        trimCmp.value = '';
        this.trimValue = '';
        trimCmp.options = [];
        trimCmp.disabled = true;
        trimCmp.setCustomValidity("");
        trimCmp.reportValidity();
        trimCmp.disabled = false;
        //Added by Deepak Mali 25 2022
        let productCmpName = '.Products';
        this.template.querySelector(productCmpName) ? this.template.querySelector(productCmpName).value = '' : null;
        //Ends
        this.getTrimOptions(this.divisionValue, this.yearId, this.modelValue.toString());
    }

    // this method will call when user select the trim
    handleTrimChange(event) {
        this.clearVINNumber();
        let name = '.' + event.currentTarget.name;
        let trimCmp = this.template.querySelector(name);
        this.TrimId = trimCmp.value;
        let trimObj = trimCmp.options.find(item => item.value == this.TrimId);
        this.trimValue = trimObj.label;
        //Added by Deepak Mali 25 2022
        let productCmpName = '.Products';
        this.template.querySelector(productCmpName) ? this.template.querySelector(productCmpName).value = '' : null;
        //Ends
    }

    handleVinChange(event) {
        try {
            this.clearYMT();
            this.hasErrorFromAPI = false;
            let vinCmpName = '.' + event.currentTarget.name;
            let index = event.currentTarget.dataset.index;
            this.vinValue = event.detail.value;
            let vinCmp = this.template.querySelector(vinCmpName);
            //Added by Deepak Mali 3 March 2022
            let productCmpName = '.Products';
            this.template.querySelector(productCmpName) ? this.template.querySelector(productCmpName).value = '' : null;
            //END
            if (this.vinValue.length == 0 || this.vinValue == '') {
                let yearCmpName = '.Year', modeCmpName = '.Model', trimCmpName = '.Trim';
                this.template.querySelector(yearCmpName).value = '';
                this.template.querySelector(modeCmpName).value = '';
                this.template.querySelector(trimCmpName).value = '';
                this.template.querySelector(yearCmpName).disabled = false;
                this.template.querySelector(yearCmpName).options = this.yearOptions;
                this.yearValue = 0;
                this.modelValue = 0;
                this.trimValue = 0;
                vinCmp.setCustomValidity("");
                // Added by deepak 
                this.template.querySelectorAll('.saveVehicle').forEach((element) => {
                    element.disabled = true;
                    element.checked = false;
                });
                setTimeout(() => {
                    this.template.querySelector('[data-name="saveVehicleYMT"]').disabled = false;
                }, 100);
                //End
            }
            let format = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;
            if ((this.vinValue.length > 0 && format.test(this.vinValue) == true) || this.vinValue.length > 17) {
                vinCmp.setCustomValidity("Please enter valid VIN");
                this.isLoaded = false;
                this.showOrHideSearchButton = false;
                // Added by deepak 
                this.template.querySelectorAll('.saveVehicle').forEach((element) => {
                    element.disabled = true;
                    element.checked = false;
                });
                //End
            } else {
                vinCmp.setCustomValidity("");
            }
            if (this.vinValue.length == 17 || this.vinValue.length == 10) {
                this.isLoaded = true;
                this.showOrHideSearchButton = true;
                //Added by Deepak Mali 1 Sept 2021 for HDMP 3690 
                //The VIN field should not be editable while the search is executing
                /*let VinCmpName = '.Vin' + index;
                let vinCmp = this.template.querySelector(VinCmpName);
                vinCmp.disabled = true;*/
                this.template.querySelectorAll('.saveVehicle').forEach((element) => element.disabled = false);
                this.getModelByEconfigVIN(vinCmp);
                // if (this.productType && this.productType == 'Parts')
                //     this.setModalByVinDecoder(index, vinCmp);
                // else
                //     this.getModelByEconfigVIN(vinCmp, index);
            }
            vinCmp.reportValidity();
        } catch (error) {
            // alert(error.message);
        }
    }

    setVehicleDataForParts(data, index) {
        let displayData = data;
        let errorMsg = 'We’re sorry, we are not able to determine your vehicle’s model information. Please use our model selector to search for products';
        let vinCmp = this.template.querySelector('.Vin');
        getVehicleDetailsForParts({ modelId: displayData.Products[0].ID, gradeId: displayData.Grades[0].ID, yearId: displayData.Years[0].ID, transmissionId: displayData.Transmissions[0].ID, doorId: displayData.Doors[0].ID, catalogId: displayData.Catalogs[0].CatalogID }).then(result => {
            if (result) {
                vinCmp.setCustomValidity('');
                this.hasErrorFromApex = false;
                let vehicleMapResult = JSON.parse(result);
                let vehicle = JSON.parse(vehicleMapResult.vehicle);
                if (this.divisionValue == 1)
                    this.hondaVehicleData = vehicle;
                else
                    this.acuraVehicleData = vehicle;
                // for years
                let yearCmpName = '.Year';
                let yearCmp = this.template.querySelector(yearCmpName);
                // yearCmp.options = [{ label: displayData.Years[0].Description, value: displayData.Years[0].ID }];
                yearCmp.options = this.yearOptions;
                yearCmp.value = displayData.Years[0].ID.toString();
                yearCmp.disabled = false;
                this.yearValue = displayData.Years[0].Description;
                this.yearId = displayData.Years[0].ID;

                // for models
                let modelCmpName = '.Model';
                let modelCmp = this.template.querySelector(modelCmpName);
                let modelOptionAll = [];
                let parseDataModel = JSON.parse(vehicleMapResult.vehicleModels);
                for (const [key, value] of Object.entries(parseDataModel)) {
                    modelOptionAll.push({ label: key, value: value })
                }
                let modelOption = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);
                modelCmp.options = modelOption;
                // modelCmp.options = [{ label: vehicle.Model__c, value: displayData.Products[0].ID }];

                let vehicleModelId = modelCmp.options.find(item => item.label == vehicle.Model__c).value;
                modelCmp.value = vehicleModelId.toString();
                modelCmp.disabled = false;
                this.modelValue = vehicle.Model__c;
                this.modelId = vehicleModelId;
                this.modelOptions = modelOption;

                //for trims
                let trimCmpName = '.Trim';
                let trimCmp = this.template.querySelector(trimCmpName);
                let parseDataTrim = JSON.parse(vehicleMapResult.vehicleTrims);
                let allTrimOptions = [];
                for (const [key, value] of Object.entries(parseDataTrim)) {
                    allTrimOptions.push({ label: key, value: value })
                }
                let trimOptions = allTrimOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                trimCmp.options = trimOptions;
                // trimCmp.options = [{ label: vehicle.Trim__c, value: displayData.Grades[0].ID }];
                trimCmp.value = displayData.Grades[0].ID.toString();
                trimCmp.disabled = false;
                this.trimValue = vehicle.Trim__c;
                this.TrimId = displayData.Grades[0].ID.toString();
                this.trimOption = trimOptions;
                this.showOrHideSearchButton = false;
                this.isLoaded = false;
            }
        }).catch(error => {
            this.showOrHideSearchButton = false;
            this.isLoaded = false;
            this.hasErrorFromApex = true;
            vinCmp.setCustomValidity(errorMsg);
            vinCmp.reportValidity();
        })
    }

    setModalByVinDecoder(index, vinCmp) {
        GetModelByVinDecoder({ vincode: this.vinValue, division: this.divisionValue }).then(result => {
            let displayData = JSON.parse(result);
            if (displayData.isError) {
                let errorMsg = '';
                if (displayData.errorMessage && displayData.errorMessage.toLowerCase().includes("unable to decode vin at this time")) {
                    this.isLoaded = false;
                    this.showOrHideSearchButton = false;
                    this.hasErrorFromAPI = true;
                    errorMsg = 'We’re sorry, we are not able to determine your vehicle’s model information. Please use our model selector to search for products';
                    // if (this.vinValue.length == 17) {
                    //     errorMsg = 'VIN can\'t be decoded at this time, please select the additional model info to refine their vehicle search.';
                    // } else if (this.vinValue.length == 10) {
                    //     errorMsg = 'We’re sorry, we are not able to determine your vehicle’s model information. Please use our model selector to search for products';
                    // }
                }
                else if (displayData.errorMessage && (displayData.errorMessage.toLowerCase().includes("invalid acura vin") || displayData.errorMessage.toLowerCase().includes("invalid honda vin") || displayData.errorMessage.toLowerCase().includes("model does not exist"))) {
                    this.isLoaded = false;
                    this.showOrHideSearchButton = false;
                    this.hasErrorFromAPI = true;
                    errorMsg = this.divisionValue && this.divisionValue == 1 ? 'You\'ve entered an Acura VIN, please select the Acura menu to search for those items' : 'You\'ve entered a Honda VIN, please select the Honda menu to search for those items';
                }
                else {
                    this.isLoaded = false;
                    this.showOrHideSearchButton = false;
                    errorMsg = 'Please enter valid VIN';
                }
                vinCmp.setCustomValidity(errorMsg);
                vinCmp.reportValidity();
            } else if (result) {
                vinCmp.setCustomValidity("");
                //for years  
                if (displayData && displayData.Years && displayData.Years.length) {
                    this.setVehicleDataForParts(displayData, index);
                } else {
                    vinCmp.setCustomValidity("Please enter valid VIN ");
                    this.isLoaded = false;
                    this.hasErrorFromApex = true;
                    this.showOrHideSearchButton = false;
                }
                vinCmp.reportValidity();
            } else {
                vinCmp.setCustomValidity("Please enter valid VIN ");
            }
            //vinCmp.disabled = false;  
        }).catch((error) => {
            //console.log(error);
            //vinCmp.disabled = false; 
        });
    }

    getModelOptions(divisionId, yearId) {
        if (divisionId && yearId) {
            getVehicleModel({ division: this.divisionValue, year: this.yearId }).then(result => {
                if (result) {
                    let parseDataModel = JSON.parse(result)
                    let modelOptionList = [];
                    for (const [key, value] of Object.entries(parseDataModel)) {
                        modelOptionList.push({ label: key, value: value });
                    }
                    this.modelOptions = modelOptionList.sort((a, b) => (a.label > b.label) ? 1 : -1);                    
                }
            }).catch(error => {
                //console.log('error while getting model options', error);
            })
        }
    }

    getTrimOptions(divisionId, yearId, modelId) {
        if (divisionId && yearId && modelId) {
            getVehicleTrim({ division: divisionId, year: yearId, modelValue: modelId }).then(result => {
                if (result) {
                    let parseDataTrim = JSON.parse(result)
                    let allTrimOptionList = [];
                    for (const [key, value] of Object.entries(parseDataTrim)) {
                        allTrimOptionList.push({ label: key, value: value });
                    }
                    this.trimOption = allTrimOptionList.sort((a, b) => (a.label > b.label) ? 1 : -1);
                }
            }).catch(error => {
               // console.log('error while getting trim options', error);
            })
        }
    }

    closeChangeVehiclePopUp(event) {
        this.dispatchEvent(new CustomEvent('closechangevehicle', {}));
    }

    handleOnSearchVehicle() {
        localStorage.setItem('partSerachValue', '');//added by Yashika for 13719
        localStorage.removeItem('searchedTerm');
        sessionStorage.removeItem('searchedTerm');
        sessionStorage.removeItem('category');
        sessionStorage.setItem('fromWhichPageUserHasRefresh', 'CATEGORY'); //Added by Bhawesh on 11-02-2022 for HDMP-6887
        // added for multi tab issue . starts here
        sessionStorage.removeItem('relayStatePage');
        // multi tab issue . ends here
        // Added by Bhawesh on 25-03-2022 for HDMP-8359 start
        if(this.divisionValue == 1){
            let obj = {'Honda': this.productType};
            sessionStorage.setItem('brandAndProductTypeMap', JSON.stringify(obj));
        }else{
            let obj = {'Acura': this.productType};
            sessionStorage.setItem('brandAndProductTypeMap', JSON.stringify(obj));
        }
        // End
        if (this.divisionValue && this.yearValue && this.modelValue && this.trimValue) {
            //this.createCookie('ProductType', this.productType, 1);
            sessionStorage.setItem('ProductType', this.productType);
            // to close modal set isModalOpen track value as false
            localStorage.removeItem("category");
            let brand = this.makeValue;
            sessionStorage.setItem('brand', brand);
            sessionStorage.setItem('vehicleBrand',brand);
            sessionStorage.setItem('vehicleBrand2',brand); // used for backend breadcrumbs logic
            if (sessionStorage.getItem('dealer')) {
                this.buildEffectiveDealer();
            }
            if (this.checkVINValidation() && this.makeValue && this.yearValue && this.modelValue && this.trimValue) {
                this.isLoaded = true;
                this.createCookie('Make', '', 1); // Clear cookie first
                this.createCookie('Year', '', 1); // Clear cookie first
                this.createCookie('Model', '', 1); // Clear cookie first
                this.createCookie('Trim', '', 1); // Clear cookie first
                this.createCookie('Make', this.makeValue, 1);
                this.createCookie('Year', this.yearValue, 1);
                this.createCookie('Model', this.modelValue, 1);
                this.createCookie('Trim', this.trimValue, 1);
                this.createCookie('Vin', this.vinValue, 1);
                this.createCookie('Division', this.divisionValue, 1);
                this.setYearCookies();
                this.setModelCookies();
                this.setTrimCookies();
                this.setVINCookies();
                sessionStorage.setItem('isSubmited',true);
                sessionStorage.setItem('mainHeaderSearched',true);
                sessionStorage.setItem('division',this.divisionValue);
                sessionStorage.setItem('selecteMyProductId', this.selecteMyProductId);
                // added on 11/12 start
                sessionStorage.setItem('VehicleName',this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim')); // used for backend breadcrumbs logic
                sessionStorage.setItem('VehicleModelId',this.getCookie('ModelId'));
                sessionStorage.setItem('VehicleVIN',this.vinValue);
                sessionStorage.setItem('VehicleYear',this.yearValue);
                sessionStorage.setItem('VehicleModel',this.modelValue);
                sessionStorage.setItem('VehicleTrim',this.trimValue);
                // added on 11/12 end
                try {
                    this.storedMake = this.getCookie('Make');
                    this.storedYear = this.getCookie('Year');
                    this.storedModel = this.getCookie('Model');
                    this.storedTrim = this.getCookie('Trim');
                    this.buttonLabel = 'MyVehicle: ' + this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim');
                    this.isModalOpen = false;
                    var currURL = window.location.href;
                    var parts = currURL.split('/');
                    var getUrl = window.location;
                    var baseUrl = getUrl.protocol + "//" + getUrl.host + "/s/category/";
                    this.boolVisible = true;
                    this.isLoaded = false;
                    this.saveToMyProductList();
                    this.handleSaveLastShoppingSelection();//Added by Faraz on 09/09/2022
                    console.log('this.productType', this.productType)
                    //for adobe: starts
                    let events = 'product search by ' + this.productType;
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

                    const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'findProductDetails': findProductDetails, 'events': events } };
                    publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                    //for adobe: ends
                    if(this.isSEOMaintenence){
                        sessionStorage.setItem('SEO_Maintenence','true');
                    }
                    this.goToCategoyPage(this.storedMake, baseUrl);
                } catch (ex) {
                    //console.log(ex.message);
                    this.isLoaded = false;
                }
            }
        } else {
            //Added by Deepak Mali 20 Aug 2021
            //The VIN field should not be editable while the search is executing
            /*this.isLoaded = false;
            let VinCmpName = '.Vin1';
            let vinCmp = this.template.querySelector(VinCmpName);
            vinCmp.disabled = false;*/
            if (!this.enterKeyPressed || this.vinValue > 1) {
                if (this.vinValue && this.vinValue.length == 10 && this.vinErrorMessage) {
                    this.showNotification('Error', this.vinErrorMessage, 'error');
                } else {
                    this.showNotification('Error', 'Please select either year, model and trim or enter valid vin ', 'error');
                }
            }
        }
        //Sakshi -4815
        this.createCookie('VINFitValue',this.vinValue, 1);
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

    goToCategoyPage(category, baseUrl) {
        getCategoryId({ categoryName: this.makeValue })
        .then((resu) => {
            this.categoryId = resu;
            var catId = this.categoryId;
            baseUrl = baseUrl + catId;
            getVehicleDetails({ yearValue: this.yearValue, modelValue: this.modelValue, trimValue: this.trimValue, division : this.divisionValue }).then(result => {
                let vehicle = Object.assign({}, result);
                this.createCookie('vehicle', JSON.stringify(vehicle), 1);
                this.buildEffectiveVehicle(catId);
                setTimeout(function () {
                    this.isLoaded = false; //Added by deepak mali 27 Aug 2021
                    //The VIN field should not be editable while the search is executing
                    let VinCmpName = '.Vin';
                    let vinCmp = this.template.querySelector(VinCmpName);
                    vinCmp.disabled = false;
                }.bind(this), 3000);
                this.setYearCookies();
                this.setModelCookies();
                this.setTrimCookies();
                this.setVINCookies();
                if (this.divisionValue == 1) {
                    sessionStorage.setItem('ModelOptionHonda', JSON.stringify(this.modelOptions));
                    sessionStorage.setItem('TrimOptionHonda', JSON.stringify(this.trimOption));
                    //sessionStorage.setItem('HondaVin', this.vinValue);
                    let hondaVehicle = this.hondaVehicleData ? this.hondaVehicleData : '';
                    sessionStorage.setItem('hondaVehicleData', hondaVehicle);
                } else if (this.divisionValue == 2) {
                    sessionStorage.setItem('ModelOptionAcura', JSON.stringify(this.modelOptions));
                    sessionStorage.setItem('TrimOptionAcura', JSON.stringify(this.trimOption));
                    //sessionStorage.setItem('AcuraVin', this.vinValue);

                    let acuraVehicle = this.acuraVehicleData ? this.acuraVehicleData : '';
                    sessionStorage.setItem('acuraVehicleData', acuraVehicle);
                }
                if(this.productType == 'Accessories' && this.modelValue == 'Motocompacto'){ 
                    this.goToMotocompactoPDP(vehicle);                      
                }else {
                    sessionStorage.removeItem('isMotoCompacto');
                    window.open(baseUrl, "_self");
                }               
            }).catch(error => {
                //console.log('error : ', error);
            })
        })
        .catch((error) => {
            this.error = error;
            //console.log('error::::', error);
        });
    }

    //Motocompacto starts
    async goToMotocompactoPDP(vehicle){
        console.log('vehicle raj : ',vehicle);
        sessionStorage.setItem('isMotoCompacto', 'true');
        //set breadcrum
        let brand = sessionStorage.getItem('vehicleBrand');
        let breadcrumbsList = [];
        let obj = {'label' : brand, 'isCurrentPage' : false, 'href' : window.location.origin+'/s/'+this.makeValue.toLowerCase()};
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
        } else {
            this.showNotification('Error', 'We\'re experiencing technical difficulties, please try again later.', 'error');
        }              
    }
    //Motocompacto ends

    getModelByEconfigVIN(vinCmp) {
        callVinDecoderService({ vinNumber: this.vinValue, poiType: (this.makeValue && this.makeValue == 'Honda' ? 'A' : 'B') }).then(result => {
            let displayData = JSON.parse(result);
            if (displayData.isError || !displayData.selectorDetail.partsCatalog) {
                this.vinErrorMessage = displayData.message ? displayData.message : '';
                let errorMsg = '';
                if (displayData.message && displayData.message.toLowerCase().includes("unable to decode vin at this time")) {
                    errorMsg = 'We’re sorry, we are not able to determine your vehicle’s model information. Please use our model selector to search for products';
                    this.hasErrorFromAPI = true;
                    // if (this.vinValue.length == 17) {
                    //     errorMsg = 'VIN can\'t be decoded at this time, please select the additional model info to refine their vehicle search.';
                    // } else if (this.vinValue.length == 10) {
                    //     errorMsg = 'We’re sorry, we are not able to determine your vehicle’s model information. Please use our model selector to search for products';
                    // }
                }
                else if (displayData.message && (displayData.message.toLowerCase().includes("invalid acura vin") || displayData.message.toLowerCase().includes("invalid honda vin") || displayData.message.toLowerCase().includes("model does not exist"))) {
                    this.hasErrorFromAPI = true;
                    errorMsg = this.divisionValue && this.divisionValue == 1 ? 'You\'ve entered an Acura VIN, please select the Acura menu to search for those items' : 'You\'ve entered a Honda VIN, please select the Honda menu to search for those items';
                }
                else if (displayData.message && (displayData.message.includes("Please fix VIN. If VIN valid, please contact support") )) {
                    errorMsg = 'We\'re sorry, we are not able to determine your vehicle\'s model. Please use the model selector to search for products';
                    this.hasErrorFromAPI = true;
                }
                else
                    errorMsg = 'Please enter valid VIN';

                //Added by deepak mali 
                if (errorMsg) {
                    this.template.querySelectorAll('.saveVehicle').forEach((element) => {
                        element.disabled = true;
                        element.checked = false;
                    });
                }
                //END
                vinCmp.setCustomValidity(errorMsg);
                vinCmp.reportValidity();
            } else {
                let modelId = displayData.selectorDetail.modelId;
                if(displayData.selectorDetail && displayData.selectorDetail.colors){
                    let colorDate = JSON.parse(displayData.selectorDetail.colors);
                    this.mfgColorCode = colorDate && colorDate.color && colorDate.color[1]['@mfg_color_cd'] ? colorDate.color[1]['@mfg_color_cd'] : '';
                }
                getVehicleDetailsForAccessories({ modelId: modelId.toString() }).then(vecResult => {
                    if (vecResult) {
                        let vehicleMapResult = JSON.parse(vecResult);
                        let vehicleResult = JSON.parse(vehicleMapResult.vehicle);
                        if (this.divisionValue == 1)
                            this.hondaVehicleData = vehicleResult;
                        else
                            this.acuraVehicleData = vehicleResult;

                        vinCmp.setCustomValidity("");
                        //for years  
                        let yearCmpName = '.Year';
                        let yearCmp = this.template.querySelector(yearCmpName);
                        // yearCmp.label = displayData.Years[0].Description;  
                        yearCmp.options = this.yearOptions;
                        yearCmp.value = vehicleResult.iNYearID__c.toString();
                        yearCmp.disabled = false;
                        this.yearValue = vehicleResult.Year__c;
                        this.yearId = vehicleResult.iNYearID__c;
                        // for models
                        let modelCmpName = '.Model';
                        let modelCmp = this.template.querySelector(modelCmpName);
                        //modelCmp.label = vehicle.Model__c;
                        let modelOptionAll = [];
                        let parseDataModel = JSON.parse(vehicleMapResult.vehicleModels);
                        for (const [key, value] of Object.entries(parseDataModel)) {
                            modelOptionAll.push({ label: key, value: value });
                        }
                        let modelOption = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);
                        modelCmp.options = modelOption;
                        let vehicleModelId = modelOption.find(item => item.label == vehicleResult.Model__c).value;
                        modelCmp.value = vehicleModelId.toString();
                        modelCmp.disabled = false;
                        this.modelValue = vehicleResult.Model__c;
                        this.modelId = vehicleModelId.toString();
                        this.modelOptions = modelOption;
                        //for trims
                        let trimCmpName = '.Trim';
                        let trimCmp = this.template.querySelector(trimCmpName);
                        //trimCmp.label = vehicle.Trim__c; 
                        let parseDataTrim = JSON.parse(vehicleMapResult.vehicleTrims);
                        let allTrimOptions = [];
                        for (const [key, value] of Object.entries(parseDataTrim)) {
                            allTrimOptions.push({ label: key, value: value });
                        }
                        let trimOptions = allTrimOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                        trimCmp.options = trimOptions;
                        //Added by Shalini soni 29 Sept 
                        trimCmp.value = vehicleResult.Model_Id__c.toString();
                        //trimCmp.value = vehicleResult.iNGradeID__c.toString();
                        trimCmp.disabled = false;
                        //Added by Shalini soni 29 Sept 
                        this.TrimId = vehicleResult.Model_Id__c.toString();   
                        //this.TrimId = vehicleResult.iNGradeID__c.toString();
                        this.trimValue = vehicleResult.Trim__c;
                        this.trimOption = trimOptions;
                        sessionStorage.setItem('partsCatalog', displayData.selectorDetail.partsCatalog);
                        //Remove hdie class which is added in handleVinChange HDMP-3638             
                        // this.template.querySelector(searchButton).classList.remove('slds-hide');
                    }
                }).catch(error => {
                    //console.log('Error : ', error);
                    this.error = error;
                    this.showOrHideSearchButton = false;
                    this.isLoaded = false;
                    this.hasErrorFromApex = true;
                    if (this.error.body.message.includes('List has no rows for assignment to SObject')) {
                        vinCmp.setCustomValidity("Please enter valid VIN ");
                        vinCmp.reportValidity();
                    }
                })
            }
            this.showOrHideSearchButton = false;
            this.isLoaded = false;
            //vinCmp.disabled = false;
        }).catch(error => {
            //console.log('Error : ', error);
            this.error = error;
            this.showOrHideSearchButton = false;
            this.isLoaded = false;
            //vinCmp.disabled = false;
        })
    }

    handleToEditMyProduct(event) {
        try {
            let productCmp = this.template.querySelector('.Products');
            let editProductId = productCmp.value;
            if (editProductId) {
                this.showMyProductEditModalBox = true;
                // Here we are sending data to Modal Box so user can edit this informations 
                let brandName = this.divisionValue == 1 ? 'Honda' : 'Acura';
                let record = this.myProductList.find(item => item.Id == editProductId);
                let vinValue = this.template.querySelector('.Vin').value;
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
            //END
        } catch (error) {
            console.log('OUTPUT : ',error);
        }
    }

    setMyProduct() {
        try {
            if (sessionStorage.getItem('selecteMyProductId')) {
                let selecteMyProductId = sessionStorage.getItem('selecteMyProductId');
                let record = this.myProductList.find(item => item.Id == selecteMyProductId);
                let productClass = '.Products';
                let productCmp = this.template.querySelector(productClass);
                let vinCmp = this.template.querySelector('.Vin');
                let storeBrand = sessionStorage.getItem('brand');
                if (productCmp && record.Honda_Product__r.Product_Models__r.Product_Subdivision__c == storeBrand){
                    productCmp.value = selecteMyProductId;
                    if (vinCmp){
                    vinCmp.value = record.Honda_Product__r.Product_Identifier__c;
                    }
                }
            }
        } catch (error) {
            console.log('Error : ',error);
        }
    }

    //Added by Soumya for Cart Management- Login
    redirectToLoginPage() {
        getCurrentCart({ communityId: communityId })
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
            if(relayState && window.location.href.includes('/s/category/')){
                localStorage.setItem('fromlogin', 'true');
                relayState = relayState.substring(relayState.indexOf('/s/'));
                localStorage.removeItem('relayStateUrl');
                pathURL = '/s/splash?returnUrl=' + relayState;
                finalURL = getLoginUrl + '&RelayState=' + pathURL;
            }else{
                finalURL = getLoginUrl + '&RelayState=' + encodeURIComponent(pathURL);
            }
                //for adobe analytic: starts
                let events = 'login initiation';
                sessionStorage.setItem('eventsForAdobe', 'login success');
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
    } 
    // Ends Here

    // Added by Soumya for Cart Management- Register
    redirectToRegisterPage() {
        getCurrentCart({ communityId: communityId })
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
                let events = 'register initiation';
                sessionStorage.setItem('eventsForAdobe', 'registration success');
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

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    closeModalBoxPopup(event) {
        this.showMyProductEditModalBox = false;
        if (event.detail) {
            window.location.reload();
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
        //updated by Pradeep Singh for Optiv Issue
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
        // ends here
    }

    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);
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

    showSearchButton(){}

    //Added by Deepak Mali Task:HDMP-3690 "Enter" key should have the same functionality as clicking the main CTA
    handleKeyPress(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        if (charCode == 13 && this.trimValue && this.trimValue.length >0) { 
            //The VIN field should not be editable while the search is executing
            let VinCmpName = '.Vin';
            let vinCmp = this.template.querySelector(VinCmpName);
            vinCmp.disabled = true;
            this.enterKeyPressed = true; //Added by Deepak Mali 27 Aug 2021
            this.isLoaded = true; //Added by deepak mali 27 Aug 2021
            this.handleOnSearchVehicle();
        }
    }

    //Added by Deepak
    async getMyProductListFromApex() {
        if(!this.isGuest){
            await getMyProductList()
            .then(result => {
                this.myProductList = result;
                let allProductList = [];
                this.myProductList.forEach(element => {
                    let brandName = this.divisionValue == 1 ? 'Honda' : 'Acura';
                    if (brandName == element.Honda_Product__r.Product_Models__r.Product_Subdivision__c) {
                        allProductList.push({
                            label: element.Nickname__c ? element.Nickname__c : element.Honda_Product__r.Product_Models__r.Model_Year__c +' '+element.Honda_Product__r.Product_Models__r.Model_Name__c,
                            value: element.Id
                        })
                    }
                });
                this.myProductOptions = allProductList.length > 0 ? allProductList : null;
                this.setMyProduct();
            })
            .catch(error => {
                console.error('Error:', error);
            });
        }
    }
    //Ends

    async handleProductChange(event) {
        let recordId = event.detail.value;
        this.selecteMyProductId = recordId;
        let year, modal, trim;
        let myProductRecord = this.myProductList.find(item => item.Id == recordId);
        year = myProductRecord.Honda_Product__r.Product_Models__r.Model_Year__c;
        modal = myProductRecord.Honda_Product__r.Product_Models__r.Model_Name__c;
        trim = myProductRecord.Honda_Product__r.Product_Models__r.Trim__c;
        let productModelId = myProductRecord.Honda_Product__r.Product_Models__r.Product_Model_ID__c;
        let VinCmpName = '.Vin';
        let vinCmp = this.template.querySelector(VinCmpName);
        vinCmp.value = myProductRecord.Honda_Product__r.Product_Identifier__c;
        vinCmp.setCustomValidity('');
        vinCmp.reportValidity();
        this.vinValue = myProductRecord.Honda_Product__r.Product_Identifier__c;
        //End
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
        const params = { yearValue: year, modelValue: modal, trimValue: trim };
        //START
        //await getVehicleDetailsWithModalAndTrims(params).then(vecResult => {
        await  getVehicleDetailsForAccessories({ modelId: productModelId}).then(vecResult => {
            if (vecResult) {
                let vehicleMapResult = JSON.parse(vecResult);
                let vehicleResult = JSON.parse(vehicleMapResult.vehicle);
                //for years  
                let yearCmpName = '.Year';
                let yearCmp = this.template.querySelector(yearCmpName);
                if (this.divisionValue == 1) {
                    yearCmp.options = this.yearOptions;  //yearOptions;
                } else {
                    yearCmp.options = this.yearOptions;
                }

                yearCmp.value = vehicleResult.iNYearID__c.toString();
                yearCmp.disabled = false;
                this.yearValue = vehicleResult.Year__c;
                this.yearId = vehicleResult.iNYearID__c;
                this.setYearCookies();

                // for models
                let modelCmpName = '.Model';
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
                let trimCmpName = '.Trim';
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
            } else {
                console.error(vecResult)
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

    // Added by deepak 
    saveToMyProductList() {
        try {
            let checked = false;
            this.template.querySelectorAll('.saveVehicle').forEach((element) => {
                if (element.checked && checked == false) {
                    checked = true;
                }
            });

            if (checked && checked == true) {
                /* let inputParams = {
                    //Product_Type__c: this.makeValue,
                    //Year__c: this.yearValue,
                    //Modal__c: this.modelValue,
                    //Trim__c: this.trimValue,
                    Product_Identifier__c: this.vinValue,
                };*/
                let name = this.yearValue +' '+ this.modelValue;
                let subVinValue = '';
                if(this.vinValue.length){
                    subVinValue = this.vinValue.substring(this.vinValue.length - 6);
                    name += ' ' + this.trimValue + ' ' + subVinValue;
                }else{
                    name += ' ' + this.trimValue;
                }
                //let name = 'My ' + this.yearValue + ' ' + this.modelValue + ' ' + vinValue;
                saveToMyProduct({ vin: this.vinValue, trimModelId: this.TrimId, nickname: name, mnfgColorCode: this.mfgColorCode})
                .then((result) => {
                    if(result == 'Success'){
                        this.showNotification('Success', 'Saved to My Product Successfully', 'success');
                    }else if(result == 'Already Exists'){
                        let msg = this.vinValue.length ? 'A product with this VIN already exists in My Products.' : 'A product with this model already exists in My Products.';
                        this.showNotification(result, msg, 'info');
                    }else{
                        this.showNotification('Record not Saved!', 'We\'re experiencing technical difficulties, please try again later.', 'error');
                        console.error(result);
                    }
                })
                .catch((error) => {
                    console.error(error.message);
                });
            }
        } catch (error) {
            console.error(error.message);
        }
    }

    //Added by Faraz for Shopping Selection functionality
    handleSaveLastShoppingSelection(){
        if(!this.isGuest){
            //Account__c: USER_ID,
            let inputParams = {
                Last_Product_ModelId__c: this.TrimId,
                Product_Subdivision__c: this.makeValue,
                Product_Identifier__c: this.vinValue,
            };
            console.log(' inputParams ', inputParams);
    
            saveLastShoppingSelection({dataAsObj: JSON.stringify(inputParams)})
            .then(result => {
                if(result && result == 'success'){
                    console.log('Result', result);
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
        }
    }
    //End

    handleClearAll(event) {
        let brandName = event.currentTarget.dataset.value;
        try {
            this.template.querySelectorAll('.saveVehicle').forEach(element => element.checked = false);
            this.createCookie('Make', '', 1); // Clear cookie first
            this.createCookie('Year', '', 1); // Clear cookie first
            this.createCookie('Model', '', 1); // Clear cookie first
            this.createCookie('Trim', '', 1); // Clear cookie first
            let productCmpName = '.Products',  yearCmpName = '.Year',  modeCmpName = '.Model', trimCmpName = '.Trim', vinCmpName = '.Vin';

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
             sessionStorage.setItem('selecteMyProductId','');
        } catch (error) {
            console.error(error.message);
        }
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

    setVINCookies(){
        if(this.divisionValue == 1 && this.vinValue != undefined){
            sessionStorage.setItem('HondaVin',this.vinValue);
        }else if(this.divisionValue == 2 && this.vinValue != undefined){
            sessionStorage.setItem('AcuraVin',this.vinValue);
        }
    }
}
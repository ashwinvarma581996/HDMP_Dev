/******************************************************************************* 
Name: MyProductListPage 
Created By : Deepak Mali
Business Unit: HDM
Created Date: 12 Feb 2021
Description: This MyProductListPage Component Handling My Products Adding. 
******************************************************************************* 
MODIFICATIONS – Date | Dev Name | User Story 
09-06-2022 | Faraz Ansari | HDMP-202

*******************************************************************************/ 
import { LightningElement, api,wire, track } from 'lwc';
import getVehicleYear from '@salesforce/apex/B2B_EconfigIntegration.getVehicleYear';
import getVehicleModel from '@salesforce/apex/B2B_EconfigIntegration.getVehicleModel';
import getVehicleTrim from '@salesforce/apex/B2B_EconfigIntegration.getVehicleTrim';
import callVinDecoderService from '@salesforce/apex/B2B_EconfigIntegration.callVinDecoderService';
import getVehicleDetailsForAccessories from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetailsForAccessories';
import saveToMyProduct from '@salesforce/apex/B2B_MySavedProduct.saveToMyProduct';
import updateMyProduct from '@salesforce/apex/B2B_MySavedProduct.updateMyProduct';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MyProductModalBox extends LightningElement {
    @api vehicleData;
    @track yearId;
    @track trimId;
    @track modelId;
    @track trimValue
    @track yearValue;
    @track modelValue;
    @track hondaVehicleData;
    @track yearOptions = [];
    @track modelOptions = [];
    @track trimOptions = [];
    @track showModalBox = true;
    @track isLoaded = false;
    @track isLoading = false;
    @track editMyProduct = false;
    @track divisionValue = 1; // defaut as honda
    @track makeValue = 'Honda';
    @track modalTitle = 'Add New';
    @track editAndCreateButtonLabel = 'ADD NEW';
    @track modelIdForUpdate = '';
    @track mfgColorCode = '';

    connectedCallback() {
        if (this.vehicleData && this.vehicleData.length > 0) {
            this.loadDataForEdit(this.vehicleData);
            this.editMyProduct = true;
            this.editAndCreateButtonLabel = 'SAVE CHANGES';
            this.modalTitle = 'Edit Product';
        }
    }

    get productTypeOptions() {
        return [
            { label: 'Honda Car', value: 'Honda' },
            { label: 'Acura Car', value: 'Acura' }
        ];
    }

    @wire(getVehicleYear, {division: '$divisionValue'})
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
            this.showNotification('Years not found!', 'We\'re experiencing technical difficulties, please try again later.', 'error');
            this.yearOptions = [];
        }
    }

    handleProductTypeOptions(event) {
        let selectedValue = event.currentTarget.value;
        this.clearYMT();
        this.clearVINNumber();
        this.template.querySelector('.Year').disabled = false;
        this.template.querySelector('.Vin').disabled = false;
        this.template.querySelector('.Model').disabled = true;
        this.template.querySelector('.Trim').disabled = true;
        if (selectedValue && selectedValue == 'Acura') {
            this.divisionValue = 2;
            this.makeValue = 'Acura';
        } else {
            this.divisionValue = 1;
            this.makeValue = 'Honda';
        }
    }

    // this method will call when user select the year
    handleYearChange(event) {
        this.clearVINNumber();
        let yearCmp = this.template.querySelector('.Year');
        let yearObj = yearCmp.options.find(item => item.value == yearCmp.value);
        this.yearValue = yearObj.label;
        this.yearId = yearCmp.value; // main
        let modelCmp = this.template.querySelector('.Model');
        modelCmp.value = '';
        this.modelValue = '';
        modelCmp.disabled = true;
        modelCmp.setCustomValidity("");
        modelCmp.reportValidity();
        modelCmp.disabled = false;
        let trimCmp = this.template.querySelector('.Trim');
        trimCmp.value = '';
        this.trimValue = '';
        trimCmp.disabled = true;
        trimCmp.setCustomValidity("");
        trimCmp.reportValidity();
        this.getModelOptions(this.divisionValue, this.yearId);
    }

    // this method will call when user select the model
    handleModelChange(event) {
        this.clearVINNumber();
        let modelCmp = this.template.querySelector('.Model');
        this.modelId = modelCmp.value;
        let modelObj = modelCmp.options.find(item => item.value == this.modelId);
        this.modelValue = modelObj.label;
        let trimName = '.Trim';
        let trimCmp = this.template.querySelector(trimName);
        trimCmp.value = '';
        this.trimValue = '';
        trimCmp.disabled = true;
        trimCmp.setCustomValidity("");
        trimCmp.reportValidity();
        trimCmp.disabled = false;
        this.getTrimOptions(this.divisionValue, this.yearId, this.modelValue.toString());
    }

    // this method will call when user select the trim
    handleTrimChange(event) {
        this.clearVINNumber();
        let name = '.' + event.currentTarget.name;
        let trimCmp = this.template.querySelector(name);
        this.trimId = trimCmp.value;
        let trimObj = trimCmp.options.find(item => item.value == this.trimId);
        this.trimValue = trimObj.label;
    }

    handleVinChange(event) {
        try {
            this.clearYMT();
            this.hasErrorFromAPI = false;
            let vinCmpName = '.' + event.currentTarget.name;
            this.vinValue = event.detail.value;
            let vinCmp = this.template.querySelector(vinCmpName);
            if (this.vinValue.length == 0 || this.vinValue == '') {
                let yearCmpName = '.Year', modeCmpName = '.Model', trimCmpName = '.Trim';
                this.template.querySelector(yearCmpName).value = '';
                this.template.querySelector(modeCmpName).value = '';
                this.template.querySelector(trimCmpName).value = '';
                if(this.modalTitle != 'Edit Product'){
                    this.template.querySelector(yearCmpName).disabled = false;
                }
                this.template.querySelector(yearCmpName).options = this.yearOptions;
                this.yearValue = 0;
                this.modelValue = 0;
                this.trimValue = 0;
                vinCmp.setCustomValidity("");
                this.clearVinData();
                if (this.vehicleData && this.vehicleData.length > 0) {
                    this.loadDataForEdit(this.vehicleData);
                }
            }
            let format = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;
            if ((this.vinValue.length > 0 && format.test(this.vinValue) == true) || this.vinValue.length > 17) {
                vinCmp.setCustomValidity("Please enter valid VIN");
                this.isLoaded = false;
            } else {
                vinCmp.setCustomValidity("");
            }
            if (this.vinValue.length == 17 || this.vinValue.length == 10) {
                this.isLoaded = true;
                // this method handle to populate YMT 
                this.getModelByEconfigVIN(vinCmp);
            }
            vinCmp.reportValidity();
        } catch (error) {
            console.log('OUTPUT : ',error);
        }
    }

    handleVINKeyPress(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        if (charCode == 13 && this.trimValue && this.trimValue.length > 0) {
            //The VIN field should not be editable while the search is executing
            let vinCmp = this.template.querySelector('.Vin1');
            vinCmp.disabled = true;
            this.isLoaded = true; //Added by deepak mali 27 Aug 2021
        }
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
                console.log('error while getting model options', error);
                this.showNotification('Model not found!', 'We\'re experiencing technical difficulties, please try again later.', 'error');
            });
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
                    this.trimOptions = allTrimOptionList.sort((a, b) => (a.label > b.label) ? 1 : -1);
                }
            }).catch(error => {
                this.showNotification('Trim not found!', 'We\'re experiencing technical difficulties, please try again later.', 'error');
                console.log('Error : ', error);
            });
        }
    }

    getModelByEconfigVIN(vinCmp) {
        callVinDecoderService({ vinNumber: this.vinValue, poiType: (this.makeValue && this.makeValue == 'Honda' ? 'A' : 'B') }).then(result => {
            let displayData = JSON.parse(result);
            if(displayData.isError && displayData.message && displayData.message.includes('API calling issue')){
                this.showNotification('Error occured!', 'We\'re experiencing technical difficulties, please try again later.', 'error');
            }
            else if(displayData.isError || !displayData.selectorDetail.partsCatalog) {
                let errorMsg = '';
                if (displayData.message && displayData.message.toLowerCase().includes("unable to decode vin at this time")) {
                    errorMsg = 'We’re sorry, we are not able to determine your vehicle’s model information. Please use our model selector to search for products';
                }
                else if (displayData.message && (displayData.message.toLowerCase().includes("invalid acura vin") || displayData.message.toLowerCase().includes("invalid honda vin") || displayData.message.toLowerCase().includes("model does not exist"))) {
                    errorMsg = this.divisionValue && this.divisionValue == 1 ? 'You\'ve entered an Acura VIN, please select the Acura menu to search for those items' : 'You\'ve entered a Honda VIN, please select the Honda menu to search for those items';
                }
                else if (displayData.message && (displayData.message.includes("Please fix VIN. If VIN valid, please contact support"))) {
                    errorMsg = 'We\'re sorry, we are not able to determine your vehicle\'s model. Please use the model selector to search for products';
                }
                else
                    errorMsg = 'Please enter valid VIN';
                vinCmp.setCustomValidity(errorMsg);
                vinCmp.reportValidity();
            } else {
                if(displayData.selectorDetail && displayData.selectorDetail.colors){
                    let colorDate = JSON.parse(displayData.selectorDetail.colors);
                    this.mfgColorCode = colorDate && colorDate.color && colorDate.color[1]['@mfg_color_cd'] ? colorDate.color[1]['@mfg_color_cd'] : '';
                }
                let modelId = displayData.selectorDetail.modelId;
                this.modelIdForUpdate = modelId.toString();
                getVehicleDetailsForAccessories({ modelId: modelId.toString() }).then(vecResult => {
                    if (vecResult) {
                        let vehicleMapResult = JSON.parse(vecResult);
                        let vehicleResult = JSON.parse(vehicleMapResult.vehicle);
                        if (this.divisionValue == 1)
                            this.hondaVehicleData = vehicleResult;
                        else
                            this.acuraVehicleData = vehicleResult;
                        vinCmp.setCustomValidity("");
                        let yearCmpName = '.Year';
                        let yearCmp = this.template.querySelector(yearCmpName);
                        yearCmp.options = this.yearOptions;
                        yearCmp.value = vehicleResult.iNYearID__c.toString();
                        if(this.modalTitle != 'Edit Product'){
                            yearCmp.disabled = false;
                        }
                        this.yearValue = vehicleResult.Year__c;
                        this.yearId = vehicleResult.iNYearID__c;
                        let modelCmpName = '.Model';
                        let modelCmp = this.template.querySelector(modelCmpName);
                        let modelOptionAll = [];
                        let parseDataModel = JSON.parse(vehicleMapResult.vehicleModels);
                        for (const [key, value] of Object.entries(parseDataModel)) {
                            modelOptionAll.push({ label: key, value: value });
                        }
                        let modelOption = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);
                        modelCmp.options = modelOption;
                        let vehicleModelId = modelOption.find(item => item.label == vehicleResult.Model__c).value;
                        modelCmp.value = vehicleModelId.toString();
                        if(this.modalTitle != 'Edit Product'){
                            modelCmp.disabled = false;
                        }
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
                        // trimCmp.value = vehicleResult.iNGradeID__c.toString();
                        if(this.modalTitle != 'Edit Product'){
                            trimCmp.disabled = false;
                        }
                        //Added by Shalini soni 29 Sept 
                        this.trimId = vehicleResult.Model_Id__c.toString();
                        //this.trimId = vehicleResult.iNGradeID__c.toString();
                        this.trimValue = vehicleResult.Trim__c;
                        this.trimOptions = trimOptions;
                        sessionStorage.setItem('partsCatalog', displayData.selectorDetail.partsCatalog);
                        //Remove hdie class which is added in handleVinChange HDMP-3638             
                        // this.template.querySelector(searchButton).classList.remove('slds-hide');
                    }
                }).catch(error => {
                    console.log('Error : ', error);
                    this.showOrHideSearchButton = false;
                    this.isLoaded = false;
                    if (error && error.body && error.body.message && error.body.message.includes('List has no rows for assignment to SObject')) {
                        vinCmp.setCustomValidity("Please enter valid VIN ");
                        vinCmp.reportValidity();
                    }
                });
            }
            this.showOrHideSearchButton = false;
            this.isLoaded = false;
            //vinCmp.disabled = false;
        }).catch(error => {
            console.log('Error : ', error);
            this.error = error;
            this.showOrHideSearchButton = false;
            this.isLoaded = false;
            //vinCmp.disabled = false;
        })
    }

    handleToCreateAndUpdate(event) {
        try {
            this.isLoaded = true;
            if (this.editMyProduct == false) {
                let productCmpName = this.template.querySelector('.product');
                let vehicleNameCmp = this.template.querySelector('.vehicleName');
                if (!(productCmpName && this.yearValue && this.modelValue && this.trimValue)) {
                    this.showNotification('Error', 'Please select either year, model and trim or enter valid vin ', 'error');
                    this.isLoaded = false;
                    return;
                }
                let name = vehicleNameCmp.value;
                if(name.length == 0){
                    name = this.yearValue +' '+ this.modelValue;
                    let subVinValue = '';
                    if(this.vinValue.length){
                        subVinValue = this.vinValue.substring(this.vinValue.length - 6);
                        name += ' '+ this.trimValue + ' '+ subVinValue;
                    }else{
                        name += ' '+ this.trimValue;
                    }
                }
                vehicleNameCmp.setCustomValidity("");
                saveToMyProduct({vin: this.vinValue, trimModelId: this.trimId, nickname: name, mnfgColorCode: this.mfgColorCode})
                .then((result) => {
                    if (result == 'Success') {
                        this.dispatchEvent(new CustomEvent('closemodalbox', {}));
                        this.showNotification(result, 'Saved to My Product Successfully', 'success');
                        window.location.reload();
                    }else if(result == 'Already Exists'){
                        let msg = this.vinValue.length ? 'A product with this VIN already exists in My Products.' : 'A product with this model already exists in My Products.';
                        this.showNotification(result, msg, 'info');
                    }else{
                        this.showNotification('Record not Saved!', 'We\'re experiencing technical difficulties, please try again later.', 'error');
                    }
                })
                .catch((error) => {
                    console.log('Error : ',error);
                })
                .finally(() => {
                    this.isLoaded = false;
                });
            } else if (this.editMyProduct == true) {
                let productCmpName = this.template.querySelector('.product');
                let vehicleNameCmp = this.template.querySelector('.vehicleName');
                let vehicle = JSON.parse(this.vehicleData);
                if (!(productCmpName.value && this.yearValue && this.modelValue && this.trimValue)) {
                    this.showNotification('Error', 'Please select either year, model and trim or enter valid vin ', 'error');
                    this.isLoaded = false;
                    return;
                }
                let name = vehicleNameCmp.value ? vehicleNameCmp.value : '';
                if(name.length == 0){
                    name = this.yearValue +' '+ this.modelValue;
                    let subVinValue = '';                    
                    if(this.vinValue && this.vinValue.length){
                        subVinValue = this.vinValue.substring(this.vinValue.length - 6);
                        name += ' '+ this.trimValue + ' '+ subVinValue;
                    }else{
                        name += ' '+ this.trimValue;
                    }       
                }
                updateMyProduct({recordId: vehicle.recordId, nickname: name, vin: this.vinValue, trimModelId: this.modelIdForUpdate, mnfgColorCode: this.mfgColorCode})
                .then(result => {
                    // Display fresh data in the form
                    if(result == 'Success'){
                        this.setUpdatedYMT();
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Vehicle updated',
                                variant: 'success'
                            })
                        );
                        this.dispatchEvent(new CustomEvent('closemodalbox', { detail: true }));
                        window.location.reload();
                    }else if(result == 'Already Exists'){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: result,
                                message: 'A product with this VIN already exists in My Products.',
                                variant: 'info'
                            })
                        );
                    }else{
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error while Updating record',
                                message: 'We\'re experiencing technical difficulties, please try again later.',
                                variant: 'error'
                            })
                        );
                    }
                })
                .catch(error => {
                    console.log('Error : ',error)
                })
                .finally(() => {
                    this.isLoaded = false;
                });
            }
        } catch (error) {
            console.log('Error : ',error);
        }
    }

    clearVINNumber() {
        let vinCmp = this.template.querySelector('.Vin');
        vinCmp.setCustomValidity("");
        vinCmp.reportValidity();
        vinCmp.value = ''
        this.vinValue = '';
    }

    clearVinData() {   
        let yearCmpName = '.Year', modeCmpName = '.Model', trimCmpName = '.Trim';
        this.template.querySelector(yearCmpName).value = '';
        this.template.querySelector(modeCmpName).value = '';
        this.template.querySelector(trimCmpName).value = '';
        if(this.modalTitle != 'Edit Product'){
            this.template.querySelector(yearCmpName).disabled = false;
        }
        this.template.querySelector(modeCmpName).disabled = true;
        this.template.querySelector(trimCmpName).disabled = true;
        if (this.divisionValue == 1) {         
        } else if (this.divisionValue == 2) {            
        }
        this.yearValue = 0;
        this.modelValue = 0;
        this.trimValue = 0;
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
        this.trimId = '';
        this.trimValue = '';
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    closeChangeModalPopUp(event) {
        this.dispatchEvent(new CustomEvent('closemodalbox', { 'reload': false }));
    }

    loadDataForEdit(vehicleData) {
        this.isLoading = true;
        let vehicle = JSON.parse(vehicleData);
        let productModelId = vehicle.productModelId;
        //Added by deepak mali HDMP-7956
        this.makeValue = vehicle.productType;
        this.divisionValue = vehicle.productType == 'Honda' ? 1 : 2;
        //END
        getVehicleDetailsForAccessories({ modelId: productModelId}).then(vecResult => {
            if (vecResult) {
                let vehicleMapResult = JSON.parse(vecResult);
                let productCmp = this.template.querySelector('.product');
                let vehicleResult = JSON.parse(vehicleMapResult.vehicle);
                productCmp.value = vehicle.productType;
                productCmp.disabled = true;
                this.yearValue = vehicle.yearValue;
                this.modelValue =  vehicleResult.Model__c;
                this.trimValue = vehicleResult.Trim__c;
                let vehicleNameCmp = this.template.querySelector('.vehicleName');
                vehicleNameCmp.value = vehicle.Name;
                //for years  
                let yearCmpName = '.Year';
                let yearCmp = this.template.querySelector(yearCmpName);
                yearCmp.options = this.yearOptions;  //yearOptions;
                yearCmp.value = vehicleResult.iNYearID__c.toString();
                this.yearId = vehicleResult.iNYearID__c.toString();
                //yearCmp.disabled = false;
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
                //modelCmp.disabled = false;
                this.modelOptions = modelOptions;
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
                trimCmp.value = vehicleResult.Model_Id__c.toString();
                //trimCmp.disabled = false;
                this.trimOptions = trimOptions;
                let vinCmp = this.template.querySelector('.Vin');
                vinCmp.value = vehicle.vinValue;
                if (vehicle && !vehicle.vinValue){
                    this.template.querySelector('.Vin').disabled = false;
                }
            }
        }).catch(error => {
            console.log('Error : ', error);
        }).finally(() => this.isLoading = false);
    }

    setUpdatedYMT() {
        let newYearId, newYearValue, newModelId, newModelValue, newTrimId, newTrimValue;
        newYearValue = this.yearValue;
        newModelValue = this.modelValue;
        newTrimValue = this.trimValue;
        newYearId = this.yearOptions.find(item => item.label == this.yearValue).value;
        newModelId = this.modelOptions.find(item => item.label == this.modelValue).value;
        newTrimId = this.trimOptions.find(item => item.label == this.trimValue).value;
        this.createCookie('Year', newYearValue, 1);
        this.createCookie('Model', newModelId, 1);
        this.createCookie('Trim', newTrimValue, 1);
        this.createCookie('Division', this.divisionValue, 1);
        sessionStorage.setItem('division', this.divisionValue);
        //it used to handle to set default my product into MegaMenu in MyProduct List
        let vehicle = JSON.parse(this.vehicleData);
        //sessionStorage.setItem('selecteMyProductId', vehicle.recordId);
        if (this.divisionValue == 1) {
            sessionStorage.setItem('HondaYearId', newYearId);
            sessionStorage.setItem('HondaYearValue', newYearValue);
            sessionStorage.setItem('HondaModelId', newModelId);
            sessionStorage.setItem('HondaModelValue', newModelValue);
            sessionStorage.setItem('HondaTrimId', newTrimId);
            sessionStorage.setItem('HondaTrimValue', newTrimValue);
            sessionStorage.setItem('ModelOptionHonda', JSON.stringify(this.modelOptions));
            sessionStorage.setItem('TrimOptionHonda', JSON.stringify(this.trimOptions));
            sessionStorage.setItem('isSubmited', true);
            this.createCookie('Make', 'Honda', 1);
            sessionStorage.setItem('brand', 'Honda');
            sessionStorage.setItem('mainHeaderSearched', true);
        } else if (this.divisionValue == 2) {
            sessionStorage.setItem('AcuraYearId', newYearId);
            sessionStorage.setItem('AcuraYearValue', newYearValue);
            sessionStorage.setItem('AcuraModelId', newModelId);
            sessionStorage.setItem('AcuraModelValue', newModelValue);
            sessionStorage.setItem('AcuraTrimId', newTrimId);
            sessionStorage.setItem('AcuraTrimValue', newTrimValue);
            sessionStorage.setItem('ModelOptionAcura', JSON.stringify(this.modelOptions));
            sessionStorage.setItem('TrimOptionAcura', JSON.stringify(this.trimOptions));
            sessionStorage.setItem('isSubmited', true);
            sessionStorage.setItem('mainHeaderSearched', true);
            this.createCookie('Acura', 'Honda', 1);
            sessionStorage.setItem('brand', 'Acura');
        }
    }

    // Common method to creating Cookie Value
    createCookie(name, value, days) {
        var expires;
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 100));
            expires = ";expires=" + date.toGMTString();
        } else {
            expires = "";
        }
        // Updated by Pradeep Singh for Optiv Issue
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
        //ends here
    }
    // Common method to get Cookie Value

    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);
    }
}
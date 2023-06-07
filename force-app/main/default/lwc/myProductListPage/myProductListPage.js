/******************************************************************************* 
Name: MyProductListPage 
Created By : Deepak Mali
Business Unit: HDM
Created Date: 12 Feb 2021
Description: This MyProductListPage Component Handling My Products Adding, Removing and Shopping Functionallty. 
******************************************************************************* 
MODIFICATIONS – Date | Dev Name | User Story 
09-06-2022 | Faraz Ansari | HDMP-202

*******************************************************************************/ 
import { LightningElement, track, wire } from 'lwc';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';
import getMyProductList from '@salesforce/apex/B2B_MySavedProduct.getMyProductList';
//import getProductModelColors from '@salesforce/apex/B2B_MySavedProduct.getProductModelColors';
import deleteMyProduct from '@salesforce/apex/B2B_MySavedProduct.deleteMyProduct';
import getVehicleYear from '@salesforce/apex/B2B_EconfigIntegration.getVehicleYear';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVehicleDetailsForAccessories from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetailsForAccessories';
import saveLastShoppingSelection from '@salesforce/apex/B2B_ShoppingSelectionController.saveLastShoppingSelection';
import Acura_Image_Prefix from '@salesforce/label/c.Acura_Image_Prefix';
import Honda_Image_Prefix from '@salesforce/label/c.Honda_Image_Prefix';

import USER_ID from '@salesforce/user/Id';

export default class MyProductListPage extends LightningElement {
    @track tempImage = imageResourcePath + '/dreamshop.png';
    @track showModaxBox = false;
    @track myProductList;
    @track wireResultData;
    @track hasData = false;
    @track isLoading = false;
    @track isDataFetch = false;
    @track isGuest = false;
    @track yearOptions = [];
    @track modelOptions = [];
    @track trimOptions = [];
    @track divisionValue = 1; // defaut as honda
    @track brandHondaURL = '/s/honda';
    @track brandAcuraURL = '/s/acura';
    @track editvehicleData = {};
    @track myAllProductList = [];
    hondaLogoSrc =  '/resource/MyGarage/img/thumbnail_honda.png';
    acuraLogoSrc = '/resource/MyGarage/img/thumbnail_acura.png';
    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s/"));
    acuraImagePrefix = Acura_Image_Prefix;
    hondaImagePrefix = Honda_Image_Prefix;

    @wire(getVehicleYear, { division: '$divisionValue' })
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
            this.yearOptions = [];
        }
    }
   
    @wire(getMyProductList)
    myProdcutListFromApex(result) {
        try {
            this.isLoading = true;
            this.myAllProductList = [];
            if (result.data) {
                // console.log('$MPLP: result.data: ',result.data);
                this.wireResultData = result;
                this.isDataFetch = true;
                if (result && result.data.length > 0 && USER_ID != undefined) {
                    let brandName = sessionStorage.getItem('dealerSiteBrand');
                    this.hasData = true;
                    if (result.data) {
                        /* result = JSON.parse(JSON.stringify(result));
                        console.log('$MPLP: result1: ',result);
                        let pArray = [];
                        let productModelsArray = [];
                        result.data.forEach(element => {
                            if(element.Honda_Product__r.Product_Models__r.Product_Division__c == 'A' || element.Honda_Product__r.Product_Models__r.Product_Division__c == 'B'){
                                pArray.push(element);
                            }
                            if(element.Honda_Product__r && !element.Honda_Product__r.Product_Model_Color__r && (element.Honda_Product__r.Product_Models__r.Product_Division__c == 'A' || element.Honda_Product__r.Product_Models__r.Product_Division__c == 'B')){
                                productModelsArray.push(element.Honda_Product__r.Product_Models__c);
                            }
                        });
                        getProductModelColors({productModelIdsSet: productModelsArray}).then((res) => {
                            let map = new map(Object.entries(res));
                            result.data.forEach(element => {
                                if(element.Honda_Product__r && !element.Honda_Product__r.Product_Model_Color__r && (element.Honda_Product__r.Product_Models__r.Product_Division__c == 'A' || element.Honda_Product__r.Product_Models__r.Product_Division__c == 'B')){
                                    if(res.hasOwnProperty(element.Honda_Product__r.Product_Models__c)){
                                        element.Honda_Product__r.Product_Model_Color__c = res[element.Honda_Product__r.Product_Models__c].Id;
                                        element.Honda_Product__r.Product_Model_Color__r = res[element.Honda_Product__r.Product_Models__c];
                                    }
                                }
                            }); */
                            let hondaList = [];
                            let acuraList = [];
                            result.data.forEach(element => {
                                let removable = true;//element.Ownership_Origination__c && element.Ownership_Origination__c == '23' ? true : false;
                                let hideShopButton = brandName == 'Honda' ? false : true;
                                let productImageURL = '';
                                if(element.Honda_Product__r.Product_Model_Color__r && element.Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c && !element.Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c.includes('/null')){
                                    productImageURL = element.Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c;
                                }else if(element.Honda_Product__r.Product_Models__r && element.Honda_Product__r.Product_Models__r.Default_Large_Image_Url__c){
                                    let url = element.Honda_Product__r.Product_Models__r.Default_Large_Image_Url__c;
                                    if(url.startsWith('https') == false){
                                        if(element.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Honda'){
                                            productImageURL = this.hondaImagePrefix + url;
                                        }else if(element.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Acura'){
                                            productImageURL = this.acuraImagePrefix + url;
                                        }
                                    }
                                }else{
                                    if(element.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Honda'){
                                        productImageURL = this.baseURL + this.hondaLogoSrc;
                                    }else if(element.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Acura'){
                                        productImageURL = this.baseURL + this.acuraLogoSrc;
                                    }
                                }
                                if (element.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Honda') {
                                    hondaList.push({...element, 'productImageURL': productImageURL, 'removable': removable, 'hideShopButton': brandName ? hideShopButton : false});
                                } else if (element.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Acura') {
                                    acuraList.push({...element, 'productImageURL': productImageURL, 'removable': removable, 'hideShopButton': brandName ? !hideShopButton: false});
                                }
                            });
                            let showHonda = hondaList.length >0 ? true : false;
                            let showAcura = acuraList.length >0 ? true : false;
                            this.myAllProductList.push({ brandName: 'Honda', productList: hondaList , showBrand: showHonda});
                            this.myAllProductList.push({ brandName: 'Acura', productList: acuraList , showBrand: showAcura});

                        /* }).catch((err) => {
                            console.error('$MPLP: err: ',err);
                        }); */
                    }
                    this.myProductList = result.data;
                } else {
                    this.hasData = false;
                }
            } else if (result.error) {
                this.isDataFetch = true;
            }
            this.isLoading = false;
        } catch (error) {
            console.error('Error : ',error.message);
        }
    }

    connectedCallback(){
        if(USER_ID == undefined || USER_ID == null){
            this.isGuest = true;
        }
    }

    // This method is handle to remove my product record from
    handleRemoveMyProduct(event) {
        let myProductId = event.currentTarget.dataset.id;
        let originationValue = event.currentTarget.dataset.origination;
        if(originationValue && originationValue == '23'){
            this.isLoading = true;
            //deleteRecord(myProductId)
            deleteMyProduct({ recordId: myProductId })
            .then(result => {
                if(result == 'Success'){
                    this.showToastMessage('Record is Deleted!', 'Item removed Successfully.', 'success');
                    refreshApex(this.wireResultData);
                    window.location.reload();
                }
            })
            .catch(error => {
                console.log('Error : ',error);
                this.showToastMessage('Record not Deleted!', 'We\'re experiencing technical difficulties, please try again later.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
        }else{
            this.showToastMessage('Record not Deleted!', 'The product cannot be removed from here, Kindly remove the product from MyGarage.', 'error');
        }
    }
    
    // Handle to open Add Product Modal Box
    handleToAddProduct() {
        this.editvehicleData = {};
        this.showModaxBox = true;
    }

    // Handle redirect to brand page on basis on honda or acura product
    async handleToShop(event) {
        let productid = event.currentTarget.dataset.productid;
        let record = this.myProductList.find(item => item.Id == productid);
        if (record.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Honda') {
            this.divisionValue = 1;
        } else if (record.Honda_Product__r.Product_Models__r.Product_Subdivision__c == 'Acura') {
            this.divisionValue = 2;
        }
        this.clearCookiesData(); // Clear all old data in cookies
        let newYearId, newYearValue, newModelId, newModelValue, newTrimId, newTrimValue, selectedVehicleDB;
        let productModelId = record.Honda_Product__r.Product_Models__r.Product_Model_ID__c;
        await getVehicleDetailsForAccessories({ modelId: productModelId}).then(vecResult => {
            if (vecResult) {
                let vehicleMapResult = JSON.parse(vecResult);
                selectedVehicleDB = JSON.parse(vehicleMapResult.vehicle);
                let modelOptionAll = [];
                let parseDataModel = JSON.parse(vehicleMapResult.vehicleModels);
                for (const [key, value] of Object.entries(parseDataModel)) {
                    modelOptionAll.push({
                        label: key,
                        value: value
                    })
                }
                let modelOptions = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);
                this.modelOptions = modelOptions;
                let parseDataTrim = JSON.parse(vehicleMapResult.vehicleTrims);
                let allTrimOptions = [];
                for (const [key, value] of Object.entries(parseDataTrim)) {
                    allTrimOptions.push({
                        label: key,
                        value: value
                    })
                }
                let trimOptions = allTrimOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                this.trimOptions = trimOptions;
            }
        }).catch(error => {
            console.error('Error : ', error);
        });
        newYearId = this.yearOptions.find(item => item.label == record.Honda_Product__r.Product_Models__r.Model_Year__c).value;
        newYearValue = record.Honda_Product__r.Product_Models__r.Model_Year__c;
        let modalCmp = this.modelOptions.find(item => item.label == selectedVehicleDB.Model__c);
        newModelId = modalCmp.value;
        newModelValue = modalCmp.label;
        let TrimCmp = this.trimOptions.find(item => item.label == selectedVehicleDB.Trim__c);
        newTrimValue = TrimCmp.label;
        newTrimId = TrimCmp.value;

        //Creating cookies to set default value on MegaMenu and Change Vehicle Year,Modal,Trim
        this.createCookie('Year', newYearValue, 1);
        this.createCookie('Model', newModelId, 1);
        this.createCookie('Trim', newTrimValue, 1);
        this.createCookie('Division', this.divisionValue, 1);
        sessionStorage.setItem('division',this.divisionValue);
        //it used to handle to set default my product into MegaMenu in MyProduct List
        sessionStorage.setItem('selecteMyProductId', productid);
        let vinValue = record.Honda_Product__r.Product_Identifier__c ? record.Honda_Product__r.Product_Identifier__c : '';
        let inputParams = {
            Last_Product_ModelId__c: productModelId,
            Product_Subdivision__c: record.Honda_Product__r.Product_Models__r.Product_Subdivision__c,
            Product_Identifier__c: vinValue,
        };
        saveLastShoppingSelection({dataAsObj: JSON.stringify(inputParams)})
        .then(result => {
            if(result && result == 'success'){
                console.log('Result', result);
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
        if (this.divisionValue == 1) {
            sessionStorage.setItem('HondaYearId', newYearId);
            sessionStorage.setItem('HondaYearValue', newYearValue);
            sessionStorage.setItem('HondaModelId', newModelId);
            sessionStorage.setItem('HondaModelValue', newModelValue);
            sessionStorage.setItem('HondaTrimId', newTrimId);
            sessionStorage.setItem('HondaTrimValue', newTrimValue);
            sessionStorage.setItem('HondaVin',vinValue);
            sessionStorage.setItem('ModelOptionHonda', JSON.stringify(this.modelOptions));
            sessionStorage.setItem('TrimOptionHonda', JSON.stringify(this.trimOptions));
            sessionStorage.setItem('isSubmited', true);
            this.createCookie('Make', 'Honda', 1);
            sessionStorage.setItem('brand', 'Honda');
            sessionStorage.setItem('mainHeaderSearched', true);
            // In this method we setting button vehicle label 
            this.buildEffectiveVehicle('Honda', newYearValue, newModelValue, newTrimValue, '', 'Parts', 'Honda');
            // We are redirecting on brand page on the bases on product type
            window.open(this.brandHondaURL, '_self');
        } else if (this.divisionValue == 2) {
            sessionStorage.setItem('AcuraYearId', newYearId);
            sessionStorage.setItem('AcuraYearValue', newYearValue);
            sessionStorage.setItem('AcuraModelId', newModelId);
            sessionStorage.setItem('AcuraModelValue', newModelValue);
            sessionStorage.setItem('AcuraTrimId', newTrimId);
            sessionStorage.setItem('AcuraTrimValue', newTrimValue);
            sessionStorage.setItem('AcuraVin',vinValue);
            sessionStorage.setItem('ModelOptionAcura', JSON.stringify(this.modelOptions));
            sessionStorage.setItem('TrimOptionAcura', JSON.stringify(this.trimOptions));
            sessionStorage.setItem('isSubmited', true);
            sessionStorage.setItem('mainHeaderSearched', true);
            this.createCookie('Acura', 'Honda', 1);
            sessionStorage.setItem('brand', 'Acura');
            // In this method we setting button vehicle label
            this.buildEffectiveVehicle('Acura', newYearValue, newModelValue, newTrimValue, '', 'Parts', 'Acura');
            // We are redirecting on brand page on the bases on product type
            window.open(this.brandAcuraURL, '_self');
        }
    }

    clearCookiesData(){
        this.createCookie('Make', '', 1); // Clear cookie first
        this.createCookie('Year', '', 1); // Clear cookie first
        this.createCookie('Model', '', 1); // Clear cookie first
        this.createCookie('Trim', '', 1); // Clear cookie first
        sessionStorage.setItem('HondaYearId', '');
        sessionStorage.setItem('HondaYearValue', '');
        sessionStorage.setItem('HondaModelId', '');
        sessionStorage.setItem('HondaModelValue', '');
        sessionStorage.setItem('HondaTrimId', '');
        sessionStorage.setItem('HondaTrimValue', '');
        sessionStorage.setItem('ModelOptionHonda', '');
        sessionStorage.setItem('TrimOptionHonda', '');
        sessionStorage.setItem('AcuraYearId','');
        sessionStorage.setItem('AcuraYearValue','');
        sessionStorage.setItem('AcuraModelId','');
        sessionStorage.setItem('AcuraModelValue','');
        sessionStorage.setItem('AcuraTrimId','');
        sessionStorage.setItem('AcuraTrimValue','');
        sessionStorage.setItem('ModelOptionAcura','');
        sessionStorage.setItem('TrimOptionAcura','');
    }

    // Handle to Close Modal Boxs
    closeModalBoxPopup() {
        refreshApex(this.wireResultData);
        this.showModaxBox = false;
    }

    // Common Method to Show Toast Message
    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // Building Effective Vehicle for megaMenu and Change Vehicle Modal Box
    buildEffectiveVehicle(Make, Year, Model, Trim, Vin, ProductType, brandName) {
        sessionStorage.setItem('brand', brandName);
        let make = Make;
        let year = Year;
        let model = Model;
        let trim = Trim;
        let vin = Vin;
        let productType = ProductType;
        let brand = brandName;
        let brands = [];
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
                        element.brand = brand;
                        element.productType = productType;
                        hasExist = true;
                    }
                });
            }
            if (!hasExist) {
                brands.push({ 'brand': brand, 'make': make, 'year': year, 'model': model, 'trim': trim, 'productType': productType, 'vin': vin });
            }
        } else {
            brands.push({ 'brand': brand, 'make': make, 'year': year, 'model': model, 'trim': trim, 'productType': productType, 'vin': vin });
        }
        localStorage.setItem("effectiveVehicle", JSON.stringify({ 'brands': brands }));
    }

    editMyProductRecord(event){
        let myProductId = event.currentTarget.dataset.productid;
        this.showModaxBox = true;
        let record = this.myProductList.find(item => item.Id == myProductId);
        let vehicleRecord = {
            'Name': record.Nickname__c,
            'productType': record.Honda_Product__r.Product_Models__r.Product_Subdivision__c,
            'yearValue': record.Honda_Product__r.Product_Models__r.Model_Year__c,
            'modalValue': record.Honda_Product__r.Product_Models__r.Model_Name__c,
            'trimValue': record.Honda_Product__r.Product_Models__r.Trim__c,
            'vinValue': record.Honda_Product__r.Product_Identifier__c,
            'recordId': record.Id,
            'productModelId': record.Honda_Product__r.Product_Models__r.Product_Model_ID__c
        }
        this.editvehicleData = JSON.stringify(vehicleRecord);
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
        //updated by Pradeep Singh for Optive Issue
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
        // ends here
    }

    // Common method to get Cookie Value
    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);
    }
}
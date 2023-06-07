import { LightningElement, track } from 'lwc';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';
//motocompacto starts
import getVehicleDetails from '@salesforce/apex/B2B_EconfigIntegration.getVehicleOptionsForHomepage';
import { getCompleteDetails } from 'c/utils';
import storeImages from '@salesforce/resourceUrl/StoreImages';
import MotocompactoImage from '@salesforce/resourceUrl/MotocompactoImage';
import MOTOCOMPACTO_GOOGLE_STORE_URL from '@salesforce/label/c.Motocompacto_Google_Store_URL';
import MOTOCOMPACTO_APPLE_STORE_URL from '@salesforce/label/c.Motocompacto_Apple_Store_URL';
import MOTOCOMPACTO_DESCRIPTION from '@salesforce/label/c.Motocompacto_Description';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//motocompacto ends

export default class AboutCar extends LightningElement {
    aboutUs3 = imageResourcePath + '/MY21_TLX_97_AllSeasonMat_Comp.jpg';
    aboutUs1 = imageResourcePath + '/MY21_Bro_RGL_05_12-10-20.jpg';
    aboutUs2 = imageResourcePath + '/Wheels_Tab_concrete_05.jpg';
    aboutUs = imageResourcePath + '/18001_6A4_protectionPkg_Main_01.jpg';
    aboutUs4 = imageResourcePath + '/MY21_TLX_Bro_01_08-20-20-Blue_car.jpg';
     

    @track brandHonda = true;
    @track brandAcura = true;

    //for motocompacto
    @track bothBrand = true;
    @track motocompactoDesc = MOTOCOMPACTO_DESCRIPTION;
    @track motoImage = MotocompactoImage;
    @track brandValue;
    @track selectedAccessories;
    @track productId;
    @track isLoading = false;
    @track year = '2024';
    @track model = 'Motocompacto';
    @track trim = 'Standard';
    @track modelOptions = [];
    @track trimOptions = [];

    @track appleStore = storeImages + '/StoreImages/applePlayStore.png';
    @track googleStore = storeImages + '/StoreImages/googlePlayStore.png';

    connectedCallback() {
        var currURL = window.location.href;
        //console.log('URL-->', currURL);
        var parts = currURL.split('/');
        var lastSegment = parts.pop() || parts.pop();
        this.brandValue = lastSegment;
        //console.log('last-->', lastSegment);
        if (lastSegment == 'honda') {
            this.brandAcura = false;
            this.brandHonda = true;
            this.bothBrand = false;
        }
        if (lastSegment == 'acura') {
            this.brandAcura = true;
            this.brandHonda = false;
            this.bothBrand = false;
        }
    }

    //Motocompacto starts   

    handleStoreImageClick(event){
        let name = event.target.name;
        if(name == 'apple store'){
            window.open(MOTOCOMPACTO_APPLE_STORE_URL, '_blank');
        }else if(name == 'google store'){
            window.open(MOTOCOMPACTO_GOOGLE_STORE_URL, '_blank');
        }
    }
    
    handleShopFromBrand(event){
        this.isLoading = true;
        let name = event.target.name;
        if(name == 'SHOP FROM HONDA'){
            this.getMotoVehicleDetails('Honda');
        }else if(name == 'SHOP FROM ACURA'){
            this.getMotoVehicleDetails('Acura');
        }
    }

    getMotoVehicleDetails(brand){
        getVehicleDetails({yearValue : Number(this.year), modelValue : this.model, trimValue : this.trim, division : brand == 'Honda' ? '1' : '2'}).then(result => {
            if(result){
                console.log('getVehicleDetails : ',result);
                //model options starts
                let parseDataModel = JSON.parse(result.modelOptions);
                let modelOptionAll = [];
                for (const [key, value] of Object.entries(parseDataModel)) {
                    modelOptionAll.push({
                        label: key,
                        value: value
                    })
                }
                let modelOption = modelOptionAll.sort((a, b) => (a.label > b.label) ? 1 : -1);
                this.modelOptions = modelOption;
                //model options ends

                //trim options starts
                let parseDataTrim = JSON.parse(result.trimOptions);
                let allTrimOptions = [];
                for (const [key, value] of Object.entries(parseDataTrim)) {
                    allTrimOptions.push({
                        label: key,
                        value: value
                    })
                }
                let trimOption = allTrimOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                this.trimOptions = trimOption;
                //trim options ends

                let vehicle = JSON.parse(result.objVehicle);
                this.createCookie('vehicle', JSON.stringify(vehicle), 1);
                sessionStorage.setItem('vehicle', JSON.stringify(vehicle));
                this.buildEffectiveVehicle('', brand);
                this.goToMotocompactoPDP(vehicle, brand);
            }           
        }).catch(error => {
            console.log('error : ',error);
            this.isLoading = false;
        });
    }

    buildEffectiveVehicle(categoryId, brand) {
        let year = this.year;
        let model = this.model;
        let trim = this.trim;
        let vin = '';
        let productType = 'Accessories';
        let brands = [];
        let vehicle = JSON.parse(sessionStorage.getItem('vehicle'));
        if (vehicle) {
            if (localStorage.getItem("effectiveVehicle")) {
                brands = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
                let hasExist = false;
                if (brands) {
                    brands.forEach(element => {
                        if (brand === element.brand) {
                            element.make = '';
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
                    brands.push({ 'brand': brand, 'make': '', 'year': year, 'model': model, 'trim': trim, 'productType': productType, 'vin': vin, 'categoryId': categoryId, 'Id': vehicle.Id, 'Model_Id__c': vehicle.Model_Id__c, 'iNCatalogID__c': vehicle.iNCatalogID__c, 'iNDivisionID__c': vehicle.iNDivisionID__c, 'iNDoorID__c': vehicle.iNDoorID__c, 'iNGradeID__c': vehicle.iNGradeID__c, 'iNModelID__c': vehicle.iNModelID__c, 'iNYearID__c': vehicle.iNYearID__c, 'iNTransmissionID__c': vehicle.iNTransmissionID__c });
                }
            } else {
                brands.push({ 'brand': brand, 'make': '', 'year': year, 'model': model, 'trim': trim, 'productType': productType, 'vin': vin, 'categoryId': categoryId, 'Id': vehicle.Id, 'Model_Id__c': vehicle.Model_Id__c, 'iNCatalogID__c': vehicle.iNCatalogID__c, 'iNDivisionID__c': vehicle.iNDivisionID__c, 'iNDoorID__c': vehicle.iNDoorID__c, 'iNGradeID__c': vehicle.iNGradeID__c, 'iNModelID__c': vehicle.iNModelID__c, 'iNYearID__c': vehicle.iNYearID__c, 'iNTransmissionID__c': vehicle.iNTransmissionID__c });
            }
        }
        localStorage.setItem("effectiveVehicle", JSON.stringify({ 'brands': brands }));
    }
    
    async goToMotocompactoPDP(vehicle, brand){       
        console.log('vehicle raj : ',vehicle);
        this.setSessionStorage(vehicle, brand);
        
        
        let breadcrumbsList = [];
        let obj = {'label' : brand, 'isCurrentPage' : false, 'href' : window.location.origin+'/s/'+brand.toLowerCase()};
        breadcrumbsList.push(obj);    
        
        let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
        breadcrumbsMap.set(brand, JSON.parse(JSON.stringify(breadcrumbsList)));      
        sessionStorage.setItem('breadcrumbsMap', JSON.stringify([...breadcrumbsMap]));

        let poiType = brand == 'Honda' ? 'A' : 'B';
        // calling getCompleteDetails from utils
        let productId = await getCompleteDetails(vehicle.Model_Id__c, poiType);
        console.log('product utils : ',productId);
        if(productId){
            window.location.href = '/s/product/' + productId;
        } else {
            this.showNotification('Error', 'We\'re experiencing technical difficulties, please try again later.', 'error');
        }
        this.isLoading = false;              
    }

    setSessionStorage(vehicle, brand){
        sessionStorage.setItem('isMotoCompacto', 'true');
        sessionStorage.setItem('brand', brand);
        sessionStorage.setItem('vehicleBrand', brand);
        sessionStorage.setItem('dealerSiteBrand', brand);
        sessionStorage.setItem('ProductType', 'Accessories');
        localStorage.setItem('cartBrand', brand);
        this.createCookie('Make', brand, 1);//For HDMP-18879
        this.createCookie('YearId', vehicle.iNYearID__c, 1);
        // for mega menu and select vehicle selection
        sessionStorage.setItem('isSubmited', true);
        let division = brand == 'Honda' ? 1 : 2;
        sessionStorage.setItem('division', division);
        sessionStorage.setItem('mainHeaderSearched', true);
        let brandProductMap = {};   
        if (division == 1) {
            brandProductMap.Honda = 'Accessories';
            sessionStorage.setItem('HondaYearId', vehicle.iNYearID__c);
            sessionStorage.setItem('HondaYearValue', vehicle.iNYearID__c);
            sessionStorage.setItem('HondaModelId', vehicle.Model_Id__c);
            sessionStorage.setItem('HondaModelValue', this.model);
            sessionStorage.setItem('HondaTrimId', vehicle.Model_Id__c);
            sessionStorage.setItem('HondaTrimValue', this.trim);            
            sessionStorage.setItem('ModelOptionHonda', JSON.stringify(this.modelOptions));
            sessionStorage.setItem('TrimOptionHonda', JSON.stringify(this.trimOptions));
        } else if (division == 2) {
            brandProductMap.Acura = 'Accessories';
            sessionStorage.setItem('AcuraYearId',vehicle.iNYearID__c);
            sessionStorage.setItem('AcuraYearValue', vehicle.iNYearID__c);
            sessionStorage.setItem('AcuraModelId', vehicle.Model_Id__c);
            sessionStorage.setItem('AcuraModelValue', this.model);
            sessionStorage.setItem('AcuraTrimId', vehicle.Model_Id__c);
            sessionStorage.setItem('AcuraTrimValue', this.trim);
            sessionStorage.setItem('ModelOptionAcura', JSON.stringify(this.modelOptions));
            sessionStorage.setItem('TrimOptionAcura', JSON.stringify(this.trimOptions));
        }
        sessionStorage.setItem('brandAndProductTypeMap', JSON.stringify(brandProductMap));
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

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    //Motocompacto ends
}
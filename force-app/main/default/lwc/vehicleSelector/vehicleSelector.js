import {LightningElement, track, wire, api} from 'lwc';
import callVinDecoderService from '@salesforce/apex/B2B_EconfigIntegration.callVinDecoderService';
import getCategoryId from '@salesforce/apex/B2B_VehicleSelectorController.getCategoryId';
import getVehicleYear from '@salesforce/apex/B2B_EconfigIntegration.getVehicleYear';
import getVehicleModel from '@salesforce/apex/B2B_EconfigIntegration.getVehicleModel';
import getVehicleTrim from '@salesforce/apex/B2B_EconfigIntegration.getVehicleTrim';
import getVehicleDoors from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDoors';
import { NavigationMixin } from 'lightning/navigation';
import communityId from '@salesforce/community/Id';
import getCartItemCategory from '@salesforce/apex/B2B_VehicleSelectorController.getCartItemCategory';
import unlockCart from '@salesforce/apex/B2BCartControllerSample.unlockCart';
import getMyShoppingSelectionRecords from '@salesforce/apex/B2B_ShoppingSelectionController.getMyShoppingSelectionRecords';
import getBrand from '@salesforce/apex/B2B_VehicleSelectorController.getBrand';
import isguest from '@salesforce/user/isGuest';
import pubsub  from 'c/pubsub';

export default class ModalPopupLWC extends NavigationMixin(LightningElement) {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track buttonTitle = "Select Vehicle";
    @track makeDisabled = false;
    @track yearDisabled = true;
    @track modelDisabled = true;
    @track trimDisabled = true;
    @track doorsDisabled = true;
    @track storedMake = "";
    @track storedYear = "";
    @track storedModel = "";
    @track storedTrim = "";
    @track storedDoors = "";
    @track boolVisible = true;
    @track makeOptions = [{
            label: 'Honda',
            value: 'Honda'
        },
        {
            label: 'Acura',
            value: 'Acura'
        },
    ];
    @track cartData=false;
    @track selectedOption = 'Parts';
    @track showParts = true;
    @track showAccessories = false;
    @track defaultSelect = true;
    @track yearOptions = [];
    @track modelOptions = [];
    @track trimOptions = [];
    @track doorsOptions = [];
    @track makeValue;
    @track yearValue;
    @track modelValue;
    @track trimValue;
    @track doorsValue;
    //@track yearOptions = [];
    //@track modelOptions = [];
    //@track trimOptions = [];
    @track categoryId = "";
    @track poihondavalue;
    @track poiacuravalue;
    @track hondaYMT = '';
    @track acuraYMT = '';
    @track isGuest = isguest;
    cartBrands;
    alreadyFilled = false;

    get isDisableSelectVechicleButton(){
        if(this.buttonTitle && this.buttonTitle.toLowerCase() == 'select vehicle')
            return false;
        return true;
    }

    get changeVehicleButtonLabel(){
        return this.buttonTitle && this.buttonTitle.toLowerCase() == 'select vehicle' ? 'Select Vehicle' : 'Change Vehicle';
    }
    
    value = '';
    @track data; 
    eventFiredCallback;


    @track showChangeVehicleModal = false;

    handleChange(e){
        this.selectedOption = e.target.value;
        if(this.selectedOption === 'Parts'){
            //console.log('parts selected');
            
            this.showAccessories = false;
            this.showParts = true;
           this.defaultSelect = true;
        }
        else if(this.selectedOption === 'Accessories'){
            this.showParts = false;
            //console.log('accessories selected');
            this.showAccessories = true;
           this.defaultSelect = false;
            
        }
    }

    renderedCallback() {
        //console.log('this.doorsOptions::',this.doorsOptions);
    }

    connectedCallback() {
        try {
            if (sessionStorage.getItem('successmsg') && sessionStorage.getItem('successmsg') == 'success') {
                let baseurl=window.location.href;
                if(baseurl.includes('cart')){
                    let arr = baseurl.split('/');
                    getBrand({cartId: arr[5]})
                    .then(result => {
                        if(result){
                            // multiple cart issue 2 starts here
                            //localStorage.setItem('brand',result);
                            sessionStorage.setItem('brand',result);
                            // multiple cart issue 2 ends here
                        }
                    }).catch(error => {
                        console.log('OUTPUT : ',error);
                    });
                }
            }
        } catch (error) {
            console.log('OUTPUT : ',error);
        }
        //Added by Faraz on 24/08/2021
        let cartIdForUpdate = this.getCookie('cartIdForUpdate');
        if(cartIdForUpdate && cartIdForUpdate != 'undefined' && cartIdForUpdate != undefined){
            unlockCart({ CartId: cartIdForUpdate })
            .then((result) => {
                this.createCookie('cartIdForUpdate','',-1);
            }).catch((e) => {
                console.log('Error : ',e);
                this.createCookie('cartIdForUpdate','',-1);
            });
        }
        //----End------//

        if(!this.isGuest){
        getMyShoppingSelectionRecords()
        .then(result => {
            if(result && result != 'No records found'){
                let data = JSON.parse(result);
                if(data.hasOwnProperty("HondaVehicle")){
                    let vehicleData = JSON.parse(data.HondaVehicle);
                    this.hondaYMT = 'Honda ' + vehicleData.Year__c +' '+ vehicleData.Model__c +' '+ vehicleData.Trim__c;
                }
                if(data.hasOwnProperty("AcuraVehicle")){
                    let vehicleData = JSON.parse(data.AcuraVehicle);
                    this.acuraYMT = 'Acura ' + vehicleData.Year__c +' '+ vehicleData.Model__c +' '+ vehicleData.Trim__c;
                }
                    let brand = sessionStorage.getItem('brand');
                if(brand == 'Honda' && this.hondaYMT.length && !this.alreadyFilled){
                    this.buttonTitle = this.hondaYMT;
                    this.alreadyFilled = true;
                }else if(brand == 'Acura' && this.acuraYMT.length && !this.alreadyFilled){
                    this.buttonTitle = this.acuraYMT;
                    this.alreadyFilled = true;
                }
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
        }

        let baseurl=window.location.href;
        if(baseurl.includes('cart')){
            getCartItemCategory({communityId:communityId}).then((result) => {
                if(result && result.catName){
                    //console.log('result '+JSON.stringify(result))
                    let categoryname=result.catName;
                    if(categoryname && categoryname !='dual'){
                        let cartName = (result.catName).toLowerCase();
                        this.cartBrands =  cartName.charAt(0).toUpperCase() + cartName.slice(1);                   
                        this.loadConnectedData();
                    }else{
                        this.loadConnectedData(); 
                    }
                }else{
                    this.loadConnectedData();
                    this.retrieveCategory();        
                    this.eventFiredCallback = this.eventFired.bind(this); 
                    this.register();
                }
            })
            .catch((error) => {
                this.error = error;
                //console.log('error::::' + JSON.stringify(error));
            });
        }
        else{
            this.loadConnectedData();
            this.retrieveCategory();        
            this.eventFiredCallback = this.eventFired.bind(this); 
            this.register();
        }
    }

    loadConnectedData(){
        let currentURL = window.location.href.split('/');
        let UrlBrand = currentURL[currentURL.length-1] == 'honda' || currentURL[currentURL.length-1] == 'acura' ? currentURL[currentURL.length-1] : '';
        let brand = sessionStorage.getItem('brand');
        this.createVehicleCookies(brand);
        let vb = sessionStorage.getItem('vehicleBrand');
        let fc = sessionStorage.getItem('fromcart');
        if(!fc && vb && !window.location.href.includes('/s/cart/') && (UrlBrand.length == 0 || (UrlBrand.length && UrlBrand == vb.toLowerCase()))){
            brand = vb;
            sessionStorage.removeItem('fromcart');
            sessionStorage.setItem('brand', brand);
        }
        // localStorage.setItem('cartBrand', brand);
        let brands = [];
        let hasExist = false;
        //console.log('cartBrands brand'+ this.cartBrands +''+ brand);
        if(this.cartBrands && this.cartBrands != brand){
            //brand = this.cartBrands; Commented by Faraz on 23/08/2021
        }
        if(localStorage.getItem("effectiveVehicle")){
            brands = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
            if(brands){
                brands.forEach(element => {        
                    if(brand === element.brand && !this.alreadyFilled){
                        //console.log('IF'+ brand +''+element.brand);
                        this.buttonTitle = element.make + ' ' + element.year + ' ' + element.model + ' ' + element.trim;
                        hasExist = true;
                        this.boolVisible = true;
                        this.alreadyFilled = true;
                        //console.log('buttonTitle::'+  this.buttonTitle);
                    }                
                });
                //console.log('TESTING::'+  this.buttonTitle);
            }
        }else{
            if(brand == 'Honda' && this.hondaYMT.length && !this.alreadyFilled){
                this.buttonTitle = this.hondaYMT;
                hasExist = true;
                this.alreadyFilled = true;
            }else if(brand == 'Acura' && this.acuraYMT.length && !this.alreadyFilled){
                this.buttonTitle = this.acuraYMT;
                hasExist = true;
                this.alreadyFilled = true;
            }
        }
        if(!hasExist  && !this.alreadyFilled){
            this.buttonTitle = 'Select Vehicle';
            this.boolVisible = false;
        }
        /*if (this.getCookie('Make') != 'undefined' && this.getCookie('Make') != 'null' && this.getCookie('Make') != null && this.getCookie('Make') != '') {
            if(this.getCookie('Trim') != 'undefined' && this.getCookie('Trim') != 'null'){
                this.buttonTitle = 'MyVehicle: ' + this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim');
            }else{
                this.buttonTitle = 'MyVehicle: ' + this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Doors');
            }
            this.boolVisible = true;
        }else {
            this.buttonTitle = 'Select Vehicle';
            this.boolVisible = false;
        }*/
    }

    eventFired(event){ 
        this.createCookie('Make', '', 1); // Clear cookie first
        this.createCookie('Year', '', 1); // Clear cookie first
        this.createCookie('Model', '', 1); // Clear cookie first
        this.createCookie('Trim', '', 1); // Clear cookie first
        this.createCookie('Doors', '', 1); // Clear cookie first
        this.buttonTitle = 'Select Vehicle';
        this.boolVisible = false;
        var currURL = window.location.href;
        //console.log(currURL);
        var parts = currURL.split('/');
        var lastSegment = parts.pop() || parts.pop(); // handle potential trailing slash
        //console.log('##@@ clearCookie ',lastSegment);
    }

    get buttonLabel(){
       if(this.makeValue && this.makeValue === sessionStorage.getItem('brand')){
           //console.log('##enter in if');
            //this.buttonTitle = 'Old Value';
        }
        //console.log('##buttonTitle ',this.buttonTitle);
      return this.buttonTitle;
    }

    register(){
        pubsub.subscribe('tabOnClick', this.eventFiredCallback ); 
    } 

    openModal() {
        // to open modal set isModalOpen track value as true
        var currURL = window.location.href;
        //console.log(currURL);
        var parts = currURL.split('/');
        var lastSegment = parts.pop() || parts.pop(); // handle potential trailing slash
        //console.log(lastSegment);
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
        if(window.location.href.includes('cart')){
            this.clearCurrentVehicle();
            setTimeout(function(){
                window.location.reload();
            },1);
        }else{
            this.clearCurrentVehicle();
        }
    }

    navigateToBrand(brandURL) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: brandURL
            }
        });
    }

    clearCurrentVehicle(){
        let brand = sessionStorage.getItem('brand');
        let brands = [];
        if(localStorage.getItem("effectiveVehicle")){
            brands = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
            if(brands){
                Object.keys(brands).forEach((index) => {
                    if(brands[index] && brands[index].brand === brand){
                        brands.splice(parseInt(index), 1);
                    }
                });
            }
        }
        localStorage.setItem("effectiveVehicle", JSON.stringify({'brands': brands}));
        this.createCookie('Make', '', 1); // Clear cookie first
        this.createCookie('Year', '', 1); // Clear cookie first
        this.createCookie('Model', '', 1); // Clear cookie first
        this.createCookie('Trim', '', 1); // Clear cookie first
        this.createCookie('Doors', '', 1); // Clear cookie first
        this.buttonTitle = 'Select Vehicle';
        this.boolVisible = false;
        let brandURL = '/s/'+ brand.toLowerCase();
        this.navigateToBrand(brandURL);
    }

    submitDetails() {
        // to close modal set isModalOpen track value as false
        this.createCookie('Make', '', 1); // Clear cookie first
        this.createCookie('Year', '', 1); // Clear cookie first
        this.createCookie('Model', '', 1); // Clear cookie first
        this.createCookie('Trim', '', 1); // Clear cookie first
        this.createCookie('Make', this.makeValue, 1);
        this.createCookie('Year', this.yearValue, 1);
        this.createCookie('Model', this.modelValue, 1);
        this.createCookie('Trim', this.trimValue, 1);
        this.createCookie('Doors', this.doorsValue, 1);
        try {
            this.storedMake = this.getCookie('Make');
            this.storedYear = this.getCookie('Year');
            this.storedModel = this.getCookie('Model');
            this.storedTrim = this.getCookie('Trim');
            if(this.storedTrim == undefined && this.storedTrim == null){
                this.storedDoors = this.getCookie('Doors');
            }
            //console.log('Stored Make:' + this.storedMake);
            if(this.selectedOption != 'Accessories'){
                this.buttonTitle = this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim');
            }else{
                this.buttonTitle = this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Doors');
            }
            this.isModalOpen = false;
            var currURL = window.location.href;
            //console.log(currURL);
            var parts = currURL.split('/');
            var getUrl = window.location;
            var baseUrl = getUrl.protocol + "//" + getUrl.host + "/s/category/";
            this.boolVisible = true;
            this.goToCategoyPage(this.storedMake, baseUrl);
            /*var catId=  this.categoryId;
            baseUrl =baseUrl+catId;
            console.log('baseUrl'+baseUrl);*/
            //window.open(baseUrl,"_self");
        } catch (ex) {
            //console.log(ex.message);
        }
        //Sakshi -4815
        this.createCookie('VINFitValue','searched', 1);
    }

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

    @wire(getVehicleYear, { make: '$makeValue'})
    wiredGetVehicleYear(result) {
        if (result.data) {
            this.yearOptions = [];
            result.data.map(x => this.yearOptions.push({
                label: x,
                value: x
            }));
            this.error = undefined;
        } else if (result.error) {
            this.error = error;
            this.yearOptions = [];
        }
    }

    @wire(getVehicleModel, {
        make: '$makeValue',
        year: '$yearValue'
    })
    wiredGetVehicleModel(result) {
        if (result.data) {
            this.modelOptions = [];
            result.data.map(x => this.modelOptions.push({
                label: x,
                value: x
            }));
            this.error = undefined;
        } else if (result.error) {
            this.error = error;
            this.modelOptions = [];
        }
    }

    @wire(getVehicleTrim, {
        make: '$makeValue',
        year: '$yearValue',
        model: '$modelValue'
    })
    wiredGetVehicleTrim(result) {
        if (result.data) {
            this.trimOptions = [];
            result.data.map(x => this.trimOptions.push({
                label: x,
                value: x
            }));
            this.error = undefined;
        } else if (result.error) {
            this.error = error;
            this.trimOptions = [];
        }
    }

    // Shalini Added here 18-05-2021
    @wire(getVehicleDoors, {
        make: '$makeValue',
        year: '$yearValue',
        model: '$modelValue'
    })
    wiredVehicleDoors(result) {
        if (result.data) {
            //console.log('result.data::',result.data)
             let doors = [];
             this.doorsOptions = [];
             doors =  result.data;
             doors.forEach(element =>{
                this.doorsOptions.push({ label: element, value: element});
             });
            this.error = undefined;
            //console.log('this.doorsOption',this.doorsOptions);
        } else if (result.error) {
            this.error = error;
            this.doorsOptions = [];
        }
    }

    handleMakeChange(event) {
        this.makeValue = event.detail.value;
        this.yearDisabled = false;
        //console.log(event.detail.value)
    }

    handleYearChange(event) {
        this.yearValue = event.detail.value;
        this.modelDisabled = false;
        //console.log(event.detail.value)
    }

    handleModelChange(event) {
        this.modelValue = event.detail.value;
        this.trimDisabled = false;
        this.doorsDisabled = false;
        //console.log(event.detail.value)
    }

    handleTrimChange(event) {
        this.trimValue = event.detail.value;
        //console.log(event.detail.value)
    }

    handleDoorsChange(event) {
        this.doorsValue = event.detail.value;
        //console.log('doors::',event.detail.value)
    }

    handleVinChange(event) {
        this.vinValue = event.detail.value;
        let vinCmp = this.template.querySelector(".Vin");
        //console.log('Vin Value' + this.vinValue + ''+this.poihondavalue);
        if (this.vinValue.length == 0) {
            this.makeDisabled = false;
            vinCmp.setCustomValidity("");
        }
        if (this.vinValue.length > 0 && this.vinValue.length < 17) {
            vinCmp.setCustomValidity("Please enter valid VIN ");
        }
        if (this.vinValue.length == 17) {
            callVinDecoderService({
                vinNumber: this.vinValue,
                poiType: this.poihondavalue
            })
            .then((result) => {
                var displayData = JSON.parse(result);
                //console.log('result' + result);
                if (displayData.isError == false) {
                    vinCmp.setCustomValidity("");
                    const makeSelect = this.template.querySelector('.Make');
                    if (makeSelect) {
                        //console.log(displayData.selectorDetail.make);
                        this.makeOptions.push({
                            label: displayData.selectorDetail.make,
                            value: displayData.selectorDetail.make
                        });
                        makeSelect.value = displayData.selectorDetail.make;
                        this.makeValue = displayData.selectorDetail.make;
                        this.makeDisabled = true;
                        //console.log('Make Value' + makeSelect.value + displayData.selectorDetail.make);
                    }
                    const yearSelect = this.template.querySelector('.Year');
                    if (yearSelect) {
                        //console.log(displayData.selectorDetail.Year);
                        this.yearOptions.push({
                            label: displayData.selectorDetail.year,
                            value: displayData.selectorDetail.year
                        });
                        yearSelect.value = displayData.selectorDetail.year;
                        this.yearValue = displayData.selectorDetail.year;
                        this.yearDisabled = true;
                        //console.log('Year Value' + yearSelect.value + displayData.selectorDetail.year);
                    }
                    const modelSelect = this.template.querySelector('.Model');
                    if (modelSelect) {
                        this.modelOptions.push({
                            label: displayData.selectorDetail.model,
                            value: displayData.selectorDetail.model
                        });
                        modelSelect.value = displayData.selectorDetail.model;
                        this.modelValue = displayData.selectorDetail.model;
                        this.modelDisabled = true;
                        //console.log('Model Value' + modelSelect.value + displayData.selectorDetail.model);
                    }
                    const trimSelect = this.template.querySelector('.Trim');
                    if (trimSelect) {
                        this.trimOptions.push({
                            label: displayData.selectorDetail.trim,
                            value: displayData.selectorDetail.trim
                        });
                        trimSelect.value = displayData.selectorDetail.trim;
                        this.trimValue = displayData.selectorDetail.trim;
                        this.trimDisabled = true;
                        //console.log('Trim Value' + trimSelect.value + displayData.selectorDetail.trim);
                    }
                    const doorsSelect = this.template.querySelector('.Door');
                    if (doorsSelect) {
                        this.trimOptions.push({
                            label: displayData.selectorDetail.trim,
                            value: displayData.selectorDetail.trim
                        });
                        doorsSelect.value = displayData.selectorDetail.trim;
                        this.doorsValue = displayData.selectorDetail.trim;
                        this.doorsDisabled = true;
                        //console.log('Door Value' + doorsSelect.value + displayData.selectorDetail.trim);
                    }
                } else {
                    vinCmp.setCustomValidity("Please enter valid VIN ");
                }
                this._isLoading = false;

                //console.log(result);
            })
            .catch((error) => {
                this.error = error;
                this._isLoading = false;
                //console.log(error);
            });
        }
        vinCmp.reportValidity();
    }

    goToCategoyPage(category, baseUrl) {
        getCategoryId({categoryName: category})
        .then((resu) => {
            this.categoryId = resu;
            // console.log('resu::::' + resu);
            var catId = this.categoryId;
            baseUrl = baseUrl + catId;
            //console.log('baseUrl' + baseUrl);
            window.open(baseUrl, "_self");
        })
        .catch((error) => {
            this.error = error;
            //console.log('error::::' + error);
        });
        // return this.categoryId ;
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
        //console.log('this.poihondavalue' + this.poihondavalue)
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

    handleOnChangeVehicle(event){
        //console.log('handleOnChangeVehicle : ');
        this.showChangeVehicleModal = true;
    }

    closeChangeVehiclePopup(){
        this.showChangeVehicleModal = false;
    }

    //Added by Deepak Mali Task:HDMP-3690 "Enter" key should have the same functionality as clicking the main CTA
    handleKeyPress(event){
        let charCode = (event.which) ? event.which : event.keyCode;
        if (charCode == 13){ 
            this.submitDetails();
        }
    }
    createVehicleCookies(brand){
        if(localStorage.getItem("effectiveVehicle")){
            let brands = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
            if(brands){
                brands.forEach(element => {        
                    if( brand === element.brand){
                        this.buttonTitle = element.make + ' ' + element.year + ' ' + element.model + ' ' + element.trim;
                        this.createCookie('Make', element.make, 1);
                        this.createCookie('Year', element.year, 1);
                        this.createCookie('Model', element.model, 1);
                        this.createCookie('Trim', element.trim, 1);
                    }                
                    if(element.model == 'Motocompacto'){
                        this.createCookie('Make', brand, 1);
                    }
                });
            }
        }
    }
}
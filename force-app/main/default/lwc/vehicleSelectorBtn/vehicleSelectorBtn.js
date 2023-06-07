import {
    LightningElement,
    track,
    wire
} from 'lwc';
import callVinDecoderService from '@salesforce/apex/B2B_EconfigIntegration.callVinDecoderService';
import getCategoryId from '@salesforce/apex/B2B_VehicleSelectorController.getCategoryId';
import getVehicleYear from '@salesforce/apex/B2B_EconfigIntegration.getVehicleYear';
import getVehicleModel from '@salesforce/apex/B2B_EconfigIntegration.getVehicleModel';
import getVehicleTrim from '@salesforce/apex/B2B_EconfigIntegration.getVehicleTrim';
import getVehicleDoors from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDoors';
export default class ModalPopupLWC extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track buttonLabel = "Select Vehicle";
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
    
    value = '';

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
        //console.log('rc values ' + 'modelvalue -' + this.modelValue + 'make value -' + this.makeValue + 'year value -' + this.yearValue + 'trim value-' + this.trimValue);
        //console.log('rc values ' + 'modelvalue -' + this.modelValue + 'make value -' + this.makeValue + 'year value -' + this.yearValue + 'door value-' + this.doorsValue);
  
    //console.log('this.doorsOptions::',this.doorsOptions);
    }
    connectedCallback() {
        this.retrieveCategory();
        if (this.getCookie('Make') != 'undefined' && this.getCookie('Make') != 'null' && this.getCookie('Make') != null && this.getCookie('Make') != '') {
            if(this.getCookie('Trim') != 'undefined' && this.getCookie('Trim') != 'null'){
                //console.log('selected option11::');
                this.buttonLabel = 'My Vehicle: ' + this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim');
            }else{
                //console.log('selected door option22::');
                this.buttonLabel = 'My Vehicle: ' + this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Doors');
            
            }
            this.boolVisible = true;
        }else {
            this.buttonLabel = 'Select Vehicle';
            this.boolVisible = false;
        }
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
        this.createCookie('Make', '', 1); // Clear cookie first
        this.createCookie('Year', '', 1); // Clear cookie first
        this.createCookie('Model', '', 1); // Clear cookie first
        this.createCookie('Trim', '', 1); // Clear cookie first
        this.createCookie('Doors', '', 1); // Clear cookie first
        this.buttonLabel = 'Select Vehicle';
        this.boolVisible = false;
        var currURL = window.location.href;
        //console.log(currURL);
        var parts = currURL.split('/');
        var lastSegment = parts.pop() || parts.pop(); // handle potential trailing slash
        if (lastSegment != 'honda' && lastSegment != 'acura') {
            location.reload();
        }
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
                 
              this.buttonLabel = 'My Vehicle: ' + this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim');
             }
             else{
                 this.buttonLabel = 'My Vehicle: ' + this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Doors');
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
           // console.log(ex.message);
        }
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
    @wire(getVehicleYear, {
        make: '$makeValue'
    })

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
        //console.log('Vin Value' + this.vinValue);
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
        getCategoryId({
                categoryName: category
            })
            .then((resu) => {
                this.categoryId = resu;
                //console.log('resu::::' + resu);
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
        //console.log('calling creating cookie');
        var expires;
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 100));
            expires = ";expires=" + date.toGMTString();
        } else {
            expires = "";
        }
        //console.log('setting cookie');
        //updated by Pradeep Singh for Optiv Issue
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
        // ends here
    }


    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }
}
import { LightningElement, track, wire, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getPhoneDataByModelId from '@salesforce/apex/OwnAPIController.getPhoneDataByModelId';
import { CurrentPageReference } from 'lightning/navigation';
import { ISGUEST, getProductContext, getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';

const VIEW_BUTTON_DISABLE_CLASS = 'check-button-disable';
const VIEW_BUTTON_ACTIVE_CLASS = 'check-button-active';
const COMBOBOX_ACTIVE_CLASS = 'find-brand-combobox product-compatibility-combobox';
export default class OwnPhoneCompatibilityPhone extends OwnBaseElement {

    @api hondaActiveContentId;
    @api hondaInactiveContentId;
    @api acuraActiveContentId;
    @api acuraInactiveContentId;
    @api pageType;
    @api buttonName;


    @track isQuickStartGuide = false;
    @track modelId;
    @track divisionId;
    @track phoneCarrierOptions;
    @track ManufacturerOptions;
    @track phoneModelOptions;
    @track phoneCarrier;
    @track manufacturer;
    @track manufacturerName;
    @track phoneModel;
    @track phoneModelName;
    @track year;
    @track model;
    @track trim;
    @track isManufacturerDisable = true;
    @track isModelDisable = true;
    @track resultData;
    @track isViewButtonDisabled = true;
    @track fb;
    @track activePageTitle;
    @track inactivePageTitle;
    @track isError = false;
    @track isContentShow = false;
    @track errorLogo;
    // errorMsg;
    context;
    currentPageReference = null;
    urlStateParameters = null;

    connectedCallback() {
        //console.log('called');
        this.errorLogo = this.myGarageResource() + '/ahmicons/warning.png';
        this.initialize();
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.fb = this.urlStateParameters.fb || null;
        this.divisionId = this.urlStateParameters.divisionid || null;
    }

    initialize = async () => {

        if(document.title == 'Quick Start Guide'){
            this.isQuickStartGuide = true;
        }
        let origin = localStorage.getItem('origin');
        let brandType = sessionStorage.getItem('brandtype');
        if (this.fb || origin == 'ProductChooser') {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        //console.log('this.context  :-  ', this.context);
        if (this.context || this.divisionId) {
            this.divisionId = this.context.product.divisionId;
            this.modelId = this.context.product.modelId;
            this.year = this.context.product.year;
            this.model = this.context.product.model;
            this.trim = this.context.product.trim;
            this.image = this.context.product.image;
            let contentKeys = [];
            if (this.divisionId == 'A') {
                contentKeys.push(this.hondaActiveContentId);
                contentKeys.push(this.hondaInactiveContentId);
            } else {
                contentKeys.push(this.acuraActiveContentId);
                contentKeys.push(this.acuraInactiveContentId);
            }

            let contentResults = await getManagedContentByTopicsAndContentKeys(contentKeys, this.topics, this.pageSize, this.managedContentType);
            //console.log('results  :-  ', contentResults);

            if(contentResults.length > 0){
                let content = contentResults[0].title.value.includes('PHONE PAGE INACTIVE') ? contentResults[0] : contentResults[1];
                this.inactivePageTitle = this.htmlDecode(content.body.value);

                content = contentResults[0].title.value.includes('PHONE PAGE ACTIVE') ? contentResults[0] : contentResults[1];
                this.activePageTitle = this.htmlDecode(content.body.value);
                // this.errorMsg= content.downloadLabel.value;

            }
            getPhoneDataByModelId({ modelId: this.modelId, divisionId: this.divisionId })
                .then((data) => {
                    if (data) {
                        //console.log('data  :-  ', data);
                        if (data.arePhonesAvailable) {
                            this.isContentShow = true;
                            this.resultData = data;
                            this.phoneCarrierOptions = [];
                            this.resultData.carrierList.forEach(element => {
                                this.phoneCarrierOptions = [...this.phoneCarrierOptions, { label: element.name, value: element.id }];
                            });
                        } else {
                            this.isError = true;
                            // this.showToast_error(this.errorMsg); 
                        }
                    }

                }).catch((error) => {
                    //console.error('Error:', error);
                    this.isError = true;
                });
        }
    };

    get viewButtonClass() {
        if (this.phoneCarrier && this.manufacturer && this.phoneModel) {
            this.isViewButtonDisabled = false;
            return VIEW_BUTTON_ACTIVE_CLASS;
        } else {
            this.isViewButtonDisabled = true;
            return VIEW_BUTTON_DISABLE_CLASS;
        }
    }

    get isPageActive() {
        return ((this.phoneCarrier && this.manufacturer && this.phoneModel) || this.pageType == 'Bluetooth') ? true : false;
    }

    get isManufacturerComboboxActive() {
        return this.phoneCarrier ? COMBOBOX_ACTIVE_CLASS : 'product-compatibility-combobox';
    }

    get isPhoneModelComboboxActive() {
        return (this.phoneCarrier && this.manufacturer) ? COMBOBOX_ACTIVE_CLASS : 'product-compatibility-combobox';
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }

    handlePhoneCarrier(event) {
        this.phoneCarrier = event.detail.value;
        //console.log('phoneCarrier', this.phoneCarrier);
        let allManufacturers = this.resultData.manufacturerMap[this.phoneCarrier];
        this.ManufacturerOptions = [];
        allManufacturers.forEach(element => {
            this.ManufacturerOptions = [...this.ManufacturerOptions, { label: element.name, value: element.id }];
        });
        this.phoneModelOptions = ''
        this.phoneModel = undefined;
        this.manufacturer = undefined;
        this.isManufacturerDisable = false;
        this.isModelDisable = true;
    }

    handleManufacturer(event) {
        this.manufacturer = event.detail.value;
        //console.log('This is Manufacturer : ',this.manufacturer);
        this.manufacturerName = event.target.options.find(opt => opt.value === event.detail.value).label;
        let allPhoneModels = this.resultData.phoneMap[this.phoneCarrier+this.manufacturer];
        this.phoneModel = undefined;
        this.phoneModelOptions = [];
        allPhoneModels.forEach(element => {
            this.phoneModelOptions = [...this.phoneModelOptions, { label: element.name, value: element.id }];
        });
        this.isModelDisable = false;
    }
    handlePhoneModel(event) {
        this.phoneModel = event.detail.value;
        this.phoneModelName = event.target.options.find(opt => opt.value === event.detail.value).label;
    }

    handleViewCompatibility() {
        const divisionName = this.divisionId === 'A' ? 'Honda' : 'Acura';
        const divisionLogo = this.divisionId === 'A' ? '/images/thumbnail_honda.png' : '/images/thumbnail_acura.png';
        let product = {
            'divisionId': this.divisionId, 'division': divisionName,
            'year': this.year, 'model': this.model, 'trim': this.trim,
            'modelId': this.modelId,
            'vin': '-',
            'nickname': this.year + ' ' + this.model + ' ' + this.trim,
            'image': this.image,
            'phoneCarrierId': this.phoneCarrier,
            'manufacturerId': this.manufacturer.trim(),
            'manufacturerName': this.manufacturerName,
            'phoneModelName': this.phoneModelName,
            'phoneModelId': this.phoneModel
        };
        const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
        context.product = product;
        localStorage.setItem('context', JSON.stringify(context));
        if (document.location.pathname.includes('phone-compatibility-phone')) {
            this.navigate('/phone-compatibility-result?fb=true', {});
        } else {
            this.navigate('/bluetooth-compatibility-result?fb=true', {});
        }

    }
}
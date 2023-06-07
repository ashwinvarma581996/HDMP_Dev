//============================================================================
// Title:    Honda MyGarage Experience - Check Product Compatibility
//
// Summary:  This is the Product Compatibility Check html seen at the page of the Honda MyGarage Community
//
// Details:  Product Compatibility Check for pages
//
// History:
// October 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import getYears from '@salesforce/apex/FindProductController.getYears';
import getModels from '@salesforce/apex/FindProductController.getModels';
import getTrims from '@salesforce/apex/FindProductController.getTrims';
import commonResources from "@salesforce/resourceUrl/Owners";
import { OwnBaseElement } from 'c/ownBaseElement';
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';
import { ISGUEST, getProductContext } from 'c/ownDataUtils';

const FIND_BUTTON_DISABLE_CLASS = 'find-button-ymt-section-disable';
const FIND_BUTTON_ACTIVE_CLASS = 'find-button-ymt-section-active';
export default class OwnProductCompatibilityCheck extends OwnBaseElement {

    @api divisionid;

    @track context;
    @track vinHelpIcon = commonResources + '/Icons/garage_questionmark.png';
    @track years;
    @track models;
    @track trims;
    @track modelId;
    @track year;
    @track model;
    @track trim;
    @track vin;
    @track isModelDisable = true;
    @track isTrimDisable = true;
    @track isYmtButtonDisabled = true;
    @track isVinButtonDisabled = true;
    @track staticText;

    connectedCallback() {
       if(this.divisionid==='A'){
            this.staticText = 'Find our which connected packages are available for your Honda based on its year, modal, and trim';
       } else {
        this.staticText = 'Find our which connected packages are available for your Acura based on its year, modal, and trim';
       }
    }


    @wire(getYears, { divisionId: '$divisionid' })
    wiredGetYearsHonda({ error, data }) {
        if (data) {
            this.years = data;
        } else if (error) {
            this.showToast_error(error);
            this.years = undefined;
            this.year = undefined;
        }
    }

    @wire(getModels, { divisionId: '$divisionid', year: '$year' })
    wiredGetModelsHonda({ error, data }) {
        if (data) {
            this.models = data;
        } else if (error) {
            this.showToast_error(error);
            this.models = undefined;
            this.model = undefined;
        }
    }

    @wire(getTrims, { divisionId: '$divisionid', year: '$year', modelName: '$model' })
    wiredGetTrimsHonda({ error, data }) {
        if (data) {
            this.trims = data;
           // console.log('data  :-  ', data);
        } else if (error) {
            this.showToast_error(error);
            this.trims = undefined;
            this.trim = undefined;
            this.modelId = undefined;
        }
    }

    get ymtButtonClass() {
        if (this.year && this.model && this.trim) {
            this.isYmtButtonDisabled = false;
            return FIND_BUTTON_ACTIVE_CLASS;
        } else {
            this.isYmtButtonDisabled = true;
            return FIND_BUTTON_DISABLE_CLASS;
        }
    }

    get vinButtonClass() {
        if (this.vin && this.vin.length === 17) {
            this.isVinButtonDisabled = false;
            return FIND_BUTTON_ACTIVE_CLASS;
        } else {
            this.isVinButtonDisabled = true;
            return FIND_BUTTON_DISABLE_CLASS;
        }
        // return this.vin && this.vin.length === 17 ? FIND_BUTTON_ACTIVE_CLASS : FIND_BUTTON_DISABLE_CLASS;
    }

    handleYear(event) {
        this.model = undefined;
        this.models = '';
        this.trims = '';
        this.trim = undefined;
        this.isModelDisable = false;
        this.isTrimDisable = true;
        // this.isYmtButtonDisabled = true;
        this.year = event.target.value;
    }

    handleModel(event) {
        this.trim = undefined;
        this.trims = '';
        this.isTrimDisable = false;
        // this.isYmtButtonDisabled = true;
        this.model = event.target.value;
    }

    handleTrim(event) {
        // this.isYmtButtonDisabled = false;
        this.modelId = event.detail.value;
        this.trims.forEach(element => {
            if (element.value === this.modelId) {
                this.trim = element.label;
            }
        });
    }

    handleVin(event) {
        // this.isFirstFindButtonDisable = false;
        this.vin = event.target.value;
    }

    handleFindByYearModel() {
        const divisionName = this.divisionid === 'A' ? 'Honda' : 'Acura';
        const divisionLogo = this.divisionid === 'A' ? '/resource/MyGarage/images/thumbnail_honda.png' : '/resource/MyGarage/images/thumbnail_acura.png';
        const url = this.divisionid === 'A' ? '/honda-product-compatibility-result?fb=true' : '/acura-product-compatibility-result?fb=true';
        let product = {
                'divisionId': this.divisionid, 'division': divisionName,
                'year': this.year, 'model': this.model, 'trim': this.trim,
                'modelId': this.modelId,
                'vin': '-',
                'nickname': this.year + ' ' + this.model + ' ' + this.trim,
                'image': divisionLogo
            };
        
        const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
        context.product = product;
        localStorage.setItem('context', JSON.stringify(context));
        this.navigate(url, {});


    }
    handleFindByVin() {
        const divisionName = this.divisionid === 'A' ? 'Honda' : 'Acura';
        const url = this.divisionid === 'A' ? '/honda-product-compatibility-result?fb=true' : '/acura-product-compatibility-result?fb=true';
        getProductByVIN({ divisionId: this.divisionid, vin: this.vin })
            .then(result => {
                let prod = JSON.parse(result);
                let product = {
                    'divisionId': this.divisionid, 'division': divisionName,
                    'year': prod.modelDetail.year ? prod.modelDetail.year : '-',
                    'model': prod.modelDetail.modelGroupName ? prod.modelDetail.modelGroupName :
                        (prod.modelDetail.modelName ? prod.modelDetail.modelName : '-'),
                    'trim': prod.modelDetail.trim ? prod.modelDetail.trim : '-',
                    'nickname': prod.modelDetail.year + ' ' + prod.modelDetail.modelGroupName + ' ' + prod.modelDetail.trim,
                    'modelId': prod.modelDetail.modelId ? prod.modelDetail.modelId : '-',
                    'make': prod.modelDetail.make ? prod.modelDetail.make : '-',
                    'vin': this.vin,
                    'color': prod.modelDetail.color ? prod.modelDetail.color : '-',
                    'exteriorColor': prod.modelDetail.color.name ? prod.modelDetail.color.name : '-',
                    'image': this.selectImageFromVINAPI(prod.modelDetail.assets)
                };
                const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
                context.product = product;
                localStorage.setItem('context', JSON.stringify(context));
                this.navigate(url, {});


            })
            .catch(error => {
                //console.log('error: ', error);
            });

    }
    selectImageFromVINAPI(vinImageSet) {
        let selectedImage = '';

        if (vinImageSet) {
            vinImageSet.find(element => {
                if (element.assetType === 'IMGMIDSIZE') {
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

        return selectedImage;
    }
}
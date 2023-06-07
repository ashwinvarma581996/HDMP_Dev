import { track, LightningElement, wire } from 'lwc';
import {OwnBaseElement} from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";
import getYears from '@salesforce/apex/FindProductController.getYears';
import getModels from '@salesforce/apex/FindProductController.getModels';
import getTrims from '@salesforce/apex/FindProductController.getTrims';
import productIdentifierLookUp from '@salesforce/apex/OwnAPIController.productIdentifierLookUp';
import getFeatureListByModelInformation from '@salesforce/apex/OwnAPIController.getFeatureListByModelInformation';
const FIND_BUTTON_ACTIVE = 'find-button-active';
const FIND_BUTTON_DISABLED = 'find-button-disabled';
const FIND_BUTTON_SECTION_ACTIVE = 'find-button-section-active';
const FIND_BUTTON_SECTION_DISABLED = 'find-button-section-disabled';
const VIN_ERROR_TEXT = "Incorrect VIN entered.";
const brands = [{'name': 'AcuraAutos', 'label': 'Acura Autos','value': 'B'},
                {'name': 'HondaAutos', 'label': 'Honda Autos','value': 'A'}
               ];
const PDF_LINK = 'https://www.honda.com/privacy/connected-product-privacy-policy.pdf';

export default class OwnFindVehicleDataPrivacy extends OwnBaseElement {
    @track modelFindButtonClass = FIND_BUTTON_DISABLED;
    @track vinFindButtonClass = FIND_BUTTON_DISABLED;
    @track modelSectionButtonClass = FIND_BUTTON_SECTION_ACTIVE;
    @track vinSectionButtonClass = FIND_BUTTON_SECTION_DISABLED;
    @track brands = brands;
    @track years;
    @track year;
    @track models;
    @track model;
    @track modelId;
    @track trims;
    @track trim;
    @track divisionId;
    @track vin;
    @track displayVINError = false;
    @track incorrectVINLength = false;
    @track correctVINLength = false;
    @track vinInputVal = "";
    @track yearSelectionDisabled = true;
    @track modelSelectionDisabled = true;
    @track trimSelectionDisabled = true;
    @track showModelSection = true;
    @track showVinSection = false;
    vinHelpIcon = commonResources + '/Icons/garage_questionmark.png';
    vinErrorText = VIN_ERROR_TEXT;

    @wire(getYears, { divisionId : '$divisionId'})
    wiredGetYears({ error, data }){
        if (data) {
            //console.log('Division Id',this.divisionId);
            this.years = data;
        } else if (error) {
            this.showToast_error(error);
            this.years = undefined;
            this.year = undefined;
        }
    }

    @wire(getModels, { divisionId : '$divisionId', year : '$year'})
    wiredGetModels({ error, data }){
        if (data) {
            this.models = data;
        } else if (error) {
            this.showToast_error(error);
            this.models = undefined;
            this.model = undefined;
        }
    }

    @wire(getTrims, { divisionId : '$divisionId', year : '$year', modelName : '$model'})
    wiredGetTrims({ error, data }){
        if (data) {
            this.trims = data;
        } else if (error) {
            this.showToast_error(error);
            this.trims = undefined;
            this.trim = undefined;
            this.modelId = undefined;
        }
    }

    handleMakeChange(event){
        this.divisionId = event.detail.value;
        this.year = undefined;
        this.model = undefined;
        this.trim = undefined;
        this.modelId = undefined;
        this.vin = undefined;
        this.vinInputVal = "";
        this.correctVINLength = false;
        this.updateSectionsFocus(this.divisionId, this.year, this.model, this.trim, this.vin);
        //console.log(this.divisionId);
    }
    handleYearChange(event){
        this.year = event.detail.value;
        this.model = undefined;
        this.trim = undefined;
        this.modelId = undefined;
        this.vin = undefined;
        this.vinInputVal = "";
        this.correctVINLength = false;
        this.updateSectionsFocus(this.divisionId, this.year, this.model, this.trim, this.vin);
    }
    handleModelChange(event){
        this.model = event.detail.value;
        this.trim = undefined;
        this.modelId = undefined;
        this.vin = undefined;
        this.vinInputVal = "";
        this.correctVINLength = false;
        this.updateSectionsFocus(this.divisionId, this.year, this.model, this.trim, this.vin);
    }
    handleTrimChange(event){
        this.modelId = event.detail.value;
        this.trims.forEach(element => { 
            if(element.value === this.modelId){ 
                this.trim = element.label;
            }
        });

        this.vin = undefined;
        this.vinInputVal = "";
        this.correctVINLength = false;
        this.updateSectionsFocus(this.divisionId, this.year, this.model, this.trim, this.vin);
    }

    handleVINChange(event){
        // VIN Validation:
        // character length validation: Once 17 characters entered, display green check
        // < 17 characters & find pressed: display error message + cross
        // 17 characters, but is not valid VIN: server-side validation against database
        //this.divisionId = undefined;
        this.vin = event.target.value;
        this.vinInputVal = this.vin; 
        this.year = undefined;
        this.model = undefined;
        this.trim = undefined;
        this.modelId = undefined;
        if (this.vin && this.vin.length === 17){
            this.correctVINLength = true;
            this.incorrectVINLength = false;
            this.displayVINError = false;
            this.updateSectionsFocus(this.divisionId, this.year, this.model, this.trim, this.vin);
        }else{
            this.correctVINLength = false;
            this.updateSectionsFocus(this.divisionId, this.year, this.model, this.trim, undefined);
        }
    }
    handleFindByYearModel(){
        //console.log(this.year,this.model,this.modelId);
        let modelName = '';
        if(this.model){
            modelName = this.model.replaceAll(' ', '%20');
        }
        getFeatureListByModelInformation({
            year: this.year ,
            model: modelName,
            modelId: this.modelId, 
            divisionId: this.divisionId}).then((result)=>{
            //console.log('Get Feature List By Model information',result);
            if(result.model.telematicsPlatform){
                let url = result.model.telematicsPlatform == 'MY17' ? '/vehicle-data-privacy-settings?page=question&from=find&fb=true' : PDF_LINK;
                let product = {
                    'divisionId': this.divisionId, 
                    'division': this.divisionId === 'A' ? 'Honda' : 'Acura',
                    'year': this.year, 'model': this.model, 'trim': this.trim,
                    'modelId': this.modelId,
                    'vin': '-',
                    'nickname': this.year + ' ' + this.model + ' ' + this.trim,
                    'image': this.divisionId === 'A' ? '/resource/MyGarage/images/thumbnail_honda.png' : '/resource/MyGarage/images/thumbnail_acura.png'
                };
                this.setContext(product);
                sessionStorage.setItem('frompage','Vehicle Data Privacy : Find Vehicle');
                this.navigate(url, {});
            } 
        }).catch((error)=>{
            //console.log(error);
        });
    }
    handleFindByVIN(){
        if (this.vin.length != 17){
            //console.log('IF:');
            this.correctVINLength = false;
            this.incorrectVINLength = true;
            this.displayVINError = true;
            return;
        }
        this.divisionId = this.divisionId ? this.divisionId : 'A';
        productIdentifierLookUp({productIdentifier : this.vin, divisionId: this.divisionId}).then((result) => {
            //console.log('Find by VIN Result',result.vehicle);
            if(result.vehicle){
                let url = result.vehicle.telematicsPlatform == 'MY17' ? '/vehicle-data-privacy-settings?page=question&from=find&fb=true': PDF_LINK;
                let product = {
                    'divisionId': result.vehicle.divisionCode, 
                    'division': result.vehicle.divisionName,
                    'year': result.vehicle.modelYear, 
                    'model': result.vehicle.modelCode, 'trim': result.vehicle.modelTrimTypeCode,
                    'modelId': result.vehicle.modelId,
                    'vin': result.vehicle.VIN,
                    'nickname': result.vehicle.modelYear + ' ' + result.vehicle.modelCode + ' ' + result.vehicle.modelTrimTypeCode,
                    'image': result.vehicle.divisionCode === 'A' ? '/resource/MyGarage/images/thumbnail_honda.png' : '/resource/MyGarage/images/thumbnail_acura.png'
                };
                
                this.setContext(product);
                sessionStorage.setItem('frompage','Vehicle Data Privacy : Find Vehicle');
                this.navigate(url, {});
            }
        }).catch((err) => {
            //console.log('Find by VIN Error',err);
        });

    }
    setContext(product){
        const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
        context.product = product;
        localStorage.setItem('context', JSON.stringify(context));
    }
    handleSectionClick(event){
        const section = event.currentTarget.dataset.section;
        if (section == 'Model'){
            this.showModelSection = true;
            this.modelSectionButtonClass = FIND_BUTTON_SECTION_ACTIVE;
            this.vinSectionButtonClass = FIND_BUTTON_SECTION_DISABLED;
            this.showVinSection = false;
        }else if (section == 'Vin'){
            this.showModelSection = false;
            this.modelSectionButtonClass = FIND_BUTTON_SECTION_DISABLED;
            this.vinSectionButtonClass = FIND_BUTTON_SECTION_ACTIVE;
            this.showVinSection = true;
        }

    }
    updateSectionsFocus(divisionId, year, model, trim, vin){
        //console.log(divisionId, year, model, trim, vin);
        if (year && model){
            this.modelSelectionDisabled = false;
            this.trimSelectionDisabled = false;
        }else if (year){
            this.modelSelectionDisabled = false;
            this.trimSelectionDisabled = true;
        }else if(divisionId){
            this.yearSelectionDisabled = false;
            this.modelSelectionDisabled = true;
            this.trimSelectionDisabled = true;
        }else{
            this.yearSelectionDisabled = true;
            this.modelSelectionDisabled = true;
            this.trimSelectionDisabled = true;
        }

        if (divisionId && year && model && trim){
            this.modelFindButtonClass = FIND_BUTTON_ACTIVE;
        }
        else{
            this.modelFindButtonClass = FIND_BUTTON_DISABLED;
        }
        if (vin){
            this.vinFindButtonClass = FIND_BUTTON_ACTIVE;
        }
        else{
            this.vinFindButtonClass = FIND_BUTTON_DISABLED;
        }
        if (this.showModelSection){
            this.modelSectionButtonClass = FIND_BUTTON_SECTION_ACTIVE;
        }
        else{
            this.modelSectionButtonClass = FIND_BUTTON_SECTION_DISABLED;
        }
        if (this.showVinSection){
            this.vinSectionButtonClass = FIND_BUTTON_SECTION_ACTIVE;
        }
        else{
            this.vinSectionButtonClass = FIND_BUTTON_SECTION_DISABLED;
        }
    }

}
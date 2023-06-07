//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Owners Garage Find - Honda Auto logic of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the own garage find honda component for all community pages.
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { addProduct } from 'c/ownDataUtils';
import getDivisionPowersports from '@salesforce/apex/OwnGarageController.getDivisionPowersports';
import getTypesPowersports from '@salesforce/apex/OwnGarageController.getTypesPowersports';
import getModelsPowersports from '@salesforce/apex/OwnGarageController.getModelsPowersports';
//import getTrimsPowersports from '@salesforce/apex/OwnGarageController.getTrimsPowersports';

const FIND_BRAND_BUTTON_ACTIVE = 'find-brand-button-active';
const FIND_BRAND_BUTTON_DISABLED = 'find-brand-button-disabled';

export default class OwnGarageFindPowersports extends OwnBaseElement {
    @track division;
    @track modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track types;
    @track type;
    @track models;
    @track model;
    @track modelLabel;
    @track trims;
    @track trim;


    @wire(getDivisionPowersports)
    wiredGetDivisionPowersports({ error, data }) {
        if (data) {
            this.division = data;
        } else if (error) {
            this.showToast_error(error);
        }
    }

    @wire(getTypesPowersports)
    wiredGetTypesPowersports({ error, data }) {
        if (data) {
            this.types = data;
        } else if (error) {
            this.showToast_error(error);
            this.types = undefined;
            this.type = undefined;
        }
    }

    handleTypeChange(event){
        this.type = event.detail.value;
        this.model = undefined;
        this.trim = undefined;
        this.handleFindAndSection();
        getModelsPowersports({ year: parseInt(this.type) })
            .then((result) => {
                this.models = result;
            })
            .catch((error) => {
                this.showToast_error(error);
                this.models = undefined;
            });
    }

    handleModelChange(event){
        this.model = event.detail.value;
        this.models.forEach(element => {
            if(element.value === this.model){
                this.modelLabel = element.label;
            }
        });
        this.trim = undefined;
        this.handleFindAndSection();
        // getTrimsPowersports({ year: parseInt(this.type), modelId: this.modelLabel })
        //     .then((result) => {
        //         this.trims = result;
        //     })
        //     .catch((error) => {
        //         this.showToast_error(error);
        //         this.trims = undefined;
        //     });
    }

    handleTrimChange(event){
        this.trim = event.detail.value;
        this.handleFindAndSection();
    }

    handleFindAndSection(){
        if(this.type && this.model && this.trim){
            this.modelFindButtonClass = FIND_BRAND_BUTTON_ACTIVE;
        }
        if(!this.type || !this.model || !this.trim){
            this.modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
        }
    }

    handleFind(){
        if(this.type && this.model && this.trim){
            const prod = {'divisionId': this.division.divisionId, 'division': this.division.divisionName, 'year': this.type, 'model': this.modelLabel, 'trim': this.trim, 'nickname': this.modelLabel};
            addProduct(prod);
        }
    }
}
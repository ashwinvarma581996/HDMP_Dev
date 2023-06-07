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
import getDivisionPowerEquipment from '@salesforce/apex/OwnGarageController.getDivisionPowerEquipment';
import getProductsPowerequipment from '@salesforce/apex/OwnGarageController.getProductsPowerequipment';
import getTypesPowerequipment from '@salesforce/apex/OwnGarageController.getTypesPowerequipment';
import getModelsPowerequipment from '@salesforce/apex/OwnGarageController.getModelsPowerequipment';

const FIND_BRAND_BUTTON_ACTIVE = 'find-brand-button-active';
const FIND_BRAND_BUTTON_DISABLED = 'find-brand-button-disabled';

export default class OwnGarageFindPowerequipment extends OwnBaseElement {
    @track division;
    @track modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track products;
    @track product;
    @track productLabel;
    @track types;
    @track type;
    @track typeLabel;
    @track models;
    @track model;
    @track modelLabel;

    @wire(getDivisionPowerEquipment)
    wiredGetDivisionPowerEquipment({ error, data }) {
        if (data) {
            this.division = data;
        } else if (error) {
            this.showToast_error(error);
        }
    }

    @wire(getProductsPowerequipment)
    wiredGetProductsPowersports({ error, data }) {
        if (data) {
            this.products = data;
        } else if (error) {
            this.showToast_error(error);
            this.products = undefined;
            this.product = undefined;
        }
    }

    handleProductChange(event){
        this.product = event.detail.value;
        this.type = undefined;
        this.model = undefined;
        this.handleFindAndSection();
        getTypesPowerequipment({ product: this.product })
            .then((result) => {
                this.types = result;
            })
            .catch((error) => {
                this.showToast_error(error);
                this.types = undefined;
            });
    }

    handleTypeChange(event){
        this.type = event.detail.value;
        this.model = undefined;
        this.handleFindAndSection();
        getModelsPowerequipment({ year: parseInt(this.type) })
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
        this.handleFindAndSection();
    }

    handleFindAndSection(){
        if(this.product && this.type && this.model){
            this.modelFindButtonClass = FIND_BRAND_BUTTON_ACTIVE;
        }
        if(!this.product || !this.type || !this.model){
            this.modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
        }
    }

    handleFind(){
        if(this.product && this.type && this.model){
            this.models.forEach(element => {
                if(element.value === this.model){
                    this.modelLabel = element.label;
                }
            });
            let label = 'Honda ' + this.modelLabel + ' ' + this.product;
            const prod = {'divisionId': this.division.divisionId.slice(0, -1), 'division': this.division.divisionName, 'year': this.type, 'model': this.modelLabel, 'type': this.type, 'nickname': this.type + (this.type ? ' ' : '') + this.modelLabel, 'breadcrumbLabel': label};
            addProduct(prod);
        }
    }
}
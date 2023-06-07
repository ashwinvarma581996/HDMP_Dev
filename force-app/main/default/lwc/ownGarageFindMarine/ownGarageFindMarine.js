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
import { addProduct,ISGUEST } from 'c/ownDataUtils';
import getDivisionMarine from '@salesforce/apex/OwnGarageController.getDivisionMarine';
import getOutboardsMarine from '@salesforce/apex/OwnGarageController.getOutboardsMarine';
import getModelsMarine from '@salesforce/apex/OwnGarageController.getModelsMarine';

const FIND_BRAND_BUTTON_ACTIVE = 'find-brand-button-active';
const FIND_BRAND_BUTTON_DISABLED = 'find-brand-button-disabled';

export default class OwnGarageFindMarine extends OwnBaseElement {
    @track division;
    @track modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @track outboards;
    @track outboard;
    @track outboardLabel;
    @track models;
    @track model;
    @track modelLabel;

    @wire(getDivisionMarine)
    wiredGetDivisionMarine({ error, data }) {
        if (data) {
            this.division = data;
        } else if (error) {
            this.showToast_error(error);
        }
    }

    @wire(getOutboardsMarine)
    wiredGetOutboardsMarine({ error, data }) {
        if (data) {
            this.outboards = data;
        } else if (error) {
            this.showToast_error(error);
            this.outboards = undefined;
            this.outboard = undefined;
        }
    }

    handleOutboardChange(event){
        this.outboardLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.outboard = event.detail.value;
        this.model = undefined;
        this.handleFindAndSection();
        getModelsMarine({ year: parseInt(this.outboard) })
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
        if(this.outboard && this.model){
            this.modelFindButtonClass = FIND_BRAND_BUTTON_ACTIVE;
        }
        if(!this.outboard && !this.model){
            this.modelFindButtonClass = FIND_BRAND_BUTTON_DISABLED;
        }
    }

    handleFind(){
        if(this.outboard && this.model){
            this.models.forEach(element => {
                if(element.value === this.model){
                    this.modelLabel = element.label;
                }
            });
            let label = 'Honda Marine ' + this.outboardLabel +' Outboard Motors';
            const prod = {'divisionId': this.division.divisionId, 'division': this.division.divisionName, 'year': this.outboard, 'model': this.modelLabel, 'nickname': this.modelLabel, 'breadcrumbLabel': label};
          // if(ISGUEST){ addProduct(prod);}
          addProduct(prod);
        }
    }
}
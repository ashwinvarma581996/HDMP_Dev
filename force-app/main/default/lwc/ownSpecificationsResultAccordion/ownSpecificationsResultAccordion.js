import { api, track, LightningElement } from 'lwc';
import {OwnBaseElement} from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";

export default class OwnSpecificationsResultAccordion extends OwnBaseElement {

    //@api subcategory;
    @api vehicletrim;
    @api showtrimlist;
    @api modellist;
    @track selectedTrimName = 'Pioneer 1000 specifications';

    @track selectedModel;
    @track selectedSectionId;
    @track subcategories;
    @track selectedSectionIds=[];

    @track rightArrow = commonResources + '/Icons/right_arrow.svg';

    handleSectionSelect(event){
        let selectedSectionId = event.detail;
        // if the user clicks the currently selected section again, close it; otherwise, open the section clicked by the user
        this.selectedSectionId = (selectedSectionId != this.selectedSectionId) ? selectedSectionId : '';
        //console.log('HandleSectionSelect' + this.selectedSectionId);
        if (this.selectedSectionIds.includes(selectedSectionId)) {
            const index = this.selectedSectionIds.indexOf(selectedSectionId);
            if (index > -1) {
                this.selectedSectionIds.splice(index, 1);
            }
        } else {
            this.selectedSectionIds.push(selectedSectionId);
        }
    }

    connectedCallback(){
        //console.log('Selected Trim ', this.vehicletrim);
        //console.log('Show Trim List ', this.showtrimlist);
        this.initialize();
    
    }
    
    initialize = async () => {    
        setTimeout(() => { 
        this.modellist.forEach( ob => {
            if(ob.modelName == this.vehicletrim){
                this.selectedModel = ob;
                this.subcategories = ob.specCats;
            }
        })
        //console.log('Selected Model ', JSON.stringify(this.selectedModel));
        //console.log('Selected Model Specification Categories', JSON.stringify(this.subcategories));
        }, 2000);
    }

}
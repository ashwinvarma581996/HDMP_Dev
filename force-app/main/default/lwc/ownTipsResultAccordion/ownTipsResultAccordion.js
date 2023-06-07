import { api, track, LightningElement } from 'lwc';
import {OwnBaseElement} from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";

export default class ownTipsResultAccordion extends OwnBaseElement {

    @api subcategory;
    @track selectedSectionId;
    @track isSingleArray = false;

    @track rightArrow = commonResources + '/Icons/right_arrow.svg';

    connectedCallback() {
        //console.log('$Tips: ownTipsResultAccordion:: subcategory - ', JSON.parse(JSON.stringify(this.subcategory)));
        if(this.subcategory && this.subcategory.label != 'Popular Tips'){
            if(this.subcategory.results && this.subcategory.results.length == 1){
                //console.log('$Tips: ownTipsResultAccordion:: this.subcategory.results 1 Length Array - ',this.subcategory.results);
                this.isSingleArray = true;
            }
        }
    }

    handleSectionSelect(event){
        let selectedSectionId = event.detail;
        //console.log('$Tips: ownTipsResultAccordion:: selectedSectionId - ', selectedSectionId);
        // if the user clicks the currently selected section again, close it; otherwise, open the section clicked by the user
        this.selectedSectionId = (selectedSectionId != this.selectedSectionId) ? selectedSectionId : '';
        //console.log(this.selectedSectionId);
    }
}
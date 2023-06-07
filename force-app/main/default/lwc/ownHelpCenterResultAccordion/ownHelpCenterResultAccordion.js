import { api, track, LightningElement } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";

export default class OwnHelpCenterResultAccordion extends OwnBaseElement {

    @api subcategory;
    @track selectedSectionId;

    @track rightArrow = commonResources + '/Icons/right_arrow.svg';

    handleSectionSelect(event) {
        let selectedSectionId = event.detail;
        //console.log('event.detail', event.detail);

        // if the user clicks the currently selected section again, close it; otherwise, open the section clicked by the user
        this.selectedSectionId = (selectedSectionId != this.selectedSectionId) ? selectedSectionId : '';
        //console.log(this.selectedSectionId);
    }
}
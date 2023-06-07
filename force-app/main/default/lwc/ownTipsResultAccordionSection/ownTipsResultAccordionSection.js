import { api, track, LightningElement } from 'lwc';
import {OwnBaseElement} from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";

const OPEN_ACCORDION_SECTION = "section selected-background slds-accordion__section slds-is-open";
const CLOSED_ACCORDION_SECTION = "section section-closed slds-accordion__section";

const OPEN_SECTION_TITLE = "selected-title slds-accordion__summary-content";
const CLOSED_SECTION_TITLE = "slds-accordion__summary-content";

export default class ownTipsResultAccordionSection extends OwnBaseElement {

    @api selectedSectionId;
    @api result;
    @api isSingleArray;
    @track isLoaded = false;

    @track rightArrow = commonResources + '/Icons/right_arrow.svg';

    connectedCallback() {
        //console.log('$Tips: ownTipsResultAccordionSection:: isSingleArray - ', this.isSingleArray);
        // console.log('$Tips: ownTipsResultAccordionSection:: result - ', this.result);
    }

    get sectionClass(){
        if(this.isSingleArray){
            return OPEN_ACCORDION_SECTION;
        }else if((window.location.search == '?isFuelRecommendation=true' || window.location.search == '?isFuelRecommendation=true&tab=sm') && this.result.title.includes('Fuel Recommendations') && !this.isLoaded){
            this.isLoaded = true;
            this.handleSectionClick();
            return OPEN_ACCORDION_SECTION;
        }else{
            return (this.selectedSectionId === this.result.id) ? OPEN_ACCORDION_SECTION : CLOSED_ACCORDION_SECTION;
        }
        //return (this.selectedSectionId === this.result.id) ? OPEN_ACCORDION_SECTION : CLOSED_ACCORDION_SECTION;
    }

    get sectionTitleClass(){
        return (this.selectedSectionId === this.result.id) ? OPEN_SECTION_TITLE : CLOSED_SECTION_TITLE;
    }

    handleSectionClick(){
        //console.log(JSON.stringify(this.result));
        this.dispatchEvent(new CustomEvent('sectionselect', {detail: this.result.id}));
    }
}
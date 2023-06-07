import { api, track, LightningElement } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";

const OPEN_ACCORDION_SECTION = "section  slds-accordion__section slds-is-open accordian_section";
const CLOSED_ACCORDION_SECTION = "section section-closed slds-accordion__section";

const OPEN_SECTION_TITLE = "selected-title slds-accordion__summary-content";
const CLOSED_SECTION_TITLE = "slds-accordion__summary-content";

export default class OwnSpecificationsResultAccordionSection extends OwnBaseElement {

    @api selectedSectionId;
    @api result;
    @api showtrimlist;
    @api selectedSectionIds=[];
    
    noTrims = false;

    @track propertiesList = [];
    @track isSelected = false;

    // Make a variable that keeps track of the type of row detail it is and as the list iterates through each detail display that row according to type; standard, no detail, list, footer

    @track rightArrow = commonResources + '/Icons/right_arrow.svg';


    connectedCallback() {
        //console.log(JSON.stringify(this.result));
        //console.log('Result ID ' + JSON.stringify(this.result.categoryTitle));

        //Temporary to Test With Trims, uncomment for single trim view
        if(this.showtrimlist == false){
            this.noTrims = true;
        }

        this.propertiesList = this.result.body;
        //console.log('Properties ' + JSON.stringify(this.propertiesList));
        //console.log('showtrimlist', this.showtrimlist);
    }

    get sectionClass() {
        //console.log('Selected Section id ' + this.selectedSectionId);
        //return (this.selectedSectionId === this.result.categoryTitle) ? OPEN_ACCORDION_SECTION : CLOSED_ACCORDION_SECTION;
        return (this.selectedSectionIds.includes(this.result.categoryTitle)) ? OPEN_ACCORDION_SECTION : CLOSED_ACCORDION_SECTION;
    }

    get sectionTitleClass() {
      //  return (this.selectedSectionId === this.result.categoryTitle) ? OPEN_SECTION_TITLE : CLOSED_SECTION_TITLE;
       return (this.selectedSectionIds.includes(this.result.categoryTitle)) ? OPEN_SECTION_TITLE : CLOSED_SECTION_TITLE;
    }

    get isSelectedRow() {
      //  return (this.selectedSectionId === this.result.categoryTitle) ? true : false;
      return (this.selectedSectionIds.includes(this.result.categoryTitle)) ? true : false;
    }

    handleSectionClick(event) {

        //console.log('HandleSectionClick ', JSON.stringify(this.result));
        this.dispatchEvent(new CustomEvent('sectionselect', { detail: this.result.categoryTitle }));
        
    }
}
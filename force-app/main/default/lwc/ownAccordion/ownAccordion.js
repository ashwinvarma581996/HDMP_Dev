//============================================================================
// Title:   Generic Component For Accordion 
// Details:  Used on Protection Plan & Roadside Assistance 			
//--------------------------------------------------------------------------------------
//
// History:
// October 21, 2021 Abhishek Salecha (Wipro) Initial coding
//===========================================================================
import { api, LightningElement } from 'lwc';

export default class OwnAccordion extends LightningElement {
    @api heading;
    @api contentForSmallScreen;
    @api contentForLargeScreen;

    previousSection;

    toggleAccordionSection(event){
        event.preventDefault();
        let element = event.currentTarget;
        let targetId = element.dataset.targetId;
        //console.log(element.querySelector('span').classList);
        
        if(this.previousSection){
            this.previousSection.querySelector(".custom-icon").iconName = 'utility:right';
            this.previousSection.querySelector(".custom-span").innerHTML = this.previousSection.querySelector(".custom-span").innerText;
            this.previousSection.classList.remove('slds-is-open');
            this.previousSection.classList.remove('section-open');
            this.previousSection.childNodes[0].style.background = '#FFFFFF';
            this.previousSection.childNodes[1].classList.remove('custom-content');
        }

        let orderedList = window.innerWidth > 600 ? this.template.querySelector(".accordion-large") : this.template.querySelector(".accordion-small");
        
        let section = orderedList.querySelector(`[data-id="${targetId}"]`);

        //console.log('Section contains : ',section.classList);
        if(!section.classList.contains('slds-is-open')){
            element.querySelector('span').innerHTML = element.querySelector('span').innerText.bold();
            element.firstChild.iconName = 'utility:down';
            section.classList.add('slds-is-open');
            section.classList.add('section-open');
            section.childNodes[0].style.background = '#F5F5F5';
            section.childNodes[1].classList.add('custom-content');  
        }   

        this.previousSection = section;
    }
}
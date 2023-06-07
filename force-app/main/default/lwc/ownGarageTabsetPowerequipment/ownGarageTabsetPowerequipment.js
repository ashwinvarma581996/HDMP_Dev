//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Owners Garage Find - Honda Auto Body logic of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the own garage find honda body component for all community pages.
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getGarageTabsPowerEquipment from '@salesforce/apex/OwnGarageController.getGarageTabsPowerEquipment';

const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';

export default class OwnGarageTabsetPowerequipment extends OwnBaseElement {
    @track tabs = [];
    @track tab;

    @wire(getGarageTabsPowerEquipment)
    wiredgetGarageTabsPowerEquipment({ error, data }) {
        if (data) {
            const tabs = [];
            for (let i = 0; i < data.length; i++) {
                if(i === 0){
                    this.tab = data[i]
                }
                tabs.push({
                    value: `${data[i]}`,
                    label: `${data[i]}`,
                    id: `${i}___item`,
                    control: `tab-${i}`,
                    content: `Tab Content ${i}`,
                    ariaselected: i === 0 ? true : false,
                    tabindex: i === 0 ? 0 : -1,
                    itemclass: i === 0 ? 'slds-tabs_default__item ' + CSS_SLDS_IS_ACTIVE : 'slds-tabs_default__item',
                    contentclass: i === 0 ? 'slds-tabs_default__content ' + CSS_SLDS_SHOW : 'slds-tabs_default__content ' + CSS_SLDS_HIDE, 
                });
            }
            this.tabs = tabs;
        } else if (error) {
            this.showToast_error(error);
        }
    }

    handleActive(event) {
        this.tab = event.currentTarget.dataset.value; 
        this.template.querySelectorAll(".tabs li").forEach(li => {
            li.classList.remove(CSS_SLDS_IS_ACTIVE);
            li.firstChild.setAttribute('aria-selected', 'false');
            li.firstChild.setAttribute('tabindex', '-1');
            if(li.dataset.id === event.currentTarget.dataset.id){
                li.classList.add(CSS_SLDS_IS_ACTIVE);
                li.firstChild.setAttribute('aria-selected', 'true');
                li.firstChild.setAttribute('tabindex', '0');
            }
        });
        this.template.querySelectorAll(".tabs .slds-tabs_default__content").forEach(div => {
            div.classList.remove(CSS_SLDS_SHOW);
            div.classList.add(CSS_SLDS_HIDE);
            if(div.dataset.id === event.currentTarget.dataset.id){
                div.classList.add(CSS_SLDS_SHOW);
                div.classList.remove(CSS_SLDS_HIDE);
            }
        });
    }

    get isOverview() { return this.tab === 'Overview'; }; 
    get isServiceParts() { return this.tab === 'Service & Parts'; }; 
    get isRecallsWarranties() { return this.tab === 'Recalls & Warranties'; }; 
    get isResourcesDownloads() { return this.tab === 'Resources & Downloads'; };

    handleChange(event){
        this.tab = event.detail.value; 
    }
}
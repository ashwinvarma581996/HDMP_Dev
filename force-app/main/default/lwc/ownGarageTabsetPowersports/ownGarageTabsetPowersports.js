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
import getGarageTabsPowersports from '@salesforce/apex/OwnGarageController.getGarageTabsPowersports';

const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';

export default class OwnGarageTabsetPowersports extends OwnBaseElement {
    @track tabs = [];
    @track tab;

    //Added By : Abhishek Salecha on 8th October 2021
    @api
    tabsetProtectionPlanContent;

    connectedCallback(){
        //console.log('tabsetProtectionPlanContent : ', this.tabsetProtectionPlanContent);
    }

   
    selectedTabIndex = 0;
    setDefaultTabAbServiceAndParts(){
        let backLinkValue = localStorage.getItem('backlinkvalue');
        this.selectedTabIndex = backLinkValue == 'Service & Parts' ? 1 : 0;
        localStorage.removeItem('backlinkvalue');
    }

    @wire(getGarageTabsPowersports)
    wiredGetGarageTabsPowersports({ error, data }) {
        if (data) {
            this.setDefaultTabAbServiceAndParts();
            const tabs = [];
            for (let i = 0; i < data.length; i++) {
                if(i === this.selectedTabIndex){
                    this.tab = data[i]
                }
                tabs.push({
                    value: `${data[i]}`,
                    label: `${data[i]}`,
                    id: `${i}___item`,
                    control: `tab-${i}`,
                    content: `Tab Content ${i}`,
                    ariaselected: i === this.selectedTabIndex ? true : false,
                    tabindex: i === this.selectedTabIndex ? 0 : -1,
                    itemclass: i === this.selectedTabIndex ? 'slds-tabs_default__item ' + CSS_SLDS_IS_ACTIVE : 'slds-tabs_default__item',
                    contentclass: i === this.selectedTabIndex ? 'slds-tabs_default__content ' + CSS_SLDS_SHOW : 'slds-tabs_default__content ' + CSS_SLDS_HIDE, 
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
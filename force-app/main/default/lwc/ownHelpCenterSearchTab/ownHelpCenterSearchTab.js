//============================================================================
// Title:    Honda Owners Experience - Help Center
//
// Summary:  Search tab logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the search bar component for all help center pages.
//
//
// History:
// May 17, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';

export default class OwnHelpCenterSearchTab extends OwnBaseElement {
    @api categories;
    @api category = ''; // recommended changes made
    @track brandMap = new Map();

    get tabs() {
        if(this.categories){
            const tabs = [];
            for (let i = 0; i < this.categories.length; i++) {
                if(i === 0){
                    this.brandMap.set('', { label: 'Help Center', value: 'Help Center', type: 'tab' });
                    tabs.push({
                        value: '',
                        label: 'All Honda Brands',
                        id: `${i}___item`,
                        control: `tab-${i}`,
                        content: `Tab Content ${i}`,
                        ariaselected: this.category === '' ? true : false,
                        tabindex: this.category === '' ? 0 : -1,
                        itemclass: this.category === '' ? 'slds-tabs_default__item ' + CSS_SLDS_IS_ACTIVE : 'slds-tabs_default__item',
                        contentclass: this.category === '' ? 'slds-tabs_default__content ' + CSS_SLDS_SHOW + ' ' + CSS_SLDS_IS_ACTIVE : 'slds-tabs_default__content ' + CSS_SLDS_HIDE, 
                    });
                }
                this.brandMap.set(this.categories[i].name, { label: this.categories[i].label, value: this.categories[i].name, type: 'brand' });
                tabs.push({
                    value: `${this.categories[i].name}`,
                    label: `${this.categories[i].label}`,
                    id: `${i+1}___item`,
                    control: `tab-${i+1}`,
                    content: `Tab Content ${i+1}`,
                    ariaselected: this.categories[i].name === this.category ? true : false,
                    tabindex: this.categories[i].name === this.category ? 0 : -1,
                    itemclass: this.categories[i].name === this.category ? 'slds-tabs_default__item ' + CSS_SLDS_IS_ACTIVE : 'slds-tabs_default__item',
                    contentclass: this.categories[i].name === this.category ? 'slds-tabs_default__content ' + CSS_SLDS_SHOW + ' '  + CSS_SLDS_IS_ACTIVE : 'slds-tabs_default__content ' + CSS_SLDS_HIDE, 
                });
            }
            return tabs;
        }
    }

    handleActive(event) {
        this.category = event.currentTarget.dataset.value;
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
            div.classList.remove(CSS_SLDS_IS_ACTIVE);
            div.classList.add(CSS_SLDS_HIDE);
            if(div.dataset.id === event.currentTarget.dataset.id){
                div.classList.add(CSS_SLDS_SHOW);
                div.classList.add(CSS_SLDS_IS_ACTIVE);
                div.classList.remove(CSS_SLDS_HIDE);
            }
        });
        let message = {category: this.category};
        this.publishToChannel(message);
    }

    handleChange(event){
        this.category = event.detail.value;
        let message = {category: this.category};
        this.publishToChannel(message);
    }
}
//============================================================================
// Title:    Honda Owners Experience - Specifications
//
// Summary:  
//
// Details:  
//
// History:
// February 4 Brett Spokes (Wipro)
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getKnowledgeArticles, getPopularKnowledgeArticles } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';

export default class OwnSpecificationsTrimList extends OwnBaseElement {
    @api categories;
    @api brand;
    @track rightArrow = this.ownerResource() + '/Icons/right_arrow.svg';
    @track category;
    @track trim;
    @track categoryMap = new Map();
    @track tabs = [];
    @track results;
    @track maxResults = 5;
    @api modelid;

    connectedCallback() {
        //this.tabs = this.getTabs();
        //console.log('Trims ', JSON.stringify(this.categories));
        this.tabs = this.getTabs();
        //this.initializeOnLoad(false);
    }

    getTabs() {
        if (this.categories) {
            const tabs = [];
            for (let i = 0; i < this.categories.length; i++) {
                if (this.categories[i].value === this.modelid) {
                    this.category = this.categories[i].value;
                    this.trim = this.categories[i].label;
                    let selectedTrim = this.trim;
                    //console.log('@@getTabs this.category, this.trim, selectedTrim', this.category, this.trim, selectedTrim)
                    localStorage.setItem('AdobeData', this.trim)
                    const selectedEvent = new CustomEvent('trimselect', {
                        detail: {
                            trim: selectedTrim,
                            modelId: this.category
                        }
                    });
                    this.dispatchEvent(selectedEvent);
                }
                tabs.push({
                    value: `${this.categories[i].value}`,
                    label: `${this.categories[i].label}`,
                    id: `${i + 1}___item`,
                    control: `tab-${i + 1}`,
                    content: `Tab Content ${i + 1}`,
                    ariaselected: this.categories[i].value === this.category ? true : false,
                    tabindex: this.categories[i].value === this.category ? 0 : -1,
                    itemclass: this.categories[i].value === this.category ? 'slds-vertical-tabs__nav-item ' + CSS_SLDS_IS_ACTIVE : 'slds-vertical-tabs__nav-item',
                });
            }
            return tabs;
        }
    }

    handleActive(event) {
        this.category = event.currentTarget.dataset.value;
        this.trim = event.currentTarget.dataset.id;
        //console.log('Dataset id', this.trim);
        //console.log('@@getTabs this.category', this.trim)

        let page = { sub_section2: this.trim };
        let message = { eventType: DATALAYER_EVENT_TYPE.LOAD, page: page };
        this.publishToChannel(message);
        this.template.querySelectorAll(".tabs li").forEach(li => {
            li.classList.remove(CSS_SLDS_IS_ACTIVE);
            li.firstChild.setAttribute('aria-selected', 'false');
            li.firstChild.setAttribute('tabindex', '-1');
            if (li.dataset.id === event.currentTarget.dataset.id) {
                li.classList.add(CSS_SLDS_IS_ACTIVE);
                li.firstChild.setAttribute('aria-selected', 'true');
                li.firstChild.setAttribute('tabindex', '0');
            }
        });
        this.template.querySelectorAll(".tabs .slds-vertical-tabs__content").forEach(div => {
            div.classList.remove(CSS_SLDS_SHOW);
            div.classList.remove(CSS_SLDS_IS_ACTIVE);
            div.classList.add(CSS_SLDS_HIDE);
            if (div.dataset.id === event.currentTarget.dataset.id) {
                div.classList.add(CSS_SLDS_SHOW);
                div.classList.add(CSS_SLDS_IS_ACTIVE);
                div.classList.remove(CSS_SLDS_HIDE);
            }
        });
        //this.handlePublishMessage(false);

        let selectedTrim = this.trim;
        const selectedEvent = new CustomEvent('trimselect', {
            detail: {
                trim: selectedTrim,
                modelId: this.category,
                tab: event.currentTarget.dataset.tab
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleSelect(event) {
        this.category = event.currentTarget.dataset.value;
        //this.handlePublishMessage(true);
    }

    handlePublishMessage(showResult) {
        this.initialize(showResult);
    }

    initialize = async (showResult) => {
        this.results = await getKnowledgeArticles(this.category);
        this.categoryMap.set(this.category, { label: this.categoryMap.get(this.category).label, value: this.categoryMap.get(this.category).value, results: this.results });
        let message = { subcategory: this.categoryMap.get(this.category), showResult: showResult, brand: this.brand };
        this.publishToChannel(message);
    };

    initializeOnLoad = async (showResult) => {
        this.results = await getKnowledgeArticles(this.category);
        this.categoryMap.set(this.category, { label: this.categoryMap.get(this.category).label, value: this.categoryMap.get(this.category).value, results: this.results });
        let message = { subcategory: this.categoryMap.get(this.category), showResult: showResult, brand: this.brand };
        this.publishToChannel(message);
    };
}
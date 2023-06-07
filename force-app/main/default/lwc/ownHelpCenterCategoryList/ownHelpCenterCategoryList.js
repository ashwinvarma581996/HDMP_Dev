//============================================================================
// Title:    Honda Owners Experience - Help Center
//
// Summary:  category list logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the category list component for all help center pages.
//
//
// History:
// June 16, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getKnowledgeArticles, getPopularKnowledgeArticles } from 'c/ownDataUtils';
import { CurrentPageReference } from 'lightning/navigation';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';

export default class OwnHelpCenterCategoryList extends OwnBaseElement {
    @api categories;
    @api brand;
    @track rightArrow = this.ownerResource() + '/Icons/right_arrow.svg';
    @track category;
    @track categoryMap = new Map();
    @track tabs = [];
    @track results;
    @track maxResults = 5;
    @track dc;
    currentPageReference = null;
    urlStateParameters = null;

    connectedCallback() {
        this.tabs = this.getTabs();
        this.initializeOnLoad(false);
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.dc = this.urlStateParameters.dc || null;
    }

    getTabs() {
        if (this.categories) {
            const tabs = [];
            let dataCategoryExist = false;
            this.categories.forEach(category => {
                if (category.name === this.brand.value) {
                    for (let i = 0; i < category.categories.length; i++) {
                        this.categoryMap.set(category.categories[i].name, { label: category.categories[i].label, value: category.categories[i].name });
                        if (i === 0 && !this.dc) {
                            this.category = category.categories[i].name;
                        }
                        if (category.categories[i].name === this.dc) {
                            dataCategoryExist = true;
                        }
                        tabs.push({
                            value: `${category.categories[i].name}`,
                            label: `${category.categories[i].label}`,
                            id: `${i + 1}___item`,
                            control: `tab-${i + 1}`,
                            content: `Tab Content ${i + 1}`,
                            ariaselected: (category.categories[i].name === this.category || category.categories[i].name === this.dc) ? true : false,
                            tabindex: (category.categories[i].name === this.category || category.categories[i].name === this.dc) ? 0 : -1,
                            itemclass: (category.categories[i].name === this.category || category.categories[i].name === this.dc) ? 'slds-vertical-tabs__nav-item ' + CSS_SLDS_IS_ACTIVE : 'slds-vertical-tabs__nav-item',
                        });
                    }
                }
            });
            if (dataCategoryExist) {
                this.category = this.dc;
            }
            return tabs;
        }
    }

    handleActive(event) {
        //console.log('@@ category', event.currentTarget.dataset.value, this.categoryMap.get(this.category))
        this.removeUrlParameter('dc');
        this.category = event.currentTarget.dataset.value;
        let page = { sub_section2: this.categoryMap.get(this.category).label }
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
        this.handlePublishMessage(false, page);
    }

    handleSelect(event) {
        this.category = event.currentTarget.dataset.value;
        let page = { sub_section2: this.categoryMap.get(this.category).label };
        this.handlePublishMessage(true, page);
    }

    removeUrlParameter(selectedParam) {
        let newURL = location.href.split("?")[0];
        if (location.href.split("?")[1]) {
            let currentParams = location.href.split("?")[1].split("&");
            //console.log('CurrentParams : ', currentParams);
            let newParams = '?';
            currentParams.forEach(para => {
                if (!para.includes(selectedParam)) {
                    newParams += (para + '&');
                }
            });
            newParams = newParams.substring(0, newParams.length - 1);
            window.history.pushState('object', document.title, newURL + newParams);
        }
    }

    handlePublishMessage(showResult, page) {
        this.initialize(showResult, page);
    }

    initialize = async (showResult, page) => {
        if (this.category.includes('PopularArticles')) {
            this.results = await getPopularKnowledgeArticles(this.brand.value, this.maxResults);
        } else {
            this.results = await getKnowledgeArticles(this.category, 40000);
        }
        this.categoryMap.set(this.category, { label: this.categoryMap.get(this.category).label, value: this.categoryMap.get(this.category).value, results: this.results });
        let message = { subcategory: this.categoryMap.get(this.category), showResult: showResult, brand: this.brand, eventType: DATALAYER_EVENT_TYPE.LOAD, page: page };
        this.publishToChannel(message);
    };

    initializeOnLoad = async (showResult) => {
        if (this.category.includes('PopularArticles')) {
            this.results = await getPopularKnowledgeArticles(this.brand.value, this.maxResults);
        } else {
            this.results = await getKnowledgeArticles(this.category, 40000);
        }
        this.categoryMap.set(this.category, { label: this.categoryMap.get(this.category).label, value: this.categoryMap.get(this.category).value, results: this.results });
        let message = { subcategory: this.categoryMap.get(this.category), showResult: showResult };
        this.publishToChannel(message);
    };
}
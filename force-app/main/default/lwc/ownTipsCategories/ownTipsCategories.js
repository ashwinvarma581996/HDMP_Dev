import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getKnowledgeArticles, getPopularKnowledgeArticles, getPopularTipsArticles } from 'c/ownDataUtils';
//import getPopularTipsArticles from '@salesforce/apex/OwnHelpCenterController.getPopularTipsArticles';
import { CurrentPageReference } from 'lightning/navigation';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';

export default class ownTipsCategories extends OwnBaseElement {

    @api categories;
    @api brand;
    @api formFactor;
    @track rightArrow = this.ownerResource() + '/Icons/right_arrow.svg';
    @track category;
    @track categoryMap = new Map();
    @track tabs = [];
    @track results;
    @track maxResults = 10;
    @track dc;
    currentPageReference = null;
    urlStateParameters = null;


    get categoriesLoaded() {
        return this.categories ? true : false;
    }



    connectedCallback() {
        let defaultCategoryName = sessionStorage.getItem('tipsDefaultCategory');
        //console.log('ownTipsCategories:: categories ', JSON.stringify(this.categories));
        //console.log('ownTipsCategories:: categories ', defaultCategoryName);
        if (defaultCategoryName) {

            this.dc = defaultCategoryName;
        }
        //console.log('ownTipsCategories:: ', JSON.stringify(this.category));

        this.tabs = this.getTabs();
        //console.log('$Tips: ownTipsCategories:: tabs', this.tabs ? JSON.parse(JSON.stringify(this.tabs)) : this.tabs);
        if (window.location.href.includes('tips-power-equipment')) {
            this.category = this.tabs[0].value;
            this.handlePublishMessage(true);
        } else if ((window.location.search == '?isFuelRecommendation=true' || window.location.search == '?isFuelRecommendation=true&tab=sm') && window.matchMedia("(max-width: 600px)").matches) {
            let index = this.tabs.findIndex(x => x.label === "Fuel Recommendations");
            //console.log('$Tips: ownTipsCategories:: index', index);
            if (index != -1) {
                this.category = this.tabs[index].value;
                this.handlePublishMessage(true);
            }
        }
        this.initializeOnLoad(false);
    }


    getTabs() {
        //console.log('ownHelpCenterCategoryList:: categories ', JSON.stringify(this.categories));
        if (this.categories) {
            const tabs = [];
            let dataCategoryExist = false;
            for (let i = 0; i < this.categories.length; i++) {
                this.categoryMap.set(this.categories[i].name, { label: this.categories[i].label, value: this.categories[i].name });
                if (i === 0 && !this.dc) {
                    this.category = this.categories[i].name;
                }
                if (this.categories[i].name === this.dc) {
                    dataCategoryExist = true;
                }
                tabs.push({
                    value: `${this.categories[i].name}`,
                    label: `${this.categories[i].label}`,
                    id: `${i + 1}___item`,
                    control: `tab-${i + 1}`,
                    content: `Tab Content ${i + 1}`,
                    ariaselected: (this.categories[i].name === this.category || this.categories[i].name === this.dc) ? true : false,
                    tabindex: (this.categories[i].name === this.category || this.categories[i].name === this.dc) ? 0 : -1,
                    itemclass: (this.categories[i].name === this.category || this.categories[i].name === this.dc) ? 'slds-vertical-tabs__nav-item ' + CSS_SLDS_IS_ACTIVE : 'slds-vertical-tabs__nav-item',
                });
            }
            if (dataCategoryExist) {
                this.category = this.dc;
            }
            else {
                this.category = this.categories[0].name;
            }
            return tabs;
        }
    }

    handleActive(event) {
        this.category = event.currentTarget.dataset.value;
        let page = { sub_section2: event.currentTarget.dataset.label };

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
        let page = { sub_section2: event.currentTarget.dataset.label };
        //console.log('$Tips: category', this.category);
        //console.log('$Tips: category from tab', this.tabs[0].value);
        this.handlePublishMessage(true, page);
    }


    handlePublishMessage(showResult, page) {
        this.initialize(showResult, page);
    }

    initialize = async (showResult, page) => {
        //console.log('ownTipsCategories:: category ', JSON.stringify(this.category));
        if (this.category.includes('PopularTips')) {
            this.results = await getPopularTipsArticles(this.brand, this.maxResults);
        } else {
            //console.log('@@@2: ', this.category);
            this.results = await getKnowledgeArticles(this.category, 40000);
        }
        this.categoryMap.set(this.category, { label: this.categoryMap.get(this.category).label, value: this.categoryMap.get(this.category).value, results: this.results });
        let message = {};
        if (window.location.pathname.includes('/tips-power-equipment')) {
            message = this.formFactor != 'mobile' ? { subcategory: this.categoryMap.get(this.category), showResult: showResult, brand: this.brand }
                : { subcategory: this.categoryMap.get(this.category), showResult: showResult, brand: this.brand, mobile: true };
        } else {
            message = this.formFactor != 'mobile' ? { subcategory: this.categoryMap.get(this.category), showResult: showResult, brand: this.brand, eventType: DATALAYER_EVENT_TYPE.LOAD, page: page }
                : { subcategory: this.categoryMap.get(this.category), showResult: showResult, brand: this.brand, mobile: true, eventType: DATALAYER_EVENT_TYPE.LOAD, page: page };
        }
        //console.log('ownPageHeader:: ownTipsCategories publishing message ', JSON.stringify(message.mobile));
        this.publishToChannel(message);
    };

    initializeOnLoad = async (showResult) => {
        //console.log('ownTipsCategories:: category ', JSON.stringify(this.category));
        if (this.category.includes('PopularTips')) {
            this.results = await getPopularTipsArticles(this.brand, this.maxResults);
        } else {
            //console.log('@@@2: ', this.category);
            this.results = await getKnowledgeArticles(this.category, 40000);
        }
        this.categoryMap.set(this.category, { label: this.categoryMap.get(this.category).label, value: this.categoryMap.get(this.category).value, results: this.results });
        let message = { subcategory: this.categoryMap.get(this.category), showResult: showResult };
        this.publishToChannel(message);
    };
}
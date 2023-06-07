import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
/* import tips_table_css from '@salesforce/resourceUrl/tips_table_css';
import { loadStyle } from 'lightning/platformResourceLoader'; */

export default class ownTipsResults extends OwnBaseElement {

    @api brand;
    @api subcategory;
    @track subcategory1 = {};
    @track rightArrow = this.ownerResource() + '/Icons/right_arrow.svg';
    @api isFuelRecommendation;
    get isMixedCategory() {
        return this.subcategory.label === 'Popular Articles & FAQs' ? true : false;
    }

    get showMultipleResults() {
        if (this.subcategory && this.subcategory.results) {
            return this.subcategory.results.length > 1;
        }
        else {
            return false;
        }
    }

    get showSingleResult() {
        if (this.subcategory && this.subcategory.results) {
            return this.subcategory.results.length === 1;
        }
        else {
            return false;
        }
    }

    get singleArticle() {
        return this.subcategory.results[0];
    }

    connectedCallback() {
        //console.log('ownTipsResults:: Results:', JSON.parse(JSON.stringify(this.subcategory.results)), this.isFuelRecommendation);
        if (this.isFuelRecommendation && window.location.href.includes('tips-power-equipment')) {
            let newArray = [];
            let fuelREC;
            this.subcategory.results.forEach(element => {
                if (!element.title.includes('Fuel Recommendations')) {
                    newArray.push(element);
                } else {
                    fuelREC = element;
                }
            });
            newArray.unshift(fuelREC);
            this.subcategory1.label = this.subcategory.label;
            this.subcategory1.results = newArray;
        } else {
            this.subscribeToChannel((message) => {
                if (message.subcategory) {
                    this.subcategory1.label = message.subcategory.label;
                    this.subcategory1.results = message.subcategory.results;
                }
            });
            //this.subcategory1.label = this.subcategory.label;
            //this.subcategory1.results = this.subcategory.results;
        }

        //console.log('ownTipsResults:: Results1:', JSON.parse(JSON.stringify(this.subcategory1.results)));
        /* if (this.subcategory.results.length === 0){
            console.log('ownTipsResults:: No articles retrieved.');
        } */
        /*         this.template.querySelector('table').forEach(element => {
                    console.log('@@@' + JSON.stringify(element));
                    element.style = 'width: 100px';
                }) */
    }

    /* renderedCallback() {
        loadStyle(this, tips_table_css + '/tips_table_css');
    } */

    handleClick(event) {
        let id = event.currentTarget.dataset.id;
        this.navigate('/article?id=' + id + '&' + 'brand=' + this.brand.brandName, {});
    }

}
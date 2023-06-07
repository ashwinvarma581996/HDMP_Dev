//============================================================================
// Title:    Honda Owners Experience - Common Base Element
//
// Summary:  Help Center Category list and result logic to support Honda's Salesforce Community for Owners Experience
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein
//
//
// History:
// June 16, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getDataCategories from '@salesforce/apex/OwnHelpCenterController.getDataCategories';
import { brandDataCategoryMap } from 'c/ownDataUtils';

export default class OwnHelpCenterBrand extends OwnBaseElement {
    @track categories;
    @api brandLabel;
    @track brand;
    @track subcategory;
    @track showResult = false;
    @track showSearchResult = false;
    @track category;

    connectedCallback(){
        this.subscribeToChannel((message) => {  
            if(message.subcategory){
                this.subcategory = message.subcategory;
                this.showResult = message.showResult;
            }
            if(message.showSearchResult === true || message.showSearchResult === false){
                this.showSearchResult = message.showSearchResult;
            }       
        });
    }

    @wire(getDataCategories)
    wiredGetDataCategories(result) {
        if (result.data) {
            this.categories = result.data;
            this.category = this.brandLabel.split(' ').join('');
            this.brand = { label: this.brandLabel + ' Help Articles & FAQs', value: this.category, url: brandDataCategoryMap.get(this.category).url, type: 'brand', brandLabel: this.brandLabel, brandName: brandDataCategoryMap.get(this.category).name };
            let message = {category: this.category};
            this.publishToChannel(message);
        } else if (result.error) {
            this.categories = undefined;
        }
    }
}
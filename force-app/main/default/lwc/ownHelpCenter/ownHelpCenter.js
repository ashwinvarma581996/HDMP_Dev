//============================================================================
// Title:    Honda Owners Experience - Common Base Element
//
// Summary:  Help Center logic to support Honda's Salesforce Community for Owners Experience
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein
//
//
// History:
// May 17, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getDataCategories from '@salesforce/apex/OwnHelpCenterController.getDataCategories';

export default class OwnHelpCenter extends OwnBaseElement {
    @track categories;
    @track searchCategory;
    @track showSearchResult = false;


    connectedCallback() { 
        this.subscribeToChannel((message) => {           
            if(message.showSearchResult === true || message.showSearchResult === false){
                this.showSearchResult = message.showSearchResult;
            }
        });
    }
    
    @wire(getDataCategories)
    wiredGetDataCategories(result) {
        if (result.data) {
            this.categories = result.data;
        } else if (result.error) {
            this.categories = undefined;
        }
    }
    
    handleSearchCategory(event){
        // recommended changes made
        //console.log('SEARCH CATEGORY');
        this.searchCategory = event.detail;
        //console.log(this.searchCategory);
    }
}
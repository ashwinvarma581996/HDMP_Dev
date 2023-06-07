//============================================================================
// Title:    Honda Owners Experience - Help Center
//
// Summary:  category result logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the category result component for all help center pages.
//
//
// History:
// June 16, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { search } from 'c/ownDataUtils';

const SORT_BYS = [
    {'label': 'Relevance', 'value': 'LastPublishedDate'},
    {'label': 'Article Title', 'value': 'Title'},
    {'label': 'Summary', 'value': 'Summary'},
    {'label': 'Article Number', 'value': 'ArticleNumber'},
    {'label': 'Publication Status', 'value': 'PublishStatus'},
];

export default class OwnHelpCenterSearchResults extends OwnBaseElement {
    @track sortBy = 'LastPublishedDate';
    @track sortBys = SORT_BYS;
    @track results;
    @track searchKey = localStorage.getItem('searchKey');
    @track resultsCount;
    @track hasResults = true;
    @track maxResults = 15;
    @api category;
    @track hideShowMore = false;

    get contactUsLink(){
        //console.log('getContactUsLink');
        //console.log(this.category);
        if (this.category && this.category.toLowerCase().includes('acura')){
            //console.log('returning Acura link');
            return '/help-acura';
        }
        else if (this.category && this.category.toLowerCase().includes('powersports')){
            //console.log('returning Powersports link');
            return '/help-powersports';
            //return 'https://powersports.honda.com/contact-us';
        }
        else if (this.category && this.category.toLowerCase().includes('powerequipment')){
            //console.log('returning Powerequipment link');
            return '/help-powerequipment';
            //return 'https://powerequipment.honda.com/support/contact-us';
        }
        else if (this.category && this.category.toLowerCase().includes('marine')){
            //console.log('returning Marine link');
            return '/help-marine';
            //return 'https://marine.honda.com/company/contact-us';
        }
        else if (this.category && this.category.toLowerCase().includes('honda')){
            //console.log('returning Honda link');
            return '/help-honda';
        }
        else{
            //console.log('returning Honda link');
            return '/help-honda';
        }
    }

    handleContactUs(){
        //console.log(1);
        this.navigate(this.contactUsLink, {});
    }

    connectedCallback(){
        //console.log('ownHelpCenterSearchResults: connectedCallback');
        //console.log(this.category);
        if (localStorage.getItem('helpSearchCategory')){
            this.category = localStorage.getItem('helpSearchCategory');
            //console.log(JSON.stringify(this.category));
            localStorage.removeItem('helpSearchCategory');
        }
        this.subscribeToChannel((message) => { 
            if(message.showSearchResult || (message.category || message.category === '')){
                this.searchKey = localStorage.getItem('searchKey');
                this.category = message.category;
                this.maxResults = 15;
                this.initialize(this.searchKey, this.category, this.sortBy, this.maxResults);
            }
        });
        this.initialize(this.searchKey, this.category, this.sortBy, this.maxResults);
    }

    initialize = async (searchKey, category, sortBy, maxResults) => {
        this.results = await search(searchKey, category, sortBy, maxResults);
        this.resultsCount = '(' + this.results.length + (this.results.length === 0 ? '' : this.results.length > 15 ? '+' : '') + ' ' + 'RESULTS)';
        if(this.results.length > 0){
            this.hasResults = true;
        }else{
            this.hasResults = false;
        }
        if(this.maxResults > this.results.length){
            this.hideShowMore = true;
        }else{
            this.hideShowMore = false;
        }
    };

    handleChange(event){
        this.sortBy = event.detail.value;
        this.initialize(this.searchKey, this.category, this.sortBy, this.maxResults);
    }

    handleClick(event){
        let id = event.currentTarget.dataset.id;
        let urlName = event.currentTarget.dataset.urlname;
        this.navigate('/article/' + urlName + '?' + 'brand=' + (this.category ? this.category : 'Honda'), {});
    }

    handleClickShowMore(){
        this.maxResults += 15;
        this.initialize(this.searchKey, this.category, this.sortBy, this.maxResults);
    }
}
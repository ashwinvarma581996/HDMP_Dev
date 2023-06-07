//============================================================================
// Title:    Honda Owners Experience - Help Center
//
// Summary:  Search bar logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the search bar component for all help center pages.
//
//
// History:
// May 17, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { search } from 'c/ownDataUtils';
import FORM_FACTOR from '@salesforce/client/formFactor';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;

const CSS_SLDS_IS_OPEN = 'slds-is-open';

export default class OwnHelpCenterSearchBar extends OwnBaseElement {
    @track title = 'Honda Help Center';
    @api brand;
    @track searchKey = '';
    @track searchKeyMobile = '';
    @track results;
    @track category = '';
    @track sortBy = 'LastPublishedDate';
    @track hasResults = false;
    isEnterPressed = false;

    get isMobile(){
        return FORM_FACTOR === 'Small' ? true : false;
    }

    connectedCallback(){
        if(this.brand){
            this.title = this.brand.type === 'global' ? 'Honda Help Center' : this.brand.label;
            this.category = this.brand.type === 'global' ? '' : this.brand.value;
        }
        this.subscribeToChannel((message) => {  
            if(message.brand){
                this.brand = message.brand;
                this.title = this.brand.type === 'global' ? 'Honda Help Center' : this.brand.label;
            } 
            if(message.category || message.category === ''){
                this.category = message.category;
            } 
        });
        //console.log(sessionStorage.getItem('ownHelpSearchBarRedirectKey'));
        if (sessionStorage.getItem('ownHelpSearchBarRedirectKey')){
            //console.log('in redirect block');
            let redirectKey = sessionStorage.getItem('ownHelpSearchBarRedirectKey');
            //console.log('redirect key ' + redirectKey);
            this.searchKey = redirectKey;
            this.searchKeyMobile = redirectKey;
            sessionStorage.removeItem('ownHelpSearchBarRedirectKey');
            this.initialize(this.searchKey, this.category, this.sortBy, 15);
/*             const searchEl = this.template.querySelector('.search');
            searchEl.classList.remove(CSS_SLDS_IS_OPEN); */
            if(!this.brand){
                this.brand = { label: 'Help Center', value: 'Help Center', type: 'global', 'url': '/help-center' }
            }
            let message = {showSearchResult: true, category: this.category, brand: this.brand};
            this.publishToChannel(message);
        }
    }

    handleKeyChange(event) {
        if(!event.target.value){
            if(this.isEnterPressed){
                if(this.brand){
                    if(this.brand.type === 'global'){
                        this.navigate('/help-center', {});
                    }
                    if(this.brand.type === 'brand'){
                        this.navigate(this.brand.url, {});
                    }
                }
            }
        }
        this.hasResults = false;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.searchKey = searchKey;
        this.searchKeyMobile = this.searchKey;
        localStorage.setItem('searchKey', this.searchKey);
        if(searchKey.length > 3){
            this.delayTimeout = setTimeout(() => {
                const searchEl = this.template.querySelector('.search');
                searchEl.classList.add(CSS_SLDS_IS_OPEN);
                this.initialize(this.searchKey, this.category, this.sortBy, 5);
                
            }, DELAY);
        }else{
            const searchEl = this.template.querySelector('.search');
            searchEl.classList.remove(CSS_SLDS_IS_OPEN);
        }
    }

    initialize = async (searchKey, category, sortBy, maxResults) => {
        this.results = await search(searchKey, category, sortBy, maxResults);
        if(this.results.length > 0){
            this.hasResults = true;
        }
    };

    handleSearch(event) {
        const isSearch = event.currentTarget.dataset.search;
        if (event.which == 13 || isSearch === 'true') {
            if(this.searchKey){
                this.isEnterPressed = true;
                this.initialize(this.searchKey, this.category, this.sortBy, 15);
                const searchEl = this.template.querySelector('.search');
                searchEl.classList.remove(CSS_SLDS_IS_OPEN);
                if(!this.brand){
                    this.brand = { label: 'Help Center', value: 'Help Center', type: 'global', 'url': '/help-center' }
                }
                let message = {showSearchResult: true, category: this.category, brand: this.brand};
                this.publishToChannel(message);
            }else{
                this.handleNavigate(this.brand.type, this.brand.url);
            }
        }
    }

    handleNavigate(type, url){
        if(type === 'global'){
            this.navigate('/help-center', {});
        }
        if(type === 'brand'){
            this.navigate(url, {});
        }
    }

    handleClick(event){
        let id = event.currentTarget.dataset.id;
        let urlName = event.currentTarget.dataset.urlname;
        this.navigate('/article/' + urlName + '?' + 'brand=' + (this.brand ? this.brand.brandName : 'Honda'), {});
    }
}
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import communityId from '@salesforce/community/Id';
import fetchCategoryPath from '@salesforce/apex/B2BCategoryNavigation.fetchCategoryPath';

// Import message service features required for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import categorySelected from '@salesforce/messageChannel/Category_Selected__c';
import getDeepLink from '@salesforce/apex/B2BCategoryNavigation.getDeepLink';


export default class B2bEBBreadcrumb extends NavigationMixin(LightningElement) {

    @api recordId;

    @track
    category;

    @track urlId;

    @track
    breadCrumbs;

    @api
    showCategories;

    @api
    categories;

    @track noCategorykey = false
    
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        var urlParameters = window.location.href;
        var urlStateParameters = urlParameters.split('/').pop();
        this.urlId = urlStateParameters;
        this.fetchCategoryPath();
    }
    
    /*
    * Desc -  To fetch the category path from parent category and identify a base category for SEO categories
    */
    fetchCategoryPath(){
        let breadCrumbs = [];
        let dataMap = {
            'categoryId' : this.urlId,
            'communityId' : communityId
        };
        fetchCategoryPath({'dataMap':dataMap})
            .then((result) => {
                // seo friendly category page
                if(result.isSuccess && result.categories){
                    result.categories.path.forEach(cat => {
                        breadCrumbs.push({
                            'categoryId':cat.id, 
                            'categoryName':cat.name,
                            'categoryUrl': '/s/category/' + cat.id
                        });
                    });
                    this.breadCrumbs = breadCrumbs;
                    this.showCategories = true;
                    this.categories = breadCrumbs;       
                }
                // checks for base category to replace 'home' with brand page name
                if(result.isSuccess && result.baseCategory) {
                    this.baseCategory = result.baseCategory;
                    this.noCategorykey = false;
                    this.baseCategoryUrl = '/s/' + result.baseCategory.toLowerCase();
                    sessionStorage.setItem('isSEOCategory', true);

                    // Add session variables for deepLinking
                    this.removeDeepLink();
                    this.getDeepLink();

                } else {
                    // non-seo friendly category page
                    this.noCategorykey = true;
                    sessionStorage.setItem('isSEOCategory', false);
                }
               
                this.template.querySelector(".slds-breadcrumb").classList.add("slds-visible");
                this.template.querySelector(".slds-breadcrumb").classList.remove("slds-hidden");

                // Messaging Channel
                const payload = { categoryKey: this.noCategorykey };
                publish(this.messageContext, categorySelected, payload);
            })
            .catch((error) => {
                this.error = error;
                console.log('error:',error);
            });
    }

    /*
    * Desc -  To redirect to Home Page or category base page
    */
    redirectToHome(event){
        event.stopPropagation();
        event.preventDefault();
        if(this.baseCategory){
            var baseCategoryAPI = this.baseCategory.split(' ').join('_');
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: baseCategoryAPI + '__c'
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: "Home"
                }
            });
        }
    }

    /*
    * Desc -  To redirect to Category detail
    */

    handleNavigation(event){
        event.stopPropagation();
        event.preventDefault();
        let categoryId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: categoryId,
                actionName: 'view'
            }
        });
    }

    removeDeepLink() {
        // Clear old values
        sessionStorage.removeItem('SEO_SectionId');
        sessionStorage.removeItem('SEO_MegaCategory');
    }

    getDeepLink() {
        getDeepLink({
            'productCategoryId': this.urlId
        }).then((result) => {
            if (result && Object.keys(result).length != 0) {
                sessionStorage.setItem('SEO_SectionId', result.sectionId);
                if (result.megaCatName) {
                    sessionStorage.setItem('SEO_MegaCategory', result.megaCatName);
                }
            }
        })
        .catch((error) => {
            console.log(error);
        });
    }
    
}
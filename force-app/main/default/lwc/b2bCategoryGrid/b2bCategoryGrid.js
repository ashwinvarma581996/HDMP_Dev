import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import communityId from '@salesforce/community/Id';

import MEGACATEGORY from '@salesforce/schema/ProductCategory.Name';

import PLP_IMAGE from '@salesforce/schema/ProductCategory.Product_Listing_Hero__c';
import PLP_IMAGE_TITLE from '@salesforce/schema/ProductCategory.Product_Listing_Hero_Image_Title__c';
import PLP_IMAGE_ALT_TEXT from '@salesforce/schema/ProductCategory.Product_Listing_Hero_Image_Alt_Text__c';

import fetchCategoryPath from '@salesforce/apex/B2BCategoryNavigation.fetchCategoryPath';
import getCategoryLanding from '@salesforce/apex/B2BCategoryNavigation.getCategoryLanding';
import getProductsWithCategory from '@salesforce/apex/B2BCategoryNavigation.getProductsWithCategory';

const FIELDS = [MEGACATEGORY, PLP_IMAGE, PLP_IMAGE_TITLE, PLP_IMAGE_ALT_TEXT];
const HONDAMAINTENANCEIMAGE = '/resource/MaintenanceImages/MaintenanceImages/Honda/Thumbnail.jpg';
const ACURAMAINTENANCEIMAGE = '/resource/MaintenanceImages/MaintenanceImages/Acura/Thumbnail.jpg';
const DEFAULTIMAGE = '/resource/b2b_resources/images/dreamshop_logo.png';

export default class B2bCategoryGrid extends NavigationMixin(LightningElement) {
    
    @api record;
    
    /**
    * Gets or sets the unique identifier of a category.
    * @type {String}
    */
    @api recordId
    
    /**
    * Number of Tiles to Display for each row in the category grid
    * @type {String}
    */
    @api gridMaxColumnsDisplayed = 3;

    /**
     * Font Color of Category Title
     * @type {Color}
     */
    @api fontColor

    /**
     * Font Size of Category Title
     * @type {String}
     */
      @api fontSize

    /**
     * Font Size of Category Title
     * @type {String}
     */
      @api noResultMessage

    @api ctaNoVehicleMsg
    @api ctaVehicleSelectedMsg
    @api ctaFontSize

    /**
     * Calculates the styles of the component
     * @type {String}
     */

    @api get componentStyles() {
        let resultCSS = [];
        if (this.fontColor) {
            resultCSS.push(`color: ${this.fontColor}`);
        }
        if (this.fontSize) {
            resultCSS.push(`font-size: ${this.fontSize}`);
        }
        return resultCSS.join('; ');
    }

    get gridCustomStyles() {
        if (this.gridMaxColumnsDisplayed <= 0) {
            return 'flex-basis: 25%;';
        }
        return `flex-basis: ${100 / this.gridMaxColumnsDisplayed}%;`;
    }
    get ctaStyles() {
        if (this.ctaFontSize) {
            return `font-size: ${this.ctaFontSize}`;
        }
    }

    recordData;
    @wire(getRecord, { recordId: '$record', fields: FIELDS })
    wiredRecord({error, data}) {
        if (data) {
            this.recordData = data;
        } else if (error) {
           
        }
    }

    get plpImage() {
        return getFieldValue(this.recordData, PLP_IMAGE);
    }
    get plpImageTitle() {
        return getFieldValue(this.recordData, PLP_IMAGE_TITLE);
    }

    get plpImageAltText() {
        return getFieldValue(this.recordData, PLP_IMAGE_ALT_TEXT);
    }
   
    @track urlId;
    @track categoryList;
    @track prodList;
    @track displayCats = true;
    @track showChangeVehicleModal = false;
    @track vehicleSelected = false;
    @track maintenanceImage = DEFAULTIMAGE;
   
    closeChangeVehicleModal(event) {
        this.showChangeVehicleModal = false;
    }

    plpSelectVehicle(event){
        event.preventDefault();
        event.stopPropagation();
        this.showChangeVehicleModal = true;
        // Set session Storage for PartNumber
        let productSKU = event.target.dataset.sku;
        if (productSKU) {
            sessionStorage.removeItem('SEO_Sku');
            sessionStorage.setItem('SEO_Sku', productSKU);
        }
    }

    connectedCallback() {
        var urlParameters = window.location.href;
        let split = urlParameters.split("/");
        this.urlId = split.pop();
        this.getCategoryLanding();
    }

     getCategoryLanding(){
        getCategoryLanding({
            'communityId': communityId,
            'productCategoryId': this.urlId
        }).then(async (result) => {
            // Category has Children
            if (Array.isArray(result) && result.length) {
                var tempResult = JSON.parse(JSON.stringify(result));
                let newArray = tempResult.filter(element => element.hasOwnProperty('Section_Id__c') && element.hasOwnProperty('Name') && element.Name.toLowerCase() == 'engine');
                if(newArray && newArray.length){
                    await this.fetchCategoryPath();
                    tempResult.unshift({
                        Category_Image__c: this.maintenanceImage,
                        Section_Id__c: 'maint001',
                        Id: 'maint001',
                        Name: 'MAINTENANCE'
                    });
                }
                
                //map sortOrder if value missing on category and assign the same value for all
                const optionsValues = tempResult.map(v => {
                    return !v.SortOrder ? {...v, SortOrder: 100} : v
                })
                // Sort the list by order order Ascending
                optionsValues.sort((a,b)=> {
                    if(a.SortOrder > b.SortOrder) return 1;
                    if(a.SortOrder < b.SortOrder) return -1;
                    return 0;
                });

                // contstruct hrefs for category urls
                const catValues = optionsValues.map(v => {
                    let newUrl = '/s/category/' + v.Id;
                    return {...v, url: newUrl}
                });

                // Return it to the frontend
                this.categoryList = catValues;
                sessionStorage.removeItem('SEO_Sku');
            // No subcategories - show mega category page/PLP
            } else {
                this.displayCats = false;
                this.fetchProductData();
            }
        })
        .catch((error) => {
            console.log(error);
        });
    }

    async fetchCategoryPath(){
        let dataMap = {
            'categoryId' : this.urlId,
            'communityId' : communityId
        };
        await fetchCategoryPath({'dataMap':dataMap})
        .then((result) => {
            if(result.isSuccess && result.baseCategory) {
                let baseCategory = result.baseCategory;
                if(baseCategory && baseCategory.toLowerCase() == 'acura'){
                    this.maintenanceImage = ACURAMAINTENANCEIMAGE;
                }else if(baseCategory && baseCategory.toLowerCase() == 'honda'){
                    this.maintenanceImage = HONDAMAINTENANCEIMAGE;
                }                
            }
        })
        .catch((error) => {
            console.log('error:',error);
        });
    }

    goToCategory(e) {
        e.stopPropagation();
        e.preventDefault();
        if(e.target.dataset.id && e.target.dataset.id == 'maint001'){
            this.showChangeVehicleModal = true;
            setTimeout(() => {
                if (this.template.querySelector('c-select-vehicle-modal')){
                    this.template.querySelector('c-select-vehicle-modal').isSEOMaintenence = true;
                }
            }, 500);                
            return;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: e.target.dataset.id,
                actionName: 'view'
            }
        });
    }

    goToPDP(e) {
        e.stopPropagation();
        e.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: e.target.dataset.id,
                actionName: 'view'
            }
        });
    }

  
    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);
    }
    
    /*
    * Desc -  To fetch all the products to show on PLP Page
    */
    fetchProductData() {
        let dataMap = {
            'categoryId': this.urlId,
        };

        getProductsWithCategory({
            'dataMap': dataMap
        })
            .then((result) => {
                if (result && result.isSuccess) { 
                    if (Array.isArray(result.prodLst) && result.prodLst.length) {
                        sessionStorage.removeItem('SEO_Sku');
                        // Determine which CTA title to display by reading vehicle cookie
                        let vehicle = JSON.parse(this.getCookie('vehicle'));
                        if (vehicle) {
                            this.vehicleSelected = true;
                        } 

                        var tempResult = JSON.parse(JSON.stringify(result.prodLst));
                        // contstruct hrefs for product urls
                        const prodValues = tempResult.map(v => {
                            let newUrl = '/s/product/' + v.Id;
                            return {...v, url: newUrl}
                        });

                        this.prodList = prodValues;
                    }
                } else {
                    console.log('error ', result.msg);
                }
            })
        .catch((error) => {
            this.error = error;
            console.log('error: ',error);
        });
    }
}
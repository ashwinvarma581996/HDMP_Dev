/******************************************************************************* 
Name:  AccessoriesDetailPage
Business Unit: HDM
Date: April 2021
Description: This is PDP of accessories. 
******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
09-06-2022 | <Yashika> | <added Header> | 
*******************************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import checkProductCompatibility from '@salesforce/apex/B2BGetInfo.checkProductCompatibility';
import getCartCompatibility from '@salesforce/apex/B2BGetInfo.getCartCompatibility';
import communityId from '@salesforce/community/Id';
import getCategory from '@salesforce/apex/B2BGetInfo.getCategoryId';
import checkIfUserIsLoggedIn from '@salesforce/apex/B2BGuestUserController.checkIfUserIsLoggedIn';
import addItem_Clone from '@salesforce/apex/B2BGuestUserController.addItem_Clone';
import createUserAndCartSetup from '@salesforce/apex/B2BGuestUserController.createUserAndCartSetup';
import addProductToCartItem_Clone from '@salesforce/apex/B2BGuestUserController.addProductToCartItem_Clone';
import checkIfUserHasCartAndSetup from '@salesforce/apex/B2BGuestUserController.checkIfUserHasCartAndSetup';
import getProductForPartNumber from '@salesforce/apex/B2BGuestUserController.getProduct';
import Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import { getCurrentDealerId } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMyProductDetail from '@salesforce/apex/B2B_GetOrderInfo.getMyProductDetail';
import imageResourcePath from '@salesforce/resourceUrl/honda_images'
import getCartId from '@salesforce/apex/B2BGetInfo.getCartId';
import getAllProuctQuantity from '@salesforce/apex/B2BGetInfo.getAllProuctQuantity';
import createPermissions from '@salesforce/apex/B2BGuestUserController.createPermissionSetsSynchronous';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageForCart__c";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import addItemToList from '@salesforce/apex/B2B_LoggedInUserWishlist.addItemToList'; //added by Yashika for R2 story Wishlist
import NAME_FIELD from '@salesforce/schema/User.Name';
import getCustomSettings from '@salesforce/apex/B2B_LoggedInUserWishlist.getCustomSettings';
import { getRecord } from 'lightning/uiRecordApi';
import getProductPrice from '@salesforce/apex/B2B_LoggedInUserWishlist.getProductPrice'; //added for 7537
import getModelId from '@salesforce/apex/B2BGuestUserController.getModelId'; //added by Yashika for 8708
import getCartItemBrand from '@salesforce/apex/B2BGetInfo.getCartItemBrand';//Added by Pradeep for HDMP-16716
import hondaImages from '@salesforce/resourceUrl/honda_images';

//motocompacto starts
import storeImages from '@salesforce/resourceUrl/StoreImages';
import MOTOCOMPACTO_GOOGLE_STORE_URL from '@salesforce/label/c.Motocompacto_Google_Store_URL';
import MOTOCOMPACTO_APPLE_STORE_URL from '@salesforce/label/c.Motocompacto_Apple_Store_URL';
//motocompacto ends

import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';//for adobe analytics
import HDMP_MESSAGE_CHANNEL_ADOBE from "@salesforce/messageChannel/HDMPMessageChannel__c";//for adobe analytics
// A fixed entry for the home page.
const homePage = {
    name: 'Home',
    type: 'standard__namedPage',
    attributes: {
        pageName: 'home'
    }
};
const BREADCRUMB_TYPE = {
    BRAND: 'brand',
    PRODUCTTYPE: 'producttype',
    CATEGORY: 'category',
    SUBCATEGORY: 'subcategory',
    PRODUCT: 'product'
}
//added by yashika for R2 Story accessory search: startes here        
const STORAGE = {
    SEARCHED_TERM: 'searchedTerm',
    CHOSEN_FILTER: 'chosenFilter',
    FROM_PDP: 'FromPDP',
    CLICKED_BACK_TO_RESULT: 'clickedBackToResult',
    YES: 'yes',
    NO: 'no',
    CLOSE: 'close'
} //ends here
const PRODUCT_TYPE = 'Accessory';
const MOTOCOMPACTO = 'Motocompacto';

export default class AccessoriesDetailPage extends NavigationMixin(LightningElement) {
    selectDealerIcon = imageResourcePath + '/location.png';
    @track itemAddedToWishlist = false; //added by Yashika for R2 story: wishlist
    @track myWishlistUrl;
    @track productImage;
    @track brand;
    @track userFirstName = '';
    @track showWishlist = false;
    @track isItemExist = false; //ends
    @api pricetype;
    @api recordId;
    @api effectiveAccountId;
    @api customFields;
    @api cartLocked;
    description;
    @api effectiveaccountid;
    @api image;
    @api productNumber;
    @api inStock = false;
    @api price;
    @api showAddToCart;
    @api resolvedCategoryPath;
    @api displayData;
    @api requiredAccessoryList;
    @api isPickupDealer;
    @api shoppingBrand;
    @track isModalOpen = false;
    @track userId = Id;
    @track allDetails;
    @track selectedAccessories;
    @track showRequiredAccessory = false;
    @track assValue;
    @track displayColorPanel;
    @track selectedColorName = '';
    @track selectedAccessoryColorName = '';
    @track plpURL;
    @track typeofproduct;
    @track breadcrumbBrand;
    @track partNumber = '';
    EnableImage = true;
    DisableImage = false;
    accessoriesDescription;
    warningPopup = false;
    cartId;
    openRequiredProductModal = false;
    currentProductUrl = '';
    @track sku;
    @track productModelMarketingName;
    @track hideBackToResults;
    @track fromCartPage;
    dreamshopDefaultImage = hondaImages + '/1200px-No_image_available.png';
    assetMediumURLError = false;
    assetThumbURLError = false;

    //added by Yashika for r2 story: wishlist
    @wire(getCustomSettings)
    myCustomSettings;

    @track cartBrandDB = ''; // added by Pradeep for HDMP-16716

    //motocompacto Starts
    @track isMotoCompacto = false;
    @track motoCompactoImages = [];
    @track appleStore = storeImages + '/StoreImages/applePlayStore.png';
    @track googleStore = storeImages + '/StoreImages/googlePlayStore.png';;
    //motocompacto ends
    @wire(getRecord, {
        recordId: Id,
        fields: [NAME_FIELD]
    }) wireuserdata({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userFirstName = data.fields.Name.value;
            if (Id == undefined || Id == null || this.userFirstName.includes('Guest')) {
                this.showWishlist = false;
            } else {
                this.showWishlist = true;
            }
        }
    }
    //ends
    @track colorsOptions = [];
    succImg = true;
    disError() {
        this.succImg = false;
    }
    @track disableAddToCart = false; //Added by deepak mali
    @api dealerEmailAddress;
    @api dealerPhoneNumber;
    @api isDealerSelected = getCurrentDealerId() ? true : false;
    get resolvedEffectiveAccountId() {
        const effectiveAcocuntId = this.effectiveAccountId || '';
        let resolved = null;
        if (
            effectiveAcocuntId.length > 0 &&
            effectiveAcocuntId !== '000000000000000'
        ) {
            resolved = effectiveAcocuntId;
        }
        return resolved;
    }
    get showDealerIcon() {
        if (this.pricetype && this.pricetype.toLowerCase() == 'dealer price')
            return false;
        return true;
    }
    get pricetypeWithDealer() {
        return this.pricetype;
    }

    // implicitly during the component descruction lifecycle.
    @wire(MessageContext)
    messageContext;
    _product;
    @api
    get product() {
        return this._product;
    }
    set product(value) {
        if (value) {
            this._product = value;
            this.sku = value.fields.StockKeepingUnit;
            this.description = value.fields.Description;
            this.getBreadcrumbs(value.fields);
        }
    }

    //added by Yashika for R2 story Wishlist : starts
    async handleAddToWishlist() {
        this.handleIsLoading();
        this.brand = sessionStorage.getItem('brand');
        let effAccId = this.myCustomSettings.data.Default_Guest_Account__c;
        if (!this._quantityFieldValue || this._quantityFieldValue - Math.floor(this._quantityFieldValue) != 0) {
            return;
        } else if (this._quantityFieldValue <= 0) {
            return;
        } else if (this._quantityFieldValue > 25) {
            this.showToastMessages('Quantity Limit', 'error', 'Sorry we can only have maximum of 25 quantity of a wishlist Item.');
            this.handleIsLoading();
            return;
        } else {
            this.partNumber = this.sku;
            let productPrice;
            await getProductPrice({ //added this method for 7537
                sku: this.sku
            }).then(result => {
                productPrice = result;
            })
            addItemToList({
                brand: this.brand,
                accountId: effAccId,
                communityId: communityId,
                sku: this.sku,
                userId: this.userId,
                price: productPrice,
                quantity: this._quantityFieldValue,
                accessoryName: this.selectedAccessories.AccessoryName,
                productImage: this.productImage,
                productType: (this.isMotoCompacto == false) ? PRODUCT_TYPE : MOTOCOMPACTO, //changed for motocompacto by yashika
                color: this.selectedAccessoryColorName,
                op_code: this.selectedAccessories.op_cd, //for 7911
                productModelName: this.productModelMarketingName,
                vin: this.vin,
                modelId: this.modelId,
                itemPackageQuantity: this.selectedAccessories.quantity ? this.selectedAccessories.quantity : 1,
            }).then(result => {
                if (result.Id) {
                    this.itemAddedToWishlist = true;
                    if (sessionStorage.getItem('breadcrumbsMap')) {
                        let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                        let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')))
                        breadcrumbsProductMap.set(this.recordId, breadcrumbsMap.get(sessionStorage.getItem('brand')));
                        localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                        console.log('$ADP: notifyAddToCart breadcrumbsProductMap', localStorage.getItem('breadcrumbsProductMap'));
                    }
                    this.addLocalStorage();
                }
                this.handleIsLoading();
                  //For adobe analytics : starts
                  let events = 'move to wishlist';
                  let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                  let eventMetadata = {
                      action_type: 'button',
                    action_label: 'save to wishlist',//for adobe bug-22
                      action_category: 'accessories'
                  };
                  breadcrumbs.push({ label: this.selectedAccessories.AccessoryName });
                  let addToCartProductDetails = {
                      breadcrumbs: breadcrumbs,
                      products: { StockKeepingUnit: this.sku },
                      context: {
                          brand: this.brand,
                          Model_Id__c: this.productModelId,
                          model: this.model,
                          year: this.year,
                          trim: this.trim
                      }
                  }
                  const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'addToCartProductDetails': addToCartProductDetails, 'events': events } };
                  publish(this.messageContext, HDMP_MESSAGE_CHANNEL_ADOBE, message);
                  //  adobe analytics : end 
            }).catch(error => {
                if (JSON.stringify(error).includes('duplicate value found')) { //modified by Yashika for 8554
                    this.isItemExist = true;
                }
                else {
                    this.dispatchEvent(new ShowToastEvent({
                        message: 'We are experiencing technical difficulties. Please try again later.',
                        variant: 'Error'
                    }));
                }
                this.handleIsLoading();
            })
        }
    }
    closeModalWishlist() {
        this.itemAddedToWishlist = false;
    }
    closeModalError() {
        this.isItemExist = false;
    } //ends
    connectedCallback() {
        try {
            // added on 11/12 start
            if (JSON.parse(sessionStorage.getItem('fromCartForBreadcrumbs'))) {// && sessionStorage.getItem('vehicleBrand2') && sessionStorage.getItem('vehicleBrand') && sessionStorage.getItem('vehicleBrand2') != sessionStorage.getItem('vehicleBrand')){
                this.hideBackToResults = true;
                //sessionStorage.setItem('fromCartForBreadcrumbs',false);
            }
            // added on 11/12 end
            //added by Yashika for R2 story wishlist: starts
            this.myWishlistUrl = window.location.origin + '/s/my-wishlist';
            //ends here
            //added by Yashika for 8708: starts
            // for multiple tab issue. starts here
            if (localStorage.getItem("effectiveVehicle") && JSON.parse(localStorage.getItem("effectiveVehicle"))["brands"]) {
                let vehicleDetail = JSON.parse(localStorage.getItem("effectiveVehicle"))["brands"];
                if (vehicleDetail) {
                    vehicleDetail.forEach(element => {
                        if (sessionStorage.getItem('vehicleBrand') === element.brand) {
                            this.year = element.year;
                            this.model = element.model;
                            this.trim = element.trim;
                            this.vin = element.vin;
                            this.productModelId =element.Model_Id__c;//for adobe bug 31
                            if(sessionStorage.getItem('isMotoCompacto')){
                                this.productModelMarketingName =  this.year + ' ' + this.model + ' ' + this.trim;
                            
                            }
                            else{
                            this.productModelMarketingName = element.make + ' ' + this.year + ' ' + this.model + ' ' + this.trim;
                            }

                        }
                    });
                }
            }
            // multiple tab issue. ends here
            else
                if (this.getCookie('Make') != 'undefined' && this.getCookie('Make') != 'null' && this.getCookie('Make') != null && this.getCookie('Make') != '') {
                    this.year = this.getCookie('Year');
                    this.model = this.getCookie('Model');
                    this.trim = this.getCookie('Trim');
                    this.vin = this.getCookie('Vin');
                    if(sessionStorage.getItem('isMotoCompacto')){
                        this.productModelMarketingName =  this.year + ' ' + this.model + ' ' + this.trim;
                    
                    }
                    else{
                    this.productModelMarketingName = this.getCookie('Make') + ' ' + this.year + ' ' + this.model + ' ' + this.trim;
                    }
                }
            getModelId({
                year: this.year,
                model: this.model,
                trim: this.trim
            })
                .then(result => {
                    this.modelId = result.Id;
                    if(this.productModelId==''){
                    this.productModelId = result.Product_Model_ID__c;//for adobe bug-11
                    }
                })
                .catch(error => { }); //ends: 8708
            this.selectedAccessories = JSON.parse(this.getCookie('selectedAccessorie'));           
            //motocompacto starts
            console.log('isMotoCompacto : ',sessionStorage.getItem('isMotoCompacto'));
            if(sessionStorage.getItem('isMotoCompacto')){
                ;
                this.isMotoCompacto = true;
                this.hideBackToResults = true;
                let motoImages = [];               
                if(this.selectedAccessories.Assets){
                    this.selectedAccessories.Assets.forEach((item, index) => {
                        if(index == 0){
                            item.style = 'border-color: #E42525;cursor: pointer;';
                        }else {
                            item.style = 'cursor: pointer;';
                        }  
                        if(index < 4)                     
                            motoImages.push(item);
                    });
                    this.motoCompactoImages = motoImages;
                }
                
            }else {
                this.isMotoCompacto = false;
            }
            //motocompacto ends
            if(this.selectedAccessories.AssetMediumURL && this.selectedAccessories.AssetMediumURL.includes('/1200px-No_image_available.png')){
                this.selectedAccessories.AssetMediumURL = this.dreamshopDefaultImage;
            }
            if(this.selectedAccessories.AssetThumbURL && this.selectedAccessories.AssetThumbURL.includes('/1200px-No_image_available.png')){
                this.selectedAccessories.AssetThumbURL = this.dreamshopDefaultImage;
            }
            this.productImage = this.selectedAccessories.AssetMediumURL;
            if (this.selectedAccessories && (!this.selectedAccessories.AssetMediumURL || this.selectedAccessories.AssetMediumURL.length == 0)) {
                this.assetMediumURLError = true;
            }
            if (this.selectedAccessories && (!this.selectedAccessories.AssetThumbURL || this.selectedAccessories.AssetThumbURL.length == 0)) {
                this.assetThumbURLError = true;
            }
            this.price = this.selectedAccessories.msrp ? this.selectedAccessories.msrp : '';
            if (this.price <= 0) { //Added by Deepak
                this.disableAddToCart = true;
                this.price = 0;
            }
            this.displayColorPanel = this.selectedAccessories && this.selectedAccessories.Colors && this.selectedAccessories.Colors.length && this.selectedAccessories.Colors[0].colorName == null && this.selectedAccessories.Colors[0].id == null ? false : true;
            this.selectedColorName = this.displayColorPanel && this.selectedAccessories && this.selectedAccessories.Colors && this.selectedAccessories.Colors.length && this.selectedAccessories.Colors[0].part_number != '' ? this.selectedAccessories.Colors[0].part_number : '';
            this.selectedAccessoryColorName = this.displayColorPanel && this.selectedAccessories && this.selectedAccessories.Colors && this.selectedAccessories.Colors.length && this.selectedAccessories.Colors[0].colorName != '' ? this.selectedAccessories.Colors[0].colorName : '';
            this.showRequiredAccessory = this.requiredAccessoryList && this.requiredAccessoryList.length ? true : false;
            let accessories = localStorage.getItem('RequiredProducts');
            if (this.selectedAccessories.AssetThumbURL == 'null') {
                this.selectedAccessories.AssetThumbURL = null;
            }
            if (this.selectedAccessories.AccessoryDesc == 'null') {
                this.selectedAccessories.AccessoryDesc = null;
            }
            this.fetchcartId();
            // HDMP-12709 starts here
            if (!this.recordId) {
                this.retrieveProduct();
            }
            //HDMP-12709 ends here

            this._resolveConnected();
            this.handleLoad();
            if (this.selectedAccessories && this.selectedAccessories.Colors && this.selectedAccessories.Colors.length) {
                let colorList = [];
                this.selectedAccessories.Colors.forEach(everyColor => {
                    let colorObj = JSON.parse(JSON.stringify(everyColor));
                    colorList.push({ label: colorObj.colorName, value: colorObj.part_number });
                });
                this.colorsOptions = colorList;
            }
            if (this.selectedColorName) {
                this.sku = this.selectedColorName;
            } else {
                this.sku = this.selectedAccessories && this.selectedAccessories.Colors && this.selectedAccessories.Colors.length && this.selectedAccessories.Colors[0].part_number != '' ? this.selectedAccessories.Colors[0].part_number : '';
            }
            let requiredModal = sessionStorage.getItem('openRequiredProductModal');
            if (requiredModal && requiredModal == 'true') {
                this.openRequiredProductModal = true;
            } else {
                this.openRequiredProductModal = false;
            }
        } catch (error) {
            //  alert(error.message);
        }
        this.getBreadcrumbs();
        this.handleDefaultImage();
    }

    handleDefaultImage(){
        let reqAcc = JSON.parse(JSON.stringify(this.requiredAccessoryList));
        if(reqAcc.length){
            reqAcc.forEach(element => {
                if(element.AssetMediumURL && element.AssetMediumURL.includes('/1200px-No_image_available.png')){
                    element.AssetMediumURL = this.dreamshopDefaultImage;
                }
                if(element.AssetThumbURL && element.AssetThumbURL.includes('/1200px-No_image_available.png')){
                    element.AssetThumbURL = this.dreamshopDefaultImage;
                }
            });
            this.requiredAccessoryList = reqAcc;
        }
    }

    //motocompacto starts
    handleImageClick(event){
        let selectedIndex = event.currentTarget.dataset.index;
        this.motoCompactoImages.forEach((item, index )=> {
            if(selectedIndex == index){
                item.style = 'border-color: #E42525;cursor: pointer;';
                this.selectedAccessories.AssetMediumURL = item.Medium;
            }else {
                item.style = 'cursor: pointer;';
            }
        });
    }

    handleThumbImageClick(event){
        let imageUrl = event.currentTarget.dataset.image;
        if(imageUrl){
            window.open(imageUrl, '_blank');
        }
    }

    handleStoreImageClick(event){
        let name = event.target.name;
        if(name == 'apple store'){
            window.open(MOTOCOMPACTO_APPLE_STORE_URL, '_blank');
        }else if(name == 'google store'){
            window.open(MOTOCOMPACTO_GOOGLE_STORE_URL, '_blank');
        }
    }
    //motocompacto ends

    getBreadcrumbs(productFields) {
        if (productFields) {
            var productDiv = productFields.Division__c;
            var selectedAccessories = JSON.parse(this.getCookie('selectedAccessorie'));
            var productName = selectedAccessories.AccessoryName
            if (productDiv) {
                if(productDiv === 'A'){
                    sessionStorage.setItem('brand', 'Honda');
                }else if(productDiv === 'B'){
                    sessionStorage.setItem('brand', 'Acura');
                }else if(productDiv === 'A;B'){
                    sessionStorage.setItem('brand', this.getCookie('Make'));
                }
                if (localStorage.getItem('breadcrumbsProductMap') || sessionStorage.getItem('breadcrumbsMap')) {                  
                    let fromCart = sessionStorage.getItem('fromcart');               
                    if(this.isMotoCompacto && fromCart != 'true'){
                        this.breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                    }else {
                        this.breadcrumbs = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap'))).get(this.recordId) ? new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap'))).get(this.recordId) : new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                    }
                    console.log('this.breadcrumbs raj : ',this.breadcrumbs);
                    if (this.breadcrumbs) {
                        this.breadcrumbs.forEach(breadcrumb => {
                            if (BREADCRUMB_TYPE.BRAND === breadcrumb.name) {
                                this.breadcrumbBrand = breadcrumb.label;
                            }
                            if (BREADCRUMB_TYPE.PRODUCTTYPE === breadcrumb.name || BREADCRUMB_TYPE.CATEGORY === breadcrumb.name || BREADCRUMB_TYPE.SUBCATEGORY === breadcrumb.name) {
                                breadcrumb.href = breadcrumb.categoryURL;
                                this.plpURL = breadcrumb.href;
                                this.typeofproduct = breadcrumb.label;
                            }
                            breadcrumb.isCurrentPage = false;
                        });
                    }else {
                        this.breadcrumbs = [];
                    }
                    this.breadcrumbs.push({
                        label: productName,
                        name: 'product',
                        href: 'javascript:void(0);',
                        isCurrentPage: true
                    });
                }
            }
        }
        //for adobe analytics:start
        let brand = sessionStorage.getItem('brand');
        let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
        breadcrumbsMap.set(brand, this.breadcrumbs);
        sessionStorage.setItem('breadcrumbsMapPDPforAd', JSON.stringify([...breadcrumbsMap]));
        console.log('breadcrumbsMapPDPforAd', sessionStorage.getItem('breadcrumbsMapPDPforAd'))
        //for adobe:ends
    }
    retrieveProduct() {
        var baseurl = window.location.href;
        var finalurl = baseurl.split('/');
        this.recordId = finalurl[6];
    }
    cartcheck;
    _invalidQuantity = false;
    _quantityFieldValue = 1;
    _categoryPath;
    isLoading = false;
    // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
    // which the NavigationMixin implicitly requires to function properly.
    _resolveConnected;
    _connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });
    disconnectedCallback() {
        this._connected = new Promise((resolve) => {
            this._resolveConnected = resolve;
        });
        sessionStorage.setItem('openRequiredProductModal', false);
    }

    handleBreadcrumbClick(event) {
        let brands = [];
        if (localStorage.getItem("effectiveVehicle")) {
            brands = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
            let hasExist = false;
            if (brands) {
                brands.forEach(element => {
                    if (this.breadcrumbBrand === element.brand) {
                        element.productType = this.typeofproduct;
                        hasExist = true;
                    }
                });
                if (hasExist) {
                    localStorage.setItem("effectiveVehicle", JSON.stringify({ 'brands': brands }));
                }
            }
            window.open(this.plpURL, "_self");
        }
        //added by yashika for R2 Story accessory search: startes here
        let searchVal = sessionStorage.getItem(STORAGE.SEARCHED_TERM);
        let chosenFilter = sessionStorage.getItem(STORAGE.CHOSEN_FILTER);
        if (searchVal != null && chosenFilter != null) {
            sessionStorage.setItem(STORAGE.CLICKED_BACK_TO_RESULT, STORAGE.YES);
        } //ends here
    }

    handleLoad() {
        this.finalvalue = JSON.stringify(this._categoryPath);
        getCategory({
            productId: this.recordId
        })
            .then(result => {
                this.RetrievedId = result;
                for (let i = 0; i < this.finalvalue[i].length; i++) {
                    if (this.RetrievedId == 'Accessories' && this.EnableImage == false) {
                        this.EnableImage = true;
                    } else if (this.RetrievedId != 'Accessories') {
                        this.DisableImage = true;
                    }
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    @api
    get categoryPath() {
        return this._categoryPath;
    }
    set categoryPath(newPath) {
        this._categoryPath = newPath;
        this.resolveCategoryPath(newPath || []);
    }
    get hasPrice() {
        return (this.price || {}) > 0;
    }

    handleQuantityChange(event) {
        this._quantityFieldValue = event.target.value;
        //START - Added by Shalini Soni 15 Sept 2021 :
        let quantityCmp = this.template.querySelector(".quantityinput");
        let quantityvalue = quantityCmp.value;
        if (!quantityvalue || quantityvalue == '0.') {
            quantityCmp.setCustomValidity("Quantity should be greater than 0 and no more than 25");
        } else {
            quantityCmp.setCustomValidity(""); // clear previous value
        }
        quantityCmp.reportValidity();
        //END
        if (event.target.validity.valid) {
            this._invalidQuantity = false;
        } else if (event.target.validity.valid && event.target.value && event.target.value > 99) {
            this._invalidQuantity = true;
        }
    }

    navigateToBack(event) {
        history.back();
    }

    handleIsLoading() {
        this.isLoading = !this.isLoading;
    }

    //Added by Faraz for HDMP-16716
    getCartItemBrand() {
        getCartItemBrand({ webcartId: this.cartId })
            .then(result => {
                if (result) {
                    let data = JSON.parse(result);
                    if (data && data.length && data[0].Product_Subdivision__c) {
                        this.cartBrandDB = data[0].Product_Subdivision__c;
                        localStorage.setItem('cartBrand', this.cartBrandDB);
                    }
                    // added on 11/12 start
                    else {
                        this.cartBrandDB = '';
                        localStorage.removeItem('cartBrand');
                    }
                    this.notifyAddToCart();
                }

                else {
                    this.cartBrandDB = '';
                    localStorage.removeItem('cartBrand');
                }
                // added on 11/12 end
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
    //End HDMP-16716
    notifyAddToCart() {
        let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
        // added on 11/12 start
        if ((localStorage.getItem('cartBrand') && (localStorage.getItem('cartBrand') != sessionStorage.getItem('vehicleBrand')))
            || (this.cartBrandDB && this.cartBrandDB.length && this.cartBrandDB != sessionStorage.getItem('vehicleBrand'))) {
            // added on 11/12 end
            console.log('$ADP: notifyAddToCart cartBrand!=brand');
            this.handleIsLoading();
            this.isModalOpen = true;
        } else {
            addProductToCartItem_Clone({
                accountId: getCurrentDealerId(),
                sku: this.sku,
                communityId: communityId,
                price: this.price,
                quantity: parseInt(this._quantityFieldValue),
                accessoryName: this.selectedAccessories.AccessoryName,
                color: this.selectedAccessoryColorName,
                productType: (this.isMotoCompacto == false) ? PRODUCT_TYPE : MOTOCOMPACTO, // Added by shalini soni for HDMP-5702 R2 Story
                accImageURL: this.productImage, // Added by Yashika for 7380
                opCode: this.selectedAccessories.op_cd, //added by Yashika for 7911
                brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290
                modelId: this.modelId, //added by Yashika for 8708 
                vin: this.vin, //added by Yashika for 8708
                productModelMarketingName: this.productModelMarketingName, //added by Yashika for 10179
                itemPackageQuantity: this.selectedAccessories.quantity ? this.selectedAccessories.quantity : 1,
            }).then(result => {
                this.notifyToCustomCart(); //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
                //For adobe analytics : starts
                let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                breadcrumbs.push({ label: this.selectedAccessories.AccessoryName });
                let eventMetadata = {
                    action_type: 'button',
                    action_label: 'add to cart',
                    action_category: 'accessories'
                };

                let events = 'scAdd';
                let addToCartProductDetails = {
                    breadcrumbs: breadcrumbs,
                    products: { StockKeepingUnit: this.sku },
                    context: {
                        brand: storeBrand,
                        Model_Id__c: this.productModelId,
                        model: this.model,
                        year: this.year,
                        trim: this.trim
                    }
                }
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'addToCartProductDetails': addToCartProductDetails, 'events': events } };
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL_ADOBE, message);
                //  adobe analytics : end 
                if (result.Id) {
                    this.dispatchEvent(
                        new CustomEvent('cartchanged', {
                            bubbles: true,
                            composed: true
                        })
                    );
                    if (sessionStorage.getItem('breadcrumbsMap')) {
                        let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                        let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')))
                        breadcrumbsProductMap.set(this.recordId, breadcrumbsMap.get(sessionStorage.getItem('brand')));
                        localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                        if (this.requiredAccessoryList && this.requiredAccessoryList.length) {
                            this.openRequiredProductModal = true;
                            sessionStorage.setItem('openRequiredProductModal', true);
                        } else {
                            this.openRequiredProductModal = false;
                            sessionStorage.setItem('openRequiredProductModal', false);
                        }
                    }
                    this.handleIsLoading();
                }
            }).catch(error => {
            })
        }
    }

    handleAddToCart1(event) {
        let partNumber = event.target.dataset.partnumber;
        this.partNumber = partNumber;
        if (!this._quantityFieldValue || this._quantityFieldValue - Math.floor(this._quantityFieldValue) != 0) {
            return;
        } else if (this._quantityFieldValue <= 0) {
            return;
        } else if (this._quantityFieldValue > 25) {
            this.showToastMessages('Quantity Limit', 'error', 'Sorry we can only have maximum of 25 quantity in an order.');
            return;
        } else {
            if (this.cartId) {
                this.getProductQuan(partNumber);
            } else {
                this.updateQuantity();
            }
        }
    }

    updateQuantity() {
        this.handleIsLoading();
        checkIfUserIsLoggedIn().then(result => {
            if (result) {
                console.log('$ADP: checkIfUserIsLoggedIn ', result);
                this.userId = result;
                checkIfUserHasCartAndSetup({
                    communityId: communityId,
                    userId: this.userId
                })
                    .then(result => {
                        if (result) {
                            console.log('$ADP: checkIfUserIsLoggedIn2 ', result);
                            this.cartId = result.cartId;
                            this.getCartItemBrand();

                        }
                    })
                    .catch(error => {
                    });
            } else {
                let quant = this._quantityFieldValue;
                createUserAndCartSetup({
                    accountId: getCurrentDealerId()
                }).then(result => {
                    let userRecord = result.userId;
                    let cartId = result.cartId;
                    if (!this.currentProductUrl) {
                        this.currentProductUrl = window.location.href;
                    }
                    let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
                    createPermissions({
                        userId: userRecord,
                    }).then(result => {
                        addItem_Clone({
                            userId: userRecord,
                            productId: this.recordId,
                            quantity: quant,
                            redirectUrl: this.currentProductUrl,
                            wc: cartId,
                            price: this.price,
                            accessoryName: this.selectedAccessories.AccessoryName,
                            color: this.selectedAccessoryColorName,
                            productType: (this.isMotoCompacto == false) ? PRODUCT_TYPE : MOTOCOMPACTO, // Added by shalini soni for HDMP-5702 R2 Story // changes for Motocompacto
                            accImageURL: this.productImage, // Added by Yashika for 7380
                            opCode: this.selectedAccessories.op_cd, //added by Yashika for 7911
                            brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290
                            modelId: this.modelId, //added by Yashika for 8708 
                            vin: this.vin, //added by Yashika for 8708
                            productModelMarketingName: this.productModelMarketingName, //added by Yashika for 10179
                            itemPackageQuantity: this.selectedAccessories.quantity ? this.selectedAccessories.quantity : 1,
                        }).then(redirectUrl => {
                            this.notifyToCustomCart(); //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
                            //For adobe analytics : starts
                            //added if condition for motocompacto
                            if(sessionStorage.getItem('breadcrumbsMap')){
                                let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                                breadcrumbs.push({ label: this.selectedAccessories.AccessoryName });
                                let eventMetadata = {
                                    action_type: 'button',
                                    action_label: 'add to cart',
                                    action_category: 'accessories'
                                };
                                let events = 'scAdd';
                                let addToCartProductDetails = {
                                    breadcrumbs: breadcrumbs,
                                    products: { StockKeepingUnit: this.sku },
                                    context: {
                                        brand: storeBrand,
                                        Model_Id__c: this.productModelId,
                                        model: this.model,
                                        year: this.year,
                                        trim: this.trim
                                    }
                                }
                                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'addToCartProductDetails': addToCartProductDetails, 'events': events } };
                                publish(this.messageContext, HDMP_MESSAGE_CHANNEL_ADOBE, message);
                            }
                            
                            //  adobe analytics : end 
                            localStorage.setItem('cartBrand', localStorage.getItem('brand'));
                            if (this.requiredAccessoryList && this.requiredAccessoryList.length) {
                                sessionStorage.setItem('openRequiredProductModal', true);
                            } else {
                                sessionStorage.setItem('openRequiredProductModal', false);
                            }
                            let brcMp = sessionStorage.getItem('breadcrumbsMap');                           
                            if (sessionStorage.getItem('breadcrumbsMap')) {
                                console.log('$ADP: breadcrumbsMap ', JSON.parse(brcMp));
                                let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                                let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')))
                                console.log('$ADP: breadcrumbsProductMap1 ', JSON.parse(localStorage.getItem('breadcrumbsProductMap')));

                                console.log('$ADP: brand11 ', sessionStorage.getItem('brand'));
                                breadcrumbsProductMap.set(this.recordId, breadcrumbsMap.get(sessionStorage.getItem('brand')));
                                localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                                if (redirectUrl) {
                                    window.location.replace(redirectUrl);
                                }
                            }
                        }).catch(error => {
                            console.log('OUTPUT : ', error);
                        })
                    }).catch(error => {
                        console.log('createPermissions', error);
                    })
                }).catch(error => {
                    console.log('createUserAndCartSetup', error);
                })
            }
        });
        this.addLocalStorage();
    }

    showToastMessege(title, messege, varient) {
        const evt = new ShowToastEvent({
            title: title,
            message: messege,
            variant: varient
        });
        this.dispatchEvent(evt);
    }

    resolveCategoryPath(newPath) {
        const path = [homePage].concat(
            newPath.map((level) => ({
                name: level.name,
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId: level.id
                }
            }))
        );
        this._connected
            .then(() => {
                const levelsResolved = path.map((level) =>
                    this[NavigationMixin.GenerateUrl]({
                        type: level.type,
                        attributes: level.attributes
                    }).then((url) => ({
                        name: level.name,
                        url: url
                    }))
                );
                return Promise.all(levelsResolved);
            })
            .then((levels) => {
                //this.resolvedCategoryPath = levels;
            });
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    submitDetails() {
        this.isModalOpen = false;
    }

    get _displayableFields() {
        // Enhance the fields with a synthetic ID for iteration.
        return (this.customFields || []).map((field, index) => ({
            ...field,
            id: index
        }));
    }

    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);
    }

    handleOnSelectRA(event) {
        let obj = JSON.parse(JSON.stringify(event.detail));
        if (obj) {
            let selectedAcc = JSON.parse(obj.selectedAcc);
            this.selectedAccessories = selectedAcc;
            this.displayColorPanel = this.selectedAccessories && this.selectedAccessories.Colors && this.selectedAccessories.Colors.length && this.selectedAccessories.Colors[0].colorName == "" && this.selectedAccessories.Colors[0].id == "" ? false : true;
            if (selectedAcc != null) {
                this.image = selectedAcc && selectedAcc.AssetThumbURL ? selectedAcc.AssetThumbURL : '';
            }
            if (selectedAcc && selectedAcc.RequiredAccessories && selectedAcc.RequiredAccessories.length) {
                this.requiredAccessoryList = selectedAcc.RequiredAccessories;
                this.showRequiredAccessory = true;
            } else {
                this.requiredAccessoryList = [];
                this.showRequiredAccessory = false;
            }
            let partNumber = obj.partNumber;
            if (partNumber) {
                this.getAccessoryDetail(this.recordId);
            }
        }
    }

    getAccessoryDetail(accessoryId) {
        if (accessoryId) {
            getMyProductDetail({ recordProductId: accessoryId })
                .then(result => {
                    this.price = result[0].Price__c;
                    if (this.price <= 0) {
                        this.disableAddToCart = true;
                    }
                })
                .catch(error => {
                    //console.error('Error:', error);
                });
        }
    }

    getPartNumber(opCode) {
        let colors = this.allAccessoriesInfo.Accessory.find(item => item.op_cd == opCode).Colors;
        colors = JSON.parse(JSON.stringify(colors));
        if (colors && colors.length && colors[0].part_number) {
            return colors[0].part_number
        }
    }

    handleOnSelectColor(event) {
        let selectedPartNumber = event.detail.value;
        this.selectedColorName = selectedPartNumber;
        if (selectedPartNumber) {
            this.sku = selectedPartNumber;
            let selectedColorInfo = this.selectedAccessories.Colors.find(item => item.part_number == selectedPartNumber);
            this.selectedAccessoryColorName = selectedColorInfo.colorName;
            getProductForPartNumber({ productId: selectedPartNumber }).then(result => {
                if (result) {
                    this.recordId = result.Id;
                    this.currentProductUrl = window.location.origin;
                    this.currentProductUrl = this.currentProductUrl + '/s/product/' + this.recordId;
                }
            }).catch(error => { })
        }
    }

    openWarningPopup() {
        this.warningPopup = true;
    }

    closeWarningPopup() {
        this.warningPopup = false;
    }

    fetchcartId() {
        getCartId({ communityId: communityId })
            .then((result) => {
                this.cartId = result;
                //this.getCartItemBrand();//added  for HDMP-16716
            })
            .catch((error) => { });
    }
    /*//added  for HDMP-16716: starts
    getCartItemBrand(){
        console.log('this.cartId : ',this.cartId);
        getCartItemBrand({ webcartId: this.cartId })
        .then(result => {
            if (result) {
                let data = JSON.parse(result);
                if (data && data.length && data[0].Product_Subdivision__c) {
                    this.cartBrandDB = data[0].Product_Subdivision__c;
                    console.log('Result2', this.cartBrandDB);
                }
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }
    //16716: ends*/

    async getProductQuan(partNumber) {
        getAllProuctQuantity({ cartId: this.cartId })
            .then((result) => {
                let prodWithQuantity = result;
                let proceedNext = false;
                let totalpartQuantity = 0;
                if (prodWithQuantity && Object.keys(prodWithQuantity).length != 0) {
                    for (var i in prodWithQuantity) {
                        totalpartQuantity += prodWithQuantity[i];
                        try {
                            if (i == this.sku) {
                                let quantity = parseInt(prodWithQuantity[i]) + parseInt(1);
                                //START Added Shalini Soni 17 Sept 2021
                                let totalQuantity = parseInt(prodWithQuantity[i]) + parseInt(this._quantityFieldValue);
                                if (totalQuantity > 50) {
                                    this.isLoading = false;
                                    proceedNext = false;
                                    break;
                                } else { proceedNext = true; }
                            } else { proceedNext = true; }
                        } catch (error) {
                        }
                    }
                    // Added by Lakshman on 02/03/2022 - HDMP-5074 EPIC Starts
                    totalpartQuantity += parseInt(this._quantityFieldValue);
                    if (totalpartQuantity > 25) {
                        this.isLoading = false;
                        proceedNext = false;
                    }
                    // Added by Lakshman on 02/03/2022 - HDMP-5074 EPIC Ends
                } else {
                    localStorage.setItem('cartBrand', sessionStorage.getItem('brand'));
                    proceedNext = true;
                }
                if (proceedNext) {
                    this.updateQuantity();
                }
            })
            .catch((error) => { });


    }

    addLocalStorage() {
        let ChecklocalStorage = localStorage.getItem('VinFitmentCheck') != null ? true : false;
        if (ChecklocalStorage == true) {
            let NewArraytemp = JSON.parse(localStorage.getItem('VinFitmentCheck'));
            Object.defineProperty(NewArraytemp, this.sku, {
                value: true,
                writable: true,
                enumerable: true,
                configurable: true
            })
            localStorage.setItem('VinFitmentCheck', JSON.stringify(NewArraytemp));
        }

        try {
            //Added by Shalini 90799
            let existingallProductDetailsList = []
            let alreadyExistInList = false;
            existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));
            if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                existingallProductDetailsList.forEach(element => {
                    if (element.partNumber) {
                        let elementNumber = element.partNumber.replace(/^"|"$/g, ''); //Remove double qcuotes from partNumber
                        if (elementNumber == this.partNumber) {
                            alreadyExistInList = true;
                        }
                    }
                });
            }
            if (!alreadyExistInList) {
                let allAcccDetailsList = [];
                let productDetails = { SelectedPart: '', ProductNumber: '', SelectedBreadcrumbs: '', SubCategoryImageURL: '', partNumber: '', ProductType: '', ProductFromCart: false };
                productDetails.SelectedPart = '';
                productDetails.selectedAcc = this.selectedAccessories; //Added For ADP
                productDetails.ProductNumber =
                    productDetails.SelectedBreadcrumbs = '';
                productDetails.SubCategoryImageURL =
                    productDetails.partNumber = JSON.stringify(this.partNumber);
                productDetails.ProductTypeForCart = 'Accessorie';
                productDetails.ProductFromCart = true;
                //Start Shalin Soni Required Products With Main Product
                let all_Accessories = JSON.parse(sessionStorage.getItem('accessories'));
                if (this.selectedAccessories.RequiredAccessories) {
                    let requiredProductOpId = [];
                    JSON.parse(JSON.stringify(this.selectedAccessories.RequiredAccessories)).forEach(rp => {
                        requiredProductOpId.push(rp.op_cd);
                    });
                    let RequiredAccessoriesList = [];
                    RequiredAccessoriesList = all_Accessories.Accessory.filter(acc => {
                        return requiredProductOpId.includes(acc.op_cd);
                    });
                    productDetails.RequiredAccessories = RequiredAccessoriesList;
                }
                allAcccDetailsList.push(productDetails);
                //Ended
                let existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));
                if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                    existingallProductDetailsList.push(productDetails);
                    localStorage.setItem('allProductDetailsList', JSON.stringify(existingallProductDetailsList));
                } else {
                    localStorage.setItem('allProductDetailsList', JSON.stringify(allAcccDetailsList));
                }
            }
        } catch (error) {
            //alert(error.message);
        }
    }

    //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
    notifyToCustomCart() {
        // you can also pass like this object info her --> const message = { message: { 'dealerLabel': dealerLabel, 'products': products } 
        const message = { message: 'Calling for update cartItem count' };
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
    }
    //Ended

    handleOnCloseRequiredProduct() {
        sessionStorage.setItem('openRequiredProductModal', false);
        this.openRequiredProductModal = false;
    }

    showToastMessages(title, variant, message) {
        this.dispatchEvent(new ShowToastEvent({ title: title, variant: variant, message: message, mode: 'dismissable' }));
    }
    renderedCallback() {

        // console.log('$ADP: breadcrumbsMap', sessionStorage.getItem('breadcrumbsMap'));
        if (sessionStorage.getItem('breadcrumbsMap')) {
            console.log('$CI_ADP: breadcrumbsMap', JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
        }
        if (localStorage.getItem('breadcrumbsProductMap')) {
            console.log('$CI_ADP: breadcrumbsProductMap', JSON.parse(localStorage.getItem('breadcrumbsProductMap')));
        }
        console.log('$CI_ADP: breadcrumbs - ', this.breadcrumbs);

        //CodeToSend-START
        if (this.breadcrumbs && Array.isArray(this.breadcrumbs) && this.breadcrumbs.length) {
            this.breadcrumbs.forEach((bread, index, arr) => {
                if (bread.categoryURL && bread.categoryURL == 'FROM_CART_ADDED' && this.fromCartPage) {
                    this.hideBackToResults = true;
                }
            });
            console.log('$CI_ADP: hideBackToResults - ', this.hideBackToResults);
        }
        //CodeToSend-END
    }

    handleGoToWishlist() {
        window.open(this.myWishlistUrl, "_self");
    }

    handleShowAssetThumbURL() {
        this.assetMediumURLError = true;
    }
    handleShowDefaultImage() {
        this.assetThumbURLError = true;
    }
}
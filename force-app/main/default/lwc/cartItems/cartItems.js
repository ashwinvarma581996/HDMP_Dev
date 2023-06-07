/******************************************************************************* 
Name: cartItems 
Business Unit: HDM
Date: april, 2021
Description: This component is used for displaying cart items on cart page.
******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
25-08-2022 | Yashika |  added header| 
*******************************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { resolve } from 'c/cmsResourceResolver';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/cartUtils';
import updateCartItem from '@salesforce/apex/B2BGuestUserController.updateCartItem';
import getcartTotalQuantity from '@salesforce/apex/B2BGuestUserController.getcartTotalQuantity';
import getProductSKUById from '@salesforce/apex/B2BGuestUserController.getProductSKUById';
import gettotalamount from '@salesforce/apex/CartItemsCtrl.gettotalamount';
import getItemImage from '@salesforce/apex/B2B_LoggedInUserWishlist.getItemImage'; //added by Yashika for R2 story Wishlist 
import addItemToList from '@salesforce/apex/B2B_LoggedInUserWishlist.addItemToList'; //added by Yashika for R2 story Wishlist 
import Id from '@salesforce/user/Id'; //added by Yashika for R2 story Wishlist
import NAME_FIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import getCustomSettings from '@salesforce/apex/B2B_LoggedInUserWishlist.getCustomSettings';
import communityId from '@salesforce/community/Id';
import getProductPrice from '@salesforce/apex/B2B_LoggedInUserWishlist.getProductPrice';
import { getCurrentDealerId, getCurrentDealer, getReturnPolicyMarkup } from 'c/utils';
import getBrand from '@salesforce/apex/B2B_VehicleSelectorController.getBrand';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';
import getWishlistItemFromSKU from '@salesforce/apex/B2B_LoggedInUserWishlist.getWishlistItemFromSKU';
//for adobe: starts
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';
//for adobe: ends
const QUANTITY_CHANGED_EVT = 'quantitychanged';
const SINGLE_CART_ITEM_DELETE = 'singlecartitemdelete';


const BREADCRUMB_TYPE = {
    BRAND: 'brand',
    PRODUCTTYPE: 'producttype',
    CATEGORY: 'category',
    SUBCATEGORY: 'subcategory',
    PRODUCT: 'product'
}

// Saravanan LTIM Added for HDMP - 18566
import updateCartItemstoSyncDynamically from '@salesforce/apex/CartItemsCtrl.updateCartItemstoSyncDynamically';

export default class Items extends NavigationMixin(LightningElement) {
    carImage = imageResourcePath + '/carImage.jpeg';
    //added by Yashika for Wishlist R2 Story : starts here
    @track productModelName;
    @track modelId;
    @track vin;
    @track color;
    @track imgUrl;
    @track opCode; //for 7911
    @track prodType;
    @track effAccId;
    @track userId = Id;
    @track isItemMoved = false;
    @track itemPrice;
    @track partName;
    @api image;
    @track productImage;
    @track brand;
    @track userFirstName = '';
    @track showWishlist = false;
    @track _quantityFieldValue;
    stockKeepingUnit; //ends here
    @track isLoading = true;
    @track warningPopup = false;
    @track removeProductId;
    @track isModalOpen = false;
    minQuan = 'Minimum Quantity is 1';
    //updated by saikiran as part of HDMP-12360
    maxQuan = 'Maximum Quantity is 25';
    @track brandName;
    @track ischangedList = []; //Added by saikiran as part HDMP -15591
    disclaimerMarkup;
    showDisclaimerMarkup = false;
    coreCharge; //Aditya - HDMP-16502
    @track partNumber;
    quantityUpdated = false;

    // LTIM 7811 and 7812 Vraiable Declarations
    disclaimerType; // Added by ashwin
    showDealerModal = false; // Added by ashwin
    dealerReturnPolicyMarkup = ""; // Added by ashwin
    showDisclaimer = true;


    openWarningPopup() {
        this.warningPopup = true;
    }
    closeWarningPopup() {
        this.warningPopup = false;
        this.showDisclaimerMarkup = false;
    }
    //added by Yashika for R2 story wishlist: starts
    @wire(getCustomSettings)
    myCustomSettings;

    @wire(getRecord, { recordId: Id, fields: [NAME_FIELD] })
    wireuserdata({ error, data }) {
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
    @api
    currencyCode;
    @api cartid;

    @api
    isCartDisabled = false;

    @api
    get cartItems() {
        return this._providedItems;
    }
    @track priceLabel = 'MSRP Price: ';
    @track dealercookie = this.getCookie('dealerLabel');
    @track checkDealerSelect = this.dealercookie ? true : false;
    @track allAccessoriesInfo;
    @track vinCookievalue;

    //for adobe
    @wire(MessageContext)
    messageContext;
    //ends    

    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);
    }
    // Added by Bhawesh on 17-03-2022 start
    fillProductsAndAccessories(items) {
        let products = {};
        let accessories = {};
        let partsList = [];
        let accessoryList = [];
        if (items) {
            [...items].forEach(currentItem => {
                if (currentItem && currentItem.productTypes.includes('Part')) {
                    let part = {};
                    part.PartNumber = currentItem.cartItem.productDetails.sku;
                    part.SuggestedRetailPriceAmount = currentItem.cartItem.productDetails.totalListPrice;
                    partsList.push(part);
                } else if (currentItem && currentItem.productTypes.includes('Accessory')) {
                    let acc = {};
                    let colorsList = [{ 'colorName': null, 'id': null, 'part_number': currentItem.cartItem.productDetails.sku, 'price': currentItem.cartItem.productDetails.totalListPrice }];
                    acc.op_cd = currentItem.op_cd;
                    acc.Colors = colorsList;
                    accessoryList.push(acc);
                }
            });
            if (partsList && partsList.length) {
                products.Parts = partsList;
            }
            if (accessoryList && accessoryList.length) {
                accessories.Accessory = accessoryList;
            }
            sessionStorage.setItem('products', JSON.stringify(products));
            sessionStorage.setItem('accessories', JSON.stringify(accessories));
        }
    }
    // End
    set cartItems(items) {
        // Added by Bhawesh on 17-03-2022 start
        let products = JSON.parse(sessionStorage.getItem('products'));

        let accessories = JSON.parse(sessionStorage.getItem('accessories'));
        if (products == null && accessories == null) {
            this.fillProductsAndAccessories(items);
        }
        // End
        if (getCurrentDealerId()) {
            this.priceLabel = 'Dealer Price: ';
        }
        if (!items) {
            this.isLoading = false;
        }
        this._providedItems = items;
        const generatedUrls = [];
        this._items = (items || []).map((item) => {
            // Create a copy of the item that we can safely mutate.
            const newItem = { ...item };
            // Set default value for productUrl
            newItem.productUrl = '';
            // Get URL of the product image.
            if (item && item.cartItem && item.cartItem.productDetails && item.cartItem.productDetails.thumbnailImage && item.cartItem.productDetails.thumbnailImage.url) {
                newItem.productImageUrl = resolve(
                    item.cartItem.productDetails.thumbnailImage.url
                );
            }
            // Set the alternative text of the image(if provided).
            // If not, set the null all text (alt='') for images.
            if (item && item.cartItem && item.cartItem.productDetails && item.cartItem.productDetails.thumbnailImage && item.cartItem.productDetails.alternateText) {
                newItem.productImageAlternativeText =
                    item.cartItem.productDetails.thumbnailImage.alternateText || '';
                //this.partNumber =   item.cartItem.productDetails.sku;
            }
            // Get URL for the product, which is asynchronous and can only happen after the component is connected to the DOM (NavigationMixin dependency).
            const urlGenerated = this._canResolveUrls
                .then(() =>
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: newItem.cartItem.productId,
                            objectApiName: 'Product2',
                            actionName: 'view'
                        }
                    })
                )
                .then((url) => {
                    newItem.productUrl = url;
                });
            generatedUrls.push(urlGenerated);
            return newItem;
        });
        // When we've generated all our navigation item URLs, update the list once more.
        Promise.all(generatedUrls).then(() => {
            this._items = Array.from(this._items);
        });
    }

    _items = [];
    _providedItems;
    _connectedResolver;
    _canResolveUrls = new Promise((resolved) => {
        this._connectedResolver = resolved;
    });

    async connectedCallback() {

        console.log('cartItemsssss ', this.cartItems)

        // Saravanan LTIM Added - Bug 18566
        this.updateCartItemName();
        // Saravanan LTIM Ends - Bug 18566

        //ends
        // Once connected, resolve the associated Promise.
        await this.getBrandDetails();
        // Added by saikiran as part of HDMP-14327
        if (sessionStorage.getItem('successmsg') && sessionStorage.getItem('successmsg') == 'success') {
            this.dispatchEvent(new ShowToastEvent({
                message: 'The items previously saved in your shopping cart have been moved to My Wish List.',
                variant: 'success'
            }));
            sessionStorage.removeItem('successmsg');
        }
        //Added by Deepak Mali 6 April 2022 Bug : 8536
        let productBrand = sessionStorage.getItem('brand');
        let VINFitmentValue = [];
        VINFitmentValue = JSON.parse(localStorage.getItem('VINFitmentValue')) || [];
        if (VINFitmentValue) {
            VINFitmentValue.forEach(element => {
                if (element.brandName == productBrand) {
                    this.vinCookievalue = element.vinValue;
                }
            })
        }
        //Ends

        this._connectedResolver();
        //----START-----Added by Deepak Mali on 12 August 2021 Task : BUG-3639 (Vehicle Selection Information Cleared when switching between Parts and Accessories)
        window.addEventListener('popstate', function (event) {

            let backPageURL = location.href;
            let customPageURL = '';

            if (backPageURL == window.location.origin + '/s/') {
                customPageURL = backPageURL;
            } else if (backPageURL == window.location.origin + '/s/honda') {
                customPageURL = backPageURL;

            } else if (backPageURL == window.location.origin + '/s/acura') {
                customPageURL = backPageURL;

            }
            // multiple tab issue3 starts here
            else if (sessionStorage.getItem('breadcrumbsMap')) {
                let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                // multiple tab issue3 ends here    
                let partsItems = false;
                breadcrumbs.forEach(breadcrumb => {
                    if (BREADCRUMB_TYPE.PRODUCTTYPE === breadcrumb.name && breadcrumb.label == "Parts") {
                        partsItems = true;
                    }
                });
                if (breadcrumbs && partsItems) {
                    breadcrumbs.forEach(breadcrumb => {
                        let categoryLabel = '';

                        if (BREADCRUMB_TYPE.PRODUCTTYPE === breadcrumb.name && breadcrumb.isCurrentPage) {
                            breadcrumb.href = breadcrumb.categoryURL;
                            customPageURL = breadcrumb.categoryURL;

                        } else if (BREADCRUMB_TYPE.CATEGORY === breadcrumb.name && breadcrumb.isCurrentPage) {
                            categoryLabel = breadcrumb.label;
                            breadcrumb.href = breadcrumb.categoryURL + '?type=' + breadcrumb.name + '&label=' + breadcrumb.label;
                            customPageURL = breadcrumb.href;
                        } else if (BREADCRUMB_TYPE.SUBCATEGORY === breadcrumb.name && breadcrumb.isCurrentPage) {
                            breadcrumb.href = breadcrumb.categoryURL + '?type=' + breadcrumb.name + '&categorylabel=' + categoryLabel + '&label=' + breadcrumb.label;
                            customPageURL = breadcrumb.href;

                            let backNavigationURL = location.href;
                            if (!backNavigationURL.includes(window.location.origin + '/s/category') && !breadcrumb.href.includes(backNavigationURL)) {
                                customPageURL = backNavigationURL;
                            }

                        }
                        //  }
                    });
                }
            }
            if (customPageURL && customPageURL != undefined && customPageURL != null && customPageURL != '' && customPageURL != ' ') {
                window.open(customPageURL, '_self');

            } else {
                window.open(backPageURL, '_self');
            }


        }, false);
        //----END-----Added by Deepak Mali on 12 August 2021 Task : BUG-3639 (Vehicle Selection Information Cleared when switching between Parts and Accessories)
        //-Added by Deepak Mali on 23 August 2021 Task :
        //  window.open(window.location.origin +'/s/', "windowName", "",true) ;

        let markupData = await getReturnPolicyMarkup();
        if (markupData.B2B_Motocompacto_Disclaimer_Markup && markupData.B2B_Motocompacto_Disclaimer_Markup.Markup__c) {
            this.disclaimerMarkup = markupData.B2B_Motocompacto_Disclaimer_Markup.Markup__c;
        }
    }

    async getBrandDetails() {
        await getBrand({
            cartId: this.cartid
        }).then(result => {
            if (result) {
                this.brandName = result;
            }
        }).catch(error => {

        })
    }
    /**
     * This lifecycle hook fires when this component is removed from the DOM.
     * Commented by Deepak Mali on 11 August 2021
     */


    //added by Yashika for Wishlist R2 Story : starts here
    async handleMoveToWishlist(clickEvt) {

        let cartItemId = clickEvt.target.dataset.cartitemid;
        this.color = clickEvt.target.dataset.color;
        this.effAccId = this.myCustomSettings.data.Default_Guest_Account__c;
        this.stockKeepingUnit = clickEvt.target.dataset.productnumber;

        let quan = Array.from(this.template.querySelectorAll('.qty')).filter((element) => {
            if (element.dataset.itemId == cartItemId) {
                this._quantityFieldValue = element.value;
            }
        });
        if (!this._quantityFieldValue || this._quantityFieldValue - Math.floor(this._quantityFieldValue) != 0) {
            return;
        } else if (this._quantityFieldValue <= 0) {
            return;
        } else if (this._quantityFieldValue > 25) {
            this.showToastMessages('Quantity Limit', 'error', 'Sorry we can only have maximum of 25 quantity of a wishlist Item.');
            this.handleIsLoading();
            return;
        } else {
            this.partName = clickEvt.target.dataset.name;

            await getItemImage({
                cartItemId
            }).then(result => {
                this.imgUrl = result[0].Accessorie_Image_URL__c;
                this.prodType = result[0].Product_Type__c;
                this.opCode = result[0].op_code__c;
                this.brand = result[0].Product_Subdivision__c; ////added by Yashika for 8290
                this.productModelName = result[0].Product_Model_Marketing_Name__c;
                this.modelId = result[0].Product_Model__c;
                this.vin = result[0].Product_Identifier__c;
                this.itemPackageQuantity = result[0].Item_Package_Quantity__c;
                this.secId = result[0].Section_Id__c;
                this.illGrp = result[0].Illustration_Group_Image_Id__c;
                this.illId = result[0].Illustration_Id__c;
                this.productModelId = result[0].Product_Model__r.Product_Model_ID__c;//for adobe bug HDMP-17138
                this.modelYearAdobe = result[0].Product_Model__r.Model_Year__c;//for adobe bug HDMP-17138
                this.modelNameAdobe = result[0].Product_Model__r.Model_Name__c; //for adobe bug HDMP-17138
                this.modelTrimAdobe = result[0].Product_Model__r.Trim__c;//for adobe bug HDMP-17138

            })
                .catch((error) => { });

            await getProductPrice({ //added this method for 7537
                sku: this.stockKeepingUnit
            }).then(result => {
                this.itemPrice = result;
            })
            addItemToList({
                brand: this.brand,
                accountId: this.effAccId,
                communityId: communityId,
                sku: this.stockKeepingUnit,
                userId: this.userId,
                price: this.itemPrice,
                quantity: this._quantityFieldValue,
                accessoryName: this.partName,
                productImage: this.imgUrl,
                productType: this.prodType,
                color: this.color,
                op_code: this.opCode, //for 7911
                productModelName: this.productModelName,
                vin: this.vin,
                modelId: this.modelId,
                itemPackageQuantity: this.itemPackageQuantity,
                sectionId: this.secId,
                IllustrationId: this.illId,
                IllustrationImageId: this.illGrp
            }).then(result => {
                if (result.Id) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'Item Moved to Wishlist',
                        variant: 'success'
                    }));
                }
                this.dispatchEvent(new CustomEvent('singlecartitemdelete', { detail: cartItemId }));
                this.removeProductFromCookies(this.stockKeepingUnit);
                this.removeLocalStorage(this.stockKeepingUnit);
                //For adobe analytics : starts
                let eventMetadata = {
                    action_type: 'link',//for adobe bug-07
                    action_label: 'move to wishlist',
                    action_category: 'cart'
                };
                let events = 'move to wishlist';
                let addToCartProductDetails = {
                    breadcrumbs: [{ label: this.partName }],
                    products: { StockKeepingUnit: this.stockKeepingUnit },
                    context: {
                        brand: this.brand,
                        Model_Id__c: this.productModelId,
                        model: this.modelNameAdobe,
                        year: this.modelYearAdobe,
                        trim: this.modelTrimAdobe
                    }
                }
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'addToCartProductDetails': addToCartProductDetails, 'events': events } };
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                //  adobe analytics : end 

            })
                .catch((error) => {
                    if (JSON.stringify(error).includes('duplicate value found')) {

                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: 'Item already exists in Wishlist',
                            variant: 'error'
                        }));
                    } else {
                        this.dispatchEvent(new ShowToastEvent({
                            message: 'We are experiencing technical difficulties. Please try again later.',
                            variant: 'Error'
                        }));
                    }
                });
        }
    }

    //ends here 
    get displayItems() {
        this.ischangedList = []; //Added by saikiran as part HDMP -15591
        return this._items.map((item) => {
            // Create a copy of the item that we can safely mutate.
            let allProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList')); //Added By Bhawesh 22-02-2022 for 7434 BugNo.
            const newItem = { ...item };
            //const newItem2 = {...item };
            //Added by saikiran as part HDMP -15591
            var obj = {};
            obj.Id = newItem.cartItem.cartItemId;
            obj.isChanged = false;
            this.ischangedList.push(obj);

            // Set whether or not to display negotiated price
            newItem.showNegotiatedPrice =
                this.showNegotiatedPrice &&
                (newItem.cartItem.totalPrice || '').length > 0;

            // Set whether or not to display original price
            newItem.showOriginalPrice = displayOriginalPrice(
                this.showNegotiatedPrice,
                this.showOriginalPrice,
                newItem.cartItem.totalPrice,
                newItem.cartItem.totalListPrice
            );
            // get the label for original price to provide to the aria-label attr for screen readers
            newItem.originalPriceLabel = getLabelForOriginalPrice(
                this.currencyCode,
                newItem.cartItem.totalListPrice
            );


            //Vin Check Variable
            // Set Vin Check Variable
            newItem.vinCheckStatus = false;
            newItem.ProductVinInList = false;

            newItem.partNumber = newItem.cartItem.productDetails.sku;
            newItem.opCode = newItem.cartItem.productDetails.op_cd;
            newItem.productId = newItem.cartItem.productId;

            let tempcheck = JSON.parse(localStorage.getItem('VinFitmentCheck'));
            if (tempcheck != null) {
                if (tempcheck.hasOwnProperty(newItem.cartItem.productDetails.sku)) {
                    newItem.ProductVinInList = true;

                    newItem.vinCheckStatus = tempcheck[newItem.cartItem.productDetails.sku];
                }
            }

            if (this.removeProductId && newItem.cartItem && this.removeProductId == newItem.cartItem.cartItemId) {
                newItem.isRemoveProduct = true;
            } else {
                newItem.isRemoveProduct = false;
            }
            //added on 11/12 start
            if (newItem.vehicle) {
                newItem.vehicleName = newItem.vehicle.Product_Subdivision__c + ' ' + newItem.vehicle.Model_Year__c + ' ' + newItem.vehicle.Model_Name__c + ' ' + newItem.vehicle.Trim__c;
            }
            //added on 11/12 ends

            //motocompacto starts
            if (newItem.Product_Type__c == 'Motocompacto') {
                newItem.isMotocompacto = true;
            } else {
                newItem.isMotocompacto = false;
            }
            //motocompacto ends

            this.isLoading = false;

            return newItem;

        });
    }

    get labels() {
        return {
            quantity: 'Quantity',
            originalPriceCrossedOut: 'Original price (crossed out):'
        };
    }


    handleProductDetailNavigation(evt) {
        //evt.preventDefault();
        const productId = evt.target.dataset.productid;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                actionName: 'view'
            }
        });
    }


    async handleDeleteCartItem(clickEvt) {
        //for adobe bug HDMP-17138: starts
        this.partNameAdobe = clickEvt.target.dataset.name;
        console.log('adobe console', clickEvt.target.dataset.productnumber)
        this.partnumberAdobe = clickEvt.target.dataset.productnumber;
        //for adobe bug HDMP-17138: ends
        const cartItemId = clickEvt.target.dataset.cartitemid;
        await getItemImage({//for adobe bug: moved this to top 
            cartItemId
        }).then(result => {
            this.prodType = result[0].Product_Type__c;
            this.brand = result[0].Product_Subdivision__c; ////added by Yashika for 8290
            this.productModelId = result[0].Product_Model__r.Product_Model_ID__c;//for adobe bug HDMP-17138
            this.modelYearAdobe = result[0].Product_Model__r.Model_Year__c;//for adobe bug HDMP-17138
            this.modelNameAdobe = result[0].Product_Model__r.Model_Name__c;//for adobe bug HDMP-17138
            this.modelTrimAdobe = result[0].Product_Model__r.Trim__c;//for adobe bug HDMP-17138
        })
            .catch((error) => { });
        this.removeProductId = cartItemId
        this.dispatchEvent(new CustomEvent('singlecartitemdelete', { detail: cartItemId }));
        this.removeProductFromCookies(clickEvt.target.dataset.productnumber);
        this.removeLocalStorage(clickEvt.target.dataset.productnumber);
        //For adobe analytics : starts
        let events = 'scRemove';
        let eventMetadata = {
            action_type: 'link', //for adobe bug-07
            action_label: 'remove from cart',
            action_category: 'cart'
        };
        console.log('cart adobe console', this.brand, this.productModelId)
        let addToCartProductDetails = {
            breadcrumbs: [{ label: this.partNameAdobe }],
            products: { StockKeepingUnit: this.partnumberAdobe },
            context: {
                brand: this.brand,
                Model_Id__c: this.productModelId,
                model: this.modelNameAdobe,
                year: this.modelYearAdobe,
                trim: this.modelTrimAdobe
            }
        }
        const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'addToCartProductDetails': addToCartProductDetails, 'events': events } };
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        //  adobe analytics : end     
        //sessionStorage.setItem('removeCartItemId',this.removeProductId);
    }

    handleEnterKeyUpdate(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        if (charCode == 13) {
            this.handleQuantitySelectorBlur(
               
                {
                    target: {
                        dataset: {
                            itemId: event.target.dataset.itemId,
                            price: event.target.dataset.price,
                            skunumber : event.target.dataset.skunumber
                        }
                    }
                }
            );
        }
    }

    handleQuantitySelectorBlur(blurEvent) {
        this.isLoading = true;
        let validQuantity = [...this.template.querySelectorAll('.qty')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);


        //Stop the original event since we're replacing it.
        //blurEvent.stopPropagation();

        // Get the item ID off this item so that we can add it to a new event.
        const cartItemId = blurEvent.target.dataset.itemId;
        const selectedCartProd = blurEvent.target.dataset.skunumber; // Saravanan LTIM Added for HDMP-19511
        let enteredInputValue = 0;
        enteredInputValue = parseInt(this.template.querySelector('[data-item-id="' + cartItemId + '"]').value);
        var singlerec = this.ischangedList.find(ele => ele.Id === cartItemId); //Added by saikiran as part HDMP -15591
        // Get the quantity off the control, which exposes it.
        let quantity;
        let totalQuantity = 0;
        const price = blurEvent.target.dataset.price;
        let quan = Array.from(this.template.querySelectorAll('.qty')).filter((element) => {
            // Saravanan LTIM Added for 19511 to exclude the core charge quantity Quantity
            if(selectedCartProd == element.dataset.skunumber && element.dataset.itemId != cartItemId ){
                //totalQuantity += parseInt(enteredInputValue);
            }else{
                totalQuantity += parseInt(element.value);

            }
            // Saravanan LTIM Added for 19511 to exclude the core charge quantity Quantity
            if (element.dataset.itemId == cartItemId) {
                quantity = element.value;
            }
            
        });


        //updated as part of HDMP-12745
        //updated by saikiran as part HDMP -15591
        if (quantity <= 0 || quantity.includes('.') || (singlerec && !singlerec.isChanged)) {
            this.isLoading = false;
        }
        singlerec.isChanged = false; //updated by saikiran as part HDMP -15591
        getcartTotalQuantity({ cartId: this.cartid })
            .then(result => {
                if (totalQuantity > 25) {
                    this.isModalOpen = true;
                    if (result.CartItems.length > 0) {
                        result.CartItems.forEach(item => {
                            if (item.Id == cartItemId) {
                                var cartItemquantity = this.template.querySelector('[data-item-id="' + cartItemId + '"]');
                                cartItemquantity.value = item.Quantity;
                            }
                        });
                    }
                } else {
                    if (validQuantity) {
                        if (this.quantityUpdated) {
                            updateCartItem({ cartItemId: cartItemId, price: price, quantity: quantity })
                                .then(result => {
                                    if (result) {
                                        this.dispatchEvent(new CustomEvent('updatecartitem', { detail: true }));
                                    }
                                }).catch(error => { });
                        } else {
                            this.isLoading = false;
                            this.dispatchEvent(new CustomEvent('qtyvalidation', { bubbles: true, composed: true, detail: quantity }));
                        }
                    } else {
                        this.isLoading = false;
                        this.dispatchEvent(new CustomEvent('qtyvalidation', { bubbles: true, composed: true, detail: '-1' }));
                    }
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    closeModal() {
        this.isModalOpen = false;
    }
    showToastMessages(title, variant, message) {
        this.dispatchEvent(new ShowToastEvent({ title: title, variant: variant, message: message, mode: 'dismissable' }));
    }



    //Added By Shalini Soni 
    async redirectToPdp(event) {
        // console.log('$CI: event-',event);
        sessionStorage.setItem('fromcart', 'true');
        sessionStorage.removeItem('fromPLP');
        console.log('$CI: fromPLP: ', sessionStorage.getItem('fromPLP'));
        console.log('$CI: fromcart: ', sessionStorage.getItem('fromcart'));
        // added on 11/12 start
        let currentVehicleName;
        if (this.getCookie('Make') && this.getCookie('Year') && this.getCookie('Model') && this.getCookie('Trim')) {
            currentVehicleName = this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim');
        }
        if (event.target.dataset.vehicle != currentVehicleName) {
            sessionStorage.setItem('fromCartForBreadcrumbs', true);
        }
        else {
            sessionStorage.setItem('fromCartForBreadcrumbs', false);
        }
        // added on 11/12 end
        sessionStorage.setItem('vehicleBrand', this.brandName);
        let producturl = event.target.dataset.producturl;
        // console.log('$CI: producturl-',producturl);
        this.partNumber = event.target.dataset.productnumber;
        let motocompacto = event.target.dataset.motocompacto;
        console.log('motocompacto raj : ', motocompacto);
        if (motocompacto == 'true') {
            sessionStorage.setItem('isMotoCompacto', 'true');
        } else {
            sessionStorage.removeItem('isMotoCompacto');
        }
        let currentProduct;
        this.currentproductId = event.target.dataset.productid;
        await getProductSKUById({ prodId: event.target.dataset.productid }).then((result) => {
            this.partNumber = !this.partNumber ? result.StockKeepingUnit : this.partNumber;
            // console.log('$CI: result-',result);
            currentProduct = result;
            // console.log('$CI: currentProduct-',currentProduct);
        }).catch((err) => {
            // console.log('$CI: err-',err)
        });
        try {
            //Added Shalini Soni 90799
            // console.log('$CI: try');
            let allProductDetailsLists = [];
            allProductDetailsLists = JSON.parse(localStorage.getItem('allProductDetailsList'))
            /* if(allProductDetailsLists)
                console.log('$CI: allProductDetailsLists-',JSON.parse(JSON.stringify(allProductDetailsLists)));
            else
                console.log('$CI: allProductDetailsLists: ',allProductDetailsLists); */
            let selectedParts;
            //added by Pradeep for HDMP-8035
            const opCode = event.target.dataset.opcode;
            //ends here
            //  console.log('$CI: opCode: ',opCode);
            allProductDetailsLists.forEach(item => {
                //Modified by Pradeep for HDMP-8035
                // console.log('$CI: item: ',item);
                if (item.opCode && opCode) {
                    if ((item.ProductTypeForCart == 'Accessorie' && item.partNumber == JSON.stringify(this.partNumber) && item.opCode == opCode) ||
                        (item.ProductTypeForCart == 'Parts' && item.partNumber == JSON.stringify(this.partNumber))) {
                        selectedParts = item;
                    }
                    // console.log('$CI: if selectedParts1: ',selectedParts);
                }
                //HDMP-16101 starts here
                else if (item.selectedAcc && item.selectedAcc.op_cd && opCode) {
                    if (item.selectedAcc.Colors && item.selectedAcc.Colors.length > 1 && currentProduct && currentProduct.Color__c) {
                        // console.log('$CI: Colors ',item.selectedAcc.Colors);
                        item.selectedAcc.Colors.forEach(color => {
                            if (currentProduct.Color__c.toLowerCase().includes(color.colorName.toLowerCase())) {
                                this.partNumber = this.partNumber.replace(/['"]+/g, '').replace(/\\$/, "");
                                item.selectedAcc.partNumber = color.part_number.replace(/['"]+/g, '').replace(/\\$/, "");
                                sessionStorage.setItem('selectedColorPart', this.partNumber);
                            }
                        });
                    }

                    if ((item.ProductTypeForCart == 'Accessorie' && item.selectedAcc.partNumber == this.partNumber && item.selectedAcc.op_cd == opCode) ||
                        (item.ProductTypeForCart == 'Parts' && item.selectedAcc.partNumber == JSON.stringify(this.partNumber))) {
                        selectedParts = item;
                    }
                    // console.log('$CI: else if selectedParts: ',selectedParts);
                }
                //HDMP-16101 ends here
                else {
                    if (item.ProductTypeForCart == 'Accessorie' && item.partNumber == JSON.stringify(this.partNumber) ||
                        item.ProductTypeForCart == 'Parts' && item.partNumber == JSON.stringify(this.partNumber)) {
                        selectedParts = item;
                    }
                    // console.log('$CI: else selectedParts: ',selectedParts);
                    if (selectedParts && selectedParts.selectedAcc && selectedParts.selectedAcc.Colors && selectedParts.selectedAcc.Colors.length > 1) {
                        sessionStorage.setItem('selectedColorPart', this.partNumber);
                    }
                }

                //ends here
            });
            //console.log('$CI: selectedParts:::',selectedParts);
            //This If added by imtiyaz to redirect to home page in case of selected part is null or for wrong pdp page
            if (!selectedParts) {
                // console.log('$CI: NULL selectedParts-',selectedParts);
                window.location.assign(window.location.origin);
            } else {
                if (selectedParts && selectedParts != null && selectedParts != undefined && selectedParts.ProductTypeForCart == 'Parts' && selectedParts.ProductTypeForCart != null && selectedParts.ProductTypeForCart != undefined) {
                    // multiple tab issue3 starts here   
                    //this.createCookie('SelectedPart', selectedParts.SelectedPart, 1);
                    //this.createCookie('ProductNumber', selectedParts.ProductNumber, 1);                   
                    //this.createCookie('SubCategoryImageURL', selectedParts.SubCategoryImageURL, 1);
                    //this.createCookie('selectedBreadcrumbs', JSON.stringify(selectedParts.SelectedBreadcrumbs), 1);
                    sessionStorage.setItem('SelectedPart', selectedParts.SelectedPart);
                    sessionStorage.setItem('ProductNumber', selectedParts.ProductNumber);
                    sessionStorage.setItem('SubCategoryImageURL', selectedParts.SubCategoryImageURL);
                    sessionStorage.setItem('selectedBreadcrumbs', JSON.stringify(selectedParts.SelectedBreadcrumbs));

                    // multiple tab issue3 ends here
                    this.createCookie('ProductTypeForCart', selectedParts.ProductTypeForCart, 1);
                    this.createCookie('ProductFromCart', true, 1);
                    //console.log('$CI: if - selectedParts::',selectedParts);

                } else if (selectedParts && selectedParts != null && selectedParts != undefined && selectedParts.ProductTypeForCart && selectedParts.ProductTypeForCart != 'Parts') {
                    this.createCookie('ProductTypeForCart', selectedParts.ProductTypeForCart, 1);
                    this.createCookie('selectedAccessorie', JSON.stringify(selectedParts.selectedAcc), 1);
                    this.createCookie('ProductFromCart', true, 1);

                    //Added by shalini soni 11-10-29=021
                    localStorage.setItem('RequiredProducts', JSON.stringify(selectedParts.RequiredAccessories));
                    //console.log('$CI: else if - selectedParts::',selectedParts);
                    //End
                }
                // console.log('$CI: GO TO PDP: ');
                window.open(producturl, "_self");
            }
        } catch (error) {
            console.log('$CI: catch error', error);
            window.location.assign(window.location.origin);
        }
    }


    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }
    createCookie(name, value, days) {
        var expires;
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 100));
            expires = ";expires=" + date.toGMTString();
        } else {
            expires = "";
        }
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
    }
    quantityChange(event) {
        let quantity = event.target.value;
        let qtyCmp = this.template.querySelector(".qty");
        let qtyvalue = qtyCmp.value;
        let cartItemId = event.target.dataset.itemId;
        if (qtyvalue.includes('.')) {
            qtyCmp.setCustomValidity("Enter a valid value.");
        } else {
            qtyCmp.setCustomValidity(""); // clear previous value
        }
        qtyCmp.reportValidity()

        let validQuantity = [...this.template.querySelectorAll('.qty')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (validQuantity) {
            //Added by saikiran as part HDMP -15591
            this.quantityUpdated = true;
            var singlerec = this.ischangedList.find(ele => ele.Id === cartItemId);
            singlerec.isChanged = true;
        } else {
            this.quantityUpdated = false;
            this.dispatchEvent(new CustomEvent('qtyvalidation', { bubbles: true, composed: true, detail: quantity }));
        }

    }
    //Added by Deepak Mali 11 Aug 2021 Task : BUG-

    removeProductFromCookies(partNumber) {
        let allProductDetailsLists = [];
        allProductDetailsLists = JSON.parse(localStorage.getItem('allProductDetailsList'))
        if (allProductDetailsLists != null) { //added by Yashika for 8290
            allProductDetailsLists.forEach((element, index) => {
                if (element.partNumber == JSON.stringify(partNumber)) {
                    allProductDetailsLists.splice(index, 1);
                }

            });
        }
        localStorage.setItem('allProductDetailsList', JSON.stringify(allProductDetailsLists));
    }

    removeLocalStorage(removePartNumber) {
        let ChecklocalStorage = localStorage.getItem('VinFitmentCheck') != null ? true : false;
        if (ChecklocalStorage == true) {
            let NewArraytemp = JSON.parse(localStorage.getItem('VinFitmentCheck'));
            delete NewArraytemp[removePartNumber];
            localStorage.setItem('VinFitmentCheck', JSON.stringify(NewArraytemp));
        }
    }

    openDisclaimerPopup() {
        this.showDisclaimerMarkup = true;
    }

    //Saravanan LTIM Core Charge 7811 & 7812
    handleDisclamerPopup(event) {

        console.log('event.currentTarget.dataset.id -- > ', event.currentTarget.dataset.id);
        this.disclaimerType = event.currentTarget.dataset.id;

        this.showDealerModal = true;

    }

    //LTIM Core Charge 7811 & 7812
    handleShowHide(event) {
        this.showDealerModal = false;

    }

    // Saravanan LTIM Added to update the Cart Items - 18566
    updateCartItemName() {
        updateCartItemstoSyncDynamically({ cartId: this.cartid })
            .then((data) => {

                if (data == true) {
                    this.dispatchEvent(new ShowToastEvent({
                        message: 'The items previously saved in your shopping cart have been moved to My Wish List.',
                        variant: 'success'
                    }));
                }

                console.log('No Records are found' + this.cartid);
            })
            .catch((error) => {
                console.log('Something went wrong' + JSON.stringify(error));
            });
    }
    // Saravanan LTIM Ends to update the Cart Items - 18566

}
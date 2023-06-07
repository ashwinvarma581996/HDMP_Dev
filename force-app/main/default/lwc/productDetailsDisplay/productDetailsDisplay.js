/******************************************************************************* 

Name:  productDetailsDisplay
Business Unit: HDM
Date: April 2021
Description: This is PDP of parts. 

******************************************************************************* 

MODIFICATIONS – Date | Dev Name | Method | User Story 
20-07-2022 | Yashika | handleBreadcrumbClick | 5300
12-09-2022  | Pradeep Singh | getBreadcrumbs | HDMP-16101
22-02-2023  | Aditya Saini | Added Reman Text | HDMP-16502
*******************************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import getCategory from '@salesforce/apex/B2BGetInfo.getCategoryId';
import createGuestAndAddToCart from '@salesforce/apex/B2BGuestUserController.createSetupDataAndUser';
import checkIfUserIsLoggedIn from '@salesforce/apex/B2BGuestUserController.checkIfUserIsLoggedIn';
import createCartSetup from '@salesforce/apex/B2BGuestUserController.createCartSetup';
import createUser from '@salesforce/apex/B2BGuestUserController.createUser';
import addItem_Clone from '@salesforce/apex/B2BGuestUserController.addItem_Clone';
import createUserAndCartSetup from '@salesforce/apex/B2BGuestUserController.createUserAndCartSetup';
import createPermissions from '@salesforce/apex/B2BGuestUserController.createPermissionSetsSynchronous';
import addProductToCartItem_Clone from '@salesforce/apex/B2BGuestUserController.addProductToCartItem_Clone';
import checkIfUserHasCartAndSetup from '@salesforce/apex/B2BGuestUserController.checkIfUserHasCartAndSetup';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getCurrentDealerId } from 'c/utils';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';
import getCartId from '@salesforce/apex/B2BGetInfo.getCartId';
import getAllProuctQuantity from '@salesforce/apex/B2BGetInfo.getAllProuctQuantity';
import getCartItemBrand from '@salesforce/apex/B2BGetInfo.getCartItemBrand'; //added by Yashika for HDMP-16716
import HDMP_MESSAGE_CHANNEL_2 from "@salesforce/messageChannel/HDMPMessageForCart__c";
import addItemToList from '@salesforce/apex/B2B_LoggedInUserWishlist.addItemToList'; //added by Yashika for R2 story Wishlist 
import NAME_FIELD from '@salesforce/schema/User.Name';
import getCustomSettings from '@salesforce/apex/B2B_LoggedInUserWishlist.getCustomSettings';
import { getRecord } from 'lightning/uiRecordApi';
import getProductPrice from '@salesforce/apex/B2B_LoggedInUserWishlist.getProductPrice';
//ends
import getModelId from '@salesforce/apex/B2BGuestUserController.getModelId'; //added by Yashika for 8708
import getModelIdByVIN from '@salesforce/apex/B2BGuestUserController.getModelIdByVIN'; //added by Yashika for 8708
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import MaintenanceImages from '@salesforce/resourceUrl/MaintenanceImages';
import hondaImages from '@salesforce/resourceUrl/honda_images';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';//for adobe analytics
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";//for adobe analytics
import RemanText from '@salesforce/label/c.B2B_Reman_Part_Identification_Label'; // Added as a part of HDMP-16533 - Aditya

// A fixed entry for the home page.
const homePage = {
    name: 'Home',
    type: 'standard__namedPage',
    attributes: {
        pageName: 'home'
    }
};
//Added By Bhawesh 24-01-2022 start
const STORAGE = {
    SEARCHED_TERM: 'searchedTerm',
    CHOSEN_FILTER: 'chosenFilter',
    FROM_PDP: 'FromPDP',
    CLICKED_BACK_TO_RESULT: 'clickedBackToResult',
    YES: 'yes',
    NO: 'no',
    CLOSE: 'close'
} //ends here
//End
const PRODUCT_TYPE = 'Part';
/**
 * An organized display of product information.
 *
 * @fires ProductDetailsDisplay#addtocart
 * @fires ProductDetailsDisplay#createandaddtolist
 */

const BREADCRUMB_TYPE = {
    BRAND: 'brand',
    PRODUCTTYPE: 'producttype',
    CATEGORY: 'category',
    SUBCATEGORY: 'subcategory',
    PRODUCT: 'product',
    SEARCH: 'search'
}


export default class ProductDetailsDisplay extends NavigationMixin(
    LightningElement
) {

    selectDealerIcon = imageResourcePath + '/location.png';

    @track userId = Id;

    isLoading = false;

    @api pricetype;
    @api shoppingBrand;

    @track breadcrumbs = [];
    // Added as a part of HDMP-16502 - Aditya
    label = {
        RemanText
    };

    @track
    isModalOpen = false;
    EnableImage = true;
    DisableImage = false;
    warningPopup = false;
    cartId;
    @track typeofproduct;
    @track breadcrumbBrand;
    @track disableAddtoCart;
    @track partnumber;
    @api recordId;
    @track vincompatibility;
    @track partNumber = '';
    @track partName = '';
    @track cartBrandDB = ''; //added by Yashika for HDMP-16716
    @track isMaintenancePart = false; //Added by Bhawesh R2 story 5492 fast moving item 
    @track categoryData;//Added by Faraz for HDMP-10203
    @api effectiveAccountId;
    //Added by Faraz for fast moving item
    hondaPLPImage = MaintenanceImages + '/MaintenanceImages/Honda/AllParts_575x300.jpg';
    acuraPLPImage = MaintenanceImages + '/MaintenanceImages/Acura/Acura_575x300.jpg';
    maintenanceImagePLP;
    //End
    //added by Yashika for 8708
    @track year;
    @track model;
    @track trim;
    @track modelId; //ends
    @track hideBackToResults; //ends
    dreamshopDefaultImage = hondaImages + '/1200px-No_image_available.png';
    imageURLError = false;
    isReman = false;// Added as a part of HDMP-16502 - Aditya
    showPricingAndCCDisclaimer = false;//Added by Vivek for HDMP-18846
    coreCharge;// Added as a part of HDMP-16502 - Aditya

    // LTIM 7811 and 7812 Vraiable Declarations
    disclaimerType; // Added by ashwin
    showDealerModal = false; // Added by ashwin
    dealerReturnPolicyMarkup = ""; // Added by ashwin
    showDisclaimer = true;

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

    /**
     * An event fired when the user indicates the product should be added to their cart.
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *   - Cancelable: false
     *
     * @event ProductDetailsDisplay#addtocart
     * @type {CustomEvent}
     *
     * @property {string} detail.quantity
     *  The number of items to add to cart.
     *
     * @export
     */

    /**
     * An event fired when the user indicates the product should be added to a new wishlist
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *   - Cancelable: false
     *
     * @event ProductDetailsDisplay#createandaddtolist
     * @type {CustomEvent}
     *
     * @export
     */



    /**
     * A product category.
     * @typedef {object} Category
     *
     * @property {string} id
     *  The unique identifier of a category.
     *
     * @property {string} name
     *  The localized display name of a category.
     */

    /**
     * A product price.
     * @typedef {object} Price
     *
     * @property {string} negotiated
     *  The negotiated price of a product.
     *
     * @property {string} currency
     *  The ISO 4217 currency code of the price.
     */

    @track allDetails;
    @api selectedPartList;
    @track partValue;
    @api isPickupDealer;
    @track plpURL;
    /**
     * Gets or sets teh stock keeping unit (or SKU) of the product.
     *
     * @type {string}
     */
    sku;
    @track hotSpotCoordinates;
    @api image;
    @api productNumber;
    @api dealerEmailAddress;
    @api dealerPhoneNumber;
    @api isDealerSelected = getCurrentDealerId() ? true : false;

    @track showDBProduct = false; // Added by Bhawesh on 28-01-2022
    @track productDataFromDB; // Added by Bhawesh on 28-01-2022
    @track itemAddedToWishlist = false; //added by Yashika for R2 story: wishlist : starts
    @track myWishlistUrl;
    @track userFirstName = '';
    @track brand;
    @track isItemExist = false;
    @track showWishlist = false;
    _product; //ends here
    @track productModelMarketingName;
    @track fromCartPage; //Added By Imtiyaz
    // implicitly during the component descruction lifecycle.
    @wire(MessageContext)
    messageContext;

    @wire(MessageContext)
    messageContext2;


    @api
    get product() {
        return this._product;
    }

    set product(value) {
        if (value) {
            // Added by Bhawesh on 28-01-2022
            this.productDataFromDB = value && value.fields ? value.fields : '';
            this._product = value;
            this.sku = value.fields.Part__c;
            this.description = value.fields.Description;
            if (this.productDataFromDB && (!this.productDataFromDB.ImageURL__c || this.productDataFromDB.ImageURL__c.length == 0)) {
                this.imageURLError = true;
            }
            if(this.productDataFromDB && this.productDataFromDB.ImageURL__c && this.productDataFromDB.ImageURL__c.includes('/1200px-No_image_available.png')){
                this.productDataFromDB.ImageURL__c = this.dreamshopDefaultImage;
            }
            this.getBreadcrumbs(value.fields);
        }
    }

    //added by Yashika for R2 story wishlist: starts
    @wire(getCustomSettings)
    myCustomSettings;

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

    //Added By Pradeep for HDMP-7253
    canvasLoad() {
        var canvas = this.template.querySelector("canvas");
        var img = this.template.querySelector("img");
        if (canvas && img) {
            let originalimgWidth;
            let originalimgHeight;
            let newImgWidth = img.width;
            let newImgHeight = img.height;
            canvas.width = newImgWidth;
            canvas.height = newImgHeight;
            const resRatio = Math.round(newImgWidth / newImgHeight);

            if (resRatio >= 2) {
                originalimgWidth = 1267;
                originalimgHeight = 583;
            } else {
                originalimgWidth = 1467 * resRatio;
                originalimgHeight = 1467;
            }
            var context = canvas.getContext("2d");
            context.clearRect(0, 0, canvas.width, canvas.height);
            const hotSpots = JSON.parse(JSON.stringify(this.hotSpotCoordinates));
            hotSpots.forEach(element => {
                const xPosOrg = Math.floor(element.XPosition * (originalimgWidth / 10000)); //585
                const yPosOrg = Math.floor(element.YPosition * (originalimgHeight / 10000)); //288

                const xPos = (xPosOrg / originalimgWidth) * newImgWidth;
                const yPos = (yPosOrg / originalimgHeight) * newImgHeight;
                context.beginPath();
                //context.arc(xPos, yPos, 10, 0, 2 * Math.PI);
                // updated by Pradeep for HDMP-7253
                if (window.screen.width < 401) {
                    context.arc(xPos, yPos, 5, 0, 2 * Math.PI);
                } else {
                    context.arc(xPos, yPos, 10, 0, 2 * Math.PI);
                }
                //ends here
                context.fillStyle = 'red';
                context.globalAlpha = 0.4;
                context.fill();
                context.stroke();
            });
        }


    }
    //ends here


    connectedCallback() {
        // updated by Pradeep for HDMP-7253
        window.addEventListener("resize", this.canvasLoad.bind(this));
        // ends here
        //added by Yashika for r2 story wishlist: starts
        this.myWishlistUrl = window.location.origin + '/s/my-wishlist';
        //ends

        this.partValue = JSON.parse(JSON.stringify(this.selectedPartList));
        // Added by Bhawesh on 28-01-2022 start
        if (this.partValue == null) {
            this.showDBProduct = true;
            return;
        } else {
            this.showDBProduct = false;
        }
        // end
        this.partName = this.partValue && this.partValue.PartDescription ? this.partValue.PartDescription : this.partName;
        // alert('test PDP->',this.getCookie('SubCategoryImageURL'));

        //let imgUrlCart =  this.getCookie('SubCategoryImageURL');
        const hotSpotData = JSON.parse(this.getCookie('HotSpots'));


        const imageCode = this.image ? this.image.split('/').pop() : '';
        if (hotSpotData && imageCode) {
            const currentPart = hotSpotData.find(elm => (elm.partNumber === this.partValue.PartNumber &&
                elm.IllustrationReferenceCode === this.partValue.IllustrationReferenceCode &&
                imageCode === elm.imageCode));
            if (currentPart && currentPart['coordinates']) {
                this.hotSpotCoordinates = JSON.parse(JSON.stringify(currentPart['coordinates']));
            }
        }

        // Added as a part of HDMP-16502 - Aditya
        if (this.partValue.isReman) {

            this.isReman = this.partValue.isReman;
            // Added by Vivek HDMP-11846 MSRP issues
            this.showPricingAndCCDisclaimer=this.partValue.isReman;
            this.coreCharge = this.partValue.CoreCostAmount;
        }
        // Added as a part of HDMP-16502 - Aditya END
        this.price = this.partValue && this.partValue.SuggestedRetailPriceAmount ? this.partValue.SuggestedRetailPriceAmount : this.price;
        if (this.price <= 0) { //Added by Deepak
            this.disableAddToCart = true;
            this.price = 0;
        }
        //Added by Vivek M for defect HDMP-18846
        console.log('Price type '+this.pricetype )

        if (this.pricetype.toLowerCase() == 'msrp price') {
            console.log('MSRP value '+this.partValue.SuggestedRetailPriceAmount)
            if (this.partValue.SuggestedRetailPriceAmount==0  || this.partValue.SuggestedRetailPriceAmount == null) {
                console.log('MSPR Price(No dealer price) and MSRP=0 or null ');   
                this.disableAddToCart = true;//Disable button
                this.showPricingAndCCDisclaimer = false;//Parts pricing needs to be hidden&What is corecharge should not be displayed
                this.showAddToCart = false;//Contact dealer will be displayed 
            }
        }
        //for defect HDMP-18864
        if (this.pricetype.toLowerCase() == 'dealer price') {
            console.log('Dealer value '+this.price)
            if (this.price==0  || this.price == null) {
                console.log('Dealer Price(No dealer price) and Dealerprice=0 or null ');   
                this.disableAddToCart = true;//Disable button
                this.showPricingAndCCDisclaimer = false;//Parts pricing needs to be hidden&What is corecharge should not be displayed
                this.showAddToCart = false;//Contact dealer will be displayed 
            }
        }
        //End of changes by Vivek M for HDMP-18846 & HDMP-18864

        if (localStorage.getItem('isFirstAddToCart')) {
            this.firstAddCartVIN = localStorage.getItem('VINEntered');
            localStorage.setItem('isFirstAddToCart', false);
        }
        if (!this.recordId) {
            this.retrieveProduct();
        }
        this.fetchcartId();
        this._resolveConnected();
        this.handleLoad();
        this.partnumber = this.sku;
        // multiple tab issue3 starts here
        //this.categoryData = JSON.parse(localStorage.getItem('category'));
        this.categoryData = JSON.parse(sessionStorage.getItem('category'));
        console.log('$PDD: fromPLP: ', sessionStorage.getItem('fromPLP'));
        console.log('$PDD: fromcart: ', sessionStorage.getItem('fromcart'));
        this.fromCartPage = sessionStorage.getItem('fromcart') ? true : false;
        console.log('$PDD: fromCartPage: ', this.fromCartPage);
        // multiple tab issue3 ends here
    }
    retrieveProduct() {
        var baseurl = window.location.href;
        var finalurl = baseurl.split('/');
        this.recordId = finalurl[6];
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
    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }
    getBreadcrumbs(productFields) {
        var productDiv = productFields.Division__c;
        var productName = productFields.Name;
        if (productDiv) {
            if (productDiv === 'A') {
                sessionStorage.setItem('brand', 'Honda');
            }
            if (productDiv === 'B') {
                sessionStorage.setItem('brand', 'Acura');
            }
            if (productDiv === 'A;B') {
                //HDMP-16101 starts here
                if (sessionStorage.getItem('brand')) {

                }
                else {
                    sessionStorage.setItem('brand', this.getCookie('Make'));
                }
                //HDMP-16101 ends here

            }
            if (localStorage.getItem('breadcrumbsProductMap') || sessionStorage.getItem('breadcrumbsMap')) {
                // this.breadcrumbs = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap'))).get(this.recordId) ? new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap'))).get(this.recordId) : new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                if (this.fromCartPage) {
                    this.breadcrumbs = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap'))).get(this.recordId) ? new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap'))).get(this.recordId) : new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                } else {
                    this.breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand')) ? new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand')) : new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap'))).get(this.recordId);
                }
                if (this.breadcrumbs) {
                    try {
                        // added on 11/12 start
                        if (JSON.parse(sessionStorage.getItem('fromCartForBreadcrumbs'))) {// && sessionStorage.getItem('vehicleBrand2') && sessionStorage.getItem('vehicleBrand') && sessionStorage.getItem('vehicleBrand2') != sessionStorage.getItem('vehicleBrand')){
                            this.hideBackToResults = true;
                        }
                        // added on 11/12 end                      
                    } catch (error) {
                        console.log('OUTPUT : ', error);
                    }
                    let categoryLabel = '';
                    let breadcrumbsFilterList = [];
                    this.breadcrumbs.forEach(breadcrumb => {

                        //Added by Bhawesh R2 story 5492 fast moving item 
                        this.isMaintenancePart = breadcrumb && breadcrumb.label == 'MAINTENANCE' ? true : false;
                        //End
                        if (BREADCRUMB_TYPE.BRAND === breadcrumb.name) {
                            this.breadcrumbBrand = breadcrumb.label;
                        }
                        else if (BREADCRUMB_TYPE.PRODUCTTYPE === breadcrumb.name) {
                            breadcrumb.href = breadcrumb.categoryURL + '?type=producttype';
                            this.typeofproduct = breadcrumb.label;
                        }
                        // added on 11/12 start
                        else if (JSON.parse(sessionStorage.getItem('fromCartForBreadcrumbs'))) {// && sessionStorage.getItem('vehicleBrand2') && sessionStorage.getItem('vehicleBrand') && sessionStorage.getItem('vehicleBrand2') != sessionStorage.getItem('vehicleBrand')){
                            return;
                        }
                        // added on 11/12 end
                        else if (BREADCRUMB_TYPE.CATEGORY === breadcrumb.name) {
                            categoryLabel = breadcrumb.label;
                            breadcrumb.href = breadcrumb.categoryURL + '?type=' + breadcrumb.name + '&label=' + breadcrumb.label;
                            //Added by Bhawesh R2 story 5492 fast moving item 
                            if (this.isMaintenancePart) {
                                this.plpURL = breadcrumb.href;
                            }
                            //End
                            }
                        else if (BREADCRUMB_TYPE.SUBCATEGORY === breadcrumb.name) {
                            breadcrumb.href = breadcrumb.categoryURL + '?type=' + breadcrumb.name + '&categorylabel=' + categoryLabel + '&label=' + breadcrumb.label;
                            this.plpURL = breadcrumb.href;
                        }
                        breadcrumb.isCurrentPage = false;
                        breadcrumbsFilterList.push(breadcrumb);
                    });
                    this.breadcrumbs = breadcrumbsFilterList;
                    //Added by Faraz R2 story 5492 fast moving item 
                    if (this.breadcrumbs[0].label && this.isMaintenancePart) {
                        this.maintenanceImagePLP = this.breadcrumbs[0].label == 'Honda' ? this.hondaPLPImage : this.breadcrumbs[0].label == 'Acura' ? this.acuraPLPImage : '';
                    }
                    //End
                    if (this.partName) {
                        this.breadcrumbs.push({
                            label: this.partName,
                            name: BREADCRUMB_TYPE.PRODUCT,
                            href: 'javascript:void(0);',
                            isCurrentPage: true
                        });
                    } else {
                        this.breadcrumbs.push({
                            label: productName,
                            name: BREADCRUMB_TYPE.PRODUCT,
                            href: 'javascript:void(0);',
                            isCurrentPage: true
                        });
                    }
                    //Added by Faraz for 8251 on 10March22
                    this.breadcrumbs.forEach(breadcrumb => {
                        if (breadcrumb.label.toLowerCase() == BREADCRUMB_TYPE.SEARCH) {
                            breadcrumb.isCurrentPage = false; //modified by Yashika for 5300
                        }
                    });
                    //End
                }
            }
        }
        console.log('pdp breadcrumb pdp', this.breadcrumbs)
        //for adobe analytics:start
        let brand = sessionStorage.getItem('brand');
        let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
        breadcrumbsMap.set(brand, this.breadcrumbs);
        sessionStorage.setItem('breadcrumbsMapPDPforAd', JSON.stringify([...breadcrumbsMap]));
        //for adobe:ends 
        console.log('breadcrumbsMapPDPforAd', sessionStorage.getItem('breadcrumbsMapPDPforAd'))
    }

    navigateToBack(event) {
        history.back();
    }

    /**
     * A product field.
     * @typedef {object} CustomField
     *
     * @property {string} name
     *  The name of the custom field.
     *
     * @property {string} value
     *  The value of the custom field.
     */

    /**
     * An iterable Field for display.
     * @typedef {CustomField} IterableField
     *
     * @property {number} id
     *  A unique identifier for the field.
     */

    /**
     * Gets or sets which custom fields should be displayed (if supplied).
     *
     * @type {CustomField[]}
     */

    cartcheck;

    /**
     * Gets or sets whether the cart is locked
     *
     * @type {boolean}
     */
    @api cartLocked;

    /**
     * Gets or sets the name of the product.
     *
     * @type {string}
     */
    description;

    @api requiredQuantity;

    /**
     * Gets or sets the id of the product.
     *
     * @type {string}
     */

    @api effectiveaccountid;

    /**
     * Gets or sets the product image.
     *
     * @type {Image}
     */



    /**
     * Gets or sets whether the product is "in stock."
     *
     * @type {boolean}
     */
    @api inStock = false;

    /**
     * Gets or sets the name of the product.
     *
     * @type {string}
     */
    /**
     * Gets or sets the price - if known - of the product.
     * If this property is specified as undefined, the price is shown as being unavailable.
     *
     * @type {Price}
     */
    @api price;



    @api showAddToCart;

    @api resolvedCategoryPath;

    _invalidQuantity = false;
    _quantityFieldValue = 1;
    _categoryPath;


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
        }
        //Added By Bhawesh 24-01-2022 for redirect Plp page click form back to result start
        //added by Yashika for 5300
        if (event.srcElement.innerHTML == 'Search') {
            localStorage.setItem('SearchClickPDP', true);
        } else if (event.srcElement.innerHTML.includes('Back to results')) {
            // multiple tab issue3 starts here
            // localStorage.setItem('backToResult', true);
            sessionStorage.setItem('backToResult', true);
            // multiple tab issue3 ends here
        } else if (event.srcElement.innerHTML == 'Parts') {
            localStorage.setItem('partSerachValue', '');
            localStorage.removeItem('searchedTerm');
            sessionStorage.removeItem('searchedTerm');
            let currentVehicleName;
            if (this.getCookie('Make') && this.getCookie('Year') && this.getCookie('Model') && this.getCookie('Trim')) {
                currentVehicleName = this.getCookie('Make') + ' ' + this.getCookie('Year') + ' ' + this.getCookie('Model') + ' ' + this.getCookie('Trim');
            }
            if (currentVehicleName != sessionStorage.getItem('VehicleName') && JSON.stringify(sessionStorage.getItem('fromCartForBreadcrumbs'))) {
                sessionStorage.removeItem('VehicleName');
                //  sessionStorage.removeItem('fromCartForBreadcrumbs');
            }
            // added on 11/12 start
            // sessionStorage.setItem('fromCartForBreadcrumbs',false);
            // added on 11/12 end
        }
        // End
        let allBreadCrumbs = [];
        allBreadCrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
        allBreadCrumbs.forEach(element => {
            if (element.name == 'category') {
                if (element.label == event.srcElement.innerHTML) {
                    localStorage.setItem('SearchClickPDP', true);
                    localStorage.setItem('CategSearch', true);
                }
            }
            if (element.name == 'subcategory') {
                if (element.label == event.srcElement.innerHTML) {
                    // multiple tab issue3 starts here
                    // localStorage.setItem('backToResult', true);
                    sessionStorage.setItem('backToResult', true);
                    // multiple tab issue3 ends here
                }
            }
        }); //ends: 5300
        sessionStorage.removeItem('relayStatePage');
        this.redirectToPlp();

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

    /**
     * Gets or sets the ordered hierarchy of categories to which the product belongs, ordered from least to most specific.
     *
     * @type {Category[]}
     */
    @api
    get categoryPath() {
        return this._categoryPath;
    }

    set categoryPath(newPath) {
        this._categoryPath = newPath;
        this.resolveCategoryPath(newPath || []);
    }

    get hasPrice() {

        // return ((this.price || {}).negotiated || '').length > 0;
        return (this.price || {}) > 0;
    }


    handleQuantityChange(event) {
        this._quantityFieldValue = event.target.value;
        //START - Added by Shalini Soni 15 Sept 2021 :
        let quantityCmp = this.template.querySelector(".quantity");
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

    /**
     * Emits a notification that the user wants to add the item to their cart.
     *
     * @fires ProductDetailsDisplay#addtocart
     * @private
     */


    @api
    displayData;


    handleIsLoading() {
        this.isLoading = !this.isLoading;
    }
    //added by Yashika for R2 story wishlist: starts
    async handleAddToWishlist() {
        this.handleIsLoading();
        //added by Yashika for 8838: starts
        if (this.vincompatibility == true) {
            let vinCookieValue = localStorage.getItem('VINEntered');
            this.vin = vinCookieValue;
            // for multiple tab issue. starts here
            if (localStorage.getItem("effectiveVehicle") && JSON.parse(localStorage.getItem("effectiveVehicle"))["brands"]) {
                let vehicleDetail = JSON.parse(localStorage.getItem("effectiveVehicle"))["brands"];
                if (vehicleDetail) {
                    vehicleDetail.forEach(element => {
                        if (sessionStorage.getItem('vehicleBrand') === element.brand) {
                            this.year = element.year;
                            this.model = element.model;
                            this.trim = element.trim;
                            this.productModelId =element.Model_Id__c;
                            this.productModelMarketingName = element.make + ' ' + this.year + ' ' + this.model + ' ' + this.trim;
                        }
                    });
                }
            }
            // multiple tab issue. ends here
            else if (this.getCookie('Make') != 'undefined' && this.getCookie('Make') != 'null' && this.getCookie('Make') != null && this.getCookie('Make') != '') {
                this.year = this.getCookie('Year');
                this.model = this.getCookie('Model');
                this.trim = this.getCookie('Trim');
                //this.vin = this.getCookie('Vin');
                this.productModelMarketingName = this.getCookie('Make') + ' ' + this.year + ' ' + this.model + ' ' + this.trim;
            }
            getModelIdByVIN({ vin: vinCookieValue })
                .then(result => {
                    this.modelId = result.Product_Model__c;
                    if(this.productModelId==''){
                        this.productModelId = result.Product_Models__r.Product_Model_ID__c;//for adobe bug-11
                    }
                })
                .catch(error => { })
        } else {
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
                            this.productModelId =element.Model_Id__c;
                            this.productModelMarketingName = element.make + ' ' + this.year + ' ' + this.model + ' ' + this.trim;
                        }
                    });
                }
            }
            // multiple tab issue. ends here
            if (this.getCookie('Make') != 'undefined' && this.getCookie('Make') != 'null' && this.getCookie('Make') != null && this.getCookie('Make') != '') {
                this.year = this.getCookie('Year');
                this.model = this.getCookie('Model');
                this.trim = this.getCookie('Trim');
                this.vin = this.getCookie('Vin');
                this.productModelMarketingName = this.getCookie('Make') + ' ' + this.year + ' ' + this.model + ' ' + this.trim;

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
        } //ends: 8838
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
            let productPrice;
            await getProductPrice({ //added this method for 7537
                sku: this.sku
            }).then(result => {
                productPrice = result;
            })
            if (this.isMaintenancePart == true) {
                this.image = this.maintenanceImagePLP;
            }
            addItemToList({
                brand: this.brand,
                accountId: effAccId,
                communityId: communityId,
                sku: this.sku,
                userId: this.userId,
                price: productPrice,
                quantity: this._quantityFieldValue,
                accessoryName: this.partName,
                productImage: this.image,
                productType: PRODUCT_TYPE,
                productModelName: this.productModelMarketingName,
                vin: this.vin,
                modelId: this.modelId,
                itemPackageQuantity: 1,
                sectionId: this.categoryData && this.categoryData.sectionId ? this.categoryData.sectionId : '',//Added by Faraz for 10203
                IllustrationId: this.categoryData && this.categoryData.illustrationId ? this.categoryData.illustrationId : '',//Added by Faraz for 10203
                IllustrationImageId: this.categoryData && this.categoryData.illustrationGroupImageId ? this.categoryData.illustrationGroupImageId : '',//Added by Faraz for 10203
                coreCharge:this.coreCharge,// Aditya HDMP-16502
            }).then(result => {
                if (result.Id) {
                    this.itemAddedToWishlist = true;
                    if (sessionStorage.getItem('breadcrumbsMap')) {
                        let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                        let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')))
                        breadcrumbsProductMap.set(this.recordId, breadcrumbsMap.get(sessionStorage.getItem('brand')));
                        localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                        console.log('$CI_PDD: breadcrumbsProductMap1', localStorage.getItem('breadcrumbsProductMap') ? JSON.parse(localStorage.getItem('breadcrumbsProductMap')) : localStorage.getItem('breadcrumbsProductMap'));
                    }
                    this.addLocalStorage();
                }
                this.handleIsLoading();
                //For adobe analytics : starts
                let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                let action_category = breadcrumbs[1].label + (breadcrumbs.length >= 3 ? '-' + breadcrumbs[2].label : '') + (breadcrumbs.length == 4 ? '-' + breadcrumbs[3].label : '')
                breadcrumbs.push({ label: this.partName });//for adobe bug-21
                let eventMetadata = {
                    action_type: 'button',
                    action_label: 'save to wishlist',//for adobe bug-22
                    action_category: action_category
                };
                let events = 'move to wishlist';
                let addToCartProductDetails = {//for adobe bug-11
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
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
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
    }
    //ends
    notifyAddToCart() {
        let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
        //condition modified by Yashika for HDMP-16716
        if ((localStorage.getItem('cartBrand') && localStorage.getItem('cartBrand') != sessionStorage.getItem('vehicleBrand')) ||
            (this.cartBrandDB && this.cartBrandDB.length && this.cartBrandDB != sessionStorage.getItem('vehicleBrand'))
        ) {
            this.handleIsLoading();
            this.isModalOpen = true;
        } else {
            addProductToCartItem_Clone({
                accountId: getCurrentDealerId(),
                sku: this.sku,
                communityId: communityId,
                price: this.price,
                quantity: parseInt(this._quantityFieldValue),
                color: '',
                accessoryName: this.partName,
                productType: PRODUCT_TYPE, // Added by shalini soni for HDMP-5702 for R2 Story
                accImageURL: this.image, // Added by Yashika for 7380
                brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290
                modelId: this.modelId, //added by Yashika for 8708
                vin: this.vin, //added by Yashika for 8708
                vincompatibility: this.vincompatibility,
                sectionId: this.categoryData && this.categoryData.sectionId ? this.categoryData.sectionId : '',//Added by Faraz for 10203
                IllustrationId: this.categoryData && this.categoryData.illustrationId ? this.categoryData.illustrationId : '',//Added by Faraz for 10203
                IllustrationImageId: this.categoryData && this.categoryData.illustrationGroupImageId ? this.categoryData.illustrationGroupImageId : '',//Added by Faraz for 10203
                productModelMarketingName: this.productModelMarketingName, //added by Yashika for 10179
                coreCharge:this.coreCharge //Aditya HDMP 17802
            }).then(result => {
                this.notifyToCustomCart(); //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
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
                        console.log('$CI_PDD: breadcrumbsProductMap2', localStorage.getItem('breadcrumbsProductMap') ? JSON.parse(localStorage.getItem('breadcrumbsProductMap')) : localStorage.getItem('breadcrumbsProductMap'));

                    }
                    this.handleIsLoading();
                    //For adobe analytics : starts
                    let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                    let action_category = breadcrumbs[1].label + (breadcrumbs.length >= 3 ? '-' + breadcrumbs[2].label : '') + (breadcrumbs.length == 4 ? '-' + breadcrumbs[3].label : '')
                    breadcrumbs.push({ label: this.partName });//for adobe bug-21
                    let eventMetadata = {
                        action_type: 'button',
                        action_label: 'add to cart',
                        action_category: action_category
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
                    publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                    //  adobe analytics : end 
                }
            }).catch(error => { })
        }
    }

    handleAddToCart2(event) {
        checkIfUserIsLoggedIn().then(result => {
            if (result) {
                this.getCartItemBrand(); //added by Pradeep for HDMP-16716

            } else {
                let quant = this._quantityFieldValue;
                let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290       

                createUser({}).then(result => {
                    let userRecord = result;
                    createCartSetup({
                        userId: userRecord.Id,
                        accountId: getCurrentDealerId()
                    }).then(result => {
                        let cartId = result;
                        addItem_Clone({
                            userId: userRecord.Id,
                            productId: this.recordId,
                            quantity: quant,
                            redirectUrl: window.location.href,
                            wc: cartId,
                            price: this.price,
                            color: '',
                            accessoryName: this.partName,
                            productType: PRODUCT_TYPE, // Added by shalini soni for HDMP-5702 R2 Story
                            accImageURL: this.image, // Added by Yashika for 7380
                            brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290
                            modelId: this.modelId, //added by Yashika for 8708 
                            vin: this.vin, //added by Yashika for 8708
                            vincompatibility: this.vincompatibility,
                            sectionId: this.categoryData && this.categoryData.sectionId ? this.categoryData.sectionId : '',//Added by Faraz for 10203
                            IllustrationId: this.categoryData && this.categoryData.illustrationId ? this.categoryData.illustrationId : '',//Added by Faraz for 10203
                            IllustrationImageId: this.categoryData && this.categoryData.illustrationGroupImageId ? this.categoryData.illustrationGroupImageId : '',//Added by Faraz for 10203
                            productModelMarketingName: this.productModelMarketingName //added by Yashika for 10179
                        }).then(redirectUrl => {
                            this.notifyToCustomCart(); //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
                            window.location.replace(redirectUrl);
                        }).catch(error => { })
                    }).catch(error => { })
                }).catch(error => { })
            }
        });
    }

    handleAddToCart1(event) {
        this.partNumber = event.target.dataset.partnumber;
        if (!this._quantityFieldValue || this._quantityFieldValue - Math.floor(this._quantityFieldValue) != 0) {
            // this.showToastMessege('Error', 'Please enter correct quantity', 'error');
            return;
        } else if (this._quantityFieldValue <= 0) {
            // this.showToastMessege('Quantity Limit', 'Quantity should be greater than 0 and no more than 50', 'error');
            return;
        } else if (this._quantityFieldValue > 25) {
            // this.showToastMessege('Quantity Limit', 'Quantity cannot exceed 50', 'error');
            this.showToastMessages('Quantity Limit', 'error', 'Sorry we can only have maximum of 25 quantity in an order.');
            return;
        } else {
            //added by Yashika for 13110: starts
            if (this.isMaintenancePart == true) {
                this.image = this.maintenanceImagePLP;
            }
            //13110: ends
            //added by Yashika for 8708: starts
            if (this.vincompatibility == true) {
                let vinCookieValue = localStorage.getItem('VINEntered');
                this.vin = vinCookieValue;
                // for multiple tab issue. starts here
                if (localStorage.getItem("effectiveVehicle") && JSON.parse(localStorage.getItem("effectiveVehicle"))["brands"]) {
                    let vehicleDetail = JSON.parse(localStorage.getItem("effectiveVehicle"))["brands"];
                    if (vehicleDetail) {
                        vehicleDetail.forEach(element => {
                            if (sessionStorage.getItem('vehicleBrand') === element.brand) {
                                this.year = element.year;
                                this.model = element.model;
                                this.trim = element.trim;
                                this.productModelId =element.Model_Id__c;
                                this.productModelMarketingName = element.make + ' ' + this.year + ' ' + this.model + ' ' + this.trim;
                                console.log('$PDD: this.productModelMarketingName - ', this.productModelMarketingName);
                            }
                        });
                    }
                }
                // multiple tab issue. ends here
                else if (this.getCookie('Make') != 'undefined' && this.getCookie('Make') != 'null' && this.getCookie('Make') != null && this.getCookie('Make') != '') {
                    this.year = this.getCookie('Year');
                    this.model = this.getCookie('Model');
                    this.trim = this.getCookie('Trim');
                    //this.vin = this.getCookie('Vin');
                    this.productModelMarketingName = this.getCookie('Make') + ' ' + this.year + ' ' + this.model + ' ' + this.trim;
                }
                getModelIdByVIN({ vin: vinCookieValue })
                    .then(result => {
                        this.modelId = result.Product_Models__c;
                        if(this.productModelId==''){
                            this.productModelId = result.Product_Models__r.Product_Model_ID__c;//for adobe bug-11
                        }
                    })
                    .catch(error => { })
            } else {
                console.log('$PDD: ELSE');
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
                                this.productModelId =element.Model_Id__c;
                                this.productModelMarketingName = element.make + ' ' + this.year + ' ' + this.model + ' ' + this.trim;
                            }
                        });
                    }
                }
                // multiple tab issue. ends here
                else if (this.getCookie('Make') != 'undefined' && this.getCookie('Make') != 'null' && this.getCookie('Make') != null && this.getCookie('Make') != '') {
                    this.year = this.getCookie('Year');
                    this.model = this.getCookie('Model');
                    this.trim = this.getCookie('Trim');
                    this.vin = this.getCookie('Vin');
                    this.productModelMarketingName = this.getCookie('Make') + ' ' + this.year + ' ' + this.model + ' ' + this.trim;
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
                    }).catch(error => {
                        console.log('error atc', error)
                    })
            } //ends: 8708
            if (this.cartId) {
                this.getProductQuan();
            } else {
                this.updateQuantity();
            }
        }
    }
    updateQuantity() {
        this.handleIsLoading();
        checkIfUserIsLoggedIn().then(result => {
            console.log('$PDD: checkIfUserIsLoggedIn ', result);
            if (result) {
                this.userId = result;
                checkIfUserHasCartAndSetup({
                    communityId: communityId,
                    userId: this.userId
                })
                    .then(result => {
                        console.log('$PDD: checkIfUserHasCartAndSetup ', result);
                        if (result) {
                            this.cartId = result.cartId;
                            this.getCartItemBrand(); //added by Pradeep for HDMP-16716                            
                        }
                    })
                    .catch(error => { });
            } else {
                let quant = this._quantityFieldValue;
                let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
                createUserAndCartSetup({
                    accountId: getCurrentDealerId()
                }).then(result => {
                    //alert(this.coreCharge + this.communityId);
                    //let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
                    let userRecord = result.userId;
                    let cartId = result.cartId;
                    createPermissions({
                        userId: userRecord,
                    }).then(result => {
                        addItem_Clone({
                            userId: userRecord,
                            productId: this.recordId,
                            quantity: quant,
                            redirectUrl: window.location.href,
                            wc: cartId,
                            price: this.price,
                            color: '',
                            accessoryName: this.partName,
                            productType: PRODUCT_TYPE, // Added by shalini soni for HDMP-5702 for story
                            accImageURL: this.image, // Added by Yashika for 7380
                            brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290
                            modelId: this.modelId, //added by Yashika for 8708 
                            vin: this.vin, //added by Yashika for 8708
                            vincompatibility: this.vincompatibility,
                            sectionId: this.categoryData && this.categoryData.sectionId ? this.categoryData.sectionId : '',//Added by Faraz for 10203
                            IllustrationId: this.categoryData && this.categoryData.illustrationId ? this.categoryData.illustrationId : '',//Added by Faraz for 10203
                            IllustrationImageId: this.categoryData && this.categoryData.illustrationGroupImageId ? this.categoryData.illustrationGroupImageId : '',//Added by Faraz for 10203
                            productModelMarketingName: this.productModelMarketingName, //added by Yashika for 10179
                            coreCharge : this.coreCharge, // Saravanan LTIM Added for 19527 , 19528
                            communityId: communityId // Saravanan LTIM Added for 19527 , 19528
                        }).then(redirectUrl => {
                            if (this.vincompatibility == true) {
                                localStorage.setItem('isFirstAddToCart', true);
                            }
                            localStorage.setItem('cartBrand', sessionStorage.getItem('brand'));
                            if (sessionStorage.getItem('breadcrumbsMap')) {
                                let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                                let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')))
                                breadcrumbsProductMap.set(this.recordId, breadcrumbsMap.get(sessionStorage.getItem('brand')));
                                localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                                console.log('$CI_PDD: breadcrumbsProductMap3', localStorage.getItem('breadcrumbsProductMap') ? JSON.parse(localStorage.getItem('breadcrumbsProductMap')) : localStorage.getItem('breadcrumbsProductMap'));
                                window.location.replace(redirectUrl);
                            }
                            //For adobe analytics : starts
                            let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                            let action_category = breadcrumbs[1].label + (breadcrumbs.length >= 3 ? '-' + breadcrumbs[2].label : '') + (breadcrumbs.length == 4 ? '-' + breadcrumbs[3].label : '')
                            breadcrumbs.push({ label: this.partName });//for adobe bug-21
                            let eventMetadata = {
                                action_type: 'button',
                                action_label: 'add to cart',
                                action_category: action_category
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
                            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                            //  adobe analytics : end 
                        }).catch(error => {
                            console.log('error', error)
                        });
                    }).catch(error => {
                        console.log('error', error)
                    });
                }).catch(error => {
                    console.log('error', error)
                });
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

    hanldevinfittoparent(event) {
        this.vincompatibility = event.detail;
    }

    /**
     * Emits a notification that the user wants to add the item to a new wishlist.
     *
     * @fires ProductDetailsDisplay#createandaddtolist
     * @private
     
    notifyCreateAndAddToList() {
        this.dispatchEvent(new CustomEvent('createandaddtolist'));
    }
     */
    /**
     * Updates the breadcrumb path for the product, resolving the categories to URLs for use as breadcrumbs.
     *
     * @param {Category[]} newPath
     *  The new category "path" for the product.
     */
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

            });
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    //added by Yashika for R2 story Wishlist
    closeModalWishlist() {
        this.itemAddedToWishlist = false;
    } //ends
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }

    /**
     * Gets the iterable fields.
     *
     * @returns {IterableField[]}
     *  The ordered sequence of fields for display.
     *
     * @private
     */

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
            })
            .catch((error) => { });
    }
    //added by Yashika for HDMP-16716
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
            });
    }// 16716 ends
    getProductQuan() {
        getAllProuctQuantity({ cartId: this.cartId })
            .then((result) => {
                let prodWithQuantity = result;
                let proceedNext = false;
                let totalpartQuantity = 0;

                if (prodWithQuantity && Object.keys(prodWithQuantity).length != 0) {
                    for (var i in prodWithQuantity) {
                        totalpartQuantity += prodWithQuantity[i];
                        if (i == this.sku) {
                            let quantity = parseInt(prodWithQuantity[i]) + parseInt(1);
                            //START Added Shalini Soni 17 Sept 2021
                            let totalQuantity = parseInt(prodWithQuantity[i]) + parseInt(this._quantityFieldValue);
                            //END
                            if (totalQuantity > 25) {
                                this.isLoading = false;
                                // this.showToastMessages('Quantity Limit', 'error', 'Quantity should be greater than 0 and no more than 25.');//commented as part of HDMP-13671
                                proceedNext = false;
                                break;
                            } else { proceedNext = true; }
                        } else { proceedNext = true; }
                    }
                    // Added by Lakshman on 23/02/2022 - HDMP-5074 EPIC Starts
                    totalpartQuantity += parseInt(this._quantityFieldValue);
                    if (totalpartQuantity > 25) {
                        this.isLoading = false;
                        this.showToastMessages('Quantity Limit', 'error', 'Sorry we can only have maximum of 25 quantity in an order.');
                        proceedNext = false;
                    }
                    // Added by Lakshman on 23/02/2022 - HDMP-5074 EPIC Ends
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
                value: this.vincompatibility,
                writable: true,
                enumerable: true,
                configurable: true
            })

            localStorage.setItem('VinFitmentCheck', JSON.stringify(NewArraytemp));
        }
        /*HDMP-12342 starts here
        else {
            var cObj = {};
            Object.defineProperty(cObj, this.sku, {
                value: this.vincompatibility,
                writable: true,
                enumerable: true,
                configurable: true
            })
            localStorage.setItem('VinFitmentCheck', JSON.stringify(cObj));
        } /*HDMP-12342 ends here*/
        //Added Shalini Soni 90799  
        try {
            let existingallProductDetailsList = []
            let alreadyExistInList = false;
            existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));
            if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                existingallProductDetailsList.forEach(element => {
                    let elementNumber = element.partNumber.replace(/^"|"$/g, ''); //Remove double qcuotes from partNumber
                    if (elementNumber == this.partNumber) {
                        alreadyExistInList = true;
                    }
                })
            }
            if (!alreadyExistInList) {
                //Added Shalini Soni 90799
                let selectedPart = this.selectedPartList;
                let allProductDetailsList = [];
                let productDetails = { SelectedPart: '', ProductNumber: '', SelectedBreadcrumbs: '', SubCategoryImageURL: '', partNumber: '', ProductType: '', productFromCart: false };
                productDetails.SelectedPart = JSON.stringify(selectedPart);
                productDetails.ProductNumber = JSON.stringify(selectedPart.productNumber);
                productDetails.SelectedBreadcrumbs = JSON.stringify(this.resolvedCategoryPath);
                productDetails.SubCategoryImageURL = JSON.stringify(this.image);
                productDetails.partNumber = JSON.stringify(this.partNumber);
                productDetails.ProductTypeForCart = 'Parts';
                productDetails.ProductFromCart = true;
                allProductDetailsList.push(productDetails);
                existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));
                if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                    existingallProductDetailsList.push(productDetails);
                    localStorage.setItem('allProductDetailsList', JSON.stringify(existingallProductDetailsList));
                } else {
                    localStorage.setItem('allProductDetailsList', JSON.stringify(allProductDetailsList));
                }
            }

        } catch (error) {
            //   alert(error.message);
        }

    }

    showToastMessages(title, variant, message) {
        this.dispatchEvent(new ShowToastEvent({ title: title, variant: variant, message: message, mode: 'dismissable' }));
    }
    redirectToPlp() {
        let lastShoppingUrl = this.plpURL.split('?')[0];
        let categoryLabel = '';
        let hasCategoryExist = false;
        let allBreadCrumbs = [];
        allBreadCrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
        allBreadCrumbs.forEach(element => {
            if (element.name == 'category') {
                categoryLabel = element.label;
                hasCategoryExist = true;
                lastShoppingUrl = lastShoppingUrl.split('?')[0] + '?type=' + element.name + '&label=' + element.label;
            }
            if (element.name == 'subcategory') {
                lastShoppingUrl = lastShoppingUrl.split('?')[0] + '?type=' + element.name + '&categorylabel=' + categoryLabel + '&label=' + element.label;
            } //added By Yashika for 5300: starts
            if (element.name == 'search') {
                lastShoppingUrl = this.plpURL.split('?')[0];
            }
        });
        if (localStorage.getItem('SearchClickPDP', true) == 'true') {
            lastShoppingUrl = this.plpURL.split('?')[0];
        } //5300: ends
        if (lastShoppingUrl != undefined && lastShoppingUrl != null) {
            if (hasCategoryExist && lastShoppingUrl.indexOf("/s/category/") > -1) {
                window.location.href = lastShoppingUrl;
            }
        }
    }
    //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
    notifyToCustomCart() {
        // you can also pass like this object info her --> const message = { message: { 'dealerLabel': dealerLabel, 'products': products } 
        const message = { message: 'Calling for update cartItem count' };
        publish(this.messageContext2, HDMP_MESSAGE_CHANNEL_2, message);
    }
    //Ended
    renderedCallback() {
        //CodeToSend-START
        if (this.breadcrumbs && Array.isArray(this.breadcrumbs) && this.breadcrumbs.length) {
            this.breadcrumbs.forEach((bread, index, arr) => {
                if (bread.label == 'Parts' && this.breadcrumbs[index + 1].name == 'product' && this.fromCartPage) {
                    this.hideBackToResults = true;
                }
                if (bread.categoryURL && bread.categoryURL == 'MAINTENANCE' && this.fromCartPage) {
                    this.isMaintenancePart = true;
                    this.maintenanceImagePLP = bread.label == 'Honda' ? this.hondaPLPImage : bread.label == 'Acura' ? this.acuraPLPImage : '';
                    this.image = this.maintenanceImagePLP;
                }
            });
            console.log('$CI_PDD: hideBackToResults - ', this.hideBackToResults);
        }
        //CodeToSend-END
        if(sessionStorage.getItem('SEO_SectionId') && sessionStorage.getItem('SEO_SectionId') != null){
            if(sessionStorage.getItem('SEO_MegaCategory') && sessionStorage.getItem('SEO_MegaCategory') != null){
                if(sessionStorage.getItem('SEO_Sku') && sessionStorage.getItem('SEO_Sku') != null){
                    sessionStorage.removeItem('SEO_SectionId');
                    sessionStorage.removeItem('SEO_MegaCategory');
                    sessionStorage.removeItem('SEO_Sku');
                }
            }
        }
    }

    handleGoToWishlist() {
        window.open(this.myWishlistUrl, "_self");
    }

    handleShowDefaultImage() {
        this.imageURLError = true;
    }

    //LTIM Core Charge 7811 & 7812 , 7817

    handleDisclamerPopup(event) {

        console.log('event.currentTarget.dataset.id -- > ', event.currentTarget.dataset.id);
        this.disclaimerType = event.currentTarget.dataset.id;

        this.showDealerModal = true;

    }



    handleShowHide(event) {
        this.showDealerModal = false;

    }
}
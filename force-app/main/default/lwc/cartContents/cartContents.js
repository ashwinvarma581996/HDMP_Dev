/******************************************************************************* 

Name:  cartContents

Business Unit: HDM

Date: April 2021

Description: This is parent component of cart page

******************************************************************************* 

MODIFICATIONS – Date | Dev Name | Method | User Story 

09-06-2022 | Yashika | <added header> | <User Story Associated> 

*******************************************************************************/
import { api, wire, LightningElement, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import communityId from '@salesforce/community/Id';
import updateCartItem from '@salesforce/apex/B2BCartControllerSample.updateCartItem';
import deleteCartItem from '@salesforce/apex/B2BCartControllerSample.deleteCartItem';
import deleteCart from '@salesforce/apex/B2BCartControllerSample.deleteCart';
import createCart from '@salesforce/apex/B2BCartControllerSample.createCart';
import GetDealerPrice from '@salesforce/apex/B2B_INSystemIntegration.GetDealerPrice';
import { getCurrentDealerId, getCurrentDealer } from 'c/utils';
// jhicks 8/24/21 - added in order to get color from cart
import getCartItemsFromDB from '@salesforce/apex/CartItemsCtrl.getCartItemList2';
import getNewCartItems from '@salesforce/apex/CartItemsCtrl.getCartItemList3';//added by Yashika for 8708
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { isCartClosed } from 'c/cartUtils';
import { publish, subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import HDMP_MESSAGE_CHANNEL_FOR_CART from "@salesforce/messageChannel/HDMPMessageForCart__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'// Added by Aditya for HDMP-18862
import moveUnavailableCartItemsToWishList from '@salesforce/apex/CartItemsCtrl.moveUnavailableCartItemsToWishList';// Added by Aditya for HDMP-18862

const DELAY = 300;
// Event name constants
const CART_CHANGED_EVT = 'cartchanged';
const UPDATED_CART_ITEMS = 'updatedcartitems';
//const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';


// Locked Cart Status
const LOCKED_CART_STATUSES = new Set(['Processing', 'Checkout']);

/**
 * A sample cart contents component.
 * This component shows the contents of a buyer's cart on a cart detail page.
 * When deployed, it is available in the Builder under Custom Components as
 * 'B2B Sample Cart Contents Component'
 *
 * @fires CartContents#cartchanged
 * @fires CartContents#cartitemsupdated
 */

export default class CartContents extends NavigationMixin(LightningElement) {
    @track _cartItemsClone;
    @track isLoading = false;
    @track isLoggedIn = false;
    @api cartItemRes;
    @track isVinUpdated = false;
    unavailablecart = ''; // Added by Aditya for HDMP-18862
    @api
    get cartItemsClone() {
        return this._cartItemsClone;
    }
    set cartItemsClone(value) {

        if (value) {
            this._cartItemsClone = value;
            this.updateCartItems();
        }
    }
    @api cartStatus;
    subscription = null;

    // By using the MessageContext @wire adapter, unsubscribe will be called
    // implicitly during the component descruction lifecycle.
    @wire(MessageContext)
    messageContext;

    /**
     * An event fired when the cart changes.
     * This event is a short term resolution to update the cart badge based on updates to the cart.
     *
     * @event CartContents#cartchanged
     *
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * An event fired when the cart items change.
     * This event is a short term resolution to update any sibling component that may want to update their state based
     * on updates in the cart items.
     *
     * In future, if LMS channels are supported on communities, the LMS should be the preferred solution over pub-sub implementation of this example.
     * For more details, please see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel_considerations
     *
     * @event CartContents#cartitemsupdated
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * A cart line item.
     *
     * @typedef {Object} CartItem
     *
     * @property {ProductDetails} productDetails
     *   Representation of the product details.
     *
     * @property {number} quantity
     *   The quantity of the cart item.
     *
     * @property {string} originalPrice
     *   The original price of a cart item.
     *
     * @property {string} salesPrice
     *   The sales price of a cart item.
     *
     * @property {string} totalPrice
     *   The total sales price of a cart item, without tax (if any).
     *
     * @property {string} totalListPrice
     *   The total original (list) price of a cart item.
     */

    /**
     * Details for a product containing product information
     *
     * @typedef {Object} ProductDetails
     *
     * @property {string} productId
     *   The unique identifier of the item.
     *
     * @property {string} sku
     *  Product SKU number.
     *
     * @property {string} name
     *   The name of the item.
     *
     * @property {ThumbnailImage} thumbnailImage
     *   The quantity of the item.
     */

    /**
     * Image information for a product.
     *
     * @typedef {Object} ThumbnailImage
     *
     * @property {string} alternateText
     *  Alternate text for an image.
     *
     * @property {string} id
     *  The image's id.
     *
     * @property {string} title
     *   The title of the image.
     *
     * @property {string} url
     *   The url of the image.
     */

    /**
     * Representation of a sort option.
     *
     * @typedef {Object} SortOption
     *
     * @property {string} value
     * The value for the sort option.
     *
     * @property {string} label
     * The label for the sort option.
     */

    @api cartid;
    @api accountid;

    /**
     * The recordId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    recordId;

    @track
    EmptyCart;
    /**
     * The effectiveAccountId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    effectiveAccountId = this.accountId;

    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    @wire(CurrentPageReference)
    pageRef;

    /**
     * Total number of items in the cart
     * @private
     * @type {Number}
     */
    @api cartItemCount;

    /**
     * A list of cartItems.
     *
     * @type {CartItem[]}
     */
    cartItems;

    /**
     * A list of cartItems retrieved from DB instead of API.
     *
     * @type {CartItem[]}
     */
    cartItemsFromDB;

    /**
     * A list of sortoptions useful for displaying sort menu
     *
     * @type {SortOption[]}
     */
    sortOptions = [
        { value: 'CreatedDateDesc', label: this.labels.CreatedDateDesc },
        { value: 'CreatedDateAsc', label: this.labels.CreatedDateAsc },
        { value: 'NameAsc', label: this.labels.NameAsc },
        { value: 'NameDesc', label: this.labels.NameDesc }
    ];

    /**
     * Specifies the page token to be used to view a page of cart information.
     * If the pageParam is null, the first page is returned.
     * @type {null|string}
     */
    pageParam = null;

    /**
     * Sort order for items in a cart.
     * The default sortOrder is 'CreatedDateDesc'
     *    - CreatedDateAsc—Sorts by oldest creation date
     *    - CreatedDateDesc—Sorts by most recent creation date.
     *    - NameAsc—Sorts by name in ascending alphabetical order (A–Z).
     *    - NameDesc—Sorts by name in descending alphabetical order (Z–A).
     * @type {string}
     */
    sortParam = 'Sku';

    /**
     * Is the cart currently disabled.
     * This is useful to prevent any cart operation for certain cases -
     * For example when checkout is in progress.
     * @type {boolean}
     */
    isCartClosed = false;

    /**
     * The ISO 4217 currency code for the cart page
     *
     * @type {string}
     */
    @api currencyCode;

    /**
     * Gets whether the cart item list is empty.
     *
     * @type {boolean}
     * @readonly
     */
    get isCartEmpty() {
        // If the items are an empty array (not undefined or null), we know we're empty.
        return Array.isArray(this.cartItems) && this.cartItems.length === 0;
    }

    /**
     * The labels used in the template.
     * To support localization, these should be stored as custom labels.
     *
     * To import labels in an LWC use the @salesforce/label scoped module.
     * https://developer.salesforce.com/docs/component-library/documentation/en/lwc/create_labels
     *
     * @type {Object}
     * @private
     * @readonly
     */
    get labels() {
        return {
            loadingCartItems: 'Loading Cart Items',
            clearCartButton: 'Clear Cart',
            sortBy: 'Sort By',
            cartHeader: '',
            emptyCartHeaderLabel: 'Your cart’s empty',
            emptyCartBodyLabel:
                'Search or browse products, and add them to your cart. Your selections appear here.',
            closedCartLabel: "The cart that you requested isn't available.",
            CreatedDateDesc: 'Date Added - Newest First',
            CreatedDateAsc: 'Date Added - Oldest First',
            NameAsc: 'Name - A to Z',
            NameDesc: 'Name - Z to A'
        };
    }

    /**
     * Gets the cart header along with the current number of cart items
     *
     * @type {string}
     * @readonly
     * @example
     * 'Cart (3)'
     */
    get cartHeader() {
        return `${this.labels.cartHeader} ${this.cartItemCount}`;
    }

    /**
     * Gets whether the item list state is indeterminate (e.g. in the process of being determined).
     *
     * @returns {boolean}
     * @readonly
     */
    get isCartItemListIndeterminate() {
        return !Array.isArray(this.cartItems);
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;
        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            HDMP_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    wireuser({ error, data }) {
        if (error) {
            console.log('OUTPUT : ', error);
        } else if (data) {
            let name = data.fields.Name.value;
            if (USER_ID == undefined || USER_ID == null || name.includes('Guest')) {
                this.isLoggedIn = false;
            } else {
                this.isLoggedIn = true;
            }
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
        // Initialize 'cartItems' list as soon as the component is inserted in the DOM.
        //this.updateCartItems();
    }

    // Handler for message received by component
    handleMessage(data) {
        if (data.message.products) {
            this.handleUpdateCart();
        }
    }

    handleUpdateCartItem() {
        console.log('inside handleUpdateCartItem');
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.updateCartItems();
        }, DELAY);
        this.handleCartUpdate()
        const message = { message: { 'updatesoncart': true } };
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
    }

    handleUpdateCart() {
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.updateCartItems();
        }, DELAY);
    }
    //added by Yashika for 8708: starts
    async handleVinChange(event) {
        let items = event.detail;
        this.cartItemRes = items;
        await getNewCartItems({ cartId: this.cartid })

            .then((result) => {
                this.isVinUpdated = true;
                this.cartItemRes = result;
                this.updateCartItems();

            })
            .catch(error => {

            })
    }//8708: ends

    /**
     * Get a list of cart items from the server via imperative apex call
     */
    async updateCartItems() {
        this.notifyToCustomCart(); // here calling when user change qrt on cart page and try to update : Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
        // Call the 'getCartItems' apex method imperatively         

        //this._cartItemsClone = result.cartItems;
        //let product_Type = this.getCookie('ProductType');
        let product_Type = sessionStorage.getItem('ProductType');
        //if (product_Type && product_Type == 'Accessories') {
        let opCodeArr = [];
        let vehicle = 0;
        await getCartItemsFromDB({ cartId: this.cartid })
            .then(async (result) => {
                //added by Yashika for 8708: starts
                if (this.isVinUpdated == true) {
                    result = this.cartItemRes;
                    this.isVinUpdated = false;

                }//8708: ends

                //  Added by Bhawesh for bug number 7888 start
                let cartIdNameMap = new Map();
                //Added By Bhawesh 03-03-2022  for Bug No.7929 start 
                let cartItemIdAndProductTypeMap = new Map();
                //End
                let cartItemIdAndProductModelMap = new Map();//added by Yashika for 8708
                let cartItemIdAndVinMap = new Map();
                let cartIdAndOpCodeMap = new Map(); // Added by Bhawesh on 17-03-2022
                let idAndDealerInstallLbl = new Map();
                let remanMap = new Map(); // Saravanan LTIM 7813 , 7815
                let remanMapCoreCharge = new Map(); // // Saravanan LTIM 7813 , 7815
                if (result) {
                    result.forEach((element) => {
                        cartIdNameMap.set(element.Id, element.Name);
                        //Added By Bhawesh 03-03-2022  for Bug No.7929 start 
                        if (element.hasOwnProperty('Product_Type__c')) {
                            cartItemIdAndProductTypeMap.set(element.Id, element.Product_Type__c);
                        }
                        //End

                        // Added by Bhawesh on 17-03-2022 start
                        if (element.hasOwnProperty('Product_Type__c') && element.Product_Type__c == 'Accessory') {
                            cartIdAndOpCodeMap.set(element.Id, element.op_code__c);
                            opCodeArr.push(element.op_code__c);
                        }
                        // End
                        //added by Yashika for 8708: starts
                        if (element.hasOwnProperty('Product_Model__r') && element.Product_Model__r.Model_Year__c != undefined && element.Product_Model__r.Model_Year__c != '' && element.Product_Model__r.Model_Year__c != null) {
                            cartItemIdAndProductModelMap.set(element.Id, element.Product_Model__r);
                        }//ends
                        //added by Yashika for 8708: starts
                        if (element.hasOwnProperty('Product_Identifier__c') && element.Product_Identifier__c != 'undefined') {
                            cartItemIdAndVinMap.set(element.Id, element.Product_Identifier__c);
                        }//ends
                        if (!vehicle && element.Product_Model__c && element.Product_Model__r.Product_Subdivision__c) {
                            vehicle = element.Product_Model__r.Product_Subdivision__c.toLowerCase() == 'honda' ? 1 : element.Product_Model__r.Product_Subdivision__c.toLowerCase() == 'acura' ? 2 : 0;
                        }

                        // Saravanan LTIM 7813
                        if (element.Product_Type__c == 'Core Charge') {

                            remanMap.set(element.Id, true);
                        }

                        // Saravanan LTIM 7813 , 7815, 7817
                        if (element.Product2.Core_Charge_Unit_Price__c > 0) {

                            remanMapCoreCharge.set(element.Id, true);
                        }
                        //Start Added by Aditya for HDMP-18862
                        // Below if Condition Commented by ashwin  for 19451
                        //if (element.Product2.Product_availability__c == 'Not Available') {
                        this.unavailablecart = element.CartId;
                        // }
                        //End Added by Aditya for HDMP-18862
                    });
                    let dealer = getCurrentDealer();
                    console.log('dealer::' + dealer);
                    if (dealer && dealer.dealerNo && vehicle && opCodeArr.length) {
                        await GetDealerPrice({
                            dealerNo: dealer.dealerNo,
                            divisionId: vehicle,
                            accessories: JSON.stringify(opCodeArr)
                        }).then(response => {
                            if (response) {
                                let data = JSON.parse(response);
                                console.log('OUTPUTdata : ', data);
                                if (data && !data.isError) {
                                    result.forEach(element => {
                                        element.dealerInstall = false;
                                        if (element.Product_Type__c && element.Product_Type__c == 'Accessory') {
                                            let installCharge = data.Accessories.filter(item => item.OpCode == element.op_code__c)[0].InstallationCharges;
                                            console.log('installCharge : ', installCharge);
                                            if (installCharge && installCharge != null && installCharge != undefined) {
                                                element.dealerInstall = true;
                                            }
                                        }
                                        idAndDealerInstallLbl.set(element.Id, element.dealerInstall);
                                    });
                                    console.log('result : ', result);
                                }
                            }
                        })
                            .catch(error => {
                                console.error('Error:', error);
                            });
                    }
                }
                // End

                let cartItemsList = [];
                const colorMap = new Map();
                const cartitemIdAndNameMap = new Map();
                let cartItemIdAndPickUpDealerMap = new Map();
                //HDMP-16050 starts here
                let vinFitMap = new Map();
                //HDMP-16050 ends here
                console.log('OUTPUT : ', this._cartItemsClone);
                // modified by Pradeep for performance
                let productMarketingMap = new Map();
                result.forEach((element) => {
                    console.log('counting : ', element);
                    if (element.hasOwnProperty('Product_Type__c') && element.Product_Type__c == 'Accessory') {
                        if (element.hasOwnProperty('Color__c')) {
                            colorMap.set(element.Id, element.Color__c);
                        }
                    }
                    // modified below 2 lines by Shalini for performance and Bug-8511
                    cartitemIdAndNameMap.set(element.Id, element.Name);
                    cartItemIdAndPickUpDealerMap.set(element.Id, element.Product2.PickupatDealer__c);
                    //HDMP-16050 starts here
                    vinFitMap.set(element.Id, element.Is_VIN_Fitment__c);
                    productMarketingMap.set(element.Id, element.Product_Model_Marketing_Name__c);
                    //HDMP-16050 ends here
                });
                this._cartItemsClone.forEach((item) => {
                    let element = result.find((elem) => {
                        return item.cartItem.cartItemId == elem.Id
                    });
                    let obj = {};
                    obj = JSON.parse(JSON.stringify(item));
                    obj.op_cd = '';
                    obj.Product_Type__c = element.Product_Type__c;
                    //HDMP-16050 starts here
                    if (vinFitMap.has(obj.cartItem.cartItemId)) {
                        obj.cartItem.isVinFit = vinFitMap.get(obj.cartItem.cartItemId);
                    }
                    //HDMP-16050 ends here
                    if (cartitemIdAndNameMap.has(obj.cartItem.cartItemId)) {
                        obj.cartItem.name = cartitemIdAndNameMap.get(item.cartItem.cartItemId);
                    }
                    //added by Yashika for 8708: starts
                    if (cartItemIdAndProductModelMap.has(obj.cartItem.cartItemId)) {
                        obj.vehicle = cartItemIdAndProductModelMap.get(item.cartItem.cartItemId);
                    }
                    if (cartItemIdAndVinMap.has(obj.cartItem.cartItemId)) {
                        obj.vin = cartItemIdAndVinMap.get(item.cartItem.cartItemId);
                    } //ends: 8708
                    if (colorMap && colorMap.has(obj.cartItem.cartItemId)) {
                        obj.Color__c = colorMap.get(item.cartItem.cartItemId);
                    }
                    if (cartItemIdAndPickUpDealerMap.has(obj.cartItem.cartItemId)) {
                        obj.pickupDelear = cartItemIdAndPickUpDealerMap.get(item.cartItem.cartItemId);
                    }
                    //Added By Bhawesh 03-03-2022  for Bug No. 7929 start 
                    if (cartItemIdAndProductTypeMap.has(obj.cartItem.cartItemId)) {
                        if (cartItemIdAndProductTypeMap.get(item.cartItem.cartItemId) == 'Motocompacto') {
                            obj.productTypes = 'Product Number:';
                            obj.motocompactoDetail = productMarketingMap.get(item.cartItem.cartItemId);
                            obj.isMotocompacto = true;
                        } else {
                            obj.isMotocompacto = false;
                            obj.productTypes = cartItemIdAndProductTypeMap.get(item.cartItem.cartItemId) ? cartItemIdAndProductTypeMap.get(item.cartItem.cartItemId) + ' Number:' : '';

                            // If Condition added by ashwin for 19505
                            if (obj.productTypes.includes('Core Charge')) {
                                obj.productTypes = 'Part Number:';
                            }

                        }
                    }
                    //End

                    // Added by Bhawesh on 17-03-2022 start
                    if (cartIdAndOpCodeMap.has(obj.cartItem.cartItemId)) {
                        obj.op_cd = cartIdAndOpCodeMap.get(obj.cartItem.cartItemId);
                    }
                    // End
                    if (idAndDealerInstallLbl.has(obj.cartItem.cartItemId)) {
                        obj.dealerInstall = idAndDealerInstallLbl.get(obj.cartItem.cartItemId);
                    }

                    // LTIM REMAN 7813 , 7815
                    if (remanMap.has(obj.cartItem.cartItemId)) {
                        // alert('System Identifying the Reman Product');
                        obj.cartItem.isRemanCoreCharge = true;
                    }

                    // LTIM REMAN 7813 , 7815
                    if (remanMapCoreCharge.has(obj.cartItem.cartItemId)) {
                        // alert('System Identifying the Reman Product');
                        obj.cartItem.isRemanProduct = true;
                    }



                    cartItemsList.push(obj);
                })
                //ends here
                this.cartItems = cartItemsList.sort((a, b) => (a.cartItem.productDetails.sku > b.cartItem.productDetails.sku) ? 1 : -1)
                this.isLoading = false;

                /*SaiLakshman - HDMP-5409 - Starts*/
                this.dispatchEvent(
                    new CustomEvent(UPDATED_CART_ITEMS, {
                        detail: this.cartItems
                    })
                );
                /*SaiLakshman - HDMP-5409 - Ends*/
            })
            .catch((error) => {
            });

        //this.cartItemCount = Number(
        //result.cartSummary.totalProductCount
        // );
        //this.currencyCode = result.cartSummary.currencyIsoCode;
        this.isCartDisabled = LOCKED_CART_STATUSES.has(this.cartStatus);
        /* jhicks 8/24/21 - add color to cart items */
        // Start Added by Aditya for HDMP-18862

        let dealerDetails = getCurrentDealer(); // Added by ashwin  for 19451


        // this.isLoggedIn && dealerDetails.dealerNo added by ashwin for 19451
        if (this.unavailablecart && this.isLoggedIn && dealerDetails == undefined) {
            this.moveUnavailableCart(this.unavailablecart);
        }
        // End Added by Aditya for HDMP-18862
    }

    // Start Added by Aditya for HDMP-18862
    moveUnavailableCart(cartid) {
        moveUnavailableCartItemsToWishList({ cartId: cartid })
            .then((data) => {
                if (data) {
                    this.dispatchEvent(new ShowToastEvent({
                        message: 'The items previously saved in your shopping cart have been moved to My Wish List.',
                        variant: 'success'
                    }));
                    eval("$A.get('e.force:refreshView').fire();");
                }
            })
            .catch((error) => {
                console.log('Something went wrong', JSON.stringify(error));
            });
    }
    // End Added by Aditya for HDMP-18862


    /**
     * Handles a "click" event on the sort menu.
     *
     * @param {Event} event the click event
     * @private
     */
    handleChangeSortSelection(event) {
        this.sortParam = event.target.value;
        // After the sort order has changed, we get a refreshed list
        this.updateCartItems();
    }

    /**
     * Helper method to handle updates to cart contents by firing
     *  'cartchanged' - To update the cart badge
     *  'cartitemsupdated' - To notify any listeners for cart item updates (Eg. Cart Totals)
     *
     * As of the Winter 21 release, Lightning Message Service (LMS) is not available in B2B Commerce for Lightning.
     * These samples make use of the [pubsub module](https://github.com/developerforce/pubsub).
     * In the future, when LMS is supported in the B2B Commerce for Lightning, we will update these samples to make use of LMS.
     *
     * @fires CartContents#cartchanged
     * @fires CartContents#cartitemsupdated
     *
     * @private
     */
    handleCartUpdate() {
        // Update Cart Badge
        this.dispatchEvent(
            new CustomEvent(CART_CHANGED_EVT, {
                bubbles: true,
                composed: true,
                detail: this.cartItemCount
            })
        );
        // Notify any other listeners that the cart items have updated
        // fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
    }

    /**
     * Handler for the 'quantitychanged' event fired from cartItems component.
     *
     * @param {Event} evt
     *  A 'quanitychanged' event fire from the Cart Items component
     *
     * @private
     */
    handleQuantityChanged(evt) {
        const { cartItemId, quantity } = evt.detail;
        updateCartItem({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.cartid,
            cartItemId,
            cartItem: { quantity }
        })
            .then((cartItem) => {
                this.updateCartItemInformation(cartItem);
            })
            .catch((e) => {
                // Handle quantity update error properly
                // For this sample, we can just log the error
            });
    }

    /**
     * Handler for the 'singlecartitemdelete' event fired from cartItems component.
     *
     * @param {Event} evt
     *  A 'singlecartitemdelete' event fire from the Cart Items component
     *
     * @private
     */
    handleCartItemDelete(evt) {
        this.isLoading = true;
        const { cartItemId } = evt.detail;
        deleteCartItem({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.cartid,
            cartItemId: evt.detail
        })
            .then(() => {

                this.removeCartItem(cartItemId);


            })
            .catch((e) => {
                this.isLoading = false;
                // Handle cart item delete error properly
                // For this sample, we can just log the error
            });
        //this.removeCartItem(evt.detail);
    }

    /**
     * Handler for the 'click' event fired from 'Clear Cart' button
     * We want to delete the current cart, create a new one,
     * and navigate to the newly created cart.
     *
     * @private
     */
    handleClearCartButtonClicked() {
        // Step 1: Delete the current cart
        deleteCart({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.cartid
        })
            .then(() => {
                // Step 2: If the delete operation was successful,
                // set cartItems to undefined and update the cart header
                this.cartItems = undefined;
                this.cartItemCount = 0;
            })
            .then(() => {
                // Step 3: Create a new cart
                return createCart({
                    communityId,
                    effectiveAccountId: this.effectiveAccountId
                });
            })
            .then((result) => {
                // Step 4: If create cart was successful, navigate to the new cart
                this.navigateToCart(result.cartId);
                this.handleCartUpdate();
            })
            .catch((e) => {
                // Handle quantity any errors properly
                // For this sample, we can just log the error
            });
    }

    /**
     * Given a cart id, navigate to the record page
     *
     * @private
     * @param{string} cartId - The id of the cart we want to navigate to
     */
    navigateToCart(cartId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: cartId,
                objectApiName: 'WebCart',
                actionName: 'view'
            }
        });
    }

    /**
     * Given a cartItem id, remove it from the current list of cart items.
     *
     * @private
     * @param{string} cartItemId - The id of the cart we want to navigate to
     */
    removeCartItem(cartItemId) {

        const removedItem = (this.cartItems || []).filter(
            (item) => item.cartItem.cartItemId === cartItemId
        )[0];
        const quantityOfRemovedItem = removedItem
            ? removedItem.cartItem.quantity
            : 0;
        const updatedCartItems = (this.cartItems || []).filter(
            (item) => item.cartItem.cartItemId !== cartItemId
        );
        // Update the cartItems with the change
        this.cartItems = updatedCartItems;
        // Update the Cart Header with the new count
        this.cartItemCount -= Number(quantityOfRemovedItem);
        // Update the cart badge and notify any other components interested in this change
        this.handleCartUpdate();
    }

    /**
     * Given a cartItem id, remove it from the current list of cart items.
     *
     * @private
     * @param{CartItem} cartItem - An updated cart item
     */
    updateCartItemInformation(cartItem) {
        // Get the item to update the product quantity correctly.
        let count = 0;
        const updatedCartItems = (this.cartItems || []).map((item) => {
            // Make a copy of the cart item so that we can mutate it
            let updatedItem = { ...item };
            if (updatedItem.cartItem.cartItemId === cartItem.cartItemId) {
                updatedItem.cartItem = cartItem;
            }
            count += Number(updatedItem.cartItem.quantity);
            return updatedItem;
        });
        // Update the cartItems List with the change
        this.cartItems = updatedCartItems;
        // Update the Cart Header with the new count
        this.cartItemCount = count;
        // Update the cart badge and notify any components interested with this change
        this.handleCartUpdate();
    }
    continueShopping() {
        sessionStorage.setItem('continueShoppingVar', true);
        let lastShoppingUrl = sessionStorage.getItem('lastShoppingUrl');
        if (!lastShoppingUrl) {
            window.location.assign(window.location.origin);
            return;
        }
        let categoryLabel = '';
        let hasCategoryExist = false;
        let allBreadCrumbs = [];
        // multiple tab issue3 starts here
        allBreadCrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('vehicleBrand'));
        // multiple tab issue3 endss here
        if (allBreadCrumbs != null && allBreadCrumbs != undefined) {
            allBreadCrumbs.forEach(element => {
                if (element.name == 'category') {
                    categoryLabel = element.label;
                    hasCategoryExist = true;
                    lastShoppingUrl = lastShoppingUrl.split('?')[0] + '?type=' + element.name + '&label=' + element.label;
                }
                if (element.name == 'subcategory') {
                    lastShoppingUrl = lastShoppingUrl.split('?')[0] + '?type=' + element.name + '&categorylabel=' + categoryLabel + '&label=' + element.label;
                }
            });
        }
        if (lastShoppingUrl != undefined && lastShoppingUrl != null) {
            if (hasCategoryExist && lastShoppingUrl.indexOf("/s/category/") > -1) {
                window.location.href = lastShoppingUrl;
            }
            else {
                window.location.href = lastShoppingUrl.split('?')[0];
            }
        } else {
            let homeUrl = window.location.origin;
            window.location.href = homeUrl;
        }
    }

    //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
    notifyToCustomCart() {
        // you can also pass like this object info her --> const message = { message: { 'dealerLabel': dealerLabel, 'products': products } 
        const message = { message: 'Calling for update cartItem count' };
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL_FOR_CART, message);
    }
    //Ended

    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }

    handleGoToWishlist() {
        window.open(window.location.origin + '/s/my-wishlist', "_self");
    }
}
import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';

import communityId from '@salesforce/community/Id';
import getProduct from '@salesforce/apex/B2BGetInfo.getProduct';
import getCartSummary from '@salesforce/apex/B2BGetInfo.getCartSummary';
// import checkProductIsInStock from '@salesforce/apex/B2BGetInfo.checkProductIsInStock';
import addToCart from '@salesforce/apex/B2BGetInfo.addToCart';
import createAndAddToList from '@salesforce/apex/B2BGetInfo.createAndAddToList';
import getProductPrice from '@salesforce/apex/B2BGetInfo.getProductPrice';
import getProdDetails from '@salesforce/apex/B2BGetInfo.getProdDetails'; // added shalin soni
import getDealerInfo from '@salesforce/apex/B2BGetInfo.getDealerInfo'; // added by Faraz
import GetDealerPrice from '@salesforce/apex/B2B_INSystemIntegration.GetDealerPrice';
import { getCurrentDealerId, getCurrentDealer, getCurrentVehicle } from 'c/utils';
import { subscribe,unsubscribe, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { refreshApex } from '@salesforce/apex';


import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {resolve} from 'c/cmsResourceResolver';

/**
 * A detailed display of a product.
 * This outer component layer handles data retrieval and management, as well as projection for internal display components.
 */
export default class ProductDetails extends LightningElement {
    
    subscription = null;

    @track priceType = 'MSRP Price';

    @track vehicle = getCurrentVehicle();

    /**
     * Gets the effective account - if any - of the user viewing the product.
     *
     * @type {string}
     */
    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }

    cartcheck;
    
    @track productDetailJson;
    /**
     * Sets the effective account - if any - of the user viewing the product
     * and fetches updated cart information
     */
    set effectiveAccountId(newId) {
        this._effectiveAccountId = newId;
        //console.log('this._effectiveAccountId : ',this._effectiveAccountId);
        this.updateCartInformation();
    }

    /**
     * Gets or sets the unique identifier of a product.
     *
     * @type {string}
     */
    @api
    recordId;

    /**
     * Gets or sets the custom fields to display on the product
     * in a comma-separated list of field names
     *
     * @type {string}
     */
    @api
    customDisplayFields;

    /**
     * The cart summary information
     *
     * @type {ConnectApi.CartSummary}
     * @private
     */
    cartSummary;

    /**
     * The stock status of the product, i.e. whether it is "in stock."
     *
     * @type {Boolean}
     * @private
     
     @wire(checkProductIsInStock, {
         productId: '$recordId'
     })
     inStock;
     */

    /**
     * The full product information retrieved.
     *
     * @type {ConnectApi.ProductDetail}
     * @private
     */
    product;
    @wire(getProduct, {
        communityId: communityId,
        productId: '$recordId',
        effectiveAccountId: '$resolvedEffectiveAccountId'
    })
    wiredProduct({ data, error }) {
        if (data) {
            console.log('inside wiredproduct---' + data);
            this.product = data;
             this.hasProduct = true;
            try{
                this.getProductDetails();
                console.log('after  wiredproduct---' + this.showPartProduct);
            }catch(error){
                console.error(error.message);
            }
           
        }
        else if (error) {
            this.hasProduct = false;
            console.error('error from getProduct---' + JSON.stringify(error));
            console.error('error from getProduct---', error);
        }
    }
    /**
     * The price of the product for the user, if any.
     *
     * @type {ConnectApi.ProductPrice}
     * @private
     */
    @wire(getProductPrice, {
        communityId: communityId,
        productId: '$recordId',
        effectiveAccountId: '$resolvedEffectiveAccountId'
    })
    productPrice;
    showPartProduct = true;
    subCategoryImage;
    @track requiredQuinty = 1;
    @track productId; 
    @track breadcrumbsList = [];
    @track productNumber;
    @track showAddtoCartBtn = false;
    @track requiredProductList = [];
    @track selctedPartsValue;
    @track accessoriesValue;
    @track isPickupDealer;
    @track dealerEmailAddress;
    @track dealerPhoneNumber;
    @track dealerSelect;
    @track shoppingBrandPart;
    @track shoppingBrandAcc;

    @track allDetails = {
                id: '',
                categoryPath: '',
                description: ' ',
                image: '',
                name: '',
                price: '',
                sku: '',
                customFields: ''
            };
            

    // By using the MessageContext @wire adapter, unsubscribe will be called
    // implicitly during the component descruction lifecycle.
    @wire(MessageContext)
    messageContext;
    
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            HDMP_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }
    /**
    
     * The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
     */
    connectedCallback() {
        console.log('$IA: T resolvedEffectiveAccountId: ', this.resolvedEffectiveAccountId);
        console.log('$IA: T recordId: ', this.recordId);
        console.log('communityId' , communityId);
        try{
            
        
        // multiple tab issue3 starts here
        //this.selctedPartsValue = JSON.parse(this.getCookie('SelectedPart'));
        this.selctedPartsValue = JSON.parse(sessionStorage.getItem('SelectedPart'));
        // multiple tab issue3 ends here
       // console.log('$CI: PDC: getCookie: SelectedPart: ',this.getCookie('SelectedPart'));
        console.log('$CI: PDC: this.selctedPartsValue: ',this.selctedPartsValue ? JSON.parse(JSON.stringify(this.selctedPartsValue)) : this.selctedPartsValue);
        // added by Pradeep for HDMP-7916 SEO
        this.accessoriesValue = this.getCookie('selectedAccessorie');
        this.shoppingBrandAcc = this.accessoriesValue && this.accessoriesValue.shoppingBrand ? this.accessoriesValue.shoppingBrand : '';
        if(this.selctedPartsValue)
            console.log('$CI: PDC:  selctedPartsValue' , JSON.parse(JSON.stringify(this.selctedPartsValue)));
        if(this.accessoriesValue)
            console.log('$CI: PDC:  accessoriesValue' ,  JSON.parse(this.accessoriesValue));

        if(!this.selctedPartsValue && !this.accessoriesValue){
            window.location.assign(window.location.origin);
        }
        //ends here

        //console.log('##ProductTypeForCart',this.getCookie('ProductTypeForCart'));
        let productFromCart = this.getCookie('ProductFromCart');
            let productTypeFromCart = this.getCookie('ProductTypeForCart');
        // Added by Bhawesh on 28-01-2022 start
        /*if(this.selctedPartsValue == null){
            this.showPartProduct = true;
            return;
        }*/
        // end
        console.log('productFromCart: ',productFromCart);
        console.log('productTypeFromCart: ',productTypeFromCart);
            if (productFromCart && productFromCart === 'true') {
                this.showPartProduct = productTypeFromCart == 'Parts' ? true : false;
                
            } else {
            this.showPartProduct = sessionStorage.getItem('ProductType') == 'Parts' ? true : false;
                
        }

        //console.log('showPartProduct',this.showPartProduct)
       
        // multiple tab issue3 starts here
        // let selectedPart = JSON.parse(this.getCookie('SelectedPart'));
        let selectedPart = JSON.parse(sessionStorage.getItem('SelectedPart'));
        // multiple tab issue3 ends here

        //console.log('#@@this.selctedPartsValue ',this.selctedPartsValue);
        console.log('OUTPUT : selectedPart ',selectedPart);
        this.shoppingBrandPart = selectedPart && selectedPart.shoppingBrand ? selectedPart.shoppingBrand : '';
            this.requiredQuinty = selectedPart && selectedPart.QuantityRequired && selectedPart.QuantityRequired != null ? selectedPart.QuantityRequired : 1;
        this.requiredQuinty = parseInt(this.requiredQuinty, 10);
            if (Number.isNaN(this.requiredQuinty) || this.requiredQuinty == 0 || this.requiredQuinty == 999) {
            this.requiredQuinty = 'Contact Dealer';
        }

            this.showAddtoCartBtn = ((selectedPart) && (selectedPart.PartModificationCode == 'X' || selectedPart.PartModificationCode == 'W' || selectedPart.PartModificationCode == 'D' || selectedPart.PartControlCode == 'G')) ? false : true;
            console.log('showAddtoCartBtn : ', this.showAddtoCartBtn);
        this.productId = this.recordId;
        //console.log('this.productId',this.productId);

        // multiple tab issue3 starts here
        //var imageUrlGet = this.getCookie('SubCategoryImageURL');
        var imageUrlGet = sessionStorage.getItem('SubCategoryImageURL');
        // multiple tab issue3 ends here
        
        
        this.subCategoryImage = imageUrlGet && imageUrlGet != 'undefined' ? imageUrlGet.replace(/^"|"$/g, '') : '';
        //console.log('PDC',this.subCategoryImage);
     
            this.productNumber = this.getCookie('ProductNumber');
            //Added By Imtiyaz-START
            if(!this.productNumber){
                this.productNumber = this.selctedPartsValue && this.selctedPartsValue.IllustrationReferenceCode ? parseInt(this.selctedPartsValue.IllustrationReferenceCode) : this.productNumber;
            }
            //Added By Imtiyaz-END
            // multiple tab issue3 starts here 
            let breadcrumbsFromSession = sessionStorage.getItem('selectedBreadcrumbs');
            if (breadcrumbsFromSession && breadcrumbsFromSession.length > 0 && breadcrumbsFromSession != 'undefined') {
            this.breadcrumbsList = JSON.parse(breadcrumbsFromSession);
            // multiple tab issue3 ends here 
        }
        // let accessories = this.getCookie('RequiredProducts');
        let accessories = localStorage.getItem('RequiredProducts');
        this.requiredProductList = accessories && accessories != 'undefined' ? JSON.parse(accessories) : [];
       

        if (this.breadcrumbsList && this.breadcrumbsList[0] && this.breadcrumbsList[0].label) {
            if(sessionStorage.getItem('isMotoCompacto') != 'true'){
            sessionStorage.setItem('brand', this.breadcrumbsList[0].label);
            }
            console.log(' this.breadcrumbsList[0].label:: ',  JSON.stringify(this.breadcrumbsList));
            if (this.vehicle) {
            this.vehicle.iNDivisionID__c = this.breadcrumbsList[0].label == 'Honda' ? 1 : 2;
            }
        }

        this.updateCartInformation();
        this.subscribeToMessageChannel();   
        this.handleDealerEmailPhone();
    } catch (error) {
          console.error('Conncted Call Back',error.message);
    }
    }

    // Handler for message received by component
    handleMessage(data) {
        if (data.message.products) {
            if (this.allDetails) {
                if (getCurrentDealerId()) {
                    let partNumberList = [];
                    let accessoriesList = [];
                    let opcodeList = [];

                    //Added Shalini
                    let accessories = JSON.parse(sessionStorage.getItem('accessories'))
                    let selectedAccessories =  JSON.parse(this.getCookie('selectedAccessorie')); // Added by Bhawesh on 10-03-2022 for bug HDMP-8188

                    if (accessories && accessories.Accessory) {
                        accessories.Accessory.forEach(accessory => {
                            if (accessory.op_cd) {
                                if (!accessoriesList.includes(accessory.op_cd))
                                    accessoriesList.push(accessory.op_cd);
                            }
                        });
                    }
                    //End
                    //added by Pradeep for dealer pricing issues.
                    let isPart = this.getCookie('ProductTypeForCart') == 'Parts' ? true : sessionStorage.getItem('ProductType') == 'Parts' ? true : false ;

                    if (isPart && this.allDetails && this.allDetails.sku) {
                        partNumberList.push(this.allDetails.sku);
                    }
                    if (!isPart && selectedAccessories && selectedAccessories.op_cd) {
                        opcodeList.push(selectedAccessories.op_cd); 
                    }
                    //ends here
                    this.requiredProductList.forEach(rp => {
                        partNumberList.push(rp.partNumber);
                    });

                    let uniquePartNumberList = partNumberList.filter(function (item, index, inputArray) {
                        return inputArray.indexOf(item) == index;
                    });
                    this.fetchDealerPrice(uniquePartNumberList, opcodeList);

                } else {
                    //this.allDetails.price = alldetail[0].Price__c ;
                }
                this.handleDealerEmailPhone();
            }
        }
    }

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

    get accountId() {
        //console.log('check this.effectiveAccountId::' + this.effectiveAccountId + this.resolvedEffectiveAccountId);
        return this.effectiveAccountId;
    }
    //001g000002VHGPWAA5
    /**
     * Gets whether product information has been retrieved for display.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    hasProduct = true;

    fetchDealerPrice(partNumberList, accessoriesList) {
                let dealer = getCurrentDealer();
        if(partNumberList.length > 0 || accessoriesList.length > 0){
        GetDealerPrice(
            {
                dealerNo: dealer.dealerNo,
                divisionId: this.vehicle.iNDivisionID__c,
                partNumbers: JSON.stringify(partNumberList),
                accessories: JSON.stringify(accessoriesList)
            }
        ).then(result => {
            if (result) {
                        let dealerPriceResult = JSON.parse(result);
                        if(this.getCookie('ProductFromCart') && this.getCookie('ProductTypeForCart')){
                            if (this.getCookie('ProductTypeForCart') == 'Parts' && dealerPriceResult.Parts) {
                                dealerPriceResult.Parts.forEach(pdp => {
                                    if (pdp.PartNumber === this.product.fields.StockKeepingUnit) {
                                        this.allDetails.price = pdp.DIYPrice; //pdp.DealerPrice ;
                                    }
                                });
                            }
                        
                            // Added by Bhawesh on 12-03-2022 for bug HDMP-8354 start
                            else if (this.getCookie('ProductTypeForCart') == 'Accessorie' && dealerPriceResult.Accessories) {
                                let selectedAcc = JSON.parse(this.getCookie('selectedAccessorie'));
                                dealerPriceResult.Accessories.forEach(pdp => {
                                    if (selectedAcc && selectedAcc.op_cd && pdp.OpCode === selectedAcc.op_cd) {
                                        this.allDetails.price = pdp.DIYPrice; //pdp.DealerPrice ;
                                    }
                                });
                            }
                            // End
                        }
                else {
                    if (dealerPriceResult.Parts && dealerPriceResult.Parts.length > 0) {
                                dealerPriceResult.Parts.forEach(pdp => {
                                    if (pdp.PartNumber === this.product.fields.StockKeepingUnit) {
                                            this.allDetails.price = pdp.DIYPrice; //pdp.DealerPrice ;
                                    }
                                });
                            }
                            // Added by Bhawesh on 12-03-2022 for bug HDMP-8354 start
                    else if (dealerPriceResult.Accessories) {
                        let selectedAcc = JSON.parse(this.getCookie('selectedAccessorie'));
                                dealerPriceResult.Accessories.forEach(pdp => {
                                    if (selectedAcc && selectedAcc.op_cd && pdp.OpCode === selectedAcc.op_cd) {
                                        this.allDetails.price = pdp.DIYPrice; //pdp.DealerPrice ;
                                    }
                                });
                            }
                            // End
                        }
                this.priceType = 'Dealer Price';
                                    }
        }).catch(error => {
            console.log('Error :1 ', error);
                                });
                            }
    }
    getProductDetails() {
        if (getCurrentDealerId()) {
            let partNumberList = [];
            let accessoriesList = [];
            try {
                //Added Shalini
                let accessories = JSON.parse(sessionStorage.getItem('accessories'))

                if (accessories && accessories.Accessory) {
                    accessories.Accessory.forEach(accessory => {
                        if (accessory.op_cd) {
                            if (!accessoriesList.includes(accessory.op_cd))
                                accessoriesList.push(accessory.op_cd);
                        }
                });
                }
            } catch (error) {
                console.error('Err', error.message);
            }
            //End
            // added by Pradeep for dealer pricing issues.
            let productTypeFromCart = this.getCookie('ProductTypeForCart');
            // updated by Pradeep for dealer pricing issues.
            if (productTypeFromCart == 'Parts' || this.vehicle.productType == 'Parts'){ //|| this.vehicle.productType == 'Accessories') {
                //ends here
                partNumberList.push(this.product.fields.StockKeepingUnit);
      }
            this.fetchDealerPrice(partNumberList, accessoriesList);
        } else {
            if (this.product.fields.Price__c) {
                //this.allDetails.price = alldetail[0].Price__c ;
            }
        }
        this.allDetails.id = this.recordId;
        this.allDetails.name = this.product.fields.Name;
        this.allDetails.sku = this.product.fields.StockKeepingUnit;
        this.allDetails.description = this.product.fields.Description;
        console.log('@@@this.isPickupDealer', this.product.fields.PickupatDealer__c );
        this.isPickupDealer = this.product.fields.PickupatDealer__c == 'true' ? true : false; //Added by Shalini soni 18 Jan 2022 for HDMP-6843
        console.log('@@this.isPickupDealer', this.isPickupDealer);
    }

    handleDealerEmailPhone() {
        if (getCurrentDealerId() && getCurrentDealer()) {
            let dealer = getCurrentDealer();
            this.dealerSelect = true;
            getDealerInfo({ dealerName: dealer.label, poiId: dealer.dealerNo })
                .then(result => {
                    if (result) {
                        result = JSON.parse(result);
                        if (result[0].Email__c) this.dealerEmailAddress = result[0].Email__c;
                        else this.dealerEmailAddress = '';

                        if (result[0].Phone) this.dealerPhoneNumber = result[0].Phone;
                        else this.dealerPhoneNumber = '';
                    }
                })
                .catch(error => {
                    //console.log('error : ',error);
                }
            );
        }
    }

    get displayableProduct() {
        //console.log('this.allDetails'+JSON.stringify(this.allDetails))
        return this.allDetails;
    }
  //------------  END Added by shalini soni 
    /**
     * Gets whether the cart is currently locked
     *
     * Returns true if the cart status is set to either processing or checkout (the two locked states)
     *
     * @readonly
     */
    get _isCartLocked() {
        const cartStatus = (this.cartSummary || {}).status;
        return cartStatus === 'Processing' || cartStatus === 'Checkout';
    }

    /**
     * Handles a user request to add the product to their active cart.
     * On success, a success toast is shown to let the user know the product was added to their cart
     * If there is an error, an error toast is shown with a message explaining that the product could not be added to the cart
     *
     * Toast documentation: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_toast
     *
     * @private
     */

    addToCart(event) {
        //console.log('inside block');
        //console.log('product detail custom quantity' + event.detail.quantity);
        addToCart({
                communityId: communityId,
                productId: this.recordId,
                quantity: event.detail.quantity,
                effectiveAccountId: this.resolvedEffectiveAccountId
            })
            .then((result) => {
                //console.log('inside try result ' + result);
                this.dispatchEvent(
                    new CustomEvent('cartchanged', {
                        bubbles: true,
                        composed: true
                    })
                );
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Your cart has been updated.',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            })
            .catch((e) => {
                //console.log('inside catch block of product detail custom' + JSON.stringify(e));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: '{0} could not be added to your cart at this time. Please try again later.',
                        messageData: [this.displayableProduct.name],
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            });
    }

    /**
     * Ensures cart information is up to date
     */
    updateCartInformation() {
        if(this.resolvedEffectiveAccountId){
            getCartSummary({
                communityId: communityId,
                effectiveAccountId: this.resolvedEffectiveAccountId
            })
            .then((result) => {
                this.cartSummary = result;
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                //console.log(e);
            });
        }
    }

    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }
    createCookie(name, value, days) {
        //console.log('calling creating cookie');
        var expires;
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 100));
            expires = ";expires=" + date.toGMTString();
        } else {
            expires = "";
        }
        //console.log('setting cookie');
        //updated by Pradeep Singh for Optive Issue
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
        // ends here
    }

    renderedCallback(){
        if(this.product != null && this.product != undefined && this.product.fields && this.product.fields.Part__c){
            if(this.showPartProduct && this.selctedPartsValue && this.selctedPartsValue.PartNumber){
                if(this.selctedPartsValue.PartNumber != this.product.fields.Part__c){
                    window.location.assign(window.location.origin);
                }
            }
            if(!this.showPartProduct && this.accessoriesValue){
                let accessoriesValue = JSON.parse(this.accessoriesValue);
                if(accessoriesValue.partNumber && accessoriesValue.partNumber != this.product.fields.Part__c){
                    window.location.assign(window.location.origin);
                }
            }
        }
    }
}
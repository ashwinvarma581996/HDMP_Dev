import { api, LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import communityId from '@salesforce/community/Id';
import getCartSummary from '@salesforce/apex/B2BCartControllerSample.getCartSummary';

import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/cartUtils';
import { unsubscribe,subscribe, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { getCurrentDealerId } from 'c/utils';
import { getCurrentDealer } from 'c/utils';
import getBrand from '@salesforce/apex/B2B_VehicleSelectorController.getBrand';
import getCartItemCategory from '@salesforce/apex/B2B_VehicleSelectorController.getCartItemCategory';


const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

const DELAY = 300; //AA: original value was 3000

export default class CartSummary extends LightningElement {
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
     * The pricing information for the cart summary's total.
     *
     * @typedef {Object} Prices
     *
     * @property {String} [originalPrice]
     *  The  list price aka "strikethrough" price (i.e. MSRP) of the cart.
     *  If the value is null, undefined, or empty, the list price will not be displayed.
     *
     * @property {String} finalPrice
     *   The final price of the cart.
     */

    /**
     * The recordId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    recordId;

    /**
     * The effectiveAccountId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    effectiveAccountId;

    subscription = null;

    @api isDealerSelected = getCurrentDealerId() ? true : false; 

   // @track isDealerSelected;
    
    // By using the MessageContext @wire adapter, unsubscribe will be called
    // implicitly during the component descruction lifecycle.
    @wire(MessageContext)
    messageContext;
    @track summaryvalue;

    @api
    cartid;
    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    @wire(CurrentPageReference)
    pageRef;

    @track showDealerPop = false;
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

    /**
     * This lifecycle hook fires when this component is inserted into the DOM.
     * We want to start listening for the 'cartitemsupdated'
     *
     * NOTE:
     * In future, if LMS channels are supported on communities, the LMS should be the preferred solution over pub-sub implementation of this example.
     * For more details, please see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel_considerations
     */
    connectedCallback() {

        this.subscribeToMessageChannel();
        //this.findCartItems();
       
        /*registerListener(
            CART_ITEMS_UPDATED_EVT,
            this.getUpdatedCartSummary,
            this
        );*/
       // this.getUpdatedCartSummary();
        // Initialize 'cartsummary' as soon as the component is inserted in the DOM  by
        // calling getCartSummary imperatively.
        //AA: this was adding a delay to the page
        /*setTimeout(() => {
            this.getUpdatedCartSummary();
        }, 1000);*/
        this.getBrandDetails();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }


    findCartItems()
    {
        getCartItemCategory({ communityId:communityId
        }).then((result) => {
            if(result && result.catName){
                let categoryname=result.catName;
                if(categoryname && categoryname !='dual')
                {
          
                        let currentBrand=localStorage.getItem('CartBrand');
                        if(currentBrand)
                        {
                            this.isDealerSelected=true;
                        }
                        else
                        {
                            this.isDealerSelected=false;
                           
                        }

        }
        else
        {
            let dualBrand=localStorage.getItem('DualBrand');
            if(dualBrand)
            {
                this.isDealerSelected=true;
         
            }
            else
            {
            this.isDealerSelected=false;
        }
        }
    }
    })
    .catch((error) => {
        //console.log('error::::' + JSON.stringify(error));
    }); 
}
    
    

    // Handler for message received by component
    handleMessage(data) {
        if (data.message.products) {
            this.handleUpdateCartSummary();
            this.isDealerSelected = true;
        }
        if (data.message.updatesoncart) {
            this.handleUpdateCartSummary();
        }
    }

    handleUpdateCartSummary(){
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.getUpdatedCartSummary();
        }, DELAY);
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
            cartSummaryHeader: 'Cart Total',
            total: 'Sub Total'
        };
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

    /**
     * The pricing information to be displayed in the summary
     * @type {Prices}
     */
    get prices() {
      //  this.summaryvalue=this.cartSummary.totalProductAmount;
        return {
            originalPrice: this.cartSummary && this.cartSummary.totalListPrice,
            finalPrice: this.cartSummary && this.cartSummary.totalProductAmount
        };
    }
    // summaryvalue(event)
    // {
    //     this.dispatchEvent(new CustomEvent('summaryvalue', { detail:   this.summaryvalue }));
	
    // }
    /**
     * The ISO 4217 currency code for the cart page
     *
     * @type {String}
     */
    get currencyCode() {
        return (this.cartSummary && this.cartSummary.currencyIsoCode) || 'USD';
    }

    /**
     * Representation for Cart Summary
     *
     * @type {object}
     * @readonly
     * @private
     */
    cartSummary;

    /**
     * Get cart summary from the server via imperative apex call
     */
    getUpdatedCartSummary() {
       
        
        getCartSummary({
            communityId: communityId,
            activeCartOrId: this.cartid,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((cartSummary) => {
                this.cartSummary = cartSummary;
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                //console.log(e);
            });
    }

    /**
     * Should the original price be shown
     * @returns {boolean} true, if we want to show the original (strikethrough) price
     * @private
     */
    get showOriginal() {
        return displayOriginalPrice(
            true,
            true,
            this.prices.finalPrice,
            this.prices.originalPrice
        );
    }

    /**
     * Gets the dynamically generated aria label for the original price element
     * @returns {string} aria label for original price
     * @private
     */
    get ariaLabelForOriginalPrice() {
        return getLabelForOriginalPrice(
            this.currencyCode,
            this.prices.originalPrice
        );
    }
    //Added by shalini for HDMP-8290
    async getBrandDetails() {
        let storedCartId = localStorage.getItem('cartId');
        if (storedCartId) {
            await getBrand({
                cartId: storedCartId
            }).then(result => {
                if (result) {
                    let brand = result;
                    localStorage.setItem('cartBrand', brand);
                    if(!this.isDealerSelected && localStorage.getItem('effectiveDealer')){
                        JSON.parse(localStorage.getItem('effectiveDealer'))['brands'].forEach(element => {
                            if(brand === element.brand){
                                this.isDealerSelected=true;
                            }
                        });
                    }
                }
            }).catch(error => {
                
            })
            .finally( () =>{
                this.showDealerPop = true;
            })
        }
    }
}
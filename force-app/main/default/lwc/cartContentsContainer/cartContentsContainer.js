/*******************************************************************************
Name: CartContentsContainer
Business Unit: 
Created Date: 
Developer: 
Description: LWC is created to handle UI for Shopping cart page only
*******************************************************************************

MODIFICATIONS – Date | Dev Name     | Method                           | User Story
                     | Faraz Ansari | getDealerInstallationData-create | HDMP-5428
                     | Faraz Ansari | getDealerInstallationData-modify | HDMP-5326
*******************************************************************************/

import { api, LightningElement, track, wire } from 'lwc';
import communityId from '@salesforce/community/Id';
import { getCurrentDealerId, getCurrentVehicle, getCurrentDealer } from 'c/utils';
import gettotalamount from '@salesforce/apex/CartItemsCtrl.gettotalamount';
import changeStatusWithDeliveryMethod from '@salesforce/apex/CartItemsCtrl.changeStatusWithDeliveryMethod';
import gettotalquantity from '@salesforce/apex/CartItemsCtrl.gettotalquantity';
import getCartItems from '@salesforce/apex/B2BCartControllerSample.getCartItems';
import getProductPrice from '@salesforce/apex/B2BCartControllerSample.getProductPrice'; // Added by ashwin for wishlist
import isUserLoggedIn from '@salesforce/apex/B2BCartControllerSample.isUserLoggedIn'; // Added by ashwin for wishlist
import getCartItemsSku from '@salesforce/apex/B2BCartControllerSample.getCartItemsSku';
import addDealerInstallationPrice from '@salesforce/apex/B2BCartControllerSample.addDealerInstallationPrice';
import GetDealerPrice from '@salesforce/apex/B2B_INSystemIntegration.GetDealerPrice';
import getCartItemsData from '@salesforce/apex/CartItemsCtrl.getCartItemList2';//Added by Faraz on 01/08/2022 for HDMP-11659
import { unsubscribe, subscribe, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import DealerNote from '@salesforce/label/c.Dealer_Note';
import ErrorMessageText from '@salesforce/label/c.ErrorMessageText'; //Added by shalini soni HDMP-5428 R2 Story
import ErrorMessageInnerText from '@salesforce/label/c.ErrorMessageInnerText'; //Added by shalini soni HDMP-5428 R2 Story
//import getExternalIpServerCall from '@salesforce/apex/LWC_Utils.getExternalIp';//Added By Pradeep for cart management - R2C story
//Added by deepak mali 1 March 2022
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import isguest from '@salesforce/user/isGuest'
import { getRecord } from 'lightning/uiRecordApi';
import getLoginUrl from '@salesforce/label/c.Identity_Provider_Login_URL';
import getRegisterUrl from '@salesforce/label/c.Identity_Provider_Register_URL';
import getCurrentCart from '@salesforce/apex/B2B_HandleCartAndUser.getCurrentCart';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//END

import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';//for adobe
import { publish } from 'lightning/messageService';//for adobe

const INSTALL_AT_DEALER = 'Install At Dealer';
const PICK_UP_AT_DEALER = 'Pick Up At Dealer';
const SHIP_TO_ME = 'Ship to Me';
const SUCCESS = 'success'; //Added by shalini soni HDMP-5428 R2 Story
const ACCESSORY = 'Accessory';
const ACCESSORIES = 'accessories';
const ACCESSORIES_HONDA = 'accessoriesHonda';
const ACCESSORIES_ACURA = 'accessoriesAcura';
const NULL = 'null';
export default class CartContentsContainer extends LightningElement {
    label = { //Added by shalini soni HDMP-5428 R2 Story
        ErrorMessageText,
        ErrorMessageInnerText,
        DealerNote
    };
    @api cartId;
    @api prodquantity;
    @api accountId;
    @track cartItemsLength;
    @track cartItems;
    @track udpatedCartItems
    @track subTotal;
    @track cartCount;
    @track totalDealerInstallationPrice;
    @track displayCartEmpty = false;
    @track buttonDisabled = getCurrentDealerId() ? false : true;
    @track isDealerSelected; // Added by shalini for HDMP-6796 12/1/2021
    @track dealerReturnPolicy;//Added by Faraz on 01/08/2022 for HDMP-11659
    @track shippingTypeDealer = false;
    @track shippingDealerNote;
    //Added by deepak mali 1 March 2022
    @track showModalBox = false;
    @track isGuest = isguest;
    recursion = true;
    //END



    cartStatus;
    currencyCode;
    selectedOrderType = '';
    subscription = null;
    dealerInstallation = false;
    showDearlerInstallation = false;

    @api
    savePayload(payload) {
        console.log('payload : ', payload);
        sessionStorage.setItem('payload', payload);
    }

    connectedCallback() {

        //alert('here')



        getCartItemsData({
            cartId: this.cartId
        })
            .then((result) => {
                this.cartStatus = result[0].Cart.Status;





                if (this.cartStatus == 'Closed') {
                    window.location.replace(window.location.origin);
                }
            })
            .catch((error) => {

            });

        this.buttonDisabled = getCurrentDealerId() ? false : true;
        this.getCartCount(null);
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    //Added by deepak mali 1 March 2022
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuserdata({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            console.log('ODATA : ', data);
            let userFirstName = data.fields.Name.value;
            if (USER_ID == undefined || USER_ID == null || userFirstName.includes('Guest')) {
                this.isGuest = true
            } else {
                this.isGuest = false;
            }
        }
    }
    //END

    // By using the MessageContext @wire adapter, unsubscribe will be called
    // implicitly during the component descruction lifecycle.
    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            HDMP_MESSAGE_CHANNEL,
            (message) => {
                if (message && message.message && message.message.eventType) {
                    console.log('not subscribing ')
                }
                else {
                    this.getCartCount(message)
                }
            }
        );
        console.log('subscribeToMessageChannel : ');
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(data) {
        if (data.message.products) {
            this.buttonDisabled = false;
        }
    }

    async getCartCount(message) {
        await gettotalamount({ cartId: this.cartId })
            .then(result => {
                if (result != null && parseFloat(result) > 0.00) {
                    this.subTotal = (parseFloat(result)).toFixed(2);
                } else if (parseFloat(result) <= 0.00) {
                    this.buttonDisabled = true;
                    this.subTotal = 0.00;
                    if (this.buttonDisabled && this.dealerInstallation) {
                        this.dealerInstallation = false;
                        this.totalDealerInstallationPrice = 0;
                    }
                }
            })
            .catch(error => {
                //console.error(error);
            });

        await gettotalquantity({ cartId: this.cartId })
            .then(result => {
                if (result != null) {
                    this.prodquantity = result;
                    this.cartItemsLength = 'Item subtotal (' + this.prodquantity;
                    this.cartItemsLength += this.prodquantity > 1 ? ' Items)' : ' Item)';
                }
            })
            .catch(error => {
                //console.error(error);
            });

        await getCartItems({
            communityId: communityId,
            effectiveAccountId: null,
            activeCartOrId: this.cartId,
            pageParam: null,
            sortParam: 'CreatedDateDesc'
        })
            .then((result) => {
                this.cartItems = result.cartItems;


                this.handleMoveTowishlist(); // New Method added by ashwin


                this.showDearlerInstallation = this.cartItems && this.cartItems.length > 0 ? true : false;
                try {
                    if (this.template.querySelector('c-cart-dealer-installation')) {
                        this.template.querySelector('c-cart-dealer-installation').updateCartItemsInfo(); //Added by shalini soni HDMP-5428 R2 Story
                    }
                    if (getCurrentDealerId() && result.cartItems) {
                        this.getDealerInstallationData();
                        result.cartItems.forEach(cartItems => {
                            if (cartItems && cartItems.cartItem && cartItems.cartItem.totalPrice && parseFloat(cartItems.cartItem.totalPrice).toFixed(2) <= 0.00) {
                                this.buttonDisabled = true;
                            } else {
                                this.buttonDisabled = false;
                            }
                        });
                    } else {
                        this.buttonDisabled = true;
                    }
                    this.cartCount = Number(result.cartSummary.totalProductCount);
                    this.currencyCode = result.cartSummary.currencyIsoCode;
                    this.cartStatus = result.cartSummary.status;
                    if (this.cartCount > 0 && message != null) {
                        this.handleMessage(message);
                    } else if (this.cartCount == 0 || this.cartCount === 0 || this.cartCount == null) {
                        this.buttonDisabled = true;
                    }
                } catch (error) {
                    //console.log('OUTPUTErrorq : ',error);
                }

                console.log('dispatch event for paypal : ');
                const selectedEvent = new CustomEvent('cartdetailschange', { detail: { dealerId: getCurrentDealerId(), buttonDisabled: this.buttonDisabled } });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            })
            .catch((error) => {
                //console.log('error in cartContentsContainer' + JSON.stringify(error));
                this.displayCartEmpty = true;
            });


        //Added by Faraz on 01/08/2022 for HDMP-11659
        getCartItemsData({ cartId: this.cartId })
            .then(result => {
                if (result) {
                    if (result[0] && result[0].Cart && result[0].Cart.DealerId__r && result[0].Cart.DealerId__r.Return_Policy__c) {
                        this.dealerReturnPolicy = result[0].Cart.DealerId__r.Return_Policy__c;
                    } else {
                        this.dealerReturnPolicy = 'Returns and Exchange policies are at the dealer’s discretion, please contact your dealer for more details';
                    }
                }
            })
            .catch(error => {
                console.error('Error : ', error);
            });
        //End 11659

        this.isDealerSelected = getCurrentDealerId() ? true : false;// Added by shalini for HDMP-6796 12/1/2021


    }

    handleCheckOut() {
        //for adobe analytic: starts
        if (this.isGuest == false) { //for adobe bug: 25
            let events = 'scCheckout';
            let eventMetadata = {
                action_type: 'button',
                action_label: 'proceed to checkout',
                action_category: 'cart'
            };
            const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events } };
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        }
        //adobe: ends
        //R2C - commented for login
        if (this.isGuest && this.isGuest == true) {
            if (this.showModalBox == false) {
                //for adobe analytic: starts

                let events = 'scCheckout';
                let eventMetadata = {
                    action_type: 'button',
                    action_label: 'proceed to checkout',
                    action_category: 'cart'
                };
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events } };
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);

                //adobe: ends
                this.showModalBox = true;
                return;
            }
        }
        if (this.cartId) {
            // Added by Bhawesh for HDMP-8429
            let selectedBrand = localStorage.getItem('cartBrand') == 'Acura' ? '2' : '1';
            changeStatusWithDeliveryMethod({ cartId: this.cartId, selectedBrand: selectedBrand })
                .then(result => {
                    if (result && result == SUCCESS) {
                        this.navigateToCheckOut();
                    } else {
                        this.navigateToCheckOut();
                    }
                })
                .catch(error => {
                    //console.error('Error while changing status', error);
                });
        }
    }

    closeModaBox() {
        this.showModalBox = false;
    }

    redirectToLoginPage() {
        getCurrentCart()
            .then((result) => {
                let pathURL;
                if (result !== null && result !== '') {
                    pathURL = '/s/splash?cartId=' + result + '&returnUrl=' + window.location.pathname;
                } else {
                    pathURL = '/s/splash?returnUrl=' + window.location.pathname;
                }
                const finalURL = getLoginUrl + '&RelayState=' + encodeURIComponent(pathURL);
                window.open(finalURL, '_self');
            })
            .catch((error) => {
                //console.error('Error:', error);
            });
    }
    // Ends Here

    // Added by Soumya for Cart Management- Register
    redirectToRegisterPage() {
        getCurrentCart()
            .then((result) => {
                let pathURL;
                if (result !== null && result !== '') {
                    pathURL = '/s/splash?cartId=' + result + '&returnUrl=' + window.location.pathname;
                } else {
                    pathURL = '/s/splash?returnUrl=' + window.location.pathname;
                }
                const finalURL = getRegisterUrl + '&RelayState=' + encodeURIComponent(pathURL);
                window.open(finalURL, '_self');
            })
            .catch((error) => {
                //console.error('Error:', error);
            });
    }
    // Ends here

    /* R2C story - Commented by Soumya - Cart Management.
    redirectToLoginPage() {
        // Updated by Pradeep for Cart Management
        getExternalIpServerCall({ currentGuestCartId: this.cartId })
        .then((result) => {
            let pathURL;
            if(window.location.pathname.includes('/cart/')){
                pathURL = '/s/validate-user?cartId='+this.cartId;
            }else{
                pathURL = window.location.pathname;
            }
            const finalURL = getLoginUrl + '&RelayState=' + pathURL;
            window.open(finalURL, '_self');
        })
        .catch((error) => {
            //console.error('Error:', error);
        });
        //ends here
    } 
    Ends here */

    navigateToCheckOut() {
        window.location = '/s/checkout/' + this.cartId;
    }

    handleVaidation(event) {
        if (getCurrentDealerId()) {
            let qtyValue = event.detail;
            //Added toString() method by Shalini Soni for HDMP-9824 2 June 2022
            if (qtyValue.toString().includes('.')) {
                this.buttonDisabled = true;
            } else {
                if (qtyValue <= 50 && qtyValue >= 1) {
                    this.buttonDisabled = false
                } else {
                    this.buttonDisabled = true;
                }
            }
        }
    }

    handleCartCount(event) {
        console.log('inside handleCartCount');
        this.getCartCount(null);
        if (getCurrentDealerId()) {
            let cartValue = event.detail;
            this.buttonDisabled = (cartValue == 0) ? true : false;
        }
    }

    /*SaiLakshman - HDMP-5409 - Starts */
    handleUpdatedCartItems(event) {
        this.udpatedCartItems = event.detail;
        try {
            if (this.template.querySelector('c-cart-shipping-summary')) {
                this.template.querySelector('c-cart-shipping-summary').hideEstimatedCartBox();
            }
        } catch (error) { }
    }
    /*SaiLakshman - HDMP-5409 - Ends */

    //Added by Faraz for HDMP-5428 Start here R2 Story 
    getDealerInstallationData() {
        if (getCurrentDealerId() && this.selectedOrderType && this.selectedOrderType == INSTALL_AT_DEALER) {
            this.buttonDisabled = true;
            let cartElementList = [];
            let cartItems = JSON.parse(JSON.stringify(this.cartItems));
            let skuList = [];
            if (cartItems) {
                cartItems.forEach(cartElement => {
                    if (cartElement.cartItem.cartItemId) {
                        if (!cartElementList.includes(cartElement.cartItem.cartItemId)) {
                            cartElementList.push(cartElement.cartItem.cartItemId);
                        }
                    }
                });
                if (cartElementList && cartElementList.length) {
                    getCartItemsSku({ cartItemIds: cartElementList })
                        .then(result => {
                            if (result) {
                                skuList = JSON.parse(result);
                                let accessoriesList = [];
                                let dealer = getCurrentDealer();
                                let vehicle;
                                if (skuList[0] && skuList[0].Product2.Division__c == 'A') {
                                    vehicle = 1;
                                } else if (skuList[0] && skuList[0].Product2.Division__c == 'B') {
                                    vehicle = 2;
                                } else if (skuList[0] && skuList[0].Product_Subdivision__c) {
                                    vehicle = skuList[0].Product_Subdivision__c.toLowerCase() == 'honda' ? 1 : skuList[0].Product_Subdivision__c.toLowerCase() == 'acura' ? 2 : 0;
                                }
                                skuList.forEach(element => {
                                    if (!this.dealerInstallation) {
                                        this.dealerInstallation = element.Product_Type__c == ACCESSORY ? true : false;
                                    }
                                    if (element.Product_Type__c && element.Product_Type__c == ACCESSORY && !accessoriesList.includes(element.op_code__c)) {
                                        accessoriesList.push(element.op_code__c);
                                    }
                                });
                                if (this.dealerInstallation && accessoriesList && accessoriesList.length && vehicle) {
                                    this.totalDealerInstallationPrice = 0;
                                    if (accessoriesList.length > 0) {
                                        GetDealerPrice({
                                            dealerNo: dealer.dealerNo,
                                            divisionId: vehicle,
                                            accessories: JSON.stringify(accessoriesList)
                                        }).then(result => {
                                            if (result) {
                                                let data = JSON.parse(result);
                                                if (data && !data.isError) {
                                                    let isPriceNull = false;
                                                    skuList.forEach(element => {
                                                        let selectedAcc = data.Accessories.filter(item => item.OpCode == element.op_code__c);
                                                        if (selectedAcc && selectedAcc.length) {
                                                            element.Dealer_Installation_Price__c = selectedAcc[0].InstallationCharges ? selectedAcc[0].InstallationCharges : 0;
                                                            if (element.Dealer_Installation_Price__c == 0) {
                                                                isPriceNull = true;
                                                            }
                                                        }
                                                    });
                                                    addDealerInstallationPrice({ cartItems: skuList })
                                                        .then(result => {
                                                            if (result) {
                                                                let data = JSON.parse(result);
                                                                this.totalDealerInstallationPrice = data[0].Cart.Total_Installation_Charge__c ? data[0].Cart.Total_Installation_Charge__c : '0';
                                                                //Added by Faraz for HDMP-5326
                                                                if (isPriceNull) {
                                                                    this.template.querySelector('c-cart-dealer-installation').handleIssueForDealerInstall('price');
                                                                    this.dealerInstallation = false;
                                                                    this.totalDealerInstallationPrice = '0';
                                                                } else if (!isPriceNull) {
                                                                    this.buttonDisabled = false;
                                                                    this.template.querySelector('c-cart-dealer-installation').handleIssueForDealerInstall('success');
                                                                }
                                                                //End HDMP-5326
                                                            }
                                                        })
                                                        .catch(error => {
                                                            //console.error('Error:', error);
                                                        });
                                                } else if (data && data.isError) {
                                                    this.dealerInstallation = false;
                                                    this.totalDealerInstallationPrice = 0;
                                                    this.template.querySelector('c-cart-dealer-installation').handleIssueForDealerInstall('API');//Added by Faraz for HDMP-5326
                                                }
                                            }
                                        })
                                            .catch(error => {
                                                //console.error('Error:', error);
                                            });
                                    }
                                } else if (!accessoriesList.length) {
                                    this.dealerInstallation = false;
                                    this.totalDealerInstallationPrice = 0;
                                }
                            }
                        })
                        .catch(error => {
                            //console.error('Error:', error);
                        });
                }
            }
        } else if (!this.selectedOrderType.length || this.selectedOrderType != INSTALL_AT_DEALER) {
            this.dealerInstallation = false;
            this.totalDealerInstallationPrice = 0;
            this.buttonDisabled = getCurrentDealerId() && this.cartItems.length ? false : true;
        }
    }
    //End here -By Faraz HDMP-5428 R2 Story

    estimatedPriceChanged(event) {
        console.log('estimatedPriceChanged : ', event.detail);
        const selectedEvent = new CustomEvent('totalpricechange', { detail: { totalPrice: event.detail.totalPrice, buttonDisabled: this.buttonDisabled } });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    //Added by shalini soni for type and  json for Delivery Type HDMP-5428 R2 Story
    hanldeDealerInstalltionChange(event) {
        this.selectedOrderType = event.detail.orderType;
        this.getDealerInstallationData();
        let timeout = 0;
        if (getCurrentDealerId()) {
            timeout = 1000;
        }
        setTimeout(() => {
            this.template.querySelector('c-cart-shipping-summary').onDelarInstallation(event.detail.jsonString);//SaiLakshman - HDMP-5409
            const selectedEvent = new CustomEvent('ordertypechange', { detail: { orderType: this.selectedOrderType, buttonDisabled: this.buttonDisabled } });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            if (this.subTotal > 0.00 && (this.selectedOrderType == PICK_UP_AT_DEALER || this.selectedOrderType == INSTALL_AT_DEALER)) {
                this.shippingTypeDealer = true;
                this.shippingDealerNote = this.selectedOrderType == PICK_UP_AT_DEALER ? ' estimated tax and estimated subtotal.' : ' installation charges and estimated tax.';
            } else if (this.selectedOrderType == SHIP_TO_ME || this.subTotal <= 0.00) {
                this.shippingTypeDealer = false;
            }
        }, timeout);
    }



    handleMoveTowishlist(event) {


        // isUserLoggedIn().then(isLoggedIn => {

        //     if (isLoggedIn && getCurrentDealerId()) {

        //         //alert('here')

        //         let cartItemMap = {}

        //         this.cartItems.map((itm) => {
        //             cartItemMap[itm.cartItem.cartItemId] = itm.cartItem.productId;
        //         })


        //         getProductPrice({
        //             cartItemIdToProdIdMap: cartItemMap
        //         }).then(data => {

        //             if (this.subTotal <= 0) {
        //                 this.template.querySelector('c-cart-shipping-summary').handlesummaryDetails();
        //             }

        //             if (data != null) {
        //                 //alert('get Product Price Success')

        //                 // gettotalamount({ cartId: this.cartId })
        //                 //     .then(result => {
        //                 //         alert('price call success')
        //                 //         this.subTotal = result != null && parseFloat(result) > 0.00 ? (parseFloat(result)).toFixed(2) : 0.00;
        //                 //     })
        //                 //     .catch(error => {
        //                 //         //alert('Price Call failed')
        //                 //     });

        //                 //alert('success')

        //                 this.connectedCallback();



        //                 // console.log('cartItemIdToProdIdMap ', JSON.stringify(data))

        //                 // let updatedArray = this.cartItems.filter(obj1 => !data.some(obj2 => obj2.Product2Id === obj1.cartItem.productId));
        //                 // this.cartItems = updatedArray;

        //                 // this.showDearlerInstallation = this.cartItems && this.cartItems.length > 0 ? true : false;


        //                 // eval("$A.get('e.force:refreshView').fire();");



        //                 const event = new ShowToastEvent({
        //                     title: 'Toast message',
        //                     message: 'Some Items moved to the WishList',
        //                     variant: 'success',
        //                     mode: 'dismissable'
        //                 });
        //                 this.dispatchEvent(event);

        //             }



        //         }).catch((error) => {
        //             console.log('getProductPrice====> ', error);
        //             alert('failed')
        //         });

        //     }
        // }).catch((error) => {
        //     //alert('failed')
        // });









    }







}
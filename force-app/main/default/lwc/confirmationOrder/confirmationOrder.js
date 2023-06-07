/******************************************************************************* 

Name:  confirmationOrder

Business Unit: HDM

Date: MAy 2022

Description: This is the fourth screen of checkout 

******************************************************************************* 

MODIFICATIONS – Date | Dev Name | Method | User Story 

<09-06-2022> | <Yashika> | <added header> | 
3/7/2023     Saravanan Ramaswammy |  16456,17170
*******************************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import getCartItems from '@salesforce/apex/CartItemsCtrl.getCartItemList2';
import getOrderInfo from '@salesforce/apex/CartItemsCtrl.getOrderInfo'; //added by Yashika for 8677
import { NavigationMixin } from 'lightning/navigation';
//two import lines added by yashika for R2 story 6314
import schedule_installation from '@salesforce/label/c.schedule_installation';
import accessory_install_msg from '@salesforce/label/c.accessory_install_msg';
//ends
import {getReturnPolicyMarkup} from 'c/utils';
//for adobe analytics:starts
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';
//for adobe analytics:ends

const INSTALL_AT_DEALER = 'Install At Dealer';
const PICK_UP_AT_DEALER = 'Pick Up At Dealer';
const PICKUP_AT_DEALER = 'Pickup at Dealer';
const SHIP_TO_ME = 'Ship to Me';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';
const RETURN_POLICY = 'Returns and Exchange policies are at the dealer’s discretion, please contact your dealer for more details';
import CoreCharge from '@salesforce/label/c.B2B_Product_Code_Core_Charges'; // Added by Saravanan LTIM for 16456 , 17170
import CoreChargeDisclaimer from '@salesforce/label/c.B2B_CoreChargeDisclaimer'; // Added by Saravanan LTIM for 16456 , 17170

export default class ConfirmationOrder extends NavigationMixin(LightningElement) {
    carImage = imageResourcePath + '/carImage.jpeg';
    @api cartId;
    @api orderId;
    @track paymentType;
    //added by Yashika for 8677 : starts
    @track OrderNumber;
    @track customName;
    @track customerAddress;
    @track lastFourDigit;
    @track City;
    @track State;
    @track Street;
    @track Zip;
    @track Country;
    //8677: ends
    @api finAmount;
    @track cartItems;
    @track pickUpDealer = false;
    @track addressLabel = '';

    @track showAddress = {};
    @track dealerAddress = {};

    // these four variable added by yashika for R2 story 6314
    @track isDealerIntallation = false;
    @track schedule_installation = schedule_installation;
    @track accessory_install_msg = accessory_install_msg;
    @track dealerSchedulingLink; //ended
    @track isScheduleLinkAvailableOrNot = false;

    @track totalInstallationCharge;
    dealerName;
    TotalProductCount;
    dealerContactNumber;
    dealerContactEmail;
    cartItemsLength;
    dealerLabel;
    dealerOperationHours;
    shippingChargesStr;
    address;
    totalTaxStr;
    finalAmountStr;
    finalAmount = 0.00;
    subTotal = 0.00; // to store sum of list price of cart items.
    totalTax = 0.00;
    shippingCharges = 0.00;
    isShiptoMe = false;
    isDealerInfo = false;
    returnPolicy;
    @track shipSpeed;
    metadatarecid;
    disclaimerType;
    disclaimerMarkup;
    showDisclaimerMarkup = false;
    //for adobe analytics:messageContext
    @wire(MessageContext)
    messageContext;
    dealerReturnPolicyMarkup = "";
    // showDisclaimer = true;

    CoreChargeValue = CoreCharge; // Added by Saravanan LTIM for 16456 , 17170
    CoreChargeDisclaimerValue = CoreChargeDisclaimer; // Added by Saravanan LTIM for 16456 , 17170

    connectedCallback() {
        //for adobe analytics:starts
        const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD, confirmationOrderId: this.orderId } };//for adobe bug
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        //for adobe analytics:ends
        sessionStorage.removeItem('DeliveryType');
        window.scrollTo(0, 0);
        this.createCookie('cartIdForUpdate', '', -1);
        // this.fetchOrderInfo();
        //added by Yashika for 8677: starts
        getOrderInfo({ orderId: this.orderId })
            .then(result => {
                if (result) {
                    this.OrderNumber = result.OrderReferenceNumber;
                    this.customName = result.Customer_Name__c;
                    this.customerAddress = result.Address__c;
                    this.lastFourDigit = result.CC_Last4__c;
                    this.City = result.BillingCity;
                    this.State = result.BillingState;
                    this.Street = result.BillingStreet;
                    this.Zip = result.BillingPostalCode;
                    this.Country = result.BillingCountry;
                    this.paymentType = result.Payment_Type__c;
                    this.shipSpeed = result.Customer_Preferred_Speeds__c;
                }

            })
            .catch(error => {}); //8677- ends
        getCartItems({ cartId: this.cartId })
            .then(result => {
                if (result) {
                    this.cartItems = result;

                     /** LTIM Saravanan Added the below FOR..EACH loop for 16456,17170 */
                     if(this.cartItems){
                        var counter = 0;
                        this.cartItems.forEach(item => {
                            this.cartItems[counter].isCoreCharge = false;
                            if(item.Product_Type__c == this.CoreChargeValue){
                                this.cartItems[counter].isCoreCharge = true;
                            }
                            counter++;
                        })
                    }

                    
                this.cartItems.forEach(element => {
                    if(element.hasOwnProperty('Product_Type__c') && element.Product_Type__c == 'Motocompacto'){
                        element.isMotocompacto = true;
                    }else{
                        element.isMotocompacto = false;
                    }                    
                });
                this.customerName= result[0].Cart.Customer_Name__c;
                    //Modified by Faraz for HDMP-5428 R2 Story
                    if (result[0] && result[0].Cart.Pickup_Dealer__c && result[0].Cart.Delivery_Type__c == PICK_UP_AT_DEALER) {
                        this.addressLabel = PICKUP_AT_DEALER;
                        //this.shippingChargesStr = '0.00';//commented by saikiran as part of HDMP-10995  
                        //this.shippingCharges = 0.00;////commented by saikiran as part of HDMP-10995  

                        this.pickUpDealer = true;
                        this.isDealerIntallation = false;
                        this.isShiptoMe = false;
                        this.isDealerInfo = true;
                    } else if (result[0] && result[0].Cart.Delivery_Type__c && result[0].Cart.Delivery_Type__c == INSTALL_AT_DEALER && result[0].Cart.Total_Installation_Charge__c >= 0) {
                        this.isDealerIntallation = true; //added by Yashika for R2 story 6314
                        this.pickUpDealer = false;
                        this.isShiptoMe = false;
                        this.isDealerInfo = true;
                        this.totalInstallationCharge = parseFloat(result[0].Cart.Total_Installation_Charge__c).toFixed(2);
                    } else {
                        this.isShiptoMe = true;
                        this.isDealerIntallation = false;
                        this.pickUpDealer = false;
                        this.addressLabel = SHIP_TO_ME;

                        if (result[0].Cart.ShippingAmount__c) {
                            this.shippingChargesStr = parseFloat(result[0].Cart.ShippingAmount__c).toFixed(2);
                            this.shippingCharges = Number(parseFloat(result[0].Cart.ShippingAmount__c).toFixed(2));
                        }
                    }

                    //End HDMP-5428

                    this.dealerName = result[0].Cart.DealerId__r.Name;
                    this.dealerContactNumber = result[0].Cart.DealerId__r.Phone;
                    this.dealerContactEmail = result[0].Cart.DealerId__r.Email__c;
                    //newly added by Sayalee Start as a part of HDMP-5328
                    if (result[0].Cart.DealerId__r.Service_Scheduling_URL__c) {
                        this.dealerSchedulingLink = result[0].Cart.DealerId__r.Service_Scheduling_URL__c;
                        this.isScheduleLinkAvailableOrNot = true;
                    }
                    //end
                    this.dealerLabel = result[0].Cart.DealerId__r.First_Name__c + ' ' + result[0].Cart.DealerId__r.Last_Name__c;
                    if (result[0].Cart.DealerId__r.Operation_Hour__c) {
                        this.dealerOperationHours = result[0].Cart.DealerId__r.Operation_Hour__c.split(';');
                    }
                    //Added by Sayalee as a bug HDMP-9894 Starts here
                    if (result[0].Cart.DealerId__r.Return_Policy__c == undefined) {
                        this.returnPolicy = RETURN_POLICY;
                    } else {
                        this.returnPolicy = result[0].Cart.DealerId__r.Return_Policy__c;
                        this.dealerReturnPolicyMarkup = result[0].Cart.DealerId__r.Return_Policy__c;
                    }
                    // Ends here
                    //console.log('OUTPUT : ',this.dealerOperationHours);

                    if (result[0].Cart.customerAddress__c) {
                        console.log('inside cust address', result[0].Cart.customerAddress__c, result[0].Cart.CustomerStreet__c)
                        this.showAddress.shippingStreet = result[0].Cart.CustomerStreet__c;
                        this.showAddress.shippingCity = result[0].Cart.CustomerCity__c;
                        this.showAddress.shippingState = result[0].Cart.Customer_State__c;
                        this.showAddress.postalCode = result[0].Cart.CustomerPostalCode__c;
                    }
                    if (result[0].Cart.DealerId__r.ShippingAddress) {
                        this.dealerAddress.shippingStreet = result[0].Cart.DealerId__r.ShippingStreet;
                        this.dealerAddress.shippingCity = result[0].Cart.DealerId__r.ShippingCity;
                        this.dealerAddress.shippingState = result[0].Cart.DealerId__r.ShippingState;
                        this.dealerAddress.postalCode = result[0].Cart.DealerId__r.ShippingPostalCode;

                    }

                    if (!result[0].Cart.Total_Tax__c) {
                        this.totalTax = 0.00;
                        this.totalTaxStr = '0.00';
                    } else {
                        this.totalTax = Number(parseFloat(result[0].Cart.Total_Tax__c).toFixed(2));
                        this.totalTaxStr = parseFloat(result[0].Cart.Total_Tax__c).toFixed(2);
                    }

                    this.cartItems = this.cartItems.map(element => {
                        element = {...element };
                        element.TotalAmount = Number(parseFloat(element.TotalAmount).toFixed(2));
                        this.subTotal = this.subTotal + element.TotalAmount;
                        return element;
                    });

                    this.finalAmount = parseFloat(this.subTotal) + Number(parseFloat(this.shippingCharges).toFixed(2)) + Number(parseFloat(this.totalTax).toFixed(2));
                    if (this.finalAmount && this.totalInstallationCharge) {
                        this.finalAmount = parseFloat(this.finalAmount) + parseFloat(this.totalInstallationCharge);
                    }
                    if (this.finalAmount) {
                        this.finalAmountStr = parseFloat(this.finalAmount).toFixed(2);
                    }
                    console.log('showshipping values', this.showAddress.shippingStreet,
                        this.showAddress.shippingCity,
                        this.showAddress.shippingState,
                        this.showAddress.postalCode)
                }
            })
            .catch(error => {
                //console.log('error----' + JSON.stringify(error));
            });
        this.handleGetReturnPolicyMarkup();
    }

    async handleGetReturnPolicyMarkup(){
        let markupData = await getReturnPolicyMarkup();
        if(markupData.B2B_Motocompacto_Disclaimer_Markup && markupData.B2B_Motocompacto_Disclaimer_Markup.Markup__c){
            this.disclaimerMarkup = markupData.B2B_Motocompacto_Disclaimer_Markup.Markup__c;
        }        
    }

    handleClick(event) {
        localStorage.removeItem("allProductDetailsList");
        window.open(window.location.origin, "_self");
    }
    //for R2 story: added by Yashika: HDMP-6314
    //start  here
    handleOnScheduleInstallation() {
        window.open(this.dealerSchedulingLink, '_blank');
    }
    //ends here
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
    //Ashwin 16460
    showDealerModal = false;


    handleDisclamerPopup(event) {


        this.disclaimerType = event.currentTarget.dataset.id;

        this.showDealerModal = true;
    }

    handleShowHide(event) {
        this.showDealerModal = false;

    }
    openDisclaimerPopup(){
        this.showDisclaimerMarkup = true;
    }
    closeDisclaimerPopup(){
        this.showDisclaimerMarkup = false;
    }

}
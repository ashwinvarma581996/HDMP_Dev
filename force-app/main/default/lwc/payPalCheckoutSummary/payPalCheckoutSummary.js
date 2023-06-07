/*******************************************************************************
Name: CheckoutSummary
Business Unit: 
Created Date: 
Developer: Bhawesh Asudani
Description: LWC is created to handle UI for required accessories model.
*******************************************************************************

MODIFICATIONS – Date | Dev Name     | Method | User Story
                    | Bhawesh Asudani| fetchAllShippingSpeeds | HDMP-4726
     3/7/2023     Saravanan Ramaswammy |  16456,17170
*******************************************************************************/

import { LightningElement, api, wire, track } from 'lwc';
import getCartItems from '@salesforce/apex/CartItemsCtrl.getCartItemList2';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Added by : Bhawesh Asudani -- R2 Story : 4726 - Start
import fetchShippingSpeeds from '@salesforce/apex/CartItemsCtrl.fetchShippingSpeeds';
import reCalculateTaxOnChangeShippingSpeed from '@salesforce/apex/CartItemsCtrl.reCalculateTaxOnChangeShippingSpeed';

import linkCartToOrder from '@salesforce/apex/B2B_PayPalCheckoutHelper.linkCartToOrder';
import processPayment from '@salesforce/apex/B2B_PayPalCheckoutController.processPayment';

import DOLLAR_CURRENCY_SYMBOL from '@salesforce/label/c.Honda_Currency_Symbol';
import Shipping_Speed_Title from '@salesforce/label/c.Shipping_Speed_Title';
// End
import {getReturnPolicyMarkup} from 'c/utils';
import InstallationInfoNote from '@salesforce/label/c.Installation_Info_Message'; //Added by Faraz For R2
import InstallationInfo from '@salesforce/label/c.Installation_Info'; //Added by Faraz For R2
//for adobe analytics: starts
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';
//adobe: ends


const INSTALL_AT_DEALER = 'Install At Dealer';
const PICKUP_AT_DEALER = 'Pick Up At Dealer';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';

import CoreCharge from '@salesforce/label/c.B2B_Product_Code_Core_Charges'; // Added by Saravanan LTIM for 16456 , 17170
import CoreChargeDisclaimer from '@salesforce/label/c.B2B_CoreChargeDisclaimer'; // Added by Saravanan LTIM for 16456 , 17170

import  getStatusofVertex from '@salesforce/apex/B2B_BTVertexTaxCalculationIntegration.getStatusofVertex'; // Saravanan LTIM for 18902,18901

import validateZipCodeAndDealerTaxJurisdiction from '@salesforce/apex/B2B_EconfigIntegration.validateZipCodeAndDealerTaxJurisdiction'; // Added by Ashwin for Tax 19465
import getDraftOrderInfo from '@salesforce/apex/CartItemsCtrl.getDraftOrderInfo'; // Added by Ashwin for Tax 19465



export default class PayPalCheckoutSummary extends LightningElement {
    carImage = imageResourcePath + '/carImage.jpeg';
    @api cartId;
    @api address;
    @api orderId;
    @track shippingChargesStr;
    @track cartItems;
    @track totalInstallationCharge;
    @track pickUpDealer = false;
    @track showErrorPopup = false;
    @track isDealerIntallation = false;
    @track errorMessage = '';
    @track showAddress = {};
    @track dealerAddress = {};
    @track ShippingSpeedOptions = []; // Added by : Bhawesh Asudani -- R2 Story : 4726
    @track dealerReturnPolicy;//Added by Faraz on 01/08/2022 for HDMP-11659
    dealerName;
    totalTaxStr;
    finalAmountStr;
    installationInfoNoteLabel = InstallationInfoNote;
    installationInfoLabel = InstallationInfo;
    subTotal = 0.00; // to store sum of list price of cart items.
    totalTax = 0.00;
    finalAmount = 0.00;
    shippingCharges;
    selectedShippingSpeed = ''; // Added by : Bhawesh Asudani -- R2 Story : 4726
    isLoading = false;
    isShiptoMe = false;
    shippingSpeedAndChangesMap = new Map(); // Added by : Bhawesh Asudani -- R2 Story : 4726
    shippingSpeedList = []; // Added by : Bhawesh Asudani on 30-12-2021 -- R2 Story : 4726
    shippingSpeedTitle = Shipping_Speed_Title; // Added by : Bhawesh Asudani on 30-12-2021 -- R2 Story : 4726
    shippingSpeedType; //Added by Faraz - R2 Story : 6809
    B2BPreferredCarrier; //Added by Faraz - R2 Story : 6809
    paypalPayload;
    openErrorModal;
    dealerContactNumber;
    dealerContactEmail;
    dealerLabel;
    dealerOperationHours;
    isrestored = false;
    disclaimerMarkup;
    showDisclaimerMarkup = false;
    @track customerName;
    //Added by ashwin
    @track disclaimerType;
    dealerReturnPolicyMarkup = "";
    showDealerModal = false;

    CoreChargeValue = CoreCharge; // Added by Saravanan LTIM for 16456 , 17170
    CoreChargeDisclaimerValue = CoreChargeDisclaimer; // Added by Saravanan LTIM for 16456 , 17170
	showTaxAndTotalAmout = false; // added by ashwin for 19465
	deliveryType; // Added by ashwin for 19435

    //for adobe:
    @wire(MessageContext)
    messageContext;
    connectedCallback() {

         // Saravanan LTIM Added for 18901 , 18902
      
         this.getStatusofVertexJs();
              
         // Saravanan LTIM Ended for 18901 , 18902

        console.log('orderId : ', this.orderId);
        //for adobe: starts
        const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        //adobe: endss
        if (sessionStorage.getItem('payload')) {
            let payloadData = sessionStorage.getItem('payload');
            this.paypalPayload = JSON.parse(payloadData);
        }
        console.log('session : ', sessionStorage.getItem('payload'));

        getCartItems({ cartId: this.cartId })
            .then(result => {
                this.isrestored = false;
                if (result) {
                    console.log('result : ', JSON.parse(JSON.stringify(result)));
                    this.cartItems = result;
                    this.cartItems.forEach(element => {
                        if(element.hasOwnProperty('Product_Type__c') && element.Product_Type__c == 'Motocompacto'){
                            element.isMotocompacto = true;
                        }else{
                            element.isMotocompacto = false;
                        }                    
                    });

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

                    this.customerName = result[0].Cart.Customer_Name__c;
					
					this.deliveryType = result[0] && result[0].Cart.Delivery_Type__c; // Added by ashwin for 19435
					
                    //Added by Faraz for HDMP-5428 Start here R2 Story
                    if (result[0] && result[0].Cart.Delivery_Type__c == PICKUP_AT_DEALER) {
                        this.shippingChargesStr = '0.00';
                        //this.shippingCharges = 0.00;// commented by saikiran as part of HDMP - 10995
                        this.pickUpDealer = true;
                        this.isDealerIntallation = false;
                        this.isShiptoMe = false;
                    } else if (result[0] && result[0].Cart.Delivery_Type__c && result[0].Cart.Delivery_Type__c == INSTALL_AT_DEALER && result[0].Cart.Total_Installation_Charge__c >= 0) {
                        this.isDealerIntallation = true;
                        this.pickUpDealer = false;
                        this.isShiptoMe = false;
                        this.totalInstallationCharge = parseFloat(result[0].Cart.Total_Installation_Charge__c).toFixed(2);;
                    } else {
                        if (result[0].Cart.ShippingAmount__c > 0) {
                            this.isShiptoMe = true;
                            this.isDealerIntallation = false;
                            this.pickUpDealer = false;
                            //End here -By Faraz HDMP-5428 R2 Story
							
							// Added by ashwin for 19465
                            /*getDraftOrderInfo({ orderId: this.orderId }).then(result => {
                                console.log('result process Payment: ', result);
                                if (result) {

                                    this.validatingSalesTax(result.BillingPostalCode, result.AccountId);
                                } else {
                                    console.log('getDraftOrderInfo method Error=====>' + JSON.stringify(error));
                                }
                            })*/
                            // ended by ashwin for 19465
							
                            this.shippingChargesStr = parseFloat(result[0].Cart.ShippingAmount__c).toFixed(2);
                            this.shippingCharges = Number(parseFloat(result[0].Cart.ShippingAmount__c).toFixed(2));
                            if (result[0].Cart.DealerId__r.Preferred_Shipping_Carrier__r) {
                                this.B2BPreferredCarrier = result[0].Cart.DealerId__r.Preferred_Shipping_Carrier__r.Name ? result[0].Cart.DealerId__r.Preferred_Shipping_Carrier__r.Name : '';
                            }
                            if (result[0] && result[0].Cart.B2B_Shipping_Speed_Options__c) {
                                let options = JSON.parse(result[0].Cart.B2B_Shipping_Speed_Options__c);
                                console.log('options', options);
                                //updated by saikiran as part of HDMP-5440
                                // updated by saikiran as part of HDMP -16294
                                if (sessionStorage.getItem('selectedSpeed')) {
                                    this.shippingSpeedType = sessionStorage.getItem('selectedSpeed');
                                }
                                else {
                                    this.shippingSpeedType = options.defaultspeed;
                                }

                                // Added by : Bhawesh Asudani -- R2 Story : 4726  Start
                                this.fetchAllShippingSpeeds(options.serviceTypewithChargeMap, this.shippingSpeedType);
                                // Added by saikiran as part HDMP -16294
                                this.shippingCharges = options.serviceTypewithChargeMap[this.shippingSpeedType];
                                if (this.cartId && this.shippingCharges) {
                                    reCalculateTaxOnChangeShippingSpeed({ cartId: this.cartId, shippingCharges: this.shippingCharges, shippingSpeed: this.shippingSpeedType })
                                        .then(result => {
                                            console.log('result', result);
                                            result = JSON.parse(result);
                                            if (result && result.errorMessage == '' && result.isSuccess == true) {
                                                this.totalTaxStr = parseFloat(result.totalTaxAmount).toFixed(2);
                                                this.totalTax = Number(parseFloat(result.totalTaxAmount).toFixed(2));
                                                this.finalAmount = parseFloat(this.subTotal) + Number(parseFloat(this.shippingCharges).toFixed(2)) + Number(parseFloat(this.totalTax).toFixed(2));
                                                if (this.finalAmount) {
                                                    this.finalAmountStr = parseFloat(this.finalAmount).toFixed(2);
                                                }
                                            }
                                            else {
                                                this.totalTaxStr = 0.00;
                                                this.totalTax = 0.00;
                                                this.finalAmount = parseFloat(this.subTotal) + Number(parseFloat(this.shippingCharges).toFixed(2)) + Number(parseFloat(this.totalTax).toFixed(2));
                                                if (this.finalAmount) {
                                                    this.finalAmountStr = parseFloat(this.finalAmount).toFixed(2);
                                                }
                                                this.errorMessage = result.errorMessage;
                                                this.showErrorPopup = true;
                                            }
                                            this.isrestored = true;
                                            this.isLoading = false;
                                        })
                                        .catch(error => {
                                            this.isLoading = false;
                                        });
                                }
                                // End
                            }
                        } else {
                            if (result[0].Cart.B2B_Shipping_Speed_Options__c) {
                                //added by Saikiran as part of 8924 to display error message dynamically.
                                let options = JSON.parse(result[0].Cart.B2B_Shipping_Speed_Options__c);
                                if (options.errorMessage) {
                                    this.errorMessage = options.errorMessage;
                                    this.showErrorPopup = true;
                                }
                            }
                        }
                    }

                    if (result[0].Cart.DealerId__r && result[0].Cart.DealerId__r.ShippingAddress) {
                        this.dealerAddress.shippingStreet = result[0].Cart.DealerId__r.ShippingStreet;
                        this.dealerAddress.postalCode = result[0].Cart.DealerId__r.ShippingPostalCode;
                        this.dealerAddress.shippingState = result[0].Cart.DealerId__r.ShippingState;
                        this.dealerAddress.shippingCity = result[0].Cart.DealerId__r.ShippingCity;
                        this.dealerAddress.shippingCountry = result[0].Cart.DealerId__r.ShippingCountry;
                    }

                    this.dealerContactNumber = result[0].Cart.DealerId__r.Phone;
                    this.dealerContactEmail = result[0].Cart.DealerId__r.Email__c;
                    this.dealerName = result[0].Cart.DealerId__r.Name;
                    this.dealerLabel = result[0].Cart.DealerId__r.First_Name__c + ' ' + result[0].Cart.DealerId__r.Last_Name__c;

                    if (result[0].Cart.DealerId__r.Operation_Hour__c) {
                        this.dealerOperationHours = result[0].Cart.DealerId__r.Operation_Hour__c.split(';');
                    }

                    this.address = result[0].Cart.customerAddress__c;
                    if (result[0].Cart.customerAddress__c) {
                        this.showAddress.shippingName = result[0].Cart.Customer_Name__c;
                        this.showAddress.shippingPhone = result[0].Cart.Customer_Phone__c;
                        this.showAddress.shippingStreet = result[0].Cart.CustomerStreet__c;
                        this.showAddress.shippingCity = result[0].Cart.CustomerCity__c;
                        this.showAddress.shippingState = result[0].Cart.Customer_State__c;
                        this.showAddress.postalCode = result[0].Cart.CustomerPostalCode__c;
                        this.showAddress.Email = result[0].Cart.DealerId__r.Email__c ? result[0].Cart.DealerId__r.Email__c : false;
                        this.showAddress.Phone = result[0].Cart.DealerId__r.Phone ? result[0].Cart.DealerId__r.Phone : false;
						
						if (this.deliveryType == 'Ship to Me') {
                            this.validatingSalesTax(result[0].Cart.CustomerPostalCode__c, result[0].Cart.DealerId__c);
                        }
                    }
                    if (result[0].Cart.Total_Tax__c == null || result[0].Cart.Total_Tax__c < 0) {
                        this.totalTax = 0.00;
                        this.totalTaxStr = '0.00';
                        //this.errorMessage = 'We’re sorry. There was a problem with calculating tax on your order. Please retry submitting your order.There was a problem reaching vertex to calculate tax. Wait a minute and try again';
                        this.showErrorPopup = true;
                    } else if (!this.isrestored) {
                        this.totalTax = Number(parseFloat(result[0].Cart.Total_Tax__c).toFixed(2));
                        this.totalTaxStr = parseFloat(result[0].Cart.Total_Tax__c).toFixed(2);
                    }

                    this.cartItems = this.cartItems.map(element => {
                        element = { ...element };
                        element.TotalAmount = Number(parseFloat(element.TotalAmount).toFixed(2));
                        this.subTotal = this.subTotal + element.TotalAmount;
                        return element;
                    });
                    // commented and updated by saikiran as part of HDMP-10995
                    // this.finalAmount = parseFloat(this.subTotal) + Number(parseFloat(this.shippingCharges).toFixed(2)) + Number(parseFloat(this.totalTax).toFixed(2));
                    (this.shippingCharges) ? this.finalAmount = parseFloat(this.subTotal) + Number(parseFloat(this.shippingCharges).toFixed(2)) + Number(parseFloat(this.totalTax).toFixed(2)) : this.finalAmount = parseFloat(this.subTotal) + Number(parseFloat(this.totalTax).toFixed(2));
                    if (this.finalAmount && this.totalInstallationCharge) {
                        this.finalAmount = parseFloat(this.finalAmount) + parseFloat(this.totalInstallationCharge);
                    }
                    if (this.finalAmount) {
                        this.finalAmountStr = parseFloat(this.finalAmount).toFixed(2);
                        const attributeChangeEvent = new FlowAttributeChangeEvent('totalAmount', this.finalAmountStr);
                        this.dispatchEvent(attributeChangeEvent);
                    }
                    //Added by Faraz on 01/08/2022 for HDMP-11659
                    if (this.cartItems[0].Cart && this.cartItems[0].Cart.DealerId__r && this.cartItems[0].Cart.DealerId__r.Return_Policy__c) {
                        this.dealerReturnPolicy = this.cartItems[0].Cart.DealerId__r.Return_Policy__c;
                        this.dealerReturnPolicyMarkup = this.cartItems[0].Cart.DealerId__r.Return_Policy__c; // Added by Ashwin
                    } else {
                        this.dealerReturnPolicy = 'Returns and Exchange policies are at the dealer’s discretion, please contact your dealer for more details';
                    }
                    //End 11659
                }
            })
            .catch(error => {
                console.log('OUTPUT : ', error);
            });

        let payload = this.paypalPayload;
        var customerData = {
            'name': payload.details.firstName + ' ' + payload.details.lastName,
            'address1': payload.details.billingAddress ? payload.details.billingAddress.line1 : '',
            'address2': payload.details.billingAddress ? payload.details.billingAddress.line2 : '',
            'city': payload.details.billingAddress ? payload.details.billingAddress.city : '',
            'state': payload.details.billingAddress ? payload.details.billingAddress.state : '',
            'zipCode': payload.details.billingAddress ? payload.details.billingAddress.postalCode : '',
            'phone': payload.details.phone ? payload.details.phone.replaceAll('-', '') : '',
            'email': payload.details.email,
            'country': 'USA',
        };

        linkCartToOrder({ cartId: this.cartId, orderId: this.orderId, dataToUpdate: customerData }).then(result => {
            console.log('result for linkCartToOrder: ', result);
        }).catch(error => {
            console.log('error in linking the order : ', error);
        });

        this.handleGetReturnPolicyMarkup();
    }

    async handleGetReturnPolicyMarkup(){
        let markupData = await getReturnPolicyMarkup();
        if(markupData.B2B_Motocompacto_Disclaimer_Markup && markupData.B2B_Motocompacto_Disclaimer_Markup.Markup__c){
            this.disclaimerMarkup = markupData.B2B_Motocompacto_Disclaimer_Markup.Markup__c;
        }        
    }

    handleBackClick() {
        window.location = '/s/cart/' + this.cartId;
    }

    handleProcessPaymentClick() {
        this.isLoading = true;
        let payload = this.paypalPayload;
        var customerData = {
            'name': payload.details.firstName + ' ' + payload.details.lastName,
            'address1': payload.details.billingAddress ? payload.details.billingAddress.line1 : '',
            'address2': payload.details.billingAddress ? payload.details.billingAddress.line2 : '',
            'city': payload.details.billingAddress ? payload.details.billingAddress.city : '',
            'state': payload.details.billingAddress ? payload.details.billingAddress.state : '',
            'zipCode': payload.details.billingAddress ? payload.details.billingAddress.postalCode : '',
            'phone': payload.details.phone ? payload.details.phone.replaceAll('-', '') : '',
            'email': payload.details.email,
            'country': 'USA',
        };

        alert(payload.nonce);
        processPayment({ orderId: this.orderId, cartId: this.cartId, customerData: customerData, paypalNonce: payload.nonce }).then(result => {
            console.log('result process Payment: ', result);
            if (result) {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            } else {
                this.openErrorModal = true;
            }
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            console.log('Error in ProcessPayment : ', error);
        });
    }

    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    closeErrorPopup() {
        this.showErrorPopup = false;
    }

    // Added by : Bhawesh Asudani -- R2 Story : 4726  Start
    handleOnChangeShippingSpeed(event) {
        this.isLoading = true;
        const selectedSpeed = event.currentTarget.value;
        //updated by saikiran as part of HDMP-5440
        sessionStorage.removeItem('selectedSpeed');
        sessionStorage.setItem('selectedSpeed', selectedSpeed);

        if (selectedSpeed) {
            this.selectedShippingSpeed = selectedSpeed;
            if (this.shippingSpeedAndChangesMap.has(selectedSpeed)) {
                this.shippingCharges = Number(parseFloat(this.shippingSpeedAndChangesMap.get(selectedSpeed)).toFixed(2));
                //updated by saikiran as part of HDMP-5440
                sessionStorage.removeItem('speedCharges');
                sessionStorage.setItem('speedCharges', this.shippingCharges);
                if (this.cartId && this.shippingCharges) {
                    reCalculateTaxOnChangeShippingSpeed({ cartId: this.cartId, shippingCharges: this.shippingCharges, shippingSpeed: this.selectedShippingSpeed })
                        .then(result => {
                            console.log('result', result);
                            result = JSON.parse(result);
                            if (result && result.errorMessage == '' && result.isSuccess == true) {
                                this.totalTaxStr = parseFloat(result.totalTaxAmount).toFixed(2);
                                this.totalTax = Number(parseFloat(result.totalTaxAmount).toFixed(2));
                                this.finalAmount = parseFloat(this.subTotal) + Number(parseFloat(this.shippingCharges).toFixed(2)) + Number(parseFloat(this.totalTax).toFixed(2));
                                if (this.finalAmount) {
                                    this.finalAmountStr = parseFloat(this.finalAmount).toFixed(2);
                                }
                            }
                            else {
                                this.totalTaxStr = 0.00;
                                this.totalTax = 0.00;
                                this.finalAmount = parseFloat(this.subTotal) + Number(parseFloat(this.shippingCharges).toFixed(2)) + Number(parseFloat(this.totalTax).toFixed(2));
                                if (this.finalAmount) {
                                    this.finalAmountStr = parseFloat(this.finalAmount).toFixed(2);
                                }
                                this.errorMessage = result.errorMessage;
                                this.showErrorPopup = true;
                            }

                            this.isLoading = false;
                        })
                        .catch(error => {
                            this.isLoading = false;
                        });
                }
            }
        }
    }
    // End

    // Added by : Bhawesh Asudani -- R2 Story : 4726  Start
    fetchAllShippingSpeeds(options, defaultSpeed) {
        console.log('options==', options, 'defaultSpeed', defaultSpeed);
        this.shippingSpeedList = [];
        let ShippingSpeeds = [];
        fetchShippingSpeeds()
            .then(result => {
                result.forEach(shipSpeed => {
                    if (shipSpeed.Carrier_Speed_Name__c && options[shipSpeed.Carrier_Speed_Name__c]) {
                        this.shippingSpeedList.push(shipSpeed);
                        if (defaultSpeed == shipSpeed.Carrier_Speed_Name__c) {
                            this.selectedShippingSpeed = shipSpeed.Carrier_Speed_Name__c;
                        }
                        if (this.shippingSpeedType && this.shippingSpeedType.length > 0 && this.B2BPreferredCarrier && this.B2BPreferredCarrier.length > 0 &&
                            shipSpeed.Carrier__r.Name == this.B2BPreferredCarrier && this.shippingSpeedType == shipSpeed.Carrier_Speed_Name__c) {
                            this.selectedShippingSpeed = shipSpeed.Carrier_Speed_Name__c;
                        }
                        ShippingSpeeds.push({ label: shipSpeed.Honda_Shipping_Speed__r.Honda_Speed_Name__c + ' - ' + DOLLAR_CURRENCY_SYMBOL + parseFloat(options[shipSpeed.Carrier_Speed_Name__c]).toFixed(2), value: shipSpeed.Carrier_Speed_Name__c });
                        this.shippingSpeedAndChangesMap.set(shipSpeed.Carrier_Speed_Name__c, options[shipSpeed.Carrier_Speed_Name__c]);
                    }

                });

                this.ShippingSpeedOptions = ShippingSpeeds;
                console.log('ShippingSpeedOptions', ShippingSpeedOptions);

            })
            .catch(error => { });
    }
    // End


    //End 5359
    // Added By Ashwin for Disclaimers Changes


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

        // Saravana LTIM Added to have Vertex status Bug 18902 , 18901
        diabledButton = false;
        getStatusofVertexJs(){
            var status = false;
            getStatusofVertex()
                .then(result => { 
                    if(!result){
                        this.showToastMessage('Error','We’re experiencing technical difficulties, please try again later','error');
                        this.diabledButton = true;
                    }
                    return result;
                })
                .catch(error => {
                    return false;
                 });
            return false;     
        }
    
        // Saravana LTIM Added to have Vertex status Bug 18902 , 18901
		
		
		// Ashwin Added below function for Tax Juridications Sprint 4 19465

    validatingSalesTax(zipCodeValue, dealerId) {


        if (zipCodeValue) {
            validateZipCodeAndDealerTaxJurisdiction({ Accid: dealerId, state: '', zipcode: zipCodeValue, poiType: '', searchRadius: '', numberOfPOIs: '' })
                .then(result => {
                    console.log('result======>' + JSON.stringify(result));
                    if (!result) {

                        this.showDealerModal = true;
                        this.disclaimerType = 'zipCodeDisclaimer';
                        this.showTaxAndTotalAmout = true;
                        this.diabledButton = true;
                    }
                })
                .catch(error => {
                    console.log('Error=====>' + JSON.stringify(error));
                });
        }

    }

    // Ashwin Added below function for Tax Juridications Sprint 4 for 19465

        
}
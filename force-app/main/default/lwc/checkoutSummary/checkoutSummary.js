/*******************************************************************************
Name: CheckoutSummary
Business Unit: 
Created Date: 
Developer: Bhawesh Asudani
Description: LWC is created to handle UI for required accessories model.
*******************************************************************************

MODIFICATIONS – Date | Dev Name     | Method | User Story
                    | Bhawesh Asudani| fetchAllShippingSpeeds | HDMP-4726
03/07/2023          | LTIM Saravanan | 16456 , 17170                    
*******************************************************************************/

import { LightningElement, api, track } from 'lwc';
import getCartItems from '@salesforce/apex/CartItemsCtrl.getCartItemList2';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Added by : Bhawesh Asudani -- R2 Story : 4726 - Start
import fetchShippingSpeeds from '@salesforce/apex/CartItemsCtrl.fetchShippingSpeeds';
import reCalculateTaxOnChangeShippingSpeed from '@salesforce/apex/CartItemsCtrl.reCalculateTaxOnChangeShippingSpeed';
import DOLLAR_CURRENCY_SYMBOL from '@salesforce/label/c.Honda_Currency_Symbol';
import Shipping_Speed_Title from '@salesforce/label/c.Shipping_Speed_Title';
// End
import { getReturnPolicyMarkup } from 'c/utils';
import InstallationInfoNote from '@salesforce/label/c.Installation_Info_Message'; //Added by Faraz For R2
import InstallationInfo from '@salesforce/label/c.Installation_Info'; //Added by Faraz For R2


const INSTALL_AT_DEALER = 'Install At Dealer';
const PICKUP_AT_DEALER = 'Pick Up At Dealer';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';

import CoreCharge from '@salesforce/label/c.B2B_Product_Code_Core_Charges'; // Added by Saravanan LTIM for 16456 , 17170
import CoreChargeDisclaimer from '@salesforce/label/c.B2B_CoreChargeDisclaimer'; // Added by Saravanan LTIM for 16456 , 17170

import validateZipCodeAndDealerTaxJurisdiction from '@salesforce/apex/B2B_EconfigIntegration.validateZipCodeAndDealerTaxJurisdiction'; // Added by Pratik for Sales Tax jurisdications

export default class CheckoutSummary extends LightningElement {
    carImage = imageResourcePath + '/carImage.jpeg';
    @api cartId;
    @api address;
    @api taxErrorMessage;
    @track shippingChargesStr;
    @track cartItems;
    @track totalInstallationCharge;
    @track pickUpDealer = false;
    @track showErrorPopup = false;
    @track isDealerIntallation = false;
    @track errorMessage = '';
    @track showAddress = {};
    @track ShippingSpeedOptions = []; // Added by : Bhawesh Asudani -- R2 Story : 4726
    @track dealerReturnPolicy;//Added by Faraz on 01/08/2022 for HDMP-11659
    metadatarecid;
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
    @track customerName;
    isrestored = false;
    disclaimerMarkup;
    showDisclaimerMarkup = false;
    disclaimerType; // Added by ashwin
    showDealerModal = false; // Added by ashwin
    dealerReturnPolicyMarkup = ""; // Added by ashwin
    //showDisclaimer = true;

    CoreChargeValue = CoreCharge; // Added by Saravanan LTIM for 16456 , 17170
    CoreChargeDisclaimerValue = CoreChargeDisclaimer; // Added by Saravanan LTIM for 16456 , 17170

    showtaxAndTotalAmount = false; // added by ashwin for 19465

    connectedCallback() {
        getCartItems({ cartId: this.cartId })
            .then(result => {
                this.isrestored = false;
                if (result) {
                    //this.showDisclaimer = result[0].Cart.Delivery_Type__c == 'Ship to Me' ? false : true;
                    console.log('result : ', JSON.parse(JSON.stringify(result)));
                    this.cartItems = result;
                    /** LTIM Saravanan Added the below FOR..EACH loop for 16456,17170 */

                    // Saravanan LTIM added below method for Sp4 - Tax Jurisdications

                    console.log('dealer Id ----' + result[0].Cart.DealerId__c);

                    if (result[0].Cart.DealerId__c && result[0].Cart.Delivery_Type__c == 'Ship to Me') {
                        this.validatingSalesTax(sessionStorage.getItem('PostalCode'), result[0].Cart.DealerId__c);

                    }
                    // Saravanan LTIM ended below method for Sp4 - Tax Jurisdications

                    if (this.cartItems) {
                        var counter = 0;
                        this.cartItems.forEach(item => {
                            this.cartItems[counter].isCoreCharge = false;
                            if (item.Product_Type__c == this.CoreChargeValue) {
                                this.cartItems[counter].isCoreCharge = true;
                            }
                            // To Identify the reman parts 
                            if (item.Product2.Core_Charge_Unit_Price__c) {
                                this.cartItems[counter].isReman = true;
                            }
                            counter++;
                        })
                    }
                    this.customerName = result[0].Cart.Customer_Name__c;
                    this.dealerReturnPolicyMarkup = result[0].Cart.DealerId__r.Return_Policy__c;

                    this.cartItems.forEach(element => {
                        if (element.hasOwnProperty('Product_Type__c') && element.Product_Type__c == 'Motocompacto') {
                            element.isMotocompacto = true;
                        } else {
                            element.isMotocompacto = false;
                        }
                    });
                    //Added by Faraz for HDMP-5428 Start here R2 Story
                    if (result[0] && result[0].Cart.Pickup_Dealer__c && result[0].Cart.Delivery_Type__c == PICKUP_AT_DEALER) {
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
                            this.shippingChargesStr = parseFloat(result[0].Cart.ShippingAmount__c).toFixed(2);
                            this.shippingCharges = Number(parseFloat(result[0].Cart.ShippingAmount__c).toFixed(2));
                            if (result[0].Cart.DealerId__r.Preferred_Shipping_Carrier__r) {
                                this.B2BPreferredCarrier = result[0].Cart.DealerId__r.Preferred_Shipping_Carrier__r.Name ? result[0].Cart.DealerId__r.Preferred_Shipping_Carrier__r.Name : '';
                            }
                            if (result[0] && result[0].Cart.B2B_Shipping_Speed_Options__c) {
                                let options = JSON.parse(result[0].Cart.B2B_Shipping_Speed_Options__c);
                                console.log('options', options);
                                //updated by saikiran as part of HDMP-5440
                                // updated  by saikiran as part of HDMP-16157
                                if (sessionStorage.getItem('selectedSpeed')) {
                                    this.shippingSpeedType = sessionStorage.getItem('selectedSpeed');
                                }
                                else {
                                    this.shippingSpeedType = options.defaultspeed;
                                }

                                // Added by : Bhawesh Asudani -- R2 Story : 4726  Start
                                this.fetchAllShippingSpeeds(options.serviceTypewithChargeMap, this.shippingSpeedType)
                                this.shippingCharges = options.serviceTypewithChargeMap[this.shippingSpeedType];
                                //Added by saikiran as part of HDMP-16157
                                if (this.cartId && this.shippingCharges) {
                                    reCalculateTaxOnChangeShippingSpeed({ cartId: this.cartId, shippingCharges: this.shippingCharges, shippingSpeed: this.shippingSpeedType })
                                        .then(result => {
                                            result = JSON.parse(result);
                                            console.log('result', result);
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
                            //added by Saikiran as part of 8924 to display error message dynamically.
                            let options = JSON.parse(result[0].Cart.B2B_Shipping_Speed_Options__c);
                            console.log('options', options.errorMessage);
                            if (options.errorMessage) {
                                this.errorMessage = options.errorMessage;
                                this.showErrorPopup = false; // chenged to false by ashwin for 19465
                                this.showtaxAndTotalAmount = true; // Added by ashwin for 19465
                            }
                        }
                    }

                    this.dealerName = result[0].Cart.DealerId__r.Name;
                    this.address = result[0].Cart.customerAddress__c;
                    if (result[0].Cart.customerAddress__c) {
                        this.showAddress.shippingStreet = result[0].Cart.CustomerStreet__c;
                        this.showAddress.shippingCity = result[0].Cart.CustomerCity__c;
                        this.showAddress.shippingState = result[0].Cart.Customer_State__c;
                        this.showAddress.postalCode = result[0].Cart.CustomerPostalCode__c;
                        this.showAddress.Email = result[0].Cart.DealerId__r.Email__c ? result[0].Cart.DealerId__r.Email__c : false;
                        this.showAddress.Phone = result[0].Cart.DealerId__r.Phone ? result[0].Cart.DealerId__r.Phone : false;
                    }
                    if (result[0].Cart.Total_Tax__c == null || result[0].Cart.Total_Tax__c < 0 || this.taxErrorMessage) {
                        this.totalTax = 0.00;
                        this.totalTaxStr = '0.00';
                        this.errorMessage = this.taxErrorMessage.toString();
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
                    } else {
                        this.dealerReturnPolicy = 'Returns and Exchange policies are at the dealer’s discretion, please contact your dealer for more details';
                    }
                    //End 11659
                }
            })
            .catch(error => {
                console.log('OUTPUT : ', error);
            });
        this.handleGetReturnPolicyMarkup();
    }

    async handleGetReturnPolicyMarkup() {
        let markupData = await getReturnPolicyMarkup();
        if (markupData.B2B_Motocompacto_Disclaimer_Markup && markupData.B2B_Motocompacto_Disclaimer_Markup.Markup__c) {
            this.disclaimerMarkup = markupData.B2B_Motocompacto_Disclaimer_Markup.Markup__c;
        }
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
                    //updated by saikiran as part of HDMP -11886
                    reCalculateTaxOnChangeShippingSpeed({ cartId: this.cartId, shippingCharges: this.shippingCharges, shippingSpeed: this.selectedShippingSpeed })
                        .then(result => {
                            result = JSON.parse(result);
                            console.log('result', result);
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

    //Aditya 16460

    //Aditya 16460
    handleDisclamerPopup(event) {


        this.disclaimerType = event.currentTarget.dataset.id;

        this.showDealerModal = true;

    }



    handleShowHide(event) {
        this.showDealerModal = false;

    }

    openDisclaimerPopup() {
        this.showDisclaimerMarkup = true;
    }
    closeDisclaimerPopup() {
        this.showDisclaimerMarkup = false;
    }

    // Saravanan LTIM Added below function for Sales Juridications Sprint 4

    validatingSalesTax(zipCodeValue, dealerId) {
        if (zipCodeValue) {
            validateZipCodeAndDealerTaxJurisdiction({ Accid: dealerId, state: '', zipcode: zipCodeValue, poiType: '', searchRadius: '', numberOfPOIs: '' })
                .then(result => {
                    console.log('result' + JSON.stringify(result));
                    if (!result) {
                        this.showDealerModal = true;
                        this.disclaimerType = 'zipCodeDisclaimer';
                    }
                })
                .catch(error => {
                    console.log('Error' + JSON.stringify(error));
                });
        }
    }

    // Saravanan LTIM Added below function for Sales Juridications Sprint 4
}
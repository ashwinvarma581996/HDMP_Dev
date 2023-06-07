/**
 * @FileName         : cartShippingSummary.js
 * @Description      : To Display Estimated Shipping and Estimated Tax Details on Cart page
 * @Author           : SaiLakshman Kanukollu
 * @Ticket           : HDM-5409
 * @LastModified     : SaiLakshman Kanukollu
 * @LastModifiedOn   : 01-12-2021
 * @Modification Log : 
 **/
import { LightningElement, api, track } from 'lwc';
import { getCurrentDealerId } from 'c/utils';
import sharedfile from 'c/utilityLWC';
import getTaxDetails from '@salesforce/apex/B2B_TaxHelperV2.startCartProcessMegaSync';
//import getShippingCharges from '@salesforce/apex/B2B_ShippingHelperV2.startCartProcessMegaSync';
import getShippingCharges from '@salesforce/apex/B2B_ShippingHelper.startCartProcessMegaSync';
import getDealerInformation from '@salesforce/apex/CartItemsCtrl.getDealerInformation';
import getloggedInuser from '@salesforce/apex/B2B_LoggedInUserAddressCheck.loggedInuser';
import DealerNotSelectedError from '@salesforce/label/c.DealerNotSelectedError';
import ShippableItemsError from '@salesforce/label/c.ShippableItemsError';
import InvalidZipCodeError from '@salesforce/label/c.Error_Message_for_Invalid_ZipCodes';
import InvalidZipCodePattern from '@salesforce/label/c.Error_message_for_Invalid_pattern_of_zip_code';
//import ZipCodeLabel from '@salesforce/label/c.ZipCode_Label';
//import Verifying_Zipcode from '@salesforce/label/c.Verifying_Zipcode';
//import Estimated_Tax from '@salesforce/label/c.Estimated_Tax';
//import Estimated_Shipping from '@salesforce/label/c.Estimated_Shipping';
import Error_Message_for_Estimated_Tax from '@salesforce/label/c.Error_Message_for_Estimated_Tax'; //Added by shalini soni for R2B HDMP-8643
import getCustomLabelforCartShippingSummary from '@salesforce/apex/CartItemsCtrl.getCustomLabelforCartShippingSummary'; //Added by Shalini Soni 16 March 2022 for bug-8380
import getCartCountTotal from '@salesforce/apex/CartItemsCtrl.getCartCountTotal';// Added by Soumya for Max limit of cart to 25
import setDealerInstallationType from '@salesforce/apex/CartItemsCtrl.setDealerInstallationType';

import validateZipCodeAndDealerTaxJurisdiction from '@salesforce/apex/B2B_EconfigIntegration.validateZipCodeAndDealerTaxJurisdiction'; // Added by Pratik for Sales Tax jurisdications

const POSTAL_CODE = 'PostalCode';
const BOOLEAN_TRUE = 'true';
const BOOLEAN_FALSE = 'false';
const TYPE_CART = 'Cart';
const USPS_RETAIL_GROUND = 'USPS Retail Ground';
const UPS_RETAIL_GROUND = '03';
const LIGHTNING_INPUT = 'lightning-input';

export default class CartShippingSummary extends LightningElement {
    @track isDealerAndCart = false;//added by Yashika for 7996: starts
    @track error;
    @track errorMessage;
    @track postalCode;
    @track loggedInUserpostalCode;
    @track dealerPostalCode;
    @track charCodeKey;
    @track isDealerSelected;
    @track _updatedcartItems;
    @track _installationCharges = 0;
    @track _subTotal = 0;
    @track warningMessage;
    @track shippingCost = 0;
    @track taxAmount = 0;
    @track showShippingDetails = false;
    @track showCartUpdatesSummary = false;
    @track showTaxDetails = false;
    @track showSummary = false;
    @track showspinner = false;
    @track showTaxCalculationSpinner = false;
    @track showError = false;
    @track onInstallAtDealer = false;
    @track onPickUp = false;
    @track isShipToMe;
    @track totalSubTotal;
    @track dealerValue;
    @track _dealerValue;
    @track isRunning = true;
    @api cartid;
    @track label = {};
    @track isEstimatedTax = false; //Added by shalini soni for R2B HDMP-8643
    @track isLoader = false; //Added by saikiran as part of HDMP 16433-
    labels = { //Added by shalini soni for R2B HDMP-8643
        Error_Message_for_Estimated_Tax
    };
    @api
    get installationCharges() {
        return this._installationCharges;
    }
    set installationCharges(value) {
        console.log('OUTPUTvlue : ', value);
        console.log('OUTPUToption : ', this.dealerValue);
        if (value) {
            this._installationCharges = value;
            let calculatedSubTotal = parseFloat(this._subTotal) + parseFloat(this._installationCharges) + parseFloat(this.taxAmount) + parseFloat(this.shippingCost);
            this.totalSubTotal = calculatedSubTotal.toFixed(2)
        }
        //By Faraz on 27/06/2022 for 5326 - Start
        if (value && (value == 0 || value == '0') && this.dealerValue && this.dealerValue.InstallAtDealer === BOOLEAN_TRUE) {
            console.log('OUTPUTaya : ', value);
            this.onInstallAtDealer = false;
        }
        //By Faraz on 27/06/2022 for 5326 - End
    }

    @api
    get subTotal() {
        return this._subTotal;
    }
    set subTotal(value) {
        if (value) {
            this._subTotal = value;
        }
    }

    @api
    get cartItems() {
        return this._updatedcartItems;
    }
    set cartItems(value) {
        if (value && this._updatedcartItems !== value) {
            let isShippable;
            this.isDealerSelected = getCurrentDealerId() ? true : false;
            if (value.length > 0) {
                this.fetchDealerDetails();
                value.forEach((item) => {
                    console.log('OUTPUTitem : ', item);
                    if (!item.pickupDelear)
                        isShippable = true;
                    else
                        isShippable = false;
                })
                if (!this.isDealerSelected) {
                    this.setWarningMessage(DealerNotSelectedError);
                } else if (this.isDealerSelected && !isShippable) {
                    this.isDealerSelected = false;
                    this.setNull();
                    this.setWarningMessage(ShippableItemsError);
                }
            } else if (value.length == 0) {
                this.warningMessage = '';
                this.isDealerSelected = false;
                this.showSummary = false;
                this.setNull();
            }
            this._updatedcartItems = value;
        }
    }
    //Added by Shalini Soni 16 March 2022 for bug-8380
    async getCustomLabelsFromApex() {
        await getCustomLabelforCartShippingSummary()
            .then(result => {
                if (result) {
                    console.log('##result', result);
                    this.label = {
                        ZipCodeLabel: result.ZipCode_Label,
                        Verifying_Zipcode: result.Verifying_Zipcode,
                        Estimated_Shipping: result.Estimated_Shipping,
                        Estimated_Tax: result.Estimated_Tax,
                        Estimated_Cart_Subtotal: result.Estimated_Cart_Subtotal,
                    };
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
    //Ends

    fetchDealerDetails() {
        if (getCurrentDealerId()) {
            getDealerInformation({ dealerId: getCurrentDealerId() })
                .then(result => {
                    if (result) {
                        this.dealerPostalCode = result.ShippingPostalCode;
                        if (getCurrentDealerId() && this.dealerPostalCode && this.dealerValue)
                            this.onDelarInstallationSelection();
                    }
                })
                .catch(error => {
                    console.error(error);
                });
        }
    }

    @api onDelarInstallation(data) {
        if (data && this._dealerValue !== data) {
            // Added by saikiran as part of HDMP-16433
            this.dealerValue = JSON.parse(data);
            if (this.dealerValue.InstallAtDealer == 'true' || this.dealerValue.PickUpAtDealer == 'true') {
                this.isLoader = true;
            }
            this.isShipToMe = this.dealerValue.ShipToMe;
            if (this.isShipToMe) {
                const selectedEvent = new CustomEvent('totalestimatedpricechange', { detail: { totalPrice: this._subTotal } });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            }
            this.onDelarInstallationSelection();
            this._dealerValue = data;
        }
    }

    connectedCallback() {
        this.getCustomLabelsFromApex(); //Added by Shalini soni 16 March 2022 for bug-8380
        if (sessionStorage.getItem(POSTAL_CODE)) {
            this.postalCode = sessionStorage.getItem(POSTAL_CODE);
        }
        else {
            getloggedInuser()
                .then(result => {
                    console.log('Logged in user ##' + JSON.stringify(result));
                    if (result.length > 0) {
                        var postalCde = result[0].Zip__c ? result[0].Zip__c : '';
                        this.loggedInUserpostalCode = postalCde.substring(0, 5);
                        if (getCurrentDealerId()) {
                            this.postalCode = postalCde.substring(0, 5);
                            if (this.postalCode.length == 5) {
                                this.fetchShippingDetails();
                            }
                        }
                    }
                })
                .catch(error => {
                    console.error(error);
                });
        }
    }

    handleKeyPressLocation(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        this.charCodeKey = charCode === undefined ? this.charCodeKey : charCode;
        if (this.charCodeKey == 13) {
            this.getShippingTaxData();
        }
        if (((this.charCodeKey != 8 && (this.charCodeKey < 48 || this.charCodeKey > 57)))) {
            event.preventDefault();
            return true;
        }
    }

    handlePostalCodeChange(event) {
        //Saravanan LTIM Added for Sp-4 Tax Jurisdications
        this.postalCode = event.detail.value;

        if (this.postalCode.length < 5) {
            //added by Yashika for 12353: 
            setDealerInstallationType({ cartId: this.cartid, deliveryType: 'Ship To Me' })
                .then(result => {
                    if (result && result == SUCCESS) {


                    } else {
                    }
                })
                .catch(error => {
                    this.isLoader = false;
                });
            //ends
            this.showSummary = false;

        }
        const selectedEvent = new CustomEvent('totalestimatedpricechange', { detail: { totalPrice: this._subTotal } });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    onDelarInstallationSelection(event) {
        if (this.dealerValue.InstallAtDealer === BOOLEAN_TRUE) {
            this.showCartUpdatesSummary = false;
            this.shippingCost = 0;
            this.onInstallAtDealer = true;
            this.onPickUp = false;
            if (getCurrentDealerId()) {
                this.fetchTaxData();
            }
        }
        if (this.dealerValue.PickUpAtDealer === BOOLEAN_TRUE) {
            this.showCartUpdatesSummary = false;
            this._installationCharges = 0;
            this.shippingCost = 0;
            this.onInstallAtDealer = false;
            this.onPickUp = true;
            if (getCurrentDealerId()) {
                this.fetchTaxData();
            }
        }
        if (this.dealerValue.ShipToMe === BOOLEAN_TRUE) {
            this.showCartUpdatesSummary = true;
            this._installationCharges = 0;
            this.onInstallAtDealer = false;
            this.onPickUp = false;
            setTimeout(() => {
                if (this.postalCode) {
                    this.getShippingTaxData();
                }
                else {
                    if (this.loggedInUserpostalCode && getCurrentDealerId())
                        this.postalCode = this.loggedInUserpostalCode;
                    this.fetchShippingDetails();
                }
            }, 100);
        }
        this.isLoader = false;// Added by saikiran as part of 16433
    }

    fetchTaxData(event) {
        this.isLoader = true; // Added by saikiran as part of 16433
        // Added by saikiran as part of 16433
        if (this.isShipToMe == BOOLEAN_FALSE) {
            this.showError = false;
            this.errorMessage = '';
        }
        this.showTaxCalculationSpinner = true;
        this.showTaxDetails = false;
        setTimeout(() => {
            sharedfile._servercall(
                getTaxDetails, {
                cartId: this.cartid,
                CustomerPostalCode: this.dealerPostalCode,
                ShippingCharges: '',
                cartType: TYPE_CART
            },
                this.handleTaxSuccess.bind(this),
                this.handleTaxError.bind(this)
            );
        }, 1000);
    }

    getShippingTaxData(event) {
        // Pratik Added for Sales Tax Juridications Sprint 4 
        var zipCodeValue = this.template.querySelector(LIGHTNING_INPUT).value;
        console.log('ZipCode value---' + zipCodeValue);
        if (this.template.querySelector(LIGHTNING_INPUT).value) {
            this.validatingSalesTax(zipCodeValue, getCurrentDealerId());
        }
        // Pratik Ended for Sales Tax Juridications Sprint 4 

        this.isLoader = true;
        if (this.isRunning) {
            this.isRunning = false;
            this.postalCode = this.template.querySelector(LIGHTNING_INPUT).value;
            var regExp = /[a-zA-Z]/g;
            if (regExp.test(this.postalCode)) {
                this.showSummary = false;
                this.setNull();
            }
            this.fetchShippingDetails();
        }
    }

    fetchShippingDetails() {
        if (this.cartid && this.postalCode && this.postalCode.length == 5) {
            this.showSummary = true;
            this.showspinner = true;
            this.showShippingDetails = false;
            this.isLoader = true; // Added by saikiran as part of 16433
            this.showError = false;
            this.showTaxDetails = false;
            sessionStorage.setItem(POSTAL_CODE, this.postalCode);
            console.log('test');
            sharedfile._servercall(
                getShippingCharges, {
                cartId: this.cartid,
                CustomerPostalCode: this.postalCode,
                cartType: TYPE_CART
            },
                this.handleShippingSuccess.bind(this),
                this.handleShippingError.bind(this)
            );
        }
        if (this.postalCode.length > 0 && this.postalCode.length < 5) {
            this.showSummary = true;
            this.showError = true;
            this.showspinner = false;
            this.showTaxDetails = false;
            this.errorMessage = InvalidZipCodePattern;
            this.isRunning = true;
            this.isLoader = false; // Added by saikiran as part of 16433
        }
        if (this.postalCode.length == 0 || this.postalCode.length > 5) {
            this.isRunning = true;
            this.isLoader = false; // Added by saikiran as part of 16433
        }
    }

    handleShippingSuccess(result) {
        console.log('res', result);
        let res = result ? JSON.parse(result) : '';
        if (res && res.responseCode == '200' && res.isSuccess && this.isShipToMe == BOOLEAN_TRUE && res.errorMessage == '') {
            this.carieerCheck(res);
            if (this.shippingCost) {
                this.showSummary = true;
                this.showShippingDetails = true;
                sharedfile._servercall(
                    getTaxDetails, {
                    cartId: this.cartid,
                    CustomerPostalCode: this.postalCode,
                    ShippingCharges: this.shippingCost,
                    cartType: TYPE_CART
                },
                    this.handleTaxSuccess.bind(this),
                    this.handleTaxError.bind(this)
                );
            } else {
                this.showSummary = false;
                this.showspinner = false;
                this.isRunning = true;
                this.isLoader = false; // Added by saikiran as part of 16433
            }
        } else if (res && this.isShipToMe == BOOLEAN_TRUE && res.errorMessage !== '') {
            this.showSummary = true;
            this.showError = true;
            this.showspinner = false;
            this.isLoader = false; // Added by saikiran as part of 16433
            this.isRunning = true;
            this.errorMessage = res.errorMessage;
            //this.errorMessage = InvalidZipCodeError;
        } else {
            this.showSummary = false;
            this.showspinner = false;
            this.isLoader = false; // Added by saikiran as part of 16433
            this.showError = true;
            this.isRunning = true;
            this.errorMessage = InvalidZipCodeError;
        }
        this.error = undefined;
        console.log('total price : ', this.totalSubTotal);
        const selectedEvent = new CustomEvent('totalestimatedpricechange', { detail: { totalPrice: this.totalSubTotal } });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    carieerCheck(result) {
        let USPSshippingCost = result.serviceTypewithChargeMap[USPS_RETAIL_GROUND];
        let FEDEX_ShippingCost = result.serviceTypewithChargeMap.FEDEX_GROUND;
        let UPS_ShippingCost = result.serviceTypewithChargeMap[UPS_RETAIL_GROUND];
        this.shippingCost = USPSshippingCost ? parseFloat(USPSshippingCost).toFixed(2) : FEDEX_ShippingCost ? parseFloat(FEDEX_ShippingCost).toFixed(2) : UPS_ShippingCost ? parseFloat(UPS_ShippingCost).toFixed(2) : 0;
    }

    handleTaxSuccess(result) {
        console.log('res 2', result);
        let res = JSON.parse(result);
        if (res && res.responseCode == '200' && res.isSuccess) {
            if (res.totalTaxAmount) {
                this.showTaxDetails = true;
                this.showspinner = false;
                this.isLoader = false; // Added by saikiran as part of 16433
                this.isRunning = true;
                this.showTaxCalculationSpinner = false;
                this.taxAmount = (parseFloat(res.totalTaxAmount)).toFixed(2);
                let calculatedSubTotal = parseFloat(this._subTotal) + parseFloat(this._installationCharges) + parseFloat(this.taxAmount) + parseFloat(this.shippingCost);
                this.totalSubTotal = calculatedSubTotal.toFixed(2);
                this.isEstimatedTax = false; //Added by Faraz for HDMP-11537 on 29/07
            }
        } else {
            this.isEstimatedTax = true; //Added by shalini soni for R2B HDMP-8643
            this.showTaxDetails = false;
            this.showspinner = false;
            this.isLoader = false; // Added by saikiran as part of 16433
            this.isRunning = true;
            this.showError = true;
            this.showTaxCalculationSpinner = false;
            this.errorMessage = res.errorMessage;// added by saikiran
            //this.errorMessage = InvalidZipCodeError;
        }
        console.log('total price : ', this.totalSubTotal);
        const selectedEvent = new CustomEvent('totalestimatedpricechange', { detail: { totalPrice: this.totalSubTotal } });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handleTaxError(error) {
        this.error = error;
        this.isRunning = true;
        this.showTaxCalculationSpinner = false;
        this.isLoader = false; // Added by saikiran as part of 16433
    }

    handleShippingError(error) {
        console.log('handleShippingError ---' + handleShippingError);
        this.error = error;
        this.isRunning = true;
        this.isLoader = false; // Added by saikiran as part of 16433
    }

    get TaxDetails() {
        return this.showTaxDetails ? true : false;
    }

    setWarningMessage(message) {
        this.warningMessage = message;
    }

    setNull() {
        this.showShippingDetails = false;
        this.showTaxDetails = false;
        this.postalCode = '';
        sessionStorage.setItem(POSTAL_CODE, '');
    }
    //Below line of code added by Soumya to accomodate max limit of cart -25
    @api
    hideEstimatedCartBox() {
        getCartCountTotal({ cartId: this.cartid })
            .then(result => {
                //this.isLoader = true;commented as part of HDMP-16433
                //added by Yashika for 7996: starts
                if (result != 0 && getCurrentDealerId()) {
                    this.isDealerAndCart = true;
                }
                if (result == 0) {
                    this.isDealerAndCart = false;
                }

            })
            .catch(error => {
                console.error('Error:', error);
                //this.isLoader = false;commented as part of HDMP-16433
            });

    }
    renderedCallback() {
        if (!this.isDealerAndCart || this.template.querySelector('.go-button') == null)
            this.isLoader = this.showTaxCalculationSpinner;
    }

    // Pratik Added below function for Sales Juridications Sprint 4
    showDealerModal = false;
    disclaimerType = '';
    validatingSalesTax(zipCodeValue, dealerId) {

        validateZipCodeAndDealerTaxJurisdiction({ Accid: dealerId, state: '', zipcode: zipCodeValue, poiType: '', searchRadius: '', numberOfPOIs: '' })
            .then(result => {
                console.log('result for zipcode::' + JSON.stringify(result));
                if (!result) {
                    this.showDealerModal = true;
                    this.disclaimerType = 'zipCodeDisclaimer';
                    this.setNull();
                }
            })
            .catch(error => {
                console.log('Error' + JSON.stringify(error));
            });

    }

    // Pratik Added below function for Sales Juridications Sprint 4
    handleShowHide() {
        this.showDealerModal = false;
    }

    // Added by ashwin for wishlist
    @api handlesummaryDetails() {
        this.onPickUp = false;
    }
}
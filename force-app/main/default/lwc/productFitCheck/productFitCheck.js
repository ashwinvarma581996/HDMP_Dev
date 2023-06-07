/******************************************************************************* 

Name:  productFitCheck
Business Unit: HDM
Date: jun 2021
Developer: Sakshi
Description: This checks the VIN fitment on PDP and Cart page
******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
09-06-2022 | Yashika | Added header | 
16-08-2022 | Pradeep | codeforVincheck() | HDMP-11447

*******************************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import validateVIN from '@salesforce/apex/B2B_INSystemIntegration.ValidatePartsVIN';
import GetModelByVinDecoder from '@salesforce/apex/B2B_INSystemIntegration.GetModelByVinDecoder';
import getProductSKU from '@salesforce/apex/B2BGetInfo.ProductSKU';
import getCartItemCategory from '@salesforce/apex/B2B_VehicleSelectorController.getCartItemCategory';
import getMyVINProductList from '@salesforce/apex/B2B_MySavedProduct.getMyVINProductList';
import callVinDecoderService from '@salesforce/apex/B2B_EconfigIntegration.callVinDecoderService';
import getVehicleDetailsForAccessories from '@salesforce/apex/B2B_EconfigIntegration.getVehicleDetailsForAccessories';
import saveToMyProduct from '@salesforce/apex/B2B_MySavedProduct.saveToMyProduct';
import getCurrentCart from '@salesforce/apex/B2B_HandleCartAndUser.getCurrentCart';
import getLoginUrl from '@salesforce/label/c.Identity_Provider_Login_URL';
import getRegisterUrl from '@salesforce/label/c.Identity_Provider_Register_URL';
import updateCartItemVin from '@salesforce/apex/B2BGuestUserController.updateCartItemVin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//Added by deepak mali 2 March 2022
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import isguest from '@salesforce/user/isGuest';
import { getRecord } from 'lightning/uiRecordApi';
//END
//for adobe: starts
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';
//for adobe: ends
import communityId from '@salesforce/community/Id';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class ProductFitCheck extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;
    @track vincheck = false;
    @track productfit = false;
    @track productnotfit = false;
    @track compatible = false;
    @track VINapiResut;
    @track CheckValid = false;
    @track sku = [];
    @track Divisionid;
    @track productTypeAccessories = false;
    @track invalidvin = false;
    @track prodIdDefined;
    @track searchwithVIN;
    @track showLOader = false;
    @track vinErrorMessage = '';
    cartBrands;
    @track errorMessage = 'Please Enter Valid Vin';
    @track notAbleToDecode = false;
    @track vinCookievalue;
    @track showspinner = false;
    @track myProductOptions = [];
    @track myProductList = [];
    @track mfgColorCode = '';
    vin = '';
    @api pdppartnumber; // part number from pdp
    @api productsku; // SKU from Cart Page
    @api pdpproducttype;
    @api pdpproducttypeacc;
    @api cartid;
    @api vinValue;
    myProductData;

    @api isVinFitment = 'No';
    //Added by deepak mali 1 March 2022
    @track isGuest = isguest;

    //for adobe    
    @wire(MessageContext)
    messageContext;


    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuserdata({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            let userFirstName = data.fields.Name.value;
            if (USER_ID == undefined || USER_ID == null || userFirstName.includes('Guest')) {
                this.isGuest = true
            } else {
                this.isGuest = false;
            }
        }
    }
    //END

    // update vin var when input field value change
    @wire(getMyVINProductList)
    myProdcutListFromApex(result) {
        this.myProductData = result;
        if (result.data) {
            if (result && result.data.length > 0) {
                console.log('OUTPUTgg : ', result.data);
                let productListData = result.data;
                this.myProductList = productListData;
                let allProductList = [];
                // multiple cart issue 2 starts here
                //let brandName = localStorage.getItem('brand');
                let brandName = sessionStorage.getItem('brand');
                // multiple cart issue 2 ends here
                this.myProductList.forEach(element => {
                    if (brandName == element.Honda_Product__r.Product_Models__r.Product_Subdivision__c) {
                        allProductList.push({
                            label: element.Nickname__c ? element.Nickname__c : element.Honda_Product__r.Product_Models__r.Model_Year__c + ' ' + element.Honda_Product__r.Product_Models__r.Model_Name__c,
                            value: element.Id
                        })
                    }
                });
                this.myProductOptions = allProductList;
            } else {
                this.myProductOptions = false;
            }
        } else if (result.error) {
            console.error('error', result.error);
        }
    }

    CheckVin(event) {
        console.log('in pft', event)
        let vinLength = event.target.value;
        if (vinLength.length == 0) {
            this.ClearData();
        }

        let charCode = (event.which) ? event.which : event.keyCode;
        if (charCode == 13) {
            this.vin = event.target.value;
            this.submitVin();
        } else {
            this.vin = event.target.value;
            return false;
        }
    }


    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }

    get errorMsgDisplay() {
        return `${this.vinErrorMessage}`;
    }

    //Added by Palak - Login
    redirectToLoginPage() {
        getCurrentCart()
            .then((result) => {
                let pathURL;
                let finalURL;
                if (result !== null && result !== '') {
                    pathURL = '/s/splash?cartId=' + result + '&returnUrl=' + window.location.pathname;
                }
                else {
                    pathURL = '/s/splash?returnUrl=' + window.location.pathname;
                }
                let relayState = localStorage.getItem('relayStateUrl');
                if (relayState && window.location.href.includes('/s/category/')) {
                    localStorage.setItem('fromlogin', 'true');
                    relayState = relayState.substring(relayState.indexOf('/s/'));
                    localStorage.removeItem('relayStateUrl');
                    pathURL = '/s/splash?returnUrl=' + relayState;
                    finalURL = getLoginUrl + '&RelayState=' + pathURL;
                } else {
                    finalURL = getLoginUrl + '&RelayState=' + encodeURIComponent(pathURL);
                }
                //for adobe analytic: starts
                sessionStorage.setItem('eventsForAdobe', 'login success');
                let events = 'login initiation';
                let eventMetadata = {
                    action_type: 'link',
                    action_label: 'login',
                    action_category: 'login'//for adobe bug-17
                };
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events } };
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                //adobe: ends
                window.open(finalURL, '_self');
            })
            .catch((error) => {
                console.error('Error:', error);
            });

    }
    // Ends Here

    // Added by Palak - Register
    redirectToRegisterPage() {
        getCurrentCart()
            .then((result) => {
                let pathURL;
                if (result !== null && result !== '') {
                    pathURL = '/s/splash?cartId=' + result + '&returnUrl=' + window.location.pathname;
                }
                else {
                    pathURL = '/s/splash?returnUrl=' + window.location.pathname;
                }
                const finalURL = getRegisterUrl + '&RelayState=' + encodeURIComponent(pathURL);
                //for adobe analytic: starts
                sessionStorage.setItem('eventsForAdobe', 'registration success');
                let events = 'register initiation';
                let eventMetadata = {
                    action_type: 'link',
                    action_label: 'register',
                    action_category: 'register'//for adobe bug-17
                };
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events } };
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                //adobe: ends
                window.open(finalURL, '_self');
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }// Ends here


    submitVin() {
        this.showLOader = true;
        this.vincheck = false;
        this.productfit = false;
        this.productnotfit = false;
        this.compatible = false;
        this.invalidvin = false;
        this.showspinner = false;
        this.vinErrorMessage = '';
        this.searchwithVIN = false;

        validateVIN({
            division: this.Divisionid,
            vincode: this.vin,
            partnumbers: JSON.stringify(this.sku),
        })
            .then(result => {
                this.VINapiResut = JSON.parse(result);
                if (this.VINapiResut && this.VINapiResut.errorMessage && this.VINapiResut.errorMessage.toLowerCase().includes('unable to decode')) {
                    // this.errorMessage = 'We were not able to locate your model, please check with your dealer.';
                    this.showLOader = false;
                    this.notAbleToDecode = true;
                    this.invalidvin = true;
                } else {
                    // this.errorMessage = 'Please Enter Valid Vin';
                    this.notAbleToDecode = false;
                }
                if (this.VINapiResut.isError === true) {
                    console.log(' this.VINapiResut.isError: ' + this.VINapiResut.isError);
                    GetModelByVinDecoder({ vincode: this.vin, division: this.Divisionid }).then(result => {
                        let displayData = JSON.parse(result);
                        this.invalidvin = true;
                        if (displayData.isError) {
                            if (displayData.errorMessage) {
                                this.vinErrorMessage = displayData.errorMessage;
                            } else {
                                this.vinErrorMessage = '';
                            }
                            let errorMsg = '';
                            if (displayData.errorMessage && displayData.errorMessage.toLowerCase().includes("unable to decode vin at this time")) {
                                if (this.vin.length == 17) {
                                    errorMsg = 'VIN can\'t be decoded at this time, please select the additional model info to refine their vehicle search.';
                                } else if (this.vin.length == 10) {
                                    errorMsg = 'We\'re sorry, we are not able to determine your vehicle\'s model. Please use the model selector to search for products';
                                }
                            }
                            else if (displayData.errorMessage && (displayData.errorMessage.toLowerCase().includes("invalid acura vin") || displayData.errorMessage.toLowerCase().includes("invalid honda vin") || displayData.errorMessage.toLowerCase().includes("model does not exist"))) {
                                errorMsg = this.Divisionid && this.Divisionid == 1 ? 'You\'ve entered an Acura VIN, please select the Acura menu to search for those items' : 'You\'ve entered a Honda VIN, please select the Honda menu to search for those items';
                            }
                            else
                                errorMsg = 'Please enter valid VIN';
                            this.showLOader = false;
                            this.vinErrorMessage = errorMsg;
                        }
                    }).catch((error) => {
                        this.error = error;
                    });

                } else {
                    this.CheckValid = this.VINapiResut.Parts[0].IsValid;
                    if (this.CheckValid == true) {
                        this.productfit = true;
                        this.vincheck = true;
                        this.compatible = true;
                        this.isModalOpen = false;
                    } else {
                        this.isModalOpen = false;
                    }
                    if (this.compatible != true) {
                        this.productnotfit = true;
                        this.vincheck = true;
                    }
                    //Added Sakshi
                    const vinfittoparent = new CustomEvent("vinfitfromchild", {
                        detail: this.compatible
                    });
                    // Dispatches the event.
                    this.dispatchEvent(vinfittoparent);
                    if (typeof this.ProductId == 'undefined') {
                        this.callLocalStorage();
                    }
                    this.showLOader = false;
                    //Added by shalini soni 28 Feb 2022 for save vehicle when checkBox is checked
                    if (this.CheckValid == true) {
                        this.vinCookievalue = this.vin; //Added shalini for bug-8537
                        //Added by Deepak Mali 6 April 2022 Bug : 8536
                        // multiple cart issue 2 starts here
                        //let productBrand = localStorage.getItem('brand');
                        let productBrand = sessionStorage.getItem('brand');
                        // multiple cart issue 2 ends here
                        let VINFitmentValue = [];
                        VINFitmentValue = JSON.parse(localStorage.getItem('VINFitmentValue')) || [];
                        //added by Yashika for 8708: starts
                        localStorage.setItem('VINEntered', this.vin) // created this cookie to use entered VIN value not thr cookie one to use on PDP
                        let sku = JSON.parse(JSON.stringify(this.sku));
                        sku = sku[0];
                        if (this.cartid != undefined) {
                            updateCartItemVin({
                                sku: sku,
                                vin: this.vin, //will take this.vin and not cookie value because we want the respective entered vin to go to cartitem
                                cart: this.cartid
                            })
                                .then(result => {
                                    let cartItems = JSON.parse(JSON.stringify(result));
                                    this.dispatchEvent(
                                        new CustomEvent('vinchanged', {
                                            detail: cartItems,
                                            bubbles: true,
                                            composed: true
                                        })
                                    )
                                })
                                .catch(error => {
                                    console.log('pft error', error)
                                });
                        }
                        //8708: ends
                        let hasExist = false;
                        if (VINFitmentValue) {
                            VINFitmentValue.forEach(element => {
                                if (element.brandName == productBrand && element.vinValue == this.vin) {
                                    hasExist = true;
                                }
                            })
                        }
                        if (!hasExist) {
                            // multiple cart issue 2 starts here
                            //let brandVIN = { brandName: localStorage.getItem('brand'), vinValue: this.vin };
                            let brandVIN = { brandName: sessionStorage.getItem('brand'), vinValue: this.vin };
                            // multiple cart issue 2 ends here
                            VINFitmentValue.push(brandVIN);
                            localStorage.setItem('VINFitmentValue', JSON.stringify(VINFitmentValue));
                        }
                    }
                    //END
                    let saveProductCmp = this.template.querySelector('.savedProducts');
                    let checked = saveProductCmp ? saveProductCmp.checked : false;
                    if (checked == true) {
                        let productBrand = sessionStorage.getItem('brand');
                        let poihondavalue = productBrand == 'Honda' ? 'A' : 'B';
                        callVinDecoderService({ vinNumber: this.vin, poiType: poihondavalue }).then(result => {
                            let displayData = JSON.parse(result);
                            if (displayData && displayData.selectorDetail && displayData.selectorDetail.modelId) {
                                let modelId = displayData.selectorDetail.modelId;
                                if (displayData.selectorDetail && displayData.selectorDetail.colors) {
                                    let colorDate = JSON.parse(displayData.selectorDetail.colors);
                                    this.mfgColorCode = colorDate && colorDate.color && colorDate.color[1]['@mfg_color_cd'] ? colorDate.color[1]['@mfg_color_cd'] : '';
                                }
                                getVehicleDetailsForAccessories({ modelId: modelId.toString() }).then(vecResult => {
                                    if (vecResult) {
                                        let vehicleMapResult = JSON.parse(vecResult);
                                        let vehicleResult = JSON.parse(vehicleMapResult.vehicle);
                                        if (!vehicleResult) {
                                            return;
                                        }
                                        let yearValue = vehicleResult.Year__c;
                                        let modelValue = vehicleResult.Model__c;
                                        let trimValue = vehicleResult.Trim__c;
                                        let vinValue = '';
                                        if (this.vin) {
                                            vinValue = this.vin.substring(0, 6);
                                        }
                                        if (!(yearValue && modelValue && trimValue)) {
                                            return;
                                        }
                                        let name = yearValue + ' ' + modelValue;
                                        if (this.vin && this.vin.length) {
                                            let subVinValue = this.vin.substring(this.vin.length - 6);
                                            name += ' ' + trimValue + ' ' + subVinValue;
                                        } else {
                                            name += ' ' + trimValue;
                                        }
                                        saveToMyProduct({ vin: this.vin, trimModelId: modelId.toString(), nickname: name, mnfgColorCode: this.mfgColorCode })
                                            .then((result) => {
                                                if (result == 'Success') {
                                                    const evt = new ShowToastEvent({
                                                        title: 'Success',
                                                        message: 'Saved to My Product Successfully',
                                                        variant: 'success',
                                                    });
                                                    this.dispatchEvent(evt);
                                                } else if (result == 'Already Exists') {
                                                    let msg = this.vin.length ? 'A product with this VIN already exists in My Products.' : 'A product with this model already exists in My Products.';
                                                    const evt = new ShowToastEvent({
                                                        title: result,
                                                        message: msg,
                                                        variant: 'info',
                                                    });
                                                    this.dispatchEvent(evt);
                                                } else {
                                                    const evt = new ShowToastEvent({
                                                        title: 'Record not Saved!',
                                                        message: 'We\'re experiencing technical difficulties, please try again later.',
                                                        variant: 'error',
                                                    });
                                                    this.dispatchEvent(evt);
                                                    console.error(result);
                                                }
                                            })
                                            .catch((error) => {
                                                console.error(error.message);
                                            });
                                    }
                                }).catch(error => {
                                    console.error('error1 : ', error);
                                });
                            }
                        }).catch(error => {
                            console.error('error2 : ', error);
                        });
                    }
                }
            })
            .catch(error => {
                this.isModalOpen = false;
                this.showLOader = false;
            });
    }

    connectedCallback() {
        this.vincheck = false;
        console.log('inside product fit check', this.pdpproducttype)
        this.productfit = false;
        this.productnotfit = false;
        this.compatible = false;
        this.retrieveProductId();
        this.showspinner = false;
        // multiple cart issue 2 starts here
        //let productBrand = localStorage.getItem('brand');
        let productBrand = sessionStorage.getItem('brand');
        // multiple cart issue 2 ends here
        this.Divisionid = productBrand == 'Honda' ? 1 : 2;

        if (this.Divisionid == 1) {
            this.vinCookievalue = sessionStorage.getItem('HondaVin');
            if (this.vinCookievalue && this.vinCookievalue !== "")
                localStorage.setItem('VINEntered', this.vinCookievalue);

        }
        else if (this.Divisionid == 2) {
            this.vinCookievalue = sessionStorage.getItem('AcuraVin');
            if (this.vinCookievalue)
                localStorage.setItem('VINEntered', this.vinCookievalue);

        }
        if (typeof this.ProductId == 'undefined') { // if condition added by shalini 19 May 2022 for HDMP-9055
            this.vinCookievalue = this.vinValue;
        }

        /*  let temp = this.getCookie('VINFitValue');
          if ((temp == null || temp == '') && (this.vinCookievalue != null || this.vinCookievalue != '')) {
              this.vinCookievalue = '';
          } Commented by shalini on 20 May 2022 for HDMP-9055*/

        if (this.vinCookievalue) { //!= null || this.vinCookievalue != 'undefined' || this.vinCookievalue != ' ' ||  this.vinCookievalue != ''
            this.showspinner = true;
            this.searchwithVIN = true;
        }
        else {
            this.showspinner = false;
            this.searchwithVIN = false;
        }

        if (typeof this.ProductId != 'undefined') {
            this.prodIdDefined = true;
            getProductSKU({ productId: this.ProductId })
                .then(result => {
                    try {
                        if (result) {
                            this.pdppartnumber = result;
                        }
                        let temp1 = [];
                        if (this.pdppartnumber[0]) {
                            temp1.push(this.pdppartnumber[0].StockKeepingUnit);  // Added by deepak mali 18 Jan 2022 : HDMP-6817
                        }
                        this.sku = temp1;
                        if (typeof this.pdpproducttype == 'undefined' && typeof this.pdpproducttypeacc == 'undefined') {
                            setTimeout(() => {
                                this.codeforVincheck();
                            }, 2000);
                        }
                        else {
                            this.codeforVincheck();
                        }
                    } catch (error) {
                        console.error(error);
                    }
                })
                .catch((error) => {
                    this.error = error;
                });

        } else if (typeof this.ProductId == 'undefined') {
            this.prodIdDefined = false;
            this.pdppartnumber = this.productsku;
            let temp1 = [];
            temp1.push(this.pdppartnumber);
            this.sku = temp1;

            //--------------------

            let ChecklocalStorage1 = localStorage.getItem('VinFitmentCheck') != null ? true : false;
            if (ChecklocalStorage1 == true) {
                let tempcheck = JSON.parse(localStorage.getItem('VinFitmentCheck'));
                if (tempcheck != null && tempcheck != ' ' && tempcheck.hasOwnProperty(this.pdppartnumber)) {
                    if (tempcheck[this.pdppartnumber]) {
                        this.productfit = true;
                        this.vincheck = true;
                        this.compatible = true;
                        this.isModalOpen = false;
                        this.showspinner = false;
                    }
                    else {
                        if (typeof this.ProductId != 'undefined') { // if condition added by shalini 23 May 2022 for HDMP-9055
                            this.productnotfit = true;
                            this.vincheck = true;
                            this.isModalOpen = false;
                        }
                    }
                }
            }
            //HDMP-16050 starts here
            if (this.isVinFitment == 'Yes') {
                this.productfit = true;
                this.vincheck = true;
                this.compatible = true;
                this.isModalOpen = false;
                this.showspinner = false;
            }
            //HDMP-16050 ends here
            let checkcondition = this.compatible == false ? this.productnotfit == true ? false : true : false;
            if (checkcondition == false) {
                // already checked
            }
            else if (checkcondition == true) {
                if (this.vinCookievalue != null && this.vinCookievalue != '') {
                    validateVIN({
                        division: this.Divisionid,
                        vincode: this.vinCookievalue,
                        partnumbers: JSON.stringify(this.sku),
                    })
                        .then(result => {
                            this.VINapiResut = JSON.parse(result);

                            if (this.VINapiResut && this.VINapiResut.errorMessage && this.VINapiResut.errorMessage.toLowerCase().includes('unable to decode')) {
                                // this.errorMessage = 'We were not able to locate your model, please check with your dealer.';
                                this.notAbleToDecode = true;

                            } else {
                                // this.errorMessage = 'Please Enter Valid Vin';
                                this.notAbleToDecode = false;
                                this.CheckValid = this.VINapiResut.Parts[0].IsValid;

                                if (this.CheckValid == true) {
                                    this.productfit = true;
                                    this.vincheck = true;
                                    this.compatible = true;
                                    this.isModalOpen = false;
                                    this.showspinner = false;
                                } else {
                                    this.isModalOpen = false;
                                }
                                if (this.compatible != true) {
                                    this.productnotfit = true;
                                    this.vincheck = true;
                                }



                            }
                        })
                        .catch(error => {
                        });

                }

            }

        }
    }

    codeforVincheck() {
        if (this.pdpproducttype == 'Parts') {
            console.log('VinFitmentCheck', localStorage.getItem('VinFitmentCheck'))
            let ChecklocalStorage1 = localStorage.getItem('VinFitmentCheck') != null ? true : false;
            if (ChecklocalStorage1 == true) {
                let tempcheck = JSON.parse(localStorage.getItem('VinFitmentCheck'));
                if (tempcheck != null && tempcheck.hasOwnProperty(this.pdppartnumber)) {
                    if (tempcheck[this.pdppartnumber]) {
                        console.log('inside if// 547')
                        this.productfit = true;
                        this.vincheck = true;
                        this.compatible = true;
                        this.isModalOpen = false;
                        this.showspinner = false;
                    }
                    else {
                        console.log('inside else// 555')
                        this.productnotfit = true;
                        this.vincheck = true;
                        this.isModalOpen = false;
                    }
                }
                else if (tempcheck != null && tempcheck.hasOwnProperty(this.pdppartnumber[0].StockKeepingUnit)) {
                    if (tempcheck[this.pdppartnumber[0].StockKeepingUnit]) {
                        console.log('inside if// 563')
                        this.productfit = true;
                        this.vincheck = true;
                        this.compatible = true;
                        this.isModalOpen = false;
                        this.vinCookievalue = localStorage.getItem('VINEntered');//added by Yashika for 9679
                        this.showspinner = false;
                        //added by Yashika for 9679 for retaining the vin value also
                        const vinfittoparent = new CustomEvent("vinfitfromchild", {
                            detail: this.compatible
                        });
                        // Dispatches the event.
                        this.dispatchEvent(vinfittoparent); //done: 9679
                    }
                    else {
                        this.productnotfit = true;
                        this.vincheck = true;
                        this.isModalOpen = false;
                    }
                }
                else {
                    this.showspinner = false;
                }
            }
            else {
                let checkcondition = this.compatible == false ? this.productnotfit == true ? false : true : false;
                if (checkcondition == false) {
                    if (this.vinCookievalue == '') {
                        this.vincheck = false;
                        this.showspinner = false;
                        this.productfit = false;
                    }
                    // already checked
                }
                else if (checkcondition == true) {
                    if (this.vinCookievalue != null && this.vinCookievalue != '') {
                        validateVIN({
                            division: this.Divisionid,
                            vincode: this.vinCookievalue,
                            partnumbers: JSON.stringify(this.sku),
                        })
                            .then(result => {
                                this.VINapiResut = JSON.parse(result);

                                if (this.VINapiResut && this.VINapiResut.errorMessage && this.VINapiResut.errorMessage.toLowerCase().includes('unable to decode')) {
                                    // this.errorMessage = 'We were not able to locate your model, please check with your dealer.';
                                    this.notAbleToDecode = true;

                                } else {
                                    // this.errorMessage = 'Please Enter Valid Vin';
                                    this.notAbleToDecode = false;
                                    this.CheckValid = this.VINapiResut.Parts[0].IsValid;

                                    if (this.CheckValid == true) {
                                        this.productfit = true;
                                        this.vincheck = true;
                                        this.compatible = true;
                                        this.isModalOpen = false;
                                        this.showspinner = false;
                                    } else {
                                        this.isModalOpen = false;
                                    }
                                    if (this.compatible != true) {
                                        this.productnotfit = true;
                                        this.vincheck = true;
                                    }

                                    //Added Sakshi
                                    const vinfittoparent = new CustomEvent("vinfitfromchild", {
                                        detail: this.compatible
                                    });
                                    // Dispatches the event.
                                    this.dispatchEvent(vinfittoparent);
                                }
                            })
                            .catch(error => {
                                console.log('error', error)
                            });



                    }
                }
            }
        } else if (this.pdpproducttypeacc == 'Accessories' || this.pdpproducttype == 'Accessories') {
            this.productTypeAccessories = true;
            this.vincheck = true;

            this.productfit = false;
            this.productnotfit = false;
            this.showspinner = false;

            //LOCAL STORAGE

            let ChecklocalStorage = localStorage.getItem('VinFitmentCheck') != null ? true : false;
            if (ChecklocalStorage == true) {
                let NewArraytemp = JSON.parse(localStorage.getItem('VinFitmentCheck'));
                Object.defineProperty(NewArraytemp, this.pdppartnumber, {
                    value: true,
                    writable: true,
                    enumerable: true,
                    configurable: true
                })
                localStorage.setItem('VinFitmentCheck', JSON.stringify(NewArraytemp));
            }
        }
    }


    retrieveProductId() {
        var baseurl = window.location.href;
        var finalurl = baseurl.split('/');
        // this.ProductId = finalurl[finalurl.length - 1]; // 17 Jan commented for HDMP-6817
        let iscartPageURL = finalurl.find(element => element == 'cart');

        if (!iscartPageURL) {
            this.ProductId = finalurl[6] != undefined ? finalurl[6] : finalurl[5];  // Added by deepak mali 18 Jan 2022 : HDMP-6817
        } else {
            this.ProductId = undefined;
        }
        //End

    }

    getProductSKUMethod() {
        getProductSKU({
            productId: this.ProductId
        })
            .then(result => {
                this.pdppartnumber = result[0].StockKeepingUnit;
                let tempvar = [];
                tempvar.push(this.pdppartnumber);
                this.sku = tempvar;
            })
            .catch(error => {
                this.error = error;
            });


    }

    callLocalStorage() {
        //LOCAL STORAGE
        let ChecklocalStorage = localStorage.getItem('VinFitmentCheck') != null ? true : false;
        if (ChecklocalStorage == true) {
            let NewArraytemp = JSON.parse(localStorage.getItem('VinFitmentCheck'));
            Object.defineProperty(NewArraytemp, this.pdppartnumber, {
                value: this.compatible,
                writable: true,
                enumerable: true,
                configurable: true
            })
            localStorage.setItem('VinFitmentCheck', JSON.stringify(NewArraytemp));
        }

    }

    handelEnterVin() {
        this.notAbleToDecode = false;
        this.isModalOpen = true;
        this.invalidvin = false;
        refreshApex(this.myProductData);
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    ClearData() {
        this.invalidvin = false;
        this.vin = '';
        //Added by deepak mali 7 March 2022 for HDMP-8091
        this.template.querySelector('.savedProducts') ? this.template.querySelector('.savedProducts').checked = false : null;
        this.template.querySelector('.Products') ? this.template.querySelector('.Products').value = '' : null;
        //END

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
        //Updated by Pradeep Singh for Optiv Issue
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
        //Ends here
    }

    handleProductChange(event) {
        let selectedProduct = this.myProductList.find(element => element.Id == event.detail.value);
        this.vin = selectedProduct.Honda_Product__r.Product_Identifier__c;
    }

}
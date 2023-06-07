/*******************************************************************************
Name: RequiredProductModal
Business Unit: 
Created Date: 7/30/2021, 12:33 PM
Developer: Bhawesh Asudani
Description: LWC is created to handle UI for required accessories model.
*******************************************************************************

MODIFICATIONS – Date | Dev Name     | Method | User Story
                    | Deepak Mali | notifyToCustomCart | HDMP-5024
*******************************************************************************/

import { LightningElement, track, api, wire } from 'lwc';
import communityId from '@salesforce/community/Id';
import currentUserId from '@salesforce/user/Id';
import { getCurrentDealerId } from 'c/utils';
import addProductToCartItem_Clone from '@salesforce/apex/B2BGuestUserController.addProductToCartItem_Clone';
import getProduct from '@salesforce/apex/B2BGuestUserController.getProduct';
import getCartId from '@salesforce/apex/B2BGetInfo.getCartId';
import checkIfUserHasCartAndSetup from '@salesforce/apex/B2BGuestUserController.checkIfUserHasCartAndSetup';
import checkIfUserIsLoggedIn from '@salesforce/apex/B2BGuestUserController.checkIfUserIsLoggedIn';
import { NavigationMixin } from 'lightning/navigation';
import getAllProuctQuantity from '@salesforce/apex/B2BGetInfo.getAllProuctQuantity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';// Publish event added by Deepak Mali
import HDMP_MESSAGE_CHANNEL_2 from "@salesforce/messageChannel/HDMPMessageForCart__c";
import getModelId from '@salesforce/apex/B2BGuestUserController.getModelId';//added by Yashika for 8708
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';//for adobe analytics
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";//for adobe analytics

const PRODUCT_TYPE = 'Accessory';
export default class RequiredProductModal extends NavigationMixin(LightningElement) {
    @track opCodeAcc; //added by Yashika for 8137
    @track productImage;//added by Yashika for 8137
    @api requiredProductList = [];
    @api pricetype;
    @track showRequiredProductModal = false;
    cartId;
    selectedAccessoryName;
    showLoader = false;
    @track productModelMarketingName;
    @wire(MessageContext)
    messageContext2;

    //for adobe
    @wire(MessageContext)
    messageContext;
    connectedCallback() {
        // added on 11/12 start
        if (sessionStorage.getItem('VehicleName')) {
            this.year = sessionStorage.getItem('VehicleYear');
            this.model = sessionStorage.getItem('VehicleModel');
            this.trim = sessionStorage.getItem('VehicleTrim');
            this.vin = sessionStorage.getItem('VehicleVIN');
            this.productModelMarketingName = sessionStorage.getItem('VehicleName');
        }
        // added on 11/12 end
        // for multiple tab issue. starts here
        else if (localStorage.getItem("effectiveVehicle") && JSON.parse(localStorage.getItem("effectiveVehicle"))["brands"]) {
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
                this.productModelId = result.Product_Model_ID__c; //for adobe analytics
                }
            })
            .catch(error => { });
        this.fetchcartId();
    }

    closeRequiredProductDialog() {
        this.dispatchEvent(new CustomEvent('closerequiredproduct'));
    }

    handleToRedirectOnPDP(event) {
        let opId = event.target.dataset.id;
        let selectedAcc = this.requiredProductList.find(item => item.op_cd == opId);
        this.createCookie('selectedAccessorie', JSON.stringify(selectedAcc), 1);
        if (selectedAcc && selectedAcc.RequiredAccessories && selectedAcc.RequiredAccessories.length) {
            let requiredProductOpId = [];
            JSON.parse(JSON.stringify(selectedAcc.RequiredAccessories)).forEach(rp => {
                requiredProductOpId.push(rp.op_cd);
            });
            let newArray = this.requiredProductList.filter(acc => {
                return requiredProductOpId.includes(acc.op_cd);
            });
            this.createCookie('RequiredProducts', JSON.stringify(newArray));
        } else {
            this.createCookie('RequiredProducts', "", -1);
        }
        let colors = this.requiredProductList.find(item => item.op_cd == opId).Colors;
        colors = JSON.parse(JSON.stringify(colors));
        if (colors && colors.length && colors[0].part_number) {
            let partNumber = colors[0].part_number
            this.getProductIdAndRedirectToPDP(partNumber);
        }
    }

    getProductIdAndRedirectToPDP(selectedPartNumber) {
        getProduct({ productId: selectedPartNumber }).then(result => {
            if (result) {
                let productName = result.Name;
                let obj = { label: productName, name: productName, id: productName };
                let newArr = [];
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/product/' + result.Id
                    }
                });
            }
        }).catch(error => {
            //console.log(error);
        })
    }

    showToastMessages(title, variant, message) {
        this.dispatchEvent(new ShowToastEvent({ title: title, variant: variant, message: message, mode: 'dismissable' }));
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
        //updated by Pradeep Singh for Optiv Issue
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
        // ends here
    }

    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);
    }

    handleOnGoToCart() {
        if (this.cartId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/cart/' + this.cartId
                }
            });
        }
    }

    fetchcartId() {
        getCartId({ communityId: communityId })
            .then((cartId) => {
                this.cartId = cartId;
            })
            .catch((error) => {
                //console.log('getting error while fetching cart Id' , JSON.stringify(error));
            });
    }

    getPartNumber(opCode) {
        let colors = this.requiredProductList.find(item => item.op_cd == opCode).Colors;
        colors = JSON.parse(JSON.stringify(colors));
        if (colors && colors.length && colors[0].part_number) {
            return colors[0].part_number
        }
    }

    handleAddToCart(event) {
        let opCode = event.target.dataset.opcode;
        //added by Yashika for 8137:starts
        let assetMedium = event.target.dataset.medium;
        let assetThumb = event.target.dataset.thumb;
        this.productImage = assetMedium = '' ? assetMedium : assetThumb;
        this.opCodeAcc = opCode;
        //ends
        let price = event.target.dataset.price;
        let partNumber = opCode ? this.getPartNumber(opCode) : event.target.dataset.partnumber;
        this.showLoader = true;
        this.getProductQuan(partNumber, price);
        // Added by Sakshi :5006
        this.addLocalStorage(partNumber);
    }

    getProductQuan(partNumber, price) {
        getAllProuctQuantity({ cartId: this.cartId })
            .then((result) => {
                let prodWithQuantity = result;
                let proceedNext = false;
                let totalpartQuantity = 0;
                if (prodWithQuantity && Object.keys(prodWithQuantity).length != 0) {
                    for (var i in prodWithQuantity) {
                        totalpartQuantity += prodWithQuantity[i];
                        if (i == partNumber) {
                            let quantity = parseInt(prodWithQuantity[i]) + parseInt(1);
                            if (quantity > 50) {
                                this.isLoading = false;
                                this.showToastMessages('Quantity Limit', 'error', 'The Product cannot be added as its already in cart with its maximum quantity.');
                                break;
                            } else { proceedNext = true;; }
                        } else { proceedNext = true; }
                    }
                    // Added by Lakshman on 03/03/2022 - HDMP-5074 EPIC Starts
                    totalpartQuantity += parseInt(1);
                    if (totalpartQuantity > 25) {
                        this.showToastMessages('Quantity Limit', 'error', 'Sorry we can only have maximum of 25 quantity in an order.');
                        this.showLoader = false;
                        proceedNext = false;
                    }
                    // Added by Lakshman on 03/03/2022 - HDMP-5074 EPIC Ends
                } else {
                    localStorage.setItem('cartBrand', sessionStorage.getItem('brand'));
                    proceedNext = true;
                }
                if (proceedNext) {
                    this.cartAddition(partNumber, price);
                }
            })
            .catch((error) => {
                //console.log('getProductQuan error' , JSON.stringify(error));
            });
    }

    cartAddition(partNumber, price) {
        let selectedAcc = {};
        try {
            let existingallProductDetailsList = []
            let alreadyExistInList = false;
            existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));
            if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                existingallProductDetailsList.forEach(element => {
                    if (element && element.partNumber) { //for adobe
                    let elementNumber = element.partNumber.replace(/^"|"$/g, '');
                        console.log('setting acc name', element)
                    if (elementNumber == partNumber) {
                        this.selectedAccessoryName = element && element.selectedAcc && element.selectedAcc.AccessoryName ? element.selectedAcc.AccessoryName : '';
                            console.log('notifyAddToCart : ', this.selectedAccessoryName);
                        alreadyExistInList = true;
                        }
                    }
                });
            }
            if (!alreadyExistInList) {
                JSON.parse(JSON.stringify(this.requiredProductList)).forEach(everyAccessorie => {
                    let accessorie = JSON.parse(JSON.stringify(everyAccessorie));
                    let accPartNumber = accessorie && accessorie.Colors && accessorie.Colors.length && accessorie.Colors[0].part_number && accessorie.Colors[0].part_number != '' ? accessorie.Colors[0].part_number : '';
                    if (accPartNumber == partNumber) {
                        selectedAcc = everyAccessorie;
                        return;
                    }
                });
                let allAcccDetailsList = [];
                let productDetails = { SelectedPart: '', ProductNumber: '', SelectedBreadcrumbs: '', SubCategoryImageURL: '', partNumber: '', ProductType: '', ProductFromCart: false };
                productDetails.SelectedPart = '';
                productDetails.selectedAcc = selectedAcc;
                productDetails.ProductNumber = productDetails.SelectedBreadcrumbs = this.breadcrumbsList;
                productDetails.SubCategoryImageURL = productDetails.partNumber = JSON.stringify(partNumber);
                productDetails.ProductTypeForCart = 'Accessorie';
                productDetails.ProductFromCart = true;
                allAcccDetailsList.push(productDetails);
                this.selectedAccessoryName = selectedAcc && selectedAcc.AccessoryName ? selectedAcc.AccessoryName : '';
                let existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));
                if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                    existingallProductDetailsList.push(productDetails);
                    localStorage.setItem('allProductDetailsList', JSON.stringify(existingallProductDetailsList));
                } else {
                    localStorage.setItem('allProductDetailsList', JSON.stringify(allAcccDetailsList));
                }
            }
        } catch (error) {
            //console.log('error simple : ', error);
        }
        checkIfUserIsLoggedIn().then(result => {
            if (result) {
                checkIfUserHasCartAndSetup({ communityId: communityId, userId: result })
                    .then(result => {
                        if (result) {
                            this.cartId = result.cartId;
                            this.notifyAddToCart(partNumber, price, selectedAcc.AccessoryName);
                        }
                    })
                    .catch(error => {
                        //console.log(error);
                    });
            }
        }).catch(error => {
            //console.log(error);
        });
    }

    notifyAddToCart(partNumber, price, selectedAccessoryName) {
        let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
        if (localStorage.getItem('cartBrand') != sessionStorage.getItem('vehicleBrand')) {
            // this.handleIsLoading();
            // this.isModalOpen = true;
        } else {
            let findAccessory = JSON.parse(JSON.stringify(this.requiredProductList)).find((item) => {
                return item.op_cd == this.opCodeAcc
            });
            addProductToCartItem_Clone({
                accountId: getCurrentDealerId(),
                sku: partNumber,
                communityId: communityId,
                price: price,
                quantity: 1,
                accessoryName: this.selectedAccessoryName,
                color: '',
                productType: PRODUCT_TYPE, // Added by shalini soni for HDMP-5702 R2 Story
                accImageURL: this.productImage, //added By Yashika for 8137
                opCode: this.opCodeAcc, //added By Yashika for 8137
                brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290
                modelId: this.modelId, //added by Yashika for 8708 
                vin: this.vin, //added by Yashika for 8708
                productModelMarketingName: this.productModelMarketingName,
                itemPackageQuantity: findAccessory.quantity ? findAccessory.quantity : 1,
            }).then(result => {
                if (result.Id) {
                    this.notifyToCustomCart(); //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
                    this.showLoader = false;
                    this.dispatchEvent(new CustomEvent('cartchanged', { bubbles: true, composed: true }));
                    this.showToastMessages('Success', 'success', 'Product successfully added.');
                    getProduct({ productId: partNumber }).then(result => {
                        if (result) {
                            if (sessionStorage.getItem('breadcrumbsMap')) {
                                let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                                let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')))
                                breadcrumbsProductMap.set(result.Id, breadcrumbsMap.get(sessionStorage.getItem('brand')));
                                localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                            }
                        }
                    }).catch(error => {
                        console.log('msg-->', error);
                    })
                }
                //For adobe analytics : starts
                let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                breadcrumbs.push({ label: this.selectedAccessoryName });
                let eventMetadata = {
                    action_type: 'button',
                    action_label: 'add to cart',
                    action_category: 'accessories'
                };
                let events = 'scAdd';
                let addToCartProductDetails = {
                    breadcrumbs: breadcrumbs,
                    products: { StockKeepingUnit: partNumber },
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
                console.log('inside catch : ', error);
                this.showLoader = false;
            })
        }
    }

    // Added by Sakshi :5006
    addLocalStorage(partNumber) {
        let ChecklocalStorage = localStorage.getItem('VinFitmentCheck') != null ? true : false;
        if (ChecklocalStorage == true) {
            let NewArraytemp = JSON.parse(localStorage.getItem('VinFitmentCheck'));
            Object.defineProperty(NewArraytemp, partNumber, {
                value: true,
                writable: true,
                enumerable: true,
                configurable: true
            })
            localStorage.setItem('VinFitmentCheck', JSON.stringify(NewArraytemp));
        }
        /*HDMP-12342 starts here
        else {
            var cObj = {};
            Object.defineProperty(cObj, partNumber, {
                value: true,
                writable: true,
                enumerable: true,
                configurable: true
            })
            localStorage.setItem('VinFitmentCheck', JSON.stringify(cObj));
        } HDMP-12342 ends here*/
    }

    //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
    notifyToCustomCart() {
        try {
            // you can also pass like this object info her --> const message = { message: { 'dealerLabel': dealerLabel, 'products': products } 
            const message = { message: 'Calling for update cartItem count' };
            publish(this.messageContext2, HDMP_MESSAGE_CHANNEL_2, message);
        } catch (error) {
            console.error(error);
        }
    }
    //Ended
}
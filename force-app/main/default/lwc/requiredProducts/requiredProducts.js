/******************************************************************************* 
Name:  requiredProducts
Business Unit: HDM
Date: Jun 2021
Developer: Bhawesh
Description: This is for displaying products required to purchase and accessory

******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
09-06-2022 | Yashika | Added header | 

*******************************************************************************/
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import communityId from '@salesforce/community/Id';
import Id from '@salesforce/user/Id';
import checkIfUserIsLoggedIn from '@salesforce/apex/B2BGuestUserController.checkIfUserIsLoggedIn';
import getAllProuctQuantity from '@salesforce/apex/B2BGetInfo.getAllProuctQuantity';
import getCartItemBrand from '@salesforce/apex/B2BGetInfo.getCartItemBrand'; //added by Yashika for HDMP-16716
import createUserAndCartSetup from '@salesforce/apex/B2BGuestUserController.createUserAndCartSetup';
import checkIfUserHasCartAndSetup from '@salesforce/apex/B2BGuestUserController.checkIfUserHasCartAndSetup';
import getProduct from '@salesforce/apex/B2BGuestUserController.getProduct';
import addProductToCartItem_Clone from '@salesforce/apex/B2BGuestUserController.addProductToCartItem_Clone';
import createPermissions from '@salesforce/apex/B2BGuestUserController.createPermissionSetsSynchronous';
import { getCurrentDealerId } from 'c/utils';
import getCartId from '@salesforce/apex/B2BGetInfo.getCartId';
import addItem_Clone from '@salesforce/apex/B2BGuestUserController.addItem_Clone';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService'; // Publish event added by Deepak Mali
import HDMP_MESSAGE_CHANNEL_2 from "@salesforce/messageChannel/HDMPMessageForCart__c";
import getModelId from '@salesforce/apex/B2BGuestUserController.getModelId'; //added by Yashika for 8708
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';//for adobe analytics
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";//for adobe analytics

import hondaImages from '@salesforce/resourceUrl/honda_images';

const PRODUCT_TYPE = 'Accessory';
export default class RequiredProducts extends NavigationMixin(LightningElement) {
    @track opCode; //added by Yashika for 8137
    @track productImage; //added by Yashika for 8137
    @api requiredProductList = [];
    @api pricetype;
    @api shoppingBrand;
    allAccessoriesInfo;
    @track userId = Id;
    showCartCompatibilityError = false;
    cartId;
    selectedAccessoryNameForAddToCart;
    price;
    showLoader = false;

    //for adobe
    @wire(MessageContext)
    messageContext;

    @wire(MessageContext)
    messageContext2;
    @track productModelMarketingName;
    @track cartBrandDB = ''; //added by Yashika for HDMP-16716
    dreamshopDefaultImage = hondaImages + '/1200px-No_image_available.png';

    connectedCallback() {
        //added by Yashika for 8708: starts
        // for multiple tab issue. starts here
        if (localStorage.getItem("effectiveVehicle") && JSON.parse(localStorage.getItem("effectiveVehicle"))["brands"]) {
            let vehicleDetail = JSON.parse(localStorage.getItem("effectiveVehicle"))["brands"];
            if (vehicleDetail) {
                vehicleDetail.forEach(element => {
                    if (sessionStorage.getItem('vehicleBrand') === element.brand) {
                        this.year = element.year;
                        this.model = element.model;
                        this.trim = element.trim;
                        this.vin = element.vin;
                        this.productModelId = element.Model_Id__c;
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
                if (this.productModelId == '') {
                    this.productModelId = result.Product_Model_ID__c; //for adobe analytics
                }
            })
            .catch(error => { }); //ends: 8708
        let currURL = window.location.href;
        this.mainProductId = currURL ? currURL.substring(currURL.lastIndexOf('/') + 1, currURL.length) : '';
        this.mainProductURL = this.mainProductId ? window.location.origin + '/s/product/' + this.mainProductId : currURL;
        this.allAccessoriesInfo = JSON.parse(sessionStorage.getItem('accessories'))
        this.fetchcartId();
    }

    fetchcartId() {
        getCartId({ communityId: communityId })
            .then((result) => {
                this.cartId = result;
                this.getCartItemBrand(); //added by Yashika for HDMP-16716
            })
            .catch((error) => {
                //console.log('fetchcartId error'+ JSON.stringify(error));
            });
    }
    //added by Yashika for HDMP-16716: starts
    getCartItemBrand() {
        getCartItemBrand({ webcartId: this.cartId })
            .then(result => {
                if (result) {
                    let data = JSON.parse(result);
                    if (data && data.length && data[0].Product_Subdivision__c) {
                        this.cartBrandDB = data[0].Product_Subdivision__c;
                        localStorage.setItem('cartBrand', this.cartBrandDB);
                    }
                    // added on 11/12 start
                    else {
                        this.cartBrandDB = '';
                        localStorage.removeItem('cartBrand');
                    }
                }
                else {
                    this.cartBrandDB = '';
                    localStorage.removeItem('cartBrand');
                }
                // added on 11/12 end
            })
            .catch(error => {
            });
    }
    //16716: ends

    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);
    }

    handleSelectRequiredAccessory(event) {
        let opId = event.currentTarget.dataset.id;
        if (opId) {
            let selectedAcc = this.allAccessoriesInfo.Accessory.find(item => item.op_cd == opId);
            selectedAcc.AccessoryDesc = selectedAcc && selectedAcc.AccessoryDesc ? selectedAcc.AccessoryDesc.replace(/(<([^>]+)>)/ig, '') : '';
            this.createCookie('selectedAccessorie', JSON.stringify(selectedAcc), 1);
            if (selectedAcc && selectedAcc.RequiredAccessories && selectedAcc.RequiredAccessories.length) {
                let requiredProductOpId = [];
                JSON.parse(JSON.stringify(selectedAcc.RequiredAccessories)).forEach(rp => {
                    requiredProductOpId.push(rp.op_cd);
                });
                let newArray = this.allAccessoriesInfo.Accessory.filter(acc => {
                    return requiredProductOpId.includes(acc.op_cd);
                });
                localStorage.setItem('RequiredProducts', JSON.stringify(newArray));
            } else {
                localStorage.removeItem('RequiredProducts');
            }
            let selectedPartNum = this.getPartNumber(opId);
            getProduct({ productId: selectedPartNum }).then(result => {
                if (result) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: '/product/' + result.Id
                        }
                    });
                }
            }).catch(error => {
                //console.log(error);
            });
        }
    }

    getPartNumber(opCode) {
        let colors = this.allAccessoriesInfo.Accessory.find(item => item.op_cd == opCode).Colors;
        colors = JSON.parse(JSON.stringify(colors));
        if (colors && colors.length && colors[0].part_number) {
            return colors[0].part_number
        }
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

    handleAddToCart(event) {
        let partNumber = event.target.dataset.partnumber;
        this.selectedAccessoryNameForAddToCart = event.target.dataset.accessoryname;
        this.price = event.target.dataset.price;
        this.partNumber = partNumber;
        //added by Yashika for 8137 : starts
        this.opCode = event.target.dataset.opcode;
        let assetMedium = event.target.dataset.medium;
        let assetThumb = event.target.dataset.thumb;
        this.productImage = assetMedium = '' ? assetMedium : assetThumb;
        //ends
        if (this.cartId) {
            this.getProductQuan(partNumber);
        } else {
            this.updateQuantity();
        }
        // Added by Sakshi :5006
        this.addLocalStorage();
    }

    async getProductQuan(partNumber) {
        this.showLoader = true;
        getAllProuctQuantity({ cartId: this.cartId })
            .then((result) => {
                let prodWithQuantity = result;
                let proceedNext = false;
                let totalpartQuantity = 0;
                if (prodWithQuantity && Object.keys(prodWithQuantity).length != 0) {
                    for (var i in prodWithQuantity) {
                        totalpartQuantity += parseInt(prodWithQuantity[i]);
                        try {
                            if (i == partNumber) {
                                let quantity = parseInt(prodWithQuantity[i]) + parseInt(1);
                                let totalQuantity = parseInt(prodWithQuantity[i]) + (1);
                                if (totalQuantity > 50) {
                                    proceedNext = false;
                                    break;
                                } else { proceedNext = true; }
                            } else { proceedNext = true; }
                        } catch (error) {
                            //console.error(error.message);
                        }
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
                    this.updateQuantity();
                }
            })
            .catch((error) => {
                //console.log('getProductQuan error' + JSON.stringify(error));
            });
    }

    updateQuantity() {
        this.showLoader = true;
        checkIfUserIsLoggedIn().then(result => {
            if (result) {
                this.userId = result;
                checkIfUserHasCartAndSetup({ communityId: communityId, userId: this.userId })
                    .then(result => {
                        if (result) {
                            this.cartId = result.cartId;
                            this.getCartItemBrand();
                            this.notifyAddToCart();
                        }
                    })
                    .catch(error => {
                        //console.log(error);
                    });
            } else {
                let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
                createUserAndCartSetup({ accountId: getCurrentDealerId() }).then(result => {
                    let userRecord = result.userId;
                    let cartId = result.cartId;
                    let currentPageURL = window.location.href;
                    let findAccessory = JSON.parse(JSON.stringify(this.requiredProductList)).find((item) => {
                        return item.op_cd == this.opCode
                    });
                    //added by Yashika for 8137 : two parameters in addItem_Clone: opcode and productImage
                    createPermissions({ userId: userRecord }).then(result => {
                        addItem_Clone({
                            userId: userRecord, productId: this.partNumber, quantity: 1, redirectUrl: this.mainProductURL,
                            wc: cartId, accessoryName: this.selectedAccessoryNameForAddToCart, color: '', productType: PRODUCT_TYPE,
                            accImageURL: this.productImage, opCode: this.opCode, brand: storeBrand, modelId: this.modelId, vin: this.vin,
                            productModelMarketingName: this.productModelMarketingName, itemPackageQuantity: findAccessory.quantity ? findAccessory.quantity : 1,
                        }).then(redirectUrl => {
                            localStorage.setItem('cartBrand', sessionStorage.getItem('brand'));
                            this.showLoader = false;
                            if (sessionStorage.getItem('breadcrumbsMap')) {
                                let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                                let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')))
                                breadcrumbsProductMap.set(this.partNumber, breadcrumbsMap.get(sessionStorage.getItem('brand')));
                                localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                                window.location.replace(redirectUrl);
                            }
                            //For adobe analytics : starts
                            let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                            let eventMetadata = {
                                action_type: 'button',
                                action_label: 'add to cart',
                                action_category: 'accessories'
                            };
                            let events = 'scAdd';
                            let addToCartProductDetails = {
                                breadcrumbs: breadcrumbs,
                                products: { StockKeepingUnit: this.partNumber },//for adobe bug
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
                            //console.log(error);
                            this.showLoader = false;
                        })
                    }).catch(error => {
                        //console.log(error);
                        this.showLoader = false;
                    })
                }).catch(error => {
                    //console.log(error);
                    this.showLoader = false;
                })
            }
        });

        //Added Shalini Soni 8 Oct
        try {
            //Added by Shalini 90799
            let existingallProductDetailsList = []
            let alreadyExistInList = false;
            existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));
            if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                existingallProductDetailsList.forEach(element => {
                    let elementNumber = element.selectedAcc.partNumber.replace(/^"|"$/g, ''); //Remove double qcuotes from partNumber
                    if (elementNumber == this.partNumber) {
                        alreadyExistInList = true;
                    }
                });
            }
            if (!alreadyExistInList) {
                let selectedRequiredAccessories = {};
                //Only we have to fill selected required acc from the list
                this.requiredProductList.forEach(element => {
                    let elementNumber = element.partNumber;
                    if (elementNumber == this.partNumber) {
                        selectedRequiredAccessories = element;
                    }
                });
                let allAcccDetailsList = [];
                let productDetails = { SelectedPart: '', ProductNumber: '', SelectedBreadcrumbs: '', SubCategoryImageURL: '', partNumber: '', ProductType: '', ProductFromCart: false };
                productDetails.SelectedPart = '';
                productDetails.selectedAcc = selectedRequiredAccessories; //Added For ADP
                productDetails.ProductNumber =
                    productDetails.SelectedBreadcrumbs = '';
                productDetails.SubCategoryImageURL =
                    productDetails.partNumber = JSON.stringify(this.partNumber);
                productDetails.ProductTypeForCart = 'Accessorie';
                productDetails.ProductFromCart = true;
                allAcccDetailsList.push(productDetails);
                let existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));
                if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                    existingallProductDetailsList.push(productDetails);
                    localStorage.setItem('allProductDetailsList', JSON.stringify(existingallProductDetailsList));
                } else {
                    localStorage.setItem('allProductDetailsList', JSON.stringify(allAcccDetailsList));
                }
            }
        } catch (error) {
            //alert(error.message);
        }
        //Ended
    }

    notifyAddToCart() {
        let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
        if (localStorage.getItem('cartBrand') != sessionStorage.getItem('vehicleBrand')) {
            this.showLoader = false;
            this.showCartCompatibilityError = true;
        } else {
            let findAccessory = JSON.parse(JSON.stringify(this.requiredProductList)).find((item) => {
                return item.op_cd == this.opCode
            });
            addProductToCartItem_Clone({
                accountId: getCurrentDealerId(),
                sku: this.partNumber,
                communityId: communityId,
                price: this.price,
                quantity: parseInt(1),
                accessoryName: this.selectedAccessoryNameForAddToCart,
                color: '',
                productType: PRODUCT_TYPE, // Added by shalini soni for HDMP-5702 R2 story
                accImageURL: this.productImage, //added by Yashika for 8137
                opCode: this.opCode, //added by Yashika for 8137
                brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290
                modelId: this.modelId, //added by Yashika for 8708 
                vin: this.vin, //added by Yashika for 8708
                productModelMarketingName: this.productModelMarketingName,
                itemPackageQuantity: findAccessory.quantity ? findAccessory.quantity : 1,
            }).then(result => {
                if (result.Id) {
                    this.notifyToCustomCart(); //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
                    this.dispatchEvent(new CustomEvent('cartchanged', { bubbles: true, composed: true }));
                    if (sessionStorage.getItem('breadcrumbsMap')) {
                        let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                        let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')))
                        breadcrumbsProductMap.set(this.productid, breadcrumbsMap.get(sessionStorage.getItem('brand')));
                        localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                        this.showLoader = false;
                    }
                    //For adobe analytics : starts
                    let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                    breadcrumbs.push({ label: this.selectedAccessoryNameForAddToCart });
                    console.log('breadcrumb on req product', breadcrumbs)
                    let eventMetadata = {
                        action_type: 'button',
                        action_label: 'add to cart',
                        action_category: 'accessories'

                    };
                    let events = 'scAdd';
                    let addToCartProductDetails = {
                        breadcrumbs: breadcrumbs,
                        products: { StockKeepingUnit: this.partNumber },//for adobe bug
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
                }
            }).catch(error => {
                //console.log(error);
            })
        }
    }

    // Added by Sakshi :5006
    addLocalStorage() {
        let ChecklocalStorage = localStorage.getItem('VinFitmentCheck') != null ? true : false;
        if (ChecklocalStorage == true) {
            let NewArraytemp = JSON.parse(localStorage.getItem('VinFitmentCheck'));
            Object.defineProperty(NewArraytemp, this.partNumber, {
                value: true,
                writable: true,
                enumerable: true,
                configurable: true
            })
            localStorage.setItem('VinFitmentCheck', JSON.stringify(NewArraytemp));
        } else {
            var cObj = {};
            Object.defineProperty(cObj, this.partNumber, {
                value: true,
                writable: true,
                enumerable: true,
                configurable: true
            })
            localStorage.setItem('VinFitmentCheck', JSON.stringify(cObj));
        }
    }

    closeCartCompatibilityPopup() {
        this.showCartCompatibilityError = false;
    }

    //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
    notifyToCustomCart() {
        try {
            // you can also pass like this object info her --> const message = { message: { 'dealerLabel': dealerLabel, 'products': products } 
            const message = { message: 'Calling for update cartItem count' };
            publish(this.messageContext2, HDMP_MESSAGE_CHANNEL_2, message);
        } catch (error) {
            //console.error(error);
        }
    }
    //Ended
}
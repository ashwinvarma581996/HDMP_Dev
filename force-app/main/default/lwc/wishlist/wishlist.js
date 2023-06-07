/******************************************************************************* 
Name: wishlist 
Business Unit: HDM
Date: Jan, 2022
Description: This component is wishlist page.

******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
25-08-2022 | Yashika |  | 
22-02-2023  | Aditya Saini | Added Reman Text | HDMP-16502

*******************************************************************************/
import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import communityId from '@salesforce/community/Id';
import addProductToCartItem_Clone from '@salesforce/apex/B2BGuestUserController.addProductToCartItem_Clone';
import Id from '@salesforce/user/Id';
import { getCurrentDealerId, getCurrentDealer } from 'c/utils';
import getCartItemsCount from '@salesforce/apex/B2BGetInfo.getCartItemsCount';
import getCartId from '@salesforce/apex/B2BGetInfo.getCartId';
import getProduct from '@salesforce/apex/B2BGuestUserController.getProduct';
import getWishlistItem from '@salesforce/apex/B2B_GetWishlistItems.getWishlistItem';
import createWishlistError from '@salesforce/apex/B2B_LoggedInUserWishlist.createWishlistError';
import updateWishlistItem from '@salesforce/apex/B2B_LoggedInUserWishlist.updateWishlistItem';
import getCartItemBrand from '@salesforce/apex/B2BGetInfo.getCartItemBrand';
import removeItemFromList from '@salesforce/apex/B2B_LoggedInUserWishlist.removeItemFromList';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageForCart__c";
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import GetDealerPrice from '@salesforce/apex/B2B_INSystemIntegration.GetDealerPrice'; //for 7911
import imageResourcePath from '@salesforce/resourceUrl/honda_images';
import getCartItems from '@salesforce/apex/B2B_LoggedInUserWishlist.getCartItems';
import hondaImages from '@salesforce/resourceUrl/honda_images';
import getModelDetails from '@salesforce/apex/B2B_LoggedInUserWishlist.getModelDetails';
import checkCurrentUserIsGuest from '@salesforce/apex/B2BMyPerferencesController.checkCurrentUserIsGuest';
import HDMP_MESSAGE_CHANNEL_ADOBE from "@salesforce/messageChannel/HDMPMessageChannel__c";//for adobe analytics
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';//for adobe analytics
import Reman_text from '@salesforce/label/c.B2B_Reman_Part_Identification_Label'; // Added By Ashwin as fix of 18588
import logdbDataError from '@salesforce/apex/B2B_DataErrorLogger.logdbDataError'; //Added by Vivek for HDMP-18897,HDMP-18897
import logAPIDataError from '@salesforce/apex/B2B_DataErrorLogger.logAPIDataError';//Added by Vivek for HDMP-18913


export default class Wishlist extends NavigationMixin(LightningElement) {
    carImage = imageResourcePath + '/carImage.jpeg';
    userId = Id;
    @track wishItemId;
    @track color;
    @track productType;
    @track isDataNotAvailable;
    @track cartId;
    @track productPartNumber;
    @track removeItemId;
    @track brand;
    @track opCode;
    @track productName;
    minQuan = 'Minimum Quantity is 1';
    maxQuan = 'Maximum Quantity is 25';
    quantityUpdated = false;
    @track partnumber;
    sku;
    refreshTable;
    @track partsList = [];
    prodWithQuantity;
    isLoading = false;
    _invalidQuantity = false;
    _quantityFieldValue = 1;
    @track wishlistRecord;
    @track isItemDeleted = false;
    @track partsList;
    isMaintenance = false;
    selectedPartNameForSave = '';
    @track returnURL;
    @track hotSpots;
    @track productHotspotMap = [];
    @api priceType;
    @api breadcrumbsList;
    @track productMap = new Map();
    subscription = null;
    // isLoading = false;
    @track userId = Id;
    @track isModalOpen = false;
    @track isPorductNotExistModalOpen = false;
    @track imgURL;
    @track cartItemCount = 0;
    @track cartBrandDB = '';
    dreamshopDefaultImage = hondaImages + '/1200px-No_image_available.png';

    disclaimerType; // Added by Aditya as a part of HDMP-16502 Development
    showDealerModal = false; // Added by Aditya as a part of HDMP-16502 Development
    coreCharge;//Aditya bug 17802
    dataErrorMessage = ''; //Added by Vivek for HDMP-18897,HDMP-18897



    // Started By Ashwin as fix of 18588
    label = {
        Reman_text
    }
    //Ended by ashwin as fix of 18588

    @api
    get productList() {
        //return this.productList;
    }
    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        checkCurrentUserIsGuest({})
            .then(result => {
                if (result == false) {
                    this.getWishlistItemRelated();
                    this.fetchcartId();
                }
                else {
                    console.log('in else')
                    window.location.replace(window.location.origin); //added if else for AMS 178 by Yashika
                }
            })
    }
    @wire(getCartId, { communityId: communityId })
    wiredData({ error, data }) {
        if (data) {
            this.cartId = data;
        } else if (error) {

        }
    }

    getProducts(partNumber, price) {
        getCartItemsCount({ cartId: this.cartId })
            .then((result) => {
                this.cartItemCount = result;
                let quan = parseInt(this._quantityFieldValue) + parseInt(this.cartItemCount);
                if (quan > 25) {
                    this.handleIsLoading();
                    this.showToastMessages('Quantity Limit', 'error', 'Sorry we can only have maximum of 25 quantity in an order.');
                } else {
                    this.addFromWishlist(partNumber, price);
                }
            })
            .catch((error) => { });
    }
    submitDetails() {
        this.isModalOpen = false;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    handleIsLoading() {
        this.isLoading = !this.isLoading;
    }
    quantityChange(event) {
        let quantity = event.target.value;
        let qtyCmp = this.template.querySelector(".qty");
        let qtyvalue = qtyCmp.value;

        if (qtyvalue.includes('.')) {
            qtyCmp.setCustomValidity("Enter a valid value.");
        } else {
            qtyCmp.setCustomValidity("");
        }
        qtyCmp.reportValidity()

        let validQuantity = [...this.template.querySelectorAll('.qty')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (validQuantity) {
            this.quantityUpdated = true;
        } else {
            this.quantityUpdated = false;
        }

    }
    handleQuantitySelectorBlur(blurEvent) {
        this.isLoading = true;
        let validQuantity = [...this.template.querySelectorAll('.qty')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        const wishItemId = blurEvent.target.dataset.id;
        let quantity;
        let quan = Array.from(this.template.querySelectorAll('.qty')).filter((element) => {
            if (element.dataset.id == wishItemId) {
                quantity = element.value;
            }
        });
        if (validQuantity) {
            if (this.quantityUpdated) {
                updateWishlistItem({ wishItemId: wishItemId, quantity: quantity, userId: this.userId })
                    .then(result => {
                        if (result) {
                            this.wishlistRecord = result
                            console.log('here are weeeee ', JSON.stringify(this.wishlistRecord))
                            let currentBrand = sessionStorage.getItem('dealerSiteBrand');
                            let wishItems = [];
                            this.wishlistRecord.forEach(element => {
                                if (element.productImage__c && element.productImage__c.includes('/1200px-No_image_available.png')) {
                                    element.productImage__c = this.dreamshopDefaultImage;
                                }
                                if (element.Product_Type__c == 'Motocompacto') {
                                    element.productType__c = false;
                                }
                                else {
                                    element.productType__c = true;
                                }

                                //below condition Added by ashwin for 19501
                                alert(element.Product2.Product_availability__c)
                                if (element.Price__c <= 0 || element.Product2.Product_availability__c == 'Not Available' || element.Core_Charge_Unit_Price__c <= 0) {
                                    element.disableAddtoCart__c = 'true';
                                }

                                //Lakshmi removed Product.isActive==false 
                                if ((currentBrand && currentBrand != element.Product_Subdivision__c) || (element.Product2.Product_availability__c == 'Not Available')) {
                                    wishItems.push({ ...element, disableAddtoCart__c: 'true' })
                                } else {
                                    wishItems.push({ ...element })
                                }




                            })
                            this.wishlistRecord = wishItems;
                            this.isLoading = false;

                            console.log('here are weeeee2222 ', JSON.stringify(this.wishlistRecord))
                        }
                    }).catch(error => {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: 'We are experiencing technical difficulties. Please try again later.',
                            variant: 'Error'
                        }));

                    });
            } else {
                this.isLoading = false;
            }
        } else {
            this.isLoading = false;
        }

    }



    async fetchcartId() {
        await getCartId({ communityId: communityId })
            .then((result) => {
                this.cartId = result;

            })
            .catch((error) => {

            });
    }
    //added for HDMP-16716
    async getCartItemBrand(partNumber, price) {
        let flag = false;
        await getCartItemBrand({ webcartId: this.cartId })
            .then(result => {
                if (result) {
                    let data = JSON.parse(result);
                    if (data && data.length) {
                        //added by Yashika for scenario: to take cart brand on basis of Honda/Acura product and not on motocompacto
                        data.forEach(element => {
                            if (element.Product_Type__c != 'Motocompacto') {
                                this.cartBrandDB = element.Product_Subdivision__c;
                                console.log('cartBrand from DB', this.cartBrandDB)
                                localStorage.setItem('cartBrand', this.cartBrandDB);
                                flag = true;

                            }
                        });
                        if (flag == false) { //req condition if there is only motocompacto product in cart
                            if (data && data.length && data[0].Cart.Product_Subdivision__c) {
                                this.cartBrandDB = data[0].Cart.Product_Subdivision__c;
                                console.log('cartBrand  ', this.cartBrandDB)
                                localStorage.setItem('cartBrand', this.cartBrandDB);
                            }
                        }
                    }
                    // added on 11/12 start
                    // else {
                    //     this.cartBrandDB = '';
                    //     localStorage.removeItem('cartBrand');
                    // }
                    this.notifyAddToCart(partNumber, price);
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
    //HDMP-16716: ends

    getWishlistItemRelated() {
        getWishlistItem({ recordId: this.userId }).then(result => {
            if (result) {
                this.wishlistRecord = result;

                if (result.length == 0) {
                    this.isDataNotAvailable = true;
                } else {
                    this.isDataNotAvailable = false;
                }
            }
            let currentBrand = sessionStorage.getItem('dealerSiteBrand');
            let wishItems = [];
            this.wishlistRecord.forEach(element => {
                if (element.productImage__c && element.productImage__c.includes('/1200px-No_image_available.png')) {
                    element.productImage__c = this.dreamshopDefaultImage;
                }
                if (element.Product_Type__c == 'Motocompacto') {
                    element.productType__c = false;
                }
                else {
                    element.productType__c = true;
                }
                // Ashwin Removed && (element.Product2.IsActive == true) for bug 18862
                if ((currentBrand && currentBrand != element.Product_Subdivision__c) || (element.Product2.Product_availability__c == 'Not Available') || (element.Price__c == 0) || (element.Core_Charge_Unit_Price__c == 0) || (element.Core_Charge_Unit_Price__c == null && element.Name.includes(Reman_text))) {//Aditya HDMP-16502 //Added for HDMP-18889 - Vivek M
                    wishItems.push({ ...element, disableAddtoCart__c: 'true' })
                } else {
                    wishItems.push({ ...element })
                }
                //Added by vivek M for HDMP-18897,HDMP-18899 This works for reman and non reman parts
                if ((element.Price__c == 0 || element.Price__c == null) && element.Name.includes(Reman_text)) {//Added for bug HDMP-18897 - Vivek M
                    console.log('Data error logging MSRP');
                    this.dataErrorMessage += '\n Error: Wishlist Data present in SF DB has Unitprice/MSRP: ' + element.Price__c + ' for  product : ' + element.Product2Id + ' for Wishlist ' + element.WishlistId;
                }
                if ((element.Core_Charge_Unit_Price__c == 0 || element.Core_Charge_Unit_Price__c == null) && element.Name.includes(Reman_text)) {//||element.Core_Charge_Unit_Price__c==null)&&element.Name.includes(Reman_text
                    console.log('Data error logging Core charge');
                    this.dataErrorMessage += '\nError: Wishlist Data present in SF DB has Core Charges: ' + element.Core_Charge_Unit_Price__c + ' for  product : ' + element.Product2Id + ' for Wishlist ' + element.WishlistId;
                }
                //End of changes by vivek M for HDMP-18897,HDMP-18899
            })
            this.wishlistRecord = wishItems;
            if (this.dataErrorMessage) { this.addToSFDBErrorLog(); }//Added by vivek M for HDMP-18897,HDMP-18899
        })
            .catch((error) => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'We are experiencing technical difficulties. Please try again later.',
                    variant: 'Error'
                }));

            });
    }

    handleShowDefaultImage(event) {
        let erroredIndex = event.currentTarget.dataset.index;
        this.wishlistRecord[erroredIndex].productImage__c = false;
    }

    handleRemoveItem(event) {

        this.removeItemId = event.target.dataset.id;
        removeItemFromList({
            removeItemId: this.removeItemId,
            userId: this.userId
        }).then(result => {
            this.wishlistRecord = result;
            if (result.length == 0) {
                this.isDataNotAvailable = true;
            } else {
                let wishItems = [];
                let currentBrand = sessionStorage.getItem('dealerSiteBrand');
                this.wishlistRecord.forEach(element => {
                    if (element.productImage__c && element.productImage__c.includes('/1200px-No_image_available.png')) {
                        element.productImage__c = this.dreamshopDefaultImage;
                    }
                    if (element.Product_Type__c == 'Motocompacto') {
                        element.productType__c = false;
                    }
                    else {
                        element.productType__c = true;
                    }


                    //below condition Added by ashwin for 19525
                    if (element.Price__c <= 0 || element.Product2.Product_availability__c == 'Not Available' || element.Core_Charge_Unit_Price__c <= 0) {
                        element.disableAddtoCart__c = 'true';
                    }


                    // Lakshmi Removed  && (element.Product2.IsActive == false) for 19438
                    if (((currentBrand && currentBrand != element.Product_Subdivision__c) || (element.Product2.Product_availability__c == 'Not Available'))) {
                        wishItems.push({ ...element, disableAddtoCart__c: 'true' })
                    } else {
                        wishItems.push({ ...element })
                    }
                })
                this.wishlistRecord = wishItems;
                this.isDataNotAvailable = false;
            }
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Item Removed successfully',
                variant: 'success'
            }));
        })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'We are experiencing technical difficulties. Please try again later.',
                    variant: 'Error'
                }));
            })

    }

    async handleAddToCart(event) {//for adobe bug-50(added async)
        this.handleIsLoading();
        this.color = event.target.dataset.color;
        this.productPartNumber = event.target.dataset.partnumber;
        this.productType = event.target.dataset.type;
        let partNumber = event.target.dataset.partnumber;
        this.partNumber = event.target.dataset.partnumber;
        this.brand = event.target.dataset.brand;
        this.productName = event.target.dataset.name;
        this.imgURL = event.target.dataset.img;
        this.wishItemId = event.target.dataset.id;
        this.opCode = event.target.dataset.code;
        this.productModelMarketingName = event.target.dataset.modelname;
        this.vin = event.target.dataset.vin;
        this.modelId = event.target.dataset.modelid;
        this.itemPckgQuantity = event.target.dataset.packagequan;
        this.secId = event.target.dataset.secid;
        this.illGrp = event.target.dataset.illgrp;
        this.illId = event.target.dataset.illid;
        this.coreCharge = event.target.dataset.core; //Aditya bug 17802
        let quan = Array.from(this.template.querySelectorAll('.qty')).filter((element) => {
            if (element.dataset.id == this.wishItemId) {
                this._quantityFieldValue = element.value;
            }
        });

        this.Price__c = event.target.dataset.price;
        let price = this.Price__c;

        await getModelDetails({ modelId: this.modelId }).then(result => {//for adobe bug-50(added await )
            this.productModelId = result.Product_Model_ID__c;//for adobe bug-14
            this.year = result.Model_Year__c;
            this.model = result.Model_Name__c;
            this.trim = result.Trim__c
        }).catch(error => { })
        this.fetchcartId();
        await getCartItems({
            cartId: this.cartId,
            sku: this.partNumber
        })
            .then(result => {
                if (result.length != 0) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: 'This item is already in your shopping cart',
                        variant: 'Error'
                    }));
                    this.isLoading = false;
                } else {
                    this.getCartItemBrand(partNumber, price);
                }
            })

    }


    notifyAddToCart(partNumber, price) {
        this.getProducts(partNumber, price);
    }

    async addFromWishlist(partNumber, price) {
        //condition modified for HDMP-16716

        if ((this.productType != 'Motocompacto') && ((this.cartItemCount != 0 && localStorage.getItem('cartBrand') != this.brand) || (this.cartBrandDB && this.cartBrandDB.length && this.cartBrandDB != this.brand))) {
            this.handleIsLoading();
            this.isModalOpen = true;
        }

        else {
            //let dealer = getCurrentDealer();
            let brand = localStorage.getItem('cartBrand');
            console.log('brand', brand)
            let brands = [];
            if (localStorage.getItem('effectiveDealer')) {
                brands = JSON.parse(localStorage.getItem('effectiveDealer'))['brands'];
                console.log('eff dealer', brands)
                if (brands) {
                    brands.forEach(element => {
                        if (brand === element.brand) {
                            this.dealer = element;
                            this.dealerId = element.id;
                        }
                    });
                }
            }
            let dealer = this.dealer;
            console.log('dealer', dealer)
            if (dealer != undefined) {
                let iNDivisionID__c = this.brand == 'Honda' ? 1 : 2;
                let parts = [];
                parts.push(partNumber);
                let codes = [];
                codes.push(this.opCode);
                if (parts.length > 0 || codes.length > 0) {
                    if (this.productType == 'Part') {
                        await GetDealerPrice({
                            dealerNo: dealer.dealerNo,
                            divisionId: iNDivisionID__c,
                            partNumbers: JSON.stringify(parts),
                        }).then(result => {
                            if (result) {
                                let dealerPriceResult = JSON.parse(result);
                                if (dealerPriceResult.Parts) {
                                    price = dealerPriceResult.Parts[0].DIYPrice;
                                    //Added by Vivek M for HDMP-18913
                                    if (price == 0 || price == null) {
                                        //let item = this.wishlistRecord.find(item => item.Product2.StockKeepingUnit == partNumber);
                                        //console.log(' Item found with price 0' + JSON.stringify(item));
                                        //if (item.Name.includes(Reman_text)) //Need to add this once Remanufactured word is added for record name  
                                        this.addToAPIErrorLog(price, partNumber);
                                    }
                                    //End of code added by Vivek M for HDMP-18913
                                }

                            }
                        })
                            .catch(error => {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Error',
                                    message: 'We are experiencing technical difficulties fetching the dealer Price. Please try again later.',
                                    variant: 'Error'
                                }));
                            })
                    } else {
                        await GetDealerPrice({
                            dealerNo: dealer.dealerNo,
                            divisionId: iNDivisionID__c,
                            partNumbers: JSON.stringify(parts),
                            accessories: JSON.stringify(codes)
                        }).then(result => {
                            if (result) {
                                let dealerPriceResult = JSON.parse(result);
                                if (dealerPriceResult.Accessories) {
                                    price = dealerPriceResult.Accessories[0].DIYPrice;
                                }
                            }

                        })
                            .catch(error => {
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Error',
                                    message: 'We are experiencing technical difficulties fetching the dealer price. Please try again later.',
                                    variant: 'Error'
                                }));
                            })
                    }
                }
            }
            //added for solving cross brand association of motocompacto. This will solve the conflict of taking cart brand from database.
            if (this.productType == 'Motocompacto' && this.cartBrandDB != undefined && this.cartBrandDB != null && this.cartBrandDB != '') {
                this.brand = this.cartBrandDB;
            }
            // Added By Ashwin for 16543
            let wishRec = this.wishlistRecord.find(item => item.Id === this.wishItemId);

            if ((price == 0 || price == 0.00) && 'Core_Charge_Unit_Price__c' in wishRec) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: 'We’re unable to add this item to your shopping cart for the selected dealer. Please try again later.',
                    variant: 'Error'
                }));
                this.isLoading = false;



                createWishlistError({
                    errMsg: 'We’re unable to add this item to your shopping cart for the selected dealer. Please try again later.',
                    response: response,
                    recordId: this.wishItemId
                })
                    .then((result) => {
                    })
                    .catch((error) => { });
            }
            // ended By Ashwin for 16543
            else {
                addProductToCartItem_Clone({
                    accountId: this.dealerId,
                    sku: partNumber,
                    communityId: communityId,
                    price: price,
                    quantity: this._quantityFieldValue,
                    color: this.color,
                    accessoryName: this.productName, //this.selectedPartNameForSave,
                    productType: this.productType,
                    accImageURL: this.imgURL,
                    opCode: this.opCode, //for 7911
                    brand: this.brand, // Added by shalini 10-3-2022 for HDMP-8290
                    modelId: this.modelId, //added by Yashika for 8708
                    vin: this.vin, //added by Yashika for 8708
                    productModelMarketingName: this.productModelMarketingName, //added by Yashika for 10179
                    itemPackageQuantity: this.itemPckgQuantity,
                    sectionId: this.secId,
                    IllustrationId: this.illId,
                    IllustrationImageId: this.illGrp,
                    coreCharge: this.coreCharge //Aditya bug 17802
                }).then(result => {
                    if (this.cartItemCount == 0) {
                        localStorage.setItem('cartBrand', this.brand);
                        sessionStorage.setItem('brand', this.brand); //Added by shalini soni for bug 8304

                    }
                    //For adobe analytics : starts
                    let eventMetadata = {
                        action_type: 'button',
                        action_label: 'add to cart',
                        action_category: 'my account-my wishlist'//for adobe bug-43
                    };
                    let addToCartProductDetails = {
                        breadcrumbs: [{ label: this.productName }],
                        products: { StockKeepingUnit: partNumber },
                        context: {
                            brand: this.brand,
                            Model_Id__c: this.productModelId,
                            model: this.model,
                            year: this.year,
                            trim: this.trim
                        }
                    }
                    let events = 'move to cart,scAdd';
                    const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'addToCartProductDetails': addToCartProductDetails, 'events': events } };
                    publish(this.messageContext, HDMP_MESSAGE_CHANNEL_ADOBE, message);
                    //  adobe analytics : end
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'Item added to cart successfully',
                        variant: 'success'
                    }));

                    removeItemFromList({
                        removeItemId: this.wishItemId,
                        userId: this.userId
                    }).then(result => {
                        this.wishlistRecord = result;
                        let wishItems = [];
                        let currentBrand = sessionStorage.getItem('dealerSiteBrand');
                        this.wishlistRecord.forEach(element => {
                            if (element.productImage__c && element.productImage__c.includes('/1200px-No_image_available.png')) {
                                element.productImage__c = this.dreamshopDefaultImage;
                            }
                            if (element.Product_Type__c == 'Motocompacto') {
                                element.productType__c = false;
                            }
                            else {
                                element.productType__c = true;
                            }
                            // Lakshmi removed && (element.Product2.IsActive != true)
                            if (((currentBrand && currentBrand != element.Product_Subdivision__c) || (element.Product2.Product_availability__c == 'Not Available'))) {
                                wishItems.push({ ...element, disableAddtoCart__c: 'true' })
                            } else {
                                wishItems.push({ ...element })
                            }
                        })
                        this.wishlistRecord = wishItems;

                        if (result.length == 0) {
                            this.isDataNotAvailable = true;
                        } else {
                            this.isDataNotAvailable = false;
                        }

                    })
                    this.notifyToCustomCart();
                    if (result.Id) {
                        this.dispatchEvent(
                            new CustomEvent('cartchanged', {
                                bubbles: true,
                                composed: true
                            })
                        );
                        getProduct({
                            productId: partNumber
                        }).then(result => {
                            if (result) {
                                if (sessionStorage.getItem('breadcrumbsMap')) {
                                    let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                                    let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')))
                                    breadcrumbsProductMap.set(result.Id, breadcrumbsMap.get(sessionStorage.getItem('brand')));

                                }
                            }
                        }).catch(error => { })
                        this.handleIsLoading();
                    }
                }).catch(error => {
                    console.log(error);
                    this.handleIsLoading();
                })

            }
        }
    }

    notifyToCustomCart() {
        const message = { message: 'Calling for update cartItem count' };
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
    }
    showToastMessages(title, variant, message) {
        this.dispatchEvent(new ShowToastEvent({ title: title, variant: variant, message: message, mode: 'dismissable' }));
    }
    showDealerModal = false;
    // START Added by Aditya as a part of HDMP-16502 Development
    handleDisclamerPopup(event) {
        this.disclaimerType = event.currentTarget.dataset.id;
        this.showDealerModal = true;
    }
    handleShowHide(event) {
        this.showDealerModal = false;
    }
    // END Added by Aditya as a part of HDMP-16502 Development
    //Added by Vivek M for HDMP-18913
    addToAPIErrorLog(price, partNumber) {
        let errorMessage = '\nERROR: On Wishlist Page Dealer pricing API returned DIYPrice="' + price + '" for part ' + partNumber;
        console.log('Errors to log ' + errorMessage);
        logAPIDataError({ errorMessage: errorMessage, messageType: 'Dealer pricing API Data erorr' })
            .then(errId => {
                console.log('Error logged in Table ' + errId);
            }).catch(error => console.log('Error log update failure' + error));
    }
    //End of code added by Vivek M for HDMP-18913
    //Added by vivek M for HDMP-18897,HDMP-18899
    addToSFDBErrorLog() {
        console.log('Errors to log ' + this.dataErrorMessage);
        logdbDataError({ errorMessage: this.dataErrorMessage, messageType: 'SF DB API Data error' })
            .then(errId => {
                console.log('Error logged in Table ' + errId);
                this.dataErrorMessage = '';
            }).catch(error => console.log('Error log update failure' + error));
    }
    //End of changes by vivek M for HDMP-18897,HDMP-18899
}
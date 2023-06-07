import { LightningElement, wire, track } from 'lwc';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';
import jQuery from '@salesforce/resourceUrl/JQuery';
import { loadScript } from 'lightning/platformResourceLoader';
import communityId from '@salesforce/community/Id';
import isguest from '@salesforce/user/isGuest'
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import CIAM_USER_ID from '@salesforce/schema/User.CIAM_User_ID__c';
import { publish, subscribe, MessageContext } from 'lightning/messageService'; //for adobe
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageForCart__c";
import getCartId from '@salesforce/apex/B2BGetInfo.getCartId';
import getCartItemsCount from '@salesforce/apex/B2BGetInfo.getCartItemsCount';
import basePath from "@salesforce/community/basePath";
import getLoginUrl from '@salesforce/label/c.Identity_Provider_Login_URL';
import getRegisterUrl from '@salesforce/label/c.Identity_Provider_Register_URL';
import indentityBaseUrl from '@salesforce/label/c.Identity_Provider_Base_URL';
import indentityAppId from '@salesforce/label/c.Identity_Provider_App_Id';
//import getExternalIpServerCall from '@salesforce/apex/LWC_Utils.getExternalIp';
import cartToActive from '@salesforce/apex/B2BCartControllerSample.cartToActive';
import getCurrentCart from '@salesforce/apex/B2B_HandleCartAndUser.getCurrentCart';
import getUserDetails from '@salesforce/apex/B2B_ShoppingSelectionController.getUserDetails';
import getLastDealers from '@salesforce/apex/B2B_ShoppingSelectionController.getLastDealers';
import getActiveCartItems from '@salesforce/apex/B2BGuestUserController.getActiveCartItems';
import GetDealerPrice from '@salesforce/apex/B2B_INSystemIntegration.GetDealerPrice';
import updateCartItems from '@salesforce/apex/B2BGuestUserController.updateCartItems';
import saveLastDealer from '@salesforce/apex/B2B_ShoppingSelectionController.saveLastDealer';
import getAddedProductsInfo from '@salesforce/apex/B2B_GetCurrentProductController.getAddedProductsInfo';//Added by Faraz for HDMP-10203
import updateMyCartItems from '@salesforce/apex/B2B_GetCurrentProductController.updateCartItems';//Added by Faraz for HDMP-10203
import moveInactiveItemsToWishList from '@salesforce/apex/B2B_HandleCartAndUser.moveInactiveItemsToWishList';
import saveLastShoppingSelection from '@salesforce/apex/B2B_ShoppingSelectionController.saveLastShoppingSelection';
import HDMP_MESSAGE_CHANNEL_ADOBE from "@salesforce/messageChannel/HDMPMessageChannel__c";//for adobe
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';//for adobe

import getCategoryId from '@salesforce/apex/B2B_GetCurrentProductController.getCategoryId';//Added By Imtiyaz
import getVehicleDetailsByModelID from '@salesforce/apex/B2B_GetCurrentProductController.getVehicleDetailsByModelID';//Added By Imtiyaz
const POSTAL_CODE = 'PostalCode';

export default class HeaderComponent extends LightningElement {
    isGuestUser = isguest;
    dreamShopLogoURL = imageResourcePath + '/dreamshop.png';
    hondaLogoURL = imageResourcePath + '/honda.png';
    communityBaseURL = window.location.origin;
    @track isLoading = false;
    @track userFirstName = '';
    @track count;
    @track cartItemCount = 0;
    @track message = '';
    @track cartId;
    @track cartTitle;
    @track myAddressbookUrl;
    @track myDealersUrl;
    @track orderhistoryUrl;
    @track myPaymentsUrl;
    @track mypreferencesUrl;
    @track userRecord;
    @track myWishlistUrl; //added by Yashika for wishlist story
    @track myProductsUrl;
    subscription = null;
    @track loginUrlLink;
    @track sfdcBaseURL = window.location.origin + '/s/findmyorder';
    @track showLogoutModal;
    isJQueryLoad = false;
    idleTime = 0;
    userData;
    @track cartUrl;
    //Testing 

    @wire(MessageContext)
    messageContext;


    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD, CIAM_USER_ID] })
    wireuserdata({ error, data }) {
        if (error) {
            this.error = error;
            console.error('Error:', error);
        } else if (data) {
            this.userData = data;
            let userFirstName = data.fields.Name.value;
            if (USER_ID == undefined || USER_ID == null || userFirstName.includes('Guest')) {
                this.isGuestUser = true;
            } else {
                this.userRecord = data;
                this.userFirstName = data.fields.Name.value;
                this.isGuestUser = false;
                this.handleMoveInactiveItems();
                this.handleGetCurrentProduct();//Added by Faraz for HDMP-10203
                this.handleSaveLastShoppingSelection();
            }
        }
    }
    //Added by deepak mali 9 March 2022
    async setCartSetup() {
        await this.updateCartStatus();
        await this.getCartIdDetails();
    }

    getCartIdDetails() {
        getCartId({ communityId: communityId })
            .then((result) => {
                this.cartId = result;
                this.cartUrl = window.location.origin + '/s/cart/' + this.cartId;
                localStorage.setItem('cartId', this.cartId);
                this.getProducts();
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }

    //Ends




    async getProducts() {
        await getCartItemsCount({ cartId: this.cartId })
            .then((result) => {
                this.cartItemCount = result;
                if (result) {
                    this.cartTitle = 'Cart: ' + this.cartItemCount + ' items';
                } else {
                    this.cartTitle = 'Cart: empty';
                }
            })
            .catch((error) => {
                //console.error('Error:', error);
            });
    }

    //Added by deepak mali 
    updateCartStatus() {
        cartToActive({ userId: USER_ID })
            .then((result) => {
            })
            .catch((error) => { console.log(' error', error) });
    }
    //Ends
    connectedCallback() {
        this.myAddressbookUrl = window.location.origin + '/s/myaddressbook';
        this.myDealersUrl = window.location.origin + '/s/my-dealers';
        this.orderhistoryUrl = window.location.origin + '/s/order-history';
        this.myPaymentsUrl = window.location.origin + '/s/my-payments';
        this.mypreferencesUrl = window.location.origin + '/s/mypreferences';
        this.myWishlistUrl = window.location.origin + '/s/my-wishlist';
        this.myProductsUrl = window.location.origin + '/s/my-products';
        this.subscribeToMessageChannel();
        this.setCartSetup();
        this.handleLastDealer();
    }

    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }


    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            HDMP_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    // Handler for message received by component
    async handleMessage(data) {
        if (data.message) {
            await this.setCartSetup();
            this.message = data.message;
        }
    }


    /* Commented By Soumya
        redirectToLoginPage() {
            getExternalIpServerCall({ currentGuestCartId: this.cartId })
                 .then((result) => {
                    // Added by Pradeep
                    let pathURL;
                    if(window.location.pathname.includes('/cart/')){
                        pathURL = '/s/validate-user?cartId='+this.cartId;;
                    }
                    else{
                        pathURL = window.location.pathname;
                    }
                    const relayStateUrl = getLoginUrl + '&RelayState=' + pathURL;
            this.loginUrlLink = relayStateUrl;
                    window.open(this.loginUrlLink, '_self');
                 })
                 .catch((error) => {
                     console.error('Error:', error);
                 });   
    
            //const relayStateUrl = getLoginUrl + '&RelayState=' + window.location.href;
    
            //this.loginUrlLink = relayStateUrl;
    
    
        }
    
    */

    handleLoginDynamic() {


        getCurrentCart()
            .then((result) => {
                let pathURL;
                if (result !== null && result !== '') {
                    pathURL = '/s/splash?cartId=' + result + '&returnUrl=' + window.location.pathname;
                }
                else {
                    pathURL = '/s/splash?returnUrl=' + window.location.pathname;
                }
                const finalURL = getLoginUrl + '&RelayState=' + encodeURIComponent(pathURL);

                //for adobe analytic: starts
                sessionStorage.setItem('eventsForAdobe', 'login success');
                let events = 'login initiation';
                let eventMetadata = {
                    action_type: 'link',
                    action_label: 'login',
                    action_category: 'global-header-navigation'
                };
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events } };
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL_ADOBE, message);
                //adobe: ends
                window.open(finalURL, '_self');
            })
            .catch((error) => {
                console.error('Error=>:', error);
            });
    }

    handleRegisterDynamic() {


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
                    action_category: 'global-header-navigation'
                };
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events } };
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL_ADOBE, message);
                //adobe: ends
                window.open(finalURL, '_self');
            })
            .catch((error) => {
                console.error('Error:', error);
            });

    }
    /* Commented by Soumya- cart management
        redirectToRegisterPage() {
            // Added by Pradeep
            getExternalIpServerCall({ currentGuestCartId: this.cartId })
            .then((result) => {
                let pathURL;
                if(window.location.pathname.includes('/cart/')){
                    pathURL = '/s/validate-user?cartId='+this.cartId;
                }
                else{
                    pathURL = window.location.pathname;
                }
                
                const finalURL = getRegisterUrl + '&RelayState=' + pathURL;
            window.open(finalURL, '_self');
            })
            .catch((error) => {
                console.error('Error:', error);
            });
            //ends here
        } ends here  */

    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
        return sitePrefix + "/secur/logout.jsp";

    }

    redirectToProfileUrl() {
        let CIAM_UserID = getFieldValue(this.userRecord, CIAM_USER_ID);
        const profilURL = indentityBaseUrl + '/s/profile/' + CIAM_UserID + '?app=' + indentityAppId + '&RelayState=' + window.location.href;;
        window.open(profilURL, '_self');
    }

    openCart() {
        if (this.cartId) {
            window.open('/s/cart/' + this.cartId, '_self');
        }
    }

    onLogout() {
        sessionStorage.setItem(POSTAL_CODE, '');
        sessionStorage.removeItem('selectedSpeed');//Added as part of HDMP-16298

        //Start - Added by Imtiyaz[Oct-3-2022] to clear the cache and cookies at logout
        this.clearCacheAndCookies();
        //End - Added by Imtiyaz[Oct-3-2022]
    }

    renderedCallback() {
        if (!this.isGuestUser && !this.isJQueryLoad && this.userFirstName.length && !this.userFirstName.includes('Guest')) {
            let self = this;
            self.isJQueryLoad = true;
            loadScript(this, jQuery)
                .then(() => {
                    try {
                        $(document).ready(function () {
                            $(window).click(function () {
                                self.idleTime = 0;
                            })
                            $(window).keyup(function () {
                                self.idleTime = 0;
                            })
                            let idleInterval = setInterval(timerIncrement, 60000);
                        });

                        function timerIncrement() {
                            self.idleTime = self.idleTime + 1;
                            if (self.idleTime == 110) {
                                self.showLogoutModal = true;
                            }
                            if (self.idleTime == 120) {
                                self.logoutUser();
                                alert("Your session has expired due to no activity.");
                            }
                        };
                    } catch (error) {
                        console.log('JERROR : ', error);
                    }
                }).catch((error) => {
                    console.log('CERROR', error);
                });
        }
    }
    logoutUser() {
        this.onLogout();
        window.location.href = this.logoutLink;
    }
    handleLogoutModal() {
        this.showLogoutModal = false;
        this.idleTime = 0;
    }
    //Added by Imtiyaz[Oct-3-2022] to clear the all cache and cookies
    clearCacheAndCookies() {
        localStorage.clear();
        sessionStorage.clear();
        document.cookie.split(";").forEach(function (c) { document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date().toUTCString() + ";path=/"); });
    }

    handleLastDealer() {
        if (!isguest) {
            if (USER_ID) {
                getUserDetails({ userId: USER_ID }).then((result) => {
                    if (result && result.Name && !result.Name.toLowerCase().includes('guest')) {

                        if (!sessionStorage.getItem('brand') && !localStorage.getItem('cartBrand')) {
                            sessionStorage.setItem('brand', result.Email);
                            localStorage.setItem('cartBrand', result.Email);
                        }
                        let cartBrandDB = result.Email && result.Email != null ? result.Email : null;

                        let isFirstLoad = sessionStorage.getItem('isFirstLoad');
                        if (!isFirstLoad) {
                            sessionStorage.setItem('isFirstLoad', 'true');
                            isFirstLoad = sessionStorage.getItem('isFirstLoad');
                        }
                        if (isFirstLoad && isFirstLoad == 'true' && (this.setGuestHasDealer('GET') == 'false' || !this.setGuestHasDealer('GET'))) {
                            sessionStorage.setItem('isFirstLoad', 'false');
                            getLastDealers().then((res) => {
                                // multiple cart issue 2 starts here
                                //let brand = sessionStorage.getItem('brand') ?? localStorage.getItem('cartBrand');
                                let brand = sessionStorage.getItem('brand');
                                if (cartBrandDB) {
                                    brand = cartBrandDB;
                                    localStorage.setItem('cartBrand', brand);
                                }
                                // multiple cart issue 2 ends here
                                let brandDivision = brand == 'Honda' ? 1 : 2;
                                if (res) {
                                    let brands = [];
                                    let currentDealer;
                                    res.forEach(dealer => {
                                        let dealerObj = { 'id': dealer.Id, 'label': dealer.Name, 'dealerNo': dealer.PoIId__c };
                                        dealerObj.brand = dealer.DivisionCd__c == 'A' ? 'Honda' : 'Acura';
                                        brands.push(dealerObj);
                                        if (brand == dealerObj.brand) {
                                            currentDealer = dealer;
                                        } else {
                                        }
                                    });


                                    localStorage.setItem('effectiveDealer', JSON.stringify({ 'brands': brands }));
                                    if (window.location.pathname.includes('/splash')) {
                                        sessionStorage.removeItem('isFirstLoad');
                                        return;
                                    }
                                    this.isLoading = true;
                                    let dealerNo = currentDealer ? currentDealer.PoIId__c : null;
                                    let effectiveAccountId = currentDealer ? currentDealer.Id.substring(0, 15) : null;
                                    let ifTrue = true;
                                    if (ifTrue) {
                                        getActiveCartItems({ communityId: communityId }).then((cartItems) => {
                                            if (cartItems && cartItems.length) {
                                                let partNumberList = [];
                                                const opCodeList = [];
                                                let opCodeAndPartNumberMap = new Map();
                                                let partNumberAndOpCodeMap = new Map();
                                                cartItems.forEach(element => {
                                                    partNumberList.push(element.Product2.StockKeepingUnit);
                                                    if (element.op_code__c) {
                                                        opCodeList.push(element.op_code__c);
                                                        opCodeAndPartNumberMap.set(element.op_code__c, element.Product2.StockKeepingUnit);
                                                        partNumberAndOpCodeMap.set(element.Product2.StockKeepingUnit, element.op_code__c);
                                                    }
                                                });
                                                let uniquePartNumberList = partNumberList.filter(function (item, index, inputArray) {
                                                    return inputArray.indexOf(item) == index;
                                                });
                                                let uniqueOpCodeList = opCodeList.filter(function (item, index, inputArray) {
                                                    return inputArray.indexOf(item) == index;
                                                });

                                                GetDealerPrice({
                                                    dealerNo: dealerNo,
                                                    divisionId: brandDivision,
                                                    partNumbers: JSON.stringify(uniquePartNumberList),
                                                    accessories: JSON.stringify(uniqueOpCodeList)
                                                }).then((resultDealerPrice) => {
                                                    resultDealerPrice = JSON.parse(resultDealerPrice);
                                                    let selectedartNumbers = [];
                                                    if (uniquePartNumberList && uniquePartNumberList.length && resultDealerPrice.Parts && resultDealerPrice.Parts.length) {
                                                        resultDealerPrice.Parts.forEach(everyPart => {
                                                            let obj = JSON.parse(JSON.stringify(everyPart));
                                                            let index = uniquePartNumberList.indexOf(obj.PartNumber);
                                                            if (index != -1 && !partNumberAndOpCodeMap.has(obj.PartNumber)) {
                                                                obj.DealerPrice = obj.DIYPrice;
                                                                selectedartNumbers.push(obj);
                                                            }
                                                        });
                                                    }
                                                    if (uniqueOpCodeList && uniqueOpCodeList.length && resultDealerPrice.Accessories && resultDealerPrice.Accessories.length) {
                                                        resultDealerPrice.Accessories.forEach(everyPart => {
                                                            let obj = JSON.parse(JSON.stringify(everyPart));
                                                            if (opCodeAndPartNumberMap.has(obj.OpCode)) {
                                                                obj.DealerPrice = obj.DIYPrice;
                                                                obj.PartNumber = opCodeAndPartNumberMap.get(obj.OpCode);
                                                                selectedartNumbers.push(obj);
                                                            }
                                                        });
                                                    }
                                                    let adToCart = {
                                                        accountId: effectiveAccountId,
                                                        communityId: communityId,
                                                        products: selectedartNumbers
                                                    };
                                                    updateCartItems({
                                                        adToCart: adToCart
                                                    }).then(resultUdatedItems => {
                                                        this.isLoading = false;
                                                        if (window.location.pathname.includes('/cart/')) {
                                                            window.location.reload();
                                                        }
                                                    }).catch(errorrUdatedItems => {
                                                        this.isLoading = false;
                                                        console.error('$HC-HLD: updateCartItems errorrUdatedItems-', errorrUdatedItems);
                                                    });
                                                }).catch((errorDealerPrice) => {
                                                    console.error('$HC-HLD: errorDealerPrice: ', errorDealerPrice);
                                                    this.isLoading = false;
                                                });
                                            } else {
                                                this.isLoading = false;
                                            }
                                        }).catch((error) => {
                                            console.error('$HC-HLD: getActiveCartItems error-', error);
                                            this.isLoading = false;
                                        });
                                    }
                                }
                            }).catch((error) => {
                                console.error('$HC-HLD: getLastDealer error-', error);
                            });
                        } else {
                            if (this.setGuestHasDealer('GET') == 'true' && !sessionStorage.getItem('dealerSaved')) {
                                let brand = sessionStorage.getItem('brand') ?? localStorage.getItem('cartBrand');
                                if (localStorage.getItem('effectiveDealer')) {
                                    let dealers = JSON.parse(localStorage.getItem('effectiveDealer'));
                                    if (dealers && dealers.brands) {
                                        dealers.brands.forEach(dlr => {
                                            saveLastDealer({ shoppingSelection: { Product_Subdivision__c: dlr.brand, Last_Dealer__c: dlr.id } }).then((result) => {
                                                console.log('$HC-HLD: saveLastDealer result', result);
                                            }).catch((error) => {
                                                console.error('$HC-HLD: saveLastDealer error', error);
                                            });
                                        });
                                    }
                                }
                                sessionStorage.setItem('dealerSaved', 'true');
                                if (localStorage.getItem('effectiveDealer')) {
                                    let localDealers = JSON.parse(localStorage.getItem('effectiveDealer'));
                                    if (localDealers.brands.length == 1) {
                                        getLastDealers().then((res) => {
                                            // multiple cart issue 2 starts here
                                            //let brand = sessionStorage.getItem('brand') ?? localStorage.getItem('cartBrand');
                                            let brand = sessionStorage.getItem('brand');
                                            // multiple cart issue 2 ends here
                                            brand = brand == 'Honda' ? 'Acura' : 'Honda';
                                            if (res) {
                                                let dealerObj;
                                                let oneTime = true;
                                                res.forEach(dealer => {
                                                    let brnd = dealer.DivisionCd__c == 'A' ? 'Honda' : 'Acura';
                                                    if (brand == brnd && oneTime) {
                                                        dealerObj = { 'id': dealer.Id, 'label': dealer.Name, 'dealerNo': dealer.PoIId__c, brand: dealer.DivisionCd__c == 'A' ? 'Honda' : 'Acura' };
                                                        oneTime = false;
                                                    }
                                                });
                                                if (dealerObj) {
                                                    localDealers.brands.push(dealerObj);
                                                    localStorage.setItem('effectiveDealer', JSON.stringify({ 'brands': localDealers.brands }));
                                                }
                                            }
                                        }).catch((error) => {
                                            console.error('$HC-HLD: getLastDealer error-', error);
                                        });
                                    }
                                }
                            }

                        }
                    } else {
                        this.setGuestHasDealer(null);
                        console.log('$HC-HLD: User Is Guest', result.Name);
                    }
                }).catch((error) => {
                    console.error('$HC-HLD: getUserDetails error-', error);
                });
            }
        } else {
            this.setGuestHasDealer(null);
        }
    }

    setGuestHasDealer(value) {
        if (value) {
            return sessionStorage.getItem('guestHasDealer');
        } else {
            if (localStorage.getItem('effectiveDealer')) {
                let brand = sessionStorage.getItem('brand') ?? localStorage.getItem('cartBrand');
                let effectiveDealer = JSON.parse(localStorage.getItem('effectiveDealer'));
                effectiveDealer.brands.forEach(element => {
                    sessionStorage.setItem('guestHasDealer', element.brand == brand ? 'true' : 'false');
                });
            } else {
                sessionStorage.setItem('guestHasDealer', 'false');
            }
            return null;
        }
    }

    //Added by Faraz for HDMP-10203
    async handleGetCurrentProduct() {
        let apiCallForCart = sessionStorage.getItem('APICallForCart');
        // sessionStorage.setItem('APICallForCart','Done1');
        //this.userFirstName.includes('HDM Developer') && 
        if (apiCallForCart != 'Done' && !window.location.pathname.includes('/splash')) {
            this.isLoading = window.location.href.includes('/cart/') ? false : true;
            await getAddedProductsInfo()
                .then(async result => {
                    if (result && result.length) {
                        try {
                            let data = JSON.parse(result);
                            //Imtiyaz - Start:
                            let productsInfo = JSON.parse(result);

                            let brand = null;
                            if (productsInfo.items) {
                                brand = productsInfo.items[0].Product_Division__c == 'A' ? 'Honda' : 'Acura';
                            }
                            sessionStorage.setItem('brand', brand);
                            localStorage.setItem('cartBrand', brand);
                            let cat = null;
                            await getCategoryId({ categoryName: brand }).then((result) => {
                                cat = result;
                            }).catch((err) => {
                                console.error('$HC-C: getCategoryId: ', err);
                            });
                            /* await getVehicleDetailsByModelID({modelId: productsInfo.items[0].Product_Model__r.Product_Model_ID__c}).then((vehicle) => {
                                let brands = [];
                                brands.push({ 'brand': vehicle.eConfigSourceCode__c, 'make': vehicle.eConfigSourceCode__c, 'year': vehicle.Year__c, 'model': vehicle.Model__c, 'trim': vehicle.Trim__c, 'productType': 'Accessories', 'vin': '', 'categoryId': cat, 'Id': vehicle.Id, 'Model_Id__c': vehicle.Model_Id__c, 'iNCatalogID__c': vehicle.iNCatalogID__c, 'iNDivisionID__c': vehicle.iNDivisionID__c, 'iNDoorID__c': vehicle.iNDoorID__c, 'iNGradeID__c': vehicle.iNGradeID__c, 'iNModelID__c': vehicle.iNModelID__c, 'iNYearID__c': vehicle.iNYearID__c, 'iNTransmissionID__c': vehicle.iNTransmissionID__c });
                                localStorage.setItem("effectiveVehicle", JSON.stringify({ 'brands': brands }));
                            }).catch((err) => {
                                console.error('$HC-C: getVehicleDetailsByModelID: ',err);
                            }); */
                            if (productsInfo.items) {
                                let cartItems = productsInfo.items;
                                let allProductDetailsLists = [];
                                if (localStorage.getItem('allProductDetailsList')) {
                                    allProductDetailsLists = JSON.parse(localStorage.getItem('allProductDetailsList'));
                                }
                                let breadcrumbsProductMap = [];
                                if (localStorage.getItem('breadcrumbsProductMap')) {
                                    breadcrumbsProductMap = JSON.parse(localStorage.getItem('breadcrumbsProductMap'));
                                }
                                cartItems.forEach(cartItem => {
                                    if (localStorage.getItem('allProductDetailsList')) {
                                        allProductDetailsLists = JSON.parse(localStorage.getItem('allProductDetailsList'));
                                    }
                                    if (localStorage.getItem('breadcrumbsProductMap')) {
                                        breadcrumbsProductMap = JSON.parse(localStorage.getItem('breadcrumbsProductMap'));
                                    }
                                    if (cartItem && cartItem.op_code__c && productsInfo[cartItem.op_code__c]) {
                                        let index = -1;
                                        if (allProductDetailsLists.length) {
                                            index = allProductDetailsLists.findIndex((item) => {
                                                return item.partNumber == JSON.stringify(cartItem.Sku);
                                            });
                                        }
                                        if (index == -1) {
                                            let allAccesories = productsInfo[cartItem.op_code__c];
                                            let accesory = allAccesories.find((item) => {
                                                return item.op_cd == cartItem.op_code__c;
                                            });
                                            accesory.displayAddToCart = true;
                                            accesory.disableAddToCartWithZeroAmount = false;
                                            accesory.partNumber = cartItem.Sku;
                                            let selectedAcc = {
                                                ProductFromCart: true,
                                                ProductType: "",
                                                ProductTypeForCart: "Accessorie",
                                                SelectedBreadcrumbs: [
                                                    {
                                                        label: brand,
                                                        id: brand
                                                    },
                                                    {
                                                        label: "Accessories",
                                                        id: "Accessories"
                                                    }
                                                ],
                                                ProductNumber: [
                                                    {
                                                        label: brand,
                                                        id: brand
                                                    },
                                                    {
                                                        label: "Accessories",
                                                        id: "Accessories"
                                                    }
                                                ],
                                                SelectedPart: "",
                                                SubCategoryImageURL: JSON.stringify(cartItem.Sku),
                                                UnitAdjustedPrice: cartItem.UnitAdjustedPrice,
                                                opCode: cartItem.op_code__c,
                                                partNumber: JSON.stringify(cartItem.Sku),
                                                selectedAcc: accesory
                                            };
                                            allProductDetailsLists.push(selectedAcc);
                                            localStorage.setItem('allProductDetailsList', JSON.stringify(allProductDetailsLists));
                                            //ACC_BRDCB-MAP-START
                                            let accBreadcrumbs = [];
                                            let subObj = [
                                                brand,
                                                [
                                                    {
                                                        label: brand, name: 'brand', href: window.location.origin + '/s/' + brand.toLowerCase(), isCurrentPage: false, categoryURL: 'FROM_CART_ADDED'
                                                    },
                                                    {
                                                        label: 'Accessories', name: 'producttype', href: 'javascript:void(0);', isCurrentPage: true, categoryURL: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat
                                                    }
                                                ]
                                            ];
                                            accBreadcrumbs.push(subObj);
                                            sessionStorage.setItem('breadcrumbsMap', JSON.stringify(accBreadcrumbs));
                                            //ACC_BRDCB-MAP-END
                                            //ACC_BRDCB-P-MAP-START
                                            breadcrumbsProductMap.push(

                                                [
                                                    cartItem.Product2Id,
                                                    [
                                                        {
                                                            label: brand, name: 'brand', href: window.location.origin + '/s/' + brand.toLowerCase(), isCurrentPage: false, categoryURL: 'FROM_CART_ADDED'
                                                        },
                                                        {
                                                            label: 'Accessories', name: 'producttype', href: 'javascript:void(0);', isCurrentPage: true, categoryURL: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat
                                                        }
                                                    ]
                                                ]

                                            );
                                            localStorage.setItem('breadcrumbsProductMap', JSON.stringify(breadcrumbsProductMap));
                                            //ACC_BRDCB-P-MAP-END
                                        }

                                    } else if (productsInfo[cartItem.Sku] && productsInfo[cartItem.Sku][0].Product2) {

                                        let part = productsInfo[cartItem.Sku].find((item) => {
                                            return item.Product2.StockKeepingUnit == cartItem.Sku;
                                        });

                                        //MAINTANANCE-START
                                        let partData = {
                                            WholsaleCompFlag: "",
                                            VDFlag: "N",
                                            TransmissionID: 0,
                                            TransmissionDescription: "ALL",
                                            SuggestedRetailPriceAmount: 8.56,
                                            SRACode: "W",
                                            QuantityRequired: "001",
                                            PriceChangeFlag: "",
                                            PartStatusCode: "A",
                                            PartSizeCode: "",
                                            PartNumber: part.Product2.StockKeepingUnit,
                                            PartModificationCode: "",
                                            PartID: 30389,
                                            PartDescriptionMasterFile: part.Product2.Name,
                                            PartDescription: part.Product2.Name,
                                            PartControlCode: "",
                                            OriginID: 0,
                                            OriginDescription: "CAN",
                                            NATABCQuantityCode: "A",
                                            MultiOrderQuantity: 30,
                                            MostForwardSupersession: "",
                                            LoUnVisSerialGroup: "",
                                            Length: 3.39,
                                            IsMatched: null,
                                            IllustrationReferenceCodeOrderBy: null,
                                            IllustrationReferenceCode2: null,
                                            IllustrationReferenceCode: null,
                                            HondaCode: 6663991,
                                            HighUnVisSerialGroup: "",
                                            Height: 2.64,
                                            GradeID: 0,
                                            GradeDescription: "EX (2WD/ONTARIO)",
                                            FunctionCode: 15400,
                                            ForwardSupersession: "",
                                            EngineFrameTransmissionTypeCode: "E",
                                            DealerNetPriceAmount: 5.14,
                                            CRSShipCode: "Y",
                                            CoreCostAmount: 0.00,
                                            CommonPartFlag: "",
                                            ColorLabelID: 0,
                                            ColorLabelDescription: "",
                                            BackwardSupersession: part.Product2.StockKeepingUnit,
                                            AreaID: 0,
                                            AreaDescription: "ALL",
                                            partHighlight: "slds-item product_item",
                                            productNumber: "",
                                            disableAddToCart: false,
                                            disableAddToCartWithZeroAmount: false
                                        }
                                        let selectedPart = {
                                            productFromCart: true,
                                            ProductNumber: "",
                                            ProductType: "",
                                            ProductTypeForCart: "Parts",
                                            SelectedBreadcrumbs: JSON.stringify(
                                                [
                                                    {
                                                        label: brand,
                                                        id: brand
                                                    },
                                                    {
                                                        label: "Parts",
                                                        id: "Parts"
                                                    },
                                                    {
                                                        label: "MAINTENANCE",
                                                        name: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat,
                                                        id: "MAINTENANCE"
                                                    }
                                                ]
                                            ),
                                            SelectedPart: JSON.stringify(partData),
                                            SubCategoryImageURL: "",
                                            partNumber: JSON.stringify(cartItem.Sku)
                                        }
                                        allProductDetailsLists.push(selectedPart);
                                        localStorage.setItem('allProductDetailsList', JSON.stringify(allProductDetailsLists));
                                        //PARTS_BRDCB-MAP-START
                                        let accBreadcrumbs = [];
                                        let subObj = [
                                            brand,
                                            [
                                                {
                                                    label: brand, name: 'brand', href: window.location.origin + '/s/' + brand.toLowerCase(), isCurrentPage: false, categoryURL: ''
                                                },
                                                {
                                                    label: 'Accessories', name: 'producttype', href: 'javascript:void(0);', isCurrentPage: true, categoryURL: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat
                                                }
                                            ]
                                        ];
                                        accBreadcrumbs.push(subObj);
                                        //sessionStorage.setItem('breadcrumbsMap',JSON.stringify(accBreadcrumbs));
                                        //PARTS_BRDCB-MAP-END

                                        //PARTS_BRDCB-P-MAP-START
                                        breadcrumbsProductMap.push([

                                            cartItem.Product2Id,
                                            [
                                                {
                                                    label: brand, name: 'brand', href: window.location.origin + '/s/' + brand.toLowerCase(), isCurrentPage: false, categoryURL: 'MAINTENANCE'
                                                },
                                                {
                                                    label: 'Parts', name: 'producttype', href: 'javascript:void(0);', isCurrentPage: false, categoryURL: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat
                                                }/* ,
                                                {
                                                    label: "MAINTENANCE", name: 'category', href: 'javascript:void(0);', isCurrentPage: true, categoryURL: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat
                                                } */
                                            ]

                                        ]);
                                        localStorage.setItem('breadcrumbsProductMap', JSON.stringify(breadcrumbsProductMap));
                                        //PARTS_BRDCB-P-MAP-END

                                        //MAINTANANCE-END
                                    } else {
                                        if (productsInfo[cartItem.Sku]) {
                                            let parts = productsInfo[cartItem.Sku];
                                            let part = parts.find((item) => {
                                                return item.PartDescription.toLowerCase() == cartItem.Name.toLowerCase();
                                            });
                                            // Saravanan LTIM Added for 19403
                                            if (part == null || part == undefined) {

                                                part = parts.find((item) => {
                                                    console.log('Item Part Description---1' + item.PartDescription);

                                                    console.log('Cart Items---' + cartItem.Name.toLowerCase());

                                                    console.log('Item Part Description---2' + (item.PartDescription + ' (REMANUFACTURED)').toLowerCase() == cartItem.Name.toLowerCase());
                                                    console.log('Item Part Description---3' + (item.PartDescription + ' (CORE CHARGE)').toLowerCase() == cartItem.Name.toLowerCase());
                                                    console.log('Item Part Description---4' + (item.PartDescription + ' (CORE CHARGE)').toLowerCase() + '--' + item.PartDescription + ' (REMANUFACTURED)'.toLowerCase());

                                                    console.log('Item Part Description---4' + (item.PartDescription + ' (CORE CHARGE)').toLowerCase() + '--' + item.PartDescription + ' (REMANUFACTURED)'.toLowerCase());


                                                    return ((item.PartDescription + ' (REMANUFACTURED)').toLowerCase() == cartItem.Name.toLowerCase() || (item.PartDescription + ' (CORE CHARGE)').toLowerCase() == cartItem.Name.toLowerCase());
                                                });



                                            }
                                            // Saravanan LTIM ENDED for 19403

                                            // Saravanan LTIM Added Terenary Condition HDMP-19403 part != null ? parseInt(part.IllustrationReferenceCode) : 0,

                                            let selectedPart = {
                                                productFromCart: true,
                                                ProductNumber: part != null ? parseInt(part.IllustrationReferenceCode) : 1,
                                                ProductType: "",
                                                ProductTypeForCart: "Parts",
                                                SelectedBreadcrumbs: JSON.stringify(
                                                    [
                                                        {
                                                            label: brand,
                                                            id: brand
                                                        },
                                                        {
                                                            label: "Parts",
                                                            id: "Parts"
                                                        }/* ,
                                                    {
                                                        label: cartItem.Category__c,
                                                        name: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat,
                                                        id: cartItem.Category__c
                                                    },
                                                    {
                                                        label: cartItem.Subcategory__c,
                                                        name:
                                                        {
                                                            pathname: '/s/category/' + brand.toLowerCase() + '/' + cat,
                                                            search: "",
                                                            hash: "",
                                                            origin: window.location.origin,
                                                            port: ""
                                                        },
                                                        id: cartItem.Subcategory__c
                                                    } */
                                                    ]
                                                ),
                                                SelectedPart: JSON.stringify(part),
                                                SubCategoryImageURL: JSON.stringify(cartItem.Accessorie_Image_URL__c),
                                                partNumber: JSON.stringify(cartItem.Sku)
                                            }
                                            allProductDetailsLists.push(selectedPart);
                                            localStorage.setItem('allProductDetailsList', JSON.stringify(allProductDetailsLists));
                                            //PARTS_BRDCB-MAP-START
                                            let accBreadcrumbs = [];
                                            let subObj = [
                                                brand,
                                                [
                                                    {
                                                        label: brand, name: 'brand', href: window.location.origin + '/s/' + brand.toLowerCase(), isCurrentPage: false, categoryURL: ''
                                                    },
                                                    {
                                                        label: 'Accessories', name: 'producttype', href: 'javascript:void(0);', isCurrentPage: true, categoryURL: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat
                                                    }
                                                ]
                                            ];
                                            accBreadcrumbs.push(subObj);
                                            //sessionStorage.setItem('breadcrumbsMap',JSON.stringify(accBreadcrumbs));
                                            //PARTS_BRDCB-MAP-END

                                            //PARTS_BRDCB-P-MAP-START
                                            breadcrumbsProductMap.push([

                                                cartItem.Product2Id,
                                                [
                                                    {
                                                        label: brand, name: 'brand', href: window.location.origin + '/s/' + brand.toLowerCase(), isCurrentPage: false, categoryURL: ''
                                                    },
                                                    {
                                                        label: 'Parts', name: 'producttype', href: 'javascript:void(0);', isCurrentPage: false, categoryURL: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat
                                                    }/* ,
                                                    {
                                                        label: cartItem.Category__c, name: 'category', href: 'javascript:void(0);', isCurrentPage: false, categoryURL: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat
                                                    },
                                                    {
                                                        label: cartItem.Subcategory__c, name: 'subcategory', href: 'javascript:void(0);', isCurrentPage: true, categoryURL: window.location.origin + '/s/category/' + brand.toLowerCase() + '/' + cat
                                                    } */
                                                ]

                                            ]);
                                            localStorage.setItem('breadcrumbsProductMap', JSON.stringify(breadcrumbsProductMap));
                                            //PARTS_BRDCB-P-MAP-END
                                        }
                                    }
                                });
                            }
                            //Imtiyaz - End:
                            let cartItems = data.items;
                            var firedMessage = false; // Saravanan LTIM for 18860
                            cartItems.forEach(element => {
                                if (element.Product_Type__c.includes('Accessory')) {
                                    let accessories = data[element.op_code__c];
                                    let name = accessories.find(item => item.op_cd == element.op_code__c);
                                    element.Name = name.AccessoryName;
                                    if (element.Cart && !element.Cart.DealerId__c) {
                                        element.UnitAdjustedPrice = name.msrp;
                                    }
                                } else if (element.Product_Type__c.includes('Part')) {
                                    let parts = data[element.Sku];
                                    if (parts && parts != undefined && parts[0].AreaDescription) {
                                        let name = parts.find(item => item.PartNumber == element.Sku && item.IsMatched == 'true');
                                        element.Name = name != null ? name.PartDescription : ''; //Saravanan LTIM
                                        if (element.Cart && !element.Cart.DealerId__c) {
                                            element.UnitAdjustedPrice = name.SuggestedRetailPriceAmount;
                                        }
                                    } else if (parts && parts != undefined && parts[0].Product2Id) {
                                        let name = parts.find(item => item.Product2.StockKeepingUnit == element.Sku);
                                        console.log('Name---' + name.Product2.Name);
                                        element.Name = name.Product2.Name;
                                        if (element.Cart && !element.Cart.DealerId__c) {
                                            element.UnitAdjustedPrice = name.UnitPrice;
                                        }
                                    }

                                    // Sararavnan LTIM Added for 18860
                                    if (!element.UnitAdjustedPrice > 0 && !firedMessage) {
                                        firedMessage = true;
                                        this.showToastMessage('Success', 'The items previously saved in your shopping cart have been moved to My Wish List.', 'success');

                                    }
                                    // Sararavnan LTIM Ended for 18860

                                }
                            });
                            updateMyCartItems({ cartItemList: cartItems })
                                .then(result => {
                                    sessionStorage.setItem('APICallForCart', 'Done');
                                })
                                .catch(error => {
                                    console.error('Error:: ', error);
                                }).finally(() => {
                                    this.isLoading = false;
                                });
                        } catch (error) {
                            console.log('Error :> ', error);
                            this.isLoading = false;
                        }
                    } else {
                        this.isLoading = false;
                    }
                })
                .catch(error => {
                    console.error('Error->', error);
                }).finally(() => this.isLoading = false);
        }
    }
    //End HDMP-10203

    async handleMoveInactiveItems() {
        console.log('OUTPUT : ', sessionStorage.getItem('moveInactiveItems'));
        if (sessionStorage.getItem('moveInactiveItems') != 'Done') {
            await moveInactiveItemsToWishList()
                .then(result => {
                    if (result || !result) {
                        sessionStorage.setItem('moveInactiveItems', 'Done');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                });
        }
    }

    // Saravanan LTIM for 18860

    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    async handleSaveLastShoppingSelection() {
        if (sessionStorage.getItem('savedVehicleInfo') != 'Done') {
            if (localStorage.getItem('effectiveVehicle')) {
                let vehicles = JSON.parse(localStorage.getItem('effectiveVehicle'));
                if (vehicles && vehicles.brands) {
                    vehicles.brands.forEach(async item => {
                        let inputParams = {
                            Last_Product_ModelId__c: item.Model_Id__c,
                            Product_Subdivision__c: item.make,
                            Product_Identifier__c: item.vin,
                        };
                        await saveLastShoppingSelection({ dataAsObj: JSON.stringify(inputParams) })
                            .then(result => {
                                if (result && result == 'success') {
                                    console.log('Result', result);
                                }
                            }).catch(error => {
                                console.error('Error:', error);
                            });
                    });

                }
            }
            sessionStorage.setItem('savedVehicleInfo', 'Done');
        }
    }
}
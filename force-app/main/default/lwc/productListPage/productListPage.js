/******************************************************************************* 

Name:  productListPage

Business Unit: HDM

Date: April 2021

Description: This is PLP of parts

******************************************************************************* 

MODIFICATIONS – 
Date        | Dev Name      |       Method/Function         | User Story 

09-06-2022  | Yashika       |       Added header            | 
18-07-2022  | Pradeep Singh |       canvasLoad              | HDMP-11011
12-09-2022  | Pradeep Singh |       connectedCallback,      | HDMP-16101
                                    notifyAddToCart,
                                    getCartItemsQuantity
*******************************************************************************/
import { LightningElement, api, track, wire } from 'lwc';
import communityId from '@salesforce/community/Id';
import { getCurrentDealerId } from 'c/utils';
import checkIfUserIsLoggedIn from '@salesforce/apex/B2BGuestUserController.checkIfUserIsLoggedIn';
import addItem_Clone from '@salesforce/apex/B2BGuestUserController.addItem_Clone';
import createUserAndCartSetup from '@salesforce/apex/B2BGuestUserController.createUserAndCartSetup';
import addProductToCartItem_Clone from '@salesforce/apex/B2BGuestUserController.addProductToCartItem_Clone';
import getProduct from '@salesforce/apex/B2BGuestUserController.getProduct';
import { NavigationMixin } from 'lightning/navigation';
import { publish, subscribe, MessageContext } from 'lightning/messageService'; // Publish event added by Deepak Mali
import HDMP_MESSAGE_CHANNEL2 from "@salesforce/messageChannel/HDMPMessageForCart__c";
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
//Added by Pradeep Singh

import Id from '@salesforce/user/Id';
import checkIfUserHasCartAndSetup from '@salesforce/apex/B2BGuestUserController.checkIfUserHasCartAndSetup';
import honda_js from '@salesforce/resourceUrl/honda_js';
import honda_Scss from '@salesforce/resourceUrl/honda_Scss';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getCartId from '@salesforce/apex/B2BGetInfo.getCartId';
import getAllProuctQuantity from '@salesforce/apex/B2BGetInfo.getAllProuctQuantity';
import getCartItemBrand from '@salesforce/apex/B2BGetInfo.getCartItemBrand';//Added by Faraz for HDMP-16716
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPermissions from '@salesforce/apex/B2BGuestUserController.createPermissionSetsSynchronous';
import MaintenanceImages from '@salesforce/resourceUrl/MaintenanceImages';
import Hotspot_Label from '@salesforce/label/c.Hotspot_label';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getModelId from '@salesforce/apex/B2BGuestUserController.getModelId'; //added by Yashika for 8708

import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';//for adobe analytics
import RemanText from '@salesforce/label/c.B2B_Reman_Part_Identification_Label'; // Added as a part of HDMP-16533 - Aditya


const BREADCRUMB_TYPE = {
    BRAND: 'brand',
    PRODUCTTYPE: 'producttype',
    CATEGORY: 'category',
    SUBCATEGORY: 'subcategory',
    PRODUCT: 'product'
}
const PRODUCT_TYPE = 'Part';
export default class ProductListPage extends NavigationMixin(LightningElement) {
    //@api productList;
    @api shoppingBrand;
    @track cartImg;
    prodWithQuantity;
    @track partsList;
    isMaintenance = false; ///Added by Bhawesh R2 story 5492 fast moving item (Created by Faraz)
    selectedPartNameForSave = '';
    @track returnURL;
    @track hotSpots; //Added By SaiLaxman for Hotspots
    @track productHotspotMap = []; //Added By SaiLaxman for Hotspots
    @track isCanvasLoaded = false;
    @api priceType;
    @api breadcrumbsList;
    @track showHotspotLabel = false;
    @track desktop = false;
    @track mobile = false;
    @track categoryData;//Added by Faraz for HDMP-10203
    @track searchedPartsIllustractionCodes = [];
    @track cartBrandDB = '';//Added by Faraz for HDMP-16716
    //Added by Faraz for fast moving item
    isReman = false; // Added by ashwin for US - HDMP-16455
    hondaPLPImage = MaintenanceImages + '/MaintenanceImages/Honda/AllParts_800x420.jpg';
    acuraPLPImage = MaintenanceImages + '/MaintenanceImages/Acura/Acura_820x420.jpg';
    maintenanceImagePLP;
    label = {
        Hotspot_Label,
        RemanText
    };
    //End
    @api
    get productList() {
        return this.productList;
    }
    set productList(value) {
        if (value) {
            this.imgURL = '';
            this.productHotspotMap = []; // Added By Pradeep Singh for HotSpots
            this.isLoading = true;
            //HDMP-15451 starts here
            this.isCanvasLoaded = false;
            let product = JSON.parse(JSON.stringify(value));
            console.log('$IA: productListPage 82 product - ', product);
            this.hotSpots = product.HotSpots ? product.HotSpots : this.hotSpots; //Added By SaiLaxman for Hotspots
            // this.hotSpots = JSON.parse(JSON.stringify(this.hotSpots));
            //HDMP-15451 ends here

            let parts = product.Parts;
            this.searchedPartsIllustractionCodes = [];
            let allParts = [];
            parts.forEach((part, index) => {
                let obj = JSON.parse(JSON.stringify(part));
                //HDMP-15451 starts here
                if (obj.IsMatched == 'true') {
                    obj.partHighlight = 'slds-item product_item parthighlight';
                    this.searchedPartsIllustractionCodes.push(obj.IllustrationReferenceCode);
                }else if(sessionStorage.getItem('SEO_Sku') && sessionStorage.getItem('SEO_Sku') != null && obj.PartNumber == sessionStorage.getItem('SEO_Sku')){
                    obj.partHighlight = 'slds-item product_item parthighlight';
                }else{
                    obj.partHighlight = 'slds-item product_item';
                }
                //HDMP-15451 ends here
                obj.isReman = obj.CoreCostAmount != 0 || obj.CoreCostAmount != 0.00 ? true : false; // Added by ashwin for US - HDMP-16455


                obj.productNumber = obj && obj.IllustrationReferenceCode ? parseInt(obj.IllustrationReferenceCode, 10) : '';
                obj.disableAddToCart = obj.PartModificationCode == 'X' || obj.PartModificationCode == 'W' || obj.PartModificationCode == 'D' || obj.PartControlCode == 'G' ? true : false;
                // Start Added by Aditya Bug HDMP-18900 fix
                console.log('Check---'+obj.SuggestedRetailPriceAmount); // Saravanan Debug
                console.log('disableAddToCart Check---'+obj.disableAddToCart); // Saravanan Debug
                if(obj.SuggestedRetailPriceAmount != null){
                    let decimalVal = obj.SuggestedRetailPriceAmount.toString().split('.')[1];
                    if ((decimalVal && decimalVal.length < 2) || (decimalVal == null || decimalVal == undefined)) {
                        obj.SuggestedRetailPriceAmount = Number(obj.SuggestedRetailPriceAmount).toFixed(2);
                    }
                }
                    obj.disableAddToCartWithZeroAmount = obj.SuggestedRetailPriceAmount <= 0 ? true : false; //Added by deepak mali
                    console.log('disableAddToCart Check---'+obj.disableAddToCartWithZeroAmount); // Saravanan Debug
                    obj.shoppingBrand = this.shoppingBrand;
                // End Added by Aditya Bug HDMP-18900 fix
                allParts.push(obj);
            });
            //15451 starts here
            //this.hotSpots = searchedPartsIllustractionCodes && searchedPartsIllustractionCodes.length > 0 ? hotSpotList.filter(elm=>searchedPartsIllustractionCodes.includes(elm.IllustrationReferenceCode)) : hotSpotList;
            //15451 ends here
            //14107 starts here
            let partListVar = JSON.parse(JSON.stringify(allParts))
            this.partsList = partListVar.sort((x, y) => { return y.IsMatched == 'true' ? 1 : x.IsMatched == 'true' ? -1 : 0; });
            //14107 ends here
            let imageList = JSON.parse(JSON.stringify(value.ImageIllustrationGroupDetails));
            this.imgURL = imageList && imageList.length ? imageList[0].IllustrationURL : '';
            //Added by Bhawesh R2 story 5492 fast moving item 
            console.log('imgURL : ', this.imgURL);
            if (!this.imgURL) {
                this.isMaintenance = true;
                this.returnURL = '?type=category&label=MAINTENANCE';
            } else if (this.imgURL) {
                this.isMaintenance = false;
            }
            //Added by Faraz for Fast Moving Items 5492 End Here
            this.fetchcartId();
            setTimeout(() => { this.isLoading = false; }, 1000);
        }
    }

    @track productMap = new Map();
    subscription = null;
    isLoading = false;
    @track userId = Id;
    @track partsList = [];
    @track isModalOpen = false;
    @track isPorductNotExistModalOpen = false;
    @track productModelMarketingName;

    // By using the MessageContext @wire adapter, unsubscribe will be called
    // implicitly during the component descruction lifecycle.
    @wire(MessageContext)
    messageContext;

    @track productModelId = '';//for adobe analytics 

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            HDMP_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }


    @track imgURL;
    cartId;

    connectedCallback() {
        window.scrollTo(0, 0);
        // updated by Pradeep for HDMP-7253
        window.addEventListener("resize", this.canvasLoad.bind(this));
        // ends here

        // Added by Bhawesh on 14-03-2022 for 8354 start
        this.createCookie('ProductFromCart', false, 1);
        this.createCookie('ProductTypeForCart', '', 1);
        // End
        //HDMP-16101 starts here
        let storeBrand = sessionStorage.getItem('brand');
        // added on 11/12 start
        if (sessionStorage.getItem('VehicleName')) {
            this.year = sessionStorage.getItem('VehicleYear');
            this.model = sessionStorage.getItem('VehicleModel');
            this.trim = sessionStorage.getItem('VehicleTrim');
            this.vin = sessionStorage.getItem('VehicleVIN');
            this.productModelMarketingName = sessionStorage.getItem('VehicleName');
        }
        // added on 11/12 end
        else if (localStorage.getItem("effectiveVehicle")) {
            var effectiveVehicles = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
            effectiveVehicles.forEach(vehicle => {
                if (vehicle.brand == storeBrand) {
                    this.year = vehicle.year;
                    this.model = vehicle.model;
                    this.trim = vehicle.trim;
                    this.vin = vehicle.vin; //added by Yashika for 16448
                    this.productModelId =vehicle.Model_Id__c; //for adobe bug 31
                    this.productModelMarketingName = vehicle.make + ' ' + vehicle.year + ' ' + vehicle.model + ' ' + vehicle.trim;
                }
            })
        }
        //HDMP-16101 ends here
        //added by Yashika for 8708: starts
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
                    this.productModelId = result.Product_Model_ID__c;//for adobe bug-16 
                    console.log('model id from apex', this.modelId)
                }
            })
            .catch(error => {

            }); //ends:8708
        this.isCanvasLoaded = false;
        this.isLoading = true;
        this.subscribeToMessageChannel();
        this.getBreadcrumbs();
        console.log('OUTPUTshoppingBrand : ', this.shoppingBrand);
        // multiple tab issue3 starts here
        //this.categoryData = JSON.parse(localStorage.getItem('category'));
        this.categoryData = JSON.parse(sessionStorage.getItem('category'));
        // multiple tab issue3 ends here
        console.log('category :: ', this.categoryData);
    }
    getBreadcrumbs() {
        if (sessionStorage.getItem('breadcrumbsMap')) {
            let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
            if (breadcrumbs) {
                //Added by Faraz R2 story 5492 fast moving item 
                if (breadcrumbs[0].label /*&& this.isMaintenance*/) {
                    this.maintenanceImagePLP = breadcrumbs[0].label == 'Honda' ? this.hondaPLPImage : breadcrumbs[0].label == 'Acura' ? this.acuraPLPImage : '';
                }
                //End
                let categoryLabel = '';
                breadcrumbs.forEach(breadcrumb => {
                    if (BREADCRUMB_TYPE.CATEGORY === breadcrumb.name) {
                        categoryLabel = breadcrumb.label;
                    }
                    if (BREADCRUMB_TYPE.SUBCATEGORY === breadcrumb.name) {
                        this.returnURL = '?type=' + breadcrumb.name + '&categorylabel=' + categoryLabel + '&label=' + breadcrumb.label;
                    }
                });
            } else if (window.location.search.includes('type=category&label=MAINTENANCE')) {
                this.maintenanceImagePLP = window.location.href.includes('/category/honda/') ? this.hondaPLPImage : window.location.href.includes('/category/acura/') ? this.acuraPLPImage : '';
            }
        }
    }
    fetchcartId() {
        getCartId({ communityId: communityId })
            .then((result) => {
                this.cartId = result;
            })
            .catch((error) => {
                //console.log('fetchcartId error' + JSON.stringify(error));
            });
    }

    //Added by Faraz for HDMP-16716
    getCartItemBrand(partNumber, price) {
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
                    this.notifyAddToCart(partNumber, price);
                }

                else {
                    this.cartBrandDB = '';
                    localStorage.removeItem('cartBrand');
                }
                // added on 11/12 end
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
    //End HDMP-16716

    initialRender = false;
    renderedCallback() {
        if (sessionStorage.getItem('breadcrumbsMap')) {
            let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
            console.log('$PLP_RCB: breadcrumbsMap: ', breadcrumbsMap);

            if (breadcrumbsMap.has(this.shoppingBrand)) {
                let breadcrumsArray = breadcrumbsMap.get(this.shoppingBrand);
                console.log('$PLP_RCB: breadcrumsArray: ', breadcrumsArray);
                console.log('$PLP_RCB: showHotspotLabel: ', this.showHotspotLabel);
                breadcrumsArray.forEach(element => {
                    console.log('$PLP_RCB: element.label: ', element.label);
                    if (element.label == 'MAINTENANCE') {
                        this.showHotspotLabel = false;
                    }
                });
            }
        }

        // if (this.cartId) {
        //     this.getProductQuan();
        // }
        if (!this.initialRender) {
            loadScript(this, honda_js + '/Drift.min.js')
                .then(() => {
                    let demoTrigger = this.template.querySelector(".productImg-toZoom");
                    let paneContainer = this.template.querySelector(".productImg__wrapper--ZoomEffect");
                    //console.log('OUTPUT : initialRender', demoTrigger, paneContainer);
                    if (demoTrigger != null && paneContainer != null) {
                        new Drift(demoTrigger, {
                            paneContainer: paneContainer,
                            inlinePane: 320,
                            inlineOffsetY: -85,
                            containInline: true,
                            hoverBoundingBox: true
                        });
                    }
                }).catch((error) => {
                    //console.log('Error-->', error);
                });
            this.initialRender = true;
            window.addEventListener("resize", this.canvasLoad.bind(this));
            setTimeout(() => { this.isLoading = false; }, 1000);
            if(sessionStorage.getItem('SEO_SectionId') && sessionStorage.getItem('SEO_SectionId') != null){
                if(sessionStorage.getItem('SEO_MegaCategory') && sessionStorage.getItem('SEO_MegaCategory') != null){
                    if(sessionStorage.getItem('SEO_Sku') == null){
                        sessionStorage.removeItem('SEO_SectionId');
                        sessionStorage.removeItem('SEO_MegaCategory');
        }
                }
            }
            sessionStorage.removeItem('SEO_Maintenence');
        }
        //HDMP-15451 starts here
        if (!this.isCanvasLoaded) {
            this.canvasLoad();
        }
        //HDMP-15451 ends here
    }
    /* Added by Lakshman as part of showing highlights on Image */
    canvasLoad() {
        this.productHotspotMap = [];
        var canvas = this.template.querySelector("canvas");
        var img = this.template.querySelector("img");
        if (canvas && img) {
            let originalimgWidth;
            let originalimgHeight;
            let newImgWidth = img.width;
            let newImgHeight = img.height;
            canvas.width = newImgWidth;
            canvas.height = newImgHeight;
            let hotspotMapUnique = new Map();
            let partsMapUnique = {};
            const resRatio = Math.round(newImgWidth / newImgHeight);
            if (resRatio >= 2) {
                originalimgWidth = 1267;
                originalimgHeight = 583;
            } else {
                originalimgWidth = 1467 * resRatio;
                originalimgHeight = 1467;
            }
            var context = canvas.getContext("2d");
            context.clearRect(0, 0, canvas.width, canvas.height);
            this.hotSpots.forEach(element => {
                let hotspot = [];
                hotspotMapUnique.set(element.IllustrationReferenceCode, element);
                const xPosOrg = Math.floor(element.XPosition * (originalimgWidth / 10000)); //585
                const yPosOrg = Math.floor(element.YPosition * (originalimgHeight / 10000)); //288

                const xPos = (xPosOrg / originalimgWidth) * newImgWidth;
                const yPos = (yPosOrg / originalimgHeight) * newImgHeight;
                context.beginPath();
                // Added By Pradeep for HDMP-8480
                if (window.screen.width <= 401) {
                    hotspot.push(xPos, yPos, 3);
                } else if (401 < window.screen.width >= 550) {
                    hotspot.push(xPos, yPos, 4);
                } else if (550 < window.screen.width >= 688) {
                    hotspot.push(xPos, yPos, 5);
                } else if (688 < window.screen.width > 786) {
                    hotspot.push(xPos, yPos, 6);
                } else {
                    hotspot.push(xPos, yPos, 7);
                }
                //ends here
                // HDMP-HDMP-11011 starts here
                let uniqueHotSpotObj = {
                    value: hotspot,
                    key: element.IllustrationReferenceCode
                };
                this.partsList.forEach(part => {
                    partsMapUnique[part.IllustrationReferenceCode] = part;
                    if ((part.IllustrationReferenceCode == element.IllustrationReferenceCode) &&
                        !(this.productHotspotMap.find(elm => (elm['key'] === element.IllustrationReferenceCode) && (JSON.stringify(elm['value']) === JSON.stringify(hotspot))))) {
                        this.productHotspotMap.push(uniqueHotSpotObj);
                        // HDMP-HDMP-11011 ends here

                        // updated by Pradeep for HDMP-7253,HDMP-8480
                        if (window.screen.width <= 401) {
                            context.arc(xPos, yPos, 3, 0, 2 * Math.PI);
                        } else if (window.screen.width > 401 && window.screen.width <= 550) {
                            context.arc(xPos, yPos, 4, 0, 2 * Math.PI);
                        } else if (window.screen.width > 550 && window.screen.width <= 688) {
                            context.arc(xPos, yPos, 5, 0, 2 * Math.PI);
                        } else if (window.screen.width > 688 && window.screen.width < 786) {
                            context.arc(xPos, yPos, 6, 0, 2 * Math.PI);
                        } else {
                            context.arc(xPos, yPos, 7, 0, 2 * Math.PI);
                        }
                        //ends here
                        //HDMP-15451 starts here
                        if (this.searchedPartsIllustractionCodes.length == 0 || this.searchedPartsIllustractionCodes.includes(part.IllustrationReferenceCode)) {
                        context.fillStyle = '#ff0000';
                        }
                        else {
                            context.fillStyle = '#dddddd';
                        }
                        //HDMP-15451 ends here
                        context.globalAlpha = 0.4;
                        context.fill();
                        context.stroke();
                    }
                });
            });
            this.isCanvasLoaded = true;
            if (hotspotMapUnique.size !== Object.keys(partsMapUnique).length) {
                this.showHotspotLabel = true;
            } else {
                this.showHotspotLabel = false;
            }
        }

    }
    // Added By Pradeep Singh for opening image in a popup
    //starts here
    handlePopUpImage() {
        window.open(this.imgURL, 'popup', 'width=983,height=506');
        return false;
    }

    //ends here

    oncanvasclick(event) {
        console.log('on click oof canvas');
        let partNumber = event.target.dataset.partnumber;
        console.log('on click oof canvas' + partNumber);
        let selectedPart = this.partsList.find((everyPart) => {
            return everyPart.IllustrationReferenceCode == partNumber;
        });
        let element = this.template.querySelector('h3[data-id="' + selectedPart.PartNumber + '"]');
        let elementPos = element.getBoundingClientRect().top;
        let offsetPos = window.pageYOffset;
        let headerOffset = 145;

        window.scrollTo({
            top: elementPos + offsetPos - headerOffset,
            behavior: "smooth"
        });
        //this.template.querySelector('h3[data-id="'+selectedPart.PartNumber+'"]').scrollIntoView();
        //this.navigateToPDP(selectedPart);
    }

    handleImageHover() {
        //console.log('OUTPUT : hello');
        let demoTrigger = this.template.querySelector(".productImg-toZoom");
        let paneContainer = this.template.querySelector(".productImg__wrapper--ZoomEffect");
        new Drift(demoTrigger, {
            paneContainer: paneContainer,
            inlinePane: 320,
            inlineOffsetY: -85,
            containInline: true,
            hoverBoundingBox: true
        });
    }

    getProductQuan() {
        getAllProuctQuantity({ cartId: this.cartId })
            .then((result) => {
                this.prodWithQuantity = result;
            })
            .catch((error) => {
                //console.log('getProductQuan error' + JSON.stringify(error));
            });
    }

    // Handler for message received by component
    handleMessage(data) {
        //console.log('OUTPUT : ', JSON.parse(JSON.stringify(data.message.products)));
        if (data.message.products) {
            this.productList = data.message.products;
            this.priceType = 'Dealer Price';
        }
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    showToastMessages(title, variant, message) {
        this.dispatchEvent(new ShowToastEvent({ title: title, variant: variant, message: message, mode: 'dismissable' }));
    }


    getCartItemsQuantity(partNumber, price) {
        //HDMP-16101 starts here
        console.log('$PLP: getCartItemsQuantity');
        let storeBrand = sessionStorage.getItem('brand');
        console.log('$PLP: storeBrand: ', storeBrand);
        // added on 11/12 start
        if (sessionStorage.getItem('VehicleName')) {
            this.year = sessionStorage.getItem('VehicleYear');
            this.model = sessionStorage.getItem('VehicleModel');
            this.trim = sessionStorage.getItem('VehicleTrim');
            this.vin = sessionStorage.getItem('VehicleVIN');
            this.productModelMarketingName = sessionStorage.getItem('VehicleName');
        }
        // added on 11/12 end
        else if (localStorage.getItem("effectiveVehicle")) {
            var effectiveVehicles = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
            effectiveVehicles.forEach(vehicle => {
                if (vehicle.brand == storeBrand) {
                    this.productModelMarketingName = vehicle.make + ' ' + vehicle.year + ' ' + vehicle.model + ' ' + vehicle.trim;
                    console.log('$PLP: this.productModelMarketingName: ', this.productModelMarketingName);
                }
            })
        }
        //HDMP-16101 ends here
        getAllProuctQuantity({ cartId: this.cartId })
            .then((result) => {
                this.prodWithQuantity = result;
                let proceedNext = false;
                let totalpartQuantity = 0;
                if (this.prodWithQuantity && Object.keys(this.prodWithQuantity).length != 0) {
                    //  console.error('this.prodWithQuantity',this.prodWithQuantity);
                    // alert('IF');
                    for (var i in this.prodWithQuantity) {
                        totalpartQuantity += this.prodWithQuantity[i];
                        if (i == partNumber) {
                            let quantity = parseInt(this.prodWithQuantity[i]) + parseInt(1);
                            if (quantity > 50) {
                                this.isLoading = false;
                                this.showToastMessages('Quantity Limit', 'error', 'The Product cannot be added as its already in cart with its maximum quantity.');
                                proceedNext = false;
                                break;
                            } else { proceedNext = true; }
                        } else { proceedNext = true; }
                    }
                    // Added by Lakshman on 23/02/2022 - HDMP-5074 EPIC Starts
                    totalpartQuantity += parseInt(1);
                    if (totalpartQuantity > 25) {
                        this.isLoading = false;
                        this.showToastMessages('Quantity Limit', 'error', 'Sorry we can only have maximum of 25 quantity in an order.');
                        proceedNext = false;
                    }
                    // Added by Lakshman on 23/02/2022 - HDMP-5074 EPIC Ends
                } else {

                    let selectedPart = this.partsList.find((everyPart) => {
                        return everyPart.PartNumber == partNumber;
                    })

                    // multiple tab issue3 starts here
                    //this.createCookie('SelectedPart', JSON.stringify(selectedPart), 1);
                    sessionStorage.setItem('SelectedPart', JSON.stringify(selectedPart));
                    // multiple tab issue3 ends here

                    if (selectedPart && selectedPart.productNumber) {
                        this.createCookie('ProductNumber', selectedPart.productNumber, 1);
                    }
                    localStorage.setItem('cartBrand', sessionStorage.getItem('brand'));


                    // multiple tab issue3 starts here
                    //this.createCookie('SubCategoryImageURL', this.imgURL, 1);
                    sessionStorage.setItem('SubCategoryImageURL', this.imgURL);
                    // multiple tab issue3 ends here
                    proceedNext = true;
                }
                if (proceedNext) {
                    try {
                        let selectedPartforHS = this.partsList.find((everyPart) => {
                            return everyPart.PartNumber == partNumber;
                        })
                        if (this.hotSpots) {
                            this.createHotSpotCookieData(selectedPartforHS);
                        }
                        let existingallProductDetailsList = []
                        let alreadyExistInList = false;

                        existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));
                        if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                            existingallProductDetailsList.forEach(element => {
                                if (element.partNumber) {
                                    let elementNumber = element.partNumber.replace(/^"|"$/g, ''); //Remove double qcuotes from partNumber
                                    if (elementNumber == partNumber) {
                                        alreadyExistInList = true;
                                        if (element && element.SelectedPart) {
                                            let selPart = JSON.parse(element.SelectedPart);
                                            this.selectedPartNameForSave = selPart && selPart.PartDescription ? selPart.PartDescription : this.selectedPartNameForSave;
                                            console.log('this.selectedPartNameForSave in if : ', this.selectedPartNameForSave);
                                        }
                                    }
                                }

                            })
                        }
                        if (!alreadyExistInList) {
                            let selectedPart = this.partsList.find((everyPart) => {
                                return everyPart.PartNumber == partNumber;
                            })
                            //Added Shalini Soni 90799
                            let allProductDetailsList = [];
                            let productDetails = { SelectedPart: '', ProductNumber: '', SelectedBreadcrumbs: '', SubCategoryImageURL: '', partNumber: '', ProductType: '', productFromCart: false };
                            productDetails.SelectedPart = JSON.stringify(selectedPart);
                            productDetails.ProductNumber = JSON.stringify(selectedPart.productNumber);
                            console.log('list breadcrumb PLP ', this.breadcrumbsList)
                            productDetails.SelectedBreadcrumbs = JSON.stringify(this.breadcrumbsList);
                            productDetails.SubCategoryImageURL = JSON.stringify(this.imgURL);
                            productDetails.partNumber = JSON.stringify(partNumber);
                            productDetails.ProductTypeForCart = 'Parts';
                            productDetails.ProductFromCart = true;
                            allProductDetailsList.push(productDetails);

                            this.selectedPartNameForSave = selectedPart && selectedPart.PartDescription ? selectedPart.PartDescription : this.selectedPartNameForSave;
                            existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));

                            if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                                existingallProductDetailsList.push(productDetails);
                                localStorage.setItem('allProductDetailsList', JSON.stringify(existingallProductDetailsList));
                            } else {
                                localStorage.setItem('allProductDetailsList', JSON.stringify(allProductDetailsList));
                            }
                            //console.log('##allProductDetailsList', JSON.parse(localStorage.getItem('allProductDetailsList')));
                        }

                    } catch (error) {
                        alert(error.message);
                    }

                    //this.buildSelectedProduct(partNumber);
                    checkIfUserIsLoggedIn().then(result => {
                        console.log('$PLP: checkIfUserIsLoggedIn: ', result);
                        if (result) {
                            console.log('$PLP: result === true: ', result);
                            this.userId = result;
                            checkIfUserHasCartAndSetup({
                                communityId: communityId,
                                userId: this.userId
                            })
                                .then(result => {
                                    if (result) {
                                        console.log('$PLP: checkIfUserHasCartAndSetup: ', result);
                                        this.cartId = result.cartId;
                                        this.getCartItemBrand(partNumber, price);//Added by Pradeep  for HDMP-16716
                                    }
                                })
                                .catch(error => {
                                    //console.log(error);
                                });
                        } else {
                            let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
                            createUserAndCartSetup({ accountId: getCurrentDealerId() })
                                .then(result => {
                                    console.log('$PLP: createUserAndCartSetup: ', result);
                                    let userRecord = result.userId;
                                    let cartId = result.cartId;
                                    let urlRedirect = window.location.href;
                                    if (this.returnURL) {
                                        urlRedirect += this.returnURL;
                                    }
                                    createPermissions({
                                        userId: userRecord,
                                    }).then(result => {
                                        addItem_Clone({
                                            userId: userRecord,
                                            productId: partNumber,
                                            quantity: 1,
                                            redirectUrl: urlRedirect,
                                            wc: cartId,
                                            price: price,
                                            color: '',
                                            accessoryName: this.selectedPartNameForSave,
                                            productType: PRODUCT_TYPE, // Added by shalini soni for HDMP-5702 R2 Story
                                            accImageURL: this.imgURL, // Added by Yashika for 7380
                                            brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290    
                                            modelId: this.modelId, //added by Yashika for 8708
                                            vin: this.vin, //added by Yashika for 8708
                                            sectionId: this.categoryData && this.categoryData.sectionId ? this.categoryData.sectionId : '',//Added by Faraz for 10203
                                            IllustrationId: this.categoryData && this.categoryData.illustrationId ? this.categoryData.illustrationId : '',//Added by Faraz for 10203
                                            IllustrationImageId: this.categoryData && this.categoryData.illustrationGroupImageId ? this.categoryData.illustrationGroupImageId : '',//Added by Faraz for 10203
                                            productModelMarketingName: this.productModelMarketingName//added by Yashika for 10179
                                        }).then(redirectUrl => {
                                            getProduct({
                                                productId: partNumber
                                            }).then(result => {
                                                if (result) {
                                                    console.log('##urlRedirect', urlRedirect);
                                                    console.log('##redirectUrl', redirectUrl);

                                                    this.notifyToCustomCart(); //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
                                                    if (sessionStorage.getItem('breadcrumbsMap')) {
                                                        let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                                                        let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')));
                                                        breadcrumbsProductMap.set(result.Id, breadcrumbsMap.get(sessionStorage.getItem('brand')));
                                                        localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                                                        window.location.replace(redirectUrl);
                                                    }
                                                }
                                            }).catch(error => {
                                                //console.log('msg-->', error);
                                            })
                                            //For adobe analytics : starts
                                            let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                                            let action_category = '-' + breadcrumbs[1].label + (breadcrumbs.length >= 3 ? '-' + breadcrumbs[2].label : '') + (breadcrumbs.length >= 4 ? '-' + breadcrumbs[3].label : '')//For adobe bug-06
                                            breadcrumbs.push({ label: this.selectedPartNameForSave });//for adobe bug-19:moved this line down
                                            let eventMetadata = {
                                                action_type: 'button',
                                                action_label: 'add to cart',
                                                action_category: 'category detail' + action_category
                                            };
                                            let events = 'scAdd';
                                            let addToCartProductDetails = {
                                                breadcrumbs: breadcrumbs,
                                                products: { StockKeepingUnit: partNumber },
                                                context: {
                                                    brand: sessionStorage.getItem('vehicleBrand'),
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
                                            alert('error0' + JSON.stringify(error));
                                            this.productNotExistPopupOpen();
                                            this.handleIsLoading();
                                        })
                                    }).catch(error => {
                                        //console.log('error1' + JSON.stringify(error));
                                    })

                                }).catch(error => {

                                    //console.log('error2' + JSON.stringify(error));
                                });
                        }
                    }).catch(error => {
                        //console.log('error3' + JSON.stringify(error));
                    });

                }
            })
            .catch((error) => {
                //console.log('getProductQuan error' + JSON.stringify(error));
            });

    }

    handleAddToCart(event) {
        console.log('handleAddToCart PLP');
        sessionStorage.setItem('addFromPLP', 'true');

        this.handleIsLoading();
        //added by Yashika for 13110: starts
        if (this.isMaintenance == true) {
            this.cartImg = this.maintenanceImagePLP;
        }
        else {
            this.cartImg = this.imgURL;
        }
        //13110: ends
        let partNumber = event.target.dataset.partnumber;
        let price = event.target.dataset.price;
        this.getCartItemsQuantity(partNumber, price);
    }

    notifyAddToCart(partNumber, price) {
        let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
        console.log('storeBrand : ', storeBrand);
        console.log('storeBrand1 : ', localStorage.getItem('cartBrand'));
        console.log('$PLP: notifyAddToCart');
        //HDMP-16101 starts here
        // added on 11/12 start
        if (sessionStorage.getItem('VehicleName')) {
            this.year = sessionStorage.getItem('VehicleYear');
            this.model = sessionStorage.getItem('VehicleModel');
            this.trim = sessionStorage.getItem('VehicleTrim');
            this.vin = sessionStorage.getItem('VehicleVIN');
            this.productModelMarketingName = sessionStorage.getItem('VehicleName');
        }
        // added on 11/12 end
        else if (localStorage.getItem("effectiveVehicle")) {
            var effectiveVehicles = JSON.parse(localStorage.getItem("effectiveVehicle"))['brands'];
            effectiveVehicles.forEach(vehicle => {
                if (vehicle.brand == storeBrand) {
                    this.productModelMarketingName = vehicle.make + ' ' + vehicle.year + ' ' + vehicle.model + ' ' + vehicle.trim;
                    console.log('$PLP: this.productModelMarketingName: ', this.productModelMarketingName);
                }
            })
        }
        //HDMP-16101 ends here
        //Update condition by Faraz for HDMP-16716
        // added on 11/12 start
        if ((localStorage.getItem('cartBrand') && (localStorage.getItem('cartBrand') != sessionStorage.getItem('vehicleBrand')/*sessionStorage.getItem('brand')*/)) ||
            (this.cartBrandDB && this.cartBrandDB.length && this.cartBrandDB != sessionStorage.getItem('vehicleBrand'))
        ) {
            // added on 11/12 end
            this.handleIsLoading();
            this.isModalOpen = true;
        } else {
            addProductToCartItem_Clone({
                accountId: getCurrentDealerId(),
                sku: partNumber,
                communityId: communityId,
                price: price,
                quantity: 1,
                color: '',
                accessoryName: this.selectedPartNameForSave,
                productType: PRODUCT_TYPE, // Added by shalini soni for HDMP-5702 R2 Story
                accImageURL: this.cartImg, // Added by Yashika for 7380
                brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290
                modelId: this.modelId, //added by Yashika for 8708
                vin: this.vin, //added by Yashika for 8708
                sectionId: this.categoryData && this.categoryData.sectionId ? this.categoryData.sectionId : '',//Added by Faraz for 10203
                IllustrationId: this.categoryData && this.categoryData.illustrationId ? this.categoryData.illustrationId : '',//Added by Faraz for 10203
                IllustrationImageId: this.categoryData && this.categoryData.illustrationGroupImageId ? this.categoryData.illustrationGroupImageId : '',//Added by Faraz for 10203
                productModelMarketingName: this.productModelMarketingName//added by Yashika for 10179
            }).then(result => {
                this.notifyToCustomCart(); //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
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
                                localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                            }
                        }
                    }).catch(error => {
                        //console.log('msg-->', error);
                    })
                    this.handleIsLoading();
                    //For adobe analytics : starts
                    let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                    let action_category = '-' + breadcrumbs[1].label + (breadcrumbs.length >= 3 ? '-' + breadcrumbs[2].label : '') + (breadcrumbs.length >= 4 ? '-' + breadcrumbs[3].label : '')//for adobe bug-06
                    breadcrumbs.push({ label: this.selectedPartNameForSave });//for adobe bug-19:moved this line down 
                    let eventMetadata = {
                        action_type: 'button',
                        action_label: 'add to cart',
                        action_category: 'category detail' + action_category
                    };

                    let events = 'scAdd';
                    let addToCartProductDetails = {
                        breadcrumbs: breadcrumbs,
                        products: { StockKeepingUnit: partNumber },
                        context: {
                            brand: sessionStorage.getItem('vehicleBrand'),
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
                alert(JSONS.stringify(error));
                this.productNotExistPopupOpen();
                this.handleIsLoading();
            })
            /*
             * This even will fire the cart icon update
             * After adding a cart item, firing this event will update the cart icon
             * TO DO: add cartitem before dispatching the cartchanged event
             * 
             * pass the product SKU, effective account, community Id, the Price to the backend
             * Backend method will 
             * 1- fetch the current cart id
             * 2- add the cart item - (To do: check the behavior when the cart already contains the same product)
             * 3 - make sure the price passed as parameter is reflected on the cart item
             * 
             * 
             */
        }

        /* //start
        getCartCompatibility({

                PartNumber: partNumber,
                communityId: communityId
            })
            .then(result => {
                console.log('communityId'+communityId)
                console.log('RESULT FROM COMPAT' + result)
                if (result === false) {
                    this.handleIsLoading();
                    this.isModalOpen = true;
                } else {
                    addProductToCartItem({
                            accountId: getCurrentDealerId(),
                            sku: partNumber,
                            communityId: communityId,
                            price: price,
                            quantity: 1
                        }).then(result => {
                            if (result.Id) {
                                this.dispatchEvent(
                                    new CustomEvent('cartchanged', {
                                        bubbles: true,
                                        composed: true
                                    })
                                );
                                this.handleIsLoading();
                            }
                        }).catch(error => {
                            console.log(error);
                            this.productNotExistPopupOpen();
                            this.handleIsLoading();
                        })
                        /*
                         * This even will fire the cart icon update
                         * After adding a cart item, firing this event will update the cart icon
                         * TO DO: add cartitem before dispatching the cartchanged event
                         * 
                         * pass the product SKU, effective account, community Id, the Price to the backend
                         * Backend method will 
                         * 1- fetch the current cart id
                         * 2- add the cart item - (To do: check the behavior when the cart already contains the same product)
                         * 3 - make sure the price passed as parameter is reflected on the cart item
                         * 
                         * 
                         */
        /*}
    })
    .catch(error => {
        console.log(error);
    });*/
    }

    handleIsLoading() {
        this.isLoading = !this.isLoading;
        //console.log('Loading...', this.isLoading);
    }

    buildSelectedProduct(partNumber) {
        if (this.productMap.has(partNumber)) {
            let product = this.productMap.get(partNumber);
            this.productMap.set(partNumber, { quantity: product.quantity + 1 });
            return true;
        } else {
            this.productMap.set(partNumber, { quantity: 1 });
            return false;
        }
    }

    hotspotDataList = [];

    createHotSpotCookieData(selectedPart) {
        const hpData = JSON.parse(this.getCookie('HotSpots'));
        this.hotspotDataList = hpData ? hpData : [];
        const hotspotData = {};
        this.imageCode = this.imgURL ? this.imgURL.split('/').pop() : null;
        if (this.hotspotDataList &&
            this.hotspotDataList.includes(elm => (elm.partNumber === selectedPart.PartNumber &&
                elm.IllustrationReferenceCode === selectedPart.IllustrationReferenceCode &&
                elm.imageCode === this.imageCode))) {
            hotspotData = this.hotspotDataList.find(elm => (elm.partNumber === selectedPart.PartNumber &&
                elm.IllustrationReferenceCode === selectedPart.IllustrationReferenceCode &&
                elm.imageCode === this.imageCode));
            const selectedProdHotSpot = this.hotSpots.filter(elm => elm.IllustrationReferenceCode === selectedPart.IllustrationReferenceCode);
            hotspotData['coordinates'] = selectedProdHotSpot;
        } else {
            hotspotData['imageCode'] = this.imageCode
            hotspotData['partNumber'] = selectedPart.PartNumber;
            hotspotData['IllustrationReferenceCode'] = selectedPart.IllustrationReferenceCode;
            const selectedProdHotSpot = this.hotSpots.filter(elm => elm.IllustrationReferenceCode === selectedPart.IllustrationReferenceCode);
            hotspotData['coordinates'] = selectedProdHotSpot;
            this.hotspotDataList.push(hotspotData);
        }


        this.createCookie('HotSpots', JSON.stringify(this.hotspotDataList), 1);
    }

    navigateToProductDetailPage(event) {
        sessionStorage.removeItem('fromcart');
        sessionStorage.setItem('fromPLP', 'true');
        console.log('$PLP: fromPLP: ', sessionStorage.getItem('fromPLP'));
        console.log('$PLP: fromcart: ', sessionStorage.getItem('fromcart'));
        sessionStorage.removeItem('fromWhichPageUserHasRefresh'); // Added by shalini this backToResultFlag for bug HDMP-7584

        let partNumber = event.target.dataset.partnumber;
        let selectedPart = this.partsList.find((everyPart) => {
            return everyPart.PartNumber == partNumber;
        })

        // multiple tab issue3 starts here
        //this.createCookie('SelectedPart', JSON.stringify(selectedPart), 1);
        sessionStorage.setItem('SelectedPart', JSON.stringify(selectedPart));
        // multiple tab issue3 ends here



        if (selectedPart && selectedPart.productNumber) {
            this.createCookie('ProductNumber', selectedPart.productNumber, 1);
        }
        if (this.breadcrumbsList) {
            // multiple tab issue3 starts here
            //this.createCookie('selectedBreadcrumbs', JSON.stringify(this.breadcrumbsList), 1);
            sessionStorage.setItem('selectedBreadcrumbs', JSON.stringify(this.breadcrumbsList));
            // multiple tab issue3 ends here
        }

        // multiple tab issue3 starts here
        //this.createCookie('SubCategoryImageURL', this.imgURL, 1);
        sessionStorage.setItem('SubCategoryImageURL', this.imgURL);
        // multiple tab issue3 ends here
        if (this.hotSpots) {
            this.createHotSpotCookieData(selectedPart);
        }

        getProduct({
            productId: partNumber
        }).then(result => {
            if (result) {
                window.location.href = '/s/product/' + result.Id;
                // this[NavigationMixin.Navigate]({
                //     // Pass in pageReference
                //     type: 'standard__webPage',
                //     attributes: {
                //         url: '/product/' + result.Id
                //     }
                // });
            }
        }).catch(error => {
            //console.log('msg-->', error);
            this.productNotExistPopupOpen();
        })
    }

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
        //updated by Pradeep Singh for Optiv Issue
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
        // ends here
    }
    //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
    notifyToCustomCart() {
        try {
            // you can also pass like this object info her --> const message = { message: { 'dealerLabel': dealerLabel, 'products': products } 
            const message = { message: 'Calling for update cartItem count' };
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL2, message);
        } catch (error) {
            console.error(error);
        }
    }
    //Ended

    productNotExistPopupOpen() {
        this.isPorductNotExistModalOpen = true;
    }
    productNotExistPopupClose() {
        this.isPorductNotExistModalOpen = false;
    }
    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }
    get isDesktop() {
        if (FORM_FACTOR == 'Large') {
            this.desktop = true;
            this.mobile = false;
            return true;
        } else {
            this.mobile = true;
            this.desktop = false;
            return false;
        }
    }
}
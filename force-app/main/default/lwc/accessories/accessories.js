/******************************************************************************* 

Name: Accessories 

Business Unit: HDM

Date: April, 2021

Description: This component is PLP of accessories. 

******************************************************************************* 

MODIFICATIONS – Date | Dev Name | Method | User Story 

09-06-2022 | Yashika | Added header | 

*******************************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import { getCurrentDealerId } from 'c/utils';
import checkIfUserIsLoggedIn from '@salesforce/apex/B2BGuestUserController.checkIfUserIsLoggedIn';
import addItem_Clone from '@salesforce/apex/B2BGuestUserController.addItem_Clone';
import createUserAndCartSetup from '@salesforce/apex/B2BGuestUserController.createUserAndCartSetup';
import checkProductCompatibility from '@salesforce/apex/B2BGetInfo.checkProductCompatibility';
import getCartCompatibility from '@salesforce/apex/B2BGetInfo.getCartCompatibility';
import addProductToCartItem_Clone from '@salesforce/apex/B2BGuestUserController.addProductToCartItem_Clone';
import Id from '@salesforce/user/Id';
import checkIfUserHasCartAndSetup from '@salesforce/apex/B2BGuestUserController.checkIfUserHasCartAndSetup';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { NavigationMixin } from 'lightning/navigation';
import getProduct from '@salesforce/apex/B2BGuestUserController.getProduct';
import HDMP_MESSAGE_CHANNEL2 from "@salesforce/messageChannel/HDMPMessageForCart__c";
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { CurrentPageReference } from 'lightning/navigation';
import getCartId from '@salesforce/apex/B2BGetInfo.getCartId';
import getAllProuctQuantity from '@salesforce/apex/B2BGetInfo.getAllProuctQuantity';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPermissions from '@salesforce/apex/B2BGuestUserController.createPermissionSetsSynchronous';
import getModelId from '@salesforce/apex/B2BGuestUserController.getModelId';//added by Yashika for 8708
import getCartItemBrand from '@salesforce/apex/B2BGetInfo.getCartItemBrand';//Added by Faraz for HDMP-16716
import hondaImages from '@salesforce/resourceUrl/honda_images';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';//for adobe analytics

const PRODUCT_TYPE = 'Accessory';
//added by yashika for R2 Story accessory search: startes here        
const STORAGE = {
    SEARCHED_TERM: 'searchedTerm',
    CHOSEN_FILTER: 'chosenFilter',
    FROM_PDP: 'FromPDP',
    CLICKED_BACK_TO_RESULT: 'clickedBackToResult',
    YES: 'yes',
    NO: 'no',
    CLOSE: 'close'
} //ends here
export default class Accessories extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;
    @api shoppingBrand;
    @track isLoading = false;
    @track showNullMsg = false;
    @track opcode;//by Yashika for 7911
    //added by Yashika for R2 story accessory search
    //starts here
    _accessoriesList;
    @api
    get accessoriesList() {
        return this._accessoriesList;
    }
    set accessoriesList(value){
        console.log('OUTPUTvalue : ',JSON.parse(JSON.stringify(value)));
        let data = JSON.parse(JSON.stringify(value));
        data.Accessories.forEach(element => {
            if(element.AssetMediumURL && element.AssetMediumURL.includes('/1200px-No_image_available.png')){
                element.AssetMediumURL = this.dreamshopDefaultImage;
            }
            if(element.AssetThumbURL && element.AssetThumbURL.includes('/1200px-No_image_available.png')){
                element.AssetThumbURL = this.dreamshopDefaultImage;
            }
        });
        data.Accessory.forEach(element => {
            if(element.AssetMediumURL && element.AssetMediumURL.includes('/1200px-No_image_available.png')){
                element.AssetMediumURL = this.dreamshopDefaultImage;
            }
            if(element.AssetThumbURL && element.AssetThumbURL.includes('/1200px-No_image_available.png')){
                element.AssetThumbURL = this.dreamshopDefaultImage;
            }
        });
        console.log('OUTPUT : all ',data);
        this._accessoriesList = data;
        this.all_Accessories=data;
        if(this._accessoriesList.Accessory.length==0){
            this.showNullMsg=true;
        }else{
            this.showNullMsg=false;
        }
        this.showColorsList = false;
        this.buildAccessories();
    }
    //ends here
    @api priceType;
    @api breadcrumbsList;
    @track colorNameValue;
    subscription = null;

    // By using the MessageContext @wire adapter, unsubscribe will be called
    // implicitly during the component descruction lifecycle.
    @wire(MessageContext)
    messageContext;
    showColorsList = false;
    colorsList = [];
    discription = '';
    imageURL = '';
    price = '';
    @track all_Accessories;
    catTemp;

    //isLoading = false;
    @track isModalOpen = false;
    @track userId = Id;

    selectedAccOpId;
    selectedCategoryFilter = '';
    succImg = true;
    cartId;
    dreamshopDefaultImage = hondaImages + '/1200px-No_image_available.png';
    @track showOriginalCategoryImage = true;
    @track productModelMarketingName;
    selectedAccessoriesNameForSave = '';
    @track cartBrandDB = '';//Added by Faraz for HDMP-16716

    @track productModelId = '';//for adobe analytics

    disError() {
        this.succImg = false;
    }
    connectedCallback() {
        // Added by Bhawesh on 14-03-2022 for 8354 start
        this.createCookie('ProductFromCart', false, 1);
        this.createCookie('ProductTypeForCart', '', 1);
        // End
        this.subscribeToMessageChannel();
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
                        this.productModelId =element.Model_Id__c;//for adobe bug 31
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
            console.log('vin', this.vin)
            this.productModelMarketingName = this.getCookie('Make') + ' ' + this.year + ' ' + this.model + ' ' + this.trim;
            console.log('productModelMarketingName', this.productModelMarketingName)
        }
        getModelId({
            year: this.year,
            model: this.model,
            trim: this.trim
        })
            .then(result => {
                this.modelId = result.Id;
                if(this.productModelId==''){
                this.productModelId = result.Product_Model_ID__c;//for adobe analytics
                }
            })
            .catch(error => {
                console.log(error)

            }); //ends:8708
        let updatedAccessories = [];
        this.showColorsList = false;
        this.buildAccessories();
        this.fetchcartId();
    }
    fetchcartId() {
        getCartId({ communityId: communityId })
            .then((result) => {
                this.cartId = result;
            })
            .catch((error) => {
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

    buildAccessories() {
        let accObj = JSON.parse(JSON.stringify(this.accessoriesList));

        let copy_AccessoriesList = [];
        JSON.parse(JSON.stringify(accObj.Accessory)).forEach(everyAccessorie => {
            let accessorie = JSON.parse(JSON.stringify(everyAccessorie));
            accessorie.AccessoryDesc = accessorie.AccessoryDesc ? accessorie.AccessoryDesc : ''; //.replace(/(<([^>]+)>)/ig, '')
            //HDMP-5036 starts
            if (accessorie && accessorie.Colors && accessorie.Colors.length && accessorie.Colors[0].colorName != null && accessorie.Colors[0].id != null) {
                accessorie.displayAddToCart = false;
                accessorie.isMultipleColor = true;
            }
            else if (accessorie && accessorie.RequiredAccessories && accessorie.RequiredAccessories.length) {
                accessorie.displayAddToCart = false;
                accessorie.isRequriedProduct = true;
            }
            else {
                accessorie.displayAddToCart = true;
            }
            //HDMP-5036 ends
            accessorie.partNumber = accessorie && accessorie.Colors && accessorie.Colors.length && accessorie.Colors[0].part_number && accessorie.Colors[0].part_number != '' ? accessorie.Colors[0].part_number : '';
            accessorie.disableAddToCartWithZeroAmount = accessorie.msrp <= 0 ? true : false //Added Deepak Mali
            let decimalVal = accessorie.msrp.toString().split('.')[1];
            if ((decimalVal && decimalVal.length < 2) || (decimalVal == null || decimalVal == undefined)) {
                accessorie.msrp = Number(accessorie.msrp).toFixed(2);
            }
            accessorie.shoppingBrand = this.shoppingBrand;
            copy_AccessoriesList.push(accessorie);
        });
        accObj.Accessory = copy_AccessoriesList;
        this._accessoriesList = accObj;

        //this.all_Accessories = this.accessoriesList;
        let tempCategories = [{ section: 'Interior' }, { section: 'Exterior' }, { section: 'Electrical' }, { section: 'All' }];

        let categoriesData = [];
        tempCategories.forEach(element => {
            if (element.section == 'Interior') {
                element.subCategories = this.accessoriesList.Accessory.filter(item => item.displaygroups == 'Interior');
            } else if (element.section == 'Exterior') {
                element.subCategories = this.accessoriesList.Accessory.filter(item => item.displaygroups == 'Exterior');
            } else if (element.section == 'Electrical') {
                element.subCategories = this.accessoriesList.Accessory.filter(item => item.displaygroups == 'Electrical');
            } else if (element.section == 'All') {
                element.subCategories = this.accessoriesList.Accessory;
            }
            categoriesData.push(element);
        });

        this.catTemp = categoriesData;
        if (this.selectedCategoryFilter && this.selectedCategoryFilter.length) {
            this.filteredAccessories('open', this.selectedCategoryFilter);
        }
        else {
            // Added by Bhawesh 05-01-2022 for bug HDMP-6484 to remove duplicate accessories.
            if (this.accessoriesList && this.accessoriesList.Accessory) {
                this.all_Accessories = this.removeDuplicatesAccessories(this.accessoriesList.Accessory);
            } else {
                this.all_Accessories = this.accessoriesList.Accessory;
            }
        }
    }

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            HDMP_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    // Added by Bhawesh 05-01-2022 for HDMP-6484
    removeDuplicatesAccessories(accessoriesList) {
        //console.log('before filtered: ', JSON.stringify(accessoriesList));
        let uniqueAcc = [];
        let dulicateValues = [];
        accessoriesList.forEach(function (item) {
            var i = uniqueAcc.findIndex(x => x.op_cd == item.op_cd);
            if (i <= -1) {
                uniqueAcc.push(item);
            } else {
                dulicateValues.push(item);
            }
        });
        return uniqueAcc;
    }
    // Handler for message received by component
    handleMessage(data) {
        if (data.message.products) {
            this._accessoriesList = data.message.products && data.message.products.myAccessories ? data.message.products.myAccessories : data.message.products;
            this.buildAccessories();
            let colorList = this.accessoriesList.Accessory.find(item => {
                return item.op_cd == this.selectedAccOpId;
            });
            if (colorList && colorList.Colors && colorList.Colors.length && colorList.Colors[0].colorName != "" && colorList.Colors[0].id != "") {
                this.colorsList = JSON.parse(JSON.stringify(colorList.Colors));
            }
            this.priceType = 'Dealer Price';
        }
    }

    renameKey(object, key, newKey) {
        const clonedObj = Object.assign({}, object);
        const targetKey = clonedObj[key];
        delete clonedObj[key];
        clonedObj[newKey] = targetKey;
        return clonedObj;
    }

    handleOnSelectAccessorie(event) {
        let accessorieId = event.target.dataset.id;
        this.selectedAccOpId = accessorieId;
        let colorList = this.accessoriesList.Accessory.find(item => {
            return item.op_cd == accessorieId;
        });
        //---Added Shalini soni---------------START ---------------------------
        let selectedAccessoryName = colorList.AccessoryName

        let obj = { label: selectedAccessoryName, name: selectedAccessoryName, id: selectedAccessoryName };
        let newArr = [];
        newArr = JSON.parse(JSON.stringify(this.breadcrumbsList));
        newArr.push(JSON.parse(JSON.stringify(obj)));
        this.breadcrumbsList = newArr;
        const selectedEvent = new CustomEvent('openaccessories', { detail: this.breadcrumbsList });

        this.dispatchEvent(selectedEvent);
        //---Added Shalini soni---------------END ---------------------------
        this.colorNameValue = colorList.Colors[0].colorName
        // multiple tab issue3 starts here 
        //this.createCookie('selectedBreadcrumbs', JSON.stringify(this.breadcrumbsList), 1);
        sessionStorage.setItem('selectedBreadcrumbs', JSON.stringify(this.breadcrumbsList));
        // multiple tab issue3 ends here 
        if (colorList && colorList.Colors && colorList.Colors.length && colorList.Colors[0].colorName != "" && colorList.Colors[0].id != "") {
            this.discription = colorList.AccessoryDesc;
            this.imageURL = colorList.AssetThumbURL ? colorList.AssetThumbURL : '';
            this.price = colorList.msrp ? colorList.msrp : '';
            this.colorsList = JSON.parse(JSON.stringify(colorList.Colors));
            this.showColorsList = true;
        }
    }

    getProductIdAndRedirectToPDP(selectedPartNumber) {
        getProduct({ productId: selectedPartNumber }).then(result => {
            if (result) {
                //Added shalini soni
                let productName = result.Name

                let obj = { label: productName, name: productName, id: productName };
                let newArr = [];
                newArr = JSON.parse(JSON.stringify(this.breadcrumbsList));
                newArr.push(JSON.parse(JSON.stringify(obj)));
                this.breadcrumbsList = newArr;
                //const selectedEvent = new CustomEvent('openaccessories', { detail: this.breadcrumbsList});		
                //this.dispatchEvent(selectedEvent);

                // multiple tab issue3 starts here 
                //this.createCookie('selectedBreadcrumbs', JSON.stringify(this.breadcrumbsList), 1);
                sessionStorage.setItem('selectedBreadcrumbs', JSON.stringify(this.breadcrumbsList));
                // multiple tab issue3 ends here 
                //Added shalini soni

                window.location.href = '/s/product/' + result.Id;
                /*this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/product/' + result.Id
                    }
                }); */
            }
        }).catch(error => {
        })
    }

    handleToRedirectOnPDP(event) {
        sessionStorage.removeItem('fromcart');
        sessionStorage.setItem('fromPLP', 'true');
        console.log('$ACC: fromPLP: ', sessionStorage.getItem('fromPLP'));
        console.log('$ACC: fromcart: ', sessionStorage.getItem('fromcart'));
        let opId = event.target.dataset.id;
        let selectedAcc = this.all_Accessories.find(item => item.op_cd == opId);
        this.createCookie('selectedAccessorie', JSON.stringify(selectedAcc), 1);
        if (selectedAcc && selectedAcc.RequiredAccessories && selectedAcc.RequiredAccessories.length) {
            let requiredProductOpId = [];
            JSON.parse(JSON.stringify(selectedAcc.RequiredAccessories)).forEach(rp => {
                requiredProductOpId.push(rp.op_cd);
            });
            let newArray = this.accessoriesList.Accessory.filter(acc => {
                return requiredProductOpId.includes(acc.op_cd);
            });

            localStorage.setItem('RequiredProducts', JSON.stringify(newArray));
            // this.createCookie('RequiredProducts', JSON.stringify(newArray),1);
        } else {
            // this.createCookie('RequiredProducts', "", -1);
            localStorage.removeItem('RequiredProducts');
        }


        // this.createCookie('allAccessories', JSON.parse(JSON.stringify(this.all_Accessories)), 1);

        let colors = this.all_Accessories.find(item => item.op_cd == opId).Colors;
        colors = JSON.parse(JSON.stringify(colors));
        if (colors && colors.length && colors[0].part_number) {
            let partNumber = colors[0].part_number
            this.getProductIdAndRedirectToPDP(partNumber);
        }


    }

    @api
    filteredAccessories(mode, category) {
        this.showColorsList = false;
        if (mode && mode == 'open' && category) {
            this.selectedCategoryFilter = category;
            // Added by Bhawesh 05-01-2022 for bug HDMP-6484 to remove duplicate accessories.
            let allAcc_Copy = this.catTemp.find(item => item.section == category).subCategories;
            if (allAcc_Copy) {
                this.all_Accessories = this.removeDuplicatesAccessories(allAcc_Copy);
            } else {
                this.all_Accessories = allAcc_Copy;
            }
            // End Bhawesh         
        }
        else if (mode && mode == 'close') {
            this.selectedCategoryFilter = '';
            // Added by Bhawesh 05-01-2022 for bug HDMP-6484 to remove duplicate accessories.
            let allAcc_Copy = this.catTemp.find(item => item.section == 'All').subCategories;
            if (allAcc_Copy) {
                this.all_Accessories = this.removeDuplicatesAccessories(allAcc_Copy);
            } else {
                this.all_Accessories = allAcc_Copy;
            }
            // End Bhawesh 
        }
    }

    @api
    filterWithSubAccessrories(opId) {
        if (opId) {
            let colorList = this.accessoriesList.Accessory.find(item => {
                return item.op_cd == opId;
            });
            if (colorList && colorList.Colors && colorList.Colors.length && colorList.Colors[0].colorName != "" && colorList.Colors[0].id != "") {
                this.discription = colorList.AccessoryDesc;
                this.imageURL = colorList.AssetThumbURL ? colorList.AssetThumbURL : '';
                this.price = colorList.msrp ? colorList.msrp : '';
                this.colorsList = JSON.parse(JSON.stringify(colorList.Colors));
                this.showColorsList = true;
            }
        }
    }

    showToastMessages(title, variant, message) {
        this.dispatchEvent(new ShowToastEvent({ title: title, variant: variant, message: message, mode: 'dismissable' }));
    }
    getProductQuan(partNumber, price, opCode) {
        getAllProuctQuantity({ cartId: this.cartId })
            .then((result) => {
                let prodWithQuantity = result;
                let proceedNext = false;
                let totalQuantity = 0;
                if (prodWithQuantity && Object.keys(prodWithQuantity).length != 0) {
                    for (var i in prodWithQuantity) {
                        totalQuantity += prodWithQuantity[i];
                        if (i == partNumber) {
                            let quantity = parseInt(prodWithQuantity[i]) + parseInt(1);
                            if (quantity > 25) {
                                this.isLoading = false;
                                this.showToastMessages('Quantity Limit', 'error', 'The Product cannot be added as its already in cart with its maximum quantity.');
                                this.proceedNext = false;
                                break;
                            } else { proceedNext = true; }
                        } else { proceedNext = true; }
                    }
                    totalQuantity += parseInt(1);
                    if (totalQuantity > 25) {
                        this.isLoading = false;
                        this.showToastMessages('Quantity Limit', 'error', 'Sorry we can only have maximum of 25 quantity in an order.');
                        proceedNext = false;
                    }
                    // Added by Lakshman on 02/03/2022 - HDMP-5074 EPIC Ends
                } else {
                    console.log('$ACC: Step 10');
                    localStorage.setItem('cartBrand', sessionStorage.getItem('brand'));
                    proceedNext = true;
                }
                if (proceedNext) {
                    this.cartAddition(partNumber, price, opCode);
                }
            })
            .catch((error) => {
            });
    }

    handleAddToCart(event) {
        this.handleIsLoading();
        let opCode = event.target.dataset.opcode;
        let price = event.target.dataset.price;
        let partNumber = event.target.dataset.opcode ? this.getPartNumber(opCode) : event.target.dataset.partnumber;
        let accObj = JSON.parse(JSON.stringify(this.accessoriesList));
        this.getProductQuan(partNumber, price, opCode);

    }
    //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
    notifyToCustomCart() {
        // you can also pass like this object info her --> const message = { message: { 'dealerLabel': dealerLabel, 'products': products } 
        const message = { message: 'Calling for update cartItem count' };
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL2, message);
    }
    //Ended

    cartAddition(partNumber, price, opCode) {
        //LOCAL STORAGE FOR ACCESSORIES PRODUCT                      
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
            else{
            var cObj = {};
            Object.defineProperty(cObj,partNumber,{
                value: true,
                writable: true,
                enumerable: true,
                configurable: true
                })
            localStorage.setItem('VinFitmentCheck',JSON.stringify(cObj));
            }
        HDMP-12342 ends here*/
        try {
            //Added by Shalini 90799
            let selectedAcc = {};
            let existingallProductDetailsList = []
            let alreadyExistInList = false;

            existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));
            if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                existingallProductDetailsList.forEach(element => {
                    let elementNumber = element.partNumber.replace(/^"|"$/g, '');//Remove double qcuotes from partNumber
                    //modified by Yashika for 8035 : start
                    if (element.ProductTypeForCart == "Accessorie" && !alreadyExistInList) {

                        let opCodeForAcc = element.selectedAcc.op_cd != undefined ? element.selectedAcc.op_cd : '';
                        if (elementNumber == partNumber && opCodeForAcc == opCode) {
                            // added by Pradeep for HDMP-8035
                            this.opcode = opCode;
                            //ends here
                            alreadyExistInList = true;
                            if (element.selectedAcc && element.selectedAcc.AccessoryName) {
                                this.selectedAccessoriesNameForSave = element.selectedAcc.AccessoryName;
                            }
                        }
                    }
                    else if (element.ProductTypeForCart != "Accessorie") {
                        if (elementNumber == partNumber) {
                            alreadyExistInList = true;
                            if (element.selectedAcc && element.selectedAcc.AccessoryName) {
                                this.selectedAccessoriesNameForSave = element.selectedAcc.AccessoryName;
                            }
                        }
                    } //ends: 8035
                });
            }
            if (!alreadyExistInList) {
                //Fine single selected record from all accessoriesList
                let accObj = JSON.parse(JSON.stringify(this.accessoriesList));
                JSON.parse(JSON.stringify(accObj.Accessory)).forEach(everyAccessorie => {
                    let accessorie = JSON.parse(JSON.stringify(everyAccessorie));
                    let accPartNumber = accessorie && accessorie.Colors && accessorie.Colors.length && accessorie.Colors[0].part_number && accessorie.Colors[0].part_number != '' ? accessorie.Colors[0].part_number : '';
                    //modified by Yashika for 8035 : start

                    let opCodeForAcc = accessorie.op_cd;
                    if (opCodeForAcc == opCode) {
                        selectedAcc = everyAccessorie;
                        return;
                    } //ends: 8035
                });

                let allAcccDetailsList = [];
                let productDetails = { SelectedPart: '', ProductNumber: '', SelectedBreadcrumbs: '', SubCategoryImageURL: '', partNumber: '', ProductType: '', ProductFromCart: false };
                productDetails.SelectedPart = '';
                productDetails.selectedAcc = selectedAcc;
                productDetails.ProductNumber =
                    productDetails.SelectedBreadcrumbs = this.breadcrumbsList;
                productDetails.SubCategoryImageURL =
                    productDetails.partNumber = JSON.stringify(partNumber);
                productDetails.ProductTypeForCart = 'Accessorie';
                this.imageURL = selectedAcc.AssetThumbURL; // Added by Yashika for 7380
                this.opcode = selectedAcc.op_cd;
                productDetails.ProductFromCart = true;
                productDetails['opCode'] = this.opcode;
                allAcccDetailsList.push(productDetails);

                this.selectedAccessoriesNameForSave = selectedAcc && selectedAcc.AccessoryName ? selectedAcc.AccessoryName : '';

                let existingallProductDetailsList = JSON.parse(localStorage.getItem('allProductDetailsList'));

                if (existingallProductDetailsList && existingallProductDetailsList.length > 0 && existingallProductDetailsList != 'undefined') {
                    existingallProductDetailsList.push(productDetails);
                    localStorage.setItem('allProductDetailsList', JSON.stringify(existingallProductDetailsList));
                } else {
                    localStorage.setItem('allProductDetailsList', JSON.stringify(allAcccDetailsList));
                }
            }

        } catch (error) {
        }
        checkIfUserIsLoggedIn().then(result => {
            if (result) {
                this.userId = result;
                checkIfUserHasCartAndSetup({
                    communityId: communityId,
                    userId: this.userId
                })
                    .then(result => {
                        if (result) {
                            this.cartId = result.cartId;
                            this.getCartItemBrand(partNumber, price);
                        }
                    })
                    .catch(error => {
                    });
            } else {
                //added by yashika for R2 Story accessory search: startes here
                let searchVal = sessionStorage.getItem(STORAGE.SEARCHED_TERM);
                let chosenFilter = sessionStorage.getItem(STORAGE.CHOSEN_FILTER);
                if (searchVal != null && chosenFilter != null) {
                    sessionStorage.setItem(STORAGE.CLICKED_BACK_TO_RESULT, STORAGE.YES);
                }//ends here
                let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
                createUserAndCartSetup({ accountId: getCurrentDealerId() })
                    .then(result => {
                        let userRecord = result.userId;
                        let cartId = result.cartId;
                        let findAccessory = JSON.parse(JSON.stringify(this.accessoriesList)).Accessories.find((item) => {
                            return item.op_cd == this.opcode
                        });
                        console.log('findAccessory : ', findAccessory);
                        createPermissions({
                            userId: userRecord,
                        }).then(result => {
                            addItem_Clone({
                                userId: userRecord,
                                productId: partNumber,
                                quantity: 1,
                                redirectUrl: window.location.href,
                                wc: cartId,
                                price: price,
                                color: '',
                                accessoryName: this.selectedAccessoriesNameForSave,
                                productType: PRODUCT_TYPE, // Added by shalini soni for HDMP-5702 R2 Story
                                accImageURL: this.imageURL, // Added by Yashika for 7380
                                opCode: this.opcode, //for 7911
                                brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290
                                modelId: this.modelId, //added by Yashika for 8708
                                vin: this.vin, //added by Yashika for 8708
                                productModelMarketingName: this.productModelMarketingName,//added by Yashika for 10179
                                itemPackageQuantity: findAccessory.quantity ? findAccessory.quantity : 1,
                            }).then(redirectUrl => {
                                getProduct({
                                    productId: partNumber
                                }).then(result => {
                                    if (result) {
                                        this.notifyToCustomCart(); //Added Deepak Mali to show cartIteam count on custom icon for : HDMP-5024 Self-Registeration Stories
                                        if (sessionStorage.getItem('breadcrumbsMap')) {
                                            let breadcrumbsMap = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap')));
                                            let breadcrumbsProductMap = new Map(JSON.parse(localStorage.getItem('breadcrumbsProductMap')))
                                            breadcrumbsProductMap.set(result.Id, breadcrumbsMap.get(sessionStorage.getItem('brand')));
                                            localStorage.setItem('breadcrumbsProductMap', JSON.stringify([...breadcrumbsProductMap]));
                                            window.location.replace(redirectUrl);
                                        }
                                    }
                                }).catch(error => {

                                })
                                //For adobe analytics : starts
                                let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                                let action_category = '-' + breadcrumbs[1].label + (breadcrumbs.length >= 3 ? '-' + breadcrumbs[2].label : '') + (breadcrumbs.length == 4 ? '-' + breadcrumbs[3].label : '')//for adobe bug-13(moved this line up)
                                breadcrumbs.push({ label: this.selectedAccessoriesNameForSave });//for adobe bug-05
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
                                console.log('error', error)
                            })
                        }).catch(error => {
                        })
                    }).catch(error => {
                    });
            }
        }).catch(error => {
        });
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isLoading = false;
        this.isModalOpen = false;
    }

    notifyAddToCart(partNumber, price) {

        let storeBrand = sessionStorage.getItem('brand'); // Added by shalini 10-3-2022 for HDMP-8290
        //Update condition by Faraz for HDMP-16716
        // added on 11/12 start
        if ((localStorage.getItem('cartBrand') && (localStorage.getItem('cartBrand') != sessionStorage.getItem('vehicleBrand'))) ||
            (this.cartBrandDB && this.cartBrandDB.length && this.cartBrandDB != sessionStorage.getItem('vehicleBrand'))
        ) {
            // added on 11/12 end
            this.handleIsLoading();
            this.isModalOpen = true;
        } else {
            let findAccessory = JSON.parse(JSON.stringify(this.accessoriesList)).Accessories.find((item) => {
                return item.op_cd == this.opcode
            });
            console.log('findAccessory : ', findAccessory);
            addProductToCartItem_Clone({
                accountId: getCurrentDealerId(),
                sku: partNumber,
                communityId: communityId,
                price: price,
                quantity: 1,
                accessoryName: this.selectedAccessoriesNameForSave,
                color: '',
                productType: PRODUCT_TYPE, // Added by shalini soni for HDMP-5702 R2 Story
                accImageURL: this.imageURL, // Added by Yashika for 7380
                opCode: this.opcode, //for 7911
                brand: storeBrand, // Added by shalini 10-3-2022 for HDMP-8290 
                modelId: this.modelId, //added by Yashika for 8708 
                vin: this.vin, //added by Yashika for 8708    
                productModelMarketingName: this.productModelMarketingName,//added by Yashika for 10179 
                itemPackageQuantity: findAccessory.quantity ? findAccessory.quantity : 1,
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
                    })
                    this.handleIsLoading();
                    //For adobe analytics : starts
                    let breadcrumbs = new Map(JSON.parse(sessionStorage.getItem('breadcrumbsMap'))).get(sessionStorage.getItem('brand'));
                    let action_category = '-' + breadcrumbs[1].label + (breadcrumbs.length >= 3 ? '-' + breadcrumbs[2].label : '') + (breadcrumbs.length == 4 ? '-' + breadcrumbs[3].label : '')//for adobe bug-13(moved this line up)
                    breadcrumbs.push({ label: this.selectedAccessoriesNameForSave });//for adobe bug-05
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
    }

    handleIsLoading() {
        this.isLoading = !this.isLoading;
    }

    getPartNumber(opCode) {
        let colors = this.all_Accessories.find(item => item.op_cd == opCode).Colors;
        colors = JSON.parse(JSON.stringify(colors));
        if (colors && colors.length && colors[0].part_number) {
            return colors[0].part_number
        }
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
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
    }

    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }

    handleShowDefaultImage(event) {
        let erroredIndex = event.currentTarget.dataset.index;
        let cloneOfAll_Accessories = this.all_Accessories;
        cloneOfAll_Accessories[erroredIndex].AssetThumbURL = '';
        // Added by Bhawesh 05-01-2022 for bug HDMP-6484 to remove duplicate accessories.
        let allAcc_Copy = cloneOfAll_Accessories;
        if (allAcc_Copy) {
            this.all_Accessories = this.removeDuplicatesAccessories(allAcc_Copy);
        } else {
            this.all_Accessories = allAcc_Copy;
        }
    }

    handleOnImageLoad(event) {
        this.showOriginalCategoryImage = false;
    }
}
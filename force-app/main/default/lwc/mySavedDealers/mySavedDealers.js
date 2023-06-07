// Created Component by shalini soni HDMP-212 R2 Story MyDealers
import { LightningElement, track, api, wire } from 'lwc';
import myPNG_icon from '@salesforce/resourceUrl/MapImage';
// Import message service features required for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { getCurrentDealer,getCurrentVehicle } from 'c/utils';//Modified By Bhawesh 11-03-2022
import communityId from '@salesforce/community/Id';
import updateDealerIdOnCart from '@salesforce/apex/B2B_LoggedInUserMyDealers.updateDealerIdOnCart';
import GetDealerPrice from '@salesforce/apex/B2B_INSystemIntegration.GetDealerPrice';//Added  By Bhawesh 11-03-2022;
import updateCartItems from '@salesforce/apex/B2BGuestUserController.updateCartItems';
import getActiveCartItems from '@salesforce/apex/B2BGuestUserController.getActiveCartItems';
import getBrand from '@salesforce/apex/B2B_VehicleSelectorController.getBrand';
import saveLastDealer from '@salesforce/apex/B2B_ShoppingSelectionController.saveLastDealer';
import isguest from '@salesforce/user/isGuest';
const BRAND = 'brand';
const BRANDS = 'brands';
const SELECTED_DEALER = 'selectedDealer';
const EFFECTIVE_DEALER = 'effectiveDealer';
const UNDEFINED = 'undefined';
export default class MySavedDealers extends LightningElement {

    @track allDealerValues = { Name: '', Street: '', City: '', State: '', Phone: '', Email: '', operationHours: '', firstName: '', lastName: '', brandName: '', zipCode: '',shippingtaxstate:'' };
    mapIcon = myPNG_icon;
    @wire(MessageContext)
    messageContext;

    //Added by Shalini for bug-8197 
    @track dealerList = [];
    @track effectiveAccountId;
    @track brandName;
    @track isDealerLoading;
    @api 
    get allDealerList(){
        console.log('getter called test##');
        return this.dealerList;
    }
    set allDealerList(value){
        console.log('setter called test##',JSON.parse(JSON.stringify(value)));
        try {
            let dealer = getCurrentDealer();
            let tempList = [];
            value.find((item) => {
                if (dealer && dealer.dealerNo == item.PoIId__c) {
                    tempList.push({
                        ...item,
                        'isSelectedDealer': true,
                        'boxStyle': 'slds-card appendedCard boxBoder'
                    }); // creating new property to hide/show button also added next property by Shalini soni for HDMP-7572 Bug
                } else {
                    this.dealerList = tempList.push({
                        ...item,
                        'boxStyle': 'slds-card appendedCard'
                    }); //  Added next property by Shalini soni for HDMP-7572 Bug
                }
            });
            tempList.forEach(currentItem => {
                if(currentItem.Operation_Hour__c && currentItem.Operation_Hour__c.length > 0) {
                    let oprationH = currentItem.Operation_Hour__c.split(';');
                    currentItem.oprationHoursArr = oprationH;
                }
                //Lakshmi HDMP-19454,19445 - Sales tax juridisction
            if(currentItem.Sales_Tax_Jurisdiction__c){
                 if(currentItem.Sales_Tax_Jurisdiction__c.split(';').length > 50){
                    currentItem.shippingtaxstate = 'All 50 States';
                }else{
                    currentItem.shippingtaxstate = currentItem.Sales_Tax_Jurisdiction__c.replaceAll(';',',');
                 }
            } else{
                    currentItem.shippingtaxstate = currentItem.BillingState; //Lakshmi HDMP-19495
                }
                });
            this.dealerList = tempList;
            //Lakshmi HDMP-19454,19445 - Sales tax juridisction
        } catch (error) {
            //Lakshmi Error handling with proper message
            console.error('Error at My Saved Dealers component:'+ error.message);
        }
    }
    //ENDS
    connectedCallback() {
        console.log('test##',JSON.parse(JSON.stringify(this.dealerList)));
        this.getBrandDetails();
    }
    //Added by shalini for HDMP-8290 17-03-2022
    async getBrandDetails() {
        let storedCartId = localStorage.getItem('cartId');
        console.log('##calling', storedCartId);
        if (storedCartId) {
            await getBrand({
                cartId: storedCartId
            }).then(result => {
                if (result) {
                    let brand = result;
                    console.log('##result brand @', brand);
                    this.brandName = brand;
    }
            }).catch(error => {

            })
        }
    }
    // This function to select the dealer from my Dealers tab will show the on button label 
    selectDealer(event) {
        sessionStorage.setItem('donotCloseModal','false');//added by Yashika for hdmp-17913
        this.isDealerLoading = true;
        let opCodeList = [];
        let partNumberList = [];
        let brandDivision;
        const dealerId = event.target.name;
        const selectedRecordId = event.target.name.substring(0, 15);
        this.effectiveAccountId = selectedRecordId;
        const dealerLabel = event.target.getAttribute('data-title');
        const dealerNo = event.target.getAttribute('data-dealerno');
        let products = JSON.parse(sessionStorage.getItem('products'));
        let accessories = JSON.parse(sessionStorage.getItem('accessories'));
        let brand = sessionStorage.getItem(BRAND);
        let vehicle = getCurrentVehicle();
        //Added by shalini for HDMP-8290 17-03-2022
        if (!vehicle) {
            console.log('##brandName', this.brandName);
            if (this.brandName) {
                brandDivision = this.brandName == 'Honda' ? 1 : 2;
            }
        } else {
            brandDivision = vehicle.iNDivisionID__c;
        }
       
        let checkDealerPriceUpdated = false;
        console.log('vehicle : ', vehicle);
        console.log('#### products data : ', products);
        console.log('accessories data : ', accessories);

        if (products && products.Parts) {
            products.Parts.forEach(part => {
                partNumberList.push(part.PartNumber);
            });
        }

        if (accessories && accessories.Accessory) {
            accessories.Accessory.forEach(accessory => {
                if (accessory && accessory.op_cd) {
                    opCodeList.push(accessory.op_cd);
                }
            });
        }

        let uniquePartNumberList = partNumberList.filter(function (item, index, inputArray) {
            return inputArray.indexOf(item) == index;
        });

        let uniqueOpCodeList = opCodeList.filter(function (item, index, inputArray) {
            return inputArray.indexOf(item) == index;
        });

        this.createDataForSelectedDealer(event.target.name);
        this.buildEffectiveDealer(brand, this.effectiveAccountId, dealerLabel, dealerNo);
        

        this.updateDealerOnCart(dealerId);
        if (brandDivision) { //Added this by shalini 17-3-2022 for bug 8426
            if(uniquePartNumberList.length > 0 || uniqueOpCodeList.length > 0){
                GetDealerPrice({
                    dealerNo: dealerNo,
                        divisionId: brandDivision, //vehicle.iNDivisionID__c,
                    partNumbers: JSON.stringify(uniquePartNumberList),
                    accessories: JSON.stringify(uniqueOpCodeList)
                }).then(result => {
                    if (result) {
                        let dealerPriceResult = JSON.parse(result);
                        console.log('dealerPriceResult : ',dealerPriceResult);
                        getActiveCartItems({ communityId: communityId  })
                        .then(result => {
                            if(result && result.length){
                                let parts_Copt = [];
                                let beforeAccessoryRespose = accessories;
                                const opcodeMap = new Map();
    
                                if (beforeAccessoryRespose && beforeAccessoryRespose.Accessory) {
                                    result.forEach(response => {
                                        beforeAccessoryRespose.Accessory.forEach(beforeAccessory => {
                                            beforeAccessory.Colors.forEach(color => {
                                                if (color.part_number == response.Product2.StockKeepingUnit) {
                                                    opcodeMap.set(beforeAccessory.op_cd, color.part_number);
                                                }
                                            });
                                        });
                                    });
                                }
                                console.log('OUTPUT  OUTPUTOUTPUTOUTPUT: ');
                                if (dealerPriceResult.Parts) {
                                    [...dealerPriceResult.Parts].forEach(everyPart => {
                                        let obj = JSON.parse(JSON.stringify(everyPart));
                                        obj.DealerPrice = obj.DIYPrice;
                                        parts_Copt.push(obj);
                                        products.Parts.forEach(product => {
                                            if (obj.PartNumber === product.PartNumber) {
                                                product.SuggestedRetailPriceAmount = obj.DIYPrice;
                                            }
                                        });
                                    });
                                }
    
                                        if (dealerPriceResult.Accessories && beforeAccessoryRespose && beforeAccessoryRespose.Accessory) {
                                    beforeAccessoryRespose.Accessory.forEach(beforeAccessory => {
                                        dealerPriceResult.Accessories.forEach(Accessories => {
                                            let obj = JSON.parse(JSON.stringify(Accessories));
                                            if (beforeAccessory.op_cd == obj.OpCode) {
                                                if (opcodeMap.has(obj.OpCode)) {
                                                    obj.DealerPrice = obj.DIYPrice;
                                                    obj.PartNumber = opcodeMap.get(beforeAccessory.op_cd);
                                                    parts_Copt.push(obj);
                                                }
                                                        beforeAccessory.msrp = Accessories.DIYPrice;
                                            }
                                                    
                                        });
                                    });
                                    accessories = beforeAccessoryRespose;
                                }
                                //End
    
                                let selectedartNumbers = [...new Map(parts_Copt.map(item => [item['PartNumber'], item])).values()];
                                let adToCart = {accountId: this.effectiveAccountId,communityId: communityId,products: selectedartNumbers};
                                updateCartItems({adToCart: adToCart}).then(result => {
                                    console.log('updatecart with dealer price', result);
                                    this.isLoading = false;
    
                                    console.log('OUTPUT : ', products);
                                    if (products == null || products == 'null') {
                                        products = accessories;
                                    }
                                    else if (products && accessories) {
                                        products.myAccessories = accessories;
                                    }
    
                                    console.log('OUTPUT : ', this.messageContext);
                                    const message = { message: { 'dealerLabel': dealerLabel, 'products': products } };
                                    this.handleSelectDealer(dealerLabel, brand, dealerId);
                                    publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                                }).catch(error => {
                                    console.log('error from select ', JSON.stringify(error));
                                });
    
                            }else{
                                let beforeAccessoryRespose = accessories;
                                if (dealerPriceResult && dealerPriceResult.Parts && products && products.Parts) {
                                    console.log('In If condition dealerPriceResult.Parts');
                                    dealerPriceResult.Parts.forEach(pdp => {
                                        let obj = JSON.parse(JSON.stringify(pdp));
                                        products.Parts.forEach(product => {
                                            if (obj.PartNumber === product.PartNumber) {
                                                product.SuggestedRetailPriceAmount = obj.DIYPrice;
                                                console.log('product.SuggestedRetailPriceAmount : ', product.SuggestedRetailPriceAmount);
                                            }
                                        });
                                    });
                                }
                                if (dealerPriceResult.Accessories && beforeAccessoryRespose && beforeAccessoryRespose.Accessory) {
                                    dealerPriceResult.Accessories.forEach(delaerPriceResponse => {
                                        beforeAccessoryRespose.Accessory.forEach(accessory => {
                                            if (accessory.op_cd == delaerPriceResponse.OpCode) {
                                            accessory.msrp = delaerPriceResponse.DIYPrice;
                                                    }
                                        });
                                    });
                                    accessories = beforeAccessoryRespose;
                                }
                        
                                this.isLoading = false;
                                if (products == null || products == 'null') {
                                    products = accessories;
                                }
                                if (accessories && accessories.Accessory) {
                                    let acc = {Accessories: accessories.Accessories, Accessory:accessories.Accessory, 
                                        Dealer_number: accessories.Dealer_number, Division: accessories.Division, 
                                        ModelAssetURL: accessories.ModelAssetURL, ModelID: accessories.ModelID
                                    };
                                    products.myAccessoriess = acc; // Added by Bhawesh for HDMP-8458
                                }
                                console.log('OUTPUT : products info before send', products);
                                console.log('### this.messageContext : ', this.messageContext);
                                const message = { message: { 'dealerLabel': dealerLabel, 'products': products } };
                                console.log('-=-=-=2 publish=-=-=-');
                                this.handleSelectDealer(dealerLabel, brand, dealerId);
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                            }
                            })
                            .catch(error => {
                                console.error('Error:', error);
                            });
    
                        //checkDealerPriceUpdated = false;
                    }
                }).catch(error => {
                    console.log('ERROR- this.messageContext : ', this.messageContext);
                    console.log(error);
                });
            }else{
                this.handleSelectDealer(dealerLabel, brand, dealerId);
                const message = { message: { 'dealerLabel': dealerLabel, 'products': products } };
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
            }
        }
        
        //this.handelGetDealerPrice(dealerNo, vehicle.iNDivisionID__c, uniquePartNumberList,uniqueOpCodeList)
        // const message = { message: { 'dealerLabel': dealerLabel, 'products': '' } };
        //publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);

    }
    handleSelectDealer(buttonLabel, brand, dealerId) {
        console.log('$MSD: handleSelectDealer: ', buttonLabel);
        // multiple cart issue 2 starts here
        //brand = localStorage.getItem('brand') ?? localStorage.getItem('cartBrand');
        brand = sessionStorage.getItem('brand') ;
        // multiple cart issue 2 ends here
        console.log('$MSD: brand: ', brand);
        console.log('$MSD: dealerId: ', dealerId);
        sessionStorage.setItem('guestHasDealer','true');
        if(!isguest){
            saveLastDealer({shoppingSelection : {Product_Subdivision__c: brand,Last_Dealer__c: dealerId}}).then((result) => {
                console.log('$MSD: saveLastDealer result', result);
            }).catch((error) => {
                console.error('$MSD: saveLastDealer error', error);
            });
        }
    }

    updateDealerOnCart(dealerAccountId){
        updateDealerIdOnCart({communityId: communityId,dealerId: dealerAccountId})
            .then(result=>{
            })
            .catch(error=>{
                console.error(error);
        });
    }

    // This function to Create data to show as selected dealer from all saved dealers 
    createDataForSelectedDealer(selectedRecordId) {

        let selectedRecord = this.dealerList.find(element => element.Id == selectedRecordId);
        let brandName = sessionStorage.getItem(BRAND);;
        this.allDealerValues.Name = selectedRecord.Name;
        this.allDealerValues.Street = selectedRecord.ShippingStreet
        this.allDealerValues.City = selectedRecord.BillingCity
        this.allDealerValues.State = selectedRecord.BillingState
        this.allDealerValues.Phone = selectedRecord.Phone
        this.allDealerValues.Email = selectedRecord.Email__c
        this.allDealerValues.operationHours = selectedRecord.Operation_Hour__c
        this.allDealerValues.firstName = selectedRecord.First_Name__c
        this.allDealerValues.lastName = selectedRecord.Last_Name__c
        this.allDealerValues.brandName = brandName;
        this.allDealerValues.zipCode = selectedRecord.BillingPostalCode;
        this.allDealerValues.dealerUrl = selectedRecord.Website;
        this.allDealerValues.POIId = selectedRecord.PoIId__c;
        this.allDealerValues.Id = selectedRecord.Id;
        this.allDealerValues.isSavedDealer = true;
        this.allDealerValues.shippingtaxstate=selectedRecord.Sales_Tax_Jurisdiction__c.replaceAll(';',',');

        let allDealerList = [];
        if (sessionStorage.getItem(SELECTED_DEALER)) {
            allDealerList = JSON.parse(sessionStorage.getItem(SELECTED_DEALER));
            if (allDealerList && allDealerList.length > 0 && allDealerList != UNDEFINED) {

                let hasExist = false;
                let foundIndex = allDealerList.findIndex(element => element.brandName == brandName);
                if (foundIndex > -1) {
                    allDealerList[foundIndex] = this.allDealerValues
                } else {
                    allDealerList.push(this.allDealerValues);
                }
            }
        } else {
            allDealerList.push(this.allDealerValues);
        }
        sessionStorage.setItem(SELECTED_DEALER, JSON.stringify(allDealerList));
    }

      // This function to create the cookies for selected dealer Label from my dealers tab 
    buildEffectiveDealer(brand, dealerId, dealerLabel, dealerNo) {
        let brands = [];
        if (localStorage.getItem(EFFECTIVE_DEALER)) {
            brands = JSON.parse(localStorage.getItem(EFFECTIVE_DEALER))[BRANDS];
            let hasExist = false;
            if (brands) {
                brands.forEach(element => {
                    if (brand === element.brand) {
                        element.id = dealerId;
                        element.label = dealerLabel;
                        element.dealerNo = dealerNo;
                        hasExist = true;
                    }
                });
            }
            if (!hasExist) {
                brands.push({ 'brand': brand, 'id': dealerId, 'label': dealerLabel, 'dealerNo': dealerNo });
            }
        } else {
            brands.push({ 'brand': brand, 'id': dealerId, 'label': dealerLabel, 'dealerNo': dealerNo });
        }
        localStorage.setItem(EFFECTIVE_DEALER, JSON.stringify({ 'brands': brands }));
    }
}
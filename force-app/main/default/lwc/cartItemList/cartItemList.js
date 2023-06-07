/*******************************************************************************
Name: CartItemList
Business Unit: HDM
Developer: Bhawesh Asudani
Description: LWC is created to handle UI for 1st screen of checkout.
*******************************************************************************

MODIFICATIONS – Date | Dev Name     | Method | User Story
19 March 2022        | Deepak Mali | getCartInfo | HDMP-8725
                     Faraz Anari    handleSelectAddress HDMP-7313
3/7/2023             Saravanan Ramaswammy | 16456,17170
*******************************************************************************/

import { LightningElement, api, wire, track } from 'lwc';
import updateCart from '@salesforce/apex/CartItemsCtrl.updateCart';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { GetDealerPrice, getReturnPolicyMarkup} from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCartItems from '@salesforce/apex/CartItemsCtrl.getCartItemList';
import unlockcart from '@salesforce/apex/B2BCartControllerSample.unlockCart';
import vertexAddressCleansing from '@salesforce/apex/B2B_VertexTaxCalculationIntegration.vertexAddressCleansing';
import gettotalquantity from '@salesforce/apex/CartItemsCtrl.gettotalquantity';
import loggedInuserAllAddressList from '@salesforce/apex/B2B_LoggedInUserAddressCheck.loggedInuserAllAddressList';
import updateAddressBook from '@salesforce/apex/B2B_LoggedInUserAddressCheck.updateAddressBook';
import createAddressRecord from '@salesforce/apex/B2B_LoggedInUserAddressCheck.createAddressRecord';
import deleteAddressBook from '@salesforce/apex/B2B_LoggedInUserAddressCheck.deleteAddressBook';
import getStateAddressBook from '@salesforce/apex/B2B_LoggedInUserAddressCheck.getStateAddressBook';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import CustomerEntered from '@salesforce/label/c.B2B_Customer_Entered_Address';
import Recommended from '@salesforce/label/c.B2B_Recommended_Address';
import getCartInfo from '@salesforce/apex/CartItemsCtrl.getCartInfo';
import getReturnPolicyMarkupMdt from '@salesforce/apex/B2B_DealerReturnPolicyController.getReturnPolicyMarkupMdt';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";//for adobe
import { publish, subscribe, MessageContext } from 'lightning/messageService';//for adobe
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';
const VALIDATION_FIELDS = ['zipCode', 'country', 'province', 'city', 'street', 'phone', 'name'];
const ADD_FIELDS = ['zipCode', 'country', 'province', 'city', 'street'];
const COUNTRY = [{ label: "United States", value: "United States" }];
const INSTALL_AT_DEALER = 'Install At Dealer';
const DEALER_INSTALLATION = 'Dealer Installation';
const PICK_UP_AT_DEALER = 'Pick Up At Dealer';
const PICKUP_FROM_DEALER = 'Pickup At Dealer';
const SHIP_TO_DEALER = 'Ship To Dealer';
const SHIP_TO_ME = 'Ship to Me';
import CoreCharge from '@salesforce/label/c.B2B_Product_Code_Core_Charges'; // Added by Saravanan LTIM for 16456 , 17170
import CoreChargeDisclaimer from '@salesforce/label/c.B2B_CoreChargeDisclaimer'; // Added by Saravanan LTIM for 16456 , 17170


export default class CartItemList extends LightningElement {
    carImage = imageResourcePath + '/carImage.jpeg';
    saveInAddressBook = false;
    markPreffered = false;
    cartItemsLength;
    @track addressList = [];
    @track addressPicker = false;
    @api cartId;
    @track cartItems;
    @api prodquantity;
    @api address;
    countries = [{ label: "United States", value: "United States" }];
    @api shippingMethod;
    @api email;
    @api phone;
    @api name;
    focusElm;
    @track stateOptionList = [];
    @track dealerAddress;
    @track zipCode;
    shipToMeDisabled = false;
    subTotal;
    @track
    shippingStreet;
    shippingCity;
    shippingState;
    shippingCountry = 'United States';
    shippingPostalCode;
    notes;
    displayDealerAddress = false;
    displayAddressBook = false; //shalini
    disabledPreferred = true; //shalini
    showAddressFields = false; //shalini
    displayUnavaiableForShippingMessage = false;
    selectedDealerName = '';
    selectedDealerEmailAddress = '';
    @track showCleansed = false;
    @track makeDisabled = false;
    @track selected = false;
    @track showvalid = false;
    @track showInvalid = false;
    @track makeValidatedisabled = false;
    @track dealerContactNumber;
    @api
    selectedAddressType = 'Ship To Dealer';
    showAddFields = false;
    defaultSelect = true;
    @track enteredAddressCheck;
    @track suggestedAddressCheck;
    @track responsedAddress = {};
    @track enteredAddress = {};
    @track showLOader = false;
    @track showErrorPopup = false;
    @track errorMessage = '';
    pickedAddressType = '';
    customerPhone = '';
    customerName = '';
    customerEmail = '';
    validEmailAddress;
    radioIndex = -1;
    @track showEnteredAddress;
    @track isDisableShipToMeOnBack;
    @track deliveryMethod;
    @track totalShippingCharge;
    @track disabledProceedToCheckout;
    @track currentRecord = {
        'Address__c': "", 'City__c': " ", 'Name': "", 'NickName__c': "", 'Notes__c': "", 'Phone__c': "",
        'State__c': "", 'Zip__c': "", 'Email__c': "", 'isPreferred__c': false
    }; // Added by Shalini on 24/01/2022
    @track state;//Added by deepak - HDMP-8725
    @track country = 'United States';
    //Added by Sayalee on 3/2/2022
    @track userFirstName; //added by mathi on 31/07/2022
    @track checkIfUserIsGuestUserOrNot = false;
    @track isInstallAtDealer = false; //For HDMP-5329 by Faraz on 28/06/2022
    @track addressRecord = {};
    disclaimerMarkup;
    showDisclaimerMarkup = false;
    statesMap = new Map(Object.entries({"alabama": "AL", "alaska": "AK", "american samoa": "AS", "arizona": "AZ", "arkansas": "AR", "california": "CA", "colorado": "CO", "connecticut": "CT", "delaware": "DE", "district of columbia": "DC", "federated states of micronesia": "FM", "florida": "FL", "georgia": "GA", "guam": "GU", "hawaii": "HI", "idaho": "ID", "illinois": "IL", "indiana": "IN", "iowa": "IA", "kansas": "KS", "kentucky": "KY", "louisiana": "LA", "maine": "ME", "marshall islands": "MH", "maryland": "MD", "massachusetts": "MA", "michigan": "MI", "minnesota": "MN", "mississippi": "MS", "missouri": "MO", "montana": "MT", "nebraska": "NE", "nevada": "NV", "new hampshire": "NH", "new jersey": "NJ", "new mexico": "NM", "new york": "NY", "north carolina": "NC", "north dakota": "ND", "northern mariana islands": "MP", "ohio": "OH", "oklahoma": "OK", "oregon": "OR", "palau": "PW", "pennsylvania": "PA", "puerto rico": "PR", "rhode island": "RI", "south carolina": "SC", "south dakota": "SD", "tennessee": "TN", "texas": "TX", "utah": "UT", "vermont": "VT", "virgin islands": "VI", "virginia": "VA", "washington": "WA", "west virginia": "WV", "wisconsin": "WI", "wyoming": "WY"}));

    label = {
        CustomerEntered,
        Recommended
    };


    disclaimerType; // Added by ashwin
    dealerNumber; // Added by ashwin
    showDealerModal = false; // Added by ashwin
    dealerReturnPolicyMarkup = ""; // Added by ashwin

    CoreChargeValue = CoreCharge; // Added by Saravanan LTIM for 16456 , 17170
    CoreChargeDisclaimerValue = CoreChargeDisclaimer; // Added by Saravanan LTIM for 16456 , 17170

    //for adobe:messageContext
    @wire(MessageContext)
    messageContext;

    @track currentShippingAddress;// Added by saikiran HDMP-13627
    connectedCallback() {

        //for adobe analytics:starts
        const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.LOAD } };
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        //for adobe analytics:ends

        this.createCookie('cartIdForUpdate', this.cartId, 1);//Added by Faraz on 24/08/2021
        this.getCartInfo(); //Added as part of HDMP-8725
        this.getStateValues();
        this.handleGetReturnPolicyMarkup();
    }
    
    async handleGetReturnPolicyMarkup(){
        let markupData = await getReturnPolicyMarkup();
        if(markupData.B2B_Motocompacto_Disclaimer_Markup && markupData.B2B_Motocompacto_Disclaimer_Markup.Markup__c){
            this.disclaimerMarkup = markupData.B2B_Motocompacto_Disclaimer_Markup.Markup__c;
        }        
    }

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    wireuserdata({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userFirstName = data.fields.Name.value;
            if (USER_ID == undefined || USER_ID == null || this.userFirstName.includes('Guest')) {
                this.checkIfUserIsGuestUserOrNot = true;
                this.displayAddressBook = false;
            }
        }
    }

    getStateValues() {
        getStateAddressBook()
            .then(result => {
                if (result) {
                    let parseData = result;
                    let stateOptions = JSON.parse(JSON.stringify(parseData));
                    this.stateOptionList = stateOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                }
            })
            .catch(error => {
                console.error('ERROR::', JSON.stringify(result.error));
                this.stateOptionList = [];
            });
    }

    showNewAddressFields() {
        this.showAddressFields = true;
        this.displayAddressBook = false;
        if (!this.checkIfUserIsGuestUserOrNot && this.selectedAddressType == SHIP_TO_ME) {
            this.disabledProceedToCheckout = false;
        }
        //Added by saikiran as part HDMP-13627
        this.addressList.forEach(currentItem =>{
            if( this.selectedAddressType == SHIP_TO_ME && !this.addressFound){            
                if(this.currentShippingAddress &&
                    this.currentShippingAddress.Customer_Name__c == currentItem.Name &&
                    this.currentShippingAddress.CustomerCity__c == currentItem.City__c &&
                    this.currentShippingAddress.CustomerStreet__c == currentItem.Address__c &&
                    this.currentShippingAddress.Customer_State__c == currentItem.State__c &&
                    this.currentShippingAddress.CustomerPostalCode__c == currentItem.Zip__c &&
                    this.currentShippingAddress.Customer_Phone__c == currentItem.Phone__c
                ){
                    this.addressFound = true;
                    return '';
                }
            }

        })
        if(this.currentShippingAddress.Customer_Name__c === undefined &&
            this.currentShippingAddress.CustomerCity__c === undefined &&
            this.currentShippingAddress.CustomerStreet__c  === undefined &&
            this.currentShippingAddress.Customer_State__c  === undefined &&
            this.currentShippingAddress.CustomerPostalCode__c  === undefined &&
            this.currentShippingAddress.Customer_Phone__c === undefined)
        {
            this.addressFound = true;
        }
        //updated by saikiran as part HDMP-13627
        console.log('$CIL: this.addressFound: ',this.addressFound);
        if(this.addressFound && !this.addressRecord.AccountAddress){
            this.clearShippingAddress();
        }
        else{

            if(this.addressRecord && this.addressRecord.AccountAddress){
                this.addressRecord.AccountAddress = false;
                this.currentShippingAddress['CustomerStreet__c'] = this.addressRecord.Address__c;
                this.currentShippingAddress['Customer_State__c'] = this.addressRecord.State__c;
                this.currentShippingAddress['CustomerCity__c'] = this.addressRecord.City__c;
                this.currentShippingAddress['Customer_Name__c'] = this.addressRecord.Name;
                this.currentShippingAddress['CustomerPostalCode__c'] = this.addressRecord.Zip__c;
                this.currentShippingAddress['Customer_Phone__c'] = "";
            }

            this.name = this.currentShippingAddress.Customer_Name__c;
            this.shippingStreet = this.currentShippingAddress.CustomerStreet__c;
            this.phone = this.currentShippingAddress.Customer_Phone__c;
            this.shippingCity = this.currentShippingAddress.CustomerCity__c;
            this.state = this.currentShippingAddress.Customer_State__c;
            this.shippingPostalCode = this.currentShippingAddress.CustomerPostalCode__c;
            this.shippingCountry = 'United States';
            this.notes = this.currentShippingAddress.Notes__c;

            this.currentRecord.name = this.currentShippingAddress.Customer_Name__c;
            this.currentRecord.Address__c = this.currentShippingAddress.CustomerStreet__c;
            this.currentRecord.Phone__c = this.currentShippingAddress.Customer_Phone__c;
            this.currentRecord.City__c = this.currentShippingAddress.CustomerCity__c;
            this.currentRecord.State__c = this.currentShippingAddress.Customer_State__c;
            this.currentRecord.Zip__c = this.currentShippingAddress.CustomerPostalCode__c;
            this.currentRecord.Country__c = 'United States';
            this.currentRecord.notes = this.currentShippingAddress.Notes__c;
        }
    }

    @wire(getCartItems, { cartId: '$cartId', userFirstName: '$userFirstName' })
    async wiredPROLRecords(result, error) {
        let items = result;
        await loggedInuserAllAddressList()
            .then(async result => {
                if (result) {
                    let myAccountAddress = JSON.parse(result.My_Account_Address);
                    let myAddressBookAddress = JSON.parse(result.My_Address_Book_Address);
                    if (myAccountAddress && myAccountAddress.length && myAccountAddress[0]) {
                        let acc = myAccountAddress[0];
                        if(acc.Name && acc.PersonMailingStreet && acc.PersonMailingCity && acc.PersonMailingState && acc.PersonMailingPostalCode){
                            console.log('$CIL: acc: ',acc);
                            let duplicate = myAddressBookAddress.find(element => {
                                return (
                                    acc.PersonMailingStreet.toLocaleLowerCase() == element.Address__c.toLocaleLowerCase() &&
                                    acc.PersonMailingCity.toLocaleLowerCase() == element.City__c.toLocaleLowerCase() &&
                                    this.statesMap.get(acc.PersonMailingState.toLocaleLowerCase()) == element.State__c
                                )
                            });
                            if (!duplicate) {
                                myAddressBookAddress.push({
                                    Id: acc.Id,
                                    Name: acc.Name,
                                    NickName__c: acc.Name,
                                    isPreferred__c: false,
                                    Address__c: acc.PersonMailingStreet,
                                    City__c: acc.PersonMailingCity,
                                    Phone__c: null,
                                    Notes__c: null,
                                    State__c: this.statesMap.get(acc.PersonMailingState.toLocaleLowerCase()),
                                    Country__c: "United States",
                                    Zip__c: acc.PersonMailingPostalCode,
                                    Person_Address_Account__c: acc.Id,
                                    AccountAddress: true
                                });
                            }
                        }
                    }

                    this.addressList = myAddressBookAddress;
                    if (this.checkIfUserIsGuestUserOrNot == false) {
                        if (this.addressList.length > 0) {
                            this.addressRecord = this.addressList[0];
                            this.addressList.forEach(currentItem => {
                                if (currentItem.isPreferred__c) {
                                    this.name = currentItem.Name;
                                    this.shippingStreet = currentItem.Address__c;
                                    this.phone = currentItem.Phone__c;
                                    this.shippingCity = currentItem.City__c;
                                    this.state = currentItem.State__c;
                                    this.shippingPostalCode = currentItem.Zip__c;
                                    this.notes = currentItem.Notes__c;
                                } else if (currentItem.Name == this.name
                                    && currentItem.Address__c == this.shippingStreet
                                    && currentItem.Phone__c == this.phone
                                    && currentItem.State__c == this.state
                                    && currentItem.Zip__c == this.shippingPostalCode
                                    && currentItem.City__c == this.shippingCity) {
                                } else {
                                    currentItem.isPreferred__c = false
                                }
                            });
                        }
                    }

                    if (items && items.data && items.data[0] && items.data[0].Cart && items.data[0].Cart.Delivery_Type__c && items.data[0].Cart.Delivery_Type__c == SHIP_TO_ME) {
                        if (!this.checkIfUserIsGuestUserOrNot) {
                            this.disabledProceedToCheckout = this.addressList.length > 0 ? this.addressList.filter(item => item.isPreferred__c).length > 0 ? false : true : true;
                        }
                    }
                }
            })
            .catch(error => {
                console.log('Error : ', error);
            });
        await gettotalquantity({ cartId: this.cartId })
            .then(async result => {
                if (result != null) {
                    this.prodquantity = result;
                    this.cartItemsLength = 'Subtotal (' + this.prodquantity;
                    this.cartItemsLength += this.prodquantity > 1 ? ' Items)' : ' Item)';
                }
            })
            .catch(error => {
                console.error(error);
            });

        let opCodeArr = [];
        let vehicle = 0;
        let dealerNo;

        if (result && result.data) {
            let cartItems_Clone = [];
            JSON.parse(JSON.stringify(result.data)).forEach(currentItem => {
                if (currentItem && currentItem.ListPrice && currentItem.Quantity) {
                    let qunty = parseInt(currentItem.Quantity);
                    let itemPrice = parseFloat(currentItem.ListPrice);
                    currentItem.subTotalForEveryProduct = (itemPrice * qunty);
                } else {
                    currentItem.subTotalForEveryProduct = '';
                }
                if(currentItem.hasOwnProperty('Product_Type__c') && currentItem.Product_Type__c == 'Motocompacto'){
                    currentItem.isMotocompacto = true;
                }else{
                    currentItem.isMotocompacto = false;
                }
                cartItems_Clone.push(currentItem);
                if (currentItem.hasOwnProperty('Product_Type__c') && currentItem.Product_Type__c == 'Accessory' && currentItem.hasOwnProperty('op_code__c')) {
                    opCodeArr.push(currentItem.op_code__c);
                }
                if(!vehicle && currentItem.Product_Subdivision__c){
                    vehicle = currentItem.Product_Subdivision__c.toLowerCase() == 'honda' ? 1 : currentItem.Product_Subdivision__c.toLowerCase() == 'acura' ? 2 : 0;
                }
                if(!dealerNo && currentItem.Cart && currentItem.Cart.DealerId__r && currentItem.Cart.DealerId__r.PoIId__c){
                    dealerNo = currentItem.Cart.DealerId__r.PoIId__c;
                }
            });
            /** LTIM Saravanan Added the below FOR..EACH loop for 16456,17170 */
            if(cartItems_Clone){
                var counter = 0;
                cartItems_Clone.forEach(item => {
                    cartItems_Clone[counter].isCoreCharge = false;
                    if(item.Product_Type__c == this.CoreChargeValue){
                        cartItems_Clone[counter].isCoreCharge = true;
                    }
                    counter++;
                })
            }            
            this.cartItems = cartItems_Clone;
            var cart = this.cartItems[0].Cart;
            if (cart.DealerId__c) {
                this.dealerNumber = cart.DealerId__r.PoIId__c;
                this.dealerReturnPolicyMarkup = cart.DealerId__r.Return_Policy__c;
                this.dealerAddress = cart.DealerId__r.ShippingAddress;
                this.selectedDealerName = cart.DealerId__r.Name;
                this.selectedDealerEmailAddress = cart.DealerId__r.Email__c;
                this.zipCode = this.dealerAddress.postalCode;
                this.displayDealerAddress = true;
                this.dealerContactNumber = cart.DealerId__r.Phone;
            }
            if (cart.GrandTotalAmount) {
                this.subTotal = (parseFloat(cart.GrandTotalAmount)).toFixed(2);
            }
            if (this.cartItems[0].Cart && this.cartItems[0].Cart.Delivery_Type__c) {
                if (this.cartItems[0].Cart.Delivery_Type__c == INSTALL_AT_DEALER && this.cartItems[0].Cart.Total_Installation_Charge__c >= 0) {
                    this.deliveryMethod = DEALER_INSTALLATION;
                    this.totalShippingCharge = parseFloat(this.cartItems[0].Cart.Total_Installation_Charge__c).toFixed(2);
                    this.displayDealerAddress = true;
                    this.showAddFields = false;
                    this.selectedAddressType = INSTALL_AT_DEALER;
                    this.isInstallAtDealer = true;
                } else if (this.cartItems[0].Cart.Delivery_Type__c == PICK_UP_AT_DEALER) {
                    this.deliveryMethod = PICKUP_FROM_DEALER;
                    this.displayDealerAddress = true;
                    this.showAddFields = false;
                    this.selectedAddressType = SHIP_TO_DEALER;
                } else if (this.cartItems[0].Cart.Delivery_Type__c == SHIP_TO_ME) {
                    if (this.cartItems[0].Cart.Pickup_Dealer__c) {
                        this.clearShippingAddress();
                    }
                    this.selectedAddressType = SHIP_TO_ME;
                    this.displayDealerAddress = false;
                    this.showAddFields = true;
                    this.displayAddressBook = true;
                    if (USER_ID == undefined || USER_ID == null || this.userFirstName.includes('Guest')) {
                        this.showAddressFields = true;
                        this.showAddFields = true;
                        this.displayAddressBook = false;
                    }
                }
            }
            if(dealerNo && vehicle && opCodeArr.length){
                let response = await GetDealerPrice(dealerNo, vehicle, [], opCodeArr);
                let data = JSON.parse(response);
                console.log('OUTPUTdata : ',data);
                if(data && !data.isError){
                    this.cartItems.forEach(element => {
                        element.dealerInstall = false;
                        if(element.Product_Type__c && element.Product_Type__c == 'Accessory'){
                            let installCharge = data.Accessories.filter(item => item.OpCode == element.op_code__c)[0].InstallationCharges;
                            console.log('installCharge : ',installCharge);
                            if(installCharge && installCharge != null && installCharge != undefined){
                                element.dealerInstall = true;
                            }
                        }
                    });
                    console.log('this.cartItems : ',this.cartItems);
                }
            }
        } else if (error) {
            console.error('error from apex--' + error);
        }
    }

    //Added by Deepak 19 March 2022 - HDMP-8725
    getCartInfo() {
        getCartInfo({ cartId: this.cartId })
            .then(result => {
                this.currentShippingAddress = result ;// Added by saikiran HDMP-13627
                console.log('$CIL: currentShippingAddress: ',result);
                if(!result.Pickup_Dealer__c){
                    this.name = result.Customer_Name__c;
                    this.customerName = result.Customer_Name__c;
                    this.phone = result.Customer_Phone__c;
                    this.customerPhone = result.Customer_Phone__c;
                    this.shippingStreet = result.CustomerStreet__c;
                    this.shippingCity = result.CustomerCity__c;
                    this.country = result.CustomerCountry__c;
                    this.shippingCountry = result.CustomerCountry__c;
                    this.shippingPostalCode = result.CustomerPostalCode__c;
                    this.state = result.Customer_State__c;
                    this.shippingState = result.Customer_State__c;
                    this.notes = result.Notes__c;
                    this.validEmailAddress = true // we default set true because we already validate before saved in cart

                     //Saravanan LTIM Added for Sprint 4 Tax Jurisdications
                     if(this.shippingPostalCode){
                        sessionStorage.setItem('PostalCode',this.shippingPostalCode);
                    }
                    //Saravanan LTIM Added for Sprint 4 Tax Jurisdications
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
    //Ends

    //Added by Faraz for 7313
    handleSelectAddress(event) {
        if (!this.checkIfUserIsGuestUserOrNot && this.selectedAddressType == SHIP_TO_ME) {
            this.radioIndex = event.target.dataset.indx;
            this.disabledProceedToCheckout = false;
            setTimeout(() => { this.template.querySelectorAll('.myaddress')[this.radioIndex].checked = true; }, 100);
            console.log('$CIL: event.target.dataset: ',JSON.parse(JSON.stringify(event.target.dataset)));
            this.addressRecord = this.addressList[this.radioIndex] ?? this.addressRecord;
            this.shippingState = this.addressRecord.State__c;
            this.customerName = this.addressRecord.Name;
            console.log('$CIL: this.addressRecord ',JSON.parse(JSON.stringify(this.addressRecord)));
        }
    }
    //End
    //Added by Sayalee for 7266
    handleCheck(event) {
        let buttonLabel = event.target.name;
        if (buttonLabel == 'SaveAddress') {
            this.disabledPreferred = event.target.checked ? false : true;
            if (event.target.checked == true) {
                this.saveInAddressBook = true;
            }
            else if (event.target.checked == false) {
                this.saveInAddressBook = false;
                this.disabledPreferred = true;
            }
        }
        if (buttonLabel == 'MarkPreferredAddress') {
            this.currentRecord.isPreferred__c = event.target.checked ? true : false;
            if (event.target.checked == true) {
                this.markPreffered = true;
            }
        }
        console.log('$CIL: this.currentRecord1: ',JSON.parse(JSON.stringify(this.currentRecord)));
    }

    createNewAddress() {
        console.log('$CIL: this.currentRecord2: ',JSON.parse(JSON.stringify(this.currentRecord)));
        if (this.saveInAddressBook || this.markPreffered) {
            createAddressRecord({ addressRecord: JSON.stringify(this.currentRecord) })
                .then((result) => {
                    console.log('$CIL: result: ',result);
                    console.log('$CIL: addressRecord: ',addressRecord);
                    if (result.error == false && result.currentRecord != null) {
                        this.addressList = result.addressList;
                        this.currentRecord = result.currentRecord;
                        //Added by Sayalee as 8301
                        if (result.errorWhenDuplicateName == 'Duplicate record not allowed') {
                            this.showToastMessage('Error', 'The address, you are trying to add, already exists', 'error');

                        }
                        else if (result.errorWhenDuplicateName == 'Continue inserting record') {
                            this.showToastMessage('Success', 'Address Created Successfully', 'success');
                        }
                        //end

                    } else if (result.error == true) {
                        console.error(result.errorMessage);
                    }
                })
                .catch((error) => {
                    console.error(error.message);
                })
                .finally(() => this.showLOader = false);
        }
    }
    //end

    handleOnConfirmAddress(event) {
        //this.showLOader = true;
        if (!this.pickedAddressType || this.pickedAddressType == '') {
            this.showToastMessage('ERROR', 'please select at-least one address..', 'error');
            return;
        } else {

            if (this.pickedAddressType && this.pickedAddressType == 'TYPED') {
                this.createNewAddress();
                this.updateCartAndMakePorcess(this.cartId, this.enteredAddress.streetAddress1, this.enteredAddress.city, this.enteredAddress.mainDivision, this.enteredAddress.country, this.enteredAddress.postalCode, false);
            }
            if (this.pickedAddressType && this.pickedAddressType == 'SUGGESTED') {
                //here we are changing some fields value which we getting from response
                this.currentRecord['Address__c'] = this.responsedAddress.StreetAddress1;
                this.currentRecord['City__c'] = this.responsedAddress.City;
                this.currentRecord['State__c'] = this.responsedAddress.MainDivision;
                this.currentRecord['Zip__c'] = this.responsedAddress.PostalCode;
                this.createNewAddress();
                this.updateCartAndMakePorcess(this.cartId, this.responsedAddress.StreetAddress1, this.responsedAddress.City, this.responsedAddress.MainDivision, this.responsedAddress.Country, this.responsedAddress.PostalCode, false);

                
                // Saravanan LTIM Added for Sprint 4 Tax Jurisdications
                sessionStorage.setItem('PostalCode',this.responsedAddress.PostalCode);
                 // Saravanan LTIM Added for Sprint 4 Tax Jurisdications
            }
        }
    }

    handleCloseAddressPicker(event) {
        this.addressPicker = false;
        if (this.radioIndex != -1) {
            setTimeout(() => { this.template.querySelectorAll('.myaddress')[this.radioIndex].checked = true; }, 50);
        }
    }

    handleOnChangeValue(event) {
        let selectedValue = event.target.value;
        let fieldName = event.currentTarget.dataset.name;
        if (fieldName && selectedValue) {
            if (fieldName == 'street') {
                this.shippingStreet = selectedValue;
                this.currentRecord.Address__c = this.shippingStreet;
                console.log('##this.currentRecord.Address__c', this.currentRecord.Address__c);
            }

            else if (fieldName == 'city') {
                this.shippingCity = selectedValue;
                this.currentRecord.City__c = this.shippingCity;
                console.log('##this.currentRecord.City__c', this.currentRecord.City__c);
            }

            else if (fieldName == 'zipcode') {
                this.shippingPostalCode = selectedValue;
                this.currentRecord.Zip__c = this.shippingPostalCode;
                console.log('##this.currentRecord.Zip__c', this.currentRecord.Zip__c);
                let zipelment = this.template.querySelector('.myzipcode');
                if (!this.checkZipCodeValidation(this.shippingPostalCode)) {
                    zipelment.setCustomValidity("Invalid zip code pattern. Zip code must be XXXXX or XXXXX-XXXX");
                } else {
                    zipelment.setCustomValidity("");
                }

                 // Saravanan LTIM Added for Sprint 4 Tax Jurisdications.
                 sessionStorage.setItem('PostalCode',this.shippingPostalCode);
                 // Saravanan LTIM Added for Sprint 4 Tax Jurisdications.
            }

            else if(fieldName == 'notes') {
                this.notes = selectedValue;
                this.currentRecord.Notes__c = this.notes;
            }
        }
    }

    handleOnSelectState(event) {
        //this.shippingState = event.detail.value;
        this.shippingState = event.target.value;
        this.currentRecord.State__c = this.shippingState;
        this.suggestedAddress.State__c = this.shippingState;
    }


    handleOnSelectCountry(event) {
        this.shippingCountry = event.detail.value;
    }

    validateAddressFromAPI(addressinput) {
        vertexAddressCleansing({ addressMap: addressinput }).then(result => {
            if (result) {
                if (this.radioIndex != -1) {
                    setTimeout(() => { this.template.querySelectorAll('.myaddress')[this.radioIndex].checked = true; }, 50);
                }
                let cleansedvalue = JSON.parse(result);
                if (cleansedvalue.isError == "false") {
                    try {

                        if (cleansedvalue && cleansedvalue.StreetAddress1 && cleansedvalue.StreetAddress1.length) {
                            if (cleansedvalue.StreetAddress1.toLowerCase().includes(("pob")) || cleansedvalue.StreetAddress1.toLowerCase().includes(("po box")) || cleansedvalue.StreetAddress1.toLowerCase().includes(("po")) || cleansedvalue.StreetAddress1.toLowerCase().includes(("p o")) || cleansedvalue.StreetAddress1.toLowerCase().includes(("p.o"))) {
                                this.errorMessage = 'You have entered PO Or Po Box address, Please enter non Po Box address and try again';
                                this.showErrorPopup = true;
                                this.showLOader = false;
                                return;
                            }
                        }
                        this.responsedAddress = cleansedvalue;
                        this.State__c = this.responsedAddress.State__c;
                        this.Zip__c = this.responsedAddress.Zip__c;
                        this.addressPicker = true;
                        this.showLOader = false;

                        if (this.enteredAddress.streetAddress1 == this.responsedAddress.StreetAddress1
                            && this.enteredAddress.city == this.responsedAddress.City && this.enteredAddress.mainDivision == this.responsedAddress.MainDivision
                            && this.enteredAddress.country == this.responsedAddress.Country && this.enteredAddress.postalCode == this.responsedAddress.PostalCode) {
                            this.addressPicker = false;
                            this.pickedAddressType = 'SUGGESTED';
                            this.handleOnConfirmAddress();
                        } else {
                            console.log('hi');
                            this.addressPicker = true;
                        }
                    }
                    catch (e) {
                        console.log('error msgh', e);
                    }
                }
                else {
                    if (cleansedvalue.errorMessage.includes('Internal Error')) {
                        this.showToastMessage('Error', 'Internal Error from client ,Please Try after sometime ', 'error');
                        this.showLOader = false;
                    }else {
                        this.showToastMessage('Error', 'We’re sorry, we couldn’t verify the address you have entered. Please review and verify the correct information is entered.', 'error');
                        this.showLOader = false;
                    }
                }
            }
        }).catch(error => {
            console.log('error from address result' + JSON.stringify(error));
            this.showLOader = false;
        });
    }

    handleToAllowName(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        console.log('$CIL: charCode: ',charCode);
        if (!((charCode >= 91 && charCode <= 126) || (charCode >= 32 && charCode <= 47) || (charCode >= 58 && charCode <= 90) || (charCode == 32))) {
            // event.preventDefault();
            console.log('$CIL: RETURN FALSE');
            return true;
        }
        console.log('$CIL: RETURN TRUE');
        return true;
    }



    handleToAllowPhone(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        if (!((charCode >= 48 && charCode <= 57))) {
            event.preventDefault();
            return false;
        }
        return true;
    }

    handleToAllowZipcode(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        if (!((charCode >= 48 && charCode <= 57) || (charCode == 45))) {
            event.preventDefault();
            return false;
        }
        return true;
    }

    validateName(event) {
        let onlyName = /^[ A-Za-z0-9_@./','#&+-]*$/.test(event.target.value),
            enteredname = this.template.querySelector(".Name");
        console.log('$CIL: onlyName: ',onlyName);
        this.customerName = event.target.value;
        console.log('$CIL: customerName: ',event.target.value);
        this.currentRecord.Name = this.customerName;
        this.currentRecord.name = this.customerName;
        this.suggestedAddress.Name = this.customerName;
        if (onlyName) {
            // this.makeDisabled = false;
            // enteredname.setCustomValidity("");
        }
        else {
            this.makeDisabled = true;
        }
    }

    validatePhone(event) {
        let onlyNumber = /^\d+$/.test(event.target.value);
        this.customerPhone = event.target.value;
        this.currentRecord.Phone__c = this.customerPhone;
        this.suggestedAddress.Phone__c = this.customerPhone;
        phone = this.template.querySelector(".Phone");
        if (onlyNumber && onlyNumber.length == 11) {
            this.makeDisabled = false;
            phone.setCustomValidity("");
        }
        else {
            this.makeDisabled = true;
            phone.setCustomValidity("Please enter valid Phone Number");
        }
    }

    gotoCart() {
        window.location = '/s/cart/' + this.cartId;
        localStorage.removeItem('cartIdForUpdate');
        unlockcart({ CartId: this.cartId })
            .then((result) => {
                //console.log('cart open')
            }).catch((e) => {
                //console.log(e);
            });
    }

    handleOnProceedToCheckout(event) {
        let phone = this.template.querySelector(".Phone");
        if(phone){
            let vldt = phone.reportValidity();
            console.log('$CIL: vldt: ',vldt);
            if(!vldt){
                this.showToastMessage('Error', 'Please review and check that all information is complete.', 'error');
                phone.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
                return;
            }
        }

        if(this.addressRecord && this.addressRecord.AccountAddress){
            this.showNewAddressFields();
            return;
        }
        //Added shalinig soni :this if condition to manage shipping address
        if (this.displayAddressBook == true) {
            console.log('$CIL: IF');
            try {
                console.log('$CIL: currentRecord ', JSON.parse(JSON.stringify(this.currentRecord)));
            } catch (error) {
                console.error(error.message);
            }

            let recordId = undefined;
            let selectedAddress = {};
            let radioButtons = this.template.querySelectorAll('.myaddress');
            if (radioButtons) {
                console.log('$CIL: IF1');
                radioButtons.forEach(element => {
                    if (recordId == undefined && element.checked) {
                        recordId = element.value;
                    }
                })
                let selectedAdd = this.addressList.filter(element => {
                    return recordId == element.Id;
                });
                selectedAddress = { ...JSON.parse(JSON.stringify(selectedAdd[0])) };
                console.log(selectedAddress);
                if (selectedAddress.Name && selectedAddress.Phone__c) {
                    this.customerName = selectedAddress.Name;
                    this.customerPhone = selectedAddress.Phone__c;
                    console.log('$CIL: IF2');
                }
                if(selectedAddress.Notes__c) {
                    this.notes = selectedAddress.Notes__c
                    console.log('$CIL: IF3');
                }

            }

            if (this.selectedAddressType && this.selectedAddressType == SHIP_TO_ME) {
                console.log('$CIL: IF4');
                let addressinput = {
                    'streetAddress1': selectedAddress.Address__c ? selectedAddress.Address__c : '',
                    'streetAddress2': selectedAddress.Address__c ? selectedAddress.Address__c : '',
                    'city': selectedAddress.City__c ? selectedAddress.City__c : '',
                    'mainDivision': selectedAddress.State__c ? selectedAddress.State__c : '',
                    'postalCode': selectedAddress.Zip__c ? selectedAddress.Zip__c : '',
                    'country': selectedAddress.Country__c ? selectedAddress.Country__c : 'United States'
                };
                this.enteredAddress = addressinput;
                console.table(addressinput);
                this.validateAddressFromAPI(this.enteredAddress);
            } else if (this.selectedAddressType && (this.selectedAddressType == SHIP_TO_DEALER || this.selectedAddressType == INSTALL_AT_DEALER)) {
                console.log('$CIL: IF5');
                this.updateCartAndMakePorcess(this.cartId, selectedAddress.Address__c, selectedAddress.City__c, selectedAddress.State__c, 'United States', selectedAddress.Zip__c, true);
            }
        } else {
            console.log('$CIL: ELSE');
            if (this.selectedAddressType && this.selectedAddressType == SHIP_TO_ME) {
                console.log('$CIL: ELSE1');
                console.log('$CIL: customerName: ',this.customerName);
                console.log('$CIL: customerPhone: ',this.customerPhone);
                console.log('$CIL: shippingPostalCode: ',this.shippingPostalCode);
                console.log('$CIL: shippingCountry: ',this.shippingCountry);
                console.log('$CIL: shippingState: ',this.shippingState);
                console.log('$CIL: shippingCity: ',this.shippingCity);
                console.log('$CIL: shippingStreet: ',this.shippingStreet);
                if (this.customerName && this.customerPhone && this.shippingPostalCode && this.shippingCountry && this.shippingState && this.shippingCity && this.shippingStreet) {
                    console.log('$CIL: ELSE IF1');
                    let isValidName = /^[ A-Za-z0-9_@./','#&+-]*$/.test(this.customerName);
                    let isValidCity = /^[a-zA-Z ]*$/.test(this.shippingCity);
                    console.log('$CIL: isValidName: ',isValidName);
                    console.log('$CIL: isValidCity: ',isValidCity);
                    if (this.customerName.length < 2/*  || !isValidName */) {
                        this.showToastMessage('Error', 'Invalid name, Please enter a valid name.', 'error');
                        return;
                    }

                    if (!this.checkZipCodeValidation(this.shippingPostalCode)) {
                        this.showToastMessage('Error', 'Invalid zip code pattern. Zip code must be XXXXX or XXXXX-XXXX', 'error');
                        return;
                    }
                    if (this.shippingStreet.length < 3 || this.shippingCity.length < 3 || !isValidCity) {
                        this.showToastMessage('Error', 'Enter a correct address please', 'error');
                        return;
                    }
                    if (this.customerPhone.length != 10) {
                        this.showToastMessage('Error', 'Invalid phone number pattern. Please enter a 10 digit numeric value', 'error');
                        return;
                    }
                    this.showLOader = true;
                    let addressinput = {
                        'streetAddress1': this.shippingStreet ? this.shippingStreet : '',
                        'streetAddress2': this.shippingStreet ? this.shippingStreet : '',
                        'city': this.shippingCity ? this.shippingCity : '',
                        'mainDivision': this.shippingState ? this.shippingState : '',
                        'postalCode': this.shippingPostalCode ? this.shippingPostalCode : '',
                        'country': 'United States'
                    };
                    this.enteredAddress = addressinput;
                    console.table(addressinput);
                    this.validateAddressFromAPI(this.enteredAddress);
                }
                else {
                    console.log('$CIL: ELSE ERROR');
                    this.showToastMessage('Error', 'Please review and check that all information is complete.', 'error');
                }
            } else if (this.selectedAddressType && (this.selectedAddressType == SHIP_TO_DEALER || this.selectedAddressType == INSTALL_AT_DEALER)) {
                console.log('$CIL: ELSE IF');
                this.updateCartAndMakePorcess(this.cartId, this.dealerAddress.street, this.dealerAddress.city, this.dealerAddress.state, this.shippingCountry, this.zipCode, true);
            }
        }
    }

    checkZipCodeValidation(zipCode) {
        let isA_Zcontains = /^[a-zA-Z ]*$/.test(zipCode);
        if (isA_Zcontains) {
            return false;
        }
        let index = zipCode.indexOf('-');
        let count = zipCode.split('-').length - 1;
        if ((zipCode.length == 5 && !zipCode.includes('-')) || (index == 5 && zipCode.length == 10 && count == 1)) {
            return true;
        }
        return false;
    }

    updateCartAndMakePorcess(cart_Id, shipping_Street, shipping_City, shipping_State, shipping_Country, shipping_Postal_Code, pickup_dealer) {
        console.log('updateCartAndMakePorcess call', this.customerName + '-----' + this.customerPhone);
        if (cart_Id && shipping_Street && shipping_City && shipping_State && shipping_Country && shipping_Postal_Code) {
            localStorage.removeItem('disableShiptoMe');
            updateCart({
                customerName: (pickup_dealer ? '' : this.customerName),
                customerPhone: (pickup_dealer ? '' : this.customerPhone),
                cartId: cart_Id,
                shippingStreet: shipping_Street,
                shippingCity: shipping_City,
                shippingState: shipping_State,
                shippingCountry: shipping_Country,
                shippingPostalCode: shipping_Postal_Code,
                isPickupDealer: pickup_dealer,
                shippingNote : this.notes
            })
                .then(result => {
                    if (result == this.cartId) {
                        this.addressPicker = false;
                        this.proceed = true;
                        this.makeDisabled = false;
                        const navigateNextEvent = new FlowNavigationNextEvent();
                        this.dispatchEvent(navigateNextEvent);
                    } else {
                        this.addressPicker = false;
                        this.makeDisabled = true;
                        this.showToastMessage(this._title, this.message, this.variant);
                    }
                    if (this.radioIndex != -1) {
                        setTimeout(() => { this.template.querySelectorAll('.myaddress')[this.radioIndex].checked = true; }, 50);
                    }
                }).catch(error => {
                    this.addressPicker = false;
                    this.showToastMessage('ERROR', 'This item is only available for pick up at a dealer.', 'error');
                });
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

    makeShipToMeDisable() {
        this.shipToMeDisabled = true;
        var shipToMeElm = this.template.querySelector('[data-id="shipToMeDiv"]');
        shipToMeElm.classList.add('greyColor');
        this.displayUnavaiableForShippingMessage = true;
    }

    disableShipToMeOnInvalidPackage() {
        checkPackageHWL({ cartId: this.cartId })
            .then(result => {
                if (result == false) {
                    this.makeShipToMeDisable();
                    this.showToastMessage('Error', 'We’re Sorry. This item is not shippable and must be picked up at dealer.', 'error');
                    return;
                }
            })
            .catch(error => {
                console.error('Error:', error);
            })
    }

    handleOnTypedAddress(event) {
        let isChecked = event.target.checked;
        if (isChecked) {
            this.pickedAddressType = 'TYPED';
            let suggElmnt = this.template.querySelector('.suggestedCls');
            suggElmnt.checked = false;
        } else {
            this.pickedAddressType = '';
        }

    }

    handleOnSuggestedAddress(event) {
        let isChecked = event.target.checked;
        if (isChecked) {
            this.pickedAddressType = 'SUGGESTED';
            let suggElmnt = this.template.querySelector('.typedcls');
            suggElmnt.checked = false;
        } else {
            this.pickedAddressType = '';
        }
    }

    closeErrorPopup() {
        this.showErrorPopup = false;
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

    clearShippingAddress(){
        this.name = '';
        this.customerName = '';
        this.phone = '';
        this.customerPhone = '';
        this.shippingStreet = '';
        this.shippingCity = '';
        this.country = 'United States';
        this.shippingCountry = 'United States';
        this.shippingPostalCode = '';
        this.state = '';
        this.shippingState = '';
        this.notes = '';
    }

    //Ashwin 16460 
    handleDisclamerPopup(event) {
        this.disclaimerType = event.currentTarget.dataset.id;
        this.showDealerModal = true;
    }

    handleShowHide(event) {
        this.showDealerModal = false;

    }

    openDisclaimerPopup(){
        this.showDisclaimerMarkup = true;
    }
    closeDisclaimerPopup(){
        this.showDisclaimerMarkup = false;
    }
}
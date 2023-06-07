/*******************************************************************************
Name: CartDealerInstallation
Business Unit: 
Created Date: 06 January 2022
Developer: shalini soni
Description: LWC is created to handle UI for Dealer Installation only.
*******************************************************************************

MODIFICATIONS – Date | Dev Name     | Method                    | User Story
27/06/2022           | Faraz Ansari | handleIssueForDealerInstall | HDMP-5326
*******************************************************************************/

// Created Component by shalini soni HDMP-5428 R2 Story
import { LightningElement, api, track, wire } from 'lwc';
import setDealerInstallationType from '@salesforce/apex/CartItemsCtrl.setDealerInstallationType';
import getCartItemsFromDB from '@salesforce/apex/CartItemsCtrl.getCartItemList2';
import getCartDeliveryType from '@salesforce/apex/CartItemsCtrl.getCartDeliveryType';
import setDefaultDealerInstallation from '@salesforce/apex/CartItemsCtrl.setDefaultDealerInstallation';
import getCustomLabels from '@salesforce/apex/CartItemsCtrl.getCustomLabels';
import installAtDealerAPIIssue from '@salesforce/label/c.Install_At_Dealer_API_Issue';//By Faraz on 27/06/2022 for 5326
import installAtDealerZeroPrice from '@salesforce/label/c.Install_At_Dealer_Null_Price';//By Faraz on 27/06/2022 for 5326

const DEALER_TYPE = 'Pick Up At Dealer';
const EVENT_NAME = 'installtionchange';
const INSTALL_DEALER = 'InstallAtDealer';
const INSTALL_AT_DEALER = 'Install At Dealer';
const SHIP_TO_ME = 'Ship to Me';
const SUCCESS = 'Success';
const PRODUCT_TYPE = 'Part';
const MOTOCOMPACTO = 'Motocompacto';

export default class CartDealerInstallation extends LightningElement {
    labelInstallAtDealerAPIIssue = installAtDealerAPIIssue;//By Faraz on 27/06/2022 for 5326
    labelInstallAtDealerZeroPrice = installAtDealerZeroPrice;//By Faraz on 27/06/2022 for 5326
    @api cartId;
    @api cartItems;
    @track label = {};
    @track deliveryTypeJSON = {}
    @track isAPIIssue = false;//By Faraz on 27/06/2022 for 5326
    @track isPriceIssue = false;//By Faraz on 27/06/2022 for 5326
    @track anyPartProductExistsOnly = false;
    @track anyProductPickupDealerOnly = false;
    @track value = 'no';
    @track selectedValue = 'Pick Up At Dealer';
    isLoader = false;

    //Added by Shalini Soni 16 March 2022
    async getCustomLabelsFromApex() {
        await getCustomLabels()
        .then(result => {
            if (result) {
                this.label = {
                    PickUpDealer: result.PickUpDealer,
                    InstallAtDealer: result.InstallAtDealer,
                    ShiptoMe: result.ShiptoMe,
                    ShippableErrorMessage: result.ShippableErrorMessage
                    //B2B_Exceeding_Error: result.B2B_Exceeding_Error
                };
            }
        })
        .catch(error => {
            // console.error('Error:', error);
        });
    }
    //Ends

    connectedCallback() {
        try {
            this.getCartDelivery(); // it's for getting delivery type value from backend
            this.getCustomLabelsFromApex(); //Added by Shalini soni 16 March 2022
        } catch (error) {
            //console.error();
        }
    }

   async getCartDelivery() {
        await getCartDeliveryType({ cartId: this.cartId })
        .then(result => {
            this.isLoader = true;
            if (result) {
                this.selectedValue = result;
                if(sessionStorage.getItem('DeliveryType') && sessionStorage.getItem('DeliveryType') != null){
                    this.selectedValue = sessionStorage.getItem('DeliveryType');
                    if(result != this.selectedValue){
                        setDealerInstallationType({ cartId: this.cartId, deliveryType: this.selectedValue })
                        .then(result => {})
                        .catch(error => {
                            console.error('Error :', error);
                        });
                    }
                }
                const boxes = this.template.querySelectorAll('input[type="checkbox"]');
                boxes.forEach(box => {
                    if (box.value.includes(this.selectedValue.trim())) {
                        box.checked = true;
                    }else{
                        box.checked = false;
                    }
                })
                setTimeout(() => {
                    this.getDeliveryTypeJSON(this.selectedValue); // default value for json
                    this.getCartItem();
                }, 2000);
            } else {
                this.isLoader = false;
            }
        })
        .catch(error => {
            //console.error('Error:', error);
            this.isLoader = false;
        });
    }

    handleDealerInstallation(event) {
        event.target.checked;
        this.isLoader = true;
        const boxes = this.template.querySelectorAll('input[type="checkbox"]');
        boxes.forEach(box => box.checked = event.target.name === box.name);
        if (event.target.value) {
            this.selectedValue = event.target.checked ? event.target.value : '';
        }
        sessionStorage.setItem('DeliveryType', this.selectedValue);
        this.getDeliveryTypeJSON(this.selectedValue); // create json for selected options
        setDealerInstallationType({ cartId: this.cartId, deliveryType: this.selectedValue })
        .then(result => {
            if (result && result == SUCCESS) {
                if (this.value) {
                    this.getCartItem();
                }else {
                    const selectedEvent = new CustomEvent(EVENT_NAME, { detail: { partExistance: false, orderType: this.selectedValue, jsonString: this.deliveryTypeJSON } });
                    // Dispatches the event.
                    this.dispatchEvent(selectedEvent);
                }
            } else {
                //console.error(result);
            }
        })
        .catch(error => {
            //console.error('Error:', error);
            this.isLoader = false;
        });
    }

    @api updateCartItemsInfo() {
        this.getCartItem();
        this.getCartDelivery();
    }

    async getCartItem() {
        let cartitemIdAndProductType = new Map();
        let partsExists = false;
        this.isLoader = true;
        if (this.selectedValue) {
            await getCartItemsFromDB({ cartId: this.cartId })
            .then((result) => {
                let isPickupAtDealerOnly = false;
                result.forEach((element) => {
                    cartitemIdAndProductType.set(element.Id, element.Product_Type__c);
                    if (element.Product2.PickupatDealer__c && element.Product2.PickupatDealer__c == true) {
                        isPickupAtDealerOnly = true;
                        this.setDefaultPickupDealerForType(SHIP_TO_ME);
                    }
                });
                this.anyProductPickupDealerOnly = isPickupAtDealerOnly;
            })
            .catch((error) => {
                //console.error(error);
                this.isLoader = false;
            });
            if (this.selectedValue) {
                const dataList = [...JSON.parse(JSON.stringify(this.cartItems))];
                dataList.filter((item) => {
                    if (cartitemIdAndProductType.has(item.cartItem.cartItemId)) {
                        const foundpart = cartitemIdAndProductType.get(item.cartItem.cartItemId) == PRODUCT_TYPE ? true : false;
                        //added for Motocompacto
                        const foundMotocompacto = cartitemIdAndProductType.get(item.cartItem.cartItemId) == MOTOCOMPACTO ? true : false;
                        if (foundpart || foundMotocompacto) {
                            partsExists = foundpart ? foundpart : foundMotocompacto;
                            if (this.selectedValue && (this.selectedValue == INSTALL_DEALER || this.selectedValue == INSTALL_AT_DEALER)) {
                                this.setDefaultPickupDealerForType(this.selectedValue);
                            }
                        }
                    }
                })
                this.anyPartProductExistsOnly = partsExists;
            }
            const selectedEvent = new CustomEvent(EVENT_NAME, { detail: { partExistance: partsExists, orderType: this.selectedValue, jsonString: this.deliveryTypeJSON } });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            let self = this;
            setTimeout(() => {
                self.isLoader = false;
            }, 1000);
        }
    }
    
    //Added by shalini soni 6 Jan 2022
    setDefaultPickupDealerForType(installationType) {
        const boxes = this.template.querySelectorAll('input[type="checkbox"]');
        let shipToMeChecked = false;
        boxes.forEach(box => {
            if (box.value === installationType  && box.checked) {
                box.checked = false;
                shipToMeChecked = true;
                return shipToMeChecked;
            }
        });
        if (shipToMeChecked == true ) {
            boxes.forEach(box => {
                if (box.value === DEALER_TYPE) {
                    box.checked = true;
                }
            });
            this.selectedValue = DEALER_TYPE;
            this.getDeliveryTypeJSON(this.selectedValue); // create json for selected options
            setDealerInstallationType({ cartId: this.cartId, deliveryType: this.selectedValue })
            .then(result => {
                if (result && result == SUCCESS) {
                } else {
                    //console.error(result);
                }
            })
            .catch(error => {
                //console.error('Error:', error);
                this.isLoader = false;
            });
        }
    }

    getDeliveryTypeJSON(type) {
        try {
            const boxes = this.template.querySelectorAll('input[type="checkbox"]');
            let jsonString = {};
            boxes.forEach(box => {
                if (type && box.value.includes(type)) {
                    jsonString[box.name] = "true";
                } else {
                    jsonString[box.name] = "false";
                }
            })
            this.deliveryTypeJSON = JSON.stringify(jsonString);
        } catch (error) {
            //console.error(error.message);
        }
    }

    //By Faraz on 27/06/2022 for 5326 - Start
    @api handleIssueForDealerInstall(issueType){
        if(issueType.includes('API')) {
            this.isAPIIssue = true;
        }else if(issueType.includes('price')) {
            this.isPriceIssue = true;
        }else if(issueType.includes('success')){
            this.isAPIIssue = false;
            this.isPriceIssue = false;
        }
    }
    //By Faraz on 27/06/2022 for 5326 - End
}
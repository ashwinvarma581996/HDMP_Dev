/******************************************************************************* 

Name:  orderView

Business Unit: HDM

Date: MAy 2022
Developer: Yashika.

Description: This is the Order Detail page used for both findmyOrder and order history modules.

******************************************************************************* 

MODIFICATIONS – Date | Dev Name | Method | User Story 

<13-06-2022> | <Yashika> | <added header> | 

*******************************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOrderItemsRelatedToOrder from '@salesforce/apex/OrderHelper.getOrderItemsRelatedToOrder';
import OrderDetailshelper from '@salesforce/apex/GetOrderViewHelper.OrderDetails';
import retryFailedPayment from '@salesforce/apex/B2B_PaymentFormController.retryFailedPayment'; //By Faraz - 5359
import schedule_installation from '@salesforce/label/c.schedule_installation'; //added by Yashika for R2 story: appointment scheduling
// import getOrderItemStatus from '@salesforce/apex/GetOrderViewHelper.getOrderItemStatus';
import { CurrentPageReference } from 'lightning/navigation';
import getOrderList from '@salesforce/apex/B2B_GetOrderInfo.getOrderList';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
//import updateorders from '@salesforce/apex/GetOrderViewHelper.updateorder';

/*
const fields = [CUSTID_FIELD, CUSTORDDATE_FIELD, ORDID_FIELD,SHIP_FIELD];
*/

const DEALER_INSTALL = 'Install At Dealer' // added by Yashika for R2 story: appointment scheduling
const SHIP_TO_ME = 'Ship to Me'//Added by shalini soni 24 Dec 2021 HDMP-5428 R2 Stor
const SHIP_TO_HOME = 'Ship to Home' //Added by shalini soni 24 Dec 2021 HDMP-5428 R2 Stor
//added by Yashika for order return story: start//
const ORDER_RETURN = 'ORDER RETURN'
const PARTIAL_RETURN = 'PARTIAL RETURN'//ends
const RETURN_POLICY = 'Returns and Exchange policies are at the dealer’s discretion, please contact your dealer for more details';

const CORE_CHARGE = 'Core Charge'; // Added by ashwin for US SP2-16549

export default class OrderViewDetails extends NavigationMixin(LightningElement) {
    @api recordId;
    @track shipVendor;
    @track showothercarrier;
    @track Orderdetailresult;
    @track fromorderview;
    @track OrderItemsRelated;
    @api orderId;
    orderItems = [];
    @track SaveStatus;
    @track editpage = false;
    @track OrdersRecord;
    @track showdata;
    @track name;
    @track phone;
    @track email;
    @track status;
    @track shippingnumber;
    @track add1;
    @track city;
    @track state;
    @track zipcode;
    @track returnPolicy;
    @track dealername;
    @track isLoading = false;
    @track proStatus = [{ label: 'Order Created', value: 'Order Created' }];
    //added by Yashika for order return
    @track isStatusReturn = false;
    // these three variables added by Yashika for R2 story: appointment scheduling
    @track dealerSchedulingLink;
    @track isDealerInstallationType = false;
    @track schedule_installation = schedule_installation;
    //ended
    @track userFirstName = '';
    @track isInstallatDealer = true;
    @track showPaymentButtons; //By Faraz for 5359
    @track showPaymentInfoModel; //By Faraz for 5359
    @track paymentInfoLabel; //By Faraz for 5359
    @track orderSFId;
    @track isCustomerNotesExist = false;//By Faraz for 8722
    @track isScheduleLinkAvailableOrNot = false;
    @track showShippingNumber = false;
    @track dealerPrivacyPolicy = false;//Added by Faraz for 11637
    @track isMotoCompacto = false;
    @track isError = false;
    @track disclaimerType;
    dealerReturnPolicyMarkup = "";



    metadatarecid; // Added by Ashwin

    isRemanPresent = false; // Saravanan and Ashwin Added for 16549

    coreChargeValue = 0; // Saravanan and Ashwin Added for 16549

    coreChargePickedandReturn = 0; // Saravanan LTIM for HDMP-19487

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    wireuserdata({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userFirstName = data.fields.Name.value;
        }
    }

    connectedCallback() {
        this.recordId = this.currentPageReference.state.orderId;
        this.orderId = this.currentPageReference.state.orderId;
        this.summarydetail();
        this.getitems();
    }

    navigateToShippingTrackPage(event) {
        ////console.log('called event',event.currentTarget.dataset.id);
        //console.log('called event2', event.target.dataset.id);
        //console.log('Name->', event.target.dataset.name);
        let shippingId = event.target.dataset.id
        if (event.target.dataset.name) {
            this.shipVendor = event.target.dataset.name;
        }
        if (this.shipVendor && this.shipVendor.toLowerCase() == 'fedex') {
            this[NavigationMixin.Navigate]({
                // Pass in pageReference
                type: 'standard__webPage',
                attributes: {
                    url: 'https://www.fedex.com/apps/fedextrack/?action=track&trackingnumber=' + shippingId
                }
            });
        }
        else if (this.shipVendor && this.shipVendor.toLowerCase() == 'ups') {
            this[NavigationMixin.Navigate]({
                // Pass in pageReference
                type: 'standard__webPage',
                attributes: {
                    url: 'https://www.ups.com/track?loc=null&tracknum=' + shippingId + '&requester=ST/'
                }
            });
        }
        else if (this.shipVendor && this.shipVendor.toLowerCase() == 'usps') {
            this[NavigationMixin.Navigate]({
                // Pass in pageReference
                type: 'standard__webPage',
                attributes: {
                    url: 'https://tools.usps.com/go/TrackConfirmAction_input?qtc_tLabels1=' + shippingId
                }
            });
        }
    }
    // added by Yashika for R2 story: appointment scheduling
    //start here
    handleOnScheduleInstallation() {
        window.open(this.dealerSchedulingLink, '_blank');

    }
    //ends here
    @wire(CurrentPageReference)
    currentPageReference;

    summarydetail() {
        OrderDetailshelper({ record: this.recordId }).then(result => {
            if (result) {
                console.log('OUTPUTResult : ', result);
                this.Orderdetailresult = result;
                //added by Yashika for R2 story 5411 : starts here
                console.log('before conv', result[0].OrderedDate.toString())
                console.log('after conv', new Date(result[0].OrderedDate))
                //result[0].OrderedDate=new Date(result[0].OrderedDate).toLocaleString().split(",")[0];
                //result[0].OrderedDate=result[0].OrderedDate.toDate();
                const dateWithoutTime = result[0].OrderedDate.toString().split("T")[0];
                const finalDate = dateWithoutTime.split("-")[1] + "/" + dateWithoutTime.split("-")[2] + "/" + dateWithoutTime.split("-")[0];
                result[0].OrderedDate = finalDate;
                if (result[0].Status == 'ORDER COMPLETE - SHIPPED' || result[0].Status == 'ORDER RETURN' || result[0].Status == 'PARTIAL RETURN') {
                    this.showShippingNumber = true;
                }
                else {
                    this.showShippingNumber = false;
                }
                if (result[0].Total_Item_Return__c == undefined) {
                    result[0].Total_Item_Return__c = 0;
                }
                if (result[0].Total_Restocking_Fees__c == undefined) {
                    result[0].Total_Restocking_Fees__c = 0;
                }
                if (result[0].Total_Ship_Return__c == undefined) {
                    result[0].Total_Ship_Return__c = 0;
                }
                if (!result[0].Total_Installation_Return__c) {
                    result[0].Total_Installation_Return__c = 0;
                }
                if (result[0].Total_Tax_Return__c == undefined) {
                    result[0].Total_Tax_Return__c = 0;
                }
                if (result[0].Total_Return__c == undefined) {
                    result[0].Total_Return__c = 0;
                }

                // Saravanan LTIM Added for 19414                
                if (result[0].Total_Core_Charge_Return_Amount__c == undefined) {
                    result[0].Total_Core_Charge_Return_Amount__c = 0;
                }
                // Saravanan LTIM Ended for 19414 

                //ends here
                //newly added by Sayalee as a part of HDMP-5328 Start
                if (result[0].Account.Service_Scheduling_URL__c) {
                    this.dealerSchedulingLink = result[0].Account.Service_Scheduling_URL__c;
                    this.isScheduleLinkAvailableOrNot = true;
                }
                //end
                if (result[0].Shipping_Vendors__c == 'other' || result[0].Shipping_Vendors__c == 'Other') {
                    this.showothercarrier = true;
                } else {
                    this.showothercarrier = false;
                }
                // added this if condition by Yashika for R2 story: appointment scheduling
                if (result[0].cart__r.Delivery_Type__c == DEALER_INSTALL) {
                    this.isDealerInstallationType = true;
                }//ended

                //Added by shalini soni 24 Dec 2021 HDMP-5428 R2 Story
                if (result[0].cart__r.Delivery_Type__c == SHIP_TO_ME) {
                    result[0].cart__r.Delivery_Type__c = SHIP_TO_HOME;
                }
                //Ended
                // added this if condition by Yashika for R2 story: order return
                // In below If statement (|| result[0].Total_Return__c > 0) added by ashwin for 19474
                if (result[0].CustomerOrderStatus__c == ORDER_RETURN || result[0].CustomerOrderStatus__c == PARTIAL_RETURN || result[0].Total_Return__c > 0) {
                    this.isStatusReturn = true;
                    this.netItems = (result[0].Updated_Order_Amount__c - result[0].Total_Item_Return__c).toFixed(2);
                    this.netTax = (result[0].Updated_Total_Tax__c - result[0].Total_Tax_Return__c).toFixed(2);
                    this.netTotal = (result[0].Updated_Order_Total__c - result[0].Total_Return__c).toFixed(2);

                    this.netInstall = (result[0].Total_Installation_Charges__c - result[0].Total_Installation_Return__c).toFixed(2);
                    this.netShipping = Math.abs(Number(result[0].Updated_Shipping__c) - Number(result[0].Total_Ship_Return__c));
                    this.netShipping = this.netShipping.toFixed(2);
                }//ended
                //Added by Faraz for 5359
                if (result[0].Status && result[0].Status == 'PAYMENT ISSUE' && result[0].IsPaymentReproccessing__c &&
                    result[0].cart__r.Delivery_Type__c != DEALER_INSTALL) {
                    this.showPaymentButtons = true;
                } else {
                    this.showPaymentButtons = false;
                }
                //End
                //Added by Faraz for 8722
                if (result[0].Customer_Notes__c && result[0].Customer_Notes__c.length) {
                    this.isCustomerNotesExist = true;
                    result[0].Order_Transactions__r.forEach(element => {
                        if (element.Dealer_To_Customer_Note__c && element.Dealer_To_Customer_Note__c == result[0].Customer_Notes__c) {
                            const d = new Date(element.CreatedDate);
                            result[0].createdFormatDate = d.toLocaleString();
                        }
                    });
                }
                //added by Yashika for 9927: starts
                result[0].Order_Transactions__r.forEach(element => {
                    if (element.Order_Transaction_Type__c == 'Returned') {
                        const dr = new Date(element.Adjustment_Date_Time__c);
                        result[0].returnDate = dr.toLocaleString().split(",")[0];
                    }

                });
                //9927: ends
                console.log('resultFA : ', result);
                //End 8722

                this.Orderdetailresult = result;
                this.orderSFId = result[0].Id;
                this.name = result[0].Name;
                this.phone = result[0].Phone_No__c;
                this.email = result[0].Email__c;
                this.status = result[0].Status;
                this.shippingnumber = result[0].ShippingNumber__c;
                this.add1 = result[0].BillingStreet;
                this.city = result[0].BillingCity;
                this.state = result[0].BillingState;
                this.zipcode = result[0].BillingPostalCode;
                //Added by Sayalee as a bug HDMP-9902 Start
                if (result[0].Account.Return_Policy__c == undefined) {
                    this.returnPolicy = RETURN_POLICY;
                    if (this.template.querySelector('[data-id="returnpolicy"]')) {
                        this.template.querySelector('[data-id="returnpolicy"]').innerHTML = this.returnPolicy;
                    }
                }
                else {
                    this.dealerReturnPolicyMarkup = result[0].Account.Return_Policy__c;
                    this.returnPolicy = result[0].Account.Return_Policy__c;
                    if (this.template.querySelector('[data-id="returnpolicy"]')) {
                        this.template.querySelector('[data-id="returnpolicy"]').innerHTML = this.returnPolicy;
                    }
                }
                //End
                //Added by Faraz for 11637
                if (result[0].Account.Privacy_Policy_URL__c && result[0].Account.Privacy_Policy_URL__c.length) {
                    this.dealerPrivacyPolicy = result[0].Account.Privacy_Policy_URL__c;
                }
                //End
                this.error = undefined;
            } else {
                this.isError = true;
            }
        }).catch(error => {
            this.isError = true;
            //console.log('#error', error);
        })
    }

    getitems() {
        getOrderItemsRelatedToOrder({ orid: this.recordId })
            .then(result => {
                console.log('result of order items' + JSON.stringify(result));
                //Added by shalini soni 24 Dec 2021 HDMP-5428 R2 Story
                let orderList = [];

                if (result) {
                    result.orderItem.forEach(orderItem => {
                        result.cartItems.forEach(cartItem => {
                            if (orderItem.Product_SKU__c == cartItem.Sku) {
                                if ((cartItem.Cart.Delivery_Type__c == 'Pick Up At Dealer' || cartItem.Cart.Delivery_Type__c == 'Ship to Me') && (cartItem.Dealer_Installation_Price__c == '' || cartItem.Dealer_Installation_Price__c == undefined || cartItem.Dealer_Installation_Price__c == null)) {
                                    this.isInstallatDealer = false;
                                }
                                if (cartItem.Dealer_Installation_Price__c != '' || cartItem.Dealer_Installation_Price__c != undefined || cartItem.Dealer_Installation_Price__c != null) {
                                    let installtionPrice = cartItem.Dealer_Installation_Price__c / cartItem.Quantity;
                                    console.log('##installtionPrice', installtionPrice);
                                    // Added below if condition for SP2-16549
                                    if (!orderList.some(item => item.Id === orderItem.Id)) {
                                        orderList.push({ ...orderItem, 'InstallationPrice': installtionPrice });
                                        if (orderItem.Product_Type__c == CORE_CHARGE) {
                                            // Added below if condition for SP2-16549 to calculate the core charge 
                                            this.isRemanPresent = true;
                                            //this.coreChargeValue += orderItem.Extended_Price__c;
                                        }
                                    }
                                }
                                if (cartItem.Product_Type__c == 'Motocompacto') {
                                    this.isMotoCompacto = true;
                                }
                            }
                        })
                    })
                }

                /*** Begin by Ashwin for US SP2-16549 for Sorting Order Items */

                let sortedOrderList = [];
                let coreItems = [];

                if (this.isRemanPresent) {
                    //this.Orderdetailresult[0].Updated_Order_Amount__c = this.Orderdetailresult[0].Updated_Order_Amount__c - this.coreChargeValue; // Added this line for bug 18157

                    orderList.forEach(itm => {
                        if (itm.Product_Type__c == CORE_CHARGE) {
                            // Saravanan LTIM Added for HDMP-19487


                            this.coreChargePickedandReturn = this.coreChargePickedandReturn + Number(itm.Updated_Quantity__c * itm.ListPrice);


                            // Saravanan LTIM Ended for HDMP-19487
                            coreItems.push(itm);
                        }
                    })
                    orderList.forEach(item => {
                        if (item.Product_Type__c != CORE_CHARGE) {
                            const coreItem = coreItems.find(obj => obj.Product_SKU__c === item.Product_SKU__c);
                            sortedOrderList.push(item);
                            if (coreItem) {
                                sortedOrderList.push(coreItem);
                            }
                        }
                    })
                }

                /*** ended by Ashwin for US SP2-16549 for Sorting Order Items */

                this.OrderItemsRelated = this.isRemanPresent ? sortedOrderList : orderList; // Ashwin Added ternary Op for 16549 (previous value was- orderList)
                this.orderItems = result.orderItem;
                //End by shalini soni 24 Dec 2021
                console.log('OrderItemsRelated ', JSON.parse(JSON.stringify(this.OrderItemsRelated)));
                console.table(orderList);
            })
            .catch(error => {
                this.error = error;
                //console.log('error', this.error);
            });
    }

    //added by Yashika for order history R2 epic
    navigateToFindMyOrder() {
        if (USER_ID == undefined || USER_ID == null || this.userFirstName.includes('Guest')) {
            localStorage.setItem("goBackOrderView", 'yes');
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/findmyorder'
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/order-history'
                }
            });
        }
    }

    //Added by Faraz for 5359
    handleRetryPayment(event) {
        console.log('OUTPUT : ', this.Orderdetailresult);
        if (this.Orderdetailresult && this.Orderdetailresult[0].Id && this.Orderdetailresult[0].cart__c) {
            this.isLoading = true;
            retryFailedPayment({ orderId: this.Orderdetailresult[0].Id, cartId: this.Orderdetailresult[0].cart__c })
                .then(result => {
                    if (result) {
                        console.log('OUTPUT : ', result);
                        if (result.success && result.successMessage && result.successMessage.includes('Your Payment is Successful')) {
                            this.summarydetail();
                            this.paymentInfoLabel = 'Payment was successful!';
                            this.handleShowPaymentInfoModel();
                        } else if (!result.success && result.error != null) {
                            this.paymentInfoLabel = 'Payment failed';
                            this.handleShowPaymentInfoModel();
                        }
                    }
                })
                .catch(error => {
                    console.log('Error : ', error);
                    this.isLoading = false;
                    this.handleShowPaymentInfoModel();
                });
        }
    }

    //Added by Rajrishi for updating the payment 
    handleUpdatePayment(event) {
        let url = '/s/BTUpdatePayment?orderId=' + this.orderSFId;
        window.open(url, '_self');

    }

    handleShowPaymentInfoModel() {
        this.isLoading = false;
        this.showPaymentInfoModel = true;
    }

    handleClosePaymentInfoModel() {
        this.showPaymentInfoModel = false;

    }
    //End 5359
    // Added By Ashwin for Disclaimers Changes
    showDealerModal = false;

    handleDisclamerPopup(event) {


        this.disclaimerType = event.currentTarget.dataset.id;

        this.showDealerModal = true;
    }

    handleShowHide(event) {
        this.showDealerModal = false;

    }
}
import { LightningElement, track } from 'lwc';
// import server side apex class method 
import getOrderList from '@salesforce/apex/B2B_GetOrderInfo.getOrderList';

import { NavigationMixin } from 'lightning/navigation';
// import standard toast event 
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class findMyOrder extends NavigationMixin(LightningElement) {

    @track OrdersRecord;
    @track othercarrierpresent;
    @track shipVendor;
    @track orderTotal;
    searchValue = '';
    searchValue1 = '';
    searchValue2 = '';
    isModalOpen = false;
    showData = false;

    showErrorMessage = false;

    connectedCallback() {

        let flag = localStorage.getItem("goBackOrderView");
        if (flag == 'yes') {
            let selectedOrderNumber = localStorage.getItem("order");
            let selectedEmail = localStorage.getItem("email");
            let selectedZip = localStorage.getItem("zip");

            if (selectedOrderNumber != 'undefined') {
                this.searchValue = selectedOrderNumber;
            }
            if (selectedEmail != 'undefined') {
                this.searchValue1 = selectedEmail;
            }
            if (selectedZip != 'undefined') {
                this.searchValue2 = selectedZip;
            }
            if (this.searchValue || this.searchValue1 || this.searchValue2) {
                this.handleSearchKeyword();
            }

        }
        localStorage.setItem("goBackOrderView", 'no');
    }

    navigatedfromOrderRecordPage(event) {
        fromorderrec = localStorage.getItem("fromorderview");
        ordRec = localStorage.getItem("OrdersRecord");


    }

    navigateToOrderRecordPage(event) {

        //console.log('called event.target.dataset.recordId', event.target.dataset.recordId);
        let orderRecordId = event.target.dataset.recordId
        this[NavigationMixin.Navigate]({
            // Pass in pageReference
            type: 'standard__webPage',
            attributes: {
                url: '/ordersummarypage?orderId=' + orderRecordId
            }
        });

    }
    navigateToShippingTrackPage(event) {
        //console.log('called event',event.currentTarget.dataset.id);
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
    // update searchValue var when input field value change
    searchKeyword(event) {

        this.searchValue = event.target.value;
        localStorage.setItem("order", event.target.value);
        //console.log('order number cookie value' + order);
    }
    searchKeyword1(event) {
        localStorage.setItem("email", event.target.value);
        this.searchValue1 = event.target.value;
    }
    searchKeyword2(event) {
        localStorage.setItem("zip", event.target.value);
        this.searchValue2 = event.target.value;
    }

    // call apex method on button click 
    handleSearchKeyword() {
        try{
        if (document.getElementsByTagName) {
            var inputElements = document.getElementsByTagName("input");   
            for(i=0; inputElements[i]; i++) { 
             if(inputElements[i].className && (inputElements[i].className.indexOf("disableAutoComplete" != -1))){
                  inputElements[i].setAttribute("autocomplete","off");
            }
        } 
     }
    }catch(error){
        }

        if ((this.searchValue !== '' && (this.searchValue1 !== '' || this.searchValue2 !== '')) || (this.searchValue1 !== '' && (this.searchValue !== '' || this.searchValue2 !== '')) || (this.searchValue2 !== '' && (this.searchValue1 !== '' || this.searchValue !== ''))) {
            this.showErrorMessage = false;
            //console.log('inside if');
            getOrderList({
                searchKey: this.searchValue,
                searchKey1: this.searchValue1,
                searchKey2: this.searchValue2,
            })
                .then(result => {
                    // set @track contacts variable with return contact list from server  

                    if (result.length === 0) {
                        //console.log('Inside if  ');
                        this.OrdersRecord = result;

                        this.isModalOpen = true;

                    }
                    else {
                        var check = new Set();
                        result= result.filter(obj => !check.has(obj.OrderNumber) && check.add(obj.OrderNumber));
                        this.OrdersRecord = result;
                        /*this.OrdersRecord.forEach(element => {
                            const dateWithoutTime=element.ActivatedDate;
                            console.log('y',dateWithoutTime)
               const finalDate=dateWithoutTime.split("-")[1]+"/"+dateWithoutTime.split("-")[2]+"/"+dateWithoutTime.split("-")[0];
               console.log('finalDate',finalDate)
                element.ActivatedDate= finalDate;
                        });*/
                        //console.log("orders result list" + JSON.stringify(this.OrdersRecord));

                        //this.OrdersRecord.ActivatedDate=this.OrdersRecord.ActivatedDate.setMinutes(this.OrdersRecord.ActivatedDate.getMinutes() - this.OrdersRecord.ActivatedDate.getTimezoneOffset());

                        /*let ordObj = JSON.parse(JSON.stringify(this.OrdersRecord));

                        let copy_orderinfo = [];
                        JSON.parse(JSON.stringify(ordObj.Order)).forEach(orderinfo => {
                            let orderin = JSON.parse(JSON.stringify(orderinfo));
                            if(orderin.CustomerOrderStatus="order received"){
                                orderin.ShippingNumber="";
                                copy_orderinfo.push(orderin);
                            }
                            
                        });
                        console.log('@@copy_orderinfo ',JSON.parse(JSON.stringify(copy_orderinfo)));
                        ordObj.Order = copy_orderinfo;
                        this.OrdersRecord = ordObj; */


                        //console.log('Shipping vendor :', result[0].ShippingVendor);
                        //console.log('OtherCarrier :', result[0].OtherCarrier);
                        //console.log('other carrier value', result[0].Othercarrierpresent);

                        this.shipVendor = result[0].ShippingVendor;

                        //console.log('inside else' + JSON.stringify(this.OrdersRecord));

                        //console.log('                   @@inside else' + JSON.stringify(result));
                        this.showData = true;

                    }
                })
                .catch(error => {
                    //console.log('inside error' + error);

                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message,
                    });
                    this.dispatchEvent(event);
                    // reset contacts var with null   
                    this.OrdersRecord = null;
                });
        } else {
            // fire toast event if input field is blank
            //console.log('inside else');
            this.showErrorMessage = true;
            this.showData = false;
            // const event = new ShowToastEvent({
            //     variant: 'error',
            //     title: 'Error',
            //     message: 'Must provide at least 2 pieces of information',
            // });
            // this.dispatchEvent(event);
        }


        if (this.searchValue == '') { localStorage.setItem("order", 'undefined'); }
        if (this.searchValue1 == '') { localStorage.setItem("email", 'undefined'); }
        if (this.searchValue2 == '') { localStorage.setItem("zip", 'undefined'); }
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }
}
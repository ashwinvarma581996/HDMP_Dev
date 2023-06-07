//============================================================================
// Title:    Honda Owners Experience - Sign Up and Log In
//
// Summary:  level 1 menu logic at the top of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the level 1 menu component for all help center pages.
//
//
// History:
// April 11, 2023 Arunprasad Nagarajan (Wipro) Original Author
//===========================================================================
import { LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getOrderList from '@salesforce/apex/B2B_GetOrderInfo.loggedInUserOrderHistory';
import USER_ID from '@salesforce/user/Id';
import dreamShopIDPLoginURL	from '@salesforce/label/c.DreamShopIDPLoginURL';
import Dreamshop_Url from '@salesforce/label/c.Dreamshop_Url';

export default class OwnOrderHistory extends OwnBaseElement {
    @track OrdersRecord;
    @track shipVendor;
    @track shippingvendor;
    @track orderTotal;
    userId=USER_ID;
    orderlist;
    isOrder = true;
    errorMessage ='We’re experiencing technical difficulties, please try again later.';
    isError=false;
    urlparameter = '';


    connectedCallback(){
       this.getLoggedInUserOrderHistory();
    }
    
    handleOrderSearch(event){
        let searchvalue = event.detail.value;
        if(searchvalue.length>=3){
            searchvalue = searchvalue.toLowerCase();
            let orders = [];
            try{this.orderlist.forEach(item => { 
                if((item.OrderNumber && item.OrderNumber.toString().toLowerCase().includes(searchvalue)) || 
                (item.OrderReferenceNumber && item.OrderReferenceNumber.toString().toLowerCase().includes(searchvalue)) ||
                (item.customOrderDate && item.customOrderDate.toString().toLowerCase().includes(searchvalue)) ||
                (item.Account.Name.toLowerCase().includes(searchvalue)) ||
                (item.CustomerOrderStatus__c.toLowerCase().includes(searchvalue)) ||
                (item.Updated_Order_Total__c.toString().includes(searchvalue)) ||

                (item.ShippingCity && item.ShippingCity.toString().toLowerCase().includes(searchvalue)) ||
                (item.ShippingCountry && item.ShippingCountry.toString().toLowerCase().includes(searchvalue)) ||
                (item.ShippingPostalCode && item.ShippingPostalCode.toString().toLowerCase().includes(searchvalue)) ||
                (item.ShippingState && item.ShippingState.toString().toLowerCase().includes(searchvalue)) ||
                (item.ShippingStreet && item.ShippingStreet.toString().toLowerCase().includes(searchvalue))){
                    if(item.Status=='ORDER COMPLETE - SHIPPED' || item.Status=='ORDER RETURN' || item.Status=='PARTIAL RETURN'){
                        orders.push({...item,showShippingNumber: 'true'})
                        }
                    else{
                        orders.push({...item})
                    }
                }
            });}
            catch(error){
                console.error(error.message);
            }
            if(orders.length!=0){
                this.isOrder =true;
                this.OrdersRecord = orders;
            }
            else{
                this.isOrder =false;
                orders = [];
            }
                 
        }else{
            this.isOrder =true;
            this.OrdersRecord =this.orderlist;
        }
         
    }
    handleSearch(event){
        let searchvalue = this.template.querySelector('.orderSearch').value;
        searchvalue = searchvalue.toLowerCase();
        let orders = [];
        try{this.orderlist.forEach(item => { 
            if((item.OrderNumber && item.OrderNumber.toString().toLowerCase().includes(searchvalue)) || 
            (item.OrderReferenceNumber && item.OrderReferenceNumber.toString().toLowerCase().includes(searchvalue)) ||
            (item.customOrderDate && item.customOrderDate.toString().toLowerCase().includes(searchvalue)) ||
            (item.Account.Name.toLowerCase().includes(searchvalue)) ||
            (item.CustomerOrderStatus__c.toLowerCase().includes(searchvalue)) ||
            (item.Updated_Order_Total__c.toString().includes(searchvalue)) ||

            (item.ShippingCity && item.ShippingCity.toString().toLowerCase().includes(searchvalue)) ||
            (item.ShippingCountry && item.ShippingCountry.toString().toLowerCase().includes(searchvalue)) ||
            (item.ShippingPostalCode && item.ShippingPostalCode.toString().toLowerCase().includes(searchvalue)) ||
            (item.ShippingState && item.ShippingState.toString().toLowerCase().includes(searchvalue)) ||
            (item.ShippingStreet && item.ShippingStreet.toString().toLowerCase().includes(searchvalue))){
                   //added by Yashika for 14315: starts
                if(item.Status=='ORDER COMPLETE - SHIPPED' || item.Status=='ORDER RETURN' || item.Status=='PARTIAL RETURN'){
                    orders.push({...item,showShippingNumber: 'true'})
                    }
                else{
                    orders.push({...item})
                }
            }
        });}
        catch(error){
            console.error(error.message);
        }
        this.OrdersRecord = orders;           
        
    }

    getLoggedInUserOrderHistory(){
        getOrderList({recordId:this.userId}).then(result=>{
            if(result && result.length!=0){
                this.OrdersRecord= JSON.parse(JSON.stringify(result));
                this.orderlist=JSON.parse(JSON.stringify(result));;
                let ordRec=[];
                //added by Yashika for 14315: starts
                this.OrdersRecord.forEach(element => {
                    element.customOrderDate = this.formatDate(element.OrderedDate); 
                     if((element.Status=='ORDER COMPLETE - SHIPPED' || element.Status=='ORDER RETURN' || element.Status=='PARTIAL RETURN')){                                         
                        ordRec.push({...element,showShippingNumber: 'true'})
                        }
                    else{
                        ordRec.push({...element})
                    }
                })
                this.OrdersRecord=ordRec;
                this.orderlist=ordRec;  //14315: ends
            }
            else if(result.length==0){
                this.isOrder = false;
            }
        })
        .catch((error) => {
            console.error('Error:', JSON.stringify(error));
            this.isError = true;
        });
    }
    getOrdersRecord(){
        if(this.OrdersRecord.length == 0){
            this.isOrder = false;
        }
    }

    
  formatDate(dateString){
    const dateWithoutTime = dateString.toString().split("T")[0];
		const finalDate = dateWithoutTime.split("-")[1]+"/"+dateWithoutTime.split("-")[2]+"/"+dateWithoutTime.split("-")[0];
		dateString = finalDate;
    return finalDate;
  }
    
    navigateToOrderRecordPage(event) {
        let orderRecordId = event.target.dataset.recordId;
        let refnumber = event.target.dataset.recordRefnumber;
        this.urlparameter = refnumber !=undefined ? refnumber : orderRecordId;
        this.navigate(dreamShopIDPLoginURL + '&RelayState=' + Dreamshop_Url  + 'ordersummarypage?orderId=' + orderRecordId +'&orderSearched='+this.urlparameter, {});        
    }

    navigateToShippingTrackPage(event) {
        let shippingId = event.target.dataset.id
        if (event.target.dataset.name) {
            this.shippingvendor = event.target.dataset.name;
        }
        if (this.shippingvendor.toLowerCase() == 'fedex') {
            this.navigate('https://www.fedex.com/apps/fedextrack/?action=track&trackingnumber=' + shippingId, {});
        }
        else if (this.shippingvendor.toLowerCase() == 'ups') {
            this.navigate('https://www.ups.com/track?loc=null&tracknum=' + shippingId + '&requester=ST/', {});
        }
        else if (this.shippingvendor.toLowerCase() == 'usps') {
            this.navigate('https://tools.usps.com/go/TrackConfirmAction_input?qtc_tLabels1=' + shippingId, {});
        }
    }
}
import { LightningElement, api, track, wire } from 'lwc';
import getMyProductDetail from '@salesforce/apex/B2B_GetOrderInfo.getMyProductDetail';
import getReturnPolicyMarkupMdt from '@salesforce/apex/B2B_DealerReturnPolicyController.getReturnPolicyMarkupMdt';

export default class ProductsDetail extends LightningElement {

    @api recordId;
    @track error;
    @track mylists;
    @api selectPartData;
    @api selectAccessoryData;
    @track poductTypeValue;
    @track selectedpartValue;
    @track selectedAssValue;
    @track prodcutType = true;
    @api colorNames;
    @track packageQuantity;
    @track allProductValues = { Height: '', Width: '', Length: '', Weight: '', PackageQuantity: '', ShippingOptions: '' };

    /**
    * Abhishek Gowlikar
    */
    popupHeader;
    // Lakshmi Removed the Values assigment 18551
    @api htmlMarkup = '';
    get disclaimerMarkup() {
        return this.htmlMarkup;
    }
    set disclaimerMarkup(value) {
        this.htmlMarkup = value;
    }

    @wire(getReturnPolicyMarkupMdt)
    metadatarecord({ error, data }) {
        if (data) {
            this.disclaimerMarkup = data.B2B_Product_Disclaimer_Markup.Markup__c;
        }
        if (error) {
            console.log('error==>', JSON.stringify(error));
            //Lakshmi HDMP-18551 - for removing error message.
            this.disclaimerMarkup = ''; 
        }
    };

    connectedCallback() {
        let pageURL = window.location.href;
        this.recordId = pageURL ? pageURL.substring(pageURL.lastIndexOf('/') + 1, pageURL.length) : '';


        //Added by Deepak 1 April : HDMP-8547 
        if (this.selectPartData && this.selectPartData.hasOwnProperty('QuantityRequired')) {
            // this.packageQuantity = this.selectPartData.QuantityRequired * 1; // if qty is 0001 * 1 = 1
            this.packageQuantity = 1; // added this to default the package quantity to 1 for parts data.

        } else if (this.selectAccessoryData && this.selectAccessoryData.hasOwnProperty('quantity')) {
            this.packageQuantity = this.selectAccessoryData.quantity * 1; // if qty is  0001 * 1 = 1

        }
        //Ends


    }

    getUrlParameter(name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
        var results = regex.exec(location.search);
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    }


    @wire(getMyProductDetail, { recordProductId: '$recordId' })
    wiredGetMyProductsDetail({ error, data }) {
        if (data) {

            this.mylists = data;

            this.error = undefined;
            this.showProductDetail();
        } else if (error) {
            this.error = error;
            this.mylists = undefined;
        }
    }

    showProductDetail() {

        // Data getting from Backend for Parts 
        if (this.mylists && this.mylists.Height_in) {
            this.allProductValues.Height = this.mylists.Height_in;
        }
        if (this.mylists && this.mylists.Length_in) {
            this.allProductValues.Length = this.mylists.Length_in;
        }
        if (this.mylists && this.mylists.Width_in) {
            this.allProductValues.Width = this.mylists.Width_in;
        }

        if (this.mylists && this.mylists.Weight_lbs) {
            this.allProductValues.Weight = this.mylists.Weight_lbs;
        }

        if (this.mylists) {
            // || this.mylists.core_charge_unit_price == 0 added by ashwin for bug 19483
            if (this.mylists.Shipping_Details === true || this.mylists.core_charge_unit_price != 0) {
                this.allProductValues.ShippingOptions = 'Pick Up At Dealer';
            } else {
                this.allProductValues.ShippingOptions = 'Pick Up At Dealer, Shippable';
            }
        }
        this.allProductValues.PackageQuantity = this.packageQuantity;
        // if(this.selectedpartValue && this.selectedpartValue.QuantityRequired){
        //     var quantityRequire = parseInt(this.selectedpartValue.QuantityRequired);
        //     this.allProductValues.PackageQuantity  = quantityRequire;
        // } else {

        //}
        // if(this.selectAccessoryData != undefined && this.selectAccessoryData != null && this.selectAccessoryData != '' && this.selectAccessoryData != 'undefined'){
        // }

    }
}
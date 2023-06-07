import { LightningElement, track, wire } from 'lwc';
import getProduct from '@salesforce/apex/B2B_VehicleSelectorController.getProduct';
import getBrand from '@salesforce/apex/B2B_VehicleSelectorController.getBrand';
// added to refresh current vehicle and dealer info - start 
import {publish, subscribe,unsubscribe, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
// added to refresh current vehicle and dealer info - end 
export default class DealerVehicleBtn extends LightningElement {


    // @track
    showDealer = true;
    @track showComponents = false;

    // added to refresh current vehicle and dealer info - start 
    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            HDMP_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message){
        if(message.refreshComponent){
            this.showComponents = false;
            this.getBrandDetails();
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    connectedCallback(){
        this.subscribeToMessageChannel();
         this.getBrandDetails();//Added by shalini for HDMP-8290
    }
    // added to refresh current vehicle and dealer info - end 
       //Added by shalini for HDMP-8290
       getBrandDetails() {
        let storedCartId = localStorage.getItem('cartId');
        console.log('##calling',storedCartId);
        if(storedCartId){
            getBrand({
            cartId: storedCartId
            }).then(result => {
                if(result){
                    let brand = result;
                    console.log('##result brand',brand);
                    localStorage.setItem('cartBrand',brand); 
                }
                 console.log('##result1',localStorage.getItem('cartBrand'));
            }).catch(error => {
           
            }).finally( () =>{
                this.buildCartEffectiveVehicleAndDealer();
            })
        }else{
            this.buildCartEffectiveVehicleAndDealer();
        }
    }
    //Ends
    buildCartEffectiveVehicleAndDealer(){
        let baseurl=window.location.href;
        if(baseurl.includes('cart')){
            console.log('##result1 btn',localStorage.getItem('cartBrand'));
            let brand = localStorage.getItem('cartBrand');
            console.log('##@@ brand ',brand);
            sessionStorage.setItem('brand', brand);
            this.showComponents = true;
        }else if(baseurl.split('/').includes('honda')){
            sessionStorage.setItem('brand', 'Honda');
            this.showComponents = true;
        }else if(baseurl.split('/').includes('acura')){
            sessionStorage.setItem('brand', 'Acura');
            this.showComponents = true;
        }else {
            var finalurl = baseurl.split('/');
            let productid = finalurl[6] ? finalurl[6] : finalurl[5];
            getProduct({
                productId: productid
            }).then(result => {
                if(result){
                    if(result.Division__c === 'A'){
                        sessionStorage.setItem('brand', 'Honda');
                    }
                    if(result.Division__c === 'B'){
                        sessionStorage.setItem('brand', 'Acura');
                    }
                    if(baseurl.split('/').includes('honda')){
                        sessionStorage.setItem('brand', 'Honda');
                    }
                    if(baseurl.split('/').includes('acura')){
                        sessionStorage.setItem('brand', 'Acura');
                    }
                    this.showComponents = true;
                }
            }).catch(error => {
            });
        }
        
    }
}
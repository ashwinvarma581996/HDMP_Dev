import {LightningElement, track, api, wire} from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { getCurrentDealer } from 'c/utils';
import communityId from '@salesforce/community/Id';
import getCartItemCategory from '@salesforce/apex/B2B_VehicleSelectorController.getCartItemCategory';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import getBrand from '@salesforce/apex/B2B_VehicleSelectorController.getBrand';
import isguest from '@salesforce/user/isGuest'
import getLastDealers from '@salesforce/apex/B2B_ShoppingSelectionController.getLastDealers';
import getUserDetails from '@salesforce/apex/B2B_ShoppingSelectionController.getUserDetails';
import getDealerInfo from '@salesforce/apex/B2B_GetSelectedDealer.getDealerInfo';
import USER_ID from '@salesforce/user/Id';
import myPNG_icon from '@salesforce/resourceUrl/MapImage';
//import acura_image from '@salesforce/resourceUrl/acura_image';

const CART_EMPTY='EmptyCart';

export default class ModalPopupLWC extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @api displayMyDealerText = false;
    @track isModalOpen = false;
    @track modalLabel
    @track cartData=false;
    categoryvalue;
    POITypevalue;
    mapListofAllPois;
    cartBrands;
    @track checkpoitype ;
    @track 
    @track dealerHeader = 'Find Dealer';
    @track dealerTitle = 'Select Dealer';
    subscription = null;
    eventFiredCallback;
    dealerInfoModelOpen = false;
    mapIcon = myPNG_icon;
    selectedDealerInfo;
    dealerHours;

    @wire(CurrentPageReference)
    pageRef;

    // By using the MessageContext @wire adapter, unsubscribe will be called
    // implicitly during the component descruction lifecycle.
    @wire(MessageContext)
    messageContext;

    @track
    emptyCart=false;

    //This method is to set the Service For Attribute for all the pages 
    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);
    }
  
    connectedCallback() {
        //Added By Imtiyaz-START
        if(!isguest){
            getUserDetails({userId: USER_ID}).then((result) => {
                if(result && result.Name && !result.Name.toLowerCase().includes('guest')){
                    getLastDealers().then((res) => {
                        // multiple cart issue 2 starts here
                        //let brand = localStorage.getItem('brand') ?? localStorage.getItem('cartBrand');
                        let brand = sessionStorage.getItem('brand') ;
                        // multiple cart issue 2 ends here
                        let brandDivision = brand == 'Honda' ? 1 : 2;
                        if(res){
                            let brands = [];
                            let currentDealer;
                            res.forEach(dealer => {
                                let dealerObj = {'id': dealer.Id, 'label': dealer.Name, 'dealerNo': dealer.PoIId__c };
                                dealerObj.brand = dealer.DivisionCd__c == 'A' ? 'Honda' : 'Acura';
                                brands.push(dealerObj);
                                if(brand == dealerObj.brand){
                                    currentDealer = dealer;
                                }
                            });
                            localStorage.setItem('effectiveDealer', JSON.stringify({ 'brands': brands }));
                            let dealer = getCurrentDealer();
                            if(dealer && dealer.label && dealer.label != null && dealer.label != undefined && dealer.label.length){
                                this.dealerTitle = dealer.label;
                            }
                        }
                    }).catch((error) => {
                        console.error('$MSD HC:POP getLastDealer error-',error);
                    });
                }
            }).catch((error) => {
                console.error('$MSD HC: getUserDetails error-',error);
            });
        }
        
        //Added By Imtiyaz-END
        try {
            if (sessionStorage.getItem('successmsg') && sessionStorage.getItem('successmsg') == 'success') {
                let baseurl=window.location.href;
                if(baseurl.includes('cart')){
                    let arr = baseurl.split('/');
                    getBrand({cartId: arr[5]})
                    .then(result => {
                        if(result){
                            // multiple cart issue 2 starts here
                            //localStorage.setItem('brand',result);
                            sessionStorage.setItem('brand',result);
                            // multiple cart issue 2 ends here
                        }
                    }).catch(error => {
                        //console.log('OUTPUT : ',error);
                    });
                }
            }
        } catch (error) {
            //console.log('OUTPUT : ',error);
        }
        if(sessionStorage.getItem('brand')){
            this.dealerHeader = 'Find ' + sessionStorage.getItem('brand') + ' Dealer';
        }
        else if(this.getCookie('Division') && this.getCookie('Division') != 'null'){
            this.dealerHeader = this.getCookie('Division') == 1 ? 'Find Honda Dealer' :  this.getCookie('Division') == 2 ? 'Find Acura Dealer' : 'Find Dealer';
        }

        let cURL = window.location.href;
        if(cURL && cURL.toLowerCase().includes('/acura')){
            this.dealerHeader = 'Find Acura Dealer';
        }
        if(cURL && cURL.toLowerCase().includes('/honda')){
            this.dealerHeader = 'Find Honda Dealer';
        }
        
        this.subscribeToMessageChannel();
        let baseurl=window.location.href;
        if(baseurl.includes('cart')){
            this.cartData=true;
            this.findCartItems(); 
            // registerListener(
            //     'EmptyCart',
            //     this.emptyCart,
            //     this
            // );
        }
        else{
            this.subscribeToMessageChannel();
        }
        this.handleGetDealerInfo();
    }
    
    handleGetDealerInfo(){
        try {
            if(this.dealerLabel && this.dealerLabel != 'Select Dealer'){
                getDealerInfo({dealerName: this.dealerLabel})
                .then(result => {
                    if(result){
                        this.selectedDealerInfo = JSON.parse(result)[0];
                        this.dealerHours = this.selectedDealerInfo.Operation_Hour__c.split(';');
                         //Lakshmi HDMP-19454, HDMP-19445 for salesTax jurisdiction
                         if( this.selectedDealerInfo.Sales_Tax_Jurisdiction__c){
                            if( this.selectedDealerInfo.Sales_Tax_Jurisdiction__c.split(';').length > 50){
                                this.selectedDealerInfo.shippingtaxstate = 'All 50 States';
                            }else{
                                this.selectedDealerInfo.shippingtaxstate =  this.selectedDealerInfo.Sales_Tax_Jurisdiction__c.replaceAll(';',',');
                            }
                        } else{
                            this.selectedDealerInfo.shippingtaxstate = this.selectedDealerInfo.BillingState; //Lakshmi HDMP-19495
                        }
                    
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                });
            }
        } catch (error) {
            console.log('Error : ',error);            
        }
    }
    
    emptyCart(value){
        this.emptyCart=value;
        this.dealerLabel();
    }

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            HDMP_MESSAGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    // Handler for message received by component
    handleMessage(data) {
        if(data.message.dealerLabel && data.message.dealerLabel != null && data.message.dealerLabel != undefined && data.message.dealerLabel.length){
            this.dealerTitle = data.message.dealerLabel;
        }
           //for adobe: starts
       let doNotCloseModal= sessionStorage.getItem('donotCloseModal');
        //console.log('##test IN handleMessage1',this.dealerTitle);
        //console.log('first time selection'+localStorage.getItem('FirstSelectedBrand'));
        if(doNotCloseModal!='true'){
        this.closeModal();
        sessionStorage.setItem('donotCloseModal','false');
        }
    }

    get dealerLabel(){
        if(this.cartData){
            return this.dealerTitle;
        }else{
            let dealer = getCurrentDealer();
            if(isguest && dealer){
                sessionStorage.setItem('guestHasDealer','true');
            }
            if(dealer && dealer.label && dealer.label != null && dealer.label != undefined && dealer.label.length){
                this.dealerTitle = dealer.label;
            }
       }
       return this.dealerTitle;
    }

    findCartItems(){
        getCartItemCategory({ communityId:communityId}).then((result) => {
            if(result && result.catName){
                let categoryname=result.catName;
                if(categoryname && categoryname !='dual'){
                    let cartName,brand,cartBrands;
                    let brands = [];
                    cartName = (result.catName).toLowerCase();
                    cartBrands =  cartName.charAt(0).toUpperCase() + cartName.slice(1);  
                    brand = sessionStorage.getItem('brand');
                    if(localStorage.getItem('effectiveDealer')){
                        brands = JSON.parse(localStorage.getItem('effectiveDealer'))['brands'];
                        if(brands){
                            let brandValue = brands.find(val => val.brand == brand);                       
                            if(brandValue !== undefined && brandValue.label && brandValue.label != undefined && brandValue.label != null && brandValue.label.length){
                                this.dealerTitle=brandValue.label;
                            }else if(brandValue == undefined){
                                let dealer = getCurrentDealer();
                                if(dealer && dealer.label && dealer.label != null && dealer.label != undefined && dealer.label.length){
                                    this.dealerTitle = dealer.label;
                                }
                            }
                            if(brandValue){
                                localStorage.setItem('cartBrand',cartBrands);
                            }
                        }                
                    }
                }else{
                    let brands=[];
                    let brand = sessionStorage.getItem('brand');
                    if(localStorage.getItem('effectiveDealer')){
                        brands = JSON.parse(localStorage.getItem('effectiveDealer'))['brands'];
                        if(brands){
                            let brandValue = brands.find(val => val.brand == brand); 
                            if(brandValue !== undefined && brandValue.label && brandValue.label != undefined && brandValue.label != null && brandValue.label.length){
                                this.dealerTitle=brandValue.label;
                            }
                            localStorage.setItem('DualBrand',brandValue.label);
                        }
                    }
                }
            }else{
                if(!(result && result.catName) ){
                    this.dealerTitle = 'Select Dealer';
                    let dealer = getCurrentDealer();
                    if(dealer && dealer.label && dealer.label != null && dealer.label != undefined && dealer.label.length){
                        this.dealerTitle = dealer.label;
                    }
                }
            }
        })
        .catch((error) => {
            console.log('error::::' + JSON.stringify(error));
        });          
    }

    renderedCallback(){
        if(this.selectedDealerInfo == undefined){
            this.handleGetDealerInfo();
        }
    }
    
    openModal() {
        if(!sessionStorage.getItem('dealer')){
            this.isModalOpen = true;
        }else if(sessionStorage.getItem('dealer')){
            this.dealerInfoModelOpen = true;
        }
    }

    closeModal() {
        this.isModalOpen = false;
        this.dealerInfoModelOpen = false;
    }

    clearCookie() {
        this.createCookie('dealerLabel', '', 1); // Clear cookie first
        this.dealerLabel = 'Select Dealer';
        this.boolVisible = false;
        var currURL = window.location.href;
        var parts = currURL.split('/');
        var lastSegment = parts.pop() || parts.pop(); // handle potential trailing slash
        if (lastSegment != 'honda' && lastSegment != 'acura') {
            location.reload();
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
        //updated by Pradeep Singh for Optive Issue
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
        // ends here
    }
  
    handleSelectDealer(event){
        this.closeModal();
    }
}
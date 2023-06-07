/******************************************************************************* 
Name: myDealers 
Business Unit: HDM
Created Date: 04-02-2022
Created By : Shalini soni
Description: This component used display saved dealers in my dealers

******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
           11-08-2022| saikiran | added RemoveDealer,handleCancel 
                                 updated removeSelectedDealer | HDMP-5381

           25-08-2022| saikiran | removeSelectedDealer,updateDealerOnCart | HDMP-12404,HDMP-12398
*******************************************************************************/ 
import { LightningElement, api, track, wire } from 'lwc';
import deleteDealers from '@salesforce/apex/B2B_LoggedInUserMyDealers.deleteDealers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import communityId from '@salesforce/community/Id';
import updateDealerIdOnCart from '@salesforce/apex/B2B_LoggedInUserMyDealers.updateDealerIdOnCart';
import getReturnPolicy from '@salesforce/apex/B2B_LoggedInUserMyDealers.getReturnPolicy';
//Added by Pradeep for HDMP-8188
import updateDealerPrice from '@salesforce/apex/CartItemsCtrl.updateDealerPrice';
import myPNG_icon from '@salesforce/resourceUrl/MapImage';
import saveLastDealer from '@salesforce/apex/B2B_ShoppingSelectionController.saveLastDealer';

//ends here

const DIVISION_A = 'A';
const DIVISION_B = 'B';
const BRANDS = 'brands';
const HONDA = 'Honda';
const ACURA = 'Acura';
const EFFECTIVE_DEALER = 'effectiveDealer';
const SELF = '_self';
export default class MyDealersDisplay extends LightningElement {
    @track returnPolicy;
    @api dealersList;
    @track brandHondaURL = '/s/honda';
    @track brandAcuraURL = '/s/acura';
    @track brandName;
    @track checkBool = false;
    mapIcon = myPNG_icon;
    @track vfPageBingMapURL;
    @track isModalOpen = false;
    @track isShowModal1 = false; //Added by saikiran as part of HDMP-5381
    @track dealerRecordId = ''; //Added by saikiran as part of HDMP-5381

    @wire(MessageContext)
    messageContext;
    connectedCallback() {
        this.vfPageBingMapURL = window.location.origin + '/bingMapVfPage';
    }
   //Added by saikiran as part of HDMP-5381
   RemoveDealer(event){
        this.isShowModal1 = true ;
        this.dealerRecordId = event.currentTarget.dataset.id ;
    }
    handleCancel(){
        this.isShowModal1 = false ; //Added by saikiran as part of HDMP-5381
        this.dealerRecordId ='';
    }
    // This function to remove dealers from my Dealers page when user click on remove button 
    removeSelectedDealer(event) {
        this.isShowModal1 = false; //Added by saikiran as part of HDMP-5381
        console.log('event',event);
        let recordId = this.dealerRecordId ;
        deleteDealers({ dealerId: recordId })
            .then(result => {
                if (result.error == false) {
                    this.dealersList = result.accountList;
                    //updated by saikian as part of HDMP 9914
                    this.dealersList.forEach(element => {
                        if(element.DivisionCd__c == DIVISION_A){
                            element.brandName = 'Honda Auto';
                        }
                        else if(element.DivisionCd__c == DIVISION_B){
                            element.brandName = 'Acura';
                        }
                        if(element.Operation_Hour__c){
                            var hours = element.Operation_Hour__c ;
                            element.OperationHours = hours.split('\;');
                        }
                    });
                    this.showToastMessage('Success', ' deleted Successfully', 'success');
                    // Added by saikiran as part of HDMP-12404
                    window.location.reload();
                } else if (result.error == true) {
                    console.error(error.errorMessage);
                    this.showToastMessage('Error', 'Apex Error ' + error.errorMessage, 'error');
                }
            })
            .catch(error => {
                console.error(error);
                this.showToastMessage('Error', error.message, 'error');
            });


    }
    // This function is for when user's shop now will redirect to brand home page for that brand with the dealer active in the header
    handleToShop(event) {
          try {
            // updated by Pradeep for HDMP - 8188
            const targetElm = event.target;
            let dealerId = event.currentTarget.dataset.id;
            this.handleSelectDealer(dealerId, event.currentTarget.dataset.division);
            this.updateDealerOnCart(dealerId,targetElm);
            // ends here
        } catch (error) {
            console.log(error.message);
        }

    }
    // HDMP-8300 - Lakshman changes - Starts
    updateDealerOnCart(dealerAccountId,targetElm){
        const dealerLabel = targetElm.getAttribute('data-title');
        const dealerNo = targetElm.getAttribute('data-dealerno');
        let record = this.dealersList.find(item => item.Id == dealerAccountId);
        updateDealerIdOnCart({communityId: communityId,dealerId: dealerAccountId})
            .then(result=>{
                //added By Pradeep for HDMP-8188
                let selectedBrand = localStorage.getItem('cartBrand') == 'Acura' ? '2' : '1';
                updateDealerPrice({ cartId: result, selectedBrand: selectedBrand })
                .then(result => {
                    //updated by saikiran as part of HDMP-12398
                        if (record.DivisionCd__c == DIVISION_A) {
                            this.buildEffectiveDealer(HONDA, dealerAccountId, dealerLabel, dealerNo);
                            window.open(this.brandHondaURL, SELF);            
                        } else if (record.DivisionCd__c == DIVISION_B) {            
                            this.buildEffectiveDealer(ACURA, dealerAccountId, dealerLabel, dealerNo);
                            window.open(this.brandAcuraURL, SELF);
                        }            
                        const message = { message: { 'dealerLabel': dealerLabel, 'products': '' } };
                        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                })
                .catch(error => {
                    console.error('Error saving the dealer price', error);
                });
                //ends here
            })
            .catch(error=>{
                console.error(error);
        });
    }
    // HDMP-8300 - Lakshman changes - Ends

    handleSelectDealer(dealerId, division) {
        let brand = division == 'A' ? 'Honda' : 'Acura';
        sessionStorage.setItem('brand',brand);
        this.createCookie('brand',brand, 1);
        sessionStorage.setItem('vehicleBrand',brand);
        console.log('$MDD: dealerId: ', dealerId);
        console.log('$MDD: brand: ', brand);
        console.log('$MDD: division: ',division);
        saveLastDealer({shoppingSelection : {Product_Subdivision__c: brand,Last_Dealer__c: dealerId}}).then((result) => {
            console.log('$MDD: saveLastDealer result', result);
        }).catch((error) => {
            console.error('$MDD: saveLastDealer error', error);
        });
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

    // This function to create the cookies for selected dealer Label from shop now button
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
    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    showPopUp(event) {
        this.checkBool = true;
        let dealerId = event.currentTarget.dataset.id;
        getReturnPolicy({ dealerId: dealerId })
            .then(result => {
                console.log('Result is' + result);
                this.returnPolicy = result;
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error Occured',
                    message: 'Error: ' + error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(event);    //To show an error Taost if error occurred while the APEX call
            });
    }

    closeModal() {
        this.checkBool = false;
        this.isModalOpen = false;

    }
    //Added by deepak mali for HDMP-8365
    goToMap(event) {
            let lat, lon, POIName,FullAddress,Phone;
            var dealerNo = event.currentTarget.dataset.dealerno;

            if (this.dealersList && this.dealersList != undefined) {
                this.dealersList.forEach(element => {
                    if (dealerNo == element.PoIId__c) {
                        lat = element.B2B_Distance__Latitude__s;
                        lon = element.B2B_Distance__Longitude__s;
                        POIName = element.Name;
                         FullAddress = element.BillingStreet +' '+ element.BillingCity +' '+ element.BillingState  +' '+ element.BillingPostalCode;
                         Phone = element.Phone ;
                         Phone = Phone.replace(/(\d{3})(\d{3})(\d{4})/,'($1)-$2-$3');

                    }
                });
            }
            if (lat !== null && lon !== null) {
                let locationList = [];
                locationList.push({ 'POIName': POIName, 'Longitude': lon, 'Latitude': lat , 'Phone':Phone, 'FullAddress':FullAddress});
                setTimeout(() => {
                 this.sendMessgaeToVisualForce(locationList, true);
                },1500);
            }
            this.isModalOpen = true;
    }

     sendMessgaeToVisualForce(locationList, scollToMap) {
            let message = {
                message: JSON.stringify(locationList),
                source: 'LWC'
            };

            let visualForce = this.template.querySelector(".VFIframe");

            if (visualForce) {
                visualForce.contentWindow.postMessage(message, '*');
                if (scollToMap == true) {
                    visualForce.scrollIntoView({ behaviour: "smooth" });
                }
            }

    }
    //Ends
}
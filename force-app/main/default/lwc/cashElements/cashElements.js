import { LightningElement,api,track,wire } from 'lwc';
import updateData from '@salesforce/apex/CashElementController.updateData';
import getData from '@salesforce/apex/CashElementController.getData';
import { getRecord } from 'lightning/uiRecordApi';
import getOffer from '@salesforce/apex/SpecialLeaseHandler.getOffer';
import getRecordTYPE from '@salesforce/apex/SpecialLeaseHandler.getRecordType';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CashElements extends NavigationMixin(LightningElement) {

@api recordId;
@track recId = this.recordId;
@track showSpinner = false;
@track isModalOpen = false;
@track dealer;
@track conquestCash;
@track captiveCash;
@track loyalityCash;
@track otherCaptiveCash;
@track additionalCash ;
@track showAddbtn = false;
@track status;
@track userProfileName;
@track offerRecordType;
@track showWarning = false;

handleClick(){
    console.log('inside handleClick');
    this.isModalOpen = true;
}
closeModal(){
    
    this.isModalOpen = false;
}

@wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
                console.log('profile name',this.userProfileName)
            }
        }
    }
    getRecordTYPE(){
        //console.log('currentrecordId=>'+this.recordId);
        getRecordTYPE({recordId: this.recordId})
        .then((result) => {
            console.log('recordType====>'+result);
            this.offerRecordType = result;
            this.getOffer();
        })
        .catch(error => {
            this.error = error;
          })
    }

handleDealerChange(event){
    this.dealer = event.target.value;
    console.log(this.dealer);
    if(this.dealer === undefined || this.dealer === null || this.dealer == ''){
        this.dealer = 0;
    }
}
handleConquestChange(event){
    this.conquestCash = event.target.value;
    if(this.conquestCash === undefined || this.conquestCash === null || this.conquestCash == ''){
        this.conquestCash = 0;
    }
}
handleCaptiveChange(event){
    this.captiveCash = event.target.value;
    if(this.captiveCash === undefined || this.captiveCash === null || this.captiveCash == ''){
        this.captiveCash = 0;
    }
}
handleLoyalityChange(event){
    this.loyalityCash = event.target.value;
    if(this.loyalityCash === undefined || this.loyalityCash === null || this.loyalityCash == ''){
        this.loyalityCash = 0;
    }
}
handleOtherChange(event){
    this.otherCaptiveCash = event.target.value;
    if(this.otherCaptiveCash === undefined || this.otherCaptiveCash === null || this.otherCaptiveCash == ''){
        this.otherCaptiveCash = 0;
    }
}
handleAdditionalChange(event){
    this.additionalCash = event.target.value;
    console.log('printing conquest cash',event.target.value);
    if(this.additionalCash === undefined || this.additionalCash === null || this.additionalCash == ''){
        this.additionalCash = 0;
    }
    console.log('after',this.additionalCash);
}
connectedCallback(){
    console.log('inside connected callback');
    this.getOfferData();
    this.getRecordTYPE();
}

applyAll(){
    updateData({
            recId:this.recordId, 
            dealer:this.dealer,
            conquest: this.conquestCash,
            captiveCash: this.captiveCash,
            loyality: this.loyalityCash,
            otherCaptive: this.otherCaptiveCash,
            additionalCash: this.additionalCash
        }).then(result=>{
            if(result === true){
                const evt = new ShowToastEvent({
            title: "Success",
            message: "Success",
            variant: "Success",
        });
            this.dispatchEvent(evt);
            }else{
                const evt = new ShowToastEvent({
            title: "Error",
            message: "Exception Occured",
            variant: "Error",
        });
        this.dispatchEvent(evt);
            }
            console.log('printing result',result);
        }).catch(error=>{
            console.log('this is from error'+error);
            console.log('this is from error'+JSON.stringify(error));

        });
        this.recId = this.recordId;
    this.isModalOpen = false;
    this.showWarning = true;
}
closeModalWarning(){
    this.showWarning = false;
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'Offers__c',
            actionName: 'view'
        },
    });
}
getOffer(){
    getOffer({recId : this.recordId})
    .then((result) => {
        if(result){
            this.status = result[0].Status__c;
            if((this.userProfileName ==='B2C_OM_AHM_AIG' && (this.status == 'WIP' || this.status == 'Validated') && (this.offerRecordType ==='New Special Finance' || this.offerRecordType ==='New Special Lease' || this.offerRecordType ==='New Special Program' || this.offerRecordType ==='New Standard Finance' || this.offerRecordType ==='New Standard Lease'))){
                this.showAddbtn = true;
            } else if(((this.userProfileName ==='B2C_OM_AHM_CPO') && (this.status == 'WIP' || this.status == 'Validated') && (this.offerRecordType ==='CPO Special Finance' || this.offerRecordType ==='CPO Special Lease' || this.offerRecordType ==='CPO Special Program' || this.offerRecordType ==='CPO Standard Finance' || this.offerRecordType ==='CPO Standard Lease'))){
                this.showAddbtn = true;
            }  else if((this.userProfileName ==='B2C_OM_PS' && (this.status == 'WIP' || this.status == 'Validated')  && (this.offerRecordType ==='Power Sports AHFC' || this.offerRecordType ==='Power Sports Bonus Bucks' || this.offerRecordType ==='Power Sports Generic' || this.offerRecordType ==='Power Sports Honda Card'))){
                this.showAddbtn = true;
            } else if (this.userProfileName ==='B2C_OM_ReadOnly' && (this.status == 'WIP' || this.status == 'Validated')){
                this.showAddbtn = false;
            } else if (this.userProfileName ==='System Administrator' && (this.status == 'WIP' || this.status == 'Validated')){
                this.showAddbtn = true;
            }
        this.getOEMList();
        }
    })
    .catch(error => {
      this.error = error;
    })
}

getOfferData(){
    getData({
            recId:this.recordId
        }).then(result=>{
            console.log('Printing results 1', result);
            if(result.length > 0){
                console.log('Printing results', result);
                this.dealer = result[0].Dealer_Contribution__c;
                this.conquestCash =result[0].Conquest_Cash__c;
                this.captiveCash = result[0].Captive_Cash__c;
                this.loyalityCash = result[0].Loyalty_Cash__c;
                this.otherCaptiveCash = result[0].Other_Captive_Cash__c;
                this.additionalCash = result[0].Additional_Cash__c;
            }
            
        }).catch(error=>{
            console.log('this is from error'+error);
            console.log('this is from error'+JSON.stringify(error));

        });
        this.recId = this.recordId;
    this.isModalOpen = false;
}
handleClearAll(){
    this.dealer = '';
                this.conquestCash =0;
                this.captiveCash = 0;
                this.loyalityCash = 0;
                this.otherCaptiveCash = 0;
                this.additionalCash =0;
                this.applyAll();
}
}
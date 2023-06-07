import { LightningElement, track } from 'lwc';
import getMyAccounts from '@salesforce/apex/AccountController.fetchAllAccounts';
import updateAccountData from '@salesforce/apex/AccountController.updateAccountData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchStoreId from '@salesforce/apex/AccountController.fetchStoreId';
import getProduct from '@salesforce/apex/AccountController.getProduct';
import communityId from '@salesforce/community/Id';
export default class MyAccounts extends LightningElement {
    //@track accountsList = [];
    @track isFetchData = false;
    @track accountType;
    @track accRecordId;
    @track storeId;
    @track pName;
    connectedCallback() {
        this.getAllMyAccounts();  
        this.getStoreId(); 
        this.getProductDetail();
    }
    getProductDetail(){
        getProduct()
        .then(result=>{
           this.pName=result;
        })


    }

    getAllMyAccounts() {
        getMyAccounts()
            .then(result => {
                if (result) {
                    console.log('inside if');
                        this.accountType = result.State__c;
                        this.accRecordId = result.Id;
                        console.log('result',JSON.stringify(this.accountType));
                        console.log('this.accRecordId',this.accRecordId);

                }
            })
            .catch(error => {
                console.error(error);
            })
            .finally(() => {
                this.isFetchData = true;
            })
    }

    nameChange(event){
        this.accountType = event.target.value;
        console.log('value:'+this.accountType);
    }
    updateAccountData(event){
        console.log('recid',this.accRecordId);
        console.log('name',this.accountType);
        updateAccountData({ 
            recordId : this.accRecordId,
            state : this.accountType
        })
        .then(result => {
            console.log('in then');
            this.dispatchEvent(new ShowToastEvent({
                message: 'acc updated sucessfully',
                variant: 'success'
            }));
        })
    } 
    getStoreId(){
        fetchStoreId({communityId: communityId})
        .then(result=>{
            this.storeId= result;
        })

    }
}
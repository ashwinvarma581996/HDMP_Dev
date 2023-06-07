import { LightningElement ,wire,api,track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getOEMList from '@salesforce/apex/SpecialLeaseHandler.getOEMList';
import getRecordTYPE from '@salesforce/apex/SpecialLeaseHandler.getRecordType';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import getOffer from '@salesforce/apex/SpecialLeaseHandler.getOffer';
import sortUp from '@salesforce/apex/SpecialLeaseHandler.sortUp';
import sortDown from '@salesforce/apex/SpecialLeaseHandler.sortDown';
import deleteRow from '@salesforce/apex/SpecialLeaseHandler.deleteRow';
import Id from '@salesforce/user/Id';
// datatable columns with row actions
const columns = [
    { label: 'Sort', fieldName: 'Sort_Order__c' }, 
    { label: 'Year', fieldName: 'Year__c' }, 
    { label: 'Model', fieldName: 'NameUrl', type:'url', wrapText: true,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Trim', fieldName: 'Trim__c',wrapText: true,initialWidth: 190}, 
    { label: 'Model ID', fieldName: 'Model_ID__c',initialWidth: 100 },
    { label: 'Dealer Contribution', fieldName: 'Dealer_Contribution__c',wrapText: true,cellAttributes: { alignment: 'center' } },  
    { label: 'Featured', fieldName: 'Featured_Offer__c', type:'boolean',cellAttributes: { alignment: 'center' } }, 
    { label: 'Include Sample Payment', fieldName: 'Include_Sample_Payment__c', type:'boolean', cellAttributes: { alignment: 'center' } }, 
    {
        label: 'Review Calculation',
        type: 'button-icon',
        initialWidth: 75,
        typeAttributes: {
            iconName: { fieldName: 'calcIcon' }, 
            variant: 'bare',
            iconClass: 'slds-button_icon-warning',
            title:'Please review this record'
            
            
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {
            iconName: 'utility:delete',
            name: 'delete',
            iconClass: 'slds-icon-text-error'
           
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:edit',
            name: 'edit'
        },
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowup',
            name: 'arrowup'
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowdown',
            name: 'arrowdown'
        }
    }
];
const columnsWithoutLease = [
    { label: 'Sort', fieldName: 'Sort_Order__c' }, 
    { label: 'Year', fieldName: 'Year__c' }, 
    { label: 'Model', fieldName: 'NameUrl', type:'url', wrapText: true,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Trim', fieldName: 'Trim__c',wrapText: true,initialWidth: 190}, 
    { label: 'Model ID', fieldName: 'Model_ID__c',initialWidth: 100 },
    { label: 'Featured', fieldName: 'Featured_Offer__c', type:'boolean',cellAttributes: { alignment: 'center' } }, 
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {
            iconName: 'utility:delete',
            name: 'delete',
            iconClass: 'slds-icon-text-error'
           
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:edit',
            name: 'edit'
        },
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowup',
            name: 'arrowup'
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowdown',
            name: 'arrowdown'
        }
    }
];
const columnsPrism = [
    { label: 'Sort', fieldName: 'Sort_Order__c' }, 
    { label: 'Year', fieldName: 'Year__c' }, 
    { label: 'Model', fieldName: 'NameUrl', type:'url', wrapText: true,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Trim', fieldName: 'Trim__c',wrapText: true,initialWidth: 190}, 
    { label: 'Model ID', fieldName: 'Model_ID__c',initialWidth: 100 },
    { label: 'Dealer Contribution', fieldName: 'Dealer_Contribution__c',wrapText: true,cellAttributes: { alignment: 'center' } },  
    { label: 'Featured', fieldName: 'Featured_Offer__c', type:'boolean',cellAttributes: { alignment: 'center' } }, 
    { label: 'Include Sample Payment', fieldName: 'Include_Sample_Payment__c', type:'boolean', cellAttributes: { alignment: 'center' } }, 
    {
        label: 'Review Calculation',
        type: 'button-icon',
        initialWidth: 75,
        typeAttributes: {
            iconName: { fieldName: 'calcIcon' }, 
            variant: 'bare',
            iconClass: 'slds-button_icon-warning',
            title:'Please review this record'
            
            
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:edit',
            name: 'edit'
        },
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowup',
            name: 'arrowup'
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowdown',
            name: 'arrowdown'
        }
    }
    
];
const columnsPrismWithoutLease = [
    { label: 'Sort', fieldName: 'Sort_Order__c' }, 
    { label: 'Year', fieldName: 'Year__c' }, 
    { label: 'Model', fieldName: 'NameUrl', type:'url', wrapText: true,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Trim', fieldName: 'Trim__c',wrapText: true,initialWidth: 190}, 
    { label: 'Model ID', fieldName: 'Model_ID__c',initialWidth: 100 },
    { label: 'Featured', fieldName: 'Featured_Offer__c', type:'boolean',cellAttributes: { alignment: 'center' } }, 
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:edit',
            name: 'edit'
        },
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowup',
            name: 'arrowup'
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowdown',
            name: 'arrowdown'
        }
    }
    
];

const columnsWithNoActions = [
    { label: 'Sort', fieldName: 'Sort_Order__c' }, 
    { label: 'Year', fieldName: 'Year__c' }, 
    { label: 'Model', fieldName: 'NameUrl', type:'url', wrapText: true,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Trim', fieldName: 'Trim__c',wrapText: true,initialWidth: 190}, 
    { label: 'Model ID', fieldName: 'Model_ID__c',initialWidth: 100 },
    { label: 'Dealer Contribution', fieldName: 'Dealer_Contribution__c',wrapText: true,cellAttributes: { alignment: 'center' } },  
    { label: 'Featured', fieldName: 'Featured_Offer__c', type:'boolean',cellAttributes: { alignment: 'center' } }, 
    { label: 'Include Sample Payment', fieldName: 'Include_Sample_Payment__c', type:'boolean', cellAttributes: { alignment: 'center' } } 
];
const columnsWithNoActionsWithoutLease = [
    { label: 'Sort', fieldName: 'Sort_Order__c' }, 
    { label: 'Year', fieldName: 'Year__c' }, 
    { label: 'Model', fieldName: 'NameUrl', type:'url', wrapText: true,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Trim', fieldName: 'Trim__c',wrapText: true,initialWidth: 190}, 
    { label: 'Model ID', fieldName: 'Model_ID__c',initialWidth: 100 },
    { label: 'Featured', fieldName: 'Featured_Offer__c', type:'boolean',cellAttributes: { alignment: 'center' } } 
];

const column = [
    { label: 'Sort', fieldName: 'Sort_Order__c' }, 
    { label: 'Year', fieldName: 'Year__c' },
    { label: 'Segment', fieldName: 'Segment__c' }, 
    { label: 'Model ID', fieldName: 'Model_ID__c',initialWidth:100},
    { label: 'Model', fieldName: 'NameUrl', type:'url', wrapText: true,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Featured', fieldName: 'Featured_Offer__c', type:'boolean',cellAttributes: { alignment: 'center' } }, 
    { label: 'MSRP', fieldName: 'MSRP__c',wrapText: true,cellAttributes: { alignment: 'center' } },
    { label: 'Freight Charge', fieldName: 'Freight_Charge__c',cellAttributes: { alignment: 'center' } }, 
    
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {
            iconName: 'utility:delete',
            name: 'delete',
            iconClass: 'slds-icon-text-error'
           
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:edit',
            name: 'edit'
        },
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowup',
            name: 'arrowup'
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowdown',
            name: 'arrowdown'
        }
    }
];

const columnPrism = [
    { label: 'Sort', fieldName: 'Sort_Order__c' }, 
    { label: 'Year', fieldName: 'Year__c' },
    { label: 'Segment', fieldName: 'Segment__c' }, 
    { label: 'Model ID', fieldName: 'Model_ID__c',initialWidth:100},
    { label: 'Model', fieldName: 'NameUrl', type:'url', wrapText: true,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Featured', fieldName: 'Featured_Offer__c', type:'boolean',cellAttributes: { alignment: 'center' } }, 
    { label: 'MSRP', fieldName: 'MSRP__c',wrapText: true,cellAttributes: { alignment: 'center' } },
    { label: 'Freight Charge', fieldName: 'Freight_Charge__c',cellAttributes: { alignment: 'center' } }, 
    
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:edit',
            name: 'edit'
        },
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowup',
            name: 'arrowup'
        }
    },
    {
        type: 'button-icon',
        initialWidth: 20,
        typeAttributes:
        {  
            iconName: 'utility:arrowdown',
            name: 'arrowdown'
        }
    }
    
];
const columnWithNoAction = [
    { label: 'Sort', fieldName: 'Sort_Order__c' }, 
    { label: 'Year', fieldName: 'Year__c' },
    { label: 'Segment', fieldName: 'Segment__c' }, 
    { label: 'Model ID', fieldName: 'Model_ID__c',initialWidth:100},
    { label: 'Model', fieldName: 'NameUrl', type:'url', wrapText: true,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Featured', fieldName: 'Featured_Offer__c', type:'boolean',cellAttributes: { alignment: 'center' } }, 
    { label: 'MSRP', fieldName: 'MSRP__c',wrapText: true,cellAttributes: { alignment: 'center' } },
    { label: 'Freight Charge', fieldName: 'Freight_Charge__c',cellAttributes: { alignment: 'center' } } 
    
];



export default class OfferModelList extends LightningElement {
    @api recordId;
    @track status;
    @track showAddbtn = false;
    @track data = [];
    @track columns = columns;
    @track showAddModelComponent = false;
    @track OEMId;
    @track ShowMgs = false;
    @track isNOTPowerSports = false;
    @track rowId;
    @track shortNum;
    @track href;
    @track showDelete = false;
    @track column = column;
    @track showSpinner = true;
    @track columnWithNoAction = columnWithNoAction;
    @track columnsWithNoActions = columnsWithNoActions;
    @track isPrism = false;
    @track columnPrism = columnPrism;
    @track columnsPrism = columnsPrism;
    @track columnsWithoutLease = columnsWithoutLease;
    @track columnsPrismWithoutLease = columnsPrismWithoutLease;
    @track columnsWithNoActionsWithoutLease = columnsWithNoActionsWithoutLease;
    @track offerRecordType;
    @track userId = Id;
   @track userProfileName;
   @track leaseIdentifier;
   @track showBack = false;
   @track isLease = false;

  /*  @wire(getRecord, { recordId: "$recordId", fields : [ status] })
    wiredModel({ data, error }) {
        if (data) {
            this.status = data.fields.Status__c.value;
            console.log(' this.status=>'+ this.status);
            if(this.status == 'WIP' || this.status == 'Validated' ){
                this.showAddbtn = true;
            }
            this.getOEMList();
        }
    }        */

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

    connectedCallback(){
        
        this.getRecordTYPE();
        var loc = window.location.href;
        console.log('url', window.location.href);
        this.href = loc.substring(0,loc.lastIndexOf('/r/') + 3);
        this.href = this.href + 'Offer_Eligible_Models__c/';
        console.log('url1', this.href);
    }


    getRecordTYPE(){
        //console.log('currentrecordId=>'+this.recordId);
        getRecordTYPE({recordId: this.recordId})
        .then((result) => {
            console.log('recordType====>'+result);
            this.offerRecordType = result;
            if(result == 'CPO Special Finance' || result == 'CPO Special Program' || result == 'CPO Special Lease' || result == 'CPO Standard Lease'
            || result == 'CPO Standard Finance' || result == 'New Standard Lease' || result == 'New Special Lease' || result == 'New Special Finance' || result == 'New Special Program' || result == 'New Standard Finance'){
                this.isNOTPowerSports = true;
            }else{
                this.isNOTPowerSports = false;
            }
            if(result == 'CPO Special Lease' || result == 'CPO Standard Lease' || result == 'New Standard Lease' || result == 'New Special Lease'){
                this.isLease = true;
            }else{
                this.isLease = false;
            }
            this.getOffer();
            console.log('getRecordTYPE==>'+this.isNOTPowerSports);
        })
        .catch(error => {
            this.error = error;
          })
    }

    getOEMList(){
        console.log('offerID==>'+this.recordId);
        getOEMList({offerId : this.recordId})
        .then((result) => {
            console.log('result==>'+result);
         this.data = result;
         this.showSpinner = false;
         for(let i =0; i< this.data.length; i++){
             this.data[i].NameUrl = this.href + this.data[i].Id +'/view';
             //populate calculate warning sign
             if(this.data[i].Is_Calculation_Done__c && this.data[i].Include_Sample_Payment__c)
             {
                this.data[i].calcIcon = '';
             }
             else if(this.data[i].Include_Sample_Payment__c)
             {
                this.data[i].calcIcon = 'utility:warning';
             }
             else
             {
                this.data[i].calcIcon = '';
             }


         }
         this.updateRecordView();
         console.log('result==>'+result.length); 
            if(result.length == 0){
                this.ShowMgs = true;
                this.showSpinner = false;
            }
        })
        .catch(error => {
          this.data = error;
        })
    }
    // getoffer
    getOffer(){
        getOffer({recId : this.recordId})
        .then((result) => {
            if(result){
                console.log('get offer result',result);
                this.status = result[0].Status__c;
                this.leaseIdentifier = result[0].Lease_Title_Ident__c;
                
            if((this.userProfileName ==='B2C_OM_AHM_AIG' && (this.status == 'WIP' || this.status == 'Validated') && (this.offerRecordType ==='New Special Finance' || this.offerRecordType ==='New Special Lease' || this.offerRecordType ==='New Special Program' || this.offerRecordType ==='New Standard Finance' || this.offerRecordType ==='New Standard Lease'))){
                this.showAddbtn = true;
            } else if(((this.userProfileName ==='B2C_OM_AHM_CPO') && (this.status == 'WIP' || this.status == 'Validated') && (this.offerRecordType ==='CPO Special Finance' || this.offerRecordType ==='CPO Special Lease' || this.offerRecordType ==='CPO Special Program' || this.offerRecordType ==='CPO Standard Finance' || this.offerRecordType ==='CPO Standard Lease'))){
                this.showAddbtn = true;
            }  else if((this.userProfileName ==='B2C_OM_PS' && (this.status == 'WIP' || this.status == 'Validated')  && (this.offerRecordType ==='Power Sports AHFC' || this.offerRecordType ==='Power Sports Bonus Bucks' || this.offerRecordType ==='Power Sports Generic' || this.offerRecordType ==='Power Sports Honda Card'))){
                this.showAddbtn = true;
            } else if (this.userProfileName ==='B2C_OM_ReadOnly' && (this.status == 'WIP' || this.status == 'Validated')){
                this.showAddbtn = false;
            } else if ((this.userProfileName ==='System Administrator' || this.userProfileName === 'B2C_OM_Admin') && (this.status == 'WIP' || this.status == 'Validated')){
                this.showAddbtn = true;
            }
            if(this.showAddbtn === true){
                
                this.isPrism = result[0].Synched_with_PRISM__c;
                if(this.isPrism === true){
                    this.showAddbtn = false;
                }/*else if(result[0].National_Offer__r.Synched_with_PRISM__c != null && result[0].National_Offer__r.Synched_with_PRISM__c != undefined && result[0].National_Offer__r.Synched_with_PRISM__c === true){
                    this.showAddbtn = false;
                } */
                else{
                    this.isPrism = false;
                }
            }
            console.log('showButton',this.showAddbtn);

            this.getOEMList();
            }
        })
        .catch(error => {
          this.error = error;
        })
    }
    // delete
    deleteRow(){
        deleteRow({recId : this.rowId, sortNum : this.shortNum, offerId:this.recordId})
        .then((result) => {
            console.log('printing delete',result);

            if(result === true){
                this.getOEMList();
            } else{
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Could not delete the model",
                      message: "We are unable to delete the model at this time. Please get in touch with your system administrator",
                      variant: "error"
                    })
                  );
            }
        })
        .catch(error => {
            this.showSpinner = false;
          this.error = error;
        })
    }
    //getdata
    sortUp(){
        sortUp({recId : this.recordId , sortNum: this.shortNum})
        .then((result) => {
            console.log('result==>'+result);
            if(result === true){
                this.getOEMList();
            } else{
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Error Occured",
                      message: "Something went wrong.",
                      variant: "error"
                    })
                  );
            }
        })
        .catch(error => {
          this.error = error;
        })
    }

    sortDown(){
        sortDown({recId : this.recordId , sortNum: this.shortNum})
        .then((result) => {
            console.log('result==>'+result);
            if(result === true){
                this.getOEMList();
            } else{
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Error Occured",
                      message: "Something went wrong.",
                      variant: "error"
                    })
                  );
            }
        })
        .catch(error => {
          this.error = error;
        })
    }

     updateRecordView() {
       setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
       }, 1000); 
    }

    handleShowBack(event){
        this.showBack = event.detail.value;

    }

    handleRowActions(event) {
        if (event.detail.action.name === 'delete') {
            console.log('Object==>'+JSON.stringify(event.detail));
           // console.log('delete action clicked==>'+event.detail.row.Sort_Order__c);
           this.shortNum = event.detail.row.Sort_Order__c;
            this.rowId = event.detail.row.Id;
            if(this.showAddbtn === true){
            this.showDelete = true;
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Could not delete the model",
                      message: "The models can only be deleted from offers in WIP or Validated Status.",
                      variant: "error"
                    })
                  );
            }
        }
        if (event.detail.action.name === 'edit') {
           
            this.OEMId = event.detail.row.Id;
                this.showAddModelComponent = true;
            
            
            console.log('edit action clicked==>'+ this.OEMId);
        }
        if (event.detail.action.name === 'arrowup') {
                //this.sortUp(event.detail.row.Id,event.detail.row.Sort_Order__c);
                this.showSpinner = true;
                this.shortNum = event.detail.row.Sort_Order__c;
                this.sortUp();
                
        }

        if (event.detail.action.name === 'arrowdown') {
                //this.sortUp(event.detail.row.Id,event.detail.row.Sort_Order__c);
                this.showSpinner = true;
                this.shortNum = event.detail.row.Sort_Order__c;
                this.sortDown();
        }

        
    }

    addModel(event){
        this.OEMId = '';
        this.showAddModelComponent = true;
        console.log('Add modal clicked');
    }

    handleCancel(){
        this.showAddModelComponent = false;
        this.showDelete = false;
    }
    handleBack(){
        this.template.querySelector('c-offer-model-details').onBack();
        this.showBack = false;

    }

    handleSave(){
        this.template.querySelector('c-offer-model-details').onSave();
    }
    handleDelete(){
        this.showSpinner = true;
        this.deleteRow();
        this.showDelete = false;
    }
    handleCancelDelete(){
        this.showDelete = false;
    }
    printWindow(){
        //this.printPage('noprintSection');
    }

    
    


   
}
import { LightningElement, api,wire, track } from 'lwc';

import getoffer from '@salesforce/apex/CloneOfferRelatedObjectHelper.getOfferRecord';
import offerclone from '@salesforce/apex/CloneOfferRelatedObjectHelper.offerclone';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class Regionaloffer extends NavigationMixin (LightningElement) {
    mycustom;
    @api recordId;
    @api objectApiName;
    _recordId;
    @api offer;;
    stopRender =true;
    program;
    descrptive;
    mycustomres;
    connectedCallback(){
        if(this.stopRender==true){
        
        }
        window.clearTimeout(this.delayTimeout);

        this.delayTimeout =setTimeout(() => {
          
          this.handleapexmethod( this.recordId);
        },10)
        this.stopRender =false;
    }
    handleapexmethod(offerid){
        getoffer({offerid :this.recordId})
            .then(result =>{
                this.offer = result;
                this.descrptive =result.offerdescriptive;
                this.program = result.Programname;
                
            })
            .catch(error=>{
                console.log('this is error'+JSON.stringify(error));
            })
    }
    handlechangeprogram(event){
       this.program = event.target.value;
    }
    handlechangedescriptive(event){
        this.descrptive = event.target.value;
    }
    
    handlesaveoffer(){
        offerclone({
            offerid:this.recordId,
            program:this.program ,
            descriptivename:this.descrptive
        }).then(result=>{
           console.log('save offer'+JSON.stringify(result));
           this.handleSuccess();
           this.handleNavigate(result);
            
        }).catch(error=>{
            console.log('+++++++++++++'+JSON.stringify(error));
            var message = JSON.stringify(error);
             if(message.includes("Already we have offer")){
                 const evt = new ShowToastEvent({
                    title: 'Toast Error',
                    message: 'Already we have offer header Record,Please change Program Name',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt)
             }

            
        })
      
    }
    handleSuccess() {
        // Close the modal window and display a success toast
       // this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Record Created!',
                variant: 'success'
            })
        );
   }
   handleCancel(event) {
    // Add your cancel button implementation here
    this.dispatchEvent(new CloseActionScreenEvent());
 }
 handleNavigate(record) {
     console.log('this end of page'+record);
    const config = {
      type: "standard__recordPage",
      attributes: {
        recordId: record,
        objectApiName: "Offers__c",
        actionName: "view"
      }
    };
    this[NavigationMixin.Navigate](config);
  }
//   reduceErrors(errors) {
//     if (!Array.isArray(errors)) {
//         errors = [errors];
//     }
//     return (
//         errors
//             // Remove null/undefined items
//             .filter((error) => !!error)
//             // Extract an error message
//             .map((error) => {
//                 // UI API read errors
//                 if (error.body.duplicateResults && error.body.duplicateResults.length > 0) {
//                     return error.body.duplicateResults.map((e) => e.message);
//                 }

//                 else if (error.body.fieldErrors && error.body.fieldErrors.length > 0 && Array.isArray(error.body.fieldErrors)) {
//                     return error.body.fieldErrors.map((e) => e.message);
//                 }

//                 else if (error.body.pageErrors && error.body.pageErrors.length > 0 && Array.isArray(error.body.pageErrors)) {
//                     return error.body.pageErrors.map((e) => e.message);
//                 }

//                 else if (Array.isArray(error.body)) {
//                     return error.body.map((e) => e.message);
//                 }
//                 // UI API DML, Apex and network errors
//                 else if (error.body && typeof error.body.message === 'string') {
//                     return error.body.message;
//                 }
//                 // JS errors
//                 else if (typeof error.message === 'string') {
//                     return error.message;
//                 }
//                 // Unknown error shape so try HTTP status text
//                 return error.statusText;
//             })
//             // Flatten
//             .reduce((prev, curr) => prev.concat(curr), [])
//             // Remove empty strings
//             .filter((message) => !!message)
//     );
//   }
  
}
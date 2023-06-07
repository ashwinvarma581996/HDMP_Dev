import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createNew from '@salesforce/apex/BoilerPlateNewEdit.createNew';
export default class BoilerplateNewEdit extends LightningElement {


@api recid;
@api brandvalue;
@api offtypevalue;
isModalOpen=true;
@api showvariables=false;
@track offerRectype = 'Offer Record Type';
formData = {};
@track hidePowerSportsFields = false;
@track name ='';
@track brand = '';
@track data = [];

closeModal() {
    console.log('***Clicked Edit Close');
    this.isModalOpen=false;
    window.history.back();
}

handleCancel(){
console.log('***Clicked Edit Close');
this.isModalOpen=false;
window.history.back();
}

handleSave(){
    createNew({
        recId:this.recid
        }).then(result=>{
            console.log('Printing results 1', result);
            window.location= '/lightning/r/Boilerplate__c/'+this.recid+'/view';
            
        }).catch(error=>{
            console.log('this is from error'+error);
            console.log('this is from error'+JSON.stringify(error));

        });
}


handlelistofvariable(){
this.showvariables=true;
setTimeout(() => {
console.log('***Clicked list of variables');
console.log('',this.brandvalue);
console.log('',this.offtypevalue);
if(this.brandvalue && this.offtypevalue){
this.showvariables=true;
const objChild = this.template.querySelector('c-show-variable-name').boilerplateModal();
console.log('this is from boilerplatenewedit'); 
}
else{
const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Please provide Brand and Offer Type value',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
}
    }, 0);

}

setbrand(event){
const selectedbrand = event.target.value;
this.brandvalue=selectedbrand;
console.log('Selected Brand:', selectedbrand);
}

setofftyp(event){
const selectedofftype = event.target.value;
this.offtypevalue=selectedofftype;
if(this.offtypevalue.includes('Power')){
    this.hidePowerSportsFields = true;
} else {
    this.hidePowerSportsFields = false;
}
console.log('Selected Offtype:', selectedofftype);
console.log(' this.hidePowerSportsFields',  this.hidePowerSportsFields);
}

handleChangeOnEditOfferType (event){
    const selectedofftype = event.target.value;
    this.offtypevalue=selectedofftype;
    if(this.offtypevalue.includes('Power')){
        this.hidePowerSportsFields = true;
    } else {
        this.hidePowerSportsFields = false;
    }
    console.log('Selected Offtype:', selectedofftype);
    console.log(' this.hidePowerSportsFields',  this.hidePowerSportsFields);
    }

get isNew(){
if(this.recid)
return false;
else
return true;
}

handleSuccess(event) {
console.log('Event success',event.detail.id);
window.location= '/lightning/r/Boilerplate__c/'+event.detail.id+'/view';
}

handleLoad(event) {
console.log('Clicked on Edit');
event.preventDefault();
const fieldKey1 = event.target.querySelector('[data-key="field1"]');
const fieldKey2 = event.target.querySelector('[data-key="field2"]');
console.log('Field key: ', fieldKey1);
console.log('Field Val: ', fieldKey1.value);
console.log('Field Val: ', fieldKey2.value);
this.brandvalue=fieldKey1.value;
this.offtypevalue=fieldKey2.value;
if(this.offtypevalue.includes('Power')){
    this.hidePowerSportsFields = true;
} else {
    this.hidePowerSportsFields = false;
}
console.log('this.hidePowerSportsFields for edit ',this.hidePowerSportsFields);
}


handleSuccess1(event){
    console.log('Event success',event.detail.id);
    if(this.hidePowerSportsFields === false){
        window.location= '/lightning/r/Boilerplate__c/'+event.detail.id+'/view'
    }else{
    this.handleSave();
    }



}


}
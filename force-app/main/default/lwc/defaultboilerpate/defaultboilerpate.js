import { LightningElement,api,track,wire } from 'lwc';
import getdetails from '@salesforce/apex/BoilerplateDetails.getBoilerPlateDetails'
import getofferdetails from '@salesforce/apex/BoilerplateDetails.getOffBolderdetails'
import saveOffer from '@salesforce/apex/BoilerplateDetails.saveOffer'
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import { NavigationMixin } from 'lightning/navigation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Offers__c from '@salesforce/schema/Offers__c';
//import RECORDTYPEID from '@salesforce/schema/Offers__c.RecordTypeId';
//const _FIELDS = [RECORDTYPEID];
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';



export default class Defaultboilerpate extends NavigationMixin(LightningElement) {
    @api boilerplateid;//='a1d3J0000006txsQAA';
    @api offerid;
    offerTitle ='';
    shortDescription = '';
    detailedDescription ='';
    termsAndConditions ='';
    legalDesclaimer ='';
    selectedRecordId; //store the record id of the selected 
    myresult;
    areDetailsVisible;
    offrecordTypeName;// to store recordtype of offer
    hidePowerSportsFields=false;
    @track showSpinner = false;




      

    handleValueSelcted(event) {
        if(event.detail.value === ''){
            this.selectedRecordId = '';
            this.boilerplateid = '';
        } else{
       this.selectedRecordId = event.detail.value;
       getdetails({
        boilerplateid:String(this.selectedRecordId),
        offerId:String(this.offerid)
    }).then(result=>{
        this.myresult = JSON.stringify(result);
        this.areDetailsVisible= true;
        this.boilerplateid = result.boilerplateid;

        this.offerTitle = this.decodeHtmlEntities(result.offerTitle);

        this.shortDescription = this.decodeHtmlEntities(result.shortDescription);

        this.detailedDescription= this.decodeHtmlEntities(result.detailedDescription);

        this.termsAndConditions= this.decodeHtmlEntities(result.termsAndConditions);
        
        this.legalDesclaimer = this.decodeHtmlEntities(result.legalDesclaimer);
        
    }).catch(error=>{
        console.log('this is from error'+JSON.stringify(error));

    });
}


    // Calling this method onselect on look up fields
    /*setTimeout(() => {
        console.log('hello world');
        this.handlesaveoffer();
    }, 1000);*/
      
      console.log('this is calling from boilerplate');
    }

    decodeHtmlEntities(inputStr) {
        const htmlEntitiesMap = {
          '&lt;': '<',
          '&gt;': '>',
          '&amp;': '&',
          '&quot;': '"',
          '&#039;': "'",
        };
        if(inputStr === null || inputStr === '' || inputStr === undefined){
            return inputStr;
        }
        return inputStr.replace(/&[a-zA-Z0-9#]+;/g, (match) => {
          return htmlEntitiesMap[match] || match;
        });
      }


    connectedCallback(){
        this.show_page = true;
        getofferdetails({
            offerid:this.offerid
        }).then(result=>{
            console.log("inside conmected callback");
            console.log("Printing boilerplate details",result);
           this.areDetailsVisible= true;
           this.myresult = JSON.stringify(result);
           this.areDetailsVisible= true;
           console.log('========='+this.myresult);
           this.boilerplateid = result.boilerplateid;
           this.offerTitle =this.decodeHtmlEntities(result.offerTitle);
           this.shortDescription = this.decodeHtmlEntities(result.shortDescription);
           this.detailedDescription= this.decodeHtmlEntities(result.detailedDescription);
           this.termsAndConditions= this.decodeHtmlEntities(result.termsAndConditions);
           this.legalDesclaimer = this.decodeHtmlEntities(result.legalDesclaimer);
           this.offrecordTypeName=result.recordtypeName;
            //Check and set an identifier for PowerSports RT
            if(this.offrecordTypeName.includes('Power')){
                this.hidePowerSportsFields = true;
            }else {
                this.hidePowerSportsFields = false;
            }

           console.log('Result'+result);
        }).catch(error=>{

        });
    }
 @api handlereset(){
    this.areDetailsVisible= false;
   
    getofferdetails({
        offerid:this.offerid
    }).then(result=>{
       this.areDetailsVisible= true;
       this.myresult = JSON.stringify(result);
       this.areDetailsVisible= true;
       this.boilerplateid = result.boilerplateid;
       this.offerTitle =this.decodeHtmlEntities(result.offerTitle);
       this.shortDescription = this.decodeHtmlEntities(result.shortDescription);
       this.detailedDescription= this.decodeHtmlEntities(result.detailedDescription);
       this.termsAndConditions= this.decodeHtmlEntities(result.termsAndConditions);
       this.legalDesclaimer = this.decodeHtmlEntities(result.legalDesclaimer);
    }).catch(error=>{

    });

 }
 @api handlesaveoffer(event){
    // if(this.offerid != '' && this.offerid != null && this.offerid != undefined && this.boilerplateid != '' && this.boilerplateid != null && this.boilerplateid != undefined && this.shortDescription != '' && this.shortDescription != null && this.shortDescription != undefined && this.offerTitle != '' && this.offerTitle != null && this.offerTitle != undefined && this.detailedDescription != null && this.detailedDescription != '' && this.detailedDescription != undefined && this.termsAndConditions != '' && this.termsAndConditions != null && this.termsAndConditions != undefined && this.legalDesclaimer != '' && this.legalDesclaimer != null && this.legalDesclaimer != undefined && this.hidePowerSportsFields==false){
        if(this.offerid != '' && this.offerid != null && this.offerid != undefined && this.boilerplateid != '' && this.boilerplateid != null && this.boilerplateid != undefined  && this.offerTitle != '' && this.offerTitle != null && this.offerTitle != undefined  && this.legalDesclaimer != '' && this.legalDesclaimer != null && this.legalDesclaimer != undefined && this.hidePowerSportsFields==false){

     this.showSpinner = true;
    
        saveOffer({
            offerid:this.offerid,
            boidlerid:this.boilerplateid,
            offertitle:this.offerTitle,
            shortdescription:this.shortDescription,
            detaildec:this.detailedDescription,
            term:this.termsAndConditions,
            legal:this.legalDesclaimer
         }).then(result=>{
           console.log('offer record has been updated sucessfully!');
           console.log('this.boilerplateid'+this.boilerplateid+'offer id'+this.offerid);
           this.showSpinner = false;

           this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.offerid,
                objectApiName: 'Offers__c',
                actionName: 'view'
            },
        });

        
         }).catch(error=>{
           // console.log(JSON.String(erorr));
           this.showSpinner = false;
           console.log('errors form save '+error);
           //window.location.reload(true);
         })
        } 
        
    // else if(this.offerid != '' && this.offerid != null && this.offerid != undefined && this.boilerplateid != '' && this.boilerplateid != null && this.boilerplateid != undefined && this.offerTitle != '' && this.offerTitle != null && this.offerTitle != undefined && this.termsAndConditions != '' && this.termsAndConditions != null && this.termsAndConditions != undefined && this.hidePowerSportsFields == true){
        else if(this.offerid != '' && this.offerid != null && this.offerid != undefined && this.boilerplateid != '' && this.boilerplateid != null && this.boilerplateid != undefined && this.offerTitle != '' && this.offerTitle != null && this.offerTitle != undefined && this.hidePowerSportsFields == true){

        this.showSpinner = true;
        saveOffer({
            offerid:this.offerid,
            boidlerid:this.boilerplateid,
            offertitle:this.offerTitle,
            shortdescription:this.shortDescription,
            detaildec:this.detailedDescription,
            term:this.termsAndConditions,
            legal:this.legalDesclaimer
         }).then(result=>{
           console.log('offer record has been updated sucessfully!');
           console.log('this.boilerplateid'+this.boilerplateid+'offer id'+this.offerid);
           this.showSpinner = false;
           this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.offerid,
                objectApiName: 'Offers__c',
                actionName: 'view'
            },
        });

        
         }).catch(erorr=>{
           // console.log(JSON.String(erorr));
           this.showSpinner = false;
           console.log('errors form save '+erorr);
           //window.location.reload(true);
         })
    }    
        
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "Error",
                  message: `Required Field Missing`,
                  variant: "error"
                })
              );
        }
    
}
 
 @api handlemodelbox(){
    const objChild = this.template.querySelector('c-show-variable-name').showModalBox();
    console.log('this is from defalut boiler plate');
}
handlechangoffertitle(event){
    this.offerTitle = event.target.value;
    this.offerTitle=this.decodeHtmlEntities(this.offerTitle);
 }
 handlechangeshortdescription(event){
     this.shortDescription = event.target.value;
     if(this.shortDescription != '' && this.shortDescription != null && this.shortDescription != undefined){
     this.shortDescription = this.decodeHtmlEntities(this.shortDescription);
     }
 }
 handlechangedetailedDescription(event){
    this.detailedDescription = event.target.value;
    this.detailedDescription =this.decodeHtmlEntities(this.detailedDescription);
}
handlechangetermsAndConditions(event){
    this.termsAndConditions = event.target.value;
    this.termsAndConditions=this.decodeHtmlEntities(this.termsAndConditions);
}
handlechangelegalDesclaimer(event){
    this.legalDesclaimer = event.target.value;
    this.legalDesclaimer = this.decodeHtmlEntities(this.legalDesclaimer)
}
}
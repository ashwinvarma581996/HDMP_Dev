import { LightningElement, api, track,wire} from 'lwc';
import getdetails from '@salesforce/apex/BoilerplateDetails.getofferdetails'
import getboilerdetails from '@salesforce/apex/BoilerplateDetails.getBoilerPlateDetails'
import NAME_FIELD from '@salesforce/schema/Offers__c.Boilerplate__c';
import TILTLE from '@salesforce/schema/Offers__c.Offer_Title__c';
import DESCRIPTION from '@salesforce/schema/Offers__c.Short_Description__c';
import DETAIL_DESCRIPTION from '@salesforce/schema/Offers__c.Detailed_Description__c';
import TERM_CONDITION from '@salesforce/schema/Offers__c.Terms_and_Conditions__c';
import LEAGALDEC from '@salesforce/schema/Offers__c.Legal_Desclaimer__c';
import { getRecord } from 'lightning/uiRecordApi';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';

export default class Defaulboilerplatereadonly extends LightningElement {

   @api recordId;
   @track results;
   stopRender;
   boilerplateid;
   offerTitle;
   shortDescription;
   detailedDescription;
   termsAndConditions;
   legalDesclaimer;
   name;
   isModalOpen;
   show_page;
   showvariabe;
   showdetails = true;
   userId = Id;
   userProfileName;
   hidePowerSportsFields = false;
    @track hideEditBoilerPlateButton = false;
   @track isLoading = false;
    @api objectApiName;

    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
            }
        }
    }


    connectedCallback(){
        this.show_page = true;
        if(this.stopRender==true){
        console.log('@@@this.recordId -'+this.recordId);
        }
        window.clearTimeout(this.delayTimeout);

        this.delayTimeout =setTimeout(() => {
          console.log('Hi 1');
          console.log('Hi 2' + this.recordId);
          this.handleapexmethod( this.recordId);
          console.log('Hi 3');
        },10)
        this.stopRender =false;
    }
    handleapexmethod(recordids){
        getdetails({
            offerid:recordids
        }).then(result =>{
         console.log('===='+result);
           this.results = result
           var offerRecordTypeName = result.offerRecordTypeName;
           var offerStatus = result.offerStatus;
           
            //Check and set an identifier for PowerSports RT
            if(offerRecordTypeName.includes('Power')){
                this.hidePowerSportsFields = true;
            }else {
                this.hidePowerSportsFields = false;
            }



           this.isLoading = false;
           if(offerStatus !== 'WIP' && offerStatus !=='Validated'){
            this.hideEditBoilerPlateButton = true;
           }
            if((this.userProfileName ==='B2C_OM_AHM_AIG' && (offerRecordTypeName !=='New Special Finance' && offerRecordTypeName !=='New Special Lease' && offerRecordTypeName !=='New Special Program' && offerRecordTypeName !=='New Standard Finance' && offerRecordTypeName !=='New Standard Lease'))){
                this.hideEditBoilerPlateButton = true;
            } else if(((this.userProfileName ==='B2C_OM_AHM_CPO') && (offerRecordTypeName !=='CPO Special Finance' && offerRecordTypeName !=='CPO Special Lease' && offerRecordTypeName !=='CPO Special Program' && offerRecordTypeName !=='CPO Standard Finance' && offerRecordTypeName !=='CPO Standard Lease'))){
                this.hideEditBoilerPlateButton = true;
            }  else if((this.userProfileName ==='B2C_OM_PS' && (offerRecordTypeName !=='Power Sports AHFC' && offerRecordTypeName !=='Power Sports Bonus Bucks' && offerRecordTypeName !=='Power Sports Generic' && offerRecordTypeName !=='Power Sports Honda Card'))){
                this.hideEditBoilerPlateButton = true;
            } else if (this.userProfileName ==='B2C_OM_ReadOnly'){
                this.hideEditBoilerPlateButton = true;
            } 
           console.log('this.results'+this.results.boilerplateid);
           this.handleservercall(this.results.boilerplateid);

        }).catch(error=>{

        })
    }
    handleservercall(boilerid){
        getboilerdetails({
            boilerplateid:boilerid
        }).then(result=>{
            this.myresult = JSON.stringify(result);
            this.areDetailsVisible= true;
            this.boilerplateid = result.boilerplateid;
            this.offerTitle =this.decodeHtmlEntities(result.offerTitle);
            this.shortDescription = this.decodeHtmlEntities(result.shortDescription);
            this.detailedDescription= this.decodeHtmlEntities(result.detailedDescription);
            this.termsAndConditions= this.decodeHtmlEntities(result.termsAndConditions);
            this.legalDesclaimer = this.decodeHtmlEntities(result.legalDesclaimer);
            this.name = result.name;
        }).catch(error=>{
            console.log('this is from error'+error);
            console.log('this is from error'+JSON.stringify(error));

        });
    }


    decodeHtmlEntities(inputStr) {
        const htmlEntitiesMap = {
          '&lt;': '<',
          '&gt;': '>',
          '&amp;': '&',
          '&quot;': '"',
          '&#039;': "'",
        };
      
        return inputStr.replace(/&[a-zA-Z0-9#]+;/g, (match) => {
          return htmlEntitiesMap[match] || match;
        });
      }


    handleedit(){
        this.isModalOpen = true;
    }
    closeModal(){
        this.isModalOpen = false;
    }
    submitDetails(){
        this.show_page = false;
        this.isLoading = true;
        console.log('this is from true'+ this.isLoading );
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            element.reportValidity();
        });
        const objChild1 = this.template.querySelector('c-defaultboilerpate').handlesaveoffer();
        console.log('objChild'+objChild1);
        this.handleapexmethod(this.recordId);
        
        this.show_page = true;
        this.isLoading = false;
        console.log('siva false'+this.isLoading);
		//window.location.reload(true);
        //this.isModalOpen = false;
       // window.location.reload(true);
        

    }
    resetboilerplate(){
        const objChild = this.template.querySelector('c-defaultboilerpate').handlereset();

    }
    hadlelistofvariable(){
        const objChild = this.template.querySelector('c-defaultboilerpate').handlemodelbox();
                    console.log('console.log');
    }

  
}
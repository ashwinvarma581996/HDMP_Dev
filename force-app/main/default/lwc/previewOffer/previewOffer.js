import { LightningElement,track,api,wire } from 'lwc';
import getRecordList from '@salesforce/apex/PreviewOffer.previewOffer2';
import updatepreview from '@salesforce/apex/PreviewOffer.updatepreview';
import validateRecord from '@salesforce/apex/PreviewOffer.validateRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import updateOemRecordsUpdated from '@salesforce/apex/PreviewOffer.updateOemRecord';
import getRecordTYPE from '@salesforce/apex/PreviewOffer.getRecordTYPE';
import controlOkMarkAsPreviewButtonVis from '@salesforce/apex/PreviewOffer.controlOkMarkAsPreviewButtonVisibility';
import previewValidation from '@salesforce/apex/PreviewOffer.getPreviewControl';
import IMAGES from "@salesforce/resourceUrl/HondaCarImage";
import { getRecord,getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OFFERS_OBJECT from '@salesforce/schema/Offers__c';
import PREVIEW_FIELD from '@salesforce/schema/Offers__c.Preview__c';
import RecorTypeName from '@salesforce/schema/Offers__c.RecordType.Name';

//for Date show on preview start
import OFFER_OBJECT from '@salesforce/schema/Offers__c';
import ADV_START_DATE_FIELD from '@salesforce/schema/Offers__c.Advertised_Start_Date__c';
import ADV_END_DATE_FIELD from '@salesforce/schema/Offers__c.Advertised_End_Date__c';
import START_DATE_FIELD from '@salesforce/schema/Offers__c.Start_Date__c';
import END_DATE_FIELD from '@salesforce/schema/Offers__c.End_Date__c';
import getOffers from '@salesforce/apex/PreviewOffer.getOfferDate';
// import { jsPDF } from "jspdf";
//Ends 

// import Id from '@salesforce/user/Id';
// import UserNameFIELD from '@salesforce/schema/User.Name';
// import oem_Offer_Title from '@salesforce/schema/Offer_Eligible_Models__c.Offer_Title__c';
// import oem_Short_Description from '@salesforce/schema/Offer_Eligible_Models__c.Short_Description__c';
// import oem_Legal_Desclaimer from '@salesforce/schema/Offer_Eligible_Models__c.Legal_Desclaimer__c';
// import oem_Detailed_Description from '@salesforce/schema/Offer_Eligible_Models__c.Detailed_Description__c';
// import oem_Terms_and_Conditions from '@salesforce/schema/Offer_Eligible_Models__c.Terms_and_Conditions__c';
// import PROFILEID from '@salesforce/schema/User.ProfileId';
import { CloseActionScreenEvent } from 'lightning/actions';
// import { NavigationMixin } from 'lightning/navigation';
import Preview_Offer_Criteria_One from '@salesforce/label/c.Error_on_Preview_Offer_Criteria_One';
import Preview_Offer_Criteria_Two from '@salesforce/label/c.Error_on_Preview_Offer_Criteria_Two';
import Preview_Offer_Criteria_Three from '@salesforce/label/c.Error_on_Preview_Offer_Criteria_Three';
import Preview_Offer_Criteria_Four from '@salesforce/label/c.Error_on_Preview_Offer_Criteria_Four';
import Error_on_Preview_Offer_Criteria_Five from '@salesforce/label/c.Error_on_Preview_Offer_Criteria_Five';
import Error_on_Preview_Offer_Criteria_Six from '@salesforce/label/c.Error_on_Preview_Offer_Criteria_Six';
import ErrorOnMissingTags from '@salesforce/label/c.ErrorOnMissingTagsPreview';
export default class PreviewOffer extends NavigationMixin(LightningElement) {
  @api recordId;
  
  @api error;
  torontoImage = IMAGES;
@api checkfieldcondition;
@track isLoaded;
@api previewcheckbox;
@track currentUserName;
@track currentUserProfileId;
@track currenUserProfileName;
@track objdatanew;
@track  myAObjrray ;
@api storeOemRecords;
@track updatedOemrecords =[];
showAHMandAHFCSalesProgramId =true;
@track recordTypeName;
disableMarkAsPreviewed =false;
inputTextforValidation='';
@track isModalOpenWarning =false; 
// @track activeSections=['A'];
@track activeSections=['A'];
@track section = 'A';

offerId;
@api wired;

label = {
  Preview_Offer_Criteria_One,
  Preview_Offer_Criteria_Two,
  Preview_Offer_Criteria_Three,
  Preview_Offer_Criteria_Four,
  Error_on_Preview_Offer_Criteria_Five,
  ErrorOnMissingTags,
  Error_on_Preview_Offer_Criteria_Six
}

closeQuickAction() {
  this.dispatchEvent(new CloseActionScreenEvent());
}


@wire(getRecord, { recordId: '$recordId',fields: [PREVIEW_FIELD,RecorTypeName]})
offerObjRecord;

stopRender =true;

IsProfieApprover=true;

//Code for showing date on preview
@track validFromDate;
@track validToDate;

fetchOfferData() {
  getOffers({ recordId: this.recordId })
      .then(result => {
        console.log('getOffers result ->>>>' + result);
          // this.validFromDate = result.Advertised_Start_Date__c ? result.Advertised_Start_Date__c : result.Start_Date__c;
          // this.validToDate = result.Advertised_End_Date__c ? result.Advertised_End_Date__c : result.End_Date__c;
          this.validFromDate = result.Advertised_Start_Date__c ? new Date(result.Advertised_Start_Date__c) : new Date(result.Start_Date__c);
          this.validToDate = result.Advertised_End_Date__c ? new Date(result.Advertised_End_Date__c) : new Date(result.End_Date__c);
          
     
          console.log('this.validFromDate====>>'+this.validFromDate);
      console.log('this.validToDate====>>'+this.validToDate);

    //   if (this.validFromDate) {
    //     this.validFromDate = this.formatDate(this.validFromDate);
    // }
    // if (this.validToDate) {
    //     this.validToDate = this.formatDate(this.validToDate);
    // }
        })
      .catch(error => {
          console.error('Error fetching offer data', error);
      });
}

// printToPdf() {
//   const doc = new jsPDF();
//   const popupContent = this.template.querySelector('.modelPopup').innerHTML;

//   // jsPDF code to add HTML
//   doc.fromHTML(popupContent, 15, 15, {
//       'width': 170
//   });

//   // Save the PDF
//   doc.save('popup-content.pdf');
// }
// formatDate(dateString) {
//   const date = new Date(dateString);
//   const month = (date.getMonth() + 1).toString().padStart(2, '0');
//   const day = date.getDate().toString().padStart(2, '0');
//   const year = date.getFullYear();
//   return `${month}/${day}/${year}`;
// }

// formatDate(date) {
//   return new Intl.DateTimeFormat('en-US', {
//       year: 'numeric',
//       month: '2-digit',
//       day: '2-digit'
//   }).format(date);
// }

// formatDate(date) {
//   return date.toLocaleDateString('en-US', {
//       year: 'numeric',
//       month: 'numeric',
//       day: 'numeric'
//   });
// }
//Ends


validateSepcialCategoryAndAmount(){

  validateRecord({ recordId: this.recordId })
  .then(() => {
      // Record is valid, proceed as necessary
  })
  .catch(error => {
      // Show an error message
      this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error',
              message: error.body.message,
              variant: 'error',
          }),
      );

      // Redirect to the Offer record page
      this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
              recordId: this.recordId,
              actionName: 'edit'
          }
      });
  });
}





   connectedCallback(){
    this.offerId = this.recordId;
    
console.log('inside connected call back preview offer');

console.log('inside connected Callback - this.offerId--'+this.offerId);
      if(this.stopRender==true){
     
      console.log('@@@this.recordId -'+this.recordId);
      
        console.log('@@@this.recordId'+this.recordId);
        window.clearTimeout(this.delayTimeout);

        this.delayTimeout =setTimeout(() => {
          console.log('Hi 1');
          console.log('Hi 2' + this.recordId);
          this.fetchOfferData();
          this.previewValidationmethod();        
          this.getRecordTYPE();
          this.controlOkMarkAsPreviewButtonVis();         
          this.callapexMethod();
          this.validateSepcialCategoryAndAmount();
          console.log('Hi 3');
        },10)
        
  
}
this.stopRender =false;
console.log('this.stopRender-'+this.stopRender);
}


getRecordTYPE(){
console.log('inside getRecordType --->>this.offerId '+this.recordId)
getRecordTYPE({recordId: this.recordId})
  .then((result) => {
      console.log('inside getRecordType - result==>'+JSON.stringify(result));
    
          if( result == 'Power Sports AHFC' || result == 'Power Sports Bonus Bucks' || result == 'Power Sports Generic' || result == 'Power Sports Honda Card'){    
          this.showAHMandAHFCSalesProgramId = false;
          console.log('this.showAHMandAHFCSalesProgramId'+this.showAHMandAHFCSalesProgramId);
      }
  
  })
  .catch(error => {
      this.error = error;
    })
}


controlOkMarkAsPreviewButtonVis(){
  console.log('controlOkMarkAsPreviewButtonVis');
  controlOkMarkAsPreviewButtonVis({recordId:this.recordId})
  .then((result)=>{
    console.log('inside controlOkMarkAsPreviewButtonVis - result ==>'+JSON.stringify(result));
    if(result==true){
    this.disableMarkAsPreviewed=true;
    }
  })
}

@track storeOfferDetails;

@track boilerplateError=false;
@track eligibleModelAssociateError=false;
@track IncSamPayOrFeaturedError=false;
@track IncSamPayAndFeaturedError=false;
@track ApplyAllClearAllEditCashElementError=false;

callapexMethod(){

  getRecordList({recordID: this.recordId}).then(result => {

  console.log('JSON.stringify(result)-----'+JSON.stringify(result));
  console.log('JSON.parse(result)-->>>>'+ JSON.parse(result));
  let topicitems=[];
   JSON.parse(result).forEach(function (currentItem, index){
 
     console.log('currentItem.OfferTitle-->>'+currentItem.OfferTitle);
     console.log('index-->>'+index);
     console.log('currentItem.SdisableMarkAsPreviewed====>>'+JSON.stringify(currentItem.SdisableMarkAsPreviewed));
     let offdetail = {Id:index,recordIdForOem:currentItem.oemId,OfferTitle:currentItem.OfferTitle, ShortDescription:currentItem.ShortDescription, LegalDesclaimer:currentItem.LegalDesclaimer, DetailedDescription:currentItem.DetailedDescription, TermsAndConditions:currentItem.TermsAndConditions, 
      defaultImageUrl:currentItem.defaultImage, boilerplatecheck:currentItem.boilerPlateCheckwp};
       console.log('boilerplatecheck-->>'+offdetail.boilerplatecheck);
     if(offdetail.boilerplatecheck==undefined){
      offdetail.boilerplatecheck='false';
     }
     if(offdetail.OfferTitle=='null'){
      offdetail.OfferTitle='';
     }
    //  else{
    //   offdetail.OfferTitle = this.changeVariableColor(offdetail.OfferTitle);
    //  }

     if(offdetail.ShortDescription=='null'){
      offdetail.ShortDescription='';
     }
    //  else{
    //   offdetail.ShortDescription = this.changeVariableColor(offdetail.ShortDescription);
    //  }


     if(offdetail.LegalDesclaimer=='null'){
      offdetail.LegalDesclaimer='';
     }
    //  else{
    //   offdetail.LegalDesclaimer = this.changeVariableColor(offdetail.LegalDesclaimer);
    //  }

     if(offdetail.DetailedDescription=='null'){
      offdetail.DetailedDescription='';
     }
    //  else{
    //   offdetail.DetailedDescription=this.changeVariableColor(offdetail.DetailedDescription);
    //  }

     if(offdetail.TermsAndConditions=='null'){
      offdetail.TermsAndConditions='';
     }
    //  else{
    //   offdetail.TermsAndConditions=this.changeVariableColor(offdetail.TermsAndConditions);
    //  }
 
topicitems.push(offdetail);
   });
   
  //  if(topicitems.length >0 ){
    // if(topicitems[0].boilerplatecheck=='true' && this.previewControlCheck==true){
      if(this.previewControlCheck==true){
   this.openModal();
   this.checkfieldcondition=true;

  //  const dynamicSectionNames = topicitems.map(item => item.Id);
  //  this.activeSections = [...this.activeSections, ...dynamicSectionNames];

  //  console.log('this.activeSections====>'+this.activeSections);

   console.log('topicitems'+JSON.stringify(topicitems));

  // const dynamicSectionNames = topicitems.map(item => item.Id.toString());
  //       this.activeSections = [...this.activeSections, ...dynamicSectionNames];

  //       // console.log(this.activeSections); // Check the result
  //  console.log('this.activeSections====>'+JSON.stringify(this.activeSections));

   
   this.myAObjrray=topicitems;
  
  //  console.log('JSON.stringify(myAObjrray)'+JSON.stringify(myAObjrray));
   this.storeOemRecords=topicitems;
   console.log('Inside getRecordList - this.myAObjrray==>>'+ JSON.stringify(this.myAObjrray));
   // After fetching data, update activeSections
  //  const dynamicSectionNames = this.myAObjrray.map(item => item.id);
  //  this.activeSections = [...this.activeSections, ...dynamicSectionNames];
  //  console.log('this.activeSections====>'+JSON.stringify(this.activeSections));

   const dynamicSectionNames = this.myAObjrray.map(item => item.Id);
   //this.activeSections = [...this.activeSections, ...dynamicSectionNames];
   
   for(let i = 0; i<this.myAObjrray.length;i++){
    const char = this.getNextChar(this.section);
    this.section = char;
    console.log('printing section', char);
    this.myAObjrray[i].SectionName = this.section;
    this.activeSections.push(char);


   }
   console.log('this.activeSections====>'+JSON.stringify(this.activeSections));



   this.showErrorOnMissingTags();
   this.checkfieldcondition=true;
  }
  // else if(topicitems[0].boilerplatecheck!='true') {
  //   this.boilerplateError = true;
  //   this.isModalOpenWarning =true;
    
  // }
  //  }
else{

this.isModalOpenWarning =true;
      }

})
.catch(error => {
console.log('Inside getRecordList - error....',error);
this.error = error;


console.log('Error is ' + JSON.stringify(this.error));
});
  
}

// //Method to show error for missing variables
hideMissingTagError=false;
@track errorMissingValues;
showErrorOnMissingTags() {
    let resultMessage = '';
    const pattern = /<<\s*[a-zA-Z0-9_]+\s*>>/g;
    let matches = [];

  console.log('this.myAObjrray====>>>>>>>>>>'+this.myAObjrray);
    // Iterate through each object in the array and then through each property of the object
    this.myAObjrray.forEach((obj) => {
      for (const property in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, property)) {
          const value = obj[property];
          if (typeof value === 'string') {
            const foundMatches = value.match(pattern);
            if (foundMatches) {
              matches = matches.concat(foundMatches);
  console.log('matches=====>>>'+matches);
            }
          }
        }
      }
    });
  
    if (matches.length > 0) {
      // Create a Set to store unique matches
      const uniqueMatches = new Set(matches);
  this.disableMarkAsPreviewed=true;
  this.hideMissingTagError=true;
      // Convert the Set back to an array
      const uniqueArray = Array.from(uniqueMatches);
  console.log('uniqueArray=====>>>'+uniqueArray);
   
  
      this.missingValues = Array.from(uniqueMatches);
      console.log('this.missingValues=====>>>' + this.missingValues);
      
      resultMessage = `[${uniqueArray.join(', ')}]`;
  this.errorMissingValues = resultMessage;
  console.log('resultMessage=====>>>>>'+resultMessage);
    } else {
      resultMessage = 'The text does not contain the specified pattern.';
    }
}

@track previewControlCheck =false;

previewValidationmethod(){
  previewValidation({recordId:this.recordId})
  .then((result)=>{

    console.log('Inside previewValidation---->>>>'+result);
       result.forEach((value)=>{
        // switch(value){
      
          if(value== 'showOtherOffersPreview' ) {
            this.previewControlCheck =true;
            console.log('showOtherOffersPreview====>>>>'+value);
          }
            if(value=='showLeasePreview') {
              this.previewControlCheck =true;
              console.log(value);
            }
             if(value=='stopPreviewBoilerPlateError')
          {
            this.previewControlCheck =false;
            this.boilerplateError=true;
            console.log(value);
         console.log('###boilerplateError===>'+this.boilerplateError);
          }
         if(value == 'stopPreviewLeasePreview' ){
              
              this.previewControlCheck =false;
              this.IncSamPayAndFeaturedError=true;
             console.log('this.IncSamPayAndFeaturedError==>'+this.IncSamPayAndFeaturedError);
            }  if(value =='stopPreviewApplyAllClearAllEditCashElementError'){
             
              this.previewControlCheck =false;
              this.ApplyAllClearAllEditCashElementError=true;
              console.log('this.ApplyAllClearAllEditCashElementError'+this.ApplyAllClearAllEditCashElementError);
            }
           if(value=='stopPreviewIncSamPayOrFeaturedError'){
              this.previewControlCheck =false;
              this.IncSamPayOrFeaturedError=true;
              console.log('this.IncSamPayOrFeaturedError===>'+this.IncSamPayOrFeaturedError);
            }
            if(value=='stopPreviewEligibleModelAssociateError'){
           
              this.previewControlCheck =false;
              this.eligibleModelAssociateError=true;
              console.log('this.eligibleModelAssociateError===>>>'+this.eligibleModelAssociateError);
            
              

        }
      });
console.log('previewControlCheck===>>'+this.previewControlCheck);
     console.log('### Boilerplate error:'+this.boilerplateError);
     //Manohar 27 APR : Adding below to show warning panel in case of any error exists
    if(this.boilerplateError==true || this.IncSamPayAndFeaturedError==true ||this.ApplyAllClearAllEditCashElementError==true||this.IncSamPayOrFeaturedError==true||this.eligibleModelAssociateError==true)
    {
      this.isModalOpenWarning =true;
    }

  })

}

getNextChar(char) {
  return String.fromCharCode(char.charCodeAt(0) + 1);
}
changeVariableColor(description){

  // Find all occurrences of text surrounded by "<<" and ">>"
      const regex = /<<\s*[a-zA-Z0-9_]+\s*>>/g;
      let match;
      let updatedDescription = description;
  
   console.log('inside changeVariableColor updatedDescription-->> '+ JOSN.stringify(updatedDescription));
  
      // Loop through all occurrences and replace with span
      while ((match = regex.exec(description))) {
        // Create a new span element with red color
        const span = document.createElement('span');
        span.style.color = 'red';
        span.innerText = match[1];
        // Replace the match with the span
        updatedDescription = updatedDescription.replace(match[0], span.outerHTML);
     console.log('updatedDescription---->>>>'+ JSON.stringify(updatedDescription));
 }
  
   
  
      // Update the description with the updated HTML
      description = updatedDescription;
  console.log('description ---->>>>'+ JSON.stringify(description));
  return description;
    
}

updateRecordView() {
  console.log('----Inside updateRecordView-1---');
  setTimeout(() => {
    console.log('----Inside updateRecordView-2----');
       eval("$A.get('e.force:refreshView').fire();");
  }, 1000); 
}

updateofferObjRecord(){
console.log('inside updateofferObjRecord');

console.log('inside updateofferObjRecord - this.recordId==>>'+this.recordId);

updatepreview({recordID: this.recordId})
        .then(result => {
            this.wired = result;
            console.log('Inside - updatepreview - result==>>'+JSON.stringify(result));
        })
        .catch(error => {
            console.log('Inside updatepreview - error==>>'+JSON.stringify(error));
            this.error = error;
        });

  const fields ={};
  fields[PREVIEW_FIELD.fieldApiName] = true;

  const recordInput ={fields};
  console.log('updateofferObjRecord2');
  this.isModalOpen = false;
  this.isModalOpenWarning =false;
  this.updateRecordView();
  this.closeQuickAction();
  console.log('after this.closeQuickAction()');

  
  this.isModalOpen = false;
  this.isModalOpenWarning =false;

  this.updateVariableNamesinOemObj();
this.updateRecordView();
this.closeModal();

}



updateVariableNamesinOemObj(){
  console.log('this.storeOemRecords.length---->'+JSON.stringify(this.storeOemRecords.length));
console.log('this.storeOemRecords.length---->'+JSON.stringify(this.storeOemRecords));
  for(let j=0; j<this.storeOemRecords.length;j++){

     let Offer_Eligible_Models__c ={ 
    Id:this.storeOemRecords[j].recordIdForOem,
    Offer_Title__c: this.storeOemRecords[j].OfferTitle,
    Short_Description__c: this.storeOemRecords[j].ShortDescription,
    Legal_Desclaimer__c: this.storeOemRecords[j].LegalDesclaimer,
    Detailed_Description__c: this.storeOemRecords[j].DetailedDescription,
    Terms_and_Conditions__c: this.storeOemRecords[j].TermsAndConditions,

     }
     this.updatedOemrecords.push(Offer_Eligible_Models__c);
  }
console.log('this.updatedOemrecords-->>'+JSON.stringify(this.updatedOemrecords));
updateOemRecordsUpdated({oemList: this.updatedOemrecords})
.then(result =>{
  console.log('result - updateOemRecordsUpdated -->' +JSON.stringify(result));
})
.catch(error =>{
  console.error('error inside - updateOemRecordsUpdated'+JSON.stringify(error));
});
}


@track isModalOpen = false;
openModal() {

    this.isModalOpen = true;
}
closeModal() {
    
    this.isModalOpen = false;
    this.isModalOpenWarning =false;
    this.myAObjrray=false;
    this.checkfieldcondition=false;
    this.closeQuickAction();
    
}
submitDetails() {
    
    this.isModalOpen = false;
    this.isModalOpenWarning =false;
    this.closeQuickAction();
}

    
}
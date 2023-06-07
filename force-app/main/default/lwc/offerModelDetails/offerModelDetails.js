import { LightningElement,track,wire ,api} from 'lwc';
import getModelDetails from '@salesforce/apex/SpecialLeaseHandler.getModelDetails';
import getOEMDetails from '@salesforce/apex/SpecialLeaseHandler.getOEMDetails';
import getModel from '@salesforce/apex/SpecialLeaseHandler.getModelID';
import getRecordTYPE from '@salesforce/apex/SpecialLeaseHandler.getRecordType';
import saveOfferEligibileModelRecord from '@salesforce/apex/SpecialLeaseHandler.saveOfferEligibileRecord';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Terms_Months from '@salesforce/schema/Offer_Eligible_Models__c.Terms_Months__c';
import Annual_Miles from '@salesforce/schema/Offer_Eligible_Models__c.Annual_Miles__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OFFER_ELIGIBLE_MODEL_OBJECT from '@salesforce/schema/Offer_Eligible_Models__c';
import { calculateLease } from './calculateUtil';
import { NavigationMixin } from 'lightning/navigation';
import brand from '@salesforce/schema/Offers__c.Brand__c';
import zeroDue from '@salesforce/schema/Offers__c.Zero_Due__c';
//import destinationCharge from '@salesforce/schema/Offer_Eligible_Models__c.Destination_Handling_charge__c'
import securityDeposit from '@salesforce/schema/Offers__c.Security_Deposit_Required__c';
import getModelImage from '@salesforce/apex/ImageController.getModelImage';
import removeModelImage from '@salesforce/apex/ImageController.removeModelImage';
import getData from '@salesforce/apex/ImageController.getData';
import updateModelImage from '@salesforce/apex/ImageController.updateModelImage';
import getModelDetailsSec2 from '@salesforce/apex/SpecialLeaseHandler.getModelDetailsSec2';
import savePowerSportsRecord from '@salesforce/apex/SpecialLeaseHandler.savePowerSportsRecord';
import updatePowerSportData from '@salesforce/apex/SpecialLeaseHandler.updatePowerSportData';

import { getRecord } from 'lightning/uiRecordApi';   

const columns = [
    { label: 'Image', fieldName: 'Offer_Image_Thumb_URL__c', type:'image'},
    { label: 'File Name', fieldName: 'Offer_Image_Thumb_URL__c',type:'text' },
    { label: 'Exterior Color', fieldName: 'Exterior_Color_Name__c' , type:'text'},
    { label: 'Upcharge Color Flag', fieldName: 'Color_Flag' , type:'boolean',cellAttributes: { alignment: 'center' }},
    
]; 


export default class OfferModelDetails extends  NavigationMixin(LightningElement) {
    @track modelNames = []; 
    @track selectedModalYear;
    @track selectedModalName;
    @track selectedModalTrim = [];
    @track SelectedPsSec1Year;
    @track SelectedPsSec2Year;
    @track SelectedPsSec1segment;
    @track SelectedPsSec2Segment;
    @track SelectSegmentSec1Options = [];
    @track SelectSegmentSec2Options = [];
    @track SelectCategorySec1Options = [];
    @track SelectCategorySec2Options = [];
    @track SelectModalSec1Options = [];
    @track SelectModalSec2Options = [];
    @track SelectFamilySec1Options = [];
    @track SelectFamilySec2Options = [];
    @track selectModelOptions = [];
    @track selectYearOptions = [];
    @track selectTrimOptions = [];
    @track modelId;
    @track displayMgs = false;
    @track modelMgs;
    modalName = [];
    @track modelNameYRWise;
    @track trimModelNameWise;
    @track segmentYearWise;
    @track categorySegmentWise;
    YearWiseMap = [];
    modalWiseMap = [];
    @api isPowerSportsRT;
    @api isCFO;
    @track hasSamplePayment = false;
    @track hasShowSamplePayment = false;
    @track featuredOffer;
    @track grossMargin;
    @track termsInmonths;
    @track acquisitionFee;
    @track dealerContribution;
    @track capitalizeCostReduction;
    @track netCapitalCost;
    @track adjustedMSRBWithDH;
    @track annualMiles;
    @track residualFactor;
    @track moneyFactor;
    @track conquestCash;
    @track loyaltyCash;
    @track additionalCash;
    @track baseMonthlyPayment;
    @track msrp = '10';
    @track bHasSecurityDeposit;
    @track invPriceWithDH;
    @track totalDueAtsigning;
    @track residualValue;
    @track totalMonthlyPayments;
    @track showErrorMgs = false;
    @track ValidationErrorMessage = [];
    @track hasSamplePaymentSectionData;
    @track finalList= {};
    @track offerId;
    @api recordId;
    @track brand;
    @track captiveCashamt;
    @track otherCaptiveAmt;
    @track destinationCharge;
    @track editMode;
    @api hasModelId;
    @track yourSelectedValues;
    @track AllCheck = true;
    @track AllTrimsSelected = []; 
    @track section1 = false;
    @track section2 = false;
    @track imageUrl;
    @track showRemove = false;
    @track selectedImage;
    @track dataImage;
    @track showForm = false;
    @track openVehicle = false;
    column = columns;
    // for Section 2
    @track sec2Data = [];
    @track segmentOptionsSeg2=[];
    @track categoryOptionssec2 = [];
    @track segSection2;
    @track catSection2;
    @track familySection2;
    @track familyOptionSec2 = [];
    @track yearOptionSec2 = [];
    @track modelOptionSec2 = [];
    @track yearSec2 = [];
    @track modelSec2 = [];
   // segSet = new Set();
   // for section 2

   @track sec1Data = [];
    @track segmentOptionsSeg1=[];
    @track categoryOptionssec1 = [];
    @track segSection1;
    @track catSection1;
    @track familySection1;
    @track familyOptionSec1 = [];
    @track yearOptionSec1 = [];
    @track modelOptionSec1 = [];
    @track modelOption = [];
    @track yearSec1 = [];
    @track modelSec1 = [];
    @track yrSet = new Set();
    @track editYear;
    @track editSegment;
    @track editCategory;
    @track editFamily;
    @track editModel;
    @track powerSportData;
    @track editYearOption = [];
    @track editSegment = [];
    @track editCategory = [];
    @track editFamily = [];
    @track editModel = [];
    @track modelSection1= [];
    @track modelSection2 = [];
    @track editMSRP;
    @track editFeatured;
    @track editFreight;
    @track showSpinner = true;
    @track showSelect = true;
    @track save = false;
    @track modelError = false;
    @track modelErrorMessage = 'Model Image is missing';
    @api isPrism;
    @track isAll = false;
    @track cpoCash = '';
    @track showCPO = false;
    @track recordTypeName;
    @track enableFeaturedOffer = false;
    @track makeFieldsReadonly = false;
    @api leaseIdentifier;
    @track vanilaInbound = false;
    @track makeSamplePaymentReadOnly = false;

    options = [
        { label: 'Year/Segment/Category/Model(s)', value: 'section1' },
        { label: 'Segment/Category/Year/Model(s)', value: 'section2' },
    ];

    // Select option1 by default
    value = 'option1';

    connectedCallback(){
        console.log('Offer recordId==>'+this.recordId);
        console.log('isCFO==>'+this.isCFO);
       // console.log('Session storage data',sessionStorage.getItem('isEdit'));
        this.offerId = this.recordId;
        // commented as we no longer placing compo on standard edit btn instead passing OEMID from datatable cmp,
        //therefore exposing as  APi
        /*console.log('url==>'+window.location.href);
        var currentrecordId;
        if((window.location.href).includes("/Offer_Eligible_Models__c/")) {
            currentrecordId = (window.location.href).split("/Offer_Eligible_Models__c/")[1];
            currentrecordId = currentrecordId.slice(0, 18);
        }
        this.OEMId = currentrecordId;
        console.log('currentrecordId=>'+this.OEMId);*/
        if(this.hasModelId != null && this.hasModelId != undefined && this.hasModelId != ''){
            console.log('hasModelId==>'+this.hasModelId);
            this.getOEMDetails();
            this.editMode = true;
        }else{

            this.editMode = false;
        }
        console.log('this.prism',this.isPrism);
     /*   if(this.isPrism === true){
            //this.hasShowSamplePayment = false;
        
        if(this.leaseIdentifier === '' || this.leaseIdentifier === null || this.leaseIdentifier === undefined){
            this.makeFieldsReadonly = false;
            this.vanilaInbound = true;
        }else{
            this.makeFieldsReadonly = true;
            this.makeSamplePaymentReadOnly = true;
        }
    }     */

        console.log('printing hasModelId',this.hasModelId);
        console.log('peinting edit mode',this.editMode);
     
        this.getRecordTYPE();
    }
/*  ---------------Default Image url starts here---------------------------------------------------------- */

removeImageData(){
    this.selectedImage = '';
    this.imageUrl = '';
    this.showRemove = false;
    removeModelImage({
            recId:this.recordId
        }).then(result=>{
            console.log('Printing results 1', result);
            
        }).catch(error=>{
            console.log('this is from error'+error);
            console.log('this is from error'+JSON.stringify(error));

        });
}

updatePowerSportData(){
    updatePowerSportData({
            recData:this.powerSportData,
            recId: this.hasModelId,
            offerId:this.offerId
        }).then(result=>{
            if(result == 'true'){
            this.showSpinner = false;
            console.log('Printing results 1', result);
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "Success",
                  message: `Record updated Succesfully!`,
                  variant: "success"
                })
              );
            
              this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.offerId,
                    objectApiName: 'Offers__c',
                    actionName: 'view'
                },
            });
        } else{
            this.showSpinner = false;
            console.log('error',result);
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "Error Occured",
                  message: `Something went wrong`,
                  variant: "Error"
                })
              );
        }
            
        }).catch(error=>{
            console.log('this is from error'+error);
            console.log('this is from error'+JSON.stringify(error));

        });
}

updateData(){
    updateModelImage({
            recId:this.hasModelId,
            defaultImage: this.selectedImage
        }).then(result=>{
            console.log('Printing results 1', result);
            if(result === true){
                this.imageUrl = this.selectedImage;
                this.showRemove = true;
                this.showForm = true;
                this.openVehicle = false;

            }
        }).catch(error=>{
            console.log('this is from error'+error);
            console.log('this is from error'+JSON.stringify(error));

        });
}
getImageData(){
    getData({
            recId:this.hasModelId
        }).then(result=>{
            console.log('Printing results 1', result);
            if(result.length > 0){
                this.dataImage = result;
                for(let i =0; i< this.dataImage.length; i++){
                    if(this.dataImage[i].Exterior_Price_Delta__c != undefined && this.dataImage[i].Exterior_Price_Delta__c != null && this.dataImage[i].Exterior_Price_Delta__c > 0){
                        this.dataImage[i].Color_Flag = true;
                    } else{
                        this.dataImage[i].Color_Flag = false;
                    }
                }
                
            }
            this.showSpinner = false;
        }).catch(error=>{
            this.showSpinner = false;
            console.log('this is from error'+error);
            console.log('this is from error'+JSON.stringify(error));

        });
}

handleRowSelection = event => {
    var selectedRows = event.detail.selectedRows;
    console.log('selectedRow=='+JSON.stringify(selectedRows));
    if (selectedRows.length > 0) {
        this.showSelect = false;
        var el = this.template.querySelector('image-datatable');
        console.log('selected rows',selectedRows[0].Offer_Image_Thumb_URL__c);
        this.selectedImage = selectedRows[0].Offer_Image_Thumb_URL__c;
        this.imageUrl = this.selectedImage;
        if(this.selectedImage != null && this.selectedImage != '' && this.selectedImage != undefined){
            this.modelError = false;
        }
        event.preventDefault();
        
    }
}
handleSelect(){
    this.showSpinner = true;
    this.getImageData();
    this.openVehicle = true;
    console.log('openVehicle', this.openVehicle);
    const selectedEvent = new CustomEvent('valueselected', {
        detail:{
            value:this.openVehicle
        } 
    });
    //dispatching the custom event
    this.dispatchEvent(selectedEvent);
    
}

handleCancel(){
    this.openVehicle = false;
}

getModelDetailsSegmentSec2(){
    this.segmentOptionsSeg2 = [];
    const segSet = new Set();
    for(const list of  this.sec2Data){
        if(segSet.has(list.Tier2__c) === false && list.Tier2__c != '' && list.Tier2__c != null && list.Tier2__c != undefined){
            segSet.add(list.Tier2__c);
            const option = {
                label: list.Tier2__c,
                value: list.Tier2__c
            };
            this.segmentOptionsSeg2 = [ ...this.segmentOptionsSeg2, option ];
        }
        
    }
   
}


/*
getModelDetailsSec1(){
    getModelDetailsSec1({
            brand:this.brand
        }).then(result=>{
            console.log('Printing results 1', result);
            if(result.length > 0){
                this.sec2Data = result;
                const segSet = new Set();
                for(const list of  this.sec2Data){
                    if(segSet.has(list.Tier1__c) === false){
                        segSet.add(list.Tier1__c);
                        const option = {
                            label: list.Tier1__c,
                            value: list.Tier1__c
                        };
                        this.yearOptionSec1 = [ ...this.yearOptionSec1, option ];
                    }
                    
                }
            }
        }).catch(error=>{
            console.log('this is from error'+error);
            console.log('this is from error'+JSON.stringify(error));

        });
}


handleYearChangeSec1(event){
    console.log('printing years:',event.detail.value);
    this.modelOptionSec1 = [];
    const yr = event.detail.value;
    this.yearSec2 = yr;
    const yrSet = new Set();
    for(const yr of this.yearSec2){
        yrSet.add(yr);
    }
    const segSet = new Set();
                for(const list of  this.sec2Data){
                    if(segSet.has(list.Tier5__c) === false && list.Tier3__c === this.catSection2 && list.Tier2__c === this.segSection2 && list.Tier4__c === this.familySection2 && yrSet.has(list.Tier1__c)){
                        segSet.add(list.Tier5__c);
                        const option = {
                            label: list.Tier5__c,
                            value: list.Tier5__c
                        };
                        this.modelOptionSec2 = [ ...this.modelOptionSec2, option ];
                    }
                    
                }
}


*/
////--------------------------------------------------------------------////////////////////////////


handleSegmentChangeSec2(event){
    this.categoryOptionssec2 = [];
    const seg = event.detail.value;
    this.segSection2 = seg;
    const segSet = new Set();
                for(const list of  this.sec2Data){
                    if(segSet.has(list.Tier3__c) === false && list.Tier3__c != null && list.Tier3__c != '' && list.Tier3__c != undefined && list.Tier2__c === seg){
                        segSet.add(list.Tier3__c);
                        const option = {
                            label: list.Tier3__c,
                            value: list.Tier3__c
                        };
                        this.categoryOptionssec2 = [ ...this.categoryOptionssec2, option ];
                    }
                    this.showSpinner = false;
                    
                }

}
handleCategoryChangeSec2(event){
    this.familyOptionSec2 = [];
    const cat = event.detail.value;
    this.catSection2 = cat;
    const segSet = new Set();
                for(const list of  this.sec2Data){
                    if(segSet.has(list.Tier4__c) === false && list.Tier4__c != null && list.Tier4__c != '' && list.Tier4__c != undefined && list.Tier3__c === this.catSection2 && list.Tier2__c === this.segSection2){
                        segSet.add(list.Tier4__c);
                        const option = {
                            label: list.Tier4__c,
                            value: list.Tier4__c
                        };
                        this.familyOptionSec2 = [ ...this.familyOptionSec2, option ];
                    }
                    
                }
}

handlefamilyChangeSec2(event){
    this.yearOptionSec2 = [];
    const fam = event.detail.value;
    this.familySection2 = fam;
    const segSet = new Set();
                for(const list of  this.sec2Data){
                    if(segSet.has(list.Tier1__c) === false && list.Tier1__c != null && list.Tier1__c != '' && list.Tier1__c != undefined && list.Tier3__c === this.catSection2 && list.Tier2__c === this.segSection2 && list.Tier4__c === this.familySection2){
                        segSet.add(list.Tier1__c);
                        const option = {
                            label: list.Tier1__c,
                            value: list.Tier1__c
                        };
                        this.yearOptionSec2 = [ ...this.yearOptionSec2, option ];
                    }
                    
                }
}

handleYearChangeSec2(event){
    console.log('printing years:',event.detail.value);
    this.modelOptionSec2 = [];
    this.modelOptionSec2 = [{"label": "All","value":"All"}];
    
    const yr = event.detail.value;
    this.yearSec2 = yr;
    const yrSet = new Set();
    for(const yr of this.yearSec2){
        yrSet.add(yr);
    }
    const segSet = new Set();
                for(const list of  this.sec2Data){
                    if(segSet.has(list.Tier5__c) === false && list.Tier5__c != null && list.Tier5__c != '' && list.Tier5__c != undefined && list.Tier3__c === this.catSection2 && list.Tier2__c === this.segSection2 && list.Tier4__c === this.familySection2 && yrSet.has(list.Tier1__c)){
                        segSet.add(list.Tier5__c);
                        const option = {
                            label: list.Tier5__c,
                            value: list.Tier5__c
                        };
                        this.modelOptionSec2 = [ ...this.modelOptionSec2, option ];
                    }  
                }
            

        /*        for(const y of modelOption){
                    const count  = 0;
                    for(const y of this.yearSec2){
                        for(const list of this.sec2Data){
                            if(list.Tier1__c === y && list.Tier3__c === this.catSection2 && list.Tier2__c === this.segSection2 && list.Tier4__c === this.familySection2){
                                count = count+1;
                            } else{
                                unique = false;
                            }
                        }
                    }
                    if(count === this.yearSec2.length){
                        const option = {
                            label: y,
                            value: y
                        };
                        this.modelOptionSec2 = [ ...this.modelOptionSec2, option];
                    }

                }  */
}
handleModelChangeSec2(event){
    this.modelSection1 = event.detail.value;
        this.isAll = false;
       for(const list of this.modelSection1){
        console.log('trim',list);
            if(list === 'All'){
                this.isAll = true;
                this.modelSec2 = [];
                this.modelSection1 = [];
                for(const listTrim of this.modelOptionSec2){
                    this.modelSec2.push(listTrim.value);
                    this.modelSection1.push(listTrim.value);
                }
                console.log('all trim selected',this.modelSec2);
                
            }
           // console.log('All Trim Selected',this.AllTrimsSelected);
        }  
         if(this.isAll === false){
            this.modelSec2 = [];
            for(const list of this.modelSection1){
                this.modelSec2.push(list);
            }

         }
    }

















/*  ---------------Default Image url starts here---------------------------------------------------------- */


  /*  @wire(getRecord, { recordId: this.currentrecordId, fields : [destinationCharge ] })
    wiredModel({ data, error }) {
        if (data) {
        this.destinationCharge = data.fields.Destination_Handling_charge__c.value;
        console.log('this.destinationCharge=>'+this.destinationCharge);
        if(this.destinationCharge > 0 || this.destinationCharge === 0)
            console.log(this.destinationCharge)
        } else{
            this.destinationCharge = null;
        }
        console.log('this.destinationCharge after=>'+this.destinationCharge);
    }   */

    @wire(getRecord, { recordId: "$recordId", fields : [ brand, securityDeposit,zeroDue] })
    wiredModel({ data, error }) {
        if (data) {

        this.brand = this.getBrandValue(data.fields.Brand__c.value);
        this.bHasSecurityDeposit = data.fields.Security_Deposit_Required__c.value;
        console.log('Security deposit'+this.bHasSecurityDeposit);
        console.log(' this.brand=>'+ this.brand);
        this.zeroDue = data.fields.Zero_Due__c.value;
        this.getData();
 
        }
    }
    @wire(getObjectInfo, { objectApiName: OFFER_ELIGIBLE_MODEL_OBJECT })
    offerEligibleModelInfo;

    @wire(getPicklistValues,
        {
            recordTypeId: '$offerEligibleModelInfo.data.defaultRecordTypeId',
            fieldApiName: Terms_Months
        }
    )
    termsmonthValues;
    
    @wire(getPicklistValues,
        {
            recordTypeId: '$offerEligibleModelInfo.data.defaultRecordTypeId',
            fieldApiName: Annual_Miles
        }
    )
    annualMilesValues;
    
    getOEMDetails(){
        getOEMDetails({recordId: this.hasModelId})
        .then((result) => {
            console.log('result from get details==>'+JSON.stringify(result));
            this.offerId = result.Offer__c;
            this.brand = this.getBrandValue(result.Offer__r.Brand__c);
            this.selectedModalYear = result.Year__c;
            this.selectedModalName = result.Name;
            this.selectedModalTrim = result.Trim__c;
            console.log('this.offerId=>'+this.selectedModalYear);
            this.modelId = result.Model_ID__c;
            this.hasSamplePayment = result.Include_Sample_Payment__c;
            this.featuredOffer = result.Featured_Offer__c;
            this.acquisitionFee = result.Acquisition_Fee__c;
            this.additionalCash = result.Additional_Cash__c;
            this.adjustedMSRBWithDH = result.Adjusted_MSRP_with_DH__c;
            this.annualMiles = result.Annual_Miles__c;
            this.baseMonthlyPayment = result.Base_Monthly_Payment__c;
            this.capitalizeCostReduction = result.Capitalized_Cost_Reduction__c;
            this.captiveCashamt = result.Captive_Cash_Lease_Amount__c;
            this.conquestCash = result.Conquest_Cash__c;
            this.dealerContribution = result.Dealer_Contribution__c;
            this.destinationCharge = result.Destination_Handling_charge__c;
            this.loyaltyCash = result.Loyalty_Cash__c;
            this.moneyFactor = result.Money_Factor__c;
            this.invPriceWithDH = result.Invoice_Price_with_DH__c;
            this.netCapitalCost = result.Net_Capital_Cost__c;
            this.termsInmonths = result.Terms_Months__c;
            this.grossMargin = result.Gross_Margin__c;
            //this.bHasSecurityDeposit = result.Security_Deposit_Required__c;
            this.residualFactor = result.Residual_Factor__c;
            this.residualValue = result.Residual_Value__c;
            this.otherCaptiveAmt = result.Other_Captive_Cash_Lease_Amount__c;
            this.totalDueAtsigning = result.Total_Due_At_signing__c;
            this.totalMonthlyPayments = result.Total_Monthly_Payment__c;
            this.imageUrl = result.Default_Image__c;
            this.selectedImage = result.Default_Image__c;
            this.editYear = result.Year__c;
            this.editSegment = result.Segment__c;
            this.editCategory = result.Category__c;
            this.editFamily = result.Family__c;
            this.editModel = result.Name;
            this.editFeatured = result.Featured_Offer__c;
            this.editMSRP = result.MSRP__c;
            this.editFreight = result.Freight_Charge__c;
            this.cpoCash = result.CPO_Cash__c;

           // this.destinationCharge = result.Destination_Handling_charge__c;
            console.log('-------destination charge------',this.destinationCharge);
            console.log('Printing url',this.imageUrl);
            if(this.imageUrl != null || this.imageUrl != '' || this.imageUrl === undefined){
                this.showRemove = true;
            }
            this.getData();
        })
        .catch(error => {
            this.error = error;
          })
    }

    getRecordTYPE(){
        console.log('currentrecordId=>'+this.hasModelId);
        getRecordTYPE({recordId: this.offerId})
        .then((result) => {
            this.recordTypeName = result;
            console.log('result==>'+result);
           /* if(result == 'CPO Special Finance' || result == 'CPO Special Program' || result == 'CPO Special Lease' || result == 'CPO Standard Lease'
            || result == 'CPO Standard Finance' || result == 'New Standard Lease' || result == 'New Special Lease'|| result == 'New Special Finance' || result == 'New Special Program' || result == 'New Standard Finance'){
                */
                if( result == 'CPO Special Lease' || result == 'CPO Standard Lease' || result == 'New Standard Lease' || result == 'New Special Lease'){    
                this.hasShowSamplePayment = true;
                this.enableFeaturedOffer = true;
            }
            if(result == 'CPO Special Lease' || result == 'CPO Standard Lease'){    
                this.showCPO = true;
            }
           /* if(this.isPrism === true){
                this.hasShowSamplePayment = false;
            } */
        })
        .catch(error => {
            this.error = error;
          })
    }

    getBrandValue(brandVal){
        var brandValue;
        if(brandVal == 'A'){
            brandValue= 'Honda';
        }else if(brandVal == 'B'){
            brandValue = 'Acura';
        } else if(brandVal == 'M'){
            brandValue = 'Motorcycle/Powersports';
        }
        return brandValue;
    }

    getData(){
        console.log('this.brand==>inside getData=>'+this.brand);
        getModelDetails({brand : this.brand})
        .then((result) => {
         console.log('year==>'+result.modelYear);
       /*  console.log('modelName==>'+result.modelNameYRWise);
         this.modelNameYRWise = result.modelNameYRWise;
         this.trimModelNameWise = result.trimModelNameWise;
         //modelNameYRWise: for powersports it is segmentYearWise
         this.segmentYearWise = result.modelNameYRWise;
         //trimModelNameWise: for powersports it is categorySegmentWise
         this.categorySegmentWise = result.trimModelNameWise;
 
        
         */
        this.sec1Data = result;
        const segSet = new Set();
        for(const list of  this.sec1Data){
            if(segSet.has(list.Tier1__c) === false){
                segSet.add(list.Tier1__c);
                const option = {
                    label: list.Tier1__c,
                    value: list.Tier1__c
                };
                this.selectYearOptions = [ ...this.selectYearOptions, option ];
            }
            
        }
          /*  for(const list of  result.modelYear){
                console.log('inside for');
                if(list != 'null' && list != '' && list != undefined){
                    console.log('inside if');
                const option = {
                    label: list,
                    value: list
                };
                this.selectYearOptions = [ ...this.selectYearOptions, option ];
            }
            }   */
            this.showSpinner = false;
           
        })
        .catch(error => {
          this.error = error;
        })

        getModelDetailsSec2({
            brand:this.brand
        }).then(result=>{
            console.log('Printing results 1', result);
            if(result.length > 0){
                this.sec2Data = result;
              /*  const segSet = new Set();
                for(const list of  this.sec2Data){
                    if(segSet.has(list.Tier2__c) === false){
                        segSet.add(list.Tier2__c);
                        const option = {
                            label: list.Tier2__c,
                            value: list.Tier2__c
                        };
                        this.segmentOptionsSeg2 = [ ...this.segmentOptionsSeg2, option ];
                    }
                    
                }*/
                this.showSpinner = false;
            }
        }).catch(error=>{
            console.log('this is from error'+error);
            console.log('this is from error'+JSON.stringify(error));

        });
    }

    get options() {
        return [
            {
                label: 'supports',
                value: 'supports',
            },
            {
                label: 'has ability to show',
                value: 'shows',
            },
        ];
    }


    handleModalNameChange(event){
        console.log('this.selectedModalYear==>'+this.selectedModalYear);
         this.selectedModalName = event.detail.value;
         const yr = this.selectedModalYear;
    //this.yearSec2 = yr;
    const yrSet = new Set();
    for(const y of this.selectedModalYear){
        yrSet.add(y);
    }
    console.log('selected yr',this.selectedModalYear);
    const segSet = new Set();
    this.selectTrimOptions = [{"label": "All","value":"All"}]
                for(const list of  this.sec1Data){
                    if(segSet.has(list.Tier4__c) === false && list.Tier4__c != null && list.Tier4__c != '' && list.Tier4__c != undefined && yrSet.has(list.Tier1__c) && list.Tier3__c == this.selectedModalName){
                        segSet.add(list.Tier4__c);
                        const option = {
                            label: list.Tier4__c,
                            value: list.Tier4__c
                        };
                        this.selectTrimOptions = [ ...this.selectTrimOptions, option ];
                    }  
                }
         
       /* console.log('selected value==>'+this.selectedModalName);
        this.modalWiseMap = [];
        for (var key in this.trimModelNameWise) {
            this.modalWiseMap.push({ key: key, value: this.trimModelNameWise[key] });
        }
       // console.log('@@@@==>'+JSON.stringify(this.modalWiseMap ));
       var uniqueArray = new Array();
        for (var obj of this.modalWiseMap) {
            if(obj["key"] == this.selectedModalName){
                var trimNames = obj['value'];
                var temp = new Array();
                temp = trimNames.split(",");
                uniqueArray = temp.filter(function(item, pos) {
                    return temp.indexOf(item) == pos;
                })
            }
        }
        this.selectTrimOptions = [{"label": "All","value":"All"}]
        for(const list of  uniqueArray){
            if(list != 'null' && list != '' && list != undefined){
            const option = {
                label: list,
                value: list
            };
            this.selectTrimOptions = [ ...this.selectTrimOptions, option ];
        }
        }  */
    }
     

    handleModalYrChange(event){
        this.selectedModalYear = event.detail.value; 
        this.selectModelOptions = [];
        this.selectTrimOptions = [];
        this.modelOption = [];
        const options = [];
        const yr = event.detail.value;
    this.yearSec2 = yr;
    const yrSet = new Set();
    for(const yr of this.yearSec2){
        yrSet.add(yr);
    }
    const segSet = new Set();
                for(const list of  this.sec2Data){
                    if(segSet.has(list.Tier3__c) === false && list.Tier3__c != null && list.Tier3__c != '' && list.Tier3__c != undefined && yrSet.has(list.Tier1__c)){
                        segSet.add(list.Tier3__c);
                        const option = {
                            label: list.Tier3__c,
                            value: list.Tier3__c
                        };
                        //this.selectModelOptions = [ ...this.selectModelOptions, option ];
                        options.push(list.Tier3__c);
                    }  
                }
                console.log('printitng sorted options', options.sort());
                options.sort();
                for(let i =0;i<options.length;i++){
                    const option = {
                        label: options[i],
                        value: options[i]
                    };
                    this.selectModelOptions = [ ...this.selectModelOptions, option ];
                }
                this.modelOption= this.selectModelOptions;
        
    /*    console.log('this.selectedModalYear=>'+this.selectedModalYear);
        var selectedYR = event.detail.value;
        var multipleYRS = new Array();
        for (var obj of selectedYR) {
            //console.log('OBJ++>'+obj);
            multipleYRS.push(obj);
        }
        console.log('multipleYRS==>'+multipleYRS);
        this.YearWiseMap = [];
        for (var key in this.modelNameYRWise) {
            this.YearWiseMap.push({ key: key, value: this.modelNameYRWise[key] });
        }
        var uniqueArray = new Array();
        for (var obj of this.YearWiseMap) {
            for (var obj1 of multipleYRS) {
                if(obj["key"] == obj1 ){
                    console.log('obj1=>'+obj1);
                    var maodalNames = obj['value'];
                    var temp = new Array();
                    temp = maodalNames.split(",");
                    uniqueArray = temp.filter(function(item, pos) {
                        return temp.indexOf(item) == pos;
                    })
                }
            }   
        }
        console.log('uniqueArray==>'+uniqueArray);
        for(const list of  uniqueArray){
            if(list != 'null' && list != '' && list != undefined){
            const option = {
                label: list,
                value: list
            };
            this.selectModelOptions = [ ...this.selectModelOptions, option ];
        }
        }*/
    }  
    @api onBack(){
        if(this.openVehicle === true){
            this.openVehicle = false;
        }
    }

    handleTrimChange(event){
        this.selectedModalTrim = event.detail.value; 
      console.log('this.selectedModalTrim==>'+this.selectedModalTrim);
      this.isAll = false;
       for(const list of this.selectedModalTrim){
        console.log('trim',list);
            if(list === 'All'){
                this.isAll = true;
                this.selectedModalTrim = [];
                this.AllTrimsSelected = [];
                for(const listTrim of this.selectTrimOptions){
                    this.selectedModalTrim.push(listTrim.value);
                    this.AllTrimsSelected.push(listTrim.value);
                }
                console.log('all trim selected',this.AllTrimsSelected);
                
            }
           // console.log('All Trim Selected',this.AllTrimsSelected);
        }  
         if(this.isAll === false){
            this.AllTrimsSelected = [];
            for(const list of this.selectedModalTrim){
                this.AllTrimsSelected.push(list);
            }

         }
         console.log('without all trim selected',this.AllTrimsSelected);
         
    /*
      var selectedTrim = event.detail.value;
      var multipleTrims = new Array();
        for (var obj of selectedTrim) {
            console.log('OBJ++>'+obj);
            multipleTrims.push(obj);
        }
        console.log('multipleYRS==>'+multipleTrims.length);
      
        if(this.selectedModalTrim == 'All'){
            var allTrims = new Array();
            this.AllCheck = false;
            for (var obj of this.selectTrimOptions) {
                allTrims.push(obj.value);
            }
            this.AllTrimsSelected = allTrims;
           // console.log('trim==>'+JSON.stringify(allTrims));
        }
        else if(multipleTrims.length > 1){
            var allTrims = new Array();
            this.AllCheck = false;

            for (var obj of this.selectTrimOptions) {
                for (var selected of multipleTrims){
                    if(obj.label == selected){
                        allTrims.push(obj.value);
                    }
                } 
            }
            this.AllTrimsSelected = allTrims;
            console.log('trim==>'+JSON.stringify(allTrims));
         }
        else{
            var allTrims = new Array();
            this.AllCheck = true;
            for (var obj of this.selectTrimOptions) {
                for (var selected of multipleTrims){
                    if(obj.label == selected){
                        allTrims.push(obj.value);
                    }
                } 
            }
            this.AllTrimsSelected = allTrims;   
            console.log('this.selectedModalTrim=>'+this.selectedModalTrim[0]);
            console.log('this.his.selectedModalName=>'+this.selectedModalName);
            console.log('this.selectedModalYear=>'+this.selectedModalYear[0]);    
        }    */
    }
    handleSave(){
        this.showSpinner = true;
        console.log('inside save',this.brand);
        if(this.brand != 'Motorcycle/Powersports'){
        var obj = {};
        obj["Year__c"] = this.selectedModalYear;
        obj["Name"] = this.selectedModalName;
        obj["Trim__c"] = this.selectedModalTrim;
        obj["Featured_Offer__c"] = this.featuredOffer;
        obj["Model_ID__c"] = this.modelId;
        obj["Offer__c"] = this.offerId;
        obj["Include_Sample_Payment__c"] = this.hasSamplePayment;
        obj["Total_Due_At_signing__c"] = this.totalDueAtsigning;
        obj["Residual_Value__c"] = this.residualValue;
        obj["Total_Monthly_Payment__c"] = this.totalMonthlyPayments;

        var obj1 = {};
        obj1["Featured_Offer__c"] = this.featuredOffer;
        obj1["Gross_Margin__c"] = this.grossMargin;
        obj1["Terms_Months__c"] = this.termsInmonths;
        obj1["Acquisition_Fee__c"] = this.acquisitionFee;
        obj1["Dealer_Contribution__c"] = this.dealerContribution;
        obj1["Capitalized_Cost_Reduction__c"] = this.capitalizeCostReduction;
        obj1["Net_Capital_Cost__c"] = this.netCapitalCost;
        obj1["Adjusted_MSRP_with_DH__c"] = this.adjustedMSRBWithDH;
        obj1["Annual_Miles__c"] = this.annualMiles;
        obj1["Residual_Factor__c"] = this.residualFactor;
        obj1["Money_Factor__c"] = this.moneyFactor;
        obj1["Conquest_Cash__c"] = this.conquestCash;
        obj1["Loyalty_Cash__c"] = this.loyaltyCash;
        obj1["Additional_Cash__c"] = this.additionalCash;
        obj1["Base_Monthly_Payment__c"] = this.baseMonthlyPayment;
        obj1["Invoice_Price_with_DH__c"] = this.invPriceWithDH;
        obj1["Captive_Cash_Lease_Amount__c"] = this.captiveCashamt;
        obj1["Other_Captive_Cash_Lease_Amount__c"] = this.otherCaptiveAmt;
        obj1["CPO_Cash__c"] = this.cpoCash;
        this.hasSamplePaymentSectionData = obj1;
       
        this.finalList = {...this.hasSamplePaymentSectionData,...obj}
        console.log('finalList==>'+JSON.stringify(this.finalList));
        console.log('this.AllTrimsSelected==>'+this.AllTrimsSelected);
        console.log('this.selectedModalYear=>'+this.selectedModalYear);
        saveOfferEligibileModelRecord({ records: this.finalList ,offerId: this.offerId, oemodelID: this.hasModelId,years:this.selectedModalYear,Alltrims:this.AllTrimsSelected,recType:this.recordTypeName})
        .then((result) => {
            this.updateData();
            this.showSpinner = false;
         console.log('saved'+result);
         this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: `Record inserted Succesfully!`,
              variant: "success"
            })
          );
        
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.offerId,
                objectApiName: 'Offers__c',
                actionName: 'view'
            },
        });
             
        })
        .catch(error => {
            this.showSpinner = false;
          this.error = error;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: "Error while saving",
              variant: "error"
            })
          );
  
        })

        }
        else{
            if(this.editMode === true){
                this.updatePowerSportData();
            
       
    
        } else{
            var obj = {};
            obj["Category__c"] = this.catSection2;
            obj["Family__c"] = this.familySection2;
            obj["Segment__c"] = this.segSection2;
            console.log('printing obj',obj);
            savePowerSportsRecord({records: obj,offerId: this.offerId, years:this.yearSec2, models: this.modelSec2, recType: this.recordTypeName})
            .then((result) => {
                this.showSpinner = false;
                console.log('saved'+result);
                this.dispatchEvent(
                   new ShowToastEvent({
                     title: "Success",
                     message: `Record inserted Succesfully!`,
                     variant: "success"
                   })
                 );
               
                 this[NavigationMixin.Navigate]({
                   type: 'standard__recordPage',
                   attributes: {
                       recordId: this.offerId,
                       objectApiName: 'Offers__c',
                       actionName: 'view'
                   },
               });
                    
               })
               .catch(error => {
                this.showSpinner = false;
                 this.error = error;
                 this.dispatchEvent(
                   new ShowToastEvent({
                     title: "Error",
                     message: "Error while saving",
                     variant: "error"
                   })
                 );
         
               })
        }
    }

    }
    handleFieldCheck(){

    }

    @api onSave(){
        if(this.editMode === false){
            if(this.brand === 'Motorcycle/Powersports'){
                if(this.modelSec2.length < 1 || this.yearSec2.length < 1 || this.segSection2 === '' || this.segSection2 === null || this.segSection2 === undefined || this.familySection2 === null || this.familySection2 === '' || this.familySection2 === undefined || this.catSection2 === '' || this.catSection2 === null || this.catSection2 === undefined){
                    this.dispatchEvent(
                        new ShowToastEvent({
                          title: "Error",
                          message: `Required Field Missing`,
                          variant: "error"
                        })
                      );
                }else{
                    this.handleSave();
                }
            } else{
                if(this.selectedModalName === null || this.selectedModalName === '' || this.selectedModalName === undefined || this.selectedModalYear.length < 1 || this.AllTrimsSelected.length < 1){
                    this.dispatchEvent(
                        new ShowToastEvent({
                          title: "Error",
                          message: `Required Field Missing`,
                          variant: "error"
                        })
                      );
                } else {
                    this.handleSave();
                }
            }
            
        }
        
        else if(this.editMode === true && this.openVehicle === true && this.isCFO === true && this.brand != 'Motorcycle/Powersports'){
            this.openVehicle = false;
            const selectedEvent = new CustomEvent('valueselected', {
                detail:{
                    value:this.openVehicle
                } 
            });
            //dispatching the custom event
            this.dispatchEvent(selectedEvent);
        }
        else if(this.hasShowSamplePayment === true && this.featuredOffer === true && this.editMode === true && this.openVehicle === false && this.brand != 'Motorcycle/Powersports' && this.hasSamplePayment === false){
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "Error",
                  message: `you can't make a model featured until sample payments are populated`,
                  variant: "error"
                })
              );
        }
        else if(this.editMode === true && this.hasShowSamplePayment === true && this.hasSamplePayment === true && this.openVehicle === false && this.featuredOffer === false && this.brand != 'Motorcycle/Powersports'){
                this.save = true;
                this.onCalculate();
                console.log('printing error message',this.showErrorMgs);
        }
        else if(this.editMode === true && this.hasShowSamplePayment === false && this.openVehicle === false && this.featuredOffer === true && this.brand != 'Motorcycle/Powersports'){
            
            if(this.selectedImage != null && this.selectedImage != '' && this.selectedImage != undefined){
                this.handleSave();
                this.modelError = false;
            }else{
                this.modelError = true;
            }
        
        }
        else if(this.editMode === true && this.hasShowSamplePayment === true && this.hasSamplePayment === true && this.openVehicle === false && this.featuredOffer === true && this.brand != 'Motorcycle/Powersports'){
            console.log('inside all');
            console.log('selected image',this.selectedImage);
            if(this.selectedImage != null && this.selectedImage != '' && this.selectedImage != undefined){
                this.modelError = false;
                this.save = true;
                this.onCalculate();
            } else{
                this.modelError = true;
                this.save = false;
                this.onCalculate();
            }
             

        }
        else if(this.brand === 'Motorcycle/Powersports' && this.editMode === true){
            this.handleSave();
        } else{
            this.handleSave();
        }
            
    }
        
    

    

    handleChange(event){
        var fapiName = event.target.name;
        switch(fapiName){
            case "grossMargin": 
                this.grossMargin = event.target.value;
                break;

            case "featuredOffer": 
                this.featuredOffer = event.target.checked;
                break;

            case "termsInmonths": 
                this.termsInmonths = event.target.value;
                break;

            case "acquisitionFee": 
                this.acquisitionFee = event.target.value;
                break;

            case "dealerContribution": 
                this.dealerContribution = event.target.value;
                break;

            case "capitalizeCostReduction": 
                this.capitalizeCostReduction = event.target.value;
                break;

            case "netCapitalCost": 
                this.netCapitalCost = event.target.value;
                break;

            case "adjustedMSRBWithDH": 
                this.adjustedMSRBWithDH = event.target.value;
                break;
                
            case "residualFactor": 
                this.residualFactor = event.target.value;
                break;
            
            case "annualMiles": 
                this.annualMiles = event.target.value;
                break;

            case "moneyFactor": 
                this.moneyFactor = event.target.value;
                break;

            case "conquestCash": 
                this.conquestCash = event.target.value;
                break;

            case "loyaltyCash": 
                this.loyaltyCash = event.target.value;
                break;

            case "captiveCashamt": 
                this.captiveCashamt = event.target.value;
                break;

            case "otherCaptiveAmt": 
                this.otherCaptiveAmt = event.target.value;
                break;
                

            case "additionalCash": 
                this.additionalCash = event.target.value;
                break;

            case "baseMonthlyPayment": 
                this.baseMonthlyPayment = event.target.value;
                break;
            case "invPriceWithDH":
                this.invPriceWithDH = event.target.value;
                break;

            case "destinationCharge":
                this.destinationCharge = event.target.value;
                break;
            case "cpoCash":
                this.cpoCash = event.target.value;
            
        }
        
        var obj = {};
        obj["Featured_Offer__c"] = this.featuredOffer;
        obj["Gross_Margin__c"] = this.grossMargin;
        obj["Terms_Months__c"] = this.termsInmonths;
        obj["Acquisition_Fee__c"] = this.acquisitionFee;
        obj["Dealer_Contribution__c"] = this.dealerContribution;
        obj["Capitalized_Cost_Reduction__c"] = this.capitalizeCostReduction;
        obj["Net_Capital_Cost__c"] = this.netCapitalCost;
        obj["Adjusted_MSRP_with_DH__c"] = this.adjustedMSRBWithDH;
        obj["Annual_Miles__c"] = this.annualMiles;
        obj["Residual_Factor__c"] = this.residualFactor;
        obj["Money_Factor__c"] = this.moneyFactor;
        obj["Conquest_Cash__c"] = this.conquestCash;
        obj["Loyalty_Cash__c"] = this.loyaltyCash;
        obj["Additional_Cash__c"] = this.additionalCash;
        obj["Base_Monthly_Payment__c"] = this.baseMonthlyPayment;
        obj["Invoice_Price_with_DH__c"] = this.invPriceWithDH;
        obj["Captive_Cash_Lease_Amount__c"] = this.captiveCashamt;
        obj["Other_Captive_Cash_Lease_Amount__c"] = this.otherCaptiveAmt;
        obj["Destination_Handling_charge__c"] = this.destinationCharge;
        
        this.hasSamplePaymentSectionData = obj;
        console.log('obj==>'+JSON.stringify(this.hasSamplePaymentSectionData));
    }

    handleChangePS(event){
        var fapiName = event.target.name;
        console.log('printing name',fapiName);
        switch(fapiName){
            case "Featured": 
                this.editFeatured = event.target.checked;
                console.log('printing segment',this.editFeatured);
                break;

            case "MSRP": 
                this.editMSRP = event.target.value;
                console.log('printing category',this.editMSRP);
                break;

            case "FreightCharge": 
                this.editFreight = event.target.value;
                break;
        }
        
        var obj = {};
        obj["Segment__c"] = this.editSegment;
        obj["Category__c"] = this.editCategory;
        obj["Freight_Charge__c"] = this.editFreight;
        obj["MSRP__c"] = this.editMSRP;
        obj["Featured_Offer__c"] = this.editFeatured;
        obj["Id"] = this.hasModelId;
        
        this.powerSportData = obj;
        console.log('obj==>'+JSON.stringify(this.hasSamplePaymentSectionData));
    }

    onPaymentClick(event){
        this.hasSamplePayment = event.target.checked;
        
    }

    
    onCalculate(){
      var calculatedArrayValues = [];
      console.log('brand ==>',this.brand);
      console.log('base montly payment ==>',this.baseMonthlyPayment);
      console.log('dealer contribution ==>',this.dealerContribution);
      console.log('destination charge ==>',this.destinationCharge);
      //this.destinationCharge = parseInt(this.destinationCharge);
      calculatedArrayValues = calculateLease(
            this.brand,
            this.baseMonthlyPayment,
            this.capitalizeCostReduction,// (this.capitalizeCostReduction).toString(),
            this.netCapitalCost,//(this.netCapitalCost).toString(),
            this.acquisitionFee,//(this.acquisitionFee).toString(),
          this.bHasSecurityDeposit,
          this.termsInmonths, //this.iTerm,
          this.annualMiles,
          this.residualFactor,//(this.residualFactor).toString(),
          this.adjustedMSRBWithDH,
          this.grossMargin,//(this.grossMargin).toString(),
          this.conquestCash,// bonus
          this.loyaltyCash,
          this.captiveCashamt,
          this.otherCaptiveAmt,
          this.additionalCash,
          this.dealerContribution,// (this.dealerContribution).toString(),
          this.invPriceWithDH,//(this.invPriceWithDH).toString(),
          this.zeroDue,// zero due
          this.editMSRP
          );
          //console.log('calculatedArrayValues==>'+calculatedArrayValues[0]);
          this.totalDueAtsigning = calculatedArrayValues[1];
          this.residualValue = calculatedArrayValues[2];
          this.totalMonthlyPayments = calculatedArrayValues[3];
         
          if(calculatedArrayValues[0]!= null || calculatedArrayValues[0]!= ''){
            this.showErrorMgs = true;
            this.errorMgs = calculatedArrayValues[0];
            this.ValidationErrorMessage = this.errorMgs.split("<br>");
            console.log('Error occurred==>'+this.ValidationErrorMessage);
  
          }
          if(this.errorMgs[0] ==='' || this.errorMgs[0] === null || this.errorMgs[0] === undefined){
            this.showErrorMgs = false;
          }
          console.log('save',this.save);
          console.log('errormsg',this.showErrorMgs);
          if(this.showErrorMgs === false && this.save === true){
            if(this.selectedImage == null || this.selectedImage == '' || this.selectedImage == undefined){
                this.modelError = true;
            }else{
                this.handleSave();
                this.save = false;
            }
            
            
          }
    }

    handleSelection(event){
        console.log('selected=>'+ event.detail.value);
        if(event.detail.value == 'section1'){
            this.section1 = true;
            this.section2 = false;
        }
        else if(event.detail.value == 'section2'){
            this.getModelDetailsSegmentSec2();
            this.section2 = true;
            this.section1 = false;
        }
    }

        CreateDateaForPowerSport1(){
            console.log('Printing data',this.powerSportData);
            console.log('printing sec 2 data',this.sec2Data);
            for(let i = 0; i< this.sec2Data.length;i++){

            }

        }

    handlePsSec1YrChange(event){
        this.SelectFamilySec1Options = [];
        this.SelectCategorySec1Options = [];
        this.SelectModalSec1Options =[];
        this.SelectSegmentSec1Options = [];
        this.yearSec2 = event.detail.value;
        this.SelectedPsSec1Year = event.detail.value;

        var selectedYR = this.SelectedPsSec1Year;
        var multipleYRS = new Array();
        for (var obj of selectedYR) {
            multipleYRS.push(obj);
        }
        console.log('this.sec2Data==>'+this.sec2Data);
        const segSet = new Set();
        for(const list of  this.sec2Data){
            for (var obj1 of multipleYRS) {
                if(segSet.has(list.Tier2__c) === false &&  list.Tier2__c != null && list.Tier2__c != '' && list.Tier2__c != undefined &&  obj1 == list.Tier1__c){
                    console.log('inside cat condition'+segSet);
                    segSet.add(list.Tier2__c);
                    const option = {
                        label: list.Tier2__c,
                        value: list.Tier2__c
                    };
                    this.SelectSegmentSec1Options = [ ...this.SelectSegmentSec1Options, option ];
                }
            }
            
        }

       
       /*
        var selectedYR = this.yearSec2 ;
        console.log('this.selectedYR=>'+selectedYR);
        var multipleYRS = new Array();
        for (var obj of selectedYR) {
            //console.log('OBJ++>'+obj);
            multipleYRS.push(obj);
        }
        
        this.YearWiseMap = [];
        for (var key in this.segmentYearWise) {
            this.YearWiseMap.push({ key: key, value: this.segmentYearWise[key] });
        }
        //console.log('YearWiseMap==>'+this.YearWiseMap);
        var uniqueArray = new Array();
        var segments = '';
        for (var obj of this.YearWiseMap) {
            for (var obj1 of multipleYRS) {
                //console.log('obj["key"]=>'+obj["key"]+'===='+obj1);
                var temp = new Array();
                if(obj["key"] == obj1 ){
                   // console.log('obj1=>'+obj1);
                    segments = segments + ','+obj['value'];
                    //console.log('segments=>'+segments);
                    temp = segments.split(",");
                    uniqueArray = temp.filter(function(item, pos) {
                        return temp.indexOf(item) == pos;
                    })
                }
            }             
        }
        console.log('uniqueArray==>'+uniqueArray);
        for(const list of  uniqueArray){
            if(list != 'null' && list != '' && list != undefined){
            const option = {
                label: list,
                value: list
            };
            this.SelectSegmentSec1Options = [ ...this.SelectSegmentSec1Options, option ];
        }
        }           */
    }

    handlePsSec1SegmentChange(event){
        this.segSection2 = event.detail.value;
        const seg = event.detail.value;
        var selectedYR = this.SelectedPsSec1Year;
        var multipleYRS = new Array();
        for (var obj of selectedYR) {
            multipleYRS.push(obj);
        }
        console.log('this.sec2Data==>'+this.sec2Data);
        const segSet = new Set();
        for(const list of  this.sec2Data){
            for (var obj1 of multipleYRS) {
                if(segSet.has(list.Tier3__c) === false &&  list.Tier3__c != null && list.Tier3__c != '' && list.Tier3__c != undefined && list.Tier2__c === seg && obj1 == list.Tier1__c){
                    console.log('inside cat condition'+segSet);
                    segSet.add(list.Tier3__c);
                    const option = {
                        label: list.Tier3__c,
                        value: list.Tier3__c
                    };
                    this.SelectCategorySec1Options = [ ...this.SelectCategorySec1Options, option ];
                }
            }
            
        }
        
    }  

    handlePsSec1CategoryChange(event){
        this.catSection2 = event.detail.value
        this.SelectFamilySec1Options = [];
        //const cat = event.detail.value;
        var selectedYR = this.SelectedPsSec1Year;
        var multipleYRS = new Array();
        for (var obj of selectedYR) {
            multipleYRS.push(obj);
        }
        console.log('this.sec2Data==>'+this.sec2Data);
        const segSet = new Set();
        for(const list of  this.sec2Data){
            for (var obj1 of multipleYRS) {
                if(segSet.has(list.Tier4__c) === false && list.Tier4__c != null && list.Tier4__c != '' && list.Tier4__c != undefined && list.Tier3__c === this.catSection2 && list.Tier2__c === this.segSection2 && obj1 == list.Tier1__c){
                    console.log('inside cat condition'+segSet);
                    segSet.add(list.Tier4__c);
                    const option = {
                        label: list.Tier4__c,
                        value: list.Tier4__c
                    };
                    this.SelectFamilySec1Options = [ ...this.SelectFamilySec1Options, option ];
                }
            }
            
        }
      
    }

    handlePsSec1FamilyChange(event){
        this.familySection2 = event.detail.value;
        this.SelectModalSec1Options = [];
        this.SelectModalSec1Options = [{"label": "All","value":"All"}];
        var selectedYR = this.SelectedPsSec1Year;
        var multipleYRS = new Array();
        for (var obj of selectedYR) {
            multipleYRS.push(obj);
        }
        console.log('this.sec2Data==>'+this.sec2Data);
        const segSet = new Set();
        for(const list of  this.sec2Data){
            for (var obj1 of multipleYRS) {
                if(segSet.has(list.Tier5__c) === false && list.Tier5__c != null && list.Tier5__c != '' && list.Tier5__c != undefined &&  list.Tier4__c === this.familySection2 && list.Tier3__c === this.catSection2 && list.Tier2__c === this.segSection2 && obj1 == list.Tier1__c){
                    console.log('inside cat condition'+segSet);
                    segSet.add(list.Tier5__c);
                    const option = {
                        label: list.Tier5__c,
                        value: list.Tier5__c
                    };
                    this.SelectModalSec1Options = [ ...this.SelectModalSec1Options, option ];
                }
            }
            
        }
      


    }

    handlePsSec1ModalChange(event){
        
        this.modelSection1 = event.detail.value;
        this.isAll = false;
       for(const list of this.modelSection1){
        console.log('trim',list);
            if(list === 'All'){
                this.isAll = true;
                this.modelSec2 = [];
                this.modelSection1 = [];
                for(const listTrim of this.SelectModalSec1Options){
                    this.modelSec2.push(listTrim.value);
                    this.modelSection1.push(listTrim.value);
                }
                console.log('all trim selected',this.modelSec2);
                
            }
           // console.log('All Trim Selected',this.AllTrimsSelected);
        }  
         if(this.isAll === false){
            this.modelSec2 = [];
            for(const list of this.modelSection1){
                this.modelSec2.push(list);
            }

         }
    }
  
}
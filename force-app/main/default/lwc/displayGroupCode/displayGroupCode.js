import { LightningElement, track, wire, api} from 'lwc';

import handleEditRegion from '@salesforce/apex/OM_EditRegionHandler.handleEditRegion' //importing method of apex class to js
import saveCalloutDetails from '@salesforce/apex/OM_EditRegionHandler.saveCalloutDetails' //importing method of apex class to js
import { getRecord } from 'lightning/uiRecordApi';
import OFFER_OBJECT from '@salesforce/schema/Offers__c'
import Off_Availability_FIELD from '@salesforce/schema/Offers__c.Offer_Availability__c';
import { NavigationMixin } from 'lightning/navigation';
import Brand_FIELD from '@salesforce/schema/Offers__c.Brand__c'
import Status_FIELD from '@salesforce/schema/Offers__c.Status__c'
import RecordTypeName_FIELD from '@salesforce/schema/Offers__c.RecordType.Name'
import ProfileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';
import GroupType_FIELD from '@salesforce/schema/Offers__c.Group_Type__c'
//Added by Manohar to control Button for Inbound offers
import SYNCED_WITH_PRISM_FIELD from '@salesforce/schema/Offers__c.Synched_with_PRISM__c';

export default class DisplayGroupCode extends NavigationMixin(LightningElement){

    @track isLoading = false;
    objectApiName = OFFER_OBJECT;
    @track showGroupDetails=false;
    @track showNoData=false;
    @track isShowModal= false;
    @wire(handleEditRegion ) apexMethod; //calling apex class method
    @wire(saveCalloutDetails) apexMethod; //calling apex class method
    @track groupDetails;
    @track stateName=[];
    @track groupCode=[];
    @api recordId;
    @track offerAvailability;
    @track showErrorModal = false;
    grouptype;
    brand;
    // @track brandNameValue;
    @track showNationalErr = false;
    @track showfieldMadatoryErr = false;
    @track fieldsName = [Brand_FIELD, GroupType_FIELD,Status_FIELD];
    @track options;
    @track showErrorMsg=false;
    selectedGroupType;
    selectedBrand;
    userProfileName;
    offerStatus;
    offerStatusValue;
    @track offerRecordTypeName;
    @track hideEditRegionButton = false;
    syncedWithPrism=false;

    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
                 console.log('@@@@@ userProfileName name'+this.userProfileName);
            }
        }
    }


    getRegionalDetails(event){
        this.isLoading = true;
        this.showGroupDetails=false;
        this.groupDetails=[]; 
        //this.selectedGroupType=event.detail.value;
              
        this.getGroupInfo(this.selectedGroupType, this.selectedBrand);
    }
    
    brandChange(event){
        this.selectedBrand=event.detail.value;
        console.log('this.selectedBrand-->>'+this.selectedBrand);
        
    }

    groupTypeChange(event) {
        this.selectedGroupType=event.detail.value;
    }

    //Added by disha on 17-02-2023
    @wire(getRecord, { recordId: "$recordId", fields : [Off_Availability_FIELD,Brand_FIELD,GroupType_FIELD,Status_FIELD,RecordTypeName_FIELD,SYNCED_WITH_PRISM_FIELD]})
    wiredModel({ data, error }) {
        if (data) {
        this.offerAvailability = data.fields.Offer_Availability__c.value;
        this.grouptype = data.fields.Group_Type__c.value;
        this.brand = data.fields.Brand__c.value;
        this.offerStatus = data.fields.Status__c.value;
        this.offerRecordTypeName = data.fields.RecordType.displayValue;
        this.brandNameValue = this.brand;
        this.offerStatusValue = this.offerStatus;
        this.selectedBrand=this.brandNameValue;
        this.selectedGroupType = this.grouptype;
        this.syncedWithPrism = data.fields.Synched_with_PRISM__c.value;
        console.log('@@@ offerStatus 1'+this.offerStatusValue);
        console.log('@@@ userProfileName 1'+this.userProfileName);
        console.log('@@@ offerRecordTypeName 1'+this.offerRecordTypeName);
        console.log('@@@ syncedWithPrism 1'+this.syncedWithPrism);
        if(this.offerStatusValue !== 'WIP' && this.offerStatusValue !=='Validated' || this.syncedWithPrism == true){
                this.hideEditRegionButton = true;
               }
                if((this.userProfileName ==='B2C_OM_AHM_AIG' && (this.offerRecordTypeName !=='New Special Finance' && this.offerRecordTypeName !=='New Special Lease' && this.offerRecordTypeName !=='New Special Program' && this.offerRecordTypeName !=='New Standard Finance' && this.offerRecordTypeName !=='New Standard Lease'))){
                    this.hideEditRegionButton = true;
                } else if(((this.userProfileName ==='B2C_OM_AHM_CPO') && (this.offerRecordTypeName !=='CPO Special Finance' && this.offerRecordTypeName !=='CPO Special Lease' && this.offerRecordTypeName !=='CPO Special Program' && this.offerRecordTypeName !=='CPO Standard Finance' && this.offerRecordTypeName !=='CPO Standard Lease'))){
                    this.hideEditRegionButton = true;
                }  else if((this.userProfileName ==='B2C_OM_PS' && (this.offerRecordTypeName !=='Power Sports AHFC' && this.offerRecordTypeName !=='Power Sports Bonus Bucks' && this.offerRecordTypeName !=='Power Sports Generic' && this.offerRecordTypeName !=='Power Sports Honda Card'))){
                    this.hideEditRegionButton = true;
                } else if (this.userProfileName ==='B2C_OM_ReadOnly'){
                    this.hideEditRegionButton = true;
                } 
                console.log('@@@ hideEditRegionButton 1'+this.hideEditRegionButton);
       }
    }

    showModalBox(event) {
        this.isShowModal=true;
        this.showGroupDetails=false;

    }
    getGroupInfo(groupType,offBrand) { 
        this.isLoading = true;
        this.showNoData=false;
        
        
            console.log('Inside handleeditRegion');
            handleEditRegion({offerGroupType:groupType,offerBrand:offBrand}).then(result => {
                if(result!=null && result!='NO DATA' && result!='FAILED' && result!='ERROR'){
                    console.log(JSON.parse(result));
                    this.selectedGroupType = groupType;
                    this.groupDetails=JSON.parse(result);
                   // console.log('stringiy'+JSON.stringify(this.sortDetails));                    
                    this.groupDetails = this.groupDetails.sort((a, b) => {
                        if (a.desc < b.desc) {
                          return -1;
                        }
                      });
                      console.log('after sort'+this.groupDetails); 
                    this.isLoading = false;
                    this.showGroupDetails=true;
                }else if(result=='NO DATA'){
                    this.isShowModal=true;
                    this.isLoading = false;
                    this.showGroupDetails=false;
                    this.showNoData=true;
                }
                }) .catch(); 

        
    }


    hideModalBox(event) {
        this.isShowModal=false;
    }

    handleSelectAll(event){
           
        this.stateName=[];
        this.groupCode=[];
        const toggleList = this.template.querySelectorAll('[data-id^="toggle"]');        
        for (const toggleElement of toggleList) {
            toggleElement.checked = event.target.checked;         
        }
      
        for(let i = 0; i < toggleList.length; i++) {
            if(toggleList[i].checked ) { 
                console.log('Checked value'+toggleList[i]);
                this.stateName.push(toggleList[i].name);
                this.groupCode.push(toggleList[i].value);
            }
        }
    }
    handleChange(event){
         if(event.target.checked){
            this.stateName.push(event.target.name);
            this.groupCode.push(event.target.value);

         }else{

            if(this.stateName.indexOf(event.target.name) !== -1) {
                this.stateName.splice(this.stateName.indexOf(event.target.name), 1);
            }
            if(this.groupCode.indexOf(event.target.value) !== -1) {
                this.groupCode.splice(this.groupCode.indexOf(event.target.value), 1);
            }           
         }
    }

    saveDetails(event){
        const stateNamestr=this.stateName.toString();
        const groupCodestr=this.groupCode.toString();
        this.isLoading = true;
        saveCalloutDetails({stateName:stateNamestr,groupCode:groupCodestr,recordId:this.recordId,offGroupType:this.selectedGroupType,offBrand:this.selectedBrand}).then(result => {
        console.log('result: '+result);
        if(result=='SUCCESS'){
            this.isShowModal=false;
            this.isLoading = false;
            //location.reload();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Offers__c',
                    actionName: 'view'
                },
            });
        }else{
            this.showErrorModal = true;
            this.showErrorMsg=true;
            this.isShowModal=false;
            this.isLoading = false;
        }
        }) .catch();  

    }

    //Added by disha on 17-02-2023
    hideErrorModal(event){
        this.showErrorModal = false;
    }
}
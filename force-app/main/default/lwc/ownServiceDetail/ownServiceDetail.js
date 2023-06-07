import { LightningElement, api, track } from 'lwc';

export default class OwnServiceDetail extends LightningElement {

    @api selectedRecord;

    dateLabel;
    nicknameLabel;
    servicesPerformed = '';
    otherString;

    //MergedListSort
    // This is to populate the record based of off data retrieved either from sales force or via api.
    @track mServiceDate
    @track mMiles
    @track mServiceFacility
    @track mOther
    @track mNotes
    @track mServices
    @track mName
    // End Get Icon


    handleReturnToList(){
        this.dispatchEvent(new CustomEvent("event",{detail: ''}));
    }

    initialize = async () => {
        this.context = await getContext();
        //console.log("Context");
        //console.log(JSON.stringify(this.context));
    }

    handlePrintRecord(){
        //console.log("Print Service");
    }

    connectedCallback(){
        this.dateLabel = "Service Record: " + this.selectedRecord.Service_Date__c;
        this.nicknameLabel = this.selectedRecord.Nickname__c;
        
        this.otherString = "Other: " + this.selectedRecord.Other__c;

        if(this.selectedRecord.Oil_Change__c == true){
            this.servicesPerformed += "Oil Change";
        }
        if(this.selectedRecord.Scheduled_Maintenance__c == true){
            if(this.servicesPerformed.length === 0)
            {
                this.servicesPerformed = "Scheduled Maintenance";
            }
            else this.servicesPerformed += ", Scheduled Maintenance";
            
        }
        if(this.selectedRecord.Tire_Rotation__c == true){
            if(this.servicesPerformed.length === 0)
            {
                this.servicesPerformed = "Tire Rotation";
            }
            else this.servicesPerformed += ", Tire Rotation";
        }
        if(this.selectedRecord.Multi_Point_Inspection__c == true){
            if(this.servicesPerformed.length === 0)
            {
                this.servicesPerformed = "Multipoint Inspection";
            }
            else this.servicesPerformed += ", Multipoint Inspection";
        }

    }

}
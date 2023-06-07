import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    createRecord
} from 'lightning/uiRecordApi';
import {
    updateRecord
} from 'lightning/uiRecordApi';
import {
    deleteRecord
} from 'lightning/uiRecordApi';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import {
    OwnBaseElement
} from 'c/ownBaseElement';
import {
    ISGUEST,
    getContext_fromBrowser,
    getContext
} from 'c/ownDataUtils';
import ID_FIELD from '@salesforce/schema/Product_Service_Note__c.Id';
import PRODUCT_SERVICE_NOTE_OBJECT from '@salesforce/schema/Product_Service_Note__c';
import DATE_FIELD from '@salesforce/schema/Product_Service_Note__c.Service_Date__c';
import COST_FIELD from '@salesforce/schema/Product_Service_Note__c.Total_Cost__c';
import SERVICE_FACILITY_FIELD from '@salesforce/schema/Product_Service_Note__c.Location__c';
import MILEAGE_FIELD from '@salesforce/schema/Product_Service_Note__c.Usage__c';
import OIL_CHANGE_FIELD from '@salesforce/schema/Product_Service_Note__c.Oil_Change__c';
import TIRE_ROTATION_FIELD from '@salesforce/schema/Product_Service_Note__c.Tire_Rotation__c';
import SCHEDULED_MAINTENANCE_FIELD from '@salesforce/schema/Product_Service_Note__c.Scheduled_Maintenance__c';
import ALIGNMENT_FIELD from '@salesforce/schema/Product_Service_Note__c.Alignment__c';
import BRAKES_FIELD from '@salesforce/schema/Product_Service_Note__c.Brakes__c';
import MULTI_POINT_INSPECTION_FIELD from '@salesforce/schema/Product_Service_Note__c.Multi_Point_Inspection__c';
import OTHER_FIELD from '@salesforce/schema/Product_Service_Note__c.Others__c';
import OTHER_TEXT_FIELD from '@salesforce/schema/Product_Service_Note__c.Other__c';
import SERVICE_NOTE_FIELD from '@salesforce/schema/Product_Service_Note__c.Note__c';
import OWNERSHIP_FIELD from '@salesforce/schema/Product_Service_Note__c.Ownership__c';
import OPERATING_HOURS_FIELD from '@salesforce/schema/Product_Service_Note__c.Operating_Hours__c';

import {
    NavigationMixin
} from "lightning/navigation";


export default class OwnAddServiceRecord extends OwnBaseElement {
    oilChange;
    oilcheckLabel;
    tireRotationLabel;
    scheduledMaintenanceLabel;
    alignmentLabel;
    brakesLabel;
    multiPointInspectionLabel;
    othersLabel;
    tiresLabel;
    fullServiceLabel;
    batteryLabel;
    tuneUpPackagesLabel;
    repairsLabel;
    endOfSeasonMaintenanceLabel;
    dateOfService = '';
    totalCost = '';
    serviceFacility = '';
    mileage = '';
    textarea1;
    textarea2 = '';
    displayError = false;
    submitButtonClick = false;
    isUpdateRecord = false;
    ownership;

    @api recordId;
    @api objectApiName;
    @track error;

    @api contentId;
    guest = true;
    @track isGuest = ISGUEST;
    @track displayHonda = false;
    @track displayPowerSports = false;

    @track displayPowerEquipment = false;
    powerEquipmentTuneUpText = 'Pre-Season Tune-Up';

    @track displayMarine = false;
    @api context;

    @track imgUrl;
    @track title = 'Add a New Service Record';

    @track productTypeText = 'VEHICLE';



    connectedCallback() {
       // console.log('Passed Record ', sessionStorage.getItem('editRecord'));
       // console.log('Passed Record Image', sessionStorage.getItem('productImg'));
        this.imgUrl = sessionStorage.getItem('productImg');
        this.initialize();
    }

    initialize = async () => {

        const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
      //  console.log('Local context: ', context);
        // //    this.context = await getProductContext('');
        //this.context = await getContext_fromBrowser('');
        this.context = await getContext('');
       // console.log('Context: ', JSON.stringify(this.context));
        //console.log('context=', JSON.stringify(this.context));
        this.division = this.context.product.division;
        //console.log('context123', JSON.stringify(this.division));
        if (this.division === 'Acura' || this.division === 'Honda') {
            this.displayAutos = true;
        } else if (this.division === 'Motorcycle/Powersports') {
            this.displayPowerSports = true;
        } else if (this.division === 'Powerequipment' || this.division === 'Marine') {
            this.displayPowerEquipmentOrMarine = true;
            
            if (this.division == 'Powerequipment') {
                this.displayPowerEquipment = true;
            } else if (this.division == 'Marine') {
                this.displayMarine = true;
            }
        }
        this.ownership = (this.context.product.ownershipId) ? this.context.product.ownershipId : undefined;
       // console.log('Ownership ' + this.ownership);

        this.setProductTypeText();
    }

    @api
    get subTitle() {
        if (this.context) {
            return this.context.product.nickname ? this.context.product.nickname : this.context.product.year + ' ' + this.context.product.model;
        } else {
            return 'test';
        }
    }

    @track info = {};
    checkboxChecked = false;
    fields = {};
    @wire(getObjectInfo, {
        objectApiName: PRODUCT_SERVICE_NOTE_OBJECT
    })
    fieldLabelName({
        data,
        error
    }) {
        if (data) {
            //console.log('data.fields ' , JSON.stringify(data.fields));
/*             data.fields.forEach(field =>{
                console.log(field.apiName);
            }) */
            for (let field in data.fields){
                //console.log(data.fields[field].apiName);
            }
            this.oilcheckLabel = data.fields.Oil_Change__c.label;
            this.tireRotationLabel = data.fields.Tire_Rotation__c.label;
            this.scheduledMaintenanceLabel = data.fields.Scheduled_Maintenance__c.label;
            this.alignmentLabel = data.fields.Alignment__c.label;
            this.brakesLabel = data.fields.Brakes__c.label;
            this.multiPointInspectionLabel = data.fields.Multi_Point_Inspection__c.label;
            this.othersLabel = data.fields.Others__c.label;
            this.tiresLabel = data.fields.Tires__c.label;
            this.fullServiceLabel = data.fields.Full_Service__c.label;
            this.batteryLabel = data.fields.Battery__c.label;
            this.tuneUpPackagesLabel = data.fields.Tune_Up_Packages__c.label;
            this.repairsLabel = data.fields.Repairs__c.label;
            this.endOfSeasonMaintenanceLabel = data.fields.End_of_Season_Maintenance__c.label;
          //  console.log("oil test:",data.fields.Oil_Change__c.label);
        } else if (error) {
          //  console.log("error=", error);
        }
    };

    constructor() {
        super();

        let serviceRecord = JSON.parse(sessionStorage.getItem('editRecord'));
      //  console.log('SERVICERECORD', this.serviceRecord);
        /* let serviceRecord = {
             "Service_Date__c": "2021-12-31",
             "Usage__c": 63326,
             "Location__c": "Belarus",
             "Note__c": "The needles in the red",
             "Name": "Test Note 1 for comparison",
             "Oil_Change__c": true,
             "Scheduled_Maintenance__c": false,
             "Brakes__c": true,
             "Tire_Rotation__c": false,
             "Alignment__c": true,
             "Multi_Point_Inspection__c": false,
             "Other__c": "Something or other",
             "Others__c": false,
             "Id": "a1A010000007EduEAE"
         }; */
        if (serviceRecord) {
            this.title = 'Edit Service Record';
            this.isUpdateRecord = true;
           // console.log('ISUPDATERECORD SET TO: ', this.isUpdateRecord);
            for (var key in serviceRecord) {
                this.fields[key] = serviceRecord[key];
              //  console.log('Key ' + key + ' This Field Key ' + this.fields[key] + ' Service Record key ' + serviceRecord[key]);

                if (key == 'Others__c'){
                    console.log('Setting Others__c');
                    this.checkboxChecked = serviceRecord[key];
                }
            }
            this.submitButtonClick = this.dateOfServiceValue && this.serviceFacilityValue;
        }
    }

    get dateOfServiceValue() {
        return this.fields.Service_Date__c;
    }
    get totalCostValue() {
        return this.fields.Total_Cost__c;
    }
    get serviceFacilityValue() {
        return this.fields.Location__c;
    }
    get mileageValue() {
        return this.fields.Usage__c;
    }
    get operatingHoursValue() {
        return this.fields.Operating_Hours__c;
    }
    get oilChangeValue() {
      //  console.log("checkbox value of oil Change:" + this.fields.Oil_Change__c);
        return this.fields.Oil_Change__c;
    }
    get tireRotationValue() {
        return this.fields.Tire_Rotation__c;
    }
    get scheduledMaintenanceValue() {
        return this.fields.Scheduled_Maintenance__c;
    }
    get AlignmentValue() {
        return this.fields.Alignment__c;
    }
    get brakesValue() {
       // console.log("checkbox value of brake:" + this.fields.Brakes__c);
        return this.fields.Brakes__c;
    }
    get multiPointInspectionValue() {
        return this.fields.Multi_Point_Inspection__c;
    }
    get otherValue() {
        return this.fields.Others__c;
    }
    get textarea1Value() {
        return this.fields.Other__c;
    }
    get textarea2Value() {
        return this.fields.Note__c;
    }
    get tiresValue() {
        return this.fields.Tires__c;
    }
    get fullServiceValue() {
        return this.fields.Full_Service__c;
    }
    get batteryValue() {
        return this.fields.Battery__c;
    }
    get tuneUpPackagesValue() {
        return this.fields.Tune_Up_Packages__c;
    }
    get repairsValue() {
        return this.fields.Repairs__c;
    }
    get endOfSeasonMaintenanceValue() {
        return this.fields.End_of_Season_Maintenance__c;
    }
    handleBlur(event) {

        let fieldName = event.target.getAttribute('data-id');
        let selectedValue = event.target.value;
        let checkboxvalue = event.target.checked;


        if (fieldName === 'Service_Date__c') {
          //  console.log("selected date=" + selectedValue);
            if (!selectedValue) {
           //     console.log("Service date handle blur:" + this.selectedValue);
                //this.showMessage('Error', 'Please enter service date.', 'error');
                this.submitButtonClick = false;
            } else {
                if (this.serviceFacilityValue) {
                    this.submitButtonClick = true;
                } else {
                    this.submitButtonClick = false;
                }
            }
            this.fields[fieldName] = selectedValue;
        } else if (fieldName === 'Total_Cost__c') {
            if (selectedValue === null) {
                selectedValue = 0.00;
            }
          //  console.log("selected Cost=" + selectedValue);
            this.totalCost = selectedValue;
            this.fields[fieldName] = selectedValue;
        } else if (fieldName === 'Location__c') {
            if (selectedValue) {
                this.displayError = false;

                if (this.dateOfServiceValue) {
                    this.submitButtonClick = true;
                } else {
                    this.submitButtonClick = false;
                }
            } else {
             //   console.log("Service facility handle blur:");
                // this.serviceFacilityCheck = true;
                this.displayError = true;
                //this.showMessage('Error', 'Please enter service facility.', 'error');
                this.submitButtonClick = false;
            }
            this.fields[fieldName] = selectedValue;
        } else if (fieldName === 'Usage__c') {
            this.fields[fieldName] = selectedValue;
        } else if (fieldName === 'Operating_Hours__c') {
            this.fields[fieldName] = selectedValue;
        } else if (fieldName === 'Oil_Change__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Tire_Rotation__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Scheduled_Maintenance__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Alignment__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Brakes__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Multi_Point_Inspection__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Tires__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Full_Service__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Battery__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Tune_Up_Packages__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Repairs__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'End_of_Season_Maintenance__c') {
            this.fields[fieldName] = checkboxvalue;
        } else if (fieldName === 'Other__c') {
            this.fields[fieldName] = selectedValue;
        } else if (fieldName === 'Note__c') {
            this.fields[fieldName] = selectedValue;
        } else if (fieldName === 'Others__c') {
            this.fields[fieldName] = checkboxvalue;
            this.checkboxChecked = event.target.checked;
        //    console.log("others checkbox value :" + this.checkboxChecked);
        }

    }

    get submitButtonClassHere() {
        if (this.submitButtonClick) {
            console.log("in if part submit getter :");
            return 'slds-button slds-button_destructive btn-color'
        } else {
            console.log("in  else submit getter :");
            return 'slds-button slds-button_destructive disabled'
        }
    }

    requiredFieldsValidity() {
        if (!this.dateOfServiceValue) {
        //    console.log("date of service in else if of date --reqdfieldvalidity:" + this.dateOfServiceValue);
            //this.showMessage('Error', 'Please enter service date.', 'error');
            return false;
        } else if (!this.serviceFacilityValue) {
         //   console.log("date of service in  else if of facility--reqdfieldvalidity:" + this.serviceFacilityValue);
            console.log("Service facility handle blur reqd validity:");
            //this.showMessage('Error', 'Please enter service facility.', 'error');
            return false;
        } else {
            return true;
        }

    }

    /*  handleBlur(event) {
          let fieldName = event.target.getAttribute('data-id');
          console.log("Outside if condition :" + fieldName);
          if (this.dateOfService !== null && this.dateOfService !== '' && this.dateOfService !== undefined && this.serviceFacility !== '' && this.serviceFacility !== undefined) {
              this.displayError = false;
          } else if (fieldName == 'Service_Date__c' && (this.dateOfService == '' || this.dateOfService == undefined || this.dateOfService == null)) {
              console.log("Service date handle blur:" + this.dateOfService);
              this.showMessage('Error', 'Please enter service date.', 'error');
          } else if (fieldName == 'Location__c' && (this.serviceFacility == '' || this.serviceFacility == undefined)) {
              console.log("Service facility handle blur:");
              this.serviceFacilityCheck = true;
              this.showMessage('Error', 'Please enter service facility.', 'error');
          }
      } */

    createProductServiceRecord() {
        //console.log("after submit date value:" + this.dateOfService + "----" + (this.dateOfService != 'null') + ' Date of Service Not Null ' + (this.dateOfService == null));
        this.submitButtonClick = true;
        let fields = this.fields;

        
        //console.log(" line 402, createProductServiceRecord, this.ownership ", this.ownership);
        fields[OWNERSHIP_FIELD.fieldApiName] = this.ownership;

        fields[COST_FIELD.fieldApiName] = this.totalCost;

        if (this.requiredFieldsValidity()) {
            const recordInput = {
                apiName: PRODUCT_SERVICE_NOTE_OBJECT.objectApiName,
                fields
            };

           // console.log(' line 413 recordInput, createProductServiceRecord', recordInput);
            //console.log('ownership ', this.ownership);
            //console.log('ownership id', this.ownershipId);
           // console.log('ownership fields ', fields[OWNERSHIP_FIELD.fieldApiName]);
            
            createRecord(recordInput)
                .then(productServiceNote => {
                    this.productServiceNoteId = productServiceNote.id;
                //    console.log(this.productServiceNoteId);
                //    console.log(' line 422 createRecord, createProductServiceRecord', recordInput);
                    /* this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record created',
                            variant: 'success',
                        }),
                    ); */
                    sessionStorage.setItem('returnFromRecord', true);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'my-service-records'
                        },
                    });
                    this.navigate('/my-service-records', {});
                })
                .catch(error => {
                 //   console.log('ERROR: ' + JSON.stringify(error));
                    /* this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    ); */
                });
        }
    }

    updateProductServiceRecord() {
        if (this.requiredFieldsValidity()) {
            const fields = this.fields;
            const recordInput = {
                fields
            };
            //console.log(recordInput);
            updateRecord(recordInput)
                .then(() => {
                    console.log('Success');
                    /* this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record Updated',
                            variant: 'success'
                        })
                    ); */
                    sessionStorage.setItem('returnFromRecord', true);
                    /* this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'my-service-records'
                        },
                    }); */
                    this.navigate('/my-service-records', {});
                })
                .catch(error => {
                   // console.log(error);
                });
        }
    }

    deleteProductServiceRecord(event) {
       // console.log('Trying to delete: ' + this.fields.id);
        deleteRecord(this.fields.Id)
            .then(() => {
                /* this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                ); */
                // Navigate to a service record page after
                // the record is deleted
                sessionStorage.setItem('returnFromRecord', true);

                /* this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'my-service-records'
                    },
                }); */
                // send event to refresh list after navigating
                
                this.navigate('/my-service-records');
            })
            .catch(error => {
                /* this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                    
                ); */
              //  console.log(error);
            });
    }

    handleCancel() {
        //console.log('Info Object: ', JSON.stringify(this.info));
        //this.navigate('/my-service-records');
        /* this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'my-service-records'
            },
        }); */
        //Double
        sessionStorage.setItem('returnFromRecord', true);
        this.navigate('/my-service-records', {});
    }
    showMessage(title, msg, variant) {
        /* this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: msg,
                variant: variant,
            }),
        ); */
    }

    handleBreadcrumbClick() {
        this.navigate('/my-service-records', {});

    }

    setProductTypeText() {

        if(this.displayAutos)
        {
            this.productTypeText = 'VEHICLE';
        }
        else if (this.displayPowerSports){
            this.productTypeText = 'VEHICLE';
        }
        else if (this.displayPowerEquipment){
            this.productTypeText = 'POWER EQUIPMENT';
        }
        else if (this.displayMarine){
            this.productTypeText = 'HONDA OUTBOARD';
        }

    }

}
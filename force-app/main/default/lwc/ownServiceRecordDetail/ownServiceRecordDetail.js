//============================================================================
// Title:    Honda Owners Experience - Service Record Details page
//
// Summary:  Page for displaying service record Details from API and User
//
// Details:  Displays selected service records detail 
//
//
// History:
// Jan 05, 2022 Ravindra Ravindra (Wipro) Original Author
//===========================================================================

import { LightningElement, api, wire, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getContext, getGarageURL, setOrigin } from 'c/ownDataUtils';

export default class OwnServiceRecordDetail extends OwnBaseElement {
    @track context;
    @track record;
    @track title;
    @track jobrecord;
    @track thumbnailImg;

    //MergedListSort
    // This is to populate the record based of off data retrieved either from sales force or via api.
    @track mServiceDate
    @track mMiles
    @track mServiceFacility
    @track mOther
    @track showOther = false;
    @track mNotes
    @track showNotes = false;
    @track mServices
    @track mName
    @track mOperatingHours
    @track isApiServiceNote = false;
    // End Get Icon

    @track displayAutos = false;
    @track displayScheduleService = false;
    @track displayPowerEquipmentOrMarine = false;
    @track displayPowerSports = false;
    @track displayPowerEquipment = false;
    @track displayMarine = false;

    @track division;

    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));

    @api
    get imgUrl() {
        if (this.context) {
            this.thumbnailImg = (this.context.product.customerUploadedImage ?
                this.context.product.customerUploadedImage : (this.context.product.productDefaultImage ?
                    this.context.product.productDefaultImage :
                    (this.context.product.image[0] === '/' ? this.baseURL + this.context.product.image : this.context.product.image)));

            return this.thumbnailImg;
        }

    }

    @api
    get subTitle() {
        if (this.context) {
            return this.context.product.nickname ? this.context.product.nickname : this.context.product.year + ' ' + this.context.product.model;
        } else {
            return 'test';
        }
    }


    initialize = async () => {
        this.context = await getContext();
        this.division = this.context.product.division;
        if (this.division === 'Acura' || this.division === 'Honda') {
            this.displayAutos = true;
            this.displayScheduleService = true;
        } else if (this.division === 'Motorcycle/Powersports') {
            this.displayPowerSports = true;
        } else if (this.division === 'Powerequipment' || this.division === 'Marine') {
            this.displayPowerEquipmentOrMarine = true;

            if (this.division == 'Powerequipment') {
                
                this.displayPowerEquipment = true;
                //console.log('Powerequipment? ,', this.displayPowerEquipment + ' , division ', this.division);

            } else if (this.division == 'Marine') {
                this.displayMarine = true;
            }

        }

        this.determineDataType();

        //console.log("Context");
        //console.log(JSON.stringify(this.context));
    }

    connectedCallback() {

        this.initialize();

        this.record = sessionStorage.getItem('viewRecord') ? JSON.parse(sessionStorage.getItem('viewRecord')) : undefined;

        if (this.record.Service_Date__c) {
            let dateString = (this.record.Service_Date__c) ? this.record.Service_Date__c : this.record.recordDate;
            let formatDate = new Date(dateString);
            let fdDay = formatDate.getUTCDate();
            /* console.log('dateString, ', dateString);
            console.log('formatDate,', formatDate);
            console.log('fdDay', fdDay);
            console.log('EST day ', formatDate.getUTCDate()); */
            //fdDay = fdDay + 1;
            fdDay = (fdDay < 10) ? fdDay = '0' + fdDay : fdDay;
            let fdMonth = (this.record.recordDate) ? formatDate.getUTCMonth() : formatDate.getUTCMonth();
            fdMonth = fdMonth + 1;
            if (fdMonth == 0) {
                fdMonth = fdMonth + 1;
            }
            /* console.log('fdMonth', fdMonth);
            console.log('EST Month ', formatDate.getUTCMonth()); */
            fdMonth = (fdMonth < 10) ? fdMonth = '0' + fdMonth : fdMonth;
            let fdYear = formatDate.getUTCFullYear();
            /* if (formatDate.getUTCDate() == '1' || (formatDate.getUTCMonth() == '0' && formatDate.getUTCDate() == '1' )) {
                console.log('First Of Month Case');
                var month = parseInt(fdMonth);
                var yearholder = fdYear;

                month = month + 1

                month = (month < 10) ? '0' + month : month;

                if (month >= 13) {
                    month = '01';
                    yearholder = parseInt(yearholder) + 1;
                }
                this.mServiceDate = month + '/' + '01' + '/' + yearholder;
            }
            else {
                this.mServiceDate = fdMonth + '/' + fdDay + '/' + fdYear;
            } */
            this.mServiceDate = fdMonth + '/' + fdDay + '/' + fdYear;
        }
        else if (this.record.recordDate) {
            this.mServiceDate = this.record.recordDate;
        }

        this.title = 'Service Record: ' + this.mServiceDate;
        //console.log(this.record.Service_Date__c);
        //console.log(sessionStorage.getItem('viewRecord') ? sessionStorage.getItem('viewRecord') : 'N/A');

        //this.determineDataType();
    }

    handleBreadcrumbClick() {
        this.navigate('/my-service-records', {});

    }

    handlePrintRecordClick() {
        window.print();
    }

    handleScheduleNewService() {
        sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: this.context.product.division, divisionId: this.context.product.divisionId }));
        this.navigate('/find-a-dealer', {});
    }

    handleEditRecordClick() {
        if (!this.isApiServiceNote) {

            sessionStorage.setItem('editRecord', JSON.stringify(this.record));
            sessionStorage.setItem('editRecordImage', this.thumbnailImg);
            //console.log('thumbnail ' + this.thumbnailImg);
        }
        this.navigate('/service-records', {})
    }

    determineDataType() {
        this.isApiServiceNote = (this.record.apiRecord) ? true : false;
        this.jobrecord = (this.isApiServiceNote) ? this.record.serviceJobList : undefined;
        //console.log("Job Record " + JSON.stringify(this.jobrecord));

        // Set values based off of API or Object source
        if (!(this.mName)) {
            this.mName = (this.record.apiName) ? this.record.apiName : '';
        }

        if (!(this.mMiles)) {
            this.mMiles = (this.record.Usage__c) ? this.record.Usage__c : this.record.Mileage;
        }

        if (!(this.mServiceFacility)) {
            this.mServiceFacility = (this.record.Location__c) ? this.record.Location__c : this.record.serviceFacility;
        }

        if (!(this.mOther)) {
            this.mOther = (this.record.Other__c) ? this.record.Other__c : '';
        }

        if (this.record.Others__c) {
            this.showOther = true;

            if (this.mOther.length == 0) {
                this.mOther = 'Other';
            }
            else {
                this.mOther = 'Other: ' + this.mOther;
            }
        }

        if (this.record.Note__c) {
            this.showNotes = true;
        }

        if (!(this.mNotes)) {
            this.mNotes = (this.record.Note__c) ? this.record.Note__c : '';
        }

        if (!(this.mOperatingHours)) {
            this.mOperatingHours = (this.record.Operating_Hours__c) ? this.record.Operating_Hours__c : '';
        }

        if (!(this.mServices)) {
            if (this.record.servicePerformed) {
                this.mServices = this.record.servicePerformed;
            }
            else {
                this.mServices = '';
                if (this.record.Oil_Change__c == true) {
                    this.mServices += "Oil Change";
                }
                if (this.record.Scheduled_Maintenance__c == true) {
                    if (this.mServices.length === 0) {
                        this.mServices = "Scheduled Maintenance";
                    }
                    else this.mServices += ", Scheduled Maintenance";

                }
                if (this.record.Tire_Rotation__c == true) {
                    if (this.mServices.length === 0) {
                        this.mServices = "Tire Rotation";
                    }
                    else this.mServices += ", Tire Rotation";
                }
                if (this.record.Multi_Point_Inspection__c == true) {
                    if (this.mServices.length === 0) {
                        this.mServices = "Multipoint Inspection";
                    }
                    else this.mServices += ", Multipoint Inspection";
                }
                if (this.record.End_of_Season_Maintenance__c == true) {
                    if (this.mServices.length === 0) {
                        this.mServices = "End of Season Maintenance";
                    }
                    else this.mServices += ", End of Season Maintenance";
                }
                if (this.record.Repairs__c == true) {
                    if (this.mServices.length === 0) {
                        this.mServices = "Repairs";
                    }
                    else this.mServices += ", Repairs";
                }
                if (this.record.Battery__c == true) {
                    if (this.mServices.length === 0) {
                        this.mServices = "Battery";
                    }
                    else this.mServices += ", Battery";
                }
                if (this.record.Tune_Up_Packages__c == true) {

                    //console.log('Line 274 Powerequipment? ,', this.displayPowerEquipment + ' , division ', this.division);

                    if (this.displayPowerEquipment) {

                        if (this.mServices.length === 0) {
                            this.mServices = "Pre-Season Tune-Up";
                        }
                        else this.mServices += ", Pre-Season Tune-Up";
                        //console.log ('mServices display power equipment', this.mServices);
                    } else {

                        if (this.mServices.length === 0) {
                            this.mServices = "Tune Up Packages";
                        }
                        else this.mServices += ", Tune Up Packages";

                    }

                }
                if (this.record.Tires__c == true) {
                    if (this.mServices.length === 0) {
                        this.mServices = "Tires";
                    }
                    else this.mServices += ", Tires";
                }
                if (this.record.Full_Service__c == true) {
                    if (this.mServices.length === 0) {
                        this.mServices = "Full Service";
                    }
                    else this.mServices += ", Full Service";
                }
                if (this.record.Alignment__c == true) {
                    if (this.mServices.length === 0) {
                        this.mServices = "Alignment";
                    }
                    else this.mServices += ", Alignment";
                }
                if (this.record.Brakes__c == true) {
                    if (this.mServices.length === 0) {
                        this.mServices = "Brakes";
                    }
                    else this.mServices += ", Brakes";
                }
            }
        }

        //console.log('Name ' + this.mName + ' Miles  ' + this.mMiles + ' Service Facility ' + this.mServiceFacility + ' Other ' + this.mOther + ' Notes ' + this.mNotes + ' Services ' + this.mServices + ' ApiRecord ' + this.isApiServiceNote);

    }
}
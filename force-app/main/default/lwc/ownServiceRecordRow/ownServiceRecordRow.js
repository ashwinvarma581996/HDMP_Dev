import { api, track, wire, LightningElement } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getContext, getGarageURL, setOrigin } from 'c/ownDataUtils';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import MEDIUM_PHOTO_URL_FIELD from '@salesforce/schema/User.MediumPhotoUrl';
import FORM_FACTOR from '@salesforce/client/formFactor';

const fields = [MEDIUM_PHOTO_URL_FIELD];
const SPECIAL_CHARACTERS = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;

export default class OwnServiceRecordRow extends OwnBaseElement {


    //Get Icon
    userId = Id;

    @track hondaLogo = this.ownerResource() + '/Logos/honda_autos.svg';
    @track acuraLogo = this.ownerResource() + '/Logos/honda_acura.svg';
    @track brandLogo;
    @track tempImage;

    //MergedListSort
    // This is to populate the record based of off data retrieved either from sales force or via api.
    @track mServiceDate
    @track mMiles = null;
    @track mServiceFacility
    @track mOther
    @track mNotes
    @track mServices
    @track mName
    @track mOperatingHours
    @track apiServiceRecord = false;
    // End Get Icon
    @wire(getRecord, { recordId: '$userId', fields }) user;
    @api record;
    @api context;
    @api usericon;
    division;


    @track displayAutos = false;
    @track displayScheduleService = false;
    @track displayPowerEquipmentOrMarine = false;
    @track displayPowerSports = false;
    @track displayPowerEquipment = false;
    @track displayMarine = false;

    @track hideRepairOrder = false;


    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }

    handleViewRecord() {
        this.dispatchEvent(new CustomEvent("event", { detail: this.record }));
    }

    connectedCallback() {
        /* console.log('this.context ', this.context, ' before load');
        console.log('this.usericon  ownservicerecordrow', this.usericon); */
        this.initialize();

        // Set values based off of API or Object source
        if (!(this.mName)) {
            this.mName = (this.record.apiName) ? this.record.apiName : '';
        }
        if (!(this.mServiceDate)) {
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

        if (!(this.mMiles)) {
            this.mMiles = (this.record.Usage__c) ? this.record.Usage__c : this.record.Mileage;
        }

        if (!(this.mServiceFacility)) {
            this.mServiceFacility = (this.record.Location__c) ? this.record.Location__c : this.record.serviceFacility;
        }

        if (!(this.mOther)) {
            this.mOther = (this.record.Other__c) ? this.record.Other__c : '';
        }

        if (!(this.mNotes)) {
            this.mNotes = (this.record.Note__c) ? this.record.Note__c : '';
        }
        if (!(this.mOperatingHours)) {
            if (this.context.product.division == 'Motorcycle/Powersports' || this.context.product.division == 'Powersports') {
                this.mOperatingHours = (this.record.Operating_Hours__c) ? this.record.Operating_Hours__c : '';
            }
            else {
                this.mMiles = (this.record.Operating_Hours__c) ? this.record.Operating_Hours__c : this.mMiles;
            }
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

                    if (this.displayPowerEquipment) {

                        if (this.mServices.length === 0) {
                            this.mServices = "Pre-Season Tune-Up";
                        }
                        else this.mServices += ", Pre-Season Tune-Up";

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

                if (this.record.Others__c) {
                    if (!(this.record.Other__c)) {
                        if (this.mServices.length === 0) {
                            this.mServices = 'Other';
                        }
                        else this.mServices += ', Other';
                    }
                    else {
                        if (this.mServices.length === 0) {
                            this.mServices = 'Other: ' + this.record.Other__c;
                        }
                        else this.mServices += ', Other: ' + this.record.Other__c;
                    }
                }
            }
        }
    }

    get mediumPhotoUrl() {
        return getFieldValue(this.user.data, MEDIUM_PHOTO_URL_FIELD);
    }

    initialize = async () => {
        //this.context = await getContext();

        this.division = this.context.product.division;
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

        if (this.displayPowerSports || this.displayPowerEquipmentOrMarine) {
            this.hideRepairOrder = true;
        }

        this.setImage();

        if (!this.brandLogo) {
            //console.log('Failed to set Brand Logo ; Brand Logo is currently ' + this.brandLogo);
            this.context = await getContext();
            this.setImage();
        }
    }

    setImage() {
        //this.tempImage = getFieldValue(this.user.data, MEDIUM_PHOTO_URL_FIELD);
        this.tempImage = this.usericon;
        this.brandLogo = (this.tempImage) ? this.tempImage : this.brandLogo;
        if (this.record.apiRecord) {
            if (this.context.product.division == 'Honda') {
                this.brandLogo = this.hondaLogo;
            }
            else if (this.context.product.division == 'Acura') {
                this.brandLogo = this.acuraLogo;
            }
            this.apiServiceRecord = true;
        }
    }

    handleFindDealerRedirect(event) {
        /* console.log(1);
        console.log(event);
        console.log(event.currentTarget.dataset.dealername);
        console.log('ownServiceRecordRow:: dealerName' + JSON.stringify(event)); */
        let divisionName = this.division === 'Motorcycle/Powersports' ? 'Powersports' : this.division;
        let searchTerm = event.currentTarget.dataset.dealername.replace(SPECIAL_CHARACTERS, '');
        this.navigate('/find-a-dealer?brand=' + divisionName + '&name=' + searchTerm, {});
        /* switch (this.division){
            case 'Acura':
                break;
            case 'Honda':
        } */
    }
}
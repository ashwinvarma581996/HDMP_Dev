//============================================================================
// Title:    Honda Owners Experience - Service Record Page
//
// Summary:  Page for displaying service records from API and User
//
// Details:  Displays a list of each record and allows access to a service record detail page
//
//
// History:
// Dec 27, 2021 Brett S (Wipro) Original Author
//===========================================================================

import { LightningElement, api, wire, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { refreshApex } from '@salesforce/apex';

import { getContext, getGarageURL, getGarageServiceMaintenanceURL, setOrigin } from 'c/ownDataUtils';

import getProductDetails from '@salesforce/apex/ownProductSettingsController.getProductDetails';
import getServiceNotes from '@salesforce/apex/OwnProductServiceNotes.getServiceNotes';
import getProductServiceNotes from '@salesforce/apex/OwnAPIController.getProductServiceNotes';
/* import getServiceRecordVIN_Acura from '@salesforce/apex/OwnProductServiceNotes.getServiceRecordVIN_Acura';
import getServiceRecordVIN_Honda from '@salesforce/apex/OwnProductServiceNotes.getServiceRecordVIN_Honda'; */
import getServiceRecordVIN_Acura_ResponseBody from '@salesforce/apex/OwnProductServiceNotes.getServiceRecordVIN_Acura_ResponseBody';
import getServiceRecordVIN_Honda_ResponseBody from '@salesforce/apex/OwnProductServiceNotes.getServiceRecordVIN_Honda_ResponseBody';
//import parseProductServiceNotes from '@salesforce/apex/OwnProductServiceNotes.parseProductServiceNotes';
import { CurrentPageReference } from 'lightning/navigation';


//For Passing User Icon To Rows
import { getRecord, getFieldValue, getRecordNotifyChage } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import MEDIUM_PHOTO_URL_FIELD from '@salesforce/schema/User.MediumPhotoUrl'; 

//For Schedule New Service / Find a Dealer
import getDealerFromObj from '@salesforce/apex/OwnRecallsController.getDealerFromObj';
import getDealerLocator from '@salesforce/apex/OwnAPIController.getDealerLocator';
import getDealerByPoiId from '@salesforce/apex/OwnAPIController.getDealerByPoiId';
import timeHighway from '@salesforce/label/c.TimeHighway';
import xTime from '@salesforce/label/c.XTime';
import updatePromise from '@salesforce/label/c.UpdatePromise';

const fields = [MEDIUM_PHOTO_URL_FIELD];

const SERVICE_RECORDS_TITLE = "My Service Records";

export default class ownServiceListView extends OwnBaseElement {
    userId = Id;
    @wire(getRecord, { recordId: '$userId', fields }) user;

    @track context;
    @track recordSelected = false;
    selectedRecordRow;
    @track noServiceRecords = true;
    //@wire(getServiceNotes) serviceRecords;
    @track serviceRecords;
    @track apiServiceRecords;
    @track concServiceRecordsList;
    @track displayList;
    @track thumbnailImg;

    @track displayAutos = false;
    @track displayScheduleService = false;
    @track displayPowerEquipmentOrMarine = false;
    @track displayPowerSports = false;

    @track hideRepairOrder = false;

    @track division;
    @track divisionNotFoundAcura = false;

    @track noRecordsBody = '';

    @track userIcon = '/mygarage/resource/1650437609000/Owners/Logos/honda_autos.svg';

    @track breadCrumbText;
    @track productDetailPage;

    //@track apiListOfRecords = [];
    @track loadComplete = false;
    @track isSpinnerLoading = false;
    @track recalling = false;
    @track hideRecordList = false;
    @track userList = false;

    @track scheduleServiceLink = '';
    apiList;

    @track pageDescription = 'Registered users can track all maintenance performed on their products by Honda dealers as well as keep a record of maintenance performed at non-Honda service facilities. A complete set of maintenance records allows you to stay up-to-date on your product’s service history and can often significantly enhance your product’s resale value.';

    urlString = window.location.href;
    baseURL = this.urlString.substring(0, this.urlString.indexOf("/s"));

    get mediumPhotoUrl() {
        return getFieldValue(this.user.data, MEDIUM_PHOTO_URL_FIELD);
    }

    handleAddNewRecord() {
        sessionStorage.removeItem('editRecord');
        sessionStorage.setItem('productImg', this.thumbnailImg);
        this.navigate('/service-records', {});
    }

    handleRecordView(event) {
        this.selectedRecordRow = event.detail;
        //console.log("Selected Record Row");
        //console.log("$Selected Record Row", JSON.stringify(this.selectedRecordRow));
        sessionStorage.setItem('viewRecord', JSON.stringify(this.selectedRecordRow));
        sessionStorage.setItem('test', this.selectedRecordRow.Service_Date__c);
        this.navigate('/service-record-detail', {});
    }

    handleRecordViewReturn(event) {
        this.recordSelected = false;
    }

    connectedCallback() {

        /* if (sessionStorage.getItem('fromMyServiceCard')) {
            sessionStorage.removeItem('fromMyServiceCard');
            window.location.reload();
        } */
        //console.log('From My Service Card?, ',sessionStorage.getItem('fromMyServiceCard'));

        this.loadComplete = false;
        if (sessionStorage.getItem('fromMyServiceCard')) {
            this.productDetailPage = sessionStorage.getItem('fromMyServiceCard');
            //console.log('productDetailPage, ', this.productDetailPage);
            this.setBreadCrumb();
            //sessionStorage.removeItem('fromMyServiceCard');
        }


        this.initialize();

        /* if (sessionStorage.getItem('returnFromRecord')) {
           console.log('Handling return');
           sessionStorage.removeItem('returnFromRecord');
           //getServiceNotes({ ownerShip: this.context.product.ownershipId });
           //window.location.reload();

       }  */

        setTimeout(() => {

            if (!(this.recalling)) {
                this.displayList = this.concServiceRecordsList;
                console.log('Display list');
                if (!this.displayList) {
                    this.setNoRecordsBody();
                }
            }
            else {
                this.displayList = null;
                this.hideRecordList = true;
            }
            //console.log(JSON.stringify(this.displayList));
        }, 5000);
        setTimeout(() => {
            //console.log('Is Loading?, ' , this.isLoading);
            //console.log('Final Display List', JSON.stringify(this.displayList));
            //console.log('This No Records Body ', this.noRecordsBody);
            //console.log('this.userList', this.userList);

            if (!(this.displayList) && (this.noRecordsBody.includes('undefined') || (this.noRecordsBody == undefined))) {
                this.displayList = this.concServiceRecordsList;
                console.log('Recalling');
                this.connectedCallback();
            } else if (this.noRecordsBody == 'No Records Found Linked to this Vehicle.' && this.userList == true) {
                this.noRecordsBody = '';
                console.log('Recalling 2');
                this.connectedCallback();
            } else if (this.userList && this.noRecordsBody.includes('Enter a new record')) {
                console.log('List but displaying no list available');
                this.noRecordsBody = null;
                this.displayList = this.concServiceRecordsList;
                this.isSpinnerLoading = true;
                this.hideRecordList = false;

                //this.connectedCallback();
            } /* else if (this.userList && !(this.displayList) ){
                console.log('List, but display list not set');
                this.displayList = this.concServiceRecordsList;
                this.connectedCallback();
            } */ else {
                console.log('Loaded Successfully');
                this.isSpinnerLoading = true;
                this.hideRecordList = false;
                //console.log('Is Loading?, after' , this.isLoading);
            }

        }, 5750);
        /* console.log('reinitialize');
        this.initialize(); */
    }

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
        try{
        this.context = await getContext('');

        this.division = this.context.product.division;
        //console.log('division ', this.division);
        if (this.division === 'Acura' || this.division === 'Honda') {
            this.displayAutos = true;
            this.displayScheduleService = true;
        } else if (this.division === 'Powersports' || this.division === 'Motorcycle/Powersports') {
            this.displayAutos = true;
            this.displayPowerSports = true;
        } else if (this.division === 'Powerequipment' || this.division === 'Marine') {
            this.displayPowerEquipmentOrMarine = true;
        }

        if (this.displayPowerSports || this.displayPowerEquipmentOrMarine) {
            this.hideRepairOrder = true;
        }

        if (this.division === 'Acura') {
            this.divisionNotFoundAcura = true;
        }
        console.log('Get user icon start');
        this.getUserIcon();
        this.setDescriptionBody();
        //console.log("Context for service records");
        //console.log(JSON.stringify(this.context));
        if (this.division === 'Acura' || this.division === 'Honda') {
            //console.log('Parse Api List from Autos');
            await this.getUserServiceRecords();
            //console.log('Context Vin', this.context.product.vin);
            if ((this.context.product.vin) && this.context.product.vin != '-') {
                this.parseApiList();
            }
            else {
                await this.mergeServiceRecords();
                if (this.concServiceRecordsList) {
                    //console.log('this.conservicerecordslist, ', this.concServiceRecordsList);
                    this.displayList = this.concServiceRecordsList;
                } else if (this.noRecordsBody == 'No Records Found Linked to this Vehicle.' && this.userList == true) {
                    this.noRecordsBody = '';
                    //console.log('Recalling 2');
                    this.connectedCallback();
                }
                else {
                    //console.log('No Vin');
                }

            }
        } else {
            this.getRecords();
        }
        //console.log('ownershipId, ', this.context.product.ownershipId, ' divisionId, ', this.context.product.divisionId, ' brand, ', this.division);
        await this.getScheduleServiceLink(this.context.product.ownershipId, this.context.product.divisionId, this.division);
    }catch(error){
        //console.log('@@error,'+error);
    }
    }

    parseApiList() {
        //console.log('parseApiList');
        let res = '';

        if (this.division === 'Acura') {
            //getServiceRecordVIN_Acura_ResponseBody({ vin: this.context.product.vin })
            getProductServiceNotes({ vin: this.context.product.vin, divisionId: 'B' })
                .then((result) => {
                    //console.log(' get Service Response Body ', result);
                    res = JSON.parse(result);
                    this.parseApiListToList(res);
                })
                .catch((error) => {
                    this.error = error;
                    //console.log(JSON.stringify(error));
                    this.apiServiceRecords = undefined;
                });
        }
        else if (this.division === 'Honda') {
            //getServiceRecordVIN_Honda_ResponseBody({ vin: this.context.product.vin })
            getProductServiceNotes({ vin: this.context.product.vin, divisionId: 'A' })
                .then((result) => {
                    //console.log(' get Service Response Body ', result);
                    res = JSON.parse(result);
                    this.parseApiListToList(res);
                })
                .catch((error) => {
                    this.error = error;
                    console.log(JSON.stringify(error));
                    this.apiServiceRecords = undefined;
                });
        }

    }

    parseApiListToList(parseList) {
        let apiServiceNotesList = parseList.body.roDto.customerROList;
        this.apiList = new Array();

        //console.log('apiServiceNotesList ', apiServiceNotesList);

        apiServiceNotesList.forEach(element => {

            let serviceNote = new Object();

            //DEFINE SERVICE NOTE
            serviceNote.apiName = element.cproNum;
            serviceNote.Mileage = element.cproInfo.mileage_in;
            serviceNote.serviceFacility = element.dealerInfo.dlr_nm;
            serviceNote.productDivision = element.dealerInfo.prod_div_nm;
            serviceNote.Id = element.cproNum;
            serviceNote.apiRecord = true;
            serviceNote.recordDate = element.cproInfo.ro_complete_dt;
            serviceNote.Service_Date__c = element.cproInfo.ro_complete_dt;
            //console.log('$dealerJob--', element.dealerJob)
            //console.log('$customerjob--', element.customerJob)
            // if (element.dealerJob) {
            // let jobList = element.dealerJob;
            if (element.customerJob) {
                let jobList = element.customerJob;
                let servicePerformed = '';
                jobList.forEach(jobElement => {
                    servicePerformed += jobElement.cpJobInfo.op_nm + ', ';
                });
                serviceNote.servicePerformed = servicePerformed.slice(0, -2);

                let serviceJobList = [];
                jobList.forEach(serviceElement => {

                    let serviceJob = new Object();
                    serviceJob.Job = serviceElement.jobNo;

                    if (serviceJob.Job < 10) {
                        serviceJob.Job = '0' + serviceJob.Job;
                    }
                    serviceJob.Service = serviceElement.cpJobInfo.op_nm;
                    let descList = serviceElement.codesList;
                    let descString = '';
                    descList.forEach(jobDesc => {

                        if (jobDesc.compl_desc) {
                            descString = jobDesc.compl_desc + ', ';
                        }
                        if (jobDesc.corr_desc) {
                            descString = jobDesc.corr_desc + ', ';
                        }
                    });
                    serviceJob.Description = descString.slice(0, -2);

                    let partList = serviceElement.cpPartsList;
                    let partString = '';
                    let partNumbers = '';
                    partList.forEach(partName => {

                        if (partString) {
                            partString = partString + ' ' + partName.part_func_nm;
                            partNumbers = partNumbers + ' ' + partName.part_no;
                        }
                        else {
                            partString = partName.part_func_nm;
                            partNumbers = partName.part_no;
                        }
                    });
                    /*if (!(partString)) {
                        partString = '';
                    }
                    if (!(partNumbers)) {
                        partNumbers = '';
                    }*/
                    serviceJob.partNames = partString;
                    serviceJob.partNumbers = partNumbers;
                    serviceJobList.push(serviceJob);
                });
                serviceNote.serviceJobList = serviceJobList;
                //console.log('Service Job List, ', serviceNote.serviceJobList);
            }



            this.apiList.push(serviceNote);

        });
        //console.log('Api List', this.apiList);
        this.mergeServiceRecords();

    }

    getRecords() {
        //console.log('getUserServiceRecords getRecords()');
        this.getUserServiceRecords();
        //console.log('mergeServiceRecords getRecords()');
        this.mergeServiceRecords();
        /*console.log('Get api service notes');
        if (this.context.product.division == 'Honda' && this.context.product.vin != '-') {
            this.getHondaServiceRecords();
        }
        else if (this.context.product.division == 'Acura' && this.context.product.vin != '-') {
            this.getAcuraServiceRecords();
        }*/
    }

    /* getAcuraServiceRecords() {
        getServiceRecordVIN_Acura({ vin: this.context.product.vin })
            .then((result) => {
                if (result == null) {
                    this.apiServiceRecords = true;
                    //console.log('No Service Records');
                }
                else {
                    var editedList = JSON.parse(JSON.stringify(result).split('"Service_DateTempc":').join('"Service_Date__c":'));
                    this.apiServiceRecords = editedList;
                    if (this.serviceRecords) {
                        this.concServiceRecordsList = this.serviceRecords.concat(this.apiServiceRecords);
                        this.sortRecordsByDateDesc();
                    }
                    else {
                        this.concServiceRecordsList = this.apiServiceRecords;
                    }
                    this.error = undefined;
                }
            })
            .catch((error) => {
                this.error = error;
                //console.log(JSON.stringify(error));
                this.apiServiceRecords = undefined;
            });
    } */

    /* getHondaServiceRecords() {
        getServiceRecordVIN_Honda({ vin: this.context.product.vin })
            .then((result) => {
                if (result == null) {
                    this.apiServiceRecords = true;
                    //console.log('No Service Records');

                }
                else {
                    var editedList = JSON.parse(JSON.stringify(result).split('"Service_DateTempc":').join('"Service_Date__c":'));
                    this.apiServiceRecords = editedList;
                    if (this.serviceRecords) {
                        this.concServiceRecordsList = this.serviceRecords.concat(this.apiServiceRecords);
                        this.sortRecordsByDateDesc();
                    }
                    else {
                        this.concServiceRecordsList = this.apiServiceRecords;
                    }
                    this.error = undefined;
                }
            })
            .catch((error) => {
                this.error = error;
                //console.log('Error' + JSON.stringify(error));
                this.apiServiceRecords = undefined;
            });
    } */

    getUserServiceRecords() {
        //console.log('Get service notes');
        getServiceNotes({ ownerShip: this.context.product.ownershipId })
            .then((result) => {
                if (result == null) {
                    this.noServiceRecords = true;
                    console.log('No Service Records UserRecords');
                    if (!(this.context.product.vin) || this.context.product.vin == '-') {
                        this.loadComplete = true;
                    }
                }
                else {
                    this.serviceRecords = result;
                    this.concServiceRecordsList = this.serviceRecords;
                    //console.log('User Records, ', JSON.stringify(result));
                    this.userList = true;
                    //console.log('ConcServicerecords List in getUserServiceRecords, ', this.concServiceRecordsList);
                    this.error = undefined;
                }
            })
            .catch((error) => {
                this.error = error;
                //console.log(JSON.stringify(error));
                this.serviceRecords = undefined;
            });
    }

    mergeServiceRecords() {
        try{
        //console.log('In Merge Service Records');
        this.apiServiceRecords = this.apiList;
        if (this.serviceRecords) {
            ////console.log('Merging Lists');
            this.concServiceRecordsList = this.serviceRecords.concat(this.apiServiceRecords);
            this.sortRecordsByDateDesc();
        }
        else if (this.apiServiceRecords) {
            //console.log('API List Only');
            this.noServiceRecords = false;
            this.concServiceRecordsList = this.apiServiceRecords;
            this.sortRecordsByDateDesc();
            this.displayList = this.concServiceRecordsList;
            //console.log('Display List', this.displayList); 
        }
        this.loadComplete = true;
        //console.log('Loadcomplete', this.loadComplete);
        this.error = undefined;
     if(this.displayList){
        if (this.displayList.length === 0) {
            this.setNoRecordsBody(true);
        }
    }else{
        this.setNoRecordsBody(true);
    }
    }catch(error){
        //console.log('@@error,'+error);
    }
    }

    sortRecordsByDateDesc() {
        this.concServiceRecordsList = this.concServiceRecordsList.sort(function (a, b) {
            var dateA = new Date(a.Service_Date__c).getTime();
            var dateB = new Date(b.Service_Date__c).getTime();
            return dateA > dateB ? -1 : 1;
        });
        ////console.log('Sorted List ' + this.concServiceRecordsList);
    }

    handleBreadcrumbClick() {
        //console.log(getGarageServiceMaintenanceURL(this.context.product.division), ' Division: ', this.division);
        if (this.productDetailPage == "Overview") {
            this.navigate(getGarageURL(this.context.product.division), {})
        } else {
            this.navigate(getGarageServiceMaintenanceURL(this.context.product.division), {})
        }
    }

    //Setting the record body based off of the division incase there are no records to be displayed
    setNoRecordsBody(nullResponse = false) {
        if (!nullResponse) {
            console.log('setting no records body');
            switch (this.division) {

                case "Powerequipment":
                    this.noRecordsBody = 'We can’t seem to find any service records for your Honda Power Equipment.Enter a new record to start tracking your service and maintenance. <br>Please note: We are working to resolve a known issue with displaying manually entered service records that were maintained on powerequipment.honda.com. We apologize for the inconvenience.';
                    break;
                case "Marine":
                    this.noRecordsBody = 'We can’t seem to find any service records for your Honda Outboard. Enter a new record to start tracking your service and maintenance. <br>Please note: We are working to resolve a known issue with displaying manually entered service records that were maintained on marine.honda.com. We apologize for the inconvenience.';
                    break;
                case "Powersports":
                    this.noRecordsBody = 'We can’t seem to find any service records for your Honda Powersports vehicle. Enter a new record to start tracking your service and maintenance. <br>Please note: We are working to resolve a known issue with displaying manually entered service records that were maintained on powersports.honda.com. We apologize for the inconvenience.';
                    break;
                case "Motorcycle/Powersports":
                    this.noRecordsBody = 'We can’t seem to find any service records for your Honda Powersports vehicle. Enter a new record to start tracking your service and maintenance. <br>Please note: We are working to resolve a known issue with displaying manually entered service records that were maintained on powersports.honda.com. We apologize for the inconvenience.';
                    break;
                case "Acura":
                    this.noRecordsBody = 'We can’t seem to find any service records for your Acura vehicle. Enter a new record to start tracking your service and maintenance. <br>Please note: We are working to resolve a known issue with displaying manually entered service records that were maintained on owners.acura.com. We apologize for the inconvenience.';
                    break;
                case "Honda":
                    this.noRecordsBody = 'We can’t seem to find any service records for your Honda vehicle. Enter a new record to start tracking your service and maintenance. <br>Please note: We are working to resolve a known issue with displaying manually entered service records that were maintained on owners.honda.com. We apologize for the inconvenience.';
                    break;
                default:
                    this.noRecordsBody = 'No Records Found Linked to this Vehicle.';
                    break;
            }
            //console.log('noRecordsBody ', this.noRecordsBody);
        }
        else {
            this.displayList = false;
            this.noRecordsBody = 'We are unable to display your service history at this time.';
        }
    }

    setDescriptionBody() {
        console.log('setting description body');
        switch (this.division) {
            case "Powerequipment":
                this.pageDescription = 'Registered users can track all maintenance performed on their products by Honda dealers as well as keep a record of maintenance performed at non-Honda service facilities. A complete set of maintenance records allows you to stay up-to-date on your product’s service history and can often significantly enhance your product’s resale value.';
                break;
            case "Marine":
                this.pageDescription = 'Registered users can track all maintenance performed on their products by Honda dealers as well as keep a record of maintenance performed at non-Honda service facilities. A complete set of maintenance records allows you to stay up-to-date on your product’s service history and can often significantly enhance your product’s resale value.';
                break;
            case "Powersports":
                this.pageDescription = 'Registered users can track all maintenance performed on their vehicles by Honda Powersports dealers as well as keep a record of maintenance performed at non-Honda service facilities. A complete set* of maintenance records allows you to stay up-to-date on your vehicle’s service history and can often significantly enhance your vehicle’s resale value.';
                break;
            case "Motorcycle/Powersports":
                this.pageDescription = 'Registered users can track all maintenance performed on their vehicles by Honda Powersports dealers as well as keep a record of maintenance performed at non-Honda service facilities. A complete set* of maintenance records allows you to stay up-to-date on your vehicle’s service history and can often significantly enhance your vehicle’s resale value.';
                break;
            case "Acura":
                this.pageDescription = 'Registered users can track all maintenance performed on their vehicles by Acura dealers as well as keep a record of maintenance performed at non-Acura service facilities. A complete set of maintenance records allows you to stay up-to-date on your vehicle’s service history and can often significantly enhance your vehicle’s resale value.';
                break;
            case "Honda":
                this.pageDescription = 'Registered users can track all maintenance performed on their vehicles by Honda dealers as well as keep a record of maintenance performed at non-Honda service facilities. A complete set of maintenance records allows you to stay up-to-date on your vehicle’s service history and can often significantly enhance your vehicle’s resale value.';
                break;
            default:
                break;
        }
        //console.log('noRecordsBody ', this.noRecordsBody);
    }



    setBreadCrumb() {
        //console.log('setBreadCrumb,', this.productDetailPage);
        if (this.productDetailPage == "Overview") {
            this.breadCrumbText = "My Products";

        }
        else {
            this.breadCrumbText = "Service & Maintenance";
        }
        //console.log('Breadcrumb, ', this.breadCrumbText);

    }
    getUserIcon() {
        //console.log('UserData, ' , this.user.data);
        this.userIcon = getFieldValue(this.user.data, MEDIUM_PHOTO_URL_FIELD);
        //console.log('User Icon, ', this.userIcon);
    }

    //From OwnRecallOverviewCard - C. B.
    async getScheduleServiceLink(ownershipId, POItype, brand) {
        //console.log('@@@parameters', ownershipId, POItype, brand);
        let latitude;
        let longitude;
        let serviceSchedulingUrl = '';
        getDealerFromObj({ ownershipId: ownershipId }).then(res => {
            let POIid = res;
            if (POIid != '') {
                //get dealer for POIid
                //console.log('@@@POIid Not NULL', POIid);
                getDealerByPoiId({ poiId: POIid, poiType: POItype, ownershipId: '', brand: brand, latitude: '', longitude: '' }).then(res => {
                    if (res.error) {
                        //this.footer = this.showFooter ? this.isGuest ? false : false : false;
                        //console.log('@@@error in > getDealerByPoiId ', res.error);
                        this.scheduleServiceLink = '/find-a-dealer';
                    }
                    let dealerResult = JSON.parse(JSON.stringify(res.poiResponse.pois.poi));
                    //console.log('@@@result after stringify', dealerResult);
                    dealerResult[0].attributes.attribute.forEach(attributeValue => {
                        if (!serviceSchedulingUrl && attributeValue.code == '47') {
                            console.log('@@@timeHighway');
                            serviceSchedulingUrl = timeHighway;
                        } else if (!serviceSchedulingUrl && attributeValue.code == '48') {
                            console.log('@@@xTime');
                            serviceSchedulingUrl = xTime;
                        } else if (!serviceSchedulingUrl && attributeValue.code == '49') {
                            console.log('@@@updatePromise');
                            serviceSchedulingUrl = updatePromise;
                        }
                    });
                    //console.log('@@@serviceSchedulingUrl', serviceSchedulingUrl);
                    if (serviceSchedulingUrl == '') {
                        //this.footer = this.showFooter ? this.isGuest ? false : false : false;
                        this.scheduleServiceLink = '/find-a-dealer';
                    } else {
                        this.scheduleServiceLink = serviceSchedulingUrl;
                        //this.footer = this.showFooter ? this.isGuest ? false : true : false;
                        this.scheduleServiceLink = '/find-a-dealer';
                    }
                    //console.log('@@@scheduleServiceLink', this.scheduleServiceLink)
                }).catch(err => {
                    //console.log('@@@ error getDealerByPoiId ', err);
                    this.footer = this.showFooter ? this.isGuest ? false : false : false;
                });

            }
            else {
                //console.log('@@@POIid is NULL', POIid);
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(position => {
                        this.latitude = position.coords.latitude;//.replace(/\s+/g, '');
                        this.longitude = position.coords.longitude;//.replace(/\s+/g, '');
                        //console.log('@@User location-->>>>', this.latitude, this.longitude);
                        getDealerLocator({ latitude: latitude, longitude: longitude, poiType: POItype, ownershipId: '', brand: brand }).then(res => {
                            //console.log('@@@result before parsing ', res);
                            if (res.error) {
                                //this.footer = this.showFooter ? this.isGuest ? false : false : false;
                                //console.log('@@@error in > getDealerLocator ', res.error);
                                this.scheduleServiceLink = '/find-a-dealer';
                            }
                            let dealerResult = JSON.parse(JSON.stringify(res.poiResponse.pois.poi));
                            //console.log('@@@result after stringify', dealerResult);
                            dealerResult = dealerResult.sort(function (a, b) { return parseFloat(a.distance.replaceAll(',', '')) - parseFloat(b.distance.replaceAll(',', '')) });
                            //console.log('@@@result after sorting', dealerResult);
                            dealerResult[0].attributes.attribute.forEach(attributeValue => {
                                if (!serviceSchedulingUrl && attributeValue.code == '47') {
                                    //console.log('@@@timeHighway');
                                    serviceSchedulingUrl = timeHighway;
                                } else if (!serviceSchedulingUrl && attributeValue.code == '48') {
                                    //console.log('@@@xTime');
                                    serviceSchedulingUrl = xTime;
                                } else if (!serviceSchedulingUrl && attributeValue.code == '49') {
                                    //console.log('@@@updatePromise');
                                    serviceSchedulingUrl = updatePromise;
                                }
                            });
                            //console.log('@@@serviceSchedulingUrl', serviceSchedulingUrl);
                            if (serviceSchedulingUrl == '') {
                                //this.footer = this.showFooter ? this.isGuest ? false : false : false;
                                this.scheduleServiceLink = '/find-a-dealer';
                            } else {
                                this.scheduleServiceLink = serviceSchedulingUrl;
                                //this.footer = this.showFooter ? this.isGuest ? false : true : false;
                            }
                            //console.log('@@@scheduleServiceLink', this.scheduleServiceLink)
                        }).catch(err => {
                            //console.log('@@@err in getDealerLocator', err);
                            //this.footer = this.showFooter ? this.isGuest ? false : false : false;
                            this.scheduleServiceLink = '/find-a-dealer';
                        });
                    }, error => {
                        //console.log('@@@user denied')
                        this.scheduleServiceLink = '/find-a-dealer';
                        //this.footer = this.showFooter ? this.isGuest ? false : true : false;
                    },
                        { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 });
                }
            }
        }).catch(err => {
            //console.log('@@@err in getDealerFromObj ', err);
            //this.footer = this.showFooter ? this.isGuest ? false : false : false;
            this.scheduleServiceLink = '/find-a-dealer';
        })
    }

    handleScheduleNewService() {
        /* sessionStorage.setItem('findDealerContext',JSON.stringify({brand: this.context.product.division, divisionId: this.context.product.divisionId}));
        this.navigate('/find-a-dealer',{}); */
        //console.log('this.scheduleServiceLink, ', this.scheduleServiceLink);
        if (this.scheduleServiceLink.includes('/find-a-dealer')) {
            let brandName = this.context.product.division == 'Powerequipment' ? 'Power Equipment' : this.context.product.division;
            sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: brandName, divisionId: this.context.product.divisionId }));
            this.navigate('/find-a-dealer', {});
        } else {

            this.navigate(this.scheduleServiceLink, {});
        }

    }

}
//============================================================================
// Title:    Honda Owners Experience - Service History Card
//
// Summary:  This Card links to the Service History
//
//
// History:
// May 17, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
// Jan  21, 2022 Ravindra Ravindra(Wipro) Modified to implement DOE-2401
//=========================================================================== -->
import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

import getServiceNotes from '@salesforce/apex/OwnProductServiceNotes.getServiceNotes';
import getProductServiceNotes from '@salesforce/apex/OwnAPIController.getProductServiceNotes';

//Old Methods Apex Heavy
/* import getServiceRecordVIN_Acura from '@salesforce/apex/OwnProductServiceNotes.getServiceRecordVIN_Acura';
import getServiceRecordVIN_Honda from '@salesforce/apex/OwnProductServiceNotes.getServiceRecordVIN_Honda'; */

//New Javascript Heavy Methods
import getServiceRecordVIN_Acura_ResponseBody from '@salesforce/apex/OwnProductServiceNotes.getServiceRecordVIN_Acura_ResponseBody';
import getServiceRecordVIN_Honda_ResponseBody from '@salesforce/apex/OwnProductServiceNotes.getServiceRecordVIN_Honda_ResponseBody';


import { getContext, getOrigin, getProductContext } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';


const NULL_RESPONSE_TEXT = 'We are unable to display your service history at this time.';


export default class OwnMyServiceHistoryRecordsCard extends OwnBaseElement {
    @track context;
    @track isSearchedProduct;
    @api title = "MY SERVICE HISTORY";
    @api titlecolor = "Honda Red";
    @api showFooter = false;
    @track isRecordsAvailable = false;
    @api icon = "documents.svg";
    @track latestSeviceRecord;
    @api page;

    //For retrieving and merging the API and Org objects//////
    @track noServiceRecords = true;
    @track serviceRecords;
    @track apiServiceRecords;
    @track concServiceRecordsList;
    @track displayList;
    @track thumbnailImg;
    @track loadComplete = false;
    @track division;
    @track mServiceDate;
    @track noRecordsBody;
    @track showOperatingHours = false;
    apiList;
    ///////////////////////////////////////////////////////////




    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;

        this.initialize();
    }


    initialize = async () => {
        this.isSearchedProduct = (getOrigin() === 'ProductChooser');
        // this.context = await getContext('');
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        //console.log('@division ', this.context);
        ///////////////////// New Methods to Retrieve List of API and Salesforce Product Service Notes
        this.division = this.context.product.division;
        //console.log('division ', this.division);


        if (this.division === 'Marine' || this.division === 'Powerequipment') {
            this.showOperatingHours = true;
        }

        if (!this.isSearchedProduct) {
            if (this.division === 'Acura' || this.division === 'Honda') {
                //console.log('Parse Api List from Autos');
                this.getUserServiceRecords();
            } else {
                //console.log('Get Only User Records')
                this.getRecords();
            }
        }
        else {
            //console.log('From Product Chooser');
            this.loadComplete = true;
            this.titlecolor = 'Black';
            //console.log('Title Color', this.titlecolor);
        }
        /////////////////////
        /* if (!this.isSearchedProduct && this.context.product && this.context.product.division == 'Honda' && this.context.product.vin != '-') {
            this.getHondaServiceRecords();
        }
        else if (!this.isSearchedProduct && this.context.product && this.context.product.division == 'Acura' && this.context.product.vin != '-') {
            this.getAcuraServiceRecords();
        } */

    }

    async handleViewAllClick(event) {
        if (this.titlecolor === 'Honda Red') {
            let eventMetadata = {
                action_type: event.target.dataset.actionType,
                action_category: 'body',
                action_label: this.title + (this.isRecordsAvailable ? ':view all' : '')
            };
            let message = this.buildAdobeMessage('/my-service-records', eventMetadata);
            this.publishToChannel(message);
            //console.log(this.page);
            sessionStorage.setItem('fromMyServiceCard', this.page);
            //console.log(sessionStorage.getItem('fromMyServiceCard'));
            await this.sleep(2000);
            this.navigate('/my-service-records');
        }
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    handleShowDetailsClick() {
        sessionStorage.setItem('viewRecord', JSON.stringify(this.latestSeviceRecord));

        //console.log(this.page);
        sessionStorage.setItem('fromMyServiceCard', this.page);
        //console.log(sessionStorage.getItem('fromMyServiceCard'));

        this.navigate('/service-record-detail', {})
    }

    /* getAcuraServiceRecords() {
        console.log('getAcuraServiceRecords ', this.context.product.vin)
        getServiceRecordVIN_Acura({ vin: this.context.product.vin })
            .then((result) => {
                if (result == null) {
                    this.isRecordsAvailable = false;
                }
                else {
                    this.isRecordsAvailable = true;
                    let editedList = JSON.parse(JSON.stringify(result).split('"Service_DateTempc":').join('"Service_Date__c":'));
                    let sortedList = editedList.sort(function (a, b) {
                        var dateA = new Date(a.Service_Date_c).getTime();
                        var dateB = new Date(b.Service_Date_c).getTime();
                        return dateA < dateB ? -1 : 1;
                    });
                    this.latestSeviceRecord = sortedList[0];
                }
            })
            .catch((error) => {
                console.log('ErrorfromCard ' + JSON.stringify(error));
                this.isRecordsAvailable = false;
            });
    }
 */
    /* getHondaServiceRecords() {
        console.log('getHondaServiceRecords ', this.context.product.vin)
        getServiceRecordVIN_Honda({ vin: this.context.product.vin })
            .then((result) => {
                if (result == null) {
                    this.isRecordsAvailable = false;
                }
                else {
                    this.isRecordsAvailable = true;
                    let editedList = JSON.parse(JSON.stringify(result).split('"Service_DateTempc":').join('"Service_Date__c":'));
                    let sortedList = editedList.sort(function (a, b) {
                        var dateA = new Date(a.Service_Date_c).getTime();
                        var dateB = new Date(b.Service_Date_c).getTime();
                        return dateA < dateB ? -1 : 1;
                    });
                    this.latestSeviceRecord = sortedList[0];
                }
            })
            .catch((error) => {
                console.log('ErrorfromCard ' + JSON.stringify(error));
                this.isRecordsAvailable = false;
            });
    } */

    ///////////////////////////////// New Methods

    getUserServiceRecords() {
        //console.log('Get service notes');
        getServiceNotes({ ownerShip: this.context.product.ownershipId })
            .then((result) => {
                //console.log('Get User Service Notes Result, ', result);

                if (result == null) {
                    this.noServiceRecords = true;
                    //console.log('No Service Records UserRecords');
                    if ((!(this.context.product.vin) || this.context.product.vin == '-') || !(this.division === 'Acura' || this.division === 'Honda')) {
                        this.loadComplete = true;
                        this.setNoRecordsBody(false);
                    }
                    if ((this.context.product.vin) && this.context.product.vin != '-') {
                        this.parseApiList();
                    }
                }
                else {
                    this.serviceRecords = result;
                    this.concServiceRecordsList = this.serviceRecords;
                    //console.log('this.serviceRecords = result result, ', JSON.stringify(this.serviceRecords));
                    //console.log('User Service Note Result', JSON.stringify(result));
                    this.error = undefined;
                    //console.log('Context Vin', this.context.product.vin);
                    if ((this.context.product.vin) && this.context.product.vin != '-' && (this.division === 'Acura' || this.division === 'Honda')) {
                        this.parseApiList();
                    }
                    else {
                        //console.log('No Vin');
                        this.mergeServiceRecords();
                    }
                }

            })
            .catch((error) => {
                this.error = error;
                //console.log(JSON.stringify(error));
                this.serviceRecords = undefined;
            });
    }

    parseApiList() {
        let res = '';

        if (this.division === 'Acura') {
            //getServiceRecordVIN_Acura_ResponseBody({ vin: this.context.product.vin })
            getProductServiceNotes({ vin: this.context.product.vin, divisionId: 'B' })
                .then((result) => {
                    //console.log(' get Service Response Body ', result);
                    res = JSON.parse(result);
                    if (res && res.Header && res.Header.ErrorCode) {
                        this.loadComplete = true;
                        this.setNoRecordsBody(false);
                    } else {
                        this.parseApiListToList(res);
                    }
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
                    res = JSON.parse(result);
                    if (res && res.Header && res.Header.ErrorCode) {
                        this.loadComplete = true;
                        this.setNoRecordsBody(false);
                    } else {
                        this.parseApiListToList(res);
                    }
                })
                .catch((error) => {
                    this.error = error;
                    //console.log(JSON.stringify(error));
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
            //if (element.dealerJob) {
            //let jobList = element.dealerJob;
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
                    var descString = '';
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
                    let partString;
                    let partNumbers;
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
                    if (!(partString)) {
                        partString = '';
                    }
                    if (!(partNumbers)) {
                        partNumbers = '';
                    }

                    serviceJob.partNames = partString;
                    serviceJob.partNumbers = partNumbers;
                    serviceJobList.push(serviceJob);
                });
                serviceNote.serviceJobList = serviceJobList;
                //console.log('Service Job List, ', serviceNote.serviceJobList);
            }

            this.apiList.push(serviceNote);

        });
        //console.log('I am here line 367');
        //console.log('Api List', this.apiList);
        this.mergeServiceRecords();

    }

    getRecords() {
        //console.log('getUserServiceRecords getRecords()');
        this.getUserServiceRecords();
        //console.log('mergeServiceRecords getRecords()');
        this.mergeServiceRecords();
    }

    mergeServiceRecords() {
        //console.log('In Merge Service Records');
        this.apiServiceRecords = this.apiList;
        //console.log('this.serviceRecords ', this.serviceRecords);
        if (this.serviceRecords) {
            //console.log('Merging Lists');
            this.concServiceRecordsList = this.serviceRecords.concat(this.apiServiceRecords);
            this.sortRecordsByDateDesc();
            this.latestSeviceRecord = this.concServiceRecordsList[0];
            //console.log('This.latestServiceRecord, ', this.latestSeviceRecord);
            if (this.latestSeviceRecord) {
                this.isRecordsAvailable = true;
                //console.log('this.isrecordsAvailable = ', this.isRecordsAvailable);

                this.formatDate();
            }
        }
        else {
            if (this.apiServiceRecords) {
                //console.log('API List Only');
                this.noServiceRecords = false;
                this.concServiceRecordsList = this.apiServiceRecords;
                this.sortRecordsByDateDesc();
                this.displayList = this.concServiceRecordsList;
                //console.log('Display List', this.displayList);
                if (this.displayList.length != 0) {
                    this.latestSeviceRecord = this.displayList[0];
                    if (this.latestSeviceRecord) {
                        this.isRecordsAvailable = true;
                        //console.log('this.isrecordsAvailable = ', this.isRecordsAvailable);
                        this.formatDate();
                    }
                }

            }
        }
        this.loadComplete = true;
        //console.log('Loadcomplete', this.loadComplete);

        //Alexander Dzhitenov (Wipro): error handling for empty API response
        if (!this.latestServiceRecord) {
            this.setNoRecordsBody(true);
        }

        this.error = undefined;
    }

    sortRecordsByDateDesc() {
        this.concServiceRecordsList = this.concServiceRecordsList.sort(function (a, b) {
            var dateA = new Date(a.Service_Date__c).getTime();
            var dateB = new Date(b.Service_Date__c).getTime();
            return dateA > dateB ? -1 : 1;
        });
        //console.log('Sorted List ' + JSON.stringify(this.concServiceRecordsList));
    }

    formatDate() {
        let dateString = this.latestSeviceRecord.Service_Date__c;
        let formatDate = new Date(dateString);
        let fdDay = formatDate.getUTCDate();
        /* console.log('dateString, ', dateString);
        console.log('formatDate,', formatDate);
        console.log('fdDay', fdDay);
        console.log('EST day ', formatDate.getUTCDate()); */
        //fdDay = fdDay + 1;
        fdDay = (fdDay < 10) ? fdDay = '0' + fdDay : fdDay;
        let fdMonth = (this.latestSeviceRecord.Service_Date__c) ? formatDate.getUTCMonth() + 1 : formatDate.getUTCMonth();
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




        //console.log('mServiceDate ', this.mServiceDate);
        this.setNoRecordsBody(false);

    }

    setNoRecordsBody(nullResponse = false) {
        if (!nullResponse) {
            //console.log('setting no records body');
            switch (this.division) {

                case "Powerequipment":
                    this.noRecordsBody = 'No Records Found Linked to this Product.';
                    break;
                default:
                    this.noRecordsBody = 'No Records Found Linked to this Vehicle.';
                    break;
            }
            //console.log('noRecordsBody ', this.noRecordsBody);
        }
        else {
            this.noRecordsBody = NULL_RESPONSE_TEXT;
        }
    }
}
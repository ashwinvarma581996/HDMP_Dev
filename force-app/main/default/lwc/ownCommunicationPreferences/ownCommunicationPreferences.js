import { LightningElement, api, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import userEmailFld from '@salesforce/schema/User.Email';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";
import getConsumerPreferenceByEmail from '@salesforce/apex/ownConsumerApiController.getConsumerPreferenceByEmail';
import saveConsumerPreferenceByEmail from '@salesforce/apex/ownConsumerApiController.saveConsumerPreferenceByEmail';
import getTimeZome from '@salesforce/apex/ownConsumerApiController.getTimeZome';
import getCommunicationPreference from '@salesforce/apex/ownConsumerApiController.getCommunicationPreference';

const OPEN_ACCORDION_SECTION = "section  slds-accordion__section slds-is-open accordian_section";
const CLOSED_ACCORDION_SECTION = "section section-closed slds-accordion__section";

const OPEN_SECTION_TITLE = "selected-title slds-accordion__summary-content slds-text-title_caps";
const CLOSED_SECTION_TITLE = "slds-accordion__summary-content slds-text-title_caps";

export default class OwnCommunicationPreferences extends OwnBaseElement {
    @api selectedSectionId;
    @api result;
    @track propertiesList = [];
    @track isSelected = false;
    @track selectedTitles = [];
    @track rightArrow = commonResources + '/Icons/right_arrow.svg';
    @track resultData;
    @track currentUserEmailId;
    @track selectedList = [];
    @track unselectedList = [];
    @track hasData;
    @track timeZone = [];
    @track error;
    @api privacyPolicyLink
    @track isUnsubscribeAll =false;
    @track headerTitles = [/*{'title' : 'General News & Information','titledivision' : 'GN'},
    {'title' : 'Product Information & Updates','titledivision' : 'PI'},
    {'title' : 'in-Vehicle Services','titledivision' : 'IV'},
    {'title' : 'Offers & Promotions','titledivision' : 'OP'},
    {'title' : 'Events','titledivision' : 'EV'},
    {'title' : 'DIGITAL MARKETPLACE','titledivision' : 'DM'},
    {'title' : 'Racing','titledivision' : 'R'},
    {'title' : 'Honda Genuine Parts','titledivision' : 'HG'},
    {'title' : 'Honda Environmental Products & Technologies','titledivision' : 'HE'},
    {'title' : 'Contact Preferences','titledivision' : 'CP'},
    {'title' : 'Unsubscribe All','titledivision' : 'UA'}*/
    ];



    @wire(getRecord, { recordId: Id, fields: [userEmailFld] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUserEmailId = data.fields.Email.value;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getCommunicationPreference, {})
    getCommunicationPref({ error, data }) {
        if (data) {
            this.headerTitles = data;
            //console.log('@@titles' + JSON.stringify(this.headerTitles));
        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback() {
        this.hasData = false;
        this.initialize();
    }

    initialize = async () => {
        this.resultData = [];
        this.hasData = false;
        this.isUnsubscribeAll = false;
        await getTimeZome().then((data) => {
            for (var i in data) {
                let timeZonevalue = { label: i, value: data[i] };
                this.timeZone.push(timeZonevalue);
            }
            //    console.log('@@TimeZone', JSON.stringify(this.timeZone));
        }).catch((error) => {
            this.hasData = false;
            //console.log('@@Error getting timeZone', error);
        });
        await getConsumerPreferenceByEmail()
            .then((data) => {
                this.resultData = data;
                //  console.log('@@Result'+JSON.stringify(data));
                this.hasData = true;
            })
            .catch((error) => {
                this.hasData = false;
                //console.log('@@Error getting communicationPreferences', error);
            });

    }

    get sectionClass() {
        //console.log('Selected Section id ' + this.selectedSectionId);
        return CLOSED_ACCORDION_SECTION;
    }

    get sectionTitleClass() {
        return CLOSED_SECTION_TITLE;
    }

    handleSelect(event) {
        let selectedTitle = event.detail;
        //console.log('@@Test' + selectedTitle);
        if (this.selectedTitles.includes(selectedTitle)) {
            const index = this.selectedTitles.indexOf(selectedTitle);
            if (index > -1) {
                this.selectedTitles.splice(index, 1);
            }
        } else {
            this.selectedTitles.push(selectedTitle);
        }
        //console.log('@@titles' + this.selectedTitles);
    }
    handleCheckboxSelect(event) {
        if (event.detail.value != 'unsubscribeall') {
            if (event.detail.selection) {
                if (!this.selectedList.includes(event.detail.value)) {
                    this.selectedList.push(event.detail.value);
                }
                if (this.unselectedList.includes(event.detail.value)) {
                    const index = this.unselectedList.indexOf(event.detail.value);
                    if (index > -1) {
                        this.unselectedList.splice(index, 1);
                    }
                }
            } else {
                if (!this.unselectedList.includes(event.detail.value)) {
                    this.unselectedList.push(event.detail.value);
                }
                if (this.selectedList.includes(event.detail.value)) {
                    const index = this.selectedList.indexOf(event.detail.value);
                    if (index > -1) {
                        this.selectedList.splice(index, 1);
                    }
                }
            }
        } else {
            if (event.detail.selection) {
                this.selectedList = [];
                this.unselectedList = [];
                var data = this.resultData;
                for (var i in data) {
                    for (var j in data[i]) {
                        if (data[i][j].OptInFlag == true) {
                            this.unselectedList.push(data[i][j].InterestID);
                        }
                        if (data[i][j].isConsumerInterestPresent == true) {
                            for (var k in data[i][j].consumerInterest) {
                                if (data[i][j].consumerInterest[k].OptInFlag == true) {
                                    this.unselectedList.push(data[i][j].consumerInterest[k].InterestID);
                                }
                            }
                        }
                    }
                }
                this.isUnsubscribeAll = true;
            } else {
                this.selectedList = [];
                this.unselectedList = [];
                this.isUnsubscribeAll = false;
            }
        }
        //  alert(this.selectedList);
    }
    handleSave() {
        //console.log('@@ResponseSelcted' + JSON.stringify(this.selectedList,));
        //console.log('@@ResponseUnSelcted' + JSON.stringify(this.unselectedList));
        saveConsumerPreferenceByEmail({ selectedItems: this.selectedList, unSelectedItems: this.unselectedList }).then((data) => {
            //console.log('@@Response' + JSON.stringify(data));
            if (data.includes('SUCCESS')) {
              //  this.showToast_success('Data Saved Successfully');
                this.hasData=false;
                this.initialize();
            } else {
              //  this.showToast_error('Error');
            }

        })
            .catch((error) => {
                //console.log('@@Error save communicationPreferences', error);
            });
    }
    handlePrivacyPolicy() {
        //console.log('@@Testlink' + this.privacyPolicyLink);
        this.navigate(this.privacyPolicyLink, {});
    }
}
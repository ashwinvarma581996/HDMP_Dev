import { LightningElement, track, wire } from 'lwc';
//import RETURN_POLICY_LABEL from '@salesforce/label/c.RETURN_POLICY_LABEL';


import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = [
    'Live_coding__Default__mdt.MasterLabel',
    'Live_coding__Default__mdt.DeveloperName',
    'Live_coding__Default__mdt.Live_coding__Policy_Markup__c',
];

export default class DisclaimerModal extends LightningElement {

    @track showHideModal = false;
    recordId = 'm042w000000EjrAAAS';
    @track htmlMarkup = '<h1>No Response from server...</h1>';

    get disclaimerMarkup() {
        return this.htmlMarkup;
    }
    set disclaimerMarkup(value) {
        this.htmlMarkup = value;
    }


    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    metadatarecord({ error, data }) {
        if (data) {
            this.disclaimerMarkup = data.fields.Live_coding__Policy_Markup__c.value;
        }
        if (error) {
            this.disclaimerMarkup = '';
        }
    };

    handleShowHideModal() {

        this.showHideModal = this.showHideModal == false ? true : false;
    }


}
import { LightningElement, api, wire, track } from 'lwc';
import {OwnBaseElement} from 'c/ownBaseElement';
import { getContext, getGarageURL, setOrigin } from 'c/ownDataUtils';

export default class OwnServiceRecordDetailJobRecord extends OwnBaseElement {
    @api job;
    @track showJobDetail = false;
    @track jobNumber;

    @track showPartNames = true;
    @track showPartNumbers = true;


    connectedCallback(){
        this.jobNumber = this.job.Job;
        let numHol = this.jobNumber.indexOf('0');
        this.jobNumber = (numHol == 0) ? this.jobNumber.slice('1') : this.jobNumber;

        this.showPartNames = (this.job.partNames) ? true : false;
        this.showPartNumbers = (this.job.partNumbers) ? true : false;
    }

    handleClick(){
        this.showJobDetail = (this.showJobDetail) ? false : true;
    }
}
import { LightningElement, track, wire, api } from 'lwc';
import OFFER_OBJECT from '@salesforce/schema/Offers__c'
import Brand_FIELD from '@salesforce/schema/Offers__c.Brand__c'
import GroupType_FIELD from '@salesforce/schema/Offers__c.Group_Type__c'
import GroupCode_FIELD from '@salesforce/schema/Offers__c.Group_Code__c'
import AHMREGIONS_FIELD from '@salesforce/schema/Offers__c.AHM_Regions__c'


export default class GroupCodeDetails extends LightningElement {
    objectApiName = OFFER_OBJECT;
    @track fieldsName = [Brand_FIELD, GroupType_FIELD,GroupCode_FIELD,AHMREGIONS_FIELD];
    @api recordId;
}
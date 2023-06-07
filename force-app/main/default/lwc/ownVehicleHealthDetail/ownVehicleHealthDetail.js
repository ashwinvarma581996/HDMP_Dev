//============================================================================
// Title:    Honda Owners Experience - Update Vehicle Software Card
//
// Summary:  This Card links to the Update Vehicle Software
//
// History:
// Created by Ritika Bhagchandani
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getVehicleHealthReport from '@salesforce/apex/ownMaintenanceMinderController.getVehicleHealthReport';
import { viewProduct, getOrigin, setOrigin, addProduct, getGarageURL, getContext, setProductContextUser, getProductContext } from 'c/ownDataUtils';
import getRecallsByModel from '@salesforce/apex/OwnAPIController.getRecallsByModel';
import getRecalls from '@salesforce/apex/OwnRecallsController.getRecallByOwnership';
import getVehicleHealthStatusReport from '@salesforce/apex/ownMaintenanceMinderController.getVehicleHealthStatusReport';

export default class ownVehicleHealthDetail extends OwnBaseElement {
    @track title = 'VEHICLE HEALTH & MAINTENANCE MINDERS';
    @track titlecolor;
    @track icon;
    @track brand = 'default';
    @track showFooter = true;
    @track actiontitle = 'VIEW HEALTH REPORT';
    @track recall = {};
    @track date;
    @track division;
    @track totalRecalls ;
    @track vehicleHealthReport = {
        oilLife: '-',
        mileage: '-',
       
    };
    @track noRecalls;
    @track vehiclestautscategory ;
    @track cardDivClass = '';
    
    connectedCallback() {
        if(document.title == 'Garage' || document.title == 'Garage'){
           // this.cardDivClass = 'overview-tab-class';
            //console.log('Document title ::: ', document.title);
        }
        this.initialize();
    }
    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            //this.context = await getProductContext('', false);
            //this.context = await getContext('');
            this.context = await getProductContext('', false);
            //console.log('context from server - ',JSON.parse(JSON.stringify(this.context)));
        }
        //console.log('context-------->', this.context);
        //console.log('context-----divisionId--->', this.context.product.divisionId);
        this.getHealthReport();
        this.getVehicleHeathStatus();
        this.getRecalls();
        
    }
    getHealthReport() {
        getVehicleHealthReport({ ownershipId: this.context.product.ownershipId, productId: this.context.product.productId }).then((result) => {
            //console.log('@@result: ',JSON.parse(JSON.stringify(result)));
            this.vehicleHealthReport.oilLife = result.Oil_Life_Percent__c;
            this.vehicleHealthReport.mileage = this.numberWithCommas(result.Mileage__c) + ' miles' ?? '-';
            // this.date = this.getDateString(new Date(result.Report_Date__c), 'mdy', '/', 1);
            this.date = result.Report_Date__c ? this.getDateString(result.Report_Date__c) : '';
           //console.log('getVehicleHealthReport', JSON.parse(JSON.stringify(this.vehicleHealthReport)));
        }).catch(error => { console.log('health report error', error); })
        
        // this.vehicleHealthReport = getVehicleHealthReport({ ownershipId: this.context.product.ownershipId, productId: this.context.product.productId });
        // console.log('VehicleHealthReport', this.vehicleHealthReport);
    }
    
    getRecalls() {
        getRecalls({ ownership: this.context.product.ownershipId }).then((result) => {
            //console.log('RECALLS: recallMessages----1', result);
        this.totalRecalls = result.length;
        }).catch(error => { console.log('health report error', error); })
        // this.recallMessages = [this.recallMessages[0]];
        
    }
 
        

    
    getVehicleHeathStatus(){
        getVehicleHealthStatusReport({ ownershipId: this.context.product.ownershipId, productId: this.context.product.productId }).then((result) => {
            //console.log('result: getVehicleHealthStatusReport',result);
            this.vehiclestautscategory = result ;
            }).catch(error => { console.log('health report error', error); })

    }
    get istrueCategorytosubcategory(){

    }
    getDateString(d){
        return d.substring(0, d.lastIndexOf("T")).split("-")[1] + "/" + d.substring(0, d.lastIndexOf("T")).split("-")[2] + "/" +d.substring(0, d.lastIndexOf("T")).split("-")[0];
    }
    numberWithCommas(x) {
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + '.00';
    }
}
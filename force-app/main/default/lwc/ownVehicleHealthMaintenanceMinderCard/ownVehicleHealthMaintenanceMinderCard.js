import { track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getVehicleHealthReport from '@salesforce/apex/ownMaintenanceMinderController.getVehicleHealthReport';
import getMaintenanceMindersListCard from '@salesforce/apex/ownMaintenanceMinderController.getMaintenanceMindersListCard';
import hasVHR from '@salesforce/apex/ownMaintenanceMinderController.hasVHR';
import { getOrigin, getContext, getProductContext, getRecalls, ISGUEST } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
export default class ownVehicleHealthMaintenanceMinderCard extends OwnBaseElement {
    @track title = 'VEHICLE HEALTH & MAINTENANCE MINDERS';
    @track titlecolor;
    @track icon = this.myGarageResource() + '/ahmicons/' + 'wrench.svg';
    @track brand = 'default';
    @track showFooter = false;
    @track actiontitle = 'VIEW HEALTH REPORT';
    @track recall = {};
    @track date;
    @track paddingClass;
    @track recallsCount = 'Fetching data...';
    @track division;
    @track showCard;
    @track isDataLoading;/*  = true; */
    @track hasMaintenanceMinders;
    @track isGuest = ISGUEST;
    @api maintenanceMindersHondaKey;
    @api maintenanceMindersAcuraKey;
    @track vehicleHealthReport = {
        oilLife: 'Fetching data...',
        mileage: 'Fetching data...',
        maintenanceMinderCode: 'Fetching data...', //Maintenance Minder
        legalDecription: 'Fetching data...' //There are no recommended  service items at this time.
    };
    @track noRecalls;
    @track cardDivClass = '';

    connectedCallback() {
        this.paddingClass = window.location.href.includes('service-maintenance') ? 'guest-container-2' : 'guest-container';
        if (document.title == 'Garage' || document.title == 'Garage') {
            this.cardDivClass = 'overview-tab-class';
            //console.log('Document title ::: ', document.title);
        } else {
            this.cardDivClass = 'service-tab-class';
        }
        this.initialize();
    }
    initialize = async () => {
        if (!this.isGuest) {
            let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
            //console.log('From Product Chooser ----', fromProductChooser);
            if (fromProductChooser) {
                this.context = await getProductContext('', true);
            } else {
                this.context = await getContext('');
            }
            //console.log('@@ownership', this.context.product.ownershipId);
            if (this.context && this.context.product && this.context.product.ownershipId && this.context.product.productId) {
                if (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-')) {
                    hasVHR({ ownershipId: this.context.product.ownershipId, productId: this.context.product.productId }).then((result) => {
                        //console.log('result: hasVHR ', result);
                        this.showCard = result;
                    }).catch((err) => {
                        //console.error('result: hasVHR ', err);
                    });
                }
            }
            this.getHealthReport();
            this.getRecalls();
        }
    }
    getHealthReport() {
        // isDataLoading
        let i = 0;
        let dot = '';
        let interval = setInterval(() => {
            dot = i == 0 ? '' : i == 1 ? '.' : i == 2 ? '..' : i == 3 ? '...' : i == 4 ? '....' : '';
            i = i == 5 ? 0 : i;
            this.vehicleHealthReport.oilLife = 'Fetching data' + dot;
            this.vehicleHealthReport.mileage = 'Fetching data' + dot;
            this.vehicleHealthReport.maintenanceMinderCode = 'Fetching data' + dot;
            this.vehicleHealthReport.legalDecription = 'Fetching data' + dot;
            this.recallsCount = 'Fetching data' + dot;
            i = i + 1;
        }, 100);

        let vhrArrived = false;
        let mmArrived = false;
        getVehicleHealthReport({ ownershipId: this.context.product.ownershipId, productId: this.context.product.productId }).then((result) => {
            clearInterval(interval);
            result = JSON.parse(JSON.stringify(result))
            //console.log("$VHR-", result);
            // result.Oil_Life_Percent__c = result.Oil_Life_Percent__c ? result.Oil_Life_Percent__c : '0';
            // result.Mileage__c = result.Mileage__c ? result.Mileage__c : '0';
            this.vehicleHealthReport.oilLife = result.hasOwnProperty("Oil_Life_Percent__c") ? result.Oil_Life_Percent__c + '%' : '[Data not available]';
            this.vehicleHealthReport.mileage = result.hasOwnProperty("Mileage__c") ? this.numberWithCommas(result.Mileage__c) + ' miles' : '[Data not available]';
            // this.date = result.Report_Date__c ? this.getDateString(new Date(result.Report_Date__c), 'mdy', '/', 1) : '';
            this.date = result.Report_Date__c ? this.getDateString(result.Report_Date__c) : '';
            //console.log('VehicleHealthReport', this.vehicleHealthReport);
            vhrArrived = true;
        }).catch(error => { 
           // console.log('health report error', error); vhrArrived = true; clearInterval(interval);
         })
        getMaintenanceMindersListCard({ ownershipId: this.context.product.ownershipId, productId: this.context.product.productId }).then((result) => {
            //console.log('@getMaintenanceMindersListCard result: - ', result);
            clearInterval(interval);
            // this.isDataLoading = false;
            if (result.length) {
                this.hasMaintenanceMinders = true;
                this.vehicleHealthReport.maintenanceMinderCode = result[0].Maintenance_Code__c ?? '';
                this.vehicleHealthReport.legalDecription = result[0].Service_Item_Description__c ?? '';
            } else {
                this.vehicleHealthReport.maintenanceMinderCode = 'Maintenance Minder';
                this.vehicleHealthReport.legalDecription = 'There are no recommended  service items at this time.';
                this.hasMaintenanceMinders = false;
                //console.log('@getMaintenanceMindersListCard - No Minders Available');
            }
        }).catch(error => {
             //console.log('@getMaintenanceMindersListCard Error', error); clearInterval(interval); /* this.isDataLoading = false; */
             })
        /* if(vhrArrived && mmArrived){
            this.isDataLoading = false;
        } */
    }
    async getRecalls() {
        let recallsData = await getRecalls(this.context);
        this.recallsCount = recallsData.length;
    }
    async handleHeader() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        await this.sleep(2000);
        this.publishToChannel(message);
        this.navigate('/help-center', {});

    }
    handleViewAllMaintenanceMinders() {
        this.division = this.context.product.division;
        let label = window.location.href.includes('service') ? this.division + ': Service & Maintenance' : this.division + ': Overview';
        let backLink = {
            label: label,
            url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
        };
        sessionStorage.setItem('backlink', JSON.stringify(backLink));
        if (this.division == 'Acura') {
            this.navigate('/acura-accelerated-service', {});
        }
        if (this.division == 'Honda') {
            this.navigate('/honda-maintenance-minder', {});
        }

    }
    async handleViewHealthReport() {
        this.division = this.context.product.division;
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title+':'+this.actiontitle
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        let label = window.location.href.includes('service') ? this.division + ': Service & Maintenance' : this.division + ': Overview';
        let backLink = {
            label: label,
            url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
        };
        sessionStorage.setItem('backlink', JSON.stringify(backLink));
        if (this.division == 'Acura') {
            await this.sleep(2000);
            this.navigate('/acura-vehicle-report', {});
        }
        if (this.division == 'Honda') {
            await this.sleep(2000);
            this.navigate('/honda-vehicle-report', {});
        }
    }
    handleAction() {
        console.log('action');
    }
    handleScheduleService() {
        this.navigate('/find-a-dealer', {});

    }
    handleFooter() {
        console.log('footer');
    }
    getDateString(d) {
        return d.substring(0, d.lastIndexOf("T")).split("-")[1] + "/" + d.substring(0, d.lastIndexOf("T")).split("-")[2] + "/" + d.substring(0, d.lastIndexOf("T")).split("-")[0];
    }
    numberWithCommas(x) {
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + '.00';
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
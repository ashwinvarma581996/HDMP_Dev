import { track ,LightningElement } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getMaintenanceMinder from '@salesforce/apex/ownMaintenanceMinderController.getMaintenanceMindersList';
import { viewProduct, getOrigin, setOrigin, addProduct, getGarageURL, getContext, setProductContextUser, getProductContext } from 'c/ownDataUtils';
export default class ownVehicleReportMaintenanceMinder extends OwnBaseElement {
@track maintenanceMinders ;
@track title = 'Recommended Services';
    @track titlecolor;
    @track icon;
    @track brand = 'default';
    @track showFooter = true;
    @track date;
    @track division;
    @track naviagtetomaintenanceurl;

connectedCallback() {
    /*if(document.title == 'Garage' || document.title == 'Garage'){
       * this.cardDivClass = 'overview-tab-class';*/
        console.log('Document title ::: ');
   // }
    this.initialize();
}
    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            //this.context = await getProductContext('', false);
            this.context = await getProductContext('', false);
            //console.log('context from server - ',JSON.parse(JSON.stringify(this.context)));
        }
        if(this.context && this.context.product && this.context.product.division){
            this.division = this.context.product.division;
        }
        //console.log('context-------->', this.context);
        //console.log('context-----divisionId--->', this.context.product.divisionId);
        this.getMaintenanceMinder();
        this.naviagtetomaintenance();
    }
    getMaintenanceMinder(){
        getMaintenanceMinder({ ownershipId: this.context.product.ownershipId, productId: this.context.product.productId }).then((result) => {
            //this.vehicleHealthReport.maintenanceMinder = result.Legal_Description__c;
            //console.log('VehicleHealthReport w maintenance', result);
            this.maintenanceMinders = result;
        }).catch(error => { console.log('health report error', error); })

    }
    naviagtetomaintenance(){
        this.division = this.context.product.division;
        if(this.division== 'Acura'){
            this.naviagtetomaintenanceurl = './acura-accelerated-service' ;
        }
        if(this.division== 'Honda'){
            this.naviagtetomaintenanceurl = './honda-maintenance-minder' ;
        }
    }

}
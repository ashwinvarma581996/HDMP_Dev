import { track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getMaintenanceMinder from '@salesforce/apex/ownMaintenanceMinderController.getMaintenanceMindersList';

export default class ownMaintenanceMinderDetailCard extends OwnBaseElement {
    @track maintenanceMinders;
    @track title = 'Recommended Services';
    @track titlecolor;
    @track icon;
    @track brand = 'default';
    @track showFooter = true;
    @track date;
    @track division;
		@track subheadingText = '';
    @track maintenanceMinders;
    @api isGuest;
    @api context;
    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/recall-overview.svg';
        this.initialize();
    }
    initialize = async () => {
        //console.log('ownMaintenanceMinderDetailCard: CONTEXT-', JSON.parse(JSON.stringify(this.context)));
        this.getMaintenanceMinder();
    }
    getMaintenanceMinder() {
        getMaintenanceMinder({ ownershipId: this.context.product.ownershipId, productId: this.context.product.productId }).then((result) => {
            //console.log('VehicleHealthReport w maintenance', result);
						result.forEach(mm => {
								this.subheadingText = this.subheadingText + ', ' + mm.Maintenance_Code__c;
						});
            this.maintenanceMinders = result;
        }).catch(error => { 
            //console.log('health report error', error); 
        })

    }

}
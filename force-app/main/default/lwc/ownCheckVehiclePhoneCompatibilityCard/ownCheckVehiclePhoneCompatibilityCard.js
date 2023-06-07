//============================================================================
// Title:    Honda Owners Experience - Check Phone Compatibility Card
//
// Summary:  This Card links to the Check Phone Compatibility
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnCheckVehiclePhoneCompatibilityCard extends OwnBaseElement {

    @api title = 'CHECK FOR VEHICLE PHONE COMPATIBILITY';
    @api icon = 'utility:connected_apps';
    @api titlecolor='Honda Red';
    @api brand='acura';
    @track showFooter = false;

    handleHeader(){
        this.navigate('/help-center', {});
    }

    handleAction(){
       // console.log('action');
    }

    handleFooter(){
       // console.log('footer');
    }
}
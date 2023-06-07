//============================================================================
// Title:    Honda Owners Experience - Update Vehicle Software Card
//
// Summary:  This Card links to the Update Vehicle Software
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnUpdateYourVehicleSoftwareCard extends OwnBaseElement {

    @api title = 'UPDATE YOUR VEHICLE SOFTWARE';
    @api icon = 'utility:connected_apps';
    @api titlecolor='Honda Red';
    @api brand='acura';
    @track showFooter = false;

    handleHeader(){
        this.navigate('/help-center', {});
    }

    handleAction(){
        console.log('action');
    }

    handleFooter(){
        console.log('footer');
    }
}
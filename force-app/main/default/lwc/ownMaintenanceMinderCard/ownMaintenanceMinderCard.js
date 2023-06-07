//============================================================================
// Title:    Honda Owners Experience - Maintenence Minder Card
//
// Summary:  This Card links to the Maintenence Minder
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnMaintenanceMinder extends OwnBaseElement {

    @api title = 'MAINTENANCE MINDER';
    @api titlecolor = 'Honda Red';
    @api brand = 'acura';
    @track showFooter = false;
    @api icon = 'utility:connected_apps';

    handleHeader(){
        this.navigate('/help-center', {});
    }

    handleAction(){
        //console.log('action');
    }

    handleFooter(){
        //console.log('footer');
    }
}
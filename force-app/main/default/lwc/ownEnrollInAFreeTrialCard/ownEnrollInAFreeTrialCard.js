//============================================================================
// Title:    Honda Owners Experience - Free Trial Card
//
// Summary:  This Card links to the Free Trial
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnEnrollInAFreeTrialCard extends OwnBaseElement {
   
    @api title = 'ENROLL IN A FREE TRIAL';
    @api titlecolor = 'Honda Red';
    @api brand = 'acura';
    @api icon = 'utility:connected_apps';
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
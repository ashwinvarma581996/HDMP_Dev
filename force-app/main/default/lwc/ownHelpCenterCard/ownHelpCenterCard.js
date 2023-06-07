//============================================================================
// Title:    Honda Owners Experience - Help Center Card
//
// Summary:  This Card links to the Help Center
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { LightningElement,api,track } from 'lwc';

export default class OwnHelpCenterCard extends LightningElement {
    @api title = 'HELP CENTER';
    @api icon = 'utility:connected_apps';
    @api titlecolor='Honda Red';
    @api brand='acura';
    @track showFooter = false;

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
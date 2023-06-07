//============================================================================
// Title:    Honda Owners Experience - Accessories Card
//
// Summary:  This Card links to the Accessories
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { LightningElement,api,track} from 'lwc';

export default class OwnAccessoriesCard extends LightningElement {
    @api title = 'ACCESSORIES';
    @api icon = 'utility:connected_apps';
    @api titlecolor='Honda Red';
    @api brand='acura';
    @track showFooter = false;
    @track showForwardIcon = true;


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
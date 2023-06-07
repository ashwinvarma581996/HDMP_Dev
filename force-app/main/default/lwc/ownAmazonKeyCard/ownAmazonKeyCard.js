//============================================================================
// Title:    Honda Owners Experience - Amazon Key Card
//
// Summary:  This Card links to the Amazon Key
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track} from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnAmazonKey extends OwnBaseElement {

    @api title = 'AMAZON KEY';
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
//============================================================================
// Title:    Honda Owners Experience - Finance Options Card
//
// Summary:  This Card links to the Finance Options
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnSpecialFinancingOffer extends OwnBaseElement {

    @api title = 'VIEW FINANCING OPTIONS';
    @api icon = 'utility:connected_apps';
    @api titlecolor='Honda Red';
    @api brand='default';
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
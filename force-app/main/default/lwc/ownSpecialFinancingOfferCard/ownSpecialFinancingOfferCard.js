//============================================================================
// Title:    Honda Owners Experience - Special Financing Card
//
// Summary:  This Card links to the Special Financing
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnSpecialFinancingOffer extends OwnBaseElement {

    @api title = 'SPECIAL FINANCING OFFER';
    @api titlecolor = 'Honda Red';
    @api brand = 'acura';
    @api icon = 'utility:connected_apps';
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
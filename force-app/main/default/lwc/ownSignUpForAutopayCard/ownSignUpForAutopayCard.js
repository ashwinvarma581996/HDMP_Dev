//============================================================================
// Title:    Honda Owners Experience - Autopay Card
//
// Summary:  This Card links to the Autopay
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnSignUpForAutopayCard extends OwnBaseElement {
    @api title = 'SIGN UP FOR AUTO PAY';
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
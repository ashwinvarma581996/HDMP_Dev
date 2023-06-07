//============================================================================
// Title:    Honda Owners Experience - View My Subscriptions Card
//
// Summary:  This Card links to the View My Subscriptions
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnViewMySubscriptionsCard extends OwnBaseElement {

    
    @api title = 'VIEW MY SUBSCRIPTIONS';
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
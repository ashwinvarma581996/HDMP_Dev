//============================================================================
// Title:    Honda Owners Experience - Parts Card
//
// Summary:  This Card links to the Parts
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { LightningElement,api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnPartsCard extends  OwnBaseElement{
    @api title = 'parts';
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
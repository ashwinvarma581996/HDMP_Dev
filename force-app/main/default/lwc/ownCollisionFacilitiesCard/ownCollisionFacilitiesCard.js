//============================================================================
// Title:    Honda Owners Experience - Collision Facilities Card
//
// Summary:  This Card links to the Collision facilities
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { LightningElement, api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnCollisionFacilitiesCard extends OwnBaseElement {
    @api title = 'Profirst Certified Collision Facilities';
    @api icon = 'utility:custom_apps';
    @api titlecolor='Honda Red';
    @api brand='honda';
    @track showFooter = false;
    @track actionbuttonlabel = 'LEARN MORE';
    @track titleclass = 'slds-text-heading_small title';

    handleHeader(){
        console.log('Header');
    }

    handleAction(){
        console.log('action');
    }

    handleFooter(){
        console.log('footer');
    } 
    
    handleClickAction(){
        this.navigate('/', {});
    }

}
//============================================================================
// Title:    Honda Owners Experience - Fuel Recomendations Card
//
// Summary:  This Card links to the Fuel Recomendations
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnFuelRecommendationsCard extends OwnBaseElement {

    @api title = 'FUEL RECOMMENDATIONS';
    @api icon = 'utility:custom_apps';
    @api titlecolor = 'Honda Red';
    @api brand = 'marine';
    @track showFooter = false;
    @track iconImage = this.myGarageResource() + '/ahmicons/fuel.svg';

    @track cardDivClass = '';

    connectedCallback() {
        if (document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage') {
            this.cardDivClass = 'overview-tab-class';
            //console.log('Document title ::: ', document.title);
        }
    }

    handleHeader() {
        this.navigate('/help-center', {});
    }

    handleAction() {
        //console.log('action');
    }

    handleFooter() {
        //console.log('footer');
    }
}
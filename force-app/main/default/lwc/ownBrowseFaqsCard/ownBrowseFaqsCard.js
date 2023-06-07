//============================================================================
// Title:    Honda Owners Experience - Browse FAQs Card
//
// Summary:  This Card links to the Browse FAQs
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { track,api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class ownBrowseFAQsCard extends OwnBaseElement {

    @api title = 'browse faqs';
    @api icon = 'utility:connected_apps';
    @api titlecolor='Honda Red';
    @api brand='acura';
    @track showFooter = false;

    connectedCallback(){
        //console.log('brand',this.brand);
    }
    handleHeader(){
        this.navigate('/help-center', {});
    }

    handleAction(){
        //console.log('action');
    }

    handleFooter(){
       // console.log('footer');
    }  
}
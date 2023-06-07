//============================================================================
// Title:    Honda Owners Experience - Quick Start Guide Card
//
// Summary:  This Card links to the Quick Start Guide
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import {  getOrigin, ISGUEST, getProductContext } from 'c/ownDataUtils';


export default class OwnQuickStartGuideCard extends OwnBaseElement {

    @api title = 'QUICK START GUIDE';
    @api icon = 'utility:connected_apps';
    @api titlecolor='Honda Red';
    @api brand='acura';
    @api showFooter = false;
    @track context;

    connectedCallback() {
        this.initialize();
    }

    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
    }

    handleHeader(){
        // this.navigate('/help-center', {});
        let division = '';
        if(this.context.product.division == 'Marine'){
            division = 'Marine';
        }else{
            division = 'Honda';
        }
        sessionStorage.setItem('quickStartContext',JSON.stringify({brand: division}));
        this.navigate('/quick-start-guide', {});
    }

    handleAction(){
        console.log('action');
    }

    handleFooter(){
        console.log('footer');
    }
}
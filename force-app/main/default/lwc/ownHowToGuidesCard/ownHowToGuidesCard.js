//============================================================================
// Title:    Honda Owners Experience - How To Guide Card
//
// Summary:  This Card links to the How To Guide
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnHowToGuidesCard extends OwnBaseElement {
   
    @api title = 'How to Guides';
    @api icon = 'utility:connected_apps';
    @api titlecolor='Honda Red';
    @api brand='acura';
    @api showFooter = false;
    @api actiontitle = 'Browse All';
    //@api actionicon = 'utility:forward';

    @track cardDivClass = '';
    
    connectedCallback(){
        //console.log('How to guides Document title ::: ', document.title);
        //console.log('how-toguides--->', JSON.parse(sessionStorage.getItem('CFhowtoguides')));
        if(document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage' ||  document.title == 'Garage' ||  document.title == 'Garage'){
            this.cardDivClass = 'overview-tab-class';
            //console.log('Document title ::: ', document.title);
        }
    }

    handleHeader(){
        this.navigate('/help-center', {});
    }

    handleAction(){
        //console.log('action');
    }

    handleFooter(){
        //console.log('footer');
    }
}
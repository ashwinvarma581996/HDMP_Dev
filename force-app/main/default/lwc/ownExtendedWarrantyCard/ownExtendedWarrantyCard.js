//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Owners Garage Find - Honda Auto Body Honda Link logic of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the own garage find honda body honda link component for all community pages.
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { LightningElement, api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnExtendedWarrantyCard extends OwnBaseElement {
    @api title = 'EXTENDED WARRANTY';
    @api icon = 'utility:custom_apps';
    @api titlecolor='Honda Red';
    @api brand='honda';
    @track showFooter = false;

    handleHeader(){
        console.log('Header');
    }

    handleAction(){
        console.log('action');
    }

    handleFooter(){
        console.log('footer');
    }  

}
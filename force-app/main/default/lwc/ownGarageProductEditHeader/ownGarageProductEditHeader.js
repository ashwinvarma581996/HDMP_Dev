//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Owners Garage Find - Honda Auto Body logic of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the own garage find honda body component for all community pages.
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnGarageProductEditHeader extends OwnBaseElement {
    @api context;

    handleClose(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('mode', {
            detail: {
                mode: 'view'
            }
        });
        this.dispatchEvent(selectEvent);
    }
}
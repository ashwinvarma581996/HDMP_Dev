//============================================================================
// Title:    Honda Owners Experience - Header
//
// Summary:  logo logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the logo component for all help center pages.
//
//
// History:
// June 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnLogo extends OwnBaseElement {
    @track logo = this.ownerResource() + '/Logos/owners_logo.svg';
    @track menuSmall = this.ownerResource() + '/Icons/burger_menu.svg';

    handleMenuClick(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('select', {
            detail: { 
                showMainMenu: true
            }
        });
        this.dispatchEvent(selectEvent);
    }

    handleClick() {
        // let eventMetadata = {
        //     action_type: 'image',
        //     action_category: 'header',
        //     action_label: 'my garage logo'
        // };
        // let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        // this.publishToChannel(message);
        // await this.sleep(2000);
        this.navigate('/', {});
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
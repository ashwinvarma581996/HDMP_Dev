//============================================================================
// Title:    Honda Owners Experience - Help Center
//
// Summary:  Popular help video logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the search bar component for all help center pages.
//
//
// History:
// May 17, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnHelpCenterPopularHelpVideo extends OwnBaseElement {
    @track title = 'Popular Help Videos';
}
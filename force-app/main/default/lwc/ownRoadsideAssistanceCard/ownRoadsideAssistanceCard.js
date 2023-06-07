//============================================================================
// Title:    Honda Owners Experience - Roadside Assistance Card
//
// Summary:  This Card links to the Roadside Assistance
//
//
// History:
// October 1, 2021 Ravindra (Wipro) Original Author
//=========================================================================== -->
import { LightningElement,track,api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
export default class OwnRoadsideAssistanceCard extends OwnBaseElement {

    @api contentData;
    @api pageDetail;
    showFooter = false;
    slotBrand = 'default';

    handlePageLinkClick(event) {
        event.preventDefault();
        localStorage.setItem('breadcrumb', JSON.stringify(this.pageDetail));
        this.navigate('/roadside-assistance', {});
    }
    handleHeader() {
        localStorage.setItem('breadcrumb', JSON.stringify(this.pageDetail));
        this.navigate('/roadside-assistance', {});
        // if (!this.contentData.findOutMore) {
        //     this.navigate('/roadside-assistance', {});
        // }
    }

    handleAction() {
        console.log('action');
    }

    handleFooter() {
        console.log('footer');
    }

}
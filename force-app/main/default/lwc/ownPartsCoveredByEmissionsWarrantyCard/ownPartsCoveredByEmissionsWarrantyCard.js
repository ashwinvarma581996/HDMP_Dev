//============================================================================
// Title:    Honda Owners Experience - Emissions Warranty Card
//
// Summary:  This Card links to the  Emissions Warranty
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { LightningElement,api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnPartsCoveredByEmissionsWarranty  extends OwnBaseElement {

        @api title = 'PARTS COVERED BY EMISSIONS WARRANTY';
		@api icon = 'utility:connected_apps';
		@api titlecolor='Honda Red';
		@api brand='honda';
		@track showFooter = false;
	
		handleHeader(){
			this.navigate('/help-center', {});
		}
	
		handleAction(){
			console.log('action');
		}
	
		handleFooter(){
			console.log('footer');
		}
}
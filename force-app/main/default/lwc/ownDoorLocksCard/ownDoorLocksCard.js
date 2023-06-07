//============================================================================
// Title:    Honda Owners Experience - Door Locks Card
//
// Summary:  This Card links to the Door Locks
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnDoorLocks extends OwnBaseElement {
	@api title = 'DOOR LOCKS';
    @api icon = 'utility:connected_apps';
	@api titlecolor='Honda Red';
	@api brand='acura';
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
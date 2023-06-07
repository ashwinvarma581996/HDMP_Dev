//============================================================================
// Title:    Honda Owners Experience - Collision Mitigating Card
//
// Summary:  This Card links to the Collision Mitigating
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class ownCollisionMitigatingBrakingSystemCard extends OwnBaseElement {

    @api title = 'COLLISION MITIGATION BRAKING SYSTEM';
    @api icon = 'utility:connected_apps';
	@api titlecolor='Honda Red';
	@api brand='default';
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
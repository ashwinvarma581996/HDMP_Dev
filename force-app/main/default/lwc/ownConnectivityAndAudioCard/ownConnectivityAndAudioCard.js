//============================================================================
// Title:    Honda Owners Experience - Connectivitiy and Audio Card
//
// Summary:  This Card links to the Connectivitiy and Audio
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnConnectivityAndAudio extends OwnBaseElement {
	@api title = 'CONNECTIVITY & AUDIO';
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
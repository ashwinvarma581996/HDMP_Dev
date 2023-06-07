//============================================================================
// Title:    Honda Owners Experience - Bluetooth Card
//
// Summary:  This Card links to the Bluetooth
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnConnectMobileDeviceViaBluetoothCard extends OwnBaseElement {

    @api title = 'CONNECT MOBILE DEVICE VIA BLUETOOTH';
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
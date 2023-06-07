import { api,track } from 'lwc';
import commonResources from "@salesforce/resourceUrl/Owners";
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnFindDealersCard extends OwnBaseElement {
    @api mapImage = commonResources + '/images/map.jpg';

    @api title = 'LOCATE A DEALER';
    @api icon = 'utility:connected_apps';
    @api titlecolor='Honda Red';
    @api brand='honda';
    @api actiontitle = 'Find Dealers';
    @api actionicon;
    @api isprotectionplanpage = false;
    @track showFooter = false;

    handleHeader(){
        this.navigate('/help-center', {});
    }

    handleAction(){
        //console.log('action');
    }

    handleFooter(){
        //console.log('footer');
    }
}
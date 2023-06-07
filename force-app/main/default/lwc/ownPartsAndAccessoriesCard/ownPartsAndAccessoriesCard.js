import { api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnPartsAndAccessoriesCard extends OwnBaseElement {

    @api title = 'Parts & accessories';
    @api titlecolor = 'Honda Red';
    @api brand = 'acura';
    @track showFooter = false;
    @track showForwardIcon = true;
    @api icon = 'utility:connected_apps';

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
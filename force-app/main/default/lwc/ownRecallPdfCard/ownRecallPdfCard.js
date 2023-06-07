import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
export default class OwnRecallPdfCard extends OwnBaseElement {
    @api title;;
    //@api icon = 'utility:connected_apps';
    @api iconImage = this.myGarageResource() + '/ahmicons/' + 'black-booklet.svg';
    @api brand;
    @api titlecolor = 'Honda Red';
    @track showFooter = false;
    @track showForwardIcon = false;

    handleHeader(){
        //this.navigate('/help-center', {});
    }

    handleAction(){
        console.log('action');
    }

    handleFooter(){
        console.log('footer');
    }
}
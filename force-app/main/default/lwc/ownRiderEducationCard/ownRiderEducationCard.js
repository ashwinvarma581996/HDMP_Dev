import { track,api} from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
export default class OwnRiderEducationCard extends OwnBaseElement {

    @api title = 'RIDER EDUCATION CENTER';
    @api icon = this.myGarageResource() + '/ahmicons/questionmark.svg';
    @api titlecolor='Honda Black';
    @api brand='marine';
    @track showFooter = false;

    handleHeader(){
        console.log('Header');
    }

    handleAction(){
        console.log('action');
    }

    handleFooter(){
        console.log('footer');
    }   

}
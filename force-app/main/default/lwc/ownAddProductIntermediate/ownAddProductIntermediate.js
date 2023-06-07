import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import AddToGarageMsg from '@salesforce/label/c.Add_Product_Message';
import RemoveFromGarageMsg from '@salesforce/label/c.Remove_Product_Message';


export default class OwnAddProductIntermediate extends OwnBaseElement {
    @track logo = this.ownerResource() + '/Logos/owners_logo.svg';
    @track Msg = AddToGarageMsg;

    @api
    get msg(){
        let redirect = sessionStorage.getItem('redirectMsg');
        let msg;
        if (redirect === 'originAdd'){
            msg = AddToGarageMsg;
        }
        else if (redirect === 'remove'){
            msg = RemoveFromGarageMsg;
        }
        return msg;
    }

    connectedCallback(){
        setTimeout(() => {
            this.template.querySelector('.loader-wrapper').style.display = 'none';
        }, 5000);
    }
}
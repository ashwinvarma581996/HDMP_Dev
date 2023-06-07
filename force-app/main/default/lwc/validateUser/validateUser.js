import { LightningElement } from 'lwc';
import user_Id from '@salesforce/user/Id';
import createPermissions from '@salesforce/apex/B2BGuestUserController.createPermissionSetsSynchronous';

const CART_ID_PARAM = 'cartId';
const CART_PAGE_URL = '/s/cart/';
export default class ValidateUser extends LightningElement {

    cartId;
    userId = user_Id;
    connectedCallback(){
        this.cartId = new URLSearchParams(window.location.search).get(CART_ID_PARAM);
        console.log('user id ----' + this.userId);
        createPermissions({userId : this.userId})
        .then(result => {
            console.log('response from apex--' + JSON.parse(JSON.stringify(result)));
            if(result){
               window.location.assign(window.location.origin + CART_PAGE_URL + this.cartId);
            }
        })
        .catch(error => {
            console.error('error valiating the user----' + error);
        })
    }
}
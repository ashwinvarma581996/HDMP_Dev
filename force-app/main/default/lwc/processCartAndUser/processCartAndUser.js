import { LightningElement,track } from 'lwc';
import user_Id from '@salesforce/user/Id';
import createPermissions from '@salesforce/apex/B2BGuestUserController.createPermissionSetsSynchronous';
import handleCartChange from '@salesforce/apex/B2B_HandleCartAndUser.handleCart'; 

const CART_ID_PARAM = 'cartid';
const CART_PAGE_URL = '/s/cart/';
export default class ValidateUser extends LightningElement {
    
    @track cartId;
    @track userId = user_Id;
    connectedCallback(){
        createPermissions({userId : this.userId})
        .then(result => {
            if(result){
                const queryString = window.location.search;
                const urlParams = new URLSearchParams(queryString);
                const returnUrl = urlParams.get('returnUrl');
                const returnUrlDecoded = decodeURIComponent(returnUrl);
                if (queryString.indexOf('cartI') !== -1){
                    this.cartId = urlParams.get('cartId');
                }
                if(this.cartId !=='' || this.cartId !==Null){
                    handleCartChange({userId : this.userId, cartId: this.cartId,brand:sessionStorage.getItem('brand')})
        .then(result => {
            // Added by saikiran as part of HDMP-14327
            if(result=='success'){
                sessionStorage.setItem('successmsg',result);
            }
            window.location.assign(window.location.origin + returnUrlDecoded);
        })
        .catch(error => {
            console.error('error valiating the user----' + error);
        })
    }else
    {
        window.location.assign(window.location.origin + returnUrlDecoded);
    }
}
else
{
    window.location.assign(window.location.origin);
}
})
.catch(error => {
            console.error('error valiating the user----' + error);
        })
        
    }
}
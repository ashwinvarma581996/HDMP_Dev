import { LightningElement,track } from "lwc";
import getRedirectValue from '@salesforce/label/c.SNA_Label';

export default class Sna_Redirect extends LightningElement{ 

    
    connectedCallback(){
            console.log('url ',window.location.origin);
            if(getRedirectValue.toLowerCase()=='true'){
                let baseURL = window.location.origin;
                window.location.href = baseURL + '/s/servicedown';
              
            }
    }

}
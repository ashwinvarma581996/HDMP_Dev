/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 09-30-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
import { LightningElement } from 'lwc';
import RESOURCES from '@salesforce/resourceUrl/res_resources' ;

export default class Res_header extends LightningElement {

imgUrl ;

connectedCallback()
{
  this.imgUrl = RESOURCES + '/acura_logo.png' ;
}
  
  renderedCallback(){
        //code
        var currUrl = window.location.href;
        if (!currUrl.includes('personal-information?data=')){
            this.template.querySelector(".header").style.display='flex';
        }
    }

}
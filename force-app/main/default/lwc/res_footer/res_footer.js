/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 11-11-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { subscribe, MessageContext } from 'lightning/messageService';
import TAG_PARAMETER_UPDATE from '@salesforce/messageChannel/Tag_Parameter_Update__c';

export default class res_footer extends  NavigationMixin(LightningElement)
{
 
    @wire(MessageContext)
    messageContext;
    
    currentPageReference = null ;
    modelName ;
    modelYear ;
    bodyStyle ;

  @api
  set header(value) {
      this.hasHeaderString = value !== '';
      this._headerPrivate = value;
  }
  
  get header() {
      return this._headerPrivate;
  }

  hasHeaderString = false;
  _headerPrivate;
  termsLink ;

  connectedCallback(){
      this.subscribeToMessageChannel() ;
      this[NavigationMixin.GenerateUrl]({ type: 'comm__namedPage', attributes: { name: 'Terms_and_Conditions__c' } })
        .then(url => { this.termsLink = url }) 
        .catch( () => { this.termsLink = '../s/terms-and-conditions' }) ;
  }

  subscribeToMessageChannel() {
    this.subscription = subscribe(
        this.messageContext,
        TAG_PARAMETER_UPDATE,
        (message) => this.handleMessage(message)
    );
}

    // Handler for message received by component
    handleMessage(message) {
        this.modelName = message.modelName ;
        this.modelYear = message.modelYear ;
        this.bodyStyle = message.bodyStyle ;
    }
  
  	renderedCallback(){
        //code
        var currUrl = window.location.href;
        if (!currUrl.includes('personal-information?data=')){
            this.template.querySelector(".acr-footer").style.display='block';
        }
    }
 
}
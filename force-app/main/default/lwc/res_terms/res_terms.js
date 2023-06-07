/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 02-26-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
import { LightningElement, track, wire} from 'lwc';
import { NavigationMixin , CurrentPageReference } from 'lightning/navigation';

export default class res_terms extends NavigationMixin(LightningElement) {
  @track modelname;
  
  currentPageReference = null; 
  urlStateParameters = null ;
  
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
      if (currentPageReference) {
        this.urlStateParameters = currentPageReference.state;
        this.setParametersBasedOnUrl();
      }
  }

  setParametersBasedOnUrl() {
    this.modelname = this.urlStateParameters.model || 'Integra' ;
  }


  //back to personal Info page
  backtoPersonalInfo() {
      window.close() ;
  }

}
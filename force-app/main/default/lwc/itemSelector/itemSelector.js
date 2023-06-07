import { LightningElement  } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Narrow extends NavigationMixin(LightningElement) {
  
    handleClick(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }



}
import { LightningElement,track,api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnSignUpForUpdatesCard extends OwnBaseElement {
    
    @api title = 'SIGN UP FOR UPDATES';    
    @api icon = 'utility:custom_apps';
    @api titlecolor='Honda Red';
    @api brand='marine';
    @track showFooter = false;
            
    handleHeader(){
        this.navigate('/help-center', {});
    }
            
    handleAction(){
        console.log('action');
    }
            
    handleFooter(){
        console.log('footer');
    }
}
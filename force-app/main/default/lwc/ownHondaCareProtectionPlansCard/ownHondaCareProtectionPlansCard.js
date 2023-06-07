import { LightningElement,track,api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnHondaCareProtectionPlansCard extends OwnBaseElement {
    @api title = 'HONDACARE® PROTECTION PLANS';
    @api icon = 'utility:connected_apps';
    @track service = 'SCHEDULE SERVICE';
    @api brand='honda';
    @api titlecolor = 'Honda Red';
    @track showFooter = false;
    @track showForwardIcon = false;

    @api
    body;
    @api source;
    connectedCallback(){
        this.icon = this.ownerResource() + '/Icons/chat.png';
    }
    //modified by Yusuf Deshwali to implement navigate functionlity for powersports 
    handleHeader(){
        let url = window.location.href;
        if(this.brand === 'powersports'){
            let breadcrumb = { 
                label : this.source, 
                value : this.source, 
                url : url,
                type : '',
            };
            if(this.source === 'Help Center'){
                breadcrumb.isGeneric = true;
            }
            //useing local storage for set breadcrumb
            localStorage.setItem('breadcrumb', JSON.stringify(breadcrumb));
            this.navigate('/hondacare-protection-plan', {});
        }else{
            this.navigate('/help-center', {});
        }
    }

    handleAction(){
        //console.log('action');
    }

    handleFooter(){
        //console.log('footer');
    }
}
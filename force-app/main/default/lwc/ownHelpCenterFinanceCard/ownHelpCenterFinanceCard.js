import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import link from '@salesforce/label/c.Finance_Link';

export default class OwnHelpCenterFinanceCard extends OwnBaseElement {
    label = {
        link
    };
    @api title ;
    @api icon ;
    //utility:call
    @api titlecolor ;
    @api brand='marine';
    @track iconImage;
    @track showFooter = false;
    @api showforwardicon ;
    @api headerlink ;
    @api forwardiconright ;
    @track isBrandAcura = false;
    @track isBrandMarine = false;
    @track isBrandHonda = false;
    @track isBrandPE = false;
    @track isBrandPS = false;
    @api headerRightIcon= 'utility:forward';
  
    

    connectedCallback() {
        //this.brand = 'acura';
        //this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }
    initialize = async () => {
       // console.log(
       
        if(document.URL.includes('help-acura')){
            this.isBrandAcura = 'true' ;
        }
        if(document.URL.includes('help-honda')){
            this.isBrandHonda = 'true' ;
        }
        if(document.URL.includes('help-powerequipment')){
            this.isBrandPE = 'true' ;
        }
        if(document.URL.includes('help-marine')){
            this.isBrandMarine = 'true' ;
        }
        if(document.URL.includes('help-powersports')){
            this.isBrandPS = 'true' ;
        }
       // }
    }
   /* get isBrandAcura(){
        if(document.URL == 'Help Acura'){
            this.isBrandAcura = true ;
        }
    }*/
            
   get titleClass(){
    //return this.titlecolor === 'Honda Red';
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : this.titlecolor === 'Black' ? 'slds-text-heading_small title black' : 'slds-text-heading_small title';
    } 
    get bodyClass(){
        let cardBodyClass = this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
        cardBodyClass = this.hideBodySection ? '' : cardBodyClass;
        return cardBodyClass;
    }
    get iconClass(){
        let colorClass = this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
        if(this.forwardiconright) {
            colorClass += ' forward-icon-right';
        }
        return colorClass;
    }
        //return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    
    handleClickHeader(){
        //this.navigate('/help-center', {});
    }
            
    handleAction(){
        //console.log('action');
    }
    handleBreadcrumbClick(){
      //  let url = label.headerlink;
        //console.log('url',url);
        this.naviagte(url,{});
    }
            
    handleFooter(){
        //console.log('footer');
    }

}
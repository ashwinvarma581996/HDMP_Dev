import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST, getProductContext, getContext, getOrigin } from 'c/ownDataUtils';

export default class ownProduct extends OwnBaseElement {
    @track context;
    @track isGuest = ISGUEST;
    @track spinnerSize = "large";
    @track displaySpinner = false;
    @track displayRecallBanner = false;

    @api contentId;
    @api safetyAlertsTopic;
    @api productAlertsTopic;
    
    /* @api
    get displayRecallBanner(){
        console.log('DISPLAYRECALLBANNER DEBUG ' + JSON.stringify(this.context));
        return this.context.product.recallCount > 0;
    } */
    
    initialize = async () => {
        // this.context = await getContext('');
      //  this.displaySpinner = false;
      let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
      if (fromProductChooser) {
        this.context = await getProductContext('', true);
      } else {
        this.context = await getProductContext('', false);
      }
      if(this.context && this.context.product){
        let divisionName = this.context.product.division == 'Powerequipment' ? 'Power Equipment' : this.context.product.division;
        let label = window.location.href.includes('service') ? divisionName + ': Service & Maintenance' : divisionName + ': Overview';
        let backLink = {
            label: label,
            url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
        };
        sessionStorage.setItem('backlink',JSON.stringify(backLink));
      }
      this.displayRecallBanner = this.context.product.recallCount > 0;
      //console.log('CONTEXT: ownProduct ',JSON.parse(JSON.stringify(this.context)));
      //console.log('CONTEXT: ownProduct ',JSON.parse(JSON.stringify(this.context)));
      let garage = JSON.parse(localStorage.getItem('garage'));
      garage.products.forEach(product => {
        if (product.modelId == this.context.product.modelId){
            product.recallCount = this.context.product.recallCount;
        }
      });
      localStorage.setItem('garage', JSON.stringify(garage));
    };

    connectedCallback() {
      //  this.displaySpinner = true;
       // console.log('ownProduct connectedCallback');
        this.initialize();    
    }
    
    reloadContext() {
        this.initialize();
    }

    reloadCarouselGarage() {
        //console.log('%%% GARAGE RELOAD');
        this.template.querySelector("c-own-product-carousel").refreshGarage();
    }
}
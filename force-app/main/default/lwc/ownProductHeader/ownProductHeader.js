import { LightningElement,api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { NavigationMixin } from "lightning/navigation";
export default class OwnProductHeader  extends NavigationMixin(OwnBaseElement) {

    @api
    productSubTitle = '2019 HR-V LX';
    @api
    productTitle = 'Roadside Assistance';
    @api
    isGenericHeader = false;

    // @track heroAcura = this.ownerResource() + '/images/HeroAcura.png';
    @track productImage;
    @api imageUrl;
    @api brand;
    @track breadcrumbs;
    async connectedCallback() { 
        //console.log('productTitle: ',this.productTitle);
        //console.log('productSubTitle: ',this.productSubTitle);
        //console.log('imageUrl1: ',this.imageUrl);
        let breadcrumb = localStorage.getItem('breadcrumb');
        if(breadcrumb){
            //localStorage.removeItem('breadcrumb');
            breadcrumb = JSON.parse(breadcrumb);
            if(breadcrumb.label ==='Help Center'){
                breadcrumb.label = 'Back';
            }
        }else{
            breadcrumb = {};
            breadcrumb.label = 'Back';
            breadcrumb.value = 'Back';
            breadcrumb.type = '';
            breadcrumb.url = '';
        }
        this.breadcrumbs = [breadcrumb];
    }

    handleClick(event){
        localStorage.removeItem('breadcrumb');//remove breadcrumb local storage variable
        let value = event.target.dataset.value;
        let type = event.target.dataset.type;
        let url = event.target.dataset.url;
        //console.log('url: ',url);
        localStorage.setItem('backlinkvalue', value);
        Object.keys(this.breadcrumbs).forEach((index) => {
            if(this.breadcrumbs[index] && this.breadcrumbs[index].value === value){
                this.breadcrumbs.splice(parseInt(index) + 1);
            }
        });
        this.handleNavigate(type, url);
    }
    handleNavigate(type, url) {
        if(url){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: url
                }
            });
        }else{
            window.history.back();
        }
      }
}
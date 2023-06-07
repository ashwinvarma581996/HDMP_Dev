import { LightningElement, track, api} from 'lwc';
import communityId from '@salesforce/community/Id';
import getTopLevelCategories from '@salesforce/apex/B2BCategoryNavigation.getTopLevelCategories';
import {NavigationMixin} from 'lightning/navigation';

export default class b2bEBBrowseByProductLine extends NavigationMixin(LightningElement) {

    @track brands;
    @track displayComponent = false;

    @api displayLabels;

    /**
    * Browse by Product Line headings
    * @type {String}
    */
     @api subTitle;
     @api title
     

    connectedCallback() { 
        this.getCategories();
    }

    getCategories(){
        getTopLevelCategories({
            communityId: communityId
        }).then((result) => {
            this.brands = result;
            if (sessionStorage.getItem('dealer')) {
                let dealer = JSON.parse(sessionStorage.getItem('dealer'));
                if (dealer && dealer.brand && dealer.brand.length) {
                    let dealerBrand = dealer.brand.toLowerCase();
                    let newArray = this.brands.filter(item => 
                        (item.hasOwnProperty('label') && item.label.toLowerCase().includes(dealerBrand)) || 
                        (item.hasOwnProperty('name') && item.name.toLowerCase().includes(dealerBrand))
                    );
                    this.brands = newArray;
                }
            }
            let urlBrandParam = window.location.href.split('/').pop();
            if(urlBrandParam.length && (urlBrandParam == 'honda' || urlBrandParam == 'acura')){
                let resultArr = this.brands.filter(item => 
                    (item.hasOwnProperty('label') && item.label.toLowerCase().includes(urlBrandParam)) || 
                    (item.hasOwnProperty('name') && item.name.toLowerCase().includes(urlBrandParam))
                );
                this.brands = resultArr;
            }
            if(this.brands.length > 0){
                this.displayComponent = true;
            }
        })
        .catch((error) => {
            console.log(error);
        });
    }

    handleNavigation(event){
        event.preventDefault();
        let url = event.currentTarget.dataset.url;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }
}
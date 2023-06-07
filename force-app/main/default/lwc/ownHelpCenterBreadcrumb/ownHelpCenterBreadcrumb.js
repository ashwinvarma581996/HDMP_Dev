//============================================================================
// Title:    Honda Owners Experience - Help Center
//
// Summary:  Breadcrumb logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the breadcrumb component for all help center pages.
//
//
// History:
// May 17, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { brandDataCategoryMap } from 'c/ownDataUtils';

const ARRAY_OPERATION_TYPE = {
    CREATE: 'create',
    UPDATE: 'update',
    CLEAR: 'clear'
}

const HELP_CENTER_TYPE = {
    GLOBAL: 'global',
    BRAND: 'brand',
    CATEGORY: 'category',
    TAB: 'tab',
    ARTICLE: 'article'
}

export default class OwnHelpCenterBreadcrumb extends OwnBaseElement {
    @api brand;
    @track breadcrumbs = [];
    @track breadcrumbsSmall = [];

    connectedCallback(){
        this.subscribeToChannel((message) => {
            //console.log('message: ',message);  
            if(message.brand){
                this.brand = message.brand;
                this.getBreadcrumbs();
            }         
        });
        this.getBreadcrumbs();
    }

    getBreadcrumbs(){
        let isExist = false;
        Object.keys(this.breadcrumbs).forEach((index) => {
            if(this.breadcrumbs[index] && this.brand && this.breadcrumbs[index].type === this.brand.type){
                isExist = true;
                this.buildBreadcrumb(ARRAY_OPERATION_TYPE.UPDATE, index, this.brand);
            }
        });
        if(!isExist && this.brand){
            this.buildBreadcrumb(ARRAY_OPERATION_TYPE.CREATE, null, this.brand);
        } 
    }

    handleClick(event){
        let value = event.target.dataset.value;
        let type = event.target.dataset.type;
        let url = event.target.dataset.url;
        Object.keys(this.breadcrumbs).forEach((index) => {
            if(this.breadcrumbs[index] && this.breadcrumbs[index].value === value){
                this.breadcrumbs.splice(parseInt(index) + 1);
            }
        });
        this.handleNavigate(type, url);
    }

    buildBreadcrumb(operationType, index, brand){
        if(ARRAY_OPERATION_TYPE.CLEAR === operationType){
            this.breadcrumbs = [];
        }
        if(ARRAY_OPERATION_TYPE.CREATE === operationType){
            if(this.breadcrumbs && this.breadcrumbs.length === 0){
                this.breadcrumbs = [
                    { label: 'Help Center', value: 'Help Center', type: 'global' }
                ];
            }
            if(this.breadcrumbs && this.breadcrumbs.length > 0 && brand.type != this.breadcrumbs[0].type){
                if(brand.articleBrand){
                    //console.log('brand.articleBrand', brand.articleBrand);
                    let tempBrand = brand.articleBrand;

                    //Breadcrumbfix DOE-4840
                    tempBrand = (brand.articleBrand === 'AcuraAutos') ? 'Acura Autos' : tempBrand;
                    tempBrand = (brand.articleBrand === 'HondaAutos') ? 'Honda Autos' : tempBrand;
                    tempBrand = (brand.articleBrand === 'HondaPowersports') ? 'Honda Powersports' : tempBrand;
                    tempBrand = (brand.articleBrand === 'HondaPowerEquipment') ? 'Honda Power Equipment' : tempBrand;
                    tempBrand = (brand.articleBrand === 'HondaMarine') ? 'Honda Marine' : tempBrand;

                    this.breadcrumbs.push({
                        label: tempBrand + ' Help Articles & FAQs',
                        value: brand.articleBrand.split(' ').join(''),
                        type: HELP_CENTER_TYPE.BRAND,
                        url: brandDataCategoryMap.get(brand.articleBrand).url
                    });
                }
                if(brand.type != 'article'){
                    this.breadcrumbs.push({
                        label: brand.label,
                        value: brand.value,
                        type: brand.type,
                        url: brand.url
                    });
                }
                if(this.breadcrumbs.length > 1){
                    this.breadcrumbsSmall = [
                        this.breadcrumbs[this.breadcrumbs.length - 2]
                    ];
                }else {
                    this.breadcrumbsSmall = [
                        this.breadcrumbs[this.breadcrumbs.length - 1]
                    ];
                }
            }else{
                this.breadcrumbsSmall = [
                    this.breadcrumbs[this.breadcrumbs.length - 1]
                ];
            }
            
        }
        if(ARRAY_OPERATION_TYPE.UPDATE === operationType){
            this.breadcrumbs[index].value = brand.value;
            this.breadcrumbs[index].label = brand.label;
            this.breadcrumbs[index].type = brand.type;
            this.breadcrumbs[index].url = brand.url;
            this.breadcrumbsSmall = [
                this.breadcrumbs[this.breadcrumbs.length - 1]
            ];
        }
    }

    handleNavigate(type, url){
        if(type === HELP_CENTER_TYPE.GLOBAL){
            this.navigate('/help-center', {});
        }
        if(type === HELP_CENTER_TYPE.BRAND){
            this.navigate(url, {});
        }
    }
}
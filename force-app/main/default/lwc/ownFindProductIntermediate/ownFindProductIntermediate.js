import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { viewProduct, setOrigin, getOrigin } from 'c/ownDataUtils';

import getRecallsByProductIdentifier from '@salesforce/apex/OwnAPIController.getRecallsByProductIdentifier';

import { ISGUEST } from 'c/ownDataUtils';

const FIND_BRAND_BUTTON_ACTIVE = 'find-brand-button-active';
const FIND_BRAND_BUTTON_DISABLED = 'find-brand-button-disabled';


export default class OwnFindProductIntermediate extends OwnBaseElement {
    titleText = 'Multiple products found. Please select a product from the list below:';
    @track productList;
    @track selectedProduct;
    @track isGuest = ISGUEST;
    //columns = {}
    findButtonActive = FIND_BRAND_BUTTON_ACTIVE;
    findButtonDisabled = FIND_BRAND_BUTTON_DISABLED;

    @api
    get findButtonClass() {
        return this.disableFindButton ? this.findButtonDisabled : this.findButtonActive;
    }

    @api
    get disableFindButton(){
        //console.log('FINDBUTTONDISABLED: ' + this.selectedProduct);
        return this.selectedProduct ? false : true;
    }

    connectedCallback(){
        this.productList = JSON.parse(localStorage.getItem('findProductPrelim'));
        //console.log(JSON.stringify(this.productList));
    }

    handleOptionSelect(event){
        //console.log(JSON.stringify(event.detail.product));
        this.selectedProduct=event.detail.product;
    }

    handleCancel(){
        this.navigate('/find-' + this.productList[0].division.toLowerCase(), {});
    }

    handleProductSelect(){
        //console.log('SELECT');
        if (!this.isGuest){
            //console.log(1);
            this.resetGarage();
            //console.log(1);
        }
        //console.log(1);
        let origin = 'ProductChooser';
        localStorage.setItem('origin', origin);
        setOrigin('ProductChooser');
        //console.log(1);
        let product = this.selectedProduct;
        //console.log(JSON.stringify(product));
        //console.log(1);
        getRecallsByProductIdentifier({ productIdentifier: product.vin, divisionId: product.divisionId }).then((res) => {
            //console.log('RECALLS: res',res);
            if (res.response.recalls_response.response.recall.campaignType.campaign) {
                let result = JSON.parse(JSON.stringify(res.response.recalls_response.response.recall.campaignType.campaign));
                product['recalls'] = result;
                localStorage.removeItem('findProductPrelim');
                viewProduct(product);
            }else{
                localStorage.removeItem('findProductPrelim');
                viewProduct(product);
            }
        }).catch(err => {
            //console.error('RECALLS: err',err);
            localStorage.removeItem('findProductPrelim');
            viewProduct(product);
        });
        localStorage.removeItem('findProductPrelim');
        viewProduct(product);
    }

    resetGarage() {
        localStorage.removeItem('garage');
    }
}
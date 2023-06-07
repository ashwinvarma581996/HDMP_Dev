import { LightningElement, api, track } from 'lwc';

export default class OwnFindProductIntermediateOption extends LightningElement {
    @api product;
    @api selectedProduct;

    @api
    get checked(){
        //console.log('___________');
        //console.log(JSON.stringify(this.product));
        //console.log(JSON.stringify(this.selectedProduct));
        //console.log(this.product.modelId === this.selectedProduct.modelId);
        if (this.selectedProduct){
            return this.product.modelId === this.selectedProduct.modelId;
        }
        else{
            return false;
        }
    }

    handleOptionSelect(){
        //console.log('OPTION SELECT');
        this.dispatchEvent(new CustomEvent('optionselect', {detail: {'product' : this.product}}));
    }
}
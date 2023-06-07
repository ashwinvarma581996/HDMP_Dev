import { LightningElement,api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { NavigationMixin } from "lightning/navigation";
export default class OwnProductHeader  extends NavigationMixin(OwnBaseElement) {
    @api
    year;
    @api
    model;
    @api
    trim;

    @api
    nickname;

    get productSubTitle(){
        if (this.nickname){
            return this.nickname;
        }
        else{
            return (this.year ? this.year : '') + ' '
            + (this.model ? this.model : '') + ' '
            + (this.trim ? this.trim : '');
        }
    }
    set productSubTitle(value){};

    @api
    productTitle = 'Product Settings';

    @api productImage;
    @api division;

    handleImgError(event){
        //console.log('IMG ERROR: ');
        //console.log(JSON.stringify(event));
    }
}
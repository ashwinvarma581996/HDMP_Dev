import { api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getOrigin, getProductContext } from 'c/ownDataUtils';
export default class ownCaseFormLink extends OwnBaseElement {
    context;
    @api brand;
    connectedCallback() {
        if(!this.brand)
            this.initialize();
    }
    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        //console.log('$CRRS-ownCaseFormLink: context: ', JSON.parse(JSON.stringify(this.context)));
    }

    openCaseForm(){
        this.brand = this.brand ? this.brand : this.context.product.division;
        this.brand = this.brand.includes('Powersports') ? 'Powersports' : this.brand;
        //console.log('$brand: ',this.brand);
        sessionStorage.setItem('fromRecallLink', 'true');
        sessionStorage.setItem('BrandName', this.brand);
        this.navigate('/send-an-email', {});
    }
}
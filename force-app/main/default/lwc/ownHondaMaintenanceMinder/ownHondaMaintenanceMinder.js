import { track, api } from 'lwc';
import { getOrigin, getProductContext, ISGUEST, getContext } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
import hasVHR from '@salesforce/apex/ownMaintenanceMinderController.hasVHR';
export default class ownHondaMaintenanceMinder extends OwnBaseElement {
    @api contentId;
    @api contentIdMM;
    @api contentIdMA;
    @api contentIdMB;
    @api contentIdM1;
    @api contentIdM2;
    @api contentIdM3;
    @api contentIdM4;
    @api contentIdM5;
    @api contentIdM6;
    @track context;
    @track dataArrived;
    @track isGuest = ISGUEST;

    connectedCallback() {
        this.initialize();
    }

    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext('');
        }
        //console.log('ownHondaMaintenanceMinder: CONTEXT-', JSON.parse(JSON.stringify(this.context)));
        if(this.context && this.context.product && this.context.product.ownershipId && this.context.product.productId){
            if (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-')) {
                hasVHR({ownershipId: this.context.product.ownershipId, productId: this.context.product.productId}).then((result) => {
                    this.isGuest = result ? false : true;
                    this.dataArrived = true;
                }).catch((err) => {
                    //console.error('err: hasVHR ',err);
                    this.dataArrived = true;
                    this.isGuest = true;
                });
            }else{
                this.dataArrived = true;
                this.isGuest = true;
            }
        }else{
            this.isGuest = true;
            this.dataArrived = true;
        }
    }
}
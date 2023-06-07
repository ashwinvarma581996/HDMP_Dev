//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Owners Garage Find - Honda Auto Body logic of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the own garage find honda body component for all community pages.
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { updateProduct, removeProduct } from 'c/ownDataUtils';
//import getTrims from '@salesforce/apex/OwnGarageController.getTrims';
import { fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';


const SAVE_BRAND_BUTTON_ACTIVE = 'save-brand-button-active';
const SAVE_BRAND_BUTTON_DISABLED = 'save-brand-button-disabled';

export default class OwnGarageProductEdit extends OwnBaseElement {
    @api context;
    @api isguest;
    @track nickname;
    @track vin;
    @track remove = false;
    @track garage;
    @track trims;
    @track trim;
    @track colors;
    @track color;
    @track saveButtonClass = SAVE_BRAND_BUTTON_DISABLED;
    @track disabled = false;
    @track product;
    @track isChanged = false;

    @wire(CurrentPageReference) pageRef;

    connectedCallback(){
        this.nickname = this.context.product.nickname;
        this.vin = this.context.product.vin;
        //this.context = getContext('');
    }

    // @wire(getTrims, { year: parseInt('$context.product.year'), modelId: '$context.product.model' })
    // wiredGetTrims({ error, data }) {
    //     if (data) {
    //         this.trims = data;
    //         this.colors = data;
    //     } else if (error) {
    //         this.showToast_error(error);
    //     }
    // }

    handleNicknameChange(event) {
        this.isChanged = true;
        this.nickname = event.target.value;
        this.toggleDisabled(event.detail.value);
    }

    handleVINKeyUp(event){
        this.isChanged = true;
        this.vin = event.target.value;
        if(this.vin && this.vin.length === 17){
            this.disabled = true;
            this.toggleDisabled(this.vin);
        }else{
            this.isChanged = false;
            this.disabled = false;
            if(!this.isChanged){
                this.toggleDisabled(null);
            }
        }
    }

    toggleDisabled(value){
        if(value){
            this.saveButtonClass = SAVE_BRAND_BUTTON_ACTIVE;
        }else {
            this.saveButtonClass = SAVE_BRAND_BUTTON_DISABLED;
        }
    }

    initializeUpdateProduct = async () => {
        await updateProduct(this.product);
        fireEvent(this.pageRef, 'productnamechange', this.product);
        //let message = {type: 'productnamechange', product : this.product};
        //this.publishToChannel(message);
    };

    handleSave(){
        if(this.isChanged){
            this.template.querySelector('c-own-base-spinner').invokeSpinner();
            this.product = {...this.context.product};
            if(this.nickname){
                this.product.nickname = this.nickname;
            }
            if(this.vin){
                this.product.vin = this.vin;
            }
            this.initializeUpdateProduct();
        }
    }

    handleExit(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('mode', {
            detail: {
                mode: 'view'
            }
        });
        this.dispatchEvent(selectEvent);
    }

    toggleRemoveSection(){
        this.remove = !this.remove;
    }

    handleGoBack(){
        this.toggleRemoveSection();
    }

    handleRemove(){
        this.toggleRemoveSection();
    }

    initializeRemoveProduct = async () => {
        await removeProduct(this.context.product.productId);
    };

    handleConfirmRemove(){
        this.initializeRemoveProduct();
    }
}
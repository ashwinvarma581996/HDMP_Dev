import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { ISGUEST, getProductContext, getContext, getOrigin } from 'c/ownDataUtils';
import getEmissionWarrantyBooklet from '@salesforce/apex/OwnAPIController.getEmissionWarrantyBooklet';

export default class OwnWarrantyBookletCardHonda extends OwnBaseElement {
    isGuest = ISGUEST;
    @track body = 'The warranty booklet has detailed information about the coverage and terms of your warranties.';
    @track title;
    @api headerLink = '/warranty-info';
    titlecolor = 'Honda Red';
    @api actionIcon = 'download.svg';
    @api icon = 'adobe-pdf.svg';
    url = '';
    get titleClass() {
        return 'slds-text-heading_small title red';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if (this.actionIcon !== '') {
            this.actionIcon = this.myGarageResource() + '/ahmicons/' + this.actionIcon;
        }
        this.initialize();
    }


    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        this.title = this.context.product.year + ' ' + this.context.product.model + ' ' + 'WARRANTY BOOKLET';
        await getEmissionWarrantyBooklet({ modelId: this.context.product.modelId }).then((result) => {
            //console.log('$EW-Result', result);
            if (result.mot && result.mot.db_results && result.mot.db_results.assets && result.mot.db_results.assets.asset && result.mot.db_results.assets.asset[0] && result.mot.db_results.assets.asset[0]['@path']) {
                this.headerLink = 'https://owners.honda.com/' + result.mot.db_results.assets.asset[0]['@path'];
                //console.log('$EW-Asset', result.mot.db_results.assets.asset[0]);
            } else {
                //console.log('$EW-No_Asset');
            }
        }).catch((err) => {
            //console.log('$EW-Error', err);
        });
    }
    handleHeader() {
        this.navigate(this.headerLink, '_blank', {});
    }
    handleAction() {
        this.navigate(this.headerLink, '_blank', {});
    }
}
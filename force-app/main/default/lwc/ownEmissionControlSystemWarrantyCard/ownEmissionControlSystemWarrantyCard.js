import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { ISGUEST, getProductContext } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
import getManualByModel from '@salesforce/apex/OwnAPIController.getManualByModelId';
export default class OwnEmissionControlSystemWarrantyCard extends OwnBaseElement  {

    @api contentId;
    @api brand;
    @api icon = "document.svg";
    @api title;
    @api titlecolor;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    @track productTitle;
    @api BrandName;

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : ' slds-text-heading_small title';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
        this.productTitle = this.alertlabel + " WARRANTY BOOKLET";
    }


    initialize = async () => {

        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value);
        });
        this.context = await getProductContext('');
        //console.log('context=', JSON.stringify(this.context));
        this.alertlabel = this.context.product.year + " " + this.context.product.model;
        this.productTitle = this.alertlabel + " WARRANTY BOOKLET";

        let res = {};
        await getManualByModel({
                modelId: 'CS2188JNW,en,US',
                divisionId: 'A',
            })
            .then((result) => {
                res = result;
                 //console.log('getManualByModel resp!', res)
            })
            .catch((error) => {
                //console.log('getManualByModel error', error)
            })
            .finally(() => {});
    }


    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
    handleHeader() {
        this.navigate('/warranty-info',{});
    }

}
import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { ISGUEST, getProductContext, getContext, getOrigin } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
export default class OwnEmissionWarrantyCardPowerequipment extends OwnBaseElement {

    @api contentid;
    @api brand;
    @api icon;
    @api title;
    @api titlecolor = 'Honda Red';
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    @track title;
    @api headerLink;
    @api actionIcon;
    @api divisionName;

    isGuest = ISGUEST;
    context;

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
        //console.log('Content Id', this.contentid);
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {

            this.context = await getProductContext('', true);

        } else {
            this.context = await getProductContext('', false);
            // this.context = await getContext('');
        }
        this.contentKeys.push(this.contentid);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            if (this.divisionName == 'Powerequipment') {
                this.title = this.context.product.year + ' ' + this.htmlDecode(r.title.value);
            }
            else {
                this.title = this.htmlDecode(r.title.value);
            }
            this.body = this.htmlDecode(r.body.value);
        });

        let vehicleYear = parseInt(this.context.product.year) <= 2012 ? 2012 : this.context.product.year;
        if (this.divisionName == "Marine") {
            this.headerLink = window.location.origin + '/sfsites/c/resource/warranties' + '/marine/emission-control-warranty/emission-control-warranty-' + vehicleYear + '.pdf'
        }
        if (this.divisionName == "Powerequipment") {
            this.headerLink = window.location.origin + '/sfsites/c/resource/warranties' + '/powerequipment/emission-control-warranty/emission-control-warranty-' + vehicleYear + '.pdf'
        }
        // this.context = await getContext('');
        //console.log('headerLink=', this.headerLink);
    }


    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
    handleHeader() {
        this.navigate(this.headerLink, '_blank', {});
    }
    handleAction() {
        this.navigate(this.headerLink, '_blank', {});
    }


}
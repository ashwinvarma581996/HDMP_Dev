import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getProductContext, getOrigin, getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import getProductSupportVideos from '@salesforce/apex/OwnHelpCenterController.getProductSupportVideos';
import getCategoryCode from '@salesforce/apex/OwnEConfigApiHelper.getCategoryCode';

export default class OwnProductSupportVideosCard extends OwnBaseElement {
    @track localIcon = 'utility:question_mark';
    @api contentId;
    @api icon;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api actionbuttonlabel;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track cmsResults;
    @track body;
    @track videos = [];
    @track context;

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }

    initialize = async () => {
        if (getOrigin() == 'ProductChooser') {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        this.contentKeys.push(this.contentId);
        this.cmsResults = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.cmsResults.forEach(r => {
            this.title = !this.title ? this.htmlDecode(r.title.value) : this.title;
            this.body = r.body ? this.htmlDecode(r.body.value).trim() : '';
        });
        this.getVideos();
    };

    getVideos = async () => {
        let productLineCode = '';
        if (!document.location.pathname.includes('help') && this.context && this.context.product && this.context.product.vin && (this.context.product.divisionId == 'P' && (this.context.product.division == 'Powerequipment' || this.context.product.division == 'Power Equipment'))) {
            productLineCode = await getCategoryCode({ vinNumber: this.context.product.vin, poiType: this.context.product.divisionId, divisionName: this.context.product.division });
        }
        //console.log('productLineCode',productLineCode);
        let productSupportVideos = await getProductSupportVideos({ categoryCode: productLineCode});
        //console.log('productSupportVideos :: ', productSupportVideos.length);
        productSupportVideos.forEach(r => {
            this.videos.push({
                id : r.VideoLink__c,
                title : r.Label,
            });
        });
    };

    handleVideoClick(event) {
        let url =  event.currentTarget.dataset.key;
        this.navigate(url, {});
    }

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    handleBrowseClick() {
        this.navigate('https://powerequipment.honda.com/', {});
    }

    handleClickHeader() {
        this.navigate(this.headerlink, {});
    }

}
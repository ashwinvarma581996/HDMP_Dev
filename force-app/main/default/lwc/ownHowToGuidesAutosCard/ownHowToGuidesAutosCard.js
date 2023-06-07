import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getProductContext, getContext, getOrigin } from 'c/ownDataUtils';
import hondaPDF from '@salesforce/label/c.Honda_Owners_PDF';
import acuraPDF from '@salesforce/label/c.Acura_Owners_PDF';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnHowToGuidesAutosCard extends OwnBaseElement {
    @api icon;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api actionbuttonlabel;
    @api brand;
    @track contents = [];
    @track divisionId;
    @track year;
    @track model;
    @track categoryData;
    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        let data = sessionStorage.getItem('CFhowtoguides');
        //console.log('data-.>-', JSON.parse(data));
        data = data ? JSON.parse(data) : '';
        if (data && data[0]) {
            this.categoryData = data[0];
            this.contents = data[0].features
            if (this.contents && this.contents.length > 4) {
                this.contents = this.contents.slice(0, 5)
            }
        }
        //console.log('dataCategory', this.contents);
        this.initialize();
    }

    initialize = async () => {
        //console.log('initialize----->');
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        let context;
        if (fromProductChooser) {
            context = await getProductContext('', true);
        } else {
            context = await getProductContext('', false);
        }
        //console.log('context----->', context);
        if (context && context.product) {
            this.divisionId = context.product.divisionId;
            this.model = context.product.model;
            this.year = context.product.year;
        }
    }

    async handleActionClick() {
        sessionStorage.setItem('howtoguides', JSON.stringify(this.categoryData));
        let label;
        let url;
        if (document.location.pathname.includes('acura-product-connected-features')) {
            label = 'Connected Features';
            url = '/acura-product-connected-features';
        } else if (document.location.pathname.includes('honda-product-connected-features')) {
            label = 'Connected Features';
            url = '/honda-product-connected-features';
        }
        let breadcrumbData = {
            label: label,
            url: url,
            subTitle: this.categoryData.title ? this.categoryData.title + ' How-to Guides' : 'How-to Guides',
        }
        let breadcrumbArr = [];
        if (sessionStorage.getItem('fromhowtoguides')) {
            breadcrumbArr = JSON.parse(sessionStorage.getItem('fromhowtoguides'));
        }
        breadcrumbArr.push(breadcrumbData);
        sessionStorage.setItem('fromhowtoguides', JSON.stringify(breadcrumbArr));
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: this.title + (this.actionbuttonlabel ? ':' + this.actionbuttonlabel : '')
        };
        let message = this.buildAdobeMessage(this.headerlink, eventMetadata)
        this.publishToChannel(message);
        await this.sleep(2000);
        this.navigate(this.headerlink, {});
    }

    handleItemClick(event) {
        let type = event.currentTarget.dataset.type;
        let key = event.currentTarget.dataset.key;
        //console.log('type', type, '---key---', key);
        if (type.toLowerCase() == 'pdf') {
            let url;
            if (this.divisionId == 'A') {
                url = hondaPDF;
            } else if (this.divisionId == 'B') {
                url = acuraPDF;
            }
            url += +this.year + '/' + this.model + '/' + key;
            this.navigate(url, {});
        } else if (type.toLowerCase() == 'youtube') {
            let content = this.contents.filter(element => element.data == key);
            if (content && content[0]) {

                let categoryData = JSON.stringify(content[0]);
                sessionStorage.setItem('howtocategory', categoryData);
                sessionStorage.setItem('frompage', 'connectedfeatures');
            }
            this.navigate('/guide-video-detail', {});
        }
    }

    async handleClickHeader() {
        if (this.titlecolor === 'Honda Red') {
            let eventMetadata = {
                action_type: 'link',
                action_category: 'body',
                action_label: this.title
            };
            let message = this.buildAdobeMessage(this.headerlink, eventMetadata)
            this.publishToChannel(message);
            await this.sleep(2000);
            this.navigate(this.headerlink, {});
        }
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
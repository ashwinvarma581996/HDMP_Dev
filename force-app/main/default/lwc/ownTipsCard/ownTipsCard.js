import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getProductContext, getOrigin, getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import getCategoryCode from '@salesforce/apex/OwnEConfigApiHelper.getCategoryCode';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
export default class OwnTipsCard extends OwnBaseElement {
    @api contentid;
    @api icon;
    @api title;
    @track headerClickable = true;
    @api titlecolor = 'Honda Red';
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    @track title;
    @api headerLink;
    @track showCard = false;
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
        let productLineCode = await getCategoryCode({ vinNumber: this.context.product.vin, poiType: this.context.product.divisionId, divisionName: this.context.product.division });
        let validProductLineCodes = ['CM', 'GG', 'LM', 'RV', 'SB', 'SE', 'TB', 'TL', 'WP'];
        if (validProductLineCodes.includes(productLineCode)) {
            this.showCard = true;
        }
        else {
            this.showCard = false;
        }
        //console.log('Content Id', this.contentid);
        this.contentKeys.push(this.contentid);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('@RESS: ', JSON.parse(JSON.stringify(this.results)));
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value);
        });

    }


    htmlDecode(input) {
        if (!input) return ''
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }

    async handleHeader() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = this.buildAdobeMessage(this.headerLink, eventMetadata);
        this.publishToChannel(message);
        sessionStorage.setItem('frompage', document.location.href.toLowerCase());
        await this.sleep(2000);
        this.navigate(this.headerLink, {});
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
import { track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST, getOrigin, getContext, getProductContext } from 'c/ownDataUtils';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
export default class ownViewMaintenanceMindersCard extends OwnBaseElement {
    @api maintenanceMindersHondaKey;
    @api maintenanceMindersAcuraKey;
    @track contentKeys = [];
    @track results;
    @track context;
    @track title;
    @track body;
    @track icon;
    @track isAcura;
    @api titlecolor = 'Honda Red';
    @track vinNumber;
    @track isGuest = ISGUEST;

    connectedCallback() {
        this.contentKeys.push(this.maintenanceMindersHondaKey);
        //console.log(this.maintenanceMindersHondaKey);
        //console.log(this.maintenanceMindersAcuraKey);
        this.icon = this.myGarageResource() + '/ahmicons/wrench-hand.svg';
        this.initialize();
    }
    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext('');
        }
        if (this.context && this.context.product) {
            if (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-')) {
                this.vinNumber = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
            }
        }
        //console.log('ownViewMaintenanceMindersCard: context-', JSON.parse(JSON.stringify(this.context)));
        //console.log('ownViewMaintenanceMindersCard: vinNumber-', this.vinNumber);
        //console.log('ownViewMaintenanceMindersCard: isGuest-', this.isGuest);

        if (this.context && this.context.product) {
            this.contentKeys = [];
            if (this.context.product.division == 'Acura') {
                //console.log('ownViewMaintenanceMindersCard: acura');
                this.contentKeys.push(this.maintenanceMindersAcuraKey);
                this.isAcura = true;
            } else {
                //console.log('ownViewMaintenanceMindersCard: honda');
                this.contentKeys.push(this.maintenanceMindersHondaKey);
                this.isAcura = false;
            }
        }
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('ownViewMaintenanceMindersCard: results-', JSON.parse(JSON.stringify(this.results)));
        this.results.forEach(r => {
            //console.log('ownViewMaintenanceMindersCard: r-', r);
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
            //console.log('ownViewMaintenanceMindersCard: title-', this.title);
            //console.log('ownViewMaintenanceMindersCard: body-', this.body);
        });
    };
    async handleHeader() {
        //console.log('ownViewMaintenanceMindersCard: handleHeader');
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        let brandName = this.isAcura ? 'Acura' : 'Honda';
        let label = window.location.href.includes('service') ? brandName + ': Service & Maintenance' : brandName + ': Overview';
        let backLink = {
            label: label,
            url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
        };
        sessionStorage.setItem('backlink', JSON.stringify(backLink));
        await this.sleep(2000);
        if (this.isAcura) {
            this.navigate('/acura-accelerated-service', {});
        } else {
            this.navigate('/honda-maintenance-minder', {});
        }
    }
    handleAction() {
        //console.log('ownViewMaintenanceMindersCard: handleAction');
    }
    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
import { wire, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getPESerialNumberLocatorUrl from '@salesforce/apex/OwnWarrantyController.getPESerialNumberLocatorUrl';

export default class ownPESerialNumberLocator extends OwnBaseElement {
    @track peSNUrl;
    @track breadcrumbLabel;
    @track breadcrumbUrl;
    @wire(getPESerialNumberLocatorUrl)
    wiredData({ error, data }) {
        if (data) {
            this.peSNUrl = data;
        } else if (error) {
           // console.error('Error:', error);
        }
    }
    handleBreadcrumbClick() {
        this.navigate(this.breadcrumbUrl, {});
    }

    connectedCallback() {
        let backlink = sessionStorage.getItem('backlink');
        if (backlink) {
            backlink = JSON.parse(backlink);
           // console.log('backlink', backlink);
            this.breadcrumbLabel = backlink.label;
            this.breadcrumbUrl = backlink.url;
        }
        sessionStorage.removeItem('backlink');
    }
}
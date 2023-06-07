import { api, LightningElement, track } from 'lwc';

export default class OwnBaseSpinner extends LightningElement {
    @track alternativeText
    @track size;
    @track variant;
    @track showSpinner = false;

    @api async invokeSpinner(alternativeText = 'Loading', size = 'medium', variant = 'brand') {
        this.showSpinner = true;
        this.alternativeText = alternativeText;
        this.size = size;
        this.variant = variant;

        await this.sleep(2000);

        this.showSpinner = false;
    }
    
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
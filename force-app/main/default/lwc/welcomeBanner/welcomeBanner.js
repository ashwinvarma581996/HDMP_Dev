import { LightningElement, track } from 'lwc';
import imageResourcePath from '@salesforce/resourceUrl/honda_images';

export default class WelcomeBanner extends LightningElement {
    hondaLogo = imageResourcePath + '/honda-logo.png';

    @track selectedBrand = '';

    connectedCallback(){
        let currentURL = window.location.href;
        if(currentURL && currentURL.toLowerCase().includes('/honda'))
            this.selectedBrand = 'Honda';
        else if(currentURL && currentURL.toLowerCase().includes('/acura'))
            this.selectedBrand = 'Acura';
        else
        this.selectedBrand = '';
    }
}
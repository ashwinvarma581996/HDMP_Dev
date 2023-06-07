import { LightningElement,api } from 'lwc';
import imageResourcePath from '@salesforce/resourceUrl/Menu_logo';

export default class TempMainHeadercmp extends LightningElement {
    @api brandName;
    honda = imageResourcePath + '/Hondalogo.png';
    acura = imageResourcePath + '/Acuralogo.png';

}
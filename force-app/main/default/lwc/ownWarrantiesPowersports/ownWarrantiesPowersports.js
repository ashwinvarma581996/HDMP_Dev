import { LightningElement,api,track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import img from '@salesforce/resourceUrl/Owners';

export default class OwnWarrantiesPowersports extends LightningElement {
    @api title = 'DOWNLOAD THE 2021 MOTORCYCLE WARRANTY BOOKLET';
    @api icon = 'document.svg';
    @api titlecolor='Honda Red';
    @api brand='default';
    @api body='PDF Description';
    @track showFooter = false;
    @track showForwardIcon = true;

    saveicon = img + '/Icons/save-icon.svg';
    fileicon = img + '/Icons/file-icon.svg';
    downloadicon = img + '/Icons/download.svg';
    headerImage = img + '/images/garage_hondadefault.svg';
}
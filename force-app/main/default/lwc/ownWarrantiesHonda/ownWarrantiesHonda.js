import { LightningElement,api,track } from 'lwc';
import img from '@salesforce/resourceUrl/Owners';
const cards=[{'title' : 'BRIDGESTONE/FIRESTONE'},
            {'title' : 'CONTINENTAL'},
            {'title' : 'GOODYEAR/DUNLOP'},
            {'title' : 'HANKOOK'},
            {'title' : 'JK'},
            {'title' : 'KENDA'},
            {'title' : 'MAXXIS'},
            {'title' : 'MICHELIN'},
        ]
export default class OwnWarrantiesHonda extends LightningElement {

    @api title1 = 'DOWNLOAD THE 2019 HR-V WARRANTY BOOKLET';
    @api title2 = 'CALIFORNIA WARRANTY INFORMATION';
    @api icon = 'utility:connected_apps';
    @api titlecolor='Honda Red';
    @api brand='default';
    @api body='PDF Description';
    @track showFooter = false;
    @track showForwardIcon = false;
    @track cards=cards;

    saveicon = img + '/Icons/save-icon.svg';
    headerImage = img + '/images/garage_hondadefault.svg';


   

}
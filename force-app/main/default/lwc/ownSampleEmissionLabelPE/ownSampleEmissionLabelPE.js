import {api, track} from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import warranties from '@salesforce/resourceUrl/warranties';
export default class OwnSampleEmissionLabelPE extends OwnBaseElement {
    @track breadcrumbLabel = 'Warranties';
    @track breadcrumbUrl = '/warranty-info';
    imageUrl = warranties + '/powerequipment/sample-emission-label-powerequipment.jpg';

    handleBreadcrumbClick(){
        this.navigate(this.breadcrumbUrl ,{});
    }

    connectedCallback(){
        let breadcrumb = sessionStorage.getItem('vinHelpBreadcrumb');
        if (breadcrumb == 'findProduct'){
            this.breadcrumbLabel = 'Power Equipment: Get Started';
            this.breadcrumbUrl = '/find-powerequipment';
        }
        else if (breadcrumb == 'productSettings'){
            this.breadcrumbLabel = 'Edit Settings';
            this.breadcrumbUrl = '/product-settings';
        }
    }
}
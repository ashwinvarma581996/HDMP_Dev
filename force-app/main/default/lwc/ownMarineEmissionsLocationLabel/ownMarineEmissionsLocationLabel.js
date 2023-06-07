import {api, track} from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import warranties from '@salesforce/resourceUrl/warranties';
export default class OwnMarineEmissionsLocationLabel extends OwnBaseElement {
    @track breadcrumbLabel = 'Warranties';
    @track breadcrumbUrl = '/warranty-info';
    imageUrl =  warranties + '/marine/marine-emissions-location.png';
    handleBreadcrumbClick(){
        this.navigate(this.breadcrumbUrl ,{});
    }

    connectedCallback(){
        let breadcrumb = sessionStorage.getItem('vinHelpBreadcrumb');
        if (breadcrumb == 'findProduct'){
            this.breadcrumbLabel = 'Marine: Get Started';
            this.breadcrumbUrl = '/find-marine';
        }
        else if (breadcrumb == 'productSettings'){
            this.breadcrumbLabel = 'Edit Settings';
            this.breadcrumbUrl = '/product-settings';
        }
        else if (breadcrumb == 'productRegistration'){
            this.breadcrumbLabel = 'Product Registration';
            this.breadcrumbUrl = '/product-registration';
        }
    }
}
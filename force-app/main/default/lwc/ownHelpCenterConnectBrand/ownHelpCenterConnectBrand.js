//============================================================================
// Title:    Honda Owners Experience - Help Center
//
// Summary:  Connect brand logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the connect brand component for all help center pages.
//
//
// History:
// May 17, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";;

const BRAND_MAP = new Map();
BRAND_MAP.set('AcuraAutos', {'img': commonResources + '/Logos/honda_acura.svg', 'url': '/help-acura'}); // Changed links from '/help-center-(brand)' to '/help-(brand)' to match overflow diagrams
BRAND_MAP.set('HondaAutos', {'img': commonResources + '/Logos/honda_autos.svg', 'url': '/help-honda'});
BRAND_MAP.set('HondaPowersports', {'img': commonResources + '/Logos/honda_powersports.svg', 'url': '/help-powersports'});
BRAND_MAP.set('HondaPowerEquipment', {'img': commonResources + '/Logos/honda_equipment.svg', 'url': '/help-powerequipment'});
BRAND_MAP.set('HondaMarine', {'img': commonResources + '/Logos/honda_marine.svg', 'url': '/help-marine'});

export default class OwnHelpCenterConnectBrand extends OwnBaseElement {
    @api categories;

    get brands(){
        if(this.categories){
            const brands = [];
            this.categories.forEach(c => {
                brands.push({
                    value: c.name,
                    label: c.label,
                    img: BRAND_MAP.get(c.name).img
                });
            });
            return brands;
        }
    }

    handleClick(event){
        let name = event.currentTarget.dataset.name;
        this.navigate(BRAND_MAP.get(name).url, {});
    }
}
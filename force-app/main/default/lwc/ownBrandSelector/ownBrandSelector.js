//============================================================================
// Title:    Honda Owners Experience - Brand Selection Links
//
// Summary:  This is the brand card html seen at the home page of the Honda Owner Community
//
// Details:  Displays a list of brand 'boxes' on desktop, or brand links on mobile for navigation to Garage pages
//
// History:
// July 07, 2021 Arunprasad N (Wipro) Original Author
// July 07, 2021 Jim Kohs (Wipro) swapped logos for honda_powersports
//===========================================================================
import { LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import commonResources from "@salesforce/resourceUrl/Owners";
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

const brands = [{ 'name': 'AcuraAutos', 'label': 'Acura Autos', 'img': commonResources + '/Logos/honda_acura.svg', 'url': 'find-acura' },
{ 'name': 'HondaAutos', 'label': 'Honda Autos', 'img': commonResources + '/Logos/honda_autos.svg', 'url': 'find-honda' },
/*DOE-4256 Start (Code commented for Release 1 - Details: Hiding PowerSports,Marine,Power Equipments )*/
{ 'name': 'HondaPowersports', 'label': 'Honda Powersports', 'img': commonResources + '/Logos/honda_powersports.svg', 'url': 'find-powersports' },
{ 'name': 'HondaPowerEquipment', 'label': 'Honda Power Equipment', 'img': commonResources + '/Logos/honda_equipment.svg', 'url': 'find-powerequipment' },
{ 'name': 'HondaMarine', 'label': 'Honda Marine', 'img': commonResources + '/Logos/honda_marine.svg', 'url': 'find-marine' }
    /*DOE-4256 End (Code commented for Release 1 - Details: Hiding PowerSports,Marine,Power Equipments )*/
]

export default class OwnBrandSelector extends OwnBaseElement {
    @track brands = brands;
    handleClick(event) {
        const url = event.currentTarget.dataset.url;
        // let eventMetadata = {
        //     action_type: 'button',
        //     action_category: 'body',
        //     action_label: event.currentTarget.dataset.label
        // };
        // let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        // this.publishToChannel(message);
        // await this.sleep(2000);
        this.navigate('/' + url, {});
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

}
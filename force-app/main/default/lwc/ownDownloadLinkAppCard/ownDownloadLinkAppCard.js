//============================================================================
// Title:    Honda Owners Experience - Download HondaLink Card
//
// Summary:  This Card links to the  Download HondaLink
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnDownloadLinkAppCard extends OwnBaseElement {


    @api title = 'DOWNLOAD HONDALINK APP';
    @api titlecolor = 'Honda Red';
    @api brand = 'acura';
    @api icon = 'utility:connected_apps';
    @track showFooter = false;
    @track headerClickable = true;

    handleHeader(){
        let navigationPath = this.brand == 'acura' ? '/acuralink-marketing' : '/hondalink-marketing';
        this.navigate(navigationPath, {});
    }

    handleAction(){
        console.log('action');
    }

    handleFooter(){
        console.log('footer');
    }
}
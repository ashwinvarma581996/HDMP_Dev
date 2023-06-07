//============================================================================
// Title:    Honda Owners Experience - Card
//
// Summary:  This is the base card html seen at the home page of the Honda Owner Community
//
// Details:  Displays a list of brand 'boxes' on desktop, or brand links on mobile for navigation to Garage pages
//
// History:
// July 23, 2021 Arunprasad N (Wipro) Original Author
// aug 11, 2021 Jim Kohs (Wipro) added .toLowerCase() comparison for property getters
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';


export default class OwnCard extends OwnBaseElement {
    @api title;
    @api titlecolor;
    @api icon;
    @api brand;
    @api showforwardicon;
    @api showfooter;
    @api headerClickable = false;
    @api iconImage;
    @api hideBodySection;
    get isDefault() { return this.brand === 'default'; }; 
    get isAcura() { return this.brand.toLowerCase() === 'acura' || this.brand.toLowerCase() === 'acura auto'; }; 
    get isHonda() { return this.brand.toLowerCase() === 'honda' || this.brand.toLowerCase() === 'honda auto'; }; 
    get isPowersports() { return this.brand.toLowerCase() === 'powersports'; }; 
    get isPowerequipment() { return this.brand.toLowerCase() === 'powerequipment'; }; 
    get isMarine() { return this.brand.toLowerCase() === 'marine'; };
    get isTitleRed() { return this.titlecolor === 'Honda Red'; }; 

    get bodyClass(){
        let cardBodyClass = this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
        cardBodyClass = this.hideBodySection ? '' : cardBodyClass;
        return cardBodyClass;
    }

    handleClickHeader(){
        this.dispatchEvent(new CustomEvent('header'));
    }

    handleClickAction(){
        this.dispatchEvent(new CustomEvent('action'));   
    }

    handleClickFooter(){
        this.dispatchEvent(new CustomEvent('footer'));   
    }
}
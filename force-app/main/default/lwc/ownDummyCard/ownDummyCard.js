//============================================================================
// Title:    Honda MyGarage Experience - CMS Card
//
// Summary:  This is a dummy card, to be used as a placeholder for cards that
//           have not been created yet.
//
// Details:  Use in layouts in place of cards that have not yet been created.
//           Title, description, and story # can be set as exposed properties
//           in Experience Builder
//
// History:
// Jan 11, 2022: Alexander Dzhitenov (Wipro) initial coding
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
export default class OwnDummyCard extends OwnBaseElement {
    @wire(CurrentPageReference)
    pageRef;
    @api BrandName;
    @api contentId;
    @api brand;
    @api icon;
    @api title;
    @api titlecolor = 'Honda Red';
    @api description;
    @api storyNumber;
    @api headerlink;
    @api showforwardicon;
    @track cardDivClass = '';

    
    get bodyClass(){
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
    }

    get titleClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    get body(){
        return this.description + (this.storyNumber ? ' ' + '(' + this.storyNumber + ')' : '');
    }

    connectedCallback(){
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if(document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage' ||  document.title == 'Garage' ||  document.title == 'Garage'){
            this.cardDivClass = 'overview-tab-class';
           // console.log('Document title ::: ', document.title);
        }
     }
}
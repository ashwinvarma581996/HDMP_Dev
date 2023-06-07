//============================================================================
// Title:    Honda Owners Experience - Help Center
//
// Summary:  category result logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the category result component for all help center pages.
//
//
// History:
// June 16, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';

export default class OwnHelpCenterCategoryResults extends OwnBaseElement {
    @api brand;
    @api subcategory;
    @track rightArrow = this.ownerResource() + '/Icons/right_arrow.svg';

    get isMixedCategory(){
        return this.subcategory.label === 'Popular Articles & FAQs' ? true : false;
    }

/*     connectedCallback(){
        console.log(JSON.stringify(this.subcategory.results));
    } */

    handleClick(event){
        let id = event.currentTarget.dataset.id;
        let urlName = event.currentTarget.dataset.urlname;
        this.navigate('/article/' + urlName + '?' + 'brand=' + this.brand.brandName, {});
    }
}
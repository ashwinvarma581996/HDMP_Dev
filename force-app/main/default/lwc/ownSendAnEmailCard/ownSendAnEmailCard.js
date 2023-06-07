//============================================================================
// Title:    Honda MyGarage Experience - CMS Card
//
// Summary:  This is the CMS Card html seen at the page of the Honda MyGarage Community
//
// Details:  CMS Card for pages
//
// History:
// October 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';

export default class OwnSendAnEmailCard extends OwnBaseElement {
    @api contentId;
    @api brand;
    @api icon;
    @api iconright;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api showforwardicon;
    @api forwardiconright;
    @api showfooter;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    
    get bodyClass(){
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
    }

    get titleClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass(){
        let colorClass = this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
        if(this.forwardiconright) {
            colorClass += ' forward-icon-right';
        }
        return colorClass;
    }
    connectedCallback(){
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }

    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = this.title ? this.title : this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value);
        })
    };

    handleSubmitRequest(){
        sessionStorage.setItem('BrandName', this.brand);
        this.navigate('/send-an-email', {});
    }

    handleClickHeader(){
        this.navigate(this.headerlink, {}); 
    }

    handleClickAction(){
        
    }

    handleClickFooter(){
           
    }
    htmlDecode(input) {
        if(!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
}
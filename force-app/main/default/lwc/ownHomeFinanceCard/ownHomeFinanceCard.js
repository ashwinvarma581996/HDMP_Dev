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
import getKavBasedOnUrlName from '@salesforce/apex/OwnHelpCenterController.getKavBasedOnUrlName';


export default class OwnHomeFinanceCard extends OwnBaseElement {
    @api contentId;
    @api brand;
    @api icon;
    @api iconright;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api showforwardicon;
    @api headerRightIcon= 'utility:forward';
    @api forwardiconright;
    @api showfooter;
    @api actionButton;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    @track phoneFields = [];
    
    
    @track phoneNumberReadOnly = false;
    @track phone2NumberReadOnly = false;
    @track phone3NumberReadOnly = false;
    @track phone4NumberReadOnly = false;
    @track mainCardClass = 'card card-size card-styles-wrapper diff-cms-card';
    @track customBodyHeight = '';
    
    get bodyClass(){
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body' + this.customBodyHeight;
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
        // this.icon = this.myGarageResource() + '/ahmicons/' + phone.svg;
        if(document.title == 'HondaLink Features' || document.title == 'Acuralink Connected Features'){
            this.mainCardClass = 'card card-size card-styles-wrapper diff-cms-card connected-features-tab-div';
        }
        this.initialize();
    }

    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            //this.title = this.htmlDecode(r.title.value);
            if(this.title == 'AcuraLink Legal Terms' || this.title == 'HondaLink Legal Terms'){
                this.customBodyHeight = ' custom-body-height ';
            }
            this.body = this.htmlDecode(r.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
            
            

            
        });
    };

    async handleClickHeader(){
        if(this.headerlink.startsWith('KA:#')){
            var headerArray=this.headerlink.split(":#");
            if(headerArray.length > 2){
                this.headerlink = '/article/' + headerArray[1] + '?' + 'brand=' + headerArray[2];
            }else{
                this.headerlink = '/article/' + headerArray[1];   
            }
            // await getKavBasedOnUrlName({UrlNameVar : headerArray[1]}).then( (result) => {
            //     if(headerArray.length > 2){
            //     this.headerlink='/article?id='+result+'&brand='+headerArray[2];
            //     }else{
            //         this.headerlink='/article?id='+result;   
            //     }
            // }).catch((error) => {
            //     console.log('error log');
            //     console.log(error);
            // });
        }
        this.navigate(this.headerlink, {}); 
    }

    handleClickAction(){
        this.navigate(this.headerlink, {});
    }

    handleClickFooter(){
           
    }
    htmlDecode(input) {
        if(!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
}
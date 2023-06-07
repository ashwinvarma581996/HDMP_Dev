//============================================================================
// Title:    Honda MyGarage Experience - Call Us Card
//
// Summary:  This is the Call Us Card html seen at the page of the Honda MyGarage Community
//
// Details:  Call Us Card for pages
//
// History:
// December 22, 2021 Ravindra Ravindra (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';

export default class OwnCallUsCard extends OwnBaseElement {
    @api contentId;
    @api brand;
    @api icon;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api showforwardicon;
    @api showfooter;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    @track phoneFields = [];
    @track showPhoneLabel = false;
    @track showPhoneNumber = false;
    @track showPhone2Label = false;
    @track showPhone2Number = false;
    @track showPhone3Label = false;
    @track showPhone3Number = false;
    @track showPhone4Label = false;
    @track showPhone4Number = false;
    @track phoneLabel;
    @track phoneNumber;
    @track phone2Label;
    @track phone2Number;
    @track phone3Label;
    @track phone3Number;
    @track phone4Label;
    @track phone4Number;
    @track phoneNumberReadOnly = false;
    @track phone2NumberReadOnly = false;
    @track phone3NumberReadOnly = false;
    @track phone4NumberReadOnly = false;
    @track cardDivClass = '';
    
    get bodyClass(){
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
    }

    get titleClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : this.titlecolor === 'Black' ? 'slds-text-heading_small title black' : 'slds-text-heading_small title';
    }

    get headerClass(){
        return this.titlecolor === 'Honda Red' ? 'card-styles card-styles-red' : this.titlecolor === 'Black' ? 'card-styles card-styles-black' : 'card-styles';
    }

    get iconClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }
    connectedCallback(){
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if(document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage' ||  document.title == 'Garage' ||  document.title == 'Garage'){
            this.cardDivClass = 'overview-tab-class';
         //   console.log('Document title ::: ', document.title);
        }
        this.initialize();
    }

    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value);
            if(r.phoneLabel){
                this.phoneLabel = this.htmlDecode(r.phoneLabel.value);
                this.showPhoneLabel = true;
            }
            if(r.phoneNumber){
                this.phoneNumber = r.phoneNumber.value;
                this.showPhoneNumber = true;
            }

            if(this.showPhoneLabel || this.showPhoneNumber) {
                this.phoneFields.push({
                    label: this.phoneLabel,
                    value: this.phoneNumber,
                    readonly: this.phoneLabel ? this.phoneLabel.toLowerCase().includes('fax') ? true : false : false,
                    showLabel: this.showPhoneLabel,
                    showValue: this.showPhoneNumber
                });
            }

            if(r.phone2Label){
                this.phone2Label = this.htmlDecode(r.phone2Label.value);
                this.showPhone2Label = true;
            }
            if(r.phone2Number){
                this.phone2Number = r.phone2Number.value;
                this.showPhone2Number = true;
            }

            if(this.showPhone2Label || this.showPhone2Number) {
                this.phoneFields.push({
                    label: this.phone2Label,
                    value: this.phone2Number,
                    readonly: this.phone2Label ? this.phone2Label.toLowerCase().includes('fax') ? true : false : false,
                    showLabel: this.showPhone2Label,
                    showValue: this.showPhone2Number
                });
            }

            if(r.phone3Label){
                this.phone3Label= this.htmlDecode( r.phone3Label.value);
                this.showPhone3Label = true;
            }
            if(r.phone3Number){
                this.phone3Number = r.phone3Number.value;
                this.showPhone3Number = true;
            }

            if(this.showPhone3Label || this.showPhone3Number) {
                this.phoneFields.push({
                    label: this.phone3Label,
                    value: this.phone3Number,
                    readonly: this.phone3Label ? this.phone3Label.toLowerCase().includes('fax') ? true : false : false,
                    showLabel: this.showPhone3Label,
                    showValue: this.showPhone3Number
                });
            }

            if(r.phone4Label){
                this.phone4Label= this.htmlDecode(r.phone4Label.value);
                this.showPhone4Label = true;
            }
            if(r.phone4Number){
                this.phone4Number = r.phone4Number.value;
                this.showPhone4Number = true;
            }

            if(this.showPhone4Label || this.showPhone4Number) {
                this.phoneFields.push({
                    label: this.phone4Label,
                    value: this.phone4Number,
                    readonly: this.phone4Label ? this.phone4Label.toLowerCase().includes('fax') ? true : false : false,
                    showLabel: this.showPhone4Label,
                    showValue: this.showPhone4Number
                });
            }
        });
    };

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
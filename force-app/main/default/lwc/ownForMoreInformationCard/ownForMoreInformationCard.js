// Title:    Honda MyGarage Experience - Promotional Hero
//
// Summary:  This is the For More Infromation Card html seen at the page of the Honda MyGarage Community 
//
// Details:  For More Infromation Card for pages
//
// History:
// December 18, 2021 Ravindar Ravindra (Wipro) Original Author 
//=========================================================================== 
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';

export default class OwnForMoreInformationCard extends OwnBaseElement {
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
    @track phoneNumberReadOnly = false;
    @track phone2NumberReadOnly = false;
    @track phoneLabel;
    @track phoneNumber;
    @track phoneLink;
    @track phone2Label;
    @track phone2Number;
    @track phone2Link;
    
    get bodyClass(){
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
    }

    get titleClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass(){
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }
    connectedCallback(){
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }

    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        //console.log('$RECALLS: results: ',JSON.parse(JSON.stringify(this.results)));
        this.results.forEach(r => {
            this.title = this.title ? this.title : this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value);
            this.phoneLabel = r.phoneLabel ? this.htmlDecode(r.phoneLabel.value) : false;
            this.phoneNumber = r.phoneNumber ? r.phoneNumber.value : false;
            this.phoneLink = r.phone3Number ? r.phone3Number.value: false;
            this.phoneURL = r.downloadLink ? r.downloadLink.value : false;

            this.phone2Label = r.phone2Label ? this.htmlDecode(r.phone2Label.value) : false;
            this.phone2Number = r.phone4Number ? r.phone4Number.value : false;
            this.phone2NumberAvailable = r.phone2Number ? r.phone2Number.value : false;
            this.phone2Link = r.phone3Label ? r.phone3Label.value : false;
            this.phone2URL = r.videoLink ? r.videoLink.value : false;

            this.phone3Label = r.phone4Label ? this.htmlDecode(r.phone4Label.value) : false;
            this.phone3NumberHeading = r.phone4Label ? r.phone4Label.value : false;
            this.phone3Number = r.downloadLabel ? r.downloadLabel.value : false;
            this.phone3Link = r.videoLink ? r.videoLink.value : false;
                
            
            if(this.phoneLabel || this.phoneNumber || this.phoneLink) {
                this.phoneFields.push({
                    label: this.phoneLabel,
                    value: this.phoneNumber,
                    link: this.phoneLink,
                    available: '',
                    url: this.phoneURL,
                    readonly: this.phoneLabel ? this.phoneLabel.toLowerCase().includes('fax') ? true : false : false,
                    //Imtiyaz - RECALLS Start
                    nextLine: true,
                    //Imtiyaz - RECALLS End
                });
            }


            if(this.phone2Label || this.phone2Number || this.phone2Link) {
                this.phoneFields.push({
                    label: this.phone2Label,
                    value: this.phone2Number,
                    link: this.phone2Link,
                    available: this.phone2NumberAvailable,
                    url: this.phone2URL,
                    readonly: this.phone2Label ? this.phone2Label.toLowerCase().includes('fax') ? true : false : false,
                    //Imtiyaz - RECALLS Start
                    nextLine: false,
                    //Imtiyaz - RECALLS End
                });
            }

            if(this.phone3Label || this.phone3Number || this.phone3Link) {
                this.phoneFields.push({
                    label: this.phone3Label,
                    value: this.phone3Number,
                    link: '',
                    available: '',
                    url: '',
                    readonly: this.phone3Label ? this.phone3Label.toLowerCase().includes('fax') ? true : false : false,
                    //Imtiyaz - RECALLS Start
                    nextLine: false,
                    //Imtiyaz - RECALLS End
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

    handleFindADealer(){
        sessionStorage.setItem('findDealerContext',JSON.stringify({brand: 'Powersports', divisionId: 'M'}));
        this.navigate('/find-a-dealer', {});
    }
}
//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Owners Garage Find - Honda Auto Body Honda Link logic of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the own garage find honda body honda link component for all community pages.
//
//
// History:
// June 28, 2021 Arunprasad N (Wipro) Original Author
// July 03, 2021 Harshavardhan (Wipro)
// July 15, 2021 Jim Kohs (Wipro) refactored to ownBaseCard2
//===========================================================================
import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST, getManagedContentByTopicsAndContentKeys, getProductContext } from 'c/ownDataUtils';
import getFinanceLink from '@salesforce/apex/OwnRetriveCustomMetaData.getFinanceLink';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';


export default class OwnFinanceCard extends OwnBaseElement {
    @api title = '';
    @api showforwardicon = false;
    @api titlecolor = '';
    @api brand = '';
    @api actiontitle = '';
    @track showFooter = false;
    @api contentId;
    @api icon;
    @api headerlink;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track cardDivClass = '';
    @track body;

    async handleClickHeader() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = this.buildAdobeMessage(this.headerlink, eventMetadata)
        this.publishToChannel(message);
        if (!(document.location.pathname.includes('help-') && (this.brand == "Marine" || this.brand == "Powerequipment"))) {
            await this.sleep(2000);
            this.navigate(this.headerlink, '_blank', {});
        }
    }
    handleClickFooter() {
        this.navigate(this.headerlink, '_blank', {});
    }
    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass() {
        let colorClass = this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon ' : 'slds-p-left_small ';
        if (this.showforwardicon) {
            colorClass += 'forward-icon-right';
        }
        return colorClass;
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        //this.initialize();
        if (document.location.pathname.includes('garage-powerequipment') || document.location.pathname.includes('garage-marine')) {
            this.cardDivClass = 'overview-tab-class';
        }
        if (document.location.pathname.includes('help-')) {
            if (this.brand != 'Powerequipment') {
                this.showFooter = true;
            }
        }
        this.initialize();
    }

    initialize = async () => {
        try {
            var context;
            let origin = localStorage.getItem('origin');
            if (ISGUEST || origin == 'ProductChooser') {
                context = await getProductContext('', true);
            } else {
                context = await getProductContext('', false);
            }
            this.contentKeys.push(this.contentId);
            this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
            this.results.forEach(r => {
                this.body = this.htmlDecode(r.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
            });
            if (document.location.pathname.includes('garage-')) {
                this.brand = context.product.division;
            }
            await getFinanceLink({ brand: this.brand }).then((data) => {
                //console.log('@@Test' + data);
                if (ISGUEST) {
                    this.headerlink = data.Guest_Link__c;
                } else {
                    this.headerlink = data.Login_Link__c;
                }
            }).catch((error) => {
                //console.log('@@Error getting Data', error);
            });
        } catch (e) {
            //console.log(e);
        }
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
}
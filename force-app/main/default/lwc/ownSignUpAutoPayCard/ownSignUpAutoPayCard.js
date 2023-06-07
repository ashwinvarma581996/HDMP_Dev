import { LightningElement, track, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST, getManagedContentByTopicsAndContentKeys, getProductContext } from 'c/ownDataUtils';
import financeUrl from '@salesforce/label/c.Finance_Link';
import financeurllogout from '@salesforce/label/c.Finance_LogOutUrl';
import basePath from '@salesforce/community/basePath';
import getFinanceLink from '@salesforce/apex/OwnRetriveCustomMetaData.getFinanceLink';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnSignUpAutoPayCard extends OwnBaseElement {
    @api title = "Sign up for Auto Pay";
    @api titlecolor = 'Honda Red';
    @api brand = 'honda';
    @api actiontitle = '';
    @api actionicon;
    @api isprotectionplanpage = false;
    @track showFooter = false;
    @track results;
    @api contentId;
    @api icon;
    @api headerlink;
    @api downloadlink;
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
        let message = this.buildAdobeMessage(this.headerlink, eventMetadata);
        this.publishToChannel(message);
        await this.sleep(2000);
        this.navigate(this.headerlink, '_blank', {});

    }
    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon ' : 'slds-p-left_small ';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        //this.initialize();
        if (document.location.pathname.includes('garage-honda') || document.location.pathname.includes('garage-acura') || document.location.pathname.includes('garage-powerequipment') || document.location.pathname.includes('garage-powersports') || document.location.pathname.includes('garage-marine')) {
            this.cardDivClass = 'overview-tab-class';
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
                this.body = this.htmlDecode(r.body.value);
            });

            await getFinanceLink({ brand: context.product.division }).then((data) => {
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

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
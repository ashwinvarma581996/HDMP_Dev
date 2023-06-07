//============================================================================
// Title:    Honda MyGarage Experience - CMS Card
//
// Summary:  This is the CMS Card html seen at the page of the Honda MyGarage Community
//
// Details:  CMS  Software Card for pages
//
// History:
//Created by ritika bhagchandani --- Tracker 3
//===========================================================================
import { api, LightningElement, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST, getProductContext } from 'c/ownDataUtils';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import getCompleteDetails from '@salesforce/apex/OwnAPIController.getCompleteDetails';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';


export default class ownVehicleSoftwareUpdateCard extends OwnBaseElement {
    @api contentId;
    @api brand;
    @api icon;
    @api iconright;
    @api title;
    @api titlecolor;
    @api headerlink;
    @api showforwardicon;
    @api headerRightIcon = 'utility:forward';
    @api forwardiconright;
    @api showfooter;
    @api actionButton;
    @track isDataLoading;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track results;
    @track body;
    @track mainCardClass = 'card card-size card-styles-wrapper diff-cms-card';
    @track customBodyHeight = '';
    @track isYearValid = false;
    @track allCategoriesData = [];
    get bodyClass() {
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body' + this.customBodyHeight;
    }

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small title red' : 'slds-text-heading_small title';
    }

    get iconClass() {
        let colorClass = this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
        if (this.forwardiconright) {
            colorClass += ' forward-icon-right';
        }
        return colorClass;
    }
    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if (document.title == 'HondaLink Features' || document.title == 'Acuralink Connected Features') {
            this.mainCardClass = 'card card-size card-styles-wrapper diff-cms-card connected-features-tab-div';
        }
        this.initializecontext();
        this.initialize();

    }
    initializecontext = async () => {
        //console.log('this.fb: ', this.fb);
        let origin = localStorage.getItem('origin');
        if (this.fb == 'true' || origin == 'ProductChooser') {
            this.context = await getProductContext('', true);
            //console.log('context from browser - ', JSON.parse(JSON.stringify(this.context)));
        } else {
            this.context = await getProductContext('', false);
            //console.log('context from server - ', JSON.parse(JSON.stringify(this.context)));
        }
        if (this.context.product) {
            if (this.context.product.divisionId == 'A') {
                this.brandName = 'HondaLink';
            } else if (this.context.product.divisionId == 'B') {
                this.brandName = 'AcuraLink';
            }
            // this.year = this.context.product.year;
            // if (this.year !== null && this.year > 2018) {
            //     console.log('year' + this.year);
            //     this.isYearValid = true;
            // }
        }
    };
    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            this.body = this.htmlDecode(r.body.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>');
        });
        var context;
        let origin = localStorage.getItem('origin');
        if (ISGUEST || origin == 'ProductChooser') {
            context = await getProductContext('', true);
        } else {
            context = await getProductContext('', false);
        }
        if (context && context.product) {
            this.divisionId = context.product.divisionId;
            await getCompleteDetails({ divisionId: context.product.divisionId, modelYear: context.product.year, model: context.product.model })
                .then((data) => {
                    if (data && data.error) {
                        this.isError = true;
                    } else {
                        data.feature.forEach(element => {
                            element.view = element.view.filter(ele => ele.data);
                            element.view.forEach(viewEle => {
                                viewEle.category = element.title;
                                if (!viewEle.title) {
                                    viewEle.title = element.title;
                                }
                            });
                            if (element.id.trim() == 'system-updates' || element.title.trim() == 'System Updates' || element.title.trim() == 'System Software Updates') {
                                this.isYearValid = true;
                                this.allCategoriesData.push({
                                    title: element.title,
                                    features: element.view
                                });
                                //console.log('@@has system update');
                            }
                        })
                    }
                })
                .catch((error) => {
                    //console.log('@@error-->', error);
                })
        }

    };

    async handleClickHeader() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        if (this.allCategoriesData) {
            sessionStorage.setItem('howtoguides', JSON.stringify(this.allCategoriesData[0]));
        }
        await this.sleep(2000);
        this.navigate('/how-to-category?fb=mp', {});
    }

    async handleClickAction() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        if (this.allCategoriesData) {
            sessionStorage.setItem('howtoguides', JSON.stringify(this.allCategoriesData[0]));
        }
        await this.sleep(2000);
        this.navigate('/how-to-category?fb=mp', {});
    }

    handleClickFooter() {

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
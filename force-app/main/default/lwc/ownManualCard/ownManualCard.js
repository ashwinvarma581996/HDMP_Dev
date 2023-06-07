import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys, getProductContext, ISGUEST } from 'c/ownDataUtils';
import getManualByVIN from '@salesforce/apex/OwnAPIController.getManualByVIN';
import getManualByModelPS from '@salesforce/apex/OwnManualsApiController.getManualByModelPS';
import getManualByVINAuto from '@salesforce/apex/OwnManualsApiController.getManualByVINAuto';
import getManualByModelIdAuto from '@salesforce/apex/OwnManualsApiController.getManualByModelIdAuto';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnManualCard extends OwnBaseElement {
    @api contentId;
    @api showBody;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @api brandName;
    @api brand;
    @api icon;
    @api title;
    @api titlecolor;
    @api headerlink = '';
    @track context;
    @api showforwardicon;
    @api showfooter;
    @api showdownlaodicon;
    @track results;
    @api body;
    @api actionIcon = 'download.svg';
    show = false;
    @track cardDivClass = '';
    @track powerSportsEndpoint = 'https://cdn.powersports.honda.com'

    get bodyClass() {
        return this.showfooter ? 'slds-card__body_inner card-body-footer' : 'slds-card__body_inner card-body';
    }

    get titleClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-text-heading_small  title red' : 'slds-text-heading_small title';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon forward-icon-right background-grey' : 'slds-p-left_small forward-icon-right';
    }

    /* get body(){
        let bodyLine = '';
    
        bodyLine = (this.brandName === 'Acura' || this.brand === 'B'  ) ? 'Access and download complete user manuals online.' : bodyLine;
        bodyLine = (this.brandName === 'Honda' || this.brand === 'A') ? 'Access and download complete user manuals online.' : bodyLine;
        bodyLine = (this.brandName === 'Powersports' || this.brand === 'PS') ? 'Access and download complete user manuals for your Honda Powersports vehicle online.' : bodyLine;
        bodyLine = (this.brandName === 'Power Equipment' || this.brand === 'PE') ? 'Access and download complete user manuals online.' : bodyLine;
        bodyLine = (this.brandName === 'Marine' || this.brand === 'M') ? 'Access and download complete user manuals online.' : bodyLine;
    
        return bodyLine;
    }*/

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if (this.actionIcon !== '') {
            this.actionIcon = this.myGarageResource() + '/ahmicons/' + this.actionIcon;
        }
        if (document.location.pathname.includes('garage-honda') || document.location.pathname.includes('garage-acura') || document.location.pathname.includes('garage-powerequipment') || document.location.pathname.includes('garage-powersports') || document.location.pathname.includes('garage-marine')) {
            this.cardDivClass = 'overview-tab-class';
        }
        if (document.location.pathname.includes('owners-manuals')) {
            this.cardDivClass = 'owners-manuals-class';
        }
        this.initialize();
    }

    initialize = async () => {
        try {
            //    const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
            var context;
            let origin = localStorage.getItem('origin');
            if (ISGUEST || origin == 'ProductChooser') {
                context = await getProductContext('', true);
            } else {
                context = await getProductContext('', false);
            }
            if (context) {
                this.context = context;
                this.contentKeys.push(this.contentId);
                this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
                this.results.forEach(r => {
                    this.body = this.htmlDecode(r.body.value);
                    if (this.body.includes('PRODUCTMODELVALUE')) {
                        this.body = this.body.replace('PRODUCTMODELVALUE', context.product.model);
                    }
                });
                if (context.product.divisionId == 'P' && !document.location.pathname.includes('owners-manuals')) {
                    await getManualByVIN({ productIdentifier: context.product.vin, divisionId: context.product.divisionId, division: context.product.division, modelId: context.product.modelId })
                        .then((data) => {
                            if (data.isMultiple == false) {
                                let [key, value] = Object.entries(data.manualsByModel)[0];
                                this.headerlink = value[0].url;
                                //  this.title = context.product.model + " Owner's Manual";
                                this.showdownlaodicon = true;
                                // this.showforwardicon = false;
                            } else {
                                this.showdownlaodicon = false;
                                //  this.showforwardicon = true;
                            }
                        }).catch((error) => {
                            //console.error('Error:', error);
                        });
                }
                if (context.product.divisionId == 'M' && !document.location.pathname.includes('owners-manuals')) {
                    await getManualByModelPS({ divisionId: context.product.divisionId, division: context.product.division, modelId: context.product.modelId })
                        .then((data) => {
                            if (data.isMultiple == false) {
                                this.headerlink = data.manualsByModel[0].path;
                                this.showdownlaodicon = true;
                            } else {
                                this.showdownlaodicon = false;
                            }
                        }).catch((error) => {
                            //console.log('Error:', error);
                        });
                }
                if ((context.product.divisionId == 'A' || context.product.divisionId == 'B') && !document.location.pathname.includes('owners-manuals')) {
                    if (context.product.vin && context.product.vin != '-') {
                        await getManualByVINAuto({ productIdentifier: context.product.vin, divisionId: context.product.divisionId, division: context.product.division })
                            .then((data) => {
                                if (data.isMultiple == false) {
                                    this.headerlink = data.manualsList[0].url;
                                    this.showdownlaodicon = true;
                                } else {
                                    this.showdownlaodicon = false;
                                }
                            }).catch((error) => {
                                //console.log('Error:', error);
                            });
                    } else {
                        await getManualByModelIdAuto({ divisionId: context.product.divisionId, division: context.product.division, modelId: context.product.modelId })
                            .then((data) => {
                                if (data.isMultiple == false) {
                                    this.headerlink = data.manualsList[0].url;
                                    this.showdownlaodicon = true;
                                } else {
                                    this.showdownlaodicon = false;
                                }
                            }).catch((error) => {
                                //console.log('Error:', error);
                            });
                    }
                }
                if (this.body) {
                    this.showBody = true;
                } else {
                    this.showBody = false;
                }
                let divisionId = context.product.divisionId;
                let model = context.product.model;
                let year = context.product.year;
                let vin = context.product.vin;
                let division = context.product.division;

                if (document.location.pathname.includes('-service-maintenance')) {
                    if (divisionId == 'B' || divisionId == 'A' || divisionId == 'M') {
                        this.title = year + ' ' + model + ' MANUAL';
                    } else if (division == 'Marine') {
                        this.title = model + ' ' + vin + " OWNER'S MANUAL";
                    } else if (divisionId == 'P') {
                        this.title = model + " OWNER'S MANUAL";
                    }
                }
                if (document.location.pathname.includes('garage-')) {
                    if (divisionId == 'P') {
                        this.title = model + " OWNER'S MANUAL";
                    }
                }
                //console.log('@@Test' + this.title);
                //console.log('@@Test' + document.location.pathname.includes('owners-manuals'));
                //console.log('@@Test' + this.headerlink);
                if (!(this.headerlink === undefined)) {
                    if (document.location.pathname.includes('owners-manuals') && !this.headerlink.toLowerCase().includes(".pdf")) {
                        this.showdownlaodicon = false;
                        this.showforwardicon = true;
                    }
                }
            }
            this.show = true;
        } catch (e) {
            this.show = true;
            //console.log('@@Exception' + e);
        }
    }

    async handleClickHeader() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = this.buildAdobeMessage(this.headerlink, eventMetadata);
        this.publishToChannel(message);

        if (document.location.pathname.includes('-resources-downloads')) {
            sessionStorage.setItem('frompage', 'Resources & Downloads');
        }
        if (document.location.pathname.includes('-service-maintenance')) {
            sessionStorage.setItem('frompage', 'Service & Maintenance');
        }
        if (document.location.pathname.includes('garage-')) {
            sessionStorage.setItem('frompage', 'Overview');
        }
        if (this.context.product.divisionId == 'M' && !this.headerlink.includes('owners-manuals') && !this.headerlink.includes(this.powerSportsEndpoint)) {
            this.headerlink = this.powerSportsEndpoint + this.headerlink;
        }
        //console.log('@@headerlink+' + this.headerlink);
        await this.sleep(2000);
        this.navigate(this.headerlink, {});
    }

    handleClickAction() {

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
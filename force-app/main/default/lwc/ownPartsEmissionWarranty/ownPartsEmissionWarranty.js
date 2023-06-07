import { LightningElement, track, api } from 'lwc';
import getStateData from '@salesforce/apex/OwnEditAddressContrller.getStateData';
import getUserMailingState from '@salesforce/apex/OwnWarrantyController.getUserMailingState';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys, ISGUEST } from 'c/ownDataUtils';
import statewarrantiesautos from '@salesforce/resourceUrl/statewarrantiesautos';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
export default class ownPartsEmissionWarranty extends OwnBaseElement {
    @api title1 = 'WARRANTY INFORMATION';
    @api icon;
    @api titlecolor = 'Honda Red';
    @api brand = 'default';
    @api body = 'Test';
    @api statesData;

    @api contentid = '';
    @api bannercontentid;
    @api contentid2 = '';
    @track contentTitle1;
    @track contentBody1;
    @track contentTitle2;
    @track contentBody2;
    @track downloadLink;
    @track downloadLink1;
    @track downloadLink2;
    @track hideBody;
    @track hideBody1;
    @track hideBody2;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track stateAndPdfMap = new Map();
    @track showFooter = false;
    @track showForwardIcon = false;
    @track states = [];
    @track state;
    @track californiaState;
    @track showWarrantyCard = false;
    @track hasMailingState = false;
    @track mailingState;
    @track isGuest = ISGUEST;

    connectedCallback() {
        //console.log('$EW-isGuest', this.isGuest);
        //console.log('$EW-StatesData', JSON.parse(this.statesData));
        let statesAndPdfs = JSON.parse(this.statesData);
        statesAndPdfs.forEach(st => {
            this.stateAndPdfMap.set(st.state, 'https://owners.honda.com/Documentum/' + st.pdf);
            this.states.push({ label: st.state, value: st.state });
        });
        //console.log('$EW-States', JSON.parse(JSON.stringify(this.states)));
        //console.log('$EW-StateAndPdfMap', this.stateAndPdfMap);
        this.icon = this.myGarageResource() + '/ahmicons/' + 'black-booklet.svg';
        // this.loadInitialData();
        this.initialize();
    }

    initialize = async () => {
        if (!this.isGuest) {
            getUserMailingState().then((result) => {
                //console.log("$EW-MailingState: ", result)
                if (result && this.stateAndPdfMap.has(result)) {
                    this.mailingState = result;
                    this.state = result;
                }
                this.hasMailingState = result ? true : false;
            }).catch((err) => {
                //console.log("$EW-MailingState: err", err)
            });
        }
        this.contentKeys.push(this.contentid);
        this.results = await getManagedContentByTopicsAndContentKeys([this.contentid], this.topics, this.pageSize, this.managedContentType);
        //console.log('this.results-1:', JSON.parse(JSON.stringify(this.results)));
        this.results.forEach(r => {
            this.contentTitle1 = this.htmlDecode(r.title.value);
            this.downloadLink1 = statewarrantiesautos + r.downloadLink.value;
            if (r.body) {
                this.contentBody1 = this.htmlDecode(r.body.value);
            } else {
                this.hideBody1 = true;
            }
        });
        this.contentKeys.push(this.contentid2);
        this.results = await getManagedContentByTopicsAndContentKeys([this.contentid2], this.topics, this.pageSize, this.managedContentType);
        //console.log('this.results-2:', JSON.parse(JSON.stringify(this.results)));
        this.results.forEach(r => {
            this.contentTitle2 = this.htmlDecode(r.title.value);
            this.downloadLink2 = statewarrantiesautos + r.downloadLink.value;
            if (r.body) {
                this.contentBody2 = this.htmlDecode(r.body.value);
            } else {
                this.hideBody2 = true;
            }
        });
        //console.log('this.downloadLink1', this.downloadLink1);
        //console.log('this.downloadLink2', this.downloadLink2);
        if (this.hasMailingState) {
            this.handleFindButton();
        }
    }

    loadInitialData() {
        getStateData({
        })
            .then((result) => {
                //console.log('RESULT: states: ', result);
                this.states = result;
            })
            .catch((error) => {
                //console.error('Error: states: ', error);
            });
    }

    handleStateChange(event) {
        this.state = event.target.value;
    }

    handleFindButton() {
        this.hasMailingState = this.state != this.mailingState ? false : true;
        if (this.state === 'California') {
            this.californiaState = true;
            this.title1 = this.contentTitle2;
            this.showWarrantyCard = true;
            this.body = this.contentBody2;
            this.downloadLink = this.downloadLink2;
            this.hideBody = this.hideBody2;
        }
        else {
            this.californiaState = false;
            this.title1 = this.state + ' WARRANTY INFORMATION';
            this.showWarrantyCard = true;
            this.body = this.contentBody1;
            this.downloadLink = this.downloadLink1;
            this.hideBody = this.hideBody1;
        }
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }

    get titleClass() {
        return 'slds-text-heading_small title red';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon ' : 'slds-p-left_small ';
    }

    handleHeaderClick() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title1
        };
        let message = this.buildAdobeMessage(this.stateAndPdfMap.get(this.state), eventMetadata);

        this.publishToChannel(message);
        window.open(this.stateAndPdfMap.get(this.state), "_blank");
    }

    handleUpdateAddress() {
        this.navigate('/my-account', {});
    }
    @api
    getElementFromChild() {
        return this.template.querySelector('.emission-warranty-section');
    }
}
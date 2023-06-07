import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys, getProductContext, getContext, getOrigin } from 'c/ownDataUtils';
import { getCMSContent } from 'c/ownCMSContent';
import warranties from '@salesforce/resourceUrl/warranties';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnWarrantiesPowerequipment extends OwnBaseElement {
    @api icon;
    @api titlecolor = 'Honda Red';

    @api contentIdPowerequipmentPage;
    @api dateWisePdfTopicPowerequipment;
    @api emmissionWisePdfTopicPowerequipment;

    @track contentBody;
    @track contentTitle;
    @track dates;
    @track date;
    @track showDateCard;
    @track dateTitle;
    @track context;
    datesPdfMap = new Map();

    @track emissions;
    @track emission;
    @track showEmissionCard;
    @track emissionTitle;
    emissionsPdfMap = new Map();

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + 'black-booklet.svg';
        this.initialize();

    }
    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext('');
        }
        //console.log('CONTEXT OwnWarrantiesPowerequipment - ', JSON.parse(JSON.stringify(this.context)));
        this.results = await getManagedContentByTopicsAndContentKeys([this.contentIdPowerequipmentPage], null, null, '');
        this.results.forEach(r => {
            this.contentBody = this.htmlDecode(r.body.value);
            this.contentTitle = this.htmlDecode(r.title.value);
        });
        this.getPdfsByDates(await getCMSContent([this.dateWisePdfTopicPowerequipment]));
        this.getPdfsByEmmission(await getCMSContent([this.emmissionWisePdfTopicPowerequipment]));
        if (this.context && this.context.product) {
            this.contentTitle = this.context.product.model + ' Product Warranty';
        }
    }

    handleDateChange(event) {
        this.activeDeactivateButtonFirst();
        this.dateTitle = event.target.value;
    }
    handleEmissionDateChange(event) {
        this.activeDeactivateButtonSecond();
        this.emissionTitle = event.target.value;
    }
    handleFindDatePdfs() {
        this.showDateCard = true;
        this.date = this.datesPdfMap.get(this.dateTitle);
    }
    handleFindEmissionPdfs() {
        this.showEmissionCard = true;
        this.emission = this.emissionsPdfMap.get(this.emissionTitle);
    }
    getPdfsByEmmission(pdfs) {
        let emissionsarray = [];
        pdfs = JSON.parse(JSON.stringify(pdfs));
        pdfs = pdfs.sort(function (a, b) { return parseInt(b.contentNodes.downloadLabel.value) - parseInt(a.contentNodes.downloadLabel.value) });
        pdfs.forEach(r => {
            let title = this.htmlDecode(r.contentNodes.downloadLabel.value);
            let body = r.contentNodes.hasOwnProperty('body') ? this.htmlDecode(r.contentNodes.body.value) : '';
            let title_cp = title == '2012' ? '2012 or earlier' : title;
            emissionsarray.push({
                label: title_cp,
                value: title
            });
            this.emissionsPdfMap.set(title, {
                title: title + ' EMISSION CONTROL SYSTEM WARRANTY',
                body: body,
                download_link: warranties + r.contentNodes.video_link.value,
                hideBody: body ? false : true
            });
        });
        this.emissions = emissionsarray;
    }

    getPdfsByDates(pdfs) {
        let datesarray = [];
        pdfs = JSON.parse(JSON.stringify(pdfs));
        pdfs = pdfs.sort(function (a, b) { return parseInt(b.contentNodes.downloadLabel.value) - parseInt(a.contentNodes.downloadLabel.value) });
        pdfs.forEach(r => {
            //console.log('r: ', r);
            let title = this.htmlDecode(r.contentNodes.title.value);
            let body = r.contentNodes.hasOwnProperty('body') ? this.htmlDecode(r.contentNodes.body.value) : '';
            datesarray.unshift({
                label: title,
                value: title
            });
            this.datesPdfMap.set(title, {
                title: title,
                body: body,
                download_link: warranties + r.contentNodes.video_link.value,
                hideBody: body ? false : true
            });
        });
        this.dates = datesarray;
    }
    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon ' : 'slds-p-left_small ';
    }
    handleHeaderClick(event) {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: event.target.dataset.title
        };
        let message = this.buildAdobeMessage(event.target.dataset.link, eventMetadata);
        this.publishToChannel(message);
        let isMobile = window.matchMedia("(max-width: 600px)").matches;
        if (isMobile) {
            window.open(event.target.dataset.link, "_blank");
        } else {
            let pdfLink = event.target.dataset.link;
            sessionStorage.setItem('pdflink', pdfLink);
            window.open(window.location.origin + window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/')) + '/pdf-document' + '?PDF=' + pdfLink.substring(pdfLink.lastIndexOf('/') + 1), "_blank");
        }
        // window.open(event.target.dataset.link, "_blank");
    }
    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
    activeDeactivateButtonFirst() {
        this.template.querySelector('.find-button-1').classList.remove('slds-brand-button-inactive');
        this.template.querySelector('.find-button-1').classList.add('slds-brand-button-active');
    }
    activeDeactivateButtonSecond() {
        this.template.querySelector('.find-button-2').classList.remove('slds-brand-button-inactive');
        this.template.querySelector('.find-button-2').classList.add('slds-brand-button-active');
    }
    openSampleEmissionLabel() {
        this.navigate('/sample-emission-label-powerequipment', {});
    }
}
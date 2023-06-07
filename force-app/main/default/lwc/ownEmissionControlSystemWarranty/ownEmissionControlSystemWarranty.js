import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getCMSContent } from 'c/ownCMSContent';
import warranties from '@salesforce/resourceUrl/warranties';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnEmissionControlSystemWarranty extends OwnBaseElement {

    @api icon;
    @api titlecolor = 'Honda Red';
    @api emmissionWisePdfTopicMarine;

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
        this.getPdfsByEmmission(await getCMSContent([this.emmissionWisePdfTopicMarine]));
    }

    getPdfsByEmmission(pdfs) {
        pdfs = JSON.parse(JSON.stringify(pdfs));
        pdfs = pdfs.sort(function (a, b) { return parseInt(b.contentNodes.downloadLabel.value) - parseInt(a.contentNodes.downloadLabel.value) });
        let emissionsarray = [];
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
    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon ' : 'slds-p-left_small ';
    }
    handleEmissionDateChange(event) {
        this.activeDeactivateButton();
        //console.log(event.target.value);
        this.emissionTitle = event.target.value;
    }
    handleFindEmissionPdfs() {
        this.showEmissionCard = true;
        this.emission = this.emissionsPdfMap.get(this.emissionTitle);
    }
    handleHeaderClick(event) {
        // window.open(event.target.dataset.link, "_blank");
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
    }
    activeDeactivateButton() {
        this.template.querySelector('.find-button').classList.remove('slds-brand-button-inactive');
        this.template.querySelector('.find-button').classList.add('slds-brand-button-active');
    }
    openSampleEmissionLabel() {
        this.navigate('/marine-emissions-location-label', {});
    }
}
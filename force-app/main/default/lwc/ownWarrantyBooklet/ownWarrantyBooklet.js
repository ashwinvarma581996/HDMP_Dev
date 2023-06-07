import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getCMSContent } from 'c/ownCMSContent';
import powersportswarranties from '@salesforce/resourceUrl/powersportswarranties';
import getSegmentValue from '@salesforce/apex/OwnWarrantyController.getSegmentValue';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class ownWarrantyBooklet extends OwnBaseElement {
    @api title1 = 'DOWNLOAD THE 2019 HR-V WARRANTY BOOKLET';
    // @api icon = 'utility:connected_apps';
    // @api titlecolor='Honda Red';
    @api brand = 'default';
    @api body = 'PDF Description';
    @api context;
    @track showFooter = false;
    @track showForwardIcon = false;
    @track booklet;
    @track segmentValue;
    @track warningicon;
    @track fetchedData;

    @api warrantiesTopicPowersports;
    @api icon;
    @api titlecolor = 'Honda Red';
    connectedCallback() {
        this.context = JSON.parse(JSON.stringify(this.context));
        //console.log('CONTEXT OwnWarrantyBooklet: ', this.context);
        this.icon = this.myGarageResource() + '/ahmicons/' + 'black-booklet.svg';
        //console.log('powersportswarranties: ', powersportswarranties);
        this.initialize();
        //console.log('warrantiesTopicPowersports: ', this.warrantiesTopicPowersports);
        this.warningicon = this.myGarageResource() + '/ahmicons/warning.png';
    }
    initialize = async () => {
        if (this.context.product) {
            await getSegmentValue({ modelId: this.context.product.modelId }).then((result) => {
                this.segmentValue = result;
                //console.log('SEGMENT result: ', result);
            }).catch((err) => {
                this.fetchedData = true;
                console.error(err);
            });
        }
        //console.log('SEGMENT: ', this.segmentValue);
        this.getPsWarranties(await getCMSContent([this.warrantiesTopicPowersports]));
    }
    getPsWarranties(pdfs) {
        pdfs = JSON.parse(JSON.stringify(pdfs));
        //console.log('PDFS: ', pdfs);
        pdfs.forEach(r => {
            if (r.contentNodes.downloadLabel.value == this.segmentValue) {
                let title = this.htmlDecode(r.contentNodes.title.value);
                let body = this.htmlDecode(r.contentNodes.body.value);
                let download_link = powersportswarranties + this.htmlDecode(r.contentNodes.download_link.value);
                this.booklet = {
                    title: title,
                    body: body,
                    download_link: download_link,
                    hideBody: body ? false : true
                };
            } else {
                this.fetchedData = true;
            }
        });
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
}
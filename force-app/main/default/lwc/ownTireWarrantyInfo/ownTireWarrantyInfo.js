import { api, track } from 'lwc';
import { getCMSContent } from 'c/ownCMSContent';
import { OwnBaseElement } from 'c/ownBaseElement';
import warrantiesautos from '@salesforce/resourceUrl/warrantiesautos';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
const cards = [{ 'title': 'BRIDGESTONE/FIRESTONE' },
{ 'title': 'CONTINENTAL' },
{ 'title': 'GOODYEAR/DUNLOP' },
{ 'title': 'HANKOOK' },
{ 'title': 'JK' },
{ 'title': 'KENDA' },
{ 'title': 'MAXXIS' },
{ 'title': 'MICHELIN' }]

export default class ownTireWarrantyInfo extends OwnBaseElement {

    @api icon = 'black-booklet.svg';
    @api titlecolor = 'Honda Red';
    @api brand = 'Honda';
    @api body = 'PDF Description';

    @api accordianTopicAcura = "Tire Warranty Information Accordion - Acura";
    @api accordianTopicHonda = "Tire Warranty Information Accordion - Honda";

    @track showFooter = false;
    @track showForwardIcon = false;
    @track cards;

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        //console.log(' Accordion Topics ', this.accordianTopicAcura + ' ', this.accordianTopicHonda, '; Brand ' + this.brand);
        this.getContentByBrand(this.brand);
    }

    async getContentByBrand(brand) {
        if (brand == 'Honda') {
            this.getAccordians(await getCMSContent([this.accordianTopicHonda]));
            //console.log('Accordion ', this.accordianTopicHonda);

        } else {
            this.getAccordians(await getCMSContent([this.accordianTopicAcura]));
            //console.log('Accordion ', this.accordianTopicHonda);
        }

    }

    getAccordians(accordian) {
        //console.log('accordians', accordian);
        this.accordianSections = [];
        accordian.forEach(currentItem => {
            let body_obj = JSON.parse(JSON.stringify(currentItem.contentNodes.body));
            let link_obj;
            body_obj.value = this.htmlDecode(body_obj.value);
            //console.log(' ContentNodes ', JSON.stringify(currentItem.contentNodes));

            if (currentItem.contentNodes.download_link) {
                //console.log(JSON.stringify(currentItem.contentNodes.download_link.value));
                // link_obj = currentItem.contentNodes.download_link.value;
                link_obj = warrantiesautos + currentItem.contentNodes.video_link.value;
                // link_obj = currentItem.contentNodes.video_link.value.includes('Bridgestone') ? currentItem.contentNodes.download_link.value : warrantiesautos + currentItem.contentNodes.video_link.value;
            }

            this.accordianSections.push(
                {
                    body: body_obj,
                    title: currentItem.contentNodes.title,
                    key: currentItem.contentKey,
                    link: link_obj
                }
            );
        });
        //console.log('this.accordianSections: ', JSON.parse(JSON.stringify(this.accordianSections)));
        this.cards = this.accordianSections;
        //console.log('this.cards: ', JSON.parse(JSON.stringify(this.cards)));
    }

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }
    handlePdfDownload() {
        window.open(this.contents.video.value, "_blank");
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
    }

    @api
    getElementFromChild() {
        return this.template.querySelector('.tire-warranty-section');
    }
}
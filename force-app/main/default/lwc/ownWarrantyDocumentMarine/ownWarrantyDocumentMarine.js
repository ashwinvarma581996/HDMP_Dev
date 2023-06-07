import { api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import warranties from '@salesforce/resourceUrl/warranties';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnWarrantyDocumentMarine extends OwnBaseElement {

    @api icon;
    @api titlecolor = 'Honda Red';

    @api contentIdMarineDoc;
    @track emission;
    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + 'black-booklet.svg';
        this.initialize();
    }
    initialize = async () => {
        let results = await getManagedContentByTopicsAndContentKeys([this.contentIdMarineDoc], null, null, '');
        //console.log('results: ', results);
        results.forEach(r => {
            this.emission = {
                title: r.title.value,
                body: r.hasOwnProperty('body') ? this.htmlDecode(r.body.value) : '',
                download_link: warranties + r.videoLink.value,
            };
            this.emission['hideBody'] = this.emission.body ? false : true;
        });
    }
    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon ' : 'slds-p-left_small ';
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
    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent;
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon ' : 'slds-p-left_small ';
    }

    handleHeaderClick(){
        
    }
}
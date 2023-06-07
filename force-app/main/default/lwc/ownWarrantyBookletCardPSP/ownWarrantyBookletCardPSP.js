import { LightningElement, api, track } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import { ISGUEST, getProductContext, getContext, getOrigin } from 'c/ownDataUtils';
import powersportswarranties from '@salesforce/resourceUrl/powersportswarranties';
import getSegmentValue from '@salesforce/apex/OwnWarrantyController.getSegmentValue';
import { getCMSContent } from 'c/ownCMSContent';
import basePath from '@salesforce/community/basePath';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnWarrantyBookletCardPSP extends OwnBaseElement {
    isGuest = ISGUEST;
    @track body;
    @track title;
    @api warrantiesTopicPowersports;
    @api titlecolor = 'Honda Red';
    @api headerLink = '/warranty-info';
    @api actionIcon = 'download.svg';
    @api icon = 'adobe-pdf.svg';
    @track segmentValue;
    get titleClass() {
        return 'slds-text-heading_small title red';
    }

    get iconClass() {
        return this.titlecolor === 'Honda Red' ? 'slds-p-left_small custom-icon' : 'slds-p-left_small';
    }

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        if (this.actionIcon !== '') {
            this.actionIcon = this.myGarageResource() + '/ahmicons/' + this.actionIcon;
        }
        this.initialize();
    }


    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext();
            // this.context = await getContext('');
        }
        this.title = this.context.product.year + ' ' + this.context.product.model + ' ' + 'WARRANTY BOOKLET';
        this.body = 'Review the warranty policy for your ' + this.context.product.year + ' ' + this.context.product.model + '.';
        if (this.context.product) {
            await getSegmentValue({ modelId: this.context.product.modelId }).then((result) => {
                this.segmentValue = result;
                //console.log('SEGMENT value: ', result);
            }).catch((err) => {
                console.error(err);
            });
        }
        this.getPsWarranties(await getCMSContent([this.warrantiesTopicPowersports]));
        //console.log('segment value', this.segmentValue)
    }
    getPsWarranties(pdfs) {
        pdfs = JSON.parse(JSON.stringify(pdfs));
        //console.log('PDFS: ', pdfs);
        pdfs.forEach(r => {
            if (r.contentNodes.downloadLabel.value == this.segmentValue) {
                this.headerLink = window.location.origin + powersportswarranties + this.htmlDecode(r.contentNodes.download_link.value);
            }
        });
        //console.log('header link', this.headerLink)
    }
    handleHeader() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: this.title
        };
        let message = this.buildAdobeMessage(this.headerLink, eventMetadata);
        this.publishToChannel(message);
        let isMobile = window.matchMedia("(max-width: 600px)").matches;
        if (isMobile) {
            this.navigate(this.headerLink, '_blank', {});
        } else {
            let pdfLink = this.headerLink;
            console.log('$pdfLink: ',pdfLink);
            sessionStorage.setItem('pdflink', pdfLink);
            window.open(window.location.origin + window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/')) + '/pdf-document' + '?PDF=' + pdfLink.substring(pdfLink.lastIndexOf('/') + 1), "_blank");
        }
        //this.navigate(this.headerLink, '_blank', {});
    }
}
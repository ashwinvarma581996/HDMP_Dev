import { track, api, LightningElement } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
import AutoLinkLegalTerms from '@salesforce/resourceUrl/AutoLinkLegalTerms';
import AutoLinkGoogleBuiltIn from '@salesforce/resourceUrl/AutoLinkGoogleBuiltIn';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnAutoLinkCard extends OwnBaseElement {
    @api icon;
    @track title;
    //@api titlecolor = 'Honda Red';
    @track contentKeys = [];


    @api contentId;
    @api Link1Name;
    @api Link2Name;
    @api Link3Name;
    @api Link4Name;
    @api Link5Name;

    @api Link1;
    @api Link2;
    @api Link3;
    @api Link4;
    @api Link5;

    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        this.initialize();
    }

    initialize = async () => {
        this.contentKeys.push(this.contentId);
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            this.title = this.htmlDecode(r.title.value);
            if (r.phoneLabel) { this.Link1Name = this.htmlDecode(r.phoneLabel.value) }
            if (r.phoneNumber) { this.Link1 = this.htmlDecode(r.phoneNumber.value) }
            if (r.phone2Label) { this.Link2Name = this.htmlDecode(r.phone2Label.value) }
            if (r.phone2Number) { this.Link2 = this.htmlDecode(r.phone2Number.value) }
            if (r.phone3Label) { this.Link3Name = this.htmlDecode(r.phone3Label.value) }
            if (r.phone3Number) { this.Link3 = this.htmlDecode(r.phone3Number.value) }
            if (r.phone4Label) { this.Link4Name = this.htmlDecode(r.phone4Label.value) }
            if (r.phone4Number) { this.Link4 = this.htmlDecode(r.phone4Number.value) }
            if (r.downloadLabel) { this.Link5Name = this.htmlDecode(r.downloadLabel.value) }
            if (r.downloadLink) { this.Link5 = this.htmlDecode(r.downloadLink.value) }

            if (r.body) {
                this.Link6Name = this.htmlDecode(r.body.value)
                //Removing <P> tag from the body
                var div = document.createElement("div");
                div.innerHTML = this.Link6Name;
                this.Link6Name = div.textContent || div.innerText || "";
            }

            if (r.videoLink) { this.Link6 = this.htmlDecode(r.videoLink.value) }
        })
    }
    async handleLink(event) {
        
        if(window.location.pathname.endsWith('acura-product-compatibility-result')){
            sessionStorage.setItem('frompage','AcuraLink');
        }else if(window.location.pathname.endsWith('honda-product-compatibility-result')){
            sessionStorage.setItem('frompage','HondaLink');
        }

        let link = event.target.dataset.link;
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: event.target.dataset.title
        };
        // let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        let message = this.buildAdobeMessage(link, eventMetadata)
        this.publishToChannel(message);

        //console.log("ownAutoLinkCardURL", event.target.dataset.link)
        if (link.includes(".pdf")) {
            let url = '';
            if(document.location.pathname.includes('google-built-in')){
                url = window.location.origin + AutoLinkGoogleBuiltIn + link;
            }else{
                url = window.location.origin + AutoLinkLegalTerms + link;
            }
            //console.log("ownAutoLinkCardURL1", url)
            let isMobile = window.matchMedia("(max-width: 600px)").matches;
            if (isMobile) {
                window.open(url, "_blank");
            } else {
                let pdfLink = url;
                sessionStorage.setItem('pdflink', pdfLink);
                window.open(window.location.origin + window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/')) + '/pdf-document' + '?PDF=' + pdfLink.substring(pdfLink.lastIndexOf('/') + 1), "_blank");
            }
        } else {
            await this.sleep(2000);
            this.navigate(link, {})
        }
    }



    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
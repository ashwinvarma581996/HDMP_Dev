import { LightningElement, wire } from 'lwc';//for adobe analytics:imported wire 
import imageResourcePath from '@salesforce/resourceUrl/footer_files';

//for adobe analytics:starts
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { publish, MessageContext } from 'lightning/messageService';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';
//for adobe analytics:ends


import RETURN_POLICY_URL from '@salesforce/label/c.RETURN_POLICY_URL';

import Part_and_Accessories_URL from '@salesforce/label/c.Part_and_Accessories_URL'; // Added by ashwin for 17421

const PRIVACYOPTIONICON = '/resource/honda_images/privacyoptions.png';


export default class BannerFooter extends LightningElement {
    currentYear;
    privacyOptionIcon = PRIVACYOPTIONICON;
    pro65pdf = imageResourcePath + '/Prop65.pdf';
    smsterms = imageResourcePath + '/SMSTerms.pdf';
    vehicledatapolicy = imageResourcePath + '/VehicleDataPrivacyPolicy.pdf';
    hondaprivacypolicy = imageResourcePath + '/HondaPrivacyPolicy.pdf';
    tcComparison = imageResourcePath + '/TC_Comparison.docx';
    faqpolicy = imageResourcePath + '/FAQsPoliciesComparison..xlsx';
    eStoreDealer = imageResourcePath + '/eStoreDealerAgreement.pdf';
    eStoreFaq = imageResourcePath + '/eStoreFAQs.docx';
    eStoreTC = imageResourcePath + '/eStore_TC.docx';
    accessorywarranty = imageResourcePath + '/Honda-Accessory-Warranty-Message.pdf';

    //for adobe analytics:MessageContext
    @wire(MessageContext)
    messageContext;


    // Added By ashwin for 17421
    redirectURLObj = {
        return_policy: RETURN_POLICY_URL,  //'https://dreamshop.honda.com/assets/pdf/DreamshopReturnPolicy.pdf',
        part_and_accessory_warranty: Part_and_Accessories_URL //'https://dreamshop.honda.com/assets/pdf/PartsAccessoriesWarranty.pdf'
    }

    //Variables
    sfdcBaseURL;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin + '/s/findmyorder';
        const d = new Date();
        this.currentYear = d.getFullYear();
    }

// Started by ashwin and Lakshmi for bug 17421
    openPdf(event) {
         let dataId = event.target.dataset.id;
         let link = this.redirectURLObj[dataId];

         this.handleAdobeClick(event);//for adobe analytics

         sessionStorage.setItem('pdflink', link);

         console.log('footer===> ' + this.redirectURLObj[dataId]);
         window.open(window.location.origin + window.location.pathname.substring(0, window.location.pathname.indexOf('/') + 2) + '/pdf-document' + '?PDF=' + link.substring(link.lastIndexOf('/') + 1), "_blank");
     }
// ended by ashwin and Lakshmi for bug 17421

    //    HDMP-16442-Imtiyaz-START
   /* openPdf(event) {//for adobe analytics
        this.handleAdobeClick(event);//for adobe analytics
        let isMobile = window.matchMedia("(max-width: 600px)").matches;
        let link = 'https://dreamshop.honda.com/assets/pdf/PartsAccessoriesWarranty.pdf';
        if (isMobile) {
            window.open(link, "_blank");
        } else {
            sessionStorage.setItem('pdflink', link);
            console.log('footer -------> ',window.location.origin + window.location.pathname.substring(0, window.location.pathname.indexOf('/') + 2) + '/pdf-document' + '?PDF=' + link.substring(link.lastIndexOf('/') + 1), "_blank");
            window.open(window.location.origin + window.location.pathname.substring(0, window.location.pathname.indexOf('/') + 2) + '/pdf-document' + '?PDF=' + link.substring(link.lastIndexOf('/') + 1), "_blank");

        }
     }*/
    //    HDMP-16442-Imtiyaz-END



    //for adobe analytics:starts
    async handleAdobeClick(event) {
        console.log("Clicked footer link ", event);
        let eventMetadata = {
            action_label: event.target.dataset.label,
            action_category: event.target.dataset.actionCategory,
            action_type: 'footer links'
        }
        let page = {};
        let eventType;
        if (event.target.dataset.clickType == 'other click') {
            if (event.target.dataset.actionCategory == 'global footer privacy') {
                eventType = DATALAYER_EVENT_TYPE.COMPLIANCE_CLICK;
            } else {
                eventType = DATALAYER_EVENT_TYPE.CLICK;
            }
        } else if (event.target.dataset.clickType == 'exit link') {
            eventType = DATALAYER_EVENT_TYPE.EXIT_EVENT;
            page.destination_url = event.target.dataset.url;
        } else if (event.target.dataset.clickType == 'download link') {
            eventType = DATALAYER_EVENT_TYPE.DOWNLOAD_EVENT;
            eventMetadata.download_title = event.target.dataset.label;
        } else if (event.target.dataset.clickType == 'prop 65') {
            eventType = DATALAYER_EVENT_TYPE.DOWNLOAD_EVENT;
            eventMetadata.download_title = event.target.dataset.label;
        }
        const message = { message: { 'eventType': eventType, 'eventMetadata': eventMetadata, 'page': page } };
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        if (event.target.dataset.label == 'FAQ') {
            await this.sleep(2000);
            window.open('/s/faq', "_self");
        }
        if (event.target.dataset.label == 'Find My Order') {
            await this.sleep(2000);
            window.open(this.sfdcBaseURL, "_self");
        }
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    //for adobe analytics:ends
}
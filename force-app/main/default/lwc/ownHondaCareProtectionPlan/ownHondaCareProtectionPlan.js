//============================================================================
// Title:   Main Component For HondaCare Protection PLan Page   
// Details:  It is accessible from two pages My Garage(Parts & Services) & Help Center Page of Powersports
// From  My Garage(Parts & Services) of Powersports : It will be shown as Product Specific
// From Help Center Page of Powersports : It will be shown as Generic Page 			
//--------------------------------------------------------------------------------------
//
// History:
// October 5, 2021 Abhishek Salecha & Yusuf Deshwali (Wipro) Initial coding
//===========================================================================
import { LightningElement, track, api, wire } from 'lwc';
import commonResources from "@salesforce/resourceUrl/Owners";
import { getCMSContent } from 'c/ownCMSContent';
import basePath from '@salesforce/community/basePath';
import { getCommunityContext, getOrigin, getProductContext } from 'c/ownDataUtils';
import isGuest from '@salesforce/user/isGuest';
import { getProduct } from 'c/ownDataUtils';
import { OwnBaseElement } from 'c/ownBaseElement';
export default class OwnHondaCareProtectionPlan extends OwnBaseElement {

    @api pageContentTopic;
    @api planDetailsContentTopic;
    @api termChartsLargeScreenContentTopic;
    @api termChartsSmallScreenContentTopic;
    @api pricingCalendarLargeScreenTopic;
    @api pricingCalendarSmallScreenTopic;
    isGeneric = false;
    productSubTitle;
    productImageURL;
    productCategory;
    mapImage = commonResources + '/images/find_dealer_map.png';
    productContext;
    @track pageContentNodes;
    body;
    section_content;

    @track planDetailsAccordion;
    @track termsAndChartsLargeScreenAccordion;
    @track termsAndChartsSmallScreenAccordion;
    @track pricingCardLargeScreenContent;
    @track pricingCardSmallScreenContent;

    // Alexander Dzhitenov (Wipro) DOE-4825: Display brand logo image instead of broken image links
    @track division;

    async connectedCallback() {
        //calling getCommunityContext method to fetch context details
        let source = localStorage.getItem('breadcrumb');
        if (source && JSON.parse(source).isGeneric) {
            this.isGeneric = true;
        } else {
            let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
            //console.log('From Product Chooser ----', fromProductChooser);
            if (fromProductChooser) {

                this.productContext = await getProductContext('', true);

            } else {
                this.productContext = await getProductContext('', false);
                // this.context = await getContext('');
            }
            //console.log('productContext context ->', this.productContext);
            if (this.productContext.product) {
                this.productSubTitle = this.productContext.product.year + ' ' + this.productContext.product.model;
            }
            let context = await getCommunityContext();
            //console.log('community context ->', context);
            let product;
            //this.division = context.product.division;
            if (isGuest && context.product && context.product.divisionId === 'M') {
                //console.log('Branch ' + 1);
                product = context.product;
                this.division = 'Powersports';
            } else if (!isGuest && context.productId) {
                //console.log('Branch ' + 2);
                product = await getProduct(context.productId, 'Powersports');
                this.division == 'Powersports';
            } else {
                //console.log('Branch ' + 3);
                this.isGeneric = true;
                this.division == 'Honda';
            }
            //console.log('Division: ' + this.division);
            //console.log('product : ', product);
            if (product) {
                // this.productSubTitle = this.productContext.product.year + ' ' + this.productContext.product.model;
                //console.log("this.productSubTitle", this.productSubTitle)
                if (product.image)
                    this.productImageURL = product.image.toLowerCase().startsWith('/mygarage') || product.image.toLowerCase().startsWith('https') ? product.image : '/mygarage' + product.image;
                else
                    this.productImageURL = '/mygarage/resource/Owners/images/garage_hondadefault.svg';
                this.productCategory = 'Touring Motorcycle';
            } else {
                this.isGeneric = true;
            }
            //console.log('product', product);
        }

        let topics = [this.pageContentTopic, this.planDetailsContentTopic];
        topics = [this.termChartsLargeScreenContentTopic, this.termChartsSmallScreenContentTopic, ...topics];
        /*if(this.isGeneric){
            topics = [this.termChartsLargeScreenContentTopic, this.termChartsSmallScreenContentTopic , ...topics];
        }else{
            this.pricingCalendarLargeScreenTopic = this.productCategory + ' ' + this.pricingCalendarLargeScreenTopic;
            this.pricingCalendarSmallScreenTopic = this.productCategory + ' ' + this.pricingCalendarSmallScreenTopic;
            console.log();  
            topics = [this.pricingCalendarLargeScreenTopic , this.pricingCalendarSmallScreenTopic , ...topics];
        }*/

        let content = await getCMSContent(topics);
        this.setCMSContentForUI(content);

    }

    setCMSContentForUI(content) {
        this.planDetailsAccordion = [];
        this.termsAndChartsSmallScreenAccordion = [];
        this.termsAndChartsLargeScreenAccordion = [];
        //console.log('content .. ', content);

        content.forEach(element => {
            element.associations.topics.forEach(topic => {
                // console.log('element.contentNodes .. ',element.contentNodes);
                let accordionSection;
                switch (topic.name.toLowerCase()) {
                    case this.pageContentTopic.toLowerCase():
                        this.pageContentNodes = element.contentNodes;
                        //console.log('pageContentNodes========', JSON.parse(JSON.stringify(this.pageContentNodes)));
                        this.body = this.convertRichTextToHTML(element.contentNodes.body.value);
                        this.section_content = this.convertRichTextToHTML(element.contentNodes.section_content.value);
                        break;
                    case this.planDetailsContentTopic.toLowerCase():
                        accordionSection = JSON.parse(JSON.stringify(element.contentNodes));
                        accordionSection.body.value = this.convertRichTextToHTML(accordionSection.body.value);
                        accordionSection.key = element.contentKey;
                        this.planDetailsAccordion.push(accordionSection);
                        break;
                    case this.termChartsLargeScreenContentTopic.toLowerCase():
                        accordionSection = JSON.parse(JSON.stringify(element.contentNodes));
                        accordionSection.body.value = this.convertRichTextToHTML(accordionSection.body.value);
                        accordionSection.key = element.contentKey;
                        this.termsAndChartsLargeScreenAccordion.push(accordionSection);
                        break;
                    case this.termChartsSmallScreenContentTopic.toLowerCase():
                        accordionSection = JSON.parse(JSON.stringify(element.contentNodes));
                        accordionSection.body.value = this.convertRichTextToHTML(accordionSection.body.value);
                        accordionSection.key = element.contentKey;
                        this.termsAndChartsSmallScreenAccordion.push(accordionSection);
                        break;
                    case this.pricingCalendarLargeScreenTopic.toLowerCase():
                        this.pricingCardLargeScreenContent = JSON.parse(JSON.stringify(element.contentNodes));
                        this.pricingCardLargeScreenContent.body.value = this.convertRichTextToHTML(this.pricingCardLargeScreenContent.body.value);
                        this.pricingCardLargeScreenContent.image.url = this.convertRichTextToHTML(this.pricingCardLargeScreenContent.image.url);
                        if (this.productCategory) {
                            this.pricingCardLargeScreenContent.phone_label.value = this.productCategory + ' ' + this.pricingCardLargeScreenContent.phone_label.value;
                            this.pricingCardLargeScreenContent.phone2_label.value = this.productCategory + ' ' + this.pricingCardLargeScreenContent.phone2_label.value;
                        }
                        break;
                    case this.pricingCalendarSmallScreenTopic.toLowerCase():
                        this.pricingCardSmallScreenContent = JSON.parse(JSON.stringify(element.contentNodes));
                        this.pricingCardSmallScreenContent.body.value = this.convertRichTextToHTML(this.pricingCardSmallScreenContent.body.value);
                        this.pricingCardSmallScreenContent.image.url = this.convertRichTextToHTML(this.pricingCardSmallScreenContent.image.url);
                        if (this.productCategory) {
                            this.pricingCardSmallScreenContent.phone_label.value = this.productCategory + ' ' + this.pricingCardSmallScreenContent.phone_label.value;
                            this.pricingCardSmallScreenContent.phone2_label.value = this.productCategory + ' ' + this.pricingCardSmallScreenContent.phone2_label.value;
                        }
                        break;
                }
            });
        });
        //console.log('This planDetailsAccordion : ', JSON.parse(JSON.stringify(this.planDetailsAccordion)));
        // console.log('This termChartsLargeScreenContentTopic : ', this.termsAndChartsLargeScreenAccordion);
    }

    convertRichTextToHTML(contentText) {
        contentText = String(contentText).replaceAll('&lt;', '<');
        contentText = contentText.replaceAll(/(&quot\;)/g, "\"");
        contentText = contentText.replaceAll('&gt;', '>');
        contentText = contentText.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
        return contentText;
    }


}
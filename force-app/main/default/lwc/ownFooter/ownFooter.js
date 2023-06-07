//============================================================================
// Title:    Honda Owners Experience - Footer
//
// Summary:  Footer logic at the bottom of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the footer component for all community pages.
//
//
// History:
// May 17, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { LightningElement, track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getGarageURL, ISGUEST, getProductContext, setOrigin, contextDetail } from 'c/ownDataUtils';
import FONT_AWESOME from '@salesforce/resourceUrl/FontAwesome';
import basePath from '@salesforce/community/basePath';
import addProduct from '@salesforce/apex/OwnGarageController.addProduct';
import getCustomMetadataTypes from '@salesforce/apex/OwnGarageController.getCustomMetadataTypes';
import FinanceSSOUrl from '@salesforce/label/c.FinanceSSOUrl';
import mygarageurl from '@salesforce/label/c.MyGarageURL';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

const BRANDS = [];
let brand = {};
brand['label'] = 'ACURA AUTOS';
brand['logo'] = (mygarageurl === '/' ? '' : mygarageurl) + '/resource/1643897587000/Owners/Logos/honda_acura_footer.svg';
brand['pages'] = [
    //DOE-4256 Start (Code commented for Release 1 - Details: Footer Page Few details hiding)

    { "label": "Find a Dealer", "url": "/find-a-dealer?brand=acura", "iconName": "" },
    { "label": "Recalls", "url": "/recall-search?brand=acura", "iconName": "" },
    { "label": "Warranty Information", "url": "/warranty-search?brand=acura", "iconName": "" },
    { "label": "FAQ", "url": "/help-center-acura", "iconName": "" },
    { "label": "Owner’s Manuals", "url": "/manuals-search?brand=acura", "iconName": "" },
    { "label": "Certified Collision Facilities", "url": "/acura-collision-repair?fb=ff", "iconName": "" },
    { "label": "AcuraLink", "url": "/acuralink-marketing", "iconName": "" },
    { "label": "HandsFreeLink", "url": "/acura-handsfreelink-compatibility-check?fb=true", "iconName": "" },
    { "label": "Connect via Bluetooth", "url": "/acura-bluetooth-compatibility-check?fb=true", "iconName": "" },
    { "label": "Radio & Navi Code", "url": "/radio-nav-code?brand=Acura", "iconName": "" },
    { "label": "News & Offers", "url": "https://www.acura.com/tools/current-luxury-car-suv-offers-leasing", "iconName": "", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size" },
    { "label": "Finance", "url": "https://www.acurafinancialservices.com/", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Parts & Accessories", "url": "/parts-and-accessories?brand=acura", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Contact Us", "url": "/help-acura", "iconName": "" } //DOE-5028 Moved Contact Us to Last
    //DOE-4256 End (Code commented for Release 1 - Details: Footer Page Few details hiding)
];
BRANDS.push(brand);

brand = {};
brand['label'] = 'HONDA AUTOS';
brand['logo'] = (mygarageurl === '/' ? '' : mygarageurl) + '/resource/1643897587000/Owners/Logos/honda_autos_footer.svg';
brand['pages'] = [
    //DOE-4256 Start (Code commented for Release 1 - Details: Footer Page Few details hiding)

    { "label": "Find a Dealer", "url": "/find-a-dealer?brand=honda", "iconName": "" },
    { "label": "Recalls", "url": "/recall-search?brand=honda", "iconName": "" },
    { "label": "Warranty Information", "url": "/warranty-search?brand=honda", "iconName": "" },
    { "label": "FAQ", "url": "/help-center-honda", "iconName": "" },
    { "label": "Owner’s Manuals", "url": "/manuals-search?brand=honda", "iconName": "" },
    { "label": "Certified Collision Facilities", "url": "/honda-collision-repair?fb=ff", "iconName": "" },
    { "label": "HondaLink", "url": "/hondalink-marketing", "iconName": "" },
    { "label": "HandsFreeLink", "url": "/honda-handsfreelink-compatibility-check?fb=true", "iconName": "" },
    { "label": "Connect via Bluetooth", "url": "/honda-bluetooth-compatibility-check?fb=true", "iconName": "" },
    { "label": "Radio & Navi Code", "url": "/radio-nav-code?brand=Honda", "iconName": "" },
    { "label": "News & Offers", "url": "https://automobiles.honda.com/tools/current-offers", "iconName": "", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size" },
    { "label": "Finance", "url": "https://www.hondafinancialservices.com/", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Parts & Accessories", "url": "/parts-and-accessories?brand=honda", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Contact Us", "url": "/help-honda", "iconName": "" } //DOE-5028 Moved Contact Us to Last
    //DOE-4256 End (Code commented for Release 1 - Details: Footer Page Few details hiding)
];
BRANDS.push(brand);

brand = {};
brand['label'] = 'HONDA POWERSPORTS';
brand['logo'] = (mygarageurl === '/' ? '' : mygarageurl) + '/resource/1643897587000/Owners/Logos/honda_powersports_footer.svg';
brand['pages'] = [
    //DOE-4256 Start (Code commented for Release 1 - Details: Footer Page Few details hiding)

    { "label": "Find a Dealer", "url": "/find-a-dealer?brand=powersports", "iconName": "" },
    { "label": "Recalls", "url": "/recall-search?brand=powersports", "iconName": "" },
    { "label": "Warranty Information", "url": "/warranty-search?brand=powersports", "iconName": "" },
    { "label": "FAQ", "url": "/help-center-powersports", "iconName": "" },
    { "label": "Owner’s Manuals", "url": "/manuals-search?brand=powersports", "iconName": "" },
    // { "label": "Trip Planner", "url": "/helloworld", "iconName": "" },
    { "label": "News & Offers", "url": "https://powersports.honda.com/offers", "iconName": "", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size" },
    { "label": "Finance", "url": "https://www.hondafinancialservices.com/", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Parts & Accessories", "url": "/parts-and-accessories?brand=powersports", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Contact Us", "url": "/help-powersports", "iconName": "" } //DOE-5028 Moved Contact Us to Last
    //DOE-4256 End (Code commented for Release 1 - Details: Footer Page Few details hiding)

];
BRANDS.push(brand);

brand = {};
brand['label'] = 'HONDA POWER EQUIPMENT';
brand['logo'] = (mygarageurl === '/' ? '' : mygarageurl) + '/resource/1643897587000/Owners/Logos/honda_equipment_footer.svg';
brand['pages'] = [
    //DOE-4256 Start (Code commented for Release 1 - Details: Footer Page Few details hiding)

    { "label": "Find a Dealer", "url": "/find-a-dealer?brand=powerequipment", "iconName": "" },
    { "label": "Recalls", "url": "/recall-search?brand=powerequipment", "iconName": "" },
    { "label": "Warranty Information", "url": "/warranty-search?brand=powerequipment", "iconName": "" },
    { "label": "FAQ", "url": "/help-center-powerequipment", "iconName": "" },
    { "label": "Owner’s Manuals", "url": "/manuals-search?brand=powerequipment", "iconName": "" },
    { "label": "News & Offers", "url": "https://powerequipment.honda.com/promotions", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Finance", "url": "https://powerequipment.honda.com/finance", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Parts & Accessories", "url": "/parts-and-accessories?brand=powerequipment", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Contact Us", "url": "/help-powerequipment", "iconName": "" } //DOE-5028 Moved Contact Us to Last

    //DOE-4256 End (Code commented for Release 1 - Details: Footer Page Few details hiding)
];
BRANDS.push(brand);

brand = {};
brand['label'] = 'HONDA MARINE';
brand['logo'] = (mygarageurl === '/' ? '' : mygarageurl) + '/resource/1643897587000/Owners/Logos/honda_marine_footer.svg';
brand['pages'] = [
    // DOE-4256 Start (Code commented for Release 1 - Details: Footer Page Few details hiding)

    { "label": "Find a Dealer", "url": "/find-a-dealer?brand=marine", "iconName": "" },
    { "label": "Recalls", "url": "/recall-search?brand=marine", "iconName": "" },
    { "label": "Warranty Information", "url": "/warranty-search?brand=marine", "iconName": "" },
    { "label": "FAQ", "url": "/help-center-marine", "iconName": "" },
    { "label": "Owner’s Manuals", "url": "/manuals-search?brand=marine", "iconName": "" },
    { "label": "News & Offers", "url": "https://marine.honda.com/company/news", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Finance", "url": "https://marine.honda.com/finance", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Parts & Accessories", "url": "/parts-and-accessories?brand=marine", "class": "fas fa-arrow-right fa-sm vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "Contact Us", "url": "/help-marine", "iconName": "" } //DOE-5028 Moved Contact Us to Last
    //DOE-4256 End (Code commented for Release 1 - Details: Footer Page Few details hiding)
];
BRANDS.push(brand);

const EXPLOREMORES = [];
let exploremore = {};
exploremore['label'] = 'Explore More from Honda';
exploremore['pages'] = [
    { "label": "ABOUT HONDA", "url": "https://global.honda/about/", "class": "fas fa-arrow-right fa-lg vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "MEDIA NEWSROOM", "url": "https://hondanews.com/en-US", "class": "fas fa-arrow-right fa-lg vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "AWARDS & RECOGNITION", "url": "https://hondanews.com/en-US/honda-automobiles/channels/honda-awards-recognition", "class": "fas fa-arrow-right fa-lg vector-icon-left arrow-icon-size", "iconName": "" },
    { "label": "INNOVATION", "url": "https://global.honda/innovation/", "class": "fas fa-arrow-right fa-lg vector-icon-left arrow-icon-size", "iconName": "" }
];
EXPLOREMORES.push(exploremore);

const FOLLOWUSS = [];
let followus = {};
followus['label'] = 'Follow Us';
followus['pages'] = [
    { "label": "Youtube", "url": "https://www.youtube.com/honda", class: "fab fa-youtube fa-2x social-icon", "iconName": "" },
    { "label": "Instagram", "url": "https://www.instagram.com/honda/", class: "fab fa-instagram fa-2x social-icon", "iconName": "" },
    { "label": "Facebook", "url": "https://www.facebook.com/Honda/", class: "fab fa-facebook fa-2x social-icon", "iconName": "" },
    { "label": "Twitter", "url": "https://twitter.com/honda", class: "fab fa-twitter fa-2x social-icon", "iconName": "" },
    { "label": "LinkedIn", "url": "https://www.linkedin.com/company/american-honda-motor-company-inc-", class: "fab fa-linkedin fa-2x social-icon", "iconName": "" }
];
FOLLOWUSS.push(followus);
const PRIVACYOPTIONICON = (mygarageurl === '/' ? '' : mygarageurl) + "/resource/MyGarage/ahmicons/privacyoptions.png";
const LINKS = [
    { "label": "Vehicle Data Privacy", "url": "https://www.honda.com/privacy/connected-product-privacy-notice", "iconName": "", "isLast": false, "adobeActionLabel": "COMPLIANCE_CLICK" },
    { "label": "Site Terms", "url": "https://www.honda.com/privacy/terms-and-conditions", "iconName": "", "isLast": false, "adobeActionLabel": "COMPLIANCE_CLICK" },
    { "label": "SMS Terms & Conditions", "url": "https://www.honda.com/privacy/sms-terms", "iconName": "", "isLast": false, "adobeActionLabel": "COMPLIANCE_CLICK" },//DOE-4934
    { "label": "Privacy Notice", "url": "https://www.honda.com/privacy/privacy-notice", "iconName": "", "isLast": false, "adobeActionLabel": "COMPLIANCE_CLICK" },
    { "label": "Your Privacy Choices", "url": "https://www.honda.com/privacy/your-privacy-choices", "iconName": "", "icon": PRIVACYOPTIONICON, "class": "slds-p-right_xx-small slds-p-bottom_xx-small slds-text-link--reset", "isLast": false, "adobeActionLabel": "COMPLIANCE_CLICK" },
    { "label": "Prop 65 Info", "url": "https://www.honda.com/-/media/Honda-Homepage/PDF/Proposition-65-Consumer-Website-Statement-072518.pdf", "iconName": "", "isLast": true, "adobeActionLabel": "COMPLIANCE_CLICK" },//DOE-4256 (Changed isLast to 'true' to hide "|" )
    //DOE-4256 Start (Code commented for Release 1 - Details: Footer Page Few details hiding)
    //{ "label": "Site Map", "url": "https://owners.honda.com/", "iconName": "", "isLast": true } Recommented out as per Marthas request June 2
    // DOE-4256 End (Code commented for Release 1 - Details: Footer Page Few details hiding 

];

export default class ownFooter extends OwnBaseElement {
    @track brands = BRANDS;
    @track registerYourProduct = { "label": "REGISTER YOUR PRODUCT", "content": "To receive personalized updates, news and offers.", "url": "", "iconName": "" }
    @track exploremores = EXPLOREMORES;
    @track followuss = FOLLOWUSS;
    @track links = LINKS;
    @track privacyPolicyURL = 'https://www.honda.com/privacy/privacy-notice';//basePath + "/vehicle-data-privacy-find-vehicle";
    @track context;
    @track marketplace_urls;
    currentYear = new Date().getFullYear();
    @track privacyOptionIcon = PRIVACYOPTIONICON;
    connectedCallback() {
        //console.log('ownFooter connectedCallback');
        // console.log('basePath: ',basePath + '/vehicle-data-privacy-find-vehicle'); 
        loadStyle(this, FONT_AWESOME + '/css/all.css')
            .then(() => { })
            .catch(error => { 
                //console.log(error); 
            });

        if (sessionStorage.getItem('originAddProduct') && !ISGUEST) {
            this.handleOriginAddProduct();
        }
        if (sessionStorage.getItem('originAddProduct') && ISGUEST) {
            //console.log('Removing Item on backtrack')
            sessionStorage.removeItem('originAddProduct');
        }

        if (sessionStorage.getItem('isPdpPage')) {
            sessionStorage.removeItem('isPdpPage');
        }
        if (document.location.pathname.includes('garage-honda') || document.location.pathname.includes('garage-acura')) {
            sessionStorage.setItem('isPdpPage', 'true');
        } else {
            sessionStorage.setItem('isPdpPage', 'false');
        }
        if (sessionStorage.getItem('removeProductRedirect')) {
            let currentPage = window.location.href;
            if (currentPage.includes('/in-progress')) {
                let redirectUrl = sessionStorage.getItem('removeProductRedirect');
                sessionStorage.removeItem('removeProductRedirect');
                window.open(redirectUrl, "_Self");
            }
            else {
                sessionStorage.removeItem('removeProductRedirect');
            }
        }

        this.initialize();
    }

    initialize = async () => {
        // console.log('brandLabel1  :-  ',brandLabel);
        this.marketplace_urls = await getCustomMetadataTypes();
        let origin = localStorage.getItem('origin');
        if (origin == 'ProductChooser') {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        if (this.context && this.context.product) {
            contextDetail();
        }
    }

    // Method to handle redirect to PDP when guest user attempts to add product
    handleOriginAddProduct() {
        let garageProducts = JSON.parse(localStorage.getItem('garage'));
        const product = garageProducts.products[0];
        setOrigin(' ');
        product.image = product.vin && product.vin != '-' ? product.image : '';
        //console.log(JSON.stringify(product));
        addProduct({
            product: product
        })
            .then(result => {
                if (result.isSuccess && (product.division === 'Acura' || product.division === 'Honda' || product.division === 'Motorcycle/Powersports' || product.division === 'Powersports')) {
                    sessionStorage.setItem('firstItemIndex', 0);
                    setOrigin(' ');
                    sessionStorage.removeItem('originAddProduct');
                    //console.log('Footer: navigate on add product');
                    window.open('.' + getGarageURL(product.division), "_Self");
                    //  this.navigate(getGarageURL(product.division), {});
                } else if (result.isSuccess && (product.division === 'Powerequipment' || product.division === 'Power Equipment' || product.division === 'Marine')) {
                    sessionStorage.setItem('firstItemIndex', 0);
                    setOrigin(' ');
                    sessionStorage.removeItem('originAddProduct');
                    //console.log('Footer: navigate on add product - Powerequipment/Marine');
                    sessionStorage.setItem('addingPEMProduct', true);
                    window.open('.' + '/product-registration', "_Self");
                } else if (!result.isSuccess && result.message) {
                    //console.log('error in result ', result);
                    this.showToast_error(result.message);

                    sessionStorage.removeItem('originAddProduct');
                    window.open('.', "_Self");
                    //  this.navigate('/', {});
                } else {
                    this.showToast_error('An error has occurred.');
                }
            })
            .catch(error => {
                //console.log('error: ' + JSON.stringify(error));
                if (error.body.isUserDefinedException) {
                    this.showToast_error(error.body.message);
                } else {
                    this.showToast_error('An error has occurred.');
                }
            });
        sessionStorage.removeItem('originAddProduct');

        // const origin = sessionStorage.getItem('originAddProduct');
        // console.log('in handleOriginAddProduct', origin);
        // this.navigate(getGarageURL(origin), {});
    }

    handleClick(event) {
        let url = event.target.dataset.url === undefined ? event.target.parentElement.dataset.url : event.target.dataset.url;
        //console.log('@adobeCCPA', event.target.parentElement.dataset.adobeActionLabel, event.target.parentElement.dataset.linkLabel)
        if (event.target.parentElement.dataset.adobeActionLabel !== undefined) {//ccpa
            let page = {
                remove_sections: true
            };
            let eventMetadata = {
                action_type: 'footer links',
                action_category: 'global footer privacy',
                action_label: event.target.parentElement.dataset.linkLabel
            };
            let message = { eventType: DATALAYER_EVENT_TYPE[event.target.parentElement.dataset.adobeActionLabel], page: page, eventMetadata: eventMetadata };
            this.publishToChannel(message);
        }
        // else if (event.target.parentElement.dataset.pageLabel !== undefined && event.target.parentElement.dataset.label !== undefined) {//brand links
        //     let eventMetadata = {
        //         action_type: 'link',
        //         action_category: 'footer',
        //         action_label: event.target.parentElement.dataset.label + ':' + event.target.parentElement.dataset.pageLabel
        //     };
        //     let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        //     this.publishToChannel(message);
        //     await this.sleep(2000);
        // }
        // else if (event.target.parentElement.dataset.linkLabel !== undefined && event.target.parentElement.dataset.adobeActionLabel === undefined) {//all other links
        //     let eventMetadata = {
        //         action_type: 'link',
        //         action_category: 'footer',
        //         action_label: event.target.parentElement.dataset.linkLabel
        //     };
        //     let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        //     this.publishToChannel(message);
        // }
        if (event.target.dataset.page == 'Finance' && !ISGUEST) {
            if (!(event.target.dataset.label.includes('MARINE') || event.target.dataset.label.includes('EQUIPMENT'))) {
                url = FinanceSSOUrl;
            }
        }
        if (sessionStorage.getItem('frompageformarketingpage') == 'pdp' && (url == '/acuralink-marketing' || url == '/hondalink-marketing')) {
            sessionStorage.removeItem('frompageformarketingpage');
        }
        if (sessionStorage.getItem('frompage')) {
            sessionStorage.removeItem('frompage');
        }
        if (url.includes('/radio-nav-code')) {
            sessionStorage.setItem('isFromFooter', true);
            //console.log('isFromFooter-', sessionStorage.getItem('isFromFooter'));
        }

        if (url.includes('/find-a-dealer')) {
            //console.log(' Find a Dealer ');

            if (url.includes('honda'))
                sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: 'Honda', divisionId: 'A' }));
            else if (url.includes('acura'))
                sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: 'Acura', divisionId: 'B' }));
            else if (url.includes('powersports'))
                sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: 'Powersports', divisionId: 'M' }));
            else if (url.includes('powerequipment'))
                sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: "Power Equipment", divisionId: 'P' }));
            else if (url.includes('marine'))
                sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: "Marine", divisionId: 'P' }));

            //console.log(sessionStorage.getItem('findDealerContext'));
            //     this.sleep(2000);
            this.navigate(url, {});
        } else if (url.includes('/parts-and-accessories')) {
            //console.log(' PARTS AND ACCESSORIES ');

            let brandName;
            if (url.includes('honda'))
                brandName = 'Honda';
            else if (url.includes('acura'))
                brandName = 'Acura';
            else if (url.includes('powersports'))
                brandName = 'Powersports';
            else if (url.includes('powerequipment'))
                brandName = 'Power_Equipment';
            else if (url.includes('marine'))
                brandName = 'Marine';

            let navigationDetails = this.marketplace_urls.find(element => element.DeveloperName == brandName);

            //console.log('navigationDetails :: ', navigationDetails);
            if (navigationDetails) {
                if (ISGUEST) {
                    this.navigate(navigationDetails.Parts_Logged_Out_URL__c, {});
                } else {
                    this.navigate(navigationDetails.Parts_Logged_In_URL__c, {});
                }
            }

        } else {
            this.navigate(url, {});
        }
    }
    handleCookiePolicyClick(event) {
        let page = {
            remove_sections: true
        };
        let eventMetadata = {
            action_type: 'footer links',
            action_category: 'global footer privacy',
            action_label: 'cookie policy'
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.COMPLIANCE_CLICK, page: page, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        let url = 'https://www.honda.com/privacy/privacy-notice#cookies';
        this.navigate(url, {});
    }
    handleWorldHondaClick(event) {
        let url = 'https://world.honda.com/';
        // let eventMetadata = {
        //     action_type: 'link',
        //     action_category: 'footer',
        //     action_label: 'world.honda.com'
        // };
        // let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        // this.publishToChannel(message);
        this.navigate(url, {});
    }
    // sleep(ms) {
    //     return new Promise(resolve => setTimeout(resolve, ms));
    // }
}
//======================================================================================================
// Title: Multi-Hero LWC for Honda Owners Community
//
// Summary: This LWC provides a configurable Hero image, and configurable Login Buttons
//
// Updated:
// Apr 14, 2021 Jim Kohs (Appirio) Original Author
// May 20, 2021 Jim Kohs (Appirio) cleanup
// May 27, 2021 Jim Kohs (Appirio) added configurable hero images
// Feb 03, 2022 Ravindra Ravindra Implemented CMS Fetched Home Page Banner Images
//====================================================================================================== -->
// import { LightningElement, api, wire, track } from 'lwc';
import { api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getCMSContent } from 'c/ownCMSContent'; // Ravindra Ravindra (Wipro)
import { ISGUEST, getMyProducts } from 'c/ownDataUtils';
import Id from '@salesforce/user/Id';
import FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import {
    getRecord,
    getFieldValue
} from 'lightning/uiRecordApi';
import {
    brandDataCategoryMap
} from 'c/ownDataUtils';

import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
const fields = [FIRST_NAME_FIELD];
const H1LINE1_HOME = "Welcome to MyGarage";
const H2LINE1_HOME = "Sign up today to get helpful tools and resources.";//updated text for DOE-5063

const H1LINE1_HONDA = "Tell us about your Honda Auto";
const H2LINE1_HONDA = "";

const H1LINE1_ACURA = "Tell us about your Acura Auto";
const H2LINE1_ACURA = "";

const H1LINE1_PS = "Tell us about your Powersports Vehicle";
const H2LINE1_PS = "";

const H1LINE1_PE = "Tell us about your Power Equipment";
const H2LINE1_PE = "";

const H1LINE1_MARINE = "Tell us about your Honda Marine Product";
const H2LINE1_MARINE = "";

const classLayoutItem1 = 'slds-col slds-size_1-of-1 own-hero-content own-hero-content1';
const classLayoutItem2 = 'slds-col slds-size_1-of-1 own-hero-image-container own-hero-image-container1';

const BREADCRUMBCLASS = 'bread-crumb-div';
// Ravindra Ravindra (Wipro)
const oneBannerImageStyle = 'bannerOne';
const twoBannerImageStyle = 'bannerTwo';
const threeBannerImageStyle = 'bannerThree';
const fourBannerImageStyle = 'bannerFour';
const fiveBannerImageStyle = 'bannerFive';

export default class ownHero extends OwnBaseElement {
    userId = Id;
    isGuest = ISGUEST;
    isLoggenInHomePage = false;
    isHomePage = false;
    isLogoShown = false;
    isVImage = false;
    modelName = '';
    @track greetingText = { text: 'Welcome,', sign: '!' };
    @track hasProducts;
    @track descriptionClass = 'own-description';
    ownBannerStyle = fiveBannerImageStyle;
    @track homePageBannerImages = []; // Ravindra Ravindra (Wipro)
    @api homePageBannerImagesTopic; // Ravindra Ravindra (Wipro)
    hideImageOnMobileViewClass_helpCenter = '';
    breadCrumbsDivClass = BREADCRUMBCLASS;
    @track layoutItem1Cls = classLayoutItem1;
    @track layoutItem2Cls = classLayoutItem2;
    @track heroHome = this.ownerResource() + '/images/HeroHome.png';
    @track heroHonda = this.ownerResource() + '/images/HeroHonda.png';
    @track heroAcura = this.ownerResource() + '/images/HeroAcura.png';
    @track heroPS = this.ownerResource() + '/images/HeroPS.png';
    @track heroPE = this.ownerResource() + '/images/HeroPE.png';
    @track heroMarine = this.ownerResource() + '/images/HeroMarine.png';
    @track helpCenterAcura = this.ownerResource() + '/images/HelpCenterAcura.png';
    @track helpCenterHonda = this.ownerResource() + '/images/HelpCenterHonda.png';
    @track helpCenterPs = this.ownerResource() + '/images/HelpCenterPS.png';
    @track helpCenterPe = this.ownerResource() + '/images/HelpCenterPE.png';
    @track helpCenterMarine = this.ownerResource() + '/images/HelpCenterMarine.png';
    @track helpCenterAcuraLogo = this.ownerResource() + '/images/Acura-logo-white.svg';
    @track helpCenterHondaLogo = this.ownerResource() + '/images/Honda-logo-white.svg';
    @track helpCenterPeLogo = this.ownerResource() + '/images/PE-logo-white.svg';
    @track helpCenterPsLogo = this.ownerResource() + '/images/PS-logo-white.svg';
    @track helpCenterMarineLogo = this.ownerResource() + '/images/Marine-logo-white.svg';
    @track searchTerm = '';
    @track heroSetterValue; //DOE-4194 Ravindra Ravindra(wipro)
    url;

    @api safetyAlertsTopic;
    @api productAlertsTopic;

    @track h1Line1 = "default1";
    @track h1Line2 = null;
    @track h2Line1 = "default2";

    @track loginUrl;
    @track signUpUrl;

    _hero = this.heroHome;
    brandLogo = this.helpCenterHondaLogo;
    @api
    get hero() {
        return this._hero;
    };

    get heroWrapperClass() {
        //console.log('ownHero:: ' + this.page === 'Find Product' ? 'own-hero-wrapper-align-right' : 'own-hero-wrapper');
        return (this.page === 'Find Product' ? 'own-hero-wrapper-align-right' : 'own-hero-wrapper');
    }

    //Ravindra Ravindra (Wipro)
    get showHomePageImage() {
        return (this.isHomePage && this.page === 'Home');
    }

    set hero(v) {
        //DOE-4194 Ravindra Ravindra(wipro)
        this.heroSetterValue = v;
        //console.log('v1 ' + v);
        let vHelper = v;
        try {
            if (vHelper == String(this.helpCenterAcura)) {
                vHelper = 'Acura Auto';
                this.isVImage = true;
            }
            if (vHelper == String(this.helpCenterHonda)) {
                vHelper = 'Honda Auto';
                this.isVImage = true;
            }
            if (vHelper == String(this.helpCenterPs)) {
                vHelper = 'Powersports';
                this.isVImage = true;
            }
            if (vHelper == String(this.helpCenterPe)) {
                vHelper = 'Power Equipment';
                this.isVImage = true;
            }
            if (vHelper == String(this.helpCenterMarine)) {
                vHelper = 'Marine';
                this.isVImage = true;
            }
        } catch (error) {
            //console.error(error);
        }
        //console.log('vHelper ' + vHelper);



        this.breadCrumbsDivClass = this.page && this.page == 'Find Product' ? 'bread-crumb-div' : 'hidden-bread-crumb';
        this.layoutItem1Cls = this.page && this.page == 'Find Product' ? 'slds-col slds-size_1-of-1 own-hero-content own-hero-content2' : this.layoutItem1Cls;
        this.layoutItem2Cls = this.page && this.page == 'Find Product' ? 'slds-col slds-size_1-of-1 own-hero-image-container own-hero-image-container2' : this.layoutItem2Cls;
        this.isLoggenInHomePage = this.isGuest == false && v === 'Home' ? true : false;
        this.isHomePage = (v === 'Home') ? true : false;
        //console.log('HERO: ' + 'V: ' + JSON.stringify(v) + ' isHomePage: ' + this.isHomePage);
        this._hero =
            (v === 'Home' ? this.heroHome :
                v === 'Honda Auto' ? this.heroHonda :
                    v === 'Acura Auto' ? this.heroAcura :
                        v === 'Powersports' ? this.heroPS :
                            v === 'Power Equipment' ? this.heroPE :
                                v === 'Marine' ? this.heroMarine :
                                    vHelper === 'Honda Auto' ? this.heroHonda :
                                        vHelper === 'Acura Auto' ? this.heroAcura :
                                            vHelper === 'Powersports' ? this.heroPS :
                                                vHelper === 'Power Equipment' ? this.heroPE :
                                                    vHelper === 'Marine' ? this.heroMarine :
                                                        this.heroHome);

        this.h1Line1 =
            (v === 'Home' ? H1LINE1_HOME :
                v === 'Honda Auto' ? H1LINE1_HONDA :
                    v === 'Acura Auto' ? H1LINE1_ACURA :
                        v === 'Powersports' ? H1LINE1_PS :
                            v === 'Power Equipment' ? H1LINE1_PE :
                                v === 'Marine' ? H1LINE1_MARINE :
                                    vHelper === 'Honda Auto' ? H1LINE1_HONDA :
                                        vHelper === 'Acura Auto' ? H1LINE1_ACURA :
                                            vHelper === 'Powersports' ? H1LINE1_PS :
                                                vHelper === 'Power Equipment' ? H1LINE1_PE :
                                                    vHelper === 'Marine' ? H1LINE1_MARINE :
                                                        H1LINE1_HOME);

        this.h2Line1 =
            (v === 'Home' ? 'We noticed you don’t have any products in My Garage yet. Adding your product is easy — start by telling us about what type of product you own.' :
                v === 'Honda Auto' ? H2LINE1_HONDA :
                    v === 'Acura Auto' ? H2LINE1_ACURA :
                        v === 'Powersports' ? H2LINE1_PS :
                            v === 'Power Equipment' ? H2LINE1_PE :
                                v === 'Marine' ? H2LINE1_MARINE :
                                    vHelper === 'Honda Auto' ? H2LINE1_HONDA :
                                        vHelper === 'Acura Auto' ? H2LINE1_ACURA :
                                            vHelper === 'Powersports' ? H2LINE1_PS :
                                                vHelper === 'Power Equipment' ? H2LINE1_PE :
                                                    vHelper === 'Marine' ? H2LINE1_MARINE :
                                                        H2LINE1_HOME);

        this.modelName = v;
        if (this.isVImage == true) this.modelName = this.isVImage;


        if (this.page && this.page == 'Help Center') {
            this.isHomePage = true;
            this.isGuest = false;
            this.hideImageOnMobileViewClass_helpCenter = 'hide-image-on-mobile-view';
            this.isLogoShown = true;
            if (v === 'Acura Auto' || vHelper === 'Acura Auto') {
                this.h1Line1 = 'Acura';
                this.h1Line2 = 'Help Center';
                this._hero = this.helpCenterAcura;
                this.brandLogo = this.helpCenterAcuraLogo;
            }
            if (v === 'Honda Auto' || vHelper === 'Honda Auto') {
                this.h1Line1 = 'Honda';
                this.h1Line2 = 'Help Center';
                this._hero = this.helpCenterHonda;
                this.brandLogo = this.helpCenterHondaLogo;
            }
            if (v === 'Powersports' || vHelper === 'Powersports') {
                this.h1Line1 = 'Honda Powersports Help Center';
                this._hero = this.helpCenterPs;
                this.brandLogo = this.helpCenterPsLogo;
            }
            if (v === 'Power Equipment' || vHelper === 'Power Equipment') {
                this.h1Line1 = 'Honda Power Equipment Help Center';
                this._hero = this.helpCenterPe;
                this.brandLogo = this.helpCenterPeLogo;
            }
            if (v === 'Marine' || vHelper === 'Marine') {
                this.h1Line1 = 'Honda Marine Help Center';
                this._hero = this.helpCenterMarine;
                this.brandLogo = this.helpCenterMarineLogo;
            }
        }
        this.h2Line1 = this.isGuest && this.isHomePage ? 'Sign up today to get helpful tools and resources.' : this.h2Line1;//updated text for DOE-5063

    }

    @api showLoginButtons = false;
    @api showBackLink = false;
    @api showSearchBox = false;
    @api page;
    @track category;
    @api categoryLabel;
    @track brand;

    @wire(getRecord, {
        recordId: '$userId',
        fields
    })
    user;

    get firstName() {
        return getFieldValue(this.user.data, FIRST_NAME_FIELD);
    }

    renderedCallback() {
        if (this.hasProducts) {
            this.h2Line1 = 'Add Another Honda Product to Your Garage';
            this.descriptionClass = 'own-title slds-m-bottom_large';
        }
    }

    async connectedCallback() {
        if (!this.isGuest) {
            let myProducts = await getMyProducts('');
            this.hasProducts = this.page == 'Home' && myProducts && myProducts.products && myProducts.products.length > 0 ? true : false;
            this.greetingText = this.hasProducts ? { text: 'Hi', sign: ',' } : this.greetingText;
        }
        this.getCIAMdetails();

        if (this.categoryLabel && this.categoryLabel != 'None') {
            this.category = this.categoryLabel.split(' ').join('');
            this.brand = {
                label: this.categoryLabel,
                value: this.category,
                url: brandDataCategoryMap.get(this.category).url,
                type: 'brand',
                brandLabel: this.brandLabel,
                brandName: brandDataCategoryMap.get(this.category).name
            };
            //this.brand = { label: this.categoryLabel, value: this.category, type: 'brand', brandLabel: this.brandLabel, brandName: brandDataCategoryMap.get(this.category).name }; 
        }

        // Store the PageReference in a variable to use in handleClick.
        // This is a plain Javascript object that conforms to the
        // PageReference type by including 'type' and 'attributes' properties.
        // The 'state' property is optional.

        /*  this.loginPageRef = {
             type: 'standard__webPage',
             attributes: { url: 'login.honda.com' }
         };
         this[NavigationMixin.GenerateUrl](this.loginPageRef)
             .then(url => { this.url = url; } ); */

        //DOE-4194 Ravindra Ravindra(wipro)
        this.hero = this.heroSetterValue;

        // Ravindra Ravindra (Wipro)
        if (this.homePageBannerImagesTopic) {
            this.getImages(await getCMSContent([this.homePageBannerImagesTopic]));
        }
    }

    getCIAMdetails = async () => {
        getCIAMConfig().then(result => {
            this.loginUrl = result.Ciam_Login_Url__c;
            this.signUpUrl = result.Ciam_SignUp_Url__c;
        })

    }

    // Ravindra Ravindra (Wipro)
    getImages(content) {
        let Images = [];
        let urlString = window.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf("/s"));
        content = JSON.parse(JSON.stringify(content));
        content = content.sort(function (a, b) { return a.title.localeCompare(b.title) });
        content.forEach(img => {
            //console.log('Imag ', img.contentNodes);
            Images.push({
                title: img.contentNodes.title.value,
                url: baseURL + img.contentNodes.source.url,
            });
        });
        //console.log('imagesSize ', Images.length);
        if (Images.length === 4) {
            this.ownBannerStyle = fourBannerImageStyle;
        } else if (Images.length === 3) {
            this.ownBannerStyle = threeBannerImageStyle;
        } else if (Images.length === 2) {
            this.ownBannerStyle = twoBannerImageStyle;
        } else if (Images.length === 1) {
            this.ownBannerStyle = oneBannerImageStyle;
        }
        this.homePageBannerImages = Images;
    }


    handleClick(event) {
        var currentLocation = window.location;
        //console.log('Current Location -', currentLocation.href);
        sessionStorage.setItem("RelayState", currentLocation.href);

        let button = event.target.getAttribute('data-id');
        let url = '';
        let eventMetadata = {
            action_type: 'button',
            action_category: 'hero banner'
        };
        if (this.loginUrl != undefined && this.signUpUrl != undefined) {
            if (button === 'Sign_Up') {
                eventMetadata.action_label = 'sign up';
                url = this.signUpUrl + `&RelayState=${window.location.href}`;
            } else if (button === 'Log_In') {
                eventMetadata.action_label = 'log in';
                url = this.loginUrl + `&RelayState=${window.location.href}`;
            }
            sessionStorage.setItem('referrer', document.location.href);
            let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
            this.publishToChannel(message);
            sessionStorage.setItem("isUserLogin", true);
            window.open(url, '_self');
        }

    }

    handleGetStarted() {
        this.navigate('/', {});
    }
}
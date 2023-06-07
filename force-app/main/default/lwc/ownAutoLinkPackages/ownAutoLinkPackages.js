import { LightningElement, track, wire, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys, ISGUEST, getProductContext } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
import getMyVehicleAndMyProfile from '@salesforce/apex/OwnAPIController.getMyVehicleAndMyProfile';
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import getPackages from '@salesforce/apex/OwnAPIController.getPackages';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnAutoLinkPackages extends OwnBaseElement {

    compatibilityCheckUrl;
    packageSectionIcon = this.myGarageResource() + '/images/package_icon.png';
    loactionIcon = this.myGarageResource() + '/images/location.png';
    popupAppStoreIcon = this.myGarageResource() + '/images/appstoreicon.png';
    popupPlayStoreIcon = this.myGarageResource() + '/images/playstoreicon.png';

    @track isGuest;
    @api contentId1;
    @api contentId2;
    @api contentId3;
    @api contentId4;
    @api contentId5;
    @api contentId6;
    @api contentId7;
    @api contentId8;
    @api contentId9;
    @api brand;
    @api playStoreURL;
    @api appStoreURL;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track packageContent;
    @track packs;
    //@track packages = ['Link', 'Security', 'Remote', 'Concierge'];
    @track heading1;
    @track heading2;
    @track heading3;
    @track heading4;
    @track heading5;
    @track btnLabel1;
    @track btnLabel2;
    @track appStoreIcon;
    @track playStoreIcon;
    @track compatibilityResultUrl;
    @track packagesList = [];
    @track context;
    @track localContext;
    loginUrl;
    @track showPopup = false;
    @api counter = 0;

    get popupText() {
        if (this.brand.toLowerCase() == 'honda') {
            return 'DOWNLOAD THE HONDALINK APP AND PAIR WITH YOUR HONDA TO START USING THESE FEATURES TODAY';
        } else {
            return 'DOWNLOAD THE ACURALINK APP AND PAIR WITH YOUR ACURA TO START USING THESE FEATURES TODAY';
        }
    }


    connectedCallback() {
        this.subscribeToChannel((message) => {
            this.handleMessage(message);
        });

        this.isGuest = ISGUEST;
        this.getCIAMdetails();
        this.initializePackages();
        this.initializePageDetails();
        if (this.brand == 'Honda') {
            this.compatibilityCheckUrl = '/hondalink-product-compatibility';
        } else {
            this.compatibilityCheckUrl = '/acuralink-product-compatibility';
        }
    }

    renderedCallback() {
        try {
            console.log("NATIVE JS P Test");
            if (this.counter == 0) {
               // console.log("NATIVE JS P Inside" + this.counter);
                this.counter = this.counter + 1;
                //  setTimeout(() => {
                let richTextElements = this.template.querySelectorAll("lightning-formatted-rich-text");
               // console.log('NATIVE JS PP ' + richTextElements.length);
                if (richTextElements.length < 4) {
                    this.counter = 0;
                } else {
                    richTextElements.forEach(element => {
                       // console.log("NATIVE JS P" + element);
                        element.addEventListener("click", (e) => {
                            let eventMetadata = {
                                action_type: 'image',
                                action_category: 'body',
                                action_label: document.location.pathname.includes('acura') ? 'download acuralink app' : 'download hondalink app'
                            };
                            let message = this.buildAdobeMessage('https://app-download.com', eventMetadata);
                            // let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
                            this.publishToChannel(message);
                            //console.log("NATIVE JS P" + e);
                        }, false);
                    });
                }

                // }, 3000);
            }
        } catch (ex) {
           // console.log("NATIVE JS P" + ex);
        }
    }
    handleMessage(message) {
        //console.log('message:', message);
        if (message.packagename) {

            let target = this.template.querySelector(`[data-id="${message.packagename}"]`);
            target.scrollIntoView();
        }
    }

    initializePackages = async () => {
        this.context = this.isGuest ? await getProductContext('', true) : await getProductContext('', false);
        this.localContext = getProductContext('', true);
        this.getMyVehicleAndMyProfile();
        //console.log('packagesList', this.packagesList);

        this.contentKeys = [this.contentId1, this.contentId2, this.contentId3, this.contentId4, this.contentId6];
        if (this.contentId7) {
            this.contentKeys.push(this.contentId7);
        }
        if (this.contentId8) {
            this.contentKeys.push(this.contentId8);
        }
        if (this.contentId9) {
            this.contentKeys.push(this.contentId9);
        }
        if (this.contentKeys.length > 0) {
            let packegeMap = new Map();
            let results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
            //console.log('results1  :-  ', results);
            getPackages()
                .then((data) => {
                    if (data) {
                        packegeMap.set('basic', '');
                        data.forEach(element => {
                            packegeMap.set(element.packageName.toLowerCase(), '');
                        });

                        this.packs = [];
                        results.forEach(r => {
                            let buttonText = r.description2Label ? r.description2Label.value : '';
                            let buttonLink = '/start-free-trial';
                            let packageTitle;
                            if (r.title.value.includes('REMOTE')) {
                                packageTitle = 'REMOTE PACKAGE';
                            } else if (r.title.value.includes('SECURITY')) {
                                packageTitle = 'SAFETY AND SECURITY';
                            } else {
                                packageTitle = r.title.value.toLowerCase();
                            }

                            let mobileURL;
                            if (r.sectionContent) {
                                let htmlValue = this.htmlDecode(r.sectionContent.value);
                                //console.log('htmlValue : ', htmlValue);
                                let startIndex = htmlValue.indexOf('src="') + 5;
                                //console.log('Start INdex  : ', startIndex);
                                let newValue = htmlValue.substring(htmlValue.indexOf('src="') + 5);
                                //console.log('End INdex  : ', newValue.indexOf('"'));

                                mobileURL = newValue.substring(0, newValue.indexOf('"'));
                                //console.log('This is mobile URL : ', mobileURL);
                            }

                            packegeMap.set(r.title.value.toLowerCase(), JSON.parse(JSON.stringify({
                                title: r.title.value.toLowerCase(),
                                id: r.title.value.toLowerCase(),
                                mobileId: 'm_' + r.title.value.toLowerCase(),
                                body: r.body ? this.htmlDecode(r.body.value) : '',
                                subTitle: r.subTitle ? r.subTitle.value : '',
                                descriptionLabel: r.descriptionLabel ? r.descriptionLabel.value : '',
                                descriptionContent: r.descriptionContent ? this.htmlDecode(r.descriptionContent.value) : '',
                                background: r.image ? `background-image: url('${basePath}/sfsites/c${r.image.url}');` : '',
                                mobileBackground: r.sectionContent ? `background-image: url('${mobileURL}');` : '',
                                buttonText: !this.packagesList.includes(packageTitle.toLowerCase()) ? buttonText : '',
                                buttonLink: !this.isGuest ? buttonLink : this.loginUrl + `&RelayState=${window.location.href}`,
                                sectionTitle: r.sectionLabel ? r.sectionLabel.value : '',
                                packageSectionIcon: r.phone2Label ? this.myGarageResource() + '/ahmicons/' + r.phone2Label.value : this.packageSectionIcon,
                                featureTitle: r.phoneLabel ? r.phoneLabel.value : '',
                                features: this.htmlDecode(r.description2Content.value).replaceAll('&lt;', '<').replaceAll('&gt;', '>')
                            })));
                        });


                        packegeMap.forEach((value, key) => {
                            if (value != '') {
                                this.packs.push(value);
                            }
                        });

                        //console.log('PACKS :: ', this.packs);
                    }
                }).catch((error) => {
                   // console.error('Error For get packages :', error);
                });
        }
    };

    initializePageDetails = async () => {
        if (this.contentId5) {
            let results = await getManagedContentByTopicsAndContentKeys([this.contentId5], this.topics, this.pageSize, this.managedContentType);
            //console.log('Result : ', results);
            //console.log('Result : ', results[0].video);
            if (results) {
                let result = results[0];
                this.heading1 = result.subTitle ? result.subTitle.value : '';
                this.heading2 = result.descriptionLabel ? result.descriptionLabel.value : '';
                this.heading3 = result.description2Label ? result.description2Label.value : '';
                this.heading4 = result.phoneLabel ? result.phoneLabel.value : '';
                this.heading5 = result.phone2Label ? result.phone2Label.value : '';
                this.btnLabel1 = result.sectionLabel ? result.sectionLabel.value : '';
                this.btnLabel2 = result.sectionContent ? this.htmlDecode(result.sectionContent.value) : '';
                this.appStoreIcon = result.descriptionContent ? this.htmlDecode(result.descriptionContent.value) : '';
                this.playStoreIcon = result.body ? this.htmlDecode(result.body.value) : '';
                if (this.isGuest)
                    this.compatibilityResultUrl = this.loginUrl + `&RelayState=${window.location.href}`;
                // this.compatibilityResultUrl = this.domainName + '/hondaowners/s/login/?app=' + this.appId + `&RelayState=${window.location.href}`;
                else
                    this.compatibilityResultUrl = this.brand.toLowerCase() == 'acura' ? '/acura-product-compatibility-result?fb=true' : '/honda-product-compatibility-result?fb=true';
            }
        }
    };

    getCIAMdetails() {
        getCIAMConfig().then(result => {
            this.loginUrl = result.Ciam_Login_Url__c;
        })

    }

    handleNavigations(event) {
        let navigationUrl = event.currentTarget.dataset.url;
        //console.log(' navigation URL : ', navigationUrl)
        let lastPage = sessionStorage.getItem('frompageformarketingpage');
        if (lastPage != 'pdp') {
            if (navigationUrl == '/honda-product-compatibility-result?fb=true') {
                navigationUrl = '/hondalink-product-compatibility';
            }
            if (navigationUrl == '/acura-product-compatibility-result?fb=true') {
                navigationUrl = '/acuralink-product-compatibility';
            }

        }
        this.navigate(navigationUrl, {});
    }

    handleCheckVehicle(event) {
        let navigationUrl = event.currentTarget.dataset.url;
        let currentDivisionId = this.brand == 'Honda' ? 'A' : 'B';
        sessionStorage.setItem('frompage', document.title == 'HondaLink Marketing' ? 'Hondalink' : 'Acuralink');
        let lastPage = sessionStorage.getItem('frompageformarketingpage');
        if (this.localContext.product && this.localContext.product.divisionId == currentDivisionId && lastPage == 'pdp') {
            let navigationPath = this.brand == 'Honda' ? '/honda-product-compatibility-result?fb=true' : '/acura-product-compatibility-result?fb=true';
            this.navigate(navigationPath, {});
        } else {
            this.navigate(navigationUrl, {});
        }
    }

    getMyVehicleAndMyProfile = async () => {
        if (this.context && this.context.product) {
            let currentProductIdentifier = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;

            let subscriptions = await getMyVehicleAndMyProfile({ productIdentifier: currentProductIdentifier, divisionId: this.context.product.divisionId });
            //console.log('ManageSubscriptions', JSON.stringify(subscriptions));
            if (subscriptions && subscriptions.devices) {
                const packages = subscriptions.devices[0].programs[0].packages;
                packages.forEach(pack => {
                    this.packagesList.push(pack.packageName.toLowerCase());
                })
            }
        }
    }

    closePopup() {
        this.showPopup = false;
    }

    handleAppNavigations(event) {
        let eventMetadata = {
            action_type: 'image',
            action_category: 'body',
            action_label: document.location.pathname.includes('acuralink') ? 'download acuralink app' : 'download hondalink app'
        };
        let message = this.buildAdobeMessage('https://app-download.com', eventMetadata);
        // let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        this.showPopup = false;
        let navigationUrl = event.currentTarget.dataset.url;
        this.navigate(navigationUrl, {});
    }

    handleFreeTrial(event) {
        let dataPack = event.currentTarget.dataset.pack.toLowerCase();
        let buttonTitle = event.currentTarget.dataset.name.toLowerCase();
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: dataPack + ':' + buttonTitle
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        this.showPopup = true;
    }
}
//============================================================================
// Title:    Honda MyGarage Experience - Product Compatibility Results
//
// Summary:  This is the Product Compatibility Results html seen at the page of the Honda MyGarage Community
//
// Details:  Product Compatibility Results for pages
//
// History:
// October 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { LightningElement, track, wire, api } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getFeatureListByModelByPackages from '@salesforce/apex/OwnAPIController.getFeatureListByModelByPackages';
import getFeatureListByVINByPackages from '@salesforce/apex/OwnAPIController.getFeatureListByVINByPackages';
import getTrialEligibility from '@salesforce/apex/OwnAPIController.getTrialEligibility';
import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
import { CurrentPageReference } from 'lightning/navigation';
import { getProductContext, ISGUEST } from 'c/ownDataUtils';
//import getMySubscriptions from '@salesforce/apex/OwnAPIController.getMySubscriptions';
import getManageSubscriptions from '@salesforce/apex/OwnAPIController.getManageSubscriptions';
import getMyVehicles from '@salesforce/apex/OwnAPIController.getMyVehicles';
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';
import getPackages from '@salesforce/apex/OwnAPIController.getPackages';
import getSSPSSOAcuralink from '@salesforce/apex/OwnAPIController.getSSPSSOAcuralink';
import getSSPSSOHondalink from '@salesforce/apex/OwnAPIController.getSSPSSOHondalink';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
import getSSO from '@salesforce/apex/OwnAPIController.getSSO';
export default class OwnProductCompatibilityResults extends OwnBaseElement {
    isGuest = ISGUEST;
    packageSectionIcon = this.myGarageResource() + '/images/package_icon.png';
    loactionIcon = this.myGarageResource() + '/images/location.png';
    popupAppStoreIcon = this.myGarageResource() + '/images/appstoreicon.png';
    popupPlayStoreIcon = this.myGarageResource() + '/images/playstoreicon.png';
    @track warningImage = this.myGarageResource() + '/ahmicons/warning.png';
    noSelectedRecord = true;

    @api contentId;
    @api contentId2;
    @api contentId3;
    @api contentId4;
    @api contentId5;
    @api contentId6;
    @api contentId7;
    @api contentId8;
    @api contentId9;
    @api contentId10;
    @api connectivitypackagetitle;
    @api connectivitypackagesubtitle;
    @api playStoreURL;
    @api appStoreURL;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track context;
    brandName = '';
    year = '';
    model = '';
    divisionId = '';

    @track freeTrialCMSData;
    @track tableData = [];
    @track packs;
    @track connectivityPackages = [];
    @track packageContent;
    @track packages = [];
    @track subscriptions;
    @track isNewUser = true;
    @track vehicleEligibility;
    currentPageReference = null;
    urlStateParameters = null;
    loginUrl;
    @track hasDataExist = false;
    @track allPackagesInOrder;
    @track isDataLoading = true;
    @track showPopup = false;
    @track currentProduct;
    @track currentProductIdentifier;
    @api counter = 0;
    @track freeTrailEligible;

    //AMSMG-9
    @track lastestModel = false;
    //AMSMG-9 END

    get popupText() {
        if (document.title.toLocaleLowerCase().includes('honda')) {
            return 'DOWNLOAD THE HONDALINK APP AND PAIR WITH YOUR HONDA TO START USING THESE FEATURES TODAY';
        } else {
            return 'DOWNLOAD THE ACURALINK APP AND PAIR WITH YOUR ACURA TO START USING THESE FEATURES TODAY';
        }
    }
    connectedCallback() {
        this.subscribeToChannel((message) => {
            this.handleMessage(message);
        });

        this.packageContent = {
            'Link': this.contentId,
            'Security': this.contentId2,
            'Remote': this.contentId3,
            'Concierge': this.contentId4,
            'Standard': this.contentId6,
            'Connect': this.contentId7,
            'Premium': this.contentId8,
            'Basic': this.contentId9,
            'Integra23': this.contentId10
        };
        this.packs = [];
        this.tableData = [];

        this.getCIAMdetails();
        this.initialize();
        this.initializeManagedContent();

    }

    renderedCallback() {
        try {
            //console.log("NATIVE JS P Test");
            if (this.counter == 0) {
                //console.log("NATIVE JS P Inside" + this.counter);
                this.counter = this.counter + 1;
                //  setTimeout(() => {
                let richTextElements = this.template.querySelectorAll("lightning-formatted-rich-text");
                //console.log('NATIVE JS PP ' + richTextElements.length);
                if (richTextElements.length == 0) {
                    this.counter = 0;
                }
                richTextElements.forEach(element => {
                    //console.log("NATIVE JS P" + element);
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
                // }, 3000);
            }
        } catch (ex) {
            //console.log("NATIVE JS P" + ex);
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.fb = this.urlStateParameters.fb || null;
    }

    initialize = async () => {
        let origin = localStorage.getItem('origin');
        if (this.fb == 'true' || origin == 'ProductChooser') {
            this.context = await getProductContext('', true);
            //console.log('context from browser - ', JSON.parse(JSON.stringify(this.context)));
        } else {
            this.context = await getProductContext('', false);
            //console.log('context from server - ', JSON.parse(JSON.stringify(this.context)));
        }

        if (!this.isGuest) {
            await this.initializeSubscriptions();
        }

        if (this.context.product) {
            if (this.context.product.divisionId == 'A') {
                this.brandName = 'HondaLink';
            } else if (this.context.product.divisionId == 'B') {
                this.brandName = 'AcuraLink';
            }
            this.year = this.context.product.year;
            this.model = this.context.product.model;
            this.divisionId = this.context.product.divisionId;
            this.getFeatureListByPackages();
        } else {
            this.isDataLoading = false;
        }

    };

    initializeManagedContent = async () => {
        let freeTrialCMSResults = await getManagedContentByTopicsAndContentKeys([this.contentId5], this.topics, this.pageSize, this.managedContentType);

        if (freeTrialCMSResults && freeTrialCMSResults[0]) {
            this.freeTrialCMSData = {
                title: freeTrialCMSResults[0].title.value,
                body: freeTrialCMSResults[0].body ? this.htmlDecode(freeTrialCMSResults[0].body.value) : '',
                iconImage: freeTrialCMSResults[0].image ? `${basePath}/sfsites/c${freeTrialCMSResults[0].image.url}` : '',
                buttonText: freeTrialCMSResults[0].downloadLabel ? freeTrialCMSResults[0].downloadLabel.value : '',
            };
        }
    };

    initializeSubscriptions = async () => {
        let currentProductIdentifier = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
        if (currentProductIdentifier && currentProductIdentifier !== '-') {
            getManageSubscriptions({ productIdentifier: currentProductIdentifier, divisionId: this.context.product.divisionId })
                .then(result => {
                    this.subscriptions = result;
                    if (this.subscriptions && this.subscriptions.vehicleFeature && this.subscriptions.vehicleFeature.vehicle) {
                        this.currentProduct = this.subscriptions.vehicleFeature.vehicle;
                    }
                    //console.log('this.getMySubscriptions', this.subscriptions);
                }).catch(error => {
                    //console.log(error);
                })
        }
    }

    async getFeatureListByPackages() {
        if (this.context) {
            this.allPackagesInOrder = await getPackages();
            let origin = localStorage.getItem('origin');
            let currentProductIdentifier = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
            if (currentProductIdentifier && currentProductIdentifier !== '-') {
                let modelName = '';
                if (this.model) {
                    modelName = this.model.replaceAll(' ', '%20');
                }
                getFeatureListByVINByPackages({ productIdentifier: currentProductIdentifier, divisionId: this.context.product.divisionId, origin: origin })
                    .then((data) => {

                        //console.log('getFeatureListByVINByPackages data', data);
                        this.initializeFeatures(data);
                    })
                    .then(() => {
                        getTrialEligibility({ productIdentifier: currentProductIdentifier, divisionId: this.context.product.divisionId })
                            .then((data) => {
                                //console.log('Data : ', data);
                                this.vehicleEligibility = data.responseBody;

                            })
                            .then(() => {
                                //console.log("Year and Model", this.year+modelName+this.model);
                                if (this.year == "2023" && (modelName == "MDX" || modelName == "TLX" || modelName == "RDX")) {
                                    //console.log('Modify Costs To This Model');
                                    this.lastestModel = true;
                                }
                                this.initializePackages();
                            })
                            .catch((error) => {
                                //console.log('Error : ', error);
                            });
                    })
                    .catch((error) => {
                        this.isDataLoading = false;
                        //console.log('Error : ', error);
                    });
            } else {
                let modelName = '';
                if (this.model) {
                    modelName = this.model.replaceAll(' ', '%20');
                }
                getFeatureListByModelByPackages({ year: this.year, model: modelName, modelId: this.context.product.modelId, divisionId: this.divisionId, origin: origin })
                    .then((data) => {
                        //console.log('getFeatureListByModelByPackages data1', data);
                        this.initializeFeatures(data);
                    })
                    .then(() => {
                        //console.log("Year and Model", this.year, " ", modelName, " ", this.model);

                        //AMSMG-9
                        if (this.year == "2023" && (modelName == "MDX" || modelName == "TLX" || modelName == "RDX")) {
                            //console.log('Modify Costs To This Model');
                            this.lastestModel = true;
                        }
                        //AMSMG-9 End

                        this.initializePackages();
                    })
                    .catch((error) => {
                        this.isDataLoading = false;
                        //console.log('Error : ', error);
                    });
            }
        }
    }

    initializeFeatures(featureData) {
        let lastTelematicsPlatform = '';
        let lastTelematicsUnit = '';
        featureData.forEach(element => {
            lastTelematicsPlatform = element.telematicsPlatform;
            lastTelematicsUnit = element.telematicsUnit;
            let tableRecord = JSON.parse(JSON.stringify(element));
            tableRecord.isSelected = false;
            tableRecord.class = 'slds-hint-parent slds-border_bottom';
            if (element.modelId == this.context.product.modelId && this.noSelectedRecord) {
                tableRecord.class = 'slds-hint-parent slds-border_bottom highlight-row';
                this.noSelectedRecord = false;
                tableRecord.isSelected = true;
                if (!this.currentProduct) {
                    this.currentProduct = {
                        divisionCode: this.divisionId,
                        telematicsPlatform: element.telematicsPlatform,
                        telematicsUnit: element.telematicsUnit,
                        VIN: ''
                    };
                }
            }
            this.tableData.push(tableRecord);
        });
        if (!this.currentProduct) {
            this.currentProduct = {
                divisionCode: this.divisionId,
                telematicsPlatform: lastTelematicsPlatform,
                telematicsUnit: lastTelematicsUnit,
                VIN: ''
            };
        }
        //console.log('this.tableData-->', this.tableData);
        let packagesLoaded = false;
        this.tableData.forEach((element, index, array) => {
            if (this.noSelectedRecord || element.isSelected) {
                element.packageToFeatures.forEach(pack => {
                    if (pack.isAvailable && !(pack.packageName.toUpperCase() in this.packs)) {
                        this.packs[pack.packageName.toUpperCase()] = pack;
                        if (pack.packageName == 'Remote' && this.currentProduct.divisionCode == 'B' && this.currentProduct.telematicsUnit == 'Y' && this.currentProduct.telematicsPlatform == 'MY21') {
                            if (this.packageContent['Integra23']) {
                                this.contentKeys.push(this.packageContent['Integra23']);
                            }
                        } else {
                            if (this.packageContent[pack.packageName]) {
                                this.contentKeys.push(this.packageContent[pack.packageName]);
                            }
                        }
                    }
                    if (!packagesLoaded) {
                        if (this.allPackagesInOrder.length > 0) {
                            let packFound = this.allPackagesInOrder.find(packInOrder => packInOrder.packageName == pack.packageName);
                            this.packages.push(packFound.packageDisplayName);
                        }
                        this.hasDataExist = true;
                    }
                });
                packagesLoaded = true;
            }
        });
    }

    initializePackages = async () => {

        if (this.contentKeys.length > 0) {

            let results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
            let packes = this.packs;
            this.packs = [];
            // //console.log('Packes : ',packes);
            // //console.log('results',results);

            let packegeMap = new Map();
            getPackages()
                .then((data) => {
                    if (data) {

                        data.forEach(element => {
                            packegeMap.set(element.packageName.toUpperCase(), '');
                        });
                        ////console.log('packegeMap1  :-  ',packegeMap);
                        results.forEach(r => {
                            let buttonText = '';
                            let isEligible = false;
                            let isEnrolled = false;

                            if (this.vehicleEligibility) {
                                let currentVehicleEligibility = JSON.parse(JSON.stringify(this.vehicleEligibility));
                                //console.log('This is this.vehicleEligibility', currentVehicleEligibility);
                                if (currentVehicleEligibility && currentVehicleEligibility.eligibilityFlag && currentVehicleEligibility.eligibleProducts) {
                                    for (const eligibilityProduct of currentVehicleEligibility.eligibleProducts) {
                                        // //console.log('This is eligibilityProduct',eligibilityProduct);
                                        // //console.log('This is r.title.value',r.title.value);
                                        if (eligibilityProduct.productName.toLowerCase().includes(r.title.value.toLowerCase())) {
                                            isEligible = true;
                                            break;
                                        }
                                    }
                                }
                            }

                            let buttonLink = '';
                            if (this.subscriptions) {

                                if (this.subscriptions.manageSubscriptions.vehicleInfo && this.subscriptions.manageSubscriptions.vehicleInfo[0] && this.subscriptions.manageSubscriptions.vehicleInfo[0].ownership == "N") {
                                    this.isNewUser = true;
                                } else {
                                    this.isNewUser = false;
                                }

                                if (this.subscriptions.packages) {
                                    this.subscriptions.packages.forEach(element => {
                                        if (element.packageDisplayName.toLowerCase() == r.title.value.toLowerCase() && (element.status == 'Active' || element.status == 'Expired')) {
                                            isEnrolled = true;
                                        }
                                    });
                                }
                            }
                            this.currentProductIdentifier = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
                            // let isYMT = false;
                            // if( !currentProductIdentifier || currentProductIdentifier == '-'){
                            //     isYMT = true;
                            // }
                            //console.log('This is isEnrolled : ', isEnrolled, ' isEligible----', isEligible);
                            if (!isEnrolled && !isEligible) { //&& (!isYMT || this.isGuest)
                                buttonText = 'ENROLL';
                                buttonLink = '/enroll';
                            } else if (isEnrolled) {// && isEligible // && (!isYMT || this.isGuest)
                                buttonText = 'MANAGE';
                                buttonLink = '/manage';
                            } else if (!isEnrolled && isEligible) {
                                this.freeTrailEligible = true;
                                buttonText = r.description2Label ? r.description2Label.value : '';//Start-Free-Trial
                                buttonLink = '/start-free-trial'
                            }

                            if (r.title.value.toLowerCase() == 'link' || r.title.value.toLowerCase() == 'basic') {
                                buttonText = '';
                                buttonLink = '';
                            }
                            //console.log('This is button Text : ', buttonText);
                            let mobileURL;
                            if (r.sectionContent) {
                                let htmlValue = this.htmlDecode(r.sectionContent.value);
                                let newValue = htmlValue.substring(htmlValue.indexOf('src="') + 5);
                                mobileURL = newValue.substring(0, newValue.indexOf('"'));
                            }

                            packegeMap.set(r.title.value.toUpperCase(), JSON.parse(JSON.stringify({
                                id: r.title.value.toLowerCase(),
                                mobileId: 'm_' + r.title.value.toLowerCase(),
                                title: r.title.value,
                                body: r.body ? this.htmlDecode(r.body.value) : '',
                                subTitle: r.subTitle ? r.subTitle.value : '',
                                descriptionLabel: r.descriptionLabel ? r.descriptionLabel.value : '',
                                descriptionContent: r.descriptionContent ? this.htmlDecode(r.descriptionContent.value) : '',
                                background: r.image ? `background-image: url('${basePath}/sfsites/c${r.image.url}');` : '',
                                buttonText: buttonText,
                                buttonLink: !this.isGuest ? buttonLink : this.loginUrl + `&RelayState=${window.location.href}`,
                                sectionTitle: r.sectionLabel ? r.sectionLabel.value : '',
                                mobileBackground: r.sectionContent ? `background-image: url('${mobileURL}');` : '',
                                //sectionContent : r.sectionContent ? this.htmlDecode(r.sectionContent.value) : '',
                                featureTitle: r.phoneLabel ? r.phoneLabel.value : '',
                                packageSectionIcon: r.phone2Label ? this.myGarageResource() + '/ahmicons/' + r.phone2Label.value : this.packageSectionIcon,
                                features: packes[r.title.value.toUpperCase()] ? packes[r.title.value.toUpperCase()].features : ''  //[feature, feature, feature, feature , feature , feature , feature]
                            })))
                        });
                        packegeMap.forEach((value, key) => {
                            if (value != '') {
                                //console.log('Value', value, " ", key);
                                const d = new Date();
                                let currentYear = d.getFullYear();

                                //AMSMG-9
                                if (key == "SECURITY" && this.lastestModel == true) {
                                    value.body = "<p>3 years complimentary, $89/year after complimentary period</p>";
                                }

                                if (key == "REMOTE" && this.model == 'Integra'){
                                    value.body = "<p>First 3 years Complimentary</p><p>$10.00 mo / $110 yr</p>";
                                }else if(key == "REMOTE" && currentYear >= 2023 && (this.model == 'Accord Sedan' || this.model == 'CR-V' || this.model == 'Pilot' || this.model == 'Civic Type R')){
                                    value.body = "<p>3 months complimentary, $10.00 mo / $110 yr after complimentary period</p>";
                                }else if (key == "REMOTE" && this.lastestModel == true) {
                                    value.body = "<p>3 years complimentary, $110/year after complimentary period</p>";
                                }
                                if (key == "CONCIERGE" && this.lastestModel == true) {
                                    value.body = "<p>6 months complimentary, $150/year after complimentary period</p>";
                                }
                                //AMSMG-9 End

                                this.packs.push(value);
                            }
                        });

                    }
                    this.isDataLoading = false;
                }).catch((error) => {
                    this.isDataLoading = false;
                    console.error('Error:', error);
                });

        }
        this.isDataLoading = false;
    };


    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }

    handleLoginClick() {
        // let url = this.domainName + '/hondaowners/s/login/?app=' + this.appId + `&RelayState=${window.location.href}`;
        let url = this.loginUrl + `&RelayState=${window.location.href}`;
        // this.navigate('/login', {});
        window.open(url, '_self');
    }

    async handleFreeTrial(event) {
        //console.log('this.currentProduct -->', this.currentProduct);
        let URL = event.currentTarget.value;
        let dataPack = event.currentTarget.dataset.pack.toLowerCase();
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: dataPack + ':' + event.currentTarget.dataset.button
        };
        // let message = this.buildAdobeMessage(this.headerlink, eventMetadata);
        // this.publishToChannel(message);
        if (this.isGuest || URL == '/start-free-trial' || ((URL == '/enroll' || URL == '/manage') && this.currentProduct && this.currentProduct.VIN == '')) {
            let message = this.buildAdobeMessage('/enroll', eventMetadata);
            this.publishToChannel(message);
            this.showPopup = true;
        } else if (!this.isGuest && (URL == '/enroll' || URL == '/manage') && this.currentProduct) {
            //Added New If For DOE-5069 By ABHISHEK SALECHA
            // if (dataPack == 'Remote' && this.currentProduct.divisionCode == 'B' && this.currentProduct.telematicsUnit == 'Y' && this.currentProduct.telematicsPlatform == 'MY21') {
            //     this.showPopup = true;
            // }
            // else 
            if (dataPack == 'security' || dataPack == 'remote' || dataPack == 'concierge') {
                if (this.currentProduct.divisionCode == 'A' || this.currentProduct.divisionCode == 'B') {
                    if ((this.currentProduct.telematicsPlatform == 'MY17' || this.currentProduct.telematicsPlatform == 'MY21' || this.currentProduct.telematicsPlatform == 'MY23') && this.currentProduct.telematicsUnit == 'Y') {
                        if (URL == '/enroll') {
                            let message = this.buildAdobeMessage('/enroll', eventMetadata);
                            this.publishToChannel(message);
                            this.showPopup = true;
                        } else {
                            let message = this.buildAdobeMessage('/enroll', eventMetadata);
                            this.publishToChannel(message);
                            if(this.currentProduct.enrollment === 'N' && this.currentProduct.ownership === 'N'){
                                this.showPopup = true;
                            }else if(this.currentProduct.telematicsPlatform == 'MY17' && this.currentProduct.telematicsUnit == 'Y' && this.freeTrailEligible == true){
                                this.showPopup = true;
                            }else{
                                this.singleSingOnToSXM(this.currentProduct);
                            }
                        }
                    }
                }
            }
            else if ((dataPack == 'standard' || dataPack == 'connect' || dataPack == 'premium') && this.currentProduct.divisionCode == 'B') {
                if (this.currentProduct.telematicsPlatform == 'MY13') {
                    let message = this.buildAdobeMessage('/sxm-phone-info', eventMetadata);
                    this.publishToChannel(message);
                    await this.sleep(3000);
                    this.navigate('/sxm-phone-info', {});
                }
            }
        }

        // this.navigate(URL, {});
    }

    handleFreeTrialEnroll(event) {
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: event.currentTarget.dataset.button
        };
        let message = this.buildAdobeMessage('/enroll', eventMetadata);
        this.publishToChannel(message);
        this.showPopup = true;
    }

    singleSingOnToSXM(product) {
        getSSO({ productIdentifier: product.VIN })
            .then((data) => {
                // //console.log('Data : ',typeof(data));
                //console.log('Data : ', data);
                if (data.statusCode === 200) {
                    if(this.isJSON(data.response)){
                        let jsonResponse = JSON.parse(data.response);
                        if(jsonResponse && jsonResponse.body && jsonResponse.body.status === 'success'){
                          this.navigate(jsonResponse.body.url, {});
                        }else{
                          this.showPopup = true;
                        }
                      }else{
                        let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
                        ssoDiv.innerHTML = data.response;
                        ////console.log('this querySelector : ',this.template.querySelector('form'));
                        this.template.querySelector('form').submit();
                      }
                } else {
                    this.showPopup = true;
                }
            })
            .catch((error) => {
                //console.log('Error : ', error);
                this.showPopup = true;
            });
        // if (product.divisionCode == 'B') {
        //     getSSPSSOAcuralink({ productIdentifier: product.VIN, divisionId: product.divisionCode })
        //         .then((data) => {
        //             // //console.log('Data : ',typeof(data));
        //             //console.log('Data : ', data);
        //             if (data.statusCode === 200) {
        //                 let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
        //                 ssoDiv.innerHTML = data.response;
        //                 ////console.log('this querySelector : ',this.template.querySelector('form'));
        //                 this.template.querySelector('form').submit();
        //             } else {
        //                 this.showPopup = true;
        //             }
        //         })
        //         .catch((error) => {
        //             //console.log('Error : ', error);
        //             this.showPopup = true;
        //         });
        // }
        // if (product.divisionCode == 'A') {
        //     getSSPSSOHondalink({ productIdentifier: product.VIN, divisionId: product.divisionCode })
        //         .then((data) => {
        //             //console.log('Data : ', data);
        //             if (data.statusCode === 200) {
        //                 let ssoDiv = this.template.querySelector(`[data-id="sso"]`);
        //                 ssoDiv.innerHTML = data.response;
        //                 ////console.log('this querySelector : ',this.template.querySelector('form'));
        //                 this.template.querySelector('form').submit();
        //             } else {
        //                 this.showPopup = true;
        //             }
        //         })
        //         .catch((error) => {
        //             //console.log('Error : ', error);
        //             this.showPopup = true;
        //         });
        // }
    }

    isJSON(str) {
        try {
            return (JSON.parse(str) && !!str);
        } catch (e) {
            return false;
        }
    }

    getCIAMdetails = async () => {
        getCIAMConfig().then(result => {
            this.loginUrl = result.Ciam_Login_Url__c;
        })

    }

    handleMessage(message) {
        //console.log('message:', message);
        if (message.packagename) {

            let target = this.template.querySelector(`[data-id="${message.packagename}"]`);
            target.scrollIntoView();
        }
    }

    async handleLearnMore() {
        //console.log('handleLearnMore');
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: 'Learn more about ' + this.brandName
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        let marketingLink = '/' + this.brandName.toLowerCase() + '-marketing';
        await this.sleep(2000);
        this.navigate(marketingLink, {});
    }

    async handleLearnAbout() {
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
            action_label: 'Learn about other ' + this.year + ' ' + this.model + ' Trims '
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);
        let URL;
        if (this.brandName.toLocaleLowerCase().includes('honda')) {
            URL = '/hondalink-product-compatibility';
        } else if (this.brandName.toLocaleLowerCase().includes('acura')) {
            URL = '/acuralink-product-compatibility';
        }
        //console.log('handleLearnAbout', URL);
        await this.sleep(2000);
        this.navigate(URL, {});
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    closePopup() {
        this.showPopup = false;
    }

    handleNavigations(event) {
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

}
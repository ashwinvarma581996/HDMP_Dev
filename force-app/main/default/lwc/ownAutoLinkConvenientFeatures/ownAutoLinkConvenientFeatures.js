//============================================================================
// Title:    Honda MyGarage Experience - Auto Link Feature Card
//
// Summary:  This is the Auto Link Convenient Features Card html seen at the page of the Honda MyGarage Community
//
// Details:  Auto Link Convenient Features Card for pages
//
// History:
// October 18, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, track, LightningElement } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getManagedContentByTopicsAndContentKeys, getProductContext, ISGUEST } from 'c/ownDataUtils';
import basePath from '@salesforce/community/basePath';
import getFeatureListByVINByPackages from '@salesforce/apex/OwnAPIController.getFeatureListByVINByPackages';
import getFeatureListByModelByPackages from '@salesforce/apex/OwnAPIController.getFeatureListByModelByPackages';
import getKeyFeatures from '@salesforce/apex/OwnAPIController.getKeyFeatures';
import getPackages from '@salesforce/apex/OwnAPIController.getPackages';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnAutoLinkConvenientFeatures extends OwnBaseElement {
    @api title;
    @api contentId;
    @api contentId2;
    @api contentId3;
    @api contentId4;
    @api contentId5;
    @api contentId6;
    @track contentKeys = [];
    @track topics = null;
    @track pageSize = null;
    @track managedContentType = '';
    @track convenientFeatures = [];
    @track context;
    year = '';
    model = '';
    divisionId = '';
    @track features = [];
    @track keyFeatures = [];
    @track cmsFeatures = [];
    connectedCallback() {
        this.getKeyFeatures();
        this.initialize();
    }

    initialize = async () => {

        this.contentKeys.push(this.contentId, this.contentId2);
        //this.contentId3 removed Amazon key content Id to resolve Bug DOE-4149
        if (this.contentId4) {
            this.contentKeys.push(this.contentId4);
        }
        if (this.contentId5) {
            this.contentKeys.push(this.contentId5);
        }
        this.results = await getManagedContentByTopicsAndContentKeys(this.contentKeys, this.topics, this.pageSize, this.managedContentType);
        this.results.forEach(r => {
            let obj = {};
            obj.title = r.title.value;
            obj.title = this.htmlDecode(obj.title);
            if (obj.title === 'myQ CONNECTED GARAGE') {
                obj.title = obj.title.replace('GARAGE', 'GARAGE<sup class="supTop">beta</sup>');
            }
            obj.body = this.htmlDecode(r.body.value);
            obj.subTitle = r.subTitle.value;
            obj.desktopImage = this.htmlDecode(r.descriptionContent.value);
            obj.mobileImage = this.htmlDecode(r.description2Content.value);
            obj.navigationUrl = r.sectionLabel ? this.htmlDecode(r.sectionLabel.value) : '';
            if (obj.title == 'DRIVER FEEDBACK<br>&nbsp;' || obj.title == 'myQ CONNECTED GARAGE<sup class="supTop">beta</sup>') {
                obj.footerContent = r.sectionContent ? this.htmlDecode(r.sectionContent.value) : '';
                obj.isStaticFooterContent = true;
            } else {
                obj.isStaticFooterContent = false;
            }
            obj.order = r.phone2Label ? r.phone2Label.value : 0;
            if (document.location.pathname.includes('marketing') && obj.title != 'DRIVER FEEDBACK<br>&nbsp;' && obj.title != 'myQ CONNECTED GARAGE<sup class="supTop">beta</sup>' && obj.title != 'GOOGLE BUILT-IN<br>&nbsp;') {
                let sectionContent = r.sectionContent ? this.htmlDecode(r.sectionContent.value) : '';
                sectionContent = sectionContent.replace(/(<([^>]+)>)/ig, '');
                let convenientPackages = sectionContent.trim() ? sectionContent.split(',') : null;
                if (convenientPackages && convenientPackages.length > 0) {
                    obj.packageNames = [];
                    convenientPackages.forEach(element => {
                        obj.packageNames.push({ desktopName: this.htmlDecode(element.trim()), mobileName: 'm_' + this.htmlDecode(element.trim()) });
                    })
                }
            }
            this.cmsFeatures.push(obj);
            this.cmsFeatures.sort((a, b) => {
                return a.order - b.order;
            });
           // console.log('cmsFeatures', this.cmsFeatures);
        });

        if (!document.location.pathname.includes('marketing')) {

            let origin = localStorage.getItem('origin');
            if (this.fb == 'true' || origin == 'ProductChooser') {
                this.context = await getProductContext('', true);
              //  console.log('context from browser - ', JSON.parse(JSON.stringify(this.context)));
            } else {
                this.context = await getProductContext('', false);
               // console.log('context from server - ', JSON.parse(JSON.stringify(this.context)));
            }
            if (this.context.product) {
                this.year = this.context.product.year;
                this.model = this.context.product.model;
                this.divisionId = this.context.product.divisionId;
                this.getFeatureListByPackages();
            }
        }
        else {
            this.convenientFeatures = this.cmsFeatures;
        }
    };

    htmlDecode(input) {
        if (!input) return '';
        let doc = new DOMParser().parseFromString(input, "text/html");
        return doc.documentElement.textContent.replaceAll('/cms/delivery/', basePath + '/sfsites/c' + '/cms/delivery/');
    }

    async handleClick(event) {

        localStorage.setItem('frompage', 'Marketing');
        let navigationUrl = event.currentTarget.dataset.value;
        //console.log(' navigation URL : ', navigationUrl)

        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: this.convertToPlain(event.currentTarget.dataset.featuretitle).trim() + ':' + event.currentTarget.dataset.buttontitle
        };
        let message = this.buildAdobeMessage(navigationUrl, eventMetadata)
        this.publishToChannel(message);
        await this.sleep(2000);
        this.navigate(navigationUrl, {});
    }


    getFeatureListByPackages() {
        if (this.context) {
            let origin = localStorage.getItem('origin');
            let currentProductIdentifier = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
            if (currentProductIdentifier && currentProductIdentifier !== '-') {
                getFeatureListByVINByPackages({ productIdentifier: currentProductIdentifier, divisionId: this.context.product.divisionId, origin: origin })
                    .then((data) => {

                        //console.log('getFeatureListByVINByPackages data', data);
                        data.forEach(element => {
                            element.packageToFeatures.forEach(packToFeature => {
                                this.features = [...this.features, ...packToFeature.features];
                            })

                        });
                        this.filterFeatures();
                       // console.log('features1', JSON.parse(JSON.stringify(this.features)));
                    })
                    .catch((error) => {
                       // console.log('Error : ', error);
                    });
            } else {
               // console.log('this.model  :-  ', this.model);
                let modelName = '';
                if (this.model) {
                    modelName = this.model.replaceAll(' ', '%20');
                }
                //console.log('modelName1  :-  ', modelName);
                getFeatureListByModelByPackages({ year: this.year, model: modelName, modelId: this.context.product.modelId, divisionId: this.divisionId, origin: origin })
                    .then((data) => {
                        //console.log('getFeatureListByModelByPackages data1', data);
                        data.forEach(element => {
                            element.packageToFeatures.forEach(packToFeature => {
                                this.features = [...this.features, ...packToFeature.features];
                            })

                        });
                        this.filterFeatures();
                       // console.log('features', JSON.parse(JSON.stringify(this.features)));
                    })
                    .catch((error) => {
                        //console.log('Error : ', error);
                    });
            }

        }
    }

    async getKeyFeatures() {
        this.keyFeatures = await getKeyFeatures();
        //console.log('this.keyFeatures', this.keyFeatures);
    }

    async filterFeatures() {
        let allPackagesInOrder = await getPackages();
       // console.log('this.features', this.features);
        let packageFeaturesMap = new Map();
        this.keyFeatures.forEach(element => {
            packageFeaturesMap.set(element.featureName, []);
        });
        this.features.forEach(element => {
            if (packageFeaturesMap.has(element.featureName)) {
                let existngPackages = packageFeaturesMap.get(element.featureName);
                let packFound = allPackagesInOrder.find(packInOrder => packInOrder.packageName == element.packageName);
                if (!existngPackages.includes(packFound.packageDisplayName)) {
                    if (allPackagesInOrder.length > 0) {
                        packageFeaturesMap.set(element.featureName, [...existngPackages, packFound.packageDisplayName]);
                    }


                }
            }
        })
        //console.log('packageFeaturesMap', packageFeaturesMap);
        let features = [];

        this.cmsFeatures.forEach(element => {
            packageFeaturesMap.forEach((value, key) => {
                let feature = key.toLowerCase();
                //console.log('feature', feature);
                //console.log('element.title', element.title);
                if (feature.includes(element.title.toLowerCase())) {
                    if (value.length > 0) {
                        let packageNames = [];
                        packageFeaturesMap.get(key).forEach(packName => {
                            packageNames.push({ desktopName: packName, mobileName: 'm_' + packName });
                        })
                        element.packageNames = packageNames;

                        features.push(element);
                    } else {
                        features.push(element);
                    }
                    //console.log('element.title', element.title);
                }
            });
        });

        this.convenientFeatures = features;
        //console.log('packageFeaturesMap', packageFeaturesMap);
        //console.log('convenientFeatures', this.convenientFeatures);
    }

    handleScroll(event) {
        let message = { packagename: event.currentTarget.dataset.packagename.toLowerCase() };
        this.publishToChannel(message);
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    convertToPlain(html) {
        let tempDivElement = document.createElement("div");
        tempDivElement.innerHTML = html;
        return tempDivElement.textContent || tempDivElement.innerText || "";
    }
}
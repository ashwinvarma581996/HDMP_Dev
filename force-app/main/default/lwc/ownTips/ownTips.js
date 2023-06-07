import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getDataCategories from '@salesforce/apex/OwnHelpCenterController.getDataCategories';
import getTipsArticleCategories from '@salesforce/apex/OwnHelpCenterController.getTipsArticleCategories';
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';
import { brandDataCategoryMap, getOrigin } from 'c/ownDataUtils';
import { getProductContext, getCategoryCd } from 'c/ownDataUtils';
import { CurrentPageReference } from 'lightning/navigation';
const PRODUCT_CONTEXT_PAGES = ['garage-marine', 'honda-marine-resources-downloads', 'honda-power-equipment-resources-downloads', 'honda-power-equipment-service-maintenance', 'garage-powerequipment'];

export default class ownTips extends OwnBaseElement {

    @track categories;
    @api brandLabel;
    @track brand;
    @track subcategory;
    @track showResult = false;
    @track showSearchResult = false;
    @track category;
    @track tipsCategories;
    @track isProductContextPage = false;
    @track hasMultipleCategories;
    @track isFuelRecommendation = false;

    @api
    get categoriesLoaded() {
        return this.categories ? true : false;
    }

    @api
    get resultsDesktopSize() {
        return this.hasMultipleCategories ? '9' : '12';
    }
    currentPageReference = null;
    urlStateParameters = null;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            //console.log('$Tips: ownTips:: urlStateParameters - ', this.urlStateParameters);
        }
    }

    connectedCallback() {
        this.subscribeToChannel((message) => {
            if (message.subcategory) {
                this.subcategory = message.subcategory;
                this.showResult = message.showResult;
                //console.log('$Tips: ownTips:: subcategory - ', this.subcategory);
                if (message.mobile) {
                    let pageUrl = window.location.href.includes('tips-power-equipment') ? '/tips-power-equipment' : '/tips-marine';
                    let messageObject = { page: 'Tips', setSubtitle: 'Tips'/*this.subcategory.label*/, setBreadcrumb: { pageTitle: 'Tips', pageUrl: pageUrl } };
                    if (window.location.href.includes('tips-power-equipment')) {
                        messageObject.setBreadcrumb.pageTitle = 'Resources & Downloads';
                        messageObject.setBreadcrumb.pageUrl = '/honda-power-equipment-resources-downloads';
                        if (window.location.search == '?isFuelRecommendation=true') {
                            messageObject.setBreadcrumb.pageTitle = 'Power Equipment: Overview';
                            messageObject.setBreadcrumb.pageUrl = '/garage-powerequipment';
                        }
                        if (window.location.search == '?isFuelRecommendation=true&tab=sm') {
                            messageObject.setBreadcrumb.pageTitle = 'Power Equipment: Service & Maintenance';
                            messageObject.setBreadcrumb.pageUrl = '/honda-power-equipment-service-maintenance';
                        }
                    }
                    if (window.location.href.includes('tips-marine') && (window.location.search == '?isFuelRecommendation=true' || window.location.search == '?isFuelRecommendation=true&tab=sm') && window.matchMedia("(max-width: 600px)").matches) {
                        messageObject.setBreadcrumb.pageTitle = 'Tips';
                        messageObject.setBreadcrumb.pageUrl = '/tips-marine';
                    }
                    this.publishToChannel(messageObject);
                    //console.log('$Tips: ownTips:: publishing mobile message messageObject - ', messageObject);
                }
            }
            if (message.page === 'Tips' && message.headerBreadcrumbClick) {
                this.showResult = false;
                this.publishToChannel({ page: 'Tips', revertHeader: true });
            }
        });
        let fromPage = sessionStorage.getItem('frompage');
        //console.log('$Tips: ownTips:: fromPage - ', fromPage);
        for (let page of PRODUCT_CONTEXT_PAGES) {
            //console.log('$Tips: ownTips:: page - ', page);
            if (fromPage.toLowerCase().includes(page)) {
                this.isProductContextPage = true;
            }
        }

        //console.log('$Tips: ownTips:: isProductContextPage - ', this.isProductContextPage);

        this.initialize();
    }

    initialize = async () => {

        if (this.urlStateParameters.isFuelRecommendation == 'true') {
            this.isFuelRecommendation = true;
            //console.log('$Tips: ownTips:: isFuelRecommendation - ', this.isProductContextPage);
        }
        let categoryCd = null;
        if (this.isProductContextPage) {
            const context = (getOrigin() === 'ProductChooser') ? await getProductContext('', true) : await getProductContext();
            //console.log('$Tips: ownTips:: context - ', context);
            let storedCategoryCodes = sessionStorage.getItem('tipsProductCategoryCodes') ? JSON.parse(sessionStorage.getItem('tipsProductCategoryCodes')) : {};
            //console.log('$Tips: ownTips:: storedCategoryCodes - ', storedCategoryCodes);
            //console.log('$Tips: ownTips:: before IF');

            if (context.product.categoryCd) {
                categoryCd = this.changeCategoryCd(context.product.categoryCd);
            }
            else if (storedCategoryCodes && storedCategoryCodes[context.product.vin]) {
                //console.log('$Tips: ownTips:: categoryCd from cache');
                categoryCd = storedCategoryCodes[context.product.vin];
            }
            else {
                //console.log('$Tips: ownTips:: categoryCd from API');

                //console.log('$Tips: ownTips:: context.product.vin + context.product.divisionId + context.product.division - ', context.product.vin + context.product.divisionId + context.product.division);

                let newCategoryCd = await getCategoryCd(context.product.vin, context.product.divisionId, context.product.division);
                categoryCd = this.changeCategoryCd(newCategoryCd);
                storedCategoryCodes[context.product.vin] = categoryCd;
                //console.log('$Tips: ownTips:: storedCategoryCodes - ', storedCategoryCodes);

                sessionStorage.setItem('tipsProductCategoryCodes', JSON.stringify(storedCategoryCodes));
            }
            //console.log('$Tips: ownTips:: categoryCd - ', categoryCd);

        }

        getTipsArticleCategories({ brand: this.brandLabel, categoryCd: categoryCd })
            .then(result => {
                let tipsCategories = new Set();
                //console.log('$Tips: ownTips:: categories list - ', result);


                result.forEach(metadataItem => {
                    tipsCategories.add(metadataItem.DeveloperName);
                });
                getDataCategories()
                    .then(result => {
                        let allCategoryListForBrand;
                        //console.log('$Tips: ownTips:: categories data list - ', result);

                        this.categories = [];
                        result.forEach(element => {
                            if (element.label === this.brandLabel) {
                                //console.log('ownTips:: element.label brandLabel', element.label, this.brandLabel, element.categories);

                                allCategoryListForBrand = element.categories;
                            }
                        });


                        allCategoryListForBrand.forEach(element => {
                            if (tipsCategories.has(element.name)) {
                                //console.log('ownTips:: tipsCategories.has(element.name)', element.name, tipsCategories);
                                this.categories.push(element);
                            }
                        });
                        //console.log('$Tips: ownTips:: this.categories - ', this.categories);


                        this.hasMultipleCategories = this.categories.length > 1;
                        if (this.hasMultipleCategories) {
                            this.categories.unshift({ label: 'Popular Tips', name: 'PopularTips' });
                        }
                        //console.log('$Tips: ownTips:: hasMultipleCategories - ', this.hasMultipleCategories);

                    })
            })
            .catch(error => {
                console.error(error);

            })
    }
    changeCategoryCd(categoryCd) {
        //console.log('$Tips: ownTips:: changeCategoryCd - ', categoryCd);

        if (categoryCd == 'CM' || categoryCd == 'LM') {
            return 'LM'
        } else if (categoryCd == 'RV' || categoryCd == 'GG') {
            return 'GG'
        } else if (categoryCd == 'SE' || categoryCd == 'TB') {
            return 'TB'
        } else {
            return categoryCd;
        }
    }
}
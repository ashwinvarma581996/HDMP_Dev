//============================================================================
// Title:    Honda Owners Experience - Help Center
//
// Summary:  category list logic at the help center of the Honda Owner Community
//
// Details:  Extend the LightningElement with this Base Element to gain access to the Messaging Channel and other logic herein and this is the category list component for all help center pages.
//
//
// History:
// June 16, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { setOrigin, getOrigin, } from 'c/ownDataUtils';
import showCasesTab from '@salesforce/apex/OwnSendAnEmailFormController.showCasesTab';

//
import getFeatureListByProductIdentifier from '@salesforce/apex/OwnAPIController.getFeatureListByProductIdentifier';
import { getMyProducts } from 'c/ownDataUtils';
import getManageSubscriptions from '@salesforce/apex/OwnAPIController.getManageSubscriptions';
import { getProductContext, ISGUEST, addProduct, nonConnectedPlatformMap } from 'c/ownDataUtils';

import getPackages from '@salesforce/apex/OwnAPIController.getPackages';
//

import ACCOUNT_ID from '@salesforce/schema/User.Contact.AccountId';
import Id from '@salesforce/user/Id';
import {
    getRecord,
    getFieldValue,
} from 'lightning/uiRecordApi';

import { CurrentPageReference } from 'lightning/navigation';
import getCIAMConfig from '@salesforce/apex/OwnUserHandler.getCIAMConfig';

import { getManagedContentByTopicsAndContentKeys } from 'c/ownDataUtils';
//import dreamSiteUrl from '@salesforce/label/c.DreamSiteLink';
import financeUrl from '@salesforce/label/c.Finance_Link';
import financeLogOutUrl from '@salesforce/label/c.Finance_LogOutUrl';
import dreamshopUrl from '@salesforce/label/c.Dreamshop_Url';
import dreamShopIDPLoginURL	from '@salesforce/label/c.DreamShopIDPLoginURL';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';

const MYACCOUNT_TAB_MAP = new Map();
MYACCOUNT_TAB_MAP.set('account', { index: 0, name: 'Account Information' });
MYACCOUNT_TAB_MAP.set('cases', { index: 1, name: 'My Support Cases' });
MYACCOUNT_TAB_MAP.set('subscription', { index: 2, name: 'HondaLink & AcuraLink Subscription Status' });
MYACCOUNT_TAB_MAP.set('linked', { index: 3, name: 'Linked Accounts & Connected Features' });
MYACCOUNT_TAB_MAP.set('dataprivacy', { index: 4, name: 'Vehicle Data Privacy' });
MYACCOUNT_TAB_MAP.set('preference', { index: 5, name: 'Communication Preferences' });
MYACCOUNT_TAB_MAP.set('dreamshop', { index: 6, name: 'Dreamshop' });
MYACCOUNT_TAB_MAP.set('finance', { index: 7, name: 'Finance' });

export default class OwnMyAccount extends OwnBaseElement {

    @track myAccountTabs = [{ 'index': 0, 'name': 'Account Information', 'label': 'Account Information' },
    { 'index': 1, 'name': 'My Support Cases', 'label': 'My Support Cases' },
    { 'index': 2, 'name': 'HondaLink & AcuraLink Subscription Status', 'label': 'HondaLink & AcuraLink Subscription Status' },
    { 'index': 3, 'name': 'Linked Accounts & Connected Features', 'label': 'Linked Accounts & Connected Features' },
    { 'index': 4, 'name': 'Vehicle Data Privacy', 'label': 'Vehicle Data Privacy' },
    { 'index': 5, 'name': 'Communication Preferences', 'label': 'Communication Preferences' },
    { 'index': 6, 'name': 'Dreamshop', 'label': 'Dreamshop' },
    { 'index': 7, 'name': 'Finance', 'label': 'Finance' }]

    @track isGuest = ISGUEST;
    @track rightArrow = this.ownerResource() + '/Icons/right_arrow.svg';
    @track tabs = [];
    @track tab;
    @api ssoInitiatingURL;
    @track showFeaturesTab;
    @api androidAppLink;
    @api iosAppLink;
    @api disclaimer;
    @api privacyPolicyLink;
    showTabSet = true;
    userId = Id;
    @track showSpinner = true;

    @api playStoreURL;
    @api appStoreURL;
    @api acuraPlayStoreURL;
    @api acuraAppStoreURL;

    @track dreamshopLink = dreamshopUrl;
    @track dreamShopIDPLoginURL = dreamShopIDPLoginURL;
    @track manageSubscriptionProducts;
    @track subscriptions;
    @track packagesFromManageSubscription = [];

    @track subscriptionsLoaded = false;

    @track vehicleInfos = [];
    zsTelematicsPlatform = '2ZS';
    // @track manageSubscriptionProductsWithVIN;

    @api digitalMarketplace;
    @api finance;

    @track topics;
    @track pageSize = null;
    @track managedContentType = '';
    @track digitalMarketplaceBody;

    label = {
        financeLogOutUrl,
        financeUrl
    };
    financeBody;

    @track tabKey;

    currentPageReference = null;
    urlStateParameters = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            //console.log('$Name-urlStateParameters: ',JSON.parse(JSON.stringify(this.urlStateParameters)));
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.tabKey = this.urlStateParameters.tab || 'account';
    }

    @wire(getRecord, { recordId: '$userId', fields: [ACCOUNT_ID] })
    user;

    get accountId() {
        let result;

        if (this.user && this.user.data) {
            result = getFieldValue(this.user.data, ACCOUNT_ID);
        }

        return result;
    }

    connectedCallback() {
        // sessionStorage.setItem('defaulttab', 'My Support Cases');
        //Ravindra Ravindra (Wipro) DOE-2441
        if (this.isGuest) {
            this.getCIAMdetails();
        } else {
            if (getOrigin() === 'ProductSettings') {
                setOrigin('');
                window.location.reload();
            }
            else {
                this.getTabs();
            }
            this.getCMSContentFinance(this.finance);
            this.getCMSContentDigitalMarketPlace(this.digitalMarketplace);
        }
    }

    getCIAMdetails = async () => {
        getCIAMConfig().then(result => {
            let url = result.Ciam_Login_Url__c + `&RelayState=${window.location.href}`;
            window.open(url, "_self")
        });
    }

    async getCMSContentFinance(finance) {
        let content = await getManagedContentByTopicsAndContentKeys([finance], this.topics, this.pageSize, this.managedContentType);
        //console.log('CMS Content child 3------', JSON.parse(JSON.stringify(content)));
        if (content) {
            this.financeBody = {
                body: content[0].body ? this.htmlDecode(content[0].body.value) : '',
            }
        }
        this.financeBody = this.htmlDecode(this.financeBody.body);
        //console.log('financeBody----', this.financeBody);
    }

    async getCMSContentDigitalMarketPlace(digitalMarketPlace) {
        let content = await getManagedContentByTopicsAndContentKeys([digitalMarketPlace], this.topics, this.pageSize, this.managedContentType);
        //console.log('CMS Content child 3------', JSON.parse(JSON.stringify(content)));
        if (content) {
            this.digitalMarketplaceBody = {
                body: content[0].body ? this.htmlDecode(content[0].body.value) : '',
            }
        }
        this.digitalMarketplaceBody = this.htmlDecode(this.digitalMarketplaceBody.body);
        //console.log('digitalMarketplaceBody----', this.digitalMarketplaceeBody);
    }
    handleDreamshopNavigation() {
        this.navigate(dreamshopUrl, {});
    }


    preInitialize = async () => {
        //console.log('ownMyAccount::preInitialize');
        let isAuto = false;
        let myProducts = await getMyProducts('');
        this.manageSubscriptionProducts = JSON.parse(JSON.stringify(myProducts.products));
        this.manageSubscriptionProducts = this.manageSubscriptionProducts.sort(function (a, b) { return parseInt(b.year) - parseInt(a.year) });
        this.manageSubscriptionProducts.forEach(product => {
            if (product.divisionId === 'A' || product.divisionId === 'B') {
                isAuto = true;
            }
            product.image = product.customerUploadedImage ? product.customerUploadedImage : product.productDefaultImage ? product.productDefaultImage : product.image.includes('motorcycle/') ? product.image.replace('motorcycle/', '') : product.image;
        });
        if (!isAuto) {
            let subsTabIndex = this.myAccountTabs.findIndex(tb => tb.name == 'Vehicle Data Privacy');
            if (subsTabIndex > -1) {
                this.myAccountTabs.splice(subsTabIndex, 1);
                this.myAccountTabs.forEach((val, indx) => {
                    val.index = indx;
                });
            }
        }
        //console.log('all products: ', this.manageSubscriptionProducts);
        this.manageSubscriptionProducts = this.manageSubscriptionProducts.filter(prod => {
            return prod.productIdentifier && prod.productIdentifier != '';
        });
        //console.log('vin products: ', this.manageSubscriptionProducts);
        if (this.manageSubscriptionProducts.length > 0) {
            // Alexander Dzhitenov (Wipro) DOE-6177
            // this.loadTabs(true);
            // this.showSpinner = false;
            // console.log('ownMyAccount::End spinner statement');
            // await this.sleep(100);
            this.initializeManageSubscriptions();
        } else {
            // Alexander Dzhitenov (Wipro): Remove spinner from ownProductCarousel if there are no subscriptions to be loaded.
            this.subscriptionsLoaded = true;
            //console.log('ownMyAccount: IF 2');
            let subsTabIndex = this.myAccountTabs.findIndex(tb => tb.name == 'HondaLink & AcuraLink Subscription Status');
            if (subsTabIndex > -1) {
                this.myAccountTabs.splice(subsTabIndex, 1);
                this.myAccountTabs.forEach((val, indx) => {
                    val.index = indx;
                });
            }
            this.loadTabs();
            this.showSpinner = false;
        }
    };

    @track packagesDisplayNames;

    initializeManageSubscriptions = () => {
        //console.log('ownMyAccount::initializeManageSubscriptions');
        //console.log('------InitializeManageSubscription------');
        //console.log('@@manageSubscriptionProducts'+this.manageSubscriptionProducts);
        // this.template.querySelector('c-own-base-spinner').invokeSpinner();
        this.subscriptions = [];
        //let allProductsHasError = true;
        this.manageSubscriptionProducts.forEach((element, index) => {
            getManageSubscriptions({ productIdentifier: element.productIdentifier, divisionId: element.divisionId }).then((result) => {
                //console.log('@@result'+JSON.stringify(result));
                let manageSubs = JSON.parse(JSON.stringify(result));
                if (manageSubs.packages.length == 0) {
                    let pack = {};
                    pack.packageName = 'Error';
                    pack.status = 'DATA UNAVAILABLE';
                    pack.link = '';
                    pack.icon = '';
                    manageSubs.packages.push(pack);
                }
                //console.log('ManageSubscriptions', manageSubs);

                let isError = false;
                let isEditPin = false;
                //console.log('@@this.vehicleInfosm'+JSON.stringify(manageSubs.manageSubscriptions));
                // if (Object.keys(manageSubs.manageSubscriptions).length > 0) {
                //     if (manageSubs.manageSubscriptions.vehicleInfo && manageSubs.manageSubscriptions.vehicleInfo[0]) {
                //         this.vehicleInfos.push(JSON.parse(JSON.stringify(manageSubs.manageSubscriptions.vehicleInfo[0])));
                //         let telematicsPlatform = manageSubs.manageSubscriptions.vehicleInfo[0].telematicsPlatform;
                //         if (telematicsPlatform == '2ZS' || telematicsPlatform == 'MY17' || telematicsPlatform == 'MY23') {
                //             isEditPin = true;
                //         }

                //     }
                //     console.log('@@this.vehicleInfos'+JSON.stringify(this.vehicleInfos));
                //     // if(manageSubs.manageSubscriptions.devices && manageSubs.manageSubscriptions.devices[0].programs[0].role == 'PRIMARY'){
                //     //     isPrimary = true;
                //     // }                  
                // }
                if (manageSubs.vehicleFeature && manageSubs.vehicleFeature.vehicle) {
                    this.vehicleInfos.push(JSON.parse(JSON.stringify(manageSubs.vehicleFeature.vehicle)));
                    let telematicsPlatform = manageSubs.vehicleFeature.vehicle.telematicsPlatform;
                    if (telematicsPlatform == '2ZS' || telematicsPlatform == 'MY17' || telematicsPlatform == 'MY23') {
                        isEditPin = true;
                    }
                    //console.log('@@this.vehicleInfos'+JSON.stringify(this.vehicleInfos));
                }
                if (manageSubs.packages && manageSubs.vehicleFeature && manageSubs.vehicleFeature.vehicle && !nonConnectedPlatformMap.includes(manageSubs.vehicleFeature.vehicle.telematicsPlatform)) {

                    let subscriptionsPackages;
                    if (manageSubs.packages.length == 1 && manageSubs.packages[0].packageName == 'Error') {
                        subscriptionsPackages = manageSubs.packages[0];
                        isError = true;
                    } else {
                        // manageSubs.packages.forEach(pack =>{
                        //     if(pack.packageName == 'Link' && manageSubs.vehicleFeature && manageSubs.vehicleFeature.vehicle && manageSubs.vehicleFeature.vehicle.enrollment == 'N' 
                        //      && (!nonConnectedPlatformMap.includes(manageSubs.vehicleFeature.vehicle.telematicsPlatform) || manageSubs.vehicleFeature.vehicle.telematicsPlatform.includes(zsTelematicsPlatform))){
                        //         isPrimary = true;
                        //     }
                        // });
                        // allProductsHasError = false;
                        subscriptionsPackages = JSON.parse(JSON.stringify(manageSubs.packages));
                    }
                    let allDefaultPackages = JSON.parse(JSON.stringify(manageSubs.allDefaultPackages));
                    allDefaultPackages.forEach(pack => {
                        if (!this.packagesFromManageSubscription.includes(pack.packageName)) {
                            this.packagesFromManageSubscription = [...this.packagesFromManageSubscription, pack.packageName];
                        }
                    });
                    //this.colspan = this.packagesFromManageSubscription.length;         
                    //console.log('This is subscription packages : ', subscriptionsPackages);

                    this.subscriptions.push({
                        colspan: this.packagesFromManageSubscription.length, productId: element.productId,
                        productIdentifier: element.productIdentifier, productName: element.nickname,
                        productImage: element.image,
                        productDivision: element.division,
                        packages: JSON.parse(JSON.stringify(subscriptionsPackages)),
                        isError: isError,
                        isEditPin: isEditPin
                    });
                }

                //console.log('This.subscription : ', this.subscriptions);
                //console.log('colspan ::::: ', this.packagesFromManageSubscription.length);
                if (index == (this.manageSubscriptionProducts.length - 1)) {
                    //console.log('ALL PRODUCT HAS ERROR : ',allProductsHasError);
                    if (this.subscriptions.length > 0) { // && !allProductsHasError
                        this.createSubscriptionsStatusDataForTable();
                    } else {
                        //console.log('Setting this.subscriptionsLoaded 2');
                        this.subscriptionsLoaded = true;
                        let subsTabIndex = this.myAccountTabs.findIndex(tb => tb.name == 'HondaLink & AcuraLink Subscription Status');
                        if (subsTabIndex > -1) {
                            this.myAccountTabs.splice(subsTabIndex, 1);
                            this.myAccountTabs.forEach((val, indx) => {
                                val.index = indx;
                            });
                        }
                    }
                    this.loadTabs();
                    this.showSpinner = false;
                }
            }).catch((err) => {
                //console.log('We are catch block :: ', err);
                if (index == (this.manageSubscriptionProducts.length - 1)) {
                    this.loadTabs();
                    this.showSpinner = false;
                }
            });
        });
    };

    async createSubscriptionsStatusDataForTable() {

        let allPackagesInOrder = await getPackages();
        //console.log(' :::: Packages We Got From APIs :::: ', this.packagesFromManageSubscription);
        //console.log(' :::: Packages We Got From allPackagesInOrder :::: ', allPackagesInOrder);
        let subscriptionsData = [];
        let newPackagesList = [];
        this.packagesDisplayNames = [];
        allPackagesInOrder.forEach(packInOrder => {
            if (this.packagesFromManageSubscription.includes(packInOrder.packageName)) {
                newPackagesList.push(packInOrder.packageName);
                this.packagesDisplayNames.push(packInOrder.packageDisplayName);
                this.subscriptions.forEach(subscriptionRecord => {
                    if (!subscriptionRecord.packages.length && subscriptionRecord.packages.packageName == 'Error') {
                        //console.log('INSIDE PACKAGE AS OBJECT : ', subscriptionsData);
                        if (subscriptionsData.length == 0 || !subscriptionsData.find(record => record.productIdentifier == subscriptionRecord.productIdentifier)) {
                            subscriptionRecord.colspan = JSON.parse(JSON.stringify(this.packagesFromManageSubscription.length));
                            subscriptionsData.push(JSON.parse(JSON.stringify(subscriptionRecord)));
                            //console.log('ADDED ERROR SUBSCRIPTION RECORD : ', subscriptionsData);
                        }
                    } else {
                        let newSubscriptionRecord = subscriptionsData.find(record => record.productIdentifier == subscriptionRecord.productIdentifier);
                        let isNew = false;
                        if (!newSubscriptionRecord) {
                            isNew = true;
                            newSubscriptionRecord = JSON.parse(JSON.stringify(subscriptionRecord));
                            //console.log('New Colspan');
                            newSubscriptionRecord.colspan = JSON.parse(JSON.stringify(this.packagesFromManageSubscription.length));
                            newSubscriptionRecord.packages = [];
                        }
                        let newPackage = subscriptionRecord.packages.find(subscriptionPackage => subscriptionPackage.packageName == packInOrder.packageName);
                        if (!newPackage) {
                            newPackage = {
                                packageDisplayName: packInOrder.packageDisplayName,
                                packageName: packInOrder.packageName,
                                status: 'Not Available',
                                icon: 'utility:clear'
                            };
                        }
                        if (!newSubscriptionRecord.packages.find(newSubscriptionPackage => newSubscriptionPackage.packageName == newPackage.packageName)) {
                            newSubscriptionRecord.packages.push(JSON.parse(JSON.stringify(newPackage)));
                        }

                        if (isNew) {
                            subscriptionsData.push(newSubscriptionRecord);
                        }
                        //console.log('This is subscriptionsData :::::: ', subscriptionsData);
                        //console.log('This is subscriptionRecord.packages : ', subscriptionRecord.packages);

                    }
                });
            }
        });
        this.packagesFromManageSubscription = JSON.parse(JSON.stringify(newPackagesList));
        //console.log('This is new Subscription Data : ', subscriptionsData);
        this.subscriptions = JSON.parse(JSON.stringify(subscriptionsData));
        //console.log('Setting this.subscriptionsLoaded 1');
        this.subscriptionsLoaded = true;
    }



    async getTabs() {

        await showCasesTab().then((result) => {
            //console.log('$showCasesTab-result: ',result);
            if(!result){
                let caseTab = this.myAccountTabs.findIndex(tb => tb.name == "My Support Cases");
                if (caseTab > -1) {
                    this.myAccountTabs.splice(caseTab, 1);
                    this.myAccountTabs.forEach((val, indx) => {
                        val.index = indx;
                    });
                }
            }
        }).catch((error) => {
            //console.error('$showCasesTab-error: ',error);
        });

        //console.log('ownMyAccount::getTabs');
        let myProducts = await getMyProducts('');
        let products = JSON.parse(JSON.stringify(myProducts.products));
        if (!products || products.length == 0) {
            let vdpTabIndex = this.myAccountTabs.findIndex(tb => tb.name == "Vehicle Data Privacy");
            if (vdpTabIndex > -1) {
                this.myAccountTabs.splice(vdpTabIndex, 1);
                this.myAccountTabs.forEach((val, indx) => {
                    val.index = indx;
                });
            }
        }
        products = products.filter(product => { return product.productIdentifier != null; });
        //console.table(products);
        if (!products || products.length == 0) {
            this.prepareTabs();
        }
        let loopCount = 0;
        products.forEach(product => {
            getFeatureListByProductIdentifier({ productIdentifier: product.productIdentifier, divisionId: product.divisionId }).then((result) => {
                //console.log(result.feature);
                result.feature.forEach(feature => {
                    if (!this.showFeaturesTab) {
                        this.showFeaturesTab = feature.status != 'Not Available' ? true : false;
                    }
                    //console.log(feature.status);
                });
                loopCount = loopCount + 1;
                //console.log(loopCount);
                if (loopCount == products.length) {
                    this.prepareTabs();
                }
            }).catch((err) => {
                loopCount = loopCount + 1;
                //console.log(loopCount);
                //console.error('Component.OwnMyAccount: line 301', err);
                if (loopCount == products.length) {
                    this.prepareTabs();
                }
            });
        });
    }

    async prepareTabs() {
        //console.log('ownMyAccount::prepareTabs');
        if (!this.showFeaturesTab) {
            let ftrTabIndex = this.myAccountTabs.findIndex(tb => tb.name == "Linked Accounts & Connected Features");
            if (ftrTabIndex > -1) {
                this.myAccountTabs.splice(ftrTabIndex, 1);
                this.myAccountTabs.forEach((val, indx) => {
                    val.index = indx;
                });
            }
        }

        if (!this.isGuest) {
            await this.preInitialize();

        }

    }

    loadTabs() {
        
        const tabset = [];
        
        let deafulTab = 0;
        if (MYACCOUNT_TAB_MAP.get(this.tabKey) && this.myAccountTabs.findIndex(tb => tb.index == MYACCOUNT_TAB_MAP.get(this.tabKey).index) !== -1) {
            deafulTab = MYACCOUNT_TAB_MAP.get(this.tabKey).index;
        }
        
        let default_selected_tab = sessionStorage.getItem('defaulttab');
        default_selected_tab = this.tabKey && this.tabKey != 'account' ? this.tabKey : default_selected_tab;
        //console.log('$default_selected_tab: ',default_selected_tab);
        
        if(default_selected_tab){
            deafulTab = this.myAccountTabs.findIndex(tb => tb.name == default_selected_tab);
            sessionStorage.removeItem('defaulttab');
            /* if(default_selected_tab == 'My Support Cases'){
                sessionStorage.setItem('caseNumberDetail', '12636544');
            } */
        }
        
        for (let i = 0; i < this.myAccountTabs.length; i++) {
            if (this.myAccountTabs[i].index === deafulTab) {
                this.tab = this.myAccountTabs[i].name;
                if (FORM_FACTOR === 'Small') {
                    if (this.isAutoLinkSubscriptionStatus) {
                        this.showSubscriptionStatusCss = 'show-subscription-status';
                    } else {
                        this.showSubscriptionStatusCss = 'hide-subscription-status';
                    }
                    this.showTabSet = false;
                }
            }
            tabset.push({
                value: `${this.myAccountTabs[i].name}`,
                label: `${this.myAccountTabs[i].label}`,
                id: `${i}___item`,
                control: `tab-${i}`,
                content: `Tab Content ${i}`,
                ariaselected: this.myAccountTabs[i].index === deafulTab ? true : false,
                tabindex: this.myAccountTabs[i].index === deafulTab ? deafulTab : -1,
                itemclass: this.myAccountTabs[i].index === deafulTab ? 'slds-vertical-tabs__nav-item ' + CSS_SLDS_IS_ACTIVE : 'slds-vertical-tabs__nav-item',
                contentclass: this.myAccountTabs[i].index === deafulTab ? 'slds-p-horizontal_large slds-vertical-tabs__content ' + CSS_SLDS_SHOW : 'slds-p-horizontal_large slds-vertical-tabs__content ' + CSS_SLDS_HIDE,
            });

        }
        this.tabs = JSON.parse(JSON.stringify(tabset));
    }

    handleActive(event) {
        this.tab = event.currentTarget.dataset.value;
        //console.log(this.tab);
        //console.log('$CRRS: tab: ',this.tab);
        if(this.tab == 'My Support Cases'){
            //console.log('$CRRS: Checkpoint 1');
            this.template.querySelectorAll('c-own-my-cases').forEach(element => {
                element.hideCaseDetail();
            });
        }
        let page = { sub_section2: event.currentTarget.dataset.value };
        let message = { eventType: DATALAYER_EVENT_TYPE.LOAD, page: page };
        this.publishToChannel(message);
        this.template.querySelectorAll(".tabs li").forEach(li => {
            li.classList.remove(CSS_SLDS_IS_ACTIVE);
            li.firstChild.setAttribute('aria-selected', 'false');
            li.firstChild.setAttribute('tabindex', '-1');
            if (li.dataset.id === event.currentTarget.dataset.id) {
                li.classList.add(CSS_SLDS_IS_ACTIVE);
                li.firstChild.setAttribute('aria-selected', 'true');
                li.firstChild.setAttribute('tabindex', '0');
            }
        });
    }

    handleSelect(event) {
        this.tab = event.currentTarget.dataset.value;
        let page = { sub_section2: event.currentTarget.dataset.value };
        let message = { eventType: DATALAYER_EVENT_TYPE.LOAD, page: page };
        this.publishToChannel(message);
        if (this.isAutoLinkSubscriptionStatus) {

            this.showSubscriptionStatusCss = 'show-subscription-status';
        } else {
            this.showSubscriptionStatusCss = 'hide-subscription-status';
        }
        this.showTabSet = false;

    }

    backToTabs() {
        this.showTabSet = true;
    }


    handleOnEditAddress(event) {
        this.tab = 'Edit Address';
    }

    handleOnAddressChangeCancel() {
        this.tab = 'Account Information';
    }

    get isAccountInformation() { return (this.tab === 'Account Information' && !this.isGuest); }
    get isAutoLinkSubscriptionStatus() { return this.tab === 'HondaLink & AcuraLink Subscription Status'; }
    get isLinkedAccountsAndConnectedFeatures() { return this.tab === 'Linked Accounts & Connected Features'; }
    get isVehicleDataPrivacy() { return this.tab === 'Vehicle Data Privacy'; }
    get isCommunicationPreferences() { return this.tab === 'Communication Preferences'; }
    get isDigitalMarketplace() { return this.tab === 'Dreamshop'; }
    get isFinance() { return this.tab === 'Finance'; }
    get isShowEditAddress() { return this.tab === 'Edit Address'; }
    get isCasesList() { return (this.tab === 'My Support Cases' && !this.isGuest); }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
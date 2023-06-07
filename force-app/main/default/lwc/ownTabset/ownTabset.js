//============================================================================
// Title:    Honda MyGarage Experience - Tabset
//
// Summary:  This is the Tabset html seen at the page of the Honda MyGarage Community
//
// Details:  Tabset for pages
//
// History:
// November 5, 2021 Arunprasad N (Wipro) Original Author
//===========================================================================
import { api, LightningElement, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getProductTabs from '@salesforce/apex/OwnProductController.getProductTabs';
import { ISGUEST, getProductContext, setProductContextUser, getOrigin, getRecalls } from 'c/ownDataUtils'; //DOE-4619 Ravindra Ravindra
import getFeatureListByProductIdentifier from '@salesforce/apex/OwnAPIController.getFeatureListByProductIdentifier';
import update_UserIsKeyFeatureEnabled from '@salesforce/apex/OwnContextController.update_UserIsKeyFeatureEnabled';
import update_UserHideVehicleSoftwareUpdate from '@salesforce/apex/OwnContextController.update_UserHideVehicleSoftwareUpdate';
import update_UserIsRecallsEnabled from '@salesforce/apex/OwnRecallsController.update_UserIsRecallsEnabled';
import update_UserHasWarranty from '@salesforce/apex/OwnWarrantyController.update_UserHasWarranty';
import updateUserHasVHR from '@salesforce/apex/ownMaintenanceMinderController.updateUserHasVHR';
import getCompleteDetails from '@salesforce/apex/OwnAPIController.getCompleteDetails';
import update_UserHasHowToGuides from '@salesforce/apex/OwnHowToGuidesController.update_UserHasHowToGuides';
import mygarageurl from '@salesforce/label/c.MyGarageURL';
import getServiceAppointments from '@salesforce/apex/OwnAPIController.getServiceAppointments';
import update_UserHasUpcomingAppointments from '@salesforce/apex/OwnContextController.update_UserHasUpcomingServiceAppointments';
import generatorCodes from '@salesforce/label/c.Generator_Product_Line_Codes';
import getCategoryCode from '@salesforce/apex/OwnEConfigApiHelper.getCategoryCode';
import update_ShowMIMO from '@salesforce/apex/OwnHowToGuidesController.update_ShowMIMO';
import getProductSupportVideos from '@salesforce/apex/OwnHelpCenterController.getProductSupportVideos';
import update_HasProductSupportVideo from '@salesforce/apex/OwnContextController.update_HasProductSupportVideo';

const CSS_SLDS_IS_ACTIVE = 'slds-is-active';
const CSS_SLDS_SHOW = 'slds-show';
const CSS_SLDS_HIDE = 'slds-hide';

export default class OwnTabset extends OwnBaseElement {
    @track tabs = [];
    @api tab;
    @track context;
    @track divisionId; //DOE-4619 Ravindra Ravindra 
    @track isSearchedProduct; //DOE-4619 Ravindra Ravindra
    @api divisionName;
    @track allGeneratorCodes;
    @track productTabs;

    connectedCallback() {
        this.initialize();
    }

    initialize = async () => {
        if (getOrigin() == 'ProductChooser') {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }

        //DOE-4619 Ravindra Ravindra
        this.isSearchedProduct = getOrigin() === 'ProductChooser' && !ISGUEST;
        let searchedProducts = JSON.parse(localStorage.getItem('garage'));
        sessionStorage.setItem('frompage', 'My Products');
        //console.log('@@@context', this.context)
        if (this.isSearchedProduct && searchedProducts && searchedProducts.products && searchedProducts.products[0]) {
            this.divisionId = searchedProducts.products[0].divisionId;
        } else if (this.context && this.context.product) {
            this.divisionId = this.context.product.divisionId;
        }
        if (sessionStorage.getItem('fromhowtoguides')) {
            sessionStorage.removeItem('fromhowtoguides');
        }
        this.allGeneratorCodes = generatorCodes ? generatorCodes.split(',') : [];
        //console.log('allGeneratorCodes--->', this.allGeneratorCodes);
        this.filterTabs(this.productTabs);
    };

    @wire(getProductTabs)
    wiredGetProductTabs({ error, data }) {
        if (data) {
            const tabs = [];
            for (let i = 0; i < data.length; i++) {
                tabs.push({
                    value: `${data[i]}`,
                    label: `${data[i]}`,
                    id: `${i}___item`,
                    control: `tab-${i}`,
                    content: `Tab Content ${i}`,
                    ariaselected: data[i] === this.tab ? true : false,
                    tabindex: data[i] === this.tab ? 0 : -1,
                    itemclass: data[i] === this.tab ? 'slds-tabs_default__item ' + CSS_SLDS_IS_ACTIVE : 'slds-tabs_default__item',
                    contentclass: data[i] === this.tab ? 'slds-tabs_default__content ' + CSS_SLDS_SHOW : 'slds-tabs_default__content ' + CSS_SLDS_HIDE,
                });
            }
            this.productTabs = tabs;
            this.filterTabs(this.productTabs);
        } else if (error) {
            this.showToast_error(error);
        }

    }

    filterTabs(tabs) {
        //DOE-5172 START-Remove when all tabs needs to be shown.
        //console.log('divisionName', this.divisionName);
        if (tabs && this.context && this.context.product) {
            if (this.divisionName == 'Powerequipment') {
                getCategoryCode({ vinNumber: this.context.product.vin, poiType: this.context.product.divisionId, divisionName: this.context.product.division })
                    .then(result => {
                        //console.log('categoryCd:: ' + result)
                        let categoryCd = result;
                        //console.log('--->', !this.allGeneratorCodes.includes(categoryCd));
                        if (this.divisionName == 'Powerequipment' && (!categoryCd || !this.allGeneratorCodes.includes(categoryCd))) {
                            if (tabs) {
                                tabs = tabs.filter(function (el) {
                                    return el.value == 'Overview' || el.value == 'Service & Maintenance' || el.value == 'Marketplace' || el.value == 'Finance' || el.value == 'Resources & Downloads'
                                });
                            }
                        } else {
                            if (tabs) {
                                tabs = tabs.filter(function (el) {
                                    return el.value == 'Overview' || el.value == 'Service & Maintenance' || el.value == 'Connected Features' || el.value == 'Marketplace' || el.value == 'Finance' || el.value == 'Resources & Downloads'
                                });
                            }
                        }
                        this.tabs = tabs;
                        //console.log('tabs0', this.tabs)
                    })
                    .catch(error => {
                        //console.log(error);
                        if (tabs) {
                            tabs = tabs.filter(function (el) {
                                return el.value == 'Overview' || el.value == 'Service & Maintenance' || el.value == 'Connected Features' || el.value == 'Marketplace' || el.value == 'Finance' || el.value == 'Resources & Downloads'
                            });
                        }
                        this.tabs = tabs;
                        //console.log('tabs0', this.tabs)
                    })
            } else {
                if (this.context.product.divisionId == 'M' && !this.context.product.model.toLowerCase().includes('gold wing') && !(this.context.product.model.toLowerCase().includes('africa twin') && this.context.product.year > 2020)) {
                    if (tabs) {
                        tabs = tabs.filter(function (el) {
                            return el.value == 'Overview' || el.value == 'Service & Maintenance' || el.value == 'Marketplace' || el.value == 'Finance' || el.value == 'Resources & Downloads'
                        });
                    }
                } else {
                    if (tabs) {
                        if(this.divisionId === 'A' || this.divisionId === 'B'){
                            tabs = tabs.filter(function (el) {
                                return el.value == 'Overview' || el.value == 'Service & Maintenance' || el.value == 'Connected Features' || el.value == 'Marketplace' || el.value == 'Finance' || el.value == 'Resources & Downloads'
                            });
                        }else{
                            tabs = tabs.filter(function (el) {
                                return el.value == 'Overview' || el.value == 'Service & Maintenance' || el.value == 'Connected Features' || el.value == 'Marketplace' || el.value == 'Finance' || el.value == 'Resources & Downloads'
                            });
                        }
                    }
                }
                this.tabs = tabs;
                //console.log('tabs0', this.tabs)
            }
        }
        //DOE-5172 END
    }

    handleActive(event) {
        let sameTabFlag = event.currentTarget.dataset.value === this.tab ? true : false;
        //console.log('this.tab', this.tab);
        //console.log('this.tab', event.currentTarget.dataset.value);
        if (!sameTabFlag) {
            this.tab = event.currentTarget.dataset.value;
            //DOE-4619 Ravindra Ravindra
            if (!this.isSearchedProduct) {
                const contextInput = {
                    'productId': this.context.productId,
                    'productTab': this.tab
                };
                setProductContextUser(contextInput);
            }

            if (this.tab == 'Connected Features' || this.tab == 'Service & Maintenance') {
                this.handleConnectedFeatures();
                if(this.tab == 'Service & Maintenance')
                    this.handlePreServiceMaintananceRedirect();
            } else if (this.tab == 'Service & Maintenance') {
                this.handlePreServiceMaintananceRedirect();
            } else if (this.tab == 'Resources & Downloads' && (this.context.product.divisionId == 'A' || this.context.product.divisionId == 'B' || this.context.product.divisionId == 'P')) {
                //console.log('RD A&B')
                this.handlePreResourcesDownloadsRedirect();
            } else {
                //console.log('RD not A&B')
                this.handleTabNavigation();
            }
        }
    }
    async handleConnectedFeatures() {
        let categoriesData = [];
        if (this.context.product) {
            var hasupdate = false;
            var year = this.context.product.year;
            if (year !== null) {
                //console.log('year' + year);
                await getCompleteDetails({ divisionId: this.context.product.divisionId, modelYear: this.context.product.year, model: this.context.product.model })
                    .then((data) => {
                        if (data && data.error) {
                            update_UserHideVehicleSoftwareUpdate({ hide: true });
                            update_UserHasHowToGuides({ hasHowToGuides: false });
                        } else {
                            data.feature.forEach(element => {
                                if (element.id.trim() == 'system-updates' || element.title.trim() == 'System Updates' || element.title.trim() == 'System Software Updates') {
                                    //console.log('has update');
                                    hasupdate = true;
                                    update_UserHideVehicleSoftwareUpdate({ hide: false });
                                }
                                //DOE-6219 How-to-Guides for Autos - Yusuf
                                let title = element.title.replace('&reg;', '');
                                if ((this.context.product.divisionId == 'A' && element.id.toLowerCase().includes('hondalink')) || (this.context.product.divisionId == 'B' && element.id.toLowerCase().includes('acuralink'))) {
                                    element.view = element.view.filter(ele => ele.type);
                                    element.view.forEach(viewEle => {
                                        viewEle.category = element.title;
                                        if (!viewEle.title) {
                                            viewEle.title = element.title;
                                        }
                                    });
                                    categoriesData.push({
                                        title: element.title,
                                        features: element.view
                                    });
                                }
                            })
                            if (!categoriesData && categoriesData.length == 0) {
                                update_UserHasHowToGuides({ hasHowToGuides: false });
                            } else {
                                update_UserHasHowToGuides({ hasHowToGuides: true });
                                //console.log('categoriesData-->', categoriesData);
                                sessionStorage.setItem('CFhowtoguides', JSON.stringify(categoriesData));
                            }
                        }
                    })
                    .catch((error) => {
                        //console.log('error' + error);
                        update_UserHideVehicleSoftwareUpdate({ hide: true });
                        update_UserHasHowToGuides({ hasHowToGuides: false });
                    })
                if (!hasupdate) {
                    await update_UserHideVehicleSoftwareUpdate({ hide: true });
                }
            } else {
                await update_UserHideVehicleSoftwareUpdate({ hide: true });
                await update_UserHasHowToGuides({ hasHowToGuides: false });
            }
        }
        if (!ISGUEST && this.context && this.context.product && (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-'))) {
            let vin = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
            await getFeatureListByProductIdentifier({ productIdentifier: vin, divisionId: this.context.product.divisionId }).then((result) => {
                let hasFeatures = false;
                result.feature.forEach(featr => {
                    //console.log(featr.status);
                    if (!hasFeatures) {
                        hasFeatures = featr.status != 'Not Available' ? true : false;
                    }
                });
                //console.log(hasFeatures);
                update_UserIsKeyFeatureEnabled({ hasFeatures: hasFeatures })
                    .then((result) => {
                        //console.log(result);
                        this.handleTabNavigation();
                    }).catch(error => {
                        //console.log(error);
                        this.handleTabNavigation();
                    });
            }).catch((err) => {
                //console.log(err);
                this.handleTabNavigation();
            });
        } else {
            setTimeout(() => {
                this.handleTabNavigation();
            }, 2000);
        }
    }
    async handlePreResourcesDownloadsRedirect() {
        let categoriesData = [];
        let allCategoriesData = [];
        //console.log('RD Context')
        if (this.context && this.context.product && (this.context.product.divisionId == 'A' || this.context.product.divisionId == 'B')) {
            // this.divisionId = context.product.divisionId;
            let response = await getCompleteDetails({ divisionId: this.context.product.divisionId, modelYear: this.context.product.year, model: this.context.product.model });
            //console.log(' RD response -->', response);
            if (response && response.error == true) {
                await update_UserHasHowToGuides({ hasHowToGuides: false }).then((res) => {
                    //console.log('RD updated hasHowToGuides', res)
                }).catch((err) => {
                    //console.log('RD error in updating has How to guides', JSON.stringify(err))
                });
                //console.log('RD error in response', JSON.stringify(response.error))
            } else {
                for (let i = 0; i < (response.feature.length >= 4 ? 4 : response.feature.length); i++) {
                    let element = response.feature[i];
                    //console.log('RD response 1-->>>', element)
                    element.view = element.view.filter(ele => ele.data);
                    element.view.forEach(viewEle => {
                        viewEle.category = element.title;
                        if (!viewEle.title) {
                            viewEle.title = element.title;
                        }
                    });
                    let categoryTitle = element.title;
                    categoriesData.push(categoryTitle);
                    allCategoriesData.push({
                        title: element.title,
                        features: element.view
                    });
                }
            }
            if (categoriesData.length !== 0) {
                await update_UserHasHowToGuides({ hasHowToGuides: true }).then((res) => {
                    //console.log('RD updated hasHowToGuides', res)
                    sessionStorage.setItem('R&Dhowtoguides', JSON.stringify(categoriesData));
                    sessionStorage.setItem('R&Dallhowtoguides', JSON.stringify(allCategoriesData));
                }).catch((err) => {
                    //console.log('RD error in updating has How to guides', JSON.stringify(err))
                });
            }
        }
        if (this.context && this.context.product && this.context.product.vin && (this.context.product.divisionId == 'P' && (this.context.product.division == 'Powerequipment' || this.context.product.division == 'Power Equipment'))) {
            let productLineCode = await getCategoryCode({ vinNumber: this.context.product.vin, poiType: this.context.product.divisionId, divisionName: this.context.product.division });
            if (productLineCode == 'AM') {
                await update_ShowMIMO({ showMIMO: true }).then((res) => {
                    //console.log('RD updated showMIMO ', res, productLineCode)
                }).catch((err) => {
                    //console.log('RD error in showMIMO ', JSON.stringify(err))
                });
            }
            else {
                await update_ShowMIMO({ showMIMO: false }).then((res) => {
                    //console.log('RD updated showMIMO else', res, productLineCode)
                }).catch((err) => {
                    //console.log('RD error in showMIMO else', JSON.stringify(err))
                });
            }
        }
        if (this.context && this.context.product && this.context.product.divisionId == 'P') {
            let productLineCode = '';
            if (!document.location.pathname.includes('help') && this.context && this.context.product && this.context.product.vin && (this.context.product.divisionId == 'P' && (this.context.product.division == 'Powerequipment' || this.context.product.division == 'Power Equipment'))) {
                productLineCode = await getCategoryCode({ vinNumber: this.context.product.vin, poiType: this.context.product.divisionId, divisionName: this.context.product.division });
            }
            //console.log('productLineCode', productLineCode);
            let productSupportVideos = await getProductSupportVideos({ categoryCode: productLineCode });
            //console.log('productSupportVideos :: ', productSupportVideos.length);
            if(productSupportVideos.length > 0){
                await update_HasProductSupportVideo({ hasVideos: true }).then((res) => {
                    //console.log('productSupportVideos', res, productLineCode)
                }).catch((err) => {
                    //console.log('productSupportVideos', JSON.stringify(err))
                });
            }else{
                await update_HasProductSupportVideo({ hasVideos: false }).then((res) => {
                    //console.log('productSupportVideos', res, productLineCode)
                }).catch((err) => {
                    //console.log('productSupportVideos', JSON.stringify(err))
                });
            }
        }

        this.handleTabNavigation();
    }
    async handlePreServiceMaintananceRedirect() {

        if (this.context && this.context.product) {

            //Recalls: start
            if (this.context.product.recallCount) {
                let hasRecalls = this.context.product.recallCount > 0 ? true : false;
                await update_UserIsRecallsEnabled({ hasRecalls: hasRecalls }).then((res) => {
                    //console.log('User recalls update : success', res);
                }).catch((err) => {
                    //console.log('User recalls update : err', err);
                });
            } else {
                let recallsData = await getRecalls(this.context);
                let hasRecalls = recallsData.length > 0 ? true : false;
                await update_UserIsRecallsEnabled({ hasRecalls: hasRecalls }).then((res) => {
                    //console.log('User recalls update : success1', res);
                }).catch((err) => {
                    //console.log('User recalls update : err1', err);
                });
            }
            //Recalls: End

            //Warranty: start
            let isPSP = this.context.product.division === 'Motorcycle/Powersports' || this.context.product.division === 'Powersports' ? true : false;
            let vinNumber;
            if (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-'))
                vinNumber = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
            await update_UserHasWarranty({ vinNumber: vinNumber ?? '', modelId: this.context.product.modelId, isPSP: isPSP }).then((result) => {
                //console.log('User warranty update : success', result);
            }).catch((err) => {
                //console.log('User warranty update : error', err);
            });
            //Warranty: end

            //Vehicle Health Report: start
            let productId;
            let ownershipId;
            if (this.context.product.ownershipId && this.context.product.productId) {
                ownershipId = this.context.product.ownershipId;
                productId = this.context.product.productId;
            }
            await updateUserHasVHR({ ownershipId: ownershipId ?? '', productId: productId ?? '' }).then((result) => {
                //console.log('updateUserHasVHR: success', result);
            }).catch((err) => {
                console.error('updateUserHasVHR: err', err);
            });
            //Vehicle Health Report: End
            //Upcoming Service Appointment
            if (!ISGUEST) {
                let hasUpcomingAppointments = false;
                await getServiceAppointments({ divisionId: this.divisionId }).then(response => {
                    //console.log('Service Appointments Response : ', response);
                    if (!response.isError) {
                        let allAppointments = JSON.parse(JSON.stringify(response.appointments));
                        if (allAppointments.length > 0) {
                            hasUpcomingAppointments = true;
                        }
                    }
                }).catch(err => { });
                await update_UserHasUpcomingAppointments({ hasAppointments: hasUpcomingAppointments });
            }

        }
        this.handleTabNavigation();
    }


    //DOE-4619 Ravindra Ravindra
    handleTabNavigation() {
        let url;
        if (this.divisionId && this.tab === 'Overview') {
            if (this.divisionId === 'A') {
                url = '/garage-honda';
            }
            if (this.divisionId === 'B') {
                url = '/garage-acura';
            }
            if (this.divisionId === 'M') {
                url = '/garage-powersports';
            }
            // if (this.divisionId === 'PE') {
            //     url = '/garage-powerequipment';
            // }
            if (this.divisionId === 'P') {
                if (this.context.product.division === 'Powerequipment') {
                    url = '/garage-powerequipment';
                }
                if (this.context.product.division === 'Marine') {
                    url = '/garage-marine';
                }

            }
        }

        //DOE-4503 Ravindra Ravindra (Wipro)
        if (this.divisionId && this.tab === 'Connected Features') {
            if (this.divisionId === 'A') {
                url = '/honda-product-connected-features';
            }
            else if (this.divisionId === 'B') {
                url = '/acura-product-connected-features'
            } else if (this.divisionId === 'M') {
                url = '/powersports-product-connected-features';
            } else if (this.divisionId === 'P') {
                if (this.context.product.division === 'Powerequipment') {
                    url = '/powerequipment-product-connected-features';
                }
                if (this.context.product.division === 'Marine') {
                    url = '/marine-product-connected-features';
                }
            }
        }
        if (this.divisionId && this.tab === 'Service & Maintenance') {
            if (this.divisionId === 'A') {
                url = '/honda-service-maintenance';
                // this.navigate('/garage-honda', {});
            }
            if (this.divisionId === 'B') {
                url = '/acura-service-maintenance';
                // this.navigate('/garage-acura', {});
            }
            if (this.divisionId === 'M') {
                url = '/honda-powersports-service-maintenance';
                // this.navigate('/garage-acura', {});
            }
            // if (this.divisionId === 'PE') {
            //     url = '/honda-power-equipmnt-service-maintenance';
            //     // this.navigate('/garage-acura', {});
            // }
            if (this.divisionId === 'P') {
                if (this.context.product.division === 'Powerequipment') {
                    url = '/honda-power-equipment-service-maintenance';
                }
                if (this.context.product.division === 'Marine') {
                    //console.log('@@@context----->')
                    url = '/honda-marine-service-maintenance';
                }
                // this.navigate('/garage-acura', {});
            }
        }
        if (this.divisionId && this.tab === 'Finance') {
            if (this.divisionId === 'A') {
                url = '/honda-financial-services';
                this.navigate(url, {});
            }
            if (this.divisionId === 'B') {
                url = '/acura-financial-services';
                this.navigate(url, {});
            }
            if (this.divisionId === 'M') {
                url = '/power-sports-financial-services';
                this.navigate(url, {});
            }
            if (this.divisionId === 'P') {
                if (this.context.product.division === 'Powerequipment') {
                    url = '/power-equipment-financial-services';
                }
                if (this.context.product.division === 'Marine') {
                    url = '/marine-financial-services';
                }

            }
        }
        if (this.divisionId && this.tab == 'Resources & Downloads') {
            //console.log('Resources & Downloads')
            if (this.divisionId === 'A') {
                url = '/honda-resources-downloads';
            }
            if (this.divisionId === 'B') {
                url = '/acura-resources-downloads';
            }
            if (this.divisionId === 'M') {
                url = '/honda-powersports-resources-downloads';
            }
            if (this.divisionId === 'P') {
                if (this.context.product.division === 'Powerequipment') {
                    url = '/honda-power-equipment-resources-downloads';
                }
                if (this.context.product.division === 'Marine') {
                    url = '/honda-marine-resources-downloads';
                }
            }
        }
        if (this.divisionId && this.tab === 'Marketplace') {
            if (this.divisionId === 'A') {
                url = '/honda-marketplace';
            }
            if (this.divisionId === 'B') {
                url = '/acura-marketplace';
            }
            if (this.divisionId === 'M') {
                url = '/honda-powersports-marketplace';
            }
            if (this.divisionId === 'P') {
                if (this.context.product.division === 'Powerequipment') {
                    url = '/honda-power-equipment-marketplace';
                }
                if (this.context.product.division === 'Marine') {
                    url = '/honda-marine-marketplace';
                }
            }
        }
        if (url) {
            //url = '/s' + url;
            let mygarageURLLabel = mygarageurl === '/' ? '' : mygarageurl;
            window.open(mygarageURLLabel + '/s' + url, '_self');
        }
    }

    handleChange(event) {
        //console.log('@@this.tab: ', this.tab);
        let sameTabFlag = event.detail.value === this.tab ? true : false;
        if (!sameTabFlag) {
            //console.log('@@sameTabFlag: ', sameTabFlag);
            this.tab = event.detail.value;
            //console.log('@@this.tab: ', this.tab);
            // this.handleTabNavigation();
            if (this.tab == 'Resources & Downloads' && (this.context.product.divisionId == 'A' || this.context.product.divisionId == 'B' || this.context.product.divisionId == 'P')) {
                //console.log('@@RD A&B')
                this.handlePreResourcesDownloadsRedirect();
            } else if (this.tab == 'Service & Maintenance') {
                this.handlePreServiceMaintananceRedirect();
            } else {
                //console.log('@@RD not A&B')
                this.handleTabNavigation();
            }
        }
    }
}
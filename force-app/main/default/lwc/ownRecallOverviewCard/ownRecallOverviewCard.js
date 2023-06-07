import { api, track } from 'lwc';
import commonResources from "@salesforce/resourceUrl/Owners";
import { OwnBaseElement } from 'c/ownBaseElement';
import { ISGUEST, getProductContext, getOrigin, getContext } from 'c/ownDataUtils';

import getRecallsByModel from '@salesforce/apex/OwnAPIController.getRecallsByModel';
import getRecallByOwnership from '@salesforce/apex/OwnRecallsController.getRecallByOwnership';
import getRecallsByModelId from '@salesforce/apex/OwnAPIController.getRecallsByModelId';


import getDealerFromObj from '@salesforce/apex/OwnRecallsController.getDealerFromObj';
import getDealerLocator from '@salesforce/apex/OwnAPIController.getDealerLocator';
import getDealerByPoiId from '@salesforce/apex/OwnAPIController.getDealerByPoiId';
import timeHighway from '@salesforce/label/c.TimeHighway';
import xTime from '@salesforce/label/c.XTime';
import updatePromise from '@salesforce/label/c.UpdatePromise';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';

export default class OwnRecallOverviewCard extends OwnBaseElement {
    @api brandName;
    @api title = 'RECALL OVERVIEW';
    @api icon;
    @api titlecolor = 'Black';
    @api brand = 'honda';
    @api actiontitle = 'VIEW ALL';
    @api actionicon;
    @api showFooter;
    @track recallData = [];
    isGuest = ISGUEST;
    totalRecalls = 0;
    @track lastUpdatedDate = '';
    @track showActionButton = true;
    @track showEnterVin = false;
    @track openRecalls = [];
    @track noRecalls = false;
    @track isDataLoading = true;
    @track fromProductChooser;
    @track footer;
    @track showRecallStatus;
    @track ownershipId;
    @track scheduleServiceLink = '';
    context;
    connectedCallback() {
        this.icon = this.myGarageResource() + '/ahmicons/' + this.icon;
        //this.showFooter ? this.footer = this.isGuest ? false : true : false;
        this.initialize();
    }
    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        this.fromProductChooser = fromProductChooser;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getContext('');
        }
        //console.log('Context********', this.context);
        this.ownershipId = this.context.product.ownershipId;
        this.showRecallStatus = this.context.product.divisionId == 'P' ? false : true;
        this.showEnterVin = this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-') ? false : true;
        if (this.isGuest) {
            this.getRecallsFromContext();
        }
        //If user is not Guest
        else {
            // await this.getScheduleServiceLink(this.context.product.ownershipId, this.context.product.divisionId, this.brandName)
            //console.log('!!!ownershipId->>', this.context.product.ownershipId);
            //If user is not guest & doesn't have the ownership of the product then get recalls from context.
            if (!this.context.product.ownershipId || this.context.product.ownershipId == '-' || this.context.product.ownershipId == '' || this.context.product.ownershipId == undefined) {
                //console.log('!!!getRecallByAPI-!isGuest->>', this.context.product.productIdentifier);
                this.getRecallsFromContext();
            }
            //If user is not guest & has the ownership of the product then get recalls from object.
            else {
                //console.log('!!!getRecallByOwnership');
                let recalls = await getRecallByOwnership({ ownership: this.context.product.ownershipId });
                //console.log('sfdc recalls', recalls);
                this.totalRecalls = recalls.length;
                for (let i = 0; i < (recalls.length > 3 ? 3 : recalls.length); i++) {
                    let recall = {
                        title: recalls[i].Message__r.Subject__c,
                        campaignId: recalls[i].Message__r.Source_Id__c,
                        source: 'object',
                        issueDate: this.formatDate(recalls[i].Message__r.Start_Date__c, 'object'),
                        status: this.extractRecallStatus(recalls[i].Message__r.Body__c),
                    };
                    this.openRecalls.push(recall);
                }
                if (this.totalRecalls == 0) { this.showActionButton = false; this.noRecalls = true }
                this.isDataLoading = false;
                //console.log('showActionButton', this.totalRecalls, this.showActionButton, this.noRecalls, this.isDataLoading)
                //console.log('!!!getRecallByOwnership-->>', this.openRecalls);

            }
        }
        let date = new Date();
        let lastUpdatedDate = date.toLocaleDateString("en-GB", { year: "numeric", month: "2-digit", day: "2-digit", });
        lastUpdatedDate = lastUpdatedDate.split('/')[1] + '/' + lastUpdatedDate.split('/')[0] + '/' + lastUpdatedDate.split('/')[2];
        this.lastUpdatedDate = lastUpdatedDate;
    }

    getRecallsFromContext() {
        //console.log('recalls from context', this.context.product.recalls)
        if (this.context.product.recalls) {
            let recalls = this.context.product.recalls;
            this.totalRecalls = recalls.length;
            for (let i = 0; i < (recalls.length > 3 ? 3 : recalls.length); i++) {
                let recall = {
                    title: recalls[i].campaignDescription,
                    campaignId: recalls[i].campaignID,
                    source: 'context',
                    issueDate: this.formatDate(recalls[i].campaignStartDate, 'context'),
                    status: this.context.product.divisionId == 'P' ? '' : recalls[i].mfrRecallStatus.value,
                };
                this.openRecalls.push(recall);
            }
        }
        else {
            this.showActionButton = false; this.noRecalls = true
        }
        this.isDataLoading = false;
    }

    extractRecallStatus(str) {
        let startIndex = str.search('<b>Recall Status: </b>') + 22;
        let endIndex = str.indexOf('<br>', startIndex);
        //console.log(str.slice(startIndex, endIndex));
        return str.slice(startIndex, endIndex);
    }

    formatDate(date, source) {
        let recordDate;
        if (source === 'object') {
            recordDate = date.split('T')[0];
        }
        else {
            recordDate = date;
        }

        if (!recordDate.includes('-')) {
            recordDate = recordDate.substring(0, 4) + '-' + recordDate.substring(4, 6) + '-' + recordDate.substring(6, 8);
        }

        //console.log('recordDate', recordDate);
        let newDate = recordDate.split('-')[1].toString() + '/' + recordDate.split('-')[2].toString() + '/' + recordDate.split('-')[0];
        //console.log('new date', newDate);
        return newDate;
    }

    async handleAction() {
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: this.title + (this.showActionButton ? ':' + this.actiontitle : '')
        };
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
        this.publishToChannel(message);

        let divisionName = this.context.product.division == 'Powerequipment' ? 'Power Equipment' : this.context.product.division;
        let label = window.location.href.includes('service') ? divisionName + ': Service & Maintenance' : divisionName + ': Overview';
        let backLink = {
            label: label,
            url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
        };
        sessionStorage.setItem('backlink', JSON.stringify(backLink));
        await this.sleep(2000);

        this.navigate('/recalls-detail', {});
        
    }
    handleRecallRedirect(event) {
        let divisionName = this.context.product.division == 'Powerequipment' ? 'Power Equipment' : this.context.product.division;
        let label = window.location.href.includes('service') ? divisionName + ': Service & Maintenance' : divisionName + ': Overview';
        let backLink = {
            label: label,
            url: window.location.pathname.substring(window.location.pathname.lastIndexOf('/')) + window.location.search
        };
        sessionStorage.setItem('backlink', JSON.stringify(backLink));
        this.navigate('/recalls-detail?campaignId=' + event.currentTarget.dataset.campaignid + '&source=' + event.currentTarget.dataset.source, {});
    }

    handleFooter() {
        if (this.scheduleServiceLink.includes('/find-a-dealer')) {
            let brandName = this.context.product.division == 'Powerequipment' ? 'Power Equipment' : this.context.product.division;
            sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: brandName, divisionId: this.context.product.divisionId }));
            this.navigate('/find-a-dealer', {});
        } else {
            this.navigate(this.scheduleServiceLink, {});
        }

    }
    handleEditVin() {
        sessionStorage.setItem('fromRecallCard', true);
        this.navigate('/enter-vin', {});
    }
    handleNoRecall() {
        let url = '';
        if (this.context.product.division === 'Motorcycle/Powersports' || this.context.product.division === 'Powersports') {
            url = '/recall-search?brand=powersports';
        }
        else if (this.context.product.division === 'Acura') {
            url = '/recall-search?brand=acura';
        }
        else if (this.context.product.division === 'Honda') {
            url = '/recall-search?brand=honda';
        }
        else if (this.context.product.division === 'Marine') {
            url = '/recall-search?brand=marine';
        }
        else if (this.context.product.division === 'Powerequipment') {
            url = '/recall-search?brand=powerequipment';
        }
        this.navigate(url, {});
    }

    async getScheduleServiceLink(ownershipId, POItype, brand) {
        //console.log('@@@parameters', ownershipId, POItype, brand);
        let latitude;
        let longitude;
        let serviceSchedulingUrl = '';
        getDealerFromObj({ ownershipId: ownershipId }).then(res => {
            let POIid = res;
            if (POIid != '') {
                //get dealer for POIid
                //console.log('@@@POIid Not NULL', POIid);
                getDealerByPoiId({ poiId: POIid, poiType: POItype, ownershipId: '', brand: brand, latitude: '', longitude: '' }).then(res => {
                    if (res.error) {
                        this.footer = this.showFooter ? this.isGuest ? false : false : false;
                        //console.log('@@@error in > getDealerByPoiId ', res.error)
                    }
                    let dealerResult = JSON.parse(JSON.stringify(res.poiResponse.pois.poi));
                    //console.log('@@@result after stringify', dealerResult);
                    dealerResult[0].attributes.attribute.forEach(attributeValue => {
                        if (!serviceSchedulingUrl && attributeValue.code == '47') {
                            //console.log('@@@timeHighway');
                            serviceSchedulingUrl = timeHighway;
                        } else if (!serviceSchedulingUrl && attributeValue.code == '48') {
                            //console.log('@@@xTime');
                            serviceSchedulingUrl = xTime;
                        } else if (!serviceSchedulingUrl && attributeValue.code == '49') {
                            //console.log('@@@updatePromise');
                            serviceSchedulingUrl = updatePromise;
                        }
                    });
                    //console.log('@@@serviceSchedulingUrl', serviceSchedulingUrl);
                    if (serviceSchedulingUrl == '') {
                        this.footer = this.showFooter ? this.isGuest ? false : false : false;
                    } else {
                        this.scheduleServiceLink = serviceSchedulingUrl;
                        this.footer = this.showFooter ? this.isGuest ? false : true : false;
                    }
                    //console.log('@@@scheduleServiceLink', this.scheduleServiceLink)
                }).catch(err => {
                    //console.log('@@@ error getDealerByPoiId ', err);
                    this.footer = this.showFooter ? this.isGuest ? false : false : false;
                });

            }
            else {
                //console.log('@@@POIid is NULL', POIid);
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(position => {
                        this.latitude = position.coords.latitude;//.replace(/\s+/g, '');
                        this.longitude = position.coords.longitude;//.replace(/\s+/g, '');
                        //console.log('@@User location-->>>>', this.latitude, this.longitude);
                        getDealerLocator({ latitude: latitude, longitude: longitude, poiType: POItype, ownershipId: '', brand: brand }).then(res => {
                            //console.log('@@@result before parsing ', res);
                            if (res.error) {
                                this.footer = this.showFooter ? this.isGuest ? false : false : false;
                                //console.log('@@@error in > getDealerLocator ', res.error)
                            }
                            let dealerResult = JSON.parse(JSON.stringify(res.poiResponse.pois.poi));
                            //console.log('@@@result after stringify', dealerResult);
                            dealerResult = dealerResult.sort(function (a, b) { return parseFloat(a.distance.replaceAll(',', '')) - parseFloat(b.distance.replaceAll(',', '')) });
                            //console.log('@@@result after sorting', dealerResult);
                            dealerResult[0].attributes.attribute.forEach(attributeValue => {
                                if (!serviceSchedulingUrl && attributeValue.code == '47') {
                                    //console.log('@@@timeHighway');
                                    serviceSchedulingUrl = timeHighway;
                                } else if (!serviceSchedulingUrl && attributeValue.code == '48') {
                                    //console.log('@@@xTime');
                                    serviceSchedulingUrl = xTime;
                                } else if (!serviceSchedulingUrl && attributeValue.code == '49') {
                                    //console.log('@@@updatePromise');
                                    serviceSchedulingUrl = updatePromise;
                                }
                            });
                            //console.log('@@@serviceSchedulingUrl', serviceSchedulingUrl);
                            if (serviceSchedulingUrl == '') {
                                this.footer = this.showFooter ? this.isGuest ? false : false : false;
                            } else {
                                this.scheduleServiceLink = serviceSchedulingUrl;
                                this.footer = this.showFooter ? this.isGuest ? false : true : false;
                            }
                            //console.log('@@@scheduleServiceLink', this.scheduleServiceLink)
                        }).catch(err => {
                            //console.log('@@@err in getDealerLocator', err);
                            this.footer = this.showFooter ? this.isGuest ? false : false : false;
                        });
                    }, error => {
                        //console.log('@@@user denied')
                        this.scheduleServiceLink = '/find-a-dealer';
                        this.footer = this.showFooter ? this.isGuest ? false : true : false;
                    },
                        { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 });
                }
                // if (navigator.geolocation) {
                //     navigator.geolocation.getCurrentPosition(position => {
                //         latitude = position.coords.latitude;//.replace(/\s+/g, '');
                //         longitude = position.coords.longitude;//.replace(/\s+/g, '');
                //         console.log('@@@User location-->>>>', latitude, longitude);
                //         //get nearest dealer 
                //         getDealerLocator({ latitude: latitude, longitude: longitude, poiType: POItype, ownershipId: '', brand: brand }).then(res => {
                //             console.log('@@@result before parsing ', res);
                //             if (res.error) {
                //                 this.footer = this.showFooter ? this.isGuest ? false : false : false;
                //                 console.log('@@@error in > getDealerLocator ', res.error)
                //             }
                //             let dealerResult = JSON.parse(JSON.stringify(res.poiResponse.pois.poi));
                //             console.log('@@@result after stringify', dealerResult);
                //             dealerResult = dealerResult.sort(function (a, b) { return parseFloat(a.distance.replaceAll(',', '')) - parseFloat(b.distance.replaceAll(',', '')) });
                //             console.log('@@@result after sorting', dealerResult);
                //             dealerResult[0].attributes.attribute.forEach(attributeValue => {
                //                 if (!serviceSchedulingUrl && attributeValue.code == '47') {
                //                     console.log('@@@timeHighway');
                //                     serviceSchedulingUrl = timeHighway;
                //                 } else if (!serviceSchedulingUrl && attributeValue.code == '48') {
                //                     console.log('@@@xTime');
                //                     serviceSchedulingUrl = xTime;
                //                 } else if (!serviceSchedulingUrl && attributeValue.code == '49') {
                //                     console.log('@@@updatePromise');
                //                     serviceSchedulingUrl = updatePromise;
                //                 }
                //             });
                //             console.log('@@@serviceSchedulingUrl', serviceSchedulingUrl);
                //             if (serviceSchedulingUrl == '') {
                //                 this.footer = this.showFooter ? this.isGuest ? false : false : false;
                //             } else {
                //                 this.scheduleServiceLink = serviceSchedulingUrl;
                //                 this.footer = this.showFooter ? this.isGuest ? false : true : false;
                //             }
                //             console.log('@@@scheduleServiceLink', this.scheduleServiceLink)
                //         }).catch(err => {
                //             console.log('@@@err in getDealerLocator', err);
                //             this.footer = this.showFooter ? this.isGuest ? false : false : false;
                //         });
                //     }, error => {
                //         console.log('user denied', error)
                //         console.warn(`ERROR : ${error.code} - ${error.message}`);
                //         this.scheduleServiceLink = '/find-a-dealer';
                //         this.footer = this.showFooter ? this.isGuest ? false : true : false;
                //     },
                //         { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 });
                // }
            }
        }).catch(err => {
            //console.log('@@@err in getDealerFromObj ', err);
            this.footer = this.showFooter ? this.isGuest ? false : false : false;
        })
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
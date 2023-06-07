import { api, track } from 'lwc';
import commonResources from "@salesforce/resourceUrl/Owners";
import { OwnBaseElement } from 'c/ownBaseElement';
import getDealerLocator from '@salesforce/apex/OwnAPIController.getDealerLocator';
import { viewProduct, getOrigin, setOrigin, addProduct, getGarageURL, getContext, setProductContextUser, getGarage, getMyProducts } from 'c/ownDataUtils';
import { ISGUEST, getProductContext } from 'c/ownDataUtils';
import Id from '@salesforce/user/Id';
import getUserDetails from '@salesforce/apex/OwnUserController.getUserDetails';
import getConsumerProfileInfo from '@salesforce/apex/OwnAPIController.getConsumerProfileByWebUserID';
import getDealerByPoiId from '@salesforce/apex/OwnAPIController.getDealerByPoiId';
import timeHighway from '@salesforce/label/c.TimeHighway';
import xTime from '@salesforce/label/c.XTime';
import updatePromise from '@salesforce/label/c.UpdatePromise';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
import timeHighwayAcura from '@salesforce/label/c.TimeHighwayAcura';
import xTimeAcura from '@salesforce/label/c.XTimeAcura';
import updatePromiseAcura from '@salesforce/label/c.UpdatePromiseAcura';

export default class ownFindDealer extends OwnBaseElement {
    userId = Id;
    @api mapImage = commonResources + '/images/map.jpg';
    isGuest = ISGUEST;
    @track title = '';
    @api icon = 'utility:connected_apps';
    @track titlecolor = '';
    @api brand;
    @api actiontitle = 'More Dealers';
    @api actionicon = 'utility:forward';
    @api isprotectionplanpage = false;
    @track showFooter = false;
    @track context;
    @track comtext1;
    @track brandSlot = 'Honda';
    @track iconImageSrc = this.myGarageResource() + '/ahmicons/dealer.svg';
    garage;
    myProducts;
    error = false;
    locationDenied = false;
    errorMessage;
    showMap = false;
    latitude;
    longitude;
    @track mapMarkers = [];
    zoomLevel = 10;
    mapOptions = {
        disableDefaultUI: true,
    };
    listView = 'not-visible';
    @track dealerLocation = {};
    @track dealerLocations = [];
    @track onlyOneDealer = false;
    @track ownershipId;
    @track isDataLoading = true;
    @track cardDivClass = '';
    @track hideScheduleLink = false;
    @track hideScheduleButton = false;
    @track favouriteDealer = {};
    connectedCallback() {
        this.initialize();
    }

    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('From Product Chooser ----', fromProductChooser);

        //console.log('Document title ::: ', document.title);
        if (document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage' || document.title == 'Garage') {
            this.cardDivClass = 'overview-tab-class';
            //console.log('Document title ::: ', document.title);
        }
        if (fromProductChooser) {
            this.context = await getProductContext('', true);

        } else {
            this.context = await getProductContext('', false);
        }

        //console.log('context-------->', this.context);
        //console.log('context-----divisionId--->', this.context.product.divisionId);
        let poiType = this.context.product.divisionId === 'PE' ? 'P' : this.context.product.divisionId;
        //console.log('poitype', poiType);

        if (this.context && this.context.product) {
            this.ownershipId = this.context.product.ownershipId;
            if (this.context.product.divisionId == 'M' || this.context.product.divisionId == 'P') {
                this.hideScheduleLink = true;
            }
        }
        // if (this.isGuest) {
        //     this.title = 'nearby dealers';
        //     this.actiontitle = 'More Dealers';
        // }
        // else {
        //     this.title = 'my dealer';
        //     this.actiontitle = 'Schedule Service';
        // }


        this.getUserCoordinates(poiType);

        //console.log('mapmarkers--', this.mapMarkers);
    }


    getDealersFromServer(poiType) {

        let servicingLocation = [];
        let servicingDealers = [];
        if (!this.isGuest && this.context && this.context.product && this.context.product.productIdentifier && this.context.product.productIdentifier != '-') {
            getConsumerProfileInfo().then(consumerResponse => {
                //console.log('consumerResponse : ', consumerResponse);
                if (consumerResponse && consumerResponse.consumerProfiles && consumerResponse.consumerProfiles.length > 0
                    && consumerResponse.consumerProfiles[0].dealers && consumerResponse.consumerProfiles[0].dealers.length > 0) {
                    consumerResponse.consumerProfiles[0].dealers.forEach((dealerRecord, index) => {
                        if (dealerRecord.relation && dealerRecord.relation.toUpperCase() == 'SERVICE' && dealerRecord.dealerNumber) {
                            getDealerByPoiId({ poiId: dealerRecord.dealerNumber, poiType: poiType, ownershipId: this.ownershipId, brand: this.brand, latitude: this.latitude, longitude: this.longitude }).then(serviceDealers => {
                                //console.log('THIS IS SERVICING DEALER : ', serviceDealers);
                                if (serviceDealers.error || !serviceDealers.poiResponse || !serviceDealers.poiResponse.pois || !serviceDealers.poiResponse.pois.poi.length) {
                                    //console.log('GOT NO SERVICING DEALERS');
                                } else {

                                    serviceDealers.poiResponse.pois.poi.forEach(location => {
                                        let badges = ['SERVICING DEALER'];
                                        let serviceSchedulingUrl;
                                        if (location.attributes && location.attributes.attribute && location.attributes.attribute.length > 0) {
                                            location.attributes.attribute.forEach(attributeValue => {
                                                if (!serviceSchedulingUrl && attributeValue.code == '47') {
                                                    serviceSchedulingUrl = poiType == 'B' ? timeHighwayAcura.replaceAll('[STORE-ID]',location.poiid)  : timeHighway.replaceAll('[STORE-ID]',location.poiid) ;
                                                } else if (!serviceSchedulingUrl && attributeValue.code == '48') {
                                                    serviceSchedulingUrl = poiType == 'B' ? xTimeAcura.replaceAll('[STORE-ID]',location.poiid)  : xTime.replaceAll('[STORE-ID]',location.poiid) ;
                                                }/* else if (!serviceSchedulingUrl && attributeValue.code == '49') {
                                                    serviceSchedulingUrl = poiType == 'B' ? updatePromiseAcura.replaceAll('[STORE-ID]',location.poiid)  : updatePromise.replaceAll('[STORE-ID]',location.poiid) ;
                                                }*/
                                                if (attributeValue.name && !badges.includes(attributeValue.name.toUpperCase()) && (attributeValue.name.toLowerCase().includes('certified collision') || attributeValue.name.toLowerCase().includes('powerhouse dealer'))) {
                                                    badges.push(attributeValue.name.toUpperCase());
                                                }
                                            });
                                        }
                                        servicingDealers.push(JSON.parse(JSON.stringify({
                                            name: location.POIName,
                                            addressLine1: location.fullAddress.split(';')[0],
                                            addressLine2: location.fullAddress.split(';')[1],
                                            phone: location.phone,
                                            website: location.internetAddress,
                                            showFavoriteIcon: location.isFavorite,
                                            badges: badges,
                                            serviceSchedulingUrl: serviceSchedulingUrl
                                        })));

                                        servicingLocation.push(JSON.parse(JSON.stringify({
                                            location: {
                                                Latitude: location.latitude,
                                                Longitude: location.longitude,
                                                title: location.POIName,
                                                description: location.fullAddress
                                            }
                                        })));
                                    });
                                }
                                if (index == consumerResponse.consumerProfiles[0].dealers.length - 1) {
                                    this.appendLocationBasedDealers(poiType, servicingDealers, servicingLocation);
                                }
                            }).catch(err => {
                                if (index == consumerResponse.consumerProfiles[0].dealers.length - 1) {
                                    this.appendLocationBasedDealers(poiType, servicingDealers, servicingLocation);
                                }
                                //console.log('Error serviceDealers : ', err);
                            });
                        }
                    });
                } else {
                    this.appendLocationBasedDealers(poiType, servicingDealers, servicingLocation);
                }
            }).catch(err => {
                this.appendLocationBasedDealers(poiType, servicingDealers, servicingLocation);
                //console.log('Error consumerResponse : ', err);
            })
        } else {
            this.appendLocationBasedDealers(poiType, servicingDealers, servicingLocation);
        }
    }

    async appendLocationBasedDealers(poiType, servicingDealers, servicingLocation) {

        getDealerLocator({ latitude: this.latitude, longitude: this.longitude, poiType: poiType, ownershipId: this.ownershipId, brand: this.brand }).then(res => {
            //console.log(' latitude,longitude:', this.latitude, this.longitude);
            //console.log('THIS IS LIST OF SERVICING DEALER : ', servicingDealers);
            //console.log('Result :::: ', res);
            if (res.error && !this.locationDenied && (!servicingDealers || servicingDealers.length == 0)) {
                this.error = true;
                this.errorMessage = res.errorMsg;
                this.isDataLoading = false;
                localStorage.setItem('faouriteDealer', JSON.stringify(this.favouriteDealer))
                this.title = 'nearby dealers';
                this.actiontitle = 'More Dealers';
                return;
            }
            else if (res.error && this.locationDenied && (!servicingDealers || servicingDealers.length == 0)) {
                this.error = true;
                this.errorMessage = 'Please allow browser to access your location..';
                this.isDataLoading = false;
                localStorage.setItem('faouriteDealer', JSON.stringify(this.favouriteDealer))
                this.title = 'nearby dealers';
                this.actiontitle = 'Find A Dealer';
                return;
            }

            let isServiceOrPreferedDealer = false;
            let favoriteIndex;
            if (!res.error) {
                let result = res.poiResponse.pois.poi;
                //console.log('result---', this.dealerLocations);
                //console.log('result api---', result);

                // if(res && res.dealerType == 'MyDealer'){
                //     this.title = 'my dealer';
                // }else{
                //     this.title = 'nearby dealers';
                // }
                result.forEach((location, index) => {
                    if (location.isFavorite) {
                        //console.log('THIS IS FAVOURITE DEALER : ', location);
                        isServiceOrPreferedDealer = true;
                        favoriteIndex = index;
                        let badges = [];
                        let serviceSchedulingUrl;
                        if (location.attributes && location.attributes.attribute && location.attributes.attribute.length > 0) {
                            location.attributes.attribute.forEach(attributeValue => {
                                if (!serviceSchedulingUrl && attributeValue.code == '47') {
                                    serviceSchedulingUrl = poiType == 'B' ? timeHighwayAcura.replaceAll('[STORE-ID]',location.poiid)  : timeHighway.replaceAll('[STORE-ID]',location.poiid) ;
                                } else if (!serviceSchedulingUrl && attributeValue.code == '48') {
                                    serviceSchedulingUrl = poiType == 'B' ? xTimeAcura.replaceAll('[STORE-ID]',location.poiid)  : xTime.replaceAll('[STORE-ID]',location.poiid) ;
                                } /*else if (!serviceSchedulingUrl && attributeValue.code == '49') {
                                    serviceSchedulingUrl = poiType == 'B' ? updatePromiseAcura.replaceAll('[STORE-ID]',location.poiid)  : updatePromise.replaceAll('[STORE-ID]',location.poiid) ;
                                }*/
                                if (attributeValue.name && !badges.includes(attributeValue.name.toUpperCase()) && (attributeValue.name.toLowerCase().includes('certified collision') || attributeValue.name.toLowerCase().includes('powerhouse dealer'))) {
                                    badges.push(attributeValue.name.toUpperCase());
                                }
                            });
                        }
                        this.favouriteDealer.selected_dealer_name = location.POIName;
                        this.favouriteDealer.selected_dealer_id = location.poiid;
                        this.dealerLocations.push(JSON.parse(JSON.stringify({
                            name: location.POIName,
                            addressLine1: location.fullAddress.split(';')[0],
                            addressLine2: location.fullAddress.split(';')[1],
                            phone: location.phone,
                            website: location.internetAddress,
                            showFavoriteIcon: true,
                            badges: badges,
                            serviceSchedulingUrl: serviceSchedulingUrl
                        })));

                        this.mapMarkers.push(JSON.parse(JSON.stringify({
                            location: {
                                Latitude: location.latitude,
                                Longitude: location.longitude,
                                title: location.POIName,
                                description: location.fullAddress
                            }
                        })));

                    }
                });
            }

            if (servicingDealers && servicingDealers.length > 0) {
                //console.log('THIS IS SERVICING DEALER : ', servicingDealers[0]);
                isServiceOrPreferedDealer = true;
                this.dealerLocations.push(JSON.parse(JSON.stringify(servicingDealers[0])));
                this.mapMarkers.push(JSON.parse(JSON.stringify(servicingLocation[0])));
            }
            let isNearbyDealers = false;
            if (isServiceOrPreferedDealer) {
                this.title = 'my dealer';
                this.showMap = true;
            } else {
                isNearbyDealers = true;
                this.title = 'nearby dealers';
                this.showMap = false;
                if (!res.error) {
                    //let result = res.poiResponse.pois.poi;
                    let dealerResult = JSON.parse(JSON.stringify(res.poiResponse.pois.poi));
                    let allBodyShopDealers = [];
                    if (true === false && (this.context.product.divisionId === 'A' || this.context.product.divisionId === 'B')) {
                        getDealerLocator({ latitude: this.latitude, longitude: this.longitude, poiType: 'BODYSHOP', ownershipId: this.ownershipId, brand: this.brand }).then(bodyShopDealers => {
                            //console.log('BodyShop Dealers : ', bodyShopDealers);
                            if (!bodyShopDealers.error && bodyShopDealers.poiResponse.pois.poi.length > 0) {
                                bodyShopDealers.poiResponse.pois.poi.forEach(dealerRecord => {
                                    let updatedDealerRecord = JSON.parse(JSON.stringify(dealerRecord));
                                    if (!updatedDealerRecord.attributes) {
                                        updatedDealerRecord.attributes = {};
                                        updatedDealerRecord.attributes.attribute = [];
                                    }
                                    updatedDealerRecord.attributes.attribute.push({
                                        code: this.context.product.divisionId === 'A' ? 'HR' : 'AR',
                                        name: this.context.product.divisionId === 'A' ? "Honda Certified Body Shop" : 'Acura Certified Body Shop'
                                    });
                                    const isFound = dealerResult.some(element => {
                                        if (element.poiid === updatedDealerRecord.poiid) {
                                            return true;
                                        }
                                        return false;
                                    });
                                    if (!isFound) {
                                        allBodyShopDealers.push(updatedDealerRecord);
                                    }
                                });
                                //console.log('allBodyShopDealers : ', allBodyShopDealers);
                                dealerResult.push(...allBodyShopDealers);
                                this.preparingAllDealersList(dealerResult);
                            } else {
                                this.preparingAllDealersList(dealerResult);
                            }
                        }).catch(err => {
                            //console.log('Error Occured while getting BodyShop Dealers : ', err);
                            this.preparingAllDealersList(dealerResult);
                        });
                    } else {
                        this.preparingAllDealersList(dealerResult);
                    }
                }
            }
            if (!isNearbyDealers) {
                if (this.dealerLocations.length < 2) {
                    this.onlyOneDealer = true;
                    this.actiontitle = 'Schedule Service';
                    if (this.dealerLocations.length == 1 && !this.dealerLocations[0].serviceSchedulingUrl) {
                        this.hideScheduleButton = true
                    }
                }
                //console.log('this.onlyOneDealer--<', this.onlyOneDealer);
                if (this.context && this.context.product && (this.context.product.divisionId == 'M' || this.context.product.divisionId == 'P') && this.actiontitle == 'Schedule Service') {
                    this.hideScheduleButton = true;
                }

                //Code Added To Hide Schedule Service Link As per Arun's Discussion with Grace
                if (this.actiontitle == 'Schedule Service') {
                    this.hideScheduleButton = true;
                }

                //console.log('********', this.dealerLocations);
                this.isDataLoading = false;
                localStorage.setItem('faouriteDealer', JSON.stringify(this.favouriteDealer))
            }

        }).catch(err => {
            //console.log(err);
            this.error = true;
            this.errorMessage = 'Unable to find dealers';
            this.isDataLoading = false;
            localStorage.setItem('faouriteDealer', JSON.stringify(this.favouriteDealer))
        });
    }

    preparingAllDealersList(dealerResult) {
        let result = JSON.parse(JSON.stringify(dealerResult));
        result = result.sort(function (a, b) { return parseFloat(a.distance.replaceAll(',', '')) - parseFloat(b.distance.replaceAll(',', '')) });
        //console.log('Dealers : ', result);
        for (let i = 0; i < result.length && this.dealerLocations.length < 3; i++) {
            //console.log('This is dealerLocations size : ', this.dealerLocations.length);
            //if((favoriteIndex || favoriteIndex == 0) && i == favoriteIndex) continue;
            // if (!this.isGuest && this.dealerLocations.length == 2) break;
            let dealerLocation = {};
            let badges = [];

            let serviceSchedulingUrl;
            if (result[i].attributes && result[i].attributes.attribute && result[i].attributes.attribute.length > 0) {
                result[i].attributes.attribute.forEach(attributeValue => {
                    if (!serviceSchedulingUrl && attributeValue.code == '47') {
                        serviceSchedulingUrl = this.context.product.divisionId == 'B' ? timeHighwayAcura.replaceAll('[STORE-ID]',result[i].poiid)  : timeHighway.replaceAll('[STORE-ID]',result[i].poiid) ;
                    } else if (!serviceSchedulingUrl && attributeValue.code == '48') {
                        serviceSchedulingUrl = this.context.product.divisionId == 'B' ? xTimeAcura.replaceAll('[STORE-ID]',result[i].poiid)  : xTime.replaceAll('[STORE-ID]',result[i].poiid) ;
                    } /*else if (!serviceSchedulingUrl && attributeValue.code == '49') {
                        serviceSchedulingUrl = this.context.product.divisionId == 'B' ? updatePromiseAcura.replaceAll('[STORE-ID]',result[i].poiid)  : updatePromise.replaceAll('[STORE-ID]',result[i].poiid) ;
                    }*/
                    if (attributeValue.name && !badges.includes(attributeValue.name.toUpperCase()) && (attributeValue.name.toLowerCase().includes('certified collision') || attributeValue.name.toLowerCase().includes('powerhouse dealer'))) {
                        badges.push(attributeValue.name.toUpperCase());
                    }
                });
            }

            dealerLocation = {
                name: result[i].POIName,
                addressLine1: result[i].fullAddress.split(';')[0],
                addressLine2: result[i].fullAddress.split(';')[1],
                phone: result[i].phone,
                website: result[i].internetAddress,
                showFavoriteIcon: false,
                badges: badges,
                serviceSchedulingUrl: serviceSchedulingUrl
            }
            this.dealerLocations.push(dealerLocation);
            let newLocation = {};
            newLocation.location = {
                Latitude: result[i].latitude,
                Longitude: result[i].longitude,
            };
            newLocation.title = result[i].POIName;
            newLocation.description = result[i].fullAddress;
            this.mapMarkers.push(newLocation);
        }
        if (this.dealerLocations.length < 2) {
            this.onlyOneDealer = true;
            this.actiontitle = 'Schedule Service';
            if (this.dealerLocations.length == 1 && !this.dealerLocations[0].serviceSchedulingUrl) {
                this.hideScheduleButton = true
            }
        }
        //console.log('this.onlyOneDealer--<', this.onlyOneDealer);
        if (this.context && this.context.product && (this.context.product.divisionId == 'M' || this.context.product.divisionId == 'P') && this.actiontitle == 'Schedule Service') {
            this.hideScheduleButton = true;
        }

        //Code Added To Hide Schedule Service Link As per Arun's Discussion with Grace
        if (this.actiontitle == 'Schedule Service') {
            this.hideScheduleButton = true;
        }

        //console.log('********', this.dealerLocations);
        this.isDataLoading = false;
        localStorage.setItem('faouriteDealer', JSON.stringify(this.favouriteDealer))
    }

    getUserCoordinates = async (poiType) => {
        // if (this.isGuest) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                this.latitude = position.coords.latitude;//.replace(/\s+/g, '');
                this.longitude = position.coords.longitude;//.replace(/\s+/g, '');
                // this.latitude = String('42.369137'.replace(/\s+/g, ''));
                // this.longitude = String('- 71.241468'.replace(/\s+/g, ''));
                // this.latitude = '42.369137';
                // this.longitude = '-71.241468';
                //console.log('User location-->>>>', this.latitude, this.longitude);
                this.getDealersFromServer(poiType);
            }, error => {
                //console.log('user denied')
                this.locationDenied = true;
                //console.warn(`ERROR : ${error.code} - ${error.message}`);
                this.getDealersFromServer(poiType);
            },
                { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 });
        }
        // }else{

        // }
    }

    async handleAction(event) {
        //console.log('action');
        //console.log('This is current Context : ', this.context);
        //console.log('This is data label ', event.target.value);
        let label = event.target.value;
        if (label) {
            let eventMetadata = {
                action_type: 'button',
                action_category: 'body',
                action_label: this.title+( !this.hideScheduleButton ? ':'+this.actiontitle:'')
            };
            let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata };
            this.publishToChannel(message);
        }
        // let brandName;
        // switch (this.brand) {
        //     case 'A':
        //         brandName = 'Honda';
        //         break;
        //     case 'B':
        //         brandName = 'Acura';
        //         break;
        //     case 'M':
        //         brandName = 'Powersports';
        //         break;
        //     case 'P':  
        //         brandName = 'Power Equipment';
        //         break;        
        // }
        if (label == 'Schedule Service') {
            if (this.dealerLocations.length > 0 && this.dealerLocations[0].serviceSchedulingUrl) {
                await this.sleep(2000);
                this.navigate(this.dealerLocations[0].serviceSchedulingUrl, {});
            }
        } else {
            let brandName = this.context.product.division == 'Powerequipment' ? 'Power Equipment' : this.context.product.division;
            sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: brandName, divisionId: this.context.product.divisionId }));
            await this.sleep(2000);
            this.navigate('/find-a-dealer', {});
        }

    }

    renderedCallback() {
        let elementArray = [];
        let heightArray = [];
        this.template.querySelectorAll(".name-container").forEach(nameElement => {
            heightArray.push(nameElement.offsetHeight);
            elementArray.push(nameElement);
        });
        if (heightArray.length > 0 && elementArray.length > 0 && heightArray[0]) {
            elementArray.forEach(element => {
                element.style.height = heightArray[0] + 'px';
            });
        }
    }
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
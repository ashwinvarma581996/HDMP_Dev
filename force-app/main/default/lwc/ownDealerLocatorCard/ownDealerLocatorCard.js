import { api, track } from 'lwc';
import commonResources from "@salesforce/resourceUrl/Owners";
import { OwnBaseElement } from 'c/ownBaseElement';
import getDealerLocator from '@salesforce/apex/OwnAPIController.getDealerLocator';
import { ISGUEST } from 'c/ownDataUtils';
import timeHighway from '@salesforce/label/c.TimeHighway';
import xTime from '@salesforce/label/c.XTime';
import updatePromise from '@salesforce/label/c.UpdatePromise';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
import timeHighwayAcura from '@salesforce/label/c.TimeHighwayAcura';
import xTimeAcura from '@salesforce/label/c.XTimeAcura';
import updatePromiseAcura from '@salesforce/label/c.UpdatePromiseAcura';

const API_KEY = 'Arj9GvIEmrj_PPGQEw0vQWyJqBBD3dK2fjBXm0KZy_HN3eEoC5XoXoO417fFps1F';
export default class OwnDealerLocatorCard extends OwnBaseElement {
    @api mapImage = commonResources + '/images/map.jpg';
    @api title = 'Locate a Profirst body shop';
    @api icon = 'utility:connected_apps';
    @api titlecolor = 'Black';
    @api brandForCard = 'honda';
    @api actiontitle = 'FIND Body Shops';
    @track iconImageSrc = this.myGarageResource() + '/ahmicons/dealer.svg';
    @api actionicon;
    @api isprotectionplanpage = false;
    @track showFooter = false;
    error = false;
    errorMessage;
    showMap = false;
    isGuest = ISGUEST;
    latitude = '';
    longitude = '';
    isDataLoading = true;
    @track mapMarkers = [
        // {
        //     location: {
        //         Latitude: '37.790197',
        //         Longitude: '-122.396879',
        //     },
        // },
    ];
    mapOptions = {
        disableDefaultUI: true,
    };
    zoomLevel = 13;
    @track dealerLocation = {};
    @api brand = 'Honda';

    get cardTitle() {
        if (this.brand == 'Honda') {
            return 'LOCATE A HONDA CERTIFIED BODY SHOP';
        } else if (this.brand == 'Acura') {
            return 'LOCATE AN ACURA BODY SHOP';
        } else {
            return '';
        }
    };

    get bodyHeading() {
        if (this.brand == 'Honda') {
            return 'Your Nearby Honda Certified Collision Repair Facility';
        } else if (this.brand == 'Acura') {
            return 'Your Nearby Acura Collision Repair Facility';
        } else {
            return '';
        }
    }

    connectedCallback() {
        //this.brand = 'Honda';
        //console.log('Connected Callback of Dealer Locator');
        this.initialize();
    }

    initialize = async () => {
        await this.getUserCoordinates();
    }

    loadDealers() {
        //console.log('Latitude and longitude---', this.latitude, this.longitude);
        getDealerLocator({ latitude: this.latitude, longitude: this.longitude, poiType: 'BODYSHOP', ownershipId: '', brand: this.brand }).then(res => {
            //console.log('Dealer Locator', res);
            if (res.error) {
                this.error = true;
                this.errorMessage = res.errorMsg;
                this.isDataLoading = false;
                return;
            }
            if (res.poiResponse && res.poiResponse.pois && res.poiResponse.pois.poi) {
                let dealerResult = res.poiResponse.pois.poi;
                let result = JSON.parse(JSON.stringify(dealerResult));
                result = result.sort(function (a, b) { return parseFloat(a.distance.replaceAll(',', '')) - parseFloat(b.distance.replaceAll(',', '')) });
                if (result.length > 0 && result[0]) {
                    this.dealerLocation.name = result[0].POIName.toLowerCase();
                    this.dealerLocation.addressLine1 = result[0].fullAddress.split(';')[0];
                    this.dealerLocation.addressLine2 = result[0].fullAddress.split(';')[1];
                    this.dealerLocation.phone = result[0].phone;
                    this.dealerLocation.website = result[0].internetAddress;
                    this.dealerLocation.scheduleServiceLink = '';
                    // SCHEDULE SERVICE LINK COMMENTED AS PER ARUN'S DISCUSSION WITH GRACE 
                    if (this.brand == 'Honda' || this.brand == 'Acura') {
                        if (result[0].attributes && result[0].attributes.attribute && result[0].attributes.attribute.length > 0) {
                            result[0].attributes.attribute.forEach(attributeValue => {
                                if (!this.dealerLocation.scheduleServiceLink && attributeValue.code == '47') {
                                    this.dealerLocation.scheduleServiceLink = this.brand == 'Acura' ? timeHighwayAcura : timeHighway;
                                } else if (!this.dealerLocation.scheduleServiceLink && attributeValue.code == '48') {
                                    this.dealerLocation.scheduleServiceLink = this.brand == 'Acura' ? xTimeAcura : xTime;
                                } else if (!this.dealerLocation.scheduleServiceLink && attributeValue.code == '49') {
                                    this.dealerLocation.scheduleServiceLink = this.brand == 'Acura' ? updatePromiseAcura : updatePromise;
                                }
                            });
                        }
                    }
                    this.mapMarkers.push({
                        title: result[0].POIName,
                        location: {
                            Latitude: result[0].latitude,
                            Longitude: result[0].longitude
                        }
                    });
                    this.showMap = true;
                }
                this.isDataLoading = false;
            } else {
                this.error = true;
                this.errorMessage = 'No Dealers Found';
                this.isDataLoading = false;
                return;
            }
        }).catch(err => {
            this.isDataLoading = false;
           // console.log(err);
        });

        //console.log('DealerLocation--', this.dealerLocation);
    }

    async getUserCoordinates() {
        //if(this.isGuest){
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                this.latitude = position.coords.latitude;
                this.longitude = position.coords.longitude;
                //this.latitude = '33.8291867';//'42.369137';
                //this.longitude = '-118.3169714';//'-71.241468';
                //console.log('THis is navigator geolocation : ', this.latitude, this.longitude);
                this.loadDealers();
            }, error => {
                this.loadDealers();
                //console.warn(`ERROR : ${error.code} - ${error.message}`);

            },
                { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 });
        }
        // }
    }


    async handleAction() {
        //console.log('action');
        let eventMetadata = {
            action_type: 'link',
            action_category: 'body',
        };

        let divisionId;
        switch (this.brand) {
            case 'Honda':
                divisionId = 'A';
                eventMetadata.action_label = 'Your Nearby Honda Certified Collision Repair Facility' + ':' + this.actiontitle;
                break;
            case 'Acura':
                divisionId = 'B';
                eventMetadata.action_label = 'LOCATE AN ACURA BODY SHOP' + ':' + this.actiontitle;
                break;
            case 'Powersports':
                divisionId = 'M';
                break;
            case 'Power Equipment': case 'Marine':
                divisionId = 'P';
                break;
        }
        let message = this.buildAdobeMessage('/find-a-dealer', eventMetadata);
        this.publishToChannel(message);
        sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: this.brand, divisionId: divisionId, fromPage: 'DEALER_LOCATOR' }));
        await this.sleep(2000);
        this.navigate('/find-a-dealer', {});
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
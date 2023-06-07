import { api, track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import searchDealers from '@salesforce/apex/OwnAPIController.searchDealers';
import getDealerLocator from '@salesforce/apex/OwnAPIController.getDealerLocator';
import updateFavoriteDealer from '@salesforce/apex/OwnAPIController.updateFavoriteDealer';
import { ISGUEST, getProductContext } from 'c/ownDataUtils';
import { viewProduct, getOrigin, setOrigin, addProduct, getGarageURL, getContext, setProductContextUser } from 'c/ownDataUtils';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import timeHighway from '@salesforce/label/c.TimeHighway';
import xTime from '@salesforce/label/c.XTime';
import updatePromise from '@salesforce/label/c.UpdatePromise';
import getProductAttributes from '@salesforce/apex/OwnGarageController.getPowerequipmentProductAttributes';
import { CurrentPageReference } from 'lightning/navigation';
import getConsumerProfileInfo from '@salesforce/apex/OwnAPIController.getConsumerProfileByWebUserID';
import getDealerByPoiId from '@salesforce/apex/OwnAPIController.getDealerByPoiId';
import { DATALAYER_EVENT_TYPE } from 'c/ownAdobedtmUtils';
import timeHighwayAcura from '@salesforce/label/c.TimeHighwayAcura';
import xTimeAcura from '@salesforce/label/c.XTimeAcura';
import updatePromiseAcura from '@salesforce/label/c.UpdatePromiseAcura';

export default class OwnFindDealers extends OwnBaseElement {
    isGuest = ISGUEST;
    error;
    showMap = true;
    instaInitialized = false;
    @track context;
    @track allMapMarkers = [];
    @track allFilteredMarkers = [];
    @track mapMarkers = [
        // {
        //     location: {
        //         Latitude: '37.790197',
        //         Longitude: '-122.396879',
        //     },
        // },
    ];
    @track zoomLevel = 10;
    mapOptions = {
        disableDefaultUI: true,
    };

    @track selectedMiles;
    //Verified
    selectedStateValue;
    //Verified
    isStateCity = false;
    //Verified
    searchedText = '';
    //Verified
    selectedSearchType = 'zip_code';
    @track allDlrs = [];
    @track allFilteredDealers = [];
    @track arrSize = 4;
    @track dealerLocations = [];
    @track dealerLocation = {};
    @track findDealerContext;
    @track currentBrand;
    @track currentDivisionId;
    @track searchPlaceholder = 'Enter Zip Code';
    @track currentLatitude;
    @track currentLongitude;
    @track showFavoriteIcon = false;
    @track ownershipId;
    @track isDataLoading = true;
    @track error = false;
    @track errorMessage = '';
    @track locationDenied = false;
    @track showMoreDealers = false;
    @track selectedDealerAwards = 'ALL';
    @track selectedDealerProduct = '0';
    @track enableFilter;
    @track fromPage;
    @track isPowerequipment = false;
    @track selectedFilterCode = '';
    @track PEProductFilterCodes = [];
    @track brandPrefix = 'a';
    @track brandUrlParam;
    @track dealerNameUrlParam;

    currentPageReference = null;
    urlStateParameters = null;

    get dealerAwards() {
        return this.currentDivisionId === 'A' ? [
            { label: 'All Dealers', value: 'ALL' },
            { label: 'Services & Awards', value: '0' },
            { label: 'Express Service', value: '09' },
            { label: 'Clarity Certified Dealer', value: 'BC' },
            { label: 'Honda Certified Body Shop', value: 'HR' },
            { label: 'Council of Excellence', value: 'HC' },
            { label: 'Honda Environmental Leadership Award', value: 'GP' },
            { label: 'Presidents Award', value: '02' },
        ] : this.currentDivisionId === 'B' ? [
            { label: 'All Dealers', value: 'ALL' },
            { label: 'Services & Awards', value: '0' },
            { label: 'Online Service Scheduling', value: '10' },
            { label: 'Acura Certified Body Shop', value: 'AR' },
            { label: 'Precision Team Award', value: '02' },
            { label: 'Environment Award', value: 'GP' },
            { label: 'Acura Accelerated Service', value: 'HC' },
            { label: 'NSX Authorized Dealer', value: 'NX' },
            { label: 'Acura Maintenance Program', value: 'CM' }
        ] : [
            { label: 'All Dealers', value: 'ALL' },
            { label: 'Services & Awards', value: '0' },
            { label: 'Honda ENVIRONMENTAL LEADERSHIP AWARD', value: 'GA' },
            { label: 'POWERHOUSE DEALER', value: 'L5' },
            { label: 'INTERNET CERTIFIED', value: '01' },
            { label: 'Honda CERTIFIED TECHNICIAN', value: 'RD' },
            { label: 'TEST RIDE', value: '03' }
        ];
    }

    get dealerProducts() {
        return this.currentDivisionId === 'A' || this.currentDivisionId === 'B' ? null : [
            { label: 'Products', value: '0' },
            { label: 'ATV', value: 'AT' },
            { label: 'MOTORCYCLE', value: 'MC' },
            { label: 'SXS', value: 'MU' },
            { label: 'SCOOTER', value: 'MS' },
            { label: 'WATERCRAFT', value: 'PW' }
        ];
    }

    get searchTypes() {
        return [
            { label: 'Zip', value: 'zip_code' },
            { label: 'City, State', value: 'city_state' },
            { label: 'Name', value: 'dlr_name' }
        ];
    }

    get mileValues() {
        return [
            { label: '10 Miles', value: '10', checked: this.selectedMiles == '10' ? true : false },
            { label: '20 Miles', value: '20', checked: this.selectedMiles == '20' ? true : false },
            { label: '30 Miles', value: '30', checked: this.selectedMiles == '30' ? true : false },
            { label: '40 Miles', value: '40', checked: this.selectedMiles == '40' ? true : false }
        ];
    }

    get getMapUrlVal() {
        return '';
    }

    get dropdownOptions() {

        let dropdownData = ['AK', 'AL', 'AR', 'AS', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'GU', 'HI',
            'IA', 'ID', 'IL', 'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO',
            'MP', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH', 'NJ', 'NM', 'NV', 'NY', 'OH', 'OK',
            'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UM', 'UT', 'VA', 'VI', 'VT', 'WA', 'WI', 'WV', 'WY'];
        let options = [];

        dropdownData.forEach(element => {
            options.push({ value: element, label: element });
        });

        return options;
        //return this.dropdown.controlData.Tier_Number__c === 1 ? options.sort(function(a,b){return b.value-a.value;}) : options.sort(function(a,b){return a.value.localeCompare(b.value);});
    }

    get placeholderText() {
        return "Select State";
    }

    get comboboxDisabled() {
        return false;
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.brandUrlParam = this.urlStateParameters.brand || null;
        //console.log('brandUrlParam: ' + this.brandUrlParam);
        this.dealerNameUrlParam = this.urlStateParameters.name || null;
        if (this.dealerNameUrlParam && this.brandUrlParam) {
            this.brandUrlParam = this.brandUrlParam.toLowerCase();
        }
        if (this.brandUrlParam === 'honda') {
            sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: 'Honda', divisionId: 'A' }));
        } else if (this.brandUrlParam === 'acura') {
            sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: 'Acura', divisionId: 'B' }));
        } else if (this.brandUrlParam === 'powersports') {
            sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: 'Powersports', divisionId: 'M' }));
        } else if (this.brandUrlParam === 'powerequipment') {
            sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: "Power Equipment", divisionId: 'P' }));
        } else if (this.brandUrlParam === 'marine') {
            sessionStorage.setItem('findDealerContext', JSON.stringify({ brand: "Marine", divisionId: 'P' }));
        }

        if (this.dealerNameUrlParam) {
            this.selectedSearchType = 'dlr_name';
            this.searchedText = this.dealerNameUrlParam;
        }
    }

    connectedCallback() {
        this.findDealerContext = sessionStorage.getItem('findDealerContext');
        this.selectedMiles = '10';
        if (this.findDealerContext) {
            this.currentBrand = JSON.parse(this.findDealerContext).brand;
            this.brandPrefix = JSON.parse(this.findDealerContext).brand === 'Acura' ? 'an' : 'a';
            this.currentDivisionId = JSON.parse(this.findDealerContext).divisionId;
            this.enableFilter = this.currentDivisionId === 'M' || this.currentDivisionId === 'A' || this.currentDivisionId === 'B' ? true : false;
            this.fromPage = JSON.parse(this.findDealerContext).fromPage;
            if (this.currentBrand == 'Power Equipment' || this.currentBrand == 'Powerequipment') {
                this.isPowerequipment = true;
                this.getproductAttributesCodes();
            }
        }
        this.initialize();
        //console.log('---!!', this.dealerLocations);
    }

    initialize = async () => {
        //console.log('isguest', this.isGuest);
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('From Product Chooser ----', fromProductChooser);
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        //console.log('context-------->', this.context);
        // if (this.context.product.division) {
        //     console.log('@@AdobeFindADealerBrand', this.context.product.division)
        //     sessionStorage.setItem('AdobeFindADealerBrand', this.context.product.division);
        // }
        if (this.context && this.context.product) {
            if (!this.isGuest && this.context.product.divisionId == this.currentDivisionId && this.context.product.ownershipId && (!this.fromPage || this.fromPage != 'DEALER_LOCATOR')) {
                this.showFavoriteIcon = true;
            }
            this.ownershipId = this.context.product.ownershipId;
        }

        this.getUserCoordinates();
        //console.log('mapmarkers--', this.mapMarkers);
        //console.log('**!!!', this.dealerLocations);
    }

    getDealersFromServer(dealerName) {
        getDealerLocator({ latitude: this.currentLatitude, longitude: this.currentLongitude, poiType: this.currentDivisionId, ownershipId: this.ownershipId, brand: this.currentBrand }).then(res => {
            //console.log(' latitude,longitude:', this.currentLatitude, this.currentLongitude);
            //console.log('Result :::: ', res);
            if (res.error) { //&& !this.locationDenied
                this.error = true;
                // this.errorMessage = res.errorMsg;
                //this.isDataLoading = false;
                //return;
            }
            // else if (res.error && this.locationDenied) {
            //     this.error = true;
            //     this.errorMessage = 'Please allow browser to access your location..';
            //     this.isDataLoading = false;
            //     return;
            // }

            let dealerResult = [];
            if (!res.error && res.poiResponse) {
                dealerResult = JSON.parse(JSON.stringify(res.poiResponse.pois.poi));
            }

            //let dealerResult = JSON.parse(JSON.stringify(res.poiResponse.pois.poi));
            let allBodyShopDealers = [];
            if (this.currentDivisionId === 'A' || this.currentDivisionId === 'B') {
                getDealerLocator({ latitude: this.currentLatitude, longitude: this.currentLongitude, poiType: 'BODYSHOP', ownershipId: this.ownershipId, brand: this.currentBrand }).then(bodyShopDealers => {
                    //console.log('BodyShop Dealers : ', bodyShopDealers);
                    if (!bodyShopDealers.error && bodyShopDealers.poiResponse.pois.poi.length > 0) {
                        bodyShopDealers.poiResponse.pois.poi.forEach(dealerRecord => {
                            let updatedDealerRecord = JSON.parse(JSON.stringify(dealerRecord));
                            if (!updatedDealerRecord.attributes) {
                                updatedDealerRecord.attributes = {};
                                updatedDealerRecord.attributes.attribute = [];
                            }
                            updatedDealerRecord.attributes.attribute.push({
                                code: this.currentDivisionId === 'A' ? 'HR' : 'AR',
                                name: this.currentDivisionId === 'A' ? "Honda Certified Body Shop" : 'Acura Certified Body Shop'
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
                        this.preparingAllDealersList(dealerResult, this.currentDivisionId);
                    } else {
                        this.preparingAllDealersList(dealerResult, this.currentDivisionId);
                    }
                }).catch(err => {
                    //console.log('Error Occured while getting BodyShop Dealers : ', err);
                    this.preparingAllDealersList(dealerResult, this.currentDivisionId);
                });
            } else {
                this.preparingAllDealersList(dealerResult, this.currentDivisionId);
            }

        }).catch(err => {
            //console.log(err);
            this.isDataLoading = false;
        });
    }

    loadDealers(latitude, longitude, poiType, city, state, zipcode, dealerName) {

        //console.log('1. latitude : ', latitude);
        //console.log('2. longitude : ', longitude);
        //console.log('3. poiType : ', poiType);
        //console.log('4. city : ', city);
        //console.log('5. state : ', state);
        //console.log('6. zipcode : ', zipcode);
        //console.log('7. miles : ', this.selectedMiles);
        //console.log('8. dealerName : ', dealerName);
        searchDealers({ latitude: latitude, longitude: longitude, poiType: poiType, city: city, state: state, postalCode: zipcode, miles: this.selectedMiles, ownershipId: this.ownershipId, brand: this.currentBrand, pOIName: dealerName, filterCode: this.selectedFilterCode }).then(res => {

            //console.log('!!!result', res);
            if (res.error) {
                this.error = true;
                this.errorMessage = res.errorMsg;
                //this.isDataLoading = false;
                //return;
            }

            let dealerResult = [];
            if (!res.error && res.poiResponse) {
                dealerResult = JSON.parse(JSON.stringify(res.poiResponse.pois.poi));
            }

            //let dealerResult = JSON.parse(JSON.stringify(res.poiResponse.pois.poi));
            let allBodyShopDealers = [];
            if (this.currentDivisionId === 'A' || this.currentDivisionId === 'B') {
                searchDealers({ latitude: latitude, longitude: longitude, poiType: 'BODYSHOP', city: city, state: state, postalCode: zipcode, miles: this.selectedMiles, ownershipId: this.ownershipId, brand: this.currentBrand, pOIName: dealerName, filterCode: this.selectedFilterCode }).then(bodyShopDealers => {
                    //console.log('BodyShop Dealers : ', bodyShopDealers);
                    if (!bodyShopDealers.error && bodyShopDealers.poiResponse.pois.poi.length > 0) {
                        bodyShopDealers.poiResponse.pois.poi.forEach(dealerRecord => {
                            let updatedDealerRecord = JSON.parse(JSON.stringify(dealerRecord));
                            if (!updatedDealerRecord.attributes) {
                                updatedDealerRecord.attributes = {};
                                updatedDealerRecord.attributes.attribute = [];
                            }
                            updatedDealerRecord.attributes.attribute.push({
                                code: this.currentDivisionId === 'A' ? 'HR' : 'AR',
                                name: this.currentDivisionId === 'A' ? "Honda Certified Body Shop" : 'Acura Certified Body Shop'
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
                        this.preparingAllDealersList(dealerResult, poiType);
                    } else {
                        this.preparingAllDealersList(dealerResult, poiType);
                    }
                }).catch(err => {
                    //console.log('Error Occured while getting BodyShop Dealers : ', err);
                    this.preparingAllDealersList(dealerResult, poiType);
                });
            } else {
                this.preparingAllDealersList(dealerResult, poiType);
            }

        }).catch(err => {
            //console.log(err);
            this.isDataLoading = false;
        });
    }

    preparingAllDealersList(dealerResult, poiType) {
        this.allMapMarkers = [];
        this.allDlrs = [];
        this.arrSize = 4;
        //console.log('Final Dealer Result : ', dealerResult);
        if (dealerResult?.length) {
            let result = JSON.parse(JSON.stringify(dealerResult));
            result = result.sort(function (a, b) { return parseFloat(a.distance.replaceAll(',', '')) - parseFloat(b.distance.replaceAll(',', '')) });
            if (!this.isGuest && (this.currentDivisionId === 'A' || this.currentDivisionId === 'B') && this.context && this.context.product && (this.context.product.productIdentifier && this.context.product.productIdentifier != '-' || this.context.product.vin && this.context.product.vin != '-') && this.context.product.divisionId == this.currentDivisionId) {
                this.getServicingDealer(result, poiType);
            } else {
                this.prepareAllDealersList(result, poiType);
            }
            /*
            if(result.length > 4){
                this.showMoreDealers = true;
            } 
            for(let i=0; i<result.length; i++){
                let operationHours = [];
                if(result[i].departments && result[i].departments.department){
                    result[i].departments.department.forEach(department => {
                        if(department.operationHour && department.operationHour.length > 0){
                            operationHours.push({
                                name: department.name,
                                hours: department.operationHour[0].text.split(';') 
                            });
                        }
                    });
                }
                let serviceSchedulingUrl;
                if(poiType == 'A' || poiType == 'B'){
                    if(result[i].attributes && result[i].attributes.attribute && result[i].attributes.attribute.length > 0){
                        result[i].attributes.attribute.forEach(attributeValue => {
                            if(!serviceSchedulingUrl && attributeValue.code == '47'){
                                serviceSchedulingUrl = timeHighway;
                            }else if(!serviceSchedulingUrl && attributeValue.code == '48'){
                                serviceSchedulingUrl = xTime;
                            }else if(!serviceSchedulingUrl && attributeValue.code == '49'){
                                serviceSchedulingUrl = updatePromise;
                            }
                        }); 
                    }
                } 
                let bodyShopAttributes = {};
                if(result[i].poiType === 'BODYSHOP'){
                    bodyShopAttributes.attributes = {};
                    bodyShopAttributes.attributes.attribute = [];
                    if(result[i].attributes && result[i].attributes.attribute && result[i].attributes.attribute.length > 0){
                        bodyShopAttributes.attributes.attribute.push(...result[i].attributes.attribute);
                    }
                    if(!bodyShopAttributes.attributes.attribute.find(attrVal => attrVal.code == 'HR' || attrVal.code == 'AR')){
                        bodyShopAttributes.attributes.attribute.push({
                            code: this.currentDivisionId === 'A' ? 'HR' : 'AR',
                            name: this.currentDivisionId === 'A' ? "Honda Certified Body Shop" : 'Acura Certified Body Shop'
                        });    
                    }
                }
                this.allDlrs.push({
                    sno : i+1,    
                    name : result[i].POIName,
                    addressLine1 : result[i].fullAddress.split(';')[0],
                    addressLine2 : result[i].fullAddress.split(';')[1],
                    shortAddr: result[i].address,
                    phone : result[i].phone,
                    lat: result[i].latitude,
                    lng: result[i].longitude,
                    indxVal: i,
                    website : result[i].internetAddress,
                    favoriteIconClass : result[i].isFavorite ? 'active-star-icon' : 'inactive-star-icon',
                    poiid : result[i].poiid,
                    distance: result[i].distance,
                    showDistance: result[i].distance === '0.0 miles' ? false : true,
                    operationHours: operationHours,
                    showOperationHours: false,
                    detailsLabel: 'MORE DETAILS',
                    detailsIcon: 'utility:chevronright',
                    attributes: result[i].poiType === 'BODYSHOP' ? bodyShopAttributes.attributes.attribute : result[i].attributes.attribute,
                    serviceSchedulingUrl: serviceSchedulingUrl
                });

                this.allMapMarkers.push({
                    title: result[i].POIName,
                    location: {
                        Latitude: result[i].latitude,
                        Longitude: result[i].longitude
                    }
                });    
            }
            console.log('THESE ALL DEALERS :: >> ',this.allDlrs);
            console.log('THESE ALL MAP MARKERS :: >> ',this.allMapMarkers);
            this.allFilteredDealers = JSON.parse(JSON.stringify(this.allDlrs));
            this.allFilteredMarkers = JSON.parse(JSON.stringify(this.allMapMarkers));
            
            if(this.fromPage && this.fromPage == 'DEALER_LOCATOR' && (this.currentDivisionId === 'A' || this.currentDivisionId === 'B')){
                this.selectedDealerAwards = this.currentDivisionId === 'A' ? 'HR' : 'AR';
                this.handleChangeDealerAwards({detail: {value : this.currentDivisionId === 'A' ? 'HR' : 'AR'}});
            }else{
                this.loadDlrsArray(this.arrSize);
            }
            */

        } else {
            this.isDataLoading = false;
        }
    }

    prepareAllDealersList(result, poiType) {
        if (result.length > 4) {
            this.showMoreDealers = true;
        }
        for (let i = 0; i < result.length; i++) {
            let operationHours = [];
            if (result[i].departments && result[i].departments.department) {
                result[i].departments.department.forEach(department => {
                    if (department.operationHour && department.operationHour.length > 0) {
                        operationHours.push({
                            name: department.name,
                            hours: department.operationHour[0].text.split(';')
                        });
                    }
                });
            }
            let serviceSchedulingUrl;
            if (poiType == 'A' || poiType == 'B') {
                if (result[i].attributes && result[i].attributes.attribute && result[i].attributes.attribute.length > 0) {
                    result[i].attributes.attribute.forEach(attributeValue => {
                        if (!serviceSchedulingUrl && attributeValue.code == '47') {
                            serviceSchedulingUrl = poiType == 'B' ? timeHighwayAcura.replaceAll('[STORE-ID]',result[i].poiid) : timeHighway.replaceAll('[STORE-ID]',result[i].poiid);
                        } else if (!serviceSchedulingUrl && attributeValue.code == '48') {
                            serviceSchedulingUrl = poiType == 'B' ? xTimeAcura.replaceAll('[STORE-ID]',result[i].poiid) : xTime.replaceAll('[STORE-ID]',result[i].poiid) ;
                        }/* else if (!serviceSchedulingUrl && attributeValue.code == '49') {
                            serviceSchedulingUrl = poiType == 'B' ? updatePromiseAcura.replaceAll('[STORE-ID]',result[i].poiid) : updatePromise.replaceAll('[STORE-ID]',result[i].poiid);
                        }*/
                    });
                }
            }
            let bodyShopAttributes = {};
            if (result[i].poiType === 'BODYSHOP') {
                bodyShopAttributes.attributes = {};
                bodyShopAttributes.attributes.attribute = [];
                if (result[i].attributes && result[i].attributes.attribute && result[i].attributes.attribute.length > 0) {
                    bodyShopAttributes.attributes.attribute.push(...result[i].attributes.attribute);
                }
                if (!bodyShopAttributes.attributes.attribute.find(attrVal => attrVal.code == 'HR' || attrVal.code == 'AR')) {
                    bodyShopAttributes.attributes.attribute.push({
                        code: this.currentDivisionId === 'A' ? 'HR' : 'AR',
                        name: this.currentDivisionId === 'A' ? "Honda Certified Body Shop" : 'Acura Certified Body Shop'
                    });
                }
            }
            this.allDlrs.push({
                sno: i + 1,
                name: result[i].POIName,
                addressLine1: result[i].fullAddress.split(';')[0],
                addressLine2: result[i].fullAddress.split(';')[1],
                shortAddr: result[i].address,
                phone: result[i].phone,
                lat: result[i].latitude,
                lng: result[i].longitude,
                indxVal: i,
                website: result[i].internetAddress,
                favoriteIconClass: result[i].isFavorite ? 'active-star-icon' : 'inactive-star-icon',
                poiid: result[i].poiid,
                distance: result[i].distance,
                showDistance: result[i].distance === '0.0 miles' ? false : true,
                operationHours: operationHours,
                showOperationHours: false,
                detailsLabel: 'MORE DETAILS',
                detailsIcon: 'utility:chevronright',
                attributes: result[i].poiType === 'BODYSHOP' ? bodyShopAttributes.attributes.attribute : result[i].attributes.attribute,
                badges: result[i].badges ? result[i].badges : [],
                serviceDealer: result[i].serviceDealer ? result[i].serviceDealer : false,
                serviceSchedulingUrl: serviceSchedulingUrl
            });

            this.allMapMarkers.push({
                title: result[i].POIName,
                location: {
                    Latitude: result[i].latitude,
                    Longitude: result[i].longitude
                }
            });
        }
        //console.log('THESE ALL DEALERS :: >> ', this.allDlrs);
        //console.log('THESE ALL MAP MARKERS :: >> ', this.allMapMarkers);
        this.allFilteredDealers = JSON.parse(JSON.stringify(this.allDlrs));
        this.allFilteredMarkers = JSON.parse(JSON.stringify(this.allMapMarkers));

        if (this.fromPage && this.fromPage == 'DEALER_LOCATOR' && (this.currentDivisionId === 'A' || this.currentDivisionId === 'B')) {
            this.selectedDealerAwards = this.currentDivisionId === 'A' ? 'HR' : 'AR';
            this.handleChangeDealerAwards({ detail: { value: this.selectedDealerAwards } });
        } else {
            this.selectedDealerAwards = 'ALL';
            this.handleChangeDealerAwards({ detail: { value: this.selectedDealerAwards } });
            //this.loadDlrsArray(this.arrSize);
        }
    }


    loadDlrsArray(indxVal) {
        //console.log('!!this.allFilteredDealers', this.allFilteredDealers);
        //console.log('!!this.allFilteredMarkers', this.allFilteredMarkers);
        this.dealerLocations = [];
        if (this.allFilteredDealers.length - 1 > indxVal) {
            this.dealerLocations = this.allFilteredDealers.slice(0, indxVal);
            this.mapMarkers = this.allFilteredMarkers.slice(0, indxVal);
            this.showMoreDealers = true;
        } else {
            this.dealerLocations = this.allFilteredDealers;
            this.mapMarkers = this.allFilteredMarkers;
            this.showMoreDealers = false;
        }
        //console.log('---dealerLocations---', this.dealerLocations);
        this.isDataLoading = false;
        if (this.dealerLocations.length === 0) {
            this.error = true;
            this.errorMessage = 'Sorry, there are no results based on the information you provided.';
        } else {
            this.error = false;
        }
    }

    handleDealerSearch() {

        this.dealerLocations = [];
        this.mapMarkers = [];
        this.isDataLoading = true;
        this.error = false;
        this.selectedDealerAwards = 'ALL';
        this.selectedDealerProduct = '0';
        //console.log('!!selectedStateValue', this.selectedStateValue);
        //console.log('!!selectedSearchType', this.selectedSearchType);
        //console.log('!!searchedText', this.searchedText);

        let zipValue = '';
        let dealerName = '';
        let cityParam = '';
        let stateParam = '';
        let lattitueParam = '';
        let longitudeParam = '';
        let eventMetadata = {
            action_type: 'button',
            action_category: 'body',
            action_label: 'search'
        };
        let dealer = {};
        var escapeSpecialCharacters = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;
        if (this.selectedSearchType == 'zip_code') {
            zipValue = this.searchedText.trim();
            dealer.dealer_locator_search_type = 'zip code';
            dealer.dealer_locator_search_term = zipValue;
            if (!zipValue || escapeSpecialCharacters.test(zipValue) || isNaN(zipValue)) {
                this.error = true;
                this.errorMessage = 'There was an error with your search. Please try again or try different search criteria.';
                this.isDataLoading = false;
                return;
            }
            //console.log('!zipValue!!', zipValue);
            //console.log('this.currentDivisionId : ', this.currentDivisionId);
            this.loadDealers(lattitueParam, longitudeParam, this.currentDivisionId, cityParam, stateParam, zipValue, dealerName);
        } else if (this.selectedSearchType == 'city_state') {
            cityParam = this.searchedText.trim();
            dealer.dealer_locator_search_type = 'city/state';
            dealer.dealer_locator_search_term = cityParam;
            if (!cityParam || escapeSpecialCharacters.test(cityParam) || !isNaN(cityParam)) {
                this.error = true;
                this.errorMessage = 'There was an error with your search. Please try again or try different search criteria.';
                this.isDataLoading = false;
                return;
            }
            stateParam = this.selectedStateValue;
            //console.log('!city!!', cityParam);
            //console.log('this.currentDivisionId : ', this.currentDivisionId);
            this.loadDealers(this.currentLatitude, this.currentLongitude, this.currentDivisionId, cityParam, stateParam, zipValue, dealerName);
        } else if (this.selectedSearchType == 'dlr_name') {
            dealerName = this.searchedText.trim();
            dealer.dealer_locator_search_type = 'name';
            dealer.dealer_locator_search_term = dealerName;
            if (!dealerName || escapeSpecialCharacters.test(dealerName) || !isNaN(dealerName)) {
                this.error = true;
                this.errorMessage = 'There was an error with your search. Please try again or try different search criteria.';
                this.isDataLoading = false;
                return;
            }
            this.loadDealers(this.currentLatitude, this.currentLongitude, this.currentDivisionId, cityParam, stateParam, zipValue, dealerName);
        }
        let message = { eventType: DATALAYER_EVENT_TYPE.CLICK, eventMetadata: eventMetadata, dealer: dealer };
        this.publishToChannel(message);
        //console.log('handleDealerSearch')
    }

    handleDealerWebsite(event) {
        let url = event.currentTarget.dataset.url;
        this.navigate(url, {});
    }

    getUserCoordinates = async () => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                this.currentLatitude = position.coords.latitude;//.replace(/\s+/g, '');
                this.currentLongitude = position.coords.longitude;//.replace(/\s+/g, '');
                // this.latitude = String('42.369137'.replace(/\s+/g, ''));
                // this.longitude = String('- 71.241468'.replace(/\s+/g, ''));
                //this.currentLatitude = '42.369137';
                //this.currentLongitude = '-71.241468';
                //this.currentLatitude = '33.8291867';//'42.369137';
                //this.currentLongitude = '-118.3169714';//'-71.241468';
                //console.log('dealerNameUrlParam' + this.dealerNameUrlParam);
                if (this.dealerNameUrlParam) {
                    //console.log('Handling search by URL param');
                    this.handleDealerSearch();
                } else {
                    //console.log('User location-->>>>', this.currentLatitude, this.currentLongitude);
                    this.getDealersFromServer('');
                }
            }, error => {
                //console.log('user denied')
                this.locationDenied = true;
                //console.warn(`ERROR : ${error.code} - ${error.message}`);
                if (this.dealerNameUrlParam) {
                    this.handleDealerSearch();
                } else {
                    this.getDealersFromServer('');
                }
            },
                { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 });
        }
    }


    handlMile(event) {
        //window.console.log('selected value ===> ' + event.target.value);
        this.selectedMiles = event.target.value;
    }

    handleStateSelection(event) {
        this.selectedStateValue = event.detail.value;
    }

    handleProductFilterSelection(event) {
        this.selectedFilterCode = event.detail.value;
    }

    searchTypeChange(event) {
        this.selectedSearchType = event.detail.value;
        this.searchedText = '';
        //console.log('Option selected with value: ' + this.selectedSearchType);
        if (this.selectedSearchType == 'city_state') {
            this.searchPlaceholder = 'Enter City';
        } else if (this.selectedSearchType == 'zip_code') {
            this.searchPlaceholder = 'Enter Zip Code';
        } else if (this.selectedSearchType == 'dlr_name') {
            this.searchPlaceholder = 'Enter Dealer Name';
        }
        this.isStateCity = this.selectedSearchType == 'city_state';
    }

    handlSearchText(event) {
        //console.log('!!!event.detail.value', event.detail.value);
        this.searchedText = event.detail.value;
    }

    handlLoadMore() {
        this.arrSize += 4;
        //console.log('$$$this.indxVal', this.arrSize);
        this.loadDlrsArray(this.arrSize);
    }

    handleStarClick(event) {
        let indexValue = event.currentTarget.dataset.index;
        let poiid = event.currentTarget.dataset.poiid;
        let name = event.currentTarget.dataset.name;
        //console.log('Event index : ', indexValue);
        //console.log('Event poiid : ', poiid);

        updateFavoriteDealer({ poiId: poiid, ownershipId: this.ownershipId, accountName: name }).then(res => {
            //console.log('Result of favorite dealer updation is : ', res);
            if (res) {
                let newDealerList = [];
                let favoriteDealerRemoved = false;
                this.dealerLocations.forEach((element, index) => {
                    //console.log('Element : ', element);
                    let newDealer = JSON.parse(JSON.stringify(element));
                    //console.log('New Dealer : ', newDealer);
                    if (index == indexValue) {
                        if (newDealer.favoriteIconClass == 'active-star-icon') {
                            favoriteDealerRemoved = true;
                            newDealer.favoriteIconClass = 'inactive-star-icon';
                        } else
                            newDealer.favoriteIconClass = 'active-star-icon';
                    } else {
                        newDealer.favoriteIconClass = 'inactive-star-icon';
                    }
                    newDealerList.push(newDealer);
                });

                //console.log('After update dealerLocation', newDealerList);
                this.dealerLocations = JSON.parse(JSON.stringify(newDealerList));

            } else {
                //console.log('Favorite Dealer Updation Failed!');
            }
        }).catch(err => {
            //console.log('Error Occured : ', err);
        });
    }

    handleMoreDetails(event) {
        let indexValue = event.currentTarget.dataset.index;
        let detailedDealer = JSON.parse(JSON.stringify(this.dealerLocations.find(element => element.indxVal == indexValue)));
        //console.log('This is  detailedDelear : ', detailedDealer);
        detailedDealer.showOperationHours = !detailedDealer.showOperationHours;
        if (detailedDealer.showOperationHours) {
            detailedDealer.detailsLabel = 'LESS DETAILS';
            detailedDealer.detailsIcon = 'utility:chevrondown';
        } else {
            detailedDealer.detailsLabel = 'MORE DETAILS';
            detailedDealer.detailsIcon = 'utility:chevronright';
        }
        this.dealerLocations.splice(indexValue, 1, detailedDealer);
    }

    handleChangeDealerAwards(event) {
        this.selectedDealerAwards = event.detail.value;
        //console.log('selected awards ' + this.selectedDealerAwards);
        //console.log('this.allDlrs ::::>>>> ', this.allDlrs);
        //console.log('this.allMapMarkers ::::>>>> ', this.allMapMarkers);
        this.allFilteredDealers = [];
        this.allFilteredMarkers = [];

        let selectedAwards = [];
        if (this.currentDivisionId === 'A' || this.currentDivisionId === 'B' || this.currentDivisionId === 'M') {
            if (this.selectedDealerAwards === 'ALL' || this.selectedDealerAwards === '0') {
                this.selectedDealerProduct = '0';
                this.dealerAwards.forEach(element => {
                    if (element.value !== '0'  && element.value !== 'HR' && element.value !== 'AR') {//&& element.value !== 'ALL'
                        selectedAwards.push(element.value);
                    }
                });
                //this.allFilteredDealers = this.allDlrs;
                //this.allFilteredMarkers = this.allMapMarkers;
            } else {
                selectedAwards = [this.selectedDealerAwards];
            }
        } else {
            this.allFilteredDealers = this.allDlrs;
            this.allFilteredMarkers = this.allMapMarkers;
        }


        let indx = 0;
        let poiIds = [];
        this.allDlrs.forEach(element => {
            if (element.attributes && element.attributes.length > 0) {
                selectedAwards.forEach(award => {

                 if ((element.attributes.find(att => att.code == award) && !poiIds.includes(element.poiid)) || (award == 'ALL' && !element.attributes.find(att => att.code == 'HR') && !element.attributes.find(att => att.code == 'AR') )) {
                        if (this.selectedDealerProduct && this.selectedDealerProduct != '0' && !element.attributes.find(att => att.code == this.selectedDealerProduct)) {
                            //console.log('this.selectedDealerProduct :::>>>', this.selectedDealerProduct);
                            return;
                        }
                        //console.log('Element : ' + indx + ' : ', element);
                        let dealerRecord = JSON.parse(JSON.stringify(element));
                        dealerRecord.indxVal = indx;
                        dealerRecord.sno = indx + 1;
                        this.allFilteredDealers.push(dealerRecord);
                        poiIds.push(dealerRecord.poiid);
                        this.allFilteredMarkers.push({
                            title: dealerRecord.name,
                            location: {
                                Latitude: dealerRecord.lat,
                                Longitude: dealerRecord.lng
                            }
                        });
                        indx++;
                    }
                });
            }
        });

        this.loadDlrsArray(4);
    }

    handleChangeDealerProduct(event) {
        this.selectedDealerProduct = event.detail.value;
        //console.log('selected product ' + this.selectedDealerProduct);

        this.allFilteredDealers = [];
        this.allFilteredMarkers = [];

        if (this.selectedDealerProduct === '0') {
            this.selectedDealerAwards = 'ALL';
            this.allFilteredDealers = this.allDlrs;
            this.allFilteredMarkers = this.allMapMarkers;
        }

        let indx = 0;
        this.allDlrs.forEach(element => {
            if (element.attributes && element.attributes.length > 0) {
                if (element.attributes.find(att => att.code == this.selectedDealerProduct)) {
                    if (this.selectedDealerAwards && this.selectedDealerAwards != 'ALL' && this.selectedDealerAwards != '0' && !element.attributes.find(att => att.code == this.selectedDealerAwards)) {
                        return;
                    }
                    let dealerRecord = JSON.parse(JSON.stringify(element));
                    dealerRecord.indxVal = indx;
                    dealerRecord.sno = indx + 1;
                    this.allFilteredDealers.push(dealerRecord);
                    this.allFilteredMarkers.push({
                        title: dealerRecord.name,
                        location: {
                            Latitude: dealerRecord.lat,
                            Longitude: dealerRecord.lng
                        }
                    });
                    indx++;
                }
            }
        });

        this.loadDlrsArray(4);
    }

    // SCHEDULE SERVICE LINK COMMENTED AS PER ARUN'S DISCUSSION WITH GRACE
    handleScheduleService(event){
        let url = event.target.dataset.url;
        if(url){
            this.navigate(url,{});
        }
    }

    handleBackClick() {
        sessionStorage.setItem('referrer', document.location.href);

        history.back();
    }

    getproductAttributesCodes = async () => {
        let result = await getProductAttributes();
        //console.log('result', result);
        if (result) {
            result.forEach(element => {
                if (element.DeveloperName == 'SelectaProduct') {
                    this.selectedFilterCode = element.Code__c;
                }
                this.PEProductFilterCodes.push({ value: element.Code__c, label: element.MasterLabel })
            });
            this.PEProductFilterCodes = JSON.parse(JSON.stringify(this.PEProductFilterCodes));
        }
    }

    getServicingDealer(result, poiType) {
        getConsumerProfileInfo().then(consumerResponse => {
            //console.log('consumerResponse : ', consumerResponse);
            if (consumerResponse && consumerResponse.consumerProfiles && consumerResponse.consumerProfiles.length > 0
                && consumerResponse.consumerProfiles[0].dealers && consumerResponse.consumerProfiles[0].dealers.length > 0) {
                let dealerNumber;
                consumerResponse.consumerProfiles[0].dealers.forEach((dealerRecord) => {
                    if (dealerRecord.relation && dealerRecord.relation.toUpperCase() == 'SERVICE' && dealerRecord.dealerNumber) {
                        dealerNumber = dealerRecord.dealerNumber;
                    }
                });
                if (dealerNumber) {
                    getDealerByPoiId({ poiId: dealerNumber, poiType: this.currentDivisionId, ownershipId: this.ownershipId, brand: this.currentBrand, latitude: this.currentLatitude, longitude: this.currentLongitude }).then(serviceDealers => {
                        //console.log('THIS IS SERVICING DEALER : ', serviceDealers);
                        if (serviceDealers.error || !serviceDealers.poiResponse || !serviceDealers.poiResponse.pois || !serviceDealers.poiResponse.pois.poi.length) {
                            //console.log('GOT NO SERVICING DEALERS');
                            this.prepareAllDealersList(result, poiType);
                        } else {
                            //console.log('GOT SERVICING DEALERS');
                            let servicingDealerResult = serviceDealers.poiResponse.pois.poi;
                            if (servicingDealerResult && servicingDealerResult[0]) {
                                servicingDealerResult[0].badges = ['SERVICING DEALER'];
                                servicingDealerResult[0].serviceDealer = true;
                            }
                            result.forEach((element, index) => {
                                if (element.poiid === servicingDealerResult[0].poiid) {
                                    result.splice(index, 1);
                                }
                            });
                            result = [servicingDealerResult[0], ...result];
                            this.prepareAllDealersList(result, poiType);
                        }
                    }).catch(err => {
                        //console.log('Error serviceDealers : ', err);
                        this.prepareAllDealersList(result, poiType);
                    });
                } else {
                    this.prepareAllDealersList(result, poiType);
                }
            } else {
                this.prepareAllDealersList(result, poiType);
            }
        }).catch(err => {
            //console.log('Error consumerResponse : ', err);
            this.prepareAllDealersList(result, poiType);
        })
    }
}
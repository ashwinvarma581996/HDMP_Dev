import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import communityId from '@salesforce/community/Id';
// import getLocation method from Apex Class B2B_EconfigIntegration
import dealerLocatorService from '@salesforce/apex/B2B_EconfigIntegration.dealerLocatorService';
import searchedDealerResponseStored from '@salesforce/apex/B2B_EconfigIntegration.searchedDealerResponseStored';
import setUserAccountAccess from '@salesforce/apex/AccountSelector.SetupExternalManagedAccount';
import getAccountResponse from '@salesforce/apex/B2B_EconfigIntegration.getAccountResponse';
import checkIfUserIsLoggedIn from '@salesforce/apex/B2BGuestUserController.checkIfUserIsLoggedIn';
import updateCartItems from '@salesforce/apex/B2BGuestUserController.updateCartItems';
import GetDealerPrice from '@salesforce/apex/B2B_INSystemIntegration.GetDealerPrice';
// Import message service features required for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import HDMP_MESSAGE_CHANNEL from "@salesforce/messageChannel/HDMPMessageChannel__c";
import { getCurrentVehicle } from 'c/utils';
import getActiveCartItems from '@salesforce/apex/B2BGuestUserController.getActiveCartItems';
import myPNG_icon from '@salesforce/resourceUrl/MapImage';
import getStateCodes from '@salesforce/apex/B2BGuestUserController.getStateCodes';
import getVisualforceOrigin from '@salesforce/apex/B2BGuestUserController.getVisualforceOrigin';
import saveToMyDealerList from '@salesforce/apex/B2B_LoggedInUserMyDealers.saveToMyDealerList';// added by shalini soni for HDMP-212 R2 Story MyDealers
import loggedInuserMyDealersList from '@salesforce/apex/B2B_LoggedInUserMyDealers.loggedInuserMyDealersList'; // added by shalini soni for HDMP-212 R2 Story MyDealers
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id'; // added by shalini soni for HDMP-212 R2 Story MyDealers
import NAME_FIELD from '@salesforce/schema/User.Name'; // added by shalini soni for HDMP-212 R2 Story MyDealers
import { getRecord } from 'lightning/uiRecordApi'; // added by shalini soni for HDMP-212 R2 Story MyDealers
import getBrand from '@salesforce/apex/B2B_VehicleSelectorController.getBrand'; //Added by shalini for HDMP-8290 17-03-2022
import getLoginUrl from '@salesforce/label/c.Identity_Provider_Login_URL';
import getRegisterUrl from '@salesforce/label/c.Identity_Provider_Register_URL';
import isguest from '@salesforce/user/isGuest'
import getCurrentCart from '@salesforce/apex/B2B_HandleCartAndUser.getCurrentCart';
import saveLastDealer from '@salesforce/apex/B2B_ShoppingSelectionController.saveLastDealer';
import getDealerByPOIID from '@salesforce/apex/B2B_ShoppingSelectionController.getDealerByPOIID';
import saveAwardsToDealers from '@salesforce/apex/B2B_ShoppingSelectionController.saveAwardsToDealers';
import { DATALAYER_EVENT_TYPE } from 'c/hdmAdobedtmUtils';//for adobe analytics

export default class SearchLocation extends LightningElement {
    //export default class B2B_EconfigIntegration extends LightningElement {
    mapIcon = myPNG_icon;
    @track dealerName;
    @track mapListofAllPois;
    message;
    errorenable = false;
    @track distanceresponse = [];
    @track dealerresponse = [];
    @api categoryname;
    @track dealerLabel = "Select Your Dealer";
    @track email;
    @track openmodel = false;
    @track showDistance = true;
    @track storedselectedrecordID = ""; //for displaying selected dealer
    @track DealerList;
    @track fireevent = false;
    @track stateresponse = false;
    @track zipcoderesponse = false;
    @track makeDisabled = false;

    @track effectiveAccountId;
    @track searchLocationErrors;
    @track location;
    @track isLoading = false;
    @track charCodeKey;
    @track charCodeKeydealer;
    @track isSelectedDealer = false;
    @track zipCodeBox = true;
    @track citystatebox = false;//added by Yashika for 6836
    @track defaultzipCode = true;
    @track hideBingMap = false;
    @track isLoadedMap = false;
    @track stateOptionList = [];
    @track dealerNumber;
    @track coordinates;
    @track currentTabName;
    zipCode;
    city;
    state
        ;

    @track dealerNumberAwardsMap = new Map();
    @wire(MessageContext)
    messageContext;
    //Added by Shalini Soni 06-10-2021
    @track allDealerValues = { Name: '', Street: '', City: '', State: '', Phone: '', Email: '', operationHours: '', firstName: '', lastName: '', brandName: '', zipCode: '', dealerUrl: '', POIId: '', Id: '', isSavedDealer: false };
    @track selectedDealerCookie;
    @track dealerHourArr = [];
    @track mondayHour;
    @track dealerHours;
    @track brand;
    //End by Shalini Soni
    @track vfPageBingMapURL;
    @track brandType;// added by shalini soni for HDMP-212 R2 Story MyDealers
    @track isFetchData = false; // added by shalini soni for HDMP-212 R2 Story MyDealers
    @track selectedDealerList = []; // added by shalini soni for HDMP-212 R2 Story MyDealers
    @track isDataFetch = false; // added by shalini soni for HDMP-212 R2 Story MyDealers
    @track isShowModal = false; // added by shalini soni for HDMP-212 R2 Story MyDealers
    @track isGuestUser = isguest; // added by shalini soni for HDMP-212 R2 Story MyDealers
    @track brandName;  //Added by shalini for HDMP-8290 17-03-2022
    @wire(getVisualforceOrigin) visualForceOrigin;

    @track radius = '10';
    @track radiusOptions = [
        { label: '10 Miles', value: '10', checked: true },
        { label: '20 Miles', value: '20', checked: false },
        { label: '30 Miles', value: '30', checked: false },
        { label: '40 Miles', value: '40', checked: false },
        { label: '200 Miles', value: '200', checked: false }
    ];


    handleRadiusChange(event) {
        let value = event.target.value;
        this.radius = value;
        let checked = event.detail.checked;
        this.radiusOptions.forEach(item => {
            if (item.value == value) {
                item.checked = checked;
            } else {
                item.checked = !checked;
            }
        });
    }
    openmodal() {


        this.openmodel = true;
    }
    closeModal() {
        this.openmodel = false;
    }
    saveMethod() {
        this.closeModal();
    }
    // added by shalini soni for HDMP-212 R2 Story MyDealers  
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuserdata({
        error,
        data
    }) {
        if (error) {
            this.error = error;
            console.error('Error:', error);
        } else if (data) {
            console.log('### data', data);
            this.userFirstName = data.fields.Name.value;
            console.log('##USER_ID', USER_ID);
            if (USER_ID == undefined || USER_ID == null || this.userFirstName.includes('Guest')) {
                this.isGuestUser = true;
                console.log('##this.myDealersForGuestUser', this.myDealersForGuestUser);
            } else {
                this.isGuestUser = false;
            }
        }
    }
    //Added by Soumya for Cart Management- Login
    redirectToLoginPage() {
        getCurrentCart()
            .then((result) => {
                let pathURL;
                let finalURL;
                if (result !== null && result !== '') {
                    pathURL = '/s/splash?cartId=' + result + '&returnUrl=' + window.location.pathname;
                }
                else {
                    pathURL = '/s/splash?returnUrl=' + window.location.pathname;
                }
                let relayState = localStorage.getItem('relayStateUrl');
                if (relayState && window.location.href.includes('/s/category/')) {
                    localStorage.setItem('fromlogin', 'true');
                    relayState = relayState.substring(relayState.indexOf('/s/'));
                    localStorage.removeItem('relayStateUrl');
                    pathURL = '/s/splash?returnUrl=' + relayState;
                    finalURL = getLoginUrl + '&RelayState=' + pathURL;
                } else {
                    finalURL = getLoginUrl + '&RelayState=' + encodeURIComponent(pathURL);
                }
                //for adobe analytic: starts
                sessionStorage.setItem('eventsForAdobe', 'login success');
                let events = 'login initiation';
                let eventMetadata = {
                    action_type: 'link',
                    action_label: 'login',
                    action_category: 'login'//for adobe bug-17
                };
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events } };
                sessionStorage.setItem('donotCloseModal','true');
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                //adobe: ends
                window.open(finalURL, '_self');
            })
            .catch((error) => {
                console.error('Error:', error);
            });

    } // Ends Here
    // Added by Soumya for Cart Management- Register
    redirectToRegisterPage() {


        getCurrentCart()
            .then((result) => {
                let pathURL;
                if (result !== null && result !== '') {
                    pathURL = '/s/splash?cartId=' + result + '&returnUrl=' + window.location.pathname;
                }
                else {
                    pathURL = '/s/splash?returnUrl=' + window.location.pathname;
                }
                const finalURL = getRegisterUrl + '&RelayState=' + encodeURIComponent(pathURL);
                //for adobe analytic: starts
                sessionStorage.setItem('eventsForAdobe', 'registration success');
                let events = 'register initiation';
                let eventMetadata = {
                    action_type: 'link',
                    action_label: 'register',
                    action_category: 'register'//for adobe bug-17
                };
                const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events } };
                sessionStorage.setItem('donotCloseModal','true');
                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                //adobe: ends
                window.open(finalURL, '_self');
            })
            .catch((error) => {
                console.error('Error:', error);
            });

    }// Ends here

    // added by shalini soni for HDMP-212 R2 Story MyDealers
    /*Below Lines of code commented by Soumya for Cart Management changes 
    redirectToLoginPage() {
        const finalURL = getLoginUrl + '&RelayState=' + window.location.pathname;
        window.open(finalURL, '_self');
    }
    // added by shalini soni for HDMP-212 R2 Story MyDealers
    redirectToRegisterPage() {
        const finalURL = getRegisterUrl + '&RelayState=' + window.location.pathname;
        window.open(finalURL, '_self');
    }
*/
    handleLocationChangedealer(event) {
        console.log('handleLocationChangedealer');


        let charCode = (event.which) ? event.which : event.keyCode;
        this.charCodeKeydealer = charCode === undefined ? this.charCodeKeydealer : charCode;
        console.log('##@@this.charCodeKeydealer', this.charCodeKeydealer);


        // Added Shalini Soni 12 Oct 2021 Task : HDMP:5167
        let validDealer = true;
        if (!(this.charCodeKeydealer != null && this.charCodeKeydealer != undefined && this.charCodeKeydealer != '' && this.charCodeKeydealer != ' ')) {
            validDealer = false;
        }

        if (validDealer && this.charCodeKeydealer == 13) { //Added by Deepak Mali Task:HDMP-3690 "Enter" key should have the same functionality as clicking the main CTA
            console.log('##@@Enter Key Preess');
            this.fireevent = true;
            this.DealerList = [];
            this.errorenable = false;
            // HDMP-13652-Imtiyaz-START
            this.dealerName = event.target.value && event.target.value.trim().length > 0 ? event.target.value.trim() : null;
            this.fireevent = this.dealerName ? this.fireevent : false;
            // HDMP-13652-Imtiyaz-END
            this.selectLocationbyDealer();
        }
        else if (validDealer && !((this.charCodeKeydealer >= 97 && this.charCodeKeydealer <= 122) || (this.charCodeKeydealer >= 65 && this.charCodeKeydealer <= 90) || (this.charCodeKeydealer == 32))) {
            //  console.group('1');
            event.preventDefault();
            return true;
        }
        else {
            //  console.group('2');
            this.fireevent = true;
            this.DealerList = [];
            this.errorenable = false;
            // HDMP-13652-Imtiyaz-START
            this.dealerName = event.target.value && event.target.value.trim().length > 0 ? event.target.value.trim() : null;
            this.fireevent = this.dealerName ? this.fireevent : false;
            // HDMP-13652-Imtiyaz-END
            return false;

        }




    }
    //Added by Deepak Mali Task:HDMP-3690 "Enter" key should have the same functionality as clicking the main CTA
    handleKeyPressLocation(event) {
        console.log('For  Testing ..Deepak Mali')
        let charCode = (event.which) ? event.which : event.keyCode;
        this.charCodeKey = charCode === undefined ? this.charCodeKey : charCode;
        this.errorenable = false;
        console.log('##Enter press1');
        console.log('##Enter charCode', charCode)
        console.log('##Enter press2', this.charCodeKey)
        try {
            this.location = (event.target.value).trim();
            this.zipCode = this.location; //Added by deepak mali 7 Dec
            //START Added Shalini soni 28 Sept
            this.fireevent = true;
            //END 
            if (this.charCodeKey == 13 && !(this.makeDisabled)) {
                if (this.zipCode != undefined && this.zipCode.length > 0) {
                    this.selectLocation();
                }

            }
            // else if (this.charCodeKey == 45){ 
            //  //   this.handleLocation();
            // }
            else if (((this.charCodeKey != 8 && (this.charCodeKey < 48 || this.charCodeKey > 57)))) {
                //Added by deepak mali for HDMP-6369
                let onlyDigit = true;
                Array.from(this.location).forEach(char => {
                    let charCode = char.charCodeAt();
                    if (charCode < 48 || charCode > 57) {
                        onlyDigit = false;
                    }
                })
                if (onlyDigit || this.location.length == 0 || this.location.length > 0) {
                    this.handleLocation();
                }
                event.preventDefault();
                return true;
                //Ended


            } else {
                this.DealerList = [];
                this.handleLocation();
            }
        } catch (error) {
            console.error(error);
        }
    }
    // Added by Deepak Mali for :HDMP-7251
    handleBlur(event) {
        this.zipCode = (event.target.value).trim();
        console.log('#zipCode ', this.zipCode);
    }


    isUSZipCode(str) {
        const regexp = /^[0-9]{5}(?:-[0-9]{4})?$/;
        if (regexp.test(str)) {
            return true;
        }
        return false;
    }

    isCityState(str) {
        if ((typeof str === 'string' || str instanceof String) && (str.indexOf(',') > -1 || str.indexOf(' ') > -1)) {
            return true;
        }
        return false;
    }

    handleLocation() {

        let zip = this.template.querySelector('.ZipCode');
        let onlyNumber = /^\d+$/.test(this.location);
        zip.setCustomValidity("");
        //Zip Code Validation
        if ((onlyNumber && (this.location.length == 5))) {
            console.log('1');
            zip.setCustomValidity("");
            zip.reportValidity();
            this.makeDisabled = false;
            this.zipcoderesponse = true;
            this.zipCode = this.location;
            this.city = '';
            this.state = '';
        } else if (this.location.length > 0 && this.location.length < 5) {
            zip.setCustomValidity("");
            this.makeDisabled = false;
            zip.reportValidity();
        } else {
            if (this.location.length > 0) {
                this.makeDisabled = true;
                zip.setCustomValidity("Please enter 5 digit zip code.");
                zip.reportValidity();
            } else {
                zip.setCustomValidity("");
                zip.reportValidity();
                this.makeDisabled = false;
            }

        }
        // else if ((this.location.length == 6 && this.charCodeKey == 45) ) {
        //     console.log('Enter Hyphen');
        //     zip.setCustomValidity("");
        //     this.makeDisabled = false;
        //     zip.reportValidity();
        // } 
    }

    //setting service for attribute for all pages 
    connectedCallback() {
        this.vfPageBingMapURL = window.location.origin + '/bingMapVfPage'
        if (!sessionStorage.getItem('brand')) {// Added if-else condition by deepak mali for HDMP-8647
            this.getBrandDetails();  //Added by shalini for HDMP-8290 17-03-2022
        } else {
            this.brandName = sessionStorage.getItem('brand');
        }

        let catValue = sessionStorage.getItem('brand');
        let baseurl = window.location.href.split('/').pop();
        let carturl = window.location.href.includes('cart') ? true : false;
        let cartservicefor = localStorage.getItem('cartBrand');
        window.addEventListener("message", this.handleResponse.bind(this), false);

        this.brand = sessionStorage.getItem('brand');
        console.log('##@@brand', this.brand);
        let allDealerList = [];

        // START 7615
        console.log('##@@allDealerList', sessionStorage.getItem('SELECTED_DEALER'));

        console.log('##@@call72', this.allDealerValues);

        if (carturl) {

            if (cartservicefor && carturl) {
                this.categoryname = cartservicefor;
            }

            else {
                this.categoryname = catValue;
            }
        }
        else {
            if (catValue) {
                this.categoryname = catValue;
            }
            else {

                if (baseurl == 'honda') {
                    this.categoryname = baseurl;
                }
                else {
                    this.categoryname = baseurl;
                }
            }
        }
        this.getLoggedInuserMyDealersList(); // added by shalini soni for HDMP-212 R2 Story MyDealers
        this.initialize();
    }
    initialize = async () => {
        await this.getUserCoordinates();
    }
    async getUserCoordinates() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
                let latitude = position.coords.latitude;
                let longitude = position.coords.longitude;
                this.coordinates = { latitude: latitude, longitude: longitude };
                console.log('$SL: latitude: ', latitude);
                console.log('$SL: longitude: ', longitude);
                console.log('$SL: coordinates: ', JSON.parse(JSON.stringify(this.coordinates)));
            }, error => {
                console.log('$SL: error: ', error);
            },
                { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 });
        }
    }
    selectLocation() {
        //Start-Added by imtiyaz to fix bug HDMP-16645
        if (this.template.querySelector('.ZipCode') != null) {
            this.location = this.template.querySelector('.ZipCode').value;
            this.zipCode = this.location;
        }
        //End-Added by imtiyaz to fix bug HDMP-16645

        if (!this.location && this.zipCodeBox) {
            this.errorenable = true;
            this.searchLocationErrors = 'No results found. Enter Zip code';
            this.DealerList = [];
            this.isLoading = false;
            return;
        }
        //console.log('##this.categoryname', this.categoryname);
        //console.log('##this.dealerame', this.dealerName);
        this.showDistance = true;
        this.isLoading = true;
        //console.log('## Called selectLocation');
        //console.log('##2zipCode', this.zipCode);

        // console.log('##1categoryname', this.categoryname);
        // console.log('##zipCode', this.zipCode);
        // console.log('##city', this.city);
        // console.log('##state', this.state);
        // console.log('##dealerName', this.dealerName);

        //Start-Added by imtiyaz to fix ipad issue And One More bug HDMP-16645
        if (this.template.querySelector('.city-name') != null) {
            this.city = this.template.querySelector('.city-name').value.trim();
        }
        //End-Added by imtiyaz to fix ipad issue And One More bug HDMP-16645

        if (!(this.zipCodeBox) && !(this.city && this.state)) {
            console.log('City and State both required..');
            this.errorenable = true;
            this.searchLocationErrors = 'No results found. Please re-enter your City and State';
            this.DealerList = [];
            this.isLoading = false;
            return true;
        }
        try {
            console.log('##2fireevent', this.fireevent);
            if (this.zipCode == undefined) {
                this.zipCode = '';
                //  this.fireevent = false;
                this.isLoading = false;
            }
            if (this.zipCode == undefined) {
                this.errorenable = true;
                this.isLoading = false;
                this.DealerList = '';
                this.distanceresponse = '';
                this.location = '';

            }


            else {

                console.log('##1categoryname', this.categoryname);
                console.log('##zipCode', this.zipCode);
                console.log('##city', this.city);
                console.log('##state', this.state);
                console.log('##dealerName', this.dealerName);

                dealerLocatorService({
                    serviceFor: this.categoryname,
                    zipCode: this.zipCode,
                    city: this.city,
                    state: this.state,
                    dealerName: this.dealerName,
                    radius: this.radius

                }).then(result => {

                    if (result.isError) {

                        this.zipCode = '';
                        this.location = '';
                        this.errorenable = true;
                        this.isLoading = false;
                        this.distanceresponse = '';


                    } else {

                        // this.zipCode = '';
                        // this.location = '';
                        this.errorenable = false;
                        console.log('$SL: errorenable4', this.errorenable);

                        this.isLoading = false;
                        //Added Deepak Mali 2 Nov 2021
                        //modified this if by Yashika for 6836 : starts here
                        if (this.citystatebox == true || this.zipCodeBox == true) {
                            this.showDistance = true;
                        }//ends here
                        const output = JSON.parse(result);
                        this.mapListofAllPois = output.mapListofAllPois;
                        console.group('ONLY DM Consoles')
                        console.group('RESULT BEFORE FILTER' + JSON.stringify(this.mapListofAllPois))
                        // commented this line by shalini soni for HDMP-8258 to get the dealers data with all code property
                        // this.mapListofAllPois = this.mapListofAllPois.filter(item => item.Attributes.Attribute[0].Code == 'DA' || item.Attributes.Attribute[0].Code == 'DB') 
                        // console.group('RESULT ' + JSON.stringify(this.mapListofAllPois))
                        if (this.mapListofAllPois.length == 0) {


                            this.errorenable = true;
                            this.isLoading = false;
                            if (output) {

                                //   console.group('this.zipCodeBox',this.zipCodeBox);
                                console.group('Error Message ', output.message);

                                if (this.zipCodeBox && (output.message && output.message.toLowerCase().includes('no matching results found in the datasource')
                                    || output.message.includes('Invalid StateCd for City/State Search.')
                                    || output.message.includes('Not enough information in the search request to locate a POI.')
                                    || output.message && output.message.toLowerCase().includes('location not found.')
                                    || output.message && output.message.toLowerCase().includes('invalid zipcode.')
                                )) {
                                    console.group('if');
                                    this.searchLocationErrors = 'No locations were found. Please check your Zip Code and resubmit.';
                                } else if (!this.zipCodeBox && (output.message && output.message.toLowerCase().includes('location not found.') ||
                                    output.message && output.message.includes('Invalid StateCd for City/State Search.')) ||
                                    output.message && output.message.includes('Not enough information in the search request to locate a POI.') ||
                                    output.message.toLowerCase().includes('no matching results found in the datasource')) {
                                    console.group('else');
                                    //  this.searchLocationErrors = 'No dealers were found matching that information. Please check your entry and resubmit';
                                    this.searchLocationErrors = 'No results found. Please re-enter your City and State';
                                } else {
                                    this.searchLocationErrors = output.message;
                                }
                            }
                            console.groupEnd(); console.groupEnd(); console.groupEnd(); console.groupEnd(); console.groupEnd(); console.groupEnd();
                            //Added by Shalini soni 29 Sept 
                            this.DealerList = [];
                            let locationList = [];    //Added by deepak mali for : 6383 dealer map displaying 
                            this.sendMessgaeToVisualForce(locationList, true);  //End


                            // this.searchLocationErrors = output.message;
                        }

                        else {
                            this.searchLocationErrors = '';

                            let LocationObject = [];
                            this.mapListofAllPois.forEach(element => {
                                let locobj = {};

                                locobj = ({ 'POIId': element.POIId, 'Distance': element.Distance.split(" ")[0], 'InternetAddress': element.InternetAddress });
                                LocationObject.push(locobj);

                            });
                            this.distanceresponse = LocationObject;




                            this.openmodel = true;




                            getAccountResponse({

                                Inputparams: this.distanceresponse
                            }).then(result => {

                                //START Added Deepak Mali 27 Oct 2021
                                try {
                                    let accRecordAndResponceList = []
                                    //commented by Saikiran as part of HDMP-10723
                                    // result.forEach(accRecord => {
                                    //     this.mapListofAllPois.forEach(element => {
                                    //         if (element.POIId == accRecord.accountList.PoIId__c) {
                                    //             let contactName = element.firstName + ' ' + element.lastName;
                                    //             let operationHours = JSON.parse(element.partOperationHour)[0].text.replace(/\s+/g, ' ');
                                    //             operationHours = operationHours.replaceAll(';', ';  ');
                                    //             accRecordAndResponceList.push({ ...accRecord, 'contactName': contactName, 'operationHour': operationHours.split(';'), 'dealerEmail': element.dealerEmail });
                                    //         }
                                    //     });
                                    // });
                                    //updated by Saikiran as per displaying Dealer in map and card in same order HDMP-10723
                                    this.mapListofAllPois.forEach(element => {
                                        result.forEach(accRecord => {
                                             // Pratik LTIM Added for SP4 Tax Jurisdications
                                            //Lakshmi HDMP-19445
                                            if(accRecord.accountList.Sales_Tax_Jurisdiction__c){
                                                if(accRecord.accountList.Sales_Tax_Jurisdiction__c.split(';').length > 50){
                                                    accRecord.shippingtaxstate = 'All 50 States';
                                                }else{
                                                    accRecord.shippingtaxstate = accRecord.accountList.Sales_Tax_Jurisdiction__c.replaceAll(';',','); // Lakshmi LTIM for HDMP-19454,HDMP-19445

                                                }
                                            }else{
                                                accRecord.shippingtaxstate = accRecord.accountList.BillingState; // Lakshmi LTIM for HDMP-19454,HDMP-19445,HDMP-19495
                                            }
                                            // Pratik LTIM Added for SP4 Tax Jurisdications

                                            if (element.POIId == accRecord.accountList.PoIId__c) {
                                                let contactName = element.firstName + ' ' + element.lastName;
                                                let operationHours = JSON.parse(element.partOperationHour)[0].text.replace(/\s+/g, ' ');
                                                operationHours = operationHours.replaceAll(';', ';  ');
                                                accRecordAndResponceList.push({ ...accRecord, 'contactName': contactName, 'operationHour': operationHours.split(';'), 'dealerEmail': element.dealerEmail });
                                            }
                                        });
                                    });
                                    this.DealerList = this.getSavedToMyDealers(accRecordAndResponceList);// added by shalini soni for HDMP-212 R2 Story MyDealers

                                    console.log('##DM DealerList2 ', JSON.parse(JSON.stringify(this.DealerList)));

                                    //Added by deepak mali for : 6383 dealer map displaying 
                                    this.sendMessgaeToVisualForce(this.mapListofAllPois, true);
                                    //End

                                    this.errorenable = false;
                                    this.isLoading = false;

                                } catch (error) {
                                    console.error(error.message);
                                }
                                //END 
                                this.errorenable = false;
                                this.isLoading = false;




                                this.refreshData();
                            }).catch(error => {
                                console.log('in error block');
                                this.error = this.errorenable;
                                this.isLoading = false;

                                console.error("error", JSON.stringify(error));
                            });
                        }

                    }

                }).catch(error => {
                    console.error("error", JSON.stringify(error));
                    this.isLoading = false;
                });

            }
            //For adobe analytics:start
            let eventMetadata = {
                action_type: 'button',
                action_label: 'dealer search',
                action_category: 'dealer search'//For adobe bug-03
            };
            let dealer = {
                dealer_locator_search_type: this.zipCodeBox ? 'zip code' : 'city/state',
                dealer_locator_search_term: this.zipCodeBox ? this.zipCode : `${this.city}/${this.state}`
            }
            let events = 'dealer search';
            const message1 = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events, dealer: dealer } };
            sessionStorage.setItem('donotCloseModal','true');
            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message1);
            //adobe analytics:end
        } catch (error) {
            console.log(error.message);
        }
        this.refreshData();

    }



    ClearData() {
        this.dealerName = '';
        this.zipCode = '';
        this.location = '';
        this.city = '';
        this.state = '';

        console.log('##this.location', this.location);
        console.log('##this.categoryname1', this.categoryname);
        console.log('##this.dealerame1', this.dealerName);
        console.log('##this.zipCode', this.zipCode);
        console.log('##this.city', this.city);
        this.errorenable = false;
        this.DealerList = [];
        this.makeDisabled = false; //Added by deepak 7 Dec
        // this.allDealerValues = '';
        //Start-Added by imtiyaz for HDMP-16588
        if (this.template.querySelector('.ZipCode') != null) {
            let validity = this.template.querySelector('.ZipCode');
            validity.setCustomValidity("");
            validity.reportValidity();
        }
        if (this.template.querySelector('.state') != null) {
            let stateCmp = this.template.querySelector('.state');
            stateCmp.value = '';
        }
        this.refreshData();
        //End-Added by imtiyaz for HDMP-16588

        //  validity.setCustomValidity("");
        // this.template.querySelector('.ZipCode').value = null;
        // this.template.querySelector('.Dealer').value = null;
    }
    refreshData() {
        /* if (this.template.querySelector('.ZipCode') != null) {
            this.template.querySelector('.ZipCode').value = '';
        }
        if (this.template.querySelector('.Dealer') != null) {
            this.template.querySelector('.Dealer').value = '';
        }
        if (this.template.querySelector('.state') != null) {
        this.template.querySelector('.state').value = '';
        }
        if (this.template.querySelector('.city-name') != null) {
            this.template.querySelector('.city-name').value = '';
        }
        this.location = '';
        this.state = '';
        this.city = '';
        this.dealerName = '';
        this.dealerresponse = [];
        this.errorenable = false;
        if (this.errorenable == true) {
            this.DealerList = [];
        } */
    }
    selectLocationbyDealer() {
        // For adobe bug - 04: start
        let eventMetadata = {
            action_type: 'button',
            action_label: 'dealer search',
            action_category: 'dealer search'
        };
        let dealer = {
            dealer_locator_search_type: 'name',
            dealer_locator_search_term: this.dealerName

        }
        let events = 'dealer search';
        const message = { message: { 'eventType': DATALAYER_EVENT_TYPE.CLICK, 'eventMetadata': eventMetadata, 'events': events, 'dealer': dealer } };
         sessionStorage.setItem('donotCloseModal','true');
         // setTimeout(() => {
        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
        // }, 2000);

        // // adobe analytics: end
        // HDMP-13652-Imtiyaz-START
        let dealerText = this.template.querySelector('.Dealer').value;
        dealerText = dealerText && dealerText.trim().length > 0 ? dealerText : null;
        if (!dealerText) {
            this.dealerName = null;
            this.fireevent = false;
        }
        // HDMP-13652-Imtiyaz-END

        this.isLoading = true;
        console.log('##this.categoryname2', this.categoryname);
        console.log('##this.dealerame2', this.dealerName);
        console.log('###isLoading ', this.isLoading);
        console.log('###fireevent ', this.fireevent);
        if (this.fireevent == false) {
            console.log('no fire evnt ');
            if (!this.dealerName) {
                this.errorenable = true;
                this.DealerList = '';
                this.distanceresponse = '';
                this.isLoading = false;
                this.searchLocationErrors = '';
                return;

            }
        }
        else if (this.fireevent != false) {
            if (this.dealerName == 'undefined' || this.dealerName == '') {
                this.errorenable = true;
                this.DealerList = '';
                this.distanceresponse = '';
                this.isLoading = false;
                this.searchLocationErrors = '';
                this.isSelectedDealer = false;
                let locationList = [];    //Added by deepak mali for : 6383 dealer map displaying 
                this.sendMessgaeToVisualForce(locationList, true);
                //End
                return;

            }
            else {
                console.log('##this.categoryname', this.categoryname);
                console.log('##this.dealerame', this.dealerName);
                dealerLocatorService({
                    serviceFor: this.categoryname,

                    dealerName: this.dealerName,
                    radius: this.radius
                }).then(result => {
                    const output = JSON.parse(result);
                    if (output && output.mapListofAllPois && Array.isArray(output.mapListofAllPois)) {
                        output.mapListofAllPois.forEach(dealer => {
                            if (dealer.Awards && dealer.Awards.length) {
                                this.dealerNumberAwardsMap.set(dealer.POIId, dealer.Awards);
                            }
                        });
                    }
                    this.mapListofAllPois = output.mapListofAllPois;
                    console.log('ALL RESULT BEFORE FILTER-->', JSON.stringify(output) + JSON.stringify(this.mapListofAllPois));
                    console.log('ALL RESULT BEFORE FILTER-->11', JSON.parse(JSON.stringify(this.mapListofAllPois)));
                    // commented this line by shalini soni for HDMP-8258 to get the dealers data with all code property
                    // this.mapListofAllPois = this.mapListofAllPois.filter(item => item.Attributes.Attribute[0].Code == 'DA' || item.Attributes.Attribute[0].Code == 'DB')
                    console.log('ALL RESULT BEFORE FILTER-->12', JSON.parse(JSON.stringify(this.mapListofAllPois)));
                    //Added by deepak mali for : 6383 dealer map displaying 
                    //START
                    if (this.mapListofAllPois && this.mapListofAllPois.length && this.coordinates && this.currentTabName == 'Search By Dealer Name') {
                        console.log('$SL: C: mapListofAllPois: ', JSON.parse(JSON.stringify(this.mapListofAllPois)));
                        console.log('$SL: C: coordinates: ', JSON.parse(JSON.stringify(this.coordinates)));
                        this.mapListofAllPois.forEach(dlr => {
                            dlr.distanceInMiles = this.getDistanceFromLatLonInKm(this.coordinates.latitude, this.coordinates.longitude, parseFloat(dlr.Latitude), parseFloat(dlr.Longitude), 'MILES');
                            dlr.distanceInKilometers = this.getDistanceFromLatLonInKm(this.coordinates.latitude, this.coordinates.longitude, parseFloat(dlr.Latitude), parseFloat(dlr.Longitude), 'KILOMETERS');
                        });
                        console.log('$SL: C: mapListofAllPois_WITH_DISTANCE: ', JSON.parse(JSON.stringify(this.mapListofAllPois)));
                        this.mapListofAllPois = this.mapListofAllPois.sort(function (a, b) { return parseFloat(a.distanceInMiles) - parseFloat(b.distanceInMiles) });
                        console.log('$SL: C: mapListofAllPois_WITH_DISTANCE_SORTED: ', JSON.parse(JSON.stringify(this.mapListofAllPois)));
                    }
                    //END

                    this.sendMessgaeToVisualForce(this.mapListofAllPois, true);
                    //End

                    this.isLoading = false;
                    //---------START ------Added by Deepak Mali 15 Aug 2021
                    if (this.mapListofAllPois.length == 0) {
                        this.errorenable = true;
                        this.isLoading = false;
                        if (output) {
                            if (output.message && output.message.toLowerCase().includes('no matching results found in the datasource')) {
                                this.searchLocationErrors = 'No dealers were found matching that information. Please check your entry and resubmit.';
                            } else {
                                this.searchLocationErrors = output.message;
                            }
                        }
                        // this.searchLocationErrors = output.message;
                    } else {
                        this.searchLocationErrors = '';
                    }
                    //---------END ------Added by Deepak Mali 15 Aug 2021
                    let tempdata = [];
                    for (let i = 0; i < this.mapListofAllPois.length; i++) {
                        let DealerObject = {};


                        DealerObject = ({ 'POIId': this.mapListofAllPois[i].POIId, 'Distance': this.mapListofAllPois[i].Distance.split(" ")[0], 'InternetAddress': this.mapListofAllPois[i].InternetAddress });
                        tempdata.push(DealerObject);

                    }
                    this.dealerresponse = tempdata;


                    this.openmodel = true;

                    if (this.dealerresponse == '' || this.dealerresponse == 'null' || this.dealerresponse == 'undefined') {

                        this.errorenable = true;
                        this.isLoading = false;
                        if (output) {
                            if (output.message && output.message.toLowerCase().includes('no matching results found in the datasource')) {
                                this.searchLocationErrors = 'No dealers were found matching that information. Please check your entry and resubmit.';
                            } else {
                                this.searchLocationErrors = output.message;
                            }
                        }
                        // this.searchLocationErrors = output.message;
                    } else {
                        this.searchLocationErrors = '';

                        getAccountResponse({

                            Inputparams: this.dealerresponse
                        }).then(result => {

                            let finaldata = result;

                            for (let i = 0; i < finaldata.length; i++) {
                                if (finaldata[i].Distance == '0.0') {

                                    finaldata[i].Distance = '';
                                    this.showDistance = false;
                                }
                            }

                            //START Added Deepak Mali 27 Oct 2021
                            try {
                                let accRecordAndResponceList = []
                                //commented by Saikiran as part of HDMP-10723
                                // result.forEach(accRecord => {
                                //     this.mapListofAllPois.forEach(element => {
                                //         if (element.POIId == accRecord.accountList.PoIId__c) {
                                //             let contactName = element.firstName + ' ' + element.lastName;
                                //             let operationHours = JSON.parse(element.partOperationHour)[0].text.replace(/\s+/g, ' ');
                                //             operationHours = operationHours.replaceAll(';', ';  ');
                                //             accRecordAndResponceList.push({ ...accRecord, 'contactName': contactName, 'operationHour': operationHours.split(';'), 'dealerEmail': element.dealerEmail });
                                //         }
                                //     });
                                // });
                                //updated by Saikiran as per displaying Dealer in map and card in same order HDMP-10723
                                this.mapListofAllPois.forEach(element => {
                                    result.forEach(accRecord => {
                                        // Pratik LTIM Added for SP4 Tax Jurisdications
                                         //console.log('Values---'+accRecord.accountList.Sales_Tax_Jurisdiction__c.split(';') > 50);
                                         //Lakshmi HDMP-19454, HDMP-19445 for salesTax jurisdiction
                                         if(accRecord.accountList.Sales_Tax_Jurisdiction__c){
                                            if(accRecord.accountList.Sales_Tax_Jurisdiction__c.split(';').length > 50){
                                                accRecord.shippingtaxstate = 'All 50 States';
                                            }else{
                                                accRecord.shippingtaxstate = accRecord.accountList.Sales_Tax_Jurisdiction__c.replaceAll(';',',');
                                            }
                                        } else{
                                                accRecord.shippingtaxstate = accRecord.accountList.BillingState; //Lakshmi HDMP-19495
                                            }
                                        // Pratik LTIM Added for SP4 Tax Jurisdications
                                        if (element.POIId == accRecord.accountList.PoIId__c) {
                                            let contactName = element.firstName + ' ' + element.lastName;
                                            let operationHours = JSON.parse(element.partOperationHour)[0].text.replace(/\s+/g, ' ');
                                            operationHours = operationHours.replaceAll(';', ';  ');
                                            accRecordAndResponceList.push({ ...accRecord, 'contactName': contactName, 'operationHour': operationHours.split(';'), 'dealerEmail': element.dealerEmail });
                                        }
                                    });
                                });
                                this.DealerList = this.getSavedToMyDealers(accRecordAndResponceList); // added by shalini soni for HDMP-212 R2 Story MyDealers
                                // console.log('$SL: DealerList2: ',JSON.parse(JSON.stringify(this.DealerList)));
                                // console.log('$SL: C: DealerList: ',JSON.parse(JSON.stringify(this.DealerList)));
                                // console.log('##DM DealerList1 ', JSON.stringify(this.DealerList));

                                if (this.mapListofAllPois && this.mapListofAllPois.length && this.coordinates && this.currentTabName == 'Search By Dealer Name') {
                                    console.log('$SL: C: mapListofAllPois_ACC: ', JSON.parse(JSON.stringify(this.mapListofAllPois)));
                                    let tempArray = [];
                                    this.mapListofAllPois.forEach(dlr => {
                                        let currentRecord = this.DealerList.find(ele => {
                                            return dlr.POIName == ele.accountList.Name;
                                        });
                                        if (currentRecord) {
                                            currentRecord.Distance = this.numberWithCommas(parseFloat(dlr.distanceInMiles).toFixed(1));
                                            currentRecord.Sort = dlr.distanceInMiles;
                                            tempArray.push(currentRecord);
                                        }
                                    });
                                    tempArray = tempArray.sort(function (a, b) { return parseFloat(a.Sort) - parseFloat(b.Sort) });
                                    console.log('$SL: C: tempArray: ', JSON.parse(JSON.stringify(tempArray)));
                                    this.DealerList = tempArray;
                                    this.showDistance = this.coordinates && this.currentTabName == 'Search By Dealer Name' ? true : false;
                                }
                                this.errorenable = false;
                                this.isLoading = false;
                            } catch (error) {
                                console.error(error.message);
                            }
                            //END 

                        }).catch(error => {

                            this.error = this.errorenable;
                            this.isLoading = false;

                            console.error("error", JSON.stringify(this.error));
                        });
                        this.refreshData();

                    }
                }).catch(error => {
                    console.error("error", JSON.stringify(error));
                    this.isLoading = false;
                });
            }
        }
        this.showDistance = true;
        this.refreshData();
    }
    saveToMyDealersfromAlreadySelected(event) {
        try {
            var dealerId = event.currentTarget.dataset.id;
            var DealerPOIId = event.currentTarget.dataset.dealerno;
            console.log('##dealerNo', DealerPOIId); console.log('##dealerId', dealerId);
            if (this.brand == 'Honda') {
                this.brandType = 'A';
            } else if (this.brand == 'Acura') {
                this.brandType = 'B';
            }
            saveToMyDealerList({ accountId: dealerId, divisionType: this.brandType })
                .then(result => {
                    if (result.error == false) {
                        this.selectedDealerList = result.accountList;
                        let allDealerList = [];
                        this.allDealerValues['isSavedDealer'] = true; // creating new property to hide/show button
                        allDealerList.push(this.allDealerValues);
                        sessionStorage.setItem('selectedDealer', JSON.stringify(allDealerList));
                        this.isShowModal = true;
                        setTimeout(() => {
                            this.isShowModal = false;
                        }, 3000);
                    } else if (result.error == true) {
                        console.error(result.errorMessage);
                    }
                })
                .catch(error => {
                    console.error(error);
                    this.showToastMessage('Error', error.message, 'error');
                })
                .finally(() => {
                    this.isLoading = false;
                })
        } catch (error) {
            console.error(error.message);
        }
    }
    // added by shalini soni for HDMP-212 R2 Story MyDealers -> To save dealers in myDealers tab
    saveToMyDealers(event) {
        let accountId = event.target.name;
        let DealerPOIId = event.currentTarget.dataset.dealerno;
        if (this.dealerNumberAwardsMap.has(DealerPOIId)) {
            let awards = this.dealerNumberAwardsMap.get(DealerPOIId);
            console.log('$SL: awards: ', awards);
            let awardNames = '';
            awards.forEach(award => {
                awardNames = awardNames + (awardNames ? ', ' : '') + award.FriendlyName
            });
            console.log('$SL: awardNames: ', awardNames);
            if (awardNames) {
                saveAwardsToDealers({ acc: { Id: accountId, B2B_Dealer_Award__c: awardNames } }).then((result) => {
                    console.log('$SL: result: ', result);
                }).catch((error) => {
                    console.error('$SL: error: ', error);
                });
            }
        }
        if (this.brand == 'Honda') {
            this.brandType = 'A';
        } else if (this.brand == 'Acura') {
            this.brandType = 'B';
        }
        saveToMyDealerList({ accountId: accountId, divisionType: this.brandType })
            .then(result => {
                if (result.error == false) {
                    this.selectedDealerList = result.accountList;
                    this.DealerList.find((item) => {
                        if (item.accountList.PoIId__c == DealerPOIId) {
                            item.accountList['isSavedDealer'] = true; // creating new property to hide/show button
                        }
                    });
                    //* Added 1 April
                    let poiList = [];
                    if (this.selectedDealerList && this.selectedDealerList != null) {
                        this.selectedDealerList.forEach(acc => {
                            poiList.push(acc.PoIId__c);
                        });
                    }

                    if (poiList.includes(this.allDealerValues.POIId)) {
                        this.allDealerValues['isSavedDealer'] = true; // creating new property to hide/show button
                    } else {
                        this.allDealerValues['isSavedDealer'] = false;
                    }
                    //Ends
                    console.log('##Result ', this.selectedDealerList);
                    this.isShowModal = true;
                    setTimeout(() => {
                        this.isShowModal = false;
                    }, 3000);
                } else if (result.error == true) {
                    console.error(result.errorMessage);
                }
            })
            .catch(error => {
                console.error(error);
                this.showToastMessage('Error', error.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            })
    }
    // added by shalini soni for HDMP-212 R2 Story MyDealers -> To get all saved dealers list on page load 
    getLoggedInuserMyDealersList() {
        this.isLoading = true;
        if (this.brand == 'Honda') {
            this.brandType = 'A';
        } else if (this.brand == 'Acura') {
            this.brandType = 'B';
        }
        loggedInuserMyDealersList({
            divisionType: this.brandType
        }).then(result => {
            console.log('##result', result);
            if (result && result.length > 0) {
                this.selectedDealerList = result;
                console.log('##Result from Server ', this.selectedDealerList);
            } else {
                this.selectedDealerList = null;
            }

            //* Added by Shalini 31 March 2022
            let allDealerList = JSON.parse(sessionStorage.getItem('selectedDealer'));
            let selectedDealerRecord;
            if (sessionStorage.getItem('selectedDealer')) {
                if (allDealerList && allDealerList.length > 0 && allDealerList != 'undefined') {

                    allDealerList.forEach(element => {
                        if (element.brandName == this.brand) {
                            selectedDealerRecord = element;
                        }
                    });

                    
                }
            }
            this.allDealerValues = selectedDealerRecord || {};

            if (selectedDealerRecord && selectedDealerRecord != null) {
                if (this.allDealerValues.operationHours) {
                    let opHour = this.allDealerValues.operationHours;
                    this.dealerHours = opHour.split(';');
                    let trackname = opHour.split(";");
                    this.mondayHour = trackname[0];
                }
                console.log('##@@ allDealerList', allDealerList);
                this.isSelectedDealer = true;
            }
            console.log('##@@ allDealerList test values', allDealerList);
            let poiList = [];
            if (this.selectedDealerList && this.selectedDealerList != null) {
                this.selectedDealerList.forEach(acc => {
                    poiList.push(acc.PoIId__c);
                });
            }
            console.log('##@@ selectedDealerList', this.selectedDealerList);
            console.log('##@@ poiList', poiList);
            console.log('##@@ allDealerValues', this.allDealerValues);

            if (poiList.includes(this.allDealerValues.POIId)) {
                this.allDealerValues['isSavedDealer'] = true; // creating new property to hide/show button
            } else {
                this.allDealerValues['isSavedDealer'] = false;
            }
            //* Ends

            this.isLoading = false;
        })
            .catch(error => {
                //this.showToastMessage('Error', error.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
                this.isFetchData = true;
            })
    }
    // added by shalini soni for HDMP-212 R2 Story MyDealers -> To return the list of all selected dealers after api call 
    getSavedToMyDealers(allDealersLists) {
        if (this.selectedDealerList) {
            let poiList = [];
            this.selectedDealerList.forEach(acc => {
                poiList.push(acc.PoIId__c);
            });
            allDealersLists.find((item) => {
                if (poiList.includes(item.accountList.PoIId__c)) {
                    console.log('##In IF', item.accountList.PoIId__c);
                    item.accountList['isSavedDealer'] = true; // creating new property to hide/show button
                }
            });
            console.log('##@@ selectedDealer ', JSON.parse(JSON.stringify(allDealersLists)));
            return allDealersLists;
        }
        return allDealersLists;
    }
    //Added by shalini for HDMP-8290 17-03-2022
    async getBrandDetails() {
        let storedCartId = localStorage.getItem('cartId');
        if (storedCartId) {
            await getBrand({
                cartId: storedCartId
            }).then(result => {
                if (result) {
                    let brand = result;
                    this.brandName = brand;
                }
            }).catch(error => {

            })
        }
    }

    clickAccount(event) {
        this.isLoading = true;
        const selectedRecordId = event.target.name.substring(0, 15);
        const dealerLabel = event.target.getAttribute('data-title');
        const dealerNo = event.target.getAttribute('data-dealerno');
        this.createCookie('dealerLabel', '', 1); // Clear cookie first
        this.createCookie('dealerLabel', dealerLabel, 1);
        let dealerName = dealerLabel;
        this.dealerNumber = dealerNo;
        this.effectiveAccountId = selectedRecordId;
        let brand = sessionStorage.getItem('brand');
        this.buildEffectiveDealer(brand, this.effectiveAccountId, dealerLabel, dealerNo);

        let checkDealerPriceUpdated = false;

        //  this.storedselectedrecordId = this.setCookie('selectedRecordId'); //for dealer info display on button
        console.log('EVENT DETAIL ::'+ JSON.stringify(event.target));

        let vehicle = getCurrentVehicle();
        let brandDivision;
        let products;

        //Added by shalini for HDMP-8290 17-03-2022
        if (!vehicle) {

            if (this.brandName) {
                brandDivision = this.brandName == 'Honda' ? 1 : 2;
            }
        } else {
            brandDivision = vehicle.iNDivisionID__c;
        }
        if (brandDivision) {


            products = JSON.parse(sessionStorage.getItem('products'));
            console.log('$SL: searchLocations: products1', products);
            // products = products ? products : JSON.parse(localStorage.getItem('prodjson'));
            console.log('$SL: searchLocations: products2 ', products);
            let accessories = JSON.parse(sessionStorage.getItem('accessories'))
            console.log('$SL: accessories: ', accessories);

            let partNumberList = [];
            let opCodeList = []; //Added by Bhawesh  16-02-2022 for BugNo. DPS-46
            if (products && products.Parts) {
                products.Parts.forEach(part => {
                    partNumberList.push(part.PartNumber);
                });
            }
            //Added by Bhawesh  16-02-2022 for BugNo. DPS-46 start
            if (accessories && accessories.Accessory) {
                accessories.Accessory.forEach(accessory => {
                    if (accessory && accessory.op_cd) {
                        opCodeList.push(accessory.op_cd);
                    }
                });
            }
            //End
            setUserAccountAccess({
                accountId: selectedRecordId
            })
                .then((result) => {
                    console.log('opCodeList', JSON.stringify(opCodeList));
                    this.closeModal();
                    if ((products || accessories) && ((partNumberList && partNumberList.length > 0) || (opCodeList && opCodeList.length > 0))) {
                        let uniquePartNumberList = partNumberList.filter(function (item, index, inputArray) {
                            return inputArray.indexOf(item) == index;
                        });
                        //Added by Bhawesh  16-02-2022 for BugNo. DPS-46 start
                        let uniqueOpCodeList = opCodeList.filter(function (item, index, inputArray) {
                            return inputArray.indexOf(item) == index;
                        });
                        //End
                        if (uniquePartNumberList.length > 0 || uniqueOpCodeList.length > 0) {
                            GetDealerPrice({
                                dealerNo: dealerNo,
                                divisionId: brandDivision,  // vehicle.iNDivisionID__c, //Added by shalini for HDMP-8290 17-03-2022
                                partNumbers: JSON.stringify(uniquePartNumberList),
                                accessories: JSON.stringify(uniqueOpCodeList)// Updated By Bhawesh 16-02-2022 for BugNo. DPS-46  
                            }).then(result => {
                                if (result) {
                                    let dealerPriceResult = JSON.parse(result);
                                    console.log('dealerPriceResult after Api', dealerPriceResult);
                                    checkDealerPriceUpdated = false;
                                    // this.isLoading = false;
                                    console.log('dealerPriceResult : ', JSON.parse(JSON.stringify(dealerPriceResult)));
                                    // if (vehicle.productType == 'Parts') {
                                    if (dealerPriceResult.Parts && products && products.Parts) {
                                        console.log('In If condition dealerPriceResult.Parts');
                                        dealerPriceResult.Parts.forEach(pdp => {
                                            products.Parts.forEach(product => {
                                                // console.log('OUTPUT : ',pdp.PartNumber === product.PartNumber);
                                                if (pdp.PartNumber === product.PartNumber) {
                                                    product.SuggestedRetailPriceAmount = pdp.DIYPrice;
                                                    console.log('product.SuggestedRetailPriceAmount : ', product.SuggestedRetailPriceAmount);
                                                }
                                            });
                                        });
                                    }
                                    //Added by Bhawesh  16-02-2022 for BugNo. DPS-46 start
                                    let beforeAccessoryRespose = accessories;
                                    if (dealerPriceResult.Accessories && beforeAccessoryRespose && beforeAccessoryRespose.Accessory) {
                                        dealerPriceResult.Accessories.forEach(delaerPriceResponse => {
                                            beforeAccessoryRespose.Accessory.forEach(accessory => {
                                                if (accessory.op_cd == delaerPriceResponse.OpCode) {
                                                    accessory.msrp = delaerPriceResponse.DIYPrice;
                                                }
                                            });
                                        });
                                        accessories = beforeAccessoryRespose;
                                    }
                                    //End
                                    if (localStorage.getItem('cartBrand') === sessionStorage.getItem('brand')) {
                                        //console.log('if condtion 730');
                                        checkDealerPriceUpdated = true; //Added By Bhawesh 18-02-2022 for BugNo. DPS-46                                                             
                                        checkIfUserIsLoggedIn().then(result => {
                                            if (result) {
                                                getActiveCartItems({ communityId: communityId }).then(result => {
                                                    if (result) {
                                                        let productNumbers = [];
                                                        //Added By Bhawesh 21-01-2022 for BugNo. DPS-46 start
                                                        let opcodeListNumbers = []
                                                        const opcodeMap = new Map();
                                                        result.forEach(element => {
                                                            productNumbers.push(element.Product2.StockKeepingUnit);
                                                        });

                                                        if (beforeAccessoryRespose && beforeAccessoryRespose.Accessory) {
                                                            result.forEach(response => {
                                                                beforeAccessoryRespose.Accessory.forEach(beforeAccessory => {
                                                                    beforeAccessory.Colors.forEach(color => {
                                                                        if (color.part_number == response.Product2.StockKeepingUnit) {
                                                                            opcodeListNumbers.push(beforeAccessory.op_cd);
                                                                            opcodeMap.set(beforeAccessory.op_cd, color.part_number);
                                                                        }
                                                                    });
                                                                });
                                                            });
                                                        }
                                                        //End
                                                        let uniquePartNumberList = productNumbers.filter(function (item, index, inputArray) {
                                                            return inputArray.indexOf(item) == index;
                                                        });
                                                        //Added By Bhawesh 21-01-2022 for BugNo. DPS-46 start
                                                        let uniqueOpCodeList = opcodeListNumbers.filter(function (item, index, inputArray) {
                                                            return inputArray.indexOf(item) == index;
                                                        });
                                                        //End
                                                        if (uniquePartNumberList.length > 0 || uniqueOpCodeList.length > 0) {
                                                            GetDealerPrice({
                                                                dealerNo: dealerNo,
                                                                divisionId: brandDivision,  // vehicle.iNDivisionID__c, //Added by shalini for HDMP-8290 17-03-2022
                                                                partNumbers: JSON.stringify(uniquePartNumberList),
                                                                accessories: JSON.stringify(uniqueOpCodeList)// Updated By Bhawesh 21-02-2022 for BugNo. DPS-46
                                                            }).then(result => {
                                                                let res = JSON.parse(result);
                                                                if (!result.isError) {
                                                                    console.log('dealerPriceResult : ', JSON.parse(JSON.stringify(dealerPriceResult)));

                                                                    if (dealerPriceResult.Parts) {
                                                                        let parts_Copt = [];
                                                                        [...dealerPriceResult.Parts].forEach(everyPart => {
                                                                            let obj = JSON.parse(JSON.stringify(everyPart));
                                                                            obj.DealerPrice = obj.DIYPrice;
                                                                            parts_Copt.push(obj);
                                                                        });

                                                                        // LTIM Added below loop for Reman parts scenario by LTIM 7815 , 16537
                                                                        res.Parts.forEach(obj => {

                                                                            obj = JSON.parse(JSON.stringify(obj));
                                                                            let containsPart = parts_Copt.find(item => item.PartNumber === obj.PartNumber);

                                                                            if (containsPart === undefined) {
                                                                                obj.DealerPrice = obj.DIYPrice;
                                                                                parts_Copt.push(obj)
                                                                            }




                                                                        })

                                                                        console.log('parts_Copt', parts_Copt)
                                                                        
                                                                        // //Added By Bhawesh 21-01-2022 for BugNo. DPS-46 start

                                                                        if (dealerPriceResult.Accessories && beforeAccessoryRespose && beforeAccessoryRespose.Accessory) {
                                                                            beforeAccessoryRespose.Accessory.forEach(beforeAccessory => {
                                                                                dealerPriceResult.Accessories.forEach(Accessories => {
                                                                                    let obj = JSON.parse(JSON.stringify(Accessories));
                                                                                    if (beforeAccessory.op_cd == obj.OpCode) {
                                                                                        if (opcodeMap.has(obj.OpCode)) {
                                                                                            obj.DealerPrice = obj.DIYPrice;
                                                                                            obj.PartNumber = opcodeMap.get(beforeAccessory.op_cd);
                                                                                            parts_Copt.push(obj);
                                                                                        }
                                                                                    }
                                                                                });
                                                                            });
                                                                        }
                                                                        //End
                                                                        //Added By Bhawesh 21-01-2022 for BugNo. DPS-46 start
                                                                        let selectedartNumbers = [...new Map(parts_Copt.map(item => [item['PartNumber'], item])).values()];
                                                                        //End
                                                                        let adToCart = {
                                                                            accountId: this.effectiveAccountId,
                                                                            communityId: communityId,
                                                                            products: selectedartNumbers //Added By Bhawesh 21-01-2022 for BugNo. DPS-46
                                                                        };
                                                                        updateCartItems({
                                                                            adToCart: adToCart
                                                                        }).then(result => {
                                                                            console.log('updatecart with dealer price', result);
                                                                            this.isLoading = false;
                                                                            console.log('OUTPUT : ', products);
                                                                            if (products == null || products == 'null') {
                                                                                products = accessories;
                                                                            }
                                                                            else if (products && accessories) {
                                                                                products.myAccessories = accessories;
                                                                            }
                                                                            console.log('OUTPUT : ', this.messageContext);
                                                                            const message = { message: { 'dealerLabel': dealerLabel, 'products': products } };
                                                                            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                                                                            setTimeout(() => {
                                                                                this.handleSelectDealer(dealerLabel);
                                                                            }, 100)
                                                                            //alert('Wait .');
                                                                            // window.location.replace(result);
                                                                        }).catch(error => {
                                                                            console.log('error from select ', JSON.stringify(error));
                                                                        });
                                                                    }
                                                                }
                                                            }).catch(error => {
                                                                console.log(error);
                                                                this.isLoading = false;
                                                            });
                                                        } else {
                                                            const message = { message: { 'dealerLabel': dealerLabel, 'products': products } };
                                                            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                                                            setTimeout(() => {
                                                                this.handleSelectDealer(dealerLabel);
                                                            }, 300);
                                                        }
                                                    }
                                                }).catch(error => {
                                                    console.log(error);
                                                    this.isLoading = false;
                                                });
                                            }
                                            else {
                                                this.isLoading = false;
                                                if (products == null || products == 'null') {
                                                    products = accessories;
                                                }
                                                else if (products && accessories) {
                                                    products.myAccessories = accessories;
                                                }
                                                const message = { message: { 'dealerLabel': dealerLabel, 'products': products } };
                                                publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                                                setTimeout(() => {
                                                    this.handleSelectDealer(dealerLabel);
                                                }, 300);
                                            }
                                        }).catch(error => {
                                            console.log(error);
                                        });
                                    }
                                    if (!checkDealerPriceUpdated) {
                                        console.log('checkDealerPriceUpdated false : ');
                                        this.isLoading = false;
                                        if (products == null || products == 'null') {
                                            products = accessories;
                                        }
                                        else if (products && accessories) {
                                            products.myAccessories = accessories;
                                        }
                                        const message = { message: { 'dealerLabel': dealerLabel, 'products': products } };
                                        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                                        setTimeout(() => {
                                            this.handleSelectDealer(dealerLabel);
                                        }, 300)
                                    }

                                }
                            }).catch(error => {
                                console.log(error);
                            });
                        } else {
                            const message = { message: { 'dealerLabel': dealerLabel, 'products': products } };
                            publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                            setTimeout(() => {
                                this.handleSelectDealer(dealerLabel);
                            }, 300);
                        }
                    } else {
                        this.isLoading = false;
                        if (products == null || products == 'null') {
                            products = accessories;
                        }
                        else if (products && accessories) {
                            products.myAccessories = accessories;
                        }
                        const message = { message: { 'dealerLabel': dealerLabel, 'products': products } };
                        publish(this.messageContext, HDMP_MESSAGE_CHANNEL, message);
                        setTimeout(() => {
                            this.handleSelectDealer(dealerLabel);
                        }, 100)
                    }
                    //var finalurl = url.substring(0, url.indexOf("/s")) + '/servlet/network/accounts/switch?effectiveAccountId=' + selectedRecordId;


                    //window.location = finalurl;
                })
                .catch((e) => {
                    // Handle cart summary error properly
                    // For this sample, we can just log the error
                    console.log(e);
                });
        }

        //Added by Shalini Soni
        try {
            let emailAddress = '';
            let POIName = '';
            let operationHour = '';
            let operationHours = '';
            let firstName = '';
            let lastName = '';
            let phone = '';
            let zipCode = '';
            let Latitude = '';
            let Longitude = '';
            let friendlyName = '';

            console.log('##data', JSON.parse(JSON.stringify(this.mapListofAllPois)));
            this.mapListofAllPois.forEach(element => {
                if (dealerName == element.POIName) {
                    emailAddress = element.dealerEmail;
                    firstName = element.firstName;
                    lastName = element.lastName;
                    POIName = element.POIName;
                    phone = element.Phone;
                    zipCode = element.MailingZip;
                    Latitude = element.Latitude;
                    Longitude = element.Longitude;
                    if ((element.Attributes.Attribute[0].Code == ' GP' || element.Attributes.Attribute[0].Code == 'GS' || element.Attributes.Attribute[0].Code == 'GG') && element.Attributes.Attribute[0].FriendlyName) {
                        friendlyName = element.Attributes.Attribute[0].FriendlyName;
                    }
                    console.log(JSON.parse(element.partOperationHour)[0].text);
                    console.log('##Hour2', JSON.parse(element.partOperationHour)[0].text.replace(/\s+/g, ' '));
                    operationHour = element.partOperationHour ? JSON.parse(element.partOperationHour)[0].text.replace(/\s+/g, ' ') : '';
                    operationHours = operationHour.replaceAll(';', ';  ');
                    emailAddress = element.dealerEmail ? element.dealerEmail.replaceAll(';', ',  ') : '';
                }
            });
            console.log('##operationHour', operationHours);
            console.log('##Phone', phone);
            console.log('##zipCode', zipCode);
            console.log('### emailAddress ', emailAddress);
            console.log('### POIName ', POIName);
            console.log('### firstName ', firstName);
            console.log('### lastName ', lastName);


            // modified by shalini soni for Latitude and Longitude
            searchedDealerResponseStored({ email: emailAddress, name: POIName, operationHour: operationHours, firstName: firstName, lastName: lastName, Latitude: Latitude, Longitude: Longitude, award: friendlyName })
                .then(result => {
                    console.log('result ===> ' + result)
                })
                .catch(error => {
                    console.error(error);
                });

            // Added by Deepak Mali for HDMP-4946 to change the dealer Phone info 
            let selectedDealerContact = phone //JSON.parse(JSON.stringify(event.target.getAttribute('data-contact')));
            let selectedDealerStreet = JSON.parse(JSON.stringify(event.target.getAttribute('data-street')));
            let selectedDealerCity = JSON.parse(JSON.stringify(event.target.getAttribute('data-city')));
            let selectedDealerState = JSON.parse(JSON.stringify(event.target.getAttribute('data-state')));
            let dealerWebsite = JSON.parse(JSON.stringify(event.target.getAttribute('data-dealerurl')));
            let poiId = JSON.parse(JSON.stringify(event.target.getAttribute('data-dealerno')));
            let dealerId = JSON.parse(JSON.stringify(event.target.getAttribute('data-Id')));
            let shippingtaxstate = JSON.parse(JSON.stringify(event.target.getAttribute('data-shippingtaxstate')));
            
            
            console.log('##@@1', selectedDealerContact); console.log('##@@2', selectedDealerCity);
            console.log('##@@3', selectedDealerState); console.log('##@@4', selectedDealerStreet);
            console.log('##@@5', dealerName); console.log('##@@6', operationHours); console.log('##@@7 ', emailAddress);
            console.log('##@@8 ', firstName); console.log('##@@9 ', lastName);
            console.log('tax state@@ ', shippingtaxstate); 

            this.allDealerValues.Name = dealerName;
            this.allDealerValues.Street = selectedDealerStreet;
            this.allDealerValues.City = selectedDealerCity;
            this.allDealerValues.State = selectedDealerState;
            this.allDealerValues.Phone = selectedDealerContact;
            this.allDealerValues.Email = emailAddress;
            this.allDealerValues.operationHours = operationHours;
            this.allDealerValues.firstName = firstName;
            this.allDealerValues.lastName = lastName;
            this.allDealerValues.brandName = this.brand;
            this.allDealerValues.zipCode = zipCode;
            this.allDealerValues.Longitude = Longitude;
            this.allDealerValues.Latitude = Latitude;
            this.allDealerValues.POIName = POIName;
            this.allDealerValues.dealerUrl = dealerWebsite;
            this.allDealerValues.POIId = poiId;
            this.allDealerValues.Id = dealerId;
            this.allDealerValues.isSavedDealer = false;
            //Lakshmi HDMP-19445
            this.allDealerValues.shippingtaxstate=shippingtaxstate.replaceAll(';',',');

            
            //7615
            let allDealerList = [];
            allDealerList = JSON.parse(sessionStorage.getItem('selectedDealer')) || [];
            let foundIndex = allDealerList.findIndex(element => element.brandName == this.brand);

            console.log('# before allDealerList  ', JSON.parse(JSON.stringify(allDealerList)));
            console.log('# foundIndex', foundIndex);

            if (foundIndex > -1) {
                allDealerList[foundIndex] = this.allDealerValues
                console.log('# found at allDealerList', JSON.parse(JSON.stringify(allDealerList)));
                console.log('# after allDealerList  ', JSON.parse(JSON.stringify(allDealerList)));

            } else {
                allDealerList.push(this.allDealerValues);
            }

            console.log('##@@get1', allDealerList);


            sessionStorage.setItem('selectedDealer', JSON.stringify(allDealerList));
            console.log('##@@get2', JSON.parse(sessionStorage.getItem('selectedDealer')));

        }
        catch (error) {
            console.error(error.message);
        }

        //End By Shalini Soi
    }

    buildEffectiveDealer(brand, dealerId, dealerLabel, dealerNo) {
        let brands = [];
        if (localStorage.getItem('effectiveDealer')) {
            brands = JSON.parse(localStorage.getItem('effectiveDealer'))['brands'];
            let hasExist = false;
            if (brands) {
                brands.forEach(element => {
                    if (brand === element.brand) {
                        element.id = dealerId;
                        element.label = dealerLabel;
                        element.dealerNo = dealerNo;
                        hasExist = true;
                    }
                });
            }
            if (!hasExist) {
                brands.push({ 'brand': brand, 'id': dealerId, 'label': dealerLabel, 'dealerNo': dealerNo });
            }
        } else {
            brands.push({ 'brand': brand, 'id': dealerId, 'label': dealerLabel, 'dealerNo': dealerNo });
        }
        localStorage.setItem('effectiveDealer', JSON.stringify({ 'brands': brands }));
    }

    handleSelectDealer(buttonLabel) {
        console.log('$SL: handleSelectDealer: ', buttonLabel);
        console.log('$SL: dealerNumber: ', this.dealerNumber);
        console.log('$SL: isguest: ', isguest);
        console.log('$SL: brandName: ', this.brandName);
        sessionStorage.setItem('guestHasDealer', 'true');
        if (!isguest) {
            getDealerByPOIID({ poiId: this.dealerNumber }).then((result) => {
                if (result) {
                    console.log('$SL: getDealerByPOIID result', result);
                    console.log('$SL: getDealerByPOIID result', result.Id);
                    saveLastDealer({ shoppingSelection: { Product_Subdivision__c: this.brandName, Last_Dealer__c: result.Id } }).then((result) => {
                        console.log('$SL: saveLastDealer result', result);
                    }).catch((error) => {
                        console.error('$SL: saveLastDealer error', error);
                    });
                }
            }).catch((error) => {
                console.error('$SL: getDealerByPOIID error', error);
            });
        }

        const selectDealerEvent = new CustomEvent('selectdealer', {
            detail: {
                buttonLabel: buttonLabel
            }
        });
        this.dispatchEvent(selectDealerEvent);

    }



    createCookie(name, value, days) {
        console.log('calling creating cookie');
        var expires;
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 100));
            expires = ";expires=" + date.toGMTString();
        } else {
            expires = "";
        }
        console.log('setting cookie');
        //updated by Pradeep Singh for Optiv Issue
        document.cookie = name + "=" + encodeURIComponent(value) + expires + ";path=/; SameSite=Lax; Secure";
        // ends here
    }


    getCookie(name) {
        return (name = new RegExp('(?:^|;\\s*)' + ('' + name).replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&') + '=([^;]*)').exec(document.cookie)) && decodeURIComponent(name[1]);

    }

    goToMap(event) {
        let isselecteddealer = event.currentTarget.dataset.isselecteddealer;

        if (isselecteddealer == 'true') {

            let allDealerList = [];
            let selectedDealerRecord = []
            if (sessionStorage.getItem('selectedDealer')) {
                allDealerList = JSON.parse(sessionStorage.getItem('selectedDealer'));
                if (allDealerList && allDealerList.length > 0 && allDealerList != 'undefined') {

                    allDealerList.forEach(element => {
                        if (element.brandName == this.brand) {
                            element.FullAddress = element.BillingStreet + ' ' + element.BillingCity + ' ' + element.BillingState + ' ' + element.BillingPostalCode;
                            selectedDealerRecord.push(element);
                        }
                    });
                }
            }
            this.sendMessgaeToVisualForce(selectedDealerRecord, true);


        } else {
            var dealerNo = event.currentTarget.dataset.dealerno;
            let title = event.currentTarget.dataset.title;


            let lat, lon, POIName, Phone, FullAddress;
            if (this.mapListofAllPois && this.mapListofAllPois != undefined) {
                this.mapListofAllPois.forEach(element => {
                    if (dealerNo === element.POIId) {
                        lat = element.Latitude;
                        lon = element.Longitude;
                        POIName = element.POIName;
                        FullAddress = element.FullAddress;
                        Phone = element.Phone;

                    }
                });
            }

            //Added by deepak mali for : 6383 dealer map displaying 
            if (lat !== null && lon !== null) {
                console.log("https://bing.com/maps/default.aspx?cp=" + lat + "~" + lon + "&where1=" + title);
                // Added by deepak mali
                let locationList = [];
                this.mapListofAllPois.forEach(dlr => {
                    locationList.push({
                        POIName: dlr.POIName,
                        Longitude: dlr.Longitude,
                        Latitude: dlr.Latitude,
                        FullAddress: dlr.FullAddress ?? '',
                        Phone: dlr.Phone
                    });
                });
                // locationList.push({ 'POIName': POIName, 'Longitude': lon, 'Latitude': lat, 'FullAddress': FullAddress, 'Phone': Phone });
                // End
                console.log('$SL-M: locationList-SEND: ', locationList);
                this.sendMessgaeToVisualForce(locationList, true, { "latitude": lat, "longitude": lon, "altitude": 0, "altitudeReference": -1 }, 15);
                //window.open("https://bing.com/maps/default.aspx?cp="+lat+"~"+lon+"&where1="+title);
                //End

            }
        }
    }
    @wire(getStateCodes, {
    })

    getStateCodesData(result) {
        console.log('@##result', result);
        if (result.data) {
            console.log('@##parseData1');
            let parseData = result.data;
            let stateOptions = JSON.parse(JSON.stringify(parseData));
            this.stateOptionList = stateOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
            console.log('@### stateOptionList ', this.stateOptionList);

        } else if (result.error) {
            console.error('ERROR::', JSON.stringify(result.error));
            this.stateOptionList = [];
        }
    }
    handleSelectOnZipAndState(event) {
        let searchType = event.target.value;
        this.state = ''
        this.city = '';

        if (searchType == 'ZipCode') {
            if (this.makeDisabled && this.makeDisabled == true) {
                this.template.querySelector('.searchBtn').disabled = true;
            }
            this.zipCodeBox = true;

        } else if (searchType == 'CityState') {
            if (this.makeDisabled && this.makeDisabled == true) {
                this.template.querySelector('.searchBtn').disabled = false;
            }
            this.citystatebox = true;// added by Yashika for 6836
            this.zipCodeBox = false;
            this.zipCode = '';

        }
    }
    handleStateChange(event) {

        this.state = event.target.value;
        console.log('$SL: state: ', this.state);
        this.DealerList = [];
        this.errorenable = false;
        this.searchLocationErrors = '';
        this.template.querySelector('.city-name').focus();
        // event.target.value = '';
    }
    handleCityChange(event) {

        let charCode = (event.which) ? event.which : event.keyCode;
        if (charCode == 13) {
            this.fireevent = true;
            this.selectLocation();
        } else if (charCode != 8 && charCode != 32 && !((charCode >= 97 && charCode <= 122) || (charCode >= 65 && charCode <= 90))) {
            event.preventDefault();
            return true;
        }

        this.city = event.target.value;
        this.DealerList = [];
        this.errorenable = false;
        this.searchLocationErrors = '';
    }

    handleActive(event) {
        console.log('Click on TAB', event.target.value);
        this.currentTabName = event.target.label;
        console.log('$SL: currentTabName: ', this.currentTabName);
        this.showDistance = this.coordinates && this.currentTabName == 'Search By Dealer Name' ? true : false;
        console.log('$SL: showDistance: ', this.showDistance);
        this.DealerList = false;
        this.errorenable = false;
        this.searchLocationErrors = ' ';
        let activeTab = event.target.value;
        this.hideBingMap = activeTab == 'MyDealers' ? true : false;

        if (activeTab != 'MyDealers') {
            let selectedDealerRecord = [];
            this.brand = sessionStorage.getItem('brand');

            if (sessionStorage.getItem('selectedDealer')) {
                let allDealerList = JSON.parse(sessionStorage.getItem('selectedDealer'));
                if (allDealerList && allDealerList.length > 0 && allDealerList != 'undefined') {
                    console.log('all dealer list', allDealerList);
                    allDealerList.forEach(element => {
                        if (element.brandName == this.brand) {
                            element.FullAddress = element.Street + ' ' + element.City + ' ' + element.State + ' ' + element.zipCode;
                            selectedDealerRecord.push(element);
                        }
                    });
                }
                setTimeout(() => {
                    this.sendMessgaeToVisualForce(selectedDealerRecord, false);
                }, 2000)
            } else {
                let selectedDealerRecord = [];
                setTimeout(() => {
                    this.sendMessgaeToVisualForce(selectedDealerRecord, false);
                }, 50)
            }
        }
    }

    //Added by deepak mali for : 6383 dealer map displaying 
    sendMessgaeToVisualForce(mapListofAllDealer, scollToMap, currentRecord, zoomSize) {
        console.log('$SL-: mapListofAllDealer: ', JSON.parse(JSON.stringify(mapListofAllDealer)));
        console.log('$SL-: scollToMap: ', scollToMap);
        console.log('$SL-: currentRecord: ', currentRecord);
        console.log('$SL-: zoomSize: ', zoomSize);
        let locationList = [];
        console.log('mapListofAllDealer ', JSON.parse(JSON.stringify(mapListofAllDealer)));
        if (mapListofAllDealer && mapListofAllDealer != undefined) {
            mapListofAllDealer.forEach(element => {
                if (element.Latitude && element.Longitude) {
                    let pushRec = { 'POIName': element.POIName, 'Longitude': element.Longitude, 'Latitude': element.Latitude, 'FullAddress': element.FullAddress, 'Phone': element.Phone };
                    if (currentRecord && zoomSize) {
                        pushRec.extraInfo = true;
                    }
                    locationList.push(pushRec);
                }
            });
        }
        console.log('$SL-: locationList: ', locationList);


        this.isLoading = true;
        let message = {
            message: JSON.stringify(locationList),
            source: 'LWC'
        };
        if (currentRecord && zoomSize) {
            message.currentRecord = currentRecord;
            message.zoomSize = zoomSize;
        }

        let visualForce = this.template.querySelector(".VFIframe");
        console.log('visualForce', visualForce)
        try {
            if (visualForce) {
                visualForce.contentWindow.postMessage(message, '*');
                if (scollToMap == true) {
                    visualForce.scrollIntoView({ behaviour: "smooth" });
                }
                this.isLoading = false;
            } else {
                this.isLoading = false; //Added this condition by Shalni for HDMP-7693
            }
        } catch (error) {
            console.error(error.message);
            this.isLoading = false;
        }
    }
    handleResponse(message) {
        console.log('called handleResponse in searchLocation');
        console.log('message ', JSON.stringify(message.data));
        // check the origin match for both source and target
        if (message.origin === this.visualForceOrigin.data) {
            this.receivedMessage = JSON.stringify(message.data);
        }
    }

    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    getDistanceFromLatLonInKm(lat1, lon1, lat2, lon2, returnValue) {
        var R = 6371; // Radius of the earth in km
        var dLat = this.deg2rad(lat2 - lat1);  // deg2rad below
        var dLon = this.deg2rad(lon2 - lon1);
        var a =
            Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
            Math.sin(dLon / 2) * Math.sin(dLon / 2)
            ;
        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        var d = R * c; // Distance in km
        if (returnValue != 'MILES') {
            return d;
        }
        // Distance in miles
        const factor = 0.621371
        d = d * factor;
        return d;
    }

    deg2rad(deg) {
        return deg * (Math.PI / 180)
    }
    numberWithCommas(x) {
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
}
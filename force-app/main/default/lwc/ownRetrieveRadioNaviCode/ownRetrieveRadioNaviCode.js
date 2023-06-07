import { LightningElement, api, wire, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { OwnBaseElement } from 'c/ownBaseElement';
import createradioNaviRequest from '@salesforce/apex/ownRadioNaviCodeController.createradioNaviRequest';
import createradioNaviRequestFailure from '@salesforce/apex/ownRadioNaviCodeController.createradioNaviRequestFailure';
import vinMasterSearchResponse from '@salesforce/apex/OwnAPIController.vinMasterSearchResponse';
import getNavigationCode from '@salesforce/apex/OwnAPIController.getNavigationCode';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import PHONE_FIELD from '@salesforce/schema/User.Phone';
import ACCOUNT_ID from '@salesforce/schema/User.Contact.AccountId';
import ZIP_CODE_FIELD from '@salesforce/schema/Account.PersonMailingPostalCode';
import APHONE_FIELD from '@salesforce/schema/Account.Phone';
import getRadioCode from '@salesforce/apex/OwnAPIController.getRadioCode';
import storeRadioOrNaviCode from '@salesforce/apex/ownRadioNaviCodeController.storeRadioOrNaviCode';
import { getOrigin, getContext, getProductContext, ISGUEST } from 'c/ownDataUtils';
import { CurrentPageReference } from 'lightning/navigation';
import getExternalIp from '@salesforce/apex/ownRadioNaviCodeController.getExternalIp';
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';


export default class OwnRetrieveRadioNaviCode extends OwnBaseElement {
    @track context;
    isguest = ISGUEST;
    ownershipid;
    searchType;
    divisionName;
    divisionId;
    division;
    image;
    Vin = '';
    ZipCode = '';
    isNavigation = false;
    isRadio = false;
    both;
    radiocode = '';
    isBoth = false;
    radioSerialNumber = '';
    navigationSerialNumber = '';
    navigationCode = '';
    value = '';
    fromProductChooser = false;
    isresult = true;
    responsenavigationCode;
    responseradiocode;
    isSuccess;
    radioNavRequest;
    udateVin = false;
    userId = Id;
    name;
    email = '';
    phone = '';
    error;
    isEmailEditable;
    isZipCodeEditable;
    isPhoneEditable=true;
    isVinEditable;
    responseNavigationCode;
    pageUrl;
    color;

    trim;
    year;
    model;
    returncode;
    returnmessage;
    sourceIp;
    @track fb;
    @track brand;
    @track errorMessage;
    @track showerror = false;
    @track isRecurringerror;
    @track isBothRadio = false;
    @track isNavigationRadio = false;
    @track isRadioRadio = false;
    @track AccountId;
    currentPageReference = null;
    urlStateParameters = null;
    vinResponse;
    incorrectVinLength;
    vinerror;
    errorType;


    get options() {
        return [
            { label: 'Navigation Code', value: 'option1' }, { label: 'Radio Code', value: 'option2' },
            { label: 'Both', value: 'option3' }
        ];
    }
    @track responseRadioCode;
    @track breadcrumb = { label: '', url: '' };

    @wire(CurrentPageReference) pageref;

    @wire(getRecord, { recordId: Id, fields: [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD,ACCOUNT_ID] })
    userDetails({ error, data }) {
        if (data) {
            //console.log('data==>>' + JSON.stringify(data));
            this.name = data.fields.Name.value;
            this.email = data.fields.Email.value;
            this.phone = data.fields.Phone.value ?data.fields.Phone.value:'';
           // this.ZipCode= data.fields.Postalcode.value ? data.fields.Postalcode.value:'';
            this.AccountId = data.fields.Contact.value.fields.AccountId.value;
        } else if (error) {
            //console.log('error=>>' + JSON.stringify(error));
            this.error = error;
        }
    }

    @wire(getRecord, { recordId: '$AccountId', fields: [ZIP_CODE_FIELD, APHONE_FIELD] })
    userAccountDetails({
        error,
        data
    }) {
        if (data) {
            this.ZipCode = data.fields.PersonMailingPostalCode.value ? data.fields.PersonMailingPostalCode.value.slice(0,10) : this.ZipCode;
            this.phone = data.fields.Phone.value ? data.fields.Phone.value : this.phone;
        } else if (error) {
            this.error = error;
        }
    }

    
    get isDesktop() {
        return FORM_FACTOR === 'Large';
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        //console.log('currentPageReference', currentPageReference);
        if (currentPageReference) {
            this.urlStateParameters = currentPageReference.state;
            //console.log('this.urlStateParameters', this.urlStateParameters);
            this.setParametersBasedOnUrl();
        }
    }

    setParametersBasedOnUrl() {
        this.fb = this.urlStateParameters.fb || null;
        //console.log('@@TestBrand', this.fb);
        this.brand = this.urlStateParameters.brand || null;
        //console.log('@@TestBrand', this.brand);
    }

    connectedCallback() {
        //console.log('@@connected callback');
        this.isRecurringerror = false;
        this.initialize();
        if (!this.isguest) {
            this.getSourceIp();
        }
    }

    getSourceIp() {
        getExternalIp()
            .then(result => {
                //console.log('sourceip==>>', result);
                this.sourceIp = result;
            })
            .catch(error => {
                //console.log('sourceIp error==>>', JSON.stringify(error));
            })
    }

    initialize = async () => {
        this.recurringerror = false;
        this.fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        //console.log('fromProductChooser==>>', this.fromProductChooser);
        let garageProducts = JSON.parse(localStorage.getItem('garage'));
        //console.log('garageProducts==>>', garageProducts);
        if (this.fromProductChooser || ISGUEST) {
            this.context = await getProductContext('', true);
            //console.log('context==>>', JSON.stringify(this.context));
        } else {
            this.context = await getContext('');
            //console.log('context=else=>>', JSON.stringify(this.context));
        }
        if (this.context.product) {
            this.trim = this.context.product.trim;
            this.model = this.context.product.model;
            this.year = this.context.product.year;
            this.ownershipid = this.context.product.ownershipId;
            this.division = this.context.product.division;
            this.divisionId = this.context.product.divisionId;
            this.color= this.context.product.exteriorColor ? '/ '+this.context.product.exteriorColor : '';
            //console.log('ownershipid==>>' + this.ownershipid);
            if (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-')) {
                if (this.fb == 'true') {
                    this.Vin = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
                }
            }
            this.divisionName = this.fromProductChooser ? garageProducts.products[0].division : this.context.product.division;
        }
        this.isNavigation = true;
        this.isNavigationRadio = true;
        this.searchType = 'Navigationcode';
        this.isRadio = false;
        this.isBoth = false;

        this.isVinEditable = (this.Vin == '' || this.Vin == undefined || this.Vin == null) ? true : false;
        this.isEmailEditable = (this.email == '' || this.email == undefined || this.email == null) ? true : false;
        this.isZipCodeEditable = (this.ZipCode == '' || this.ZipCode == undefined || this.ZipCode == null) ? true : false;
       // this.isPhoneEditable = (this.phone == '' || this.phone == undefined || this.phone == null) ? true : false;

        if (sessionStorage.getItem('isFromFooter') && this.isguest) {
            this.isVinEditable = true;
            this.isEmailEditable = true;
            this.isZipCodeEditable = true;
            this.isPhoneEditable = true;
        }
        //console.log('isPhoneEditable==>>' + this.isEmailEditable, this.isZipCodeEditable, this.isPhoneEditable);
    }
    addBreadcrumb = async () => {
        let context;
        if (getOrigin() == 'ProductChooser') {
            context = await getProductContext('', true);
        } else {
            context = await getProductContext('', false);
        }
        //console.log('ownProductCrousel: Context', JSON.parse(JSON.stringify(context)));
        if (context && context.product) {
            if (context.product.division === 'Honda') {
                this.breadcrumb.label = 'Honda Autos: Get Started';
                this.breadcrumb.url = '/find-honda';
            } else if (context.product.division === 'Acura') {
                this.breadcrumb.label = 'Acura Autos: Get Started';
                this.breadcrumb.url = '/find-acura';
            } else if (context.product.division === 'Motorcycle/Powersports' || context.product.division === 'Powersports') {
                this.breadcrumb.label = 'Powersports: Get Started';
                this.breadcrumb.url = '/find-powersports';
            } else if (context.product.division === 'Powerequipment') {
                this.breadcrumb.label = 'Powerequipment: Get Started';
                this.breadcrumb.url = '/find-powerequipment';
            } else if (context.product.division === 'Marine') {
                this.breadcrumb.label = 'Honda Marine: Get Started';
                this.breadcrumb.url = '/find-marine';
            } else if (context.product.division === 'radio nav code') {
                this.breadcrumb.label = 'Retrieve Radio / Navigation Codes';
                this.breadcrumb.url = '/radio-nav-code';
            }
        }
    }
    handleBreadcrumb() {
        this.navigate(this.breadcrumb.url, {});
    }

    @api
    get displayBreadcrumb() {
        return ((this.fromProductChooser || this.isguest) && this.isDesktop);
    }
    handleVINChange(event) {
        this.Vin = event.target.value;
    }

    handleZipCodeChange(event) {
        this.ZipCode = event.target.value;
    }

    handlePhoneNumberChange(event) {
        this.phone = event.target.value;
    }

    handleEmailChange(event) {
        this.email = event.target.value;
    }
    handleNavigationSerialChange(event) {
        this.navigationSerialNumber = event.target.value;
    }
    handleRadioSerialChange(event) {
        this.radioSerialNumber = event.target.value;
    }
    handleNavigationCode() {
        this.isNavigationRadio = true;
        this.isNavigation = true;
        this.isRadio = false;
        this.searchType = 'Navigationcode';
        this.isBothRadio = false;
        this.isNavigationRadio = true;
        this.isRadioRadio = false;
    }

    handleRadioCode() {
        this.isRadioRadio = true;
        this.isNavigation = false;
        this.isRadio = true;
        this.searchType = 'RadioCode';
        this.isBothRadio = false;
        this.isNavigationRadio = false;
        this.isRadioRadio = true;
    }

    handleBoth() {
        this.isBoth = true;
        this.isNavigation = true;
        this.isRadio = true;
        this.searchType = 'Both';
        this.isBothRadio = true;
        this.isNavigationRadio = false;
        this.isRadioRadio = false;
    }
    handleCancel() {
        history.back();
    }
    handleVINHelp() {

        //console.log(this.divisionName);
        if (this.brand != null) {
            if (this.brand.includes('Acura')) {
                this.navigate('/vin-help/?division=Acura&fp=rn', {});
            } else {
                this.navigate('/vin-help/?division=Honda&fp=rn', {});
            }
            localStorage.setItem('VINHelpBreadcrumb', 'FindProduct' + this.brand);
        } else {
            localStorage.setItem('VINHelpBreadcrumb', 'FindProduct' + this.divisionName);
            if (this.divisionName == 'Honda' || this.divisionName == 'Acura' || this.divisionName == 'Powersports' || this.divisionName == 'Motorcycle/Powersports') {
                this.navigate('/vin-help/?division=' + this.divisionName+'&fp=rn', {});
            }
            else if (this.divisionName == 'Power Equipment') {
                sessionStorage.setItem('vinHelpBreadcrumb', 'findProduct');
                this.navigate('/sample-emission-label-powerequipment', {});
            }
            else if (this.divisionName == 'Marine') {
                sessionStorage.setItem('vinHelpBreadcrumb', 'findProduct');
                this.navigate('/marine-emissions-location-label', {});
            }
        }
    }
    handleSerialNumberHelp() {
        if (this.brand != null) {
            if (this.brand.includes('Acura')) {
                this.navigate('/serial-number-help?brand=Acura', {});
            } else {
                this.navigate('/serial-number-help?brand=Honda', {});
            }
            localStorage.setItem('VINHelpBreadcrumb', 'FindProduct' + this.brand);
        } else {
            localStorage.setItem('VINHelpBreadcrumb', 'FindProduct' + this.divisionName);
            //console.log(this.divisionName);

            if (this.divisionName == 'Honda' || this.divisionName == 'Acura' || this.divisionName == 'Powersports' || this.divisionName == 'Motorcycle/Powersports') {
                this.navigate('/serial-number-help', {});
            }
            else if (this.divisionName == 'Power Equipment') {
                sessionStorage.setItem('vinHelpBreadcrumb', 'findProduct');
                this.navigate('/sample-emission-label-powerequipment', {});
            }
            else if (this.divisionName == 'Marine') {
                sessionStorage.setItem('vinHelpBreadcrumb', 'findProduct');
                this.navigate('/marine-emissions-location-label', {});
            }
        }
    }
    async validateRequiredField() {
        this.vinResponse = '';
        this.incorrectVinLength = false;
        this.vinerror = false;
        if (this.fb == 'true') {
            this.brand = this.division;
        } else {
            if (this.brand == 'Acura') {
                this.divisionId = 'B';
            } else {
                this.divisionId = 'A';
            }
        }
        let showToastMessage = '\n';
        if (this.isVinEditable) {
            //this.udateVin = true;
            if ((this.Vin == '' || this.Vin == undefined || this.Vin == null)) {
                this.udateVin = this.divisionName == 'Honda' ? true : false;
                showToastMessage += '* VIN is mandatory. \n';
            } else {
                const pattern = /[A-HJ-NPR-Za-hj-npr-z0-9]{17,17}/;
                if (pattern.test(this.Vin) == false) {
                    this.incorrectVinLength = true;
                    this.vinerror =true;
                    showToastMessage += '* Incorrect Vin Format \n';
                    this.vinResponse='* Incorrect Vin Format \n';
                } else {
                    await getProductByVIN({ divisionId: this.divisionId, vin: this.Vin, divisionName: this.brand })
                        .then(result => {
                            //console.log('@@result Vin', JSON.stringify(result));
                            let prod = JSON.parse(result);
                            if (!prod.isError) {
                                this.year = prod.modelDetail.year ? prod.modelDetail.year : '';
                                this.trim = prod.modelDetail.trim ? prod.modelDetail.trim : '';
                                this.color = prod.modelDetail.color.name ? '/ ' + prod.modelDetail.color.name : '-';
                                this.model = prod.modelDetail.modelGroupName ? prod.modelDetail.modelGroupName : (prod.modelDetail.modelName ? prod.modelDetail.modelName : '-');
                                if (prod.modelDetail.assets) {
                                    for (var key in prod.modelDetail.assets) {
                                        if (prod.modelDetail.assets[key].assetType == 'BASECAR') {
                                            this.image = prod.modelDetail.assets[key].imagePath;
                                            sessionStorage.setItem('rnv-image', this.image);
                                        }
                                    }
                                }
                            } else {
                                showToastMessage += '* Incorrect VIN number entered. \n';
                                this.vinerror = true;
                            }
                        })
                        .catch(error => {
                            this.vinerror = true;
                            //console.log('getProductByVIN: error');
                            //console.log('error: ', error);
                        });
                     this.vinResponse = await vinMasterSearchResponse({ vin: this.Vin, divisionId: this.divisionId });
                }

            }
        }
        if (this.email == '' || this.email == undefined || this.email == null) {
            showToastMessage += '* Email is mandatory. \n';

        }
        if (this.phone == '' || this.phone == undefined || this.phone == null) {
            showToastMessage += '* Phone Number is mandatory. \n';
        }
        if (this.ZipCode == '' || this.ZipCode == undefined || this.ZipCode == null) {
            showToastMessage += '* Zip Code is mandatory. \n';
        }


        if (showToastMessage != '\n') {
            // this.showToast_error(showToastMessage);
            this.errorMessage = showToastMessage;
            this.showerror = true;
            this.isresult = true;
            if (this.vinerror) {
                if (this.incorrectVinLength) {
                    this.errorType = "FVIN";
                } else {
                    this.errorType = "FVINS";
                }
                createradioNaviRequest({ clientIpAddress: this.sourceIp, response: this.vinResponse, radioCode: this.radiocode, vin: this.Vin, radioserialNumber: this.radioSerialNumber,navserialNumber: this.navigationSerialNumber, email: this.email, phone: this.phone, zipcode: this.ZipCode, isSuccess: this.errorType, isRecurringerror: this.isRecurringerror, radioNavId: this.radioNavRequest })
                    .then(createradioNaviRequestResult => {
                        //console.log('createradioNaviRequestResult==>>', JSON.stringify(createradioNaviRequestResult));
                        this.radioNavRequest = createradioNaviRequestResult;
                    })
                    .then(storeRadioOrNaviCodeResult => {
                        //console.log('storeRadioOrNaviCode=>>', JSON.stringify(storeRadioOrNaviCodeResult));
                        return createradioNaviRequestFailure({ returncode: '404', response: this.vinResponse, vin: this.Vin, radioserialNumber: this.radioSerialNumber,navserialNumber: this.navigationSerialNumber, email: this.email, radioNavRequest: this.radioNavRequest, isSuccess: this.isSuccess, phone: this.phone, zipcode: this.ZipCode })
                    })
                    .catch(error => {
                        //console.log('getRadioResponse error==>>', JSON.stringify(error));
                        if (error.body.pageErrors) {
                            // this.showToast_error(JSON.stringify(error.body.pageErrors[0].message));
                            this.errorMessage = JSON.stringify(error.body.pageErrors[0].message);
                            this.showerror = true;
                            this.isresult = true;
                        }
                        else {
                            // this.showToast_error(error.body.message);
                            this.errorMessage = error.body.message;
                            this.showerror = true;
                            this.isresult = true;
                        }
                    })
            }
            this.isRecurringerror = true;
            this.isresult = true;
            return false;
        }
        this.showerror = false;
        return true;
    }
    async handleSave() {
        this.isresult = false;
        this.showerror = false;
        this.ownershipid = this.ownershipid == undefined ? null : this.ownershipid;

        if (await this.validateRequiredField()) {
            if (this.searchType == 'Both') {
                //console.log('isboth called');
                let showToastMessage = '\n';
                if (this.radioSerialNumber == '' || this.radioSerialNumber == undefined) {
                    showToastMessage += '* Radio Serial Number is mandatory. \n';

                }
                if (this.navigationSerialNumber == '' || this.navigationSerialNumber == undefined) {
                    showToastMessage += '* Navigation Serial Number is mandatory. \n';

                }
                if (showToastMessage != '\n') {
                    // this.showToast_error(showToastMessage);
                    this.errorMessage = showToastMessage;
                    this.showerror = true;
                    this.isresult = true;
                    return;
                }
                this.isresult = false;
                this.showerror = false;
                await this.getBothCodeResponse();
            }
            if (this.searchType == 'RadioCode') {
                //console.log('isRadio called');
                let showToastMessage = '\n';
                if (this.radioSerialNumber == '' || this.radioSerialNumber == undefined) {
                    showToastMessage = '* Radio Serial Number is mandatory.';

                }
                if (showToastMessage != '\n') {
                    //this.showToast_error(showToastMessage);
                    this.errorMessage = showToastMessage;
                    this.showerror = true;
                    this.isresult = true;
                    return;
                }
                this.isresult = false;
                this.showerror = false;
                await this.getRadioResponse();
            }

            if (this.searchType == 'Navigationcode') {
                //console.log('isNavigation called');
                let showToastMessage = '\n';
                if (this.navigationSerialNumber == '' || this.navigationSerialNumber == undefined) {
                    showToastMessage = '* Navigation Serial Number is mandatory.';

                }
                if (showToastMessage != '\n') {
                    // this.showToast_error(showToastMessage);
                    this.errorMessage = showToastMessage;
                    this.showerror = true;
                    this.isresult = true;
                    return;
                }
                this.isresult = false;
                this.showerror = false;
                await this.getNaviCodeResponse();
            }
        } else {
            //  this.isresult=true;
        }

    }
    getBothCodeResponse = async () => {
        this.responseRadioCode = await getRadioCode({ code: this.radioSerialNumber });
        this.radiocode = this.responseRadioCode.RadioCodeBody.map((eachcode) => eachcode.Code).join(', ');
        let isRadioSuccess = this.responseRadioCode ? this.responseRadioCode.Header.ReturnType : '';
        let radioreturnmessage = this.responseRadioCode ? this.responseRadioCode.radioresponse.replaceAll('\/', '') : '';
        let radioreturncode = this.responseRadioCode.Header.ReturnCode;

        this.responseNavigationCode = await getNavigationCode({ code: this.navigationSerialNumber });
        this.navigationCode = this.responseNavigationCode.RadioCodeBody.map((eachcode) => eachcode.Code).join(', ');
        let isNaviSuccess = this.responseNavigationCode ? this.responseNavigationCode.Header.ReturnType : '';
        let navireturnmessage = this.responseNavigationCode ? this.responseNavigationCode.navigationresponse.replaceAll('\/', '') : '';
        let navireturncode = this.responseNavigationCode.Header.ReturnCode;

        if (isRadioSuccess == 'Success' && isNaviSuccess == 'Success') {
            this.isSuccess = 'Success';
            this.returncode = radioreturncode;
            this.returnmessage = 'Radio Response==>>' + radioreturnmessage + '\n' + 'Navigation Response==>>' + navireturnmessage;
        } else if (isRadioSuccess != 'Success' && isNaviSuccess != 'Success') {
            this.isSuccess = isRadioSuccess;
            this.returncode = radioreturncode;
            this.returnmessage = 'Radio Response==>>' + radioreturnmessage + '\n' + 'Navigation Response==>>' + navireturnmessage;
        } else if (isRadioSuccess != 'Success') {
            this.isSuccess = isRadioSuccess;
            this.returncode = radioreturncode;
            this.returnmessage = 'Radio Response==>>' + radioreturnmessage + '\n' + 'Navigation Response==>>' + navireturnmessage;
        } else if (isNaviSuccess != 'Success') {
            this.isSuccess = isNaviSuccess;
            this.returncode = navireturncode;
            this.returnmessage = 'Radio Response==>>' + radioreturnmessage + '\n' + 'Navigation Response==>>' + navireturnmessage;
        }

        createradioNaviRequest({ clientIpAddress: this.sourceIp, response: this.returnmessage, radioCode: this.radiocode, navCode: this.navigationCode, radioserialNumber: this.radioSerialNumber, navserialNumber: this.navigationSerialNumber, vin: this.Vin, email: this.email, phone: this.phone, zipcode: this.ZipCode, isSuccess: this.isSuccess, isRecurringerror: this.isRecurringerror, radioNavId: this.radioNavRequest })
            .then(createradioNaviRequestResult => {
                //console.log('Both_createradioNaviRequestResult==>>', createradioNaviRequestResult);
                this.radioNavRequest = createradioNaviRequestResult;
                return storeRadioOrNaviCode({ vin: this.Vin, ownershipId: this.ownershipid, navCode: this.navigationCode, radioCode: this.radiocode, isSuccess: this.isSuccess, udateVin: this.udateVin, radioserialNumber: this.radioSerialNumber, navserialNumber: this.navigationSerialNumber })
            })
            .then(storeRadioOrNaviCodeResult => {
                //console.log('Both_storeRadioOrNaviCode=>>', JSON.stringify(storeRadioOrNaviCodeResult));
                return createradioNaviRequestFailure({ returncode: this.returncode, response: this.returnmessage, vin: this.Vin, radioserialNumber: this.radioSerialNumber, navserialNumber: this.navigationSerialNumber, email: this.email, radioNavRequest: this.radioNavRequest, isSuccess: this.isSuccess, phone: this.phone, zipcode: this.ZipCode })
            })
            .then(createradioNaviRequestFailResult => {
                //console.log('Both_createradioNaviRequestFailResult=>>', JSON.stringify(createradioNaviRequestFailResult));
                this.navigateToResultPage();
                // this.isresult =false;
            })
            .catch(error => {
                //console.log('getNaviCodeResponse error==>>', JSON.stringify(error));
                if (error.body.pageErrors) {
                    // this.showToast_error(JSON.stringify(error.body.pageErrors[0].message));
                    this.errorMessage = JSON.stringify(error.body.pageErrors[0].message);
                    this.showerror = true;
                    this.isresult = true;
                }
                else {
                    // this.showToast_error(error.body.message);
                    this.errorMessage = error.body.message;
                    this.showerror = true;
                    this.isresult = true;
                }
            })
    }
    getNaviCodeResponse = async () => {
        this.responseNavigationCode = await getNavigationCode({ code: this.navigationSerialNumber })
            .then(result => {
                this.navigationCode = result.RadioCodeBody.map((eachcode) => eachcode.Code).join(', ');
                //console.log('result==>>', JSON.stringify(result));
                this.isSuccess = result.Header.ReturnType;
                this.returncode = result.Header.ReturnCode;
                this.returnmessage = result.navigationresponse.replaceAll('\/', '');
                createradioNaviRequest({ clientIpAddress: this.sourceIp, response: this.returnmessage, navCode: this.navigationCode, vin: this.Vin, navserialNumber: this.navigationSerialNumber, email: this.email, phone: this.phone, zipcode: this.ZipCode, isSuccess: this.isSuccess, isRecurringerror: this.isRecurringerror, radioNavId: this.radioNavRequest })
                    .then(createradioNaviRequestResult => {
                        //console.log('Navi_createradioNaviRequestResult==>>', typeof (createradioNaviRequestResult));
                        this.radioNavRequest = createradioNaviRequestResult;
                        return storeRadioOrNaviCode({ vin: this.Vin, ownershipId: this.ownershipid, navCode: this.navigationCode, radioCode: this.radiocode, isSuccess: this.isSuccess, udateVin: this.udateVin, radioserialNumber: this.radioSerialNumber, navserialNumber: this.navigationSerialNumber })
                    })
                    .then(storeRadioOrNaviCodeResult => {
                        //console.log('navi_storeRadioOrNaviCode=>>', JSON.stringify(storeRadioOrNaviCodeResult));
                        return createradioNaviRequestFailure({ returncode: this.returncode, response: this.returnmessage, vin: this.Vin, navserialNumber: this.navigationSerialNumber, email: this.email, radioNavRequest: this.radioNavRequest, isSuccess: this.isSuccess, phone: this.phone, zipcode: this.ZipCode })
                    })
                    .then(createradioNaviRequestFailResult => {
                        //console.log('navi_createradioNaviRequestFailResult=>>', JSON.stringify(createradioNaviRequestFailResult));
                        this.navigateToResultPage();
                        //  this.isresult =false;
                    })
                    .catch(error => {
                        //console.log('getNaviCodeResponse error==>>', JSON.stringify(error));
                        if (error.body.pageErrors) {
                            // this.showToast_error(JSON.stringify(error.body.pageErrors[0].message));
                            this.errorMessage = JSON.stringify(error.body.pageErrors[0].message);
                            this.showerror = true;
                            this.isresult = true;
                        }
                        else {
                            // this.showToast_error(error.body.message);
                            this.errorMessage = error.body.message;
                            this.showerror = true;
                            this.isresult = true;
                        }

                    })
            })
    }


    getRadioResponse = async () => {
        this.responseRadioCode = await getRadioCode({ code: this.radioSerialNumber })
            .then(result => {
                this.radiocode = result.RadioCodeBody.map((eachcode) => eachcode.Code).join(', ');
                this.isSuccess = result.Header.ReturnType;
                this.returncode = result.Header.ReturnCode;
                this.returnmessage = result.radioresponse.replaceAll('\/', '');
                createradioNaviRequest({ clientIpAddress: this.sourceIp, response: this.returnmessage, radioCode: this.radiocode, vin: this.Vin, radioserialNumber: this.radioSerialNumber, email: this.email, phone: this.phone, zipcode: this.ZipCode, isSuccess: this.isSuccess, isRecurringerror: this.isRecurringerror, radioNavId: this.radioNavRequest })
                    .then(createradioNaviRequestResult => {
                        //console.log('createradioNaviRequestResult==>>', JSON.stringify(createradioNaviRequestResult));
                        this.radioNavRequest = createradioNaviRequestResult;
                        return storeRadioOrNaviCode({ vin: this.Vin, ownershipId: this.ownershipid, navCode: this.navigationCode, radioCode: this.radiocode, isSuccess: this.isSuccess, udateVin: this.udateVin, radioserialNumber: this.radioSerialNumber, navserialNumber: this.navigationSerialNumber })
                    })
                    .then(storeRadioOrNaviCodeResult => {
                        //console.log('storeRadioOrNaviCode=>>', JSON.stringify(storeRadioOrNaviCodeResult));
                        return createradioNaviRequestFailure({ returncode: this.returncode, response: this.returnmessage, vin: this.Vin, radioserialNumber: this.radioSerialNumber, email: this.email, radioNavRequest: this.radioNavRequest, isSuccess: this.isSuccess, phone: this.phone, zipcode: this.ZipCode })
                    })
                    .then(createradioNaviRequestFailResult => {
                        //console.log('createradioNaviRequestFailResult=>>', JSON.stringify(createradioNaviRequestFailResult));
                        this.navigateToResultPage();
                        //  this.isresult =false;
                    })
                    .catch(error => {
                        //console.log('getRadioResponse error==>>', JSON.stringify(error));
                        if (error.body.pageErrors) {
                            // this.showToast_error(JSON.stringify(error.body.pageErrors[0].message));
                            this.errorMessage = JSON.stringify(error.body.pageErrors[0].message);
                            this.showerror = true;
                            this.isresult = true;
                        }
                        else {
                            // this.showToast_error(error.body.message);
                            this.errorMessage = error.body.message;
                            this.showerror = true;
                            this.isresult = true;
                        }
                    })
            })
    }

    navigateToResultPage() {
        this.errorMessage ='';
        var radioError=false;
        var NaviError=false;
        try {
            sessionStorage.setItem('rnv-color', this.color);
            sessionStorage.setItem('rnv-navigationSerialNumber', this.navigationSerialNumber);
            sessionStorage.setItem('rnv-radioSerialNumber', this.radioSerialNumber);
            sessionStorage.setItem('rnv-navigationCode', this.navigationCode);
            sessionStorage.setItem('rnv-radiocode', this.radiocode);
            sessionStorage.setItem('rnv-vin', this.Vin);
            sessionStorage.setItem('rnv-trim', this.trim);
            sessionStorage.setItem('rnv-model', this.model);
            sessionStorage.setItem('rnv-year', this.year);
            sessionStorage.setItem('rnv-isRadio', this.isRadio);
            sessionStorage.setItem('rnv-isNavigation', this.isNavigation);
            sessionStorage.setItem('rnv-isBoth', this.isBoth);
            if (this.isRadio === true && (this.radiocode == undefined || this.radiocode == '' || this.radiocode.trim().length == 0)) {
                this.errorMessage =this.errorMessage+'*Data not found for Radio Code Serial Number.  \n';
                radioError=true;
            }
            if (this.isNavigation === true && (this.navigationCode == undefined || this.navigationCode == '' || this.navigationCode.trim().length == 0)) {
                this.errorMessage =this.errorMessage+'*Data not found for Navigation Code Serial Number.  \n';
                NaviError=true;

            }
            if(radioError == true || NaviError == true){
                this.showerror = true;
                this.isresult = true;
                this.isRecurringerror = true;
                return;
            }

            if (this.fb == 'true') {
                this.navigate('/radio-nav-result?fb=true', {});
            } else {
                if (this.brand.includes('Acura')) {
                    this.navigate('/radio-nav-result?brand=Acura', {});
                } else {
                    this.navigate('/radio-nav-result?brand=Honda', {});
                }
            }
        } catch (e) {
            //console.log('@@error' + e);
        }

    }
}
import { track, wire } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import getStates from '@salesforce/apex/ownProductSettingsController.getStates';
import verifyCaptcha from '@salesforce/apex/ownRecaptchaController.verifyCaptcha';
import createCase from '@salesforce/apex/OwnSendAnEmailFormController.createCase';
import getCaseById from '@salesforce/apex/OwnSendAnEmailFormController.getCaseById';
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';
import getDropdowns from '@salesforce/apex/OwnSendAnEmailFormController.getDropdowns';
import getPreferredDealerName from '@salesforce/apex/OwnSendAnEmailFormController.getPreferredDealerName';
import { ISGUEST, getProductContext, getOrigin, createConsoles } from 'c/ownDataUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPersonMailingAddress from '@salesforce/apex/OwnSendAnEmailFormController.getPersonMailingAddress';
export default class ownSendAnEmailForm extends OwnBaseElement {
    @track states;
    @track hideSpinner;
    @track vinerror;
    @track verifiedBool;
    @track captchaValue;
    @track captchaResponse;
    @track required = true;
    @track isguest = ISGUEST;
    @track value_state;
    @track value_topic;
    @track value_subtopic;
    @track statesMap = new Map(Object.entries(this.states_code));
    @track formInputs = {};
    @track disable_emai;
    @track disable_vin;
    @track context;
    @track selected_topic;
    @track selected_subtopic;
    @track custom_metadata;
    @track user_federationid;

    // Breadcrumbs
    @track breadCrumbLabel = 'Honda Autos';
    @track breadCrumbUrl = 'help-honda';
    @track brand = 'Honda';

    @track showErrorBox = false;
    // @track errorBoxLabel = 'Error: Please verify the Captcha';
    @track errorBoxLabel = 'Error: Please complete the fields below and resubmit.';

    helpCenterUrls = {
        Honda: '/help-honda',
        Acura: '/help-acura',
        Powersports: '/help-powersports',
        Powerequipment: '/help-powerequipment',
        Marine: '/help-marine'
    }
    helpCenterLabels = {
        Honda: 'Honda Autos',
        Acura: 'Acura Autos',
        Powersports: 'Honda Powersports',
        Powerequipment: 'Honda Powerequipment',
        Marine: 'Honda Marine'
    }
    buildBreadcrums() {
        // this.brand = sessionStorage.getItem('BrandName') ? sessionStorage.getItem('BrandName') : 'Honda';
        this.breadCrumbLabel = this.helpCenterLabels[this.brandName];
        this.breadCrumbUrl = this.helpCenterUrls[this.brandName];
        if (this.breadCrumbLabel.includes('Powerequipment')) {
            this.breadCrumbLabel = this.breadCrumbLabel.replace('Powerequipment', 'Power Equipment');
        }
        this.breadCrumbLabel = this.breadCrumbLabel + ': Help Center';
    }

    get brandName() {
        return sessionStorage.getItem('BrandName') ? sessionStorage.getItem('BrandName') : 'Honda';
    }
    // Breadcrumbs

    get isAcura() {
        return this.brandName == 'Acura';
    }
    get isHonda() {
        return this.brandName == 'Honda';
    }

    get isPSP() {
        return this.brandName == 'Powersports';
    }

    get isPE() {
        return this.brandName == 'Powerequipment';
    }

    get isMarine() {
        return this.brandName == 'Marine';
    }

    get topicLabel() {
        return this.isAcura || this.isHonda || this.isPSP ? 'Topic (Please Select One)' : this.isPE ? 'What Product Line?' : 'What Engine Size?';
    }

    get subTopicLabel() {
        return this.isAcura || this.isHonda || this.isPSP ? 'Sub Topic (Please Select One)' : this.isPE ? 'What do you need help with?' : 'What do you need help with?';
    }

    @wire(getDropdowns)
    wiredData({ error, data }) {
        if (data) {
            console.log('$CRRS: getDropdowns-data-WIRE: ', data);
            this.custom_metadata = JSON.parse(JSON.stringify(data));
            this.phoneDropdowns = data.PhoneDropdowns;
            this.manualDropdowns = data.ManualDropdowns;
            this.phoneModelsAll = data.PhoneModels;
            this.phone_operatingsystems = data.Phone_OS;
            this.dropdowns = data.Topics;
            this.hideSpinner = true;
        } else if (error) {
            console.error('$CRRS: getDropdowns-error: ', error);
            this.hideSpinner = true;
        }
    }

    connectedCallback() {
        this.buildBreadcrums();
        this.fields_Clone = JSON.parse(JSON.stringify(this.fields));
        this.initialize();
    }

    initialize = async () => {
        let fromProductChooser = getOrigin() === 'ProductChooser' ? true : false;
        if (fromProductChooser) {
            this.context = await getProductContext('', true);
        } else {
            this.context = await getProductContext('', false);
        }
        console.log('$CRRS: context: ', JSON.parse(JSON.stringify(this.context)));
        if (!this.isguest && this.context && this.context.product && (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-'))) {
            // this.formInputs.Vin = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
            // this.disable_vin = this.formInputs.Vin ? true : false;
        }

        if(sessionStorage.getItem('fromRecallLink')){
            if (!this.isguest && this.context && this.context.product && this.context.product.ownershipId){
                if (this.context.product.productIdentifier || (this.context.product.vin && this.context.product.vin != '-')) {
                    this.formInputs.Vin = this.context.product.productIdentifier ? this.context.product.productIdentifier : this.context.product.vin;
                    // this.disable_vin = this.formInputs.Vin ? true : false;
                }
                getPreferredDealerName({ownershipId: this.context.product.ownershipId}).then((result) => {
                    console.log('$getPreferredDealerName-result: ',result);
                    this.formInputs.preferredDealer = result;
                }).catch((error) => {
                    console.error('$getPreferredDealerName-error: ',error); 
                });
            }
        }

        getStates().then(result => {
            console.log('$CRRS: getStates', result);
            this.states = result;
        }).catch(error => {
            console.error('$error: ', error);
        });
        if (!this.isguest) {
            getPersonMailingAddress().then((result) => {
                console.log('$CRRS: getPersonMailingAddress result: ', result);
                this.user_federationid = result.User?.FederationIdentifier;
                this.formInputs.FirstName = result.User.FirstName;
                this.formInputs.LastName = result.User.LastName;
                this.formInputs.Email = result.User.Email;
                this.formInputs.City = result.Account.PersonMailingAddress?.city;
                this.formInputs.PostalCode = result.Account.PersonMailingAddress?.postalCode;
                this.formInputs.State = this.statesMap.get(result.Account.PersonMailingAddress?.state.toLocaleLowerCase());
                this.formInputs.Street = result.Account.PersonMailingAddress?.street;
                this.formInputs.MailingAddress = this.formInputs.Street + ', ' + this.formInputs.City + ', ' + this.formInputs.PostalCode + ', ' + result.Account.PersonMailingAddress?.state;
                // this.disable_emai = this.formInputs.Email ? true : false;
                console.log('$CRRS: formInputs: ', JSON.parse(JSON.stringify(this.formInputs)));
            }).catch((error) => {
                console.error('$CRRS: getPersonMailingAddress error: ', error);
            });
        }
        console.log('$CRRS: fromRecallLink: ', sessionStorage.getItem('fromRecallLink'));
        if(sessionStorage.getItem('fromRecallLink')){
            // sessionStorage.removeItem('fromRecallLink');
            setTimeout( () => {
                this.handleChangeTopic({
                    detail: {
                        value: 'Recalls/Campaigns'
                    },
                    target: {
                        dataset: {
                            apiname: 'Topic_c__c'
                        }
                    }
                });
            }, 1000);
        }
    }

    handleGoToCaseDetail(){
        sessionStorage.setItem('defaulttab', 'My Support Cases');
        sessionStorage.setItem('caseNumberDetail', this.caseNumber);
        this.navigate('/my-account', {});
    }

    @track dropdowns = {};

    get topics() {
        if (this.isAcura) {
            return this.dropdowns.acura.topics;
        } else if (this.isHonda) {
            return this.dropdowns.honda.topics;
        } else if (this.isPSP) {
            return this.dropdowns.powersports.topics;
        } else if (this.isPE) {
            return this.dropdowns.powerequipment.topics;
        } else if (this.isMarine) {
            return this.dropdowns.marine.topics;
        } else {
            return this.dropdowns.acura.topics;
        }
    }

    @track manualDropdowns;

    @track selected_makemanual;
    handleChangeMakeManual(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
        this.selected_modelmanual = '';
        this.selected_yearmanual = '';
        this.modelmanuals = [];
        this.yearmanuals = [];
        this.selected_makemanual = event.detail.value;
        console.log('$CRRS: selected_makemanual: ', this.selected_makemanual);
        this.modelmanuals = this.manualDropdowns.model[this.selected_makemanual]['topics'];
    }

    @track modelmanuals = [];
    @track selected_modelmanual;

    handleChangeModelManual(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
        this.selected_yearmanual = '';
        this.selected_modelmanual = event.detail.value;
        console.log('$CRRS: selected_modelmanual: ', this.selected_modelmanual);
        this.yearmanuals = this.manualDropdowns.model[this.selected_makemanual]['subtopics'][this.selected_modelmanual];
    }

    get disable_modelmanual() {
        return this.modelmanuals.length ? false : true;
    }

    @track yearmanuals = [];
    @track selected_yearmanual;

    handleChangeYearManual(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
        this.selected_yearmanual = event.detail.value;
        console.log('$CRRS: selected_yearmanual: ', this.selected_yearmanual);
    }

    get disable_yearmanual() {
        return this.yearmanuals.length ? false : true;
    }

    get disable_subtopics() {
        this.showFieldsSection = this.subtopics.length && this.selected_topic != 'Acura Financial Services (AFS)' && this.selected_topic != 'Honda Financial Services (HFS)' ? true : false;
        if ((this.isPE || this.isMarine) && !this.selected_subtopic) {
            this.showFieldsSection = false;
        }
        return this.subtopics.length ? false : true;
    }

    @track showFinancialDiv;

    handleChangeTopic(event) {

        this.selected_topic = event.detail.value;
        this.selected_subtopic = '';
        this.subtopics = [];

        if (this.isPE && this.selected_topic == 'Pressure Washers' && this.custom_metadata.PE_Pressure_Washers.PE_Pressure_Washers.Text) {
            this.subtopics = [];
            this.showFinancialDiv = false;
            this.showFieldsSection = false;
            this.isPEPressureWashers = true;
            return;
        } else {
            this.isPEPressureWashers = false;
        }

        if (this.isPE && this.selected_topic == 'Pressure Washers' && !this.custom_metadata.PE_Pressure_Washers.PE_Pressure_Washers.Text) {
            this.subtopics = [];
            this.disable_subtopics = true;
            this.fields.Subtopic.required = false;
        }

        if (this.selected_topic == 'Acura Financial Services (AFS)' || this.selected_topic == 'Honda Financial Services (HFS)') {
            this.showFinancialDiv = true;
        } else {
            this.showFinancialDiv = false;
        }
        console.log('$CRRS: selected_topic: ', this.selected_topic);
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);

        if (this.isAcura)
            this.subtopics = this.dropdowns.acura.subtopics[this.selected_topic];
        else if (this.isHonda)
            this.subtopics = this.dropdowns.honda.subtopics[this.selected_topic];
        else if (this.isPSP)
            this.subtopics = this.dropdowns.powersports.subtopics[this.selected_topic];
        else if (this.isPE)
            this.subtopics = this.dropdowns.powerequipment.subtopics[this.selected_topic];
        else if (this.isMarine)
            this.subtopics = this.dropdowns.marine.subtopics[this.selected_topic];
        if (!this.isPE && !this.isMarine)
            this.showHideFields();
    }
    @track fields_Clone;
    showHideFields() {
        this.fields = JSON.parse(JSON.stringify(this.fields_Clone));
        let topic = this.selected_topic;
        let subtopic = this.selected_subtopic;
        if (this.isAcura || this.isHonda) {
            if (topic == 'Accident/Injury' || topic == 'Vehicles' || topic == 'Dealer Experience' || topic == 'Parts' || topic == 'Roadside Assistance') {
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.ZipCode.show = true;
                this.fields.Phone.show = true;
                this.fields.VIN.show = true;
                this.fields.Mileage.show = true;
                this.fields.Mileage.required = false;
                this.fields.Description.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (topic == 'Dealership Experience' || topic == 'Vehicle Service Contract (AcuraCare)') {
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.ZipCode.show = true;
                this.fields.Phone.show = true;
                this.fields.VIN.show = true;
                this.fields.VIN.required = false;
                this.fields.Mileage.show = true;
                this.fields.Mileage.required = false;
                this.fields.Description.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (topic == 'Acura NSX' || topic == 'Vehicle Service Contract (HondaCare)' || topic == 'Other') {
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.ZipCode.show = true;
                this.fields.Phone.show = true;
                this.fields.VIN.show = true;
                this.fields.VIN.required = false;
                this.fields.Mileage.show = true;
                this.fields.Mileage.required = false;
                this.fields.Description.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (topic == 'Recalls/Campaigns') {
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Street.show = true;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.VIN.show = true;
                this.fields.Mileage.show = true;
                this.fields.Description.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = true;
                this.fields.File1.Namelabel = 'Claim Form';
                this.fields.File2.show = true;
                this.fields.File2.required = true;
                this.fields.File2.Namelabel = 'Repair Order';
                this.fields.File3.show = true;
                this.fields.File3.required = true;
                this.fields.File3.Namelabel = 'Proof of Payment';
                this.fields.File4.show = true;
                // this.fields.File4.required = true;
                this.fields.File4.Namelabel = 'Additional Supporting Documents';

            } else if (topic == 'AcuraLink' || topic == 'HondaLink' || topic == 'In-Car Technology') {
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.ZipCode.show = true;
                this.fields.VIN.show = true;
                this.fields.VIN.required = false;
                this.fields.MakeManual.show = true;
                this.fields.MakeManual.required = false;
                this.fields.ModelManual.show = true;
                this.fields.ModelManual.required = false;
                this.fields.YearManual.show = true;
                this.fields.YearManual.required = false;
                this.fields.VehicleTrim.show = true;
                this.fields.VehicleTrim.required = false;
                this.fields.PhoneCarrier.show = true;
                this.fields.PhoneCarrier.required = false;
                this.fields.PhoneManufacturer.show = true;
                this.fields.PhoneManufacturer.required = false;
                this.fields.PhoneModel.show = true;
                this.fields.PhoneModel.required = false;
                this.fields.PhoneOS.show = true;
                this.fields.PhoneOS.required = false;
                this.fields.Description.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            }
        } else if (this.isPSP) {
            if (topic == 'Recalls/Campaigns') {
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Street.show = true;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.PreferredDealer.show = true;
                this.fields.Dealership.show = true;
                this.fields.VIN.show = true;
                this.fields.Mileage.show = true;
                this.fields.Description.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = true;
                this.fields.File1.Namelabel = 'Claim Form';
                this.fields.File2.show = true;
                this.fields.File2.required = true;
                this.fields.File2.Namelabel = 'Repair Order';
                this.fields.File3.show = true;
                this.fields.File3.required = true;
                this.fields.File3.Namelabel = 'Proof of Payment';
                this.fields.File4.show = true;
                // this.fields.File4.required = true;
                this.fields.File4.Namelabel = 'Additional Supporting Documents';
            } else if (topic == 'Dealership Experience') {
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.ZipCode.show = true;
                this.fields.PreferredDealer.show = true;
                this.fields.Dealership.show = true;
                this.fields.VIN.show = true;
                this.fields.Mileage.show = true;
                this.fields.Description.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (topic == "Manufacturer's Statement of Origin (MSO) Info Letter/Vehicle Info Letter Request") {
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Street.show = true;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.VIN.show = true;
                this.fields.Mileage.show = true;
                this.fields.Description.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (topic == 'Product') {
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.ZipCode.show = true;
                this.fields.PreferredDealer.show = true;
                this.fields.Dealership.show = true;
                this.fields.VIN.show = true;
                this.fields.Mileage.show = true;
                this.fields.Description.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            }
        } else if (this.isPE) {
            if (subtopic == 'Issue with a Product' || subtopic == 'Concern with a Dealer') {
                this.fields.PreferredDealer.show = true;
                this.fields.PreferredDealer.required = false;
                this.fields.DealerCity.show = true;
                this.fields.DealerState.show = true;
                this.fields.DealerState.required = false;
                this.fields.Dealership.show = true;
                this.fields.Dealership.required = false;
                this.fields.Model.show = true;
                this.fields.Model.required = false;
                this.fields.SerialNumber.show = true;
                this.fields.SerialNumber.required = false;
                this.fields.HowCanWeHelpYou.show = true;
                this.fields.Salutation.show = true;
                this.fields.Salutation.required = false;
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Phone.required = false;
                this.fields.AddressLine1.show = true;
                this.fields.AddressLine2.show = true;
                this.fields.AddressLine2.required = false;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (subtopic == 'General Product Question' || subtopic == 'Compliment') {
                this.fields.Model.show = true;
                this.fields.Model.required = false;
                this.fields.SerialNumber.show = true;
                this.fields.SerialNumber.required = false;
                this.fields.HowCanWeHelpYou.show = true;
                this.fields.Salutation.show = true;
                this.fields.Salutation.required = false;
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Phone.required = false;
                this.fields.AddressLine1.show = true;
                this.fields.AddressLine2.show = true;
                this.fields.AddressLine2.required = false;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (subtopic == 'Change of Address') {
                this.fields.Model.show = true;
                this.fields.Model.required = false;
                this.fields.SerialNumber.show = true;
                this.fields.SerialNumber.required = false;
                this.fields.Salutation.show = true;
                this.fields.Salutation.required = false;
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Phone.required = false;
                this.fields.AddressLine1.show = true;
                this.fields.AddressLine2.show = true;
                this.fields.AddressLine2.required = false;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (subtopic == 'Other') {
                this.fields.Model.show = true;
                this.fields.Model.required = false;
                this.fields.SerialNumber.show = true;
                this.fields.SerialNumber.required = false;
                this.fields.HowCanWeHelpYou.show = true;
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Phone.required = false;
                this.fields.AddressLine1.show = true;
                this.fields.AddressLine2.show = true;
                this.fields.AddressLine2.required = false;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            }
        } else if (this.isMarine) {
            if (subtopic == 'Issue with a Product' || subtopic == 'Concern with a Dealer') {
                this.fields.PreferredDealer.show = true;
                this.fields.PreferredDealer.required = false;
                this.fields.DealerCity.show = true;
                this.fields.DealerState.show = true;
                this.fields.DealerState.required = false;
                this.fields.Dealership.show = true;
                this.fields.Dealership.required = false;
                this.fields.Model.show = true;
                this.fields.Model.required = false;
                this.fields.SerialNumber.show = true;
                this.fields.SerialNumber.required = false;
                this.fields.HowCanWeHelpYou.show = true;
                this.fields.Salutation.show = true;
                this.fields.Salutation.required = false;
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Phone.required = false;
                this.fields.AddressLine1.show = true;
                this.fields.AddressLine2.show = true;
                this.fields.AddressLine2.required = false;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (subtopic == 'General Product Question' || subtopic == 'Compliment') {
                this.fields.Model.show = true;
                this.fields.Model.required = false;
                this.fields.SerialNumber.show = true;
                this.fields.SerialNumber.required = false;
                this.fields.HowCanWeHelpYou.show = true;
                this.fields.Salutation.show = true;
                this.fields.Salutation.required = false;
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Phone.required = false;
                this.fields.AddressLine1.show = true;
                this.fields.AddressLine2.show = true;
                this.fields.AddressLine2.required = false;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (subtopic == 'Change of Address') {
                this.fields.Model.show = true;
                this.fields.Model.required = false;
                this.fields.SerialNumber.show = true;
                this.fields.SerialNumber.required = false;
                this.fields.Salutation.show = true;
                this.fields.Salutation.required = false;
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Phone.required = false;
                this.fields.AddressLine1.show = true;
                this.fields.AddressLine2.show = true;
                this.fields.AddressLine2.required = false;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            } else if (subtopic == 'Other') {
                this.fields.Model.show = true;
                this.fields.Model.required = false;
                this.fields.SerialNumber.show = true;
                this.fields.SerialNumber.required = false;
                this.fields.HowCanWeHelpYou.show = true;
                this.fields.FirstName.show = true;
                this.fields.LastName.show = true;
                this.fields.EmailAddress.show = true;
                this.fields.Phone.show = true;
                this.fields.Phone.required = false;
                this.fields.AddressLine1.show = true;
                this.fields.AddressLine2.show = true;
                this.fields.AddressLine2.required = false;
                this.fields.City.show = true;
                this.fields.State.show = true;
                this.fields.ZipCode.show = true;
                this.fields.File1.show = true;
                this.fields.File1.required = false;
            }
        }
    }

    @track fields = {
        Topic: {
            // label: 'Topic',
            label: this.isPE ? 'What Product Line?' : this.isMarine ? 'What Engine Size?' : 'Topic',
            apiName: this.isPE ? 'WebToCase_Power_Equip_Product_Line_c__c' : this.isMarine ? 'WebToCase_Marine_What_Engine_Size_c__c' : 'Topic_c__c',
            // apiName: 'Topic_c__c',
            class: this.isPE ? 'WebToCase_Power_Equip_Product_Line_c__c' : this.isMarine ? 'WebToCase_Marine_What_Engine_Size_c__c' : 'Topic_c__c',
            // class: 'Topic_c__c',
            required: true,
            show: false,
            disabled: false
        },
        Subtopic: {
            // label: 'Sub Topic',
            label: this.isPE ? 'What do you need help with?' : this.isMarine ? 'What do you need help with?' : 'Sub Topic (Please Select One)',
            // apiName: 'Sub_topic_c__c',
            apiName: this.isPE ? 'WebToCase_Marine_do_you_need_help_with_c__c' : this.isMarine ? 'WebToCase_Marine_do_you_need_help_with_c__c' : 'Sub_topic_c__c',
            // class: 'Sub_topic_c__c',
            class: this.isPE ? 'WebToCase_Marine_do_you_need_help_with_c__c' : this.isMarine ? 'WebToCase_Marine_do_you_need_help_with_c__c' : 'Sub_topic_c__c',
            required: true,
            show: false,
            disabled: false
        },
        FirstName: {
            label: 'First Name',
            apiName: 'First_Name_c__c',
            class: 'First_Name_c__c',
            required: true,
            show: false,
            disabled: false
        },
        LastName: {
            Namelabel: 'Last Name',
            apiName: 'Last_Name_c__c',
            class: 'Last_Name_c__c',
            required: true,
            show: false,
            disabled: false
        },
        EmailAddress: {
            label: 'Email Address',
            apiName: 'SuppliedEmail__c',
            class: 'SuppliedEmail__c',
            required: true,
            show: false,
            disabled: false
        },
        Phone: {
            Namelabel: 'Phone',
            apiName: 'SuppliedPhone__c',
            class: 'SuppliedPhone__c',
            required: true,
            show: false,
            disabled: false
        },
        Street: {
            Namelabel: 'Street',
            apiName: 'WebToCase_Street_c__c',
            class: 'WebToCase_Street_c__c',
            required: true,
            show: false,
            disabled: false
        },
        City: {
            Namelabel: 'City',
            apiName: 'WebToCase_City_c__c',
            class: 'WebToCase_City_c__c',
            required: true,
            show: false,
            disabled: false
        },
        State: {
            Namelabel: 'State',
            apiName: 'WebToCase_State_c__c',
            class: 'WebToCase_State_c__c',
            required: true,
            show: false,
            disabled: false
        },
        ZipCode: {
            Namelabel: 'Zip Code',
            apiName: 'WebToCase_Zipcode_c__c',
            class: 'WebToCase_Zipcode_c__c',
            required: true,
            show: false,
            disabled: false
        },
        Model: {
            Namelabel: 'Model',
            apiName: 'WebtoCase_Model_c__c',
            class: 'WebtoCase_Model_c__c',
            required: true,
            show: false,
            disabled: false
        },
        AddressLine1: {
            Namelabel: 'Address Line 1',
            apiName: 'WebToCase_Street_c__c',
            class: 'WebToCase_Street_c__c',
            required: true,
            show: false,
            disabled: false
        },
        AddressLine2: {
            Namelabel: 'Address Line 2',
            apiName: 'WebToCase_Street2_c__c',
            class: 'WebToCase_Street2_c__c',
            required: true,
            show: false,
            disabled: false
        },
        Salutation: {
            Namelabel: 'Model',
            apiName: 'webToCase_Title_c__c',
            class: 'webToCase_Title_c__c',
            required: true,
            show: false,
            disabled: false
        },
        HowCanWeHelpYou: {
            Namelabel: 'How can we help you?',
            apiName: 'WebToCase_How_can_we_help_you_c__c',
            class: 'WebToCase_How_can_we_help_you_c__c',
            required: true,
            show: false,
            disabled: false
        },
        SerialNumber: {
            Namelabel: 'Serial Number',
            apiName: 'VIN_Text_c__c',
            class: 'VIN_Text_c__c',
            required: true,
            show: false,
            disabled: false
        },
        DealerCity: {
            Namelabel: "Dealer's City",
            apiName: 'WebToCase_Dealer_s_City_c__c',
            class: 'WebToCase_Dealer_s_City_c__c',
            required: true,
            show: false,
            disabled: false
        },
        DealerState: {
            Namelabel: "Dealer's State",
            apiName: 'WebToCase_Dealer_s_State_c__c',
            class: 'WebToCase_Dealer_s_State_c__c',
            required: true,
            show: false,
            disabled: false
        },
        PreferredDealer: {
            Namelabel: 'Preferred Dealer',
            apiName: 'Name_of_Dealer_c__c',
            class: 'Name_of_Dealer_c__c',
            required: true,
            show: false,
            disabled: false
        },
        Dealership: {
            Namelabel: 'Is your product at this dealership?',
            apiName: 'W2C_IsYourProductCurrentlyAtThisDealer_c__c',
            class: 'W2C_IsYourProductCurrentlyAtThisDealer_c__c',
            required: true,
            show: false,
            disabled: false
        },
        VIN: {
            Namelabel: 'VIN',
            apiName: 'VIN_Text_c__c',
            class: 'VIN_Text_c__c',
            required: true,
            show: false,
            disabled: false
        },
        MakeManual: {
            Namelabel: 'Make (manual)',
            apiName: 'Make_manual_c__c',
            class: 'Make_manual_c__c',
            required: true,
            show: false,
            disabled: false
        },
        ModelManual: {
            Namelabel: 'Model (Manual)',
            apiName: 'Model_Manual_c__c',
            class: 'Model_Manual_c__c',
            required: true,
            show: false,
            disabled: false
        },
        YearManual: {
            Namelabel: 'Year (manual)',
            apiName: 'Year_manual_c__c',
            class: 'Year_manual_c__c',
            required: true,
            show: false,
            disabled: false
        },
        VehicleTrim: {
            Namelabel: 'Vehicle Trim',
            apiName: 'WebToCase_Vehicle_Trim_c__c',
            class: 'WebToCase_Vehicle_Trim_c__c',
            required: true,
            show: false,
            disabled: false
        },
        PhoneCarrier: {
            Namelabel: 'Phone Carrier',
            apiName: 'Phone_Carrier_c__c',
            class: 'Phone_Carrier_c__c',
            required: true,
            show: false,
            disabled: false
        },
        PhoneManufacturer: {
            Namelabel: 'Phone Manufacturer',
            apiName: 'Phone_Manufacturer_c__c',
            class: 'Phone_Manufacturer_c__c',
            required: true,
            show: false,
            disabled: false
        },
        PhoneModel: {
            Namelabel: 'Phone Model',
            apiName: 'Phone_Model_c__c',
            class: 'Phone_Model_c__c',
            required: true,
            show: false,
            disabled: false
        },
        PhoneOS: {
            Namelabel: 'Phone OS',
            apiName: 'Phone_OS_c__c',
            class: 'Phone_OS_c__c',
            required: true,
            show: false,
            disabled: false
        },
        Mileage: {
            Namelabel: 'Current Mileage',
            apiName: 'Miles_c__c',
            class: 'Miles_c__c',
            required: true,
            show: false,
            disabled: false
        },
        Description: {
            Namelabel: 'Description',
            apiName: 'Description__c',
            class: 'Description__c',
            required: true,
            show: false,
            disabled: false
        },
        File1: {
            Namelabel: 'File',
            apiName: '',
            class: '',
            required: false,
            show: false,
            data: null,
            showRequiredLabel: false,
            disabled: false
        },
        File2: {
            Namelabel: 'File',
            apiName: '',
            class: '',
            required: false,
            show: false,
            data: null,
            showRequiredLabel: false,
            disabled: false
        },
        File3: {
            Namelabel: 'File',
            apiName: '',
            class: '',
            required: false,
            show: false,
            data: null,
            showRequiredLabel: false,
            disabled: false
        },
        File4: {
            Namelabel: 'File',
            apiName: '',
            class: '',
            required: false,
            show: false,
            data: null,
            showRequiredLabel: false,
            disabled: false
        },
    };

    handleChangeSubTopic(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
        this.selected_subtopic = event.detail.value;
        console.log('$CRRS: selected_subtopic: ', this.selected_subtopic);

        
        if (this.isPE || this.isMarine) {
            this.showHideFields();
        }

        if((this.isAcura || this.isHonda || this.isPSP) && this.selected_topic == 'Recalls/Campaigns' && this.selected_subtopic == 'All Other Questions'){

            this.fields.File1.required = false;
            this.fields.File1.Namelabel = 'Claim Form';
            // this.fields.File1.Namelabel = 'File 1';
            this.fields.File2.required = false;
            this.fields.File2.Namelabel = 'Repair Order';
            // this.fields.File2.Namelabel = 'File 2';
            this.fields.File3.required = false;
            this.fields.File3.Namelabel = 'Proof of Payment';
            // this.fields.File3.Namelabel = 'File 3';
            this.fields.File4.required = false;
            this.fields.File4.Namelabel = 'Additional Supporting Documents';
            // this.fields.File4.Namelabel = 'File 4';

        }else if((this.isAcura || this.isHonda || this.isPSP) && this.selected_topic == 'Recalls/Campaigns' && this.selected_subtopic == 'Recalls/Campaigns: Reimbursement Request'){
            this.fields.File1.show = true;
            this.fields.File1.required = true;
            this.fields.File1.Namelabel = 'Claim Form';
            this.fields.File2.show = true;
            this.fields.File2.required = true;
            this.fields.File2.Namelabel = 'Repair Order';
            this.fields.File3.show = true;
            this.fields.File3.required = true;
            this.fields.File3.Namelabel = 'Proof of Payment';
            this.fields.File4.show = true;
            this.fields.File4.required = false;
        }
    }

    @track subtopics = [];
    @track showFieldsSection;


    handleChange(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
    }
    handleChangeDealerState(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
    }

    //Phone Dropdowns Start
    @track phoneDropdowns;
    @track phoneModelsAll;
    @track selected_phonecarrier;

    get phonecarriers() {
        return this.phoneDropdowns.carriers;
    }

    handleChangePhoneCarrier(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
        this.selected_phonemanufacturer = '';
        this.phoneManufactureres = [];
        this.selected_phonemodel = '';
        this.phoneModels = [];
        this.selected_phonecarrier = event.detail.value;
        console.log('$CRRS: selected_phonecarrier: ', this.selected_phonecarrier);

        this.phoneManufactureres = this.phoneDropdowns.manufacturer[this.selected_phonecarrier]['manufactureres'];
    }


    @track selected_phonemanufacturer;
    @track phoneManufactureres = [];

    handleChangePhoneManufacturer(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
        this.selected_phonemodel = '';
        this.phoneModels = [];
        this.selected_phonemanufacturer = event.detail.value;
        console.log('$CRRS: selected_phonemanufacturer: ', this.selected_phonemanufacturer);

        this.phoneModels = this.phoneModelsAll[this.selected_phonemanufacturer];
    }

    get disable_phonemanufacturer() {
        return this.phoneManufactureres.length ? false : true;
    }

    @track selected_phonemodel;
    @track phoneModels = [];

    handleChangePhoneModel(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
        this.selected_phonemodel = event.detail.value;
        console.log('$CRRS: selected_phonemodel: ', this.selected_phonemodel);
    }

    get disable_phonemodel() {
        return this.phoneModels.length ? false : true;
    }

    //Phone Dropdowns End

    //PhoneOS
    @track selected_phoneos;
    @track phone_operatingsystems;
    handleChangePhoneOS(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
        this.selected_phoneos = event.detail.value;
        console.log('$CRRS: selected_phoneos: ', this.selected_phoneos);
    }
    //PhoneOS


    // Radio Yes No
    @track radio_value = true;
    handleRadioChange(event) {
        let checked = event.target.checked;
        let radio = event.target.dataset.label;
        console.log(checked);
        console.log(radio);
    }
    // Radio Yes No

    // Salutation
    @track selected_salutation;
    handleChangeSalutation(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
        this.selected_salutation = event.detail.value;
        console.log('$CRRS: selected_salutation: ', this.selected_salutation);
    }

    get salutations() {
        return [
            { label: 'Mr.', value: 'Mr.' },
            { label: 'Mrs.', value: 'Mrs.' },
            { label: 'Ms.', value: 'Ms.' },
            { label: 'Dr.', value: 'Dr.' }
        ]
    }
    // Salutation

    inputChange(event) {
        let apiname = event.target.dataset.apiname;
        console.log('$CRRS: apiname: ', apiname);
    }

    handleKeyPressPhone(event) {
        const regex = /[0-9]/g;
        const key = String.fromCharCode(event.charCode);
        if (!regex.test(key)) {
            event.preventDefault();
        }
    }

    handleCaptcha(event) {
        console.log('$CRRS: Updated value is ', JSON.stringify(event.detail));
        this.verifiedBool = event.detail.value;

        if (event.detail.response) {
            console.log('$CRRS: Response is ' + event.detail.response);
            this.captchaResponse = event.detail.response;
        } else {
            this.captchaValue = false;
        }

        verifyCaptcha({ recaptchaResponse: this.captchaResponse }).then(result => {
            console.log('$CRRS: result :: ', result);
            this.captchaValue = result;
        }).catch(error => {
            console.log('$CRRS: result :: ', error);
        });
    }
    @track isFormSubmitting;
    @track isCaseSubmissionSuccess;
    async submitForm() {

        let tag;
        let isValidForm = true;
        this.isFormSubmitting = true;
        this.errorBoxLabel = 'Error: Please complete the fields below and resubmit.';
        if(this.template.querySelector('.vin')){
            this.vinerror = false;
            this.template.querySelector('.vin').setCustomValidity('');
            this.template.querySelector('.vin').reportValidity();
        }

        this.template.querySelectorAll('.validation').forEach(element => {
            element.reportValidity()
            if (isValidForm) {
                isValidForm = element.reportValidity();
                if (!isValidForm) {
                    if (!tag)
                        tag = element;
                }
            }
        });
        console.log('$CRRS: captchaValue: ', this.captchaValue);

        if (!isValidForm) {
            this.showErrorBox = true;
            this.scroll(tag);
            this.isFormSubmitting = false;
            return;
        } else {
            this.showErrorBox = false;
        }

        if (this.template.querySelector('.vin')) {
            let vin = this.template.querySelector('.vin').value;
            if (vin.length == 17) {
                await this.validateVin();
                if (this.vinerror) {
                    this.isFormSubmitting = false;
                    return;
                }
            } else if (vin.length == 0) {
                this.template.querySelector('.vin').setCustomValidity('');
                this.template.querySelector('.vin').reportValidity();
            }
        }

        //FILE CHECK
        console.log('$CRRS: Checkpoint file check 1');
        console.log('$CRRS: this.fields.File1.required: ',this.fields.File1.required);
        console.log('$CRRS: this.fields.File2.required: ',this.fields.File2.required);
        console.log('$CRRS: this.fields.File3.required: ',this.fields.File3.required);
        console.log('$CRRS: this.fields.File4.required: ',this.fields.File4.required);
        console.log('$CRRS: this.fields.File1.data: ',this.fields.File1.data ? JSON.parse(JSON.stringify(this.fields.File1.data)) : this.fields.File1.data);
        console.log('$CRRS: this.fields.File2.data: ',this.fields.File2.data ? JSON.parse(JSON.stringify(this.fields.File2.data)) : this.fields.File2.data);
        console.log('$CRRS: this.fields.File3.data: ',this.fields.File3.data ? JSON.parse(JSON.stringify(this.fields.File3.data)) : this.fields.File3.data);
        console.log('$CRRS: this.fields.File4.data: ',this.fields.File4.data ? JSON.parse(JSON.stringify(this.fields.File4.data)) : this.fields.File4.data);
        let file_data = [];
        if(this.fields.File1.data){
            file_data.push(JSON.parse(JSON.stringify(this.fields.File1.data)));
        }
        if(this.fields.File2.data){
            file_data.push(JSON.parse(JSON.stringify(this.fields.File2.data)));
        }
        if(this.fields.File3.data){
            file_data.push(JSON.parse(JSON.stringify(this.fields.File3.data)));
        }
        if(this.fields.File4.data){
            file_data.push(JSON.parse(JSON.stringify(this.fields.File4.data)));
        }
        console.log('$CRRS: file_data: ',JSON.parse(JSON.stringify(file_data)));
        let file_cls = 'File';
        if(this.fields.File1.required && !this.fields.File1.data){
            this.fields.File1.showRequiredLabel = true;
            this.hideSpinner = true;
            isValidForm = false;
            this.isFormSubmitting = false;
            file_cls = '.File1';
        }
        if(this.fields.File2.required && !this.fields.File2.data){
            this.fields.File2.showRequiredLabel = true;
            this.hideSpinner = true;
            isValidForm = false;
            this.isFormSubmitting = false;
            if(file_cls == 'File')
                file_cls = '.File2';
        }
        if(this.fields.File3.required && !this.fields.File3.data){
            this.fields.File3.showRequiredLabel = true;
            this.hideSpinner = true;
            isValidForm = false;
            this.isFormSubmitting = false;
            if(file_cls == 'File')
                file_cls = '.File3';
        }
        if(this.fields.File4.required && !this.fields.File4.data){
            this.fields.File4.showRequiredLabel = true;
            this.hideSpinner = true;
            isValidForm = false;
            this.isFormSubmitting = false;
            if(file_cls == 'File')
                file_cls = '.File4';
        }
        if (!isValidForm && file_cls != 'File') {
            this.showErrorBox = true;
            this.errorBoxLabel = 'Error: Please upload the below files and resubmit.';
            this.isFormSubmitting = false;
            this.scroll(this.template.querySelector(file_cls));
            let child = this.template.querySelector('c-own-send-an-email-form-file'+file_cls);
            setTimeout( () => {
                child.showErrorText(1000);
            }, 500);
            return;
        } else {
            this.showErrorBox = false;
            this.errorBoxLabel = 'Error: Please complete the fields below and resubmit.';
        }
        //FILE CHECK


        if (this.isguest && !this.captchaValue && isValidForm) {
            this.showErrorBox = true;
            this.errorBoxLabel = 'Error: Please verify the Captcha';
            await new Promise(resolve => setTimeout(resolve, 100));
            let element = this.template.querySelector('.error-div');
            this.scroll(element);
            this.isFormSubmitting = false;
            return;
        } else {
            this.errorBoxLabel = 'Error: Please complete the fields below and resubmit.';
        }

        //Create Case- STARTS
        let Case__x = {};
        this.template.querySelectorAll('.validation').forEach(element => {
            let api_name = element.dataset.apiname;
            let stored_value = element.value;
            //if(api_name != 'Description__c')
            Case__x[api_name] = stored_value ?? '';
            createConsoles('$CRRS: ', api_name + ' - ', stored_value);
        });
        console.log('$CRRS: Case__x: ', Case__x);

        if (Case__x.Miles_c__c) {
            Case__x.Miles_c__c = parseFloat(Case__x.Miles_c__c);
        }
        
        // apiName: this.isPE ? 'WebToCase_Marine_do_you_need_help_with_c__c' : this.isMarine ? 'WebToCase_Marine_do_you_need_help_with_c__c' : 'Sub_topic_c__c',
        // apiName: this.isPE ? 'WebToCase_Power_Equip_Product_Line_c__c' : this.isMarine ? 'WebToCase_Marine_What_Engine_Size_c__c' : 'Topic_c__c',

        if(this.isPE){
            Case__x.Subject__c = Case__x.WebToCase_Power_Equip_Product_Line_c__c + ' ' + Case__x.WebToCase_Marine_do_you_need_help_with_c__c;
        }else if(this.isMarine){
            Case__x.Subject__c = Case__x.WebToCase_Marine_What_Engine_Size_c__c + ' ' + Case__x.WebToCase_Marine_do_you_need_help_with_c__c;
        }else{
            Case__x.Subject__c = Case__x.Topic_c__c + ' ' + Case__x.Sub_topic_c__c;
        }
        

        
        Case__x.WebtoCase_Make_c__c = this.brandName == 'Powerequipment' ? 'Power Equipment' : this.brandName == 'Powersports' ? 'Motorcycle' : this.brandName;

        Case__x.Preferred_Method_to_Receive_Response_c__c = 'Email';

        if(this.user_federationid){
            Case__x.CustomerId_c__c = this.user_federationid;
        }

        if(this.template.querySelector('.radio')){
            let dealership = this.template.querySelector('input[type="radio"]:checked').dataset.label == 'Yes';
            console.log('$CRRS: dealership: ',dealership);
            Case__x.W2C_IsYourProductCurrentlyAtThisDealer_c__c = dealership;
        }

        /* file_data = [{
            "file": {
                "name": "sample-pdf-download-10-mb.pdf",
                "contentVersionId": "0680100000281DfAAI",
                "contentBodyId": "05T010000063BIPEA2",
                "mimeType": "application/pdf"
            },
            "label": "File",
            "required": false
        }]; */

        console.log('$CRRS: Case__x: ', Case__x);
        createCase({webToCase: Case__x, fileData_json : file_data.length ? JSON.stringify(file_data) : ''}).then((caseRec) => {
            console.log('$CRRS: createCase-caseRec: ', caseRec);

            getCaseById({caseId: caseRec.Id}).then((result) => {
                console.log('$CRRS: getCaseById-result: ',result);
                
                let query = 'Select Id, ';
                let insert_case = 'Database.insertImmediate(new Case__x(\n\t\t';
                let cs = JSON.parse(JSON.stringify(result));
                Object.keys(cs).forEach(val => {
                    console.log('$val: ',val);
                    if(val != 'Id')
                        query += val + ', ';
                    
                    if(val != 'Id' && Case__x[val]){
                        let v = typeof Case__x[val] == 'string' ? '\'' + Case__x[val] + '\'' : Case__x[val];
                        insert_case += val + ' = ' + v + ',\n\t\t';
                    }
                });
                insert_case += '\n));';
                insert_case = insert_case.slice(0, insert_case.lastIndexOf(",")) + insert_case.slice(insert_case.lastIndexOf(",") + 1);
                console.log('$CRRS: insert_case: \n',insert_case);
                query = query.slice(0, -2) + ' ';
                query += 'From Case__x Where Id = \'' + result.Id + '\'';
                createConsoles('$CRRS: ', 'Query: ', query);


                this.caseNumber = result.CaseNumber__c;

                this.caseDetails.forEach(val => {
                    if(val.Field == 'Topic'){
                        if(this.isPE){
                            val.Value = result.WebToCase_Power_Equip_Product_Line_c__c;
                        }else if(this.isMarine){
                            val.Value = result.WebToCase_Marine_What_Engine_Size_c__c;
                        }else{
                            val.Value = result.Topic_c__c;
                        }
                    }else if(val.Field == 'Sub Topic'){
                        if(this.isPE){
                            val.Value = result.WebToCase_Marine_do_you_need_help_with_c__c;
                        }else if(this.isMarine){
                            val.Value = result.WebToCase_Marine_do_you_need_help_with_c__c;
                        }else{
                            val.Value = result.Sub_topic_c__c;
                        }
                    }else if(val.Field == 'First Name' && result.First_Name_c__c){
                        val.Value = result.First_Name_c__c;
                    }else if(val.Field == 'Last Name' && result.Last_Name_c__c){
                        val.Value = result.Last_Name_c__c;
                    }else if(val.Field == 'Email Address' && result.SuppliedEmail__c){
                        val.Value = result.SuppliedEmail__c;
                    }else if(val.Field == 'Zip Code' && result.WebToCase_Zipcode_c__c){
                        val.Value = result.WebToCase_Zipcode_c__c;
                    }else if(val.Field == 'Phone' && result.SuppliedPhone__c){
                        val.Value = result.SuppliedPhone__c;
                    }else if(val.Field == 'VIN' && result.VIN_Text_c__c){
                        val.Value = result.VIN_Text_c__c;
                    }else if(val.Field == 'Mileage' && result.Miles_c__c){
                        val.Value = result.Miles_c__c;
                    }else if(val.Field == 'Description' && result.Description__c){
                        val.Value = result.Description__c;
                    }

                    if((val.Field == 'Mileage' || val.Field == 'Description') && (this.isMarine || this.isPE)){
                        val.Show = false;
                    }

                    if(val.Field == 'VIN' && (this.isMarine || this.isPE)){
                        val.Field = 'Serial Number';
                    }
                });

                console.log('$Name-caseDetails: ',JSON.parse(JSON.stringify(this.caseDetails)));

                this.isCaseSubmissionSuccess = true;

                this.isCaseSubmissionSuccess = true;
                this.isFormSubmitting = false;
                
            }).catch((error) => {
                console.error('$CRRS: getCase-error: ',error);
                this.hideSpinner = true;
                this.isFormSubmitting = false;
                const event = new ShowToastEvent({
                    title : error.body.exceptionType,
                    variant : 'error',
                    message : error.body.message
                });
                this.dispatchEvent(event);
            });
        }).catch((error) => {
            console.error('$CRRS: createCase-error: ', error);
            this.isFormSubmitting = false;
            const event = new ShowToastEvent({
                title : error.body.exceptionType,
                variant : 'error',
                message : error.body.message
            });
            this.dispatchEvent(event);
        });
    }
    @track caseNumber = '-';
    @track caseDetails = [
        {
            Field: 'Topic',
            Value: '-',
            Show: true
        },
        {
            Field: 'Sub Topic',
            Value: '-',
            Show: true
        },
        {
            Field: 'First Name',
            Value: '-',
            Show: true
        },
        {
            Field: 'Last Name',
            Value: '-',
            Show: true
        },
        {
            Field: 'Email Address',
            Value: '-',
            Show: true
        },
        {
            Field: 'Zip Code',
            Value: '-',
            Show: true
        },
        {
            Field: 'Phone',
            Value: '-',
            Show: true
        },
        {
            Field: 'VIN',
            Value: '-',
            Show: true
        },
        {
            Field: 'Mileage',
            Value: '-',
            Show: true
        },
        {
            Field: 'Description',
            Value: '-',
            Show: true
        }
    ];

    get division_id() {
        return this.isAcura ? 'B' : this.isHonda ? 'A' : 'M';
    }
    get division_name() {
        return this.isAcura ? 'Acura' : this.isHonda ? 'Honda' : 'Powersports';
    }

    async validateVin() {
        let vin = this.template.querySelector('.vin').value;
        console.log('$CRRS: vin: ', vin);
        console.log('$CRRS: division_id: ', this.division_id);
        console.log('$CRRS: division_name: ', this.division_name);
        if (vin.length != 17) {
            console.log('$CRRS: invalid vin');
            return;
        }
        if (vin) {
            await getProductByVIN({ divisionId: this.division_id, vin: vin, divisionName: this.division_name }).then(result => {
                let prod = JSON.parse(result);
                console.log('$CRRS: getProductByVIN - prod: ', prod);
                if (!prod.isError) {
                    this.vinerror = false;
                } else {
                    this.vinerror = true;
                }
            }).catch(error => {
                this.vinerror = true;
                console.error('$CRRS: error: getProductByVIN ', error);
            });
            console.log('$CRRS: vinerror: ', this.vinerror);
            if (this.vinerror) {
                this.showErrorBox = true;
                this.errorBoxLabel = 'Please enter a valid VIN';
                this.template.querySelector('.vin').setCustomValidity('Please enter a valid VIN');
                this.template.querySelector('.vin').reportValidity();
                this.scroll(this.template.querySelector('.vin'));
            } else {
                this.showErrorBox = false;
                this.errorBoxLabel = 'Error: Please complete the fields below and resubmit.';
                this.template.querySelector('.vin').setCustomValidity('');
                this.template.querySelector('.vin').reportValidity();
            }
        }
    }
    scroll(element) {
        element.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
    }

    get states_code() {
        return { "alabama": "AL", "alaska": "AK", "american samoa": "AS", "arizona": "AZ", "arkansas": "AR", "california": "CA", "colorado": "CO", "connecticut": "CT", "delaware": "DE", "district of columbia": "DC", "federated states of micronesia": "FM", "florida": "FL", "georgia": "GA", "guam": "GU", "hawaii": "HI", "idaho": "ID", "illinois": "IL", "indiana": "IN", "iowa": "IA", "kansas": "KS", "kentucky": "KY", "louisiana": "LA", "maine": "ME", "marshall islands": "MH", "maryland": "MD", "massachusetts": "MA", "michigan": "MI", "minnesota": "MN", "mississippi": "MS", "missouri": "MO", "montana": "MT", "nebraska": "NE", "nevada": "NV", "new hampshire": "NH", "new jersey": "NJ", "new mexico": "NM", "new york": "NY", "north carolina": "NC", "north dakota": "ND", "northern mariana islands": "MP", "ohio": "OH", "oklahoma": "OK", "oregon": "OR", "palau": "PW", "pennsylvania": "PA", "puerto rico": "PR", "rhode island": "RI", "south carolina": "SC", "south dakota": "SD", "tennessee": "TN", "texas": "TX", "utah": "UT", "vermont": "VT", "virgin islands": "VI", "virginia": "VA", "washington": "WA", "west virginia": "WV", "wisconsin": "WI", "wyoming": "WY" }
    }

    renderedCallback(){
        // let auto_populate = true;
        let auto_populate = false;
        if(this.isAcura){
            if((this.selected_topic == 'Accident/Injury' || this.selected_topic == 'Recalls/Campaigns') && auto_populate){
                setTimeout(() => {
                    if(this.template.querySelector('.phone'))
                        this.template.querySelector('.phone').value = '9856857485';
                    if(this.template.querySelector('.mileage'))
                        this.template.querySelector('.mileage').value = '233';
                    if(this.template.querySelector('.description'))
                        this.template.querySelector('.description').value = 'Description.';
                    if(this.template.querySelector('.street'))
                        this.template.querySelector('.street').value = 'Street test';
                    if(this.template.querySelector('.city'))
                        this.template.querySelector('.city').value = 'Test City';
                    this.formInputs.Vin = '19VDE1F78FE001628';
                    this.formInputs.PostalCode = '12345';
                    this.formInputs.FirstName = 'Imtiyaz';
                    this.formInputs.LastName = 'Ansari';
                    this.formInputs.Email = 'imtiyazimi999@gmail.com';
                    this.formInputs.State = 'CA';
                    this.selected_subtopic = 'All Questions';
                }, 100);
            }
        }

        if(this.template.querySelector('.case-detail-container')){
            window.scrollTo(0, 0);
        }
    }
    handleOnfileupload(event){
        let file = JSON.parse(JSON.stringify(event.detail));
        console.log('$CRRS: handleOnfileupload: ', file);
        if(file.label == 'File' || file.label == 'Claim Form'){
            this.fields.File1.data = {...file};
            this.fields.File1.showRequiredLabel = false;
        }else if(file.label == 'Repair Order'){
            this.fields.File2.data = {...file};
            this.fields.File2.showRequiredLabel = false;
        }else if(file.label == 'Proof of Payment'){
            this.fields.File3.data = {...file};
            this.fields.File3.showRequiredLabel = false;
        }else if(file.label == 'Additional Supporting Documents'){
            this.fields.File4.data = {...file};
            this.fields.File4.showRequiredLabel = false;
        }
    }
}
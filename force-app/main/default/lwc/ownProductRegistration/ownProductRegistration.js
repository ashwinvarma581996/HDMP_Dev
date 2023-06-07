import { api, track, wire, LightningElement } from 'lwc';
import { OwnBaseElement } from 'c/ownBaseElement';
import { getOrigin, getGarageURL, ISGUEST, getContext } from 'c/ownDataUtils';
import img from '@salesforce/resourceUrl/Owners';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { createRecord, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import userFirstName from '@salesforce/schema/User.FirstName';
import userLastName from '@salesforce/schema/User.LastName';
import userEmail from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.Contact.AccountId';
import STREET_FIELD from '@salesforce/schema/Account.PersonMailingStreet';
import CITY_FIELD from '@salesforce/schema/Account.PersonMailingCity';
import STATE_FIELD from '@salesforce/schema/Account.PersonMailingState';
import ZIP_CODE_FIELD from '@salesforce/schema/Account.PersonMailingPostalCode';
import productRegistrationObj from '@salesforce/schema/PE_Product_Registration__c';
import productUseField from '@salesforce/schema/PE_Product_Registration__c.Product_Use_Code__c'
import purchasedViaField from '@salesforce/schema/PE_Product_Registration__c.Purchased_Via_Code__c';
// hullMatrial from '@salesforce/schema/PE_Product_Registration__c.Purchased_Via__c';
import getStates from '@salesforce/apex/ownProductSettingsController.getStates';
import createRegistrationRecord from '@salesforce/apex/OwnUserController.createRegistrationRecord'
import verifyCaptcha from '@salesforce/apex/ownRecaptchaController.verifyCaptcha';


export default class ownProductRegistration extends OwnBaseElement {

    //@track submitButtonClass = FIND_BRAND_BUTTON_DISABLED;
    @api saveToMyGarageContentId;
    @track fromProductChooser = false;
    @track productDetails;
    @track context;
    @track isguest = ISGUEST;
    @track division;
    contextSerialNumber = 'SERI-1548375';
    @track prefixMana = ''
    @track serialNumber = '';
    @track isMarine = false;
    @track displayPeRegistration = false;
    @track displayRegistrationForm = false;
    @track displayConfirmationPage = false;
    saveicon = img + '/Icons/save-icon.svg';
    @track captchaValue;
    //DOE-2408 - VARIABLE DECLARATION
    @track title = "";
    @track firstName = "";
    @track initial = "";
    @track lastName = "";
    @track suffix = "";
    @track addressLine1 = "";
    @track addressLine2 = "";
    @track city = "";
    @track state = "";
    @track zip = "";
    @track email = "";
    @track confirmEmail = "";
    @track phone = "";
    @track datePurchased = "";
    @track displayDate = "";
    @track productUsed = "";
    @track AccountId;
    @track productUsedList = [{ label: "Residential", value: "H" }, { label: "Commercial", value: "P" }, { label: "Rental", value: "R" }];
    @track locationPurchased = "";
    @track purchasedViaList = [{ label: "In-store Sales", value: "S" }, { label: "Online / Internet Sales", value: "I" }];
    @track hullMaterials = [{ label: "Aluminum", value: "Aluminum" }, { label: "Inflatable", value: "Inflatable" }, { label: "Dingies", value: "Dingies" }, { label: "Sailboats", value: "Sailboats" }, { label: "Pontoon", value: "Pontoon" }, { label: "Fiberglass", value: "Fiberglass" }, { label: "OffShore", value: "OffShore" }, { label: "Inshore", value: "Inshore" }, { label: "Commercial", value: "Commercial" }, { label: "Other", value: "Other" }];
    @track purchasedVia = "";
    @track hullMaterial = "";
    @track info = {};
    @track states;
    @track displayError = false;
    @track productFieldOptions = {};
    @track purchaseFieldOptions = {};
    @track verifiedBool;
    @track captchaResponse;
    @track serialNumberUrl;
    @track hullID;
    @track hullMaterial;
    @track boatYear;
    @track boatMake;
    @track boatModel;
    @track marineOrPE = false;

    @track returnValue = false;
    error;

    @track congratulationsText;
    addProduct = false;


    @wire(getRecord, { recordId: Id, fields: [userFirstName, userLastName, userEmail, ACCOUNT_ID] })
    userDetails({
        error,
        data
    }) {
        if (data) {
            //console.log('User Detail Data ', data);
            this.firstName = data.fields.FirstName.value;
            this.info['First_Name__c'] = this.firstName;
            this.lastName = data.fields.LastName.value;
            this.info['Last_Name__c'] = this.lastName;
            this.email = data.fields.Email.value;
            if (this.email) {
                this.confirmEmail = this.email;
                this.info['Email__c'] = this.email;
            }
            this.AccountId = data.fields.Contact.value.fields.AccountId.value;
            //console.log(this.AccountId);

        } else if (error) {
            this.error = error;
        }
    }

    @wire(getRecord, { recordId: '$AccountId', fields: [STREET_FIELD, CITY_FIELD, STATE_FIELD, ZIP_CODE_FIELD] })
    userAccountDetails({
        error,
        data
    }) {
        if (data) {
            let stateHolder = '';

            //console.log('User Account Data ', data);
            this.addressLine1 = data.fields.PersonMailingStreet.value ? data.fields.PersonMailingStreet.value : '';
            //console.log('AddressLine1, ', this.addressLine1);
            this.info['Address_Line_1__c'] = this.addressLine1;

            this.city = data.fields.PersonMailingCity.value ? data.fields.PersonMailingCity.value : '';
            //console.log('City, ', this.city);
            this.info['City__c'] = this.city;

            this.stateHolder = data.fields.PersonMailingState.value ? data.fields.PersonMailingState.value : '';

            this.state = this.stateHolder ? this.abbrState(this.stateHolder) : '';
            //console.log('State, ', this.state);
            this.info['State__c'] = this.state;

            this.zip = data.fields.PersonMailingPostalCode.value ? data.fields.PersonMailingPostalCode.value : '';
            //console.log('Zip, ', this.zip);
            this.info['Zip__c'] = this.zip;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getObjectInfo, {
        objectApiName: productRegistrationObj
    })
    Object_productRegistration;

    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeObj',
        fieldApiName: productUseField
    })
    productUsedOptions;

    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeObj',
        fieldApiName: purchasedViaField
    })
    purchaseViaOptions;


    handleKeyUpPERegistration(event) {
        //console.log('Up event :', JSON.stringify(event.detail), '--', event.target.value, '--', event.target.name, '--', event.target.type);
        let fieldName = event.target.getAttribute('data-id');
        let enteredValue = event.target.value;

        if (fieldName === 'prefixMana') {
            this.prefixMana = enteredValue;

        } else if (fieldName === 'peNumber') {
            this.serialNumber = enteredValue;

        }

    }

    get submitButtonClassPERegistration() {
        if (this.prefixMana !== '' && this.serialNumber !== '' && this.serialNumber.length === 7) {
            return 'slds-button slds-button_brand slds-combobox_container form-button_submit';
        } else {
            //return 'slds-button slds-button_brand slds-combobox_container form-button_submit disabled'
            return 'slds-button slds-button_brand slds-combobox_container form-button_submit';
        }
    }

    handleNextPE() {
        if (this.prefixMana !== '' && this.serialNumber !== '' && this.serialNumber.length === 7 /* && this.marineOrPE = true */) {
            this.displayPeRegistration = false;
            this.displayRegistrationForm = true;
            this.displayConfirmationPage = false;
        }
        sessionStorage.removeItem('vinHelpBreadcrumb');

    }

    handleCancelClick() {
        let pagename = getGarageURL(this.division);
        //sessionStorage.setItem('isRegistrationRedirect', true);

        // Alexander Dzhitenov (Wipro): DOE-5335
        //this.navigate(pagename, {});
        window.open('.' + pagename, '_self');
    }

    handleAdd() {
        let garageProducts = JSON.parse(localStorage.getItem('garage'));
        const product = garageProducts.products[0];

        //console.log(product.vin);
        if (this.isguest) {
            sessionStorage.setItem('originAddProduct', product.division);
            this.navigate('/login', {});
        }
    }

    connectedCallback() {
        this.initializeStates();
        this.initialize();

    }

    initializeStates() {
        getStates().then(result => {
            this.states = result;
        }).catch(error => {
            //console.log(error);
        });
    }

    initialize = async () => {
        const context = localStorage.getItem('context') ? JSON.parse(localStorage.getItem('context')) : {};
        if (!context || getOrigin() != 'ProductChooser') {
            this.context = await getContext('');
        } else {
            this.context = context;
        }
        //console.log('Context Product Reg, ', JSON.stringify(this.context));
        this.fromProductChooser = getOrigin() === 'ProductChooser' && !this.isguest ? true : false;


        this.addProduct = sessionStorage.getItem('addingPEMProduct');
        //console.log('addProduct? ', this.addProduct);

        this.displaySavedDetails = !this.fromProductChooser && !this.isguest && !this.addProduct ? true : false;
        sessionStorage.removeItem('addingPEMProduct');

        if (this.displaySavedDetails) {
            this.displayPeRegistration = false;
            this.displayRegistrationForm = true;
            this.displayConfirmationPage = false;
        }
        else {
            this.displayPeRegistration = true;
            this.displayRegistrationForm = false;
            this.displayConfirmationPage = false;
        }
        // always filling with searched products for later use.


        let garageProducts = JSON.parse(localStorage.getItem('garage'));
        this.productDetails = this.fromProductChooser ? garageProducts.products[0] : 'undefined';
        this.division = this.productDetails != 'undefined' ? this.productDetails.division : this.context.product.division;
        //this.marineOrPE = (this.division === 'Marine' || this.division == 'Power Equipment') ? true : false;
        this.isMarine = this.division === 'Marine' ? true : false;

        this.contextSerialNumber = this.context.product.vin;
        this.congratulationsText = this.isguest ? 'Congratulations on the purchase of your new Honda Product!' : 'Congratulations on adding your ' + this.context.product.model + ' to Your Garage!';


        /* this.prefixMana = this.contextSerialNumber.slice(0,4);
        this.serialNumber = this.contextSerialNumber.slice(5); */
        const splitArray = this.contextSerialNumber.split('-');

        this.prefixMana = splitArray[0];
        this.serialNumber = splitArray[1];

        //console.log('Serial Number Split', this.prefixMana + ' - ' + this.serialNumber);
        sessionStorage.setItem('vinHelpBreadcrumb', 'productRegistration');
        this.serialNumberUrl = this.isMarine ? '/marine-serial-number-help' : '/power-equipment-serial-number-locator';
        this.info['Serial_Number_VIN__c'] = this.contextSerialNumber;
        if(this.isMarine == true){
            this.info['Legacy_Subdivision_Code__c'] = 'C';
        }else{
            this.info['Legacy_Subdivision_Code__c'] = 'P';
        }
    }


    get recordTypeObj() {
        if (this.Object_productRegistration.data) {
            return this.Object_productRegistration.data.defaultRecordTypeId;
        }
    }

    get productUse() {
      /*  if (this.isguest) {
            //console.log('productUsedList ', this.productUsedList);
            return this.productUsedList;
        } else*/
            if (this.productUsedOptions.data) {
                this.productUsedOptions.data.values.forEach(element => {
                    this.productFieldOptions[element.label] = element.value;
                });
                let options = this.productUsedOptions.data.values.map(x => {
                    return {
                        label: x.label,
                        value: x.label
                    };
                });
                return options;
            }
    }

    get purchaseVia() {

   /*     if (this.isguest) {
            //console.log('purchasedViaList ', this.purchasedViaList);
            return this.purchasedViaList;
        } else*/
            if (this.purchaseViaOptions.data) {
                this.purchaseViaOptions.data.values.forEach(element => {
                    this.purchaseFieldOptions[element.label] = element.value;
                });
                let options = this.purchaseViaOptions.data.values.map(x => {
                    return {
                        label: x.label,
                        value: x.label
                    };
                });
                return options;
            }
    }

    get submitButtonClass() {
        if (/*this.requiredFieldsValid()*/ this.returnValue) {
            return 'slds-button slds-button_brand slds-combobox_container form-button_submit'
        } else {
            return 'slds-button slds-button_brand slds-combobox_container form-button_submit disabled'
        }
    }

    get emailDisabled() {
        if (this.isguest) {
            return false;
        } else {
            return true;
        }
    }

    handleFindMySerialNumber() {
        let backLink = {
            label: 'Product Registration',
            url: '/product-registration'
        };
        sessionStorage.setItem('backlink', JSON.stringify(backLink));
        if(this.serialNumberUrl == '/power-equipment-serial-number-locator'){
            window.open('https://powerequipment.honda.com/support/serial-number-locator','_blank');
        }else{
            this.navigate(this.serialNumberUrl, {})
        }
    }

    requiredFieldsValid() {
        this.returnValue = false;

        const isInputsCorrect = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        ////console.log('is Inputs Correct?, ', isInputsCorrect);


        if (this.firstName !== '' &&
            this.lastName !== '' &&
            this.addressLine1 !== '' &&
            this.city !== '' &&
            this.state !== '' &&
            (this.zip !== '' && (this.zip.length == 5 || (this.zip.length == 10 && this.zip.charAt(5) == '-'))) &&
            this.email !== '' &&
            this.confirmEmail !== '' && this.confirmEmail == this.email &&
            this.datePurchased !== '' && this.datePurchased &&
            this.productUsed !== '' &&
            this.phone !== '' &&
            this.locationPurchased !== '' &&
            this.purchasedVia !== '' &&
            isInputsCorrect) {
            //returnValue = this.isMarine ? this.captchaValue : true ;
            this.returnValue = this.isguest ? this.captchaValue : true;
            //returnValue = true;
        }
        //return returnValue;
    }

    handleBlur(event) {
        let fieldName = event.target.getAttribute('data-id');
        if (fieldName === 'Email__c' || fieldName === 'confirmEmail') {
            if (this.email !== '' && this.email !== undefined && this.confirmEmail !== '' && this.confirmEmail !== undefined) {
                if (this.email === this.confirmEmail) {
                    this.displayError = false;
                } else {
                    //this.displayError = true;
                    this.confirmEmail = '';
                    this.showMessage('Error', 'Re-entered email does not match', 'error');
                }
            }
        }

        this.requiredFieldsValid();

    }

    handleKeyUp(event) {
        //let fieldName = event.target.name;
        let fieldName = event.target.getAttribute('data-id');
        let enteredValue = event.target.value;
        //let fieldApiName;
        if (fieldName === 'Title__c') {
            this.title = enteredValue;
            //fieldApiName = 'Title__c';
        } else if (fieldName === 'First_Name__c') {
            this.firstName = enteredValue;
        } else if (fieldName === 'Middle_Initial__c') {
            this.initial = enteredValue;
        } else if (fieldName === 'Last_Name__c') {
            this.lastName = enteredValue;
        } else if (fieldName === 'Suffix__c') {
            this.suffix = enteredValue;
        } else if (fieldName === 'Address_Line_1__c') {
            this.addressLine1 = enteredValue;
        } else if (fieldName === 'Address_Line_2__c') {
            this.addressLine2 = enteredValue;
        } else if (fieldName === 'City__c') {
            this.city = enteredValue;
        } else if (fieldName === 'Zip__c') {
            this.zip = enteredValue;
        } else if (fieldName === 'Email__c') {
            this.email = enteredValue;
        } else if (fieldName === 'confirmEmail') {
            this.confirmEmail = enteredValue;
        } else if (fieldName === 'Phone__c') {
            this.phone = enteredValue;
        } else if (fieldName === 'Location_Purchased__c') {
            this.locationPurchased = enteredValue;
        } else if (fieldName === 'Hull_ID__c') {
            this.hullID = enteredValue;
        } else if (fieldName === 'Boat_Year__c') {
            this.boatYear = enteredValue;
        } else if (fieldName === 'Boat_Make__c') {
            this.boatMake = enteredValue;
        } else if (fieldName === 'Boat_Model__c') {
            this.boatModel = enteredValue;
        }


        if (fieldName !== undefined && fieldName !== '') {
            //this.createObjectForInsert(fieldApiName, enteredValue);
            this.info[fieldName] = enteredValue;
        }

        this.requiredFieldsValid();
    }

    handleChange(event) {
        //console.log('change event :', JSON.stringify(event.detail), '--', event.target.value, '--', event.target.name, '--', event.target.label);
        let fieldName = event.target.getAttribute('data-id');
        let selectedValue = event.target.value;
        let selectedValue1;

        if (fieldName === 'State__c') {
            this.state = selectedValue;
        } else if (fieldName === 'Date_Purchased__c') {
            this.datePurchased = selectedValue;
            this.formatDate();

        } else if (fieldName === 'Product_Use_Code__c') {
            this.productUsed = selectedValue;
            //selectedValue1 = this.productUsed;

            selectedValue1 = this.productFieldOptions[selectedValue];

            //console.log('selectedValue1', selectedValue1);
        } else if (fieldName === 'Purchased_Via_Code__c') {
            this.purchasedVia = selectedValue;
            //selectedValue1 = this.purchaseVia;

            selectedValue1 = this.purchaseFieldOptions[selectedValue];

            //console.log('selectedValue1', selectedValue1);
        } else if (fieldName === 'Hull_Material__c') {
            this.hullMaterial = selectedValue;
        }
        //console.log('@@Product_Use_Code__c'+selectedValue1);
        if (fieldName !== undefined && fieldName !== '' && (fieldName === 'Product_Use_Code__c' || fieldName === 'Purchased_Via_Code__c')) {
            this.info[fieldName] = selectedValue1;
        } else if (fieldName !== undefined && fieldName !== '') {
            //console.log('Object Creation onCHange');
            this.info[fieldName] = selectedValue;
        }

        this.requiredFieldsValid();

    }

    createObjectForInsert(fieldName, fieldValue) {
        this.info["field"] = fieldName;
        this.info["value"] = fieldValue;
        //console.log('Info object :', JSON.stringify(this.info));
    }

    handleSubmit() {
        //console.log('This info at submit, ', JSON.stringify(this.info));
        if (this.returnValue) {
            delete this.info["confirmEmail"];
            let recordInput = {
                apiName: productRegistrationObj.objectApiName,
                fields: this.info
            }
            createRegistrationRecord({
                info: this.info
            }).then(result => {
                //console.log('Result: ', result);
                this.displayPeRegistration = false;
                this.displayRegistrationForm = false;
                this.displayConfirmationPage = true;
                window.scrollTo(0, 0);
            }).catch(error => {
                //console.log('Error From Apex', JSON.stringify(error));
            });
            /* createRecord(recordInput).then(objRecord => {
                //console.log('CreateRecord : Success : Record Id: ', objRecord.id);
                this.showMessage('Success', 'Record created successfully', 'success');
            }).catch(error => {
                const errorLog = JSON.parse(JSON.stringify(error));
                //console.log('CreateRecord : Error :', errorLog);
            }) */
        }
    }

    showMessage(title, msg, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: msg,
                variant: variant,
            }),
        );
    }

    handleCaptcha(event) {
        //console.log('Updated value is ' + JSON.stringify(event.detail));
        this.verifiedBool = event.detail.value;

        if (event.detail.response) {
            //console.log('Response is ' + event.detail.response);
            this.captchaResponse = event.detail.response;
        } else {
            this.captchaValue = false;
        }

        verifyCaptcha({ recaptchaResponse: this.captchaResponse })
            .then(result => {
                //console.log('result :: ', result);
                this.captchaValue = result;

                this.requiredFieldsValid();

            }).catch(error => {
                //console.log('result :: ', error);
            });


    }

    formatDate() {
        console
        let dateString = this.datePurchased;
        let formatDate = new Date(dateString);
        let fdDay = formatDate.getUTCDate();
        fdDay = (fdDay < 10) ? fdDay = '0' + fdDay : fdDay;
        let fdMonth = formatDate.getUTCMonth();
        fdMonth = fdMonth + 1;
        if (fdMonth == 0) {
            fdMonth = fdMonth + 1;
        }
        fdMonth = (fdMonth < 10) ? fdMonth = '0' + fdMonth : fdMonth;
        let fdYear = formatDate.getUTCFullYear();
        this.displayDate = fdMonth + '/' + fdDay + '/' + fdYear;
        //console.log('datePurchased Formatted', this.datePurchased);
    }

    abbrState(input) {
        var states = [
            ['Arizona', 'AZ'],
            ['Alabama', 'AL'],
            ['Alaska', 'AK'],
            ['Arkansas', 'AR'],
            ['California', 'CA'],
            ['Colorado', 'CO'],
            ['Connecticut', 'CT'],
            ['Delaware', 'DE'],
            ['Florida', 'FL'],
            ['Georgia', 'GA'],
            ['Hawaii', 'HI'],
            ['Idaho', 'ID'],
            ['Illinois', 'IL'],
            ['Indiana', 'IN'],
            ['Iowa', 'IA'],
            ['Kansas', 'KS'],
            ['Kentucky', 'KY'],
            ['Louisiana', 'LA'],
            ['Maine', 'ME'],
            ['Maryland', 'MD'],
            ['Massachusetts', 'MA'],
            ['Michigan', 'MI'],
            ['Minnesota', 'MN'],
            ['Mississippi', 'MS'],
            ['Missouri', 'MO'],
            ['Montana', 'MT'],
            ['Nebraska', 'NE'],
            ['Nevada', 'NV'],
            ['New Hampshire', 'NH'],
            ['New Jersey', 'NJ'],
            ['New Mexico', 'NM'],
            ['New York', 'NY'],
            ['North Carolina', 'NC'],
            ['North Dakota', 'ND'],
            ['Ohio', 'OH'],
            ['Oklahoma', 'OK'],
            ['Oregon', 'OR'],
            ['Pennsylvania', 'PA'],
            ['Rhode Island', 'RI'],
            ['South Carolina', 'SC'],
            ['South Dakota', 'SD'],
            ['Tennessee', 'TN'],
            ['Texas', 'TX'],
            ['Utah', 'UT'],
            ['Vermont', 'VT'],
            ['Virginia', 'VA'],
            ['Washington', 'WA'],
            ['West Virginia', 'WV'],
            ['Wisconsin', 'WI'],
            ['Wyoming', 'WY'],
        ];
        input = input.replace(/\w\S*/g, function (txt) { return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase(); });
        for (let i = 0; i < states.length; i++) {
            if (states[i][0] == input) {
                return (states[i][1]);
            }
        }
    }

}
import { api, track, wire, LightningElement } from 'lwc';
import getStates from '@salesforce/apex/ownProductSettingsController.getStates';
import { OwnBaseElement } from 'c/ownBaseElement';
import { CurrentPageReference } from 'lightning/navigation';
import { getManagedContentByTopicsAndContentKeys, getProductContext, ISGUEST, getContext_fromBrowser } from 'c/ownDataUtils';
import getManualRequest from '@salesforce/apex/OwnRetriveCustomMetaData.getManualRequest';
import createOwnerManualRequestRecord from '@salesforce/apex/OwnManualsApiController.createOwnerManualRequestRecord';
import { createRecord, getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import userFirstName from '@salesforce/schema/User.FirstName';
import userLastName from '@salesforce/schema/User.LastName';
import userEmail from '@salesforce/schema/User.Email';
import ACCOUNT_ID from '@salesforce/schema/User.Contact.AccountId';
import STREET_FIELD from '@salesforce/schema/Account.PersonMailingStreet';
import CITY_FIELD from '@salesforce/schema/Account.PersonMailingCity';
import STATE_FIELD from '@salesforce/schema/Account.PersonMailingState';
import ZIP_CODE_FIELD from '@salesforce/schema/Account.PersonMailingPostalCode';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import getProductByVIN from '@salesforce/apex/OwnGarageController.getProductByVIN';
import verifyCaptcha from '@salesforce/apex/ownRecaptchaController.verifyCaptcha';

export default class OwnManualRequest extends OwnBaseElement {

    firstName = '';
    lastName = '';
    zip = '';
    email = '';
    phone = '';
    vin = '';
    year = '';
    modelName = '';
    addressLine1 = '';
    addressLine2 = '';
    city = '';
    state = '';
    isOwnersManual = false;
    isNavigationManual = false;
    isBraille=false;
    isBothManual = false;
    showOwnersManuals = false;
    showBraille = false;
    errorMessage = '';
    showerror = false;
    isresult = false;
    vinerror = false;
    @track verifiedBool;
    @track captchaResponse;
    @track captchaValue;
    @track info = {};
    @track states;
    @track yearsArray = [];
    @track yearsModelArray = [];
    @track modelsArray = [];
    @track selectedYear = '';
    @track selectedModel = '';
    @track selectedDivisionID = '';
    @track division = '';
    @track modelId = '';
    @track AccountId;
    @track saveToAccount = false;
    @track guestUser = true;
    @track isSuccess = false;
    currentPageReference = null;
    urlStateParameters = null;
    
    fb = null;


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
                //   this.confirmEmail = this.email;
                this.info['Email_Address__c'] = this.email;
            }
            this.AccountId = data.fields.Contact.value.fields.AccountId.value;
            //console.log(this.AccountId);

        } else if (error) {
            this.error = error;
        }
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
        this.fb = this.urlStateParameters.page || null;
    }

    @wire(getRecord, { recordId: '$AccountId', fields: [STREET_FIELD, CITY_FIELD, STATE_FIELD, ZIP_CODE_FIELD, PHONE_FIELD] })
    userAccountDetails({
        error,
        data
    }) {
        if (data) {
            let stateHolder = '';

            //console.log('User Account Data ', data);
            this.addressLine1 = data.fields.PersonMailingStreet.value ? data.fields.PersonMailingStreet.value : '';
            //console.log('AddressLine1, ', this.addressLine1);
            this.info['Street__c'] = this.addressLine1;

            this.city = data.fields.PersonMailingCity.value ? data.fields.PersonMailingCity.value : '';
            //console.log('City, ', this.city);
            this.info['City__c'] = this.city;

            this.stateHolder = data.fields.PersonMailingState.value ? data.fields.PersonMailingState.value : '';
            this.state = this.stateHolder ? this.abbrState(this.stateHolder) : '';
            //console.log('State, ', this.state);
            this.info['State__c'] = this.stateHolder;

            this.zip = data.fields.PersonMailingPostalCode.value ? data.fields.PersonMailingPostalCode.value : '';
            //console.log('Zip, ', this.zip);
            this.info['Postal_Code__c'] = this.zip;
            this.phone = data.fields.Phone.value ? data.fields.Phone.value : '';
            //console.log('phone, ', this.phone);
            this.info['Phone__c'] = this.phone;
        } else if (error) {
            this.error = error;
        }
    }


    connectedCallback() {
        this.isSuccess = false;
        this.guestUser = ISGUEST;
        this.initializeStates();
        this.initialize();

    }

    initializeStates() {

        getStates().then(result => {
            this.states = result;
            //console.log('@@state'+JSON.stringify(this.states ));
        }).catch(error => {
            //console.log(error);
        });
    }

    initialize = async () => {
        this.isresult = false;
        try {
            document.title="Printed Manual Request Form";
            this.isOwnersManual = true;
            let origin = localStorage.getItem('origin');
            if (ISGUEST || origin == 'ProductChooser') {
                this.context = await getProductContext('', true);
            } else {
                this.context = await getProductContext('', false);
            }
            if (this.context) {
                this.info['Product_Division__c'] = this.context.product.divisionId;
                this.selectedYear = this.context.product.year;
                this.year=this.context.product.year;
                this.info['Model_Year__c'] = this.year;
                this.modelsArray = [];
                this.selectedModel = this.context.product.model;
                this.modelName=this.context.product.model;
                this.info['Model_Name__c'] = this.modelName;
                this.selectedDivisionID = this.context.product.divisionId;
                this.division = this.context.product.division;
                this.modelId = this.context.product.modelId;
                this.vin = this.context.product.vin && this.context.product.vin != '-' ? this.context.product.vin : '';
                if(this.vin){
                    this.info['Product_Identifier__c'] = this.vin;
                }
                if (this.selectedYear <= 2021) {
                    this.showOwnersManuals = true;
                    this.info['Book_Type__c'] = 'OM';
                } else {
                    this.isNavigationManual = true;
                    this.isOwnersManual = false;
                    this.info['Book_Type__c'] = 'NM';
                }
                if(this.fb == 'braille'){
                    this.showBraille=true;
                    this.showOwnersManuals = false;
                    this.isNavigationManual = false;
                    this.isOwnersManual = false;
                    this.isBraille=true;
                    this.info['Book_Type__c'] = 'BM';
                }
            }
            //console.log('@@s' + JSON.stringify(this.yearsArray));
            if(this.fb != 'braille'){
            await getManualRequest({ brand: this.division }).then((data) => {
                //console.log('@@r' + JSON.stringify(data));
                data.forEach(arrayIteam => {
                    this.yearsArray = [...this.yearsArray, { label: arrayIteam.Year__c, value: arrayIteam.Year__c }];
                    this.yearsModelArray = [...this.yearsModelArray, { year: arrayIteam.Year__c, model: arrayIteam.Models__c }]
                });
                //console.log('@@s' + JSON.stringify(this.yearsArray));
            }).catch((error) => {
                //console.log('@@Error getting Data', error);
            });
        }
           
            if(this.fb == 'braille'){
                const d = new Date();
                let currentYear = d.getFullYear();
                this.yearsArray = [];
                var incrementYear=2019;
                while(incrementYear <= currentYear){
                    this.yearsArray = [...this.yearsArray, { label: String(currentYear), value: String(currentYear) }];
                    if(currentYear == 2023){
                        this.yearsModelArray = [...this.yearsModelArray, { year: currentYear, model: 'Odyssey' }];
                    }else{
                        this.yearsModelArray = [...this.yearsModelArray, { year: currentYear, model: 'Odyssey;Pilot' }];
                    }
                    currentYear=currentYear-1;
                }
            }

            this.yearsModelArray.forEach(element => {
                if (element.year == this.year && element.model.includes(';')) {
                    element.model.split(';').forEach(ele => {
                        if(ele.includes('::')){
                            let modleAndTrim=ele.split('::');
                            this.modelsArray = [...this.modelsArray, { label: modleAndTrim[0], value: modleAndTrim[0] }];
                        }else{
                        this.modelsArray = [...this.modelsArray, { label: ele, value: ele }];
                        }
                    });
                }else if(element.year == this.year){
                    this.modelsArray = [...this.modelsArray, { label: element.model, value: element.model }];
                }
            });
            this.isresult = true;
        } catch (e) {
            //console.log(e);
            this.isresult = true;
        }
    }


    handleKeyUp(event) {
        let keyField = event.currentTarget.dataset.id;
        let enteredValue = event.target.value;
        if (keyField == "First_Name__c") {
            this.firstName = enteredValue;
        } else if (keyField == "Last_Name__c") {
            this.lastName = enteredValue;
        } else if (keyField == "Product_Identifier__c") {
            this.vin = enteredValue;
        } else if (keyField == "Street__c") {
            this.addressLine1 = enteredValue;
        } else if (keyField == "Street2__c") {
            this.addressLine2 = enteredValue;
        } else if (keyField == "City__c") {
            this.city = enteredValue;
        } else if (keyField == "Postal_Code__c") {
            this.zip = enteredValue;
        } else if (keyField == "Email_Address__c") {
            this.email = enteredValue;
        } else if (keyField == "Phone__c") {
            this.phone = enteredValue;
        }

        this.info[keyField] = enteredValue;
    }

    handleOwnersManual(event) {
        this.isOwnersManual = event.target.checked;
      //  this.isNavigationManual = false;
      if(this.isOwnersManual == true &&  this.isNavigationManual == true){
        this.info['Book_Type__c'] = 'OM,NM';
      }else if(this.isOwnersManual == true){
        this.info['Book_Type__c'] = 'OM';
      }else if(this.isOwnersManual == false && this.isNavigationManual == true){
        this.info['Book_Type__c'] = 'NM';
      }
    }
    handleNavigationManual(event) {
     //   this.isOwnersManual = false;
        this.isNavigationManual = event.target.checked;
        if(this.isOwnersManual == true &&  this.isNavigationManual == true){
            this.info['Book_Type__c'] = 'OM,NM';
          }else if(this.isNavigationManual == true){
            this.info['Book_Type__c'] = 'NM';
          }else if(this.isOwnersManual == true && this.isNavigationManual == false){
            this.info['Book_Type__c'] = 'OM';
          }
    }

    handleBrailleManual(event){
        this.isBraille = event.target.checked;
        this.info['Book_Type__c'] = 'BM';
    }

    handleChange(event) {
        try {
            let keyField = event.currentTarget.dataset.id;
            let enteredValue = event.target.value;
            if (keyField == 'Model_Year__c') {
                this.year = enteredValue;
                this.selectedYear=enteredValue;
                this.modelsArray = [];
                this.yearsModelArray.forEach(element => {
                    if (element.year == enteredValue && element.model.includes(';')) {
                        element.model.split(';').forEach(ele => {
                            this.modelsArray = [...this.modelsArray, { label: ele, value: ele }];
                        });
                    }else if(element.year == this.year){
                        this.modelsArray = [...this.modelsArray, { label: element.model, value: element.model }];
                    }
                });
                if (this.year <= 2021) {
                    this.showOwnersManuals = true;
                    this.isNavigationManual = false;
                    this.isOwnersManual = true;
                    this.info['Book_Type__c'] = 'OM';
                } else {
                    this.showOwnersManuals = false;
                    this.isNavigationManual = true;
                    this.isOwnersManual = false;
                    this.info['Book_Type__c'] = 'NM';
                }
            }

            if (keyField == 'Model_Name__c') {
                this.modelName = enteredValue;
            } else if (keyField == 'State__c') {
                this.state = event.target.value;
                //console.log('@@' + event.target.options.find(opt => opt.value == event.detail.value).label);
                this.info[keyField] = event.target.options.find(opt => opt.value == event.detail.value).label;
            }
            if(keyField != 'State__c'){
                this.info[keyField] = enteredValue;
            }
            if(this.fb == 'braille'){
                this.showBraille=true;
                this.showOwnersManuals = false;
                this.isNavigationManual = false;
                this.isOwnersManual = false;
                this.isBraille=true;
                this.info['Book_Type__c'] = 'BM';
            }
        } catch (e) {
            //console.log('@@exp' + e);
        }
    }

    async handleSubmit() {
        this.errorMessage='';
        this.showerror = false;
      //  this.isresult=false;
        try{
        if (await this.requiredFieldsValid()) {
            //console.log('validation Success' + JSON.stringify(this.info));
            createOwnerManualRequestRecord({
                info: this.info, saveToAccount: this.saveToAccount, AccountId: this.AccountId
            }).then(result => {
                this.isSuccess = true;
                window.scrollTo(0,0);
                //console.log('Data From Apex', JSON.stringify(result));
            }).catch(error => {
                //console.log('Error From Apex', JSON.stringify(error));
            });
        }
     //   this.isresult=true;
    }catch (e) {
        //console.log('@@exp' + e);
    //    this.isresult=true;
    }
    }

    async requiredFieldsValid() {
        try{
        //console.log('@@checkingrequiredFieds');
        this.vinerror = true;
        const isInputsCorrect = [
            ...this.template.querySelectorAll("lightning-input")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        const isDropdownsCorrect = [
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        if (this.firstName != '' &&
            this.lastName != '' &&
            this.vin != '' &&
            this.addressLine1 != '' &&
            this.city != '' &&
            this.zip != '' &&
            this.email != '' &&
            this.phone != '' &&
            this.year != '' && this.modelName != '' && this.state != '' && isInputsCorrect && (!this.guestUser || (this.guestUser &&  this.captchaValue)) 
            && (this.isOwnersManual == true || this.isNavigationManual == true || this.isBraille == true)) {
            //console.log('$CRRS: selectedDivisionID: ',this.selectedDivisionID);
            //console.log('$CRRS: vin: ',this.vin);
            //console.log('$CRRS: division: ',this.division);
            await getProductByVIN({ divisionId: this.selectedDivisionID, vin: this.vin, divisionName: this.division })
                .then(result => {
                    //console.log('@@result Vin', JSON.stringify(result));
                    let prod = JSON.parse(result);
                    if (!prod.isError) {
                        this.vinerror = false;
                    } else {
                        //showToastMessage += '* Incorrect VIN number entered. \n';
                        this.vinerror = true;
                    }
                })
                .catch(error => {
                    this.vinerror = true;
                    //console.log('getProductByVIN: error');
                    //console.log('error: ', error);
                });
        } else {
            this.showerror = true;
            var counter=0;
           if( this.firstName == ''){
            counter=counter+1;
           }
           if( this.lastName == ''){
            counter=counter+1;
           }
           if( this.vin == ''){
            counter=counter+1;
           }
           if( this.addressLine1 == ''){
            counter=counter+1;
           }
           if( this.city == ''){
            counter=counter+1;
           }
           if( this.zip == ''){
            counter=counter+1;
           }
           if( this.email == ''){
            counter=counter+1;
           }
           if( this.phone == ''){
            counter=counter+1;
           }
           if( this.year == ''){
            counter=counter+1;
           }

            if(this.state == ''){
                counter=counter+1;
            }
            if(this.modelName == ''){
                counter=counter+1;
            }
            if(counter == 1){
                this.errorMessage = "* Please complete the mandatory field ";
            }else if (counter > 1){
                this.errorMessage = "* Please complete the mandatory fields ";
            }

            if(this.isNavigationManual == false && this.isOwnersManual == false && this.isBraille == false){
                this.errorMessage += "* Please select at least one manual for your request";
            }
            
            if(this.guestUser){
                if(!this.captchaValue){
                    this.errorMessage += "* Please complete the captcha ";
                }
            }
            return false;
        }
        if (!this.vinerror) {
            return true;
        } else {
            this.showerror = true;
            this.errorMessage = "* Incorrect VIN number entered";
            return false;
        }
    }catch (e) {
        //console.log('@@exp' + e);
    }
        return false;
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

    handleChexboxClick(event) {
        this.saveToAccount = event.target.checked;
        //console.log('Checked' + this.saveToAccount);
    }

    handleGoBack() {
        history.back();
    }

    handleCaptcha(event) {
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
              //  this.requiredFieldsValid();
            }).catch(error => {
                //console.log('result :: ', error);
            });


    }

    handleCancelClick(){
        this.navigate('/owners-manuals', {});
    }
}
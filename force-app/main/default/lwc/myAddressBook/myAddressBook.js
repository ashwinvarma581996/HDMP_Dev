/*******************************************************************************
Name            : myAddressBook
Created By		: SAILAKSHMAN KANUKOLLU
Business Unit   : HDM
Date            : 1/12/2022
Description     : This is my address book component to store customer address.
********************************************************************************
MODIFICATIONS – Date | Dev Name | Method | User Story

********************************************************************************/
import { LightningElement, track, wire } from 'lwc';
import loggedInuserAddressList from '@salesforce/apex/B2B_LoggedInUserAddressCheck.loggedInuserAddressList';
import deleteAddressBook from '@salesforce/apex/B2B_LoggedInUserAddressCheck.deleteAddressBook';
import updateAddressBook from '@salesforce/apex/B2B_LoggedInUserAddressCheck.updateAddressBook';
import createAddressRecord from '@salesforce/apex/B2B_LoggedInUserAddressCheck.createAddressRecord';
import getStateAddressBook from '@salesforce/apex/B2B_LoggedInUserAddressCheck.getStateAddressBook';
import markAsPrefferedDirectly from '@salesforce/apex/B2B_LoggedInUserAddressCheck.markAsPrefferedDirectly';
import getEditAddressInfo from '@salesforce/apex/B2B_LoggedInUserAddressCheck.getEditAddressInfo';
import vertexAddressCleansing from '@salesforce/apex/B2B_VertexTaxCalculationIntegration.vertexAddressCleansing';
import PreferredAddressDeleteMessage from '@salesforce/label/c.PreferredAddressDeleteMessage';
import NonPreferredAddressDeleteMessage from '@salesforce/label/c.NonPreferredAddressDeleteMessage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import CustomerEntered from '@salesforce/label/c.B2B_Customer_Entered_Address';
import Recommended from '@salesforce/label/c.B2B_Recommended_Address';

export default class MyAddressBook extends LightningElement {
    preferredAddressDeleteMessageLabel = PreferredAddressDeleteMessage;
    nonPreferredAddressDeleteMessageLabel = NonPreferredAddressDeleteMessage;
    addressList;
    activeSectionMessage = '';
    @track isDataNotAvailable = false;
    @track isLoaded = false
    @track recordId;
    @track showRemoveModalBox = false;
    @track showEditModalBox = false;
    @track error;
    @track editRowIndex;
    @track editableRecord;
    @track createNewAddress = false;
    @track modalBoxName = 'Edit Address';
    @track saveAndCreateButton = 'SAVE CHANGES';
    @track stateOptionList = [];
    @track addressFeildsErrors = false;
    @track addressBookForGuestUser = false;
    @track userFirstName = '';
    @track checkIfUserIsGuestUserOrNot = false;
    @track responsedAddress = {};
    @track addressPicker = false;
    @track pickedAddressType;
    @track showErrorPopup = false;
    @track errorMessage = '';

    @track currentRecord = {
        'Address__c': "",
        'City__c': " ",
        'Id': "",
        'Name': "",
        'NickName__c': "",
        'Notes__c': "",
        'Phone__c': "",
        'Email__c': "",
        'State__c': "",
        'Country__c': "United States",
        'Zip__c': "",
        'isPreferred__c': false
    };

    label = {
        CustomerEntered,
        Recommended
    };

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuserdata({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.userFirstName = data.fields.Name.value;
            if (USER_ID == undefined || USER_ID == null || this.userFirstName.includes('Guest')) {

                this.checkIfUserIsGuestUserOrNot = true;
                this.addressBookForGuestUser = true;
            }
        }
    }

    connectedCallback() {
        this.getStateValues();
        this.getAllAddressList();
        console.log('USER_ID ', USER_ID);
    }

    getAllAddressList() {
        this.isLoaded = true;
        loggedInuserAddressList()
            .then(result => {
                console.log('##result', result);
                if (result && result.length > 0) {
                    console.log('##result', result);
                    this.addressList = result;
                    this.isDataNotAvailable = false;
                }
                else if (result.length == 0) {
                    this.isDataNotAvailable = true;
                }
            })
            .catch(error => {
                console.error(error);
            })
            .finally(() => {
                this.isLoaded = false;
            })
    }

    getStateValues() {
        getStateAddressBook()
            .then(result => {
                if (result) {
                    let parseData = result;
                    let stateOptions = JSON.parse(JSON.stringify(parseData));
                    this.stateOptionList = stateOptions.sort((a, b) => (a.label > b.label) ? 1 : -1);
                }
            })
            .catch(error => {
                console.error('ERROR::', JSON.stringify(result.error));
                this.stateOptionList = [];
            });
    }

    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }

    handleSetActiveSectionC() {
        const accordion = this.template.querySelector('.example-accordion');
        accordion.activeSectionName = 'C';
    }

    /* Remove Funcationality Starts */
    removeAddressModelShow(event) {
        let addressId = event.currentTarget.dataset.id;
        this.recordId = addressId;
        this.showRemoveModalBox = true;
        let foundRecord = this.addressList.filter((item) => {
            return item.Id == addressId;
        });
        this.currentRecord = { ...foundRecord[0] };
    }

    removeAddressHandler() {
        deleteAddressBook({ addressId: this.recordId })
            .then(result => {
                if (result.length == 0) {
                    this.showToastMessage('Success', 'Removed Successfully', 'success');
                    this.isDataNotAvailable = true;
                    this.addressList = result;
                }
                else if (result.length > 0) {
                    this.showToastMessage('Success', 'Removed Successfully', 'success');
                    this.isDataNotAvailable = false;
                    this.addressList = result;
                }
            })
            .catch(error => {
                console.error(error);
                this.showToastMessage('Error', 'Fail to delete address.Please try later', 'error');
            })
            .finally(() => {

            })
        this.showRemoveModalBox = false;
    }

    closeRemoveModalBox() {
        this.showRemoveModalBox = false;
    }

    createNewAddressHandler() {
        this.currentRecord = {};
        this.modalBoxName = 'Add New Address';
        this.saveAndCreateButton = 'ADD ADDRESS';
        this.createNewAddress = true;
        this.showEditModalBox = true;
    }

    editAddressHandler(event) {
        try {
            this.modalBoxName = 'Edit Address';
            this.saveAndCreateButton = 'SAVE CHANGES';

            let addressId = event.currentTarget.dataset.id;
            this.editRowIndex = event.currentTarget.dataset.index;
            this.recordId = addressId;
            this.showEditModalBox = true;

            let foundRecord = this.addressList.filter((item) => {
                return item.Id == addressId;
            });
            this.currentRecord = { ...foundRecord[0] };
            console.log('foundRecord', JSON.stringify(this.currentRecord));

        } catch (error) {
            console.error(error.message);
        }
    }

    handleToAllowName(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        //Changed if condition by Deepak Mali for :HDMP-7477
        if (!((charCode >= 48 && charCode <= 57) || (charCode >= 65 && charCode <= 90) || (charCode >= 97 && charCode <= 122) || (charCode == 32) || (charCode == 20) || (charCode == 46))) {
            event.preventDefault();
            return false;
        }
        if (event.target.name == 'Name') {
            let addressName = this.template.querySelector(".AddName");
            let isValidName = /^[ A-Za-z0-9_@./','#&+-]*$/.test(event.target.value);
            
            if (event.target.value.length < 2 || !isValidName) {
                addressName.setCustomValidity("Invalid name, Please enter a valid name");
                addressName.reportValidity();
                this.addressFeildsErrors = true;
                return;
            } else {
                addressName.setCustomValidity("");
                addressName.reportValidity();
                this.addressFeildsErrors = false;
            }
        } else if (event.target.name == 'City') {
            let cityName = this.template.querySelector(".city");
            if (event.target.value.length < 3) {
                cityName.setCustomValidity("Enter a correct city please");
                cityName.reportValidity();
                this.addressFeildsErrors = true;
                return true;
            } else {
                cityName.setCustomValidity("");
                cityName.reportValidity();
                this.addressFeildsErrors = false;
                return false
            }
        }
        return true;
    }

    handleAddress(event) {
        let addressValue = event.target.value;
        console.log('@@#addressValue ', addressValue);
        let addressName = this.template.querySelector(".AddressName");

        if (addressValue.length < 3) {
            addressName.setCustomValidity("Enter a correct address please");
            addressName.reportValidity();
            this.addressFeildsErrors = true;
            return true;
        } else {
            addressName.setCustomValidity("");
            addressName.reportValidity();
            this.addressFeildsErrors = false;
            return false
        }
    }

    validatePhone(event) {
        let onlyNumber = /^\d+$/.test(event.target.value);
        let numberCmp = this.template.querySelector(".Number");
        //Added by Deepak for HDMP-7407
        if (event.target.value.length == 10 && onlyNumber || (event.target.value.length == 0 && onlyNumber == false)) {
            numberCmp.setCustomValidity("");
            numberCmp.reportValidity();
            this.addressFeildsErrors = false;
            return;
        } else {
            numberCmp.setCustomValidity("Invalid phone number pattern. Please enter a 10 digit numeric value");
            numberCmp.reportValidity();
            this.addressFeildsErrors = true;
        }
    }
    
    handleToAllowZipcode(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        if (!((charCode >= 48 && charCode <= 57) || (charCode == 45))) {
            event.preventDefault();
            return false;
        }
        return true;
    }

    checkZipCodeValidation(zipCode) {
        let isA_Zcontains = /^[a-zA-Z ]*$/.test(zipCode);
        if (isA_Zcontains) {
            return false;
        }
        let index = zipCode.indexOf('-');
        let count = zipCode.split('-').length - 1;
        if ((zipCode.length == 5 && !zipCode.includes('-')) || (index == 5 && zipCode.length == 10 && count == 1)) {
            //if (zipCode.length == 5) {
            return true;
        }
        return false;
    }


    addressHandleChange(event) {
        console.log(event.target.name);
        console.log(event.target.value);
        try {
            if (this.currentRecord) {
                if (event.target.name == 'Name') {
                    this.currentRecord.Name = event.target.value;
                }
                if (event.target.name == 'Address') {
                    let validAddress = this.handleAddress(event);
                    if (validAddress && validAddress == true) {
                        return;
                    } else {
                        this.currentRecord.Address__c = event.target.value;
                    }
                }
                if (event.target.name == 'City') {
                    this.currentRecord.City__c = event.target.value;
                }
                if (event.target.name == 'State') {
                    this.currentRecord.State__c = event.target.value;
                    console.log('var value', this.addressFeildsErrors);
                    this.addressFeildsErrors = false;
                }
                if (event.target.name == 'Country') {
                    this.currentRecord.Country__c = event.target.value;
                }
                if (event.target.name == 'Zip') {
                    let zipelment = this.template.querySelector(".zipCode");
                    if (!this.checkZipCodeValidation(event.target.value)) {
                        zipelment.setCustomValidity("Invalid zip code pattern. Zip code must be XXXXX or XXXXX-XXXX");
                        zipelment.reportValidity();
                        this.addressFeildsErrors = true;
                    } else {
                        zipelment.setCustomValidity("");
                        zipelment.reportValidity();
                        this.addressFeildsErrors = false;
                        this.currentRecord.Zip__c = event.target.value;
                    }
                }
                if (event.target.name == 'Phone') {
                    this.currentRecord.Phone__c = event.target.value;
                    this.addressFeildsErrors = false;
                }
                if (event.target.name == 'Notes') {
                    this.currentRecord.Notes__c = event.target.value;
                    console.log('var value', this.addressFeildsErrors);
                    this.addressFeildsErrors = false;
                }
                if (event.target.name == 'AddressNickName') {
                    this.currentRecord.NickName__c = event.target.value; // confustion
                    console.log('var value', this.addressFeildsErrors);
                    this.addressFeildsErrors = false;
                }
                if (event.target.name == 'MarkPreferredAddress') {
                    this.currentRecord.isPreferred__c = event.target.checked; // confustion
                }
                // if createNewAddress false then user clicked on edit but of any record
                if (this.createNewAddress == true) {
                    console.log('New Address Record ', JSON.parse(JSON.stringify(this.currentRecord)));
                } else if (this.createNewAddress == false) {
                    this.editableRecord = this.currentRecord;
                }
            }
        } catch (error) {
            console.error(error.message);
        }
    }

    handleClick(event)
    {
        this.isLoaded = true;
        let addressId = event.currentTarget.dataset.id;
        markAsPrefferedDirectly({ addressId: addressId})
            .then(result => {
                console.log('Result from Server', result);
                if (result) {
                    this.getAllAddressList();
                    this.showToastMessage('Success', 'Marked as Preferred Successfully', 'success');
                    this.isLoaded = false;
                } else if (!result) {
                    this.showToastMessage('Error', 'Not Marked as Preferred', 'error');
                }
            })
            .catch(error => {
                console.error(error);
            })
    }

    handleEditAction(event) {
        this.isLoaded = true;
        try {
            let buttonLabel = event.target.name;
            if (buttonLabel == 'SAVECHANGES') {
                let addressinput = {
                    'name': this.currentRecord.Name ? this.currentRecord.Name : '',
                    'streetAddress1': this.currentRecord.Address__c ? this.currentRecord.Address__c : '',
                    'streetAddress2': this.currentRecord.Address__c ? this.currentRecord.Address__c : '',
                    'city': this.currentRecord.City__c ? this.currentRecord.City__c : '',
                    'mainDivision': this.currentRecord.State__c ? this.currentRecord.State__c : '',
                    //'subDivision': '',
                    'phone': this.currentRecord.Phone__c ? this.currentRecord.Phone__c : '',
                    'postalCode': this.currentRecord.Zip__c ? this.currentRecord.Zip__c : '',
                    'nickName': this.currentRecord.NickName__c ? this.currentRecord.NickName__c : '',
                    'notes': this.currentRecord.Notes__c ? this.currentRecord.Notes__c : '',
                    'country': 'United States'
                };
                if (addressinput && addressinput.streetAddress1 && addressinput.streetAddress1.length) {
                    if (addressinput.streetAddress1.toLowerCase().includes(("pob")) || addressinput.streetAddress1.toLowerCase().includes(("po box")) || 
                        addressinput.streetAddress1.toLowerCase().includes(("po")) || addressinput.streetAddress1.toLowerCase().includes(("p o")) || 
                        addressinput.streetAddress1.toLowerCase().includes(("p.o"))) {
                        this.errorMessage = 'You have entered PO Or Po Box address, Please enter non Po Box address and try again';
                        this.showErrorPopup = true;
                        this.isLoaded = false;
                        return;
                    }
                }
                getEditAddressInfo({ editAddressId: this.currentRecord.Id })
                .then(result => {
                    console.log('Result from Server:: ', result);
                    if (result) {
                            console.log('result:: ' + JSON.stringify(result));
                            console.log('this.currentRecord:: ' + JSON.stringify(this.currentRecord));
                            if (result.Address__c != this.currentRecord.Address__c || result.City__c != this.currentRecord.City__c ||
                                result.State__c != this.currentRecord.State__c ||
                                result.Zip__c != this.currentRecord.Zip__c) {
                this.validateAddressFromAPI(addressinput);
                            } else if (this.addressFeildsErrors == true || this.currentRecord.Name == 'undefined' || this.currentRecord.Address__c == undefined || this.currentRecord.City__c == undefined || this.currentRecord.Zip__c == undefined || this.currentRecord.State__c == undefined ||
                                this.currentRecord.Name.length == 0 || this.currentRecord.Address__c.length == 0 || this.currentRecord.State__c.length == 0 || this.currentRecord.City__c.length == 0 || 
                                this.currentRecord.Zip__c.length == 0 || this.currentRecord.Phone__c == undefined || this.currentRecord.Phone__c.length == 0) {
                            this.showToastMessage('Error', 'Please review and check that all information is complete.', 'error');
                            this.isLoaded = false;
                            return
                        } else {
                            console.log(' JSON.stringify(this.currentRecord)** '+JSON.stringify(this.currentRecord));
                            updateAddressBook({ addressRecordToUpdate: JSON.stringify(this.currentRecord) })
                                .then((result) => {
                                    if (result.error == false) {
                                        this.addressList = result.addressList;
                                        //Added by Sayalee as a bug 7227
                                        if(result.errorWhenDuplicateName == 'Duplicate record not allowed') 
                                        {
                                            this.showToastMessage('Error', 'You are not allowed to insert duplicate record', 'error');
                                        }
                                        else if(result.errorWhenDuplicateName == 'Continue inserting record')
                                        {
                                            this.showToastMessage('Success', 'Address Updated Successfully', 'success'); 
                                        }  
                                        this.showEditModalBox = false;
                                        this.isLoaded = false;
                                    } else if (result.error == true) {
                                        console.error(result.errorMessage);
                                    }
                                })
                                .catch((error) => {
                                    console.error(error.message);
                                    this.showToastMessage('Error', 'Fail to update address.Please try later', 'error');
                                    this.showEditModalBox = false;
                                    this.isLoaded = false;
                                });
                        }
                    }
                    else if (!result) {
                        this.showToastMessage('Error', 'Fail to update address.Please try later', 'error');
                    }
                })
                .catch(error => {
                    console.error(error);
                })
            }
            if (buttonLabel == 'CANCEL' || buttonLabel == 'Close') {
                this.showEditModalBox = false;
                this.isLoaded = false;
                this.createNewAddress = false; // need to set false for next time 

            }
        } catch (error) {
            console.error(error.message);
            this.isLoaded = false;
        }
    }

    async validateAddressFromAPI(addressinput) {
        //Modified by shalini soni on 11-05-2022 for HDMP-8707
        //Updated by Ravi Prasad as part of HDMP-13640
        if (this.addressFeildsErrors == true || this.currentRecord.Name == 'undefined' || this.currentRecord.Address__c == undefined || this.currentRecord.City__c == undefined || this.currentRecord.Zip__c == undefined || this.currentRecord.State__c == undefined ||
            this.currentRecord.Name.length == 0 || this.currentRecord.Address__c.length == 0 || this.currentRecord.State__c.length == 0 || this.currentRecord.City__c.length == 0 || 
            this.currentRecord.Zip__c.length == 0 || this.currentRecord.Phone__c == undefined || this.currentRecord.Phone__c.length == 0) {
            this.showToastMessage('Error', 'Please review and check that all information is complete.', 'error');
            this.isLoaded = false;
            return
        }
        await vertexAddressCleansing({ addressMap: addressinput }).then(result => {
            if (result) {
                let cleansedvalue = JSON.parse(result);
                if (cleansedvalue.isError == "false") {
                    this.responsedAddress = cleansedvalue;
                    this.addressPicker = true;
                    this.showEditModalBox = false;
                    this.isLoaded = false;
                }
                else {
                    if (cleansedvalue.errorMessage.includes('Internal Error')) {
                        this.showToastMessage('Error', 'Internal Error from client ,Please Try after sometime ', 'error');
                        this.isLoaded = false;
                    }
                    else {
                        this.showToastMessage('Error', 'We’re sorry, we couldn’t verify the address you have entered. Please review and verify the correct information is entered.', 'error');
                        this.isLoaded = false;
                    }
                }
            }
        }).catch(error => {
            console.error('error from address result' + JSON.stringify(error));
            this.isLoaded = false;
        });
    }

    handleOnAddress(event) {
        console.log('inputName ', event.target.name);
        const boxes = this.template.querySelectorAll('[data-id="checkbox"]');
        console.log('boxes ', boxes);
        this.pickedAddressType = event.target.name;
        boxes.forEach(box => box.checked = event.target.name === box.name); // checked only one checkBox at a time
    }

    handleCloseAddressPicker() {
        this.addressPicker = false;
    }

    handleOnConfirmAddress() {
        if (!this.pickedAddressType || this.pickedAddressType == '') {
            this.showToastMessage('ERROR', 'please select at-least one address..', 'error');
            return;
        } else {
            if (this.pickedAddressType && this.pickedAddressType == 'TYPED') {
                 this.handleCreateAndUpdateAddress();
            }
            if (this.pickedAddressType && this.pickedAddressType == 'SUGGESTED') {
                //here we are changing some fields value which we getting from response
                this.currentRecord['Address__c'] = this.responsedAddress.StreetAddress1;
                this.currentRecord['City__c'] = this.responsedAddress.City;
                this.currentRecord['State__c'] = this.responsedAddress.MainDivision;
                this.currentRecord['Country__c'] = 'United States';
                this.currentRecord['Zip__c'] = this.responsedAddress.PostalCode;
                 this.handleCreateAndUpdateAddress();
            }
            this.addressPicker = false;
        }
    }

    handleCreateAndUpdateAddress() {
        this.isLoaded  = true;
        if (this.createNewAddress == true && this.currentRecord.Name.length > 3) {
            createAddressRecord({ addressRecord: JSON.stringify(this.currentRecord) })
                .then((result) => {
                    if (result.error == false) {
                        this.addressList = result.addressList;
                        this.isDataNotAvailable = false;
                        if(result.errorWhenDuplicateName == 'Duplicate record not allowed') {
                            console.log('not allowed',result.errorWhenDuplicateName);
                            this.showToastMessage('Error', 'The address, you are trying to add, already exists', 'error');
                        }
                        else if(result.errorWhenDuplicateName == 'Continue inserting record') {
                            this.showToastMessage('Success', 'Address Created Successfully', 'success'); 
                        }  
                    } else if (result.error == true) {
                        console.error(error.errorMessage);
                    }
                    this.showEditModalBox = false;
                    this.isLoaded = false;
                })
                .catch((error) => {
                    console.error(error.message);
                    this.showToastMessage('Error', 'Fail to create address.Please try later', 'error'); 
                    this.showEditModalBox = false;
                    this.isLoaded = false;
                });
            this.createNewAddress = false; // need to set false for next time 
        } else if (this.createNewAddress == false) {
            this.editableRecord = this.currentRecord;
            // here we are passing update json list to apex for updating
            updateAddressBook({ addressRecordToUpdate: JSON.stringify(this.editableRecord) })
                .then((result) => {
                    if (result.error == false) {
                        this.addressList = result.addressList;
                        //Added by Sayalee as a bug 7227
                        if(result.errorWhenDuplicateName == 'Duplicate record not allowed') 
                        {
                            this.showToastMessage('Error', 'You are not allowed to insert duplicate record', 'error');
                        }
                        else if(result.errorWhenDuplicateName == 'Continue inserting record')
                        {
                            this.showToastMessage('Success', 'Address Updated Successfully', 'success'); 
                        }  
                        this.showEditModalBox = false;
                        this.isLoaded = false;
                    } else if (result.error == true) {
                        console.error(result.errorMessage);
                    }
                })
                .catch((error) => {
                    console.error(error.message);
                    this.showToastMessage('Error', 'Fail to update address.Please try later', 'error');
                    this.showEditModalBox = false;
                    this.isLoaded = false;
                });
        }else{
            this.isLoaded = false;
            this.showToastMessage('Error', 'Enter valid name', 'error');
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

    closeErrorPopup() {
        this.showErrorPopup = false;
    }

}
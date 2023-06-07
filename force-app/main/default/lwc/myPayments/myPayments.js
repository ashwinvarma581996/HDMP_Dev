import { LightningElement, wire, api, track } from 'lwc';
import getMyPayments from '@salesforce/apex/B2B_MyPaymentsController.getAllMyPayments';
import deleteSinglePayment from '@salesforce/apex/B2B_MyPaymentsController.deletePaymentRecord';
import markPreferredSingleRecord from '@salesforce/apex/B2B_MyPaymentsController.markPreferredSingleRecord';
import getAllMyAddresses from '@salesforce/apex/B2B_MyPaymentsController.getAllMyAddresses';
import updatePaymentAndAddress from '@salesforce/apex/B2B_MyPaymentsController.updatePaymentAndAddress';
import getStatesList from '@salesforce/apex/B2B_LoggedInUserAddressCheck.getStateAddressBook';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';

export default class MyPayments extends LightningElement {
    @track isLoading = false;
    @track showEditModal = false;
    @track showRemoveModal = false;
    @track showNoRecordFoundMsg = false;
    @track paymentCardNumber;
    @track removePaymentId;
    @track editPaymentId;
    @track editPaymentRecord;
    @track existingAddresses;
    @track isAddressesExist;
    @track validEditForm;
    @track paymentsList = [];
    @track stateOptionList = [];
    @track billingAddress = {};
    @track paymentRecord = {};

    connectedCallback(){
        console.log('USER_ID : ',USER_ID);
        if(USER_ID == undefined || USER_ID == null){
            this.showNoRecordFoundMsg = true;
        }else{
            this.getMyPaymentsList();
            this.getStateValues();
        }
    }

    getMyPaymentsList(){
        this.isLoading = true;
        getMyPayments()
        .then(result => {
            if (result && result.includes('No record found')) {
                this.showNoRecordFoundMsg = true;
                this.isLoading = false;
            }else if(result){
                this.isLoading = false;
                console.log('result : ',JSON.parse(result));
                this.paymentsList = JSON.parse(result);
                this.validateCardExpirationDate();
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.showNoRecordFoundMsg = true;
            console.log('Error : ',error);
        });
    }

    validateCardExpirationDate(){
        this.paymentsList.forEach((element, index) => {
            element.dateNotExpired = isFutureDate(new Date(element.CC_Expiration_Date__c), new Date());
        });
        console.log('this.paymentsList : ',this.paymentsList);
        function isFutureDate(d1, today) {
            if(d1.getFullYear() > today.getFullYear()){
                return true;
            }else if(d1.getFullYear() < today.getFullYear()){
                return false;
            }else if(d1.getFullYear() == today.getFullYear()){
                if(d1.getMonth() >= today.getMonth()){
                    return true;
                }else if(d1.getMonth() < today.getMonth()){
                    return false;
                }else if(d1.getMonth() == today.getMonth()){
                    return true;
                }
            }
        }
    }

    getStateValues() {
        getStatesList()
        .then(result => {
            if (result) {
                this.stateOptionList = result.sort((a, b) => (a.label > b.label) ? 1 : -1);
                console.log('@### stateOptionList ', this.stateOptionList);
            }
        })
        .catch(error => {
            console.error('ERROR::', error);
        });
    }

    handleMarkPreferred(event){
        let markPaymentId = event.currentTarget.dataset.id;
        console.log('markPaymentId : ',markPaymentId);
        if (markPaymentId) {
            this.isLoading = true;
            markPreferredSingleRecord({ paymentId: markPaymentId })
            .then(result => {
                if (result && result.length > 0) {
                    console.log('OUTPUT : ',result);
                    this.paymentsList = JSON.parse(result);
                    this.validateCardExpirationDate();
                    this.isLoading = false;
                    this.showToastMessage('Success', 'Mark Successfully', 'success');
                }else if(result && result.includes('No record found')) {
                    console.log('OUTPUT : ',result);
                    this.isLoading = false;
                    this.showToastMessage('Error', result, 'error');
                }
            })
            .catch(error => {
                console.log('Error : ',error);
                this.isLoading = false;
                this.showToastMessage('Error', error.message, 'error');
            });            
        }
    }

    removePaymentModelShow(event) {
        this.showRemoveModal = true;
        this.removePaymentId = event.currentTarget.dataset.id;
        this.paymentCardNumber = event.currentTarget.dataset.cardnumber;
    }

    closeRemoveModel() {
        this.showRemoveModal = false;
    }

    handleRemovePayment(){
        if (this.removePaymentId) {
            this.isLoading = true;
            deleteSinglePayment({ paymentId: this.removePaymentId })
            .then(result => {
                if (result && !result.includes('No record found')) {
                    console.log('Result from Server', result);
                    this.paymentsList.forEach((element, index) => {
                        if (element.Id == this.removePaymentId) {
                            this.paymentsList.splice(index, 1);
                            console.log('Found reeee');
                        }
                    });
                    this.getMyPaymentsList();
                    if (this.paymentsList.length == 0) {
                        this.showNoRecordFoundMsg = true;
                    }
                    this.isLoading = false;
                    this.showRemoveModal = false;
                    this.showToastMessage('Success', result, 'success');
                }
            })
            .catch(error => {
                console.log('Error : ',error);
                this.showRemoveModal = false;
                this.showToastMessage('Error', error.message, 'error');
                this.isLoading = false;
            });
        }
    }

    openEditModel(event){
        this.showEditModal = true;
        this.editPaymentId = event.currentTarget.dataset.id;
        let foundRecord = this.paymentsList.filter((item) => {
            return item.Id == this.editPaymentId;
        });
        console.log('OUTPUT : ',foundRecord);
        if (foundRecord != undefined) {
            this.editPaymentRecord = { ...foundRecord[0]};                
        }
        console.log('foundRecord', JSON.stringify(this.editPaymentRecord));
        let exirationDateArr = this.editPaymentRecord.CC_Expiration_Date__c.split('-');
        this.editPaymentRecord.CC_Expiration_Date__c = exirationDateArr[1]+'/'+exirationDateArr[0].substr(2,2);
        let currentAddressId = event.currentTarget.dataset.addressid;
        console.log('OUTPUT : ',currentAddressId);
        if (currentAddressId) {
            getAllMyAddresses({ addressId: currentAddressId })
            .then(result => {
                if (result && !result.includes('No record found')) {
                    this.existingAddresses = JSON.parse(result);
                    console.log('OUTPUT : ',this.existingAddresses);
                    this.isAddressesExist = true;
                }else if(result && result.includes('No record found')){
                    console.log('OUTPUT : ',result);
                    this.existingAddresses = [];
                    this.isAddressesExist = false;
                }
            })
            .catch(error => {
                console.log('Error : ',error);
            });            
        }  
    }

    handleToAllowName(event) {
        let charCode = (event.which) ? event.which : event.keyCode;
        console.log('OUTPUT : ',charCode);
        if (!((charCode >= 97 && charCode <= 122) || (charCode >= 65 && charCode <= 90) || (charCode == 32))) {
            event.preventDefault();
            return false;
        }
        return true;
    }

    handleUpdateFields(event) {
        console.log(event.target.name);
        console.log(event.target.value);
        try {
            if (this.editPaymentRecord) {
                this.paymentRecord.Id = this.editPaymentRecord.Id;
                this.billingAddress.Id = this.editPaymentRecord.My_Address_Book__c;
                if (event.target.name == 'Add-Name') {
                    this.billingAddress.Name = event.target.value;
                }
                if (event.target.name == 'Add-Address') {
                    this.billingAddress.Address__c = event.target.value;                    
                }
                if (event.target.name == 'Add-City') {
                    this.billingAddress.City__c = event.target.value;
                }
                if (event.target.name == 'Add-State') {
                    this.billingAddress.State__c = event.target.value;
                }
                if (event.target.name == 'Add-Zip') {
                    this.billingAddress.Zip__c = event.target.value;
                }
                if (event.target.name == 'Add-Phone') {
                    this.billingAddress.Phone__c = event.target.value;
                }
                if (event.target.name == 'Cardholdername') {
                    this.paymentRecord.Name = event.target.value;
                }
                if (event.target.name == 'expiration') {
                    //this.paymentRecord.CC_Expiration_Date__c = event.target.value;
                    this.paymentRecord.CC_Expiration_Date__c = event.target.value.length == 0 ? null : Date.parse(event.target.value.slice(0, 3) + "2/" + event.target.value.slice(3));
                }
                if (event.target.name == 'MarkPreferredAddress') {
                    this.paymentRecord.Default_Payment_Method__c = event.target.checked;;
                }
            }   
        } catch (error) {
            console.error(error.message);
        }
    }

    handleChangeAddress(event){
        console.log('event1 : ',event.target.checked);
        console.log('event1 : ',event.target.dataset.selectid);
        if (event.target.checked && event.target.dataset.selectid && this.editPaymentRecord) {
            this.paymentRecord.My_Address_Book__c = event.target.dataset.selectid;
            this.paymentRecord.Id = this.editPaymentRecord.Id;
            this.billingAddress.Id = this.editPaymentRecord.My_Address_Book__c;
        }
    }

    handleEditSaveAction(event){
        console.log('paymentRecord : ',this.paymentRecord);
        console.log('billingAddress : ',this.billingAddress);
        this.validateEditForm();
        console.log('OUTPUT : ',this.validEditForm);
        if (this.paymentRecord.Id && this.billingAddress.Id && this.validEditForm) {
            this.isLoading = true;
            updatePaymentAndAddress({addressForUpdate: JSON.stringify(this.billingAddress), paymentForUpdate: JSON.stringify(this.paymentRecord)})
            .then(result => {
                if (result && result.length > 0) {
                    console.log('OUTPUT : ',result);
                    this.paymentsList = JSON.parse(result);
                    this.validateCardExpirationDate();
                    this.isLoading = false;
                    this.showEditModal = false;
                    this.showToastMessage('Success', 'Updated', 'success');
                    this.billingAddress = {};
                    this.paymentRecord = {};
                }
            })
            .catch(error => {
                this.isLoading = false;
                console.log('ERROR : ',error);
                this.showEditModal = false;
                this.billingAddress = {};
                this.paymentRecord = {};
            });
        }
    }

    validateEditForm(){
        try {
            for (var key in this.billingAddress) {
                console.log(key + " -> " + this.billingAddress[key]);
                if (this.billingAddress.hasOwnProperty(key) && this.billingAddress[key].trim().length == 0) {
                    this.validEditForm = false;
                    this.showToastMessage('Error', 'Please review and check that all information is complete.', 'error');
                    return;
                }else if(this.billingAddress.hasOwnProperty(key) && this.billingAddress[key].trim().length > 0){
                    this.validEditForm = true;
                }
            }
            if (this.paymentRecord && this.paymentRecord.hasOwnProperty('Name') && this.paymentRecord.Name.trim().length == 0) {
                this.validEditForm = false;
                this.showToastMessage('Error', 'Please review and check that all information is complete.', 'error');
                return;
            }
            if(this.paymentRecord && this.paymentRecord.hasOwnProperty('CC_Expiration_Date__c') && this.paymentRecord.CC_Expiration_Date__c == null){
                this.validEditForm = false;
                this.showToastMessage('Error', 'Please review and check that all information is complete.', 'error');
                return;
            }
            this.validEditForm = true;
        } catch (error) {
            console.log('OUTPUT : ',error);
        }
    }

    closeEditModel(){
        this.showEditModal = false;
        this.billingAddress = {};
        this.paymentRecord = {};
    }

    showToastMessage(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    formatString(event) {
        var inputChar = String.fromCharCode(event.keyCode);
        var code = event.keyCode;
        var allowedKeys = [8];
        if (allowedKeys.indexOf(code) !== -1) {
            return;
        }
      
        event.target.value = event.target.value.replace(
          /^([1-9]\/|[2-9])$/g, '0$1/'
        ).replace(
          /^(0[1-9]|1[0-2])$/g, '$1/'
        ).replace(
          /^([0-1])([3-9])$/g, '0$1/$2'
        ).replace(
          /^(0?[1-9]|1[0-2])([0-9]{2})$/g, '$1/$2'
        ).replace(
          /^([0]+)\/|[0]+$/g, '0'
        ).replace(
          /[^\d\/]|^[\/]*$/g, ''
        ).replace(
          /\/\//g, '/'
        );
    }
}
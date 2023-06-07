import {
    LightningElement,
    //wire,
    track,
    api
} from 'lwc';
//import Id from '@salesforce/user/Id';
//import ACCOUNT_ID from '@salesforce/schema/User.Contact.AccountId';
/*mport {
    getRecord,
    getFieldValue,
    updateRecord
} from 'lightning/uiRecordApi';*/
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import getInitalData from '@salesforce/apex/OwnEditAddressContrller.getInitalData';
import updateAddress from '@salesforce/apex/OwnEditAddressContrller.updateAddress';

//const fields = [ACCOUNT_ID];

export default class OwnEditAddress extends LightningElement {
    //userId = Id;
    @api accountId;
    @track account = {};
    @track states = [];

    /*@wire(getRecord, {
        recordId: '$userId',
        fields
    })
    wiredRecord({
        error,
        data
    }) {
        if (error) {
            let message = 'Unknown error';

            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading user!',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.accountId = getFieldValue(data, ACCOUNT_ID);
            this.loadInitialData();
        }
    }*/

    connectedCallback(){
        this.loadInitialData();
    }

    loadInitialData() {
        getInitalData({
                accountId: this.accountId
            })
            .then((result) => {
                this.states = result.states;
                this.account = result.accountRecord;
            })
            .catch((error) => {
               // console.log(error);
            });
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');

        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        return isValid;
    }

    handleSave() {
        if(this.isInputValid()) {
            updateAddress({ accountRecord: this.account })
            .then(() => {
                /* DOE-4843
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Address updated!',
                        variant: 'success'
                    })
                );*/
                this.dispatchEvent(new CustomEvent("cancel"));
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error update address',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent("cancel"));
    }

    //Brett Spokes - Feb 25, changed from billingaddress to personmailingaddress
    handleAddressChange(event) {
        //this.account.BillingStreet = event.currentTarget.value;
        this.account.PersonMailingStreet = event.currentTarget.value;
    }

    handleCityChange(event) {
        //this.account.BillingCity = event.currentTarget.value;
        this.account.PersonMailingCity = event.currentTarget.value;
    }

    handleStateChange(event) {
        //this.account.BillingState = event.currentTarget.value;
        this.account.PersonMailingState = event.currentTarget.value;
    }

    handleZipCodeChange(event) {
        //this.account.BillingPostalCode = event.currentTarget.value;
        this.account.PersonMailingPostalCode = event.currentTarget.value;
    }
}
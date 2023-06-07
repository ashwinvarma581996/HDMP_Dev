/*******************************************************************************
Name: MyPerferences
Business Unit: HDM
Date: 25/08/2022
Developer: Mathioli
Description: LWC is created to handle UI for MYpreferences 
*******************************************************************************
MODIFICATIONS – Date | Dev Name 	| Method | User Story
           21/07/22    saikiran      Added checkCurrentUserIsGuestTest1
           15/08/22     Mathioli      Added error message and updated the toast message
                                    HDMP-5356 JIRA Number
*******************************************************************************/
import { LightningElement, wire } from 'lwc';
import getPickListValues from '@salesforce/apex/B2BMyPerferencesController.getPickListValues';
import MyPreferredShipping from '@salesforce/apex/B2BMyPerferencesController.insertMyPreferredShipping';
import checkExistingShippingPerferences from '@salesforce/apex/B2BMyPerferencesController.checkExistingShippingPerferences';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkCurrentUserIsGuest from '@salesforce/apex/B2BMyPerferencesController.checkCurrentUserIsGuest';
import redirectUrl from '@salesforce/label/c.B2B_myPreferenceRe';  //custom lable added

export default class MyPerferences extends LightningElement {
    getShippingOption;
    getDeliveryOption;
    seletedDeliveryMethod;
    seletedShippingSpeed;
    isLoading = false;
    isGuestUser = true;
    showError = false;
    value = ['option1'];

    connectedCallback() {
        this.isLoading = true;
        checkCurrentUserIsGuest().then(result => {

            if (result) {
                this.isGuestUser = true;
                this.showError = true;
                this.isLoading = false;
                return;
            } else {
                this.isGuestUser = false;
                this.showError = false;
                checkExistingShippingPerferences().then(result => {

                    if (result && result.length) {
                        this.seletedShippingSpeed = result[0].Preferred_Honda_Shipping_Speed__r.Name;
                        this.seletedDeliveryMethod = result[0].Preferred_Delivery_Type__c;
                    } else {
                        this.seletedDeliveryMethod = 'Pick Up At Dealer';
                        this.seletedShippingSpeed = 'Standard (7-10 Days)';
                    }
                    this.isLoading = false;
                }).catch();
            }
        })
            .catch(error => {

                this.ShowToastMessage('Error', 'Error', 'We’re experiencing technical difficulties, please try again later');
                this.isLoading = false;
            });




    }


    @wire(getPickListValues)
    getPickListValueData({ error, data }) {
        if (data) {

            if ((data.deliveryValueList == undefined) || (data.shippingValueList == undefined)) {

                this.ShowToastMessage('Error', 'Error', 'We’re experiencing technical difficulties, please try again later');

            }

            this.getDeliveryOption = data.deliveryValueList.map(delivery => {
                return { label: delivery, value: delivery };
            });

            this.getShippingOption = data.shippingValueList.map(shipping => {
                return { label: shipping, value: shipping };
            });

        }

        else if (error) {

        }
    }


    handelDeliveryOption(event) {
        this.seletedDeliveryMethod = event.target.value;
    }

    handelShippingOption(event) {
        this.seletedShippingSpeed = event.target.value;
    }
    handleOnSavePerferences() {
        //if (this.seletedDeliveryMethod && this.seletedDepartmentPreference && this.seletedShippingSpeed) {
        if (this.seletedDeliveryMethod && this.seletedShippingSpeed) {
            this.isLoading = true;
            //Commented By Soumya for Notification Preferences requirement
            //MyPreferredShipping({ delivery: this.seletedDeliveryMethod, shipping: this.seletedShippingSpeed, department: this.seletedDepartmentPreference }).then(result => {
            MyPreferredShipping({ delivery: this.seletedDeliveryMethod, shipping: this.seletedShippingSpeed }).then(result => {
                if (result == 'Success') {

                    this.isLoading = false;
                    this.ShowToastMessage('success', 'Success', 'Your Perferences are successfully saved');
                } else {
                    this.ShowToastMessage('Error', 'Error', 'We’re experiencing technical difficulties, please try again later');

                }
            }).catch(error => {

            });
        }
    }

    ShowToastMessage(_variant, _title, _message) {
        const event = new ShowToastEvent({
            variant: _variant,
            title: _title,
            message: _message,
        });
        this.dispatchEvent(event);
    }

    handleClickOnCancel() {
        window.location.reload(); //added by Yashika for 8162
    }



    handlePreferenceRedirect() {

        window.open(redirectUrl, '_blank'); //custom label
    }

}
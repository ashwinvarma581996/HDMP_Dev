import { LightningElement, track, wire, api } from 'lwc';
//  import RETURN_POLICY_LABEL_ID from '@salesforce/label/c.RETURN_POLICY_LABEL';
import { getRecord } from 'lightning/uiRecordApi';
import getReturnPolicyMarkupMdt from '@salesforce/apex/B2B_DealerReturnPolicyController.getReturnPolicyMarkupMdt';

const FIELDS = [
    'Default_Policy_Markup__mdt.MasterLabel',
    'Default_Policy_Markup__mdt.DeveloperName',
    'Default_Policy_Markup__mdt.Markup__c',
    'Default_Policy_Markup__mdt.Policy_Header__c',
];

export default class DisclaimerModal extends LightningElement {

    @track showHideModal = false;
    @api mdtRecordId;
    popupHeader;
    @api htmlMarkup = '<h1>Loading...</h1>';
    @api mdtPolicyName;
    pageName = window.document.title;
    notFound = 'Contact Dealer';
    noDisclaimerBody = 'Returns and Exchange policies are at the dealer’s discretion, please contact your dealer for more details'

    @api disclaimertype;
    dealerReturnPolicyMrk;





    @api
    get modaltype() {

    }




    set modaltype(value) {
        if (value) {

            this.handleShowDisclaimer(value);

        }
    }

    @api
    get dealerReturnPolicyMarkup() { }

    set dealerReturnPolicyMarkup(value) {
        if (value) {
            this.dealerReturnPolicyMrk = value;

        }
    }


    get disclaimerMarkup() {
        return this.htmlMarkup;
    }
    set disclaimerMarkup(value) {
        this.htmlMarkup = value;
    }






    handleShowDisclaimer(type) {


        getReturnPolicyMarkupMdt()
            .then(data => {

                if (data == null) {
                    this.handleIfNoDataFound();
                    return false;
                }

                if (type == 'Terms_and_Conditions_of_sale') {
                    this.popupHeader = data.Terms_and_Conditions_of_sale.Policy_Header__c;
                    this.disclaimerMarkup = data.Terms_and_Conditions_of_sale.Markup__c;
                }
                else if (type == 'Return_Policy') {


                    this.popupHeader = data.Return_Policy.Policy_Header__c;
                    this.disclaimerMarkup = this.dealerReturnPolicyMrk !== "" && this.dealerReturnPolicyMrk !== undefined ? this.dealerReturnPolicyMrk
                        : data.Return_Policy.Markup__c;
                }
                // else if (type == 'B2B_Product_Disclaimer_Markup') {
                //     this.popupHeader = data.B2B_Product_Disclaimer_Markup.Policy_Header__c;
                //     this.disclaimerMarkup = data.B2B_Product_Disclaimer_Markup.Markup__c;
                // }
                //added for motocompacto
                else if (type == 'Motocompacto') {
                    this.popupHeader = 'Product Disclaimer';
                    console.log(data.B2B_Motocompacto_Disclaimer_Markup.Markup__c)
                    this.disclaimerMarkup = data.B2B_Motocompacto_Disclaimer_Markup.Markup__c;
                } //motocompacto: ends

                // Added for 7812 , 7811 , 17449
                else if (type == 'Core_Charge_Disclaimer') {

                    this.popupHeader = data.Core_Charge_Disclaimer.Policy_Header__c;
                    this.disclaimerMarkup = data.Core_Charge_Disclaimer.Markup__c;
                }

                // Pratik LTIM Added for Sprint 4 Tax jurisidcations
                else if (type == 'zipCodeDisclaimer') {

                    this.popupHeader = '';
                    this.disclaimerMarkup = data.zip_code_dislciamer.Markup__c;
                }
            })
            .catch(error => {
                console.log('Disclamer Popup Error =====>  ', error)
                this.handleIfNoDataFound();

            });



    }




    handleIfNoDataFound() {
        this.popupHeader = this.notFound;
        this.disclaimerMarkup = this.noDisclaimerBody;
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'))
    }
}
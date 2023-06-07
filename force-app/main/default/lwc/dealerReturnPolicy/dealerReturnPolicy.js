import { LightningElement, track, wire, api } from 'lwc';
import getReturnPolicy from '@salesforce/apex/B2B_DealerReturnPolicyController.getReturnPolicy';
import getReturnPolicyMarkupMdt from '@salesforce/apex/B2B_DealerReturnPolicyController.getReturnPolicyMarkupMdt';// Aditya - Core charges desclaimer email Added as a part of HDMP-16462

export default class DisclaimerModal extends LightningElement {


    @api htmlMarkup;
    spinnerShowHide = true;
    accRecord;
    parameters = {};
    dealerPolicy;
    showDealerPolicy = false;
    showDefaultPolicy = false;
    showCorechargePolicy = false; // Aditya - Core charges desclaimer email Added as a part of HDMP-16462
    showspinner = true;
    noDisclaimerBody = 'No Data Found' // Aditya - Core charges desclaimer email Added as a part of HDMP-16462

    
    /* Start Aditya - Core charges desclaimer email Added as a part of HDMP-16462 */
    /**
     * Gets or sets to have the disclaimer markup 
     *
     * @type {String}
     */
    get disclaimerMarkup() {
        return this.htmlMarkup;
    }
    set disclaimerMarkup(value) {
        this.htmlMarkup = value;
    }

    /* End Aditya - Core charges desclaimer email Added as a part of HDMP-16462 */


    connectedCallback() {


        this.parameters = this.getQueryParameters();
        /* Start Aditya - Core charges desclaimer email Added as a part of HDMP-16462 */
        if(this.parameters.corecharge ==='true'){
            console.log('this.parameters.corecharge ----> ',this.parameters.corecharge);
            this.showspinner = false;
            this.showDefaultPolicy = false;
            this.showDealerPolicy = false;
            this.showCorechargePolicy = true;

            getReturnPolicyMarkupMdt()
            .then(data => {

                if (data == null) {
                    this.handleIfNoDataFound();
                    return false;
                }
                else{
                    this.disclaimerMarkup = data.Core_Charge_Disclaimer.Markup__c ;
                }
                
            })
            .catch(error => {
                console.log('Disclamer Popup Error =====>  ', error)
                this.handleIfNoDataFound();

            });

        }
        /* End Aditya - Core charges desclaimer email Added as a part of HDMP-16462 */
        if(this.parameters.corecharge != 'true'){  // Aditya - Core charges desclaimer email Added as a part of HDMP-16462
        getReturnPolicy({ dealerNo: this.parameters.dealer }).then(result => {
            this.accRecord = result;

            if (this.accRecord != null && this.accRecord[0].Return_Policy__c != null) {
                this.dealerPolicy = this.accRecord[0].Return_Policy__c;
                this.showDealerPolicy = true;
                this.showspinner = false;
            }
            else {
                this.showDefaultPolicy = true;
                this.showspinner = false;
            }



        }).catch(error => {
            this.showDefaultPolicy = true;
            this.showspinner = false;
            console.log(error);
        })
    }  // Aditya - Core charges desclaimer email Added as a part of HDMP-16462

    }
    
    /* Start Aditya - Core charges desclaimer email Added as a part of HDMP-16462 */
    handleIfNoDataFound() {
        this.disclaimerMarkup = this.noDisclaimerBody;
    }
    /* End Aditya - Core charges desclaimer email Added as a part of HDMP-16462 */

    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

}
/******************************************************************************* 
Name: myDealers 
Business Unit: HDM
Created Date: 01-02-2022
Created By : Shalini soni
Description: This component used as parent component to display my dealers

******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
           11-08-2022| saikiran | getAllDealersList | HDMP-9914
           25-08-2022| saikiran | getAllDealersList | HDMP-12417

*******************************************************************************/
import { LightningElement, track } from 'lwc';
import getMyDealersList from '@salesforce/apex/B2B_LoggedInUserMyDealers.getMyDealersList';
const DIVISION_A = 'A';
const DIVISION_B = 'B';
export default class MyDealers extends LightningElement {
    @track dealersList;
    @track hondaDealersList = [];
    @track acuraDealersList = [];
    @track isFetchData = false;

    connectedCallback() {
        this.getAllDealersList();
    }

    // separate the honda and acura dealers list to show all dealers list on page load
    getAllDealersList() {
        let brandName = sessionStorage.getItem('dealerSiteBrand');
        let dealerInfo = JSON.parse(sessionStorage.getItem('dealer'));
        console.log('dealerInfo', sessionStorage.getItem('dealer'));
        getMyDealersList()
            .then(result => {
                if (result) {
                    if (result && result.length > 0) {
                        this.dealersList = result;
                        this.dealersList.forEach(element => {
                             //Lakshmi HDMP-19454,HDMP-19445 Sales Tax jurisdiction changes
                            if(element.Sales_Tax_Jurisdiction__c){
                                if(element.Sales_Tax_Jurisdiction__c.split(';').length > 50){
                                    element.shippingtaxstate = 'All 50 States';
                                }else{
                                    element.shippingtaxstate = element.Sales_Tax_Jurisdiction__c.replaceAll(';',',');
                                }
                            } else{
                                    element.shippingtaxstate = element.BillingState;//Lakshmi HDMP-19495
                            }

                            //alert(element.Name + '----' + element.Return_Policy__c);
                       
                            if (element && element.DivisionCd__c == DIVISION_A) {
                                //updated by saikiran  as part of HDMP-13100 and HDMP-12756
                                if((brandName && brandName == 'Acura')|| !element.IsActive__c){
                                    element.disableBtn = true;
                                }
                                if((brandName && brandName == 'Honda'&& element.PoIId__c != dealerInfo.dealerNo) || !element.IsActive__c){
                                    element.disableBtn = true;
                                }
                                element.brandName = 'Honda Auto' ;// Added by saikiran HDMP-12417
                                this.hondaDealersList.push(element);
                            } else if (element && element.DivisionCd__c == DIVISION_B) {
                                if((brandName && brandName == 'Honda')|| !element.IsActive__c){
                                    element.disableBtn = true;
                                }
                                if((brandName && brandName == 'Acura'&& element.PoIId__c != dealerInfo.dealerNo)|| !element.IsActive__c){
                                    element.disableBtn = true;
                                }
                                element.brandName = 'Acura' ;// Added by saikiran HDMP-12417
                                this.acuraDealersList.push(element);
                            }
                            //updated by saikian as part of HDMP 9914
                            if(element.Operation_Hour__c){
                                var hours = element.Operation_Hour__c ;
                                element.OperationHours = hours.split('\;');
                            }
                        })
                        this.acuraDealersList = this.acuraDealersList.length >0 ? this.acuraDealersList : null; 
                        this.hondaDealersList = this.hondaDealersList.length >0 ? this.hondaDealersList : null; 
                    }
                    else {
                        this.dealersList = null;
                    }

                }
            })
            .catch(error => {
                console.error('Error at My Dealers:'+ error);
            })
            .finally(() => {
                this.isFetchData = true;
            })
    }

}
/* 
* Apex Class Name   :   CashElementController
* @description      :	This class is controller for LWC Component (cashElements)
* Modification Log  :
* ---------------------------------------------------------------------------
* Developer                        Date                   Description
* ---------------------------------------------------------------------------
* Priyadarshi Singh              2nd MAR 2023               
*********************************************************************************/
public class CashElementController {
    /** 
	* @author Priyadarshi Singh
	* @description This method is used to update cash elements in Offers__c and Offer_Eligible_Model__c Object.
	*/
    @AuraEnabled
    Public Static Boolean updateData(Id recId, String dealer, decimal conquest, decimal captiveCash, decimal loyality, decimal otherCaptive, decimal additionalCash){
        Boolean returnValue = true;
        system.debug('printing'+dealer);
        system.debug('printing conqu'+conquest);
        system.debug('printing captiveCash'+captiveCash);
        system.debug('printing loyality'+loyality);
        system.debug('printing otherCaptive'+otherCaptive);
        system.debug('printing additionalCash'+additionalCash);
        
        List<Offers__c> offer = new List<Offers__c>();
        try{
        List<Offer_Eligible_Models__c> offers = new List<Offer_Eligible_Models__c>();
        offer = [Select Id,Dealer_Contribution__c,Conquest_Cash__c,Captive_Cash__c,Loyalty_Cash__c,Other_Captive_Cash__c,Additional_Cash__c from Offers__c where Id =: recId];
        if(offer.Size() > 0){
            offer[0].Dealer_Contribution__c = dealer;
            offer[0].Conquest_Cash__c = conquest;
            offer[0].Captive_Cash__c = captiveCash;
            offer[0].Loyalty_Cash__c = loyality;
            offer[0].Other_Captive_Cash__c = otherCaptive;
            offer[0].Additional_Cash__c = additionalCash;
            Update offer;
        }
        offers = [Select Id,Is_Calculation_Done__c,Dealer_Contribution__c,Conquest_Cash__c,Captive_Cash_Lease_Amount__c,Other_Captive_Cash_Lease_Amount__c,Loyalty_Cash__c,Additional_Cash__c from Offer_Eligible_Models__c where Offer__c =: recId];
        if(offers.Size() > 0){
            for(Offer_Eligible_Models__c ofr : offers){
                if(dealer == null || dealer == ''){
                    ofr.Dealer_Contribution__c = null;
                }else{
                    ofr.Dealer_Contribution__c = decimal.valueOf(dealer);
                }
            	ofr.Conquest_Cash__c = conquest;
            	ofr.Captive_Cash_Lease_Amount__c = captiveCash;
            	ofr.Other_Captive_Cash_Lease_Amount__c = otherCaptive;
            	ofr.Loyalty_Cash__c = loyality;
            	ofr.Additional_Cash__c = additionalCash;
                ofr.Is_Calculation_Done__c = false;
            }
            update offers;
        }
        } Catch(Exception ex){
            System.debug('printing ex'+ex);
            returnValue = false;
        }
        return returnValue;
    }
    /** 
	* @author Priyadarshi Singh
	* @description This method is used to fetch data from Offers__c object and return it to CashElement Lwc Component.
	*/
    @AuraEnabled
    Public Static List<Offers__c> getData(Id recId){
        List<Offers__c> offer = new List<Offers__c>();
        try{
        offer = [Select Id,Dealer_Contribution__c,Conquest_Cash__c,Captive_Cash__c,Loyalty_Cash__c,Other_Captive_Cash__c,Additional_Cash__c from Offers__c where Id =: recId];
        } Catch(Exception ex){
            system.debug(ex);
        }
        return offer;
    }
    
    

}
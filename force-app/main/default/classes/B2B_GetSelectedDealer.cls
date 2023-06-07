/*******************************************************************************
Name: B2B_GetSelectedDealer
Business Unit: HDM Dreamshop
Date: 23/12/2022
Developer: Faraz Ansari
Description: To get all details related to selected dealer 
********************************************************************************/

public without sharing class B2B_GetSelectedDealer {
    @AuraEnabled
    public static string getDealerInfo(String dealerName){
        //Lakshmi HDMP-19454,19445 for Sales_Tax_Jurisdiction__c
        return JSON.serialize([SELECT Id, Name, Phone, BillingCity, BillingStreet, BillingState, BillingPostalCode, First_Name__c, 
        Last_Name__c, Operation_Hour__c, Email__c, Website,Sales_Tax_Jurisdiction__c FROM Account WHERE Name LIKE: dealerName AND IsActive__c = true]);
    }
}
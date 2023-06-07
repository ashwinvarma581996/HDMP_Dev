/**********************************************************************
Name: B2B_AccountTriggerHelper
Purpose: Helper class for AccountTrigger
Date : 01/11/2021
Created By : Rajrishi Kaushik
*************************************************************/

public class B2B_AccountTriggerHelper {
    
    //this method is used to process before update calls by trigger
    public static void beforeUpdate(List<Account> lstNewAccounts, List<Account> lstOldAccounts, Map<Id, Account> mapNewAccounts, Map<Id, Account> mapOldAccounts){    
        //checkBTSetup(lstNewAccounts, mapOldAccounts);
    }
    
    //this method is used to process before update calls by trigger
    public static void afterUpdate(List<Account> lstNewAccounts, List<Account> lstOldAccounts, Map<Id, Account> mapNewAccounts, Map<Id, Account> mapOldAccounts){    
        disabledOAuthForMerchantId(lstNewAccounts, mapOldAccounts);
    }
    public static void beforeInsert(List<Account> lstNewAccounts){
        populatedefaultcarrier(lstNewAccounts);
    }
    
    
    //method to update Reserve and Dreamshop setup flags 
   /* public static void checkBTSetup(List<Account> lstNewAccounts, Map<Id, Account> mapOldAccounts){
        for(Account objAccount : lstNewAccounts){
            if(objAccount.IsActive__c == true && objAccount.Is_Vehicle_Reserve__c == True && mapOldAccounts.get(objAccount.Id).Is_Vehicle_Reserve__c == false){
                objAccount.Vehicle_Reserve_Setup__c = true;
            }
            if(objAccount.IsActive__c == true && objAccount.Is_Dreamshop__c == True && mapOldAccounts.get(objAccount.Id).Is_Dreamshop__c == false){
                objAccount.Dreamshop_Setup__c = true;
            }
        }
    }*/
    
    // method to disable isActive__c (Is BT Setup) flag when merchant Id for dealer is updated 
    // added on 07/03/2022
    public static void disabledOAuthForMerchantId(List<Account> lstNewAccounts, Map<Id, Account> mapOldAccounts){
        Set<Id> accIds = new Set<Id>();
        List<Account> lstUpdateAccounts = new List<Account>();
        for(Account objAccount : [SELECT Id,IsActive__c,Merchant_Id__c,lastModifiedBy.Name FROM Account WHERE Id IN: mapOldAccounts.keySet()]){      
           
            // check merchant id is changed
            if(objAccount.IsActive__c == true && String.isNotEmpty(mapOldAccounts.get(objAccount.Id).Merchant_Id__c) 
               && objAccount.Merchant_Id__c != mapOldAccounts.get(objAccount.Id).Merchant_Id__c && objAccount.lastModifiedBy.Name.containsIgnoreCase('Migration')){
                objAccount.IsActive__c = false;
                accIds.add(objAccount.Id);  
                lstUpdateAccounts.add(objAccount);
            }
        }        
            
        // delete the related BT Token Details records 
        List<BT_Token_Details__c> lstBTDetails = [SELECT Id From BT_Token_Details__c WHERE Account__c IN: accIds];
        if(!lstBTDetails.isEmpty()){
            delete lstBTDetails;
        }
        
        // update the accounts
        if(!lstUpdateAccounts.isEmpty()){
            update lstUpdateAccounts;
        }
    }
    // Below method added to populate deafult carrer name of the Account
    public static void populatedefaultcarrier(List<Account> lstNewAccounts){
        String migrationUserId;
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(B2B_Constant.DEALER_RECORD_TYPE).getRecordTypeId();
        List <Carrier__c> carrierId = [SELECT Id FROM Carrier__c where Is_Active__c =: B2B_Constant.TRUE_FLAG and name = : B2B_Constant.DEFAULT_CARRIER_NAME limit 1];
        if (carrierId !=null && carrierId.size()>0){
        for(Account accountObj : lstNewAccounts){
            if(carrierId != null && carrierId.size()>0 && accountObj.RecordTypeId != accRecordTypeId){
                if(!Test.isRunningTest()){
                    accountObj.Preferred_Shipping_Carrier__c = carrierId[0].Id;
                }
            }
        }
        }
    }
}
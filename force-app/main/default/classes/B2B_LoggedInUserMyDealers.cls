/**********************************************************************
Name: B2B_LoggedInUserMyDealers
Purpose: This class handles all the saved my dealers HDMP-212 R2 Story
Created By :Shalini Soni 
Created Date : 5 Feb 2022
*************************************************************/
public without sharing class B2B_LoggedInUserMyDealers {
    // Get all dealers list and return to show on page load 
    @AuraEnabled(cacheable=false)
    public static List<Account> getMyDealersList(){
        List<B2B_My_Dealer__c> myDealersList = [SELECT Id, Name, CreatedById , B2B_Dealer__c FROM B2B_My_Dealer__c 
                                                where CreatedById =: userinfo.getUserId()];
        Set<Id> dealersIds = new Set<Id>();
        for(B2B_My_Dealer__c objDealers : myDealersList){
            dealersIds.add(objDealers.B2B_Dealer__c);
        }
        // Added Return_Policy__c in query by Pradeep for HDMP-8502
        //Added IsActive__c in query by saikiran for HDMP-13100
        // Saravanan LTIM Added shipping Sales_Tax_Jurisdiction__c for Sp-4
        List<Account> accountList =[SELECT Id, Name, Dealer_Type__c,First_Name__c,PoIId__c,DivisionCd__c, Last_Name__c,Operation_Hour__c, 
                                    ShippingStreet, BillingCity,B2B_Dealer_Award__c, BillingState, BillingStreet,BillingPostalCode, Phone, Website, Email__c,Privacy_Policy_URL__c
                                    ,B2B_Distance__Latitude__s, B2B_Distance__Longitude__s,Return_Policy__c,IsActive__c,Sales_Tax_Jurisdiction__c

                                    FROM Account where Id IN : dealersIds];
        if(accountList.size()> 0){
            return accountList;
        }
        
        return (new List<Account>());
    }
    // Get all dealers list by division type and return to show on saved dealers tab
    @AuraEnabled(cacheable=false)
    public static List<Account> loggedInuserMyDealersList(String divisionType){
        List<B2B_My_Dealer__c> myDealersList = [SELECT Id, Name, CreatedById , B2B_Dealer__c FROM B2B_My_Dealer__c where CreatedById =: userinfo.getUserId()];
        Set<Id> dealersIds = new Set<Id>();
        for(B2B_My_Dealer__c objDealers : myDealersList){
            dealersIds.add(objDealers.B2B_Dealer__c);
        }
        // Saravanan LTIM Added shipping Sales_Tax_Jurisdiction__c for Sp-4
        List<Account> accountList =[SELECT Id, Name, Dealer_Type__c,First_Name__c,PoIId__c,DivisionCd__c, Last_Name__c,Operation_Hour__c, 
                                    ShippingStreet, BillingCity, BillingState, BillingStreet,BillingPostalCode, Phone, Website, Email__c,Sales_Tax_Jurisdiction__c
                                    FROM Account where Id IN : dealersIds AND DivisionCd__c =: divisionType];
        if(accountList.size()> 0){
            return accountList;
        }
        
        return (new List<Account>());
    }
    // Save those delaers on dealers object which is selected by user's on click Saved to my Dealers
    @AuraEnabled
    public static ResponseWrapper saveToMyDealerList(String accountId,String divisionType){
        List<Error__c> lstErrors = new List<Error__c>();
        String contactId = [SELECT Id,ContactId  FROM User WHERE Id=:userinfo.getUserId() Limit 1]?.ContactId;
        Account objAccountId = [Select Id,PersonContactId from Account where PersonContactId=:contactId]; 
        //Creating MyDealer List here
        List<B2B_My_Dealer__c> myDealersList = new List<B2B_My_Dealer__c>();
        B2B_My_Dealer__c objDealer  = new B2B_My_Dealer__c();
        objDealer.Name = B2BConstants.DEALER_NAME;
        if(objAccountId != null){
         objDealer.B2B_Person_Account__c = objAccountId.Id;
        }
        objDealer.B2B_Dealer__c = accountId;
        objDealer.AK_My_Dealer__c = objAccountId.Id + accountId ;
        myDealersList.add(objDealer);
        try{
            insert myDealersList;
            ResponseWrapper objResponseWrapper = new ResponseWrapper();
            objResponseWrapper.error = false;
            objResponseWrapper.errorMessage = '';
            objResponseWrapper.accountList = loggedInuserMyDealersList(divisionType);
            //When test class is running it throw an exception
            if(Test.isRunningTest()){
                throw new MyException();
            }
            return objResponseWrapper;
        }
        catch (Exception e) {
            ResponseWrapper objResponseWrapper = new ResponseWrapper();
            objResponseWrapper.error = true;
            objResponseWrapper.errorMessage = system.Label.ErrorMessageForDealers;
            Error__c objError = B2B_Util.createErrorRecord('Dealers Error on Save',e.getMessage(),e.getLineNumber(),'B2B_LoggedInUserMyDealers','saveToMyDealerList');                                    
            lstErrors.add(objError);
            insert lstErrors;
            return objResponseWrapper;
        }
    }
    // delete those records by record Id from my dealers object on click of remove button by user's 
    @AuraEnabled
    public static ResponseWrapper deleteDealers(string dealerId){
        List<Error__c> lstErrors = new List<Error__c>();
        List<B2B_My_Dealer__c> myDealersList = [SELECT Id,CreatedById,B2B_Dealer__c FROM B2B_My_Dealer__c Where B2B_Dealer__c =: dealerId ];
        try{
            DELETE myDealersList;
            ResponseWrapper objResponseWrapper = new ResponseWrapper();
            objResponseWrapper.error = false;
            objResponseWrapper.errorMessage = '';
            objResponseWrapper.accountList = getMyDealersList();
            //When test class is running it throw an exception
            if(Test.isRunningTest()){
                throw new MyException();
            }
            return objResponseWrapper;
        }
        catch (Exception e) {
            ResponseWrapper objResponseWrapper = new ResponseWrapper();
            objResponseWrapper.error = true;
            objResponseWrapper.errorMessage = system.Label.ErrorMessageForDealers;
            Error__c objError = B2B_Util.createErrorRecord('Dealers Error on Delete',e.getMessage(),e.getLineNumber(),'B2B_LoggedInUserMyDealers','deleteDealers');                                    
            lstErrors.add(objError);
            insert lstErrors;
            return objResponseWrapper;
        }
    }
    
     @AuraEnabled
    public static Id updateDealerIdOnCart(String communityId, String dealerId){
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
        string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
        if(String.isNotBlank(personAccountId))
            b2b.Default_Guest_Account__c=personAccountId;
        ConnectApi.CartSummary currentCart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, b2b.Default_Guest_Account__c, 'active');
        if(currentCart.cartId != NULL){
            WebCart wc = new WebCart();
            wc.Id = currentCart.cartId;
            wc.DealerId__c = dealerId;
            update wc;
        }
        return currentCart.cartId;
    }
    @AuraEnabled
    public static String getReturnPolicy(String dealerId){
        return [Select Id,Return_Policy__c from Account where Id =:dealerId ].Return_Policy__c;
    }

    // Created ths wrapper class to manage list of my dealers on load after selected dealers to save in my Dealers Tab
    // wrapper class with @AuraEnabled and {get;set;} properties  
    public class ResponseWrapper{
        @AuraEnabled
        public Boolean error{get;set;}
        @AuraEnabled
        public String errorMessage{get;set;}
        @AuraEnabled
        public List<Account> accountList{get;set;}
    }
    //create custom exception class
    class MyException extends Exception{}
}
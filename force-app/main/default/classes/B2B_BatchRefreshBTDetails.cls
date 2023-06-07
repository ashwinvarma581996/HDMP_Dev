/*
Created By : Rajrishi Kaushik
Date : 06/07/2021
Description : This is a Batch class to update BT_Token_Details__c data by calling getRefreshToken api when the expiry date for refresh token is today.
*/

global class B2B_BatchRefreshBTDetails implements Database.Batchable<sObject>, Database.AllowsCallouts {
   
    // start method to query on BT_Token_Details__c object
    global Database.QueryLocator start(Database.BatchableContext bc)  {
        String query = 'SELECT Id, Name, AccessToken__c, RefreshToken__c, AccessTokenExpiresAt__c, RefreshTokenExpiresAT__c, Account__c, Account__r.Merchant_Id__c, Account__r.OnBoarding_Error__c FROM BT_Token_Details__c';
        query += ' WHERE RefreshTokenExpiresAT__c = today AND Account__r.Merchant_Id__c != null';
        return Database.getQueryLocator(query);
    }
    
    // execute method to run buisness logic for updating the BT_Token_Details__c data.
    global void execute(Database.BatchableContext bc, List<BT_Token_Details__c> lstBTDetails){
        List<BT_Token_Details__c> lstBTTokenDetailsUpdate = new List<BT_Token_Details__c>();
        List<Account> lstAccounts = new List<Account>();
        List<Error__c> lstErrors = new List<Error__c>();
        for(BT_Token_Details__c objBTTokenDetail : lstBTDetails){ 
            try{
                for(Integer count = 1;count <= 3; count++){
                    
                    Long beforeAPI = B2B_Util.fetchCurrentTime();
                    // call getRefreshToken API 
                    String response = B2B_BrainTreeIntegration.getRefreshToken(objBTTokenDetail.Account__r.Merchant_Id__c, objBTTokenDetail.RefreshToken__c);
                    
                    B2B_AccessTokenResponseWrapper objAccessTokenResponseWrapper = New B2B_AccessTokenResponseWrapper();           
                    objAccessTokenResponseWrapper = (B2B_AccessTokenResponseWrapper) JSON.deserialize(response, B2B_AccessTokenResponseWrapper.class);
                    system.debug('objAccessTokenResponseWrapper : '+ objAccessTokenResponseWrapper);           
                    if(objAccessTokenResponseWrapper.status == 200){ 
                        objBTTokenDetail = B2B_BrainTreeUtils.checkBTTokenDetails(objBTTokenDetail, objAccessTokenResponseWrapper);                    
                        lstBTTokenDetailsUpdate.add(objBTTokenDetail);    
                        count = 4;
                    }else if(count == 3){
                        objBTTokenDetail.Account__r.OnBoarding_Error__c = objAccessTokenResponseWrapper.errorMessage;
                        lstAccounts.add(objBTTokenDetail.Account__r);
                        Long afterAPI = B2B_Util.fetchCurrentTime();
                        Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);// to calculate duration time between before API and after API
                        String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                        Error__c errorRecord = B2B_Util.createErrorRecord(false, '', '', objBTTokenDetail.Account__c, personAccountId, '',
                                                                          'B2B_BatchRefreshBTDetails', String.valueOf(objAccessTokenResponseWrapper.status), 
                                                                          Label.B2B_Error_Type_API, '', 'execute', true, '', '', '', durationTime, Label.B2B_Severity_API, 
                                                                          'Request:'+objAccessTokenResponseWrapper.requestBody, 'Response:'+objAccessTokenResponseWrapper.responseBody);
                        lstErrors.add(errorRecord);
                    }
                }
                
            }catch(Exception ex){
               objBTTokenDetail.Account__r.OnBoarding_Error__c = ex.getMessage() +' Line Number : ' + ex.getLineNumber(); 
               lstAccounts.add(objBTTokenDetail.Account__r);
            }
        }
        System.debug('lstAccounts : '+lstAccounts);
        System.debug('lstBTTokenDetailsUpdate : '+lstBTTokenDetailsUpdate);
        //update BT_Token_Details__c data
        if(!lstBTTokenDetailsUpdate.isEmpty())
            update lstBTTokenDetailsUpdate;
        
        // update account is error in response        
        if(!lstAccounts.isEmpty())
            update lstAccounts;
        
        if(!lstErrors.isEmpty()) {
            insert lstErrors;
        }
        
    }
    
    
    //finish method
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}
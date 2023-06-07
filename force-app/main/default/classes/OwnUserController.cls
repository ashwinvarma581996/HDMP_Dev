// File Name:       OwnUserController.cls
// Summary:
// Created On:      12-16-2021
// Test Classes:    OwnUserControllerTest.cls
// Data I/O:
// Honda Jira Story: DOE-2408
//====================================================================================
// Modification Log:
//====================================================================================
public without sharing class OwnUserController{
    @AuraEnabled(cacheable = true)
    public static User getUserDetails(String userId){

        User user = [SELECT Id, FirstName, LastName, Email
                     FROM User
                     WHERE Id = :userId
                     LIMIT 1];
        return user;
    }
    @AuraEnabled
    public static String createRegistrationRecord(PE_Product_Registration__c info){

        try{
            String msg = '';
            insert info;
            msg = 'Record Created';
            return msg;
        } catch (Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }

    
    @AuraEnabled()
    public static String getEnteredState(){
   
    String AccountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]?.AccountId;
     String ac = [SELECT BillingState FROM Account WHERE Id =: AccountId  Limit  1]?.BillingState;
    return ac;
    }
     @AuraEnabled
    public static string getPersonMailingState(){
        String AccountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]?.AccountId;
        String ac = [SELECT PersonMailingState FROM Account WHERE Id =: AccountId  Limit  1]?.PersonMailingState;
        return ac;
    }
    @AuraEnabled
    public static String getUserFederationID(String userID){
        return [select id,federationIdentifier from user where id=:userid Limit 1].federationIdentifier;
    }
}
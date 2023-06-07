/******************************************************************************* 
Name: myDealers 
Business Unit: HDM
Created Date: 03-03-2022
Created By : Shalini soni
Description: This class covers test code for B2B_LoggedInUserMyDealers
******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method       | User Story 
           26-08-2022| saikiran | Added header | 
*******************************************************************************/
@isTest
public with sharing class B2B_LoggedInUserMyDealersTest {
    
    @testSetup
    public static void setup() {
        Account objAccount = B2B_TestDataFactory.createAccount(true);
        User objUser = [Select Id from User where isActive=true LIMIT 1 ];
        B2B_TestDataFactory.createCustomSetting(true,objAccount.Id,objUser.Id);
        WebStore store1 = new WebStore();
        store1=B2B_TestDataFactory.createStore(true);
    }
    @isTest 
    public static void testGetloggedInuserMyDealersList(){
        Network communityObj = [SELECT id, name FROM Network where name like 'dev%' OR  name like 'Dream%' LIMIT 1];
        Account acc  = [Select Id,DivisionCd__c From Account Limit 1];
        List<Account> dealerlist= new List<Account>();
        dealerlist = B2B_LoggedInUserMyDealers.loggedInuserMyDealersList(acc.DivisionCd__c);
        B2B_LoggedInUserMyDealers.getMyDealersList();
        B2B_LoggedInUserMyDealers.saveToMyDealerList(acc.Id,acc.DivisionCd__c);
        B2B_LoggedInUserMyDealers.deleteDealers(acc.Id);
        B2B_LoggedInUserMyDealers.getReturnPolicy(acc.Id);
        B2B_Util.createErrorRecord('Dealers Error on Delete','Error',17,'B2B_LoggedInUserMyDealers','deleteDealers');
    }
}
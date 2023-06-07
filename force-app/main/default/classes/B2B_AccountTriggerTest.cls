/**********************************************************************
Name: B2B_AccountTriggerTest
Purpose: Test class for AccountTrigger
Date : 11/03/2022
Created By : Rajrishi Kaushik
*************************************************************/

@isTest
public class B2B_AccountTriggerTest {

    @isTest
    public static void testUpdateAccount(){
      	User objUser = B2B_TestDataFactory.createUser(false);
        objUser.FirstName = 'Migration';
        insert objUser;
        
        System.runAs(objUser){    
            Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
            objAccount.Merchant_Id__c='x6q6b83wjsn28t2m';
            objAccount.PoIId__c = '205454';
            objAccount.IsActive__c = true;       
            update objAccount;
        }       
    }
}
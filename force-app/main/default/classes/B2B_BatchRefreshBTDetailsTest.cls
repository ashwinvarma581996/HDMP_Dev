/**********************************************************************
Name: B2B_BatchRefreshBTDetailsTest
Purpose: Test class for B2B_BatchRefreshBTDetails.
Date : 07/07/2021
Created By : Apoorv Garg
*************************************************************/
@isTest
public class B2B_BatchRefreshBTDetailsTest {
     @isTest
    public static void unitTest(){
        Test.startTest();
        // Create test data
       	Account testAccount = B2B_TestDataFactory.createAccount(true,'x6q6b83wjsn28t2m');
        System.debug('account' + testAccount);
        BT_Token_Details__c bt = B2B_TestDataFactory.createBTTokenDetails(true,testAccount.Id);
        List<BT_Token_Details__c> lstBTTokenDetails =new List<BT_Token_Details__c>();
		lstBTTokenDetails.add(bt);
       	System.debug('list' + lstBTTokenDetails);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        Id batchJobId = Database.executeBatch(new B2B_BatchRefreshBTDetails(), 10);
        System.debug('batchjobId' + batchJobId);
        Test.stopTest();
        Account test2 =  [SELECT ID,Name,Merchant_Id__c FROM Account WHERE Id != null limit 1 ];
        System.assert(test2.Name!=NULL);
        System.assert(test2.Merchant_Id__c!=null); 
    }
    
     @isTest
    public static void unitTest2Mock(){
        Test.startTest();
        // Create test data
   		Account testAccount = B2B_TestDataFactory.createAccount(true,'x6q6b83wjsn28t2m');
        System.debug('account' + testAccount);
        BT_Token_Details__c bt = B2B_TestDataFactory.createBTTokenDetails(true, testAccount.Id);
        List<BT_Token_Details__c> lstBTTokenDetails =new List<BT_Token_Details__c>();
		lstBTTokenDetails.add(bt);
       	System.debug('list' + lstBTTokenDetails);
        Id batchJobId = Database.executeBatch(new B2B_BatchRefreshBTDetails(), 10);
        System.debug('batchjobId' + batchJobId);
        Test.stopTest(); 
    }
    
       @isTest
    public static void unitTestNegative(){
        Test.startTest();
        // Create test data
		Account testAccount = B2B_TestDataFactory.createAccount(true,'x6q6b83wjsn28t2m');
        System.debug('account' + testAccount);
        BT_Token_Details__c bt = B2B_TestDataFactory.createBTTokenDetails(true, testAccount.Id);
        List<BT_Token_Details__c> lstBTTokenDetails =new List<BT_Token_Details__c>();
		lstBTTokenDetails.add(bt);
       	System.debug('list' + lstBTTokenDetails);
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock()); 
        Id batchJobId = Database.executeBatch(new B2B_BatchRefreshBTDetails(), 10);
        System.debug('batchjobId' + batchJobId);
        Test.stopTest();
    }
    
}
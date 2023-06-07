@isTest
public class Batch_RadioNaviRequestAuditTest {
    @testSetup static void testSetup(){
    }
    @isTest static void testMethod1(){
        Radio_Navi_Request__c radioNav = new Radio_Navi_Request__c();
            radioNav.Product_Identifier__c = '29UUA66204A054612';
            insert radioNav;
        Radio_Navi_Request_Failure__c radioNaviRequestFailure = new Radio_Navi_Request_Failure__c();
            radioNaviRequestFailure.Product_Identifier__c = '29UUA66204A054612';
            radioNaviRequestFailure.Authorization_Code_Failure_Type_Code__c ='100';
            radioNaviRequestFailure.Radio_Navi_Request_Id__c = radioNav.ID; 
            radioNaviRequestFailure.Alternate_Identifier__c =radioNav.ID+radioNaviRequestFailure.Authorization_Code_Failure_Type_Code__c;
            insert radioNaviRequestFailure;
            Datetime pastdateFail = Datetime.now().addDays(-35);
            Test.setCreatedDate(radioNaviRequestFailure.Id, pastdateFail);
        Test.startTest();
        Batch_RadioNaviRequestAudit radioNaviAudit = new Batch_RadioNaviRequestAudit();
            Database.executeBatch(radioNaviAudit);
        Test.stopTest();
    }
    @isTest static void testMethod2(){
        Radio_Navi_Request__c radioNavWithEmail = new Radio_Navi_Request__c();
            radioNavWithEmail.Product_Identifier__c = '1HGCV1F37MA028563';
            radioNavWithEmail.Email_Address__c = 'test@gmail.com';
            insert radioNavWithEmail;
            Datetime pastdate = Datetime.now().addDays(-35);
            Test.setCreatedDate(radioNavWithEmail.Id, pastdate);
        Test.startTest();
        	Batch_RadioNaviRequestAudit radioNaviAudit = new Batch_RadioNaviRequestAudit();
            Database.executeBatch(radioNaviAudit);
        Test.stopTest();
    }
}
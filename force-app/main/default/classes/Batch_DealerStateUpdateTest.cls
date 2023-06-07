@isTest
public class Batch_DealerStateUpdateTest {
     //Lakshmi HDMP-19479 Batch process to update sales tax 
    @testSetup static void testSetup(){
        Id rectypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner 1').getRecordTypeId();
        Account acntObj = new Account(Name='Test Honda Dealer', BillingState='AL',recordtypeId=rectypeId);
        insert acntObj;
    }

    @isTest static void testMethod1(){
        test.startTest();
        Batch_DealerStateUpdate dlrUpdate = new Batch_DealerStateUpdate();
        ID batchprocessid = Database.executeBatch(dlrUpdate);
        test.stopTest();
    }

    public static testMethod void testschedule() {

        Test.StartTest();
        Batch_DealerStateUpdate sh1 = new Batch_DealerStateUpdate();
        
        String sch = '0 0 4 * * ?'; 
        system.schedule('Test Dealer Status Check', sch, sh1); 
        Test.stopTest(); 
    }
         
        
         
}
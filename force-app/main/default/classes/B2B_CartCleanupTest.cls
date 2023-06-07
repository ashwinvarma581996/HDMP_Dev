@isTest
public class B2B_CartCleanupTest {
    
    /*@isTest static void test() {
        Test.startTest(); 
        //B2B_CartCleanup uca = new B2B_CartCleanup();
        
        //Id batchId = Database.executeBatch(uca);
        
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        
    }
    static testMethod void myTestMethod() {        
         test.starttest();
         B2B_CartCleanupSchedule myClass = new B2B_CartCleanupSchedule ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
    }*/
     static testMethod void myTestMethod1() {        
         test.starttest();
         B2B_ScheduleRefreshBTDetails myClass = new B2B_ScheduleRefreshBTDetails ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
    }
     static testMethod void myTestMethod2() {        
         test.starttest();
         B2B_ScheduleSettleBTTransactions myClass = new B2B_ScheduleSettleBTTransactions ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
    }
    
}
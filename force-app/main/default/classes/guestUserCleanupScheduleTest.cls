@isTest
public class guestUserCleanupScheduleTest {
    
    
    public static testMethod void testschedule() {
		Test.StartTest();
		guestUserCleanupBatchSchedule guc = new guestUserCleanupBatchSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('TestSchedule', sch, guc);
        guestUserCleanupBatchSchedule2 guc2 = new guestUserCleanupBatchSchedule2();
        String sch2 = '0 0 23 * * ?';
        system.schedule('TestSchedule2', sch2, guc2);
		Test.stopTest();
	}
}
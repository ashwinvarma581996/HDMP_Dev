/*==============================================================================================

Class Name : SystemAdminReportScheduleTest
Purpose    : This Apex Test Class is used for testing SystemAdminReportSchedule functionality.

----------------------------------------History--------------------------------------------------
VERSION         AUTHOR                          DATE                DETAIL
1.0             Pradeep Singh                27-01-2023          Initial Version

===============================================================================================*/
@isTest
private class SystemAdminReportScheduleTest {
    @isTest static void testMethod1(){
        String CRON_EXP = '0 0 20 ? * FRI *';
        Test.startTest();
        SystemAdminReportSchedule sh = new SystemAdminReportSchedule();
        system.schedule('Admin Report Scheduled Example Test', CRON_EXP, sh);
        Test.stopTest();     
    }
}
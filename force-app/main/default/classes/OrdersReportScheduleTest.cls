@isTest
private class OrdersReportScheduleTest {
    @isTest static void testMethod1(){
        String CRON_EXP = '0 0 8 ? * FRI *';
		Test.startTest();
        PageReference testPage = Page.OrderReport; 
        Test.setCurrentPage(testPage);
		OrdersReportSchedule sh = new OrdersReportSchedule();
		system.schedule('Scheduled Example Test', CRON_EXP, sh);
		Test.stopTest();     
    }
}
@isTest
public with sharing class OwnProductChooserSchedulerTest {
    @isTest public static void testScheduler() {
        OwnProductChooserScheduler scheduler = new OwnProductChooserScheduler();
        String sch = '0 0 2 * * ?';
        Test.setMock(HttpCalloutMock.class, new OwnProdChoosMockRespGen());
        System.schedule('Product Chooser Scheduler Test', sch, scheduler); 
    }
}
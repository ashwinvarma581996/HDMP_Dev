@isTest
public class OwnMyGarageUtilsTest {
    
      @isTest
    static void createErrorRecordTest(){
     Test.startTest();        
        System.enqueueJob(new OwnMyGarageUtils('MyVehicles','',0,'OwnAPIController','getMyVehicles','API',''+'requestbody','response','200'));
        Test.stopTest();
    }

}
@isTest
public class OwnConsumerProfileServiceTest {
    @isTest
    public static void getConsumerProfileTest(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new OwnConsumerProfileService_MockService());
        
        Set<OwnGarageController.VinDetails> testVins = OwnConsumerProfileService.getUserVins('0000000');
		//Set<OwnGarageController.vinDetails>
        Test.stopTest();
        // Values from OwnConsumerProfileService_MockService
		List<OwnGarageController.VinDetails> vinList = new List<OwnGarageController.VinDetails>(testVins);     
		OwnGarageController.VinDetails assertVin = new OwnGarageController.VinDetails('VINNUMBER00000003', 'A');
        
        System.assertEquals(assertVin.divisionId, vinList[0].divisionId);
		System.assertEquals(assertVin.vin, vinList[0].vin);
        System.assertEquals(4, testVins.size());
    }
}
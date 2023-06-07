@isTest
public class OwnSpecificationsControllerTest {

    //Positive Tests
    @isTest
    static void getMotorcycleSpecifications() {
		String inputModelID = 'SXS10M3J';
    String divisionId = 'M';
		String response = OwnSpecificationsController.getSpecificationsByModelID(inputModelID, divisionId);
       System.assert(response != null);
    }
    
    //Negative Tests
    @isTest
    static void getMotorcycleSpecifications_negative() {
        OwnSpecificationsController.getSpecificationsByModelID('','');
    }
}
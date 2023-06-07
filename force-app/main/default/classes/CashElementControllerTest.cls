@isTest
public class CashElementControllerTest {

    @testSetup
    public static void createTestData(){
        
        Boilerplate__c testBoilerplate = new Boilerplate__c(Name='Test Boilerplate', Status__c='Expired');
        insert testBoilerplate;
        Offers__c testOffer = new Offers__c(Name='Test Offer',Boilerplate__c=testBoilerplate.Id);
        insert testOffer;
        Offer_Eligible_Models__c offerModel = new Offer_Eligible_Models__c(Offer__c = testOffer.Id);
        insert offerModel;
        
    }
    
    @isTest
    public static void testupdateData(){
        Test.startTest();
        List<Offers__c> offer = new List<Offers__c>();
		offer = [Select Id,Dealer_Contribution__c,Conquest_Cash__c,Captive_Cash__c,Loyalty_Cash__c,Other_Captive_Cash__c,Additional_Cash__c from Offers__c];
        Boolean result = CashElementController.updateData(offer[0].Id,'100.0',200.0,300.0,400.0,500.0,600.0);
        System.assertEquals(true, result, 'Successfull');
        Test.stopTest();
    }
    @isTest
    public static void testgetData(){
        Test.startTest();
        List<Offers__c> offer = new List<Offers__c>();
		offer = [Select Id from Offers__c];
        List<Offers__c> result = new List<Offers__c>();
        result = CashElementController.getData(offer[0].Id);
        system.debug(result);
        System.assertEquals(1,result.Size(), 'Successfull');
        Test.stopTest();
    }
}
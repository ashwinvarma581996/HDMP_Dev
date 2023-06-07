@isTest
public class OwnUserControllerTest {
    @isTest static void testMethod1(){
        User userA;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        UserRole r = new UserRole(DeveloperName = 'COO', Name = 'COO');
        insert r;
        System.runAs (thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole role = [SELECT Id FROM UserRole WHERE Name='COO'];
            userA = new User(alias = 'usera', email='user@a.com', 
                             emailencodingkey='UTF-8', FirstName = 'User', lastname='A', 
                             languagelocalekey='en_US', 
                             localesidkey='en_US', profileid = p.Id, userroleid = role.Id,
                             timezonesidkey='America/Los_Angeles', 
                             username='usera@a.com');
            insert userA;
            OwnUserController.getUserDetails(userA.Id);
        }
    }
    @isTest static void testMethod2(){
        PE_Product_Registration__c pe_product_registrationObj = new PE_Product_Registration__c(
            Name = '');
        Test.startTest();
        OwnUserController.createRegistrationRecord(pe_product_registrationObj);
        Test.stopTest();
    }
    @isTest static void testMethod3(){
        OwnUserController.getEnteredState();
        OwnUserController.getPersonMailingState();
    }
}
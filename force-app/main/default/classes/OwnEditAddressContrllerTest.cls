@isTest
public with sharing class OwnEditAddressContrllerTest {
    @TestSetup
    public static void setupMethod() {
        Insert new Account(
            FirstName = 'd',
            LastName = 'test',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
            PersonEmail = 'kotu@test.com'
        );
    }

    @isTest
    public static void getInitalDataTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        OwnEditAddressContrller.getInitalData(acc.Id);
        Test.stopTest();
    }

    @isTest
    public static void updateAddressTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        OwnEditAddressContrller.updateAddress(acc);
        Test.stopTest();
    }
}
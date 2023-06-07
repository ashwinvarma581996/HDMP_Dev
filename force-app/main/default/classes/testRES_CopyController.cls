/**
 * @description       :
 * @author            : eantonsonh@gorillagroup.com
 *
 *
**/
@isTest(SeeAllData = true)
public with sharing class testRES_CopyController {
    static Id profileId;
    static User testUser;
    static User adminUser;
    static Account testAccount;
    static Contact testContact;
    static Res_Copy_Set__c testResCopy;
    static String testString;

    public static void init() {
        profileId = [Select Id From Profile Where Name ='Reservation Community User'].Id;
        List<Account> accounts = Res_TestDataFactory.createAccounts(1) ;
        testAccount = accounts[0] ;
        testContact = Res_TestDataFactory.createContact(testAccount) ;
        testUser = Res_TestDataFactory.createUsers(new List<Contact>{ testContact }, profileId)[0] ;
        // testResCopy = new Res_Copy_Set__c(
        //     Name = 'waitlist',
        //     subHeaderText__c = 'Hello',
        //     Model__c = 'MDX',
        //     headingText__c = 'Contact Info',
        //     buttonText__c = 'Submit',
        //     windowDocumentTitle__c = 'Waitlist' ,
        //     external_Key__c = 'MDX_waitlist'
        // );
        // insert testResCopy;
    }
    @isTest
    public static void testRES_CopyController() {
        init();
        Test.startTest();

        System.runAs(testUser) {
            //
            testResCopy = RES_CopyController.getSingleCopySets('MDX', False, True);
        }

        System.assertNotEquals(testResCopy, null);
        Test.stopTest();
    }
    @isTest
    public static void testRES_CopyControllerDefaultCopy() {
        init();
        Test.startTest();
        System.runAs(testUser) {
            //
            testResCopy = RES_CopyController.getSingleCopySets('SomeRandom', False, True);
        }

        System.assertNotEquals(testResCopy, null);
        Test.stopTest();
    }
}
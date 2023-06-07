@isTest
public with sharing class OwnAccountInformationControllerTest {
    @isTest
    public static void getExternalLoginDetailsTest() {
        Test.startTest();
        OwnAccountInformationController.getExternalLoginDetails();
        Test.stopTest();
    }

    @isTest
    public static void saveImageTest() {
        Test.startTest();
        OwnAccountInformationController.saveImage(UserInfo.getUserId(), 'Test', 'data:image/jpeg;base64,/9j/4AAQS', 'image/jpeg');
        Test.stopTest();
    }
}
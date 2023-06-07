/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 11-01-2021
 * @last modified by  : mbunch@gorillagroup.com
**/
@istest
public class TestRes_GenerateConfirmationPayload {

    @TestSetup
    static void makeData(){
        UserRole userRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'Honda_Owner' LIMIT 1];
		User admin = [SELECT Id, Username, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId = :userRole.Id AND isActive = true LIMIT 1];
		User user_1;
		System.runAs(admin) {
            Res_TestDataFactory.setUpReservationTest() ;
        }    }

    @IsTest
    static void testGetReturnURLByReservation(){
        Reservation__c r = [SELECT id FROM Reservation__c LIMIT 1] ;
        Test.startTest();
        String s = RES_GenerateConfirmationPayload.getReturnUrlFromReservation(r.id) ;
        Test.stopTest() ;

        System.Assert(s != null, 'Excpected non null return') ;
    }

    @IsTest
    static void testGenerateConfirmationUrls(){

        WebCart c = [SELECT id FROM WebCart LIMIT 1] ;

        Test.startTest();
        LIst<STring> s = RES_GenerateConfirmationPayload.generateConfirmationUrl(new List<STring>{ c.id}) ;
        Test.stopTest();
        System.assert(s.size() == 1, 'Excpect single element list');
    }

}
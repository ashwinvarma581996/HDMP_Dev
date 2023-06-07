@isTest
public class B2B_Logged_IN_UtilityTest {
    @isTest
    private static void testMigratedBuyerGroupId(){
        B2B_Logged_IN_Utility.getMigratedBuyerGroupID();
    }
    @isTest
    private static void testgetPersonAccountId(){
        User uid=B2B_TestDataFactory.personAccountUser(True);
        system.runAs(uid){
            B2B_Logged_IN_Utility.getPersonAccountId(uid.FederationIdentifier);
        }
    }
    
    @isTest
    Private static void testgetgetUserdetails(){
        User uid=B2B_TestDataFactory.personAccountUser(True);
        system.runAs(uid){
            B2B_Logged_IN_Utility.getUserdetails(uid.Id);
        }
        
    }
        @isTest
    Private static void testgetPersonAccountDetails(){
          User uid=B2B_TestDataFactory.personAccountUser(True);
        system.runAs(uid){
            B2B_Logged_IN_Utility.getPersonAccountDetails(uid.ContactId);
            
        }
        
    }
	
}
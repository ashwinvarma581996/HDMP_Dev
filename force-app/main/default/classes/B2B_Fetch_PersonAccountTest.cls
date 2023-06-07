@isTest
public class B2B_Fetch_PersonAccountTest {
    @istest
    public static void createSetupData(){
        User objUser=B2B_TestDataFactory.createUser(true);
        system.debug('userid'+objUser.id);
    }

}
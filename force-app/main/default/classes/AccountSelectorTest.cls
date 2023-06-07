@isTest
public class AccountSelectorTest {
    @testSetup 
    public static void setup(){
        Account acc=new Account();
       acc= B2B_TestDataFactory.createAccount(true);
        User objUser = [Select Id from User LIMIT 1];
        
    }
    @isTest 
    public static void getAccountListTest() {
       
         List<Account> accList =new List<Account>();
        accList= AccountSelector.getAccountList();
    }
    @isTest 
    public static void TestSetupExternalManagedAccount() {
        Account acc  = [Select Id From Account Limit 1];
        User objUser = [Select Id From User Limit 1];
        accountSelector.SetupExternalManagedAccount(acc.Id);
    }
}
/********************************************************************************
Name			: 	guestUserCleanupBatchTest
Purpose			: 	Test Class for guestUserCleanupBatch, guestUserCleanupBatch2.
Date 			: 	10/22/2021
Created By 		: 	Deployment User
*********************************************************************************
MODIFICATIONS – Date 		|	Dev Name		|	Method		|	User Story
*********************************************************************************
	V1			19/07/2022	|	Ravi Prasad		|				|	
********************************************************************************/
@isTest
public class guestUserCleanupBatchTest {
    
    @testSetup
    static void setup() {
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Where PortalType = 'None'  Limit 1];
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' and isactive=true Limit 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        
        System.runAs(adminUser){
            Account acc= new Account();
            acc.name='Guest Account 1';
            acc.PoIId__c='test';
            insert acc;
            
            Contact con=new Contact();
            con.LastName ='Guest Contact 1';
            con.AccountId =acc.id;
            insert con;
            
            List<Profile> plist=[Select id from Profile where name ='Honda Sites User'];
            
            User usr = new User();
            usr.LastName= 'test User';
            usr.Email='test4678@testmail.com';
            usr.Username='test4678@testmail.com';
            usr.alias='gdvd';
            usr.Contactid=con.id;
            usr.profileId=plist[0].id;
            usr.EmailEncodingKey='UTF-8';
            usr.LanguageLocaleKey='en_US';
            usr.LocaleSidKey='en_US';
            usr.TimeZoneSidKey='America/Los_Angeles';
            insert usr;
            
        }
        
    }
    @isTest static void test() {
        List<Contact> conList = [Select Id, Name From Contact];
        Test.startTest();
        guestUserCleanupBatch uca = new guestUserCleanupBatch();
        guestUserCleanupBatch2 uca1 = new guestUserCleanupBatch2();
        Id batchId = Database.executeBatch(uca);
        Id batchId1 = Database.executeBatch(uca1);
        try{
            uca1.execute(null, conList);
        }catch(Exception ex){}
        
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        
    }
}
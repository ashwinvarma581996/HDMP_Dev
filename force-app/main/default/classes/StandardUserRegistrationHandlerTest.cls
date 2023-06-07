/**********************************************************************
Name: StandardUserRegistrationHandlerTest
Business Unit:HDM
Developer : Deepak Mali
Description: This is the test class for StandardUserHandler
MODIFICATIONS- Soumya Sahoo (HDMP-6467)
MODIFICATIONS – Palak | (Added header and removal of commented code)
*************************************************************/

@isTest
private class StandardUserRegistrationHandlerTest {
    
    static testMethod void testCreateAndUpdateUser() {
        StandardUserHandler handler = new StandardUserHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'testbook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        String pid =[Select Id from Profile Where name ='Honda Sites User'].Id ;
        BuyerGroup bg=new BuyerGroup();
        bg.Name='Test';
        insert bg;
       /* B2B_Logged_In_Buyer_group__c logged_buyer=new B2B_Logged_In_Buyer_group__c();
        logged_buyer.B2B_Is_Active__c=true;
        logged_buyer.B2B_Logged_in_Buyer_GroupId__c=bg.id;
        insert logged_buyer;*/
        Map<string,String> tempUser=  new Map<String, String>
        {'language' => 'en_US' ,
            'username'=>'testaskdhjkasdj@sdjkfhsjd.com' ,
            'First Name'=>'test',
            'Last Name'=>'asdjhgasjhd',
            'Email'=>'test11@gmail.com',
            'Alias'=>'asdhagsd',
            'CommunityNickname'=>'asdjasgdjhahsdhasd',
            'TimeZoneSidKey'=>'America/Los_Angeles',
            'LocaleSidKey'=>'en_US',
            'EmailEncodingKey'=>'UTF-8',
            'ProfileId'=>pid,
            'LanguageLocaleKey'=>'en_US' }; 
                //User u = handler.createUser(null,null,null,'', tempUser ,null);
                User u = handler.createUser(null,null,null,'501543237',tempUser,null);
        	
        insert(u);
        Test.startTest();
	System.runAs(new User(Id = UserInfo.getUserId())){
            handler.updateUser(u.id,null,null,null,'501543237',tempUser,null);//added by mathi 
        
        }
        Test.stopTest();
        //sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast','testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',null, new Map<String, String>{});
        //User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid]; 
    }
}
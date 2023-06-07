@isTest
private class OwnUserHandler_Test {
    @testSetup static void setup(){
        String systemAdminProfileId =[Select Id from Profile Where name ='System Administrator'].Id ;
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'System_Administrator' Limit 1];
        
        User user = new User();
        user.ProfileID = systemAdminProfileId;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@systemAdmin01.com';   
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.UserRoleId = userrole.Id;
        insert user;
        
    }

	static testMethod void testCreateAndUpdateUser() {
        OwnUserHandler handler = new OwnUserHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'testbook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        
   		User user = [SELECT Id FROM User WHERE Username ='test@systemAdmin01.com'];
        String pid =[Select Id from Profile Where name ='Honda Sites User'].Id ;
        System.runAs(user){
            
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
                
        User u = handler.createUser(null,null,null,'501543238',tempUser,null);
                
        insert(u);
        String uid = u.id;
        
        sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast','testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',null, new Map<String, String>{});
        handler.updateUser(uid, null, null,null,'501543238', tempUser,null);
        
        User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
        
        }
    }
}
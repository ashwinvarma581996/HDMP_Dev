@isTest
private class OwnSendAnEmailFormControllerTest {
	
    @isTest
    private static void testReOpenCase(){
        OwnSendAnEmailFormController.reOpenCase(new Case__x());
    }
    
    @isTest
    private static void testShowCasesTab(){
        Boolean showCaseTab = OwnSendAnEmailFormController.showCasesTab();
        System.assertNotEquals(null, showCaseTab);
    }
    
    @isTest
    private static void testGetPersonMailingAddress(){
        
        UserRole portalRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'My Test Role', PortalType='None' );  
        insert portalRole;  
        Profile sysAdminProfile = [Select Id from Profile where name = 'System Administrator'];  
        User portalAccountOwner = new User(  
            UserRoleId = portalRole.Id,  
            ProfileId = sysAdminProfile.Id,  
            Username = 'portalOwner' + System.currentTimeMillis() + '@test.com',  
            Alias = 'Alias',  
            Email='portal.owner@test.com',
            EmailEncodingKey='UTF-8',  
            Firstname='Portal',
            Lastname='Owner',  
            LanguageLocaleKey='en_US',  
            LocaleSidKey='en_US',  
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert portalAccountOwner;
        
        System.runAs(portalAccountOwner) {
            Test.startTest();
       		Contact con = new Contact();
            con.FirstName = 'John';
            con.LastName = 'Doe';
            con.Email = 'johndoe@example.com';
            insert con;
            
            Account newAccount = new Account();
            newAccount.Name = 'Acme Inc.';
            insert newAccount;
            
            AccountContactRole newContactRole = new AccountContactRole();
            newContactRole.ContactId = con.Id;
            newContactRole.AccountId = newAccount.Id;
            newContactRole.Role = 'Primary';
            insert newContactRole;
            
            OwnSendAnEmailFormController.getPersonMailingAddress();
            Test.stopTest();
        }
    }
    
    @isTest
    private static void testGetDropdowns(){
        Map<String, Object> dropdownsMap = OwnSendAnEmailFormController.getDropdowns();
        System.assertNotEquals(null, dropdownsMap);
    }
    
    @isTest
    private static void testGetCaseComments(){
        OwnSendAnEmailFormController.getCaseComments('');
    }
    
    @isTest
    private static void testGetCaseAttachments(){
        List<ContentVersion__x> contentVersions = OwnSendAnEmailFormController.getCaseAttachments('');
        System.assertNotEquals(null, contentVersions);
    }
    
    @isTest
    private static void testGetCases(){
        List<Case__x> cases = OwnSendAnEmailFormController.getCases();
        //System.assertNotEquals(null, contentVersions);
    }
    
    @isTest
    private static void testGetCaseGetCaseByIdAndCreateCase(){
        
        Test.startTest();
        OwnSendAnEmailFormController.getCase('');
        OwnSendAnEmailFormController.getCaseById('');
        Test.setMock(HttpCalloutMock.class, new OwnSendAnEmailFormControllerTestMock());
        OwnSendAnEmailFormController.createCase((Case__x)JSON.deserialize('{"ExternalId" : "05T010000063zOyEAI"}', Case__x.class), '[{"file":{"name":"sample-pdf-file_(2)_(1) (2).pdf","documentId":"069010000028IhRAAU","contentVersionId":"068010000028HszAAE","contentBodyId":"05T010000063zOyEAI","mimeType":"application/pdf"},"label":"Add more","required":false}]');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetAccessToken(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OwnSendAnEmailFormControllerTestMock());
        OwnSendAnEmailFormController.getAccessToken();
        Test.stopTest();
    }
    
    @isTest
    private static void testGetAttachmentBody(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OwnSendAnEmailFormControllerTestMock());
        OwnSendAnEmailFormController.getAttachmentBody('');
        Test.stopTest();
    }
    
    @isTest
    private static void testCreateFeedItem(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OwnSendAnEmailFormControllerTestMock());
        OwnSendAnEmailFormController.createFeedItem('', '', '');
        Test.stopTest();
    }
    
    @isTest
    private static void testAddMoreAttachment(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OwnSendAnEmailFormControllerTestMock());
        String jsonBody = '[\n'+
            ' {\n'+
            ' "file":\n'+
            ' {\n'+
            ' "name": "sample-pdf-file_(2)_(1) (2).pdf",\n'+
            ' "documentId": "069010000028IhRAAU",\n'+
            ' "contentVersionId": "068010000028HszAAE",\n'+
            ' "contentBodyId": "05T010000063zOyEAI",\n'+
            ' "mimeType": "application/pdf"\n'+
            ' },\n'+
            ' "label": "Add more",\n'+
            ' "required": false\n'+
            ' }\n'+
        ']';
        OwnSendAnEmailFormController.addMoreAttachment(jsonBody, 'x001J00000Y3Cj8QAF');
        Test.stopTest();
    }
}
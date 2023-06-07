//****************************************************************************** 
// File Name:       PermissionGroupAssignmentHandlerTest.cls
// Summary:         Apex Class for testing PermissionGroupAssignmentHandler.cls
// Created On:      02-2-2022
// Created By:      Ravindra Ravindra (Wipro)
// Test Classes:    PermissionGroupAssignmentHandlerTest.cls
// Data I/O:        
// Honda Jira Story: DOE-4360 Site user permissions
//===============================================================================
// Modification Log: 
//*******************************************************************************
@isTest
public class PermissionGroupAssignmentHandlerTest {
    @isTest static void assignPermissionGroupTest(){
        //creating portal owner
        UserRole portalRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'My Test Role', PortalType='None' );  
        insert portalRole;  
        System.debug('portalRole is ' + portalRole);  
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
        Database.insert(portalAccountOwner);  
        System.runAs(portalAccountOwner) {
            Account act = new Account(
                Name = 'test Account' 
            ); 
            Insert act;
            
            Contact contact = new Contact(FirstName = 'john', LastName = 'doy', AccountId = act.Id);
            Insert contact;
            
            Profile comm = [SELECT Id FROM Profile WHERE Name = 'Honda Sites User'];
            
            User user = new User(
                alias = 'test123', 
                email='test123@noemail.com',
                emailencodingkey='UTF-8', 
                lastname='Testing', 
                languagelocalekey='en_US',
                localesidkey='en_US', 
                profileid = comm.Id, 
                country='United States',
                IsActive =true,
                ContactId = contact.Id,
                timezonesidkey='America/Los_Angeles', 
                username='tester@noemail.com'
            );
            Insert user;
            
        }
    }
    
}
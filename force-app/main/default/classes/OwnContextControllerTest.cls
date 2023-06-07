//*******************************************************************
// FileName		: OwnContextControllerTest.cls
// Summary		: apex test class for OwnContextController.cls
// Created On   : 07-08-2021
// Created By   : Yusuf
// Honda Jira Story: Apex class for Garage for Honda Owner Experience
// ******************************************************************
// Modification Log: 
// Aug 9, 2021 Tahir (Wipro) initial coding
// Oct 12, 2021 Yusuf (Wipro)
// December 4, 2021 Ravindra Ravindra  changed Community_Context__c to User (DOE-2477, DOE-2476, DOE-2466)
//*******************************************************************************
@isTest
public class OwnContextControllerTest { 
    @testSetup static void testSetup(){
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
            Profile comm = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User'];
            Account act = new Account(FirstName = 'test', LastName = 'Account'); 
            Insert act;
            /* Contact contact = new Contact(FirstName = 'john', LastName = 'doy', AccountId = act.Id);
            Insert contact; */
            Id contactId = [SELECT Id FROM Contact WHERE FirstName = 'test' AND LastName = 'Account'].Id;
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
                ContactId = contactId,
                timezonesidkey='America/Los_Angeles', 
                username='tester@noemail.com'
            );
            Insert user;
            // System.runAs(user) {
            Product_Model__c productModel = new Product_Model__c(Product_Division__c = 'B', Product_Model_ID__c = '00000000');
            insert productModel;
            //Create Honda product
            Id hondaAutoRecTypeId = Schema.SObjectType.Honda_Product__c.getRecordTypeInfosByDeveloperName().get('Honda_Auto').getRecordTypeId();
            Honda_Product__c product = new Honda_Product__c(
                RecordTypeId = hondaAutoRecTypeId,
                Name = 'Accord',
                Product_Identifier__c = '1HGCV2F90JA764234',
                Product_Models__c = productModel.Id
                /*                     Model_Year__c = '2021',
Model_Name__c = 'Accord2021' */ // These fields have been removed from Honda Product
            );
            Insert product;
            System.debug('product===='+product);
            Ownership__c owner = new Ownership__c(Honda_Product__c = product.Id, Product_Owner__c = act.Id, Managed__c = true,
                                                  License_Plate_Number__c = '2021 NSX',
                                                  //License_Plate_State_Name__c = 'Alaska', 
                                                  Nickname__c = '2021 NSX'
                                                 );
            Insert owner;
            System.debug('owner===='+owner);
            // Commented for DOE-2466
            //Create Community_Context
            /*   Community_Context__c communityContext = new Community_Context__c(
Name = 'Sample Context',
Make__c = 'Honda',
Model__c = 'Accord', 
Year__c = 1991,
UserId__c = UserInfo.getUserId());
insert communityContext; */
            // }
        }
    }
    
    @isTest static void getContextTest(){
        OwnContextController.Product productIds = getProduct(true);
        User testUser = [SELECT username, AccountId, Last_Visited_Product_ID__c FROM User WHERE username='tester@noemail.com' LIMIT 1];
        Honda_product__c product = [SELECT Id, Product_Identifier__c FROM Honda_product__c LIMIT 1];
        testUser.Last_Visited_Product_ID__c = product.Id;
        update testUser;
        
        Test.startTest();
        
        
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        System.runAs(testUser) {
            
            OwnContextController.Context context = OwnContextController.getContext(product.Id);
            System.assertNotEquals(null, context);
            
            // Commented for DOE-2466
            // OwnContextController.Result rs = OwnContextController.setContextMenuL1(context);
            //System.assertEquals(true, rs.isSuccess);
            // rs = OwnContextController.setContextMenuL2(context);
            //System.assertEquals(true, rs.isSuccess);
            
            OwnContextController.Result rs = OwnContextController.setProductContextUser(context);
            System.assertEquals(true, rs.isSuccess);
            rs = OwnContextController.setProductContextUser(context);
            System.assertEquals(true, rs.isSuccess);
        }       
        Test.stopTest();
        
    }
    
    
    @isTest static void testUpdateUserConnectedFlag(){
        User testUser = [SELECT username, AccountId, Last_Visited_Product_ID__c FROM User WHERE username='tester@noemail.com' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        System.runAs(testUser) {
            OwnContextController.Result context = OwnContextController.update_UserConnectedFlag('5FNRL6H81KB653128', 'A');
        }       
        Test.stopTest();
        
    }
    
    @isTest static void testGetProfilePhoto(){
        User testUser = [SELECT username, AccountId, Last_Visited_Product_ID__c FROM User WHERE username='tester@noemail.com' LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            OwnContextController.getProfilePhoto();
        }       
        Test.stopTest();
        
    }
    
    @isTest static void testUpdateUserIsKeyFeatureEnabled(){
        User testUser = [SELECT username, AccountId, Last_Visited_Product_ID__c FROM User WHERE username='tester@noemail.com' LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser) {
            OwnContextController.update_UserIsKeyFeatureEnabled(true);
        }       
        Test.stopTest();
        
    }
    
    @isTest static void testGetDivisionLogo(){
        Test.startTest();
        OwnContextController.getDivisionLogo(OwnEConfigApiHelper.HONDA_DIVISION_NAME); 
        OwnContextController.getDivisionLogo(OwnEConfigApiHelper.ACURA_DIVISION_NAME); 
        OwnContextController.getDivisionLogo(OwnEConfigApiHelper.POWERSPORTS_DIVISION_NAME); 
        OwnContextController.getDivisionLogo(OwnEConfigApiHelper.POWEREQUIPMENT_DIVISION_NAME); 
        OwnContextController.getDivisionLogo(OwnEConfigApiHelper.MARINE_DIVISION_NAME); 
        Test.stopTest();
    }
    
    @isTest static void getContextNegativeTest(){
        Honda_product__c product = [SELECT Id FROM Honda_product__c LIMIT 1];
        try{
            OwnContextController.Context testContext = new OwnContextController.Context();
            OwnContextController.Context context = OwnContextController.getContext(null);
            System.assertEquals(null, context.communityContextId);
            // Commented for DOE-2466
            // OwnContextController.Result rs = OwnContextController.setContextMenuL1(context);
            //System.assertEquals(true, rs.isSuccess);
            // rs = OwnContextController.setContextMenuL2(context);
            //System.assertEquals(true, rs.isSuccess);
            context.telematicsPlatform = 'MY13';
            OwnContextController.Result rs = OwnContextController.setProductContextUser(context);
            System.assertEquals(true, rs.isSuccess);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest static void getCommunityContextTest(){
        // Commented for DOE-2466
        // Community_Context__c communityContext = [SELECT Id, Name, Model__c FROM Community_Context__c LIMIT 1];
        user u = [SELECT AccountId,FirstName FROM User WHERE username='tester@noemail.com' LIMIT 1];
        System.runAs(u) {
            OwnContextController.Context context = OwnContextController.getCommunityContext();
            System.assertEquals(context.FirstName, u.FirstName);
        }
    }
    
    @isTest static void productClassTest(){
        OwnContextController.Product productObj = getProduct(false);
        System.assert(True, productObj != NULL);
    }
    
    private static OwnContextController.Product getProduct(Boolean vin){
        OwnContextController.Product product = new OwnContextController.Product();
        
        product.divisionId  = 'A';
        product.division    = 'Honda';
        product.year        = '2022';
        product.modelId     = '000000000';
        product.model       = 'Test Model 1';
        product.trim        = 'Test Trim';
        product.vin         = vin ? '00000000000000000' : '';
        product.productId = 'productIdTest';
        product.nickname = 'nickname Test';
        product.productModelId = 'productModelId Test';
        product.powersportsTypeId = 'powersportsTypeId Test';
        product.powersportsType = 'powersportsType Test';
        product.powerEquipmentProductId = 'powerEquipmentProductId Test';
        product.powerEquipmentProduct = 'powerEquipmentProduct Test';
        product.powerEquipmentTypeId = 'powerEquipmentTypeId Test';
        product.powerEquipmentType = 'powerEquipmentType Test';
        product.marineOutboardId = 'marineOutboardId Test';
        product.marineOutboard = 'marineOutboard Test';
        product.productDefaultImage = 'productDefaultImage Test';
        product.customerUploadedImage = 'customerUploadedImage Test';
        product.isUserImage = false;
        product.isSaved = false;
        product.isEditable = false;
        product.isDefault = false;
        product.telematicsFlag = 'telematicsFlag test';
        product.enrollment = 'enrollment test';
        product.enrollmentMethod = 'enrollmentMethod test';
        product.ownershipId = 'A';
        product.exteriorColor = 'B';
        product.exteriorColorCode = 'C';
        product.image = 'www.google.com';
        product.licenseNumber = 'E';
        product.licenseState = 'F';
        product.activeSubscription = null;
        return product;
    }
}
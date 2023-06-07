//****************************************************************************** 
// File Name:       OwnAPIControllerTest.cls
// Summary:         Test Class for OwnAPIController
// Created On:      27-12-2021
// Created By:      Arunprasad N (Wipro)
// Data I/O:        
//===============================================================================
// Modification Log: 
// December 27, 2021 Arunprasad N (Wipro) initial coding 
// January 03, 2022 Sai Kotu (Wipro) added test methods
// January 13, 2022 Yusuf (Wipro) added test methods
//*******************************************************************************

@isTest
public class OwnAPIControllerTest {
    @testsetup
    static void testSetup(){
        Profile adm = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole role1 = [SELECT Id FROM UserRole WHERE Name = 'System Administrator' LIMIT 1];
        User admin = new User (
            FirstName='admin',
            LastName='user',
            Alias = 'admin',
            Email = 'admin1@test.com',
            Username =  System.now().millisecond() + 'admin1@test.com',
            ProfileId = adm.Id,
            UserRoleId = role1.Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert admin; 
        Account act;
        System.runAs(admin){
            Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            act = new Account(
                FirstName = 'd',
                LastName = 'test',
                RecordTypeId = personAccRecTypeId,
                PersonEmail = 'kotu@test.com',
                ownerId = admin.id
            );
            Insert act;
            Account accObj = [SELECT Id, RecordTypeId, FirstName, LastName, PersonEmail, OwnerId, PersonContactId FROM Account WHERE Id = : act.Id];
            Profile comm = [SELECT Id FROM Profile WHERE Name = 'Standard Community User'];
            User user1 = new User(
                UserName = accObj.PersonEmail,
                FirstName = accObj.FirstName,
                LastName = accObj.LastName,
                Alias = 'test123',
                email = accObj.PersonEmail,
                ContactId = accObj.PersonContactId,
                ProfileId = comm.Id,
                EmailEncodingKey = 'UTF-8',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                FederationIdentifier = '301018',
                CIAMToken__c = 'AS3123'
            );
            Insert user1;
        }
        User u = [SELECT Id FROM USER WHERE Email ='kotu@test.com' LIMIT 1];
        System.runAs(admin){
            Vehicle__c vehicleObj = new Vehicle__c(
                Name = 'Test',
                Model__c = 'Test Model',
                Model_Id__c = 'Testmodel_01',
                eConfigDivisionID__c = 'A',
                Year__c = 2021,
                Trim__c = 'Test'
            );
            Insert vehicleObj;
            Product_Model__c product_modelObj = new Product_Model__c(
                Product_Model_ID__c = 'RW2H8LJNW',
                Product_Division__c = 'A',
                Product_Subdivision__c = 'Honda',
                Model_Year__c = '2020',
                Model_Name__c = 'CR-V',
                Trim__c = 'AWD EX-L');
            insert product_modelObj;
            Product_Model_Color__c product_model_colorObj = new Product_Model_Color__c(
                Name = 'a0I020000007SNL',
                Model_ID_Manufacture_Color_Code__c = 'RW2H8LJNW_R-569M',
                Manufacturer_Color_Code__c = 'R-569M',
                Exterior_Color_Name__c = 'Radiant Red Metallic',
                Thumbnail_Image_URL__c = 'https://automobiles.honda.com/-/media/Honda-Automobiles/Vehicles/2020/CR-V/AW/Medium/medium_CR-V_front_CR-V15TAWDEX-L_2020_RadiantRedMetallic_RW2H8LJNW_R-569M.png',
                Product_Model__c = product_modelObj.Id);
            insert product_model_colorObj;
            
            
            Id recTypeId = Schema.SObjectType.Honda_Product__c.getRecordTypeInfosByName().get('Acura Auto').getRecordTypeId();
            Honda_Product__c product = new Honda_Product__c(
                Name = 'a0602000002i322',
                RecordTypeId = recTypeId,
                Product_Models__c = product_modelObj.Id,
                Product_Model_Color__c = product_model_colorObj.Id,
                Product_Identifier__c = '5FNRL6H84KB764126'
            );
            Insert product;
            Account acntRecord = new Account(name = 'Abhishek',POIID__c = '12242');
            insert acntRecord;
            Ownership__c ownershipObj = new Ownership__c(
                Managed__c = true,
                Alert__c = 'Test',
              //  Radio_Navigation_Code__c = 'Test',
                License_Plate_Number__c = '01234567',
                Honda_Product__c = product.Id,
                Nickname__c = 'Nickname test',
                Product_Owner__c = act.Id,
                License_Plate_State_Name__c = 'AK',
            	Preferred_Dealer__c = acntRecord.Id);
            insert ownershipObj;
        }
        
        u.Last_Visited_Product_ID__c =[select id,name from Honda_Product__c where name='a0602000002i322' limit 1].id;
        update u;
        
    }
    
    @isTest
    static void getPhoneDataByModelIdTest(){
        OwnAPIController.PhoneDataWrapper wrap=new OwnAPIController.PhoneDataWrapper();
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            wrap=OwnAPIController.getPhoneDataByModelId('YD9H4NKNW','B');
            Test.stopTest();
        }
        system.assertEquals(true, wrap.arePhonesAvailable);
    }
    @isTest
    static void getPhoneDataByModelIdFromUserContextTest(){
        OwnAPIController.PhoneDataWrapper wrap=new OwnAPIController.PhoneDataWrapper();
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            wrap=OwnAPIController.getPhoneDataByModelId('','');
            Test.stopTest();
        }
        system.assertEquals(true, wrap.arePhonesAvailable);
    }
    
    @isTest
    static void getFeaturesByPhoneTest(){
      //  List<OwnAPIController.Feature_category> featureCategory=new List<OwnAPIController.Feature_category>();
       OwnAPIController.FeatureCategoryWrapper featureCategoryWrapper;
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            featureCategoryWrapper=OwnAPIController.getFeaturesByPhone('FC3B3GJW','107','130','5473358','A');
            Test.stopTest();
        }
        system.assertEquals(2, featureCategoryWrapper.featureCategory.size());
        system.assertEquals(true, featureCategoryWrapper.hasData);

    }
    @isTest
    static void getPairingInstructionByPhoneTest(){
      //  List<OwnAPIController.Feature_category> featureCategory=new List<OwnAPIController.Feature_category>();
       OwnAPIController.ParingDataWrapper paringDataWrapper;
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getPairingInstructionByPhone('','107','130','5473358','');
            paringDataWrapper=OwnAPIController.getPairingInstructionByPhone('FC3B3GJW','107','130','5473358','A');
            Test.stopTest();
        }
      //  system.assertEquals(2, featureCategoryWrapper.featureCategory.size());
        system.assertEquals(true, paringDataWrapper.iscompatible);
system.assertEquals(true, paringDataWrapper.isOnThePhonedata);
        system.assertEquals(true, paringDataWrapper.isFirstPhonedata);
        system.assertEquals(true, paringDataWrapper.isSubSequentdata);
    }
    
    @isTest
    static void getFeaturesByPhoneFromUserContextTest(){
       // List<OwnAPIController.Feature_category> featureCategory=new List<OwnAPIController.Feature_category>();
         OwnAPIController.FeatureCategoryWrapper featureCategoryWrapper;
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            featureCategoryWrapper=OwnAPIController.getFeaturesByPhone('','107','130','5473358','');
            Test.stopTest();
        }
        system.assertEquals(2, featureCategoryWrapper.featureCategory.size());
    }
    
    @isTest
    static void getManageSubscriptionsTest(){
        /*OwnPackage__mdt ownPackage = new OwnPackage__mdt();
        ownPackage.DeveloperName = 'Remote';
        ownPackage.Icon__c = 'utility:clear';
        ownPackage.Label = 'Remote';
        ownPackage.MasterLabel = 'Remote';
        ownPackage.Status__c = 'Not Available';*/
        OwnAPIController.Subscriptions subs=new  OwnAPIController.Subscriptions();
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            subs=OwnAPIController.getManageSubscriptions('5FNRL6H84KB764126','B');
            Test.stopTest();
        }
    }
    @isTest
    static void getManageSubscriptionsTestErrorResponse(){
        OwnAPIController.Subscriptions subs=new  OwnAPIController.Subscriptions();
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator('ManageSubscriptionsError'));
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            subs=OwnAPIController.getManageSubscriptions('5FNRL6H84KB764126','B');
            Test.stopTest();
        }
    }
    
    @isTest
    static void getManageSubscriptionsFromUserContextTest(){
        OwnAPIController.Subscriptions subs=new  OwnAPIController.Subscriptions();
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            subs=OwnAPIController.getManageSubscriptions('','');
            Test.stopTest();
        }
        OwnAPIController.VehicleInfo vinfo=subs.manageSubscriptions.vehicleInfo.get(0);
        system.assertEquals('5FNRL6H84KB764126', vinfo.VIN);
        system.assertEquals('5FNRL6H8KB', vinfo.VINHeader);
        system.assertEquals('A', vinfo.divisionCode);
        system.assertEquals('Honda', vinfo.divisionName);
        system.assertEquals('2019', vinfo.modelYear);
        system.assertEquals('RL6H8KKXW', vinfo.modelId);
        system.assertEquals('ODYSSEY TOURING', vinfo.modelCode);
        system.assertEquals('KA', vinfo.modelTypeCode);
        system.assertEquals('Touring', vinfo.modelTrimTypeCode);
        system.assertEquals(true, String.isEmpty(vinfo.factoryCode));
        system.assertEquals(true, String.isEmpty(vinfo.factoryName));
        system.assertEquals('BU', vinfo.exteriorBaseColorCode);
        system.assertEquals('Blue', vinfo.exteriorBaseColorName);
        system.assertEquals('Obsidian Blue Pearl', vinfo.exteriorMarketingColorCode);
        system.assertEquals('B-588P', vinfo.manufacturingColorCode);
        system.assertEquals('Odyssey', vinfo.modelGroupNameFriendly);
        system.assertEquals('Y', vinfo.embeddedNavi);
        system.assertEquals('Y', vinfo.telematicsFlag);
        system.assertEquals('MY17', vinfo.telematicsPlatform);
        system.assertEquals('test.png', vinfo.asset34FrontPath);
        system.assertEquals('US', vinfo.countryCoded);
        system.assertEquals('BU_TOURING_34FRONT.png', vinfo.largeFrontImage);
        system.assertEquals('Y', vinfo.enrollment);
        system.assertEquals('SELF', vinfo.enrollmentMethod);
        system.assertEquals('Y', vinfo.telematicsUnit);
        system.assertEquals('N', vinfo.ownership);
        system.assertEquals('2021-07-19 07:11:26.18', vinfo.associationDate);
        system.assertEquals('UNCONFIRMED', vinfo.relationshipStatus);
    }
    
    @isTest
    static void getFeatureListByProductIdentifierTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getFeatureListByProductIdentifier('5FNRL6H81KB653128', 'A');
            Test.stopTest();
        }
    }
    
    @isTest
    static void getFeatureListByProductIdentifierTestErrorResponse(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator('FeatureListByVinError'));
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getFeatureListByProductIdentifier('5FNRL6H81KB653128', 'A');
            Test.stopTest();
        }
    }
    
    @isTest
    static void getFeatureListByProductIdentifierFromUserContextTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getFeatureListByProductIdentifier('', '');
            Test.stopTest();
        }
    }
    @isTest
    static void getFeatureListByModelInformationTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator('FeatureListByModel'));
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            Test.startTest();
            //OwnAPIController.getFeatureListByModelInformation('','','','');
            OwnAPIController.getFeatureListByModelInformation('2022','Odyssey','RL6H8NKXW','A');
            Test.stopTest();
        }
    }
    
    @isTest
    static void getMyVehiclesTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getMyVehicles('5FNRL6H81KB653128', 'A');
            Test.stopTest();
        }
    } 
    @isTest
    static void getMyVehiclesFromUserContextTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getMyVehicles('', '');
            Test.stopTest();
        }
    } 
    
    @isTest
    static void getFeatureListByVINByPackagesTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getFeatureListByVINByPackages('', '','');
            Test.stopTest();
        }
    }
    @isTest
    static void getValidateCustomerIdentityTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getValidateCustomerIdentity('', '');
            OwnAPIController.getValidateCustomerIdentity('5FNRL6H81KB653128', 'A');
            Test.stopTest();
        }
    }
    @isTest
    static void productIdentifierLookUpTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.productIdentifierLookUp('', '');
            OwnAPIController.productIdentifierLookUp('5FNRL6H81KB653128', 'A');
            Test.stopTest();
        }
    }
    @isTest
    static void getFeatureListByModelByPackagesTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            Test.startTest();
            OwnAPIController.getFeatureListByModelByPackages('2021','Passport', '' ,'','');
            OwnAPIController.getFeatureListByModelByPackages('2021','Passport', '','A','ProductChooser');
            Test.stopTest();
        }
    }
    
    @isTest
    static void getProductByVinTest(){
        // OwnAPIController.PhoneDataWrapper wrap=new OwnAPIController.PhoneDataWrapper();
        String response = '';
        
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            response = OwnAPIController.getProductByVin('5FNRL5H95HB152304','B');
            Test.stopTest();
        }
        String expectResponse = '{"Vehicle":{"VIN":"19UDE2F76GA573669","VINHeader":"19UDE2F7GA","DivisionCode":"B","DivisionName":"ACURA","ModelYear":"2016","ModelId":"DE2F7GKNZW","ModelCode":"ILX TECH PLUS","ModelTypeCode":"KA","ModelTrimTypeCode":"with Technology Plus Package","FactoryCode":"","FactoryName":"","ExteriorBaseColorCode":"GR","ExteriorBaseColorName":"Gray","ExteriorMarketingColorCode":"Graphite Luster Metallic","ManufacturingColorCode":"NH-782MX","ModelGroupNameFriendly":"ILX","EmbeddedNavi":"Y","TelematicsFlag":"Y","TelematicsPlatform":"MY13","Asset34FrontPath":"https://www.acura.com/assets/acura/medium/2016/DE2F7GKNZW_ilxgraphitelustermetallic_nh-782m_medium.jpg","CountryCoded":"US","HeadUnit":"ODMD1","TrafficType":"IP","LargeFrontImage":"https://www.acura.com/assets/acura2/carshot/ilx/2016/carshot_ilxtechnology_2016_ilxgraphitelustermetallic_nh-782m.png","Enrollment":"N","EnrollmentMethod":"","TelematicsUnit":"Y","ProgramEligible":[],"Ownership":"Y"},"status":"SUCCESS"}';
        system.assertEquals(expectResponse, response);
    }
    @isTest
    static void getEligibleVehicleTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getEligibleVehicle('B');
            Test.stopTest();
        }
    }
    @isTest
    static void sendToMyVehiclesTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.sendToMyVehicles('','B'); 
            Test.stopTest();
        }
    }
    @isTest
    static void vinMasterSearchTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.vinMasterSearch('','B');
            OwnAPIController.Header head = new OwnAPIController.Header();
            head.code = ''; head.errorCode = ''; head.errorDescription = ''; head.errorType = ''; head.node = '';
            Test.stopTest();
        }
    }
    @isTest
    static void getBrandLineProductByDivisionTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getBrandLineProductByDivision('Honda','A');
            OwnAPIController.hasExcludedFeatures('');
            OwnAPIController.hasExcludedFeatures('A');
            Test.stopTest();
        }
    }
    @isTest
    static void getMyProfileTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getMyProfile('5FNRL5H95HB152304','A');
            Test.stopTest();
        }
    }
    @isTest
    static void getMyProfileTest1(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getMyProfile('','');
            Test.stopTest();
        }
    }
    
    @isTest
    static void getSSPSSOAcuralinkTest() {
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        String expectedResponse = '<html><head><title>Working...</title></head><body><form method="post" name="hiddenform"action="https://access-sta.telematics.net/openam/Consumer/metaAlias/acura/ACURAOP/sp"><input type="hidden"name="[SAMLResponse]"value="xxxxxx"><input type="hidden" name="RelayState" value=""><noscript><p>Script is disabled. Click Submit to continue.</p><input type="submit" value="Submit"></noscript></form><script language="javascript" type="text/javascript">window.setTimeout(function(){document.forms[0].submit();}, 0);</script></body></html>';
        OwnAPIController.SSPSSO ectualResponse;
        system.runAs(testUSer){
            Test.startTest();
            ectualResponse = OwnAPIController.getSSPSSOAcuralink('', '');
            ectualResponse = OwnAPIController.getSSPSSOAcuralink('19UDE2F76GA573669', 'B');
            Test.stopTest();
        }
        //system.assertEquals(expectedResponse, ectualResponse);
    }
    
    @isTest
    static void getSSPSSOHondalinkTest() {
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        String expectedResponse = '<html><head><title>Working...</title></head><body><form method="post" name="hiddenform"action="https://access-sta.telematics.net/openam/Consumer/metaAlias/acura/ACURAOP/sp"><input type="hidden"name="[SAMLResponse]"value="xxxxxx"><input type="hidden" name="RelayState" value=""><noscript><p>Script is disabled. Click Submit to continue.</p><input type="submit" value="Submit"></noscript></form><script language="javascript" type="text/javascript">window.setTimeout(function(){document.forms[0].submit();}, 0);</script></body></html>';
        OwnAPIController.SSPSSO  ectualResponse;
        system.runAs(testUSer){
            Test.startTest();
            ectualResponse = OwnAPIController.getSSPSSOHondalink('', '');
            ectualResponse = OwnAPIController.getSSPSSOHondalink('19UDE2F76GA573669', 'A');
            Test.stopTest();
        }
        //system.assertEquals(expectedResponse, ectualResponse);
    }

    @isTest
    static void getSSOTest() {
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        OwnAPIController.SSPSSO ectualResponse;
        system.runAs(testUSer){
            Test.startTest();
            ectualResponse = OwnAPIController.getSSO('19UDE4H6XPA320001');
            Test.stopTest();
        }
    }
    
    @isTest
    static void getPackagesByModelInformationTest() {
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getConnectedPlatforms();
            OwnAPIController.getPackagesByModelInformation('','','RL6H2KEY','');
            Test.stopTest();
        }
        
    }
    
    /* @isTest
static void updateUserTelematicsPlatformTest() {
Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
system.runAs(testUSer){
Test.startTest();
OwnAPIController.updateUserTelematicsPlatform();
Test.stopTest();
}
}*/
    
    @isTest
    static void getTrialEligibilityTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getTrialEligibility('19UDE2F76GA573669','B');
            OwnAPIController.getTrialEligibility('','');
            Test.stopTest();
        }
    }
    @isTest static void productIdentifierLookUpByProductIdTest(){
        OwnAPIController.productIdentifierLookUpByProductId('');
    }
    @isTest static void hidasTokenRevokeTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.hidasTokenRevoke();
            Test.stopTest();
        }
       
    }
    @isTest static void getMyVehicleAndMyProfileTest(){
        OwnAPIController.getMyVehicleAndMyProfile('','');
    }
    @isTest static void getAllUserVehiclesFromMyVehiclesTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getAllUserVehiclesFromMyVehicles();
            Test.stopTest();
        }
    }
    @isTest static void getProductChooserDataTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getProductChooserData('2020', 'Honda');
            OwnAPIController.getProductChooserData('2020', 'Acura');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetDealerByPoiId(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            List<Ownership__c> owners = [Select Id from Ownership__c Limit 1];
            OwnAPIController.getDealerByPoiId('7876', 'M', owners[0].Id, 'Powersports', '37.3175659179688', '-121.981178283691');
            OwnAPIController.getDealerByPoiId('7876', 'A', owners[0].Id, 'Honda', '', '');
            OwnAPIController.getDealerByPoiId('7876', 'B', owners[0].Id, 'Acura', '', '');
            OwnAPIController.getDealerByPoiId('7876', 'P', owners[0].Id, 'Powerequipment', '', '');
            OwnAPIController.getDealerByPoiId('7876', 'P', owners[0].Id, 'Marine', '', '');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetDealerLocator(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            List<Ownership__c> owners = [Select Id from Ownership__c Limit 1];
            OwnAPIController.getDealerLocator('29.82577', '-94.86014', 'M', owners[0].Id, 'Powersports');
            OwnAPIController.getDealerLocator('', '', 'M', owners[0].Id, 'Powersports');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testUpdateFavoriteDealer(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  email = 'admin1@test.com' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            List<Ownership__c> owners = [Select Id from Ownership__c Limit 1];
            OwnAPIController.updateFavoriteDealer('7876', owners[0].Id, 'XYZ');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSearchDealers(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            List<Ownership__c> owners = [Select Id from Ownership__c Limit 1]; 
            OwnAPIController.searchDealers('29.82577', '-94.86014', 'M', '', '', '', '10', owners[0].Id, 'Powersports', 'Eastside Honda','');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetManualByVIN(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getManualByVIN('FAAA-1635077', 'P', 'Powerequipment', 'FG110AT');
            OwnAPIController.getManualByVIN('', '', 'Powerequipment', 'FG110AT');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetConsumerProfileByWebUserID(){
        Test.setMock(WebServiceMock.class, new OwnConsumerProfileService_MockService());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getConsumerProfileByWebUserID();
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetRecallsByProductIdentifier(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getRecallsByProductIdentifier('5FNRL6H84KB764126', 'A');
            OwnAPIController.getRecallsByProductIdentifier('', '');
            Test.stopTest();
        }
    }
    
     @isTest
    static void testGetRecallsByModel(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getRecallsByModel('2022', 'XYZ', '', '');
            Test.stopTest();
        }
    }
    @isTest
    static void getRecallsByModelIdTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getRecallsByModelId('RL6H2NEW', 'A');
            OwnAPIController.getRecallsByModelId('', 'A');
            Test.stopTest();
        }
    }
    /*@isTest
    static void getManualIdsTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getManualIds();
            Test.stopTest();
        }
    }*/
    @isTest
    static void getProductServiceNotesTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getProductServiceNotes('','A');
            OwnAPIController.getProductServiceNotes('','B');
            Test.stopTest();
        }
    }
    @isTest
    static void getOffersTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            OwnAPIController.getOffers('');
            Test.stopTest();
        }
    }
     @isTest
    static void getCompleteDetailsTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
            Test.startTest();
            OwnAPIController.getCompleteDetails('B', '2019', 'MDX');
            Test.stopTest();
    }
    
    @isTest
    static void testGetServiceAppointments(){
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
            Test.startTest();
            OwnAPIController.getServiceAppointments('A');
            Test.stopTest();
    }
    /*@isTest
    static void testGetRadioCode(){
        	Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
            Test.startTest();
            	OwnAPIController.RadioCodeService result = OwnAPIController.getRadioCode('11113491');
        		System.assertEquals(false, result.error);
            Test.stopTest();
    }
    @isTest
    static void testGetNavigationCode(){
        	Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
            Test.startTest();
            	OwnAPIController.RadioCodeService result = OwnAPIController.getNavigationCode('CLB29001605A');
        		System.assertEquals(false, result.error);
            Test.stopTest();
    }*/
     @isTest
    static void testGetEmissionWarrantyBooklet(){
        	Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
            Test.startTest();
            	Map<String, Object> result = OwnAPIController.getEmissionWarrantyBooklet('Testmodel_01');
        		System.assertEquals(true, result != null);
            Test.stopTest();
    }
}
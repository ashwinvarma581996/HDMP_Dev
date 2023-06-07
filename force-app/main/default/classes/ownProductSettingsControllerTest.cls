@isTest
public with sharing class ownProductSettingsControllerTest {
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
                LanguageLocaleKey = 'en_US'
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
                Product_Model_ID__c = 'RM3H5GJW',
                Product_Division__c = 'A',
                Product_Subdivision__c = 'Honda',
                Model_Year__c = '2020',
                Model_Name__c = 'CR-V1',
                Trim__c = 'AWD EX-L1');
            insert product_modelObj;
            Product_Model_Color__c product_model_colorObj = new Product_Model_Color__c(
                Name = 'a0I020000007SNL',
                Model_ID_Manufacture_Color_Code__c = 'RW2H8LJNW_R-569M',
                Manufacturer_Color_Code__c = 'NH-797M',
                Exterior_Color_Name__c = 'Radiant Red Metallic',
                Thumbnail_Image_URL__c = 'https://automobiles.honda.com/-/media/Honda-Automobiles/Vehicles/2020/CR-V/AW/Medium/medium_CR-V_front_CR-V15TAWDEX-L_2020_RadiantRedMetallic_RW2H8LJNW_R-569M.png',
                Product_Model__c = product_modelObj.Id);
            insert product_model_colorObj;
            
            
            Id recTypeId = Schema.SObjectType.Honda_Product__c.getRecordTypeInfosByName().get('Acura Auto').getRecordTypeId();
            Honda_Product__c product = new Honda_Product__c(
                Name = 'a0602000002i321',
                RecordTypeId = recTypeId,
                Product_Models__c = product_modelObj.Id,
                Product_Model_Color__c = product_model_colorObj.Id,
                Product_Identifier__c = '5J6RW2H83LA011791'
            );
            Insert product;
            Ownership__c ownershipObj = new Ownership__c(
                Managed__c = true,
                Alert__c = 'Test',
              //  Radio_Navigation_Code__c = 'Test',
                License_Plate_Number__c = '01234567',
                Honda_Product__c = product.Id,
                Nickname__c = 'Nickname test',
                Product_Owner__c = act.Id,
                License_Plate_State_Name__c = 'AK');
            insert ownershipObj;
        }
        
        u.Last_Visited_Product_ID__c =[select id,name from Honda_Product__c where name='a0602000002i321' limit 1].id;
        update u;
        
    }
    
    /*
private static void getProductInfoTest(){
Honda_Product__c testProduct = new Honda_Product__c( Name='Test Product',
VIN__c='11111111111111111',
Model_Id__c='testId',
Exterior_Color__c='testColor');

insert testProduct;

Honda_Product__c testProduct2 = ownProductSettingsController.getProductInfo(testProduct.Id);

System.assertEquals(testProduct, testProduct2);
}

@isTest
private static void getStatesTest(){
List<String> stateList = new List<String>{
'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA', 'HI', 'ID', 'IL', 'IN', 'IA',
'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM',
'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'TN', 'TX', 'UT', 'VT', 'WA', 'WV', 'WI',
'WY'
};
List<SelectOptionWrapper> stateListTest = ownProductSettingsController.getStates();

System.assertEquals(stateList, stateListTest);

}
*/
    @isTest
    private static void getStatesInsuranceEligibilityTest(){
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            Map<String,boolean> stateMap=ownProductSettingsController.getStatesInsuranceEligibility();
            system.assertEquals(true,stateMap.get('ALABAMA'));
        }
    }
    @isTest
    private static void getStatesTest(){
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        List<String> stateList=new  List<String>();
        system.runAs(adminUser){
            List<ownProductSettingsController.SelectOptionWrapper> stateWrapList=ownProductSettingsController.getStates();
            for(ownProductSettingsController.SelectOptionWrapper s:stateWrapList){
                stateList.add(s.value);
            }
        }
        system.assert(stateList.contains('AL'));
    }
    
    @isTest
    private static void getProductDetailsTest(){
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            Id hondaid=[select id from Honda_Product__c where Product_Identifier__c='5J6RW2H83LA011791'].id;
            Id ownerShipid=[select id from Ownership__c where License_Plate_Number__c='01234567'].id;
            ownProductSettingsController.ProductDetailsWrapper pdWrapper=ownProductSettingsController.getProductDetails(hondaid, ownerShipid);
        }
    }
    
    @isTest
    private static void saveTest(){
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        system.runAs(adminUser){
            Test.startTest();
            Id hondaid=[select id from Honda_Product__c where Product_Identifier__c='5J6RW2H83LA011791'].id;
            Id ownerShipid=[select id from Ownership__c where License_Plate_Number__c='01234567'].id;
            String saveString=ownProductSettingsController.save(hondaid,ownerShipid,'Test','01234568','AL','Test','Test');
            List<Ownership__c> ownerShipPlateNum=[select id,License_Plate_Number__c from Ownership__c where id=:ownerShipid];
            system.assertEquals('01234568', ownerShipPlateNum.get(0).License_Plate_Number__c);
            Test.stopTest();
        }
    }
    
    
    @isTest
    private static void saveChnagesTest(){
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        system.runAs(adminUser){
            Test.startTest();
            Id hondaid=[select id from Honda_Product__c where Product_Identifier__c='5J6RW2H83LA011791'].id;
            Id ownerShipid=[select id from Ownership__c where License_Plate_Number__c='01234567'].id;
            OwnContextController.Product product=new OwnContextController.Product();
            product.productId=hondaid;
            //product.vin='5J6RW2H83LA011791';
            Id saveString=ownProductSettingsController.saveChanges(hondaid,ownerShipid,'A',product,'Test','RW2H8LJN1','5J6RW2H83LA011791','AWD EX-L1','','01234568','AL','','',true);
            Test.stopTest();
        }
    }
    @isTest
    private static void saveChangesVINTest(){
        User adminUser = [SELECT Id FROM USER WHERE Alias ='test123' LIMIT 1];
        List<Honda_Product__c> hondaProducts = [select id, Name, Product_Identifier__c from Honda_Product__c/* where Product_Identifier__c='5J6RW2H83LA011791'*/];
        List<Ownership__c> ownerships = [select id from Ownership__c where License_Plate_Number__c='01234567'];
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        system.runAs(adminUser){
            Test.startTest();
            Id hondaid = hondaProducts.get(0).Id;
            Id ownerShipId = ownerships.get(0).Id;
            OwnContextController.Product product=new OwnContextController.Product();
            product.productId=hondaid;
            String saveString=ownProductSettingsController.saveChangesVIN(hondaid,ownerShipid,'A','Test','5J6RW2H83LA011791',true,'012345678','AL');
            Test.stopTest();
        }
    }
    
    @isTest
    static void saveChangesVINTest1(){
        User adminUser = [SELECT Id FROM USER WHERE Alias ='test123' LIMIT 1];
        Honda_Product__c hondaProduct =[select Id, Product_Models__r.Product_Division__c from Honda_Product__c where Product_Identifier__c='5J6RW2H83LA011791'];
        Ownership__c ownershipObj =[select Id,Nickname__c,License_Plate_Number__c, License_Plate_State_Name__c from Ownership__c where License_Plate_Number__c='01234567'];
        //Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        Test.setMock(HttpCalloutMock.class, new OwnEConfigVinDecoder_MockService());
        system.runAs(adminUser){
            Test.startTest();
            hondaProduct.Product_Identifier__c = '';
            OwnContextController.Product product=new OwnContextController.Product();
            product.productId=hondaProduct.Id;
            String saveString=ownProductSettingsController.saveChangesVIN(hondaProduct.Id,ownershipObj.Id,hondaProduct.Product_Models__r.Product_Division__c,ownershipObj.Nickname__c,'VINNUMBER00000001',true,ownershipObj.License_Plate_Number__c,ownershipObj.License_Plate_State_Name__c);
            //Update hondaProduct;
            ownProductSettingsController.validateVIN('','');
            OwnContextController.Product prod = (OwnContextController.Product)JSON.deserialize('{ "productId": "abc", "ownershipId": "kbc", "divisionId":"A"}', OwnContextController.Product.class);
            ownProductSettingsController.fillProductModelFromProduct(prod);
            ownProductSettingsController.fillProductModelColorFromProduct(prod);
            Test.stopTest();
        }
    }
    
    @isTest
    private static void saveImageTest(){
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        system.runAs(adminUser){
            Test.startTest();
            Id hondaid=[select id from Honda_Product__c where Product_Identifier__c='5J6RW2H83LA011791'].id;
            Id ownerShipid=[select id from Ownership__c where License_Plate_Number__c='01234567'].id;
            OwnContextController.Product product=new OwnContextController.Product();
            product.productId=hondaid;
            product.vin='5J6RW2H83LA011791';
            String saveString1=ownProductSettingsController.saveImage(ownerShipid,'test','test','JPEG');
            String saveString=ownProductSettingsController.saveImage(ownerShipid,'test2','test2','JPEG');
            System.assert(!String.isEmpty(saveString));
            Test.stopTest();
        }
    }
    
    @isTest
    private static void setProductModelFromVINResponseTest(){
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            Test.startTest();
            OwnEConfigApiHelper.VinDecoderResponse testRespObj = new OwnEconfigApiHelper.VinDecoderResponse();
            testRespObj.isError = false;
            testRespObj.modelDetail = new OwnEConfigApiHelper.ModelDetail();
            testRespObj.modelDetail.vinNumber = '00000000000000000';
            testRespObj.modelDetail.year = '2021';
            testRespObj.modelDetail.modelGroupName = 'Honda Civic';
            testRespObj.modelDetail.color = new OwnEConfigApiHelper.ModelColor();

            Product_Model__c testPm1 = ownProductSettingsController.setProductModelFromVINResponse(testRespObj);

            System.assertEquals(testRespObj.modelDetail.year, testPm1.Model_Year__c);
            System.assertEquals(testRespObj.modelDetail.modelGroupName, testPm1.Model_Name__c);


            Map<String, String> divisionNames = new Map<String, String>{'Acura' => 'B', 
                                                                        'Honda' => 'A', 
                                                                        'Motorcycle/Powersports' => 'M', 
                                                                        'Powerequipment' => 'P', 
                                                                        'Marine' => 'P'};
            for (String divisionName : divisionNames.keySet()){
                OwnEConfigApiHelper.VinDecoderResponse testRespObj2 = new OwnEConfigApiHelper.VinDecoderResponse();
                testRespObj2.modelDetail = new OwnEConfigApiHelper.ModelDetail();
                testRespObj2.modelDetail.make = divisionName;
                Product_Model__c testPm2 = ownProductSettingsController.setProductModelFromVINResponse(testRespObj2);
                System.assertEquals(testRespObj2.modelDetail.make, testPm2.Product_Subdivision__c);
                System.assertEquals(divisionNames.get(testRespObj2.modelDetail.make), testPm2.Product_Division__c);
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void fillHondaProductFromProductTest(){
        User adminUser = [SELECT Id FROM USER WHERE Email ='admin1@test.com' LIMIT 1];
        system.runAs(adminUser){
            Test.startTest();
            OwnContextController.Product product = new OwnContextController.Product();
            product.vin = '00000000000000000';
            Honda_Product__c hp = ownProductSettingsController.fillHondaProductFromProduct(product);
            System.assertEquals(product.vin ,hp.Product_Identifier__c);
            Test.stopTest();
        }
    }
}
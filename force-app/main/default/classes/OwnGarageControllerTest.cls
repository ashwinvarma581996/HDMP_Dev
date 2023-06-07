//*********************************************************************
// File Name : OwnGarageControllerTest.cls
// Summary   : Test class for OwnGarageController
// Created on: 07-08-2021
// Created by: Yusuf
// Honda Jira Story: Apex class for Garage for Honda Owner Experience
// ********************************************************************
// Modification Log: 
// Oct 12, 2021 Yusuf (Wipro)
// December 16, 2021 Alex Dzhitenov Changed references to several Honda Product fields to references to 
//                                   Product Model and Product Model Color fields (DOE-3220)
//                                   Test methods may need to be rewritten to factor in lookups between Honda Product/Product Model/Product Model Color
// ***************************
@isTest
public class OwnGarageControllerTest {
    @testSetup static void testSetup(){
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
        System.runAs(admin){
            Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            Account act = new Account(
                FirstName = 'd',
                LastName = 'test',
                RecordTypeId = personAccRecTypeId,
                PersonEmail = 'test@test.com',
                ownerId = admin.id
            );
            Insert act;
            Account accObj = [SELECT Id, RecordTypeId, FirstName, LastName, PersonEmail, OwnerId, PersonContactId FROM Account WHERE Id = : act.Id];
            //Create Portal User
            Profile comm = [SELECT Id FROM Profile WHERE Name = 'Honda Sites User'];
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
                FederationIdentifier = '000000001'
            );
            Insert user1;
        }
        User u = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'MyGarage'];
    	insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        
        PermissionSetAssignment pg = [SELECT AssigneeId, Assignee.FirstName, Assignee.LastName, IsActive, PermissionSetGroupId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :u.Id LIMIT 1];

        System.debug(pg);
        System.debug([SELECT Id, Description, DeveloperName, MasterLabel FROM PermissionSetGroup WHERE Id = :pg.PermissionSetGroupId]);
        System.debug([SELECT Label, Name, Description, IsCustom FROM PermissionSet WHERE Id = :pg.PermissionSetId]);
        System.debug([SELECT FirstName, LastName FROM User WHERE Id = :pg.AssigneeId]);

        System.runAs(u){
            //create Vehicle record
            Vehicle__c vehicleObj = new Vehicle__c(
                Name = 'Test',
                Model__c = 'Test Model',
                Model_Id__c = 'Testmodel_01',
                eConfigDivisionID__c = 'A',
                Year__c = 2021,
                Trim__c = 'Test'
            );
            insert vehicleObj;
            
            
            //Create Honda product
            Id hondaAutoRecTypeId = Schema.SObjectType.Honda_Product__c.getRecordTypeInfosByDeveloperName().get('Honda_Auto').getRecordTypeId();
            Honda_Product__c product = new Honda_Product__c(
                RecordTypeId = hondaAutoRecTypeId,
                Name = 'Accord',
                Product_Identifier__c = '5FNYF7H55MB004787'
                /*                 Model_Year__c = '2021',
Model_Name__c = 'Accord2021',
Product_division__c = 'A',
Product_Subdivision__c = 'Honda',
Model_Id__c = 'Testmodel_01' */
            );
            Insert product;
        }
        
        // Create second test user, for testing add by VIN method
        System.runAs(admin){
            Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            Account act2 = new Account(
                FirstName = 'A',
                LastName = 'Test2',
                RecordTypeId = personAccRecTypeId,
                PersonEmail = 'test2@test.com',
                ownerId = admin.id
            );
            Insert act2;
            Account accObj = [SELECT Id, RecordTypeId, FirstName, LastName, PersonEmail, OwnerId, PersonContactId FROM Account WHERE Id = : act2.Id];
            //Create Portal User
            Profile comm = [SELECT Id FROM Profile WHERE Name = 'Honda Sites User'];
            User user2 = new User(
                UserName = accObj.PersonEmail,
                FirstName = accObj.FirstName,
                LastName = accObj.LastName,
                Alias = 'test222',
                email = accObj.PersonEmail,
                ContactId = accObj.PersonContactId,
                ProfileId = comm.Id,
                EmailEncodingKey = 'UTF-8',
                CommunityNickname = 'test22222',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                FederationIdentifier = '000000002'
            );
            Insert user2;
        }
    }
    @isTest static void testMethod1(){
        
        Vehicle__c vehicle = [SELECT Id, Model_Id__c,Model__c, eConfigDivisionID__c FROM Vehicle__c LIMIT 1];
        OwnGarageController.getGarageTabs();
        OwnGarageController.getGarageTabsAcura();
        OwnGarageController.getGarageTabsHonda();
        OwnGarageController.getGarageTabsMarine();
        OwnGarageController.getGarageTabsPowerEquipment();
        OwnGarageController.getGarageTabsPowersports();
        
        OwnGarageController.getDivisionAcura();
        OwnGarageController.getDivisionHonda();
        OwnGarageController.getDivisionMarine();
        OwnGarageController.getDivisionPowerEquipment();
        OwnGarageController.getDivisionPowersports();
        
        OwnGarageController.getYearsHonda();
        OwnGarageController.getYearsAcura();
        
		//
        OwnGarageController.getTypesPowerequipment('Generator');
        OwnGarageController.getTypesPowerequipment('Lawn Mower');
        OwnGarageController.getTypesPowerequipment('Pumps');
        OwnGarageController.getTypesPowerequipment('Snow Blowers');
        OwnGarageController.getTypesPowerequipment('Tillers');
        OwnGarageController.getTypesPowerequipment('Trimmers');
        
        OwnGarageController.getTypesPowersports();
        OwnGarageController.getProductsPowerequipment();
        OwnGarageController.getOutboardsMarine();
        
        OwnGarageController.getModelsHonda(2021);
        OwnGarageController.getModelsAcura(2021);

		//
		OwnGarageController.getModelsPowersports(2022);
        OwnGarageController.getModelsPowersports(2021);
        OwnGarageController.getModelsPowersports(2020);
        OwnGarageController.getModelsPowersports(2019);
        
        //
        OwnGarageController.getModelsPowerequipment(2022);
        OwnGarageController.getModelsPowerequipment(2021);
        OwnGarageController.getModelsPowerequipment(2020);
        OwnGarageController.getModelsPowerequipment(2019);
        OwnGarageController.getModelsPowerequipment(2018);
        OwnGarageController.getModelsPowerequipment(2017);
        
        
        //
        OwnGarageController.getModelsMarine(2022);
        OwnGarageController.getModelsMarine(2021);
        OwnGarageController.getModelsMarine(2020);
        OwnGarageController.getModelsMarine(2019);
        User u = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        /* System.runAs(u){
            OwnGarageController.getTrims(2021,vehicle.Model__c);
            OwnGarageController.getTrimsPowersports(2021, vehicle.Model__c);
			 OwnGarageController.getTrimsPowersports(2022, vehicle.Model__c);
			OwnGarageController.getTrimsPowersports(2020, vehicle.Model__c);
            OwnGarageController.getTrimsPowersports(2019, vehicle.Model__c);
        } */
    }
    @isTest static void testMethod2(){
        User u = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        System.runAs(u){
            Honda_product__c product = [SELECT Id FROM Honda_product__c LIMIT 1];
            product.Product_Identifier__c ='123';
            Update product;
            
            /*OwnGarageController.Garage garageObj = OwnGarageController.getGarage(product.Id);
            System.assertEquals(0, garageObj.products.size());
            try{
                OwnGarageController.Product productObj = new OwnGarageController.Product();
                productObj.vin = '123';
                garageObj.products.add(productObj);
                OwnGarageController.Result rs = OwnGarageController.addProduct(garageObj.products[0]);
            }Catch(Exception e){
            }*/
        }  
    }
    // Alexander Dzhitenov (Wipro): Commenting these out; they were written for previous versions of the 'Add Product' method, and have been replaced by
    // addProductsByVinTest and addProductsByYMTTest
    /* @isTest static void testMethod3(){
        User u = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        System.runAs(u){
            Honda_product__c product = [SELECT Id FROM Honda_product__c LIMIT 1];
            product.Product_Identifier__c = '123';
            Update product;
            Account accObj = [SELECT Id FROM Account LIMIT 1];
            //Create ownership
            Ownership__c ownership = new Ownership__c(
                NickName__c = '2021 Accord',
                Honda_Product__c = product.Id,
                Product_Owner__c = accObj.Id
            );
            Insert ownership;
            
            OwnGarageController.Garage garageObj = OwnGarageController.getGarage(product.Id);
            System.assertNotEquals(null, garageObj.products);
            System.assertEquals(garageObj.products[0].productId, product.Id);
            OwnGarageController.Result rs = OwnGarageController.addProduct(garageObj.products[0]);
            System.assertEquals(true, rs.isSuccess);
            rs = OwnGarageController.updateProduct(garageObj.products[0]);
            System.assertEquals(true, rs.isSuccess);
            rs = OwnGarageController.removeProduct(product.Id);
            System.assertEquals(true, rs.isSuccess);
        }  
    }
    @isTest static void testMethod4(){
        User u = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        System.runAs(u){
            Honda_product__c product = [SELECT Id FROM Honda_product__c LIMIT 1];
            Account accObj = [SELECT Id FROM Account LIMIT 1];
            //Create ownership
            Ownership__c ownership = new Ownership__c(
                NickName__c = '2021 Accord',
                Honda_Product__c = product.Id,
                Product_Owner__c = accObj.Id
            );
            Insert ownership;
            System.debug('product'+product);
            OwnGarageController.Garage garageObj = OwnGarageController.getGarage(product.Id);
            System.assertNotEquals(null, garageObj.products);
            System.assertEquals(garageObj.products[0].productId, product.Id);
            System.debug('garageObj'+garageObj);
            OwnGarageController.Result rs = OwnGarageController.addProduct(garageObj.products[0]);
            System.assertEquals(true, rs.isSuccess);
        }  
    } */
    @isTest static void testMethod5(){
        User u = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        
        Honda_product__c product = [SELECT Id FROM Honda_product__c LIMIT 1];
            product.Product_Identifier__c = '123';
            Update product;
            Account accObj = [SELECT Id FROM Account LIMIT 1];
        //Create ownership
            Ownership__c ownership = new Ownership__c(
                NickName__c = '2021 Accord',
                Honda_Product__c = product.Id,
                Product_Owner__c = accObj.Id,
                Verified__c = true
            );
            Insert ownership;
        System.runAs(u){
            
            
            
           // OwnGarageController.Result rs = OwnGarageController.removeProduct(product.Id);
            //System.assertEquals(true, rs.isSuccess);
        }  
    }
    @isTest static void getProductPositiveTest(){
        Honda_product__c product = [SELECT Id FROM Honda_product__c LIMIT 1];
        OwnGarageController.Product productObj =  OwnGarageController.getProduct(product.Id, 'A');
        //System.assertNotEquals(null, productObj);
        //System.assertEquals(productObj.model, product.Product_Models__r.Model_Name__c);
    }
    @isTest static void getProductNegetiveTest(){
        OwnGarageController.Product productObj =  OwnGarageController.getProduct('', '');
        System.assertEquals(null, productObj);
    }
    /*@isTest static void getProductByVINPositiveTest(){
String product =  OwnGarageController.getProductByVIN('A','123');
System.assert(String.isNotBlank(product));
}
@isTest static void getProductByYearModelTest(){
String product =  OwnGarageController.getProductByYearModel('A','Testmodel_01');
System.assert(String.isNotBlank(product));
}*/
    @isTest static void getNearbyDealersTest(){
        Test.startTest();
        Honda_product__c product = [SELECT Id FROM Honda_product__c LIMIT 1];
        //Create ownership
        Account accObj1 = [SELECT Id FROM Account LIMIT 1];
        Ownership__c ownership = new Ownership__c(
            NickName__c = '2021 Accord',
            Honda_Product__c = product.Id,
            Product_Owner__c = accObj1.Id
        );
        Insert ownership;
        List<Ownership__c> ProductList = OwnGarageController.getNearbyDealers(product.Id, '', '');
        System.assert(ProductList.size()>0);
        Test.stopTest();
    }
    
    private static OwnGarageController.Product getProduct1(Boolean vin){
        OwnGarageController.Product product = new OwnGarageController.Product();
        
        product.divisionId  = 'A';
        product.division    = 'Honda';
        product.year        = '2022';
        product.modelId     = '000000000';
        product.model       = 'Test Model 1';
        product.trim        = 'Test Trim';
        product.vin         = vin ? '00000000000000000' : '';
        product.origination = 2;
        product.color = new OwnGarageController.ModelColor();
        product.color.name = 'Test Color 1';
        product.color.mfg_color_cd = 'TE-0001';
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
        return product;
    }
    
    private static OwnGarageController.Product getProduct2(Boolean vin){
        // Same modelId as product1, but different color and vin
        OwnGarageController.Product product = new OwnGarageController.Product();
        
        product.divisionId  = 'A';
        product.division    = 'Honda';
        product.year        = '2022';
        product.modelId     = '000000000';
        product.model       = 'Test Model 1';
        product.trim        = 'Test Trim';
        product.vin         = vin ? '00000000000000002' : '';
        product.origination = 2;
        product.color = new OwnGarageController.ModelColor();
        product.color.name  = 'Test Color 2';
        product.color.mfg_color_cd = 'TE-0002';
        
        return product;
    }
    
    private static OwnGarageController.Product getProduct3(Boolean vin){
        // Same color as product2, but different modelId, division, and vin
        OwnGarageController.Product product = new OwnGarageController.Product();
        
        product.divisionId  = 'B';
        product.division    = 'Acura';
        product.year        = '2020';
        product.modelId     = '000000003';
        product.model       = 'Test Model 3';
        product.trim        = 'Test Trim 3';
        product.vin         = vin ? '00000000000000003' : '';
        product.origination = 2;
        product.color = new OwnGarageController.ModelColor();
        product.color.name = 'Test Color 2';
        product.color.mfg_color_cd = 'TE-0002';
        
        return product;
    }
    
    private static OwnGarageController.Product getProduct4(Boolean vin){
        // Same modelId as product1, but different color and vin
        OwnGarageController.Product product = new OwnGarageController.Product();
        
        product.divisionId  = 'A';
        product.division    = 'Honda';
        product.year        = '2022';
        product.modelId     = '000000004';
        product.model       = 'Test Model 1';
        product.trim        = 'Test Trim';
        product.vin         = vin ? '00000000000000004' : '';
        product.origination = 2;
        product.color = new OwnGarageController.ModelColor();
        product.color.name  = 'Test Color 2';
        product.color.mfg_color_cd = 'TE-0002';
        
        return product;
    }
    
    @isTest static void addProductsByVINTest(){
        
        // Test adding new product for a user
        OwnGarageController.Product product = getProduct1(true);
        
        User u = [SELECT Id, AccountId FROM USER WHERE Email = 'test@test.com' LIMIT 1];
        System.runAs(u){
            OwnGarageController.addProductsByVin(new List<OwnGarageController.Product>{product}, u.AccountId);
        }
        
        Account uAcc = [SELECT Id FROM Account WHERE PersonEmail = 'test@test.com'];
        
        List<Ownership__c> oL = [SELECT Ownership_Origination__c, Honda_Product__c, Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__c, Honda_Product__r.Product_Model_Color__c,
                                 Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c,
                                 Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c,
                                 Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c
                                 FROM Ownership__c WHERE Product_Owner__c = :uAcc.Id];
        
        Ownership__c oTest = new Ownership__c();
        
        for (Ownership__c o : oL){
            if (o.Honda_Product__r.Product_Identifier__c == '00000000000000000'){
                oTest = o;
            }
        }
        
        // Verify that product details are correct
        System.assertEquals('00000000000000000', oTest.Honda_Product__r.Product_Identifier__c, 'Product with test VIN not found for test user test@test.com');
        System.assertEquals('A', oTest.Honda_Product__r.Product_Models__r.Product_Division__c);
        System.assertEquals('Honda', oTest.Honda_Product__r.Product_Models__r.Product_Subdivision__c);
        System.assertEquals('2022', oTest.Honda_Product__r.Product_Models__r.Model_Year__c);
        //System.assertEquals('Test Model 1', oTest.Honda_Product__r.Product_Models__r.Model_Name__c);
        //System.assertEquals('Test Model 1 Test Trim', oTest.Honda_Product__r.Product_Models__r.Model_Name__c);
        System.assertEquals('000000000', oTest.Honda_Product__r.Product_Models__r.Product_Model_Id__c);
        //System.assertEquals('Test Trim', oTest.Honda_Product__r.Product_Models__r.Trim__c);
        //System.assertEquals(null, oTest.Honda_Product__r.Product_Models__r.Trim__c);
        System.assertEquals('Test Color 1', oTest.Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c);
        System.assertEquals('TE-0001', oTest.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c);
        System.assertEquals('2', oTest.Ownership_Origination__c); //addProductByVin method is designed specifically for use in LWC; origination should always be set to '2' (Standard web product added)
        
        // Test adding new product with same modelId, but different VIN and Manufacturer Color Code - HP and PMC records should be different, but
        // PM record should be reused
        OwnGarageController.Product product2 = getProduct4(true);
        
        // Test adding new product with entirely different parameters, but identicaly Manufacturer Color Code (SF record should not be reused, as the
        // modelId + Manufacturer color code combination is different)
        OwnGarageController.Product product3 = getProduct3(true);
        
        // Test inserting list of products
        System.runAs(u){
            OwnGarageController.addProductsByVin(new List<OwnGarageController.Product>{product2, product3}, u.AccountId);
        }
        
        List<Ownership__c> oL2 = [SELECT Ownership_Origination__c, Honda_Product__c, Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__c, Honda_Product__r.Product_Model_Color__c,
                                  Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c,
                                  Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c,
                                  Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c
                                  FROM Ownership__c WHERE Product_Owner__c = :uAcc.Id];
        
        Ownership__c oTest2 = new Ownership__c();
        Ownership__c oTest3 = new Ownership__c();
        
        for (Ownership__c o : oL2){
            if (o.Honda_Product__r.Product_Identifier__c == '00000000000000004'){
                oTest2 = o;
            }
            else if (o.Honda_Product__r.Product_Identifier__c == '00000000000000003'){
                oTest3 = o;
            }
        }
        
        // Verify that existing Product Model record was reused for new product with matching Model ID
        //System.assertEquals(oTest.Honda_Product__r.Product_Models__c, oTest2.Honda_Product__r.Product_Models__c);
        
        // Verify that new details for the same product are correct
        System.assertEquals('Test Color 2', oTest2.Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c);
        System.assertEquals('TE-0002', oTest2.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c);
        
        // Verify that third product did not reuse details from first product
        System.assertNotEquals(oTest.Honda_Product__r.Product_Models__c, oTest3.Honda_Product__r.Product_Models__c);
        System.assertNotEquals(oTest2.Honda_Product__r.Product_Model_Color__c, oTest3.Honda_Product__r.Product_Model_Color__c);
        
        // Verify that third product's details are correct
        System.assertEquals('B', oTest3.Honda_Product__r.Product_Models__r.Product_Division__c);
        System.assertEquals('Acura', oTest3.Honda_Product__r.Product_Models__r.Product_Subdivision__c);
        System.assertEquals('2020', oTest3.Honda_Product__r.Product_Models__r.Model_Year__c);
        //System.assertEquals('Test Model 3', oTest3.Honda_Product__r.Product_Models__r.Model_Name__c); 
        //System.assertEquals('Test Model 3 Test Trim 3', oTest3.Honda_Product__r.Product_Models__r.Model_Name__c); // Setting model name to concatenate model + trim for consistency with Product Chooser API response
        System.assertEquals('000000003', oTest3.Honda_Product__r.Product_Models__r.Product_Model_Id__c);
        //System.assertEquals('Test Trim 3', oTest3.Honda_Product__r.Product_Models__r.Trim__c);
        //System.assertEquals(null, oTest3.Honda_Product__r.Product_Models__r.Trim__c); // Setting model name to concatenate model + trim for consistency with Product Chooser API response
        System.assertEquals('Test Color 2', oTest3.Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c);
        System.assertEquals('TE-0002', oTest3.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c);
        System.assertEquals('2', oTest3.Ownership_Origination__c);
        
        
        // Verify that two users are able to own a product with the same VIN
        User u2 = [SELECT Id, AccountId FROM USER WHERE Email = 'test2@test.com' LIMIT 1];
        
        System.runAs(u2){
            OwnGarageController.addProductsByVin(new List<OwnGarageController.Product>{product3}, u2.AccountId);
        }
        
        Account u2Acc = [SELECT Id FROM Account WHERE PersonEmail = 'test2@test.com'];
        
        List<Ownership__c> oL3 = [SELECT Ownership_Origination__c, Honda_Product__c, Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__c, Honda_Product__r.Product_Model_Color__c,
                                  Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c,
                                  Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c,
                                  Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c
                                  FROM Ownership__c WHERE Product_Owner__c = :u2Acc.Id];
        
        Ownership__c oTest4 = new Ownership__c();
        
        for (Ownership__c o : oL3){
            if (o.Honda_Product__r.Product_Identifier__c == '00000000000000003'){
                oTest4 = o;
            }
        }
        
        // Verify that second user's HP with VIN matching product3 is the same HP record that is used by the first user
        System.assertEquals(oTest4.Honda_Product__c, oTest3.Honda_Product__c);
        
        // Verify that a user is not able to run the same VIN twice
        
        Boolean duplicateExceptionThrown = false;
        
        System.runAs(u){
            try{
                OwnGarageController.addProductsByVin(new List<OwnGarageController.Product>{product2, product3}, u.AccountId);
            }
            catch (OwnGarageController.DuplicateException e){
                duplicateExceptionThrown = true;
            }
        }
        System.assert(duplicateExceptionThrown);
    }
    
    
    @isTest static void removeProductTest(){
        OwnGarageController.Product product = getProduct1(true);
        
        String testVin1 = product.vin;
        
        
        User u = [SELECT Id, AccountId FROM USER WHERE Email = 'test@test.com' LIMIT 1];
        System.runAs(u){
            OwnGarageController.addProductsByVin(new List<OwnGarageController.Product>{product}, u.AccountId);
        }
        
        Account uAcc = [SELECT Id FROM Account WHERE PersonEmail = 'test@test.com'];
        
        List<Ownership__c> oL = [SELECT Id, Honda_Product__c, Managed__c, Honda_Product__r.Product_Identifier__c
                                 FROM Ownership__c WHERE Product_Owner__c = :uAcc.Id];
        
        Ownership__c oTest = new Ownership__c();
        
        for (Ownership__c o : oL){
            if (o.Honda_Product__r.Product_Identifier__c == testVin1){
                oTest = o;
            }
        }
        System.assertEquals(true, oTest.Managed__c);
        
        Test.setMock(HttpCalloutMock.class, new OwnMyVehicleHttpCalloutMock());
        
        System.runAs(u){
            OwnGarageController.Result res = OwnGarageController.removeProduct(oTest.Honda_Product__c);
        }
        oL = [SELECT Id, Honda_Product__c, Managed__c, Honda_Product__r.Product_Identifier__c
              FROM Ownership__c WHERE Product_Owner__c = :uAcc.Id];
        
        oTest = new Ownership__c();
        
        for (Ownership__c o : oL){
            if (o.Honda_Product__r.Product_Identifier__c == testVin1){
                oTest = o;
            }
        }
        System.assertEquals(false, oTest.Managed__c);
        
        // Add the same product again, ensure that the previous ownership was set back to "true"
        System.runAs(u){
            OwnGarageController.addProductsByVin(new List<OwnGarageController.Product>{product}, u.AccountId);
        }
        
        oL = [SELECT Id, Honda_Product__c, Managed__c FROM Ownership__c WHERE Id = :oTest.Id];
        
        System.assertEquals(true, oL[0].Managed__c);
        
        // Ensure that no new ownerships were added, either
        oL = [SELECT Id, Honda_Product__c, Managed__c FROM Ownership__c WHERE Product_Owner__c = :uAcc.Id AND Honda_Product__r.Product_Identifier__c = :testVin1];
        
        System.assertEquals(1, oL.size());
    }
    
    @isTest static void vinDetailsTest(){
        OwnGarageController.VinDetails vd = new OwnGarageController.VinDetails('a','b');
    }
    
	@isTest static void checkFirstTimeUserTest(){
        User u = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        System.runAs(u){
           OwnGarageController.checkFirstTimeUser();
        }
    }
    
    @isTest static void checkUserGarageForVINTest(){
        User u = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        System.runAs(u){
           OwnGarageController.checkUserGarageForVIN('1234567890abcdfgh');
        }
    }

    @isTest static void getProductByYearModelTest(){
        
		List<Vehicle__c> lvc = OwnGarageController.getProductByYearModel('A', 'Testmodel_01');
		//Testmodel_01,A
    }

	/*@isTest static void handleUserLoginTest(){
        User u = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        System.runAs(u){

			//String b = OwnGarageController.handleUserLogin(true);
        }
    }*/
    

    @isTest static void addProductYMTTest(){
        OwnGarageController.Product product = getProduct1(false);
        
        System.debug(product);
        
        User u = [SELECT Id, AccountId FROM USER WHERE Email = 'test@test.com' LIMIT 1];
        System.runAs(u){
            OwnGarageController.addProduct(product);
        }
        
        Account uAcc = [SELECT Id FROM Account WHERE PersonEmail = 'test@test.com'];
        
        List<Ownership__c> oL = [SELECT Ownership_Origination__c, Honda_Product__r.Product_Identifier__c, Honda_Product__c, Honda_Product__r.Product_Models__c, Honda_Product__r.Product_Model_Color__c,
                                 Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c,
                                 Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c,
                                 Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c
                                 FROM Ownership__c WHERE Product_Owner__c = :uAcc.Id];
        
        Ownership__c oTest = new Ownership__c();
        
        for (Ownership__c o : oL){
            if (o.Honda_Product__r.Product_Models__r.Product_Model_Id__c == '000000000' && o.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c == 'TE-0001'){
                oTest = o;
            }
        }
        
        System.assertEquals('000000000', oTest.Honda_Product__r.Product_Models__r.Product_Model_Id__c, 'Product with test modelId not found for test user test@test.com');
        System.assertEquals('TE-0001', oTest.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c, 'Product with test manufacturer color code not found for test user test@test.com');
        
        
        System.assertEquals('A', oTest.Honda_Product__r.Product_Models__r.Product_Division__c);
        System.assertEquals('Honda', oTest.Honda_Product__r.Product_Models__r.Product_Subdivision__c);
        System.assertEquals('2022', oTest.Honda_Product__r.Product_Models__r.Model_Year__c);
        //System.assertEquals('Test Model 1 Test Trim', oTest.Honda_Product__r.Product_Models__r.Model_Name__c);
        //System.assertEquals('Test Trim', oTest.Honda_Product__r.Product_Models__r.Trim__c);
        System.assertEquals(null, oTest.Honda_Product__r.Product_Identifier__c);
        System.assertEquals('Test Color 1', oTest.Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c);
        System.assertEquals('2', oTest.Ownership_Origination__c); //addProductByVin method is designed specifically for use in LWC; origination should always be set to '2' (Standard web product added)
        
        
        // Test adding multiple vehicles with various combinations of matching modelId/Manufacturer Color Code
        
        // Same modelId as product1, but different color
        OwnGarageController.Product product2 = getProduct4(false);
        
        OwnGarageController.Product product3 = getProduct3(false);
        
        System.runAs(u){
            OwnGarageController.addProductsByYMT(new List<OwnGarageController.Product>{product2, product3}, u.AccountId);
        }
        
        List<Ownership__c> oL2 = [SELECT Ownership_Origination__c, Honda_Product__r.Product_Identifier__c, Honda_Product__c, Honda_Product__r.Product_Models__c, Honda_Product__r.Product_Model_Color__c,
                                  Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c,
                                  Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c,
                                  Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c
                                  FROM Ownership__c WHERE Product_Owner__c = :uAcc.Id];
        
        Ownership__c oTest2 = new Ownership__c();
        Ownership__c oTest3 = new Ownership__c();
        
        for (Ownership__c o : oL2){
            if (o.Honda_Product__r.Product_Models__r.Product_Model_Id__c == '000000004' && o.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c == 'TE-0002'){
                oTest2 = o;
            }
            else if (o.Honda_Product__r.Product_Models__r.Product_Model_Id__c == '000000003' && o.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c == 'TE-0002'){
                oTest3 = o;
            }
        }
        
        System.assertEquals('000000004', oTest2.Honda_Product__r.Product_Models__r.Product_Model_Id__c, 'Product with test modelId not found for test user test@test.com');
        System.assertEquals('TE-0002', oTest2.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c, 'Product with test manufacturer color code not found for test user test@test.com');
        
        System.assertEquals('A', oTest2.Honda_Product__r.Product_Models__r.Product_Division__c);
        System.assertEquals('Honda', oTest2.Honda_Product__r.Product_Models__r.Product_Subdivision__c);
        System.assertEquals('2022', oTest2.Honda_Product__r.Product_Models__r.Model_Year__c);
        //System.assertEquals(oTest.Honda_Product__r.Product_Models__c, oTest2.Honda_Product__r.Product_Models__c); // Verify that PM record was re-used for products with matching modelId
        
        System.assertEquals(null, oTest2.Honda_Product__r.Product_Identifier__c);
        System.assertEquals('Test Color 2', oTest2.Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c);
        System.assertEquals('2', oTest2.Ownership_Origination__c);
        
        
        System.assertEquals('000000003', oTest3.Honda_Product__r.Product_Models__r.Product_Model_Id__c, 'Product with test modelId not found for test user test@test.com');
        System.assertEquals('TE-0002', oTest3.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c, 'Product with test manufacturer color code not found for test user test@test.com');
        
        System.assertEquals('B', oTest3.Honda_Product__r.Product_Models__r.Product_Division__c);
        System.assertEquals('Acura', oTest3.Honda_Product__r.Product_Models__r.Product_Subdivision__c);
        System.assertEquals('2020', oTest3.Honda_Product__r.Product_Models__r.Model_Year__c);
        //System.assertEquals('Test Model 3 Test Trim 3', oTest3.Honda_Product__r.Product_Models__r.Model_Name__c);
        //System.assertEquals(null, oTest3.Honda_Product__r.Product_Models__r.Trim__c);
        System.assertEquals(null, oTest3.Honda_Product__r.Product_Identifier__c);
        System.assertEquals('Test Color 2', oTest3.Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c);
        System.assertEquals('2', oTest3.Ownership_Origination__c);
        
        
        // Test adding a product with the same modelId + manufacturer color code combination for a different user - same HP record should be used.
        User u2 = [SELECT Id, AccountId FROM USER WHERE Email = 'test2@test.com' LIMIT 1];
        
        System.runAs(u2){
            OwnGarageController.addProductsByYMT(new List<OwnGarageController.Product>{product}, u2.AccountId);
        }
        
        Account u2Acc = [SELECT Id FROM Account WHERE PersonEmail = 'test2@test.com'];
        
        List<Ownership__c> oL3 = [SELECT Ownership_Origination__c, Honda_Product__r.Product_Identifier__c, Honda_Product__c, Honda_Product__r.Product_Models__c, Honda_Product__r.Product_Model_Color__c,
                                  Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c,
                                  Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c,
                                  Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c
                                  FROM Ownership__c WHERE Product_Owner__c = :u2Acc.Id];
        
        Ownership__c oTest4 = new Ownership__c();
        
        for (Ownership__c o : oL3){
            if (o.Honda_Product__r.Product_Models__r.Product_Model_Id__c == '000000000' && o.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c == 'TE-0001'){
                oTest4 = o;
            }
        }
        
        System.assertEquals(oTest.Honda_Product__c, oTest4.Honda_Product__c);
    }
    
    @isTest static void fillProductFromVinTest() {
       // Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
       	Test.setMock(HttpCalloutMock.class, new OwnEConfigVinDecoder_MockService());
        User testUSer = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        system.runAs(testUSer) {
            Test.startTest();
            OwnGarageController.fillProductFromVin('','B');
            Test.stopTest();
        }
     //   OwnGarageController.fillProductFromVin('','B');
    }
    
    @isTest static void handleUserLoginTest() {
        Honda_product__c product = [SELECT Id FROM Honda_product__c LIMIT 1];
        Account accObj1 = [SELECT Id FROM Account LIMIT 1];
        Ownership__c ownership = new Ownership__c(
            NickName__c = '2021 Accord',
            Honda_Product__c = product.Id,
            Product_Owner__c = accObj1.Id,
            Managed__c = true
        );
        Insert ownership;
        
        Test.setMock(HttpCalloutMock.class, new OwnApiCalloutMock());
        Test.setMock(HttpCalloutMock.class, new OwnMyVehicleHttpCalloutMock());
        Test.setMock(HttpCalloutMock.class, new OwnEConfigVinDecoder_MockService()); 
        User testUSer = [SELECT Id FROM USER WHERE Email ='test@test.com' LIMIT 1];
        system.runAs(testUSer) {
            Test.startTest();
            OwnGarageController.LoginHandlerWrapper loginWrapper = OwnGarageController.handleUserLogin(true);
            System.debug('loginWrapper  :-  '+loginWrapper);
            //System.assertEquals(0, loginWrapper.garageProducts.products.size());
            //System.assertEquals(0, loginWrapper.garageProducts.products.size());
            Test.stopTest();
        }
    }
}
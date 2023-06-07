//****************************************************************************** 
// File Name:       OwnProductControllerTest.cls
// Summary:         Tes Class for ownProductController
// Created On:      26-12-2021
// Created By:      Imtiyaz K.
//*******************************************************************************
//// Modification Log: 
// December 26, 2021 Imtiyaz K initial coding 
// January 04, 2021 Sai Kotu (Wipro) added test setup and getProductContextTest method
//*******************************************************************************

@isTest 
private class OwnProductControllerTest {
    @testsetup
    static void testSetup(){
        Profile adm = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole role1 = [SELECT Id FROM UserRole WHERE Name = 'System Administrator' LIMIT 1];
        User admin = new User (
            FirstName='admin',
            LastName='user',
            Alias = 'admin',
            Email = 'admin1@test.com',
            Username =  System.now().millisecond() + 'admin1312@test.com',
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
            Product_Model_Color__c product_model_colorObj = new Product_Model_Color__c(
                Name = 'a0I020000007SNL',
                Model_ID_Manufacture_Color_Code__c = 'RW2H8LJNW_R-569M',
                Manufacturer_Color_Code__c = 'R-569M',
                Exterior_Color_Name__c = 'Radiant Red Metallic',
                Thumbnail_Image_URL__c = 'https://automobiles.honda.com/-/media/Honda-Automobiles/Vehicles/2020/CR-V/AW/Medium/medium_CR-V_front_CR-V15TAWDEX-L_2020_RadiantRedMetallic_RW2H8LJNW_R-569M.png'
                /*Product_Model__c = 'a02020000019GrRAAU'*/);
            insert product_model_colorObj;
            Product_Model__c product_modelObj = new Product_Model__c(
                Product_Model_ID__c = 'RW2H8LJN1',
                Product_Division__c = 'A',
                Product_Subdivision__c = 'Honda',
                Model_Year__c = '2020',
                Model_Name__c = 'CR-V1',
                Trim__c = 'AWD EX-L1');
            insert product_modelObj;
            
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
             //   Radio_Navigation_Code__c = 'Test',
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
    
    @isTest
    static void getProductContextTest(){
        OwnProductController.Context context=new OwnProductController.Context();
        User testUSer = [SELECT Id FROM USER WHERE  alias='test123' LIMIT 1];
        system.runAs(testUSer){
            Test.startTest();
            context=OwnProductController.getProductContext('');
            Test.stopTest();
        }
        system.assertEquals('A', context.product.divisionId);
    }
    @isTest
    static void testMethod1(){
        Profile adm = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole role1 = [SELECT Id FROM UserRole WHERE Name = 'System Administrator' LIMIT 1];
        User admin = new User (
            FirstName='admin',
            LastName='user',
            Alias = 'admin',
            Email = 'admin1@test.com',
            Username =  System.now().millisecond() + 'admin1121@test.com',
            ProfileId = adm.Id,
            UserRoleId = role1.Id,
            TimeZoneSidKey = 'GMT',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        );
        insert admin; 
        new OwnProductController.Context();
        new OwnProductController.Context(admin, new OwnProductController.Product());
        System.runAs(admin){
            Product_Model_Color__c product_model_colorObj = new Product_Model_Color__c(
                Name = 'a0I020000007SNL',
                Model_ID_Manufacture_Color_Code__c = 'RW2H8LJNW_R-569M',
                Manufacturer_Color_Code__c = 'R-569M',
                Exterior_Color_Name__c = 'Radiant Red Metallic',
                Thumbnail_Image_URL__c = 'https://automobiles.honda.com/-/media/Honda-Automobiles/Vehicles/2020/CR-V/AW/Medium/medium_CR-V_front_CR-V15TAWDEX-L_2020_RadiantRedMetallic_RW2H8LJNW_R-569M.png'
                /*Product_Model__c = 'a02020000019GrRAAU'*/);
            insert product_model_colorObj;
            Product_Model__c product_modelObj = new Product_Model__c(
                Product_Model_ID__c = 'RW2H8LJNW',
                Product_Division__c = 'A',
                Product_Subdivision__c = 'Honda',
                Model_Year__c = '2020',
                Model_Name__c = 'CR-V',
                Trim__c = 'AWD EX-L');
            insert product_modelObj;
            Id recTypeId = Schema.SObjectType.Honda_Product__c.getRecordTypeInfosByName().get('Acura Auto').getRecordTypeId();
            Honda_Product__c honda_productObj = new Honda_Product__c(
                Name = 'a0602000002i322',
                RecordTypeId = recTypeId,
                Product_Models__c = product_modelObj.Id,
                Product_Model_Color__c = product_model_colorObj.Id,
                Product_Identifier__c = '5J6RW2H83LA011790');
            insert honda_productObj;
            Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            Account act = new Account(
                FirstName = 'I',
                LastName = 'Ansari',
                RecordTypeId = personAccRecTypeId,
                PersonEmail = 'ansari@test.com'
            );
            Insert act;
            Ownership__c ownershipObj = new Ownership__c(
                Managed__c = true,
                Alert__c = 'Test',
              //  Radio_Navigation_Code__c = 'Test',
                License_Plate_Number__c = '01234567',
                Honda_Product__c = honda_productObj.Id,
                Nickname__c = 'Nickname test',
                Product_Owner__c = act.Id,
                License_Plate_State_Name__c = 'AK');
            insert ownershipObj;
            OwnProductController.getProductContext('');
            OwnProductController.getProductContext(honda_productObj.Id);
            OwnProductController.getMyProducts(honda_productObj.Id);
            OwnProductController.getProductTabs();
        }
    }
    @isTest
    static void testMethod2(){
        Product_Model_Color__c product_model_colorObj = new Product_Model_Color__c(
            Name = 'a0I020000007SNL',
            Model_ID_Manufacture_Color_Code__c = 'RW2H8LJNW_R-569M',
            Manufacturer_Color_Code__c = 'R-569M',
            Exterior_Color_Name__c = 'Radiant Red Metallic',
            Thumbnail_Image_URL__c = 'https://automobiles.honda.com/-/media/Honda-Automobiles/Vehicles/2020/CR-V/AW/Medium/medium_CR-V_front_CR-V15TAWDEX-L_2020_RadiantRedMetallic_RW2H8LJNW_R-569M.png'/*,
            Product_Model__c = 'a02020000019GrRAAU'*/);
        insert product_model_colorObj;
        Product_Model__c product_modelObj = new Product_Model__c(
            Product_Model_ID__c = 'RW2H8LJNW',
            Product_Division__c = 'A',
            Product_Subdivision__c = 'Honda',
            Model_Year__c = '2020',
            Model_Name__c = 'CR-V',
            Trim__c = 'AWD EX-L');
        insert product_modelObj;
        Id recTypeId = Schema.SObjectType.Honda_Product__c.getRecordTypeInfosByName().get('Acura Auto').getRecordTypeId();
        Honda_Product__c honda_productObj = new Honda_Product__c(
            Name = 'a0602000002i322',
            RecordTypeId = recTypeId,
            Product_Models__c = product_modelObj.Id,
            Product_Model_Color__c = product_model_colorObj.Id,
            Product_Identifier__c = '5J6RW2H83LA011790');
        insert honda_productObj;
        Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account act = new Account(
            FirstName = 'I',
            LastName = 'Ansari',
            RecordTypeId = personAccRecTypeId,
            PersonEmail = 'ansari@test.com'
        );
        Insert act;
        Ownership__c ownershipObj = new Ownership__c(
            Managed__c = true,
            Alert__c = 'Test',
           // Radio_Navigation_Code__c = 'Test',
            License_Plate_Number__c = '01234567',
            Honda_Product__c = honda_productObj.Id,
            Nickname__c = 'Nickname test',
            Product_Owner__c = act.Id,
            License_Plate_State_Name__c = 'AK');
        insert ownershipObj;
        OwnProductController.getProductContext(honda_productObj.Id);
    }
}
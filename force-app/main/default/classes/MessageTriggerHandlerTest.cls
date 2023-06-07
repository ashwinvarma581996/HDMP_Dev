@isTest
public class MessageTriggerHandlerTest {
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
                Product_Identifier__c = 'Test123456'
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
        
        u.Last_Visited_Product_ID__c =[select id,name from Honda_Product__c where name='a0602000002i322' limit 1].id;
        update u;    }
   
    @istest
    static void insertOwnersMessagesTest(){
         User testUSer = [SELECT Id FROM USER WHERE  alias='admin' LIMIT 1];
        Honda_Product__c h=[select id from Honda_Product__c where Product_Identifier__c = 'Test123456' LIMIT 1];
        Account accObj = [SELECT Id, RecordTypeId, FirstName, LastName, PersonEmail, OwnerId, PersonContactId FROM Account LIMIT 1];
        List<Message__c> messages=new List<Message__c>();
        system.runAs(testUSer){
            Ownership__c ownerShip= new Ownership__c();
            ownerShip.Ownership_Unique_ID__c='Test53782462';
            ownerShip.Honda_Product__c=h.Id;
            ownerShip.Product_Owner__c=accObj.Id;
            ownerShip.Preferred_Dealer__c=accObj.Id;    
            insert ownerShip;
            String recordTypeVar=system.Label.OTARecordType;    
            Id otaRecordID = Schema.SObjectType.Message__c.getRecordTypeInfosByName().get(recordTypeVar).getRecordTypeId();
            Message__c message=new Message__c();
            message.Body__c='test';
            message.Brand__c='M';
            message.Source_Id__c='Test123';
            message.Subject__c = 'Test';
            message.Product_Identifier__c ='Test123456';
            message.Alternate_Identifier__c ='Test53782462';
            message.RecordTypeId=otaRecordID;
            messages.add(message);
            Message__c message1=new Message__c();
            message1.Body__c='test';
            message1.Brand__c='M';
            message1.Source_Id__c='Test1233';
            message1.Subject__c = 'Test';
            message1.Product_Identifier__c ='Test123456';
            message1.Alternate_Identifier__c ='Test53782463';
            message1.RecordTypeId=otaRecordID;
            messages.add(message1);
            insert messages;
        }
    }
}
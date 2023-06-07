@isTest
public with sharing class OwnMyVehicleApiHelperTest {
    
    @TestSetup
    static void makeData(){

        Profile adm = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole role1 = [SELECT Id FROM UserRole WHERE Name = 'System Administrator' LIMIT 1];
        User admin = new User ( FirstName='admin', LastName='user', Alias = 'admin', Email = 'admin1@test.com', Username =  System.now().millisecond() + 'admin1@test.com',
                                ProfileId = adm.Id, FederationIdentifier='300010152123', UserRoleId = role1.Id, TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US'
        );
        insert admin;
        Account acc = new Account();
        User u = new User();

        System.runAs(admin){
            Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            Account act = new Account( FirstName = 'd', LastName = 'Yusuf', RecordTypeId = personAccRecTypeId, PersonEmail = 'yusuf@test.com', ownerId = admin.id);
            Insert act;
            acc = act;
            Account accObj = [SELECT Id, RecordTypeId, FirstName, LastName, PersonEmail, OwnerId, PersonContactId FROM Account WHERE Id = : act.Id];
            //Create Portal User
            Profile comm = [SELECT Id FROM Profile WHERE Name = 'Standard Community User'];
            User user1 = new User( UserName = accObj.PersonEmail, FirstName = accObj.FirstName, LastName = accObj.LastName, Alias = 'test123',
                                    email = accObj.PersonEmail, ContactId = accObj.PersonContactId, FederationIdentifier='3000101521234', ProfileId = comm.Id, EmailEncodingKey = 'UTF-8',
                                    CommunityNickname = 'test12345', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US'
            );
            Insert user1;
            u = user1;
        }

        System.runAs(admin){
            Product_Model__c pm = new Product_Model__c(Model_Year__c='2022', Model_Name__c='TestModel1', Trim__c='TestTrim1', Product_Model_Id__c='TEST01');
            insert pm;
            Product_Model_Color__c pmc = new Product_Model_Color__c(Exterior_Color_Name__c='TestColor1', Manufacturer_Color_Code__c='TE-0001', Product_Model__c=pm.Id);
            insert pmc;
            Honda_Product__c hp = new Honda_Product__c(Product_Models__c=pm.Id, Product_Model_Color__c=pmc.Id);
            insert hp;
    
            Ownership__c o = new Ownership__c(Product_Owner__c=acc.Id, Honda_Product__c=hp.Id);
            insert o;
        }
    }
    
    @isTest public static void sendToMyVehiclesTest(){
        Account acc = [SELECT Id FROM Account WHERE PersonEmail='yusuf@test.com'];
        List<Ownership__c> oL = [SELECT Id, Nickname__c, Managed__c, License_Plate_Number__c, License_Plate_State_Name__c,
                                        Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__r.Model_Year__c,
                                        Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c,
                                        Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Models__r.Product_Division__c,
                                        Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c,
                                        Honda_Product__r.Product_Model_Color__r.Model_ID_Manufacture_Color_Code__c, Product_Owner__c
                                    FROM Ownership__c WHERE Product_Owner__c=:acc.Id];
        Ownership__c o = oL[0].clone(true, true, true, true);
        o.Nickname__c = 'Test Nickname 1';

        update o;

        Map<Id, Ownership__c> oMap = new Map<Id, Ownership__c>();

        for (Ownership__c os : oL){
            oMap.put(os.Id, os);
        }

        Test.setMock(HttpCalloutMock.class, new OwnMyVehicleHttpCalloutMock());
        OwnMyVehicleApiHelper.sendToMyVehicles_async(new Set<Id>{o.Id}, JSON.serialize(oMap));
        OwnMyVehicleApiHelper.sendToMyVehicles_async(new Set<Id>{o.Id});
    }

    @isTest public static void getAllUserVehiclesTest(){
        Test.setMock(HttpCalloutMock.class, new OwnMyVehicleHttpCalloutMock());

        Test.startTest();
        OwnMyVehicleApiHelper.MyVehicleResult result = OwnMyVehicleApiHelper.getAllUserVehicles();
        Test.stopTest();

        System.assertEquals(1, result.products.size());
        System.assertEquals('VINNUMBER00000001', result.products[0].vin);
        //List<OwnGarageController.Product> products = result.products;
    }
    
     @isTest public static void sendToMyVehiclesTestWithVin(){
        Account acc = [SELECT Id FROM Account WHERE PersonEmail='yusuf@test.com'];
        Honda_Product__c hp=[select id,Product_Identifier__c from Honda_Product__c Limit 1];
        hp.Product_Identifier__c = '5J6RW2H83LA011791';
        update hp;
        List<Ownership__c> oL = [SELECT Id, Nickname__c, Managed__c, License_Plate_Number__c, License_Plate_State_Name__c,
                                        Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__r.Model_Year__c,
                                        Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c,
                                        Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Models__r.Product_Division__c,
                                        Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c,
                                        Honda_Product__r.Product_Model_Color__r.Model_ID_Manufacture_Color_Code__c, Product_Owner__c
                                    FROM Ownership__c WHERE Product_Owner__c=:acc.Id];
        Ownership__c o = oL[0].clone(true, true, true, true);
        o.Nickname__c = 'Test Nickname 1';

        update o;

        Map<Id, Ownership__c> oMap = new Map<Id, Ownership__c>();

        for (Ownership__c os : oL){
            oMap.put(os.Id, os);
        }

        Test.setMock(HttpCalloutMock.class, new OwnMyVehicleHttpCalloutMock());
        OwnMyVehicleApiHelper.sendToMyVehicles_async(new Set<Id>{o.Id}, JSON.serialize(oMap));
        OwnMyVehicleApiHelper.sendToMyVehicles_async(new Set<Id>{o.Id});
    }

}
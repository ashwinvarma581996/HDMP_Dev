@isTest
public class OwnershipTriggerHelperTest {
    @isTest static void sendToMyVehiclesTest(){
        List<Message__c> messages=new List<Message__c>();
        String recordTypeVar=system.Label.OTARecordType;    
            Id otaRecordID = Schema.SObjectType.Message__c.getRecordTypeInfosByName().get(recordTypeVar).getRecordTypeId();
            Message__c message=new Message__c();
            message.Body__c='test';
            message.Brand__c='M';
            message.Source_Id__c='Test123';
            message.Subject__c = 'Test';
            message.Product_Identifier__c ='29UUA66204A054612';
            message.Alternate_Identifier__c ='Test53782462';
            message.RecordTypeId=otaRecordID;
        	message.Start_Date__c = system.today()+1;
        	message.End_Date__c = system.today()+2;
            messages.add(message);
            Message__c message1=new Message__c();
            message1.Body__c='test';
            message1.Brand__c='M';
            message1.Source_Id__c='Test1233';
            message1.Subject__c = 'Test';
            message1.Product_Identifier__c ='29UUA66204A054612';
            message1.Alternate_Identifier__c ='Test53782463';
            message1.RecordTypeId=otaRecordID;
        	message1.Start_Date__c = system.today()+1;
        	message1.End_Date__c = system.today()+2;
            messages.add(message1);
            insert messages;
        Honda_Product__c honda_productObj = new Honda_Product__c(
            Name = 'honda_product',
            Standard_Warranty_End_Date__c = System.today(),
            Standard_Warranty_Start_Date__c = System.today(),
            Warranty_Factory_Extended_Date__c = System.today(),
            Is_Warrany_Canceled__c = true,
            Product_Identifier__c = '29UUA66204A054612');
         insert honda_productObj;
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Account accountObj = new Account(
            LastName = 'Banner',
            FirstName = 'Bruce',
            Salutation = 'Dr.',
            RecordTypeId = recordTypeId,
            Phone = '(555) 123-4567',
            Description = 'Hulk',
            PersonMailingStreet = 'Gotham',
            PersonMailingCity = 'New York',
            PersonMailingState = 'Arizona',
            PersonMailingPostalCode = '11377',
            PersonTitle = 'Hulk');
         insert accountObj;
        Ownership__c ownershipObj = new Ownership__c(
            Managed__c = true,
            Verified__c = true,
            Alert__c = 'Test',
          //  Radio_Navigation_Code__c = 'Test',
            Honda_Product__c = honda_productObj.Id,
            Product_Owner__c = accountObj.Id,
            Nickname__c = 'Test Marine');
         insert ownershipObj;
        
        Ownership__c ownershipObj2 = new Ownership__c(
            Id = ownershipObj.Id,
            Nickname__c = 'Test Marine2');
         update ownershipObj2;
        Set<Id> ownershipIds = new Set<Id>();
        ownershipIds.add(ownershipObj.Id);
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
		Test.startTest();
        OwnershipTriggerHelper.sendToMyVehicles(ownershipIds);
        Map<Id, Ownership__c> oo = new Map<Id, Ownership__c>{ownershipObj.Id => new Ownership__c()};
        String oldOwnershipStr = JSON.serialize(oo);
        OwnershipTriggerHelper.sendToMyVehicles(ownershipIds, oldOwnershipStr);
        List<Schema.SObjectField> ownershipFieldsList = new List<Schema.SObjectField>{Ownership__c.Nickname__c, Ownership__c.License_Plate_Number__c, Ownership__c.Honda_Product__c};
        Map<Schema.SObjectField, String> apiFieldNameMap = new Map<Schema.SObjectField, String> {Ownership__c.Nickname__c => 'vehicleAlias', Ownership__c.License_Plate_Number__c => 'licensePlateNo', Honda_Product__c.Product_Identifier__c => 'vinNo'};
        OwnershipTriggerHelper.getApiParamsForOwnershipFields(ownershipObj, oo, ownershipFieldsList, apiFieldNameMap);                                                                 
		Test.stopTest();
    }
}
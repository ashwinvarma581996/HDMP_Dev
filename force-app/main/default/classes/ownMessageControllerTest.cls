@isTest
public with sharing class ownMessageControllerTest {
    @testSetup static void testSetup(){
        Message__c messageObj = new Message__c(
            Name = 'a0q7h000001yNV4',
            Brand__c = 'A',
            Subject__c = '2021 Accord Rear Center Seat Belt Safety Recall',
            Body__c = '<b>NHTSA Recall Number: </b>21V-900<br><br><b>MFR Campaign ID: </b>RBR<br><br><b>Campaign Description: </b>2021 Accord Rear Center Seat Belt Safety Recall<br><br><b>Recall Date: </b>11/18/2021<br><br><b>Recall Status: </b>17 Character VIN Required<br><br><b>Summary: <br></b>American Honda Motor Co., Inc. (Honda) is recalling certain 2021 model year Accord Sedan and Accord Hybrid vehicles. The automatic locking retractor (ALR) function on the second row center seat belt assembly may improperly deactivate. If the seat belt webbing is pulled out to the end and the ALR deactivates, the seat belt webbing can retract or extend freely, preventing proper child seat restraint with the seat belt.<br><br><b>Safety Risk: <br></b>ALR deactivation does not comply with the requirements of Federal Motor Vehicle Safety Standard (FMVSS) No. 208, Occupant Crash Protection, increasing the risk of injury to the child seat occupant.<br><br><b>Remedy: <br></b>Please call any authorized Honda dealer and make an appointment to have your vehicle repaired. Your dealer will replace the second row center seat belt assembly with a new assembly for free. For additional questions or to get help locating a dealer, owners may contact American Honda&#39;s Customer Support &amp; Campaign Center at 1-888-234-2138.<br><br>',
            Start_Date__c = System.today(),
            Alternate_Identifier__c = 'CV1F5MJNW~RBR',
            Source_Id__c = 'RBR');
         insert messageObj;
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
           // Radio_Navigation_Code__c = 'Test',
            Honda_Product__c = honda_productObj.Id,
            Product_Owner__c = accountObj.Id,
            Nickname__c = 'Test Marine');
         insert ownershipObj;
        Owner_Message__c owner_messageObj = new Owner_Message__c(
            Name = 'a0x7h000001W58T',
            Alternate_Identifier__c = 'a0q7h000001yGNnAAM~0010200000GLuoyAAD',
            Is_Read__c = true,
            Message__c = messageObj.Id,
            Owner__c = accountObj.Id,
            Ownership__c = ownershipObj.Id,
            Read_Date__c = System.today());
         insert owner_messageObj;
    }
    @isTest static void getAllMessages(){
        Test.startTest();
        Honda_product__c product = [SELECT Id FROM Honda_product__c LIMIT 1];
        Account accObj1 = [SELECT Id FROM Account LIMIT 1];
        Ownership__c ownership = [SELECT Id FROM Ownership__c LIMIT 1];
        Id acctId = [SELECT AccountId FROM User LIMIT 1].AccountId;
        Message__c msg = [SELECT Id FROM Message__c LIMIT 1];
        OwnMessageController.MessageInbox messages = ownMessageController.getAllMessages();
        Test.stopTest();
    }
    @isTest static void markItReadTest(){
        Owner_Message__c ownerMessage = [select id from Owner_Message__c limit 1];
        ownMessageController.markItRead(ownerMessage.Id);
    }
    @isTest static void getRecallByAlt_IdnfTest(){
        Message__c message = [select id, Alternate_Identifier__c from Message__c limit 1];
        ownMessageController.getRecallByAlt_Idnf(message.Alternate_Identifier__c);
    }
    @isTest static void getAllRecallsTest(){
        ownMessageController.getAllRecalls();
    }
}
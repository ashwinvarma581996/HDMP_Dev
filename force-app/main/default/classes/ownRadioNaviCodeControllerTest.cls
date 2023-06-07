@isTest
public class ownRadioNaviCodeControllerTest {
    @testSetup static void testSetup(){
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
        Radio_Navi_Request__c radioNav = new Radio_Navi_Request__c();
		radioNav.Product_Identifier__c = '1HGCV1F37MA028563';
        radioNav.LastUpdatedDate__c = System.now();
            insert radioNav;
        Radio_Navi_Request__c radioNavWithEmail = new Radio_Navi_Request__c();
            radioNavWithEmail.Product_Identifier__c = '29UUA66204A054612';
            radioNavWithEmail.Email_Address__c = 'test@gmail.com';
            insert radioNavWithEmail;

        Radio_Navi_Request_Failure__c radioNaviRequestFailure = new Radio_Navi_Request_Failure__c();
            radioNaviRequestFailure.Product_Identifier__c = '29UUA66204A054612';
            radioNaviRequestFailure.Authorization_Code_Failure_Type_Code__c ='100';
            radioNaviRequestFailure.Radio_Navi_Request_Id__c = radioNavWithEmail.ID; 
            radioNaviRequestFailure.Alternate_Identifier__c =radioNavWithEmail.ID+radioNaviRequestFailure.Authorization_Code_Failure_Type_Code__c;
            insert radioNaviRequestFailure;
    }

    @isTest static void teststoreRadioOrNaviCode(){
        Ownership__c ownershipObj = [SELECT Id, Name FROM Ownership__c limit 1];
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        Test.startTest();
        ownRadioNaviCodeController.storeRadioOrNaviCode('1234','3456','29UUA66204A054612',ownershipObj.Id,true,'29UUA66204A054612','true','Success');
        Test.stopTest();
    }
    @isTest static void testcreateradioNaviRequest(){
        Radio_Navi_Request__c radioNav = [SELECT Id,Email_Address__c,Product_Identifier__c,LastUpdatedDate__c FROM Radio_Navi_Request__c limit 1];
        System.debug('radioNav--->'+radioNav);
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        Test.startTest();
        ownRadioNaviCodeController.createradioNaviRequest('','1234','3456','29UUA66204A054612','11113491','CLB29001605A','test@gmail.com','098765432','23456','Not Found','false',true,radioNav.Id);
        Test.stopTest();
    }
    @isTest static void testcreateradioNaviRequestelse(){
        Radio_Navi_Request__c radioNav = [SELECT Id,Email_Address__c,Product_Identifier__c FROM Radio_Navi_Request__c WHERE Product_Identifier__c ='1HGCV1F37MA028563' limit 1];
        
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        Test.startTest();
        ownRadioNaviCodeController.createradioNaviRequest('','1234','3456','29UUA66204A054612','11113491','CLB29001605A','test@gmail.com','098765432','23456','Success','false',false,'1234');
        Test.stopTest();
    }
    @isTest static void testcreateradioNaviRequestFailure(){
        Radio_Navi_Request__c radioNav = [SELECT Id,Email_Address__c,Product_Identifier__c FROM Radio_Navi_Request__c WHERE Email_Address__c ='test@gmail.com' limit 1];
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        Test.startTest();
        ownRadioNaviCodeController.createradioNaviRequestFailure('29UUA66204A054612','11113491','CLB29001605A','test@gmail.com',radioNav.Id,'Fail','','','','100');
        Test.stopTest();
    }
    @isTest static void testgetExternalIp(){
        Radio_Navi_Request__c radioNav = [SELECT Id,Email_Address__c,Product_Identifier__c FROM Radio_Navi_Request__c WHERE Email_Address__c ='test@gmail.com' limit 1];
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        Test.startTest();
        ownRadioNaviCodeController.getExternalIp();
        Test.stopTest();
    }
}
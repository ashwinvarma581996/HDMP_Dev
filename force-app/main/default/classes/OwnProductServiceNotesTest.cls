@isTest
public class OwnProductServiceNotesTest {

    @testSetup static void testSetup(){
        Account a = new Account();
		a.Name = 'TestAccount';
        //a.PoIId__c = 'TestPoI'; 
        insert a;

		Honda_Product__c p = new Honda_Product__c();
		p.Name = 'TestProduct';
        insert p;

        Ownership__c o = new Ownership__c();
		o.Honda_Product__c = p.Id;
		o.Product_Owner__c = a.Id;
		o.Nickname__c = 'TestOwnership';
		insert o;

		/*Product_Service_Note__c n = new Product_Service_Note__c();
		n.Name = 'TestServiceNote';
        n.Ownership__c = o.Id;
		insert n;*/
    }

	
	//Positive
	@isTest
    static void getServiceNotesFromOrgPass_Honda_API(){
	
	Test.startTest();
	Test.setMock(HttpCalloutMock.class, new OwnProductServiceNotes_MockService());
	
	//List<OwnProductServiceNotes.API_Product_Service_Note> noteList = new List<OwnProductServiceNotes.API_Product_Service_Note>();
	String noteList;
	noteList = OwnProductServiceNotes.getServiceRecordVIN_Honda_ResponseBody('19XFB2F54DE248462');
     
    Test.stopTest();
    }

	@isTest
    static void getServiceNotesFromOrgPass_Acura_API(){
	
	Test.startTest();
	Test.setMock(HttpCalloutMock.class, new OwnProductServiceNotes_MockService());
	//List<OwnProductServiceNotes.API_Product_Service_Note> noteList = new List<OwnProductServiceNotes.API_Product_Service_Note>();
	String noteList;
	noteList = OwnProductServiceNotes.getServiceRecordVIN_Acura_ResponseBody('5J8TB4H31FL000398');
    Test.stopTest();
    }

	@isTest
    static void getServiceNotesFromOrg(){
	Ownership__c o = [select Id, nickname__c from ownership__c where nickname__c = 'TestOwnership' LIMIT 1];
	
	List<Product_Service_Note__c> noteList = OwnProductServiceNotes.getServiceNotes(o.Id);

    Product_Service_Note__c n = new Product_Service_Note__c();
		n.Name = 'TestServiceNote';
        n.Ownership__c = o.Id;

		insert n;

    	noteList = OwnProductServiceNotes.getServiceNotes(o.Id);
    }
    
	//Positive
	@isTest
    static void getServiceNotesFromOrgPass_Honda_APIController(){
	
	Test.startTest();
	Test.setMock(HttpCalloutMock.class, new OwnProductServiceNotes_MockService());
	
	//List<OwnProductServiceNotes.API_Product_Service_Note> noteList = new List<OwnProductServiceNotes.API_Product_Service_Note>();
	String noteList;
	noteList = OwnAPIController.getProductServiceNotes('19XFB2F54DE248462','A');
     
    Test.stopTest();
    }

	@isTest
    static void getServiceNotesFromOrgPass_Acura_APIController(){
	
	Test.startTest();
	Test.setMock(HttpCalloutMock.class, new OwnProductServiceNotes_MockService());
	//List<OwnProductServiceNotes.API_Product_Service_Note> noteList = new List<OwnProductServiceNotes.API_Product_Service_Note>();
	String noteList;
	noteList = OwnAPIController.getProductServiceNotes('5J8TB4H31FL000398','B');
    Test.stopTest();
    }


}
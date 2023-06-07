@isTest
public class EmailTemplateControllerTest {
	@isTest 
    static void testEmailTemplateController() {
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'vvh2kqnt6m4434vr');
        Order objOrder = createTestData(objAccount);
       
        Product2 objProduct = [Select Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c From Product2 Limit 1];
        
        OrderItem objOrderItem123 = B2B_TestDataFactory.createOrderItem(false, objOrder.Id, objProduct.Id); 
        objOrderItem123.Updated_Quantity__c = objOrderItem123.Quantity;
        insert objOrderItem123;
        
        EmailTemplateController em = new EmailTemplateController();
        em.recordId = objOrder.Id;
        em.getItems();
        
    }
    
    public static Order createTestData(Account objAccount){
       	Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
        Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());
        
        WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, objAccount.Id, testStore.Id);
        testcart.Delivery_Type__c = 'Install At Dealer';
        update testcart;
        
        CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, testcart.Id);
        Product2 prod = B2B_TestDataFactory.createProduct(true);
        Product2 objProduct = [Select Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c From Product2 Where Id =: prod.Id];
        CartItem objCartItem = B2B_TestDataFactory.createCartItem(true, testcart.Id, testdelivery.Id, objProduct.Id);    
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objuser = new User(Alias = 'standt', Email='rajuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
             UserName='rajuser@testorg.com');
        insert objuser;
        
        B2B_Custom_Settings__c obj = B2B_TestDataFactory.createCustomSetting(true, objAccount.Id, objuser.Id);
        
        Order objOrder = B2B_TestDataFactory.createOrder(true, objAccount.Id, testcart.Id);
        OrderItem objOrderItem123 = B2B_TestDataFactory.createOrderItem(false, objOrder.Id, objProduct.Id); 
        objOrderItem123.Updated_Quantity__c = objOrderItem123.Quantity;
        insert objOrderItem123;
        
        return objOrder;
    }
}
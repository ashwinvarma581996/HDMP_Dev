@isTest
public class B2B_BatchSettleBTTransactionsTest {
    
    @isTest
    public static void unitTest(){
        Account objAccount = B2B_TestDataFactory.createAccount(true,'x6q6b83wjsn28t2m');
        System.debug('account' + objAccount);
        WebStore objWebStore = B2B_TestDataFactory.createStore(true);
        WebCart objWebCart =  B2B_TestDataFactory.createCart(true,objAccount.Id, objWebStore.Id);
        CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, objWebCart.Id);
        Product2 prod = B2B_TestDataFactory.createProduct(true);
        Product2 objProduct = [Select Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c From Product2 Where Id =: prod.Id];
        CartItem objCartItem = B2B_TestDataFactory.createCartItem(true, objWebCart.Id, testdelivery.Id, objProduct.Id);
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objuser = new User(Alias = 'standt', Email='rajuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
             UserName='rajuser@testorg.com');
        insert objuser;
        
        B2B_Custom_Settings__c obj = B2B_TestDataFactory.createCustomSetting(true, objAccount.Id, objuser.Id);
        Order objOrder = B2B_TestDataFactory.createOrder(true,objAccount.Id,objWebCart.Id);
        B2B_TestDataFactory.createOrderItem(true, objOrder.Id, objProduct.Id);
        objOrder.BT_Transaction_Status__c = 'Submitted_For_Settlement';
        objOrder.Status = 'Activated';
        update objOrder;
        Test.startTest();                  
        Id batchJobId = Database.executeBatch(new B2B_BatchSettleBTTransactions());
        System.debug('batchjobId' + batchJobId);
        Test.stopTest();         
    }  
}
/*
Created By : Rajrishi Kaushik
Name: B2B_CreditCardPreAuthVertexTest
Date: 05/10/2021
Description: 
*/

@isTest
public class B2B_CreditCardPreAuthVertexTest {
	
    @isTest
    public static void unitTestCalculatePreAuthTax(){
        Account testAccount = B2B_TestDataFactory.createAccount(true);
       	WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, testAccount.Id, testStore.Id);
        testcart.Delivery_Type__c = 'Install At Dealer';
        update testcart;
       	CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, testcart.Id);
       	Product2 prod = B2B_TestDataFactory.createProduct(true);
        Product2 testProd = [Select Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c From Product2 Where Id =: prod.Id];        
        CartItem cItem = B2B_TestDataFactory.createCartItem(true, testcart.Id, testdelivery.Id,testProd.Id);
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objuser = new User(Alias = 'standt', Email='rajuser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                                UserName='rajuser@testorg.com');
        insert objuser;
        B2B_Custom_Settings__c obj = B2B_TestDataFactory.createCustomSetting(true, testAccount.Id, objuser.Id);
        Order objOrder = B2B_TestDataFactory.createOrder(false, testAccount.Id, testcart.Id);
        objOrder.BT_Transaction_Id__c = 'fe67q2zd';
        objOrder.Updated_Order_Total__c = 10.00;
        objOrder.Updated_Total_Tax__c = 04.00;
        insert objOrder;
        
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);
        OrderItem objOrderItem123 = B2B_TestDataFactory.createOrderItem(true, objOrder.Id, prod.Id); 
        
        B2B_CreditCardPreAuthVertex.FlowInputs objFlowInputs = new B2B_CreditCardPreAuthVertex.FlowInputs();
        objFlowInputs.accountId = testAccount.Id;
        objFlowInputs.orderId = objOrder.Id;
        List<B2B_CreditCardPreAuthVertex.FlowInputs> lstFlowInputs = new List<B2B_CreditCardPreAuthVertex.FlowInputs>();
        lstFlowInputs.add(objFlowInputs);
        B2B_CreditCardPreAuthVertex.calculatePreAuthTax(lstFlowInputs);
    }
}
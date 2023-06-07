/**
* @File Name          : B2B_DraftOrderUpdateControllerTest
* @Description        : This class is a test class of B2B_DraftOrderUpdateController
* @Created By         : Rajrishi
* @Date               : 28/10/2022
* @Last Modified By   : 
*==============================================================================
* Ver         Date                   Author              Modification
*==============================================================================
* 1.0       28/10/2022               Rajrishi            Initial Version
**/

@isTest
public class B2B_DraftOrderUpdateControllerTest {

    @isTest
    public static void unitTest(){
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
        
        OrderItem objOrderItem123 = B2B_TestDataFactory.createOrderItem(true, objOrder.Id, prod.Id); 
        
        B2B_DraftOrderUpdateController.FlowInputs objFlowInputs = new B2B_DraftOrderUpdateController.FlowInputs();
        objFlowInputs.cartId = testcart.Id;
        objFlowInputs.orderId = objOrder.Id;
        List<B2B_DraftOrderUpdateController.FlowInputs> lstFlowInputs = new List<B2B_DraftOrderUpdateController.FlowInputs>();
        lstFlowInputs.add(objFlowInputs);
        B2B_DraftOrderUpdateController.updateOrderAndOrderItem(lstFlowInputs);
    }
}
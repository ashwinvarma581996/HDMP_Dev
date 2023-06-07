/**************************************************************************************
@File Name      : B2B_ShippingHelperTest  
@Bussiness unit : HDM 
@Description    : It is created to code coverage for B2B_ShippingHelper, B2B_UPSShippingCalculation, B2B_FedexShippingCalculation apex class
@Created By		: Soumya Sahoo 
@Created Date   : 25/06/2022
@API Version    : 54.0
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                    | User Story 
10/20/2021                | Soumya,Yashika   |                           |            
26/05/2022                | Mathi		     |							 |	
25/06/2022				  | Soumya			 |
*****************************************************************************************/

@isTest
public class B2B_ShippingHelperTest {
    @testsetup
    public static void createSetupData(){
        User objUser = [Select Id from User LIMIT 1 ];
        B2B_Fedex_Shipping_Box__mdt objFedexBox=[Select DeveloperName,B2B_Height__c,B2B_Length__c,B2B_Width__c,B2B_Package_Volume__c from B2B_Fedex_Shipping_Box__mdt ORDER BY B2B_Package_Volume__c ASC limit 1];
        Contact con=B2B_TestDataFactory.createContact(true);
        Account objAccount = B2B_TestDataFactory.createAccountdealer(true);
        WebStore objWebStore = B2B_TestDataFactory.createStore(true);
        WebCart objWebCart =  B2B_TestDataFactory.createCart(true,objAccount.Id, objWebStore.Id);
        CartDeliveryGroup objCartDeliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(true,objWebCart.Id);
        Product2 objProduct2 = B2B_TestDataFactory.createProduct(true);
        objProduct2.Length_in__c = 0.59;
        objProduct2.Width_in__c = 0.39;
        objProduct2.Height_in__c = 0.39;
        update objProduct2;
        OrderDeliveryMethod objOrderDeliveryMethod = B2B_TestDataFactory.createOrderDeliveryMethod(true,'test',objProduct2.Id);
        cartItem cartitm = new cartItem();
        B2B_Custom_Settings__c objCustomSetting = B2B_TestDataFactory.createCustomSetting(true,objAccount.Id, objUser.Id);
        cartitm=B2B_TestDataFactory.createCartItem(true, objWebCart.Id, objCartDeliveryGroup.Id, objProduct2.Id );
        cartitm.Quantity=1;
        update cartitm;
        Order ord = B2B_TestDataFactory.createOrder(true, objAccount.Id, objWebCart.Id);
        OrderItem orditem = B2B_TestDataFactory.createOrderItem(true,ord.Id,objProduct2.Id);
        
    }
    @isTest
    public static void TestmethodFedEx(){
        List<Id> testcart=new List<Id>();
        Account acc=[SELECT id FROM Account LIMIT 1];
        	  acc.shippingState='TX';
              acc.shippingPostalCode='79110-1722';
        	  acc.POIID__c='RJ';
        		UPDATE acc;
        WebCart cart1=[SELECT id FROM Webcart LIMIT 1];
        		cart1.Customer_State__c='TX';
                cart1.CustomerPostalCode__c='79110-1722';
        		cart1.ShippingAmount__c=1;
        		cart1.DealerId__c=acc.id;
        		
        UPDATE cart1;
        Carrier__c carrier_data = B2B_TestDataFactory.createCarrier('FEDEX');
        Carrier_Speed__c carrierSpeedData=B2B_TestDataFactory.createCarrierSpeed('FEDEX',carrier_data.id);
        for(Webcart we:[select id from webCart])
            testcart.add(we.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_ShippingHelperCalloutMock());
        B2B_ShippingHelper.syncDelivery(testcart);
        Id iddata=testcart[0];
        B2B_ShippingHelper.startCartProcessMegaSync(iddata,'22201','Cart');
        Test.stopTest();
    }
    @isTest
    public static void TestmethodUSPS(){
        Carrier__c carrier_data_USPS = B2B_TestDataFactory.createCarrier('USPS');
        Account acc=[select id from Account limit 1];
        acc.Preferred_Shipping_Carrier__c=carrier_data_USPS.id;
        acc.shippingPostalCode='2220145656';
        update acc;
        WebCart cart1=[select id from Webcart limit 1];
        cart1.Customer_State__c='TX';
        cart1.CustomerPostalCode__c='79110-1722';
        cart1.ShippingAmount__c=1;
        cart1.DealerId__c=acc.id;
        
        update cart1;
        List<Id> testcart=new List<Id>();
        for(Webcart we:[select id from webCart])
            testcart.add(we.id);
        Carrier__c carrier_data = B2B_TestDataFactory.createCarrier('USPS');
        Carrier_Speed__c carrierSpeedData=B2B_TestDataFactory.createCarrierSpeed('USPS',carrier_data.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_ShippingHelperCalloutMock());
        B2B_ShippingHelper.syncDelivery(testcart);
        Id iddata=testcart[0];
        B2B_ShippingHelper.startCartProcessMegaSync(iddata,'22201','Cart');
        Test.stopTest();
    }
    @isTest
    public static void TestmethodUPS(){
        Carrier__c carrier_data_UPS = B2B_TestDataFactory.createCarrier('UPS');
        Account acc=[select id from Account limit 1];
        acc.Preferred_Shipping_Carrier__c=carrier_data_UPS.id;
        acc.shippingPostalCode='2220145656';
        update acc;
        WebCart cart1=[select id from Webcart limit 1];
        cart1.Customer_State__c='TX';
        cart1.CustomerPostalCode__c='79110-1722';
        cart1.ShippingAmount__c=1;
        cart1.DealerId__c=acc.id;
        
        update cart1;
        List<Id> testcart=new List<Id>();
        for(Webcart we:[select id from webCart])
            testcart.add(we.id);
        Carrier__c carrier_data = B2B_TestDataFactory.createCarrier('UPS');
        Carrier_Speed__c carrierSpeedData=B2B_TestDataFactory.createCarrierSpeed('UPS',carrier_data.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_ShippingHelperCalloutMock());
        B2B_ShippingHelper.syncDelivery(testcart);
        Id iddata=testcart[0];
        B2B_ShippingHelper.startCartProcessMegaSync(iddata,'22201','Cart');
        Test.stopTest();
    }
    /*@isTest
    public static void TestmethodNegativeNullCartId(){
        
        List<Id> testcart=new List<Id>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_ShippingHelperCalloutMock());
        B2B_ShippingHelper.syncDelivery(testcart);
        Test.stopTest();
    }*/
    @isTest
    public static void TestmethodNegativeNullPickUpAtDealer(){
        WebCart cart2=[select id from webcart limit 1];
        cart2.Pickup_Dealer__c=true;
        cart2.ShippingAmount__c=null;
        update cart2;
        List<Id> testcart=new List<Id>();
        for(Webcart we:[select id,Pickup_Dealer__c,ShippingAmount__c from webCart])
            testcart.add(we.id);
        Id iddata=testcart[0];
        B2B_ShippingHelper.syncDelivery(testcart);
    }
    @isTest
    public static void TestmethodNegativeFedEx(){
        List<Id> testcart=new List<Id>();
        Account acc=[SELECT id FROM Account LIMIT 1];
        	  acc.shippingState='TX';
              acc.shippingPostalCode='79110-1722';
        	  acc.POIID__c='RJ';
        		UPDATE acc;
        WebCart cart1=[SELECT id FROM Webcart LIMIT 1];
        		cart1.Customer_State__c='TX';
                cart1.CustomerPostalCode__c='79110-1722';
        		cart1.ShippingAmount__c=1;
        		cart1.DealerId__c=acc.id;
        		
        UPDATE cart1;
        Carrier__c carrier_data = B2B_TestDataFactory.createCarrier('FEDEX');
        Carrier_Speed__c carrierSpeedData=B2B_TestDataFactory.createCarrierSpeed('FEDEX',carrier_data.id);
        for(Webcart we:[select id from webCart])
            testcart.add(we.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_ShippingHelperCalloutMockNegative());
        B2B_ShippingHelper.syncDelivery(testcart);
        Id iddata=testcart[0];
        B2B_ShippingHelper.startCartProcessMegaSync(iddata,'22201','Cart');
        Test.stopTest();
    }
    @isTest
    public static void TestmethodNegativeUSPS(){
        Carrier__c carrier_data_USPS_Negative = B2B_TestDataFactory.createCarrier('USPS');
        Account acc=[select id from Account limit 1];
        acc.Preferred_Shipping_Carrier__c=carrier_data_USPS_Negative.id;
        acc.shippingPostalCode='2220145656';
        update acc;
        WebCart cart1=[select id from Webcart limit 1];
        cart1.Customer_State__c='TX';
        cart1.CustomerPostalCode__c='79110-1722';
        cart1.ShippingAmount__c=1;
        cart1.DealerId__c=acc.id;
        
        update cart1;
        List<Id> testcart=new List<Id>();
        for(Webcart we:[select id from webCart])
            testcart.add(we.id);
        Carrier__c carrier_data = B2B_TestDataFactory.createCarrier('USPS');
        Carrier_Speed__c carrierSpeedData=B2B_TestDataFactory.createCarrierSpeed('USPS',carrier_data.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_ShippingHelperCalloutMockNegative());
        B2B_ShippingHelper.syncDelivery(testcart);
        Id iddata=testcart[0];
        B2B_ShippingHelper.startCartProcessMegaSync(iddata,'22201','Cart');
        Test.stopTest();
    }
    @isTest
    public static void TestmethodNegativeUPS(){
        Carrier__c carrier_data_UPS_Negative = B2B_TestDataFactory.createCarrier('UPS');
        Account acc=[select id from Account limit 1];
        acc.Preferred_Shipping_Carrier__c=carrier_data_UPS_Negative.Id;
        acc.shippingPostalCode='2220145656';
        update acc;
        WebCart cart1=[select id from Webcart limit 1];
        cart1.Customer_State__c='TX';
        cart1.CustomerPostalCode__c='79110-1722';
        cart1.ShippingAmount__c=1;
        cart1.DealerId__c=acc.id;
        
        update cart1;
        List<Id> testcart=new List<Id>();
        for(Webcart we:[select id from webCart])
            testcart.add(we.id);
        Carrier__c carrier_data = B2B_TestDataFactory.createCarrier('UPS');
        Carrier_Speed__c carrierSpeedData=B2B_TestDataFactory.createCarrierSpeed('UPS',carrier_data.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_ShippingHelperCalloutMockNegative());
        B2B_ShippingHelper.syncDelivery(testcart);
        Id iddata=testcart[0];
        B2B_ShippingHelper.startCartProcessMegaSync(iddata,'22201','Cart');
        Test.stopTest();
    }
    
}
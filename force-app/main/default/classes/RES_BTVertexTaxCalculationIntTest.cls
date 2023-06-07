@isTest
public class RES_BTVertexTaxCalculationIntTest {
	@isTest
    public static webcart testsetupdata(){

        Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
        Account testAccount = B2B_TestDataFactory.createAccount(true);
        User objuser=[select id from User Limit 1];
       	WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, testAccount.Id, testStore.Id);
       	CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, testcart.Id);
       	Product2 prod = B2B_TestDataFactory.createProduct(true);
        Product2 testProd = [Select Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c From Product2 Where Id =: prod.Id];
        CartItem cItem = B2B_TestDataFactory.createCartItem(true, testcart.Id, testdelivery.Id,testProd.Id);
        B2B_Custom_Settings__c obj = B2B_TestDataFactory.createCustomSetting(true, testAccount.Id, objuser.Id);
        Order objOrder = B2B_TestDataFactory.createOrder(true, testAccount.Id, testcart.Id);
        OrderItem orderlineitems=B2B_TestDataFactory.createOrderItem(true, objOrder.Id, testProd.Id);
        OrderItem orderline=[select id,Delta_Quantity__c from OrderItem limit 1];
        orderline.Delta_Quantity__c=1;
        update orderline;
        return testcart;


        //RES_BTVertexTaxCalculationIntegration.vertexAddressCleansing(dealerAddress);
        //RES_BTVertexTaxCalculationIntegration.calculateLineItemReturnTax(testcart.Id, dealerAddressMap, customerAddressMap, 'RJ');

        //RES_BTVertexTaxCalculationIntegration.calculateTax(testcart.Id, dealerAddressMap, customerAddressMap,'RJ','206500','return');
        //RES_BTVertexTaxCalculationIntegration.calculateTax(testcart.Id, dealerAddressMap, customerAddressMap,'RJ','206500','quotation');

}

    @isTest
    public static Map<String,String> testdealerAddressMap() {
        Map<String,String> dealerAddressMap = new Map<String,String>();
            dealerAddressMap.put('streetAddress', '4300 S Georgia St');
            dealerAddressMap.put('city','AMARILLO');
            dealerAddressMap.put('mainDivision', 'TX');
            dealerAddressMap.put('postalCode', '79110-1722');
        return dealerAddressMap;
    }

    public static Map<String,String> testcustomerAddressMap(){
        Map<String,String> customerAddressMap = new Map<String,String>();
        	customerAddressMap.put('streetAddress', '1234 Main Street');
            customerAddressMap.put('city','DALLAS');
            customerAddressMap.put('mainDivision', 'TX');
            customerAddressMap.put('postalCode', '75201');
        return customerAddressMap;

    }

    public static Map<String,String> testdealerAddress(){
        Map<String,String> dealerAddress = new Map<String,String>();
        	dealerAddress.put('streetAddress1','4300 S Georgia St');
            dealerAddress.put('streetAddress2','');
            dealerAddress.put('city','AMARILLO');
            dealerAddress.put('mainDivision','TX');
            dealerAddress.put('postalCode','75001');
            dealerAddress.put('country','USA');
        return dealerAddress;

    }
    	@isTest
    public static void testunit1(){

        Webcart testcart1=testsetupdata();
        Map<String,String> dealerAddressMap1 = testdealerAddressMap();
        Map<String,String> customerAddressMap1 = testcustomerAddressMap();
        Map<String,String> dealerAddress = testdealerAddress();

        Test.startTest();

        RES_BTVertexTaxCalculationIntegration.vertexAddressCleansing(dealerAddress);
        Test.stopTest();
    }
    @isTest
    public static void testunit2(){

        Webcart testcart1=testsetupdata();
        Map<String,String> dealerAddressMap1 = testdealerAddressMap();
        Map<String,String> customerAddressMap1 = testcustomerAddressMap();
        Map<String,String> dealerAddress = testdealerAddress();

        Test.startTest();
        RES_BTVertexTaxCalculationIntegration.calculateTax(testcart1.Id, dealerAddressMap1, customerAddressMap1,'RJ','206500','commit');
        Test.stopTest();
    }
    @isTest
    public static void testunit3(){

        Webcart testcart=testsetupdata();
        Map<String,String> dealerAddressMap = testdealerAddressMap();
        Map<String,String> customerAddressMap = testcustomerAddressMap();
        Map<String,String> dealerAddress = testdealerAddress();

        Test.startTest();
        RES_BTVertexTaxCalculationIntegration.calculateTax(testcart.Id, dealerAddressMap, customerAddressMap,'RJ','206500','return');
        Test.stopTest();
    }
   @isTest
    public static void testunit4(){

        Webcart testcart=testsetupdata();
        Map<String,String> dealerAddressMap = testdealerAddressMap();
        Map<String,String> customerAddressMap = testcustomerAddressMap();
        Map<String,String> dealerAddress = testdealerAddress();

        Test.startTest();
        RES_BTVertexTaxCalculationIntegration.calculateTax(testcart.Id, dealerAddressMap, customerAddressMap,'RJ','206500','quotation');
        Test.stopTest();
    }

@isTest
    public static void testunit5(){

        Webcart testcart=testsetupdata();
        Map<String,String> dealerAddressMap = testdealerAddressMap();
        Map<String,String> customerAddressMap = testcustomerAddressMap();
        Map<String,String> dealerAddress = testdealerAddress();

        Test.startTest();
        RES_BTVertexTaxCalculationIntegration.calculateLineItemReturnTax(testcart.Id, dealerAddressMap, customerAddressMap, 'RJ');
        Test.stopTest();
    }
}
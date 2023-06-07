/*******************************************************************************
Name: B2B_TaxHelperV2Test
Business Unit: HDM
Date: 25/05/2021
Developer: Apoorv Garg
Description: This is a Test class for B2B_VertaxCalculationIntegration and B2B_TaxhelperV2.
*******************************************************************************
MODIFICATIONS – Date | Dev Name 	| Method | User Story
		  26/05/2022 | Mathioli |  Error handling changes- JIRA- 8617
*******************************************************************************/

@isTest
public class B2B_TaxHelperV2Test {
    
    @testsetup
    public static void createdatasetup(){
        Account testAccount = B2B_TestDataFactory.createAccount(true);
        Account dealerAccount = B2B_TestDataFactory.createAccountdealer(true);
        dealerAccount.shippingStreet='4300 S Georgia St';
        dealerAccount.shippingCity='DALLAS';
        dealerAccount.shippingState='TX';
        dealerAccount.shippingPostalCode='79110-1722';
        dealerAccount.POIID__c='RJ';
        update dealerAccount;
        WebStore testStore = B2B_TestDataFactory.createStore(true);
        
        WebCart testcart = B2B_TestDataFactory.createCart(true, testAccount.Id, testStore.Id);
        testcart.DealerId__c=dealerAccount.id;
        testcart.CustomerStreet__c='4300 S Georgia St';
        testcart.CustomerCity__c='DALLAS';
        testcart.Customer_State__c='TX';
        testcart.CustomerPostalCode__c='79110-1722';
        testcart.ShippingAmount__c=206500;
        update testcart;
        
        CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, testcart.Id);
        Product2 prod = B2B_TestDataFactory.createProduct(true);
        Product2 testProd = [SELECT Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c 
                             FROM Product2
                             WHERE Id =: prod.Id];
        CartItem cItem = B2B_TestDataFactory.createCartItem(true, testcart.Id, testdelivery.Id,testProd.Id);
    }
    
    @isTest
    public static void Testmethod1(){
        List<Id> testcart=new List<Id>();
        for(Webcart we:[SELECT id FROM webCart])
            testcart.add(we.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
        B2B_TaxHelperV2.syncTax(testcart);
        Test.stopTest();
        
    }
    
    //added by mathi
    @isTest
    public static void Testsynctax(){
        Test.startTest();
        try{
            B2B_TaxHelperV2.syncTax(null);
        }
        catch(exception e){}
        Test.stopTest();
    }
    
    @isTest
    public static void Testmethod2(){
        Map<String, Decimal> cartItemTotalPriceBySKU = new Map<String, Decimal>();
        B2B_TaxHelperV2 Tax=new B2B_TaxHelperV2();
        CartItem citem = [SELECT id,Product2Id 
                          FROM CartItem LIMIT 1];
        Product2 pid = [SELECT id,StockKeepingUnit 
                        FROM Product2 
                        WHERE id =: citem.Product2Id];
        citem.TotalPrice=2.4;
        citem.Sku=pid.StockKeepingUnit;
        update citem;
        CartDeliveryGroup  deliverygroup = [SELECT id 
                                            FROM CartDeliveryGroup LIMIT 1];
        deliverygroup.DeliverToState='TX';
        deliverygroup.DeliverToCountry='US';
        update deliverygroup;
        cartItemTotalPriceBySKU.put(citem.Sku,citem.TotalPrice);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.stopTest();
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson='{ "data" :  {"createClientToken" :  {"createClientToken": {"createClientToken" : [ {"createClientToken":"test" , "clientToken" : "testing"}] } , "clientToken" : "testing"} }}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void Testmethod3(){
        Account dealerAccount = B2B_TestDataFactory.createAccountdealer(true);
        WebStore testStore = [SELECT id  
                              FROM WebStore LIMIT 1];
        WebCart testcartnegative = B2B_TestDataFactory.createCart(true, dealerAccount.Id, testStore.Id);
        sfdc_checkout.IntegrationInfo integinfo = new sfdc_checkout.IntegrationInfo();
    }
    
    @isTest
    public static void Testmethod4(){
        WebCart testcart = [SELECT id 
                            FROM WebCart LIMIT 1];
        B2B_TaxHelperV2.integrationStatusFailedWithCartValidationOutputError('istype2','errorMessage','integinfo',testcart.id);
    }
    
    @isTest
    public static void Testmethod5(){
        List<Id> testcart=new List<Id>();
        for(Webcart we:[SELECT id FROM webCart])
            testcart.add(we.id);
        id cartid=testcart[0];
        Test.startTest();
        B2B_TaxHelperV2.syncTax(testcart);
        B2B_TaxHelperV2.startCartProcessMegaSync(cartid,'22201','33.25','Cart');
    }
    
    @isTest
    public static void unitTest1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
        Map<String,String> dealerAddressMap = new Map<String,String>();
        dealerAddressMap.put('streetAddress','4300 S Georgia St');
        dealerAddressMap.put('city','AMARILLO');
        dealerAddressMap.put('mainDivision', 'TX');
        dealerAddressMap.put('postalCode', '79110-1722');
        
        Map<String,String> customerAddressMap = new Map<String,String>();
        customerAddressMap.put('streetAddress', '1234 Main Street');
        customerAddressMap.put('city','DALLAS');
        customerAddressMap.put('mainDivision', 'TX');
        customerAddressMap.put('postalCode', '75201');
        
        Map<String,String> dealerAddress = New Map<String,String>();
        dealerAddress.put('streetAddress1','4300 S Georgia St');
        dealerAddress.put('streetAddress2','');
        dealerAddress.put('city','AMARILLO');
        dealerAddress.put('mainDivision','TX');
        dealerAddress.put('postalCode','75001');
        dealerAddress.put('country','USA');
        
        Test.stopTest();
        //call vertex methods
        B2B_VertexTaxCalculationIntegration.vertexAddressCleansing(dealerAddress);
    }
    
    @isTest 
    public static void unitTestNegative(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
        
        Map<String,String> customerAddressMap = new Map<String,String>();
        customerAddressMap.put('streetAddress', '1234 Main Street');
        customerAddressMap.put('city','DALLAS');
        customerAddressMap.put('mainDivision', 'TX');
        customerAddressMap.put('postalCode', '75201');
        
        Map<String,String> dealerAddress = New Map<String,String>();
        dealerAddress.put('streetAddress1','4300 S Georgia St');
        dealerAddress.put('streetAddress2','');
        dealerAddress.put('city','AMARILLO');
        dealerAddress.put('mainDivision','TX');
        dealerAddress.put('subDivision','');
        dealerAddress.put('postalCode','75001');
        dealerAddress.put('country','null');
        
        Test.stopTest();
        //call vertex methods
        B2B_VertexTaxCalculationIntegration.vertexAddressCleansing(dealerAddress);
    }
    
    @Istest 
    //Added this method to cover the code 
    public static void testingname(){
        List<Id> testcart=new List<Id>();
        for(Webcart we:[SELECT id FROM webCart])
            testcart.add(we.id);
        id cartid=testcart[0];
        
        Map<String,String> customerAddressMap = new Map<String,String>();
        customerAddressMap.put('streetAddress', '1234 Main Street');
        customerAddressMap.put('city','DALLAS');
        
        Map<String,String> dealerAddressMap = New Map<String,String>();
        dealerAddressMap.put('streetAddress1','4300 S Georgia St');
        dealerAddressMap.put('streetAddress2','');
        
        B2B_VertexTaxCalculationIntegration.calculateTaxQuotation(cartId,dealerAddressMap,customerAddressMap,'RJ','33.13','2.13','commit','nocart');  
        B2B_VertexTaxCalculationIntegration.calculateTaxQuotation(cartId,dealerAddressMap,customerAddressMap,'RJ','33.13','2.13','commit','Cart');
        B2B_VertexTaxCalculationIntegration.calculateTaxQuotation(cartId,dealerAddressMap,customerAddressMap,'RJ','33.13','2.13','return','Cart');
    }
    //added by mathi
    
    private class RestMock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Product2 objProduct2  = [Select Id From Product2 Limit 1];
            WebCart objWebCart = [Select Id From WebCart Limit 1];
            WebCart objWebCart2 = [Select Id From WebCart Limit 1];
            Product2 prod = [SELECT id
                             FROM product2 LIMIT 1]; 
            CartDeliveryGroup cartdelivery = [SELECT id 
                                              FROM CartDeliveryGroup LIMIT 1];
            cartItem cartItems=B2B_TestDataFactory.createCartItem(True,objWebCart2.id,cartdelivery.id,prod.id);
            String fullJson = '{"productId" : "' + objProduct2 + '", "quantity" :100, "type" : "Product", "cartItemId" : "'+cartItems.Id+'"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(202);
            res.setStatus('created');
            return res;
        }
    }
    
    @isTest
    public static void testcalculateTaxQuotation(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        List<Id> testcart=new List<Id>();
        for(Webcart we:[SELECT id 
                        FROM webCart])
            testcart.add(we.id);
        id cartid=testcart[0];
        
        Map<String,String> customerAddressMap = new Map<String,String>();
        customerAddressMap.put('streetAddress', '1234 Main Street');
        customerAddressMap.put('city','DALLAS');
        
        Map<String,String> dealerAddressMap = New Map<String,String>();
        dealerAddressMap.put('streetAddress1','4300 S Georgia St');
        dealerAddressMap.put('streetAddress2','');
        
        B2B_VertexTaxCalculationIntegration.calculateTaxQuotation(cartId,dealerAddressMap,customerAddressMap,'RJ','33.13','2.13','commit','nocart');  
        B2B_VertexTaxCalculationIntegration.calculateTaxQuotation(cartId,dealerAddressMap,customerAddressMap,'RJ','33.13','2.13','commit','Cart');
        B2B_VertexTaxCalculationIntegration.calculateTaxQuotation(cartId,dealerAddressMap,customerAddressMap,'RJ','33.13','2.13','return','Cart');
        test.stopTest();
    }
    
}
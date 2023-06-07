/**********************************************************************
Name: B2B_VertexTaxCalculationIntegrationTest
Purpose: Test Class for Vertex Tax Calculation.
Created By : Radhey Shyam Gupta
Modified By : 
1. Apoorv Garg : 05/07/2021
*************************************************************/

@isTest
public class B2B_VertexTaxCalculationIntegrationTest {
    @isTest
    public static void unitTest1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
        Account testAccount = B2B_TestDataFactory.createAccount(true);
       	WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, testAccount.Id, testStore.Id);
       	CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, testcart.Id);
       	Product2 prod = B2B_TestDataFactory.createProduct(true);
        Product2 testProd = [Select Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c From Product2 Where Id =: prod.Id];
        CartItem cItem = B2B_TestDataFactory.createCartItem(true, testcart.Id, testdelivery.Id,testProd.Id);
        
        Map<String,String> dealerAddressMap = new Map<String,String>();
        dealerAddressMap.put('streetAddress', '4300 S Georgia St');
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
        Account testAccount = B2B_TestDataFactory.createAccount(true);
       	WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, testAccount.Id, testStore.Id);
        CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, testcart.Id);
        Product2 prod = B2B_TestDataFactory.createProduct(true);
        Product2 testProd = [Select Length_in__c,Width_in__c,Height_in__c,Weight_lbs__c,B2B_Volume__c From Product2 Where Id =: prod.Id];
        CartItem cItem = B2B_TestDataFactory.createCartItem(true, testcart.Id, testdelivery.Id,testProd.Id);
        
        Map<String,String> dealerAddressMap = new Map<String,String>();
        dealerAddressMap.put('streetAddress', '4300 S Georgia St');
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
        dealerAddress.put('subDivision','');
        dealerAddress.put('postalCode','75001');
        dealerAddress.put('country','null');
       
        Test.stopTest();
        //call vertex methods
        B2B_VertexTaxCalculationIntegration.vertexAddressCleansing(dealerAddress);
    }
}
/*******************************************************************************
	Name: B2B_ShippingHelperV2Test
Business Unit: HDM
	Date: 06/07/2021
	Developer: Soumya Sahoo
	Description: This Test Class covers B2B_ShippingHelperV2 class.
	*******************************************************************************
	MODIFICATIONS – 09/06/2022 | Sayalee Brahmankar |Added Header
	*******************************************************************************/

@isTest
public class B2B_ShippingHelperV2Test {
	 @testsetup
    public static void createSetupData(){
        User objUser = [Select Id FROM User LIMIT 1 ];
        B2B_Fedex_Shipping_Box__mdt objFedexBox=[Select DeveloperName,B2B_Height__c,B2B_Length__c,B2B_Width__c,B2B_Package_Volume__c 
        FROM B2B_Fedex_Shipping_Box__mdt 
        ORDER BY B2B_Package_Volume__c ASC 
        LIMIT 1];
        
        
        Contact con=B2B_TestDataFactory.createContact(true);
        Account objAccount = B2B_TestDataFactory.createAccountdealer(true);
        WebStore objWebStore = B2B_TestDataFactory.createStore(true);
        WebCart objWebCart =  B2B_TestDataFactory.createCart(true,objAccount.Id, objWebStore.Id);
        CartDeliveryGroup objCartDeliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(true,objWebCart.Id);
        
        Product2 objProduct2 = B2B_TestDataFactory.createProduct(true);
        	objProduct2.Length_in__c = 0.59;
        	objProduct2.Width_in__c = 0.39;
       	    objProduct2.Height_in__c = 0.39;
        UPDATE objProduct2;
        
        OrderDeliveryMethod objOrderDeliveryMethod = B2B_TestDataFactory.createOrderDeliveryMethod(true,'test',objProduct2.Id);
        
        cartItem cartitm = new cartItem();
        
        	B2B_Custom_Settings__c objCustomSetting = B2B_TestDataFactory.createCustomSetting(true,objAccount.Id, objUser.Id);
        		cartitm=B2B_TestDataFactory.createCartItem(true, objWebCart.Id, objCartDeliveryGroup.Id, objProduct2.Id );
        		cartitm.Quantity=1;
        UPDATE cartitm;
        	Order ord = B2B_TestDataFactory.createOrder(true, objAccount.Id, objWebCart.Id);
        	OrderItem orditem = B2B_TestDataFactory.createOrderItem(true,ord.Id,objProduct2.Id);

    }
    @isTest
    public static void Testmethod1(){
        List<Id> testcart=new List<Id>();
        	for(Webcart we:[select id FROM webCart])
                testcart.add(we.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_FedexShippingCalculationCalloutMock());
        B2B_ShippingHelperV2.syncDelivery(testcart);
        Test.stopTest();
        
    }
    @isTest
    public static void Testmethod2(){
      WebCart cart2=[select id FROM webcart LIMIT 1];
        	  cart2.Pickup_Dealer__c=true;
        	  cart2.ShippingAmount__c=null;
        update cart2;
        List<Id> testcart=new List<Id>();
        	for(Webcart we:[SELECT id,Pickup_Dealer__c,ShippingAmount__c FROM webCart])
                testcart.add(we.id);
        
        
        					   B2B_ShippingHelperV2.syncDelivery(testcart);
    }
    
    @isTest
    public static void Testmethod4(){
        WebCart testcart=[SELECT id FROM WebCart LIMIT 1];
        //B2B_ShippingHelperV2.integrationStatusFailedWithCartValidationOutputError('istype2','errorMessage','integinfo',testcart.id);
    }
     @isTest
    public static void Testmethod5(){
        List<Id> testcart=new List<Id>();
        	for(Webcart we:[SELECT id FROM webCart])
                testcart.add(we.id);
        Test.startTest();
        						
        					   B2B_ShippingHelperV2.syncDelivery(testcart);
        Test.stopTest();
    }
     @isTest
    public static void Testmethod6(){
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
        List<Id> testcart=new List<Id>();
        	for(Webcart we:[SELECT id FROM webCart])
                testcart.add(we.id);
       Test.startTest();
        
       
        Test.setMock(HttpCalloutMock.class, new B2B_FedexShippingCalculationCalloutMock());
        					  B2B_ShippingHelperV2.syncDelivery(testcart);
        Test.stopTest();
    }
    
}
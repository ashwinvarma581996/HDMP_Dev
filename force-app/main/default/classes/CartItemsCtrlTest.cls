/**
* @File Name          : CartItemsCtrlTest
* @Description        : It is created to code coverage for CartItemsCtrl apex class.
* @Modified By        : Yashika
* @Date               : 26/05/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    	05/04/2021				 Soumya Sahoo            Initial Version
* 2.0       01/06/2022				 Ravi Prasad			 Updated the test methods and refactor the code.
**/
@isTest
public class CartItemsCtrlTest {
    
    @testSetup
    private static void createSetupData(){
        User objUser = [Select Id from User LIMIT 1 ];
        
        Contact con=B2B_TestDataFactory.createContact(true);
        Account objAccount = B2B_TestDataFactory.createAccountdealer(true);
        
        WebStore objWebStore = B2B_TestDataFactory.createStore(true);
        WebCart objWebCart =  B2B_TestDataFactory.createCart(true,objAccount.Id, objWebStore.Id);
        
        CartDeliveryGroup objCartDeliveryGroup = B2B_TestDataFactory.createCartDeliveryGroup(true,objWebCart.Id);
        
        Product2 objProduct2 = B2B_TestDataFactory.createProduct(true);
        OrderDeliveryMethod objOrderDeliveryMethod = B2B_TestDataFactory.createOrderDeliveryMethod(true,'test',objProduct2.Id);
        
        B2B_Custom_Settings__c objCustomSetting = B2B_TestDataFactory.createCustomSetting(true,objAccount.Id, objUser.Id);
        
        cartItem cartitm = new cartItem();
        cartitm = B2B_TestDataFactory.createCartItem(true, objWebCart.Id, objCartDeliveryGroup.Id, objProduct2.Id );
        Order ord = B2B_TestDataFactory.createOrder(true, objAccount.Id, objWebCart.Id);
        OrderItem orditem = B2B_TestDataFactory.createOrderItem(true,ord.Id,objProduct2.Id);
        
        objProduct2.Length_in__c=0;
        objProduct2.PickupatDealer__c=true;
        objProduct2.Width_in__c=170;
        UPDATE objProduct2;
        
        CartCheckoutSession c=new CartCheckoutSession();
        c.state='Order Confirmation';
        c.NextState='Payment And Billing Address';
        c.WebCartId=objWebCart.Id;
        c.Name='Order';
        INSERT c;      
    }
    
    @isTest 
    public static void TestRedirectToBackScreen() {
        WebCart c  = [Select Id FROM WebCart LIMIT 1];
        Order ord=[select Id FROM Order LIMIT 1];
        CartCheckoutSession cSession = [SELECT Id,state,NextState FROM CartCheckoutSession LIMIT 1];
        string value;
        string pstate='Checkout Summary';
        string nstate='Payment And Billing Address';
        test.startTest();
        value=CartItemsCtrl.redirectToBackScreen(pstate, nstate, c.Id, ord.Id);
        CartItemsCtrl.gettotalamount(c.Id);
        test.stopTest();
    }
    
        
    @isTest 
    public static void TestRedirectToBackScreen1() {
            try{
        //WebCart c  = [Select Id FROM WebCart LIMIT 1];
        //Order ord=[select Id FROM Order LIMIT 1];
        //CartCheckoutSession cSession = [SELECT Id,state,NextState FROM CartCheckoutSession LIMIT 1];
        string value;
        //string pstate='Checkout Summary';
        //string nstate='Payment And Billing Address';
    
        test.startTest();
        value=CartItemsCtrl.redirectToBackScreen(null, null, null, '');
        //CartItemsCtrl.gettotalamount(c.Id);
        test.stopTest();
        }
        catch (exception ex){}
    }
    @isTest
    public static void getCustomLabelsTest(){
        test.startTest();
        CartItemsCtrl.getCustomLabels();
        CartItemsCtrl.getCustomLabelforCartShippingSummary();
        test.stopTest();
    }

    @isTest 
    public static void TestgetCartItemList() {
        WebCart c  = [Select Id FROM WebCart LIMIT 1];
        CartItemsCtrl.getCartItemList(c.Id);
        CartItemsCtrl.getCartItemList2(c.Id);
        CartItemsCtrl.getCartItemList3(c.Id);
        CartItemsCtrl.setDefaultDealerInstallation(c.Id);
        CartItemsCtrl.getCartDeliveryType(c.Id);
    }
    
    @isTest 
    public static void TestgetTotalQuantity() {
        WebCart c  = [Select Id FROM WebCart LIMIT 1];
        CartItemsCtrl.gettotalquantity(c.Id);
    }
    
    @isTest 
    public static void TestgetCartInfo() {
        WebCart c = [Select Id FROM WebCart LIMIT 1];
        CartItemsCtrl.getCartInfo(c.Id);
    }
    
    @TestVisible virtual B2B_Fedex_Shipping_Box__mdt[] getAllMetadata() {
        return [Select DeveloperName,B2B_Height__c,B2B_Length__c,B2B_Width__c,B2B_Package_Volume__c 
        FROM B2B_Fedex_Shipping_Box__mdt];
    }
    
    @isTest 
    public static void TestcheckPackageHWL() {
        WebCart c  = [Select Id FROM WebCart Limit 1];
        
        boolean isvalue;
        B2B_Fedex_Shipping_Box__mdt objFedexBox=[Select DeveloperName,B2B_Height__c,B2B_Length__c,B2B_Width__c,B2B_Package_Volume__c 
        FROM B2B_Fedex_Shipping_Box__mdt 
        LIMIT 1];
        
        isvalue=CartItemsCtrl.checkPackageHWL(c.Id);
        cartItem ct=[select id,Product2Id FROM cartItem limit 1];
        Product2 prod=[select id FROM Product2 WHERE id=:ct.Product2Id];
        prod.Length_in__c=113;
        UPDATE prod;
        ct.Product2Id=prod.id;
        UPDATE ct;
        
        boolean isvalue2=CartItemsCtrl.checkPackageHWL(c.Id);
        cartItem ct2=[select id,Product2Id FROM cartItem limit 1];
        Product2 prod2=[select id FROM Product2 WHERE id=:ct.Product2Id];
        prod2.Length_in__c=1;
        prod2.Width_in__c=2;
        prod2.Height_in__c=3;
        UPDATE prod2;
        ct2.Product2Id=prod2.id;
        UPDATE ct2;
        boolean isvalue3=CartItemsCtrl.checkPackageHWL(c.Id);
        List<String> listPtoductsMissingDimensions = new List<String>();
        List<String> listPtoductsExceedingDimensions = new List<String>();
        
        Product2 p  = [Select Id FROM Product2 Limit 1];
        listPtoductsMissingDimensions.add(p.Id);
        listPtoductsExceedingDimensions.add(p.Id);
        B2B_CheckoutUtility.createErrorRecord('One or more products on this cart is missing the dimensions', null, 'One or more products on this cart is missing the dimensions::'+listPtoductsMissingDimensions, 'CartItemsCtrl', 'checkPackageHWL',c.Id,true,true);
        B2B_CheckoutUtility.createErrorRecord('User is trying to ship Product(s) that exceed(s) dimensions', null, 'A customer attempted to purchase an item on Dreamshop that exceeded 108” in length or 165" in width and could not be shipped::'+listPtoductsExceedingDimensions, 'CartItemsCtrl', 'checkPackageHWL',c.Id,true,true);        
    }
    
    @isTest 
    public static void TestupdateCart() {
        WebCart c  = [Select Id,Pickup_Dealer__c,CustomerStreet__c,Customer_State__c,CustomerCity__c,CustomerCountry__c,CustomerPostalCode__c, Customer_Name__c, Customer_Phone__c,Customer_Email__c
                      FROM WebCart 
                      LIMIT 1];
        string value;
        string value2;
        CartItemsCtrl.fetchShippingSpeeds();
        value=CartItemsCtrl.updateCart(c.Id, c.CustomerStreet__c, c.CustomerCity__c, c.Customer_State__c, c.CustomerCountry__c, c.CustomerPostalCode__c, c.Pickup_Dealer__c, c.Customer_Name__c, c.Customer_Phone__c,c.Customer_Email__c, '');
               
        value2=CartItemsCtrl.updateCart(c.Id,'test1','test2','te','test4','test5',True, 'test7', 'test8','test9@gmail.com', '');
    }
        @isTest 
    public static void TestupdateCart1() {
        try{
        WebCart c  = [Select Id,Pickup_Dealer__c,CustomerStreet__c,Customer_State__c,CustomerCity__c,CustomerCountry__c,CustomerPostalCode__c, Customer_Name__c, Customer_Phone__c,Customer_Email__c
                      FROM WebCart 
                      LIMIT 1];
       // string value;
        string value2;
        CartItemsCtrl.fetchShippingSpeeds();
               value2=CartItemsCtrl.updateCart(null,null,null,null,null,null,null, null, null,null,null);
        }
        catch (exception ex){
            
        }
       
    }
    
    @isTest 
    public static void proceedCheckoutTest() {
        WebCart c  = [Select Id, Tax_Amount_Error_Message__c FROM WebCart LIMIT 1];
        cartItem cc = [select id FROM cartitem LIMIT 1];
        c.Tax_Amount_Error_Message__c = 'error';
        UPDATE c;
        CartItemsCtrl.CheckoutCompatibility check = CartItemsCtrl.proceedCheckout(c.Id);
    }
        @isTest 
    public static void proceedCheckoutTest1() {
        try{
        CartItemsCtrl.CheckoutCompatibility check = CartItemsCtrl.proceedCheckout(null);
        }
        catch (exception ex){
            
        }
    }
    
    @isTest 
    public static void proceedCheckoutWithoutDealerTest() {
        WebCart c  = [Select Id, Tax_Amount_Error_Message__c, Total_Tax__c 
        FROM WebCart 
        LIMIT 1];
        cartItem cc = [select id from cartitem limit 1];
        c.Tax_Amount_Error_Message__c = null;
        c.Total_Tax__c = 100;
        UPDATE c;
        
        CartItemsCtrl.CheckoutCompatibility check = CartItemsCtrl.proceedCheckout(c.Id);
    }
    
    @isTest 
    public static void proceedCheckoutFromDealerTest() {
        WebCart c = [Select Id, Delivery_Type__c, Pickup_Dealer__c, Tax_Amount_Error_Message__c, Total_Tax__c  
        FROM WebCart 
        LIMIT 1];
        c.Pickup_Dealer__c = true;
        c.Tax_Amount_Error_Message__c = 'test';
        c.Total_Tax__c = null;
        UPDATE c;
        
        CartItemsCtrl.CheckoutCompatibility check = CartItemsCtrl.proceedCheckout(c.Id);
    }
    
    @isTest 
    public static void proceedCheckoutFromDealerTaxTest() {
        WebCart c = [Select Id, Delivery_Type__c, Pickup_Dealer__c, Total_Tax__c  FROM WebCart LIMIT 1];
        c.Pickup_Dealer__c = true;
        c.Total_Tax__c = 100;
        UPDATE c;
        
        CartItemsCtrl.CheckoutCompatibility check = CartItemsCtrl.proceedCheckout(c.Id);
    }
    
    @isTest 
    public static void TestgetOrderInfo() {
        Order ord  = [Select Id FROM Order LIMIT 1];
        CartItemsCtrl.getOrderInfo(ord.Id);
    }
    
    @isTest
    public static void TestsetDealerInstallationType(){
        WebCart c  = [Select Id, Delivery_Type__c, OwnerId FROM WebCart LIMIT 1];
        CartDeliveryGroup cdg = new CartDeliveryGroup();
        cdg.Name = 'Test Delivery Group';
        cdg.CartId = c.Id;
        INSERT cdg;
        
        CartItem ci = new CartItem();
        ci.CartId = c.Id;
        ci.Name = 'Test Item';
        ci.CartDeliveryGroupId = cdg.Id;
        ci.Product_Type__c = 'Accessory';
        INSERT ci;
        
        CartItemsCtrl.setDealerInstallationType(c.id, c.Delivery_Type__c);
    }
    
    @isTest
    public static void setDefaultDealerInstallationCatchExceptionTest(){
        try{
            WebCart c  = [Select Id, Delivery_Type__c, OwnerId FROM WebCart LIMIT 1];
            
            CartItemsCtrl.setDealerInstallationType(c.id, 'Test');
        } catch (Exception ex) {
            
        }
    }
        
    @isTest
    public static void TestgetDealerInformation(){
        Account acc = [select id,Name FROM Account LIMIT 1];        
        CartItemsCtrl.getDealerInformation(acc.Id);
    }
    
    @isTest
    public static void TestUpdateDealerPrice(){
        
        WebCart c  = [Select Id,Delivery_Type__c FROM WebCart LIMIT 1];
        Test.startTest();
        CartItemsCtrl.updateDealerPrice(c.id,'1'); 
        Test.stopTest();
    }
    
    @isTest
    public static void TestChangeStatusWithDeliveryMethod(){
        
        WebCart c  = [Select Id,Delivery_Type__c FROM WebCart LIMIT 1];
        Account acc1=[Select Id, PoIId__c FROM Account LIMIT 1];
        acc1.PoIId__c='206506';
        UPDATE acc1;
        Order ord=[select Id FROM Order LIMIT 1];
        c.Pickup_Dealer__c=true;
        c.Tax_Amount_Error_Message__c='test';
        c.Total_Tax__c=null;
        c.DealerId__c=acc1.Id;
        c.ownerId = UserInfo.getUserId();
        UPDATE c;
        Account acc = [select id,Name FROM Account LIMIT 1];
        WebStore ws = [select id,Name FROM WebStore LIMIT 1];
        
        CartDeliveryGroup cartgroup = new CartDeliveryGroup();
        cartgroup.Name = 'Test Delivery Group';
        cartgroup.CartId = c.id;
        INSERT cartgroup;
        
        cartItem cit = new cartItem();
        cit.op_code__c = 'TLX0020034';
        cit.Sku = '12300-P0G-A01';
        cit.CartId = c.id;
        cit.Name = 'Test Cart Item';
        cit.CartDeliveryGroupId = cartgroup.id;
        cit.Product_Type__c = 'Part';
        cit.unitAdjustedPrice = Decimal.valueOF('260.08');
        cit.SalesPrice = Decimal.valueOF('260.08');
        cit.Quantity=1;
        INSERT cit;
        
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationMock());
        String result = B2B_INSystemIntegration.GetDealerPrice('206506',1,'12300-P0G-A01','ACCOR17005');
        
        CartItemsCtrl.changeStatusWithDeliveryMethod(c.id,'1'); 
        Test.stopTest();
    }
    
    @isTest
    public static void TestChangeStatusWithDeliveryMethod1(){
        
        WebCart c  = [Select Id,Delivery_Type__c FROM WebCart LIMIT 1];
        Order ord=[select Id FROM Order LIMIT 1];
        c.Pickup_Dealer__c=true;
        c.Tax_Amount_Error_Message__c='test';
        c.Total_Tax__c=null;
        c.ownerId = UserInfo.getUserId();
        UPDATE c;
        
        Account acc = [select id,Name FROM Account LIMIT 1];
        WebStore ws = [select id,Name FROM WebStore LIMIT 1];
        
        CartDeliveryGroup cartgroup = new CartDeliveryGroup();
        cartgroup.Name = 'Test Delivery Group';
        cartgroup.CartId = c.id;
        INSERT cartgroup;
        
        cartItem cit = new cartItem();
        cit.op_code__c = 'ACCOR17110';
        cit.Sku = '12300-P0G-A01';
        cit.CartId = c.id;
        cit.Name = 'Test Cart Item';
        cit.CartDeliveryGroupId = cartgroup.id;
        cit.Product_Type__c = 'Accessory';
        cit.unitAdjustedPrice = Decimal.valueOF('260.08');
        cit.SalesPrice = Decimal.valueOF('260.08');
        cit.Quantity=1;
        INSERT cit;
                
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationMock());
        String result = B2B_INSystemIntegration.GetDealerPrice('206506',1,'12300-P0G-A01','ACCOR17110');
        
        CartItemsCtrl.changeStatusWithDeliveryMethod(c.id,'1');  
        Test.stopTest();
              
    }
    
    @isTest
    public static void TestgetCartCountTotal(){
        WebCart c  = [Select Id FROM WebCart LIMIT 1];
        CartItemsCtrl.getCartCountTotal(c.id);
    }

    @isTest
    public static void TestreCalculateTaxOnChangeShippingSpeed(){
        WebCart c  = [Select Id,ShippingAmount__C, Is_PayPal_Checkout__c FROM WebCart LIMIT 1];
        c.Is_PayPal_Checkout__c = true;
        UPDATE c;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
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
        
        string x = string.valueOf(c.ShippingAmount__c);
        CartItemsCtrl.reCalculateTaxOnChangeShippingSpeed(c.id,x,'');
       
        
    }
    
    @isTest
    public static void getStrLogoUrlTest(){
        CartItemsCtrl crt = new CartItemsCtrl();
        List<Document> doc = [select Name FROM Document WHERE Name = 'dreamshop'];
        Test.startTest();
        crt.getStrLogoUrl();
        Test.stopTest();
    }
    @isTest
    public static void testReturnCheckoutState(){
        WebCart c  = [Select Id FROM WebCart LIMIT 1];
        string s= CartItemsCtrl.returnCheckoutState(c.Id);
    }
}
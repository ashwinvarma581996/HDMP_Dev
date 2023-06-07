@isTest(seeAllData=true)
public class B2B_DealerEmailTest {
    
  @isTest
    public static void insertDealerEmailBasedOnOrderId(){
         Test.startTest();
        List<B2B_DealerEmail.FlowInputs> flowInpList = new List<B2B_DealerEmail.FlowInputs>();
        Account objAccount = B2B_TestDataFactory.createAccount(true, 'ffsfsf');
        Order objOrder = createTestData(objAccount);   
        OrderSummary os=new OrderSummary();
        os.Status='Created';
        os.Billing_Email_Address_User_Email__c='saitest@test.com';   
        B2B_DealerEmail.FlowInputs flowInputs=new B2B_DealerEmail.FlowInputs();
        flowInputs.orderId=objOrder.Id;
        flowInputs.orderSummaryId=[select id from OrderSummary Limit 1].Id;
        flowInpList.add(flowInputs);
        //Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock());  
        String body = '{"POIResponse":{"appid":"dreamshop.honda.com","Error":"false","ResultCount":"1","Version":"1","POIs":{"POI":[{"POIIdent":"6326","PageNumber":"1","PositionInPage":"1","POIId":"207478","POIType":"A","POIName":"Bernardi Honda","Email":"leads@bernardihondanatick.motosnap.com","InternetAddress":"","CorporationName":"Bernardis, Inc.","Address":"960 Worcester St ","City":"Natick","State":"MA","ZipCode":"01760-2033","MailingAddress":"960 Worcester St","MailingCity":"Natick","MailingState":"MA","MailingZip":"01760-2033","Country":"US","Ranking":null,"Phone":"(508) 651-3033","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(508) 651-1394","FaxCountryCode":"1","FaxExtension":null,"POISortOrder":"1","Distance":"0.0 miles","FullAddress":"960 Worcester St;Natick, MA 01760-2033","Latitude":"42.299217","Longitude":"-71.364029","Attributes":null,"Properties":null,"Departments":{"Department":[{"Cd":"PA","Name":"Parts Management","text":"Parts Management","Contact":[{"SequenceNo":"1","FirstName":"Erik","LastName":"Richards","Phone":"(508) 319-2261","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(508) 319-2261","FaxCountryCode":"1","FaxExtension":null,"Email":"erik.richards@bernardiauto.com"},{"SequenceNo":"2","FirstName":"Kanstantsin","LastName":"Varennikau","Phone":"(508) 319-2260","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(508) 656-2740","FaxCountryCode":"1","FaxExtension":null,"Email":"kanstantsin.varennikau@bernardiautogroup.com"},{"SequenceNo":"3","FirstName":"Juliana","LastName":"Richards","Phone":"(508) 651-3033","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(508) 651-1220","FaxCountryCode":"1","FaxExtension":null,"Email":"juliana.richards@bernardiautogroup.com"}],"OperationHour":[{"type":"consolidated","text":"Mon-Thu  7:00AM-7:00PM;Fri      7:00AM-6:00PM;Sat      7:30AM-4:00PM;Sun      Closed"}]}]}}]}}}';
        DynamicResponceMock objDynamicResponceMock = new DynamicResponceMock(200,body);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
        Test.setMock(HTTPCalloutMock.class, objDynamicResponceMock);   
        B2B_DealerEmail.inserDealerEmailBasedOnOrderId(flowInpList);
        Test.stopTest(); 
    }
    
    public static Order createTestData(Account objAccount){
      // 	Test.setMock(HttpCalloutMock.class, new B2B_VertexTaxCalculationCalloutMock());
      //  Test.setMock(HTTPCalloutMock.class, new B2B_BrainTreeIntegrationMock());         	 
        WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, objAccount.Id, testStore.Id);
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
        Order objOrder = B2B_TestDataFactory.createOrder(false, objAccount.Id, testcart.Id);
        objOrder.Updated_Order_Amount__c = 15000;
        objOrder.Updated_Order_Total__c = 15010;
        objOrder.Updated_Total_Tax__c = 10;
        objOrder.BT_Transaction_Id__c = 'fe67q2zd';
        objOrder.BT_Customer_Detail__c = 'dfrsedfg';
        objOrder.Payment_Method_Token__c = 'sdfgdaasfgdfsafgdeaw';
        objOrder.Current_Shipping_Tax__c = 0;
        objOrder.Return_Shipping_Tax__c = 0;
        insert objOrder;
        
        B2B_TestDataFactory.createBTTransactionDetails(true, objOrder.Id);
        
        OrderItem objOrderItem123 = B2B_TestDataFactory.createOrderItem(false, objOrder.Id, objProduct.Id); 
        objOrderItem123.Updated_Quantity__c = 2;  
        objOrderItem123.Dealer_Installation_Price__c = 25;
        objOrderItem123.Total_Tax__c = 10;
        objOrderItem123.Delta_Quantity__c = 2;
        objOrderItem123.Delta_Installation_Price__c = 12;
        insert objOrderItem123;
        system.debug('OrderItem123'+objOrderItem123);
        return objOrder;
    }
    
      private class DynamicResponceMock implements HttpCalloutMock {
        Integer statusCode;
        String requestBody;
        DynamicResponceMock(Integer statusCode,String requestBody){
            this.statusCode = statusCode;
            this.requestBody = requestBody;
        }
         public HTTPResponse respond(HTTPRequest req) {
             HttpResponse response = new HttpResponse();
             response.setHeader('Content-Type', 'application/json');
             response.setBody(requestBody);
             response.setStatusCode(statusCode);
             return response;
         }
     }

}
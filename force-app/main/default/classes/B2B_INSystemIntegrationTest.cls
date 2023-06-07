/*******************************************************************************
Name: B2B_INSystemIntegrationTest
Business Unit: HDM
Date: 25/05/2021
Developer: Apoorv Garg
Description: Test class for B2B_INSystemIntegration.
*******************************************************************************
MODIFICATIONS – Date | Dev Name 	| Method | User Story
		   26-5-2022 | Mathioli	    |  Error handling changes- JIRA- 8617
*******************************************************************************/

@isTest
public class B2B_INSystemIntegrationTest{
    
    @isTest
    public static void testGetModelByVinDecoder() {
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());             
        Test.startTest();
        String result = B2B_INSystemIntegration.GetModelByVinDecoder('1HGCR2F30GA073005', 1);
        Test.stopTest();
    }
    
    @isTest
    //created another method to cover line 77 to 88 
    public static void testGetModelByVinDecoder_negative() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMockData());             
        String result = B2B_INSystemIntegration.GetModelByVinDecoder('1HGCR2F30GA073006', 1);
        String result1 = B2B_INSystemIntegration.GetModelByVinDecoder('1HGCR2F30GA073007', 1);
        Test.stopTest();
    }
    
    @isTest
    //created another method to cover line 114 to 119
    public static void testGetModelByVinDecoderStatusCode() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());             
        String result = B2B_INSystemIntegration.GetModelByVinDecoder('1HGCR2F30GA073007', 1);
        Test.stopTest();
    }
    
    @isTest
    public static void testnegativeGetModelByVinDecoder() {
        Test.startTest();
        // Setting up the mock response
        String body = '{"Body":{"ErrorFlag": false,"ErrorCode": null,"ErrorType": null,"ErrorMessage": null,';
        body += '"VINInfo": {"ExternalColorCode": "NH797M","ExternalColorDescription": "MODERN STEEL M."},';
        body += '"Catalog": {"ProductCategories": [{"ID": 0,"Description": "AUTOMOBILE"}],"Products": [{"ID": 5,"Description": "ACCORD"}],"Doors": [{"ID": 4,"Description": "4"}],"Years": [{"ID": 4,"Description": "4"}],"Catalogs": [{"CatalogID": 134}],';
        body += '"SelectedProducts": [{"ProductID": 0}],"Origins": [{"ID": 2,"Description": "USA"}],"Areas": [{"ID": 4,"Description": "KL"}],"Grades": [{"ID": 5,"Description": "LX"}],"Transmissions": [{"ID": 4,"Description": "CVT"}],"ColorLabels": [{"ID": 2,"Description": "B-GRAY"}],"ColorNames": [{"ID": 2,"Description": "GRAY"}],';
        body += '"Sections": [{"ID": 1,"Description": "ENGINE","SectionURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/Sections/Section_1.png","ImageSize": 0}],"IllustrationGroups": null,"HotSpots": null,"Parts": null}},"": {"Code": "200","Status": "Success","Message": "",Errors":[{"ErrorMessage":"test", "ErrorCode":"test", "ErrorType": "test"}]}}';
        DynamicResponceMock objDynamicResponceMock = new DynamicResponceMock(200,body);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
        Test.setMock(HTTPCalloutMock.class, objDynamicResponceMock);             
        String result = B2B_INSystemIntegration.GetModelByVinDecoder('1HGCR2F30GA073004', 1);
        Test.stopTest();
    }
    
    @isTest
    public static void testCatchBlockGetModelByVinDecoder() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMockData());             
        String result = B2B_INSystemIntegration.GetModelByVinDecoder('0GA0730041HGCR2F3', 1);
        Test.stopTest();
    }
    
    @isTest
    public static void testfailureCatchBlockGetModelByVinDecoder() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMockData());             
        String result = B2B_INSystemIntegration.GetModelByVinDecoder('19UUB2F64LA003875', 1);
        Test.stopTest();
    }
    
    public static void testCatchBlock1GetModelByVinDecoder() {
        Test.startTest();
        String body = '{"Body":{"ErrorFlag": True,"ErrorCode": null,"ErrorType": null,"ErrorMessage": null,';
        body += '"VINInfo": {"ExternalColorCode": "NH797M","ExternalColorDescription": "MODERN STEEL M."},';
        body += '"Catalog": {"ProductCategories": [{"ID": 0,"Description": "AUTOMOBILE"}],"Products": [{"ID": 5,"Description": "ACCORD"}],"Doors": [{"ID": 4,"Description": "4"}],"Years": [{"ID": 4,"Description": "4"}],"Catalogs": [{"CatalogID": 134}],';
        body += '"SelectedProducts": [{"ProductID": 0}],"Origins": [{"ID": 2,"Description": "USA"}],"Areas": [{"ID": 4,"Description": "KL"}],"Grades": [{"ID": 5,"Description": "LX"}],"Transmissions": [{"ID": 4,"Description": "CVT"}],"ColorLabels": [{"ID": 2,"Description": "B-GRAY"}],"ColorNames": [{"ID": 2,"Description": "GRAY"}],';
        body += '"Sections": [{"ID": 1,"Description": "ENGINE","SectionURL": "https://staging.genuinehondaparts.honda.com/images/PARTSCATALOG/US/Honda/Catalogs/Sections/Section_1.png","ImageSize": 0}],"IllustrationGroups": null,"HotSpots": null,"Parts": null}}, "Header": {"Code": "200","Status": "Success","Message": "",Errors":[{"ErrorMessage":"test", "ErrorCode":"test", "ErrorType": "test"}]}}';
        DynamicResponceMock objDynamicResponceMock = new DynamicResponceMock(200,body);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
        Test.setMock(HTTPCalloutMock.class, objDynamicResponceMock);             
        // Setting up the mock response
        String result = B2B_INSystemIntegration.GetModelByVinDecoder('1HGCR2F30GA073006', 1);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetIllustrationBySectionID() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class,new B2B_INSystemIntegrationTestMock());
        String reqBody = null;
        String result = B2B_INSystemIntegration.GetIllustrationBySectionID(reqBody);
        Test.stopTest();
    }
    
    @isTest
    public static void testNegativeGetIllustrationBySectionID() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class,new B2B_INSystemIntegrationTestMock());
        String reqBody = '{"RegionID": 1,"DivisionID": 1,"LanguageID": 0,"ProductCategoryID": 0,"ProductID": 8,"DoorID": 0,"YearID": 32,"GradeID": 3481,"CatalogID": 151,"AreaID": 0,"OriginID": 0,"TransmissionID": 0,"ColorLabelID": 0,"ColorNameID": 0,"SectionID": 54321}'; 
        String result = B2B_INSystemIntegration.GetIllustrationBySectionID(reqBody);
        Test.stopTest();
    }
    
    //created another method to cover line 172-177
    @isTest
    public static void testNegativeGetIllustrationBySectionID_Statuscode() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class,new B2B_INSystemIntegrationTestMock());
        String reqBody = '{"RegionID": 1,"DivisionID": 1,"LanguageID": 0,"ProductCategoryID": 0,"ProductID": 8,"DoorID": 0,"YearID": 32,"GradeID": 3481,"CatalogID": 151,"AreaID": 0,"OriginID": 0,"TransmissionID": 0,"ColorLabelID": 0,"ColorNameID": 0,"SectionID": 64321}'; 
        String result = B2B_INSystemIntegration.GetIllustrationBySectionID(reqBody);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetPartsByIllustrationID() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        String reqBody = '{"RegionID": 1,"DivisionID": 1,"LanguageID": 0,"ProductCategoryID": 0,"ProductID": 7,"DoorID": 3,"YearID": 51,"GradeID": 3481,"CatalogID": 151,"AreaID": 0,"OriginID": 0,"TransmissionID": 0,"ColorLabelID": 0,"ColorNameID": 0,"SectionID": 1,"IllustrationGroupID": 1,"IllustrationGroupImageID": 569}';
        String result = B2B_INSystemIntegration.GetPartsByIllustrationID(reqBody);
        Test.stopTest();
    }
    
    @isTest
    public static void testNegativeGetPartsByIllustrationID() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        String reqBody = '{"RegionID": 1,"DivisionID": 1,"LanguageID": 0,"ProductCategoryID": 0,"ProductID": 7,"DoorID": 3,"YearID": 51,"GradeID": 3481,"CatalogID": 151,"AreaID": 0,"OriginID": 0,"TransmissionID": 0,"ColorLabelID": 0,"ColorNameID": 0,"SectionID": 1,"IllustrationGroupID": 1,"IllustrationGroupImageID": 234}';
        String result = B2B_INSystemIntegration.GetPartsByIllustrationID(reqBody);
        Test.stopTest();
    }
    
    //created another method to cover line 229 to 233
    @isTest
    public static void testGetPartsByIllustrationID_Statuscode() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        String reqBody = '{"RegionID": 1,"DivisionID": 1,"LanguageID": 0,"ProductCategoryID": 0,"ProductID": 7,"DoorID": 3,"YearID": 51,"GradeID": 3481,"CatalogID": 151,"AreaID": 0,"OriginID": 0,"TransmissionID": 0,"ColorLabelID": 0,"ColorNameID": 0,"SectionID": 1,"IllustrationGroupID": 1,"IllustrationGroupImageID": 432}';
        String result = B2B_INSystemIntegration.GetPartsByIllustrationID(reqBody);
        Test.stopTest();
    }
    
    @isTest
    public static void testNegativeGetPartsByIllustrationIDelse1() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        String reqBody = '{"RegionID": 1,"DivisionID": 1,"LanguageID": 0,"ProductCategoryID": 0,"ProductID": 7,"DoorID": 3,"YearID": 51,"GradeID": 3481,"CatalogID": 151,"AreaID": 0,"OriginID": 0,"TransmissionID": 0,"ColorLabelID": 0,"ColorNameID": 0,"SectionID": 1,"IllustrationGroupID": 1,"IllustrationGroupImageID": 431}';
        String result = B2B_INSystemIntegration.GetPartsByIllustrationID(reqBody);
        Test.stopTest();
    }
    
    @isTest
    public static void testSearchbyProduct() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        String result = B2B_INSystemIntegration.SearchbyProduct(11,2021,35,40,0,1,7);
        Test.stopTest();
    }
    
    @isTest
    public static void testNegativeSearchbyProduct() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        String result = B2B_INSystemIntegration.SearchbyProduct(1,2022,5,4,0,1,7);
        Test.stopTest();
    }
    
    @isTest
    public static void testElseSearchbyProduct() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        String result = B2B_INSystemIntegration.SearchbyProduct(1,2022,5,4,0,1,7);
        Test.stopTest();
    }
    
    @isTest
    public static void testcatchSearchbyProduct() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMockData());
        String result = B2B_INSystemIntegration.SearchbyProduct(1,2025,5,4,0,1,7);
        Test.stopTest();
    }
    
    @isTest
    public static void testProductDealerPrice() {
        Test.startTest();
        String reqBody = '{"PartNumber": 1, "DealerPrice":5000}';
        B2B_INSystemIntegration.getProductDealerPricing(reqBody);
        Test.stopTest();
    }
    
    //added by mathi
    @isTest
    public static void testProductDealerPrice1() {
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new RestMocktest());
        B2B_INSystemIntegration.getProductDealerPricing(null);
        Test.stopTest();
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String body = '{"Body": {"DealerNo": "206507","Division": "A","Parts": [{"PartNumber": "12300-P0G-A01","DealerPrice": 1153.32},{"PartNumber": "12300-P8E-306","DealerPrice": 88.81},{"PartNumber": "12300-P8F-307","DealerPrice": 14.80},{"PartNumber": "23411-P0X-000","DealerPrice": 107.60}]},';
            body += '"Accessories": [{"OpCode": "ACCOR17005","DealerPrice": 320.08,"DIYPrice": 260.08},{"OpCode": "ACCOR17110","DealerPrice": 440.08,"DIYPrice": 260.08}],"Header": {"Code": "200","Status": "Error","Message": ""}}';
            response.setBody(body);
            return response;
        }
    }
    
    private class RestMock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String body = '{"Body": {"DealerNo": "206507","Division": "A","Parts":  [{"PartNumber": "12300-P0G-A01","DealerPrice": 1153.32},{"PartNumber": "12300-P8E-306","DealerPrice": 88.81},{"PartNumber": "12300-P8F-307","DealerPrice": 14.80},{"PartNumber": "23411-P0X-000","DealerPrice": 107.60}]},';
            body += '"Accessories": [{"OpCode": "ACCOR17005","DealerPrice": 320.08,"DIYPrice": 260.08},{"OpCode": "ACCOR17110","DealerPrice": 440.08,"DIYPrice": 260.08}],"Header": {"Code": "200","Status": "Error","Message": ""}}';
            response.setBody(body);
            return response;
        }
    }
    
    @isTest
    public static void testGetDealerPrice() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        String result = B2B_INSystemIntegration.GetDealerPrice('2065287',1,'12300-P0G-A01','ACCOR17005');
        Test.stopTest();
    }
    
    @isTest
    public static void testGetDealerPriceNegative() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        String result = B2B_INSystemIntegration.GetDealerPrice('2065288',11,'12300-P0G-A01','ACCOR17005');
        Test.stopTest();
    }
    
    @isTest
    public static void testGetDealerPrice_Statuscode() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new RestMock());
        String result = B2B_INSystemIntegration.GetDealerPrice('206506',1,'12300-P0G-A01','ACCOR17005');
        Test.stopTest();
    }
    
    @isTest
    public static void testcatchPrice_Statuscode() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new B2B_INSystemIntegrationTestMockData());
        String result = B2B_INSystemIntegration.GetDealerPrice('206508',1,'12300-P0G-A01','ACCOR17005');
        Test.stopTest();
    }
    
    @isTest
    public static void testMaintenance() {
        Vehicle__c veh=B2B_TestDataFactory.createVehicle(true);
        B2B_TestDataFactory.createVehicleData(String.valueof(Vehicle__c.Model_Id__c));
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        //maintainenceProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer TransmissionID){
        String result = B2B_INSystemIntegration.maintainenceProduct(1,50,17,4,4965,149,9);
        Test.stopTest();
    }
    
    @isTest
    public static void testMaintenance1() {
        Vehicle__c veh=B2B_TestDataFactory.createVehicle(true);
        B2B_TestDataFactory.createVehicleData(String.valueof(Vehicle__c.Model_Id__c));
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new B2B_INSystemIntegrationTestMockData());
        //maintainenceProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer TransmissionID){
        String result = B2B_INSystemIntegration.maintainenceProduct(1,50,17,4,4965,149,9);
        Test.stopTest();
    }
    
    @isTest
    public static void testMaintenancetest() {
        Vehicle__c veh=B2B_TestDataFactory.createVehicle(true);
        B2B_TestDataFactory.createVehicleData(String.valueof(Vehicle__c.Model_Id__c));
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        //maintainenceProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer TransmissionID){
        String result = B2B_INSystemIntegration.maintainenceProduct(1,50,17,4,4967,149,9);
        Test.stopTest();
    }
    
    public static void testMaintenance2() {
        Vehicle__c veh=B2B_TestDataFactory.createVehicle(true);
        B2B_TestDataFactory.createVehicleData(String.valueof(Vehicle__c.Model_Id__c));
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new B2B_INSystemIntegrationTestMockData());
        //maintainenceProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer TransmissionID){
        String result = B2B_INSystemIntegration.maintainenceProduct(1,50,17,4,4966,149,9);
        Test.stopTest();
    }
     
    @isTest
    public static void testPartialSearch() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        //maintainenceProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer TransmissionID){
        String result = B2B_INSystemIntegration.PartialSearchbyProduct(1,52,4,4,3022,162,9,0,0,0,0,0,'16400-59B-003');
        Test.stopTest();
    }
    
    //added bymathi
    @isTest
    public static void testPartialSearch1() {
       Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new B2B_INSystemIntegrationTestMockData());
        //maintainenceProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer TransmissionID){
        String result = B2B_INSystemIntegration.PartialSearchbyProduct(1,52,4,4,3023,162,9,0,0,0,0,0,'16400-59B2003');
        Test.stopTest();
    }
    
    @isTest
    public static void testPartialSearch2() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        //maintainenceProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer TransmissionID){
        String result = B2B_INSystemIntegration.PartialSearchbyProduct(1,52,4,4,3024,162,9,0,0,0,0,0,'16400-59B-003');
        Test.stopTest();
    }
    
    @isTest
    public static void testNegativeDealerPrice() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        String result = B2B_INSystemIntegration.GetDealerPrice('2065288',2,'1-G-1','C005');//2044274
        Test.stopTest();
    }
    
    @isTest
    public static void testValidatePartsVIN() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        B2B_INSystemIntegration.ValidatePartsVIN(1,'1HGCR2F30GA073004','04635-T2F-A00ZZ');
        Test.stopTest();
    }
    
    @isTest
    public static void testValidatePartsVINSucessFailure() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        B2B_INSystemIntegration.ValidatePartsVIN(1,'1TRCR2F30GA073007','04635-T2F-A00ZZ');
        Test.stopTest();
    }
    
    @isTest
    public static void testNegativeValidatePartsVIN() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMock());
        B2B_INSystemIntegration.ValidatePartsVIN(1,'4S6CM58W2W4419771','8-17113-395-0');
        Test.stopTest();
    }
    
    @isTest
    public static void testerrorValidatePartsVIN() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_INSystemIntegrationTestMockData());
        B2B_INSystemIntegration.ValidatePartsVIN(1,'4S6CM58W2W4419778','8-17113-395-0');
        Test.stopTest();
    }
    
    private class RestMocktest implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson='{ "data" :  {"createClientToken" :  {"createClientToken": {"createClientToken" : [ {"createClientToken":"test" , "clientToken" : "testing"}] } , "clientToken" : "testing"} }}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setBody(null);
            res.setStatusCode(200);
            return res;
        }
    }
    
    public static void testPartialSearchtest() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HttpCalloutMock.class, new RestMocktest());
        //maintainenceProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer TransmissionID){
        B2B_INSystemIntegration.PartialSearchbyProduct(1, 1, 1,1,1,1,1,1,1,1,1,1,'search');
        Test.stopTest();
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
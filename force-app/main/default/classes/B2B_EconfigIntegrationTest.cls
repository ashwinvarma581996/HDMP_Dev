/**********************************************************************
Name: B2B_EconfigIntegrationTest
Business Unit:HDM
Date : 25/05/2021
Developer : Apoorv Garg 
Description: Test Class for B2B_EconfigIntegration,Mock class: B2B_EconfigIntegrationMock
MODIFICATIONS – 09/06/2022 | Mathioli | (Added header and removal of commented code)
*************************************************************/
@isTest
public class B2B_EconfigIntegrationTest {
    @testSetup 
    public static void setup(){
        B2B_TestDataFactory.createVehicle(true);
    }
    @isTest
    public static void testGetCompleteDetail() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock());    
        B2B_EconfigIntegration.getCompleteDetail('FC3B3KJW','A');
        Test.stopTest();
    }
    @isTest
    public static void testGetCompleteDetailNegative() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock());   
        B2B_EconfigIntegration.getCompleteDetail('FC3B3KJ','B');
        Test.stopTest();
    }
    @isTest
    public static void testGetCompleteDetailCatch() {
        Test.startTest();
        try{
            
            // Setting up the mock response
            Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock1());    
            B2B_EconfigIntegration.getCompleteDetail('F-648383','z');
        }
        catch( exception x ){}
        Test.stopTest();
    } 
    @isTest
    public static void  testcallVinDecoderService() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock());   
        B2B_EconfigIntegration.callVinDecoderService('19XFC1F33ME203650','A');
        Test.stopTest();
    }
    @isTest
    public static void  testcallVinDecoderServiceNegative() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock());   
        B2B_EconfigIntegration.callVinDecoderService('1HGCR','X');
        Test.stopTest();
    }
    
    @isTest
    public static void vertexCalloutTesting() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock());    
        B2B_EconfigIntegration.vertexCalloutTesting();
        Test.stopTest();
    }
    
    @isTest
    public static void testdealerLocatorService() {
        
        // Setting up the mock response
        Account objAccount = B2B_TestDataFactory.createAccount(true);  
        BT_Token_Details__c objTokens = B2B_TestDataFactory.createBTTokenDetails(true,objAccount.Id);
        Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock());   
        Test.startTest();
        B2B_EconfigIntegration.dealerLocatorService(B2B_Constant.HONDA_VALUE, '77034', 'Houston', 'TX','Big Star Honda', '200');
        Test.stopTest();
    }
    
    @isTest
    public static void testdealerLocatorServiceNegative() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock());  
        Test.stopTest();
    }
    @isTest
    public static void testElsePartdealerLocatorServiceNegative() {
        Test.startTest();
        // Setting up the mock response
        String body = '{"POIResponse":{"appid":"dreamshop.honda.com","Error":"false","ResultCount":"1","Version":"1","POIs":{"POI":[{"POIIdent":"6888","PageNumber":"1","PositionInPage":"1","POIId":"208602","POIType":"A","POIName":"Big Star Honda","Email":null,"InternetAddress":"https://www.bigstarhonda.com/","CorporationName":"Gl Bsh, LLC","Address":"11200 Gulf Fwy ","City":"Houston","State":"TX","ZipCode":"77034-3545","MailingAddress":"11200 GULF FREEWAY","MailingCity":"HOUSTON","MailingState":"TX","MailingZip":"77034","Country":"US","Ranking":null,"Phone":"(713) 948-1900","PhoneCountryCode":"1","PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"POISortOrder":"1","Distance":"0.0 miles","FullAddress":"11200 Gulf Fwy;Houston, TX 77034-3545","Latitude":"29.632517","Longitude":"-95.235489","Attributes":{"Attribute":[{"Code":"DA","Name":"Honda Digital Marketplace","Description":"This dealership participates in the Honda Dream Shop Marketplace","DetailedDescriptionDynamic":null,"IconURL":null,"SortOrder":"1","StartDate":"2021-06-01","EndDate":null}]},"Properties":null,"Departments":{"Department":[{"Cd":"AD","Name":"Business Management","text":"Business Management","Contact":[{"SequenceNo":"1","FirstName":"Alicia","LastName":"Wallis","Phone":"(713) 969-4461","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(713) 948-1999","FaxCountryCode":"1","FaxExtension":null,"Email":"awallis@bigstarhonda.com"}]},{"Cd":"DP","Name":"Dealer Principle","text":"Dealer Principle","Contact":[{"SequenceNo":"1","FirstName":"Alicia","LastName":"Wallis","Phone":"(713) 969-4461","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(713) 948-1999","FaxCountryCode":"1","FaxExtension":null,"Email":"awallis@bigstarhonda.com"}]},{"Cd":"D2","Name":"Dealership Mgr.","text":"Dealership Mgr.","Contact":[{"SequenceNo":"1","FirstName":"Martin","LastName":"Carcano","Phone":null,"PhoneCountryCode":null,"PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":null}]},{"Cd":"D1","Name":"Dlr. Principal","text":"Dlr. Principal","Contact":[{"SequenceNo":"1","FirstName":"John","LastName":"Garff","Phone":null,"PhoneCountryCode":null,"PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":null}]},{"Cd":"CE","Name":"eStore","text":"eStore","Contact":[{"SequenceNo":"1","FirstName":"Jose","LastName":"Navarrete","Phone":"(713) 969-4441","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(713) 948-1998","FaxCountryCode":"1","FaxExtension":null,"Email":"jnavarrete@bigstarhonda.com"}]},{"Cd":"FS","Name":"Financial Statement Accounting Manager","text":"Financial Statement Accounting Manager","Contact":[{"SequenceNo":"1","FirstName":null,"LastName":null,"Phone":null,"PhoneCountryCode":null,"PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":"awallis@bigstarhonda.com"}]},{"Cd":"SA","Name":"Internet Sales Management","text":"Internet Sales Management","Contact":[{"SequenceNo":"1","FirstName":null,"LastName":null,"Phone":"(713) 948-1900","PhoneCountryCode":"1","PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":null}],"OperationHour":[{"type":"consolidated","text":"Mon-Sun  Closed"}]},{"Cd":"PA","Name":"Parts Management","text":"Parts Management","Contact":[{"SequenceNo":"1","FirstName":"Jose","LastName":"Navarrete","Phone":"(713) 969-4441","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(713) 948-1998","FaxCountryCode":"1","FaxExtension":null,"Email":"jnavarrete@bigstarhonda.com"}],"OperationHour":[{"type":"consolidated","text":"Mon-Fri  7:00AM-6:00PM;Sat      7:00AM-5:00PM;Sun      Closed"}]},{"Cd":"SV","Name":"Service Management","text":"Service Management","Contact":[{"SequenceNo":"1","FirstName":"Robert","LastName":"Quintero","Phone":"(713) 969-4431","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(713) 948-1999","FaxCountryCode":"1","FaxExtension":null,"Email":"rquintero@bigstarhonda.com"},{"SequenceNo":"2","FirstName":"Omar","LastName":"Bravo","Phone":"(713) 969-4432","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(713) 948-1999","FaxCountryCode":"1","FaxExtension":null,"Email":"obravo@bigstarhonda.com"}],"OperationHour":[{"type":"consolidated","text":"Mon-Fri  7:00AM-6:00PM;Sat      7:00AM-5:00PM;Sun      Closed"}]},{"Cd":"UM","Name":"Used Car Management","text":"Used Car Management","Contact":[{"SequenceNo":"1","FirstName":"Stephanie","LastName":"Salazar","Phone":"(832) 259-9899","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(713) 948-1904","FaxCountryCode":"1","FaxExtension":null,"Email":"stephanies@bigstarhonda.com"}]}]}}]},"POIRequest":{"appid":"dreamshop.honda.com","AppId":"dreamshop.honda.com","POIId":null,"SearchWord":null,"Address":null,"City":"Houston","State":"TX","ZipCode":null,"Country":null,"Culture":null,"POIName":"Big Star Honda","POIIdent":null,"POIType":"A","Filters":"ATTR_A_DA","SearchRadius":"20","BoundingBox":null,"Latitude":null,"Longitude":null,"NumberOfPOIs":"20","POIGroupSize":null,"SortByPOIName":"false","SortOrderByAttribute":null,"StateOnly":"false","ShowDrivingDistance":"false","ReferenceCoordinates":null,"SearchWordOption":null,"GeocodeOnly":"false","IPAddress":null,"ConfidenceLevel":null,"ReferenceLocation":null,"RankingSource":null,"ShowAllAttributes":"False","ShowAllProperties":"False","ShowAllDepartments":"True","AttributeCdCSV":"DA","PropertyCdCSV":null,"DepartmentCdCSV":null,"FirstName":null,"LastName":null,"VIN":null,"GeocodeIfNotFound":"false","ServiceDomain":null,"SearchWordType":null,"LocationName":null,"AppIdParent":null,"OutPut":"json","Input":null,"RelationshipPOIOnly":"false","RequestID":null},"GeoCodeResults":{"Latitude":"29.7605800628662","Longitude":"-95.3696823120117","Locations":{"Location":[{"Type":"PopulatedPlace","Latitude":"29.7605800628662","Longitude":"-95.3696823120117","Name":"Houston, TX","Address":null,"City":"Houston","State":"TX","ZipCode":null,"Country":"United States","Confidence":"High","MatchCode":"Good"}]}},"CacheStatus":{"FromCache":"false","WhenCached":""},"TraceId":"871d8971-d319-4570-8e00-786c82c94a69&#124;10.177.9.60","DebugLog":{"LogMessage":[{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.Get"},{"level":"INFORMATIONAL","text":"Processing Thread: 52"},{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.Get"},{"level":"INFORMATIONAL","text":"Inputs: poiRequest - <?xml version=\"1.0\" encoding=\"utf-16\"?>\n<POIRequest xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" appid=\"dreamshop.honda.com\">\n    <POIId />\n    <SearchWord />\n    <Address />\n    <City>Houston</City>\n    <State>TX</State>\n    <ZipCode />\n    <Country />\n    <Culture />\n    <POIName>Big Star Honda</POIName>\n    <POIIdent />\n    <POIType>A</POIType>\n    <Filters>ATTR_A_DA</Filters>\n    <SearchRadius>20</SearchRadius>\n    <BoundingBox />\n    <Latitude />\n    <Longitude />\n    <NumberOfPOIs>20</NumberOfPOIs>\n    <POIGroupSize />\n    <SortByPOIName>false</SortByPOIName>\n    <SortOrderByAttribute />\n    <StateOnly>false</StateOnly>\n    <ShowDrivingDistance>false</ShowDrivingDistance>\n    <ReferenceCoordinates />\n    <SearchWordOption />\n    <GeocodeOnly>false</GeocodeOnly>\n    <IPAddress />\n    <ConfidenceLevel />\n    <ReferenceLocation />\n    <RankingSource />\n    <ShowAllAttributes>False</ShowAllAttributes>\n    <ShowAllProperties>False</ShowAllProperties>\n    <ShowAllDepartments>True</ShowAllDepartments>\n    <AttributeCdCSV>DA</AttributeCdCSV>\n    <PropertyCdCSV />\n    <DepartmentCdCSV />\n    <FirstName />\n    <LastName />\n    <VIN />\n    <GeocodeIfNotFound>false</GeocodeIfNotFound>\n    <ServiceDomain />\n    <SearchWordType />\n    <LocationName />\n    <AppIdParent />\n    <OutPut>json</OutPut>\n    <Input />\n    <RelationshipPOIOnly>false</RelationshipPOIOnly>\n    <RequestID />\n</POIRequest>"},{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.POIExecute"},{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.SetPOIRequestDefaultValues"},{"level":"INFORMATIONAL","text":"POIRequest Object Inputs: poiRequest - <?xml version=\"1.0\" encoding=\"utf-16\"?>\n<POIRequest xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" appid=\"dreamshop.honda.com\">\n    <POIId />\n    <SearchWord />\n    <Address />\n    <City>Houston</City>\n    <State>TX</State>\n    <ZipCode />\n    <Country />\n    <Culture />\n    <POIName>Big Star Honda</POIName>\n    <POIIdent />\n    <POIType>A</POIType>\n    <Filters>ATTR_A_DA</Filters>\n    <SearchRadius>20</SearchRadius>\n    <BoundingBox />\n    <Latitude />\n    <Longitude />\n    <NumberOfPOIs>20</NumberOfPOIs>\n    <POIGroupSize />\n    <SortByPOIName>false</SortByPOIName>\n    <SortOrderByAttribute />\n    <StateOnly>false</StateOnly>\n    <ShowDrivingDistance>false</ShowDrivingDistance>\n    <ReferenceCoordinates />\n    <SearchWordOption />\n    <GeocodeOnly>false</GeocodeOnly>\n    <IPAddress />\n    <ConfidenceLevel />\n    <ReferenceLocation />\n    <RankingSource />\n    <ShowAllAttributes>False</ShowAllAttributes>\n    <ShowAllProperties>False</ShowAllProperties>\n    <ShowAllDepartments>True</ShowAllDepartments>\n    <AttributeCdCSV>DA</AttributeCdCSV>\n    <PropertyCdCSV />\n    <DepartmentCdCSV />\n    <FirstName />\n    <LastName />\n    <VIN />\n    <GeocodeIfNotFound>false</GeocodeIfNotFound>\n    <ServiceDomain>staging.location.services.honda.com</ServiceDomain>\n    <SearchWordType />\n    <LocationName />\n    <AppIdParent />\n    <OutPut>json</OutPut>\n    <Input>&lt;?xml version=\"1.0\" encoding=\"utf-16\"?&gt;\n&lt;POIRequest xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" appid=\"dreamshop.honda.com\"&gt;\n    &lt;POIId /&gt;\n    &lt;SearchWord /&gt;\n    &lt;Address /&gt;\n    &lt;City&gt;Houston&lt;/City&gt;\n    &lt;State&gt;TX&lt;/State&gt;\n    &lt;ZipCode /&gt;\n    &lt;Country /&gt;\n    &lt;Culture /&gt;\n    &lt;POIName&gt;Big Star Honda&lt;/POIName&gt;\n    &lt;POIIdent /&gt;\n    &lt;POIType&gt;A&lt;/POIType&gt;\n    &lt;Filters&gt;ATTR_A_DA&lt;/Filters&gt;\n    &lt;SearchRadius&gt;20&lt;/SearchRadius&gt;\n    &lt;BoundingBox /&gt;\n    &lt;Latitude /&gt;\n    &lt;Longitude /&gt;\n    &lt;NumberOfPOIs&gt;20&lt;/NumberOfPOIs&gt;\n    &lt;POIGroupSize /&gt;\n    &lt;SortByPOIName&gt;false&lt;/SortByPOIName&gt;\n    &lt;SortOrderByAttribute /&gt;\n    &lt;StateOnly&gt;false&lt;/StateOnly&gt;\n    &lt;ShowDrivingDistance&gt;false&lt;/ShowDrivingDistance&gt;\n    &lt;ReferenceCoordinates /&gt;\n    &lt;SearchWordOption /&gt;\n    &lt;GeocodeOnly&gt;false&lt;/GeocodeOnly&gt;\n    &lt;IPAddress /&gt;\n    &lt;ConfidenceLevel /&gt;\n    &lt;ReferenceLocation /&gt;\n    &lt;RankingSource /&gt;\n    &lt;ShowAllAttributes&gt;False&lt;/ShowAllAttributes&gt;\n    &lt;ShowAllProperties&gt;False&lt;/ShowAllProperties&gt;\n    &lt;ShowAllDepartments&gt;True&lt;/ShowAllDepartments&gt;\n    &lt;AttributeCdCSV&gt;DA&lt;/AttributeCdCSV&gt;\n    &lt;PropertyCdCSV /&gt;\n    &lt;DepartmentCdCSV /&gt;\n    &lt;FirstName /&gt;\n    &lt;LastName /&gt;\n    &lt;VIN /&gt;\n    &lt;GeocodeIfNotFound&gt;false&lt;/GeocodeIfNotFound&gt;\n    &lt;ServiceDomain /&gt;\n    &lt;SearchWordType /&gt;\n    &lt;LocationName /&gt;\n    &lt;AppIdParent /&gt;\n    &lt;OutPut&gt;json&lt;/OutPut&gt;\n    &lt;Input /&gt;\n    &lt;RelationshipPOIOnly&gt;false&lt;/RelationshipPOIOnly&gt;\n    &lt;RequestID /&gt;\n&lt;/POIRequest&gt;</Input>\n    <RelationshipPOIOnly>false</RelationshipPOIOnly>\n    <RequestID />\n</POIRequest>"},{"level":"PERFORMANCE","text":"Method SetPOIRequestDefaultValues took 5.9212 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIPrivateController.SetPOIRequestDefaultValues"},{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.ValidateInputs"},{"level":"PERFORMANCE","text":"Method ValidateInputs took 0.8774 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIPrivateController.ValidateInputs"},{"level":"INFORMATIONAL","text":"BEGIN: POIManager.GetPOIs"},{"level":"INFORMATIONAL","text":"POIRequest Object Inputs: request - <?xml version=\"1.0\" encoding=\"utf-16\"?>\n<POIRequest xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" appid=\"dreamshop.honda.com\">\n    <POIId />\n    <SearchWord />\n    <Address />\n    <City>Houston</City>\n    <State>TX</State>\n    <ZipCode />\n    <Country>US</Country>\n    <Culture>en-US</Culture>\n    <POIName>Big Star Honda</POIName>\n    <POIIdent />\n    <POIType>A</POIType>\n    <Filters>ATTR_A_DA</Filters>\n    <SearchRadius>20</SearchRadius>\n    <BoundingBox />\n    <Latitude />\n    <Longitude />\n    <NumberOfPOIs>20</NumberOfPOIs>\n    <POIGroupSize>5</POIGroupSize>\n    <SortByPOIName>false</SortByPOIName>\n    <SortOrderByAttribute />\n    <StateOnly>false</StateOnly>\n    <ShowDrivingDistance>false</ShowDrivingDistance>\n    <ReferenceCoordinates />\n    <SearchWordOption />\n    <GeocodeOnly>false</GeocodeOnly>\n    <IPAddress />\n    <ConfidenceLevel />\n    <ReferenceLocation />\n    <RankingSource />\n    <ShowAllAttributes>False</ShowAllAttributes>\n    <ShowAllProperties>False</ShowAllProperties>\n    <ShowAllDepartments>True</ShowAllDepartments>\n    <AttributeCdCSV>DA</AttributeCdCSV>\n    <PropertyCdCSV />\n    <DepartmentCdCSV />\n    <FirstName />\n    <LastName />\n    <VIN />\n    <GeocodeIfNotFound>false</GeocodeIfNotFound>\n    <ServiceDomain>staging.location.services.honda.com</ServiceDomain>\n    <SearchWordType />\n    <LocationName />\n    <AppIdParent />\n    <OutPut>json</OutPut>\n    <Input>&lt;?xml version=\"1.0\" encoding=\"utf-16\"?&gt;\n&lt;POIRequest xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" appid=\"dreamshop.honda.com\"&gt;\n    &lt;POIId /&gt;\n    &lt;SearchWord /&gt;\n    &lt;Address /&gt;\n    &lt;City&gt;Houston&lt;/City&gt;\n    &lt;State&gt;TX&lt;/State&gt;\n    &lt;ZipCode /&gt;\n    &lt;Country /&gt;\n    &lt;Culture /&gt;\n    &lt;POIName&gt;Big Star Honda&lt;/POIName&gt;\n    &lt;POIIdent /&gt;\n    &lt;POIType&gt;A&lt;/POIType&gt;\n    &lt;Filters&gt;ATTR_A_DA&lt;/Filters&gt;\n    &lt;SearchRadius&gt;20&lt;/SearchRadius&gt;\n    &lt;BoundingBox /&gt;\n    &lt;Latitude /&gt;\n    &lt;Longitude /&gt;\n    &lt;NumberOfPOIs&gt;20&lt;/NumberOfPOIs&gt;\n    &lt;POIGroupSize /&gt;\n    &lt;SortByPOIName&gt;false&lt;/SortByPOIName&gt;\n    &lt;SortOrderByAttribute /&gt;\n    &lt;StateOnly&gt;false&lt;/StateOnly&gt;\n    &lt;ShowDrivingDistance&gt;false&lt;/ShowDrivingDistance&gt;\n    &lt;ReferenceCoordinates /&gt;\n    &lt;SearchWordOption /&gt;\n    &lt;GeocodeOnly&gt;false&lt;/GeocodeOnly&gt;\n    &lt;IPAddress /&gt;\n    &lt;ConfidenceLevel /&gt;\n    &lt;ReferenceLocation /&gt;\n    &lt;RankingSource /&gt;\n    &lt;ShowAllAttributes&gt;False&lt;/ShowAllAttributes&gt;\n    &lt;ShowAllProperties&gt;False&lt;/ShowAllProperties&gt;\n    &lt;ShowAllDepartments&gt;True&lt;/ShowAllDepartments&gt;\n    &lt;AttributeCdCSV&gt;DA&lt;/AttributeCdCSV&gt;\n    &lt;PropertyCdCSV /&gt;\n    &lt;DepartmentCdCSV /&gt;\n    &lt;FirstName /&gt;\n    &lt;LastName /&gt;\n    &lt;VIN /&gt;\n    &lt;GeocodeIfNotFound&gt;false&lt;/GeocodeIfNotFound&gt;\n    &lt;ServiceDomain /&gt;\n    &lt;SearchWordType /&gt;\n    &lt;LocationName /&gt;\n    &lt;AppIdParent /&gt;\n    &lt;OutPut&gt;json&lt;/OutPut&gt;\n    &lt;Input /&gt;\n    &lt;RelationshipPOIOnly&gt;false&lt;/RelationshipPOIOnly&gt;\n    &lt;RequestID /&gt;\n&lt;/POIRequest&gt;</Input>\n    <RelationshipPOIOnly>false</RelationshipPOIOnly>\n    <RequestID />\n</POIRequest>"},{"level":"INFORMATIONAL","text":"BEGIN: POIManager.GetPOIByCityState"},{"level":"INFORMATIONAL","text":"BEGIN: POIManager.PopulateSorting"},{"level":"INFORMATIONAL","text":"Inputs: poiSearch - POISearchByCityState"},{"level":"INFORMATIONAL","text":"BEGIN: POIManager.ValidateInput"},{"level":"INFORMATIONAL","text":"Inputs: poiSearchType - POISearchByCityState"},{"level":"INFORMATIONAL","text":"BEGIN: POIManager.PopulateFilters"},{"level":"INFORMATIONAL","text":"BEGIN: POIManager.ExtractFilters"},{"level":"INFORMATIONAL","text":"Inputs: attributes - ATTR_A_DA"},{"level":"PERFORMANCE","text":"Method ExtractFilters took 0.0155 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIManager.ExtractFilters"},{"level":"PERFORMANCE","text":"Method PopulateFilters took 0.0332 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIManager.PopulateFilters"},{"level":"PERFORMANCE","text":"Method ValidateInput took 0.0471 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIManager.ValidateInput"},{"level":"PERFORMANCE","text":"Method PopulateSorting took 0.0717 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIManager.PopulateSorting"},{"level":"INFORMATIONAL","text":"BEGIN: DataManager.ProcessPOIByZipCityState"},{"level":"INFORMATIONAL","text":"Inputs: xmlInput - <?xml version=\"1.0\" encoding=\"utf-16\"?>\n<Input xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\n    <Required>\n        <POIType>A</POIType>\n        <POIGroupSize>5</POIGroupSize>\n        <Country>US</Country>\n        <Culture>en-US</Culture>\n        <GeocodeOnly>False</GeocodeOnly>\n        <GeocodeIfNotFound>False</GeocodeIfNotFound>\n        <SearchRadius>20</SearchRadius>\n        <NumberOfPOIs>20</NumberOfPOIs>\n        <City>Houston</City>\n        <State>TX</State>\n    </Required>\n    <Optional>\n        <Tracking>\n            <RequestID />\n        </Tracking>\n        <SearchCriteria>\n            <City>Houston</City>\n            <State>TX</State>\n            <ResultFromSearchStateOnly>False</ResultFromSearchStateOnly>\n            <AttributeFilters>\n                <FilterExpression>ATTR_A_DA</FilterExpression>\n                <Filters>\n                    <Filter id=\"1\">\n                        <AndOrCSV>ATTR_A_DA</AndOrCSV>\n                        <NotCSV />\n                        <Operand>AND</Operand>\n                    </Filter>\n                </Filters>\n                <Operands />\n            </AttributeFilters>\n        </SearchCriteria>\n        <OutputDisplay>\n            <ServiceDomain>staging.location.services.honda.com</ServiceDomain>\n            <ASARankingSource />\n            <ShowAllAttributes>False</ShowAllAttributes>\n            <ShowAllProperties>False</ShowAllProperties>\n            <ShowAllDepartments>True</ShowAllDepartments>\n            <AttributeCdCSV>DA</AttributeCdCSV>\n            <PropertyCdCSV />\n            <DepartmentCdCSV />\n            <Sorting>\n                <Sort type=\"POINameMatch\" direction=\"ASC\" id=\"1\">Big Star Honda</Sort>\n                <Sort type=\"Distance\" direction=\"ASC\" id=\"2\" />\n                <Sort type=\"SearchScore\" direction=\"ASC\" id=\"3\" />\n            </Sorting>\n            <ReferenceCoordinates />\n        </OutputDisplay>\n    </Optional>\n</Input>"},{"level":"INFORMATIONAL","text":"BEGIN: DataManager.ExecuteXDocument"},{"level":"INFORMATIONAL","text":"Stored Procedure : poisp_GetPOIByZipCityState"},{"level":"INFORMATIONAL","text":"@sXML : <?xml version=\"1.0\" encoding=\"utf-16\"?>\n<Input xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\n    <Required>\n        <POIType>A</POIType>\n        <POIGroupSize>5</POIGroupSize>\n        <Country>US</Country>\n        <Culture>en-US</Culture>\n        <GeocodeOnly>False</GeocodeOnly>\n        <GeocodeIfNotFound>False</GeocodeIfNotFound>\n        <SearchRadius>20</SearchRadius>\n        <NumberOfPOIs>20</NumberOfPOIs>\n        <City>Houston</City>\n        <State>TX</State>\n    </Required>\n    <Optional>\n        <Tracking>\n            <RequestID />\n        </Tracking>\n        <SearchCriteria>\n            <City>Houston</City>\n            <State>TX</State>\n            <ResultFromSearchStateOnly>False</ResultFromSearchStateOnly>\n            <AttributeFilters>\n                <FilterExpression>ATTR_A_DA</FilterExpression>\n                <Filters>\n                    <Filter id=\"1\">\n                        <AndOrCSV>ATTR_A_DA</AndOrCSV>\n                        <NotCSV />\n                        <Operand>AND</Operand>\n                    </Filter>\n                </Filters>\n                <Operands />\n            </AttributeFilters>\n        </SearchCriteria>\n        <OutputDisplay>\n            <ServiceDomain>staging.location.services.honda.com</ServiceDomain>\n            <ASARankingSource />\n            <ShowAllAttributes>False</ShowAllAttributes>\n            <ShowAllProperties>False</ShowAllProperties>\n            <ShowAllDepartments>True</ShowAllDepartments>\n            <AttributeCdCSV>DA</AttributeCdCSV>\n            <PropertyCdCSV />\n            <DepartmentCdCSV />\n            <Sorting>\n                <Sort type=\"POINameMatch\" direction=\"ASC\" id=\"1\">Big Star Honda</Sort>\n                <Sort type=\"Distance\" direction=\"ASC\" id=\"2\" />\n                <Sort type=\"SearchScore\" direction=\"ASC\" id=\"3\" />\n            </Sorting>\n            <ReferenceCoordinates />\n        </OutputDisplay>\n    </Optional>\n</Input>"},{"level":"PERFORMANCE","text":"Method ExecuteXDocument took 333.309 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: DataManager.ExecuteXDocument"},{"level":"PERFORMANCE","text":"Method ProcessPOIByZipCityState took 333.3688 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: DataManager.ProcessPOIByZipCityState"},{"level":"PERFORMANCE","text":"Method GetPOIByCityState took 356.3108 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIManager.GetPOIByCityState"},{"level":"INFORMATIONAL","text":"BEGIN: POIManager.ValidateOutput"},{"level":"PERFORMANCE","text":"Method ValidateOutput took 0.0312 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIManager.ValidateOutput"},{"level":"INFORMATIONAL","text":"BEGIN: POIManager.AddResponseWithAdditionalInfo"},{"level":"PERFORMANCE","text":"Method AddResponseWithAdditionalInfo took 0.0041 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIManager.AddResponseWithAdditionalInfo"},{"level":"INFORMATIONAL","text":"BEGIN: POIManager.CalculateDrivingDistance"},{"level":"INFORMATIONAL","text":"BEGIN: POIManager.IsDrivingDistanceExists"},{"level":"PERFORMANCE","text":"Method IsDrivingDistanceExists took 0.0081 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIManager.IsDrivingDistanceExists"},{"level":"PERFORMANCE","text":"Method CalculateDrivingDistance took 0.0443 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIManager.CalculateDrivingDistance"},{"level":"PERFORMANCE","text":"Method GetPOIs took 396.7809 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIManager.GetPOIs"},{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.CreateOutputResponse"},{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.AddResponseWithPOIRequest"},{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.AddResponseWithTraceId"},{"level":"PERFORMANCE","text":"Method AddResponseWithTraceId took 0.0065 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIPrivateController.AddResponseWithTraceId"},{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.AddResponseWithAppId"},{"level":"PERFORMANCE","text":"Method AddResponseWithAppId took 0.2171 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIPrivateController.AddResponseWithAppId"},{"level":"PERFORMANCE","text":"Method AddResponseWithPOIRequest took 0.5677 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIPrivateController.AddResponseWithPOIRequest"},{"level":"PERFORMANCE","text":"Method CreateOutputResponse took 0.9159 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIPrivateController.CreateOutputResponse"},{"level":"PERFORMANCE","text":"Method POIExecute took 404.5797 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIPrivateController.POIExecute"},{"level":"PERFORMANCE","text":"Request Get took 404.7964 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIPrivateController.Get"}]}}}';
        DynamicResponceMock objDynamicResponceMock = new DynamicResponceMock(200,body);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
        Test.setMock(HTTPCalloutMock.class, objDynamicResponceMock);        
        B2B_EconfigIntegration.dealerLocatorService('sdfsdfsfshf','456001','A','J','K', '200');
        Test.stopTest();
    }
    @isTest
    public static void testgetAccountResponse() {
        Test.startTest(); 
        List<B2B_EconfigIntegration.DistanceWrapper> dis = new List<B2B_EconfigIntegration.DistanceWrapper>();
        B2B_EconfigIntegration.DistanceWrapper config = new  B2B_EconfigIntegration.DistanceWrapper();
        config.POIId = '208776';
        config.distance ='8';
        config.InternetAddress = 'https://www.pierceyhonda.com/';
        dis.add(config);
        Account objAccount = B2B_TestDataFactory.createAccount(false);    
        objAccount.PoIId__c = '208776';
        insert objAccount;
        B2B_EconfigIntegration.getAccountResponse(dis);
        Test.stopTest();
    }
    @isTest
    public static void testSetupExternalManagedAccountNegative() {
        Test.startTest();      
        Account objAccount = B2B_TestDataFactory.createAccount(true);
        Test.stopTest(); 
    }
    
    @isTest
    public static void testimportCSVFile(){
        String[] csvFileLines;
        Blob csvFileBody;
        String str = 'Model_Id__c,Year__c,Model__c,Trim__c,iNDivisionID__c,iNDivisionName__c,iNYearID__c,iNYear__c,iNModelID__c,iNModel__c,iNDoorID__c,iNDoor__c,iNGradeID__c,iNGrade__c,iNCatalogID__c,iNTransmissionID__c,iNTransmission__c,eConfigSourceCode__c,eConfigModelID__c,eConfigDivisionID__c\n RL6H9NKXW,2022,Odyssey,ELITE 10 Speed Automatic,1,Honda,53,2022,11,Odyssey,3,5,4760,ELITE(HPPG 10AT),152,12,XAT,Honda,RL6H9NKXW,A';       
        Test.startTest();       
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        B2B_EconfigIntegration importData = new B2B_EconfigIntegration();
        importData.csvFileBody = csvFileBody;
        Test.stopTest();
    } 
    
    @isTest
    public static void testgetVehicleYear() {
        Test.startTest();
        Vehicle__c objVehicle = [SELECT Year__c, Model__c, Trim__c, Model_Id__c, External_Id__c, iNDivisionID__c, iNDivisionName__c, iNYearID__c, 
                                 iNYear__c, iNModelID__c, iNModel__c, iNDoorID__c, iNDoor__c, iNGradeID__c, iNGrade__c, iNCatalogID__c, iNTransmissionID__c,
                                 iNTransmission__c, eConfigSourceCode__c, eConfigModelID__c, eConfigDivisionID__c, Name, Id 
                                 FROM Vehicle__c 
                                 LIMIT 1];      
        B2B_EconfigIntegration.getVehicleYear(String.valueOf(objVehicle.iNDivisionID__c));        
        Test.stopTest();
    }
    
    @isTest
    public static void testgetVehicleModel() {
        Test.startTest();
        Vehicle__c objVehicle = [SELECT Year__c, Model__c, Trim__c, Model_Id__c, External_Id__c, iNDivisionID__c, iNDivisionName__c, iNYearID__c, 
                                 iNYear__c, iNModelID__c, iNModel__c, iNDoorID__c, iNDoor__c, iNGradeID__c, iNGrade__c, iNCatalogID__c, iNTransmissionID__c,
                                 iNTransmission__c, eConfigSourceCode__c, eConfigModelID__c, eConfigDivisionID__c, Name, Id 
                                 FROM Vehicle__c 
                                 LIMIT 1];  
        B2B_EconfigIntegration.getVehicleModel(String.valueof(objVehicle.iNDivisionID__c),Integer.valueOf(objVehicle.iNYearID__c));   
        Test.stopTest();
    }
    
    
    
    @isTest
    public static void testgetVehicleTrim() {
        Test.startTest();
        Vehicle__c objVehicle = [SELECT Year__c, Model__c, Trim__c, Model_Id__c, External_Id__c, iNDivisionID__c, iNDivisionName__c, iNYearID__c, 
                                 iNYear__c, iNModelID__c, iNModel__c, iNDoorID__c, iNDoor__c, iNGradeID__c, iNGrade__c, iNCatalogID__c, iNTransmissionID__c,
                                 iNTransmission__c, eConfigSourceCode__c, eConfigModelID__c, eConfigDivisionID__c, Name, Id 
                                 FROM Vehicle__c 
                                 LIMIT 1]; 
        String trims = B2B_EconfigIntegration.getVehicleTrim(String.valueof(objVehicle.iNDivisionID__c), Integer.valueof(objVehicle.Year__c), objVehicle.Model_Id__c);    	
        Test.stopTest();
    }    
    
    @isTest
    public static void testgetVehicleDetails() {
        Test.startTest();
        Vehicle__c objVehicle = [SELECT Year__c, Model__c, Trim__c, Model_Id__c, External_Id__c, iNDivisionID__c, iNDivisionName__c, iNYearID__c, 
                                 iNYear__c, iNModelID__c, iNModel__c, iNDoorID__c, iNDoor__c, iNGradeID__c, iNGrade__c, iNCatalogID__c, iNTransmissionID__c,
                                 iNTransmission__c, eConfigSourceCode__c, eConfigModelID__c, eConfigDivisionID__c, Name, Id 
                                 FROM Vehicle__c 
                                 LIMIT 1]; 
        B2B_EconfigIntegration.getVehicleDetails(String.valueof(objVehicle.Year__c), String.valueof(objVehicle.Model__c), String.valueof(objVehicle.Trim__c), '');      
        Test.stopTest();
    }

    @isTest
    public static void testgetVehicleOptionsForHomepage() {
        Test.startTest();
        Vehicle__c objVehicle = [SELECT Year__c, Model__c, Trim__c, Model_Id__c, External_Id__c, iNDivisionID__c, iNDivisionName__c, iNYearID__c, 
                                 iNYear__c, iNModelID__c, iNModel__c, iNDoorID__c, iNDoor__c, iNGradeID__c, iNGrade__c, iNCatalogID__c, iNTransmissionID__c,
                                 iNTransmission__c, eConfigSourceCode__c, eConfigModelID__c, eConfigDivisionID__c, Name, Id 
                                 FROM Vehicle__c 
                                 LIMIT 1]; 
        B2B_EconfigIntegration.getVehicleOptionsForHomepage(Integer.valueOf(objVehicle.Year__c), String.valueof(objVehicle.Model__c), String.valueof(objVehicle.Trim__c), '1');      
        Test.stopTest();
    }    
    
    @isTest
    public static void testgetVehicleDetailsPartsIf() { 
        Test.startTest();
        Vehicle__c objVehicle = [SELECT Year__c, Model__c , Trim__c, Model_Id__c, External_Id__c, iNDivisionID__c, iNDivisionName__c, iNYearID__c, 
                                 iNYear__c, iNModelID__c, iNModel__c, iNDoorID__c, iNDoor__c, iNGradeID__c, iNGrade__c, iNCatalogID__c, iNTransmissionID__c,
                                 iNTransmission__c, eConfigSourceCode__c, eConfigModelID__c, eConfigDivisionID__c, Name, Id 
                                 FROM Vehicle__c 
                                 LIMIT 1]; 
        B2B_EconfigIntegration.getVehicleDetailsForParts(String.valueof(objVehicle.iNModelID__c), String.valueof(objVehicle.iNGradeID__c ), String.valueof(objVehicle.iNYearID__c),String.valueof(objVehicle.iNTransmissionID__c),String.valueof(objVehicle.iNDoorID__c),String.valueof(objVehicle.iNCatalogID__c));
        Test.stopTest();
    }
      @isTest
    public static void testgetVehicleDetailsPartsElse() { 
        Test.startTest();
        Vehicle__c objVehicle = [SELECT Year__c, Model__c , Trim__c, Model_Id__c, External_Id__c, iNDivisionID__c, iNDivisionName__c, iNYearID__c, 
                                 iNYear__c, iNModelID__c, iNModel__c, iNDoorID__c, iNDoor__c, iNGradeID__c, iNGrade__c, iNCatalogID__c, iNTransmissionID__c,
                                 iNTransmission__c, eConfigSourceCode__c, eConfigModelID__c, eConfigDivisionID__c, Name, Id 
                                 FROM Vehicle__c 
                                 LIMIT 1]; 
        B2B_EconfigIntegration.getVehicleDetailsForParts(String.valueof(objVehicle.iNModelID__c), String.valueof(objVehicle.iNGradeID__c ), String.valueof(objVehicle.iNYearID__c),'',String.valueof(objVehicle.iNDoorID__c),String.valueof(objVehicle.iNCatalogID__c));
        Test.stopTest();
    }
    @isTest
    public static void testgetVehicleDoors() {
        Test.startTest();
        Vehicle__c objVehicle = [SELECT Year__c, Model__c, Trim__c, Make__c, Model_Id__c, External_Id__c, iNDivisionID__c, iNDivisionName__c, iNYearID__c, 
                                 iNYear__c, iNModelID__c, iNModel__c, iNDoorID__c, iNDoor__c, iNGradeID__c, iNGrade__c, iNCatalogID__c, iNTransmissionID__c,
                                 iNTransmission__c, eConfigSourceCode__c, eConfigModelID__c, eConfigDivisionID__c, Name, Id 
                                 FROM Vehicle__c 
                                 LIMIT 1]; 
        B2B_EconfigIntegration.getVehicleDoors(String.valueOf(objVehicle.Make__c),String.valueOf(objVehicle.Year__c),String.valueOf(objVehicle.Model__c));
        Test.stopTest();
    }
    public static void testgetCategory() {
        Test.startTest();
        Product2 product = B2B_TestDataFactory.createProduct(true);
        B2B_EconfigIntegration.getCategory(String.valueof(product.Id));
        Test.stopTest();
    }
    
    @isTest
    public static void testgetCartItemCategory() {
        Test.startTest();
        Account testAccount = B2B_TestDataFactory.createAccount(true);
        WebStore testStore = B2B_TestDataFactory.createStore(true);
        WebCart testcart = B2B_TestDataFactory.createCart(true, testAccount.Id, testStore.Id);
        CartDeliveryGroup testdelivery = B2B_TestDataFactory.createCartDeliveryGroup(true, testcart.Id);
        Product2 objProduct = B2B_TestDataFactory.createProduct(true);
        ProductCategoryProduct objCategoryProduct = B2B_TestDataFactory.createProductCategory(true,objProduct.Id);
        CartItem cartItem = B2B_TestDataFactory.createCartItem(true,testcart.Id, testdelivery.Id, objProduct.Id);
        B2B_EconfigIntegration.getCartItemCategory(testcart.Id);
        Test.stopTest();
    }
    @isTest
    public static void testgetVehicleDetailsWithModalAndTrims(){
        Test.startTest();
        Vehicle__c objVehicle = [SELECT Year__c, Model__c, Trim__c, Model_Id__c, External_Id__c, iNDivisionID__c, iNDivisionName__c, iNYearID__c, 
                                 iNYear__c, iNModelID__c, iNModel__c, iNDoorID__c, iNDoor__c, iNGradeID__c, iNGrade__c, iNCatalogID__c, iNTransmissionID__c,
                                 iNTransmission__c, eConfigSourceCode__c, eConfigModelID__c, eConfigDivisionID__c, Name, Id 
                                 FROM Vehicle__c 
                                 LIMIT 1];  
        B2B_EconfigIntegration.getVehicleDetailsWithModalAndTrims(String.valueof(objVehicle.Year__c),String.valueOf(objVehicle.Model__c),String.valueOf(objVehicle.Trim__c ));   
        Test.stopTest();
		}
    
    @isTest
    public static void testCompareTo() {
        Test.startTest();
        B2B_EconfigIntegration.LocationResponseWrapper loc = new B2B_EconfigIntegration.LocationResponseWrapper();
        Account account = B2B_TestDataFactory.createAccount(true);
        loc.accountList = account;
        loc.Distance = 8;
        loc.InternetAddress = 'https://www.pierceyhonda.com/';
        loc.compareTo((Object)loc);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetVehicleDetailsForAccessories() {
        Test.startTest();
        Vehicle__c objVehicle = [SELECT Model_Id__c, Name, Id 
                                 FROM Vehicle__c 
                                 LIMIT 1];
        B2B_EconfigIntegration.getVehicleDetailsForAccessories(objVehicle.Model_Id__c);
        Test.stopTest();
    }
    @isTest
    public static void testSearchedDealerResponseStored() {
        Test.startTest();
        Account testAccount = B2B_TestDataFactory.createAccount(true);
        B2B_EconfigIntegration.searchedDealerResponseStored(testAccount.Email__c,testAccount.Name,testAccount.Operation_Hour__c,'Jose','Navarrete',1.0212,-1.123,'test'); 
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
    @isTest
    public static void testCallinms(){
         Test.startTest(); 
        B2B_Util.fetchCurrentTime();
        B2B_Util.calInMilliSeconds(29785,598989);
        Test.stopTest();
    }
     @isTest
    public static void  testcallVinDecoderServiceError() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock1());   
        B2B_EconfigIntegration.callVinDecoderService('','');
        Test.stopTest();
    }
    
     @isTest
    public static void  testdealerLocatorServiceError() {
        Test.startTest();
        // Setting up the mock response
        Test.setMock(HTTPCalloutMock.class, new B2B_EConfigIntegrationMock1());   
        B2B_EconfigIntegration.dealerLocatorService('','','','','',''); 
        Test.stopTest();
    }

}
/**********************************************************************
Name: B2B_BrainTreeUtilsTestMock
Business Unit:HDM
Date : 28/05/2022
Developer : Mathioli K 
Description: Mock class for BrainTreeUtilsIntegration
MODIFICATIONS – 09/06/2022 | Mathioli | (Added header and removal of commented code)
*************************************************************/
@isTest
global class B2B_BrainTreeUtilsTestMock implements HTTPCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        
        String reqBody = request.getBody();
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        //Negative for AccessToken
        if(request.getEndpoint().contains('dadagdadh')) {
            String body ='{"status": 502,"errorMessage": "Gatway error"}';
            response.setBody(body);
            response.setStatusCode(502);
            response.setStatus('Gatway error');
        }
        
        //Positive for AccessToken
        else if (request.getEndpoint().contains('x6q6b83wjsn28t2m')) {
            String body ='{"status": 200,"merchantId": "x6q6b83wjsn28t2m","credentials": {"accessToken": "access_token$sandbox$x6q6b83wjsn28t2m$d648f8a9d4523e920c631bfa31065647","refreshToken": "refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130160a82ddf4ef9eec","tokenType": "bearer","expiresAt": "2021-07-06T09:13:40Z","scope": "read_write,shared_vault_transactions"}}';
            response.setBody(body); 
            response.setStatusCode(200); 
        }
        
        else if(request.getEndpoint().contains('testCatch')){          
            response.setBody(null); 
            response.setStatusCode(200);
        }
        
        //Negative for RefreshToken
        if(request.getEndpoint().contains('agdadh')) {
            String body ='{"status": 502,"errorMessage": "Gatway error"}';
            response.setBody(body);
            response.setStatusCode(502); 
            response.setStatus('Gatway error');
        }
        
        // for positive 
        else if (request.getBody().contains('34507')) {
            String body ='{"Mot":{"Input_Parameters":{"Required":{"Dealer_No":"206559","Dealer_Setup_Completion_Timestamp":"2022-06-08T08:03:39.651Z"}}},"Output":{"Result":"success"}}'; 
            response.setBody(body);
            response.setStatusCode(200); 
            response.setHeader('Content-Type', 'application/json');
        }
        // for negative
        else if (request.getBody().contains('123456')) {
            String body ='{"response":{"errorCode":"SA1003","errorMesage":"error"}}'; 
            response.setBody(body);
            response.setStatusCode(400); 
            response.setHeader('Content-Type', 'application/json');
        }
        if(reqBody.contains('testCatch')){
            response.setBody(null); 
            response.setStatusCode(200);
        }
        //Negative for PreAuth
        else if(reqBody.contains('bbncbncnb')) {
            String body ='{"status":400,"errorMessage":"authenticationError"}';
            response.setBody(body); 
            response.setStatusCode(400); 
        }
        
        //Positive for PreAuth
        else if (request.getEndpoint().endsWith('transaction/pre-auth')) {
            String body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"authorized","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            response.setBody(body);
            response.setStatusCode(200);  
        }
        
        //Negative for PostAuth
        else if(reqBody.contains('ffsfsf'))
        {
            String body ='{"status":400,"errorMessage":"authenticationError"}';
            response.setBody(body); 
            response.setStatusCode(400); 
        }
        
        //Positive for PostAuth
        else if (request.getEndpoint().endsWith('transaction/post-auth')) {
            String body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"submitted_for_settlement","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            response.setBody(body);
            response.setStatusCode(200);  
        }
        
        //Negative for Refund
        else if(reqBody.contains('sfsjgf'))
        {
            String body = '{"status":400,"errorMessage":"authenticationError"}';
            response.setBody(body);
            response.setStatusCode(400); 
        }
        
        //Positive for Refund
        else if (request.getEndpoint().endsWith('transaction/refund')) {
            String body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"authorized","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            response.setBody(body);
            response.setStatusCode(200);  
        }
        
        //Negative for Void
        else if (reqBody.contains('sdfsfjsf')) {
            String body = '{"status":400,"errorMessage":"authenticationError"}';
            response.setBody(body);
            response.setStatusCode(400); 
        }
        
        //Positive for Void
        else if (request.getEndpoint().endsWith('transaction/void')) {
            String body ='{"status":200,"merchantId":"vvh2kqnt6m4434vr","transaction":{"id":"ky5hkfng","status":"Voided","type":"sale","amount":"20.00"},"facilitatedDetails":{"merchantId":"vvh2kqnt6m4434vr","merchantName":"Wipro pvt. lmt."},"facilitatorDetails":{"oauthApplicationClientId":"client_id$sandbox$5chrg778bfg627fg","oauthApplicationName":"Braintree Payment Service","sourcePaymentMethodToken":"009"}}';
            response.setBody(body);
            response.setStatusCode(200); 
            response.setHeader('Content-Type', 'application/json');
        } 
        else  if(request.getEndpoint().contains('251084')) {
            String body = '{"status":202,"POIResponse":{"appid":"bodyshops.honda.com","Error":"false","ResultCount":"7","Version":"1","POIs":{"POI":[{"POIIdent":"33094","PageNumber":"2","PositionInPage":"2","POIId":"208779","POIType":"A","POIName":"Victory Honda of Morgan Hill","Email":null,"InternetAddress":"https://victoryhondamorganhill.com/","CorporationName":"Cappo Management Xlix, LLC","Address":"17100 Laurel Rd ","City":"Morgan Hill","State":"CA","ZipCode":"95037-4434","MailingAddress":"17100 Laurel Rd","MailingCity":"Morgan Hill","MailingState":"CA","MailingZip":"95037-4434","Country":"US","Ranking":null,"Phone":"(408) 500-3000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"POISortOrder":"7","Distance":"19.8 miles","FullAddress":"17100 Laurel Rd;Morgan Hill, CA 95037-4434","Latitude":"37.132771","Longitude":"-121.63568","Attributes":null,"Properties":null,"Departments":{"Department":[{"Cd":"AD","Name":"Business Management","text":"Business Management","Contact":[{"SequenceNo":"1","FirstName":"Joseph","LastName":"Liotta","Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"jliotta@acurabayshore.com"}]},{"Cd":"SC","Name":"Dealer System Coordinator","text":"Dealer System Coordinator","Contact":[{"SequenceNo":"1","FirstName":"Christine","LastName":"Staab","Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-4207","FaxCountryCode":"1","FaxExtension":null,"Email":"cstaab@acuraofbayshore.com"}]},{"Cd":"D2","Name":"Dealership Mgr.","text":"Dealership Mgr.","Contact":[{"SequenceNo":"1","FirstName":"Christine","LastName":"Staab","Phone":null,"PhoneCountryCode":null,"PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":null}]},{"Cd":"D1","Name":"Dlr. Principal","text":"Dlr. Principal","Contact":[{"SequenceNo":"1","FirstName":"Alain","LastName":"Dibre","Phone":null,"PhoneCountryCode":null,"PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":null}]},{"Cd":"FS","Name":"Financial Statement Accounting Manager","text":"Financial Statement Accounting Manager","Contact":[{"SequenceNo":"1","FirstName":null,"LastName":null,"Phone":null,"PhoneCountryCode":null,"PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":"carly@acura4me.com"}]},{"Cd":"SA","Name":"Internet Sales Management","text":"Internet Sales Management","Contact":[{"SequenceNo":"1","FirstName":null,"LastName":null,"Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":null}],"OperationHour":[{"type":"consolidated","text":"Mon-Thu  9:00AM-9:00PM;Fri      9:00AM-7:00PM;Sat      9:00AM-6:00PM;Sun      11:00AM-4:00PM"}]},{"Cd":"XT","Name":"NSX Certified Technician","text":"NSX Certified Technician","Contact":[{"SequenceNo":"1","FirstName":"John","LastName":"Clark","Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"rmilano@acuraofbayshore.com"}]},{"Cd":"XS","Name":"NSX Sales Specialist","text":"NSX Sales Specialist","Contact":[{"SequenceNo":"1","FirstName":"Diego","LastName":"Bonilla","Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-4207","FaxCountryCode":"1","FaxExtension":null,"Email":"dbonilla@acuraofbayshore.com"}]},{"Cd":"XW","Name":"NSX Service Specialist","text":"NSX Service Specialist","Contact":[{"SequenceNo":"1","FirstName":"Jason","LastName":"Rupansingh","Phone":"(631) 968-4141","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"jrupansingh@acuraofbayshore.com"}]},{"Cd":"PA","Name":"Parts Management","text":"Parts Management","Contact":[{"SequenceNo":"1","FirstName":"Robert","LastName":"Milano","Phone":"(631) 968-4142","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"rmilano@acuraofbayshore.com"}],"OperationHour":[{"type":"consolidated","text":"Mon-Tue  7:30AM-5:00PM;Wed      7:30AM-7:00PM;Thu-Fri  7:30AM-5:00PM;Sat      7:30AM-4:00PM;Sun      Closed"}]},{"Cd":"SM","Name":"Sales Management","text":"Sales Management","Contact":[{"SequenceNo":"1","FirstName":"Carlton","LastName":"Johnson","Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"cjohnson@acuraofbayshore.com"}]},{"Cd":"CS","Name":"Service Appointments","text":"Service Appointments","Contact":[{"SequenceNo":"1","FirstName":"Robert","LastName":"Milano","Phone":"(631) 968-4141","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"rmilano@acuraofbayshore.com"}]},{"Cd":"SV","Name":"Service Management","text":"Service Management","Contact":[{"SequenceNo":"1","FirstName":"Robert","LastName":"Milano","Phone":"(631) 968-4141","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"rmilano@acuraofbayshore.com"}],"OperationHour":[{"type":"consolidated","text":"Mon-Fri  7:30AM-7:00PM;Sat      7:00AM-4:00PM;Sun      Closed"}]}]}}]},"POIRequest":{"appid":"bodyshops.honda.com","AppId":"bodyshops.honda.com","POIId":null,"SearchWord":null,"Address":null,"City":"San Jose","State":"CA","Country":null,"Culture":null,"POIName":null,"POIIdent":null,"POIType":"A","Filters":null,"SearchRadius":"20","BoundingBox":null,"Latitude":null,"Longitude":null,"NumberOfPOIs":"20","POIGroupSize":null,"SortByPOIName":"false","SortOrderByAttribute":null,"StateOnly":"false","ShowDrivingDistance":"false","ReferenceCoordinates":null,"SearchWordOption":null,"GeocodeOnly":"false","IPAddress":null,"ConfidenceLevel":null,"ReferenceLocation":null,"RankingSource":null,"ShowAllAttributes":"False","ShowAllProperties":"False","ShowAllDepartments":"False","AttributeCdCSV":null,"PropertyCdCSV":null,"DepartmentCdCSV":null,"FirstName":null,"LastName":null,"VIN":null,"GeocodeIfNotFound":"false","ServiceDomain":null,"SearchWordType":null,"LocationName":null,"AppIdParent":null,"OutPut":"json","Input":null,"RelationshipPOIOnly":"false","RequestID":null},"GeoCodeResults":{"Latitude":"37.3386497497559","Longitude":"-121.88542175293","Locations":{"Location":[{"Type":"PopulatedPlace","Latitude":"37.3386497497559","Longitude":"-121.88542175293","Name":"San Jose, CA","Address":null,"City":"San Jose","State":"CA","ZipCode":null,"Country":"United States","Confidence":"High","MatchCode":"Good"}]}},"CacheStatus":{"FromCache":"false","WhenCached":""},"TraceId":"d5f98e0a-64a2-4b10-87f4-5a22b2372bf6|10.177.9.60","DebugLog":{"LogMessage":[{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.ValidateInputs"},{"level":"PERFORMANCE","text":"Method ValidateInputs took 0.6525 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIPrivateController.ValidateInputs"}]}}}';
            response.setBody(body);
            response.setStatusCode(202); 
            
        } 
        
        else if(request.getEndpoint().contains('251084')) {
            String body = '{"status":202,"POIResponse":{"appid":"bodyshops.honda.com","Error":"false","ResultCount":"7","Version":"1","POIs":{"POI":[{"POIIdent":"33094","PageNumber":"2","PositionInPage":"2","POIId":"208779","POIType":"A","POIName":"Victory Honda of Morgan Hill","Email":null,"InternetAddress":"https://victoryhondamorganhill.com/","CorporationName":"Cappo Management Xlix, LLC","Address":"17100 Laurel Rd ","City":"Morgan Hill","State":"CA","ZipCode":"95037-4434","MailingAddress":"17100 Laurel Rd","MailingCity":"Morgan Hill","MailingState":"CA","MailingZip":"95037-4434","Country":"US","Ranking":null,"Phone":"(408) 500-3000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"POISortOrder":"7","Distance":"19.8 miles","FullAddress":"17100 Laurel Rd;Morgan Hill, CA 95037-4434","Latitude":"37.132771","Longitude":"-121.63568","Attributes":null,"Properties":null,"Departments":{"Department":[{"Cd":"AD","Name":"Business Management","text":"Business Management","Contact":[{"SequenceNo":"1","FirstName":"Joseph","LastName":"Liotta","Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"jliotta@acurabayshore.com"}]},{"Cd":"SC","Name":"Dealer System Coordinator","text":"Dealer System Coordinator","Contact":[{"SequenceNo":"1","FirstName":"Christine","LastName":"Staab","Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-4207","FaxCountryCode":"1","FaxExtension":null,"Email":"cstaab@acuraofbayshore.com"}]},{"Cd":"D2","Name":"Dealership Mgr.","text":"Dealership Mgr.","Contact":[{"SequenceNo":"1","FirstName":"Christine","LastName":"Staab","Phone":null,"PhoneCountryCode":null,"PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":null}]},{"Cd":"D1","Name":"Dlr. Principal","text":"Dlr. Principal","Contact":[{"SequenceNo":"1","FirstName":"Alain","LastName":"Dibre","Phone":null,"PhoneCountryCode":null,"PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":null}]},{"Cd":"FS","Name":"Financial Statement Accounting Manager","text":"Financial Statement Accounting Manager","Contact":[{"SequenceNo":"1","FirstName":null,"LastName":null,"Phone":null,"PhoneCountryCode":null,"PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":"carly@acura4me.com"}]},{"Cd":"SA","Name":"Internet Sales Management","text":"Internet Sales Management","Contact":[{"SequenceNo":"1","FirstName":null,"LastName":null,"Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":null,"FaxCountryCode":null,"FaxExtension":null,"Email":null}],"OperationHour":[{"type":"consolidated","text":"Mon-Thu  9:00AM-9:00PM;Fri      9:00AM-7:00PM;Sat      9:00AM-6:00PM;Sun      11:00AM-4:00PM"}]},{"Cd":"XT","Name":"NSX Certified Technician","text":"NSX Certified Technician","Contact":[{"SequenceNo":"1","FirstName":"John","LastName":"Clark","Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"rmilano@acuraofbayshore.com"}]},{"Cd":"XS","Name":"NSX Sales Specialist","text":"NSX Sales Specialist","Contact":[{"SequenceNo":"1","FirstName":"Diego","LastName":"Bonilla","Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-4207","FaxCountryCode":"1","FaxExtension":null,"Email":"dbonilla@acuraofbayshore.com"}]},{"Cd":"XW","Name":"NSX Service Specialist","text":"NSX Service Specialist","Contact":[{"SequenceNo":"1","FirstName":"Jason","LastName":"Rupansingh","Phone":"(631) 968-4141","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"jrupansingh@acuraofbayshore.com"}]},{"Cd":"PA","Name":"Parts Management","text":"Parts Management","Contact":[{"SequenceNo":"1","FirstName":"Robert","LastName":"Milano","Phone":"(631) 968-4142","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"rmilano@acuraofbayshore.com"}],"OperationHour":[{"type":"consolidated","text":"Mon-Tue  7:30AM-5:00PM;Wed      7:30AM-7:00PM;Thu-Fri  7:30AM-5:00PM;Sat      7:30AM-4:00PM;Sun      Closed"}]},{"Cd":"SM","Name":"Sales Management","text":"Sales Management","Contact":[{"SequenceNo":"1","FirstName":"Carlton","LastName":"Johnson","Phone":"(631) 968-4000","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"cjohnson@acuraofbayshore.com"}]},{"Cd":"CS","Name":"Service Appointments","text":"Service Appointments","Contact":[{"SequenceNo":"1","FirstName":"Robert","LastName":"Milano","Phone":"(631) 968-4141","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"rmilano@acuraofbayshore.com"}]},{"Cd":"SV","Name":"Service Management","text":"Service Management","Contact":[{"SequenceNo":"1","FirstName":"Robert","LastName":"Milano","Phone":"(631) 968-4141","PhoneCountryCode":"1","PhoneExtension":null,"Fax":"(631) 968-6522","FaxCountryCode":"1","FaxExtension":null,"Email":"rmilano@acuraofbayshore.com"}],"OperationHour":[{"type":"consolidated","text":"Mon-Fri  7:30AM-7:00PM;Sat      7:00AM-4:00PM;Sun      Closed"}]}]}}]},"POIRequest":{"appid":"bodyshops.honda.com","AppId":"bodyshops.honda.com","POIId":null,"SearchWord":null,"Address":null,"City":"San Jose","State":"CA","Country":null,"Culture":null,"POIName":null,"POIIdent":null,"POIType":"A","Filters":null,"SearchRadius":"20","BoundingBox":null,"Latitude":null,"Longitude":null,"NumberOfPOIs":"20","POIGroupSize":null,"SortByPOIName":"false","SortOrderByAttribute":null,"StateOnly":"false","ShowDrivingDistance":"false","ReferenceCoordinates":null,"SearchWordOption":null,"GeocodeOnly":"false","IPAddress":null,"ConfidenceLevel":null,"ReferenceLocation":null,"RankingSource":null,"ShowAllAttributes":"False","ShowAllProperties":"False","ShowAllDepartments":"False","AttributeCdCSV":null,"PropertyCdCSV":null,"DepartmentCdCSV":null,"FirstName":null,"LastName":null,"VIN":null,"GeocodeIfNotFound":"false","ServiceDomain":null,"SearchWordType":null,"LocationName":null,"AppIdParent":null,"OutPut":"json","Input":null,"RelationshipPOIOnly":"false","RequestID":null},"GeoCodeResults":{"Latitude":"37.3386497497559","Longitude":"-121.88542175293","Locations":{"Location":[{"Type":"PopulatedPlace","Latitude":"37.3386497497559","Longitude":"-121.88542175293","Name":"San Jose, CA","Address":null,"City":"San Jose","State":"CA","ZipCode":null,"Country":"United States","Confidence":"High","MatchCode":"Good"}]}},"CacheStatus":{"FromCache":"false","WhenCached":""},"TraceId":"d5f98e0a-64a2-4b10-87f4-5a22b2372bf6|10.177.9.60","DebugLog":{"LogMessage":[{"level":"INFORMATIONAL","text":"BEGIN: POIPrivateController.ValidateInputs"},{"level":"PERFORMANCE","text":"Method ValidateInputs took 0.6525 milliseconds (ms)"},{"level":"INFORMATIONAL","text":"END: POIPrivateController.ValidateInputs"}]}}}';
            response.setBody(body);
            response.setStatusCode(202); 
            
        }
        
        else if (request.getEndpoint().endsWith('transaction/payment-update')) {
            String body ='{"status":200}';
            response.setBody(body);
            response.setStatusCode(200); 
            response.setHeader('Content-Type', 'application/json');
        } 
        else if(reqBody.contains('braintreePaymentMethodFind')){
            String body='{"status":200,"billingAddressId":"ry"}';
            response.setBody(body);
            response.setStatusCode(200); 
            response.setHeader('Content-Type', 'application/json');
        }
        else if(reqBody.contains('braintreeAddressDelete'))
        {
            String body='{"status":200}';
            response.setBody(body);
            response.setStatusCode(200); 
            response.setHeader('Content-Type', 'application/json');
        }
        
        else if(reqBody.contains('braintreePaymentMethodDelete'))
        {
            String body='{"status":200}';
            response.setBody(body);
            response.setStatusCode(200); 
            response.setHeader('Content-Type', 'application/json');
        }
        
        return response;
    }
}
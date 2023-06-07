/**********************************************************************
Name: B2B_EconfigIntegration
Business Unit:HDM
Developer : Radhey Shyam Gupta
Description: This class handles all the Integrations related to Econfig.Test class:B2B_EconfigIntegrationTest,B2B_EConfigIntegrationMock(Mock class),B2B_TestDataFactory
MODIFICATIONS – 20/04/2021 | Shwetank
MODIFICATIONS -	26/5/2021 | Shalini
MODIFICATIONS- 10/06/2021 | RajRishi Kaushik :
MODIFICATIONS- 23/05/2022 |Soumya Sahoo:(Error handling changes- JIRA- 8617)
MODIFICATIONS – 09/06/2022 | Mathioli | (Added header and removal of commented code)
*************************************************************/
public without sharing class B2B_EconfigIntegration{
    public Static String sortBy{get; set;}
    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    // This Method will provide list of accessories based on model id provided in request.
    @AuraEnabled
    public static String getCompleteDetail(String modelId, String poiType){
        GetCompleteDetailsResponse objCompleteDetailByModelId = New GetCompleteDetailsResponse();
        String returnResponse = '';
        try{
            String divisionName = '';
            if(poiType == 'A'){
                divisionName = 'HONDA';
            }else if(poiType == 'B'){
                divisionName = 'ACURA';
            }
            B2B_Econfig_Request__mdt objMetaData = [Select B2B_Application_Id__c,B2B_Domain__c,B2B_Environment__c,B2B_Server_IP__c,B2B_Session_Id__c 
                                                    FROM  B2B_Econfig_Request__mdt 
                                                    WHERE DeveloperName = 'GetCompleteDetails'];
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String reqBody = '{"mit": {"@mit_version_date": "2019-03-10","@mit_version_number": "1",';
            reqBody += '"client_info":{"@application_id":"'+ objMetaData.B2B_Application_Id__c + '","@echo_input":"'+'false'+'","@server_ip":"'+ objMetaData.B2B_Server_IP__c +'","@session_id": "'+objMetaData.B2B_Session_Id__c +'","@domain":"'+ objMetaData.B2B_Domain__c ;
            reqBody += '","@environment":"'+ objMetaData.B2B_Environment__c +'"},"input_parameters": {"required": {"source_cd":"'+'HDM'+'","site_cd":"'+divisionName+'","category_cd":"'+'ACCESSORY';
            reqBody += '","division": {"@version_num":"'+0+'","#text":"'+ poiType +'"},"models": {"model": {"@id":"'+modelId+'"}}},';
            reqBody += '"optional":{}},'; 
            reqBody += '"private":{"template_info":{"@class":"Model","@filename":"Model-GetModelCompleteDetails-MIT.xml","@xsd":"Model-GetModelCompleteDetails-MIT.xsd","@method":"GetModelCompleteDetails"},"stored_procedure":{"@name":"ecnetsp_Model_GetModelCompleteDetails"}}}}';
            request = B2B_IntegrationCallout.eConfigRequest('GetCompleteDetails',reqBody);
            Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
            HTTPResponse response = http.send(request);
            if(response.getStatusCode()==B2B_IntegrationConstants.STATUSCODE){
                String responseBody = response.getbody(); 
                String isError = '';
                String ErrorDescription ='';
                Map<String, Object> completeDetailResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                Map<String, Object> mapResponse_level1 = (Map<String, Object>)completeDetailResponse.get('mot');
                if(mapResponse_level1.containsKey('@Error')){
                    isError = (String)mapResponse_level1.get('@Error');
                    if(mapResponse_level1.containsKey('Error')){
                        Map<String, Object> errorMap = (Map<String, Object>)mapResponse_level1.get('Error');
                        if(errorMap.containsKey('Description')){
                            ErrorDescription = JSON.serialize(errorMap.get('Description'));
                        }
                    }
                    if(isError == 'true')
                        objCompleteDetailByModelId.isError = true;
                    objCompleteDetailByModelId.errorMessage = ErrorDescription;
                    returnResponse = JSON.serialize(objCompleteDetailByModelId);
                }else {
                    //add optional to wrapper 
                    Map<String, Object> mapDbResult = (Map<String, Object>)mapResponse_level1.get('db_results');
                    objCompleteDetailByModelId.isError = false;
                    objCompleteDetailByModelId.errorMessage = null;
                    objCompleteDetailByModelId.accessoryResult = JSON.serialize(mapDbResult.get('JSON'));
                    returnResponse = JSON.serialize(objCompleteDetailByModelId);
                }  
            }else{
                // HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);
                String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                String severity;
                String errorType;
                Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity= errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType=errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                Boolean createError = true;
                if(response.getBody().containsIgnoreCase('The model is not active.') && String.valueOf(response.getStatusCode()) == '400'){
                    createError = false;
                }
                if(createError){
                Error__c errorRecord=B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_EconfigIntegration',String.valueOf(response.getStatusCode()),errorType,'','getCompleteDetail',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                }
                objCompleteDetailByModelId.isError = true;//Added by Faraz on 17/06/2022
                objCompleteDetailByModelId.errorMessage = 'Response:'+response.getBody();//Added by Faraz on 17/06/2022
                returnResponse = JSON.serialize(objCompleteDetailByModelId);//Added by Faraz on 17/06/2022
                // HDMP-8617- End of changes
            }
            
        }
        catch(Exception ex){
            objCompleteDetailByModelId.isError = true;
            objCompleteDetailByModelId.errorMessage = ex.getMessage();
            returnResponse = JSON.serialize(objCompleteDetailByModelId);
        }
        return returnResponse;
    }
    /*
This method is to Econfig Vin Decoder web Service
This will provide a json string containing vehicle detail
*/
    @AuraEnabled
    public static String callVinDecoderService(String vinNumber, String poiType){
        VinDecoderResponse objVinDecodercls = New VinDecoderResponse();
        try{
            B2B_Econfig_Request__mdt objMetaData = [SELECT B2B_Application_Id__c,B2B_Check_sum__c,B2B_Domain__c,B2B_Environment__c,B2B_Server_IP__c,B2B_Session_Id__c 
                                                    FROM  B2B_Econfig_Request__mdt 
                                                    WHERE DeveloperName = 'VinDecoderRequest'];
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            VinDecoderRequestSetting__c vinSetting = VinDecoderRequestSetting__c.getInstance();
            String reqBody = '{"mit": {"@mit_version_number": "1","@mit_version_date": "2018-04-12",';
            reqBody += '"client_info":'+ '{"@application_id":"'+ objMetaData.B2B_Application_Id__c +'","@echo_input": "true","@server_ip":"'+ objMetaData.B2B_Server_IP__c +'","@session_id":"'+ objMetaData.B2B_Session_Id__c +'","@domain":"'+ objMetaData.B2B_Domain__c;
            reqBody += '","@environment":"'+ objMetaData.B2B_Environment__c +'"},"input_parameters": {"required": {"vins": {"vin": {"@vin_number": "'+vinNumber+'","@division_cd":"'+poiType;
            reqBody += '"}}},"optional": {"parts_catalog": {"@return_ids": "true"}, "assets": { "@suppress_asset_name": "true","@suppress_asset_description": "true","asset": [{"@type_cd": "IMGOVERLAY","@view_cd": "34FRONT"},{"@type_cd": "IMGMIDSIZE","@view_cd": "34FRONT"},{"@type_cd": "BASECAR","@view_cd": "34FRONT"}]  }} },'+'"private": {"@check_sum":"'+ objMetaData.B2B_Check_sum__c +'","template_info": {"@class": "Model","@filename": "Model-GetModelByVin-MIT.xml","@method": "GetModelByVIN","@xsd": "Model-GetModelByVin-MIT.xsd"},"stored_procedure": {"@name": "ecnetsp_Model_GetModelByVIN"}}}}';
            request = B2B_IntegrationCallout.eConfigRequest('GetModelByVIN',reqBody) ;
            Long beforeAPI =B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
            HTTPResponse response = http.send(request);
            if(response.getStatusCode()==B2B_IntegrationConstants.STATUSCODE){
                Map<String, Object> vinResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> mapResponse_level1 = (Map<String, Object>) vinResponse.get('mot');
                HierarchyDetails objHierarchyDetails = New HierarchyDetails();
                if(!mapResponse_level1.isEmpty() && mapResponse_level1.containsKey('@Error') && (String)mapResponse_level1.get('@Error') == 'true'){
                    Map<String, Object> mapError = (Map<String, Object>)mapResponse_level1.get('Error');
                    String errorDescription = (String)mapError.get('Description');
                    objVinDecodercls.isError = true;
                    objVinDecodercls.message = errorDescription;
                    objVinDecodercls.selectorDetail = objHierarchyDetails;
                }else{
                    Map<String, Object> mapDbResult = (Map<String, Object>)mapResponse_level1.get('db_results');
                    Map<String, Object> mapVins = (Map<String, Object>)mapDbResult.get('vins');
                    List<Object> listVin = (List<Object>) mapVins.get('vin');
                    Map<String, Object> mapVin = (Map<String, Object>)listVin[0];
                    if(mapVin.containsKey('@error_action')){
                        objVinDecodercls.isError = true;
                        objVinDecodercls.message = (String)mapVin.get('@error_action');
                        objVinDecodercls.selectorDetail = objHierarchyDetails;
                    }else{
                        Map<String, Object> mapModel = (Map<String, Object>)mapVin.get('model');
                        if(!mapModel.isEmpty() && mapModel.containskey('@id')){
                            objHierarchyDetails.modelId = (String)mapModel.get('@id');
                        }
                        if(!mapModel.isEmpty() && mapModel.containskey('@trim_name')){
                            objHierarchyDetails.trim = (String)mapModel.get('@trim_name');
                        }
                        if(!mapModel.isEmpty() && mapModel.containskey('@doors_name')){
                            objHierarchyDetails.doors = (String)mapModel.get('@doors_name');
                        }
                        if(!mapModel.isEmpty() && mapModel.containskey('@trans_name')){
                            objHierarchyDetails.trans = (String)mapModel.get('@trans_name');
                        }
                        if(!mapModel.isEmpty() && mapModel.containskey('@make')){
                            objHierarchyDetails.make = (String)mapModel.get('@make');
                        }
                        if(!mapModel.isEmpty() && mapModel.containskey('@model_name')){
                            objHierarchyDetails.model = (String)mapModel.get('@model_name');
                        }
                        if(!mapModel.isEmpty() && mapModel.containskey('@model_year')){
                            objHierarchyDetails.year = (String)mapModel.get('@model_year');
                        }
                        if(!mapModel.isEmpty() && mapModel.containskey('parts_catalog')){
                            objHierarchyDetails.partsCatalog = JSON.serialize(mapModel.get('parts_catalog'));
                        }
                        if(!mapModel.isEmpty() && mapModel.containskey('colors')){
                            objHierarchyDetails.colors = JSON.serialize(mapModel.get('colors'));
                        }
                        objVinDecodercls.isError = false;
                        objVinDecodercls.message = '';
                        objVinDecodercls.selectorDetail = objHierarchyDetails;
                    }
                } }else{
                    //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                    Long afterAPI =B2B_Util.fetchCurrentTime();
                    Long durationTime =B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);// to calculate duration time between before API and after API
                    String severity;
                    String errorType;
                    // Below custom metadata provide the information related to Severity and error type based on the feature
                    Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                    if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                        severity= errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                        errorType=errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                    }
                    else{
                        severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                        errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                    }
                    String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                    Error__c errorRecord=B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_EconfigIntegration',String.valueOf(response.getStatusCode()),errorType,'','callVinDecoderService',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                    //HDMP-8617- End of changes
                }   
            
            
        }catch(Exception ex){
            objVinDecodercls.isError = false;
            objVinDecodercls.message = ex.getMessage()+'LineNumber'+ex.getLineNumber();
        }
        return JSON.serialize(objVinDecodercls);
    }
    public static void vertexCalloutTesting(){
        String requestBodyString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:vertexinc:o-series:tps:9:0"><soapenv:Header/><soapenv:Body><urn:VertexEnvelope><urn:Login><urn:TrustedId>$tr.Jw2zyXCr</urn:TrustedId></urn:Login><QuotationRequest documentDate="2021-02-19" postingDate="2021-02-19" transactionType="SALE"><Seller><Company>AHM Group</Company><Division>206500</Division></Seller><LineItem lineItemNumber="1"><Seller><AdministrativeOrigin><StreetAddress1>4300 S Georgia St</StreetAddress1><City>AMARILLO</City><MainDivision>TX</MainDivision><PostalCode>79110-1722</PostalCode></AdministrativeOrigin></Seller><Customer><Destination><StreetAddress1>1234 Main Street</StreetAddress1><City>DALLAS</City><MainDivision>TX</MainDivision><PostalCode>75201</PostalCode></Destination></Customer><Product>00004</Product><ExtendedPrice>100</ExtendedPrice></LineItem><LineItem lineItemNumber="2"><Seller><AdministrativeOrigin><StreetAddress1>4300 S Georgia St</StreetAddress1><City>AMARILLO</City><MainDivision>TX</MainDivision><PostalCode>79110-1722</PostalCode></AdministrativeOrigin></Seller><Customer><Destination><StreetAddress1>1234 Main St</StreetAddress1><City>DALLAS</City><MainDivision>TX</MainDivision><PostalCode>75201</PostalCode></Destination></Customer><ExtendedPrice>200</ExtendedPrice></LineItem></QuotationRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'text/xml');
        request.setMethod('POST');
        request.setBody(requestBodyString);
        request.setEndpoint('https://honda2.ondemand.vertexinc.com:443/vertex-ws/services/CalculateTax90');               
        HTTPResponse response = http.send(request);
    }
    
    /*
This method is to get Dealer details based on ZipCode provide from Dealer location UI
This contains two parameters serviceFor, is to whom we are looking a dealer (Honda/Acura)
Second parameter is zipcode which will be provided by UI.
*/
    @auraEnabled
    public static string dealerLocatorService(String serviceFor,String zipCode,String city,String state,String dealerName, String radius){
        DealerServiceResponse objDealerResponse = New DealerServiceResponse();
        Set<String> activePoIds = new Set<String>();
        for(Account acc:[SELECT id,PoIId__c,Participation_Code__c 
                         FROM Account 
                         WHERE IsActive__c = true ]){
            if(acc.Participation_Code__c != null && acc.Participation_Code__c.contains('DRM')){
                activePoIds.add(acc.PoIId__c);
            }           
        }
        for(BT_Token_Details__c btd:[SELECT id,Account__r.PoIId__c, Account__r.Participation_Code__c 
                                     FROM BT_Token_Details__c]){
            if(btd.Account__r.Participation_Code__c != null && btd.Account__r.Participation_Code__c.contains('DRM')){
                activePoIds.add(btd.Account__r.PoIId__c);
            }
        }
        try{
            String guId = B2B_Util.createGui();
            // Creating Http request
            Http http = new Http();
            HttpRequest request = new HttpRequest();           
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('hondaHeaderType.messageId',guId);
            // request.setHeader('Authorization','Basic c2VydmljZV9iMmNfbG9jYXRpb246eXVLbjVkZW4yQGNGZHI=');
            request.setHeader('accept','application/json');
            request.setMethod('GET');
            String endPointUrl = 'callout:B2B_Dealer_Credential';
            endPointUrl += Label.B2B_Dealer_Locator_URL;
            if(serviceFor == B2B_Constant.HONDA_VALUE){
                //endPointUrl = endPointUrl + 'bodyshops.honda.com';
                endPointUrl = endPointUrl + '&POIType=A';
                endPointUrl = endPointUrl + '&Filters=ATTR_A_DA';
                endPointUrl = endPointUrl + '&AttributeCdCSV=GP,GS,GG,DA';
            }else{
                //endPointUrl = endPointUrl + 'bodyshops.honda.com';
                endPointUrl = endPointUrl + '&POIType=B';
                endPointUrl = endPointUrl + '&Filters=ATTR_A_DB';
                endPointUrl = endPointUrl + '&AttributeCdCSV=GP,GS,GG,DB';
            } 
            if(!String.isEmpty(dealerName)){
                String poiName = getRequestedString(dealerName);
                endPointUrl = endPointUrl + '&POIName='+ poiName +'&SearchRadius=' + radius +'&NumberOfPOIs=21'+'&ShowAllAttributes=False&ShowAllProperties=False&ShowAllDepartments=True&Output=json';
            }
            if(!String.isEmpty(zipCode)){
                endPointUrl = endPointUrl + '&ZipCode='+ zipCode +'&SearchRadius='+ radius +'&NumberOfPOIs=21'+'&ShowAllAttributes=False&ShowAllProperties=False&ShowAllDepartments=True&Output=json';
            }if(!String.isEmpty(city) || (!String.isEmpty(state))){
                String cityName = getRequestedString(city);
                endPointUrl = endPointUrl + '&City='+cityName+'&State='+ state+'&SearchRadius='+ radius +'&NumberOfPOIs=21'+'&ShowAllAttributes=False&ShowAllProperties=False&ShowAllDepartments=True&Output=json';
            } 
            request.setEndPoint(endPointUrl);
            // Getting response from Econfig Server.
            Long beforeAPI = DateTime.now().getTime();// HDMP-8617- This will provide initial response time
            HTTPResponse response = http.send(request);
            if(response.getStatusCode()==B2B_IntegrationConstants.STATUSCODE){
                String responseBody = response.getBody();
                // Parsing the response body.
                List<Map<String, Object>> myMaps = new List<Map<String, Object>>();
                Map<String, Object> poiResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                Map<String, Object> mapResponse_level1 = (Map<String, Object>) poiResponse.get('POIResponse');
                if(!mapResponse_level1.containsKey('ResultCount') || (mapResponse_level1.containsKey('ResultCount') && (String)mapResponse_level1.get('ResultCount') == '0' )){
                    Map<String, Object> mapResponse_level2 = (Map<String, Object>) mapResponse_level1.get('Error');
                    String errorResponse = (String)mapResponse_level2.get('Description');
                    objDealerResponse.isError = true;
                    objDealerResponse.message = errorResponse;
                }else if(mapResponse_level1.containsKey('ResultCount') && (String)mapResponse_level1.get('ResultCount') != '0'){
                    Map<String, Object> mapPois = (Map<String, Object>)mapResponse_level1.get('POIs');
                    List<Object> poiList = (List<Object>)mapPois.get('POI');
                    List<Map<String, Object>> mapListofAllPois = new List<Map<String, Object>>();
                    for(Object poidetail : poiList){
                        Map<String, Object> data = (Map<String, Object>)poidetail;
                        String ss=(String)data.get('POIId'); 
                        If(activePoIds.contains(ss)){                                                               
                            //for Awards
                            Map<String, Object> Attributes = (Map<String, Object>)data.get('Attributes');
                            List<Object> AttributeList = (List<Object>)Attributes.get('Attribute'); 
                            List<Object> Awards = new List<Object>();
                            for(Object objAttribute : AttributeList){
                                Map<String, Object> AwardData = (Map<String, Object>) objAttribute;
                                if(String.valueOf(AwardData.get('Code')) == 'GP'){
                                    Awards.add(objAttribute);
                                }
                            }
                            data.put('Awards', (Object)Awards);                           
                            
                            //for departments
                            Map<String, Object> departments = (Map<String, Object>)data.get('Departments');
                            List<Object> departmentList = (List<Object>)departments.get('Department'); 
                            for(Object objDepartment : departmentList){
                                Map<String, Object> departmentData = (Map<String, Object>) objDepartment;
                                if(String.valueOf(departmentData.get('Name')) == 'Parts Management'){                                
                                    String operationHour = departmentData.ContainsKey('OperationHour') ? JSON.serialize(departmentData.get('OperationHour')) : null;
                                    data.put('partOperationHour',(object)operationHour);
                                    List<Object> contactList = departmentData.ContainsKey('Contact') ? (List<Object>) departmentData.get('Contact') : null;
                                    if(contactList != null && contactList.isEmpty() == false){
                                        Map<String, Object> contactData = (Map<String, Object>) contactList[0];
                                        data.put('dealerEmail',(object)contactData.get('Email'));
                                        data.put('sequenceNo',(object)contactData.get('SequenceNo'));
                                        data.put('firstName',(object)contactData.get('FirstName'));
                                        data.put('lastName',(object)contactData.get('LastName'));
                                    }
                                }                     
                            }
                            data.remove('Departments');
                            mapListofAllPois.add(data);
                        }
                    }                
                    objDealerResponse.isError = false;
                    objDealerResponse.message = '';
                    objDealerResponse.mapListofAllPois = mapListofAllPois;
                } 
            }else{
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime =B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);// to calculate duration time between before API and after API
                String severity;
                String errorType;
                //Below custom metadata provide the information related to Severity and error type based on the feature
                Map<String,B2B_Error_Handling__mdt> errorRecords=B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity= errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType=errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity=B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType=B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                Boolean createError = true;
                if(response.getBody().containsIgnoreCase('Invalid ZipCode.') && String.valueOf(response.getStatusCode()) == '400'){
                    createError = false;
                }
                if(createError){                
                String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord=B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_EconfigIntegration',String.valueOf(response.getStatusCode()),errorType,'','dealerLocatorService',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                }
                //HDMP-8617- End of changes
            }
            
        }catch(Exception ex){
            objDealerResponse.isError = false;
            objDealerResponse.message = ex.getMessage();
        }
        return JSON.serialize(objDealerResponse);
    }
    
    // This method is used to update city name or dealer name as per request format
    public static string getRequestedString(String cityOrDealerName){
        String outputString ='';
        for(String ot : cityOrDealerName.split(' ')){
            if(ot.trim() != ''){
                outputString += ot.trim()+'+';
            }
        }
        outputString = outputString.removeEnd('+');
        return outputString;
    }
    
    @AuraEnabled
    public static String searchedDealerResponseStored(String email,String name, String operationHour,String firstName, String lastName, Decimal Latitude, Decimal Longitude,String award) {
        
        list<Account> lstOfAccount = [SELECT Id,B2B_Distance__Latitude__s,B2B_Dealer_Award__c, B2B_Distance__Longitude__s, B2B_Distance__c,Email__c,Operation_Hour__c,First_Name__c,Last_Name__c, Name 
                                      FROM Account 
                                      Where Name =: name 
                                      Limit 1];
        try{   
            if(lstOfAccount.size() >0 ){
                lstOfAccount.get(0).Email__c = email;
                lstOfAccount.get(0).Operation_Hour__c  = operationHour;
                lstOfAccount.get(0).First_Name__c = firstName;
                lstOfAccount.get(0).Last_Name__c = lastName;
                lstOfAccount.get(0).B2B_Distance__Latitude__s = Latitude;
                lstOfAccount.get(0).B2B_Distance__Longitude__s = Longitude;
                lstOfAccount.get(0).B2B_Dealer_Award__c = award;
                upsert lstOfAccount;
                return 'Success';
            }
            return 'Record not found...';
        }catch(Exception e){
            return 'Error while creating dealer at '+e.getMessage();
        }
    }
    @auraEnabled
    public static List<LocationResponseWrapper> getAccountResponse(List<DistanceWrapper> Inputparams)
    { 
        B2B_EconfigIntegration.sortBy='Distance';
        Map<String,Decimal> checkmap=new map<String,Decimal>();
        Map<String,String> checkmapweb=new map<String,String>();
        List<LocationResponseWrapper> WrapperList=new List<LocationResponseWrapper>();
        for(DistanceWrapper dis:Inputparams)
        {
            checkmap.put(dis.POIId,decimal.valueOf(dis.Distance));
            checkmapweb.put(dis.PoIId, dis.InternetAddress);
        }
        // Pratik LTIM Added for Sp4 Tax Jurisdctions Sales_Tax_Jurisdiction__c
        List<Account>  AccountsList=[SELECT Id,Name,PoIId__c,phone,billingState,billingcity,billingStreet,ShippingStreet,ShippingPostalCode,billingPostalcode,Sales_Tax_Jurisdiction__c FROM Account WHERE PoIId__c IN :checkmap.keyset() and isactive__c=true];
        try
        {     for(Account acc:AccountsList)
            {
                LocationResponseWrapper locwrap=new LocationResponseWrapper();
                locwrap.accountList=acc;
                locwrap.Distance=checkmap.get(acc.PoIId__c);
                locwrap.InternetAddress=checkmapweb.get(acc.PoIId__c);
                WrapperList.add(locwrap);
            }
            WrapperList.sort();
        }
        catch(exception ex){
        }
        return WrapperList;
    } 
    // This Inner class is used in dealerLocatorService() method
    public class DealerServiceResponse
    {
        public Boolean isError;
        public String message;
        List<Map<String, Object>> mapListofAllPois;        
        
        DealerServiceResponse(){
            isError = false;
            message = '';
            mapListofAllPois = New List<Map<String, Object>>();
        }
    }
    
    //Added Shalini 27-05-2021
    @AuraEnabled(cacheable=true)
    public static String getVehicleYear(String division){
        map<Decimal,Decimal> mapOfYear = new  map<Decimal,Decimal>();
        for( Vehicle__c veh: [SELECT Year__c,iNYearID__c 
                              FROM Vehicle__c 
                              WHERE iNDivisionID__c = :Integer.valueOf(division) ORDER BY iNYear__c DESC LIMIT 5000] ) {
                            mapOfYear.put(veh.iNYearID__c,veh.Year__c);
        }
        return JSON.serialize(mapOfYear);
    }
    @AuraEnabled(cacheable=true)
    public static String getVehicleModel(String division, Integer year){
        List<String> strList = new List<String>();
        map<String,String> mapOfModel = new  map<String,String>();
        for(Vehicle__c veh: [SELECT Model__c,Model_Id__c,iNYearID__c 
                             FROM Vehicle__c 
                             WHERE iNDivisionID__c = :Integer.valueOf(division) AND iNYearID__c = :year ORDER BY Model__c DESC])
                             {mapOfModel.put(veh.Model__c,veh.Model_Id__c);}
        return JSON.serialize(mapOfModel);
    }
    @AuraEnabled(cacheable=true)
    public static String getVehicleTrim(String division, Integer year, String modelValue){
        List<String> strList = new List<String>();
        map<String,String> mapOfTrim = new  map<String,String>(); 
        for(Vehicle__c veh: [SELECT iNGrade__c,Trim__c, iNYearID__c,Model_Id__c,iNModelID__c,iNTransmissionID__c, 
                             iNGradeID__c, iNCatalogID__c, iNDoorID__c
                             FROM Vehicle__c 
                             WHERE iNDivisionID__c = :Integer.valueOf(division) AND iNYearID__c = :year AND model__c =: modelValue ORDER BY Trim__c DESC]) 
                            { mapOfTrim.put(veh.Trim__c,String.valueOf(/*veh.iNTransmissionID__c + */veh.Model_Id__c/* + veh.iNCatalogID__c+ veh.iNDoorID__c*/));}
        return JSON.serialize(mapOfTrim);
    } 
    @AuraEnabled
    public static Vehicle__c getVehicleDetails(String yearValue, String modelValue, String trimValue, String division){
        Vehicle__c vehicle;
        if(String.isNotEmpty(division)){
            vehicle = [SELECT iNDivisionID__c, iNGradeID__c,iNYearID__c,iNDoorID__c,iNCatalogID__c,iNTransmissionID__c,iNModelID__c,Model_Id__c 
                   FROM Vehicle__c 
                   WHERE Year__c=:double.valueOf(yearValue) AND Model__c=:modelValue AND Trim__c=:trimValue AND iNDivisionID__c =: double.valueOf(division) LIMIT 1];
        }else {
        vehicle = [SELECT iNDivisionID__c, iNGradeID__c,iNYearID__c,iNDoorID__c,iNCatalogID__c,iNTransmissionID__c,iNModelID__c,Model_Id__c 
                   FROM Vehicle__c 
                   WHERE Year__c=:double.valueOf(yearValue) AND Model__c=:modelValue AND Trim__c=:trimValue LIMIT 1];
        }
        
        return vehicle;
    }
    
    @auraEnabled
    public static Map<String, String> getVehicleOptionsForHomepage(Integer yearValue, String modelValue, String trimValue, String division){
        String modelOptions = getVehicleModel(division, yearValue);
        String trimOptions = getVehicleTrim(division, yearValue, modelValue);
        Vehicle__c objVehicle =	getVehicleDetails(String.valueOf(yearValue), modelValue, trimValue, division);
        Map<String, String> mapVehicleDetails = new Map<String, String>();
        mapVehicleDetails.put('modelOptions', modelOptions);
        mapVehicleDetails.put('trimOptions', trimOptions);
        mapVehicleDetails.put('objVehicle', JSON.serialize(objVehicle));
        return mapVehicleDetails;
    }
    
    @AuraEnabled
    public static String getVehicleDetailsForParts(String modelId, String gradeId, String yearId,String transmissionId, String doorId, String catalogId){
        Vehicle__c vehicle;
        Map<String, String> mapVehicleDetails = new Map<String, String>();
        if(String.isNotEmpty(transmissionId)){
            vehicle = [SELECT iNDivisionID__c, iNGradeID__c,iNYearID__c,iNDoorID__c,iNCatalogID__c, iNTransmissionID__c, iNModelID__c,Model_Id__c, Model__c, Trim__c 
                       FROM Vehicle__c 
                       WHERE iNModelID__c =: Integer.valueOf(modelId) AND iNGradeID__c =: Integer.valueOf(gradeId) AND iNYearID__c =: Integer.valueOf(yearId) 
                       AND iNTransmissionID__c =: Integer.valueOf(transmissionId) AND iNDoorID__c =: Integer.valueOf(doorId) AND iNCatalogID__c =:Integer.valueOf(catalogId) Limit 1];
        }else {
            vehicle = [SELECT iNDivisionID__c, iNGradeID__c,iNYearID__c,iNDoorID__c,iNCatalogID__c, iNTransmissionID__c, iNModelID__c,Model_Id__c, Model__c, Trim__c 
                       FROM Vehicle__c 
                       WHERE iNModelID__c =: Integer.valueOf(modelId) AND iNGradeID__c =: Integer.valueOf(gradeId) AND iNYearID__c =: Integer.valueOf(yearId) 
                       AND iNDoorID__c =: Integer.valueOf(doorId) AND iNCatalogID__c =:Integer.valueOf(catalogId) Limit 1]; 
        }
        
        if(vehicle != null){
            String vehicleModels = getVehicleModel(String.valueOf(vehicle.iNDivisionID__c), Integer.valueOf(vehicle.iNYearID__c));
            String vehicleTrims = getVehicleTrim(String.valueOf(vehicle.iNDivisionID__c), Integer.valueOf(vehicle.iNYearID__c), vehicle.Model__c);
            mapVehicleDetails.put('vehicleModels',vehicleModels);
            mapVehicleDetails.put('vehicleTrims',vehicleTrims);
            mapVehicleDetails.put('vehicle',JSON.serialize(vehicle));                      
        }
        return JSON.serialize(mapVehicleDetails);
    }
    
    @AuraEnabled
    public static String getVehicleDetailsForAccessories(String modelId){
        Map<String, String> mapVehicleDetails = new Map<String, String>();
        Vehicle__c vehicle = [SELECT iNDivisionID__c, iNGradeID__c,iNYearID__c,Year__c,iNDoorID__c,iNCatalogID__c,iNModelID__c,Model_Id__c, Model__c, Trim__c 
                              FROM Vehicle__c 
                              WHERE Model_Id__c =: modelId Limit 1]; 
        if(vehicle != null){
            String vehicleModels = getVehicleModel(String.valueOf(vehicle.iNDivisionID__c), Integer.valueOf(vehicle.iNYearID__c));
            String vehicleTrims = getVehicleTrim(String.valueOf(vehicle.iNDivisionID__c), Integer.valueOf(vehicle.iNYearID__c), vehicle.Model__c);
            mapVehicleDetails.put('vehicleModels',vehicleModels);
            mapVehicleDetails.put('vehicleTrims',vehicleTrims);
            mapVehicleDetails.put('vehicle',JSON.serialize(vehicle));                      
        }
        return JSON.serialize(mapVehicleDetails);        
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getVehicleDoors(String make, String year, String model){
        List<String> strList = new List<String>();
        List<AggregateResult> doors = [SELECT Doors__c
                                       FROM Vehicle__c 
                                       WHERE Make__c = :make AND Year__c = :Integer.valueOf(year) AND Model__c = :model AND Doors__c != Null GROUP BY Doors__c];
        for(AggregateResult ar: doors) {
            strList.add(String.valueOf(ar.get('Doors__c')));
        }
        return strList;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getCategory(String ProductId) 
    {
        String categoryname  = [SELECT id,name,ProductCategory.name 
                                FROM ProductCategoryProduct 
                                WHERE ProductId=:ProductId LIMIT 1].ProductCategory.name;
        return categoryname;
    }
    
    @AuraEnabled(cacheable=true)
    public static String  getCartItemCategory(String cartId){
        List<String> productList=new List<String>();
        for(CartItem car:[SELECT Id,Product2Id 
                          FROM CartItem 
                          WHERE cartId =:cartId])
        {
            productList.add(car.Product2Id);
        }
        String Categoryname= getCategory(productList[0]);
        return Categoryname;
    }
    
    @AuraEnabled
    public static String getVehicleDetailsWithModalAndTrims(String yearValue, String modelValue, String trimValue ){
        String modalId;
        String vehicleDetailsWithModalTrim;
        modalId = [SELECT iNDivisionID__c, iNGradeID__c,iNYearID__c,iNDoorID__c,iNCatalogID__c,iNTransmissionID__c,iNModelID__c,Model_Id__c 
                   FROM Vehicle__c 
                   WHERE Year__c=:double.valueOf(yearValue) AND Model__c=:modelValue AND Trim__c=:trimValue LIMIT 1]?.Model_Id__c;
        if(String.isNotEmpty(modalId)){
            vehicleDetailsWithModalTrim = getVehicleDetailsForAccessories(modalId);
        }
        return vehicleDetailsWithModalTrim;
    }

    /**
     * Pratike LTIM Added the below function for Sales Tax Jurisdifcations
     */
    
    @AuraEnabled
    public static Boolean validateZipCodeAndDealerTaxJurisdiction(String Accid,String state,String zipcode, String poiType, String searchRadius, String numberOfPOIs){
        Boolean taxjuris;
        Account AccSTJ = [select id,Sales_Tax_Jurisdiction__c,ShippingState from Account where id=:Accid];
        String Tax_Jurisdiction = AccSTJ.Sales_Tax_Jurisdiction__c != null ?  AccSTJ.Sales_Tax_Jurisdiction__c : AccSTJ.ShippingState ;
        List<String> stj = Tax_Jurisdiction != null ? Tax_Jurisdiction.split(';') : new List<string>();
        List<String> stjpoi = B2B_SearchByPOIZipCode.HitB2CCloud(state,zipcode,poiType,searchRadius,numberOfPOIs);
        system.debug('Shipping State---'+ AccSTJ.ShippingState);
        system.debug('Sales Tax Juridifcations---'+AccSTJ.Sales_Tax_Jurisdiction__c);
        system.debug('Tax Value---'+Tax_Jurisdiction);
        for(String s : stj){
            system.debug('Search--'+s);
            taxjuris = stjpoi.contains(s);
            if(taxjuris == true){
                return taxjuris;
            }
        }
        return false;
    }
    
    public class VinDecoderResponse{
        public Boolean isError;
        public String message;
        public HierarchyDetails selectorDetail;
    }
    
    public class HierarchyDetails{
        public String modelId;
        public String year;
        public String make;
        public String model;
        public String trim;
        public String trans;
        public String doors;
        public String partsCatalog;
        public String colors;
    }
    
    public class GetCompleteDetailsResponse{
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String messages;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String accessoryResult;
    }
    
    public class LocationResponseWrapper implements Comparable
    {
        @AuraEnabled
        public Account accountList{get;set;}
        @AuraEnabled
        public Decimal Distance{get;set;}
        @AuraEnabled
        public String InternetAddress{get;set;}
        public Integer compareTo(Object obj)
        {
            LocationResponseWrapper loc=(LocationResponseWrapper)obj;
            
            if (Distance == loc.Distance) return 0;
            if (Distance < loc.Distance) return -1;
            else
            {
                return 1;
            }
            
        }   
    }
    
    public class DistanceWrapper 
    {
        @AuraEnabled
        public String POIId{get;set;}
        @AuraEnabled
        public String Distance{get;set;}
        @AuraEnabled
        public String InternetAddress{get;set;}
    }
    
    
}
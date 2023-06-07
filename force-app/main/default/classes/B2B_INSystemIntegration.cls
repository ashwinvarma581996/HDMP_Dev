/*******************************************************************************
Name: B2B_INSystemIntegration
Business Unit: HDM
Date: 22/04/2021
Developer: Radhey Shyam Gupta/RajRishi Kaushik/Arun Prasad/Apoorv Garg
Description: This class handles all the Integrations related to IN System.
Test ClassName- B2B_INSystemIntegrationTest,B2B_INSystemIntegrationTestMock,B2B_INSystemIntegrationTestMockData(Mock Class to handle error handling)
*******************************************************************************
MODIFICATIONS – Date | Dev Name 	| Method | User Story
		  23/05/2022 | Soumya Sahoo |  Error handling changes- JIRA- 8617
*******************************************************************************/

public class B2B_INSystemIntegration{
    
    public class ResponseWrapperVinDecoder
    { 
        public String errorMessage = '';
        public Boolean isError = false;
        public String errorCode = '';
        public String errorType = '';     
        public ResponseWrapperVinDecoder()
        {
            this.errorMessage = '';
            this.isError = false;
            this.errorCode = '';
            this.errorType = '';    
        }
    }
    
    @AuraEnabled
    public static String GetModelByVinDecoder(String vincode, Integer division){
        ResponseWrapperVinDecoder objResponseWrapper = New ResponseWrapperVinDecoder();
        B2B_INCatalogWrapper catalog = new B2B_INCatalogWrapper();
        DateTime startTime = datetime.now();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String reqBody = '{"RegionID": 1, "DivisionID":'+ division+', "LanguageID": 0, "VIN":"'+vincode+'"}';
            request = B2B_IntegrationCallout.inSystemRequest('GetModelByVinDecoder', reqBody);
            Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
            HTTPResponse response = http.send(request);
            if(response.getStatusCode()==B2B_IntegrationConstants.STATUSCODE){
                String responseBody = response.getbody();
                responseBody = responseBody.unescapeHtml4();
                responseBody = responseBody.unescapeHtml3();
                Map<String,Object> vinDecoderResponse = (Map<String,Object>)JSON.deserializeUntyped(responseBody);
                if(vinDecoderResponse.containsKey('Header')){
                    Map<String,Object> headers = (Map<String,Object>) vinDecoderResponse.get('Header'); 
                    String status = (String) headers.get('Status');               
                    if(status == 'Success'){
                        Map<String,Object> mapBody = (Map<String,Object>)vinDecoderResponse.get('Body');
                        Map<String,Object> CatalogMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(mapBody.get('Catalog')));
                        List<Object> Sections = (List<Object>)JSON.deserializeUntyped(JSON.serialize(CatalogMap.get('Sections')));
                        List<Object> sectionsList = new List<Object>();
                        sectionsList = replaceImages(Sections);
                        CatalogMap.put('Sections',sectionsList);
                        mapBody.put('Catalog',CatalogMap);
                        Boolean errorflag = (Boolean)mapBody.get('ErrorFlag');
                        
                        if(mapBody.containsKey('Catalog') && errorflag == false) {                
                           // modified by Rajrishi Kaushik on 18 May 2021
                            String  jsonString = JSON.serialize(mapBody.get('Catalog'));                        
                            catalog = B2B_INCatalogWrapper.parse(jsonString); 
                        }else {
                            objResponseWrapper.isError = true;
                            objResponseWrapper.errorMessage = (String)mapBody.get('ErrorMessage');
                            objResponseWrapper.errorCode = (String)mapBody.get('ErrorCode');
                            objResponseWrapper.errorType = (String)mapBody.get('ErrorType');
                            DateTime endTime = datetime.now();
                            Long timeAvailable = endTime.getTime() - startTime.getTime();
                            return JSON.serialize(objResponseWrapper);
                        }
                    }else{
                        Object objErrorData = ((List<Object>)headers.get('Errors'))[0];
                        Map<String,Object> mapError = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(objErrorData));
                        objResponseWrapper.isError = true;
                        objResponseWrapper.errorMessage = (String)mapError.get('ErrorMessage');
                        objResponseWrapper.errorCode = (String)mapError.get('ErrorCode');
                        objResponseWrapper.errorType = (String)mapError.get('ErrorType');
                        
                        DateTime endTime = datetime.now();
                        Long timeAvailable = endTime.getTime() - startTime.getTime();
                        return JSON.serialize(objResponseWrapper);
                    }
                }else{
                    Object errorobject = vinDecoderResponse.get('errors');
                    Map<String,Object> mapError = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(errorobject));
                    Object objVin = mapError.get('VIN');
                    objResponseWrapper.isError = true;
                    objResponseWrapper.errorMessage = JSON.serialize(objVin);
                    DateTime endTime = datetime.now();
                    Long timeAvailable = endTime.getTime() - startTime.getTime();
                    return JSON.serialize(objResponseWrapper);
                }
            }else{
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);// to calculate duration time between before API and after API
                String severity;
                String errorType;
                //Below custom metadata provide the information related to Severity and error type based on the feature
                Map<String,B2B_Error_Handling__mdt> errorRecords = B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity = errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType = errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity = B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType = B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                Boolean createError = true;
                if(response.getBody().containsIgnoreCase('Invalid VIN') && String.valueOf(response.getStatusCode()) == '400'){
                    createError = false;
                }
                if(createError){
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord = B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_INSystemIntegration',String.valueOf(response.getStatusCode()),errorType,'','GetModelByVinDecoder',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                }
                //HDMP-8617- End of changes
                objResponseWrapper.isError = true;
                objResponseWrapper.errorMessage = 'Please enter valid VIN';
                return JSON.serialize(objResponseWrapper);  
            }
        }catch(Exception ex){
            objResponseWrapper.isError = true;
            //Modified by Apoorv Garg(Line 59)
            objResponseWrapper.errorMessage = ex.getMessage() + ex.getLineNumber(); 
            objResponseWrapper.errorCode = '';
            return JSON.serialize(objResponseWrapper);
        }  
        DateTime endTime = datetime.now();
        Long timeAvailable = endTime.getTime() - startTime.getTime();
        return JSON.serialize(catalog);
    }
    
/*
Created By : Rajrishi Kaushik
Date : 18/05/2021
Description : This method is provide SubCategories(Illustration) by sectionId and other product relatedId.
*/ 
    
    @AuraEnabled
    public static String GetIllustrationBySectionID(String reqBody){
        ResponseWrapperVinDecoder objResponseWrapper = New ResponseWrapperVinDecoder();
        B2B_INCatalogWrapper illustration = new B2B_INCatalogWrapper();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();            
            request = B2B_IntegrationCallout.inSystemRequest('GetIllustrationBySectionID', reqBody);
            Long beforeAPI = B2B_Util.fetchCurrentTime();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                Map<String,Object> vinDecoderResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> headers = (Map<String,Object>) vinDecoderResponse.get('Header'); 
                String status = (String) headers.get('Status');
                if(status == 'Success'){
                    String jsonString = JSON.serialize(vinDecoderResponse.get('Body'));          
                    illustration = B2B_INCatalogWrapper.parse(jsonString);    
                }else {
                    objResponseWrapper.isError = true;
                    objResponseWrapper.errorMessage = 'Some Error occured';
                    objResponseWrapper.errorCode = '';
                    //Modified by Apoorv Garg (Line 96)
                    objResponseWrapper.errorType = Label.B2B_INSystemIntegrationErrorType;
                    return JSON.serialize(objResponseWrapper);
                }
            }else{
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);// to calculate duration time between before API and after API
                String severity;
                String errorType;
                //Below custom metadata provide the information related to Severity and error type based on the feature
                Map<String,B2B_Error_Handling__mdt> errorRecords = B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity = errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType = errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity = B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType = B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord = B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_INSystemIntegration',String.valueOf(response.getStatusCode()),errorType,'','GetIllustrationBySectionID',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                //HDMP-8617- End of changes
            }           
            
        }catch(Exception ex){
            objResponseWrapper.isError = true;
            //Modified by Apoorv Garg(Line 104)
            objResponseWrapper.errorMessage = ex.getMessage() + ex.getLineNumber(); 
            objResponseWrapper.errorCode = '';
            return JSON.serialize(objResponseWrapper);
        }  
        return JSON.serialize(illustration);
    }
    
/*
Created By : Rajrishi Kaushik
Date : 20/05/2021
Description : this method Get Parts based on ProductID, YearID, DoorID, GradeID, CatalogID, SectionID, 
IllustrationGroupID, IllustrationGroupImageID.
*/ 
    @AuraEnabled
    public static String GetPartsByIllustrationID(String reqBody){
        ResponseWrapperVinDecoder objResponseWrapper = New ResponseWrapperVinDecoder();
        B2B_INCatalogWrapper part = new B2B_INCatalogWrapper();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();            
            request = B2B_IntegrationCallout.inSystemRequest('GetPartsByIllustrationID', reqBody);
            Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                Map<String,Object> vinDecoderResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());                
                Map<String,Object> headers = (Map<String,Object>) vinDecoderResponse.get('Header'); 
                String status = (String) headers.get('Status');
                if(status == 'Success'){
                    String  jsonString = JSON.serialize(vinDecoderResponse.get('Body'));                        
                    part = B2B_INCatalogWrapper.parse(jsonString);    
                }else {
                    objResponseWrapper.isError = true;
                    objResponseWrapper.errorMessage = 'Some Error occured';
                    objResponseWrapper.errorCode = '';
                    //Modified by Apoorv Garg (Line 141)
                    objResponseWrapper.errorType = Label.B2B_INSystemIntegrationErrorType;
                    return JSON.serialize(objResponseWrapper);
                }
            }else{
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);// to calculate duration time between before API and after API
                String severity;
                String errorType;
                //Below custom metadata provide the information related to Severity and error type based on the feature
                Map<String,B2B_Error_Handling__mdt> errorRecords = B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity = errorRecords.get(String.valueOf(response.getStatusCode())).severity__c; 
                    errorType = errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity = B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType = B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord = B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_INSystemIntegration',String.valueOf(response.getStatusCode()),errorType,'','GetPartsByIllustrationID',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                //HDMP-8617- End of changes
            }
            
        }catch(Exception ex){
            objResponseWrapper.isError = true;
            //Modified by Apoorv Garg(Line 149)
            objResponseWrapper.errorMessage = ex.getMessage() + ex.getLineNumber(); 
            objResponseWrapper.errorCode = '';
            return JSON.serialize(objResponseWrapper);
        }  
        return JSON.serialize(part);
    }
    
    /*
Created By : Arunprasad
Date : 1/06/2021
Description : Products Dealer Pricing.
*/ 
    @AuraEnabled
    public static List<ProductDealerPrice> getProductDealerPricing(String reqBody){
        try{
            List<ProductDealerPrice> productDealerPrices = new List<ProductDealerPrice>();
            productDealerPrices.add(new ProductDealerPrice('16400-59B-003', '123.45'));
            productDealerPrices.add(new ProductDealerPrice('16430-RTA-J01', '563.45'));
            return productDealerPrices;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }  
    }
    
    public class ProductDealerPrice {
        @AuraEnabled
        public String PartNumber {get; set;}
        @AuraEnabled
        public String DealerPrice {get; set;}
        public ProductDealerPrice(String partNumber, String dealerPrice){
            this.PartNumber = partNumber;
            this.dealerPrice = dealerPrice;
        }
        
    }
    
    /*
Created By : Apoorv Garg
Date : 11/06/2021
Description : Get Dealer Price.
*/ 
    @AuraEnabled
    public static String GetDealerPrice(String dealerNo,Integer divisionId, String partNumbers, String accessories){
        ResponseWrapperVinDecoder objResponseWrapper = New ResponseWrapperVinDecoder();
        String jsonResponse;
        try{
            Http http = new Http();
            String usernamePassword = Label.B2B_IN_QAUserName+':'+Label.B2B_IN_Password;
            String authorizationString = EncodingUtil.base64Encode(Blob.valueof(usernamePassword));
            HttpRequest request = new HttpRequest();          
            request.setHeader('accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Basic '+authorizationString);
            request.setHeader('hondaHeaderType.siteId', Label.B2B_IN_SiteId);
            request.setHeader('hondaHeaderType.businessId', Label.B2B_IN_BusinessId); 
            request.setHeader('hondaHeaderType.ApplicationId', Label.B2B_IN_ApplicationId);    
            request.setHeader('hondaHeaderType.messageId', '87d184ad-9de8-4e2e-a47c-473ffd0afbe3');
            request.setHeader('hondaHeaderType.collectedTimestamp', datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'America/Los_Angeles')); 
            request.setMethod('POST');
            
            String reqBody = '{"DealerNo": '+dealerNo+',"DivisionID": '+divisionId+',"PartNumbers": '+partNumbers+' ,"Accessories":'+accessories+'}';
            request.setBody(reqBody);
            request.setEndpoint(Label.B2B_IN_GetDealerPrice_QAUrl_Path);
            Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
            System.debug(' >>>>>>reqBody::: '+reqBody);
            HTTPResponse response = new HTTPResponse(); 
                //AMSDS-110 - Modified by Pramod kumar  (Line 316,316, 357 to 363)
                if(!string.isblank(dealerNo)){
                    response =  http.send(request);
            if(response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                Map<String,Object> vinDecoderResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());   
                Map<String,Object> headers = (Map<String,Object>) vinDecoderResponse.get('Header'); 
                String status = (String) headers.get('Status');
                if(status == 'Success'){
                   jsonResponse = JSON.serialize(vinDecoderResponse.get('Body'));       
                }else {
                    objResponseWrapper.isError = true;
                    objResponseWrapper.errorMessage = 'Some Error occured';
                    objResponseWrapper.errorCode = '';
                    objResponseWrapper.errorType = Label.B2B_INSystemIntegrationErrorType;
                    return JSON.serialize(objResponseWrapper);
                }
            }else{
                // HDMP- 5326(R2B)- Below lines of code added to handle error message to display when API is down
                objResponseWrapper.isError=TRUE;
                objResponseWrapper.errorMessage=B2B_IntegrationConstants.DEALER_API_DOWN_MESSAGE;
                // End of 5326 
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);// to calculate duration time between before API and after API
                String severity;
                String errorType;
                //Below custom metadata provide the information related to Severity and error type based on the feature
                Map<String,B2B_Error_Handling__mdt> errorRecords = B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity = errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType = errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity = B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType = B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord = B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_INSystemIntegration',String.valueOf(response.getStatusCode()),errorType,'','GetDealerPrice',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());  
                //HDMP-8617- End of changes
                return JSON.serialize(objResponseWrapper);
            }
                }else{
                    objResponseWrapper.isError = true;
                    objResponseWrapper.errorMessage = 'Dealer number is blank';
                    objResponseWrapper.errorCode = B2B_IntegrationConstants.BlankVariable;
                    objResponseWrapper.errorType = Label.B2B_INSystemIntegrationErrorType;
                    return JSON.serialize(objResponseWrapper);
                    
                }
        }catch(Exception ex){
            objResponseWrapper.isError = true;
            objResponseWrapper.errorMessage = ex.getMessage() + ex.getLineNumber(); 
            objResponseWrapper.errorCode = '';
            return JSON.serialize(objResponseWrapper);
        } 
        return jsonResponse;
    }
    
    /*
Created By : Apoorv Garg
Date : 21/05/2021
Description : This method Searches by Product based on ProductId
*/ 
    @AuraEnabled
    public static String SearchbyProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer TransmissionID){
        ResponseWrapperVinDecoder objResponseWrapper = New ResponseWrapperVinDecoder();
        B2B_INCatalogWrapper search = new B2B_INCatalogWrapper();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String reqBody = '{"RegionID": 1,"DivisionID": '+division+',"LanguageID": 0,"ProductCategoryID": 0,"ProductID": '+productId+',"DoorID": '+doorId+',"YearID": '+year+' ,"GradeID": '+gradeId+',"CatalogID": '+catalogId+',"AreaID": 0,"OriginID": 0,"TransmissionID": '+TransmissionID+',"ColorLabelID": 0,"ColorNameID": 0,"SectionID": 0,"IllustrationGroupID":0,"IllustrationGroupImageID": 0}';
            request = B2B_IntegrationCallout.inSystemRequest('SearchbyProduct', reqBody);
            Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                Map<String,Object> searchProductResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> headers = (Map<String,Object>) searchProductResponse.get('Header'); 
                String status = (String) headers.get('Status');
                if(status == 'Success' || response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                    String  jsonString = JSON.serialize(searchProductResponse.get('Body')); 
                    Map<String,Object> bodyResp = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
                    List<Object> Sections = (List<Object>)JSON.deserializeUntyped(JSON.serialize(bodyResp.get('Sections')));
                    List<Object> sectionsList = new List<Object>();
                    sectionsList = replaceImages(Sections); 
                    bodyResp.put('Sections',sectionsList);
                    jsonString = JSON.serialize(bodyResp);
                    search = B2B_INCatalogWrapper.parse(jsonString);    
                }else {
                    objResponseWrapper.isError = true;
                    objResponseWrapper.errorMessage = 'Some Error occured';
                    objResponseWrapper.errorCode = '';
                    //Modified by Apoorv Garg (Line 219)
                    objResponseWrapper.errorType = Label.B2B_INSystemIntegrationErrorType;
                    return JSON.serialize(objResponseWrapper);
                }
            }else{
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);// to calculate duration time between before API and after API
                String severity;
                String errorType;
                //Below custom metadata provide the information related to Severity and error type based on the feature
                Map<String,B2B_Error_Handling__mdt> errorRecords = B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity = errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType = errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity = B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType = B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord = B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_INSystemIntegration',String.valueOf(response.getStatusCode()),errorType,'','SearchbyProduct',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                //HDMP-8617- End of changes
            }
        }catch(Exception ex){
            objResponseWrapper.isError = true;
            //Modified by Apoorv Garg(Line 227)
            objResponseWrapper.errorMessage = ex.getMessage() + ex.getLineNumber(); 
            objResponseWrapper.errorCode = '';
            return JSON.serialize(objResponseWrapper);
        }  
        return JSON.serialize(search);
    }
    /*
Created By : Soumya Sahoo
Date : 16/12/2021
Description : This method provides MaintainencePart Details
*/ 
    
    @AuraEnabled
    public static String maintainenceProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer TransmissionID){
        ResponseWrapperVinDecoder objResponseWrapper = New ResponseWrapperVinDecoder();
        B2B_INCatalogWrapper search = new B2B_INCatalogWrapper();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            List<B2B_Vehicle_Function_Code_Junction__c> vehicleCodeList = B2B_IntegrationUtility.getfunctioncodes(gradeId,year,division,catalogId,doorId);
            string functioncode = '[';
            for(B2B_Vehicle_Function_Code_Junction__c vehicleFuncObj : vehicleCodeList){
                functionCode += '"'+vehicleFuncObj.B2B_Function_Codes__r.B2B_Code__c + '",';
            }
            functionCode = functionCode.removeEnd(',');
            functionCode += ']';
            String reqBody = '{"RegionID": 1,"DivisionID": '+division+',"LanguageID": 0,"ProductCategoryID": 0,"ProductID": '+productId+',"DoorID": '+doorId+',"YearID": '+year+' ,"GradeID": '+gradeId+',"CatalogID": '+catalogId+',"AreaID": 0,"OriginID": 0,"TransmissionID": '+TransmissionID+',"ColorLabelID": 0,"ColorNameID": 0,"FunctionCodes":'+functionCode+'}';
            request = B2B_IntegrationCallout.inSystemRequestPartial('MaintainenceProduct', reqBody);
            Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
            HTTPResponse response = http.send(request);

            if(response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                Map<String,Object> searchProductResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> headers = (Map<String,Object>) searchProductResponse.get('Header'); 
                String status = (String) headers.get('Status');
                if(status == B2B_Constant.SUCCESS){
                    String  jsonString = JSON.serialize(searchProductResponse.get('Body')); 
                    Map<String,Object> bodyResp = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
                    List<Object> Sections = (List<Object>)JSON.deserializeUntyped(JSON.serialize(bodyResp.get(B2B_IntegrationConstants.Sections)));
                    List<Object> sectionsList = new List<Object>();
                    bodyResp.put(B2B_IntegrationConstants.Sections,sectionsList);
                    jsonString = JSON.serialize(bodyResp);
                    search = B2B_INCatalogWrapper.parse(jsonString);
                }else {
                    objResponseWrapper.isError = B2B_Constant.TRUE_FLAG;
                    objResponseWrapper.errorMessage = B2B_IntegrationConstants.errormessageForMaintainenceAPIDown;
                    objResponseWrapper.errorCode = B2B_IntegrationConstants.BlankVariable;
                    //Modified by Apoorv Garg (Line 219)
                    objResponseWrapper.errorType = Label.B2B_INSystemIntegrationErrorType;
                    return JSON.serialize(objResponseWrapper);
                }
            }else{

                objResponseWrapper.isError = B2B_Constant.TRUE_FLAG;
                objResponseWrapper.errorMessage = B2B_IntegrationConstants.errormessageForMaintainenceAPIDown;
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);// to calculate duration time between before API and after API
                String severity;
                String errorType;
                //Below custom metadata provide the information related to Severity and error type based on the feature
                Map<String,B2B_Error_Handling__mdt> errorRecords = B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity = errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType = errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity = B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType = B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord = B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_INSystemIntegration',String.valueOf(response.getStatusCode()),errorType,'','maintainenceProduct',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                //HDMP-8617- End of changes
                return JSON.serialize(objResponseWrapper);
            }
        }catch(Exception ex){
            objResponseWrapper.isError = B2B_Constant.TRUE_FLAG;
            //objResponseWrapper.errorMessage = ex.getMessage() + ex.getLineNumber();
            objResponseWrapper.errorMessage = B2B_IntegrationConstants.errormessageForMaintainenceAPIDown;
            objResponseWrapper.errorCode = B2B_IntegrationConstants.BlankVariable;
            return JSON.serialize(objResponseWrapper);
        }
        return JSON.serialize(search);
    }
    // End of Soumya Changes     
    
    /*
Created By : Apoorv Garg
Date : 21/06/2021
Description : This method validate the parts for the specific VIN (VIN Fitment)
*/ 
    @AuraEnabled
    public static String ValidatePartsVIN(Integer division,String vincode,String partnumbers){
        ResponseWrapperVinDecoder objResponseWrapper = New ResponseWrapperVinDecoder();
        String jsonResponse;
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String reqBody = '{"RegionID": 1, "DivisionID":'+ division+', "LanguageID": 0, "VIN":"'+vincode+'","PartNumbers":'+partnumbers+'}';
            request = B2B_IntegrationCallout.inSystemRequest('ValidatePartsVIN', reqBody);
            Long beforeAPI = B2B_Util.fetchCurrentTime();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
               Map<String,Object> vinDecoderResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());   
                if(!vinDecoderResponse.containsKey('Header')){
                    Map<String,Object> bodyResponse = (Map<String,Object>)vinDecoderResponse.get('Body');
                    Boolean errorflag = (Boolean)bodyResponse.get('ErrorFlag');
                    if(errorflag == false){
                        jsonResponse = JSON.serialize(vinDecoderResponse.get('Body')); 
                    }else{
                        objResponseWrapper.isError = (Boolean)bodyResponse.get('ErrorFlag');
                        objResponseWrapper.errorMessage = JSON.serialize(bodyResponse.get('ErrorMessage'));
                        objResponseWrapper.errorCode = JSON.serialize(bodyResponse.get('ErrorCode'));
                        objResponseWrapper.errorType = JSON.serialize(bodyResponse.get('ErrorType'));
                        return JSON.serialize(objResponseWrapper);
                    }
                }else{
                    Map<String,Object> headerResponse = (Map<String,Object>)vinDecoderResponse.get('Header');  
                    List<Object> errorList = (List<Object>)headerResponse.get('Errors');  
                    Map<String,Object> errorResponse = (Map<String,Object>)errorList[0];
                    objResponseWrapper.isError = true;
                    objResponseWrapper.errorMessage = JSON.serialize(errorResponse.get('Message')) + JSON.serialize(errorResponse.get('AdditionalInfo'));
                    objResponseWrapper.errorCode = JSON.serialize(errorResponse.get('ErrorCode'));
                    objResponseWrapper.errorType = JSON.serialize(errorResponse.get('ErrorType'));
                    return JSON.serialize(objResponseWrapper);
                }  
            }else{
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);// to calculate duration time between before API and after API
                String severity;
                String errorType;
                //Below custom metadata provide the information related to Severity and error type based on the feature
                Map<String,B2B_Error_Handling__mdt> errorRecords = B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity = errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType = errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity = B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType = B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                Boolean createError = true;
                if(response.getBody().containsIgnoreCase('Invalid VIN') && String.valueOf(response.getStatusCode()) == '400'){
                    createError = false;
                }
                if(createError){
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord = B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_INSystemIntegration',String.valueOf(response.getStatusCode()),errorType,'','ValidatePartsVIN',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                }
                //HDMP-8617- End of changes
                objResponseWrapper.isError = true;
                objResponseWrapper.errorMessage = 'Please enter valid VIN';
                return JSON.serialize(objResponseWrapper);
            }
      }catch(Exception ex){
            objResponseWrapper.isError = true;
            objResponseWrapper.errorMessage = ex.getMessage() + ex.getLineNumber(); 
            objResponseWrapper.errorCode = '';
            return JSON.serialize(objResponseWrapper);
        }  
        return jsonResponse;
    }
    
    /*
Created By : Soumya Sahoo
Date : 04/01/2022
Description : This method validate the parts for the specific VIN (VIN Fitment)
*/ 
    @AuraEnabled
    public static String PartialSearchbyProduct(Integer division, Integer year, Integer productId, Integer doorId, Integer gradeId,Integer catalogId, Integer transmissionID,Integer sectionID,Integer illustrationGroupID,Integer illustrationGroupImageID,Integer searchCodeTypeID,Integer searchCodeContains,String searchstring){
        String searchstr = '"'+searchstring+'"';
        String reqBody;
        ResponseWrapperVinDecoder objResponseWrapper = New ResponseWrapperVinDecoder();
        B2B_INCatalogWrapper search = new B2B_INCatalogWrapper();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            reqBody = '{"RegionID": 1,"DivisionID": '+division+',"LanguageID": 0,"ProductCategoryID": 0,"ProductID": '+productId+',"DoorID": '+doorId+',"YearID": '+year+' ,"GradeID": '+gradeId+',"CatalogID": '+catalogId+',"AreaID": 0,"OriginID": 0,"TransmissionID": '+TransmissionID+',"ColorLabelID": 0,"ColorNameID": 0,"SectionID":'+sectionID+',"IllustrationGroupID":'+illustrationGroupID+',"IllustrationGroupImageID":'+illustrationGroupImageID+',"SearchCodeTypeID":'+searchCodeTypeID+',"SearchCodeContains":'+searchCodeContains+',"SearchCode":'+searchstr+'}';
            request = B2B_IntegrationCallout.inSystemRequestPartial('PartialSearchbyProduct', reqBody);
            Long beforeAPI = B2B_Util.fetchCurrentTime();
            HTTPResponse response = http.send(request);
            if(response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
                Map<String,Object> searchProductResponse = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> headers = (Map<String,Object>) searchProductResponse.get('Header'); 
                String status = (String) headers.get('Status');
                if(status == B2B_Constant.SUCCESS){
                    String  jsonString = JSON.serialize(searchProductResponse.get('Body')); 
                    Map<String,Object> bodyResp = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
                    List<Object> Sections = (List<Object>)JSON.deserializeUntyped(JSON.serialize(bodyResp.get(B2B_IntegrationConstants.Sections)));
                    List<Object> sectionsList = new List<Object>();
                    sectionsList = replaceImages(Sections); 
                    bodyResp.put(B2B_IntegrationConstants.Sections,sectionsList);
                    jsonString = JSON.serialize(bodyResp);
                    search = B2B_INCatalogWrapper.parse(jsonString); 
                }else {
                    objResponseWrapper.isError = B2B_Constant.TRUE_FLAG;
                    objResponseWrapper.errorMessage = B2B_IntegrationConstants.errormessage;
                    objResponseWrapper.errorCode = B2B_IntegrationConstants.BlankVariable;
                    objResponseWrapper.errorType = Label.B2B_INSystemIntegrationErrorType;
                    return JSON.serialize(objResponseWrapper);
                } 
            }else{
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);
                String severity;
                String errorType;
                Map<String,B2B_Error_Handling__mdt> errorRecords = B2B_IntegrationUtility.getErrorHandlingCodes_Severity(B2B_IntegrationConstants.ERROR_TYPE);
                if(errorRecords.containskey(String.valueOf(response.getStatusCode()))){
                    severity = errorRecords.get(String.valueOf(response.getStatusCode())).severity__c;
                    errorType = errorRecords.get(String.valueOf(response.getStatusCode())).error_Type__c;
                }
                else{
                    severity = B2B_IntegrationConstants.INTEGRATION_SEVERITY;
                    errorType = B2B_IntegrationConstants.INTEGRATION_ERROR_TYPE;
                }
                String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord = B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_INSystemIntegration',String.valueOf(response.getStatusCode()),errorType,'','PartialSearchbyProduct',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                //HDMP-8617- End of changes
                objResponseWrapper.isError =  B2B_Constant.TRUE_FLAG;
                objResponseWrapper.errorMessage = 'API Issue';
                return JSON.serialize(objResponseWrapper);
            }
        }catch(Exception ex){
            objResponseWrapper.isError =  B2B_Constant.TRUE_FLAG;
            objResponseWrapper.errorMessage = ex.getMessage() + ex.getLineNumber(); 
            objResponseWrapper.errorCode = B2B_IntegrationConstants.BlankVariable;  
            return JSON.serialize(objResponseWrapper);
        }
        return JSON.serialize(search);
    }
    // End of Soumya Changes 
    public Static List<Object> replaceImages(List<Object> Sections){
        List<Object> updatedSections = new List<Object>();
        for(Object section: Sections){
            Map<string,Object> sectionMap = (Map<string,Object>) section;
            Integer imageId = sectionMap.containsKey('ID')?(Integer)sectionMap.get('ID'):1;
            sectionMap.put('SectionURL', '/resource/CategoryImages/'+ImageId+'.png');
            updatedSections.add((Object)sectionMap);
        }
        return updatedSections;
    }
}
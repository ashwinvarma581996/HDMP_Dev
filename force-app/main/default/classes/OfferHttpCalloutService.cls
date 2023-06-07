//****************************************************************************** 
// File Name:       OfferHttpCalloutService.cls
// Summary:         Apex Class for Offers
// Created On:      03-13-2023
// Created By:      Manoharan Nirmalraj
// Test Classes:    OfferHttpCalloutServiceTest.cls
// Data I/O:        
// Honda Jira Story: Apex class for API of Honda Offers Experience
//===============================================================================
// Modification Log: 

//*******************************************************************************
public without sharing class OfferHttpCalloutService {
    OfferAPIConfiguration__mdt calloutMetadata;
    String endpointURL, requestMethod, requestBody;
    Map<String, String> urlParametersMap;
    Map<String, String> headerParametersMap;
    static final String TYPE_URL_PARAMETERS = 'URL_PARAMETERS';
    static final String TYPE_HEADER_PARAMETERS = 'HEADER_PARAMETERS';
    HTTPRequest request;

    //====================
    //= Getters and Setters - Begin
    //====================
	public String getEndpointURL() {
		return endpointURL;
	}

	public void setEndpointURL(String endpointURL) {
		this.endpointURL = endpointURL;
	}

    public OfferAPIConfiguration__mdt getCalloutMetadata() {
		return calloutMetadata;
	}

	public void setCalloutMetadata(OfferAPIConfiguration__mdt calloutMetadata) {
		this.calloutMetadata = calloutMetadata;
	}

	public String getRequestMethod() {
		return requestMethod;
	}

	public void setRequestMethod(String requestMethod) {
		this.requestMethod = requestMethod;
	}

	public String getRequestBody() {
		return requestBody;
	}

	public void setRequestBody(String requestBody) {
		this.requestBody = requestBody;
	}

    public String getHeaderParameter(String key) {
        return headerParametersMap.get(key);
    }

    public Map<String, String> getHeaderParameters() {
        return headerParametersMap;
    }

    public void setHeaderParameter(String key, String value) {
        if(String.isNotEmpty(key) && String.isNotEmpty(value)) {
            headerParametersMap.put(key, value);
        }
    }

    public void removeHeaderParameter(String key) {
        headerParametersMap.remove(key);
    }

    public String getURLParameter(String key) {
        return urlParametersMap.get(key);
    }

    public Map<String, String> getURLParameters() {
        return urlParametersMap;
    }

    public void setURLParameter(String key, String value) {
        if(String.isNotEmpty(key) && String.isNotEmpty(value)) {
            urlParametersMap.put(key, value);
        } else if(String.isNotEmpty(key)) {
            urlParametersMap.put(key, value);
        }
    }

    public void removeURLParameter(String key) {
        urlParametersMap.remove(key);
    }
    //====================
    //= Getters and Setters - End
    //====================

    //====================
    //= Constructor
    //====================
    public OfferHttpCalloutService() {
        initialize(null, null);
    }

    //====================
    //= Constructor with Custom Metadata
    //====================
    public OfferHttpCalloutService(String customMetadataName, OfferAPIController.Attribute attribute, List<String> endpointParameters) {
        try {
            System.debug('OfferHttpCalloutService: customMetadataName--->' + customMetadataName);
            calloutMetadata = [
                SELECT Id, MasterLabel, DeveloperName, Method__c, URLParameters__c, HeaderParameters__c, Endpoint__c,
                Body__c
                FROM OfferAPIConfiguration__mdt
                WHERE DeveloperName =:customMetadataName
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        initialize(endpointParameters, attribute);
    }

    /**
     * Added By Abhishek Salecha for HidasTokenRevoke API 
     * Encoding Request Body
     */
    private String urlEncode(Map<String, String> requestBodyMap) {
        String result = '';
        for(String bodyKey : requestBodyMap.keySet()) {
            result += EncodingUtil.urlEncode(bodyKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(requestBodyMap.get(bodyKey), 'UTF-8') + '&';
        }
        return result.removeEnd('&');    
    }     
     

    //====================
    //= Initialization of class variables
    //====================
    private void initialize(List<String> endpointParameters, OfferAPIController.Attribute attribute) {
        System.debug('@@attribute: '+attribute);
        urlParametersMap = new Map<String, String>();
        headerParametersMap = new Map<String, String>();
        if(calloutMetadata != null) {
            String epParameters = '';
            for(String endpointParameter : endpointParameters){
                epParameters += '/' + endpointParameter;
            }
            endpointURL = calloutMetadata.Endpoint__c;
            if(String.isNotBlank(epParameters)){
                endpointURL += epParameters;
            }
            requestMethod = calloutMetadata.Method__c;

            /**
             * Added By Abhishek Salecha for HidasTokenRevoke API 
             * Encoding Request Body
             */
            // if(calloutMetadata.Endpoint__c != null && calloutMetadata.Endpoint__c.containsIgnoreCase('GetCompleteDetails')){
            //     requestBody = calloutMetadata.Body__c;
            // }
            if(calloutMetadata.Endpoint__c != null && calloutMetadata.Endpoint__c.containsIgnoreCase('GetSpecificationsByModel')){
                requestBody = attribute.requestBody;
            }else if(calloutMetadata.Endpoint__c != null && calloutMetadata.Endpoint__c.containsIgnoreCase('HidasTokenRevoke') && calloutMetadata.Body__c != null){
                Map<String, String> requestBodyMap = new Map<String, String>();
                // Parse entire JSON response.
                JSONParser parser = JSON.createParser(calloutMetadata.Body__c);
                while (parser.nextToken() != null) {
                    // Start at the array of headers.
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                        while (parser.nextToken() != null) {
                            // Advance to the start object marker to
                            //  find next header statement object.
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                // Read entire header object, including its array of line items.
                                Header body = (Header)parser.readValueAs(Header.class);
                                if(String.isNotEmpty(body.key)) {
                                    if(body.key == 'access_token'){
                                        requestBodyMap.put(body.key, attribute.accessToken);
                                    }else{
                                        requestBodyMap.put(body.key, body.value);
                                    }
                                }
            
                                // Skip the child start array and start object markers.
                                parser.skipChildren();
                            }
                        }
                    }
                }
                requestBody = urlEncode(requestBodyMap);
            }else{
                requestBody = calloutMetadata.Body__c;
                if(String.isNotBlank(requestBody)){
                    if(requestBody.contains('divisionIdValue')){
                        requestBody = requestBody.replace('divisionIdValue', attribute.divisionId);
                    }
                    if(requestBody.contains('subDivisionCdValue')){
                        requestBody = requestBody.replace('subDivisionCdValue', attribute.subDivisionCd);
                    }
                    if(requestBody.contains('modelIdValue')){
                        requestBody = requestBody.replace('modelIdValue', attribute.modelId);  
                    }
                    if(requestBody.contains('carrierIdValue')){
                        requestBody = requestBody.replace('carrierIdValue', attribute.carrierId);  
                    }
                    if(requestBody.contains('manufacturerIdValue')){
                        requestBody = requestBody.replace('manufacturerIdValue', attribute.manufacturerId);  
                    }
                    if(requestBody.contains('phoneIdValue')){
                        requestBody = requestBody.replace('phoneIdValue', attribute.phoneId);  
                    }
                    if(requestBody.contains('productIdentifierValue')){
                        requestBody = requestBody.replace('productIdentifierValue', attribute.productIdentifier);  
                    }
                    if(requestBody.contains('eventValue')){
                        requestBody = requestBody.replace('eventValue', attribute.event);
                    }
                    if(requestBody.contains('vinValue')){
                        requestBody = requestBody.replace('vinValue', attribute.vin);
                    }
                    if(requestBody.contains('yearValue')){
                        requestBody = requestBody.replace('yearValue', attribute.year);
                    }
                    if(requestBody.contains('applicationIdValue')){
                        requestBody = requestBody.replace('applicationIdValue', attribute.applicationId);
                    }
                    if(requestBody.contains('echoInputValue')){
                        requestBody = requestBody.replace('echoInputValue', String.valueOf(attribute.echoInput));
                    }
                    if(requestBody.contains('serverIpValue')){
                        requestBody = requestBody.replace('serverIpValue', attribute.serverIp);
                    }
                    if(requestBody.contains('sessionIdValue')){
                        requestBody = requestBody.replace('sessionIdValue', attribute.sessionId);
                    }
                    if(requestBody.contains('domainValue')){
                        requestBody = requestBody.replace('domainValue', attribute.domain);
                    }
                    if(requestBody.contains('environmentValue')){
                        requestBody = requestBody.replace('environmentValue', attribute.environment);
                    }
                    if(requestBody.contains('checkSumValue')){
                        requestBody = requestBody.replace('checkSumValue', attribute.checkSum);
                    }
                    if(requestBody.contains('checkSumValue')){
                        requestBody = requestBody.replace('checkSumValue', attribute.checkSum);
                    }
                    if(requestBody.contains('programNameValue')){
                        requestBody = requestBody.replace('programNameValue', attribute.programName);
                    }
                    if(requestBody.contains('accessTokenValue')){
                        requestBody = requestBody.replace('accessTokenValue', attribute.accessToken);
                    }
                    if(requestBody.contains('emailValue')){
                        requestBody = requestBody.replace('emailValue', attribute.email);
                    }
                    if(requestBody.contains('appIdValue')){
                        if(attribute.divisionId == 'P'){
                            if(attribute.division == 'Marine'){
                                requestBody = requestBody.replace('appIdValue', 'marine.honda.com');
                            }else{
                                requestBody = requestBody.replace('appIdValue', 'powerequipment.honda.com');
                            }
                        }
                        
                    }
                    if(requestBody.contains('eUserIdentValue')){
                        requestBody = requestBody.replace('eUserIdentValue', attribute.federationIdentifier);
                    }
    /*                 if(requestBody.contains('licensePlateNoValue')){
                        requestBody = requestBody.replace('licensePlateNoValue', attribute.licensePlate);  
                    }
                    if(requestBody.contains('vehicleAliasValue')){
                        requestBody = requestBody.replace('vehicleAliasValue', attribute.vehicleAlias);  
                    } */
                }
            }
            System.debug('requestBody1  :-  '+requestBody);
            setUrlOrHeaderParameters(TYPE_URL_PARAMETERS, attribute, calloutMetadata.URLParameters__c);
            setUrlOrHeaderParameters(TYPE_HEADER_PARAMETERS, attribute, calloutMetadata.HeaderParameters__c);
        }
    }

    public class Header {
        public String key;
        public String value;
        public String type;
        
        public Header(String key, String value, String type) {
            this.key = key;
            this.value = value;
            this.type = type;
        }
    }

    public class Attribute {
        @AuraEnabled
        public string divisionId {get;set;}
        @AuraEnabled
        public String modelId {get;set;}
        @AuraEnabled
        public String carrierId {get;set;}
        @AuraEnabled
        public String manufacturerId {get;set;}
        @AuraEnabled
        public String phoneId {get;set;}
    }

    //====================
    //= This method is used to set URL or Header parameters from Custom Metadata
    //====================O
    private void setUrlOrHeaderParameters(String parameterType, OfferAPIController.Attribute attribute, String parameterInfo) {
        /*if(String.isNotEmpty(parameterInfo)) {
            Map<String, String> parametersMap = new Map<String, String>();
            List<String> parameters = parameterInfo.split('\n');
            for(String urlParam : parameters) {
                List<String> keyValuePair = urlParam.trim().split(':');
                if(!keyValuePair.isEmpty()) {
                    if(keyValuePair.size() == 2) {
                        if(String.isNotEmpty(keyValuePair[0]) && String.isNotEmpty(keyValuePair[1])) {
                            parametersMap.put(keyValuePair[0], keyValuePair[1]);
                        }
                    } else if(
                        (keyValuePair.size() == 1) &&
                        (parameterType != TYPE_HEADER_PARAMETERS)
                    ) {
                        if(String.isNotEmpty(keyValuePair[0])) {
                            parametersMap.put(keyValuePair[0], '');
                        }
                    }
                }
            }
            if(parameterType == TYPE_URL_PARAMETERS) {
                urlParametersMap.putAll(parametersMap);
            } else if(parameterType == TYPE_HEADER_PARAMETERS) {
                headerParametersMap.putAll(parametersMap);
            }
        }*/
        if(String.isNotEmpty(parameterInfo)) {
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.CurrentOffers');
            String accessToken = (String)orgPart.get('JWTAccessToken');
            String eUserIdent = '';
            String ciamToken = '';
            if(UserInfo.getUserType() != 'Guest'){
                User u = [SELECT FederationIdentifier, CIAMToken__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
                if(u != null){
                    eUserIdent = u.FederationIdentifier;
                    ciamToken = u.CIAMToken__c;
                }
            }
            Map<String, String> parametersMap = new Map<String, String>();
            // Parse entire JSON response.
            JSONParser parser = JSON.createParser(parameterInfo);
            while (parser.nextToken() != null) {
                // Start at the array of headers.
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        // Advance to the start object marker to
                        //  find next header statement object.
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            // Read entire header object, including its array of line items.
                            Header hed = (Header)parser.readValueAs(Header.class);
                            if(String.isNotEmpty(hed.key)) {
                                if(attribute.divisionId == 'A'){
                                    if(hed.key == 'hondaHeaderType.businessId'){
                                        parametersMap.put(hed.key, 'HONDALINK CONNECT');
                                    }else if(hed.key == 'hondaHeaderType.systemId'){
                                        if(calloutMetadata.Endpoint__c.containsIgnoreCase('EligibleVehicle')){
                                            parametersMap.put(hed.key,hed.value);
                                        }
                                        else{
                                            parametersMap.put(hed.key, 'com.honda.hondalink.cv_web');
                                        }
                                        
                                    }else if(hed.key == 'appid'){ //If this header value will be changed in release for all APIs, this condition should be removed.
                                        parametersMap.put(hed.key, hed.value);
                                    }
                                    else if(hed.key == 'ClientDomain' ){ //If this header value will be changed in release for all APIs, this condition should be removed.
                                        parametersMap.put(hed.key, hed.value);
                                    }
                                    else if(hed.key == 'eUserIdent'){
                                        parametersMap.put(hed.key, eUserIdent);
                                    }else if(hed.key == 'modelid' &&  hed.value.Contains('en,US')){
                                        parametersMap.put(hed.key, hed.value.replace('modelid',attribute.modelId)); 
                                    }else if(hed.key == 'vin' &&  hed.value.Contains('en,US')){
                                        parametersMap.put(hed.key, hed.value.replace('vinValue',attribute.vin)); 
                                    }else if(hed.key == 'ProductDivisionCD'){
                                        parametersMap.put(hed.key, hed.value.replace('productDivisionCDValue',attribute.productDivisionCD)); 
                                    }else{
                                        parametersMap.put(hed.key, hed.value);
                                    }
                                }else if(attribute.divisionId == 'B'){
                                    if(hed.key == 'hondaHeaderType.businessId' && attribute.divisionId == 'B'){
                                        parametersMap.put(hed.key, 'ACURALINK CONNECT');
                                    }else if(hed.key == 'hondaHeaderType.systemId' && attribute.divisionId == 'B'){
                                        if(calloutMetadata.Endpoint__c.containsIgnoreCase('EligibleVehicle')){
                                            parametersMap.put(hed.key,hed.value);
                                        }
                                        else{
                                            parametersMap.put(hed.key, 'com.acura.acuralink.cv_web');
                                        }
                                    }else if(hed.key == 'appid'){
                                        parametersMap.put(hed.key, hed.value);
                                    }else if(hed.key == 'ClientDomain'){
                                        parametersMap.put(hed.key, hed.value);
                                    }else if(hed.key == 'eUserIdent'){
                                        parametersMap.put(hed.key, eUserIdent);
                                    }else if(hed.key == 'modelid' &&  hed.value.Contains('en,US')){
                                        parametersMap.put(hed.key, hed.value.replace('modelid',attribute.modelId)); 
                                    }else if(hed.key == 'vin' &&  hed.value.Contains('en,US')){
                                        parametersMap.put(hed.key, hed.value.replace('vinValue',attribute.vin)); 
                                    }else {
                                        parametersMap.put(hed.key, hed.value);
                                    }
                                }else if(attribute.divisionId == 'M'){
                                    if(hed.key == 'hondaHeaderType.businessId'){
                                        parametersMap.put(hed.key, 'HONDALINK CONNECT');
                                    }else if(hed.key == 'hondaHeaderType.systemId'){
                                        if(calloutMetadata.Endpoint__c.containsIgnoreCase('EligibleVehicle')){
                                            parametersMap.put(hed.key,hed.value);
                                        }
                                        else{
                                            parametersMap.put(hed.key, 'com.honda.hondalink.cv_web');
                                        }
                                        
                                    }else if(hed.key == 'appid'){
                                        parametersMap.put(hed.key, hed.value);
                                    }else if(hed.key == 'ClientDomain'){
                                        parametersMap.put(hed.key, hed.value);
                                    }else if(hed.key == 'eUserIdent'){
                                        parametersMap.put(hed.key, eUserIdent);
                                    }else {
                                        parametersMap.put(hed.key, hed.value);
                                    }
                                }
                                if(attribute.divisionId == 'P'){
                                    if(hed.value.contains('Bearer')){
                                        parametersMap.put(hed.key, accessToken);
                                    }else{
                                        parametersMap.put(hed.key, hed.value);
                                    }
        
                                }
                                if(hed.key == 'hondaHeaderType.token'){
                                    parametersMap.put(hed.key, ciamToken);
                                }
                                
                                if((calloutMetadata.Endpoint__c != null && (calloutMetadata.Endpoint__c.containsIgnoreCase('MyVehicles') || calloutMetadata.Endpoint__c.containsIgnoreCase('MyProfile') || calloutMetadata.Endpoint__c.containsIgnoreCase('ManageSubscriptions'))) && hed.key == 'Authorization' && hed.value != null && hed.value.contains('Bearer') && accessToken != null){
                                    parametersMap.put(hed.key, accessToken);
                                }

                                // For Dealer Locator
                                if(hed.key == 'ZipCode'){
                                    parametersMap.put(hed.key, attribute.zipCode);
                                }
                                if(hed.key == 'city'){
                                    parametersMap.put(hed.key, attribute.city);
                                }
                                if(hed.key == 'State'){
                                    parametersMap.put(hed.key, attribute.state);
                                }
                                if(hed.key == 'POIType'){
                                    parametersMap.put(hed.key, attribute.poiType);
                                }
                                if(hed.key == 'SearchRadius'){
                                    parametersMap.put(hed.key, attribute.searchRadius);
                                }
                                if(hed.key == 'POIId'){
                                    parametersMap.put(hed.key, attribute.pOIId);
                                }
                                if(hed.key == 'Filters'){
                                    parametersMap.put(hed.key, attribute.filters);
                                }
                                if(hed.key == 'Latitude' && String.isNotBlank(attribute.latitude)){
                                    parametersMap.put(hed.key, attribute.latitude);
                                }
                                if(hed.key == 'Longitude' && String.isNotBlank(attribute.longitude)){
                                    parametersMap.put(hed.key, attribute.longitude);
                                }
                                if(hed.key == 'POIName'){
                                    parametersMap.put(hed.key, attribute.poiName);
                                }
                                if(hed.key == 'ReferenceCoordinates' && String.isNotBlank(attribute.referenceCoordinates)){
                                    parametersMap.put(hed.key, attribute.referenceCoordinates);
                                }
                                // For Dealer Locator Ends

                                // For recalls API
                                if (hed.key == 'vin' && hed.value == 'vinValue' && parameterType == TYPE_URL_PARAMETERS && calloutMetadata.Endpoint__c != null && calloutMetadata.Endpoint__c.containsIgnoreCase('RecallData')){
                                    System.debug('Setting VIN URL param');
                                    parametersMap.put(hed.key, attribute.productIdentifier);
                                }

                                //added for GetCompleteDetails(HowToGuides) API
                                if(calloutMetadata.Endpoint__c != null && calloutMetadata.Endpoint__c.containsIgnoreCase('GetCompleteDetails')){
                                    if(hed.key == 'appid'){
                                        parametersMap.put(hed.key, hed.value);
                                    }
                                    else if(hed.key == 'ClientDomain'){
                                        parametersMap.put(hed.key, hed.value);
                                    }
                                }
                            }
        
                            // Skip the child start array and start object markers.
                            parser.skipChildren();
                        }
                    }
                }
            }
            if(parameterType == TYPE_URL_PARAMETERS) {
                urlParametersMap.putAll(parametersMap);
            } else if(parameterType == TYPE_HEADER_PARAMETERS) {
                headerParametersMap.putAll(parametersMap);
            }
            System.debug('urlParametersMap  :-  '+urlParametersMap);
            System.debug('headerParametersMap  :-  '+headerParametersMap);
        }
        System.debug('@@headerParametersMap: '+headerParametersMap);
    }

    //====================
    //= This method is used to append the URL parameters at the end of URL
    //====================
    private void appendURLParameters() {
        Set<String> urlParamKeys = urlParametersMap.keySet();
        if(!urlParamKeys.isEmpty()) {
            endpointURL += '?';
            for(String urlParamKey : urlParamKeys) {
                endpointURL += urlParamKey + '=' + urlParametersMap.get(urlParamKey) + '&';
            }
            endpointURL = endpointURL.substringBeforeLast('&');
        }
    }

    //====================
    //= This method is used to set Header parameters using headerParametersMap
    //====================
    private void addHeaderParameters() {
        System.debug('--headerParametersMap--');
        for(string ky : headerParametersMap.keySet()){
            System.debug('ky** '+ky);
        }
        for(string vall : headerParametersMap.values()){
            System.debug('vall** '+vall);
        }
        for(String key : headerParametersMap.keySet()) {
            if(headerParametersMap.get(key)!=null){
                request.setHeader(key, headerParametersMap.get(key));
            }
            
        }
    }

    //====================
    //= This method is used to form HTTP Request
    //====================
    public void formHTTPRequest() {
        request = new HTTPRequest();
        addHeaderParameters();
        if(String.isNotEmpty(endpointURL)) {
            endpointURL = endpointURL.substringBefore('?');
            appendURLParameters();
            request.setEndpoint(endpointURL);
        }
        if(String.isNotEmpty(requestMethod)) {
            request.setMethod(requestMethod);
        }
        request.setTimeout(20000);
        if(String.isNotEmpty(requestBody)) {
            request.setBody(requestBody);
        } 
    }

    //====================
    //= This method forms and returns the HTTP Request without sending (for debugging purposes)
    //====================
    public HTTPRequest getRequest() {
        formHTTPRequest();
        return request;
    }

    //====================
    //= This method is used to send HTTP Request and return the response
    //====================
    public HTTPResponse sendRequest() {
        formHTTPRequest();
        System.debug('request1  :-  '+request);
      
        Http http = new Http();
        return http.send(request);
    }

    //====================
    //= This method is used to send HTTP Request received in parameter and return the response
    //====================
    public HTTPResponse sendRequest(HTTPRequest request) {
        Http http = new Http();
        return http.send(request);
    }

    //====================
    //= This method is used to get the GUID
    //====================
    public static string getGUID(){
        try {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            return guid;
        } catch (Exception e) {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }

}
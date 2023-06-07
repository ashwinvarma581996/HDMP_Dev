/*******************************************************************************
Name: B2B_VertexTaxCalculationIntegration
Business Unit: HDM
Date: 28/04/2021
Developer: Radhey Shyam Gupta
Description: This class is to provide Tax from Vertex API.
Test ClassName- B2B_TaxHelperV2Test, B2B_VertexTaxCalculationCalloutMock(Mock Class)
*******************************************************************************
MODIFICATIONS – Date | Dev Name 	| Method | User Story
		  22/05/2022 | Soumya Sahoo |  Error handling changes- JIRA- 8617
          03/07/2023 | Saravanan  | 16535 - added terenay assignment for Reman parts and Core chare
*******************************************************************************/

public class B2B_VertexTaxCalculationIntegration{
    
    @AuraEnabled
    public static ResponseDataWrapper calculateTaxQuotation(String cartId,Map<String,String> dealerAddressMap, Map<String,String> customerAddressMap,String dealerCode,String shippingCharge,String InstallationCharges,String methodName,String cartType){
        ResponseDataWrapper responseWrapper =  New ResponseDataWrapper();
        List<CartItem> lstCartItem = New List<CartItem>();
        try{
            if(dealerAddressMap.size() != 4 && customerAddressMap.size() != 4 && cartType!=B2B_IntegrationConstants.TYPE_VALUE){
                responseWrapper.errorMessage = B2B_IntegrationConstants.ERROR_CORRECT_ADDRESS;
                responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG; 
                return responseWrapper;
            }else{
                Map<Integer,String> mapLineItem = New Map<Integer,String>();
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String guId = B2B_Util.createGui(); //Added by Apoorv Garg
                request.setHeader('Content-Type', 'text/xml');
                request.setMethod('POST');
                String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://www.honda.com/global/1.0/header/" xmlns:urn="urn:vertexinc:o-series:tps:9:0">';
                body += '<soapenv:Header>';
                body += '<head:hondaHeaderType>';
                body += '<head:messageId>'+guId+'</head:messageId>';
                body += '<head:siteId>'+ Label.B2B_Fedex_SiteId +'</head:siteId>';
                body += '<head:businessId>'+Label.B2B_Fedex_BusinessId+'</head:businessId>';
                body += '<head:collectedTimestamp>'+datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'America/Los_Angeles')+'</head:collectedTimestamp>';
                body += '</head:hondaHeaderType>';
                body += '</soapenv:Header>';
                body += '<soapenv:Body> <urn:VertexEnvelope>';
                body += '<urn:Login><urn:UserName>'+Label.B2B_VertexUserName + '</urn:UserName><urn:Password>'+Label.B2B_VertexPassword+'</urn:Password></urn:Login>' ;
                String todayDate = String.valueOf(Date.Today());
                if(methodName == 'quotation'){
                    body += '<urn:QuotationRequest documentDate="'+ todayDate +'" documentNumber="'+ cartId + '" postingDate="'+ todayDate + '" transactionType="SALE">';
                }else if(methodName == 'commit'){
                    body += '<urn:InvoiceRequest documentDate="'+ todayDate +'" documentNumber="'+ cartId + '" postingDate="'+ todayDate + '" transactionType="SALE">';
                }else if(methodName == 'return'){
                    body += '<urn:InvoiceRequest documentDate="'+ todayDate +'" documentNumber="'+ cartId + '" postingDate="'+ todayDate + '" transactionType="SALE">';
                }
                body += '<urn:Seller> <urn:Company>'+'AHM Group'+'</urn:Company>';
                body += '<urn:Division>'+dealerCode+'</urn:Division> </urn:Seller>';
                Integer i = B2B_IntegrationConstants.DEFAULT_VALUE;
                for(CartItem objCartItem : B2B_IntegrationUtility.gettaxcartitems(cartId)){
                    i = i+1;
                    mapLineItem.put(i,objCartItem.Id);
                    body += '<urn:LineItem lineItemNumber="'+i+'" vendorSKU="'+objCartItem.Product2.StockKeepingUnit+'">';
                    body += '<urn:Seller> <urn:AdministrativeOrigin>';
                    if(cartType!=B2B_IntegrationConstants.TYPE_VALUE){
                        body +=  '<urn:StreetAddress1>'+dealerAddressMap.get(B2B_IntegrationConstants.STREETADDRESS) + '</urn:StreetAddress1>';
                        body += '<urn:City>'+dealerAddressMap.get(B2B_IntegrationConstants.CITY)+'</urn:City>';
                        body += '<urn:MainDivision>'+dealerAddressMap.get(B2B_IntegrationConstants.STATE)+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+dealerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>'; 
                    }else{
                        body += '<urn:PostalCode>'+dealerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>';
                    }
                    body += ' </urn:AdministrativeOrigin> </urn:Seller>';
                    body += '<urn:Customer> <urn:Destination>';
                    if(cartType!=B2B_IntegrationConstants.TYPE_VALUE){
                        body += '<urn:StreetAddress1>'+customerAddressMap.get(B2B_IntegrationConstants.STREETADDRESS);
                        body += '</urn:StreetAddress1><urn:City>'+customerAddressMap.get(B2B_IntegrationConstants.CITY)+'</urn:City>';
                        body += '<urn:MainDivision>'+customerAddressMap.get(B2B_IntegrationConstants.STATE)+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+customerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>';   
                    }else{
                        body += '<urn:PostalCode>'+customerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>';   
                    }
                    body += '</urn:Destination></urn:Customer>';
                    //body += '<urn:Product>'+Label.B2B_Product_Code+'</urn:Product>';
                    if(objCartItem.Product_Type__c == 'Motocompacto'){
                        body += '<urn:Product>'+Label.motocompacto_code+'</urn:Product>';
                    }else{
                        // Saravanan LTIM HDMP-16535
                        body += objCartItem.Product_type__c == 'Core Charge' ?  '<urn:Product>'+Label.B2B_Product_Code_Core_Charges+'</urn:Product> ' 
                        :  objCartItem.Product2.Core_Charge_Unit_Price__c  > 0 ? '<urn:Product>'+Label.B2B_Product_Code_Reman+'</urn:Product> '  
                            : '<urn:Product>'+Label.B2B_Product_Code+'</urn:Product>';
                    }               
                    body += '<urn:Quantity unitOfMeasure="EA">'+objCartItem.Quantity+'</urn:Quantity>';
                    body += '<urn:UnitPrice>'+objCartItem.UnitAdjustedPrice+'</urn:UnitPrice>';
                    if(methodName == 'return'){
                        body += '<urn:ExtendedPrice>'+ -objCartItem.TotalAmount +'</urn:ExtendedPrice>';
                    }else{
                        body += '<urn:ExtendedPrice>'+ objCartItem.TotalAmount +'</urn:ExtendedPrice>';
                    }
                    body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                }
                if(String.isNotBlank(shippingCharge)){
                    i = i+1;
                    mapLineItem.put(i,Label.B2B_Shipping_Code);
                    body += '<urn:LineItem lineItemNumber="'+i+'">';
                    body += '<urn:Seller> <urn:AdministrativeOrigin>';
                    if(cartType!=B2B_IntegrationConstants.TYPE_VALUE){
                        body += '<urn:StreetAddress1>'+dealerAddressMap.get(B2B_IntegrationConstants.STREETADDRESS)+ '</urn:StreetAddress1>';
                        body += '<urn:City>'+dealerAddressMap.get(B2B_IntegrationConstants.CITY)+'</urn:City>';
                        body += '<urn:MainDivision>'+dealerAddressMap.get(B2B_IntegrationConstants.STATE)+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+dealerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>';
                        body += ' </urn:AdministrativeOrigin></urn:Seller>';
                        body += '<urn:Customer> <urn:Destination>';
                        body += '<urn:StreetAddress1>'+customerAddressMap.get(B2B_IntegrationConstants.STREETADDRESS)+'</urn:StreetAddress1>';
                        body += '<urn:City>'+customerAddressMap.get(B2B_IntegrationConstants.CITY)+'</urn:City>';
                        body += '<urn:MainDivision>'+customerAddressMap.get(B2B_IntegrationConstants.STATE)+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+customerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>'; 
                    }else{
                        body += '<urn:PostalCode>'+dealerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>';
                        body += ' </urn:AdministrativeOrigin></urn:Seller>';
                        body += '<urn:Customer> <urn:Destination>';
                        body += '<urn:PostalCode>'+customerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>';
                    }
                    body += '</urn:Destination></urn:Customer>';
                    body += '<urn:Product>'+Label.B2B_Shipping_Code+'</urn:Product>';
                    body += '<urn:ExtendedPrice>'+shippingCharge+'</urn:ExtendedPrice>';
                    body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                }
                //starts here 
                if(String.isNotBlank(InstallationCharges)){
                    i = i+1;
                    mapLineItem.put(i,Label.B2B_Installation_Code);
                    body += '<urn:LineItem lineItemNumber="'+i+'">';
                    body += '<urn:Seller> <urn:AdministrativeOrigin>';
                    if(cartType!=B2B_IntegrationConstants.TYPE_VALUE){
                        body += '<urn:StreetAddress1>'+dealerAddressMap.get(B2B_IntegrationConstants.STREETADDRESS) + '</urn:StreetAddress1>';
                        body += '<urn:City>'+dealerAddressMap.get(B2B_IntegrationConstants.CITY)+'</urn:City>';
                        body += '<urn:MainDivision>'+dealerAddressMap.get(B2B_IntegrationConstants.STATE)+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+dealerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>';
                        body += ' </urn:AdministrativeOrigin></urn:Seller>';
                        body += '<urn:Customer> <urn:Destination>';
                        body += '<urn:StreetAddress1>'+customerAddressMap.get(B2B_IntegrationConstants.STREETADDRESS)+'</urn:StreetAddress1>';
                        body += '<urn:City>'+customerAddressMap.get(B2B_IntegrationConstants.CITY)+'</urn:City>';
                        body += '<urn:MainDivision>'+customerAddressMap.get(B2B_IntegrationConstants.STATE)+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+customerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>'; 
                    }else{
                        body += '<urn:PostalCode>'+dealerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>';
                        body += ' </urn:AdministrativeOrigin></urn:Seller>';
                        body += '<urn:Customer> <urn:Destination>';
                        body += '<urn:PostalCode>'+customerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>';
                    }
                    body += '</urn:Destination></urn:Customer>';
                    body += '<urn:Product>'+Label.B2B_Installation_Code+'</urn:Product>';
                    body += '<urn:ExtendedPrice>'+InstallationCharges+'</urn:ExtendedPrice>';
                    body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                }
                // Ends here --- Soumya Sahoo-- R2 Story
                if(methodName == B2B_IntegrationConstants.QUOTATION){
                    body += '</urn:QuotationRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
                }else if(methodName == 'commit'){
                    body += '</urn:InvoiceRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
                }else if(methodName == 'return'){
                    body += '</urn:InvoiceRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
                }
                request.setBody(body);  
                request.setEndpoint('callout:VertexNamedCredential'+ Label.B2B_Vertex_Path_URL);
                Long beforeAPI = B2B_Util.fetchCurrentTime();
                system.debug('requestbodysoumya'+request.getBody());
                HTTPResponse response = http.send(request);
                system.debug('responsebodysoumya'+response.getBody());
                if(response.getStatusCode()==B2B_IntegrationConstants.STATUSCODE){
                    DOM.Document doc = response.getBodyDocument();
                    Dom.XMLNode rootElement = doc.getRootElement();
                    String totalTaxAmount ='';
                    String errorDescription = '';
                    responseWrapper.responseCode = String.valueOf(response.getStatusCode());
                    for(Dom.XMLNode childElement : rootElement.getChildElements()){ 
                        if(childElement.getName() == 'Body'){
                            if(childElement.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/') != null){
                                Dom.XMLNode faultNode =  childElement.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                                if(faultNode.getChildElement('faultstring',null) != null){
                                    errorDescription = faultNode.getChildElement('faultstring',null).getText();
                                    responseWrapper.isSuccess = false;
                                    //commented and updated by saikiran as part of HDMP-16551
                                   // responseWrapper.errorMessage = errorDescription;
                                    responseWrapper.errorMessage = Label.Error_Message_for_Invalid_ZipCodes;
                                    responseWrapper.totalTaxAmount = '';
                                }
                            }else if(childElement.getChildElement('VertexEnvelope',B2B_IntegrationConstants.TAX_XML_URL) != null){
                                Dom.XMLNode vertexEnvelopeNode = childElement.getChildElement('VertexEnvelope',B2B_IntegrationConstants.TAX_XML_URL);
                                Dom.XMLNode quotationResponse;
                                if(methodName == B2B_IntegrationConstants.QUOTATION){
                                    if(vertexEnvelopeNode.getChildElement('QuotationResponse',B2B_IntegrationConstants.TAX_XML_URL) != null){
                                        quotationResponse =  vertexEnvelopeNode.getChildElement('QuotationResponse',B2B_IntegrationConstants.TAX_XML_URL);
                                    }
                                }else{
                                    if(vertexEnvelopeNode.getChildElement('InvoiceResponse',B2B_IntegrationConstants.TAX_XML_URL) != null){
                                        quotationResponse =  vertexEnvelopeNode.getChildElement('InvoiceResponse',B2B_IntegrationConstants.TAX_XML_URL);
                                    }
                                }
                                if(quotationResponse != null){
                                    for(Dom.XMLNode quotationResponseChild : quotationResponse.getChildElements()){
                                        if(quotationResponseChild.getName() == 'TotalTax'){
                                            totalTaxAmount = quotationResponseChild.getText();
                                            responseWrapper.isSuccess = true;
                                            responseWrapper.errorMessage = '';
                                            responseWrapper.totalTaxAmount = totalTaxAmount;
                                        }
                                        if(quotationResponseChild.getName() == 'LineItem'){
                                            B2B_VertexTaxCalculationIntegration.taxDetailForLineItem objInner = New B2B_VertexTaxCalculationIntegration.taxDetailForLineItem();
                                            String cartItemId = mapLineItem.get(Integer.valueOf(quotationResponseChild.getAttributeValue('lineItemNumber',null)));
                                            objInner.itemId = cartItemId;
                                            CartItem objCartItem;
                                            if(cartItemId != Label.B2B_Shipping_Code  && (cartItemId != Label.B2B_Installation_Code)){
                                                objCartItem = New CartItem();
                                                objCartItem.Id = objInner.itemId;
                                            }
                                            for(Dom.XMLNode lineItemsNodes : quotationResponseChild.getChildElements()){
                                                //Condition && lineItemsNodes.getText() != null added by ashwin as part of HDMP-18867
                                                if(lineItemsNodes.getName() == 'TotalTax' && lineItemsNodes.getText() != null){
                                                    objInner.totalItemTax = lineItemsNodes.getText();
                                                    if(cartItemId != Label.B2B_Shipping_Code && (cartItemId != Label.B2B_Installation_Code)){
                                                        objCartItem.B2B_Item_Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());
                                                    }
                                                    if(cartItemId == Label.B2B_Shipping_Code){
                                                        responseWrapper.shippingTaxAmount=Decimal.valueOf(lineItemsNodes.getText());
                                                    }
                                                    if(cartItemId == Label.B2B_Installation_Code){
                                                        responseWrapper.installationTaxAmount=Decimal.valueOf(lineItemsNodes.getText());
                                                    }
                                                    
                                                }
                                                if(lineItemsNodes.getName() == 'Taxes'){
                                                    Dom.XMLNode JuridictionResponse =  lineItemsNodes.getChildElement('Jurisdiction',B2B_IntegrationConstants.TAX_XML_URL);
                                                    String jdLevel = JuridictionResponse.getAttributeValue('jurisdictionLevel',null);
                                                    String tax =  lineItemsNodes.getChildElement('CalculatedTax',B2B_IntegrationConstants.TAX_XML_URL).getText();
                                                    String taxRate =  lineItemsNodes.getChildElement('EffectiveRate',B2B_IntegrationConstants.TAX_XML_URL).getText();
                                                    if(jdLevel == 'STATE'){
                                                        objInner.stateTax = tax;
                                                        objInner.stateTaxRate = taxRate; 
                                                        if(cartItemId != Label.B2B_Shipping_Code  && (cartItemId != Label.B2B_Installation_Code)){
                                                            objCartItem.B2B_StateTax__c = Decimal.valueOf(tax);
                                                            objCartItem.B2B_StateTax_Rate__c = Decimal.valueOf(taxRate);
                                                        }
                                                    }else if(jdLevel == 'CITY'){
                                                        objInner.cityTax = tax;
                                                        objInner.cityTaxRate = taxRate;
                                                        if(cartItemId != Label.B2B_Shipping_Code && (cartItemId != Label.B2B_Installation_Code)){
                                                            objCartItem.B2B_CityTax__c = Decimal.valueOf(tax);
                                                            objCartItem.B2B_CityTax_Rate__c = Decimal.valueOf(taxRate);
                                                        } 
                                                    }else if(jdLevel == 'TRANSIT_DISTRICT'){
                                                        objInner.transitDistrictTax = tax;
                                                        objInner.transitDistrictTaxRate = taxRate; 
                                                        if(cartItemId != Label.B2B_Shipping_Code && (cartItemId != Label.B2B_Installation_Code)){
                                                            objCartItem.B2B_TransitDistrictTax__c = Decimal.valueOf(tax);
                                                            objCartItem.B2B_TransitDistrictTax_Rate__c = Decimal.valueOf(taxRate);
                                                        }
                                                    }
                                                }
                                            }
                                            responseWrapper.lineItemsDetails.add(objInner);
                                            if(objCartItem != null){
                                                lstCartItem.add(objCartItem);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else{
                    responseWrapper.errorMessage=B2B_IntegrationConstants.VERTEX_API_DOWN_MESSAGE;
                    responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
            		//HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                    Long afterAPI = B2B_Util.fetchCurrentTime();
                    Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);
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
                    Webcart cart=B2B_IntegrationUtility.getcartdetails(cartId);
                    String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(cart.ownerId);
                    Error__c errorRecord=B2B_Util.createErrorRecord(true,'','',cart.DealerId__c,personAccountId,cartId,'B2B_VertexTaxCalculationIntegration',String.valueOf(response.getStatusCode()),errorType,'','calculateTaxQuotation',true,'',cartId,'',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                    //HDMP-8617- End of changes
                }
                if(!lstCartItem.isEmpty()){
                    update lstCartItem;
                }
            }
        }catch(Exception Ex){
            responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
            responseWrapper.errorMessage = ex.getMessage()+B2B_IntegrationConstants.LINENUMBER+ex.getLineNumber();
        }
        System.debug(' responseWrapper** '+responseWrapper);
        return responseWrapper;
    }
    
    @AuraEnabled
    public static string vertexAddressCleansing(Map<String,String> addressMap){
        Map<String,String> cleansedAddressMap = New Map<String,String>();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('Content-Type', 'text/xml');
            request.setMethod('POST');
            String guId = B2B_Util.createGui();
            String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://www.honda.com/global/1.0/header/" xmlns:urn="urn:vertexinc:o-series:tps:9:0">';
            body += '<soapenv:Header>';
            body += '<head:hondaHeaderType>';
            body += '<head:messageId>'+guId+'</head:messageId>';            
            body += '<head:siteId>'+ Label.B2B_Fedex_SiteId +'</head:siteId>';
            body += '<head:businessId>'+Label.B2B_Fedex_BusinessId+'</head:businessId>';
            body += '<head:collectedTimestamp>'+datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'America/Los_Angeles')+'</head:collectedTimestamp>';
            body += '</head:hondaHeaderType>';
            body += '</soapenv:Header>';
            body += '<soapenv:Body> <urn:VertexEnvelope> <urn:Login>';      
            body += '<urn:UserName>'+Label.B2B_VertexUserName + '</urn:UserName>';
            body += '<urn:Password>'+Label.B2B_VertexPassword+'</urn:Password>';
            body += '</urn:Login>';
            body += '<urn:TaxAreaRequest> <urn:TaxAreaLookup asOfDate="2021-05-26" lookupId="1">'; //<urn:TaxAreaID></urn:TaxAreaID>
            body += '<urn:PostalAddress> ';
            if(addressMap.containsKey('streetAddress1') && String.isNotEmpty(addressMap.get('streetAddress1'))){
                body += '<urn:StreetAddress1>'+ addressMap.get('streetAddress1') + '</urn:StreetAddress1>';
            }
            if(addressMap.containsKey('streetAddress2') && String.isNotEmpty(addressMap.get('streetAddress2'))){
                body += '<urn:StreetAddress2>'+ addressMap.get('streetAddress2') + '</urn:StreetAddress2>';
            }
            if(addressMap.containsKey('city') && String.isNotEmpty(addressMap.get('city'))){
                body += '<urn:City>'+ addressMap.get('city') + '</urn:City>';
            }
            if(addressMap.containsKey('mainDivision') && String.isNotEmpty(addressMap.get('mainDivision'))){
                body += '<urn:MainDivision>'+ addressMap.get('mainDivision') + '</urn:MainDivision>';
            }
            
            if(addressMap.containsKey('postalCode') && String.isNotEmpty(addressMap.get('postalCode'))){
                body += '<urn:PostalCode>'+ addressMap.get('postalCode') + '</urn:PostalCode>';
            }
            if(addressMap.containsKey('country') && String.isNotEmpty(addressMap.get('country'))){
                body += '<urn:Country>'+ addressMap.get('country') + '</urn:Country>';
            }
            
            body += '</urn:PostalAddress> </urn:TaxAreaLookup> </urn:TaxAreaRequest> </urn:VertexEnvelope> </soapenv:Body> </soapenv:Envelope> ';
            request.setBody(body);              
            request.setEndpoint('callout:Vertex_Address_Cleansing_Named_Credential' + Label.B2B_Vertex_Address_Cleansing_URL);
            Long beforeAPI = DateTime.now().getTime();
            HttpResponse response = http.send(request);
            if(response.getStatusCode()==B2B_IntegrationConstants.STATUSCODE){
                cleansedAddressMap.put('responseCode',String.valueOf(response.getStatusCode()));
                String xmlString = response.getBody();
                
                // Removing/handling CDATA in response if found
                xmlString = xmlString.replaceAll( '<!\\[CDATA\\[', 'XML_CDATA_START' ).replaceAll( ']]>', 'XML_CDATA_END' );
                Map<String, String> replacementMap = new Map<String, String>();
                Pattern myPattern = Pattern.compile( '(XML_CDATA_START)(.*?)(XML_CDATA_END)' );
                Matcher myMatcher = myPattern.matcher( xmlString );
                while ( myMatcher.find() ) {
                    replacementMap.put( myMatcher.group(), myMatcher.group(2).escapeXML() );
                }
                for ( String key : replacementMap.keySet() ) {
                    xmlString = xmlString.replace( key, replacementMap.get( key ) );
                }
                // CDATA Handling closed
                
                Dom.Document doc = new Dom.Document();
                doc.load( xmlString );
                Dom.XMLNode rootElement = doc.getRootElement();
                Dom.XMLNode bodyElement = rootElement.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
                
                if(bodyElement.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/') != null){
                    Dom.XMLNode faultNode =  bodyElement.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                    if(faultNode.getChildElement('faultstring',null) != null){
                        String errorDescription = faultNode.getChildElement('faultstring',null).getText();
                        cleansedAddressMap.put('isError','true');
                        cleansedAddressMap.put('errorMessage',errorDescription);
                    }
                }else{
                    Dom.XMLNode vertexEnvelopNode =  bodyElement.getChildElement('VertexEnvelope','urn:vertexinc:o-series:tps:9:0');
                    Dom.XMLNode taxAreaResNode =  vertexEnvelopNode.getChildElement('TaxAreaResponse','urn:vertexinc:o-series:tps:9:0');
                    Dom.XMLNode taxAreaResultNode =  taxAreaResNode.getChildElement('TaxAreaResult','urn:vertexinc:o-series:tps:9:0');
                    Dom.XMLNode postalAddressNode =  taxAreaResultNode.getChildElement('PostalAddress','urn:vertexinc:o-series:tps:9:0');
                    cleansedAddressMap.put('isError','false');
                    
                    if(postalAddressNode == null){
                        cleansedAddressMap.put('isError','true');
                        Dom.XMLNode addressCleansingMessage =  taxAreaResultNode.getChildElement('AddressCleansingResultMessage','urn:vertexinc:o-series:tps:9:0');
                        if(addressCleansingMessage != null){
                            cleansedAddressMap.put('errorMessage',addressCleansingMessage.getText());}
                    }else{ 
                        for(Dom.XMLNode postalAddressChild : postalAddressNode.getChildElements()){
                            if(postalAddressChild.getName() == 'StreetAddress1'){
                                cleansedAddressMap.put('StreetAddress1',postalAddressChild.getText());
                            }
                            if(postalAddressChild.getName() == 'StreetAddress2'){
                                cleansedAddressMap.put('StreetAddress2',postalAddressChild.getText());
                            }
                            if(postalAddressChild.getName() == 'City'){
                                cleansedAddressMap.put('City',postalAddressChild.getText());
                            }
                            if(postalAddressChild.getName() == 'MainDivision'){
                                cleansedAddressMap.put('MainDivision',postalAddressChild.getText());
                            }
                            if(postalAddressChild.getName() == 'SubDivision'){
                                cleansedAddressMap.put('SubDivision',postalAddressChild.getText());
                            }
                            if(postalAddressChild.getName() == 'PostalCode'){
                                cleansedAddressMap.put('PostalCode',postalAddressChild.getText());
                            }
                            if(postalAddressChild.getName() == 'Country'){
                                cleansedAddressMap.put('Country',postalAddressChild.getText());
                            }
                        }
                    }
                }   
            }else{
                //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                Long afterAPI = B2B_Util.fetchCurrentTime();
                Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI,afterAPI);
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
                String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
                Error__c errorRecord=B2B_Util.createErrorRecord(true,'','','',personAccountId,'','B2B_VertexTaxCalculationIntegration',String.valueOf(response.getStatusCode()),errorType,'','vertexAddressCleansing',true,'','','',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                //HDMP-8617- End of changes
            }
        }catch(Exception ex){
            cleansedAddressMap.put('isError','true');
            cleansedAddressMap.put('errorMessage',ex.getMessage());
            Error__c objError = B2B_BrainTreeUtils.createErrorRecord('Address Cleansing error:', null, ex.getMessage());
            if(objError != null){
                insert objError;
            }
        }
        return Json.serialize(cleansedAddressMap);
    }
    
    public class ResponseDataWrapper{
        public String responseCode;
        public String errorMessage;
        public Boolean isSuccess;
        public String totalTaxAmount;
        public Decimal shippingTaxAmount=0.00;//Added by Soumya for 8705
        public Decimal installationTaxAmount=0.00;//Added by Soumya for 8705
        public List<taxDetailForLineItem> lineItemsDetails = New List<taxDetailForLineItem>();
        ResponseDataWrapper(){
            errorMessage = '';
            isSuccess = false;
            totalTaxAmount = '';
            responseCode = '';
        }
    }
    
    public class taxDetailForLineItem{
        String itemId,totalItemTax,stateTax,stateTaxRate,cityTax,cityTaxRate,transitDistrictTax,transitDistrictTaxRate;
    }   
}
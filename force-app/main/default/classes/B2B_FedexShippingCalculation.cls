/*******************************************************************************
Name: B2B_FedexShippingCalculation
Business Unit: HDM
Date: 28/04/21
Developer: Radhey Shyam Gupta 
Description: This class is to provide Shipping charge calculation.
*******************************************************************************
MODIFICATIONS – V1 | Soumya Sahoo | Error handling changes- JIRA- 8617 
				V2 | Sayalee Brahmankar | Added Header
				V3 | Soumya Sahoo | Error handling changes- JIRA- 8924
*******************************************************************************/

Public class B2B_FedexShippingCalculation{
    
    public static String fedexShippingChargeCalculation(String cartId, String dealerAddress, String customerAddress,String cartType){
        B2B_IntegrationWrapper responseWrapper =  New B2B_IntegrationWrapper();
        try{
            Integer fedexBoxLength = B2B_IntegrationConstants.DEFAULT_VALUE;
            Integer fedexBoxWidth = B2B_IntegrationConstants.DEFAULT_VALUE;
            Integer fedexBoxHeight = B2B_IntegrationConstants.DEFAULT_VALUE;
            Decimal packageCount = B2B_IntegrationConstants.DEFAULT_VALUE;
            String responseData;
            Map<String,Carrier_Speed__c> shippingSpeedsMap = B2B_IntegrationUtility.getShippingdata(B2B_IntegrationConstants.FEDEX_LABEL,false);
            List<String> dealerAddressList = New List<String>();
            List<String> customerAddressList = New List<String>();
            // Start here for Cart Logic change
            if(!String.IsEmpty(dealerAddress) && cartType!=B2B_IntegrationConstants.TYPE_VALUE){
                dealerAddressList = dealerAddress.split(B2B_Constant.SHIPPING_SPLIT);
            }
            if(!String.IsEmpty(customerAddress) && cartType!=B2B_IntegrationConstants.TYPE_VALUE){
                customerAddressList = customerAddress.split(B2B_Constant.SHIPPING_SPLIT);
            }// Ends here -- Soumya Sahoo R2 Story
            if((dealerAddressList.size() < 3 || customerAddressList.size() < 3) && cartType!=B2B_IntegrationConstants.TYPE_VALUE){
                responseWrapper.errorMessage = B2B_IntegrationConstants.ERROR_CORRECT_ADDRESS;
                responseWrapper.isSuccess = false; 
                return JSON.serialize(responseWrapper);
            }else{
                String guId = B2B_Util.createGui();
                Http http = new Http();
                String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://www.honda.com/global/1.0/header/" xmlns:q0="http://fedex.com/ws/rate/v28" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                body += '<soapenv:Header>';
                body += '<head:hondaHeaderType>';
                body += '<head:messageId>'+guId+'</head:messageId>';
                body += '<head:siteId>'+Label.B2B_Fedex_SiteId+'</head:siteId>';
                body += '<head:businessId>'+Label.B2B_Fedex_BusinessId+'</head:businessId>';
                body += '<head:collectedTimestamp>'+datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'America/Los_Angeles')+'</head:collectedTimestamp>'; //2020-11-30T09:55:29
                body += '</head:hondaHeaderType>';
                body += '</soapenv:Header>';
                body += '<soapenv:Body>';
                body += '<q0:RateRequest>';
                body += '<q0:WebAuthenticationDetail>';
                body += '<q0:UserCredential>';
                body += '<q0:Key>';
                body += Label.B2B_Fedex_Key;
                body += '</q0:Key>';
                body += '<q0:Password>';
                body +=  Label.B2B_Fedex_Password;
                body += '</q0:Password>';
                body += '</q0:UserCredential>';
                body += '</q0:WebAuthenticationDetail>';
                body += '<q0:ClientDetail>';
                body += '<q0:AccountNumber>';
                body += Label.B2B_FedexAccountNumber;
                body += '</q0:AccountNumber>';
                body += '<q0:MeterNumber>';
                body += Label.B2B_MeterNumber;
                body += '</q0:MeterNumber>';
                body += '</q0:ClientDetail>';
                body += '<q0:TransactionDetail>';
                body += '<q0:CustomerTransactionId>';
                body += cartId;
                body += '</q0:CustomerTransactionId>';
                body += '</q0:TransactionDetail>';
                body += '<q0:Version>';
                body += '<q0:ServiceId>';
                body += 'crs';
                body += '</q0:ServiceId>';
                body += '<q0:Major>';
                body += '28';
                body += '</q0:Major>';
                body += '<q0:Intermediate>';
                body += '0';
                body += '</q0:Intermediate>';
                body += '<q0:Minor>';
                body += '0';
                body += '</q0:Minor>';
                body += '</q0:Version>';
                body += '<q0:ReturnTransitAndCommit>true</q0:ReturnTransitAndCommit>';
                body += '<q0:RequestedShipment>';
                body += '<q0:DropoffType>'+'REGULAR_PICKUP'+'</q0:DropoffType>';
                body += '<q0:PackagingType>'+'YOUR_PACKAGING'+'</q0:PackagingType>';
                body += '<q0:Shipper>';
                body += '<q0:Address>';
                if(cartType!=B2B_IntegrationConstants.TYPE_VALUE){
                    body += '<q0:StateOrProvinceCode>'+dealerAddressList[0]+'</q0:StateOrProvinceCode>';
                    body += '<q0:PostalCode>'+dealerAddressList[1]+'</q0:PostalCode>';
                    body += '<q0:CountryCode>'+dealerAddressList[2]+'</q0:CountryCode>';  
                }else{
                    body += '<q0:PostalCode>'+dealerAddress+'</q0:PostalCode>';
                    body += '<q0:CountryCode>'+B2B_IntegrationConstants.COUNTRY_VALUE+'</q0:CountryCode>';   
                }
                body += '</q0:Address>';
                body += '</q0:Shipper>';
                body += '<q0:Recipient>';
                body += '<q0:Address>';
                if(cartType!=B2B_IntegrationConstants.TYPE_VALUE){
                    body += '<q0:StateOrProvinceCode>'+customerAddressList[0]+'</q0:StateOrProvinceCode>';
                    body += '<q0:PostalCode>'+customerAddressList[1]+'</q0:PostalCode>';
                    body += '<q0:CountryCode>'+customerAddressList[2]+'</q0:CountryCode>'; 
                }
                else{
                    body += '<q0:PostalCode>'+customerAddress+'</q0:PostalCode>';
                    body += '<q0:CountryCode>'+B2B_IntegrationConstants.COUNTRY_VALUE+'</q0:CountryCode>';  
                }
                body += '<q0:Residential>'+'false'+'</q0:Residential>';
                body += '</q0:Address>';
                body += '</q0:Recipient>';
                body += '<q0:RateRequestTypes>LIST</q0:RateRequestTypes>';
                for(CartItem objCartItem : B2B_IntegrationUtility.getCartItemdetails(cartId)){
                    if(objCartItem.Item_Package_quantity__c > 0)
                      packageCount += (objCartItem.Quantity * objCartItem.Item_Package_quantity__c);
                    else
                        packageCount += objCartItem.Quantity;
                }
                body += '<q0:PackageCount>'+packageCount+'</q0:PackageCount>';
                for(CartItem objCartItem : B2B_IntegrationUtility.getCartItemdetails(cartId)){                                  
                    body += '<q0:RequestedPackageLineItems>';
                    if(objCartItem.Item_Package_quantity__c > 0)
                        body += '<q0:GroupPackageCount>'+objCartItem.Quantity * objCartItem.Item_Package_quantity__c+'</q0:GroupPackageCount>';
                    else
						body += '<q0:GroupPackageCount>'+objCartItem.Quantity+'</q0:GroupPackageCount>';                        
                    body += '<q0:Weight>';
                    body += '<q0:Units>'+'LB'+'</q0:Units>';
                    body += '<q0:Value>'+objCartItem.Product2.Weight_lbs__c+'</q0:Value>';
                    body += '</q0:Weight>';
                    body += '<q0:Dimensions>';                            
                    body += '<q0:Length>'+Math.ceil(objCartItem.Product2.Length_in__c)+'</q0:Length>';
                    body += '<q0:Width>'+Math.ceil(objCartItem.Product2.Width_in__c)+'</q0:Width>';
                    body += '<q0:Height>'+Math.ceil(objCartItem.Product2.Height_in__c)+'</q0:Height>'; 
                    body += '<q0:Units>'+'IN'+'</q0:Units>';
                    body += '</q0:Dimensions>';                
                    body += '</q0:RequestedPackageLineItems>';                
                }
                body += '</q0:RequestedShipment>';
                body += '</q0:RateRequest>';
                body += '</soapenv:Body>';
                body += '</soapenv:Envelope>';
                HttpRequest request = new HttpRequest();
                request.setHeader('Content-Type', 'application/xml');                
                request.setMethod('POST');
                request.setBody(body);
                request.setEndpoint('callout:FedexDataPowerNamedCredential');
                Long beforeAPI = B2B_Util.fetchCurrentTime();// HDMP-8617- This will provide initial response time
                HTTPResponse response = http.send(request);
                if(response.getStatusCode()==B2B_IntegrationConstants.STATUSCODE){
                    responseData = response.getBody();
                    DOM.Document doc = response.getBodyDocument();
                    Dom.XMLNode rootElement = doc.getRootElement(); 
                    Map<String,String> serviceTypewithChargeMapData = New Map<String,String>();
                    responseWrapper.responseCode = String.valueOf(response.getStatusCode());
                    for (Dom.XMLNode childElement : rootElement.getChildElements()){
                        for(Dom.XMLNode detailElement : childElement.getChildElements()){
                            if(detailElement.getName()==B2B_IntegrationConstants.RATEREPLY){
                                Dom.XMLNode notificationElement = detailElement.getChildElement(B2B_IntegrationConstants.NOTIFICATIONS,B2B_IntegrationConstants.FEDEX_XML_URL);
                                String successOrFailure = notificationElement.getChildElement(B2B_IntegrationConstants.SEVERITY,B2B_IntegrationConstants.FEDEX_XML_URL).getText();
                                String responseMssg = notificationElement.getChildElement(B2B_IntegrationConstants.MESSAGE,B2B_IntegrationConstants.FEDEX_XML_URL).getText();
                                String errorCodeResponse=notificationElement.getChildElement(B2B_IntegrationConstants.CODE,B2B_IntegrationConstants.FEDEX_XML_URL).getText();
                                String serviceType = '';
                                if(successOrFailure != B2B_Constant.FAILURE_LABEL && successOrFailure != B2B_Constant.WARNING_LABEL && successOrFailure != B2B_Constant.ERROR_LABEL){
                                    for(Dom.XMLNode rateReplydetailElement : detailElement.getChildElements()){
                                        if(rateReplydetailElement.getname() == B2B_IntegrationConstants.RATEREPLYDETAILS){
                                            for(Dom.XMLNode RatedShipmentDetailsElement: rateReplydetailElement.getChildElements()){
                                                if(RatedShipmentDetailsElement.getname() == B2B_IntegrationConstants.SERVICETYPE){
                                                    serviceType = RatedShipmentDetailsElement.getText();
                                                }
                                                if(RatedShipmentDetailsElement.getname() == B2B_IntegrationConstants.RATEDSHIPMENTDETAILS){
                                                    for(Dom.XMLNode ShipmentRateDetailElement : RatedShipmentDetailsElement.getChildElements()){
                                                        if(ShipmentRateDetailElement.getname() == B2B_IntegrationConstants.SHIPMENTRATEDETAIL){
                                                            if(ShipmentRateDetailElement.getChildElement(B2B_IntegrationConstants.RATETYPE,B2B_IntegrationConstants.FEDEX_XML_URL) != null){
                                                                String rateType = ShipmentRateDetailElement.getChildElement(B2B_IntegrationConstants.RATETYPE,B2B_IntegrationConstants.FEDEX_XML_URL).getText();
                                                                if(rateType == B2B_IntegrationConstants.PAYORLISTPACKAGE){
                                                                    if(ShipmentRateDetailElement.getChildElement(B2B_IntegrationConstants.TOTALNETCHARGEWITHOUT,B2B_IntegrationConstants.FEDEX_XML_URL) != null){
                                                                        Dom.XMLNode shipmentElement = ShipmentRateDetailElement.getChildElement(B2B_IntegrationConstants.TOTALNETCHARGEWITHOUT,B2B_IntegrationConstants.FEDEX_XML_URL);
                                                                        if(shipmentElement.getChildElement(B2B_IntegrationConstants.AMOUNT,B2B_IntegrationConstants.FEDEX_XML_URL).getname() != null ){
                                                                            String totalCharge = shipmentElement.getChildElement(B2B_IntegrationConstants.AMOUNT,B2B_IntegrationConstants.FEDEX_XML_URL).getText();
                                                                            if(shippingSpeedsMap.containsKey(serviceType))
                                                                                serviceTypewithChargeMapData.put(serviceType,totalCharge);
                                                                        }
                                                                    }
                                                                } 
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    responseWrapper.isSuccess = B2B_Constant.TRUE_FLAG;
                                    responseWrapper.serviceTypewithChargeMap = serviceTypewithChargeMapData;
                                }else if(errorCodeResponse==B2B_IntegrationConstants.FEDEX_ADDRESS_WRONG_CODE){
                                    responseWrapper.errorMessage = B2B_IntegrationConstants.ERROR_MESSAGE_ADDRESS_INVALID;
                                    responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
                                    responseWrapper.responseCode = string.valueof(response.getStatusCode());
                                }
                            } 
                        }
                    }
                }else{
                    responseWrapper.errorMessage = B2B_IntegrationConstants.ERROR_MESSAGE_API_DOWN;
                    responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
                    responseWrapper.responseCode = string.valueof(response.getStatusCode());
                    //HDMP-8617- Below lines of code added to handle,insert on error object and trigger email to support team
                    Long afterAPI =B2B_Util.fetchCurrentTime();
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
                    Webcart cart=B2B_IntegrationUtility.getcartdetails(cartId);
                    String personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(cart.ownerId);
                    Error__c errorRecord=B2B_Util.createErrorRecord(true,'','',cart.DealerId__c,personAccountId,cartId,'B2B_FedexShippingCalculation',String.valueOf(response.getStatusCode()),errorType,'','fedexShippingChargeCalculation',true,'',cartId,'',durationTime,severity,'Request:'+request.getBody(),'Response:'+response.getBody());
                    //HDMP-8617- End of changes
                }
            }
            
        }catch(Exception Ex){
            responseWrapper.isSuccess = B2B_Constant.FALSE_FLAG;
            responseWrapper.errorMessage = ex.getMessage() + ' ' + ex.getLineNumber();
        }
        return JSON.serialize(responseWrapper);
    }
    
}
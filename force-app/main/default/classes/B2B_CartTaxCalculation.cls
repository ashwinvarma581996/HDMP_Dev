public class B2B_CartTaxCalculation {
		@AuraEnabled(cacheable=false)	
    public static String  CartTaxCharges(String cartId,String CustomerPostalCode,String ShippingCharges){
        ResponseDataWrapper responseData =new ResponseDataWrapper();
        WebCart cart = [SELECT Id,DealerId__c,DealerId__r.shippingStreet,DealerId__r.shippingCity,
                DealerId__r.shippingPostalCode,DealerId__r.shippingState,
                DealerId__r.Name,DealerId__r.POIID__c,ShippingAmount__c,
                CustomerStreet__c,Customer_State__c,CustomerCity__c,CustomerCountry__c,
                CustomerPostalCode__c
        FROM WEbCart
        WHERE Id=:cartId];
        System.debug('Dealer Postal Code'+cart.DealerId__r.shippingPostalCode);
       	String dealerPostalCode=cart.DealerId__r.shippingPostalCode;
			
        responseData = calculateTaxQuotation(cartId,dealerPostalCode,CustomerPostalCode,cart.DealerId__r.POIID__c,ShippingCharges, 'quotation');
        system.debug('myresponseData'+JSON.serialize(responseData));
        return JSON.serialize(responseData);
     }
    
    public static ResponseDataWrapper calculateTaxQuotation(String cartId,String dealerPostalCode, String CustomerPostalCode,String dealerCode,String shippingCharge,String methodName){
        ResponseDataWrapper responseWrapper =  New ResponseDataWrapper();
        		try{
          				if(dealerPostalCode == '' && CustomerPostalCode == ''){
             				responseWrapper.errorMessage = 'Please Provide Correct Addresses.';
             				responseWrapper.isSuccess = false; 
             		    return responseWrapper;
          }else{
             Map<Integer,String> mapLineItem = New Map<Integer,String>();
              Http http = new Http();
              HttpRequest request = new HttpRequest();
              String guId = B2B_Util.createGui(); //Added by Apoorv Garg
              request.setHeader('Content-Type', 'text/xml');
              request.setMethod('POST');
              
              // Creating Request Body
              String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://www.honda.com/global/1.0/header/" xmlns:urn="urn:vertexinc:o-series:tps:9:0">';
              body += '<soapenv:Header>';
              body += '<head:hondaHeaderType>';
              body += '<head:messageId>'+guId+'</head:messageId>';
              //body += '<head:messageId>'+Label.B2B_Fedex_MessageId+'</head:messageId>';
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
              //body += '<urn:QuotationRequest documentDate="2021-02-19" postingDate="2021-02-19" transactionType="SALE">';
              body += '<urn:Seller> <urn:Company>'+'AHM Group'+'</urn:Company>';
              body += '<urn:Division>'+dealerCode+'</urn:Division> </urn:Seller>';
              Integer i = 0;
              for(CartItem objCartItem : [Select Id,Quantity,unitadjustedPrice,TotalAmount,Product2.StockKeepingUnit from CartItem where cartId =:cartId]){
                  i = i+1;
                  mapLineItem.put(i,objCartItem.Id);
                  body += '<urn:LineItem lineItemNumber="'+i+'" vendorSKU="'+objCartItem.Product2.StockKeepingUnit+'">';
                  body += '<urn:Seller> <urn:AdministrativeOrigin>';
                  
                 
                  
                  body += '<urn:PostalCode>'+dealerPostalCode+'</urn:PostalCode> </urn:AdministrativeOrigin>';
                  body += '</urn:Seller>';
                  body += '<urn:Customer><urn:Destination>';
                 
                  
                  body += '<urn:PostalCode>'+CustomerPostalCode+'</urn:PostalCode>';
                  body += '</urn:Destination></urn:Customer>';
                  body += '<urn:Product>'+'00004'+'</urn:Product>';
                  body += '<urn:Quantity unitOfMeasure="EA">'+objCartItem.Quantity+'</urn:Quantity>';
                  body += '<urn:UnitPrice>'+objCartItem.UnitAdjustedPrice+'</urn:UnitPrice>';
                  System.debug('---Total Amount-- '+objCartItem.TotalAmount);
                  if(methodName == 'return'){
                      body += '<urn:ExtendedPrice>'+ -objCartItem.TotalAmount +'</urn:ExtendedPrice>';
                  }else{
                      body += '<urn:ExtendedPrice>'+ objCartItem.TotalAmount +'</urn:ExtendedPrice>';
                  }
                  body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                
              }
              
              if(shippingCharge != null){
                  i = i+1;
                  mapLineItem.put(i,'00006');
                  body += '<urn:LineItem lineItemNumber="'+i+'">';
                  body += '<urn:Seller> <urn:AdministrativeOrigin>';
                  body += '<urn:PostalCode>'+dealerPostalCode+'</urn:PostalCode> </urn:AdministrativeOrigin>';
                  body += '</urn:Seller>';
                  body += '<urn:Customer> <urn:Destination>';
                  body += '<urn:PostalCode>'+CustomerPostalCode+'</urn:PostalCode>';
                  body += '</urn:Destination></urn:Customer>';
                  body += '<urn:Product>'+'00006'+'</urn:Product>';
                  System.debug('ShippingChargeValue'+shippingCharge);
                  body += '<urn:ExtendedPrice>'+shippingCharge+'</urn:ExtendedPrice>';
                  body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
              }
              
              if(methodName == 'quotation'){
                  body += '</urn:QuotationRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
              }else if(methodName == 'commit'){
                  body += '</urn:InvoiceRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
              }else if(methodName == 'return'){
                  body += '</urn:InvoiceRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
              }
              System.debug('==RequestBody=='+body);
              request.setBody(body);  
              request.setEndpoint('callout:VertexNamedCredential'+ Label.B2B_Vertex_Path_URL);
              //String usernamePassword = Label.B2B_Vertex_HDM_Username +':'+Label.B2B_Vertex_HDM_Password ;
              //String authorizationString = EncodingUtil.base64Encode(Blob.valueof(usernamePassword)); 
              //request.setHeader('Authorization', 'Basic '+authorizationString);
              
              // Get Response
              HTTPResponse response = http.send(request);
              System.debug('testResponsecartTax'+response.getBody());
              DOM.Document doc = response.getBodyDocument();
              // Get Root Element which is 'Envelope'
              Dom.XMLNode rootElement = doc.getRootElement();
              System.debug('---RootElementName---'+rootElement.getName()); 
              String totalTaxAmount ='';
              String errorDescription = '';
              List<CartItem> lstCartItem = New List<CartItem>();
              responseWrapper.responseCode = String.valueOf(response.getStatusCode());
              for(Dom.XMLNode childElement : rootElement.getChildElements()){ 
                 if(childElement.getName() == 'Body'){
                     if(childElement.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/') != null){
                       Dom.XMLNode faultNode =  childElement.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                       if(faultNode.getChildElement('faultstring',null) != null){
                          errorDescription = faultNode.getChildElement('faultstring',null).getText();
                          responseWrapper.isSuccess = false;
                          responseWrapper.errorMessage = errorDescription;
                          responseWrapper.totalTaxAmount = '';
                       }
                     }else if(childElement.getChildElement('VertexEnvelope','urn:vertexinc:o-series:tps:9:0') != null){
                         Dom.XMLNode vertexEnvelopeNode = childElement.getChildElement('VertexEnvelope','urn:vertexinc:o-series:tps:9:0');
                         Dom.XMLNode quotationResponse;
                         if(methodName == 'quotation'){
                             if(vertexEnvelopeNode.getChildElement('QuotationResponse','urn:vertexinc:o-series:tps:9:0') != null){
                                 quotationResponse =  vertexEnvelopeNode.getChildElement('QuotationResponse','urn:vertexinc:o-series:tps:9:0');
                             }
                         }else{
                             if(vertexEnvelopeNode.getChildElement('InvoiceResponse','urn:vertexinc:o-series:tps:9:0') != null){
                                 quotationResponse =  vertexEnvelopeNode.getChildElement('InvoiceResponse','urn:vertexinc:o-series:tps:9:0');
                             }
                         }
                         
                         if(quotationResponse != null){
                           // Dom.XMLNode quotationResponse =  vertexEnvelopeNode.getChildElement('QuotationResponse','urn:vertexinc:o-series:tps:9:0');
                            for(Dom.XMLNode quotationResponseChild : quotationResponse.getChildElements()){
                                if(quotationResponseChild.getName() == 'TotalTax'){
                                    totalTaxAmount = quotationResponseChild.getText();
                                    responseWrapper.isSuccess = true;
                                    responseWrapper.errorMessage = '';
                                    responseWrapper.totalTaxAmount = totalTaxAmount;
                                }
                                if(quotationResponseChild.getName() == 'LineItem'){
                                   
                                   B2B_CartTaxCalculation.taxDetailForLineItem objInner = New B2B_CartTaxCalculation.taxDetailForLineItem();
                                   String cartItemId = mapLineItem.get(Integer.valueOf(quotationResponseChild.getAttributeValue('lineItemNumber',null)));
                                   objInner.itemId = cartItemId;
                                   CartItem objCartItem;
                                   if(cartItemId != Label.B2B_Shipping_Code){
                                       objCartItem = New CartItem();
                                       objCartItem.Id = objInner.itemId;
                                   }
                                   for(Dom.XMLNode lineItemsNodes : quotationResponseChild.getChildElements()){
                                       if(lineItemsNodes.getName() == 'TotalTax'){
                                        objInner.totalItemTax = lineItemsNodes.getText();
                                        if(cartItemId != Label.B2B_Shipping_Code){
                                            objCartItem.B2B_Item_Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());
                                        }
                                       }
                                       if(lineItemsNodes.getName() == 'Taxes'){
                                           Dom.XMLNode JuridictionResponse =  lineItemsNodes.getChildElement('Jurisdiction','urn:vertexinc:o-series:tps:9:0');
                                           String jdLevel = JuridictionResponse.getAttributeValue('jurisdictionLevel',null);
                                           String tax =  lineItemsNodes.getChildElement('CalculatedTax','urn:vertexinc:o-series:tps:9:0').getText();
                                           String taxRate =  lineItemsNodes.getChildElement('EffectiveRate','urn:vertexinc:o-series:tps:9:0').getText();
                                           if(jdLevel == 'STATE'){
                                             objInner.stateTax = tax;
                                             objInner.stateTaxRate = taxRate; 
                                             if(cartItemId != Label.B2B_Shipping_Code){
                                                 objCartItem.B2B_StateTax__c = Decimal.valueOf(tax);
                                                 objCartItem.B2B_StateTax_Rate__c = Decimal.valueOf(taxRate);
                                             }
                                           }
                                           else if(jdLevel == 'CITY'){
                                             objInner.cityTax = tax;
                                             objInner.cityTaxRate = taxRate;
                                             if(cartItemId != Label.B2B_Shipping_Code){
                                                 objCartItem.B2B_CityTax__c = Decimal.valueOf(tax);
                                                 objCartItem.B2B_CityTax_Rate__c = Decimal.valueOf(taxRate);
                                             } 
                                           }else if(jdLevel == 'TRANSIT_DISTRICT'){
                                             objInner.transitDistrictTax = tax;
                                             objInner.transitDistrictTaxRate = taxRate; 
                                             if(cartItemId != Label.B2B_Shipping_Code){
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
              if(!lstCartItem.isEmpty()){
                  update lstCartItem;
              }
              System.debug('--TaxCalculatedCarttax ===> '+totalTaxAmount);
            }
       }catch(Exception Ex){
           responseWrapper.isSuccess = false;
           responseWrapper.errorMessage = ex.getMessage()+ ' Line Number '+ex.getLineNumber();
       }
       System.debug('ResponseFromServer'+JSON.serialize(responseWrapper)); 
              
              
        				return responseWrapper;
          
    }
    
    public class ResponseDataWrapper{
        public String responseCode;
        public String errorMessage;
        public Boolean isSuccess;
        public String totalTaxAmount ;
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
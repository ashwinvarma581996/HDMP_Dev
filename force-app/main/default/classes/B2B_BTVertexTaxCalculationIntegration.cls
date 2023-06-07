/**********************************************************************
Name: B2B_BTVertexTaxCalculationIntegration
Business Unit:HDM

Date : 27/06/2021
Developer : Rajrishi Kaushik
Description: For calculating taxes from vertex,Test ClassName- B2B_BTVertexTaxCalculationIntTest,B2B_VertexTaxCalculationCalloutMock(Mock Class), B2B_TestDataFactory
MODIFICATIONS -Yashika Agarwal(Error handling changes- JIRA- 8617)
MODIFICATIONS - Soumya Sahoo- HDMP-9851
MODIFICATIONS – 09/06/2022 | Mathioli | (Added header and removal of commented code)
MODIFICATIONS - 27/03/2023 | Saravanan LTIM | Added Vertex logic for Core Charge and Reman Products
*************************************************************/
   
Public class B2B_BTVertexTaxCalculationIntegration{
    @AuraEnabled
    public static ResponseDataWrapper calculateTax(String cartId,Map<String,String> dealerAddressMap, Map<String,String> customerAddressMap,String dealerCode,String shippingCharge, String installationCharges, String methodName){
        ResponseDataWrapper responseWrapper =  New ResponseDataWrapper();
        try{
            String userId = UserInfo.getUserId();
            if(dealerAddressMap.size() != 4 && customerAddressMap.size() != 4){
                responseWrapper.errorMessage = 'Please Provide Correct Addresses.';
                responseWrapper.isSuccess = false; 
                return responseWrapper;
            }else{
                String OrderId;
                Map<String, CartItem> mapProductIdCartItemIds = new Map<String, CartItem>();
                // Saravanan LTIM Added Variable for Core Charge DPrint 2 
                Map<String, CartItem> mapProductIdCoreChargeCartItemIds = new Map<String, CartItem>();
                List<Order> lstOrders = new List<Order>();
                // Saravanan LTIM Added API For Sprint 2 Vertex Data Rules Product_Type__c,Product2.Core_Charge_Unit_Price__c
                List<WebCart> lstWebCarts = [SELECT Id,(SELECT Id FROM Orders__r) , 
                                             (SELECT Id, Name, Quantity, Op_Code__c, unitadjustedPrice, TotalAmount, Product2Id,Dealer_Installation_Price__c,Product_Model__c,Product_Identifier__c,Product_Subdivision__c,Product_Division__c,Product_Model_Marketing_Name__c,Color__c,Product_Type__c,Product2.Core_Charge_Unit_Price__c FROM CartItems) 
                                             FROM WebCart 
                                             WHERE Id =:cartId];
                Map<String, OrderItem> mapCartItemOrderItemIds = new Map<String, OrderItem>();
                if(!lstWebCarts.isEmpty()){
                    OrderId = (lstWebCarts[0].Orders__r.isEmpty()) ? null : lstWebCarts[0].Orders__r[0].Id;
                    if(OrderId != null) {
                        if(methodName != 'return'){
                             // Total_Core_Charge_Current_Amount__c  Added by Ashwin as fix of 18568
                            // populating order amount fields
                            Order objOrder = [SELECT Id, Updated_Shipping__c, Updated_Order_Total__c, Updated_Total_Tax__c, Updated_Order_Amount__c, 
                                              cart__r.TOTAL__c, cart__r.Total_Tax__c, cart__r.TotalProductAmount, cart__r.ShippingAmount__c, cart__r.Total_Installation_Charge__c,
                                              Original_Shipping_Amount__c,GrandTotalAmount__c,TotalTaxAmount__c, Total_Original_Product_Amount__c,Total_Installation_Charges__c,Total_Core_Charge_Current_Amount__c
                                              FROM Order 
                                              WHERE Id =: OrderId 
                                              LIMIT 1];

                            // isContainCore, totalProductAmount  Added by Ashwin as fix of 18568
                            Boolean isContainCore = objOrder.Total_Core_Charge_Current_Amount__c != 0 && objOrder.Total_Core_Charge_Current_Amount__c != null ? true : false;
                            Decimal totalProductAmount = isContainCore ? objOrder.cart__r.TotalProductAmount - objOrder.Total_Core_Charge_Current_Amount__c : objOrder.cart__r.TotalProductAmount;

                            //Filling current order fields               
                            objOrder.Updated_Order_Total__c = objOrder.cart__r.TOTAL__c;
                            objOrder.Updated_Total_Tax__c = objOrder.cart__r.Total_Tax__c;
                            objOrder.Updated_Order_Amount__c = totalProductAmount; // Added by Ashwin as fix of 18568  Privious Value : objOrder.cart__r.TotalProductAmount
                            objOrder.Updated_Shipping__c = objOrder.cart__r.ShippingAmount__c;
                           
                            //Filling original order fields
                            objOrder.Original_Shipping_Amount__c = objOrder.cart__r.ShippingAmount__c;
                            objOrder.GrandTotalAmount__c = objOrder.cart__r.TOTAL__c;
                            objOrder.TotalTaxAmount__c = objOrder.cart__r.Total_Tax__c;
                            objOrder.Total_Original_Product_Amount__c = objOrder.cart__r.TotalProductAmount;
                            objOrder.Total_Installation_Charges__c = objOrder.cart__r.Total_Installation_Charge__c;

                            lstOrders.add(objOrder); 
                        }           
                        // Saravanan LTIM Added for Sprint 2 Vertex Data Rules Product_Type__c , Order.Product2.Core_Charge_Unit_Price__c                                    
                        List<OrderItem> lstOrderItems = [SELECT Id, Total_Current_Product_Tax__c, Total_Tax__c, Op_Code__c, Product2Id, Dealer_Installation_Price__c, 
                                                         Updated_Quantity__c, Cart_Item_Product_Name__c, OrderId, Product_SKU__c, Product_Name__c, Quantity,Product_Model__c,Product_Identifier__c,Product_Subdivision__c,Product_Division__c,Product_Model_Marketing_Name__c,Color__c
                                                         , Product_Type__c , Product2.Core_Charge_Unit_Price__c
                                                         FROM OrderItem 
                                                         WHERE OrderId =: OrderId];
                        if(lstOrderItems.isEmpty() == false && lstWebCarts[0].CartItems.isEmpty() == false){                          
                            for(CartItem objCartItem : lstWebCarts[0].CartItems){
                                
                                // Saravanan LTIM Added for Sprint 2 Vertex Data Rules if...else Conditions
                                if(objCartItem.Product_type__c == label.B2B_Product_Code_Core_Charges){
                                    mapProductIdCoreChargeCartItemIds.put(objCartItem.Product2Id, objCartItem);
                                }else{
                                    mapProductIdCartItemIds.put(objCartItem.Product2Id, objCartItem);
                                }
                            }
                            for(OrderItem objOrderItem : lstOrderItems){   
                                // Saravanan LTIM Added for Sprint 2 Vertex Data Rules if Conditions
                                if(objOrderItem.Product_type__c == Label.B2B_Product_Code_Core_Charges){ 
                                    CartItem objCoreCartItem = mapProductIdCoreChargeCartItemIds.get(objOrderItem.Product2Id);   
                                    mapCartItemOrderItemIds.put(objCoreCartItem.Id, objOrderItem);  
                                }else{
                                    CartItem objCartItem  = mapProductIdCartItemIds.get(objOrderItem.Product2Id);
                                    mapCartItemOrderItemIds.put(objCartItem.Id, objOrderItem);  
                                }                          
                            }
                        }
                        
                        
                    }                    
                }
               
                Map<Integer,String> mapLineItem = New Map<Integer,String>();
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String guId = B2B_Util.createGui();
                request.setHeader('Content-Type', 'text/xml');
                request.setMethod('POST');
                // Creating Request Body
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
                //R2C1 : change document number from cart id to order Id
                if(methodName == 'quotation'){
                    body += '<urn:QuotationRequest documentDate="'+ todayDate +'" documentNumber="'+ OrderId + '" postingDate="'+ todayDate + '" transactionType="SALE">';
                }else if(methodName == 'commit'){
                    body += '<urn:InvoiceRequest documentDate="'+ todayDate +'" documentNumber="'+ OrderId + '" postingDate="'+ todayDate + '" transactionType="SALE">';
                }else if(methodName == 'return'){
                    body += '<urn:InvoiceRequest documentDate="'+ todayDate +'" documentNumber="'+ OrderId + '" postingDate="'+ todayDate + '" transactionType="SALE">';
                }
                body += '<urn:Seller> <urn:Company>'+'AHM Group'+'</urn:Company>';
                body += '<urn:Division>'+dealerCode+'</urn:Division> </urn:Seller>';
                Integer i = 0;
                if(methodName != 'return'){    
                    // Saravanan LTIM Added API for Sprint 2 Data Rules Vertex  Product_Type__c , Order.Product2.Core_Charge_Unit_Price__c                          
                    for(CartItem objCartItem : [SELECT Id,Quantity,unitadjustedPrice,TotalAmount,Product2.StockKeepingUnit,Product_Type__c,Product2.Core_Charge_Unit_Price__c
                                                FROM CartItem
                                                WHERE cartId =:cartId ORDER By Sku]){
                        i = i+1;
                        mapLineItem.put(i,objCartItem.Id);
                        body += '<urn:LineItem lineItemNumber="'+i+'" vendorSKU="'+objCartItem.Product2.StockKeepingUnit+'">';
                        body += '<urn:Seller> <urn:AdministrativeOrigin> <urn:StreetAddress1>';
                        body += dealerAddressMap.get('streetAddress') + '</urn:StreetAddress1>';
                        body += '<urn:City>'+dealerAddressMap.get('city')+'</urn:City>';
                        body += '<urn:MainDivision>'+dealerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+dealerAddressMap.get('postalCode')+'</urn:PostalCode> </urn:AdministrativeOrigin>';
                        body += '</urn:Seller>';
                        body += '<urn:Customer> <urn:Destination> <urn:StreetAddress1>'+customerAddressMap.get('streetAddress');
                        body += '</urn:StreetAddress1><urn:City>'+customerAddressMap.get('city')+'</urn:City>';
                        body += '<urn:MainDivision>'+customerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+customerAddressMap.get('postalCode')+'</urn:PostalCode>';
                        body += '</urn:Destination></urn:Customer>';
                       
                        if(objCartItem.Product_Type__c == 'Motocompacto'){
                            body += '<urn:Product>'+Label.motocompacto_code+'</urn:Product>';
                        }else{
                        //Saravanan LTIM Added for Sprint 2 Data Rules and US
                             body += objCartItem.Product_type__c == Label.B2B_Product_Code_Core_Charges ?  '<urn:Product>'+Label.B2B_Product_Code_Core_Charges+'</urn:Product>'  :  objCartItem.Product2.Core_Charge_Unit_Price__c > 0  ? '<urn:Product>'+Label.B2B_Product_Code_Reman+'</urn:Product>' :  '<urn:Product>'+Label.B2B_Product_Code+'</urn:Product>';
                        // Saravanan LTIM Added for Sprint 2 Data Rules and US
                        }
                        body += '<urn:Quantity unitOfMeasure="EA">'+objCartItem.Quantity+'</urn:Quantity>';
                        body += '<urn:UnitPrice>'+objCartItem.UnitAdjustedPrice+'</urn:UnitPrice>';
                       	body += '<urn:ExtendedPrice>'+ objCartItem.TotalAmount +'</urn:ExtendedPrice>';                        
                        body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';                        
                    }
                    
                    if(shippingCharge != null){
                        i = i+1;
                        mapLineItem.put(i,'00006');
                        body += '<urn:LineItem lineItemNumber="'+i+'">';
                        body += '<urn:Seller> <urn:AdministrativeOrigin> <urn:StreetAddress1>';
                        body += dealerAddressMap.get('streetAddress') + '</urn:StreetAddress1>';
                        body += '<urn:City>'+dealerAddressMap.get('city')+'</urn:City>';
                        body += '<urn:MainDivision>'+dealerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+dealerAddressMap.get('postalCode')+'</urn:PostalCode> </urn:AdministrativeOrigin>';
                        body += '</urn:Seller>';
                        body += '<urn:Customer> <urn:Destination> <urn:StreetAddress1>'+customerAddressMap.get('streetAddress');
                        body += '</urn:StreetAddress1><urn:City>'+customerAddressMap.get('city')+'</urn:City>';
                        body += '<urn:MainDivision>'+customerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+customerAddressMap.get('postalCode')+'</urn:PostalCode>';
                        body += '</urn:Destination></urn:Customer>';
                        body += '<urn:Product>'+'00006'+'</urn:Product>';
                        body += '<urn:ExtendedPrice>'+shippingCharge+'</urn:ExtendedPrice>';
                        body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                    }
                    
                    if(String.isNotBlank(installationCharges)){
                        i = i+1;
                        mapLineItem.put(i,Label.B2B_Installation_Code);
                        body += '<urn:LineItem lineItemNumber="'+i+'">';
                        body += '<urn:Seller> <urn:AdministrativeOrigin>';                        
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
                        body += '</urn:Destination></urn:Customer>';
                        body += '<urn:Product>'+Label.B2B_Installation_Code+'</urn:Product>';
                        body += '<urn:ExtendedPrice>'+installationCharges+'</urn:ExtendedPrice>';
                        body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                    }
                }else {                    
                    //for full cancel and return
                    // Saravanan LTIM Added for Sprint 2 Vertex Data Rules Product_Type__c , Order.Product2.Core_Charge_Unit_Price__c                                    
                     for(OrderItem objOrderItem : [SELECT Id, Product2Id, Product2.StockKeepingUnit, Delta_Quantity__c, Return_Quantity__c, Updated_Quantity__c,  Product_Name__c, Quantity, ListPrice,Product_Type__c , Product2.Core_Charge_Unit_Price__c
                                             	  FROM OrderItem 
                                                  WHERE OrderId =: OrderId ORDER By Product_SKU__c]){
                        i = i+1;                                               
                        mapLineItem.put(i,objOrderItem.Product_type__c == Label.B2B_Product_Code_Core_Charges ? mapProductIdCoreChargeCartItemIds.get(objOrderItem.Product2Id).Id : mapProductIdCartItemIds.get(objOrderItem.Product2Id).Id); // Saravanan LTIM Modified for Core Charge Functionality
                        body += '<urn:LineItem lineItemNumber="'+i+'" vendorSKU="'+objOrderItem.Product2.StockKeepingUnit+'">';
                        body += '<urn:Seller> <urn:AdministrativeOrigin> <urn:StreetAddress1>';
                        body += dealerAddressMap.get('streetAddress') + '</urn:StreetAddress1>';
                        body += '<urn:City>'+dealerAddressMap.get('city')+'</urn:City>';
                        body += '<urn:MainDivision>'+dealerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+dealerAddressMap.get('postalCode')+'</urn:PostalCode> </urn:AdministrativeOrigin>';
                        body += '</urn:Seller>';
                        body += '<urn:Customer> <urn:Destination> <urn:StreetAddress1>'+customerAddressMap.get('streetAddress');
                        body += '</urn:StreetAddress1><urn:City>'+customerAddressMap.get('city')+'</urn:City>';
                        body += '<urn:MainDivision>'+customerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+customerAddressMap.get('postalCode')+'</urn:PostalCode>';
                        body += '</urn:Destination></urn:Customer>';
                        //Saravanan LTIM Added for Sprint 2 Data Rules and US
                        body += objOrderItem.Product_type__c == Label.B2B_Product_Code_Core_Charges ?  '<urn:Product>'+Label.B2B_Product_Code_Core_Charges+'</urn:Product>'  :  objOrderItem.Product2.Core_Charge_Unit_Price__c > 0  ? '<urn:Product>'+Label.B2B_Product_Code_Reman+'</urn:Product>' :  '<urn:Product>'+'00004'+'</urn:Product>';
                        // Saravanan LTIM Added for Sprint 2 Data Rules and US
                        body += '<urn:Quantity unitOfMeasure="EA">'+objOrderItem.Updated_Quantity__c+'</urn:Quantity>';
                        body += '<urn:UnitPrice>'+objOrderItem.ListPrice+'</urn:UnitPrice>';               
                        body += '<urn:ExtendedPrice>'+ -objOrderItem.ListPrice * objOrderItem.Updated_Quantity__c +'</urn:ExtendedPrice>';                    
                        body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';                                                   
                    }   
                    
                    if(shippingCharge != null && Decimal.valueOf(shippingCharge) != 0){
                        i = i+1;
                        mapLineItem.put(i,'00006');
                        body += '<urn:LineItem lineItemNumber="'+i+'">';
                        body += '<urn:Seller> <urn:AdministrativeOrigin> <urn:StreetAddress1>';
                        body += dealerAddressMap.get('streetAddress') + '</urn:StreetAddress1>';
                        body += '<urn:City>'+dealerAddressMap.get('city')+'</urn:City>';
                        body += '<urn:MainDivision>'+dealerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+dealerAddressMap.get('postalCode')+'</urn:PostalCode> </urn:AdministrativeOrigin>';
                        body += '</urn:Seller>';
                        body += '<urn:Customer> <urn:Destination> <urn:StreetAddress1>'+customerAddressMap.get('streetAddress');
                        body += '</urn:StreetAddress1><urn:City>'+customerAddressMap.get('city')+'</urn:City>';
                        body += '<urn:MainDivision>'+customerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+customerAddressMap.get('postalCode')+'</urn:PostalCode>';
                        body += '</urn:Destination></urn:Customer>';
                        body += '<urn:Product>'+'00006'+'</urn:Product>';
                        body += '<urn:ExtendedPrice>'+ -Decimal.valueOf(shippingCharge) +'</urn:ExtendedPrice>';
                        body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                    }
                    
                    if(String.isNotBlank(installationCharges) && Decimal.valueOf(installationCharges) != 0){
                        i = i+1;
                        mapLineItem.put(i,Label.B2B_Installation_Code);
                        body += '<urn:LineItem lineItemNumber="'+i+'">';
                        body += '<urn:Seller> <urn:AdministrativeOrigin>';                        
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
                        body += '</urn:Destination></urn:Customer>';
                        body += '<urn:Product>'+Label.B2B_Installation_Code+'</urn:Product>';
                        body += '<urn:ExtendedPrice>'+ -Decimal.valueOf(installationCharges)+'</urn:ExtendedPrice>';
                        body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                    }
                    
                }               
                
                if(methodName == 'quotation'){
                    body += '</urn:QuotationRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
                }else if(methodName == 'commit'){
                    body += '</urn:InvoiceRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
                }else if(methodName == 'return'){
                    body += '</urn:InvoiceRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
                }
                request.setBody(body); 
                responseWrapper.request = body;
                request.setEndpoint('callout:VertexNamedCredential'+ Label.B2B_Vertex_Path_URL);
                
                Long beforeAPI = B2B_Util.fetchCurrentTime();
                // Get Response
                HTTPResponse response = http.send(request);
                responseWrapper.response = response.getBody();
				if(response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
					DOM.Document doc = response.getBodyDocument();
					// Get Root Element which is 'Envelope'
					Dom.XMLNode rootElement = doc.getRootElement();
					String totalTaxAmount ='';
					String errorDescription = '';
                    Decimal installationTax = 0;
					List<CartItem> lstCartItem = New List<CartItem>();
					Vertex_Details__c objParentVertexDetails;
					List<Vertex_Details__c> lstChildVertexDetails = new  List<Vertex_Details__c>();
					List<OrderItem> lstUpdateOrderItem = new List<OrderItem>();
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
									for(Dom.XMLNode quotationResponseChild : quotationResponse.getChildElements()){
										//total tax for all line items
										if(quotationResponseChild.getName() == 'TotalTax'){
											totalTaxAmount = quotationResponseChild.getText();
											responseWrapper.isSuccess = true;
											responseWrapper.errorMessage = '';
											responseWrapper.totalTaxAmount = totalTaxAmount;
											
											//create cartTax record for total tax of all line Items                                                                      
											objParentVertexDetails = new Vertex_Details__c();
											objParentVertexDetails.B2B_Total_Tax__c = Decimal.valueOf(totalTaxAmount);
											objParentVertexDetails.B2B_Cart__c = cartId;
											objParentVertexDetails.Order__c = orderId;
											objParentVertexDetails.Customer__c = userId;
											objParentVertexDetails.documentNumber__c = cartId;
                                            objParentVertexDetails.Tax_Transaction_Date__c = System.now();
											
										}
										if(quotationResponseChild.getName() == 'LineItem'){
											
											B2B_BTVertexTaxCalculationIntegration.taxDetailForLineItem objInner = New B2B_BTVertexTaxCalculationIntegration.taxDetailForLineItem();
											String cartItemId = mapLineItem.get(Integer.valueOf(quotationResponseChild.getAttributeValue('lineItemNumber',null)));
											objInner.itemId = cartItemId;
											CartItem objCartItem;
											Vertex_Details__c objChildVertexDetails;
											OrderItem objOrderItem;
											if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code){
												objCartItem = New CartItem();
												objCartItem.Id = objInner.itemId;
												
												//get OrderItem from map
												objOrderItem = mapCartItemOrderItemIds.get(objCartItem.Id);
												if(methodName != 'return'){
													objOrderItem.Updated_Quantity__c = objOrderItem.Quantity;
													CartItem objCartItemFromMap = objOrderItem.Product_type__c == Label.B2B_Product_Code_Core_Charges ? mapProductIdCoreChargeCartItemIds.get(objOrderItem.Product2Id) :mapProductIdCartItemIds.get(objOrderItem.Product2Id);
													objOrderItem.Cart_Item_Product_Name__c =   objCartItemFromMap.Name;
													objOrderItem.Product_Model__c = objCartItemFromMap.Product_Model__c;//added by Yashika for 8708
                                                    objOrderItem.Product_Identifier__c = objCartItemFromMap.Product_Identifier__c;
                                                    objOrderItem.Product_Subdivision__c = objCartItemFromMap.Product_Subdivision__c;
                                                    objOrderItem.Product_Division__c = objCartItemFromMap.Product_Division__c;
                                                    objOrderItem.Color__c = objCartItemFromMap.Color__c;
                                                    objOrderItem.Product_Model_Marketing_Name__c = objCartItemFromMap.Product_Model_Marketing_Name__c;
													objOrderItem.Dealer_Installation_Price__c = objCartItemFromMap.Dealer_Installation_Price__c;		
                                                    objOrderItem.Op_Code__c = objCartItemFromMap.Op_Code__c;//Added by Rajrishi for 8705
												}                                           	
												//cartTax for line items
												objChildVertexDetails = new Vertex_Details__c();
												objChildVertexDetails.B2B_Cart__c = cartId;
												objChildVertexDetails.B2B_Cart_Item_Id__c =  objCartItem.Id;
												objChildVertexDetails.Order__c = orderId;
												objChildVertexDetails.OrderItem__c = objOrderItem.Id;
												objChildVertexDetails.Customer__c = userId;
												objChildVertexDetails.documentNumber__c = cartId;
                                                objChildVertexDetails.Tax_Transaction_Date__c = System.now();
											}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code){
												//cartTax for shipping
												objChildVertexDetails = new Vertex_Details__c();
												objChildVertexDetails.B2B_Cart__c = cartId;                                          
												objChildVertexDetails.Order__c = orderId;                   
												objChildVertexDetails.Customer__c = userId;
												objChildVertexDetails.documentNumber__c = cartId;  
												objChildVertexDetails.B2B_Cart_Item_Id__c = cartItemId;
                                                objChildVertexDetails.Tax_Transaction_Date__c = System.now();
											}
											
											for(Dom.XMLNode lineItemsNodes : quotationResponseChild.getChildElements()){                       
												if(lineItemsNodes.getName() == 'TotalTax'){
													objInner.totalItemTax = lineItemsNodes.getText();
													if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code){
														
														objChildVertexDetails.B2B_Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());  
														if(methodName != 'return'){
                                                            objCartItem.B2B_Item_Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());                                          
															objOrderItem.Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());
                                                            objOrderItem.Total_Current_Product_Tax__c = Decimal.valueOf(lineItemsNodes.getText());
														}
													}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code){
														objChildVertexDetails.B2B_Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());
                                                        if(cartItemId == Label.B2B_Installation_Code){
                                                            installationTax = Decimal.valueOf(lineItemsNodes.getText());
                                                        }
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
														if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code){
															objCartItem.B2B_StateTax__c = Decimal.valueOf(tax);
															objCartItem.B2B_StateTax_Rate__c = Decimal.valueOf(taxRate);
															
															//for CartTax
															// objChildVertexDetails.B2B_State_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_State_Tax_Rate__c = Decimal.valueOf(taxRate);
														}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code){
															//for CartTax
															// objChildVertexDetails.B2B_State_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_State_Tax_Rate__c = Decimal.valueOf(taxRate);
														}
													}
													else if(jdLevel == 'CITY'){
														objInner.cityTax = tax;
														objInner.cityTaxRate = taxRate;
														if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code){
															objCartItem.B2B_CityTax__c = Decimal.valueOf(tax);
															objCartItem.B2B_CityTax_Rate__c = Decimal.valueOf(taxRate);
															
															//for CartTax
															// objChildVertexDetails.B2B_City_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_City_Tax_Rate__c = Decimal.valueOf(taxRate);
														}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code){
															//for CartTax
															// objChildVertexDetails.B2B_City_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_City_Tax_Rate__c = Decimal.valueOf(taxRate);
														} 
													}else if(jdLevel == 'TRANSIT_DISTRICT'){
														objInner.transitDistrictTax = tax;
														objInner.transitDistrictTaxRate = taxRate; 
														if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code){
															objCartItem.B2B_TransitDistrictTax__c = Decimal.valueOf(tax);
															objCartItem.B2B_TransitDistrictTax_Rate__c = Decimal.valueOf(taxRate);
															
															//for CartTax
															// objChildVertexDetails.B2B_Transit_District_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_Transit_District_Tax_Rate__c = Decimal.valueOf(taxRate);
														}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code){
															//for CartTax
															// objChildVertexDetails.B2B_Transit_District_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_Transit_District_Tax_Rate__c = Decimal.valueOf(taxRate);
														} 
													}                                       
												}
											}
											if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code){
												lstChildVertexDetails.add(objChildVertexDetails);
												if(methodName != 'return'){
													lstUpdateOrderItem.add(objOrderItem);
												}                                                  
											}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code){
												lstChildVertexDetails.add(objChildVertexDetails);
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
                    
                    if(!lstUpdateOrderItem.isEmpty()){
                        update lstUpdateOrderItem;
                    }
                    
                    if(!lstOrders.isEmpty()){                        
                        lstOrders[0].Total_Installation_Tax__c = installationTax;
                        update lstOrders;
                    }
                    if(objParentVertexDetails != null) {                    
                        insert objParentVertexDetails;
                        List<Vertex_Details__c> lstVertaxDetails = new List<Vertex_Details__c>();
                        for(Vertex_Details__c objVertexDetails : lstChildVertexDetails){                      
                            objVertexDetails.Parent_Vertex_Details__c = objParentVertexDetails.Id;
                            lstVertaxDetails.add(objVertexDetails);
                        }
                        //insert the child cart tax records
                        if(!lstVertaxDetails.isEmpty()){
                            insert lstVertaxDetails;
                        }
                    }
                } else {
                    Long afterAPI = B2B_Util.fetchCurrentTime();
                    Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                    //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
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

                    Webcart cart = B2B_IntegrationUtility.getcartdetails(cartId);
                    String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(cart.ownerId);
                    Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', cart.DealerId__c, personAccountId, cartId, 'B2B_BTVertexTaxCalculationIntegration', String.valueOf(response.getStatusCode()), errorType, '', 'calculateTax', true, OrderId, '', '', durationTime, severity, 'Request:'+request.getBody(), 'Response:'+response.getBody());
                    //HDMP-8617: ends
                }
            }
        }catch(Exception Ex){
            responseWrapper.isSuccess = false;
            responseWrapper.errorMessage = ex.getMessage()+ ' Line Number '+ex.getLineNumber();
        }
        return responseWrapper;
    }
    
     @AuraEnabled
    public static ResponseDataWrapper calculateLineItemReturnTax(String cartId,Map<String,String> dealerAddressMap, Map<String,String> customerAddressMap, String dealerCode, String shippingCharge, String installationCharges, String restockingFees){
        ResponseDataWrapper responseWrapper =  New ResponseDataWrapper();       
        try{
            String OrderId;
            String userId = UserInfo.getUserId();
            if(dealerAddressMap.size() != 4 && customerAddressMap.size() != 4){
                responseWrapper.errorMessage = 'Please Provide Correct Addresses.';
                responseWrapper.isSuccess = false; 
                return responseWrapper;
            }else{        

                // Saravanan LTIM Added API For Sprint 2 Vertex Data Rules Product_Type__c,Product2.Core_Charge_Unit_Price__c
                List<WebCart> lstWebCarts = [SELECT Id,(SELECT Id FROM Orders__r) , 
                                             (SELECT Id,Quantity,unitadjustedPrice,TotalAmount,Product2Id,Dealer_Installation_Price__c,Product_Type__c,Product2.Core_Charge_Unit_Price__c FROM CartItems) 
                                             FROM WebCart 
                                             WHERE Id =:cartId];
                // Saravanan LTIM Added Variable for Core Charge DPrint 2 
                Map<String, string> mapProductIdCoreChargeCartItemIds = new Map<String, string>();
                //  Saravanan LTIM Added Variable for Core Charge DPrint 2                             
                Map<String, String> mapProductIdCartItemIds = new Map<String, String>();
                Map<String, String> mapCartItemOrderItemIds = new Map<String, String>();
                if(!lstWebCarts.isEmpty()){
                    OrderId = (lstWebCarts[0].Orders__r.isEmpty()) ? null : lstWebCarts[0].Orders__r[0].Id;
                    if(OrderId != null) {
                        // Saravanan LTIM Added for Sprint 2 Vertex Data Rules Product_Type__c , Order.Product2.Core_Charge_Unit_Price__c                                    

                        List<OrderItem> lstOrderItems = [SELECT Id, Product2Id, Dealer_Installation_Price__c, OrderId, Product_SKU__c, Product_Name__c, Quantity 
                                                         , Product_Type__c , Product2.Core_Charge_Unit_Price__c
                                                         FROM OrderItem 
                                                         WHERE OrderId =: OrderId];
                        if(lstOrderItems.isEmpty() == false && lstWebCarts[0].CartItems.isEmpty() == false){
                            
                            for(CartItem objCartItem : lstWebCarts[0].CartItems){
                                // Saravanan LTIM Added for Sprint 2 Vertex Data Rules if...else Conditions
                                if(objCartItem.Product_type__c == label.B2B_Product_Code_Core_Charges){
                                    mapProductIdCoreChargeCartItemIds.put(objCartItem.Product2Id, objCartItem.Id);  
                                }else{
                                    mapProductIdCartItemIds.put(objCartItem.Product2Id, objCartItem.Id);
                                }    
                            }
                            for(OrderItem objOrderItem : lstOrderItems){
                                // Saravanan LTIM Added for Sprint 2 Vertex Data Rules if Conditions
                                if(objOrderItem.Product_type__c == Label.B2B_Product_Code_Core_Charges){ 
                                    String cartItemId = mapProductIdCoreChargeCartItemIds.get(objOrderItem.Product2Id);
                                    mapCartItemOrderItemIds.put(cartItemId, objOrderItem.Id);
                                }else{
                                    String cartItemId = mapProductIdCartItemIds.get(objOrderItem.Product2Id);
                                    mapCartItemOrderItemIds.put(cartItemId, objOrderItem.Id); 
                                }
                            }
                        }	  
                    }                    
                }
               
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
                body += '<head:siteId>'+ Label.B2B_Fedex_SiteId +'</head:siteId>';
                body += '<head:businessId>'+Label.B2B_Fedex_BusinessId+'</head:businessId>';
                body += '<head:collectedTimestamp>'+datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'America/Los_Angeles')+'</head:collectedTimestamp>';
                body += '</head:hondaHeaderType>';
                body += '</soapenv:Header>';
                body += '<soapenv:Body> <urn:VertexEnvelope>';
                body += '<urn:Login><urn:UserName>'+Label.B2B_VertexUserName + '</urn:UserName><urn:Password>'+Label.B2B_VertexPassword+'</urn:Password></urn:Login>' ;
                String todayDate = String.valueOf(Date.Today());
                //R2C1 : change document number from cart id to order Id
                body += '<urn:InvoiceRequest documentDate="'+ todayDate +'" documentNumber="'+ OrderId + '" postingDate="'+ todayDate + '" transactionType="SALE">';
                body += '<urn:Seller> <urn:Company>'+'AHM Group'+'</urn:Company>';
                body += '<urn:Division>'+dealerCode+'</urn:Division> </urn:Seller>';
                Integer i = 0;
                List<OrderItem> lstUpdateOrderItems = new List<OrderItem>();
                // Saravanan LTIM Added for Sprint 2 Vertex Data Rules Product_Type__c , Order.Product2.Core_Charge_Unit_Price__c                                    
                for(OrderItem objOrderItem : [SELECT Id, Product2Id, Product2.StockKeepingUnit, Delta_Quantity__c, Return_Quantity__c, Updated_Quantity__c,  Product_Name__c, Quantity, ListPrice,Product_Type__c , Product2.Core_Charge_Unit_Price__c
                                              FROM OrderItem 
                                              WHERE OrderId =: OrderId 
                                              AND Delta_Quantity__c != 0 ORDER By Product_SKU__c]){
                  	i = i+1;                                               
                    mapLineItem.put(i,objOrderItem.Product_type__c == Label.B2B_Product_Code_Core_Charges ? mapProductIdCoreChargeCartItemIds.get(objOrderItem.Product2Id) : mapProductIdCartItemIds.get(objOrderItem.Product2Id)); // Saravanan LTIM Addded for Core Charge Functionality HDMP-18577
                    body += '<urn:LineItem lineItemNumber="'+i+'" vendorSKU="'+objOrderItem.Product2.StockKeepingUnit+'">';
                    body += '<urn:Seller> <urn:AdministrativeOrigin> <urn:StreetAddress1>';
                    body += dealerAddressMap.get('streetAddress') + '</urn:StreetAddress1>';
                    body += '<urn:City>'+dealerAddressMap.get('city')+'</urn:City>';
                    body += '<urn:MainDivision>'+dealerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                    body += '<urn:PostalCode>'+dealerAddressMap.get('postalCode')+'</urn:PostalCode> </urn:AdministrativeOrigin>';
                    body += '</urn:Seller>';
                    body += '<urn:Customer> <urn:Destination> <urn:StreetAddress1>'+customerAddressMap.get('streetAddress');
                    body += '</urn:StreetAddress1><urn:City>'+customerAddressMap.get('city')+'</urn:City>';
                    body += '<urn:MainDivision>'+customerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                    body += '<urn:PostalCode>'+customerAddressMap.get('postalCode')+'</urn:PostalCode>';
                    body += '</urn:Destination></urn:Customer>';
                    if(objOrderItem.Product_Name__c=='Motocompacto'){
                        body += '<urn:Product>'+label.motocompacto_code+'</urn:Product>';  
                    }  else{
                    //Saravanan LTIM Added for Sprint 2 Data Rules and US
                    body += objOrderItem.Product_type__c == Label.B2B_Product_Code_Core_Charges ?  '<urn:Product>'+Label.B2B_Product_Code_Core_Charges+'</urn:Product>'  :  objOrderItem.Product2.Core_Charge_Unit_Price__c > 0  ? '<urn:Product>'+Label.B2B_Product_Code_Reman+'</urn:Product>' :  '<urn:Product>'+'00004'+'</urn:Product>';
                    // Saravanan LTIM Added for Sprint 2 Data Rules and US
                    }            
                    body += '<urn:Quantity unitOfMeasure="EA">'+objOrderItem.Delta_Quantity__c+'</urn:Quantity>';
                    body += '<urn:UnitPrice>'+objOrderItem.ListPrice+'</urn:UnitPrice>';                 
                    body += '<urn:ExtendedPrice>'+ -objOrderItem.ListPrice * objOrderItem.Delta_Quantity__c +'</urn:ExtendedPrice>';                    
                    body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';  
                    objOrderItem.Delta_Quantity__c = 0;
                   	lstUpdateOrderItems.add(objOrderItem);                             
                }
                
                if(shippingCharge != null){
                        i = i+1;
                        mapLineItem.put(i,'00006');
                        body += '<urn:LineItem lineItemNumber="'+i+'">';
                        body += '<urn:Seller> <urn:AdministrativeOrigin> <urn:StreetAddress1>';
                        body += dealerAddressMap.get('streetAddress') + '</urn:StreetAddress1>';
                        body += '<urn:City>'+dealerAddressMap.get('city')+'</urn:City>';
                        body += '<urn:MainDivision>'+dealerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+dealerAddressMap.get('postalCode')+'</urn:PostalCode> </urn:AdministrativeOrigin>';
                        body += '</urn:Seller>';
                        body += '<urn:Customer> <urn:Destination> <urn:StreetAddress1>'+customerAddressMap.get('streetAddress');
                        body += '</urn:StreetAddress1><urn:City>'+customerAddressMap.get('city')+'</urn:City>';
                        body += '<urn:MainDivision>'+customerAddressMap.get('mainDivision')+'</urn:MainDivision>';
                        body += '<urn:PostalCode>'+customerAddressMap.get('postalCode')+'</urn:PostalCode>';
                        body += '</urn:Destination></urn:Customer>';
                        body += '<urn:Product>'+'00006'+'</urn:Product>';
                        body += '<urn:ExtendedPrice>'+ -Decimal.valueOf(shippingCharge) +'</urn:ExtendedPrice>';
                        body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                }
                
                if(String.isNotBlank(installationCharges)){
                    i = i+1;
                    mapLineItem.put(i,Label.B2B_Installation_Code);
                    body += '<urn:LineItem lineItemNumber="'+i+'">';
                    body += '<urn:Seller> <urn:AdministrativeOrigin>';                        
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
                    body += '</urn:Destination></urn:Customer>';
                    body += '<urn:Product>'+Label.B2B_Installation_Code+'</urn:Product>';
                    body += '<urn:ExtendedPrice>'+ -Decimal.valueOf(installationCharges)+'</urn:ExtendedPrice>';
                    body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                }
                
                if(String.isNotBlank(restockingFees)){
                    i = i+1;
                    mapLineItem.put(i,Label.B2B_Restocking_Code);
                    body += '<urn:LineItem lineItemNumber="'+i+'">';
                    body += '<urn:Seller> <urn:AdministrativeOrigin>';                        
                    body += '<urn:StreetAddress1>'+dealerAddressMap.get(B2B_IntegrationConstants.STREETADDRESS) + '</urn:StreetAddress1>';
                    body += '<urn:City>'+dealerAddressMap.get(B2B_IntegrationConstants.CITY)+'</urn:City>';
                    body += '<urn:MainDivision>'+dealerAddressMap.get(B2B_IntegrationConstants.STATE)+'</urn:MainDivision>';
                    body += '<urn:PostalCode>'+dealerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>';
                    body += ' </urn:AdministrativeOrigin></urn:Seller>';
                    body += '<urn:Customer> <urn:Destination>';
                    //Start of HDMP- 9851 customerAddressMap replaced with dealerAddressMap
                    body += '<urn:StreetAddress1>'+dealerAddressMap.get(B2B_IntegrationConstants.STREETADDRESS)+'</urn:StreetAddress1>';
                    body += '<urn:City>'+dealerAddressMap.get(B2B_IntegrationConstants.CITY)+'</urn:City>';
                    body += '<urn:MainDivision>'+dealerAddressMap.get(B2B_IntegrationConstants.STATE)+'</urn:MainDivision>';
                    body += '<urn:PostalCode>'+dealerAddressMap.get(B2B_IntegrationConstants.POSTALCODE)+'</urn:PostalCode>'; 
                    // End of HDMP- 9851
                    body += '</urn:Destination></urn:Customer>';
                    body += '<urn:Product>'+Label.B2B_Restocking_Code+'</urn:Product>';
                    body += '<urn:ExtendedPrice>'+ Decimal.valueOf(restockingFees)+'</urn:ExtendedPrice>';
                    body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                }
                
                body += '</urn:InvoiceRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';
                request.setBody(body);  
                request.setEndpoint('callout:VertexNamedCredential'+ Label.B2B_Vertex_Path_URL);
                responseWrapper.request = request.getbody();
                
                Long beforeAPI = B2B_Util.fetchCurrentTime();
                // Get Response
                HTTPResponse response = http.send(request);
                System.debug('response of Vertex :'+JSON.serialize(response.getBody()));
                if(response.getStatusCode() == B2B_IntegrationConstants.STATUSCODE){
					DOM.Document doc = response.getBodyDocument();
					// Get Root Element which is 'Envelope'
					Dom.XMLNode rootElement = doc.getRootElement();
					String totalTaxAmount ='';
					String errorDescription = '';
					List<CartItem> lstCartItem = New List<CartItem>();
					Vertex_Details__c objParentVertexDetails;
					List<Vertex_Details__c> lstChildVertexDetails = new  List<Vertex_Details__c>();
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
								if(vertexEnvelopeNode.getChildElement('InvoiceResponse','urn:vertexinc:o-series:tps:9:0') != null){
									quotationResponse =  vertexEnvelopeNode.getChildElement('InvoiceResponse','urn:vertexinc:o-series:tps:9:0');
								}
								if(quotationResponse != null){
									for(Dom.XMLNode quotationResponseChild : quotationResponse.getChildElements()){
										//total tax for all line items
										if(quotationResponseChild.getName() == 'TotalTax'){
											totalTaxAmount = quotationResponseChild.getText();
											responseWrapper.isSuccess = true;
											responseWrapper.errorMessage = '';
											responseWrapper.totalTaxAmount = totalTaxAmount;
											
											//create cartTax record for total tax of all line Items                                                                      
											objParentVertexDetails = new Vertex_Details__c();
											objParentVertexDetails.B2B_Total_Tax__c = Decimal.valueOf(totalTaxAmount);
											objParentVertexDetails.B2B_Cart__c = cartId;
											objParentVertexDetails.Order__c = orderId;
											objParentVertexDetails.Customer__c = userId;
											objParentVertexDetails.documentNumber__c = cartId;
                                            objParentVertexDetails.Tax_Transaction_Date__c = System.now();
											
										}
										if(quotationResponseChild.getName() == 'LineItem'){
											
											B2B_BTVertexTaxCalculationIntegration.taxDetailForLineItem objInner = New B2B_BTVertexTaxCalculationIntegration.taxDetailForLineItem();
											String cartItemId = mapLineItem.get(Integer.valueOf(quotationResponseChild.getAttributeValue('lineItemNumber',null)));
											objInner.itemId = cartItemId;
											CartItem objCartItem;
											Vertex_Details__c objChildVertexDetails;
											if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code && cartItemId != Label.B2B_Restocking_Code){
												objCartItem = New CartItem();
												objCartItem.Id = objInner.itemId;
												//cartTax for line items
												objChildVertexDetails = new Vertex_Details__c();
												objChildVertexDetails.B2B_Cart__c = cartId;
												objChildVertexDetails.B2B_Cart_Item_Id__c =  objCartItem.Id;
												objChildVertexDetails.Order__c = orderId;
												objChildVertexDetails.OrderItem__c = mapCartItemOrderItemIds.get(objCartItem.Id);
												objChildVertexDetails.Customer__c = userId;
												objChildVertexDetails.documentNumber__c = cartId;  
                                                objChildVertexDetails.Tax_Transaction_Date__c = System.now();
											}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code || cartItemId == Label.B2B_Restocking_Code){
												//cartTax for shipping
												objChildVertexDetails = new Vertex_Details__c();
												objChildVertexDetails.B2B_Cart__c = cartId;                                          
												objChildVertexDetails.Order__c = orderId;                   
												objChildVertexDetails.Customer__c = userId;
												objChildVertexDetails.documentNumber__c = cartId;  
												objChildVertexDetails.B2B_Cart_Item_Id__c = cartItemId;
                                                objChildVertexDetails.Tax_Transaction_Date__c = System.now();
											}
											
											for(Dom.XMLNode lineItemsNodes : quotationResponseChild.getChildElements()){                       
												if(lineItemsNodes.getName() == 'TotalTax'){
													objInner.totalItemTax = lineItemsNodes.getText();
													if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code && cartItemId != Label.B2B_Restocking_Code){
														objChildVertexDetails.B2B_Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());                                         
													}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code || cartItemId == Label.B2B_Restocking_Code){
														objChildVertexDetails.B2B_Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText()); 
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
														if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code && cartItemId != Label.B2B_Restocking_Code){
															objCartItem.B2B_StateTax__c = Decimal.valueOf(tax);
															objCartItem.B2B_StateTax_Rate__c = Decimal.valueOf(taxRate);
															
															//for CartTax
															// objChildVertexDetails.B2B_State_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_State_Tax_Rate__c = Decimal.valueOf(taxRate);
														}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code || cartItemId == Label.B2B_Restocking_Code){
															//for CartTax
															// objChildVertexDetails.B2B_State_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_State_Tax_Rate__c = Decimal.valueOf(taxRate);
														}
													}
													else if(jdLevel == 'CITY'){
														objInner.cityTax = tax;
														objInner.cityTaxRate = taxRate;
														if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code && cartItemId != Label.B2B_Restocking_Code){
															objCartItem.B2B_CityTax__c = Decimal.valueOf(tax);
															objCartItem.B2B_CityTax_Rate__c = Decimal.valueOf(taxRate);
															
															//for CartTax
															// objChildVertexDetails.B2B_City_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_City_Tax_Rate__c = Decimal.valueOf(taxRate);
														}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code || cartItemId == Label.B2B_Restocking_Code){
															//for CartTax
															// objChildVertexDetails.B2B_City_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_City_Tax_Rate__c = Decimal.valueOf(taxRate);
														} 
													}else if(jdLevel == 'TRANSIT_DISTRICT'){
														objInner.transitDistrictTax = tax;
														objInner.transitDistrictTaxRate = taxRate; 
														if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code && cartItemId != Label.B2B_Restocking_Code){
															objCartItem.B2B_TransitDistrictTax__c = Decimal.valueOf(tax);
															objCartItem.B2B_TransitDistrictTax_Rate__c = Decimal.valueOf(taxRate);
															
															//for CartTax
															// objChildVertexDetails.B2B_Transit_District_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_Transit_District_Tax_Rate__c = Decimal.valueOf(taxRate);
														}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code || cartItemId == Label.B2B_Restocking_Code){
															//for CartTax
															// objChildVertexDetails.B2B_Transit_District_Tax__c = Decimal.valueOf(tax);
															// objChildVertexDetails.B2B_Transit_District_Tax_Rate__c = Decimal.valueOf(taxRate);
														} 
													}                                                                                    
												}
											}
											if(cartItemId != Label.B2B_Shipping_Code && cartItemId != Label.B2B_Installation_Code && cartItemId != Label.B2B_Restocking_Code){
												lstChildVertexDetails.add(objChildVertexDetails);
											}else if(cartItemId == Label.B2B_Shipping_Code || cartItemId == Label.B2B_Installation_Code || cartItemId == Label.B2B_Restocking_Code){
												lstChildVertexDetails.add(objChildVertexDetails);
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
				
                    if(!lstCartItem.isEmpty() && !Test.isRunningTest()){
                        update lstCartItem;
                    } 
                    if(objParentVertexDetails != null) {                    
                        insert objParentVertexDetails;
                        List<Vertex_Details__c> lstVertaxDetails = new List<Vertex_Details__c>();
                        for(Vertex_Details__c objVertexDetails : lstChildVertexDetails){                      
                            objVertexDetails.Parent_Vertex_Details__c = objParentVertexDetails.Id;
                            lstVertaxDetails.add(objVertexDetails);
                        }
                        //insert the child cart tax records
                        if(!lstVertaxDetails.isEmpty()){
                            insert lstVertaxDetails;
                            responseWrapper.lstVertexDetails = lstVertaxDetails;
                        }
                    }
                    if(!lstUpdateOrderItems.isEmpty() && responseWrapper.isSuccess == true){
                        update lstUpdateOrderItems;
                    }               	
                } else {
                    Long afterAPI = B2B_Util.fetchCurrentTime();
                    Long durationTime = B2B_Util.calInMilliSeconds(beforeAPI, afterAPI);
                    //HDMP-8617- Below lines of code added to handle,insert and trigger email to support team: starts
                    
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
                    Webcart cart = B2B_IntegrationUtility.getcartdetails(cartId);
                    String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(cart.ownerId);
                    Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', cart.DealerId__c, personAccountId, cartId, 'B2B_BTVertexTaxCalculationIntegration', String.valueOf(response.getStatusCode()), errorType, '', 'calculateLineItemReturnTax', true, OrderId, '', '', durationTime, severity, 'Request:'+request.getBody(), 'Response:'+response.getBody());
                }
                //HDMP-8617:ends
            }
        }catch(Exception Ex){
            responseWrapper.isSuccess = false;
            responseWrapper.errorMessage = ex.getMessage()+ ' Line Number '+ex.getLineNumber();
        }
        return responseWrapper;
    }

    public class ResponseDataWrapper{
        public String responseCode;
        public String errorMessage;
        public Boolean isSuccess;
        public String totalTaxAmount ;
        public List<Vertex_Details__c> lstVertexDetails;
        public String request;
        public String response;
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

    // Saravanan LTIM Added this method for Bug HDMP-18902 , HDMP-1891
    @AuraEnabled
    Public static Boolean getStatusofVertex(){
       try{ 
            ResponseDataWrapper responseWrapper =  New ResponseDataWrapper();  
            Map<Integer,String> mapLineItem = New Map<Integer,String>();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String guId = B2B_Util.createGui();
            request.setHeader('Content-Type', 'text/xml');
            request.setMethod('POST');

            // Creating Request Body
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
            body += '</urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';

            request.setBody(body); 
            responseWrapper.request = body;
            request.setEndpoint('callout:VertexNamedCredential'+ Label.B2B_Vertex_Path_URL);
            // Get Response
            HTTPResponse response = http.send(request);
            system.debug('response status code---'+response.getStatusCode());

            if(response.getStatusCode() == 200){
                return true; // actual value should be true
            }
            

            return false;
        }
        catch(Exception ex){
            return false;
        }
    }
    
}
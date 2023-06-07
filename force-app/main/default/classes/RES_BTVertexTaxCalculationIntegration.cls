/**********************************************************************
Name: RES_BTVertexTaxCalculationIntegration
Purpose: For calculating taxes from vertex.
Date : 27/06/2021
Created By : Rajrishi Kaushik
*************************************************************/

Public class RES_BTVertexTaxCalculationIntegration{
    @AuraEnabled
    public static ResponseDataWrapper calculateTax(String cartId,Map<String,String> dealerAddressMap, Map<String,String> customerAddressMap,String dealerCode,String shippingCharge,String methodName){
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
                List<Order> lstOrders = new List<Order>();
                List<WebCart> lstWebCarts = [SELECT Id,(SELECT Id FROM Orders__r) ,
                                             (SELECT Id, Name,Quantity,unitadjustedPrice,TotalAmount,Product2Id FROM CartItems)
                                             FROM WebCart
                                             WHERE Id =:cartId];
                Map<String, OrderItem> mapCartItemOrderItemIds = new Map<String, OrderItem>();
                System.Debug('lstWebCarts : ' +lstWebCarts);
                if(!lstWebCarts.isEmpty()){
                    OrderId = (lstWebCarts[0].Orders__r.isEmpty()) ? null : lstWebCarts[0].Orders__r[0].Id;
                    if(OrderId != null) {
                        if(methodName != 'return'){
                            // populating order amount fields
                            Order objOrder = [SELECT Id, Updated_Order_Total__c, Updated_Total_Tax__c, Updated_Order_Amount__c, ORDER_AMOUNT_from_cart__c, SHIPPING_from_cart__c, TAX_from_cart__c, TOTAL_from_cart__c
                                              FROM Order
                                              WHERE Id =: OrderId LIMIT 1];
                            objOrder.Updated_Order_Total__c = objOrder.TOTAL_from_cart__c;
                            objOrder.Updated_Total_Tax__c = objOrder.TAX_from_cart__c;
                            objOrder.Updated_Order_Amount__c = objOrder.ORDER_AMOUNT_from_cart__c;
                            //added on 20/08/2021
                            objOrder.Vertex_Trans_Id__c = cartId;
                            lstOrders.add(objOrder);
                        }
                        List<OrderItem> lstOrderItems = [SELECT Id, Product2Id, Updated_Quantity__c, Cart_Item_Product_Name__c, OrderId, Product_SKU__c, Product_Name__c, Quantity FROM OrderItem where OrderId =: OrderId];
                        if(lstOrderItems.isEmpty() == false && lstWebCarts[0].CartItems.isEmpty() == false){
                            for(CartItem objCartItem : lstWebCarts[0].CartItems){
                                mapProductIdCartItemIds.put(objCartItem.Product2Id, objCartItem);
                            }
                            System.debug('mapProductIdCartItemIds : '+ mapProductIdCartItemIds);
                            for(OrderItem objOrderItem : lstOrderItems){
                                CartItem objCartItem = mapProductIdCartItemIds.get(objOrderItem.Product2Id);
                                mapCartItemOrderItemIds.put(objCartItem.Id, objOrderItem);
                            }
                            System.debug('mapCartItemOrderItemIds : '+ mapCartItemOrderItemIds);
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
                if(methodName != 'return'){
                    for(CartItem objCartItem : [SELECT Id,Quantity,unitadjustedPrice,TotalAmount,Product2.StockKeepingUnit
                                                FROM CartItem WHERE cartId =:cartId]){
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
                        body += '<urn:Product>'+'00004'+'</urn:Product>';
                        body += '<urn:Quantity unitOfMeasure="EA">'+objCartItem.Quantity+'</urn:Quantity>';
                        body += '<urn:UnitPrice>'+objCartItem.UnitAdjustedPrice+'</urn:UnitPrice>';
                        System.debug('---Total Amount-- '+objCartItem.TotalAmount);
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
                        System.debug('ShippingChargeValue'+shippingCharge);
                        body += '<urn:ExtendedPrice>'+shippingCharge+'</urn:ExtendedPrice>';
                        body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                    }
                }else {
                    //for full cancel and return
                    for(OrderItem objOrderItem : [SELECT Id, Product2Id, Product2.StockKeepingUnit, Delta_Quantity__c, Return_Quantity__c, Updated_Quantity__c, Order_Item_Status__c, Product_Name__c, Quantity, UnitPrice
                                             	  FROM OrderItem WHERE OrderId =: OrderId]){
                        i = i+1;
                        mapLineItem.put(i,mapProductIdCartItemIds.get(objOrderItem.Product2Id).Id);
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
                        body += '<urn:Product>'+'00004'+'</urn:Product>';
                        body += '<urn:Quantity unitOfMeasure="EA">'+objOrderItem.Updated_Quantity__c+'</urn:Quantity>';
                        body += '<urn:UnitPrice>'+objOrderItem.UnitPrice+'</urn:UnitPrice>';
                        System.debug('---Total Amount-- '+objOrderItem.UnitPrice);
                        body += '<urn:ExtendedPrice>'+ -objOrderItem.UnitPrice * objOrderItem.Updated_Quantity__c +'</urn:ExtendedPrice>';
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
                System.debug('==RequestBody=='+body);
                request.setBody(body);
                request.setEndpoint('callout:VertexNamedCredential'+ Label.B2B_Vertex_Path_URL);
                //String usernamePassword = Label.B2B_Vertex_HDM_Username +':'+Label.B2B_Vertex_HDM_Password ;
                //String authorizationString = EncodingUtil.base64Encode(Blob.valueof(usernamePassword));
                //request.setHeader('Authorization', 'Basic '+authorizationString);

                // Get Response
                HTTPResponse response = http.send(request);
                //System.debug('testResponse'+response.getBody());
                DOM.Document doc = response.getBodyDocument();
                // Get Root Element which is 'Envelope'
                Dom.XMLNode rootElement = doc.getRootElement();
                System.debug('---RootElementName---'+rootElement.getName());
                String totalTaxAmount ='';
                String errorDescription = '';
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
                                // Dom.XMLNode quotationResponse =  vertexEnvelopeNode.getChildElement('QuotationResponse','urn:vertexinc:o-series:tps:9:0');
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

                                    }
                                    if(quotationResponseChild.getName() == 'LineItem'){

                                        RES_BTVertexTaxCalculationIntegration.taxDetailForLineItem objInner = New RES_BTVertexTaxCalculationIntegration.taxDetailForLineItem();
                                        String cartItemId = mapLineItem.get(Integer.valueOf(quotationResponseChild.getAttributeValue('lineItemNumber',null)));
                                        objInner.itemId = cartItemId;
                                        CartItem objCartItem;
                                        Vertex_Details__c objChildVertexDetails;
                                        OrderItem objOrderItem;
                                        if(cartItemId != Label.B2B_Shipping_Code){
                                            objCartItem = New CartItem();
                                            objCartItem.Id = objInner.itemId;

                                            //get OrderItem from map
                                            objOrderItem = mapCartItemOrderItemIds.get(objCartItem.Id);
                                            if(methodName != 'return'){
                                                objOrderItem.Updated_Quantity__c = objOrderItem.Quantity;
                                                CartItem objCartItemFromMap = mapProductIdCartItemIds.get(objOrderItem.Product2Id);
                                                objOrderItem.Cart_Item_Product_Name__c = objCartItemFromMap.Name;
                                            }
                                            //cartTax for line items
                                            objChildVertexDetails = new Vertex_Details__c();
                                            objChildVertexDetails.B2B_Cart__c = cartId;
                                            objChildVertexDetails.B2B_Cart_Item_Id__c =  objCartItem.Id;
                                            objChildVertexDetails.Order__c = orderId;
                                            objChildVertexDetails.OrderItem__c = objOrderItem.Id;
                                            objChildVertexDetails.Customer__c = userId;
                                            objChildVertexDetails.documentNumber__c = cartId;
                                        }

                                        for(Dom.XMLNode lineItemsNodes : quotationResponseChild.getChildElements()){
                                            if(lineItemsNodes.getName() == 'TotalTax'){
                                                objInner.totalItemTax = lineItemsNodes.getText();
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                    objCartItem.B2B_Item_Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());
                                                    objChildVertexDetails.B2B_Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());
                                                    if(methodName != 'return'){
                                                    	objOrderItem.Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());
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
                                                    if(cartItemId != Label.B2B_Shipping_Code){
                                                        objCartItem.B2B_StateTax__c = Decimal.valueOf(tax);
                                                        objCartItem.B2B_StateTax_Rate__c = Decimal.valueOf(taxRate);

                                                        //for CartTax
                                                        objChildVertexDetails.B2B_State_Tax__c = Decimal.valueOf(tax);
                                                        objChildVertexDetails.B2B_State_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                    }
                                                }
                                                else if(jdLevel == 'CITY'){
                                                    objInner.cityTax = tax;
                                                    objInner.cityTaxRate = taxRate;
                                                    if(cartItemId != Label.B2B_Shipping_Code){
                                                        objCartItem.B2B_CityTax__c = Decimal.valueOf(tax);
                                                        objCartItem.B2B_CityTax_Rate__c = Decimal.valueOf(taxRate);

                                                        //for CartTax
                                                        objChildVertexDetails.B2B_City_Tax__c = Decimal.valueOf(tax);
                                                        objChildVertexDetails.B2B_City_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                    }
                                                }else if(jdLevel == 'TRANSIT_DISTRICT'){
                                                    objInner.transitDistrictTax = tax;
                                                    objInner.transitDistrictTaxRate = taxRate;
                                                    if(cartItemId != Label.B2B_Shipping_Code){
                                                        objCartItem.B2B_TransitDistrictTax__c = Decimal.valueOf(tax);
                                                        objCartItem.B2B_TransitDistrictTax_Rate__c = Decimal.valueOf(taxRate);

                                                        //for CartTax
                                                        objChildVertexDetails.B2B_Transit_District_Tax__c = Decimal.valueOf(tax);
                                                        objChildVertexDetails.B2B_Transit_District_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                    }
                                                }
                                                /*else if(jdLevel == 'APO'){
                                                objInner.apoTax = tax;
                                                objInner.apoTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_APO_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Apo_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'BOROUGH'){
                                                objInner.broughTax = tax;
                                                objInner.broughTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Borough_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Borough_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'COUNTY'){
                                                objInner.countyTax = tax;
                                                objInner.countyTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_County_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_County_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'COUNTRY'){
                                                objInner.coutryTax = tax;
                                                objInner.countryTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_County_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_County_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'DISTRICT'){
                                                objInner.districtTax = tax;
                                                objInner.districtTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_District_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_District_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'FPO'){
                                                objInner.fpoTax = tax;
                                                objInner.fpoTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Fpo_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Fpo_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'LOCAL_IMPROVEMENT_DISTRICT'){
                                                objInner.localImprovementDistrictTax = tax;
                                                objInner.localImprovementDistrictTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Local_Improvement_district_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Local_Improvement_District_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'PARISH'){
                                                objInner.parishTax = tax;
                                                objInner.parishTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Parish_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Parish_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'PROVINCE'){
                                                objInner.provinceTax = tax;
                                                objInner.provinceTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Province_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Province_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'SPECIAL_PURPOSE_DISTRICT'){
                                                objInner.specialPurposeDistrictTax = tax;
                                                objInner.specialPurposeDistrictTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Special_Purpose_District_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Special_Purpose_District_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'TERRITORY'){
                                                objInner.territoryTax = tax;
                                                objInner.territoryTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Territory_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Territory_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'TOWNSHIP'){
                                                objInner.townshipTax = tax;
                                                objInner.townshipTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Township_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Township_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'TRADE_BLOCK'){
                                                objInner.tradeBlockTax = tax;
                                                objInner.tradeBlockTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Trade_Block_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Trade_Block_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }*/
                                            }
                                        }
                                        if(cartItemId != Label.B2B_Shipping_Code){
                                            lstChildVertexDetails.add(objChildVertexDetails);
                                            if(methodName != 'return'){
                                            	lstUpdateOrderItem.add(objOrderItem);
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

                if(!lstUpdateOrderItem.isEmpty()){
                    update lstUpdateOrderItem;
                }

                if(!lstOrders.isEmpty()){
                    update lstOrders;
                }

                System.debug('lstUpdateOrderItem'+ lstUpdateOrderItem);
                System.debug('objParentVertexDetails 1'+ objParentVertexDetails);
                System.debug('lstChildVertexDetails '+ lstChildVertexDetails);
                //added by Rajrishi on 28/07/2021
                if(objParentVertexDetails != null) {
                    insert objParentVertexDetails;
                    System.debug('parentCartTax '+ objParentVertexDetails);

                    List<Vertex_Details__c> lstVertaxDetails = new List<Vertex_Details__c>();
                    for(Vertex_Details__c objVertexDetails : lstChildVertexDetails){
                        objVertexDetails.Parent_Vertex_Details__c = objParentVertexDetails.Id;
                        lstVertaxDetails.add(objVertexDetails);
                    }
                    System.debug('lstCartTax '+ lstVertaxDetails);
                    //insert the child cart tax records
                    if(!lstVertaxDetails.isEmpty()){
                        insert lstVertaxDetails;
                    }
                }

                System.debug('--TaxCalculated ===> '+totalTaxAmount);
            }
        }catch(Exception Ex){
            responseWrapper.isSuccess = false;
            responseWrapper.errorMessage = ex.getMessage()+ ' Line Number '+ex.getLineNumber();
            System.debug('Exception : '+ ex.getMessage() + ' Line Number '+ex.getLineNumber());
        }
        System.debug('ResponseFromServer'+JSON.serialize(responseWrapper));
        return responseWrapper;
    }

     @AuraEnabled
    public static ResponseDataWrapper calculateLineItemReturnTax(String cartId,Map<String,String> dealerAddressMap, Map<String,String> customerAddressMap,String dealerCode){
        ResponseDataWrapper responseWrapper =  New ResponseDataWrapper();
        try{
            String OrderId;
            String userId = UserInfo.getUserId();
            if(dealerAddressMap.size() != 4 && customerAddressMap.size() != 4){
                responseWrapper.errorMessage = 'Please Provide Correct Addresses.';
                responseWrapper.isSuccess = false;
                return responseWrapper;
            }else{
                List<WebCart> lstWebCarts = [SELECT Id,(SELECT Id FROM Orders__r) ,
                                             (SELECT Id,Quantity,unitadjustedPrice,TotalAmount,Product2Id FROM CartItems)
                                             FROM WebCart
                                             WHERE Id =:cartId];
                Map<String, String> mapProductIdCartItemIds = new Map<String, String>();
                Map<String, String> mapCartItemOrderItemIds = new Map<String, String>();
                System.Debug('lstWebCarts : ' +lstWebCarts);
                if(!lstWebCarts.isEmpty()){
                    OrderId = (lstWebCarts[0].Orders__r.isEmpty()) ? null : lstWebCarts[0].Orders__r[0].Id;
                    if(OrderId != null) {
                        List<OrderItem> lstOrderItems = [SELECT Id, Product2Id, OrderId, Product_SKU__c, Product_Name__c, Quantity FROM OrderItem where OrderId =: OrderId];
                        if(lstOrderItems.isEmpty() == false && lstWebCarts[0].CartItems.isEmpty() == false){

                            for(CartItem objCartItem : lstWebCarts[0].CartItems){
                                mapProductIdCartItemIds.put(objCartItem.Product2Id, objCartItem.Id);
                            }
                            System.debug('mapProductIdCartItemIds : '+ mapProductIdCartItemIds);
                            for(OrderItem objOrderItem : lstOrderItems){
                                String cartItemId = mapProductIdCartItemIds.get(objOrderItem.Product2Id);
                                mapCartItemOrderItemIds.put(cartItemId, objOrderItem.Id);
                            }
                            System.debug('mapCartItemOrderItemIds : '+ mapCartItemOrderItemIds);
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
                //body += '<head:messageId>'+Label.B2B_Fedex_MessageId+'</head:messageId>';
                body += '<head:siteId>'+ Label.B2B_Fedex_SiteId +'</head:siteId>';
                body += '<head:businessId>'+Label.B2B_Fedex_BusinessId+'</head:businessId>';
                body += '<head:collectedTimestamp>'+datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX', 'America/Los_Angeles')+'</head:collectedTimestamp>';
                body += '</head:hondaHeaderType>';
                body += '</soapenv:Header>';
                body += '<soapenv:Body> <urn:VertexEnvelope>';
                body += '<urn:Login><urn:UserName>'+Label.B2B_VertexUserName + '</urn:UserName><urn:Password>'+Label.B2B_VertexPassword+'</urn:Password></urn:Login>' ;
                String todayDate = String.valueOf(Date.Today());
                body += '<urn:InvoiceRequest documentDate="'+ todayDate +'" documentNumber="'+ cartId + '" postingDate="'+ todayDate + '" transactionType="SALE">';
                //body += '<urn:QuotationRequest documentDate="2021-02-19" postingDate="2021-02-19" transactionType="SALE">';
                body += '<urn:Seller> <urn:Company>'+'AHM Group'+'</urn:Company>';
                body += '<urn:Division>'+dealerCode+'</urn:Division> </urn:Seller>';
                Integer i = 0;
                List<OrderItem> lstUpdateOrderItems = new List<OrderItem>();
                for(OrderItem objOrderItem : [SELECT Id, Product2Id, Current_Return_Quantity__c, Product2.StockKeepingUnit, Delta_Quantity__c, Return_Quantity__c, Updated_Quantity__c, Order_Item_Status__c, Product_Name__c, Quantity, UnitPrice
                                             FROM OrderItem WHERE OrderId =: OrderId AND Delta_Quantity__c != 0]){
                  	i = i+1;
                    mapLineItem.put(i,mapProductIdCartItemIds.get(objOrderItem.Product2Id));
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
                    body += '<urn:Product>'+'00004'+'</urn:Product>';
                    body += '<urn:Quantity unitOfMeasure="EA">'+objOrderItem.Delta_Quantity__c+'</urn:Quantity>';
                    body += '<urn:UnitPrice>'+objOrderItem.UnitPrice+'</urn:UnitPrice>';
                    System.debug('---Total Amount-- '+objOrderItem.UnitPrice);
                    body += '<urn:ExtendedPrice>'+ -objOrderItem.UnitPrice * objOrderItem.Delta_Quantity__c +'</urn:ExtendedPrice>';
                    body += '<urn:FlexibleFields> <urn:FlexibleCodeField fieldId="8">HDM</urn:FlexibleCodeField></urn:FlexibleFields>'+'</urn:LineItem>';
                    objOrderItem.Current_Return_Quantity__c = objOrderItem.Delta_Quantity__c;
                    objOrderItem.Delta_Quantity__c = 0;
                   	lstUpdateOrderItems.add(objOrderItem);
                }
                 body += '</urn:InvoiceRequest></urn:VertexEnvelope></soapenv:Body></soapenv:Envelope>';

                System.debug('==RequestBody=='+body);
                request.setBody(body);
                request.setEndpoint('callout:VertexNamedCredential'+ Label.B2B_Vertex_Path_URL);
                //String usernamePassword = Label.B2B_Vertex_HDM_Username +':'+Label.B2B_Vertex_HDM_Password ;
                //String authorizationString = EncodingUtil.base64Encode(Blob.valueof(usernamePassword));
                //request.setHeader('Authorization', 'Basic '+authorizationString);

                // Get Response
                HTTPResponse response = http.send(request);
                //System.debug('testResponse'+response.getBody());
                DOM.Document doc = response.getBodyDocument();
                // Get Root Element which is 'Envelope'
                Dom.XMLNode rootElement = doc.getRootElement();
                System.debug('---RootElementName---'+rootElement.getName());
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
                                // Dom.XMLNode quotationResponse =  vertexEnvelopeNode.getChildElement('QuotationResponse','urn:vertexinc:o-series:tps:9:0');
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

                                    }
                                    if(quotationResponseChild.getName() == 'LineItem'){

                                        RES_BTVertexTaxCalculationIntegration.taxDetailForLineItem objInner = New RES_BTVertexTaxCalculationIntegration.taxDetailForLineItem();
                                        String cartItemId = mapLineItem.get(Integer.valueOf(quotationResponseChild.getAttributeValue('lineItemNumber',null)));
                                        objInner.itemId = cartItemId;
                                        CartItem objCartItem;
                                        Vertex_Details__c objChildVertexDetails;
                                        if(cartItemId != Label.B2B_Shipping_Code){
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
                                        }

                                        for(Dom.XMLNode lineItemsNodes : quotationResponseChild.getChildElements()){
                                            if(lineItemsNodes.getName() == 'TotalTax'){
                                                objInner.totalItemTax = lineItemsNodes.getText();
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                    objCartItem.B2B_Item_Total_Tax__c = Decimal.valueOf(lineItemsNodes.getText());
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
                                                    if(cartItemId != Label.B2B_Shipping_Code){
                                                        objCartItem.B2B_StateTax__c = Decimal.valueOf(tax);
                                                        objCartItem.B2B_StateTax_Rate__c = Decimal.valueOf(taxRate);

                                                        //for CartTax
                                                        objChildVertexDetails.B2B_State_Tax__c = Decimal.valueOf(tax);
                                                        objChildVertexDetails.B2B_State_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                    }
                                                }
                                                else if(jdLevel == 'CITY'){
                                                    objInner.cityTax = tax;
                                                    objInner.cityTaxRate = taxRate;
                                                    if(cartItemId != Label.B2B_Shipping_Code){
                                                        objCartItem.B2B_CityTax__c = Decimal.valueOf(tax);
                                                        objCartItem.B2B_CityTax_Rate__c = Decimal.valueOf(taxRate);

                                                        //for CartTax
                                                        objChildVertexDetails.B2B_City_Tax__c = Decimal.valueOf(tax);
                                                        objChildVertexDetails.B2B_City_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                    }
                                                }else if(jdLevel == 'TRANSIT_DISTRICT'){
                                                    objInner.transitDistrictTax = tax;
                                                    objInner.transitDistrictTaxRate = taxRate;
                                                    if(cartItemId != Label.B2B_Shipping_Code){
                                                        objCartItem.B2B_TransitDistrictTax__c = Decimal.valueOf(tax);
                                                        objCartItem.B2B_TransitDistrictTax_Rate__c = Decimal.valueOf(taxRate);

                                                        //for CartTax
                                                        objChildVertexDetails.B2B_Transit_District_Tax__c = Decimal.valueOf(tax);
                                                        objChildVertexDetails.B2B_Transit_District_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                    }
                                                }
                                                /*else if(jdLevel == 'APO'){
                                                objInner.apoTax = tax;
                                                objInner.apoTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_APO_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Apo_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'BOROUGH'){
                                                objInner.broughTax = tax;
                                                objInner.broughTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Borough_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Borough_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'COUNTY'){
                                                objInner.countyTax = tax;
                                                objInner.countyTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_County_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_County_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'COUNTRY'){
                                                objInner.coutryTax = tax;
                                                objInner.countryTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_County_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_County_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'DISTRICT'){
                                                objInner.districtTax = tax;
                                                objInner.districtTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_District_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_District_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'FPO'){
                                                objInner.fpoTax = tax;
                                                objInner.fpoTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Fpo_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Fpo_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'LOCAL_IMPROVEMENT_DISTRICT'){
                                                objInner.localImprovementDistrictTax = tax;
                                                objInner.localImprovementDistrictTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Local_Improvement_district_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Local_Improvement_District_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'PARISH'){
                                                objInner.parishTax = tax;
                                                objInner.parishTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Parish_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Parish_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'PROVINCE'){
                                                objInner.provinceTax = tax;
                                                objInner.provinceTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Province_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Province_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'SPECIAL_PURPOSE_DISTRICT'){
                                                objInner.specialPurposeDistrictTax = tax;
                                                objInner.specialPurposeDistrictTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Special_Purpose_District_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Special_Purpose_District_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'TERRITORY'){
                                                objInner.territoryTax = tax;
                                                objInner.territoryTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Territory_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Territory_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'TOWNSHIP'){
                                                objInner.townshipTax = tax;
                                                objInner.townshipTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Township_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Township_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }else if(jdLevel == 'TRADE_BLOCK'){
                                                objInner.tradeBlockTax = tax;
                                                objInner.tradeBlockTaxRate = taxRate;
                                                if(cartItemId != Label.B2B_Shipping_Code){
                                                objCartItem.B2B_Trade_Block_Tax__c = Decimal.valueOf(tax);
                                                objCartItem.B2B_Trade_Block_Tax_Rate__c = Decimal.valueOf(taxRate);
                                                }
                                                }*/
                                            }
                                        }
                                        if(cartItemId != Label.B2B_Shipping_Code){
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
                System.debug('objParentVertexDetails 1'+ objParentVertexDetails);
                System.debug('lstChildVertexDetails '+ lstChildVertexDetails);
                //added by Rajrishi on 28/07/2021
                if(objParentVertexDetails != null) {
                    insert objParentVertexDetails;
                    System.debug('parentCartTax '+ objParentVertexDetails);

                    List<Vertex_Details__c> lstVertaxDetails = new List<Vertex_Details__c>();
                    for(Vertex_Details__c objVertexDetails : lstChildVertexDetails){
                        objVertexDetails.Parent_Vertex_Details__c = objParentVertexDetails.Id;
                        lstVertaxDetails.add(objVertexDetails);
                    }
                    System.debug('lstCartTax '+ lstVertaxDetails);
                    //insert the child cart tax records
                    if(!lstVertaxDetails.isEmpty()){
                        insert lstVertaxDetails;
                    }
                }
                if(!lstUpdateOrderItems.isEmpty() && responseWrapper.isSuccess == true){
                    for(OrderItem objOrderItem : [SELECT Id, Delta_Quantity__c, Current_Return_Quantity__c
                                             	  FROM OrderItem WHERE OrderId =: OrderId AND Delta_Quantity__c = 0]){
                       objOrderItem.Current_Return_Quantity__c = 0;
                       lstUpdateOrderItems.add(objOrderItem);
                    }
                    update lstUpdateOrderItems;
                }
                System.debug('--TaxCalculated ===> '+totalTaxAmount);
            }
        }catch(Exception Ex){
            responseWrapper.isSuccess = false;
            responseWrapper.errorMessage = ex.getMessage()+ ' Line Number '+ex.getLineNumber();
            System.debug('Exception : '+ ex.getMessage() + ' Line Number '+ex.getLineNumber());
        }
        System.debug('ResponseFromServer'+JSON.serialize(responseWrapper));
        return responseWrapper;
    }

    /* This Method is for Address cleansing api
    Developed By : Radhey Shyam Gupta
    */
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
            body += '<soapenv:Body> <urn:VertexEnvelope> <urn:Login> <urn:UserName>';
            body += Label.B2B_VertexUserName + '</urn:UserName><urn:Password>'+Label.B2B_VertexPassword+'</urn:Password></urn:Login>';
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
            /*if(addressMap.containsKey('subDivision')){
            	body += '<urn:SubDivision>'+ addressMap.get('subDivision') + '</urn:SubDivision>';
            }else{
            	body += '<urn:SubDivision>'+ '' + '</urn:SubDivision>';
            } */
            if(addressMap.containsKey('postalCode') && String.isNotEmpty(addressMap.get('postalCode'))){
                body += '<urn:PostalCode>'+ addressMap.get('postalCode') + '</urn:PostalCode>';
            }
            if(addressMap.containsKey('country') && String.isNotEmpty(addressMap.get('country'))){
                body += '<urn:Country>'+ addressMap.get('country') + '</urn:Country>';
            }
            /*
            body += '<urn:StreetAddress2>'+ addressMap.get('streetAddress2') + '</urn:StreetAddress2>';
            body += '<urn:City>'+ addressMap.get('city') + '</urn:City>';
            body += '<urn:MainDivision>'+ addressMap.get('mainDivision') + '</urn:MainDivision>';
            body += '<urn:SubDivision>'+ addressMap.get('subDivision') + '</urn:SubDivision>';
            body += '<urn:PostalCode>'+ addressMap.get('postalCode') + '</urn:PostalCode>';
            body += '<urn:Country>'+ addressMap.get('country') + '</urn:Country>';
            */
            body += '</urn:PostalAddress> </urn:TaxAreaLookup> </urn:TaxAreaRequest> </urn:VertexEnvelope> </soapenv:Body> </soapenv:Envelope> ';
            System.debug('VertexRequestBody='+body);
            request.setBody(body);
            request.setEndpoint('callout:Vertex_Address_Cleansing_Named_Credential' + Label.B2B_Vertex_Address_Cleansing_URL);
            //String usernamePassword = Label.B2B_Vertex_HDM_Username +':'+Label.B2B_Vertex_HDM_Password ;
            //String authorizationString = EncodingUtil.base64Encode(Blob.valueof(usernamePassword));
            //request.setHeader('Authorization', 'Basic '+authorizationString);
            HttpResponse response = http.send(request);
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

            System.debug('vertexResponse'+xmlString);
            //DOM.Document doc = response.getBodyDocument();
            Dom.XMLNode rootElement = doc.getRootElement();
            Dom.XMLNode bodyElement = rootElement.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');

            if(bodyElement.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/') != null){
                Dom.XMLNode faultNode =  bodyElement.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                System.debug('FaultNodeName'+faultNode.getName());
                if(faultNode.getChildElement('faultstring',null) != null){
                    String errorDescription = faultNode.getChildElement('faultstring',null).getText();
                    cleansedAddressMap.put('isError','true');
                    cleansedAddressMap.put('errorMessage',errorDescription);
                }
            }else{
                Dom.XMLNode vertexEnvelopNode =  bodyElement.getChildElement('VertexEnvelope','urn:vertexinc:o-series:tps:9:0');
                Dom.XMLNode taxAreaResNode =  vertexEnvelopNode.getChildElement('TaxAreaResponse','urn:vertexinc:o-series:tps:9:0');
                System.debug('NameSpace'+taxAreaResNode.getNameSpace());
                Dom.XMLNode taxAreaResultNode =  taxAreaResNode.getChildElement('TaxAreaResult','urn:vertexinc:o-series:tps:9:0');
                Dom.XMLNode postalAddressNode =  taxAreaResultNode.getChildElement('PostalAddress','urn:vertexinc:o-series:tps:9:0');
                cleansedAddressMap.put('isError','false');

                if(postalAddressNode == null){
                    cleansedAddressMap.put('isError','true');
                    Dom.XMLNode addressCleansingMessage =  taxAreaResultNode.getChildElement('AddressCleansingResultMessage','urn:vertexinc:o-series:tps:9:0');
                    System.debug('-----'+addressCleansingMessage.getChildElement('','urn:vertexinc:o-series:tps:9:0')+addressCleansingMessage.getChildren());
                    if(addressCleansingMessage != null){
                        cleansedAddressMap.put('errorMessage',addressCleansingMessage.getText());
                        System.debug('Some Other error found');
                    }
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
            System.debug('SerializeResponse'+Json.serialize(cleansedAddressMap));
        }catch(Exception ex){
            System.debug('Exception Found  '+ex.getMessage()+' '+ex.getLineNumber());
            cleansedAddressMap.put('isError','true');
            cleansedAddressMap.put('errorMessage',ex.getMessage());
            Error__c objError = B2B_BrainTreeUtils.createErrorRecord('Address Cleansing error:', null, ex.getMessage());
            if(objError != null){
                //objError.Cart__c = cart.Id;
                insert objError;
            }
        }
        return Json.serialize(cleansedAddressMap);
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
        /*
        String apoTax,apoTaxRate,broughTax,broughTaxRate,countyTax,countyTaxRate,districtTax,districtTaxRate;
        String fpoTax,fpoTaxRate,localImprovementDistrictTax,localImprovementDistrictTaxRate,parishTax,parishTaxRate;
        String provinceTax,provinceTaxRate,specialPurposeDistrictTax,specialPurposeDistrictTaxRate,territoryTax,territoryTaxRate;
        String townshipTax,townshipTaxRate,tradeBlockTax,tradeBlockTaxRate,coutryTax,countryTaxRate;
        */
    }

}
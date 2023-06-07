/*******************************************************************************
Name: B2B_CreditCardPreAuthVertex
Business Unit: 
Created Date:  07/19/2021
Developer: 
Description: Invocable Method to callout to Vertex right after the pre-authorization occurs in checkout.
*******************************************************************************

MODIFICATIONS – Date | Dev Name     | Method | User Story
16/05/2022         | Faraz Ansari | createInvoiceRecords | HDMP-8705
Rajrishi - HDMP- 8716 : Audit trail
*******************************************************************************/

public class B2B_CreditCardPreAuthVertex {
    
    //Input Class with attributes to be passed from the Flow
    public class FlowInputs {
        @InvocableVariable(label='Order ID' description='ID for the Current Order') 
        public String orderId;
        
        @InvocableVariable(label='Account ID' description='ID for the Account on the Order') 
        public String accountId;
    }
    
    //Invocable Method called from the Payment and Billing Custom subflow
    @InvocableMethod(label='Vertax: Pre-Auth Tax Calculation' description='Flow Step to calculate the tax after the pre-auth request')
    public static void calculatePreAuthTax(List<FlowInputs> request) {
        try {
            FlowInputs req = request[0];
            
            Account a = [SELECT Id, BillingAddress, BillingStreet, BillingCity, BillingState, BillingPostalCode, PoIId__c FROM Account WHERE Id = :req.accountId];
            Order o = [SELECT Id, Cart__c, Cart__r.CustomerStreet__c, Cart__r.CustomerCity__c, Cart__r.Customer_State__c, Cart__r.CustomerPostalCode__c, Cart__r.ShippingAmount__c, Cart__r.Total_Installation_Charge__c, Cart__r.Delivery_Type__c FROM Order WHERE Id = :req.orderId];
        
            Map<String,String> dealerAddressMap = new Map<String,String>();
            dealerAddressMap.put('streetAddress', a.BillingStreet);
            dealerAddressMap.put('city', a.BillingCity);
            dealerAddressMap.put('mainDivision', a.BillingState);
            dealerAddressMap.put('postalCode', a.BillingPostalCode);
            
            Map<String,String> customerAddressMap = new Map<String,String>();
            customerAddressMap.put('streetAddress', o.Cart__r.CustomerStreet__c);
            customerAddressMap.put('city', o.Cart__r.CustomerCity__c);
            customerAddressMap.put('mainDivision', o.Cart__r.Customer_State__c);
            customerAddressMap.put('postalCode', o.Cart__r.CustomerPostalCode__c);    
            
            String installPrice = (o.Cart__r.Total_Installation_Charge__c != null && o.Cart__r.Total_Installation_Charge__c > 0) ? String.valueOf(o.Cart__r.Total_Installation_Charge__c) : null;
            String shippingPrice = (o.Cart__r.ShippingAmount__c != null && o.Cart__r.ShippingAmount__c > 0) ? String.valueOf(o.Cart__r.ShippingAmount__c) : null;
            //B2B_VertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper = B2B_VertexTaxCalculationIntegration.calculateTaxQuotation(o.Cart__c, dealerAddressMap, customerAddressMap, a.PoIId__c, String.valueOf(o.Cart__r.ShippingAmount__c), 'commit');
            B2B_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper = B2B_BTVertexTaxCalculationIntegration.calculateTax(o.Cart__c, dealerAddressMap, customerAddressMap, a.PoIId__c, shippingPrice, installPrice, 'commit');
            
            System.debug(objResponseDataWrapper);
            if(!objResponseDataWrapper.isSuccess == true) { 
                handleVertexError(o.Id, objResponseDataWrapper);
            }
            //Added by Faraz on 21/06/2022 for HDMP-10167 & HDMP-10179
            updateOrderOrderItemRecord(req.orderId);
            
            //changes for HDMP-8716 : create Order transaction record
            createOrderTransactionRecords(req.orderId, objResponseDataWrapper.isSuccess);
            
            //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
            //Dealer Installation - Invoice creation
            if(o.cart__r.Delivery_Type__c == 'Install At Dealer') {
                createInvoiceRecords(req.orderId);
            }           
            //Added by Faraz Ansari for HDMP-8705 - End
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    //Added by Faraz on 21/06/2022 for HDMP-10167& HDMP-10179
    //Updating remaining fields for order & order item object.
    public static void updateOrderOrderItemRecord(String orderId){
        try{
            Decimal orderQuantity = 0;
            Decimal orderProductTax = 0;
            Order objOrder = [SELECT Id, Updated_Total_Tax__c, Customer_Preferred_Speeds__c, Updated_Order_Total__c, cart__c, cart__r.Product_Division__c, cart__r.Product_Subdivision__c, Account.Email__c, cart__r.ShippingAmount__c,Account.PoIId__c,cart__r.Customer_Phone__c,cart__r.Customer_Name__c,cart__r.Delivery_Type__c, cart__r.Honda_Shipping_Speed__c, cart__r.Honda_Shipping_Speed__r.Honda_Speed_Name__c FROM Order WHERE Id =: orderId];
            // Saravanan LTIM Added Product_Type__c it for Sprint 2 Data Rules - REMAN-073
            List<OrderItem> orderItems = [SELECT Id, Quantity, Total_Tax__c, Item_Package_Quantity__c, Product_Model_Marketing_Name__c, Product_Division__c, Product_Subdivision__c, Product_Model__c, Product2Id,Product_Type__c FROM OrderItem WHERE OrderId =: orderId];
            List<CartItem> cartItems = [SELECT Id, Item_Package_Quantity__c, SalesPrice, Product_Model_Marketing_Name__c, Product_Division__c, Product_Subdivision__c, Product_Model__c, Product2Id FROM CartItem WHERE CartId =: objOrder.cart__c];
            //Pricebook2 pricebookObj = [SELECT Id FROM Pricebook2 WHERE Name LIKE 'Dream Shop Price Book' LIMIT 1];
            Map<String, CartItem> cartItemMap = new Map<String, CartItem>();
            for(CartItem itemObj : cartItems){
                cartItemMap.put(itemObj.Product2Id, itemObj);
            }
            for(OrderItem itemObj : orderItems){
                if(cartItemMap.containsKey(itemObj.Product2Id)){
                    CartItem cartItemObj = cartItemMap.get(itemObj.Product2Id);
                    itemObj.Item_Package_Quantity__c = cartItemObj.Item_Package_Quantity__c;
                    itemObj.Product_Model_Marketing_Name__c = cartItemObj.Product_Model_Marketing_Name__c;
                    itemObj.Product_Division__c = cartItemObj.Product_Division__c;
                    itemObj.Product_Subdivision__c = cartItemObj.Product_Subdivision__c;
                    itemObj.Product_Model__c = cartItemObj.Product_Model__c;
                }
                // Saravanan LTIM Added it for Sprint 2 Data Rules - REMAN-073
                if(itemObj.Product_Type__c != Label.B2B_Product_Code_Core_Charges){
                    orderQuantity += itemObj.Quantity;
                    orderProductTax += itemObj.Total_Tax__c; // Saravanan LTIM for 19416,19436

                }
            }
            Order orderObj = new Order();
            orderObj.Id = orderId;
            orderObj.Customer_Preferred_Speeds__c = (objOrder.cart__r.Honda_Shipping_Speed__c != null) ? objOrder.cart__r.Honda_Shipping_Speed__r.Honda_Speed_Name__c : '';
            orderObj.Delivery_Types__c = objOrder.cart__r.Delivery_Type__c;
            orderObj.Dealer_Email__c = objOrder.Account.Email__c;
            orderObj.Dealer_Number__c = objOrder.Account.PoIId__c;
            orderObj.ShippingPhoneNumber__c = objOrder.cart__r.Customer_Phone__c;
            orderObj.Product_Division__c = objOrder.cart__r.Product_Division__c;
            orderObj.Product_Subdivision__c = objOrder.cart__r.Product_Subdivision__c;
            orderObj.Shipping_Customer_Name__c = objOrder.cart__r.Customer_Name__c;
            orderObj.Quantity__c = orderQuantity;
            orderObj.Current_Quantity__c = orderQuantity;
            orderObj.Total_Original_Product_Tax__c = orderProductTax;
            orderObj.Total_Amount__c = objOrder.Updated_Order_Total__c - objOrder.Updated_Total_Tax__c;
            orderObj.Total_Current_Product_Tax__c = orderProductTax;
            orderObj.Total_Current_Pre_Tax_Order_Amount__c = (objOrder.Updated_Order_Total__c != null ? objOrder.Updated_Order_Total__c : 0) - (objOrder.Updated_Total_Tax__c != null ? objOrder.Updated_Total_Tax__c : 0);
            /*if(pricebookObj.Id != null){
                orderObj.Pricebook2Id = pricebookObj.Id;
            }*/
            update orderObj;
            update orderItems;
        }catch(Exception ex){
            System.debug('Exception : '+ex.getMessage());
            System.debug('Line Number : '+ex.getLineNumber());
            System.debug('Stack Trace : '+ex.getStackTraceString());
            Error__c objError = new Error__c();
            objError.Line_Number__c = ex.getLineNumber();
            objError.StackTrace__c = ex.getStackTraceString();
            objError.Error_Type__c = ex.getTypeName();
            objError.Error_Message__c = ex.getMessage();
            objError.Name = 'Exception Occured'; 
            objError.ClassName__c = 'B2B_CreditCardPreAuthVertex';
            objError.MethodName__c = 'updateOrderOrderItemRecord';
            objError.Order__c = orderId;
            objError.RecordId__c = orderId;
            insert objError;
        }        
    }
    //End - Added by Faraz
    
    // for HDMP- 8716 : Audit trail :- create order transaction for order placed 
    public static void createOrderTransactionRecords(String orderId, Boolean isSuccess){
        Try{
            
            List<Error__c> errorObjList = new List<Error__c>();
            if(!isSuccess){
                errorObjList = [Select Id, Order_Transaction__c From Error__c Where Order__c =: orderId Order By CreatedDate Desc Limit 1];             
            }
            
            // Saravanan LTIM added Reman SPRINT 2 Guest or Logged -in User Total_Core_Charge_Original_Amount__c , Total_Core_Charge_Original_Quantity__c , Total_Core_Charge_Original_Tax__c
            Order objOrder = [SELECT Id, Updated_Shipping__c, cart__r.Delivery_Type__c, Total_Installation_Tax__c, BT_Transaction_Id__c, Current_Shipping_Tax__c, Updated_Order_Total__c, Updated_Total_Tax__c 
                                ,Total_Core_Charge_Original_Amount__c,Total_Core_Charge_Original_Quantity__c,Total_Core_Charge_Original_Tax__c
                              FROM Order WHERE Id =: orderId];
            if(objOrder != null){               
                
                //create order transaction object 
                Order_Transaction__c objOrderTransaction = new Order_Transaction__c();
                objOrderTransaction.Order__c = objOrder.Id;               
                objOrderTransaction.Order_Transaction_Type__c = objOrder.cart__r.Delivery_Type__c == 'Install At Dealer' ? 'Placed' : 'Submitted';
                objOrderTransaction.Order_Transaction_Status__c = isSuccess == true ? 'Success' : 'Failure';
                objOrderTransaction.Is_Adjustment__c = false;
                
                //post values
                objOrderTransaction.Total_Post_Adjustment_Shiping_Charge__c = objOrder.Updated_Shipping__c;
                objOrderTransaction.Total_Post_adjustment_Installation_Tax__c = objOrder.Total_Installation_Tax__c;
                objOrderTransaction.Total_Post_adjustment_Shipping_Tax__c = objOrder.Current_Shipping_Tax__c;
                objOrderTransaction.Post_Adjustment_Total_Amount__c = (objOrder.Updated_Order_Total__c != null ? objOrder.Updated_Order_Total__c : 0);
                objOrderTransaction.Post_Adjustment_Total_Tax__c = (objOrder.Updated_Total_Tax__c != null ? objOrder.Updated_Total_Tax__c : 0);
                objOrderTransaction.Adjustment_Date_Time__c = System.now();

                // Saravanan starts LTIM SPRINT -2 Data Rules Logic Guest or Logged-in User Order Checkout
                objOrderTransaction.Total_Post_Adjustment_Core_Charge_Qty__c = objOrder.Total_Core_Charge_Original_Quantity__c;
                objOrderTransaction.Total_Post_Adjustment_Core_Charge_Amount__c = objOrder.Total_Core_Charge_Original_Amount__c;
                objOrderTransaction.Total_Post_Adjustment_Core_Charge_Tax__c = objOrder.Total_Core_Charge_Original_Tax__c;

                //// Saravanan Ends LTIM SPRINT -2 Data Rules Logic Guest or Logged-in User Order Checkout

                insert objOrderTransaction;
                
                // create Order_Transaction_Item__c 
                List<Order_Transaction_Item__c> lstOrderTranItems = new List<Order_Transaction_Item__c>();
                // Saravanan LTIM added Product_Type__c,Product2Id.Core_Charge_Unit_Price__c for SPRINT -2 Data Rules Logic 
                for(OrderItem objOrderItem : [SELECT Id, Total_Current_Product_Tax__c, Dealer_Installation_Price__c, Delta_Installation_Price__c, Delta_Quantity__c,
                                              Updated_Quantity__c, ListPrice, Total_Tax__c ,Product_Type__c,Product2.Core_Charge_Unit_Price__c
                                              FROM OrderItem WHERE Type != 'Delivery Charge' AND OrderId =: objOrder.Id]){
                                                  Order_Transaction_Item__c objOrderTranItem = new Order_Transaction_Item__c();
                                                  objOrderTranItem.Order_Item__c = objOrderItem.Id;
                                                  objOrderTranItem.Order_Transaction__c = objOrderTransaction.Id;  
                                                  //post values                              
                                                  objOrderTranItem.Post_Adjustment_Quantity__c = objOrderItem.Updated_Quantity__c;
                                                  objOrderTranItem.Post_Adjustment_Extended_Price__c = objOrderItem.Updated_Quantity__c * objOrderItem.ListPrice;
                                                  objOrderTranItem.Total_Post_Adjustment_Product_Tax__c = objOrderItem.Total_Current_Product_Tax__c;
                                                  objOrderTranItem.TotalPost_Adjustment_Installation_Charge__c = objOrderItem.Dealer_Installation_Price__c; 
                                                  objOrderTranItem.Adjustment_Date_Time__c = System.now();
                                                  objOrderTranItem.AK_Order_Transaction_Item__c = objOrderTransaction.Id + '' + objOrderItem.Id; //Added by Ravi Prasad to populate AK Order Transaction Item as part of HDMP-12002

                                                  // Saravanan starts LTIM SPRINT -2 Data Rules Logic for Guest or Logged-in User Order Checkout
                                                  objOrderTranItem.Product_Type__c = objOrderItem.Product_Type__c; 
                                                  objOrderTranItem.AK_Order_Transaction_Item__c = objOrderItem.Product2.Core_Charge_Unit_Price__c > 0 || objOrderItem.Product_Type__c == label.B2B_Product_Code_Core_Charges ? 
                                                                                                  objOrderTransaction.Id + '~' + objOrderItem.Id + '~' + objOrderItem.Product_Type__c : objOrderTranItem.AK_Order_Transaction_Item__c ; //REMAN-093

                                                 // Saravanan Ends LTIM SPRINT -2 Data Rules Logic for Guest or Logged-in User Order Checkout

                                                  lstOrderTranItems.add(objOrderTranItem);
                                              }        
                
                if(!lstOrderTranItems.isEmpty()){
                    insert lstOrderTranItems;
                }
                
                if(!errorObjList.isEmpty()){
                    errorObjList[0].Order_Transaction__c = objOrderTransaction.Id;
                    update errorObjList;
                }
                
                List<BT_Transaction_Details__c> lstBTTrans = [SELECT Id, BT_TransactionId__c, Order_Transaction__c 
                                                              FROM BT_Transaction_Details__c 
                                                              WHERE BT_TransactionId__c =: objOrder.BT_Transaction_Id__c LIMIT 1];
                if(!lstBTTrans.isEmpty()){
                    lstBTTrans[0].Order_Transaction__c = objOrderTransaction.Id;
                    update lstBTTrans;
                }
                
                //Start
                // added for R2C1 : Tax Transaction to have a lookup to Order Transaction
                List<Vertex_Details__c> lstTaxTransactions = new List<Vertex_Details__c>();
                for(Vertex_Details__c objDetails : [SELECT Id, Order_Transaction__c FROM Vertex_Details__c WHERE Order__c =: objOrder.Id]){
                    objDetails.Order_Transaction__c = objOrderTransaction.Id;
                    lstTaxTransactions.add(objDetails);
                }
                
                if(!lstTaxTransactions.isEmpty()){
                    update lstTaxTransactions;
                }
                //End
            }
        }catch(Exception ex){
            System.debug('Exception : '+ex.getMessage());
            System.debug('line Number : '+ex.getLineNumber());
            System.debug('Stack Trace : '+ex.getStackTraceString());
        }        
    }
    
    
    private static void handleVertexError(String orderId, B2B_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper) {
        try {
            Error__c errorRecord = new Error__c();
            errorRecord.Name = 'Vertext Commit Callout Service Failed'; 
            errorRecord.Order__c = orderId;
            errorRecord.ClassName__c = 'B2B_CreditCardPreAuthVertex';
            errorRecord.Error_Message__c = objResponseDataWrapper.errorMessage;
            errorRecord.Request_Payload__c = objResponseDataWrapper.request;
            errorRecord.Response_Payload__c = objResponseDataWrapper.response;
            errorRecord.MethodName__c = 'calculatePreAuthTax';
            errorRecord.RecordId__c = orderId;
            insert errorRecord;
    
            Order o = new Order(Id = orderId);
            o.IsError__c = true;
            update o;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    //Added by Faraz Ansari for HDMP-8705 on 16/05/2022 - Start
    //Create Invoice & Invoice Items records based on Order & Order Items
    private static void createInvoiceRecords(String orderId) {
        String singleOrderId;
        try{
            List<Invoice__c> lstInvoice = new List<Invoice__c>();
            List<Invoice_Item__c> lstInvoiceItem = new List<Invoice_Item__c>();
            //Cart_Shipping_Customer_Name__c,Delivery_Type__c
            Order objOrder = [SELECT Id, OrderNumber, OrderedDate, BT_Customer_Detail__c, Payment_Method_Token__c, Updated_Order_Total__c, Delivery_Types__c,cart__r.Customer_Name__c,cart__r.Delivery_Type__c,  
                              AccountId, Status, Updated_Shipping__c, Updated_Total_Tax__c, ShipToContactId,BillingEmailAddress, Customer_Name__c,OrderReferenceNumber,
                              BT_Transaction_Status__c, IsError__c, cart__c, Send_Email_To_Customer__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, 
                              BillingCountry, BillingAddress, BillingPhoneNumber, CC_Last4__c, Payment_Type__c,Total_Shipping_Tax__c,Current_Shipping_Tax__c,
                              Shipping_Customer_Name__c, ShippingAddress, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, Total_Installation_Tax__c, Owner.Email,
                              (SELECT Id, Name, BT_TransactionId__c , Customer__c FROM BT_Transaction_Details__r), (SELECT Id FROM Order_Transactions__r),
                              (SELECT Id, TotalPrice, Dealer_Installation_Price__c, Delta_Installation_Price__c, Delta_Quantity__c,Updated_Quantity__c,
                               Return_Quantity__c, Quantity, ListPrice, Total_Tax__c, Product_SKU__c, Cart_Item_Product_Name__c, Op_Code__c FROM OrderItems WHERE Type != 'Delivery Charge') 
                              FROM Order 
                              WHERE Id =: orderId];
            if(objOrder.Id != null){
                singleOrderId = objOrder.Id;
                Account objAccount = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, Email__c, Phone FROM Account WHERE Id =: objOrder.AccountId];
                String BTTransactionId = objOrder.BT_Transaction_Details__r[0].Id;
                Invoice__c invoiceObj = new Invoice__c();
                invoiceObj.Total_Shipping_Amount__c = objOrder.Updated_Shipping__c;
                invoiceObj.Total_Shipping_Tax__c = objOrder.Current_Shipping_Tax__c;
                invoiceObj.Total_Invoice_Price__c = (objOrder.Updated_Order_Total__c != null ? objOrder.Updated_Order_Total__c : 0); 
                invoiceObj.Total_Invoice_Tax__c = (objOrder.Updated_Total_Tax__c != null ? objOrder.Updated_Total_Tax__c : 0);
                invoiceObj.Total_Pre_Tax_Invoice_Amount__c = (objOrder.Updated_Order_Total__c != null ? objOrder.Updated_Order_Total__c : 0) - (objOrder.Updated_Total_Tax__c != null ? objOrder.Updated_Total_Tax__c : 0);
                invoiceObj.Account__c = objOrder.AccountId;
                invoiceObj.CC_Last4__c = objOrder.CC_Last4__c;
                invoiceObj.BillingStreet__c = objOrder.BillingStreet;
                invoiceObj.BillingCity__c = objOrder.BillingCity;
                invoiceObj.BillingCountry__c = objOrder.BillingCountry;
                invoiceObj.BillingState__c = objOrder.BillingState;
                invoiceObj.Billing_Customer_Name__c = objOrder.Customer_Name__c;
                invoiceObj.Order_EmailAddress__c = String.isNotEmpty(objOrder.BillingEmailAddress) ? objOrder.BillingEmailAddress : objOrder.Owner.Email;
                invoiceObj.BillingPhoneNumber__c = objOrder.BillingPhoneNumber;
                invoiceObj.BillingPostalCode__c = objOrder.BillingPostalCode;
                invoiceObj.ShippingStreet__c = objOrder.ShippingStreet ;
                invoiceObj.ShippingCity__c = objOrder.ShippingCity;
                invoiceObj.ShippingCountry__c = objOrder.ShippingCountry;
                invoiceObj.ShippingPostalCode__c = objOrder.ShippingPostalCode;
                invoiceObj.ShippingState__c = objOrder.ShippingState;
                invoiceObj.Shipping_Customer_Name__c = objOrder.cart__r.Customer_Name__c;
                invoiceObj.Dealer_Name__c = objAccount.Name;
                invoiceObj.Dealer_Street__c = objAccount.BillingStreet;
                invoiceObj.Dealer_City__c = objAccount.BillingCity;
                invoiceObj.Dealer_State__c = objAccount.BillingState;
                invoiceObj.Dealer_Postal_Code__c = objAccount.BillingPostalCode;
                invoiceObj.Dealer_Phone_Number__c = objAccount.Phone;
                invoiceObj.Dealer_Email_Address__c = objAccount.Email__c;
                invoiceObj.Invoice_Date__c = System.now();
                invoiceObj.Ordered_Date__c = objOrder.OrderedDate;
                invoiceObj.BT_Transaction_Details__c = BTTransactionId;
                invoiceObj.Order__c = objOrder.Id;
                invoiceObj.Invoice_Type__c = B2B_IntegrationConstants.ORDER_INVOICE;
                invoiceObj.Order_Reference_Number__c = String.isNotEmpty(objOrder.OrderReferenceNumber) ? objOrder.OrderReferenceNumber : objOrder.OrderNumber;
                invoiceObj.Payment_Method_Type__c = objOrder.Payment_Type__c;
                invoiceObj.Delivery_Type__c = objOrder.cart__r.Delivery_Type__c;
                invoiceObj.Total_Installation_Tax__c = objOrder.Total_Installation_Tax__c;
                invoiceObj.Order_Transaction__c = objOrder.Order_Transactions__r.size() > 0 ? objOrder.Order_Transactions__r[0].Id : null;
                lstInvoice.add(invoiceObj);
                for(OrderItem objOrderItem : objOrder.OrderItems){
                    Invoice_Item__c invItemObj = new Invoice_Item__c();
                    invItemObj.Unit_Price__c = objOrderItem.ListPrice;
                    invItemObj.Total_Product_Tax__c = objOrderItem.Total_Tax__c;
                    invItemObj.Item_Installation_Price__c = objOrderItem.Dealer_Installation_Price__c;
                    invItemObj.Total_Installation_Charge__c = objOrderItem.Dealer_Installation_Price__c;
                    invItemObj.Extended_Price__c = objOrderItem.ListPrice * objOrderItem.Updated_Quantity__c;
                    invItemObj.Accessory_Op_Code__c = objOrderItem.Op_Code__c;
                    invItemObj.Product_SKU__c = objOrderItem.Product_SKU__c;
                    invItemObj.Item_Quantity__c = objOrderItem.Updated_Quantity__c;
                    invItemObj.Product_Name__c = objOrderItem.Cart_Item_Product_Name__c ;
                    lstInvoiceItem.add(invItemObj);
                }
                //insert invoice & invoice item records for order  
                if(!lstInvoice.isEmpty()){
                    insert lstInvoice;
                    Invoice__c objInvoice = [SELECT Id, Name FROM Invoice__c WHERE Id =: lstInvoice[0].Id];
                    lstInvoice[0].Invoice_Number__c = objInvoice.Name;
                    update lstInvoice;
                    if(!lstInvoiceItem.isEmpty()){
                        for(Invoice_Item__c itemObj : lstInvoiceItem){
                            itemObj.Invoice__c = lstInvoice[0].Id;
                        }
                        insert lstInvoiceItem;
                    }
                }
            }
        } catch(Exception ex) {
            Error__c objError = new Error__c();
            objError.Line_Number__c = ex.getLineNumber();
            objError.StackTrace__c = ex.getStackTraceString();
            objError.Error_Type__c = ex.getTypeName();
            objError.Error_Message__c = ex.getMessage();
            objError.Name = 'Exception Occured'; 
            objError.ClassName__c = 'B2B_CreditCardPreAuthVertex';
            objError.MethodName__c = 'createInvoiceRecords';
            objError.Order__c = singleOrderId;
            objError.RecordId__c = singleOrderId;
            insert objError;
        }
    }
    //Added by Faraz Ansari for HDMP-8705 - End
}
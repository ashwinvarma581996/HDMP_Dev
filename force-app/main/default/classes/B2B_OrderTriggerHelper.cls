/**************************************************************************************
@File Name      : B2B_OrderTriggerHelper  
@Description    : This is a helper class for OrderTrigger.
@Created By		: Rajrishi Kaushik
@Business Unit  : HDM
@Created Date   : 09/07/2021
@API Version    : 54.0
*****************************************************************************************
MODIFICATIONS – Date      | Dev Name         | Method                    | User Story 
19-07-2022                | Ravi Prasad      | generateOrderReference()  | 
*****************************************************************************************/

public class B2B_OrderTriggerHelper {
	
	Public static Boolean firstcall = false;
	//this method is called when order object is updated

	Public static Map<Id,List<Order_Transaction_Item__c>> maporderTransIdtolstTransItems= new Map<Id,List<Order_Transaction_Item__c>>(); // Saravanan LTIM 19500

	public static void afterUpdate(List<Order> lstNewOrders, List<Order> lstOldOrders, Map<Id, Order> mapNewOrders, Map<Id, Order> mapOldOrders){      
		
		captureBTCustomerOrder(lstNewOrders, mapOldOrders, mapNewOrders); 
		cancelBTCustomerOrder(lstNewOrders, mapOldOrders, mapNewOrders); 
		partialReturnBTCustomerOrder(lstNewOrders, mapOldOrders, mapNewOrders);  
		onOrderItemCancel(lstNewOrders, mapOldOrders);
		if(!firstcall) {
			generateOrderReference(lstNewOrders,mapOldOrders);}// updated by saikiran as part of HDMP-12833
	}  
	
	/*
	Created By : Rajrishi Kaushik
	Date : 11/07/2021
	Description : this method is used when the order status get's changed to CUSTOMER CANCELED and
				  it canceled the order at braintree server by calling the braintreeTransactionVoid api.
	*/
	public static void cancelBTCustomerOrder(List<Order> lstNewOrders, Map<Id, Order> mapOldOrders , Map<Id, Order> mapNewOrders){
        System.debug('cancelBTCustomerOrder '+lstNewOrders);
		Set<Id> setOrderIds = new Set<Id>();
		Set<Id> setAccountIds = new Set<Id>();
		Map<Id, String> mapOldOrderStatus = new Map<Id, String>();
		for(Order objOrder : lstNewOrders){
			if((objOrder.BT_Transaction_Status__c == 'Authorized' || objOrder.BT_Transaction_Status__c == 'Submitted_For_Settlement') 
			   && objOrder.AccountId != null && (objOrder.Status == 'CUSTOMER CANCELED' || objOrder.Status == 'SYSTEM CANCELED' || 
			   objOrder.Status == 'DEALER CANCELED') && (mapOldOrders.get(objOrder.Id).Status == 'IN PROGRESS' || mapOldOrders.get(objOrder.Id).Status == 'PAYMENT ISSUE' || mapOldOrders.get(objOrder.Id).Status == 'Activated')){
				setOrderIds.add(objOrder.Id);
				setAccountIds.add(objOrder.AccountId);
				mapOldOrderStatus.put(objOrder.Id, mapOldOrders.get(objOrder.Id).Status);
			}
		}   
		     
		System.debug('setOrderIds' + setOrderIds );
		System.debug('setAccountIds' + setAccountIds );
		if(!setOrderIds.isEmpty() && !setAccountIds.isEmpty()){
			B2B_BrainTreeIntegration bTObject = new B2B_BrainTreeIntegration(setOrderIds, setAccountIds, mapOldOrderStatus, 'void');
            System.enqueueJob(bTObject);
            // B2B_BrainTreeIntegration.braintreeOrderCancellation(setOrderIds, setAccountIds, mapOldOrderStatus, 'void');
		}
	} 
	
	
	/*
	Created By : Rajrishi Kaushik
	Date : 07/08/2021
	Description : 
	*/
	public static void partialReturnBTCustomerOrder(List<Order> lstNewOrders, Map<Id, Order> mapOldOrders , Map<Id, Order> mapNewOrders){
		Set<Id> setOrderIds = new Set<Id>();
		Set<Id> setAccountIds = new Set<Id>();
		Map<Id, String> mapOldOrderStatus = new Map<Id, String>();
		for(Order objOrder : lstNewOrders){
			if((objOrder.BT_Transaction_Status__c == 'Settling' || objOrder.BT_Transaction_Status__c == 'Settled') 
			   && objOrder.AccountId != null && objOrder.Status == 'PARTIAL RETURN COMPLETE' && (mapOldOrders.get(objOrder.Id).Status == 'PARTIAL RETURN' || mapOldOrders.get(objOrder.Id).Status == 'ORDER COMPLETE - SHIPPED'
				|| mapOldOrders.get(objOrder.Id).Status == 'READY FOR PICKUP' || mapOldOrders.get(objOrder.Id).Status == 'ORDER COMPLETE - PICKED UP')){
				setOrderIds.add(objOrder.Id);
				setAccountIds.add(objOrder.AccountId);
				mapOldOrderStatus.put(objOrder.Id, mapOldOrders.get(objOrder.Id).Status);
				}else if((objOrder.BT_Transaction_Status__c == 'Settling' || objOrder.BT_Transaction_Status__c == 'Settled') && 
						 objOrder.Status == 'PARTIAL RETURN COMPLETE' && (mapOldOrders.get(objOrder.Id).Status == 'Activated' || mapOldOrders.get(objOrder.Id).Status == 'ORDER COMPLETE - INSTALLED') && objOrder.Delivery_Types__c == 'Install At Dealer'){
							 setOrderIds.add(objOrder.Id);
							 setAccountIds.add(objOrder.AccountId);
							 mapOldOrderStatus.put(objOrder.Id, mapOldOrders.get(objOrder.Id).Status);	
				}
		}        
		if(!setOrderIds.isEmpty() && !setAccountIds.isEmpty()){
			 //B2B_BrainTreeIntegration.braintreeOrderCancellation(setOrderIds, setAccountIds, mapOldOrderStatus,'partial return'); 
			 B2B_BrainTreeIntegration bTObject = new B2B_BrainTreeIntegration(setOrderIds, setAccountIds, mapOldOrderStatus, 'partial return');
			 System.enqueueJob(bTObject);
		}
	}
		   
	
	/*
	Created By : Bhawesh Asudani
	Date : 02/08/2021
	Description : this method is used to populate the shipping address field on the order object from the shipping field of the related cart object.
	*/
	// HDMP-10756 starts here
	public static void populateDataFromCart(List<Order> orderList){
		set<Id> cartIds = new Set<Id>();
		for(Order orderObj : orderList){
			if(orderObj.cart__c != null)
				cartIds.add(orderObj.cart__c);
		}
		Map<Id, WebCart> cartIdAndCartObjMap = new Map<Id,WebCart>([SELECT Id,Name,CustomerStreet__c,CustomerCity__c,
																	Customer_State__c,CustomerPostalCode__c,CustomerCountry__c FROM 
																	WebCart WHERE Id IN : cartIds]);
		
		for(Order orderObj : orderList){
			if(orderObj.cart__c != null && cartIdAndCartObjMap.containsKey(orderObj.cart__c)){
				orderObj.ShippingStreet = cartIdAndCartObjMap.get(orderObj.cart__c).CustomerStreet__c;
				orderObj.ShippingCity = cartIdAndCartObjMap.get(orderObj.cart__c).CustomerCity__c;
				orderObj.ShippingState = cartIdAndCartObjMap.get(orderObj.cart__c).Customer_State__c;
				orderObj.ShippingPostalCode = cartIdAndCartObjMap.get(orderObj.cart__c).CustomerPostalCode__c;
				orderObj.ShippingCountry  = cartIdAndCartObjMap.get(orderObj.cart__c).CustomerCountry__c;
			}
		}        
	}
	// HDMP-10756 ends here

	/*
	Created By : Vikrant Upneja
	Date : 08/05/2021
	Description : this method is used when the order status is changed to ORDER COMPLETE - SHIPPED or READY FOR PICKUP
				  BT Post Auth Call is made and funds are captured
	*/
	public static void captureBTCustomerOrder(List<Order> lstNewOrders, Map<Id, Order> mapOldOrders , Map<Id, Order> mapNewOrders){
	 Set<Id> setOrderIds = new Set<Id>();
	 Set<Id> setAccountIds = new Set<Id>();
	 System.debug('*lstNewOrders*:'+ lstNewOrders);
	 System.debug('*mapOldOrders*:'+ mapOldOrders);
	 System.debug('*mapNewOrders*:'+ mapNewOrders);
	 Map<Id, String> mapOldOrderStatus = new Map<Id, String>();
	 for(Order objOrder : lstNewOrders){
		 if((objOrder.BT_Transaction_Status__c == 'Authorized') 
			&& objOrder.AccountId != null && (objOrder.Status == 'ORDER COMPLETE - SHIPPED' ||objOrder.Status == 'READY FOR PICKUP') 
			&& mapOldOrders.get(objOrder.Id).Status =='IN PROGRESS' ){
			 setOrderIds.add(objOrder.Id);
			 setAccountIds.add(objOrder.AccountId);
			 mapOldOrderStatus.put(objOrder.Id, mapOldOrders.get(objOrder.Id).Status);
		 }
	 }        
	 if(!setOrderIds.isEmpty() && !setAccountIds.isEmpty()){
		   B2B_BrainTreeIntegration.braintreeOrderCapture(setOrderIds, setAccountIds, mapOldOrderStatus, 'refund'); 
	 }
	}

	public static void updateOrderDealer(List<Order> lstNewOrders){
		
	  String webStoreId =  [select id from webstore where name like 'Dream%' LIMIT 1].id;
	  
	  // If these are order for the reservation storefront, then skip this trigger
	  List<Reservation_Settings__mdt> resStores = [SELECT StoreId__c FROM Reservation_Settings__mdt WHERE DeveloperName = 'Default'] ;
	  String resStoreId = null ;
	  if ( !resStores.isEmpty())
	  {
		  resStoreId = resStores[0].StoreId__c ;
	  }
	  for ( order o : lstNewOrders )
	  {
		  if ( o.SalesStoreId == resStoreId )
		  {
			  return ;
		  }
	  }
	  
	  B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
		if (!Test.isRunningTest()) {
			
			//Below line of code Added By -Soumya for Person Account changes
		   string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
			if(String.isNotBlank(personAccountId))
				b2b.Default_Guest_Account__c=personAccountId;
			//End-Soumya
	  ConnectApi.CartSummary currentCart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webStoreId, b2b.Default_Guest_Account__c, 'active');
			WebCart wc = [SELECT Id, DealerId__c FROM WebCart WHERE Id = :currentCart.cartId LIMIT 1];
	  for(Order a : lstNewOrders) {
		  a.AccountId = wc.DealerId__c;
				//a.Dealer_Email__c = wc.DealerId__r.PersonEmail;
	  }
	}
	}
	 /*
	Created By : Rajrishi Kaushik
	Date : 27/08/2021
	Description : This method is called when line item cancellation is performed from dealer experience.
	*/
	public static void onOrderItemCancel(List<Order> lstNewOrders, Map<Id, Order> mapOldOrders){
        System.debug('mapOldOrders '+mapOldOrders);
		Set<Id> setOrderIds = new Set<Id>();
		Set<Id> setAccountIds = new Set<Id>();
		List<Order> lstOrders = new List<Order>();
		String tranType = '';
		for(Order objOrder : lstNewOrders){
			if(objOrder.Status == 'IN PROGRESS' && objOrder.AccountId != null && objOrder.cart__c != null && 
			   objOrder.Updated_Order_Total__c !=  mapOldOrders.get(objOrder.Id).Updated_Order_Total__c && 
			   objOrder.Updated_Total_Tax__c !=  mapOldOrders.get(objOrder.Id).Updated_Total_Tax__c && 
			   (mapOldOrders.get(objOrder.Id).Status == 'Activated' || mapOldOrders.get(objOrder.Id).Status == 'IN PROGRESS')){                
				   //set order ids    
				   setOrderIds.add(objOrder.Id);
				   setAccountIds.add(objOrder.AccountId);
				   lstOrders.add(objOrder);
				   tranType = 'Modified';
			}            
			//for HDMP-8716 : AuditTrail
			else if(objOrder.Status == 'ORDER COMPLETE - PICKED UP' && mapOldOrders.get(objOrder.Id).Status == 'READY FOR PICKUP'){
				lstOrders.add(objOrder);
				tranType = 'Order Picked Up';
			}
			
			else if(objOrder.Status == 'ORDER COMPLETE - INSTALLED' && mapOldOrders.get(objOrder.Id).Status == 'Activated'){
				lstOrders.add(objOrder);
				tranType = 'Order Installed';
			}
		}
		
		if(!setOrderIds.isEmpty() && !setAccountIds.isEmpty()){
			 callVertexOnOrderItemCancel(setOrderIds, setAccountIds, JSON.serialize(lstOrders), JSON.serialize(mapOldOrders), tranType); 
		}
	   
	}

	/*
	Created By : Saravanan Ramaswammy
	Date : 29/05/20233
	Description : This method is used to create Tax Transaction Record for HDMP-19500.
	*/

	Public static void createVertexRecords(Order_Transaction__c  objOrderTransaction , Order objOrder){

		Vertex_Details__c objParentVertexDetails = new Vertex_Details__c();
		List<Vertex_Details__c> lstChildVertexDetails = new List<Vertex_Details__c>();
		List<Order_Transaction_Item__c> lstOrderTransactionItem = new List<Order_Transaction_Item__c> ();

		//objParentVertexDetails.B2B_Cart__c = cartId;
		objParentVertexDetails.Order__c = objOrder.Id;
		//objParentVertexDetails.Customer__c = userId;
		//objParentVertexDetails.documentNumber__c = cartId;
		objParentVertexDetails.Tax_Transaction_Date__c = System.now();
		objParentVertexDetails.B2B_Total_Tax__c = objOrderTransaction.Post_Adjustment_Total_Tax__c;
		objParentVertexDetails.Order_Transaction__c = objOrderTransaction.Id;

		Database.insert(objParentVertexDetails);

		if(maporderTransIdtolstTransItems.values().size() > 0){

			lstOrderTransactionItem = maporderTransIdtolstTransItems.get(objOrderTransaction.Id);

			for(Order_Transaction_Item__c objTranItem : lstOrderTransactionItem){

				Vertex_Details__c objChildVertexDetails = new Vertex_Details__c();

				objChildVertexDetails.Parent_Vertex_Details__c = objParentVertexDetails.Id;
				objChildVertexDetails.Order_Transaction__c = objOrderTransaction.Id;
				objChildVertexDetails.Order__c = objOrder.Id;
				objChildVertexDetails.Tax_Transaction_Date__c = System.now();
				objChildVertexDetails.B2B_Total_Tax__c = objTranItem.Total_Post_Adjustment_Product_Tax__c;

				lstChildVertexDetails.add(objChildVertexDetails);

			}
		}

		Database.insert(lstChildVertexDetails);

	}
	
	/*
	Created By : Rajrishi Kaushik
	Date : 31/05/2022
	Description : This method is used to create Order Transaction and Order Transaction Item Records for HDMP-8716.
	*/
	public static Order_Transaction__c createOrderTransactionRecords(Order objOrder, Map<String, Order> mapOldOrders, String auditType, List<OrderItem> lstOldOrderItems){
		Order oldOrder = mapOldOrders.get(objOrder.Id);
		BT_Transaction_Details__c objBTTran = [SELECT Id, BT_TransactionId__c FROM BT_Transaction_Details__c WHERE BT_TransactionId__c =: objOrder.BT_Transaction_Id__c LIMIT 1];
		
		//create order transaction object 
		Order_Transaction__c objOrderTransaction = new Order_Transaction__c();
		objOrderTransaction.Order__c = objOrder.Id;
		objOrderTransaction.Order_Transaction_Type__c = auditType;
		objOrderTransaction.BT_Transaction_Details__c = objBTTran != null ? objBTTran.Id : null;
		objOrderTransaction.Order_Transaction_Status__c = 'Success';
		objOrderTransaction.Dealer_To_Customer_Note__c = objOrder.Customer_Notes__c;
		objOrderTransaction.Is_Adjustment__c = false;

	
		//post values
		objOrderTransaction.Total_Post_Adjustment_Shiping_Charge__c = objOrder.Updated_Shipping__c;
		objOrderTransaction.Total_Post_adjustment_Installation_Tax__c = Math.abs(objOrder.Total_Installation_Tax__c - objOrder.Total_Return_Installation_Tax__c);
		objOrderTransaction.Total_Post_adjustment_Shipping_Tax__c = objOrder.Current_Shipping_Tax__c;
		objOrderTransaction.Post_Adjustment_Total_Amount__c = objOrder.Updated_Order_Total__c;
		objOrderTransaction.Post_Adjustment_Total_Tax__c = objOrder.Updated_Total_Tax__c;
		objOrderTransaction.Adjustment_Date_Time__c = System.now();


		// Saravanan starts LTIM SPRINT -2 Data Rules Logic Dealer
		objOrderTransaction.Total_Post_Adjustment_Core_Charge_Qty__c = objOrder.Total_Core_Charge_Current_Quantity__c;
		objOrderTransaction.Total_Post_Adjustment_Core_Charge_Amount__c = objOrder.Total_Core_Charge_Current_Amount__c;
		objOrderTransaction.Total_Post_Adjustment_Core_Charge_Tax__c = objOrder.Total_Core_Charge_Current_Tax__c;

		//// Saravanan Ends LTIM SPRINT -2 Data Rules Logic Dealer
		Decimal taxValue = objOrder.Total_Core_Charge_Original_Tax__c /objOrder.Total_Core_Charge_Original_Quantity__c;
		if(auditType == 'Modified'){
			//pre values
			objOrderTransaction.Total_Pre_Adjustment_Shiping_Charge__c = oldOrder.Updated_Shipping__c;
			objOrderTransaction.Total_Pre_Adjustment_Shipping_Tax__c = oldOrder.Current_Shipping_Tax__c;                      
			objOrderTransaction.Pre_Adjustment_Total_Amount__c = oldOrder.Updated_Order_Total__c;
			objOrderTransaction.Is_Adjustment__c = true;

			// Saravanan Starts LTIM Sprint -2 Data Rules Logic Dealer Order Modofication
			objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Amount__c =0;
			objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Qty__c = 0;
			objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Tax__c =0;
			objOrderTransaction.Total_Post_Adjustment_Core_Charge_Amount__c =0;
			objOrderTransaction.Total_Post_Adjustment_Core_Charge_Qty__c =0;
			objOrderTransaction.Total_Post_Adjustment_Core_Charge_Tax__c =0;

			for(OrderItem objOrderItem : lstOldOrderItems){
				if(objOrderItem.Product_Type__c == Label.B2B_Product_Code_Core_Charges){
					objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Qty__c += (objOrderItem.Updated_Quantity__c + objOrderItem.Delta_Quantity__c);
					objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Amount__c += (objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Qty__c * objOrderItem.ListPrice);

					objOrderTransaction.Total_Post_Adjustment_Core_Charge_Amount__c += (objOrderItem.Updated_Quantity__c * objOrderItem.ListPrice); 
					objOrderTransaction.Total_Post_Adjustment_Core_Charge_Qty__c += objOrderItem.Updated_Quantity__c   ; 
				}

			}
			
			objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Tax__c =  (taxValue * objOrderTransaction.Total_Pre_Adjustment_Core_Charge_Qty__c).setscale(2); 
			objOrderTransaction.Total_Post_Adjustment_Core_Charge_Tax__c = objOrder.Total_Core_Charge_Current_Tax__c ;// (taxValue * objOrderTransaction.Total_Post_Adjustment_Core_Charge_Qty__c).setscale(2); 

			//objOrderTransaction.Post_Adjustment_Total_Amount__c = 0;
			//objOrderTransaction.Post_Adjustment_Total_Tax__c = 0;
			
			// Saravanan Ends LTIM Sprint - 2 Data Rules Logic Dealer Order Modification
		}
		insert objOrderTransaction; 
		
		// create Order_Transaction_Item__c 
		List<Order_Transaction_Item__c> lstOrderTranItems = new List<Order_Transaction_Item__c>();
		List<OrderItem> lstOrderItems = new List<OrderItem>();
		for(OrderItem objOrderItem : lstOldOrderItems){
			Order_Transaction_Item__c objOrderTranItem = new Order_Transaction_Item__c();
			objOrderTranItem.Order_Item__c = objOrderItem.Id;
			objOrderTranItem.Order_Transaction__c = objOrderTransaction.Id;                                           
			//post values    
			objOrderTranItem.Post_Adjustment_Quantity__c = objOrderItem.Updated_Quantity__c;
			objOrderTranItem.Post_Adjustment_Extended_Price__c = objOrderItem.Updated_Quantity__c * objOrderItem.ListPrice;
			objOrderTranItem.Total_Post_Adjustment_Product_Tax__c = objOrderItem.Total_Current_Product_Tax__c;
			objOrderTranItem.TotalPost_Adjustment_Installation_Charge__c = objOrderItem.Dealer_Installation_Price__c;
			if(auditType == 'Modified'){

				
				
                //pre values
                objOrderTranItem.Pre_Adjustment_Quantity__c = objOrderItem.Updated_Quantity__c + objOrderItem.Delta_Quantity__c;
                objOrderTranItem.Pre_Adjustment_Extended_Price__c = objOrderTranItem.Pre_Adjustment_Quantity__c * objOrderItem.ListPrice;  
                objOrderTranItem.Total_Pre_Adjustment_Product_Tax__c = (objOrderItem.Delta_Quantity__c > 0) ? objOrderItem.Total_Current_Product_Tax__c + objOrderItem.Total_Return_Product_Tax__c : objOrderItem.Total_Current_Product_Tax__c;
                if(objOrderItem.Delta_Quantity__c > 0){
                    objOrderItem.Delta_Quantity__c = 0;
                    objOrderItem.Total_Return_Product_Tax__c = 0;
                    lstOrderItems.add(objOrderItem);
                }

            }  
			objOrderTranItem.Adjustment_Date_Time__c = System.now();
            objOrderTranItem.AK_Order_Transaction_Item__c = objOrderItem.Id +''+ objOrderTransaction.Id; //Added by Ravi Prasad as part of HDMP-12002

			 // Saravanan starts LTIM SPRINT -2 Data Rules Logic for dealer
			 objOrderTranItem.AK_Order_Transaction_Item__c = objOrderItem.Product2.Core_Charge_Unit_Price__c > 0 || objOrderItem.Product_Type__c == label.B2B_Product_Code_Core_Charges ? 
															 objOrderTransaction.Id + '~' + objOrderItem.Id + '~' + objOrderItem.Product_Type__c : 'Test'; //REMAN-093

			// objOrderTranItem.Product_type__c = objOrderItem.Product2.Core_Charge_Unit_Price__c > 0 || objOrderItem.Product_Type__c == label.B2B_Product_Code_Core_Charges ? objOrderItem.Product_Type__c : objOrderTranItem.Product_Type__c;

			objOrderTranItem.Product_type__c = objOrderItem.Product_Type__c; // Bug HDMP-19394
				
			// Saravanan Ends LTIM SPRINT -2 Data Rules Logic for dealer

			lstOrderTranItems.add(objOrderTranItem);
		}
		

		if(!lstOrderTranItems.isEmpty()){
			insert lstOrderTranItems;
		}
        
        
        System.debug('here are weeeeeeee ' + lstOrderTranItems);
        
       
		
		if(!lstOrderItems.isEmpty()){
			update lstOrderItems;

			// Saravanan LTIM Added for 19500

			maporderTransIdtolstTransItems.put(objOrderTransaction.id,lstOrderTranItems);
		}
		return objOrderTransaction;
	}

	
	 /*
	Created By : Rajrishi Kaushik
	Date : 27/08/2021
	Description : This method is used to make a callout to vertex return tax api for line item cancellation.
	*/
	@future(callout=true)
	public static void callVertexOnOrderItemCancel(Set<Id> setOrderIds, Set<Id> setAccountIds,String strOrderList, String strOldOrderMap, String auditType){
		List<Error__c> lstErrors = new List<Error__c>();
		
		List<Account> lstAccounts = [SELECT Id, PoIId__c, BillingStreet, BillingCity, BillingState, BillingPostalCode                                   
									 FROM Account WHERE Id IN: setAccountIds];
		
		List<Order> lstOrders = [SELECT Id, AccountId, Restocking_Fees__c, Status, cart__r.ShippingAmount__c , cart__r.CustomerStreet__c, cart__r.CustomerCity__c, cart__r.Customer_State__c, cart__r.CustomerPostalCode__c,
								 IsError__c, cart__c
								 FROM Order 
								 WHERE Id IN: setOrderIds];
        
		// Saravanan/Pratik LTIM Added for Sprint 2 Data Rules - Product2.Core_Charge_Unit_Price__c,Product_Type__c 		
		// Saravanan Batch 2 TotalLineAmount ,Quantity		 
        List<OrderItem> lstOrderItems = [SELECT Id, Total_Return_Product_Tax__c, Total_Current_Product_Tax__c, Dealer_Installation_Price__c, Delta_Installation_Price__c,  Delta_Quantity__c,
                                          Updated_Quantity__c, ListPrice, Total_Tax__c,Product2.Core_Charge_Unit_Price__c,Product_Type__c,TotalLineAmount,Quantity	
                                          FROM OrderItem WHERE Type != 'Delivery Charge' AND OrderId IN: setOrderIds];
		
		Map<Id, Account> mapAccounts = new Map<Id, Account>();
		for(Account objAccount : lstAccounts){
			mapAccounts.put(objAccount.Id, objAccount);           
		}
		
		List<Error__c> errorObjList = new List<Error__c>();    
		if(!lstOrders.isEmpty()){
			Order objOrder = lstOrders[0];
			Account objAccount = mapAccounts.get(objOrder.AccountId);
			try{
				//call vertax line item return tax 
				B2B_BTVertexTaxCalculationIntegration.ResponseDataWrapper objResponseDataWrapper = B2B_BrainTreeUtils.callVertaxLineItemReturnTax(objAccount, objOrder, null, null); 
				
				if(objResponseDataWrapper.isSuccess == false){  
					errorObjList = [Select Id, Order_Transaction__c From Error__c Where Order__c =: objOrder.Id Order By CreatedDate Desc Limit 1];             
				}
			}catch(Exception ex){
				System.debug('exeption :-' + ex.getMessage() + ' line number : '+ ex.getLineNumber());                                                                      
				Error__c objError = B2B_BrainTreeUtils.createErrorRecord('Exception Occured ', objOrder.Id, ex.getMessage());
				objError.Line_Number__c = ex.getLineNumber();
				objError.StackTrace__c = ex.getStackTraceString();
				objError.Error_Type__c = ex.getTypeName();
				lstErrors.add(objError);                
			}           
		}
		
		//for HDMP-8716 : AuditTrail starts
		List<Order> orderList = (List<Order>) JSON.deserialize(strOrderList, List<Order>.class);
		Map<String, Order> mapOldOrders = (Map<String, Order>) JSON.deserialize(strOldOrderMap, Map<String, Order>.class);
		
		if(!orderList.isEmpty()){
			//create order transaction object 
			Order_Transaction__c objOrderTransaction = createOrderTransactionRecords(orderList[0], mapOldOrders, auditType, lstOrderItems);
            
			// Saravanan LTIM create Tax Transaction Records HDMP-19500
			createVertexRecords(objOrderTransaction,orderList[0]);
			// Saravanan LTIM create Tax Transaction Record HDMP-19500
            //Start
            // added for R2C1 : Tax Transaction to have a lookup to Order Transaction
            List<Vertex_Details__c> lstTaxTransactions = new List<Vertex_Details__c>();
            for(Vertex_Details__c objDetails : [SELECT Id, Order_Transaction__c FROM Vertex_Details__c WHERE Order__c =: orderList[0].Id AND Order_Transaction__c = null]){
                objDetails.Order_Transaction__c = objOrderTransaction.Id;
                lstTaxTransactions.add(objDetails);
            }
            
            if(!lstTaxTransactions.isEmpty()){
                update lstTaxTransactions;
            }
            //End
            
			if(!errorObjList.isEmpty()){
				errorObjList[0].Order_Transaction__c = objOrderTransaction.Id;
				update errorObjList;
			}
		}
	   	//for HDMP-8716 : AuditTrail ends
		
		// update Error object        
		if(!lstErrors.isEmpty())
			insert lstErrors;
		 
	}    
	 /*
	Created By : saikiran
	Date : 22/06/2022
	Description : This method generates order ref number if status changes to Activated
	modified Date : 03/08/2022 updated by saikiran as part of HDMP-11730
	modified Date : 26/08/2022 updated by saikiran as part of HDMP-12833
	*/
    public static void generateOrderReference(List<Order> orders , Map<Id,Order> mapOldOrders){
		firstcall = true;
		String dealerType ;
		Map<String ,B2B_Order_Reference_Number_Prefix__mdt> prefixMap = new Map<String ,B2B_Order_Reference_Number_Prefix__mdt>() ;
        Set<Id> dealerIdSet = new Set<Id>();
        for(Order ord : orders){
            dealerIdSet.add(ord.AccountId);
        }
		Map<Id , Account> accountMap =new Map<Id , Account>([select Id,Name,DivisionCd__c,Current_Dealer_Order_Seq_Number__c, PoIId__c FROM Account WHERE Id IN: dealerIdSet]);
		List<Account> accountsToUpdate = new List<Account>();
		List<Order> orderToUpdate = new List<Order>();
        List<Invoice__c> invoices = new List<Invoice__c>();//Added by Faraz for HDMP-11820
		for(B2B_Order_Reference_Number_Prefix__mdt refPrefix :[SELECT Brand__c, Id,Order_Delivery_Type__c, Order_Type_Prefix__c 
															   FROM B2B_Order_Reference_Number_Prefix__mdt]){
				  prefixMap.put(refPrefix.Brand__c + '-' + refPrefix.Order_Delivery_Type__c, refPrefix);
			  }
		// Saravanan LTIM Added Total_Core_Charge_Current_Amount__c in SOQL	  
		for(Order ord: [SELECT Delivery_Types__c, OrderReferenceNumber, Status,AccountId,Total_Core_Charge_Current_Amount__c,(SELECT Id, Order_Reference_Number__c FROM Invoices__r) FROM Order WHERE Id =: orders] ){
			if(mapOldOrders.get(ord.Id).status != ord.Status && mapOldOrders.get(ord.Id).status == 'Draft' && ord.Status == 'Activated'){//Added by saikiran as part of HDMP-12833
				String refnumber ;
				Account  dealerAccount= accountMap.get(ord.AccountId);
				String deliveryType = ord.Delivery_Types__c ;
				if(dealerAccount.DivisionCd__c != null && dealerAccount.DivisionCd__c == 'A'){
                    dealerType =  'Honda Auto';
                }
                else if(dealerAccount.DivisionCd__c != null && dealerAccount.DivisionCd__c == 'B') {
                    dealerType =  'Acura';
                }
				String dealerTypeAnddeliveryTypeKey = dealerType + '-' + deliveryType;
                if(prefixMap.containsKey(dealerTypeAnddeliveryTypeKey)){
					B2B_Order_Reference_Number_Prefix__mdt prfixList = prefixMap.get(dealerTypeAnddeliveryTypeKey);
                    if(deliveryType != '' &&  deliveryType == prfixList.Order_Delivery_Type__c){
						refnumber = '000000000';
						if(dealerAccount.Current_Dealer_Order_Seq_Number__c == null){
							dealerAccount.Current_Dealer_Order_Seq_Number__c = 1;
						}
						refnumber =  refnumber + dealerAccount.Current_Dealer_Order_Seq_Number__c;
						if(refnumber.length() > 10){
							refnumber =  refnumber.substring(refnumber.length()-10);
						}
						refnumber = prfixList.Order_Type_Prefix__c + refnumber ;
						dealerAccount.Current_Dealer_Order_Seq_Number__c  = dealerAccount.Current_Dealer_Order_Seq_Number__c + 1;
					}
                    ord.OrderReferenceNumber = refnumber ;
                    ord.AK_Order__c = ord.OrderReferenceNumber +'~'+ dealerAccount.PoIId__c; //Added by Ravi Prasad to populate AK Order as part of R2B
                    orderToUpdate.add(ord);
                    accountsToUpdate.add(dealerAccount);
					//Added by Faraz for HDMP-11820
					if(ord.Invoices__r.size() > 0 && ord.Delivery_Types__c == 'Install At Dealer'){
                        Invoice__c invoiceObj = new Invoice__c(Id = ord.Invoices__r[0].Id, Order_Reference_Number__c = ord.OrderReferenceNumber);
                        invoices.add(invoiceObj);
                    }
					//End HDMP-11820
                }
			}
		}
		if(!orderToUpdate.isEmpty() && !accountsToUpdate.isEmpty()){
		   Update orderToUpdate;
		   Update accountsToUpdate;
		}
		//Added by Faraz for HDMP-11820
		if(!invoices.isEmpty()){
            update invoices;
        }
		//End HDMP-11820
	}
}
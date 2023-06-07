/**
* @File Name          : B2B_DraftOrderUpdateController
* @Description        : This class invoked from Checkout Flow to update order and order item fields in Draft status
* @Created By         : Rajrishi
* @Date               : 28/10/2022
* @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
* @Test Class Name	  : B2B_DraftOrderUpdateControllerTest
*==============================================================================
* Ver         Date                   Author              Modification
*==============================================================================
* 1.0       28/10/2022               Rajrishi            Initial Version
**/
public class B2B_DraftOrderUpdateController {
    
    //Input Class with attributes to be passed from the Flow
    public class FlowInputs {
        @InvocableVariable(label='Order ID' description='ID for the Current Order') 
        public String orderId;
        
        @InvocableVariable(label='Cart ID' description='ID for the Cart on the Order') 
        public String cartId;
    }
    
    @InvocableMethod(label='Update: draft order' description='Flow Step to update draft order')
    public static void updateOrderAndOrderItem(List<FlowInputs> request) {
        FlowInputs req = request[0];
        String orderId = req.orderId;
        String cartId = req.cartId;
        Decimal orderQuantity = 0;
        Decimal totalCoreCharge = 0; // Added by Ashwin for bug fix 18157
        Decimal totalUpdatedOrdAmt = 0; // Added by Ashwin for bug fix 18157
        Decimal orderProductTax = 0;
        Decimal coreChargeTotalCurrentAmount = 0; // Saravanan LTIM HDMP-16540

        Order orderObj = new Order(); // Saravanan LTIM moved the declaration the variable on Top from bottom for Sprint 1 Data Rules 
        
        if(String.isNotEmpty(orderId) && String.isNotEmpty(cartId)){
            // Saravanan LTIM Added Total_Core_Charge_Current_Amount__c  API in SOQL for HDMP-16540
            Order objOrder = [SELECT Id, Customer_Preferred_Speeds__c, cart__c, Account.Email__c, Account.PoIId__c,Total_Core_Charge_Current_Amount__c
                              FROM Order 
                              WHERE Id =: orderId limit 1];
            
            WebCart objCart = [SELECT Id, Shipping_Note__c, CustomerStreet__c, CustomerCity__c, Customer_State__c, CustomerPostalCode__c, CustomerCountry__c, 
                               Product_Division__c, Product_Subdivision__c, ShippingAmount__c, Customer_Phone__c, Total_Shipping_Tax__c, Total_Installation_Tax__c,
                               Customer_Name__c, Delivery_Type__c, Honda_Shipping_Speed__c, Honda_Shipping_Speed__r.Honda_Speed_Name__c,
                               TOTAL__c, Total_Tax__c, TotalProductAmount, Total_Installation_Charge__c
                               FROM WebCart WHERE Id =: cartId limit 1];
            
            // LTIM Added a Field Product_Type__c API for Sprint 2 - 16540
            // Saravanan LTIM Added Product2Id.Core_Charge_Unit_Price__c,Product2.Name for Data Rules
            
            List<OrderItem> orderItems = [SELECT Id, Quantity, Total_Tax__c, Item_Package_Quantity__c, Product_Model_Marketing_Name__c, 
                                          Product_Division__c, Product_Subdivision__c, Product_Model__c, Product2Id, AK_Order_Item__c, Total_Current_Product_Tax__c, 
                                          Color__c, Op_Code__c, Product_Identifier__c,Description, Updated_Quantity__c, Cart_Item_Product_Name__c, Dealer_Installation_Price__c ,Product_Type__c,Product2.Core_Charge_Unit_Price__c,unitprice,Product2.Name
                                          FROM OrderItem WHERE OrderId =: orderId];
            // LTIM Added a Field Product_Type__c API for Sprint 2 - 16540
            // Saravanan LTIM Added API ,B2B_Item_Total_Tax__c,Quantity,salesprice fpr Sprint 2 Data Rules - Order Check out 
            List<CartItem> cartItems = [SELECT Id, Name, Dealer_Installation_Price__c, Item_Package_Quantity__c, SalesPrice, Product_Model_Marketing_Name__c, Product_Division__c, 
                                        Product_Subdivision__c, Product_Model__c, Product2Id, B2B_Item_Total_Tax__c, Color__c, Op_Code__c, Product_Identifier__c, Quantity,listprice,Product_Type__c,TotalLineAmount
                                        FROM CartItem WHERE CartId =: objOrder.cart__c];
            
            Map<String, CartItem> cartItemProductIdMap = new Map<String, CartItem>();
            Map<String, CartItem> CoreChargeCartItemMap = new Map<String, CartItem>(); // Added Map for SP1-16549
            for(CartItem itemObj : cartItems){
                // Added if conditions for LTIM SP1-16549
                if(itemObj.Name.contains('(CORE CHARGE)')){

                    CoreChargeCartItemMap.put(itemObj.Product2Id, itemObj);
                     // Saravanan LTIM Added HDMP-16540
                 
                    
                  // Saravanan LTIM Added for Sprint 2 - Order Checkout, Cancellation, Modification, & Fulfillment
                  orderObj.Total_Core_Charge_Original_Amount__c = orderObj.Total_Core_Charge_Original_Amount__c == null ? itemObj.TotalLineAmount : orderObj.Total_Core_Charge_Original_Amount__c + itemObj.TotalLineAmount;
                  orderObj.Total_Core_Charge_Current_Amount__c = orderObj.Total_Core_Charge_Current_Amount__c == null ? itemObj.TotalLineAmount : orderObj.Total_Core_Charge_Current_Amount__c + itemObj.TotalLineAmount;
                  orderObj.Total_Core_Charge_Original_Quantity__c = orderObj.Total_Core_Charge_Original_Quantity__c == null ? itemObj.Quantity : orderObj.Total_Core_Charge_Original_Quantity__c + itemObj.Quantity; 
                  orderObj.Total_Core_Charge_Current_Quantity__c = orderObj.Total_Core_Charge_Current_Quantity__c == null ? itemObj.Quantity : orderObj.Total_Core_Charge_Current_Quantity__c + itemObj.Quantity; 
                  orderObj.Total_Core_Charge_Original_Tax__c = orderObj.Total_Core_Charge_Original_Tax__c == null ? itemObj.B2B_Item_Total_Tax__c : orderObj.Total_Core_Charge_Original_Tax__c + itemObj.B2B_Item_Total_Tax__c;                   
                  orderObj.Total_Core_Charge_Current_Tax__c = orderObj.Total_Core_Charge_Current_Tax__c == null ? itemObj.B2B_Item_Total_Tax__c : orderObj.Total_Core_Charge_Current_Tax__c + itemObj.B2B_Item_Total_Tax__c;
                  // Saravanan LTIM Ends for Sprint 2 - Order Checkout, Cancellation, Modification, & Fulfillment

                }
                // Added else conditions for SP1-16549
                else{
                    cartItemProductIdMap.put(itemObj.Product2Id, itemObj);
                }

            }

            

            for(OrderItem itemObj : orderItems){
                if(cartItemProductIdMap.containsKey(itemObj.Product2Id)){
                    CartItem cartItemObj = cartItemProductIdMap.get(itemObj.Product2Id);
                    // LTIM Added below assignment for SP1-16549
                    CartItem coreChargeItem = CoreChargeCartItemMap.get(itemObj.Product2Id);
                    itemObj.Item_Package_Quantity__c = cartItemObj.Item_Package_Quantity__c;
                    itemObj.Product_Model_Marketing_Name__c = cartItemObj.Product_Model_Marketing_Name__c;
                    itemObj.Product_Division__c = cartItemObj.Product_Division__c;
                    itemObj.Product_Subdivision__c = cartItemObj.Product_Subdivision__c;
                    itemObj.Product_Model__c = cartItemObj.Product_Model__c;
                    itemObj.AK_Order_Item__c = orderId + '' + itemObj.Product2Id;
                    itemObj.Total_Current_Product_Tax__c = cartItemObj.B2B_Item_Total_Tax__c;
                    itemObj.Total_Tax__c = cartItemObj.B2B_Item_Total_Tax__c;
                    itemObj.Color__c = cartItemObj.Color__c;
                    itemObj.Op_Code__c = cartItemObj.Op_Code__c;
                    itemObj.Product_Identifier__c = cartItemObj.Product_Identifier__c;
               		itemObj.Updated_Quantity__c = cartItemObj.Quantity;
                    itemObj.Cart_Item_Product_Name__c =  cartItemObj.Name; // Saravanan LTIM Removed Terernary Conditions for HDMP-18577
                    // LTIM Added a Field assignment for SP2-16540
                    itemObj.Product_Type__c = itemObj.Description.contains(Label.B2B_Reman_Part_Core_Charge_Identification_Label) ? Label.B2B_Product_Code_Core_Charges : itemObj.Product2.Core_Charge_Unit_Price__c > 0 ? 'Part' :  cartItemProductIdMap.get(itemObj.Product2Id).Product_Type__c; // Saravanan LTIM 

                    // condition started by ashwin for reassigning values to the fields if Item type is Core Charge as part of HDMP-18867 bug fixing 
                    if(itemObj.Product_Type__c == Label.B2B_Product_Code_Core_Charges){
                        itemObj.Total_Current_Product_Tax__c = coreChargeItem.B2B_Item_Total_Tax__c; 
                        itemObj.Total_Tax__c = coreChargeItem.B2B_Item_Total_Tax__c;
                    }
                     // condition ended by ashwin as part of HDMP-18867 bug fixing
                    
                    // Added by Ashwin for bug fix 18157
                    if(itemObj.Product_Type__c == Label.B2B_Product_Code_Core_Charges){
                        totalCoreCharge +=   itemObj.unitprice * itemObj.Quantity;
                    }
                    
                    // Saravanan LTIM Added for Sprint 2 - Data Rules Order Checkout
                    // Below If Condition Execute only for Core charge and Reman Products
                    if(itemObj.Product_Type__c == Label.B2B_Product_Code_Core_Charges || itemObj.Product2.Core_Charge_Unit_Price__c > 0 || itemObj.description.contains(Label.B2B_Reman_Part_Identification_Label)){
                        itemObj.AK_Order_Item__c = OrderId +'~'+ itemObj.Product2Id+'~'+ itemObj.Product_Type__c;
                        itemObj.UnitPrice = itemObj.Product_Type__c == Label.B2B_Product_Code_Core_Charges ? coreChargeItem.SalesPrice : cartItemObj.SalesPrice ;
                        // Added for HDMP-18577
                        itemObj.Cart_Item_Product_Name__c = itemObj.Product_Type__c == Label.B2B_Product_Code_Core_Charges ? itemObj.Product2.Name+' '+Label.B2B_Reman_Part_Core_Charge_Identification_Label : itemObj.Product2.Name+' '+Label.B2B_Reman_Part_Identification_Label;
                        
                        
                    }
                    // Saravanan LTIM Ends for Sprint 2 - Data Rules Order Checkout
                    
                    itemObj.Dealer_Installation_Price__c = cartItemObj.Dealer_Installation_Price__c;
                }
                // Saravanan LTIM Added the below conditions for Sprint 2 Data Rule REMAN-073
                if(itemObj.Product_Type__c != Label.B2B_Product_Code_Core_Charges){
                    orderQuantity += itemObj.Quantity;
                    orderProductTax += itemObj.Total_Tax__c != null ? itemObj.Total_Tax__c : 0; // REMAN-073
                }
                //Saravanan LTIM Removed 
                //orderProductTax += itemObj.Total_Tax__c != null ? itemObj.Total_Tax__c : 0;
            }

            // Order orderObj = new Order(); Declaration moved to Top Saravanan LTIM for Sprint 2 Data Rules
            orderObj.Id = orderId;
            totalUpdatedOrdAmt = objCart.TotalProductAmount - totalCoreCharge; // Added by Ashwin for bug fix 18157
                
            String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
            if(String.isNotEmpty(personAccountId))
                orderObj.Account__c = personAccountId;
            if(objCart.Delivery_Type__c =='Ship To Me'){
                orderObj.Customer_Preferred_Speeds__c = (objCart.Honda_Shipping_Speed__c != null) ? objCart.Honda_Shipping_Speed__r.Honda_Speed_Name__c : '';
            	orderObj.Shipping_Note__c = objCart.Shipping_Note__c;
            }else{
                orderObj.Customer_Preferred_Speeds__c = null;
            	orderObj.Shipping_Note__c = '';
            }
            orderObj.Delivery_Types__c = objCart.Delivery_Type__c;
            orderObj.Dealer_Email__c = objOrder.Account.Email__c;
            orderObj.Dealer_Number__c = objOrder.Account.PoIId__c;
            orderObj.ShippingPhoneNumber__c = objCart.Customer_Phone__c;
            orderObj.Product_Division__c = objCart.Product_Division__c;
            orderObj.Product_Subdivision__c = objCart.Product_Subdivision__c;
            orderObj.Shipping_Customer_Name__c = objCart.Customer_Name__c;
            orderObj.Quantity__c = orderQuantity;
            orderObj.Current_Quantity__c = orderQuantity;
            orderObj.Total_Original_Product_Tax__c = orderProductTax;
            orderObj.Total_Amount__c = ( objCart.TOTAL__c != null ?  objCart.TOTAL__c : 0) - (objCart.Total_Tax__c != null ? objCart.Total_Tax__c : 0);
            orderObj.Total_Current_Product_Tax__c = orderProductTax;
            orderObj.Total_Current_Pre_Tax_Order_Amount__c = ( objCart.TOTAL__c != null ?  objCart.TOTAL__c : 0) - (objCart.Total_Tax__c != null ? objCart.Total_Tax__c : 0);
           
            //Filling current order fields               
            orderObj.Updated_Order_Total__c = objCart.TOTAL__c;
            orderObj.Updated_Total_Tax__c = objCart.Total_Tax__c;
            orderObj.Updated_Order_Amount__c = totalCoreCharge != 0 ? totalUpdatedOrdAmt : objCart.TotalProductAmount ; //totalUpdatedOrdAmt Added by Ashwin for bug fix 18157 privious:objCart.TotalProductAmount
            orderObj.Updated_Shipping__c = objCart.ShippingAmount__c;
            
            //Filling original order fields
            orderObj.Original_Shipping_Amount__c = objCart.ShippingAmount__c;
            orderObj.GrandTotalAmount__c = objCart.TOTAL__c;
            orderObj.TotalTaxAmount__c = objCart.Total_Tax__c;
            orderObj.Total_Original_Product_Amount__c =  objCart.TotalProductAmount - totalCoreCharge ; // objCart.TotalProductAmount; Saravanan Removed Total Product Amount REMAN-073
            orderObj.Total_Installation_Charges__c = objCart.Total_Installation_Charge__c;
            
            //shipping fields
            orderObj.ShippingStreet = objCart.CustomerStreet__c;
            orderObj.ShippingCity = objCart.CustomerCity__c;
            orderObj.ShippingState = objCart.Customer_State__c;
            orderObj.ShippingPostalCode = objCart.CustomerPostalCode__c;
            orderObj.ShippingCountry  = objCart.CustomerCountry__c;
            orderObj.Total_Shipping_Tax__c = objCart.Total_Shipping_Tax__c;
           	orderObj.Current_Shipping_Tax__c = objCart.Total_Shipping_Tax__c;
            orderObj.Total_Installation_Tax__c = objCart.Total_Installation_Tax__c;


           
            
            update orderObj;
            update orderItems;
        }        	
    }
    
}
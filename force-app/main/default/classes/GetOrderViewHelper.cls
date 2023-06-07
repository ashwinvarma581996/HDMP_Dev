/*******************************************************************************
	Name: GetOrderViewHelperTest
    Business Unit: HDM
	Date: 07/01/2022
	Developer: Yashika
	Description: To fetch fields related to order to use in findMyOrder and OrderView comp.
	*******************************************************************************
	MODIFICATIONS – V1 | 09/06/2022 | Sayalee | Added Header
	*******************************************************************************/

    public without sharing class GetOrderViewHelper {
    
        @AuraEnabled
        public static List<Order> OrderDetails(String record){
            List<Order> orderlist = new List<Order>();
            //Added field for installation charges by shalini soni 24 Dec 2021 for R2 Story
            //schedule_installation__c, Delivery_Type__c fields added in query by Yashika for R2 story: appointment scheduling
            //fields added for r2 story order return
            if(!String.isEmpty(record)){
                //Added Total_Core_Charge_Current_Amount__c, as part of 18157 Total_Core_Charge_Return_Amount__c for 19414
                orderlist =[SELECT Id,Total_Item_Return__c,Total_Restocking_Fees__c,Total_Ship_Return__c,Total_Tax_Return__c,Total_Return__c,IsPaymentReproccessing__c,Total_Core_Charge_Current_Amount__c,
                            Order.cart__r.Total_Installation_Charge__c,BillingStreet,BillingPhoneNumber, BillingCity, BillingState, BillingPostalCode,OrderReferenceNumber,
                            Shipping_Vendors__c,Other_Carrier__c, CC_Last4__c,Cart__r.TOTAL__c,Cart__r.TotalProductAmount,Total_Installation_Charges__c,
                            Updated_Order_Total__c,Updated_Order_Amount__c,Updated_Total_Tax__c, EffectiveDate,GrandTotalAmount__c,cart__r.Customer_Name__c,
                            Customer_Name__c,cart__r.Customer_Phone__c, OrderNumber,cart__r.customerAddress__c,cart__r.CustomerStreet__c,cart__r.CustomerCity__c,
                            cart__r.Customer_State__c, cart__r.CustomerPostalCode__c,cart__r.Delivery_Type__c, Name,Status,OrderedDate,
                            Order.CustomerOrderStatus__c, GrandTotalAmount,BillingEmailAddress,Account.Name, ShippingNumber__c,TotalAmount, cart__r.Total_Tax__c, 
                            cart__r.ShippingAmount__c,cart__r.Pickup_Dealer__c,Account.Service_Scheduling_URL__c, Account.Phone, Account.Operation_Hour__c, Account.Email__c,Account.Return_Policy__c, Account.Privacy_Policy_URL__c,
                            Cart__r.DealerId__r.shippingStreet,Cart__r.DealerId__r.shippingCity,Cart__r.DealerId__r.shippingState,Cart__r.DealerId__r.ShippingPostalCode, 
                            Cart__r.DealerId__r.Email__c,Total_Installation_Return__c,Updated_Shipping__c, Customer_Notes__c,ShippingCity,Payment_Type__c,
                            ShippingState,ShippingStreet,ShippingPostalCode,ShippingCountry,Shipping_Customer_Name__c,Total_Amount__c,TotalTaxAmount__c,Customer_Preferred_Speeds__c,Dealer_Shipping_Speed__c,Delivery_Types__c,Total_Core_Charge_Return_Amount__c,(SELECT CreatedDate,Adjustment_Date_Time__c,Order_Transaction_Type__c, Dealer_To_Customer_Note__c FROM Order_Transactions__r) 
                            FROM Order 
                            WHERE OrderNumber=:record];
            }
            // Added by saikiran velugundula as part removing HTML tags from return policy 
            // for(Order order : orderlist ){
            //     if(order.Account.Return_Policy__c != NULL){
            //         String returnPolicy =  order.Account.Return_Policy__c ;
            //         order.Account.Return_Policy__c  =  returnPolicy.stripHtmlTags();
            //     }
            // }
                return orderlist;
    
        }
        
    }
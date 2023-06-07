/******************************************************************************* 
Name:  B2B_GetOrderInfoTest
Business Unit: HDM
Create By: Sayeed Shaik 
Date: 22/10/2021
Description: It is created to code coverage for B2B_GetOrderInfo apex class.

******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
		  25/08/2022 | <Vipul>  | HDMP-5357,HDMP-5358 
*******************************************************************************/

public without sharing class B2B_GetOrderInfo {
    
    
    @AuraEnabled(cacheable=true)
    public static list<OrderRelatedWrapper> getOrderList(string searchKey, string searchKey1, string searchKey2 ) {
        string searchKeyword =  searchKey ;
        string searchKeyword1 =  searchKey1 ;
        string searchKeyword2=  searchKey2 ;
       
       // create order list to store search result 
        
        List<OrderRelatedWrapper> WrapperList=new List<OrderRelatedWrapper>();

        if(searchKeyword1=='')
        { 
            //Updated Query by saikiran as part of HDMP-12150
            for(OrderItem rel:[SELECT Id,Order.Delivery_Types__c,Order.OrderedDate,Order.Total_Return__c,Order.Updated_Order_Total__c,Order.Other_Carrier__c, Order.EffectiveDate, Order.ShowShippingInfo__c,Order.Shipping_Vendors__c,Order.CustomerOrderStatus__c, Order.ShippingNumber__c,Order.Account.Name, Type, OrderId, Order.AccountId, Order.OrderNumber, Order.Status, Order.ActivatedDate, Order.ShippingAddress, Order.GrandTotalAmount,Order.OrderReferenceNumber  FROM OrderItem WHERE (Order.OrderReferenceNumber = :searchKeyword OR Order.OrderNumber = :searchKeyword)  and Order.BillingPostalCode LIKE : searchKeyword2+'%' and Type='Order Product' ORDER BY Order.EffectiveDate DESC])
            {
                
                OrderRelatedWrapper relwrap= new OrderRelatedWrapper();
                relWrap.OrderNumber= rel.Order.OrderNumber;
                relWrap.OrderReferenceNumber= rel.Order.OrderReferenceNumber;
                relWrap.OtherCarrier= rel.Order.Other_Carrier__c;
                relWrap.isStatusDraft= rel.Order.Status == 'Draft' ? true : false;
                if(rel.Order.Status=='ORDER COMPLETE - SHIPPED' || rel.Order.Status=='ORDER RETURN' || rel.Order.Status=='PARTIAL RETURN'){
                relWrap.showshippingNumber= true;
                }
                else{
                    relWrap.showshippingNumber= false;
                }
                if(rel.Order.Total_Return__c==null){
                    rel.Order.Total_Return__c=0;
                }
                if(rel.Order.Updated_Order_Total__c!=null){
                    
                relWrap.OrderTotal= string.valueof(Math.abs(rel.Order.Updated_Order_Total__c - rel.Order.Total_Return__c));
                }
                String withoutTime= String.valueof(Date.valueof(rel.Order.OrderedDate));
                String finaltime = withoutTime.split('-')[1]+'/'+ withoutTime.split('-')[2] + '/'+ withoutTime.split('-')[0];
                relWrap.ActivatedDate = finaltime;// relWrap.productName= rel.Product2.Name;
                relWrap.GrandTotalAmount = rel.Order.GrandTotalAmount;
                relWrap.AccountId= rel.Order.Account.Name;
                relWrap.ShippingNumber=rel.Order.ShippingNumber__c;
               relwrap.Status=rel.Order.Status;
               relWrap.ShippingVendor= rel.Order.Shipping_Vendors__c;
               relWrap.CustomerOrderStatus= rel.Order.CustomerOrderStatus__c;
               if(rel.Order.Shipping_Vendors__c=='Other' || rel.Order.Shipping_Vendors__c=='other'){
                relWrap.Othercarrierpresent= true;
               }
               else{
               relWrap.Othercarrierpresent= false;
               }
                // relwrap.ShippingAddress=rel.Order.ShippingAddress;
                
                WrapperList.add(relwrap);
                
                // ImageMap.put(rel.Relatedproduct__r.Id,getproductInfo.defaultImage.url);
            }
            
        }
        if((searchKeyword1!='') && (searchKeyword2=='')){
            //Updated Query by saikiran as part of HDMP-12150
            for(OrderItem rel:[SELECT Id,Order.Delivery_Types__c,Order.OrderedDate,Order.Total_Return__c,Order.Updated_Order_Total__c,Order.Other_Carrier__c,Order.EffectiveDate,Order.ShowShippingInfo__c,Order.Shipping_Vendors__c, Order.CustomerOrderStatus__c,Order.ShippingNumber__c,Order.Account.Name, Type, OrderId,Order.ActivatedDate, Order.OrderNumber, Order.Status, Order.AccountId, Order.ShippingAddress, Order.GrandTotalAmount, Order.OrderReferenceNumber  FROM OrderItem WHERE (Order.OrderReferenceNumber = :searchKeyword OR Order.OrderNumber = :searchKeyword)  and Order.BillingEmailAddress=:searchKeyword1 and Type='Order Product' ORDER BY Order.EffectiveDate DESC])
            {
                
                OrderRelatedWrapper relwrap= new OrderRelatedWrapper();
                relWrap.OrderNumber= rel.Order.OrderNumber;
                relWrap.OrderReferenceNumber = rel.Order.OrderReferenceNumber;
                relWrap.OtherCarrier= rel.Order.Other_Carrier__c;
                relWrap.isStatusDraft= rel.Order.Status == 'Draft' ? true : false;
                if(rel.Order.Status=='ORDER COMPLETE - SHIPPED' || rel.Order.Status=='ORDER RETURN' || rel.Order.Status=='PARTIAL RETURN'){
                    relWrap.showshippingNumber= true;
                    }
                    else{
                        relWrap.showshippingNumber= false;
                    }
                if(rel.Order.Total_Return__c==null){
                     rel.Order.Total_Return__c=0;
                }
                if(rel.Order.Updated_Order_Total__c!=null){
                relWrap.OrderTotal= string.valueof(Math.abs(rel.Order.Updated_Order_Total__c - rel.Order.Total_Return__c));
                }
                relWrap.AccountId= rel.Order.Account.Name;
                String withoutTime= String.valueof(Date.valueof(rel.Order.OrderedDate));
                String finaltime = withoutTime.split('-')[1]+'/'+ withoutTime.split('-')[2] + '/'+ withoutTime.split('-')[0];
                relWrap.ActivatedDate = finaltime;// relWrap.productName= rel.Product2.Name;
                relWrap.GrandTotalAmount = rel.Order.GrandTotalAmount;
                relWrap.ShippingNumber=rel.Order.ShippingNumber__c;
               
                relwrap.Status=rel.Order.Status;
                relWrap.ShippingVendor= rel.Order.Shipping_Vendors__c;
                relWrap.CustomerOrderStatus= rel.Order.CustomerOrderStatus__c;
                if(rel.Order.Shipping_Vendors__c=='Other' || rel.Order.Shipping_Vendors__c=='other'){
                    relWrap.Othercarrierpresent= true;
                   }
                   else{
                   relWrap.Othercarrierpresent= false;
                   }
                // relwrap.ShippingAddress=rel.Order.ShippingAddress;
                WrapperList.add(relwrap);
                // ImageMap.put(rel.Relatedproduct__r.Id,getproductInfo.defaultImage.url);
            }
            
        }
        if(((searchKeyword1!='') && (searchKeyword2!=''))&&(searchKeyword=='')){
            
            for(Order rel:[SELECT  Id,Delivery_Types__c,OrderedDate,Total_Return__c,Updated_Order_Total__c,Other_Carrier__c,EffectiveDate,ShowShippingInfo__c, Shipping_Vendors__c, ShippingNumber__c,Order.CustomerOrderStatus__c, Account.Name, Type, ActivatedDate, OrderNumber,Status,  ShippingAddress, GrandTotalAmount , OrderReferenceNumber  FROM Order  WHERE BillingPostalCode LIKE : searchKeyword2+'%'  and BillingEmailAddress=:searchKeyword1 ORDER BY EffectiveDate DESC ])
            {
                
                OrderRelatedWrapper relwrap= new OrderRelatedWrapper();
                if(rel.Total_Return__c==null){
                    rel.Total_Return__c=0;
                }
                if(rel.Updated_Order_Total__c!=null){
                relWrap.OrderTotal= string.valueof(Math.abs(rel.Updated_Order_Total__c - rel.Total_Return__c));
                }
                relWrap.OtherCarrier= rel.Other_Carrier__c;
                relWrap.isStatusDraft= rel.Status == 'Draft' ? true : false;
                if(rel.Status=='ORDER COMPLETE - SHIPPED' || rel.Status=='ORDER RETURN' || rel.Status=='PARTIAL RETURN'){
                    relWrap.showshippingNumber= true;
                    }
                    else{
                        relWrap.showshippingNumber= false;
                    }relWrap.OrderNumber= rel.OrderNumber;
                relwrap.OrderReferenceNumber = rel.OrderReferenceNumber;
                relWrap.AccountId= rel.Account.Name;
                String withoutTime= String.valueof(Date.valueof(rel.OrderedDate));
                String finaltime = withoutTime.split('-')[1]+'/'+ withoutTime.split('-')[2] + '/'+ withoutTime.split('-')[0];
                relWrap.ActivatedDate = finaltime;
                // relWrap.productName= rel.Product2.Name;
                relWrap.GrandTotalAmount = rel.GrandTotalAmount;
                relWrap.ShippingNumber=rel.ShippingNumber__c;
               
                
                relwrap.Status=rel.Status;
                relWrap.ShippingVendor= rel.Shipping_Vendors__c;
                relWrap.CustomerOrderStatus= rel.CustomerOrderStatus__c;
                if(rel.Shipping_Vendors__c=='Other' || rel.Shipping_Vendors__c=='other'){
                    relWrap.Othercarrierpresent= true;
                   }
                   else{
                   relWrap.Othercarrierpresent= false;
                   }
                // relwrap.ShippingAddress=rel.Order.ShippingAddress;
            
                WrapperList.add(relwrap);
                // ImageMap.put(rel.Relatedproduct__r.Id,getproductInfo.defaultImage.url);
            }
            
        }
        else if(searchKeyword!='' && searchKeyword1!='' && searchKeyword2!=''){
            //Updated Query by saikiran as part of HDMP-12150
            for(OrderItem rel:[SELECT Id,Order.Delivery_Types__c,Order.OrderedDate,Order.Total_Return__c,Order.Updated_Order_Total__c,Order.Other_Carrier__c,Order.EffectiveDate,Order.ShowShippingInfo__c,Order.Shipping_Vendors__c, Order.ShippingNumber__c,Order.CustomerOrderStatus__c,Order.Account.Name, Type, OrderId, Order.ActivatedDate, Order.OrderNumber, Order.Status, Order.AccountId, Order.ShippingAddress, Order.GrandTotalAmount,Order.OrderReferenceNumber  FROM OrderItem WHERE (Order.OrderReferenceNumber = :searchKeyword OR Order.OrderNumber = :searchKeyword)  and Order.BillingEmailAddress=:searchKeyword1 and Order.BillingPostalCode LIKE : searchKeyword2+'%' and Type='Order Product' ORDER BY Order.EffectiveDate DESC])
            {
                
                OrderRelatedWrapper relwrap= new OrderRelatedWrapper();
                relWrap.OrderNumber= rel.Order.OrderNumber;
                relWrap.OrderReferenceNumber = rel.Order.OrderReferenceNumber;
                relWrap.OtherCarrier= rel.Order.Other_Carrier__c;
                relWrap.isStatusDraft= rel.Order.Status == 'Draft' ? true : false;
                if(rel.Order.Status=='ORDER COMPLETE - SHIPPED' || rel.Order.Status=='ORDER RETURN' || rel.Order.Status=='PARTIAL RETURN'){
                    relWrap.showshippingNumber= true;
                    }
                    else{
                        relWrap.showshippingNumber= false;
                    }    
                    if(rel.Order.Total_Return__c==null){
                        rel.Order.Total_Return__c=0;
                    }
                    if(rel.Order.Updated_Order_Total__c!=null){
                    relWrap.OrderTotal= string.valueof(Math.abs(rel.Order.Updated_Order_Total__c - rel.Order.Total_Return__c));
                    }
                    relWrap.AccountId =rel.Order.Account.Name;
                String withoutTime= String.valueof(Date.valueof(rel.Order.OrderedDate));
                String finaltime = withoutTime.split('-')[1]+'/'+ withoutTime.split('-')[2] + '/'+ withoutTime.split('-')[0];
                relWrap.ActivatedDate = finaltime;// relWrap.productName= rel.Product2.Name;
                relWrap.GrandTotalAmount = rel.Order.GrandTotalAmount;
                relWrap.ShippingNumber=rel.Order.ShippingNumber__c;
               
                
                relwrap.Status=rel.Order.Status;
                relWrap.ShippingVendor= rel.Order.Shipping_Vendors__c;
                relWrap.CustomerOrderStatus= rel.Order.CustomerOrderStatus__c;
                if(rel.Order.Shipping_Vendors__c=='Other' || rel.Order.Shipping_Vendors__c=='other'){
                    relWrap.Othercarrierpresent= true;
                   }
                   else{
                   relWrap.Othercarrierpresent= false;
                   }
                // relwrap.ShippingAddress=rel.Order.ShippingAddress;
                
                 WrapperList.add(relwrap);
                
                // ImageMap.put(rel.Relatedproduct__r.Id,getproductInfo.defaultImage.url);
            }
        }        
        return WrapperList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Order> loggedInUserOrderHistory(String recordId){
        List<Order> Order = [SELECT  Id,ShippingCity,ShippingCountry, ShippingPostalCode,Delivery_Types__c,	
        ShippingState,ShippingStreet,Customer_Name__c, Cart__r.DealerId__r.Service_Scheduling_URL__c, 
        OrderedDate, Updated_Order_Total__c,Other_Carrier__c,EffectiveDate,
        ShowShippingInfo__c, Shipping_Vendors__c, ShippingNumber__c,CustomerOrderStatus__c, Account.Name, Type, ActivatedDate, 
        OrderNumber,Status,  ShippingAddress, GrandTotalAmount,OrderReferenceNumber  FROM Order  
        WHERE OwnerId =: recordId AND Status != 'Draft' AND OrderedDate = LAST_N_DAYS:180 ORDER BY OrderedDate DESC];
        return Order;
    }

   @AuraEnabled
    public static OrderRelatedWrapper getMyOrderDetail(String recordOrderId) {
       
            String activDate;
            string accName;
            Decimal grandTotalAmount;
            List<String> prodNameLst = new List<String>();
            List<OrderItem> orderitems = [SELECT Id,AvailableQuantity, Type, OrderId,Order.ActivatedDate,Order.Account.Name, Product2.Name,Product2.StockKeepingUnit,
                                          Order.OrderNumber, Order.Status, Order.ShippingAddress, Order.GrandTotalAmount 
                                          FROM OrderItem WHERE Order.OrderNumber =: recordOrderId AND Type='Order Product'];
        
        for(OrderItem ordobj : orderitems){
            activDate = string.valueof(ordobj.Order.ActivatedDate);
            accName = ordobj.Order.Account.Name;
            grandTotalAmount =  ordobj.Order.GrandTotalAmount;
            prodNameLst.add(ordobj.Product2.Name);
        }
        OrderRelatedWrapper relwrap= new OrderRelatedWrapper();
        relWrap.ActivatedDate= activDate;
        relWrap.AccountId = accName;
        relWrap.GrandTotalAmount= grandTotalAmount;
        relWrap.productNamesLst= prodNameLst;
        return relwrap;
    }

    @AuraEnabled(cacheable=true)
    public static ProductRelatedWrapper getMyProductDetail(String recordProductId) {
        String height;
        string width;
        String packageQty;
        String weight;
        String length;
        Boolean shippingAdd;
        Decimal coreChargeUnitPrice;  // Added by ashwin for bug 19483
         String colorOption;
        Decimal productPrice;
        if(!B2B_Util.isSalesforceID(recordProductId)){
                Product2 product = [SELECT Id,Name FROM Product2 WHERE StockKeepingUnit  = :recordProductId LIMIT 1];
                recordProductId = product.Id;
        }
        List<Product2> proditems = [SELECT Id /*Part_SKU__c*/, Height_in__c /*Shipping_Details__c*/, Manufactured_Location__c,Core_Charge_Unit_Price__c, // Core_Charge_Unit_Price__c Added by ashwin for bug 19483
                                    Name, Description, StockKeepingUnit , Price__c,PickupatDealer__c,
                                    Width_in__c, Weight_lbs__c, Length_in__c,/* Block_reference__c*/ Color__c, QuantityUnitOfMeasure, 
                                    Product_availability__c /*Required_Product__c,package__c ,Retired_Part_No__c,Color_Options__c,RT_Long_description__c*/ FROM Product2 where Id =: recordProductId];
        
        for(Product2 prdobj : proditems){
            height = String.valueOf(prdobj.Height_in__c);
            width =  String.valueOf(prdobj.Width_in__c);
            //packageQty =  prdobj.package__c;
            weight =  String.valueOf(prdobj.Weight_lbs__c);
            length =  String.valueOf(prdobj.Length_in__c);
            shippingAdd = prdobj.PickupatDealer__c;
            coreChargeUnitPrice = prdobj.Core_Charge_Unit_Price__c != 0 && prdobj.Core_Charge_Unit_Price__c != null ? prdobj.Core_Charge_Unit_Price__c : 0; // Added by ashwin for bug 19483
            
            
            productPrice = prdobj.Price__c;
            //colorOption = prdobj.Color_Options__c;
        }
        ProductRelatedWrapper relwrap= new ProductRelatedWrapper();
        relWrap.Height_in= height;
        relWrap.Width_in = width;
        relWrap.packageQtny= packageQty;
        relWrap.Weight_lbs = weight;
        relWrap.Length_in = length;
        relWrap.Shipping_Details = shippingAdd;
        relWrap.core_charge_unit_price = coreChargeUnitPrice;
        relWrap.Price = String.valueOf(productPrice);
         relWrap.Color_Options = colorOption;
        return relwrap;
    }
    public class OrderRelatedWrapper
    {
        @AuraEnabled
        public string OrderNumber{get;set;}
        @AuraEnabled
        public Date OrderActDate{get;set;}
        @AuraEnabled
        public string OrderTotal{get;set;}
        @AuraEnabled
        public string ActivatedDate{get;set;}
        @AuraEnabled
        public string AccountId{get;set;}
        @AuraEnabled
        public string OrderedDate{get;set;}
        @AuraEnabled
        public string Status{get;set;}
        @AuraEnabled
        public String ShippingAddress{get;set;}
        @AuraEnabled
        public String OtherCarrier{get;set;}
        @AuraEnabled
        public Decimal GrandTotalAmount{get;set;}
        @AuraEnabled
        public Boolean showshippingNumber{get;set;}
        @AuraEnabled
        public List<String> productNamesLst{get;set;}
        @AuraEnabled
        public String productName{get;set;}
        @AuraEnabled
        public String CustomerOrderStatus{get;set;}
        @AuraEnabled
        public Boolean isStatusDraft{get;set;}
        @AuraEnabled
        public String ShippingNumber{get;set;}
        @AuraEnabled
        public String ShippingVendor{get;set;}
        @AuraEnabled
        public Boolean Othercarrierpresent{get;set;}
        @AuraEnabled
        public String OrderReferenceNumber {get;set;}
    }
    public class ProductRelatedWrapper{
        @AuraEnabled
        public string Part_SKU {get;set;}
        @AuraEnabled
        public string  Height_in {get;set;}
        @AuraEnabled
        public Boolean  Shipping_Details {get;set;}
        @AuraEnabled
        public string  Manufactured_Location {get;set;}
        @AuraEnabled
        public string   Name {get;set;}
        @AuraEnabled
        public Double core_charge_unit_price {get;set;}
        
        @AuraEnabled
        public string  Description {get;set;}
        @AuraEnabled
        public string StockKeepingUnit  {get;set;} 
        @AuraEnabled
        public string  Price {get;set;}
        @AuraEnabled
        public string Width_in {get;set;}
        
        @AuraEnabled
        public string  Weight_lbs {get;set;}
        @AuraEnabled
        public string  Length_in {get;set;}
        @AuraEnabled
        public string  Block_reference {get;set;}
        @AuraEnabled
        public string  Color {get;set;}
        @AuraEnabled
        public string  QuantityUnitOfMeasure {get;set;}
        @AuraEnabled
        public string  Product_availability {get;set;}
        
        @AuraEnabled
        public string  Required_Product {get;set;}
        @AuraEnabled
        public string  packageQtny {get;set;} 
        @AuraEnabled
        public string Retired_Part_No {get;set;}
        @AuraEnabled
        public string Color_Options {get;set;}
        @AuraEnabled
        public string RT_Long_description  {get;set;}
    }
}
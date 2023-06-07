/*********************************************************************************************************************
Name: 			DisplayCartItemsCtrl
Date: 			07/09/2021
Description: 	Controller for email template
Test Class: 	DisplayCartItemsCtrlTest
***********************************************************************************************************************/
public without sharing class DisplayCartItemsCtrl {
    public String cartId {get;set;}
    public String orderId {get;set;}
    public String disclaimerUrl {get;set;}
    public String pdf {get;set;}
    public Boolean isReturn {get;set;}
    public Boolean isReturnEmpty {get;set;}
    public Boolean isDealerInstall {get;set;}
    public Integer compRend {get;set;} //Added by ashwin for SP3-16542
    
    public DisplayCartItemsCtrl(){

        
        //cartItemList = new List<CartItem>();
        System.debug('cartId is'+ cartId);
        Site site = [SELECT Id, Status, SiteType, Name, Subdomain, UrlPathPrefix, MasterLabel, Description FROM Site WHERE Status = 'Active' AND MasterLabel LIKE '%dreamshop%' AND UrlPathPrefix = '' LIMIT 1];
        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
        disclaimerUrl = communityUrl+'s/product-disclaimer';
        //pdf = 'pdf';
    }
    public void handleMobileView(){
        pdf = '';
    }
    public void handleDesktopView(){
        pdf = 'pdf';
    }
    
    public List<CartItem> getCartItemList() {
        if(String.isNotBlank(cartId)){
            return [SELECT Id, Name, Sku, Quantity, ListPrice,Dealer_Installation_Price__c,Cart.Delivery_Type__c,TotalPrice,Product_Model_Marketing_Name__c FROM CartItem WHERE CartId  =: cartId ORDER By Sku];
        }
        return null;
    }
    
    public List<OrderItem> getOrderItemList() {
        if(String.isNotBlank(orderId)){                                 
            isReturn = false;
            //Added Product_Type__c field in query by ashwin for SP3 - 16542
            //Product type Field in below Query Added by ashwin SP4-16461
            return [SELECT Id, Cart_Item_Product_Name__c,	Product_Model_Marketing_Name__c, Product_SKU__c, Updated_Quantity__c,Return_Quantity__c, Extended_Price__c, Quantity, UnitPrice, Product_Type__c
                    FROM OrderItem WHERE OrderId  =: orderId AND Type != 'Delivery Charge' ORDER BY Product_SKU__c];                        
        }
        return null;
    }
    
    
     /*Started bye ashwin for SP4-16461*/
    
    public Decimal getTotalReturnedCoreCharges(){
        
        Decimal totalReturnCoreCharge = 0;
        
        for(Invoice_Item__c oi : getOrderItemReturnList()){
            if(oi.Product_Type__c == 'Core Charge'){
                totalReturnCoreCharge += oi.Unit_Price__c * oi.Item_Quantity__c;
            }
        }
        
        return totalReturnCoreCharge;
    }

    //Start Added by Aditya for 19428 19430 Fix
    public Boolean getNonZeroCoreChrageItemExist(){
        Boolean isExist = false ;
        
        for(Invoice_Item__c oi : getOrderItemReturnList()){
            if(oi.Product_Type__c == 'Core Charge'){
                isExist = true;
            }
        }    
        
        return isExist;
    }
   //End Added by Aditya for 19428 19430 Fix
   
    
    public boolean getIsContainCore(){
 
        Set<String> prodType = new Set<String>();
        
        for(Invoice_Item__c inv : getOrderItemReturnList()){
            prodType.add(inv.Product_Type__c);
        }
        
        return prodType.size() ==1 && prodType.contains('Core Charge') ? true : false;
    }
    
    /*ended bye ashwin for SP4-16461*/
    
    
    public List<Invoice_Item__c> getOrderItemReturnList() {
        isDealerInstall = false;
        if(String.isNotBlank(orderId)){
            Order objOrder = [SELECT Id, Delivery_Types__c, Status FROM Order WHERE Id =: orderId];
            if(objOrder != null && (objOrder.Status == 'PARTIAL RETURN' || objOrder.Status == 'ORDER RETURN' || objOrder.Status == 'Activated')){
                if(objOrder.Delivery_Types__c == 'Install At Dealer'){
                   isDealerInstall = true; 
                }
                Invoice__c objInvoice = [SELECT Id FROM Invoice__c WHERE Order__c =: orderId AND Invoice_Type__c = 'Order Return' ORDER BY CreatedDate DESC LIMIT 1];
                if(objInvoice != null){
                    isReturn = true;
                    
                    List<Invoice_Item__c> lstInvoiceItems = [SELECT Id, Invoice__c, Product_SKU__c, Product_Name__c, Accessory_Op_Code__c, Unit_Price__c, Item_Quantity__c, Total_Product_Tax__c, Item_Installation_Price__c, Total_Installation_Charge__c, Extended_Price__c, Product_Type__c
                                                             FROM Invoice_Item__c 
                                                             WHERE Invoice__c =: objInvoice.Id AND Item_Quantity__c != 0 ORDER BY Product_SKU__c];
                    if(lstInvoiceItems.isEmpty())
                        isReturnEmpty = true;
                    
                    return lstInvoiceItems;
                }
            }            			
        }
        return null;
    }
    
    
    // Order__r.Delivery_Type__c,Total_Core_Charge_Amount__c added by ashwin
    public List<Invoice__c> getOrderReturnList() {
        if(String.isNotBlank(orderId)){
            Return [SELECT Id, Total_Product_Price__c, Order__r.Total_Core_Charge_Current_Amount__c,Order__r.Delivery_Types__c,Order__r.Delivery_Type__c, Total_Installation_Charge__c, Total_Restocking_Fee__c, Total_Shipping_Amount__c, Total_Invoice_Price__c, Total_Invoice_Tax__c,Total_Core_Charge_Amount__c 
                    FROM Invoice__c 
                    WHERE Order__c =: orderId AND Invoice_Type__c = 'Order Return' ORDER BY CreatedDate DESC LIMIT 1];
                	
        }
        return null;
    }
    
    public Boolean getIsMotocompacto() {
        System.debug('cart : '+cartId);
        if(String.isNotBlank(cartId)){
            List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId =: cartId AND Product_Type__c = 'Motocompacto'];
            System.debug('cartItems : '+cartItems);
            if(!cartItems.isEmpty() && cartItems.size() > 0){
                return true;
            }
        }
        return false;
    }
    
    public static String getMotocompactoMarkupMdt(){
        Map<String, Default_Policy_Markup__mdt> dataMap = B2B_DealerReturnPolicyController.getReturnPolicyMarkupMdt();
        String motocompactpData = '';
        if(dataMap.containsKey('B2B_Motocompacto_Disclaimer_Markup')){
            motocompactpData = dataMap.get('B2B_Motocompacto_Disclaimer_Markup').Markup__c;
        }else{
            motocompactpData = 'No preview available!';
        }
        return motocompactpData;
    }
}
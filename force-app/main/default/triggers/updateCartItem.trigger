// this trigger updates the cart item as a workaround for sping'22 release where user is not able to 
// update cartitem while adding cart Item to a cart.

trigger updateCartItem on Update_CartItem__e (after insert) {
    
    List<CartItem> cartItemList = new List<CartItem>();
    
    for (Update_CartItem__e event : Trigger.New) {
        if(event.Cart_Item_Id__c != null){
            CartItem ci = new CartItem(Id = event.Cart_Item_Id__c);
            ci.ListPrice = event.List_Price__c;
            ci.SalesPrice = event.Sales_Price__c;
            ci.UnitAdjustmentAmount  = event.Unit_Adjustment_Amount__c;
            ci.UnitAdjustedPrice = event.Unit_Adjusted_Price__c;
            ci.AdjustmentAmount = event.Adjustment_Amount__c;
            ci.Color__c = event.Color__c;
            ci.Name = event.Name__c;
            ci.AdjustmentTaxAmount = event.Adjustment_Tax_Amount__c;
            ci.TotalListPrice = event.Total_List_Price__c;
            ci.TotalLineAmount = event.Total_Line_Amount__c;
            ci.TotalPrice = event.Total_Price__c;
            ci.TotalPriceAfterAllAdjustments = event.Total_Price_After_All_Adjustments__c;
            ci.TotalPromoAdjustmentAmount = event.Total_Promo_Adjustment_Amount__c;
            ci.TotalAdjustmentAmount = event.Unit_Adjustment_Amount__c;
            ci.Accessorie_Image_URL__c= event.Accessorie_Image_URL__c;//added by Yashika for 7380
            ci.op_code__c= event.op_code__c;//added by Yashika for 7911
            ci.product_type__c = event.Product_Type__c; // Added by Bhawesh for bug number 7434
            ci.Product_Subdivision__c= event.Brand_Name__c; // Added by shalini for bug HDMP-8290
            ci.Product_Model__c = event.Product_Model__c; //added by Yashika for 8708
            ci.Product_Identifier__c = event.Product_Identifier__c; //added by Yashika for 8708
            cartItemList.add(ci);
        }
   }
   update cartItemList;
}
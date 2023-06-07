/* =======================================================================================
Purpose : This class is written as the handler for updateCartItem Trigger.
-------------------------------------------------------------------------------------------

History
-------
VERSION        AUTHOR                  DATE                DETAIL
1.0            Pradeep Singh           19-04-2022          Intial Version

============================================================================================*/

public class UpdateCartItemHelper {    
    Public static void updateCartItemRecord(List<Update_CartItem__e> ucList){
        List<CartItem> cartItemList = new List<CartItem>();
        
        for (Update_CartItem__e event : ucList) {
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
                cartItemList.add(ci);
            }
        }
        update cartItemList;
    }
}
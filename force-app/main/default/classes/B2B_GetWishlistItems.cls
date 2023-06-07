/******************************************************************************* 
Name:  B2B_LoggedInUserWishlist
Business Unit: HDM
Date: Jan, 2022
Description: This class is for wishlist usage.

******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
          25-08-2022 | Yashika | Added header | 
          22-02-2023 | Aditya Saini | getWishlistItem | HDMP-16502
          4-28 -2023 | Lakshmi Iyer | getWishlistItem | HDMP-19438 -
          Code optimization and changes to remove multiple select and upsert inside for loop
*******************************************************************************/ 
public with sharing class B2B_GetWishlistItems {
    @AuraEnabled
    public static List<WishlistItem> getWishlistItem(String recordId){
        List<User> loggedInUser = new List<User>();
        loggedInUser = [SELECT Id,Name,ContactId,Contact.Account.Name FROM User WHERE Id=:userinfo.getUserId()];
        Id contactId = loggedInUser[0].contactId;
        ///*WHERE Wishlist.OwnerId =: recordId ORDER BY Product2.StockKeepingUnit*/ 
        try{

        Map<String,PricebookEntry> skuMap = new Map<String,PricebookEntry>();
        List<PricebookEntry> priceBookList = new List<PricebookEntry>();
        List<String> skuList = new List<String>();
        List<WishlistItem> wlItems= new List<WishListItem>();
        Map<String,Product2> productMap = new Map<String,Product2>();

        List<WishlistItem> wishlistItem = [SELECT  Id,Section_Id__c,Illustration_Group_Image_Id__c,Illustration_Id__c, Item_Package_Quantity__c,color__c,Op_Code__c,
        productImage__c,Name,Quantity__c,Price__c,
        Core_Charge_Unit_Price__c, Product2.Name,Product2.Id,Product_Type__c,Product2.Core_Charge_Unit_Price__c,Product2.StockKeepingUnit,Product_Model_Marketing_Name__c,Product_Identifier__c,Product_Model__c,Product_Subdivision__c,Product_Division__c, Product2.Product_availability__c,Product2.IsActive
        FROM WishlistItem WHERE Wishlist.Account.PersonContactId =:contactId ORDER BY Product2.StockKeepingUnit  ]; // Aditya - HDMP-16502 (Added core charges field in SOQL)Vivek HDMP 18856 (Added product2.IsActivein SOQL)
            for(WishlistItem wlItem:wishlistItem){
                skuList.add(wlItem.Product2.StockKeepingUnit);
                productMap.put(wlItem.product2.id,wlItem.product2);
            }
		// In below query Label.Dreamshop_Pricebook_Name Query  Added by lakshmi for 19501
        priceBookList = [SELECT Product2.StockKeepingUnit,Id,UnitPrice FROM PricebookEntry WHERE Product2.StockKeepingUnit IN :skuList AND pricebook2.Name=:Label.Dreamshop_Pricebook_Name];
        for(PricebookEntry pbItem: priceBookList){
            skuMap.put(pbItem.Product2.StockKeepingUnit, pbItem);
        }
            for(WishlistItem item:wishlistItem){
                item.Price__c=skuMap.get(item.Product2.StockKeepingUnit).UnitPrice;
                item.Core_Charge_Unit_Price__c=productMap.get(item.Product2.Id).Core_Charge_Unit_Price__c;
                item.product2.IsActive=productMap.get(item.Product2.Id).IsActive;
                wlItems.add(item);
            }
            upsert wlItems;
            
            wishlistItem= wlItems;
            return wishlistItem;
        
        }
        catch(Exception Ex){
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', '', '', '',
																'B2B_LoggedInUserWishlist', ex.getMessage(), '', String.ValueOf(ex.getLineNumber()),
																'getWishlistItem', true, '', '', '', (Long) 0.0, '',
																'Request:', 'Response:');
			throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }

        
}
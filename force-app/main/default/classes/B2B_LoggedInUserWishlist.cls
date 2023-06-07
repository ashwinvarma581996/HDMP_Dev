/******************************************************************************* 
Name:  B2B_LoggedInUserWishlist
Business Unit: HDM
Date: Jan, 2022
Description: This class is for wishlist usage.

******************************************************************************* 
MODIFICATIONS – Date | Dev Name | Method | User Story 
          25-08-2022 | Yashika | Added header |
          22-02-2023 | Aditya | Added Core Cost field | HDMP-16502

*******************************************************************************/ 
public without sharing class B2B_LoggedInUserWishlist {
    @AuraEnabled
    public static List<WishlistItem> getWishlistItem(String recordId){
        List<User> loggedInUser = new List<User>();
        loggedInUser = [SELECT Id,Name,ContactId,Contact.Account.Name FROM User WHERE Id=:userinfo.getUserId()];
        Id contactId = loggedInUser[0].contactId;
        try{
            // Added Core_Charge_Unit_Price__c for HDMP-19508
            List<WishlistItem> WishlistItem = [SELECT  Core_Charge_Unit_Price__c, Id,Item_Package_Quantity__c,Product2.IsActive, Product_Subdivision__c,Product_Division__c,Op_Code__c, Product2.Product_availability__c,Product_Type__c,Brand__c, color__c,productImage__c,Name,Quantity__c,Price__c, Product2.Name,Product2.Id, Product2.StockKeepingUnit,Product_Model_Marketing_Name__c,Product_Identifier__c,Product_Model__c,Section_Id__c,Illustration_Group_Image_Id__c,Illustration_Id__c,Product_Model__r.Model_Name__c,Product_Model__r.Model_Year__c,Product_Model__r.Trim__c,Product_Model__r.Product_Subdivision__c,Product_Model__r.Product_Model_ID__c FROM WishlistItem  WHERE Wishlist.Account.PersonContactId =:contactId ORDER BY Product2.StockKeepingUnit ];//for adobe:added fields
            for(WishlistItem w:WishlistItem){
                // In query below Label.Dreamshop_Pricebook_Name Query  Added by ashwin for 19501
            Decimal ProductPrice = [SELECT Id, UnitPrice FROM PricebookEntry where Product2.StockKeepingUnit=: w.Product2.StockKeepingUnit AND Pricebook2.Name =: Label.Dreamshop_Pricebook_Name LIMIT 1 ].UnitPrice ; 
            Decimal Corecharge = [SELECT Id, Core_Charge_Unit_Price__c FROM Product2 where id=: w.Product2.Id ].Core_Charge_Unit_Price__c ; // Aditya Added for wishlist core charge Fix
            w.Core_Charge_Unit_Price__c=Corecharge; // Aditya Added for wishlist core charge Fix
            w.Price__c=ProductPrice;

             if(w.Core_Charge_Unit_Price__c > 0){
             
                       w.Name = w.Product2.Name + ' ' + Label.B2B_Reman_Part_Identification_Label;
                }

            // update w; Saravanan LTIM Commented Wipro's code as it violation
            }

            Database.update(WishlistItem); // Saravanan LTIM added 
        return WishlistItem;
        }catch(Exception Ex){
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', '', '', '',
																'B2B_LoggedInUserWishlist', ex.getMessage(), '', String.ValueOf(ex.getLineNumber()),
																'getWishlistItem', true, '', '', '', (Long) 0.0, '',
																'Request:', 'Response:');
			throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }

    // Added By AShwin for 16543 to create error
    @AuraEnabled
    public static String createWishlistError(String errMsg, String response, String recordId){

        Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', '', '', '',
        'B2B_LoggedInUserWishlist', errMsg, '', '',
        'createWishlistError', true, '', recordId, '', (Long) 0.0, '',
        'Request:', response);

        return 'Create Record';

    }
    @AuraEnabled
    public static WishlistItem addItemToList(string brand, String accountId, String communityId, String sku, String userId, Decimal price, Integer quantity, String accessoryName, String productImage, String productType, String color, String op_code, String productModelName, String vin, String modelId, String itemPackageQuantity, String sectionId, String IllustrationId, String IllustrationImageId){ //Aditya HDMP-16502
        List<User> loggedInUser = new List<User>();
		 String remanText = Label.B2B_Reman_Part_Identification_Label; // Added By Ashwin as fix of 18588
            loggedInUser = [SELECT Id,Name,ContactId,Contact.Account.Name FROM User WHERE Id=:userinfo.getUserId()];
            Id contactId = loggedInUser[0].contactId;
            Account objAccountId = [Select Id,PersonContactId from Account where PersonContactId=:contactId LIMIT 1];
           try{
            string id=null; 
           try{
                if(brand=='Honda'){
                 id=[SELECT Id FROM Wishlist where OwnerId=:userId and Name=:'My Honda Wishlist' LIMIT 1].Id;
                }
                else{
                    id=[SELECT Id FROM Wishlist where OwnerId=:userId and Name=:'My Acura Wishlist' LIMIT 1].Id;
                }
            }Catch(Exception ex){
                if(ex.getMessage() == 'List has no rows for assignment to SObject'){
                    id = null;
                }
                else{
                    id='abc';
                }
            }

        //Core_Charge_Unit_Price__c field Added by ashwin as fix for bug HDMP-17765
        Product2 product = [SELECT Id,Name,Core_Charge_Unit_Price__c FROM Product2 WHERE StockKeepingUnit = :sku LIMIT 1];

        Decimal coreCharge = product.Core_Charge_Unit_Price__c; // Added by ashwin as fix for bug HDMP-17765

        if(id==null){
            String storeId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            String ws =[SELECT Id, Name from WebStore where Id=:storeId LIMIT 1].Name;
            Wishlist wishNew= new Wishlist();
            wishNew.OwnerId=userId;
            if(brand=='Honda'){
            wishNew.Name='My Honda Wishlist';
            }
            else{
                wishNew.Name='My Acura Wishlist';
            }
            wishNew.WebstoreId=storeId;
            wishNew.AccountId=objAccountId.Id;
            wishNew.AK_Wishlist__c='My Wishlist'+ws;
            insert wishNew;

        }
        Wishlist wish= new Wishlist();
        if(brand=='Honda'){
         wish=[SELECT Id, Name, OwnerId, WebStoreId, AccountId FROM Wishlist where Account.PersonContactId =:contactId AND Name=:'My Honda Wishlist'  LIMIT 1];
        }
        else{
         wish=[SELECT Id, Name, OwnerId, WebStoreId, AccountId FROM Wishlist where Account.PersonContactId =:contactId AND Name=:'My Acura Wishlist'  LIMIT 1]; 
        }
        WishlistItem wi = new WishlistItem();
        wi.Product_Subdivision__c=brand;
        if(brand=='Honda'){
            wi.Product_Division__c='A';
        }
        else{
            wi.Product_Division__c='B';
        }
        //Aditya HDMP-16502 // Added to fic Wishlist Reman text PDP - Aditya
        if(coreCharge > 0){
            wi.Core_Charge_Unit_Price__c=coreCharge;
			if(accessoryName.contains(remanText)){
                wi.Name=accessoryName;
            }else{
                wi.Name= accessoryName+' '+ remanText;
            }
        }else{
            wi.Name=accessoryName;
        }// Added to fic Wishlist Reman text PDP - Aditya
        wi.Product2Id=product.Id;
        wi.WishlistId= wish.Id;
        wi.Price__c =price;
        wi.Quantity__c=quantity;
        wi.productImage__c=productImage;
        wi.Product_Type__c =productType;
        wi.color__c =color;
        wi.Op_Code__c =op_code;
        wi.Product_Model_Marketing_Name__c =productModelName;
        wi.Product_Identifier__c = vin;
        if(vin=='undefined'){ //for 12421
            wi.Product_Identifier__c='';
        }
        wi.Product_Model__c =modelId;
        // Saravanan LTIM for 17761
        wi.AK_Wishlist_Item__c= (coreCharge > 0) ? String.ValueOf(product.Id)+'~'+String.ValueOf(wish.Id)+'~'+'Part' : String.ValueOf(product.Id)+String.ValueOf(wish.Id);
        wi.sku__c=sku;
        wi.Item_Package_Quantity__c= Decimal.valueOf(itemPackageQuantity);
        wi.Section_Id__c =sectionId;
        wi.Illustration_Id__c = IllustrationId;
        wi.Illustration_Group_Image_Id__c = IllustrationImageId;
        insert wi;
        return wi;
        
    }catch (Exception ex) {
        Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', accountId, '', '',
																'B2B_LoggedInUserWishlist', ex.getMessage(), '', String.ValueOf(ex.getLineNumber()),
																'addItemToList', true, '', '', '', (Long) 0.0, '',
																'Request:', 'Response:');
			throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
    }
    }

    @AuraEnabled
    public static List<WishlistItem>  removeItemFromList(String removeItemId, String userId){
        List<User> loggedInUser = new List<User>();
        loggedInUser = [SELECT Id,Name,ContactId,Contact.Account.Name FROM User WHERE Id=:userinfo.getUserId()];
        Id contactId = loggedInUser[0].contactId;   
            List<WishlistItem> WishlistItem =[SELECT Id, Name,Core_Charge_Unit_Price__c FROM WishlistItem WHERE Id =:removeItemId and Wishlist.Account.PersonContactId =:contactId ];//Aditya HDMP-16502 (Added field in SOQL)
        try{            
            DELETE WishlistItem;
            List<WishlistItem> updatedRecords = getWishlistItem(userId);
            return updatedRecords;         
        }catch(Exception Ex){
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', '', '', '',
            'B2B_LoggedInUserWishlist', ex.getMessage(), '', String.ValueOf(ex.getLineNumber()),
            'removeItemFromList', true, '', '', '', (Long) 0.0, '',
            'Request:', 'Response:');
        throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());

        }
    }
    @AuraEnabled
    public static List<WishlistItem>  updateWishlistItem(String wishItemId, Integer quantity, String userId){
        List<User> loggedInUser = new List<User>();
        loggedInUser = [SELECT Id,Name,ContactId,Contact.Account.Name FROM User WHERE Id=:userinfo.getUserId()];
        Id contactId = loggedInUser[0].contactId;
        List<WishlistItem> WishlistItem =[SELECT Id,Quantity__c, Name, Core_Charge_Unit_Price__c FROM WishlistItem WHERE Id =:wishItemId and Wishlist.Account.PersonContactId =:contactId ];//Aditya HDMP-16502 (Added field in SOQL)
        try{
            WishlistItem wi = new WishlistItem();
            wi.Id=wishItemId;
            wi.Quantity__c=quantity;
           update wi;
            List<WishlistItem> updatedRecords = getWishlistItem(userId);
            return updatedRecords;
            
        }catch(Exception ex){
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', '', '', '',
            'B2B_LoggedInUserWishlist', ex.getMessage(), '', String.ValueOf(ex.getLineNumber()),
            'updateWishlistItem', true, '', '', '', (Long) 0.0, '',
            'Request:', 'Response:');

            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }
    @AuraEnabled(cacheable=true) 
    public static B2B_Custom_Settings__c getCustomSettings(){
        return B2B_Custom_Settings__c.getOrgDefaults();
    }
    @AuraEnabled(cacheable=true)
    public static List<CartItem> getItemImage(String cartItemId){
        List<CartItem> CartItem = [SELECT  Section_Id__c, Illustration_Group_Image_Id__c,Illustration_Id__c,Accessorie_Image_URL__c,op_code__c,Product_Subdivision__c,Product_Type__c,Product_Identifier__c,Product_Model__c,Product_Model_Marketing_Name__c,Item_Package_Quantity__c,Product2.Core_Charge_Unit_Price__c FROM CartItem  WHERE Id =: cartItemId ]; //Aditya HDMP-16502
        return CartItem;
    }
    @AuraEnabled(cacheable=true)
    public static Decimal getProductPrice(String sku){
        Decimal ProductPrice = [SELECT Id, UnitPrice FROM PricebookEntry where Product2.StockKeepingUnit=: sku LIMIT 1 ].UnitPrice ;
        return ProductPrice;
    }

    @AuraEnabled//(cacheable=true)
    public static List<CartItem> getCartItems(String cartId, String sku) 
    {
            List<CartItem> cartList = new List<CartItem>([SELECT Id, Sku FROM CartItem WHERE Sku=:sku AND CartId=:cartId AND Cart.OwnerId =: UserInfo.getUserId()]);
            return cartList;
    }
    @AuraEnabled(cacheable=true)
    public static List<WishlistItem> getWishlistItemFromSKU(String userId, String sku){
        List<User> loggedInUser = new List<User>();
        loggedInUser = [SELECT Id,Name,ContactId,Contact.Account.Name FROM User WHERE Id=:userinfo.getUserId()];
        Id contactId = loggedInUser[0].contactId;
        List<WishlistItem> WishlistItem = [SELECT  Id FROM WishlistItem  WHERE Wishlist.Account.PersonContactId =:contactId AND Product2.StockKeepingUnit=:sku ];
        return WishlistItem;
    }
//added for adobe
    @AuraEnabled(cacheable=true)
    public static Product_Model__c getModelDetails(String modelId){
        try {
            Product_Model__c pm = [Select Id,Product_Model_ID__c,Model_Year__c,Model_Name__c,Trim__c from Product_Model__c where Id=:modelId];
            return pm;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    } 

    
}
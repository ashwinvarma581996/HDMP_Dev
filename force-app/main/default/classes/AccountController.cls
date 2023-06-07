public without sharing class AccountController 
{
    @AuraEnabled(cacheable=true)
    public static Account fetchAllAccounts(){
        return [SELECT id, Name, State__c FROM Account WHERE Name like 'Yashika' limit 1]; 
    }

    @AuraEnabled
    public static Account updateAccountData(string recordId,string state){
        try {
            Account acc = [select id,State__c from Account where Id =:recordId];
            acc.State__c = state;
            update acc; 
            return acc;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string fetchStoreId(String communityId){
        try{ 
           B2B_Custom_Settings__c b2b = [select id,name, Default_Guest_Account__c from B2B_Custom_Settings__c limit 1];
        String  effectiveAccountId = b2b.Default_Guest_Account__c;
        string personAccountId=B2B_Fetch_PersonAccount.getPersonAccount(UserInfo.getUserId());
        		if(String.isNotBlank(personAccountId))
            effectiveAccountId =personAccountId;
         String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
       //ConnectApi.CartSummary currentCart = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(webstoreId, b2b.Default_Guest_Account__c, 'active');
        ConnectApi.CartSummary CurrentCart = B2BGetInfo.getCartSummary(communityId, effectiveAccountId) ;
        string res=B2B_ShippingHelperV2.startCartProcessMegaSync('0a6010000000B7hAAE','01760','cart');
        return webstoreId;
        
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getProduct(){
        try {
            // if(B2B_Util.isSalesforceID(productId) == false){
            //     Product2 product = [SELECT Id,Name FROM Product2 WHERE StockKeepingUnit  = :productId LIMIT 1];
            //     productId = product.Id;
            // }
            Product2 product1 = [SELECT Id,Name FROM Product2 LIMIT 1];
                return product1.Name;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage());
        }
    }
     
}
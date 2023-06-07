/**
 * Created by mbarton on 12/14/22.
 */

public with sharing class B2BProductUtils {
    @TestVisible
    private static B2BCommerceProxy commerceProxy = new B2BCommerceProxy();

    /**
    * @description       : To fetch category path to show in breadcrumbs on PLP
    **/

    public static Map<String,Object> getCategoryPath(Map<String, Object> dataMap){
        ConnectApi.ProductCategoryPath catPath = B2BCommerceProxy.getCategoryPath(dataMap);

        Set<String> idsToQuery = new Set<String>();
        for (ConnectApi.ProductCategoryData cat : catPath.path) {
            idsToQuery.add(cat.id);
        }
        String categoryKey = null;
        try{
            categoryKey = [
                    SELECT Category_Breadcrumb_Key__c
                    FROM ProductCategory
                    WHERE Id IN :idsToQuery
                    AND Category_Breadcrumb_Key__c != null
            ].Category_Breadcrumb_Key__c;
        } catch(Exception ex){
            categoryKey = null;
        }


        if(categoryKey != null){
            if(catPath != null){
                dataMap.put('categories', catPath);
                dataMap.put('isSuccess', true);
                dataMap.put('baseCategory', categoryKey);
            }
        } else {
            if(catPath != null){
                dataMap.put('categories', catPath);
                dataMap.put('isSuccess', true);
            }
        }

        return dataMap;
    }

    /**
   * @description       : To fetch products with category and facet based on categoryId or search string
   **/

    public static Map<String,Object> getProductsWithCategoryAndFacet(Map<String, Object> dataMap){
        if(!dataMap.containsKey('effectiveAccountId')){
            // Running a LIKE b/c Profile names are not consistent throughout orgs
            String accId = [SELECT Id FROM GuestBuyerProfile WHERE Name LIKE 'Dreamshop% Guest Buyer%' LIMIT 1].Id; 
            dataMap.put('effectiveAccountId', accId);
        }
        return B2BCommerceProxy.getProductsWithCategory(dataMap);
    }

}
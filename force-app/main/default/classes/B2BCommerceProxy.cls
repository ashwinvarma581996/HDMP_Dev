/**
 * Created by mbarton on 12/14/22.
 */

public with sharing class B2BCommerceProxy {

    public static ConnectApi.ProductCategoryPath getCategoryPath(Map<String, Object> dataMap){
        if(dataMap.containsKey('communityId') && dataMap.get('communityId') != null && dataMap.containsKey('categoryId') && dataMap.get('categoryId') != null){
            System.debug('Results from getCategoryPath dataMap: ' + dataMap);
            String communityId = String.valueOf(dataMap.get('communityId'));
            String storeId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            String categoryId = String.valueOf(dataMap.get('categoryId'));
            return ConnectApi.CommerceCatalog.getProductCategoryPath(storeId, categoryId);
        }
        return null;
    }

    public static Map<String,Object> getProductsWithCategory(Map<String, Object> dataMap){

        Boolean isSuccess;
        String errorMsg = '';
        if(!dataMap.containsKey('effectiveAccountId') || dataMap.get('effectiveAccountId') == null){
            isSuccess = false;
            errorMsg = 'Error 1 ';
            dataMap.put('isSuccess', isSuccess);
            dataMap.put('msg', errorMsg);
            return dataMap;
        }

        String currencyStr = 'USD';
        String accId = String.valueOf(dataMap.get('effectiveAccountId'));

        String categoryId, searchTerm;
        if (dataMap.containsKey('categoryId') && dataMap.get('categoryId') != null) {
            categoryId = String.valueOf(dataMap.get('categoryId'));
        }

        List<Product2> prodLst;
      
        String prodStr = 'SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE IsActive = TRUE';

        if(String.isNotBlank(categoryId)){
            prodStr += ' AND ID IN (SELECT ProductID FROM ProductCategoryProduct WHERE ProductCategoryId = :categoryId)';
        }

        prodLst = Database.query(prodStr);
        isSuccess = true;
        errorMsg = 'Error 2';
        dataMap.put('isSuccess', isSuccess);
        dataMap.put('msg', errorMsg);
        dataMap.put('prodLst', prodLst);
        dataMap.put('currencyCode', currencyStr);
        return dataMap;
    }

}
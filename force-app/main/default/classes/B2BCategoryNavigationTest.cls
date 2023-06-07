/**
 * Created by mbarton on 12/29/22.
 */

@isTest(SeeAllData=true)
public with sharing class B2BCategoryNavigationTest {

    @isTest
    private static void getCategoryLandingPassTest() {
        String networkId = [SELECT Id FROM Network WHERE Name = 'DreamShop'].Id;
        String categoryId = [SELECT Id FROM ProductCategory LIMIT 1].Id;

        String webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :networkId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;

        List<WebStoreCatalog> storeCatalogList = [SELECT Id, ProductCatalogId, SalesStoreId, Name FROM WebStoreCatalog WHERE SalesStoreId = :webStoreId];

        String catalogId = storeCatalogList[0].ProductCatalogId;

        ProductCategory parentCategory = new ProductCategory();
        parentCategory.Name = 'parentCategory';
        parentCategory.CatalogId = catalogId;
        insert parentCategory;

        ProductCategory childCategory = new ProductCategory();
        childCategory.Name = 'childCategory';
        childCategory.CatalogId = catalogId;
        childCategory.ParentCategoryId = parentCategory.Id;
        childCategory.Section_Id__c = '8';
        insert childCategory;

        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('categoryId',categoryId);
        dataMap.put('communityId',networkId);

        Test.startTest();
        List<ProductCategory> results = B2BCategoryNavigation.getCategoryLanding(networkId, parentCategory.Id);
        Test.stopTest();
        System.debug('Results from getCategoryLandingPassTest: ' + results);
        System.assert(results != null);
        System.assert(results.size() >= 1);
    }

    @isTest
    private static void fetchCategoryPathPassTest() {
        String networkId = [SELECT Id FROM Network WHERE Name = 'DreamShop'].Id;

        String webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :networkId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;

        List<WebStoreCatalog> storeCatalogList = [SELECT Id, ProductCatalogId, SalesStoreId, Name FROM WebStoreCatalog WHERE SalesStoreId = :webStoreId];

        String catalogId = storeCatalogList[0].ProductCatalogId;

        ProductCategory parentCategory = new ProductCategory();
        parentCategory.Name = 'parentCategory';
        parentCategory.CatalogId = catalogId;
        parentCategory.Category_Breadcrumb_Key__c = 'TestBrand';
        insert parentCategory;

        ProductCategory childCategory = new ProductCategory();
        childCategory.Name = 'childCategory';
        childCategory.CatalogId = catalogId;
        childCategory.ParentCategoryId = parentCategory.Id;
        childCategory.ParentCategory = parentCategory;
        insert childCategory;

        String categoryId = [SELECT Id FROM ProductCategory  WHERE ParentCategoryId=:parentCategory.Id LIMIT 1].Id;

        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('categoryId',categoryId);
        dataMap.put('communityId',networkId);

        Test.startTest();
        Map<String, Object> results = B2BCategoryNavigation.fetchCategoryPath(dataMap);
        Test.stopTest();
        System.debug('Results from fetchCategoryPathPassTest: ' + results);
        System.assert(results != null);
        System.assert(results.get('isSuccess') == true);
    }


    @isTest
    private static void fetchCategoryPathFailTest() {
        String networkId = [SELECT Id FROM Network WHERE Name = 'DreamShop'].Id;
        ProductCatalog objProdCatalog = new ProductCatalog();
        objProdCatalog.Name = 'TestShop';
        insert objProdCatalog;
        ProductCategory objProdCategory = new ProductCategory();
        objProdCategory.Name = 'Test Product Category';
        objProdCategory.CatalogId = objProdCatalog.Id;
        insert objProdCategory;

        String categoryId = [SELECT Id FROM ProductCategory WHERE Id=:objProdCategory.Id LIMIT 1].Id;

        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('categoryId',categoryId);
        dataMap.put('communityId',networkId);

        Test.startTest();
        Map<String, Object> results = B2BCategoryNavigation.fetchCategoryPath(dataMap);
        Test.stopTest();
        System.debug('Results from fetchCategoryPathFailTest: ' + results);
        System.assert(results != null);
        System.assert(results.get('isSuccess') == false);
    }

    @isTest
    private static void getProductsWithCategoryPassTest() {
        String networkId = [SELECT Id FROM Network WHERE Name = 'DreamShop'].Id;
        String categoryId = [SELECT Id FROM ProductCategory LIMIT 1].Id;

        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('categoryId',categoryId);
        dataMap.put('communityId',networkId);

        Test.startTest();
        Map<String, Object> results = B2BCategoryNavigation.getProductsWithCategory(dataMap);
        Test.stopTest();
        System.debug('Results from getProductsWithCategoryPassTest: ' + results);
        System.assert(results != null);
    }

    @isTest
    private static void getProductsWithCategoryFailTest() {
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('effectiveAccountId',null);

        Test.startTest();
        Map<String, Object> results = B2BCategoryNavigation.getProductsWithCategory(dataMap);
        Test.stopTest();
        System.debug('Results from getProductsWithCategoryFailTest: ' + results);
        System.assert(results != null);
    }

    @isTest
    private static void getCategoryTreePassTest() {

        String networkId = [SELECT Id FROM Network WHERE Name = 'DreamShop'].Id;

        String webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :networkId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;

        List<WebStoreCatalog> storeCatalogList = [SELECT Id, ProductCatalogId, SalesStoreId, Name FROM WebStoreCatalog WHERE SalesStoreId = :webStoreId];

        String catalogId = storeCatalogList[0].ProductCatalogId;

        ProductCategory parentCategory = new ProductCategory();
        parentCategory.Name = 'parentCategory';
        parentCategory.CatalogId = catalogId;
        parentCategory.Category_Breadcrumb_Key__c = 'TestBrand';
        parentCategory.IsNavigational = true;
        insert parentCategory;

        ProductCategory childCategory1 = new ProductCategory();
        childCategory1.Name = 'childCategory1';
        childCategory1.CatalogId = catalogId;
        childCategory1.ParentCategoryId = parentCategory.Id;
        childCategory1.ParentCategory = parentCategory;
        parentCategory.IsNavigational = true;
        insert childCategory1;

        ProductCategory childCategory2 = new ProductCategory();
        childCategory2.Name = 'childCategory1';
        childCategory2.CatalogId = catalogId;
        childCategory2.ParentCategoryId = childCategory1.Id;
        childCategory2.ParentCategory = childCategory1;
        parentCategory.IsNavigational = true;
        insert childCategory2;

        ProductCategory childCategory3 = new ProductCategory();
        childCategory3.Name = 'childCategory1';
        childCategory3.CatalogId = catalogId;
        childCategory3.ParentCategoryId = childCategory2.Id;
        childCategory3.ParentCategory = childCategory2;
        parentCategory.IsNavigational = true;
        insert childCategory3;

        Test.startTest();
        List<B2BCategoryNavigation.CategoryWrapper> results = B2BCategoryNavigation.getCategoryTree(networkId);
        Test.stopTest();
        System.debug('Results from getCategoryTreePassTest: ' + results);
        System.assert(results != null);
    }

    @isTest
    private static void getTopLevelCategoriesPassTest() {
        String networkId = [SELECT Id FROM Network WHERE Name = 'DreamShop'].Id;

        String webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :networkId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;

        List<WebStoreCatalog> storeCatalogList = [SELECT Id, ProductCatalogId, SalesStoreId, Name FROM WebStoreCatalog WHERE SalesStoreId = :webStoreId];

        String catalogId = storeCatalogList[0].ProductCatalogId;

        ProductCategory parentCategory = new ProductCategory();
        parentCategory.Name = 'parentCategory';
        parentCategory.CatalogId = catalogId;
        parentCategory.Category_Breadcrumb_Key__c = 'TestBrand';
        parentCategory.IsNavigational = true;
        parentCategory.Category_Title__c = 'TestTitle';
        insert parentCategory;

        Test.startTest();
        List<B2BCategoryNavigation.TopCategoryWrapper> results = B2BCategoryNavigation.getTopLevelCategories(networkId);
        Test.stopTest();
        System.debug('Results from getTopLevelCategoriesPassTest: ' + results);
        System.assert(results != null);
    }

    @isTest
    private static void getTopLevelCategoriesPassAltTest() {
        String networkId = [SELECT Id FROM Network WHERE Name = 'DreamShop'].Id;

        String webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :networkId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;

        List<WebStoreCatalog> storeCatalogList = [SELECT Id, ProductCatalogId, SalesStoreId, Name FROM WebStoreCatalog WHERE SalesStoreId = :webStoreId];

        String catalogId = storeCatalogList[0].ProductCatalogId;

        ProductCategory parentCategory = new ProductCategory();
        parentCategory.Name = 'parentCategory';
        parentCategory.CatalogId = catalogId;
        parentCategory.Category_Breadcrumb_Key__c = 'TestBrand';
        parentCategory.IsNavigational = true;
        parentCategory.Category_Title__c = 'TestTitle';
        parentCategory.Category_Image__c = 'TestImgURL';
        parentCategory.Category_Image_Alt_Text__c = 'TestImageAltText';
        parentCategory.Category_Image_Title__c = 'TestImageTitle';
        insert parentCategory;

        Test.startTest();
        List<B2BCategoryNavigation.TopCategoryWrapper> results = B2BCategoryNavigation.getTopLevelCategories(networkId);
        Test.stopTest();
        System.debug('Results from getTopLevelCategoriesPassTest: ' + results);
        System.assert(results != null);
    }

    @isTest
    private static void getDeepLinkValidTest() {
        ProductCatalog objProdCatalog = new ProductCatalog();
        objProdCatalog.Name = 'TestShop';
        insert objProdCatalog;

        ProductCategory parentCategory = new ProductCategory();
        parentCategory.Section_Id__c = '8';
        parentCategory.Name = 'parentCategory';
        parentCategory.CatalogId = objProdCatalog.Id;
        insert parentCategory;

        Test.startTest();
        Map<String,String> results = B2BCategoryNavigation.getDeepLink(parentCategory.Id);
        Test.stopTest();
        System.debug('Results from getDeepLinkValidTest: ' + results);
        System.assert(results != null);
    }

    @isTest
    private static void getDeepLinkNullTest() {
        ProductCatalog objProdCatalog = new ProductCatalog();
        objProdCatalog.Name = 'TestShop';
        insert objProdCatalog;

        ProductCategory parentCategory = new ProductCategory();
        parentCategory.Section_Id__c = '8';
        parentCategory.Name = 'parentCategory';
        parentCategory.CatalogId = objProdCatalog.Id;
        insert parentCategory;

        ProductCategory childCategory = new ProductCategory();
        childCategory.ParentCategoryId = parentCategory.Id;
        childCategory.Name = 'childCategory';
        childCategory.CatalogId = objProdCatalog.Id;
        insert childCategory;

        Test.startTest();
        Map<String,String> results = B2BCategoryNavigation.getDeepLink(childCategory.Id);
        Test.stopTest();
        System.debug('Results from getDeepLinkNullTest: ' + results);
        System.assert(results != null);
    }
}
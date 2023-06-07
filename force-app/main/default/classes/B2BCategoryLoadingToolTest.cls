/**
 * Created by mbarton on 2/5/23.
 */
@isTest(SeeAllData=true)
public with sharing class B2BCategoryLoadingToolTest {

    @isTest
    private static void validCSVTest() {
        String networkId = [SELECT Id FROM Network WHERE Name = 'DreamShop'].Id;

        String webStoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :networkId LIMIT 1].WebStoreId;

        List<WebStoreCatalog> storeCatalogList = [SELECT Id, ProductCatalogId, SalesStoreId, Name FROM WebStoreCatalog WHERE SalesStoreId = :webStoreId];

        String catalogId = storeCatalogList[0].ProductCatalogId;

        ProductCategory parentCategory = new ProductCategory();
        parentCategory.Name = 'Honda Parts Test';
        parentCategory.CatalogId = catalogId;
        insert parentCategory;

        ProductCategory childCategory1 = new ProductCategory();
        childCategory1.Name = 'Accord Coupe Test';
        childCategory1.CatalogId = catalogId;
        childCategory1.ParentCategoryId = parentCategory.Id;
        childCategory1.ParentCategory = parentCategory;
        insert childCategory1;

        ProductCategory childCategory2 = new ProductCategory();
        childCategory2.Name = 'ENGINE Test';
        childCategory2.CatalogId = catalogId;
        childCategory2.ParentCategoryId = childCategory1.Id;
        childCategory2.ParentCategory = childCategory1;
        insert childCategory2;

        ProductCategory childCategory3 = new ProductCategory();
        childCategory3.Name = 'THROTTLE BODY (1.5L) Test';
        childCategory3.CatalogId = catalogId;
        childCategory3.ParentCategoryId = childCategory2.Id;
        childCategory3.ParentCategory = childCategory2;
        insert childCategory3;


        String testCSVbody = 'Level 1 (Make),Level 2 (Model),Level 3 (Section),Level 4 (Group)' + '\n' +
            'Honda Parts Test,Accord Coupe Test,ENGINE Test,THROTTLE BODY (1.5L) Test' + '\n' +
            'Honda Parts,Accord Coupe,ENGINE,PURGE CONTROL SOLENOID VALVE (1.5L)' + '\n' +
            'Honda Parts,Civic Hatchback,ENGINE,INTAKE MANIFOLD (1.5L)' + '\n' +
            'Honda Parts,Accord Coupe,ENGINE,FUEL INJECTOR (1.5L)' + '\n' +
            'Honda Parts,Accord Coupe,ENGINE,CONVERTER (1.5L)' + '\n' +
            'Honda Parts,Accord Coupe,ENGINE,POTATO (1.5Lx)' + '\n' +
            'Honda Parts,Accord Coupe,CARROT,POTATO (1.5L)' + '\n' +
            'Honda Parts,Squash,CARROT,POTATO (1.5L)' + '\n' +
            'Turnip,Squash,CARROT,POTATO (1.5L)';

        ContentVersion contentVersion_1 = new ContentVersion(
                Title = 'testCSV',
                PathOnClient = 'testCSV.csv',
                VersionData = Blob.valueOf(testCSVbody),
                IsMajorVersion = true
        );
        insert contentVersion_1;

        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =:contentVersion_2.Id];

        List<String> listString = new List<String>();
        String catalogName = [SELECT Name FROM ProductCatalog WHERE Name LIKE 'DreamShop%' LIMIT 1].Name;
        listString.add(catalogName);
        listString.add(documents[0].Id);
        List<List<String>> listListString = new List<List<String>>();
        listListString.add(listString);

        Test.startTest();
        List<String> results = B2BCategoryLoadingTool.initiateCategoryLoading(listListString);
        Test.stopTest();
        System.assert(results != null);
        System.assert(results[0].contains('Number of rows in CSV : 9') == true);
    }

    @isTest
    private static void zeroRows() {
        String testCSVbody =  'Honda Parts Test,Accord Coupe Test,ENGINE Test,THROTTLE BODY (1.5L) Test';

        ContentVersion contentVersion_1 = new ContentVersion(
                Title = 'testCSV',
                PathOnClient = 'testCSV.csv',
                VersionData = Blob.valueOf(testCSVbody),
                IsMajorVersion = true
        );
        insert contentVersion_1;

        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =:contentVersion_2.Id];

        List<String> listString = new List<String>();
        String catalogName = [SELECT Name FROM ProductCatalog WHERE Name LIKE 'DreamShop%' LIMIT 1].Name;
        listString.add(catalogName);
        listString.add(documents[0].Id);
        List<List<String>> listListString = new List<List<String>>();
        listListString.add(listString);

        Test.startTest();
        List<String> results = B2BCategoryLoadingTool.initiateCategoryLoading(listListString);
        Test.stopTest();
        System.assert(results != null);
        System.assert(results[0].contains('The uploaded CSV file was empty, or missing a header row.') == true);
    }
}
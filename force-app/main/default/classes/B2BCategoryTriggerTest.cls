@isTest(SeeAllData=true)
public class B2BCategoryTriggerTest {
    @isTest
    private static void insertCategoryTest(){
        //Insert the parent record
        String catalogId = [SELECT Id FROM ProductCatalog WHERE Name LIKE 'DreamShop%' LIMIT 1].Id;
        ProductCategory parentCat = new ProductCategory(CatalogId = catalogId,
            										    Name = 'Test Parent Category Name');
        insert parentCat;
        
        //Insert the child record
        ProductCategory childCat = new ProductCategory(ParentCategoryId = parentCat.Id, 
                                                       CatalogId = catalogId,
                                                       Name = 'Test Child Category Name');
        insert childCat;
        
        //Insert the duplicate child record
        childCat = new ProductCategory(ParentCategoryId = parentCat.Id,
                                       CatalogId = catalogId,
                                       Name = 'Test Child Category Name');
        
        Test.startTest();
        Database.SaveResult result = Database.insert(childCat, false);
        Test.stopTest();
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        String errorMsg; 
        if(result.getErrors().size() > 0){
            System.debug('Error message: '+result.getErrors()[0].getMessage());
            //Sample full message:
            //duplicate value found: AK_Category__c duplicates value on record with id: 0ZG750000008PZe
            errorMsg = result.getErrors()[0].getMessage().substring(0,21);
        }
        System.assertEquals('duplicate value found',errorMsg);
    }
    @isTest
    private static void updateCategoryTest(){
        //Insert the parent record
        String catalogId = [SELECT Id FROM ProductCatalog WHERE Name LIKE 'DreamShop%' LIMIT 1].Id;
        ProductCategory parentCat = new ProductCategory(CatalogId = catalogId,
            										    Name = 'Test Parent Category Name');
        insert parentCat;
        
        //Insert the child record
        ProductCategory childCat = new ProductCategory(ParentCategoryId = parentCat.Id, 
                                                       CatalogId = catalogId,
                                                       Name = 'Test Child Category Name');
        insert childCat;
        
        //Update the child record
        childCat = new ProductCategory(Id = childCat.Id,
                                       ParentCategoryId = parentCat.Id,
                                       CatalogId = catalogId,
                                       Name = 'Test Child Category Name');
        
        Test.startTest();
        Database.SaveResult result = Database.update(childCat, false);
        Test.stopTest();
        System.assert(result.isSuccess());
    }

    @isTest
    private static void insertCategoryNoParentTest(){
        String catalogId = [SELECT Id FROM ProductCatalog WHERE Name LIKE 'DreamShop%' LIMIT 1].Id;

        //Insert the child record
        ProductCategory childCat = new ProductCategory(CatalogId = catalogId,
                Name = 'Test Child Category Name');
        insert childCat;

        //Insert the duplicate child record
        childCat = new ProductCategory(CatalogId = catalogId,
                Name = 'Test Child Category Name');

        Test.startTest();
        Database.SaveResult result = Database.insert(childCat, false);
        Test.stopTest();
        System.assert(!result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        String errorMsg;
        if(result.getErrors().size() > 0){
            System.debug('Error message: '+result.getErrors()[0].getMessage());
            //Sample full message:
            //duplicate value found: AK_Category__c duplicates value on record with id: 0ZG750000008PZe
            errorMsg = result.getErrors()[0].getMessage().substring(0,21);
        }
        System.assertEquals('duplicate value found',errorMsg);
    }
}
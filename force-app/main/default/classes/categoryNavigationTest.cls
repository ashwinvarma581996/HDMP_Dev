@isTest
public class categoryNavigationTest {
 @isTest 
    public static void testGetChildCategories(){
        ProductCatalog objProdCatalog = new ProductCatalog();
        objProdCatalog.Name = 'Test Product Catalog';
        insert objProdCatalog;
        ProductCategory objProdCategory = new ProductCategory();
        objProdCategory.Name = 'Test Product Category';
        objProdCategory.CatalogId = objProdCatalog.Id;
        insert objProdCategory;
        
        ProductCategory objProdCategory2 = new ProductCategory();
        objProdCategory2.Name = 'Test Product Category';
        objProdCategory2.CatalogId = objProdCatalog.Id;
        objProdCategory2.parentCategoryId = objProdCategory.Id;
        insert objProdCategory2;
      
       
        categoryNavigation.getChildCategories(objProdCategory.Id);
    }
}
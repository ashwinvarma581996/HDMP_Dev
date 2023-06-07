public class B2BCategoryTriggerHandler {
    public static void beforeUpdate(List<ProductCategory> newCat){
        updateAlternateKey(newCat);        
    }
    public static void beforeInsert(List<ProductCategory> newCat){
        updateAlternateKey(newCat);
    }
    private static void updateAlternateKey(List<ProductCategory> newCat){
        for(ProductCategory cat : newCat){
            String parentCategoryId = String.isBlank(cat.ParentCategoryId)?cat.CatalogId:cat.ParentCategoryId;
            String name = String.isBlank(String.valueOf(cat.Name))?'':String.valueOf(cat.Name);
            cat.AK_Category__c = parentCategoryId + '~' + name;
        }
    }
}
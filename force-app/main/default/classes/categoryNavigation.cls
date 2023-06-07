public without sharing class categoryNavigation {
    
     @AuraEnabled(cacheable=true)
    public static List<ProductCategory> getChildCategories(Id catId) {
        System.debug('catId::'+catId);
        List<ProductCategory> categories =  [SELECT Id, Name FROM ProductCategory where parentCategoryId =: catId];
        System.debug('categories::'+categories);
        return categories;
    }

}
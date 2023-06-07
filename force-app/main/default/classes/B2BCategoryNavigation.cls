public with sharing class B2BCategoryNavigation {

    B2BProductUtils utils;

    // Used in GetCategoryTree
    public static final Set<String> EXCLUDED_CATEGORIES = new Set<String> { 'Honda', 'Acura'};


    public B2BCategoryNavigation(B2BProductUtils utils){
        this.utils = utils;
    }
    
    @AuraEnabled (cacheable=true)
    public static List<ProductCategory> getCategoryLanding(String communityId, String productCategoryId){

        String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        List<WebStoreCatalog> storeCatalogList = [SELECT Id, ProductCatalogId, SalesStoreId 
                                                  FROM WebStoreCatalog
                                                  WHERE SalesStoreId = :webStoreId];
        
        Set<Id> catalogIds = new Set<Id>();
        for(WebStoreCatalog WSC : storeCatalogList){
            catalogIds.add(WSC.ProductCatalogId);
        }

        List<ProductCategory> productCategoryList = [
                                                    SELECT Id, Name, Section_Id__c, Category_Image__c, Category_Image_Default__c,Category_Image_Alt_Text__c, Category_Image_Title__c, SortOrder	
                                                    FROM ProductCategory 
                                                    WHERE CatalogId IN : catalogIds AND ParentCategoryId =: productCategoryId 
                                                    AND IsNavigational = True 
                                                    ORDER BY SortOrder ASC
                                                    ];
        
        return productCategoryList;
    }

    // Retrieves sectionId and megaCategory Name for deeplinking on section level & megaCategory level category pages
    @AuraEnabled (cacheable=true)
    public static Map<String,String> getDeepLink(String productCategoryId) {

        Map<String, String> sessionVarMap = new Map<String, String>();
        String megaCatName;

        // Check to see if category record has sectionId
        String sectionId = [SELECT Section_Id__c FROM ProductCategory WHERE ID =: productCategoryId].Section_Id__c;

        if(String.isBlank(sectionId)) {
            // Check to see if on megaCategory page and look for parent's sectionId
            ProductCategory[] parentCategory = [SELECT ParentCategoryId FROM ProductCategory WHERE ID =: productCategoryId AND ParentCategoryId <> null];
            if (parentCategory.size() > 0) {
                sectionId = [SELECT Section_Id__c FROM ProductCategory WHERE ID =: parentCategory[0].parentCategoryId].Section_Id__c;
                megaCatName = [SELECT Name FROM ProductCategory WHERE ID =: productCategoryId].Name;
            }
        }

        if(sectionId != null){
            sessionVarMap.put('sectionId', sectionId);
            sessionVarMap.put('megaCatName', megaCatName);
        } 

        return sessionVarMap;
    
    }

    @AuraEnabled
    public static Map<String,Object> fetchCategoryPath(Map<String, Object> dataMap){
        try{
            return B2BProductUtils.getCategoryPath(dataMap);
        }catch (Exception ex) {
            dataMap = dataMap==null ? new Map<String,Object>() : dataMap ;
            dataMap.put('isSuccess',false);
            dataMap.put('msg',ex.getMessage());
        }
        return dataMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getProductsWithCategory(Map<String, Object> dataMap){
        try {
            return B2BProductUtils.getProductsWithCategoryAndFacet(dataMap);
        } catch (Exception ex) {
            dataMap = dataMap == null ? new Map<String,Object>() : dataMap ;
            dataMap.put('isSuccess',false);
            dataMap.put('msg',ex.getMessage());
        }
        return dataMap;
    }

    @AuraEnabled (cacheable=true)
    public static List<CategoryWrapper> getCategoryTree(String communityId){
        String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        List<WebStoreCatalog> storeCatalogList = [SELECT Id, ProductCatalogId, SalesStoreId 
                                                  FROM WebStoreCatalog
                                                  WHERE SalesStoreId = :webStoreId];
        
        Set<Id> catalogIds = new Set<Id>();
        for(WebStoreCatalog WSC : storeCatalogList){
            catalogIds.add(WSC.ProductCatalogId);
        }

        List<ProductCategory> productCategoryList = [SELECT Id, Name, ParentCategoryId
                                                     FROM ProductCategory 
                                                     WHERE CatalogId IN : catalogIds
                                                     AND Name NOT IN :EXCLUDED_CATEGORIES
                                                     AND IsNavigational = True Order by SortOrder ASC];
        
        Map<Id, List<ProductCategory>> productCategoryMap = new Map<Id, List<ProductCategory>>();
        List<ProductCategory> parentCategories = new List<ProductCategory>();
        for(ProductCategory category : productCategoryList){
            if(!productCategoryMap.containsKey(category.ParentCategoryId)){
                productCategoryMap.put(category.ParentCategoryId, new List<ProductCategory>());
            }
            productCategoryMap.get(category.ParentCategoryId).add(category);
            if(category.ParentCategoryId == null){
                parentCategories.add(category);
            }
        }
        List<CategoryWrapper> categoryWrapperList = new List<CategoryWrapper>();
        CategoryWrapper wrap1, wrap2, wrap3, wrap4;
        
        for(ProductCategory cat1 : parentCategories){
            wrap1 = new CategoryWrapper(cat1);
            if(productCategoryMap.containsKey(cat1.Id)){
                for(ProductCategory cat2 : productCategoryMap.get(cat1.Id)){
                    wrap2 = new CategoryWrapper(cat2);
                    wrap1.childs.add(wrap2);
                    if(productCategoryMap.containsKey(cat2.Id)){
                        for(ProductCategory cat3 : productCategoryMap.get(cat2.Id)){
                            wrap3 = new CategoryWrapper(cat3);
                            wrap2.childs.add(wrap3);
                            if(productCategoryMap.containsKey(cat3.Id)){
                                for(ProductCategory cat4 : productCategoryMap.get(cat3.Id)){
                                    wrap4 = new CategoryWrapper(cat4);
                                    wrap3.childs.add(wrap4);
                                }
                            }
                        }
                    }
                }
            }
            categoryWrapperList.add(wrap1);
        }
        return categoryWrapperList;
    }
        
    public class CategoryWrapper{
        @AuraEnabled public String categoryName;
        @AuraEnabled public String categoryUrl;
        @AuraEnabled public List<CategoryWrapper> childs;
        
        public CategoryWrapper(ProductCategory category){
            this.categoryName = category.Name;
            this.categoryUrl = '/s/category/' + category.Id;
            this.childs = new List<CategoryWrapper>();
        }
    }

    @AuraEnabled (cacheable=true)
    public static List<TopCategoryWrapper> getTopLevelCategories(String communityId){
        String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        List<WebStoreCatalog> storeCatalogList = [SELECT
            Id,
            ProductCatalogId,
            SalesStoreId
            FROM WebStoreCatalog
            WHERE SalesStoreId = :webStoreId];

        String catalogId = storeCatalogList[0].ProductCatalogId;

        List<ProductCategory> productCategoryList = [SELECT
            Id,
            Name,
            Category_Title__c,
            ParentCategoryId,
            Category_Breadcrumb_Key__c,
            Category_Image_Default__c,
            Category_Image__c,
            Category_Image_Alt_Text__c,
            Category_Image_Title__c
            FROM ProductCategory
            WHERE CatalogId = :catalogId
            AND Category_Breadcrumb_Key__c != null
            AND IsNavigational = true
            AND ParentCategoryId = null
            AND Category_Title__c != null
            ORDER BY SortOrder ASC];

        List<TopCategoryWrapper> topCategoryWrapperList = new List<TopCategoryWrapper>();
        TopCategoryWrapper topCategory;

        for(ProductCategory topCat : productCategoryList){
            topCategory = new TopCategoryWrapper(topCat);
            topCategoryWrapperList.add(topCategory);
        }
        return topCategoryWrapperList;
    }

    public class TopCategoryWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String img;
        @AuraEnabled public String url;
        @AuraEnabled public String imgAltText;
        @AuraEnabled public String imgTitle;

        public TopCategoryWrapper(ProductCategory category){
            this.name = category.Name;
            this.label = category.Category_Title__c;
            this.url = '/s/category/' + category.Id;

            if(category.Category_Image__c != null){
                this.img = category.Category_Image__c;
            } else {
                this.img = category.Category_Image_Default__c;
            }

            this.imgAltText = '';
            if(category.Category_Image_Alt_Text__c != null){
                this.imgAltText = category.Category_Image_Alt_Text__c;
            }

            this.imgTitle = '';
            if(category.Category_Image_Title__c != null){
                this.imgTitle = category.Category_Image_Title__c;
            }
        }
    }
}
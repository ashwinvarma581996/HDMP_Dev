//****************************************************************************** 
// File Name:       OwnHelpCenterController.cls
// Summary:         Apex Class for Community Context
// Created On:      04-28-2021
// Created By:      Arunprasad N (Wipro)
// Test Classes:    OwnHelpCenterControllerTest.cls
// Data I/O:        
// Honda Jira Story: Apex class for Help Center for Honda Owner Experience
//===============================================================================
// Modification Log: 
// May 17, 2021 Arunprasad N (Wipro) initial coding
// July 26, 2021 Arunprasad N (Wipro) get articles and faqs
//*******************************************************************************
public without sharing class OwnHelpCenterController {
    private static final String KNOWLEDGE_CATEGORY_OBJECT = 'KnowledgeArticleVersion';
    private static final String KNOWLEDGE_CATEGORY_GROUP = 'ProductLine';
    private static List<Category> dataCategories = new List<Category>();
    private static final String LANGUAGE = 'en_US';
    private static final String PUBLISH_STATUS = 'Online';

    public OwnHelpCenterController() {}

    @AuraEnabled
    public static List<Result> getKnowledgeArticles(String category, Integer maxResults)
    {
        List<Knowledge__kav> kaList;
        maxResults = String.isEmpty(maxResults.format()) ? 10000 : maxResults;
        try {

            if (String.isEmpty(category))
            {
                ////////////////////////////////////////////////////////////////////////
                // get ka id list of all articles that have data category assignments //
                ////////////////////////////////////////////////////////////////////////
                Set<Id> dscIdList = new Set<Id>();
                List<Knowledge__DataCategorySelection>  dcsList = [SELECT ParentId from Knowledge__DataCategorySelection];
                for (Knowledge__DataCategorySelection dsc : dcsList)
                {
                    dscIdList.add(dsc.ParentId);
                }
                //////////////////////////////////////////////////////////////////////////////////////////////
                // retrive articles not in the list above...i.e. articles without data category assignments //
                //////////////////////////////////////////////////////////////////////////////////////////////
                // kaList = [SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT ParentId, DataCategoryName FROM DataCategorySelections) 
                //             FROM Knowledge__kav
                //             WHERE
                //                 IsDeleted = false 
                //                 AND PublishStatus = :PUBLISH_STATUS 
                //                 AND Language = :LANGUAGE 
                //                 AND Id IN :dscIdList
                //             WITH SECURITY_ENFORCED
                //         ];

                String queryString = 'SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT ParentId, DataCategoryName FROM DataCategorySelections) ';
                queryString += 'FROM Knowledge__kav ';
                queryString += 'WHERE ';
                queryString += 'IsDeleted = false ';
                queryString += 'AND PublishStatus = :PUBLISH_STATUS ';
                queryString += 'AND Language = :LANGUAGE ';
                queryString += 'AND Id IN :dscIdList ';
                //queryString += 'WITH SECURITY_ENFORCED ';
                queryString += 'LIMIT '+ maxResults;
                String safeQueryString = String.escapeSingleQuotes(queryString);
                kaList = Database.query(safeQueryString);
            }
            else {
                ////////////////////////////////////////////////////////////////////////
                // get ka id list of all articles within a defined group and category //
                //   - SOQL cannot use DataCategoryGroupName or DataCategoryname in   //
                //     WHERE clause                                                   //
                ////////////////////////////////////////////////////////////////////////
                Set<Id> dscIdList = new Set<Id>();
                List<Knowledge__DataCategorySelection>  dcsList = [SELECT ParentId, DataCategoryGroupName, DataCategoryName
                               FROM Knowledge__DataCategorySelection];
                for (Knowledge__DataCategorySelection dsc : dcsList)
                {
                    if (dsc.DataCategoryGroupName == KNOWLEDGE_CATEGORY_GROUP && dsc.DataCategoryName == category)
                    {
                        dscIdList.add(dsc.ParentId);
                    }
                }
                System.debug('@@@' + JSON.serialize(dscIdList));
                ///////////////////////////////////////////////////////////////////////////////////////
                // retrive articles in the list above...i.e. articles within that group and category //
                ///////////////////////////////////////////////////////////////////////////////////////
                // kaList = [SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT ParentId, DataCategoryName FROM DataCategorySelections) 
                //             FROM Knowledge__kav
                //             WHERE
                //                 IsDeleted = false 
                //                 AND PublishStatus = :PUBLISH_STATUS 
                //                 AND Language = :LANGUAGE 
                //                 AND Id IN :dscIdList
                //             WITH SECURITY_ENFORCED
                //         ];
                String queryString = 'SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT ParentId, DataCategoryName FROM DataCategorySelections) ';
                queryString += 'FROM Knowledge__kav ';
                queryString += 'WHERE ';
                queryString += 'IsDeleted = false ';
                queryString += 'AND PublishStatus = :PUBLISH_STATUS ';
                queryString += 'AND Language = :LANGUAGE ';
                queryString += 'AND Id IN :dscIdList ';
                //queryString += 'WITH SECURITY_ENFORCED ';
                queryString += 'LIMIT '+ maxResults;
                String safeQueryString = String.escapeSingleQuotes(queryString);
                kaList = Database.query(safeQueryString);

            }
            List<Result> results = new List<Result>();
            for (Knowledge__kav ka : kaList){
                Result resultsObj = new Result();
                resultsObj.id = ka.Id;
                resultsObj.urlName = ka.UrlName;
                resultsObj.title = ka.Title;
                resultsObj.content = ka.Article_Content__c;
                resultsObj.lastPublishedDate = ka.LastPublishedDate.format('MMMMM dd, yyyy');
                List<Category> categories = new List<Category>();
                for(Knowledge__DataCategorySelection dataCategorySelection : ka.DataCategorySelections){
                    Category c = new Category();
                    c.name = dataCategorySelection.DataCategoryName;
                    categories.add(c);
                }
                resultsObj.categories = categories;
                resultsObj.type = 'article';
                resultsObj.objectLabel = 'Knowledge';
                results.add(resultsObj);
            }
            return results;
        } catch (Exception e) {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }

    @AuraEnabled
    public static List<Result> getPopularKnowledgeArticles(String category, Integer maxResults)
    {
        List<Knowledge__kav> kaList;

        try {

            if (String.isEmpty(category))
            {
                ////////////////////////////////////////////////////////////////////////
                // get ka id list of all articles that have data category assignments //
                ////////////////////////////////////////////////////////////////////////
                Set<Id> dscIdList = new Set<Id>();
                List<Knowledge__DataCategorySelection>  dcsList = [SELECT ParentId from Knowledge__DataCategorySelection];
                for (Knowledge__DataCategorySelection dsc : dcsList)
                {
                    dscIdList.add(dsc.ParentId);
                }
                //////////////////////////////////////////////////////////////////////////////////////////////
                // retrive articles not in the list above...i.e. articles without data category assignments //
                //////////////////////////////////////////////////////////////////////////////////////////////
                String queryString = 'SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT ParentId, DataCategoryName FROM DataCategorySelections) ';
                queryString += 'FROM Knowledge__kav ';
                queryString += 'WHERE ';
                queryString += 'IsDeleted = false ';
                queryString += 'AND PublishStatus = :PUBLISH_STATUS ';
                queryString += 'AND Language = :LANGUAGE ';
                queryString += 'AND Id IN :dscIdList ';
                //queryString += 'WITH SECURITY_ENFORCED ';
                queryString += 'ORDER BY ArticleTotalViewCount DESC ';
                queryString += 'LIMIT '+ maxResults;
                String safeQueryString = String.escapeSingleQuotes(queryString);
                kaList = Database.query(safeQueryString);
            }
            else {
                ////////////////////////////////////////////////////////////////////////
                // get ka id list of all articles within a defined group and category //
                //   - SOQL cannot use DataCategoryGroupName or DataCategoryname in   //
                //     WHERE clause                                                   //
                ////////////////////////////////////////////////////////////////////////
                Set<Id> dscIdList = new Set<Id>();
                List<String> categoryNames = new List<String>();
                List<Category> categories = getDataCategories();
                for(Category topCategory : categories){
                    if(topCategory.name == category){
                        for(Category cat : topCategory.categories){
                            categoryNames.add(cat.name);
                        }
                    }
                }
                List<Knowledge__DataCategorySelection>  dcsList = [SELECT ParentId, DataCategoryGroupName, DataCategoryName
                               FROM Knowledge__DataCategorySelection];
                for (Knowledge__DataCategorySelection dsc : dcsList)
                {
                    if (dsc.DataCategoryGroupName == KNOWLEDGE_CATEGORY_GROUP && categoryNames.contains(dsc.DataCategoryName))
                    {
                        dscIdList.add(dsc.ParentId);
                    }
                }

                ///////////////////////////////////////////////////////////////////////////////////////
                // retrive articles in the list above...i.e. articles within that group and category //
                ///////////////////////////////////////////////////////////////////////////////////////
                String queryString = 'SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT ParentId, DataCategoryName FROM DataCategorySelections) ';
                queryString += 'FROM Knowledge__kav ';
                queryString += 'WHERE ';
                queryString += 'IsDeleted = false ';
                queryString += 'AND PublishStatus = :PUBLISH_STATUS ';
                queryString += 'AND Language = :LANGUAGE ';
                queryString += 'AND Id IN :dscIdList ';
                //queryString += 'WITH SECURITY_ENFORCED ';
                queryString += 'ORDER BY ArticleTotalViewCount DESC ';
                queryString += 'LIMIT '+ maxResults;
                String safeQueryString = String.escapeSingleQuotes(queryString);
                kaList = Database.query(safeQueryString);

            }
            List<Result> results = new List<Result>();
            for (Knowledge__kav ka : kaList){
                Result resultsObj = new Result();
                resultsObj.id = ka.Id;
                resultsObj.urlName = ka.UrlName;
                resultsObj.title = ka.Title;
                resultsObj.content = ka.Article_Content__c;
                resultsObj.lastPublishedDate = ka.LastPublishedDate.format('MMMMM dd, yyyy');
                List<Category> categories = new List<Category>();
                for(Knowledge__DataCategorySelection dataCategorySelection : ka.DataCategorySelections){
                    Category c = new Category();
                    c.name = dataCategorySelection.DataCategoryName;
                    categories.add(c);
                }
                resultsObj.categories = categories;
                resultsObj.type = 'article';
                resultsObj.objectLabel = 'Knowledge';
                results.add(resultsObj);
            }
            return results;
        } catch (Exception e) {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }

    @AuraEnabled
    public static Result getKnowledgeArticle(String articleId, String guestId)
    {
        try {
            Map<ID, Knowledge__DataCategorySelection> dataCategorySelectionMap = new Map<ID, Knowledge__DataCategorySelection>([SELECT Id, ParentId, toLabel(DataCategoryName) FROM Knowledge__DataCategorySelection]);
            String userId = UserInfo.getUserId();
            String queryString = 'SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT Id, ParentId, DataCategoryName FROM DataCategorySelections), ';
            queryString += '(SELECT Vote__c FROM KnowledgeArticleVotes__r WHERE Knowledge__c = :articleId AND ';
            if(UserInfo.getUserType() != 'Guest'){
                queryString += 'User__c = :userId) ';
            }else{
                queryString += 'GUID__c = :guestId) ';
            }
            queryString += 'FROM Knowledge__kav ';
            queryString += 'WHERE ';
            queryString += 'Id = :articleId ';
            //queryString += 'WITH SECURITY_ENFORCED ';
            String safeQueryString = String.escapeSingleQuotes(queryString);
            List<Knowledge__kav> kaList = Database.query(safeQueryString);
            List<Result> results = new List<Result>();
            for (Knowledge__kav ka : kaList){
                Result resultsObj = new Result();
                resultsObj.id = ka.Id;
                resultsObj.urlName = ka.UrlName;
                resultsObj.title = ka.Title;
                resultsObj.content = ka.Article_Content__c;
                resultsObj.lastPublishedDate = ka.LastPublishedDate.format('MMMMM dd, yyyy');
                List<Category> categories = new List<Category>();
                for(Knowledge__DataCategorySelection dataCategorySelection : ka.DataCategorySelections){
                    Category c = new Category();
                    c.label = dataCategorySelectionMap.get(dataCategorySelection.Id).DataCategoryName;
                    c.name = dataCategorySelection.DataCategoryName;
                    categories.add(c);
                }
                for(KnowledgeArticleVote__c knowledgeArticleVote : ka.KnowledgeArticleVotes__r){
                    resultsObj.vote = knowledgeArticleVote.Vote__c;
                }
                resultsObj.categories = categories;
                resultsObj.type = 'article';
                resultsObj.objectLabel = 'Knowledge';
                results.add(resultsObj);
            }
            return !results.isEmpty() ? results[0] : new Result();
        } catch (Exception e) {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }
    
    @AuraEnabled (cacheable=true)
    public static List<Result> search(String searchKey, String category, String sortBy, Integer maxResults)
    {
        try {
            String searchText = searchKey;

            Search.SuggestionOption options = new Search.SuggestionOption();

            Search.KnowledgeSuggestionFilter filters = new Search.KnowledgeSuggestionFilter();

            filters.setLanguage(LANGUAGE);
            filters.setPublishStatus(PUBLISH_STATUS);

            if (String.isNotEmpty(category)) filters.addDataCategory(KNOWLEDGE_CATEGORY_GROUP, category);
            
            options.setFilter(filters);
            options.setLimit(maxResults);

            Search.SuggestionResults suggestionResults = Search.suggest(searchText, KNOWLEDGE_CATEGORY_OBJECT, options);
            List<Search.SuggestionResult> resultList = suggestionResults.getSuggestionResults();

            List<String> kaIdList = new List<String>();
            for (Search.SuggestionResult res : resultList)
            {
                SObject sobj = res.getSOBject();
                kaIdList.add((String)sobj.get('Id'));
            }

            //////////////////////////////////////////////
            // build list of KA details to return to UI //
            //////////////////////////////////////////////
            String queryString = 'SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT ParentId, DataCategoryName FROM DataCategorySelections) ';
            queryString += 'FROM Knowledge__kav ';
            queryString += 'WHERE ';
            queryString += 'IsDeleted = false ';
            queryString += 'AND PublishStatus = :PUBLISH_STATUS ';
            queryString += 'AND Id IN :kaIdList ';
            //queryString += 'WITH SECURITY_ENFORCED ';
            queryString += 'ORDER BY '+ sortBy +' DESC ';
            String safeQueryString = String.escapeSingleQuotes(queryString);
            List<Knowledge__kav> kaList = Database.query(safeQueryString);
            List<Result> results = new List<Result>();
            for (Knowledge__kav ka : kaList){
                Result resultsObj = new Result();
                resultsObj.id = ka.Id;
                resultsObj.urlName = ka.UrlName;
                resultsObj.title = ka.Title;
                resultsObj.content = ka.Article_Content__c;
                resultsObj.lastPublishedDate = ka.LastPublishedDate.format('MMMMM dd, yyyy');
                List<Category> categories = new List<Category>();
                for(Knowledge__DataCategorySelection dataCategorySelection : ka.DataCategorySelections){
                    Category c = new Category();
                    c.name = dataCategorySelection.DataCategoryName;
                    categories.add(c);
                }
                resultsObj.categories = categories;
                resultsObj.type = 'article';
                resultsObj.objectLabel = 'Knowledge';
                results.add(resultsObj);
            }
            return results;
        } catch (Exception e) {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }

    @AuraEnabled
    public static List<Result> getRelatedArticles(String searchKey, String category, Integer maxResults)
    {
        try {
            String searchText = searchKey + '\'';

            // create sosl
            String sosl = null;
            if (String.isEmpty(category)) {
                // search without any category mapping
                sosl = 'FIND {' + String.escapeSingleQuotes(searchText) + '} IN ALL FIELDS RETURNING KnowledgeArticleVersion(ArticleNumber, KnowledgeArticleId, LastPublishedDate, Title WHERE Title != :searchKey) LIMIT ' + maxResults;
            } else {
                // search using found category mapping
                sosl = 'FIND {' + String.escapeSingleQuotes(searchText) + '} IN ALL FIELDS RETURNING KnowledgeArticleVersion(ArticleNumber, KnowledgeArticleId, LastPublishedDate, Title WHERE Title != :searchKey) WITH DATA CATEGORY ' + KNOWLEDGE_CATEGORY_GROUP + '__c' + ' BELOW ' + category + '__c  LIMIT ' + maxResults;
            }

            // do search
            Search.SearchResults searchResults = Search.find(sosl);
            List<Search.SearchResult> resultList = searchResults.get(KNOWLEDGE_CATEGORY_OBJECT);

            List<String> kaIdList = new List<String>();
            for (Search.SearchResult res : resultList)
            {
                SObject sobj = res.getSOBject();
                kaIdList.add((String)sobj.get('Id'));
            }

            //////////////////////////////////////////////
            // build list of KA details to return to UI //
            //////////////////////////////////////////////
            String queryString = 'SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT ParentId, DataCategoryName FROM DataCategorySelections) ';
            queryString += 'FROM Knowledge__kav ';
            queryString += 'WHERE ';
            queryString += 'IsDeleted = false ';
            queryString += 'AND PublishStatus = :PUBLISH_STATUS ';
            queryString += 'AND Id IN :kaIdList ';
            //queryString += 'WITH SECURITY_ENFORCED ';
            String safeQueryString = String.escapeSingleQuotes(queryString);
            List<Knowledge__kav> kaList = Database.query(safeQueryString);
            List<Result> results = new List<Result>();
            for (Knowledge__kav ka : kaList){
                Result resultsObj = new Result();
                resultsObj.id = ka.Id;
                resultsObj.urlName = ka.UrlName;
                resultsObj.title = ka.Title;
                resultsObj.content = ka.Article_Content__c;
                resultsObj.lastPublishedDate = ka.LastPublishedDate.format('MMMMM dd, yyyy');
                List<Category> categories = new List<Category>();
                for(Knowledge__DataCategorySelection dataCategorySelection : ka.DataCategorySelections){
                    Category c = new Category();
                    c.name = dataCategorySelection.DataCategoryName;
                    categories.add(c);
                }
                resultsObj.categories = categories;
                resultsObj.type = 'article';
                resultsObj.objectLabel = 'Knowledge';
                results.add(resultsObj);
            }
            return results;
        } catch (Exception e) {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }

    @AuraEnabled
    public static Result addKnowledgeArticleVote(String articleId, Boolean vote, String guestId,String comment)
    {
        try {
            KnowledgeArticleVote__c knowledgeArticleVote = new KnowledgeArticleVote__c();
            knowledgeArticleVote.Knowledge__c = articleId;
            knowledgeArticleVote.Comment__c = comment;
            if(UserInfo.getUserType() != 'Guest'){
                knowledgeArticleVote.User__c = UserInfo.getUserId();
            } else{
                knowledgeArticleVote.GUID__c = guestId;
            }
            knowledgeArticleVote.Vote__c = vote;
            if (CanTheUser.create(knowledgeArticleVote)) {
                insert knowledgeArticleVote; 
            }
            Result resultsObj = new Result();
            resultsObj.id = articleId;
            resultsObj.vote = vote;
            return resultsObj;
        } catch (Exception e) {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }

    @AuraEnabled
    public static string getGUID(){
        try {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            return guid;
        } catch (Exception e) {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<Category> getDataCategories(){
        try {
            // ask for data categories for knowledge
            final List <String> objType = new List<String>{KNOWLEDGE_CATEGORY_OBJECT};
            final List<Schema.DescribeDataCategoryGroupResult> describeCategoryResult = Schema.describeDataCategoryGroups(objType);

            // loop through data categories for knowledge looking for the correct mapping and
            // create DataCategoryGroupSobjectTypePair object
            final List<Schema.DataCategoryGroupSobjectTypePair> pairs = new List<Schema.DataCategoryGroupSobjectTypePair>();
            for (DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
                if (singleResult.getName().equals(KNOWLEDGE_CATEGORY_GROUP)) {
                    // found the one we are looking for - add pair
                    DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                    p.setSobject(singleResult.getSobject());
                    p.setDataCategoryGroupName(singleResult.getName());
                    pairs.add(p);
                }
            }
            if (pairs.isEmpty()) throw new AuraHandledException('Unable to find requested Schema.DataCategoryGroupSobjectTypePair for <' + KNOWLEDGE_CATEGORY_OBJECT + '> called <' + KNOWLEDGE_CATEGORY_GROUP + '>');

            // get describe for root element and loop although there can only be one...
            final List<Schema.DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);
            for (DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult) {
                // get the top categories and get the first level
                final DataCategory topLevel = singleResult.getTopCategories().get(0);
                for(DataCategory cat : topLevel.getChildCategories()){
                    Category c = new Category();
                    c.name = cat.getName();
                    c.label = cat.getLabel();
                    c.categories = recurseDataCategoryHierarchy(cat.getChildCategories());
                    dataCategories.add(c);
                }
            }
            if(!dataCategories.isEmpty()) return dataCategories;
        } catch (Exception e) {
            throw new AuraHandledException(e.getLineNumber() + ':' + e.getMessage());
        }
        return null;
    }

    private static List<Category> recurseDataCategoryHierarchy(List<DataCategory> cats) {
        List<Category> categories = new List<Category>();
        // loop and attempt to find
        for (DataCategory cat : cats) {
            Category c = new Category();
            c.name = cat.getName();
            c.label = cat.getLabel();
            c.categories = recurseDataCategoryHierarchy(cat.getChildCategories());
            categories.add(c);
        }
        return categories;
    }  
    
    public class Category {
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public List<Category> categories {get; set;}
    }

    public class Result {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String urlName {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String content {get; set;}
        @AuraEnabled
        public String lastPublishedDate {get; set;}
        @AuraEnabled
        public List<Category> categories {get; set;}
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public String objectLabel {get; set;}
        @AuraEnabled
        public Boolean vote {get; set;}
    }

          
    @AuraEnabled(cacheable = true)
    public static String getKavBasedOnUrlName(String UrlNameVar){
        Knowledge__kav kavResult=[SELECT Id, KnowledgeArticleId,URLName,Title FROM Knowledge__kav where URLName =:UrlNameVar Limit 1];
        if(kavResult != null){
          return kavResult.Id;
        }
        return null;
    }


    @AuraEnabled(cacheable = true)
    public static List<Own_Tips_Article_Categories__mdt> getTipsArticleCategories(String brand){
        return getTipsArticleCategories(brand, null);
    }

    @AuraEnabled(cacheable = true)
    public static List<Own_Tips_Article_Categories__mdt> getTipsArticleCategories(String brand, String categoryCd){
        List<Own_Tips_Article_Categories__mdt> categoryList = new List<Own_Tips_Article_Categories__mdt>();

        List<Own_Tips_Article_Categories__mdt> metadataList = Own_Tips_Article_Categories__mdt.getAll().values();

        if (brand.equalsIgnoreCase('Powerequipment')){
            brand = 'Power Equipment';
        }

        // Add all category codes that exist in metadata; if the provided code does not match any of them, return categories based on brand
        Boolean categoryCodeIsKnown = false;
        if (!String.isEmpty(categoryCd)){
            for (Own_Tips_Article_Categories__mdt categoryMetadata : metadataList){
                if (!String.isEmpty(categoryMetadata.Category_Code__c)){
                    Set<String> metadataCategoryCodeSet = new Set<String>(categoryMetadata.Category_Code__c.deleteWhitespace().split(','));
                    if (metadataCategoryCodeSet.contains(categoryCd)){
                        categoryCodeIsKnown = true;
                    }
                }
            }
        }

        for (Own_Tips_Article_Categories__mdt categoryMetadata : metadataList){
            
            Set<String> metadataCategoryCodeSet = new Set<String>();
            if (!String.isEmpty(categoryMetadata.Category_Code__c)){
                metadataCategoryCodeSet = new Set<String>(categoryMetadata.Category_Code__c.deleteWhitespace().split(','));
            }

            if (!categoryCodeIsKnown && categoryMetadata.Brand__c.equalsIgnoreCase(brand)){
                categoryList.add(categoryMetadata);
            }
            else if (categoryCodeIsKnown && categoryMetadata.Brand__c.equalsIgnoreCase(brand) && metadataCategoryCodeSet.contains(categoryCd)){
                categoryList.add(categoryMetadata);
            }
        }

        return categoryList;
    }
/* 
    @AuraEnabled(cacheable = true)
    public static void getTipsArticles(){
        List<Knowledge__kav> articleList = [SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT ParentId, DataCategoryName FROM DataCategorySelections) FROM Knowledge__kav WHERE IsDeleted = false AND PublishStatus = 'Online' AND Language = 'en_US' AND Id IN ('ka04C000000B0QwQAK','ka04C000000B0R1QAK','ka04C000000B0R6QAK','ka04C000000B0RBQA0','ka04C000000B0RGQA0','ka04C000000B0RLQA0','ka04C000000B0RQQA0','ka04C000000B0RVQA0', 'ka00200000019x5AAA')];
        List<Knowledge__kav> testList = [SELECT Id FROM Knowledge__kav WHERE Id = 'ka04C000000B0QwQAK'];
        System.debug(JSON.serialize(articleList));
    } */



    @AuraEnabled
    public static List<Result> getPopularTipsArticles(String brand, Integer maxResults)
    {
        List<Knowledge__kav> kaList;
        Set<String> categorySet = new Set<String>();

        for (Own_Tips_Article_Categories__mdt categoryMetadata : getTipsArticleCategories(brand)){
            categorySet.add(categoryMetadata.DeveloperName);
        }

        System.debug('TIPS CATEGORY SET: ' + JSON.serialize(categorySet));

        try {
            ////////////////////////////////////////////////////////////////////////
            // get ka id list of all articles within a defined group and category //
            //   - SOQL cannot use DataCategoryGroupName or DataCategoryname in   //
            //     WHERE clause                                                   //
            ////////////////////////////////////////////////////////////////////////
            Set<Id> dscIdList = new Set<Id>();
            /* List<String> categoryNames = new List<String>();
           // List<Category> dataCategories = getDataCategories();
            for(Category topCategory : getDataCategories()){
                System.debug('topCategory: ' + topCategory);
                if(categorySet.contains(topCategory.name)){
                    for(Category cat : topCategory.categories){
                        categoryNames.add(cat.name);
                    }
                }
            } */
            //System.debug('CATEGORY NAMES: ' + categoryNames);
            List<Knowledge__DataCategorySelection>  dcsList = [SELECT ParentId, DataCategoryGroupName, DataCategoryName
                            FROM Knowledge__DataCategorySelection];
            for (Knowledge__DataCategorySelection dsc : dcsList)
            {
                if (dsc.DataCategoryGroupName == KNOWLEDGE_CATEGORY_GROUP && categorySet.contains(dsc.DataCategoryName))
                {
                    dscIdList.add(dsc.ParentId);
                }
            }

            ///////////////////////////////////////////////////////////////////////////////////////
            // retrive articles in the list above...i.e. articles within that group and category //
            ///////////////////////////////////////////////////////////////////////////////////////
            String queryString = 'SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT ParentId, DataCategoryName FROM DataCategorySelections) ';
            queryString += 'FROM Knowledge__kav ';
            queryString += 'WHERE ';
            queryString += 'IsDeleted = false ';
            queryString += 'AND PublishStatus = :PUBLISH_STATUS ';
            queryString += 'AND Language = :LANGUAGE ';
            queryString += 'AND Id IN :dscIdList ';
            //queryString += 'WITH SECURITY_ENFORCED ';
            queryString += 'ORDER BY ArticleTotalViewCount DESC ';
            queryString += 'LIMIT '+ maxResults;
            String safeQueryString = String.escapeSingleQuotes(queryString);
            kaList = Database.query(safeQueryString);

            List<Result> results = new List<Result>();
            for (Knowledge__kav ka : kaList){
                Result resultsObj = new Result();
                resultsObj.id = ka.Id;
                resultsObj.urlName = ka.UrlName;
                resultsObj.title = ka.Title;
                resultsObj.content = ka.Article_Content__c;
                resultsObj.lastPublishedDate = ka.LastPublishedDate.format('MMMMM dd, yyyy');
                List<Category> categories = new List<Category>();
                for(Knowledge__DataCategorySelection dataCategorySelection : ka.DataCategorySelections){
                    Category c = new Category();
                    c.name = dataCategorySelection.DataCategoryName;
                    categories.add(c);
                }
                resultsObj.categories = categories;
                resultsObj.type = 'article';
                resultsObj.objectLabel = 'Knowledge';
                results.add(resultsObj);
            }
            System.debug('GET POPULAR TIPS RESULTS: ' + JSON.serialize(results));
            System.debug('GET POPULAR TIPS RESULTS: ' + 'RETRIEVED ' + results.size());
            return results;
        } catch (Exception e) {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<OwnProductSupportVideo__mdt> getProductSupportVideos(String categoryCode){
        try {
            String queryString = 'SELECT Id, DeveloperName, MasterLabel, Label, VideoLink__c, CategoryCode__c ';
            queryString += 'FROM OwnProductSupportVideo__mdt '; 
            if(String.isNotEmpty(categoryCode)){
                queryString += 'WHERE CategoryCode__c = :categoryCode';
            }
            String safeQueryString = String.escapeSingleQuotes(queryString);
            List<OwnProductSupportVideo__mdt> ownProductSupportVideos = Database.query(safeQueryString);
            return ownProductSupportVideos;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getLineNumber() + ':' + ex.getMessage()); 
        }
    }

    @AuraEnabled
    public static Result getKnowledgeArticleByUrlName(String urlName)
    {
        try {
            Map<ID, Knowledge__DataCategorySelection> dataCategorySelectionMap = new Map<ID, Knowledge__DataCategorySelection>([SELECT Id, ParentId, toLabel(DataCategoryName) FROM Knowledge__DataCategorySelection]);
            String userId = UserInfo.getUserId();
            String queryString = 'SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT Id, ParentId, DataCategoryName FROM DataCategorySelections) ';
            queryString += 'FROM Knowledge__kav ';
            queryString += 'WHERE ';
            queryString += 'UrlName = :urlName ';
            //queryString += 'WITH SECURITY_ENFORCED ';
            String safeQueryString = String.escapeSingleQuotes(queryString);
            List<Knowledge__kav> kaList = Database.query(safeQueryString);
            List<Result> results = new List<Result>();
            for (Knowledge__kav ka : kaList){
                Result resultsObj = new Result();
                resultsObj.id = ka.Id;
                resultsObj.urlName = ka.UrlName;
                resultsObj.title = ka.Title;
                resultsObj.content = ka.Article_Content__c;
                resultsObj.lastPublishedDate = ka.LastPublishedDate.format('MMMMM dd, yyyy');
                List<Category> categories = new List<Category>();
                for(Knowledge__DataCategorySelection dataCategorySelection : ka.DataCategorySelections){
                    Category c = new Category();
                    c.label = dataCategorySelectionMap.get(dataCategorySelection.Id).DataCategoryName;
                    c.name = dataCategorySelection.DataCategoryName;
                    categories.add(c);
                }
                resultsObj.categories = categories;
                resultsObj.type = 'article';
                resultsObj.objectLabel = 'Knowledge';
                results.add(resultsObj);
            }
            return !results.isEmpty() ? results[0] : new Result();
        } catch (Exception e) {
            throw new  AuraHandledException(e.getTypeName() + ' - ' + e.getMessage() + ' [Line: ' + e.getLineNumber() + ']');
        }
    }
   
}
public without sharing class OwnVINHelpController {

    private final static String HONDA_DIVISION_NAME = 'Honda';
    private final static String ACURA_DIVISION_NAME = 'Acura';
    private final static String POWERSPORTS_DIVISION_NAME = 'Motorcycle/Powersports';
    private final static String POWEREQUIPMENT_DIVISION_NAME = 'Powerequipment';
    private final static String MARINE_DIVISION_NAME = 'Marine';

    @AuraEnabled (cacheable = true)
    public static Id getArticleId(String divisionName){

        List<Own_Product_Identifier_Help_Page__mdt> articleMetadataList = Own_Product_Identifier_Help_Page__mdt.getAll().values();

        Id articleId;
        String articleMetadataName;
        /* if (divisionName == HONDA_DIVISION_NAME || divisionName == ACURA_DIVISION_NAME){
            for (Own_Product_Identifier_Help_Page__mdt amd: articleMetadata){
                if (amd.label == 'Auto_VIN'){
                    articleId = amd.ArticleId__c;
                }
            }
        } */

        if (divisionName == HONDA_DIVISION_NAME || divisionName == ACURA_DIVISION_NAME){
            articleMetadataName = 'Auto_VIN';
        }
        else if (divisionName == POWERSPORTS_DIVISION_NAME){
            articleMetadataName = 'Powersports_VIN';
        }
        for (Own_Product_Identifier_Help_Page__mdt articleMetadata : articleMetadataList){
            if (articleMetadata.label == articleMetadataName){
                articleId = articleMetadata.ArticleId__c;
            }
        }

        return articleId;
    }

    @AuraEnabled (cacheable = true)
    public static String getArticleNumber(String divisionName){

        String articleNumber;
        String articleMetadataName;

        List<Own_Product_Identifier_Help_Page__mdt> articleMetadataList = Own_Product_Identifier_Help_Page__mdt.getAll().values();

        /* if (divisionName == HONDA_DIVISION_NAME || divisionName == ACURA_DIVISION_NAME){
            articleMetadataName = 'Auto_VIN';
        } */
        if (divisionName == HONDA_DIVISION_NAME){
            articleMetadataName = 'Honda_VIN';
        }
        else if (divisionName == ACURA_DIVISION_NAME){
            articleMetadataName = 'Acura_VIN';
        }
        else if (divisionName == POWERSPORTS_DIVISION_NAME){
            articleMetadataName = 'Powersports_VIN';
        }
        for (Own_Product_Identifier_Help_Page__mdt articleMetadata : articleMetadataList){
            if (articleMetadata.label == articleMetadataName){
                articleNumber = articleMetadata.ArticleNumber__c;
            }
        }


        return articleNumber;
    }

    @AuraEnabled (cacheable = true)
    public static OwnHelpCenterController.Result getProductIdentifierArticle(String divisionName, String guestId){
        Id articleId = getArticleId(divisionName);
        return OwnHelpCenterController.getKnowledgeArticle(articleId, guestId);
    }

    @AuraEnabled (cacheable = true)
    public static OwnHelpCenterController.Result getProductIdentifierArticleByNumber(String divisionName, String guestId){
        String articleNumber = getArticleNumber(divisionName);

        OwnHelpCenterController.Result result = getArticle(articleNumber, guestId);
        
        return result;
    }

    @TestVisible
    private static OwnHelpCenterController.Result getArticle(String articleNumber, String guestId){
        Id userId = UserInfo.getUserId();
        Map<ID, Knowledge__DataCategorySelection> dataCategorySelectionMap = new Map<ID, Knowledge__DataCategorySelection>([SELECT Id, ParentId, toLabel(DataCategoryName) FROM Knowledge__DataCategorySelection]);
        String queryString = 'SELECT Id, KnowledgeArticleId, ArticleNumber, ArticleTotalViewCount, LastPublishedDate, UrlName, Title, Article_Content__c, (SELECT Id, ParentId, DataCategoryName FROM DataCategorySelections), ';
            queryString += '(SELECT Vote__c FROM KnowledgeArticleVotes__r WHERE ';
            if(UserInfo.getUserType() != 'Guest'){
                queryString += 'User__c = :userId) ';
            }else{
                queryString += 'GUID__c = :guestId) ';
            }
            queryString += 'FROM Knowledge__kav ';
            queryString += 'WHERE ';
            queryString += 'ArticleNumber = :articleNumber';
        
        String safeQueryString = String.escapeSingleQuotes(queryString);
        List<Knowledge__kav> kaList = Database.query(safeQueryString);

        List<OwnHelpCenterController.Result> results = new List<OwnHelpCenterController.Result>();
        for (Knowledge__kav ka : kaList){
            OwnHelpCenterController.Result resultsObj = new OwnHelpCenterController.Result();
            resultsObj.id = ka.Id;
            resultsObj.title = ka.Title;
            resultsObj.content = ka.Article_Content__c;
            resultsObj.lastPublishedDate = Test.isRunningTest() ? '' : ka.LastPublishedDate.format('MMMMM dd, yyyy');
            List<OwnHelpCenterController.Category> categories = new List<OwnHelpCenterController.Category>();
            for(Knowledge__DataCategorySelection dataCategorySelection : ka.DataCategorySelections){
                OwnHelpCenterController.Category c = new OwnHelpCenterController.Category();
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


        return !results.isEmpty() ? results[0] : new OwnHelpCenterController.Result();
    }
}
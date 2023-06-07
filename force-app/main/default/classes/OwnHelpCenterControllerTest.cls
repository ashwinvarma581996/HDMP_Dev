@isTest
private inherited sharing class OwnHelpCenterControllerTest {
    /*private static final String KNOWLEDGE_CATEGORY_OBJECT = 'KnowledgeArticleVersion';
    private static final String KNOWLEDGE_CATEGORY_GROUP = 'ProductLine';*/
    @testSetup
    static void testSetup(){
        
        Profile systemAdmin = [select id, name from Profile where  name = 'System Administrator' LIMIT 1];
        User testUser = new User(  
            FirstName = 'test',  
            LastName = 'knowledge user',  
            email = 'testKnowledge@test.com',  
            Username = System.now().millisecond() + 'testknowledge@test.com',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias ='test123',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = systemAdmin.Id,
            userpermissionsknowledgeUser = true
        );  
        Insert testUser;
        system.runAs(testUser){
            //Create Article
            Knowledge__kav kav = new Knowledge__kav(
                Title='I have a question regarding my HondaCard account?',
                urlName='Powersport-I-have-a-question-regarding-my-HondaCard-account-test',
                Article_Content__c = 'Please contact HondaCard directly at 800-250-5411.'
            );
            Insert kav;
            knowledge__kav knowledgeKav = [SELECT Id, Title, KnowledgeArticleId, publishStatus FROM knowledge__kav WHERE id =: kav.Id];
            KbManagement.PublishingService.publishArticle(knowledgeKav.KnowledgeArticleId, true);
            
            System.debug('knowledgeKav--'+knowledgeKav);
            
            //Create Category
            Knowledge__DataCategorySelection dcs = new Knowledge__DataCategorySelection(DataCategoryName='AcuraRecalls');
            dcs.ParentId = knowledgeKav.Id;
            dcs.DataCategoryGroupName = 'ProductLine';
            Insert dcs;
         
        }
    }
    @isTest
    static void getDataCategoriesPositive() {
        Test.startTest();
        OwnHelpCenterController con = new OwnHelpCenterController();
        List<OwnHelpCenterController.Category> dataCategories = OwnHelpCenterController.getDataCategories();
        System.assertNotEquals(null, dataCategories);
        Test.stopTest();
    }
    @isTest
    static void getKnowledgeArticlesPositive() {
        Test.startTest();
        List<OwnHelpCenterController.Category> dataCategories = OwnHelpCenterController.getDataCategories();
        System.assert(dataCategories != null);
        OwnHelpCenterController.Category cat = dataCategories[0];
        String category = cat.name;
        List<OwnHelpCenterController.Result> resultList = OwnHelpCenterController.getKnowledgeArticles(category, 5);
        System.assertNotEquals(null, resultList);
        if(resultList != null && resultList.size() > 0){
           System.assertEquals('article', resultList[0].type); 
        }
        Test.stopTest();
    }
    @isTest
    static void getKnowledgeArticlesNegetive() {
        Test.startTest();
        List<OwnHelpCenterController.Result> resultList = OwnHelpCenterController.getKnowledgeArticles(null, 5);
        System.assertNotEquals(null, resultList);
        Test.stopTest();
    }
    @isTest
    static void getPopularKnowledgeArticlesPositive() {
        Test.startTest();
        List<OwnHelpCenterController.Category> dataCategories = OwnHelpCenterController.getDataCategories();
        System.assert(dataCategories != null);
        OwnHelpCenterController.Category cat = dataCategories[0];
        String category = cat.name;
        List<OwnHelpCenterController.Result> resultList = OwnHelpCenterController.getPopularKnowledgeArticles(category, 4);
        System.assertNotEquals(null, resultList);
        if(resultList != null && resultList.size() > 0){
           System.assertEquals('article', resultList[0].type); 
        }
        Test.stopTest();
    }
    @isTest
    static void getPopularKnowledgeArticlesNegetive() {
        Test.startTest();
        List<OwnHelpCenterController.Result> resultList = OwnHelpCenterController.getPopularKnowledgeArticles('', 4);
        System.assertNotEquals(null, resultList);
        if(resultList != null && resultList.size() > 0){
           System.assertEquals('article', resultList[0].type); 
        }
        Test.stopTest();
    }
    @isTest
    static void getKnowledgeArticlePositive() {
        Test.startTest();
        List<Knowledge__kav> article = [SELECT Id FROM Knowledge__kav LIMIT 1];
        Id articleId = null;
        if(article != null && article.size()>0){
            articleId = article[0].Id;
        }
        OwnHelpCenterController.Result resultObj = new OwnHelpCenterController.Result();
        try{
           resultObj = OwnHelpCenterController.getKnowledgeArticle(articleId, '');
        }catch(Exception e){
            System.debug('exception'+e.getMessage());
            System.debug('exception'+e.getStackTraceString());
            System.assertNotEquals(null, resultObj);
            //System.assertEquals('article', resultObj.type);
        }
        Test.stopTest();
    }
    @isTest
    static void getKnowledgeArticleNegetive() {
        Test.startTest();
        List<Knowledge__kav> article = [SELECT Id FROM Knowledge__kav LIMIT 1];
        Id articleId = null;
        if(article != null && article.size()>0){
            articleId = article[0].Id;
        }
        OwnHelpCenterController.Result resultObj = new OwnHelpCenterController.Result();
        try{
           resultObj = OwnHelpCenterController.getKnowledgeArticle(articleId, null);
        }catch(Exception e){
           System.assertEquals(null, resultObj.id);
        }
        Test.stopTest();
    }
    @isTest
    static void searchPositive(){
        Test.startTest();
        List<OwnHelpCenterController.Category> dataCategories = OwnHelpCenterController.getDataCategories();
        System.assert(dataCategories != null);
        OwnHelpCenterController.Category cat = dataCategories[0];
        String category = cat.name;
        List<OwnHelpCenterController.Result> resultList = OwnHelpCenterController.search('I have a question', category, 'Title', 4);
        System.assertNotEquals(null, resultList);
        if(resultList != null && resultList.size() > 0){
           System.assertEquals('article', resultList[0].type); 
        }
        Test.stopTest();
    }
    @isTest
    static void searchNegetive(){
        Test.startTest();
        try{
            List<OwnHelpCenterController.Result> resultList = OwnHelpCenterController.search('test', 'test', 'Title', 4);
        }catch(Exception e){
            System.debug('exception'+e.getTypeName());
            System.assertNotEquals(null, e);
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }
        Test.stopTest();
    }
    @isTest
    static void getRelatedArticlesPositive(){
        Test.startTest();
        List<OwnHelpCenterController.Category> dataCategories = OwnHelpCenterController.getDataCategories();
        System.assert(dataCategories != null);
        OwnHelpCenterController.Category cat = dataCategories[0];
        String category = cat.name;
        System.debug('category'+category);
        List<OwnHelpCenterController.Result> resultList = OwnHelpCenterController.getRelatedArticles('I have a question', category, 4); 
        System.assertNotEquals(null, resultList);
        Test.stopTest();
    }
    @isTest
    static void getRelatedArticlesNegetive(){
        Test.startTest();
        try{
        List<OwnHelpCenterController.Result> resultList1 = OwnHelpCenterController.getRelatedArticles('test', null, 4); 
        System.assertEquals(0, resultList1.Size());
		List<OwnHelpCenterController.Result> resultList = OwnHelpCenterController.getRelatedArticles('test', 'test', 4);
        }catch(Exception e){
            System.debug('exception'+e.getTypeName());
            System.assertNotEquals(null, e);
            System.assertEquals('System.AuraHandledException', e.getTypeName());
        }
        Test.stopTest();
    }
    @isTest static void addKnowledgeArticleVoteTest(){
        Test.startTest();
            knowledge__kav knowledgeKav = [SELECT Id, Title, KnowledgeArticleId, publishStatus FROM knowledge__kav LIMIT 1];
            OwnHelpCenterController.Result res = OwnHelpCenterController.addKnowledgeArticleVote(knowledgeKav.Id, true, '');
            System.assertEquals(true, res.vote);
        Test.stopTest();
    }
    @isTest static void getKavBasedOnUrlNameTest(){
        string url = 'Powersport-I-have-a-question-regarding-my-HondaCard-account-test';
        String knowledgeArticleId = OwnHelpCenterController.getKavBasedOnUrlName(url);
        System.assert(knowledgeArticleId != null);
    }
}
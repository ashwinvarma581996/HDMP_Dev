@isTest
public with sharing class OwnVINHelpControllerTest {

    @isTest public static void getArticleIdTest(){
        Id hondaArticleId = OwnVINHelpController.getArticleId('Honda');
        Id acuraArticleId = OwnVINHelpController.getArticleId('Acura');
        System.assertEquals(hondaArticleId, acuraArticleId);

        OwnVINHelpController.getProductIdentifierArticle('Honda', '0000000');
    }
}
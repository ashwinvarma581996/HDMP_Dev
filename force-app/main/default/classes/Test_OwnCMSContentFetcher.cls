//*********************************************************************
// File Name : Test_OwnCMSContentFetcher.cls
// Summary   : Test class for OwnCMSContentFetcher
// 
// Created by: Yusuf
// Honda Jira Story: Apex class for fetch CMS content records for Honda Owner Experience
// ********************************************************************
// Modification Log:
// Oct 12, 2021 Yusuf (Wipro)
// ********************************************************************
@isTest
public class Test_OwnCMSContentFetcher {
    
    @IsTest(SeeAllData=true)
    static void testGetContentList(){
        List<ConnectApi.ManagedContentVersion> itemsList = OwnCMSContentFetcher.getContentList(new List<string>{'MyGarage'}, 0, null, 'en_US', '');
    	//System.assert(itemsList.size() > 0 , 'Error : content items not fetched');
    }
    
    @IsTest(SeeAllData=true)
    static void testGetContent(){
        Map<String, ConnectApi.ManagedContentNodeValue> managedContentItem = OwnCMSContentFetcher.getContent('', 0, 0, 'en_US', '');
        //System.assert(managedContentItem != null , 'Error : content item not fetched');
    }
}
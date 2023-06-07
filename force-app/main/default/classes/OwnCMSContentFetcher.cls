//****************************************
// File Name	: 	OwnCMSContentFetcher.cls
// Summary		:	Apex class for fetch CMS content type records
// Test class   : Test_OwnCMSContentFetcher.cls
// Created On	: 	10-04-2021
// Created By	:  Yusuf Deshwali (Wipro)
// *******************************
public with sharing class OwnCMSContentFetcher {
	@AuraEnabled(Cacheable = true)
    public static List<ConnectApi.ManagedContentVersion> getContentList(List<String> topics, Integer page, Integer pageSize, String language, String filterby){
        try {
            String networkId = Network.getNetworkId();
            if(Test.isRunningTest()) {
            	networkId = [SELECT Id FROM Network WHERE Name = 'MyGarage'].Id;
            }
            ConnectApi.ManagedContentVersionCollection contentCollection = ConnectApi.ManagedContent.getManagedContentByTopics(
                networkId, 
                topics, 
                page,
                pageSize,
                language, 
                filterby);
            return contentCollection.items;
        }catch(ConnectApi.ConnectApiException e){
            System.debug('Error Message : ' + e);
            return new List<ConnectApi.ManagedContentVersion>();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, ConnectApi.ManagedContentNodeValue> getContent(String contentId, Integer page, Integer pageSize, String language, String filterby){
        try {
            String networkId = Network.getNetworkId();
            if(Test.isRunningTest()) {
            	networkId = [SELECT Id FROM Network WHERE Name = 'MyGarage'].Id;
                contentId = ConnectApi.ManagedContent.getManagedContentByTopics(networkId, new List<string>{'MyGarage'}, 0, null, 'en_US', '').items[0].contentKey;
            }
            ConnectApi.ManagedContentVersionCollection contentCollection = ConnectApi.ManagedContent.getManagedContentByContentKeys(
                networkId,
                new List<String>{ contentId },
                0,
                1,
                language,
                filterby,
                false
            );
            return contentCollection.items[0].contentNodes;
        } catch (ConnectApi.ConnectApiException e) {
            System.debug('Error Message : ' + e);
            return new Map<String, ConnectApi.ManagedContentNodeValue>();
        }
    }
}
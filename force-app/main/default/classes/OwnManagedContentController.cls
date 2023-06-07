//****************************************************************************** 
// File Name:       OwnManagedContentController.cls
// Summary:         Apex Class for Garage
// Created On:      10-18-2021
// Created By:      Arunprasad N (Wipro)
// Test Classes:    OwnManagedContentControllerTest.cls
// Data I/O:        
// Honda Jira Story: Apex class for API of Honda MyGarage Experience
//===============================================================================
// Modification Log: 
// October 18, 2021 Arunprasad N (Wipro) initial coding
//*******************************************************************************
public without sharing class OwnManagedContentController {
    public OwnManagedContentController() {

    }

    //====================
    //= get CMS content for topics
    //====================
    @AuraEnabled(cacheable=true)
    public static List<ContentType> getManagedContentByTopicsAndContentKeys(List<String> contentKeys, List<String> topics, Integer pageSize, String managedContentType) {
        try {
            String language = UserInfo.getUserType() == 'Guest' ? 'en_US' : UserInfo.getLanguage();
            String communityId = Network.getNetworkId();
            if(Test.isRunningTest()) {
            	communityId = [SELECT Id FROM Network WHERE Name = 'MyGarage'].Id;
            }
            //ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getManagedContentByTopics(communityId, topics, 0, pageSize, language, managedContentType);
            ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getManagedContentByTopicsAndContentKeys(communityId, contentKeys, topics, 0, pageSize, language, managedContentType, false);
            return getCMSContent(managedContentVersionCollection);
        }catch(Exception e) {
            System.debug('Exception'+ e.getMessage());
            System.debug('Exception'+ e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    //====================
    //= populate cms content
    //====================
    private static List<ContentType> getCMSContent(ConnectApi.ManagedContentVersionCollection managedContentVersionCollection) {
        try {
            List<ConnectApi.ManagedContentVersion> managedContentVersions = managedContentVersionCollection.items;
            List<ContentType> contentTypes = new List<ContentType>();
            for(ConnectApi.ManagedContentVersion managedContentVersion : managedContentVersions){
                System.debug('managedContentVersion : '+managedContentVersion);
                ContentType contentTypeObj = new ContentType();
                contentTypeObj.key = managedContentVersion.contentKey;
                contentTypeObj.title = managedContentVersion.contentNodes.get('title');
                contentTypeObj.subTitle = managedContentVersion.contentNodes.get('sub_title');
                contentTypeObj.body = managedContentVersion.contentNodes.get('body');
                contentTypeObj.descriptionLabel = managedContentVersion.contentNodes.get('description_label');
                contentTypeObj.descriptionContent = managedContentVersion.contentNodes.get('description_content');
                contentTypeObj.description2Label = managedContentVersion.contentNodes.get('description2_label');
                contentTypeObj.description2Content = managedContentVersion.contentNodes.get('description2_content');
                contentTypeObj.sectionLabel = managedContentVersion.contentNodes.get('section_label');
                contentTypeObj.sectionContent = managedContentVersion.contentNodes.get('section_content');
                contentTypeObj.phoneLabel = managedContentVersion.contentNodes.get('phone_label');
                contentTypeObj.phoneNumber = managedContentVersion.contentNodes.get('phone_number');
                contentTypeObj.phone2Label = managedContentVersion.contentNodes.get('phone2_label');
                contentTypeObj.phone2Number = managedContentVersion.contentNodes.get('phone2_number');
                contentTypeObj.phone3Label = managedContentVersion.contentNodes.get('phone3_label');
                contentTypeObj.phone3Number = managedContentVersion.contentNodes.get('phone3_number');
                contentTypeObj.phone4Label = managedContentVersion.contentNodes.get('phone4_label');
                contentTypeObj.phone4Number = managedContentVersion.contentNodes.get('phone4_number');
                contentTypeObj.image = managedContentVersion.contentNodes.get('image');
                contentTypeObj.downloadLabel = managedContentVersion.contentNodes.get('downloadLabel');
                contentTypeObj.downloadLink = managedContentVersion.contentNodes.get('download_link');
                contentTypeObj.videoLink = managedContentVersion.contentNodes.get('video_link');
                contentTypeObj.publishedDate = managedContentVersion.publishedDate;
                contentTypes.add(contentTypeObj);
            }
            return contentTypes;
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ContentType {
        @AuraEnabled public string key {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue title {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue subTitle {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue body {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue descriptionLabel {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue descriptionContent {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue description2Label {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue description2Content {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue sectionLabel {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue sectionContent {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue phoneLabel {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue phoneNumber {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue phone2Label {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue phone2Number {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue phone3Label {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue phone3Number {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue phone4Label {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue phone4Number {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue image {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue downloadLabel {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue downloadLink {get; set;}
        @AuraEnabled public ConnectApi.ManagedContentNodeValue videoLink {get; set;}
        @AuraEnabled public Datetime publishedDate {get; set;}
        Public ContentType(){}
    }
}
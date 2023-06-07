//****************************************************************************** 
// File Name:       OwnManagedContentControllerTest.cls
// Summary:         Apex Class for Garage
// Created On:      29-12-2021
// Created By:      Arunprasad N (Wipro)
// Data I/O:        
// Honda Jira Story: Apex class for fetch CMS records of Honda MyGarage Experience
//===============================================================================
// Modification Log: 
// December 29, 2021 Yusuf Deshwali (Wipro) added test methods
//*******************************************************************************
@isTest
public class OwnManagedContentControllerTest {
	@IsTest(SeeAllData=true) 
    static void getManagedContentByTopicsAndContentKeysTest(){
        List<string> contentKeys = new List<string>();
        List<string> topics = new List<string>();
        OwnManagedContentController.ContentType contentObj = new OwnManagedContentController.ContentType();
        List<OwnManagedContentController.ContentType> contentTypeList = new List<OwnManagedContentController.ContentType>();
        //contet key for testing 'MCJTSB7CK2WZFN5E2DQKTV3RXT2E'
        contentTypeList = OwnManagedContentController.getManagedContentByTopicsAndContentKeys(contentKeys, topics, 1, '');
    	System.assert(contentTypeList.size() > 0 , 'Error : content items not fetched');
    }
}
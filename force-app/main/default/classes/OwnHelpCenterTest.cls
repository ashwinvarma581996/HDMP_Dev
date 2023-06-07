//****************************************************************************** 
// File Name:       OwnHelpCenterTest.cls
// Summary:         Apex test Class to support owner Help Center
// Created On:      19-05-2021
// Created By:      Bharadwaj Reddy Katta, Appirio
// Test Classes:    OwnHelpCenterTest
// Data I/O:        
// Honda Jira Story: DOE-1236:Create Apex Test Class for OwnHelpCenter.cls
//===============================================================================
// Modification Log: 
//*******************************************************************************
@isTest
public class OwnHelpCenterTest 
{
    //positive Tests
    @isTest
    static void getHondaCategoriesTest()
    { 
        Map<String,String>hondaCatMap = new Map<String,String>();
        hondaCatMap = ownhelpcenter.getHondaCategories();
        //Positive test 
        system.assertEquals(True,hondaCatMap.size()>1,'Error in checking with correct param');
    }
    @isTest
    static void getAcuraCategoriesTest()
    {
        Map<String,String>acuraCatMap = new Map<String,String>();
        acuraCatMap = ownhelpcenter.getAcuraCategories();
        system.assertEquals(True,acuraCatMap.size()>1,'Error in checking with correct param');
    }
    @isTest
    static void getPECategoriesTest()
    { 
        Map<String,String>peCatMap = new Map<String,String>();
        peCatMap = ownhelpcenter.getPECategories();
        system.assertEquals(True,peCatMap.size()>1,'Error in checking with correct param');
    }
    @isTest
    static void getPSCategoriesTest()
    {
        Map<String,String>psCatMap = new Map<String,String>();
        psCatMap = ownhelpcenter.getPSCategories();
        system.assertEquals(True,psCatMap.size()>1,'Error in checking with correct param');
    }
    @isTest
    static void getMarineCategoriesTest()
    {
        Map<String,String>marineCatMap = new Map<String,String>();
        marineCatMap = OwnHelpCenter.getMarineCategories();
        system.assertEquals(True,marineCatMap.size()>1,'Error in checking with correct param');
    }
    
    @isTest
	static void createAndTestBrandTimes()
    {
		Map<String, OwnGarageChatConfig__mdt> allBrands = OwnGarageChatConfig__mdt.getAll();

        for(String brnd : allBrands.keySet()){
            OwnHelpCenter.isChatAvailable(allBrands.get(brnd).Label);
        }
    }
    
    //Negative testing
    @isTest
    static void doNegativeTest()
    {
        Map<String,String>catMap=  OwnHelpCenter.getSubCategoriesNameAndLabels('KittyCats');
        system.assertEquals(null, catMap,'Error in checking with wrong param');
    }

	@isTest
	static void incorrectBrandAvailable()
    {
       Boolean a = OwnHelpCenter.isChatAvailable('wrongName');
	   system.assertEquals(false, a);
    }
}
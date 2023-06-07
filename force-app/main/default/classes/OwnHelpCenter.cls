//****************************************************************************** 
// File Name:       OwnHelpCenter.cls
// Summary:         Apex Class to support Community Help Center
// Created On:      19-05-2021
// Created By:      Bharadwaj Reddy Katta, Appirio
// Test Classes:    OwnHelpCenterTest
// Data I/O:        
// Honda Jira Story: DOE-1235:Create Apex to support Help Center
//===============================================================================
// Modification Log: Added if condition in line 20 : Bharadwaj
//*******************************************************************************
public with sharing class OwnHelpCenter
{
    private Static Final String hondaName = 'HondaAutos';
    private Static Final String acuraName = 'AcuraAutos';
    private Static Final String psName = 'HondaPowersports';
    private Static Final String peName = 'HondaPowerEquipment';
    private Static Final String marineName = 'HondaMarine';
    private static final String KNOWLEDGE_CATEGORY_OBJECT = 'KnowledgeArticleVersion';
    private static final String KNOWLEDGE_CATEGORY_FIELD_MAPPING_NAME = 'ProductLine';
    //method to get child categories based on the category name
    @TestVisible 
    public static Map<String,String> getSubCategoriesNameAndLabels(String categoryName)
    {
        List<DataCategory> subCategories = getAllSubCategoriesByName(categoryName);
        Map<String,String> categoryNamesAndLabelsMap = new Map<String,String>();
        try{
            for(DataCategory category:subCategories)
            {
                categoryNamesAndLabelsMap.put(category.getName(),category.getLabel());
            }
            return categoryNamesAndLabelsMap;
        }
        catch(exception e)
        {
            system.debug('Error message===='+e.getMessage()); 
        }
        return null; 
    }
    
    
    //method to retrieve all the subcategories from top level categories.
    @TestVisible 
    private static List<DataCategory> getAllSubCategoriesByName(String categoryName)
    {
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = getDescribeDataCategoryGroupStructureResults();
        for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult)
        {
            DataCategory [] toplevelCategories =  singleResult.getTopCategories();
            List<DataCategory> allCategories = getAllCategories(toplevelCategories);
            for(DataCategory category : allCategories) 
            {
                if(categoryName==category.getName())
                {
                    return category.getChildCategories();  
                }
            } 
        }
        return null;
    }
    //method to get the data structure    
    @TestVisible
    private static List<DescribeDataCategoryGroupStructureResult> getDescribeDataCategoryGroupStructureResults()
    {
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        List<string> catNames = new list<string>();
        try
        {
            List<String> objType = new List<String>();
            objType.add(KNOWLEDGE_CATEGORY_OBJECT);
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);
            List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
            for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult)
            {
                if(singleResult.getName().equals(KNOWLEDGE_CATEGORY_FIELD_MAPPING_NAME))
                {
                    DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                    p.setSobject(singleResult.getSobject());
                    p.setDataCategoryGroupName(singleResult.getName());
                    pairs.add(p);
                    if(pairs.isEmpty()) {
                        throw new AuraHandledException('Unable to find requested Schema.DataCategoryGroupSobjectTypePair for <' + KNOWLEDGE_CATEGORY_OBJECT + '> called <' + KNOWLEDGE_CATEGORY_FIELD_MAPPING_NAME + '>');
                    }
                    else{
                        describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);  
                    } 
                }
            }
        } 
        catch (Exception e)
        {
            //Exception handling
            system.debug('===Error Message===='+e.getMessage());
            system.debug('====Error Cause====='+e.getCause());
            system.debug('======Error Type====== '+e.getTypeName());
        }
        
        return describeCategoryStructureResult;
    }
    //method to get all categories
    @TestVisible
    private static DataCategory[] getAllCategories(DataCategory [] categories)
    {
        if(categories.isEmpty())
        {
            return new DataCategory[]{};
                } 
        else 
        {
            DataCategory [] categoriesClone = categories.clone();
            DataCategory category = categoriesClone[0];
            DataCategory[] allCategories = new DataCategory[]{category};
                categoriesClone.remove(0);
            categoriesClone.addAll(category.getChildCategories());
            allCategories.addAll(getAllCategories(categoriesClone));
            return allCategories;
        }
    }
    //methods to get child categories of respective category names
    @AuraEnabled(cacheable=true) 
    public static Map<String,String> getHondaCategories()
    { 
        Map<String,String>hondaCatMap = new Map<String,String>();
        hondaCatMap = OwnHelpCenter.getSubCategoriesNameAndLabels(hondaName);
        system.debug('jsdc'+hondaCatMap);
        return hondaCatMap;
    }
    @AuraEnabled(cacheable=true) 
    public static Map<String,String> getAcuraCategories() 
    { 
        Map<String,String>acuraCatMap = new Map<String,String>();
        acuraCatMap = OwnHelpCenter.getSubCategoriesNameAndLabels(acuraName);
        return acuraCatMap;
    }
    @AuraEnabled(cacheable=true) 
    public static Map<String,String> getPECategories() 
    {
        Map<String,String>peCatMap = new Map<String,String>();
        peCatMap = OwnHelpCenter.getSubCategoriesNameAndLabels(peName);
        return peCatMap;
    }
    @AuraEnabled(cacheable=true) 
    public static Map<String,String> getPSCategories() 
    {
        Map<String,String>psCatMap = new Map<String,String>();
        psCatMap = OwnHelpCenter.getSubCategoriesNameAndLabels(psName);
        return psCatMap;
    }
    @AuraEnabled(cacheable=true) 
    public static Map<String,String> getMarineCategories() 
    { 
        Map<String,String>marineCatMap = new Map<String,String>();
        marineCatMap = OwnHelpCenter.getSubCategoriesNameAndLabels(marineName);
        return marineCatMap;
    }
    
    //Nov 11 Chat availability method - Brett Spokes
    @AuraEnabled(cacheable=true)
    public static Boolean isChatAvailable(String brandName)
    {         
        OwnGarageChatConfig__mdt currentBrand = OwnGarageChatConfig__mdt.getInstance(brandName);
        String startTimeStr = '';
        try{
         startTimeStr = currentBrand.StartTime__c;
        }
        catch (NullPointerException e)
        {
            //Exception handling
            system.debug('===Error Message===='+e.getMessage());
            system.debug('====Error Cause====='+e.getCause());
            system.debug('======Error Type====== '+e.getTypeName());
			system.debug('Check if brandName is spelled correctly');
            return false;
        }  

        //DOE-4992
        Timezone tz = Timezone.getTimeZone('America/Los_Angeles');
        String tzDisplayName = tz.getDisplayName(); 
        
        TimeWarpper startTimeWrapper = new TimeWarpper(startTimeStr);
        Time startTime = Time.newInstance(startTimeWrapper.hours, startTimeWrapper.minutes, 0,0);     
        
        String endTimeStr = currentBrand.EndTime__c;
        TimeWarpper endTimeWrapper = new TimeWarpper(endTimeStr);
        Time endTime = Time.newInstance(endTimeWrapper.hours, endTimeWrapper.minutes, 0,0);
        
        
        datetime currentGMTTime = datetime.now();
        date currentDate = currentGMTTime.dateGMT();
        
        datetime startGMTTime;
        datetime endGMTTime;

        if(tzDisplayName.contains('Standard')){
            System.debug(tzDisplayName);
            startGMTTime = datetime.newInstanceGMT(currentDate, startTime);
            endGMTTime = datetime.newInstanceGMT(currentDate, endTime);

            //Nov 18 - Brett Spokes ; Adjusts the end time to be the next day
            if (startTimeStr.contains('PM') && endTimeStr.contains('AM')) {
                endGMTTime = datetime.newInstanceGMT(currentDate+1, endTime);
                
            }

            System.debug('StartTime: ' + startGMTTime + ' || EndTime: ' + endGMTTime );
        }
        
        if(tzDisplayName.contains('Daylight')){
            System.debug(tzDisplayName);
            startGMTTime = datetime.newInstanceGMT(currentDate, (startTime.addHours(-1)));
            endGMTTime = datetime.newInstanceGMT(currentDate, (endTime.addHours(-1)));

            //Nov 18 - Brett Spokes ; Adjusts the end time to be the next day
            if (startTimeStr.contains('PM') && endTimeStr.contains('AM')) {
                endGMTTime = datetime.newInstanceGMT(currentDate+1, (endTime.addHours(-1)));
            
            }

            System.debug('StartTime: ' + startGMTTime + ' || EndTime: ' + endGMTTime );
        }

		
		

        
        
        boolean chatIsAvailable = false;
        
        if (currentBrand.IsActive__c == true)
        {
            if(currentGMTTime >= startGMTTime && currentGMTTime <=endGMTTime)
            {
                chatIsAvailable = true;
            }
        }
        
        system.debug('Chat is available:' + chatIsAvailable);
        
        return chatIsAvailable;
        
    }
    
    public class TimeWarpper
    {
        Integer hours { get; set;}
        Integer minutes { get; set;}
        String meridiem { get; set;}
        
        public TimeWarpper(String timeStr)
        {
            String[] times = timeStr.split(':| ');
            this.hours = Integer.valueOf(times.get(0));
            this.minutes = Integer.valueOf(times.get(1));
            this.meridiem = times.get(2);
            
            //set the time in 24 hr format
            
            if(this.meridiem == 'PM')
            {
                this.hours += 12;
            }
        }
    }
}
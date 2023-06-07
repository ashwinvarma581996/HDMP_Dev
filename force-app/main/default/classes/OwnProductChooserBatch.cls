//****************************************************************************** 
// File Name:       OwnProductChooserBatch.cls
// Summary:         Batch Class for fetching Product Chooser details
// Created On:      22-12-2021
// Created By:      Girish J (Wipro) 
// Test Classes:    OwnProductChooserBatchTest.cls
// Data I/O:        
// Honda Jira Story: DOE-2520 & DOE-2568 
//*******************************************************************************

global without sharing class OwnProductChooserBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    OwnProductChooserBatchJSON.ResponseWrapper response;
    Integer productChooserRecords;
    /* Integer startYear = '2000';
    Integer endYear = '2020'; */
    String divisionName;
    String divisionId;
    String imagePrefix;
    OwnProductChooserBatchHelper helper;
    
    global OwnProductChooserBatch(String divisionName, String divisionId) {
/*         OwnProductChooserBatchHelper helper = new OwnProductChooserBatchHelper();
        helper.divisionName = 'Acura';
        this.response = helper.fetchData('2020'); */
        this.productChooserRecords = 0;
        this.divisionName = divisionName;
        this.divisionId = divisionId;
        switch on divisionName{
            when 'Honda'{
                this.imagePrefix = System.Label.Honda_Image_Prefix;
            }
            when 'Acura'{
                this.imagePrefix = System.Label.Acura_Image_Prefix;
            }
            when 'Powersports'{
                this.imagePrefix = System.Label.Powersports_Image_Prefix;
            }
            when 'Motorcycle/Powersports'{
                this.imagePrefix = System.Label.Powersports_Image_Prefix;
            }
        }
        this.helper = new OwnProductChooserBatchHelper(divisionName, divisionId);
    }
    
    global Iterable<String> start(Database.BatchableContext BC) {
        // API callout to retrieve years
        Set<String> brandYears = OwnProductChooserBatchHelper.getBrandYears(this.divisionName, this.divisionId);
        List<String> brandYearList = new List<String>();
        /* brandYearList.add('2022');
        brandYearList.add('2021');
        brandYearList.add('2020');
        brandYearList.add('2019'); */
        brandYearList.addAll(brandYears);

        System.debug('Running batch class for years: ');
        System.debug(brandYearList);

        return brandYearList;
    }
    
    global void execute(Database.BatchableContext BC, List<String> scope) {
        System.debug('Running batch for years: ' + JSON.serialize(scope));
        for (String year : scope){
/*             OwnProductChooserBatchHelper helper = new OwnProductChooserBatchHelper();
            helper.divisionName = this.divisionName;
            helper.divisionCode = this.divisionId; */
            OwnProductChooserBatchJSON.ResponseWrapper response = helper.fetchData(year);
         //   System.debug(response);

            List<OwnProductChooserBatchHelper.BatchRecord> batchRecords = new List<OwnProductChooserBatchHelper.BatchRecord>();
            if(response != NULL){
                batchRecords = helper.fetchRecords(response, year);
            }

            System.debug('fetchRecords returned with ' + JSON.serialize(batchRecords));

            Map<Integer, Product_Model__c> modelMap = new Map<Integer, Product_Model__c>();
            List<Product_Chooser__c> productChooserList = new List<Product_Chooser__c>();
            List<Product_Model_Color__c> productModelColorList = new List<Product_Model_Color__c>();

            for(OwnProductChooserBatchHelper.BatchRecord record : batchRecords){ 
                modelMap.put(batchRecords.indexOf(record), record.productModel);
            }

            Database.upsert(modelMap.values(), false);
            for(Integer index : modelMap.keyset()){
                System.debug('index: ' + index);
                String modelId = modelMap.get(index).Id;
                OwnProductChooserBatchHelper.BatchRecord record = batchRecords.get(index);
                record.productChooser.Product_Model__c = modelId;
                
                System.debug('Record ' + record.productChooser);

                if(!productChooserList.contains(record.productChooser)){
                    System.debug('Adding ' + record.productChooser + ' to insert list');
                    productChooserList.add(record.productChooser);
                }
                Set<Id> modelColorIds = new Set<Id>();
                Set<String> mfgColorCds = new Set<String>();
                for(Product_Model_Color__c color : record.modelColorList){
                    //System.debug(color);
                    color.Product_Model__c = modelId;
                    color.Thumbnail_Image_URL__c = this.imagePrefix + color.Thumbnail_Image_URL__c;
                    color.Large_Image_URL__c = this.imagePrefix + color.Large_Image_URL__c;

                    if (color.Id != null){
                        if(!mfgColorCds.contains(color.Manufacturer_Color_Code__c) && !modelColorIds.contains(color.Id) && !String.isEmpty(color.Product_Model__c)){
                            productModelColorList.add(color);
                            modelColorIds.add(color.Id);
                        }
                    }
                    else{
                        if(!mfgColorCds.contains(color.Manufacturer_Color_Code__c)){
                            productModelColorList.add(color);
                        }
                    }
                    mfgColorCds.add(color.Manufacturer_Color_Code__c);
                }
            }
            //Test code//
            Set<String> pmIdMfgColorCodeSet = new Set<String>();

            for (Product_Model_Color__c pmc : productModelColorList){
                String pmIdMfgColorCd = pmc.Product_Model__c + pmc.Manufacturer_Color_Code__c;
                if (pmIdMfgColorCodeSet.contains(pmIdMfgColorCd)){
                    System.debug('***Duplicate Found: ' + pmc.Id);
                    pmIdMfgColorCodeSet.add(pmIdMfgColorCd);
                }
            }
            /////////////
            System.debug(this.productChooserRecords);
            System.debug(productChooserList.size());
            System.debug('Final list: ' + productChooserList);
            this.productChooserRecords = this.productChooserRecords + productChooserList.size();
            Database.upsert(productModelColorList, false);
            List<Database.saveResult> dmlResult = Database.insert(productChooserList, false);
            
            for (Database.saveResult result : dmlResult){
                System.debug('Result ' + result.getId() + ':');
                System.debug(result.isSuccess());
                System.debug(Result.getErrors());
            }

        }

        /* List<OwnProductChooserBatchHelper.BatchRecord> batchRecords = new List<OwnProductChooserBatchHelper.BatchRecord>();
        if(response != NULL){
            batchRecords = helper.fetchRecords(this.response);
        } */

        /* Map<Integer, Product_Model__c> modelMap = new Map<Integer, Product_Model__c>();
        List<Product_Chooser__c> productChooserList = new List<Product_Chooser__c>();
        List<Product_Model_Color__c> productModelColorList = new List<Product_Model_Color__c>();
        for(OwnProductChooserBatchHelper.BatchRecord record : scope){ 
            modelMap.put(scope.indexOf(record), record.productModel);
        }
        Database.upsert(modelMap.values(), false);
        for(Integer index : modelMap.keyset()){
            String modelId = modelMap.get(index).Id;
            OwnProductChooserBatchHelper.BatchRecord record = scope.get(index);
            record.productChooser.Product_Model__c = modelId;
           
            if(!productChooserList.contains(record.productChooser)){
                productChooserList.add(record.productChooser);
            }
            for(Product_Model_Color__c color : record.modelColorList){
                color.Product_Model__c = modelId;
                    if(!productModelColorList.contains(color)){
                         productModelColorList.add(color);
                    }
            }
        }
        this.productChooserRecords = this.productChooserRecords + productChooserList.size();
        Database.upsert(productModelColorList, false);
        Database.insert(productChooserList, false); */
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Finish');
        Batch_productChooserOrgCache chooserBatch = new Batch_productChooserOrgCache(this.divisionName);
        Database.executeBatch(chooserBatch);
        Integer insertedChooserList = [SELECT Id, CreatedDate FROM Product_Chooser__c WHERE CreatedDate = TODAY AND Application_Name__c = 'My_Garage' AND Product_Subdivision__c = :this.divisionName].size();
		Integer insertedChooserControlList = [SELECT Id, CreatedDate FROM Product_Chooser_Control__c WHERE CreatedDate = TODAY AND Application_Name__c = 'My_Garage' AND Product_Subdivision__c = :this.divisionName].size();      
         if(insertedChooserList > 0 && insertedChooserControlList > 0){ 
            System.debug('Executing org cache batch');
            DELETE [SELECT Id, CreatedDate FROM Product_Chooser_Control__c WHERE CreatedDate != TODAY AND Application_Name__c = 'My_Garage' AND Product_Subdivision__c = :this.divisionName];
			DELETE [SELECT Id, CreatedDate FROM Product_Chooser__c  WHERE CreatedDate != TODAY AND Application_Name__c = 'My_Garage' AND Product_Subdivision__c = :this.divisionName];
        } 
    }

    public class YearsIterator implements Iterator<String>{ 
        
        private List<String> years;
        private Integer startYear;
        private Integer endYear;
        private Integer currentIndex;
        
        public YearsIterator(List<String> years){
            this.years = years;
            this.currentIndex = 0;
        }
        
        public boolean hasNext(){ 
            return currentIndex < years.size()-1;
        }
        
        public String next(){
            if(hasNext()) {
                currentIndex++;
                return years[currentIndex];
            } else {
                throw new NoSuchElementException();
            }
        } 
    }
}
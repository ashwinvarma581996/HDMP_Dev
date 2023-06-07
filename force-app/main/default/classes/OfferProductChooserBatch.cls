//****************************************************************************** 
// File Name:       OfferProductChooserBatch.cls
// Summary:         Batch Class for fetching Product Chooser details
// Created On:      02-23-2023
// Created By:      Nirmalraj Manoharan(B2C) 
// Test Classes:    OfferProductChooserBatchTest.cls
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************

global without sharing class OfferProductChooserBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    OfferProductChooserBatchJSON.ResponseWrapper response;
    Integer productChooserRecords;
    /* Integer startYear = '2000';
    Integer endYear = '2020'; */
    String divisionName;
    String divisionId;
    String categoryCode;
    String imagePrefix;
    String BrandsiteImgPrefix;
    String currEnv;
    OfferProductChooserBatchHelper helper;
    
    global OfferProductChooserBatch(String divisionName, String divisionId,String categoryCode) {
/*         
        helper.divisionName = 'Acura';
        this.response = helper.fetchData('2020'); */
        this.productChooserRecords = 0;
        this.divisionName = divisionName;
        this.divisionId = divisionId;
        this.categoryCode=categoryCode;
        Map<String, Environment_Setting__mdt> mapEd = Environment_Setting__mdt.getAll();
        for(String nameEnvironment : mapEd.keySet()){
            currEnv=mapEd.get(nameEnvironment).environment__c.toLowercase();
            System.debug('Current Environment:----->  '+mapEd.get(nameEnvironment).environment__c);           
            }

        switch on divisionName{
            when 'Honda'{
                this.imagePrefix = System.Label.Honda_Image_Prefix;
                this.BrandsiteImgPrefix=System.Label.Honda_Brandsite_Image_Prefix;
            }
            when 'Acura'{
                this.imagePrefix = System.Label.Acura_Image_Prefix;
                this.BrandsiteImgPrefix=System.Label.Acura_Brandsite_Image_Prefix;
            }
            when 'Powersports'{
                this.imagePrefix = System.Label.Powersports_Image_Prefix;
            }
            when 'Motorcycle/Powersports'{
                this.imagePrefix = System.Label.Powersports_Image_Prefix;
            }
        }
        this.helper = new OfferProductChooserBatchHelper(divisionName, divisionId, categoryCode, currEnv);
    }
    
    global Iterable<String> start(Database.BatchableContext BC) {
        // API callout to retrieve years
        Set<String> brandYears = OfferProductChooserBatchHelper.getBrandYears(this.divisionName, this.divisionId,this.categoryCode,currEnv);
        if(brandYears!=null)
        {
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
        else
        {
            System.debug('Job Aborted. Job Id is: '+ BC.getJobId() + ' .eConfig GetBrandLineProductByDivision API Response is Null. Please check Error Object table(Error__c) for more Details.');
            System.abortJob(BC.getJobId());
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<String> scope) {
        System.debug('Running batch for years: ' + JSON.serialize(scope));
        String ImgNullRcords = '';
        for (String year : scope)
        {
 /*           
            helper.divisionName = this.divisionName;
            helper.divisionCode = this.divisionId; */

                    OfferProductChooserBatchJSON.ResponseWrapper response = helper.fetchData(year,this.categoryCode,currEnv);       
                    List<OfferProductChooserBatchHelper.BatchRecord> batchRecords = new List<OfferProductChooserBatchHelper.BatchRecord>();
            if(response != NULL)
            {
                    batchRecords = helper.fetchRecords(response, year, this.categoryCode);                  
                    System.debug('fetchRecords returned with ' + JSON.serialize(batchRecords));
                    Map<Integer, Product_Model__c> modelMap = new Map<Integer, Product_Model__c>();
                    List<Product_Chooser__c> productChooserList = new List<Product_Chooser__c>();
                    List<Product_Model_Color__c> productModelColorList = new List<Product_Model_Color__c>();
                        for(OfferProductChooserBatchHelper.BatchRecord record : batchRecords){ 
                            modelMap.put(batchRecords.indexOf(record), record.productModel);
                            System.debug('Record Model' + record.productModel);
                        }          
                    Database.upsert(modelMap.values(), false);
                    for(Integer index : modelMap.keyset()){
                        System.debug('index: ' + index);
                        String modelId = modelMap.get(index).Id;
                        OfferProductChooserBatchHelper.BatchRecord record = batchRecords.get(index);
                        record.productChooser.Product_Model__c = modelId;
                        
                    

                        if(!productChooserList.contains(record.productChooser))
                        {                  
                            productChooserList.add(record.productChooser);
                        }
                        Set<Id> modelColorIds = new Set<Id>();
                        Set<String> mfgColorCds = new Set<String>();
                        for(Product_Model_Color__c color : record.modelColorList){
                            //System.debug(color);
                            color.Product_Model__c = modelId;

                            if(string.isBlank(color.Offer_Image_Large_URL__c)){
                                ImgNullRcords = ImgNullRcords +  'ModelId: ' + color.Model_ID_Manufacture_Color_Code__c +' ProductDivision: ' + this.divisionName +  ';';                                                        

                            }
                            if(this.divisionName!= 'Powersports')
                            {
                                    if(this.divisionName=='Acura' && color.Offer_Image_Large_URL__c!=null && !String.isEmpty(color.Offer_Image_Large_URL__c) &&
                                        !color.Offer_Image_Large_URL__c.startsWith('/-/media')){
                                                    color.Offer_Image_Large_URL__c=this.BrandsiteImgPrefix + '/assets'+   color.Offer_Image_Large_URL__c;
                                                    color.Offer_Image_Thumb_URL__c=this.BrandsiteImgPrefix + '/assets'+ color.Offer_Image_Thumb_URL__c;
                                    }                           
                                    else{                       
                                                    color.Offer_Image_Large_URL__c=this.BrandsiteImgPrefix +  color.Offer_Image_Large_URL__c;
                                                    color.Offer_Image_Thumb_URL__c=this.BrandsiteImgPrefix + color.Offer_Image_Thumb_URL__c;
                                    }
                            }
                            else
                            {
                                color.Offer_Image_Large_URL__c=this.imagePrefix +color.Offer_Image_Large_URL__c;
                                color.Offer_Image_Thumb_URL__c=this.imagePrefix +color.Offer_Image_Thumb_URL__c;
                                }

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
                    if(!String.isBlank(ImgNullRcords)){
                        OfferAPIController.createErrorRecord(true,'OfferImageUrl_is_Null',null,null,null,null,'OfferProductChooserBatchHelper',
                        '',null,null,
                        'fetchRecords',false,null,null,null,0,null,'',ImgNullRcords); 
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
                    //List<Database.saveResult> dmlResult = Database.insert(productChooserList, false);
                   List<Database.saveResult> dmlResult = Database.insert(productChooserList, false);
                    
                    for (Database.saveResult result : dmlResult){
                        System.debug('Result ' + result.getId() + ':');
                        System.debug(result.isSuccess());
                        System.debug(Result.getErrors());
                    }
        }
        else{
            System.debug('Result: eConfig GetBaseDetails API Response is Null. Please check Error Object table(Error__c) for more Details.');
        }
    }
     
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Finish');
        Batch_productChooserOrgCache chooserBatch = new Batch_productChooserOrgCache(this.divisionName);
        Database.executeBatch(chooserBatch);
        Integer insertedChooserList = [SELECT Id, CreatedDate FROM Product_Chooser__c WHERE CreatedDate = TODAY AND Application_Name__c in ('Current_Offers_Used','Current_Offers_New') AND Product_Subdivision__c = :this.divisionName].size();
        Integer insertedChooserControlList = [SELECT Id, CreatedDate FROM Product_Chooser_Control__c WHERE CreatedDate = TODAY AND Application_Name__c in ('Current_Offers_Used','Current_Offers_New') AND Product_Subdivision__c = :this.divisionName].size();      
         if(insertedChooserList > 0 && insertedChooserControlList > 0){ 
            System.debug('Executing org cache batch');
            DELETE [SELECT Id, CreatedDate FROM Product_Chooser_Control__c WHERE CreatedDate != TODAY AND Application_Name__c in ('Current_Offers_Used','Current_Offers_New') AND Product_Subdivision__c = :this.divisionName ];
            DELETE [SELECT Id, CreatedDate FROM Product_Chooser__c  WHERE CreatedDate != TODAY AND Application_Name__c in ('Current_Offers_Used','Current_Offers_New') AND Product_Subdivision__c = :this.divisionName];
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
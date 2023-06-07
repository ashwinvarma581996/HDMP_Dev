/**
 * Created by mbarton on 1/12/23.
 */

public with sharing class B2BCategoryLoadingTool {

    @InvocableVariable
    public Boolean checkActionDone;

    @InvocableMethod
    public static List <String> initiateCategoryLoading(List<List<String>> ids) {

        // Flow passes List<List<String>>, first remove List<String> from List
        List<String> firstList = ids[0];
        // Next remove String from List<String>
        String catalogName = firstList[0];
        String uploadedFileId = firstList[1];
        // Retrieve Content LatestPublishedVersionId and Title Id from ContentDocument Id provided
        ContentDocument contentDocument = [SELECT LatestPublishedVersionId, Title FROM ContentDocument WHERE Id = :uploadedFileId LIMIT 1];
        // Retrieve Blob content from ContentVersion.LatestPublishedVersionId
        Blob fileContent = [SELECT VersionData FROM ContentVersion WHERE Id = :contentDocument.LatestPublishedVersionId LIMIT 1].VersionData;

        List<String> csvContent = processCSV(fileContent);
        csvContent.remove(0); //removing Header row
        Integer numberOfRowsInCSV = csvContent.size();

        if(numberOfRowsInCSV == 0){
            String response = 'The uploaded CSV file was empty, or missing a header row.';
            List<String> responseWrapper= new List<String>();
            responseWrapper.add(response);
            return responseWrapper;
        }

        ProductCatalog catalog = [SELECT Id FROM ProductCatalog WHERE Name =:catalogName LIMIT 1];

        Map<String, Object> retrievedData = retrieveData(catalog.Id);
        Map<String, ProductCategory> makes = (Map<String,ProductCategory>) retrievedData.get('makes');
        Map<String, ProductCategory> models = (Map<String,ProductCategory>) retrievedData.get('models');
        Map<String, ProductCategory> sections = (Map<String,ProductCategory>) retrievedData.get('sections');
        Map<String, ProductCategory> groups = (Map<String,ProductCategory>) retrievedData.get('groups');
        Map<String, MegacategoryMapping__c> megacategoryMappings = retrieveDataMegacategoryMappings();

        Map<String, List<Object>> csvResult = new Map<String, List<Object>>();
        csvResult = processRows(csvContent, makes, models, sections, catalog, groups, megacategoryMappings);

        Map<String, List<Object>> csvResult2 = new Map<String, List<Object>>();
        Map<String, List<Object>> csvResult3 = new Map<String, List<Object>>();
        Map<String, List<Object>> csvResult4 = new Map<String, List<Object>>();

        List<string> skippedRows4 = new List<string> ();

        for(ProductCategory make : (List<ProductCategory>)csvResult.get('categoriesToCreateMakes')){
            makes.put(make.Name, make);
        }
        for(ProductCategory model : (List<ProductCategory>)csvResult.get('categoriesToCreateModels')){
            String modelMapKey = model.Name.toLowerCase() + '_' + model.ParentCategoryId;
            models.put(modelMapKey, model);
        }
        for (ProductCategory section : (List<ProductCategory>)csvResult.get('categoriesToCreateSections')){
            String sectionMapKey = section.Name.toLowerCase() + '_' + section.ParentCategoryId;
            sections.put(sectionMapKey, section);
        }
        for (ProductCategory catGroup : (List<ProductCategory>)csvResult.get('categoriesToCreate')){
            String groupMapKey = catGroup.Name.toLowerCase() + '_' + catGroup.ParentCategoryId;
            groups.put(groupMapKey, catGroup);
        }

        Integer categoriesToCreateMakesCounter = csvResult.get('categoriesToCreateMakes').Size();
        Integer categoriesToCreateCounter = csvResult.get('categoriesToCreate').Size();
        Integer categoriesToCreateModelsCounter = csvResult.get('categoriesToCreateModels').Size();
        Integer categoriesToCreateSectionsCounter = csvResult.get('categoriesToCreateSections').Size();
        Integer megacategoriesToCreateCounter = csvResult.get('megacategoriesToCreate').Size();
        Set<MegacategoryMapping__c> megacategoriesToCreateSet = new Set<MegacategoryMapping__c>();
        megacategoriesToCreateSet.addAll((List<MegacategoryMapping__c>) csvResult.get('megacategoriesToCreate'));

        if(csvResult.get('csvCatch').size() >= 1){

            List<string> skippedRows= new List<string> ();
            for(Object skippedRow:csvResult.get('csvCatch')){
                skippedRows.add((String) skippedRow);
            }

            csvResult2 = processRows(skippedRows, makes, models, sections, catalog, groups, megacategoryMappings);

            for(ProductCategory make : (List<ProductCategory>)csvResult2.get('categoriesToCreateMakes')){
                makes.put(make.Name, make);
            }
            for(ProductCategory model : (List<ProductCategory>)csvResult2.get('categoriesToCreateModels')){
                String modelMapKey = model.Name.toLowerCase() + '_' + model.ParentCategoryId;
                models.put(modelMapKey, model);
            }
            for (ProductCategory section : (List<ProductCategory>)csvResult2.get('categoriesToCreateSections')){
                String sectionMapKey = section.Name.toLowerCase() + '_' + section.ParentCategoryId;
                sections.put(sectionMapKey, section);
            }
            for (ProductCategory catGroup : (List<ProductCategory>)csvResult2.get('categoriesToCreate')){
                String groupMapKey = catGroup.Name.toLowerCase() + '_' + catGroup.ParentCategoryId;
                groups.put(groupMapKey, catGroup);
            }

            categoriesToCreateCounter += csvResult2.get('categoriesToCreate').Size();
            categoriesToCreateModelsCounter += csvResult2.get('categoriesToCreateModels').Size();
            categoriesToCreateSectionsCounter += csvResult2.get('categoriesToCreateSections').Size();
            megacategoriesToCreateCounter += csvResult2.get('megacategoriesToCreate').Size();
            megacategoriesToCreateSet.addAll((List<MegacategoryMapping__c>) csvResult2.get('megacategoriesToCreate'));

            if(csvResult2.get('csvCatch').size() >= 1){

                List<string> skippedRows2= new List<string> ();
                for(Object skippedRow:csvResult2.get('csvCatch')){
                    skippedRows2.add((String) skippedRow);
                }
                csvResult3 = processRows(skippedRows2, makes, models, sections, catalog, groups, megacategoryMappings);

                for(ProductCategory make : (List<ProductCategory>)csvResult3.get('categoriesToCreateMakes')){
                    makes.put(make.Name, make);
                }
                for(ProductCategory model : (List<ProductCategory>)csvResult3.get('categoriesToCreateModels')){
                    String modelMapKey = model.Name.toLowerCase() + '_' + model.ParentCategoryId;
                    models.put(modelMapKey, model);
                }
                for (ProductCategory section : (List<ProductCategory>)csvResult3.get('categoriesToCreateSections')){
                    String sectionMapKey = section.Name.toLowerCase() + '_' + section.ParentCategoryId;
                    sections.put(sectionMapKey, section);
                }
                for (ProductCategory catGroup : (List<ProductCategory>)csvResult3.get('categoriesToCreate')){
                    String groupMapKey = catGroup.Name.toLowerCase() + '_' + catGroup.ParentCategoryId;
                    groups.put(groupMapKey, catGroup);
                }

                categoriesToCreateCounter += csvResult3.get('categoriesToCreate').Size();
                categoriesToCreateModelsCounter += csvResult3.get('categoriesToCreateModels').Size();
                categoriesToCreateSectionsCounter += csvResult3.get('categoriesToCreateSections').Size();
                megacategoriesToCreateCounter += csvResult3.get('megacategoriesToCreate').Size();
                megacategoriesToCreateSet.addAll((List<MegacategoryMapping__c>) csvResult3.get('megacategoriesToCreate'));

                if(csvResult3.get('csvCatch').size() >= 1){

                    List<string> skippedRows3= new List<string> ();
                    for(Object skippedRow:csvResult3.get('csvCatch')){
                        skippedRows3.add((String) skippedRow);
                    }
                    csvResult4 = processRows(skippedRows3, makes, models, sections, catalog, groups, megacategoryMappings);

                    categoriesToCreateCounter += csvResult4.get('categoriesToCreate').Size();
                    categoriesToCreateModelsCounter += csvResult4.get('categoriesToCreateModels').Size();
                    categoriesToCreateSectionsCounter += csvResult4.get('categoriesToCreateSections').Size();
                    megacategoriesToCreateCounter += csvResult4.get('megacategoriesToCreate').Size();
                    megacategoriesToCreateSet.addAll((List<MegacategoryMapping__c>) csvResult4.get('megacategoriesToCreate'));

                    if(csvResult4.get('csvCatch').size() >= 1) {

                        for (Object skippedRow : csvResult4.get('csvCatch')) {
                            skippedRows4.add((String) skippedRow);
                        }
                    }
                }
            }
        }

        if(csvResult.get('csvMegaCatch').size() >= 1){
            List<string> csvMegaCatchResults = new List<string>();
            if (csvResult.get('csvMegaCatch').size() >= 1) {
                for (Object row : csvResult.get('csvMegaCatch')) {
                    csvMegaCatchResults.add((string) row);
                }
            }
            if(csvResult2.get('csvMegaCatch') != null) {
                if (csvResult2.get('csvMegaCatch').size() >= 1) {
                    for (Object row : csvResult2.get('csvMegaCatch')) {
                        csvMegaCatchResults.add((string) row);
                    }
                }
            }
            if(csvResult3.get('csvMegaCatch') != null) {
                if (csvResult3.get('csvMegaCatch').size() >= 1) {
                    for (Object row : csvResult3.get('csvMegaCatch')) {
                        csvMegaCatchResults.add((string) row);
                    }
                }
            }
            if(csvResult4.get('csvMegaCatch') != null){
                if(csvResult4.get('csvMegaCatch').size() >= 1){
                    for(Object row:csvResult4.get('csvMegaCatch')){
                        csvMegaCatchResults.add((string)row);
                    }
                }
            }

            if(skippedRows4.size() >= 1){
                csvMegaCatchResults.addall(skippedRows4);
            }
            sendCsvEmail(csvMegaCatchResults, contentDocument.Title);
        }

        String response = 'Name of CSV : ' + contentDocument.Title + '\n' +
        'Number of rows in CSV : ' + numberOfRowsInCSV + '\n' +
        'Make Categories were created : ' + categoriesToCreateMakesCounter + '\n' +
        'Model Categories were created : ' + categoriesToCreateModelsCounter + '\n' +
        'Section Categories were created : ' + categoriesToCreateSectionsCounter + '\n' +
        'Megacategories were created : ' + categoriesToCreateCounter + '\n' +
        'Megacategory to group mappings created (see report) : ' + megacategoriesToCreateCounter;
        List<String> responseWrapper= new List<String>();
        responseWrapper.add(response);
        return responseWrapper;
    }

    public static void sendCsvEmail(List<string> csvMegaCatch, String fileName){
        String headerRow = 'Level 1 (Make),Level 2 (Model),Level 3 (Section),Level 4 (Group)' + '\n';
        String concantenatedStr = headerRow;
        Integer i = 0;
        Integer rowListSize = csvMegaCatch.size();
        for(Object row :csvMegaCatch){
            concantenatedStr += row;
            i++;
            if(i != rowListSize) concantenatedStr += '\n';
        }

        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(concantenatedStr);
        string csvname= 'Failures_' + fileName + '.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {UserInfo.getUserEmail()};
        String subject ='Unsuccessful B2B Category Load Results';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('The attached CSV file contains remaining categories that were unsuccessfully loaded from file ' + fileName + '.csv');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] emailSendResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

    public static Map<String, List<Object>> processRows(List<String> csvContent, Map<String, ProductCategory> makes, Map<String, ProductCategory> models, Map<String, ProductCategory> sections, ProductCatalog catalog, Map<String, ProductCategory> groups, Map<String, MegacategoryMapping__c>  megacategoryMappings){

        List<String> csvCatch = new List<String>();
        List<String> csvMegaCatch = new List<String>();

        Integer catAlreadyExists = 0;
        Integer prodCatToBeCreated = 0;
        Integer megaCatToBeCreated = 0;
        Integer modelCatToBeCreated = 0;
        Integer sectionCatToBeCreated = 0;
        Integer makeCatToBeCreated = 0;
        List<ProductCategory> categoriesToCreateMakes = new List<ProductCategory>();
        Map<String, ProductCategory> categoriesToCreateMakesMap = new Map<String, ProductCategory>();
        List<ProductCategory> categoriesToCreateModels = new List<ProductCategory>();
        Map<String, ProductCategory> categoriesToCreateModelsMap = new Map<String, ProductCategory>();
        List<ProductCategory> categoriesToCreateSections = new List<ProductCategory>();
        Map<String, ProductCategory> categoriesToCreateSectionsMap = new Map<String, ProductCategory>();
        List<ProductCategory> categoriesToCreate = new List<ProductCategory>();
        List<MegacategoryMapping__c> megacategoriesToCreate = new List<MegacategoryMapping__c>();

        for(String row : csvContent){
            row = row.replace('\r','');
            List<String> rowValues = row.split(',');

            if(rowValues.size() < 2){rowValues.add('');rowValues.add('');rowValues.add('');}
            if(rowValues.size() < 3){rowValues.add('');rowValues.add('');}
            if(rowValues.size() < 4){rowValues.add('');}

            String modelId = '';
            String sectionId = '';

            String makeId = findMakes(rowValues, makes);

            if(makeId != '') {
                if(rowValues[1] != '') {
                    modelId = findModels(rowValues, models, modelId, makeId);
                } else {
                    //make was found, but there is no more data to parse, moving on
                    continue;
                }
            } else {
                //there was no make found
                //create a make ProductCategory
                ProductCategory categoryToCreateMake = new ProductCategory();
                categoryToCreateMake.Name = rowValues[0];
                categoryToCreateMake.CatalogId = catalog.Id;
                categoryToCreateMake.IsNavigational = false;
                categoriesToCreateMakesMap.put(categoryToCreateMake.Name, categoryToCreateMake);
                makeCatToBeCreated++;
                csvCatch.add(row);
                continue;
            }

            if(modelId != '') {
                if(rowValues[2] != '') {
                    sectionId = findSections(rowValues, sections, modelId);
                } else {
                    //make and model were found, but there is no more data to parse, moving on
                    continue;
                }
            } else {
                //there was no model found
                //create a model ProductCategory
                ProductCategory categoryToCreateModel = new ProductCategory();
                categoryToCreateModel.Name = rowValues[1];
                categoryToCreateModel.ParentCategoryId = makeId;
                categoryToCreateModel.CatalogId = catalog.Id;
                categoryToCreateModel.IsNavigational = false;
                categoriesToCreateModelsMap.put(categoryToCreateModel.Name +'_'+categoryToCreateModel.ParentCategoryId, categoryToCreateModel);
                modelCatToBeCreated++;
                csvCatch.add(row);
                continue;
            }

            if(sectionId != '') {
                if(rowValues[3] != '') {
                    findGroups(row, rowValues, groups, megacategoryMappings, sectionId, catAlreadyExists, categoriesToCreate, prodCatToBeCreated, megacategoriesToCreate, megaCatToBeCreated, catalog, csvMegaCatch);
                } else {
                    //make, model, and section were found, but there is no more data to parse, moving on
                    continue;
                }
            } else {
                //there was no section found
                //create a section ProductCategory
                ProductCategory categoriesToCreateSection = new ProductCategory();
                categoriesToCreateSection.Name = rowValues[2];
                categoriesToCreateSection.ParentCategoryId = modelId;
                categoriesToCreateSection.CatalogId = catalog.Id;
                categoriesToCreateSection.IsNavigational = false;
                categoriesToCreateSectionsMap.put(categoriesToCreateSection.Name +'_'+categoriesToCreateSection.ParentCategoryId, categoriesToCreateSection);
                sectionCatToBeCreated++;
                csvCatch.add(row);
                continue;
            }
        }


        try {
            categoriesToCreateMakes = categoriesToCreateMakesMap.values();
            categoriesToCreateModels = categoriesToCreateModelsMap.values();
            categoriesToCreateSections = categoriesToCreateSectionsMap.values();

            Database.SaveResult[] srMakes = Database.insert(categoriesToCreateMakes, false);
            Database.SaveResult[] srModels = Database.insert(categoriesToCreateModels, false);
            Database.SaveResult[] srSections = Database.insert(categoriesToCreateSections, false);
            Database.SaveResult[] srCreate = Database.insert(categoriesToCreate, false);
            Database.SaveResult[] srList = Database.insert(megacategoriesToCreate, false);
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

        Map<String, List<Object>> responseMap = new Map<String, List<Object>>();
        responseMap.put('categoriesToCreateMakes', categoriesToCreateMakes);
        responseMap.put('categoriesToCreateModels', categoriesToCreateModels);
        responseMap.put('categoriesToCreateSections', categoriesToCreateSections);
        responseMap.put('categoriesToCreate', categoriesToCreate);
        responseMap.put('megacategoriesToCreate', megacategoriesToCreate);
        responseMap.put('csvCatch', csvCatch);
        responseMap.put('csvMegaCatch', csvMegaCatch);
        return responseMap;
    }

    public static String[] processCSV(Blob fileContent){
        String tempString = fileContent.toString();
        tempString = tempString.replaceAll('"', '');
        List<String> stringArray = tempString.split('\n');
        return stringArray;
    }

    public static String findMakes(List<String> rowValues, Map<String, ProductCategory> makes){
        String makeId = '';
        if(makes.get(rowValues[0]) != null){
            makeId = makes.get(rowValues[0]).Id;
        }
        return makeId;
    }

    public static String findModels(List<String> rowValues, Map<String, ProductCategory> models, String modelId, String makeId){
        String modelKey = rowValues[1].toLowerCase() + '_' + makeId;
        if(models.get(modelKey) != null){
            modelId = models.get(modelKey).Id;
        }
        return modelId;
    }

    public static String findSections(List<String> rowValues, Map<String, ProductCategory> sections, String modelId){
        String sectionId = '';
        String sectionKey = rowValues[2].toLowerCase() + '_' + modelId;
        if(sections.get(sectionKey) != null){
            sectionId = sections.get(sectionKey).Id;
        }
        return sectionId;
    }

    public static void findGroups(String row, List<String> rowValues,  Map<String, ProductCategory> groups, Map<String, MegacategoryMapping__c> megacategoryMappings, String sectionId, Integer catAlreadyExists, List<ProductCategory> categoriesToCreate, Integer prodCatToBeCreated, List<MegacategoryMapping__c> megacategoriesToCreate, Integer megaCatToBeCreated, ProductCatalog catalog, List<String> csvMegaCatch){
        String megacategoryId = '';
        String theGroup = rowValues[3].toLowerCase();
        String theGroupKey = rowValues[3].toLowerCase() + '_' + rowValues[2].toLowerCase();

        if(megacategoryMappings.get(theGroupKey) != null){
            if(megacategoryMappings.get(theGroupKey).MegacategoryName__c != null){
                MegacategoryMapping__c megacategory = megacategoryMappings.get(theGroupKey);
                megacategoryId = megacategory.Id;
                String categoryToFind = megacategory.MegacategoryName__c.toLowerCase() + '_' + sectionId;
                if(groups.get(categoryToFind) !=null){
                    catAlreadyExists++;
                } else {
                    //there was no category with that name and parent category found
                    ProductCategory categoryToCreate = new ProductCategory();
                    categoryToCreate.Name = megacategory.MegacategoryName__c;
                    categoryToCreate.ParentCategoryId = sectionId;
                    categoryToCreate.CatalogId = catalog.Id;
                    categoryToCreate.IsNavigational = false;
                    categoriesToCreate.add(categoryToCreate);
                    prodCatToBeCreated++;
                }
            } else {
                //found a megacategory with no MegacategoryName__c
            }
        } else {
            //there was no megacategory found
            if(theGroup != ''){
                MegacategoryMapping__c megaCategoryToCreate = new MegacategoryMapping__c();
                megaCategoryToCreate.SectionName__c = rowValues[2];
                megaCategoryToCreate.GroupName__c = rowValues[3];
                megacategoriesToCreate.add(megaCategoryToCreate);
                csvMegaCatch.add(row);
                megaCatToBeCreated++;
            }
        }
    }

    public static Map<String,Object> retrieveData(String catalogId){
        Map<String, Object> mapObject = new Map<String, Object>();
        mapObject = retrieveDataMakes(mapObject, catalogId);
        mapObject = retrieveDataModels(mapObject);
        mapObject = retrieveDataSections(mapObject);
        mapObject = retrieveDataGroups(mapObject);
        return mapObject;
    }

    public static Map<String, Object> retrieveDataMakes(Map<String,Object> mapObject, String catalogId) {
        Map<String, ProductCategory> makes = new Map<String, ProductCategory>();
        Set<Id> makeCategoryIds = new Set<Id>();
        for (ProductCategory make : [SELECT Id, Name FROM ProductCategory WHERE ParentCategoryId = null AND CatalogId = :catalogId]) {
            makes.put(make.Name, make);
            makeCategoryIds.add(make.Id);
        }
        mapObject.put('makes', makes);
        mapObject.put('makeCategoryIds', makeCategoryIds);
        return mapObject;
    }

    public static Map<String, Object> retrieveDataModels(Map<String,Object> mapObject) {
        Set<Id> makeCategoryIds = (Set<Id>) mapObject.get('makeCategoryIds');
        Map<String, ProductCategory> models = new Map<String, ProductCategory>();
        Set<Id> modelCategoryIds = new Set<Id>();
        for (ProductCategory model : [SELECT Id, Name, ParentCategoryId FROM ProductCategory WHERE ParentCategoryId IN :makeCategoryIds]) {
            String modelMapKey = model.Name.toLowerCase() + '_' + model.ParentCategoryId;
            models.put(modelMapKey, model);
            modelCategoryIds.add(model.Id);
        }
        mapObject.put('models', models);
        mapObject.put('modelCategoryIds', modelCategoryIds);
        return mapObject;
    }

    public static Map<String, Object> retrieveDataSections(Map<String, Object> mapObject) {
        Set<Id> modelCategoryIds = (Set<Id>) mapObject.get('modelCategoryIds');
        Map<String, ProductCategory> sections = new Map<String, ProductCategory>();
        Set<Id> sectionCategoryIds = new Set<Id>();
        for (ProductCategory section : [SELECT Id, Name, ParentCategoryId FROM ProductCategory WHERE ParentCategoryId IN :modelCategoryIds]) {
            String sectionMapKey = section.Name.toLowerCase() + '_' + section.ParentCategoryId;
            sections.put(sectionMapKey, section);
            sectionCategoryIds.add(section.Id);
        }
        mapObject.put('sections', sections);
        mapObject.put('sectionCategoryIds', sectionCategoryIds);
        return mapObject;
    }

    public static Map<String, Object> retrieveDataGroups(Map<String, Object> mapObject) {
        Set<Id> sectionCategoryIds = (Set<Id>) mapObject.get('sectionCategoryIds');
        Map<String, ProductCategory> groups = new Map<String, ProductCategory>();
        Set<Id> groupCategoryIds = new Set<Id>();
        for (ProductCategory catGroup : [SELECT Id, Name, ParentCategoryId FROM ProductCategory WHERE ParentCategoryId IN :sectionCategoryIds]) {
            String groupMapKey = catGroup.Name.toLowerCase() + '_' + catGroup.ParentCategoryId;
            groups.put(groupMapKey, catGroup);
            groupCategoryIds.add(catGroup.Id);
        }
        mapObject.put('groups', groups);
        mapObject.put('groupCategoryIds', groupCategoryIds);
        return mapObject;
    }

    public static Map<String, MegacategoryMapping__c> retrieveDataMegacategoryMappings(){
        Map<String, MegacategoryMapping__c> megacategoryMappings = new Map<String, MegacategoryMapping__c>();
        for (MegacategoryMapping__c megacategoryMapping : [SELECT Id, Name, SectionName__c, MegacategoryName__c, GroupName__c FROM MegacategoryMapping__c WHERE MegacategoryName__c != null AND SectionName__c != null AND GroupName__c != null]) {
            String megacategoryMappingsMapKey = megacategoryMapping.GroupName__c.toLowerCase() + '_' + megacategoryMapping.SectionName__c.toLowerCase();
            megacategoryMappings.put(megacategoryMappingsMapKey, megacategoryMapping);
        }
        return megacategoryMappings;
    }
    public class B2BCategoryLoadingToolException extends Exception{}
}
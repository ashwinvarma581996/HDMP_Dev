//****************************************************************************** 
// File Name:       FindProductController.cls
// Summary:         Apex Class for populating lists for ownFindProductsAuto
// Created On:      10-05-2021
// Created By:      Brett S (Wipro)
// Test Classes:    FindProductControllerTest.cls
// Data I/O:        
// Honda Jira Story: Create APEX "FindProductController"
//===============================================================================

public without sharing class FindProductController {

    private static Map<String, String> brandNamesMap = new Map<String, String>{'Honda' => 'Honda', 'Acura' => 'Acura', 'Powersports' => 'Motorcycle/Powersports'};


    @AuraEnabled (cacheable = false)
    public static List<Product_Chooser_Control__c> getProductChooserControl(String division){
        System.debug('division: ' + division);
        //System.debug('brand name: ' + brandNamesMap.get(division));
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.MyGarage');
        Map<String, List <Product_Chooser_Control__c>> productChooserControl = new Map<String, List <Product_Chooser_Control__c>>();


        if (Cache.Org.get('local.MyGarage.ProductChooserControl') == null || ((Map<String, List <Product_Chooser_Control__c>>)Cache.Org.get('local.MyGarage.ProductChooserControl')).get(division) == null){
            System.debug('Retrieving via SOQL');
            if (Cache.Org.get('local.MyGarage.ProductChooserControl') != null){
                productChooserControl = (Map<String, List <Product_Chooser_Control__c>>)Cache.Org.get('local.MyGarage.ProductChooserControl');        
            }

            List<Product_Chooser_Control__c> pccList = [SELECT Application_Name__c, Product_Chooser_Control_Alternate_Identi__c, Name,
                                                                Product_Subdivision__c, Tier_Name__c, Tier_Number__c FROM Product_Chooser_Control__c
                                                                WHERE Application_Name__c = 'My_Garage' AND Product_Subdivision__c=:division];
            System.debug(pccList);
            //System.debug(productChooserControl.containsKey(pccList[0].Product_Subdivision__c));
            for(Product_Chooser_Control__c pcc: pccList){
                if(productChooserControl.containsKey(pcc.Product_Subdivision__c)){
                    productChooserControl.get(pcc.Product_Subdivision__c).add(pcc);
                }else{
                    List <Product_Chooser_Control__c> newList = new List <Product_Chooser_Control__c>();
                    newList.add(pcc);
                    productChooserControl.put(pcc.Product_Subdivision__c, newList);
                }            
            }
            
            // Save data to org cache
            orgPart.put('ProductChooserControl', productChooserControl);
            System.debug(Cache.Org.get('local.MyGarage.ProductChooserControl'));
        }
        else{
            System.debug('Retrieving from cache');
            productChooserControl = (Map<String, List <Product_Chooser_Control__c>>)Cache.Org.get('local.MyGarage.ProductChooserControl');
        }

        System.debug('keyset' + productChooserControl.keySet());
        System.debug(productChooserControl.get(division));

        Set<String> tierNamesInUseSet = new Set<String>();

        List<Product_Chooser_Control__c> returnList = new List<Product_Chooser_Control__c>();
        if(productChooserControl.ContainsKey(division)){
            for (Product_Chooser_Control__c pcc : productChooserControl.get(division)){
                if (!tierNamesInUseSet.contains(pcc.Tier_Name__c)){
                    pcc.Tier_Name__c = division == 'Honda' && pcc.Tier_Name__c == 'ModelGroup' ? 'Model' : pcc.Tier_Name__c;
                    returnList.add(pcc);
                    tierNamesInUseSet.add(pcc.Tier_Name__c);
                }
            }
        }
		System.debug(returnList);

        return returnList;
    }

    @AuraEnabled (cacheable = false)
    public static List<Product_Chooser__c> getProductChooserData(String division){
        System.debug('ProductChooserControl' + Cache.Org.get('local.MyGarage.ProductChooserControl'));
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.MyGarage');
        /* Map<String, List <Product_Chooser__c>> productChooserData = new Map<String, List <Product_Chooser__c>> ();

        System.debug('keyset' + productChooserData.keySet());
        System.debug(productChooserData.get(division)); */

        Cache.OrgPartition myGaragePart = Cache.Org.getPartition('local.MyGarage');

        String cacheKey = Batch_productChooserOrgCache.getCacheKey(division); // Use the same cache naming scheme that is used by the Product Chooser batch class
        Boolean cacheContainsCurrentDivision = myGaragePart.contains(cacheKey);
        List<Product_Chooser__c> productChooserData = new List<Product_Chooser__c>();

        // If the partition already contains data for the current division, use that data. Otherwise (for instance, in the event a deployment has cleared the cache since the last run of the batch class), retrieve Product Chooser data via SOQL and attempt to store it in the cache
        if (myGaragePart.contains(cacheKey)){
            productChooserData = (List<Product_Chooser__c>) myGaragePart.get(cacheKey);
            System.debug('Retrieving from cache');
        }
        else{
            productChooserData = [SELECT Alternate_Product_Chooser_Identifier__c, Application_Name__c, Name, Product_Model__c, Product_Model__r.Product_Model_Id__c, Product_Subdivision__c,
                                                        Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c FROM Product_Chooser__c WHERE Product_Subdivision__c=:division];
            System.debug('Retrieving via SOQL');

            try{
                orgPart.put(cacheKey, productChooserData);
            }
            catch (Exception e){
                System.debug('Exception on storing date to cache: ' + e);
            }

        }

        //List<Product_Chooser__c> productChooserReturnList = new List<Product_Chooser__c>();

        if (division == 'Powersports' || division == 'Motorcycle/Powersports'){
            // Powersports model Ids that have an 'L' as the second-to-last character correspond to California Emissions models, and should only be displayed in the
            // dropdowns if they are the only modelId for that model
            productChooserData = removeCaliforniaEmissionsModelsForProductChooserPowersports(productChooserData);
        }

        //System.debug(productChooserData);
        /* System.debug('DIVISION: ' + division);
        if (division == 'Powersports' || division == 'Motorcycle/Powersports'){
            for (Product_Chooser__c pc : productChooserReturnList){
                String s = pc.Product_Model__r.Product_Model_Id__c;
                if (s.substring(s.length()-2, s.length()-1) == 'L'){
                    System.debug(s);
                }
            }
        } */

        return productChooserData;



        /* if (Cache.Org.get('local.MyGarage.ProductChooser') == null || ((Map<String, List <Product_Chooser__c>>)Cache.Org.get('local.MyGarage.ProductChooser')).get(division) == null){
            System.debug('Retrieving via SOQL');
            if (Cache.Org.get('local.MyGarage.ProductChooser') != null){
                productChooserData = (Map<String, List <Product_Chooser__c>>)Cache.Org.get('local.MyGarage.ProductChooser');
            }

            // If data is not in cache, retrieve data from Salesforce and store in cache for future use

            List<Product_Chooser__c> pcList  = [SELECT Alternate_Product_Chooser_Identifier__c, Application_Name__c, Name, Product_Model__c, Product_Model__r.Product_Model_Id__c, Product_Subdivision__c,
                                                        Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c FROM Product_Chooser__c WHERE Product_Subdivision__c=:division];
            // use SOQL results
            for(Product_Chooser__c pc: pcList){
                if(productChooserData.containsKey(pc.Product_Subdivision__c)){
                    productChooserData.get(pc.Product_Subdivision__c).add(pc);
                }else{
                    List <Product_Chooser__c> newList = new List <Product_Chooser__c>();
                    newList.add(pc);
                    productChooserData.put(pc.Product_Subdivision__c, newList);
                }
            }
            
            // Save data to org cache
            try{
                orgPart.put('ProductChooser', productChooserData);
            }
            catch (Exception e){
                System.debug('Exception on storing date to cache: ' + e);
            }
            System.debug(Cache.Org.get('local.MyGarage.ProductChooser'));
        }
        else{
            System.debug('Retrieving from cache');
            productChooserData = (Map<String, List <Product_Chooser__c>>)Cache.Org.get('local.MyGarage.ProductChooser');
        } */

        /* for (String key : productChooserData.keyset()){
            for (Product_Chooser__c pc : productChooserData.get(key)){
                System.debug('Data: ' + pc);
            }
        } */

        /* List<Product_Chooser__c> productChooserReturnList = new List<Product_Chooser__c>();

        if (division == 'Powersports' || division == 'Motorcycle/Powersports'){
            // Powersports model Ids that have an 'L' as the second-to-last character correspond to California Emissions models, and should only be displayed in the
            // dropdowns if they are the only modelId for that model
            productChooserReturnList = removeCaliforniaEmissionsModelsForProductChooserPowersports(productChooserData.get(division));
        }
        else{
            productChooserReturnList = productChooserData.get(division);
        }

        //System.debug(productChooserData);
        System.debug('DIVISION: ' + division);
        if (division == 'Powersports' || division == 'Motorcycle/Powersports'){
            for (Product_Chooser__c pc : productChooserReturnList){
                String s = pc.Product_Model__r.Product_Model_Id__c;
                if (s.substring(s.length()-2, s.length()-1) == 'L'){
                    System.debug(s);
                }
            }
        }

        return productChooserReturnList; */
    }

    private class ProductChooserWrapper{
        List<Product_Chooser_Control__c> productChooserControl;
        List<Product_Chooser__c> productChooserData;

        public productChooserWrapper(List<Product_Chooser_Control__c> productChooserControl, List<Product_Chooser__c> productChooserData){
            this.productChooserControl = productChooserControl;
            this.productChooserData = productChooserData;
        }
    }

    @testVisible
    private static List<Product_Chooser__c> removeCaliforniaEmissionsModelsForProductChooserPowersports(List<Product_Chooser__c> productChooserReturnList){
        // Find all modelIds that have 'L' as the second-to-last character, and remove them from the list of ProductChooser objects if there is a non-California Emissions
        // version of that model (identified as a modelId that does not have the 'L'). Return the resulting list.
        
        System.debug('Running California Emissions code');

        Map<String, Product_Chooser__c> modelIdMap = new Map<String, Product_Chooser__c>();
        //System.debug('Beginning modelId log: ' + productChooserReturnList.size() + ' entries found.');
        for (Product_Chooser__c pc : productChooserReturnList){
            System.debug(pc.Product_Model__r.Product_Model_Id__c);
            modelIdMap.put(pc.Product_Model__r.Product_Model_Id__c, pc);
        }
        System.debug('End modelId log.');
        Set<String> calModelIdSet = new Set<String>(); // California Emissions model IDs
        Set<String> modelIdRemoveSet = new Set<String>();
        for (String modelId : modelIdMap.keySet()){
            if (modelId.substring(modelId.length()-2, modelId.length()-1).equalsIgnoreCase('L')){
                System.debug('calModelId found : ' + modelId);
                calModelIdSet.add(modelId);
            }
        }
        System.debug('calModelIdSet: ' + calModelIdSet);
        for (String calModelId : calModelIdSet){
            Integer calLength = calModelId.length();
            Boolean isOnlyModel = true;
            for (String modelId : modelIdMap.keySet()){
                if (calModelId.replace(calModelId.substring(0, calLength-1), calModelId.substring(0, calLength-2)) == modelId){
                    isOnlyModel = false;
                }
            }
            System.debug(calModelId + ' isOnlyModel: ' + isOnlyModel);
            if (!isOnlyModel){
                modelIdMap.remove(calModelId);
            }
        }

        return modelIdMap.values();
    }

    public static String getProductModelId(String modelId){
        return [SELECT Id FROM Vehicle__c WHERE Model_Id__c = :modelId LIMIT 1]?.Id;
    }
 
    // divisionId
    /*
        Honda = 'A'
        Acura = 'B'
    */

    @AuraEnabled (cacheable = true)
    public static List <SelectOptionWrapper> getYears(String divisionId) {
            return getYears(divisionId, '');
    }

    @AuraEnabled (cacheable = true)
    public static List <SelectOptionWrapper> getYears(String divisionId, String modelName){
        Map<Double, Double> yearMap = new Map<Double, Double>();
        List < SelectOptionWrapper > years = new List < SelectOptionWrapper > ();
        String modelFilter = string.isNotBlank(modelName) ? 'AND Model__c = :modelName' : '';
        String query = 'SELECT Id, Year__c FROM Vehicle__c WHERE eConfigDivisionID__c = :divisionId';
        query += ' ' + modelFilter;
        query += ' WITH SECURITY_ENFORCED ORDER BY Year__c DESC LIMIT 10000';

        system.debug('query:' + String.escapeSingleQuotes(query));
        List<Vehicle__c> vehicles = Database.query(String.escapeSingleQuotes(query)); 
        
        for (Vehicle__c vehicle : vehicles) {
            if(!yearMap.containsKey(vehicle.Year__c)){
                years.add(new SelectOptionWrapper(String.valueOf(vehicle.Year__c), String.valueOf(vehicle.Year__c)));
                yearMap.put(vehicle.Year__c, vehicle.Year__c);
            }
        }
        return years;
    }

    @AuraEnabled (cacheable = true)
    public static List<SelectOptionWrapper> getModels(String divisionId, Double year){
        List < SelectOptionWrapper > models = new List < SelectOptionWrapper > ();
        Map<String, String> modelMap = new Map<String, String>();
        for (Vehicle__c vehicle : [
            SELECT Id, Model_Id__c, Model__c
            FROM Vehicle__c
            WHERE
                eConfigDivisionID__c = :divisionId
                AND Year__c = :year
            WITH SECURITY_ENFORCED
            ORDER BY Model__c ASC
            LIMIT 10000
        ]) {
            if(modelMap.get(vehicle.Model__c) == null){
                modelMap.put(vehicle.Model__c, vehicle.Model__c);
                models.add(new SelectOptionWrapper(vehicle.Model__c, vehicle.Model__c));
            }
        }
        return models;
    }

    @AuraEnabled (cacheable = true)
    public static List<SelectOptionWrapper> getTrims(String divisionId, string year, String modelName){
        return getTrims(divisionId, Double.valueOf(year), modelName);
    }

    @AuraEnabled (cacheable = true)
    public static List<SelectOptionWrapper> getTrims(String divisionId, Double year, String modelName){
        List < SelectOptionWrapper > trims = new List < SelectOptionWrapper > ();
        Map<String, String> trimMap = new Map<String, String>();
        for (Vehicle__c vehicle : [
            SELECT Id, Model_Id__c, Trim__c
            FROM Vehicle__c
            WHERE
                eConfigDivisionID__c = :divisionId
                AND Year__c = :year 
                AND Model__c = :modelName
            WITH SECURITY_ENFORCED
            ORDER BY Trim__c DESC
            LIMIT 10000
        ]) {
            if(trimMap.get(vehicle.Model_Id__c) == null){
                trimMap.put(vehicle.Model_Id__c, vehicle.Trim__c);
                trims.add(new SelectOptionWrapper(vehicle.Model_Id__c, vehicle.Trim__c));
            }
        }
        return trims;
    }

    public class SelectOptionWrapper {
        @AuraEnabled public string value;
        @AuraEnabled public string label;

        public SelectOptionWrapper(string value, string label) {
            this.value = value;
            this.label = label;
        }
    }

    //Sends a pre-cursory call to the Honda API to validate if a string passed as a VIN is valid by calling the Honda API
    /*
    private static Boolean getValidVIN(String divisionId, String vin)
    {
        Boolean isVIN = false;
        String vinCall = '';
        List <Honda_Product__c> vinHP = new List <Honda_Product__c>();

        vinHP = [ SELECT Id FROM Honda_Product__c WHERE VIN__c = :vin LIMIT 1 ];

        if(vinHP.size() > 0)
        {
            isVIN = true;
            return isVIN;
        }
        
        if(isVIN == false)
        {
            vinCall = OwnEConfigApiHelper.getModelByVin(vin, divisionId);
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(vinCall);          
            if(!((Boolean)m.get('isError'))) isVIN = true;
        }

        return isVIN;
    }
    */
}
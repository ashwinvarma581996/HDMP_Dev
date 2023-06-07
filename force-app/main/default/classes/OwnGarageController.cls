//****************************************************************************** 
// File Name:       OwnGarageController.cls
// Summary:         Apex Class for Garage
// Created On:      06-25-2021
// Created By:      Arunprasad N (Wipro)
// Test Classes:    OwnGarageControllerTest.cls
// Data I/O:        
// Honda Jira Story: Apex class for Garage for Honda Owner Experience
//===============================================================================
// Modification Log: 
// June 25, 2021 Arunprasad N (Wipro) initial coding
// June 28, 2021 Jodi Allen (Wipro) Renamed Ownership__c.Account__c to Ownership__c.Product_Owner__c
// Jul 1, 2021 Jim kohs (Wipro) refactoring
// Jul 7, 2021 Jim kohs (Wipro) added pseudo-code comments to delete_ProductRecord() for Arun
// December 4, 2021 Ravindra Ravindra  changed Community_Context__c to User (DOE-2477, DOE-2476, DOE-2466)
// December 16, 2021 Alex Dzhitenov Changed references to several Honda Product fields to references to 
//                                   Product Model and Product Model Color fields; commented out insert
//                                   and update methods that are no longer in use (DOE-3220)
//*******************************************************************************
public without sharing class OwnGarageController {

    private final static String HONDA_DIVISION_CODE = 'A';
    private final static String ACURA_DIVISION_CODE = 'B';
    //Set the actual code once we load the data into vehicle object
    private final static String POWERSPORTS_DIVISION_CODE = 'M';
    private final static String POWEREQUIPMENT_DIVISION_CODE = 'PE';
    private final static String MARINE_DIVISION_CODE = 'P';
    private final static String HONDA_DIVISION_NAME = 'Honda';
    private final static String ACURA_DIVISION_NAME = 'Acura';
    private final static String POWERSPORTS_DIVISION_NAME = 'Motorcycle/Powersports';
    private final static String POWEREQUIPMENT_DIVISION_NAME = 'Powerequipment';
    private final static String MARINE_DIVISION_NAME = 'Marine';
    private final static Map<String, Division> DIVISION_MAP = new Map<String, Division>{
        HONDA_DIVISION_CODE => new Division(HONDA_DIVISION_CODE, HONDA_DIVISION_NAME),
        ACURA_DIVISION_CODE => new Division(ACURA_DIVISION_CODE, ACURA_DIVISION_NAME),
        POWERSPORTS_DIVISION_CODE => new Division(POWERSPORTS_DIVISION_CODE, POWERSPORTS_DIVISION_NAME),
        POWEREQUIPMENT_DIVISION_CODE => new Division(POWEREQUIPMENT_DIVISION_CODE, POWEREQUIPMENT_DIVISION_NAME),
        MARINE_DIVISION_CODE => new Division(MARINE_DIVISION_CODE, MARINE_DIVISION_NAME)
        };

    private static String personAccountId(){
        return [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]?.AccountId;
    }

    private static String getProductModelId(String modelId){
        return [SELECT Id FROM Vehicle__c WHERE Model_Id__c = :modelId LIMIT 1]?.Id;
    }

    @AuraEnabled (cacheable = true)
    public static List<Vehicle__c> getProductByYearModel(String divisionId, String modelId){
        
        return [SELECT Id, eConfigDivisionID__c, Year__c, Model__c, Trim__c, Model_Id__c 
                FROM Vehicle__c WHERE eConfigDivisionID__c =:divisionId AND Model_Id__c = :modelId LIMIT 1];
    }

    @AuraEnabled (cacheable = false)
    public static /* List<Product_Model__c> */ Product_Model__c getProductByProductChooser(/* List<Product_Chooser__c> */String productChooserStr){
        System.debug(productChooserStr);

        List<Product_Chooser__c> pcs = (List<Product_Chooser__c>) JSON.deserialize(productChooserStr, List<Product_Chooser__c>.class);
        /* for (Product_Chooser__c pc : productChooser){
            System.debug(pc);
        } */
        Product_Model__c pm = [SELECT Id, Model_Name__c, Model_Year__c, Trim__c, Product_Model_Id__c, (SELECT Exterior_Color_Name__c, Manufacturer_Color_Code__c, Thumbnail_Image_URL__c FROM Product_Model_Colors__r LIMIT 1) FROM Product_Model__c WHERE Id=:pcs[0].Product_Model__c];
        System.debug(pcs);
        return pm;
    }

    @AuraEnabled 
    public static String getProductByVIN(String divisionId, String vin){
        return getProductByVIN(divisionId, vin, '');
    }

    @AuraEnabled 
    public static String getProductByVIN(String divisionId, String vin, String divisionName){
        if (divisionName.containsIgnoreCase('Marine')){
            divisionName = 'Marine';
        }
        else if (divisionName.containsIgnoreCase('Power Equipment') || divisionName.containsIgnoreCase('Powerequipment')){
            divisionName = 'Power Equipment';
        }
        /*Honda_Product__c Hp = new Honda_Product__c();
        hp = [SELECT Model_Id__c, Product_Identifier__c FROM Honda_Product__c WHERE Product_Identifier__c = :vin];
        String mdlId = hp.Model_Id__c;

        return [SELECT Id FROM Vehicle__c WHERE Model_Id__c = :mdlId LIMIT 1]?.Id;*/
        //return '';
        return OwnEConfigApiHelper.getModelByVin(vin, divisionId, divisionName);
    }
    
    // Commented for DOE-2466
    // public static Community_Context__c getCommunityContext(){
    //     List<Community_Context__c> listOfContext = 
    //         [Select Id, 
    //                 VIN__c,
    //                 Make__c, 
    //                 Model__c, 
    //                 Color__c,
    //                 Year__c,
    //                 Owner_Product__c,
    //                 Level1__c, 
    //                 Level2__c, 
    //                 Level3__c, 
    //                 Level4__c,
    //                 UserId__r.FirstName 
    //         FROM    Community_Context__c  
    //         WHERE   UserId__c = :UserInfo.getUserId()];
    //     if (!listOfContext.isEmpty()) {
    //         return listOfContext[0];
    //     }
    //     else{
    //         return new Community_Context__c();
    //     }
    // }

    // ====================
    // = public
    // Added By:  Ravindra Ravindra (DOE-2466)
    // Date : 4th Dec 2021
    // ====================
    public static User getContextUser(){
        return  [SELECT Id, FirstName, 
                 Last_Visited_Product_ID__c, 
                 Last_Visited_Product_Tab__c FROM User
                 WHERE   Id = :UserInfo.getUserId() Limit 1];
    }

    // ====================
    // = public
    // Added By:  Ravindra Ravindra (DOE-2466)
    // Date : 4th Dec 2021
    // ====================
    public static void updateContextUser(String productId, String productTab){
        User contextUser = getContextUser();
        contextUser.Last_Visited_Product_Tab__c = productTab;
        contextUser.Last_Visited_Product_ID__c = productId;
        update contextUser;
    }

@AuraEnabled (cacheable = true) public static List<String> getGarageTabs() {return new List<String>{'Overview', 'Connected Features', 'Service & Parts', 'Recalls & Warranties', 'Resources & Downloads'};} //DOE-4256  (Code commented for Release 1 - Details: Hiding 'Service & Parts', 'Recalls & Warranties', 'Resources & Downloads' tabs )
@AuraEnabled (cacheable = true) public static List<String> getGarageTabsAcura() {return new List<String>{'Overview',  'Connected Features','Service & Maintenance', 'Marketplace', 'Finance', 'Resources & Downloads'};} //DOE-4256  (Code commented for Release 1 - Details: Hiding 'Service & Maintenance', 'Marketplace', 'Finance', 'Resources & Downloads' tabs )
@AuraEnabled (cacheable = true) public static List<String> getGarageTabsHonda() {return new List<String>{'Overview', 'Connected Features', 'Service & Parts', 'Recalls & Warranties', 'Resources & Downloads'};} //DOE-4256  (Code commented for Release 1 - Details: Hiding 'Service & Parts', 'Recalls & Warranties', 'Resources & Downloads' tabs )
    @AuraEnabled (cacheable = true) public static List<String> getGarageTabsPowersports() {return new List<String>{'Overview', 'Service & Parts', 'Recalls & Warranties', 'Resources & Downloads'};}
    @AuraEnabled (cacheable = true) public static List<String> getGarageTabsPowerEquipment() {return new List<String>{'Overview', 'Service & Parts', 'Recalls & Warranties', 'Resources & Downloads'};} 
    @AuraEnabled (cacheable = true) public static List<String> getGarageTabsMarine() {return new List<String>{'Overview', 'Service & Parts', 'Recalls & Warranties', 'Resources & Downloads'};} 

    @AuraEnabled (cacheable = true) public static Division getDivisionHonda() {return DIVISION_MAP.get(HONDA_DIVISION_CODE);} 
    @AuraEnabled (cacheable = true) public static Division getDivisionAcura() {return DIVISION_MAP.get(ACURA_DIVISION_CODE);} 
    @AuraEnabled (cacheable = true) public static Division getDivisionPowersports() {return DIVISION_MAP.get(POWERSPORTS_DIVISION_CODE);} 
    @AuraEnabled (cacheable = true) public static Division getDivisionPowerEquipment() {return DIVISION_MAP.get(POWEREQUIPMENT_DIVISION_CODE);} 
    @AuraEnabled (cacheable = true) public static Division getDivisionMarine() {return DIVISION_MAP.get(MARINE_DIVISION_CODE);} 

    @AuraEnabled (cacheable = true) public static List <SelectOptionWrapper> getYearsHonda() {return getYears(HONDA_DIVISION_CODE);} 
    @AuraEnabled (cacheable = true) public static List <SelectOptionWrapper> getYearsAcura() {return getYears(ACURA_DIVISION_CODE);}
    
    @AuraEnabled (cacheable = true) public static List <SelectOptionWrapper> getTypesPowersports() {return new List<SelectOptionWrapper>{new SelectOptionWrapper('2022', 'Street'), new SelectOptionWrapper('2021', 'Off-Road'), new SelectOptionWrapper('2020', 'ATV'), new SelectOptionWrapper('2019', 'SXS')};}
    
    @AuraEnabled (cacheable = true) public static List <SelectOptionWrapper> getProductsPowerequipment() {return new List<SelectOptionWrapper>{new SelectOptionWrapper('Generator', 'Generator'), new SelectOptionWrapper('Lawn Mower', 'Lawn Mower'), new SelectOptionWrapper('Pumps', 'Pumps'), new SelectOptionWrapper('Snow Blowers', 'Snow Blower'), new SelectOptionWrapper('Tillers', 'Tillers'), new SelectOptionWrapper('Trimmers', 'Trimmers')};}
    @AuraEnabled (cacheable = true) public static List <SelectOptionWrapper> getTypesPowerequipment(String product) {
        List <SelectOptionWrapper > types = new List <SelectOptionWrapper>();
        if(product == 'Generator'){
            types.add(new SelectOptionWrapper('2022', 'Super Quiet'));
        }
        if(product == 'Lawn Mower'){
            types.add(new SelectOptionWrapper('2021', 'HRX Premium Residential'));
        }
        if(product == 'Pumps'){
            types.add(new SelectOptionWrapper('2020', 'De-Watering'));
        }
        if(product == 'Snow Blowers'){
            types.add(new SelectOptionWrapper('2019', 'Wheel Drive'));
        }
        if(product == 'Tillers'){
            types.add(new SelectOptionWrapper('2018', 'Mid tine'));
        }
        if(product == 'Trimmers'){
            types.add(new SelectOptionWrapper('2017', 'Trimmer'));
        }
        return types;
    }
    @AuraEnabled (cacheable = true) public static List <SelectOptionWrapper> getOutboardsMarine() {return new List<SelectOptionWrapper>{new SelectOptionWrapper('2022', 'Portable'), new SelectOptionWrapper('2021', 'Mid-Range'), new SelectOptionWrapper('2020', 'High Power'), new SelectOptionWrapper('2019', 'Jet Drive')};}

    private static List <SelectOptionWrapper> getYears(String divisionId){
        Map<Double, Double> yearMap = new Map<Double, Double>();
        List < SelectOptionWrapper > years = new List < SelectOptionWrapper > ();
        for (Vehicle__c vehicle : [
            SELECT Id, Year__c 
            FROM Vehicle__c
            WHERE
                eConfigDivisionID__c = :divisionId
            WITH SECURITY_ENFORCED
            ORDER BY Year__c DESC
            LIMIT 10000
        ]) {
            if(!yearMap.containsKey(vehicle.Year__c)){
                years.add(new SelectOptionWrapper(String.valueOf(vehicle.Year__c), String.valueOf(vehicle.Year__c)));
                yearMap.put(vehicle.Year__c, vehicle.Year__c);
            }
        }
        return years;
    }

    @AuraEnabled public static List <SelectOptionWrapper> getModelsHonda(Double year) {return getModels(HONDA_DIVISION_CODE, year);} 
    @AuraEnabled public static List <SelectOptionWrapper> getModelsAcura(Double year) {return getModels(ACURA_DIVISION_CODE, year);} 

    @AuraEnabled public static List <SelectOptionWrapper> getModelsPowersports(Double year) {
        List <SelectOptionWrapper > models = new List <SelectOptionWrapper>();
        if(year == 2022){
            models.add(new SelectOptionWrapper('2022', 'Touring'));
            /*models.add(new SelectOptionWrapper('2022', 'Adventure'));
            models.add(new SelectOptionWrapper('2022', 'Cruiser'));
            models.add(new SelectOptionWrapper('2022', 'Supersport'));
            models.add(new SelectOptionWrapper('2022', 'Sport'));
            models.add(new SelectOptionWrapper('2022', 'Neo-Sports Cafe'));
            models.add(new SelectOptionWrapper('2022', 'MiniMOTO'));
            models.add(new SelectOptionWrapper('2022', 'Dual Sport'));
            models.add(new SelectOptionWrapper('2022', 'Scooter'));*/
        }
        if(year == 2021){
            models.add(new SelectOptionWrapper('2021', 'Trail'));
            /*models.add(new SelectOptionWrapper('2021', 'Competition'));
            models.add(new SelectOptionWrapper('2021', 'Adventure'));
            models.add(new SelectOptionWrapper('2021', 'Dual Sport'));*/
        }
        if(year == 2020){
            models.add(new SelectOptionWrapper('2020', 'Rec/Utility'));
           /* models.add(new SelectOptionWrapper('2020', 'Sport'));*/
        }
        if(year == 2019){
            models.add(new SelectOptionWrapper('2019', 'Sport'));
           /* models.add(new SelectOptionWrapper('2019', 'Rec/Utility'));*/
        }
        return models;
    }
    @AuraEnabled public static List <SelectOptionWrapper> getModelsPowerequipment(Double year) {
        List <SelectOptionWrapper > models = new List <SelectOptionWrapper>();
        if(year == 2022){
            models.add(new SelectOptionWrapper('RL6H9NKXW', 'EU1000i'));
        }
        if(year == 2021){
            models.add(new SelectOptionWrapper('CV1F5MJNW', 'HRX217VKA'));
        }
        if(year == 2020){
            models.add(new SelectOptionWrapper('FC1F3MJW', 'WX10'));
        }
        if(year == 2019){
            models.add(new SelectOptionWrapper('FK8G0MGW', 'HS720AM'));
        }
        if(year == 2018){
            models.add(new SelectOptionWrapper('FK8G0MGW', 'F220'));
        }
        if(year == 2017){
            models.add(new SelectOptionWrapper('FK8G0MGW', 'HHT25SLTA'));
        }
        return models;
    }
    @AuraEnabled public static List <SelectOptionWrapper> getModelsMarine(Double year) {
        List <SelectOptionWrapper > models = new List <SelectOptionWrapper>();
        if(year == 2022){
            models.add(new SelectOptionWrapper('RL6H9NKXW', 'BF2.3'));
        }
        if(year == 2021){
            models.add(new SelectOptionWrapper('CV1F5MJNW', 'BF25-30'));
        }
        if(year == 2020){
            models.add(new SelectOptionWrapper('FC1F3MJW', 'BF115'));
        }
        if(year == 2019){
            models.add(new SelectOptionWrapper('FK8G0MGW', '40 Jet'));
        }
        return models;
    }

    private static List<SelectOptionWrapper> getModels(String divisionId, Double year){
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
                modelMap.put(vehicle.Model__c, vehicle.Model_Id__c);
                models.add(new SelectOptionWrapper(vehicle.Model_Id__c, vehicle.Model__c));
            }
        }
        return models;
    }

    /* @AuraEnabled public static List <SelectOptionWrapper> getTrimsPowersports(Double year, String modelId) {
        List <SelectOptionWrapper > trims = new List <SelectOptionWrapper>();
        if(year == 2022){
            trims.add(new SelectOptionWrapper('RL6H9NKXW', 'Gold Wing'));
            trims.add(new SelectOptionWrapper('RL6H9NKXW', 'Gold Wing Tour'));
        }
        if(year == 2021){
            trims.add(new SelectOptionWrapper('CV1F5MJNW', 'CRF450X'));
            trims.add(new SelectOptionWrapper('CV1F5MJNW', 'CRF250F'));
            trims.add(new SelectOptionWrapper('CV1F5MJNW', 'CRF125FB Big Wheel'));
            trims.add(new SelectOptionWrapper('CV1F5MJNW', 'CRF125F'));
        }
        if(year == 2020){
            trims.add(new SelectOptionWrapper('FC1F3MJW', 'Fourtrax Rincon'));
            trims.add(new SelectOptionWrapper('FC1F3MJW', 'Fourtrax Foreman 4×4'));
        }
        if(year == 2019){
            trims.add(new SelectOptionWrapper('FK8G0MGW', 'Talon 1000R Special Edition'));
            trims.add(new SelectOptionWrapper('FK8G0MGW', 'Talon 1000R FOX LIVE VALVE'));
        }
        return trims;
    } */

    /* @AuraEnabled (cacheable = true) public static List <SelectOptionWrapper> getTrims(Double year, String modelId) {return getTrims(HONDA_DIVISION_CODE, year, modelId);}

    private static List<SelectOptionWrapper> getTrims(String divisionId, Double year, String modelId){
        List < SelectOptionWrapper > trims = new List < SelectOptionWrapper > ();
        Map<String, String> trimMap = new Map<String, String>();
        for (Vehicle__c vehicle : [
            SELECT Id, Model_Id__c, Trim__c
            FROM Vehicle__c
            WHERE
                eConfigDivisionID__c = :divisionId
                AND Year__c = :year 
                AND Model__c = :modelId
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
    } */

    private static String getGarageURL(String division){ return '/garage-' + division.toLowerCase(); }

    public class SelectOptionWrapper {
        @AuraEnabled public string value;
        @AuraEnabled public string label;

        public SelectOptionWrapper(string value, string label) {
            this.value = value;
            this.label = label;
        }
    }

    public class Division {
        @AuraEnabled public string divisionId;
        @AuraEnabled public string divisionName;

        public Division(string divisionId, string divisionName) {
            this.divisionId = divisionId;
            this.divisionName = divisionName;
        }
    }

    //====================
    //= Public: populate Product by Product Id & Record Type
    // Added By: Abhishek Salecha On 11th October 2021
    //====================
    @AuraEnabled (cacheable = true) 
    public static Product getProduct(String productId, String brand){
        try {
            return UserInfo.getUserType() != 'Guest' ? queryProduct(productId, brand) : null;
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } // end getGarage()


    //====================
    //= populate Product
    // Added By: Abhishek Salecha On 11th October 2021
    //====================
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Fields have been removed from Honda Product; most values are now accessed through Product Model and Product Model Color
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private static Product queryProduct(String productId, String brand) { 
        if(String.isNotEmpty(productId)){
            
            String queryString = 'SELECT Id, (Select Id,Customer_Uploaded_Image__c From OwnedHondaProduct__r), Name, Product_Models__r.Product_Model_Id__c, Product_Models__r.Model_Name__c, Product_Models__r.Model_Year__c, Product_Models__r.Product_Division__c, Product_Models__r.Product_Subdivision__c, Product_Models__r.Trim__c, Product_Identifier__c ';
            queryString += 'FROM Honda_Product__c ';
            queryString += 'WHERE Id = :productId ';
            if(String.isNotBlank(brand)){
                    String division = '';  
                    switch on brand.toLowerCase() {
                        when 'powersports' {
                            division = 'M';
                        }
                        when 'acura'{
                            division = 'A';
                        }
                    }
                    if(String.isNotBlank(division))            
                        queryString += ' AND Product_Models__r.Product_Division__c =: division '; 
            }
            //queryString += 'WITH SECURITY_ENFORCED ';
            queryString += 'LIMIT 1';
            System.debug(' DB Query : '+queryString);
            String safeQueryString = String.escapeSingleQuotes(queryString);
            List<Honda_Product__c> products = Database.query(safeQueryString);
            if(products.size() > 0) {
                Product productObj = new Product();
                productObj.productId = products[0].Id;
                productObj.productModelId = products[0].Product_Models__r.Product_Model_Id__c;
                productObj.nickname = ''/* products[0].Model_Year__c + ' ' + products[0].Model_Name__c */;
                productObj.divisionId = products[0].Product_Models__r.Product_Division__c;
                productObj.division = products[0].Product_Models__r.Product_Subdivision__c;
                productObj.year = products[0].Product_Models__r.Model_Year__c;
                productObj.modelId = products[0].Product_Models__r.Product_Model_Id__c;
                productObj.model = products[0].Product_Models__r.Model_Name__c;
                productObj.trim = products[0].Product_Models__r.Trim__c;
                productObj.vin = products[0].Product_Identifier__c;
                if(products[0].OwnedHondaProduct__r.size() > 0 && String.isNotblank(products[0].OwnedHondaProduct__r[0].Customer_Uploaded_Image__c)){
                    productObj.image = products[0].OwnedHondaProduct__r[0].Customer_Uploaded_Image__c;
                }
                /*else if(products[0].Product_Model_Color__r != null && string.isNotblank(products[0].Product_Model_Color__r.Thumbnail_Image_URL__c)){
                    productObj.image = products[0].Product_Model_Color__r.Thumbnail_Image_URL__c;
                }*/else{
                    productObj.image = '/owners/resource/Owners/images/garage_hondadefault.svg';
                }
                return productObj;
            }
        }
        return null;
    }
     // end queryProducts()



    //====================
    //= Public: populate Garage and Product by Product Id
    //====================
    @AuraEnabled (cacheable = true) 
    public static Garage getGarage(String productId){
        try {
            return UserInfo.getUserType() != 'Guest' ? new Garage(queryProducts(productId)) : new Garage();
        }catch(Exception e) {
            System.debug('exception ->'+ e.getMessage());
            System.debug('exception ->'+ e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    } // end getGarage()

    //====================
    //= populate Garage Products
    //====================
    private static List<Product> queryProducts(String productId) { 
        Id recallRecordTypeId = Schema.SObjectType.Message__c.getRecordTypeInfosByDeveloperName().get('Recall').getRecordTypeId();
        String accountId = personAccountId();
        List<Product> products = new List<Product>();
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Fields have been removed from Honda Product; most values are now accessed through Product Model and Product Model Color
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Alexander Dzhitenov (Wipro): Added recalls to garage query
        String queryString = 'SELECT Id, Honda_Product__c, Nickname__c, Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c, Honda_Product__r.Product_Models__r.Default_Large_Image_Url__c, Honda_Product__r.Product_Identifier__c, Customer_Uploaded_Image__c, Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c ';
        queryString += ', (SELECT Id FROM Owner_Messages__r WHERE Message__r.RecordTypeId=:recallRecordTypeId) ';
        queryString += 'FROM Ownership__c ';
        queryString += 'WHERE ';
		queryString += 'Managed__c = true AND ';
        queryString += String.isNotEmpty(productId) ? 'Honda_Product__c = :productId ' : 'Product_Owner__c = :accountId ';
        queryString += 'WITH SECURITY_ENFORCED ';
        queryString += 'ORDER BY LastModifiedDate DESC ';
        queryString += 'LIMIT 100';
        String safeQueryString = String.escapeSingleQuotes(queryString);
        List<Ownership__c> ownerships = Database.query(safeQueryString);
        for (Ownership__c ownership :ownerships) {
            Product productObj = new Product();
            productObj.ownershipId=ownership.Id;
            productObj.productId = ownership.Honda_Product__c;
            productObj.productModelId = ownership.Honda_Product__r.Product_Models__r.Product_Model_Id__c;
            productObj.nickname = String.isNotEmpty(ownership.Nickname__c) ? ownership.Nickname__c : ''/* ownership.Honda_Product__r.Model_Year__c + ' ' + ownership.Honda_Product__r.Model_Name__c */;
            productObj.divisionId = ownership.Honda_Product__r.Product_Models__r.Product_Division__c;
            productObj.division = ownership.Honda_Product__r.Product_Models__r.Product_Subdivision__c;
            productObj.year = ownership.Honda_Product__r.Product_Models__r.Model_Year__c;
            productObj.modelId = ownership.Honda_Product__r.Product_Models__r.Product_Model_Id__c;
            productObj.model = ownership.Honda_Product__r.Product_Models__r.Model_Name__c;
            productObj.trim = ownership.Honda_Product__r.Product_Models__r.Trim__c;
            productObj.vin = ownership.Honda_Product__r.Product_Identifier__c;
            productObj.image = OwnContextController.getDivisionLogo(productObj.division);
            productObj.customerUploadedImage = ownership.Customer_Uploaded_Image__c;
            productObj.productDefaultImage = String.isNotEmpty(ownership.Honda_Product__r.Product_Model_Color__c) ? ownership.Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c : ownership.Honda_Product__r.Product_Models__r.Default_Large_Image_Url__c;
            productObj.recallCount = 0;
            for (Owner_Message__c recallMessage : ownership.Owner_Messages__r){
                productObj.recallCount++;
            }
            products.add(productObj);
        }
        return products;
    } // end queryProducts()
    
    //====================
    //= Public: addProduct()
    //====================
    // Commenting out this code for field changes to Honda Product, as this method is outdated and will need to be replaced in a future story
    // -Alexander D. for DOE-3220
    /*@AuraEnabled
    public static Result addProduct(Product product) {
        
         try {
            Result result;
            if(String.isNotEmpty(product.vin)){
                result = insert_ProductRecord(product.vin, product);
            }else if(String.isNotEmpty(product.year) && String.isNotEmpty(product.model)){
                result = insert_ProductRecord(product);
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
        return new Result(false, 'Method no longer in use', new Product());
    } // end addProduct()*/

   //====================
   //= Internal Support Methods
   //====================
    // Commenting out this code for field changes to Honda Product, as this method is outdated and will need to be replaced in a future story
    // -Alexander D. for DOE-3220
/*    private static Result insert_ProductRecord(Product product){

    //private static Result insert_ProductRecord(String vin, Product product){
        Honda_Product__c hondaProduct = new Honda_Product__c();
        Ownership__c ownership = new Ownership__c();
       // Community_Context__c communityContext = getCommunityContext();
        hondaProduct.Product_Model__c = getProductModelId(product.modelId);
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // These fields have been moved to the Product Model object; the method for inserting products by YMT will need to be reworked in a future story
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        hondaProduct.Product_Division__c = product.divisionId;
        hondaProduct.Product_Subdivision__c = product.division;
        hondaProduct.Model_Year__c = product.year;
        hondaProduct.Model_Id__c = product.modelId;
        hondaProduct.Model_Name__c = product.model;
        hondaProduct.Trim__c = product.trim;
        system.debug('hondatrim:'+hondaProduct.Trim__c);
        if (CanTheUser.create(hondaProduct)) {
            insert hondaProduct; 
            system.debug('honda  product created.');
            ownership.Product_Owner__c = personAccountId();
            ownership.Honda_Product__c = hondaProduct.Id;
            ownership.Managed__c = true;
            if (CanTheUser.create(ownership)) {
                insert ownership; 
                // Modified on 4th dec 2021 for DOE-2466
                // communityContext.Level1__c = getGarageURL(product.division);
                // communityContext.Level2__c = hondaProduct.Id;
                // communityContext.UserId__c = UserInfo.getUserId();
                // communityContext.Owner_Product__c = hondaProduct.Id;
                // if (CanTheUser.create(communityContext)) {
                //     upsert communityContext; 
                // }
                updateContextUser(hondaProduct.Id , 'Overview');
            }
        }
        system.debug('hondaId:'+hondaProduct.Id);
        Product productObj = product;
        productObj.productId = hondaProduct.Id;
        productObj.productModelId = hondaProduct.Product_Model__c;
        return new Result(true, 'Product added to Garage', productObj);
   } // end insert_ProductRecord(String year, String model) */

   //====================
   //= Internal Support Methods
   //====================
    // Commenting out this code for field changes to Honda Product, as this method has been replaced by AddProductByVIN
    // -Alexander D. for DOE-3220
/*    private static Result insert_ProductRecord(String vin, Product product){

    
        Boolean vinExistsInProudct = false;
        Boolean vinExistsInOwnership = false;
        Honda_Product__c hondaProduct = new Honda_Product__c();
        Ownership__c ownership = new Ownership__c();
         // Modified on 4th dec 2021 for DOE-2466
         // Community_Context__c communityContext = getCommunityContext();
         List<Honda_Product__c> products = [SELECT Id, Name, Product_Model__c, Product_Division__c, Product_Subdivision__c, Model_Year__c, Model_Id__c, Model_Name__c, Trim__c, Product_Identifier__c, (SELECT Id, Name, Nickname__c  
                                                              FROM OwnedHondaProduct__r 
                                                              WHERE 
                                                                Honda_Product__r.Product_Identifier__c = :vin 
                                                                AND Product_Owner__c = :personAccountId()
                                                              LIMIT 1)
                                            FROM Honda_Product__c
                                            WHERE
                                                Product_Identifier__c = :vin
                                            WITH SECURITY_ENFORCED
                                            LIMIT 1
                                        ];
        if(products.isEmpty()){
            return new Result(false, 'Please enter the valid VIN', product);
        }
        for (Honda_Product__c productRecord : products) {
            vinExistsInProudct = true;
            hondaProduct = productRecord;
            for(Ownership__c ownershipObj : hondaProduct.OwnedHondaProduct__r){
                vinExistsInOwnership = true;
                ownership = ownershipObj;
            }
        }
        if(vinExistsInProudct && vinExistsInOwnership){
            // Modified on 4th dec 2021 for DOE-2466
            // communityContext.Level1__c = getGarageURL(product.division);
            // communityContext.Level2__c = hondaProduct.Id;
            // communityContext.UserId__c = UserInfo.getUserId();
            // communityContext.Owner_Product__c = hondaProduct.Id;
            // if (CanTheUser.create(communityContext)) {
            //     upsert communityContext; 
            // }
            updateContextUser(hondaProduct.Id , 'Overview');
        }
        if(vinExistsInProudct && !vinExistsInOwnership){
            ownership = new Ownership__c();
            ownership.Product_Owner__c = personAccountId();
            ownership.Honda_Product__c = hondaProduct.Id;
            ownership.Verified__c = true;
            ownership.Nickname__c = product.nickname; //harcoded as API call is under construction //hondaProduct.Model_Year__c + ' ' + hondaProduct.Model_Name__c;
            if (CanTheUser.create(ownership)) {
                insert ownership; 
                // Modified on 4th dec 2021 for DOE-2466
                // communityContext.Level1__c = getGarageURL(product.division);
                // communityContext.Level2__c = ownership.Id;
                // communityContext.UserId__c = UserInfo.getUserId();
                // communityContext.Owner_Product__c = hondaProduct.Id;
                // if (CanTheUser.create(communityContext)) {
                //     upsert communityContext; 
                // }
                updateContextUser(hondaProduct.Id , 'Overview');
            }
        }
        Product productObj = product;
        productObj.productId = hondaProduct.Id;
        productObj.productModelId = hondaProduct.Product_Model__c;
        productObj.nickname = product.nickname; //harcoded as API call is under construction //ownership.Nickname__c;
        productObj.divisionId = hondaProduct.Product_Division__c;
        productObj.division = hondaProduct.Product_Subdivision__c;
        productObj.year = hondaProduct.Model_Year__c;
        productObj.modelId = hondaProduct.Model_Id__c;
        productObj.model = hondaProduct.Model_Name__c;
        productObj.trim = hondaProduct.Trim__c;
        productObj.vin = hondaProduct.Product_Identifier__c;
        return new Result(true, 'Product added to Garage', productObj);
        //return new Result(false, 'Method no longer in use', new Product());
    } // end insert_ProductRecord(String vin) */


    //====================
    //= Public: updateProduct(product)
    //====================
    // Commenting out this code for field changes to Honda Product, as this method has been replaced by AddProductByVIN
    // -Alexander D. for DOE-3220
    @AuraEnabled
    public static Result updateProduct(Product product) {
/*         try {
            return update_ProductRecord(product);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } */
        return new Result(false, 'Method no longer in use', new Product());
    } // end updateProduct(product)

    /* private static Result update_ProductRecord(Product product){
        // Commenting out this code for field changes to Honda_Product__c; method is not in use
        Ownership__c ownership = [SELECT Id, Nickname__c, Honda_Product__c, Honda_Product__r.Product_Subdivision__c
                                    FROM Ownership__c
                                    WHERE
                                        Honda_Product__c = :product.productId 
                                        AND Product_Owner__c = :personAccountId()
                                    WITH SECURITY_ENFORCED
                                    LIMIT 1
                                ];
        if(ownership != null){
            ownership.Nickname__c = product.nickname; 
            if(CanTheUser.edit(ownership)){
                update ownership;
                if(String.isNotEmpty(product.vin)){
                    List<Honda_Product__c> products = [SELECT Id, Name, Product_Model__c, Product_Division__c, Product_Subdivision__c, Model_Year__c, Model_Id__c, Model_Name__c, Trim__c, Product_Identifier__c, (SELECT Id, Name, Nickname__c  
                                                              FROM OwnedHondaProduct__r 
                                                              WHERE 
                                                                Honda_Product__r.Product_Identifier__c = :product.vin 
                                                                AND Product_Owner__c = :personAccountId()
                                                              LIMIT 1)
                                            FROM Honda_Product__c
                                            WHERE
                                                Product_Identifier__c = :product.vin
                                            WITH SECURITY_ENFORCED
                                            LIMIT 1
                                        ];
                    if(products.isEmpty()){
                        return new Result(false, 'Please enter the valid VIN', product);
                    }
                    Honda_Product__c hondaProduct = new Honda_Product__c();
                    hondaProduct.Id = product.productId;
                    //hondaProduct.Product_Identifier__c = product.vin;
                    if (CanTheUser.create(hondaProduct)) {
                        update hondaProduct; 
                    }
                }
            }
        }
        return new Result(true, 'Product updated to Garage', product); 
        //return new Result(false, 'Method no longer in use', new Product());
    //} // end update_ProductRecord(String vin) */

    //====================
    //= Public: removeProduct(String productId)
    //====================
    @AuraEnabled
    public static Result removeProduct(String productId) {
        try {
            return delete_ProductRecord(productId);
        } catch (Exception e) {
            System.debug('exception =>'+ e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    } // end removeProduct(String productId)

    private static Result delete_ProductRecord(String productId){

        //jkohs july 7 2021 - 
        // when we delete a product we need to essentially 'reverse' the 'insert product' insofar as we:
        // 1) check the source of the Ownership__c record (which corrolates to the associated Honda_Products__c record)
        //      a) if that record came from the api / migration / rdr .... the ok we leave the Honda Product Record there and we're done
        //      b) but if that record was 'user entered' (maybe they entered Year+Model) .... then we should nuke the assoc Honda Product Record there and we're done
        // ** jim & jodi & chris still architecting where this 'source' field is.  right now we're thinking it is the Ownership__c.Verified__c field
		//Brett Spokes Dec 2 2021 - DOE 2347
		// - Modified code to set Managed__c to false instead of removing ownership and or product objects
        // -Modified code to change Community_Context__c With User for DOE-2466
        Id personAccountId = personAccountId();
        List<Product> products = new List<Product>();
        Honda_Product__c product = new Honda_Product__c(Id = productId);
        List<Ownership__c> ownershipList = [SELECT Id, Verified__c,
                                                    Honda_Product__r.Product_Identifier__c
                                            FROM Ownership__c
                                            WHERE
                                                Honda_Product__c = :productId 
                                                AND Product_Owner__c = :personAccountId 
                                            WITH SECURITY_ENFORCED                                 
                                ];
        
        // List<Community_Context__c> communityContexts = [
        //                                     SELECT Id, Name, Level1__c, Level2__c, Owner_Product__c 
        //                                     FROM Community_Context__c
        //                                     WHERE
        //                                         UserId__c = :UserInfo.getUserId() 
        //                                     WITH SECURITY_ENFORCED
        //                                     LIMIT 1
        //                                 ];

        Set<String> vinRemoveSet = new Set<String>();

        for(Ownership__c own : ownershipList){
            if(CanTheUser.edit(own)){
                own.Managed__c = false;
                update own;
    
                List<Product> previousProduct = queryProducts('');

                if(!previousProduct.isEmpty()){
                    updateContextUser(previousProduct[0].productId, 'Overview');
                        }
                else {
                    updateContextUser('', 'Overview');
                }

                if (!String.isEmpty(own.Honda_Product__r.Product_Identifier__c)){
                    vinRemoveSet.add(own.Honda_Product__r.Product_Identifier__c);
                }
        }

        // Alexander Dzhitenov (Wipro) Recalls - delete associated Owner_Message__c records when the user removes a product from their garage
        /* List<Owner_Message__c> ownerMessages = [SELECT Id FROM Owner_Message__c WHERE Owner__c=:personAccountId AND Message__r.Product_Identifier__c IN :vinRemoveSet];
        delete ownerMessages; */


            // products = queryProducts('');
            // if(!communityContexts.isEmpty() && !products.isEmpty()){
            //     if(CanTheUser.edit(communityContexts[0])){
            //         communityContexts[0].Level1__c = '/garage-' + products[0].division;
            //         communityContexts[0].Level2__c = products[0].productId;
            //         communityContexts[0].Owner_Product__c = products[0].productId;
            //         update communityContexts;
            //     }
            // }else if(!communityContexts.isEmpty()){
            //     if(CanTheUser.destroy(communityContexts[0])){
            //         delete communityContexts;
            //     }
            // }
        }
        return new Result(true, 'Product successfully removed, redirecting to home', !products.isEmpty() ? products[0] : new Product());
    } // end delete_ProductRecord(String productId)

    //====================
    //= Public Class: Garage
    //====================
    public class Garage {
        @AuraEnabled public List<Product> products {get; set;}
        public Garage(List<Product> products){
            this.products = products;
        }
        public Garage(){}
    } // end Garage Class()

    //====================
    //= Public Class: Product
    //====================
    public class Product {
        @AuraEnabled public String productId {get; set;}
        @AuraEnabled public String nickname {get; set;}
        @AuraEnabled public String productModelId {get; set;}
        @AuraEnabled public String divisionId {get; set;}
        @AuraEnabled public String division {get; set;}
        @AuraEnabled public String year {get; set;}
        @AuraEnabled public String modelId {get; set;}
        @AuraEnabled public String model {get; set;}
        @AuraEnabled public String trim {get; set;}
        @AuraEnabled public String vin {get; set;}
        @AuraEnabled public String powersportsTypeId {get; set;}
        @AuraEnabled public String powersportsType {get; set;}
        @AuraEnabled public String powerEquipmentProductId {get; set;}
        @AuraEnabled public String powerEquipmentProduct {get; set;}
        @AuraEnabled public String powerEquipmentTypeId {get; set;}
        @AuraEnabled public String powerEquipmentType {get; set;}
        @AuraEnabled public String marineOutboardId {get; set;}
        @AuraEnabled public String marineOutboard {get; set;}
        @AuraEnabled public Boolean isDefault {get; set;}
        @AuraEnabled public String image {get; set;} 
        @AuraEnabled public ModelColor color {get; set;}
        @AuraEnabled public String productDefaultImage {get; set;} 
        @AuraEnabled public String customerUploadedImage {get; set;}
        @AuraEnabled public Boolean isUserImage {get; set;}
        @AuraEnabled public Boolean isSaved {get; set;}
        @AuraEnabled public Boolean isEditable {get; set;}
        @AuraEnabled public Integer origination {get; set;}
        @AuraEnabled public String ownershipId {get; set;}
        @AuraEnabled public Integer recallCount {get;set;}
        Public Product(){}
    } // end Product Class()   

    public enum OriginationCode {
        TEST_DRIVE_USER_PRODUCT_THEN_REGISTERED,
        STANDARD_WEB_PRODUCT_ADDED,
        DEALER_ADDED_VIA_STANDARD_WEB_REGISTRATION,
        IN_ADDED_PRODUCT,
        RDR_ADDED_PRODUCT,
        WAITLIST_ADDED_PRODUCT,
        PROD_ADDED_TO_ECUSTOMER_THEN_USER_LOGGED_IN_TO_OL,
        UNKNOWN_PRODUCT_SOURCE,
        SERVICE_REMINDER_REGISTRATION_PRODUCT,
        HONDA_FINANCE_PRODUCT_ADDED,
        MC_RDR_PRODUCT,
        POWER_EQUIPMENT_MINI_OL_REGISTRATION,
        MARINE_EQUIPMENT_MINI_OL_REGISTRATION,
        MC_OL_SWEEPSTAKES,
        CSAT_ADMIN,
        SERVICE_OFFER_PRODUCT_REGISTRATION,
        ECRM,
        CONNECTED
    }

    // Public Class: ModelColor (from OwnEConfigApiHelper, with LWC annotations added)
    public class ModelColor {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String mfg_color_cd {get; set;}
        public ModelColor(){}
    }

    //====================
    //= Public Class: Result
    //====================
    public class Result {
        @AuraEnabled public Boolean isSuccess {get; set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public Product product {get; set;}
        Public Result(Boolean isSuccess, String message){
            this.isSuccess = isSuccess;
            this.message = message;
        }
        Public Result(Boolean isSuccess, String message, Product product){
            this.isSuccess = isSuccess;
            this.message = message;
            this.product = product;
        }
        Public Result(){}
    } // end Product Class()  
     @AuraEnabled
    Public static List<Ownership__c> getNearbyDealers (string productId,String Latitude,String Longitude)
    { List<Ownership__c> ProductList = [SELECT Id, Honda_Product__c, Nickname__c, 
                                        Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c,
                                        Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Models__r.Model_Name__c, 
                                        Honda_Product__r.Product_Models__r.Trim__c, Honda_Product__r.Product_Identifier__c FROM Ownership__c WHERE
                                         Honda_Product__c=:productId ] ;
     System.debug('&&&ProductList'+ ProductList[0].Honda_Product__r.Product_Models__r.Model_Name__c);
     return ProductList;
           
        }

    //====================
    //= Public: getDivisionNameFromCode
    //====================

    @AuraEnabled
    public static String getDivisionNameFromCode(String divisionCode){
        return DIVISION_MAP.get(divisionCode).divisionName;
    }

    //====================
    //= Exception: DuplicateException
    //= Added by Alexander D. for DOE-2345
    //====================
    //Added AND  Managed__c = true  check for DOE-4223 Ravindra Ravindra (Wipro)
    public class DuplicateException extends Exception{}
    public class DuplicateVinException extends Exception{}

    @AuraEnabled (cacheable = true)
    public static Boolean checkUserGarageForVIN(String vin){
        String userId = UserInfo.getUserId();
        Id personAcctId = [SELECT AccountId FROM User WHERE Id=:userId LIMIT 1]?.AccountId;
        List<Ownership__c> productsWithVin = [SELECT Id FROM Ownership__c WHERE Honda_Product__r.Product_Identifier__c=:vin AND  Managed__c = true AND  Product_Owner__c=:personAcctId];
        return !productsWithVin.isEmpty();
    }

    @AuraEnabled (cacheable = true)
    public static String getUserGarageForVIN(String vin){
        String userId = UserInfo.getUserId();
        Id personAcctId = [SELECT AccountId FROM User WHERE Id=:userId LIMIT 1]?.AccountId;
        List<Ownership__c> productsWithVin = [SELECT Id FROM Ownership__c WHERE Honda_Product__r.Product_Identifier__c=:vin AND  Managed__c = true AND  Product_Owner__c=:personAcctId];
        if(!productsWithVin.isEmpty()){
            return productsWithVin[0].Id;
        }
        return ''; 
    }

    @AuraEnabled (cacheable = true)
    public static Boolean checkUserGarageForModelId(String modelId){
        String userId = UserInfo.getUserId();
        Id personAcctId = [SELECT AccountId FROM User WHERE Id=:userId LIMIT 1]?.AccountId;
        List<Ownership__c> productsWithModelId = [SELECT Id FROM Ownership__c WHERE Honda_Product__r.Product_Models__r.Product_Model_Id__c=:modelId AND Honda_Product__r.Product_Identifier__c='' AND Managed__c = true AND  Product_Owner__c=:personAcctId];
        return !productsWithModelId.isEmpty();
    }

    @AuraEnabled (cacheable = true)
    public static String getUserGarageForModelId(String modelId){
        String userId = UserInfo.getUserId();
        Id personAcctId = [SELECT AccountId FROM User WHERE Id=:userId LIMIT 1]?.AccountId;
        List<Ownership__c> productsWithModelId = [SELECT Id FROM Ownership__c WHERE Honda_Product__r.Product_Models__r.Product_Model_Id__c=:modelId AND Honda_Product__r.Product_Identifier__c='' AND Managed__c = true AND  Product_Owner__c=:personAcctId];
        if(!productsWithModelId.isEmpty()){
            return productsWithModelId[0].Id;
        }
        return ''; 
    }

    // Added by Alexander Dzhitenov (Wipro) - Method that is called from the community site when the user adds a product, either by VIN or Product Chooser
    @AuraEnabled
    public static Result addProduct(Product product){

        Id userId = UserInfo.getUserId();
        Id acctId = [SELECT AccountId FROM User WHERE Id = :userId LIMIT 1]?.AccountId;
        Boolean recallCalloutSuccess;
        Boolean addProductSuccess;
        Result result = new Result();

        Map<String, OwnRecallsController.RecallObject> newRecallDataMap = new Map<String, OwnRecallsController.RecallObject>();

        // Get product recall data
        try{
            newRecallDataMap = OwnRecallsController.getRecallData(new List<Product>{product}, acctId);
            recallCalloutSuccess = true;
        }
        catch(Exception e){
            System.debug('Recall callout exception; ' + e);
            recallCalloutSuccess = false;
        }
        // Add product to user's garage
        try{
            if (!String.isEmpty(product.vin) && product.vin != '-'){
                addProductByVin(product, acctId);
            }
            else{
                addProductByYMT(product, acctId);
            }
            addProductSuccess = true;
            result = new Result(true, 'Product successfully added to garage.');
        }
        catch(Exception e){
            result = new Result(false, e.getMessage());
            addProductSuccess = false;
        }
        // Save product recall data, delete recalls if necessary
        if (recallCalloutSuccess && addProductSuccess){
            try{
                OwnRecallsController.saveAndDeleteRecallsData(newRecallDataMap, acctId);
            }
            catch(Exception e){
                System.debug('Recall save exception; ' + e);
            }
        }

        return result;
    }


    //====================
    //= Public: addProductsByVin
    //= Added by Alexander D. for DOE-2345
    // -Modified code to change Community_Context__c With User for DOE-2466
    //====================

    // Added by Alexander Dzhitenov (Wipro) for DOE-2345 - Method that is called from the addProduct method when the user adds a product to their garage by Product Chooser from the community site
    // ***For web use only—should only be called from LWC (automatically sets the origination code to Web)***
    @AuraEnabled
    public static List<Ownership__c> addProductByVin(Product product, Id acctId){
        product.origination = 2;
        List<Ownership__c> newOwnerships = addProductsByVIN(new List<Product>{product}, acctId);

        if (product.divisionId != 'P' && product.divisionId != 'M'){
            Set<Id> newOwnershipId = new Set<Id>();
            newOwnershipId.add(newOwnerships[0].Id);
            OwnMyVehicleApiHelper.sendToMyVehicles_async(newOwnershipId);
        }

        return newOwnerships;
    }

    @Future
    public static void addProductsByVin_async(String productListstr, Id acctId){
        List<Product> productList = (List<Product>) JSON.deserialize(productListstr, List<Product>.class);
        addProductsByVin(productList, acctId);
    }

    // Added by Alexander Dzhitenov (Wipro) for DOE-2345 - Method for adding products to a user's garage by VIN
    public static List<Ownership__c> addProductsByVin(List<Product> productList, Id acctId){
        // For each product in productList, a Honda Product record must either be created - or an existing one found
        // Each Honda Product record must have an associated Product Model and Product Model Color record - if the
        // necessary records do not exist, they must be created
        // (question: how do we handle existing ProductModelColor records that may be associated with a YMT Honda Product record?)
        // (The VIN image may end up overwriting the YMT image)
        // All possible details for new records must be populated from the values provided
        // Finally, a new ownership for the current user must be created for each resulting Honda Product record.
        // All records should be inserted or updated as Lists, to avoid bulk DML errors

        Id personAcctId = acctId;

        Set<String> addVinSet = new Set<String>();
        Set<String> duplicateVinSet = new Set<String>();
        Set<String> modelIdSet = new Set<String>();
        Set<String> modelId_mfgColorCodeSet = new Set<String>();
        Map<String, Product> productMap = new Map<String, Product>();

        System.debug(JSON.serialize(productList));

        for (Product p : productList){
            p.vin = p.vin.toUpperCase();
        }

        // Identify which VINs need to be searched against, and ensure the same VIN does not appear twice in the list
        for (Product p : productList){
            addVinSet.add(p.vin);
            //productMap.put(p.vin, p);
        }

        // Identify VINs that are already in the User's garage; throw an exception of no new VINs are added 
        // (Handle this in the Connected API call for cases when no new VINs will be added to the garage)
        duplicateVinSet = findDuplicateVins(addVinSet, personAcctId);
        addVinSet.removeAll(duplicateVinSet);
        System.debug(addVinSet);
        System.debug('DUPLICATE VINS FOUND');
        System.debug(duplicateVinSet);
        System.debug(addVinSet);

        // Ensure that the same VIN is not added twice, and that VINs that already exist in the user's garage are not added again
        for (Product p : productList){
            if (!productMap.containsKey(p.vin) && !duplicateVinSet.contains(p.vin)){
                productMap.put(p.vin, p);
            }
        }

        if (productMap.isEmpty() && !duplicateVinSet.isEmpty()){
            throw new DuplicateException('VIN is already registered with another product.');
        }

        // Identify which Model Ids, and ModelId_MfgColorCodes need to be searched against    
        for (Product p : productMap.values()){
            modelIdSet.add(p.modelId);
            modelId_mfgColorCodeSet.add(p.modelId + '_' + p.color.mfg_color_cd);
        }

        System.debug('Handling existing ownerships');

        // Obtain lists of both existing records, and those to be inserted
        List<Honda_Product__c> hondaProductList = handleHondaProducts(addVinSet, productMap.values());
        ProductModelListWrapper productModelList = handleProductModels(modelIdSet, productMap.values());
        ProductModelColorListWrapper productModelColorList = handleProductModelColors(modelId_mfgColorCodeSet, productMap.values());

        List<Honda_Product__c> newHPList = new List<Honda_Product__c>();
        List<Product_Model__c> newPMList = new List<Product_Model__c>();
        List<Product_Model_Color__c> newPMCList = new List<Product_Model_Color__c>();

        // Separate new records
        for (Honda_Product__c hp : hondaProductList){
            if (hp.Id == null || hp.Product_Models__c == null || hp.Product_Model_Color__c == null){
                newHPList.add(hp);
            }
        }
        newPMList = productModelList.newRecords;
        newPMCList = productModelColorList.newRecords;

        System.debug(newPMList);
        upsert newPMList;
        List<Product_Model__c> allPMRecords = new List<Product_Model__c>();
        allPMRecords.addAll(newPMList);
        allPMRecords.addAll(productModelList.existingRecords);

        List<Product_Model_Color__c> allPMCRecords = new List<Product_Model_Color__c>();
        allPMCRecords.addAll(newPMCList);
        allPMCRecords.addAll(productModelColorList.existingRecords);
        // Create maps between VIN, Model ID, and Model Id/Manufacturer color code

        Map<String, String> vinToModelId = new Map<String, String>();
        Map<String, String> vinToMfgColorCode = new Map<String, String>();

        for (Product p : productMap.values()){
            vinToModelId.put(p.vin, p.modelId);
            if (p.color.mfg_color_cd != null){
                vinToMfgColorCode.put(p.vin, p.color.mfg_color_cd);
            }
        }

        // Set up associations for new records according to modelId/manufacturer color code

        for (Product_Model_Color__c pmc : newPMCList){
            for (Product_Model__c pm : allPMRecords){
                if (pm.Product_Model_Id__c == pmc.Model_ID_Manufacture_Color_Code__c.substringBefore('_')){
                    pmc.Product_Model__c = pm.Id;
                }
            }
        }
        System.debug(newPMCList);
        upsert newPMCList;

        for (Honda_Product__c hp : newHPList){
            // Set up associations with Product Model records for new Honda Product records
            for (Product_Model__c pm : allPMRecords){
                if (pm.Product_Model_Id__c == vinToModelId.get(hp.Product_Identifier__c)){
                    hp.Product_Models__c = pm.Id;
                }
            }
            // Set up associations with Product Model Color records for new Honda Product records
            for (Product_Model_Color__c pmc : allPMCRecords){
                if (pmc.Model_ID_Manufacture_Color_Code__c == (vinToModelId.get(hp.Product_Identifier__c) + '_' + vinToMfgColorCode.get(hp.Product_Identifier__c))){
                    hp.Product_Model_Color__c = pmc.Id;
                }
            }
            System.debug(JSON.serialize(hp));
        }
        System.debug(newHPList);
        upsert newHPList;

        // Track 
        Set<String> newVinSet = new Set<String>();
        for (Honda_Product__c hp : hondaProductList){
            newVinSet.add(hp.Product_Identifier__c);
        }

        // Create Ownership records, and associate them with the Honda Products

        List<Ownership__c> newOwnerships = new List<Ownership__c>();

/*         for (Honda_Product__c hp : hondaProductList){
            newOwnerships.add(createOwnershipForHondaProduct(hp, personAcctId, true, false));
        } */

        newOwnerships = handleOwnerships(newVinSet, hondaProductList, personAcctId, productMap);

        upsert newOwnerships;

        // Select most recent vehicle, based on model year

        String mostRecentYear = '0';
        String mostRecentVin;

        for (Product p : productMap.values()){
            System.debug('%%%%%%%%%% p.year: ' + p.year);
            if (!String.isEmpty(p.year)){
                if (Integer.valueOf(p.year) > Integer.valueOf(mostRecentYear)){
                    mostRecentYear = p.year;
                    mostRecentVin = p.vin;
                }
            }
        }
        if (mostRecentVin == null){
            mostRecentVin = productMap.values()[0].vin;
        }
        Id mostRecentProductId;
        for (Honda_Product__c hp : hondaProductList){
            if (hp.Product_Identifier__c == mostRecentVin){
                mostRecentProductId = hp.Id;
            }
        }
        System.debug('AddProducts mostRecentProductId: ' + mostRecentProductId);
        // Set most recent Honda Product as the first Ownership in the list—user login sequence will set that as the current product for first-time users, and will set
        // the last-visited product as the current product for returning users
        Ownership__c oTemp = newOwnerships[0];
        Integer mostRecentOwnershipIndex = 0;
        for (Ownership__c o : newOwnerships){
            if (o.Honda_Product__c == mostRecentProductId){
                mostRecentOwnershipIndex = newOwnerships.indexOf(o);
            }
        }
        System.debug('Most recent ownership HPID: ' + newOwnerships[mostRecentOwnershipIndex].Honda_Product__c);
        newOwnerships[0] = newOwnerships[mostRecentOwnershipIndex];
        newOwnerships[mostRecentOwnershipIndex] = oTemp;
        
        updateContextUser(hondaProductList[0].Id , 'Overview');
        //updateContextUser(mostRecentProductId, 'Overview');

        return newOwnerships;
    }

    //====================
    //= Internal Support Methods
    //====================

    public static Set<String> findDuplicateVins(Set<String> vinSet, Id personAcctId){
        Set<String> duplicateVins = new Set<String>();
        List<Ownership__c> ownDuplicateVins = [SELECT Honda_Product__r.Product_Identifier__c FROM Ownership__c
                                            WHERE Managed__c = true AND Honda_Product__r.Product_Identifier__c IN :vinSet
                                            AND Product_Owner__c = :personAcctId];
        
        for (Ownership__c o : ownDuplicateVins){
            duplicateVins.add(o.Honda_Product__r.Product_Identifier__c);
        }
        return duplicateVins;
    }

    // Internal support method for Add Product methods; returns a list of existing Honda Products for the user and VINs passed in,
    // and creates new Honda Products for VINs that do not have an existing Honda Product record
    private static List<Honda_Product__c> handleHondaProducts(Set<String> identifierSet, List<Product> products){

        List<Honda_Product__c> returnList = new List<Honda_Product__c>();
        List<Honda_Product__c> existingRecords = [SELECT    Id, Product_Identifier__c, Product_Models__c, Product_Model_Color__c
                                                            FROM Honda_Product__c
                                                            WHERE Product_Identifier__c IN :identifierSet];
        Map<String, Honda_Product__c> existingRecordMap = new Map<String, Honda_Product__c>();

        for (Honda_Product__c hp : existingRecords){
            existingRecordMap.put(hp.Product_Identifier__c, hp);
        }
        for (Product p : products){
            if (existingRecordMap.containsKey(p.vin)){
                returnList.add(existingRecordMap.get(p.vin));
            }
            else{
                returnList.add(fillHondaProductFromProduct(p));
            }
        }
        return returnList;
    }

    // Internal support method for Add Product methods; returns a list of existing Product Model for the user and modelIds passed in,
    // and creates new Product Model for modelIds that do not have an existing Product Model record
    private static ProductModelListWrapper handleProductModels(Set<String> identifierSet, List<Product> products){
        // Obtain existing product model records, and create new ones for modelIDs not already present in the system.
        // If fields differ between existing Product Model records and Product records obtained from VIN Master Search API,
        // update the existing records.
        // Return separate lists of new and existing records.
        List<Product_Model__c> newRecordsReturn = new List<Product_Model__c>();
        List<Product_Model__c> existingRecordsReturn = new List<Product_Model__c>();
        List<Product_Model__c> existingRecords = [SELECT Id, Product_Model_Id__c, Model_Year__c, Model_Name__c, Trim__c FROM Product_Model__c WHERE Product_Model_Id__c IN :identifierSet];
        Map<String, Product_Model__c> existingRecordMap = new Map<String, Product_Model__c>();

        Set<String> modelIdsInUse = new Set<String>(); // Account for possible duplicate modelIds in Product list

        for (Product_Model__c rec : existingRecords){
            existingRecordMap.put(rec.Product_Model_Id__c, rec);
        }
        for (Product p : products){
            if (!modelIdsInUse.contains(p.modelId)){
                // ModelID has not been accounted for
                if (existingRecordMap.containsKey(p.modelId)){
                    // Record already exists in database; check for field differences
                    Product_Model__c pm = existingRecordMap.get(p.modelId);
                    Boolean isFieldUpdate = false;
                    if (pm.Model_Year__c == null){
                        pm.Model_Year__c = p.year;
                        isFieldUpdate = true;
                    }
                    if (pm.Model_Name__c == null){
                        pm.Model_Name__c = p.model + ' ' + p.trim; // Setting model name to concatenate model + trim for consistency with Product Chooser API response
                        isFieldUpdate = true;
                    }
                    if (isFieldUpdate){
                        newRecordsReturn.add(pm);
                    }
                    else{
                        existingRecordsReturn.add(pm);
                    }
                }
                else{
                    // Record does not exist in database; create new record.
                    newRecordsReturn.add(fillProductModelFromProduct(p));
                }
                modelIdsInUse.add(p.modelId);
            }
        }
        ProductModelListWrapper returnList = new ProductModelListWrapper();
        returnList.newRecords = newRecordsReturn;
        returnList.existingRecords = existingRecordsReturn;
        return returnList;
    }

    private class ProductModelListWrapper {
        public List<Product_Model__c> newRecords;
        public List<Product_Model__c> existingRecords;
    }

    // Internal support method for Add Product methods; returns a list of existing Product Model Colors for the user and modelId_ManufacturerColorCodes passed in,
    // and creates new Product Model Colors for modelId_ManufacturerColorCodes that do not have an existing Product Model Colors record
    private static ProductModelColorListWrapper handleProductModelColors(Set<String> identifierSet, List<Product> products){

        List<Product_Model_Color__c> newRecordsReturn = new List<Product_Model_Color__c>();
        List<Product_Model_Color__c> existingRecordsReturn = new List<Product_Model_Color__c>();
        List<Product_Model_Color__c> existingRecords = [SELECT Id, Model_ID_Manufacture_Color_Code__c, Product_Model__c, Exterior_Color_Name__c FROM Product_Model_Color__c 
                                                        WHERE Model_ID_Manufacture_Color_Code__c IN :identifierSet];
        Map<String, Product_Model_Color__c> existingRecordMap = new Map<String, Product_Model_Color__c>();

        Set<String> modelIdMfgColorCodesInUse = new Set<String>();

        for (Product_Model_Color__c rec : existingRecords){
            existingRecordMap.put(rec.Model_ID_Manufacture_Color_Code__c, rec);
        }
        for (Product p : products){
            String modelIdMfgColorCode = p.modelId + '_' + p.color.mfg_color_cd;
            if (!modelIdMfgColorCodesInUse.contains(modelIdMfgColorCode)){
                if (existingRecordMap.containsKey(modelIdMfgColorCode)){
                    // Record already exists in database; check for field differences
                    Product_Model_Color__c pmc = existingRecordMap.get(modelIdMfgColorCode);
                    Boolean isFieldUpdate = false;
                    if (pmc.Exterior_Color_Name__c == null){
                        pmc.Exterior_Color_Name__c = p.color.name;
                    }
                    if (isFieldUpdate || pmc.Product_Model__c == null){
                        newRecordsReturn.add(pmc);
                    }
                    else{
                        existingRecordsReturn.add(pmc);
                    }
                }
                else if (p.color.mfg_color_cd != null){ // Do not create PMC records without MFG color code; in this case, image will be saved to Image URL fields on Product Model
                    // Record does not exist in database; create new record.
                    newRecordsReturn.add(fillProductModelColorFromProduct(p));
                }
                modelIdMfgColorCodesInUse.add(modelIdMfgColorCode);
            }
        }
        ProductModelColorListWrapper returnList = new ProductModelColorListWrapper();
        returnList.newRecords = newRecordsReturn;
        returnList.existingRecords = existingRecordsReturn;
        return returnList;
    }

    private class ProductModelColorListWrapper {
        public List<Product_Model_Color__c> newRecords;
        public List<Product_Model_Color__c> existingRecords;
    }

    // Internal support method for Add Product methods; returns a list of existing Ownerships for the user and VINs passed in, and creates new Ownerships for VINs that do not
    // have an existing Ownership record
    private static List<Ownership__c> handleOwnerships(Set<String> vinSet, List<Honda_Product__c> hondaProducts, Id ownerAcctId, Map<String, Product> productMap){
        // Checks the database for Ownership records for the Honda Products being added for the current user that have been removed from their garage (Managed__c == false).
        // Creates new records for those products that do not have an existing ownership. Creates relationships between Honda Product and Ownership objects
        List<Ownership__c> ownershipList = new List<Ownership__c>();
        List<Ownership__c> existingOwnerships = [SELECT Id, Honda_Product__c, Honda_Product__r.Product_Identifier__c FROM Ownership__c WHERE Product_Owner__c = :ownerAcctId AND Honda_Product__r.Product_Identifier__c IN :vinSet];

        Map<String, Ownership__c> existingOwnershipMap = new Map<String, Ownership__c>();

        // Re-activate existing ownerships
        for (Ownership__c o : existingOwnerships){
            o.Managed__c = true;
            o.Ownership_Origination__c = String.valueOf(productMap.get(o.Honda_Product__r.Product_Identifier__c).origination);
            existingOwnershipMap.put(o.Honda_Product__r.Product_Identifier__c, o);
        }

        for (Honda_Product__c hp: hondaProducts){
            ownershipList.add(existingOwnershipMap.containsKey(hp.Product_Identifier__c) ? existingOwnershipMap.get(hp.Product_Identifier__c) : createOwnershipForHondaProduct(hp, ownerAcctId, true, false, String.valueOf(productMap.get(hp.Product_Identifier__c).origination)));
        }

        return ownershipList;
    }

    // Internal support method for Add Product methods; creates a Honda Product record from an OwnGarageController.Product object
    private static Honda_Product__c fillHondaProductFromProduct(Product prod){
        return String.isNotEmpty(prod.vin) ? new Honda_Product__c(Product_Identifier__c = prod.vin) : new Honda_Product__c();
    }

    // Internal support method for Add Product methods; creates a Honda Product record from an OwnGarageController.Product object and assigns a related Product Model and Product Model Color
    private static Honda_Product__c fillHondaProductFromProduct(Product prod, Id prodModelId, Id prodModelColorId){
        return new Honda_Product__c(Product_Identifier__c = prod.vin == '-' ? '' : prod.vin,
                                    Alternate_Product_Identifier__c = prod.modelId,
                                    Product_Models__c = prodModelId,
                                    Product_Model_Color__c = prodModelColorId);
    }

    // Internal support method for Add Product methods; creates a Honda Product record from an OwnGarageController.Product object and assigns a related Product Model
    private static Honda_Product__c fillHondaProductFromProduct(Product prod, Id prodModelId){
        return new Honda_Product__c(Product_Identifier__c = prod.vin == '-' ? '' : prod.vin,
                                    Product_Models__c = prodModelId);
    }

    // Internal support method for Add Product methods; creates a Product Model record from an OwnGarageController.Product object
    private static Product_Model__c fillProductModelFromProduct(Product prod){
        String divisionName = prod.division.containsIgnoreCase('Powersports') ? 'Motorcycle/Powersports' : prod.division;
        if (prod.color.mfg_color_cd != null){
            return new Product_Model__c(Product_Division__c = prod.divisionId,
                                        Product_Subdivision__c = prod.division,
                                        Model_Year__c = prod.year,
                                        Model_Name__c = prod.model, // Setting model name to concatenate model + trim for consistency with Product Chooser API response
                                        Trim__c = prod.trim,
                                        Product_Model_Id__c = prod.modelId);
        }
        else{ // Save Image to fields on Product Model for models that don't have MFG color code (don't have a color)
            return new Product_Model__c(Product_Division__c = prod.divisionId,
                                        Product_Subdivision__c = prod.division,
                                        Model_Year__c = prod.year,
                                        Model_Name__c = prod.model, // Setting model name to concatenate model + trim for consistency with Product Chooser API response
                                        Trim__c = prod.trim,
                                        Product_Model_Id__c = prod.modelId,
                                        Default_Large_Image_Url__c = prod.image,
                                        Default_Thumbnail_Url__c = prod.image);
        }

    }

    // Internal support method for Add Product methods; creates a Product Model Color record from an OwnGarageController.Product object
    private static Product_Model_Color__c fillProductModelColorFromProduct(Product prod){
        return new Product_Model_Color__c(  Exterior_Color_Name__c = (prod.color != null) ? prod.color.name : '',
                                            Manufacturer_Color_Code__c = (prod.color != null) ? prod.color.mfg_color_cd : '',
                                            Model_ID_Manufacture_Color_Code__c = (prod.color != null) ? prod.modelId + '_' + prod.color.mfg_color_cd : prod.modelId + '_',
                                            Thumbnail_Image_URL__c = prod.image);
    }

    // Internal support method for Add Product methods; creates a Product Model Color record from an OwnGarageController.Product object and assigns a related Product Model
    private static Product_Model_Color__c fillProductModelColorFromProduct(Product prod, Id prodModelId){
        return new Product_Model_Color__c(  Exterior_Color_Name__c = (prod.color != null) ? prod.color.name : '',
                                            Manufacturer_Color_Code__c = (prod.color != null) ? prod.color.mfg_color_cd : '',
                                            Model_ID_Manufacture_Color_Code__c = (prod.color != null) ? prod.modelId + '_' + prod.color.mfg_color_cd : prod.modelId + '_',
                                            Product_Model__c = prodModelId,
                                            Thumbnail_Image_URL__c = prod.image);
    }

    // Internal support method for Add Product methods; creates an Ownership record
    private static Ownership__c createOwnershipForHondaProduct(Honda_Product__c hp, Id personAcctId, Boolean isManaged, Boolean isVerified, String origination){
        return new Ownership__c(    Honda_Product__c = hp.Id, Product_Owner__c = personAcctId, 
                                    Managed__c = isManaged, Verified__c = isVerified, Ownership_Origination__c = origination, Ownership_Unique_ID__c = personAcctId + '~' + hp.Id);
    }

    public static Product fillProductFromVin(String vin, String divisionId){
        Product p = new Product();
        p.color = new ModelColor();
        String productFromVINstr = OwnEConfigApiHelper.getModelByVin(vin, divisionId);
        System.debug('productFromVINstr test :-  '+productFromVINstr);
        OwnEConfigApiHelper.VinDecoderResponse resp = (OwnEConfigApiHelper.VinDecoderResponse) JSON.deserialize(productFromVINstr, OwnEConfigApiHelper.VinDecoderResponse.class);
		System.debug('resp test :-  '+resp);
        p.divisionId = divisionId;
        p.year = resp.ModelDetail.year;
        p.modelId = resp.ModelDetail.modelId;
        p.model = resp.ModelDetail.modelGroupName;
        p.trim = resp.ModelDetail.trim;
        p.vin = vin;
        p.color.name = resp.ModelDetail.color.name;
        p.color.mfg_color_cd = resp.ModelDetail.color.mfg_color_cd;


        String imgURL;
        String imgURLMidsize;
        String imgURLTemp;

        // Use image with IMGMIDSIZE asset type as it is fits better into the circle; if it is not there, use the first available
        for (OwnEConfigApiHelper.ModelAsset asset : resp.ModelDetail.assets){
            if (asset.assetType == OwnEConfigApiHelper.ModelAssetType.IMGMIDSIZE){
                imgURLMidsize = asset.imagePath;
            }
            else if (!String.isEmpty(asset.imagePath)){
                imgURLTemp = asset.imagePath;
            }
        }

        imgURL = !String.isEmpty(imgURLMidsize) ? imgURLMidsize : imgURLTemp;

        p.image = imgURL;

        return p;
    }

/*     private class AddHondaProducts{
        List<Honda_Product__c> new;
        List<Honda_Product__c> existing;
    }

    private class AddProductModels{
        List<Product_Model__c> new;
        List<Product_Model__c> existing;
    }

    private class AddProductModelColors{
        List<Product_Model_Color__c> new;
        List<Product_Model_Color__c> existing;
    } */

    // Added by Alexander Dzhitenov (Wipro) for ___-____ - Method that is called from the addProduct method when the user adds a product to their garage by Product Chooser from the community site
    @AuraEnabled
    public static void addProductByYMT(Product product, Id acctId){
        System.debug(product);
        product.origination = 2;
        addProductsByYMT(new List<Product>{product}, acctId);
    }

    // Added by Alexander Dzhitenov (Wipro) for ___-____ - Method for adding products to a user's garage by Product Chooser
    public static void addProductsByYMT(List<Product> products, Id acctId){
        // 1.) Find existing records (match on ModelId / color)
        // 2.) For ModelId/Color combinations that aren't found, create new records
        // 3.) Handle association
        // 4.) Assign Ownership
        // 5.) Handle user context variables

        //Id personAcctId = [SELECT AccountId FROM User WHERE Id = :userId LIMIT 1]?.AccountId;
        Id personAcctId = acctId;
    
        Set<String> modelIdSet = new Set<String>();
        Set<String> modelId_MfgColorCodeSet = new Set<String>();
        Set<String> hpIdSet = new Set<String>();

        for (Product p : products){
            modelIdSet.add(p.modelId);
        }

        List<Product_Model__c> productModels = [SELECT Id, Product_Model_Id__c, (SELECT Id, Product_Models__r.Product_Model_Id__c, Product_Model_Color__r.Manufacturer_Color_Code__c, Product_Model_Color__r.Exterior_Color_Name__c, Product_Model_Color__r.Model_ID_Manufacture_Color_Code__c FROM Honda_Products__r WHERE Product_Identifier__c=null), (SELECT Id, Manufacturer_Color_Code__c, Exterior_Color_Name__c, Model_ID_Manufacture_Color_Code__c FROM Product_Model_Colors__r ORDER BY Manufacturer_Color_Code__c ASC) FROM Product_Model__c WHERE Product_Model_Id__c IN :modelIdSet];

        Map<String, Product_Model__c> pmMap = new Map<String, Product_Model__c>();
        Map<String, Product_Model_Color__c> pmcMap = new Map<String, Product_Model_Color__c>();
        Map<String, Honda_Product__c> hpMap = new Map<String, Honda_Product__c>();

        for (Product_Model__c pm : productModels){
            pmMap.put(pm.Product_Model_Id__c, pm);
        }

        // Assign default color (first Product Model Color for that model, ordered by Manufacturer color code ascending) for Products that do not have a color. If none are found,
        // (temporary) assign 
        for (Product p : products){
            if (p.color == null || p.color.mfg_color_cd == null){
                p.color = new ModelColor();
                p.color.mfg_color_cd = (pmMap.containsKey(p.modelId) && !pmMap.get(p.modelId).Product_Model_Colors__r.isEmpty() ) ? pmMap.get(p.modelId).Product_Model_Colors__r[0].Manufacturer_Color_Code__c : '0000000000';
                p.color.name = (pmMap.containsKey(p.modelId) && !pmMap.get(p.modelId).Product_Model_Colors__r.isEmpty() ) ? pmMap.get(p.modelId).Product_Model_Colors__r[0].Exterior_Color_Name__c : 'Default White';
            }
            // Find all colors that already exist in the database with the modelId + manufacturer color code combination of the products being added
            if (pmMap.containsKey(p.modelId)){
                for (Product_Model_Color__c pmc : pmMap.get(p.modelId).Product_Model_Colors__r){
                    if(pmc.Manufacturer_Color_Code__c == p.color.mfg_color_cd){
                        pmcMap.put(p.modelId + '_' + pmc.Manufacturer_Color_Code__c, pmc);
                        System.debug(pmcMap.values());
                    }
                }
                for (Honda_Product__c hp : pmMap.get(p.modelId).Honda_Products__r){
                    if (hp.Product_Model_Color__r.Manufacturer_Color_Code__c == p.color.mfg_color_cd){
                        hpMap.put(hp.Product_Models__r.Product_Model_Id__c + '_' + hp.Product_Model_Color__r.Manufacturer_Color_Code__c, hp);
                        hpIdSet.add(hp.Id);
                    }
                }
            }
        }
        
        List<Ownership__c> existingOwnershipsForHondaProductAndUser = [SELECT Id, Honda_Product__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c, Managed__c, Ownership_Origination__c FROM Ownership__c WHERE Managed__c = true AND Honda_Product__c IN :hpIdSet AND Product_Owner__c = :personAcctId];
        System.debug(hpIdSet);
        System.debug(personAcctId);
        System.debug('Duplicate ownerships: ');
        System.debug(existingOwnershipsForHondaProductAndUser);
        if (!existingOwnershipsForHondaProductAndUser.isEmpty()){
            throw new DuplicateException('Model already exists in garage.');
        }

        // Handle record creation and association for Products that do not have corresponding records in the database
        // This code can be modified to fit both add by VIN and add by Product Chooser
        Map<String, Honda_Product__c> newHpRecords = new Map<String, Honda_Product__c>();
        Map<String, Product_Model__c> newPmRecords = new Map<String, Product_Model__c>();
        Map<String, Product_Model_Color__c> newPmcRecords = new Map<String, Product_Model_Color__c>();

        for (Product p : products){
            if (!pmMap.containsKey(p.modelId) && !newPmRecords.containsKey(p.modelId)){
                newPmRecords.put(p.modelId, fillProductModelFromProduct(p));
            }
        }
        insert newPmRecords.values();

        for (Product p : products){
            String modelId_MfgColorCode = p.modelId + '_' + p.color.mfg_color_cd;
            if (!pmcMap.containsKey(modelId_MfgColorCode) && !newPmcRecords.containsKey(modelId_MfgColorCode)){
                newPmcRecords.put(modelId_MfgColorCode, fillProductModelColorFromProduct(p, pmMap.containsKey(p.modelId) ? pmMap.get(p.modelId).Id : newPmRecords.get(p.modelId).Id));
            }
        }
        insert newPmcRecords.values();

        for (Product p : products){
            String modelId_MfgColorCode = p.modelId + '_' + p.color.mfg_color_cd;
            if (!hpMap.containsKey(modelId_MfgColorCode) && !newHpRecords.containsKey(modelId_MfgColorCode)){ // Match with hp records by model Id + mfg color code if product has an exterior color
                newHpRecords.put(modelId_MfgColorCode, fillHondaProductFromProduct(p, pmMap.containsKey(p.modelId) ? pmMap.get(p.modelId).Id : newPmRecords.get(p.modelId).Id, pmcMap.containsKey(modelId_MfgColorCode) ? pmcMap.get(modelId_MfgColorCode).Id : newPmcRecords.get(modelId_MfgColorCode).Id));
            }
        }
        system.debug('as '+newHpRecords);
        insert newHpRecords.values();


        List<Ownership__c> ownerships = [SELECT Id, Honda_Product__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c, Managed__c FROM Ownership__c WHERE Managed__c = false AND Honda_Product__c IN :hpIdSet AND Product_Owner__c = :personAcctId];

        Map<String, Ownership__c> ownershipMap = new Map<String, Ownership__c>();

        for (Ownership__c o : ownerships){
            ownershipMap.put(o.Honda_Product__r.Product_Models__r.Product_Model_Id__c + '_' + o.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c, o);
        }

        List<Ownership__c> ownershipsChange = new List<Ownership__c>();

        // Set up modelId_MfgColorCode - OriginationCode map
        Map<String, String> mimccMap = new Map<String, String>();
        for (Product p : products){
            mimccMap.put(p.modelId + '_' + p.color.mfg_color_cd, String.valueOf(p.origination));
        }

        for (String mimcc : hpMap.keySet()){
            Honda_Product__c hp = hpMap.get(mimcc);
            //String mimcc = hp.Product_Models__r.Product_Model_Id__c + '_' + hp.Product_Model_Color__r.Manufacturer_Color_Code__c; // ModelId_ManufacturerColorCode
            System.debug('mimcc: ' + mimcc);
            String origination = mimccMap.get(mimcc);
            System.debug('origination code: ' + origination);
            if (ownershipMap.containsKey(mimcc)){
                Ownership__c o = ownershipMap.get(mimcc);
                o.Managed__c = true;
                o.Ownership_Origination__c = origination;
                ownershipsChange.add(o);
            }
            else{
                ownershipsChange.add(createOwnershipForHondaProduct(hp, personAcctId, true, false, origination));
            }
        }
        for (String mimcc : newHpRecords.keySet()){
            Honda_Product__c hp = newHpRecords.get(mimcc);
            //String mimcc = hp.Product_Models__r.Product_Model_Id__c + '_' + hp.Product_Model_Color__r.Manufacturer_Color_Code__c; // ModelId_ManufacturerColorCode
            String origination = mimccMap.get(mimcc);
            ownershipsChange.add(createOwnershipForHondaProduct(hp, personAcctId, true, false, origination));
        }

        System.debug(ownershipsChange);

        upsert ownershipsChange;

        updateContextUser(!newHpRecords.isEmpty() ? newHpRecords.values()[0].Id : hpMap.values()[0].Id, 'Overview');
    }

    /* @AuraEnabled
    @Future(callout=true)
    public static void getUserVehiclesFromAPI_async(Id userId){
        getUserVehiclesFromAPI(userId);
    }

    @AuraEnabled
    public static void getUserVehiclesFromAPI(Id userId){
        System.debug('Cache');
        Cache.SessionPartition garageCache = Cache.Session.getPartition('local.MyGarage');
        System.debug(garageCache.get('local.UserLogin.loginOperation'));
        User u = [SELECT AccountId, Email, FederationIdentifier FROM User WHERE Id=:userId LIMIT 1];
        String userEmail = u.Email;
        Id personAcctId = u.AccountId;
        //userEmail = 'BAILEY.CRYSTAL1902@YAHOO.COM';
        Set<vinDetails> vins = OwnConsumerProfileService.getUserVins(u.FederationIdentifier);
        Set<String> vinSet = new Set<String>();
        for (vinDetails vin : vins){
            vinSet.add(vin.vin);
        }
        Set<String> vinRemoveSet = new Set<String>();
        //Set<vinDetails> addVinSet = new Set<OwnConsumerProfileService.vinDetails>();
        //addVinSet.addAll(vins);
        List<Ownership__c> existingOwnerships = [SELECT Id, Honda_Product__r.Product_Identifier__c, Managed__c FROM Ownership__c WHERE Honda_Product__r.Product_Identifier__c IN :vinSet AND Product_Owner__c = :personAcctId];
        for (Ownership__c o : existingOwnerships){
            if (o.Managed__c){
                vinRemoveSet.add(o.Honda_Product__r.Product_Identifier__c);
            }
        }
        for (vinDetails vin : vins){
            if (vinRemoveSet.contains(vin.vin)){
                vins.remove(vin);
            }
        }

        List<Product> productsFromAPI = new List<Product>();

        for (vinDetails vin : vins){
            OwnMyVehicleApiHelper.MyVehicleResult result = OwnMyVehicleApiHelper.getProductDetails(vin.divisionId, vin.vin);
            if (result.status == 'SUCCESS'){
                productsFromAPI.addAll(result.products);
                System.debug(JSON.serialize(result.products));
            }
        }
        if (!productsFromAPI.isEmpty()){
            addProductsByVIN(productsFromAPI, userId);
        }
    } */

/*     public static void getUserVins(String userEmail){
        Set<String> userVins = new Set<String>();
        OwnConsumerProfileService.ConsumerProfileSOAP consumerProfileService = new OwnConsumerProfileService.ConsumerProfileSOAP();
        consumerProfileService.HondaMsgHeader = new OwnConsumerProfileService.hondaMsgHeaderType();
        consumerProfileService.HondaMsgHeader.messageId = '207e19bb-189b-4079-b6e2-0ef259bed267';
        consumerProfileService.HondaMsgHeader.siteId = '7a075db5b4b04c04afdc0b75fc135a80';
        consumerProfileService.HondaMsgHeader.businessId = 'HONDALINK CONNECT';
        consumerProfileService.HondaMsgHeader.collectedTimestamp = '2020-11-30T09:55:29+00:00'; */
/*         consumerProfileService.clientCertName_x = 'service_ecrm_b2c';
        consumerProfileService.clientCertPasswd_x = 'h0nd938jdUd1a'; */

        //consumerProfileService.clientCertName_x = 'Consumer_Profile_Service_Test';
/* 
        Blob headerValue = Blob.valueOf('service_ecrm_b2c' + ':' + 'h0nd938jdUd1a');
        String authorizationHeader = 'BASIC '+ EncodingUtil.base64Encode(headerValue);
        consumerProfileService.inputHttpHeaders_x = new Map<String, String>();
        consumerProfileService.inputHttpHeaders_x.put('Authorization', authorizationHeader);
        consumerProfileService.inputHttpHeaders_x.put('Content-Type', 'text/xml'); */

/*         consumerProfileService.inputHttpHeaders_x = new Map<String, String>();
        consumerProfileService.inputHttpHeaders_x.put('Authorization', 'BASIC service_ecrm_b2c:h0nd938jdUd1a');
        consumerProfileService.inputHttpHeaders_x.put('Content-Type', 'text/xml'); */
/* 
        try{
            OwnConsumerProfileService.ConsumerProfileResp userDetails = consumerProfileService.GetConsumerProfileByEmail(userEmail);
            for (OwnConsumerProfileService.ConsumerProfile userProfile : userDetails.ConsumerProfiles){
                for (OwnConsumerProfileService.OwnedProductInfo userOwnedProduct : userProfile.CurrentlyOwnedProducts){
                    userVins.add(userOwnedProduct.ProductID);
                }
                for (OwnConsumerProfileService.ServicedProductInfo userServicedProduct : userProfile.CurrentlyServicedProducts){
                    userVins.add(userServicedProduct.ProductID);
                }
            }
            System.debug(JSON.serialize(userVins));
        }
        catch (Exception e){
            System.debug(e.getMessage());
        }
        //System.debug(JSON.serialize(userDetails));
        //consumerProfileService.GetConsumerProfile(159464314, 'BAILEY.CRYSTAL1902@YAHOO.COM', '3CZRM3H59FG701101', '15875084');

        return userVins;
    } */

    
    @AuraEnabled
    public static Boolean checkFirstTimeUser(){
        User u = [SELECT Id, Last_Visited_Product_Tab__c FROM User WHERE Id=:UserInfo.getUserId()];

        if (u.Last_Visited_Product_Tab__c == 'First-time user'){
            return true;
        }
        else{
            return false;
        }
    }

    @AuraEnabled
    public static LoginHandlerWrapper handleUserLogin(Boolean isFirstTimeUser){
        System.debug('HandleUserLogin');
        Id userId = userInfo.getUserId();

        User u = [SELECT Last_Visited_Product_Id__c FROM User WHERE Id=:userID];

        String lastVisitedProductId = u.Last_Visited_Product_Id__c;

        LoginHandlerWrapper redirectObject = new LoginHandlerWrapper();

        if (isFirstTimeUser){
            // First-time login sequence
            System.debug('First-time login sequence');
            redirectObject = handleUserLoginProducts(userId);
            resetUserLastVisitedProductTab(userId);
        }
        else{
            // Returning user login sequence
            System.debug('Returning user login sequence');
            handleUserLoginProducts_async(userId);
        }

        Id landingProductId;

        System.debug('Login Controller: user ownerships:');
        /* System.debug(userOwnerships); */

        String destinationPage = 'garage';

        if (isFirstTimeUser && redirectObject.hasProducts){
            // New user with connected/ECRM products—set most recent product ID, redirect to that product's garage page
            System.debug('Setting most recent product');
            if (redirectObject.userOwnerships.size() > 0){
                landingProductId = redirectObject.userOwnerships[0].Honda_Product__c;
            }
            else{
                landingProductId = lastVisitedProductId;
            }
            redirectObject.destinationPage = 'garage';
        }
        else if (isFirstTimeUser && !redirectObject.hasProducts){
            // New user & no local/connected products—no product ID can be set, redirect to home page
            landingProductId = lastVisitedProductId;
            redirectObject.destinationPage = 'main';
        }
        else{
            // Returning user—keep last visited product ID
            System.debug('Setting last visited product');
            landingProductId = lastVisitedProductId;
            redirectObject.destinationPage = 'garage';
        }

        updateContextUser(landingProductId, 'Overview');
        //String lastVisitedProductDivisionId = [SELECT Product_Models__r.Product_Division__c FROM Honda_Product__c WHERE Id=:landingProductId].Product_Models__r.Product_Division__c;
        //List<Ownership__c> oList = [SELECT Id, Honda_Product__c, Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Trim__c, Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c];
        
        /* if (isFirstTimeUser){
            redirectObject.contextProduct = OwnContextController.getContext(landingProductId);
            redirectObject.garageProducts = OwnGarageController.getGarage('');
        } */
        redirectObject.garage = OwnGarageController.getGarage('');
        if (redirectObject.garage.products.size() > 0){
            redirectObject.hasProducts = true;
        }
        
        System.debug('RETURNING FROM LOGIN SEQUENCE: ' + redirectObject);

        return redirectObject;
    }

    @Future(callout=true)
    private static void handleUserLoginProducts_async(Id userId){
        handleUserLoginProducts(userId);
    }

    @Future
    private static void resetUserLastVisitedProductTab(Id userId){
        User u = new User(Id=userId, Last_Visited_Product_Tab__c=null);
        update u;
    }

    // Added by Alexander Dzhitenov for Login sequence; replaces getUserVehiclesFromAPI
    private static LoginHandlerWrapper handleUserLoginProducts(Id userId){

        //Id userId = userInfo.getUserId();

        User u = [SELECT Id, AccountId, Email, FederationIdentifier FROM User WHERE Id=:userId LIMIT 1];
        String userEmail = u.Email;
        Id personAcctId = u.AccountId;
        String eUserIdent = u.FederationIdentifier;

        System.debug('eUserIdent: ' + u.FederationIdentifier);

        // Return object
        LoginHandlerWrapper userRedirectObject = new LoginHandlerWrapper();

        /* if (u.Last_Visited_Product_Tab__c == 'First-time user'){
            u.Last_Visited_Product_Tab__c = null;
            update u;
        } */

        // Obtain ECRM/connected VINs
        List<Product> myVehiclesProducts = new List<Product>();
        Map<VinDetails, Product> connectedVINs = new Map<VinDetails, Product>();

        OwnMyVehicleApiHelper.MyVehicleResult result = OwnMyVehicleApiHelper.getAllUserVehicles();
        System.debug(result.status);
        if (result.status == 'SUCCESS'){
            myVehiclesProducts = result.products;
        }

        System.debug('MyVehicles Callout Results:');
        System.debug(myVehiclesProducts);
        System.debug(myVehiclesProducts.size());
        for (Product p : myVehiclesProducts){
            //DEBUG CODE
            if (p.vin == '19UUB1F34FA009551'){
                System.debug('TEST VIN FOUND; IN myVehiclesProducts');
            }
            //
            connectedVINs.put(new VinDetails(p.vin, p.divisionId), p);
        }
        //DEBUG CODE
        /* List<VinDetails> connectedVINsDebug = new List<VinDetails>();
        connectedVINsDebug.addAll(connectedVINs); */
        for (VinDetails v : connectedVINs.keySet()){
            if (v.vin == '19UUB1F34FA009551'){
                System.debug('TEST VIN FOUND; IN connectedVINs');
            }
        }
        //

        Set<VinDetails> ecrmVINs = OwnConsumerProfileService.getUserVins(eUserIdent);

        Set<VinDetails> externalVINList = new Set<VinDetails>();
        externalVINList.addAll(connectedVINs.keySet());
        externalVINList.addAll(ecrmVINs);

        /////Obtain VINs from Salesforce/////
        Map<VinDetails, Ownership__c> localVINs = new Map<VinDetails, Ownership__c>();
        List<Ownership__c> allUserProducts = [SELECT Id, Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c, 
                                                        Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c,
                                                        Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Model_Name__c, Managed__c FROM Ownership__c WHERE Product_Owner__c = :personAcctId];
        
        List<Ownership__c> userVinProducts = new List<Ownership__c>();
        List<Product> userProductsRecallsList = new List<Product>();

        for (Ownership__c o : allUserProducts){
            if (o.Honda_Product__r.Product_Identifier__c != null){
                localVINs.put(new VinDetails(o.Honda_Product__r.Product_Identifier__c, o.Honda_Product__r.Product_Models__r.Product_Division__c), o);
            }
            if (o.Managed__c){
                Product p = new Product();
                p.modelId = o.Honda_Product__r.Product_Models__r.Product_Model_Id__c;
                p.vin = o.Honda_Product__r.Product_Identifier__c;
                p.divisionId = o.Honda_Product__r.Product_Models__r.Product_Division__c;
                p.year = o.Honda_Product__r.Product_Models__r.Model_Year__c;
                p.model = o.Honda_Product__r.Product_Models__r.Model_Name__c;
                p.ownershipId = o.Id;
                userProductsRecallsList.add(p);   
            }
        }

        /* for (Ownership__c o : userProducts){
            localVINs.put(new VinDetails(o.Honda_Product__r.Product_Identifier__c, o.Honda_Product__r.Product_Models__r.Product_Division__c), o);
        } */
        /////End obtain VINs from Salesforce/////

        // connectedVINs    - Map<VinDetails, Product>, stores VIN info (VIN + divisionId) mapped to Product data for each product retrieved from the Connected API
        // ecrmVINs         - Set<VinDetails> storing VINs retrieved from ECRM
        // externalVINList  - Set<VinDetails> storing all VINs retrieved from external APIs
        // localVINs        - Map<VinDetails, Ownership__c> storing VIN info mapped to corresponding User ownership for the current user & VIN from SFDC

        Set<VinDetails> allVINs = new Set<VinDetails>();
        allVINs.addAll(externalVINList);
        allVINs.addAll(localVINs.keySet());

        System.debug('Connected VINs');
        System.debug(connectedVINs.keySet());
        System.debug('ECRM VINs');
        System.debug(ecrmVINs);
        System.debug('Local VINs:');
        System.debug(localVINs);

        // User has no VINs in their local garage, or in the ECRM or Connected APIs—no further processing to be done, return to site & redirect to main page
        if (allVINs.isEmpty()){
            //LoginHandlerWrapper userRedirectObject = new LoginHandlerWrapper();
            userRedirectObject.productId = '';
            userRedirectObject.hasProducts = false;
            return userRedirectObject;
        }

        List<Product> externalProducts = new List<Product>();
        Set<Id> sendToMyVehiclesOwnershipIds = new Set<Id>();
        Set<VinDetails> vinRemoveSet = new Set<VinDetails>();

        Map<VinDetails, Product> allUserProductsMap = new Map<VinDetails, Product>();

        /* System.debug('All VINs:');
        System.debug(allVINs); */

        /////VIN processing Loop/////
        for (VinDetails vin : allVINs){
            // Add VINs that are not present in SFDC using addProductsByVIN method


            System.debug('Running VIN loop for VIN: ' + vin);

            OwnEConfigApiHelper.ECRMResult apiResult = new OwnEConfigApiHelper.ECRMResult();
            if (vin.vin != null && vin.divisionId != null && (vin.divisionId != 'P' && vin.divisionId != 'PE')){
                apiResult = OwnEConfigApiHelper.getGarageProductFromECRM(vin.vin, vin.divisionId);
            }
            else{
                apiResult.isError = true;
            }

            //OwnEConfigApiHelper.ECRMResult apiResult = OwnEConfigApiHelper.getGarageProductFromECRM(vin.vin, vin.divisionId);
            System.debug(apiResult.isError);
            System.debug(apiResult.product);
            Product product = new Product();
            Boolean productDetailsFound = !apiResult.isError;
            if (productDetailsFound){
                product = apiResult.product;
                if (connectedVINs.containsKey(vin)){
                    product.origination = 22;
                }
                else if (ecrmVINs.contains(vin)){
                    product.origination = 21;
                }
                else if (localVINs.containsKey(vin)){
                    product.origination = 3;
                }
            }

            System.debug('Is in local VINs: ' + localVINs.containsKey(vin));
            System.debug(localVINs.keySet());
            if (!localVINs.containsKey(vin) && productDetailsFound){
                    /* System.debug('External product: ');
                    System.debug('vin: ' + externalProduct.vin);
                    System.debug('divisionId: ' + externalProduct.divisionId);
                    System.debug('division: ' + externalProduct.division);
                    System.debug('year: ' + externalProduct.year);
                    System.debug('modelId: ' + externalProduct.modelId);
                    System.debug('model: ' + externalProduct.model);
                    System.debug('trim: ' + externalProduct.trim);
                    System.debug('color: ' + externalProduct.color); */
                    externalProducts.add(product);
            }
            // If a local product is missing from Connected, send its data to Connected
            // If product is PE or Marine, do not send to Connected.
            else if (localVINs.containsKey(vin) && !connectedVINs.containsKey(vin) && vin.divisionId != 'P' && vin.divisionId != 'M'){
                sendToMyVehiclesOwnershipIds.add(localVINs.get(vin).Id);
            }
            // If a product is not managed, remove it from the list of all VINs
            else if (localVINs.containsKey(vin) && !localVINs.get(vin).Managed__c){
                vinRemoveSet.add(vin);
            }

            if (productDetailsFound){
                allUserProductsMap.put(vin, product);
            }
        }
        /////End VIN processing Loop/////

        // allVINs is now the final list of products
        allVINs.removeAll(vinRemoveSet);
        List<VinDetails> allVINsList = new List<VinDetails>();
        allVINsList.addAll(allVINs);

        //DEBUG CODE
        for (VinDetails vin : allUserProductsMap.keySet()){
            System.debug('PRODUCT: ');
            System.debug(allUserProductsMap.get(vin));
        }
        //

        /////Send data to MyVehicles API/////
        if (sendToMyVehiclesOwnershipIds.size() > 0){
            OwnMyVehicleApiHelper.sendToMyVehicles(sendToMyVehiclesOwnershipIds);
        }
        /////End send data to MyVehicles API/////


        userProductsRecallsList.addAll(externalProducts); // Contains all Managed products already in user's garage, as well as all products from MyVehicles and getConsumerProfile that will be added to the user's garage
        
        // Temporary R2 code - remove for R3
        /* List<Product> userProductsRecallsList2 = new List<Product>();
        for (Product p : userProductsRecallsList){
            if (p.divisionId != 'A' && p.divisionId != 'B'){
                userProductsRecallsList2.add(p);
            }
        } */

        /////Recalls API Callout/////
        // Obtain recall Message__c object for each VIN already in user's garage, and each VIN that will be added
        Map<String, OwnRecallsController.RecallObject> recallsMap = new Map<String, OwnRecallsController.RecallObject>();
        Boolean recallCalloutError;
        try{
            recallsMap = OwnRecallsController.getRecallData(userProductsRecallsList, personAcctId);
            recallCalloutError = false;
        }
        catch(Exception e){
            System.debug('Recalls callout error: ' + e.getMessage());
            recallCalloutError = true;
        }

        for (String s : recallsMap.keySet()){
            System.debug(recallsMap.get(s));
        }
        /////End Recalls API Callout/////

        /////Add products to user's garage/////
        List<Ownership__c> newUserOwnerships = new List<Ownership__c>();
        if (externalProducts.size() > 0){
            // Debug code:
            System.debug('Calling add products with list:');
            for (Product p : externalProducts){
                System.debug(p);
                if (p.vin == '19UUB1F34FA009551'){
                    System.debug('TEST VIN FOUND; IN externalProducts');
                }
            }
            String vinTestStr;
            for (Product p : externalProducts){
                vinTestStr += p.vin + ', ';
            }
            System.debug('VINS: ' + vinTestStr);
            //

            try{
                newUserOwnerships = addProductsByVIN(externalProducts, personAcctId);
            }
            catch(Exception e){
                // Duplicate VIN exception does not need to be handled here, as it was not intended for this sequence.
            }
        }
        /////End add products to user's garage/////


        for (VinDetails removeVin : vinRemoveSet){
            allUserProductsMap.remove(removeVin);
        }

        if (newUserOwnerships.size() > 0){
            userRedirectObject.productId = newUserOwnerships[0].Honda_Product__c;
        }
        else{
            System.debug('No products added.');
        }
        userRedirectObject.userOwnerships = newUserOwnerships;
        userRedirectObject.hasProducts = true;

        try{
            OwnRecallsController.saveAndDeleteRecallsData(recallsMap, personAcctId);
            userRedirectObject.recallsLoaded = true;
        } catch(Exception e){
            userRedirectObject.recallsLoaded = false;
        }

        //userRedirectObject.recallsLoaded = false;


        return userRedirectObject;

        //Cache.SessionPartition myGarageCache = Cache.Session.getPartition('local.MyGarage');
        //myGarageCache.put('garage', allUserProductsMap.values());

        // Get recall information for all products in allVINs

        // Save OwnGarageController.Product for all vins in allVINs to session cache (MyGarage Partition)

        // Check whether or not each connected/ECRM VIN exists in SFDC; if not, add it
        // For SFDC VINs that are also present in Connected VINs, check whether or not there are any updates from the Connected API
        /* List<Product> addExternalProducts = new List<Product>();
        for (VinDetails externalVIN : externalVINList){
            if (!localVINs.containsKey(externalVIN)){
                addExternalProducts.add(OwnEConfigApiHelper.getGarageProductFromECRM(externalVIN.vin, externalVIN.divisionId));
            }
        }

        addProductsByVIN_async(JSON.serialize(addExternalProducts), u.Id);

        // If a local product is missing from Connected, send its data to Connected
        Set<VinDetails> checkForUpdatesVINs = new Set<VinDetails>();

        Set<Id> sendToMyVehiclesOwnershipIds = new Set<Id>();
        for (VinDetails localVIN : localVINs.keySet()){
            if (!connectedVINs.containsKey(localVIN)){
                sendToMyVehiclesOwnershipIds.add(localVINs.get(localVIN).Id);
            }
        }
        // Method is asynchronous
        OwnMyVehicleApiHelper.sendToMyVehicles(sendToMyVehiclesOwnershipIds); */

        /* List<Schema.SObjectField> ownershipComparFieldsList          = new List<Schema.SObjectField>{Ownership__c.Nickname__c, Ownership__c.License_Plate_Number__c};
        List<Schema.SObjectField> productModelCompareFieldsList      = new List<Schema.SObjectField>{Product_Model__c.Model_Year__c, Product_Model__c.Model_Name__c, Product_Model__c.Trim__c, Product_Model__c.Product_Model_Id__c};
        List<Schema.SObjectField> productModelColorCompareFieldsList = new List<Schema.SObjectField>{Product_Model_Color__c.Exterior_Color_Name__c, Product_Model_Color__c.Manufacturer_Color_Code__c, Product_Model_Color__c.Thumbnail_Image_URL__c}; */


        // NEED CLARIFICATION ON WHETHER OR NOT AUTOMATICALLY ADDING VIN TO MATCHING YMT PRODUCTS SHOULD HAPPEN ANYTIME THE USER ADDS A PRODUCT


        // Update user products if connected data differs
        // Which fields should be updated based on connected VIN data?
    }

    /* private static VehicleInfo checkProductChanges(Product pExternal, Ownership__c oLocal, List<Schema.SObjectField> ownershipComparFieldsList, List<Schema.SObjectField> productModelCompareFieldsList, List<Schema.SObjectField> productModelColorCompareFieldsList){
        Honda_Product__c externalProduct = fillHondaProductFromProduct(pExternal);
        Product_Model__c externalProductModel = fillProductModelFromProduct(pExternal);
        Product_Model_Color__c externalProductModelColor = fillProductModelColorFromProduct(pExternal);

        Honda_Product__c localProduct = oLocal.Honda_Product__r;
        Product_Model__c localProductModel = oLocal.Product_Model__r;
        Product_Model_Color__c localProductModelColor = oLocal.Product_Model_Color__r;

        Product_Model__c updateProduct 
    } */

    //private static Product

    public class VehicleInfo{
        public Honda_Product__c hp;
        public Product_Model__c pm;
        public Product_Model_Color__c pmc;
        public Ownership__c o;
    }

    public class VinDetails{
        public String vin;
        public String divisionId;

        public VinDetails(String vin, String divisionId){
            this.divisionId = divisionId;
            this.vin = vin;
        }
        public Boolean equals(Object obj){
            if (obj instanceof VinDetails){
                VinDetails vCompare = (VinDetails) obj;
                return ( (vCompare.vin==this.vin) && (vCompare.divisionId==this.divisionId) ) ? true : false;
            }
            else{
                return false;
            }
        }
        public Integer hashCode(){
            return (this.vin + this.divisionId).hashCode();
        }
    }

    public class LoginHandlerWrapper {
        @AuraEnabled public String productId;
        @AuraEnabled public List<Ownership__c> userOwnerships;
        @AuraEnabled public Boolean hasProducts;
        @AuraEnabled public String destinationPage;
        @AuraEnabled public Garage garage;
        @AuraEnabled public OwnContextController.Context contextProduct;
        @AuraEnabled public Boolean recallsLoaded;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCurrentOfferLinks(){
        return (Map<String, Object>)JSON.deserializeUntyped(Label.Current_Offers);
    }

    @AuraEnabled(cacheable=true)
    public static List<Marketplace_URL__mdt> getCustomMetadataTypes(){
        return [ SELECT Id, DeveloperName, Accessories_Logged_In_URL__c, Accessories_Logged_Out_URL__c, Parts_Logged_In_URL__c, Parts_Logged_Out_URL__c
                 FROM Marketplace_URL__mdt ];
    }
 
    @AuraEnabled(cacheable=true)
    public static List<Finance_SSO__mdt> getCustomMetadataType(){
        return [ SELECT Id, DeveloperName, 	Brand__c, Guest_Link__c, Login_Link__c
                 FROM Finance_SSO__mdt ];
    }

    /* private class ProductOriginWrapper{
        private Product product;
        private String origination;

        public Product(Product p, String o){
            this.product = p;
            this.origination = o;
        }
        public Product(){}
    } */
    
    @AuraEnabled(cacheable=true)
    public static List<OwnPowerEquipmentDealerAttribute__mdt> getPowerequipmentProductAttributes(){
        return [ SELECT Id, MasterLabel, DeveloperName, Code__c, Sort__c
                 FROM OwnPowerEquipmentDealerAttribute__mdt ORDER BY Sort__c ASC];
    }

    @AuraEnabled
    public static List<Ownership__c> getRadioNaviCode(String ownershipId){
        return [ SELECT Id, Name, Radio_Code__c, Navi_Code__c
                 FROM Ownership__c WHERE Id =:ownershipId LIMIT 1];
    }
    public static Integer getFamilyField(){
        Product_Chooser_Control__c productChooserControl = [SELECT Tier_Number__c FROM Product_Chooser_Control__c Where Tier_Name__c = 'Family' LIMIT 1];
        return Integer.valueOf(productChooserControl.Tier_Number__c);
    }
    
    @AuraEnabled (cacheable = true)
    public static string getFamilyValue(String modelId){
        Map<Integer, String> tierFiledMap = new Map<Integer, String>{1 => 'Tier1__c', 2 => 'Tier2__c', 3 => 'Tier3__c', 4 => 'Tier4__c', 5 => 'Tier5__c', 6 => 'Tier6__c'};
            String family = '';
        if(String.isNotBlank(modelId)){
            List<Product_Chooser__c> productChoosers = [SELECT Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c FROM Product_Chooser__c 
                                                        where Product_Model__r.Product_Model_ID__c =:modelId ];
            if(productChoosers.size() > 0){
                Product_Chooser__c productChooser = productChoosers[0];
                family = String.valueOf(productChooser.get(tierFiledMap.get(getFamilyField())));
            }
        }
        return family;
    }
    public static Integer getCategoryField(){
        Product_Chooser_Control__c productChooserControl = [SELECT Tier_Number__c FROM Product_Chooser_Control__c Where Tier_Name__c = 'Category' LIMIT 1];
        return Integer.valueOf(productChooserControl.Tier_Number__c);
    }
    
    @AuraEnabled (cacheable = true)
    public static string getCategoryValue(String modelId){
        Map<Integer, String> tierFiledMap = new Map<Integer, String>{1 => 'Tier1__c', 2 => 'Tier2__c', 3 => 'Tier3__c', 4 => 'Tier4__c', 5 => 'Tier5__c', 6 => 'Tier6__c'};
            String category = '';
        if(String.isNotBlank(modelId)){
            List<Product_Chooser__c> productChoosers = [SELECT Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c FROM Product_Chooser__c 
                                                        where Product_Model__r.Product_Model_ID__c =:modelId ];
            if(productChoosers.size() > 0){
                Product_Chooser__c productChooser = productChoosers[0];
                category = String.valueOf(productChooser.get(tierFiledMap.get(getCategoryField())));
            }
        }
        return category;
    }
}
//****************************************************************************** 
// File Name:       OwnProductController.cls
// Summary:         Apex Class for Garage
// Created On:      11-11-2021
// Created By:      Arunprasad N (Wipro)
// Test Classes:    OwnProductControllerTest.cls
// Data I/O:        
// Honda Jira Story: Apex class for Product for Honda Owner Experience
//===============================================================================
// Modification Log: 
// November 11, 2021 Arunprasad N (Wipro) initial coding
// December 16, 2021 Alex Dzhitenov Changed references to several Honda Product fields to references to 
//                                   Product Model and Product Model Color fields (DOE-3220)
//*******************************************************************************
public without sharing class OwnProductController {

    public OwnProductController() {

    }

    private static String personAccountId(){
        return [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]?.AccountId;
    }

    @AuraEnabled (cacheable = true) 
    public static String getHondaProductID(String productIdentifier){
        return [SELECT Id FROM Honda_Product__c WHERE Product_Identifier__c = :productIdentifier LIMIT 1]?.Id;
    }

    //====================
    //= Public: Get Tabs()
    //====================
    @AuraEnabled (cacheable = true) 
    public static List<String> getProductTabs() {
        List < String > tabs = new List < String > ();
        for (OwnProductTab__mdt tab : [
            SELECT MasterLabel, DeveloperName, Sort__c 
            FROM OwnProductTab__mdt
            //WHERE MasterLabel = 'Connected Features' OR MasterLabel = 'Overview' //DOE-4256  ( added this line for Release 1 - Details: Hiding tabs )
            ORDER BY Sort__c ASC
            LIMIT 10000
        ]) {
            tabs.add(tab.MasterLabel);
        }
        return tabs;
    
    }  // end GetTabs()

    //====================
    //= Public: Get()
    //====================
    @AuraEnabled
    public static Context getProductContext(String productId){
        try {
            Context finalContext = read_ProductContextRecord(productId);
            return finalContext;
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getLineNumber());
        }
    } // end OwnContext()

    //====================
    //= Internal Support Methods
    //====================
    private static Context read_ProductContextRecord(String productId){
        String accountId = personAccountId();
        Context context;
        User u = 
            [Select Id,
             FirstName,
             Last_Visited_Product_ID__c,
             Last_Visited_Product_Tab__c 
             FROM    User  
             WHERE   Id = :UserInfo.getUserId()];
        
        if(u != null){
            if(String.isEmpty(ProductId)){
                productId = u.Last_Visited_Product_ID__c;
            }
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            // Fields have been removed from Honda Product; most values are now accessed through Product Model and Product Model Color
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            List<Product> products = new List<Product>();
            // Alexander Dzhitenov (Wipro) - Removed Product_Model__c field (lookup to Vehicle__c object) from query
            // Alexander Dzhitenov (Wipro): Added recalls to product query
            Id recallRecordTypeId = Schema.SObjectType.Message__c.getRecordTypeInfosByDeveloperName().get('Recall').getRecordTypeId();
            String queryString = 'SELECT Id, Honda_Product__c, License_Plate_Number__c, License_Plate_State_Name__c, Nickname__c, Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c, Honda_Product__r.Product_Identifier__c, (Select Name from Subscriptions__r), Honda_Product__r.Product_Model_Color__r.Large_Image_URL__c, Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Customer_Uploaded_Image__c,Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c, Honda_Product__r.Product_Models__r.Default_Thumbnail_Url__c ';
            queryString += ', (SELECT Id FROM Owner_Messages__r WHERE Message__r.RecordTypeId=:recallRecordTypeId) ';
            queryString += 'FROM Ownership__c ';
            queryString += 'WHERE ';
            queryString += 'Honda_Product__c = :productId ';
            queryString += 'AND Product_Owner__c = :accountId ';
            //queryString += 'WITH SECURITY_ENFORCED ';
            String safeQueryString = String.escapeSingleQuotes(queryString);
            List<Ownership__c> ownerships = Database.query(safeQueryString);
            for (Ownership__c ownership :ownerships) {
                Product productObj = new Product();
                productObj.productId = ownership.Honda_Product__c;
                productObj.ownershipId = ownership.Id;
                productObj.exteriorColor = ownership.Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c;
                //productObj.productModelId = ownership.Honda_Product__r.Product_Model__c;
                productObj.nickname = ownership.Nickname__c;
                productObj.divisionId = ownership.Honda_Product__r.Product_Models__r.Product_Division__c;
                productObj.division = ownership.Honda_Product__r.Product_Models__r.Product_Subdivision__c;
                productObj.year = String.isNotEmpty(ownership.Honda_Product__r.Product_Models__r.Model_Year__c) ? ownership.Honda_Product__r.Product_Models__r.Model_Year__c : '';
                productObj.modelId = ownership.Honda_Product__r.Product_Models__r.Product_Model_Id__c;
                productObj.model = ownership.Honda_Product__r.Product_Models__r.Model_Name__c;
                productObj.trim = ownership.Honda_Product__r.Product_Models__r.Trim__c;
                productObj.vin = ownership.Honda_Product__r.Product_Identifier__c;
                productObj.productIdentifier = ownership.Honda_Product__r.Product_Identifier__c;
                productObj.isDefault = true;
                productObj.customerUploadedImage = ownership.Customer_Uploaded_Image__c;
                productObj.division = String.isBlank(productObj.division) ? productObj.divisionId == 'A' ? 'Honda' : productObj.divisionId == 'B' ? 'Acura' : productObj.division : productObj.division;
                productObj.image = String.isNotBlank(productObj.division) ? '/resource/MyGarage/images/thumbnail_' + productObj.division.toLowerCase() + '.png' : '';
                //productObj.image = '/resource/Owners/images/garage_hondadefault.svg';
                productObj.licenseNumber = ownership.License_Plate_Number__c;
                productObj.licenseState = ownership.License_Plate_State_Name__c;
                productObj.activeSubscription = ownership.subscriptions__r;
                productObj.productDefaultImage = ownership.Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c != null ? ownership.Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c : ownership.Honda_Product__r.Product_Models__r.Default_Thumbnail_Url__c; //Using thumbnail for now, since IMGMIDSIZE type images work better for the circular image display
               // productObj.productDefaultImage = ownership.Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c; 
                productObj.recallCount = 0;
                for (Owner_Message__c recallMessage : ownership.Owner_Messages__r){
                    productObj.recallCount++;
                }
                products.add(productObj);
            }
            if(!products.isEmpty()){
                context = new Context(u, products[0]);
            }
        }
        return context;
        
    } // end readOrInsert_ContextRecord()

    //====================
    //= Public: populate My Products by Product Id
    //====================
    @AuraEnabled (cacheable = true) 
    public static MyProducts getMyProducts(String productId){
        try {
            return UserInfo.getUserType() != 'Guest' ? new MyProducts(queryProducts(productId)) : new MyProducts();
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } // end getMyProducts()

    //====================
    //= populate My Products
    //====================
    private static List<Product> queryProducts(String productId) { 
        String accountId = personAccountId();
        List<Product> products = new List<Product>();
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Fields have been removed from Honda Product; most values are now accessed through Product Model and Product Model Color
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // Alexander Dzhitenov (Wipro) - Removed Product_Model__c field (lookup to Vehicle__c object) from query
        String queryString = 'SELECT Id, Honda_Product__c, Nickname__c, Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c, Honda_Product__r.Product_Identifier__c, Customer_Uploaded_Image__c, Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c ';
        queryString += 'FROM Ownership__c ';
        queryString += 'WHERE Managed__c = true AND ';
        queryString += String.isNotEmpty(productId) ? 'Honda_Product__c = :productId ' : 'Product_Owner__c = :accountId ';
        //queryString += 'WITH SECURITY_ENFORCED ';
        queryString += 'ORDER BY LastModifiedDate DESC ';
        queryString += 'LIMIT 100';
        String safeQueryString = String.escapeSingleQuotes(queryString);
        List<Ownership__c> ownerships = Database.query(safeQueryString);
        for (Ownership__c ownership :ownerships) {
            Product productObj = new Product();
            productObj.productId = ownership.Honda_Product__c;
            //productObj.productModelId = ownership.Honda_Product__r.Product_Model__c;
            productObj.nickname = String.isNotEmpty(ownership.Nickname__c) ? ownership.Nickname__c : ownership.Honda_Product__r.Product_Models__r.Model_Year__c + ' ' + ownership.Honda_Product__r.Product_Models__r.Model_Name__c;
            productObj.divisionId = ownership.Honda_Product__r.Product_Models__r.Product_Division__c;
            productObj.division = ownership.Honda_Product__r.Product_Models__r.Product_Subdivision__c;
            productObj.year = ownership.Honda_Product__r.Product_Models__r.Model_Year__c;
            productObj.modelId = ownership.Honda_Product__r.Product_Models__r.Product_Model_Id__c;
            productObj.model = ownership.Honda_Product__r.Product_Models__r.Model_Name__c;
            productObj.trim = ownership.Honda_Product__r.Product_Models__r.Trim__c;
            productObj.productIdentifier = ownership.Honda_Product__r.Product_Identifier__c;
            productObj.division = String.isBlank(productObj.division) ? productObj.divisionId == 'A' ? 'Honda' : productObj.divisionId == 'B' ? 'Acura' : productObj.division : productObj.division;
            productObj.image = String.isNotBlank(productObj.division) ? '/resource/MyGarage/img/thumbnail_' + productObj.division.toLowerCase() + '.png' : '';
            productObj.customerUploadedImage = ownership.Customer_Uploaded_Image__c;
            productObj.productDefaultImage = ownership.Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c;
            products.add(productObj);
        }
        return products;
    } // end queryProducts()


    //====================
    //= Public Class: Context
    //====================
    public class Context {
        @AuraEnabled public Boolean isInContext {get;set;}
        @AuraEnabled public String productId  {get;set;}
        @AuraEnabled public String productTab  {get;set;} 
        @AuraEnabled public String FirstName    {get;set;}  
        @AuraEnabled public Product product {get;set;}       
        
        Public Context(){ this.isInContext = false; }
        Public Context(User u, Product product){
            this.productId = u.Last_Visited_Product_ID__c ;
            this.productTab = u.Last_Visited_Product_Tab__c;
            this.FirstName = u.FirstName ;
            this.product = product;
            
            //====================
            //= Is there any 'Context' for this User?
            //====================
            this.isInContext 
                = String.isNotEmpty(this.productId); 
        }                      
    } // end Context Class()

    //====================
    //= Public Class: Garage
    //====================
    public class MyProducts {
        @AuraEnabled public List<Product> products {get; set;}
        public MyProducts(List<Product> products){
            this.products = products;
        }
        public MyProducts(){}
    } // end Garage Class()
    
    //====================
    //= Public Class: Product
    //====================
    public class Product {
        @AuraEnabled public String productId {get; set;}
        @AuraEnabled public String ownershipId {get; set;}
        @AuraEnabled public String exteriorColor {get; set;}
        @AuraEnabled public String nickname {get; set;}
        @AuraEnabled public String productModelId {get; set;}
        @AuraEnabled public String divisionId {get; set;}
        @AuraEnabled public String division {get; set;}
        @AuraEnabled public String year {get; set;}
        @AuraEnabled public String modelId {get; set;}
        @AuraEnabled public String model {get; set;}
        @AuraEnabled public String trim {get; set;}
        @AuraEnabled public String vin {get; set;}
        @AuraEnabled public String productIdentifier {get; set;}
        @AuraEnabled public String productDefaultImage {get; set;} 
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
        @AuraEnabled public String customerUploadedImage {get; set;}
        @AuraEnabled public Boolean isUserImage {get; set;}
        @AuraEnabled public Boolean isSaved {get; set;}
        @AuraEnabled public Boolean isEditable {get; set;}
        @AuraEnabled public String licenseNumber {get; set;}
        @AuraEnabled public String licenseState {get; set;}
        @AuraEnabled public List<Subscription__c> activeSubscription {get;set;}
        @AuraEnabled public Integer recallCount {get;set;}
        Public Product(){}
    } // end Product Class()
}
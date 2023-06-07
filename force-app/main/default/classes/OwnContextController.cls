//****************************************************************************** 
// File Name:       OwnContextController.cls
// Summary:         Apex Class for Garage
// Created On:      06-25-2021
// Created By:      Arunprasad N (Wipro)
// Test Classes:    OwnContextControllerTest.cls
// Data I/O:        
// Honda Jira Story: Apex class for Garage for Honda Owner Experience
//===============================================================================
// Modification Log: 
// June 16, 2021 Jim Kohs (Wipro) initial coding changed Owner_Product__c to Honda_Product__c
// June 25, 2021 Arunprasad N (Wipro) initial coding
// December 4, 2021 Ravindra Ravindra  changed Community_Context__c to User (DOE-2477, DOE-2476, DOE-2466)
// December 16, 2021 Alex Dzhitenov Changed references to several Honda Product fields to references to 
//                                   Product Model and Product Model Color fields (DOE-3220)
//*******************************************************************************
public without sharing class OwnContextController {
    private static String personAccountId(){
        return [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]?.AccountId;
    }
    
    
    //====================
    //= Public: Get()
    // Added By:  Abhishek Salecha 
    // Date : 8th Oct 2021
    //====================
    @AuraEnabled
    public static Context getCommunityContext(){
        try {
            return retrieveContextFromDatabase();
        }catch(Exception e) {
            system.debug('Exception'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    } 


    //====================
    //= Public: Get()
    // Added By:  Ravindra Ravindra
    // to get profile photo on ownProfile 
    // Date : 1 March 2022
    //====================
    @AuraEnabled
    public static String getProfilePhoto(){
        return [SELECT SmallPhotoUrl FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]?.SmallPhotoUrl;
    }


    // Commented for DOE-2466
    // //====================
    // //= private
    // // Added By:  Abhishek Salecha 
    // // Date : 8th Oct 2021
    // //====================
    // private static Context retrieveContextFromDatabase(){
    //     List<Community_Context__c> listOfContext = 
    //         [Select Id, 
    //          VIN__c,
    //          Make__c, 
    //          Model__c, 
    //          Color__c,
    //          Year__c,
    //          Owner_Product__c,
    //          Level1__c, 
    //          Level2__c, 
    //          Level3__c, 
    //          Level4__c,
    //          UserId__r.FirstName 
    //          FROM    Community_Context__c  
    //          WHERE   UserId__c = :UserInfo.getUserId()];
    //     if (!listOfContext.isEmpty()) {
    //         Context contextObj = new Context(listOfContext[0], null);
    //         return contextObj;
    //     }
    //     else{
    //         return new Context();
    //     }
    // }


    // ====================
    // = private
    // Added By:  Ravindra Ravindra (DOE-2466)
    // Date : 2nd Dec 2021
    // ====================
    private static Context retrieveContextFromDatabase(){
        User userObj =  [SELECT Id, FirstName, 
                         Last_Visited_Product_ID__c, 
                         Last_Visited_Product_Tab__c FROM User
                         WHERE   Id = :UserInfo.getUserId() Limit 1];

            return new Context(userObj, null);
    } // END 


    
    //====================
    //= Public: Get()
    //Modified on 4th December 2021 for DOE-2466
    //====================
    @AuraEnabled// jk note cacheable inhibits DML inserts.
    public static Context getContext(String productId){
        try {
            Context finalContext = read_ContextRecord(productId);
            System.debug('finalContext::'+finalContext);
            return finalContext;
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } // end OwnContext()
    
    //====================
    //= Internal Support Methods
    //====================
    private static Context read_ContextRecord(String productId){
        String accountId = personAccountId();
        System.debug('accountId  :-  '+accountId);
        Context context;
        // Commented for DOE-2466
        // List<Community_Context__c> communityContexts = 
        //     [Select Id, 
        //      VIN__c,
        //      Make__c, 
        //      Model__c, 
        //      Color__c,
        //      Year__c,
        //      Owner_Product__c,
        //      Level1__c, 
        //      Level2__c, 
        //      Level3__c, 
        //      Level4__c,
        //      UserId__r.FirstName 
        //      FROM    Community_Context__c  
        //      WHERE   UserId__c = :UserInfo.getUserId()];
        
        User u = 
            [Select Id, 
             FirstName,
             Last_Visited_Product_ID__c,
             Last_Visited_Product_Tab__c 
             FROM    User  
             WHERE   Id = :UserInfo.getUserId() LIMIT 1];
        // Commented for DOE-2466
        // if(!communityContexts.isEmpty()){
        //     Community_Context__c communityContext = communityContexts[0];
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
            String queryString = 'SELECT Id, Honda_Product__c, License_Plate_Number__c, License_Plate_State_Name__c, Nickname__c, Honda_Product__r.Product_Models__r.Product_Division__c, Honda_Product__r.Product_Models__r.Product_Subdivision__c, Honda_Product__r.Product_Models__r.Model_Year__c, Honda_Product__r.Product_Models__r.Default_Thumbnail_Url__c,'
                                    + ' Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c, Honda_Product__r.Product_Identifier__c, (Select Name from Subscriptions__r), Honda_Product__r.Product_Model_Color__r.Large_Image_URL__c, Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c, Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Customer_Uploaded_Image__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c ';
            queryString += ', (SELECT Id FROM Owner_Messages__r WHERE Message__r.RecordTypeId=:recallRecordTypeId) ';
            queryString += 'FROM Ownership__c ';
            queryString += 'WHERE ';
            queryString += 'Honda_Product__c = :productId ';
            queryString += 'AND Product_Owner__c = :accountId ';
            queryString += 'AND Managed__c = true ';
            //queryString += 'WITH SECURITY_ENFORCED ';
            String safeQueryString = String.escapeSingleQuotes(queryString);
            List<Ownership__c> ownerships = Database.query(safeQueryString);
            for (Ownership__c ownership :ownerships) {
                Product productObj = new Product();
                productObj.productId = ownership.Honda_Product__c;
                productObj.ownershipId = ownership.Id;
                productObj.exteriorColor = ownership.Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c;
                productObj.exteriorColorCode = ownership.Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c;
                //productObj.productModelId = ownership.Honda_Product__r.Product_Model__c;
                productObj.nickname = ownership.Nickname__c;
                productObj.divisionId = ownership.Honda_Product__r.Product_Models__r.Product_Division__c;
                productObj.division = ownership.Honda_Product__r.Product_Models__r.Product_Subdivision__c;
                productObj.year = String.isNotEmpty(ownership.Honda_Product__r.Product_Models__r.Model_Year__c) ? ownership.Honda_Product__r.Product_Models__r.Model_Year__c : '';
                productObj.modelId = ownership.Honda_Product__r.Product_Models__r.Product_Model_Id__c;
                productObj.model = ownership.Honda_Product__r.Product_Models__r.Model_Name__c;
                productObj.trim = ownership.Honda_Product__r.Product_Models__r.Trim__c;
                productObj.vin = ownership.Honda_Product__r.Product_Identifier__c;
                productObj.isDefault = true;
                productObj.customerUploadedImage = ownership.Customer_Uploaded_Image__c;
                productObj.image = getDivisionLogo(productObj.division);
                productObj.licenseNumber = ownership.License_Plate_Number__c;
                productObj.licenseState = ownership.License_Plate_State_Name__c;
                productObj.activeSubscription = ownership.subscriptions__r;
                // Alexander Dzhitenov (Wipro): Some Product Models will not have associated Product Model Color records; in this case, the default image will be saved on the Product Model Color record itself
                productObj.productDefaultImage = ownership.Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c != null ? ownership.Honda_Product__r.Product_Model_Color__r.Thumbnail_Image_URL__c : ownership.Honda_Product__r.Product_Models__r.Default_Thumbnail_Url__c; //Using thumbnail for now, since IMGMIDSIZE type images work better for the circular image display
                productObj.recallCount = 0;
                for (Owner_Message__c recallMessage : ownership.Owner_Messages__r){
                    productObj.recallCount++;
                }
                products.add(productObj);
            }
            if(!products.isEmpty()){
                // Commented for DOE-2466
                //context = new Context(communityContext, u, products[0]);
                //DOE-2701 Ravindra Ravindra (Wipro)
                // Alexander Dzhitenov (Wipro): Check connected features for Honda, Acura, or PS only
                if(products[0].vin <> null && (products[0].divisionId == 'A' || products[0].divisionId == 'B' || products[0].divisionId == 'M')){
                    products[0].telematicsFlag = retrieveTelemeticsFlag(products[0].divisionId, products[0].vin);
                    products[0].enrollment = retrieveEnrollment(products[0].divisionId, products[0].vin);
                   // products[0].enrollmentMethod = retrieveEnrollmentMethod(products[0].divisionId, products[0].vin);
                }
                products[0].exteriorColor = products[0].exteriorColor <> null ? products[0].exteriorColor : '-';
                products[0].vin    = products[0].vin <> null ? products[0].vin : '-';
                products[0].licenseNumber = products[0].licenseNumber <> null ? products[0].licenseNumber : '-';
                context = new Context(u, products[0]);
            }else{
                Context = new Context(u, null);
            }
       // }
        return context;
        
    } // end readOrInsert_ContextRecord()


    //====================
    //= Public: getDivisionLogo
    //====================
    @AuraEnabled
    public static String getDivisionLogo(String divisionName){
        String divisionLogo;
        if (divisionName == OwnEConfigApiHelper.HONDA_DIVISION_NAME){
            divisionLogo = '/resource/MyGarage/img/thumbnail_honda.png'; //'/cms/delivery/media/MCYYDI357BSZDS5FXGPSPN5AH4AQ';
        }
        else if (divisionName == OwnEConfigApiHelper.ACURA_DIVISION_NAME){
            divisionLogo = '/resource/MyGarage/img/thumbnail_acura.png'; //'/cms/delivery/media/MCZYP2ZIWGIJCNTB5TO4LRLE4TFY';
        }
        else if (divisionName == OwnEConfigApiHelper.POWERSPORTS_DIVISION_NAME){
            divisionLogo = '/resource/MyGarage/img/thumbnail_powersports.png'; //'/cms/delivery/media/MCQJUU7MKCERCYBL77NG7CTXBDQU';
        }
        else if (divisionName == OwnEConfigApiHelper.POWEREQUIPMENT_DIVISION_NAME){
            divisionLogo = '/resource/MyGarage/img/thumbnail_powerequipment.png'; //'/cms/delivery/media/MCMFYJERXT4ZD6XDGL6HZ7GGNZ4U';
        }
        else if (divisionName == OwnEConfigApiHelper.MARINE_DIVISION_NAME){
            divisionLogo = '/resource/MyGarage/img/thumbnail_marine.png'; //'/cms/delivery/media/MCRIYJTYRG7FB23N4324ABJESWL4';
        }
        return divisionLogo;
    }
    
    // ====================
    // = private
    // Added By:  Ravindra Ravindra (DOE-2701), Edited by Brett Spokes
    // Date : 27 January 2022
    // ====================
    private static String retrieveTelemeticsFlag(String divisionId, String vin){
        String responseBody = OwnAPIController.getProductByVin(vin, divisionId);
        Map<String, Object> vinResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if(vinResponse.get('status') != 'ERROR'){
            Map<String, Object> responseLevel1 = (Map<String, Object>) vinResponse.get('Vehicle');
            if (responseLevel1.containsKey('TelematicsFlag')){
                return (String) responseLevel1.get('TelematicsFlag') ;
            }
        }
            return 'N';
    } // END 
    
    private static String retrieveEnrollment(String divisionId, String vin){
        String responseBody = OwnAPIController.getProductByVin(vin, divisionId);
        Map<String, Object> vinResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if(vinResponse.get('status') != 'ERROR'){
            Map<String, Object> responseLevel1 = (Map<String, Object>) vinResponse.get('Vehicle');
            if (responseLevel1.containsKey('Enrollment')){
                return (String) responseLevel1.get('Enrollment') ;
            }
        }
            return 'N';
    } // END 

    /*private static String retrieveEnrollmentMethod(String divisionId, String vin){
        String responseBody = OwnAPIController.getProductByVin(vin, divisionId);
        Map<String, Object> vinResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if(vinResponse.get('status') != 'ERROR'){
            Map<String, Object> responseLevel1 = (Map<String, Object>) vinResponse.get('Vehicle');
            if (responseLevel1.containsKey('EnrollmentMethod')){
                return (String) responseLevel1.get('EnrollmentMethod') ;
            }
        }
            return 'N';
    } // END */

    /*public static String retrieveTelemeticsFlag(String divisionId, String vin){
        String responseBody = OwnAPIController.getProductByVin(vin, divisionId);
        Map<String, Object> vinResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if(vinResponse.get('status') != 'ERROR'){
            Map<String, Object> responseLevel1 = (Map<String, Object>) vinResponse.get('Vehicle');
            if (responseLevel1.containsKey('TelematicsFlag') && responseLevel1.containsKey('Enrollment') && responseLevel1.containsKey('EnrollmentMethod')){
                System.debug('Keyset ' + (String) responseLevel1.get('TelematicsFlag') + ', ' + (String) responseLevel1.get('Enrollment') + ', ' + (String) responseLevel1.get('EnrollmentMethod'));
                String telematics = (String) responseLevel1.get('TelematicsFlag');
                String enrollment = (String) responseLevel1.get('Enrollment');
                String enrollmentMethod = (String) responseLevel1.get('EnrollmentMethod');
                System.debug('Telematics ' + telematics);
                if (telematics.equals('Y')){
                    System.debug('Enrollment ' + enrollment);
                    if (enrollment.equals('Y')){
                        System.debug('EnrollmentMethod ' + enrollmentMethod);
                        if (enrollmentMethod.equals('SELF')){
                            return (String) responseLevel1.get('TelematicsFlag') + (String) responseLevel1.get('Enrollment') + (String) responseLevel1.get('EnrollmentMethod');
                        }
                    }
                }
            }
        }
            return 'N';
    } // END */

    // Commented for DOE-2466
    // //====================
    // //= Public: upsertContextL1(context)
    // //====================
    // @AuraEnabled
    // public static Result setContextMenuL1(Context context) {
    //     try {
    //         Result result = upsert_ContextRecordMenuL1(context);
    //         return result;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // } // end upsertContextL1(context)
    
    // private static Result upsert_ContextRecordMenuL1(Context context){
    //     Community_Context__c communityContext = new Community_Context__c();
    //     if(String.isNotEmpty(context.communityContextId)){
    //         communityContext.Id = context.communityContextId;
    //     }
    //     communityContext.Level1__c = context.Level1;
    //     communityContext.Level2__c = context.productId;
    //     communityContext.Owner_Product__c = context.productId;
    //     communityContext.UserId__c = UserInfo.getUserId();
    //     if(CanTheUser.create(communityContext) && CanTheUser.edit(communityContext)){
    //         upsert communityContext;
    //         context.communityContextId = communityContext.Id;
    //     }
    //     return new Result(true, 'Level 1 updated to Context', context);
    // } // end upsert_ContextRecordL1(Context context)
    
    // //====================
    // //= Public: upsertContextL2(context)
    // //====================
    // @AuraEnabled
    // public static Result setContextMenuL2(Context context) {
    //     try {
    //         Result result = upsert_ContextRecordMenuL2(context);
    //         return result;
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // } // end upsertContextL2(context)
    
    // private static Result upsert_ContextRecordMenuL2(Context context){
    //     Community_Context__c communityContext = new Community_Context__c();
    //     if(String.isNotEmpty(context.communityContextId)){
    //         communityContext.Id = context.communityContextId;
    //     }
    //     communityContext.Level2__c = context.productId;
    //     communityContext.Owner_Product__c = context.productId;
    //     communityContext.UserId__c = UserInfo.getUserId();
    //     if(CanTheUser.create(communityContext) && CanTheUser.edit(communityContext)){
    //         upsert communityContext;
    //         context.communityContextId = communityContext.Id;
    //     }
    //     return new Result(true, 'Level 2 updated to Context', context);
    // } // end upsert_ContextRecord(Context context)
    
    //====================
    //= Public: upsertContextL2(context)
    //====================
    @AuraEnabled
    public static Result setProductContextUser(Context context) {
        try {
            Result result = update_UserRecord(context);
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } // end updateUser(context)
    
    private static Result update_UserRecord(Context context){
        User u = new User();
        u.Id = UserInfo.getUserId();
        u.Last_Visited_Product_ID__c = context.productId;
        u.Last_Visited_Product_Tab__c = context.productTab;
        // Do not call API for PE/Marine
        Honda_Product__c hp = [SELECT Product_Models__r.Product_Division__c, Product_Identifier__c FROM Honda_Product__c WHERE Id = :context.productId];
        String divisionId = hp.Product_Models__r.Product_Division__c;
        if (divisionId == 'A' || divisionId == 'B' || divisionId == 'M'){
            OwnAPIController.VehicleFeatures vehicleFeature = OwnAPIController.productIdentifierLookUpByProductId(context.productId);
            String telematicsPlatform = 'Legacy';
            String VIN = 'null';
            if(vehicleFeature != null){
                if(vehicleFeature.vehicle != null){
                    telematicsPlatform = vehicleFeature.vehicle.telematicsPlatform;
                    VIN = vehicleFeature.vehicle.VIN;
                }
            }
            u.TelematicsPlatform__c = telematicsPlatform;
            u.VIN__c = VIN;
        }
        else{
            u.VIN__c = hp.Product_Identifier__c;
        }

        if(CanTheUser.edit(u)){
            update u;
        }
        return new Result(true, 'User updated to Product Context', context);
    } // end update_UserRecord(Context context)
    
    @AuraEnabled
    public static void update_UserIsKeyFeatureEnabled(Boolean hasFeatures) {
        update new User(Id = UserInfo.getUserId(), IsKeyFeatureEnabled__c = hasFeatures);
    }
    
    @AuraEnabled
    public static void update_UserHideVehicleSoftwareUpdate(Boolean hide) {
        update new User(Id = UserInfo.getUserId(), HideVehicleSoftwareUpdate__c = hide);
    }

    @AuraEnabled
    public static void update_HasProductSupportVideo(Boolean hasVideos) {
        update new User(Id = UserInfo.getUserId(), Has_Product_Support_Videos__c = hasVideos);
    }

    //====================
    //= Public: update_UserConnectedFlag 
    // Ravindra Ravindra for updateding connected flag on user object
    //====================
    @AuraEnabled
    public static Result update_UserConnectedFlag(String productIdentifier, String divisionId){
        User u = new User();
        u.Id = UserInfo.getUserId();
        OwnAPIController.VehicleFeatures  vehicleFeature = new  OwnAPIController.VehicleFeatures();
        if(productIdentifier != null && productIdentifier != '-'){
            vehicleFeature = OwnAPIController.productIdentifierLookUp(productIdentifier, divisionId);
        }
     
        String telematicsPlatform = 'Legacy';
        if(vehicleFeature != null){
            if(vehicleFeature.vehicle != null){
                telematicsPlatform = vehicleFeature.vehicle.telematicsPlatform;
            }
        }
        u.TelematicsPlatform__c = telematicsPlatform;
        u.VIN__c = String.isNotBlank(productIdentifier) && productIdentifier != '-' ? productIdentifier : 'null';
        if(CanTheUser.edit(u)){
            update u;
        }
        return new Result(true, 'User updated to Product Context', null);
    } // end update_UserConnectedFlag
    //update upcoming service appointments
    @AuraEnabled
    public static void update_UserHasUpcomingServiceAppointments(Boolean hasAppointments) {
        update new User(Id = UserInfo.getUserId(), HasUpcomingServiceAppointment__c = hasAppointments);
    }

    //====================
    //= Public Class: Context
    //====================
    //Modified on 4th December 2021 for DOE-2466
    public class Context {
        @AuraEnabled public String communityContextId {get; set;}
        @AuraEnabled public Boolean isInContext {get;set;}
        @AuraEnabled public String lastVisitedProductID  {get;set;}
        @AuraEnabled public String telematicsPlatform  {get;set;}
        // @AuraEnabled public String Make         {get;set;}
        // @AuraEnabled public Decimal Year        {get;set;}
        // @AuraEnabled public String Model        {get;set;}
        // @AuraEnabled public String VIN          {get;set;}
        @AuraEnabled public String productId  {get;set;}
        @AuraEnabled public String productTab  {get;set;}
        // @AuraEnabled public String Level1  {get;set;}
        // @AuraEnabled public String Level2  {get;set;}
        // @AuraEnabled public String Level3  {get;set;}
        // @AuraEnabled public String Level4  {get;set;}
        @AuraEnabled public String FirstName    {get;set;}  
        // @AuraEnabled public String licenseNumber {get;set;} 
        @AuraEnabled public Product product {get;set;}       
        
        Public Context(){ this.isInContext = false; }
        // Public Context(Community_Context__c contextObj, User u, Product product){
        //     this.communityContextId = contextObj.Id;
        //     this.Make   = contextObj.Make__c;
        //     this.Year   = contextObj.Year__c;
        //     this.Model  = contextObj.Model__c;
        //     this.VIN    = contextObj.VIN__c;
        //     this.productId = contextObj.Owner_Product__c ;
        //     //this.productId = u.Last_Visited_Product_ID__c;
        //     this.productTab = u.Last_Visited_Product_Tab__c;
        //     this.Level1 = contextObj.Level1__c;
        //     this.Level2 = contextObj.Level2__c ;
        //     this.Level3 = contextObj.Level3__c ;
        //     this.Level4 = contextObj.Level4__c ;
        //     this.FirstName = contextObj.UserId__r.FirstName ;
        //     this.licenseNumber = product != null ? product.licenseNumber : '';
        //     this.product = product;
            
        //     //====================
        //     //= Is there any 'Context' for this User?
        //     //====================
        //     this.isInContext 
        //         = String.isNotEmpty(this.VIN) 
        //         || (String.isNotEmpty(this.Make) && String.isNotEmpty(this.Model) && (this.Year != null && this.year != 0)) ; 
        // }

         Public Context(User u, Product product){
             System.debug(JSON.serialize(product));
            this.lastVisitedProductID = u.Last_Visited_Product_ID__c;
            this.productId = (product != null && u.Last_Visited_Product_ID__c != product.productId) ? product.productId : u.Last_Visited_Product_ID__c;
            this.productTab = u.Last_Visited_Product_Tab__c ;
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
    //= Public Class: Product
    //====================
    public class Product {
        @AuraEnabled public String productId {get; set;}
        @AuraEnabled public String ownershipId {get; set;}
        @AuraEnabled public String exteriorColor {get; set;}
        @AuraEnabled public String exteriorColorCode {get; set;}
        @AuraEnabled public String nickname {get; set;}
        @AuraEnabled public String productModelId {get; set;}
        @AuraEnabled public String divisionId {get; set;}
        @AuraEnabled public String division {get; set;}
        @AuraEnabled public String year {get; set;}
        @AuraEnabled public String modelId {get; set;}
        @AuraEnabled public String model {get; set;}
        @AuraEnabled public String trim {get; set;}
        @AuraEnabled public String vin {get; set;}
        @AuraEnabled public String telematicsFlag {get; set;}
        @AuraEnabled public String enrollment {get; set;}
        @AuraEnabled public String enrollmentMethod {get; set;}
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
        Public Product(){
        }
        
        /*@AuraEnabled public String telematicsFlag {get; set;} // DOE-2701
        Public Product(){
            this.telematicsFlag = true;
        }*/

    } // end Product Class()    
    
    //====================
    //= Public Class: Result
    //====================
    public class Result {
        @AuraEnabled public Boolean isSuccess {get; set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public Context context {get; set;}
        Public Result(Boolean isSuccess, String message, Context context){
            this.isSuccess = isSuccess;
            this.message = message;
            this.context = context;
        }
    } // end Product Class()  
    
    // @AuraEnabled(cacheable = true)
    // public static string getContext2()
    // {
    //     /*basically context means while we log out where were we lasted==>for example when the user log in 
    //      * again to the site he need to be navigated to where he lasted
    //      * the navigation menu first calls this context and loads the mygarage menu with nicknames.
    //      * ==>suppose if we log out from the help centre page then when they log in again we put them in the help
    //        center.*/
    //     return getContextDetails('');
    // }
    
    
    // @AuraEnabled(cacheable = true)
    // public static void setContextMenu1(string context)
    // {
    //     //level 1 is mygarage ,help centre and find a dealer 
    
    // }
    
    
    //  @AuraEnabled(cacheable = true)
    // public static void setContextMenu2(string ProductId)
    // {
    //       /*we need to return the nick names*/
    // }
    
    //   @AuraEnabled(cacheable = true)
    // public static void setContextUser(String InputJSON)
    // {
    //    //we set the logged in users firstname and avitar
    
    // }
    
    
    
    // private static string getContextDetails(string recordId)
    // {
    
    //     set<id> Ownerproductids=new set<id>();
    //     //get the logged in user
    //     User loggdUsr=[SELECT Id, AccountId, ContactId FROM User where Id=:userinfo.getUserId()];
    //     Community_Context__c contxt=[SELECT Id, UserId__c, Owner_Product__c FROM Community_Context__c where UserId__c=:userinfo.getUserId() limit 1];
    //     String qry='SELECT Id, Name,Model_ID__c, Product_Model__c, Owner_Product__c, Recall__c, Knowledge__c, Selling_Dealer__c, Servicing_Dealer__c, Finance_Service_Profile__c, Exterior_Color_Name__c, Interior_Color__c, Model_Year__c, Model_Name__c FROM Honda_Product__c where id=:contxt.Owner_Product__c';
    //     if(String.isNotBlank(recordId)){
    //         qry=qry+' and id=:recordId';
    //     }
    
    //     /*here we just need the brand, nick name , productid to form a product*/
    
    //     Honda_Product__c Prct=database.query(qry);
    //     ProdcutWrap PW=New ProdcutWrap();
    //     PW.productId='test';
    //     PW.brand='Honda';
    //     GarageWrap GW = new GarageWrap();
    //     GW.products.add(PW);
    //     return JSON.serialize(GW);
    // }
    
    // public class GarageWrap{      
    //     List<ProdcutWrap> Products;
    // }
    
    // public class ProdcutWrap{
    //     /*here we just need these three fields or do we need some more?*/
    //     id productId;
    //     string nickname;
    //     string brand; 
    // }
}
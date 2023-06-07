//****************************************************************************** 
// File Name:       ownProductSettingsController.cls
// Summary:         This is a temporary controller for ProductSettings; these methods
//                  will eventually be placed in ownGarageController
// Created On:      10-15-2021
// Created By:      Alexander D (Wipro), Brett S (Wipro)
// Test Classes:    
// Data I/O:        
// Honda Jira Story: 
//===============================================================================
// Modification Log: 
// December 4, 2021 Ravindra Ravindra  changed Community_Context__c to User (DOE-2477, DOE-2476, DOE-2466)
//*******************************************************************************
public without sharing class ownProductSettingsController {

    public static string customerImageDescription = 'Customer uploaded image.';

    @AuraEnabled (cacheable = true)
    public static List<SelectOptionWrapper> getStates(){
		
		List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
		Schema.DescribeFieldResult fieldResult = Ownership__c.License_Plate_State_Name__c.getDescribe();

        List<SelectOptionWrapper> stateOptionsList = new List<SelectOptionWrapper>();

        for (Schema.PicklistEntry stateEntry : fieldResult.getPicklistValues()){
            SelectOptionWrapper stateOption = new SelectOptionWrapper(stateEntry.getValue(), stateEntry.getLabel());
            stateOptionsList.add(stateOption);
        }

        return stateOptionsList;
    }
    
    //added for UBI Insurance eligibility  on 19 Jan 22 by Yusuf Deshwali
    @AuraEnabled (cacheable = true)
    public static Map<string, boolean> getStatesInsuranceEligibility(){
        Map<string,boolean> InsuranceEligibilityMap = new Map<string,boolean>();
        for(UBIInsuranceEligibility__mdt mdt : [SELECT Id, MasterLabel, DeveloperName, Eligible__c
                                                FROM UBIInsuranceEligibility__mdt ORDER BY MasterLabel]){
                                                    InsuranceEligibilityMap.put(mdt.MasterLabel, mdt.Eligible__c);
        }
        return InsuranceEligibilityMap;
    }

    @AuraEnabled (cacheable = true)
    public static ProductDetailsWrapper getProductDetails(Id productId, Id ownershipId){
        // Get information about a product for ProductSettings

        ProductDetailsWrapper product = new ProductDetailsWrapper();
        Honda_Product__c hondaProduct = [SELECT Id, Name, Product_Identifier__c, Product_Models__r.Model_Name__c, Product_Models__r.Product_Model_Id__c, Product_Models__r.Trim__c,
                                                Product_Model_Color__r.Exterior_Color_Name__c, Product_Model_Color__r.Thumbnail_Image_URL__c
                                                FROM Honda_Product__c WHERE Id = :productId];
        Ownership__c productOwnership = [SELECT Id, Nickname__c, License_Plate_State_Name__c, Customer_Uploaded_Image__c
                                                FROM Ownership__c WHERE Id=:ownershipId];
    
        product.productId = hondaProduct.Id;
        product.vin = hondaProduct.Product_Identifier__c;
        product.model = hondaProduct.Product_Models__r.Model_Name__c;
        product.modelId = hondaProduct.Product_Models__r.Product_Model_Id__c;
        product.trim = hondaProduct.Product_Models__r.Trim__c;
        product.exteriorColor = hondaProduct.Product_Model_Color__r.Exterior_Color_Name__c;
        product.state = productOwnership.License_Plate_State_Name__c;
        product.defaultVehicleImage = hondaProduct.Product_Model_Color__r.Thumbnail_Image_URL__c;
        product.customVehicleImage = productOwnership.Customer_Uploaded_Image__c;
       // product.radioCode = productOwnership.Radio_Navigation_Code__c;
        
        return product;
    }


    @AuraEnabled
    public static string save (Id productId, Id ownershipId, String nickname, String licensePlate, String licensePlateState,
                                String radioCode, String navCode){
        // Save method that runs when the product being edited already has a VIN

        Ownership__c editOwnership = new Ownership__c(  Id=ownershipId, Nickname__c=nickname,
                                                        License_Plate_Number__c=licensePlate,
                                                        License_Plate_State_Name__c=licensePlateState );

        update editOwnership;
        
        return '';
    }


    @AuraEnabled
    public static Id saveChanges(   Id productId, Id ownershipId, String divisionId,
                                        OwnContextController.Product product,
                                        String nickname, String modelId,
                                        String vin, String trim, String exteriorColor,
                                        String licensePlate, String licensePlateState,
                                        String radioCode, String navCode, Boolean validVINLength){
        // Save method that runs when the product being edited has no VIN (and none was entered by the user while editing)
        System.debug(productId);
        System.debug(nickname);
        System.debug(vin);
        System.debug(trim);
        System.debug(modelId);
        System.debug(exteriorColor);
        System.debug(radioCode);

        if (vin != null){
            vin = vin.toUpperCase();
        }
        if (product.vin != null){
            product.vin = product.vin.toUpperCase();
        }

        /* Honda_Product__c editProduct = [SELECT  Id, Product_Models__c, Product_Model_Color__c FROM Honda_Product__c
                                                WHERE Id=:productId];
        Product_Model__c editModel = new Product_Model__c();
        Product_Model_Color__c editModelColor = new Product_Model_Color__c(); */
        Ownership__c editOwnership = new Ownership__c(  Id=ownershipId, Nickname__c=nickname,
                                                        License_Plate_Number__c=licensePlate,
                                                        License_Plate_State_Name__c=licensePlateState );
                                    
        //String modelId_manufacturerColorCode = product.modelId + '_' + product.exteriorColorCode;

        // Alexander Dzhitenov (Wipro): Commenting out as editing trim/color is no longer an option on Product Settings
        /* // If a Honda Product with the combination of modelId and mfg color code exists in the database, redirect the ownership to that Honda Product. Else,
        // create a new Honda Product and check if Product Model and Product Model Color records need to be created as well
        if (![SELECT Id FROM Honda_Product__C WHERE Product_Models__r.Product_Model_Id__c = :modelId AND Product_Model_Color__r.Model_ID_Manufacture_Color_Code__c = :modelId_manufacturerColorCode AND Product_Identifier__c = ''].isEmpty()){
            editProduct = [SELECT Id FROM Honda_Product__C WHERE Product_Models__r.Product_Model_Id__c = :modelId AND Product_Model_Color__r.Model_ID_Manufacture_Color_Code__c = :modelId_manufacturerColorCode AND Product_Identifier__c = '' LIMIT 1];
            editOwnership.Honda_Product__c = editProduct.Id;
        }
        else{
            editProduct = fillHondaProductFromProduct(product);
            // If modelId exists in database, redirect Honda Product lookup to that Product Model. If not, create a new Product Model record.
            if (![SELECT Id FROM Product_Model__c WHERE Product_Model_Id__c = :modelId].isEmpty()){
                editProduct.Product_Models__c = [SELECT Id FROM Product_Model__c WHERE Product_Model_Id__c = :modelId].Id;
            }
            else{
                editModel = fillProductModelFromProduct(product);
                insert editModel;
                editProduct.Product_Models__c = editModel.Id;
            }

            // If modelId_manufacturerColorCode exists in database, redirect Honda Product lookup to that Product Model Color. If not, create a new Product Model Color record.
            //if (![SELECT Id FROM Product_Model_Color__c WHERE Model_ID_Manufacture_Color_Code__c = :modelId_manufacturerColorCode].isEmpty()){
            //    editProduct.Product_Model_Color__c = [SELECT Id FROM Product_Model_Color__c WHERE Model_ID_Manufacture_Color_Code__c = :modelId_manufacturerColorCode].Id;
            //}
            if (![SELECT Id FROM Product_Model_Color__c WHERE Product_Model__r.Product_Model_Id__c = :product.modelId AND Manufacturer_Color_Code__c = :product.exteriorColorCode].isEmpty()){
                editProduct.Product_Model_Color__c = [SELECT Id FROM Product_Model_Color__c WHERE Product_Model__r.Product_Model_Id__c = :product.modelId AND Manufacturer_Color_Code__c = :product.exteriorColorCode].Id;
            }
            else{
                editModelColor = fillProductModelColorFromProduct(product);
                editModelColor.Product_Model__c = editModel.Id;
                insert editModelColor;
                editProduct.Product_Model_Color__c = editModelColor.Id;
            }
            insert editProduct;
            editOwnership.Honda_Product__c = editProduct.Id;
            // Need to set user context if honda product was changed
        } */
        update editOwnership;

        return productId;
    }


    @AuraEnabled
    public static String saveChangesVIN(Id productId, Id ownershipId, String divisionId,
                                        String nickname, String vin, Boolean validVINLength,
                                        String licensePlate, string licensePlateState){
        // Save method that runs when the product being edited has no VIN (and one was entered by the user while editing)
        Id productOwnerId = UserInfo.getUserId();
        Id acctId = [SELECT AccountId FROM User WHERE Id=:productOwnerId].AccountId;

        Boolean recallCalloutSuccess;
        Boolean addProductSuccess = true;
        Map<String, OwnRecallsController.RecallObject> newRecallDataMap = new Map<String, OwnRecallsController.RecallObject>();
        String vinResultStr;

        // Auto-capitalize VIN
        if (vin != null && vin != '-'){
            vin = vin.toUpperCase();
        }
        // Attempt to retrieve VIN details from API, and save to user's garage
        try{
            Honda_Product__c vinProduct = new Honda_Product__c();
            Ownership__c editOwnership = new Ownership__c(  Id=ownershipId, Nickname__c=nickname,
                                                            License_Plate_Number__c=licensePlate,
                                                            License_Plate_State_Name__c=licensePlateState );
    
            vinResultStr = OwnEConfigApiHelper.getModelByVin(vin, divisionId);
            OwnEConfigApiHelper.VinDecoderResponse vinResult = (OwnEConfigApiHelper.VinDecoderResponse) JSON.deserialize(vinResultStr, OwnEConfigApiHelper.VinDecoderResponse.class);
            System.debug(vinResultStr);
            if (!vinResult.isError){
                // Retrieve recalls for the provided VIN
                try{
                    OwnGarageController.Product p = new OwnGarageController.Product();
                    p.vin = vin;
                    p.divisionId = divisionId;
                    p.modelId = vinResult.modelDetail.modelId;
                    newRecallDataMap = OwnRecallsController.getRecallData(new List<OwnGarageController.Product>{p}, acctId);
                    recallCalloutSuccess = true;
                }
                catch (Exception e){
                    System.debug('Recall callout exception; ' + e);
                    recallCalloutSuccess = false;
                }
    
                // Case 1: VIN does not exist in database
                if ([SELECT Id FROM Honda_Product__c WHERE Product_Identifier__c = :vin].isEmpty()){
    
                    vinProduct = setProductFromVINResponse(vinResult);
                    Product_Model__c productModel = new Product_Model__c();
                    Product_Model_Color__c productModelColor = new Product_Model_Color__c();
                    String modelIdMfgColorCode = vinResult.modelDetail.modelId + '_' + vinResult.modelDetail.color.mfg_color_cd;
    
                    // If product model with model ID does not exist in database, create one
                    if ([SELECT Id FROM Product_Model__c WHERE Product_Model_Id__c = :vinResult.modelDetail.modelId].isEmpty()){
                        productModel = setProductModelFromVINResponse(vinResult);
                        insert productModel;
                    }
                    else{
                        productModel = [SELECT Id FROM Product_Model__c WHERE Product_Model_Id__c = :vinResult.modelDetail.modelId];
                    }
    
                    // If product model color with the modelId + mfr color code combination does not exist, create one
                    productModelColor = setProductModelColorFromVINResponse(vinResult);
                    upsert productModelColor;
    
                    vinProduct.Product_Models__c = productModel.Id;
                    vinProduct.Product_Model_Color__c = productModelColor.Id;
                    System.debug(vinProduct);
                    insert vinProduct;
                    System.debug('Insert successful');
                }
                // Case 2: VIN already exists in database, but not in the current user's garage - retrieve the record Id
                else if ([SELECT Id, Honda_Product__c FROM Ownership__c WHERE Honda_Product__r.Product_Identifier__c = :vin 
                                                                        AND Product_Owner__c = :productOwnerId].isEmpty()){
                    vinProduct = [SELECT Id FROM Honda_Product__c WHERE Product_Identifier__c = :vin];
                }
                // Case 3: VIN already exists in database, and is already in the current user's garage - throw a DuplicateVinException with
                // an error to be displayed in LWC
                else if (![SELECT Id, Honda_Product__c FROM Ownership__c WHERE Honda_Product__r.Product_Identifier__c = :vin 
                                                                        AND Product_Owner__c = :productOwnerId].isEmpty()){
                    throw new OwnGarageController.DuplicateVinException('VIN is already registered with another product.');
                }
    
                editOwnership.Honda_Product__c = vinProduct.Id;
                editOwnership.Ownership_Unique_ID__c = acctId + '~' + vinProduct.Id;
                update editOwnership;
    
                // Alexander Dzhitenov (Wipro): Delete ownerships for previously removed products with the provided vin to prevent duplicate ownerships for the same
                // product
                if (![SELECT Id FROM Ownership__c WHERE Honda_Product__r.Product_Identifier__c=:vin AND Product_Owner__c=:AcctId AND Managed__c=false].isEmpty()){
                    List<Ownership__c> ownershipDeleteList = [SELECT Id, (SELECT Id FROM Owner_Messages__r) FROM Ownership__c WHERE Honda_Product__r.Product_Identifier__c=:vin AND Product_Owner__c=:AcctId AND Managed__c=false];
    
                    List<Owner_Message__c> ownerMessageDeleteList = new List<Owner_Message__c>();
    
                    for (Ownership__c o : ownershipDeleteList){
                        for (Owner_Message__c om : o.Owner_Messages__r){
                            ownerMessageDeleteList.add(om);
                        }
                    }
                    if (ownerMessageDeleteList.size() > 0){
                        delete ownerMessageDeleteList;
                    }
                    delete ownershipDeleteList;
                }
                //Modified on 4th Dec 2021 (DOE-2466)
                // Community_Context__c communityContext = OwnGarageController.getCommunityContext();
                // communityContext.Level2__c = vinProduct.Id;
                // communityContext.UserId__c = UserInfo.getUserId();
                // communityContext.Owner_Product__c = vinProduct.Id;
                // upsert communityContext;
                OwnGarageController.updateContextUser(vinProduct.Id,'Overview');
            }
            else{
                addProductSuccess = false;
                recallCalloutSuccess = false;
            }
        }
        catch (Exception e){
            addProductSuccess = false;
        }

        // If recalls were successfully retrieved, and the product was successfully saved to the user's garage, attempt to handle recall save & deletion
        if (recallCalloutSuccess && addProductSuccess){
            try{
                OwnRecallsController.saveAndDeleteRecallsData(newRecallDataMap, acctId);
            }
            catch(Exception e){
                System.debug('Recall save exception; ' + e);
            }
        }

        return vinResultStr;
    }

    public static Honda_Product__c setProductFromVINResponse(OwnEConfigApiHelper.VinDecoderResponse vinResponse){
        Honda_Product__c vinProduct = new Honda_Product__c();
        System.debug(vinResponse.modelDetail.vinNumber);
        vinProduct.Product_Identifier__c = vinResponse.modelDetail.vinNumber;
        System.debug(vinProduct.Product_Identifier__c);
        if (vinProduct.Product_Identifier__c != null){
            vinProduct.Product_Identifier__c = vinProduct.Product_Identifier__c.toUpperCase();
        }

        return vinProduct;
    }

    public static Product_Model__c setProductModelFromVINResponse(OwnEConfigApiHelper.VinDecoderResponse vinResponse){
        Product_Model__c newModel = new Product_Model__c();
        String divisionName = vinResponse.modelDetail.make;

        if (divisionName == 'Honda'){
            newModel.Product_Division__c = 'A';
        }
        else if (divisionName == 'Acura'){
            newModel.Product_Division__c = 'B';
        }
        else if (divisionName == 'Motorcycle/Powersports'){
            newModel.Product_Division__c = 'M';
        }
        else if (divisionName == 'Powerequipment' || divisionName == 'Marine'){
            newModel.Product_Division__c = 'P';
        }
        newModel.Product_Subdivision__c = vinResponse.modelDetail.make;
        newModel.Model_Year__c = vinResponse.modelDetail.year;
        newModel.Model_Name__c = vinResponse.modelDetail.modelGroupName;
        newModel.Trim__c = vinResponse.modelDetail.trim;
        newModel.Product_Model_Id__c = vinResponse.modelDetail.modelId;
        
        return newModel;
    }

    private static Product_Model_Color__c setProductModelColorFromVINResponse(OwnEConfigApiHelper.VinDecoderResponse vinResponse){
        Product_Model_Color__c newModelColor = new Product_Model_Color__c();
        String modelId = vinResponse.modelDetail.modelId;
        String exteriorColorCode = vinResponse.modelDetail.color.mfg_color_cd;
        String exteriorColorName = vinResponse.modelDetail.color.name;
        String ModelID_MfrColorCode = modelId + '_' + exteriorColorCode;
        String imgURL;
        String imgURLMidsize;
        String imgURLTemp;

        // Use image with IMGMIDSIZE asset type as it is fits better into the circle; if it is not there, use the first available
        for (OwnEConfigApiHelper.ModelAsset asset : vinResponse.ModelDetail.assets){
            if (asset.assetType == OwnEConfigApiHelper.ModelAssetType.IMGMIDSIZE){
                imgURLMidsize = asset.imagePath;
            }
            else if (!String.isEmpty(asset.imagePath)){
                imgURLTemp = asset.imagePath;
            }
        }
        imgURL = !String.isEmpty(imgURLMidsize) ? imgURLMidsize : imgURLTemp;

        // If a model color already exists, update its image; else, fill out a new model color with the necessary details
        if ([SELECT Large_Image_URL__c FROM Product_Model_Color__c WHERE Model_ID_Manufacture_Color_Code__c = :ModelID_MfrColorCode].size() != 0){
            newModelColor = [SELECT Id, Thumbnail_Image_URL__c FROM Product_Model_Color__c WHERE Model_ID_Manufacture_Color_Code__c = :ModelID_MfrColorCode LIMIT 1];
            newModelColor.Thumbnail_Image_URL__c = imgURL;
        }
        else{
            newModelColor.Exterior_Color_Name__c = exteriorColorName;
            newModelColor.Thumbnail_Image_URL__c = imgURL;
            newModelColor.Manufacturer_Color_Code__c = !String.isEmpty(exteriorColorCode) ? exteriorColorCode : 'N/A';
            newModelColor.Model_ID_Manufacture_Color_Code__c = ModelID_MfrColorCode;
        }

        return newModelColor;
    }

    @AuraEnabled
    public static String validateVIN(String vin, String divisionId){
        // VIN Validation only - no data is saved
        System.debug('VIN:' + vin);
        System.debug('divisionId:' + divisionId);
        String productFromVINstr = OwnEConfigApiHelper.getModelByVin(vin, divisionId);
        System.debug(productFromVINstr);
        return productFromVINstr;
    }

    @AuraEnabled
    public static String saveImage(Id ownershipId, String imageName, String imageURL, String imageType){
        // Save a customer-uploaded image as a ContentDocument
        Blob image = System.EncodingUtil.base64Decode(imageURL.remove(imageURL.substring(0, imageURL.indexOf(',')+1)));
        String publicURL;

        if ([SELECT Id FROM ContentVersion WHERE FirstPublishLocationId=:ownershipId AND Description=:customerImageDescription].size() > 0){
            ContentVersion customImageVersion = [SELECT Id, Title, PathOnClient, VersionData, ContentDocument.Id FROM ContentVersion
                                                    WHERE FirstPublishLocationId=:ownershipId AND Description=:customerImageDescription
                                                    LIMIT 1];
            ContentDocument customImageDoc = customImageVersion.ContentDocument;
            ContentDistribution customImageDist = [SELECT DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution
                                                    WHERE ContentVersionId=:customImageVersion.Id LIMIT 1];
            delete customImageDoc;
        }

        ContentVersion customImageVersion = new ContentVersion( Title=imageName, 
                                                                VersionData=image,
                                                                PathOnClient='/'+imageName,
                                                                Description=customerImageDescription,
                                                                FirstPublishLocationId=ownershipId);
        insert customImageVersion;

        ContentDistribution customImageDist = new ContentDistribution(  Name=imageName,
                                                                        ContentVersionId=customImageVersion.Id,
                                                                        PreferencesAllowViewInBrowser=true);                               
        insert customImageDist;

        publicURL = [SELECT DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution 
                            WHERE id=:customImageDist.Id].ContentDownloadUrl;


        Ownership__c updateOwnership = new Ownership__c(Id=ownershipId, Customer_Uploaded_Image__c=publicURL);
        update updateOwnership;

        return 'success';
    }

    public static Honda_Product__c fillHondaProductFromProduct(OwnContextController.Product prod){
        //prod.vin = prod.vin.toUpperCase();
        return new Honda_Product__c(Product_Identifier__c = prod.vin);
    }

    public static Product_Model__c fillProductModelFromProduct(OwnContextController.Product prod){
        return new Product_Model__c(Product_Division__c = prod.divisionId,
                                    Product_Subdivision__c = OwnGarageController.getDivisionNameFromCode(prod.divisionId),
                                    Model_Year__c = prod.year,
                                    Model_Name__c = prod.model,
                                    Trim__c = prod.trim,
                                    Product_Model_Id__c = prod.modelId);
    }

    public static Product_Model_Color__c fillProductModelColorFromProduct(OwnContextController.Product prod){
        return new Product_Model_Color__c(  Exterior_Color_Name__c = prod.exteriorColor,
                                            Manufacturer_Color_Code__c = !String.isEmpty(prod.exteriorColorCode) ? prod.exteriorColorCode : 'N/A',
                                            Model_ID_Manufacture_Color_Code__c = prod.modelId + '_' + prod.exteriorColorCode
                                           // Thumbnail_Image_URL__c = prod.image
                                            );
    }

    public class SelectOptionWrapper {
        @AuraEnabled public string value;
        @AuraEnabled public string label;

        public SelectOptionWrapper(string value, string label) {
            this.value = value;
            this.label = label;
        }
    }

    /* public class ImageWrapper {
        @AuraEnabled public Blob image;
        @AuraEnabled public String imageURL;

        public ImageWrapper(Blob image, String imageURL){
            this.image = image;
            this.imageURL = imageURL;
        }
    } */

    public class ProductDetailsWrapper {
        @AuraEnabled public string productId;
        @AuraEnabled public string nickname;
        @AuraEnabled public string vin;
        @AuraEnabled public string model;
        @AuraEnabled public string modelId;
        @AuraEnabled public string trim;
        @AuraEnabled public string exteriorColor;
        @AuraEnabled public string licensePlate;
        @AuraEnabled public string state;
        @AuraEnabled public string radioCode;
        @AuraEnabled public string defaultVehicleImage;
        @AuraEnabled public string customVehicleImage;

        public ProductDetailsWrapper(){
        }
    }
}
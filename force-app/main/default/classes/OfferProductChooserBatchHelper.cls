//****************************************************************************** 
// File Name:       OfferProductChooserBatchHelper.cls
// Summary:         Batch Class Helper for OfferProductChooserBatch.cls
// Created On:      22-12-2021
// Created By:      Nirmalraj Manoharan(B2C) 
// Test Classes:    OfferProductChooserBatchTest.cls
// Data I/O:         
// Honda Jira Story: DOE-2520 & DOE-2568 
//*******************************************************************************
global class OfferProductChooserBatchHelper {
    public String divisionName;
    public String divisionCode;
    public String categoryCode;
    public String applicationName;
    private final String productSubdivision;
    private final String POWERSPORTS_DIVISION_NAME = 'Motorcycle/Powersports';
    private OfferAPIConfiguration__mdt calloutMetadata;
    private OfferHttpCalloutService productChooserApiService;

    /* private Integer maxTreeLevel;
    private String lastTreeLevel; */

    private final String lastTierName = 'Trim';

    global OfferProductChooserBatchHelper(String divisionName, String divisionId,string categoryCode, String env){
        this.divisionName = divisionName;
        this.productSubdivision = getProductSubdivision(this.divisionName);
        this.divisionCode = divisionId;
        this.categoryCode=categoryCode;
        String metadataName = 'ProductChooser_' + divisionName +'_'+ categoryCode +'_' + env ;
        this.calloutMetadata = [
            SELECT Id, MasterLabel, DeveloperName, Method__c, URLParameters__c, HeaderParameters__c, Endpoint__c,
            Body__c
            FROM OfferAPIConfiguration__mdt
            WHERE DeveloperName = :metadataName
        ];
    }

    public OfferProductChooserBatchJSON.ResponseWrapper fetchData(String year,String Categorycode, String env ) {

        String brand = this.divisionName;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = OfferAPIController.getProductChooserDataForOffers(year, brand, Categorycode,env);   
        system.debug('response.getStatusCode()  '  + response.getStatusCode());
        if(response.getStatusCode() != 200)//Successful response will have Status=OK , code=200 
        {
            return null;
        }      
        else
        {
        String responseBody = response.getBody();   
        if(responseBody.contains('db_results')){
            responseBody = responseBody.remove('@');
            responseBody = responseBody.remove('#');   
        } 
        System.debug('Response status: ' + response.getStatus());
        System.debug('Response status code: ' + response.getStatusCode());
        System.debug('Response unserialized: ' + responseBody);
        System.debug('Response :: ' + JSON.serialize(responseBody));
        OfferProductChooserBatchJSON.ResponseWrapper result = OfferProductChooserBatchJSON.parseResponseJson(responseBody);
        System.debug('result :: ' + JSON.serialize(result));
        
        return result; 
       }   
    }
    
    public Map<String, OfferProductChooserBatchJSON.cls_asset> fetchAssets(OfferProductChooserBatchJSON.cls_assets assets){
        // Map response ids to their assets (images)        
        Map<String, OfferProductChooserBatchJSON.cls_asset> assetMap = new Map<String, OfferProductChooserBatchJSON.cls_asset>();
        if(assets != null){
            for(OfferProductChooserBatchJSON.cls_asset asset : assets.asset){
                assetMap.put(asset.id, asset);
            }
        }
        return assetMap;
    }

        
    public Map<String, OfferProductChooserBatchJSON.cls_attribute> fetchAttributes(OfferProductChooserBatchJSON.cls_attributes attributes){
        // Map response ids to their assets (images)        
        Map<String, OfferProductChooserBatchJSON.cls_attribute> attributesMap = new Map<String, OfferProductChooserBatchJSON.cls_attribute>();
        if(attributes != null){
            for(OfferProductChooserBatchJSON.cls_attribute attribute : attributes.attribute){
                
                attributesMap.put(attribute.id,attribute);
            }
        }
        return attributesMap;
    }
    
    
    public Map<String, OfferProductChooserBatchJSON.cls_text> fetchMarketingTexts(OfferProductChooserBatchJSON.cls_text[] texts){
        // Map response ids to their marketing texts (currently used for trim + transmission)
        Map<String, OfferProductChooserBatchJSON.cls_text> textMap = new Map<String, OfferProductChooserBatchJSON.cls_text>();
        if(texts != NULL){
            for(OfferProductChooserBatchJSON.cls_text text : texts){                
                textMap.put(text.id, text);
            }
        }
        return textMap;
    }
    
    public Map<String, OfferProductChooserBatchJSON.cls_exterior> fetchColors(OfferProductChooserBatchJSON.cls_exterior[] colors){
        // Map response ids to their colors
        Map<String, OfferProductChooserBatchJSON.cls_exterior> colorMap = new Map<String, OfferProductChooserBatchJSON.cls_exterior>();
        if(colors != NULL){
            for(OfferProductChooserBatchJSON.cls_exterior color : colors){
                colorMap.put(color.id, color);
            }
        }
        return colorMap;
    }
    
    public Map<String, OfferProductChooserBatchJSON.cls_brand_hierarchy> fetchBrandHierarchies(OfferProductChooserBatchJSON.cls_brand_hierarchy[] hierarchies){
        System.debug('### fetchBrandHierarches: ###' + JSON.serialize(hierarchies));
        Map<String, OfferProductChooserBatchJSON.cls_brand_hierarchy> hierarchyMap = new Map<String, OfferProductChooserBatchJSON.cls_brand_hierarchy>();
        if(hierarchies != NULL){
            for(OfferProductChooserBatchJSON.cls_brand_hierarchy hierarchy : hierarchies){
                hierarchyMap.put(hierarchy.cd, hierarchy);
            }
        }
        return hierarchyMap;
    }

    public Map<String, OfferProductChooserBatchJSON.cls_brand> fetchBrands(OfferProductChooserBatchJSON.cls_brand[] brands){
        System.debug('### fetchBrands: ###' + JSON.serialize(brands));
        Map<String, OfferProductChooserBatchJSON.cls_brand> brandsMap = new Map<String, OfferProductChooserBatchJSON.cls_brand>();
        if(brands != NULL){
            for(OfferProductChooserBatchJSON.cls_brand brand : brands){
                OfferProductChooserBatchJSON.cls_brand newBrand = new OfferProductChooserBatchJSON.cls_brand();
                newBrand.brand_info = brand.brand_info;
                newBrand.brand_details = brand.brand_details;
                newBrand.id = brand.id;
                if(brand.brand != NULL){ 
                    brandsMap.putAll(fetchBrands(brand.brand));
                }
                brandsMap.put(newBrand.id, newBrand);
                System.Debug('BrandMap Id: ' + newBrand.id);
            }
        }
        return brandsMap;
    }
    
    
    public List<BatchRecord> fetchRecords ( OfferProductChooserBatchJSON.ResponseWrapper response, String year,String categoryCode ){
        System.debug('### fetchRecords: ###');
        List<BatchRecord> batchRecords = new List <BatchRecord>();
        
        //string ImgNullRcords = '';
        //System.debug(response.mot.db_results.division.marketing_texts.text);
        System.debug('colors:' + JSON.serialize(response.mot.db_results.division.colors));
        Map<String, OfferProductChooserBatchJSON.cls_exterior> colorsMap = fetchColors(response.mot.db_results.division.colors.exterior);
        Map<String, OfferProductChooserBatchJSON.cls_asset> assetsMap = fetchAssets(response.mot.db_results.division.assets);
        Map<String, OfferProductChooserBatchJSON.cls_text> textsMap = new Map<String, OfferProductChooserBatchJSON.cls_text>();
        Map<String, OfferProductChooserBatchJSON.cls_attribute> attributesMap = fetchAttributes(response.mot.db_results.division.attributes);
        if (this.divisionName != 'Powersports'){
            textsMap = fetchMarketingTexts(response.mot.db_results.division.marketing_texts.text);
        }
        Map<String, OfferProductChooserBatchJSON.cls_brand_hierarchy> brandHierarchyMap = fetchBrandHierarchies(response.mot.db_results.division.hierarchies.brand_hierarchy);
        divisionName = response.mot.db_results.division.name;
        divisionCode = response.mot.db_results.division.cd;
        List<Product_Chooser_Control__c> productChooserControlList = new List<Product_Chooser_Control__c>();       
            if(categoryCode.toLowercase()=='new'){
                applicationName = System.label.Application_Name_For_Current_Offers;  
            }
            else{
                applicationName = System.label.Application_Name_For_Current_Offers_Used; 
            }
                        
        for(String cd : brandHierarchyMap.keySet())
        {
            Map<String, OfferProductChooserBatchJSON.cls_brand> brandsMap = new Map<String, OfferProductChooserBatchJSON.cls_brand>();
            brandsMap = fetchBrands( brandHierarchyMap.get(cd).brand);
            Map<String, Product_Chooser_Control__c> controlObj = new Map<String, Product_Chooser_Control__c>();
            
            for(String id : brandsMap.keySet()){
                if(brandsMap.get(id).brand_info.models != NULL){
                    
                    OfferProductChooserBatchJSON.cls_model[] models = brandsMap.get(id).brand_info.models.model;
                    ProductChooserClass productChooserObj = fetchRecordHelper(brandsMap.get(id), brandsMap, new ProductChooserClass(controlObj));
                    controlObj = productChooserObj.ProductChooserControl;
                    
                    // Determine maximum tree level found in API response based on Product Chooser controls returned by fetchRecordHelper,
                    // and add an additional Product Chooser Control object one tier higher.
                    Integer maxTreeLevel = 0;
                    for (String treeLevelStr : controlObj.keySet()){
                        Integer treeLevel = Integer.valueOf(treeLevelStr);
                        if (treeLevel > maxTreeLevel){
                            maxTreeLevel = treeLevel;
                        }
                    }
                    String lastTreeLevel = String.valueOf(maxTreeLevel);
                    // Alexander Dzhitenov: Add one additional Product Chooser Control record, after all brand detail levels have been read, for trim + transmission
                    // For Autos, the last dropdown menu (trim) is not included in the response; values are derived from "trim" and "transmission" marketing texts. For Powersports, the last dropdown menu is included in the response.
                    // Since this loop runs multiple times, only set lastTreeLevel higher than current maxTreeLevel if Trim Group Product Chooser control object has not already been added
                    // lastTreeLevel is needed to set values in Product Chooser objects, as well, so this needs to be done within the loop itself—
                    // before iterating over models.
                    if (controlObj.get(String.valueOf(maxTreeLevel)).Tier_Name__c != this.lastTierName && this.divisionName != 'Powersports'){
                        lastTreeLevel = String.valueOf(maxTreeLevel+1);
                        controlObj.put(lastTreeLevel, new Product_Chooser_Control__c(
                            Tier_Name__c = this.lastTierName,
                             //Tier_Number__c = Integer.valueOf(lastTreeLevel) + 1,
                              Tier_Number__c = 4,
                            Product_Subdivision__c = this.productSubdivision,
                            Application_Name__c  = applicationName,
                            Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName + lastTreeLevel)
                        ));
                    }
                    System.debug('**********CONTROL OBJ ITERATION**********');
                    System.debug(controlObj.keySet());
                    for (String i : controlObj.keySet()){
                        System.debug(JSON.serialize(controlObj.get(i)));
                    }
                    System.debug('**********END CONTROL OBJ ITERATION**********');
                   	String modelGroupName = productChooserObj.modelGroupName;
                    String trimGroupName = productChooserObj.trimGroupName;
                    String dhCost= productChooserObj.dhCost;
                    System.Debug('DH Cost Is: ' +dhCost);
                    Decimal dInvoice= 0;
                    for(OfferProductChooserBatchJSON.cls_model model : models)
                    {
                        if(model.year >= '2010'){
                        BatchRecord newRecord = new BatchRecord(productChooserObj.productChooser);
                        List<Product_Model_Color__c> modelColorsList = new List<Product_Model_Color__c>();
                        OfferProductChooserBatchJSON.cls_asset[] modelAssets = model.assets != NULL ? model.assets.asset : NULL;
                        OfferProductChooserBatchJSON.cls_exterior[] modelColors = model.colors != NULL? model.colors.exterior : NULL;
                        newRecord.productModel.Product_Subdivision__c = this.productSubdivision;
                        newRecord.productModel.Product_Division__c = divisionCode;
                        newRecord.productModel.Model_Year__c = model.year;
                        newRecord.productChooser.Tier1__c = model.year;
                        //Adding Alternative identifier for product chooser
                       // String textId = model.marketing_texts != NULL ? model.marketing_texts.text[0].id : 'NotFound';
                        newRecord.productChooser.Alternate_Product_Chooser_Identifier__c = applicationName + divisionName + model.year +  newRecord.productChooser.Alternate_Product_Chooser_Identifier__c;
                        newRecord.productModel.Product_Model_ID__c = model.id;
                        newRecord.productModel.Model_Name__c = modelGroupName; // modelName;
                        //try to add msrp and dhcost
                        //newRecord.productModel.MSRP__c= Decimal.valueOf(!String.isEmpty(model.msrp) ? model.msrp : null);
                        //newRecord.productModel.Destination_Handling_Amount__c= Decimal.valueOf(!String.isEmpty(model.dhcost) ? model.dhcost :null);
                        
                        if(model.msrp == 'null' || model.msrp == null ){
                            newRecord.productModel.MSRP__c=null;
                        }
                        else{
                            newRecord.productModel.MSRP__c=Decimal.valueOf(model.msrp);
                        }
                        if(model.invoice_price == 'null' || model.invoice_price == null ){
                            newRecord.productModel.Dealer_Invoice__c=null;
                        }
                        else{
                            newRecord.productModel.Dealer_Invoice__c=Decimal.valueOf(model.invoice_price);
                        }
                        if (this.divisionName == 'Honda')
                        {        //Commented this use case as some models exists in both scenarios so it is getting overridden                 
                            // if (this.divisionName == 'Honda' && this.categoryCode.toLowerCase() == 'used') {
                            //   newRecord.productModel.Destination_Handling_Amount__c = Decimal.valueOf(0);
                            // } 

                            if (this.divisionName == 'Honda' && this.categoryCode.toLowerCase() == 'new'
                            && dhcost != 'null' && dhcost != null) {
                            //System.Debug('test dhcost' + Decimal.valueOf(dhcost));
                            newRecord.productModel.Destination_Handling_Amount__c = Decimal.valueOf(dhcost);
                          }
                          if (this.divisionName == 'Honda' && this.categoryCode.toLowerCase() == 'new'
                          && dhcost == 'null' || dhcost == null) {
                                //Add Logic to send Email notification
                                newRecord.productModel.Destination_Handling_Amount__c = null;
                            }    
                        }
                        if (this.divisionName == 'Acura')
                        {
                                //Commented this use case as some models exists in both scenarios so it is getting overridden
                            // if (this.divisionName == 'Acura' && this.categoryCode.toLowerCase() == 'used') {
                            //   newRecord.productModel.Destination_Handling_Amount__c = Decimal.valueOf(0);
                            // }                              
                            if (this.divisionName == 'Acura' && this.categoryCode.toLowerCase() == 'new' 
                              && dhcost != 'null' && dhcost != null) {
                              newRecord.productModel.Destination_Handling_Amount__c = Decimal.valueOf(dhcost);
                            }
                            if (this.divisionName == 'Acura' && this.categoryCode.toLowerCase() == 'new' 
                            && dhcost == 'null' || dhcost == null){
                                //Add Logic to send Email notification
                                newRecord.productModel.Destination_Handling_Amount__c = null;
                                }                     
                                                     
                        } 
                        if(this.divisionName == 'Powersports') {
                          for (OfferProductChooserBatchJSON.cls_attribute attribute: model.attributes.attribute) {
                            if(attributesMap.containsKey(attribute.id) && attributesMap.get(attribute.id).attribute_type.toLowerCase() == 'national_destination_charge'){
                                newRecord.productModel.Destination_Handling_Amount__c = Decimal.valueOf(attributesMap.get(attribute.id).attribute_name);                                
                            }
                          }                        
                        }                      
                        
          
                        
                        System.debug('LINE 287');
                        System.debug('**287**' + this.divisionName + ' ' + (this.divisionName != 'Powersports'));
                        if (this.divisionName != 'Powersports')
                        {                            
                                lastTreeLevel='3';                          
                            
                            // For Autos, the last dropdown menu (trim) is not included in the response; values are derived from "trim" and "transmission" marketing texts. For Powersports, the last dropdown menu is included in the response.
                            String trimName = '' ;
                            String transmission = '';
                            String trimShortName='';
                        
                            for(OfferProductChooserBatchJSON.cls_text textId : model.marketing_texts.text){

                                if(textsMap.containsKey(textId.id) && textsMap.get(textId.id).type_cd == 'MDLMKTNAME'){
                                    trimShortName = textsMap.get(textId.id).text;                                 
                                    
                                }
                                if (textsMap.containsKey(textId.id) && textsMap.get(textId.id).type_cd == 'TRIM_FN_NM'){
                                    trimName = textsMap.get(textId.id).text;

                                }else if(textsMap.containsKey(textId.id) && textsMap.get(textId.id).type_cd == 'FRND_TRAN'){
                                    transmission = textsMap.get(textId.id).text;
                                }
                                
                            }   

                           
                            //newRecord.productModel.Trim_Short_Name__c=!String.isEmpty(trimShortName) ? trimShortName : '';
                            trimName = trimName == 'null' || trimName == null ? '' : trimName;
                            transmission = transmission == 'null' || transmission == null ? '' : transmission;
                            String tConcat = trimName + ' ' + transmission;
                            newRecord.productModel.Trim_Short_Name__c = trimShortName == 'null' || String.isEmpty(trimShortName)||trimShortName == null ? tConcat : trimShortName;
                            newRecord.productModel.Trim__c = tConcat;
                            System.debug('Max tree level: ' + lastTreeLevel);
                            if(lastTreeLevel == '5'){
                                System.debug('Setting tConcat at tree level 5');
                                newRecord.productChooser.Tier6__c = tConcat;
                            }else if(lastTreeLevel == '4'){
                                System.debug('Setting tConcat at tree level 4');
                                newRecord.productChooser.Tier5__c = tConcat;
                            }else if(lastTreeLevel == '3'){
                                System.debug('Setting tConcat at tree level 3');
                                newRecord.productChooser.Tier4__c = tConcat;
                            }else if(lastTreeLevel == '2'){
                                System.debug('Setting tConcat at tree level 2');
                                newRecord.productChooser.Tier3__c =  tConcat;
                            }else if(lastTreeLevel == '1'){
                                System.debug('Setting tConcat at tree level 1');
                                newRecord.productChooser.Tier2__c = tConcat;
                            }
                            newRecord.productChooser.Alternate_Product_Chooser_Identifier__c +=  tConcat;
                        }
                        System.debug(newRecord.productChooser);
                        Integer index = 0;  

                        if(modelColors != NULL){
                                String extPriceDelta='';
                            for(OfferProductChooserBatchJSON.cls_exterior color : modelColors){
                                Product_Model_Color__c obj = new Product_Model_Color__c();
                                obj.Manufacturer_Color_Code__c = colorsMap.containsKey(color.id) ? colorsMap.get(color.id).mfg_color_cd : '';
                                obj.Exterior_Color_Name__c = colorsMap.containsKey(color.id) ? colorsMap.get(color.id).name : '';
                                obj.Model_ID_Manufacture_Color_Code__c = model.id + '_' + obj.Manufacturer_Color_Code__c;
                                System.Debug('Exterior_Price_Delta__c is: ' + color.price_delta);
                                if(color.price_delta == 'null' || color.price_delta == null ){
                                    obj.Exterior_Price_Delta__c=Decimal.valueOf(0);
                                }
                                else{
                                    obj.Exterior_Price_Delta__c=Decimal.valueOf(color.price_delta);
                                }
                                //obj.Exterior_Price_Delta__c=color.price_delta == 'null' || color.price_delta == null ? '' : Decimal.valueOf(color.price_delta);
                                //obj.Exterior_Price_Delta__c= Decimal.valueOf(!String.isEmpty(color.price_delta) ? color.price_delta : '');
                               
                                //Ravindra Ravindra (Wipro) Mapping Images with colors and inserting them into product model color obj.
                        if(modelAssets != NULL){
                            for(OfferProductChooserBatchJSON.cls_asset asset : modelAssets)
                            {
                                if (this.divisionName.toLowerCase() != 'powersports' && assetsMap.get(asset.Id).asset_color_match != null)
                                {
                                    List<OfferProductChooserBatchJSON.cls_color> colorMatchList = assetsMap.get(asset.id).asset_color_match.color;
                                    for(OfferProductChooserBatchJSON.cls_color colorNode : assetsMap.get(asset.id).asset_color_match.color)
                                    {
                                        if(	colorNode.Id == color.id)
                                        {                                                   
                                                   //To insert offer image url
                                                    if (this.divisionName.toLowerCase() != 'powersports' && assetsMap.get(asset.Id).type_cd.trim().toLowerCase()=='basecar'){                                                                                                   
                                                        obj.Offer_Image_Large_URL__c  = assetsMap.get(asset.id).path;                                         
                                                    
                                                    }
                                                    if(String.isBlank(obj.Offer_Image_Large_URL__c)){
                                                        if (this.divisionName.toLowerCase() != 'powersports' && assetsMap.get(asset.Id).type_cd.trim().toLowerCase()=='imgoverlay'){
                                                            obj.Offer_Image_Large_URL__c  = assetsMap.get(asset.id).path;                                          
                                                        }
                                                    }
                                                    if(String.isBlank(obj.Offer_Image_Large_URL__c)){
                                                        if (this.divisionName.toLowerCase() != 'powersports' && assetsMap.get(asset.Id).type_cd.trim().toLowerCase()=='imgmidsize'){
                                                            obj.Offer_Image_Large_URL__c  = assetsMap.get(asset.id).path;                                          
                                                        }
                                                    }

                                                    if (this.divisionName.toLowerCase() != 'powersports' && assetsMap.get(asset.Id).type_cd.trim().toLowerCase()=='imgthumb'){
                                                                                                  
                                                        obj.Offer_Image_Thumb_URL__c  = assetsMap.get(asset.id).path;                                         
                                                    
                                                    }     

                                                    //If the image url is still null, add the record to the error object for notification
                                                    // if(String.isBlank(obj.Offer_Image_Large_URL__c))
                                                    // {
                                                    //     ImgNullRcords = ImgNullRcords +  'ModelId: ' + model.id +' ProductDivision: ' + this.divisionName + ' AssetClorMatchId: '+colorNode.Id+  ';';                                                        
                                                                                                                               
                                                    // }

                                                    
                                        }
                                    }
                                }                                                                   

                                        if (this.divisionName.toLowerCase() == 'powersports' && assetsMap.get(asset.Id).asset_color_match != null){
                                            List<OfferProductChooserBatchJSON.cls_color> colorMatchList = assetsMap.get(asset.id).asset_color_match.color;
                                            for(OfferProductChooserBatchJSON.cls_color colorNode : assetsMap.get(asset.id).asset_color_match.color){
                                                if(	colorNode.Id == color.id){                                                   
                                                    obj.Offer_Image_Large_URL__c  = assetsMap.get(asset.id).path;
                                                    obj.Offer_Image_Thumb_URL__c  = assetsMap.get(asset.id).path;                                                    
                                                }
                                            }
                                        }                                          
                                    }
                                }

                                modelColorsList.add(obj);
                                index++;
                            }
                        }
                        
                        newRecord.modelColorList =  modelColorsList; 
                        batchRecords.add(newRecord);
                    }

                    }
                }
            }
            productChooserControlList.addALL(controlObj.values());
        }

        
        batchRecords = recordValidation(batchRecords); 
        System.debug('batchRecords == ' + batchRecords.size());
        insertChooserControls(productChooserControlList);
        return batchRecords;
    }
    
    public void insertChooserControls(List<Product_Chooser_Control__c> productChooserControlList){
        try{
            Database.insert(productChooserControlList, false); 
            System.debug('insertedChooserControls ' + productChooserControlList);
        }catch(DmlException ex){
            System.debug('Exception' + ex);
        }
    }
    
    public ProductChooserClass fetchRecordHelper(OfferProductChooserBatchJSON.cls_brand brand, Map<String, OfferProductChooserBatchJSON.cls_brand> brandsMap, ProductChooserClass productChooserObj){
       
                    OfferProductChooserBatchJSON.cls_brand_details brandDetail = brand.brand_details;
                    System.debug('BRAND DETAIL ' + brandDetail);
                    System.debug('PRODUCTCHOOSEROBJ: ' + productChooserObj);
                    //For Autos we dont need all the hierarchy, so filter only year,Series, model and trim                
                if(!productChooserObj.ProductChooserControl.containsKey(brandDetail.tree_level))            
                {
                    if(this.divisionName.toLowerCase() != 'powersports')
                    {
                                if(brandDetail.brand_line_type_name== 'Brand'){			
                                    productChooserObj.ProductChooserControl.put(brandDetail.tree_level, new Product_Chooser_Control__c(
                                        Tier_Name__c =  'Year',                   
                                        Tier_Number__c = 1,
                                        Product_Subdivision__c = this.productSubdivision,
                                        Application_Name__c  = applicationName,
                                            Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName + brandDetail.tree_level)
                                        )); 
                                }

                                //Set Tier 2 as Series for Honda
                                if(brandDetail.brand_line_type_name== 'Series' && this.divisionName.toLowerCase() == 'honda'){			
                                    productChooserObj.ProductChooserControl.put(brandDetail.tree_level, new Product_Chooser_Control__c(
                                        Tier_Name__c =  brandDetail.brand_line_type_name,                   
                                        Tier_Number__c = 2,
                                        Product_Subdivision__c = this.productSubdivision,
                                        Application_Name__c  = applicationName,
                                            Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName + brandDetail.tree_level)
                                        )); 
                                }

                                if(brandDetail.brand_line_type_name.toLowerCase()== 'model' && this.divisionName.toLowerCase() == 'honda'){			
                                    productChooserObj.ProductChooserControl.put(brandDetail.tree_level, new Product_Chooser_Control__c(
                                        Tier_Name__c =  brandDetail.brand_line_type_name,                   
                                        Tier_Number__c = 3,
                                        Product_Subdivision__c = this.productSubdivision,
                                        Application_Name__c  = applicationName,
                                            Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName + brandDetail.tree_level)
                                        )); 
                                }
                                
                                if(brandDetail.brand_line_type_name.toLowerCase()== 'model' && this.divisionName.toLowerCase() == 'acura'){
                                    productChooserObj.ProductChooserControl.put('1', new Product_Chooser_Control__c(
                                        Tier_Name__c =  'Series',                   
                                        Tier_Number__c = 2,
                                        Product_Subdivision__c = this.productSubdivision,
                                        Application_Name__c  = applicationName,
                                            Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName +  '1')
                                        )); 

                                        productChooserObj.ProductChooserControl.put('2', new Product_Chooser_Control__c(
                                            Tier_Name__c =  brandDetail.brand_line_type_name,                   
                                            Tier_Number__c = 3,
                                            Product_Subdivision__c = this.productSubdivision,
                                            Application_Name__c  = applicationName,
                                            Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName + '2')
                                        )); 
                                
                                    }
                    }
                if(this.divisionName.toLowerCase() == 'powersports')
                {          
                        
                            productChooserObj.ProductChooserControl.put(brandDetail.tree_level, new Product_Chooser_Control__c(
                                Tier_Name__c = ( (Integer.valueOf(brandDetail.tree_level) + 1 ) > 1 ) ? (brandDetail.brand_line_type_name.equalsIgnoreCase('Model Group') ? 'Model' : brandDetail.brand_line_type_name) : 'Year',
                                Tier_Number__c = ( (Integer.valueOf(brandDetail.tree_level) + 1 ) > 1 ) ? (Integer.valueOf(brandDetail.tree_level) + 1 )  : 1.00,
                                Product_Subdivision__c = this.productSubdivision,
                                Application_Name__c  = applicationName,
                                Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName + brandDetail.tree_level)
                            )); 
                            
                        
                    }
                }
                    if(brandDetail.brand_line_type_name.containsIgnoreCase('Model')){
                            productChooserObj.modelGroupName = brandDetail.brand_line_name;
                            productChooserObj.dhcost=brandDetail.dhcost;
                            System.debug('brandDetail.dhcost' + brandDetail.dhcost);
                    }
                    if(brandDetail.parent_id != brand.id )
                    {
                       
                        //Adding Alternative identifier for product chooser
                        String altName = productChooserObj.productChooser.Alternate_Product_Chooser_Identifier__c;
                        productChooserObj.productChooser.Alternate_Product_Chooser_Identifier__c = brandDetail.brand_line_name + (altName != NULL ? altName :'');
                    
                        //Keep only 3 Tiers for Autos
                        if(this.divisionName.toLowerCase() =='honda')
                        {
                                //Honda tree level 3 is Series
                                if(brandDetail.tree_level == '3'){
                                    productChooserObj.productChooser.Tier2__c = brandDetail.brand_line_name;                        
                                }
                                //Honda tree level 4 is Model
                                if(brandDetail.tree_level == '4'){                
                                    productChooserObj.productChooser.Tier3__c = brandDetail.brand_line_name;
                                }
                        }
                        if(this.divisionName.toLowerCase() =='acura' && this.categoryCode.toLowerCase()=='new')
                        {
                                if(brandDetail.tree_level == '2'){
                                    //system.debug('brandDetail.brand_line_name_inside treelevel2'+ brandDetail.brand_line_name);
                                    // Since Acura doensnt have Series level hierarchy, copy the same value of "Model (tree level 2)" to Tier 2 and 3
                                        productChooserObj.productChooser.Tier2__c =  brandDetail.brand_line_name.trim() ;  
                                        productChooserObj.productChooser.Tier3__c = brandDetail.brand_line_name.trim(); 
                                }
                                // if(string.isBlank( brandDetail.brand_line_name)){
                                //     System.Debug('Not getting into tree level 2');
                                //     productChooserObj.productChooser.Tier2__c = 'test' + brandDetail.brand_line_name.trim() +'1' ;      
                                //     productChooserObj.productChooser.Tier3__c = 'test' + brandDetail.brand_line_name.trim() +'1';
                                // }
                            }
                       if(this.divisionName.toLowerCase() =='acura' && this.categoryCode.toLowerCase()=='used')
                        {
                                if(brandDetail.tree_level == '1'){
                                    // Since Acura doensnt have Series level hierarchy, copy the same value of "Model (tree level 1)" tp Tier 2 and 3
                                    productChooserObj.productChooser.Tier2__c = brandDetail.brand_line_name;      
                                    productChooserObj.productChooser.Tier3__c = brandDetail.brand_line_name;              
                                }
                            }
                        if(this.divisionName.toLowerCase() =='powersports' && this.categoryCode.toLowerCase()=='new')
                        {
                            if(brandDetail.tree_level == '5'){
                                productChooserObj.productChooser.Tier6__c = brandDetail.brand_line_name;
                            }else if(brandDetail.tree_level == '4'){
                                productChooserObj.productChooser.Tier5__c = brandDetail.brand_line_name;
                            }else if(brandDetail.tree_level == '3'){                
                                productChooserObj.productChooser.Tier4__c = brandDetail.brand_line_name;
                            }else if(brandDetail.tree_level == '2'){
                                productChooserObj.productChooser.Tier3__c =  brandDetail.brand_line_name;
                                
                            }else if(brandDetail.tree_level == '1'){
                                productChooserObj.productChooser.Tier2__c = brandDetail.brand_line_name;
                            }
                    }
                    if(brandsMap.get(brandDetail.parent_id)!=null)
                    {
                        productChooserObj = fetchRecordHelper(brandsMap.get(brandDetail.parent_id),brandsMap, productChooserObj);
                    }
                }                    
            else{
                        productChooserObj.productChooser.Application_Name__c = applicationName;
                        productChooserObj.productChooser.Product_Subdivision__c = this.productSubdivision;
                        System.debug('ELSE STATEMENT BRAND LEVEL ' + brandDetail.tree_level);
                        List<Integer> treeLevelValues = new List<Integer>();
                    }
                    return productChooserObj;  
    }
    
    public List<BatchRecord> recordValidation(List<BatchRecord> batchRecords){
        System.debug('### recordValidation ###');
        Map<String, BatchRecord> recordMap = new Map<String, BatchRecord>();
        for(BatchRecord record : batchRecords){
            recordMap.put(record.productModel.Product_Model_ID__c, record);
        }
        
        List<Product_Model__c> modelList = [SELECT Id, Product_Model_ID__c,
                                            (SELECT Id, Exterior_Color_Name__c, Manufacturer_Color_Code__c FROM Product_Model_Colors__r)
                                            FROM Product_Model__c 
                                            WHERE Product_Model_ID__c IN: recordMap.keySet()];

        Set<Id> pmcIds = new Set<Id>();

        
        
        for(Product_Model__c model : modelList){
            recordMap.get(model.Product_Model_ID__c).productModel.Id = model.Id;

            List<Product_Model_Color__c> modelColorList = recordMap.get(model.Product_Model_ID__c).modelColorList;
            
            if(model.Product_Model_Colors__r.size() > 0 && modelColorList.size() > 0){
                for(Product_Model_Color__c modelColor : model.Product_Model_Colors__r){
                    String flag = modelColor.Manufacturer_Color_Code__c;

                    for(Product_Model_Color__c matchColor : modelColorList ){

                        if(matchColor.Manufacturer_Color_Code__c == flag){
                            matchColor.Id = modelColor.Id;
                        }
                    }
                }
            }
            recordMap.get(model.Product_Model_ID__c).modelColorList = modelColorList;
        }
        
        return recordMap.values();
    }


    public static Set<String> getBrandYears(String divisionName, String divisionId,String categoryCode,String currEnv)
    {

        // Separate API call for retrieving list of years to be used for main Product Chooser API callouts 
        String response = OfferAPIController.getBrandLineProductByDivisionForOffers(divisionName, divisionId,categoryCode,currEnv);
        if(String.isBlank(response))//Successful response will have Status=OK , code=200 
        {
            return null;
        }
        else
        {
            Set<String> brandYears = new Set<String>();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            Map<String, Object> responseLevel1 = (Map<String, Object>) responseMap.get('mot');
            Map<String, Object> responseLevel2 = (Map<String, Object>) responseLevel1.get('db_results');
            Map<String, Object> responseLevel3 = (Map<String, Object>) responseLevel2.get('division');
            Map<String, Object> responseLevel4 = (Map<String, Object>) responseLevel3.get('hierarchies');
            List<Object> responseLevel5 = (List<Object>) responseLevel4.get('brand_hierarchy');        
            List<Object> brandList = (List<Object>) ((Map<String, Object>) responseLevel5[0]).get('brand');
            brandYears.addAll(loopThroughBrandsRecursive(brandList));
            System.debug('Brand Years: ' + brandYears);
            return brandYears;
        }
    }

    private static Set<String> loopThroughBrandsRecursive(List<Object> brandList){
        // API response contains nested levels of "brand" objects that each contain relevant years; run through them recursively, adding
        // years from each level before moving onto the next
        Set<String> yearSet = new Set<String>();
        for (Object brandItem : brandList){
            Map<String, Object> brandItemMap = (Map<String, Object>) brandItem;

            // Add all years found in a given brand subtree
            yearSet.addAll(getYearsFromBrand(brandItemMap));

            if (brandItemMap.containsKey('brand')){
                // Add all years found in nest brand subtrees recursively
                yearSet.addAll(loopThroughBrandsRecursive(( (List<Object>) brandItemMap.get('brand') )));
            }
        }
        // Initial method call will return all years found throughout the API response tree structure
        return yearSet;
    }

    private static Set<String> getYearsFromBrand(Map<String, Object> brandItemMap){
        //Takes an item in a 'brand' list from the GetBrandLineProductByDivision API response, and extracts all years from it

        Set<String> yearSet = new Set<String>();

        Map<String, Object> brandInfoMap = (Map<String, Object>) brandItemMap.get('brand_info');
        Map<String, Object> activeModelYears = (Map<String, Object>) brandInfoMap.get('active_model_years');
        List<Object> years = (List<Object>) activeModelYears.get('year');

        for (Object year : years){
            Map<String, Object> yearInfo = (Map<String, Object>) year;
            yearSet.add((String) yearInfo.get('#text'));
        }
        return yearSet;
    }


    private String getProductSubdivision(String divisionName){
        switch on divisionName{
            when 'Honda'{
                return 'Honda';
            }
            when 'Acura'{
                return 'Acura';
            }
            when 'Powersports'{
                return 'Motorcycle/Powersports';
            }
            when else{
                return divisionName;
            }
        }
    }

    
    class InputParamsWrapper {
        String key;
        String value;
        String type;
    }
    
    public class ProductChooserClass {
        public Product_Chooser__c productChooser;
        public Map<String, Product_Chooser_Control__c> ProductChooserControl ;
        public String modelGroupName;
        public String trimGroupName;
        public String dhcost;
        public ProductChooserClass(){
            this.productChooser = new Product_Chooser__c();
            this.ProductChooserControl = new Map<String, Product_Chooser_Control__c>();
        }
        public ProductChooserClass( Map<String, Product_Chooser_Control__c> controlObj){
            this.productChooser = new Product_Chooser__c();
            this.ProductChooserControl = controlObj;
        }
    }
    
    global class BatchRecord{
        global Product_Model__c productModel;
        global Product_Chooser__c productChooser;
        global List<Product_Model_Color__c> modelColorList;
        
        global BatchRecord(){
            this.productModel = new Product_Model__c();
            this.productChooser = new Product_Chooser__c();
            this.modelColorList =  new List<Product_Model_Color__c>();
        }
        global BatchRecord(Product_Chooser__c record){
            this.productModel = new Product_Model__c();
            this.productChooser = record.clone();
            this.modelColorList =  new List<Product_Model_Color__c>();
        }
    }
}
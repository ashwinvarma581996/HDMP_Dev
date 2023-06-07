//****************************************************************************** 
// File Name:       OwnProductChooserBatchHelper.cls
// Summary:         Batch Class Helper for OwnProductChooserBatch.cls
// Created On:      22-12-2021
// Created By:      Girish J (Wipro)
// Test Classes:    OwnProductChooserBatchTest.cls
// Data I/O:         
// Honda Jira Story: DOE-2520 & DOE-2568 
//*******************************************************************************
global class OwnProductChooserBatchHelper {
    public String divisionName;
    public String divisionCode;
    public String applicationName;
    private final String productSubdivision;
    private final String POWERSPORTS_DIVISION_NAME = 'Motorcycle/Powersports';
    private OwnAPIConfiguration__mdt calloutMetadata;
    private OwnHttpCalloutService productChooserApiService;

    /* private Integer maxTreeLevel;
    private String lastTreeLevel; */

    private final String lastTierName = 'Trim';

    global OwnProductChooserBatchHelper(String divisionName, String divisionId){
        this.divisionName = divisionName;
        this.productSubdivision = getProductSubdivision(this.divisionName);
        this.divisionCode = divisionId;

        String metadataName = 'ProductChooser_' + divisionName;

        this.calloutMetadata = [
            SELECT Id, MasterLabel, DeveloperName, Method__c, URLParameters__c, HeaderParameters__c, Endpoint__c,
            Body__c
            FROM OwnAPIConfiguration__mdt
            WHERE DeveloperName = :metadataName
        ];
        // OwnHttpCalloutService code
        //OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        //attribute.divisionId = divisionId;
        //List<String> endpointParams = new List<String>();
        //productChooserApiService = new OwnHttpCalloutService(metadataName, attribute, endpointParams);
    }

    public OwnProductChooserBatchJSON.ResponseWrapper fetchData(String year) {

        String brand = this.divisionName;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();


        HttpResponse response = OwnAPIController.getProductChooserData(year, brand);

        // API callout moved to OwnAPIController
        /* HttpResponse response = new HttpResponse();

        
        if (brand == 'Acura'){
            //List<InputParamsWrapper> headerParams = (List<InputParamsWrapper>) JSON.deserialize(calloutMetadata.HeaderParameters__c, InputParamsWrapper.class);
            //String endPoint = this.calloutMetadata.Endpoint__c;
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
            attribute.year = year;
            attribute.divisionId = 'A';
            OwnHttpCalloutService productChooserCalloutService = new OwnHttpCalloutService('ProductChooser_Acura', attribute, new List<String>());
            response = productChooserCalloutService.sendRequest();
        }
        else if (brand == 'Honda'){
            //List<InputParamsWrapper> headerParams = (List<InputParamsWrapper>) JSON.deserialize(calloutMetadata.HeaderParameters__c, InputParamsWrapper.class);
            
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
            attribute.year = year;
            attribute.divisionId = 'A';
            OwnHttpCalloutService productChooserCalloutService = new OwnHttpCalloutService('ProductChooser_Honda', attribute, new List<String>());
            System.debug(productChooserCalloutService.getRequestBody());
            
            response = productChooserCalloutService.sendRequest();
        } */
        //Powersports not currently implemented
        /* else if (brand == 'Powersports'){
            request.setEndpoint('https://ws-qa4.hondaweb.com/REST/B2C/ProductChooser/1.0?appid=ownerportal.honda.com');
            request.setMethod('POST');

            request.setHeader('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJDbGllbnRBcHBsaWNhdGlvbklEIjoib3duZXJwb3J0YWwuaG9uZGEuY29tIiwiQ2xpZW50RG9tYWluIjoidGVzdC5vd25lcnBvcnRhbC5ob25kYS5jb20iLCJUb2tlbklEIjoiMTYxNzMwMTg0MjI5MSIsImlzcyI6ImVjb25maWcuc2VydmljZXMuaG9uZGEuY29tIiwiYXVkIjoidGVzdF90ZXN0LmVjb25maWcyLnNlcnZpY2VzLmhvbmRhLmNvbSJ9.0DnYZZ7iCnR7jW7KVSCzYdedFxvydKQWocgfH327On8');
            request.setHeader('ClientDomain', 'test.ownerportal.honda.com');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-Honda-wl-authorization', 'Basic c2VydmljZV9vd25lcnNfYjJjX3FhOkZlZXQkNzcx');
            request.setHeader('hondaHeaderType.messageId', '207e19bb-189b-4079-b6e2-0ef259bed26');
    
            request.setHeader('ClientDomain', 'test.ownerportal.honda.com');
            request.setHeader('Accept', 'application/json');  
            request.setHeader('Content-Type', 'application/json');  
            request.setHeader('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJDbGllbnRBcHBsaWNhdGlvbklEIjoib3duZXJwb3J0YWwuaG9uZGEuY29tIiwiQ2xpZW50RG9tYWluIjoidGVzdC5vd25lcnBvcnRhbC5ob25kYS5jb20iLCJUb2tlbklEIjoiMTYxNzMwMTg0MjI5MSIsImlzcyI6ImVjb25maWcuc2VydmljZXMuaG9uZGEuY29tIiwiYXVkIjoidGVzdF90ZXN0LmVjb25maWcyLnNlcnZpY2VzLmhvbmRhLmNvbSJ9.0DnYZZ7iCnR7jW7KVSCzYdedFxvydKQWocgfH327On8');
    
            request.setBody(OwnProductChooserBatchJSON.requestBodyPowersports);
        } */
        
        //HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        /* if (brand == 'Acura'){
            System.debug('SETTING TEST RESPONSE BODY');
            responseBody = OwnProductChooserBatchJSON.acuraTestResponse;
        } */
        /* if (brand == 'Honda'){
            System.debug('SETTING TEST RESPONSE BODY');
            responseBody = OwnProductChooserBatchJSON.hondaTestResponse + OwnProductChooserBatchJSON.hondaTestResponse2 + OwnProductChooserBatchJSON.hondaTestResponse3 + OwnProductChooserBatchJSON.hondaTestResponse4 + OwnProductChooserBatchJSON.hondaTestResponse5 + OwnProductChooserBatchJSON.hondaTestResponseLast;
        } */

        // OwnHttpCalloutService code
        //String responseBody = productChooserApiService.sendRequest().getBody();
        
        /*List<String> endpointParameters = new List<String>{vin};
Attribute attribute = new Attribute();
attribute.divisionId = divisionId;
OwnHttpCalloutService service = new OwnHttpCalloutService('ProductChooserList', attribute, endpointParameters);
String responseBody = service.sendRequest().getBody();*/
        
        if(responseBody.contains('db_results')){
            responseBody = responseBody.remove('@');
            responseBody = responseBody.remove('#');   
        } 
        System.debug('Response status: ' + response.getStatus());
        System.debug('Response status code: ' + response.getStatusCode());
        System.debug('Response unserialized: ' + responseBody);
        System.debug('Response :: ' + JSON.serialize(responseBody));
        OwnProductChooserBatchJSON.ResponseWrapper result = OwnProductChooserBatchJSON.parseResponseJson(responseBody);
        System.debug('result :: ' + JSON.serialize(result));
        
        return result;
        //return new OwnProductChooserBatchJSON.ResponseWrapper();
    }
    
    public Map<String, OwnProductChooserBatchJSON.cls_asset> fetchAssets(OwnProductChooserBatchJSON.cls_assets assets){
        // Map response ids to their assets (images)
        System.debug(assets);
        Map<String, OwnProductChooserBatchJSON.cls_asset> assetMap = new Map<String, OwnProductChooserBatchJSON.cls_asset>();
        if(assets != null){
            for(OwnProductChooserBatchJSON.cls_asset asset : assets.asset){
                assetMap.put(asset.id, asset);
            }
        }
        return assetMap;
    }
    
    public Map<String, OwnProductChooserBatchJSON.cls_text> fetchMarketingTexts(OwnProductChooserBatchJSON.cls_text[] texts){
        // Map response ids to their marketing texts (currently used for trim + transmission)
        Map<String, OwnProductChooserBatchJSON.cls_text> textMap = new Map<String, OwnProductChooserBatchJSON.cls_text>();
        if(texts != NULL){
            for(OwnProductChooserBatchJSON.cls_text text : texts){
                textMap.put(text.id, text);
            }
        }
        return textMap;
    }
    
    public Map<String, OwnProductChooserBatchJSON.cls_exterior> fetchColors(OwnProductChooserBatchJSON.cls_exterior[] colors){
        // Map response ids to their colors
        Map<String, OwnProductChooserBatchJSON.cls_exterior> colorMap = new Map<String, OwnProductChooserBatchJSON.cls_exterior>();
        if(colors != NULL){
            for(OwnProductChooserBatchJSON.cls_exterior color : colors){
                colorMap.put(color.id, color);
            }
        }
        return colorMap;
    }
    
    public Map<String, OwnProductChooserBatchJSON.cls_brand_hierarchy> fetchBrandHierarchies(OwnProductChooserBatchJSON.cls_brand_hierarchy[] hierarchies){
        System.debug('### fetchBrandHierarches: ###' + JSON.serialize(hierarchies));
        Map<String, OwnProductChooserBatchJSON.cls_brand_hierarchy> hierarchyMap = new Map<String, OwnProductChooserBatchJSON.cls_brand_hierarchy>();
        if(hierarchies != NULL){
            for(OwnProductChooserBatchJSON.cls_brand_hierarchy hierarchy : hierarchies){
                hierarchyMap.put(hierarchy.cd, hierarchy);
            }
        }
        return hierarchyMap;
    }
    
    public Map<String, OwnProductChooserBatchJSON.cls_brand> fetchBrands(OwnProductChooserBatchJSON.cls_brand[] brands){
        System.debug('### fetchBrands: ###' + JSON.serialize(brands));
        Map<String, OwnProductChooserBatchJSON.cls_brand> brandsMap = new Map<String, OwnProductChooserBatchJSON.cls_brand>();
        if(brands != NULL){
            for(OwnProductChooserBatchJSON.cls_brand brand : brands){
                OwnProductChooserBatchJSON.cls_brand newBrand = new OwnProductChooserBatchJSON.cls_brand();
                newBrand.brand_info = brand.brand_info;
                newBrand.brand_details = brand.brand_details;
                newBrand.id = brand.id;
                if(brand.brand != NULL){ 
                    brandsMap.putAll(fetchBrands(brand.brand));
                }
                brandsMap.put(newBrand.id, newBrand);
            }
        }
        return brandsMap;
    }
    
    
    public List<BatchRecord> fetchRecords ( OwnProductChooserBatchJSON.ResponseWrapper response, String year ){
        System.debug('### fetchRecords: ###');
        List<BatchRecord> batchRecords = new List <BatchRecord>();
        //System.debug(response.mot.db_results.division.marketing_texts.text);
        System.debug('colors:' + JSON.serialize(response.mot.db_results.division.colors));
        Map<String, OwnProductChooserBatchJSON.cls_exterior> colorsMap = fetchColors(response.mot.db_results.division.colors.exterior);
        //System.debug(fetchAssets(response.mot.db_results.division.assets.asset));

        Map<String, OwnProductChooserBatchJSON.cls_asset> assetsMap = fetchAssets(response.mot.db_results.division.assets);
        Map<String, OwnProductChooserBatchJSON.cls_text> textsMap = new Map<String, OwnProductChooserBatchJSON.cls_text>();
        if (this.divisionName != 'Powersports'){
            textsMap = fetchMarketingTexts(response.mot.db_results.division.marketing_texts.text);
        }
        Map<String, OwnProductChooserBatchJSON.cls_brand_hierarchy> brandHierarchyMap = fetchBrandHierarchies(response.mot.db_results.division.hierarchies.brand_hierarchy);
        divisionName = response.mot.db_results.division.name;
        divisionCode = response.mot.db_results.division.cd;
        List<Product_Chooser_Control__c> productChooserControlList = new List<Product_Chooser_Control__c>();
        applicationName = System.label.Application_Name_For_My_Garage;
        //divisionName = divisionName == 'Powersports' ? 'Motorcycle/Powersports' : divisionName;
        for(String cd : brandHierarchyMap.keySet()){
            Map<String, OwnProductChooserBatchJSON.cls_brand> brandsMap = new Map<String, OwnProductChooserBatchJSON.cls_brand>();
            brandsMap = fetchBrands( brandHierarchyMap.get(cd).brand);
            Map<String, Product_Chooser_Control__c> controlObj = new Map<String, Product_Chooser_Control__c>();
            
            for(String id : brandsMap.keySet()){
                if(brandsMap.get(id).brand_info.models != NULL){
                    
                    OwnProductChooserBatchJSON.cls_model[] models = brandsMap.get(id).brand_info.models.model;
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
                            Tier_Number__c = Integer.valueOf(lastTreeLevel) + 1,
                            Product_Subdivision__c = this.productSubdivision,
                            Application_Name__c  = applicationName,
                            Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName + lastTreeLevel)
                        ));
                    }
                    //this.lastTreeLevel = lastTreeLevel;
                    /* if (!controlObj.containsKey(lastTreeLevel)){
                        controlObj.put(lastTreeLevel, new Product_Chooser_Control__c(
                            Tier_Name__c = this.lastTierName,
                            Tier_Number__c = Integer.valueOf(lastTreeLevel) + 1,
                            Product_Subdivision__c = divisionName,
                            Application_Name__c  = applicationName,
                            Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName + lastTreeLevel)
                        ));
                    } */
                    System.debug('**********CONTROL OBJ ITERATION**********');
                    System.debug(controlObj.keySet());
                    for (String i : controlObj.keySet()){
                        System.debug(JSON.serialize(controlObj.get(i)));
                    }
                    System.debug('**********END CONTROL OBJ ITERATION**********');
                   	String modelGroupName = productChooserObj.modelGroupName;
                    String trimGroupName = productChooserObj.trimGroupName;
                    for(OwnProductChooserBatchJSON.cls_model model : models){
                        BatchRecord newRecord = new BatchRecord(productChooserObj.productChooser);
                        List<Product_Model_Color__c> modelColorsList = new List<Product_Model_Color__c>();
                        OwnProductChooserBatchJSON.cls_asset[] modelAssets = model.assets != NULL ? model.assets.asset : NULL;
                        OwnProductChooserBatchJSON.cls_exterior[] modelColors = model.colors != NULL? model.colors.exterior : NULL;
                        newRecord.productModel.Product_Subdivision__c = this.productSubdivision;
                        newRecord.productModel.Product_Division__c = divisionCode;
                        newRecord.productModel.Model_Year__c = model.year;
                        newRecord.productChooser.Tier1__c = model.year;
                        //Adding Alternative identifier for product chooser
                       // String textId = model.marketing_texts != NULL ? model.marketing_texts.text[0].id : 'NotFound';
                        newRecord.productChooser.Alternate_Product_Chooser_Identifier__c = applicationName + divisionName + model.year +  newRecord.productChooser.Alternate_Product_Chooser_Identifier__c;
                        newRecord.productModel.Product_Model_ID__c = model.id;
                        newRecord.productModel.Model_Name__c = modelGroupName; // modelName;
                        System.debug('LINE 287');
                        System.debug('**287**' + this.divisionName + ' ' + (this.divisionName != 'Powersports'));
                        if (this.divisionName != 'Powersports'){ // For Autos, the last dropdown menu (trim) is not included in the response; values are derived from "trim" and "transmission" marketing texts. For Powersports, the last dropdown menu is included in the response.
                            String trimName = '' ;
                            String transmission = '';
                        
                            for(OwnProductChooserBatchJSON.cls_text textId : model.marketing_texts.text){
                                if (textsMap.containsKey(textId.id) && textsMap.get(textId.id).type_cd == 'TRIM_FN_NM'){
                                    trimName = textsMap.get(textId.id).text;
                                }else if(textsMap.containsKey(textId.id) && textsMap.get(textId.id).type_cd == 'FRND_TRAN'){
                                    transmission = textsMap.get(textId.id).text;
                                }
                            }   

                            trimName = trimName == 'null' || trimName == null ? '' : trimName;
                            transmission = transmission == 'null' || transmission == null ? '' : transmission;
                            String tConcat = trimName + ' ' + transmission;

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

                            for(OwnProductChooserBatchJSON.cls_exterior color : modelColors){
                                Product_Model_Color__c obj = new Product_Model_Color__c();
                                obj.Manufacturer_Color_Code__c = colorsMap.containsKey(color.id) ? colorsMap.get(color.id).mfg_color_cd : '';
                                obj.Exterior_Color_Name__c = colorsMap.containsKey(color.id) ? colorsMap.get(color.id).name : '';
                                obj.Model_ID_Manufacture_Color_Code__c = model.id + '_' + obj.Manufacturer_Color_Code__c;
                                //Ravindra Ravindra (Wipro) Mapping Images with colors and inserting them into product model color obj.
                                if(modelAssets != NULL){
                                    for(OwnProductChooserBatchJSON.cls_asset asset : modelAssets){
                                        if (assetsMap.get(asset.Id).asset_color_match != null){
                                            List<OwnProductChooserBatchJSON.cls_color> colorMatchList = assetsMap.get(asset.id).asset_color_match.color;
                                            for(OwnProductChooserBatchJSON.cls_color colorNode : assetsMap.get(asset.id).asset_color_match.color){
                                                if(	colorNode.Id == color.id){
                                                    obj.Large_Image_URL__c  = assetsMap.get(asset.id).path;
                                                    obj.Thumbnail_Image_URL__c  = assetsMap.get(asset.id).path;
                                                }
                                            }
                                        } // Alexander Dzhitenov (Wipro) - Handle empty asset color match by inserting blank Product Model Color image, containing only the image link
                                        else{
                                            newRecord.productModel.Default_Large_Image_Url__c = assetsMap.get(asset.id).path;
                                            newRecord.productModel.Default_Thumbnail_Url__c = assetsMap.get(asset.id).path;
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
    
    public ProductChooserClass fetchRecordHelper(OwnProductChooserBatchJSON.cls_brand brand, Map<String, OwnProductChooserBatchJSON.cls_brand> brandsMap, ProductChooserClass productChooserObj){
        OwnProductChooserBatchJSON.cls_brand_details brandDetail = brand.brand_details;
        System.debug('BRAND DETAIL ' + brandDetail);
        System.debug('PRODUCTCHOOSEROBJ: ' + productChooserObj);
        if(!productChooserObj.ProductChooserControl.containsKey(brandDetail.tree_level)){
            productChooserObj.ProductChooserControl.put(brandDetail.tree_level, new Product_Chooser_Control__c(
                Tier_Name__c = ( (Integer.valueOf(brandDetail.tree_level) + 1 ) > 1 ) ? (brandDetail.brand_line_type_name.equalsIgnoreCase('Model Group') ? 'Model' : brandDetail.brand_line_type_name) : 'Year',
                Tier_Number__c = ( (Integer.valueOf(brandDetail.tree_level) + 1 ) > 1 ) ? (Integer.valueOf(brandDetail.tree_level) + 1 )  : 1.00,
                Product_Subdivision__c = this.productSubdivision,
                Application_Name__c  = applicationName,
              	Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName + brandDetail.tree_level)
              )); 
            
        }
        if(brandDetail.brand_line_type_name.containsIgnoreCase('Model')){
                productChooserObj.modelGroupName = brandDetail.brand_line_name;
        }
        if(brandDetail.parent_id != brand.id ){
            //Adding Alternative identifier for product chooser
            String altName = productChooserObj.productChooser.Alternate_Product_Chooser_Identifier__c;
            productChooserObj.productChooser.Alternate_Product_Chooser_Identifier__c = brandDetail.brand_line_name + (altName != NULL ? altName :'');
           
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
            productChooserObj = fetchRecordHelper(brandsMap.get(brandDetail.parent_id),brandsMap, productChooserObj);
        }else{
            productChooserObj.productChooser.Application_Name__c = applicationName;
            productChooserObj.productChooser.Product_Subdivision__c = this.productSubdivision;
            System.debug('ELSE STATEMENT BRAND LEVEL ' + brandDetail.tree_level);
            List<Integer> treeLevelValues = new List<Integer>();
            /* Integer maxTreeLevel = 0;
            for (String treeLevelStr : productChooserObj.ProductChooserControl.keySet()){
                Integer treeLevel = Integer.valueOf(treeLevelStr);
                if (treeLevel > maxTreeLevel){
                    maxTreeLevel = treeLevel;
                }
            } */
            /* Integer maxTreeLevel = Integer.valueOf(brandDetail.tree_level);
            System.debug('Helper maxTreeLevel: ' + maxTreeLevel); */
            /* String lastTreeLevel = String.valueOf(maxTreeLevel+1);
            this.lastTreeLevel = lastTreeLevel;
            productChooserObj.ProductChooserControl.put(lastTreeLevel, new Product_Chooser_Control__c(
                Tier_Name__c = 'Trim Group',
                Tier_Number__c = Integer.valueOf(lastTreeLevel) + 1,
                Product_Subdivision__c = divisionName,
                Application_Name__c  = applicationName,
              	Product_Chooser_Control_Alternate_Identi__c =  (applicationName + divisionName + lastTreeLevel)
            )); */
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


    public static Set<String> getBrandYears(String divisionName, String divisionId){
        // Separate API call for retrieving list of years to be used for main Product Chooser API callouts
        String response = OwnAPICOntroller.getBrandLineProductByDivision(divisionName, divisionId);

        Set<String> brandYears = new Set<String>();

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

        Map<String, Object> responseLevel1 = (Map<String, Object>) responseMap.get('mot');
        Map<String, Object> responseLevel2 = (Map<String, Object>) responseLevel1.get('db_results');
        Map<String, Object> responseLevel3 = (Map<String, Object>) responseLevel2.get('division');
        Map<String, Object> responseLevel4 = (Map<String, Object>) responseLevel3.get('hierarchies');
        List<Object> responseLevel5 = (List<Object>) responseLevel4.get('brand_hierarchy');
        
        List<Object> brandList = (List<Object>) ((Map<String, Object>) responseLevel5[0]).get('brand');

        brandYears.addAll(loopThroughBrandsRecursive(brandList));

        System.debug(brandYears);

        return brandYears;
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
//****************************************************************************** 
// File Name:       OwnEConfigApiHelper.cls
// Summary:         Apex Class for E-Config API Helper
// Created On:      07-12-2021
// Created By:      Ankur A (Wipro)
// Test Classes:    OwnEConfigApiHelperTest.cls
// Data I/O:        
// Honda Jira Story: Apex class for Garage for Honda Owner Experience
//===============================================================================
// Modification Log: 
// July 12, 2021 Ankur A (Wipro) initial coding
//*******************************************************************************

public without sharing class OwnEConfigApiHelper {
    
    public static final String HONDA_DIVISION_CODE = 'A';
    public static final String ACURA_DIVISION_CODE = 'B';
    
    public static final String POWERSPORTS_DIVISION_CODE = 'M';
    public static final String POWEREQUIPMENT_DIVISION_CODE = 'P';
    public static final String MARINE_DIVISION_CODE = 'P';
    
    public static final String HONDA_DIVISION_NAME = 'Honda';
    public static final String ACURA_DIVISION_NAME = 'Acura';
    public static final String POWERSPORTS_DIVISION_NAME = 'Motorcycle/Powersports';
    public static final String POWEREQUIPMENT_DIVISION_NAME = 'Powerequipment';
    public static final String MARINE_DIVISION_NAME = 'Marine';

    public static final String HONDA_AUTOS_ASSET_URL = 'https://automobiles.honda.com/';

    public class Division {
        @AuraEnabled public String divisionId;
        @AuraEnabled public String divisionName;

        public Division(String divisionId, String divisionName) {
            this.divisionId = divisionId;
            this.divisionName = divisionName;
        }
    }
    
    public class SelectOptionWrapper {
        @AuraEnabled public String value;
        @AuraEnabled public String label;

        public SelectOptionWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    
    public static Map<String, Division> divisionMap = new Map<String, Division>{
        HONDA_DIVISION_CODE => new Division(HONDA_DIVISION_CODE, HONDA_DIVISION_NAME),
        ACURA_DIVISION_CODE => new Division(ACURA_DIVISION_CODE, ACURA_DIVISION_NAME),
        POWERSPORTS_DIVISION_CODE => new Division(POWERSPORTS_DIVISION_CODE, POWERSPORTS_DIVISION_NAME),
        POWEREQUIPMENT_DIVISION_CODE => new Division(POWEREQUIPMENT_DIVISION_CODE, POWEREQUIPMENT_DIVISION_NAME),
        MARINE_DIVISION_CODE => new Division(MARINE_DIVISION_CODE, MARINE_DIVISION_NAME)
        };
    
    // 'getYears' is coming from Local storage, later can be changed by API callout
    // divisionId = {'A', 'B'}
    public static List <SelectOptionWrapper> getYears(String divisionId){
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

    // divisionId = {'A' or 'B'} , year = 2022
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
                modelMap.put(vehicle.Model__c, vehicle.Model_Id__c);
                models.add(new SelectOptionWrapper(vehicle.Model_Id__c, vehicle.Model__c));
            }
        }
        return models;
    }

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

    /*************  PowerSport/ Power equipment/ Marine Data point  ***************/

    public static List<SelectOptionWrapper> getTypesPowersports() {
        
        Set<String> typeSet = new Set<String>(); 
        List<SelectOptionWrapper> powersportTypeOptions = new List<SelectOptionWrapper>();

        OwnEConfigTempData.ModelDataWrapper powerModelData = OwnEConfigTempData.getPowerModelData();

        if(powerModelData.powersportsRecords.size() > 0)
        {
            for(OwnEConfigTempData.PowerSports powerSportObj : powerModelData.powersportsRecords)
            {
                if(!typeSet.contains(String.valueOf(powerSportObj.segmentType)))
                {    
                    typeSet.add(String.valueOf(powerSportObj.segmentType));
                    powersportTypeOptions.add(new SelectOptionWrapper(String.valueOf(powerSportObj.segmentType), String.valueOf(powerSportObj.segmentType)));       
                }
                
            }
        }

        return powersportTypeOptions;
    }

    public static List <SelectOptionWrapper> getModelsPowersports(String powersportType) {
        
        Set<String> modelSet = new Set<String>(); 
        List <SelectOptionWrapper> powersportModelOptions = new List<SelectOptionWrapper>();

        OwnEConfigTempData.ModelDataWrapper powerModelData = OwnEConfigTempData.getPowerModelData();

        if(powerModelData.powersportsRecords.size() > 0)
        {
            for(OwnEConfigTempData.PowerSports powerSportObj : powerModelData.powersportsRecords)
            {
                if(powerSportObj.segmentType == powersportType && !modelSet.contains(String.valueOf(powerSportObj.categoryModel)))
                {
                    modelSet.add(String.valueOf(powerSportObj.categoryModel));
                    powersportModelOptions.add(new SelectOptionWrapper(String.valueOf(powerSportObj.categoryModel), String.valueOf(powerSportObj.categoryModel)));         
                }
                
            }
        }

        return powersportModelOptions;
    }

    public static List <SelectOptionWrapper> getTrimsPowersports(String powersportType, String powersportModel) {
        
        Set<String> modelIdSet = new Set<String>(); 
        List<SelectOptionWrapper> powersportTrimOptions = new List<SelectOptionWrapper>();

        OwnEConfigTempData.ModelDataWrapper powerModelData = OwnEConfigTempData.getPowerModelData();

        if(powerModelData.powersportsRecords.size() > 0)
        {
            for(OwnEConfigTempData.PowerSports powersportObj : powerModelData.powersportsRecords)
            {
                if(powersportObj.segmentType == powersportType &&
                    powersportObj.categoryModel == powersportModel &&
                    !modelIdSet.contains(String.valueOf(powersportObj.modelId)))
                {
                    modelIdSet.add(String.valueOf(powersportObj.modelId));
                    powersportTrimOptions.add(new SelectOptionWrapper(String.valueOf(powersportObj.modelId), String.valueOf(powersportObj.modelGroupTrim)));         
                }
                
            }
        }

        return powersportTrimOptions;
    }

    /*********************************************/
    /*********** For Power Euipments *************/
    /*********************************************/

    public class CompleteDetailsResponseWrapper{
        public Boolean isError;
        public String messages;
        public String errorMessage;
        public String model;
        public EConfigModelColor[] colors;
        public String accessory;
        public String optional;
        public ModelAsset[] assets;
        public String marketingtexts;
        public String displaygroups;

        public CompleteDetailsResponseWrapper()
        {
            colors = new List<EConfigModelColor>();
            assets = new List<ModelAsset>();
        }
    }

    public class EConfigModelColor {
        public String id { get; set; }
        public String name { get; set; }
        public String color_cd { get; set; }
        public String mfg_color_cd { get; set; }
        public String color_type { get; set; }

    }

    // public class EConfigAsset {
    //     public String path { get; set; }
    //     public String asset-color-match { get; set; }
    // }

    // public class ModelAsset {
    //     public String colorId { get; set; }
    //     public String imagePath { get; set; }
    // }

    public class OwnModelColorWrapper {
        public String modelId { get; set; }
        public List<EConfigModelColor> modelColorList { get; set; }
        public List<ModelAsset> modelAssetList { get; set; }

        public OwnModelColorWrapper(String mId)
        {
            modelId = mId;
            modelColorList = new List<EConfigModelColor>();
            ModelAssetList = new List<ModelAsset>();
        }
    }

    //************* Get Honda/ Acura Autos - Colors and Asset (images) related to same Model  */
    // Alexander Dzhitenov: Method does not appear to be in use, can comment out for testing coverage  
    public static OwnModelColorWrapper getModelColorsAndAssets(String modelId, String divisionName) {
        
        OwnModelColorWrapper objOwnModel = new OwnModelColorWrapper(modelId);
        
        CompleteDetailsResponseWrapper objCompleteDetailByModelId = getCompleteDetails(modelId, divisionName);

        if(!objCompleteDetailByModelId.isError)
        {
            if(objCompleteDetailByModelId.colors != null)
            {
                objOwnModel.modelColorList.addAll(objCompleteDetailByModelId.colors);    
            }
            if(objCompleteDetailByModelId.assets != null)
            {
                objOwnModel.modelAssetList.addAll(objCompleteDetailByModelId.assets);    
            }
        }
    
        return objOwnModel;

    }

    //****************** GetCompleteDetails ********************/
    // Alexander Dzhitenov: Method does not appear to be in use, can comment out for testing coverage
    public static CompleteDetailsResponseWrapper getCompleteDetails(String modelId, String divisionName)
    {
        CompleteDetailsResponseWrapper objCompleteDetailByModelId = New CompleteDetailsResponseWrapper();


        //final String APPID = 'automobiles.honda.com';

        try
        {
            //String divisionName = '';
            // if(poiType == 'A'){
            //     divisionName = 'HONDA';
            // } else if(poiType == 'B'){
            //     divisionName = 'ACURA';
            // }
            
            // Sample ModelId = FC3B3KJW

            Http http = new Http();

            // String reqBody = '{   "mit": {"@mit_version_date": "2019-03-10","@mit_version_number": "1",';
            // reqBody +=  '"client_info": {  "@application_id": "' + APPID + '",  "@echo_input": "true",  "@server_ip": "test",  "@session_id": "test",  "@domain": "staging.automobiles.honda.com",  "@environment": "staging"},';
            // reqBody += '"input_parameters": {  "required": {"source_cd": "Honda","site_cd": "Honda","category_cd": "CONFIG","division": { "@version_num": "0", "#text": "A"},';
            // reqBody += '"models": { "model": {   "@id": "'+ modelId +'" }}  },';
            // reqBody += '"optional": {"assets": { "@suppress_asset_name": "true", "@suppress_asset_description": "true", "asset": [{  "@type_cd": "IMGMIDSIZE",  "@view_cd": "34FRONT",  "@source_cd": "HONDA"},{  "@type_cd": "BASECAR",  "@view_cd": "34FRONT",  "@source_cd": "HONDA"},{  "@type_cd": "IMGMIDSIZE",  "@view_cd": "34FRONT",  "@source_cd": "ACURA"}]   },   "fifs": {   "@return_fifs": "true",   "fif": {"@category_cd": "T"   } }}},';
            // reqBody += '"private": {  "template_info": {"@class": "Model","@filename": "Model-GetModelCompleteDetails-MIT.xml","@xsd": "Model-GetModelCompleteDetails-MIT.xsd","@method": "GetModelCompleteDetails"  },  "stored_procedure": {"@name": "ecnetsp_Model_GetModelCompleteDetails"  }}   } }';

            
            //HttpRequest request = getEConfigRequest('GetCompleteDetails', reqBody);
            HttpRequest request = getEConfigRequest('GetCompleteDetails', modelId, divisionName);

            HTTPResponse response = http.send(request);
            
            //******** Create API Log   ********/
            //OwnApiRequestLogger.log('OwnEConfigApiHelper.getCompleteDetails', 'EConfig', request, response);
    


            //response = getCompleteDetail2();

            System.debug('==ResponseBody=='+response.getbody());
            System.debug('==ResponseBody=='+response);

            String responseBody = response.getbody();

            //Temp Testing local method
            
            //responseBody = getCompleteDetail2();    

            if(responseBody.contains('db_results')){
                responseBody = responseBody.remove('@');
                responseBody = responseBody.remove('#');   
            }           
            System.debug('responseBody2 :' + responseBody);

            

            Map<String, Object> completeDetailResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
            Map<String, Object> mapResponseLevel1 = (Map<String, Object>)completeDetailResponse.get('mot');
            String isError = '';
            String errorDescription ='';
            
            if(mapResponseLevel1.containsKey('Error')){
                isError = (String)mapResponseLevel1.get('Error');
                if(mapResponseLevel1.containsKey('Error')){
                    Map<String, Object> errorMap = (Map<String, Object>)mapResponseLevel1.get('Error');
                    if(errorMap.containsKey('Description')){
                        errorDescription = JSON.serialize(errorMap.get('Description'));
                    }
                }
                
                if(isError == 'true')
                {
                    objCompleteDetailByModelId.isError = true;
                    objCompleteDetailByModelId.errorMessage = ErrorDescription;
                }
                
                System.debug('There is some problem!');
            }
            else
            {
                System.debug('objCompleteDetail Info:' + objCompleteDetailByModelId);

                try 
                {
                    //add optional to wrapper
                    Map<String, Object> mapOptionalResult = (Map<String, Object>)mapResponseLevel1.get('input_parameters');
                    objCompleteDetailByModelId.optional = JSON.serialize(mapOptionalResult.get('optional')); 
                    //add values to wrapper 
                    Map<String, Object> mapDbResult = (Map<String, Object>)mapResponseLevel1.get('db_results');
                    Map<String, Object> mapMessages = (Map<String, Object>)mapDbResult.get('messages');
                    Map<String, Object> mapModels = (Map<String, Object>)mapDbResult.get('models');               
                    Map<String, Object> mapColors = (Map<String, Object>)mapDbResult.get('colors');               
                    Map<String, Object> mapAccessories = (Map<String,Object>)mapDbResult.get('accessories');
                    Map<String, Object> mapAssets = (Map<String,Object>)mapDbResult.get('assets');
                    //Map<String, Object> mapDisplaygroups = (Map<String,Object>)mapDbResult.get('displaygroups');
                    //Map<String, Object> mapMarketingtexts = (Map<String,Object>)mapDbResult.get('marketingtexts');
                
                    objCompleteDetailByModelId.isError = false;
                    objCompleteDetailByModelId.messages = JSON.serialize(mapMessages.get('message'));                
                    objCompleteDetailByModelId.model = JSON.serialize(mapModels.get('model'));
                    objCompleteDetailByModelId.colors = parseModelColors((List<object>)mapColors.get('color'));
                    objCompleteDetailByModelId.accessory = JSON.serialize(mapAccessories.get('accessory'));
                    objCompleteDetailByModelId.assets = parseModelAssets((List<object>)mapAssets.get('asset'));

                }
                catch(Exception ex)
                {
                    System.debug('Exception Info:' + ex.getCause() + ' - ' + ex.getMessage() + 'Line No: ' + ex.getLineNumber());
                }
                

                System.debug('objCompleteDetail Info:' + objCompleteDetailByModelId);
                //objCompleteDetailByModelId.displaygroups = JSON.serialize(mapDisplaygroups.get('displaygroup'));
                //objCompleteDetailByModelId.marketingtexts = JSON.serialize(mapMarketingtexts.get('text'));
                
            }

        }
        catch(Exception ex) {
            objCompleteDetailByModelId.isError = true;
            objCompleteDetailByModelId.errorMessage = ex.getMessage();
        }

        //System.debug('--SerializedResponseBody---' + JSON.serialize(objCompleteDetailByModelId));
       
        return objCompleteDetailByModelId;
        //return JSON.serialize(objCompleteDetailByModelId);

    }

    public static List<EConfigModelColor> parseModelColors(List<Object> eConfigModelColors)
    {
        List<EConfigModelColor> retModelColors = new List<EConfigModelColor>();
        for(Object modelColorObj : eConfigModelColors)
        {
            retModelColors.add((EConfigModelColor) JSON.deserialize(JSON.serialize(modelColorObj) , EConfigModelColor.class));
        }

        return retModelColors;
    }

    public static List<ModelAsset> parseModelAssets(List<Object> eConfigModelAssets)
    {
        List<ModelAsset> retModelAssets = new List<ModelAsset>();        
        Boolean hasError = false;
        String errorMessage = '';

        for(Object modelAssetObj : eConfigModelAssets)
        {
            try {

                ModelAsset modelAst = new ModelAsset();
                Map<String, Object> assetMap = (Map<String, Object>) modelAssetObj;

                System.debug('Test AssetMap:' + assetMap);

                if(assetMap.containsKey('path'))
                {
                    modelAst.imagePath = HONDA_AUTOS_ASSET_URL + (String) assetMap.get('path');
                }
                
                if(assetMap.containsKey('asset-color-match'))
                {
                    Map<String, Object> assetColorMatchMap = (Map<String, Object>) assetMap.get('asset-color-match');
                    Map<String, Object> colorMap = (Map<String, Object>) assetColorMatchMap.get('color');
                    
                    modelAst.colorId = (string) colorMap.get('id');
                }

                retModelAssets.add(modelAst);


            }
            catch(Exception ex)
            {
                hasError = true;
                errorMessage += '\r\n' + ' Error: ' + + ex.getMessage() + '- Line:' + ex.getLineNumber() + ' - ModelAsset:' + modelAssetObj;
                
                continue;
            }
            
        }

        if(hasError)
        {
            //OwnAppLogger.log('OwnEConfigApiHelper.parseModelAssets', 'Error:' + errorMessage, OwnAppLogger.LogLevel.ERROR);
        }

        return retModelAssets;
    }

    //****************** GetCompleteDetail End ********************/

    // Alexander Dzhitenov: Method does not appear to be in use, can comment out for testing coverage
    public static HttpRequest getEConfigRequest(String methodName,String modelId, String divisionName){
        
       
        HttpRequest request = new HttpRequest();
        
        //String finalurl = 'https://ws-qa4.hondaweb.com';
        String finalurl = 'callout:EConfig_BaseEndPoint';
        
        if(methodName == 'GetCompleteDetails'){

            
            String configurationName = '';

            if(divisionName.toUpperCase() == 'HONDA') { configurationName = 'GetCompleteDetailsHonda'; }
            if(divisionName.toUpperCase() == 'ACURA') { configurationName = 'GetCompleteDetailsAcura'; }

            OwnEConfigApiSetting__mdt eConfigApiSetting = [Select DeveloperName, AppId__c, ApplicationId__c,
                                                        Authorization__c, CheckSum__c, ClientDomain__c,
                                                        Environment__c, Domain__c, 
                                                        HondaWlAuthorization__c,
                                                        ServerIP__c 
                                                        FROM OwnEConfigApiSetting__mdt
                                                        WHERE DeveloperName = :configurationName limit 1];

            System.debug('==eConfigApiSetting ===' + eConfigApiSetting);

            // Step 1: Set API URL Parameters
            //finalurl = 'https://ws-qa4.hondaweb.com/REST/B2C/GetModelCompleteDetails/1.0/?appid=marketplace.honda.com';            
            //finalurl = finalurl + '/api/Model/GetCompleteDetails?appid=marketplace.honda.com';
            finalUrl += '/REST/B2C/GetModelCompleteDetails/1.0/?appid='+ eConfigApiSetting.AppId__c;

            // Step 2: Set API request Header
            //String guId = OwnUtilCls.createGuid();
            String guId = OwnHttpCalloutService.getGUID();
            request.setHeader('accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + eConfigApiSetting.Authorization__c);
            request.setHeader('ClientDomain', eConfigApiSetting.ClientDomain__c);
            request.setHeader('X-Honda-wl-authorization', eConfigApiSetting.HondaWlAuthorization__c);
            request.setHeader('hondaHeaderType.messageId', guId);
            request.setMethod('POST');

            // Step 3: Set request body
            String reqBody = '';
            if(divisionName == 'Honda')
            {
                reqBody = '{ "mit": {"@mit_version_date": "2019-03-10","@mit_version_number": "1",';
                reqBody +=  '"client_info": {  "@application_id": "' + eConfigApiSetting.ApplicationId__c + '",  "@echo_input": "true",  "@server_ip": "' + eConfigApiSetting.ServerIP__c + '",  "@session_id": "test",  "@domain": "' + eConfigApiSetting.Domain__c + '",  "@environment": "' + eConfigApiSetting.Environment__c + '"},';
                reqBody += '"input_parameters": {  "required": {"source_cd": "Honda","site_cd": "Honda","category_cd": "CONFIG","division": { "@version_num": "0", "#text": "A"},';
                reqBody += '"models": { "model": {   "@id": "'+ modelId +'" }}  },';
                reqBody += '"optional": {"assets": { "@suppress_asset_name": "true", "@suppress_asset_description": "true", "asset": [{  "@type_cd": "IMGMIDSIZE",  "@view_cd": "34FRONT",  "@source_cd": "HONDA"},{  "@type_cd": "BASECAR",  "@view_cd": "34FRONT",  "@source_cd": "HONDA"},{  "@type_cd": "IMGMIDSIZE",  "@view_cd": "34FRONT",  "@source_cd": "ACURA"}]   },';   
                reqBody += '"fifs": {   "@return_fifs": "true",   "fif": {"@category_cd": "T"   } }}},';
                reqBody += '"private": {  "template_info": {"@class": "Model","@filename": "Model-GetModelCompleteDetails-MIT.xml","@xsd": "Model-GetModelCompleteDetails-MIT.xsd","@method": "GetModelCompleteDetails"  },  "stored_procedure": {"@name": "ecnetsp_Model_GetModelCompleteDetails"  }}   } }';
            }

            request.setBody(reqBody);                                                    

        }/*else if(methodName == 'GetAccessoriesByBrand'){
            finalurl = 'https://test.econfig2.services.honda.com/api/Accessory/GetAccessoriesForBrand?appid=marketplace.honda.com';
        }*/
        
        System.debug('finalUrl: ' + finalUrl);

        request.setEndpoint(finalurl);
        
        System.debug('==Http Request ===' + request);
        //HTTPResponse response = http.send(request);

        return request;
   }

   /*
        This method is to Econfig Vin Decoder web Service
        This will provide a json string containing vehical detail
        vinNumber = 'XXXXXXX', poiType = {'A','B','M','P'}
        Sample VIN = '2HKRM3H53GH500289', poiType = 'A'
    */

    public static String getModelByVin(String vinNumber, String poiType){
        return getModelByVin(vinNumber, poiType, '');
    }

    public static String getModelByVin(String vinNumber, String poiType, String divisionName){

        VinDecoderResponse vinDecoderResObj = new VinDecoderResponse();
    
        try{

            HttpResponse response = new HttpResponse();

            // Identify whether or not subdivision code should be included in the callout
            String subdivisionPOITypesStr = Own_Division_Config__mdt.getInstance('Contains_Subdivisions').Division_Code_List__c;
            Set<String> subdivisionPOITypeSet = new Set<String>();
            subdivisionPOITypeSet.addAll(subdivisionPOITypesStr.deleteWhitespace().split(','));
            System.debug('OWN E CONFIG API HELPER: ' + divisionName);

            // Make callout, retrieving subdivision codes from metadata if necessary
            if (subdivisionPOITypeSet.contains(poiType)){
                String subdivisionCode;
                List<Own_Divisions__mdt> divisionCodes = Own_Divisions__mdt.getAll().values();
                for (Own_Divisions__mdt division : divisionCodes){
                    if (division.Label == divisionName){
                        subdivisionCode = division.Subdivision_Code__c;
                    }
                }
                System.debug('OWN E CONFIG API HELPER: ' + subdivisionCode);
                response = OwnAPIController.vinMasterSearch(vinNumber, poiType, subdivisionCode);
            }
            else{
                response = OwnAPIController.vinMasterSearch(vinNumber, poiType);
            }

            System.debug('@@TestResponseBody==='+ JSON.serialize(response.getBody()));

            String responseBody = response.getBody();

            if(responseBody.contains('db_results')){
                responseBody = responseBody.remove('@');
                responseBody = responseBody.remove('#');   
            }

            Map<String, Object> vinResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> mapResponseLevel1 = (Map<String, Object>) vinResponse.get('mot');
            ModelDetail modelDetailObj = new ModelDetail();
            //modelDetailObj.color = new ModelColor();
            //modelDetailObj.assets = new List<ModelAsset>();

            if(!mapResponseLevel1.isEmpty() && mapResponseLevel1.containsKey('Error') /* && (Map<String, Object>)mapResponseLevel1.get('Error') == 'true' */){
                System.debug('OwnEConfigApiHelper: Error');
                Map<String, Object> mapError = (Map<String, Object>) mapResponseLevel1.get('Error');
                String errorDescription = (String) mapError.get('Description');
                vinDecoderResObj.isError = true;
                vinDecoderResObj.message = errorDescription;
                vinDecoderResObj.modelDetail = modelDetailObj;
            }
            else {  // No error detected from response
                // API response for Autos/Powersports/Marine/PE is different, so must be handled differently
                /* if (poiType == 'A' || poiType == 'B'){
                    Map<String, Object> mapDbResult = (Map<String, Object>)mapResponseLevel1.get('db_results');
                    Map<String, Object> mapVins = (Map<String, Object>)mapDbResult.get('vins');
                    List<Object> listVin = (List<Object>) mapVins.get('vin');
                    Map<String, Object> firstVin = (Map<String, Object>) listVin[0];
                    //List<ModelDetail> vinResultList = fillResultsFromAPIResponse(listVin, vinDecoderResObj);
                    vinDecoderResObj = fillResultsFromAPIResponse(listVin, vinDecoderResObj, poiType);
                }
                else  */if (poiType == 'A' || poiType == 'B' || poiType == 'M'){
                    System.debug(JSON.serialize(mapResponseLevel1));
                    Map<String, Object> mapDbResult = (Map<String, Object>)mapResponseLevel1.get('db_results');
                    /* System.debug(JSON.serialize(mapDbResult));
                    Map<String, Object> models = (Map<String, Object>)mapDbResult.get('models');
                    System.debug(JSON.serialize(models));
                    Map<String, Object> model = (Map<String, Object>)models.get('model'); */
                    Map<String, Object> mapVins = (Map<String, Object>)mapDbResult.get('vins');
                    List<Object> listVin = (List<Object>) mapVins.get('vin');
                    Map<String, Object> firstVin = (Map<String, Object>) listVin[0];
                    Map<String, Object> model = (Map<String, Object>) firstVin.get('model');

                    modelDetailObj.vinNumber = (string) firstVin.get('number');

                    vinDecoderResObj = fillResultsFromDatabase(modelDetailObj, model, vinDecoderResObj);
                }
                else if (poiType == 'P'){
                    Map<String, Object> mapDbResult = (Map<String, Object>)mapResponseLevel1.get('db_results');
                    Map<String, Object> mapVins = (Map<String, Object>)mapDbResult.get('vins');
                    List<Object> listVin = (List<Object>) mapVins.get('vin');
                    Map<String, Object> firstVin = (Map<String, Object>) listVin[0];
                    //List<ModelDetail> vinResultList = fillResultsFromAPIResponse(listVin, vinDecoderResObj);
                    vinDecoderResObj = fillResultsFromAPIResponse(listVin, vinDecoderResObj, poiType);
                }
            }
        }catch(Exception ex){
            vinDecoderResObj.isError = true;
            vinDecoderResObj.message = ex.getMessage() + 'LineNumber'+ex.getLineNumber();
        }

        System.debug('SerializedResponse'+ JSON.serialize(vinDecoderResObj));
        
        // Temp App log
        //OwnAppLogger.log('OwnEConfigApiHelper.getModelByVin', JSON.serialize(vinDecoderResObj), OwnAppLogger.LogLevel.INFORMATION);

        return JSON.serialize(vinDecoderResObj);
    }

    private static VinDecoderResponse fillResultsFromAPIResponse(List<Object> vinList, VinDecoderResponse vinDecoderResObj, String poiType){
        List<ModelDetail> modelList = new List<ModelDetail>();
        Boolean allError = true;
        for (Object vinObj : vinList){
            Map<String, Object> vin = (Map<String, Object>) vinObj;
            ModelDetail modelDetailObj = new ModelDetail();
            if(vin.containsKey('error_action')){
                modelDetailObj.isError = true;
                modelDetailObj.errorAction = (String) vin.get('error_action');
                modelDetailObj.message = (String) vin.get('error_reason');
            }else{
                //System.debug('%%%%%% SIZE %%%%%%%% ' + modelList.size());
                if (poiType == 'A' || poiType == 'B' || poiType == 'M'){
                    modelDetailObj.vinNumber = (string) vin.get('number');
                }
                Map<String, Object> mapModel = (Map<String, Object>) vin.get('model');
                /* Depending on brand type {Auto, powersports} model properties may exists or not 
                    so, needs to check individual properties. 
                */
                if(!mapModel.isEmpty()){
                    if(mapModel.containskey('id')){
                        modelDetailObj.modelId = (String)mapModel.get('id');
                    }
                    if(mapModel.containskey('trim_name')){
                        modelDetailObj.trim = (String)mapModel.get('trim_name');
                    }                   
                    if(mapModel.containskey('trans_name')){
                        modelDetailObj.trans = (String)mapModel.get('trans_name');
                    }
                    if(mapModel.containskey('make')){
                        modelDetailObj.make = (String)mapModel.get('make');
                    }
                    if(mapModel.containskey('model_name')){
                        modelDetailObj.modelName = (String)mapModel.get('model_name');
                    }
                    if(mapModel.containskey('model_group_name')){
                        modelDetailObj.modelGroupName = (String)mapModel.get('model_group_name');
                    }
                    if(mapModel.containskey('model_year')){
                        modelDetailObj.year = (String)mapModel.get('model_year');
                    }
                    if(mapModel.containsKey('colors')){
                        modelDetailObj = fillColorsAndAssetsFromResponse(modelDetailObj, mapModel);
                    }
                    if(mapModel.containsKey('product_line_cd')){
                        modelDetailObj.categoryCd = (String)mapModel.get('product_line_cd');
                    }
                    
    
                } //# end else section
    
                modelDetailObj.isError = false;
                modelDetailObj.message = '';
                allError = false;
            }
            modelList.add(modelDetailObj);
        }

        if (modelList.size() == 1){
            vinDecoderResObj.modelDetail = modelList[0];
            vinDecoderResObj.isError = modelList[0].isError;
            vinDecoderResObj.errorAction = modelList[0].errorAction;
            vinDecoderResObj.message = modelList[0].message;
        }
        else if (modelList.size() > 1){
            vinDecoderResObj.modelDetailList = modelList;
            vinDecoderResObj.isError = allError;
        }
        else{
            vinDecoderResObj.isError = true;
        }

        //vinDecoderResObj.isError = false;
        
        return vinDecoderResObj;
    }

    private static ModelDetail fillColorsAndAssetsFromResponse(ModelDetail modelDetailObj, Map<String, Object> mapModel){
        if(mapModel.containskey('colors')){
            Map<String, Object> colorsMap = (Map<String, Object>) mapModel.get('colors');
            List<Object> colors = (List<Object>) colorsMap.get('color');
            for(Object colorObj : colors)
            {
                Map<String, Object> colorInfoMap = (Map<String, Object>) colorObj;
                if(colorInfoMap.containsKey('color_type') && colorInfoMap.get('color_type') == 'E')
                {
                    modelDetailObj.color.id = (String) colorInfoMap.get('id');
                    modelDetailObj.color.name = (String) colorInfoMap.get('name');
                    modelDetailObj.color.mfg_color_cd = (String) colorInfoMap.get('mfg_color_cd');
                }

                if(colorInfoMap.containsKey('assets') && colorInfoMap.get('assets') != NULL)
                {
                    Map<String, Object> assetsMap = (Map<String, Object>) colorInfoMap.get('assets');
                    List<Object> assets = (List<Object>) assetsMap.get('asset');

                    for(Object assetObj : assets)
                    {
                        Map<String, Object> assetInfoMap = (Map<String, Object>) assetObj;
                        if(assetInfoMap.containsKey('type_cd'))
                        {
                            ModelAsset modelAsset = new ModelAsset();
                            modelAsset.colorId = (String) assetInfoMap.get('id');
                            modelAsset.imagePath = (String) assetInfoMap.get('path');
                            if (modelAsset.assetType == ModelAssetType.BASECAR || modelAsset.assetType == ModelAssetType.IMGMIDSIZE){
                                modelAsset.assetType = getModelAssetType((string) assetInfoMap.get('type_cd'));
                            }

                            modelDetailObj.assets.add(modelAsset);
                        }
                        
                    } // # end of inner for - 
                }
                
            } // # end of outer for - 
            
        } //# end if Map is Empty()

        return modelDetailObj;
    }

    private static VinDecoderResponse fillResultsFromDatabase(ModelDetail modelDetailObj, Map<String, Object> model, VinDecoderResponse vinDecoderResObj){
        
        modelDetailObj.modelId = (String) model.get('id');
        //modelDetailObj.color.mfg_color_cd = (String) model.get('exterior_mfg_color_cd');
        if (model.containsKey('colors')){
            modelDetailObj = fillColorsAndAssetsFromResponse(modelDetailObj, model);
        }
        
        System.debug('%%% ' + modelDetailObj.modelId);
        // Fill out model details from SF database, rather than API response - used for Powersports VINs. Return error if a record with a matching modelId is not found.
        List<Product_Model__c> pmMatch = [SELECT Id, Product_Model_Id__c, Model_Year__c, Model_Name__c, Trim__c, (SELECT Id, Exterior_Color_Name__c, Manufacturer_Color_Code__c, Large_Image_URL__c, Thumbnail_Image_URL__c FROM Product_Model_Colors__r WHERE Manufacturer_Color_Code__c=:modelDetailObj.color.mfg_color_cd) FROM Product_Model__c WHERE Product_Model_Id__c=:modelDetailObj.modelId];

        if (pmMatch.size() > 0){

            Product_Model__c pm = pmMatch[0];

            modelDetailObj.year = pm.Model_Year__c;
            modelDetailObj.modelGroupName = pm.Model_Name__c;
            modelDetailObj.trim = pm.Trim__c;
    
            if (pm.Product_Model_Colors__r.size() > 0){
                modelDetailObj.color.name = pm.Product_Model_Colors__r[0].Exterior_Color_Name__c;
                modelDetailObj.assets.add(new ModelAsset(   (pm.Product_Model_Colors__r[0].Large_Image_URL__c != null
                                                            ? pm.Product_Model_Colors__r[0].Large_Image_URL__c 
                                                            : pm.Product_Model_Colors__r[0].Thumbnail_Image_URL__c), ModelAssetType.BASECAR));
            }
            vinDecoderResObj.modelDetail = modelDetailObj;
            vinDecoderResObj.isError = false;
        }
        else{
            System.debug('%%% Model not found %%%');
            vinDecoderResObj.isError = true;
            vinDecoderResObj.message = 'Your VIN is currently not supported by MyGarage.';
            vinDecoderResObj.modelDetail = modelDetailObj;
            sendVinDatabaseErrorEmail(modelDetailObj, model);
        }
        return vinDecoderResObj;
    }

    private static void sendVinDatabaseErrorEmail(ModelDetail modelDetailObj, Map<String, Object> model){
        Email_List__mdt emailList = [SELECT Label, Email_Addresses__c FROM Email_List__mdt WHERE Label = 'VIN Database Error'];
        String emailAddresses = emailList.Email_Addresses__c.deleteWhitespace();

        Messaging.SingleEmailMessage vinDatabaseErrorEmail = new Messaging.SingleEmailMessage();
        vinDatabaseErrorEmail.setToAddresses(emailAddresses.split(','));
        vinDatabaseErrorEmail.setSubject('Product not found in product model');

        String emailBody = 'Hi,\n\n';
        emailBody += 'The following product is not available in the Product Model object: \n\n';
        emailBody += (String) model.get('model_year') + ' ' + (String) model.get('model_name') + '\n';
        emailBody += 'Division Id: ' + (String) model.get('division_cd') + '\n';
        emailBody += 'Model Id: ' + (String) model.get('id') + '\n\n';
        emailBody += 'A product with the VIN ' + modelDetailObj.vinNumber + ' was searched for and returned a result, but a corresponding Product Model record was not found in the database.';

        vinDatabaseErrorEmail.setPlainTextBody(emailBody);


        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{vinDatabaseErrorEmail});
    }

    public static ECRMResult getGarageProductFromECRM(String vin, String divisionId){
        VinDecoderResponse responseObject = (VinDecoderResponse) JSON.deserialize(getModelByVin(vin, divisionId), VinDecoderResponse.class);

        ECRMResult result = new ECRMResult();

        if (!responseObject.isError){
            result.isError = false;
            OwnGarageController.Product product = new OwnGarageController.Product();
            System.debug(responseObject.modelDetail);
            product.vin = responseObject.modelDetail.vinNumber;
            product.divisionId = divisionId;
            product.division = OwnGarageController.getDivisionNameFromCode(divisionId);
            product.year = responseObject.modelDetail.year;
            product.modelId = responseObject.modelDetail.modelId;
            product.model = responseObject.modelDetail.modelGroupName;
            product.trim = responseObject.modelDetail.trim;
            product.color = new OwnGarageController.ModelColor();
    
            /* System.debug('vin: ' + product.vin);
            System.debug('divisionId: ' + product.divisionId);
            System.debug('division: ' + product.division);
            System.debug('year: ' + product.year);
            System.debug('modelId: ' + product.modelId);
            System.debug('model: ' + product.model);
            System.debug('trim: ' + product.trim);
            System.debug('color: ' + product.color); */
    
            product.color.name = responseObject.modelDetail.color.name;
            product.color.mfg_color_cd = responseObject.modelDetail.color.mfg_color_cd;

            if (divisionId == 'P'){

            }
    
            String imgUrl = '';
            String imgUrlTemp = '';
    
            for (ModelAsset asset : responseObject.modelDetail.assets){
                if (asset.assetType == ModelAssetType.IMGMIDSIZE){
                    imgUrl = asset.imagePath;
                }
                else if (asset.assetType == ModelAssetType.BASECAR){
                    imgUrlTemp = asset.imagePath;
                }
            }
    
            product.image = !String.isEmpty(imgUrl) ? imgUrl : imgUrlTemp;
    
            System.debug('OwnEconfigApiHelper product:');
            System.debug(product);
            result.product = product;
        }
        else{
            result.isError = true;
        }
        

        return result;
    }

    /* public static ECRMResult getGarageProductFromResponse(String apiResponse, String divisionId){
        
        String responseBody = apiResponse;
        String poiType = divisionId;
        VinDecoderResponse vinDecoderResObj = new VinDecoderResponse();

        if(responseBody.contains('db_results')){
            responseBody = responseBody.remove('@');
            responseBody = responseBody.remove('#');   
        }

        Map<String, Object> vinResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> mapResponseLevel1 = (Map<String, Object>) vinResponse.get('mot');
        ModelDetail modelDetailObj = New ModelDetail();

        if(!mapResponseLevel1.isEmpty() && mapResponseLevel1.containsKey('Error') && (String)mapResponseLevel1.get('Error') == 'true'){
            Map<String, Object> mapError = (Map<String, Object>) mapResponseLevel1.get('Error');
            String errorDescription = (String) mapError.get('Description');
            vinDecoderResObj.isError = true;
            vinDecoderResObj.message = errorDescription;
            vinDecoderResObj.modelDetail = modelDetailObj;
        }
        // No error detected from response
        else {
            Map<String, Object> mapDbResult = (Map<String, Object>)mapResponseLevel1.get('db_results');
            Map<String, Object> mapVins = (Map<String, Object>)mapDbResult.get('vins');
            List<Object> listVin = (List<Object>) mapVins.get('vin');
            Map<String, Object> firstVin = (Map<String, Object>) listVin[0];
            if(firstVin.containsKey('error_action')){
                vinDecoderResObj.isError = true;
                vinDecoderResObj.errorAction = (String) firstVin.get('error_action');
                vinDecoderResObj.message = (String) firstVin.get('error_reason');
                vinDecoderResObj.modelDetail = modelDetailObj;
            }else{

                modelDetailObj.vinNumber = (string) firstVin.get('number');
                    
                Map<String, Object> mapModel = (Map<String, Object>) firstVin.get('model');

                //Depending on brand type {Auto, powersports} model properties may exists or not 
                //    so, needs to check individual properties. 
                if(!mapModel.isEmpty())
                {
                    if(mapModel.containskey('id')){
                        modelDetailObj.modelId = (String)mapModel.get('id');
                    }
                    if(mapModel.containskey('trim_name')){
                        modelDetailObj.trim = (String)mapModel.get('trim_name');
                    }                   
                    if(mapModel.containskey('trans_name')){
                        modelDetailObj.trans = (String)mapModel.get('trans_name');
                    }
                    if(mapModel.containskey('make')){
                        modelDetailObj.make = (String)mapModel.get('make');
                    }
                    if(mapModel.containskey('model_name')){
                        modelDetailObj.modelName = (String)mapModel.get('model_name');
                    }
                    if(mapModel.containskey('model_group_name')){
                        modelDetailObj.modelGroupName = (String)mapModel.get('model_group_name');
                    }
                    if(mapModel.containskey('model_year')){
                        modelDetailObj.year = (String)mapModel.get('model_year');
                    }
                    if(mapModel.containskey('colors')){
                        Map<String, Object> colorsMap = (Map<String, Object>) mapModel.get('colors');
                        List<Object> colors = (List<Object>) colorsMap.get('color');
                        for(Object colorObj : colors)
                        {
                            Map<String, Object> colorInfoMap = (Map<String, Object>) colorObj;
                            if(colorInfoMap.containsKey('color_type') && colorInfoMap.get('color_type') == 'E')
                            {
                                modelDetailObj.color.id = (String) colorInfoMap.get('id');
                                modelDetailObj.color.name = (String) colorInfoMap.get('name');
                                modelDetailObj.color.mfg_color_cd = (String) colorInfoMap.get('mfg_color_cd');
                            }

                            if(colorInfoMap.containsKey('assets'))
                            {
                                Map<String, Object> assetsMap = (Map<String, Object>) colorInfoMap.get('assets');
                                List<Object> assets = (List<Object>) assetsMap.get('asset');

                                for(Object assetObj : assets)
                                {
                                    Map<String, Object> assetInfoMap = (Map<String, Object>) assetObj;
                                    if(assetInfoMap.containsKey('type_cd'))
                                    {
                                        ModelAsset modelAsset = new ModelAsset();
                                        modelAsset.colorId = (String) assetInfoMap.get('id');
                                        modelAsset.imagePath = (String) assetInfoMap.get('path');
                                        modelAsset.assetType = getModelAssetType((string) assetInfoMap.get('type_cd'));

                                        modelDetailObj.assets.add(modelAsset);
                                    }
                                    
                                } // # end of inner for - 
                            }
                            
                        } // # end of outer for - 
                        
                    } //# end if Map is Empty()

                } //# end else section
            }
        }

        VinDecoderResponse responseObject = vinDecoderResObj;

        ECRMResult result = new ECRMResult();

        if (!responseObject.isError){
            result.isError = false;
            OwnGarageController.Product product = new OwnGarageController.Product();
            System.debug(responseObject.modelDetail);
            product.vin = responseObject.modelDetail.vinNumber;
            product.divisionId = divisionId;
            product.division = OwnGarageController.getDivisionNameFromCode(divisionId);
            product.year = responseObject.modelDetail.year;
            product.modelId = responseObject.modelDetail.modelId;
            product.model = responseObject.modelDetail.modelGroupName;
            product.trim = responseObject.modelDetail.trim;
            product.color = new OwnGarageController.ModelColor();
    
            product.color.name = responseObject.modelDetail.color.name;
            product.color.mfg_color_cd = responseObject.modelDetail.color.mfg_color_cd;
    
            String imgUrl = '';
            String imgUrlTemp = '';
    
            for (ModelAsset asset : responseObject.modelDetail.assets){
                if (asset.assetType == ModelAssetType.IMGMIDSIZE){
                    imgUrl = asset.imagePath;
                }
                else if (asset.assetType == ModelAssetType.BASECAR){
                    imgUrlTemp = asset.imagePath;
                }
            }
    
            product.image = !String.isEmpty(imgUrl) ? imgUrl : imgUrlTemp;
    
            System.debug('OwnEconfigApiHelper product:');
            System.debug(product);
            result.product = product;
        }
        else{
            result.isError = true;
        }

        return result;
    } */

    public class ECRMResult {
        public OwnGarageController.Product product;
        public Boolean isError;
    }


    /*
        This method is to Econfig Vin Decoder web Service
        This will provide a json string containing vehical detail
        vinNumber = 'XXXXXXX', poiType = {'A','B','M','P'}
        Sample VIN = '2HKRM3H53GH500289'
    */

    // Alexander Dzhitenov: Method does not appear to be in use, can comment out for testing coverage
    public static String callVinDecoderService2(String vinNumber, String poiType){
        
        VinDecoderResponse vinDecoderResObj = New VinDecoderResponse();
        
        try{
            
            String applicationId = 'powersports.honda.com';
            String checkSum = 'B3F3AC36024C63D310EED8EB81E61C3AF06697E412D3BAE660B5ECC623BE4E69 ';
            String domain = 'prestage2.powersports.honda.com';
            String environment = 'prestage';
            String serverIp = 'test';
            String sessionId = 'test';


            // B2B_Econfig_Request__mdt objMetaData = [Select B2B_Application_Id__c,B2B_Check_sum__c,B2B_Domain__c,B2B_Environment__c,B2B_Server_IP__c,B2B_Session_Id__c from  B2B_Econfig_Request__mdt where DeveloperName = 'VinDecoderRequest'];
            // System.debug('metadata' + objMetadata);

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //VinDecoderRequestSetting__c vinSetting = VinDecoderRequestSetting__c.getInstance();
            
            String reqBody = '{"mit": {"@mit_version_number": "1","@mit_version_date": "2018-04-12",';
            reqBody += '"client_info":'+ '{"@application_id":"'+ applicationId +'","@echo_input": "true","@server_ip":"'+ serverIp +'","@session_id":"'+ sessionId +'","@domain":"'+ domain;
            reqBody += '","@environment":"'+ environment +'"},"input_parameters": {"required": {"vins": {"vin": {"@vin_number": "'+vinNumber+'","@division_cd":"'+poiType;
            reqBody += '"}}}},'+'"private": {"@check_sum":"'+ checkSum +'","template_info": {"@class": "Model","@filename": "Model-GetModelByVin-MIT.xml","@method": "GetModelByVIN","@xsd": "Model-GetModelByVin-MIT.xsd"},"stored_procedure": {"@name": "ecnetsp_Model_GetModelByVIN"}}}}';
            
            System.debug('RequestBody==='+reqBody);
            
            //request = B2B_IntegrationCallout.eConfigRequest('GetModelByVIN',reqBody) ;        
            //HttpRequest request = new HttpRequest();

            //String guId = OwnUtilCls.createGuid();
            String guId = OwnHttpCalloutService.getGUID();
            request.setHeader('accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJDbGllbnRBcHBsaWNhdGlvbklEIjoibWFya2V0cGxhY2UuaG9uZGEuY29tIiwiQ2xpZW50RG9tYWluIjoidGVzdC5tYXJrZXRwbGFjZS5ob25kYS5jb20iLCJUb2tlbklEIjoiMTYxNzMwMTU0ODcxOCIsImlzcyI6ImVjb25maWcuc2VydmljZXMuaG9uZGEuY29tIiwiYXVkIjoidGVzdF90ZXN0LmVjb25maWcyLnNlcnZpY2VzLmhvbmRhLmNvbSJ9.oPgrcIL4IrEJce70I5pPajGmvhg41PKtgCPOgHQdclY');
            request.setHeader('ClientDomain', 'test.marketplace.honda.com');
            request.setHeader('X-Honda-wl-authorization', ' Basic c2VydmljZV9iMmNfaGRtX3FhOkVhcnRoIzc0');
            request.setHeader('hondaHeaderType.messageId', guId);
            request.setMethod('POST');
            request.setBody(reqBody);
            String finalurl='';
            finalurl = 'https://ws-qa4.hondaweb.com/'+'REST/B2C/GetModelByVin/1.0/?appid=marketplace.honda.com';
            
            request.setEndpoint(finalurl);

            HTTPResponse response = http.send(request);

            //******** Create API Log   ********/
            //OwnApiRequestLogger.log('OwnEConfigApiHelper.callVinDecoderService', 'EConfig', request, response);

            System.debug('ResponseBody==='+ response.getBody());
            Map<String, Object> vinResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> mapResponseLevel1 = (Map<String, Object>) vinResponse.get('mot');
            ModelDetail objModelDetail = New ModelDetail();
            if(!mapResponseLevel1.isEmpty() && mapResponseLevel1.containsKey('@Error') && (String)mapResponseLevel1.get('@Error') == 'true'){
                Map<String, Object> mapError = (Map<String, Object>)mapResponseLevel1.get('Error');
                String errorDescription = (String)mapError.get('Description');
                vinDecoderResObj.isError = true;
                vinDecoderResObj.message = errorDescription;
                //vinDecoderResObj.selectorDetail = objModelDetail;
            }else{
                Map<String, Object> mapDbResult = (Map<String, Object>)mapResponseLevel1.get('db_results');
                Map<String, Object> mapVins = (Map<String, Object>)mapDbResult.get('vins');
                Map<String, Object> mapVin = (Map<String, Object>)mapVins.get('vin');
                if(mapVin.containsKey('@error_action')){
                    vinDecoderResObj.isError = true;
                    vinDecoderResObj.message = (String)mapVin.get('@error_action');
                    //vinDecoderResObj.selectorDetail = objModelDetail;
                }else{
                    Map<String, Object> mapModel = (Map<String, Object>)mapVin.get('model');
                    if(!mapModel.isEmpty() && mapModel.containskey('@id')){
                        objModelDetail.modelId = (String)mapModel.get('@id');
                    }
                    if(!mapModel.isEmpty() && mapModel.containskey('@trim_name')){
                        objModelDetail.trim = (String)mapModel.get('@trim_name');
                    }
                    if(!mapModel.isEmpty() && mapModel.containskey('@doors_name')){
                        objModelDetail.doors = (String)mapModel.get('@doors_name');
                    }
                    if(!mapModel.isEmpty() && mapModel.containskey('@trans_name')){
                        objModelDetail.trans = (String)mapModel.get('@trans_name');
                    }
                    if(!mapModel.isEmpty() && mapModel.containskey('@make')){
                        objModelDetail.make = (String)mapModel.get('@make');
                    }
                    if(!mapModel.isEmpty() && mapModel.containskey('@model_name')){
                        objModelDetail.modelName = (String)mapModel.get('@model_name');
                    }
                    if(!mapModel.isEmpty() && mapModel.containskey('@model_year')){
                        objModelDetail.year = (String)mapModel.get('@model_year');
                    }
                    vinDecoderResObj.isError = false;
                    vinDecoderResObj.message = '';
                    //vinDecoderResObj.selectorDetail = objModelDetail;
                }
            }
        }catch(Exception ex){
            vinDecoderResObj.isError = false;
            vinDecoderResObj.message = ex.getMessage()+'LineNumber'+ex.getLineNumber();
        }
        System.debug('SerializedResponse'+JSON.serialize(vinDecoderResObj));
    
        return JSON.serialize(vinDecoderResObj);
    }

    @AuraEnabled
    public static String getCategoryCode(String vinNumber, String poiType, String divisionName){
        if (divisionName.equalsIgnoreCase('Powerequipment')){
            divisionName = 'Power Equipment';
        }
        String apiResponseStr = getModelByVin(vinNumber, poiType, divisionName);
        VinDecoderResponse apiResponse = (VinDecoderResponse) JSON.deserialize(apiResponseStr, VinDecoderResponse.Class);
        String categoryCd;
        if (apiResponse.ModelDetail != null){
            categoryCd = apiResponse.ModelDetail.categoryCd;
        }
        else if (apiResponse.ModelDetailList != null){
            categoryCd = apiResponse.ModelDetailList[0].categoryCd;
        }

        return categoryCd;
    }

    public class VinDecoderResponse{
        public Boolean isError;
        public String errorAction;
        public String message;
        public ModelDetail modelDetail;
        public List<ModelDetail> modelDetailList;
    }

    public class ModelDetail {
        public String vinNumber;
        public String modelId;
        public String year;
        public String make;
        public String modelName;
        public String modelGroupName;
        public String trim;
        public String trans;
        public String doors;
        public String telematicsFlag; //Ravindra Ravindra DOE-2701
        public String enrollment;
        public String categoryCd;
        public ModelColor color;
        public ModelAsset[] assets;
        public Boolean isError;
        public String errorAction;
        public String message;

        public ModelDetail()
        {
            this.color = new ModelColor();
            this.assets = new ModelAsset[]{};
        }

    }

    public class ModelColor {
        public String id;
        public String name;
        public String mfg_color_cd;        
    }

    public class ModelAsset {
        public String colorId;
        public String imagePath;
        public ModelAssetType assetType;   // {'BASECAR', 'IMGMIDSIZE'}
    
        public ModelAsset(String imagePath, ModelAssetType assetType){
            this.imagePath = imagePath;
            this.assetType = assetType;
        }
        public ModelAsset(){}
    }

    public enum ModelAssetType {
        BASECAR,
        IMGMIDSIZE
    }

    public static ModelAssetType getModelAssetType(String modelAssetType)
    {
        ModelAssetType retAssetType;
        for(ModelAssetType assetType : OwnEConfigApiHelper.ModelAssetType.values())
        {
            if(assetType.name().toUpperCase() == modelAssetType.toUpperCase())
            {
                retAssetType = assetType;
                break;
            }
        }

        return retAssetType;
    }


    public class VinLookupResponse{
        public String VIN;
        public String VINHeader;
        public String DivisionCode;
        public String DivisionName;
        public String ModelYear;
        public String ModelId;
        public String ModelCode;
        public String ModelTypeCode;
        public String ModelTrimTypeCode;
        public String FactoryCode;
        public String FactoryName;
        public String ExteriorBaseColorCode;
        public String ExteriorBaseColorName;
        public String ExteriorMarketingColorCode;
        public String ManufacturingColorCode;
        public String ModelGroupNameFriendly;
        public String EmbeddedNavi;
        public String TelematicsFlag;
        public String TelematicsPlatform;
        public String Asset34FrontPath;
        public String CountryCoded;
        public String HeadUnit;
        public String LargeFrontImage;
        public String Enrollment;
        public String EnrollmentMethod;
        public String TelematicsUnit;
        public String ProgramEligible;
    }


//    public static String getCompleteDetail2Temp(){
//         HttpRequest request;
//         String FResponse = '';
//         String requestBody = '{"mit": {"@mit_version_date": "2019-03-10", "@mit_version_number": "1", "client_info": {"@application_id": "marketplace.honda.com", "@echo_input": "true", "@server_ip": "10.0.0.1", "@session_id": "514B5581-E456-4E1D-901B-FF44204EEC49", "@domain": "dev.marketplace.honda.com", "@environment": "dev"}, "input_parameters": {"required": {"source_cd": "ESTORE", "site_cd": "HONDA", "category_cd": "ACCESSORY", "division": {"@version_num": "0", "#text": "A"}, "models": {"model": {"@id": "RM3H5GJW"} } }, "optional": {"dealer_number": "206534", "assets": {"@suppress_asset_name": "true", "@suppress_asset_description": "true", "asset": [{"@type_cd": "IMGOVERLAY", "@view_cd": "34FRONT", "@source_cd": "HONDA"}, {"@type_cd": "IMGMIDSIZE", "@view_cd": "34FRONT", "@source_cd": "HONDA"}, {"@type_cd": "BASECAR", "@view_cd": "34FRONT", "@source_cd": "HONDA"}, {"@type_cd": "IMGOVERLAY", "@view_cd": "34FRONT", "@source_cd": "ACURA"}, {"@type_cd": "IMGMIDSIZE", "@view_cd": "34FRONT", "@source_cd": "ACURA"}, {"@type_cd": "ACCTHUMB", "@source_cd": "HONDA"}, {"@type_cd": "ACCMEDIUM", "@source_cd": "HONDA"}, {"@type_cd": "ACCTHUMB", "@source_cd": "ACURA"}, {"@type_cd": "ACCMEDIUM", "@source_cd": "ACURA"} ] }, "marketing_texts": {"text": [{"@type_cd": "OPTIONNAME", "@source_cd": "ACURA"}, {"@type_cd": "OPTIONDESC", "@source_cd": "ACURA"}, {"@type_cd": "ACCNAME_en", "@source_cd": "HONDA"}, {"@type_cd": "ACCDESC_en", "@source_cd": "HONDA"} ] }, "attributes": "", "accessories": {"@return_rules": "true"}, "display_groups": {"display_group": [{"@cd": "Acura_Accys"}, {"@cd": "Acura_Brakes"}, {"@cd": "Acura_ExtSprtsPkg"}, {"@cd": "Acura_Headliner"}, {"@cd": "Acura_Interior"}, {"@cd": "Acura_IntSprtsPkg"}, {"@cd": "Acura_Paint"}, {"@cd": "Acura_Roof"}, {"@cd": "Acura_Seats"}, {"@cd": "Acura_TechPkg"}, {"@cd": "Acura_Wheels"}, {"@cd": "ACURAEXTAC"}, {"@cd": "ACURAINTAC"}, {"@cd": "ACURATOWPK"}, {"@cd": "HONDA_ELE_AIRCOND"}, {"@cd": "HONDA_ELE_AUDIOVIDEO"}, {"@cd": "HONDA_ELE_OTHER"}, {"@cd": "HONDA_ELE_SECURITY"}, {"@cd": "HONDA_EXT_CARGO"}, {"@cd": "HONDA_EXT_OTHER"}, {"@cd": "HONDA_EXT_PROTECTION"}, {"@cd": "HONDA_EXT_SPOILERS"}, {"@cd": "HONDA_EXT_WHEELS"}, {"@cd": "HONDA_INT_CARGO"}, {"@cd": "HONDA_INT_FLOORMATS"}, {"@cd": "HONDA_INT_OTHER"}, {"@cd": "HONDA_INT_TRIMKITS"}, {"@cd": "HONDA_PACKAGES"}, {"@cd": "HONDAAUDIO"}, {"@cd": "HONDAEXTAC"}, {"@cd": "HONDAINTAC"} ] } } }, "private": {"template_info": {"@class": "Model", "@filename": "Model-GetModelCompleteDetails-MIT.xml", "@xsd": "Model-GetModelCompleteDetails-MIT.xsd", "@method": "GetModelCompleteDetails"}, "stored_procedure": {"@name": "ecnetsp_Model_GetModelCompleteDetails"} } } }';
//         //String endPoint = 'callout:EConfig_BaseEndPoint/REST/B2C/GetModelCompleteDetails/1.0/?appid=marketplace.honda.com';
//         String endPoint = 'https://ws-qa4.hondaweb.com/REST/B2C/GetModelCompleteDetails/1.0/?appid=marketplace.honda.com';
//         Http http = new Http();  
//         request = new HttpRequest();
//         request.setEndPoint(endPoint);
//         request.setMethod('POST');
//         request.setHeader('Content-Type', 'application/Json');   
//         //request.setHeader('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJDbGllbnRBcHBsaWNhdGlvbklEIjoibWFya2V0cGxhY2UuaG9uZGEuY29tIiwiQ2xpZW50RG9tYWluIjoidGVzdC5tYXJrZXRwbGFjZS5ob25kYS5jb20iLCJUb2tlbklEIjoiMTYxNzMwMTU0ODcxOCIsImlzcyI6ImVjb25maWcuc2VydmljZXMuaG9uZGEuY29tIiwiYXVkIjoidGVzdF90ZXN0LmVjb25maWcyLnNlcnZpY2VzLmhvbmRhLmNvbSJ9.oPgrcIL4IrEJce70I5pPajGmvhg41PKtgCPOgHQdclY');
//         request.setHeader('ClientDomain', 'test.marketplace.honda.com');
//         request.setHeader('hondaHeaderType.messageId', '82eee037-784e-47aa-9b1a-00be9cc5e5f4');
//         request.setHeader('accept', 'application/json');
//         request.setHeader('X-Honda-wl-authorization', 'Basic c2VydmljZV9iMmNfaGRtX3FhOkVhcnRoIzc0');
//         request.setBody(requestBody);
        
//         HttpResponse response;

//         String statusCode = '';
//             try{
//                 System.debug('requestBody  :-  '+requestBody);
//                 response = http.send(request);
//                 System.debug('response--'+response);
//                 system.debug('response.getStatus() -- ' + response.getStatus());
//                 if(response.getStatusCode() == 200){
//                     FResponse = response.getBody();
//                     system.debug('fresponse-'+FResponse);  
//                 }
//             }catch(Exception ex){
//                 System.debug('Exception Found !!' + ex.getMessage());
//             }
        
//         return response.getBody();
//     }

// Alexander Dzhitenov (Wipro) - Method does not appear to be in use; commenting out for code coverage
/* public static String getModelByVin2(String vinNumber, String poiType){


    VinDecoderResponse vinDecoderResObj = New VinDecoderResponse();
        System.debug('OWNECONFIG POI: ' + poiType);
        try
        {    
            String responseBody = OwnAPIController.getProductByVin(vinNumber, poiType);
            System.debug(responseBody);

            Map<String, Object> vinResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug(vinResponse.keySet());
            System.debug(vinResponse);

            if (vinResponse.get('status') == 'ERROR'){
                System.debug('error');
                Map<String, Object> responseHeader = (Map<String, Object>) vinResponse.get('header');
                vinDecoderResObj.isError = true;
                vinDecoderResObj.message = (String) responseHeader.get('errorMessage');
                System.debug(vinDecoderResObj);
            }
            else{
                vinDecoderResObj.isError = false;
                System.debug(vinResponse.get('Vehicle'));
                System.debug(vinResponse.get('Vehicle'));
                Map<String, Object> responseLevel1 = (Map<String, Object>) vinResponse.get('Vehicle');
                ModelDetail modelDetailObj = New ModelDetail();
                System.debug('Level 1');
                System.debug(responseLevel1);
    
                System.debug(responseLevel1.get('VIN'));


                if (!responseLevel1.isEmpty()){
                    if(responseLevel1.containskey('VIN')){
                        modelDetailObj.vinNumber = (String)responseLevel1.get('VIN');
                    }
                    if(responseLevel1.containskey('ModelId')){
                        modelDetailObj.modelId = (String)responseLevel1.get('ModelId');
                    }
                    if(responseLevel1.containskey('ModelYear')){
                        modelDetailObj.year = (String)responseLevel1.get('ModelYear');
                    }                   
                    if(responseLevel1.containskey('DivisionName')){
                        modelDetailObj.make = (String)responseLevel1.get('DivisionName');
                    }
                    if(responseLevel1.containskey('ModelCode')){
                        modelDetailObj.modelName = (String)responseLevel1.get('ModelCode');
                    }
                    if(responseLevel1.containskey('ModelGroupNameFriendly')){
                        modelDetailObj.modelGroupName = (String)responseLevel1.get('ModelGroupNameFriendly');
                    }
                    if(responseLevel1.containskey('ModelTrimTypeCode')){
                        modelDetailObj.trim = (String)responseLevel1.get('ModelTrimTypeCode');
                    }
                    if (responseLevel1.containsKey('ExteriorMarketingColorCode')){
                        modelDetailObj.color.name = (String) responseLevel1.get('ExteriorMarketingColorCode');
                    }
                    if (responseLevel1.containsKey('ManufacturingColorCode')){
                        modelDetailObj.color.mfg_color_cd = (String) responseLevel1.get('ManufacturingColorCode');
                    }
                    if (responseLevel1.containsKey('Asset34FrontPath')){
                        //ModelAsset asset = new ModelAsset();
                        //asset.imagePath = (String)responseLevel1.get('Asset34FrontPath');
                        //asset.assetType = ModelAssetType.IMGMIDSIZE;
                        //modelDetailObj.assets.add(asset);
                        modelDetailObj.assets.add( new ModelAsset( (String)responseLevel1.get('Asset34FrontPath'), ModelAssetType.IMGMIDSIZE ));
                    }
                    if (responseLevel1.containsKey('LargeFrontImage')){
                        modelDetailObj.assets.add( new ModelAsset( (String)responseLevel1.get('LargeFrontImage'), ModelAssetType.BASECAR ));
                    }
                    //DOE-2701 Ravindra Ravindra (Wipro)
                    if (responseLevel1.containsKey('TelematicsFlag')){
                        modelDetailObj.telematicsFlag = (String) responseLevel1.get('TelematicsFlag');
                    }
                    if (responseLevel1.containsKey('Enrollment')){
                        modelDetailObj.enrollment = (String) responseLevel1.get('Enrollment');
                    }
                }
                System.debug(modelDetailObj);
                vinDecoderResObj.modelDetail = modelDetailObj;
            }
        }catch(Exception ex){
            vinDecoderResObj.isError = false;
            vinDecoderResObj.message = ex.getMessage() + 'LineNumber'+ex.getLineNumber();
        }

        System.debug('SerializedResponse'+ JSON.serialize(vinDecoderResObj));

        return JSON.serialize(vinDecoderResObj);
    } */

}
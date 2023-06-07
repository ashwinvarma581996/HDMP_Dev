//****************************************************************************** 
// File Name:       OwnershipTriggerHelper.cls
// Summary:         
// Created On:      12-15-2021
// Created By:      Alexander D (Wipro)
// Test Classes:    
// Data I/O:        
// Honda Jira Story: DOE-2345
//===============================================================================


public without sharing class OwnMyVehicleApiHelper {

    private static String OPERATION_TYPE_ADD = 'ADD';
    private static String OPERATION_TYPE_UPDATE = 'UPDATE';
    private static String OPERATION_TYPE_DELETE = 'DELETE';

    // List of fields that should be checked for changes—should be updated if additional fields need to be sent to the MyVehicle API
    private static final List<Schema.SObjectField> ownershipFieldsList      = new List<Schema.SObjectField>{Ownership__c.Nickname__c, Ownership__c.License_Plate_Number__c};
    private static final Schema.SObjectField productIdentifierField = Honda_Product__c.Product_Identifier__c;
    private static final List<Schema.SObjectField> productModelFieldsList   = new List<Schema.SObjectField>{Product_Model__c.Model_Year__c, Product_Model__c.Model_Name__c, Product_Model__c.Trim__c, Product_Model__c.Product_Model_Id__c};
    private static final List<Schema.SObjectField> productModelColorFieldsList = new List<Schema.SObjectField>{Product_Model_Color__c.Exterior_Color_Name__c, Product_Model_Color__c.Manufacturer_Color_Code__c};

    // Maps Salesforce field names to API field names
    private static final Map<Schema.SObjectField, String> apiFieldNameMap = new Map<Schema.SObjectField, String>
                                                                                {   Ownership__c.Nickname__c => 'vehicleAlias',
                                                                                    Ownership__c.License_Plate_Number__c => 'licensePlateNo',
                                                                                    Honda_Product__c.Product_Identifier__c => 'vinNo'};



    private static String getRequestBody(List<ApiParam> productData){
        String reqBody = '{"vehicle":[';

        for (ApiParam param : productData){
            reqBody += '{"key":';
            reqBody += '"' + param.key + '",';
            reqBody += '"value":';
            reqBody += param.value +'},';
        }

        reqBody = reqBody.removeEnd(',');
        reqBody += ']}';

        return reqBody;
    }


    public static void sendMyVehiclesPostRequest(List<ApiParam> productData, String divisionId){
        String requestBody = getRequestBody(productData);
        System.debug('MyVehicleApiHelper: request body');
        System.debug(requestBody);

        String apiResponse = OwnAPIController.sendToMyVehicles(requestBody, divisionId);
        System.debug(apiResponse);
    }


    /* @Future(callout=true) */
    /* public static MyVehicleResult getProductDetails(String divisionId, String vin){
        MyVehicleResult result = new MyVehicleResult();
        OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = divisionId;
        OwnHttpCalloutService myVehiclesGet = new OwnHttpCalloutService('MyVehiclesGet', attribute, new List<String>{vin});
        HttpResponse response = myVehiclesGet.sendRequest();
        System.debug('MyVehicles API response: ' + JSON.serialize(response.getBody()));

        Map<String, Object> l1Response = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        if (l1Response.get('status') == 'SUCCESS'){

            List<Object> vehicleInfoList = (List<Object>) l1Response.get('vehicleInfo');
            
            if (vehicleInfoList.size() != 0){

                OwnGarageController.Product product = parseVehicleResponse((Map<String, Object>) vehicleInfoList[0]);
                result.status = 'SUCCESS';
                result.products = new List<OwnGarageController.Product>{product};
                
            }
            else{
                result.status = 'NOT FOUND';
            }
        }
        else{
            result.status = 'ERROR';
        }
        return result;
    } */


    private static OwnGarageController.Product parseVehicleResponse(Map<String, Object> vehicleInfo){

        OwnGarageController.Product product = new OwnGarageController.Product();

        product.divisionId  =    (String) vehicleInfo.get('DivisionCode');
        product.division    =    (String) vehicleInfo.get('DivisionName');
        product.year        =    (String) vehicleInfo.get('ModelYear');
        product.modelId     =    (String) vehicleInfo.get('ModelId');
        product.model       =    (String) vehicleInfo.get('ModelGroupNameFriendly');
        product.trim        =    (String) vehicleInfo.get('ModelTrimTypeCode');
        product.vin         =    (String) vehicleInfo.get('VIN');
        product.image       =    (String) vehicleInfo.get('Asset34FrontPath');

        product.color       =    new OwnGarageController.ModelColor();
        product.color.name  =    (String) vehicleInfo.get('ExteriorBaseColorName');
        product.color.mfg_color_cd = (String) vehicleInfo.get('ManufacturingColorCode');

        return product;
    }


    public static MyVehicleResult getAllUserVehicles(){
        MyVehicleResult result = new MyVehicleResult();
        /* OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = 'A';
        OwnHttpCalloutService getAllVehiclesService = new OwnHttpCalloutService('MyVehiclesGetAll', attribute, new List<String>());
        Map<String, String> headersMap = getAllVehiclesService.getHeaderParameters();
        System.debug(headersMap.get('Authorization'));
        HttpResponse response = getAllVehiclesService.sendRequest();
        System.debug(response.getBody()); */
        HttpResponse response = OwnAPIController.getAllUserVehiclesFromMyVehicles();
        List<OwnGarageController.Product> myVehiclesProducts = new List<OwnGarageController.Product>();

        Map<String, Object> l1Response = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        if (l1Response.get('status') == 'SUCCESS'){

            List<Object> vehicleInfoList = (List<Object>) l1Response.get('vehicleInfo');
            System.debug(l1Response.get('vehicleInfo'));
            System.debug(vehicleInfoList);
            if (vehicleInfoList.size() != 0){  
                for (Object vehicle : vehicleInfoList){
                    System.debug(parseVehicleResponse((Map<String, Object>) vehicle));
                    myVehiclesProducts.add(parseVehicleResponse((Map<String, Object>) vehicle));
                }
                result.status = 'SUCCESS';
                result.products = myVehiclesProducts;
            }
            else{
                result.status = 'NOT FOUND';
            }
        }
        else{
            result.status = 'ERROR';
        }
        System.debug(result.status);
        System.debug(result.products);
        return result;
    }

    @Future (callout=true)
    public static void sendToMyVehicles_async(Set<Id> ownershipIds, String oldOwnershipStr){
        sendToMyVehicles(ownershipIds, oldOwnershipStr);
    }
    
    public static void sendToMyVehicles(Set<Id> ownershipIds, String oldOwnershipStr){
        // Send data about vehicles added to user's garage to API

        // Code to run when trigger is called (edit operation on Ownership; have previous ownership values, and is not called when user adds completely new product to garage)
        if(OwnAPIController.getCustomerServiceStatus(OwnUserController.getUserFederationID(UserInfo.getUserId())) != null && OwnAPIController.getCustomerServiceStatus(OwnUserController.getUserFederationID(UserInfo.getUserId())).equals(Label.CustomerServiceStatus)){
            // Retrieve complete Ownership data, including related Honda Product, Product Model, and Product Model Color records
            String ownershipQuery = 'SELECT Id, Nickname__c, Managed__c, License_Plate_Number__c, License_Plate_State_Name__c, '
                                    + 'Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__r.Model_Year__c, '
                                    + 'Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c, '
                                    + 'Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Models__r.Product_Division__c, '
                                    + 'Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c, '
                                    + 'Honda_Product__r.Product_Model_Color__r.Model_ID_Manufacture_Color_Code__c, Product_Owner__c '
                                    + 'FROM Ownership__c WHERE Id IN '
                                    + ':ownershipIds';
            String safeQueryStr = String.escapeSingleQuotes(ownershipQuery);
            List<Ownership__c> newOwnershipList = Database.query(safeQueryStr);

            Map<Id, Ownership__c> oldOwnerships = (Map<Id, Ownership__c>) JSON.deserialize(oldOwnershipStr, Map<Id, Ownership__c>.class);

            System.debug('Debug'+oldOwnershipStr);
            // Need to obtain list of changed fields for each ownership by comparing against old values, then map those fields/values to API names
            for (Ownership__c o : newOwnershipList){
                String operationType;
                String divisionId = o.Honda_Product__r.Product_Models__r.Product_Division__c;
                System.debug(divisionId);

                if (!String.isEmpty(o.Honda_Product__r.Product_Identifier__c)/*  && (o.Managed__c) && (oldOwnerships.get(o.Id).Managed__c)  */){
                    if (!o.Managed__c && oldOwnerships.get(o.Id).Managed__c){
                        // Product was removed from user's garage
                        operationType = OPERATION_TYPE_DELETE;
                    }
                    else if (String.isEmpty(oldOwnerships.get(o.Id).Honda_Product__r.Product_Identifier__c)){
                        // VIN was added to a user's product in product settings
                        operationType = OPERATION_TYPE_ADD;
                    }
                    else if (o.Managed__c && oldOwnerships.get(o.Id).Managed__c){
                        // Changes were made to an existing product; send information to the API
                        operationType = OPERATION_TYPE_UPDATE;
                    }
                    /* else if (o.Managed__c && !oldOwnerships.get(o.Id).Managed__c){
                        // Product was re-added to user's garage
                        operationType = 'ADD';
                    } */

                    System.debug(operationType);
                    if (String.isNotEmpty(operationType)){
                        List<OwnMyVehicleApiHelper.ApiParam> apiData = new List<OwnMyVehicleApiHelper.ApiParam>();
                        apiData.addAll(getApiParamsForOwnershipFields(o, oldOwnerships, ownershipFieldsList, apiFieldNameMap));
                        apiData.add(getEventParam(operationType));
                        apiData.add(getVinParam(o.Honda_Product__r));
                        //apiData.add(getEUserIdentParam(o.Product_Owner__c));
                        if (operationType == OPERATION_TYPE_DELETE || operationType == OPERATION_TYPE_ADD){
                            apiData.add(getRelationshipStatusParam(operationType));
                        }
                        //apiData.add(getEmailParam(o.Product_Owner__c));
                        //apiData.add(getEUserIdentParam(o.Product_Owner__c));
                        System.debug(JSON.serialize(apiData));
                        OwnMyVehicleApiHelper.sendMyVehiclesPostRequest(apiData, divisionId);
                    }
                }
            }
        }
    }

    @Future (callout=true)
    public static void sendToMyVehicles_async(Set<Id> ownershipIds){
        sendToMyVehicles(ownershipIds);
    }

    public static void sendToMyVehicles(Set<Id> ownershipIds){
        // Send data about vehicles added to user's garage to API
        if(OwnAPIController.getCustomerServiceStatus(OwnUserController.getUserFederationID(UserInfo.getUserId())) != null && OwnAPIController.getCustomerServiceStatus(OwnUserController.getUserFederationID(UserInfo.getUserId())).equals(Label.CustomerServiceStatus)){
            // Retrieve complete Ownership data, including related Honda Product, Product Model, and Product Model Color records
            String ownershipQuery = 'SELECT Id, Nickname__c, Managed__c, License_Plate_Number__c, License_Plate_State_Name__c, '
                                    + 'Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__r.Model_Year__c, '
                                    + 'Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c, '
                                    + 'Honda_Product__r.Product_Models__r.Product_Model_Id__c, Honda_Product__r.Product_Models__r.Product_Division__c, '
                                    + 'Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c, '
                                    + 'Honda_Product__r.Product_Model_Color__r.Model_ID_Manufacture_Color_Code__c, Product_Owner__c '
                                    + 'FROM Ownership__c WHERE Id IN '
                                    + ':ownershipIds';
            String safeQueryStr = String.escapeSingleQuotes(ownershipQuery);
            List<Ownership__c> newOwnershipList = Database.query(safeQueryStr);

            for (Ownership__c o : newOwnershipList){
                // Code to run when product data for newly-added products needs to be sent to MyVehicles; not called from Ownership trigger, old values do not exist
                String operationType = OPERATION_TYPE_ADD;
                String divisionId = o.Honda_Product__r.Product_Models__r.Product_Division__c;
                List<ApiParam> apiData = new List<ApiParam>();
                apiData.addAll(getApiParamsForOwnershipFields(o, ownershipFieldsList, apiFieldNameMap));
                apiData.add(getEventParam(operationType));
                apiData.add(getVinParam(o.Honda_Product__r));
                apiData.add(getRelationshipStatusParam(operationType));
                //apiData.add(getEUserIdentParam(o.Product_Owner__c));
                //apiData.add(getEmailParam(o.Product_Owner__c));
                System.debug(JSON.serialize(apiData));
                System.debug('sendToMyVehicles running');
                sendMyVehiclesPostRequest(apiData, divisionId);
            }
        }
    }

    private static List<ApiParam> getApiParamsForOwnershipFields(Ownership__c o, Map<Id, Ownership__c> oldOwnerships, List<Schema.SObjectField> ownershipFields, Map<Schema.SObjectField, String> fieldNameMap){
        List<ApiParam> fieldChanges = new List<ApiParam>();
        for (Schema.SObjectField field : ownershipFieldsList){
            // Check for field changes
            if (o.get(field) != oldOwnerships.get(o.Id).get(field)){
                fieldChanges.add(mapFieldToApi(o, field, apiFieldNameMap));
            }
        }

        return fieldChanges;
    }

    private static List<OwnMyVehicleApiHelper.ApiParam> getApiParamsForOwnershipFields(Ownership__c o, List<Schema.SObjectField> ownershipFields, Map<Schema.SObjectField, String> fieldNameMap){
        List<ApiParam> fieldChanges = new List<OwnMyVehicleApiHelper.ApiParam>();
        for (Schema.SObjectField field : ownershipFieldsList){
            fieldChanges.add(mapFieldToApi(o, field, apiFieldNameMap));
        }

        return fieldChanges;
    }

    private static ApiParam mapFieldToApi(SObject record, Schema.SObjectField field, Map<Schema.SObjectField, String> fieldNameMap){
        return new ApiParam(apiFieldNameMap.get(field), record.get(field));
    }

    private static ApiParam getEventParam(String operationType){
        // Set 'DELETE' calls as 'UPDATE' - this is reflected only by updating the relationshipStatus parameter
        return /* operationType == OPERATION_TYPE_DELETE ? new ApiParam('Event', OPERATION_TYPE_UPDATE) : */ new ApiParam('Event', operationType);
    }
    
    private static ApiParam getRelationshipStatusParam(String operationType){
        String relationshipStatus;
        if (operationType == OPERATION_TYPE_DELETE){
            relationshipStatus = 'DONOTSHOW';
        }
        else if (operationType == OPERATION_TYPE_ADD){
            //relationshipStatus = 'Unconfirmed';
            relationshipStatus = 'UNCONFIRMED';
        }
        return new ApiParam('RelationshipStatus', relationshipStatus);
    }

    private static ApiParam getVinParam(Honda_Product__c hp){
        return new ApiParam(apiFieldNameMap.get(Honda_Product__c.Product_Identifier__c), hp.Product_Identifier__c);
    }

    private static ApiParam getEmailParam(Id acctId){
        String userEmail = [SELECT Email FROM User WHERE AccountId = :acctId LIMIT 1]?.Email;
        return new ApiParam('emailAddress', userEmail);
    }

    private static ApiParam getEUserIdentParam(Id acctId){
        String eUserIdent = [SELECT FederationIdentifier FROM User WHERE AccountId=:acctId]?.FederationIdentifier;
        return new ApiParam('eUserIdent', eUserIdent);
    }



    public class MyVehicleResult{
        public List<OwnGarageController.Product> products;
        public String status;
        public MyVehicleResult(String status, List<OwnGarageController.Product> products){
            this.status = status;
            this.products = products;
        }
        public MyVehicleResult(){}
    }

    public class ApiParam{
        public String key;
        public String value;

        public ApiParam(String key, Object value){
            this.key = key;
            this.value = JSON.serialize(value);
        }
        public ApiParam(){
        }
    }
}
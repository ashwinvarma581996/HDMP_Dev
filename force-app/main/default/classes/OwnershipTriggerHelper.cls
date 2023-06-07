//****************************************************************************** 
// File Name:       OwnershipTriggerHelper.cls
// Summary:         
// Created On:      12-15-2021
// Created By:      Alexander D (Wipro)
// Test Classes:    
// Data I/O:        
// Honda Jira Story: 
//===============================================================================


public with sharing class OwnershipTriggerHelper {

    // List of fields that should be checked for changes—should be updated if additional fields need to be sent to the MyVehicle API
    private static final List<Schema.SObjectField> ownershipFieldsList      = new List<Schema.SObjectField>{Ownership__c.Nickname__c, Ownership__c.License_Plate_Number__c, Ownership__c.Honda_Product__c};
    private static final Schema.SObjectField productIdentifierField = Honda_Product__c.Product_Identifier__c;
    private static final List<Schema.SObjectField> productModelFieldsList   = new List<Schema.SObjectField>{Product_Model__c.Model_Year__c, Product_Model__c.Model_Name__c, Product_Model__c.Trim__c, Product_Model__c.Product_Model_Id__c};
    private static final List<Schema.SObjectField> productModelColorFieldsList = new List<Schema.SObjectField>{Product_Model_Color__c.Exterior_Color_Name__c, Product_Model_Color__c.Manufacturer_Color_Code__c};

    // Maps Salesforce field names to API field names
    private static final Map<Schema.SObjectField, String> apiFieldNameMap = new Map<Schema.SObjectField, String>
                                                                                {   Ownership__c.Nickname__c => 'vehicleAlias',
                                                                                    Ownership__c.License_Plate_Number__c => 'licensePlateNo',
                                                                                    Honda_Product__c.Product_Identifier__c => 'vinNo'};


    @Future (callout=true)
    public static void sendToMyVehicles(Set<Id> ownershipIds, String oldOwnershipStr){
        // Send data about vehicles added to user's garage to API

        // Code to run when trigger is called (edit operation on Ownership; have previous ownership values, and is not called when user adds completely new product to garage)

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

        //List<Ownership__c> vinOwnerships = new List<Ownership__c>();
        System.debug('Debug');
        // Need to obtain list of changed fields for each ownership by comparing against old values, then map those fields/values to API names
        for (Ownership__c o : newOwnershipList){
            /* System.debug('debug'); */
            String operationType;
            String divisionId = o.Honda_Product__r.Product_Models__r.Product_Division__c;
            System.debug(divisionId);
            /* System.debug('new HP: ' + o.Honda_Product__c);
            System.debug('new HP: ' + oldOwnerships.get(o.Id).Honda_Product__c); */
            if (!String.isEmpty(o.Honda_Product__r.Product_Identifier__c) && (o.Managed__c) && (oldOwnerships.get(o.Id).Managed__c) ){
                if (!o.Managed__c && oldOwnerships.get(o.Id).Managed__c){
                    // Product was removed from user's garage
                    operationType = 'DELETE';
                }
/*                 else if (o.Managed__c && !oldOwnerships.get(o.Id).Managed__c){
                    // Product was re-added
                    operationType = 'ADD';
                }
                else if (o.Managed__c && (o.Honda_Product__c != oldOwnerships.get(o.Id).Honda_Product__c) ){
                    // VIN was added to the user's ownership
                    operationType = 'ADD';
                } */
                else/*  if (o.Managed__c) */{
                    // Changes were made to an existing product; send information to the API
                    operationType = 'UPDATE';
                }

                System.debug(operationType);
                if (String.isNotEmpty(operationType)){
                    /* String productIdentifier = o.Honda_Product__r.Product_Identifier__c;
                    String vehicleAlias, licensePlate = '';
                    if (o.Nickname__c != oldOwnerships.get(o.Id).Nickname__c){
                        vehicleAlias = o.Nickname__c;
                    }
                    if (o.License_Plate_Number__c != oldOwnerships.get(o.Id).License_Plate_Number__c){
                        licensePlate = o.License_Plate_Number__c;
                    } */
                    List<OwnMyVehicleApiHelper.ApiParam> apiData = new List<OwnMyVehicleApiHelper.ApiParam>();
                    apiData.addAll(getApiParamsForOwnershipFields(o, oldOwnerships, ownershipFieldsList, apiFieldNameMap));
                    apiData.add(getEventParam(operationType));
                    apiData.add(getVinParam(o.Honda_Product__r));
                    apiData.add(getEmailParam(o.Product_Owner__c));
                    System.debug(JSON.serialize(apiData));
                    OwnMyVehicleApiHelper.sendMyVehiclesPostRequest(apiData, divisionId);
                    /* System.debug('Sending to MyVehicles');
                    String apiResponse = OwnAPIController.sendToMyVehicles(operationType, productIdentifier, licensePlate, vehicleAlias);
                    System.debug(apiResponse); */
                }
            }
        }
    }

    @Future (callout=true)
    public static void sendToMyVehicles(Set<Id> ownershipIds){
        // Send data about vehicles added to user's garage to API

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
            String operationType = 'ADD';
            String divisionId = o.Honda_Product__r.Product_Models__r.Product_Division__c;
            List<OwnMyVehicleApiHelper.ApiParam> apiData = new List<OwnMyVehicleApiHelper.ApiParam>();
            apiData.addAll(getApiParamsForOwnershipFields(o, ownershipFieldsList, apiFieldNameMap));
            apiData.add(getEventParam(operationType));
            apiData.add(getVinParam(o.Honda_Product__r));
            apiData.add(getEmailParam(o.Product_Owner__c));
            System.debug(JSON.serialize(apiData));
            OwnMyVehicleApiHelper.sendMyVehiclesPostRequest(apiData, divisionId);
        }
    }

    public static List<OwnMyVehicleApiHelper.ApiParam> getApiParamsForOwnershipFields(Ownership__c o, Map<Id, Ownership__c> oldOwnerships, List<Schema.SObjectField> ownershipFields, Map<Schema.SObjectField, String> fieldNameMap){
        
        List<OwnMyVehicleApiHelper.ApiParam> fieldChanges = new List<OwnMyVehicleApiHelper.ApiParam>();

        for (Schema.SObjectField field : ownershipFieldsList){
            // Check for field changes
            if (o.get(field) != oldOwnerships.get(o.Id).get(field)){
                //changedFields.add(new OwnMyVehicleApiHelper.KeyVal(apiFieldNameMap.get(field), o.get(field)));
                fieldChanges.add(mapFieldToApi(o, field, apiFieldNameMap));
            }
        }

        return fieldChanges;
    }

    private static List<OwnMyVehicleApiHelper.ApiParam> getApiParamsForOwnershipFields(Ownership__c o, List<Schema.SObjectField> ownershipFields, Map<Schema.SObjectField, String> fieldNameMap){
        
        List<OwnMyVehicleApiHelper.ApiParam> fieldChanges = new List<OwnMyVehicleApiHelper.ApiParam>();

        for (Schema.SObjectField field : ownershipFieldsList){
            fieldChanges.add(mapFieldToApi(o, field, apiFieldNameMap));
        }

        return fieldChanges;
    }

    private static OwnMyVehicleApiHelper.ApiParam mapFieldToApi(SObject record, Schema.SObjectField field, Map<Schema.SObjectField, String> fieldNameMap){
        return new OwnMyVehicleApiHelper.ApiParam(apiFieldNameMap.get(field), record.get(field));
    }

    private static OwnMyVehicleApiHelper.ApiParam getEventParam(String operationType){
        return new OwnMyVehicleApiHelper.ApiParam('Event', operationType);
    }

    private static OwnMyVehicleApiHelper.ApiParam getVinParam(Honda_Product__c hp){
        return new OwnMyVehicleApiHelper.ApiParam(apiFieldNameMap.get(Honda_Product__c.Product_Identifier__c), hp.Product_Identifier__c);
    }

    private static OwnMyVehicleApiHelper.ApiParam getEmailParam(Id acctId){
        String userEmail = [SELECT Email FROM User WHERE AccountId = :acctId LIMIT 1]?.Email;
        return new OwnMyVehicleApiHelper.ApiParam('emailAddress', userEmail);
    }

/*     private static List<OwnMyVehicleApiHelper.ApiParam> getApiParams(Ownership__c o, Map<Id, Ownership__c> oldOwnerships){
        List<OwnMyVehicleApiHelper.ApiParam> changedFields = new List<OwnMyVehicleApiHelper.ApiParam>();
        String operationType;
        for (Schema.SObjectField field : ownershipFieldsList){
            // Check for field changes
            if (o.get(field) != oldOwnerships.get(o.Id).get(field)){
                //changedFields.add(new OwnMyVehicleApiHelper.KeyVal(apiFieldNameMap.get(field), o.get(field)));
                changedFields.add(mapFieldToApi(o, field, apiFieldNameMap));
                operationType = 'UPDATE'; //Changes to the ownership record, but not its lookup fields, means that the vehicle remains the same—the operation is thus an update
            }
        } */
        // Not currently implementing API call for adding vehicles
/*         if (o.Honda_Product__c != oldOwnerships.get(o.Id).Honda_Product__c){
            //changedFields.add(new OwnMyVehicleApiHelper.KeyVal(apiFieldNameMap.get(Honda_Product__c.Product_Identifier__c), o.Honda_Product__r.Product_Identifier__c));

            changedFields.add(mapFieldToApi(o, Honda_Product__c.Product_Identifier__c, apiFieldNameMap);

            // Vehicle lookup was changed; model is different
            if (o.Honda_Product__r.Product_Models__c != oldOwnerships.get(o.Id).Honda_Product__r.Product_Models__c){

            }
            // Vehicle lookup was changed; model color is different
            if (o.Honda_Product__r.Product_Model_Color__c != oldOwnerships.get(o.Id).Honda_Product__r.Product_Model_Color__c){
                
            }
        } */

        //changedFields.add(0, new OwnMyVehicleApiHelper.ApiParam('Event', operationType));

/*         return changedFields;
    } */
}
trigger OwnershipTrigger on Ownership__c (after insert, after update, after delete) {
    
    /*     Set<Ownership__c> ownershipIds = new Set<Ownership__c>();

    for (Ownership__c o : trigger.new){
        ownershipIds.add(o.Id);
    }
    
    String ownershipQuery = 'SELECT Id, Honda_Product__r.Product_Identifier__c, Honda_Product__r.Product_Models__r.Model_Year__c, '
    + 'Honda_Product__r.Product_Models__r.Model_Name__c, Honda_Product__r.Product_Models__r.Trim__c, '
    + 'Honda_Product__r.Product_Models__r.Product_Model_Id__c, '
    + 'Honda_Product__r.Product_Model_Color__r.Exterior_Color_Name__c, Honda_Product__r.Product_Model_Color__r.Manufacturer_Color_Code__c, '
    + 'Honda_Product__r.Product_Model_Color__r.Model_ID_Manufacturer_Color_Code__c'
    + 'FROM Ownership__c WHERE Id IN '
    + ':ownershipIds';
    String safeQueryStr = String.escapeSingleQuotes(ownershipQuery);
    List<Ownership__c> ownershipList = Database.query(safeQueryStr); */
    system.debug('@@InsideAfterStart');
    if(trigger.isInsert && trigger.isAfter){
        //START-Added By Imtiyaz to update Product_Service_Note__c after insert ownership
        System.debug('$$$OwnershipTrigger: ' + Trigger.newMap);
        OwnershipTriggerHandler.addOwnershipToProductServiceNotes(Trigger.newMap.keySet());
        //END-Added By Imtiyaz to update Product_Service_Note__c after insert ownership
        system.debug('@@InsideAfter');
        OwnershipTriggerHandler oth=new OwnershipTriggerHandler();
        oth.insertOwnersMessages(trigger.new);
    }
    if(trigger.isUpdate && trigger.isAfter){
        OwnershipTriggerHandler oth=new OwnershipTriggerHandler();
        oth.UpdateOwnersMessages(trigger.new,trigger.oldMap);
    }
    Set<Id> ownershipIds = new Set<Id>();
    if (trigger.isDelete){
        for (Ownership__c o : trigger.old){
            ownershipIds.add(o.Id);
        }
    }
    else{
        for (Ownership__c o : trigger.new){
            ownershipIds.add(o.Id);
        }
    }
    
    // When an ownership is inserted, updated, or deleted, if the product has a VIN (or a VIN has been added), send the data to MyVehiclesAPI
    //if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isDelete)){
    if (trigger.isAfter && (trigger.isUpdate /* || trigger.isDelete */)){
        String operationType = trigger.isInsert ? 'ADD' : (trigger.isUpdate || trigger.isDelete) ? 'UPDATE' : 'ERROR';
        OwnMyVehicleApiHelper.sendToMyVehicles_async(ownershipIds, JSON.serialize(trigger.oldMap));
    }
}
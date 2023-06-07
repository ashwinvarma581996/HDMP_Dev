public with sharing class DeleteBoilerplate {

    /****************************************************************************
* Description: This method will delete validation on Boilerplate object
* Name: Bhupendra Sisodiya
* ***************************************************************************/

    @AuraEnabled
    public static Boolean deleteBoilerplate(String recordID) {
       String recordIdUpdated = recordID.replace('"','');
        System.debug('recordIdUpdated - ' + recordIdUpdated);

        List<Offers__c> offerList = [
            SELECT Id, Status__c 
            FROM Offers__c 
            WHERE Status__c NOT IN ('WIP','Expired') AND Boilerplate__c = :recordIdUpdated
        ];

        if (!offerList.isEmpty()) {
            return false;
        } else{

        List<Boilerplate__c> boilerplateList = [
            SELECT Id 
            FROM Boilerplate__c 
            WHERE Id = :recordIdUpdated
        ];
            try{
        delete boilerplateList;
            } catch (Exception e){
                
                System.debug('An error occured while deleting the list:' + e.getMessage());
            }
        return true;
            }
    }
}
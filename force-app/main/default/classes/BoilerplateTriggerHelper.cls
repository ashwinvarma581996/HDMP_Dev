public class BoilerplateTriggerHelper {
    
    /****************************************************************************
* Description: This method will check duplicate Name validation on Boilerplate object
* Name: Bhupendra
* ***************************************************************************/
    public void preventDuplicateRecords(List<Boilerplate__c> newBoilerplateList) {
       
        Set<String> boilerplateNames = new Set<String>();

        for(Boilerplate__c boi : newBoilerplateList){
            boilerplateNames.add(boi.Name);
        }
        

        Map<String,List<Boilerplate__c>> boilerplateMap = new Map<String, List<Boilerplate__c>>();
        List<Boilerplate__c> boilerPlateList = [select id,name from Boilerplate__c where name IN:boilerplateNames];

        for(Boilerplate__c boilerPlateRecord : boilerPlateList) {
            
            String BoilerplateName = boilerPlateRecord.Name;
            
            if(!boilerplateMap.containsKey(BoilerplateName)){
                boilerplateMap.put(BoilerplateName, new List<Boilerplate__c>());
            }
            boilerplateMap.get(BoilerplateName).add(boilerPlateRecord);
        }


       if(newBoilerplateList.size()>0){
            for(Boilerplate__c boi : newBoilerplateList){
                
          
                    if(boilerplateMap.size()>0 && boilerplateMap.containsKey(boi.Name)){
                        
                        boi.Name.addError(label.Error_on_Duplicate_Boilerplate_Name);
                    }
             
            }
        }


  
      
    }
    /****************************************************************************
* Description: This method will validate status field on Boilerplate object
* Name: Bhupendra
* ***************************************************************************/
    public void validateStatusOfBoilerPlate(List<Boilerplate__c> updatedBoilerplateList) {
        
        Set<Id> boilerplateIds = new Set<Id>();
        for(Boilerplate__c boi : updatedBoilerplateList){
            boilerplateIds.add(boi.Id);
        }
        
        if(boilerplateIds.isEmpty()){
            return ;
        }
        
        Map<String,List<Offers__c>> offersMap = new Map<String, List<Offers__C>>();
        List<Offers__c> offersList = [SELECT Id, Status__c, Boilerplate__c 
                                      FROM Offers__c 
                                      WHERE Status__c NOT IN ('WIP', 'Expired') 
                                      AND Boilerplate__c IN :boilerplateIds];
        for(Offers__c offersRecord : offersList) {
            
            String BoilerplateId = offersRecord.Boilerplate__c;
            if(!offersMap.containsKey(BoilerplateId)){
                offersMap.put(BoilerplateId, new List<Offers__c>());
            }
            offersMap.get(BoilerplateId).add(offersRecord);
        }
        
        if(updatedBoilerplateList.size()>0){
            for(Boilerplate__c boi : updatedBoilerplateList){
                
                if(boi.Status__c == 'Expired'){
                    
                    if(offersMap.size()>0 && offersMap.containsKey(boi.Id)){
                        boi.Status__c.addError(Label.Error_on_Boilerplate_Expire);
                    }
                }   
            }   
        }
    }
    
    /****************************************************************************
* Description: This method will validate delete functionality on Boilerplate object
* Name: Bhupendra
* ***************************************************************************/    
    public  void validateStatusOfBoilerPlateDelete(List<Boilerplate__c> deletedBoilerplateList) {
        
        Set<Id> boilerplateIds = new Set<Id>();
        for(Boilerplate__c boi : deletedBoilerplateList){
            boilerplateIds.add(boi.Id);
        }
        if(boilerplateIds.isEmpty()){
            return ;
        }
        
        Map<String,List<Offers__c>> offersMap = new Map<String, List<Offers__C>>();
        List<Offers__c> offersList = [SELECT Id, Status__c, Boilerplate__c 
                                      FROM Offers__c 
                                      WHERE Status__c NOT IN ('WIP') 
                                      AND Boilerplate__c IN :boilerplateIds];
        for(Offers__c offersRecord : offersList) {
            
            String BoilerplateId = offersRecord.Boilerplate__c;
            if(!offersMap.containsKey(BoilerplateId)){
                offersMap.put(BoilerplateId, new List<Offers__c>());
            }
            offersMap.get(BoilerplateId).add(offersRecord);
        }
        
        
        if(deletedBoilerplateList.size()>0){
            for(Boilerplate__c boi : deletedBoilerplateList){
                
                if(boi.Status__c == 'Expired'){
                    if(offersMap.size()>0 && offersMap.containsKey(boi.Id)){
                        
                        boi.Status__c.addError(Label.Error_On_Boilerplate_Deletion);
                    }
                }
            }
        }
    }
    /**********************************************************
     * Name : Siva
     * Description: While cloning Boilerplate need to default status to WIP 
     * *********************************************************/
    public void defaultStatusWIPWhenClone(List<Boilerplate__c> lstBoilerplate){
        for(Boilerplate__c bpObj:lstBoilerplate){
            if(bpObj.isclone()){
                bpObj.Status__c='WIP';
            }
        }
        
    }
}
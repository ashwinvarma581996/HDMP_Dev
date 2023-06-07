public without sharing class ownMaintenanceMinderController {
    @AuraEnabled(cacheable = true)
    public static Vehicle_Health_Report__c getVehicleHealthReport(String ownershipId,String productId){
        try {
            Vehicle_Health_Report__c vehicleHealthReport=[SELECT Oil_Life_Percent__c, Mileage__c, Report_Date__c ,Ownership__c, Honda_Product__c, Id FROM Vehicle_Health_Report__c where Ownership__c = :ownershipId AND Honda_Product__c = :productId order by Report_Date__c desc limit 1];
            System.debug(vehicleHealthReport);
            return vehicleHealthReport;
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    @AuraEnabled(cacheable = true)
    public static List<String> getVehicleHealthStatusReport(String ownershipId,String productId){
        try {
            Map<Decimal ,String> mapCategorytoName = new Map<Decimal ,String>();
            
            Set<Id>vehicleStatusId = new Set<Id>();
            Vehicle_Health_Report__c vehicleHealthReport=[SELECT Oil_Life_Percent__c, Mileage__c, Report_Date__c ,Ownership__c, Honda_Product__c, Id FROM Vehicle_Health_Report__c where Ownership__c = :ownershipId AND Honda_Product__c = :productId];
            System.debug(vehicleHealthReport);
             List<Vehicle_Health_Status__c> vehicleHealthStatusReport =[SELECT Id, IsDeleted, Name, Category_Sort_Order__c, Health_Status_Indicator__c, Category_Name__c, SubCategory_Name__c, SubCategory_Sort_Order__c, Vehicle_Health_Report__c FROM Vehicle_Health_Status__c where Vehicle_Health_Report__c =: vehicleHealthReport.Id ORDER BY Category_Sort_Order__c ASC];
           //  AggregateResult[] groupedResults = [SELECT  MAX(Category_Sort_Order__c) maxcategory,Category_Name__c from Vehicle_Health_Status__c  where Id in:vehicleHealthStatusReport  group by Category_Name__c,Category_Sort_Order__c ORDER BY Category_Sort_Order__c ASC];
            for(Vehicle_Health_Status__c vsc : vehicleHealthStatusReport){
                
                
                if(!mapCategorytoName.containsKey(vsc.Category_Sort_Order__c) && vsc.Category_Sort_Order__c != null ){
                    mapCategorytoName.put(vsc.Category_Sort_Order__c,vsc.Category_Name__c);

                }
                
            }
                       
            return mapCategorytoName.values();
            //return vehiclewrapper;
           
          // return vehicleHealthStatusReport;
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    @AuraEnabled(cacheable = true)
    public static Maintenance_Minder__c getMaintenanceMinder(String ownershipId,String productId){
        try {
            Maintenance_Minder__c maintenanceMinder =[SELECT Id, Service_Item_Description__c, Maintenance_Code__c ,Legal_Description__c, Service_Header_Text__c ,Service_Post_Text__c ,Service_Pre_Text__c ,Vehicle_Health_Report__c FROM Maintenance_Minder__c where Vehicle_Health_Report__r.Ownership__c = :ownershipId AND Vehicle_Health_Report__r.Honda_Product__c = :productId Order By Maintenance_Code__c];
            return maintenanceMinder;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable = true)
    public static List<Owner_Message__c> getRecallMessages(){
        try {
        List<Owner_Message__c> recallmessages = [SELECT Id, OwnerId, Name, Ownership__c, Owner__c, Is_Read__c, Read_Date__c, Message__r.body__c,Message__r.Subject__c FROM Owner_Message__c ];
        return recallmessages;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable = true)
    public static List<Maintenance_Minder__c> getMaintenanceMindersList(String ownershipId,String productId){
        try {
            List<Maintenance_Minder__c> maintenanceMinder =[SELECT Id, Service_Item_Description__c, Maintenance_Code__c ,Legal_Description__c, Service_Header_Text__c ,Service_Post_Text__c ,Service_Pre_Text__c ,Vehicle_Health_Report__c FROM Maintenance_Minder__c where Vehicle_Health_Report__r.Ownership__c = :ownershipId AND Vehicle_Health_Report__r.Honda_Product__c = :productId  Order By Maintenance_Code__c];
            return maintenanceMinder;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Maintenance_Minder__c> getMaintenanceMindersListCard(String ownershipId,String productId){
        try {
            List<Maintenance_Minder__c> maintenanceMinder =[SELECT Id, Service_Item_Description__c, Maintenance_Code__c ,Legal_Description__c, Service_Header_Text__c ,Service_Post_Text__c ,Service_Pre_Text__c ,Vehicle_Health_Report__c FROM Maintenance_Minder__c where Vehicle_Health_Report__r.Ownership__c = :ownershipId AND Vehicle_Health_Report__r.Honda_Product__c = :productId  Order By Maintenance_Code__c LIMIT 1];
            return maintenanceMinder;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Vehicle_Health_Status__c> getVehicleHealthSubCategoryList(String ownershipId,String productId,String vehicleCategory){
        Vehicle_Health_Report__c vehicleHealthReport=[SELECT Oil_Life_Percent__c, Mileage__c, Report_Date__c ,Ownership__c, Honda_Product__c, Id FROM Vehicle_Health_Report__c where Ownership__c = :ownershipId AND Honda_Product__c = :productId];
        System.debug(vehicleHealthReport);
        List<Vehicle_Health_Status__c> vehicleHealthStatusReport =[SELECT Id, IsDeleted, Name, Category_Sort_Order__c, Health_Status_Indicator__c,Category_Name__c, SubCategory_Name__c, SubCategory_Sort_Order__c, Vehicle_Health_Report__c FROM Vehicle_Health_Status__c where Vehicle_Health_Report__c =: vehicleHealthReport.Id AND Category_Name__c = : vehicleCategory ORDER BY SubCategory_Sort_Order__c ASC];
        
        return vehicleHealthStatusReport;
        
    }
    @AuraEnabled
    public static void updateUserHasVHR(String ownershipId,String productId){
        Boolean hasVHR = hasVHR(ownershipId, productId);
        update new User(Id = UserInfo.getUserId(), Has_Vehicle_Health_Report__c = hasVHR);
    }
    @AuraEnabled
    public static Boolean hasVHR(String ownershipId,String productId){
        List<Vehicle_Health_Report__c> vehicleHealthReports = [SELECT Id FROM Vehicle_Health_Report__c where Ownership__c = :ownershipId AND Honda_Product__c = :productId];
        return vehicleHealthReports != null && vehicleHealthReports.size() > 0 ? true : false;
    }
}
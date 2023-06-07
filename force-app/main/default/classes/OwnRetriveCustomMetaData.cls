public class OwnRetriveCustomMetaData {
    
       @AuraEnabled(cacheable = true)
    public static  Finance_SSO__mdt getFinanceLink(String brand){
        String srchstr='%'+brand+'%';
        Finance_SSO__mdt financeSSO=[select MasterLabel,Brand__c,Login_Link__c,Guest_Link__c from Finance_SSO__mdt where Brand__c LIKE:srchstr LIMIT 1];
        return financeSSO;
    }

    @AuraEnabled(cacheable = true)
    public static  List<ManualRequest__mdt> getManualRequest(String brand){
        List<ManualRequest__mdt> manualRequest =[select MasterLabel,Brand__c,Year__c,Models__c from ManualRequest__mdt where Brand__c =:brand order by Year__c asc];
        return manualRequest;
    }

    @AuraEnabled(cacheable = true)
    public static  List<OwnmyQVehicleCompatibility__mdt> getmyQVehicleCompatibility(String brand){
        List<OwnmyQVehicleCompatibility__mdt> myQVehicleCompatibility =[SELECT Id, DeveloperName, MasterLabel, Label, Brand__c, Year__c, Model__c, Trim__c FROM OwnmyQVehicleCompatibility__mdt WHERE Brand__c = :brand ORDER BY Year__c DESC];
        return myQVehicleCompatibility;
    }

    @AuraEnabled(cacheable = true)
    public static  List<ISOR_model__mdt> getInfotainmentSystemData(){
        List<ISOR_model__mdt> infotainmentSystemData =[select masterlabel,Year__c, Model__c, Alert__c,Link__c,Trims__c from ISOR_model__mdt  ORDER BY Year__c DESC];
        return infotainmentSystemData;
    }

}
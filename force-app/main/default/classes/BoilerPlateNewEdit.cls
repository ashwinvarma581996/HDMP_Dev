public class BoilerPlateNewEdit {
    @AuraEnabled
    public static boolean createNew(String recId){
        List<Boilerplate__c> boil = new List<Boilerplate__c>();
        boil = [select Detailed_Description__c,Legal_Disclaimer__c,Short_Description__c from Boilerplate__c where Id=:recId];
        if(boil.Size() != 0 ){
            
            boil[0].Detailed_Description__c = null;
            boil[0].Legal_Disclaimer__c = null;
            boil[0].Short_Description__c = null;
            update boil;
            }
        
         return true;
    }
   

}
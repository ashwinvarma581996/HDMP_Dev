public without sharing class B2BCustomHeaderController {

    
    @AuraEnabled(cacheable=true)
    public static String getCartId(String recordId) {
        return [SELECT Id, Name, Type, OwnerId, Status FROM WebCart WHERE OwnerId =: recordId AND Status ='Active'].Id;
    }
}
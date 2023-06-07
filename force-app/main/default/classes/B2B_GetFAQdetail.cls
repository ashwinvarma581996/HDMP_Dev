public without sharing class B2B_GetFAQdetail {
    
      @AuraEnabled(cacheable=true)
    public static List<FAQ__c> getFAQ() {
        
        List<FAQ__c> result = [SELECT Id,Sr_No__c, Question__c, Answer__c FROM FAQ__c ORDER By Sr_No__c];
        
        return result;
    }
    
}
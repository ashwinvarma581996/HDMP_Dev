/*** 
 * Class Name : B2B_DealerReturnPolicyController
 * Description : Used to acts as a controller for dealerReturnPolicy
 * Owner : LTIM
 * Created Date : 1/18/2023
 */
public without sharing class B2B_DealerReturnPolicyController {

    /**
     * Method Name : getReturnPolicy
     * Parmeter : @dealerNo from URL
     * Description : Used to featch the Dealer based account details
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getReturnPolicy(String dealerNo){
        if(String.isBlank(dealerNo) || dealerNo == ''){
            return null;
        }
        List<Account> accList = [SELECT ID,Name,Return_Policy__c, PoIId__c FROM Account where PoIId__c =:dealerNo];
        
        return !accList.isEmpty()?accList:null;
        
    }
    
     @AuraEnabled(cacheable = true)
    public static Map<String, Default_Policy_Markup__mdt> getReturnPolicyMarkupMdt(){

        Map<String, Default_Policy_Markup__mdt> mdtNameToMdtRec = new Map<String, Default_Policy_Markup__mdt>();
        
        
        for(Default_Policy_Markup__mdt mdt:[SELECT Id,Markup__c,Policy_Header__c,DeveloperName FROM Default_Policy_Markup__mdt]){
            mdtNameToMdtRec.put(mdt.DeveloperName, mdt);
        }
        
        return !mdtNameToMdtRec.isEmpty() ? mdtNameToMdtRec : null;
    }
}
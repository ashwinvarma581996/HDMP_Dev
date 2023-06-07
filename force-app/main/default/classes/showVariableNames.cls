/*******************************************************************************************
 * Name : Bhupendra Sisodiya/Neha B Mahajan
 * Description: This class will used for List of varibale Functionality on Offer and on Boilerplate orecord page.
 * 
 * ***************************************************************************************/

public class showVariableNames {
 
        /****************************************************************************
* Description: This method will show List of Variable on Offer
* Name: Bhupendra
* ***************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<	PRISM_merge_tag__mdt> getVariableList(String recordID) {
        
        Offers__c  objOffer = [select id,RecordType.Name,toLabel(Brand__c) from Offers__c where id=:RecordId];  
        System.debug('objOffer==>>'+objOffer);   
        
        List<PRISM_merge_tag__mdt> CusMetaList = [SELECT Id,Object_Name__c,Record_Type_Name__c,Field_API__c, Field_Name__c, Format__c, Variable_Name__c
                                                  FROM 	PRISM_merge_tag__mdt where Record_Type_Name__c=:objOffer.RecordType.Name and Brand__c=:objOffer.Brand__c and 
                                                  Object_Name__c IN ('Offers__c','Offer_Eligible_Models__c') ORDER BY Variable_Name__c ASC];
  
        
        return CusMetaList;
    }
            /****************************************************************************
* Description: This method will show List of Variable on Offer- used in showVariableName LWC
* Name: Neha
* ***************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<	PRISM_merge_tag__mdt> getboilerVariableList(String offerBrand, String offerType){
  
        String brand='';
        brand=offerBrand;
        switch on brand {
                when 'A' {
                    brand ='Honda' ;
                }
                when 'B' {
                    brand = 'Acura';
                }
            	when 'M' {
                    brand = 'Power Sports';
                }
        }
        List<PRISM_merge_tag__mdt> CusMetaList1 = [SELECT Id,Object_Name__c,Brand__c,Record_Type_Name__c,Field_API__c, Field_Name__c, Format__c, Variable_Name__c
                                                   FROM 	PRISM_merge_tag__mdt where Brand__c=:brand AND Record_Type_Name__c=:offerType ORDER BY Variable_Name__c ASC];
        System.debug('CusMetaList1'+CusMetaList1);
        return CusMetaList1;
    }
}
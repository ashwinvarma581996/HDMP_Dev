/*********************************************************************************************************************
Name: 			B2BMyPerferencesController
Date: 			09/08/2022
Description: 	Controller for the myPerferences component that authorizes a transaction
Test Class: 	B2BMyPerferencesControllerTest
***********************************************************************************************************************
MODIFICATIONS – Date 		|	Dev Name		|	Method		|	User Story
***********************************************************************************************************************
V1					|	Mathi/soumya	|			insertMyPreferredShipping	|		
***********************************************************************************************************************/

public without sharing class B2BMyPerferencesController {
    
    @AuraEnabled
    public static List<Account> checkExistingShippingPerferences(){
        User userRec = [SELECT Id,ContactId  FROM User WHERE Id =: userinfo.getUserId() AND ContactId != Null LIMIT 1];
        List<Account> existingShippingPerferencesList = new  List<Account>();
        if(userRec != null){
            existingShippingPerferencesList = [SELECT Id,Preferred_Honda_Shipping_Speed__r.Name, Preferred_Delivery_Type__c FROM Account WHERE PersonContactId =: userRec.ContactId AND Preferred_Delivery_Type__c !=Null AND Preferred_Honda_Shipping_Speed__c != Null];
        } 
        return existingShippingPerferencesList;
    }
    
    @AuraEnabled
    public static Boolean checkCurrentUserIsGuest(){
        User userRec = [SELECT Id,ContactId,Name FROM User WHERE Id =: userinfo.getUserId() and Name != Null LIMIT 1];
        if(userRec != null && userRec.Name.containsIgnoreCase('Guest')){
            return true;
        }
        return false;
    }
    //Changes on Below method for Notification preferences
    @AuraEnabled
    public static string insertMyPreferredShipping(String delivery, String shipping){
        
        List<Account> mypeferredShippingList = new  List<Account>();
        String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(userinfo.getUserId());
        try {
            HONDA_SHIPPING_SPEED__C hondaShipping = [SELECT ID, NAME FROM HONDA_SHIPPING_SPEED__C WHERE NAME= :shipping LIMIT 1];
            if(personAccountId != null && hondaShipping != null){
                mypeferredShippingList.add(new Account(Id=personAccountId,Preferred_Delivery_Type__c = delivery, Preferred_Honda_Shipping_Speed__c = hondaShipping.Id));
                
                if(!mypeferredShippingList.isEmpty()){
                    update mypeferredShippingList;
                    return 'Success';
                }else{
                    return 'Fail';
                }	
            }
        } catch(Exception e) {
            
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', personAccountId, personAccountId, '',
                                                              'B2BMyPerferencesController', e.getMessage(), '', '',
                                                              'insertMyPreferredShipping', false, '', '', '', (Long) 0.0, '',
                                                              'Request:', 'Response:');
            return 'Fail';
        }
        return 'Fail';
    }
    // End- Soumya Changes
    
    @AuraEnabled(cacheable=true)
    public static Map<string, List<String>> getPickListValues() {
        Map<string, List<String>> allPickListValuesMap = new Map<string, List<String>>();
        allPickListValuesMap.put('deliveryValueList', picklistValues(B2B_Constant.PREFERRED_FIELD_DELIVERY_TYPE));
        allPickListValuesMap.put('shippingValueList', picklistValues(B2B_Constant.NULL_VALUE));
        return allPickListValuesMap;
    }		
    
    private static List<String> picklistValues(String fieldName){ 
        List<String> lstPickvals=new List<String>();
        try{
            if(string.isNotEmpty(fieldName)){
                Schema.sObjectType sobject_type = Account.getSObjectType(); //grab the sobject that was passed
                Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
                Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
                List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
                for (Schema.PicklistEntry pickListData : pick_list_values) { //for all values in the picklist list
                    lstPickvals.add(pickListData.getValue());//add the value  to our final list
                }
            }else{
                List<HONDA_SHIPPING_SPEED__C>shippingpicklist = [SELECT ID,NAME FROM HONDA_SHIPPING_SPEED__C ORDER BY Name Desc LIMIT 200];
                // updated by saikiran as part of HDMP -13810
                String tempSpeed = '';
                for(HONDA_SHIPPING_SPEED__C hondaSpeed : shippingpicklist) {
                     if(hondaSpeed.Name == 'Express (1-2 Days)'){
                        tempSpeed = hondaSpeed.Name;
                     }
                     else{
                        lstPickvals.add(hondaSpeed.Name);
                     }
                }
                lstPickvals.add(tempSpeed);

            }
            return lstPickvals;
        } 
        
        catch(Exception e){
            String personAccountId = B2B_Fetch_PersonAccount.getPersonAccount(userinfo.getUserId());
            Error__c errorRecord = B2B_Util.createErrorRecord(true, '', '', personAccountId, personAccountId, '','B2BMyPerferencesController', e.getMessage(), '', '', 'getpicklistvalue', false, '', '', '', (Long) 0.0, '','Request:', 'Response:');
            return null;
        }
    }
}
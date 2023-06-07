//****************************************************************************** 
// File Name:       GetOfferRecordTypesUtility.cls
// Summary:         Apex Class for to Retrieve Offer Record Type based on User input
// Created On:      02-22-2023
// Created By:      Rama Iyer
// Test Classes:    OfferManagmentInboundProcessing_Test.cls
// Data I/O:        
// Honda Jira Story: Create APEX "FindProductController"
//===============================================================================
public class GetOfferRecordTypesUtility{
  
    @AuraEnabled(cacheable=true)
    public static Map<String,Id> getofferHeadRectypeIds() {
          Map<String,Id> recordTypesNametoId = new Map<String,Id>();
          List<List<RecordType>> recordtypelist=new List<List<RecordType>>();
         
        for(RecordTypeInfo info: Offer_Header__c.SObjectType.getDescribe().getRecordTypeInfos()) {
         
                //results.add(new FlowOutput(info.getRecordTypeId(), info.getName()));
                recordTypesNametoId.put(info.getDeveloperName(),info.getRecordTypeId());
            
        }
        //recordtypelist.add(recordTypes);
    return recordTypesNametoId;
    }
    public static Map<String,Id> getofferRectypeIds() {
          Map<String,Id> recordTypesNametoId = new Map<String,Id>();
          List<List<RecordType>> recordtypelist=new List<List<RecordType>>();
         
        for(RecordTypeInfo info: Offers__c.SObjectType.getDescribe().getRecordTypeInfos()) {
         
                //results.add(new FlowOutput(info.getRecordTypeId(), info.getName()));
                recordTypesNametoId.put(info.getDeveloperName(),info.getRecordTypeId());
            
        }
        //recordtypelist.add(recordTypes);
    return recordTypesNametoId;
    }
    public static Map<String,Id> getofferEligModRectypeIds() {
          Map<String,Id> recordTypesNametoId = new Map<String,Id>();
          List<List<RecordType>> recordtypelist=new List<List<RecordType>>();
         
        for(RecordTypeInfo info: Offer_Eligible_Models__c.SObjectType.getDescribe().getRecordTypeInfos()) {
         
                //results.add(new FlowOutput(info.getRecordTypeId(), info.getName()));
                recordTypesNametoId.put(info.getDeveloperName(),info.getRecordTypeId());
            
        }
        //recordtypelist.add(recordTypes);
    return recordTypesNametoId;
    }
    public static Map<Id,String> getOffHeadRecordTypeNames() {
        Map<Id,String> recordTypesIdtoName = new Map<Id,String>();
        for(RecordTypeInfo info: Offer_Header__c.SObjectType.getDescribe().getRecordTypeInfos()) {
         
                //results.add(new FlowOutput(info.getRecordTypeId(), info.getName()));
                recordTypesIdtoName.put(info.getRecordTypeId(),info.getDeveloperName());
            
        }
        //recordtypelist.add(recordTypes);
    return recordTypesIdtoName;
    }
     public static Map<Id,String> getOfferRecordTypeNames() {
        Map<Id,String> recordTypesIdtoName = new Map<Id,String>();
        for(RecordTypeInfo info: Offers__c.SObjectType.getDescribe().getRecordTypeInfos()) {
         
                //results.add(new FlowOutput(info.getRecordTypeId(), info.getName()));
                recordTypesIdtoName.put(info.getRecordTypeId(),info.getDeveloperName());
            
        }
        //recordtypelist.add(recordTypes);
    return recordTypesIdtoName;
    }
    public static Map<Id,string> getOEMRecTypes() {
        Map<Id,string> recordTypesIdToName = new Map<Id,string>();
       
      for(RecordTypeInfo info: Offer_Eligible_Models__c.SObjectType.getDescribe().getRecordTypeInfos()) {
       
              //results.add(new FlowOutput(info.getRecordTypeId(), info.getName()));
              recordTypesIdToName.put(info.getRecordTypeId(),info.getDeveloperName());
              
      }
      //recordtypelist.add(recordTypes);
  return recordTypesIdToName;
  }

}
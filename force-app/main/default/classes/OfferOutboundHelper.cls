/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-16-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//****************************************************************************** 
// File Name:       OfferOutboundHelper.cls
// Summary:         This is helper class for Offer Outbound Integration
// Created On:      03-31-2023
// Created By:      Rama Iyer
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
public class OfferOutboundHelper {

    /*This method gets the configured inetgraton settings from Metadata Type */
    public static Map<String,OM_Integration_Setting__mdt> getAllIntegrationSettings(){
        
        Map<String,OM_Integration_Setting__mdt> mapSettings = new Map<String,OM_Integration_Setting__mdt>();
        for(OM_Integration_Setting__mdt objSetting :[SELECT ID, MasterLabel,Parameters__c,Endpoint_URL__c,Method__c,HeaderValue__c,Environment__c,  Success_Status_Codes__c,UserName__c,Password__c FROM OM_Integration_Setting__mdt]){
           // mapSettings.put(objSetting.Method__c+objSetting.MasterLabel, objSetting);
           mapSettings.put(objSetting.MasterLabel, objSetting);
        }
        return mapSettings;
    } 
   
    /* This method is used to get the include sample payment value based on offer types and sample finanical terms */
    public static boolean getIncludeSamplePayment(Offers__c offerRec,Offer_Eligible_Models__c modelRec)
    {
        map<Id,string> mapOfferRecTypes = GetOfferRecordTypesUtility.getOfferRecordTypeNames();
    
      //If Lease then get include sample payment flag from Model
      //If finance /programs and featured=true and sample monthly payment is not blank below should be set to true
      boolean bPaymentValue=false;
      if(offerRec !=null && modelRec !=null)
      {
          system.debug('###request:'+mapOfferRecTypes.get(offerRec.RecordTypeId).contains('Finance'));
          system.debug('###featured offer:'+modelRec.Featured_Offer__c+':'+offerRec.Sample_Monthly_Payment__c);
          
        if(mapOfferRecTypes.get(offerRec.RecordTypeId).contains('Lease'))
        {
          bPaymentValue= modelRec.Include_Sample_Payment__c;
        }
        else if(mapOfferRecTypes.get(offerRec.RecordTypeId).contains('Finance') )
        {
          if(modelRec!=null && modelRec.Featured_Offer__c == true && offerRec.Sample_Monthly_Payment__c!=null)
          {
            bPaymentValue = true; 
          }
        }
        //04-11-2023 :  Added by Rama Iyer 04/10/2023
        else if (mapOfferRecTypes.get(offerRec.RecordTypeId).contains('Program') ||mapOfferRecTypes.get(offerRec.RecordTypeId).contains('Power'))
        {
          if(modelRec!=null && modelRec.Featured_Offer__c == true )
          {
            bPaymentValue = true; 
          }
        }
      }      
      return bPaymentValue;
    }    

/* This method takes the elgiblemodel records and filters the featured,include sample payment models having lowest sort order record*/
public static Offer_Eligible_Models__c getLowestFeaturedModel(List<Offer_Eligible_Models__c> lstElgibleModels)
{
  map<Decimal,Offer_Eligible_Models__c> mapModelsBySortOrder = new map<Decimal,Offer_Eligible_Models__c>();//key - sort order, value - model record
  List<Decimal> lstSortOrder;
  Offer_Eligible_Models__c objLowestElgibleModel;
  if(lstElgibleModels !=null)
  {
    for(Offer_Eligible_Models__c modelRecord:lstElgibleModels)
    {
      if(modelRecord.Featured_Offer__c || modelRecord.Include_Sample_Payment__c == true)
      {
        mapModelsBySortOrder.put(modelRecord.Sort_Order__c,modelRecord);// this will contain only featured models
        
      }
    }
   
    if(mapModelsBySortOrder !=null && mapModelsBySortOrder.size()> 0)
    {
      lstSortOrder = new List<Decimal>(mapModelsBySortOrder.keySet());
      if(lstSortOrder.size() > 0){
      lstSortOrder.sort();//this sorts the list based on sort order and top most record is always with low sort order.so indexing to get corresponding model record
      objLowestElgibleModel = mapModelsBySortOrder.get(lstSortOrder[0]);
      }
    }    
  }
  return objLowestElgibleModel;
}
/* This methods gets the headervalues*/
public static Map<String,String> getHeaderValue(String headerJson){
    Map<String,String> mapHeaderKeyToHeaderValue = new Map<String,String>();
    List<Object> headerValueResult = (List<Object>)JSON.deserializeUntyped(headerJson); 
    
    for(Object obj : headerValueResult) { 
        Map<String,Object> mapHeaderKeyToHeaderValueTemp = (Map<String,Object>)obj;      
        mapHeaderKeyToHeaderValue.put((String)mapHeaderKeyToHeaderValueTemp.get('key'),(String)mapHeaderKeyToHeaderValueTemp.get('value'));
    }
   
    //Manohar:Added below to pass unique header message Id on 26th April 23
    string messageId = getHeaderMessageId(); 
    system.debug('unique message Id:'+messageId);
    if(messageId !=null)
    {
      mapHeaderKeyToHeaderValue.put('hondaHeaderType.messageId',messageId);
      system.debug('after unique message Id:'+mapHeaderKeyToHeaderValue);
    }
    
    return mapHeaderKeyToHeaderValue;
}
/* This method is used to get the special category based on brand and record type for offers.
This method is used in request classes for call out */
public static string getSpecialCategory(string brand,string recordTypeId)
{
  string specialCategory;
  if(brand !=null && recordTypeId !=null)
  {
    switch on brand{
      when 'A'{
        specialCategory = OfferMgmtConstants.SPL_CATEGORY_MAP_FOR_HONDA_ACURA.get(brand);
      }
      when 'B'{
        specialCategory = OfferMgmtConstants.SPL_CATEGORY_MAP_FOR_HONDA_ACURA.get(brand);
      }
      when 'M'{
        string recTypeName = GetOfferRecordTypesUtility.getOfferRecordTypeNames().get(recordTypeId);
        specialCategory = OfferMgmtConstants.SPL_CATEGORY_MAP_FOR_PS.get(recTypeName);
      }
  } 
}
return specialCategory; 
}

/*This method is used to retrieve offer record details for standard specials */
public static Offers__c getOfferDetailsForStandardSpecial(string offerId)
{
 return[SELECT Standard_Program_APR_High__c,Security_Deposit_Required__c,Terms_and_Conditions__c,Legal_Desclaimer__c,Detailed_Description__c,Sample_Termmonths__c,Standard_Program_APR_Low__c,Additional_Cash__c,Additional_Info_URL__c,Advertised_End_Date_NUM__c,Advertised_End_Date__c,Advertised_Start_Date_NUM__c,Advertised_Start_Date__c,AHFC_Approved__c,AHFC_Internal_Program_Name__c,AHFC_Internal_Sales_Program_Name__c,AHM_Regions__c,AHFC_Sales_Program_ID__c,AHM_Sales_Program_ID__c,Approval_Link__c,APR_1__c,APR_2__c,APR_3__c,APR_4__c,APR_5__c,APR_6__c,Banner_Disclaimer_3__c,Banner_Disclaimer_4__c,Banner_Disclaimer_5__c,
  Banner_Disclaimer_Competitor_Model__c,Banner_Disclaimer_Prefix__c,Banner_Image_URL__c,Banner_Sales_Program_Type__c,Banner_Short_Description__c,Base_Monthly_Payment__c,Boilerplate__c,Bonus_Bucks_Amount__c,Brand__c,Capital_Cost_Reduction__c,ClonedSourceID__c,Conquest_Cash__c,CreatedDate,Created__c,Create_Date__c,Creator_Name__c,Credit_Tier_Description__c,Credit_Tier__c,Custom_clone__c,Custom_Offer_Attributes__c,Cutline_Text__c,Dealer_Contribution__c,Descriptive_Name__c,Display_Type__c,Double_Bonus_Bucks_Amount__c,End_Date_NUM__c,End_Date__c,File_Name__c,Gross_Margin__c,Group_Code__c,Group_Name__c,Group_Type__c,Id,Invoice_Price_With_DH__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LifeCycle__c,Lock_Date__c,Lock_Owner__c,Min_Pay__c,Monthly_APR__c,Monthly_Payment_Amount__c,Name,No_Interest_Required_Duration__c,No_Payments_Required_Duration__c,Offer_Amount__c,Offer_Availability__c,Offer_Header__c,Offer_Identifier__c,Offer_Title__c,Offer_Type__c,Original_High_Balance_APR__c,OwnerId,Owner_name__c,Picklist1__c,Picklist_2__c,Preview__c,Priority__c,PRISM_Offer_Status__c,Product_Division_Name__c,Product_Type__c,Program_End_Date__c,Program_Start_Date__c,Promotional_APR__c,Promotion_Duration__c,Promotion_Name__c,RecordTypeId,Record_Type_Name__c,Related_Queue__c,Sales_Program_Type_CD__c,Sales_Program_Type_Name__c,Sample_APR__c,Sample_Model_Description__c,Sample_Monthly_Payment__c,Short_Description__c,Size__c,Special_category__c,Special_Region_Type_Name__c,Special_Region__c,Standard_Program_Date__c,Start_Date_NUM__c,Start_Date__c,State_Code__c,State_Name__c,Status__c,Synched_with_PRISM__c,SystemModstamp,Term_Description__c,Term_Max_1__c,Term_Max_2__c,Term_Max_3__c,Term_Max_4__c,Term_Max_5__c,Term_Max_6__c,Term_Min_1__c,Term_Min_2__c,Term_Min_3__c,Term_Min_4__c,Term_Min_5__c,Term_Min_6__c,Title_Name__c,Title__c,Total_Amount_Financed__c,Total_Due_at_Signing__c,Total_Monthly_Payment__c,Transaction_Status__c,User1__c,User2__c,Vehicle_Type_CD__c,Vehicle_Type__c,Version_Number__c,Zero_Due__c,
  National_Offer__c,National_Offer__r.Offer_Header__c,Lease_Title_Ident__c from offers__c where Id=:offerId];
}

/* This method is used to retrive the list of Offer Elgible Model records  and prepare map of Offer Id and corresponding list of models*/
public static map<string,List<Offer_Eligible_Models__c>> getElgibleModelsByOfferForStandardSpecial(string offerId)
{
  map<string,List<Offer_Eligible_Models__c>> mapOfferToModels = new map<string,List<Offer_Eligible_Models__c>>();
  List<Offer_Eligible_Models__c> lstModels = [SELECT Acquisition_Fee__c,Adjusted_MSRP_with_DH__c,Annual_Miles__c,Base_Monthly_Payment__c,Brand__c,Capitalized_Cost_Reduction__c,Captive_Cash_Lease_Amount__c,CreatedById,CreatedDate,Dealer_Contribution__c,Default_Image__c,Depreciation_Amount__c,Featured_Offer__c,Featured_Term__c,Sort_Order__c,Gross_Cap_Cost_After_Dealer_Contrib__c,Gross_Cap_Cost_Before_Dealer_Contrib__c,Gross_Margin__c,Include_Sample_Payment__c,Id,Incentive_Cycle_Id__c,Invoice_Amount__c,Invoice_Price_with_DH__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lease_Option_Id__c,Lease_Option_Type__c,Mileage__c,ModelParentSeriesGroupName__c,Model_Code__c,Model_Group_Name__c,Model_ID__c,Model_Marketing_Name__c,Model_Series_Group_Name__c,Model_Series__c,Model__c,Money_Factor__c,MSRP__c,Name,Net_Capital_Cost__c,Offer__c,Other_Captive_Cash_Lease_Amount__c,OwnerId,Program_Code__c,Residual_Factor__c,Residual_Pct__c,Residual_Value__c,Segment__c,Service_Charge_Amount__c,Special_Region__c,SystemModstamp,Terms_Months__c,Title_Ident__c,Total_Due_At_signing__c,Total_Monthly_Payment__c,Trim__c,Residual_Rate__c,Year__c,Large_Image_Path__c,Image_Color__c,Image_Source_Name__c,Dh_Cost__c,Conquest_Cash__c,Loyalty_Cash__c,Additional_Cash__c,Offer_Title__c,Short_Description__c,Legal_Desclaimer__c,Detailed_Description__c,Terms_and_Conditions__c 
                                              FROM Offer_Eligible_Models__c
                                              where Offer__c=:offerId
                                              Order by Sort_Order__c];
   if(lstModels != null && lstModels.size()> 0)  
   {
    mapOfferToModels.put(offerId,lstModels);
   }                                         
  
  return mapOfferToModels;
}

/* This method is used to retrieve offer record details for specials */
public static Offers__c getOfferDetailsForSpecial(string offerId)
{
  return [SELECT National_Offer__c,Security_Deposit_Required__c,Terms_and_Conditions__c,Detailed_Description__c,Legal_Desclaimer__c,Standard_Program_APR_High__c,Sales_Program_CD__c,Standard_Program_APR_Low__c,Additional_Cash__c,Additional_Info_URL__c,Advertised_End_Date_NUM__c,Advertised_End_Date__c,Advertised_Start_Date_NUM__c,Advertised_Start_Date__c,AHFC_Approved__c,AHFC_Internal_Program_Name__c,AHFC_Internal_Sales_Program_Name__c,AHM_Regions__c,AHFC_Sales_Program_ID__c,AHM_Sales_Program_ID__c,Approval_Link__c,APR_1__c,APR_2__c,APR_3__c,APR_4__c,APR_5__c,APR_6__c,Banner_Disclaimer_3__c,Banner_Disclaimer_4__c,Banner_Disclaimer_5__c,Banner_Disclaimer_Competitor_Model__c,Banner_Disclaimer_Prefix__c,Banner_Image_URL__c,Banner_Sales_Program_Type__c,Banner_Short_Description__c,Base_Monthly_Payment__c,Boilerplate__c,Bonus_Bucks_Amount__c,Brand__c,Capital_Cost_Reduction__c,ClonedSourceID__c,Conquest_Cash__c,CreatedDate,Created__c,Create_Date__c,Creator_Name__c,Credit_Tier_Description__c,Credit_Tier__c,Custom_clone__c,Custom_Offer_Attributes__c,Cutline_Text__c,Dealer_Contribution__c,Descriptive_Name__c,Display_Type__c,Double_Bonus_Bucks_Amount__c,End_Date_NUM__c,End_Date__c,File_Name__c,Gross_Margin__c,Group_Code__c,Group_Name__c,Group_Type__c,Id,Invoice_Price_With_DH__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LifeCycle__c,Lock_Date__c,Lock_Owner__c,Min_Pay__c,Monthly_APR__c,Monthly_Payment_Amount__c,Name,No_Interest_Required_Duration__c,No_Payments_Required_Duration__c,Offer_Amount__c,Offer_Availability__c,Offer_Header__c,Offer_Identifier__c,Offer_Title__c,Offer_Type__c,Original_High_Balance_APR__c,OwnerId,Owner_name__c,Picklist1__c,Picklist_2__c,Preview__c,Priority__c,PRISM_Offer_Status__c,Product_Division_Name__c,Product_Type__c,Program_End_Date__c,Program_Start_Date__c,Promotional_APR__c,Promotion_Duration__c,Promotion_Name__c,RecordTypeId,Record_Type_Name__c,Related_Queue__c,Sales_Program_Type_CD__c,Sales_Program_Type_Name__c,Sample_APR__c,Sample_Model_Description__c,Sample_Monthly_Payment__c,Sample_Termmonths__c,Short_Description__c,Size__c,Special_category__c,Special_Region_Type__c,Special_Region_Type_Name__c,Special_Region__c,Standard_Program_Date__c,Start_Date_NUM__c,Start_Date__c,State_Code__c,State_Name__c,Status__c,Synched_with_PRISM__c,SystemModstamp,Term_Description__c,Term_Max_1__c,Term_Max_2__c,Term_Max_3__c,Term_Max_4__c,Term_Max_5__c,Term_Max_6__c,Term_Min_1__c,Term_Min_2__c,Term_Min_3__c,Term_Min_4__c,Term_Min_5__c,Term_Min_6__c,Title_Name__c,Title__c,Total_Amount_Financed__c,Total_Due_at_Signing__c,Total_Monthly_Payment__c,Transaction_Status__c,User1__c,User2__c,Vehicle_Type_CD__c,Vehicle_Type__c,Version_Number__c,Zero_Due__c,
                       National_Offer__r.Offer_Header__c,Lease_Title_Ident__c from offers__c where Id=:offerId];
}
/* This method is used to retrive the list of Offer Elgible Model records  and prepare map of Offer Id and corresponding list of models*/
public static map<string,List<Offer_Eligible_Models__c>> getElgibleModelsByOfferForSpecial(string offerId)
{
  map<string,List<Offer_Eligible_Models__c>> mapOfferToModels = new map<string,List<Offer_Eligible_Models__c>>();
  List<Offer_Eligible_Models__c> lstModels = [SELECT Acquisition_Fee__c,Adjusted_MSRP_with_DH__c,Annual_Miles__c,Base_Monthly_Payment__c,Brand__c,Capitalized_Cost_Reduction__c,Captive_Cash_Lease_Amount__c,CreatedById,CreatedDate,Dealer_Contribution__c,Default_Image__c,Depreciation_Amount__c,Featured_Offer__c,Featured_Term__c,Sort_Order__c,Gross_Cap_Cost_After_Dealer_Contrib__c,Gross_Cap_Cost_Before_Dealer_Contrib__c,Gross_Margin__c,Include_Sample_Payment__c,Id,Incentive_Cycle_Id__c,Invoice_Amount__c,Invoice_Price_with_DH__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lease_Option_Id__c,Lease_Option_Type__c,Mileage__c,ModelParentSeriesGroupName__c,Model_Code__c,Model_Group_Name__c,Model_ID__c,Model_Marketing_Name__c,Model_Series_Group_Name__c,Model_Series__c,Model__c,Money_Factor__c,MSRP__c,Name,Net_Capital_Cost__c,Offer__c,Other_Captive_Cash_Lease_Amount__c,OwnerId,Program_Code__c,Residual_Factor__c,Residual_Pct__c,Residual_Value__c,Segment__c,Service_Charge_Amount__c,Special_Region__c,SystemModstamp,Terms_Months__c,Title_Ident__c,Total_Due_At_signing__c,Total_Monthly_Payment__c,Trim__c,Residual_Rate__c,Year__c,Large_Image_Path__c,Image_Color__c,Image_Source_Name__c,Dh_Cost__c,Conquest_Cash__c,Loyalty_Cash__c,Additional_Cash__c,Offer_Title__c,Short_Description__c,Legal_Desclaimer__c,Detailed_Description__c,Terms_and_Conditions__c 
                                              FROM Offer_Eligible_Models__c
                                              where offer__c=:offerId 
                                              Order by Sort_Order__c];
    if(lstModels != null && lstModels.size()> 0)  
    {
      mapOfferToModels.put(offerId,lstModels);
    }   
 
  return mapOfferToModels;  
}

/*This method is used to generate the unique message id for outbound request */
public static string getHeaderMessageId()
{
  Blob uidInBytes = Crypto.generateAESKey(128);
  String uniqueUID = EncodingUtil.convertToHex(uidInBytes);
  uniqueUID = uniqueUID.substring(0, 8) + '-' +
              uniqueUID.substring(8, 12) + '-' +
              '4' + uniqueUID.substring(13, 16) + '-' + 
              String.valueOf((Math.random() * 4 + 8)).substring(0, 1) + 
              uniqueUID.substring(17, 20) + '-' +uniqueUID.substring(20, 32);
return uniqueUID;
}

}
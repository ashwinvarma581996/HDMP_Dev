/**
 * @description       : 
 * @author            : Rama Iyer
 * @group             : 
 * @last modified on  : 05-18-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//****************************************************************************** 
// File Name:       EshoppyOutboundRequest.cls
// Summary:         This is request class for Eshoppy for finance types
// Created On:      03-04-2023
// Created By:      Rama Iyer
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
public class EshoppyOutboundRequest {
  
public static void sendOutboundEshoppyReq(ID offerId,string offerStatus){ 
  /*
Offers__c offerRecord =[SELECT Standard_Program_APR_High__c,Security_Deposit_Required__c,Terms_and_Conditions__c,Legal_Desclaimer__c,Detailed_Description__c,Sample_Termmonths__c,Standard_Program_APR_Low__c,Additional_Cash__c,Additional_Info_URL__c,Advertised_End_Date_NUM__c,Advertised_End_Date__c,Advertised_Start_Date_NUM__c,Advertised_Start_Date__c,AHFC_Approved__c,AHFC_Internal_Program_Name__c,AHFC_Internal_Sales_Program_Name__c,AHM_Regions__c,AHFC_Sales_Program_ID__c,AHM_Sales_Program_ID__c,Approval_Link__c,APR_1__c,APR_2__c,APR_3__c,APR_4__c,APR_5__c,APR_6__c,Banner_Disclaimer_3__c,Banner_Disclaimer_4__c,Banner_Disclaimer_5__c,Banner_Disclaimer_Competitor_Model__c,Banner_Disclaimer_Prefix__c,Banner_Image_URL__c,Banner_Sales_Program_Type__c,Banner_Short_Description__c,Base_Monthly_Payment__c,Boilerplate__c,Bonus_Bucks_Amount__c,Brand__c,Capital_Cost_Reduction__c,ClonedSourceID__c,Conquest_Cash__c,CreatedDate,Created__c,Create_Date__c,Creator_Name__c,Credit_Tier_Description__c,Credit_Tier__c,Custom_clone__c,Custom_Offer_Attributes__c,Cutline_Text__c,Dealer_Contribution__c,Descriptive_Name__c,Display_Type__c,Double_Bonus_Bucks_Amount__c,End_Date_NUM__c,End_Date__c,File_Name__c,Gross_Margin__c,Group_Code__c,Group_Name__c,Group_Type__c,Id,Invoice_Price_With_DH__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LifeCycle__c,Lock_Date__c,Lock_Owner__c,Min_Pay__c,Monthly_APR__c,Monthly_Payment_Amount__c,Name,No_Interest_Required_Duration__c,No_Payments_Required_Duration__c,Offer_Amount__c,Offer_Availability__c,Offer_Header__c,Offer_Identifier__c,Offer_Title__c,Offer_Type__c,Original_High_Balance_APR__c,OwnerId,Owner_name__c,Picklist1__c,Picklist_2__c,Preview__c,Priority__c,PRISM_Offer_Status__c,Product_Division_Name__c,Product_Type__c,Program_End_Date__c,Program_Start_Date__c,Promotional_APR__c,Promotion_Duration__c,Promotion_Name__c,RecordTypeId,Record_Type_Name__c,Related_Queue__c,Sales_Program_Type_CD__c,Sales_Program_Type_Name__c,Sample_APR__c,Sample_Model_Description__c,Sample_Monthly_Payment__c,Short_Description__c,Size__c,Special_category__c,Special_Region_Type_Name__c,Special_Region__c,Standard_Program_Date__c,Start_Date_NUM__c,Start_Date__c,State_Code__c,State_Name__c,Status__c,Synched_with_PRISM__c,SystemModstamp,Term_Description__c,Term_Max_1__c,Term_Max_2__c,Term_Max_3__c,Term_Max_4__c,Term_Max_5__c,Term_Max_6__c,Term_Min_1__c,Term_Min_2__c,Term_Min_3__c,Term_Min_4__c,Term_Min_5__c,Term_Min_6__c,Title_Name__c,Title__c,Total_Amount_Financed__c,Total_Due_at_Signing__c,Total_Monthly_Payment__c,Transaction_Status__c,User1__c,User2__c,Vehicle_Type_CD__c,Vehicle_Type__c,Version_Number__c,Zero_Due__c,
                        National_Offer__c,National_Offer__r.Offer_Header__c,(SELECT Acquisition_Fee__c,Adjusted_MSRP_with_DH__c,Annual_Miles__c,Base_Monthly_Payment__c,Brand__c,Capitalized_Cost_Reduction__c,Captive_Cash_Lease_Amount__c,Category__c,CreatedById,CreatedDate,Dealer_Contribution__c,Default_Image__c,Depreciation_Amount__c,Featured_Offer__c,Featured_Term__c,Sort_Order__c,Gross_Cap_Cost_After_Dealer_Contrib__c,Gross_Cap_Cost_Before_Dealer_Contrib__c,Gross_Margin__c,Include_Sample_Payment__c,Id,Incentive_Cycle_Id__c,Invoice_Amount__c,Invoice_Price_with_DH__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lease_Option_Id__c,Lease_Option_Type__c,Mileage__c,ModelParentSeriesGroupName__c,Model_Code__c,Model_Group_Name__c,Model_ID__c,Model_Marketing_Name__c,Model_Series_Group_Name__c,Model_Series__c,Model__c,Money_Factor__c,MSRP__c,Name,Net_Capital_Cost__c,Offer__c,Other_Captive_Cash_Lease_Amount__c,OwnerId,Program_Code__c,Residual_Factor__c,Residual_Pct__c,Residual_Value__c,Segment__c,Service_Charge_Amount__c,Special_Region__c,SystemModstamp,Terms_Months__c,Title_Ident__c,Total_Due_At_signing__c,Total_Monthly_Payment__c,Trim__c,Residual_Rate__c,Year__c,Large_Image_Path__c,Image_Color__c,Image_Source_Name__c,Dh_Cost__c,Conquest_Cash__c,Loyalty_Cash__c,Offer_Title__c,Short_Description__c,Legal_Desclaimer__c,Detailed_Description__c,Terms_and_Conditions__c,Additional_Cash__c FROM Offer_Eligible_Models__r order by Sort_Order__c)FROM Offers__c where id =:offerId ];
 */
offers__c offerRecord = OfferOutboundHelper.getOfferDetailsForStandardSpecial(offerId);
map<string,List<Offer_Eligible_Models__c>> mapOfferModels = OfferOutboundHelper.getElgibleModelsByOfferForStandardSpecial(offerId);

Offer_Eligible_Models__c objFeaturedLowOrderModelRecord = OfferOutboundHelper.getLowestFeaturedModel(mapOfferModels.get(offerId));
EshoppyOutboundRequestWrapper req = new EshoppyOutboundRequestWrapper();

 List<EshoppyOutboundRequestWrapper.cls_StandardSpecial> stdSpecialList = new List<EshoppyOutboundRequestWrapper.cls_StandardSpecial>();
 EshoppyOutboundRequestWrapper.cls_StandardSpecial stdSpecial = new EshoppyOutboundRequestWrapper.cls_StandardSpecial();
  stdSpecial.StandardSpecialId=offerRecord.Offer_Header__c;//It should always use Offer Header Id
  stdSpecial.Action= offerStatus == 'Expired'?'Delete':'Upsert';
        
  stdSpecial.OfferIdentifier=offerRecord.Offer_Header__c;
  stdSpecial.AddlInfoUrl= offerRecord.Additional_Info_URL__c;
  stdSpecial.AhfcEndDate=String.ValueOf(offerRecord.End_Date__c);
  stdSpecial.AhfcSlsPgmId=offerRecord.AHFC_Sales_Program_ID__c;
  stdSpecial.AhfcStartDate=String.ValueOf(offerRecord.Start_Date__c);
  stdSpecial.AhmSlsPgmId=offerRecord.AHM_Sales_Program_ID__c;
  stdSpecial.BannerDiscCompetModel = offerRecord.Banner_Disclaimer_Competitor_Model__c;
  stdSpecial.BannerDiscPrefix=offerRecord.Banner_Disclaimer_Prefix__c;
  stdSpecial.BannerDisclaimer3=offerRecord.Banner_Disclaimer_3__c;
  stdSpecial.BannerDisclaimer4=offerRecord.Banner_Disclaimer_4__c;
  stdSpecial.BannerDisclaimer5=offerRecord.Banner_Disclaimer_5__c;
  stdSpecial.BannerImageUrl=offerRecord.Banner_Image_URL__c;
  stdSpecial.BannerShortDescription=offerRecord.Banner_Short_Description__c;
  stdSpecial.BannerSlsPgmType=offerRecord.Banner_Sales_Program_Type__c;
  stdSpecial.BonusBucksAmount=offerRecord.Bonus_Bucks_Amount__c;
  stdSpecial.CreatedDate=String.ValueOf(offerRecord.Create_Date__c);
  stdSpecial.CutlineTxt=offerRecord.Cutline_Text__c;
  //stdSpecial.Descr=offerRecord.Detailed_Description__c;
  if(objFeaturedLowOrderModelRecord !=null)
  {
    stdSpecial.Descr=objFeaturedLowOrderModelRecord.Detailed_Description__c;
    //stdSpecial.ShortDescr=offerRecord.Short_Description__c;
    stdSpecial.ShortDescr=objFeaturedLowOrderModelRecord.Short_Description__c;
    //stdSpecial.ShortDisclaimer=offerRecord.Legal_Desclaimer__c;
    stdSpecial.ShortDisclaimer=objFeaturedLowOrderModelRecord.Legal_Desclaimer__c; 
    //stdSpecial.SlsPgmName=offerRecord.Offer_Title__c;
    stdSpecial.SlsPgmName=objFeaturedLowOrderModelRecord.Offer_Title__c;
    //stdSpecial.TermAndCondTx=offerRecord.Terms_and_Conditions__c;
    stdSpecial.TermAndCondTx = objFeaturedLowOrderModelRecord.Terms_and_Conditions__c; 
  }
  stdSpecial.DoubleBonusBucksAmount=offerRecord.Double_Bonus_Bucks_Amount__c;
  stdSpecial.EcmsStatusCd= offerStatus == 'Submitted'?'P':'A';   
  //stdSpecial.AWebcUrl='Acura/offers/C/R/U2Z2I.xml'; Not needed as per 03/23 Discussion with Dennis he will default
  if(offerRecord.Advertised_Start_Date__c!=null){
    stdSpecial.EffDate=String.ValueOf(offerRecord.Advertised_Start_Date__c);
  }else{
    stdSpecial.EffDate=String.ValueOf(offerRecord.Start_Date__c); 
  }
   //stdSpecial.EndDate=offerRecord.End_Date__c;
  //05/16/2023 - Rama Iyer - OMP-301 End Date use the same logic as Start Date
  if(offerRecord.Advertised_End_Date__c!=null){
    stdSpecial.EndDate=String.ValueOf(offerRecord.Advertised_End_Date__c);
  }else{
    stdSpecial.EndDate=String.ValueOf(offerRecord.End_Date__c); 
  }  
   stdSpecial.HasSecurityDeposit =offerRecord.Security_Deposit_Required__c;
   stdSpecial.HfSelectSort=offerRecord.Priority__c; 
   stdSpecial.LastUpdatedDate=String.ValueOf(offerRecord.LastModifiedDate);
   stdSpecial.MinCreditTierCd=offerRecord.Credit_Tier__c; 
   Schema.DescribeFieldResult objFieldDescribe = Offers__c.Credit_Tier__c.getDescribe();
  List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
  string creditTierLabel='';
  for (Schema.PicklistEntry objPickList : lstPickListValues) {
      if(objPickList.getValue()== offerRecord.Credit_Tier__c){
        creditTierLabel=objPickList.getLabel();      
      }
  }
   stdSpecial.MinCreditTierDescr=creditTierLabel;
   stdSpecial.MonthlyApr=offerRecord.Monthly_APR__c;
   
        if(offerRecord.National_Offer__c!=null){
            stdSpecial.IsSplit='true'; 
        }else{
			stdSpecial.IsSplit='false';             
        }
        stdSpecial.SplitFromId=offerRecord.National_Offer__r.Offer_Header__c;
   stdSpecial.MonthlyPaymentAmount=offerRecord.Monthly_Payment_Amount__c;
   stdSpecial.NoInterestDuration=offerRecord.No_Interest_Required_Duration__c;
   stdSpecial.NoPaymentDuration=offerRecord.No_Payments_Required_Duration__c;
   stdSpecial.OfferAmount = offerRecord.Offer_Amount__c;
   stdSpecial.OriginalHighBalanceApr=offerRecord.Original_High_Balance_APR__c;
   stdSpecial.PromotionApr=offerRecord.Promotional_APR__c;
   stdSpecial.PromotionDuration=offerRecord.Promotion_Duration__c;
   stdSpecial.SampleApr=offerRecord.Sample_APR__c;
   stdSpecial.SampleMonthlyPayment=offerRecord.Sample_Monthly_Payment__c; //This probably should not be on the Offer Record and as per sample should be on the Model
   stdSpecial.SampleTerm=offerRecord.Sample_Termmonths__c;
   
   stdSpecial.SlsPgmTypCd=offerRecord.Sales_Program_Type_CD__c;
   //stdSpecial.SpecialCategory=offerRecord.Special_category__c;
   stdSpecial.SpecialCategory=OfferOutboundHelper.getSpecialCategory(offerRecord.Brand__c,offerRecord.recordTypeId) ;
   stdSpecial.SpecialRegion=offerRecord.Offer_Availability__c;
   stdSpecial.SpecialTyp=offerRecord.Vehicle_Type_CD__c;
   stdSpecial.StandardProgramAprHigh=offerRecord.Standard_Program_APR_High__c;
   stdSpecial.StandardProgramAprLow=offerRecord.Standard_Program_APR_Low__c; 
   stdSpecial.StandardProgramDate=offerRecord.Standard_Program_Date__c;
   
   stdSpecial.TotalAmountFinanced=offerRecord.Total_Amount_Financed__c;
   stdSpecial.XprodDivCd =offerRecord.Brand__c;
   stdSpecial.ZeroDue=offerRecord.Zero_Due__c;
   //Offer Defect OMP-375 added by Rama Iyer 05/16/2023
   stdSpecial.TitleIdent=offerRecord.Lease_Title_Ident__c!=null?Integer.valueof(offerRecord.Lease_Title_Ident__c):null;

   string attributeValues=offerRecord.Custom_Offer_Attributes__c;
   List<string> attributeValuesList =new List<string>();
   if(attributeValues!=null){
    attributeValuesList=attributeValues.split(';');
    for(integer i=0;i<attributeValuesList.size();i++){
     if(attributeValuesList[i].right(2)=='_A' || attributeValuesList[i].right(2)=='_B'){
     attributeValuesList[i]=attributeValuesList[i].Substring(0,attributeValuesList[i].length()-2);
     }
    }
   }
   stdSpecial.Attribute=attributeValuesList;

   List<EshoppyOutboundRequestWrapper.cls_Model> modelList = new List<EshoppyOutboundRequestWrapper.cls_Model>();
   
   if(mapOfferModels.get(offerId) !=null && mapOfferModels.get(offerId).size()>0) {
   for(Offer_Eligible_Models__c oemodel : mapOfferModels.get(offerId)){
      EshoppyOutboundRequestWrapper.cls_Model model = new EshoppyOutboundRequestWrapper.cls_Model();
      model.ParentSeriesGroupName=oemodel.ModelParentSeriesGroupName__c;
      model.SeriesGroupName=oemodel.Model_Series_Group_Name__c;
      model.ModelGroupName = oemodel.Model_Group_Name__c;
      model.TrimGroupName=oemodel.Trim__c;
      model.MdlId =oemodel.Model_ID__c;      
      
      //Model Details for Featured Models
      //Added by Rama Iyer 03/30/2023
      if (oemodel.Featured_Offer__c) //Meaning its a featured model
      {
          model.SlsPgmName=oemodel.Offer_Title__c;
          model.ShortDescr=oemodel.Short_Description__c;
          model.ShortDisclaimer=oemodel.Legal_Desclaimer__c;
          model.Descr=oemodel.Detailed_Description__c;
          model.TermAndCondTx=oemodel.Terms_and_Conditions__c;
      }
       //If Lease then get include sample payment flag from Model
      //If finance /programs and featured=true and sample monthly payment is not blank below should be set to true
     // model.HasTerms =oemodel.Include_Sample_Payment__c;
     
     model.HasTerms = OfferOutboundHelper.getIncludeSamplePayment(offerRecord,oemodel);
     system.debug('Include sample payment Value:'+model.HasTerms);
     model.ModelYear =oemodel.Year__c;
     model.ImagePath=oemodel.Default_Image__c;
     model.LargeImagePath =oemodel.Large_Image_Path__c; 
     model.Msrp = oemodel.MSRP__c;
     model.DhCost =oemodel.Dh_Cost__c;
     model.IsFeatured =oemodel.Featured_Offer__c;
     model.ModelPosition =oemodel.Sort_Order__c;
     model.SortOrder=oemodel.Sort_Order__c;     
     model.ImageColor =oemodel.Image_Color__c;
     model.ImageSrcName =oemodel.Image_Source_Name__c;
     model.MsrpAdjustedDh = oemodel.Adjusted_MSRP_with_DH__c;
     /*
     if(oemodel.MSRP__c!=null && oemodel.Dh_Cost__c!=null){
          model.MsrpAdjustedDh=oemodel.MSRP__c+oemodel.Dh_Cost__c;
      }else if(oemodel.MSRP__c!=null){
          model.MsrpAdjustedDh=oemodel.MSRP__c;
      }else if(oemodel.Dh_Cost__c!=null){
          model.MsrpAdjustedDh=oemodel.Dh_Cost__c;       
      } 
      */
      model.CreatedDate =oemodel.CreatedDate;
      model.LastUpdatedDate =oemodel.LastModifiedDate;
      //This block is commented to send these values only if include sample payment is checked
       /*
      model.TermMonths=oemodel.Terms_Months__c;
      model.BaseMonthlyPayment = oemodel.Base_Monthly_Payment__c;
      model.CapitalCostReduction=oemodel.Capitalized_Cost_Reduction__c;
      model.NetCapitalCost=oemodel.Net_Capital_Cost__c;
      model.AnnualMiles=oemodel.Annual_Miles__c;
      model.ResidualValue=oemodel.Residual_Value__c;
      model.TotalMonthlyPayment=oemodel.Total_Monthly_Payment__c;
      model.TotalDueAtSigning=oemodel.Total_Due_At_signing__c;
      model.ResidualRate=oemodel.Residual_Factor__c;//Changed by Rama Iyer on 04/21 after confirming with Dennis and Jas on 04/21
      model.MoneyFactor=oemodel.Money_Factor__c;
      model.DealerContribution =oemodel.Dealer_Contribution__c;
      model.GrossMargin =oemodel.Gross_Margin__c;
      model.BonusCash1 =oemodel.Conquest_Cash__c;
      model.BonusCash2 =oemodel.Loyalty_Cash__c;
      model.BonusCash3 =oemodel.Captive_Cash_Lease_Amount__c;
      model.BonusCash4 =oemodel.Other_Captive_Cash_Lease_Amount__c;
      model.BonusCash5 =oemodel.Additional_Cash__c;
      model.AcquisitionFee=oemodel.Acquisition_Fee__c; 
      */
      //model.Invc=oemodel.Invoice_Price_with_DH__c;
     //Made the change on 04/21 after confirming with Dennis and Satya
      //model.ResidualValpct=oemodel.Residual_Factor__c;  
       //Manohar:Remove below comment to control sample payment fields when include sample payment is true.
      if(oemodel.Include_Sample_Payment__c == true) 
      {
            model.TermMonths=oemodel.Terms_Months__c;
            model.BaseMonthlyPayment = oemodel.Base_Monthly_Payment__c;
            model.CapitalCostReduction=oemodel.Capitalized_Cost_Reduction__c;
            model.NetCapitalCost=oemodel.Net_Capital_Cost__c;
            model.AnnualMiles=oemodel.Annual_Miles__c;
            model.ResidualValue=oemodel.Residual_Value__c;
            model.TotalMonthlyPayment=oemodel.Total_Monthly_Payment__c;
            model.TotalDueAtSigning=oemodel.Total_Due_At_signing__c;
            //model.ResidualRate=oemodel.Residual_Rate__c;   
            model.ResidualRate=oemodel.Residual_Factor__c; //Modified by Rama Iyer on 05/11/2023         
            model.MoneyFactor=oemodel.Money_Factor__c;
            model.DealerContribution =oemodel.Dealer_Contribution__c;
            model.GrossMargin =oemodel.Gross_Margin__c;
            model.BonusCash1 =oemodel.Conquest_Cash__c;
            model.BonusCash2 =oemodel.Loyalty_Cash__c;
            model.BonusCash3 =oemodel.Captive_Cash_Lease_Amount__c;
            model.BonusCash4 =oemodel.Other_Captive_Cash_Lease_Amount__c;
            model.BonusCash5 =oemodel.Additional_Cash__c;
            model.AcquisitionFee=oemodel.Acquisition_Fee__c;
            //Offer Defect OMP-375 added by Rama Iyer 05/16/2023
            //model.TitleIdent=offerRecord.Lease_Title_Ident__c;
      }
      modelList.add(model);
    }
   }
stdSpecial.model = modelList;

List<EshoppyOutboundRequestWrapper.cls_Term> termList= new List<EshoppyOutboundRequestWrapper.cls_Term>();

Map<string,Decimal> TermMapMax = new Map<string,Decimal>();
Map<string,Decimal> TermMapMin = new Map<string,Decimal>();
Map<string,Decimal> APRMap = new Map<string,Decimal>();
if(offerRecord.Term_Max_1__c!=null){
  TermMapMax.put('Term_Max_1__c',offerRecord.Term_Max_1__c);
  TermMapMin.put('Term_Max_1__c',offerRecord.Term_Min_1__c);
  APRMap.put('Term_Max_1__c',offerRecord.APR_1__c);
}
if(offerRecord.Term_Max_2__c!=null){
  TermMapMax.put('Term_Max_2__c',offerRecord.Term_Max_2__c);
  TermMapMin.put('Term_Max_2__c',offerRecord.Term_Min_2__c);
  APRMap.put('Term_Max_2__c',offerRecord.APR_2__c);
}
if(offerRecord.Term_Max_3__c!=null){
  TermMapMax.put('Term_Max_3__c',offerRecord.Term_Max_3__c);
  TermMapMin.put('Term_Max_3__c',offerRecord.Term_Min_3__c);
  APRMap.put('Term_Max_3__c',offerRecord.APR_3__c);
}
if(offerRecord.Term_Max_4__c!=null){
  TermMapMax.put('Term_Max_4__c',offerRecord.Term_Max_4__c);
  TermMapMin.put('Term_Max_4__c',offerRecord.Term_Min_4__c);
  APRMap.put('Term_Max_4__c',offerRecord.APR_4__c);
}
if(offerRecord.Term_Max_5__c!=null){
  TermMapMax.put('Term_Max_5__c',offerRecord.Term_Max_5__c);
  TermMapMin.put('Term_Max_5__c',offerRecord.Term_Min_5__c);
  APRMap.put('Term_Max_5__c',offerRecord.APR_5__c);
}
if(offerRecord.Term_Max_6__c!=null){
  TermMapMax.put('Term_Max_6__c',offerRecord.Term_Max_6__c);
  TermMapMin.put('Term_Max_6__c',offerRecord.Term_Min_6__c);
  APRMap.put('Term_Max_6__c',offerRecord.APR_6__c);
}
for (string key : TermMapMax.keySet()) {
  for (string key1 : TermMapMin.keySet()) {
    for (string key2: APRMap.keySet()) {
      if(key==key1 && key1==key2){
        EshoppyOutboundRequestWrapper.cls_Term term = new EshoppyOutboundRequestWrapper.cls_Term(); 
        term.TermMoQyMin=TermMapMin.get(key1);
        term.TermMoQyMax=TermMapMax.get(key);
        term.IntPt=APRMap.get(key2);
        termList.add(term);
      }
    }
  }
}
stdSpecial.Term=termList;
    string groupCode=offerRecord.Group_Code__c;
    List<string> groupCodeList= new List<string>();
    if(groupCode!=null){
        groupCodeList=groupCode.split(','); 
    }    
    
stdSpecial.ZipGroupCoverage=groupCodeList;
//stdSpecialList.add(stdSpecial);

List<EshoppyOutboundRequestWrapper.cls_Attributes> attrList= new List<EshoppyOutboundRequestWrapper.cls_Attributes>();
EshoppyOutboundRequestWrapper.cls_Attributes  clsAttribute= new EshoppyOutboundRequestWrapper.cls_Attributes();
//Modified by Rama Iyer 03/26/2023 to include Additional attributes for mapping
List<Custom_Offer_Attribute__c> attributeList=[SELECT Id,Alternate_Custom_Offer_Attribute_ID__c,Name,Description__c,Brand__c,Offer_Status_Code_for_Publishing__c,Offer_Attribute_Code__c,Offer_Attribute_Name__c,URL__c,Keywords__c,Image__c,Attribute_Image_Path__c FROM Custom_Offer_Attribute__c];

Map<String,Custom_Offer_Attribute__c> attributemap=new Map<String,Custom_Offer_Attribute__c>();
//Added by Rama Iyer
for (Custom_Offer_Attribute__c custattr:attributeList)
{
  attributemap.put(custattr.Alternate_Custom_Offer_Attribute_ID__c,custattr);
}
if(attributeList.size()>0 && attributeValuesList.size()>0){
        //Below Code Commented by Rama Iyer on 05/03 to fix population of custom offer attribute records
        /*for(Custom_Offer_Attribute__c att: attributeList){
         for(string attVal: attributeValuesList){
          String offerpublishingstatus=offerRecord.Status__c=='Submitted'?'P':'A';
          system.debug('###attVal'+attVal + 'AND:'+att.Offer_Attribute_Code__c + '###Brand:'+ att.Brand__c+':'+ offerRecord.Brand__c+'###Staus:'+att.Offer_Status_Code_for_Publishing__c+':'+offerpublishingstatus);

           if(att.Offer_Attribute_Code__c==attVal && att.Brand__c == offerRecord.Brand__c &&    att.Offer_Status_Code_for_Publishing__c==offerpublishingstatus){
             EshoppyOutboundRequestWrapper.cls_Attributes  clsAttr= new EshoppyOutboundRequestWrapper.cls_Attributes();
             clsAttr.AttributeCd=att.Offer_Attribute_Code__c;
             clsAttr.AttributeDescr=att.Description__c ;
             clsAttr.AttributeImagePath=att.Attribute_Image_Path__c;
             clsAttr.AttributeKeywords=att.Keywords__c;
             clsAttr.AttributeName=att.Offer_Attribute_Name__c;
             clsAttr.AttributeUrl=att.URL__c;
             clsAttr.XprodDivCd=att.Brand__c;// Added by Rama Iyer on 03/28/2023
             clsAttr.EcmsStatusCd = offerpublishingstatus;
             attrList.add(clsAttr);
           }
         }
        }*/
        //Loop through Selected att Val List
        String offerpublishingstatus=offerRecord.Status__c=='Submitted'?'P':'A';
        for (string attVal: attributeValuesList)
        {
            String alternatecoid=attVal+'~'+offerpublishingstatus+'~'+offerRecord.Brand__c;
            EshoppyOutboundRequestWrapper.cls_Attributes  clsAttr= new EshoppyOutboundRequestWrapper.cls_Attributes();
            Custom_Offer_Attribute__c custatt=attributemap.get(alternatecoid);
            if (custatt!=null)
            {
              clsAttr.AttributeCd=custatt.Offer_Attribute_Code__c;
              clsAttr.AttributeDescr=custatt.Description__c ;
              clsAttr.AttributeImagePath=custatt.Attribute_Image_Path__c;
              clsAttr.AttributeKeywords=custatt.Keywords__c;
              clsAttr.AttributeName=custatt.Offer_Attribute_Name__c;
              clsAttr.AttributeUrl=custatt.URL__c;
              clsAttr.XprodDivCd=custatt.Brand__c;// Added by Rama Iyer on 03/28/2023
              clsAttr.EcmsStatusCd = offerpublishingstatus;
              attrList.add(clsAttr);
            }



        }
        system.debug('####attrList'+attrList);
    }
req.StandardSpecial = stdSpecial;//stdSpecialList;
req.Attributes = attrList;
   String jsonString = Json.serialize(req);
   System.debug(jsonString);   
   HttpResponse response = OfferOutboundService.makeCallout(jsonString,offerRecord.Id,offerRecord.status__c,'EshoppyOutboundRequest',OfferMgmtConstants.STANDARDSPECIALS_INTEGRATION);
   
    if(response!=null)  
   {
    OfferOutboundService.updateOffer(offerRecord.Id,offerRecord.Status__c,response);
   }
} 
}
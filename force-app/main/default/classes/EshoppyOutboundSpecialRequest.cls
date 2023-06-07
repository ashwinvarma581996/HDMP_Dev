/**
 * @description       : This is request class for Eshoppy for Special Lease and Special Finance 
 * @author            : Rama Iyer
 * @group             : 
 * @last modified on  : 05-18-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//****************************************************************************** 
// File Name:       EshoppyOutboundSpecialRequest.cls
// Summary:         This is request class for Eshoppy for Special Lease and Special Finance
// Created On:      03-04-2023
// Created By:      Rama Iyer 
// Test Classes:   
// Data I/O:        
// Honda Jira Story: 
//*******************************************************************************
public class EshoppyOutboundSpecialRequest {

   
  public static void sendOutboundSpecialEshoppyReq(ID offerId,string offerStatus){
     system.debug('inside sendOutboundSpecialEshoppyReq');
      /*Offers__c offerRecord =[SELECT National_Offer__c,Security_Deposit_Required__c,Terms_and_Conditions__c,Detailed_Description__c,Legal_Desclaimer__c,Standard_Program_APR_High__c,Sales_Program_CD__c,Standard_Program_APR_Low__c,Additional_Cash__c,Additional_Info_URL__c,Advertised_End_Date_NUM__c,Advertised_End_Date__c,Advertised_Start_Date_NUM__c,Advertised_Start_Date__c,AHFC_Approved__c,AHFC_Internal_Program_Name__c,AHFC_Internal_Sales_Program_Name__c,AHM_Regions__c,AHFC_Sales_Program_ID__c,AHM_Sales_Program_ID__c,Approval_Link__c,APR_1__c,APR_2__c,APR_3__c,APR_4__c,APR_5__c,APR_6__c,Banner_Disclaimer_3__c,Banner_Disclaimer_4__c,Banner_Disclaimer_5__c,Banner_Disclaimer_Competitor_Model__c,Banner_Disclaimer_Prefix__c,Banner_Image_URL__c,Banner_Sales_Program_Type__c,Banner_Short_Description__c,Base_Monthly_Payment__c,Boilerplate__c,Bonus_Bucks_Amount__c,Brand__c,Capital_Cost_Reduction__c,ClonedSourceID__c,Conquest_Cash__c,CreatedDate,Created__c,Create_Date__c,Creator_Name__c,Credit_Tier_Description__c,Credit_Tier__c,Custom_clone__c,Custom_Offer_Attributes__c,Cutline_Text__c,Dealer_Contribution__c,Descriptive_Name__c,Display_Type__c,Double_Bonus_Bucks_Amount__c,End_Date_NUM__c,End_Date__c,File_Name__c,Gross_Margin__c,Group_Code__c,Group_Name__c,Group_Type__c,Id,Invoice_Price_With_DH__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,LifeCycle__c,Lock_Date__c,Lock_Owner__c,Min_Pay__c,Monthly_APR__c,Monthly_Payment_Amount__c,Name,No_Interest_Required_Duration__c,No_Payments_Required_Duration__c,Offer_Amount__c,Offer_Availability__c,Offer_Header__c,Offer_Identifier__c,Offer_Title__c,Offer_Type__c,Original_High_Balance_APR__c,OwnerId,Owner_name__c,Picklist1__c,Picklist_2__c,Preview__c,Priority__c,PRISM_Offer_Status__c,Product_Division_Name__c,Product_Type__c,Program_End_Date__c,Program_Start_Date__c,Promotional_APR__c,Promotion_Duration__c,Promotion_Name__c,RecordTypeId,Record_Type_Name__c,Related_Queue__c,Sales_Program_Type_CD__c,Sales_Program_Type_Name__c,Sample_APR__c,Sample_Model_Description__c,Sample_Monthly_Payment__c,Sample_Termmonths__c,Short_Description__c,Size__c,Special_category__c,Special_Region_Type__c,Special_Region_Type_Name__c,Special_Region__c,Standard_Program_Date__c,Start_Date_NUM__c,Start_Date__c,State_Code__c,State_Name__c,Status__c,Synched_with_PRISM__c,SystemModstamp,Term_Description__c,Term_Max_1__c,Term_Max_2__c,Term_Max_3__c,Term_Max_4__c,Term_Max_5__c,Term_Max_6__c,Term_Min_1__c,Term_Min_2__c,Term_Min_3__c,Term_Min_4__c,Term_Min_5__c,Term_Min_6__c,Title_Name__c,Title__c,Total_Amount_Financed__c,Total_Due_at_Signing__c,Total_Monthly_Payment__c,Transaction_Status__c,User1__c,User2__c,Vehicle_Type_CD__c,Vehicle_Type__c,Version_Number__c,Zero_Due__c,
                     National_Offer__r.Offer_Header__c,(SELECT Acquisition_Fee__c,Adjusted_MSRP_with_DH__c,Annual_Miles__c,Base_Monthly_Payment__c,Brand__c,Capitalized_Cost_Reduction__c,Captive_Cash_Lease_Amount__c,CreatedById,CreatedDate,Dealer_Contribution__c,Default_Image__c,Depreciation_Amount__c,Featured_Offer__c,Featured_Term__c,Sort_Order__c,Gross_Cap_Cost_After_Dealer_Contrib__c,Gross_Cap_Cost_Before_Dealer_Contrib__c,Gross_Margin__c,Include_Sample_Payment__c,Id,Incentive_Cycle_Id__c,Invoice_Amount__c,Invoice_Price_with_DH__c,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Lease_Option_Id__c,Lease_Option_Type__c,Mileage__c,ModelParentSeriesGroupName__c,Model_Code__c,Model_Group_Name__c,Model_ID__c,Model_Marketing_Name__c,Model_Series_Group_Name__c,Model_Series__c,Model__c,Money_Factor__c,MSRP__c,Name,Net_Capital_Cost__c,Offer__c,Other_Captive_Cash_Lease_Amount__c,OwnerId,Program_Code__c,Residual_Factor__c,Residual_Pct__c,Residual_Value__c,Segment__c,Service_Charge_Amount__c,Special_Region__c,SystemModstamp,Terms_Months__c,Title_Ident__c,Total_Due_At_signing__c,Total_Monthly_Payment__c,Trim__c,Residual_Rate__c,Year__c,Large_Image_Path__c,Image_Color__c,Image_Source_Name__c,Dh_Cost__c,Conquest_Cash__c,Loyalty_Cash__c,Additional_Cash__c,Offer_Title__c,Short_Description__c,Legal_Desclaimer__c,Detailed_Description__c,Terms_and_Conditions__c FROM Offer_Eligible_Models__r Order by Sort_Order__c)FROM Offers__c where id =:offerId ];
      */ 
      Offers__c offerRecord = OfferOutboundHelper.getOfferDetailsForSpecial(offerId); 
      map<string,List<Offer_Eligible_Models__c>> mapOfferModels = OfferOutboundHelper.getElgibleModelsByOfferForSpecial(offerId);
     
       Offer_Eligible_Models__c objFeaturedLowOrderModelRecord = OfferOutboundHelper.getLowestFeaturedModel(mapOfferModels.get(offerId));
      
       EshoppyOutboundSpecialRequestWrapper req = new EshoppyOutboundSpecialRequestWrapper();
      EshoppyOutboundSpecialRequestWrapper.cls_Special special= new EshoppyOutboundSpecialRequestWrapper.cls_Special();
      special.SpecialId=offerRecord.Offer_Header__c;//Added by Rama. It should always Offer Header Record Id
      //special.Action= offerStatus == 'Expired'?'Delete':'Upsert';  
      special.TitleIdent=offerRecord.Lease_Title_Ident__c!=null?Integer.valueof(offerRecord.Lease_Title_Ident__c):null;//Added by Rama Iyer OMP-375
      special.OfferIdentifier=offerRecord.Offer_Header__c;
      special.AddlInfoUrl=offerRecord.Additional_Info_URL__c;
      special.BannerDiscCompetModel=offerRecord.Banner_Disclaimer_Competitor_Model__c;
      special.BannerDiscPrefix=offerRecord.Banner_Disclaimer_Prefix__c;
      special.BannerDisclaimer3=offerRecord.Banner_Disclaimer_3__c;
      special.BannerDisclaimer4=offerRecord.Banner_Disclaimer_4__c;
      special.BannerDisclaimer5=offerRecord.Banner_Disclaimer_5__c;
      special.BannerImageUrl=offerRecord.Banner_Image_URL__c;
      special.BannerShortDescription=offerRecord.Banner_Short_Description__c;
      special.BannerSlsPgmType=offerRecord.Banner_Sales_Program_Type__c;
      special.CreatedDate=offerRecord.Create_Date__c;
      special.CutlineTxt=offerRecord.Cutline_Text__c;      
     if(objFeaturedLowOrderModelRecord !=null){
      special.Descr= objFeaturedLowOrderModelRecord.Detailed_Description__c;        
      special.SlsPgmName=objFeaturedLowOrderModelRecord.Offer_Title__c;
      special.TermAndCondTx = objFeaturedLowOrderModelRecord.Terms_and_Conditions__c;
     }
      special.EcmsStatusCd=offerStatus == 'Submitted'?'P':'A';   
        if(offerRecord.Advertised_Start_Date__c!=null){ 
          special.EffDate=offerRecord.Advertised_Start_Date__c;
        }else{
          special.EffDate=offerRecord.Start_Date__c;
        }
      //05/16/2023 - OMP-301 - Should Follow Same Logic as Start Date
      //special.EndDate=offerRecord.End_Date__c;
      if(offerRecord.Advertised_End_Date__c!=null){ 
        special.EndDate=offerRecord.Advertised_End_Date__c;
      }else{
        special.EndDate=offerRecord.End_Date__c;
      }
      special.HasSecurityDeposit=offerRecord.Security_Deposit_Required__c;
      if(offerRecord.Priority__c != null){
      special.HfSelectSort=Integer.valueOf(offerRecord.Priority__c);
      }
      special.LastUpdatedDate=String.ValueOf(offerRecord.LastModifiedDate);
      special.SampleApr=offerRecord.Sample_APR__c;
      if(offerRecord.Sample_Monthly_Payment__c != null){
      special.SampleMonthlyPayment=decimal.valueof(offerRecord.Sample_Monthly_Payment__c); 
      }
      //special.AWebcUrl='Acura/offers/C/R/U2Z2I.xml'; Not needed Dennis will default
      special.SampleTerm=offerRecord.Sample_Termmonths__c;
      //special.SlsPgmName=offerRecord.Offer_Title__c;
      special.SpecialRegion=offerRecord.Offer_Availability__c;
      special.SpecialTyp=offerRecord.Vehicle_Type_CD__c;
      //special.TermAndCondTx=offerRecord.Terms_and_Conditions__c;
      special.ZeroDue=offerRecord.Zero_Due__c;
      
      special.SalesPrgmCd=offerRecord.Sales_Program_CD__c!=null?offerRecord.Sales_Program_CD__c:0;
      special.HasRegions=offerRecord.Id;
      special.SpecialRegionType=offerRecord.Special_Region_Type__c;
      if(offerRecord.National_Offer__c!=null){
          special.IsSplit=true;  
      }else{
    special.IsSplit=false;             
      }
      special.SplitFromId=offerRecord.National_Offer__r.Offer_Header__c; //Changed this to Original Offers header
      special.DivisionCd=offerRecord.Brand__c;
      special.VehicleTypeCd=offerRecord.Vehicle_Type_CD__c;
    //  04/11/2023 - Commented by Rama Iyer, As per Dennis and Jas this is not applicable to Specials
    //  special.SpecialCategory = OfferOutboundHelper.getSpecialCategory(offerRecord.Brand__c,offerRecord.recordTypeId);

   string attributeValues=offerRecord.Custom_Offer_Attributes__c;
     List<string> attributeValuesList=new List<string>();
     if(attributeValues!=null){
          attributeValuesList=attributeValues.split(';');
          for(integer i=0;i<attributeValuesList.size();i++){
           if(attributeValuesList[i].right(2)=='_A' || attributeValuesList[i].right(2)=='_B'){
           attributeValuesList[i]=attributeValuesList[i].Substring(0,attributeValuesList[i].length()-2);
           }
          }
     }
     special.SpecialsAttribute=attributeValuesList; 
      
     List<EshoppyOutboundSpecialRequestWrapper.cls_SpecialModel> modelList = new List<EshoppyOutboundSpecialRequestWrapper.cls_SpecialModel>();
      if(mapOfferModels.get(offerId) !=null && mapOfferModels.get(offerId).size()>0) {
          for(Offer_Eligible_Models__c oemodel : mapOfferModels.get(offerId)){
              EshoppyOutboundSpecialRequestWrapper.cls_SpecialModel specialModel= new EshoppyOutboundSpecialRequestWrapper.cls_SpecialModel();
              specialModel.ParentSeriesGroupName=oemodel.ModelParentSeriesGroupName__c;
              specialModel.SeriesGroupName=oemodel.Model_Series_Group_Name__c;
              specialModel.ModelGroupName=oemodel.Model_Group_Name__c;
              specialModel.TrimGroupName=oemodel.Trim__c;
              specialModel.MdlId=oemodel.Model_ID__c;                
              specialModel.SlsPgmName = oemodel.Offer_Title__c;
              specialModel.ShortDescr=oemodel.Short_Description__c;
              specialModel.ShortDisclaimer=oemodel.Legal_Desclaimer__c;
              specialModel.Descr = oemodel.Detailed_Description__c;
              specialModel.TermAndCondTx=oemodel.Terms_and_Conditions__c; 
              specialModel.SortOrder=oemodel.Sort_Order__c;
              //specialModel.TitleIdent=offerRecord.Lease_Title_Ident__c; // Added as Part of Defect by Rama Iyer 05/15/2023
      
                  //Model Details for Featured Models
                  //Added by Rama Iyer 03/30/2023
                  if (oemodel.Featured_Offer__c) //Meaning its a featured model
                  {
                    specialModel.SlsPgmName=oemodel.Offer_Title__c;
                    specialModel.ShortDescr=oemodel.Short_Description__c;
                    specialModel.ShortDisclaimer=oemodel.Legal_Desclaimer__c;
                    specialModel.Descr=oemodel.Detailed_Description__c;
                    specialModel.TermAndCondTx=oemodel.Terms_and_Conditions__c;
                  }
                  specialModel.ResidualRate=oemodel.Residual_Factor__c;//Confirmed with Jas and Dennis on 04/21/2023 Made by Rama Iyer
                  specialModel.ModelYear=oemodel.Year__c;
                  specialModel.ImagePath=oemodel.Default_Image__c;
                  specialModel.LargeImagePath=oemodel.Large_Image_Path__c; 
                  specialModel.IsFeatured=oemodel.Featured_Offer__c;
                  specialModel.ModelPosition=oemodel.Sort_Order__c;
                  //If Lease then get include sample payment flag from Model
                  //If finance /programs and featured=true and sample monthly payment is not blank below should be set to true
                  //specialModel.HasTerms=oemodel.Include_Sample_Payment__c;
                  specialModel.HasTerms =OfferOutboundHelper.getIncludeSamplePayment(offerRecord,oemodel);
                  system.debug('### Has Terms:'+specialModel.HasTerms);
                  specialModel.Msrp=oemodel.MSRP__c;
                  specialModel.MsrpAdjustedDh = oemodel.Adjusted_MSRP_with_DH__c;
                  /*
                      if(oemodel.MSRP__c!=null && oemodel.Dh_Cost__c!=null){
                          specialModel.MsrpAdjustedDh=oemodel.MSRP__c+oemodel.Dh_Cost__c;
                      }else if(oemodel.MSRP__c!=null){
                          specialModel.MsrpAdjustedDh=oemodel.MSRP__c;
                          }else if(oemodel.MSRP__c!=null){
                              specialModel.MsrpAdjustedDh=oemodel.Dh_Cost__c;       
                      }
                      */
                  specialModel.ImageColor=oemodel.Image_Color__c;
                  specialModel.ImageSrcName=oemodel.Image_Source_Name__c;
              	  /*specialModel.TermMonths=oemodel.Terms_Months__c;
                  specialModel.GrossMargin =oemodel.Gross_Margin__c;
                  specialModel.DealerContribution=oemodel.Dealer_Contribution__c;
                  specialModel.NetCapitalCost=oemodel.Net_Capital_Cost__c;
                  specialModel.CapitalCostReduction=oemodel.Capitalized_Cost_Reduction__c;                  
                  specialModel.AnnualMiles=oemodel.Annual_Miles__c;
                  specialModel.MoneyFactor=oemodel.Money_Factor__c;
                  specialModel.BonusCash1 =oemodel.Conquest_Cash__c;
                  specialModel.BonusCash2 =oemodel.Loyalty_Cash__c;
                  specialModel.BonusCash3 =oemodel.Captive_Cash_Lease_Amount__c;
                  specialModel.BonusCash4 =oemodel.Other_Captive_Cash_Lease_Amount__c;
                  specialModel.BonusCash5 =oemodel.Additional_Cash__c;        
                  specialModel.BaseMonthlyPayment=oemodel.Base_Monthly_Payment__c;   
                  specialModel.TotalDueAtSigning=oemodel.Total_Due_At_signing__c;    
                  specialModel.ResidualValue=oemodel.Residual_Value__c;
                  specialModel.TotalMonthlyPayment=oemodel.Total_Monthly_Payment__c; 
                //specialModel.Invc=oemodel.Invoice_Price_with_DH__c;
                  specialModel.AcquisitionFee=oemodel.Acquisition_Fee__c; //Confirmed with Dennis and Satya on 04/21/ and made the change
                //specialModel.ResidualValpct=oemodel.Residual_Factor__c; 
                */
                  //Manohar:Remove below comment to control sample payment fields when include sample payment is true. 
                  
                  if(oemodel.Include_Sample_Payment__c == true)
                  {
                      specialModel.TermMonths=oemodel.Terms_Months__c;
                      specialModel.BaseMonthlyPayment=oemodel.Base_Monthly_Payment__c; 
                      specialModel.CapitalCostReduction=oemodel.Capitalized_Cost_Reduction__c;  
                      specialModel.NetCapitalCost=oemodel.Net_Capital_Cost__c;  
                      specialModel.AnnualMiles=oemodel.Annual_Miles__c;    
                      specialModel.ResidualValue=oemodel.Residual_Value__c;
                      specialmodel.ResidualRate=oemodel.Residual_Factor__c;//Added by Rama Iyer on 05/11
                      specialModel.TotalMonthlyPayment=oemodel.Total_Monthly_Payment__c;
                      specialModel.TotalDueAtSigning=oemodel.Total_Due_At_signing__c;
                      specialModel.MoneyFactor=oemodel.Money_Factor__c;
                      specialModel.DealerContribution=oemodel.Dealer_Contribution__c;
                      specialModel.GrossMargin =oemodel.Gross_Margin__c;
                      specialModel.BonusCash1 =oemodel.Conquest_Cash__c;
                      specialModel.BonusCash2 =oemodel.Loyalty_Cash__c;
                      specialModel.BonusCash3 =oemodel.Captive_Cash_Lease_Amount__c;
                      specialModel.BonusCash4 =oemodel.Other_Captive_Cash_Lease_Amount__c;
                      specialModel.BonusCash5 =oemodel.Additional_Cash__c;               		   
                  }
          modelList.add(specialModel);   
          }
      }
      special.SpecialsModel=modelList;
      
      string groupCode=offerRecord.Group_Code__c;
      List<string> groupCodeList= new List<string>();
      if(groupCode!=null){
         groupCodeList=groupCode.split(',');  
      }    
      special.ZipGroupCoverage=groupCodeList; 
      
      List<EshoppyOutboundSpecialRequestWrapper.cls_Attributes> attrList= new List<EshoppyOutboundSpecialRequestWrapper.cls_Attributes>();
      EshoppyOutboundSpecialRequestWrapper.cls_Attributes  clsAttribute= new EshoppyOutboundSpecialRequestWrapper.cls_Attributes();
      //Modified Below by Rama Iyer 03/26/2023 to include additional checks
      List<Custom_Offer_Attribute__c> attributeList=[SELECT Id,Alternate_Custom_Offer_Attribute_ID__c,Name,Description__c,Brand__c,Offer_Status_Code_for_Publishing__c,Offer_Attribute_Code__c,Offer_Attribute_Name__c,URL__c,Keywords__c,Image__c,Attribute_Image_Path__c FROM Custom_Offer_Attribute__c];
      
      Map<String,Custom_Offer_Attribute__c> attributemap=new Map<String,Custom_Offer_Attribute__c>();
      //Added by Rama Iyer
      for (Custom_Offer_Attribute__c custattr:attributeList)
      {
        attributemap.put(custattr.Alternate_Custom_Offer_Attribute_ID__c,custattr);
      }
      
      
      
      if(attributeList.size()>0 && attributeValuesList.size()>0){
      /*for(Custom_Offer_Attribute__c att: attributeList){
       for(string attVal: attributeValuesList){
         String offerpublishingstatus=offerRecord.Status__c=='Submitted'?'P':'A';
         
         if(att.Offer_Attribute_Code__c==attVal && att.Brand__c == offerRecord.Brand__c &&  att.Offer_Status_Code_for_Publishing__c==offerpublishingstatus){
           EshoppyOutboundSpecialRequestWrapper.cls_Attributes  clsAttr= new EshoppyOutboundSpecialRequestWrapper.cls_Attributes();
           clsAttr.AttributeCd=att.Offer_Attribute_Code__c;
           clsAttr.AttributeDescr=att.Description__c ;// In the object data this value should not be null
           clsAttr.AttributeImagePath=att.Attribute_Image_Path__c;
           clsAttr.AttributeKeywords=att.Keywords__c;
           clsAttr.AttributeName=att.Offer_Attribute_Name__c;
           clsAttr.AttributeUrl=att.URL__c;       
           clsAttr.XprodDivCd=att.Brand__c;//Added by Rama Iyer : This is a required value
           clsAttr.EcmsStatusCd = offerpublishingstatus;
           attrList.add(clsAttr);
         } 
       }
      }*/
      String offerpublishingstatus=offerRecord.Status__c=='Submitted'?'P':'A';
      for (string attVal: attributeValuesList)
      {
          String alternatecoid=attVal+'~'+offerpublishingstatus+'~'+offerRecord.Brand__c;
          EshoppyOutboundSpecialRequestWrapper.cls_Attributes  clsAttr= new EshoppyOutboundSpecialRequestWrapper.cls_Attributes();
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
  }  
      req.Specials=special;
      req.Attribute = attrList; 
      
     String jsonString = Json.serialize(req);
     
    HttpResponse response = OfferOutboundService.makeCallout(jsonString,offerRecord.Id,offerRecord.status__c,'EshoppyOutboundSpecialRequest',OfferMgmtConstants.SPECIALS_INTEGRATION);
    if(response!=null) 
    {
      OfferOutboundService.updateOffer(offerRecord.Id,offerRecord.Status__c,response); 
    }
  }
}
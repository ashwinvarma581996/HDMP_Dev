/**
 * @name              : OfferFeedInbNewOffer2.cls 
 * @Description        : Used for Inserting new offers that dont match b2c_offer_Id from STG Offer table
 * @author            : Rama Iyer
 * @group             : Honda Offer Management
 * @last modified on  : 05-03-2023
 * @last modified by  : Rama Iyer
 * @Test Classes      : OfferManagmentInboundProcessing_Test.cls
**/



public class OfferFeedInbNewOffer2 {

    public static void processNewInboundOffers(List<STG_Offers__c> nonmatchedoffers,Map<Id,List<STG_Offer_Eligible_Models__c>> nonmatchedmodels){


        List<Offer_Header__c> newoffheaderList=new List<Offer_Header__c> ();
        List<Offers__c> newofferverList=new List<Offers__c> ();
        List<Offer_Eligible_Models__c> newofferModelsList=new List<Offer_Eligible_Models__c> ();
        Map<String,STG_Offers__c> stgoffmap=new Map<String,STG_Offers__c>();

        Schema.FieldSet STGoffeheadFieldNew =  Schema.SObjectType.STG_Offers__c.FieldSets.OfferHeaderFieldsMapped;
        Schema.FieldSet STGofferfieldsnewver = Schema.SObjectType.STG_Offers__c.FieldSets.OfferVersionFields;
        Schema.FieldSet STGoffeligmodelflds =  Schema.SObjectType.STG_Offer_Eligible_Models__c.FieldSets.ModelFieldsforOfferVersion;

        Map<String,Id> offerRecordtypes=GetOfferRecordTypesUtility.getofferRectypeIds();  
        Map<String,Id> offerheadrectypes=GetOfferRecordTypesUtility.getofferHeadRectypeIds();
        Map<String,Id> offEligRecordtypes=GetOfferRecordTypesUtility.getofferEligModRectypeIds();

        Map<String,String> brndnames=getBrandLabelsandValues();
        Map<String,String> getOffernames=getOfferName(nonmatchedoffers);

        List<STG_Offer_Eligible_Models__c> stgmodelsfordetails=new List<STG_Offer_Eligible_Models__c>();
        List<String> modelids=new List<String>();
        Set<String> modelidset=new Set<String>();
        for (Id stgofferIds: nonmatchedmodels.keySet())
        {
            for(STG_Offer_Eligible_Models__c models:nonmatchedmodels.get(stgofferIds))
            {
                modelids.add(models.Model_Id__c);
            }

        }
        modelidset.addAll(modelids);
        Map<String,Product_Model__c> prodModelDetails=GetOMModelDetailsUtility.getModelDetailsbyModelId(modelidset);


        //Start Collecting Records
        for (STG_Offers__c stgoffers:nonmatchedoffers)
        {

            //Start with Header

            stgoffmap.put(stgoffers.b2c_Offer_Id__c,stgoffers);
            Offer_Header__c newofferheadrec=new Offer_Header__c();
            Offers__c newofferversionrec=new Offers__c();

            newofferheadrec.Offer_Identifier__c=stgoffers.b2c_Offer_Id__c;
            newofferheadrec.RecordTypeId=offerheadrectypes.get(stgoffers.Offer_Record_Type__c);
            newofferheadrec.name= getOffernames.get(stgoffers.b2c_Offer_Id__c);
            //Powersports , CPO Standard Finance and New Standard Finance & CPO Standard Lease files will not come in through Inbound feed else we need the logic for the same             
            for (Schema.FieldSetMember stgOffHeadField : STGoffeheadFieldNew.getFields() )
            {
                newofferheadrec.put(stgOffHeadField.getFieldPath(),stgoffers.get(stgOffHeadField.getFieldPath()));
            }
            newofferheadrec.Descriptive__c=stgoffers.AHFC_Internal_Sales_Program_Name__c;
            newoffheaderList.add(newofferheadrec);

            //Now Lets Get Offer Versions
            Offer_Header__c offheaderref=new Offer_Header__c(Offer_Identifier__c=stgoffers.b2c_Offer_Id__c);
            newofferversionrec.Offer_Header__r=offheaderref;
            newofferversionrec.name=getOffernames.get(stgoffers.b2c_Offer_Id__c);
            newofferversionrec.Alternate_Offer_Identifier__c=stgoffers.b2c_Offer_Id__c+'~1';
            newofferversionrec.RecordTypeId=offerRecordtypes.get(stgoffers.Offer_Record_Type__c);
            newofferversionrec.Descriptive_Name__c=stgoffers.AHFC_Internal_Program_Name__c;
            newofferversionrec.Version_Number__c=1;
            newofferversionrec.Synched_with_PRISM__c=true;
            newofferversionrec.Status__c='WIP';
            newofferversionrec.Latest_Version__c=true;

            if (stgoffers.Offer_Record_Type__c.contains('CPO'))
                newofferversionrec.Product_Type__c=stgoffers.Vehicle_Type_CD__c=='U'?'Used':'Certfied';

            for (Schema.FieldSetMember stgnewOffField : STGofferfieldsnewver.getFields() )
            {
                if (stgoffers.get(stgnewOffField.getFieldPath())!=null) newofferversionrec.put(stgnewOffField.getFieldPath(),stgoffers.get(stgnewOffField.getFieldPath()));
            } 
            if (stgoffers.Offer_Availability__c=='R'){
                newofferversionrec.Offer_Availability__c='Regional';
            }
            else
            {
                newofferversionrec.Offer_Availability__c='National';
            }
            newofferversionrec.Offer_Type__c=stgoffers.Offer_Type_CD__c;
            
            if (stgoffers.Vehicle_Type_CD__c=='U')
            {
                newofferversionrec.Product_Type__c='Used';
            }
            else if (stgoffers.Vehicle_Type_CD__c=='C')
            {
                newofferversionrec.Product_Type__c='Certified';
            }
            newofferverList.add(newofferversionrec);
            List<STG_Offer_Eligible_Models__c> stgoffeligmods=nonmatchedmodels.get(stgoffers.Id);
            List<Offer_Eligible_Models__c> newEligibleModel=new List<Offer_Eligible_Models__c>();
            for(STG_Offer_Eligible_Models__c offermodel:stgoffeligmods )
            {
                Offer_Eligible_Models__c newOfferEligModelRec=new Offer_Eligible_Models__c();
                newOfferEligModelRec.RecordTypeId=offEligRecordtypes.get(stgoffers.Offer_Record_Type__c);
                Offers__c offerref=new Offers__c(Alternate_Offer_Identifier__c=offermodel.b2c_offer_Id__c+'~1');
                newOfferEligModelRec.Offer__r=offerref;
                newOfferEligModelRec.Brand__c=stgoffers.Brand__c;
                //newOfferEligModelRec.Alternate_Offer_Eligible_Model_Id__c=offermodel.b2c_offer_Id__c+'~1'+'~'+offermodel.Model_Id__c;

                for (Schema.FieldSetMember stgoffeligmodelfld : STGoffeligmodelflds.getFields() )
                {
                   //system.debug('Fields Being Loaded:'+stgoffeligmodelfld.getFieldPath());
                   if (offermodel.get(stgoffeligmodelfld.getFieldPath())!=null && stgoffeligmodelfld.getFieldPath()!='IsDeleted') newOfferEligModelRec.put(stgoffeligmodelfld.getFieldPath(),offermodel.get(stgoffeligmodelfld.getFieldPath()));
                } 
                 if (prodModelDetails.get(offermodel.Model_ID__c)!=null)
                 {
                     newOfferEligModelRec.Name=prodModelDetails.get(offermodel.Model_ID__c).Model_Name__c;
                     newOfferEligModelRec.Model__c=prodModelDetails.get(offermodel.Model_ID__c).Model_Name__c;
                     newOfferEligModelRec.Trim__c=prodModelDetails.get(offermodel.Model_ID__c).Trim__c;
                      
                 }
                 else
                 {

                    newOfferEligModelRec.Name=offermodel.Model_Group_Name__c;
                    newOfferEligModelRec.Model__c=offermodel.Model_Group_Name__c;
                    newOfferEligModelRec.Trim__c=offermodel.Model_Marketing_Name__c;
                 }
                 newofferModelsList.add(newOfferEligModelRec);                

            }



            //now we build offer version list



        }
        if (newofferModelsList!=null && newofferModelsList.size() > 0 && newoffheaderList!=null && newoffheaderList.size() > 0 && newofferverList.size() > 0 && newofferverList!=null)
        {

            List<SObject> newofferList=new List<SObject>();
            newofferList.addAll(newoffheaderList);
            newofferList.addAll(newofferverList);
            newofferList.addAll(newofferModelsList);
            Savepoint sp = Database.setSavepoint();
            try {
                insert newofferList;
                UpdateSTGOfferProcessingStatus.setstatusonstgrecords(newofferList,'Success','New Offer Creation Success',stgoffmap);
            }
            catch(DMLException e)
            {
                //on error rolleback
                Database.rollback( sp );
                UpdateSTGOfferProcessingStatus.setstatusonstgrecords(newofferList,'Failures',e.getMessage(),stgoffmap);


            }
        }

    }

    public static Map<String,String> getBrandLabelsandValues(){
        Map<String,String> brandValues= new Map<String,String>();
          Schema.DescribeFieldResult fieldResult = Offer_Header__c.Brand__c.getDescribe();
          List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          for( Schema.PicklistEntry pickListVal : ple){
              brandValues.put(pickListVal.getValue(),pickListVal.getLabel());
          }     
          return brandValues;
      }
  
      public static Map<String,String> getOfferName(List<STG_Offers__c> stgoffers)
      {
          Map<String,String> offernames=new Map<String,String> ();
          Map<String,String> brandlabels=OfferFeedInbNewOffers.getBrandLabelsandValues();
          for(STG_Offers__c stgoffer:stgoffers)
          {
              String offernm;
              switch on stgoffer.Offer_Record_Type__c {
      
                  when 'CPO_Special_Finance','New_Special_Finance' {
                      if (stgoffer.AHM_Sales_Program_ID__c!=null && stgoffer.AHFC_Sales_Program_ID__c!=null)
                      {
                          offernm=stgoffer.AHFC_Sales_Program_ID__c+'_'+stgoffer.AHM_Sales_Program_ID__c+'_'+string.valueof(integer.valueof(stgoffer.Sales_Program_CD__c));
                      }
                      else // Assuming AHM Sales Program is blank
                      {
                          offernm=stgoffer.AHFC_Sales_Program_ID__c+'_'+string.valueof(integer.valueof(stgoffer.Sales_Program_CD__c));
                      }
      
                  }
                  when 'CPO_Special_Lease','New_Special_Lease' {
                      if (stgoffer.AHM_Sales_Program_ID__c!=null && stgoffer.AHFC_Sales_Program_ID__c!=null && stgoffer.Title_Name__c!=null)
                      {
                          offernm=stgoffer.AHFC_Sales_Program_ID__c+'_'+stgoffer.AHM_Sales_Program_ID__c+'_'+stgoffer.Title_Name__c;
                      }
                      else if (stgoffer.AHM_Sales_Program_ID__c!=null && stgoffer.AHFC_Sales_Program_ID__c!=null)//Assuming title is null Sales Program is Blank
                      {   //Modified Below on 04/27/2023 based on Feedback from Shagun S
                          offernm=stgoffer.AHFC_Sales_Program_ID__c+'_'+stgoffer.AHM_Sales_Program_ID__c+String.valueof(Integer.valueof(stgoffer.Sales_Program_CD__c));
                      }
                    
                  }
                  when 'New_Standard_Lease' {
                      if (stgoffer.Title_Name__c!=null)
                      {
                          offernm=stgoffer.Title_Name__c;
                      }
              }
              when 'CPO_Special_Program','New_Special_Program' {
                  if (stgoffer.Promotion_Name__c!=null)
                  {
                      offernm=stgoffer.Promotion_Name__c;
                  }
               }
              when else {
                  offernm=brandlabels.get(stgoffer.Brand__c)+'_'+stgoffer.b2c_Offer_Id__c;
                  }
              }
              if (offernm==null) offernm=brandlabels.get(stgoffer.Brand__c)+'_'+stgoffer.b2c_Offer_Id__c;
              offernames.put(stgoffer.b2c_Offer_Id__c,offernm);
  
          }
  
          return offernames;
      }

}
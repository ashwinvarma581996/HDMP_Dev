//****************************************************************************** 
// File Name:       OfferFeedInbNewOffers.cls
// Summary:         Apex Class for to Retrieve inbound Offer Feed Records and Process for new records and new models
// Created On:      02-22-2023
// Created By:      Rama Iyer
// Test Classes:    OfferManagmentInboundProcessing_Test.cls
// JIRA Story :     OMP-156,OMP-76,OMP-104,OMP-103
//===============================================================================

public class OfferFeedInbNewOffers {
    
    @InvocableMethod(label='Inbound Offer Processing Logic - New Offers')
    public static List<STG_Offers__c> processNewInboundOffers(List<FlowInput> inputs){
         //Insert Header and Corressponding Versions
         FlowInput feedprocinputs=inputs.get(0);
         Map<String,String> brandvaluesPicklist=getBrandLabelsandValues();
         Schema.FieldSet STGoffeheadFieldNew =  Schema.SObjectType.STG_Offers__c.FieldSets.OfferHeaderFieldsMapped;
         Schema.FieldSet STGofferfieldsnewver = Schema.SObjectType.STG_Offers__c.FieldSets.OfferVersionFields;
         Map<String,Id> offerRecordtypes=GetOfferRecordTypesUtility.getofferRectypeIds();  
         Map<String,Id> offerheadrectypes=GetOfferRecordTypesUtility.getofferHeadRectypeIds();
         Map<String,String> brndnames=getBrandLabelsandValues();
         Map<String,Offer_Header__c> offheadmap=new Map<String,Offer_Header__c>();
         Map<String,Offers__c> offvermap=new Map<String,Offers__c>();
         List<Offer_Header__c> newoffHeadlst=new List<Offer_Header__c>();
         List<Offers__c> newoffVerLst=new List<Offers__c>();
         Map<String,STG_Offers__c> stgoffmap=new Map<String,STG_Offers__c>();
         Map<Id,String> offheadreversemap=new Map<Id,String>();
         List<STG_Offers__c> returnstgofferlist=new List<STG_Offers__c>();
         Map<String,String> recordIdMap=new Map<String,String>();
         Map<String,List<STG_Offer_Eligible_Models__c>> stgoffleigmodmap=new Map<String,List<STG_Offer_Eligible_Models__c>>();
        
         Map<String,String> getOffernames=getOfferName(feedprocinputs.offertoProcess);
        
         for(STG_Offers__c stgoffers:feedprocinputs.offertoProcess)
         {
             Offer_Header__c newofferheadrec=new Offer_Header__c();
             newofferheadrec.Offer_Identifier__c=stgoffers.b2c_offer_Id__c;
             newofferheadrec.RecordTypeId=offerheadrectypes.get(stgoffers.Offer_Record_Type__c);
             stgoffmap.put(stgoffers.B2C_Offer_Id__c,stgoffers);
             recordIdMap.put(stgoffers.B2C_Offer_Id__c,stgoffers.B2C_Offer_Id__c);
             /*if (stgoffers.AHFC_Sales_Program_ID__c!=null && stgoffers.AHM_Sales_Program_ID__c!=null && stgoffers.Sales_Program_CD__c!=null)
             {
                 newofferheadrec.name=brndnames.get(stgoffers.Brand__c)+'_'+string.valueOf(stgoffers.Sales_Program_CD__c)+'_'+stgoffers.AHFC_Sales_Program_ID__c+'_'+stgoffers.AHM_Sales_Program_ID__c;
             }
             else if (stgoffers.AHFC_Sales_Program_ID__c!=null  && stgoffers.AHM_Sales_Program_ID__c!=null )
             {
                 newofferheadrec.name=brndnames.get(stgoffers.Brand__c)+'_'+stgoffers.AHFC_Sales_Program_ID__c+'_'+stgoffers.AHM_Sales_Program_ID__c;
             }
             else if (stgoffers.AHFC_Sales_Program_ID__c!=null )
             {
                 newofferheadrec.name=brndnames.get(stgoffers.Brand__c)+'_'+stgoffers.AHFC_Sales_Program_ID__c;
             }
             else if (stgoffers.Lease_Title_Ident__c!=null)
             {
                 newofferheadrec.name=brndnames.get(stgoffers.Brand__c)+'_'+stgoffers.Lease_Title_Ident__c;
             }*/
             
             //As per Offer Spec
             newofferheadrec.name= getOffernames.get(stgoffers.b2c_Offer_Id__c);
            //Powersports , CPO Standard Finance and New Standard Finance & CPO Standard Lease files will not come in through Inbound feed else we need the logic for the same             
            for (Schema.FieldSetMember stgOffHeadField : STGoffeheadFieldNew.getFields() )
            {
                newofferheadrec.put(stgOffHeadField.getFieldPath(),stgoffers.get(stgOffHeadField.getFieldPath()));
            }
            newofferheadrec.Descriptive__c=stgoffers.AHFC_Internal_Sales_Program_Name__c;
            newoffHeadlst.add(newofferheadrec);
            
             
         }
        //Insert Header
        try{
            //insert newoffHeadlst;
            Database.SaveResult[] offheadsavelst = Database.insert(newoffHeadlst, false);
            
           // returnstgofferlist=UpdateSTGOfferProcessingStatus.collectStgRecordstoUpdate(stgoffmap,recordIdMap,'Offer_Header__c',newoffHeadlst,offheadsavelst,null);
            for(Offer_Header__c offheadrec:newoffHeadlst){
                offheadmap.put(offheadrec.Offer_Identifier__c,offheadrec);
                offheadreversemap.put(offheadrec.Id,offheadrec.Offer_Identifier__c);
            }
        } 
        catch(Dmlexception e){
            system.debug('Error Inserting Header'+e.getMessage());
             B2B_Util.createErrorRecord('Error in Processing Offer Inbound Feed',e.getMessage(),72,'OfferManagmentInboundProcessing','processInboundFeedNewOffers');
        }
        //Process Offerversion
        //for(STG_Offers__c stgoffers:feedprocinputs.offertoProcess)
        for (STG_Offers__c stgoffers:returnstgofferlist)
        {
            Offers__c newofferversionrec=new Offers__c();
            system.debug('Offer Header Found='+offheadmap.get(stgoffers.b2c_offer_Id__c));
            //if (offheadmap.get(stgoffers.b2c_offer_Id__c)!=null){
            if(stgoffers.Processing_Status__c=='Success'){
                
                newofferversionrec.offer_header__c=offheadmap.get(stgoffers.b2c_offer_Id__c).Id;
                newofferversionrec.name=offheadmap.get(stgoffers.b2c_offer_Id__c).Name;
                newofferversionrec.RecordTypeId=offerRecordtypes.get(stgoffers.Offer_Record_Type__c);
                newofferversionrec.Descriptive_Name__c=stgoffers.AHFC_Internal_Program_Name__c;
                newofferversionrec.Version_Number__c=1;
                newofferversionrec.Synched_with_PRISM__c=true;
                newofferversionrec.Status__c='WIP';
                newofferversionrec.Latest_Version__c=true;
                
                //Commented by Rama Iyer on 04/21/2023 based on Review of Offer Spec that the below dates will not prepopulate
                
                /*if (stgoffers.Offer_Record_Type__c.contains('Special_Lease') ||stgoffers.Offer_Record_Type__c.contains('Special_Finance'))
                {
                    newofferversionrec.Advertised_Start_Date__c=stgoffers.Start_Date__c!=null?stgoffers.Start_Date__c:null;
                    newofferversionrec.Advertised_End_Date__c=stgoffers.End_Date__c!=null?stgoffers.End_Date__c:null;
                }*/
                // Mapping Product State based on Vehicle type Code : Added by Rama Iyer 04/13/2023
                if (stgoffers.Offer_Record_Type__c.contains('CPO'))
                    newofferversionrec.Product_Type__c=stgoffers.Vehicle_Type_CD__c=='U'?'Used':'Certfied';

                
                newofferversionrec.Alternate_Offer_Identifier__c=offheadmap.get(stgoffers.b2c_offer_Id__c).Id+'~'+newofferversionrec.Version_Number__c;
                
       
                
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
                
                newoffVerLst.add(newofferversionrec);
            }
            
        }
        
        try{
            insert newoffVerLst;
            system.debug('Offer Ver List='+newoffVerLst);
            //Database.SaveResult[] offerversavelst = Database.insert(newoffVerLst, false);
            

            for(Offers__c offerrec:newoffVerLst)
            {
                system.debug('Offer Record='+offerrec);
                system.debug('Offer Identifier='+offheadreversemap.get(offerrec.Offer_Header__c));
                offvermap.put(offheadreversemap.get(offerrec.Offer_Header__c),offerrec);
                recordIdMap.put(offerrec.Offer_Header__c+'~1',offheadreversemap.get(offerrec.Offer_Header__c));
            }
            //List<STG_Offers__c> returnstgofferlistoffer=UpdateSTGOfferProcessingStatus.collectStgRecordstoUpdate(stgoffmap,recordIdMap,'Offers_c',newoffVerLst,offerversavelst);    
   			if(offvermap!=null && offvermap.size() > 0)
            {
                system.debug('Process Offers'+offvermap);
                
                
                returnstgofferlist=processOffEligibleMods(stgoffmap,offvermap,feedprocinputs.offerEligibleModelsProcess);
            }
  
        }
        catch(Dmlexception e){
            
             B2B_Util.createErrorRecord('Error in Processing Offer Inbound Feed',e.getMessage(),72,'OfferManagmentInboundProcessing','processInboundFeedNewOffers');
        }
        catch(Exception e){
            B2B_Util.createErrorRecord('Error in Processing Offer Inbound Feed',e.getMessage(),72,'OfferManagmentInboundProcessing','processInboundFeedNewOffers');
        }
        return returnstgofferlist;
  
    }
        

 
    
    public static List<STG_Offers__c> processOffEligibleMods(Map<String,STG_Offers__c> stgOffers,
                                                                              Map<String,Offers__c> offvermap,
                                                                              List<STG_Offer_Eligible_Models__c> stgoffeligmods){
 
  
         Schema.FieldSet STGoffeligmodelflds =  Schema.SObjectType.STG_Offer_Eligible_Models__c.FieldSets.ModelFieldsforOfferVersion;
         Map<String,Id> offEligRecordtypes=GetOfferRecordTypesUtility.getofferEligModRectypeIds();
         List<Offer_Eligible_Models__c> newEligibleModel=new List<Offer_Eligible_Models__c>();
         Map<String,Offer_Eligible_Models__c> offerEligModelsreturn=new Map<String,Offer_Eligible_Models__c> ();                                                                    
         List<String> modelIds=new List<String>();
         Set<String> modelidset=new Set<String>();
          List<STG_Offers__c> returnstgofferlist=new List<STG_Offers__c>();                                                                         
          for(STG_Offer_Eligible_Models__c stgeligmods:stgoffeligmods)    
          {
              modelIds.add(stgeligmods.Model_Id__c);
             
          }
          modelidset.addAll(modelIds);                                                                        
          Map<String,Product_Model__c> prodModelDetails=GetOMModelDetailsUtility.getModelDetailsbyModelId(modelidset);
          //Get Model Details
          system.debug('Offervrsion Map='+offvermap);
          Map<String,String> recordIdMap=new Map<String,String>();   
          Map<String,STG_Offer_Eligible_Models__c> stgeligmodelmap=new Map<String, STG_Offer_Eligible_Models__c>();                                                                     
          for(STG_Offer_Eligible_Models__c offermodel:stgoffeligmods)
          {
             
             Offer_Eligible_Models__c newOfferEligModelRec=new Offer_Eligible_Models__c();
             if(offvermap.get(offermodel.B2C_Offer_Id__c)!=null && stgOffers.get(offermodel.B2C_Offer_Id__c).Id==offermodel.STG_Offer__c)
             {
                 newOfferEligModelRec.Offer__c=offvermap.get(offermodel.B2C_Offer_Id__c).Id;
                 //system.debug('Offer Id='+offvermap.get(offermodel.B2C_Offer_Id__c).Id);
                 newOfferEligModelRec.RecordTypeId=offEligRecordtypes.get(stgOffers.get(offermodel.B2C_Offer_Id__c).Offer_Record_Type__c);
                 newOfferEligModelRec.Alternate_Offer_Eligible_Model_Id__c=offvermap.get(offermodel.B2C_Offer_Id__c).Id+'~'+offermodel.Model_Id__c;
                 newOfferEligModelRec.Brand__c=offvermap.get(offermodel.B2C_Offer_Id__c).Brand__c;//Added by Rama Iyer on 04/10 to fix Product Chooser Issue
                 recordIdMap.put(offvermap.get(offermodel.B2C_Offer_Id__c).Id+'~'+offermodel.Model_Id__c,offermodel.B2C_Offer_Id__c);
                 stgeligmodelmap.put(offvermap.get(offermodel.B2C_Offer_Id__c).Id+'~'+offermodel.Model_Id__c,offermodel);
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
                      Double dealerinvoice=prodModelDetails.get(offermodel.Model_ID__c).Dealer_Invoice__c!=null?prodModelDetails.get(offermodel.Model_ID__c).Dealer_Invoice__c:0;
                      Double dhprice=prodModelDetails.get(offermodel.Model_ID__c).Destination_Handling_Amount__c!=null?prodModelDetails.get(offermodel.Model_ID__c).Destination_Handling_Amount__c:0;
                      newOfferEligModelRec.Invoice_Price_With_DH__c=stgOffers.get(offermodel.B2C_Offer_Id__c).Offer_Record_Type__c.contains('Lease')?dealerinvoice+dhprice:null;

                       
                  }
                 newEligibleModel.add(newOfferEligModelRec);                 
             }

          }   
                                                                                
          //Database.SaveResult[] offeligmodelsavelst = Database.insert(newEligibleModel, false);
           try{
                 Database.SaveResult[] offeligmodelsavelst = Database.insert(newEligibleModel, false);
                // insert newEligibleModel;
                 
                 
                // returnstgofferlist=UpdateSTGOfferProcessingStatus.collectStgRecordstoUpdate(stgOffers,recordIdMap,'Offer_Eligible_Models__c',newEligibleModel,offeligmodelsavelst,stgeligmodelmap);
                //UpdateSTGOfferProcessingStatus.updateStatus(stgOffers,stgoffeligmods,offeligmodelsavelst);
          }
          catch(Dmlexception e)
          {
             system.debug('Error Processing Models'+e.getMessage());

             B2B_Util.createErrorRecord('Error in Processing Offer Inbound Feed',e.getMessage(),172,'OfferFeedInbNewOffers','processOffEligibleMods'); 
          }
          return returnstgofferlist;                                                                     
        
        
    }
       public class FlowInput {
        
        @InvocableVariable
        public List<Stg_Offers__c> offertoProcess;
        
        @InvocableVariable
        public STG_Offers__c stgoffertoProcess;

        @InvocableVariable
         public List<Stg_Offer_Eligible_Models__c> offerEligibleModelsProcess;
   

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
                    {
                        offernm=stgoffer.AHFC_Sales_Program_ID__c+'_'+stgoffer.AHM_Sales_Program_ID__c;
                    }
                  
                }
                when 'New_Standard_Lease' {
                    if (stgoffer.Title_Name__c!=null)
                    {
                        offernm=stgoffer.Title_Name__c;
                    }
            }
            when 'CPO_Special_Program','New_Sepcial_Program' {
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
    /*public static Map<String,String> getoffernameValue(STG_Offers__c stgofftoproc){
      Map<String,String> offernames= new Map<String,String>();
	  if (stgofftoproc.Offer_Record_Type__c=='New_Special_Finance' && )
		return offernames;
    }*/
}
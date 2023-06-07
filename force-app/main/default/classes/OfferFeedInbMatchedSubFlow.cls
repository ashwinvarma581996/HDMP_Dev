//****************************************************************************** 
// File Name:       OfferFeedInbMatchedSubFlow.cls
// Summary:         Apex Class for to Retrieve inbound Offer Feed Records and Process
// Created On:      02-22-2023
// Created By:      Rama Iyer
// Test Classes:    OfferFeedInbMatchedSubFlow_Test.cls
// JIRA Story :     OMP-156,OMP-76,OMP-104,OMP-103
// Methods : 
// 1. processExistingOffers - Main Method to Check Offer Versions
// // Calls to Other Classes :
// 1. OfferFeedInbNewOffers.processOffEligibleMods - For Inserting new models if a new version of offer is loaded
//===============================================================================


public class OfferFeedInbMatchedSubFlow {
    
    @InvocableMethod(label='Inbound Offer Processing Logic - Updates')
    public static List<STG_Offers__c> processExistingOffers(List<FlowInput> inputs){
        
        FlowInput feedprocinputs=inputs.get(0);
        //Now we query the Latest Offer Version with the Same Offer Identifier
        //Create Maps
        Map<String,Offers__c> currentOffMapActive=new Map<String,Offers__c>();
        Map<String,Offers__c> currentOffMap=new Map<String,Offers__c>();
        Map<String,Offers__c> currentOffMaplatestver=new Map<String,Offers__c>();
        Map<String,STG_Offers__c> stgOffMap=new Map<String,STG_Offers__c>();
        Map<String,List<Offer_Eligible_Models__c>> currOfferEligmodmap=new Map<String,List<Offer_Eligible_Models__c>>();
        Map<Id,STG_Offers__c> offerIdsfornewVersion=new Map<Id,STG_Offers__c>();
        Map<String,STG_Offer_Eligible_Models__c> stgOfferEligmodmap=new Map<String,STG_Offer_Eligible_Models__c>();
        Map<String,List<STG_Offer_Eligible_Models__c>> stgofferModels=new Map<String,List<STG_Offer_Eligible_Models__c>>();
        Map<String,List<Offer_Eligible_Models__c>> newOfferEligmodmap=new Map<String,List<Offer_Eligible_Models__c>>();
        Map<String,Offer_Eligible_Models__c> offeligmodelmaps=new  Map<String,Offer_Eligible_Models__c> ();
        Map<Id,String> offerheaderecordmap=new Map<Id,String>();
        List<Offers__c> newOfferversionList=new List<Offers__c>();
        List<Offers__c> oldofferversionList=new List<Offers__c>();
        List<Offer_Eligible_Models__c> newOfferverEligModList=new List<Offer_Eligible_Models__c>();
        List<STG_Offers__c> returnstglist=new List<STG_Offers__c>();
         Map<String,String> recordIdMap=new Map<String,String>(); 
        
        
        //FieldSetMember[] offerfields = sObjectType.Offers__c.fieldSets.getMap().get('NewOfferVersionDeterminators').getFields();
        //FieldSetMember[] STGofferfieldsnewver = sObjectType.STG_Offers__c.fieldSets.getMap().get('NewOfferVersionDeterminators').getFields();
        Schema.FieldSet STGofferfieldsnewver = Schema.SObjectType.STG_Offers__c.FieldSets.NewOfferVersionDeterminators;
      
        //Collect Latest Active or Latest Offer Version for Manipulation
        for (Offers__c curroff: feedprocinputs.currentOffer)
        {
            system.debug('Current Offer Tested='+curroff);
            offerheaderecordmap.put(curroff.Offer_Header__c,curroff.Offer_Identifier__c);
            if (curroff.Status__c=='Active' || curroff.status__c=='Approved'||curroff.status__c=='Submitted')
            {
   
                currentOffMapActive.put(curroff.Offer_Identifier__c,curroff);
            }
            else if (curroff.Latest_Version__c=true)
            {
                currentOffMaplatestver.put(curroff.Offer_Identifier__c,curroff);
            }
            currentOffMap.put(curroff.Offer_Identifier__c,curroff);
            List<Offer_Eligible_Models__c> curroffeligmodlst=new List<Offer_Eligible_Models__c>();
       
            for (Offer_Eligible_Models__c currelmod: feedprocinputs.currentEligibleModels)
            {
                if (currelmod.Offer__c==curroff.Id) curroffeligmodlst.add(currelmod);
                offeligmodelmaps.put(currelmod.Offer_Identifier__c+'_'+currelmod.Model_ID__c,currelmod);
                system.debug('Current Model='+currelmod.Offer_Identifier__c+'_'+currelmod.Model_ID__c);
            } 
            currOfferEligmodmap.put(curroff.Offer_Identifier__c,curroffeligmodlst);
            List<STG_Offer_Eligible_Models__c> stgofmodellist=new List<STG_Offer_Eligible_Models__c>();
            for (STG_Offer_Eligible_Models__c modeltoproc:feedprocinputs.offerEligibleModelsProcess )
            {
               if (modeltoproc.b2c_Offer_Id__c==curroff.Offer_Identifier__c)
               {
                   stgofmodellist.add(modeltoproc);
                   stgOfferEligmodmap.put(modeltoproc.b2c_Offer_Id__c+'_'+modeltoproc.Model_ID__c,modeltoproc);
               }
            }
            stgofferModels.put(curroff.Offer_Identifier__c,stgofmodellist);
            
            
        }
        //Now Lets Check STG Offers
        //
       //Setup offer Eligible Model Maps
       Map<String,String> offerRecordtypeNames=new Map<String,String>();
        
        for (STG_Offers__c offertoproc: feedprocinputs.offertoProcess)
        {
            Offers__c newofferversionrec=new Offers__c();
            stgOffMap.put(offertoproc.B2C_Offer_Id__c,offertoproc);
            offerRecordtypeNames.put(offertoproc.B2C_Offer_Id__c,offertoproc.Offer_Record_Type__c);
            Offers__c offerversiontocheck=currentOffMapActive.get(offertoproc.B2C_Offer_Id__c)!=null?currentOffMapActive.get(offertoproc.B2C_Offer_Id__c):currentOffMaplatestver.get(offertoproc.B2C_Offer_Id__c);
            System.debug('Offer Version to Check ='+offerversiontocheck);
            Boolean creatnewversion=false;
            Integer noofVerDeterminschanged=0;
            //newofferversionrec=offerversiontocheck!=null?offerversiontocheck:null;
            newofferversionrec.offer_header__c=offerversiontocheck.Offer_Header__c;
            newofferversionrec.name=offerversiontocheck.Name;
            newofferversionrec.RecordTypeId=offerversiontocheck.RecordTypeId;
            newofferversionrec.Descriptive_Name__c=offerversiontocheck.Descriptive_Name__c;
            newofferversionrec.Status__c='WIP';
       
            newofferversionrec.Synched_with_PRISM__c=true;
            newofferversionrec.PRISM_Offer_Status__c=offertoproc.PRISM_Offer_Status__c;
            newofferversionrec.Credit_Tier__c=offerversiontocheck.Credit_Tier__c;
            newofferversionrec.AHFC_Sales_Program_ID__c=offerversiontocheck.AHFC_Sales_Program_ID__c;
            newofferversionrec.AHM_Sales_Program_ID__c=offerversiontocheck.AHFC_Sales_Program_ID__c;
            newofferversionrec.Lease_Title_Ident__c=offerversiontocheck.Lease_Title_Ident__c;
            newofferversionrec.Offer_Type__c=offerversiontocheck.Offer_Type__c;
            newofferversionrec.Brand__c=offerversiontocheck.Brand__c;
            newofferversionrec.Offer_Availability__c=offerversiontocheck.Offer_Availability__c;
            newofferversionrec.Group_Code__c=offerversiontocheck.Group_Code__c;
            newofferversionrec.Group_Type__c=offerversiontocheck.Group_Type__c;
            newofferversionrec.AHM_Regions__c=offerversiontocheck.AHM_Regions__c;
            newofferversionrec.Sales_Program_CD__c=offerversiontocheck.Sales_Program_CD__c;
            newofferversionrec.Priority__c=offerversiontocheck.Priority__c;
            newofferversionrec.Boilerplate__c=offerversiontocheck.Boilerplate__c!=null?offerversiontocheck.Boilerplate__c:null;
            newofferversionrec.Offer_Title__c=offerversiontocheck.Offer_Title__c!=null?offerversiontocheck.Offer_Title__c:null;
            newofferversionrec.Short_Description__c=offerversiontocheck.Short_Description__c!=null?offerversiontocheck.Short_Description__c:null;
            newofferversionrec.Detailed_Description__c=offerversiontocheck.Detailed_Description__c!=null?offerversiontocheck.Detailed_Description__c:null;
            newofferversionrec.Legal_Desclaimer__c=offerversiontocheck.Legal_Desclaimer__c!=null?offerversiontocheck.Legal_Desclaimer__c:null;
            newofferversionrec.Terms_and_Conditions__c=offerversiontocheck.Terms_and_Conditions__c!=null?offerversiontocheck.Terms_and_Conditions__c:null;
            newofferversionrec.Advertised_End_Date__c=offertoproc.Start_Date__c;
            newofferversionrec.Advertised_Start_Date__c=offertoproc.End_Date__c;
            //newofferversionrec.Latest_Version__c=true;
			//Check if Main Offer Fields have changed - Then create new Version
            for (Schema.FieldSetMember stgofffld : STGofferfieldsnewver.getFields() )
            {
				//system.debug('Field='+stgofffld.getFieldPath()+',Current Value='+offerversiontocheck.get(stgofffld.getFieldPath())+'New Value='+ offertoproc.get(stgofffld.getFieldPath()));
                if (offertoproc.get(stgofffld.getFieldPath())!=offerversiontocheck.get(stgofffld.getFieldPath()) && offertoproc.get(stgofffld.getFieldPath())!=null)
                {
                    Double versionumactive=currentOffMapActive.get(offertoproc.B2C_Offer_Id__c)!=null?currentOffMapActive.get(offertoproc.B2C_Offer_Id__c).Version_Number__c:1;
                    Double versionumlatest=currentOffMaplatestver.get(offertoproc.B2C_Offer_Id__c)!=null?currentOffMaplatestver.get(offertoproc.B2C_Offer_Id__c).Version_Number__c:1;
                    Double lastversionnumber=Math.max(versionumactive, versionumlatest);
                    
                    newofferversionrec.put(stgofffld.getFieldPath(),offertoproc.get(stgofffld.getFieldPath()));
                    newofferversionrec.Version_Number__c=lastversionnumber+1;
                    newofferversionrec.Latest_Version__c=true;
                    noofVerDeterminschanged+=1;
                   
                }
                else{
                    newofferversionrec.put(stgofffld.getFieldPath(),offerversiontocheck.get(stgofffld.getFieldPath()));
                }
            }
            newofferversionrec.Start_Date__c=offertoproc.Start_Date__c;
            newofferversionrec.End_Date__c=offertoproc.End_Date__c;
            //newofferversionrec.Id=null;
            //Check Start Date, End Date has Changed to update the current offer
            system.debug('Offer being Tested='+offerversiontocheck);
            system.debug('Offer Start Dates='+offerversiontocheck.Start_Date__c+'New Date='+offertoproc.Start_Date__c );
            system.debug('Offer End Dates='+offerversiontocheck.End_Date__c+'New Date='+offertoproc.End_Date__c );
            recordIdMap.put(offerversiontocheck.Alternate_Offer_Identifier__c,offertoproc.B2C_Offer_Id__c);
            if (offerversiontocheck.Start_Date__c!=offertoproc.Start_Date__c || offerversiontocheck.End_Date__c!=offertoproc.End_Date__c )
            {
                offerversiontocheck.Start_Date__c=offertoproc.Start_Date__c;
                offerversiontocheck.Advertised_Start_Date__c=offerversiontocheck.Advertised_Start_Date__c!=null?offertoproc.Start_Date__c:null;
                if (offertoproc.PRISM_Offer_Status__c=='A' && offerversiontocheck.Status__c=='Approved' && offertoproc.Start_Date__c<System.today()) 
                {	
                    offerversiontocheck.Status__c='Active' ;
               	   
                }
				offerversiontocheck.End_Date__c=offertoproc.End_Date__c<>offerversiontocheck.End_Date__c?offertoproc.End_Date__c:offerversiontocheck.End_Date__c;
                offerversiontocheck.Advertised_End_Date__c=offerversiontocheck.Advertised_End_Date__c!=null?offertoproc.End_Date__c:null; 
     			if ((offertoproc.End_Date__c < System.today())
                  || offertoproc.PRISM_Offer_Status__c=='C' 
                  ||(offertoproc.Start_Date__c>=System.today()) )
                {
                    offerversiontocheck.Start_Date__c=offertoproc.Start_Date__c;
                    offerversiontocheck.End_Date__c=offertoproc.End_Date__c;

                   if (offerversiontocheck.Status__c!='WIP') 
                   {
                        if (offerversiontocheck.Status__c=='Submitted')
                        {
                            //Meaning offer is in approval process, then cancel the approval process
                            cancelOfferApprovalProcess(offerversiontocheck);
                        }                    
                    
                    offerversiontocheck.Status__c='Expired';

                  }
                    
                }
                else if (offerversiontocheck.Status__c=='Submitted'||offerversiontocheck.Status__c=='Approved')
                {
                       if (offertoproc.Start_Date__c<System.today())
                       {
                         if (offerversiontocheck.Status__c=='Submitted')
                         {
                            cancelOfferApprovalProcess(offerversiontocheck);
                         }
                         offerversiontocheck.Status__c='WIP';
                       } 
                }
                /*if (offertoproc.Start_Date__c >=System.today()) 
                {
                    if (offerversiontocheck.Status__c!='WIP') 
                    {
                        if (offerversiontocheck.Status__c='Submitted')
                        {
                            //Meaning offer is in approval process
                            cancelOfferApprovalProcess(offerversiontocheck);
                        }
                        offerversiontocheck.Status__c='Expired';
                    }
                    
                }*/
                
                system.debug('Offer Status='+offerversiontocheck.Status__c+',End Date='+offerversiontocheck.End_Date__c+',Start Date='+offerversiontocheck.Start_Date__c);
                oldofferversionList.add(offerversiontocheck);
                
            }
            
			//Check if No of Models in Offer Changed for Same Offer Id. Then we set flag for new version and subsequently new models as well
            if (currOfferEligmodmap.get(offertoproc.B2C_Offer_Id__c).size()!=stgofferModels.get(offertoproc.B2C_Offer_Id__c).size()||noofVerDeterminschanged>0) 
            {
                /*system.debug('No Of Version Determinators Changed ='+noofVerDeterminschanged);
                system.debug ('No Of Offer Models in Old Offer='+currOfferEligmodmap.get(offertoproc.B2C_Offer_Id__c).size());
                system.debug ('No Of Offer Models in New Offer='+stgofferModels.get(offertoproc.B2C_Offer_Id__c).size());*/
                creatnewversion=true;
            }
            else {
                //Check if any Models fields have changed - Cash fields
               Schema.FieldSet STGEligModelNewver = Schema.SObjectType.STG_Offer_Eligible_Models__c.FieldSets.ModelFieldsForNewOfferVersion;
               System.debug('No of Models for this Offer='+stgofferModels.get(offertoproc.B2C_Offer_Id__c).size()) ;
               for (STG_Offer_Eligible_Models__c stgmodeltocheck : stgofferModels.get(offertoproc.B2C_Offer_Id__c))
                {
                    Offer_Eligible_Models__c offeligmodel=offeligmodelmaps.get(stgmodeltocheck.B2C_Offer_Id__c+'_'+stgmodeltocheck.Model_ID__c);
                     for (Schema.FieldSetMember stgoffeligfld : STGEligModelNewver.getFields() )
                    {  //Compare model fields against the same offer version
                        system.debug('STG='+stgoffeligfld.getFieldPath()+'='+stgmodeltocheck.get(stgoffeligfld.getFieldPath()));
                        system.debug('OfferModel='+stgoffeligfld.getFieldPath()+'='+offeligmodel.get(stgoffeligfld.getFieldPath()));
                        if (stgmodeltocheck.get(stgoffeligfld.getFieldPath())!=offeligmodel.get(stgoffeligfld.getFieldPath()) && stgmodeltocheck.get(stgoffeligfld.getFieldPath())!=null && offeligmodel.Offer__c==offerversiontocheck.Id)
                        {
                           creatnewversion=true; 
                        }
                    }
                        system.debug('Offer Eligible Model - Alt Id='+offeligmodel.Alternate_Offer_Eligible_Model_Id__c);
                        system.debug('STG Offer Models='+offerversiontocheck.Id+'~'+stgmodeltocheck.Model_Id__c);
                        newOfferverEligModList.add(offeligmodel);
                        stgOfferEligmodmap.put(offerversiontocheck.Id+'~'+stgmodeltocheck.Model_Id__c,stgmodeltocheck);
                        //recordIdMap.put(offerversiontocheck.Id+'~'+stgmodeltocheck.Model_Id__c,stgmodeltocheck.b2c_Offer_Id__c);
                    
                }
                system.debug('newOfferverEligModList='+newOfferverEligModList.size());
            }
            system.debug('Create New Version Flag='+creatnewversion);
             if (creatnewversion)
             {
                Double versionumactive=currentOffMapActive.get(offertoproc.B2C_Offer_Id__c)!=null?currentOffMapActive.get(offertoproc.B2C_Offer_Id__c).Version_Number__c:1;
                Double versionumlatest=currentOffMaplatestver.get(offertoproc.B2C_Offer_Id__c)!=null?currentOffMaplatestver.get(offertoproc.B2C_Offer_Id__c).Version_Number__c:1;
                Double lastversionnumber=Math.max(versionumactive, versionumlatest);
                newofferversionrec.Version_Number__c=lastversionnumber+1;
                newofferversionrec.Alternate_Offer_Identifier__c=newofferversionrec.Offer_Header__c+'~'+newofferversionrec.Version_Number__c;
                                
                newOfferversionList.add(newofferversionrec);

             }
                
            


        }
        system.debug('STG Off Map='+stgOffMap);
        system.debug('Old Offer Version to Update='+oldofferversionList);
        //Update Old Offer Versions if End Date or Start Date is Changed
        if (oldofferversionList!=null && oldofferversionList.size()>0)
        {
            try {
                
   
               
                //update oldofferversionList;
                Database.SaveResult[] oldversion = Database.update(oldofferversionList, false);
                List<STG_Offers__c> returnstgofferlist=new List<STG_Offers__c>();
               // returnstgofferlist=UpdateSTGOfferProcessingStatus.collectStgRecordstoUpdate(stgOffMap,recordIdMap,'OldOfferVersion',oldofferversionList,oldversion,stgOfferEligmodmap);
                Map<String,Offers__c> mapoffer=new Map<String,Offers__c>();
 
            }
            catch (Dmlexception e)
            {
                system.debug('Erro Updating Old Offer Versions with Dates'+e.getMessage());
                  B2B_Util.createErrorRecord('Inbound Feed Processing Error', 'Error Processing Offer Activation and Expiring:-'+e.getMessage(),139, 'OfferFeedInbMatchedSubFlow.cls', 'processExistingOffers');
            }
            catch (Exception e)
            {
                system.debug('Error With Old Offer List '+stgoffmap+','+e.getMessage());
                  B2B_Util.createErrorRecord('Inbound Feed Processing Error', 'Error Processing Offer Activation and Expiring:-'+e.getMessage(),139, 'OfferFeedInbMatchedSubFlow.cls', 'processExistingOffers');                
            }

        }

        //If new Version is getting created then insert also new models
        if (newOfferversionList!=null && newOfferversionList.size()>0)
        {
            try {
                
   
                system.debug('New OfferVersion List='+newOfferversionList);
                insert newOfferversionList;
                Map<String,Offers__c> mapoffer=new Map<String,Offers__c>();
                for(Offers__c newoffers:newOfferversionList) 
                {
                    mapoffer.put(offerheaderecordmap.get(newoffers.Offer_Header__c),newoffers);
                }
               returnstglist=OfferFeedInbNewOffers.processOffEligibleMods(stgOffMap,mapoffer,feedprocinputs.offerEligibleModelsProcess);
            }
            catch (Dmlexception e)
            {
                system.debug('Erro Updating new Offer Version List='+e.getMessage());
                  B2B_Util.createErrorRecord('Inbound Feed Processing Error', 'Error Processing Offer New Version Logic'+e.getMessage(),163, 'OfferFeedInbMatchedSubFlow.cls', 'processExistingOffers');                
            }
            catch (Exception e)
            {
                system.debug('Error With Offer Map '+stgoffmap+','+e.getMessage());
                 B2B_Util.createErrorRecord('Inbound Feed Processing Error', 'Error Processing Offer New Version Logic'+e.getMessage(),163, 'OfferFeedInbMatchedSubFlow.cls', 'processExistingOffers');                                
            }

        }
        return returnstglist;
 
    }
	
    public static void cancelOfferApprovalProcess(Offers__c offertoCancel)
    {
        List<Approval.ProcessWorkitemRequest> approvalreqs = new List<Approval.ProcessWorkitemRequest> ();
        //Get the Process Instances where Offer is in Approval
        //Map<ID,ProcessInstance> procMap = New Map<ID,ProcessInstance>([Select Id from ProcessInstance where TargetObjectId = :offertoCancel.Id);
        for (ProcessInstanceWorkItem approvalprocess: [Select Id from ProcessInstanceWorkItem where ProcessInstance.TargetObjectId = :offertoCancel.Id and ProcessInstance.Status = 'Pending' ])
        {
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setAction('Removed');
            request.setWorkItemId(approvalprocess.Id);
            approvalreqs.add(request);
        }
        if (approvalreqs!=null && approvalreqs.size()>0)
        {
            Approval.ProcessResult[] processResults = Approval.process(approvalreqs, true);
             
        }
    }

        public class FlowInput {
        
        @InvocableVariable
        public List<Stg_Offers__c> offertoProcess;
        
        @InvocableVariable
         public List<Offers__c> currentOffer;
        
   
       @InvocableVariable
        public List<Offer_Eligible_Models__c> currentEligibleModels;
        
        @InvocableVariable
         public List<Stg_Offer_Eligible_Models__c> offerEligibleModelsProcess;

    }
}
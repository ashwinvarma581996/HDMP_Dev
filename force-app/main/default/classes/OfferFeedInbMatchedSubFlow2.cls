/**
 * @name              : OfferFeedInbMatchedSubFlow2
 * @description       : Apex class for processing Inbound Offers where Offer Identifier matches the B2C Offer Id in Stg Offer table
 * @author            : Rama Iyer
 * @group             : Honda Offer Management
 * @last modified on  : 05-04-2023
 * @last modified by  : Rama Iyer
 * JIRA Story         : OMP-156, Update Scenarios
 * Test Class         : OfferManagmentInboundProcessing_Test.cls
 * Methods            : processExistingOffers - Main Method to perform update scenarios
 * Calls to other     : UpdateSTGOfferProcessingStatus.setstatusonstgrecords - Update the STG Offer States
**/



public class OfferFeedInbMatchedSubFlow2 {

    public static void processExistingOffers(

        List<STG_Offers__c> matchedSTGOffers,
        Map<Id,List<STG_Offer_Eligible_Models__c>> matchedModels,
        Map<String,Offer_Header__c> offerheadmap,
        Map<Id,List<Offers__c>> matchedOfferVersions,
        Map<Id,List<Offer_Eligible_Models__c>> matchedofferEligmodels
    )
    {
        Schema.FieldSet STGofferfieldsnewver = Schema.SObjectType.STG_Offers__c.FieldSets.OfferVersionFields;
        Schema.FieldSet STGoffeligmodelflds =  Schema.SObjectType.STG_Offer_Eligible_Models__c.FieldSets.ModelFieldsforOfferVersion;
    
        //New Offer Version Determinators. If any of these fields differ on Offer or Model its a new version
        
        Schema.FieldSet newOfferversiondet = Schema.SObjectType.STG_Offers__c.FieldSets.NewOfferVersionDeterminators;
        Schema.FieldSet newOfferversiondetmodel = Schema.SObjectType.STG_Offer_Eligible_Models__c.FieldSets.ModelFieldsForNewOfferVersion;
    
        Map<String,Id> offerRecordtypes=GetOfferRecordTypesUtility.getofferRectypeIds();  
        Map<String,Id> offerheadrectypes=GetOfferRecordTypesUtility.getofferHeadRectypeIds();
        Map<String,Id> offEligRecordtypes=GetOfferRecordTypesUtility.getofferEligModRectypeIds();
    
        Map<String,STG_Offers__c> stgoffmap=new Map<String,STG_Offers__c> ();
    
        List<Offers__c> oldofferversionlst=new List<Offers__c>();
        List<Offers__c> newofferversionlst=new List<Offers__c>();
        List<Offer_Eligible_Models__c> newofferModelsList=new List<Offer_Eligible_Models__c>();
        List<String> modelids=new List<String>();
        Set<String> modelidset=new Set<String>();
    
        List<Offer_Header__c> offheaderlst=new List<Offer_Header__c>();
        for (Id stgofferIds: matchedModels.keySet())
        {
            for(STG_Offer_Eligible_Models__c models:matchedModels.get(stgofferIds))
            {
                modelids.add(models.Model_Id__c);
            }

        }
        modelidset.addAll(modelids);
        Map<String,Product_Model__c> prodModelDetails=GetOMModelDetailsUtility.getModelDetailsbyModelId(modelidset);
    
        for(STG_Offers__c offertoproc:matchedSTGOffers)
        {
            stgoffmap.put(offertoproc.b2c_Offer_Id__c,offertoproc);
            List<Offers__c> currentoffers=matchedOfferVersions.get(offertoproc.Id);
            Offer_Header__c offheadrec=offerheadmap.get(offertoproc.b2c_Offer_Id__c);
            offheaderlst.add(offheadrec);
            Map<String,Offers__c> currentOffMapActive=new Map<String,Offers__c>();
            Map<String,Offers__c> currentOffMap=new Map<String,Offers__c>();
            Map<String,Offers__c> currentOffMaplatestver=new Map<String,Offers__c>();
            Offers__c newofferversionrec=new Offers__c();
            for(Offers__c curroff:currentoffers)
            {
                if (curroff.Status__c=='Active' || curroff.status__c=='Approved'||curroff.status__c=='Submitted')
                {
       
                    currentOffMapActive.put(offertoproc.Id,curroff);
                }
                else if (curroff.Latest_Version__c=true)
                {
                    currentOffMaplatestver.put(offertoproc.Id,curroff);
                }
            }
            Offers__c offerversiontocheck=currentOffMapActive.get(offertoproc.Id)!=null?currentOffMapActive.get(offertoproc.Id):currentOffMaplatestver.get(offertoproc.Id);
            List<Offer_Eligible_Models__c> currentmodellist=matchedofferEligmodels.get(offerversiontocheck.Id);
            Map<String,Offer_Eligible_Models__c> offerligmodelmap=new Map<String,Offer_Eligible_Models__c>();
            for (Offer_Eligible_Models__c offerligmodel1:matchedofferEligmodels.get(offerversiontocheck.Id))
            {
                offerligmodelmap.put(offertoproc.Id+'~'+offerligmodel1.Model_Id__c,offerligmodel1);
            }
            System.debug('Offer Id='+offerversiontocheck.Id+',No of models='+currentmodellist.size());
            Double versionumactive=currentOffMapActive.get(offertoproc.Id)!=null?currentOffMapActive.get(offertoproc.Id).Version_Number__c:1;
            Double versionumlatest=currentOffMaplatestver.get(offertoproc.Id)!=null?currentOffMaplatestver.get(offertoproc.Id).Version_Number__c:1;
            Double lastversionnumber=Math.max(versionumactive, versionumlatest);
            newofferversionrec.Version_Number__c=lastversionnumber+1;
            newofferversionrec.Latest_Version__c=true;
            newofferversionrec.Offer_Header__c=offheadrec.Id;
            newofferversionrec.Alternate_Offer_Identifier__c=offertoproc.b2c_Offer_Id__c+'~'+string.valueof(integer.valueof(newofferversionrec.Version_Number__c));
            newofferversionrec.Status__c='WIP';
            newofferversionrec.Synched_with_PRISM__c=true;
            newofferversionrec.PRISM_Offer_Status__c=offertoproc.PRISM_Offer_Status__c;

            newofferversionrec.Descriptive_Name__c=offertoproc.AHFC_Internal_Sales_Program_Name__c;

            newofferversionrec.Name=offheadrec.Name;
            newofferversionrec.AHFC_Sales_Program_ID__c=offertoproc.AHFC_Sales_Program_ID__c;
            newofferversionrec.AHM_Sales_Program_ID__c=offertoproc.AHM_Sales_Program_ID__c;

            newofferversionrec.RecordTypeId=offerRecordtypes.get(offertoproc.Offer_Record_Type__c);
    
    
            //Copy Boilerplate Details if available in previous offer
    
            newofferversionrec.Boilerplate__c=offerversiontocheck.Boilerplate__c!=null?offerversiontocheck.Boilerplate__c:null;
            newofferversionrec.Offer_Title__c=offerversiontocheck.Offer_Title__c!=null?offerversiontocheck.Offer_Title__c:null;
            newofferversionrec.Short_Description__c=offerversiontocheck.Short_Description__c!=null?offerversiontocheck.Short_Description__c:null;
            newofferversionrec.Detailed_Description__c=offerversiontocheck.Detailed_Description__c!=null?offerversiontocheck.Detailed_Description__c:null;
            newofferversionrec.Legal_Desclaimer__c=offerversiontocheck.Legal_Desclaimer__c!=null?offerversiontocheck.Legal_Desclaimer__c:null;
            newofferversionrec.Terms_and_Conditions__c=offerversiontocheck.Terms_and_Conditions__c!=null?offerversiontocheck.Terms_and_Conditions__c:null;


    
            if (offertoproc.Offer_Record_Type__c.contains('CPO'))
            newofferversionrec.Product_Type__c=offertoproc.Vehicle_Type_CD__c=='U'?'Used':'Certfied';
    
            for (Schema.FieldSetMember stgnewOffField : STGofferfieldsnewver.getFields() )
            {
                if (offertoproc.get(stgnewOffField.getFieldPath())!=null) newofferversionrec.put(stgnewOffField.getFieldPath(),offertoproc.get(stgnewOffField.getFieldPath()));
            } 
/*            if (offertoproc.Offer_Availability__c=='R'){
                newofferversionrec.Offer_Availability__c='Regional';
            }
            else
            {
                newofferversionrec.Offer_Availability__c='National';
            }
*/
            newofferversionrec.Offer_Type__c=offertoproc.Offer_Type_CD__c;
            
            if (offertoproc.Vehicle_Type_CD__c=='U')
            {
                newofferversionrec.Product_Type__c='Used';
            }
            else if (offertoproc.Vehicle_Type_CD__c=='C')
            {
                newofferversionrec.Product_Type__c='Certified';
            }
    
    
            // Check if Main Offer Fields have changed - (E.g. For Finance offers APR)
            Boolean createnewversion=false;

                //Check the updates to the offer Start Date End Date etc
                if (offerversiontocheck.Start_Date__c<>offertoproc.Start_Date__c || 
                offerversiontocheck.End_Date__c<>offertoproc.End_Date__c ||
                offerversiontocheck.PRISM_Offer_Status__c<>offertoproc.PRISM_Offer_Status__c)
            {   //Scenario 4
                if(offertoproc.PRISM_Offer_Status__c=='A' && offerversiontocheck.Status__c=='Approved' && offertoproc.Start_Date__c <= System.today()
                   && offertoproc.End_Date__c>System.today())
                {
                    offerversiontocheck.Status__c='Active' ;
                    offerversiontocheck.PRISM_Offer_Status__c=offertoproc.PRISM_Offer_Status__c;
                    offerversiontocheck.Start_Date__c=offertoproc.Start_Date__c;
                    offerversiontocheck.End_Date__c=offertoproc.End_Date__c;
                    system.debug('Inside Scenario 4:');
                }
                //Scenario 7a : If Offer Start Date Received is in the past and End Date is in the future
                else if (offertoproc.Start_Date__c<System.today() && offertoproc.End_Date__c >=System.today())
                {
                    
                    if (offerversiontocheck.status__c!='WIP' && offerversiontocheck.status__c!='Active')
                    {
                        if(offerversiontocheck.Status__c=='Submitted') cancelOfferApprovalProcess(offerversiontocheck); //Recall Approval if offer is submitted
                        offerversiontocheck.Status__c='WIP';
                        offerversiontocheck.Start_Date__c=offertoproc.Start_Date__c;
                        offerversiontocheck.End_Date__c=offertoproc.End_Date__c;
                        offerversiontocheck.PRISM_Offer_Status__c=offertoproc.PRISM_Offer_Status__c;
                        system.debug('Inside Scenario 7a');
                        
                    }

                }
                //Scenario 7b : If Offer Start Date is changed today or a future date
                else if (offertoproc.Start_Date__c>=System.today() && offertoproc.End_Date__c >=System.today())
                {
                    if (offerversiontocheck.status__c=='Submitted' || offerversiontocheck.status__c=='Approved' ||offerversiontocheck.Status__c=='Active')
                    {
                        //
                        if(offerversiontocheck.Status__c=='Submitted') cancelOfferApprovalProcess(offerversiontocheck); //Recall Approval if offer is submitted
                        offerversiontocheck.Status__c='Expired';
                        //newofferversionlst.add(newofferversionrec); // Create New Version with WIP with the updated start/end dates
                        createnewversion=true;
                        newofferversionrec.Start_Date__c=offertoproc.Start_Date__c;
                        newofferversionrec.End_Date__c=offertoproc.End_Date__c;
                        newofferversionrec.PRISM_Offer_Status__c=offertoproc.PRISM_Offer_Status__c;
                        system.debug('Inside Scenario 7b');

                    }
                    //Scenario 7c : If its WIP Or Validated
                    else
                    {
                        offerversiontocheck.Status__c='WIP';
                        offerversiontocheck.Start_Date__c=offertoproc.Start_Date__c;
                        offerversiontocheck.End_Date__c=offertoproc.End_Date__c;
                        offerversiontocheck.PRISM_Offer_Status__c=offertoproc.PRISM_Offer_Status__c;     
                        system.debug('Inside Scenario 7c');                   
                    }
                }
                //Scenario 5 & Scenario 8 : If PRISM is changed to Closed or End Date is less than todays date
                else if (offertoproc.End_Date__c < System.today()||offertoproc.PRISM_Offer_Status__c=='C')
                {
                    if(offerversiontocheck.Status__c=='Submitted') cancelOfferApprovalProcess(offerversiontocheck); //Recall Approval if offer is submitted
                    offerversiontocheck.Status__c='Expired';
                    offerversiontocheck.End_Date__c=offertoproc.End_Date__c;
                    system.debug('Inside Scenario 5 & 8');  

                }
                oldofferversionlst.add(offerversiontocheck);

            }
    
            for (Schema.FieldSetMember stgofffld : newOfferversiondet.getFields() )
            {
                //system.debug('Field='+stgofffld.getFieldPath()+',Current Value='+offerversiontocheck.get(stgofffld.getFieldPath())+'New Value='+ offertoproc.get(stgofffld.getFieldPath()));
                //Get Regional Value
                String inboffavailability='National';
                String currentofferavailability='National';

                if (stgofffld.getFieldPath()=='Offer_Availability__c')
                {
                    inboffavailability=offertoproc.get(stgofffld.getFieldPath())=='R'?'Regional':'National';
                    currentofferavailability=String.valueof(offerversiontocheck.get(stgofffld.getFieldPath()));
                    if (inboffavailability!=currentofferavailability)
                    {
                        newofferversionrec.Offer_Availability__c=offertoproc.get(stgofffld.getFieldPath())=='R'?'Regional':'National';
                        createnewversion=true;
                    }
                }
                //Check other fields if changed
                if ((offertoproc.get(stgofffld.getFieldPath())!=offerversiontocheck.get(stgofffld.getFieldPath())&& stgofffld.getFieldPath()!='Offer_Availability__c') && offertoproc.get(stgofffld.getFieldPath())!=null)
                {
                    newofferversionrec.put(stgofffld.getFieldPath(),offertoproc.get(stgofffld.getFieldPath()));
                    createnewversion=true;//Determines if a new version should be created or not
                   
                }
                else{
                    newofferversionrec.put(stgofffld.getFieldPath(),offerversiontocheck.get(stgofffld.getFieldPath()));
                }
            }
            //Integer noofmodelsincurroffer=;
            /*for(Offer_Eligible_Models__c offeligmodel:matchedofferEligmodels.get(offertoproc.Id))
            {
                if (offeligmodel.Offer__c==offerversiontocheck.Id) noofmodelsincurroffer++;
            }*/
    
            //Now we check if no of models between both the offers have changed and if above condition did not change
            system.debug('No Of Models Currently='+matchedofferEligmodels.get(offerversiontocheck.Id).size()+',New total models='+matchedModels.get(offertoproc.Id).size());
            if (matchedModels.get(offertoproc.Id).size() != matchedofferEligmodels.get(offerversiontocheck.Id).size() && !createnewversion)
            {
                createnewversion=true;
            }
            //Create New Version is still false. So lets ensure main models fields are not changed
            //We will not build the model list here. We will only build if the create new version is true
            List<STG_Offer_Eligible_Models__c> stgmodelstoprocess=matchedModels.get(offertoproc.Id);
            List<Offer_Eligible_Models__c> offerligiblemodels=matchedofferEligmodels.get(offertoproc.Id);
            //Build a map of the offer eligible models so you dont have to do for loop within for loop within for loop
            //Map<String,Offer_Eligible_Models__c> offerligmodelmap=new Map<String,Offer_Eligible_Models__c>();

            for (STG_Offer_Eligible_Models__c stgmodeltocheck : stgmodelstoprocess)
            {
                //Only for Lease offers we need to check fields below
                Offer_Eligible_Models__c offeligmodel=offerligmodelmap.get(stgmodeltocheck.STG_Offer__c+'~'+stgmodeltocheck.Model_Id__c);
                //Offer_Eligible_Models__c offeligmodel=matchedofferEligmodels.get(offerversiontocheck.Id);
                if (offeligmodel!=null && offertoproc.Offer_Record_Type__c.contains('Lease')){
                    for (Schema.FieldSetMember stgoffeligfld : newOfferversiondetmodel.getFields() )
                    {  //Compare model fields against the same offer version
                        system.debug('STG='+stgoffeligfld.getFieldPath()+'='+stgmodeltocheck.get(stgoffeligfld.getFieldPath()));
                        system.debug('OfferModel='+stgoffeligfld.getFieldPath()+'='+offeligmodel.get(stgoffeligfld.getFieldPath()));
                        if (stgmodeltocheck.get(stgoffeligfld.getFieldPath())!=offeligmodel.get(stgoffeligfld.getFieldPath()) && stgmodeltocheck.get(stgoffeligfld.getFieldPath())!=null && offeligmodel.Offer__c==offerversiontocheck.Id)
                        {
                            createnewversion=true; 
                        }
                    }
                    
                }


            }
            if (createnewversion)
            {
                if (offertoproc.Offer_Availability__c=='R'){
                    newofferversionrec.Offer_Availability__c='Regional';
                }
                else
                {
                    newofferversionrec.Offer_Availability__c='National';
                }

                newofferversionlst.add(newofferversionrec);
                for (STG_Offer_Eligible_Models__c stgmodeltocheck : stgmodelstoprocess)
                {
                    Offer_Eligible_Models__c newOfferEligModelRec=new Offer_Eligible_Models__c();
                    newOfferEligModelRec.Brand__c=offertoproc.Brand__c;
                    newOfferEligModelRec.RecordTypeId=offEligRecordtypes.get(offertoproc.Offer_Record_Type__c);
                    Offers__c offerref=new Offers__c(Alternate_Offer_Identifier__c=stgmodeltocheck.b2c_offer_Id__c+'~'+string.valueof(integer.valueof(newofferversionrec.Version_Number__c)));
                    system.debug(offerref);
                    newOfferEligModelRec.Offer__r=offerref;
    
                    for (Schema.FieldSetMember stgoffeligmodelfld : STGoffeligmodelflds.getFields() )
                    {
                       //system.debug('Fields Being Loaded:'+stgoffeligmodelfld.getFieldPath());
                       if (stgmodeltocheck.get(stgoffeligmodelfld.getFieldPath())!=null && stgoffeligmodelfld.getFieldPath()!='IsDeleted') newOfferEligModelRec.put(stgoffeligmodelfld.getFieldPath(),stgmodeltocheck.get(stgoffeligmodelfld.getFieldPath()));
                    } 
                    if (prodModelDetails.get(stgmodeltocheck.Model_ID__c)!=null)
                    {
                        newOfferEligModelRec.Name=prodModelDetails.get(stgmodeltocheck.Model_ID__c).Model_Name__c;
                        newOfferEligModelRec.Model__c=prodModelDetails.get(stgmodeltocheck.Model_ID__c).Model_Name__c;
                        newOfferEligModelRec.Trim__c=prodModelDetails.get(stgmodeltocheck.Model_ID__c).Trim__c;
                         
                    }
                    else
                    {
    
                       newOfferEligModelRec.Name=stgmodeltocheck.Model_Group_Name__c;
                       newOfferEligModelRec.Model__c=stgmodeltocheck.Model_Group_Name__c;
                       newOfferEligModelRec.Trim__c=stgmodeltocheck.Model_Marketing_Name__c;
                    }
                    //newOfferEligModelRec.Alternate_Offer_Eligible_Model_Id__c=stgmodeltocheck.b2c_Offer_Id__c+'~'+string.valueof(integer.valueof(newofferversionrec.Version_Number__c))+'~'+stgmodeltocheck.Model_Id__c;
                    newofferModelsList.add(newOfferEligModelRec);                
    
                }
            }
            //else
            //{

                
                
                
               /* if (offerversiontocheck.Start_Date__c!=offertoproc.Start_Date__c || offerversiontocheck.End_Date__c!=offertoproc.End_Date__c ||offerversiontocheck.PRISM_Offer_Status__c<>offertoproc.PRISM_Offer_Status__c)
                {
                    offerversiontocheck.PRISM_Offer_Status__c=offertoproc.PRISM_Offer_Status__c;
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
                        offerversiontocheck.PRISM_Offer_Status__c=offertoproc.PRISM_Offer_Status__c;
    
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
                    
            /*        system.debug('Offer Status='+offerversiontocheck.Status__c+',End Date='+offerversiontocheck.End_Date__c+',Start Date='+offerversiontocheck.Start_Date__c);
                    oldofferversionlst.add(offerversiontocheck);
                    
                //}


            }*/

            if (!createnewversion && (oldofferversionlst==null || oldofferversionlst.size()<1))
            {
               //Nothing to Process on the offer - Lets mark STG as Erro
               offertoproc.Processing_Status__c='Error';
               offertoproc.Processing_Message__c='No Changes Found for Processing';
               offertoproc.Reprocess__c=false;
               offertoproc.Processing_Date__c=System.now();

            }


		}
	        //Finally after all the manipulation - do the thing and capture errors
        //Update Old Version
        if (oldofferversionlst!=null && oldofferversionlst.size()>0)
        {
            List<SObject> oldofferrecord=new List<SObject>();
            oldofferrecord.addAll(oldofferversionlst);
            try {

                update oldofferrecord;
                UpdateSTGOfferProcessingStatus.setstatusonstgrecords(offheaderlst,'Success','Update Scenario - Old Offers Succeed',stgoffmap);
    
            }
            catch (DMLException e)
            {
                UpdateSTGOfferProcessingStatus.setstatusonstgrecords(offheaderlst,'Failures',e.getMessage(),stgoffmap);
            }
        }
    
        if (newofferversionlst!=null && newofferversionlst.size()>0 && newofferModelsList.size()>0 && newofferModelsList!=null)
        {
            List<SObject> newofferrecord=new List<SObject>();
            newofferrecord.addAll(newofferversionlst);
            newofferrecord.addAll(newofferModelsList);
            Savepoint sp = Database.setSavepoint();
            try{
                insert newofferrecord;
                UpdateSTGOfferProcessingStatus.setstatusonstgrecords(offheaderlst,'Success','Update Scenario - New Version Succeeded',stgoffmap);
            }
            catch(DMLException e)
            {
                Database.rollback(sp);
                UpdateSTGOfferProcessingStatus.setstatusonstgrecords(offheaderlst,'Failures',e.getMessage(),stgoffmap);
            }
        }


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

}
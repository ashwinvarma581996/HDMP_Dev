//****************************************************************************** 
// File Name:       STGOfferTriggerHelper.cls
// Summary:         Apex Class for to Retrieve inbound Offer Feed Records and Process
// Created On:      02-22-2023
// Created By:      Rama Iyer
// Test Classes:    OfferManagmentInboundProcessing_Test.cls
// JIRA Story :     OMP-156,OMP-76,OMP-104,OMP-103
// Method Names :seperateNewandMatchingRecords - Takes the Incoming Records and Calls the two other Classes for processing
// Calls to Other Classes :  
// 1. OfferFeedInbMatchedSubFlow : This Apex Class is called for Processing Update Scenarios of Offer - B2C Offer Id matched with Offer Identifier Field on Offer Header
// 2. OfferFeedInbNewOffers : This Apex Class is Called for Processing New Records - B2C Offer Id no match with any Offer Header records
//===============================================================================
public class STGOfferTriggerHelper {
    
    public void seperateNewandMatchingRecords(List<STG_Offers__c> lstStgOffers){
        
        List<Offer_Header__c> offerHeadersMatchinglst=new List<Offer_Header__c>();
        List<Offers__c> offersmatchinglst=new List<Offers__c>();
        List<Offer_ELigible_Models__c> offerEligModelslst=new List<Offer_ELigible_Models__c>();
        List<STG_Offers__c> matchingSTGOfferslst=new List<STG_Offers__c>();
        List<STG_Offer_Eligible_Models__c> matchingSTGOffEligModlst=new List<STG_Offer_Eligible_Models__c>();
        List<STG_Offers__c> nonmatchingSTGOfferslst=new List<STG_Offers__c>();
        List<STG_Offer_Eligible_Models__c> nonmatchingSTGOffEligModlst=new List<STG_Offer_Eligible_Models__c>();
        Map<String,Offer_Header__c> offerheadermap=new Map<String,Offer_Header__c>();
        Map<String,String> stgofferrecordstatus=new Map<String,String>();
        List<STG_Offer_Eligible_Models__c> inputSTGModelsLst=new List<STG_Offer_Eligible_Models__c>();
        Map<String,STG_Offers__c> recordstoProcess=new Map<String,STG_Offers__c>();

        
        Set<String> b2cofferIdstoProcess=new Set<String> ();
        //Lets get all the fields for Offer Header, Offer and Offer Eligible Models
		Schema.DescribeSObjectResult offheader  = Offer_Header__c.SObjectType.getDescribe();
		Map<String, Schema.SObjectField> offheadfieldMap = offheader.fields.getMap();

        Schema.DescribeSObjectResult offver  = Offers__c.SObjectType.getDescribe();
		Map<String, Schema.SObjectField> offverfieldmap = offver.fields.getMap();

        Schema.DescribeSObjectResult offerEligibleModel  = Offer_Eligible_Models__c.SObjectType.getDescribe();
		Map<String, Schema.SObjectField> offerEligibleModelfldMap = offerEligibleModel.fields.getMap();
        
        Schema.DescribeSObjectResult stgofferEligibleModel  = STG_Offer_Eligible_Models__c.SObjectType.getDescribe();
		Map<String, Schema.SObjectField> stgofferEligibleModelfldMap = stgofferEligibleModel.fields.getMap();
        
        Set<String> b2cofferIdstoQuery=new Set<String>();
        Set<String> modelids=new Set<String>();
        Set<String> modelautonumberstoQuery=new Set<String>();
        //fetch model Ids and offer ids with max Auto Number to get latest value

        Map<Id,Integer> noofmodelsperoffer=new Map<Id,Integer>();

        Map<Id,List<STG_Offer_Eligible_Models__c>> nonmatchedmodels=new Map<Id,List<STG_Offer_Eligible_Models__c>>();
        Map<Id,List<STG_Offer_Eligible_Models__c>> matchedmodels=new Map<Id,List<STG_Offer_Eligible_Models__c>>();
        Map<Id,List<Offers__c>> currentOffersMap=new Map<Id,List<Offers__c>>();
        Map<Id,List<Offer_Eligible_Models__c>> currentOfferModelsMap=new Map<Id,List<Offer_Eligible_Models__c>>();

        
        
        String offheadQuery='';
        String offverquery='';
        String offEligModelQuery='';
        String stgOffEligModelQuery='';
        
        for( String offheadfld : offheadfieldMap.keySet() )
        {
                Schema.SObjectField field = offheadfieldMap.get( offheadfld );
   			    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                offheadQuery+=fieldDescribe.getName()+',';
        }
        for( String offverfld : offverfieldmap.keySet() )
        {
                Schema.SObjectField field = offverfieldmap.get( offverfld );
   			    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                offverquery+=fieldDescribe.getName()+',';
        }
        for( String offEligModelfld : offerEligibleModelfldMap.keySet() )
        {
                Schema.SObjectField field = offerEligibleModelfldMap.get( offEligModelfld );
   			    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                offEligModelQuery+=fieldDescribe.getName()+',';
        }
        for( String stgoffereligmod : stgofferEligibleModelfldMap.keySet() )
        {
                Schema.SObjectField field = stgofferEligibleModelfldMap.get( stgoffereligmod );
   			    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                //Changed below line for 04/14/2023 by Rama Iyer to Dedup the STG Offer Eligible Model Records
                stgOffEligModelQuery+=fieldDescribe.getName()+',';
        }
        String ProcessingStatus='New';
        offheadQuery='Select '+offheadQuery+'from Offer_Header__c'.replace(',from',' from');
		offheadQuery=offheadQuery.replace(',from', ' from');
        offverquery='Select '+offverquery+'from Offers__c'.replace(',from',' from');
        offverquery=offverquery.replace(',from', ' from');
        offEligModelQuery='Select '+offEligModelQuery+'from Offer_Eligible_Models__c'.replace(',from',' from');
        offEligModelQuery=offEligModelQuery.replace(',from', ' from');
        stgOffEligModelQuery='Select '+stgOffEligModelQuery+'from STG_Offer_Eligible_Models__c'.replace(',from',' from');
        stgOffEligModelQuery=stgOffEligModelQuery.replace(',from', ',STG_Offer__r.Processing_Status__c,STG_Offer__r.Reprocess__c,STG_Offer__r.Offer_Record_type__c,STG_Offer__r.Brand__c from');
        List<Id> stgofferrecordIds=new List<Id>();
        for (STG_Offers__c stgoffertoproc:lstStgOffers)
        {
			if (stgoffertoproc.Processing_Status__c=='New' || stgoffertoproc.Reprocess__c==TRUE)
            {
                b2cofferIdstoProcess.add(stgoffertoproc.B2C_Offer_Id__c);  
                stgofferrecordIds.add(stgoffertoproc.Id);
            } 
            
        }
        
        
        //system.debug('QUery='+offheadQuery);
        Date stgmodeldate=System.today();
        String modelprocessingstatus='New';
        offerHeadersMatchinglst=Database.query(offheadQuery+' where Offer_Identifier__c in :b2cofferIdstoProcess');
        //inputSTGModelsLst=Database.query(stgOffEligModelQuery+' where B2C_Offer_Id__c in :b2cofferIdstoProcess');
        inputSTGModelsLst=Database.query(stgOffEligModelQuery+' where STG_Offer__c in :stgofferrecordIds');

        system.debug('Input STG MOdels Query='+inputSTGModelsLst);
        if (offerHeadersMatchinglst.size()>0 && offerHeadersMatchinglst!=null)
        {
            offersmatchinglst=Database.query(offverquery+' where Offer_Identifier__c in :b2cofferIdstoProcess');
            
            offerEligModelslst= Database.query(offEligModelQuery+' where Offer_Identifier__c in :b2cofferIdstoProcess ');
                            
        }
        List<String> foundofferids=new List<String>();
        for (Offer_Header__c offheaderrec:offerHeadersMatchinglst)
        {
            offerheadermap.put(offheaderrec.Offer_Identifier__c,offheaderrec);
        }
        
        for (STG_Offers__c stgoffertoproc:lstStgOffers)
        {
            if (stgoffertoproc.Processing_Status__c=='New' || stgoffertoproc.Reprocess__c==TRUE){

                List<Offers__c> currentoffers=new List<Offers__c>();
               
                
                if (offerheadermap.get(stgoffertoproc.b2c_offer_Id__c)!=null)
                {
                    matchingSTGOfferslst.add(stgoffertoproc);
                }
                else
                {
                    nonmatchingSTGOfferslst.add(stgoffertoproc);
                }
                recordstoProcess.put(stgoffertoproc.b2c_offer_Id__c,stgoffertoproc);
                Integer noofmodels=0;

                for(Offers__c curroffer:offersmatchinglst)
                {
                    if (curroffer.Offer_Identifier__c==stgoffertoproc.b2c_Offer_Id__c)
                    {
                        currentoffers.add(curroffer);
                    }
                    List<Offer_Eligible_Models__c> currentoffermodels=new List<Offer_Eligible_Models__c>();
                    for(Offer_Eligible_Models__c curroffermods:offerEligModelslst)
                    {
                        if (curroffermods.Offer__c==curroffer.Id)
                        {
                            currentoffermodels.add(curroffermods);
                        }
    
                    }
                    currentOfferModelsMap.put(curroffer.Id,currentoffermodels);

                }
                currentOffersMap.put(stgoffertoproc.Id,currentoffers);

               

                for (STG_Offer_Eligible_Models__c stgmodeltoproc:inputSTGModelsLst)
                {
                    system.debug('stgmodeltoproc.b2c_offer_Id__c='+stgmodeltoproc.b2c_offer_Id__c);
                    noofmodels++;
                    //if (recordstoProcess.get(stgmodeltoproc.b2c_offer_Id__c)!=null && (recordstoProcess.get(stgmodeltoproc.b2c_offer_Id__c).Processing_Status__c=='New' ||  recordstoProcess.get(stgmodeltoproc.b2c_offer_Id__c).Reprocess__c==true))
                    if (stgmodeltoproc.STG_Offer__c!=null && stgmodeltoproc.STG_Offer__c==stgoffertoproc.Id)
                    {
                        if (offerheadermap.get(stgmodeltoproc.b2c_offer_Id__c)!=null)
                        {
                            matchingSTGOffEligModlst.add(stgmodeltoproc);
                        }
                        else
                        {
                            nonmatchingSTGOffEligModlst.add(stgmodeltoproc);
                        }
                       // noofmodelsperoffer.put(recordstoProcess.get(stgmodeltoproc.b2c_offer_Id__c).Id,1);
                        
                    }
                    nonmatchedmodels.put(stgoffertoproc.Id,nonmatchingSTGOffEligModlst);
                    matchedmodels.put(stgoffertoproc.Id,matchingSTGOffEligModlst);
                 
        
                }
                if(noofmodels<1)
                {
                    stgoffertoproc.Processing_Status__c='Error';
                    stgoffertoproc.Processing_Message__c='Error : No Models Loaded for the Offer';
                    stgoffertoproc.Reprocess__c=false;
                    stgoffertoproc.Processing_Date__c=System.now();
                }
                
            }

        }




        //}
        //Processing Matching Offers
        /*if (matchingSTGOfferslst!=null && matchingSTGOfferslst.size() > 0){
            
                OfferFeedInbMatchedSubFlow.FlowInput flowinputs;
                flowinputs=new OfferFeedInbMatchedSubFlow.FlowInput();
                flowinputs.offertoProcess=matchingSTGOfferslst;
                flowinputs.offerEligibleModelsProcess=matchingSTGOffEligModlst;
                flowinputs.currentEligibleModels=offerEligModelslst;
                flowinputs.currentOffer=offersmatchinglst;
                
           	    OfferFeedInbMatchedSubFlow.processExistingOffers(new List<OfferFeedInbMatchedSubFlow.FlowInput> {flowinputs});
            
        }*/
        if(matchedmodels.size()>0 && matchingSTGOfferslst!=null && matchingSTGOfferslst.size() >0 && matchedmodels!=null )
        {
            OfferFeedInbMatchedSubFlow2.processExistingOffers(matchingSTGOfferslst,matchedmodels,offerheadermap,currentOffersMap,currentOfferModelsMap);
        }
		if (nonmatchingSTGOfferslst!=null && nonmatchedmodels.size() > 0){
            
                /*OfferFeedInbNewOffers.FlowInput flowinputs;
                flowinputs=new OfferFeedInbNewOffers.FlowInput();
                flowinputs.offertoProcess=nonmatchingSTGOfferslst;
            	flowinputs.offerEligibleModelsProcess=nonmatchingSTGOffEligModlst;
                OfferFeedInbNewOffers.processNewInboundOffers(new List<OfferFeedInbNewOffers.FlowInput> {flowinputs});*/
                OfferFeedInbNewOffer2.processNewInboundOffers(nonmatchingSTGOfferslst,nonmatchedmodels);
        }
        
        
    } 

}
//****************************************************************************** 
// File Name:       UpdateSTGOfferProcessingStatus.cls
// Summary:         Inserts Records into Error Framework, Notifies Support and also updates the Stage Offer Processing Status
// Created On:      03-13-2023
// Created By:      Rama Iyer
// Test Classes:    OfferManagmentInboundProcessing_Test.cls
// JIRA Story :     OMP-156,OMP-76,OMP-104,OMP-103
//===============================================================================
public class UpdateSTGOfferProcessingStatus {
    //Below method commented by Rama Iyer on 04/21/2023
    
    /*public static List<StG_Offers__c> collectStgRecordstoUpdate(Map<String,STG_Offers__c> stgoffmap,
                                    Map<String,String> recordIdMaps,
                                    String insertobject,
                                    List<SObject> objecttoproclst,
                                    Database.SaveResult[] resultlst,Map<String,STG_Offer_Eligible_Models__c> stgoffeligmap)
    {
        //Verify if Offer Header Inserted/Updated Successfully
        //Mark Failures for Offer Header Insert
        List<STG_Offers__c> stgrecordstoupdatesucces=new List<STG_Offers__c>();
        List<STG_Offers__c> stgrecordupdatefailures=new List<STG_Offers__c>();
        List<STG_Offers__c> returnlist=new List<STG_Offers__c>();
        Set<STG_Offer_Eligible_Models__c> stgeligmodelstoupdateset=new Set<STG_Offer_Eligible_Models__c> ();
        List<STG_Offer_Eligible_Models__c> stgeligmodelstoupdate=new List<STG_Offer_Eligible_Models__c> ();
        STG_Offer_Eligible_Models__c eligmodelrecord=new STG_Offer_Eligible_Models__c();

        system.debug('List of offer Eligible Models='+objecttoproclst.size());
        //Map<String,STG_Offer_Eligible_Models__c> stgeligmodelstoupdate=new Map<String,STG_Offer_Eligible_Models__c>();
        Set<String> offerModelids=new Set<String>();
        //Map<String,STG_Offers__c> stgoffmap=new Map<String,STG_Offers__c>();
        Integer sizeofprocessing=resultlst.size();
        Set<Id> successrecords=new Set<Id>();
        //system.debug('Eligible MOdel STG Records size='+stgoffeligmap.size());
        //Debug only

        for (Integer i=0;i<sizeofprocessing;i++)
        {
            String recordIdGetAppropriate;
            if(insertobject=='Offer_Eligible_Models__c')
            {
                recordIdGetAppropriate=(String) objecttoproclst.get(i).get('Alternate_Offer_Eligible_Model_Id__c');
                eligmodelrecord=stgoffeligmap.get(recordIdGetAppropriate);
                system.debug('Eligible MOdel Record='+eligmodelrecord.Id);
                
            }
            else if(insertobject=='Offers__c'||insertobject=='OldOfferVersion')
            {
                recordIdGetAppropriate=(String)  objecttoproclst.get(i).get('Alternate_Offer_Identifier__c');
            }
            else if(insertobject=='Offer_Header__c')
            {
                recordIdGetAppropriate=(String)  objecttoproclst.get(i).get('Offer_Identifier__c');
            }

            STG_Offers__c processingOffer=stgoffmap.get(recordIdMaps.get(recordIdGetAppropriate));
            if(resultlst.get(i).IsSuccess()  )
            {
                //get the b2coffer id record
               processingOffer.Processing_Status__c='Success';
               processingOffer.Processing_Message__c='Processing Succeeded';
               processingOffer.Processing_Date__c=System.now();
               processingOffer.Reprocess__c=false;
               stgrecordstoupdatesucces.add(processingOffer);
               if (eligmodelrecord!=null && insertobject=='Offer_Eligible_Models__c' )
               {
                    eligmodelrecord.Model_Processing_Status__c='Success';
                    eligmodelrecord.Salesforce_ID_of_Offer__c=processingOffer.Id;
                    stgeligmodelstoupdateset.add(eligmodelrecord);

               }
               else if ( insertobject=='OldOfferVersion')
               {
                    for (String offerkey:stgoffeligmap.keySet())
                    {
                        STG_Offer_Eligible_Models__c eligmodelrecordoff=new STG_Offer_Eligible_Models__c();
                        eligmodelrecordoff=stgoffeligmap.get(offerkey);
                        if(eligmodelrecordoff.b2c_Offer_Id__c==processingOffer.b2c_Offer_Id__c)
                        {
                            eligmodelrecordoff.Model_Processing_Status__c='Success';
                            stgeligmodelstoupdateset.add(eligmodelrecordoff);
                        }

                    }

               }
            }
            else
            {
                Database.Error error = resultlst.get(i).getErrors().get(0);
                STG_Offers__c failedoffer=new STG_Offers__c();
                String dmlerrormessage;
                if (insertobject=='Offer_Eligile_Models__c')
                {
                    //get Offer Id of the failed eligible models and then corresponding header Id and then the STG Offer Id based on
                    
                    System.debug('Error Occurs While Processing The Record'+error.getMessage()); 
                    dmlerrormessage='Failed to Process Models for ='+error.getMessage();
                    String errorModelSTG=(String) objecttoproclst.get(i).get('Alternate_Offer_Eligible_Model_Id__c');
                    eligmodelrecord=stgoffeligmap.get(errorModelSTG);

                    System.debug('Error Model='+errorModelSTG);
                    failedoffer=stgoffmap.get(recordIdMaps.get(errorModelSTG));

                    eligmodelrecord.Model_Processing_Status__c='Error';
                    eligmodelrecord.Salesforce_ID_of_Offer__c=failedoffer.Id;
                    stgeligmodelstoupdateset.add(eligmodelrecord);
                   
                }
                else if (insertobject=='Offers__c'||insertobject=='OldOfferVersion')
                {
                    dmlerrormessage='Failed to Process Offer Versions for ='+error.getMessage();
                    String offerversion=(String)  objecttoproclst.get(i).get('Alternate_Offer_Identifier__c');
                    failedoffer=stgoffmap.get(recordIdMaps.get(offerversion));
                    for (String offerkey:stgoffeligmap.keySet())
                    {
                        STG_Offer_Eligible_Models__c eligmodelrecordoff=new STG_Offer_Eligible_Models__c();
                        eligmodelrecordoff=stgoffeligmap.get(offerkey);
                        if(eligmodelrecordoff.b2c_Offer_Id__c==failedoffer.b2c_Offer_Id__c)
                        {
                            eligmodelrecordoff.Model_Processing_Status__c='Error';
                            stgeligmodelstoupdateset.add(eligmodelrecordoff);
                        }

                    }
                }
                else if (insertobject=='Offer_Header__c') 
                {
                    dmlerrormessage='Failed to Process Offer Headers for ='+error.getMessage();
                    String offerheader=(String)  objecttoproclst.get(i).get('Offer_Identifier__c');
                    failedoffer=stgoffmap.get(recordIdMaps.get(offerheader));
                    
                }
                failedoffer.Processing_Status__c='Error';
                failedoffer.Processing_Message__c=dmlerrormessage;
                failedoffer.Processing_Date__c=System.now();
                stgrecordupdatefailures.add(failedoffer);
                failedoffer.Reprocess__c=false;

            }
        }
    system.debug('Success Records='+stgrecordstoupdatesucces);
    returnlist.addAll(stgrecordupdatefailures);
    returnlist.addAll(stgrecordstoupdatesucces);
    system.debug('Returned Records for Processing='+returnlist);

    if (stgeligmodelstoupdateset!=null && stgeligmodelstoupdateset.size()>0)
    {
        stgeligmodelstoupdate.addAll(stgeligmodelstoupdateset);//dedup the records
        try {
            update stgeligmodelstoupdate;
        }
        catch(Dmlexception e)
        {
            system.debug('Unable to Update Model Status='+e.getMessage());
            B2B_Util.createErrorRecord('Error in Processing Offer Inbound Feed Model Status',e.getMessage(),110,'UpdateSTGOfferProcessingStatus','collectStgRecordstoUpdate'); 
        }
    }
    
    return returnlist;
    }*/

    public static void setstatusonstgrecords(List<SObject> offerrecords,String statustype,String message,Map<String, STG_Offers__c> stgoffmap)
    {
        for(SObject offobject:offerrecords)
        {
            //String sObjName = offobject.Id.getSObjectType().getDescribe().getName();
            switch on offobject {

                when Offer_Header__c offhead {

                    STG_Offers__c stgoffer= stgoffmap.get(offhead.Offer_Identifier__c);
                    if (statustype=='Success')
                    {
                        stgoffer.Processing_Status__c='Success';
                        
                    }
                    else
                    {
                        stgoffer.Processing_Status__c='Error';
                        stgoffer.Processing_Message__c=message.left(255);
                    }
                    stgoffer.Reprocess__c=false;
                    stgoffer.Processing_Date__c=System.now();
                    system.debug('Message='+message);
                    stgoffer.Processing_Message__c=message.left(255);
                }
            }
        }
    }
}
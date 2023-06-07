public class OfferTriggerHelper {
    /****************************************************************************
* Description: This method will update Sequence number on offer object based on Offer Header obj
* Name: Siva T
* ***************************************************************************/
    public void updateSequenceNumber(List<Offers__c> lstOfferNew) { 
        set<id> setHeaderIds = new set<id>();
        for(Offers__c off:lstOfferNew){
            setHeaderIds.add(off.Offer_Header__c);
        }
        list<Offers__c> lstToUpdaateOff = new list<Offers__c>();    
        if(setHeaderIds.isEmpty()){
            return ;
        }
        List<Offer_Header__c> lstHeader =[select id,(select id from Offer__r),Offer_Identifier__c from Offer_Header__c where id in:setHeaderIds];
        if(lstHeader.size()>0){
            for(Offer_Header__c header:lstHeader){
                integer index =0;
                system.debug('#$# offer size:'+header.Offer__r.size());
                for(Offers__c off:header.Offer__r){
                    off.Version_Number__c = index+1;
                    off.Alternate_Offer_Identifier__c = header.Offer_Identifier__c!=null?header.Offer_Identifier__c+'~'+off.Version_Number__c:header.Id+'~'+off.Version_Number__c;
                    lstToUpdaateOff.add(off);
                    index++;
                }
            }
        }
        try{
            update lstToUpdaateOff;  
        }catch(exception ex){
            system.debug('ex'+ex.getTypeName());
        }
        
        
    }
    /*************************************************************
* Description: this method will create Offer Header record based on input field values of offer
* *************************************************************************/
    public List<Offer_Header__c> CreateOfferHeader(List<Offers__c> lstOfferNew,id recId) {
        List<Offer_Header__c> lstHeader = new List<Offer_Header__c>();
        if(lstOfferNew.isempty()){
            return new List<Offer_Header__c>();
        }
        
        for(Offers__c offObj:lstOfferNew){
            if(offObj.Custom_clone__c == false ){
                Offer_Header__c headerobj = new Offer_Header__c();  
                headerobj.Name = offObj.Name+'_Clone';
                headerobj.Descriptive__c =offObj?.Descriptive_Name__c;
                headerobj.Offer_Type__c= offObj.Offer_Type__c;
                headerobj.Brand__c  = offObj?.Brand__c;                
                headerobj.RecordTypeId = recId;
                system.debug('headerobj.RecordTypeId'+recId);
                lstHeader.add(headerobj); 
            }
        }
        if(lstHeader.size()>0){
            try{
                // insert lstHeader;   
            }catch(exception ex){
                system.debug('=========='+ex.getMessage());
                //displayErrorMessage(lstOfferNew);
            } 
            
        } 
        return lstHeader;
    }
    /****************************************************************
* Description: This method update default boilerplate based on specific condition
* ************************************************************************/
    Public  void updateDefaultBoilerPlate(List<Offers__c> lstOffer){
        Map<string,Id> MapOffBlr = BoilerPlateDefault.defBlrPlateBasedonOfferListforUI(lstOffer); 
        system.debug('#@#@#@#MapOffBlr '+MapOffBlr);
        set<id> setBoilerplatesids = new set<id>();
        for(Offers__c offobj:lstOffer){
            setBoilerplatesids.add(MapOffBlr?.get(offobj.Offer_Header__c));
        }
        system.debug('setBoilerplatesids'+setBoilerplatesids);
        Map<id,Boilerplate__c> mapboile = getboilerplate(setBoilerplatesids);	
        for(Offers__c offobj:lstOffer){
            system.debug('+++++++++++++'+mapboile);
            if(MapOffBlr.containsKey(offobj.Offer_Header__c)){
                if( offobj.Boilerplate__c == null){
                offobj.Boilerplate__c =MapOffBlr?.get(offobj.Offer_Header__c);   
                string boilerplateid = offobj.Boilerplate__c;
                offobj.Offer_Title__c = mapboile.get(boilerplateid)?.Offer_Title__c;
                string shortDesc = mapboile.get(boilerplateid)?.Short_Description__c;
                /*if(shortDesc != null && shortDesc.length() > 200){
                    offobj.Short_Description__c = shortDesc.substring(0,200);
                } else {
                    offobj.Short_Description__c =mapboile.get(boilerplateid)?.Short_Description__c;
                }*/
                     /*if(term != null){
                    if(term.length()>255){
                        term = term.substring(0,255);
                    }
                    
                    offobj.Terms_and_Conditions__c = term;  
                }*/ //Comment for datatype change
                    
                    offobj.Short_Description__c =mapboile.get(boilerplateid)?.Short_Description__c;
                    
                    offobj.Detailed_Description__c = mapboile.get(boilerplateid)?.Detailed_Description__c;
                    offobj.Status__c='WIP';
                    string  term = mapboile.get(offobj.Boilerplate__c)?.Terms_Descriptions__c;
                    if(term != null){
                        offobj.Terms_and_Conditions__c = term;
                    }
                    
                    
                    
                    offobj.Legal_Desclaimer__c =  mapboile.get(boilerplateid)?.Legal_Disclaimer__c;
            }
        }
        }
    }
    /****************************************************************
* Description: This method will create child record which are associate to offer
* ************************************************************************/
    Public  void CreateChildrecordsBasedOnOldOffer(List<Offers__c> lstOffer){
        if(lstOffer.size()>0){
            for(Offers__c offobj:lstOffer){
                if(offobj.isClone()){
                    CloneOfferRelatedObjectHelper.eligiblemodelClone(offobj.id,offobj.getCloneSourceId());
                    // CloneOfferRelatedObjectHelper.eligibleRegionClone(offobj.id,offobj.getCloneSourceId());
                }
                
            } 
        } 
    }  
    /**********************************************************************************
* Description:This method will update offer header Name 
* ******************************************************************************/
    public  void updateOfferHeader(List<Offers__c> lstOffer){
        set<id> SetHeaderids = new set<id>();
        for(Offers__c offobj:lstOffer){
            if(offobj.Offer_Header__c != null && offobj.isClone()){
                SetHeaderids.add(offobj.Offer_Header__c);
            }
        }
        if(!SetHeaderids.isempty()){
            Map<id,Offer_Header__c> mapHeader = new Map<id,Offer_Header__c>([SELECT Name, Id FROM Offer_Header__c WHERE ID IN:SetHeaderids]);
            for(Offers__c offobj:lstOffer){
                mapHeader.get(offobj.Offer_Header__c).Name = offobj.Name+'_Clone';
            }
            try{
                update mapHeader.values(); 
            } catch(exception ex){
                system.debug('exception'+ex.getMessage());
            }
            
        }       
    }  
    /**********************************************************************************
* Description:This method will update offer record cloned ID
* ******************************************************************************/
    public void updateOfferRecord(List<Offers__c> lstOffer,Map<ID,SObject> newOfferMap){
        set<id> offerids = new set<id>();
        List<Offers__c> cloneCopyOfOffer = new list<Offers__c>();
        //List<Offers__c> lstoffers = new List<Offers__c>();
        for(Offers__c offobj:lstOffer){
            offerids.add(offobj.getCloneSourceId());
        }
        Map<id,Offers__c> offerMap = getOfferRecords(offerids);
        List<Offer_Header__c> lstHeader;
        
        for(Offers__c offobj:lstOffer){
            if(offobj.isclone()){
                string recId = offerMap.get(offobj.getCloneSourceId()).RecordTypeid;
                string  recname  =Schema.getGlobalDescribe().get('Offers__c').getDescribe().getRecordTypeInfosById().get(recId).getName();
                Id rectypeId = Schema.SObjectType.Offer_Header__c.getRecordTypeInfosByName().get(recname).getRecordTypeId();
                system.debug('offer rec type Id '+rectypeId);  
                 system.debug('offer rectypeId'+recId +'::header rec type id:'+rectypeId);  
                lstHeader = CreateOfferHeader(lstOffer,rectypeId);
            }
        }
        if(lstHeader!=null && lstHeader.size()>0){
            try{
                insert lstHeader;
            }catch(exception ex){
                //displayErrorMessage(lstOffer,ex.getDmlMessage(0));
                system.debug('###Error:'+ex.getMessage());
            }
        }
        
        for(Offers__c offobj:lstOffer){
      
            if(offobj.isclone()){
                for(Offer_Header__c header:lstHeader){
                    offobj.ClonedSourceID__c= offobj.getCloneSourceId();
                    offobj.RecordTypeId = offerMap.get(offobj.ClonedSourceID__c).RecordTypeId;
                    system.debug('RecordTypeId'+offobj.RecordTypeId);
                    offobj.Offer_Header__c = header.id;
                    offobj.Name = header.Name;
                    offobj.Status__c = 'WIP';
                    offobj.Synched_with_PRISM__c =false;
                    offobj.PRISM_Offer_Status__c = null;
                    offobj.Preview__c = false;
                    offobj.Brand__c = offerMap.get(offobj.ClonedSourceID__c).Brand__c;
                    offobj.Offer_Availability__c = offerMap.get(offobj.ClonedSourceID__c).Offer_Availability__c;
                    if(offobj.Offer_Availability__c == 'Regional'){
                        offobj.Group_Type__c = offerMap.get(offobj.ClonedSourceID__c).Group_Type__c;
                        offobj.Group_Code__c = offerMap.get(offobj.ClonedSourceID__c).Group_Code__c;
                        offobj.AHM_Regions__c = offerMap.get(offobj.ClonedSourceID__c).AHM_Regions__c;
                    }
                    if(offobj.Sales_Program_CD__c != null){
                        offobj.Sales_Program_CD__c = null;   
                    }
                    if( offobj.AHFC_Sales_Program_ID__c != null){
                        offobj.AHFC_Sales_Program_ID__c=null; 
                    }
                    if(offobj.AHM_Sales_Program_ID__c != null){
                        offobj.AHM_Sales_Program_ID__c=null;
                    }
                   
                    if(offerMap.get(offobj.getCloneSourceId()).Boilerplate__c!=null){
                        offobj.Offer_Title__c = offerMap.get(offobj.ClonedSourceID__c).Offer_Title__c;
                        offobj.Boilerplate__c = offerMap.get(offobj.ClonedSourceID__c).Boilerplate__c;
                        offobj.Short_Description__c = offerMap.get(offobj.ClonedSourceID__c).Short_Description__c;
                        offobj.Detailed_Description__c = offerMap.get(offobj.ClonedSourceID__c).Detailed_Description__c;
                        offobj.Terms_and_Conditions__c = offerMap.get(offobj.ClonedSourceID__c).Terms_and_Conditions__c;
                        offobj.Legal_Desclaimer__c = offerMap.get(offobj.ClonedSourceID__c).Legal_Desclaimer__c;
                    }
                    if(offerMap != null &&  offerMap.get(offobj.ClonedSourceID__c) != null && offerMap.get(offobj.ClonedSourceID__c).Dealer_Contribution__c != null  ){
                        offobj.Dealer_Contribution__c = offerMap.get(offobj.ClonedSourceID__c).Dealer_Contribution__c;
                    }
                    if(offerMap != null &&  offerMap.get(offobj.ClonedSourceID__c) != null && offerMap.get(offobj.ClonedSourceID__c).Loyalty_Cash__c != null  ){
                        offobj.Loyalty_Cash__c = offerMap.get(offobj.ClonedSourceID__c).Loyalty_Cash__c;
                    }
                    if(offerMap != null &&  offerMap.get(offobj.ClonedSourceID__c) != null && offerMap.get(offobj.ClonedSourceID__c).Additional_Cash__c != null  ){
                        offobj.Additional_Cash__c = offerMap.get(offobj.ClonedSourceID__c).Additional_Cash__c;
                    }
                    if(offerMap != null &&  offerMap.get(offobj.ClonedSourceID__c) != null && offerMap.get(offobj.ClonedSourceID__c).Captive_Cash__c != null  ){
                        offobj.Captive_Cash__c = offerMap.get(offobj.ClonedSourceID__c).Captive_Cash__c;
                    }
                    if(offerMap != null &&  offerMap.get(offobj.ClonedSourceID__c) != null && offerMap.get(offobj.ClonedSourceID__c).Conquest_Cash__c != null  ){
                        offobj.Conquest_Cash__c = offerMap.get(offobj.ClonedSourceID__c).Conquest_Cash__c;
                    }
                    if(offerMap != null &&  offerMap.get(offobj.ClonedSourceID__c) != null && offerMap.get(offobj.ClonedSourceID__c).Other_Captive_Cash__c != null  ){
                        offobj.Other_Captive_Cash__c = offerMap.get(offobj.ClonedSourceID__c).Other_Captive_Cash__c;
                    }
                }
            }
        }
       
        
        
    }
/**************************************************
* Description: this method will show error message
* ***********************************************/
    public void displayErrorMessage(List<Offers__c> lstOffer,string error){
        for(Offers__c offobj:lstOffer){
            offobj.Adderror(error);
        }
    }
    
    
    
    /**************************************************
* Description: this method will make outnbound integration callout to eshopping 
* ***********************************************/
    public void outboundIntegrationCallout(List<Offers__c> lstOffer,Map<ID, SObject> oldOfferMap)
    {
        set<string> allowStatusValues = new set<string>{'Submitted','Approved'};
        map<Id,Offers__c> mapLatestOffer = getLatestOffer(lstOffer);
        Offers__c latestOfferRec;
        if(oldOfferMap !=null)
        {
            map<Id,Offers__c> oldMap = (map<Id,offers__c>)oldOfferMap;
            List<Offers__c> lstOffertoSend = new List<Offers__c>();           
            for(Offers__c offerRec:lstOffer)
                {
                    if(oldMap.get(offerRec.Id).status__c !=null && allowStatusValues.contains(offerRec.Status__c) && oldMap.get(offerRec.Id).Status__c !=offerRec.Status__c && OfferRec.Latest_Version__c == true)
                    {
                     	//System.enqueuejob(new  OfferOutboundQueue(lstOffer)); 
                     	lstOffertoSend.add(offerRec);
                    }
                     //Manohar : Added below condition to handle delete scenarios
                     else if(oldMap.get(offerRec.Id).status__c !=null && offerRec.Status__c =='Expired' && oldMap.get(offerRec.Id).Status__c !=offerRec.Status__c)
                     {
                        system.debug('### Expired offer :'+offerRec.Latest_Version__c+':'+offerRec.Integration_status__c);
                        if(offerRec.Latest_Version__c == true)
                        {
                            if(OfferRec.Integration_status__c == 'Success')
                            {
                                lstOffertoSend.add(offerRec);
                            }
                                                  
                        }
                        else
                        {
                            if(mapLatestOffer !=null && mapLatestOffer.containsKey(offerRec.offer_header__c))
                            {
                                latestOfferRec = mapLatestOffer.get(offerRec.offer_header__c); 
                            }
                            if(OfferRec.Integration_status__c == 'Success' && latestOfferRec !=null && latestOfferRec.Integration_status__c == null)
                            {
                                lstOffertoSend.add(offerRec); 
                            }
                        }
                        
                     }
                    //Manohar : Commenting below to stop the outbound based on active status(feedback on 22 Apr)
                    /*else if(offerRec.status__c =='Active' && oldMap.get(offerRec.Id).Status__c !='Active' && offerRec.Start_Date__c <= system.today()&& OfferRec.Latest_Version__c == true)
                    {
                     	lstOffertoSend.add(offerRec); 
                    }
                    */
                }
            	if(lstOffertoSend!=null && lstOffertoSend.size()>0)
                {
                    System.enqueuejob(new  OfferOutboundQueue(lstOffertoSend));
                }
        }       

    }
    /************************************************************************
* Description: this method will return list of offer based on clone source id.
* *************************************************************************/
    public Map<id,Offers__c> getOfferRecords(set<id> setOffer){
        Map<id,Offers__c> mapOffer;
        if(setOffer.size()>0){
            mapOffer = new Map<id,Offers__c>([Select Id,RecordtypeID,Name,Boilerplate__c,Offer_Title__c,Short_Description__c,Detailed_Description__c,Terms_and_Conditions__c,Legal_Desclaimer__c,
                                              Dealer_Contribution__c,Loyalty_Cash__c,Additional_Cash__c,Captive_Cash__c,Conquest_Cash__c,Other_Captive_Cash__c,Brand__c,Offer_Availability__c,Group_Type__c,Group_Code__c,AHM_Regions__c from Offers__c where id In:setOffer]);
        }
        return mapOffer;
    }
    /** 
* @author Priyadarshi Singh
* @description This method is used to update Latest_Version__c field on Offers__c object when new Offers__c record is inserted.
**/
    public void updateLatestVersion(List<Offers__c> lstOffer){
        set<Id> offerhdr = new set<Id>();
        List<Offers__c> offr = new List<Offers__c>();
        for(Offers__c ofr : lstOffer){
            ofr.Latest_Version__c = true;
            if(ofr.Offer_Header__c != null){
                offerhdr.add(ofr.Offer_Header__c);
            }
        }
        offr = [Select Id,Latest_Version__c,Offer_Header__c from Offers__c where Offer_Header__c IN : offerhdr];
        if(offr.Size() > 0){
            for(Offers__c ofr : offr){
                if(ofr.Latest_Version__c == true){
                    ofr.Latest_Version__c = false;
                }
            }
            system.debug('inside updaeLAtestVersion');
            
            update offr;  
            
            
            
        }
        
    }
    
    public Map<id,Boilerplate__c> getboilerplate(set<id> boilerids){
        Map<id,Boilerplate__c> mapboile = new map<id,Boilerplate__c>([SELECT Id, Name, Offer_Title__c, Legal_Disclaimer__c, Short_Description__c, Detailed_Description__c, Terms_Descriptions__c, Terms_Conditions__c FROM Boilerplate__c where Id IN:boilerids]);
        system.debug('mapboile'+mapboile);
        return mapboile;
        
    }
    
    public void updateinboundOffer(List<Offers__c> lstOffer, boolean triggerIsExecuting){
        if(!triggerIsExecuting){
            for(Offers__c off:lstOffer){
                if(off.Id==null){
                    System.debug('Record is created via inbound');
                    off.Alternate_Offer_Identifier__c=off.Offer_Header__r.id+''+off.Version_Number__c;
                    System.debug('****'+off.Alternate_Offer_Identifier__c);
                }
            }
        }
    }
    
    public void hasMoreActiveOffers(List<Offers__c> lstOffer){ 
        Set<Id> setOfOfferHeaderId = new Set<Id>();
        for(Offers__c objRecords: lstOffer) {
            setOfOfferHeaderId.add(objRecords.Offer_Header__c);
        }
        
        
        setOfOfferHeaderId.remove(null);
        if(setOfOfferHeaderId != null){
            Set<Id> setOfMoreThan1Offerss = new Map<Id, AggregateResult>([
                SELECT Offer_Header__c Id FROM offers__c
                WHERE Offer_Header__c IN :setOfOfferHeaderId and Status__c ='Active'
                and Id NOT IN: lstOffer
                GROUP BY Offer_Header__c 
                HAVING COUNT(Id) > 1]).keySet(); 
            system.debug('map value:'+setOfMoreThan1Offerss);
            if(lstOffer != null){
                for(Offers__c objRecord: lstOffer) {
                    if(setOfMoreThan1Offerss.contains(objRecord.Offer_Header__c)) {
                        objRecord.Offer_Header__c .addError('You cannot have more than 1 active offer under same Offer Header');
                    }
                }
            } 
        }
        
    }
    /*This method is used to update offers with lower version to expire*/
    public void markOfferAsExpired(List<Offers__c> lstOffers,map<Id,offers__c> newMap,map<Id,offers__c> oldMap)
    {
        set<Id> offerHeaderIdSet = new set<Id>();
        List<Offers__c> lstOffersToUpdate = new List<Offers__c>();
        if(lstOffers!=null)
        {
            for(Offers__c rec:lstOffers){
                if(rec.Status__c == 'Approved' && oldMap.get(rec.Id).status__c !='Approved')
                {
                	offerHeaderIdSet.add(rec.offer_header__c);
                }
            }
        }
        if(offerHeaderIdSet !=null)
        {
            for(Offers__c offerRec:[select id,name,status__c,version_number__c 
                                    from offers__c 
                                    where offer_header__c  IN :offerHeaderIdSet and 
                                    Id NOT IN :lstOffers and
               						status__c IN ('Approved','Submitted','Active')])
            {
               
               if(Approval.isLocked(offerRec.Id))
                {
                	Approval.UnlockResult unlockResult = Approval.unlock(offerRec.Id);
                }
                offerRec.Status__c = 'Expired';
                lstOffersToUpdate.add(offerRec);
            }
        }
        if(lstOffersToUpdate !=null && lstOffersToUpdate.size() >0)
        {
            update lstOffersToUpdate;
        }
            
    }
    /*This method is used populate the vehicle type code for offer based on record types*/
    public void populateVehicleTypeCode(List<Offers__c> newList,map<Id,Sobject> oldMap)
    {       
        map<Id,offers__c> mapOldoffer ;
        if(oldMap !=null)
        {
            mapOldoffer =(map<Id,offers__c>)oldMap;
        }
		if(newList !=null)    
        {
            for(offers__c offer:newList)
            {
                system.debug('## vehicle type code:'+offer.Vehicle_Type_CD__c);
                system.debug('## vehicle type code:'+mapOldoffer);
                if(offer.Vehicle_Type_CD__c == null)
                {
                   setVehicleTypeCode(offer);
                }
                else
                {
                    system.debug('## else');
                    if(mapOldoffer != null && offer.Product_Type__c !=null &&  offer.Product_Type__c != mapOldoffer.get(offer.Id).Product_Type__c)
                    {
                       setVehicleTypeCode(offer);
                    }
                }
             }
        }
    }

    /* This method sets the vehicle type code based record type and product type*/
     @Testvisible 
    private void setVehicleTypeCode(Offers__c offer)  
        {           
            map<id,string> mapOfferRecTypes = GetOfferRecordTypesUtility.getOfferRecordTypeNames();
            //for CPO, set the value based on product type.         
             if(OfferMgmtConstants.CPO_RECTYPE_NAMES.contains((string)mapOfferRecTypes.get(offer.RecordTypeId)))
                {
                    system.debug('Offer.Product_Type__c:'+Offer.Product_Type__c);
                    if(Offer.Product_Type__c == 'Used')
                    {
                        offer.Vehicle_Type_CD__c='U';
                    }
                    else if(offer.Product_Type__c =='Certified')
                    {
                        offer.Vehicle_Type_CD__c='C';
                    }                    
                }
                //for AIG, PS types , set value as N
            else if(OfferMgmtConstants.AIG_RECTYPE_NAMES.contains((string)mapOfferRecTypes.get(offer.RecordTypeId)) || OfferMgmtConstants.PS_RECTYPE_NAMES.contains((string)mapOfferRecTypes.get(offer.RecordTypeId)))
            {
                offer.Vehicle_Type_CD__c='N';
            }
        }
    /*This method is used to set the Sales Program code for diffrent offer types in condition with Special Category*/
    public void populateSalesProgramCode(List<offers__c> lstOffers)
        {
            map<id,string> mapOfferRecTypes = GetOfferRecordTypesUtility.getOfferRecordTypeNames();
            if(lstOffers !=null)
            {
                for(Offers__c offer:lstOffers)
                {
                    string recTypeName = mapOfferRecTypes.get(offer.recordTypeId);
                    string splCategoryValue = offer.Special_category__c;
                    system.debug('In populateSalesProgramCode:recTypeName'+recTypeName+' and Special category:'+splCategoryValue);
                    system.debug('In populateSalesProgramCode:splCategoryValue exists in map:'+OfferMgmtConstants.SALES_PRGM_MAP_FOR_PROGRAMS.containsKey(splCategoryValue));
                    //for finance , lease  types map the value from constants
                    if(OfferMgmtConstants.SALES_PRGM_MAP_FOR_FINANCE_AND_LEASE.containsKey(recTypeName))
                    {
                       offer.Sales_Program_Type_CD__c = OfferMgmtConstants.SALES_PRGM_MAP_FOR_FINANCE_AND_LEASE.get(recTypeName);
                    }
                    //for program types, check the special category and map the value from constants. Do not map for PS
                    else if(recTypeName.contains('Program') && splCategoryValue!=null && OfferMgmtConstants.SALES_PRGM_MAP_FOR_PROGRAMS.containsKey(splCategoryValue))
                    {
                       offer.Sales_Program_Type_CD__c = OfferMgmtConstants.SALES_PRGM_MAP_FOR_PROGRAMS.get(splCategoryValue);
                        
                    } 
                    else if(OfferMgmtConstants.SALES_PRGM_MAP_FOR_POWERSPORTS.containsKey(recTypeName))
                    {
                        offer.Sales_Program_Type_CD__c = OfferMgmtConstants.SALES_PRGM_MAP_FOR_POWERSPORTS.get(recTypeName);
                    }
                    system.debug('### Rectype:'+recTypeName + '::Sales Program Code Value :'+offer.Sales_Program_Type_CD__c);
                }
                
            } 
        }
    public void uncheckPreview(Map<ID, SObject> newOfferMap,Map<ID, SObject> oldOfferMap){
        map<Id,offers__c> mapNewoffer;
        if(newOfferMap !=null)
        {
            mapNewoffer =(map<Id,offers__c>)newOfferMap;
        }
        map<Id,offers__c> mapOldoffer;
        if(oldOfferMap !=null)
        {
            mapOldoffer =(map<Id,offers__c>)oldOfferMap;
        }
        for(Id offerId: mapNewoffer.keyset()){
            if((mapOldoffer.get(offerId).Status__c == 'WIP' || mapOldoffer.get(offerId).Status__c == 'Validated') && mapOldoffer.get(offerId).Preview__c == true){
                if(mapNewoffer.get(offerId).Status__c == mapOldoffer.get(offerId).Status__c){
                    mapNewoffer.get(offerId).Status__c = 'WIP';
                    mapNewoffer.get(offerId).Preview__c = false;
                    
                }
                
            }
            
        }
        
    }  
    /*This method is used to get the latest offer version details for given offer records*/
    private static map<Id,Offers__c> getLatestOffer(List<Offers__c> lstOffers)
    {
        map<Id,Offers__c> mapHeaderToLatestOffer = new map<Id,offers__c>();//key - header id, value - offer record
        set<Id> setOfferHeaderId = new set<Id>();
        for(Offers__c rec:lstOffers)
        {
            setOfferHeaderId.add(rec.offer_header__c);
        }        
        for(offers__c rec:[select id,offer_header__c,Integration_status__c,Latest_Version__c
                          from Offers__c
                          where offer_header__c IN: setOfferHeaderId and Latest_Version__c = true])
        {
            mapHeaderToLatestOffer.put(rec.offer_header__c,rec);
        }
        return mapHeaderToLatestOffer;  
    }   

}
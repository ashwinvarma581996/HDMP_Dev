public class SpecialLeaseHandler {
    @AuraEnabled
    public static List<Offer_Eligible_Models__c> getOEMList(String offerId ){
        System.debug('offerId==>'+offerId);
        return [ Select Id, Name,Year__c,Offer__c,Sort_Order__c,Offer__r.Brand__c,Featured_Offer__c,Trim__c,Model_ID__c,Acquisition_Fee__c,Additional_Cash__c,
                Adjusted_MSRP_with_DH__c,Annual_Miles__c,Base_Monthly_Payment__c,Capitalized_Cost_Reduction__c,Is_Calculation_Done__c,
                Conquest_Cash__c,Dealer_Contribution__c,Loyalty_Cash__c,Net_Capital_Cost__c,Gross_Margin__c,Captive_Cash_Lease_Amount__c,
                Include_Sample_Payment__c,Invoice_Price_with_DH__c,Terms_Months__c,Residual_Factor__c,Other_Captive_Cash_Lease_Amount__c,
                Total_Due_At_signing__c,Residual_Value__c,Total_Monthly_Payment__c,Segment__c,Category__c,Family__c,Model__c,Featured__c,MSRP__c,Freight_Charge__c
                 ,Money_Factor__c
                from Offer_Eligible_Models__c 
                where Offer__c=:offerId order by Sort_Order__c asc];
    }
     
    @AuraEnabled
    public static List<Offers__c> getOffer(Id recId){
        List<Offers__c> offer = new List<Offers__c>();
        offer = [Select Id,Status__c,Synched_with_PRISM__c,Lease_Title_Ident__c,National_Offer__c from Offers__c where Id =: recId];
        if(offer.Size() > 0){
            if(offer[0].Synched_with_PRISM__c == true){
                return offer;
            }
            if(offer[0].National_Offer__c != null){
                List<Offers__c> offerParent = new List<Offers__c>();
        		offerParent = [Select Id,Synched_with_PRISM__c from Offers__c where Id =: offer[0].National_Offer__c];
                if(offerParent.Size() > 0){
                    offer[0].Synched_with_PRISM__c = offerParent[0].Synched_with_PRISM__c;
                }
            }
        }
        return offer;
    }
    @AuraEnabled
    public static Boolean sortUp(Id recId, Integer sortNum){
        system.debug('printing num'+sortNum);
        Boolean returnVal = true;
        try{
        if(sortNum == 1){
            return true;
        }
        List<Offer_Eligible_Models__c> offer = new List<Offer_Eligible_Models__c>();
		offer = [select Id, Sort_Order__c from Offer_Eligible_Models__c where Offer__c =: recId order by Sort_Order__c asc];
        for(Integer i = 0; i < offer.Size(); i++){
            if(offer[i].Sort_Order__c == sortNum){
                offer[i].Sort_Order__c = offer[i].Sort_Order__c - 1;
                offer[i - 1].Sort_Order__c = offer[i - 1].Sort_Order__c +1;
                i = offer.Size();
            }
        }
        update offer;
        Boolean updateOffer = updateOfferPreview(recId);
        } catch(Exception ex){
            returnVal = false;
            
        }
        return returnVal;
    }
    
     @AuraEnabled
    public static Boolean sortDown(Id recId, Integer sortNum){
        system.debug('printing num'+sortNum);
        Boolean returnVal = true;
        try{
        List<Offer_Eligible_Models__c> offer = new List<Offer_Eligible_Models__c>();
		offer = [select Id, Sort_Order__c from Offer_Eligible_Models__c where Offer__c =: recId order by Sort_Order__c asc];
        for(Integer i = 0; i < offer.Size(); i++){
            if(offer[i].Sort_Order__c == sortNum){
                offer[i].Sort_Order__c = offer[i].Sort_Order__c + 1;
                offer[i + 1].Sort_Order__c = offer[i + 1].Sort_Order__c -1;
                i = offer.Size();
            }
        }
        update offer;
        Boolean updateOffer = updateOfferPreview(recId);
        } catch(Exception ex){
            returnVal = false;
        }
        return returnVal;
    }
    
    
    @AuraEnabled
    public static Boolean deleteRow(String recId, Integer sortNum, String offerId){
        boolean returnVal = true;
        try{
        system.debug('printing record id '+recId);
        //Id rowId = recId.substring(1,19);
        system.debug('printing record id '+recId);
        List<Offer_Eligible_Models__c> offerModel = new List<Offer_Eligible_Models__c>();
        List<Offer_Eligible_Models__c> oem = new List<Offer_Eligible_Models__c>();
        offerModel = [Select Id,Sort_Order__c from Offer_Eligible_Models__c where Offer__c =:offerId order by Sort_Order__c asc];
        if(offerModel.Size() == 0){
            returnVal = false;
        }else{
            boolean recFound = false;
            for(Offer_Eligible_Models__c offer:offerModel){
                if(offer.Sort_Order__c == sortNum && recFound == false){
                    recFound = true;
                    oem.add(offer);
                }
                if(recFound == true){
                    offer.Sort_Order__c = offer.Sort_Order__c - 1;
                }
            }
            update offerModel;
        }
        Boolean updateOffer = updateOfferPreview(offerId);
        delete oem;
        } catch(Exception ex){
            returnVal = false;
        }
        return returnVal;
        
        
    }
    @AuraEnabled
    public static List<Product_Chooser__c> getModelDetailsSec2(String brand){
        List<Product_Chooser__c> oem = new List<Product_Chooser__c>();
        /*oem = [SELECT Alternate_Product_Chooser_Identifier__c, Application_Name__c, Name, Product_Model__c, 
               Product_Model__r.Product_Model_Id__c, Product_Subdivision__c,
               Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c FROM Product_Chooser__c 
               WHERE Product_Subdivision__c =: brand order by Tier1__c desc];*/
        oem = [SELECT Alternate_Product_Chooser_Identifier__c, Application_Name__c, Name, Product_Model__c, 
               Product_Model__r.Product_Model_Id__c, Product_Subdivision__c,
               Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c FROM Product_Chooser__c 
               WHERE Product_Subdivision__c =: brand and Application_Name__c like 'Current_Offers%' order by Tier1__c desc];
        return oem;
    }
    
    @AuraEnabled
    public static void updateOfferEligibileModel(Offer_Eligible_Models__c records){
        List<Offer_Eligible_Models__c> updateList = new List<Offer_Eligible_Models__c>();
        if(records != null){
            Offer_Eligible_Models__c offem = new Offer_Eligible_Models__c();
            offem.Id = records.Id;
            records.Total_Due_At_signing__c = records.Total_Due_At_signing__c;
            records.Total_Monthly_Payment__c = records.Total_Monthly_Payment__c;
            records.Residual_Value__c = records.Residual_Value__c;
            updateList.add(records);
        }
        update updateList;
    }
    
    @AuraEnabled
    public static List<Product_Chooser__c> getModelDetails(String brand){
        System.debug('brand=>'+brand);
        List<Product_Chooser__c> oem = new List<Product_Chooser__c>();
        /*oem = [SELECT Alternate_Product_Chooser_Identifier__c, Application_Name__c, Name, Product_Model__c, 
               Product_Model__r.Product_Model_Id__c, Product_Subdivision__c,
               Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c FROM Product_Chooser__c 
               WHERE Product_Subdivision__c =: brand order by Tier1__c desc];*/

        oem = [SELECT Alternate_Product_Chooser_Identifier__c, Application_Name__c, Name, Product_Model__c, 
               Product_Model__r.Product_Model_Id__c, Product_Subdivision__c,
               Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c FROM Product_Chooser__c 
               WHERE Product_Subdivision__c =: brand and Application_Name__c like 'Current_Offers%' order by Tier1__c desc];
        return oem;
       /* Set<String> uniqModelYr = new Set<String>();
        Set<String> uniqModelName = new Set<String>();
        Set<String> uniqTrim = new Set<String>();
        Map<String,String> modelNameYRWise = new Map<String,String>();
        Map<String,String> trimModelNameWise = new Map<String,String>();
        List<Product_Chooser__c> productModelList = [SELECT Alternate_Product_Chooser_Identifier__c, Application_Name__c, Name, Product_Model__c, Product_Model__r.Product_Model_Id__c, Product_Subdivision__c,
                                                     Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c FROM Product_Chooser__c 
                                                     WHERE Product_Subdivision__c=:brand order by Tier1__c desc];
        if(productModelList.size() > 0){
            for(Product_Chooser__c rec: productModelList){
                if(!trimModelNameWise.containsKey(rec.Tier3__c)){
                    trimModelNameWise.put(rec.Tier3__c,rec.Tier4__c);
                }else{
                    String oldvalue = trimModelNameWise.get(rec.Tier3__c);
                    oldvalue +=','+rec.Tier4__c;
                    trimModelNameWise.put(rec.Tier3__c,oldvalue);
                }
            }
            for(Product_Chooser__c rec: productModelList){
                if(!modelNameYRWise.containsKey(rec.Tier1__c)){
                    modelNameYRWise.put(rec.Tier1__c,rec.Tier3__c);
                }else{
                    String oldvalue = modelNameYRWise.get(rec.Tier1__c);
                    oldvalue +=','+rec.Tier3__c;
                    modelNameYRWise.put(rec.Tier1__c,oldvalue);
                }
            }
        }
        for(String key: modelNameYRWise.keyset()){
            String tempVar = modelNameYRWise.get(key);
            Set<String> tmpSet = New Set<String>(tempVar.split(','));
            tempVar = string.join(New List<String>(tmpSet),',');
            modelNameYRWise.put(key,tempVar);
        }
        System.debug('modelNameYRWise==>'+modelNameYRWise);
        for (Integer i = 0; i< productModelList.size(); i++)
        {
            uniqModelYr.add(productModelList[i].Tier1__c); 
        }
        System.debug('uniqModelYr==>'+modelNameYRWise);
        ProductModelWrapper wrapper = new ProductModelWrapper();
        wrapper.modelYear = new List<String>(uniqModelYr);
        wrapper.modelNameYRWise = modelNameYRWise;
        wrapper.trimModelNameWise = trimModelNameWise;
        return wrapper;      */
    }
    
    @AuraEnabled
    public static String getModelID(String year,String modalName,String trim){
        String returnValue;
        List<Product_Model__c> productData = [select Id, Product_Model_ID__c,Model_Year__c,Model_Name__c,Trim__c 
                                              from Product_Model__c 
                                              where Model_Year__c=:year and Model_Name__c=:modalName and Trim__c=:trim limit 1];
        if(productData.size() > 0){
            returnValue = productData[0].Product_Model_ID__c;
        }else{
            returnValue = '';
        }
        return returnValue;
    }
    
    @AuraEnabled
    public static String getRecordType(String recordId){
        List<Offers__c> offerList =[Select Id,Name,recordTypeId,recordType.Name from Offers__c
                                    where Id=:recordId];
        Boolean isPowerSports = false;
        String recordTypeName;
        if(offerList.size() > 0){
            recordTypeName = offerList[0].recordType.Name;
            System.debug('recordTypeName=>'+recordTypeName);
        }
        return recordTypeName;
    }
    
    @AuraEnabled 
    public static Offer_Eligible_Models__c getOEMDetails(String recordId ){
        return [ Select Id, Name,Year__c,Offer__c,Offer__r.Brand__c,Featured_Offer__c,Trim__c,Model_ID__c,Acquisition_Fee__c,Additional_Cash__c,
                Adjusted_MSRP_with_DH__c,Annual_Miles__c,Base_Monthly_Payment__c,Capitalized_Cost_Reduction__c,Is_Calculation_Done__c,
                Conquest_Cash__c,Dealer_Contribution__c,Loyalty_Cash__c,Net_Capital_Cost__c,Gross_Margin__c,Captive_Cash_Lease_Amount__c,
                Include_Sample_Payment__c,Invoice_Price_with_DH__c,Terms_Months__c,Residual_Factor__c,Other_Captive_Cash_Lease_Amount__c,
                Total_Due_At_signing__c,Residual_Value__c,Total_Monthly_Payment__c,Default_Image__c,Segment__c,Category__c,Family__c,Model__c,Featured__c,MSRP__c,Freight_Charge__c,Destination_Handling_charge__c
                , Money_Factor__c,CPO_Cash__c
                from Offer_Eligible_Models__c 
                where Id=:recordId];
    }
    @AuraEnabled
    public static String updatePowerSportData(Offer_Eligible_Models__c recData, String recId,Id offerId){
        String returnVal = 'true';
        try{
        List<Offer_Eligible_Models__c> offer = new List<Offer_Eligible_Models__c>();
        offer = [ Select Id, Name,Year__c,Segment__c,Category__c,Family__c,Model__c,MSRP__c,Featured__c,Freight_Charge__c,Is_Calculation_Done__c
                from Offer_Eligible_Models__c 
                where Id=:recId];
        if(recData != null){
            offer[0].MSRP__c = recData.MSRP__c;
            offer[0].Featured_Offer__c = recData.Featured_Offer__c;
            offer[0].Freight_Charge__c = recData.Freight_Charge__c;
            offer[0].Is_Calculation_Done__c = true;
            //offer[0].Category__c = recData.Category__c;
            //offer[0].Family__c = recData.Family__c;
            //offer[0].Name = recData.Model__c;
            update offer;
            Boolean updateOffer = updateOfferPreview(offerId);
        }
        } catch(Exception ex){
            returnVal = ex.getMessage();
        }
        return returnVal;
    }
    
    @AuraEnabled 
    public static String saveOfferEligibileRecord(Offer_Eligible_Models__c records,String offerId,String oemodelID,List<String> years,List<String> Alltrims,String recType){
       	system.debug('=================inside save===============================');
        Id devRecordTypeId = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();
        List<String> Lstyears = new List<String>(years);
        List<Offer_Eligible_Models__c> offerModelList;
        List<Offer_Eligible_Models__c> updateList = new List<Offer_Eligible_Models__c>();
        List<Offer_Eligible_Models__c> insertofferList = new List<Offer_Eligible_Models__c>();
        //System.debug('Alltrims=>'+Alltrims.size());
        if(String.isNotBlank(oemodelID)){
            offerModelList = [Select Id, Name,Year__c,Featured_Offer__c,Trim__c,Model_ID__c,Acquisition_Fee__c,Additional_Cash__c,
                              Adjusted_MSRP_with_DH__c,Annual_Miles__c,Base_Monthly_Payment__c,Capitalized_Cost_Reduction__c,
                              Conquest_Cash__c,Dealer_Contribution__c,Loyalty_Cash__c,Net_Capital_Cost__c,Gross_Margin__c,
                              Include_Sample_Payment__c,Invoice_Price_with_DH__c,Terms_Months__c,Residual_Factor__c ,
                              Total_Due_At_signing__c,Residual_Value__c,Total_Monthly_Payment__c,Offer__c
                              , Money_Factor__c,CPO_Cash__c,Is_Calculation_Done__c
                              from Offer_Eligible_Models__c 
                              where Id=:oemodelID ];
            if(offerModelList.size() > 0){
                for(Offer_Eligible_Models__c obj : offerModelList){
                    //obj = new Offer_Eligible_Models__c();
                    obj.Name = records.Name;
                    obj.Year__c = records.Year__c;
                    obj.Trim__c = records.Trim__c;
                    obj.Featured_Offer__c = records.Featured_Offer__c;    
                    obj.Id = oemodelID;
                    obj.CPO_Cash__c = records.CPO_Cash__c;
                    obj.Model_ID__c = records.Model_ID__c;
                    obj.Acquisition_Fee__c = records.Acquisition_Fee__c;
                    obj.Additional_Cash__c = records.Additional_Cash__c;
                    obj.Adjusted_MSRP_with_DH__c = records.Adjusted_MSRP_with_DH__c;
                    obj.Annual_Miles__c = records.Annual_Miles__c;
                    obj.Base_Monthly_Payment__c = records.Base_Monthly_Payment__c;
                    obj.Capitalized_Cost_Reduction__c = records.Capitalized_Cost_Reduction__c;
                    obj.Conquest_Cash__c = records.Conquest_Cash__c;
                    obj.Dealer_Contribution__c = records.Dealer_Contribution__c;
                    obj.Loyalty_Cash__c = records.Loyalty_Cash__c;
                    obj.Net_Capital_Cost__c = records.Net_Capital_Cost__c;
                    obj.Gross_Margin__c = records.Gross_Margin__c;
                    obj.Include_Sample_Payment__c = records.Include_Sample_Payment__c;
                    obj.Invoice_Price_with_DH__c = records.Invoice_Price_with_DH__c;
                    obj.Terms_Months__c = records.Terms_Months__c;
                    obj.Residual_Factor__c = records.Residual_Factor__c;
                    obj.Money_Factor__c = records.Money_Factor__c;
                    obj.Total_Due_At_signing__c = records.Total_Due_At_signing__c;
                    obj.Total_Monthly_Payment__c = records.Total_Monthly_Payment__c;
                    obj.Residual_Value__c = records.Residual_Value__c;
                    obj.Captive_Cash_Lease_Amount__c = records.Captive_Cash_Lease_Amount__c;
                    obj.Other_Captive_Cash_Lease_Amount__c = records.Other_Captive_Cash_Lease_Amount__c;
                    obj.Is_Calculation_Done__c = true;
                   /* if(records.Include_Sample_Payment__c == false){
                        obj.CPO_Cash__c = null;
                        obj.Acquisition_Fee__c = null;
                    	obj.Additional_Cash__c = null;
                        obj.Annual_Miles__c = null;
                    	obj.Base_Monthly_Payment__c = null;
                    	obj.Capitalized_Cost_Reduction__c = null;
                    	obj.Conquest_Cash__c = null;
                    	obj.Dealer_Contribution__c = null;
                    	obj.Loyalty_Cash__c = null;
                    	obj.Net_Capital_Cost__c = null;
                    	obj.Gross_Margin__c = null;
                        obj.Terms_Months__c = null;
                    	obj.Residual_Factor__c = null;
                    	obj.Money_Factor__c = null;
                    	obj.Total_Due_At_signing__c = null;
                    	obj.Total_Monthly_Payment__c = null;
                    	obj.Residual_Value__c = null;
                    	obj.Captive_Cash_Lease_Amount__c = null;
                    	obj.Other_Captive_Cash_Lease_Amount__c = null;
                    }  */
                   // obj.Destination_Handling_charge__c = records.Destination_Handling_charge__c;
                    updateList.add(obj);
                }
            }
        }
        else if(String.isNotBlank(offerId) && String.isBlank(oemodelID) && records != null){
       /*     Map<String, Product_Model__c> productChoosers = new Map<String, Product_Model__c>();
        for(Product_Model__c pc : [SELECT Product_Model_ID__c, Trim__c, Model_Year__c, Model_Name__c
                                     FROM Product_Model__c 
                                     WHERE Model_Year__c IN :Lstyears AND Model_Name__c =:records.Name AND Trim__c IN:Alltrims]){
                                         String key = pc.Model_Year__c + pc.Model_Name__c + pc.Trim__c;
                                         productChoosers.put(key, pc);
                                     }   */
            Map<String, Product_Chooser__c> productChoosers = new Map<String, Product_Chooser__c>();
        for(Product_Chooser__c pc : [SELECT Product_Model__c, Product_Subdivision__c, Product_Model__r.Product_Model_Id__c,Product_Model__r.Destination_Handling_Amount__c,Product_Model__r.MSRP__c,Product_Model__r.Dealer_Invoice__c, Tier1__c, Tier2__c, Tier3__c,Tier4__c,Tier5__c
                                     FROM Product_Chooser__c 
                                     WHERE Tier1__c IN :Lstyears AND Tier3__c =:records.Name AND Tier4__c IN:Alltrims and application_Name__c like 'Current_Offers%']){
                                         String key = pc.Tier1__c + pc.Tier3__c + pc.Tier4__c;
                                         productChoosers.put(key, pc);
                                     }
            
            Set<String> offerEligibleModelSet = new Set<String>();
        for(Offer_Eligible_Models__c oem : [SELECT Trim__c, Year__c, Name
                                     FROM Offer_Eligible_Models__c where Offer__c =: offerId]){
                                         String key = oem.Year__c + oem.Name + oem.Trim__c;
                                         offerEligibleModelSet.add(key);
                                     }   
            List<Offers__c> offer = new List<Offers__c>();
            offer = [select Id,Brand__c,recordTypeId,recordType.Name from Offers__c where Id =: offerId];
            system.debug('keyset'+productChoosers.KeySet());
            for(String year: Lstyears){
                if(Alltrims.size() > 0){
                    for(String trim: Alltrims){
                        if(trim != 'All'){
                            string key = year+records.Name+trim;
                            System.debug('records=>'+productChoosers.get(key));
                            if(productChoosers.containsKey(key) == true && !offerEligibleModelSet.contains(Key) ){
                                Offer_Eligible_Models__c obj = new Offer_Eligible_Models__c();
                                obj.Model_ID__c = productChoosers.get(key).Product_Model__r.Product_Model_Id__c;
                                obj.Name = records.Name;
                                obj.Model_Series_Group_Name__c = productChoosers.get(Key).Tier2__c;
                        	obj.ModelParentSeriesGroupName__c = productChoosers.get(Key).Tier2__c;
                                obj.Model_Group_Name__c = productChoosers.get(Key).Tier3__c;
                            obj.Year__c = year;
                            obj.Trim__c = trim;
                            obj.Featured_Offer__c = records.Featured_Offer__c;
                            //obj.Model_ID__c = productChoosers.get(key).Product_Model_ID__c;
                            obj.Acquisition_Fee__c = records.Acquisition_Fee__c;
                            obj.Additional_Cash__c = records.Additional_Cash__c;
                            //obj.Adjusted_MSRP_with_DH__c = records.Adjusted_MSRP_with_DH__c;
                            obj.Annual_Miles__c = records.Annual_Miles__c;
                            obj.Base_Monthly_Payment__c = records.Base_Monthly_Payment__c;
                            obj.Capitalized_Cost_Reduction__c = records.Capitalized_Cost_Reduction__c;
                            obj.Conquest_Cash__c = records.Conquest_Cash__c;
                            obj.Dealer_Contribution__c = records.Dealer_Contribution__c;
                            obj.Loyalty_Cash__c = records.Loyalty_Cash__c;
                            obj.Net_Capital_Cost__c = records.Net_Capital_Cost__c;
                            obj.Gross_Margin__c = records.Gross_Margin__c;
                            obj.Include_Sample_Payment__c = records.Include_Sample_Payment__c;
                            obj.Terms_Months__c = records.Terms_Months__c;
                            obj.Residual_Factor__c = records.Residual_Factor__c;
                            obj.Money_Factor__c = records.Money_Factor__c;
                            obj.Total_Due_At_signing__c = records.Total_Due_At_signing__c;
                            obj.Total_Monthly_Payment__c = records.Total_Monthly_Payment__c;
                            obj.Residual_Value__c = records.Residual_Value__c;
                            obj.Offer__c = offerId;
                            obj.RecordTypeId = devRecordTypeId;
                            obj.Captive_Cash_Lease_Amount__c = records.Captive_Cash_Lease_Amount__c;
                            obj.Other_Captive_Cash_Lease_Amount__c = records.Other_Captive_Cash_Lease_Amount__c;
                            obj.Destination_Handling_charge__c = records.Destination_Handling_charge__c;
                            if(offer.Size() > 0){
                            	obj.Brand__c = offer[0].Brand__c;
                                if(offer[0].recordType.Name == 'CPO Special Lease' || offer[0].recordType.Name == 'CPO Standard Lease' || offer[0].recordType.Name == 'New Standard Lease' || offer[0].recordType.Name == 'New Special Lease' ){
                                    if(productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c == null){
                                        productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c = 0;
                                    }
                                    if(productChoosers.get(key).Product_Model__r.Dealer_Invoice__c == null){
                                        productChoosers.get(key).Product_Model__r.Dealer_Invoice__c = 0;
                                    }
                            	//obj.Invoice_Price_with_DH__c = productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c +  productChoosers.get(key).Product_Model__r.Dealer_Invoice__c;
                                //obj.MSRP__c = productChoosers.get(key).Product_Model__r.MSRP__c;
                                }
                            }
                            insertofferList.add(obj);
                            }
                            
                        }
                    }
                }else{
                    System.debug('records.Trim__c==>'+records.Trim__c);
                    System.debug('year==>'+year);
                    
                    string key = year+records.Name+records.Trim__c;
                    if(productChoosers.containsKey(key) == true && !offerEligibleModelSet.contains(Key)){
                        Offer_Eligible_Models__c obj = new Offer_Eligible_Models__c();
                                obj.Model_ID__c = productChoosers.get(key).Product_Model__r.Product_Model_Id__c;
                        obj.Name = records.Name;
                    obj.Year__c = year;
                    obj.Trim__c = records.Trim__c;
                    obj.Featured_Offer__c = records.Featured_Offer__c;
                    //obj.Model_ID__c = records.Model_ID__c;
                    obj.Acquisition_Fee__c = records.Acquisition_Fee__c;
                    obj.Additional_Cash__c = records.Additional_Cash__c;
                    obj.Model_Series_Group_Name__c = productChoosers.get(Key).Tier2__c;
                    obj.ModelParentSeriesGroupName__c = productChoosers.get(Key).Tier2__c;
                    obj.Model_Group_Name__c = productChoosers.get(Key).Tier3__c;
                    //obj.Adjusted_MSRP_with_DH__c = records.Adjusted_MSRP_with_DH__c;
                    obj.Annual_Miles__c = records.Annual_Miles__c;
                    obj.Base_Monthly_Payment__c = records.Base_Monthly_Payment__c;
                    obj.Capitalized_Cost_Reduction__c = records.Capitalized_Cost_Reduction__c;
                    obj.Conquest_Cash__c = records.Conquest_Cash__c;
                    obj.Dealer_Contribution__c = records.Dealer_Contribution__c;
                    obj.Loyalty_Cash__c = records.Loyalty_Cash__c;
                    obj.Net_Capital_Cost__c = records.Net_Capital_Cost__c;
                    obj.Gross_Margin__c = records.Gross_Margin__c;
                    obj.Include_Sample_Payment__c = records.Include_Sample_Payment__c;
                    obj.Invoice_Price_with_DH__c = records.Invoice_Price_with_DH__c;
                    obj.Terms_Months__c = records.Terms_Months__c;
                    obj.Residual_Factor__c = records.Residual_Factor__c;
                    obj.Money_Factor__c = records.Money_Factor__c;
                    obj.Total_Due_At_signing__c = records.Total_Due_At_signing__c;
                    obj.Total_Monthly_Payment__c = records.Total_Monthly_Payment__c;
                    obj.Residual_Value__c = records.Residual_Value__c;
                    obj.Offer__c = offerId;
                    obj.RecordTypeId = devRecordTypeId;
                    obj.Captive_Cash_Lease_Amount__c = records.Captive_Cash_Lease_Amount__c;
                    obj.Other_Captive_Cash_Lease_Amount__c = records.Other_Captive_Cash_Lease_Amount__c;
                    obj.Destination_Handling_charge__c = records.Destination_Handling_charge__c;
                    //obj.Brand__c = offer[0].Brand__c;
                    if(offer.Size() > 0){
                            	obj.Brand__c = offer[0].Brand__c;
                                if(offer[0].recordType.Name == 'CPO Special Lease' || offer[0].recordType.Name == 'CPO Standard Lease' || offer[0].recordType.Name == 'New Standard Lease' || offer[0].recordType.Name == 'New Special Lease' ){
                                    if(productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c == null){
                                        productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c = 0;
                                    }
                                    if(productChoosers.get(key).Product_Model__r.Dealer_Invoice__c == null){
                                        productChoosers.get(key).Product_Model__r.Dealer_Invoice__c = 0;
                                    }
                                //obj.Invoice_Price_with_DH__c = productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c +  productChoosers.get(key).Product_Model__r.Dealer_Invoice__c;
                                //obj.MSRP__c = productChoosers.get(key).Product_Model__r.MSRP__c;
                                }
                            }
                    insertofferList.add(obj);
                            }
                    
                    
                }
            }
        }
        String returnValue;
        if(insertofferList.size() > 0){
            insert insertofferList;
            Boolean updateOffer = updateOfferPreview(offerId);
            returnValue = insertofferList[0].Id;
            System.debug('inserted...'+insertofferList[0].Offer__c);
        }
        if(updateList.size() > 0){
            System.debug('updated...'+updateList);
            update updateList;
            Boolean updateOffer = updateOfferPreview(offerId);
            returnValue = updateList[0].Offer__c;
        }
        return returnValue;
    }
	
    @AuraEnabled
    public static Boolean updateOfferPreview(Id offerId){
        Boolean returnVal = false;
        List<Offers__c> offer = new List<Offers__c>();
        offer = [Select Id,Status__c,Preview__c from Offers__c where Id =: offerId];
        if(offer.Size() > 0){
            if((offer[0].Status__c == 'Validated' || offer[0].Status__c == 'WIP') && offer[0].Preview__c == true){
                offer[0].Status__c = 'WIP';
                offer[0].Preview__c = false;
                returnVal = true;
            }
            update offer;
        }
        return returnVal;
    }
	    
     @AuraEnabled 
    public static String savePowerSportsRecord(Offer_Eligible_Models__c records,String offerId,List<String> years,List<String> models, String recType){
        List<String> Lstyears = new List<String>(years);
        List<String> Lstmodels = new List<String>(models);
        String recTypeName;
        system.debug('rec type'+recType);
        if(rectype == 'Power Sports AHFC'){
            recTypeName = 'Powersports AHFC';
        } else if(rectype == 'Power Sports Bonus Bucks'){
            recTypeName = 'Powersport Bonus Bucks';
        }else if(rectype == 'Power Sports Generic'){
            recTypeName = 'Powersports Generic';
        }else if(rectype == 'Power Sports Honda Card'){
            recTypeName = 'Powersports Honda card';
        }
        
        Id devRecordTypeId = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        List<Offer_Eligible_Models__c> offerLstToInsert = new List<Offer_Eligible_Models__c>();
        system.debug('printing offer Id'+offerId);
        Map<String, Product_Chooser__c> productChoosers = new Map<String, Product_Chooser__c>();
        for(Product_Chooser__c pc : [SELECT Product_Model__c, Product_Subdivision__c, Product_Model__r.Product_Model_Id__c,Product_Model__r.Destination_Handling_Amount__c,Product_Model__r.Dealer_Invoice__c,Product_Model__r.MSRP__c, Tier1__c, Tier2__c, Tier3__c,Tier4__c,Tier5__c
                                     FROM Product_Chooser__c 
                                     WHERE Tier1__c IN :Lstyears AND Tier2__c =:records.Segment__c AND Tier3__c =:records.Category__c AND Tier4__c =:records.Family__c AND Tier5__c IN: Lstmodels AND application_Name__c like 'Current_Offers%']){
                                         String key = pc.Tier1__c + pc.Tier2__c + pc.Tier3__c + pc.Tier4__c + pc.Tier5__c;
                                         productChoosers.put(key, pc);
                                     }
        Set<String> offerEligibleModelSet = new Set<String>();
        for(Offer_Eligible_Models__c oem : [SELECT Trim__c, Year__c, Name,Segment__c,Category__c,Family__c
                                     FROM Offer_Eligible_Models__c where Offer__c =: offerId]){
                                         String key = oem.Year__c + oem.Segment__c + oem.Category__c +oem.Family__c + oem.Name;
                                         offerEligibleModelSet.add(key);
                                     }
        System.debug('printing map'+productChoosers);
        if(String.isNotBlank(offerId) && records != null){
            for(String year: Lstyears){
                for(String model: Lstmodels){
                    String key = year + records.Segment__c + records.Category__c + records.Family__c + model;
                    if(productChoosers.containsKey(Key) == true && !offerEligibleModelSet.contains(Key)){
                        system.debug('printing key'+productChoosers.get(Key));
                        Offer_Eligible_Models__c obj = new Offer_Eligible_Models__c();
                        obj.Model_ID__c = productChoosers.get(Key).Product_Model__r.Product_Model_Id__c;
                        //obj.Invoice_Price_with_DH__c = productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c;
                        if(productChoosers.get(key).Product_Model__r.MSRP__c == null){
                            //obj.MSRP__c = null;
                        }else{
                        //obj.MSRP__c = productChoosers.get(key).Product_Model__r.MSRP__c;
                        }
						obj.Name = model;
                    	obj.Year__c = year;
                        obj.Model_Series_Group_Name__c = productChoosers.get(Key).Tier3__c;
                        obj.ModelParentSeriesGroupName__c = productChoosers.get(Key).Tier2__c;
                        obj.Model_Group_Name__c = productChoosers.get(Key).Tier4__c;
                    	obj.Category__c = records.Category__c;
                    	obj.Segment__c = records.Segment__c;
                    	obj.Family__c = records.Family__c;
                    	obj.Offer__c = offerId;
                        obj.RecordTypeId = devRecordTypeId;
                        obj.Brand__c = 'M';
                        obj.Trim__c = productChoosers.get(Key).Tier5__c;
                    	//obj.Model_ID__c = productChoosers.get(key).Product_Model__r.Product_Model_Id__c;
                    	offerLstToInsert.add(obj);        
                    }
                    
                }
            }
            system.debug('printing offer to insert list'+offerLstToInsert);
        }
        String returnValue;
        if(offerLstToInsert.size() > 0){
            Boolean updateOffer = updateOfferPreview(offerId);
            insert offerLstToInsert;
            returnValue = offerLstToInsert[0].Offer__c;
        }
        return returnValue;
    }
    Public class ProductModelWrapper{
        @AuraEnabled
        public List<String> modelYear {get; set;}
        @AuraEnabled
        public Map<String,String> modelNameYRWise {get; set;}
        @AuraEnabled
        public Map<String,String> trimModelNameWise {get; set;}
    }
}
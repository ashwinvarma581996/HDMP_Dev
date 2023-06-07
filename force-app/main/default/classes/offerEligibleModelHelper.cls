global with sharing class offerEligibleModelHelper {
    public static void updateOEMs(Boolean isExecuting,List<Offer_Eligible_Models__c> oemList){
        //if (!isExecuting) {
            for(Offer_Eligible_Models__c oemObj: oemList){
               /* if(oemObj.id == null){
                    System.debug('Record is created via inbound');
                    oemObj.Alternate_Offer_Eligible_Model_Id__c=oemObj.Offer__r.Id+'~'+oemObj.Model_ID__c;
                    System.debug('****'+oemObj.Alternate_Offer_Eligible_Model_Id__c);
                }*/
                system.debug('Offer='+oemObj.Offer__c+',Model='+oemObj.Model_ID__c);
                oemObj.Alternate_Offer_Eligible_Model_Id__c=oemObj.Offer__c+'~'+oemObj.Model_ID__c;
            }
        //}
    }
    
    
    
    public static void processOEMs(List<Offer_Eligible_Models__c> oemList){
        
        //store only those recordtypes which need to be processed
        Id spcLeaseRTId = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByDeveloperName().get('New_Special_Lease').getRecordTypeId();
        Id cpoSpcLeaselRTId = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByDeveloperName().get('CPO_Special_Lease').getRecordTypeId();
        //list to store eligible records
        List<Offer_Eligible_Models__c> listtoProcess= new List<Offer_Eligible_Models__c>(); 
        Boolean calculate=true;
        System.debug('spcLeaseRTId'+spcLeaseRTId);
        System.debug('cpoSpcLeaselRTId'+cpoSpcLeaselRTId);
        
        for(Offer_Eligible_Models__c oemObj: oemList){
            if(oemObj.RecordTypeId==spcLeaseRTId || oemObj.RecordTypeId==cpoSpcLeaselRTId){
                if(oemObj.Base_Monthly_Payment__c==null || oemObj.Capitalized_Cost_Reduction__c==null || oemObj.Net_Capital_Cost__c==null ||
                   oemObj.Acquisition_Fee__c==null || oemObj.Annual_Miles__c==null || oemObj.Residual_Factor__c==null || 
                   oemObj.Destination_Handling_charge__c==null || oemObj.MSRP__c==null || oemObj.Gross_Margin__c==null ||
                   oemObj.Dealer_Contribution__c==null || oemObj.Invoice_Price_with_DH__c==null || oemObj.Terms_Months__c==null
                  )
                {
                    System.debug('Some values are null');
                    calculate=false;
                    //oemObj.addError('Invalid field values');
                    //return;
                }
                
                System.debug('***Create a list and call Calculate Lease Method for validation***');
                listtoProcess.add(oemObj);
            }
        }
        if(listtoProcess.size()>0 && calculate){
            calculateLease(listtoProcess);
        }
    }
    
    public static void calculateLease(List<Offer_Eligible_Models__c> oemList){
        
        List<Offer_Eligible_Models__c> oemListtoupdate= new List<Offer_Eligible_Models__c>(); 
        System.debug('OEMList'+oemList.size());
        Decimal BaseMonthlyPayment=0;
        Decimal CapitalizedCostReduction=0;
        Decimal ResidualFactor=0;
        Decimal DestinationHandlingCharge=0;
        Decimal AdjustedMSRP=0;
        Decimal NetCapitalCost=0;
        String Term='';
        String AnnualMiles='';
        
        Decimal intTotalMonthlyPayment=0;
        Decimal intTotalDueLeaseSign=0;
        Decimal intRefundableSecurity=0;
        Decimal intResidualValue=0;
        Decimal intAdjustedResidualFactor=0;
        Decimal intNetPrice=0;
        Decimal decTerm=0;
        
        for(Offer_Eligible_Models__c oemObj: oemList){
            // format the fields to 2 decimal places
            BaseMonthlyPayment= oemObj.Base_Monthly_Payment__c.setScale(2);
            CapitalizedCostReduction= oemObj.Capitalized_Cost_Reduction__c.setScale(2);
            ResidualFactor= oemObj.Residual_Factor__c.setScale(2);
            DestinationHandlingCharge= oemObj.Destination_Handling_charge__c.setScale(2);
            AdjustedMSRP= oemObj.Adjusted_MSRP_with_DH__c.setScale(2);
            NetCapitalCost= oemObj.Net_Capital_Cost__c.setScale(2);
            AnnualMiles= oemObj.Annual_Miles__c;
            Term= oemObj.Terms_Months__c;
            
            
            //Calculate refundable security
            if(!oemObj.Offer__r.Security_Deposit_Required__c){
                intRefundableSecurity = 0;
            }
            else{
                intRefundableSecurity = Math.ceil((BaseMonthlyPayment)/25) * 25;
            }
            //Default value for intAdjustedResidualFactor
            intAdjustedResidualFactor = ResidualFactor;
            
            intNetPrice = AdjustedMSRP;
            
            switch on Term {
                when '24' {
                    decTerm = 24.0;
                }
                when '27' {
                    decTerm = 27.0;
                }
                when '30' {
                    decTerm = 30.0;
                }
                when '33' {
                    decTerm = 33.0;
                }
                when '36' {
                    decTerm = 36.0;
                }
                when '39' {
                    decTerm = 39.0;
                }
                when '42' {
                    decTerm = 42.0;
                }
                when '45' {
                    decTerm = 45.0;
                }
                when '48' {
                    decTerm = 48.0;
                }
                when '51' {
                    decTerm = 51.0;
                }
                when '54' {
                    decTerm = 54.0;
                }
                when '57' {
                    decTerm = 57.0;
                }
                when '60' {
                    decTerm = 60.0;
                }
            }
            
            
            
            
            if(oemObj.Offer__r.Zero_Due__c){
                intTotalMonthlyPayment = (decTerm - 1) * BaseMonthlyPayment;
                intTotalDueLeaseSign = CapitalizedCostReduction;
            }
            
            else
            {
                intTotalMonthlyPayment = decTerm * BaseMonthlyPayment;
                intTotalDueLeaseSign = BaseMonthlyPayment + CapitalizedCostReduction + intRefundableSecurity ; //+ parseFloat(nAcquistionFee);
            }
            intResidualValue = intAdjustedResidualFactor * intNetPrice;
            
            oemObj.Total_Due_At_signing__c = (Math.round(intTotalDueLeaseSign*100)/100);
            oemObj.Residual_Value__c = (Math.round(intResidualValue*100)/100);
            oemObj.Total_Monthly_Payment__c = (Math.round(intTotalMonthlyPayment*100)/100);
            
        }
        
        
        
    }
    public static void defaultOEMFieldValues(List<Offer_Eligible_Models__c> oemList){
       /* Id cpoSpecialLease = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('CPO Special Lease').getRecordTypeId();
        Id cpoStandardLease = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('CPO Standard Lease').getRecordTypeId();
        Id newStandardLease = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('New Standard Lease').getRecordTypeId();
        Id newSpecialLease = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('New Special Lease').getRecordTypeId();
        Id psAHFC = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('Powersports AHFC').getRecordTypeId();
        Id psBonusBucks = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('Powersport Bonus Bucks').getRecordTypeId();
        Id psGeneric = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('Powersports Generic').getRecordTypeId();
        Id psHondaCard = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('Powersports Honda card').getRecordTypeId();
        */
        map<Id,string> mapOEMRecTypes = GetOfferRecordTypesUtility.getOEMRecTypes();
        Set<String> productModelId = new Set<String>();
        for(Offer_Eligible_Models__c oem : oemList){
            productModelId.add(oem.Model_ID__c);
        }
        Map<String, Product_Model__c> productModel = new Map<String, Product_Model__c>();
        for(Product_Model__c pm : [SELECT Product_Model_Id__c,Destination_Handling_Amount__c,MSRP__c,Dealer_Invoice__c
                                     FROM Product_Model__c 
                                     WHERE Product_Model_Id__c IN: productModelId]){
                                         String key = pm.Product_Model_Id__c;
                                         productModel.put(key, pm);
                                     }

		
        for(Offer_Eligible_Models__c oem : oemList){
            System.debug('records types=>'+mapOEMRecTypes.get(oem.RecordTypeId));
            string key = oem.Model_ID__c;
            Product_Model__c pmRec = new Product_Model__c();
            if(productModel.containsKey(key) == true){
            pmRec = productModel.get(oem.Model_ID__c);
            oem.MSRP__c = pmRec.MSRP__c;
            }
           // if(oem.RecordTypeId == cpoSpecialLease || oem.RecordTypeId == cpoStandardLease || oem.RecordTypeId == newStandardLease || oem.RecordTypeId == newSpecialLease){
               if(mapOEMRecTypes!=null && mapOEMRecTypes.get(oem.RecordTypeId).contains('Lease')){ 
                
                if(productModel.containsKey(key) == true){
                    if(pmRec.Destination_Handling_Amount__c == null){
                    	pmRec.Destination_Handling_Amount__c = 0;
                    }
                    if(pmRec.Dealer_Invoice__c == null){
                        pmRec.Dealer_Invoice__c = 0;
                    }
                    if(pmRec.MSRP__c == null){
                        pmRec.MSRP__c = 0;
                    }
                    oem.Invoice_Price_with_DH__c = pmRec.Destination_Handling_Amount__c +  pmRec.Dealer_Invoice__c;
                    oem.MSRP__c = pmRec.MSRP__c;
                    if(mapOEMRecTypes.get(oem.RecordTypeId).contains('CPO')){
                        oem.Adjusted_MSRP_with_DH__c = pmRec.MSRP__c;
                    }else{
                    	oem.Adjusted_MSRP_with_DH__c = pmRec.Destination_Handling_Amount__c +  pmRec.MSRP__c;
                    }
                }
            }
           // else if(oem.RecordTypeId == psAHFC || oem.RecordTypeId == psBonusBucks || oem.RecordTypeId == psGeneric || oem.RecordTypeId == psHondaCard){
             else if(mapOEMRecTypes!=null && mapOEMRecTypes.get(oem.RecordTypeId).contains('Power'))    {
                if(productModel.containsKey(key) == true){  
                    oem.MSRP__c = pmRec.MSRP__c;
                    oem.Freight_Charge__c = productModel.get(key).Destination_Handling_Amount__c;               
                }
            } 
        }
        
            
        }
        
    
    
    public static void defaultFieldValues(List<Offer_Eligible_Models__c> oemList){
        Id cpoSpecialLease = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('CPO Special Lease').getRecordTypeId();
        Id cpoStandardLease = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('CPO Standard Lease').getRecordTypeId();
        Id newStandardLease = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('New Standard Lease').getRecordTypeId();
        Id newSpecialLease = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('New Special Lease').getRecordTypeId();
        Id psAHFC = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('Powersports AHFC').getRecordTypeId();
        Id psBonusBucks = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('Powersport Bonus Bucks').getRecordTypeId();
        Id psGeneric = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('Powersports Generic').getRecordTypeId();
        Id psHondaCard = Schema.SObjectType.Offer_Eligible_Models__c.getRecordTypeInfosByName().get('Powersports Honda card').getRecordTypeId();
        System.debug('Inside defaultFieldValues');
        Set<String> models = new Set<String>();
        Set<String> years = new Set<String>();
        Set<String> trims = new Set<String>();
        Set<String> segmentPS = new Set<String>();
        Set<String> yearsPS = new Set<String>();
        Set<String> categoryPS = new Set<String>();
        Set<String> familyPS = new Set<String>();
        Set<String> modelsPS = new Set<String>();
        Set<String> offer = new Set<String>();
        Set<String> offerPS = new Set<String>();
        map<string,string> brandMap = new map<string,string>{'A'=>'Honda','B'=>'Acura','M'=>'Motorcycle/Powersports'};
        for(Offer_Eligible_Models__c oem : oemList){ 
            if(oem.RecordTypeId == cpoSpecialLease || oem.RecordTypeId == cpoStandardLease || oem.RecordTypeId == newStandardLease || oem.RecordTypeId == newSpecialLease){
            	models.add(oem.Name);
            	years.add(oem.Year__c);
            	trims.add(oem.Trim__c);
                offer.add(oem.Offer__c);
            }
            if(oem.RecordTypeId == psAHFC || oem.RecordTypeId == psBonusBucks || oem.RecordTypeId == psGeneric || oem.RecordTypeId == psHondaCard){
                modelsPS.add(oem.Name);
            	yearsPS.add(oem.Year__c);
            	segmentPS.add(oem.Segment__c);
                categoryPS.add(oem.Category__c);
                familyPS.add(oem.Family__c);
                offerPS.add(oem.Offer__c);
            }
            
        }
        Map<String, Product_Chooser__c> productChoosers = new Map<String, Product_Chooser__c>();
        if(offer.Size() > 0){
        for(Product_Chooser__c pc : [SELECT Product_Model__c, Product_Subdivision__c, Product_Model__r.Product_Model_Id__c,Product_Model__r.Destination_Handling_Amount__c,Product_Model__r.MSRP__c,Product_Model__r.Dealer_Invoice__c, Tier1__c, Tier2__c, Tier3__c,Tier4__c,Tier5__c
                                     FROM Product_Chooser__c 
                                     WHERE Tier1__c IN :years AND Tier3__c =:models AND Tier4__c IN:trims and application_Name__c like 'Current_Offers%']){
                                         String key = pc.Tier1__c + pc.Tier3__c + pc.Tier4__c;
                                         productChoosers.put(key, pc);
                                     }
        }
        Map<String, Product_Chooser__c> productChoosersPS = new Map<String, Product_Chooser__c>();
        if(offerPS.Size() > 0){
        for(Product_Chooser__c pc : [SELECT Product_Model__c, Product_Subdivision__c, Product_Model__r.Product_Model_Id__c,Product_Model__r.Destination_Handling_Amount__c,Product_Model__r.Dealer_Invoice__c,Product_Model__r.MSRP__c, Tier1__c, Tier2__c, Tier3__c,Tier4__c,Tier5__c
                                     FROM Product_Chooser__c 
                                     WHERE Tier1__c IN :yearsPS AND Tier2__c IN:segmentPS AND Tier3__c IN:categoryPS AND Tier4__c IN:familyPS AND Tier5__c IN: modelsPS AND application_Name__c like 'Current_Offers%']){
                                         String key = pc.Tier1__c + pc.Tier2__c + pc.Tier3__c + pc.Tier4__c + pc.Tier5__c;
                                         productChoosersPS.put(key, pc);
                                     }
        }
        
        System.debug('pritning product chooser' +productChoosers);
        for(Offer_Eligible_Models__c oem : oemList){
            System.debug('printing record type name'+oem.RecordType.Name);
            System.debug('printing record type Id' +oem.RecordTypeId);
            if(oem.RecordTypeId == cpoSpecialLease || oem.RecordTypeId == cpoStandardLease || oem.RecordTypeId == newStandardLease || oem.RecordTypeId == newSpecialLease){
                string key = oem.Year__c + oem.Name + oem.Trim__c;
                System.debug('records=>'+productChoosers.get(key));
                if(productChoosers.containsKey(key) == true){
                    if(productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c == null){
                    	productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c = 0;
                    }
                    if(productChoosers.get(key).Product_Model__r.Dealer_Invoice__c == null){
                        productChoosers.get(key).Product_Model__r.Dealer_Invoice__c = 0;
                    }
                    if(productChoosers.get(key).Product_Model__r.MSRP__c == null){
                        productChoosers.get(key).Product_Model__r.MSRP__c = 0;
                    }
                    oem.Invoice_Price_with_DH__c = productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c +  productChoosers.get(key).Product_Model__r.Dealer_Invoice__c;
                    oem.MSRP__c = productChoosers.get(key).Product_Model__r.MSRP__c;
                    oem.Adjusted_MSRP_with_DH__c = productChoosers.get(key).Product_Model__r.Destination_Handling_Amount__c +  productChoosers.get(key).Product_Model__r.MSRP__c;
                }
            }
            else if(oem.RecordTypeId == psAHFC || oem.RecordTypeId == psBonusBucks || oem.RecordTypeId == psGeneric || oem.RecordTypeId == psHondaCard){
                 String key = oem.Year__c + oem.Segment__c + oem.Category__c + oem.Family__c + oem.Name;
                if(productChoosersPS.containsKey(key) == true){  
                    if(productChoosersPS.get(key).Product_Model__r.MSRP__c == null){
                        oem.MSRP__c = null;
                    } else{
                        oem.MSRP__c = productChoosersPS.get(key).Product_Model__r.MSRP__c;
                    }
                    if(productChoosersPS.get(key).Product_Model__r.Destination_Handling_Amount__c == null){
                        oem.Freight_Charge__c = null;
                    } else{
                        oem.Freight_Charge__c = productChoosersPS.get(key).Product_Model__r.Destination_Handling_Amount__c;
                    }
                }
            } 
        }
    }
    
    public static void updateDefaultImage(List<Offer_Eligible_Models__c> oemList){
        Set<String> models = new Set<String>();
        Set<String> years = new Set<String>();
        Set<String> trims = new Set<String>();
        Set<String> offer = new Set<String>();

        map<string,string> brandMap = new map<string,string>{'A'=>'Honda','B'=>'Acura','M'=>'Motorcycle/Powersports'};
        set<string> setFiannceLeaseRecTypes = new set<string>{'CPO_Special_Finance','CPO_Special_Lease','CPO_Special_Program','CPO_Standard_Finance','CPO_Standard_Lease'};
      
        map<string,List<Product_Model_Color__c>> mapProdModelToColor = new map<string,List<Product_Model_Color__c>>();//key - product model id, value- list of product model color records
        map<string,Product_Chooser__c> mapUniqueProductChooser = new map<string,Product_Chooser__c>();//key - Product_Subdivision__c:Application_Name__c:Tier1__c:Tier4__c:Tier3__c, value - Product_Chooser__c
       // Set<Id> modelIds = new Set<Id>();
        map<Id,string> mapOfferRecTypes = GetOfferRecordTypesUtility.getOfferRecordTypeNames();
        for(Offer_Eligible_Models__c oem : oemList){ 
            models.add(oem.Name);
            years.add(oem.Year__c);
            trims.add(oem.Trim__c);
            offer.add(oem.Offer__c);
        }
        Map<String, Offers__c> Offers = new Map<String, Offers__c>([Select Id,Name,recordTypeId,recordType.DeveloperName 
                                                                    from Offers__c
                                                                    where Id IN:offer]);

        Set<Id> modelColor = new Set<Id>();
        Map<String, Product_Chooser__c> productChoosers = new Map<String, Product_Chooser__c>([SELECT Product_Model__c, Product_Subdivision__c, Product_Model__r.Product_Model_Id__c, Tier1__c, Tier2__c, Tier3__c,Tier4__c,Application_Name__c
                                                                                            FROM Product_Chooser__c 
                                                                                            WHERE Tier1__c IN :years AND 
                                                                                            Tier3__c IN :models AND 
                                                                                            Tier4__c IN :trims AND 
                                                                                            Application_Name__c like 'Current_Offers%']);
        
         for(String pcId : productChoosers.keySet())
         {            
            Product_Chooser__c pcRec = productChoosers.get(pcId);
            modelColor.add(pcRec.Product_Model__c);
            mapUniqueProductChooser.put(pcRec.Product_Subdivision__c+':'+pcRec.Application_Name__c+':'+pcRec.Tier1__c+':'+pcRec.Tier4__c+':'+pcRec.Tier3__c,productChoosers.get(pcId));
         } 
        	System.debug('Unique Map Product Chooser'+mapUniqueProductChooser);
        	system.debug('product chooser keyset=>'+mapUniqueProductChooser.KeySet());

         List<Product_Model_Color__c> modelColors = [SELECT Id, Exterior_Color_Name__c, Thumbnail_Image_URL__c,Offer_Image_Thumb_URL__c, Product_Model__c, Exterior_Price_Delta__c 
                                                    FROM Product_Model_Color__c 
                                                    WHERE Product_Model__c IN :modelColor
                                                    ORDER BY Exterior_Color_Name__c ASC]; 
          for(product_model_color__c rec: modelColors)
          {
            if(!mapProdModelToColor.containsKey(rec.Product_Model__c))
            {
                List<Product_Model_Color__c> lstPMC = new List<Product_Model_Color__c>();
                mapProdModelToColor.put(rec.Product_Model__c,lstPMC);// value would be list of pmc
                
            }
            mapProdModelToColor.get(rec.Product_Model__c).add(rec);
           
          }
        System.debug('unique Map Product Model Color'+mapProdModelToColor);
          system.debug('product model color keyset=> '+mapProdModelToColor.KeySet());
        for(Offer_Eligible_Models__c oem : oemList){            
            
            string brand = brandMap.get(oem.Brand__c);
            String application='Current_Offers_New';     
            string recTypeName = mapOfferRecTypes.get(Offers.get(oem.Offer__c).RecordTypeId); 
            system.debug('Rec type:'+recTypeName);    
            if(setFiannceLeaseRecTypes.contains(recTypeName))
            {
                application ='Current_Offers_Used';
            }
            string uniqueModelId = brand+':'+application+':'+oem.Year__c+':'+oem.Trim__c+':'+oem.Name;
			System.debug('oem Key'+uniqueModelId);
            System.debug('oem Key'+mapUniqueProductChooser.containsKey(uniqueModelId));
            if(mapUniqueProductChooser.containsKey(uniqueModelId)){
                Product_Chooser__c pc = mapUniqueProductChooser.get(uniqueModelId); 
                system.debug('Inside if pc:'+pc);
                List<Product_Model_Color__c> pmcList = mapProdModelToColor.get(pc.Product_Model__c);
                system.debug('inside if pmc:'+pmcList);
                system.debug('inside if pmc size:'+pmcList.Size());
                if(pc !=null && pmcList !=null){
                    for(Product_Model_Color__c pmcRec:pmcList){
                    if((pmcRec.Exterior_Price_Delta__c == 0 || pmcRec.Exterior_Price_Delta__c == null) && oem.Default_Image__c == null){
                        oem.Default_Image__c = pmcRec.Offer_Image_Thumb_URL__c;  
                        break;                  	
                    }
                } 
                }
            }           
           
        }
        
    }
    
    public static void updateSort(List<Offer_Eligible_Models__c> offerList){
        set<Id> setOfferIds = new set<id>();      
        map<id,List<Offer_Eligible_Models__c>> mapOfferToModels = new map<id,List<Offer_Eligible_Models__c>>();
        List<Offer_Eligible_Models__c> lstModelToUpdate = new List<Offer_Eligible_Models__c>();

        if(offerList!=null && offerList.size() > 0)
        {
            for(Offer_Eligible_Models__c off: offerList){
                if(off.Offer__c != null){
                    setOfferIds.add(off.Offer__c);
                }
            }
        }
        if(setOfferIds !=null)
        {
            for(Offer_Eligible_Models__c rec:[Select Id,MSRP__c,Year__c,Model__c,Offer__c,Sort_Order__c 
                                from Offer_Eligible_Models__c 
                                where Offer__c IN: setOfferIds ORDER BY Year__C DESC , Model__c DESC, MSRP__c DESC])
                {
                    if(mapOfferToModels.containsKey(rec.Offer__c))
                    {
                        mapOfferToModels.get(rec.Offer__c).add(rec);
                    }
                    else{
                        List<Offer_Eligible_Models__c> models = new List<Offer_Eligible_Models__c>();
                        models.add(rec);
                        mapOfferToModels.put(rec.offer__c,models);
                    }   
                                   
                }
		}
        if(mapOfferToModels!=null)
        {
            for(Id offerId:mapOfferToModels.keySet())
            {
                lstModelToUpdate = sortModels(mapOfferToModels.get(offerId));
            }
        }
        if(lstModelToUpdate.size()> 0)
        {
            update lstModelToUpdate;
        }

    }
    private static List<Offer_Eligible_Models__c> sortModels( List<Offer_Eligible_Models__c> lstModels)
    {
        List<Offer_Eligible_Models__c> updateList = new List<Offer_Eligible_Models__c>(); 
        Decimal sortOrder = 0;
        for(Offer_Eligible_Models__c off:lstModels){
            if(off.Sort_Order__c != null){
                if(off.Sort_Order__c > sortOrder){
                    sortOrder = off.Sort_Order__c;
                }
            }else{
                updateList.add(off);
            }
        }
        if(updateList.Size() > 0){
            For(Offer_Eligible_Models__c off:updateList){
                off.Sort_Order__c = sortOrder + 1;
                sortOrder = sortOrder + 1;
            }
        }
        return updateList;
    }
    
    
    /*
    public static void updateSort(List<Offer_Eligible_Models__c> offer){
        set<Id> ids = new set<Id>();
        for(Offer_Eligible_Models__c off: offer){
            if(off.Offer__c != null){
                ids.add(off.Offer__c);
            }
        }
        List<Offer_Eligible_Models__c> updateList = new List<Offer_Eligible_Models__c>();
        List<Offer_Eligible_Models__c> oem = new List<Offer_Eligible_Models__c>();
        oem = [Select Id,MSRP__c,Year__c,Model__c,Offer__c,Sort_Order__c from Offer_Eligible_Models__c where Offer__c IN: ids ORDER BY Year__C DESC , Model__c DESC, MSRP__c DESC];
        for(Id i:ids){
            List<Offer_Eligible_Models__c> iterList = new List<Offer_Eligible_Models__c>();
            for(Offer_Eligible_Models__c off: oem){
                if(i == off.Offer__c){
                    iterList.add(off);
                }
            }
            if(iterList.Size() > 0){
                List<Offer_Eligible_Models__c> returnList = sortOffer(iterList);
                for(Offer_Eligible_Models__c offerM : returnList){
                    updateList.add(offerM);
                }
                
            }
        }
        System.debug('printing wupdate list'+updateList);
        update updateList;
    }
    
    public static List<Offer_Eligible_Models__c> sortOffer(List<Offer_Eligible_Models__c> iterList){
        List<Offer_Eligible_Models__c> updateList = new List<Offer_Eligible_Models__c>();
        Decimal sortOrder = 0;
        for(Offer_Eligible_Models__c offer:iterList){
            if(offer.Sort_Order__c != null){
                if(offer.Sort_Order__c > sortOrder){
                    sortOrder = offer.Sort_Order__c;
                }
            }else{
                updateList.add(offer);
            }
        }
        if(updateList.Size() > 0){
            For(Offer_Eligible_Models__c off:updateList){
                off.Sort_Order__c = sortOrder + 1;
                sortOrder = sortOrder + 1;
            }
        }
        System.debug('printing return update list'+updateList);
        return updateList;
    }
    */
    public static void deleteCheck(List<Offer_Eligible_Models__c> models){
        Set<String> ids = new Set<String>();
        Set<String> deleteEx = new Set<String>();
        set<String> deletePrism = new set<String>();
        for(Offer_Eligible_Models__c model: models){
            ids.add(model.Offer__c);
        }
        Map<String, Offers__c> Offer = new Map<String, Offers__c>();
        for(Offers__c off : [SELECT Id,Status__c,Synched_with_PRISM__c
                                     FROM Offers__c 
                                     WHERE Id IN : ids]){
                                         if(off.Status__c != 'WIP' && off.Status__c !='Validated' ){
                                             deleteEx.add(off.Id);
                                         }
                                         if(off.Synched_with_PRISM__c == true){
                                             deletePrism.add(off.Id);
                                         }
                                     }
        for(Offer_Eligible_Models__c offrModel: models){
            if(deleteEx.contains(offrModel.Offer__c)){
                    offrModel.adderror('You can delete the model only in WIP or Validated Status');
                }
            if(deletePrism.contains(offrModel.Offer__c)){
                	offrModel.adderror('You can not delete a model when offer is synched with prism');
            }
                
            
        }
    }
    
    public static void editCheck(List<Offer_Eligible_Models__c> models){
        Set<String> ids = new Set<String>();
        Set<String> deleteEx = new Set<String>();
        for(Offer_Eligible_Models__c model: models){
            ids.add(model.Offer__c);
        }
        Map<String, Offers__c> Offer = new Map<String, Offers__c>();
        for(Offers__c off : [SELECT Id,Status__c
                                     FROM Offers__c 
                                     WHERE Id IN : ids]){
                                         if(off.Status__c != 'WIP' && off.Status__c !='Validated' ){
                                             deleteEx.add(off.Id);
                                         }
                                     }
        for(Offer_Eligible_Models__c offrModel: models){
            if(deleteEx.contains(offrModel.Offer__c)){
                    offrModel.adderror('You can edit the model only in WIP or Validated Status');
                }
                
            
        }
    }
public static void editCheckForPrism(Map<Id,SObject> newOfferMap, Map<Id,SObject> oldOfferMap){
    Set<Id> prismIdSet = new Set<Id>();
    
    for(Offer_Eligible_Models__c off : [SELECT Id, Offer__r.Synched_with_PRISM__c
                                     FROM Offer_Eligible_Models__c where Id IN:newOfferMap.keyset()
                                     ]){
                                         if(off.Offer__r.Synched_with_PRISM__c){
                                             prismIdSet.add(off.Id);
                                         }
                                         
                                     }
    Offer_Eligible_Models__c OfferEligModelObj = new Offer_Eligible_Models__c();
    Schema.SObjectType objType = OfferEligModelObj.getSObjectType();
    Map<String, Schema.SObjectField> OEM = Schema.SObjectType.Offer_Eligible_Models__c.fields.getMap();
    Set<String> FieldNameSet = new Set<String>();
    FieldNameSet.add('Featured_Offer');
    FieldNameSet.add('Default_Image');
    for(SObject offrModel: newOfferMap.values()){
        if(prismIdSet.contains(offrModel.Id)){
        Id offerId = offrModel.Id;
        SObject newofferobj = newOfferMap.get(offerId);
        SObject oldofferobj = oldOfferMap.get(offerId);
        
        for (String str : OEM.keyset()) {
            try {
                System.debug('Field name: '+str +'. New value: ' + newofferobj.get(str) +'. Old value: '+ oldofferobj.get(str));
                	if(newofferobj.get(str) != oldofferobj.get(str)) {
                        system.debug('******The value has changed!!!! ');
                        if(!FieldNameSet.contains(str)){
                            offrModel.adderror('You cant update value in ' + str + ' field when offer is sync with PRISM');
                        }
                    }
            }
            catch (Exception e) {
                System.debug('Error: ' + e);
            }
        }
      }
    }
	}  

}
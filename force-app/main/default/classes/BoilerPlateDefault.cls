public class BoilerPlateDefault {
    
    public static Id defBlrPlate(String dfltblrpltname)
    {
        List<BoilerPlate__c> blrplatelst=[select Name,Id,Brand__c from BoilerPlate__c where Status__c='Active'];
        //Setup a Map of Boiler Plate Object
        Map<String,Id> blrplateId=new Map<String,Id>();
        for (BoilerPlate__c blrplate:blrplatelst)
        {
            blrplateId.put(blrplate.Name,blrplate.Id);
        }
        return blrplateId.get(dfltblrpltname);
        
    }
    public static Map<String,Id> defBlrPlateBasedonOfferListforUI(List<Offers__c> offerProcesslst)
    { 
        
        
        set<string> setOfBrandName = new set<string>();
        List<string> setOfRecordTypeName = new List<string>();
         
        for(Offers__c objOffer : offerProcesslst){
            setOfBrandName.add(objOffer.Brand__c);
            setOfRecordTypeName.add(objOffer.RecordTypeId);
        }
        Map<Id,String> mapOfOfferRecordTypeIdAndName = GetOfferRecordTypesUtility.getOfferRecordTypeNames();

         string recTypeName = mapOfOfferRecordTypeIdAndName.get(setOfRecordTypeName[0]); 
        string WithoutUnderSCoreRecordTypeName = recTypeName.replace('_',' ');
        List<BoilerPlate__c> blrplatelst=[select Name,Id,Brand__c,Offer_Type__c  from BoilerPlate__c where Status__c='Active' and Brand__c in :setOfBrandName and Offer_Type__c=:WithoutUnderSCoreRecordTypeName order by createddate DESC];
        //Setup a Map of Boiler Plate Object
        Map<string,Id> blrplateId = new Map<string,Id>();
        Map<string,Id> offeridblrplatemap = new Map<string,Id>();
        for (BoilerPlate__c blrplate:blrplatelst)
        {
            blrplateId.put(blrplate.Name,blrplate.Id);
        }
         
        //Get Boiler Plate Names based on Offer type, Category and Brand
        Map<String,DefaultBoilerPlates__mdt> defaultBlrPlateMdt=DefaultBoilerPlates__mdt.getAll();
        
        for (Offers__c off:offerProcesslst)
        {
            //get Boiler Plate Name
            String recordtypename = Schema.getGlobalDescribe().get('Offers__c').getDescribe().getRecordTypeInfosById().get(off.recordtypeid).getName();
            String blrplatenamemap=off.Brand__c+recordtypename+off.Special_Category__c+off.Product_Type__c;
            string blrplateTempKey = blrplatenamemap.replaceAll( '\\s+', '');
            string blrplateMapKeys = blrplateTempKey.remove('null');
            string blrplateMapKey = blrplateMapKeys.remove('-');
            system.debug('@@@@@blrplateMapKey '+blrplateMapKey);
            if(defaultBlrPlateMdt.containsKey(blrplateMapKey)){
                String test = defaultBlrPlateMdt.get(blrplateMapKey).Default_BLR_Plate_Name__c;
                String blrplatename=defaultBlrPlateMdt.get(blrplateMapKey).Default_BLR_Plate_Name__c;
                system.debug('blrplateId'+blrplateId);
                offeridblrplatemap.put(off.Offer_Header__c,blrplateId.get(blrplatename));  
            }
        }
        system.debug('offeridblrplatemap'+offeridblrplatemap);
        return offeridblrplatemap;
        
    }
    
    
    
}
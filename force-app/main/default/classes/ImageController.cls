public class ImageController {
    
    @AuraEnabled
    public static List<Product_Model_Color__c> getData(Id recId){
        string brand='';
        String appName = '';
        List<Offer_Eligible_Models__c> offerModel = new List<Offer_Eligible_Models__c>();
        offerModel = [Select Id,Year__c,Trim__c,Name,Brand__c,Offer__r.recordType.Name from Offer_Eligible_Models__c where Id=: recId];
        if(offerModel.Size() > 0){
        if(offerModel[0].Brand__c == 'A'){
            brand = 'Honda';
        }
        if(offerModel[0].Brand__c == 'B'){
            brand = 'Acura';
        }
        if(offerModel[0].Brand__c == 'M'){
            brand = 'Motorcycle/Powersports';
        } 
            System.debug('printing recordType'+offerModel[0].Offer__r.recordType.Name);
            if(offerModel[0].Offer__r.recordType.Name == 'CPO Special Finance' || offerModel[0].Offer__r.recordType.Name == 'CPO Special Lease' || offerModel[0].Offer__r.recordType.Name == 'CPO Special Program' || offerModel[0].Offer__r.recordType.Name == 'CPO Standard Finance' || offerModel[0].Offer__r.recordType.Name == 'CPO Standard Lease'){
              appName = 'current_offers_used';
            } else{
                appName ='current_offers_new';
            }
            system.debug('app name'+appName);
    	}  
        List<Product_Chooser__c> chooser = new List<Product_Chooser__c>();
        chooser = [ SELECT Product_Model__c,Product_Subdivision__c, Product_Model__r.Product_Model_Id__c, Tier1__c, Tier2__c, Tier3__c,Tier4__c,Application_Name__c
                  FROM Product_Chooser__c WHERE Product_Subdivision__c =: brand AND
                  Tier1__c =: offerModel[0].Year__c AND Tier3__c =: offerModel[0].Name AND Tier4__c =: offerModel[0].Trim__c AND Application_Name__c =: appName];
        system.debug('printing chooser'+chooser);
        
        List<Product_Model_Color__c> model = new List<Product_Model_Color__c>();
        model =[Select Id,Exterior_Color_Name__c,Offer_Image_Thumb_URL__c,Exterior_Price_Delta__c from Product_Model_Color__c where Product_Model__c =: chooser[0].Product_Model__c ORDER BY Exterior_Color_Name__c ASC];
        return model;
    }
    
    @AuraEnabled
    public static List<Offer_Eligible_Models__c> getModelImage(String recId){
        List<Offer_Eligible_Models__c> offerModel = new List<Offer_Eligible_Models__c>();
        offerModel = [select Id,Default_Image__c from Offer_Eligible_Models__c where Id =: recId];
        return offerModel;
    }
    
    @AuraEnabled
    public static Boolean updateModelImage(String recId , String defaultImage){
        Boolean returnval = true;
        try{
        List<Offer_Eligible_Models__c> offerModel = new List<Offer_Eligible_Models__c>();
        offerModel = [select Id,Default_Image__c from Offer_Eligible_Models__c where Id =: recId];
        if(offerModel.Size() > 0){
            offerModel[0].Default_Image__c = defaultImage;
            update offerModel;
        }
        }Catch(Exception ex){
            returnval = false;
        }
        return returnval;
    }
    
    @AuraEnabled
    public static Boolean removeModelImage(String recId){
        boolean returnValue = true;
        List<Offer_Eligible_Models__c> offerModel = new List<Offer_Eligible_Models__c>();
        offerModel = [select Id,Default_Image__c from Offer_Eligible_Models__c where Id =: recId];
        offerModel[0].Default_Image__c = null;
        update offerModel;
        return returnValue;
    }
    
    @AuraEnabled
    public static Boolean updateModelField(Id rec , String url){
        Boolean returnValue = true;
        List<Offer_Eligible_Models__c> model = new List<Offer_Eligible_Models__c>();
            model = [select Id,Default_Image__c from Offer_Eligible_Models__c where Id =: rec];
        
        
        
        
        return returnValue;
        
    }
    

}
public without sharing class OwnManualsApiController {
    
    @AuraEnabled (cacheable = true)
    public static PSManualsDataWrapper getManualByModelPS(string divisionId,String division,String modelId) {
        if(String.isBlank(divisionId) || String.isBlank(division) ||String.isBlank(modelId) ){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.division)){
                    division = productContext.product.division;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
                if(String.isNotBlank(productContext.product.modelId)){
                    modelId = productContext.product.modelId;
                }
            }
        }
        
        OwnAPIController.setJWTAccessToken();
        List<String> endpointParameters = new List<String>{};
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = divisionId;
        attribute.division = division;
        attribute.modelId = modelId;
        PSManualsData pSManualsData;
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            pSManualsData = (PSManualsData)sessionPart.get('PSmanual' + modelId + divisionId + userId);
        }
        if(pSManualsData == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('GetManualsByModelPS', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            System.debug('@@response'+response);
            System.debug('@@response'+service.sendRequest().getStatusCode());
            OwnAPIController.Error error = (OwnAPIController.Error)JSON.deserialize(response, OwnAPIController.Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                OwnAPIController.setJWTAccessTokenToNULL();
            }
            
            response=response.replace('@id','id');
            response=response.replace('@name','name');
            response=response.replace('@type_cd','type_cd');
            response=response.replace('@description','description');
            response=response.replace('@path','path');
            
            pSManualsData = (PSManualsData)JSON.deserialize(response,PSManualsData.class);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('PSmanual' + modelId + divisionId + userId, pSManualsData);
            }
        }
        PSManualsDataWrapper psData= new PSManualsDataWrapper(pSManualsData);
        return psData;
    }
    
    @AuraEnabled (cacheable = true)
    public static ManualsDataWrapper getManualByVINAuto(string productIdentifier, string divisionId,String division) {
        if(String.isBlank(productIdentifier) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            if(productContext != null){
                if(String.isNotBlank(productContext.product.productIdentifier)){
                    productIdentifier = productContext.product.productIdentifier;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        OwnAPIController.setJWTAccessToken();
        ManualsResultData ManualsDatacache;
        List<String> endpointParameters = new List<String>{};
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = divisionId;
        attribute.vin = productIdentifier;
        attribute.division = division;
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            ManualsDatacache = (ManualsResultData)sessionPart.get('Automanuals' + productIdentifier + divisionId + userId);
        }
        
        if(ManualsDatacache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('GetManualsByVINAuto', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
             JSONParser parser = JSON.createParser(response);
            while(parser.nextToken() != null){
                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'pub')){
                    if(parser.nextToken() == JSONToken.START_OBJECT){
                        cls_pub c=(cls_pub)parser.readValueAs(cls_pub.class);
                        List<cls_pub> lPub=new List<cls_pub>();
                        lPub.add(c);
                        ManualsDataWrapper w=new ManualsDataWrapper();
                        w.isMultiple=false;
                        w.manualsList=lPub;
                        return w;
                    }
                }
            }
            OwnAPIController.Error error = (OwnAPIController.Error)JSON.deserialize(response, OwnAPIController.Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                OwnAPIController.setJWTAccessTokenToNULL();
            }
            ManualsDatacache=(ManualsResultData)JSON.deserialize(response,ManualsResultData.class);
            system.debug('!!response-'+response);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('Automanuals'+ productIdentifier + divisionId + userId,ManualsDatacache);
            }
        }
        ManualsDataWrapper m=new ManualsDataWrapper(ManualsDatacache);
        return m;
    }
    
    @AuraEnabled (cacheable = true)
    public static ManualsDataWrapper getManualByModelIdAuto(string divisionId,String division,string modelId) {
        if(String.isBlank(modelId) || String.isBlank(divisionId)){
            OwnProductController.Context productContext = OwnProductController.getProductContext('');
            system.debug('======>>>>> '+productContext);
            if(productContext != null){
                if(String.isNotBlank(productContext.product.modelId)){
                    modelId = productContext.product.modelId;
                }
                if(String.isNotBlank(productContext.product.divisionId)){
                    divisionId = productContext.product.divisionId;
                }
            }
        }
        OwnAPIController.setJWTAccessToken();
        ManualsResultData ManualsDatacache;
        List<String> endpointParameters = new List<String>{};
            OwnAPIController.Attribute attribute = new OwnAPIController.Attribute();
        attribute.divisionId = divisionId;
        attribute.modelId = modelId;
        attribute.division = division;
        String userId = UserInfo.getUserType() != 'Guest' ? UserInfo.getUserId() : '';
        if(UserInfo.getUserType() != 'Guest'){
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
            ManualsDatacache = (ManualsResultData)sessionPart.get('Automanuals' + modelId + divisionId + userId);
        }
        
        if(ManualsDatacache == null){
            OwnHttpCalloutService service = new OwnHttpCalloutService('GetManualsByModelAuto', attribute, endpointParameters);
            String response = service.sendRequest().getBody();
            system.debug('@@debug'+response);
            JSONParser parser = JSON.createParser(response);
            while(parser.nextToken() != null){
                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'pub')){
                    if(parser.nextToken() == JSONToken.START_OBJECT){
                        cls_pub c=(cls_pub)parser.readValueAs(cls_pub.class);
                        List<cls_pub> lPub=new List<cls_pub>();
                        lPub.add(c);
                        ManualsDataWrapper w=new ManualsDataWrapper();
                        w.isMultiple=false;
                        w.manualsList=lPub;
                        return w;
                    }
                }
            }
            OwnAPIController.Error error = (OwnAPIController.Error)JSON.deserialize(response, OwnAPIController.Error.class);
            if(error.header != null && error.header.errorDescription == 'JWT validation failed'){
                OwnAPIController.setJWTAccessTokenToNULL();
            }
            ManualsDatacache=(ManualsResultData)JSON.deserialize(response,ManualsResultData.class);
            system.debug('!!response-'+response);
            if(UserInfo.getUserType() != 'Guest'){
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.MyGarageConnectedFeature');
                sessionPart.put('Automanuals'+ modelId + divisionId + userId,ManualsDatacache);
            }
        }
        ManualsDataWrapper m=new ManualsDataWrapper(ManualsDatacache);
        return m;
    }
    
    public class PSManualsData{
        public cls_mot mot {get;set;}
    }
    public class cls_mot {
        public cls_db_results db_results {get;set;}
    }
    public class cls_db_results {
        public cls_assets assets {get;set;}
    }
    public class cls_assets {
        public cls_asset[] asset {get;set;}
    }
    public class cls_asset {
        @AuraEnabled public String id {get;set;}	//1363302
        @AuraEnabled public String type_cd {get;set;}	//OWNERMAN
        @AuraEnabled public String name {get;set;}	//2021 Recon (TRX250TM) Owner's Manual
        @AuraEnabled public String description {get;set;}	//2021 Recon (TRX250TM) Owner's Manual
        @AuraEnabled public String path {get;set;}	///documentum/MWOM/ml.remawmom.2021_31hs0650_trx250tm_recon.pdf
    }
    
    public class ManualsResultData{
        public mot mot {get;set;}
    }
    class mot {
        public cls_model model {get;set;}
    }
    class cls_model {
        public String country_cd {get;set;}
        public String lanugage_cd {get;set;}	
        public String vin {get;set;}	
        public String model_id {get;set;}	
        public cls_pubs pubs {get;set;}
    }
    class cls_pubs {
        @AuraEnabled public List<cls_pub> pub {get;set;}
    }
    class cls_pub {
        public String country_cd {get;set;}	
        public String language_cd {get;set;}	
        @AuraEnabled public String model {get;set;}	
        @AuraEnabled public String title {get;set;}	//Common replacement parts guide
        @AuraEnabled public String trim {get;set;}	
        @AuraEnabled public String url {get;set;}	//https://cdn.powerequipment.honda.com/pe/pdf/manuals/otr54654.pdf
        @AuraEnabled public String year {get;set;}	
    }
    
    public class PSManualsDataWrapper{
        @AuraEnabled public List<cls_asset> manualsByModel= new List<cls_asset>();
        @AuraEnabled public boolean isMultiple;
        public PSManualsDataWrapper(PSManualsData data){
            isMultiple =true;
            Integer count =0;
            try{
                if(data.mot.db_results.assets.asset != null){
                    for(cls_asset asset:data.mot.db_results.assets.asset){
                        manualsByModel.add(asset);
                        count++;
                    }
                }
                if(count == 1){
                    isMultiple=false;
                }
                
            }catch(Exception e){
            }
        }
    }
    
    
    
    public class ManualsDataWrapper {
        @AuraEnabled public List<cls_pub> manualsList= new List<cls_pub>();
        @AuraEnabled public boolean isMultiple;
        public ManualsDataWrapper(){}
        public ManualsDataWrapper(ManualsResultData manuals){
            isMultiple =true;
            Integer count =0;
            try{
                if(manuals.mot.model != null){
                    for(cls_pub p:manuals.mot.model.pubs.pub){
                        cls_pub pub = p;
                        manualsList.add(pub);
                        count++;
                    }
                }
                if(count == 1){
                    isMultiple=false;
                }
                
            }catch(Exception e){
                system.debug('Exception'+e);
            }
            
        }
    }
    
    
    @AuraEnabled
    public static String createOwnerManualRequestRecord(Owner_Manual_Request__c info,boolean saveToAccount,String AccountId){
        system.debug('Test');
        try{
            List<Ownership__c> records= [SELECT Id,Honda_Product__r.Product_Identifier__c  from Ownership__c where Honda_Product__r.Product_Identifier__c =:info.Product_Identifier__c AND Product_Owner__c =:AccountId];
            if(records.Size() > 0){
                info.Ownership__c = records[0].Id;
            }
            String msg = '';
            insert info;
            if(saveToAccount ==true){
                Account a=new Account();
                a.Id=AccountId;
                a.PersonMailingStreet=info.Street__c;
                a.PersonMailingCity=info.City__c;
                a.PersonMailingPostalCode=info.Postal_Code__c;
                a.Phone=info.Phone__c;
                a.PersonMailingState=info.State__c;
                //     a.email=info.Email__c;
                update a;
            }
            msg = 'Record Created';
            String street2='';
            String requestType='';
            if(info.Book_Type__c == 'OM'){
                requestType='Owner\'s Manual';
            }else if (info.Book_Type__c == 'NM'){
                requestType='Navigation Manual';
            }else if (info.Book_Type__c == 'OM,NM'){
                requestType='Navigation Manual and Owner\'s Manual';
            }else{
                requestType='Rear Entertainment System Booklet in Braille' ;
            }
            if(info.Street2__c != null && info.Street2__c != 'null'){
                street2=info.Street2__c; 
            }else{
                street2=''; 
            }

            List<String> toAddress=new List<String>();
            toAddress.add(System.Label.ManualRequestEmail);
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddress);
            mail.setSubject('Online Request for free Printed Manual ');
            String bodyText='Dear Support User,\n\n';
            bodyText+='An online request for free printed manual has been received for '+requestType+' for the '+info.Model_Year__c+' '+info.Model_Name__c+'. Please ship the manuals to the below address:\n\n';
            bodyText+='1.	Customer name: '+info.First_Name__c+' '+info.Last_Name__c+'\n';
            bodyText+='2.	Street Address Line 1: '+info.Street__c+'\n';
            bodyText+='3.	Street Address Line 2: '+street2+'\n';
            bodyText+='4.	City: '+info.City__c+'\n';
            bodyText+='5.	State: '+info.State__c+'\n';
            bodyText+='6.	Zip Code: '+info.Postal_Code__c+'\n';
            bodyText+='7.	VIN: '+info.Product_Identifier__c+'\n';
            bodyText+='8.	E-mail: '+info.Email_Address__c+'\n';
            bodyText+='9.	Phone Number: '+info.Phone__c+'\n\n';
            bodyText+='Regards,\n';
            bodyText+='Owners Team \n\n';       
            mail.setPlainTextBody(bodyText);
            List<Messaging.SingleEmailMessage> allmsg=new List<Messaging.SingleEmailMessage>();
            allmsg.add(mail);
            Messaging.sendEmail(allmsg,false);
            
            return msg;
            
        } catch (Exception exp){
            system.debug(exp);
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    
}
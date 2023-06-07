public without sharing class OwnWarrantyController {
    
    @AuraEnabled
    public static string update_UserHasWarranty(String vinNumber, String modelId, Boolean isPSP) {
        String criteria = '';
        Boolean hideWarranty = false;
        User user = [SELECT HideWarranty__c From User Where ID =: UserInfo.getUserId()];
        
        if(isPSP && String.isBlank(getSegmentValue(modelId))){
            user.HideWarranty__c = true;
            update user;
            criteria = 'Unable to find segment, model not available';
        }else{
            if(String.isBlank(vinNumber)){
                if(user.HideWarranty__c){
                    user.HideWarranty__c = false;
                    update user;
                }
                criteria = 'No vin criteria';
            }else{
                List<Honda_Product__c> products = [SELECT Is_Warrany_Canceled__c, Warranty_Factory_Extended_Date__c, Standard_Warranty_End_Date__c FROM Honda_Product__c 
                                                   WHERE Product_Identifier__c = :vinNumber];
                if(products.size() > 0){
                    criteria = 'Product found';
                    Honda_Product__c prod = products[0];
                    if(prod.Is_Warrany_Canceled__c){
                        hideWarranty = true;
                        criteria = 'Warranty cancelled true';
                    }else{
                        if(prod.Warranty_Factory_Extended_Date__c != NULL){
                            criteria = 'Warranty extended date criteria';
                            hideWarranty = prod.Warranty_Factory_Extended_Date__c > System.today() ? false : true;
                        }else if(prod.Standard_Warranty_End_Date__c != NULL){
                            criteria = 'Warranty end date criteria';
                            hideWarranty = prod.Standard_Warranty_End_Date__c > System.today() ? false : true;
                        }
                    }
                }else{
                    criteria = 'Product not found';
                }
                user.HideWarranty__c = hideWarranty;
                update user;
            }    
        }
        
        return criteria;
    }
    
    @AuraEnabled
    public static Map<String, Boolean> checkUserHasWarranty(String vinNumber) {
        String criteria = '';
        Boolean hideWarranty = false;
        
        if(String.isBlank(vinNumber)){
            hideWarranty = false;
            criteria = 'No vin criteria';
        }else{
            List<Honda_Product__c> products = [SELECT Is_Warrany_Canceled__c, Warranty_Factory_Extended_Date__c, Standard_Warranty_End_Date__c FROM Honda_Product__c 
                                               WHERE Product_Identifier__c = :vinNumber];
            if(products.size() > 0){
                criteria = 'Product found';
                Honda_Product__c prod = products[0];
                if(prod.Is_Warrany_Canceled__c){
                    hideWarranty = true;
                    criteria = 'Warranty cancelled true';
                }else{
                    if(prod.Warranty_Factory_Extended_Date__c != NULL){
                        criteria = 'Warranty extended date criteria';
                        hideWarranty = prod.Warranty_Factory_Extended_Date__c > System.today() ? false : true;
                    }else if(prod.Standard_Warranty_End_Date__c != NULL){
                        criteria = 'Warranty end date criteria';
                        hideWarranty = prod.Standard_Warranty_End_Date__c > System.today() ? false : true;
                    }
                }
            }else{
                criteria = 'Product not found';
            }
        }  
        System.debug('criteria: '+criteria);
        return new Map<String, Boolean>{criteria => hideWarranty};
    }
    @AuraEnabled
    public static String getWarrantyEndDate(String vinNumber){
            String enddate='';
            if(!String.isBlank(vinNumber)){
                List<Honda_Product__c> products = [SELECT Is_Warrany_Canceled__c, Warranty_Factory_Extended_Date__c, Standard_Warranty_End_Date__c FROM Honda_Product__c 
                                                   WHERE Product_Identifier__c = :vinNumber];
                if(products.size() > 0){
                    if(products[0].Standard_Warranty_End_Date__c != null){
                        Date standardWarrantyEndDt=products[0].Standard_Warranty_End_Date__c ;
                    return DateTime.newInstance(standardWarrantyEndDt.year(), standardWarrantyEndDt.month(), standardWarrantyEndDt.day(), 19, 37, 55).format('MM/dd/yyyy');
                    }
                }
            }
            return enddate;
       }  
       
       
    public static Integer getSegmentField(){
        Product_Chooser_Control__c productChooserControl = [SELECT Tier_Number__c FROM Product_Chooser_Control__c Where Tier_Name__c = 'Segment' LIMIT 1];
        return Integer.valueOf(productChooserControl.Tier_Number__c);
    }
    
    @AuraEnabled (cacheable = true)
    public static string getSegmentValue(String modelId){
        Map<Integer, String> tierFiledMap = new Map<Integer, String>{1 => 'Tier1__c', 2 => 'Tier2__c', 3 => 'Tier3__c', 4 => 'Tier4__c', 5 => 'Tier5__c', 6 => 'Tier6__c'};
            String segment = '';
        if(String.isNotBlank(modelId)){
            List<Product_Chooser__c> productChoosers = [SELECT Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c FROM Product_Chooser__c 
                                                        where Product_Model__r.Product_Model_ID__c =:modelId ];
            if(productChoosers.size() > 0){
                Product_Chooser__c productChooser = productChoosers[0];
                segment = String.valueOf(productChooser.get(tierFiledMap.get(getSegmentField())));
            }
        }
        return segment;
    }
    @AuraEnabled (cacheable = true)
    public static String getPESerialNumberLocatorUrl(){
        return Label.PE_Serial_Number_Locator;
    }
    @AuraEnabled (cacheable = true)
    public static String getPEOrMarineRecallsUpdateurl(String division){
        if(division == 'Marine'){
            return Label.Marine_Recalls_and_update;
        }else{
            return Label.PE_Recalls_and_update;
        }
    }
    @AuraEnabled(cacheable=true)
    public static String getUserMailingState(){
        String userID = UserInfo.getUserId();
        System.debug('userID-'+userID);
        List<User> user=[SELECT Id,AccountId FROM User WHERE Id=:userID LIMIT 1];
        System.debug('accountID-'+user[0].AccountId);
        String accountID=user[0].AccountId;
        List<Account> account = [SELECT Id, PersonMailingState FROM Account WHERE Id = :accountID LIMIT 1];
        if(account.size()>0){
            System.debug('state='+account[0].PersonMailingState);
            return account[0].PersonMailingState;
        }
        else{
            return '';
        }
    }
    
}
global class Batch_productChooserControlOrgCache implements Database.Batchable<Sobject>{
    
    global Batch_productChooserControlOrgCache(){
        
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.MyGarage');
        orgPart.put('ProductChooserControl', new Map<String, List <Product_Chooser_Control__c>> ());
    }
    
    global Database.QueryLocator start(Database.BatchableContext dt){
        return Database.getQueryLocator('Select id,Product_Subdivision__c,Tier_Name__c,Tier_Number__c,Product_Chooser_Control_Alternate_Identi__c from Product_Chooser_Control__c WHERE Application_Name__c = \'My_Garage\' limit 50000');
    }
    
    global void execute(Database.BatchableContext dt, List<Product_Chooser_Control__c> scope){
        // Get partition
        
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.MyGarage');
        Map<String, List <Product_Chooser_Control__c>> pccMap = new Map<String, List <Product_Chooser_Control__c>>();
        pccMap = (Map<String, List <Product_Chooser_Control__c>>)Cache.Org.get('local.MyGarage.ProductChooserControl');
        
        for(Product_Chooser_Control__c pcc: scope){
            if(pccMap.containsKey(pcc.Product_Subdivision__c)){
                pccMap.get(pcc.Product_Subdivision__c).add(pcc);
            }else{
                List <Product_Chooser_Control__c> newList = new List <Product_Chooser_Control__c>();
                newList.add(pcc);
                pccMap.put(pcc.Product_Subdivision__c, newList);
            }            
        }
        
        //pushing data to org cache
        orgPart.put('ProductChooserControl', pccMap);
    }
    
    public void finish(Database.BatchableContext dt){
    }
}
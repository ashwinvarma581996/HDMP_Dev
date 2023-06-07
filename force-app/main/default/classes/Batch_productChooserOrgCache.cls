global class Batch_productChooserOrgCache implements Database.Batchable<Sobject>{

    private String division;
    private final String cacheKey;
    private static final String cacheKeyPrefix = 'ProductChooser';

    public static String getCacheKey(String division){
        return cacheKeyPrefix + (division == 'Motorcycle/Powersports' ? 'Powersports' : division);
    }
  
    global Batch_productChooserOrgCache(String division){
        this.division = division;
        this.cacheKey = getCacheKey(division);
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.MyGarage');
	    orgPart.put(this.cacheKey, new List<Product_Chooser__c>());	
    }
    
 	global Database.QueryLocator start(Database.BatchableContext dt){
       return Database.getQueryLocator('Select id, Product_Subdivision__c, Tier1__c, Tier2__c, Tier3__c, Tier4__c, Tier5__c, Tier6__c, Product_Model__c, Product_Model__r.Product_Model_Id__c, Alternate_Product_Chooser_Identifier__c, Application_Name__c from Product_Chooser__c WHERE Application_Name__c = \'My_Garage\' AND Product_Subdivision__c = \'' + (this.division == 'Powersports' ? 'Motorcycle/Powersports' : this.division) + '\' limit 50000');
    }
    
    global void execute(Database.BatchableContext dt, List<Product_Chooser__c> scope){
        // Get partition
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.MyGarage');
        //Map<String, List <Product_Chooser__c>> pcMap = new Map<String, List <Product_Chooser__c>> ();
        //pcMap = (Map<String, List <Product_Chooser__c>>)Cache.Org.get('local.MyGarage.ProductChooser');
        /* for(Product_Chooser__c pc: scope){
            if(pcMap.containsKey(pc.Product_Subdivision__c)){
                pcMap.get(pc.Product_Subdivision__c).add(pc);
            }else{
                List <Product_Chooser__c> newList = new List <Product_Chooser__c>();
                newList.add(pc);
                pcMap.put(pc.Product_Subdivision__c, newList);
            }
        } */

        // If a List of Product Chooser records has already been cached this run, retrieve and use it; otherwise, create a new list to be filled and stored.

        List<Product_Chooser__c> pcList = (orgPart.contains(this.cachekey)) ? (List<Product_Chooser__c>) orgPart.get(this.cacheKey) : new List<Product_Chooser__c>();
        for (Product_Chooser__c pc : scope){
            pcList.add(pc);
        }
        
        //pushing data to org cache
        orgPart.put(this.cacheKey, pcList);
    }
    
    global void finish(Database.BatchableContext dt){
        Batch_productChooserControlOrgCache controllerBatch = new Batch_productChooserControlOrgCache();
        Database.executeBatch(controllerBatch);
    }
}
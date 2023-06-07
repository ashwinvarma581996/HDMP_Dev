//************************************************************************************************ 
// File Name:       GetOMModelDetailsUtility.cls
// Summary:         Apex Class for to Retrieve Model Names, Trim , Year based on inbound Model Ids
// Created On:      03-11-2023
// Created By:      Rama Iyer
// Test Classes:    GetOMModelDetailsUtility_Test.cls
// JIRA Story :     OMP-156,OMP-76,OMP-104,OMP-103
//================================================================================================
public class GetOMModelDetailsUtility {
    
   /* public static Map<String,Product_Model__c> getModelDetailsbyModelId(Set<String> modelIds){
        Map<String,Product_Model__c> prodmodelidmap=new Map<String,Product_Model__c>();
        for (Product_Model__c prodmodel:[select Id,Model_Name__c,Model_Year__c,Product_Model_Id__c,Trim__c,MSRP__c from Product_Model__c where Product_Model_Id__c in : modelIds])
        {
            prodmodelidmap.put(prodmodel.Product_Model_Id__c,prodmodel);
        }   
        return prodmodelidmap;
    }*/
    
      public static Map<String,Product_Model__c> getModelDetailsbyModelId(set<String> modelIds){
        Map<String,Product_Model__c> prodmodelidmap=new Map<String,Product_Model__c>();
        Schema.DescribeSObjectResult productmodelobj  = Product_Model__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> prodmodelfieldmap = productmodelobj.fields.getMap();
        String prodmodelquery='';

        for( String prodmodelfld : prodmodelfieldmap.keySet() )
        {
                Schema.SObjectField field = prodmodelfieldmap.get( prodmodelfld );
   			    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                   prodmodelquery+=fieldDescribe.getName()+',';
        }
        prodmodelquery=('Select '+prodmodelquery+'from Product_Model__c').replace(',from',' from');
        List<String> applicationames=new List<String>{'Current_Offers_Used','Current_Offers_New'};//Modify this line to add more application names if applicable
        
        //prodmodelquery=prodmodelquery+' where Product_Model_Id__c in :modelIds';
        List<Product_Model__c> prodmodellst=Database.Query(prodmodelquery+' where Product_MOdel_Id__c in :modelids and Id in (Select Product_Model__c from Product_Chooser__c where Application_Name__c in :applicationames)');
        for (Product_Model__c prodmodel:prodmodellst)
        {
            prodmodelidmap.put(prodmodel.Product_Model_Id__c,prodmodel);
        }   
        return prodmodelidmap;
    }
	
}
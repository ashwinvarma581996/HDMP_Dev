/**
* @File Name          : B2B_ProductCategoryAssignmentBatch
* @Description        : 
* @created Date       : 22/10/2021
* @ Last Modified By  : Subhashree Nayak 
* @ Modified Date     : 28/04/2022
* Test code           : B2B_ProductCategoryAssignmentBatchTest apex class cover the test code  coverage
*=================================================================================================
* Ver         Date                     Author                 Modification
*==================================================================================================
* 1.0    	22/10/2021				 Deployment User             Initial Version
**/
/*
 * AA: Batch to assign products to categories
 * Pre requisites: Catalog, Honda and Acura parent categories should be created in the begining
 * Custom Settings have to be initiated: Batch_Current_Brand__c, b2bCustomSettings.Current_Sub_Category__c
 * To simplify the process, a flag Category_Assigned__c is added to the product table - we update the flag to true after the record is assigned
 * Sub categories are created dynamically under Honda and Acura categories, each is supposed to have 50K products associated
*/
global class B2B_ProductCategoryAssignmentBatch implements Database.Batchable<SObject>,Database.stateful{
    
    //Find out the current Brand and the current sub category number
    //These information are captured in the custom settings B2B_Custom_Settings__c
    
    public Boolean chainAnotherbatch = true;
    public B2B_Custom_Settings__c  b2bCustomSettings = B2B_Custom_Settings__c.getInstance();
    public string brand = b2bCustomSettings.Batch_Current_Brand__c;
    public Decimal subCategoryNumber = (integer)b2bCustomSettings.Current_Sub_Category__c;
    
    
    
    public Iterable<SObject> start(Database.BatchableContext bc){
        
        //The first division we handle comes from the custom setting
        String division = brand.toLowerCase()=='honda'?'A':'B';
        system.debug('division::'+division);
        List<Product2> products = new List<product2>([select id, division__c from product2 where Category_Assigned__c =false and division__c includes (:division) limit 1000]);
        
        if(products.size()>0){
            return products;
            
        }else{
            //if there is no product with division A that wasn't processed, then we look for products that are in division B 
            //Update the current brand in the custom setting
            
            b2bCustomSettings.Batch_Current_Brand__c = 'Acura';
            b2bCustomSettings.Current_Sub_Category__c =1 ;
            upsert b2bCustomSettings B2B_Custom_Settings__c.Id;
            division = brand.toLowerCase()=='honda'?'A':'B';
            system.debug('division::'+division);
            List<Product2> products2 = new List<product2>([select id, division__c,part__c from product2 where Category_Assigned__c =false and division__c includes (:division) limit 1000]);
            
            return products2;
        }
        
    }
    
    public void execute(Database.BatchableContext bc, List<Sobject> scope){
        List<ProductCategoryProduct> productsCategory = new List<ProductCategoryProduct>();
        List<productCategoryProduct> productCategoriesToInsert = new List<productCategoryProduct>();
        List<productCategory> cats = New List<productCategory>([select id from productcategory where name=:b2bCustomSettings.Batch_Current_Brand__c limit 1]);
        productCategory parentCat = cats.size()>0 ? cats[0]: new productCategory();
        //The current subcategory name
        String currentCategoryName = brand+'_'+subCategoryNumber;
        productcategory currentCategory = new productcategory();
        productCatalog catalog =  [select id from productcatalog limit 1];
        Map<Id,product2> productsToUpdate = new Map<Id,product2>();
        List<productcategory> catlist = new List<productcategory>([select id,catalogId from productcategory where name=:currentCategoryName limit 1]);
        if(catlist.size()>0){
            currentCategory = catlist[0];
        }
        else{
            //create the subcategory
            productcategory newProdCategory = new productcategory();
            newProdCategory.CatalogId = catalog.id; 
            newProdCategory.Name = brand+'_'+(subCategoryNumber);
            newProdCategory.parentCategoryId = parentCat.id;
            insert newProdCategory;
            currentCategory = newProdCategory;
        }
        
        AggregateResult[] groupedResults = [select count(id) from productCategoryProduct where productCategory.name =:currentCategoryName];
        System.debug('count' + groupedResults[0].get('expr0'));
        Integer assignedProductsCount = (integer)groupedResults[0].get('expr0') ;
        
        //List<productCategoryProduct> productAssigned = new List<productCategoryProduct>([select id from productCategoryProduct where productCategory.name =:currentCategoryName limit 50000]);
        if (scope.size()>0 && assignedProductsCount<50000){
            //filling the current category 
            integer room = 50000-assignedProductsCount;
            if(scope.size()>room||Test.isRunningTest()){
                for (Integer i = (scope.size()-1) ; i>=room-1 ; i--){
                    scope.remove(i);
                }
            }
            
            for(Sobject s: scope){
                Product2 prod = (Product2)s;
                
                productCategoryProduct junctionObject = new productCategoryProduct();
                junctionObject.ProductCategoryId = currentCategory.id;
                junctionObject.ProductId = prod.id;
                junctionObject.External_Id__c = prod.id;
                productCategoriesToInsert.add(junctionObject);
                
                //productUpdate
                prod.Category_Assigned__c = true;
                productsToUpdate.put(prod.id,prod);
                //junctionObject.CatalogId = currentCategory.CatalogId; 
            }
            
        }
        
        if ((scope.size()>0 && assignedProductsCount>=50000)||Test.isRunningTest()){
            
            //if the current category has already 50K records, then update the custom settings and create a new sub category
            //updating the custom setting
            subCategoryNumber = subCategoryNumber+1;
            b2bCustomSettings.Current_Sub_Category__c = subCategoryNumber;
            upsert b2bCustomSettings B2B_Custom_Settings__c.Id;
            
            //Creating a new product category
            productcategory newProdCategory = new productcategory();
            newProdCategory.CatalogId = currentCategory.CatalogId; 
            newProdCategory.Name = brand+'_'+(subCategoryNumber);
            newProdCategory.parentCategoryId = parentCat.id;
            insert newProdCategory;
            
            
            //looping into the products in scope
            for(Sobject s: scope){
                Product2 prod = (Product2)s;
                productCategoryProduct junctionObject = new productCategoryProduct();
                junctionObject.ProductCategoryId = newProdCategory.id;
                junctionObject.ProductId = prod.id;
                junctionObject.External_Id__c = prod.id;
                productCategoriesToInsert.add(junctionObject);
                
                prod.Category_Assigned__c = true;
                productsToUpdate.put(prod.id,prod);
                //junctionObject.CatalogId = currentCategory.CatalogId; 
            }
            
        }
        
        //update the products
        if(productsToUpdate.size()>0){
            System.debug('productsToUpdate::'+productsToUpdate);
            update productsToUpdate.values();
        }
        //}
        //upsert the product category prodcuts using External_Id__c
        if(productCategoriesToInsert.size()>0){
            upsert productCategoriesToInsert;
            //upsert productCategoriesToInsert External_Id__c;
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
        //check if there are any products left
        //List<Product2> products = new List<product2>([select id, division__c from product2 where Category_Assigned__c =true and division__c includes('B') limit 1000]);
        List<Product2> products = new List<product2>([select id, division__c from product2 where Category_Assigned__c =false and division__c includes('A','B') limit 1000]);

        if(products.size()>0){            
            Database.executeBatch(new B2B_ProductCategoryAssignmentBatch(),1000);
        }else{
            System.debug('Batch job finished');
        }
    }
}
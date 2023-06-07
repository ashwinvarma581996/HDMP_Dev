/**
* @File Name          : B2B_ProductCategoryAssignmentBatchTest
* @Description        : covers the test coverage for B2B_ProductCategoryAssignmentBatch Apex class
* @created Date       : 22/10/2021
* @Modified By        : Palak Gupta 
* @ Modified Date     : 18/05/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0    	22/10/2021				 Deployment User             Initial Version
**/

@isTest
public class B2B_ProductCategoryAssignmentBatchTest {
    
	@isTest
    public static void testProductCategoryBatch() 
    {	 
        		User usid=[select id from user limit 1];
        
        		system.runAs(usid){
        		Account objAccount = B2B_TestDataFactory.createAccount(true);
            	
            	List<Product2> prod2=new List<Product2>();
            	for(Integer i=0;i<=2;i++)
                {
                        Product2 product = new Product2();
                        
                        product.Name = 'Test Product_'+i;
                        //product.DealerPrice__c = 7500;
                        product.Length_in__c = 12;
                        product.Width_in__c = 12;
                        product.Height_in__c = 12;
                        product.Weight_lbs__c = 20; 
                        product.StockKeepingUnit='testunit'+i;
                        product.Category_Assigned__c=false;
                        product.Division__c='B';
                        prod2.add(product);
                }
            		 
            	insert prod2;
                    
            	Product2 prod=[select id,Division__c from Product2 where Name='Test Product_1'];
            			prod.Division__c='A';
            			prod.Category_Assigned__c=true;
            	update prod;
                    Product2 prod3=[select id,Division__c from Product2 where Name='Test Product_2'];
            			//prod.Division__c='C';
            			prod.Category_Assigned__c=true;
            	update prod;
                    
            	productcatalog prodcatlog=new productcatalog();
            			prodcatlog.name='Honda Catlog';
            	insert prodcatlog;
                
                //productcategory prodcat=new productcategory();
                    	ProductCatalog objProdCatalog = new ProductCatalog();
        			objProdCatalog.Name = 'Test Product Catalog';
                            insert objProdCatalog;
                    ProductCategory objProdCategory = new ProductCategory();
                            objProdCategory.Name = 'honda_1';
                            objProdCategory.CatalogId = objProdCatalog.Id;
                            insert objProdCategory;
                   ProductCategoryProduct testproduct = new ProductCategoryProduct();
                           testproduct.ProductId = [select id from Product2 where Name='Test Product_1'].id;
                            testproduct.ProductCategoryId = objProdCategory.Id;
                    		testproduct.External_Id__c='test';
            		insert testproduct;
            	
        		B2B_Custom_Settings__c objB2BCustomSetting = new B2B_Custom_Settings__c();
        				objB2BCustomSetting.Default_Guest_Account__c = objAccount.id;
        				objB2BCustomSetting.name = 'test';
            			objB2BCustomSetting.Current_Sub_Category__c=1;
        				objB2BCustomSetting.SetupOwnerId = usid.id;
        				objB2BCustomSetting.Batch_Current_Brand__c='honda';
        				insert objB2BCustomSetting;
         
         		Test.startTest();
         				Id batchJobId = Database.executeBatch(new B2B_ProductCategoryAssignmentBatch());
     	 		Test.stopTest();
        }
        
    }	
    
}
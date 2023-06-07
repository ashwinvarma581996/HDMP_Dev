@isTest
public class FindProductControllerTest {
	
    @testSetup static void testSetup(){
        
            //create Vehicle record
            Vehicle__c vehicleObj = new Vehicle__c(
                Name = 'Test',
                Model__c = 'Test Model',
                Model_Id__c = 'Testmodel_01',
                eConfigDivisionID__c = 'A',
                Year__c = 2021,
                Trim__c = 'Test' 
            );
            Insert vehicleObj;

			Vehicle__c vehicleObj2 = new Vehicle__c(
                Name = 'Test_2',
                Model__c = 'Test Model_2',
                Model_Id__c = 'Testmodel_02',
                eConfigDivisionID__c = 'A',
                Year__c = 2020,
                Trim__c = 'Test_2'
            );
            Insert vehicleObj2;
            
            //Create Honda product
            Id hondaAutoRecTypeId = Schema.SObjectType.Honda_Product__c.getRecordTypeInfosByDeveloperName().get('Honda_Auto').getRecordTypeId();
            Honda_Product__c product = new Honda_Product__c(
                RecordTypeId = hondaAutoRecTypeId,
                Name = 'Accord'
/*                 Model_Year__c = '2021',
                Model_Name__c = 'Accord2021',
                Product_division__c = 'A',
                Product_Subdivision__c = 'Honda' */
            ); // Fields no longer in use (DOE-3220)
            Insert product;
           
        	Product_Chooser_Control__c productChooserControl = new Product_Chooser_Control__c(
            	Application_Name__c = 'My_Garage',
                Product_Chooser_Control_Alternate_Identi__c = 'My_GarageHonda1',
                Product_Subdivision__c = 'Honda',
				Tier_Name__c = 'Model',
				Tier_Number__c = 1
            );
        	Insert productChooserControl;
        	Product_Chooser_Control__c productChooserControl1 = new Product_Chooser_Control__c(
            	Application_Name__c = 'My_Garage',
                Product_Chooser_Control_Alternate_Identi__c = 'My_GarageAcura1',
                Product_Subdivision__c = 'Acura',
				Tier_Name__c = 'Model',
				Tier_Number__c = 1
            );
        	Insert productChooserControl1;
        
        	Product_Model__c product_modelObj = new Product_Model__c(
                Product_Model_ID__c = 'RW2H8LJNW',
                Product_Division__c = 'B',
                Product_Subdivision__c = 'Acura',
                Model_Year__c = '2018',
                Model_Name__c = '8 Speed Dual-Clutch');
            insert product_modelObj;
        
        	Product_Chooser__c productChooser = new Product_Chooser__c(
            	Alternate_Product_Chooser_Identifier__c = 'My_GarageAcura2018ILXwith AcuraWatch Plus 8 Speed Dual-Clutch',
                Application_Name__c = 'My_Garage',
                Product_Subdivision__c = 'Acura',
                Tier1__c = '2018', 
                Tier2__c = 'ILX',
                Tier3__c ='8 Speed Dual-Clutch',
                Product_Model__c = product_modelObj.Id
            );
        	Insert productChooser;
    }
    
    @isTest static void test() {
        List <Object> testYearsList = new List <Object>();
        testYearsList = FindProductController.getYears('A');
        
        System.assert(testYearsList.size() == 2);
        
        FindProductController.getModels('A',2021);
        FindProductController.getTrims('A',2021,'Test Model');
        FindProductController.getProductModelId('A');
        
        FindProductController n = new FindProductController();

    }
    
    @isTest static void getProductChooserControlTest() {
        Cache.Org.put('local.MyGarage.ProductChooserControl', new Map<String, List <Product_Chooser_Control__c>>());
        List<Product_Chooser_Control__c> pdcctrl = FindProductController.getProductChooserControl('Honda');
        System.assert(!pdcctrl.isEmpty(),'List is not Empty');
    }
    @isTest static void getProductChooserDataTest() {
        Cache.Org.put('local.MyGarage.ProductChooser', new Map<String, List <Product_Chooser__c>> ());
        List<Product_Chooser__c> pdcr = FindProductController.getProductChooserData('Acura');
        System.assertEquals(pdcr.isEmpty(), false);
    }
    @isTest static void getTrimsTest() {
        FindProductController.getTrims('A', 2021, 'RDX');
        FindProductController.getTrims('A', '2021', 'RDX');
    }
}
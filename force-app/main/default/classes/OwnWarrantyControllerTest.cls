@isTest
private class OwnWarrantyControllerTest {
    @isTest static void update_UserHasWarrantyTest(){
        Honda_Product__c honda_productObj = new Honda_Product__c(
            Name = 'honda_product',
            Standard_Warranty_End_Date__c = System.today(),
            Standard_Warranty_Start_Date__c = System.today(),
            Warranty_Factory_Extended_Date__c = System.today(),
            Is_Warrany_Canceled__c = true,
            Product_Identifier__c = '29UUA66204A054612');
         insert honda_productObj;
        Honda_Product__c honda_productObj1 = new Honda_Product__c(
            Name = 'honda_product',
            Standard_Warranty_End_Date__c = System.today(),
            Standard_Warranty_Start_Date__c = System.today(),
            Warranty_Factory_Extended_Date__c = System.today(),
            Is_Warrany_Canceled__c = false,
            Product_Identifier__c = '29UUA66204A054611');
         insert honda_productObj1;
        
        Product_Chooser_Control__c prodChC = new Product_Chooser_Control__c(Name='Test', Tier_Name__c = 'Segment' , Tier_Number__c = 2.0);
        insert prodChC;
        Product_Model__c prodModel = new Product_Model__c();
        prodModel.Product_Model_ID__c = 'RL6H2NEW';
        insert prodModel;
        
        Product_Chooser__c prodChooser = new Product_Chooser__c();
        prodChooser.Name = 'TestName';
        prodChooser.Tier1__c = '2022';
        prodChooser.Tier2__c = 'Accord Sedan';
        prodChooser.Tier3__c = '1.5T LX Continuously Variable Transmission';
        prodChooser.Application_Name__c = 'My_Garage';
        prodChooser.Product_Subdivision__c = 'Honda';
        prodChooser.Product_Model__c = prodModel.Id;
        insert prodChooser;
        
        OwnWarrantyController.update_UserHasWarranty('29UUA66204A054612','RL6H2NEW',true);
        OwnWarrantyController.update_UserHasWarranty('29UUA66204A054611','RL6H2NEW',false);
        OwnWarrantyController.update_UserHasWarranty('','RL6H2NEW',true);
    }
    @isTest static void getPEOrMarineRecallsUpdateurlTest(){
        OwnWarrantyController.getPEOrMarineRecallsUpdateurl('Marine');
        OwnWarrantyController.getPEOrMarineRecallsUpdateurl('Powerequipement');
    }
    @isTest static void getPESerialNumberLocatorUrlTest(){
        OwnWarrantyController.getPESerialNumberLocatorUrl();
    }
    @isTest static void getSegmentValueTest(){
        OwnWarrantyController.getSegmentValue('ABC');
    }
    @isTest static void getWarrantyEndDate(){
        OwnWarrantyController.getWarrantyEndDate('5FNRL6H79KB126851');
	}
    @isTest static void getSegmentFieldTest(){
        insert new Product_Chooser_Control__c(Name='Test', Tier_Name__c = 'Segment' , Tier_Number__c = 2.0);
        OwnWarrantyController.getSegmentField();
    }
    @isTest static void getUserMailingStateTest(){
        OwnWarrantyController.getUserMailingState();
        Honda_Product__c honda_productObj1 = new Honda_Product__c(
            Name = 'honda_product1',
            Standard_Warranty_End_Date__c = System.today(),
            Standard_Warranty_Start_Date__c = System.today(),
            Warranty_Factory_Extended_Date__c = System.today(),
            Is_Warrany_Canceled__c = false,
            Product_Identifier__c = '29UUA66204A054613');
         insert honda_productObj1;
        //Honda_Product__c hPd = [select id from Honda_Product__c limit 1];
        OwnWarrantyController.checkUserHasWarranty(honda_productObj1.Product_Identifier__c);
    }
}
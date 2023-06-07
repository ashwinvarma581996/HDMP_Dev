@isTest
public class OwnEConfigApiHelperTest {

    // Vin No.: VINNUMBER00000001
    // Division: Honda
    // Division Id: A
    // Model Name: TestModel1
    // Trim: TestTrim1
    // Year: 2022
    // Mfg Color Code: TE-0001
    // Exterior Color Name: TestColor1
    // Model Id: 000000001

    @testSetup
    public static void testSetup(){
        Product_Model__c pm = new Product_Model__c(Product_Division__c = 'A', Product_Subdivision__c = 'Honda', Model_Name__c = 'TestModel1', Trim__c = 'TestTrim1', Model_Year__c = '2022', Product_Model_Id__c = '000000001');
        insert pm;
        Product_Model_Color__c pmc = new Product_Model_Color__c(Manufacturer_Color_Code__c = 'TE-0001', Exterior_Color_Name__c = 'TestColor1', Product_Model__c = pm.Id);
        insert pmc;
    }

    @isTest static void testGetYears() {
        Vehicle__c vehicle = new Vehicle__c(Name = 'testV2');
        vehicle.eConfigDivisionID__c = 'V002';
        vehicle.Year__c = 2020;

        insert vehicle;

        Test.startTest();

        OwnEConfigApiHelper.getYears('V002');

        Test.stopTest();
        
    }
    
    @isTest static void testGetModels() {
        Vehicle__c vehicle = new Vehicle__c(Name = 'testV2');
        vehicle.eConfigDivisionID__c = 'V002';
        vehicle.Year__c = 2020;
        vehicle.Model__c = 'M1';
        vehicle.Model_Id__c = 'M1';

        insert vehicle;

        Test.startTest();

        OwnEConfigApiHelper.getModels('V002', 2020);

        Test.stopTest();
        
    }


    @isTest static void testGetTrims() {
        Vehicle__c vehicle = new Vehicle__c(Name = 'testV2');
        vehicle.eConfigDivisionID__c = 'V002';
        vehicle.Year__c = 2020;
        vehicle.Model__c = 'M1';
        vehicle.Model_Id__c = 'M1';
        vehicle.Trim__c = 'abc';

        insert vehicle;

        Test.startTest();

        OwnEConfigApiHelper.getTrims('V002', 2020, 'M1');
        //OwnEConfigApiHelper.getTypesPowersports();
		//OwnEConfigApiHelper.getModelsPowersports('ATV');
        
        Test.stopTest();
        
    }
    
     @isTest static void testPowerSports() {

        Test.startTest();
         
        OwnEConfigApiHelper.getTypesPowersports();
		OwnEConfigApiHelper.getModelsPowersports('ATV');
        OwnEConfigApiHelper.getTrimsPowersports('Street','Adventure');
         
        Test.stopTest();
        
    }
    
    @isTest static void testOwnModelWrapper() {
        Vehicle__c vehicle = new Vehicle__c(Name = 'testV2');
        vehicle.eConfigDivisionID__c = 'V002';
        vehicle.Year__c = 2020;
        vehicle.Model__c = 'M1';
        vehicle.Model_Id__c = 'M1';
        vehicle.Trim__c = 'abc';

        insert vehicle;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OwnEConfigApi_MockService());

        //OwnEConfigApiHelper.getOwnModelWrapper('M1','V002');
        Test.stopTest();
    }
    
     @isTest static void testgetModelByVin() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OwnEConfigVinDecoder_MockService());

        OwnEConfigApiHelper.getModelByVin('testVin','A');
        Test.stopTest();
    }
    
    @isTest static void testcallVinDecoderService2() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OwnEConfigVinDecoder_MockService());

        OwnEConfigApiHelper.callVinDecoderService2('testVin','model1');
        Test.stopTest();
    }

    @isTest static void getGarageProductFromECRMTest() {

        Test.setMock(HttpCalloutMock.class, new OwnApiCalloutMock());
        Test.startTest();
        OwnEConfigApiHelper.ECRMResult result = OwnEConfigApiHelper.getGarageProductFromECRM('VINNUMBER00000001', 'A');
        Test.stopTest();

        System.assertEquals(false, result.isError);
        System.assertEquals('A', result.product.divisionId);
        System.assertEquals('Honda', result.product.division);
        System.assertEquals('2022', result.product.year);
        System.assertEquals('TestModel1', result.product.model);
        System.assertEquals('TestTrim1', result.product.trim);
        System.assertEquals('TE-0001', result.product.color.mfg_color_cd);
        System.assertEquals('TestColor1', result.product.color.name);
        System.assertEquals('000000001', result.product.modelId);
    }
    
    @isTest static void getModelColorsAndAssetsTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OwnApiCalloutMock());
        OwnEConfigApiHelper.getModelColorsAndAssets('FC3B3KJW', 'Honda');
        Test.stopTest();
       // System.debug('test  :-  '+OwnEConfigApiHelper.getCompleteDetails('FC3B3KJW', 'Honda'));
    }
    
    /* @isTest static void getModelByVin2Test() {
        Test.setMock(HttpCalloutMock.class, new OwnMockHttpResponseGenerator());
        OwnEConfigApiHelper.getModelByVin2('5FNRL5H95HB152304', 'B');
       // System.debug('test  :-  '+OwnEConfigApiHelper.getCompleteDetails('FC3B3KJW', 'Honda'));
    } */

    @isTest static void EConfigModelColorTest() {
        OwnEConfigApiHelper.EConfigModelColor testColor = new OwnEConfigApiHelper.EConfigModelColor();

        testColor.id = 'test';
        testColor.name = 'test';
        testColor.color_cd = 'test';
        testColor.mfg_color_cd = 'test';
        testColor.color_type = 'test';

        System.assertEquals(testColor.id, 'test');
        System.assertEquals(testColor.name, 'test');
        System.assertEquals(testColor.color_cd, 'test');
        System.assertEquals(testColor.mfg_color_cd, 'test');
        System.assertEquals(testColor.color_type, 'test');
    }

    @isTest static void getModelAssetTypeTest() {
        String assetType1Str = 'BASECAR';

        OwnEConfigApiHelper.ModelAssetType assetTypeEnum = OwnEConfigApiHelper.getModelAssetType(assetType1Str);

        System.assertEquals(OwnEConfigApiHelper.ModelAssetType.BASECAR, assetTypeEnum);
    }

    @isTest static void peSerialNumberLookupTest() {
        String peTestSN = 'MANA-1858567';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OwnApiCalloutMock());
        OwnEConfigApiHelper.getModelByVin('MANA-1858567', 'P', 'Power Equipment');
        Test.stopTest();
    }
}
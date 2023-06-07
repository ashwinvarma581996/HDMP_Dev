@isTest(seeAllData=true)
public class B2B_VehicleSelectorControllerTest {
    static Network communityObj = [SELECT id, name, status FROM Network where (name like 'dev%' OR name like 'Dream%' )and status = 'Live' LIMIT 1];
    @isTest 
    public static void TestgetVehicleYear() {
        string year;
        year=B2B_VehicleSelectorController.getVehicleYear('Honda');
    }
    @isTest 
    public static void TestgetVehicleMake() {
        List<Vehicle__c> vehicleList =new List<Vehicle__c>();
        vehicleList =B2B_VehicleSelectorController.getVehicleMake('Honda', 2019);
    }
    @isTest 
    public static void TestgetVehicleTrim() {
        List<Vehicle__c> vehicleList1 =new List<Vehicle__c>();
        vehicleList1=B2B_VehicleSelectorController.getVehicleTrim('Honda', 2019, 'Ridgeline');
    }
    @isTest 
    public static void TestgetCategoryId() {
        ProductCategoryProduct prcategory=new ProductCategoryProduct();
        Product2 product = [Select Id from Product2 LIMIT 1];
        ProductCategory prcat=[Select Id, Name,Catalog.Name From ProductCategory LIMIT 1];
        ProductCatalog prodcat=[select id from ProductCatalog limit 1];
        //prcatlog.name='DreamShop';
        // Update prcatlog;
        
        system.debug('ProductIddata'+prcat.Catalog.Name);
        string catId;
        catId=B2B_VehicleSelectorController.getCategoryId('Honda');
    }
    @isTest 
    public static void testGetProduct() {
        Product2 products = [Select Id from Product2 LIMIT 1];
        Product2 product = new Product2();
        product=B2B_VehicleSelectorController.getProduct(products.Id);
    }
    
    /*@isTest 
    public static void testGetCartItemCategory() {
        B2B_VehicleSelectorController.ItemWrapper wr=B2B_VehicleSelectorController.getCartItemCategory(communityObj.Id);
    }*/
    
    @isTest 
    public static void testgetBrand() {
        WebCart w= [Select Id from webcart Limit 1];
        string brand =B2B_VehicleSelectorController.getBrand(w.Id);
        
    }
    
}
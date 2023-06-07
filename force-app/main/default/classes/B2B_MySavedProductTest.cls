/**
* @File Name          : B2B_MySavedProductTest
* @Description        : Test Class for B2B_MySavedProduct
* @Created By         : Deepak Mali
* @Date               : 3/14/2022
* @Last Modified By   : 23/Sep/2022
*==============================================================================
* Ver         Date                     Author                 Modification
*==============================================================================
* 1.0       08/Feb/2022               Deepak Mali           Initial Version
* 2.0       20/August/2022             Mathioli            -
**/
@isTest
private class B2B_MySavedProductTest {
    
    @isTest
    private static void testGetMyProductList(){
        B2B_MySavedProduct.getMyProductList();  
    }
    
    @isTest
    private static void testgetMyVINProductList(){
        B2B_MySavedProduct.getMyVINProductList();  
    }
    
    @isTest
    private static void testsaveToMyProduct(){
        Product_Model__c pm=new Product_Model__c (Model_Name__c	='bwww',Product_Model_ID__c='RW1H5MJW');
        insert pm;
        Honda_Product__c hp=new  Honda_Product__c (Product_Models__c=pm.id,Product_Identifier__c='19XFC1F33ME203650');
        insert hp;
        B2B_MySavedProduct.saveToMyProduct('RW1H5MJW','RW1H5MJW','Honda Vehicle','');  
    }
    
    @isTest
    private static void testsaveToMyProduct2(){
        Product_Model__c pm=new Product_Model__c (Model_Name__c	='bwww',Product_Model_ID__c='test1');
        insert pm;
        Honda_Product__c hp=new  Honda_Product__c (Product_Models__c=pm.id,Product_Identifier__c='19XFC1F33ME203650');
        insert hp;
        B2B_MySavedProduct.saveToMyProduct('19XFC1F33ME203650',Null ,'Honda Vehicle','');  
    }
    
    @isTest
    private static void testsaveToMyProductnegative(){
        Product_Model__c pm=new Product_Model__c (Model_Name__c	='bwww',Product_Model_ID__c='test1');
        insert pm;
        Honda_Product__c hp=new  Honda_Product__c (Product_Models__c=pm.id,Product_Identifier__c='19XFC1F33ME203650');
        insert hp;
        B2B_MySavedProduct.saveToMyProduct(null,'CV1F1NEW' ,'Honda Vehicle','');  
    }
    
    @isTest
    private static void testsaveToMyProductnegative1(){
        B2B_MySavedProduct.saveToMyProduct(null,null ,null, null);  
    }
    
    @isTest
    private static void testsaveToMyProduct3(){
        Honda_Product__c objHondaProduct = new Honda_Product__c(Name = 'Honda Vehicle', Product_Type__c = 'Honda',Year__c = '2020',
                                                                Modal__c = 'CR-V', Trim__c = 'continuously variable transmission',
                                                                VIN__c = '19XFC1F33ME203650');
        insert objHondaProduct;
        B2B_MySavedProduct.saveToMyProduct('19XFC1F33ME203650',Null ,'Honda Vehicle','');  
    }
    
    
    @isTest
    private static void testdeleteMyProduct(){
        B2B_MySavedProduct.deleteMyProduct('asdfgh345678f');  
    }
    
    @isTest
    private static void testupdateMyProduct(){
        Product_Model__c pm=new Product_Model__c (Model_Name__c	='bwww',Product_Model_ID__c='test1');
        insert pm;
        B2B_MySavedProduct.updateMyProduct('sdfg345678fgh','Honda Vehicle','a','test1','');
        Honda_Product__c hp=new  Honda_Product__c (Product_Models__c=pm.id,Product_Identifier__c='19XFC1F33ME203650');
        insert hp;
        B2B_MySavedProduct.updateMyProduct('sdfg345678fgh','Honda Vehicle','19XFC1F33ME203650','','');  //added by mathi
    }
    
    @isTest
    private static void testupdateMyProductnegative(){
        B2B_MySavedProduct.updateMyProduct(null,null,null,null, null);  //added by mathi
    }  
    
    @isTest
    private static void testupdateMyProduct1(){
        Test.startTest();
        B2B_MySavedProduct.updateMyProduct('sdfg345678fgh','Honda Vehicle','','','');  
        Test.stopTest();
    }
    
    @isTest static void testUpdateHondaProductColor(){
        Product_Model__c pm = new Product_Model__c(Model_Name__c = 'Test Name', Product_Model_ID__c='test11');
        insert pm;
        Honda_Product__c hp = new Honda_Product__c(Product_Models__c = pm.id);
        insert hp;
        Test.startTest();
        //B2B_MySavedProduct.updateHondaProductColor(hp.Id, 'test11', 'mfgColorCode');  
        B2B_MySavedProduct.saveToMyProduct('', 'test11', '', 'mfgColorCode');
        //Test.stopTest();
        Account accObj = new Account(Name = 'Test Account');
        insert accObj;
        Ownership__c ownershipObj = new Ownership__c();
        ownershipObj.Honda_Product__c = hp.Id;
        ownershipObj.Ownership_Origination__c = '23';
        ownershipObj.Nickname__c = 'nickname';
        ownershipObj.Product_Owner__c = accObj.Id;
        ownershipObj.Ownership_Unique_ID__c = accObj.Id + '~' + hp.Id;
        insert ownershipObj;
        //Test.startTest();
        //B2B_MySavedProduct.updateHondaProductColor(hp.Id, 'test11', 'mfgColorCode');  
        B2B_MySavedProduct.saveToMyProduct('', 'test11', '', 'mfgColorCode');
        Test.stopTest();
    }
    
}
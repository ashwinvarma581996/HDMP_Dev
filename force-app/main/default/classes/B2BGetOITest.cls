@isTest
public class B2BGetOITest{
   /* @testSetup 
    public static void setup(){
        Product2 pro=new Prodcut2();
        pro= B2B_TestDataFactory.createProduct(true);
               
    }
    */
    
    @isTest 
    public static void getProduct() {
        List<OrderItem> oi = new List<OrderItem>();
        String oid='12345677';
        oi=B2BGetOI.getOrderItem(oid);
    }


}
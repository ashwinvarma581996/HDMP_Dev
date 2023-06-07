/**********************************************************************
Name: B2B_HandleCartAndUserTest
Business Unit:HDM
Developer : Deepak Mali
Description: This is the test class for B2B_HandleCartAndUser
MODIFICATIONS- Soumya Sahoo (HDMP-6467)
MODIFICATIONS – Palak | (Added header and removal of commented code)
*************************************************************/
@isTest
public class B2B_HandleCartAndUserTest {
    @isTest
    public static void Testmethod1(){
        user u=[select id from user limit 1];
        webstore store1= B2B_TestDataFactory.createStore(True);
        RecordType recordTypeId=[SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account' Limit 1];
        Account objAccount = new Account();
        objAccount.RecordType = recordTypeId;
        objAccount.FirstName = 'test';
        objAccount.PersonEmail = 'test@gmail.com';
        objAccount.LastName='Account';
        insert objAccount;
        Webcart web=B2B_TestDataFactory.createCart(True,objAccount.id,store1.id);
        webcart cartid=[select id,ownerid,Status from webcart limit 1];
        cartid.OwnerId=u.Id;
        update cartid;
        CartDeliveryGroup cdelivery=B2B_TestDataFactory.createCartDeliveryGroup(true,cartid.id);
        Product2 prod=B2B_TestDataFactory.createProduct(true);
        CartItem citem=B2B_TestDataFactory.createCartItem(True,cartid.id,cdelivery.id,prod.id);
        WishList wishListRecord = new WishList(OwnerId=u.id, Name='My Honda Wishlist', AccountId=objAccount.Id, 
                                               WebStoreId=store1.id);
        insert wishListRecord;
        WishList wishListRecord2 = new WishList(OwnerId=u.id, Name='My Acura Wishlist', AccountId=objAccount.Id,
                                                WebStoreId=store1.id);
        insert wishListRecord2;
        B2B_HandleCartAndUser.handleCart(u.id,web.id,'honda');
        B2B_HandleCartAndUser.handleCart(u.id,web.id,'acura');
        B2B_HandleCartAndUser.handleCart(u.id,'','honda'); 
        //delete [SELECT Id FROM WishList];
        B2B_HandleCartAndUser.handleCart(u.id,'','test');
        
        test.startTest();
        cartid.ownerid = UserInfo.getUserId();
        cartid.Status = 'Active';
        update cartid;
        B2B_HandleCartAndUser.moveInactiveItemsToWishList();
        test.stopTest();
    }
    
    @isTest
    public static void getCurrentCartTest(){
        B2B_HandleCartAndUser.getCurrentCart();
    }
    
}
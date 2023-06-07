//By Sayeed Shaik

@isTest
public class UpdateCartItemHelperTest {
     
    @isTest
    Public Static void  updateCartItemRecord(){
                
        Account testAccount = new Account(Name='TestAccount',PoIId__c='test');
        insert testAccount;
        
        WebStore testWebStore = new WebStore(Name='TestWebStore', DefaultLanguage='en_US');
        insert testWebStore;
        
        WebCart webcart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id, status='Active');
        insert webcart;
               
        Product2 prod1 = new Product2(Name='TestProduct', division__c = 'A;B', StockKeepingUnit='testunit', Price__c=120, Description='Test1');
        insert prod1;
             
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=webcart.Id, Name='Default Delivery 1');
        insert cartDeliveryGroup; 
        
        cartItem cart = B2B_TestDataFactory.createCartItem(True,webcart.Id,cartDeliveryGroup.Id,prod1.Id);     
        Update_CartItem__e updateEvent = new Update_CartItem__e();    
        updateEvent.Cart_Item_Id__c = cart.id;
       
        Test.startTest();
        EventBus.publish(updateEvent); 
        Test.stopTest();
          
    }


}
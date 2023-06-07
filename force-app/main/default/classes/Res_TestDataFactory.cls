/**
* @description       :
* @author            : mbunch@gorillagroup.com
* @group             :
* @last modified on  : 04-11-2022
* @last modified by  : mbunch@gorillagroup.com
**/
@isTest
@SuppressWarnings('PMD.ExcessivePublicCount')
public without sharing class Res_TestDataFactory {

    public static void setUpReservationTest()
    {
        createDreamShopStore();
        List<WebStore> webStores = createWebStores(1) ;
        List<Account> accounts = createAccounts(1) ;
        BuyerGroup buyerGroup = createBuyerGroup() ;
        List<BuyerGroupMember> buyers = createBuyers(buyerGroup,accounts);
        List<Contact> contacts = createContacts(accounts) ;
        List<User> users = createUsers(contacts);

        List<WebStoreCatalog> catalogs = createProductCatalogs(webStores) ;
        List<Product2> products = createProducts(1) ;
        List<ProductCategory> categories = createProductCategories(catalogs);
        List<ProductCategoryProduct> pcps = assignProductsToCategories(categories,products);
        CommerceEntitlementPolicy policy = createEntitlementPolicy();
        CommerceEntitlementBuyerGroup cebg = assignBuyerGroupToEntitlement(policy,buyerGroup);
        List<CommerceEntitlementProduct> ceps = assignProductsToEntitlement(policy, products ) ;
        Reservation_Cap_Group__c g = createCapGroup() ;
        assignProductToCapGroup(products[0].id, g.Id) ;


        List<OrderDeliveryMethod> deliveryMethods = createOrderDeliveryMethods(1);

        Reservation_Contact2__c resContact = createReservationContact() ;
        Reservation__c reservation = createReservation(resContact) ;
        WebCart cart = createWebCart(accounts[0].id, webStores[0].id) ;
    }
    public static void setUpReservationTest1(){
        List<WebStore> webStores = createWebStores(1) ;
        List<Account> accounts = createAccounts(1) ;
        BuyerGroup buyerGroup = createBuyerGroup() ;
        List<BuyerGroupMember> buyers = createBuyers(buyerGroup,accounts);
        List<Contact> contacts = createContacts(accounts) ;

        User users =CreateUser1();

        List<WebStoreCatalog> catalogs = createProductCatalogs(webStores) ;
        List<Product2> products = createProducts(1) ;
        List<ProductCategory> categories = createProductCategories(catalogs);
        List<ProductCategoryProduct> pcps = assignProductsToCategories(categories,products);
        CommerceEntitlementPolicy policy = createEntitlementPolicy();
        CommerceEntitlementBuyerGroup cebg = assignBuyerGroupToEntitlement(policy,buyerGroup);
        List<CommerceEntitlementProduct> ceps = assignProductsToEntitlement(policy, products ) ;
        Reservation_Cap_Group__c g = createCapGroup() ;
        assignProductToCapGroup(products[0].id, g.Id) ;


        List<OrderDeliveryMethod> deliveryMethods = createOrderDeliveryMethods(1);

        Reservation_Contact2__c resContact = createReservationContact() ;
        Reservation__c reservation = createReservation(resContact) ;
        WebCart cart = createWebCart(accounts[0].id, webStores[0].id) ;

    }
    public static User createUser1(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];

        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',

            Alias = 'gst',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );

        return portalAccountOwner1;

    }

    public static List<Account> createAccounts(Integer num){
        List<Account> accountsList = new List<Account>();
        List<RecordType> recordTypes = [Select Id From RecordType WHERE sObjectType='Account' and isActive=true AND Name = ''];
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Record type').getRecordTypeId();

        for(Integer i=0;i<num;i++){
            Account accnt = new Account(
                Name = 'Account Test' + i,
                RecordTypeId = recordTypeId ,
                BillingCity='test',
                BillingStreet='test',
                BillingState='IN',
                BillingPostalCode='test',
                BillingCountry='US',
                ShippingCity='test',
                ShippingStreet='test',
                ShippingState='IN',
                ShippingPostalCode='test',
                ShippingCountry='US',
                Operation_Hour__c = 'Mon-Fri 7:00AM-6:00PM;  Sat 7:00AM-5:00PM;  Sun Closed',
                Email__c = 'test@gmail.com',
                PoIId__c  = '251367',
                IsActive__c = true ,
                Merchant_Id__c = 'testMerchant'
            );
            accountsList.add(accnt);
        }
        insert accountsList;
        return accountsList;
    }

    public static List<Product2> createProducts(Integer num){
        List<Product2> productsList = new List<Product2>();
        Integer productCode = 10011;
        for(Integer i=0;i<num;i++){
            Product2 prd = new Product2(
                Name = 'Reservation ' + String.valueof(i) ,
                ProductCode = String.valueOf(productCode),
                IsActive = true,
                StockKeepingUnit = String.valueOf(productCode)
            );
            productsList.add(prd);
            productCode++;
        }
        insert productsList;
        return productsList;
    }

    public static Reservation_Cap_Group__c createCapGroup()
    {
        Reservation_Cap_Group__c g = new Reservation_Cap_Group__c(name = 'default', Reservation_cap__c = 500, is_active__c = true, Include_no_deposit_in_cap_calculation__c = false) ;
        insert g ;
        return g ;
    }

    public static void assignProductToCapGroup(String productId, String capGroupId){
        Product2 product = [SELECT id FROM Product2 WHERE id = :productId] ;
        product.Reservation_Cap_Group__c = capGroupId ;
        update product ;
    }

    public static List<WebStore> createWebStores(Integer num){
        List<WebStore> webStoresList = new List<WebStore>();

        for(Integer i=0;i<num;i++){
            WebStore ws = new WebStore(
                Name = 'Default WS' + i
            );
            webStoresList.add(ws);
        }
        insert webStoresList;
        return webStoresList;
    }

    public static void createDreamShopStore(){

        insert new WebStore( Name = 'Dreamshop' ) ;
    }

    public static List<WebStoreCatalog> createProductCatalogs(List<WebStore> stores)
    {
        List<ProductCatalog> catalogs = new List<ProductCatalog>() ;
        List<WebStoreCatalog> webstoreCatalogs = new List<WebStoreCatalog>() ;
        Integer i = 0 ;
        for ( WebStore store : stores)
        {
            i++ ;
            ProductCatalog cat = new ProductCatalog(name = 'test' + String.valueof(i)  ) ;
            catalogs.add(cat) ;
        }
        insert catalogs ;
        i = 0 ;
        for ( WebStore store : stores)
        {
            WebStoreCatalog wsc = new WebStoreCatalog( ProductCatalogId = catalogs[i].Id , SalesStoreId = store.Id);
            webStoreCatalogs.add(wsc) ;
        }
        insert webstoreCatalogs ;
        return webstoreCatalogs ;
    }

    public static List<ProductCategory> createProductCategories(List<WebStoreCatalog> catalogs){

        List<ProductCategory> categories = new List<ProductCategory>() ;

        for ( WebStoreCatalog catalog : catalogs ){
            ProductCategory pc = new ProductCategory(
                Name = 'TestCategory',
                CatalogId = catalog.ProductCatalogId
            );
        }
        insert Categories ;
        return categories;
    }

    public static List<ProductCategoryProduct> assignProductsToCategories(List<ProductCategory> categories, List<Product2> products)
    {
        List<ProductCategoryProduct> rv = new List<ProductCategoryProduct>();
        for ( Productcategory cat : categories ){
            for ( Product2 product : products){
                rv.add( new ProductCategoryProduct(ProductCategoryId = cat.id, ProductId = product.id )) ;
            }
        }
        insert rv ;
        return rv ;
    }

    private static List<Contact> createContacts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>() ;

        Integer i = 1 ;
        for ( Account account : accounts)
        {
            Contact c = new Contact();
            c.FirstName = 'Guest';
            c.LastName = 'Contact' + String.valueof(i) ;
            c.Email = 'guest' + String.valueof(i) + '@test.com';
            c.AccountId = account.id;
            contacts.add(c) ;
            i++;
        }
        insert contacts;

        return contacts;
    }

    public static Contact createContact(Account account) {

        Contact c = new Contact();
        c.FirstName = 'Guest';
        c.LastName = 'ContactNew' ;
        c.Email = 'guest@new.example.com';
        c.AccountId = account.id;

        insert c;

        return c;
    }

    private static List<User> createUsers(List<Contact> contacts) {
        return createUsers(contacts, null) ;
    }

    public static List<User> createUsers(List<Contact> contacts, String profileId) {

        List<User> users = new List<User>() ;
        if ( profileId == null ){
            profileId = RES_Settings.getSettings().User_Profile__c ;
        }
        for ( Contact contact : contacts)
        {
            User u = new User();
            u.ContactId = contact.Id;
            u.FirstName = contact.FirstName;
            u.LastName = contact.LastName;
            u.Email = contact.Email;

            u.ProfileId = profileId ;
            u.UserName = contact.Email +'.guest';
            u.Alias = 'gst';
            u.TimeZoneSidKey = 'GMT';
            u.LocaleSidKey = 'en_US';
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.CommunityNickname = contact.FirstName + ' ' + contact.LastName;
            u.IsActive = true ;
            users.add(u) ;
        }
        insert users;

        return users;
    }

    public static BuyerGroup  createBuyerGroup()
    {
        BuyerGroup buyGroup = new BuyerGroup(
            Name = 'GG-Test',
            Description = 'No desc'     );
        insert buyGroup;
        return buyGroup ;
    }

    public static List<BuyerGroupMember>  createBuyers( BuyerGroup buyGroup, List<Account> accounts)
    {

        List<BuyerAccount> buyerAccounts = new List<BuyerAccount>();
        List<BuyerGroupMember> buyerGroupMembers = new List<BuyerGroupMember>() ;

        for ( Account account : accounts){

            BuyerAccount buyerAccount = new BuyerAccount(
                BuyerId = account.Id,
                Name = 'Buyer',
                IsActive = true    );
            buyerAccounts.add(buyerAccount) ;
            BuyerGroupMember bgMember = new BuyerGroupMember(
                BuyerId = account.Id,
                BuyerGroupId = buyGroup.Id );
            buyerGroupMembers.add(bgMember) ;

        }
        insert buyerAccounts;
        insert buyerGroupMembers ;

        return buyerGroupMembers ;
    }

    public static CommerceEntitlementPolicy createEntitlementPolicy()
    {
        CommerceEntitlementPolicy cep = new CommerceEntitlementPolicy(
            Name = 'Policy',
            IsActive = true,
            Description = 'Policy'
        );
        insert cep;
        return cep ;
    }

    public static CommerceEntitlementBuyerGroup assignBuyerGroupToEntitlement(CommerceEntitlementPolicy policy, BuyerGroup buyerGroup )
    {
        CommerceEntitlementBuyerGroup cebg = new CommerceEntitlementBuyerGroup(
            BuyerGroupId = buyerGroup.Id,
            PolicyId = policy.Id
        );
        insert cebg;
        return cebg ;
    }

    public static List<CommerceEntitlementProduct> assignProductsToEntitlement(CommerceEntitlementPolicy policy, List<Product2> products )
    {
        List<CommerceEntitlementProduct> rv = new List<CommerceEntitlementProduct>() ;
        for ( Product2 product : products){
            CommerceEntitlementProduct cp = new CommerceEntitlementProduct(
                PolicyId = policy.Id,
                ProductId = product.id,
                External_id__c =  String.valueof(policy.id.to15()) +  product.id.to15() ) ;
            rv.add(cp) ;
        }
        insert rv ;
        return rv ;
    }

    public static List<OrderDeliveryMethod> createOrderDeliveryMethods(Integer num){
        List<OrderDeliveryMethod> odmList = new List<OrderDeliveryMethod>();
        Product2 shippingChargeProduct = new Product2(Name = 'Shipping Charge for this delivery method');
        insert shippingChargeProduct;

        for(Integer i=0;i<num;i++){
            OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod(
                Name = 'Order Delivery Method' + i,
                Carrier = 'Test Carrier ' + i,
                ClassOfService = 'SNC9600',
                ProductId = shippingChargeProduct.Id,
                isActive = true
            );
            odmList.add(orderDeliveryMethod);
        }
        insert odmList;
        return odmList;
    }

    public static Reservation_Contact2__c createReservationContact()
    {
        Reservation_Contact2__c rc = new Reservation_Contact2__c(
            Accepted_Terms__c = true ,
            Email_Address__c = 'test@test.com' ,
            First_Name__c = 'fist' ,
            Last_Name__c = 'last' ,
            Phone_Number__c = '3175551111' ,
            Zip_Code__c = '12345'
        ) ;
        insert rc ;
        return rc ;
    }

    /*  public static Reservation__c createReservation()
{
Reservation__c reservation = new Reservation__c(
Model_ID__c = 'test' ,
Vehicle_Model_Series__c = 'test' ,
Model_Year__c = 'test' ,
Exterior_Color__c = 'test' ,
Exterior_Color_Code__c = 'test' ,
Exterior_Color_Price__c =  1.0 ,
Interior_Color__c = 'test' ,
Interior_Color_Code__c = 'test' ,
Deposit_Amount__c = 500.00 ,
MSRP__c = 36000.00 ,
Dealer_Number__c = 'test',
Dealer_Name__c = 'test' ,
Dealer_Address__c = 'test' ,
Dealer_Phone__c = 'test' ,
Is_Participating__c =  true ,
Dealer_Postal_Code__c = 'test' ,
Redirect_URL__c = 'test' ) ;
insert reservation ;
return reservation ;
}

public static WebCart createWebCart(){
WebCart wc = new WebCart();
wc.AccountId = [SELECT id FROM Account LIMIT 1][0].id ;
wc.Name = 'GuestCart' ;
wc.WebStoreId = [SELECT id FROM WebStore LIMIT 1][0].id ;
wc.Status = 'Active';
wc.Type = 'Cart';
insert wc;
return wc;
}*/

    public static Reservation__c createReservation(Reservation_Contact2__c rc)
    {
        Reservation__c r = new Reservation__c( Model_ID__c = '1234' , Model_Name__c = 'MDX' , Package_Name__c = 'package' , Vehicle_Model_Series__c = 'series', Model_Year__c = '2022' ,
                                              Exterior_Color__c = 'blue' , Exterior_Color_Code__c = 'bl' , 	Exterior_Color_Price__c =  null , Interior_Color__c = 'red' , Interior_Color_Code__c = 'rd' ,
                                              Deposit_Amount__c = 500.00, Dealer_Number__c = '251367' , 	Dealer_Name__c = 'Dealer' , Dealer_Address__c = 'Delaers place' , Dealer_Phone__c = '12345678901',
                                              Is_Participating__c =  true, 	Dealer_Postal_Code__c = '12345', Redirect_URL__c = '\\' , IsWaitlist__c = false, Campaign_Name__c  = 'campaign',
                                              Provider_Participating_Dealer__c = 'test' , Provider_Non_Participating_Dealer__c = 'test' , Provider_Reserve_Waitlist__c = 'test' ,
                                              Vehicle_Model_Marketing_Name__c = 'test' , Vehicle_Model_Body_Style__c = 'test' , Shopping_Tool__c = 'test' , Transaction_Type__c = 'TX' ,
                                              Delivery_Send_Date__c = null , Reservation_Contact2__c = rc.id)  ;

        insert r ;
        return r ;
    }

    public static Reservation_Session__c createSession(){
        Reservation_Contact2__c c = [SELECT id, First_Name__c, Last_Name__c, Email_Address__c, Phone_Number__c FROM Reservation_Contact2__c LIMIT 1] ;
        Reservation__c r = [SELECT id FROM Reservation__C LIMIT 1] ;
        webCart cr = [select id , DealerId__c from webCart limit 1];
        User u = [SELECT id FROM User WHERE Alias = 'gst' LIMIT 1] ;
        Account a = [SELECT id FROM Account LIMIT 1] ;
        return Res_TestDataFactory.createSession(u.id,c.id,a.id,r.id,cr.id) ;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static Reservation_Session__c createSession(String userId, String contactId, String accountId, String reservationId, String cartId){
        Reservation_Session__c session = new Reservation_Session__c(
            User__c = userId ,
            Reservation_Contact2__c = contactId,
            Reservation_Account__c = accountId ,
            Reservation__c = reservationId,
            Cart__c = cartId) ;
        insert session ;
        return session ;
    }

    public static Order createOrder(String accountId, String cartId){
        Order objOrder = new Order();
        objOrder.Name = 'Test Order';
        objOrder.cart__c = cartId;
        objOrder.AccountId = accountId;
        objOrder.Status = 'Draft';
        objOrder.IsPaymentReproccessing__c = false;
        objOrder.EffectiveDate = System.today().addDays(20);
        objOrder.BT_Transaction_Status__c = 'Authorized';
        insert objOrder;
        return objOrder ;
    }

    public static BT_Token_Details__c createBTTokenDetails(String accId){
        BT_Token_Details__c bttoken = new BT_Token_Details__c();
        bttoken.Account__c= accId;
        bttoken.AccessToken__c = 'access_token$sandbox$x6q6b83wjsn28t2m$1a22c8ab33bdd7e4726ca8358f27de77';
        bttoken.RefreshToken__c = 'refresh_token$sandbox$x6q6b83wjsn28t2m$ade578dc1f20a130';
        DateTime currentTime = System.now();
        bttoken.AccessTokenExpiresAt__c=  System.now();
        bttoken.RefreshTokenExpiresAT__c=  currentTime.addMinutes(30);
        insert bttoken;
        return bttoken;
    }

    public static WebCart createWebCart(String accountId, String storeId){

        WebCart cart = new WebCart();
        cart.Name = 'Test cart';
        cart.PoNumber = '123';
        cart.AccountId = accountId ;
        cart.WebStoreId = storeId ;
        cart.Status = 'Active';
        cart.Type = 'Cart';
        cart.DealerId__c  = accountId ;
        cart.CustomerStreet__c = '1234 Main Street';
        cart.CustomerCity__c = 'DALLAS';
        cart.Customer_State__c = 'TX';
        cart.CustomerCountry__c = 'USA';
        cart.CustomerPostalCode__c = '75201';
        cart.ShippingAmount__c = 0;
        insert cart;
        return cart ;
    }

    public static Map<String,Object> buildReservationMap(String reservationId, String reservationContactId){
        Reservation__c lead ;
        HttpResponse response ;
        Map<String,Object> leadRecord = new Map<String,Object>() ;
        String sourceIp = null ;

        Map<String, String> session ;
            if ( !System.Test.isRunningTest() && sourceIp == null )
            {
                session = Auth.SessionManagement.getCurrentSession();
            }
            else {
                session = new Map<String,String>() ;
                session.put('SourceIp', sourceIp == null ? '127.0.0.1' : sourceIp ) ;
            }

            lead = [SELECT Id, MSRP__c, model_id__c, Model_year__c, Exterior_Color__c, Exterior_Color_Code__c, Exterior_Color_Price__c, Interior_Color_Code__c, Interior_Color__c, Vehicle_Model_Series__c,
                        IsWaitlist__c, Business_Entity__c, Campaign_Name__c, Provider_Participating_Dealer__c, Provider_Non_Participating_Dealer__c, Provider_Reserve_Waitlist__c, Dealer_Number__c,
                        Vehicle_Model_Marketing_Name__c, Vehicle_Model_Body_Style__c, Shopping_Tool__c, Transaction_Type__c, Deposit_Amount__c,Delivery_Send_Date__c , Is_Participating__c, Approval_Code__c, Display_Number__c
                    FROM Reservation__c
                    WHERE id = :reservationId][0] ;

            Reservation_Contact2__c contact = [SELECT first_Name__c, last_Name__c,
                                                    Email_Address__c, Phone_Number__c,
                                                    Zip_Code__c
                                                FROM Reservation_Contact2__c
                                                WHERE id = :reservationContactId] ;
            String provider = lead.IsWaitlist__c ? lead.Provider_Reserve_Waitlist__c : ( lead.Is_Participating__c ? lead.Provider_Participating_Dealer__c : lead.Provider_Non_Participating_Dealer__c   ) ;
            leadRecord.put('Division', 'B') ;
            List<String> config = new List<String>() ;
            config.add('<configuration total_configured_price=\"');
            config.add(String.valueof(lead.MSRP__c)) ;
            config.add('\">\r\n  <model id=\"');
            config.add('') ; // config.add(lead.model_id__c);
            config.add('\" model_year=\"') ;
            config.add(lead.Model_year__c) ;
            config.add('\" msrp=\"0\">\r\n <client_side_state>M:</client_side_state>\r\n <color exterior_color_name=\"');
            config.add(lead.Exterior_Color__c) ;
            config.add('\" exterior_color_cd=\"');
            config.add(lead.Exterior_Color_Code__c) ;
            config.add('\" exterior_price_delta=\"') ;
            config.add(String.valueof(lead.Exterior_Color_Price__c)) ;
            config.add('\" interior_color_name=\"') ;
            config.add(lead.Interior_Color__c) ;
            config.add('\" interior_color_cd=\"') ;
            config.add(lead.Interior_Color_Code__c) ;
            config.add('" product_honda_cd=\"\" />\r\n  </model>\r\n  <original_configuration_data />\r\n</configuration>') ;
            leadRecord.put('Configuration', String.join(config,'')) ;
            leadRecord.put('ModelName', lead.Vehicle_Model_Series__c) ;
            leadRecord.put('DealerId', Integer.valueOf(lead.Dealer_Number__c)) ;
            leadRecord.put('FirstName', contact.first_Name__c) ;
            leadRecord.put('LastName', contact.last_Name__c) ;
            leadRecord.put('Email',  contact.Email_Address__c) ;
            leadRecord.put('Phone',  contact.Phone_Number__c) ;
            leadRecord.put('Address', null ) ;
            leadRecord.put('Address2', null) ;
            leadRecord.put('City', null) ;
            leadRecord.put('State', null) ;
            leadRecord.put('ZipCode', contact.Zip_Code__c) ;
            leadRecord.put('WorkZipCode', null) ;
            leadRecord.put('ContactMethod', null) ;
            leadRecord.put('ContactTime', null) ;
            leadRecord.put('AddressScrubbing', false) ;
            leadRecord.put('SendConfirmationEmail', 'N') ;
            leadRecord.put('Provider', provider) ;  // add provider to reserbation
            leadRecord.put('ShoppingTool', lead.Shopping_Tool__c) ;
            leadRecord.put('CampaignName', lead.Campaign_Name__c) ;
            leadRecord.put('TransactionCD', lead.Transaction_Type__c) ;
            leadRecord.put('DeliverySendDate', lead.Delivery_Send_Date__c) ;
            leadRecord.put('ModelBodyStyle', lead.Vehicle_Model_Body_Style__c) ;
            leadRecord.put('CustomerIPAddress',session.get('SourceIp'));

            List<Map<String,Object>> additionalInfoList = new List<Map<String,Object>>() ;
            leadRecord.put('LeadAdditionalInfo', additionalInfoList ) ;

            if ( lead.Is_Participating__c && ! lead.isWaitlist__c){
                Map<String,Object> depositInfo = new Map<String,Object>() ;
                depositInfo.put('ConfirmationNumber',  '1223') ;
                depositInfo.put('DepositSalesforceOrderNumber',  lead.Display_Number__c);
                depositInfo.put('Amount',  lead.Deposit_Amount__c);
                List<Map<String,Object>> depositInfoList = new List<Map<String,Object>>() ;
                depositInfoList.add(depositInfo) ;
                leadRecord.put('Deposit', depositInfo ) ;
            }

            return leadRecord ;
    }

}
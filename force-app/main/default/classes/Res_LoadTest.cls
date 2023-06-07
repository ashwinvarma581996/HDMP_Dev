/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-07-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@SuppressWarnings('PMD.ApexCRUDViolation,PMD.CognitiveComplexity')
public without sharing class Res_LoadTest {

    @AuraEnabled
    public static string runTestElement(String jsonString){
        Map<String,Object> data ;
        try {
            Integer testPackageId =  Integer.valueOf(Math.random() * 3.0) ;
            Map<String,Object> defaultMap = getNextPayLoad(testPackageId);
            data = mergeMaps(jsonString, defaultMap) ;


            String capGroupId = null ;

            Boolean isWaitlisted = Math.random() > 0.25 ? true : false ;
            String contactId = saveFormData() ;
            String productId = Res_Settings.getSettings().Reservation_Product_Id__c ;
            String rid = saveReservation(JSON.serialize(data), isWaitlisted, contactId, productId, capGroupId) ;

         RES_LeadCreation.postLeadsFromReservationAsync(rid,'127.0.0.1',true) ;


            return '' ;
        }
        catch( Exception e){
            RES_Logger.log('runTestElement Exception.  JSON: ' + jsonString + ' data ' + JSON.serialize(data) + 'Exception ' + e.getMessage() ) ;
            return e.getMessage();
        }
    }

    public static Map<String,Object> getNextPayLoad(Integer payloadId){
        String idStr = '' ;
        List<String> hexUnits = new List<String>{'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
        for ( Integer id = 0 ; id < 32 ; id++){
            Integer digitId = Integer.valueOf(Math.random() * 16.0) ;
            idStr += hexUnits[digitId] ;
        }

        Map<String,Object> rv = new Map<String,Object>() ;
        rv.put('id',idStr) ;
        rv.put('modelId',payloadId == 0 ? 'FK1H3MKNW' : (payloadId == 1 ? 'FK1N5MKNW' : 'FK1H7MKNW') ) ;
        rv.put('uniqueModelId',rv.get('modelId')) ;
        rv.put('modelName','Integra') ;
        rv.put('packageName', payloadId == 0 ?  'A-Spec' : (payloadId == 1 ? 'A-Spec wTech CVT' : 'A-Spec wTech 6MT')) ;
        rv.put('vehicleModelSeries', payloadId == 0 ?  'A-Spec® (CVT)' : (payloadId == 1 ? 'A-Spec w/Technology (CVT)' : 'A-Spec w/Technology (6MT)')) ;
        rv.put('modelYear','2023') ;
        rv.put('exteriorColor', payloadId == 0 ? 'Liquid Carbon Metallic' : (payloadId == 1 ? 'Majestic Black Pearl' : 'Platinum White Pearl') ) ;
        rv.put('exteriorColorCode', payloadId == 0 ? 'NH-885M' : (payloadId == 1 ? 'NH-893P' : 'NH-883P') ) ;
        rv.put('exteriorColorPrice','') ;
        rv.put('interiorColor', payloadId == 1 ? 'Ebony' : 'Red');
        rv.put('interiorColorCode', payloadId == 1 ? 'EN' : 'RE') ;
        rv.put('depositAmount','500') ;
        rv.put('MSRP','') ;
        rv.put('dealerNumber', payloadId == 1 ? '251445' : '251059') ;
        rv.put('dealerName', payloadId == 1 ? 'Regal Acura' : 'Cerritos Acura') ;
        rv.put('dealerAddress', payloadId == 1 ? '2615 Lakeland Hills Blvd' :  '18827 Studebaker Rd') ;
        rv.put('dealerPhoneNumber', payloadId == 1 ? '(863) 687-8000' : '(888) 321-6797') ;
        rv.put('dealerCity', payloadId == 1 ? 'Lakeland' :  'Cerritos') ;
        rv.put('dealerState', payloadId == 1 ? 'FL' : 'CA') ;
        rv.put('isParticipantDealer', payloadId == 1 ? false : true) ;
        rv.put('zipCode', payloadId == 1 ? '33805' : '90703') ;
        rv.put('callbackUrl','https://staging.new.acura.com/tools/reserve-online/confirmation') ;
        rv.put('accessories', null);


        Map<String,Object> si = new Map<String,Object>() ;
        si.put('businessEntity','Acura') ;
        si.put('campaignName','') ;
        si.put('providerParticipantDealer','Integra Reserve AHM') ;
        si.put('providerNonParticipantDealer','Integra Confirmation lead AHM') ;
        si.put('providerReserveWaitlist','Integra waitlist AHM') ;
        si.put('vehicleModelBodyStyle','') ;
        si.put('shoppingTool','Resesrve Online') ;
        si.put('transactionType', 'VL') ;
        si.put('deliverySendDate','') ;
        si.put('vehicleModelMarketingName', payloadId == 0 ? '2023 Integra A-Spec' : (payloadId == 1 ? '2023 Integra A-Spec with Technology (AT)' : '2023  Integra A-Spec with Technology (6MT)') ) ;
        rv.put('subsciptionInfo',si) ;

        return rv ;
    }

    public static Map<String,Object> mergeMaps(String jsonString, Map<String,Object> defaultMap){

        Map<String,Object> reservationMap ;

        try {
            if ( String.isNotEmpty(jsonString)){
                reservationMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            }
        }
        catch (Exception e) {
            // eat exception
        }

        if ( reservationMap == null )
            return defaultMap ;

        for ( String field : defaultMap.keySet())
        {
            if ( defaultMap.get(field) != reservationMap.get(field)){
                if ( reservationMap.containsKey(field)){
                    defaultMap.put(field,reservationMap.get(field)) ;
                }
            }
        }

        return defaultMap ;
    }

    public static String saveFormData() {
        Reservation_Contact2__c rc = new Reservation_Contact2__c(
            Accepted_Terms__c = true ,
            Email_Address__c = 'email' + String.valueOf(Integer.valueOf(Math.random() * 9999)) + '@example.com' ,
            First_Name__c = 'Joe' + String.valueOf(Integer.valueOf(Math.random() *9999)) ,
            Last_Name__c = 'Cool' + String.valueOf(Integer.valueOf(Math.random() *9999)) ,
            Zip_Code__c = String.valueOf(Integer.valueOf(Math.random() * 99999 )).leftPad(5,'0'));

        Database.SaveResult sr = Database.insert(rc) ;

        if ( !sr.success )
        {

            throw new Res_Exception('Unable to save contact information') ;
        }

        return rc.id ;
    }

    public static String getWebStore() {
        return RES_Settings.getSettings().storeId__c ;
    }

    public static Contact createNewContact(String accountId,Integer cnt, String str) {
        Contact c = new Contact();
        c.FirstName = 'Guest';
        c.LastName = 'Contact' + String.valueOf(cnt);
        c.Email = 'guest' + String.valueOf(cnt) + '_' + str + '@example.com';
        c.AccountId = accountId;
        insert c;

        return c;
    }

    public static User createNewUser(String accountId, String profileId, Reservation_Settings__mdt settings, Contact contact, Integer lastNumber, Integer retries) {
        if ( retries > 5)
        {
            return null ;
        }

        integer cnt ;
        if ( lastNumber == null ){
            cnt = Database.countQuery('SELECT COUNT() FROM User WHERE ProfileId = \'' + profileId + '\'') ;
        }
        else
        {
            cnt = lastNumber ;
        }
        String nickName = (String.isBlank(settings.Guest_Nickname_Prefix__c) ? '' : settings.Guest_Nickname_Prefix__c )  + ' ' + String.valueOf(cnt) ;

        List<User> users = [    SELECT Id, Alias
                                FROM User
                                WHERE Contact.AccountId = :accountId AND ProfileId = :profileId AND Alias LIKE 'gst0_%'
                                    AND CommunityNickname > :nickName
                                //    AND Id NOT IN (SELECT User__c FROM Reservation_Session__c)
                                ORDER BY CommunityNickname DESC LIMIT 1] ;

        if ( !users.isEmpty() )
        {
            cnt = Integer.valueof(users[0].Alias.substring(3) ) + 1;
        }

        Integer r =  Integer.valueOf(Math.random() * 1000.0) ;
        String rs = String.valueof(r) ;

        Contact c =  contact == null ? createNewContact(accountId,cnt,rs) : contact ;

        nickname = Test.isRunningTest() ?
            'tst'  + '' + String.valueOf(cnt).leftPad(7,'0') :
            (String.isBlank(settings.Guest_Nickname_Prefix__c) ? '' : settings.Guest_Nickname_Prefix__c )  + rs + '_' + String.valueOf(cnt).leftPad(7,'0') ;

        String username = Test.isRunningTest() ?
            'Tst_U' + String.valueOf(cnt).leftPad(7,'0') + c.Email +'.guest'  + (String.isBlank(settings.Guest_User_Suffix__c) ? '' : settings.Guest_User_Suffix__c) :
            'Res_U' + rs + '_' + String.valueOf(cnt).leftPad(7,'0') + c.Email +'.guest'  + (String.isBlank(settings.Guest_User_Suffix__c) ? '' : settings.Guest_User_Suffix__c);

        String alias = Test.isRunningTest() ?
            't' + String.valueof(cnt).leftPad(7,'0') :
            'g' + ( String.valueof(cnt) + '_' + rs).leftPad(7,'0').right(7) ;

        User u = new User();
        u.ContactId = c.Id;
        u.FirstName = c.FirstName;
        u.LastName = c.LastName;
        u.Email = c.Email;
        u.ProfileId = profileId ;
        u.UserName = username ;
        u.Alias = alias ;
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.CommunityNickname = nickName ;
        u.IsActive = true ;
        Database.SaveResult sr = Database.Insert(u) ;
        if ( ! sr.isSuccess() )
        {
            return createNewUser(accountId,profileId,settings,c,cnt,retries + 1);
        }
        //insert u;

        String password = '!1' + String.valueof(u.id).right(6) + 'Ab' ;
        System.setPassword(u.id, password) ;

        return u;
    }

    public static User getLoginUser(Reservation_Settings__mdt settings, Integer retries){

        if ( retries > 5){
            throw new RES_Exception('Could not esablish user session');
        }

        List<User> users = [    SELECT Id, ContactId, FirstName,LastName,Email,ProfileId,UserName,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey,CommunityNickname, IsActive
                                FROM User
                                WHERE Contact.AccountId = :settings.Reservation_Account__c
                                    AND ProfileId = :settings.User_Profile__c
                                    AND IsActive = true
                                    AND Alias LIKE 'g00_%'
                                    AND Id NOT IN (SELECT User__c FROM Reservation_Session__c) LIMIT 1] ;

        User u ;

        if ( users.isEmpty()  )
        {
            u = createNewUser(settings.Reservation_Account__c, settings.User_Profile__c, settings, null, null, null) ;
        }
        else{
            u = users[0] ;
        }

        Database.SaveResult sr = Database.insert(new Reservation_Session__c(User__c = u.id)) ;

        if ( ! sr.isSuccess() )
        {
            return getLoginUser(settings, retries+1) ;
        }

        return u ;
    }

    public static string startSession(String userId, String reservationContactId, String reservationId){
        User u ;
        try {

            String webStoreId = getWebStore();
            Reservation_Settings__mdt settings = RES_Settings.getSettings() ;
            Reservation_Session__c session = getSession(reservationContactId, reservationId, userId, settings) ;
            //setUserActive(userId);
            Reservation__c reservation = [SELECT IsWaitlist__c, Is_Participating__c, Product__c FROM Reservation__c WHERE id = :reservationId] ;
            if ( reservation.IsWaitlist__c || ! reservation.is_Participating__c)
            {
                return '' ;
            }
            WebCart cart = createWebCart(session,settings) ;
            session.Cart__c = cart.id ;
            update session ;
            addToCart(cart.id, settings.Reservation_Account__c, reservation.Product__c == null ? settings.Reservation_Product_Id__c : reservation.Product__c, webstoreId);
            return settings.Checkout_URL__c + '/' + cart.id ;
        } catch (Exception e) {
            if ( u != null )
            {
                //setUserInActive(u.id) ;
            }
            Res_Exception ex = new Res_Exception(e.getMessage());
            ex.setMessage(e.getMessage() + ' line ' + e.getLineNumber() ) ;
            throw ex ;
        }
    }

    public static string saveReservation(String jsonString, Boolean isWaitlisted, String contactId, String productId, String capGroupId){


            Map<String,Object> reservationMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

            Object subItem = reservationMap.get('subsciptionInfo') ;
            Map<String,Object> subsciptionInfo = new Map<String,Object>() ;
            if ( subItem != null ) {
                subsciptionInfo = (Map<String,Object>) subItem ;
            }
            Map<String,Object> ciReservationMap = new Map<String,Object>() ;
            for ( String key : reservationMap.keySet() ){
                ciReservationMap.put(key.toUpperCase(),reservationMap.get(key)) ;
            }
            Map<String,Object> ciOptionsMap = new Map<String,Object>() ;
            for ( String key : subsciptionInfo.keySet() ){
                ciOptionsMap.put(key.toUpperCase(),subsciptionInfo.get(key)) ;
            }
            string ac = '0' + String.valueOf(Integer.valueOf(Math.random() *9999)) ;
            //create the reservation using the maps created above
            Reservation__c reservation = new Reservation__c(
                //update to data sent 01/22/22
                Sitecore_id__c = getMapInfoAsString('id', ciReservationMap,ciOptionsMap),
                uniqueModelId__c = getMapInfoAsString('uniqueModelId', ciReservationMap,ciOptionsMap),
                //
                Model_ID__c = getMapInfoAsString('modelId', ciReservationMap,ciOptionsMap) ,
                Model_Name__c = getMapInfoAsString('modelName',ciReservationMap,ciOptionsMap) ,
                Package_Name__c = getMapInfoAsString('packageName',ciReservationMap,ciOptionsMap) ,
                Vehicle_Model_Series__c = getMapInfoAsString('vehicleModelSeries', ciReservationMap,ciOptionsMap) ,
                Model_Year__c = getMapInfoAsString('modelYear', ciReservationMap,ciOptionsMap) ,
                Exterior_Color__c = getMapInfoAsString('exteriorColor', ciReservationMap,ciOptionsMap) ,
                Exterior_Color_Code__c = getMapInfoAsString('exteriorColorCode', ciReservationMap,ciOptionsMap) ,
                Exterior_Color_Price__c =  getMapInfoAsDecimal('exteriorColorPrice', ciReservationMap,ciOptionsMap) ,
                Interior_Color__c = getMapInfoAsString('interiorColor', ciReservationMap,ciOptionsMap) ,
                Interior_Color_Code__c = getMapInfoAsString('interiorColorCode', ciReservationMap,ciOptionsMap) ,
                Deposit_Amount__c = getMapInfoAsDecimal('depositAmount', ciReservationMap,ciOptionsMap) ,
                MSRP__c = getMapInfoAsDecimal('MSRP', ciReservationMap,ciOptionsMap) ,
                Dealer_Number__c = getMapInfoAsString('dealerNumber',ciReservationMap,ciOptionsMap),
                Dealer_Name__c = getMapInfoAsString('dealerName', ciReservationMap,ciOptionsMap) ,
                Dealer_Address__c = getMapInfoAsString('dealerAddress', ciReservationMap,ciOptionsMap) ,
                Dealer_Phone__c = getMapInfoAsString('dealerPhoneNumber', ciReservationMap,ciOptionsMap) ,
                Is_Participating__c =  getMapInfoAsBoolean('isParticipantDealer', ciReservationMap,ciOptionsMap) ,
                Dealer_Postal_Code__c = getMapInfoAsString('zipCode', ciReservationMap,ciOptionsMap) ,
                Redirect_URL__c = getMapInfoAsString('callbackUrl',ciReservationMap,ciOptionsMap)  ,
                IsWaitlist__c = mapValueToBoolean(isWaitlisted) ,
                Business_Entity__c = getMapInfoAsString('businessEntity',ciReservationMap,ciOptionsMap) ,
                Campaign_Name__c  = getMapInfoAsString('campaignName',ciReservationMap,ciOptionsMap) ,
                Provider_Participating_Dealer__c = getMapInfoAsString('providerParticipantDealer',ciReservationMap,ciOptionsMap) ,
                Provider_Non_Participating_Dealer__c = getMapInfoAsString('providerNonParticipantDealer',ciReservationMap,ciOptionsMap) ,
                Provider_Reserve_Waitlist__c = getMapInfoAsString('providerReserveWaitlist',ciReservationMap,ciOptionsMap) ,
                Vehicle_Model_Marketing_Name__c = getMapInfoAsString('vehicleModelMarketingName',ciReservationMap,ciOptionsMap) ,
                Vehicle_Model_Body_Style__c = getMapInfoAsString('vehicleModelBodyStyle',ciReservationMap,ciOptionsMap) ,
                Shopping_Tool__c = getMapInfoAsString('shoppingTool',ciReservationMap,ciOptionsMap) ,
                Transaction_Type__c = getMapInfoAsString('transactionType',ciReservationMap,ciOptionsMap) ,
                Delivery_Send_Date__c = getMapInfoAsString('deliverySendDate',ciReservationMap,ciOptionsMap),
                Reservation_Contact2__c = contactId ,
                Dealer_City__c = getMapInfoAsString('dealerCity',ciReservationMap,ciOptionsMap) ,
                Dealer_State__c = getMapInfoAsString('dealerState', ciReservationMap, ciOptionsMap) ,
                Product__c = productId ,
                Reservation_Cap_Group__c = RES_Util.isSalesforceID(capGroupId) ? capGroupId : null,
                Accessories__c = '[]',
                Approval_Code__c = ac ) ;
            if ( ciReservationMap.get('ISPARTICIPANTDEALER') == null ){
                reservation.Is_Participating__c = getMapInfoAsBoolean('isOnboardedDealer',ciReservationMap,ciOptionsMap) ;
            }
            if ( reservation.Deposit_Amount__c == null || reservation.Deposit_Amount__c == 0){
                reservation.Deposit_Amount__c = 500.00 ;
            }
            Database.SaveResult sr = Database.insert(reservation) ;

            //if the database insert worked above sr will = success so return and exit
            if ( sr.success ) {
                return sr.getId() ;
            }
            //otherwise you will hit this exception
            Res_Exception ex = new Res_Exception('Unable to save reservation data.') ;
            ex.setMessage('Unable to save reservation data.') ;
            throw ex ;

    }

    public static Reservation_Session__c getSession(String reservationContactId, String reservationId, String userId, Reservation_Settings__mdt settings) {
        Reservation_Session__c session ;

        List<Reservation_Session__c> sessions = [   SELECT User__c, Reservation_Contact2__c, Reservation_Account__c, Reservation__c, id
                                                    FROM Reservation_Session__c
                                                    WHERE User__c = :UserInfo.getUserId()] ;

        if ( !sessions.isEmpty()){
            session = sessions[0] ;
            session.Reservation_Contact2__c = reservationContactId ;
            session.Reservation_Account__c = settings.Reservation_Account__c ;
            session.Reservation__c = reservationId ;
            update session ;
            return sessions[0] ;
        }
        else
        {
            session = new Reservation_Session__c(
                User__c = userId ,
                Reservation_Contact2__c = reservationContactId,
                Reservation_Account__c = settings.Reservation_Account__c,
                Reservation__c = reservationId) ;
            Database.SaveResult result = Database.insert(session) ;
            if ( result.isSuccess())
            {
                return session ;
            }
        }
        throw new AuraException('Cannot create session') ;
    }

    public static WebCart createWebCart(Reservation_Session__c session, Reservation_Settings__mdt settings) {



        try{
            List<WebCart> carts = [SELECT id, AccountId, Name, WebStoreId, Status, Type, OwnerId FROM WebCart WHERE OwnerId = :session.User__c AND (Status = 'Active' OR Status = 'Checkout')];
            WebCart wc ;
            if ( carts.isEmpty( ))
            {
                wc = new WebCart();
                wc.AccountId = settings.Reservation_Account__c ;
                wc.Name = 'GuestCart' ;
                wc.WebStoreId = settings.StoreId__c;
                wc.Status = 'Active';
                wc.Type = 'Cart';
                wc.OwnerId = session.User__c;
                insert wc;
            }
            else {
                wc = carts[0] ;
                if ( wc.Status == 'Checkout')
                {
                    List<CartCheckoutSession> ccs = [SELECT id FROM CartCheckoutSession WHERE WebCartId = :wc.id] ;
                    for ( CartCheckoutSession s : ccs){
                        s.isProcessing = false ;
                    }
                    update ccs ;
                }
            }
            createCartDeliveryGroup(wc.id);
            return wc;
        }
        catch(Exception e){
            RES_Logger.log(e.getMessage()) ;
            throw e ;
        }
    }

    public static CartDeliveryGroup createCartDeliveryGroup(String cartId) {

        List<CartDeliveryGroup> cdgs = [SELECT id, Name, Cartid FROM CartDeliveryGroup WHERE cartid = :cartId ] ;
        CartDeliveryGroup cdg ;
        if ( cdgs.isempty())
        {
            cdg = new CartDeliveryGroup();
            cdg.Name = 'Default Delivery';
            cdg.CartId = cartId;
            OrderDeliveryMethod orderDeliveryMethod = [select id, createddate, name, ProductId from OrderDeliveryMethod limit 1];
            cdg.DeliveryMethodId = orderDeliveryMethod.id;
            insert cdg;
        }
        else {
            cdg = cdgs[0] ;
        }
        return cdg ;
    }

    public static void addToCart(String cartId, String accountId, String productId, String storeId) {
        if ( [SELECT id FROM CartItem WHERE CartId = :cartId].size() > 0 ) {
            return ;
        }
        List<CartDeliveryGroup> cdgs = [SELECT id FROM CartDeliveryGroup WHERE CartId = :cartId LIMIT 1] ;
        CartDeliveryGroup cdg ;
        if ( cdgs.isEmpty()) {
            cdg = createCartDeliveryGroup(cartId) ;
        } else {
            cdg = cdgs[0] ;
        }
        CartItem item = new CartItem( Name = 'testcart',
                                        cartId = cartId,
                                        product2Id = productId,
                                        quantity = 1,
                                        type = 'Product',
                                        CartDeliveryGroupId = cdg.id ,
                                        SalesPrice = 500.00,
                                        ListPrice = 500,
                                        TotalPriceAfterAllAdjustments = 500,
                                        TotalListPrice = 500,
                                        UnitAdjustedPrice = 500,
                                        TotalPrice	= 500) ;
        insert item ;
    }


    public static String getMapInfoAsString(String key, Map<String,Object> res , Map<String,Object> options) {
        String k = key.toUpperCase();
        String value = mapValueToString(options.get(k)) ;
        if ( String.isEmpty(value) )
        {
            value = mapValueToString(res.get(k)) ;
        }
        return value ;
    }

    public static Boolean getMapInfoAsBoolean(String key, Map<String,Object> res, Map<String,Object> options){
        String k = key.toUpperCase();
        Boolean value = mapValueToBoolean(options.get(k)) ;
        if (  options.get(k) == null )
        {
            value = mapValueToBoolean(res.get(k)) ;
        }

        return value ;
    }

    public static Decimal getMapInfoAsDecimal(String key, Map<String,Object> res, Map<String,Object> options){
        String k = key.toUpperCase();
        Decimal value = mapValueToDecimal(options.get(k)) ;
        if (  value == null )
        {
            value = mapValueToDecimal(res.get(k)) ;
        }
        return value ;
    }

    public static String mapValueToString(Object o){
        if ( o == null )
        {
            return null ;
        }
        return String.valueOf(o) ;
    }

    public static Decimal mapValueToDecimal(Object o){
        if ( o == null )
        {
            return null ;
        }
        if ( o instanceof String &&  String.isBlank((String)o) ){
            return null ;
        }
        return Decimal.valueOf(String.valueof(o)) ;
    }

    public static Boolean mapValueToBoolean(Object o){
        if ( o == null )
        {
            return false ;
        }
        if ( o instanceof Boolean)
        {
            return (Boolean) o ;
        }
        return Boolean.valueOf(String.valueOf(o)) ;
    }

    public static Order createOrder(Product2 p, Account acc){





      Pricebook2 pb2 = [select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1];

      Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft' ,
            SalesstoreId = RES_Settings.getSettings().StoreId__c ,
            Pricebook2Id = pb2.id
        );
        insert order;

        OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(

           DeliverToName = 'Receiver',

           DeliverToStreet = '1234 Receive It Lane',
           DeliverToCity = 'Receiving',
           DeliverToState = 'FL',
           DeliverToPostalCode = '34233',
           DeliverToCountry = 'US',

            OrderDeliveryMethodId = [select id, createddate, name, ProductId from OrderDeliveryMethod limit 1][0].id,
            OrderId = order.Id
        );
        insert(orderDeliveryGroup);

        List<PricebookEntry> pbes = [SELECT id FROM PricebookEntry WHERE Pricebook2Id = :pb2.id AND Product2Id = :p.id] ;
        if ( pbes.isempty()){

            return null ;
        }
        PricebookEntry pbe = pbes[0] ;

        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.id;
        lineItem.Quantity = 1;
        lineItem.UnitPrice = 500;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=pbe.id;
        lineItem.TotalLineAmount = 500 ;
        lineItem.OrderDeliveryGroupId = orderDeliveryGroup.id ;
        insert lineItem;

        // Now update & Activate the Order
        order.Status = 'Activated';
        update order;

        ConnectApi.OrderSummaryInputRepresentation i = new ConnectApi.OrderSummaryInputRepresentation() ;
        i.orderId = order.id ;
        ConnectApi.OrderSummaryCreation.createOrderSummary(i) ;

        return order ;

    }

    /*
ew OrderItem(UnitPrice         = pl.UnitPrice,
                                          OrderId           = ord.id,
                                          Quantity          = pl.quantity,
                                          Product2Id        = pl.Id,
                                          PricebookEntryId  = pl.PricebookEntryId
    */

}
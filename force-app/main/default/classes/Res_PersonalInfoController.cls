/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-29-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@SuppressWarnings('PMD.ApexCRUDViolation')
public WITHOUT SHARING class Res_PersonalInfoController {

    //         return RES_CapManagement.isOnWaitlist((Map<String, Object>) JSON.deserializeUntyped(dataStr)) ;

    // public static Account reservationAccount = getOldestModifiedReservationAccount();
    public static Account reservationAccount = getRandomReservationAccount();

    @AuraEnabled
    public static Boolean waitlist(){
        return waitlist(null,null) ;
    }
    public static Boolean waitlist(Integer cap, Integer actual){//Deposit Made
        try {
            String WebStoreId = getWebStore() ;
            Reservation_Settings__mdt settings = getSettings(webStoreId) ;
            Decimal cnt = settings.Reservation_Cap__c ;
            if ( Test.isRunningTest())
            {
                cnt = cap ;
            }
            else {
                if ( cnt == null )
                {
                    return false ;
                }
            }
            String qry = 'SELECT count() FROM Reservation__c WHERE Completed__c = true' ;
            if ( getSettings().Include_No_Deposit_in_Cap_Calculation__c  )
            {
                qry += ' AND Status__c IN (\'Deposit Made\',\'Reservation Made\')' ;
            }
            else {
                qry += ' AND Status__c = \'Deposit Made\'' ;
            }
            integer currentCnt = Database.countQuery(qry) ;
            if ( Test.isRunningTest())
            {
                currentCnt = actual ;
            }
            return currentCnt >= cnt ;
        } catch (Exception e) {
            log( 'Exception in waitlist: ' + e.getMessage() );
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string doLogin(String url, Boolean isWaitlisted, Integer retries) {
        User u ;
        try {
            String webStoreId = getWebStore();
            Reservation_Settings__mdt settings = getSettings(webStoreId) ;
            u = getLoginUser(settings, retries) ;
            if ( u == null )
            {
                throw new LocalException('no dice');
            }

            String password = '!1' + String.valueof(u.id).right(6) + 'Ab' ;
            String returnUrl = settings.PI_Link__c ;
            // String returnUrl = url;
            System.PageReference loggedInPage = System.Site.login(u.Username, password, returnUrl );

            if ( Test.isRunningTest())
            {
                return 'test';
            }
            String rurl = loggedInPage.getUrl() ;
            return rurl ;
        } catch (Exception e) {
            try {
                log(e.getMessage()) ;
            if ( u != null )
            {
                setUserInActive(u.id) ;
            }}
            catch (Exception i)
            {
                //eat exception
            }
            throw createException(e.getMessage()) ;
        }
    }

    @AuraEnabled
    public static String saveFormData(Map<String,Object> formData, String ip, String language, String browser) {
        try{

           Reservation_Settings__mdt settings ;
           try {
                settings = getSettings() ;
            }
            catch(Exception e){
                throw createException('settings');
            }
            if ( UserInfo.getUserId() == null ){
                throw createException('noUser');
            }
            List<Reservation_Session__c> sessions = [SELECT id, createdDate FROM Reservation_Session__c WHERE User__c = :UserInfo.getUserId()  ] ;
            if ( sessions.Size() == 0  ||  sessions[0].createdDate.AddMinutes( Integer.valueof(settings.Session_Timeout_minutes__c == null ? 30 : settings.Session_Timeout_minutes__c)) < Datetime.now()  ){
                if ( ! Test.isRunningTest()){
                    throw createException('session timed out') ;
                }
            }
            Reservation_Contact2__c rc = new Reservation_Contact2__c(
                Accepted_Terms__c = mapValueToBoolean(formData.get('Accepted_Terms__c')) ,
                Email_Address__c = mapValueToString(formData.get('Email_Address__c')) ,
                First_Name__c = mapValueToString(formData.get('First_Name__c')) ,
                Last_Name__c = mapValueToString(formData.get('Last_Name__c')) ,
                Phone_Number__c = mapValueToString(formData.get('Phone_Number__c')) ,
                Zip_Code__c = mapValueToString(formData.get('Zip_Code__c')),
                Language__c = language?.left(5),
                Browser__c = browser,
                IP_Address__c = ip) ;

            Database.SaveResult sr = Database.insert(rc) ;

            if ( !sr.success )
            {

                throw new AuraHandledException('Unable to save contact information') ;
            }

            return rc.id ;
        }
        catch(Exception e)
        {
            throw createException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string startSession(String userId, String reservationContactId, String reservationId){
        User u ;
        try {

            String webStoreId = getWebStore();

            Reservation_Settings__mdt settings = getSettings(webStoreId) ;

            Reservation_Session__c session = getSession(reservationContactId, reservationId, userId, settings) ;


            Reservation__c reservation = [SELECT IsWaitlist__c, Is_Participating__c, Product__c, Deposit_Amount__c FROM Reservation__c WHERE id = :reservationId] ;

            if ( reservation.IsWaitlist__c || ! reservation.is_Participating__c)
            {
                return '' ;
            }
            WebCart cart = createWebCart(session,settings) ;
            session.Cart__c = cart.id ;

            update session ;
            RES_Logger.log(LoggingLevel.DEBUG, reservationAccount.Id, 'Res_PersonalInfoController.startSession', null, 'Debug', null, false) ;

            addToCart(cart.id, reservationAccount.Id, reservation.Product__c == null ? settings.Reservation_Product_Id__c : reservation.Product__c, webstoreId, reservation.Deposit_Amount__c);
            return settings.Checkout_URL__c + '/' + cart.id ;
        } catch (Exception e) {
            log('Start Session Exception ' + e.getMessage());
            if ( u != null )
            {
                setUserInActive(u.id) ;
            }
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage() + ' line ' + e.getLineNumber() ) ;
            throw ex ;
        }
    }

    @AuraEnabled
    public static string decodeString(String b64String){
        try {
            return EncodingUtil.base64Decode(b64String).toString();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    //save reservation
    public static string saveReservation(String JSONString, Boolean isWaitlisted, String contactId, String productId, String capGroupId){
        String reservationStr = '' ;

        try {
            //local variables
            Map<String,Object> reservationMap = (Map<String, Object>) JSON.deserializeUntyped(JSONString);
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
                Accessories__c = getMapInfoAsJSONString('accessories', ciReservationMap, ciOptionsMap),
                Accessories_Names__c = buildAccessoriesNamesString((List<Object>)getMapInfoAsJSON('accessories', ciReservationMap, ciOptionsMap)),
                Accessories_IDs__c = buildAccessoriesIdsString((List<Object>)getMapInfoAsJSON('accessories', ciReservationMap, ciOptionsMap)),
                Model_Name_Standalone__c = getMapInfoAsString('modelNameStandalone',ciReservationMap,ciOptionsMap)
            );


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
            AuraHandledException ex = new AuraHandledException('Unable to save reservation data.') ;
            ex.setMessage('Unable to save reservation data.') ;
            throw ex ;
        //if the mapping fails you should hit this exception
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage() + ' line ' + e.getLineNumber() + ' payload: ' + reservationStr) ;
            throw ex ;
        }
    }
    @AuraEnabled
    //
    public static string getBackLink(String data){
        try {
            //decoding being done with JavaScript to avoid null value issues with Apex

            Map<String,Object> reservationMap = (Map<String, Object>) JSON.deserializeUntyped(data);
            Reservation_Settings__mdt settings = getSettings(getWebStore());

            Boolean isInMarket = (Boolean) reservationMap.get('isInMarket');

            String template = '{0}?modelYear={1}&vehicleModelSeries={2}&zipcode={3}&modelId={4}&step=2&exteriorColor={5}&interiorColor={6}&dealer={7}';
            String accessoriesIds = buildAccessoriesIdsString((List<Object>)getMapInfoAsJSONFromMap('accessories', reservationMap));
            List<String> parameters = new List<String> {
                settings.Base_Return_URL__c ,  (String) reservationMap.get('modelYear') , (String) reservationMap.get('reserveModelParameter') , (String) reservationMap.get('zipCode') ,
                (String) reservationMap.get('modelId'), (String) reservationMap.get('exteriorColorCode'), (String) reservationMap.get('interiorColorCode'), (String) reservationMap.get('dealerNumber')
            };


            if (isInMarket) {
                template = '{0}/{1}?modelYear={2}&vehicleModelSeries={3}&zipcode={4}&modelId={5}&exterior={6}&interior={7}&dealer={8}&tab=summary&reserveOnlineFlow=true';
                parameters = new List<String> {
                    settings.BAP_Return_URL__c, (String) reservationMap.get('modelName'), (String) reservationMap.get('modelYear') , (String) reservationMap.get('reserveModelParameter') , (String) reservationMap.get('zipCode') ,
                    (String) reservationMap.get('modelId'), (String) reservationMap.get('exteriorColorCode'), (String) reservationMap.get('interiorColorCode'), (String) reservationMap.get('dealerNumber')
                };
            }


            if (accessoriesIds != null || accessoriesIds != '') {
                if (isInMarket) {
                    template = template + '&accessories={9}';
                } else {
                    template = template + '&accessories={8}';
                }
                parameters.add(accessoriesIds);
            }

            String u = String.format(template, parameters) ;
            return u ;

        } catch (Exception e) {
            log('go back ex: ' + e.getMessage()) ;
            return '' ;
        }
    }

    @TestVisible
    private static String buildAccessoriesNamesString(List<Object> accessories) {
        String res = '';
        if (accessories == null || accessories.isEmpty()) {
            return res;
        }
        List<String> accessoriesNames = new List<String>();
        List <Map<String, Object>> accessoriesList = new List<Map<String,Object>>();
        for (Object accessory : accessories) {
            accessoriesList.add((Map<String, Object>)accessory);
        }

        for (Map<String,Object> accesory : accessoriesList) {
            accessoriesNames.add((String)accesory.get('name'));
        }
        return String.join(accessoriesNames, '\n');
    }

    @TestVisible
    private static String buildAccessoriesIdsString(List<Object> accessories) {
        String res = '';
        if (accessories == null || accessories.isEmpty()) {
            return res;
        }
        List<String> accessoriesIds = new List<String>();
        List <Map<String, Object>> accessoriesList = new List<Map<String,Object>>();
        for (Object accessory : accessories) {
            accessoriesList.add((Map<String, Object>)accessory);
        }

        for (Map<String,Object> accesory : accessoriesList) {
            accessoriesIds.add((String)accesory.get('opCode'));
        }
        return String.join(accessoriesIds, ',');
    }



    private static String getMapInfoAsJSONString(String key, Map<String,Object> res , Map<String,Object> options) {
        String k = key.toUpperCase();
        Object value = mapValueToObject(options.get(k)) ;
        if (value == null)
        {
            value = mapValueToObject(res.get(k));
        }
        String jsonString = JSON.serialize(value);
        return jsonString;
    }


    private static Object getMapInfoAsJSON(String key, Map<String,Object> res , Map<String,Object> options) {
        String k = key.toUpperCase();
        Object value = mapValueToObject(options.get(k)) ;
        if (value == null)
        {
            value = mapValueToObject(res.get(k));
        }
        return value;
    }

    private static Object getMapInfoAsJSONFromMap(String key, Map<String,Object> res) {
        return mapValueToObject(res.get(key)) ;
    }

    private static String getMapInfoAsString(String key, Map<String,Object> res , Map<String,Object> options) {
        String k = key.toUpperCase();
        String value = mapValueToString(options.get(k)) ;
        if ( String.isEmpty(value) )
        {
            value = mapValueToString(res.get(k)) ;
        }
        return value ;
    }

    private static Boolean getMapInfoAsBoolean(String key, Map<String,Object> res, Map<String,Object> options){
        String k = key.toUpperCase();
        Boolean value = mapValueToBoolean(options.get(k)) ;
        if (  options.get(k) == null )
        {
            value = mapValueToBoolean(res.get(k)) ;
        }

        return value ;
    }

    private static Decimal getMapInfoAsDecimal(String key, Map<String,Object> res, Map<String,Object> options){
        String k = key.toUpperCase();
        Decimal value = mapValueToDecimal(options.get(k)) ;
        if (  value == null )
        {
            value = mapValueToDecimal(res.get(k)) ;
        }
        return value ;
    }

    private static Object mapValueToObject(Object o){
        if (o == null)
        {
            return null;
        }
        return (o) ;
    }

    private static String mapValueToString(Object o){
        if ( o == null )
        {
            return null ;
        }
        return String.valueOf(o) ;
    }

    private static Decimal mapValueToDecimal(Object o){
        if ( o == null )
        {
            return null ;
        }
        if ( o instanceof String &&  String.isBlank((String)o) ){
            return null ;
        }
        return Decimal.valueOf(String.valueof(o)) ;
    }

    private static Boolean mapValueToBoolean(Object o){
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

    @TestVisible
    private static User  getLoginUser(Reservation_Settings__mdt settings, Integer retries){

        if ( retries > 5){
            RES_Logger.log(LoggingLevel.ERROR, 'Max login retries reached.  Could not esablish user session', 'Res_PersonalInfoController', null, 'Login', null, false);
            throw createException('Could not esablish user session');
        }

        RES_Logger.log(LoggingLevel.DEBUG, reservationAccount.Id, 'Res_PersonalInfoController.getLoginUser', null, 'Debug', null, false) ;


        List<User> users = [    SELECT Id, ContactId, FirstName,LastName,Email,ProfileId,UserName,Alias,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,EmailEncodingKey,CommunityNickname, IsActive
                                FROM User
                                WHERE Contact.AccountId = :reservationAccount.Id
                                    AND ProfileId = :settings.User_Profile__c
                                    AND IsActive = true
                                    AND Alias LIKE 'g00_%'
                                    AND Id NOT IN (SELECT User__c FROM Reservation_Session__c) LIMIT 1] ;

        User u ;

        if ( users.isEmpty()  )
        {
            u = createNewUser(reservationAccount.Id, settings.User_Profile__c, settings) ;
        }
        else{
            u = users[0] ;
        }

        Database.SaveResult sr = Database.insert(new Reservation_Session__c(User__c = u.id)) ;

        if ( ! sr.isSuccess() )
        {
            reservationAccount = getRandomReservationAccount();
            RES_Logger.log(LoggingLevel.DEBUG, reservationAccount.Id, 'Res_PersonalInfoController.getLoginUser -> retry', null, 'Debug', null, false) ;
            return getLoginUser(settings, retries+1) ;
        }

        return u ;
    }

    @TestVisible
    private static Reservation_Session__c getSession(String reservationContactId, String reservationId, String userId, Reservation_Settings__mdt settings) {
        Reservation_Session__c session ;

        List<Reservation_Session__c> sessions = [   SELECT User__c, Reservation_Contact2__c, Reservation_Account__c, Reservation__c, id
                                                    FROM Reservation_Session__c
                                                    WHERE User__c = :UserInfo.getUserId()] ;

        RES_Logger.log(LoggingLevel.DEBUG, reservationAccount.Id, 'Res_PersonalInfoController.getSession', null, 'Debug', null, false) ;

        if ( !sessions.isEmpty()){
            session = sessions[0] ;
            session.Reservation_Contact2__c = reservationContactId ;
            session.Reservation_Account__c = reservationAccount.Id ;
            session.Reservation__c = reservationId ;
            update session ;
            return sessions[0] ;
        }
        else
        {
            session = new Reservation_Session__c(
                User__c = userId ,
                Reservation_Contact2__c = reservationContactId,
                Reservation_Account__c = reservationAccount.Id,
                Reservation__c = reservationId) ;
            Database.SaveResult result = Database.insert(session) ;
            if ( result.isSuccess())
            {
                return session ;
            }
        }
        throw new AuraException('Cannot create session') ;
    }

    private static User createNewUser(String accountId, String profileId, Reservation_Settings__mdt settings) {
        return createNewUser(accountId, profileId, settings, null, null, null) ;
    }

    @TestVisible
    private static User createNewUser(String accountId, String profileId, Reservation_Settings__mdt settings, Contact contact, Integer lastNumber, Integer retries) {
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

        RES_Logger.log(LoggingLevel.DEBUG, reservationAccount.Id, 'Res_PersonalInfoController.createNewUser', null, 'Debug', null, false) ;

        List<User> users = [    SELECT Id, Alias
                                FROM User
                                WHERE Contact.AccountId = :reservationAccount.Id AND ProfileId = :profileId AND Alias LIKE 'gst0_%'
                                    AND CommunityNickname > :nickName
                                //    AND Id NOT IN (SELECT User__c FROM Reservation_Session__c)
                                ORDER BY CommunityNickname DESC LIMIT 1] ;

        if ( !users.isEmpty() )
        {
            cnt = Integer.valueof(users[0].Alias.substring(3) ) + 1;
        }

        Contact c =  contact == null ? createNewContact(accountId,cnt) : contact ;

        nickname = Test.isRunningTest() ?
            'tst'  + '' + String.valueOf(cnt).leftPad(7,'0') :
            (String.isBlank(settings.Guest_Nickname_Prefix__c) ? '' : settings.Guest_Nickname_Prefix__c )  + '' + String.valueOf(cnt).leftPad(7,'0') ;

        String username = Test.isRunningTest() ?
            'Tst_U' + String.valueOf(cnt).leftPad(7,'0') + c.Email +'.guest'  + (String.isBlank(settings.Guest_User_Suffix__c) ? '' : settings.Guest_User_Suffix__c) :
            'Res_U' + String.valueOf(cnt).leftPad(7,'0') + c.Email +'.guest'  + (String.isBlank(settings.Guest_User_Suffix__c) ? '' : settings.Guest_User_Suffix__c);

        String alias = Test.isRunningTest() ?
            't' + String.valueof(cnt).leftPad(7,'0') :
            'g' + String.valueof(cnt).leftPad(7,'0') ;

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
            RES_Logger.log(LoggingLevel.DEBUG, sr.getErrors()?.get(0)?.getMessage(), 'Res_PersonalInfoController', null, 'User', null, false) ;
            return createNewUser(accountId,profileId,settings,c,cnt,retries + 1);
        }


        String password = '!1' + String.valueof(u.id).right(6) + 'Ab' ;
        System.setPassword(u.id, password) ;

        return u;
    }

    private static Account getRandomReservationAccount() {
        List<Account> queriedAccounts = [SELECT Id, Name FROM Account WHERE Is_Vehicle_Reserve__c = true];

        Account randomAccount = null;
        if (!queriedAccounts.isEmpty()) {
            Integer numAccounts = queriedAccounts.size();

            Integer randomIndex = (Integer) (Math.random() * numAccounts).intValue();

            randomAccount = queriedAccounts[randomIndex];
        }
        return randomAccount;
    }


    private static Account getOldestModifiedReservationAccount() {
        // Query all accounts with Is_Vehicle_Reserve__c set to true
        List<Account> queriedAccounts = [SELECT Id, Name, Is_Vehicle_Reserve__c, (SELECT Id, LastModifiedDate FROM Contacts ORDER BY LastModifiedDate DESC LIMIT 1) FROM Account WHERE Is_Vehicle_Reserve__c = true];

        Account oldestModifiedAccount = null;
        Datetime lastModifiedDate = null;

        // Iterate through the queried accounts
        for (Account acc : queriedAccounts) {
            Integer contactListSize = acc.Contacts.size();
            if (contactListSize == 0) {
                return acc; // Return the account immediately if it doesn't have any contacts
            }
            // Check if the account has any related contacts
            if (contactListSize > 0) {
                // Get the last modified contact's LastModifiedDate
                Datetime contactLastModifiedDate = acc.Contacts[0].LastModifiedDate;

                // Check if it is the oldest modified contact record so far
                if (lastModifiedDate == null || contactLastModifiedDate < lastModifiedDate) {
                    oldestModifiedAccount = acc;
                    lastModifiedDate = contactLastModifiedDate;
                }
            }
        }

        return oldestModifiedAccount;
    }

    private static Contact createNewContact(String accountId,Integer cnt) {
        Contact c = new Contact();
        c.FirstName = 'Guest';
        c.LastName = 'Contact' + String.valueOf(cnt);
        c.Email = 'guest' + String.valueOf(cnt) + '@example.com';
        c.AccountId = accountId;
        insert c;

        return c;
    }

    private static WebCart createWebCart(Reservation_Session__c session, Reservation_Settings__mdt settings) {



        RES_Logger.log(LoggingLevel.DEBUG, reservationAccount.Id, 'Res_PersonalInfoController.createWebCart', null, 'Debug', null, false) ;

        try{
            List<WebCart> carts = [SELECT id, AccountId, Name, WebStoreId, Status, Type, OwnerId FROM WebCart WHERE OwnerId = :session.User__c AND (Status = 'Active' OR Status = 'Checkout')];
            WebCart wc ;
            if ( carts.isEmpty( ))
            {
                wc = new WebCart();
                wc.AccountId = reservationAccount.Id ;
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

    private static CartDeliveryGroup createCartDeliveryGroup(String cartId) {

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

    private static void addToCart(String cartId, String accountId, String productId, String storeId, Decimal depositAmount) {
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
                                        SalesPrice = depositAmount,
                                        ListPrice = depositAmount,
                                        TotalPriceAfterAllAdjustments = depositAmount,
                                        TotalListPrice = depositAmount,
                                        UnitAdjustedPrice = depositAmount,
                                        TotalPrice	= depositAmount) ;
        insert item ;
    }


    public static void setUserActive(String userId) {
        User u = new User(id = userId , IsActive = true ) ;
        update u ;
    }

    @future
    public static void setUserInActive(String userId) {
        User u = new User(id = userId , IsActive = false ) ;
        update u ;
    }

    private static AuraHandledException createException(String message) {
        RES_Logger.log(LoggingLevel.ERROR, message, 'Res_PersonalInfoController', null, 'error', null, false) ;
        AuraHandledException ae = new AuraHandledException(message) ;
        ae.setMessage(message) ;
        return ae ;
    }

    private static void log(String msg) {
        try {
            RES_Logger.log(LoggingLevel.DEBUG, msg, 'Res_PersonalInfoController', null, 'Error', null, false) ;
        }
        catch(Exception e){
            // do nothing
        }
    }

    private class LocalException extends Exception{}

    private static Reservation_Settings__mdt settings ;

    private static String webStoreId ;

    @TestVisible
    private static Reservation_Settings__mdt getSettings() {
        if ( settings == null )
        {
            settings = getSettings(getWebStore()) ;
        }
        return settings ;
    }

    @TestVisible
    private static String getWebStore() {
        if ( webStoreId == null ){
            if ( !Schema.SObjectType.WebStore.isAccessible() )
            {
                throw new LocalException('No Access');
            }

            String networkId = Network.getNetworkId() ;
            if ( networkId == null){

                if ( Test.isRunningTest() )
                {
                    return [SELECT id FROM WebStore LIMIT 1][0].id ;
                }
                else {
                    throw new LocalException('Unable to locate store') ;
                }
            }

            List<WebStoreNetwork> stores = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :networkId LIMIT 1] ;

            if ( stores.size() == 0)
            {
                throw new LocalException('Unable to locate store');
            }
            webStoreId = stores[0].id ;

        }
        return webStoreId ;
    }

    @TestVisible
    private static Reservation_Settings__mdt getSettings(String webStoreId) {
        return  RES_Settings.getSettings() ;
    }
}
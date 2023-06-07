/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-30-2022
 * @last modified by  : mbunch@gorillagroup.com
 *
 *
 * @description       :
 * Update to use Named Credentials based
 * on current org.  This allows for
 * easier development
 * @author          :  Erin Antonson
 * Email: eantonson@gorillagroup.com
 *
**/
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class RES_LeadCreation {

    private static boolean logMessages = null ;
    private static List<RES_Log__c> messages = new List<RES_Log__c>() ;
    private static boolean pastCallout = false ;
    private static String sourceIp = null ;
    private static Boolean inLoadTest = false ;

    @AuraEnabled
    public static void postLeadsFromReservation(String reservationId){

        Reservation__c r ;
        try {
            List<Reservation__c> rs = [SELECT Id, Reservation_Contact2__c, is_Participating__c, isWaitlist__c  FROM Reservation__c WHERE id = :reservationId] ;
            r = rs[0] ;
            postLeads(reservationId,r.Reservation_Contact2__c) ;
        } catch (Exception e) {
            RES_Logger.logException(e) ;
            Res_Log__c msg = new Res_Log__c(Log_Data__c = 'Failed to create lead: ' + e.getMessage()) ;
            insert msg ;
            throw new AuraHandledException(e.getMessage());
        }
        try {
            r.Status__c = r.isWaitlist__c ? 'Wait-listed' : (r.is_Participating__c ? 'Deposit Made' : 'Reservation Made') ;
            r.Completed__c = true ;
            update r ;
        }
        catch (Exception e){
            pastCallout = true ;
            RES_Logger.logException(e) ;
            System.debug( LoggingLevel.DEBUG, 'Could not update reservation status ' + e.getMessage()) ;
            Res_Log__c msg = new Res_Log__c(Log_Data__c = 'Failed to create lead: ' + e.getMessage()) ;
            insert msg ;
        }
    }

    @future(callout=true)
    public static void postLeadsFromReservationAsync(String reservationId){
            try {

                postLeadsFromReservation(reservationId) ;

            }
            catch (Exception e){
                RES_Logger.log('Lead Creation Exception.  Res ID: ' + reservationId + 'Exception ' + e.getMessage() ) ;
            }
    }

    @future(callout=true)
    public static void postLeadsFromReservationAsync(String reservationId, String sourceIp, Boolean isLoadTest){
        try {
            RES_LeadCreation.sourceIp = sourceIp ;
            RES_LeadCreation.inLoadTest = isLoadTest ;
            postLeadsFromReservation(reservationId) ;

        }
        catch (Exception e){
            RES_Logger.log('Lead Creation Exception.  Res ID: ' + reservationId + 'Exception ' + e.getMessage() ) ;
        }
    }


    @future(callout=true)
    public static void postLeadsAsync(String sessionId)
    {
        postLeads(sessionId) ;
    }

    @InvocableMethod(label='RES_CreateLead' description='description')
    public static void createLead(List<CreateLeadInput> leads) {
        try{
            List<String> ids = new List<String>() ;
            for ( CreateLeadInput lead : leads ){
                ids.add(lead.cartId) ;
            }
            List<Reservation_Session__c> sessions = [SELECT id, Cart__c FROM Reservation_Session__c WHERE Cart__c IN :ids ORDER BY CreatedDate DESC] ;
            Map<String,Reservation_Session__c> cartSessionMap = new Map<String,Reservation_Session__c>() ;
            for ( Reservation_Session__c session : sessions )
            {
                if ( ! cartSessionMap.containsKey(session.Cart__c)){
                    cartSessionMap.put(session.Cart__c, session) ;
                }
            }
            for ( CreateLeadInput lead : leads ){
                postLeadsWithAuthCode(cartSessionMap.get(lead.cartId).id, lead.authCode) ;
            }
        } catch (Exception e) {
            RES_Logger.log(LoggingLevel.DEBUG, 'Failed creating lead ' + e.getMessage(), 'RES_LeadCreation', null, 'Lead', e, false) ;
            throw new RES_Exception(e.getMessage());
        }
    }

    public class CreateLeadInput{
        @InvocableVariable(required=true)
        public String cartId;

        @InvocableVariable
        public String authCode;
    }

    public static void postLeads(String sessionId){
        Reservation_Session__c session = [SELECT Reservation__c, Reservation_Contact2__c FROM Reservation_Session__c WHERE id = :sessionId][0] ;
        postLeads(session.Reservation__c, session.Reservation_Contact2__c) ;
    }

    public static void postLeadsWithAuthCode(String sessionId, String authCode){
        Reservation_Session__c session = [SELECT Reservation__c, Reservation_Contact2__c FROM Reservation_Session__c WHERE id = :sessionId][0] ;
        postLeads(session.Reservation__c, session.Reservation_Contact2__c, authCode) ;
    }

    public static void postLeads(String reservationId , String reservationContactId)
    {
        postLeads(reservationId,reservationContactId,null) ;
    }

    //Build and send the Lead record:
    public static void postLeads(String reservationId , String reservationContactId, String authCode){

        Reservation__c lead ;
        HttpResponse response ;
        Map<String,Object> leadRecord = new Map<String,Object>() ;

        try {
            //local data to push as lead:
            Map<String, String> session ;
            if ( !System.Test.isRunningTest() && ! System.isBatch() && sourceIp == null )
            {
                session = Auth.SessionManagement.getCurrentSession();
            }
            else {
                session = new Map<String,String>() ;
                session.put('SourceIp', sourceIp == null ? '127.0.0.1' : sourceIp ) ;
            }
            //You can access the IP address of the user by using this =>  session.get('SourceIp')
            lead = [SELECT Id, MSRP__c, model_id__c, Model_year__c, Exterior_Color__c, Exterior_Color_Code__c, Exterior_Color_Price__c, Interior_Color_Code__c, Interior_Color__c, Vehicle_Model_Series__c,
                        IsWaitlist__c, Business_Entity__c, Campaign_Name__c, Provider_Participating_Dealer__c, Provider_Non_Participating_Dealer__c, Provider_Reserve_Waitlist__c, Dealer_Number__c,
                        Vehicle_Model_Marketing_Name__c, Vehicle_Model_Body_Style__c, Shopping_Tool__c, Transaction_Type__c, Deposit_Amount__c,Delivery_Send_Date__c , Is_Participating__c, Approval_Code__c, Display_Number__c,
                        Accessories__c
                    FROM Reservation__c
                    WHERE id = :reservationId][0] ;
                //postLeadsFromReservationAsync finished a0t7i000002dWI4AAM
            Reservation_Contact2__c contact = [SELECT first_Name__c, last_Name__c,
                                                    Email_Address__c, Phone_Number__c,
                                                    Zip_Code__c, IP_Address__c
                                                FROM Reservation_Contact2__c
                                                WHERE id = :reservationContactId] ;
            if(!String.isBlank(contact.IP_Address__c) && (session.get('SourceIp') == null || session.get('SourceIp') == '127.0.0.1')){
            	session.put('SourceIp', contact.IP_Address__c);
            }
            String provider = lead.IsWaitlist__c ? lead.Provider_Reserve_Waitlist__c : ( lead.Is_Participating__c ? lead.Provider_Participating_Dealer__c : lead.Provider_Non_Participating_Dealer__c   ) ;
            //JSON for Lead output example:
            /*
            1.0  "Division": "B",
            2.0  "Configuration": "<configuration total_configured_price=\"50000\">\r\n  <model id=\"FK1H3MKNW\" model_year=\"2023\" msrp=\"0\">\r\n <client_side_state>M:</client_side_state>\r\n <color exterior_color_name=\"Apex Blue Pearl\" exterior_color_cd=\"B-621P\" exterior_price_delta=\"500\" interior_color_name=\"Orchid\" interior_color_cd=\"OR\" product_honda_cd=\"\" />\r\n  </model>\r\n  <original_configuration_data />\r\n</configuration>",
            3.0  "ModelName": "Integra A-Spec (CVT)",
            4.0  "DealerId": 251633,
            5.0  "FirstName": "Test",
            6.0  "LastName": "Test",
            7.0  "Email": "acura.none@possible.com",
            8.0  "Phone": null,
            9.0  "Address": null,
            10.0 "Address2": null,
            11.0 "City": null,
            12.0 "State": null,
            13.0 "ZipCode": "12345",
            14.0 "WorkZipCode": null,
            15.0 "ContactMethod": null,
            16.0 "ContactTime": null,
            17.0 "AddressScrubbing": false,
            18.0 "SendConfirmationEmail": "Y",
            19.0 "Provider": "Integra Launch AHM",
            20.0 "ShoppingTool": "Reserve Online",
            21.0 "CampaignName": "",
            22.0 "TransactionCD": "VL",
            23.0 "DeliverySendDate": null,
            24.0 "ModelBodyStyle": null,
            25.0 "LeadAdditionalInfo" : [],
            26.0 "CustomerIPAddress": "120.122.110.100",
            27.0 "Deposit": {
            28.0     "ConfirmationNumber": "123ABC12312",
            29.0     "SalesForceOrderNumber": "900008999",
            30.0     "Amount": 1000.00
            31.0 },
            */

            //add line one from above:
            /**1.0  **/leadRecord.put('Division', 'B') ;
            String accessoriesConfig = buildAccessoriesConfig((List<Object>)JSON.deserializeUntyped(lead.Accessories__c));
            //Line two is the configuration object:
            List<String> config = new List<String>() ;
            /**2.0  **/config.add('<configuration total_configured_price=\"');
            /**2.0  **/config.add(String.valueof(lead.MSRP__c)) ;
            /**2.0  **/config.add('\">\r\n  <model id=\"');
            /**2.0  **/config.add('') ; // config.add(lead.model_id__c);
            /**2.0  **/config.add('\" model_year=\"') ;
            /**2.0  **/config.add(lead.Model_year__c) ;
            /**2.0  **/config.add('\" msrp=\"0\">\r\n <client_side_state>M:</client_side_state>\r\n <color exterior_color_name=\"');
            /**2.0  **/config.add(lead.Exterior_Color__c) ;
            /**2.0  **/config.add('\" exterior_color_cd=\"');
            /**2.0  **/config.add(lead.Exterior_Color_Code__c) ;
            /**2.0  **/config.add('\" exterior_price_delta=\"') ;
            /**2.0  **/config.add(String.valueof(lead.Exterior_Color_Price__c)) ;
            /**2.0  **/config.add('\" interior_color_name=\"') ;
            /**2.0  **/config.add(lead.Interior_Color__c) ;
            /**2.0  **/config.add('\" interior_color_cd=\"') ;
            /**2.0  **/config.add(lead.Interior_Color_Code__c) ;
            if (accessoriesConfig != null) {
            /**2.0  **/config.add('" product_honda_cd=\"\" />\r\n  ' + accessoriesConfig + '</model>\r\n  <original_configuration_data />\r\n</configuration>');
            } else {
            /**2.0  **/config.add('" product_honda_cd=\"\" />\r\n  </model>\r\n  <original_configuration_data />\r\n</configuration>') ;
            }
            //add the configuration to the lead JSON string:
            /**2.0  **/leadRecord.put('Configuration', String.join(config,'')) ;
            /**3.0  **/leadRecord.put('ModelName', lead.Vehicle_Model_Marketing_Name__c) ;
            /**4.0  **/leadRecord.put('DealerId', Integer.valueOf(lead.Dealer_Number__c)) ;
            /**5.0  **/leadRecord.put('FirstName', contact.first_Name__c) ;
            /**6.0  **/leadRecord.put('LastName', contact.last_Name__c) ;
            /**7.0  **/leadRecord.put('Email',  contact.Email_Address__c) ;
            /**8.0  **/leadRecord.put('Phone',  contact.Phone_Number__c) ;
            /**9.0  **/leadRecord.put('Address', null ) ;
            /**10.0  **/leadRecord.put('Address2', null) ;
            /**11.0  **/leadRecord.put('City', null) ;
            /**12.0  **/leadRecord.put('State', null) ;
            /**13.0  **/leadRecord.put('ZipCode', contact.Zip_Code__c) ;
            /**14.0  **/leadRecord.put('WorkZipCode', null) ;
            /**15.0  **/leadRecord.put('ContactMethod', null) ;
            /**16.0  **/leadRecord.put('ContactTime', null) ;
            /**17.0  **/leadRecord.put('AddressScrubbing', false) ;
            /**18.0  **/leadRecord.put('SendConfirmationEmail', 'N') ;
            /**19.0  **/leadRecord.put('Provider', provider) ;  // add provider to reserbation
            /**20.0  **/leadRecord.put('ShoppingTool', lead.Shopping_Tool__c) ;
            /**21.0  **/leadRecord.put('CampaignName', lead.Campaign_Name__c) ;
            /**22.0  **/leadRecord.put('TransactionCD', lead.Transaction_Type__c) ;
            /**23.0  **/leadRecord.put('DeliverySendDate', lead.Delivery_Send_Date__c) ;
            /**24.0  **/leadRecord.put('ModelBodyStyle', lead.Vehicle_Model_Body_Style__c) ;

            /**26.0  **/leadRecord.put('CustomerIPAddress',session.get('SourceIp'));

            List<Map<String,Object>> additionalInfoList = new List<Map<String,Object>>() ;
            leadRecord.put('LeadAdditionalInfo', additionalInfoList ) ;

            if ( lead.Is_Participating__c && ! lead.isWaitlist__c){
                Map<String,Object> depositInfo = new Map<String,Object>() ;
                depositInfo.put('ConfirmationNumber',  lead.Approval_Code__c) ;
                depositInfo.put('DepositSalesforceOrderNumber',  lead.Display_Number__c);
                depositInfo.put('Amount',  lead.Deposit_Amount__c);
                List<Map<String,Object>> depositInfoList = new List<Map<String,Object>>() ;
                depositInfoList.add(depositInfo) ;
                leadRecord.put('Deposit', depositInfo ) ;
            }

            sendLeadsData(leadRecord, lead, RES_LeadCreation.inLoadTest) ;
        }
        catch (Exception e){
            RES_Logger.log('Post Leads Error: ' + e.getMessage());
            RES_Logger.log('URL: ' + RES_Util.getNamedCreds('Lead_Service') );
            RES_Logger.log('Request: ' + JSON.serialize(leadRecord)) ;
            lead = new Reservation__c(id = reservationId, LeadPosted__c = false) ;
            lead.LeadPosted__c = false ;
        }
    }

    // build the accessory config
    private static String buildAccessoriesConfig(List<Object> accessories) {
        if (accessories == null || accessories.isEmpty()) {
            return null;
        }

        List<String> config = new List<String>();
        config.add('\r\n  <accessories>\r\n');

        List <Map<String, Object>> accessoriesList = new List<Map<String,Object>>();
        for (Object accessory : accessories) {
            accessoriesList.add((Map<String, Object>)accessory);
        }

        for (Map<String,Object> accessory : accessoriesList) {
            //  <accessory option_name=\"Emblems – Black Chrome A-Spec\" msrp=\"224\" op_cd=\"TLX0021031\" />\r\n
            config.add('  <accessory option_name=\"' + accessory.get('name') + '\" ' + 'msrp=\"' + accessory.get('msrp') + '\"' + ' op_cd=\"' + accessory.get('opCode') + '\" />\r\n');
        }

        config.add('  </accessories>\r\n  ');
        return String.join(config,'');
    }

    //Build and send the Lead record:
    public static void sendLeadsData(Map<String,Object> leadRecord, Reservation__c lead, Boolean inLoadTest){
        HttpResponse response ;

        try {

            HttpRequest req = new HttpRequest() ;
            //Determine where we are calling from
            req.setEndpoint(RES_Util.getNamedCreds('Lead_Service'));
            req.setMethod('POST');
            req.setHeader('Content-Type','application/json');
            req.setBody(JSON.serialize(leadRecord));
            req.setTimeout(60000);
            Http http = new Http();
            response = http.send(req);
            pastCallout = true;
            handleLeadCreation(leadRecord, response, lead.id);
            lead.LeadPosted__c = response.getStatusCode() < 400;
        }
        catch (Exception e) {
            handleLeadCreationFailure(e, leadRecord, response, lead.id);
            lead.LeadPosted__c = false;
        }

        if (lead != null) {
            update lead;
        }
    }

    @TestVisible
    private static void handleLeadCreationFailure(Exception e, Map<String,Object> leadRecord, HttpResponse response, String reservationId){
        try{
            String message = e != null ? e.getMessage() : response?.getStatus() + ' ' + response?.getStatusCode()   + ' ' + response?.getBody() ;
            RES_Logger.log(LoggingLevel.ERROR, message, 'RES_LeadCreation', reservationId, 'Lead Failure', e, false) ;
            RES_Logger.log(LoggingLevel.ERROR, 'Failed Lead Request: ' + JSON.serialize(sanitizeLeadRecord(leadRecord)),'RES_LeadCreation',reservationId,'Bad Lead',null,false) ;
        }
        catch(Exception ex){ //NOPMD
            // eat it don't throw it
        }
    }

    private static void handleLeadCreation(Map<String,Object> leadRecord, HttpResponse response, String reservationId){
        try {
            String message = response?.getStatus() + ' ' + response?.getStatusCode()   + ' ' + response?.getBody() ;
            RES_Logger.log(LoggingLevel.DEBUG, message, 'RES_LeadCreation', reservationId, 'Lead Created', null, false) ;
            RES_Logger.log(LoggingLevel.DEBUG, 'Success Lead Request: ' + JSON.serialize(sanitizeLeadRecord(leadRecord)),'RES_LeadCreation',reservationId,'Good Lead',null,false);
        } catch(Exception ex) { //NOPMD
            // eat it don't throw it
        }
    }

    private static Map<String,Object> sanitizeLeadRecord(Map<String,Object> lead){
        lead.put('CustomerIPAddress','127.0.0.0') ;
        lead.put('Phone',String.valueOf(lead.get('Phone'))?.replaceAll('[0-9]', '*')) ;
        lead.put('Email',String.valueOf(lead.get('Email')).replaceAll('[0-9a-zA-Z]','*')) ;
        lead.put('LastName','**********') ;
        return lead ;
    }

    @TestVisible
    private static void log(String message)
    {
        try {
            if ( logMessages == null )
            {
                List<Reservation_Settings__mdt> settingsList = [SELECT id, Enable_Logging__c FROM Reservation_Settings__mdt WHERE DeveloperName = 'Default' ] ;
                if ( !settingsList.isempty()){
                    logMessages = settingsList[0].Enable_Logging__c ;
                }
            }
            if ( logMessages )
            {
                messages.add(new Res_Log__c(Log_Data__c = message)) ;
                if ( pastCallout ){
                    insert messages ;
                    messages.clear();
                }
            }
        }
        catch(Exception e){  //NOPMD
            // do nothing
        }

    }


}
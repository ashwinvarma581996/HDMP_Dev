/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class RES_Send_Email {

    @TestVisible
    private static Reservation_Settings__mdt psettings ;

    @InvocableMethod(label='Send Confirmation Email')
    public static void sendEmailAction(List<String>ids)  {
        List<String> reservationIds = new List<String>() ;
        try{
            for ( Reservation_Session__c session : [SELECT Reservation__c FROM Reservation_Session__c WHERE Cart__c IN :ids ORDER BY CreatedDate DESC ] )
            {
                reservationIds.add(session.Reservation__c) ;
            }
            sendEmail(reservationIds);
        }
        catch(Exception e){
            RES_Logger.log(LoggingLevel.ERROR,e.getMessage(),'RES_Send_Email.cls',reservationIds[0],'Error',e,false);
        }
    }

    @AuraEnabled
    //Not sure if this is being used.... 
    public static void sendConfirmation(String cartId){
        sendEmailAction(new List<String>{ cartId}) ;
    }

    @AuraEnabled
    //what is called form the Personal Info JavaScript Controller
    public static void sendConfirmationByRes(String reservationId){
        try {
            //call the send email function with a list
            sendEmail(new List<String>{reservationId}) ;
        } catch (Exception e) { 
            RES_Logger.log(LoggingLevel.ERROR,e.getMessage(),'RES_Send_Email.cls',reservationId,'Error',e,false);       }      }

    private static Map<String,Reservation_Session__c> getSessionsFromReservations(List<String> reservationIds){
        Map<String,Reservation_Session__c> rv = new Map<String,Reservation_Session__c>() ;
        for (Reservation_Session__c session : [SELECT Reservation__c, User__r.ContactId FROM Reservation_Session__c WHERE Reservation__c IN :reservationIds ] )
        {
            rv.put(session.Reservation__c,session) ;
        }
        return rv ;
    }
    //returns a map of the reservation email templates
    private static Map<String,String> getTemplatesFromReservations(List<String> reservationIds){
        Set<String> templateDevNameSet =  new Set<String>{getSettings().Waitlist_Confirmation_Template__c, getSettings().Reservation_Confirmation_Template__c, getSettings().Reservation_Lead_Template__c};
        Map<String,String> templateIds = new Map<String,String>() ;
        for (EmailTemplate template : [    SELECT Id, DeveloperName
                                            FROM EmailTemplate 
                                            WHERE Developername IN :templateDevNameSet] ){
            templateIds.put(template.DeveloperName, template.id)  ;
        }

        List<Reservation__c> reservations = [SELECT isWaitList__c, Is_Participating__c, Id FROM Reservation__c WHERE id IN :reservationIds] ;
        Map<String,Reservation__c> reservationMap = new Map<String,Reservation__c>(reservations) ;

        Map<String,String> rv = new Map<String,String>() ;

        for ( String id : reservationIds ){
            Reservation__c r = reservationMap.get(id) ;
            rv.put( id, 
                r.IsWaitList__c ? 
                templateIds.get(getSettings().Waitlist_Confirmation_Template__c) : 
                (  r.Is_Participating__c ? templateIds.get(getSettings().Reservation_Confirmation_Template__c) : templateIds.get(getSettings().Reservation_Lead_Template__c))) ;
        }

        return rv ;
    }

    public static void sendEmail(List<String> reservationIds) {
        //first get the session information using the reservation ID 
        Map<String,Reservation_Session__c> sessions = getSessionsFromReservations( reservationIds ) ;
        
        
        //then get the template Id using the reservation ID
        Map<String,String> templateIds = getTemplatesFromReservations(reservationIds) ;

        List<OrgWideEmailAddress> orgEmails = [ SELECT id FROM OrgWideEmailAddress WHERE DisplayName = 'Reserve'] ;
        String orgWideId = orgEmails.isEmpty() ? null : orgEmails[0].id ;

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>() ;

        for ( String reservationId : reservationIds ){
            //build the message
            messages.add(buildMessage(reservationId, sessions.get(ReservationId)?.User__r?.ContactID, orgWideId, templateIds.get(reservationId)) );
        }
        List<Reservation__c> reservationsToUpdate = new List<Reservation__c>() ;

        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        for ( integer i = 0 ; i < results.size(); i++){
            if ( results[i].isSuccess() ){
                reservationsToUpdate.add( new Reservation__c(Id = reservationIds[i], EmailSent__c = true)) ;
            }
        }
        update reservationsToUpdate ;
    }

    public String getTandCLink(){
        try{
            return [  SELECT SecureUrl FROM SiteDetail WHERE DurableId = :[  SELECT id FROM Site WHERE SiteType = 'ChatterNetworkPicasso' AND MasterLabel = :[ SELECT Network.Name FROM WebStoreNetwork WHERE WebStoreId = :getSettings().Storeid__c ][0].Network.Name][0].id][0].SecureUrl ; 
        }
        catch(Exception e){
            return 'https://reserve.acura.com/s' ;
        }
    }

    //custom metadata setting 
    private static Reservation_Settings__mdt getSettings(){
        if ( psettings == null ){
            psettings = RES_Settings.getSettings() ;
        }
        return psettings ;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static Messaging.SingleEmailMessage buildMessage(String reservationId, String contactId, String orgWideId, String templateId){

        if ( contactId == null )
        {
            //get the settings from the custom metadata. 
            String accountId = getSettings().Reservation_Account__c ;
            contactId = [SELECT id FROM Contact WHERE AccountId = :accountId LIMIT 1][0].id ;
        }

        List<Reservation__c> reservations = [SELECT Reservation_Contact2__c, Model_Name__c FROM Reservation__c WHERE id = :reservationId] ;
        if ( reservations.isEmpty())
        {
            throw new RES_Exception('Could not retrieve reservation in RES_Send_Email.buildMessage.  Reservation id: ' + reservationId) ;
        }

        List<Reservation_Contact2__c> contacts = [SELECT Email_Address__c FROM Reservation_Contact2__c WHERE id = :reservations[0].Reservation_Contact2__c] ;
        if ( contacts.isEmpty())
        {
            throw new RES_Exception('Could not retrieve reservation contact in RES_Send_Email.buildMessage.  Reservation Contact id: ' + reservations[0].Reservation_Contact2__c) ;
        }
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(contactId);
        String replyToAdd = getSettings().Reply_To_Address__c ;
        message.setReplyTo(replyToAdd);
        if ( orgWideId == null ) {
            message.setSenderDisplayName('Acura'); 
        }
        else {
            message.setOrgWideEmailAddressId(orgWideId) ;
        }
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        message.setTemplateID( templateId); 
        message.setWhatId(reservationId); //This is important for the merge fields in template to work
        message.setTreatTargetObjectAsRecipient(false) ;
        message.toAddresses = new String[] {  contacts[0].Email_Address__c};
        return message ;
    }

}
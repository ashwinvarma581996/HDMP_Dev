/**
 * @description       : 
 * @author            : mbunch@gorillagroup.com
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@istest
public class RES_LeadCreationTest {

    @TestSetup
    static void makeData(){
       Res_TestDataFactory.setUpReservationTest();
    }

    @istest
    public static void testCreateLeads() {
        WebCart cart = [SELECT id FROM WebCart LIMIT 1] ;
        Res_TestDataFactory.createSession() ;
        Test.setMock(HttpCalloutMock.class, new Res_LeadService_Mock());
        Res_LeadCreation.CreateLeadInput input = new RES_LeadCreation.CreateLeadInput() ;
        input.cartId = cart.id ;
        input.authCode = '12345' ;

        Exception e ;

        Test.startTest();
        try {
            RES_LeadCreation.createLead(new List<Res_LeadCreation.CreateLeadInput>{ input}) ;
        }
        catch (Exception ex) {
            e = ex ;
        }
        Test.stopTest();

        System.Assert(e == null, 'Expected no exception.  Recieved ' +  e?.getMessage());

    }
 
    @istest
    public static void testCreateLeads2() {
        
        Test.startTest();
        RES_LeadCreation.log('test');
        Test.stopTest();
    } 

     @istest
    public static void testCreateLeads1() {
        User u = [SELECT Id, UserRoleId, ProfileId, Username FROM User where profile.name ='System Administrator' and UserRoleId != null limit 1];
        List<Account> accList = [SELECT id FROM Account LIMIT 1] ;
        accList[0].ownerId=u.Id;
        update accList[0];
        List<WebStore> storeList = [SELECT id FROM WebStore LIMIT 1] ;
        WebCart cart = [SELECT id FROM WebCart LIMIT 1 ][0] ;
        Contact objCon = [SELECT id FROM Contact LIMIT 1][0] ;
       
        
        
    /*     System.runAs(u){
        Profile profile1 = [Select Id from Profile where name = 'Customer Community Plus Login User'];
            
            User portalAccountOwner1 = new User(
            
                ProfileId = profile1.Id,
                Username = System.now().millisecond() + 'test2@test.com',
                
                Alias = 'gst',
                Email='bruce.wayne56667@wayneenterprises.com',
                EmailEncodingKey='UTF-8',
                Firstname='Bruce',
                Lastname='Wayne',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                TimeZoneSidKey='America/Chicago',
                contactId=objCon.Id
            );
            insert portalAccountOwner1;
            
        }
 */       
        
      
        Reservation_Contact2__c resContact = Res_TestDataFactory.createReservationContact() ;
     
        Reservation__c reservation = Res_TestDataFactory.createReservation(resContact) ;
        Reservation_Session__c session = Res_TestDataFactory.createSession();
        Test.startTest();
        RES_LeadCreation.postLeadsFromReservation(reservation.id);
        RES_LeadCreation.postLeadsFromReservationAsync(reservation.id);
        RES_LeadCreation.postLeadsAsync(session.id);
        Test.stopTest();
    } 

    @IsTest
    public static void testLeadSanitize(){
        Exception e = new RES_Exception('test') ;
        Map<String,Object> dataToClean = new Map<String,Object>() ;
        dataToClean.put('LastName','Test') ;
        dataToClean.put('Phone','5555555555') ;
        dataToClean.put('Email','secret@example.com') ;
        RES_Settings.getSettings().Logging_Level__c = 'DEBUG' ;
        Test.startTest();
        RES_LeadCreation.handleLeadCreationFailure(e,dataToClean,null,null);
        Test.stopTest();
        List<RES_Log__c> logRecords = [SELECT id, Label__c, Log_Data__c FROM RES_Log__c ] ;
        System.Assert(logRecords.size() > 0, 'Log Records Expected' ) ;
        for ( RES_Log__c logRecord : logRecords ){
            if ( logRecord.Label__c == 'Bad Lead'){
                System.assert(logRecord.Log_Data__C.indexof('5555555555') == -1 , 'Expected sanitized data.  Received: ' + logRecord.Log_Data__c ) ;
            }
        }
    }
    
}
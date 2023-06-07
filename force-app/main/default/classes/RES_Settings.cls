/**
 * @description       :
 * @author            : mbunch@gorillagroup.com
 * @group             :
 * @last modified on  : 03-29-2022
 * @last modified by  : mbunch@gorillagroup.com
**/
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class RES_Settings {
    @TestVisible
    private static Reservation_Settings__mdt settings ;
    @TestVisible
    private static String webStoreId ;
    @TestVisible
    private static boolean useOrgDomain = false ;  // tests don't run as a community, use this flag to force the system to use the main org domain

    static {
        settings = getSettingsFromOrg() ;
    }

    public static Reservation_Settings__mdt getSettings(){
        if ( settings == null )
        {
            settings = getSettingsFromOrg() ;
        }
        return settings ;
    }

    @TestVisible
    private static String getWebStore()
    {
        return getSettings().StoreId__c ;
    }

    public static Reservation_Settings__mdt getSettings(String webStoreId){
        return getSettings() ;
    }

    @testVisible
    private static Reservation_Settings__mdt getSettingsFromOrg()
    {
        System.Domain d ;
        try {
            if ( Test.isRunningTest() && useOrgDomain ){
                throw new RES_Exception();
            }
            d = DomainParser.parse(Url.getSalesforceBaseUrl()) ;
        }
        catch(Exception e){
            try {
                d = DomainParser.parse(Url.getOrgDomainUrl()) ;
            }
            catch ( Exception ex){
                RES_Logger.log('Cannot find domain in RES_Settings.getSettingsFromOrg: ' + ex.getMessage() ) ;
            }
        }
        String orgName = d?.getSandboxName() == null ? 'Default' : d.getSandboxName() ;
        Reservation_Settings__mdt settings = readSettings(null, orgName) ;
        settings = readSettings(settings,'Default') ;
        if ( settings == null ){
            throw new RES_Exception('Unable to locate config') ;
        }
        return settings ;
    }

    private static Reservation_Settings__mdt readSettings(Reservation_Settings__mdt prev, String devName){
        if ( prev != null ){
            return prev ;
        }
        List<Reservation_Settings__mdt> settingsList = [
                SELECT id, Reservation_Account__c, StoreId__c, Reservation_Product_Id__c, Checkout_URL__c, User_Profile__c, Reservation_Cap__c, Base_Return_URL__c,
                    Include_No_Deposit_in_Cap_Calculation__c, Enable_Logging__c, Guest_User_Suffix__c, Guest_Nickname_Prefix__c, PI_Link__c, Privacy_Policy_URL__c,
                    Session_Timeout_minutes__c, Logging_Level__c, noCap__c, Reservation_Confirmation_Template__c, Waitlist_Confirmation_Template__c,
                    Reservation_Lead_Template__c, Reply_To_Address__c, BAP_Return_URL__c, CapKey__c
                FROM Reservation_Settings__mdt
                WHERE DeveloperName = :devName] ;
        if ( !settingsList.isEmpty())
        {
            return settingsList[0] ;
        }
        return null ;
    }

}